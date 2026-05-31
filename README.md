# Codex Desktop History Restore Skill

[中文](./README.zh-CN.md) | [English](./README.en.md)

`codex-desktop-history-restore` is a dual-mode Codex skill for session continuity and local-history recovery.

Choose your language:

- [阅读中文版 README](./README.zh-CN.md)
- [Read the English README](./README.en.md)

## Quick Summary

This project helps with two different goals:

- `handoff`: continue the work quickly in a new session
- `restore`: repair Codex local history, sidebar threads, and original-thread resume

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

## Install

```bash
git clone <your-repo-url>
cd codex-desktop-history-restore-skill
./install.sh
```

## Validate

```bash
./scripts/verify.sh
```

## License

MIT
