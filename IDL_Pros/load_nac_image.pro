;=============================================================================
;+
; load_nac_image
;
; PURPOSE
;`
;  Reads a vicar data and rotate the picture towards the right orientation.
;
;'
; CALLING SEQUENCE :
;
;       image=load_nac_image(filename)
;
;
; ARGUMENTS
;  INPUT : filename - String giving the name of the file to be read.
;
;  OUTPUT : image - 1024x1024 BYTE array.
;
;
;
; KEYWORDS : NONE

;
; RESTRICTIONS : This program only works with band-sequential data and
;                does not recognize EOF labels. Also required read_vicar
;                to be setup to the right directory.
;
;
;
; KNOWN BUGS : NONE
;
;
;
; ORIGINAL AUTHOR : Johnny Li
;
; UPDATE HISTORY :
;
;-
;=============================================================================
function load_nac_image,filename

  ;Using read_vicar to read in an image with provided keyword "flip" to
  ;transpose and flip 270 degree.
  image=read_vicar(filename,/flip)
  ;Flip 90 degree clockwise
  image=rotate(image,1)
  ;Return 1024x1024 BYTE array
  return, image
end