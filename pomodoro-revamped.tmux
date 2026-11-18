#!/bin/sh

pomodoro_revamped_dir=$(cd "$(dirname "$0")" && pwd)
"${pomodoro_revamped_dir}/bin/pomodoro-revamped" apply
