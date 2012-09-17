#!/bin/bash

####################################################################
# @Author : Domenico Luciani aka DLion
# @Name : Defollow Notify
# @Copyright : 2012
# @Site : http://about.me/dlion
# @License : GNU AGPL v3 http://www.gnu.org/licenses/agpl.html
###################################################################

# Init Variables
root_d="/usr/local"
install_home="$root_d/src/defollownotify"
DFN_RC="$install_home/defollownotify.rc"

#End Init Variables

echo -e "\n* Uninstall Defollow Notify -"

if [ ! -d $install_home ]; then
    echo -e "\n* You haven't installed Defollow Notify!"
    echo -e "\n* Please run [ sudo ./install.sh ]"
    exit 0
fi

echo -e "\n* Checking user's privileges..."

if [ $(id -u) -ne 0 ]; then
    echo -e "\n* ERROR: User $(whoami) is not root, and does not have sudo privileges"
    exit 1
fi

echo -e "\n* Uninstalling in progress...\n"

rm -v $root_d/bin/TwitterOAuth.sh
rm -v $root_d/bin/OAuth.sh
rm -v $root_d/bin/defollownotify
rm -rv $install_home
echo -e "\n* Do you want remove the follow list from the computer? (y/n)"
read choose
if [[ "$choose" == "y" || "$choose" == "Y" ]]; then
    for i in $(cat /etc/passwd | grep /home | cut -d: -f1); do
        echo -e "\n* User check in progress..."
        if [ -d /home/$i/.defollownotify ]; then
            rm -rv /home/$i/.defollownotify
        fi
    done
fi

echo -e "\n* Uninstall Complete!"
exit 0
