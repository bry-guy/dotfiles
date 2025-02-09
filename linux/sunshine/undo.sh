#!/bin/bash

# nvidia-settings --assign CurrentMetaMode="DP-0: 3440x1440_120 @4558x1908 +0+0 {Transform=(1.324997,0.000000,0.000000,0.000000,1.324997,0.000000,0.000000,0.000000,1.000000), ViewPortIn=4558x1908, ViewPortOut=3440x1440+0+0, ResamplingMethod=Bilinear}"
nvidia-settings --assign CurrentMetaMode="DP-0: 3440x1440_120 @3440x1440+0+0"
sleep 5
/home/brain/pop-tweaks/sunshine/vhclientx86_64 -t "stop using,braindeck.13"

