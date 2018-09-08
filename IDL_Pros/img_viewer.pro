;img_viewer
;
;PURPOSE
;Create an enviroment to view all image without reading one by one. It
;automatically creates the cropped image and creates a graph of the
;brightness with the waves removed.
;Press:
;       n for next image
;       b for previous image
;       i for skipping to a image at index location (integer)
;       p for skipping to a image by providing full image name
;       f for image information
;       q to quit
;
;Calling Sequence
;img_viewer
;
;ARGUMENTS
;  None
;
;KEYWORDS
;  None
;
;RETURN
;  None
;
;RESTRICTIONS : This program only works when the read_vicar.pro works.
;               Meaning that the directory is setup correctly and the
;               type of the file reading is correct.
;
;PROCEDURES USED : remove_image_brightness_waves(), array_avg(), crop_ring()
;
;KNOWN BUGS : Yet to handle exception realted to file not found.
;
;; ORIGINAL AUTHOR : Johnny Li
;
;UPDATE HISTORY :
;  6/7/2016- Initialization v1.0
;  6/7/2016- Define the start and end of the images; clear out the indexoutofbound problem. v1.1
;  6/8/2016- Define the find_image_index function to search for specific file name.
;  6/10/2016- Popup dialoug with information
;  6/20/2016- Kuchta: added in automatic txt file picker, image
;             cropper, and plots the vertically integrated brightness
;             of the image with brightness waves removed.

pro img_viewer

; Change this to be the area where YOUR images_name_index.txt is
; located. If this is not working then go ahead and use the code found
; right below this that is commented out instead.
  file = '/Users/cameron/idl/pro/img_viewer/images_name_index.txt'

  ;Instruction
  ;print, "Please select a image name file."
  ; Select a text file and open for reading
  ;file = DIALOG_PICKFILE(FILTER='*.txt')

  ;Open the file for reading
  OPENR, lun, file, /GET_LUN

  ; Read one line at a time, saving the result into array.
  ; Starting by initializing array to store image and line
  ; for current line.
  array = ''
  line = ''
  WHILE NOT EOF(lun) DO BEGIN & $
    ;Read the next line
    READF, lun, line & $
    ;Append line to array
    array = [array, line] & $
  ENDWHILE
; Close the file and free the file unit
FREE_LUN, lun



; Change this to be the area where YOUR images_time_index.txt is
; located. If this is not working then go ahead and use the code found
; right below this that is commented out instead.
file = '/Users/cameron/idl/pro/img_viewer/images_time_index.txt'

;Same as above but for time.
;Instruction
;print, "Please select a image time file."
;file = DIALOG_PICKFILE(FILTER='*.txt')

OPENR, lun, file, /GET_LUN
timearray=''
timeline=''
WHILE NOT EOF(lun) DO BEGIN & $
  ;Read the next line
  READF, lun, timeline & $
  ;Append line to array
  timearray = [timearray, timeline] & $
ENDWHILE
FREE_LUN, lun
;New line string
newline=string([13B, 10B])
;Print instruction
print, "====================================================="+newline+"n for next image"+newline+"b for previous image"$
  +newline+"i for skipping to a image at index location (integer)"$+newline+"p for skipping to a image by providing full image name"$
  +newline+"f for image information"+newline+"q to quit"+newline+"====================================================="



;This is the total number of element in the array. The length.
sz=N_ELEMENTS(array)

;Print out the first image that is in file.
image=load_nac_image(array[1])

;Changed window name and size
window,0,xsize=2048,ysize=1024,title="Image Viewer"
tvscl,image


;Create a counter that starts at 1 which is the fist image.
i=1

;Repeat statement that will not end unless q is pressed
REPEAT BEGIN
  ;Record the key that is pressed in the console
  key = GET_KBRD(/ESCAPE)

  ;Turn the key pressed into ASCII decimal value
  ;TO-DO These are only for lower-case
  keyval=byte(key)

  ;Case for button pressed
  case keyval of

    ;98 is b (lower-case)
    98:BEGIN
      ;Since the image starts at index 1 to sz, need to prevent
      ;looking at index 0,-1,-2,etc. If trying to reach index<1,
      ;the counter would be set to 1.
      if((i-1)LT 1) then i=1 else i=i-1
    END

    ;110 is n (lower-case)
    110:BEGIN
      ;Same logic. Need to prevent looking for image at index
      ;that does not exist. Set an upper bound for i so if
      ;i+1>sz we set i to sz.
      if((i+1) GT sz-1) then i=sz-1 else i=i+1
    END

    ;112 is p (lower-case)
    112:BEGIN
      ;Create a variable to store user input
      filename=''
      ;Back up the value sotred in i incase of expected exception.
      backupi=i
      ;Prompt the user for a file name with instruction
      READ,filename,PROMPT='Enter the Image Name with extension(Case Sensitive):
      ;Call the function find_image_index and set the value to i
      i = find_image_index(array,filename)
      ;If file not found, i=0, is received, restore the value of i to backupi.
      IF(i EQ 0) THEN i=backupi
    END

    ;105 is i (lower-case)
    105:BEGIN
      ;Creater a catch to record an expected exception
      CATCH, Error_status
      ;initialize a index number
      indexnumber=1
      READ,indexnumber,PROMPT='Enter the image index number:
      ;If error is not found.
      IF(Error_Status NE 1) THEN BEGIN
        IF(indexnumber GT 0) AND (indexnumber LT sz) THEN i=indexnumber
      ENDIF
    END

    ;102 is f (lower-case)
    ;Display image information
    102:image_information,array,timearray,i


    ;If something else was pressed just do nothing
    else:
  endcase

  ;Close the previously opened window/image
  erase
  ;Open the image that is requested(previous/next/index/name)
  image=load_nac_image(array[i])
  
; radius = The number of pixels above or below the ring to be measured
; in the image. 
  radius = 20

; Creates a one dimensional array with brightness waves removed.
  image_array = remove_image_brightness_waves(image, radius)

; Creates a longword integer then sets it equal to the average of the array.
  avg_image_brightness = long(0)
  avg_image_brightness = array_avg(image_array)

; Prints out what the average brightness is of the array. If for some
; reason the brightness is wacky for an image then go ahead and
; manually adjust the mas and min values and the yrange then view the
; image again.
  print, avg_image_brightness

; Plots the one dimensional array on the top half of the window and
; sets the max and min values and the y and xrange.
  plot,image_array, Pos=[.1,.5,1,1], MAX_VALUE= avg_image_brightness + 500, MIN_VALUE= avg_image_brightness - 500, XRANGE = [0,1024], YRANGE = [avg_image_brightness - 500,avg_image_brightness + 500]

; Crops the image so the ring is at the center. If ring is not in the
; image then you should manually adjust these values. Make sure you
; look at the commenting on this function and all other procedures
; used in this file.
  cropped_image = crop_ring(image, radius)

; Scales the cropped images brightness and sets it in the botton left corner
; starting at (0,0)
  tvscl, cropped_image

  ;If q was pressed the repeat would end
ENDREP UNTIL key EQ 'q'

;Close all windows
wdelete

;end of program
end

;find_image_index
;
;PURPOSE
;Search the image name array and find the index
;of a specific file name.
;
;Calling Sequence
;find_image_index(imagenamearray,targetname)
;
;ARGUMENTS
;  None
;
;KEYWORDS
;  None
;
;RETURN
;  Return index, the location of the file name in the array.
;
;RESTRICTIONS : This program only works when a image name array existed.
;
;KNOWN BUGS : Yet to handle exception realted to file not found.
;
;; ORIGINAL AUTHOR : Johnny Li
;
;UPDATE HISTORY :
;  6/8/2016- Initialization v1.0
;  6/8/2016- Add in code to check if name not found v1.1
;  6/9/2016- Add in exception handling. v1.2
function find_image_index,imagenamearray,targetname

  ;Start the index at 1.(by IDL default)
  index=1
  ;Calculate the length of the array
  arraysize=N_ELEMENTS(imagenamearray)
  ;While the item at current index is not equal to what we are looking
  ;for we initiate the loop
  WHILE(imagenamearray[index] NE targetname) DO BEGIN
    ;If the entire is searched but no match found
    IF(index+1 GT arraysize-1)THEN BEGIN
      ;Set index to 0
      index=0
      ;End the loop by breaking
      BREAK
    ENDIF ELSE BEGIN
      ;Otherwise increment index by 1
      index=index+1
    ENDELSE
  ENDWHILE
  ;Return the final index value
  return,index
end

;image_information
;
;PURPOSE
;Display a popup dialog box to present information
;
;Calling Sequence
;image_information, namearray, timearray, index
;
;ARGUMENTS
;  None
;
;KEYWORDS
;  None
;
;RETURN
;  None
;
;RESTRICTIONS : This program only works when image name and image time array existed.
;
;KNOWN BUGS : Yet to handle exception realted to file not found.
;
;; ORIGINAL AUTHOR : Johnny Li
;
;UPDATE HISTORY :
;6/10/2016- Creation of pro file and basic setup.
;
pro image_information, namearray, timearray, index
  ;The same as \n in other languages. Jump to nextline.
  newline=string([13B, 10B])
  ;Utilize result = dialog_message() to display message
  popup = dialog_message("This is the information about the image "+newline+newline+"Shutter Mid-Time: "$
    + String(timearray[index])+ newline+"Image Name: "+String(namearray[index])+newline+"Image Index number: "$
    + String(index) + newline,title="Information",/information)
end
