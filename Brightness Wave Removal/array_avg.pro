;+

; NAME: array_avg

; PURPOSE: Finds average of one dimensional array.

; EXPLANATION: Takes a one dimensional integer array with 1024 numbers
; then averages them so a plot of the one dimensional array will have
; a good range.

; CALLING SEQUENCE: avg_brightness = array_avg(image_brightness_array)

; INPUTS: image_brightness_array = A one dimensional array with 1024
; integers.

; OPTIONAL INPUTS:

; OPTIONAL KEYWORD INPUTS:

; OUTPUTS: array_avg = a longword integer with the average of the array.

; EXAMPLE: avg_brightness = array_avg(image_brightness_array)

; PROCEDURES USED: 

; REVISION HISTORY:
; 6/21 Kuchta: Ready to be implimented
; 6/24 Kuchta: Added line if the value of the array is 0 then skip
; that part and do not include in average

function array_avg, image_brightness_array

; Creates a longword integer that is set at zero.
array_avg = long(0)

; Creates an integer that counts the number of array values greater
; than 0
number_filled_pixels = 1024

; Creates a for loop that runs through each element in a one
; dimensional array with only one row.
FOR i = 0, 1023, 1 DO BEGIN

; Creates an if statement to test if an array value is greater than zero
   IF (image_brightness_array(i,0) GT 0) THEN BEGIN
; Sums up all the values in the array.
      array_avg = image_brightness_array(i,0) + array_avg
   ENDIF ELSE BEGIN
; If the array value is zero then the number of pixels to average is
; subtracted by one
      number_filled_pixels--
   ENDELSE
ENDFOR

; Divides by the number of filled elements in the array to get an average.
array_avg = array_avg / number_filled_pixels

; Return the average so a graph can be adjusted for each image.
return, array_avg

end
