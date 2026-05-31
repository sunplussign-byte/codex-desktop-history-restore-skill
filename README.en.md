# Codex Desktop History Restore Skill

[中文](./README.md) | English

Make Codex Desktop history easier to continue and easier to recover.

This skill focuses on two practical problems:

- you want to continue a previous task without re-explaining the whole context
- you want Codex sidebar history, project roots, and the original thread to work again

## Where It Helps

This skill is especially useful when:

- you switch between multiple ChatGPT Plus accounts on the same Mac
- you move from subscription mode to API mode and want to continue the same task
- the old conversation is still on disk but no longer appears in the Codex sidebar
- opening the original thread fails, or only the first message renders

In many real cases, the data is not actually gone.
The local state still exists, but Codex no longer restores it correctly in the UI.

This skill separates two goals that are often mixed together:

- continuing the work
- restoring the original thread

## Two Modes

### `handoff`

Use this when your first priority is to keep the work moving.

It will:

- find the most relevant prior session
- extract the context needed to continue
- prepare a clear continuation prompt for the next session

It will not:

- modify local databases
- change `config.toml`
- directly restore the old sidebar thread

Short version:  
`handoff` is for continuing the work.

### `restore`

Use this when you explicitly want Codex local history repaired.

It will:

- inspect the current `auth_mode`
- choose the correct provider target
- repair consistency across SQLite, rollout metadata, indexes, and global state
- try to restore sidebar history, project roots, and the original thread

Short version:  
`restore` is for repairing the original local thread state.

## Which One Should You Use?

- If you want to keep working right now, use `handoff`
- If you want the original sidebar history and thread back, use `restore`

This is especially helpful in switching flows like:

- `Plus A -> Plus B`
- `Plus -> API`

In practice:

- `handoff` is usually the safer path for continuity
- `restore` is the heavier path for repairing the local history system itself

## Core Principles

- read `auth.json` before deciding any provider strategy
- in `chatgpt` mode, active threads should normally return to built-in `openai`
- do not migrate active threads to `custom` just because a historical custom provider existed
- keep `handoff` read-only by default
- keep `restore` limited to minimal necessary backups
- clean up superseded backups after a successful repair

## Installation

After installation, Codex will have a symlink like this on your machine:

```text
~/.codex/skills/codex-desktop-history-restore -> <this-repo>/skill/codex-desktop-history-restore
```

Repository:

```text
https://github.com/sunplussign-byte/codex-desktop-history-restore-skill
```

### Option 1: Install from the terminal

1. Clone the repository

```bash
git clone https://github.com/sunplussign-byte/codex-desktop-history-restore-skill.git
cd codex-desktop-history-restore-skill
```

2. Run the install script

```bash
./install.sh
```

3. Optional: run verification

```bash
./scripts/verify.sh
```

If you see:

```text
verify_ok=true
```

the structure and installation are valid.

### Option 2: Ask Codex to install it for you

If you do not want to run the commands yourself, paste this into Codex:

```text
Please help me install this Codex skill:
1. clone this GitHub repository locally
2. enter the repository directory
3. run ./install.sh
4. run ./scripts/verify.sh
5. tell me whether ~/.codex/skills/codex-desktop-history-restore is installed correctly
Repository URL:
https://github.com/sunplussign-byte/codex-desktop-history-restore-skill
Do not modify the skill contents. Only install and validate it.
```

If the repository already exists locally, use this version:

```text
Please help me install this local Codex skill:
1. enter this directory
2. run ./install.sh
3. run ./scripts/verify.sh
4. tell me whether ~/.codex/skills/codex-desktop-history-restore is correctly symlinked
Local path: <your-local-repo-path>
Do not modify the skill contents. Only install and validate it.
```

## Usage

After installation, you can say:

```text
Please use the codex-desktop-history-restore skill to help me recover this conversation.
```

Or:

```text
Please use the codex-desktop-history-restore skill in handoff mode so I can continue the previous work.
```

Or:

```text
Please use the codex-desktop-history-restore skill in restore mode so the sidebar history and original thread come back.
```

## Repository Layout

```text
.
├── README.md
├── README.en.md
├── CHANGELOG.md
├── LICENSE
├── VERSION
├── install.sh
├── releases/
│   └── v0.1.0.md
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

## Validation

Run:

```bash
./scripts/verify.sh
```

It checks:

- required top-level repository files
- required runtime skill files
- shell script syntax
- key Markdown and YAML files in the expected locations

## License

MIT
