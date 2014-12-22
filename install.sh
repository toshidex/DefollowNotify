#!/bin/bash

###############################################################################
# @Author : Ennio Giliberto aka Lightuono / Toshidex
# @Implemented by : Domenico Luciani aka DLion
# @Name : Defollow Notify
# @Copyright : 2012
# @Site : http://www.toshidex.org
# @Site : http://about.me/dlion
# @License : GNU AGPL v3 http://www.gnu.org/licenses/agpl.html
###############################################################################

# Init Variables
check_user=""
check_dep=0
declare -A dep
dep=(
	["bash"]="$(which bash 2> /dev/null)"
	["curl"]="$(which curl 2> /dev/null)")
install_home="/usr/local"
DFN_RC="$install_home/src/defollownotify/defollownotify.rc"

#End Init Variables

echo -e "\n* Installation Defollow Notify -"

if [ -d $install_home/src/defollownotify ]; then
	echo -e "\n* You have already installed Defollow Notify!"
	exit 0
fi

echo -e "\n* Checking user's privileges..."

if [ $(id -u) -ne 0 ]; then
	echo -e "\n* ERROR: User $(whoami) is not root, and does not have sudo privileges"
	exit 1
fi

echo -e "\n* Write your username Twitter: "
read username

echo -e "\n* Checking dependencies..."

for key in "bash" "curl"; do
	if [ -n "${dep[$key]}" ]; then
		echo "	-  Package [ $key ] => [ OK ]"
	else
		echo "	-  Package [ $key ] => [ Not Found ]"
		check_dep=1
		dep_install="$key $dep_install"
	fi
done

if [ $check_dep -eq 1 ]; then
	echo -e "\n* ERROR: You have to install [ $dep_install ] before to continue."

	exit 1
fi


echo -e "\n* Installing in progress.."

if [ ! -d $install_home/src/ ]; then
	mkdir $install_home/src/
fi

if [ ! -d $install_home/src/defollownotify ]; then
	mkdir $install_home/src/defollownotify
	echo -e "\n	- Create directory [ defollownotify ] inside $install_home/src"
	cp conf/defollownotify.rc $install_home/src/defollownotify
	echo -e "\n	- Copy file [ defollownotify.rc ] inside $install_home/src/defollownotify"
	cp VERSION $install_home/src/defollownotify
	echo -e "\n	- Copy file [ VERSION ] inside $install_home/src/defollownotify"
	cp -fr lib/*.sh $install_home/bin
	chmod +x $install_home/bin/TwitterOAuth.sh
	chmod +x $install_home/bin/OAuth.sh
	echo -e "\n	- Copy files [ OAuth.sh TwitterOAuth.sh ] inside $install_home/bin"
	cp bin/defollownotify.sh $install_home/bin/defollownotify
	echo -e "\n	- Copy file execute [ defollownotify.sh ] inside /usr/local/bin"
	chmod +x $install_home/bin/defollownotify
	echo -e "\n	- Change permissions at the file [ defollownotify.sh ] inside /usr/local/bin"
    	cp uninstall.sh $install_home/src/defollownotify
    	chmod +x $install_home/src/defollownotify/uninstall.sh
    	echo -e "\n - Copy uninstall inside $install_home/src/defollownotify"
	echo "USER_NAME=$username" >> $install_home/src/defollownotify/defollownotify.rc
	echo "HOMEDIR=$install_home/src/defollownotify" >> $install_home/src/defollownotify/defollownotify.rc
fi

source $DFN_RC
OAuth_sh=$(which TwitterOAuth.sh)
(( $? != 0 )) && echo 'Unable to locate TwitterOAuth.sh! Make sure it is in searching PATH.' && exit 1
source "$OAuth_sh"

echo -e "\n* Configuration account Twitter.."
TO_init

if [[ "$oauth_token" == "" ]] || [[ "$oauth_token_secret" == "" ]]; then
	TO_access_token_helper
	if (( $? == 0 )); then
		oauth_token=${TO_ret[0]}
		oauth_token_secret=${TO_ret[1]}
		echo "oauth_token='${TO_ret[0]}'" >> "$DFN_RC"
		echo "oauth_token_secret='${TO_ret[1]}'" >> "$DFN_RC"
		echo "Token saved."
	else
		echo 'Unable to get access token'
		exit 1
	fi
fi

echo -e "\n* Installation Complete!"
exit 0
