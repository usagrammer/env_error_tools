: 'zshかbashか'
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
あなたのshellは
"
if [ `echo $SHELL | grep 'zsh'` ] ; then
  printf "zsh"
  ENV_FILE="zshrc"
elif [ `echo $SHELL | grep 'fish'` ] ; then
  printf "fish\n"
  printf "
申し訳ありません。fishは対応していません。zshに変更してからお試しください。
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
  EXIT=true
  return 2>&- || exit
else
  printf "bash"
  ENV_FILE="bash_profile"
fi
printf "
です。
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"

if [ `echo $SHELL | grep 'bash'` ] ; then
printf "\e[31m
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
環境エラー問題はzshで行う必要があります！
shellをzshに変更しますか？
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\e[m
"
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
zshに変更する場合は「y」を入力してEnterを押してください。
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"

read input_yn

EXIT=true
WhichZsh=`which zsh`

if [ ! `echo $WhichZsh | grep '/zsh'` ] ; then
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
zshがインストールされていません。
homebrewでインストールします。
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"

brew install zsh

printf "\e[31m
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
パスワードを求められたらMacのパスワードを入力してください！
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\e[m
"

echo `which zsh` | sudo tee -a /etc/shells


fi

if [ $input_yn != y -a $input_yn != ｙ ] ; then
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
zshへの変更は行いません。
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
else
printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
zshへの変更を行います。
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
printf "\e[31m
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
パスワードの入力を求められたらMacのパスワードを入力してください！
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\e[m
"
chsh -s `which zsh`

printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
「~/.${ENV_FILE}」の中身を「~/.zshrc」に追記します。
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"

echo "## ~/.${ENV_FILE}から追加されたものここから ##" >> ~/.zshrc
cat ~/.$ENV_FILE >> ~/.zshrc
echo "## ~/.${ENV_FILE}から追加されたものここまで ##" >> ~/.zshrc

printf "
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
パスワードを正しく入力できたらターミナルを再起動してください。

※以下のように表示された場合はパスワードが間違っています。

chsh: Credentials could not be verified, username or password is invalid.
Credentials could not be verified, username or password is invalid.
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
fi

fi
