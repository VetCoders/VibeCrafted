# `vc-audit` Flow

## Flow

```mermaid
flowchart TD
    A[Completed plan or implementation] --> B[Run or consume vc-init]
    B --> C[Build requirements matrix]
    C --> D[Probe repo, tests, docs, and runtime truth]
    D --> E[Classify done, undone, and unverifiable items]
    E --> F[Write audit report with evidence]
```

## Routes

| Entry                       | Args                   | Produces     | Exit                 |
| --------------------------- | ---------------------- | ------------ | -------------------- |
| `vibecrafted audit <agent>` | `--prompt` or `--file` | audit report | P0/P1/P2/P3 findings |
| `vc-audit <agent>`          | same                   | same         | same                 |
