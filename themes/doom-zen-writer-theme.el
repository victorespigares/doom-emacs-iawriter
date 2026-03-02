;;; doom-zen-writer-theme.el --- -*- lexical-binding: t; no-byte-compile: t; -*-
(require 'doom-themes)

(defgroup doom-plain-theme nil
  "Options for the `doom-plain' theme."
  :group 'doom-themes)

(defcustom doom-plain-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line."
  :group 'doom-plain-theme
  :type '(or integer boolean))

(def-doom-theme doom-zen-writer
  "Theme inspired by iA Writer."
  ((bg '("#ffffff")) (bg-alt '("#eaecea"))
   (base0 '("#969896")) (base1 '("#f1f3f5")) (base2 '("#606666"))
   (base3 '("#cccccc")) (base4 '("#e7e7e7")) (base5 '("#a5a8a6"))
   (base6 '("#fafafa")) (base7 '("#dfdfdf")) (base8 '("#fafafa"))
   (fg '("#969896")) (fg-alt (doom-lighten fg 0.15))
   (grey fg) (red fg) (blue fg) (dark-blue fg) (orange fg)
   (green fg) (teal fg) (yellow fg) (magenta fg) (violet fg)
   (cyan fg) (dark-cyan fg)
   (highlight base2) (vertical-bar base5) (selection base1)
   (builtin base0) (comments base5) (doc-comments base5)
   (constants base0) (functions fg) (keywords fg) (methods fg)
   (operators fg) (type fg) (strings base0) (variables base0)
   (numbers base0) (region base4)
   (error (doom-blend fg "#ff0000" 0.4))
   (warning base2) (success green)
   (vc-modified base5) (vc-added (doom-lighten fg 0.7)) (vc-deleted base2)
   (-modeline-pad (when doom-plain-padded-modeline
                    (if (integerp doom-plain-padded-modeline)
                        doom-plain-padded-modeline 4)))
   (modeline-bg (doom-darken bg-alt 0.15))
   (modeline-bg-alt (doom-darken bg-alt 0.1))
   (modeline-bg-inactive (doom-darken bg-alt 0.1))
   (modeline-bg-inactive-alt bg-alt)
   (modeline-fg fg)
   (modeline-fg-alt (doom-darken modeline-bg-inactive 0.35)))

  ((error :underline `(:style wave :color ,error))
   (warning :underline `(:style wave :color ,warning))
   (hl-sentence :foreground "#000000" :background bg)
   (hl-line :background base8)
   ((line-number &override) :foreground base3)
   ((line-number-current-line &override) :foreground base2)
   (mode-line :background modeline-bg :foreground modeline-fg
              :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive :background modeline-bg-inactive :foreground modeline-fg-alt
                       :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (outline-1 :slant 'italic :foreground fg-alt)
   (outline-2 :inherit 'outline-1 :foreground base2)
   (outline-3 :inherit 'outline-2) (outline-4 :inherit 'outline-3)
   ((org-block &override) :background bg-alt)
   ((org-block-begin-line &override) :foreground base5)))
;;; doom-zen-writer-theme.el ends here

