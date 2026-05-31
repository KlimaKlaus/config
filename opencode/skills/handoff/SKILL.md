---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up. Use when the user says "handoff", "hand off", "create a handoff", "save state for another agent", or asks to summarize the session for a new agent to continue.
---

# Handoff

Write a handoff document summarizing the current conversation so a fresh agent can continue the work.

## Output location

Save the document to the OS temporary directory (`os.tmpdir()` / `$TMPDIR` / `%TEMP%`). Do **not** save to the workspace. Name it descriptively (e.g., `handoff-<project>-<topic>.md`).

## Document structure

```markdown
# Handoff: <project/session name>

## Context
<one-paragraph summary of the project, what was being worked on, and the current state>

## Completed work
- <bullet-point summary of what was done this session>

## Remaining work
- <unfinished items, next steps, open questions>

## Key decisions
- <architecture, design, or approach decisions made>

## State to preserve
- <running processes, important variable values, data files, URLs, credentials (redacted!), port numbers, etc.>

## Suggested skills
<list of skill names this agent should invoke on startup, e.g.: brainstorming, verification-before-completion, systematic-debugging>

## References
- <paths or URLs to PRDs, plans, ADRs, issues, commits, diffs — do NOT inline content already captured elsewhere>
```

## Content rules

1. **Do not duplicate** content already captured in external artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.
2. **Redact** API keys, passwords, tokens, PII. Replace with `<REDACTED>` or a placeholder like `[set env VAR_NAME]`.
3. If the user passed arguments when invoking the skill, treat them as a description of what the next session will focus on and tailor the document accordingly.

## Tone

Concise and factual. Assume the next agent has no prior context.
