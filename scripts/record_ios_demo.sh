#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 || "$2" != "--" ]]; then
  echo "Usage: scripts/record_ios_demo.sh <attempt-name> -- <command> [args...]" >&2
  exit 2
fi

attempt_name="$1"
shift 2

artifact_root="artifacts/demo_proofs/${attempt_name}"
mkdir -p "$artifact_root"
artifact_root_abs="$(cd "$artifact_root" && pwd)"

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
video_path="${artifact_root_abs}/demo_${timestamp}.mp4"
log_path="${artifact_root}/command_${timestamp}.log"

echo "Recording simulator video to ${video_path}"
xcrun simctl io booted recordVideo "$video_path" >/tmp/tag_demo_record_video.log 2>&1 &
record_pid=$!

cleanup() {
  if kill -0 "$record_pid" >/dev/null 2>&1; then
    kill -INT "$record_pid" >/dev/null 2>&1 || true
    wait "$record_pid" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

set +e
"$@" >"$log_path" 2>&1
command_status=$?
set -e

cleanup
trap - EXIT

if [[ ! -s "$video_path" ]]; then
  echo "Simulator video was not created. Recorder output:" >&2
  cat /tmp/tag_demo_record_video.log >&2 || true
  exit 1
fi

echo "Command log: ${log_path}"
echo "Video: ${video_path}"
exit "$command_status"
