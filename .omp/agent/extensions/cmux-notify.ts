import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { execFileSync } from "node:child_process";

export default function (pi: ExtensionAPI) {
  // Notify after every response. Change to "session_shutdown" to only
  // notify when the omp process exits.
  pi.on("turn_end", async () => {
    try {
      execFileSync("cmux", [
        "notify",
        "--title", "omp",
        "--body", "Response ready",
      ]);
    } catch {
      // Not running inside cmux — silently no-op.
    }
  });
}
