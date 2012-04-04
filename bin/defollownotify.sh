#!/bin/bash

###############################################################################
# @Author : Ennio Giliberto aka Lightuono / Toshidex
# @Name : Defollow Notify
# @Copyright : 2012
# @Site : http://www.toshidex.org
# @License : GNU AGPL v3 http://www.gnu.org/licenses/agpl.html
###############################################################################

DFN_RC="/usr/local/src/defollownotify/defollownotify.rc"
OAuth_sh=$(which TwitterOAuth.sh)
HOME_IDS="$HOME/.defollownotify"


(( $? != 0 )) && echo 'Unable to locate TwitterOAuth.sh! Make sure it is in searching PATH.' && exit 1
source "$OAuth_sh"

load_config() {
	
	[[ ! -d "$HOME/.defollownotify" ]] && mkdir $HOME/.defollownotify
	
	[[ -f "$DFN_RC" ]] && . "$DFN_RC" || echo -e "\n defollownotify.rc: File not found!\n $(exit)"
	
	[[ "$oauth_consumer_key" == "" ]] && echo -e "\n The variable [ oauth_consumer_key ] not found!\n $(exit)"
        [[ "$oauth_consumer_secret" == "" ]] && echo -e "\n The variable [ oauth_consumer_secret ] not found!\n $(exit)"
	[[ "$USER_NAME" == "" ]] && echo -e "\n You have not insert an account Twitter"

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
}

create_ids() {

	filename="$1"
	
	#delete the first three rows
	sed -i '1,3d' $filename

	#delete tags <id> and </id>
	sed -i -e 's/<id>//g' -e 's/<\/id>//g' $filename

	#inversion file and delete the first three rows
	tac $filename > /tmp/ids_firstxx.xml
	sed -i '1,3d' /tmp/ids_firstxx.xml
	
	#move temporany file into original directory
	mv /tmp/ids_firstxx.xml $HOME_IDS/ids_first.xml
	rm $filename
}

download_ids_list() {

	if [ -f $HOME/.defollownotify/ids_first.xml ]; then
 		curl -o $ids_second "https://api.twitter.com/1/followers/ids.xml?cursor=-1&screen_name=$USER_NAME"
		create_ids "ids_second.xml"
        else
                curl -o /tmp/ids_first.xml "https://api.twitter.com/1/followers/ids.xml?cursor=-1&screen_name=$USER_NAME"
		local next_cursor=$(grep "<next_cursor>" /tmp/ids_first.xml | sed -e 's/<next_cursor>//g' -e 's/<\/next.*//g') #GET NEXT_CURSOR
		if [ $next_cursor -eq 0 ]; then
			create_ids "/tmp/ids_first.xml"
        	fi
	fi
}


load_config
download_ids_list

