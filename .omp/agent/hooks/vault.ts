import type { HookAPI } from "@oh-my-pi/pi-coding-agent/extensibility/hooks";
import { execSync } from "node:child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { basename, join } from "node:path";

const VAULT = join(homedir(), "vault");
const PROJECTS = join(VAULT, "projects");

function detectProject(): { org: string; repo: string; branch: string } | null {
  try {
    const branch = execSync("git rev-parse --abbrev-ref HEAD", {
      cwd: process.env.INIT_CWD ?? process.cwd(),
      encoding: "utf-8",
      timeout: 3000,
    }).trim();

    const remote = execSync("git remote get-url origin", {
      cwd: process.env.INIT_CWD ?? process.cwd(),
      encoding: "utf-8",
      timeout: 3000,
    }).trim();

    const match = remote.match(/[:/]([^/]+)\/([^/]+?)(?:\.git)?$/);
    if (!match) return null;

    return { org: match[1], repo: match[2], branch };
  } catch {
    const cwd = process.env.INIT_CWD ?? process.cwd();
    return { org: "_local", repo: basename(cwd), branch: "main" };
  }
}

function readRecentNotes(project: { org: string; repo: string; branch: string }): string | null {
  const dir = join(PROJECTS, project.org, project.repo, project.branch);
  if (!existsSync(dir)) return null;

  const files = readdirSync(dir)
    .filter((f) => f.endsWith(".md"))
    .sort()
    .slice(-5); // last 5 sessions

  if (files.length === 0) return null;

  const parts = files.map((f) => {
    const content = readFileSync(join(dir, f), "utf-8");
    const body = content.replace(/^---\n[\s\S]*?\n---\n?/, "").trim();
    return `### ${f.replace(".md", "")}\n\n${body}`;
  });

  return `## Prior sessions (from vault)\n\nProject: ${project.org}/${project.repo}  \nBranch: ${project.branch}\n\n${parts.join("\n\n---\n\n")}`;
}

export default function vaultHook(pi: HookAPI): void {
  // Inject vault context on every session start
  pi.on("context", async () => {
    const project = detectProject();
    if (!project) return;

    const notes = readRecentNotes(project);
    if (!notes) return;

    return {
      messages: [{ role: "user" as const, content: notes }],
    };
  });

  // Shared: create vault stub (idempotent — one per day)
  const createStub = () => {
    const project = detectProject();
    if (!project) return;

    const timestamp = new Date().toISOString();
    const dateStr = timestamp.slice(0, 10);
    const dir = join(PROJECTS, project.org, project.repo, project.branch);
    const file = join(dir, `${dateStr}.md`);
    if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
    if (!existsSync(file)) {
      const header = [
        "---",
        `project: ${project.org}/${project.repo}`,
        `branch: ${project.branch}`,
        `date: ${timestamp}`,
        `tags: [${project.org}/${project.repo}, ${project.branch}]`,
        "---",
        "",
        `# ${project.org}/${project.repo} — ${project.branch} — ${dateStr}`,
        "",
      ].join("\n");
      writeFileSync(file, header, "utf-8");
    }
    pi.log?.(`Vault stub: ${file}`);
  };

  // On /new: create stub + summarize the session we're leaving behind
  pi.on("session_before_switch", async (event) => {
    if ((event as any).reason !== "new") return;
    createStub();
    const script = join(homedir(), ".omp/agent/hooks/post/save-to-vault.sh");
    if (!existsSync(script)) return;
    try {
      execSync(`bash "${script}"`, {
        cwd: process.env.INIT_CWD ?? process.cwd(),
        encoding: "utf-8",
        timeout: 60000,
        stdio: "pipe",
      });
    } catch (e: any) {
      const msg = e.stderr || e.message || String(e);
      pi.log?.(`[vault] summarize failed: ${msg.slice(0, 200)}`);
    }
  });

  // On shutdown: create stub (post-hook save-to-vault.sh handles summarization)
  pi.on("session_shutdown", async () => {
    createStub();
  });
}
