;;; package -- Summary
;;; Commentary:
;;; Code:
(require 'ruby-electric)
(require 'inf-ruby)
(require 'rspec-mode)
(require 'ac-robe)
(require 'robe)
(require 'ruby-block)

(diminish 'ruby-electric-mode)
(diminish 'auto-fill-function)
(diminish 'ruby-block-mode)

;; auto modes
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.ru$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.jbuilder$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\GuardFile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\Vagrantfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\Gemfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\Godfile$" . ruby-mode))

;; hook auxiliary modes to ruby mode
(add-hook 'ruby-mode-hook 'robe-mode)
(add-hook 'ruby-mode-hook 'ruby-electric-mode)
(add-hook 'ruby-mode-hook 'rspec-mode)

(add-hook 'robe-mode-hook
          (lambda () (add-to-list 'ac-sources 'ac-source-robe)))
(add-hook 'ruby-mode-hook
          (lambda () (add-to-list 'ac-sources 'ac-source-yasnippet)))

;; fix for rspec and pry
(add-hook 'after-init-hook 'inf-ruby-switch-setup)
(setenv "PAGER" (executable-find "cat"))
;; add <Pry.config.pager = false if ENV["EMACS"]> to .pryrc

;; toggle ruby-block highlight to both keyword and line
(ruby-block-mode t)
(setq ruby-block-highlight-toggle 'overlay)
(setq ruby-block-highlight-face 'show-paren-match)

;; don't indent parenthesis in a weird way
(setq ruby-deep-indent-paren-style nil)

;; do not add encoding automagically
(setq ruby-insert-encoding-magic-comment nil)

;; inf ruby stuff
(defun ruby-send-buffer ()
  "Send whole buffer to inferior process."
  (interactive)
  (ruby-send-region (point-min) (point-max)))

;; Fix annoying sole close paren. Thanks to Mr. DGutov
(defadvice ruby-indent-line (after unindent-closing-paren activate)
  "Indent sole parenthesis in loca's way."
  (let ((column (current-column))
        indent offset)
    (save-excursion
      (back-to-indentation)
      (let ((state (syntax-ppss)))
        (setq offset (- column (current-column)))
        (when (and (eq (char-after) ?\))
                   (not (zerop (car state))))
          (goto-char (cadr state))
          (setq indent (current-indentation)))))
    (when indent
      (indent-line-to indent)
      (when (> offset 0) (forward-char offset)))))

;; ruby-electric playing nice with wrap region
(defadvice ruby-electric-quote (around first ()
                                       activate)
  "Make electric quote play nice with wrap region."
  (if (use-region-p)
      (wrap-region-trigger arg (string last-command-event))
    ad-do-it))

(defadvice ruby-electric-curlies (around first ()
                                         activate)
  "Make electric quote play nice with wrap region."
  (if (use-region-p)
      (wrap-region-trigger arg (string last-command-event))
    ad-do-it))

(defadvice ruby-electric-matching-char (around first ()
                                               activate)
  "Make electric quote play nice with wrap region."
  (if (use-region-p)
      (wrap-region-trigger arg (string last-command-event))
    ad-do-it))

;; -- Rspec stuff --
(defadvice rspec-compile
  (before rspec-save-before-compile (A-FILE-OR-DIR &optional opts) activate)
  "Save current buffer before running spec.  This remove the annoying save confirmation."
  (save-some-buffers (lambda () (string-match "\\.rb" (buffer-name  (current-buffer))))))

(defun rspec-spec-or-target-other-window-no-change-window ()
  "Just like rspec-find-spec-or-target-other-window but does not change the current window."
  (interactive)
  (rspec-find-spec-or-target-other-window)
  (other-window 1))

;; -- keybindings --
(define-key rspec-mode-verifiable-keymap (kbd "y") 'rspec-spec-or-target-other-window-no-change-window)
(define-key rspec-mode-verifiable-keymap (kbd "u") 'rspec-find-spec-or-target-other-window)
(define-key rspec-mode-verifiable-keymap (kbd "e") 'rspec-find-spec-or-target-find-example-other-window)
(define-key rspec-mode-verifiable-keymap (kbd "w") 'rspec-toggle-spec-and-target-find-example)

(defvar ruby-mode-custom-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "b") 'ruby-send-buffer)
    (define-key map (kbd "r") 'ruby-send-region)
    (define-key map (kbd "v") 'ruby-refactor-extract-local-variable)
    (define-key map (kbd "m") 'ruby-refactor-extract-to-method)
    (define-key map (kbd "l") 'ruby-refactor-extract-to-let)
    map))
(define-key ruby-mode-map (kbd "C-c r") ruby-mode-custom-map)


;; ===================================================================
;; will be merged probably
(defcustom rspec-snippets-fg-syntax 1
  "When 0, use full syntax for FactoryGirl snippets. When 1, use full syntax if
FactoryGirl::Syntax::Methods is not included in the spec_helper file, and uses the concise syntax
otherwise. When 2, use the concise syntax."
  :type 'boolean
  :group 'rspec-mode)

(defun rspec-project-root (&optional directory)
  "Finds the root directory of the project by walking the directory tree until it finds a rake file."
  (let ((directory (file-name-as-directory (or directory default-directory))))
    (cond ((rspec-root-directory-p directory)
           (error "Could not determine the project root."))
          ((file-exists-p (expand-file-name "Rakefile" directory)) directory)
          ((file-exists-p (expand-file-name "Gemfile" directory)) directory)
          (t (rspec-project-root (file-name-directory (directory-file-name directory)))))))

(defun rspec--include-fg-syntax-methods-p ()
  "Check wether FactoryGirl::Syntax::Methods is included in spec_helper"
  (with-temp-buffer
    (let* ((root-path (rspec-project-root))
           (spec-helper-path (concat root-path "spec/spec_helper.rb"))
           (uses-factory-girl-regexp "include +FactoryGirl::Syntax::Methods"))
      (with-temp-buffer
        (insert-file-contents spec-helper-path)
        (cond
         ((= 0 rspec-snippets-fg-syntax) nil)
         ((= 1 rspec-snippets-fg-syntax) (re-search-forward uses-factory-girl-regexp nil t))
         ((= 2 rspec-snippets-fg-syntax) t))))))

(defun rspec-snippets-fg-method-prefix (method)
  "Return FactoryGirl method for snippet aware of FactoryGirl::Syntax::Methods inclusion in the spec_helper file."
  (if (rspec--include-fg-syntax-methods-p)
      method
    (concat "FactoryGirl." method)))
;; ======================================================================

(provide 'init-ruby)
;;; init-ruby.el ends here
