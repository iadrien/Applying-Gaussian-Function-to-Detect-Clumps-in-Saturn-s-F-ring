;+
; NAME:
;    circletransform
;
; PURPOSE:
;    Performs a transform similar to a Hough transform
;    for detecting circular features in an image.
;
; CATEGORY:
;    Image analysis, feature detection
;
; CALLING SEQUENCE:
;    b = circletransform(a)
;
; INPUTS:
;    a: [nx,ny] gray-scale image data
;
; KEYWORD PARAMETERS:
;    range: maximum range over which a circle's center will be
;        sought.  Default: 100 pixels
;
;    noise: estimate for additive pixel noise.  Default: 1 [grey level]
;
;    smoothfactor: range over which to smooth input image before
;        computing gradient.  Default: 5 pixels
;        Setting this to 1 prevents smoothing.
;
;    deinterlace: if set to an odd number, then only perform
;        transform on odd field of an interlaced image.
;        If set to an even number, transform even field.
;
; OUTPUTS:
;    b: [nx,ny] circle transform.  Peaks correspond to estimated
;        centers of circular features in a.
;
; PROCEDURE:
;    Compute the gradient of the image.  The local gradient at each
;    pixel defines a line along which the center of a circle may
;    lie.  Cast votes for pixels along the line in the transformed
;    image.  The pixels in the transformed image with the most votes
;    correspond to the centers of circular features in the original
;    image.
;
; REFERENCE:
; F. C. Cheong, B. Sun, R. Dreyfus, J. Amato-Grill, K. Xiao, L. Dixon
; & D. G. Grier,
; Flow visualization and flow cytometry with holographic video
; microscopy, Optics Express 17, 13071-13079 (2009)
;
; EXAMPLE:
;    IDL> b = circletransform(a)
;
; MODIFICATION HISTORY:
; 10/07/2008 Written by David G. Grier, New York University.
; 01/26/2009 DGG Added DEINTERLACE keyword. Gracefully handle
;    case when original image has no features. Documentation cleanups.
; 02/03/2009 DGG Replaced THRESHOLD keyword with NOISE.
; 06/10/2010 DGG Documentation fixes.  Added COMPILE_OPT.
; 05/02/2012 DGG Updated keyword parsing.  Formatting.
; 06/24/2012 DGG Streamlined index range checking in inner loop
;    to improve efficiency.
; 07/16/2012 DGG IMPORTANT: Center results on pixels, not on vertices!
;    Use array_indices for clarity.
;
; Copyright (c) 2008-2012 David G. Grier
;
;
; UPDATES:
;    The most recent version of this program may be obtained from
;    http://physics.nyu.edu/grierlab/software.html
; 
; LICENSE:
;    This program is free software; you can redistribute it and/or
;    modify it under the terms of the GNU General Public License as
;    published by the Free Software Foundation; either version 2 of the
;    License, or (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;    General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
;    02111-1307 USA
;
;    If the Internet and WWW are still functional when you are using
;    this, you should be able to access the GPL here: 
;    http://www.gnu.org/copyleft/gpl.html
;-




pro center, filename

; Insert the image
display_image, filename, image

b = circletransform(image)

plots, array_indices(b, where(b eq max(b))), /DEVICE, psym = 1

print, array_indices(b, where(b eq max(b)))

; Display the transformed image
;tvscl, b

;SHADE_SURF, b

end


function circletransform, a_, $
                          range = range, $
                          noise = noise, $
                          smoothfactor = smoothfactor, $
                          deinterlace = deinterlace

COMPILE_OPT IDL2

if ~isa(range, /scalar, /number) then range = 100.
if ~isa(noise, /scalar, /number) then noise = 1.
if ~isa(smoothfactor, /scalar, /number) then smoothfactor = 5
dodeinterlace = isa(deinterlace, /scalar, /number)

sz = size(a_, /dimensions)
nx = sz[0]
ny = sz[1]

b = fltarr(nx, ny)

wx = smoothfactor
if dodeinterlace then begin
   n0 = deinterlace mod 2
   a = float(a_[*, n0:*:2])
   wy = wx / 2
endif else begin
   n0 = 0
   a =  float(a_)
   wy = wx
endelse

if smoothfactor gt 1 then $
   a = smooth(a, [wx, wy], /edge_truncate)

dx = rebin([-1., 0., 1.], 3, 3)

dadx = convol(a, dx, /center, /edge_truncate)
dady = convol(a, transpose(dx), /center, /edge_truncate)
if dodeinterlace then dady /= 2.

grada = sqrt(dadx^2 + dady^2)

w = where(grada gt 2.*noise, npts)

if npts le 0 then return, b

xy = array_indices(grada, w)
if dodeinterlace then xy[1,*] = 2.*xy[1,*] + n0
xy += 1.                       ; to center on pixels

costheta = dadx[w] / grada[w]
sintheta = dady[w] / grada[w]

r = findgen(2.*range + 1.) - range

for i = 0L, npts-1L do begin 
   x = round(xy[0,i] + r * costheta[i]) > 0 < nx-1
   y = round(xy[1,i] + r * sintheta[i]) > 0 < ny-1
   b[x, y] += 1. 
endfor

return, b

end
