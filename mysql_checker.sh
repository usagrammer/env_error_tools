MYSQL_VER=`brew list | grep mysql@`
MYSQL_VER=${MYSQL_VER##mysql@}
if [[ $MYSQL_VER == "5.6" ]] ; then
  OTHER_MYSQL_VER="5.7"
elif [[ $MYSQL_VER == "5.7" ]] ; then
  OTHR_MYSQL_VER="5.6"
else
  printf "\e[31m
  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  mysqlに異常があります！
  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  \e[m
  "
  EXIT=true
fi
