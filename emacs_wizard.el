;;; emacs_wizard.el --- An example of an Emacs initial set-up wizard -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Simon Pugnet
;;
;; Author: Simon Pugnet <https://www.polaris64.net/>
;; Maintainer: Simon Pugnet <simon@polaris64.net>
;; Created: September 27, 2020
;; Modified: September 27, 2020
;; Version: 0.0.1
;; Keywords: wizard set-up configuration
;; Homepage: https://github.com/polaris64/emacs_wizard
;; Package-Requires: ((emacs 27.1) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  An example of an Emacs initial set-up wizard
;;
;;; Code:

(defvar inhibit-emacs-wizard-link nil
  "If unset, the Emacs Wizard link will appear on the fancy start-up screen.")

(defvar inhibit-emacs-wizard-menu-item nil
  "If unset, the Emacs Wizard link will appear in the Help menu.")

(defface emacs-wizard-button
  '((t :foreground "#202020" :background "grey" :box (:line-width 2 :color nil :style released-button)))
  "Face used for Emacs set-up wizard buttons"
  :group 'emacs-wizard-faces)

(defface emacs-wizard-info
  '((t :foreground "green"))
  "Face used for Emacs set-up wizard buttons"
  :group 'emacs-wizard-faces)

(defun emacs-wizard-invoke-spell (fn)
  "Invoke a given spell and insert the result into a new window.

FN is the spell (function) to call, which should return a string
containing the appropriate configuration."
  (let (
        (config-txt (funcall fn))
        (config-win (split-window-right))
        (config-buf (get-buffer-create "*New config*")))
    (set-window-buffer config-win config-buf)
    (with-current-buffer config-buf
      (erase-buffer)
      (emacs-lisp-mode)
      (insert config-txt))))

(defun emacs-wizard-post-spell (buf)
  "Display information after the wizard has generated a configuration.

BUF is the buffer to erase and to which to insert the messages."
  (with-current-buffer buf
    (setq buffer-read-only nil)
    (erase-buffer)
    (insert (propertize "Emacs initial set-up wizard" 'face '(:height 112 :underline t)))
    (insert "\n\nThe wizard has cast his spell!\n\n")
    (insert "To the right you can see your newly-created Emacs configuration. This file simply needs to be saved as \"init.el\" in your Emacs configuration directory and next time you start Emacs it will be used.\n\n")
    (insert-button " Click here to save your new configuration to init.el "
                   'face 'emacs-wizard-button
                   'action (lambda (_button) (emacs-wizard-save-config))
                   'help-echo "mouse-2, RET: Save the new configuration"
                   'follow-link t)
    (goto-char (point-min))))

(defun emacs-wizard-save-config ()
  "Save the \"*New config*\" buffer as the user's init.el."
  (message "Saving init.el...")
  (let ((config-buf (get-buffer-create "*New config*")))
    (with-current-buffer config-buf

      ; TODO For this prototype, the file is saved to init.el.wizard to avoid
      ; overwriting an actual config. Change this back after proper backup
      ; procedures have been implemented.
      (setq buffer-file-name (expand-file-name "~/.emacs.d/init.el.wizard"))

      (save-buffer))))

(defun emacs-wizard-spell-default ()
  "Default spell: return default Emacs configuration."
  "(message \"This is the default config\")\n\n; Hide Emacs Wizard from the start-up screen\n(setq inhibit-emacs-wizard-link t)")

(defun emacs-wizard-spell-evil ()
  "Evil spell: return a Vim-like Emacs configuration with evil-mode."
  "(message \"This is the evil config\")\n\n; Hide Emacs Wizard from the start-up screen\n(setq inhibit-emacs-wizard-link t)")

(defun emacs-wizard-spell-cua ()
  "CUA spell: return an Emacs configuration with standard CUA key-bindings."
  "(message \"This is the CUA config\")\n\n; Hide Emacs Wizard from the start-up screen\n(setq inhibit-emacs-wizard-link t)")

(defun emacs-wizard-add-to-fancy-startup-screen ()
  "Add a link to the wizard to the fancy start-up screen."
  (setq fancy-startup-text
        `((:face (variable-pitch font-lock-comment-face)
        "Welcome to "
        :link ("GNU Emacs"
                ,(lambda (_button) (browse-url "https://www.gnu.org/software/emacs/"))
                "Browse https://www.gnu.org/software/emacs/")
        ", one component of the "
        :link
        ,(lambda ()
        (if (eq system-type 'gnu/linux)
                `("GNU/Linux"
                ,(lambda (_button) (browse-url "https://www.gnu.org/gnu/linux-and-gnu.html"))
                "Browse https://www.gnu.org/gnu/linux-and-gnu.html")
                `("GNU" ,(lambda (_button)
                        (browse-url "https://www.gnu.org/gnu/thegnuproject.html"))
                "Browse https://www.gnu.org/gnu/thegnuproject.html")))
        " operating system.\n\n"
        :face (variable-pitch (:foreground "blue" :height 110 :slant oblique))
        :link ("First time user? Run the Emacs set-up wizard." ,(lambda (_button) (emacs-wizard-start)))
        "  Initial Emacs set-up wizard\n\n"
        :face variable-pitch
        :link ("Emacs Tutorial" ,(lambda (_button) (help-with-tutorial)))
        "\tLearn basic keystroke commands"
        ,(lambda ()
        (let* ((en "TUTORIAL")
                (tut (or (get-language-info current-language-environment
                                                'tutorial)
                        en))
                (title (with-temp-buffer
                        (insert-file-contents
                                (expand-file-name tut tutorial-directory)
                                ;; We used to read only the first 256 bytes of
                                ;; the tutorial, but that prevents the coding:
                                ;; setting, if any, in file-local variables
                                ;; section to be seen by insert-file-contents,
                                ;; and results in gibberish when the language
                                ;; environment's preferred encoding is
                                ;; different from what the file-local variable
                                ;; says.  One case in point is Hebrew.
                                nil)
                        (search-forward ".")
                        (buffer-substring (point-min) (1- (point))))))
                ;; If there is a specific tutorial for the current language
                ;; environment and it is not English, append its title.
                (if (string= en tut)
                ""
                (concat " (" title ")"))))
        "\n"
        :link ("Emacs Guided Tour"
                ,(lambda (_button)
                (browse-url "https://www.gnu.org/software/emacs/tour/"))
                "Browse https://www.gnu.org/software/emacs/tour/")
        "\tOverview of Emacs features at gnu.org\n"
        :link ("View Emacs Manual" ,(lambda (_button) (info-emacs-manual)))
        "\tView the Emacs manual using Info\n"
        :link ("Absence of Warranty" ,(lambda (_button) (describe-no-warranty)))
        "\tGNU Emacs comes with "
        :face (variable-pitch (:slant oblique))
        "ABSOLUTELY NO WARRANTY\n"
        :face variable-pitch
        :link ("Copying Conditions" ,(lambda (_button) (describe-copying)))
        "\tConditions for redistributing and changing Emacs\n"
        :link ("Ordering Manuals" ,(lambda (_button) (view-order-manuals)))
        "\tPurchasing printed copies of manuals\n"
        "\n"))))

(defun emacs-wizard-add-to-help-menu ()
  "Add a link to the wizard to the Help menu."
  (require 'easymenu)
  (easy-menu-add-item
   nil
   '("help-menu")
   ["Emacs initial set-up wizard" emacs-wizard-start t]
   "emacs-psychotherapist"))

(defun emacs-wizard-user-has-config ()
  "Check for the presence of init.el and return t if it exists."
  (and user-init-file (file-exists-p user-init-file)))

(defun emacs-wizard-start ()
  "Start the Emacs initial set-up wizard."
  (interactive)
  (let ((wizard-buffer (get-buffer-create "*Emacs Set-up*")))
    (switch-to-buffer wizard-buffer)
    (with-current-buffer wizard-buffer
      (erase-buffer)
      (visual-line-mode)
      (insert (propertize "Emacs initial set-up wizard" 'face '(:height 112 :underline t)))
      (insert "\n\nClick on the buttons below with the mouse or use the arrow keys or Ctrl-N and Ctrl-P to move the cursor to a button and press Enter/Return to press it.")
      (insert (propertize "\n\nPlease select how you want your copy of Emacs to be configured\n\n" 'face 'emacs-wizard-info))
      (insert-button " Keep the default Emacs configuration "
                     'face 'emacs-wizard-button
                     'action (lambda (_button) (emacs-wizard-invoke-spell 'emacs-wizard-spell-default) (emacs-wizard-post-spell wizard-buffer))
                     'help-echo "mouse-2, RET: Keep the default Emacs configuration"
                     'follow-link t)
      (insert "\nThis changes nothing and keeps Emacs the way it is when freshly installed.")
      (insert "\nThis option is best if you are already familiar with Emacs or if you want full control over your personal configuration.")
      (insert "\n\n")
      (insert-button " Use a Vim-like configuration "
                     'face 'emacs-wizard-button
                     'action (lambda (_button) (emacs-wizard-invoke-spell 'emacs-wizard-spell-evil) (emacs-wizard-post-spell wizard-buffer))
                     'help-echo "mouse-2, RET: Create a Vim-like configuration"
                     'follow-link t)
      (insert "\nThis makes Emacs behave just like Vi or Vim.")
      (insert "\nThis option is best if you are familiar with Vi or Vim and want a similar experience in Emacs.")
      (insert "\n\n")
      (insert-button " Make Emacs behave like other common text editors "
                     'face 'emacs-wizard-button
                     'action (lambda (_button) (emacs-wizard-invoke-spell 'emacs-wizard-spell-cua) (emacs-wizard-post-spell wizard-buffer))
                     'help-echo "mouse-2, RET: Create a common configuration"
                     'follow-link t)
      (insert "\nThis enables key bindings such as Ctrl-C to copy, Ctrl-Z to undo, which match other common text editors.")
      (insert "\nThis option is best if you are unfamiliar with Emacs and Vi/Vim and want Emacs to behave like other programs do.")
      (setq buffer-read-only t)
      (goto-char (point-min)))))

; Add the wizard link to the fancy start-up screen unless it has explicitly been
; hidden
(unless (or inhibit-emacs-wizard-link (emacs-wizard-user-has-config))
  (emacs-wizard-add-to-fancy-startup-screen))

; Add the wizard link to the "Help" menu unless it has explicitly been hidden
(unless inhibit-emacs-wizard-menu-item
  (emacs-wizard-add-to-help-menu))

(provide 'emacs_wizard)
;;; emacs_wizard.el ends here
