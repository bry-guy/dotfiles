#!/bin/bash

WIDTH=${1:-1920}
HEIGHT=${2:-1200}
OUTPUT=${3:-DP-0}
nvidia-settings --assign CurrentMetaMode="$OUTPUT: 3440x1440_120 +0+0 {viewportout=${WIDTH}x${HEIGHT}+0+0}"
sleep 5
/home/brain/pop-tweaks/sunshine/vhclientx86_64 -t "use,braindeck.13"
