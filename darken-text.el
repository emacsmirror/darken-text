;;; darken-text.el --- Darken font-faced text in emacs.

;; Copyright © 2012 Sébastien Gross <seb•ɑƬ•chezwam•ɖɵʈ•org>

;; Author: Sébastien Gross <seb•ɑƬ•chezwam•ɖɵʈ•org>
;; Keywords: emacs, 
;; Created: 2012-11-15
;; Last changed: 2012-11-15 17:25:50
;; Licence: WTFPL, grab your copy here: http://sam.zoy.org/wtfpl/

;; This file is NOT part of GNU Emacs.

;;; Commentary:
;; 


;;; Code:


(eval-when-compile
  (require 'cl))

(defgroup darken-text nil "darken-text customization."
  :group 'convenience)

(defcustom darken-text-color "#3e4446"
  "Color to use to darken text."
  :group 'darken-text
  :type 'color)

(defcustom darken-text-ignore nil
  "list of font-face to ignore."
  :group 'darken-text
  :type '(repeat face))


(defcustom darken-text-intangible nil
  "Add intanglible property to darken-text overlay."
  :group 'darken-text
  :type 'boolean)

(defun darken-text-on (&optional min max)
  "Activate darken-text between point MIN and MAX. Use
`point-min' and `point-max' if undefined."
  (let ((min (or min (point-min)))
	(max (or max (point-max))))
    (save-excursion
      (goto-char min)
      (loop for P = (next-property-change (point))
	    while (and P (<= P max))
	    when (let ((face (get-text-property (point) 'face)))
		   (and face
			(not (intersection
			      darken-text-ignore
			      (if (listp face)
				  face
				(list face))))))
	    do (let ((ov (make-overlay (point) P)))
		 (overlay-put ov 'face `(foreground-color . ,darken-text-color))
		 (when darken-text-intangible
		   (overlay-put ov 'intangible t)))
	    do (goto-char P)))))

(defun darken-text-off (&optional min max)
  "Deactivate darken-text between point MIN and MAX. Use
`point-min' and `point-max' if undefined."
  (let ((min (or min (point-min)))
	(max (or max (point-max))))
    (loop for ov in (overlays-in min max)
	  when (or
		(string= darken-text-color (cdr (overlay-get ov 'face))))
	  do (delete-overlay ov))))

(defun darken-text-update ()
  "Darken line"
  (darken-text-off (point-at-bol) (point-at-eol))
  (darken-text-on (point-at-bol) (point-at-eol)))

(define-minor-mode darken-text-mode
  "Toggle darken-text-mode."
  nil " D" nil
  (if darken-text-mode
      (progn
	(darken-text-on)
	(add-hook 'post-command-hook 'darken-text-update nil t))
    (darken-text-off)
    (remove-hook 'post-command-hook 'darken-text-update t)))

(provide 'darken-text)

;; darken-text.el ends here
