# Codex Desktop History Restore Skill

中文 | [English](./README.en.md)

一个给 Codex Desktop 用户准备的恢复型 skill。

它解决两类很常见的问题：

- 我只是想马上继续之前的工作，不想从头再解释一遍上下文
- 我想把 Codex 左侧历史、项目归属、原线程恢复正常

所以这个 skill 提供两种明确模式：

- `handoff`：快速续工
- `restore`：修复本地历史状态

## 背景

这个 skill 特别适合下面这类用户：

- 你是 Codex 的订阅用户
- 你用的是 ChatGPT Plus
- 你不想直接升级到更贵的 Pro
- 你可能会准备 2 到 3 个 Plus 账号，轮换使用
- 你原来用订阅模式工作，但想临时切到 API 模式继续同一个任务

这时候最容易遇到的问题是：

- 切到另一个订阅号之后，新会话看不到旧上下文
- 从订阅模式切到 API 模式之后，新会话接不上旧任务
- 原来的左侧历史会话像是消失了
- 账号切换、provider 切换之后，原线程恢复失败

这个 skill 的作用不是“神奇地让所有账号天然共享同一个聊天窗口”，而是帮你把这件事拆开来处理：

- 如果你只想继续工作，用 `handoff`
- 如果你想把左侧原历史和原线程修回来，用 `restore`

这里也说明一下这个场景的适用性：

- 从订阅账号切到 API 模式，这个 skill 也是能用的
- `handoff` 最稳，因为它是把上下文交给新会话继续，不依赖原线程必须立即原样恢复
- `restore` 也能处理，但前提是修复流程必须先识别当前 `auth_mode`，再决定正确的 provider 目标

## 这两个模式分别做什么

### `handoff`

适合：

- 你现在最在乎的是不要中断工作
- 你愿意在一个新会话里继续
- 你不要求左侧原线程立刻恢复

它会做的事：

- 找到最相关的旧会话
- 提炼出继续工作需要的上下文
- 给新会话一段清晰的继续提示

它不会做的事：

- 不会改本地 SQLite
- 不会改 `config.toml`
- 不会直接把原线程变回左侧可点开的状态

一句话理解：
`handoff` 解决的是“工作怎么继续”。

### `restore`

适合：

- 你明确想把 Codex 左侧历史修回来
- 你想恢复原线程、项目归属、侧边栏显示
- 你接受一个更谨慎、可能需要重启 Codex 的修复流程

它会做的事：

- 检查 `auth_mode`
- 判断正确的 provider 目标
- 修复 SQLite、rollout、索引和全局状态之间的一致性
- 让左侧历史和原线程尽量回到正常状态

一句话理解：
`restore` 解决的是“Codex 本地历史系统怎么修好”。

## 什么时候该用哪一个

- 你现在就要继续干活：用 `handoff`
- 你要把左侧历史和原线程修回来：用 `restore`

这两个目标相关，但不是同一个操作。很多恢复失败，恰恰是因为把“继续工作”和“恢复原线程”混在一起做了。

## 这个 skill 的几个关键原则

- 先看 `auth.json`，再决定 provider 策略
- `chatgpt` 模式下，活跃线程通常应该回到内置 `openai`
- 不能因为历史上有过 `custom`，就默认把当前活跃线程迁到 `custom`
- `handoff` 默认保持只读
- `restore` 默认只做最小必要备份，避免把磁盘越占越大
- 修复成功后，应该清理已经被覆盖的冗余备份

## 安装方式

给小白最简单的理解：安装完成后，这个仓库会被链接到你本机的 Codex skill 目录里。

最终效果是：

```text
~/.codex/skills/codex-desktop-history-restore -> <this-repo>/skill/codex-desktop-history-restore
```

### 方式一：自己在终端安装

1. 克隆仓库

```bash
git clone <your-repo-url>
cd codex-desktop-history-restore-skill
```

2. 执行安装脚本

```bash
./install.sh
```

3. 可选：跑一次校验

```bash
./scripts/verify.sh
```

如果输出：

```text
verify_ok=true
```

说明仓库结构是完整的。

### 方式二：直接发提示词给 Codex，让它帮你安装

如果你不想自己敲命令，也可以让 Codex 帮你安装。

但要注意：你必须告诉 Codex 仓库在哪里，否则它不知道要装哪个 skill。

你可以给它两种信息：

- GitHub 仓库 URL
- 或者你已经 clone 到本地的仓库路径

版本 A：你提供 GitHub 仓库 URL

如果你不想自己敲命令，可以把下面这段话直接发给 Codex：

```text
请帮我安装这个 Codex skill：
1. clone 这个 GitHub 仓库到本地
2. 进入仓库目录
3. 运行 ./install.sh
4. 再运行 ./scripts/verify.sh
5. 最后告诉我 skill 是否已经正确安装到 ~/.codex/skills/codex-desktop-history-restore
仓库地址是：<your-repo-url>
```

版本 B：仓库已经在本地

```text
请帮我安装这个本地 Codex skill：
1. 进入这个目录
2. 运行 ./install.sh
3. 运行 ./scripts/verify.sh
4. 告诉我 ~/.codex/skills/codex-desktop-history-restore 是否已经正确建立软链接
本地路径是：<your-local-repo-path>
不要修改 skill 内容，只做安装和验证。
```

如果你还想更保险一点，可以发这个版本：

```text
请你先只读检查这个 skill 仓库的结构，再帮我安装。
安装步骤：
1. clone 仓库
2. 运行 ./install.sh
3. 运行 ./scripts/verify.sh
4. 告诉我最终软链接是否已经建立成功
不要改这个 skill 的内容，只做安装和验证。
仓库地址：<your-repo-url>
```

## 仓库结构

```text
.
├── README.md
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

真正运行时会安装的是：

```text
skill/codex-desktop-history-restore/
```

外层这些文件是为了方便：

- 放 GitHub
- 给别人安装
- 做版本管理
- 做基础校验
- 方便后续写分享文章

## 校验

运行：

```bash
./scripts/verify.sh
```

这个脚本目前会检查：

- 仓库外层文件是否齐全
- skill 运行时文件是否齐全
- shell 脚本语法是否正确
- 关键 Markdown / YAML 文件是否在正确位置

## License

MIT
