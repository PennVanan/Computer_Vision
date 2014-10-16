function morph_generator_final(im1, im2, do_trig, im1_pts, im2_pts)
%im1_pts and im2_pts are optional arguments - can be populated through
%If not provided, generated through click_correspondences called below
[r1,c1,z1] = size(im1);
[r2,c2,z2] = size(im2);

if(c1>c2)
    im2=padarray(im2,[0,(c1-c2)],'symmetric','post');
else
    im1=padarray(im1,[0 (c2-c1)],'symmetric','post');
end
 
if(r1>r2)
    im2=padarray(im2,[(r1-r2) 0],'symmetric','post');
else
    im1=padarray(im1,[(r2-r1) 0],'symmetric','post');
end 

%Initializing the video
if(do_trig==1)
   h_avi = VideoWriter('Triangulation_Face.avi', 'Uncompressed AVI');
else
   h_avi = VideoWriter('TPS_Face.avi', 'Uncompressed AVI');
end
h_avi.FrameRate = 10;
h_avi.open();
%aviobj = avifile('sample.avi','fps',10);

%Get correspondence points 
if(nargin < 5)
[im1_pts,im2_pts] = click_correspondences(im1,im2);
end;
%Apppending borders as control points
im1_pts = [im1_pts; 1 1; 1 r1; r1 1; r1 c1]
im2_pts = [im2_pts; 1 1; 1 r2; r2 1; r2 c2]

x=im1_pts; y=im2_pts;
if do_trig==1
 X = [x(:,1); y(:,1)];
 Y = [x(:,2); y(:,2)];
 X=zeros(size(x,1),1)
 Y=zeros(size(y,1),1)
for i=1:size(x,1)
 X(i,1) = (x(i,1) + y(i,1))/2;
 Y(i,1) = (x(i,2) + y(i,2))/2;
end
 tri = delaunay(X,Y);
end
i=1;

%Generating frames for every increment of 0.016 to create around 60 frames
no_of_frames = round(1/0.016);
for step = 0 : 0.016 : 1
    disp('Morphing at Iteration ');
    disp(i);
    warp_frac     = step;  
    dissolve_frac = step;
    if do_trig==1   %Triangulation
        morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac);
    else %Thin Plate Spine
        morphed_im = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac);
    end
   imshow(morphed_im); 
   title(strcat({'Frame '},num2str(i),{' of '}, num2str(no_of_frames)));  axis image; axis off; drawnow;
   h_avi.writeVideo(getframe(gcf));
    i=i+1;
end  
h_avi.close();
end
