; Britt's Generic Useful Routines

;  -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-

pro pwd  ;Written by Britt Scharringhausen, July 22, 1997
 cd,'.',CURRENT=alpha
 cd,alpha
 print,alpha
end

;  -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-

pro ls,directory,result,quiet=quiet ; Written by BRS, December 20, 2000
 if not keyword_set(directory) then directory='' 
 spawn, 'ls '+directory,result
 if not keyword_set(quiet) then for i=0,n_elements(result)-1 do print, result(i)

end

;  -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~


pro setps,filename, landscape=landscape, notencapsulated=notencapsulated, long=long, square=square
; Reroutes graphics output to the postscript device.  

; Hardcopy should be called afterward to print the file and return
; output to the X device, or else just use closeps to close the
; postscript file.

if not keyword_set(filename) then filename="idl"

if not strmatch(filename,'*.*ps') then begin
    if not keyword_set(notencapsulated) then begin
        filename=filename+'.eps' 
        encapsulated=1
    endif else begin
       filename=filename+'.ps'
       encapsulated=-1
    endelse
 endif


if not keyword_set(landscape) then begin
    portrait=1                           ; Default to portrait orientation
    if keyword_set(square) then begin
        ysize=6.2                        ; Square-size portait
        yoffset=3.8                      
     endif else begin
        if keyword_set(long) then begin
          ysize=10.             ; Long portrait
          yoffset=0.5
       endif else begin
          ysize=8.0             ; Default:lab-book sized portrait
          yoffset=2.0
          xoffset=1
       endelse
    endelse
  endif else begin 
;     yoffset=11.0 ; Landscape
;     ysize=11.0
;     xoffset=0.0
;     xsize=8.5
  endelse

set_plot,'ps'

device,filename=filename,portrait=portrait,landscape=landscape, $
  encapsulated=encapsulated,  /inches, ysize=ysize,yoffset=yoffset,xoffset=xoffset, xsize=xsize

!p.charsize=1
;!p.thick=2


!p.font=1 ; Avoid weird hardware fonts that turn things to Greek
print, "Output to: ", filename


end


pro closeps

  device,/close_file
  set_plot,'X'

  !p.font=0 ; return to nice font for TV
end

;  -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~

pro hardcopy, remove=remove, nodate=nodate, filename=filename


  if not keyword_set(nodate) then begin
     get_date,date	
     xyouts,1,0,date,align=1,/norm
  endif
	
	
  device,/close_file
  if not keyword_set(filename) then filename='idl.eps'
  spawn,'lpr '+filename
  if keyword_set(remove) then spawn,'rm -f idl.eps'

  set_plot, 'X' ; Return to TV
  !p.font=0 ; return to nice font for TV
	
end

;  -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~

pro psym_list 

; Show basic IDL plotting symbols and linestyles
; does not include PLOTSYM from the IDL Astro User Library

plot,[0,0],[0,0],/nodata

legend,['psym=0','pysm=1','psym=2','psym=3','psym=4','psym=5','psym=6','psym=7','lines=0','lines=1','lines=2','lines=3','lines=4'],$
       psym=[ 0,       1,       2,       3,       4,       5,       6,       7,       -3,       -3,       -3,       -3 ,      -3],$
       lines=[0,       0,       0,       0,       0,       0,       0,       0,        0,        1,        2,        3 ,       4]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

function keyword_exists, var

  return, fix( (size(var))[1] ne 0 )

end




