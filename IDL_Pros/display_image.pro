; Get the image from the directory
pro display_image, filename, image
dir = "/Users/Shared/CASSINI DATA/ISS_018RI_RPX110PH001_VIMS_images/"
image=read_vicar(dir+filename,/flip)
image=rotate(image,1)

; Apply filter
;image = SOBEL(image)

tvscl, image

end 
