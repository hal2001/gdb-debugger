(require 'dash)

(defvar gdb-debugger-executable-list nil)

(defun --prepend-or-pop (f)
  (setq gdb-debugger-executable-list
        (cons f (--remove (string-equal it f) gdb-debugger-executable-list))))

(defun --nth-or-last (n list)
  (nth
   (let* ((len (length list))
          (i
           (if (and n (numberp n) (< n len))
               n (1- len))))
     (message "index -> %s" i)
     i)
   list))

(defun gdb-debugger-add-executable ()
  (interactive)
  (let ((file-name
         (file-truename
          (let ((match nil)
                (in-file))
            (while (not match)
              (let ((in (read-file-name "Executable: " nil nil t)))
                (if (setq match (and (file-exists-p in)
                                     (file-regular-p in)
                                     (file-executable-p in)))
                    (setq in-file in)
                  (message "Select executable file.")
                  (run-with-idle-timer 2))))
            in-file))))
    (--prepend-or-pop file-name)))

(defun gdb-debugger-debug (&optional n)
  (interactive "P")
  (let ((exec (car
               (if (and (numberp n) (<= 0 n) gdb-debugger-executable-list)
                   (--prepend-or-pop (--nth-or-last n gdb-debugger-executable-list))
                 (if gdb-debugger-executable-list
                     gdb-debugger-executable-list
                   (gdb-debugger-add-executable))))))
    (message "run -> %s" exec)
    (gdb (format "gdb -i=mi %s" exec))))

(let ((k (kbd "<f5>")))
  (if (key-binding k)
      (message "gdb-debugger: %s is already bound." k)
    (global-set-key k 'gdb-debugger-debug)))

(let ((k (kbd "C-x <f5>")))
  (if (key-binding k)
      (message "gdb-debugger: %s is already bound." k)
    (global-set-key k (lambda ()
                        (interactive)
                        (gdb-debugger-add-executable)
                        (gdb-debugger-debug)))))

(let ((k (kbd "C-x <f9>")))
  (if (key-binding k)
      (message "gdb-debugger: %s is already bound." k)
    (global-set-key k 'gud-break)))

(provide 'gdb-debugger)
