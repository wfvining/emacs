(deftheme aspen
  "Dark color theme with gray background and bright keywords")

(custom-theme-set-faces
 'aspen
 '(default ((t (:background "#464646" :foreground "light gray"))))
 ; font-lock faces
 '(font-lock-type-face
   ((t (:inherit default :foreground "aquamarine" :weight normal))))
 '(font-lock-builtin-face
   ((t (:inherit font-lock-type-face :weight normal))))
 '(font-lock-comment-face
   ((t (:inherit default :foreground "burlywood" :slant italic))))
 '(font-lock-string-face
   ((t (:inherit default :foreground "SlateGray2" :slant italic))))
 '(font-lock-warning-face
   ((((class color) (min-colors 88) (background dark))
     (:inherit default :foreground "#db2763" :weight bold))))
 '(font-lock-constant-face
   ((t (:inherit font-lock-variable-name-face :foreground "white" :slant normal))))
 '(font-lock-doc-face
   ((t (:inherit default :foreground "moccasin" :slant italic))))
 '(font-lock-function-name-face
   ((t (:inherit default :foreground "MediumOrchid1" :slant normal))))
 '(font-lock-keyword-face
   ((t (:inherit default :foreground "white"))))
 '(font-lock-preprocessor-face
   ((t (:inherit default :foreground "medium sea green" :weight normal))))
 '(font-lock-variable-name-face
   ((t (:inherit default :foreground "SteelBlue1"))))
 ; language-specific faces
 '(haskell-operator-face ((t (:foreground "cyan" :weight normal))))
 '(elixir-atom-face ((t (:foreground "dark turquoise"))))
 '(elixir-attribute-face ((t (:foreground "light sea green"))))
 ; org-mode faces
 '(org-done ((t (:foreground "#8ae234"))))
 '(org-level-4 ((t (:inherit outline-7))))
 '(org-level-7 ((t (:inherit outline-4))))
 '(org-level-1 ((t (:inherit outline-1)))) ;  :foreground "MediumOrchid1"
 '(org-todo ((t (:foreground "Maroon2"))))
 '(org-verbatim ((t (:foreground "white"))))
 '(org-block ((t (:inherit org-verbatim :slant normal))))
 '(org-date ((t (:foreground "turquoise" :underline t))))
 '(org-document-info ((t (:foreground "white smoke" :slant italic))))
 '(org-document-title ((t (:foreground "white" :weight bold))))
 '(org-footnote ((t (:inherit link))))
 '(org-table ((t (:foreground "DodgerBlue1"))))
 '(org-list-dt ((t (:foreground "DeepSkyBlue1"))))
 '(org-tag ((t (:foreground "grey17" :slant italic :weight normal))))
 '(org-code ((t (:inherit shadow :foreground "CadetBlue1"))))
 ; other mode faces
 '(show-paren-match ((t (:background "gold" :foreground "black"))))
 '(show-paren-mismatch ((t (:background "deep pink" :foreground "gray18"))))
 '(hl-line ((t (:background "gray26"))))
 '(which-func ((t (:foreground "maroon3"))))
 '(error ((t (:foreground "firebrick1" :weight bold))))
 '(fringe ((t (:background "gray35"))))
 '(highlight ((t (:background "gray21"))))
 '(isearch ((t (:background "coral1" :foreground "gray26"))))
 '(link ((t (:foreground "SteelBlue1" :underline t))))
 '(minibuffer-prompt ((t (:foreground "SteelBlue1"))))
 '(mode-line ((t (:background "gray"
                  :foreground "gray15"
                  :box (:line-width 1)))))
 '(region ((t (:background "dim gray"))))
 '(shadow ((t (:foreground "grey16"))))
 '(line-number ((t (:inherit (shadow default) :background "gray25" :foreground "light gray" :slant italic :weight light :family "Hasklig"))))
 '(line-number-current-line ((t (:inherit line-number :background "gray36"))))
 )

(provide-theme 'aspen)
