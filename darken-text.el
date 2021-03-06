;;; darken-text.el --- Darken font-faced text in emacs.

;; Copyright © 2012 Sébastien Gross <seb•ɑƬ•chezwam•ɖɵʈ•org>

;; Author: Sébastien Gross <seb•ɑƬ•chezwam•ɖɵʈ•org>
;; Keywords: emacs, 
;; Created: 2012-11-15
;; Last changed: 2012-11-16 16:12:41
;; Licence: WTFPL, grab your copy here: http://sam.zoy.org/wtfpl/

;; This file is NOT part of GNU Emacs.

;;; Commentary:
;;
;;  This allows you to darken all font-face withing a buffer thus all pure
;;  text will be emphasized. This is usefull while editing xml, html,
;;  LaTeX files.
;;
;;  Put this darken-text directory somewhere within your ~/.emacs.d, then in
;;  your emacs init file:
;;
;;  (add-to-list 'load-path "~/.emacs.d/lib/darken-text")
;;  (global-set-key (kbd "M-.") 'darken-text-mode)

;;; Code:


(eval-when-compile
  (require 'cl))

(defgroup darken-text nil "darken-text customization."
  :group 'convenience)

(defcustom darken-text-color "#3e4446"
  "Color to use to darken text."
  :group 'darken-text
  :type 'color)

(defcustom darken-text-ignore
  '((ALL . (font-lock-string-face))
    (latex-mode . (font-latex-sectioning-0-face
		   font-latex-sectioning-1-face
		   font-latex-sectioning-2-face
		   font-latex-sectioning-3-face
		   font-latex-sectioning-4-face
		   font-latex-sectioning-5-face))
    (nxml-mode . (nxml-text)))
  "list of font-face to ignore. ALIST which CAR is a `major-mode'
and CDR is a list of face name to ignore. Special mode \"ALL\" is
used as default values to be ignored for all modes."
  :group 'darken-text
  :type '(alist :key-type symbol :value-type (repeat face)))


(defcustom darken-text-intangible nil
  "Add intanglible property to darken-text overlay."
  :group 'darken-text
  :type 'boolean)

(defun darken-text-on (&optional min max)
  "Activate darken-text between point MIN and MAX. Use
`point-min' and `point-max' if undefined."
  (let ((min (or min (point-min)))
	(max (or max (point-max)))
	(ignore-faces (union
		       (cdr (assoc 'ALL darken-text-ignore))
		       (cdr (assoc major-mode darken-text-ignore)))))
    (save-excursion
      (goto-char min)
      (loop for P = (next-property-change (point))
	    while (and P (<= P max))
	    when (let ((face (get-text-property (point) 'face)))
		   (and face
			(not (intersection
			      ignore-faces
			      (if (listp face)
				  face
				(list face))))))
	    do (let ((ov (make-overlay (point) P)))
		 (overlay-put ov 'face
			      (cons 'foreground-color darken-text-color))
		 (when darken-text-intangible
		   (overlay-put ov 'intangible t)))
	    do (goto-char P)))))

(defun darken-text-off (&optional min max)
  "Deactivate darken-text between point MIN and MAX. Use
`point-min' and `point-max' if undefined."
  (let ((min (or min (point-min)))
	(max (or max (point-max))))
    (loop for ov in (overlays-in min max)
	  when (let ((face (overlay-get ov 'face)))
		 (when (listp face)
		   (string= darken-text-color (cdr (overlay-get ov 'face)))))
	  do (delete-overlay ov))))

(defun darken-text-update ()
  "Darken line"
  (darken-text-off (point-at-bol) (point-at-eol))
  (darken-text-on (point-at-bol) (point-at-eol)))

;;;###autoload
(define-minor-mode darken-text-mode
  "Toggle darken-text-mode."
  nil " DrkT" nil
  (if darken-text-mode
      (progn
	(darken-text-on)
	(add-hook 'post-command-hook 'darken-text-update nil t))
    (darken-text-off)
    (remove-hook 'post-command-hook 'darken-text-update t)))

(provide 'darken-text)

;; darken-text.el ends here
