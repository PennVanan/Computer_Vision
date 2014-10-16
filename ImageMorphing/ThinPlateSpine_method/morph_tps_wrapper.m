function [morphed_im] = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)
X=zeros(size(im1_pts,1),1);
Y=zeros(size(im1_pts,1),1);

%Applying warp fraction
for i=1:size(im1_pts,1)
X(i,1) = (im1_pts(i,1)*(1-warp_frac)) + (im2_pts(i,1)*(warp_frac));
Y(i,1) = (im1_pts(i,2)*(1-warp_frac)) + (im2_pts(i,2)*(warp_frac));
end
ctr_pts = [X Y];

%Generating intermediate image from source
xa=im1_pts(:,1);
ya=im1_pts(:,2);
[a1_x,ax_x,ay_x,w_x] = est_tps(ctr_pts, xa); %TPS for X coordinates of im1
[a1_y,ax_y,ay_y,w_y] = est_tps(ctr_pts, ya); %TPS for Y coordinates of im1
%Merging X and Y TPS for im1
morph_im1 = morph_tps(im1, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y,ctr_pts,size(im1));


%Generating intermediate image from destination
xb=im2_pts(:,1);
yb=im2_pts(:,2);
[a1_x,ax_x,ay_x,w_x] = est_tps(ctr_pts, xb);  %TPS for X coordinates of im2
[a1_y,ax_y,ay_y,w_y] = est_tps(ctr_pts, yb);  %TPS for Y coordinates of im2
%Merging X and Y TPS for im2
morph_im2 = morph_tps(im2, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y,ctr_pts,size(im2));

%Cross-dissolving the intermediate images generated for im1 and im2
morphed_im = (1-dissolve_frac)*morph_im1 + dissolve_frac*morph_im2;
end