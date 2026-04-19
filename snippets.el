;;
;; Workspace and buffers attached
(after! persp-mode
  (setq persp-add-buffer-on-find-file t)
  (setq persp-add-buffer-on-after-change-major-mode 'free)

  ;; Buffers with no workspace (system buffers)
  (setq persp-filter-save-buffers-functions
        (list (lambda (b) (string-prefix-p " " (buffer-name b)))))

  ;; Org files go to "org" workspace SOLO si no están ya en uno
  (add-hook 'org-mode-hook
    (lambda ()
      (when (and (buffer-file-name)
                 (not (persp-contain-buffer-p (current-buffer))))
        (persp-add-buffer (current-buffer)
          (persp-get-by-name "org" *persp-hash* :nil)))))

  ;; Doom config files go to "config" workspace SOLO si no están ya en uno
  (add-hook 'emacs-lisp-mode-hook
    (lambda ()
      (when (and (buffer-file-name)
                 (string-match-p (regexp-quote doom-user-dir) (buffer-file-name))
                 (not (persp-contain-buffer-p (current-buffer))))
        (persp-add-buffer (current-buffer)
          (persp-get-by-name "config" *persp-hash* :nil))))))

(after! persp-mode
  (add-hook 'persp-mode-hook
    (lambda ()
      (+workspace/new "org")
      (+workspace/new "config")
      (+workspace/switch-to 0))))


;;
;; SPC b N → nuevo buffer en el workspace actual (no crea workspace nuevo)
(defun my/new-buffer-current-workspace ()
  "Crea un buffer vacío en el workspace actual."
  (interactive)
  (let* ((buf (generate-new-buffer "*new*"))
         (persp (get-current-persp)))
    (persp-add-buffer buf persp t)))

(map! :leader
      :desc "New buffer (workspace actual)"
      "b N" #'my/new-buffer-current-workspace)
