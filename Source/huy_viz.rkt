#lang racket
(require plot json 2htdp/batch-io)

;; This will make it possible to import this file into the Racket Weather driver program.
(provide (all-defined-out))

;; City names
(define boston-json "JSON/Boston,US.json")
(define lawrence-json "JSON/Lawrence,US.json")
(define lowell-json "JSON/Lowell,US.json")
(define worchester-json "JSON/Worcester,US.json")
(define manchester-json "JSON/Manchester,US.json")

;; List of city names
(define list-of-json-files
  (list boston-json lawrence-json lowell-json worchester-json manchester-json))

;; Variables defined here
(define json_file '())
(define json_string '())

(define list-n '())
(define temp '())

(define city-x-coord '(1 2 3 4 5 6 7 8 9 10))

;; list of min / max temps
(define list_min '())
(define list_max '())

;; list of avg temps
(define list_avg '())

;; List of plot stuff
(define list_plot '())

;; functions defined here.

;; Get min temps
(define (make_min list_temps list_min)
  (if (null? list_temps)
      ;; Return the list of mins
      list_min
      (make_min (cdr list_temps) (cons (hash-ref (hash-ref (car list_temps) 'temp) 'min) list_min))
  )
)

;; Get max temps
(define (make_max list_temps list_max)
  (if (null? list_temps)
      ;; Return the list of mins
      list_max
      (make_max (cdr list_temps) (cons (hash-ref (hash-ref (car list_temps) 'temp) 'max) list_max))
  )
)

;; Generate avg temps
(define (make_avg lst1 lst2 avg-lst)
          (if (and (null? lst1)
                   (null? lst2))
              avg-lst
              (make_avg (cdr lst1) (cdr lst2) (append avg-lst (list (/ (+ (car lst1) (car lst2)) 2))))))

;; Graph all the graph
(define (gen-graph lsts-of-cities name-of-city)
  (if (empty? lsts-of-cities)
      '()
      (begin
        ;; Read file in
        (set! json_file (read-file (car lsts-of-cities)))

        ;; Parse to string object
        (set! json_string (string->jsexpr json_file))

        ;; Output JSON string
        ;(display json_string)

        ;; Get min/max
        (set! list-n (hash-ref json_string 'list))
        (set! temp (hash-ref (car list-n) 'temp))

        ;; list of min / max temps
        (set! list_min (make_min list-n '()))
        (set! list_max (make_max list-n '()))

        ;; list of avg temps
        (set! list_avg (make_avg list_max list_min '()))

        (plot (list (lines (map vector  city-x-coord list_max)
                           #:color 'red
                           #:label "High"
                           )
                    (points (map vector  city-x-coord  list_max)
                            #:color 'red

                            )
                    (lines (map vector city-x-coord list_min)
                           #:color 'blue
                           #:label "Low"
                           )
                    (points (map vector city-x-coord list_min)
                            #:color 'blue

                            )
                    (lines (map vector city-x-coord list_avg)
                           #:color 'black
                           #:label "Average Temp"
                           )
                    (points (map vector city-x-coord list_avg)
                            #:color 'black
                            ))

              #:x-label "Days"
              #:y-label "Temperature in Fahrenheit"
              #:width 1400
              #:height 300
              #:title (string-append name-of-city " 10-Day Forecast Graph")))
))
