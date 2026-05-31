# Operator Playbook

This note exists to keep the skill operationally sharp and easy to share.

## Two Modes

- `handoff`: continue the work in a new session without repairing Codex UI state
- `restore`: repair Codex local history, sidebar entries, project roots, and original-thread resume

## Decision Shortcut

Use `handoff` when:

- the user is blocked right now and wants the fastest continuation path
- the user does not care whether the original left-sidebar thread comes back immediately
- provider/account switching makes native resume unreliable

Use `restore` when:

- the user explicitly wants the original thread back
- the left sidebar itself is part of the problem to be solved
- project roots, thread rendering, or session indexing are broken

## Backup Matrix

- `handoff`: no backup by default, because the workflow is read-only
- `restore` minimal backup:
  - `config.toml`
  - `auth.json`
  - `state_5.sqlite*`
  - `session_index.jsonl*`
  - `.codex-global-state.json*`
  - only rollout files that will be edited
- `restore` full backup only if:
  - frontend storage must be edited
  - affected rollout files cannot be isolated
  - a smaller repair already failed

## Provider Rule

- `auth_mode = chatgpt` -> active threads should normally end up on built-in `openai`
- `auth_mode = apikey` -> a custom provider is allowed only when it is actually valid in `config.toml`
- never migrate active threads to `custom` by default just because a historical custom config exists

## Completion Rule

`handoff` is done when:

- the right thread is selected
- the continuation context is readable
- the next session can continue without re-discovery

`restore` is done when:

- active thread provider distribution is correct
- rollout `session_meta.payload.model_provider` is consistent
- `session_index.jsonl` matches active thread count
- the target thread reappears and opens correctly after a full restart

## Publish Notes

When sharing this skill publicly:

- present it as a dual-mode recovery skill, not just a database repair trick
- emphasize that `handoff` preserves workflow continuity
- emphasize that `restore` repairs product state and should be more conservative
- mention that backup strategy is intentionally minimal by default to avoid wasting disk space
