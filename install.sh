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
dep=(
	["bash"]="$(which bash 2> /dev/null)"
	["curl"])"$(which curl 2> /dev/null)")

#End Init Variables

echo -e "* Checking user's privileges...\n"

if [ $(id -u) -ne 0 ]; then
	echo "	ERROR: User $(whoami) is not root, and does not have sudo privileges"
	exit 1
else
	while [ -z $check_user ]; do
		echo "	Write your exact username: "
		read username
		id -u -r $usernmae &> /dev/null
		
		if [ $? -eq 0 ]; then
			check_user=1
		else
			echo "	Username don't exists! Please insert a valid username."
		fi
	done
fi

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



