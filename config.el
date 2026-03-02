;;; config.el -*- lexical-binding: t; -*-

(setq user-full-name "kr0n" user-mail-address "")

;; Fuentes iA Writer
(setq doom-font (font-spec :family "iA Writer Mono S" :size 18)
      doom-variable-pitch-font (font-spec :family "iA Writer Quattro S" :size 18))

;; Tema
(add-to-list 'custom-theme-load-path "~/.config/doom/themes")
(setq doom-theme 'doom-zen-writer)

;; Números de línea relativos
(setq display-line-numbers-type t)

;; Org core
(setq org-directory "~/novela/")
(setq org-hide-emphasis-markers t)
(setq org-hide-leading-stars t)
(setq org-startup-indented t)
(setq org-startup-folded 'overview)
(setq org-use-sub-superscripts nil)

;; Em-dashes via prettify
(add-hook 'org-mode-hook
  (lambda ()
    (push '("---" . ?—) prettify-symbols-alist)
    (push '("--" . ?–) prettify-symbols-alist)
    (push '("->" . ?→) prettify-symbols-alist)
    (setq prettify-symbols-unprettify-at-point t)
    (prettify-symbols-mode +1)))

;; Smart quotes
(add-hook 'org-mode-hook #'electric-quote-local-mode)

;; Encabezados grandes en Georgia
(custom-set-faces!
  '(org-level-1 :height 2.0 :weight bold   :family "Georgia")
  '(org-level-2 :height 1.7 :weight bold   :family "Georgia")
  '(org-level-3 :height 1.4 :weight normal :family "Georgia")
  '(org-level-4 :height 1.2 :weight normal :family "Georgia"))

;; Bullets bonitos
(use-package! org-superstar
  :hook (org-mode . org-superstar-mode))

;; org-appear: markup visible solo al editar
(use-package! org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autolinks t
        org-appear-autosubmarkers t))

;; Escritura centrada
(setq olivetti-body-width 80)
(add-hook 'org-mode-hook #'olivetti-mode)
(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'org-mode-hook #'hl-sentence-mode)

;; Treemacs
(after! treemacs
  (setq treemacs-width 30))

;; Borrar no machaca el clipboard
(defun bb/evil-delete (orig-fn beg end &optional type _ &rest args)
  (apply orig-fn beg end type ?_ args))
(advice-add 'evil-delete :around 'bb/evil-delete)

;; Corrector español
(setq ispell-dictionary "spanish")

;; Evita que SPC f r salte al workspace donde el buffer ya estaba abierto
(setq persp-when-kill-switch-to-buffer-in-perspective nil)

;; Tabs — gestionados por el módulo :ui tabs de Doom
;; que ya integra persp-mode para aislar buffers por workspace
(after! centaur-tabs
  (setq centaur-tabs-style "wave"
        centaur-tabs-height 28
        centaur-tabs-set-icons t
        centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker "●")
  (centaur-tabs-group-by-projectile-project))

(map! :after centaur-tabs
      :map evil-normal-state-map
      "g t" #'centaur-tabs-forward
      "g T" #'centaur-tabs-backward)


;; Añade contador de palabras al modeline de Doom en org-mode
(add-hook 'org-mode-hook
  (lambda ()
    (wc-mode 1)
    (wc-count)  ;; fuerza conteo inmediato
    (setq-local header-line-format
          '((:eval (when (and wc-mode wc-orig-words)
                     (format "📝 %d palabras" wc-orig-words)))))))


(defun my/org-update-wordcount ()
  (when (eq major-mode 'org-mode)
    (org-map-entries
     (lambda ()
       (let* ((element (org-element-at-point))
              (beg (org-element-property :contents-begin element))
              (end (org-element-property :contents-end element))
              (text (if (and beg end (> end beg))
                        (replace-regexp-in-string
                         ":.*?:.*\n" ""
                         (buffer-substring-no-properties beg end))
                      ""))
              (words (length (split-string text "\\W+" t))))
         (org-set-property "PALABRAS" (number-to-string words))))
     "LEVEL=2" 'file)))

(add-hook 'org-mode-hook
  (lambda ()
    (add-hook 'before-save-hook #'my/org-update-wordcount nil t)))


;; Zen writer
(load! "zen-writer.el")
