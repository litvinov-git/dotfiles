#!/bin/bash

#==================================================================]
#  CONFIGURATION                                                   |
#==================================================================]

#Here you have to configure your menu and its pin entry mode
#       
#   1. menu(): type here the command you would launch your menu 
#      with "$1" as placeholder/prompt.
#
#   2. pin_menu(): type here the command to launch your menu in
#      pin entry mode (masking the input with "*", or simply
#      hiding it). If you do not care about the password being
#      visible while you type it, simply make menu_pin your regular
#      menu command.


menu() {
	fuzzel --dmenu --placeholder="$1"
}

menu_pin() {
	fuzzel --dmenu --password='*' --placeholder="Password"
}


#==================================================================]
#  FUNCTIONS                                                       |
#==================================================================]


#Format a network entry properly, get the icon
format_entry() {
	local entry=$1
	local formatted
	local signal_level
	local ssid
	local icon
	
	signal_level="${entry##*:}"
	if [ "$signal_level" -lt "85" ]; then
		if [ "$signal_level" -lt "60" ]; then
			if [ "$signal_level" -lt "25" ]; then
				icon="󰤟"
			else
				icon="󰤢"
			fi
		else
			icon="󰤥"
		fi
	elif [ "$signal_level" -gt "84" ]; then
		icon="󰤨"
	else
		icon="󰤭"
	fi
	
	ssid="${entry%:*}"
	
	if [[ -n "$ssid" ]]; then
		formatted="$icon $ssid"
	else
		formatted=""
	fi
	
	echo "$formatted"
}


#Convert the list from SSID:SIGNAL_LEVEL to SIGNAL_ICON SSID
format_list() {
	local initial_list=$1
	local new_list=""
	local formatted
	readarray -t entries <<< "$initial_list"
	for entry in "${entries[@]}"; do
		formatted="$(format_entry "$entry")"
		if [[ -n "$formatted" ]]; then
			new_list="$new_list"$'\n'"$formatted"
		fi
	done
	new_list="${new_list#$'\n'}"
	echo "$new_list"
}


#Connect to a network
connect() {
	local ssid=$1
	local rc
	if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
		notify-send "Connecting..." -t 1800
		nmcli connection up "$ssid"
		rc=$?
	else
		local security=$(nmcli -t -f SSID,SECURITY dev wifi list | awk -F: -v s="$ssid" '$1==s {print $2; exit}')

		if [[ -z "$security" ]]; then
			notify-send "Connecting..." -t 1800
			nmcli device wifi connect "$ssid"
			rc=$?
		else
			local password=$(printf "Cancel" | menu_pin)
			if [[ "$password" == "Cancel"  || -z "$password" ]]; then
				rc=1
			else
				notify-send "Connecting..." -t 1800
				nmcli --wait 7 device wifi connect "$ssid" password "$password"
				rc=$?
			fi
		fi
	fi
	
	if (( $rc == 0 )); then
		notify-send "Connected:D" -t 1800
		exit 0
	elif (( $rc ==1 )); then
		exit 0
	else
		notify-send "Failed(" -t 1800
		handle_failed $ssid
	fi
}


#Connect with no timeout
connect_no_timeout() {
	local ssid=$1
	local rc
	if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
		notify-send "Connecting..." -t 1800
		nmcli connection up "$ssid"
		rc=$?
	else
		local security=$(nmcli -t -f SSID,SECURITY dev wifi list | awk -F: -v s="$ssid" '$1==s {print $2; exit}')

		if [[ -z "$security" ]]; then
			notify-send "Connecting..." -t 1800
			nmcli device wifi connect "$ssid"
			rc=$?
		else
			local password=$(printf "Cancel" | menu_pin)
			if [[ "$password" == "Cancel"  || -z "$password" ]]; then
				rc=1
			else
				notify-send "Connecting..." -t 1800
				nmcli device wifi connect "$ssid" password "$password"
				rc=$?
			fi
		fi
	fi
	
	if (( $rc == 0 )); then
		notify-send "Connected:D" -t 1800
		exit 0
	elif (( $rc ==1 )); then
		exit 0
	else
		notify-send "Failed(" -t 1800
		handle_failed $ssid
	fi
}


#If the chosen network is the active one
handle_active() {
	local ssid=$1
	local selection=$(printf "Edit\nDisconnect\nForget" | menu "$ssid")
	#selection="${selection:2}"
	case $selection in
		Edit) nm-connection-editor -e "$(nmcli -t -f NAME,UUID connection show | grep "^$ssid:" | cut -d: -f2)";;
		Disconnect) nmcli connection down "$ssid";;
		Forget) nmcli connection delete "$ssid";; 
        "") main;;
	esac
}


#If the chosen network is profiled (memorized) but not active
handle_profiled() {
	local ssid=$1
	local selection=$(printf "Connect\nEdit\nForget" | menu "$ssid")
	case $selection in
		Connect) connect "$ssid";;
		Edit) nm-connection-editor -e "$(nmcli -t -f NAME,UUID connection show | grep "^$ssid:" | cut -d: -f2)";;
		Forget) nmcli connection delete "$ssid";; 
        "") main;;
	esac
}


#Failed connection menu
handle_failed() {
	local ssid=$1
	selection=$(printf "Retry\nForget\nRetry - no timeout\nExit" | menu "$ssid")
	case $selection in
		Retry)
			connect "$ssid"
		;;
		Forget)
			nmcli connection delete "$ssid"
			handle_failed "$ssid"
		;;
		"Retry - no timeout")
			connect_no_timeout "$ssid"
		;;
		Exit) exit 0;; 
        "") main;;

	esac	
}


#If the chosen tenwork is not profiled
handle_new() {
	local ssid=$1
	connect "$ssid"
}

#View saved conneections
view_profiles() {
	local profiles=$(nmcli -t -f NAME connection show | sed '/^$/d' | sort -u | grep -v "^lo$")
	#profiles=$(form_list $profiles)
	local selection=$(echo "$profiles" | menu "Saved connections")
	if [ "$selection" = "$active" ]; then
		handle_active "$active"
	elif [[ -z "$selection" ]]; then
		main
	else
		handle_profiled "$selection"
	fi
}

#Get nmcli (network controller) data from cash
scan() {
    active="$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi list --rescan no | grep '^yes')"
    list=$(nmcli -t -f SSID,SIGNAL dev wifi list --rescan no)
}    


#Rescan
rescan() {
    notify-send "Scanning..." -t 1200
    list=$(nmcli -t -f SSID,SIGNAL dev wifi list --rescan yes)
    active="$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi list --rescan no | grep '^yes')"
    
}    


#Format all data for the main menu
format_all() {
    active=${active:4}
    active=$(format_entry "$active")
    list=$(format_list "$list")

    #Add saved profiles option to the ,enu input
    list="--Saved connections"$'\n'"$list"

    #Add rescan option to the menu input
    list="--Rescan"$'\n'"$list"
}


#Check if connected, form the prompt for the main menu
check_connection() {
	if [ -z "$active" ]; then
		prompt="Not connected"
		connected=false
	else
		prompt="Connected:"
		connected=true
		list=$(echo "$list" | grep -v "$active")
		list="$active <"$'\n'"$list"
	fi
}


#Spawn and process the main menu
main() {
	#Launch menu, get choice
	choice=$(echo "$list" | menu "$prompt")
	
	
	#Handle choice
	if [ "$choice" = "$active <" ]; then
		handle_active "${active:2}"
	elif [[ -z "$choice" ]]; then
		exit 0
	elif [ "$choice" = "--Rescan" ]; then
		rescan
        format_all
        check_connection
        main
	elif [ "$choice" = "--Saved connections" ]; then
		view_profiles
	elif nmcli -t -f NAME connection show | grep -Fxq "${choice:2}"; then
		handle_profiled "${choice:2}"
	else
		handle_new "${choice:2}"
	fi
}



#==================================================================]
#  MAIN                                                            |
#==================================================================]


nmcli device wifi rescan & disown #Rescan available networks in the background

scan
format_all
check_connection
main

exit 0
