;; Will's revised .emacs file, 8 November 2024
;;
;; This is (almost) entirely lifted from https://github.com/patrickt/emacs
;;
;; Some files to note
;; - proxy.el :: this file is loaded before packages are installed and
;;               can be used to configure proxy settings
;; - agenda.el :: this file is used to set the list of agenda file for
;;                org-mode

(when (window-system)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1))

(load "~/.emacs.d/proxy.el" 'noerror)

(set-face-attribute 'default nil :font "Victor Mono")
(set-face-attribute 'default nil :height 150)
;; (set-face-attribute 'variable-pitch nil :font "Libertinus Sans")

(load-theme 'aspen t)
(load-theme 'updated-aspen-dim t)
(setq custom-enabled-themes '(updated-aspen-dim aspen))

;; Make pdfs look better
(setq doc-view-mupdf-use-svg t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq package-native-compile t)
(setq use-package-always-ensure t) ;; This may not be necessary - it will hit the network every time
(unless (package-installed-p 'use-package)
  (message "refreshing contents")
  (unless package-archive-contents (package-refresh-contents))
  (package-install 'use-package))

(require 'use-package)

(setq gc-cons-threshold 1000000000)
(setq max-specpdl-size 5000)

(setq
 inhibit-startup-screen t
 initial-scratch-message "; *scratch*\n"
 sentence-end-double-space nil
 save-interprogram-paste-before-kill t
 load-prefer-newer t
 native-comp-async-report-warnings-errors 'silent
 help-window-select t
 scroll-preserve-screen-position t)

(setq-default indent-tabs-mode nil)

(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8-unix)

(delete-selection-mode t)
(global-display-line-numbers-mode t)
(column-number-mode)
(savehist-mode)
 
;; XXX dangerous
(setq custom-safe-themes t)

(defun pt/indent-just-yanked ()
  "Re-indent whatever you just yanked appropriately."
  (interactive)
  (exchange-point-and-mark)
  (indent-region (region-beginning) (region-end))
  (deactivate-mark))

(bind-key "C-c I" #'pt/indent-just-yanked)

(defalias 'view-emacs-news 'ignore)
(defalias 'describe-gnu-project 'ignore)
(defalias 'describe-copying 'ignore)

(use-package shut-up)

;; ?? Allegedly this fixes the case insensitive completions offered up
;; by emacs, but it also looks like it does more than that. Regadless
;; I'm going to try it out.
(use-package dabbrev
  :bind* (("C-/" . #'dabbrev-completion))
  :custom
  (dabbrev-check-all-buffers t)
  (dabbrev-case-replace nil))

(use-package fancy-compilation :config (fancy-compilation-mode))

(use-package nerd-icons)
(use-package nerd-icons-dired
  :after nerd-icons
  :hook (dired-mode . nerd-icons-dired-mode))

;; de-pollute the mode line
(use-package diminish
  :config
  (diminish 'visual-line-mode))

(defun pt/project-relative-file-name (include-prefix)
  "Return the project-relative filename, or the full path if INCLUDE-PREFIX is t."
  (letrec
      ((fullname (if (equal major-mode 'dired-mode) default-directory (buffer-file-name)))
       (root (project-root (project-current)))
       (relname (if fullname (file-relative-name fullname root) fullname))
       (should-strip (and root (not include-prefix))))
    (if should-strip relname fullname)))

(use-package mood-line
  :config
  (defun pt/mood-line-segment-project-advice (oldfun)
    "Advice to use project-relative file names where possible."
    (let
        ((project-relative (ignore-errors (pt/project-relative-file-name nil))))
         (if
             (and (project-current) (not org-src-mode) project-relative)
             (propertize (format "%s  " project-relative) 'face 'mood-line-buffer-name)
           (funcall oldfun))))

  (advice-add 'mood-line-segment-buffer-name :around #'pt/mood-line-segment-project-advice)
  (mood-line-mode))

(use-package rainbow-delimiters
  :disabled
  :hook ((prog-mode . rainbow-delimiters-mode)))

(use-package centered-window
  :custom
  (cwm-centered-window-width 180))

(shut-up
 (use-package tree-sitter
   :config (global-tree-sitter-mode))
 (use-package tree-sitter-langs))

(use-package smartparens
  :bind (("C-(" . #'sp-backward-sexp)
         ("C-)" . #'sp-forward-sexp)
         ("C-c d w" . #'sp-delete-word)
         ("<left>" . #'sp-backward-sexp)
         ("<right>" . #'sp-forward-sexp)
         ("C-c C-(" . #'sp-up-sexp)
         ("C-c j s" . #'sp-copy-sexp)
         ("C-c C-)" . #'sp-down-sexp))
  :config
  (require 'smartparens-config)
  (setq sp-show-pair-delay 0
        sp-show-pair-from-inside t)
  (smartparens-global-mode)
  (show-smartparens-global-mode t)
  ;; (set-face-attribute 'sp-pair-overlay-face nil :background "#0E131D")
  (defun indent-between-pair (&rest _ignored)
    (newline)
    (indent-according-to-mode)
    (forward-line -1)
    (indent-according-to-mode))

  (sp-local-pair 'prog-mode "{" nil :post-handlers '((indent-between-pair "RET")))
  (sp-local-pair 'prog-mode "[" nil :post-handlers '((indent-between-pair "RET")))
  (sp-local-pair 'prog-mode "(" nil :post-handlers '((indent-between-pair "RET"))))

(defun pt/split-window-thirds ()
  "Split a window into thirds."
  (interactive)
  (split-window-right)
  (split-window-right)
  (balance-windows))

(bind-key "C-c 3" #'pt/split-window-thirds)

(use-package sudo-edit)

(setq
 dired-do-revert-buffer t
 dired-mark-region t)

(setq read-process-output-max (* 1024 1024)) ; 1 MB

(setq executable-prefix-env t)
(add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)

(use-package org
  :hook ((org-mode . auto-fill-mode) (org-mode . turn-on-flyspell))
  :bind (("C-c a" . #'org-agenda))
  :custom
  (org-log-into-drawer t)
  (org-todo-keywords
   '((sequence "TODO" "IN PROGRESS(i!)" "BLOCKED(b@)" "|" "DONE(d!)" "CANCELED(c!)")))
  (org-todo-keyword-faces
   '(("TODO" . org-todo)
     ("DONE" . org-done)
     ("CANCELED" . (:foreground "DodgerBlue1"))
     ("BLOCKED" . (:foreground "DarkOrange1"))))
  (org-return-follows-link t)
  (org-pretty-entities t)
  (org-agenda-window-setup 'only-window)
  (org-agenda-restore-windows-after-quit t))
(load "~/.emacs.d/agenda.el" 'noerror)
;; This is a hack to deal with org-ctags modifying the link following
;; behavior when it is loaded. I'm not sure what is loading it, but
;; something is and this will make sure that whenever it happens we
;; put the link behavior back to the default.
(with-eval-after-load 'org-ctags (setq org-open-link-functions nil))

(use-package magit
  :diminish magit-auto-revert-mode
  :diminish auto-revert-mode
  :bind (("C-x g" . #'magit-status))
  :custom
  (magit-diff-refine-hunk t)
  (magit-repository-directories '(("~/src" . 1)))
  (magit-list-refs-sortby "-creatordate")
  :config
  (defun pt/commit-hook () (set-fill-column 80))
  (add-hook 'git-commit-setup-hook #'pt/commit-hook)
  (add-hook 'git-commit-setup-hook #'git-commit-turn-on-flyspell))

(use-package compile
  :custom
  (compilation-read-command nil "Don't prompt every time.")
  (compilation-scroll-output 'first-error))

(use-package project
  :pin gnu
  :bind (("C-c k" . #'project-kill-buffers)
         ("C-c m" . #'project-compile)
         ("C-x f" . #'find-file)
         ("C-c F" . #'project-switch-project)
         ("C-c R" . #'pt/recentf-in-project)
         ("C-c f" . #'project-find-file))
  :custom
  ;; This is one of my favorite things: you can customize
  ;; the options shown upon switching projects.
  (project-switch-commands
   '((project-find-file "Find file")
     (magit-project-status "Magit" ?g)
     (deadgrep "Grep" ?h)
     (pt/project-run-vterm "vterm" ?t)
     (project-dired "Dired" ?d)
     (pt/recentf-in-project "Recently opened" ?r)))
  (compilation-always-kill t)
  (project-vc-merge-submodules nil)
  )

(use-package projectile
  :disabled
  :custom (projectile-enable-caching t)
  :config
  (defun pt/find-file-dwim ()
    (interactive)
    (project-find-file))
    ;; (if (and buffer-file-name (file-remote-p buffer-file-name))
    ;;     (progn
    ;;       (projectile-mode t)
    ;;       (projectile-find-file)
    ;;       )
    ;;   (project-find-file)))
  :bind (("C-c f" . #'pt/find-file-dwim)))

(defun pt/recentf-in-project ()
  "As `recentf', but filtering based on the current project root."
  (interactive)
  (let* ((proj (project-current))
         (root (if proj (project-root proj) (user-error "Not in a project"))))
    (cl-flet ((ok (fpath) (string-prefix-p root fpath)))
      (find-file (completing-read "Find recent file:" recentf-list #'ok)))))

(use-package deadgrep
  :ensure-system-package rg
  :bind (("C-c H" . #'deadgrep)))

(use-package vertico
  :ensure t
  :demand
  :config
  (vertico-mode t)
  (vertico-mouse-mode)
  (set-face-attribute 'vertico-mouse nil :inherit nil)
  (savehist-mode)
  :custom
  (vertico-count 22)
  (vertico-cycle t)
  :bind (:map vertico-map
              ("C-'"           . vertico-quick-exit)
              ("C-c '"         . vertico-quick-insert)
              ("<return>"      . exit-minibuffer)
              ("C-m"           . vertico-insert)
              ("C-c SPC"       . vertico-quick-exit)
              ("C-<backspace>" . vertico)
              ("DEL"           . vertico-directory-delete-char)))

(use-package consult
  :bind* (("C-c r"     . consult-recent-file))
  :bind (("C-c i"     . consult-imenu)
         ("C-c b"     . consult-project-buffer)
         ("C-x b"     . consult-buffer)
         ("C-c B"     . consult-bookmark)
         ("C-c `"     . flymake-goto-next-error)
         ("C-c h"     . consult-ripgrep)
         ("C-c y"     . consult-yank-pop)
         ("C-x C-f"   . find-file)
         ("C-c C-h a" . describe-symbol)
         )
  :custom
  (consult-narrow-key (kbd ";"))
  (completion-in-region-function #'consult-completion-in-region)
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  (consult-project-root-function #'deadgrep--project-root) ;; ensure ripgrep works
  (consult-preview-key '(:debounce 0.25 any))
  )

(use-package marginalia
  :config (marginalia-mode))

(use-package orderless
  :custom (completion-styles '(orderless basic)))

(use-package ctrlf
  :config (ctrlf-mode))

(use-package prescient
  :config (prescient-persist-mode))

(use-package embark
  :bind ("C-c e" . #'embark-act)
  :bind ("C-<escape>" . #'embark-act))

(use-package embark-consult :after (embark consult))
(use-package embark-vc :after embark)

(use-package vterm
  ;; I'm very confident this package will not be easy to install on a windows machine.
  ;; At this point I don't think it worth the effort to figure it out. So skip.
  :if (not (eq system-type 'windows-nt))
  :ensure-system-package cmake
  :custom
  (vterm-timer-delay 0.05)
  :config
  (defun pt/turn-off-chrome ()
    (hl-line-mode -1)
    ;;(yascroll-bar-mode nil)
    (display-line-numbers-mode -1))

  (defun pt/project-run-vterm ()
    "Invoke `vterm' in the project's root.

 Switch to the project specific term buffer if it already exists."
    (interactive)
    (let* ((project (project-current))
           (buffer (format "*vterm %s*" (consult--project-name (project-root project)))))
      (unless (buffer-live-p (get-buffer buffer))
        (unless (require 'vterm nil 'noerror)
          (error "Package 'vterm' is not available"))
        (vterm buffer)
        (vterm-send-string (concat "cd " (project-root project)))
        (vterm-send-return))
      (switch-to-buffer buffer)))

  :hook (vterm-mode . pt/turn-off-chrome))

(use-package vterm-toggle
  :if (not (eq system-type 'windows-nt))
  :custom
  (vterm-toggle-fullscreen-p nil "Open a vterm in another window.")
  (vterm-toggle-scope 'project)
  :bind (("C-c t" . #'vterm-toggle)
         :map vterm-mode-map
         ("C-\\" . #'popper-cycle)
         ("s-t" . #'vterm) ; Open up new tabs quickly
         ("s-v" . #'vterm-yank)
         ("C-y" . #'vterm-yank)
         ("C-h" . #'vterm-send-backspace)
         ))

(use-package yasnippet
  :defer 15 ;; takes a while to load, so do it async
  :diminish yas-minor-mode
  :config (yas-global-mode)
  :custom (yas-prompt-functions '(yas-completing-prompt)))

(use-package erlang)

(use-package markdown-mode
  :hook (gfm-mode . visual-line-mode)
  :bind (:map markdown-mode-map ("C-c C-s a" . markdown-table-align))
  :mode ("\\.md$" . gfm-mode))

(use-package restclient
  :mode ("\\.restclient$" . restclient-mode))

(use-package which-key
  :config
  (which-key-mode))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  ;; (defun wfv/lsp-mode-setup-completion ()
  ;;   (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
  ;;         '(orderless)))
  :hook ((erlang-mode . lsp)
         (python-mode . lsp)
         ; (lsp-completion-mode . wfv/lsp-mode-setup-completion)
         (lsp-mode . lsp-enable-which-key-integration))
  :custom
  (lsp-completion-provider :none) ;; using +corfu+ the built in completion-at-point
  (lsp-modeline-diagnostics-enable t)
  (lsp-modeline-workspace-status-enable t)
  (lsp-modeline-code-actions-enable t)
  :commands lsp)

(use-package lsp-ui
  :custom
  (lsp-ui-sideline-enable t)
  (lsp-ui-doc-enable t)
  :commands lsp-ui-mode)

(use-package lsp-treemacs
  :commands lsp-treemacs-errors-list)

;; consult-lsp-diagnostics
;;     Select diagnostics from current workspace. Pass prefix argument to search all workspaces
;; consult-lsp-symbols
;;     Select symbols from current workspace. Pass prefix argument to search all workspaces.
;; consult-lsp-file-symbols
;;     Interactively select a symbol from the current file, in a manner similar to consult-line. 
(use-package consult-lsp)

;; Something about corfu and orderless appears to cause a segfault in
;; emacs 29.4. Until that gets fixed I'm going to stick with the built
;; in completion function and `consult'. I may still like to try corfu
;; in the future though.
(bind-key* "C-." #'completion-at-point)

;; Use `consult-completion-in-region' if Vertico is enabled.
;; Otherwise use the default `completion--in-region' function.
(setq completion-in-region-function
      (lambda (&rest args)
        (apply (if vertico-mode
                   #'consult-completion-in-region
                 #'completion--in-region)
               args)))

;; (use-package corfu
;;   :custom
;;   (corfu-cycle t)
;;   (corfu-auto t)
;;   (corfu-auto-delay 0.1)
;;   (corfu-auto-prefix 2)
;;   (corfu-quit-no-match 'separator)
;;   :init
;;   (global-corfu-mode))

;; (use-package kind-icon
;;   :after corfu
;;   :config
;;   (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; (use-package orderless
;;   :custom
;;   ;; (orderless-style-dispatchers '(orderless-affix-dispatch))
;;   ;; (orderless-component-separator #'orderless-escapable-split-on-space)
;;   (completion-styles '(orderless partial-completion basic))
;;   (completion-category-defaults nil)
;;   (completion-category-overrides '((file (styles partial-completion)))))

(require 'tramp)
(setq remote-file-name-inhibit-locks t)

;; Needs to be called from recentf's :init
;; todo: make this into a use-package invocation
(defun pt/customize-tramp ()

  (setq tramp-default-method "ssh"
        tramp-verbose 1
        remote-file-name-inhibit-cache nil
        tramp-use-ssh-controlmaster-options nil
        tramp-default-remote-shell "/bin/bash"
        tramp-connection-local-default-shell-variables
        '((shell-file-name . "/bin/bash")
          (shell-command-switch . "-c")))

  (connection-local-set-profile-variables 'tramp-connection-local-default-shell-profile
                                          '((shell-file-name . "/bin/bash")
                                            (shell-command-switch . "-c")))
  ;;(add-to-list 'tramp-remote-path 'tramp-own-remote-path)

  )

  ;; (lsp-register-client
  ;;  (make-lsp-client :new-connection (lsp-stdio-connection "gopls")
  ;;                   :major-modes '(go-mode go-dot-mod-mode)
  ;;                   :language-id "go"
  ;;                   :remote? t
  ;;                   :priority 0
  ;;                   :server-id 'gopls-remote
  ;;                   :completion-in-comments? t
  ;;                   :library-folders-fn #'lsp-go--library-default-directories
  ;;                   :after-open-fn (lambda ()
  ;;                                    ;; https://github.com/golang/tools/commit/b2d8b0336
  ;;                                    (setq-local lsp-completion-filter-on-incomplete nil))))

(setq c-default-style "linux"
      c-basic-offset 3)

(defvar victor-mono-ligatures
  '("</" "</>" "/>" "~-" "-~" "~@" "<~" "<~>" "<~~"
    "~>" "~~" "~~>" ">=" "<=" "<!--" "##" "###" "####"
    "|-" "-|" "|->" "<-|" ">-|" "|-<" "|=" "|=>" ">-"
    "<-" "<--" "-->" "->" "-<" ">->" ">>-" "<<-" "<->"
    "->>" "-<<" "<-<" "==>" "=>" "=/=" "!==" "!=" "<=="
    ">>=" "=>>" ">=>" "<=>" "<=<" "=<=" "=>=" "<<=" "=<<"
    ".-" ".=" "=:=" "=!=" "==" "===" "::" ":=" ":>"
    ":<" ">:" "<:" ";;" "<|" "<|>" "|>" "<>" "<$"
    "<$>" "$>" "<+" "<+>" "+>" "?=" "/=" "/==" "/\\"
    "\\/" "__" "&&" "++" "+++"))
(use-package ligature
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode victor-mono-ligatures)
  ;; Enables ligature checks globally in all buffers.  You can also do it
  ;; per mode with `ligature-mode'.
  (global-ligature-mode t))

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))

(defun my-default-window-setup ()
  "Called by emacs-startup-hook to set up my initial window configuration."
  (org-agenda-list))

(add-hook 'dired-mode-hook 'dired-omit-mode)
(add-hook 'emacs-startup-hook #'my-default-window-setup)

(provide 'init)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(centered-window yasnippet which-key vterm-toggle vertico tree-sitter-langs sudo-edit smartparens shut-up restclient prescient orderless nerd-icons-corfu mood-line marginalia lsp-ui lsp-treemacs ligature kind-icon ivy fancy-compilation erlang embark-vc embark-consult diminish deadgrep ctrlf corfu consult-lsp consult-eglot company all-the-icons-dired)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
