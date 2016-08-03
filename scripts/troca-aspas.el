;;; troca-aspas.el -- Substitui aspas "antigas" por “novas” nos
;;; arquivos de tradução do projeto GNU.

;; Copyright (C) 2015 Sergio Durigan Junior

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see
;; <http://www.gnu.org/licenses/>.

(defconst file-to-scan (pop argv))
(unless (and file-to-scan (file-readable-p file-to-scan))
  (error "Uso: emacs --script replace-quote.el ARQUIVO"))

(setq inside-quote nil)

(defun replace-quote-1 ()
  (goto-char (point-min))
  (while (re-search-forward "\\(msgid\\|\\\\\"\\|{\\|<\\|&ldquo;\\|&rdquo;\\)" 
nil 'move)
    (let ((str (match-string 1)))
      (cond

       ((string-equal str "msgid")
        (search-forward "msgstr"))

       ((string-equal str "<")
        (skip-chars-forward "^>"))

       ((string-equal str "{")
        (skip-chars-forward "^}"))

       ((string-equal str "\\\"")
        (if inside-quote
            (replace-match "”" t t)
          (replace-match "“" t t))
        (setq inside-quote (not inside-quote)))

       ((string-equal str "&ldquo;")
        (replace-match "“")
        (setq inside-quote t))

       ((string-equal str "&rdquo;")
        (replace-match "”")
        (setq inside-quote nil))))))

(defun replace-quote ()
  (find-file file-to-scan)
  ;; Se o modo PO estiver instalado, ele marca o arquivo como read-only
  (when (eq major-mode 'po-mode)
    (setq major-mode 'fundamental-mode)
    (setq buffer-read-only nil))
  (message "Processando arquivo %s" file-to-scan)
  (unless buffer-read-only
    (replace-quote-1)
    (and (buffer-modified-p) (save-buffer))))

(replace-quote)
