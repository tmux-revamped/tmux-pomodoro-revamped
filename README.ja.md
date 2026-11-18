<div align="center">

# tmux-pomodoro-revamped

<strong>すべての状態をtmuxオプションに保持し、一時ファイルを使わない、tmuxステータスバーのポモドーロタイマーです。</strong>

[English](README.md) &nbsp;|&nbsp; 日本語 &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-pomodoro-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-pomodoro-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-pomodoro-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-pomodoro-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-pomodoro-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-pomodoro-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-pomodoro-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#クイックスタート"><strong>クイックスタート</strong></a> &nbsp;|&nbsp;
  <a href="#使い方">使い方</a> &nbsp;|&nbsp;
  <a href="#仕組み">仕組み</a> &nbsp;|&nbsp;
  <a href="#画面">画面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="ステータスラインでタイマーを始め、一時停止し、メニューから休憩に進み、進捗バーを表示する pomodoro-revamped" width="800">
</p>

```console
$ pomodoro-revamped toggle
$ pomodoro-revamped --show-progress 1 status
#[fg=red]-------- 25:00 [1/4]#[default]
```

タイマーは作業時間と休憩をステータスバーでカウントダウンし、そのサイクルを繰り返します。一時停止と再開をしても時間がずれません。フェーズが変わるたびに、デスクトップ通知を送り、端末のベルを鳴らし、好きなシェルコマンドを実行できます。終えた作業の回数を7日分記録します。

---

## クイックスタート

### 前提条件

| ツール | バージョン | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 以降 | ファミリー共通の最低バージョン。ヘルプのポップアップにも必要です |
| `osascript` または `notify-send` | 任意 | macOS や Linux のデスクトップ通知 |
| `less` | 任意 | ヘルプのキーがヘルプをこの中に表示します。ない場合はポップアップにヘルプ全体を表示し、Enter で閉じます |
| gum | 任意 | `pomodoro-revamped` のメニュー、表、色。なくてもすべてのコマンドがプレーンテキストで動きます |

### インストール

[TPM](https://github.com/tmux-plugins/tpm)を使う場合は、`~/.tmux.conf`にプラグインとプレースホルダーを追加して`prefix + I`を押します。

```tmux
set -g @plugin 'tmux-revamped/tmux-pomodoro-revamped'
set -g status-right '#{pomodoro_status} | %H:%M'
```

TPMを使わない場合は、リポジトリをクローンし、`~/.tmux.conf`の`status-right`を設定する行より後でエントリーポイントを実行します。

```sh
git clone https://github.com/tmux-revamped/tmux-pomodoro-revamped ~/.tmux/plugins/tmux-pomodoro-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-pomodoro-revamped/pomodoro-revamped.tmux
```

クローンで `make install` を実行すると、`pomodoro-revamped` が `~/.local/bin` に、manページと補完が `~/.local/share` の下に入ります。

### 確認

```bash
~/.tmux/plugins/tmux-pomodoro-revamped/bin/pomodoro-revamped doctor
```

## 使い方

`prefix + M-s`でタイマーを開始します。もう一度押すと一時停止し、さらに押すと再開します。

`status-left`または`status-right`に置いた`#{pomodoro_status}`は、フェーズの色、`MM:SS`のカウントダウン、`[interval/total]`のカウンターを表示します。たとえば`23:20 [1/4]`です。タイマーが動いていない間は何も表示しません。

描画のたびに以下のtmuxオプションも書き込むので、テーマや他のプラグインはスクリプトを実行せずに読めます。

| オプション | 値 |
|:-------|:------|
| `@pomodoro_revamped_status` | 描画したセグメントで、`#{pomodoro_status}`と同じテキストです |
| `@pomodoro_revamped_phase` | `work`、`break`、`long_break`のいずれかです |
| `@pomodoro_revamped_remaining` | フェーズの残り秒数です |
| `@pomodoro_revamped_fraction` | フェーズの経過率をパーセントで示します |
| `@pomodoro_revamped_week` | 直近7日間の曜日ごとの作業回数を日曜日から並べたスパークラインで、`_.-=+*%@`で描きます |
| `@pomodoro_revamped_today` | 今日終えた作業の回数です |

| コマンド | 動作 |
|:--------|:-------------|
| `pomodoro-revamped apply` | キーを割り当て、プレースホルダーを今すぐ置き換えます。プラグインの読み込み時にエントリーポイントが実行します |
| `pomodoro-revamped list` | `apply` が送るコマンドをすべて表示し、何も変更しません。`--json` で 1 つのオブジェクトを出力します |
| `pomodoro-revamped toggle` | タイマーを開始、一時停止、再開します |
| `pomodoro-revamped skip` | 次のフェーズに進みます |
| `pomodoro-revamped restart` | 現在のフェーズを最初からやり直します |
| `pomodoro-revamped cancel` | タイマーを止めて消去します |
| `pomodoro-revamped status` | ステータスの表示を出力します。ステータスラインが実行します |
| `pomodoro-revamped doctor` | 依存関係ごとに 1 行。通知の手段、`less`、触れなかったキーも含みます |
| `pomodoro-revamped version` | バージョンと tmux のバージョン |
| `pomodoro-revamped help` | ヘルプ。`man pomodoro-revamped` にも同じコマンドと設定があります |
| `pomodoro-revamped` | 端末ではメニュー |

## 設定

オプションはプラグインを読み込む前に`~/.tmux.conf`で設定します。

| オプション | 既定値 | 意味 |
|:-------|:--------|:--------|
| `@pomodoro_revamped_work` | `25` | 作業時間、分単位です |
| `@pomodoro_revamped_break` | `5` | 短い休憩、分単位です |
| `@pomodoro_revamped_long_break` | `15` | 長い休憩、分単位です |
| `@pomodoro_revamped_intervals` | `4` | 長い休憩までの作業回数です |
| `@pomodoro_revamped_show_interval` | `1` | `0`で`[n/N]`のカウンターを隠します |
| `@pomodoro_revamped_show_progress` | `0` | `1`でカウントダウンの前に進捗バーを表示します |
| `@pomodoro_revamped_progress_width` | `8` | 進捗バーの幅、セル数です |
| `@pomodoro_revamped_bar_filled` | `#` | 進捗バーの埋まった部分の文字です |
| `@pomodoro_revamped_bar_empty` | `-` | 進捗バーの空の部分の文字です |
| `@pomodoro_revamped_show_finish` | `0` | `1`で`ends HH:MM`を末尾に付けます |
| `@pomodoro_revamped_show_goal` | `0` | `1`で今日の`done/goal`カウンターを末尾に付けます |
| `@pomodoro_revamped_goal` | `6` | 1日の作業回数の目標です |
| `@pomodoro_revamped_pause_text` | ` paused` | 一時停止中に末尾に付けるテキストです |
| `@pomodoro_revamped_work_color` | `#[fg=red]` | 作業フェーズのスタイルです |
| `@pomodoro_revamped_break_color` | `#[fg=green]` | 短い休憩のスタイルです |
| `@pomodoro_revamped_long_break_color` | `#[fg=blue]` | 長い休憩のスタイルです |
| `@pomodoro_revamped_work_icon` | 空 | 作業のカウントダウンの前に置くテキストで、Nerd Fontのトマトなどです |
| `@pomodoro_revamped_break_icon` | 空 | 短い休憩のカウントダウンの前に置くテキストです |
| `@pomodoro_revamped_long_break_icon` | 空 | 長い休憩のカウントダウンの前に置くテキストです |
| `@pomodoro_revamped_notify` | `0` | `1`でフェーズの切り替えと残り1分の警告ごとにデスクトップ通知を送ります。 |
| `@pomodoro_revamped_bell` | `0` | `1`でフェーズが変わったとき、接続中のすべてのクライアントでベルを鳴らします |
| `@pomodoro_revamped_quiet_hours` | 空 | `22:00-07:00`のような時間帯で、その間は通知とベルを止めます |
| `@pomodoro_revamped_warn_seconds` | `0` | フェーズ終了の何秒前に1回警告するかです。`0`で警告を止めます |
| `@pomodoro_revamped_on_work` | 空 | 作業が始まるときに実行するシェルコマンドです |
| `@pomodoro_revamped_on_break` | 空 | 短い休憩が始まるときに実行するシェルコマンドです |
| `@pomodoro_revamped_on_long_break` | 空 | 長い休憩が始まるときに実行するシェルコマンドです |
| `@pomodoro_revamped_on_cycle` | 空 | 長い休憩が始まるときに、`on_long_break`の後で実行するシェルコマンドです |
| `@pomodoro_revamped_on_warn` | 空 | フェーズ終了の警告で実行するシェルコマンドです |
| `@pomodoro_revamped_toggle_key` | `M-s` | 開始、一時停止、再開を行うプレフィックスキーです。`off`で割り当てを外します |
| `@pomodoro_revamped_cancel_key` | 空 | タイマーを取り消すプレフィックスキーです |
| `@pomodoro_revamped_skip_key` | 空 | 次のフェーズへ進むプレフィックスキーです |
| `@pomodoro_revamped_restart_key` | 空 | 現在のフェーズをやり直すプレフィックスキーです |
| `@pomodoro_revamped_menu_key` | 空 | 操作メニューを開くプレフィックスキーです |
| `@pomodoro_revamped_help_key` | 空 | ヘルプのポップアップを開くプレフィックスキーです |

どのオプションも、ダッシュ区切りのコマンドオプション（例 `--work 50`）と環境変数（例 `POMODORO_REVAMPED_WORK`）で指定できます。優先順位はコマンドライン、環境変数、tmux オプションの順です。空の tmux オプションは既定値を意味します。`apply` に渡したものは、すべての割り当てとステータスの呼び出しに引き継がれます。

### 内部状態

以下のオプションはプラグインが自分で管理します。設定しないでください。

| オプション | 内容 |
|:-------|:------|
| `@pomodoro_revamped_state` | 停止中は空で、動作中は`running`、一時停止中は`paused`です |
| `@pomodoro_revamped_start` | タイマーを開始したエポック秒で、スキップとやり直しで動きます |
| `@pomodoro_revamped_paused_at` | 現在の一時停止が始まったエポック秒で、動作中は`0`です |
| `@pomodoro_revamped_paused_total` | タイマー開始後に一時停止していた秒数です |
| `@pomodoro_revamped_last_phase` | 最後に見たフェーズで、フェーズの変化でフックと通知を1回だけ実行するために使います |
| `@pomodoro_revamped_transition_claim` | 同時に走るステータス更新のうち、どれがフェーズの変化を処理するかを決めるトークンです |
| `@pomodoro_revamped_warned` | 現在のフェーズで警告を出すと`1`になります |
| `@pomodoro_revamped_week_counts` | 曜日ごとの作業回数で、日曜日から始まるカンマ区切りの7つの値です |
| `@pomodoro_revamped_week_day` | 最後に作業を記録した日の番号で、古い曜日をリセットするために使います |

## キーバインド

| キー | 動作 | オプション |
|:----|:-------|:-------|
| `prefix + M-s` | 開始、一時停止、再開 | `@pomodoro_revamped_toggle_key` |
| 未割り当て | 取り消し | `@pomodoro_revamped_cancel_key` |
| 未割り当て | 次のフェーズへ進む | `@pomodoro_revamped_skip_key` |
| 未割り当て | 現在のフェーズをやり直す | `@pomodoro_revamped_restart_key` |
| 未割り当て | 操作メニューを開く | `@pomodoro_revamped_menu_key` |
| 未割り当て | ヘルプのポップアップを開く | `@pomodoro_revamped_help_key` |

`M-s`は、tmux-revampedファミリーがこのプラグインに割り当てた唯一のキーです。他のキーは、オプションを設定するまで割り当てられません。既定のキーを他の誰かが使っている場合はそのままにし、`doctor`が知らせます。

```tmux
set -g @pomodoro_revamped_menu_key 'o'
```

<a id="仕組み"></a>

## 仕組み

**1つの開始時刻。** タイマーは開始したエポック秒と、一時停止していた秒数を保存します。描画のたびに現在時刻から両方を引き、作業、短い休憩、長い休憩のサイクルをたどって、現在のフェーズと残り秒数を求めます。スキップは開始時刻を残り秒数だけ前へずらします。やり直しは、そのフェーズですでに使った秒数だけ後ろへずらします。

**ファイルなし。** すべての値はtmuxサーバーのオプションにあるので、`/tmp`には何も書かず、片付けるものも残りません。週ごとの集計は、オプションに入れた7枠のリングです。

**描画。** エントリーポイントは`#{pomodoro_status}`を[`bin/pomodoro-revamped`](bin/pomodoro-revamped)を呼ぶ`#()`に置き換えるので、カウントダウンは`status-interval`ごとに進みます。バックグラウンドのプロセスは動きません。

**フェーズの変化。** 接続中のクライアントはそれぞれステータス行を更新するため、複数の描画が同じフェーズの変化に気づくことがあります。1つの条件付きtmuxコマンドがその変化を確保し、確保した描画だけが作業回数を数え、フックを実行し、通知を送ります。フックは`run-shell -b`で実行するので、遅いコマンドがステータス行を止めることはありません。

<a id="画面"></a>

## 画面

<details>
<summary>すべての画面。本物の tmux の中で <code>make screens</code> で録画し、押したキーをステータスラインに表示しています</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/running.png" alt="pomodoro-revamped: prefix M-s でタイマーを開始する"><br><sub><code>prefix M-s</code> でタイマーを開始する。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/paused.png" alt="pomodoro-revamped: prefix M-s で一時停止する"><br><sub><code>prefix M-s</code> で一時停止する。<code>hero.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/timer-menu.png" alt="pomodoro-revamped: メニューのキー prefix M-p でタイマーのメニューを開く"><br><sub>メニューのキー <code>prefix M-p</code> でタイマーのメニューを開く。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/break.png" alt="pomodoro-revamped: メニューの Skip phase で休憩が始まる"><br><sub>メニューの Skip phase で休憩が始まる。<code>hero.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/progress.png" alt="pomodoro-revamped: 進捗バー、今日の回数と目標、終了時刻"><br><sub>進捗バー、今日の回数と目標、終了時刻。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/restarted.png" alt="pomodoro-revamped: やり直しのキー prefix M-r でフェーズを最初から始める"><br><sub>やり直しのキー <code>prefix M-r</code> でフェーズを最初から始める。<code>hero.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/help-popup.png" alt="pomodoro-revamped: ヘルプのキー prefix M-o でヘルプを開く"><br><sub>ヘルプのキー <code>prefix M-o</code> でヘルプを開く。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/skipped.png" alt="pomodoro-revamped: スキップのキー prefix M-k で次のフェーズに進む"><br><sub>スキップのキー <code>prefix M-k</code> で次のフェーズに進む。<code>hero.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/cancelled.png" alt="pomodoro-revamped: キャンセルのキー prefix M-c でタイマーを消す"><br><sub>キャンセルのキー <code>prefix M-c</code> でタイマーを消す。<code>hero.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="pomodoro-revamped: list がすべての割り当てを表示する"><br><sub><code>list</code> がすべての割り当てを表示する。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/status.png" alt="pomodoro-revamped: status が表示を出力する"><br><sub><code>status</code> が表示を出力する。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="pomodoro-revamped: doctor"><br><sub><code>doctor</code>。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="pomodoro-revamped: gum なしのメニュー"><br><sub>gum なしのメニュー。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/plain-doctor.png" alt="pomodoro-revamped: メニューからの doctor"><br><sub>メニューからの <code>doctor</code>。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="pomodoro-revamped: バージョン"><br><sub>バージョン。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="pomodoro-revamped: 不明なコマンド"><br><sub>不明なコマンド。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="pomodoro-revamped: 6 つのテーマのヘッダー"><br><sub>6 つのテーマのヘッダー。<code>themes.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="pomodoro-revamped: ヘルプ"><br><sub>ヘルプ。<code>help.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="pomodoro-revamped: POMODORO_REVAMPED_ACCENT によるアクセント"><br><sub><code>POMODORO_REVAMPED_ACCENT</code> によるアクセント。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## 移植性

プラグインは POSIX `sh` です。CI は下の各行ですべてのテストを実行します。

| シェル | 状態 |
|:------|:-------|
| `dash`、macOS の `/bin/sh` | 対応 |
| `bash` 3.2 と 5.x、システムの `zsh` と Homebrew の `zsh` | 対応 |

| システム | 状態 |
|:-------|:-------|
| macOS | Apple Silicon と Intel の Tahoe。付属のツール、Homebrew の GNU ツール、Homebrew の uutils で確認 |
| Linux | x86_64 と arm64 の Ubuntu 26.04。GNU coreutils、uutils、BusyBox で確認 |

## 開発

| コマンド | 実行内容 |
|:--------|:-------------|
| `make fmt` | すべてのスクリプトに shfmt `-i 2` をかけます |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint、actionlint を、指摘ゼロで通します |
| `make test` | システムの `sh` で bats のテスト |
| `make test-all` | インストール済みのすべてのシェルでテスト。macOS では bash と zsh の両方のビルドを含みます |
| `make test-linux` | Ubuntu のコンテナでテスト |
| `make coverage` | この Mac と Ubuntu のコンテナで bashcov を実行し、合算して 100 パーセントで判定します |
| `make screens` | 上の画面を、本物のプラグインから tmux の中で VHS で録画します。macOS で実行します |
| `make install` | コマンド、manページ、補完を `PREFIX` の下に置きます |

macOS では、`brew bundle` を実行すると、これらのターゲットが使うツールがすべて [`Brewfile`](Brewfile) からインストールされます。

コミットは Conventional Commits の形式に従い、そのまま `main` に入ります。`main` で `ci` が成功すると、`release.yml` が semantic-release を実行します。前回のタグ以降に `feat` か `fix` があればリリースを公開し、バージョン定数を更新し、変更内容を [`CHANGELOG.md`](CHANGELOG.md) に追加します。

## ライセンス

[MIT](LICENSE)、copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped ファミリー

このプラグインは tmux-revamped ファミリーの一員です。すべてのメンバーが [`FAMILY.md`](FAMILY.md) の同じ規約と同じ共有ライブラリを持ちます。メンバーは一緒にインストールする前提で作られており、ほかのメンバーが使うキーや tmux オプションを使うメンバーはありません。

あるメンバーで見つかった不具合は、修正完了とする前に全メンバーで同じ不具合を探します。

| メンバー | 機能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | tmuxの設定を編集して保存するだけで、キーもコマンドも使わずに自動で再読み込みされます |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | tmuxのステータスバーに電池の状態を表示し、ステータスの描画を一切止めません |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 接続中のすべてのBluetooth機器とその電池残量をtmuxのステータスバーに表示し、描画を止めません |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPUの負荷、温度、周波数をtmuxのステータスバーに表示し、描画を一切止めません |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | tmuxのステータスバーにディスク使用量を表示し、ステータスの描画を一切止めません |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 画面上の URL、パス、ハッシュなどのトークンを fzf で選び、カーソル位置に入力します。純粋なシェルだけで動きます |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | ポップアップ内の fzf ピッカーから、tmux のセッション、ウィンドウ、ペインの切り替え、終了、名前変更、作成を行います |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | アクティブなペインのgitブランチ、変更、プロバイダーの件数を、描画を止めずにtmuxのステータスバーに表示します |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | NVIDIA、AMD、Intel、Apple の GPU の負荷、温度、クロック、電力、メモリを tmux のステータスバーに表示します |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 現在の Kubernetes コンテキストと名前空間を、kubectl を使わずに kubeconfig から解析して tmux のステータスバーに表示します |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | 任意の TUI アプリを、現在のペインのディレクトリでポップアップまたはウィンドウとして起動します。アプリごとにキーを設定できます |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 任意のペインをファイルに保存します。ライブのログ記録、スクロールバック全体、1 回限りのスクリーンショットに対応します |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 再生中の曲をステータスバーに表示し、ステータスの描画を止めません |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | ネットワークのスループットをステータスバーに表示し、描画を止めません |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux のペインとウィンドウの操作キー。tmux のバージョンに対応し、vim と共存でき、どの prefix キーも無効にできます |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | tmuxのすべてのセッション、ウィンドウ、ペインを保存し、タイマーで自動保存して、再起動後にすべて復元します |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revampedプラグインの出発点です。共有ライブラリ、batsハーネス、CIを含みます |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | **このプラグイン**、すべての状態をtmuxオプションに保持し、一時ファイルを使わない、tmuxステータスバーのポモドーロタイマーです |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM、スワップ、メモリプレッシャーをtmuxのステータスバーに表示します。計測はバックグラウンドで行うため描画を待たせません |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | tmuxのステータスバー上でウィンドウのタブをマウスでドラッグして、そのウィンドウを移動します |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 自分でスクロールできるアプリにはマウスホイールを渡し、それ以外ではtmuxのコピーモードに入ります |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | tmuxのバージョンと端末に合わせて適用され、ユーザーが設定したオプションには触れない、妥当な初期設定です |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmuxのタイル型ウィンドウ管理です。BSPのdwindleとspiralを含む8つのレイアウトと、レイアウトの取り消しがあります |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | ステータスバーにローカル時計と世界時計を時間帯ごとの色で表示し、カウントダウンと夏時間の警告も出します |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | wttr.inの天気をバックグラウンドで取得し、ステータスバーを待たせずに表示します |

<!-- family:end -->
