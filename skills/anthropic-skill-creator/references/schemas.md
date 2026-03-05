# Evals schema (optional)

Used when recording test cases in `evals/evals.json`. Full schemas (grading, benchmark, etc.) are in the [Anthropic skill-creator references](https://github.com/anthropics/skills/tree/main/skills/skill-creator/references).

## evals.json

```json
{
  "skill_name": "example-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "User's example prompt",
      "expected_output": "Description of expected result",
      "files": [],
      "expectations": [
        "The output includes X",
        "The skill used script Y"
      ]
    }
  ]
}
```

- **skill_name**: Matches the skill's frontmatter `name`
- **evals[].id**: Unique integer
- **evals[].prompt**: Task to execute
- **evals[].expected_output**: Human-readable success description
- **evals[].files**: Optional input file paths (relative to skill root)
- **evals[].expectations**: Optional list of verifiable statements (for your own checklist; Cursor doesn't auto-grade)
