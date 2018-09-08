; Get the image from the directory
pro filter, filename
dir="C:\Users\Po Adrich\Desktop\IDL\ISS_018RI_RPX110PH001_VIMS_images\"
image=read_vicar(dir+filename,/flip)
image=rotate(image,1)

; Apply Roberts filter
;filtered_image = ROBERTS(image)

; Apply Sobel filter
;filtered_image = SOBEL(image)

; Apply Prewitt filter
;filtered_image = PREWITT(image)

; Apply SHIFT_DIFF filter
;filtered_image = SHIFT_DIFF(image)

; Apply EDGE-DOG filter
;filtered_image = EDGE_DOG(image)

; Apply Lapacian filter
filtered_image = LAPLACIAN(image)

; Apply EMBOSS filter
;filtered_image = EMBOSS(image)

tvscl, filtered_image

end 
