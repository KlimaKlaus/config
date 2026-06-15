Return valid JSON only. Do not wrap it in markdown fences or add commentary.

Schema:
{
  "summary": "3-5 concise bullets or a short paragraph describing what was worked on, files or areas touched, and the final state.",
  "wins": ["1-4 bullets about what the assistant did correctly or what went well"],
  "corrections": ["1-4 bullets about mistakes, wrong assumptions, fixes, or places where the user had to correct the assistant"]
}

Guidance:
- Be specific about the actual work in the session.
- Include both successful work and corrections the user had to make.
- If there were no mistakes or wins worth noting, use empty arrays.