#!/bin/sh
while true; do
  sleep 30
  # What network am I on?

  # Get the Active Connection path
  # Result should be like: /org/freedesktop/NetworkManager/ActiveConnection/187
  active_connection_path=$( dbus-send --system --print-reply \
                            --dest=org.freedesktop.NetworkManager \
                            /org/freedesktop/NetworkManager \
                            org.freedesktop.DBus.Properties.Get \
                            string:"org.freedesktop.NetworkManager" \
                            string:"ActiveConnections" \
                            | grep ActiveConnection/ | cut -d'"' -f2 )

  # Get the Access Point path
  # Result should be like: /org/freedesktop/NetworkManager/AccessPoint/194
  access_point_path=$( dbus-send --system --print-reply \
                       --dest=org.freedesktop.NetworkManager \
                       "$active_connection_path" \
                       org.freedesktop.DBus.Properties.Get \
                       string:"org.freedesktop.NetworkManager.Connection.Active" \
                       string:"SpecificObject" \
                       | grep variant | cut -d'"' -f2 )

  # Get the Access Point ESSID
  # Result should be something like "NETGEAR"
  essid=$( dbus-send --system --print-reply \
                     --dest=org.freedesktop.NetworkManager \
                     "$access_point_path" \
                     org.freedesktop.DBus.Properties.Get \
                     string:"org.freedesktop.NetworkManager.AccessPoint" \
                     string:"Ssid" \
                     | grep variant | cut -d'"' -f2 )

  if [ "$state" != "$essid" ]; then
    state="none"
  fi


  # If we are on the WORK network
  if [ "$essid"=="IESOFTEK-A" ] && [ "$state" != "$essid" ]; then
     # Do network-specific changes here
     state=$essid
     notify-send "Work Network: Volume Muted"
     notify-send "Work Network: Notifications Disabled"
     amixer -D pulse set Master off > /dev/null
     gsettings set com.canonical.friends notifications none

  elif [ "$essid"=="IESOFTEK-B" ] && [ "$state" != "$essid" ]; then
     # Do network-specific changes here
     state=$essid
     notify-send "Work Network: Volume Muted"
     notify-send "Work Network: Notifications Disabled"
     amixer -D pulse set Master off > /dev/null
     gsettings set com.canonical.friends notifications none

  elif [ "$essid"=="perluth" ] && [ "$state" != "$essid" ]; then
     # Do network-specific changes here
     state=$essid
     notify-send "Home Network: Audio Enabled"
     notify-send "Home Network: Notifications Enabled"
     amixer -D pulse set Master on > /dev/null
     gsettings set com.canonical.friends notifications all

  else
     # Do changes for unrecognized network or no network at all here
     printf "Dunno"
  fi
done