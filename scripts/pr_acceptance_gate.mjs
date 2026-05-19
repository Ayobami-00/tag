#!/usr/bin/env node
import { execFileSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";

const repo = process.env.GITHUB_REPOSITORY || gitHubRepoFromRemote();
const token = process.env.GITHUB_TOKEN || process.env.GH_TOKEN || ghToken();
const eventName = process.env.GITHUB_EVENT_NAME || "";
const eventPath = process.env.GITHUB_EVENT_PATH || "";
const event = readEvent(eventPath);
const prNumber = numberArg("--pr") || prNumberFromEvent(eventName, event);

if (!repo) failSetup("Missing GITHUB_REPOSITORY and could not infer origin repo.");
if (!token) failSetup("Missing GITHUB_TOKEN/GH_TOKEN and gh auth token is unavailable.");
if (!prNumber) {
  console.log("No pull request found for this event; skipping gate.");
  process.exit(0);
}

const [owner, repoName] = repo.split("/");
const requiredChecks = csvEnv("REQUIRED_CHECKS", ["Flutter analyze and test"]);
const gateCheckName = process.env.GATE_CHECK_NAME || "Tag PR acceptance gate";
const greptileScore = process.env.GREPTILE_REQUIRED_SCORE || "5/5";
const greptilePattern = new RegExp(
  process.env.GREPTILE_ACTOR_PATTERN || "greptile",
  "i",
);

const pr = await api(`/repos/${owner}/${repoName}/pulls/${prNumber}`);
const [comments, reviews, reviewComments, checks] = await Promise.all([
  api(`/repos/${owner}/${repoName}/issues/${prNumber}/comments?per_page=100`),
  api(`/repos/${owner}/${repoName}/pulls/${prNumber}/reviews?per_page=100`),
  api(`/repos/${owner}/${repoName}/pulls/${prNumber}/comments?per_page=100`),
  api(`/repos/${owner}/${repoName}/commits/${pr.head.sha}/check-runs?per_page=100`, {
    accept: "application/vnd.github+json",
  }),
]);

const failures = [];
const checkResult = requiredCheckResult(checks.check_runs || [], requiredChecks);
if (!checkResult.ok) failures.push(...checkResult.failures);

const proof = latestDemoProof(pr, comments);
if (!proof) {
  failures.push("Missing current Tag demo proof marker.");
} else {
  if (proof.status !== "pass") {
    failures.push(`Demo proof status is ${proof.status}; expected pass.`);
  }
  if (proof.head_sha !== pr.head.sha) {
    failures.push(
      `Demo proof head_sha ${proof.head_sha || "missing"} does not match PR head ${pr.head.sha}.`,
    );
  }
  if (!proof.video && !proof.video_url) {
    failures.push("Demo proof is missing video or video_url.");
  }
  if (!proof.command_log && !proof.log && !proof.log_url) {
    failures.push("Demo proof is missing command_log/log evidence.");
  }
}

const greptile = latestGreptileScore({
  comments,
  reviews,
  reviewComments,
  checkRuns: checks.check_runs || [],
});
if (!greptile) {
  failures.push(`Missing Greptile ${greptileScore} review score.`);
} else if (greptile.score !== greptileScore) {
  failures.push(`Latest Greptile score is ${greptile.score}; expected ${greptileScore}.`);
}

const blocker = unresolvedHumanBlocker({ comments, reviews, reviewComments });
if (blocker) {
  failures.push(`Unresolved human blocker from ${blocker.author}: ${oneLine(blocker.body, 140)}`);
}

const summary = {
  pr: pr.html_url,
  head_sha: pr.head.sha,
  required_checks: checkResult.summary,
  greptile_score: greptile?.score ?? null,
  demo_proof: proof
    ? {
        status: proof.status,
        attempt: proof.attempt ?? null,
        head_sha: proof.head_sha,
        video: proof.video_url || proof.video,
      }
    : null,
  human_blocker: blocker ? { author: blocker.author, created_at: blocker.created_at } : null,
  pass: failures.length === 0,
};

console.log(JSON.stringify(summary, null, 2));
writeStepSummary(summary, failures);

if (failures.length) {
  console.error("\nPR acceptance gate failed:");
  for (const failure of failures) console.error(`- ${failure}`);
  process.exit(1);
}

console.log("\nPR acceptance gate passed.");

function requiredCheckResult(checkRuns, names) {
  const failures = [];
  const summary = {};
  for (const name of names) {
    const matching = checkRuns
      .filter((check) => check.name === name)
      .sort((a, b) => new Date(b.started_at || b.created_at) - new Date(a.started_at || a.created_at));
    const latest = matching[0];
    summary[name] = latest
      ? { status: latest.status, conclusion: latest.conclusion }
      : { status: "missing", conclusion: null };
    if (!latest) {
      failures.push(`Missing required check: ${name}.`);
    } else if (latest.status !== "completed" || latest.conclusion !== "success") {
      failures.push(
        `Required check ${name} is ${latest.status}/${latest.conclusion || "no conclusion"}.`,
      );
    }
  }

  for (const check of checkRuns) {
    if (check.name === gateCheckName) continue;
    if (/greptile/i.test(check.name)) continue;
    if (names.includes(check.name)) continue;
    if (check.status === "completed" && ["failure", "timed_out", "cancelled"].includes(check.conclusion)) {
      failures.push(`Check ${check.name} concluded ${check.conclusion}.`);
    }
  }

  return { ok: failures.length === 0, failures, summary };
}

function latestDemoProof(pr, comments) {
  const sources = [
    { body: pr.body || "", created_at: pr.updated_at, author: pr.user?.login },
    ...comments.map((comment) => ({
      body: comment.body || "",
      created_at: comment.updated_at || comment.created_at,
      author: comment.user?.login,
    })),
  ];

  const proofs = [];
  for (const source of sources) {
    for (const proof of demoProofsFromBody(source.body)) {
      proofs.push({ ...proof, created_at: source.created_at, author: source.author });
    }
  }
  return proofs.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))[0] || null;
}

function demoProofsFromBody(body) {
  const proofs = [];
  const marker = /<!--\s*tag-demo-proof\s*([\s\S]*?)\s*-->/gi;
  for (const match of body.matchAll(marker)) {
    try {
      proofs.push(JSON.parse(match[1].trim()));
    } catch {
      // Ignore malformed historical markers; the gate will fail if none parse.
    }
  }

  if (/tag demo proof\s*:\s*pass/i.test(body)) {
    proofs.push({
      status: "pass",
      head_sha: lineValue(body, "Head SHA"),
      video: lineValue(body, "Video") || lineValue(body, "Video URL"),
      command_log: lineValue(body, "Command log") || lineValue(body, "Log"),
      attempt: lineValue(body, "Attempt"),
    });
  }
  return proofs;
}

function latestGreptileScore({ comments, reviews, reviewComments, checkRuns }) {
  const sources = [];
  for (const comment of comments) {
    sources.push({
      body: comment.body || "",
      author: comment.user?.login || "",
      created_at: comment.updated_at || comment.created_at,
    });
  }
  for (const review of reviews) {
    sources.push({
      body: review.body || "",
      author: review.user?.login || "",
      created_at: review.submitted_at,
    });
  }
  for (const comment of reviewComments) {
    sources.push({
      body: comment.body || "",
      author: comment.user?.login || "",
      created_at: comment.updated_at || comment.created_at,
    });
  }
  for (const check of checkRuns) {
    sources.push({
      body: [check.name, check.output?.title, check.output?.summary, check.output?.text]
        .filter(Boolean)
        .join("\n"),
      author: check.app?.slug || check.app?.name || "",
      created_at: check.completed_at || check.started_at || check.created_at,
    });
  }

  return sources
    .filter((source) => greptilePattern.test(source.author) || /greptile/i.test(source.body))
    .map((source) => ({ ...source, score: scoreFromText(source.body) }))
    .filter((source) => source.score)
    .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))[0] || null;
}

function scoreFromText(text) {
  const patterns = [
    /\b(?:score|rating|review score|overall)\s*[:=-]?\s*(\d+)\s*\/\s*(\d+)\b/i,
    /\b(\d+)\s*\/\s*5\b/i,
    /\b(\d+)\s+out\s+of\s+5\b/i,
  ];
  for (const pattern of patterns) {
    const match = text.match(pattern);
    if (match) return `${Number(match[1])}/${Number(match[2] || 5)}`;
  }
  return null;
}

function unresolvedHumanBlocker({ comments, reviews, reviewComments }) {
  const blockers = [];
  const resolvers = [];
  const latestReviewByUser = new Map();

  const allComments = [
    ...comments.map((comment) => ({
      body: comment.body || "",
      author: comment.user?.login || "",
      type: comment.user?.type || "",
      created_at: comment.updated_at || comment.created_at,
    })),
    ...reviewComments.map((comment) => ({
      body: comment.body || "",
      author: comment.user?.login || "",
      type: comment.user?.type || "",
      created_at: comment.updated_at || comment.created_at,
    })),
  ];

  for (const comment of allComments) {
    if (isBot(comment)) continue;
    if (isResolveComment(comment.body)) resolvers.push(comment);
    if (isBlockerComment(comment.body)) blockers.push(comment);
  }

  for (const review of reviews) {
    if (isBot({ author: review.user?.login || "", type: review.user?.type || "" })) continue;
    const prior = latestReviewByUser.get(review.user.login);
    if (!prior || new Date(review.submitted_at) > new Date(prior.submitted_at)) {
      latestReviewByUser.set(review.user.login, review);
    }
  }

  for (const review of latestReviewByUser.values()) {
    if (review.state === "CHANGES_REQUESTED") {
      blockers.push({
        body: review.body || "Changes requested",
        author: review.user.login,
        created_at: review.submitted_at,
      });
    }
  }

  const latestResolverTime = resolvers.length
    ? Math.max(...resolvers.map((comment) => new Date(comment.created_at).getTime()))
    : 0;

  return blockers
    .filter((blocker) => new Date(blocker.created_at).getTime() > latestResolverTime)
    .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))[0] || null;
}

function isBot(source) {
  return source.type === "Bot" || /\[bot\]$/i.test(source.author) || greptilePattern.test(source.author);
}

function isBlockerComment(body) {
  return /(^|\n)\s*\/codex\s+(retry|again|not[- ]fixed)\b/i.test(body) ||
    /\bnot fixed\b/i.test(body) ||
    /\bstill broken\b/i.test(body) ||
    /\bblocking\b/i.test(body);
}

function isResolveComment(body) {
  return /(^|\n)\s*\/codex\s+(resolved|fixed|approve|approved)\b/i.test(body) ||
    /\bfixed confirmed\b/i.test(body) ||
    /\bdemo accepted\b/i.test(body);
}

async function api(path, options = {}) {
  const response = await fetch(`https://api.github.com${path}`, {
    headers: {
      accept: options.accept || "application/vnd.github+json",
      authorization: `Bearer ${token}`,
      "x-github-api-version": "2022-11-28",
    },
  });
  if (!response.ok) {
    throw new Error(`GitHub API ${path} failed: ${response.status} ${await response.text()}`);
  }
  return response.json();
}

function prNumberFromEvent(name, payload) {
  if (payload.pull_request?.number) return payload.pull_request.number;
  if (payload.issue?.pull_request && payload.issue?.number) return payload.issue.number;
  if (payload.review?.pull_request_url) return Number(payload.pull_request?.number);
  if (name === "workflow_run") {
    return payload.workflow_run?.pull_requests?.[0]?.number;
  }
  return null;
}

function numberArg(name) {
  const index = process.argv.indexOf(name);
  if (index === -1) return null;
  return Number(process.argv[index + 1]);
}

function csvEnv(name, fallback) {
  return (process.env[name] || "")
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean)
    .concat(process.env[name] ? [] : fallback);
}

function readEvent(path) {
  if (!path || !existsSync(path)) return {};
  return JSON.parse(readFileSync(path, "utf8"));
}

function ghToken() {
  try {
    return execFileSync("gh", ["auth", "token"], { encoding: "utf8" }).trim();
  } catch {
    return "";
  }
}

function gitHubRepoFromRemote() {
  try {
    const remote = execFileSync("git", ["remote", "get-url", "origin"], {
      encoding: "utf8",
    }).trim();
    const match = remote.match(/github\.com[:/](.+?\/.+?)(?:\.git)?$/);
    return match?.[1] || "";
  } catch {
    return "";
  }
}

function lineValue(body, label) {
  const match = body.match(new RegExp(`^\\s*${escapeRegex(label)}\\s*:\\s*(.+)$`, "im"));
  return match?.[1]?.trim() || "";
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function oneLine(value, max) {
  const text = String(value || "").replace(/\s+/g, " ").trim();
  return text.length > max ? `${text.slice(0, max - 1)}…` : text;
}

function writeStepSummary(summary, failures) {
  if (!process.env.GITHUB_STEP_SUMMARY) return;
  const lines = [
    "## Tag PR Acceptance Gate",
    "",
    `PR: ${summary.pr}`,
    `Head SHA: \`${summary.head_sha}\``,
    `Greptile score: ${summary.greptile_score || "missing"}`,
    `Demo proof: ${summary.demo_proof ? summary.demo_proof.status : "missing"}`,
    `Human blocker: ${summary.human_blocker ? "yes" : "none"}`,
    "",
  ];
  if (failures.length) {
    lines.push("### Blocking", ...failures.map((failure) => `- ${failure}`));
  } else {
    lines.push("All acceptance requirements passed.");
  }
  execFileSync("bash", [
    "-lc",
    `cat >> "$GITHUB_STEP_SUMMARY" <<'EOF'\n${lines.join("\n")}\nEOF`,
  ]);
}

function failSetup(message) {
  console.error(message);
  process.exit(1);
}
