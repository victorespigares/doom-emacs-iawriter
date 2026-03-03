;;; doom-zen-writer-dark-theme.el --- -*- lexical-binding: t; no-byte-compile: t; -*-
(require 'doom-themes)

(defgroup doom-zen-writer-dark-theme nil
  "Options for the `doom-zen-writer-dark' theme."
  :group 'doom-themes)

(defcustom doom-zen-writer-dark-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line."
  :group 'doom-zen-writer-dark-theme
  :type '(or integer boolean))

(def-doom-theme doom-zen-writer-dark
  "Dark theme inspired by iA Writer + Monokai."
  ((bg      '("#1e1e1e"))
   (bg-alt  '("#272727"))
   (base0   '("#a9b7c6"))   ; texto principal — azul grisáceo suave
   (base1   '("#2d2d2d"))
   (base2   '("#75715e"))   ; comentarios — Monokai warm grey
   (base3   '("#3a3a3a"))
   (base4   '("#313131"))
   (base5   '("#555555"))
   (base6   '("#252525"))
   (base7   '("#383838"))
   (base8   '("#242424"))
   (fg      '("#f8f8f2"))   ; Monokai white
   (fg-alt  (doom-darken fg 0.15))
   (grey    base2)
   (red     '("#f92672"))   ; Monokai pink/red — solo para errores
   (blue    fg) (dark-blue fg) (orange fg)
   (green   fg) (teal fg) (yellow fg)
   (magenta fg) (violet fg) (cyan fg) (dark-cyan fg)
   (highlight base2)
   (vertical-bar base5)
   (selection base3)
   (builtin base0) (comments base2) (doc-comments base2)
   (constants base0) (functions fg) (keywords fg) (methods fg)
   (operators fg) (type fg) (strings base0) (variables base0)
   (numbers base0) (region base3)
   (error red)
   (warning (doom-blend fg "#e6db74" 0.4))
   (success fg)
   (vc-modified base2) (vc-added (doom-darken fg 0.3)) (vc-deleted base2)
   (-modeline-pad (when doom-zen-writer-dark-padded-modeline
                    (if (integerp doom-zen-writer-dark-padded-modeline)
                        doom-zen-writer-dark-padded-modeline 4)))
   (modeline-bg     (doom-darken bg-alt 0.15))
   (modeline-bg-alt (doom-darken bg-alt 0.1))
   (modeline-bg-inactive     (doom-darken bg-alt 0.1))
   (modeline-bg-inactive-alt bg-alt)
   (modeline-fg     fg)
   (modeline-fg-alt (doom-darken modeline-bg-inactive 0.35)))

  ((error   :underline `(:style wave :color ,error))
   (warning :underline `(:style wave :color ,warning))
   (hl-sentence :foreground fg :background bg :extend t)
   (hl-line :background base8)

   ((line-number &override)              :foreground base5)
   ((line-number-current-line &override) :foreground base2)
   (mode-line :background modeline-bg :foreground modeline-fg
              :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive :background modeline-bg-inactive :foreground modeline-fg-alt
                       :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (outline-1 :slant 'italic :foreground fg-alt)
   (outline-2 :inherit 'outline-1 :foreground base2)
   (outline-3 :inherit 'outline-2)
   (outline-4 :inherit 'outline-3)
   ((org-block &override)            :background bg-alt)
   ((org-block-begin-line &override) :foreground base5)))


;;; doom-zen-writer-dark-theme.el ends here

