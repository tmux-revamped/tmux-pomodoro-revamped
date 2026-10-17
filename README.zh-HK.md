<div align="center">

# tmux-pomodoro-revamped

<strong>tmux 狀態列中的番茄鐘計時器，所有狀態都儲存在 tmux 選項中，不使用暫存檔。</strong>

[English](README.md) | [日本語](README.ja.md) | [简体中文](README.zh-Hans.md) | 繁體中文（香港）

[![Tests](https://github.com/tmux-revamped/tmux-pomodoro-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-pomodoro-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">功能</a> |
  <a href="#installation">安裝</a> |
  <a href="#usage">用法</a> |
  <a href="#configuration">設定</a> |
  <a href="#key-bindings">按鍵綁定</a> |
  <a href="#how-it-works">運作原理</a>
</p>

</div>

**工作 25 分鐘，短休息 5 分鐘，每 4 個工作時段後長休息 15 分鐘。0 個暫存檔。已在 macOS 及 Linux 上測試。**

---

<a id="what-it-does"></a>

## 功能

計時器在狀態列中倒數工作時段及休息時間，然後重複這個循環。暫停及繼續不會損失時間。每次階段轉換時，它可以發出桌面通知、響起終端機鈴聲，並執行你指定的 shell 指令。它亦會記錄 7 天內完成的工作時段數目。

## 系統要求

| 項目 | 版本或說明 |
|:------------|:----------------|
| tmux | 3.2 或以上，說明彈出視窗需要 |
| bash | 3.2 或以上，因此 macOS 內置的 `/bin/bash` 可以使用 |
| 作業系統 | Apple Silicon 及 Intel 上的 macOS，x86_64 及 arm64 上的 Linux |
| 核心工具 | BSD、GNU 或 uutils coreutils |
| `osascript` 或 `notify-send` | 選用，用於 macOS 或 Linux 上的桌面通知 |

<a id="installation"></a>

## 安裝

使用 [TPM](https://github.com/tmux-plugins/tpm) 時，把插件及佔位符加入 `~/.tmux.conf`，然後按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-pomodoro-revamped'
set -g status-right '#{pomodoro_status} | %H:%M'
```

不使用 TPM 時，複製儲存庫，並在 `~/.tmux.conf` 中設定 `status-right` 那一行之後執行入口腳本：

```sh
git clone https://github.com/tmux-revamped/tmux-pomodoro-revamped ~/.tmux/plugins/tmux-pomodoro-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-pomodoro-revamped/pomodoro-revamped.tmux
```

<a id="usage"></a>

## 用法

按 `prefix + M-s` 啟動計時器。再按一次暫停，再按一次繼續。

放在 `status-left` 或 `status-right` 中的 `#{pomodoro_status}` 會顯示階段顏色、`MM:SS` 倒數及 `[interval/total]` 計數器，例如 `23:20 [1/4]`。沒有計時器運行時，它不會顯示任何內容。

每次繪製亦會寫入以下 tmux 選項，主題或其他插件無需執行腳本即可讀取：

| 選項 | 值 |
|:-------|:------|
| `@pomodoro_status` | 繪製出的片段，與 `#{pomodoro_status}` 的文字相同 |
| `@pomodoro_phase` | `work`、`break` 或 `long_break` |
| `@pomodoro_remaining` | 目前階段剩餘的秒數 |
| `@pomodoro_fraction` | 目前階段已過去的百分比 |
| `@pomodoro_week` | 最近 7 天內按星期統計的工作時段走勢線，由星期日開始，用 `_.-=+*%@` 繪製 |
| `@pomodoro_today` | 今天完成的工作時段數目 |

同樣的操作亦可在 shell 中以 `~/.tmux/plugins/tmux-pomodoro-revamped/src/pomodoro.sh <action>` 執行，action 為 `toggle`、`cancel`、`skip`、`restart`、`menu` 或 `help`。

<a id="configuration"></a>

## 設定

在插件載入之前於 `~/.tmux.conf` 中設定選項。

| 選項 | 預設值 | 含義 |
|:-------|:--------|:--------|
| `@pomodoro_revamped_work` | `25` | 工作分鐘數 |
| `@pomodoro_revamped_break` | `5` | 短休息分鐘數 |
| `@pomodoro_revamped_long_break` | `15` | 長休息分鐘數 |
| `@pomodoro_revamped_intervals` | `4` | 長休息之前的工作時段數目 |
| `@pomodoro_revamped_show_interval` | `1` | `0` 隱藏 `[n/N]` 計數器 |
| `@pomodoro_revamped_show_progress` | `0` | `1` 在倒數前顯示進度列 |
| `@pomodoro_revamped_progress_width` | `8` | 進度列寬度，以儲存格計 |
| `@pomodoro_revamped_bar_filled` | `#` | 進度列已填滿部分的字元 |
| `@pomodoro_revamped_bar_empty` | `-` | 進度列空白部分的字元 |
| `@pomodoro_revamped_show_finish` | `0` | `1` 在末尾加上 `ends HH:MM` |
| `@pomodoro_revamped_show_goal` | `0` | `1` 在末尾加上今天的 `done/goal` 計數 |
| `@pomodoro_revamped_goal` | `6` | 每天的工作時段目標 |
| `@pomodoro_revamped_pause_text` | ` paused` | 暫停時加上的文字 |
| `@pomodoro_revamped_work_color` | `#[fg=red]` | 工作階段的樣式 |
| `@pomodoro_revamped_break_color` | `#[fg=green]` | 短休息的樣式 |
| `@pomodoro_revamped_long_break_color` | `#[fg=blue]` | 長休息的樣式 |
| `@pomodoro_revamped_work_icon` | 空 | 工作倒數之前的文字，例如 Nerd Font 的番茄圖示 |
| `@pomodoro_revamped_break_icon` | 空 | 短休息倒數之前的文字 |
| `@pomodoro_revamped_long_break_icon` | 空 | 長休息倒數之前的文字 |
| `@pomodoro_revamped_notifications` | `1` | `0` 關閉桌面通知 |
| `@pomodoro_revamped_bell` | `0` | `1` 在階段轉換時令每個已連接的用戶端響鈴 |
| `@pomodoro_revamped_quiet_hours` | 空 | 例如 `22:00-07:00` 的時段，期間靜音通知及鈴聲 |
| `@pomodoro_revamped_warn_seconds` | `0` | 階段結束前多少秒提示一次。`0` 關閉提示 |
| `@pomodoro_revamped_on_work` | 空 | 工作時段開始時執行的 shell 指令 |
| `@pomodoro_revamped_on_break` | 空 | 短休息開始時執行的 shell 指令 |
| `@pomodoro_revamped_on_long_break` | 空 | 長休息開始時執行的 shell 指令 |
| `@pomodoro_revamped_on_cycle` | 空 | 長休息開始時、在 `on_long_break` 之後執行的 shell 指令 |
| `@pomodoro_revamped_on_warn` | 空 | 階段結束提示時執行的 shell 指令 |
| `@pomodoro_revamped_toggle_key` | `M-s` | 啟動、暫停及繼續的前綴鍵。`off` 取消綁定 |
| `@pomodoro_revamped_cancel_key` | 空 | 取消計時器的前綴鍵 |
| `@pomodoro_revamped_skip_key` | 空 | 跳到下一階段的前綴鍵 |
| `@pomodoro_revamped_restart_key` | 空 | 重新開始目前階段的前綴鍵 |
| `@pomodoro_revamped_menu_key` | 空 | 開啟控制選單的前綴鍵 |
| `@pomodoro_revamped_help_key` | 空 | 開啟說明彈出視窗的前綴鍵 |

### 內部狀態

以下選項由插件自行管理，請勿設定。

| 選項 | 內容 |
|:-------|:------|
| `@pomodoro_revamped_state` | 閒置時為空，運行時為 `running`，暫停時為 `paused` |
| `@pomodoro_revamped_start` | 計時器啟動時的紀元秒，跳過及重新開始會移動它 |
| `@pomodoro_revamped_paused_at` | 目前暫停開始時的紀元秒，運行時為 `0` |
| `@pomodoro_revamped_paused_total` | 計時器啟動以來暫停的秒數 |
| `@pomodoro_revamped_last_phase` | 最近見到的階段，令階段轉換只觸發一次鈎子及提示 |
| `@pomodoro_revamped_transition_claim` | 一個權杖，決定由哪一次並行的狀態更新處理階段轉換 |
| `@pomodoro_revamped_warned` | 目前階段已發出提示後為 `1` |
| `@pomodoro_revamped_week_counts` | 每個星期幾的工作時段數目，由星期日開始的 7 個逗號分隔值 |
| `@pomodoro_revamped_week_day` | 最近一次記錄工作時段的日序號，用於重設過時的星期資料 |

<a id="key-bindings"></a>

## 按鍵綁定

| 按鍵 | 作用 | 選項 |
|:----|:-------|:-------|
| `prefix + M-s` | 啟動、暫停或繼續 | `@pomodoro_revamped_toggle_key` |
| 未綁定 | 取消 | `@pomodoro_revamped_cancel_key` |
| 未綁定 | 跳到下一階段 | `@pomodoro_revamped_skip_key` |
| 未綁定 | 重新開始目前階段 | `@pomodoro_revamped_restart_key` |
| 未綁定 | 開啟控制選單 | `@pomodoro_revamped_menu_key` |
| 未綁定 | 開啟說明彈出視窗 | `@pomodoro_revamped_help_key` |

`M-s` 是 tmux-revamped 家族分配給本插件的唯一按鍵。2.0.0 之前，切換鍵是 `p`，其他操作綁定在 `P`、`_`、`R`、`o` 及 `?` 上。如要恢復某個按鍵，設定對應的選項：

```tmux
set -g @pomodoro_revamped_menu_key 'o'
```

<a id="how-it-works"></a>

## 運作原理

**一個開始時間。** 計時器儲存啟動時的紀元秒及暫停的秒數。每次繪製都從目前時間減去兩者，沿着工作時段、短休息及長休息的循環計算出目前階段及剩餘秒數。跳過會把開始時間向前移動剩餘的秒數。重新開始會把它向後移動目前階段已用去的秒數。

**沒有檔案。** 所有值都儲存在 tmux 伺服器選項中，因此不會在 `/tmp` 下寫入任何東西，亦沒有需要清理的東西。每週統計是儲存在一個選項中的 7 格環形緩衝。

**繪製。** 入口腳本把 `#{pomodoro_status}` 替換為呼叫 [`src/pomodoro.sh`](src/pomodoro.sh) 的 `#()`，因此倒數每個 `status-interval` 前進一次。沒有背景進程運行。

**階段轉換。** 每個已連接的用戶端都會更新狀態列，所以多次繪製可能會察覺同一次階段轉換。一條條件式 tmux 指令認領這次轉換，只有認領成功的繪製會計算工作時段、執行鈎子並發出提示。鈎子透過 `run-shell -b` 執行，因此慢的指令不會卡住狀態列。

## 開發

| 指令 | 作用 |
|:--------|:-------------|
| `make test` | 執行 bats 測試套件 |
| `make lint` | 對所有 shell 檔案執行 shellcheck |
| `make coverage` | 用 kcov 量度行覆蓋率，低於 95% 時失敗，在 Linux 上執行 |

測試套件需要 `bats-core` 及 tmux。

## 授權條款

[MIT](LICENSE)

<!-- family:begin -->

## tmux-revamped 插件家族

本插件是 tmux-revamped 插件家族的成員。每個成員都帶有 [`FAMILY.md`](FAMILY.md) 中的同一份約定、`family/` 下的同一套工具和同一個共用程式庫，並由校驗和清單確保逐位元組一致。這些成員可以一併安裝：任何成員都不會佔用其他成員使用的按鍵或 tmux 選項。

在一個成員中發現的缺陷，要在全部成員中排查後才算修正完成。這項責任寫在約定之中，而不是依靠記憶，`family/bin/sweep` 負責執行。

| 成員 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 編輯並儲存 tmux 設定後，它會自動重新載入，毋須按鍵，也毋須指令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | 在 tmux 狀態列顯示電池狀態，從不阻塞狀態列繪製 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 狀態列顯示每部已連接的藍牙裝置及其電量，不阻塞繪製 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 狀態列顯示 CPU 負載、溫度及頻率，從不阻塞繪製 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 狀態列顯示磁碟用量，從不阻塞狀態列繪製 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 用 fzf 從畫面上揀選 URL、路徑、雜湊值或任何其他字詞，並輸入到游標位置，全部以純 shell 實現 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在彈出視窗的 fzf 選擇器中切換、關閉、重新命名或建立 tmux 工作階段、視窗和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 狀態列顯示當前窗格的 git 分支、改動和託管平台數目，而不會阻塞顯示 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 狀態列顯示 NVIDIA、AMD、Intel 及 Apple GPU 的負載、溫度、時脈、功耗及記憶體 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 狀態列顯示目前的 Kubernetes 上下文及命名空間，毋須 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 在彈出視窗或新視窗中啟動任何 TUI 應用程式，從目前窗格的目錄開始，每個應用程式可設定一個按鍵 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 將任何窗格儲存到檔案：即時記錄、完整捲動緩衝區或一次性截圖 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 狀態列顯示正在播放的歌曲，從不阻塞狀態列的繪製 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 狀態列顯示網絡傳輸量，從不阻塞繪製 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和視窗管理按鍵，配合 tmux 版本，與 vim 相容，每個 prefix 按鍵都可停用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 儲存 tmux 的所有工作階段、視窗及窗格，按計時器自動儲存，並在重新開機後全部還原 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起點：共用程式庫、bats 測試框架、CI 和系列工具 |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | **本插件**，tmux 狀態列中的番茄鐘計時器，所有狀態都儲存在 tmux 選項中，不使用暫存檔 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用滑鼠在 tmux 狀態列上拖動視窗標籤來移動該視窗 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 將滑鼠滾輪交給能自行捲動的應用程式，其他情況下進入 tmux 複製模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和終端機區分的合理預設設定，不會改動你自己設定的選項 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平鋪視窗管理：八種版面，包括 BSP dwindle 和 spiral，並支援復原版面 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 狀態列中的本地時鐘和世界時鐘，按一天中的時段著色，並提供倒數和夏令時間提示 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在背景從 wttr.in 取得天氣並顯示在狀態列，狀態列毋須等待 |

### 檢查安裝

所有成員都在磁碟上時，一個指令即可報告它們之間的任何衝突：

```sh
family/bin/doctor --live
```

它讀取每個成員和正在運行的 tmux 伺服器，報告重複的按鍵、重複的狀態佔位符、不符合命名規則的選項，以及約定版本落後的成員。

<!-- family:end -->
