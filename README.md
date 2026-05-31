# Codex Desktop History Restore Skill

中文 | [English](./README.en.md)

让 Codex Desktop 的历史会话更容易续上。

这个 skill 主要解决两类问题：

- 你想立刻继续之前的工作，不想重新解释上下文
- 你想把 Codex 左侧历史、项目归属和原线程恢复正常

## 适合什么场景

这个 skill 特别适合下面几种情况：

- 你在同一台 Mac 上切换不同的 ChatGPT Plus 订阅账号
- 你从订阅模式切到 API 模式，想继续同一个任务
- 旧会话内容其实还在本地，但 Codex 左侧历史不显示了
- 原线程点开后恢复失败，或者只能看到第一条消息

很多人遇到的真实问题不是“数据没了”，而是：

- 会话还在本地
- 但 Codex 没有正确把它恢复到界面里

这个 skill 的作用，就是把“继续工作”和“恢复原线程”分开处理。

## 两种模式

### `handoff`

适合你现在最在乎的是先把工作继续下去。

它会：

- 找到最相关的旧会话
- 提炼出继续工作需要的上下文
- 给新会话一段清晰的继续提示

它不会：

- 修改本地数据库
- 修改 `config.toml`
- 直接把原线程恢复到左侧栏

一句话理解：  
`handoff` 解决的是“先继续干活”。

### `restore`

适合你明确想把 Codex 本地历史修回来。

它会：

- 检查当前 `auth_mode`
- 判断正确的 provider 目标
- 修复 SQLite、rollout、索引和全局状态的一致性
- 尽量把左侧历史、项目根和原线程恢复正常

一句话理解：  
`restore` 解决的是“把原会话修回来”。

## 什么时候用哪一个

- 想马上继续之前的工作：用 `handoff`
- 想把左侧历史和原线程恢复回来：用 `restore`

尤其是下面这两种切换场景，这个 skill 很有用：

- `Plus A -> Plus B`
- `Plus -> API`

其中：

- `handoff` 更稳，适合先保住工作连续性
- `restore` 更重，适合修本地历史系统本身

## 这个 skill 的关键原则

- 先看 `auth.json`，再决定 provider 策略
- `chatgpt` 模式下，活跃线程通常应该回到内置 `openai`
- 不能因为历史上有过 `custom`，就默认把当前活跃线程迁到 `custom`
- `handoff` 默认只读
- `restore` 只做最小必要备份，避免磁盘越占越大
- 修复成功后，应清理已被覆盖的冗余备份

## 安装

安装完成后，Codex 会在本机 skill 目录里建立一个软链接：

```text
~/.codex/skills/codex-desktop-history-restore -> <this-repo>/skill/codex-desktop-history-restore
```

仓库地址：

```text
https://github.com/sunplussign-byte/codex-desktop-history-restore-skill
```

### 方式一：自己在终端安装

1. 克隆仓库

```bash
git clone https://github.com/sunplussign-byte/codex-desktop-history-restore-skill.git
cd codex-desktop-history-restore-skill
```

2. 运行安装脚本

```bash
./install.sh
```

3. 可选：运行校验

```bash
./scripts/verify.sh
```

如果输出：

```text
verify_ok=true
```

说明结构和安装结果都正常。

### 方式二：直接让 Codex 帮你安装

如果你不想自己执行命令，可以把下面这段话直接发给 Codex：

```text
请帮我安装这个 Codex skill：
1. clone 这个 GitHub 仓库到本地
2. 进入仓库目录
3. 运行 ./install.sh
4. 运行 ./scripts/verify.sh
5. 告诉我 ~/.codex/skills/codex-desktop-history-restore 是否已经正确安装
仓库地址是：
https://github.com/sunplussign-byte/codex-desktop-history-restore-skill
不要修改 skill 内容，只做安装和验证。
```

如果仓库已经在本地，可以发这个版本：

```text
请帮我安装这个本地 Codex skill：
1. 进入这个目录
2. 运行 ./install.sh
3. 运行 ./scripts/verify.sh
4. 告诉我 ~/.codex/skills/codex-desktop-history-restore 是否已经正确建立软链接
本地路径是：<your-local-repo-path>
不要修改 skill 内容，只做安装和验证。
```

## 使用方式

安装后，你可以直接对 Codex 说：

```text
请用 codex-desktop-history-restore skill 帮我恢复这条会话。
```

或者：

```text
请用 codex-desktop-history-restore skill，先用 handoff 模式帮我继续之前的工作。
```

或者：

```text
请用 codex-desktop-history-restore skill，用 restore 模式帮我把左侧历史和原线程修回来。
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

真正运行时会被安装的是：

```text
skill/codex-desktop-history-restore/
```

## 校验

运行：

```bash
./scripts/verify.sh
```

它会检查：

- 仓库外层文件是否齐全
- skill 运行时文件是否齐全
- shell 脚本语法是否正确
- 关键 Markdown / YAML 文件是否在正确位置

## License

MIT
