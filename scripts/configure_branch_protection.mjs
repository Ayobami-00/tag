#!/usr/bin/env node
import { execFileSync } from "node:child_process";

const repo = process.env.GITHUB_REPOSITORY || gitHubRepoFromRemote();
const token = process.env.GITHUB_TOKEN || process.env.GH_TOKEN || ghToken();
const branch = process.argv[2] || "main";
const contexts = (process.env.REQUIRED_STATUS_CONTEXTS ||
  "Flutter analyze and test,Tag PR acceptance gate")
  .split(",")
  .map((value) => value.trim())
  .filter(Boolean);

if (!repo) {
  console.error("Missing GITHUB_REPOSITORY and could not infer origin repo.");
  process.exit(1);
}
if (!token) {
  console.error("Missing GITHUB_TOKEN/GH_TOKEN and gh auth token is unavailable.");
  process.exit(1);
}

const [owner, repoName] = repo.split("/");
const body = {
  required_status_checks: {
    strict: true,
    contexts,
  },
  enforce_admins: false,
  required_pull_request_reviews: null,
  restrictions: null,
  required_linear_history: false,
  allow_force_pushes: false,
  allow_deletions: false,
  block_creations: false,
  required_conversation_resolution: true,
  lock_branch: false,
  allow_fork_syncing: true,
};

const response = await fetch(
  `https://api.github.com/repos/${owner}/${repoName}/branches/${encodeURIComponent(branch)}/protection`,
  {
    method: "PUT",
    headers: {
      accept: "application/vnd.github+json",
      authorization: `Bearer ${token}`,
      "content-type": "application/json",
      "x-github-api-version": "2022-11-28",
    },
    body: JSON.stringify(body),
  },
);

if (!response.ok) {
  throw new Error(`Branch protection update failed: ${response.status} ${await response.text()}`);
}

console.log(`Protected ${repo}:${branch}`);
console.log(`Required status contexts: ${contexts.join(", ")}`);
console.log("Required conversation resolution: true");

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
