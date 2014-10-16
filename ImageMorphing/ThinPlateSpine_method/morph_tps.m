function[morphed_im] = morph_tps(im_source, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y,ctr_pts, sz)
%Extracting the size parameters desired
r=sz(1); c=sz(2);

%Generating location arrays for pixels in intermediate image
x_t = zeros(r*c, 1);
y_t = zeros(r*c, 1);
count=0;val=1;

%Gathering pixel locations of intermediate image in two arrays
%Row-wise indices
for q1=1:r*c
x_t(q1,1) = val;
count = count+1;
if(mod(count,c)==0)
val = val+1;
end
end
%Column-wise indices
val=1;
for q1=1:r*c
y_t(q1,1) = val;
if(mod(val,r)==0)
val = 1;
else
val = val+1;
end
end
 
x_c = ctr_pts(:,1);
y_c = ctr_pts(:,2);
x_c = x_c';
y_c = y_c';
x_ct_size = max(size(x_c),size(x_t)).*(size(x_c) & size(x_t)>0);
x_ct = zeros(size(x_ct_size,1),size(x_ct_size,2));
y_ct = zeros(size(x_ct_size,1),size(x_ct_size,2));
%Initializing the Distance matrix
D  = max(size(x_c),size(x_t)).*(size(x_c) & size(x_t)>0);
D =  zeros(size(D,2),size(D,1));
for i = 1:size(x_c,2)
    for j = 1:size(x_t,1)
        x_ct(i,j) = (x_t(j)-x_c(i)).^2;
        y_ct(i,j) = (y_t(j)-y_c(i)).^2;
        D(j,i) = x_ct(i,j) + y_ct(i,j);
    end 
end 
U = D .* log(D);
U(isnan(U)) = 0; %Ignoring NaN values

%Calculating set of X,Y co-ordinates in the source image
         X = a1_x + ax_x*x_t + ay_x*y_t + U*w_x;
         Y = a1_y + ax_y*x_t + ay_y*y_t + U*w_y;

 
morphed_im(r, c, 3) = uint8(0);  

X=round(X);
Y=round(Y);
imr = size(im_source,1);
imc = size(im_source,2);
X(X<=0)=1;  X(X>imr)=imr;
Y(Y<=0)=1;  Y(Y>imc)=imc;

o=1;
for i = 1:r
    for j = 1:c
    x=real(round(X(o))); y=real(round(Y(o)));
    x1=x-1; x2=x+1;
    y1=y-1; y2=y+1;         
    if(x1==0) x1=1; end;  if(x2==0) x2=1; end
    if(y1==0) y1=1; end;  if(y2==0) y2=1; end
    if(x1>imr) x1=imr; end;  if(x2>imr) x2=imr; end
    if(y1>imc) y1=imc; end;  if(y2>imc) y2=imc; end 
              Q11=im_source(x1,y1,:); Q12=im_source(x1,y2,:);
              Q21=im_source(x2,y1,:); Q22=im_source(x2,y2,:);
              P1=((x2-x)*(y2-y))/((x2-x1)*(y2-y1));
              P2=((x-x1)*(y2-y))/((x2-x1)*(y2-y1));
              P3=((x2-x)*(y-y1))/((x2-x1)*(y2-y1));
              P4=((x-x1)*(y-y1))/((x2-x1)*(y2-y1));
              morphed_im(i,j,:) = (P1*Q11) + (P2*Q21) + (P3*Q12) + (P4*Q22);
    o=o+1; %Navigate to next pixel through the indices array
    end
end
end 
