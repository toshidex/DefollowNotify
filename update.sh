#!/bin/bash

###############################################################################
# @Author : Ennio Giliberto aka Lightuono / Toshidex
# @Name : Defollow Notify
# @Copyright : 2012
# @Site : http://www.toshidex.org
# @License : GNU AGPL v3 http://www.gnu.org/licenses/agpl.html
###############################################################################

# Init Variables
install_home="/usr/local"
DFN_RC="$install_home/src/defollownotify/defollownotify.rc"
#End Init Variables

echo -e "\n* Update Defollow Notify -"

echo -e "\n* Checking user's privileges..."

if [ $(id -u) -ne 0 ]; then
        echo -e "\n* ERROR: User $(whoami) is not root, and does not have sudo privileges"
        exit 1
fi

if [ ! -d $install_home/src/defollownotify ]; then
	echo -e "\n* You haven't installed Defollow Notify!"
	echo -e "\n* Please run [ sudo bash install.sh ]"
	exit 0
fi

echo -e "\n* Update in progress.."

if [ -d $install_home/src/defollownotify ]; then
	
	[[ $(grep -o "BASTARD_MODE" $install_home/src/defollownotify/defollownotify.rc) == "" ]] && echo 'BASTARD_MODE="FALSE"' >> $install_home/src/defollownotify/defollownotify.rc
	cp bin/defollownotify.sh $install_home/bin/defollownotify
	echo -e "\n	- Copy file execute [ defollownotify.sh ] inside /usr/local/bin"
	chmod +x $install_home/bin/defollownotify
	echo -e "\n	- Change permissions at the file [ defollownotify.sh ] inside /usr/local/bin"
	cp VERSION $install_home/src/defollownotify/
	echo -e "\n	- Copy file [ VERSION ] inside /usr/local/src/defollownotify"
fi

echo -e "\n* Update Complete!"
exit 0
