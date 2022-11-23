;; POSIX clocks (Linux)

;;;; Copyright (C) 2016 Andy Wingo <wingo@pobox.com>
;;;;
;;;; This library is free software; you can redistribute it and/or
;;;; modify it under the terms of the GNU Lesser General Public
;;;; License as published by the Free Software Foundation; either
;;;; version 3 of the License, or (at your option) any later version.
;;;;
;;;; This library is distributed in the hope that it will be useful,
;;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; Lesser General Public License for more details.
;;;;
;;;; You should have received a copy of the GNU Lesser General Public
;;;; License along with this library; if not, write to the Free Software
;;;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

;;; Fibers uses POSIX clocks to be able to preempt schedulers running
;;; in other threads after regular timeouts in terms of thread CPU time.

(define-module (fibers posix-clocks)
  #:use-module (system foreign)
  #:use-module (ice-9 match)
  #:use-module (rnrs bytevectors)
  #:export (init-posix-clocks
            clock-nanosleep
            clock-getcpuclockid
            pthread-getcpuclockid
            pthread-self))

(define exe (dynamic-link))

(define clockid-t int32)
(define time-t long)
(define pid-t int)
(define pthread-t unsigned-long)

(define TIMER_ABSTIME 1)

(define CLOCK_REALTIME 0)
(define CLOCK_MONOTONIC 1)
(define CLOCK_PROCESS_CPUTIME_ID 2)
(define CLOCK_THREAD_CPUTIME_ID 3)
(define CLOCK_MONOTONIC_RAW 4)
(define CLOCK_REALTIME_COARSE 5)
(define CLOCK_MONOTONIC_COARSE 6)

(define init-posix-clocks
  (lambda () *unspecified*))

(define pthread-self
  (let* ((ptr (dynamic-pointer "pthread_self" exe))
         (proc (pointer->procedure pthread-t ptr '())))
    (lambda ()
      (proc))))

(define clock-getcpuclockid
  (let* ((ptr (dynamic-pointer "clock_getcpuclockid" exe))
         (proc (pointer->procedure int ptr (list pid-t '*)
                                   #:return-errno? #t)))
    (lambda* (pid #:optional (buf (make-bytevector (sizeof clockid-t))))
      (call-with-values (lambda () (proc pid (bytevector->pointer buf)))
        (lambda (ret errno)
          (unless (zero? ret) (error (strerror errno)))
          (bytevector-s32-native-ref buf 0))))))

(define pthread-getcpuclockid
  (let* ((ptr (dynamic-pointer "pthread_getcpuclockid" exe))
         (proc (pointer->procedure int ptr (list pthread-t '*)
                                   #:return-errno? #t)))
    (lambda* (pthread #:optional (buf (make-bytevector (sizeof clockid-t))))
      (call-with-values (lambda () (proc pthread (bytevector->pointer buf)))
        (lambda (ret errno)
          (unless (zero? ret) (error (strerror errno)))
          (bytevector-s32-native-ref buf 0))))))

(define clock-nanosleep
  (let* ((ptr (dynamic-pointer "clock_nanosleep" exe))
         (proc (pointer->procedure int ptr (list clockid-t int '* '*))))
    (lambda* (clockid nsec #:key absolute? (buf (nsec->timespec nsec)))
      (let* ((flags (if absolute? TIMER_ABSTIME 0))
             (ret (proc clockid flags buf buf)))
        (cond
         ((zero? ret) (values #t 0))
         ((eqv? ret EINTR) (values #f (timespec->nsec buf)))
         (else (error (strerror ret))))))))
