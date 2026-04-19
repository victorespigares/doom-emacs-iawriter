;;; config.el -*- lexical-binding: t; -*-

(setq user-full-name "kr0n" user-mail-address "")

;;
;; Must be set before evil loads
(setq evil-want-shift-selection t)

;; Enable shift-selection in all states
(after! evil
  (define-key evil-motion-state-map (kbd "S-<up>")    #'evil-previous-visual-line)
  (define-key evil-motion-state-map (kbd "S-<down>")  #'evil-next-visual-line)
  (define-key evil-motion-state-map (kbd "S-<left>")  #'evil-backward-char)
  (define-key evil-motion-state-map (kbd "S-<right>") #'evil-forward-char))

;;
;; iA Writer fonts
(setq doom-font (font-spec :family "iA Writer Mono S" :size 18)
      doom-variable-pitch-font (font-spec :family "iA Writer Quattro S" :size 18))

;;
;; Theme
(add-to-list 'custom-theme-load-path "~/.config/doom/themes")
(setq doom-theme 'doom-zen-writer)

;;
;; Absolute line numbers globally, hidden in writing modes, toggle with SPC t n
(setq display-line-numbers-type t)

(map! :leader
      :desc "Toggle line numbers"
      "t n" #'display-line-numbers-mode)

;;
;; Org core
(setq org-directory "~/novela/")
(setq org-hide-emphasis-markers t)
(setq org-hide-leading-stars t)
(setq org-startup-indented t)
(setq org-startup-folded 'overview)
(setq org-use-sub-superscripts nil)

(setq nerd-icons-font-family "Symbols Nerd Font Mono")

;;
;; Shared writing mode (org + markdown)
(defun my/writing-mode ()
  (olivetti-mode 1)
  (visual-line-mode 1)
  (hl-sentence-mode 1)
  (electric-quote-local-mode 1)
  (display-line-numbers-mode -1)
  (wc-mode 1)
  (setq-local header-line-format
        '((:eval (format "📝 %d palabras" (my/buffer-word-count)))))
  (run-with-idle-timer 2 t
    (lambda ()
      (when (derived-mode-p 'org-mode 'markdown-mode)
        (force-mode-line-update)))))

(add-hook 'org-mode-hook #'my/writing-mode)
(add-hook 'markdown-mode-hook #'my/writing-mode)

;;
;; Emdash with double -- (org and markdown)
(defun my/insert-emdash ()
  (interactive)
  (if (and (> (point) 1)
           (string= (buffer-substring (- (point) 2) (point)) "--"))
      (progn
        (delete-char -2)
        (insert "—"))
    (self-insert-command 1)))

(after! org
  (map! :map org-mode-map :i "SPC" #'my/insert-emdash))

(after! markdown-mode
  (map! :map markdown-mode-map :i "SPC" #'my/insert-emdash))

;;
;; Autocomplete with Spanish characters - limit dabbrev to current buffer
(after! dabbrev
  (setq dabbrev-abbrev-char-regexp "\\sw\\|[áéíóúüñÁÉÍÓÚÜÑ]")
  (setq dabbrev-ignored-buffer-regexps
        '("\\` " "\\*Messages\\*" "\\*scratch\\*" "\\*doom\\*"
          "\\*evil\\*" "\\*helpful\\*" "\\*Help\\*")))

(after! cape
  (setq cape-dabbrev-check-other-buffers nil))

;;
;; Force ispell to Spanish
(after! ispell
  (setq ispell-program-name "aspell")
  (setq ispell-dictionary "es")
  (setq ispell-local-dictionary "es"))

;;
;; Big typography headings
(after! org
  (setq org-cycle-separator-lines 2)
  (add-hook 'org-mode-hook (lambda () (org-superstar-mode 1))))

(after! org-superstar
  (setq org-superstar-headline-bullets-list '(" "))
  (setq org-superstar-leading-bullet " ")
  (setq org-superstar-special-todo-items t))

;;
;; Shared heading typography (org + markdown)
;;
;; Shared heading typography (org + markdown)
(defvar my/heading-styles
  '((1 :family "Palatino" :height 2.2 :weight normal
       :slant italic :underline (:color "#555555" :style line))
    (2 :family "Palatino" :height 2.0 :weight normal
       :slant italic :foreground "#a9b7c6")
    (3 :family "Helvetica Neue" :height 1.1 :weight bold
       :foreground "#75715e")
    (4 :family "Helvetica Neue" :height 1.0 :weight normal
       :foreground "#555555")))

(defun my/apply-heading-styles (prefix)
  (dolist (s my/heading-styles)
    (let ((face (intern (format "%s%d" prefix (car s))))
          (attrs (cdr s)))
      (apply #'set-face-attribute face nil attrs))))

(after! org
  (my/apply-heading-styles "org-level-"))

(after! markdown-mode
  (my/apply-heading-styles "markdown-header-face-"))


;;
;; No bullets
(after! org-superstar
  (setq org-superstar-headline-bullets-list '(" "))
  (setq org-superstar-leading-bullet " "))

;;
;; org-appear: markup visible only when editing
(use-package! org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autolinks t
        org-appear-autosubmarkers t))

;;
;; Theme face remap for dark mode
(add-hook 'doom-load-theme-hook
  (lambda ()
    (when (eq doom-theme 'doom-zen-writer-dark)
      (dolist (buf (buffer-list))
        (with-current-buffer buf
          (when (derived-mode-p 'org-mode 'markdown-mode)
            (face-remap-add-relative 'default :foreground "#75715e")))))))

;;
;; Treemacs
(after! treemacs
  (setq treemacs-width 30))

;;
;; Tabs
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

;;
;; Word count (excludes org property blocks)
(defun my/buffer-word-count ()
  "Count words in buffer excluding org property blocks."
  (let ((text (buffer-substring-no-properties (point-min) (point-max))))
    (setq text (replace-regexp-in-string
                ":PROPERTIES:\\(.\\|\n\\)*?:END:" "" text))
    (length (split-string text "\\W+" t))))

;;
;; Updates :PALABRAS: property for each level-2 heading on save (org only)
(defun my/org-update-wordcount ()
  (when (and (derived-mode-p 'org-mode)
             (buffer-file-name)
             (eq (buffer-local-value 'major-mode (current-buffer)) 'org-mode))
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
      (error nil))))

(add-hook 'org-mode-hook
  (lambda ()
    (remove-hook 'before-save-hook #'my/org-update-wordcount)
    (add-hook 'before-save-hook #'my/org-update-wordcount nil t)))

;;
;; day/night theme toggle SPC t t
(defun my/toggle-theme ()
  (interactive)
  (if (eq doom-theme 'doom-zen-writer)
      (progn
        (setq doom-theme 'doom-zen-writer-dark)
        (load-theme 'doom-zen-writer-dark t))
    (progn
      (setq doom-theme 'doom-zen-writer)
      (load-theme 'doom-zen-writer t))))

(map! :leader
      :desc "Toggle day/night theme"
      "t t" #'my/toggle-theme)

;;
;; Color syntax for properties in org-mode
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

(add-hook 'org-mode-hook #'my/org-property-syntax)

;;
;; Centaur tabs faces for dark mode
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
    `(centaur-tabs-active-bar-face
      :background ,(doom-color 'red))
    `(centaur-tabs-modified-marker-selected
      :background ,(doom-color 'bg) :foreground ,(doom-color 'red))
    `(centaur-tabs-modified-marker-unselected
      :background ,(doom-color 'bg-alt) :foreground ,(doom-color 'base2))))

;;
;; SPC k for global buffer switcher
(map! :leader
      :desc "Global buffers" "k" #'consult-buffer)

;;
;; SPC m k for org-columns side panel
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
  (face-remap-add-relative 'org-column  :family "Helvetica Neue" :height 1)
  (face-remap-add-relative 'org-column-title :family "Helvetica Neue" :height 1.1)
  (goto-char (point-min))
  (org-overview)
  (org-show-children)
  (org-columns)
  (other-window -1))

(after! org
  (map! :map org-mode-map
        :localleader
        "k" #'my/org-columns-side))

;;
;; Fuzzy search ignoring accents
(defun my/search-ignore-accents (str)
  (let ((replacements '(("a" . "[aáàäâã]")
                        ("e" . "[eéèëê]")
                        ("i" . "[iíìïî]")
                        ("o" . "[oóòöôõ]")
                        ("u" . "[uúùüû]")
                        ("n" . "[nñ]"))))
    (dolist (r replacements str)
      (setq str (replace-regexp-in-string
                 (car r) (cdr r) str)))))

(defun my/evil-search-no-accents ()
  (interactive)
  (let* ((query (read-string "Search (ignore accents): "))
         (pattern (my/search-ignore-accents query)))
    (setq evil-ex-search-pattern (evil-ex-make-search-pattern pattern))
    (setq evil-ex-search-direction 'forward)
    (evil-ex-search-next)))

(map! :n "g/" #'my/evil-search-no-accents)

;;
;; Lines logic: j/k for logical lines, arrows for visual lines
(after! evil
  (evil-define-key '(normal visual motion) 'global
    (kbd "<up>")    'evil-previous-visual-line
    (kbd "<down>")  'evil-next-visual-line
    (kbd "<left>")  'evil-backward-char
    (kbd "<right>") 'evil-forward-char))

;;
;; Shift-selection
(setq org-support-shift-select t)
(setq evil-want-shift-selection t)

(map! :gi "S-<up>"    #'evil-previous-visual-line
      :gi "S-<down>"  #'evil-next-visual-line
      :gi "S-<left>"  #'evil-backward-char
      :gi "S-<right>" #'evil-forward-char)

;;
;; Cmd-left/Cmd-right → start/end of visual line
(after! evil
  (evil-define-key '(normal visual) 'global
    (kbd "s-<left>")  #'evil-beginning-of-visual-line
    (kbd "s-<right>") #'evil-end-of-visual-line))

;;
;; Workspace and buffer management
(after! persp-mode
  (setq persp-add-buffer-on-find-file t)
  (setq persp-add-buffer-on-after-change-major-mode 'free)

  (setq persp-filter-save-buffers-functions
        (list (lambda (b) (string-prefix-p " " (buffer-name b)))))

  ;; Org files go to "org" workspace only if not already in one
  (add-hook 'org-mode-hook
    (lambda ()
      (when (and (buffer-file-name)
                 (not (persp-contain-buffer-p (current-buffer))))
        (persp-add-buffer (current-buffer)
          (persp-get-by-name "org" *persp-hash* :nil)))))

  ;; Doom config files go to "config" workspace only if not already in one
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
;; ox-pandoc for epub export
(use-package! ox-pandoc
  :after org)

(after! ox-pandoc
  (setq ox-pandoc-command "/opt/homebrew/bin/pandoc"))

;;
;; Zen writer
(load! "zen-writer.el")

;;
;; PAIR
(use-package! exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))
(setq org-latex-pdf-process
      '("lualatex -interaction nonstopmode -output-directory %o %f"
        "lualatex -interaction nonstopmode -output-directory %o %f"))
(load! "pair-docs/init-pair" "/Users/kr0n/Projects/Working/PAIR Protocol")
