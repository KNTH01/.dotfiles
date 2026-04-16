#!/bin/bash

function run {
  if ! pgrep $1; then
    $@ &
  fi
}

# keyboard layout
setxkbmap -layout us,us -variant ,intl -option 'grp:alt_space_toggle'

# start picom
picom -b --config $HOME/.config/awesome/picom.conf

### Arco Linux default
run nm-applet
#run caffeine
run pamac-tray
run xfce4-power-manager
run blueberry-tray
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
run numlockx on
run volumeicon
# run variety
# run conky -c $HOME/.config/awesome/system-overview

### My runs
run imwheel
run copyq
run liquidctl initialize all # NZXT smart device v2 config
run portless start

# load the config file from arandr
#create a weird bug where it display horizontal
(sleep 1; $HOME/.screenlayout/init.sh) &

# mouse speed
$HOME/.config/awesome/scripts/mouse_settings.sh &

# run nitrogen after xrandr
run nitrogen --restore

# polybar
# (sleep 2; $HOME/.config/polybar/launch.sh) &
