#!/usr/bin/env bash

#: Creates a dmg from the exported Sunflower app bundle
#: 
#: PRECONDITIONS: 
#:		1) You have installed homebrew create-dmg
#:
#: ARGUMENTS:
#: 		$1 - The directory containing the Sunflower.app
#: 
#: Author: Fastily

if [ $# -lt 1 ] || [ ! -d "$1" ]; then
	printf "Usage: %s <PATH_TO_DIR_WITH_SUNFLOWER_APP>\n" "${0##*/}"
	exit 1
fi

SHORT_NAME="Sunflower"
FULL_NAME="${SHORT_NAME}.app"

create-dmg --volname "$SHORT_NAME" --window-pos 200 120 --window-size 800 400 --icon-size 100 --icon "$FULL_NAME" 200 190 --format UDBZ --hide-extension "$FULL_NAME" --app-drop-link 600 185 --no-internet-enable "$(dirname "$1")/${SHORT_NAME}.dmg" "$1"