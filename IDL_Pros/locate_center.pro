; Get the image from the directory
pro locate_center, filename
dir = "/Users/Shared/CASSINI DATA/ISS_018RI_RPX110PH001_VIMS_images/"
image = read_vicar(dir+filename,/flip)
image = rotate(image,1)

image = ROBERTS(image)

tvscl,image

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
;filtered_image = LAPLACIAN(image)

; Apply EMBOSS filter
;filtered_image = EMBOSS(image)

; Display filtered image
;tvscl, filtered_image

; Plot
;point=ARRAY_INDICES(image, where(filteredimage gt 550))

;plot, point(0,*), point(1,*), psym = 3

; ----------
; Apply Hough Transform
;transform = HOUGH(filtered_image, RHO = rho, THETA = theta)

; Display Hough Transform
;tvscl, transform

; Apply Hough Backprojection
;backprojection=HOUGH(transform, /BACKPROJECT, RHO = rho, THETA = theta)

; Display Hough Backprojection
;tvscl, backprojection

end 
