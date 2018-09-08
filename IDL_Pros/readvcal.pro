pro readvcal,data,backgrd,filename,xmax,ymax, start_time, stop_time, quiet=quiet

; ----------------------------------------------------------------
; IDL procedure to read in a VIMS image cube & display it
 
; instructions:
;	>IDL
;	>.run readvims2000
;	>readvims,cube,back,filename,xmax,ymax
;	  ... reads file 'filename'
;	  ... extracts core into array 'cube'
;	  ... extracts side plane into array 'back'
;	  ... plots image for desired spectral channel(s)
;	  ... plots spectra for specified pixels
; ----------------------------------------------------------------

;   Obtained 1/18/96 from Giancarlo Bellucci
;   Modified 6/24/96 by Phil Nicholson to:
;	- convert byte format to DEC for vimst1m
;	- read cube PDS header to extract header length
;	  and suffix size for data
;	- reduce output image size to <= 256*256
;	- add labels to spectrum plot
;	- add loop to choose different image plane to display
;	- identify displayed channel # on image and spectra
;	- read word length & image size from header
;    Modified 16 May 1997 for use at Cornell.
;    Modified 2 Jan 1998 for use on Oct98 test cubes (pdn).
;    Modified 6 Jan 1999 for use on Dec98 test cubes:
;       - 4-byte suffices require slice-by-slice reads
;  NOTE:  routine does not handle cubes with <100 bands at present!
;    Modified 16 Jan 1999 for use on Jan99 ICO cubes: (pdn)
;	- cube & suffixe size format changed to free field: should now
;	  read any size cubes (<99) or suffices (<9)
;    Modified 17/18 Jan 1999: (pdn)
;	- add filename as parameter, to return for plot labels
;	- extract background plane from 2/4-byte data
;    Modified 9 Oct 2000: readvims2000 (pdn)
;       - read Fomalhaut cubes (extra lines in headers + more spaces
;         in "^QUBE = nn" line.)
;    Modified 16 June 2004: (pdn)
;	- extract exposure time for use in xcal.pro
;    Modified 19 May 2008: (brs)
;       - added "quiet" mode
;    Modified 20 May 2008: (brs)
;       - return start and stop times
; ----------------------------------------------------------------

;path='/VIMSdata/ICO/Spica/'		; for vimsops directories
;path='../ICO/spica/'		        ; for bilbo directories
;path=''
;path='../ICO/noisy/'
;path='../ICO/quiet/'
;path='../venus/'
;path='../moon/'
;path='../fomalhaut/'
;path='../jupiter/data/'
;path='../jupiter/data/rings/'
;path='../jupiter/data/sats/'
;path='../jupiter/data/planet/'
;path='../solar_port/c27/data/'
;path='../solar_port/c33/data/'
;path='../IRstars/AlpBoo/'
;path='../IRstars/AlpSco/'
;path='../IRstars/AlpOri/'
;path='../IRstars/CWLeo/'
;path='../IRstars/EtaCar/'
;path='../IRstars/OmiCet/'
;path='../IRstars/NMLTau/'
;path='../IRstars/RDor/'
;path='../IRstars/BetGru/'
;path='../saturn/data/C44/'
;path='../saturn/data/S01/'
;path='../saturn/data/S01/phoebe/'
;path='../saturn/data/S01/soi/'
;path='../saturn/data/S01/ringmos/'
;path='../saturn/data/S02/RINGMOS224/'
;path= '/home/adeona/mmhedman/vims/S02/'
;path='/home/borogove/vims/S05/'
;filename = ' '				; program prompts for filename

swath = 64				; nominal values; also input below
spec = 352
small = 0				; images of 10*10 or bigger
;small = 1				; set flag for image size of <=9*9

; read in header info on image dimensions, etc.

;if not keyword_set(quiet) then print, 'current path = ',path

;read,' Enter filename (cut & paste): ',filename   ; input file
;file = path + filename
;file=dialog_pickfile(path=path)
;filename=file
openr, lun, filename, /get
hdr=bytarr(512)
hdr=bytarr(1024)              ; avoid "CORE_ITEMS" straddling 2 records!
readu,lun,hdr
header=string(hdr>32b)		

; I don't know what the '>32b' does! It is from readfits.pro

;if not keyword_set(quiet) then print,header	; put back if something goes horribly wrong!
skip=0
findcube: p=strpos(header,'^QUBE')	; find starting record of cube data
if p le 0 then begin
   if not keyword_set(quiet) then print,'^QUBE not found, reading next record ...'
	readu,lun,hdr
	header=string(hdr>32b)		
;        if not keyword_set(quiet) then print,header
	goto, findcube
endif else begin
 ; MMH swaps to try and read calib data 9/21/04                             
	reads,strmid(header,p+8,3),skip,format='(i3)'   ; earlier data; calib data
;	reads,strmid(header,p+16,2),skip,format='(i2)'  ; fomalhaut - C44 data
	if not keyword_set(quiet) then print,'data starts at record = ',skip
;	byte_skip = fix(512*(skip-1))	; number of header bytes
	byte_skip = 512L*(skip-1)	; number of header bytes (4-byte INT)
	if not keyword_set(quiet) then print,'*** Header bytes to be skipped = ',byte_skip
endelse
hdr=bytarr(512)

core = [swath,spec,64]
findcore: p=strpos(header,'CORE_ITEMS')	

; core = dimensions of image data in cube
;  NOTE:  routine does not handle cubes with <100 bands at present!

if p le 0 then begin
	if not keyword_set(quiet) then print,'no CORE_ITEMS found, reading next record ...'
;	if not keyword_set(quiet) then print,'no CORE_ITEMS found, assuming [64,352,64] ...'  ; readvims98
	readu,lun,hdr
	header=string(hdr>32b)		
;        if not keyword_set(quiet) then print,header
	goto, findcore
endif else begin
;if small eq 1 then begin
;	reads,strmid(header,p+14,7),core,format='(i1,x,i3,x,i1)'	; small cubes
;endif else begin
;	reads,strmid(header,p+14,9),core,format='(i2,x,i3,x,i2)'	; big cubes
;endelse
	reads,strmid(header,p+14,9),core,format='(3i)'	; use free-field read
	if not keyword_set(quiet) then print,'read cube dimensions: ',core
endelse
swath=core(0)
spec=core(1)
mstep=core(2)
; ************   WARNING swap lines & bands ****************
;spec=core(2)
;mstep=core(1)
;if not keyword_set(quiet) then print,'*** inverted cube dimesions ***'
; **********************************************************

core_bytes = 2
findcorebytes: p=strpos(header,'CORE_ITEM_BYTES')	

if p le 0 then begin
	if not keyword_set(quiet) then print,'no CORE_ITEM_BYTES found, reading next record ...'
;	if not keyword_set(quiet) then print,'no CORE_ITEM_BYTES found, assuming 2-byte integers ...'	; readvims98
	readu,lun,hdr
	header=string(hdr>32b)		
	goto, findcorebytes
endif else begin
	reads,strmid(header,p+18,1),core_bytes,format='(i1)'
	if not keyword_set(quiet) then print,'read byte_length: ',core_bytes
endelse

suffix = [0,0,0]
findsuffix: p=strpos(header,'SUFFIX_ITEMS')	

; suffix = number of non-image words at the end of each 
; row/spectrum/column of data in cube.

; NOTE: proceessed cubes often have no SUFFIX_ITEMS keyword; comment
; in extra lines to read RAW cube.

if p le 0 then begin
;	if not keyword_set(quiet) then print,'no SUFFIX_ITEMS found, assuming [0,0,0]'
        if not keyword_set(quiet) then print,'no SUFFIX_ITEMS found, reading next record ...'
        readu,lun,hdr
        header=string(hdr>32b)
	goto, findsuffix
endif else begin
;	reads,strmid(header,p+16,5),suffix,format='(i1,x,i1,x,i1)'
	reads,strmid(header,p+16,5),suffix,format='(3i)'  ; use free field read
	if not keyword_set(quiet) then print,'read cube suffix: ',suffix
endelse
; ************   WARNING swap lines & bands ****************
;temp = suffix(1)
;suffix(1) = suffix(2)
;suffix(2) = temp
;if not keyword_set(quiet) then print,'*** inverted cube suffix: ',suffix,' ***'
; **********************************************************
suffix_bytes = 2
findsuffixbytes: p=strpos(header,'SUFFIX_BYTES')	

if p le 0 then begin
	if not keyword_set(quiet) then print,'no SUFFIX_BYTES found, reading next record ...'
        readu,lun,hdr
        header=string(hdr>32b)
	goto, findsuffixbytes
endif else begin
	reads,strmid(header,p+15,1),suffix_bytes,format='(i1)'
	if not keyword_set(quiet) then print,'read suffix_byte_length: ',suffix_bytes
endelse

findstarttime: p=strpos(header,' START_TIME')	

if p le 0 then begin
 	if not keyword_set(quiet) then print,'no START_TIME found, reading next record ...'
         readu,lun,hdr
         header=string(hdr>32b)
 	goto, findstarttime
endif else begin
	start_time=strmid(header,p+15,22)
 	if not keyword_set(quiet) then print,'read start_time: ',start_time
endelse

findstoptime: p=strpos(header,' STOP_TIME')	

if p le 0 then begin
 	if not keyword_set(quiet) then print,'no STOP_TIME found, reading next record ...'
         readu,lun,hdr
         header=string(hdr>32b)
 	goto, findstoptime
endif else begin
	stop_time=strmid(header,p+14,22)
 	if not keyword_set(quiet) then print,'read stop_time: ',stop_time
endelse




exptime = [640.0,5000.0]

findexptime: p=strpos(header,'EXPOSURE_DURATION')	

if p le 0 then begin
        if not keyword_set(quiet) then print,'no EXPOSURE info found, reading next record ...'
        readu,lun,hdr
        header=string(hdr>32b)
	goto, findexptime
endif else begin
	reads,strmid(header,p+21,22),exptime,format='(2f)'  ; free field read
	if not keyword_set(quiet) then print,'read exposure time: ',exptime
endelse

; ----------------------------------------------------------------
; read image cube:

point_lun, lun, byte_skip				; set pointer at start of data

; modify code to allow for 4-byte suffix: (6 jan 1999)
if core_bytes eq 2 and suffix_bytes eq 2 then begin
  data = intarr(swath+suffix(0), spec+suffix(1), mstep+suffix(2))
  backgrd = intarr(spec)
  readu, lun, data       ; Note that 'data' includes any suffices.
  close, lun
endif else if core_bytes eq 2 and suffix_bytes eq 4 then begin
  goto, slice_by_slice
endif else begin
; long integers (format never encountered so far...)
;  data = lonarr(swath+suffix(0), spec+suffix(1), mstep+suffix(2))
; attempt to read calibrated data: 15 June 2004
    ; MMH read calibrated data 9/21/04
  data = fltarr(swath+suffix(0), spec+suffix(1), mstep+suffix(2))
  readu, lun, data       ; Note that 'data' includes any suffices.
;  byteorder, data, /LSWAP   ; convert from PC_REAL to SUN format
  ; MMH change to work on Adeona 9/21/04
  close, lun
endelse
goto, newimage

; read cube slice by slice & remove suffices:
slice_by_slice: if not keyword_set(quiet) then print,'reading by slices, be patient ...'
data = intarr(swath, spec, mstep)
backgrd = intarr(spec,mstep)
slice = intarr(swath+2*suffix(0), spec)



slice_bytes = n_elements(slice)*2L + (swath+suffix(0))*suffix(1)*4L
for j=0,mstep-1 do begin
  point_lun, lun, byte_skip+j*slice_bytes	; set pointer at next slice
  readu,lun,slice
  data(0:swath-1,0:spec-1,j) = slice(0:swath-1,0:spec-1)  ; no suffices!
;  backgrd(0:spec-1,j) = reform(slice(swath,0:spec-1))	; use 1st 2 bytes
  backgrd(0:spec-1,j) = reform(slice(swath+1,0:spec-1))	; use 2nd 2 bytes
endfor
close,lun

; *** NB: the following is for use on DEC machines only ***
; Comments removed to work on Adeona by MMH 9/20/04
if core_bytes eq 2 then begin
	byteorder,data
endif else begin
	byteorder,data,/ntohl		; longwords?
endelse

newimage:
close, /all
;datax(i,0:swath-1,0:spec-1,0:mstep-1)=data
;backx(i,0:spec-1,0:mstep-1)=backgrd
;end

end
