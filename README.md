# volume-control

Requires:
* pulseaudio
* a notifications server (I use xfce4-notifyd)
* the Adawaita icons theme

Settings for i3 bindings:
```
bindsym XF86AudioRaiseVolume exec --no-startup-id $HOME/.config/i3/volume-control.sh +10% #increase sound volume
bindsym XF86AudioLowerVolume exec --no-startup-id $HOME/.config/i3/volume-control.sh -10% #decrease sound volume
bindsym XF86AudioMute exec --no-startup-id $HOME/.config/i3/volume-control.sh mute # mute sound
bindsym XF86AudioMicMute exec --no-startup-id $HOME/.config/i3/sound-change.sh micmute # mute mic
```
