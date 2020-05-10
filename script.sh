printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
どうしても中断したい場合は「Control + C」を押し続けてください
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
: 'zshかbashか'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
あなたのshellは
"
if [ `echo $SHELL | grep 'zsh'` ] ; then
  printf "zsh\n"
  ENV_FILE="zshrc"
elif [ `echo $SHELL | grep 'fish'` ] ; then
  printf "fish\n"
  printf "
申し訳ありません。fishは対応していません。zshに変更してからお試しください。
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  return 2>&- || exit
else
  printf "bash\n"
  ENV_FILE="bash_profile"
fi
printf "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
: 'xcodeが入っているか'
printf '
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
【xcode-selectコマンドを実行するには、コマンドライン・デベロッパツールが必要です】
というウインドウは表示されましたか？表示されたのであればインストールを行ってください（かなり時間がかかります）
【command line tools are already installed】と表示されていたり、インストールが完了した場合は
yを入力してEnterを押してください。中断する場合はy以外を入力してEnterを押してください
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'
xcode-select --install
read xcode_install
if [ $xcode_install != y -a $xcode_install != ｙ ] ; then
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
xcodeを導入してからやり直してください
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  return 2>&- || exit
fi
: '使いたいmysqlのバージョン'
MYSQL_VER=5.6
: '使いたいrubyのバージョン'
GLOBAL_RUBY_VER=2.5.1
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rails newをしたことがありますか？
したことがあるのであればyを入力してEnterを押してください
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
read input_rails_new
if [ $input_rails_new = y -o $input_rails_new = ｙ ] ; then
  RAILS_NEW=yes
  if [ ! -e Gemfile ] ; then
    printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Railsプロジェクト内（my_first_appなど）に移動してから再度実行してください
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
    return 2>&- || exit
  fi
else
  RAILS_NEW=no
fi
: 'カレントディレクトリを変数に入れておく'
CDR=$(pwd)
\
: 'ホームディレクトリへ移動'
cd ~
: 'データベースのバックアップを作成'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
データベースのバックアップを作成します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
mysql.server start
if [[ `mysql.server status` != *SUCCESS* ]]; then
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
mysqlが起動していません

修正を試みます
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"

: 'mysqlの権限を修正'
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
mysqlの権限を修正します

パスワードを求められた場合はMacのパスワードを入力してください
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  sudo chown -R "$(whoami)":admin /usr/local/var/mysql
  sudo chmod 1777 /tmp
  sudo chown root:wheel /tmp
\
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
mysqlを起動します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
: 'sockやプロセスが残っているとmysqlの起動に失敗するので削除'
  sudo rm -rf /tmp/mysql.sock
  sudo pkill -KILL -f mysql
  sudo pkill -KILL -f mysql
  sudo pkill -KILL -f mysql
\
: 'mysqlの起動'
  mysql.server start
fi

if [[ `mysql.server status` != *SUCCESS* ]]; then
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
mysqlが起動できません
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"

  printf "\e[31m
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
データベースが消えても良いですか？
よろしければyを入力してEnterを押してください。
消えると困るのであればy以外を入力してEnterを押してください。
※消したほうが解決確率は上がります
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
\e[m
"
  read input_remove_tables
  if [ $input_remove_tables = y -o $input_remove_tables = ｙ ] ; then
    REMOVE_TABLES=yes
  else
    REMOVE_TABLES=no
  fi
fi
if [ $REMOVE_TABLES != "no" ]; then
  DB_BACKUP_NAME="db_backup_`date "+%Y_%m%d_%H%M_%S"`"
  mysqldump -u root --all-databases > ~/$DB_BACKUP_NAME.sql
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ホームディレクトリへ
「$DB_BACKUP_NAME.sql」
という名前でバックアップを作成しました。

手動でデータベースを復元したい場合は
mysql -u root < ~/$DB_BACKUP_NAME.sql
を実行してください。
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
fi
\
: 'mysqlを停止'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
mysqlを停止します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
mysql.server stop
\
: 'mysqlを全削除'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
全てのバージョンのmysqlを一旦削除します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
mysqls=($(brew list | grep mysql@) mysql)
for mysql in $mysqls; do
  brew uninstall $mysql
done
\
: 'sudoの有効化'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ここからはパスワードの入力を求められたら、Macのパスワードを入力してください
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
sudo cd ..
: 'xcodeのライセンス認証'

printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
xcodeのライセンス認証を行います
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
sudo xcodebuild -license accept
: 'mysqlの設定を削除'
if [ $REMOVE_TABLES != "no" ]; then
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
mysqlの設定やテーブルを削除します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  sudo rm -rf /usr/local/var/mysql
fi
sudo rm /etc/my.cnf
\
: '本来使いたいmysqlを入れ直す'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
mysqlを入れ直します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
brew install mysql@$MYSQL_VER
\
: 'mysqlへのパスを再設定'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
mysqlのパスを通します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
sed -i .bak '/opt\/mysql/d' ~/.$ENV_FILE
echo "export PATH="/usr/local/opt/mysql@${MYSQL_VER}/bin:""'$PATH' >> ~/.$ENV_FILE
source ~/.$ENV_FILE
\
: 'mysqlの権限を修正'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
mysqlの権限を修正します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
sudo chown -R "$(whoami)":admin /usr/local/var/mysql
sudo chmod 1777 /tmp
sudo chown root:wheel /tmp
\
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
mysqlを起動します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
: 'sockやプロセスが残っているとmysqlの起動に失敗するので削除'
sudo rm -rf /tmp/mysql.sock
sudo pkill -KILL -f mysql
sudo pkill -KILL -f mysql
sudo pkill -KILL -f mysql
\
: 'mysqlの起動'
mysql.server start
\
: 'mysql自動起動の設定'
rm -rf ~/Library/LaunchAgents
mkdir ~/Library/LaunchAgents
ln -sfv /usr/local/opt/mysql\@$MYSQL_VER/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql\@$MYSQL_VER.plist
\
: 'バックアップからデータベースのテーブルを復元'
if [ $REMOVE_TABLES != "no" ]; then
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
バックアップからデータベースを復元します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  mysql -u root < ~/$DB_BACKUP_NAME.sql
fi
: 'rbenvへのパスを再設定'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rbenvの再設定を行います
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
sed -i .bak '/rbenv init/d' ~/.$ENV_FILE
echo 'eval "$(rbenv init -)"' >> ~/.$ENV_FILE
source ~/.$ENV_FILE
\
: 'rubyのインストールとrbenv globalをやっておく'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rbenv global ${GLOBAL_RUBY_VER}を行います
ruby${GLOBAL_RUBY_VER}がもし導入されていない場合、ここでrubyをインストールします
rubyのインストールが始まった場合かなり時間がかかる可能性があります
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
export CONFIGURE_OPTS="--with-readline-dir=`brew --prefix readline` --with-openssl-dir=`brew --prefix openssl`"
export RUBY_CONFIGURE_OPTS="--with-readline-dir=`brew --prefix readline` --disable-install-doc --with-openssl-dir=`brew --prefix openssl`"
echo n |rbenv install $GLOBAL_RUBY_VER
rbenv rehash
rbenv global $GLOBAL_RUBY_VER
rbenv rehash
\
: 'rvmを削除する'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rvmを削除します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
rvm seppuku
sudo rm -rf ~/.rvm
\
: '先ほどのカレントディレクトリへ戻る'
cd $CDR
: 'Rails newをしたことがないのであればここで終了'
if [ $RAILS_NEW = no ] ; then
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
修正が完了しました
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  return 2>&- || exit
fi
\
: 'OpenSSLのチェック'
RUBY_OPENSSL=`ruby -ropenssl -e 'puts OpenSSL::OPENSSL_VERSION'`
RUBY_V=`ruby -v`

printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
OpenSSLをチェックします
${RUBY_V}
には
${RUBY_OPENSSL}
が使用されています。
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"

sed -i .bak '/export PATH=\/usr\/local\/opt\/openssl/d' ~/.$ENV_FILE
echo "export PATH=`brew --prefix openssl`/bin:\$PATH" >> ~/.$ENV_FILE
source ~/.$ENV_FILE
OPENSSL_VERSION=`openssl version`

if [[ ${RUBY_OPENSSL:8:4} != ${OPENSSL_VERSION:8:4} ]]; then
  printf '\e[31m
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
※※※Homebrewのopensslとrubyで使用されているopensslに齟齬があります！※※※
もし以下のようなエラーが出ていて詰まっているようであればrubyの入れ直しを検討してください。

Library not loaded: /usr/local/opt/openssl/lib/libssl.1.0.0.dylib (LoadError)

openssl,ruby,mysqlを入れ直しますか？（かなり時間がかかります）
入れ直す場合はyを入力してEnterを押してください。
入れ直さない場合はy以外を入力してEnterを押してください。
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
\e[m
'
  read reinstall_openssl

  if [ $reinstall_openssl = y -o $reinstall_openssl = ｙ ] ; then
    printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
opensslを削除しています
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
    brew uninstall --ignore-dependencies openssl
    brew uninstall --ignore-dependencies openssl
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
opensslを入れ直しています
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
    brew install openssl
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
opensslのパスを通し直しています
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
    sed -i .bak '/export PATH=\/usr\/local\/opt\/openssl/d' ~/.$ENV_FILE
    echo "export PATH=`brew --prefix openssl`/bin:\$PATH" >> ~/.$ENV_FILE
    source ~/.$ENV_FILE
    OPENSSL_VERSION=`openssl version`
    OPENSSL_VERSION=(`echo $OPENSSL_VERSION`)
    brew switch openssl $OPENSSL_VERSION[2]

  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rubyを入れ直します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  cd ~
  brew uninstall rbenv
  sudo rm -rf ~/.rbenv
  brew install rbenv
  export CONFIGURE_OPTS="--with-readline-dir=`brew --prefix readline` --with-openssl-dir=`brew --prefix openssl`"
  export RUBY_CONFIGURE_OPTS="--with-readline-dir=`brew --prefix readline` --disable-install-doc --with-openssl-dir=`brew --prefix openssl`"
  rbenv install $GLOBAL_RUBY_VER
  rbenv rehash
  rbenv global $GLOBAL_RUBY_VER
  rbenv rehash
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
mysqlを入れ直します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  brew uninstall mysql@$MYSQL_VER
  brew install mysql@$MYSQL_VER
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
mysqlを起動します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  : 'sockやプロセスが残っているとmysqlの起動に失敗するので削除'
  sudo rm -rf /tmp/mysql.sock
  sudo pkill -KILL -f mysql
  sudo pkill -KILL -f mysql
  sudo pkill -KILL -f mysql
  \
  : 'mysqlの起動'
  mysql.server start
  \
  : 'mysql自動起動の設定'
  rm -rf ~/Library/LaunchAgents
  mkdir ~/Library/LaunchAgents
  ln -sfv /usr/local/opt/mysql\@$MYSQL_VER/*.plist ~/Library/LaunchAgents
  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mysql\@$MYSQL_VER.plist
  \
  cd $CDR
  fi

fi
\
: 'Gemfileで指定されているrubyのバージョンを探して設定する'
LOCAL_RUBY_VER=$(cat Gemfile | awk "/ruby '/" | sed "s/^.*'\(.*\)'.*$/\1/")
: '.ruby-versionがあるならそこからrubyのバージョンを取得する'
if [ -z $LOCAL_RUBY_VER ]; then
  LOCAL_RUBY_VER=`cat .ruby-version`
fi
: 'LOCAL_RUBY_VERが空ならrbenv globalと同じバージョンをlocalに設定する'
if [ -z $LOCAL_RUBY_VER ]; then
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rbenv local ${GLOBAL_RUBY_VER}を行います
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  rbenv local $GLOBAL_RUBY_VER
else
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Gemfile,もしくは.ruby-versionでruby${LOCAL_RUBY_VER}が設定されています
rbenv local ${LOCAL_RUBY_VER}を行います
ruby${LOCAL_RUBY_VER}がもし導入されていない場合、ここでrubyをインストールします
rubyのインストールが始まった場合かなり時間がかかる可能性があります
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  echo n |rbenv install $LOCAL_RUBY_VER
  rbenv rehash
  rbenv local $LOCAL_RUBY_VER
fi
rbenv rehash
\
: 'Gemfile.lockで指定されているbundlerのバージョンを探して入れる'
BUNDLER_VER=$(echo $(cat Gemfile.lock) | awk '{print substr($0, index($0, "BUNDLED WITH"))}' | cut -c14- )
if [ -n $BUNDLER_VER ] ; then
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
バージョン${BUNDLER_VER}のbundlerが必要です
gem install bundler -v ${BUNDLER_VER}を行います
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  gem install bundler -v $BUNDLER_VER
\
else
  : 'Gemfile.lockが無い場合、最新のbundlerを入れる'
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
最新のバージョンのbundlerをインストールします
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  gem install bundler
fi
\
  printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
railsをインストールします
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
gem install rails -v '5.0.7.2'
gem install rails -v '5.2.3'
gem install rails -v '5.2.4'
rbenv rehash
\
: 'mysql2のgemを全て消しておく（mysqlを入れ直した後だとエラーが出る可能性があるため）'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
gem mysql2を全消去します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
gem uninstall -aIx mysql2
\
: 'bundle configを設定し直す'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bundle configを再設定します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
rm -rf ~/.bundle
rm -rf .bundle
bundle config --delete build.mysql2
bundle config --global build.mysql2 --with-opt-dir="$(brew --prefix openssl)"
\
: 'gemの権限を修正しておく'
sudo chown -R $(whoami) $(gem environment gemdir)
\
: 'defaults gemを消しておく'
sudo rm -rf $(gem environment gemdir)/specifications/default
\
: 'rails sをキルしておく'
pkill -KILL -f puma
\
: 'bundle install --path vendor/bundleで入ったgemを消す'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bundle install -path vendor/bundleによってインストールされてしまったgemを削除します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
rm -rf vendor/bundle
\
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bundle installを行います
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
bundle install
: 'springの再起動'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
springを再起動します
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
bundle exec spring stop
bundle exec spring
\
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rails db:createを行います
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
rails db:create
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rails db:migrateを行います
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
rails db:migrate
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
rails sを起動します。
正常に起動できたら修正完了です
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
rails s
