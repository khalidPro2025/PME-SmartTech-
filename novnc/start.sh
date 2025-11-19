#!/bin/bash

export DISPLAY=:1

# Launch virtual framebuffer
Xvfb :1 -screen 0 1280x720x16 &
sleep 2

# Disable power manager completely
export XDG_CURRENT_DESKTOP=XFCE
export XFCE_DISABLE_UPDATES=1

# Start XFCE (no power manager)
xfce4-session &
sleep 2

# Start VNC
x11vnc -display :1 -forever -shared -bg -usepw -rfbport 5900 -noxdamage &

# Launch noVNC
websockify --web /usr/share/novnc/ 6080 localhost:5900 &

echo "------------------------------------------"
echo " NoVNC READY"
echo " URL : http://localhost:6080/vnc.html"
echo " Password : vncPass123!"
echo "------------------------------------------"

# Keep running
tail -f /dev/null
