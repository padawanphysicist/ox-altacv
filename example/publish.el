(require 'ox)
(require 'ox-altacv)

(setq this-directory (file-name-directory (or load-file-name buffer-file-name)))
(setq project-directory (file-name-directory (directory-file-name this-directory)))
(setq pub-directory (concat project-directory "public/"))

(unless (boundp 'org-publish-project-alist)
  (setq org-publish-project-alist nil))

(setq org-publish-timestamp-directory "/tmp/org-timestamps/")

(add-to-list
 'org-publish-project-alist
 `("pdf"
   :base-directory ,this-directory
   :base-extension "org"
   :publishing-directory ,(expand-file-name "pdf" pub-directory)
   :publishing-function org-altacv-publish-to-pdf))

(defun org-publish-example ()
  (org-publish-project "pdf" t))
