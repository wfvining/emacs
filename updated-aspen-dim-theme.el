(deftheme updated-aspen-dim
  "Created 2023-03-10.")

(custom-theme-set-faces
 'updated-aspen-dim
 '(line-number ((t (:inherit default :background "gray25" :foreground "LightYellow4" :height 0.7 :weight semi-bold :slant normal))))
 '(line-number-current-line ((t (:inherit line-number :inverse-video t))))
 '(font-lock-variable-name-face ((t (:inherit default :foreground "SlateGray3"))))
 '(font-lock-string-face ((t (:inherit default :foreground "CadetBlue" :slant normal :weight normal))))
 '(font-lock-comment-face ((t (:inherit default :foreground "AntiqueWhite4" :slant italic :weight light))))
 '(default ((t (:family "Victor Mono" :foundry "UKWN" :width normal :height 158 :weight normal :slant normal :underline nil :overline nil :strike-through nil :box nil :inverse-video nil :foreground "ivory3" :background "gray23" :stipple nil :extend nil :inherit default))))
 '(font-lock-constant-face ((t (:inherit font-lock-variable-name-face :foreground "snow1" :slant normal :weight bold))))
 '(font-lock-keyword-face ((t (:inherit default :foreground "white"))))
 '(font-lock-preprocessor-face ((t (:inherit default :foreground "darkseagreen2" :slant oblique :weight normal))))
 '(font-lock-type-face ((t (:inherit default :foreground "PaleTurquoise2" :weight normal))))
 '(font-lock-function-name-face ((t (:inherit default :foreground "thistle2"))))
 '(erlang-font-lock-exported-function-name-face ((t (:inherit font-lock-function-name-face))))
 '(shadow ((t (:foreground "snow4"))))
 '(flycheck-error ((t (:underline (:color "tomato" :style wave)))))
 '(flycheck-warning ((t (:underline (:color "DarkGoldenrod1" :style wave)))))
 '(flycheck-fringe-error ((t (:foreground "tomato"))))
 '(org-level-1 ((t (:inherit outline-1 :extend nil))))
 '(org-tag ((t (:foreground "azure4" :slant oblique :weight normal))))
 '(mode-line-active ((t (:inherit mode-line-inactive :foreground "gray30" :background "gray80")))))

(provide-theme 'updated-aspen-dim)
