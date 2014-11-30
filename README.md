# Helm - Google Music Player

This is a music player for All Access Google Music subscribers via the 
[Emacs/Helm](https://github.com/emacs-helm/helm) interface. I got my
motivation from the very nice example provided for a
[Helm Spotify Interface](https://github.com/krisajenkins/helm-spotify).

Currently I only have a search for artist method and then select track
feature but I hope to add more methods soon. GMusicProxy is not able
to search for information and play tracks at the same time so
currently this program is limited (cannot search while track is playing...).

*I have only tested this on Ubuntu 14.10 but theoretically it should
 work with other Operating Systems as well*

## (non-Emacs) Dependencies
 - GMusicProxy (make sure to have configuration file setup in `~/.profile/`
 - VLC Player

 All of these dependencies are available on all platforms.
