#!/bin/bash

###############################################################################
# @Author : Ennio Giliberto aka Lightuono / Toshidex
# @Name : Defollow Notify
# @Version: 0.0.1
# @Copyright : 2012
# @Site : http://www.toshidex.org
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

#End Init Variables

echo -e "\n* Installation Defollow Notify -"


echo -e "\n* Checking user's privileges..."

if [ $(id -u) -ne 0 ]; then
	echo -e "\n* ERROR: User $(whoami) is not root, and does not have sudo privileges"
	exit 1
#else
#	while [ -z $check_user ]; do
#		echo "	Write your exact username: "
#		read username
#		id -u -r $username &> /dev/null
#		
#		if [ $? -eq 0 ]; then
#			check_user=1
#		else
#			echo "	Username don't exists! Please insert a valid username."
#		fi
#	done
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

#install_home="$(awk -F: -v v="$username" '{ if ( $1 == v ) print $6 }' /etc/passwd)"

if [ ! -d $install_home/src/defollownotify ]; then
	mkdir $install_home/src/defollownotify
	echo -e "\n	- Create directory [ defollownotify ] inside $install_home/src"
	cp conf/defollownotify.rc $install_home/src/defollownotify
	echo -e "\n	- Copy file [ defollownotify.rc ] inside $install_home/src/defollownotify"
	cp -fr lib $install_home/src/defollownotify
	echo -e "\n	- Copy directory [ lib ] inside $install_home/src/defollownotify"
	cp bin/defollownotify.sh $install_home/bin/defollownotify
	echo -e "\n	- Copy file execute [ defollownotify.sh ] inside /usr/local/bin"
	chmod +x $install_home/bin/defollownotify
	echo -e "\n	- Change permissions at the file [ defollownotify.sh ] inside /usr/local/bin"
	echo "USERNAME=$username" >> $install_home/src/defollownotify/defollownotify.rc
	echo "HOMEDIR=$install_home/src/defollownotify" >> $install_home/src/defollownotify/defollownotify.rc

	echo -e "\n* Installation complete!"
	exit 0
else
	echo -e "\n* You have already installed Defollow Notify!"
	exit 0
fi
