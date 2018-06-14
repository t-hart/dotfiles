;;; packages.el --- Helm Layer packages File
;;
;; Copyright (c) 2012-2018 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq helm-packages
      '(
        ace-jump-helm-line
        auto-highlight-symbol
        bookmark
        helm
        helm-ag
        helm-descbinds
        helm-flx
        helm-make
        helm-mode-manager
        helm-projectile
        helm-swoop
        helm-themes
        (helm-spacemacs-help :location local)
        (helm-spacemacs-faq :location local)
        helm-xref
        imenu
        persp-mode
        popwin
        projectile
        ))

;; Initialization of packages

(defun helm/init-ace-jump-helm-line ()
  (use-package ace-jump-helm-line
    :defer (spacemacs/defer)
    :init
    (with-eval-after-load 'helm
      (define-key helm-map (kbd "C-q") 'ace-jump-helm-line))))

(defun helm/pre-init-auto-highlight-symbol ()
  (spacemacs|use-package-add-hook auto-highlight-symbol
    :post-init
    ;; add some functions to ahs transient states
    (setq spacemacs--symbol-highlight-transient-state-doc
          (concat
           spacemacs--symbol-highlight-transient-state-doc
           "  Search: [_s_] swoop  [_b_] buffers  [_f_] files  [_/_] project"))
    (spacemacs/transient-state-register-add-bindings 'symbol-highlight
      '(("s" spacemacs/helm-swoop-region-or-symbol :exit t)
        ("b" spacemacs/helm-buffers-smart-do-search-region-or-symbol :exit t)
        ("f" spacemacs/helm-files-smart-do-search-region-or-symbol :exit t)
        ("/" spacemacs/helm-project-smart-do-search-region-or-symbol :exit t)))))

(defun helm/post-init-bookmark ()
  (spacemacs/set-leader-keys "fb" 'helm-filtered-bookmarks))

(defun helm/init-helm ()
  (use-package helm
    :defer (spacemacs/defer)
    :init
    (progn
      (add-hook 'helm-cleanup-hook #'spacemacs//helm-cleanup)
      ;; key bindings
      ;; Use helm to provide :ls, unless ibuffer is used
      (unless (configuration-layer/package-used-p 'ibuffer)
        (evil-ex-define-cmd "buffers" 'helm-buffers-list))
      ;; use helm by default for M-x, C-x C-f, and C-x b
      (unless (configuration-layer/layer-usedp 'smex)
        (global-set-key (kbd "M-x") 'helm-M-x))
      (global-set-key (kbd "C-x C-f") 'spacemacs/helm-find-files)
      (global-set-key (kbd "C-x b") 'helm-buffers-list)
      ;; use helm everywhere
      (spacemacs/set-leader-keys
        "<f1>" 'helm-apropos
        "a'"   'helm-available-repls
        "bb"   'helm-mini
        "Cl"   'helm-colors
        "ff"   'spacemacs/helm-find-files
        "fF"   'helm-find-files
        "fL"   'helm-locate
        "fr"   'helm-recentf
        "hdd"  'helm-apropos
        "hdF"  'spacemacs/helm-faces
        "hi"   'helm-info-at-point
        "hm"   'helm-man-woman
        "iu"   'helm-ucs
        "jI"   'helm-imenu-in-all-buffers
        "rm"   'helm-all-mark-rings
        "rl"   'helm-resume
        "rr"   'helm-register
        "rs"   'spacemacs/resume-last-search-buffer
        "ry"   'helm-show-kill-ring
        "sl"   'spacemacs/resume-last-search-buffer
        "sj"   'spacemacs/helm-jump-in-buffer)
      ;; search with grep
      (spacemacs/set-leader-keys
        "sgb"  'spacemacs/helm-buffers-do-grep
        "sgB"  'spacemacs/helm-buffers-do-grep-region-or-symbol
        "sgf"  'spacemacs/helm-files-do-grep
        "sgF"  'spacemacs/helm-files-do-grep-region-or-symbol
        "sgg"  'spacemacs/helm-file-do-grep
        "sgG"  'spacemacs/helm-file-do-grep-region-or-symbol)
      ;; various key bindings
      (spacemacs||set-helm-key "fel"  helm-locate-library)
      (spacemacs||set-helm-key "hdm" describe-mode)
      (spacemacs||set-helm-key "sww" helm-wikipedia-suggest)
      (spacemacs||set-helm-key "swg" helm-google-suggest)
      (with-eval-after-load 'helm-files
        (define-key helm-find-files-map
          (kbd "C-c C-e") 'spacemacs/helm-find-files-edit))
      ;; Add minibuffer history with `helm-minibuffer-history'
      (define-key minibuffer-local-map (kbd "C-c C-l") 'helm-minibuffer-history)
      ;; define the key binding at the very end in order to allow the user
      ;; to overwrite any key binding
      (add-hook 'emacs-startup-hook
                (lambda ()
                  (unless (configuration-layer/layer-usedp 'smex)
                    (spacemacs/set-leader-keys
                      dotspacemacs-emacs-command-key 'helm-M-x))))
      (helm-mode))
    :config
    (progn
      (spacemacs|hide-lighter helm-mode)
      (advice-add 'helm-grep-save-results-1 :after 'spacemacs//gne-init-helm-grep)
      ;; helm-locate uses es (from everything on windows which doesnt like fuzzy)
      (helm-locate-set-command)
      (setq helm-locate-fuzzy-match (string-match "locate" helm-locate-command))
      ;; alter helm-bookmark key bindings to be simpler
      (defun simpler-helm-bookmark-keybindings ()
        (define-key helm-bookmark-map (kbd "C-d") 'helm-bookmark-run-delete)
        (define-key helm-bookmark-map (kbd "C-e") 'helm-bookmark-run-edit)
        (define-key helm-bookmark-map
          (kbd "C-f") 'helm-bookmark-toggle-filename)
        (define-key helm-bookmark-map
          (kbd "C-o") 'helm-bookmark-run-jump-other-window)
        (define-key helm-bookmark-map (kbd "C-/") 'helm-bookmark-help))
      (with-eval-after-load 'helm-bookmark
        (simpler-helm-bookmark-keybindings))
      (when (configuration-layer/package-used-p 'winum)
        (define-key helm-buffer-map
          (kbd "RET") 'spacemacs/helm-find-buffers-windows)
        (define-key helm-generic-files-map
          (kbd "RET") 'spacemacs/helm-find-files-windows)
        (define-key helm-find-files-map
          (kbd "RET") 'spacemacs/helm-find-files-windows)))))

(defun helm/init-helm-ag ()
  (use-package helm-ag
    :defer (spacemacs/defer)
    :init
    (progn
      (setq helm-ag-use-grep-ignore-list t)
      ;; This overrides the default C-s action in helm-projectile-switch-project
      ;; to search using rg/ag/pt/whatever instead of just grep
      (with-eval-after-load 'helm-projectile
        (define-key helm-projectile-projects-map
          (kbd "C-s") 'spacemacs/helm-projectile-grep))

      ;; evilify the helm-grep buffer
      (evilified-state-evilify helm-grep-mode helm-grep-mode-map
        (kbd "RET") 'helm-grep-mode-jump-other-window
        (kbd "q") 'quit-window)

      (spacemacs/set-leader-keys
        ;; helm-ag marks
        "s`"  'helm-ag-pop-stack
        ;; opened buffers scope
        "sb"  'spacemacs/helm-buffers-smart-do-search
        "sB"  'spacemacs/helm-buffers-smart-do-search-region-or-symbol
        "sab" 'helm-do-ag-buffers
        "saB" 'spacemacs/helm-buffers-do-ag-region-or-symbol
        "skb" 'spacemacs/helm-buffers-do-ack
        "skB" 'spacemacs/helm-buffers-do-ack-region-or-symbol
        "srb" 'spacemacs/helm-buffers-do-rg
        "srB" 'spacemacs/helm-buffers-do-rg-region-or-symbol
        "stb" 'spacemacs/helm-buffers-do-pt
        "stB" 'spacemacs/helm-buffers-do-pt-region-or-symbol
        ;; current file scope
        "ss"  'spacemacs/helm-file-smart-do-search
        "sS"  'spacemacs/helm-file-smart-do-search-region-or-symbol
        "saa" 'helm-ag-this-file
        "saA" 'spacemacs/helm-file-do-ag-region-or-symbol
        ;; files scope
        "sf"  'spacemacs/helm-files-smart-do-search
        "sF"  'spacemacs/helm-files-smart-do-search-region-or-symbol
        "saf" 'helm-do-ag
        "saF" 'spacemacs/helm-files-do-ag-region-or-symbol
        "skf" 'spacemacs/helm-files-do-ack
        "skF" 'spacemacs/helm-files-do-ack-region-or-symbol
        "srf" 'spacemacs/helm-files-do-rg
        "srF" 'spacemacs/helm-files-do-rg-region-or-symbol
        "stf" 'spacemacs/helm-files-do-pt
        "stF" 'spacemacs/helm-files-do-pt-region-or-symbol
        ;; current dir scope
        "sd"  'spacemacs/helm-dir-smart-do-search
        "sD"  'spacemacs/helm-dir-smart-do-search-region-or-symbol
        "sad" 'spacemacs/helm-dir-do-ag
        "saD" 'spacemacs/helm-dir-do-ag-region-or-symbol
        "skd" 'spacemacs/helm-dir-do-ack
        "skD" 'spacemacs/helm-dir-do-ack-region-or-symbol
        "srd" 'spacemacs/helm-dir-do-rg
        "srD" 'spacemacs/helm-dir-do-rg-region-or-symbol
        "std" 'spacemacs/helm-dir-do-pt
        "stD" 'spacemacs/helm-dir-do-pt-region-or-symbol
        ;; current project scope
        "/"   'spacemacs/helm-project-smart-do-search
        "*"   'spacemacs/helm-project-smart-do-search-region-or-symbol
        "sp"  'spacemacs/helm-project-smart-do-search
        "sP"  'spacemacs/helm-project-smart-do-search-region-or-symbol
        "sap" 'spacemacs/helm-project-do-ag
        "saP" 'spacemacs/helm-project-do-ag-region-or-symbol
        "skp" 'spacemacs/helm-project-do-ack
        "skP" 'spacemacs/helm-project-do-ack-region-or-symbol
        "srp" 'spacemacs/helm-project-do-rg
        "srP" 'spacemacs/helm-project-do-rg-region-or-symbol
        "stp" 'spacemacs/helm-project-do-pt
        "stP" 'spacemacs/helm-project-do-pt-region-or-symbol))
    :config
    (progn
      (advice-add 'helm-ag--save-results :after 'spacemacs//gne-init-helm-ag)
      (evil-define-key 'normal helm-ag-map "SPC" spacemacs-default-map)
      (evilified-state-evilify helm-ag-mode helm-ag-mode-map
        (kbd "RET") 'helm-ag-mode-jump-other-window
        (kbd "gr") 'helm-ag--update-save-results
        (kbd "q") 'quit-window))))

(defun helm/init-helm-descbinds ()
  (use-package helm-descbinds
    :defer (spacemacs/defer)
    :init
    (progn
      (setq helm-descbinds-window-style 'split)
      (add-hook 'helm-mode-hook 'helm-descbinds-mode)
      (spacemacs/set-leader-keys "?" 'helm-descbinds))))

(defun helm/pre-init-helm-flx ()
  (spacemacs|use-package-add-hook helm
    :pre-config
    (progn
      ;; Disable for helm-find-files until performance issues are sorted
      ;; https://github.com/PythonNut/helm-flx/issues/9
      (setq helm-flx-for-helm-find-files nil)
      (helm-flx-mode))))

(defun helm/init-helm-flx ()
  (use-package helm-flx
    :defer (spacemacs/defer)))

(defun helm/init-helm-make ()
  (use-package helm-make
    :defer t
    :init
    (spacemacs/set-leader-keys
      "cc" 'helm-make-projectile
      "cm" 'helm-make)))

(defun helm/init-helm-mode-manager ()
  (use-package helm-mode-manager
    :defer t
    :init
    (spacemacs/set-leader-keys
      "hM"    'helm-switch-major-mode
      ;; "hm"    'helm-disable-minor-mode
      "h C-m" 'helm-enable-minor-mode)))

(defun helm/pre-init-helm-projectile ()
  ;; overwrite projectile settings
  (spacemacs|use-package-add-hook projectile
    :post-init
    (progn
      (setq projectile-switch-project-action 'helm-projectile)
      (spacemacs/set-leader-keys
        "pb"  'helm-projectile-switch-to-buffer
        "pd"  'helm-projectile-find-dir
        "pf"  'helm-projectile-find-file
        "pF"  'helm-projectile-find-file-dwim
        "ph"  'helm-projectile
        "pp"  'helm-projectile-switch-project
        "pr"  'helm-projectile-recentf
        "sgp" 'helm-projectile-grep))))

(defun helm/init-helm-projectile ()
  (use-package helm-projectile
    :commands (helm-projectile-switch-to-buffer
               helm-projectile-find-dir
               helm-projectile-dired-find-dir
               helm-projectile-recentf
               helm-projectile-find-file
               helm-projectile-grep
               helm-projectile
               helm-projectile-switch-project)
    :init
    (progn
      ;; needed for smart search if user's default tool is grep
      (defalias 'spacemacs/helm-project-do-grep 'helm-projectile-grep)
      (defalias
        'spacemacs/helm-project-do-grep-region-or-symbol
        'helm-projectile-grep))
    :config (define-key helm-projectile-find-file-map
              (kbd "RET") 'spacemacs/helm-find-files-windows)))

(defun helm/init-helm-spacemacs-help ()
  (use-package helm-spacemacs-help
    :commands (helm-spacemacs-help-dotspacemacs
               helm-spacemacs-help
               helm-spacemacs-help-faq
               helm-spacemacs-help-layers
               helm-spacemacs-help-packages
               helm-spacemacs-help-docs
               helm-spacemacs-help-toggles)
    :init (spacemacs/set-leader-keys
            "h ."   'helm-spacemacs-help-dotspacemacs
            "h SPC" 'helm-spacemacs-help
            "h f"   'helm-spacemacs-help-faq
            "h l"   'helm-spacemacs-help-layers
            "h p"   'helm-spacemacs-help-packages
            "h r"   'helm-spacemacs-help-docs
            "h t"   'helm-spacemacs-help-toggles)))

(defun helm/init-helm-spacemacs-faq ()
  (use-package helm-spacemacs-faq
    :commands helm-spacemacs-help-faq
    :init (spacemacs/set-leader-keys "h f" 'helm-spacemacs-help-faq)))

(defun helm/init-helm-swoop ()
  (use-package helm-swoop
    :defer (spacemacs/defer)
    :init
    (progn
      (setq helm-swoop-split-with-multiple-windows t
            helm-swoop-split-direction 'split-window-vertically
            helm-swoop-speed-or-color t
            helm-swoop-split-window-function 'helm-default-display-buffer
            helm-swoop-pre-input-function (lambda () ""))

      (defun spacemacs/helm-swoop-region-or-symbol ()
        "Call `helm-swoop' with default input."
        (interactive)
        (let ((helm-swoop-pre-input-function
               (lambda ()
                 (if (region-active-p)
                     (buffer-substring-no-properties (region-beginning)
                                                     (region-end))
                   (let ((thing (thing-at-point 'symbol t)))
                     (if thing thing ""))))))
          (call-interactively 'helm-swoop)))

      (spacemacs/set-leader-keys
        "ss"    'helm-swoop
        "sS"    'spacemacs/helm-swoop-region-or-symbol
        "s C-s" 'helm-multi-swoop-all)
      (defadvice helm-swoop (before add-evil-jump activate)
        (evil-set-jump)))))

(defun helm/init-helm-themes ()
  (use-package helm-themes
    :defer t
    :init
    (spacemacs/set-leader-keys
      "Ts" 'spacemacs/helm-themes)))

(defun helm/init-helm-xref ()
  (use-package helm-xref
    :commands (helm-xref-show-xrefs)
    :init
    (progn
      ;; This is required to make `xref-find-references' not give a prompt.
      ;; `xref-find-references' asks the identifier (which has no text property)
      ;; and then passes it to `lsp-mode', which requires the text property at
      ;; point to locate the references.
      ;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=29619
      (setq xref-prompt-for-identifier '(not xref-find-definitions
                                             xref-find-definitions-other-window
                                             xref-find-definitions-other-frame
                                             xref-find-references
                                             spacemacs/jump-to-definition))
      ;; Use helm-xref to display `xref.el' results.
      (setq xref-show-xrefs-function #'helm-xref-show-xrefs))))


(defun helm/post-init-imenu ()
  (spacemacs/set-leader-keys "ji" 'spacemacs/helm-jump-in-buffer))

(defun helm/post-init-popwin ()
  ;; disable popwin-mode while Helm session is running
  (add-hook 'helm-after-initialize-hook #'spacemacs//helm-prepare-display)
  ;;  Restore popwin-mode after a Helm session finishes.
  (add-hook 'helm-cleanup-hook #'spacemacs//helm-restore-display))

(defun helm/pre-init-persp-mode ()
  (spacemacs|use-package-add-hook persp-mode
    :post-config
    (setq
     spacemacs--persp-display-buffers-func 'spacemacs/persp-helm-mini
     spacemacs--persp-display-perspectives-func 'spacemacs/helm-perspectives)))

(defun helm/post-init-projectile ()
  (setq projectile-completion-system 'helm))