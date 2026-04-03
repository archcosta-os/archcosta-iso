#!/bin/sh
# ArchCosta bspwm Power Menu

choice=$(printf "Lock\nLogout\nSuspend\nReboot\nShutdown" | rofi -dmenu -p "Power" -i)

case "$choice" in
    Lock)     i3lock -c 1a1a2e ;;
    Logout)   bspc quit ;;
    Suspend)  systemctl suspend ;;
    Reboot)   systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
