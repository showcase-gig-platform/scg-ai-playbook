---
name: anthropic-skill-creator
description: Create and iteratively improve Cursor Agent Skills using the Anthropic skill-creator workflow. Use when the user wants to create a skill from scratch, refine an existing skill with test prompts and feedback, or follow a structured draft→test→review→improve loop for skills.
---

# Anthropic-Style Skill Creator

Workflow for creating and improving Cursor skills. Adapted from [anthropics/skills](https://github.com/anthropics/skills) skill-creator.

**Core loop:** Capture intent → Draft skill → Run 2–3 test prompts → User reviews outputs → Improve from feedback → Repeat until satisfied.

---

## 1. Capture Intent

Before writing, clarify:

1. **What should this skill enable the agent to do?**
2. **When should it trigger?** (user phrases, file types, context)
3. **Expected output format?** (templates, structure)
4. **Test cases?** Skills with verifiable outputs (file transforms, data extraction, code) benefit from test prompts. Subjective outputs (tone, design) often don’t — suggest based on type, let user decide.

If the conversation already shows a workflow (“turn this into a skill”), extract from history: steps, tools, corrections, formats. Fill gaps with the user and confirm before drafting.

---

## 2. Interview and Research

Ask about edge cases, I/O formats, example files, success criteria, dependencies. Don’t write test prompts until this is clear.

If useful, search the codebase or web for similar skills, conventions, or docs — come with context so the user doesn’t have to repeat.

---

## 3. Write the SKILL.md

**Paths in Cursor:**

| Type    | Path                     | Scope        |
|---------|--------------------------|--------------|
| Personal | `~/.cursor/skills/<name>/` | All projects |
| Project  | `.cursor/skills/<name>/`  | This repo    |

**Do not** create skills in `~/.cursor/skills-cursor/` — that’s for Cursor’s built-in skills.

**Frontmatter:**

- **name**: Lowercase, hyphens, unique id.
- **description**: Primary trigger. Include both **what** the skill does and **when** to use it (phrases, contexts). Cursor tends to undertrigger — be a bit “pushy”, e.g. “Use this skill whenever the user mentions dashboards, data viz, or internal metrics, even if they don’t say ‘dashboard’.”
- **compatibility**: Optional; only if specific tools/deps are required.

---

### Skill anatomy

```
skill-name/
├── SKILL.md       # Required — frontmatter + instructions
├── references/    # Optional — docs to read when needed
├── scripts/       # Optional — runnable helpers
└── assets/        # Optional — templates, static files
```

---

### Progressive disclosure

- **Metadata** (name + description): Always in context.
- **SKILL.md body**: When skill triggers; keep under ~500 lines.
- **Bundled files**: Load only when needed; link from SKILL.md with “when to read”.

Patterns:

- Keep SKILL.md under 500 lines; if close, add hierarchy and pointers to reference files.
- For long references (>300 lines), add a short ToC in SKILL.md.
- Multi-domain skills: one SKILL.md + `references/aws.md`, `references/gcp.md`, etc.; instruct to read only the relevant one.

---

### Writing style

- Prefer **imperative** instructions.
- Explain **why** instead of stacking MUSTs. Skills that teach reasoning generalize better.
- Avoid overfitting to one example; keep instructions general.

**Output format:**

```markdown
## Report structure
Use this template:
# [Title]
## Executive summary
## Key findings
## Recommendations
```

**Examples:**

```markdown
## Commit format
**Example 1:**
Input: Added user auth with JWT
Output: feat(auth): implement JWT-based authentication
```

---

### Principle of lack of surprise

No malware, exploits, or misleading intent. Don’t create skills for unauthorized access or data exfiltration. Roleplay/creative skills are fine if described honestly.

---

## 4. Test cases

After the draft, propose **2–3 realistic test prompts** — what a real user would say. Confirm with the user, then run them.

**In Cursor:** You have the skill in context. For each prompt, follow the skill’s instructions and produce the output. Save outputs under a workspace folder, e.g. `skill-workspace/iteration-1/eval-1/`, and show the user (files, snippets, or summary).

Optional: record prompts in `evals/evals.json` for later iterations:

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's task prompt",
      "expected_output": "What good looks like",
      "files": []
    }
  ]
}
```

---

## 5. Review and iterate

- Show the user each test case: prompt + output.
- Ask for feedback (inline or structured).
- Improve the skill from feedback:
  - **Generalize** — fix the underlying pattern, not only the example.
  - **Trim** — remove instructions that don’t help; check if the agent is wasting steps and simplify.
  - **Explain why** — turn rigid MUSTs into reasoning so the agent can generalize.
  - **Reuse repeated work** — if every run builds the same helper, put it in `scripts/` and tell the skill to use it.

Then: run the same (or updated) test prompts again into a new iteration folder, get feedback again, repeat until the user is satisfied or feedback is empty.

---

## 6. Description tuning (optional)

After the skill is stable, offer to refine the **description** for better triggering.

- Draft 8–10 **should-trigger** prompts (different phrasings, implicit intents, edge cases).
- Draft 8–10 **should-not-trigger** prompts (near-misses: same domain but different need).
- Make prompts concrete (paths, context, real-looking detail), not generic.
- Review with the user, then try a few prompts in conversation and see if the skill is suggested when it should be; adjust description wording based on results.

No custom tooling required — this is manual try-and-adjust in Cursor.

---

## Reference

- Cursor skill layout and conventions: see the create-skill skill (`~/.cursor/skills-cursor/create-skill/SKILL.md` or project equivalent).
- Original full workflow (subagents, eval viewer, benchmark): [anthropics/skills – skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator).

**Summary:** Clarify intent → draft SKILL.md (with clear description and structure) → run 2–3 test prompts → collect feedback → improve skill and repeat. Use evals.json and description tuning only when they help.
