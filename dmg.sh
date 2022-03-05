#!/usr/bin/env bash

if [ ! -d "$1" ]; then
	printf "ERROR: '%s' must be a directory containing the target .app\n" "$1"
	exit 1
fi

SHORT_NAME="Sunflower"
FULL_NAME="${SHORT_NAME}.app"

create-dmg --volname "$SHORT_NAME" --window-pos 200 120 --window-size 800 400 --icon-size 100 --icon "$FULL_NAME" 200 190 --format UDBZ --hide-extension "$FULL_NAME" --app-drop-link 600 185 --no-internet-enable "$(dirname "$1")/${SHORT_NAME}.dmg" "$1"