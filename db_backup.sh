MYSQL_VER=`brew list | grep mysql@`
MYSQL_VER=${MYSQL_VER##mysql@}
DB_BACKUP_NAME="`date "+%Y年%m月%d日%H時%M分%S秒"`_""mysql@"$MYSQL_VER
mkdir ~/projects/env_error_tools/db_backup
mysqldump -u root --all-databases > ~/projects/env_error_tools/db_backup/$DB_BACKUP_NAME.sql
