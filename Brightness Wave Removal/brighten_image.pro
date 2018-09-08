;+

; NAME: brighten_image

; PURPOSE: Adjusts an image so that all pixels with brightness above a certain limit are reduced to that limit. 
; 	   	     If it is then scaled so the lowest brightness is zero and the highest is 255 then alot more may be seen inside of the picture.

; EXPLANATION: Takes an image and then reduces the brightest pixels of an image to a certain level. 
; 	       	     Especially useful if tvscl is used on the returned image to see small brightness differences in the background.

; CALLING SEQUENCE: brightened_image = brighten_image(image)

; INPUTS: image = A 1024 by 1024 BYTE array

; OPTIONAL INPUTS: cut_limit = any brightnesses above a certain value will be set to zero. 
; 	   	     This is useful for creating the brightness wave array where it does not want to take in certain brightnesses above a specific value. 
;		     More explanation is offered in create_extracted_wave_array.
; 	  upper_limit = the brightness value that all pixels brighter than that value will be reduced to. 
;	  	     A suggested limit for seeing the waves in the backdrop of NAC pictures is 15.

; OPTIONAL KEYWORD INPUTS: UPPER_LIMIT_SWITCH = UPPER_ON == If this is set then the upper limit will be taken into account.
; 	   	   	   CUT_LIMIT_SWITCH = CUT_ON == If this is set then the cut limit will be takin into account.

; OUTPUTS: image_brightened = A 1024 by 1024 BYTE array with brightnesses above a certain point either set to an upper limit or removed altogether

; EXAMPLE: brightened_image = brighten_image(image, 0, 15, /CUT_LIMIT_SWITCH)

; PROCEDURES USED:

; REVISION HISTORY:
; 6/20 Kuchta: Ready for implementation.

function brighten_image, image, upper_limit, cut_limit, UPPER_LIMIT_SWITCH = UPPER_ON, CUT_LIMIT_SWITCH = CUT_ON

; Sets image_brightened to be equal to image in case none of the
; keywords are specified and the program skips through all of the if statements.
image_brightened = image

; Creates an if statement to test if the keyword is set and if the
; upper_limit is set.
IF ((N_ELEMENTS(upper_limit) NE 0) && KEYWORD_SET(UPPER_ON)) THEN BEGIN

; If the brightness of a pixel is less than a certain limit then it
; keeps the same brightness.
   image_brightened = (image lt upper_limit) * image

; If the brightness of a pixel is set to zero because it was greater
; than the limit then it is now set to that upper limit. The /null
; makes it do nothing if it is NE 0.
   image_brightened[where (image_brightened eq 0, /null)] = upper_limit

; Ends the if statement.
ENDIF

; Creates an if statement to test if the keyword is set and if there
; is a cut limit. One must be careful when calling for a cut_limit
; because otherwise the program thinks you have set the upper_limt so
; make sure to add an extra 0 before it. Look at the example.
IF ((N_ELEMENTS(cut_limit) NE 0) && KEYWORD_SET(CUT_ON)) THEN BEGIN

; Any pixels greater than or equal to a certain limt will be set to
; zero. The /null makes it do nothing if it is LT cut_limit.
   image_brightened[where(image GE cut_limit, /null)] = 0

; Ends the if statement.
ENDIF

; If neither keyword is set then a message is sent saying that nothing
; has been changed about the image.
IF (KEYWORD_SET(UPPER_ON) EQ 0) && (KEYWORD_SET(CUT_ON) EQ 0) THEN BEGIN
   print, 'The image was not adjusted'
ENDIF

; Returns the adjusted image.
return, image_brightened

end
