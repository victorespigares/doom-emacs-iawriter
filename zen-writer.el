;;; zen-writer.el -*- lexical-binding: t; -*-

(defun y/zen ()
  (interactive)
  (setq doom-theme 'doom-zen-writer)
  (load-theme doom-theme t)
  (hl-sentence-mode +1))

(defun y/unzen ()
  (interactive)
  (setq doom-theme 'doom-one)
  (load-theme doom-theme t)
  (hl-sentence-mode -1))

(defun y/zen-full ()
  (interactive)
  (y/zen)
  (toggle-frame-fullscreen))

(defun y/unzen-full ()
  (interactive)
  (y/unzen)
  (toggle-frame-fullscreen))


(map! :leader
      (:prefix ("y z" . "Zen Writer")
       :desc "Full Zen Writer"   "z" #'y/zen-full
       :desc "un-Full Zen Writer" "u" #'y/unzen-full
       :desc "Zen Writer"        "t" #'y/zen
       :desc "un-Zen Writer"     "q" #'y/unzen))

