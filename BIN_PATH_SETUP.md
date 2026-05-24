# Vibecrafted Bin Path Setup

This repository now ships standalone `bin/vc-*` entrypoints that can be called
from non-interactive shells without sourcing `skills/vc-agents/shell/vetcoders.sh`.

For local development:

```bash
export PATH="/Users/polyversai/Libraxis/vc-runtime/vibecrafted/bin:$PATH"
```

For an installed runtime, `scripts/install-foundations.sh` copies the wrappers
into `${VIBECRAFTED_BIN:-$HOME/.vibecrafted/bin}`. Add that directory to PATH:

```bash
export PATH="${VIBECRAFTED_BIN:-$HOME/.vibecrafted/bin}:$PATH"
```
