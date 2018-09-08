;+

; NAME: remove_image_brightness_waves

; PURPOSE: Calls on all other programs in group in order to remove the brightness waves found in the picture

; EXPLANATION: There are multiple functions that are required to remove the waves and this function condenses them all into one function so usage of it is easy.

; CALLING SEQUENCE: wave_removed_image_array = remove_image_brightness_waves(image, radius)

; INPUTS: image = A 1024 by 1024 BYTE array
; 	  radius = The number of pixels above or below the ring to be measured in the array

; OPTIONAL INPUTS:

; OPTIONAL KEYWORD INPUTS:

; OUTPUTS: removed_wave_array = A one dimensional array that has removed the brightness waves and is ready to be plotted on a graph.

; EXAMPLE: wave_removed_image_array = remove_image_brightness_waves(image, 50)

; PROCEDURES USED: crop_ring(), create_image_brightness_array(), create_extracted_wave_array()

; REVISION HISTORY:
; 6/20 Kuchta: Ready to be implimented

function remove_image_brightness_waves, image, radius

; Runs crop_ring and sets it equal to cropped_image. This uses the
; inputted image and radius.
cropped_image = crop_ring(image, radius)

; Doubles the radius to simplify later code. This is also the number
; of rows in the image.
height = 2 * radius

; Sets image_brightness_array to be the brightness of the cropped image.
image_brightness_array = create_image_brightness_array(cropped_image, height)

; Sets extracted_wave_array to be the extracted wave array.
extracted_wave_array = create_extracted_wave_array(image)

; Creates a one dimensional integer array with 1024 units.
removed_wave_array = MAKE_ARRAY(1024,1,/INTEGER, VALUE = 0)

; Makes a for loop that runs through each integer in the array.
FOR i=0, 1023, 1 DO BEGIN

; Makes extracted_wave_brightness be equal to the value at some point
; in the array.
    extracted_wave_brightness = extracted_wave_array(i,0)
    
; Makes extracted_wave_brightness become a longword integer so that
; math functions can be done to it.
    extracted_wave_brightness_long = long(extracted_wave_brightness)

; Adjusts extracted_wave_brightness_long so that it removes the
; correct amount based on the height of the image. Each element in the
; removed_wave_array is set to the image_brightness_array minus the
; adjusted wave brightness.
    removed_wave_array(i,0) = image_brightness_array(i,0) - extracted_wave_brightness_long * height / 1024

; Creates an if statement in case for some reason the value in
; removed_wave_array is less than 0.
    IF (removed_wave_array(i,0) LT 0) THEN BEGIN

; Sets the value of a negative integer to be zero.
       removed_wave_array(i,0) = 0

; Ends the if statement.
    ENDIF

; Ends the for loop.
ENDFOR

; Returns the vertical brightness array with waves removed.
return, removed_wave_array

; Ends the function.
end

