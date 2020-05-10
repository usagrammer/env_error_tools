printf "
【設定ツール】:アップデート確認中...
"
git pull
printf "
【設定ツール】:アップデート完了
"

printf "
【shell】:チェック中...
"
source ~/projects/env_error_tools/shell_checker.sh
printf "
【shell】:チェック完了
"

printf "
【terminal-notifier】:チェック中...
"
source ~/projects/env_error_tools/notifier_install.sh
printf "
【terminal-notifier】:チェック完了
"
