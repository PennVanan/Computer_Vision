function Q = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac)
Ax = im1_pts(:,1);
Bx = im2_pts(:,1);
Ay = im1_pts(:,2); 
By = im2_pts(:,2);
[r,c,z] = size(im1);
X=zeros(size(im1_pts,1),1);
Y=zeros(size(im2_pts,1),1);

%Performing Warping on Correspondence points
for i=1:size(im1_pts,1)
X(i,1) = (im1_pts(i,1)*(1-warp_frac)) + (im2_pts(i,1)*(warp_frac));
Y(i,1) = (im1_pts(i,2)*(1-warp_frac)) + (im2_pts(i,2)*(warp_frac));
end
 
%Generate intermediate image by recording the pixel positions in a matrix
%Loop by rows
count=0;val=1;
for q1=1:r*c
x_t(q1,1) = val;
count = count+1;
if(mod(count,c)==0)
val = val+1;
end
end
%Loop by columns
count=0;val=1;
for q1=1:r*c
y_t(q1,1) = val;
if(mod(val,r)==0)
val = 1;
else
val = val+1;
end
end

%Initialize intermediate Images
im1_M(r, c, 3) = uint8(0);
im2_M(r, c, 3) = uint8(0);

for i=1:size(x_t,1)
         tri_id = mytsearch(tri, X, Y, x_t(i), y_t(i));
         if (tri_id > 0)  
             %Find triangle indices
              pt1=tri(tri_id,1);
              pt2=tri(tri_id,2); 
              pt3=tri(tri_id,3);
              %Locate triangle coordinates in intermediate image
              x1=X(pt1); x2=X(pt2); x3=X(pt3);
              y1=Y(pt1); y2=Y(pt2); y3=Y(pt3);
              %Compute Barycentric coordinates
              alpha =  ((y2 - y3)*(x_t(i) - x3) + (x3 - x2)*(y_t(i) - y3)) / ((y2 - y3)*(x1 - x3) + (x3 - x2)*(y1 - y3));
              beta =  ((y3 - y1)*(x_t(i) - x3) + (x1 - x3)*(y_t(i) - y3)) / ((y2 - y3)*(x1 - x3) + (x3 - x2)*(y1 - y3));
              gamma = 1-alpha-beta;
              values = [alpha, beta, gamma]; 
              %Find corresponding points in source image
              x1=Ax(pt1); x2=Ax(pt2); x3=Ax(pt3);
              y1=Ay(pt1); y2=Ay(pt2); y3=Ay(pt3);
              xs = (x1*alpha) + (x2*beta) + (x3*gamma);
              ys = (y1*alpha) + (y2*beta) + (y3*gamma); 
              zs = alpha + beta + gamma;
              xs = round(xs/zs);
              ys = round(ys/zs);   
        
             %Find corresponding points in target image
              x1=Bx(pt1); x2=Bx(pt2); x3=Bx(pt3);
              y1=By(pt1); y2=By(pt2); y3=By(pt3);
              xd = (x1*alpha) + (x2*beta) + (x3*gamma);
              yd = (y1*alpha) + (y2*beta) + (y3*gamma);  
              zd = alpha + beta + gamma;
              xd = round(xd/zd);
              yd = round(yd/zd);   
            
              %Copy colors into respective intermediate images
              x=real(round(xs)); y=real(round(ys));
              x1=x-1; x2=x+1;
              y1=y-1; y2=y+1;
             
              if(x1==0) x1=1; end;  if(x2==0) x2=1; end
              if(y1==0) y1=c; end;  if(y2==0) y2=1; end
              if(x1>r) x1=r; end;  if(x2>r) x2=r; end
              if(y1>c) y1=c; end;  if(y2>c) y2=c; end 
              Q11=im1(x1,y1,:); Q12=im1(x1,y2,:);
              Q21=im1(x2,y1,:); Q22=im1(x2,y2,:);
              P1=((x2-x)*(y2-y))/((x2-x1)*(y2-y1));
              P2=((x-x1)*(y2-y))/((x2-x1)*(y2-y1));
              P3=((x2-x)*(y-y1))/((x2-x1)*(y2-y1));
              P4=((x-x1)*(y-y1))/((x2-x1)*(y2-y1));
              im1_M(x_t(i),y_t(i),:) = (P1*Q11) + (P2*Q21) + (P3*Q12) + (P4*Q22);
              %im1_M(x_t(i),y_t(i),:) = im1(round(xs),round(ys),:);
              
           %Performing Bilinear Interpolation to find pixel location to copy
              x=real(round(xd)); y=real(round(yd));
              x1=x-1; x2=x+1;
              y1=y-1; y2=y+1;
             
              if(x1==0) x1=1; end;  if(x2==0) x2=1; end
              if(y1==0) y1=c; end;  if(y2==0) y2=1; end
              if(x1>r) x1=r; end;  if(x2>r) x2=r; end
              if(y1>c) y1=c; end;  if(y2>c) y2=c; end
              
              Q11=im2(x1,y1,:); Q12=im2(x1,y2,:);
              Q21=im2(x2,y1,:); Q22=im2(x2,y2,:);
              P1=((x2-x)*(y2-y))/((x2-x1)*(y2-y1));
              P2=((x-x1)*(y2-y))/((x2-x1)*(y2-y1));
              P3=((x2-x)*(y-y1))/((x2-x1)*(y2-y1));
              P4=((x-x1)*(y-y1))/((x2-x1)*(y2-y1));
              im2_M(x_t(i),y_t(i),:) = (P1*Q11) + (P2*Q21) + (P3*Q12) + (P4*Q22);
         end
end
 %Cross dissolve intermediate images   
 Q = im1_M *(1-dissolve_frac) + im2_M *(dissolve_frac);
end