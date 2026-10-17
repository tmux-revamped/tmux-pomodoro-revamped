<div align="center">

# tmux-pomodoro-revamped

<strong>すべての状態をtmuxオプションに保持し、一時ファイルを使わない、tmuxステータスバーのポモドーロタイマーです。</strong>

[English](README.md) &nbsp;|&nbsp; 日本語 &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![Tests](https://github.com/tmux-revamped/tmux-pomodoro-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-pomodoro-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">概要</a> &nbsp;|&nbsp;
  <a href="#installation">インストール</a> &nbsp;|&nbsp;
  <a href="#usage">使い方</a> &nbsp;|&nbsp;
  <a href="#configuration">設定</a> &nbsp;|&nbsp;
  <a href="#key-bindings">キーバインド</a> &nbsp;|&nbsp;
  <a href="#how-it-works">仕組み</a>
</p>

</div>

**作業25分、短い休憩5分、作業4回ごとに長い休憩15分です。一時ファイルは0個です。macOSとLinuxでテストしています。**

---

<a id="what-it-does"></a>

## 概要

タイマーは作業時間と休憩をステータスバーでカウントダウンし、そのサイクルを繰り返します。一時停止と再開をしても時間がずれません。フェーズが変わるたびに、デスクトップ通知を送り、端末のベルを鳴らし、好きなシェルコマンドを実行できます。終えた作業の回数を7日分記録します。

## 必要なもの

| 項目 | バージョンや補足 |
|:------------|:----------------|
| tmux | 3.2以降。ヘルプのポップアップに必要です |
| bash | 3.2以降。macOS標準の`/bin/bash`で動きます |
| OS | Apple SiliconとIntelのmacOS、x86_64とarm64のLinux |
| 基本コマンド | BSD、GNU、uutilsのいずれのcoreutilsでも動きます |
| `osascript`または`notify-send` | 任意。macOSまたはLinuxのデスクトップ通知に使います |

<a id="installation"></a>

## インストール

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

<a id="usage"></a>

## 使い方

`prefix + M-s`でタイマーを開始します。もう一度押すと一時停止し、さらに押すと再開します。

`status-left`または`status-right`に置いた`#{pomodoro_status}`は、フェーズの色、`MM:SS`のカウントダウン、`[interval/total]`のカウンターを表示します。たとえば`23:20 [1/4]`です。タイマーが動いていない間は何も表示しません。

描画のたびに以下のtmuxオプションも書き込むので、テーマや他のプラグインはスクリプトを実行せずに読めます。

| オプション | 値 |
|:-------|:------|
| `@pomodoro_status` | 描画したセグメントで、`#{pomodoro_status}`と同じテキストです |
| `@pomodoro_phase` | `work`、`break`、`long_break`のいずれかです |
| `@pomodoro_remaining` | フェーズの残り秒数です |
| `@pomodoro_fraction` | フェーズの経過率をパーセントで示します |
| `@pomodoro_week` | 直近7日間の曜日ごとの作業回数を日曜日から並べたスパークラインで、`_.-=+*%@`で描きます |
| `@pomodoro_today` | 今日終えた作業の回数です |

同じ操作はシェルから`~/.tmux/plugins/tmux-pomodoro-revamped/src/pomodoro.sh <action>`として実行できます。actionは`toggle`、`cancel`、`skip`、`restart`、`menu`、`help`のいずれかです。

<a id="configuration"></a>

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
| `@pomodoro_revamped_notifications` | `1` | `0`でデスクトップ通知を止めます |
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

<a id="key-bindings"></a>

## キーバインド

| キー | 動作 | オプション |
|:----|:-------|:-------|
| `prefix + M-s` | 開始、一時停止、再開 | `@pomodoro_revamped_toggle_key` |
| 未割り当て | 取り消し | `@pomodoro_revamped_cancel_key` |
| 未割り当て | 次のフェーズへ進む | `@pomodoro_revamped_skip_key` |
| 未割り当て | 現在のフェーズをやり直す | `@pomodoro_revamped_restart_key` |
| 未割り当て | 操作メニューを開く | `@pomodoro_revamped_menu_key` |
| 未割り当て | ヘルプのポップアップを開く | `@pomodoro_revamped_help_key` |

`M-s`は、tmux-revampedファミリーがこのプラグインに割り当てた唯一のキーです。2.0.0より前は、切り替えが`p`で、他の操作は`P`、`_`、`R`、`o`、`?`に割り当てられていました。元に戻すには、そのオプションを設定します。

```tmux
set -g @pomodoro_revamped_menu_key 'o'
```

<a id="how-it-works"></a>

## 仕組み

**1つの開始時刻。** タイマーは開始したエポック秒と、一時停止していた秒数を保存します。描画のたびに現在時刻から両方を引き、作業、短い休憩、長い休憩のサイクルをたどって、現在のフェーズと残り秒数を求めます。スキップは開始時刻を残り秒数だけ前へずらします。やり直しは、そのフェーズですでに使った秒数だけ後ろへずらします。

**ファイルなし。** すべての値はtmuxサーバーのオプションにあるので、`/tmp`には何も書かず、片付けるものも残りません。週ごとの集計は、オプションに入れた7枠のリングです。

**描画。** エントリーポイントは`#{pomodoro_status}`を[`src/pomodoro.sh`](src/pomodoro.sh)を呼ぶ`#()`に置き換えるので、カウントダウンは`status-interval`ごとに進みます。バックグラウンドのプロセスは動きません。

**フェーズの変化。** 接続中のクライアントはそれぞれステータス行を更新するため、複数の描画が同じフェーズの変化に気づくことがあります。1つの条件付きtmuxコマンドがその変化を確保し、確保した描画だけが作業回数を数え、フックを実行し、通知を送ります。フックは`run-shell -b`で実行するので、遅いコマンドがステータス行を止めることはありません。

## 開発

| コマンド | 内容 |
|:--------|:-------------|
| `make test` | batsのテストスイートを実行します |
| `make lint` | すべてのシェルファイルにshellcheckを実行します |
| `make coverage` | kcovで行カバレッジを測り、95パーセント未満なら失敗します。Linuxで動きます |

テストスイートには`bats-core`とtmuxが必要です。

## ライセンス

[MIT](LICENSE)

<!-- family:begin -->

## tmux-revamped ファミリー

このプラグインは tmux-revamped ファミリーの一員です。すべてのメンバーが [`FAMILY.md`](FAMILY.md) の同じ規約、`family/` 配下の同じツール、同じ共有ライブラリを持ち、チェックサムの一覧によってバイト単位で同一に保たれています。メンバーは一緒にインストールする前提で作られており、ほかのメンバーが使うキーや tmux オプションを使うメンバーはありません。

あるメンバーで見つかった不具合は、修正完了とする前に全メンバーで同じ不具合を探します。この義務は記憶に頼らず規約に書かれており、`family/bin/sweep` がその作業を行います。

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
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revampedプラグインの出発点です。共有ライブラリ、batsハーネス、CI、ファミリーのツールを含みます |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | **このプラグイン**、すべての状態をtmuxオプションに保持し、一時ファイルを使わない、tmuxステータスバーのポモドーロタイマーです |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM、スワップ、メモリプレッシャーをtmuxのステータスバーに表示します。計測はバックグラウンドで行うため描画を待たせません |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | tmuxのステータスバー上でウィンドウのタブをマウスでドラッグして、そのウィンドウを移動します |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 自分でスクロールできるアプリにはマウスホイールを渡し、それ以外ではtmuxのコピーモードに入ります |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | tmuxのバージョンと端末に合わせて適用され、ユーザーが設定したオプションには触れない、妥当な初期設定です |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmuxのタイル型ウィンドウ管理です。BSPのdwindleとspiralを含む8つのレイアウトと、レイアウトの取り消しがあります |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | ステータスバーにローカル時計と世界時計を時間帯ごとの色で表示し、カウントダウンと夏時間の警告も出します |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | wttr.inの天気をバックグラウンドで取得し、ステータスバーを待たせずに表示します |

### インストールの確認

全メンバーがディスク上にあれば、1 つのコマンドでメンバー間の衝突を報告できます。

```sh
family/bin/doctor --live
```

各メンバーと実行中の tmux サーバーを読み取り、重複したキー、重複したステータスのプレースホルダー、命名規則に合わないオプション、規約のバージョンが古いメンバーを報告します。

<!-- family:end -->
