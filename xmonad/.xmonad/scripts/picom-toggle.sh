#!/bin/bash
if pgrep -x "picom" > /dev/null
then
	killall picom
else
	picom -b --experimental-backend --config ~/.xmonad/scripts/picom.conf
fi
