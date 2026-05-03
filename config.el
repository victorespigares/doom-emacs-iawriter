;;; config.el -*- lexical-binding: t; -*-

(setq user-full-name "kr0n"
      user-mail-address "")

(setq evil-want-shift-selection t)

(after! evil
  (define-key evil-motion-state-map (kbd "S-<up>")    #'evil-previous-visual-line)
  (define-key evil-motion-state-map (kbd "S-<down>")  #'evil-next-visual-line)
  (define-key evil-motion-state-map (kbd "S-<left>")  #'evil-backward-char)
  (define-key evil-motion-state-map (kbd "S-<right>") #'evil-forward-char))

(setq doom-font (font-spec :family "iA Writer Mono S" :size 18)
      doom-variable-pitch-font (font-spec :family "iA Writer Quattro S" :size 18))

(add-to-list 'custom-theme-load-path "~/.config/doom/themes")
(setq doom-theme 'doom-zen-writer)

;;
;; ─── COLORES DE SINTAXIS GLOBALES ─────────────────────────────────────────────

(after! doom-themes
  (custom-set-faces!
    `(font-lock-keyword-face            :foreground "#C678DD" :weight bold)
    `(font-lock-function-name-face      :foreground "#61AFEF")
    `(font-lock-variable-name-face      :foreground "#E06C75")
    `(font-lock-string-face             :foreground "#98C379")
    `(font-lock-comment-face            :foreground "#5C6370" :slant italic)
    `(font-lock-comment-delimiter-face  :foreground "#5C6370" :slant italic)
    `(font-lock-type-face               :foreground "#E5C07B")
    `(font-lock-constant-face           :foreground "#D19A66")
    `(font-lock-builtin-face            :foreground "#56B6C2")
    `(font-lock-doc-face                :foreground "#5C6370" :slant italic)
    `(font-lock-negation-char-face      :foreground "#F92672")
    `(font-lock-preprocessor-face       :foreground "#C678DD")))

(setq display-line-numbers-type t)
(map! :leader :desc "Toggle line numbers" "t n" #'display-line-numbers-mode)

(setq org-directory "~/novela/")
(setq org-hide-emphasis-markers t)
(setq org-hide-leading-stars t)
(setq org-startup-indented t)
(setq org-startup-folded 'overview)
(setq org-use-sub-superscripts nil)
(setq nerd-icons-font-family "Symbols Nerd Font Mono")

;;
;; ─── FIX 1: exec-path-from-shell DIFERIDO ─────────────────────────────────────
;;
;; En lugar de inicializar en el arranque (lanza un proceso de shell completo),
;; se difiere hasta que Emacs lleva 2 segundos idle tras el arranque.
;; Si ya usas `doom env` este bloque entero puede eliminarse.

(use-package! exec-path-from-shell
  :defer t
  :init
  (add-hook 'emacs-startup-hook
    (lambda ()
      (run-with-idle-timer 2 nil #'exec-path-from-shell-initialize))))



;;
;; ─── MODE FUNCTIONS ───────────────────────────────────────────────────────────

(defun my/writing-mode ()
  "Activa el entorno de escritura en prosa."
  (olivetti-mode 1)
  (visual-line-mode 1)
  (hl-sentence-mode 1)
  (electric-quote-local-mode 1)
  (display-line-numbers-mode -1)
  (wc-mode 1)
  ;; FIX: sin idle timer repetitivo. (:eval ...) en header-line-format
  ;; se re-evalúa tras cada comando automáticamente — no necesita timer.
  (setq-local header-line-format
    '((:eval (format "📝 %d palabras" (my/buffer-word-count))))))

(defun my/flatten-syntax-colors ()
  (let ((fg (face-attribute 'default :foreground nil t)))
    (face-remap-add-relative 'font-lock-keyword-face           :foreground fg :weight 'normal)
    (face-remap-add-relative 'font-lock-function-name-face     :foreground fg)
    (face-remap-add-relative 'font-lock-variable-name-face     :foreground fg)
    (face-remap-add-relative 'font-lock-string-face            :foreground fg)
    (face-remap-add-relative 'font-lock-comment-face           :foreground fg :slant 'normal)
    (face-remap-add-relative 'font-lock-comment-delimiter-face :foreground fg :slant 'normal)
    (face-remap-add-relative 'font-lock-type-face              :foreground fg)
    (face-remap-add-relative 'font-lock-constant-face          :foreground fg)
    (face-remap-add-relative 'font-lock-builtin-face           :foreground fg)
    (face-remap-add-relative 'font-lock-doc-face               :foreground fg :slant 'normal)
    (face-remap-add-relative 'font-lock-preprocessor-face      :foreground fg)
    (face-remap-add-relative 'font-lock-negation-char-face     :foreground fg)))

(defun my/writing-org-mode ()
  "Modo escritura: novela y archivos long-form."
  (my/writing-mode)
  (org-superstar-mode 1)
  (my/apply-heading-styles-local "org-level-")
  (my/org-property-syntax)
  (my/flatten-syntax-colors))

(defun my/technical-org-mode ()
  "Modo técnico: PAIR, LaTeX, exportación."
  (unless (featurep 'pair-docs-init)
    (load! "pair-docs/init-pair" "/Users/kr0n/Projects/Working/PAIR Protocol")
    (provide 'pair-docs-init))
  (olivetti-mode -1)
  (visual-line-mode 1)
  (display-line-numbers-mode 1)
  (wc-mode -1)
  (setq-local header-line-format nil)
  (setq-local org-hide-leading-stars nil)
  (when (bound-and-true-p org-indent-mode)
    (org-indent-mode -1))
  (pair/apply-headers)
  (my/org-pair-font-lock)
  ;; FIX: overlays diferidos — no bloquean la apertura del buffer
  (run-with-idle-timer 0.5 nil
    (lambda () (when (buffer-live-p (current-buffer))
                 (my/org-pair-apply-overlays))))
  ;; Re-aplicar overlays al guardar, también diferido
  (add-hook 'after-save-hook
    (lambda () (run-with-idle-timer 0.3 nil
                 (lambda () (when (buffer-live-p (current-buffer))
                              (my/org-pair-apply-overlays)))))
    nil t))

;;
;; ─── ORG DISPATCH ─────────────────────────────────────────────────────────────

(defvar my/novel-org-dirs
  (list (expand-file-name "~/novela/")
        (expand-file-name "/Users/kr0n/Library/Mobile Documents/27N4MQEA55~pro~writer/Documents/Story - La Academia de la Presciencia"))
  "Directorios que usan modo escritura/novela.")

(defvar my/technical-org-dirs
  (list (expand-file-name "/Users/kr0n/Projects/Working/PAIR Protocol/"))
  "Directorios que usan modo técnico.")

(defun my/org-mode-dispatch ()
  (let ((file (buffer-file-name)))
    (cond
     ((and file (cl-some (lambda (d) (string-prefix-p d (expand-file-name file)))
                         my/novel-org-dirs))
      (my/writing-org-mode))
     ((and file (cl-some (lambda (d) (string-prefix-p d (expand-file-name file)))
                         my/technical-org-dirs))
      (my/technical-org-mode))
     (t nil))))

;; t = append: corre ÚLTIMO, después de org-startup-indented
(add-hook 'org-mode-hook #'my/org-mode-dispatch t)

(add-hook 'markdown-mode-hook #'my/writing-mode)
(add-hook 'markdown-mode-hook #'my/flatten-syntax-colors)

;;
;; ─── HEADING STYLES (solo modo novela) ───────────────────────────────────────

(defvar my/heading-styles
  '((1 :family "Palatino" :height 2.2 :weight normal
       :slant italic :underline (:color "#555555" :style line))
    (2 :family "Palatino" :height 2.0 :weight normal
       :slant italic :foreground "#a9b7c6")
    (3 :family "Helvetica Neue" :height 1.1 :weight bold
       :foreground "#75715e")
    (4 :family "Helvetica Neue" :height 1.0 :weight normal
       :foreground "#555555")))

(defun my/apply-heading-styles-local (prefix)
  (dolist (s my/heading-styles)
    (apply #'face-remap-add-relative
           (intern (format "%s%d" prefix (car s)))
           (cdr s))))

(after! markdown-mode
  (add-hook 'markdown-mode-hook
    (lambda () (my/apply-heading-styles-local "markdown-header-face-"))))

;;
;; ─── EMDASH ───────────────────────────────────────────────────────────────────

(defun my/insert-emdash ()
  (interactive)
  (if (and (> (point) 1)
           (string= (buffer-substring (- (point) 2) (point)) "--"))
      (progn (delete-char -2) (insert "—"))
    (self-insert-command 1)))

(after! org      (map! :map org-mode-map     :i "SPC" #'my/insert-emdash))
(after! markdown-mode (map! :map markdown-mode-map :i "SPC" #'my/insert-emdash))

;;
;; ─── ORG-SUPERSTAR ────────────────────────────────────────────────────────────

(after! org (setq org-cycle-separator-lines 2))
(after! org-superstar
  (setq org-superstar-headline-bullets-list '(" "))
  (setq org-superstar-leading-bullet " ")
  (setq org-superstar-special-todo-items t))

;;
;; ─── ORG-APPEAR ───────────────────────────────────────────────────────────────

(use-package! org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autolinks t
        org-appear-autosubmarkers t))

;;
;; ─── AUTOCOMPLETE ─────────────────────────────────────────────────────────────

(after! dabbrev
  (setq dabbrev-abbrev-char-regexp "\\sw\\|[áéíóúüñÁÉÍÓÚÜÑ]")
  (setq dabbrev-ignored-buffer-regexps
        '("\\` " "\\*Messages\\*" "\\*scratch\\*" "\\*doom\\*"
          "\\*evil\\*" "\\*helpful\\*" "\\*Help\\*")))
(after! cape (setq cape-dabbrev-check-other-buffers nil))

;;
;; ─── ISPELL ───────────────────────────────────────────────────────────────────

(after! ispell
  (setq ispell-program-name "aspell"
        ispell-dictionary "es"
        ispell-local-dictionary "es"))

;;
;; ─── NOVEL PROPERTY SYNTAX ────────────────────────────────────────────────────

(defun my/org-property-syntax ()
  (font-lock-add-keywords
   nil
   '(("^[ \t]*:\\(POV\\|ESCENAS\\|BEATS_PRINCIPALES\\|APERTURA\\|CIERRE\\):"
      1 '(:foreground "#66d9e8") t)
     ("^[ \t]*:\\(PERSONAJES_PRINCIPALES\\|PERSONAJES_SECUNDARIOS\\|DESARROLLO_PERSONAJE\\):"
      1 '(:foreground "#a9dc76") t)
     ("^[ \t]*:\\(TRAMA_IDENTIDAD\\|TRAMA_ACADEMIA\\|TRAMA_MISTERIO\\|TRAMA_RELACIONES\\|SEMILLAS\\):"
      1 '(:foreground "#e6db74") t)
     ("^[ \t]*:\\(TENSION\\|RITMO\\|MOTIFS\\|PODER_DINAMICAS\\):"
      1 '(:foreground "#fc9867") t)
     ("^[ \t]*:\\(FECHA_CRONOLOGICA\\|DURACION\\|ESTADO\\|NOTAS\\|CUSTOM_ID\\|PALABRAS\\|ESCENARIOS\\|TECNOLOGIA\\|REGLAS_MUNDO\\):"
      1 '(:foreground "#75715e") t))
   t))

;;
;; ─── FIX 3: WORD COUNT SIN TIMER LEAK ────────────────────────────────────────
;;
;; Antes: run-with-idle-timer 2 t creaba un timer por buffer que nunca moría.
;; Ahora: el header-line-format (:eval ...) re-evalúa solo al redibujarse.
;; El wordcount en :PALABRAS: se sigue actualizando en before-save, pero
;; diferido con idle-timer para no bloquear el guardado.

(defun my/buffer-word-count ()
  "Cuenta palabras en el buffer excluyendo bloques :PROPERTIES:."
  (let ((text (buffer-substring-no-properties (point-min) (point-max))))
    (setq text (replace-regexp-in-string
                ":PROPERTIES:\\(.\\|\n\\)*?:END:" "" text))
    (length (split-string text "\\W+" t))))

(defvar-local my/wordcount-timer nil
  "Timer para el wordcount diferido. Evita ejecuciones solapadas.")

(defun my/org-update-wordcount ()
  "Actualiza :PALABRAS: en headings nivel 2. Diferido para no bloquear el guardado."
  (when (and (derived-mode-p 'org-mode) (buffer-file-name))
    ;; Cancelar timer anterior si aún no ha corrido
    (when (timerp my/wordcount-timer)
      (cancel-timer my/wordcount-timer))
    (setq my/wordcount-timer
      (run-with-idle-timer 1 nil
        (lambda (buf)
          (when (buffer-live-p buf)
            (with-current-buffer buf
              (condition-case nil
                  (org-map-entries
                   (lambda ()
                     (let* ((element (org-element-at-point))
                            (beg (org-element-property :contents-begin element))
                            (end (org-element-property :contents-end element))
                            (text (if (and beg end (> end beg))
                                      (replace-regexp-in-string
                                       ":PROPERTIES:\\(.\\|\n\\)*?:END:" ""
                                       (buffer-substring-no-properties beg end))
                                    ""))
                            (words (length (split-string text "\\W+" t))))
                       (org-set-property "PALABRAS" (number-to-string words))))
                   "LEVEL=2" 'file)
                (error nil)))))
        (current-buffer)))))

(add-hook 'org-mode-hook
  (lambda ()
    (add-hook 'after-save-hook #'my/org-update-wordcount nil t)))

;;
;; ─── THEME TOGGLE ─────────────────────────────────────────────────────────────

(defun my/refresh-technical-buffers ()
  "Re-aplica headers y overlays en buffers técnicos tras cambiar tema."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (derived-mode-p 'org-mode)
                 (local-variable-p 'pair/header-cookies))
        (pair/apply-headers)
        (my/org-pair-apply-overlays)
        (pair/add-transclusion-bg)))))

(defun my/toggle-theme ()
  (interactive)
  (if (eq doom-theme 'doom-zen-writer)
      (progn (setq doom-theme 'doom-zen-writer-dark)
             (load-theme 'doom-zen-writer-dark t))
    (progn (setq doom-theme 'doom-zen-writer)
           (load-theme 'doom-zen-writer t)))
  (run-with-timer 0.1 nil #'my/refresh-technical-buffers))

(map! :leader :desc "Toggle day/night theme" "t t" #'my/toggle-theme)

;;
;; ─── UI: TREEMACS, TABS ───────────────────────────────────────────────────────

(after! treemacs (setq treemacs-width 30))

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

(after! centaur-tabs
  (custom-set-faces!
    `(centaur-tabs-selected
      :background ,(doom-color 'bg) :foreground ,(doom-color 'fg) :bold t)
    `(centaur-tabs-unselected
      :background ,(doom-color 'bg-alt) :foreground ,(doom-color 'base2))
    `(centaur-tabs-selected-modified
      :background ,(doom-color 'bg) :foreground ,(doom-color 'red))
    `(centaur-tabs-unselected-modified
      :background ,(doom-color 'bg-alt) :foreground ,(doom-color 'base2))
    `(centaur-tabs-active-bar-face    :background ,(doom-color 'red))
    `(centaur-tabs-modified-marker-selected
      :background ,(doom-color 'bg) :foreground ,(doom-color 'red))
    `(centaur-tabs-modified-marker-unselected
      :background ,(doom-color 'bg-alt) :foreground ,(doom-color 'base2))))

;;
;; ─── ORG COLUMNS SIDE PANEL ───────────────────────────────────────────────────

(defun my/org-columns-side ()
  (interactive)
  (delete-other-windows)
  (split-window-right)
  (other-window 1)
  (switch-to-buffer (clone-indirect-buffer "*Columnas*" nil))
  (olivetti-mode -1)
  (org-superstar-mode -1)
  (display-line-numbers-mode -1)
  (setq-local line-spacing 1)
  (text-scale-set -3)
  (face-remap-add-relative 'org-level-1 :family "Helvetica Neue" :height 1.1 :slant 'normal :underline nil :weight 'normal)
  (face-remap-add-relative 'org-level-2 :family "Helvetica Neue" :height 1 :slant 'normal :foreground "#f8f8f2" :weight 'normal)
  (face-remap-add-relative 'org-level-3 :family "Helvetica Neue" :height 1 :slant 'normal :weight 'normal)
  (face-remap-add-relative 'org-column       :family "Helvetica Neue" :height 1)
  (face-remap-add-relative 'org-column-title :family "Helvetica Neue" :height 1.1)
  (goto-char (point-min))
  (org-overview)
  (org-show-children)
  (org-columns)
  (other-window -1))

(after! org
  (map! :map org-mode-map :localleader "k" #'my/org-columns-side))

;;
;; ─── NAVIGATION ───────────────────────────────────────────────────────────────

(defun my/search-ignore-accents (str)
  (let ((replacements '(("a" . "[aáàäâã]") ("e" . "[eéèëê]")
                        ("i" . "[iíìïî]")  ("o" . "[oóòöôõ]")
                        ("u" . "[uúùüû]")  ("n" . "[nñ]"))))
    (dolist (r replacements str)
      (setq str (replace-regexp-in-string (car r) (cdr r) str)))))

(defun my/evil-search-no-accents ()
  (interactive)
  (let* ((query   (read-string "Search (ignore accents): "))
         (pattern (my/search-ignore-accents query)))
    (setq evil-ex-search-pattern   (evil-ex-make-search-pattern pattern))
    (setq evil-ex-search-direction 'forward)
    (evil-ex-search-next)))

(map! :n "g/" #'my/evil-search-no-accents)

(after! evil
  (evil-define-key '(normal visual motion) 'global
    (kbd "<up>")    'evil-previous-visual-line
    (kbd "<down>")  'evil-next-visual-line
    (kbd "<left>")  'evil-backward-char
    (kbd "<right>") 'evil-forward-char))

(setq org-support-shift-select t)

(map! :gi "S-<up>"    #'evil-previous-visual-line
      :gi "S-<down>"  #'evil-next-visual-line
      :gi "S-<left>"  #'evil-backward-char
      :gi "S-<right>" #'evil-forward-char)

(after! evil
  (evil-define-key '(normal visual) 'global
    (kbd "s-<left>")  #'evil-beginning-of-visual-line
    (kbd "s-<right>") #'evil-end-of-visual-line))

;;
;; ─── BUFFERS & WORKSPACES ─────────────────────────────────────────────────────

(map! :leader :desc "Global buffers" "k" #'consult-buffer)

(after! persp-mode
  (setq persp-add-buffer-on-find-file t
        persp-add-buffer-on-after-change-major-mode 'free
        persp-filter-save-buffers-functions
        (list (lambda (b) (string-prefix-p " " (buffer-name b)))))
  (add-hook 'org-mode-hook
    (lambda ()
      (when (and (buffer-file-name)
                 (not (persp-contain-buffer-p (current-buffer))))
        (persp-add-buffer (current-buffer)
          (persp-get-by-name "org" *persp-hash* :nil)))))
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
;; ─── EXPORT ───────────────────────────────────────────────────────────────────

(use-package! ox-pandoc :after org)
(after! ox-pandoc (setq ox-pandoc-command "/opt/homebrew/bin/pandoc"))

(setq org-latex-pdf-process
      '("lualatex -interaction nonstopmode -output-directory %o %f"
        "lualatex -interaction nonstopmode -output-directory %o %f"))

;;
;; ─── EXTRAS ───────────────────────────────────────────────────────────────────

(load! "zen-writer.el")

