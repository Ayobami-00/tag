#!/usr/bin/env node
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { basename, resolve } from "node:path";

const options = parseArgs(process.argv.slice(2));
const pr = required(options.pr, "--pr");
const status = options.status || "pass";
const video = required(options.video || options.video_url, "--video");
const commandLog = required(options.command_log || options.log, "--command-log");
const attempt = options.attempt || "1";
const headSha = options.head_sha || gitHeadSha();
const outputDir = resolve(options.output_dir || "artifacts/demo_proofs", `pr_${pr}`, `attempt_${attempt}`);
mkdirSync(outputDir, { recursive: true });

const proof = {
  schema: "tag-demo-proof/v1",
  pr: Number(pr),
  attempt: Number(attempt),
  status,
  head_sha: headSha,
  video,
  command_log: commandLog,
  generated_at: new Date().toISOString(),
  notes: options.notes || "",
};

const jsonPath = resolve(outputDir, "demo-proof.json");
const commentPath = resolve(outputDir, "demo-proof-comment.md");
writeFileSync(jsonPath, `${JSON.stringify(proof, null, 2)}\n`);
writeFileSync(commentPath, commentFor(proof));

console.log(`Demo proof JSON: ${jsonPath}`);
console.log(`Demo proof comment: ${commentPath}`);

function commentFor(proof) {
  return [
    `Tag demo proof: ${proof.status}`,
    "",
    `PR: #${proof.pr}`,
    `Attempt: ${proof.attempt}`,
    `Head SHA: ${proof.head_sha}`,
    `Video: ${proof.video}`,
    `Command log: ${proof.command_log}`,
    proof.notes ? `Notes: ${proof.notes}` : "",
    "",
    "<!-- tag-demo-proof",
    JSON.stringify(proof, null, 2),
    "-->",
    "",
  ].filter((line) => line !== "").join("\n");
}

function parseArgs(args) {
  const parsed = {};
  for (let index = 0; index < args.length; index++) {
    const arg = args[index];
    if (!arg.startsWith("--")) continue;
    const key = arg.slice(2).replace(/-/g, "_");
    parsed[key] = args[index + 1];
    index++;
  }
  return parsed;
}

function required(value, name) {
  if (!value) {
    console.error(`Missing ${name}`);
    process.exit(1);
  }
  return value;
}

function gitHeadSha() {
  try {
    return execFileSync("git", ["rev-parse", "HEAD"], { encoding: "utf8" }).trim();
  } catch {
    return "";
  }
}
