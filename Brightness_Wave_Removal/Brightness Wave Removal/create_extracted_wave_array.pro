;+

; NAME: create_extracted_wave_array

; PURPOSE: Creates a one dimensional array that adds up all the wave values vertically and is ready for subtraction from the actual image array.

; EXPLANATION: Adds up all pixel brightnesses vertically with bright spots then adjusts the final value by the number of pixels with value equal to zero because that means they have been cut out.

; CALLING SEQUENCE: wave_array = create_extracted_wave_array(image)

; INPUTS: image = A 1024 by 1024 BYTE array

; OPTIONAL INPUTS:

; OPTIONAL KEYWORD INPUTS:

; OUTPUTS: wave_array = One dimensional array with integer values for brightness.

; EXAMPLE: wave_array = create_extracted_wave_array(image)

; PROCEDURES USED: brighten_image()

; REVISION HISTORY:
 
function create_extracted_wave_array, image

; Sets image_brightened to be the image with brightness values from 0
; to 14 and anything above that limit is set to 0.
image_brightened = brighten_image(image, 0, 15, /CUT_LIMIT_SWITCH)

; Creates a one dimensional with 1024 integers that are set to 0.
wave_array = MAKE_ARRAY(1024,1, /INTEGER, VALUE = 0)

; Creates a for loop to run through each column seperately.
FOR i=0, 1023, 1 DO BEGIN

; Resets the vertical brightness to 0 and also makes it a longword integer.
    vertical_brightness = 0
    vertical_brightness_long = long(vertical_brightness)

; Resets the count of pixels with 0 brightness.
    vertical_empty_pixel_count = 0

; Creates a for loop to run through each element in a column.
    FOR j=0, 1023, 1 DO BEGIN

; Sums up all vertical brightness in a column.
          vertical_brightness_long = vertical_brightness_long + image_brightened(i, j)
          
; If a pixel has a brightness of zero then the count of missing pixels
; is increased by one.
	  IF (image_brightened(i,j) EQ 0) THEN BEGIN
	     vertical_empty_pixel_count++
	  ENDIF	  
    ENDFOR
    
; Subtracts 1024 by the number of missing pixels to find the number of
; pixels with values other than 0.
    vertical_empty_pixel_count = 1024 - vertical_empty_pixel_count

; Adjusts the vertical brightness based on the number of missing
; pixels so that the missing pixels are averaged to be waves.
    vertical_brightness_long = vertical_brightness_long * 1024
    vertical_brightness_long = vertical_brightness_long / vertical_empty_pixel_count

; Sets the value of each element of the wave array to be equal to its
; wave brightness sum.
    wave_array[i] = vertical_brightness_long
ENDFOR

; Returns the vertical brightness array for the waves that is ready
; for subtraction.
return, wave_array

end
