#!/bin/bash

###############################################################################
# @Author : Ennio Giliberto aka Lightuono / Toshidex
# @Name : Defollow Notify
# @Version : 0.0.2
# @Copyright : 2012
# @Site : http://www.toshidex.org
# @License : GNU AGPL v3 http://www.gnu.org/licenses/agpl.html
###############################################################################

DFN_RC="/usr/local/src/defollownotify/defollownotify.rc"
OAuth_sh=$(which TwitterOAuth.sh)
HOME_IDS="$HOME/.defollownotify"
screen_name=()

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

convert_ids() {

	name=$(curl "https://api.twitter.com/1/users/show.xml?user_id=$1" | grep "<screen_name>" | sed -e 's/<screen_name>//g' -e 's/<\/scre.*//g' -e 's/  //g')
	if [[ "$name" == "" ]]; then
		return
	fi
	screen_name=( ${screen_name[@]} $name )
	
}

compare_ids() {

	list_diff="$(diff $HOME_IDS/ids.xml $HOME_IDS/ids_new.xml | grep "<" | awk -F'<| ' '{ print $3}')"
	
	if [[ $list_diff == "" ]]; then
		echo "The list IDS has not changed!"
		mv $HOME_IDS/ids_new.xml $HOME_IDS/ids.xml
		exit 0
	else
		for ids_index in $list_diff; do
			convert_ids "$ids_index"
			#echo "News per @$USER_NAME: L'utente [ $screen_name ] non ti segue più."
			
		done
		#echo "News per @$USER_NAME: L'utente [ ${screen_name[@]} ] non ti segue più."
		mv $HOME_IDS/ids_new.xml $HOME_IDS/ids.xml
	fi

}

create_ids() {

	filename="$1"

	if [[ $filename == "/tmp/ids.xml" ]]; then
			
		#delete the first three rows
		sed -i '1,3d' $filename

		#delete tags <id> and </id>
		sed -i -e 's/<id>//g' -e 's/<\/id>//g' $filename

		#inversion file and delete the first three rows
		tac $filename > /tmp/idsxx.xml
		sed -i '1,2d' /tmp/idsxx.xml
		tac /tmp/idsxx.xml > $filename	
	
		#move temporany file into original directory
		mv $filename $HOME_IDS
		rm /tmp/idsxx.xml
	else	
		#CREATE SECOND FILE IDS
		#delete the first three rows
                sed -i '1,3d' $filename

                #delete tags <id> and </id>
                sed -i -e 's/<id>//g' -e 's/<\/id>//g' $filename

                #inversion file and delete the first three rows
                tac $filename > /tmp/ids_newxx.xml
                sed -i '1,2d' /tmp/ids_newxx.xml
         	tac /tmp/ids_newxx.xml > $filename

                #move temporany file into original directory
                mv $filename $HOME_IDS
                rm /tmp/ids_newxx.xml
	fi
}

download_ids_list() {

	if [ -f $HOME/.defollownotify/ids.xml ]; then
 		curl -o /tmp/ids_new.xml "https://api.twitter.com/1/followers/ids.xml?cursor=-1&screen_name=$USER_NAME"
		local next_cursor=$(grep "<next_cursor>" /tmp/ids_new.xml | sed -e 's/<next_cursor>//g' -e 's/<\/next.*//g') #GET NEXT_CURSOR
		if [ $next_cursor -eq 0 ]; then
			create_ids "/tmp/ids_new.xml"
			compare_ids
		else
			echo "The number of follower >5000. The function has not implemented!"
			exit 1
		fi
        else
                curl -o /tmp/ids.xml "https://api.twitter.com/1/followers/ids.xml?cursor=-1&screen_name=$USER_NAME"
		local next_cursor=$(grep "<next_cursor>" /tmp/ids.xml | sed -e 's/<next_cursor>//g' -e 's/<\/next.*//g') #GET NEXT_CURSOR
		if [ $next_cursor -eq 0 ]; then
			create_ids "/tmp/ids.xml"
		else
			echo "The number of follower >5000. The function has not implemented!"
			exit 1
        	fi
	fi
}


notify_me() {

	lenght=${#screen_name[@]}
	echo ""
	for index in $(seq 0 $lenght); do
		if [ -z ${screen_name[$index]} ]; then exit 0; fi

		#TO_statuses_update '' "News for @$USER_NAME: The user [ @${screen_name[$index]} ] not following you more." ""
		echo "News for @$USER_NAME: The user [ @${screen_name[$index]} ] not following you more."
	done

}


load_config
download_ids_list
notify_me

exit 0
