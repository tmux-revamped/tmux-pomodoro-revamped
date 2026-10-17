<div align="center">

# tmux-pomodoro-revamped

<strong>tmux 状态栏中的番茄钟计时器，所有状态都保存在 tmux 选项中，不使用临时文件。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; 简体中文 &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![Tests](https://github.com/tmux-revamped/tmux-pomodoro-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-pomodoro-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">功能</a> &nbsp;|&nbsp;
  <a href="#installation">安装</a> &nbsp;|&nbsp;
  <a href="#usage">用法</a> &nbsp;|&nbsp;
  <a href="#configuration">配置</a> &nbsp;|&nbsp;
  <a href="#key-bindings">按键绑定</a> &nbsp;|&nbsp;
  <a href="#how-it-works">工作原理</a>
</p>

</div>

**工作 25 分钟，短休息 5 分钟，每 4 个工作时段后长休息 15 分钟。0 个临时文件。已在 macOS 和 Linux 上测试。**

---

<a id="what-it-does"></a>

## 功能

计时器在状态栏中倒数工作时段和休息时间，然后重复这个循环。暂停和继续不会损失时间。每次阶段切换时，它可以发送桌面通知、响起终端铃声，并运行你指定的 shell 命令。它还会记录 7 天内完成的工作时段数。

## 环境要求

| 项目 | 版本或说明 |
|:------------|:----------------|
| tmux | 3.2 或更高版本，帮助弹窗需要 |
| bash | 3.2 或更高版本，因此 macOS 自带的 `/bin/bash` 可以使用 |
| 操作系统 | Apple Silicon 和 Intel 上的 macOS，x86_64 和 arm64 上的 Linux |
| 核心工具 | BSD、GNU 或 uutils coreutils |
| `osascript` 或 `notify-send` | 可选，用于 macOS 或 Linux 上的桌面通知 |

<a id="installation"></a>

## 安装

使用 [TPM](https://github.com/tmux-plugins/tpm) 时，把插件和占位符加入 `~/.tmux.conf`，然后按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-pomodoro-revamped'
set -g status-right '#{pomodoro_status} | %H:%M'
```

不使用 TPM 时，克隆仓库，并在 `~/.tmux.conf` 中设置 `status-right` 的那一行之后运行入口脚本：

```sh
git clone https://github.com/tmux-revamped/tmux-pomodoro-revamped ~/.tmux/plugins/tmux-pomodoro-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-pomodoro-revamped/pomodoro-revamped.tmux
```

<a id="usage"></a>

## 用法

按 `prefix + M-s` 启动计时器。再按一次暂停，再按一次继续。

放在 `status-left` 或 `status-right` 中的 `#{pomodoro_status}` 会显示阶段颜色、`MM:SS` 倒计时和 `[interval/total]` 计数器，例如 `23:20 [1/4]`。没有计时器运行时，它不显示任何内容。

每次渲染还会写入以下 tmux 选项，主题或其他插件无需运行脚本即可读取：

| 选项 | 值 |
|:-------|:------|
| `@pomodoro_status` | 渲染出的片段，与 `#{pomodoro_status}` 的文本相同 |
| `@pomodoro_phase` | `work`、`break` 或 `long_break` |
| `@pomodoro_remaining` | 当前阶段剩余的秒数 |
| `@pomodoro_fraction` | 当前阶段已过去的百分比 |
| `@pomodoro_week` | 最近 7 天内按星期统计的工作时段火花线，从星期日开始，用 `_.-=+*%@` 绘制 |
| `@pomodoro_today` | 今天完成的工作时段数 |

同样的操作也可以在 shell 中以 `~/.tmux/plugins/tmux-pomodoro-revamped/src/pomodoro.sh <action>` 运行，action 为 `toggle`、`cancel`、`skip`、`restart`、`menu` 或 `help`。

<a id="configuration"></a>

## 配置

在插件加载之前于 `~/.tmux.conf` 中设置选项。

| 选项 | 默认值 | 含义 |
|:-------|:--------|:--------|
| `@pomodoro_revamped_work` | `25` | 工作分钟数 |
| `@pomodoro_revamped_break` | `5` | 短休息分钟数 |
| `@pomodoro_revamped_long_break` | `15` | 长休息分钟数 |
| `@pomodoro_revamped_intervals` | `4` | 长休息之前的工作时段数 |
| `@pomodoro_revamped_show_interval` | `1` | `0` 隐藏 `[n/N]` 计数器 |
| `@pomodoro_revamped_show_progress` | `0` | `1` 在倒计时前显示进度条 |
| `@pomodoro_revamped_progress_width` | `8` | 进度条宽度，单位为单元格 |
| `@pomodoro_revamped_bar_filled` | `#` | 进度条已填充部分的字符 |
| `@pomodoro_revamped_bar_empty` | `-` | 进度条空白部分的字符 |
| `@pomodoro_revamped_show_finish` | `0` | `1` 在末尾追加 `ends HH:MM` |
| `@pomodoro_revamped_show_goal` | `0` | `1` 在末尾追加今天的 `done/goal` 计数 |
| `@pomodoro_revamped_goal` | `6` | 每天的工作时段目标 |
| `@pomodoro_revamped_pause_text` | ` paused` | 暂停时追加的文本 |
| `@pomodoro_revamped_work_color` | `#[fg=red]` | 工作阶段的样式 |
| `@pomodoro_revamped_break_color` | `#[fg=green]` | 短休息的样式 |
| `@pomodoro_revamped_long_break_color` | `#[fg=blue]` | 长休息的样式 |
| `@pomodoro_revamped_work_icon` | 空 | 工作倒计时之前的文本，例如 Nerd Font 的番茄图标 |
| `@pomodoro_revamped_break_icon` | 空 | 短休息倒计时之前的文本 |
| `@pomodoro_revamped_long_break_icon` | 空 | 长休息倒计时之前的文本 |
| `@pomodoro_revamped_notifications` | `1` | `0` 关闭桌面通知 |
| `@pomodoro_revamped_bell` | `0` | `1` 在阶段切换时让每个已连接的客户端响铃 |
| `@pomodoro_revamped_quiet_hours` | 空 | 例如 `22:00-07:00` 的时间段，在此期间静默通知和铃声 |
| `@pomodoro_revamped_warn_seconds` | `0` | 阶段结束前多少秒提醒一次。`0` 关闭提醒 |
| `@pomodoro_revamped_on_work` | 空 | 工作时段开始时运行的 shell 命令 |
| `@pomodoro_revamped_on_break` | 空 | 短休息开始时运行的 shell 命令 |
| `@pomodoro_revamped_on_long_break` | 空 | 长休息开始时运行的 shell 命令 |
| `@pomodoro_revamped_on_cycle` | 空 | 长休息开始时、在 `on_long_break` 之后运行的 shell 命令 |
| `@pomodoro_revamped_on_warn` | 空 | 阶段结束提醒时运行的 shell 命令 |
| `@pomodoro_revamped_toggle_key` | `M-s` | 启动、暂停和继续的前缀键。`off` 取消绑定 |
| `@pomodoro_revamped_cancel_key` | 空 | 取消计时器的前缀键 |
| `@pomodoro_revamped_skip_key` | 空 | 跳到下一阶段的前缀键 |
| `@pomodoro_revamped_restart_key` | 空 | 重新开始当前阶段的前缀键 |
| `@pomodoro_revamped_menu_key` | 空 | 打开控制菜单的前缀键 |
| `@pomodoro_revamped_help_key` | 空 | 打开帮助弹窗的前缀键 |

### 内部状态

以下选项由插件自行管理，请勿设置。

| 选项 | 内容 |
|:-------|:------|
| `@pomodoro_revamped_state` | 空闲时为空，运行时为 `running`，暂停时为 `paused` |
| `@pomodoro_revamped_start` | 计时器启动时的纪元秒，跳过和重新开始会移动它 |
| `@pomodoro_revamped_paused_at` | 当前暂停开始时的纪元秒，运行时为 `0` |
| `@pomodoro_revamped_paused_total` | 计时器启动以来暂停的秒数 |
| `@pomodoro_revamped_last_phase` | 最近看到的阶段，使阶段切换只触发一次钩子和提醒 |
| `@pomodoro_revamped_transition_claim` | 一个令牌，决定由哪一次并发的状态刷新处理阶段切换 |
| `@pomodoro_revamped_warned` | 当前阶段已发出提醒后为 `1` |
| `@pomodoro_revamped_week_counts` | 每个星期几的工作时段数，从星期日开始的 7 个逗号分隔值 |
| `@pomodoro_revamped_week_day` | 最近一次记录工作时段的日序号，用于重置过期的星期数据 |

<a id="key-bindings"></a>

## 按键绑定

| 按键 | 作用 | 选项 |
|:----|:-------|:-------|
| `prefix + M-s` | 启动、暂停或继续 | `@pomodoro_revamped_toggle_key` |
| 未绑定 | 取消 | `@pomodoro_revamped_cancel_key` |
| 未绑定 | 跳到下一阶段 | `@pomodoro_revamped_skip_key` |
| 未绑定 | 重新开始当前阶段 | `@pomodoro_revamped_restart_key` |
| 未绑定 | 打开控制菜单 | `@pomodoro_revamped_menu_key` |
| 未绑定 | 打开帮助弹窗 | `@pomodoro_revamped_help_key` |

`M-s` 是 tmux-revamped 家族分配给本插件的唯一按键。2.0.0 之前，切换键是 `p`，其他操作绑定在 `P`、`_`、`R`、`o` 和 `?` 上。要恢复某个按键，设置对应的选项：

```tmux
set -g @pomodoro_revamped_menu_key 'o'
```

<a id="how-it-works"></a>

## 工作原理

**一个开始时间。** 计时器保存启动时的纪元秒和暂停的秒数。每次渲染都从当前时间中减去这两者，沿着工作时段、短休息和长休息的循环计算出当前阶段和剩余秒数。跳过会把开始时间向前移动剩余的秒数。重新开始会把它向后移动当前阶段已用去的秒数。

**没有文件。** 所有值都保存在 tmux 服务器选项中，因此不会在 `/tmp` 下写入任何内容，也没有需要清理的东西。每周统计是保存在一个选项中的 7 格环形缓冲。

**渲染。** 入口脚本把 `#{pomodoro_status}` 替换为调用 [`src/pomodoro.sh`](src/pomodoro.sh) 的 `#()`，因此倒计时每个 `status-interval` 前进一次。没有后台进程运行。

**阶段切换。** 每个已连接的客户端都会刷新状态栏，所以多次渲染可能会发现同一次阶段切换。一条条件式 tmux 命令认领这次切换，只有认领成功的渲染会计入工作时段、运行钩子并发送提醒。钩子通过 `run-shell -b` 运行，因此慢命令不会卡住状态栏。

## 开发

| 命令 | 作用 |
|:--------|:-------------|
| `make test` | 运行 bats 测试套件 |
| `make lint` | 对所有 shell 文件运行 shellcheck |
| `make coverage` | 用 kcov 测量行覆盖率，低于 95% 时失败，在 Linux 上运行 |

测试套件需要 `bats-core` 和 tmux。

## 许可证

[MIT](LICENSE)

<!-- family:begin -->

## tmux-revamped 插件家族

本插件是 tmux-revamped 家族的一员。每个成员都带有 [`FAMILY.md`](FAMILY.md) 中的同一份约定、`family/` 下的同一套工具和同一个共享库，并由校验和清单保持逐字节一致。这些插件设计为一起安装：任何成员都不会占用另一个成员已占用的按键或 tmux 选项。

在一个成员中发现的缺陷，要在所有成员中排查之后才算修复完成。这项义务写在约定里，而不是靠记忆，`family/bin/sweep` 就是履行它的工具。

| 成员 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 编辑并保存 tmux 配置后自动重新加载，无需按键或命令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | 在 tmux 状态栏显示电池状态，绝不阻塞状态栏渲染 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 状态栏显示所有已连接的蓝牙设备及其电量，不阻塞渲染 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 状态栏显示 CPU 负载、温度和频率，绝不阻塞渲染 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 状态栏显示磁盘使用量，绝不阻塞状态栏渲染 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 用 fzf 从屏幕上选取 URL、路径、哈希或其他片段并输入到光标处，纯 shell 实现 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在弹出窗口的 fzf 选择器中切换、关闭、重命名或创建 tmux 会话、窗口和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 状态栏显示当前窗格的 git 分支、变更和托管平台计数，不阻塞状态栏 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 状态栏显示 NVIDIA、AMD、Intel 和 Apple GPU 的负载、温度、频率、功耗和显存 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 状态栏显示当前 Kubernetes 上下文和命名空间，直接解析 kubeconfig，无需 kubectl |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 以当前窗格的目录在弹出窗口或新窗口中启动任意 TUI 应用，只需一个可配置的按键 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 将任意窗格保存到文件：实时日志、完整回滚记录或一次性截图 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 状态栏显示正在播放的曲目，绝不阻塞状态栏渲染 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 状态栏显示网络吞吐量，绝不阻塞渲染 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的标准窗格与窗口管理按键绑定，适配各版本，对 vim 友好，可完全配置 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 保存 tmux 的所有会话、窗口和窗格，按定时器自动保存，并在重启后全部恢复 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起点：共享库、bats 测试框架、CI 和家族工具 |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | **本插件**，tmux 状态栏中的番茄钟计时器，所有状态都保存在 tmux 选项中，不使用临时文件 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 状态栏显示内存、交换空间和内存压力，在后台采样，渲染从不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用鼠标在 tmux 状态栏上拖动窗口标签来移动该窗口 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 将鼠标滚轮交给能自行滚动的应用，其他情况下进入 tmux 复制模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 合理的 tmux 默认设置，按 tmux 版本和终端启用，不改动你已设置的选项 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平铺式窗口管理：8 种布局，包括 BSP dwindle 和 spiral，并可撤销布局 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | tmux 状态栏的本地时钟和世界时钟，按时段着色，附带倒计时和夏令时提醒 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在 tmux 状态栏显示来自 wttr.in 的天气，在后台获取，状态栏从不等待 |

### 检查安装

所有成员都在磁盘上时，一条命令即可报告它们之间的任何冲突：

```sh
family/bin/doctor --live
```

它会读取每个成员和正在运行的 tmux 服务器，并报告重复的按键、重复的状态栏占位符、不符合命名规则的选项，以及约定版本落后的成员。

<!-- family:end -->
