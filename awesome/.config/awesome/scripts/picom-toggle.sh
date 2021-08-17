#!/bin/bash
if pgrep -x "picom" >/dev/null; then
  killall picom
else
  picom -b --experimental-backends --config ~/.config/awesome/picom.conf
fi
