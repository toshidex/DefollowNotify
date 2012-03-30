#!/bin/bash

###############################################################################
# @Author : Ennio Giliberto aka Lightuono / Toshidex
# @Name : Defollow Notify
# @Copyright : 2012
# @Site : http://www.toshidex.org
# @License : GNU AGPL v3 http://www.gnu.org/licenses/agpl.html
###############################################################################

DFN_RC="/usr/local/src/defollownotify/defollownotify.rcs"


load_config() {

	[[ -f "$DFN_RC" ]] && . "$DFN_RC" || echo -e "\ndefollownotify.rc: File not found!\n $(exit)"
	
	[[ "$oauth_consumer_key" == "" ]] && echo -e "\nThe [ oauth File not found!\n $(exit)"
        [[ "$oauth_consumer_secret" == "" ]] && echo -e "\ndefollownotify.rc: File not found!\n $(exit)"


}

load_config
