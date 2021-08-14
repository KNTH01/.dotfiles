#!/bin/bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

# load the config file from arandr
run $HOME/.screenlayout/init.sh &

# keyboard layout
setxkbmap -layout us,us -variant ,intl -option 'grp:alt_space_toggle'

# polybar
# (sleep 2; run $HOME/.config/polybar/launch.sh) &

### Arco Linux default
run nm-applet
#run caffeine
run pamac-tray
run variety
run xfce4-power-manager
run blueberry-tray
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
run numlockx on
run volumeicon
#run nitrogen --restore
run conky -c $HOME/.config/awesome/system-overview

### My runs
run imwheel
run liquidctl initialize all # NZXT smart device v2 config
