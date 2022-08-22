#!/bin/zsh

###################################################################################################
# Created by Jonathan Connor | support@kandji.io | Kandji, Inc.
###################################################################################################
# Created - 2022-07-13

###################################################################################################
# Software Information
###################################################################################################
#
# This Audit and Enforce script is used to ensure that a defined application is installed, and if
# so, checks it against a minimum defined version.
#
###################################################################################################
# License Information
###################################################################################################
# Copyright 2022 Kandji, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
# to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
###################################################################################################

###################################################################################################
########################## USER INPUT - MODIFY THESE VARIABLES ####################################
###################################################################################################

# Define and then look for the app defined in APP_NAME, then checks against the version number
# specified by the version number in the variable $minimum_version
#
# By default, this command looks in /Applications, /System/Applications, and /Library for the
# existance of the app defined in $APP_NAME

#AT THE TOP CHANGE FROM ZSH TO BASH TO MAKE THIS WORK IN KANDJI
#Define Application Name ex: "Chess.app"
APP_NAME="zoom.us.app"

# Potential Installed Locations - if you need to add additional ones, place a space after /Library/,
# then put the full path to where it might be found
installed_path="$(/usr/bin/find /Applications /System/Applications /Library/ -maxdepth 3 -name $APP_NAME 2>/dev/null)"

# Set the minimum version of the app - the CFBundleShortVersionString in the "info.plist" file
# inside the app package - you can get to this file by right-clicking on the app and selecting
# "Show Package Contents"
minimum_version=(5 11 6)

###################################################################################################
################################ LOGIC - DO NOT MODIFY BELOW ######################################
###################################################################################################
IFS=' '
# minimum_version="5.11.6 (9890)"
# read -a strarr <<< "$minimum_version"
# echo $strarr[0]
# echo ${strarr[0]}  
# Validate the path returned in installed_path
if [[ ! -e $installed_path ]] || [[ $APP_NAME != "$(/usr/bin/basename $installed_path)" ]]; then
    /bin/echo "$APP_NAME not installed."
    exit 0
else
    # Get the installed app version
    installed_version=$(/usr/bin/defaults read "$installed_path/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)
    read -a strarr <<< "$installed_version"
    #echo ${strarr[0]} 
    # remove the extra version part of the version
    version=${strarr[0]}
    echo $version
    IFS='.'
    #put installed version into array
    read -a strarr <<< "$version" 
    # echo ${minimum_version[1]}
    counter=0
    for i in "${minimum_version[@]}"
    do
        # echo $counter
        # echo $i
        version=${strarr[$counter]}
        # echo $version 
        if [ $version -lt $i ];
        then
            /bin/echo "Zoom needs to be updated"
            /bin/echo "$APP_NAME version $installed_version is below the minimum required version - initiating upgrade..."
            exit 1
        fi
        let counter++
        #statement(s)
    done
    #If the script does not exit above then zoom is installed and is atleast the minimum version
   /bin/echo "$APP_NAME is installed at \"$installed_path\" and is equal to or greater than the minimum requirements..." 
   exit 0 

    # echo "installed version is: ${strarr[1]}"
    # echo ${strarr[1]}  | sed 's/[()]//g' 
    # comp=$( echo "${strarr[1]}"  | sed 's/(//; s/)//')
    # echo $comp
    # $ans = $( ${strarr[1]}  | sed 's/[()]//g' )
    
    # echo "Min version $minimum_version"

    # Check the version of the app against the minimum version specified
    # if [[ $comp -lt $minimum_version ]]; then

    #     /bin/echo "$APP_NAME version $installed_version is below the minimum required version - initiating upgrade..."
    # exit 1
    # else
    #     /bin/echo "$APP_NAME is installed at \"$installed_path\" and is equal to or greater than the minimum requirements..."
    # exit 0
    # fi
fi