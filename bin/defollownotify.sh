#!/bin/bash -x

###############################################################################
# @Author : Ennio Giliberto aka Lightuono / Toshidex
# @Implemented by : Domenico Luciani aka DLion
# @Name : Defollow Notify
# @Copyright : 2012
# @Site : http://www.toshidex.org
# @Site : http://about.me/dlion
# @License : GNU AGPL v3 http://www.gnu.org/licenses/agpl.html
###############################################################################

DFN_RC="/usr/local/src/defollownotify/defollownotify.rc"
OAuth_sh=$(which TwitterOAuth.sh)
HOME_IDS="$HOME/.defollownotify"
screen_name=()

(( $? != 0 )) && echo 'Unable to locate TwitterOAuth.sh! Make sure it is in searching PATH.' && exit 1
source "$OAuth_sh"


usage(){

	cat << "USAGE"
        
Use: defollownotify [OPTION]
        
   -B      	Enable Bastard Mode - Notification via Twitter

   -N @user 	Send a notify of defollow at the @user

   -v	   	Print Version

* If you want uninstall defollownotify you have to run /usr/local/src/defollownotify/uninstall.sh
USAGE

}


load_config() {
	
	[[ ! -d "$HOME/.defollownotify" ]] && mkdir $HOME/.defollownotify
	
	[[ -f "$DFN_RC" ]] && . "$DFN_RC" || echo -e "\n defollownotify.rc: File not found!\n $(exit)"
	
	[[ "$oauth_consumer_key" == "" ]] && echo -e "\n The variable [ oauth_consumer_key ] not found!\n" && exit 1
        [[ "$oauth_consumer_secret" == "" ]] && echo -e "\n The variable [ oauth_consumer_secret ] not found!\n" && exit 1
	[[ "$USER_NAME" == "" ]] && echo -e "\n You have not insert an account Twitter!\n" && exit 1
	[[ ! ("$BASTARD_MODE" == "TRUE" || "$BASTARD_MODE" == "FALSE") ]] && echo -e "\n You have not insert an value BOOLEAN (TRUE|FALSE)!\n" && exit 1

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


print_error() {

    if [[ ! -z $1 ]]; then
        echo -e "\e[0;1;31m\n*ERROR: $1\e[m\n"
        exit 1
    fi
}

convert_ids() {

	name=$(curl -s "https://api.twitter.com/1.1/users/show.xml?user_id=$1" | grep "<screen_name>" | sed -e 's/<screen_name>//g' -e 's/<\/scre.*//g' -e 's/  //g')

	qualcosa | grep -Eo "screen_name\":\"[[:alpha:]]*" | head -1 | awk -F '"' '{print $3}'
	#if [[ "$name" == "" ]]; then
#		echo -e "\e[0;1;34mUser [\e[m\e[0;1;31m $1 \e[m\e[0;1;34m] not found.\n\e[m" 
#		return
#	fi
    
    if [[ $2 == 1 ]]; then
        screen_name_follow=(${screen_name_follow[@]} $name )
    else
        screen_name_defollow=( ${screen_name_defollow[@]} $name )	
    fi
}

compare_ids() {

	list_defollow="$(diff $HOME_IDS/list_ids $HOME_IDS/list_ids_new | grep "<" | awk -F'<| ' '{ print $3}')"
	list_follow="$(diff $HOME_IDS/list_ids $HOME_IDS/list_ids_new | grep ">" | awk -F'>| ' '{ print $3}')"
    	NUM_FOLLOW=$(echo "$list_follow" | wc -w)
    	NUM_DEFOLLOW=$(echo "$list_defollow" | wc -w)

    echo -e "\n* Info Diff:"
	echo -e "       \e[0;1;34m - New Follower: $NUM_FOLLOW \e[m"
	echo -e "       \e[0;1;32m - New Defollow: $NUM_DEFOLLOW \e[m"
    

	if [[ $list_defollow == "" && $list_follow == "" && $NUM_FOLLOW -eq 0 && $NUM_DEFOLLOW -eq 0 ]]; then
    	echo -n -e "\n* Nothing has changed!\n"
		exit 0
    else
		echo -e "\n* Conversion ID to Nickname: \n"
		if [[ ! $NUM_FOLLOW == "0" ]]; then
            i=0
            for ids_index in $list_follow; do
                convert_ids "$ids_index" 1
                echo -e -n "$((++i)).."
            done
        fi
        
        if [[ ! $NUM_DEFOLLOW == "0" ]]; then
		    for ids_index in $list_defollow; do
			    convert_ids "$ids_index" 2
			    echo -n "$((++i)).."	
            done
        fi
		
		echo -n -e "\nConversion completed!\n"
    fi
    
    mv $HOME_IDS/list_ids_new $HOME_IDS/list_ids

}

#create_ids() {

#	filename="$1"

#	if [[ $filename == "/tmp/ids.xml" ]]; then
			
		#delete the first three rows
#		sed -i '1,3d' $filename

		#delete tags <id> and </id>
#		sed -i -e 's/ *<id>//g' -e 's/<\/id>//g' $filename

		#inversion file and delete the first three rows
#		tac $filename > /tmp/idsxx.xml
#		sed -i '1,4d' /tmp/idsxx.xml
#		tac /tmp/idsxx.xml > $filename	
	
		#move temporany file into original directory
#		mv $filename $HOME_IDS
#		rm /tmp/idsxx.xml
#	else	
		#CREATE SECOND FILE IDS
		#delete the first three rows
 #       sed -i '1,3d' $filename

        #delete tags <id> and </id>
  #      sed -i -e 's/ *<id>//g' -e 's/<\/id>//g' $filename

        #inversion file and delete the first three rows
   #     tac $filename > /tmp/ids_newxx.xml
   #     sed -i '1,4d' /tmp/ids_newxx.xml
   #     tac /tmp/ids_newxx.xml > $filename

        #move temporany file into original directory
    #    mv $filename $HOME_IDS
    #    rm /tmp/ids_newxx.xml
#	fi
#}

download_ids_list_new () {


	
	if [ -f $HOME/.defollownotify/list_ids ]; then
		echo -e "\n* Download ids list.."
		TO_get_followers_ids "$USER_NAME" "5000"
		echo $TO_ret

		echo $TO_ret | awk -F']' '{print $1}' | awk -F'[' '{print $2}' | tr ',' '\n' > /tmp/list_ids_new
		
		cp /tmp/list_ids_new $HOME_IDS
	
		compare_ids

	else
		
		echo -e "\n* Download ids list.."
		TO_get_followers_ids "$USER_NAME" "5000"
		echo $TO_ret

		echo $TO_ret | awk -F']' '{print $1}' | awk -F'[' '{print $2}' | tr ',' '\n' > /tmp/list_ids
		cp /tmp/list_ids $HOME_IDS
		#rm /tmp/list_ids

		
		#print_error $(grep "<error>" /tmp/ids.xml | sed -e 's/<error>//g' -e 's/<\/err.*//g') #GET ERROR
	
		#local next_cursor=$(grep "<next_cursor>" /tmp/ids.xml | sed -e 's/<next_cursor>//g' -e 's/<\/next.*//g') #GET NEXT_CURSOR
		
	        #if [ $next_cursor -eq 0 ]; then
		#	create_ids "/tmp/ids.xml"
		#else
		#	echo "The number of follower >5000. The function has not implemented!"
		#	exit 1
        #fi
    fi

}


download_ids_list() {

	if [ -f $HOME/.defollownotify/ids.xml ]; then
		echo -e "\n* Download ids list.."
 		curl -s -o /tmp/ids_new.xml "https://api.twitter.com/1.1/followers/ids.xml?cursor=-1&screen_name=$USER_NAME"
		print_error $(grep "<error>" /tmp/ids_new.xml | sed -e 's/<error>//g' -e 's/<\/err.*//g') #GET ERROR
		local next_cursor=$(grep "<next_cursor>" /tmp/ids_new.xml | sed -e 's/<next_cursor>//g' -e 's/<\/next.*//g') #GET NEXT_CURSOR
		
        if [ $next_cursor -eq 0 ]; then
			create_ids "/tmp/ids_new.xml"
			compare_ids
		else
			echo "The number of follower >5000. The function has not implemented!"
			exit 1
		fi
        
    else
		echo -e "\n* Download ids list.."
        curl -s -o /tmp/ids.xml "https://api.twitter.com/1.1/followers/ids.xml?cursor=-1&screen_name=$USER_NAME"
		
		print_error $(grep "<error>" /tmp/ids.xml | sed -e 's/<error>//g' -e 's/<\/err.*//g') #GET ERROR
	
		local next_cursor=$(grep "<next_cursor>" /tmp/ids.xml | sed -e 's/<next_cursor>//g' -e 's/<\/next.*//g') #GET NEXT_CURSOR
		
        if [ $next_cursor -eq 0 ]; then
			create_ids "/tmp/ids.xml"
		else
			echo "The number of follower >5000. The function has not implemented!"
			exit 1
        fi
    fi
}

revenge() 
{
    if [[ $(echo "$1" | egrep "^@") != "" ]]; then
        TO_statuses_update '' "News for @$USER_NAME: The user [ $1 ] not following you more. http://t.co/RfXKjgbU" ""   
        echo "Notify Send!"
    else
        print_error "Define an user to notify"
    fi 
}

notify_me() {

    if [[ $OPTION_N == "TRUE" ]]; then
	TO_statuses_update '' "News for @$USER_NAME: The user [ @$OPTARG ] not following you more. http://t.co/RfXKjgbU" ""
        echo -e "\e[0;1;34m$((++i)). [\e[m\e[0;1;31m@${OPTARG}\e[m\e[0;1;34m] not following you more. Notification sent! [\e[m\e[0;1;31m http://twitter.com/${OPTARG}\e[m\e[0;1;34m ]\e[m"
	exit 0
    fi

    let "lenght_follow=${#screen_name_follow[@]}-1"
    let "lenght_defollow=${#screen_name_defollow[@]}-1"
    local i=0

    if [ ! $lenght_follow -lt 0 ]; then
        echo -e "\n"
        for index in $(seq 0 $lenght_follow); do
            echo -e "\e[0;1;34m$((++i)). [\e[m\e[0;1;31m@${screen_name_follow[$index]}\e[m\e[0;1;34m] follow you! [\e[m\e[0;1;31m http://twitter.com/${screen_name_follow[$index]}\e[m\e[0;1;34m ]\e[m\n"
        done
    fi
    
    if [ ! $lenght_defollow -lt 0 ]; then
         i=0
        echo -e "\n"
        for index in $(seq 0 $lenght_defollow); do
		    if [[ $BASTARD_MODE == "TRUE" ]]; then
			    revenge "@${screen_name_defollow[$index]}"
			    echo -e "\e[0;1;34m$((++i)). [\e[m\e[0;1;31m@${screen_name_defollow[$index]}\e[m\e[0;1;34m] not following you more. Notification sent! [\e[m\e[0;1;31m http://twitter.com/${screen_name_defollow[$index]}\e[m\e[0;1;34m ]\e[m"
		    else
			    echo -e "\e[0;1;34m$((++i)). [\e[m\e[0;1;31m@${screen_name_defollow[$index]}\e[m\e[0;1;34m] not following you more! [\e[m\e[0;1;31m http://twitter.com/${screen_name_defollow[$index]}\e[m\e[0;1;34m ]\e[m"
            fi
        done
    fi
}


load_config

while getopts "Bvh:N:" opt; do
	case $opt in
		"B")
			BASTARD_MODE="TRUE"
		;;
		"N")
			OPTION_N="TRUE"
			notify_me $OPTARG
			exit 0			
		;;
		"v")
			echo -e "\nDefollowNotify - $(cat /usr/local/src/defollownotify/VERSION) \n";
			exit 0
		;;
		"h")
			usage
			exit 0
		;;
		\?)
			usage
			exit 0
		;;
	esac
done


TO_get_users_show "toshidex" "101792150"


#download_ids_list_new
#download_ids_list
#notify_me

exit 0
