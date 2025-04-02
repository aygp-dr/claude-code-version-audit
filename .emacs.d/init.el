;; Claude Code Version Audit - Emacs Configuration
;; This file configures Emacs for working with the audit repository

;; Package system setup
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Ensure use-package is installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Magit configuration
(use-package magit
  :bind (("C-x g" . magit-status))
  :config
  (setq magit-repository-directories
        '(("/home/jwalsh/projects/aygp-dr/claude-code-version-audit" . 0)
          ("/home/jwalsh/projects/aygp-dr/claude-code-version-audit/claude-code-repo" . 1)))
  ;; Configure commit message to use trailers
  (setq magit-commit-trailer-style 'separated)
  (setq git-commit-trailer-lines
        '(("Co-authored-by" . "Claude <noreply@anthropic.com>")
          ("Reviewed-by" . "jwalsh")))
  ;; Configure git commit template to include trailers
  (setq git-commit-setup-hook
        (append git-commit-setup-hook
                '(git-commit-setup-changelog-support
                  git-commit-turn-on-auto-fill
                  git-commit-propertize-diff
                  git-commit-save-message))))

;; Forge configuration for GitHub integration
(use-package forge
  :after magit
  :config
  ;; Configure repositories
  (add-to-list 'forge-alist
               '("claude-code-version-audit"
                 "github.com"
                 "aygp-dr/claude-code-version-audit"))
  (add-to-list 'forge-alist
               '("claude-code"
                 "github.com"
                 "anthropics/claude-code"))
  
  ;; Increase issue listing limit to ensure we can see older issues
  (setq forge-topic-list-limit '(100 . 0))
  
  ;; Custom function to fetch multiple pages of issues
  (defun fetch-all-claude-code-issues ()
    "Fetch all issues from the anthropics/claude-code repository."
    (interactive)
    (let ((repo (forge-get-repository "anthropics/claude-code")))
      (forge--pull repo nil nil :issues t :pullreqs nil :labels t :forge-pull-unrestricted t)))
  
  ;; Custom function to filter issues by version
  (defun filter-issues-by-version (version)
    "Filter forge issues by version string."
    (interactive "sVersion (e.g. 0.2.48): ")
    (let ((query (format "/is:issue /org:anthropics /repo:claude-code /body:%s" version)))
      (forge-visit-topic query))))

;; Org-mode configuration for issue tracking
(use-package org
  :config
  (setq org-directory "/home/jwalsh/projects/aygp-dr/claude-code-version-audit/issues")
  (setq org-default-notes-file (concat org-directory "/index.org"))
  
  ;; Custom function to create new issue template
  (defun create-issue-template (title)
    "Create a new issue template file."
    (interactive "sIssue title: ")
    (let* ((filename (concat (downcase (replace-regexp-in-string "[^a-zA-Z0-9]" "-" title)) ".org"))
           (filepath (concat org-directory "/" filename)))
      (find-file filepath)
      (insert (format "#+TITLE: %s\n#+AUTHOR: jwalsh\n#+DATE: %s\n\n* Issue Description\n\n" 
                     title
                     (format-time-string "%Y-%m-%d")))
      (save-buffer)))
  
  ;; Integrate with forge
  (defun org-create-issue-from-template ()
    "Create a GitHub issue from the current org file."
    (interactive)
    (when (and (eq major-mode 'org-mode)
               (string-prefix-p org-directory (buffer-file-name)))
      (let* ((title (or (org-get-title) "Untitled Issue"))
             (body (buffer-substring-no-properties (point-min) (point-max))))
        (forge-create-issue (forge-get-repository "aygp-dr/claude-code-version-audit")
                           title body)))))

;; Theme and UI settings
(use-package doom-themes
  :config
  (load-theme 'doom-nord t)
  (doom-themes-org-config))

;; Load custom settings if they exist
(when (file-exists-p "~/.emacs.d/custom.el")
  (load "~/.emacs.d/custom.el"))

(provide 'init)