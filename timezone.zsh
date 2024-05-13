#!/bin/zsh

# Name: setTimezone.zsh
# Created By: VARE Consulting
# Version: 1.0.0
#
# Requires: swiftDialog and elevated access
#
# Desciption: 
#   This script utilizes swiftDialog to prompt the
#   current user to select a timezone from the drop-down menu.
#
#   Additional timezone values can be found by running the
#   `systemsetup -listtimezones` command.

if [[ ! -e /usr/local/bin/dialog ]]; then
    print "Please install swiftDialog first!"
    exit 1
fi

declare -A timezones=(
    ["[-4] Eastern"]="America/New_York" ["[-5] Central"]="America/Chicago"
    ["[-6] Mountain"]="America/Denver" ["[-7] Pacific"]="America/Los_Angeles"
    # ["Central European"]="Europe/Paris" ["Eastern European"]="Europe/Kyiv"
    # ["Gulf Standard"]="Asia/Dubai" ["Arabian Standard"]="Europe/Moscow"
)

print "Prompting user to select timezone ..."
promptOutput=$(
    /usr/local/bin/dialog \
    --moveable \
    --ontop \
    --title none \
    --icon "SF=clock,palette=green" \
    --centericon \
    --message "Select a timezone from the drop-down menu below." \
    --messagealignment "center" \
    --messageposition "center" \
    --selecttitle "Timezones,required" \
    --selectvalues "${(kj;,;)timezones}" \
    --button1text "Set" \
    --button2text "Quit" \
    --infotext "1.0.0" \
    --width 450 \
    --height 400
)
promptResults=$?

if [[ $promptResults -eq 0 ]]; then
    selectedTimezone=$(grep SelectedOption <<< "${promptOutput}" | awk -F' : ' '//{print $NF}' | sed 's/\"//g')
    print "User selected the \"${selectedTimezone}\" timezone."
    
    for k v in ${(kv)timezones}; do if [[ $k == $selectedTimezone ]]; then timezoneCode="${v}" ; fi; done
    print "Attempting to set timezone to \"${timezoneCode}\" ..."
    
    commandResults=$(/usr/sbin/systemsetup -settimezone "${timezoneCode}" 2> /dev/null | awk -F': ' '//{print $NF}')
    if [[ $timezoneCode == $commandResults ]]; then 
        print "Successfully set timezone to \"${timezoneCode}\" !!!"
        exit 0
    else
        print "Unable to set timezone to \"${timezoneCode}\" !!!"
        exit 1
    fi
else
    print "User selected to quit utility."
fi
exit 0