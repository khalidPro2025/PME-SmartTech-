#!/bin/bash

export DISPLAY=:1

# Virtual screen
Xvfb :1 -screen 0 1280x720x16 &
sleep 2

# Start Openbox
openbox-session &
sleep 1

# Start tint2 panel
tint2 &

# Start VNC
x11vnc -display :1 -forever -shared -bg -usepw -rfbport 5900 &

# Start NoVNC
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

echo "NoVNC Running : http://localhost:6080/vnc.html"
tail -f /dev/null
