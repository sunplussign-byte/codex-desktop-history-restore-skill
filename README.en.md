# Codex Desktop History Restore Skill

[中文](./README.zh-CN.md) | [English](./README.en.md)

A recovery-oriented skill for Codex Desktop users.

It helps with two common situations:

- you want to keep working immediately without re-explaining everything
- you want Codex sidebar history, project roots, and original-thread resume to work again

Because those are different goals, the skill has two explicit modes:

- `handoff`: continue the work quickly
- `restore`: repair local history state

## Why This Exists

This skill is especially useful for people who:

- use Codex with ChatGPT Plus
- do not want to pay for a more expensive Pro tier
- may rotate between 2 or 3 Plus accounts
- start in subscription mode but want to switch to API mode without losing task continuity

In that setup, you can easily run into problems like:

- a new session cannot see the previous context
- switching from subscription mode to API mode breaks continuity
- local sidebar history appears to disappear after switching accounts
- provider or account changes break native resume

This skill does not magically make multiple accounts share the exact same live chat window.
Instead, it helps you handle the situation in two practical ways:

- use `handoff` when you mainly want to continue the work
- use `restore` when you want the original local history and thread behavior back

This also applies to subscription-to-API switching:

- the skill can be used when you move from a subscription-backed session to an API-backed session
- `handoff` is the safest path there, because it transfers working context without depending on native thread recovery
- `restore` can also work, but only when the recovery flow respects the current `auth_mode` and chooses the correct provider target

## What The Two Modes Do

### `handoff`

Use this when:

- you want to continue the task immediately
- you are fine continuing in a new session
- you do not need the original sidebar thread to come back right away

What it does:

- identifies the most relevant prior session
- extracts the context needed to continue
- gives the next session a clear continuation prompt

What it does not do:

- it does not mutate local SQLite state
- it does not change `config.toml`
- it does not directly restore the old sidebar thread

Short version:
`handoff` solves "how do I keep working?"

### `restore`

Use this when:

- you explicitly want Codex sidebar history repaired
- you want the original thread, project root, and local history behavior back
- you accept a more careful repair flow that may require restarting Codex

What it does:

- checks `auth_mode`
- chooses the correct provider target
- repairs consistency across SQLite, rollout metadata, index, and global UI state
- tries to restore normal sidebar and original-thread behavior

Short version:
`restore` solves "how do I repair Codex local history?"

## When To Use Which

- If you need to keep working now, use `handoff`
- If you need the original sidebar history and thread back, use `restore`

These goals are related, but they are not the same operation. Many broken recovery attempts happen because they get mixed together.

## Key Principles

- Read `auth.json` before choosing any provider strategy
- In `chatgpt` mode, active threads should normally end up on built-in `openai`
- Do not migrate active threads to `custom` just because a historical custom provider existed
- Keep `handoff` read-only by default
- Keep `restore` conservative and verifiable
- Use minimal backups by default so local disk usage does not grow unnecessarily
- Clean up superseded backups after a successful repair

## Installation

Simple mental model: after installation, this repository is linked into your local Codex skill directory.

The end result looks like:

```text
~/.codex/skills/codex-desktop-history-restore -> <this-repo>/skill/codex-desktop-history-restore
```

### Option 1: Install from the terminal yourself

1. Clone the repository

```bash
git clone <your-repo-url>
cd codex-desktop-history-restore-skill
```

2. Run the install script

```bash
./install.sh
```

3. Optional: verify the repository structure

```bash
./scripts/verify.sh
```

If you see:

```text
verify_ok=true
```

the repository structure is valid.

### Option 2: Ask Codex to install it for you

If you do not want to run the commands yourself, you can ask Codex to do it.

But Codex still needs to know where the repository is. So you must provide either:

- a GitHub repository URL
- or a local path where the repository already exists

Version A: provide a GitHub repository URL

You can paste this into Codex:

```text
Please help me install this Codex skill:
1. clone this GitHub repository locally
2. enter the repository directory
3. run ./install.sh
4. run ./scripts/verify.sh
5. tell me whether the skill is correctly installed at ~/.codex/skills/codex-desktop-history-restore
Repository URL: <your-repo-url>
```

Version B: the repository already exists locally

```text
Please help me install this local Codex skill:
1. enter this directory
2. run ./install.sh
3. run ./scripts/verify.sh
4. tell me whether ~/.codex/skills/codex-desktop-history-restore is correctly linked
Local path: <your-local-repo-path>
Do not modify the skill contents. Only install and validate it.
```

If you want a safer version:

```text
Please first inspect this skill repository in read-only mode, then help me install it.
Steps:
1. clone the repository
2. run ./install.sh
3. run ./scripts/verify.sh
4. tell me whether the symlink was created successfully
Do not modify the skill contents. Only install and validate it.
Repository URL: <your-repo-url>
```

## Repository Layout

```text
.
├── README.md
├── README.zh-CN.md
├── README.en.md
├── CHANGELOG.md
├── LICENSE
├── VERSION
├── install.sh
├── scripts/
│   └── verify.sh
└── skill/
    └── codex-desktop-history-restore/
        ├── SKILL.md
        ├── agents/openai.yaml
        └── references/operator-playbook.md
```

The runtime skill is:

```text
skill/codex-desktop-history-restore/
```

The outer files exist to make the project easier to:

- publish on GitHub
- install for other users
- version and maintain
- validate quickly
- reuse in public writeups

## Validation

Run:

```bash
./scripts/verify.sh
```

The script currently checks:

- required top-level repo files exist
- required runtime skill files exist
- shell scripts are syntactically valid
- key Markdown and YAML files are in the expected locations

## License

MIT
