;;; helm-gmusic.el --- Control Gmusic with Helm.
;; Copyright 2014 Christopher Ostrouchov
;;
;; Author: Christopher Ostrouchov <chris.ostrouchov@gmail.com>
;; Maintainer: Christopher Ostrouchov <chris.ostrouchov@gmail.com>
;; Keywords: helm gmusic
;; URL: https://github.com/costrou/helm-gmusic
;; Created: 30th November 2014
;; Version: 0.0.1
;; Package-Requires: ((helm "0.0.0"))

;;; Commentary:
;;
;; A search & play interface for Google Music All Access
;;
;; Currently supports Linux (That I know of) 
;; Requires: GMusicProxy, VLC Player
;;

;;; Code:
(require 'helm)
(require 'url)

(defun gmusic-vlc-command (command)
  "Send COMMAND to vlc music player."
  (shell-command (format "/bin/echo %s | netcat localhost %d" command vlc_port)))

(defun gmusic-pause ()
  "Pause VLC player."
  (gmusic-vlc-command "pause"))

(defun gmusic-play ()
  "Play VLC player."
  (gmusic-vlc-command "play"))

(defun gmusic-next ()
  "Next song in queue VLC player."
  (gmusic-vlc-command "next"))

(defun gmusic-stop ()
  "Stop VLC player."
  (gmusic-vlc-command "stop"))

(defun gmusic-format-track (track)
  "Given a TRACK, return a a formatted string suitable for display."
  (let ((track-name (cdr (assoc 'name track)))
	(track-link (cdr (assoc 'link track))))
    (format "%s - %s" track-name track-link)))
    
(defun gmusic-play-track (track)
  "Get the Spotify app to play the album for this TRACK."
  (gmusic-vlc-command (format "add '%s'" (cdr (assoc 'link track)))))

(defun gmusic-search (artist)
  "Search GMusicProxy for ARTIST."
  (let ((a-url (format "http://localhost:%d/get_by_search?type=artist&artist=%s" gmusicproxy_port artist)))
    (with-current-buffer (url-retrieve-synchronously a-url)
      (goto-char url-http-end-of-headers)
      (beginning-of-line 2)
      (let ((tracks '())
	    (track-name "")
	    (track-link ""))
	(while (not (eobp))
	  (search-forward ",")
	  (set 'track-name (buffer-substring (point) (point-at-eol)))
	  (beginning-of-line 2)
	  (set 'track-link (buffer-substring (point) (point-at-eol)))
	  (beginning-of-line 2)
	  (push `((name . ,track-name) (link . ,track-link)) tracks))
	tracks))))

(defun gmusic-search-formatted (artist)
  "Format output from gusic-search for ARTIST."
  (mapcar (lambda (track)
	    (cons (gmusic-format-track track) track))
	  (gmusic-search artist)))

(defun helm-gmusic-search ()
  "Execute helm-search."
  (gmusic-search-formatted helm-pattern))

(defvar helm-source-gmusic-artist-search
  '((name . "GMusic")
    (volatile)
    (delayed)
    (multiline)
    (requires-pattern . 2)
    (candidates . helm-gmusic-search)
    (action ("Play Track" . gmusic-play-track))))


(defun helm-gmusic-actions-for-track ()
  "Return a list of helm ACTIONS available for this TRACK."
  `(("Show Track Metadata" . (lambda(track) (pp track)))))

(defun helm-gmusic ()
  "Bring up a Google Music search interface in helm."
  (interactive)
  (helm :sources 'helm-source-gmusic-artist-search
	:buffer "*helm-gmusic*"))

(defun gmusic-setup ()
  "Setup Google Music Player."
  (interactive)
  (setq gmusicproxy_port 8000)
  (setq vlc_port 9000)

  (async-shell-command (format "cvlc --intf rc --rc-host localhost:%d &" vlc_port) "*CVLCMusicPlayer*")
  (async-shell-command (format "GMusicProxy -P %d &" gmusicproxy_port) "*GMusicProxy*"))

(provide 'helm-gmusic)
(provide 'gmusic-setup)
;;; helm-gmusic.el ends here
