;+

; NAME: crop_ring

; PURPOSE: Cuts off all of the image except a certain amount around the ring.

; EXPLANATION: Finds row of pixels that is brightest then adjusts the image to only show pixels up to a certain distance away from that row.

; CALLING SEQUENCE: cropped_image = crop_ring(image, radius)

; INPUTS: image = A 1024 by 1024 BYTE array
; 	       radius = The number of pixels above or below the ring to be kept in the image

; OPTIONAL INPUTS:

; OPTIONAL KEYWORD INPUTS:

; OUTPUTS: cropped_image = A 1024 by radius*2 array that has the brightest row of pixels in the image.

; EXAMPLE: cropped_image = crop_ring(image, 50)

; PROCEDURES USED:

; REVISION HISTORY:
; 6/20 Kuchta: Ready for implementation.

function crop_ring, image, radius

; Creates two integers for dealing with the brightest line and what
; row that is.
brightest_line = 0
brightest_line_row = 0

; Creates a for loop for going through each row.
FOR j = 0, 1023, 1 DO BEGIN

; Resets the horizontal brightness to zero for each new row.
    horizontal_brightness = 0

; Creates a for loop to go through each element in a row.
    FOR i = 0, 1023, 1 DO BEGIN
    	
; Sums up the brightness of a specific row.
	horizontal_brightness = image(i , j) + horizontal_brightness

; Ends for loop at end of row.
    ENDFOR

; Creates an if statement to test if the current rows brightness is
; greater than the brightest line already tested.
    IF (horizontal_brightness GT brightest_line) THEN BEGIN

; Sets the brightest line to be equal to the rows brightness.
       brightest_line = horizontal_brightness

; Sets the brightest_line_row to be the row number.
       brightest_line_row = j

    ENDIF

ENDFOR

; Creates two integers that are the bottom and top of the image. If
; the image has a different size then go ahead and change this.
lower_row = 0
upper_row = 1023

; In case the radius is less than zero the absolute value of it is taken.
radius = ABS(radius)

; Creates an if statement to test if the lowest row is at the bottom
; of the picture or lower. If so then the lowest row is not changed.
IF (brightest_line_row - radius LE lower_row) THEN BEGIN

; Prints a message to inform user.
   print, 'Lowest row is at bottom of picture.'

; If the row - radius is not at the bottom then the lower_row is set
; to the row - radius.
ENDIF ELSE BEGIN

; Sets the lower bound of the image to a certain amount below the
; brightest row.
   lower_row = brightest_line_row - radius
ENDELSE

; Creates an if statement that does the same as the previous statement
; except for the top row instead.
IF (brightest_line_row + radius GE upper_row) THEN BEGIN
   print, 'Highest row is at top of picture.'
ENDIF ELSE BEGIN
   upper_row = brightest_line_row + radius
ENDELSE

; Sets cropped_image to be the image except only on certain rows.
cropped_image = image[ *, lower_row : upper_row]

; Returns the cropped image with the brightest row in the middle.
return, cropped_image

end
