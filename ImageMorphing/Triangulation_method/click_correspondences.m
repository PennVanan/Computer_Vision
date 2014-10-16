function [x,y] = click_correspondences(im1,im2)
[x,y] = cpselect(im1,im2,'Wait', true);
end