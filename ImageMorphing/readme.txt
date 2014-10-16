Helper Functions List

1. morph_generator_final
   ---------------------
* Takes in input images and gets the correspondence points from user and performs the morph according to do_trig(0 or 1)
Inputs:  
im1 - Image A;
im2 - Image B;
do_trig - set to 1 if Triangulation, 0 for TPS
Output:
Video file - 
Triangulation_Face.avi if triangulation,
TPS_Face.avi for TPS

2. mytsearchn
   ----------
* Returns the triangle id corresponding to pixel (X,Y) in  triangulation defined by TRI and (x,y) being the set of correspondence points in intermediate image
 
3. morph_tps_wrapper
   -----------------
* Generates one frame of TPS morph
Inputs:
im1, im2 - Input images
im1_pts, im2_pts - Correspondence points for im1 and im2
warp_frac - Warp fraction between 0 and 1
dissolve_frac - Dissolve fraction between 0 and 1 

Images used:  obama.jpg. clinton.jpg
