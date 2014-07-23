;;; package -- Summary
;;; Commentary:
;;; Code:

;; -- Mode preferences --
(winner-mode 1)
(ido-mode t)
(menu-bar-mode -1)
(blink-cursor-mode t)
(delete-selection-mode t)
(smartscan-mode t)
(global-flycheck-mode t)

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; -- Variables --
(setq
 save-abbrevs nil
 make-backup-files nil
 auto-save-default nil
 backup-inhibited t
 x-select-enable-clipboard t
 suggest-key-bindings t
 column-number-mode t
 show-trailing-whitespace t
 pcomplete-ignore-case t
 eshell-cmpl-ignore-case t
 ag-highlight-search t
 fill-column 80)

;; nice paren-style highlight ;)
(defun expression-style-show-paren ()
  "make show-paren expression only for lisp modes"
  (make-variable-buffer-local 'show-paren-style)
  (setq show-paren-style 'expression))
(add-hook 'emacs-lisp-mode-hook 'expression-style-show-paren)

;; make cursor type a bar
(modify-all-frames-parameters (list (cons 'cursor-type 'bar)))

(defadvice shell (after do-not-query-shell-exit
                        first (&optional buffer)
                        activate)
  "Do not query exit confirmation for shell process buffer."
  (interactive)
  (set-process-query-on-exit-flag (get-process "shell") nil))

(setq-default
 display-buffer-reuse-frames t
 abbrev-mode t)

;; -- Hooks --
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'prog-mode-hook 'linum-mode)
(add-hook 'prog-mode-hook 'pretty-symbols-mode)

(setq pretty-symbol-categories '(lambda relational))

;; -- Abbrev --
(define-abbrev-table 'global-abbrev-table
  '(
    ;; math/unicode symbols
    ("8bes" "bundle exec rspec")
    ("8be" "bundle exec")
    ("8gpl" "git pull")
    ("8rdbm" "bundle exec rake db:migrate db:rollback && bundle exec rake db:migrate")
    ))

;; -- some automodes --
(add-to-list 'auto-mode-alist '("\\.scss$" . css-mode))
(add-to-list 'auto-mode-alist '("\\.css$" . css-mode))
(add-to-list 'auto-mode-alist '("\\.js$" . js-mode))

(provide 'init-utils)
;;; init-utils.el ends here
