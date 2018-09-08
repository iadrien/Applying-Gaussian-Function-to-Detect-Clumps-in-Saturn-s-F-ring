;+

; NAME: create_image_brightness_array

; PURPOSE: Creates a one dimensional array where the brightness of each pixel is added together into a column.

; EXPLANATION: Adds up all the brightnesses vertically then sets a value in the one dimensional array equal to that sum. This can then be plotted.

; CALLING SEQUENCE: image_array = create_image_brightness_array(image, radius)

; INPUTS:  image = A 1024 by 1024 BYTE array
; 	  	height = height of array starting at 0.

; OPTIONAL INPUTS:

; OPTIONAL KEYWORD INPUTS:

; OUTPUTS: vertical_brightness_array = A one dimensional array with 1024 integers chere each is the sum of the pixel brightness of each column in the inputed image.

; EXAMPLE: image_array = create_image_brightness_array(image, 50)

; PROCEDURES USED: 

; REVISION HISTORY:
; 6/20 Kuchta: Ready for implementation.
 
function create_image_brightness_array, cropped_image, height

; Creates a one dimensional array with 1024 integers that are all zero.
vertical_brightness_array = MAKE_ARRAY(1024,1, /INTEGER, VALUE = 0)

; Creates a for loop to run through each column seperately.
FOR i=0, 1023, 1 DO BEGIN

; Resets the vertical brightness to 0 and also makes it a longword integer.
    vertical_brightness = 0
    vertical_brightness_long = long(vertical_brightness)

; Creates a for loop to run through each element in a column. Changes
; based on height of image because the image is usually cropped.
    FOR j=0, height, 1 DO BEGIN

; Sums up all vertical brightness in a column.
          vertical_brightness_long = vertical_brightness_long + cropped_image(i, j)
    ENDFOR

; Sets each value in the one dimensional array to be the sum of the
; column of the image.
    vertical_brightness_array[i] = vertical_brightness_long
ENDFOR

; Returns the vertical brightness sum array of the inputted image.
return, vertical_brightness_array

end
