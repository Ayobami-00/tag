#!/usr/bin/env node
import { execFileSync } from "node:child_process";
import {
  existsSync,
  mkdirSync,
  readFileSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { basename, extname, resolve } from "node:path";

const options = parseArgs(process.argv.slice(2));
const pr = required(options.pr, "--pr");
const status = options.status || "pass";
const video = required(options.video || options.video_url, "--video");
const commandLog = required(options.command_log || options.log, "--command-log");
const attempt = options.attempt || "1";
const headSha = options.head_sha || gitHeadSha();
const outputDir = resolve(options.output_dir || "artifacts/demo_proofs", `pr_${pr}`, `attempt_${attempt}`);
mkdirSync(outputDir, { recursive: true });
const bucket = options.bucket || "demo-proofs";
const shouldUpload = !options.dry_run && !options.no_upload;

const proof = {
  schema: "tag-demo-proof/v2",
  pr: Number(pr),
  issue: options.issue ? Number(options.issue) : null,
  attempt: Number(attempt),
  status,
  head_sha: headSha,
  video_file: basename(video),
  command_log_file: basename(commandLog),
  storage_bucket: bucket,
  video_path: null,
  command_log_path: null,
  manifest_path: null,
  generated_at: new Date().toISOString(),
  notes: options.notes || "",
};

const jsonPath = resolve(outputDir, "demo-proof.json");
writeFileSync(jsonPath, `${JSON.stringify(proof, null, 2)}\n`);

console.log(`Demo proof JSON: ${jsonPath}`);

if (shouldUpload) {
  await uploadProof(proof, { bucket, video, commandLog, jsonPath });
  writeFileSync(jsonPath, `${JSON.stringify(proof, null, 2)}\n`);
  await upsertProofRow(proof, { video, commandLog });
  console.log(`Supabase bucket: ${proof.storage_bucket}`);
  console.log(`Video path: ${proof.video_path}`);
  console.log(`Command log path: ${proof.command_log_path}`);
  console.log(`Manifest path: ${proof.manifest_path}`);
} else {
  console.log("Supabase upload skipped.");
}

async function uploadProof(proof, { bucket, video, commandLog, jsonPath }) {
  const prefix = [
    `pr-${proof.pr}`,
    `attempt-${proof.attempt}`,
    proof.head_sha || "unknown-head",
  ].join("/");

  proof.video_path = await uploadObject({
    bucket,
    path: `${prefix}/${basename(video)}`,
    body: readFileSync(video),
    contentType: contentTypeFor(video),
  });
  proof.command_log_path = await uploadObject({
    bucket,
    path: `${prefix}/${basename(commandLog)}`,
    body: readFileSync(commandLog),
    contentType: "text/plain; charset=utf-8",
  });

  const manifestPath = `${prefix}/demo-proof.json`;
  proof.manifest_path = manifestPath;
  const manifestBody = Buffer.from(`${JSON.stringify(proof, null, 2)}\n`);
  writeFileSync(jsonPath, manifestBody);
  await uploadObject({
    bucket,
    path: manifestPath,
    body: manifestBody,
    contentType: "application/json; charset=utf-8",
  });
}

async function uploadObject({ bucket, path, body, contentType }) {
  const config = env();
  const baseUrl = requiredEnv(config, "SUPABASE_URL").replace(/\/$/, "");
  const serviceRoleKey = requiredEnv(config, "SUPABASE_SERVICE_ROLE_KEY");
  const response = await fetch(
    `${baseUrl}/storage/v1/object/${encodePath(`${bucket}/${path}`)}`,
    {
      method: "POST",
      headers: {
        authorization: `Bearer ${serviceRoleKey}`,
        apikey: serviceRoleKey,
        "content-type": contentType,
        "cache-control": "private, max-age=0",
        "x-upsert": "true",
      },
      body,
    },
  );

  if (!response.ok) {
    throw new Error(`Supabase proof upload failed for ${path}: ${await response.text()}`);
  }
  return path;
}

async function upsertProofRow(proof, { video, commandLog }) {
  const config = env();
  const baseUrl = requiredEnv(config, "SUPABASE_URL").replace(/\/$/, "");
  const serviceRoleKey = requiredEnv(config, "SUPABASE_SERVICE_ROLE_KEY");
  const response = await fetch(`${baseUrl}/rest/v1/demo_proofs`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${serviceRoleKey}`,
      apikey: serviceRoleKey,
      "content-type": "application/json",
      prefer: "return=minimal",
    },
    body: JSON.stringify({
      github_pr_number: proof.pr,
      github_issue_number: proof.issue,
      attempt: proof.attempt,
      status: proof.status,
      head_sha: proof.head_sha,
      storage_bucket: proof.storage_bucket,
      video_path: proof.video_path,
      command_log_path: proof.command_log_path,
      manifest_path: proof.manifest_path,
      video_byte_size: statSync(video).size,
      command_log_byte_size: statSync(commandLog).size,
      notes: proof.notes || null,
    }),
  });

  if (!response.ok) {
    throw new Error(`Supabase demo_proofs insert failed: ${await response.text()}`);
  }
}

function parseArgs(args) {
  const parsed = {};
  for (let index = 0; index < args.length; index++) {
    const arg = args[index];
    if (!arg.startsWith("--")) continue;
    const key = arg.slice(2).replace(/-/g, "_");
    const next = args[index + 1];
    if (!next || next.startsWith("--")) {
      parsed[key] = true;
      continue;
    }
    parsed[key] = next;
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

function contentTypeFor(path) {
  const extension = extname(path).toLowerCase();
  if (extension === ".mp4") return "video/mp4";
  if (extension === ".mov") return "video/quicktime";
  if (extension === ".webm") return "video/webm";
  if (extension === ".log" || extension === ".txt") return "text/plain; charset=utf-8";
  return "application/octet-stream";
}

function env() {
  const repoRoot = resolve(import.meta.dirname, "..");
  return {
    ...loadEnv(resolve(repoRoot, "internal/.env.local")),
    ...loadEnv(resolve(repoRoot, "internal/supabase/.env")),
    ...process.env,
  };
}

function loadEnv(path) {
  if (!existsSync(path)) return {};
  const entries = {};
  const lines = readFileSync(path, "utf8").split(/\r?\n/);

  for (let index = 0; index < lines.length; index++) {
    const raw = lines[index];
    const line = raw.trim();
    if (!line || line.startsWith("#")) continue;
    const equalsIndex = line.indexOf("=");
    if (equalsIndex < 0) continue;

    const key = line.slice(0, equalsIndex).trim();
    let value = raw.slice(raw.indexOf("=") + 1).trim();

    if (
      key === "GITHUB_APP_PRIVATE_KEY" &&
      value.includes("BEGIN") &&
      !value.includes("END")
    ) {
      const chunks = [value];
      while (index + 1 < lines.length) {
        index++;
        chunks.push(lines[index].trim());
        if (lines[index].includes("END") && lines[index].includes("KEY")) break;
      }
      value = chunks.join("\n");
    }

    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    entries[key] = value.replaceAll("\\n", "\n");
  }

  return entries;
}

function requiredEnv(config, name) {
  const value = config[name];
  if (!value) {
    throw new Error(`Missing ${name}; demo proof upload needs Supabase service-role credentials.`);
  }
  return value;
}

function encodePath(path) {
  return path.split("/").map(encodeURIComponent).join("/");
}
