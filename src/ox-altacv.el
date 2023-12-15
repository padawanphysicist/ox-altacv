;;; ox-altacv.el --- AltaCV Back-End for Org Export Engine -*- lexical-binding: t; -*-

;; Copyright (C) 2007-2020 Free Software Foundation, Inc.

;; Author: Victor Santos <victor_santos@fisica.ufc.br>
;; Keywords: org, wp, tex

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; This library implements an AltaCV LaTeX back-end, derived from the
;; LaTeX one.

;;; Code:
(require 'ox-latex)

;; Install a default set-up for altacv export.
(unless (assoc "altacv" org-latex-classes)
  (add-to-list 'org-latex-classes
	       '("altacv"
		     "% Beginning of the document
\\documentclass[10pt,a4paper,ragged2e,withhyper]{altacv}
[NO-DEFAULT-PACKAGES]
[NO-PACKAGES]
% Change the page layout if you need to
\\geometry{left=1.25cm,right=1.25cm,top=1.5cm,bottom=1.5cm,columnsep=1.2cm}
% The paracol package lets you typeset columns of text in parallel
\\usepackage{paracol}
% Change the font if you want to, depending on whether
% you're using pdflatex or xelatex/lualatex
% WHEN COMPILING WITH XELATEX PLEASE USE
% xelatex -shell-escape -output-driver='xdvipdfmx -z 0' mmayer.tex
\\ifxetexorluatex
  % If using xelatex or lualatex:
  \\setmainfont{Lato}
\\else
  % If using pdflatex:
  \\usepackage[default]{lato}
\\fi
% Change the colours if you want to
\\definecolor{VividPurple}{HTML}{3E0097}
\\definecolor{SlateGrey}{HTML}{2E2E2E}
\\definecolor{LightGrey}{HTML}{666666}
% \\colorlet{name}{black}
% \\colorlet{tagline}{PastelRed}
\\colorlet{heading}{VividPurple}
\\colorlet{headingrule}{VividPurple}
% \\colorlet{subheading}{PastelRed}
\\colorlet{accent}{VividPurple}
\\colorlet{emphasis}{SlateGrey}
\\colorlet{body}{LightGrey}
% Change the bullets for itemize and rating marker
% for \\cvskill if you want to
\\renewcommand{\\cvItemMarker}{{\\small\\textbullet}}
\\renewcommand{\\cvRatingMarker}{\\faCircle}
% ...and the markers for the date/location for \\cvevent
% \\renewcommand{\\cvDateMarker}{\\faCalendar*[regular]}
% \\renewcommand{\\cvLocationMarker}{\\faMapMarker*}
\\usepackage{newfields}
[EXTRA]"
		 ("\\cvevent{%s}" . "\\cvevent*{%s}")
		 ("\\subsection{%s}" . "\\subsection*{%s}")
		 ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))))

;;; User-Configurable Variables

(defgroup org-export-altacv nil
  "Options specific for using the beamer class in LaTeX export."
  :tag "Org AltaCV"
  :group 'org-export
  :version "24.2")

;;; Define Back-End
(org-export-define-derived-backend 'altacv 'latex
  :menu-entry
  '(?l 1
       ((?B "As LaTeX buffer (AltaCV)" org-altacv-export-as-latex)
	(?b "As LaTeX file (AltaCV)" org-altacv-export-to-latex)
	(?P "As PDF file (AltaCV)" org-altacv-export-to-pdf)
	(?O "As PDF file and open (AltaCV)"
	    (lambda (a s v b)
	      (if a (org-altacv-export-to-pdf t s v b)
		(org-open-file (org-altacv-export-to-pdf nil s v b)))))))
  :options-alist
  '(
    (:latex-class "LATEX_CLASS" nil "altacv" t)
    (:tagline "TAGLINE" nil "" t)
    (:email "EMAIL" nil "" t)
    (:address "ADDRESS" nil "" t)
    (:github "GITHUB" nil "" t)
    (:gitlab "GITLAB" nil "" t)
    (:location "LOCATION" nil "" t)
    (:homepage "HOMEPAGE" nil "" t)
    (:linkedin "LINKEDIN" nil "" t)
    (:orcid "ORCID" nil "" t)
    (:phone "PHONE" nil "" t)
    (:photo "PHOTO" nil "" t)
    (:column_ratio "COLUMN_RATIO" nil "0.5" t)
    )
  :translate-alist '(
		             (headline . org-altacv-headline)
                     (template . org-altacv-template)
                     ))

(dolist (backend org-export-registered-backends)
  (if (eq 'altacv (org-export-backend-name backend))
    (setf (car (org-export-backend-menu backend))
          ?w)))

;;; Transcode Functions
(defun org-altacv--format-cvevent (headline contents info)
  (concat (format "\\cvevent{%s}{%s}{%s--%s}{%s}\n"
                      (org-export-data
                (org-element-property :title headline)
	            info)
                      (org-element-property :COMPANY headline)
                      (org-element-property :FROM headline)
                      (org-element-property :TO headline)
                      (org-element-property :LOCATION headline)
                      )
          contents))
(defun org-altacv--format-cvachievement (headline contents info)
  (format "\\cvachievement{\\%s}{%s}{%s}\n"
          (org-element-property :ICON headline)
          (org-export-data
           (org-element-property :title headline)
	       info)
          (replace-regexp-in-string
           "\n$" "" 
           contents)))
(defun org-altacv--format-cvskill (headline contents info)
  (format "\\cvskill{%s}{%s}\n"                  
          (org-export-data
           (org-element-property :title headline)
	       info)
          (org-element-property :SKILL_LEVEL headline)))
(defun org-altacv--format-cvref (headline contents info)
  (format "\\cvref{%s}{%s}{%s}{%s}\n"                  
          (org-export-data
           (org-element-property :title headline)
	       info)
          (org-element-property :REF_INST headline)
          (org-element-property :REF_EMAIL headline)
          (org-element-property :REF_ADDRESS headline)))

;;;; Headline
(defun org-altacv-headline (headline contents info)
  "Transcode HEADLINE element into Beamer code.
CONTENTS is the contents of the headline.  INFO is a plist used
as a communication channel.
Depending on the tag of the headline it is considered a section, an event...."
  (let ((level (org-export-get-relative-level headline info))
        (tags (org-element-property :tags headline))
        (title (org-export-data
                (org-element-property :title headline)
	            info))
        (entry-type (org-element-property :CVENTRY headline)))    
    (cond
     ((string= entry-type "cvsection")
      (concat (format "\\cvsection{%s}\n" title)
              contents))
     ((string= entry-type "cvevent")
      (org-altacv--format-cvevent headline contents info))
     ((string= entry-type "cvachievement")
      (org-altacv--format-cvachievement headline contents info))
     ((string= entry-type "cvskill")
      (org-altacv--format-cvskill headline contents info))
     ((string= entry-type "cvref")
      (org-altacv--format-cvref headline contents info))
     ((string= entry-type "cvtag")
      (concat (format "\\cvtag{%s}" title)))
     (t (format "\\section{%s}\n" title)))
    ))
(defun org-altacv-template (contents info)
  "Return complete document string after Beamer conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (concat
   ;; Time-stamp   
   (format-time-string "%% Created %Y-%m-%d %a %H:%M\n")
   ;; Document class and packages.
   (org-latex-make-preamble info)
   "\\begin{document}\n"
   ;; Author
   (let ((author (and (plist-get info :with-author)
			(let ((auth (plist-get info :author)))
			  (and auth (org-export-data auth info))))))
     (format "\\name{%s}\n" author))
   ;; Tagline
   (let ((tagline (plist-get info :tagline)))
     (format "  \\tagline{%s}\n" tagline))
   ;; Photo
   (let ((photo (plist-get info :photo)))
     (format "\\photoR{2.5cm}{%s}\n" photo))
   "\\personalinfo{%\n"
   ;; Email
   (let ((email (plist-get info :email)))
     (format "  \\email{%s}\n" email))
   ;; Address
   (let ((addr (plist-get info :address)))
     (format "  \\mailaddress{%s}\n" addr))
   ;; Location
   (let ((loc (plist-get info :location)))
     (format "  \\location{%s}\n" loc))
   ;; LinkedIn
   (let ((ln (plist-get info :linkedin)))
     (format "  \\linkedin{%s}\n" ln))
   ;; Homepage
   (let ((homepage (plist-get info :homepage)))
     (format "  \\homepage{%s}\n" homepage))
   ;; GitHub
   (let ((gh-uname (plist-get info :github)))
     (format "  \\github{github.com/%s}\n" gh-uname))
   ;; GitLab
   (let ((gl-uname (plist-get info :gitlab)))
     (format "  \\gitlab{gitlab.com/%s}\n" gl-uname))
   ;; OrcID
   (let ((orcid (plist-get info :orcid)))
     (format "  \\orcid{%s}\n" orcid))
   ;; OrcID
   (let ((phone (plist-get info :phone)))
     (format "  \\phone{%s}\n" phone))
   "}\n"
   "\\makecvheader\n"
   ;; Column ratio
   (let ((column-ratio (plist-get info :column_ratio)))
     (format "\\columnratio{%s}" column-ratio))
   contents
   "\\end{document}"
   ))

;;; Commands
;;;###autoload
(defun org-altacv-export-as-latex
  (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer as a Beamer buffer.
If narrowing is active in the current buffer, only export its
narrowed part.
If a region is active, export that region.
A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.
When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.
When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.
When optional argument BODY-ONLY is non-nil, only write code
between \"\\begin{document}\" and \"\\end{document}\".
EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.
Export is done in a buffer named \"*Org BEAMER Export*\", which
will be displayed when `org-export-show-temporary-export-buffer'
is non-nil."
  (interactive)
  (org-export-to-buffer 'altacv "*Org AltaCV Export*"
    async subtreep visible-only body-only ext-plist (lambda () (LaTeX-mode))))
;;;###autoload
(defun org-altacv-export-to-latex
  (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer as a Beamer presentation (tex).
If narrowing is active in the current buffer, only export its
narrowed part.
If a region is active, export that region.
A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through
the `org-export-stack' interface.
When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.
When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.
When optional argument BODY-ONLY is non-nil, only write code
between \"\\begin{document}\" and \"\\end{document}\".
EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.
Return output file's name."
  (interactive)
  (let ((file (org-export-output-file-name ".tex" subtreep)))
    (org-export-to-file 'altacv file
      async subtreep visible-only body-only ext-plist)))
;;;###autoload
(defun org-altacv-export-to-pdf
  (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer as a Beamer presentation (PDF).
If narrowing is active in the current buffer, only export its
narrowed part.
If a region is active, export that region.
A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through
the `org-export-stack' interface.
When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.
When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.
When optional argument BODY-ONLY is non-nil, only write code
between \"\\begin{document}\" and \"\\end{document}\".
EXT-PLIST, when provided, is a property list with external
parameters overriding Org default settings, but still inferior to
file-local settings.
Return PDF file's name."
  (interactive)
  (let ((file (org-export-output-file-name ".tex" subtreep)))
    (org-export-to-file 'altacv file
      async subtreep visible-only body-only ext-plist
      (lambda (file) (org-latex-compile file)))))
;;;###autoload
(defun org-altacv-publish-to-latex (plist filename pub-dir)
  "Publish an Org file to a Beamer presentation (LaTeX).
FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.
Return output file name."
  (org-publish-org-to 'altacv filename ".tex" plist pub-dir))
;;;###autoload
(defun org-altacv-publish-to-pdf (plist filename pub-dir)
  "Publish an Org file to a Beamer presentation (PDF, via LaTeX).
FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.
Return output file name."
  ;; Unlike to `org-beamer-publish-to-latex', PDF file is generated in
  ;; working directory and then moved to publishing directory.
  (org-publish-attachment
   plist
   ;; Default directory could be anywhere when this function is
   ;; called.  We ensure it is set to source file directory during
   ;; compilation so as to not break links to external documents.
   (let ((default-directory (file-name-directory filename)))
     (org-latex-compile
      (org-publish-org-to
       'altacv filename ".tex" plist (file-name-directory filename))))
   pub-dir))
(provide 'ox-altacv)
;; Local variables:
;; generated-autoload-file: "org-loaddefs.el"
;; End:
;;; ox-altacv.el ends here