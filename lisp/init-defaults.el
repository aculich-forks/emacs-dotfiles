;;; package -- Summary
;;; Commentary:
;;; Code:

;; -- Mode preferences --
(winner-mode 1)
(menu-bar-mode -1)
(blink-cursor-mode t)
(delete-selection-mode t)
(smartscan-mode t)
(global-flycheck-mode t)
(wrap-region-global-mode)
(global-undo-tree-mode)
(ido-vertical-mode)

;; diminish
(diminish 'undo-tree-mode)
(diminish 'abbrev-mode)

;; add pretty symbols for lambdas and relationals
(setq pretty-symbol-categories '(lambda))

;; -- Variables --
(setq
 ;; please, share the clipboard
 x-select-enable-clipboard t
 save-abbrevs nil
 ;; no backups
 make-backup-files nil
 auto-save-default nil
 backup-inhibited t
 ;; set initial mode
 initial-major-mode 'emacs-lisp-mode
 initial-scratch-message ";;This be scratch Buffer.\n"
 ;; underline at next line
 x-underline-at-descent-line t
 suggest-key-bindings t
 column-number-mode t
 show-trailing-whitespace t
 ;; ignore case completion on emacs lisp and find files
 eshell-cmpl-ignore-case t
 pcomplete-ignore-case t
 ;; more itens to recentf
 recentf-max-saved-items 250
 ;; more memory. it's the distant future
 gc-cons-threshold 20000000
 ;; Real emacs knights don't use shift to mark things
 shift-select-mode nil)

(setq-default
 display-buffer-reuse-frames t
 abbrev-mode t
 fill-column 100
 ;; no more two spaces to end sentences. Jeez.
 sentence-end-double-space nil)

;; -- Hooks --
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'prog-mode-hook 'linum-mode)
(add-hook 'prog-mode-hook 'pretty-symbols-mode)

(defadvice shell (after do-not-query-shell-exit
                        first (&optional buffer)
                        activate)
  "Do not query exit confirmation for shell process buffer."
  (interactive)
  (let* ((shell-processes (remove-if-not
                           (lambda (process) (string-match-p "shell" (process-name process)))
                           (process-list))))
    (dolist (p shell-processes)
      (set-process-query-on-exit-flag p nil))))

;; -- Abbrev --
(define-abbrev-table 'global-abbrev-table
  '(("8bes" "bundle exec rspec")
    ("8be" "bundle exec")
    ("8rdbm" "bundle exec rake db:migrate db:rollback && bundle exec rake db:migrate")
    ("8bejs" "bundle exec jekyll serve --watch")))

;; -- some automodes --
(add-to-list 'auto-mode-alist '("\\.scss$" . css-mode))
(add-to-list 'auto-mode-alist '("\\.css$" . css-mode))
(add-to-list 'auto-mode-alist '("\\.js$" . js-mode))

(provide 'init-defaults)
;;; init-defaults.el ends here
