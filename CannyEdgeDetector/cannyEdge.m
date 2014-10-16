function J = cannyEdge(I)
%Checking for Image Size
if size(I,3)==3
I=rgb2gray(I);
end

%Converting Image to Double to use conv2
I=double(I);

% 5*5 Gaussian Kernel G
G=[2 4 5 4 2; 4 9 12 9 4; 5 12 15 12 5; 4 9 12 9 4; 2 4 5 4 2];
G=G/115;

%Differential dx and dy
dx=[1 -1];
dy=[1; -1];

disp('Calculating Gradient...');
%Calculating Gradient G
Gradx=conv2(conv2(I,G),dx,'same');
Grady=conv2(conv2(I,G),dy,'same');
Gradient=sqrt(Gradx.*Gradx + Grady.*Grady);
G=Gradient;
Dir=atan2d(Grady,Gradx); 
s1=size(Gradient,1);
s2=size(Gradient,2);

%Initializing destination matrix to all zeros
J=zeros(size(Gradient,1), size(Gradient,2));

disp('Performing Non-Maximal Suppression...')
%NMS by Quantization
for i=3:s1-2 
    for j=3:s2-2
      d=Dir(i,j); 
      if(d<0) 
          d=d+360;
      end
      if(d>=0 && d<=45) || (d>180 && d<=225)
          pix1 = G(i,j+1); px=i; py=j+1;
          pix3 = G(i+1, j+1); rx=i+1; ry=j+1;
          pix2 = G(i, j-1); qx=i; qy=j-1;
          pix4 = G(i-1, j-1); sx=i-1; sy=j-1;     
      elseif(d>45 && d<=90) || (d>225 && d<=270)
          pix1 = G(i+1, j+1); px=i+1; py=j+1;
          pix3=  G(i+1, j); rx=i+1; ry=j;
          pix2 = G(i-1, j-1); qx=i-1; qy=j-1;
          pix4 = G(i-1, j); sx=i-1; sy=j;
      elseif(d>90 && d<=135) || (d>270 && d<=315)
          pix1 = G(i+1, j); px=i+1; py=j;
          pix3=  G(i+1, j-1); rx=i+1; ry=j-1;
          pix2 = G(i-1, j); qx=i-1; qy=j;
          pix4 = G(i-1, j+1); sx=i-1; sy=j+1;
      elseif(d>135 && d<=180) || (d>315 && d<=360)         
          pix1 = G(i+1, j-1); px=i+1; py=j-1;
          pix3 = G(i,j-1); rx=i; ry=j-1;
          pix2 = G(i-1, j+1); qx=i-1; qy=j+1;
          pix4 = G(i,j+1); sx=i; sy=j+1;
      end
   %Suppressing non-maximum pixels and enabling edge pixel
   if (G(i,j) > pix1 && G(i,j) > pix2 && G(i,j) > pix3 && G(i,j) > pix4)
              J(i,j)=1; J(px, py)=0; J(qx,qy)=0; J(rx,ry)=0; J(sx,sy)=0;
   end
    end
end

%Setting thresholds
low=1.6; high=4;

disp('Edge linking by Interpolation...');
for i=3:s1-2 
    for j=3:s2-2
      d=Dir(i,j); 
      if(d<0) 
          d=d+360;
      end
      if(d>=0 && d<=45) || (d>180 && d<=225)
          pix1 = G(i+1, j); px=i+1; py=j;
          pix3=  G(i+1, j-1); rx=i+1; ry=j-1;
          pix2 = G(i-1, j); qx=i-1; qy=j;
          pix4 = G(i-1, j+1); sx=i-1; sy=j+1;
      elseif(d>45 && d<=90) || (d>225 && d<=270)
          pix1 = G(i+1, j-1); px=i+1; py=j-1;
          pix3 = G(i,j-1); rx=i; ry=j-1;
          pix2 = G(i-1, j+1); qx=i-1; qy=j+1;
          pix4 = G(i,j+1); sx=i; sy=j+1;
      elseif(d>90 && d<=135) || (d>270 && d<=315)
          pix1 = G(i,j+1); px=i; py=j+1;
          pix3 = G(i+1, j+1); rx=i+1; ry=j+1;
          pix2 = G(i, j-1); qx=i; qy=j-1;
          pix4 = G(i-1, j-1); sx=i-1; sy=j-1;
      elseif(d>135 && d<=180) || (d>315 && d<=360)         
          pix1 = G(i+1, j+1); px=i+1; py=j+1;
          pix3=  G(i+1, j); rx=i+1; ry=j;
          pix2 = G(i-1, j-1); qx=i-1; qy=j-1;
          pix4 = G(i-1, j); sx=i-1; sy=j;
      end

     %Performing Interpolation
     wt1 = 1/tand(Dir(i,j));
     wt2 = 1-wt1;

     %Multiplying pixels with interpolated weights
     pix1 = pix1 * wt2;
     pix2 = pix2 * wt1;

     Diro=0;
      if(Dir(i,j) < 180)  
        Diro = Dir(i,j) + 180; 
      else
         Diro = Dir(i,j) - 180;
      end
  
     %Performing Interpolation
     wt3 = 1/tand(Diro);
     wt4 = 1-wt3;

     %Multiplying pixels with interpolated weights
     pix3 = pix3 * wt4;
     pix4 = pix4 * wt3;
  
    %Checking if current pixel value is greater than the calculated pixels
    %in the edge normal direction
     if (G(i,j) > pix1+pix3) && (G(i,j)>pix2+pix4)
          if(G(i,j)>=high)
              J(i,j)=1; J(px, py)=0; J(qx,qy)=0; J(rx,ry)=0; J(sx,sy)=0;
          elseif(G(i,j)>low) && (G(i,j)<high)
              J(i,j)=2;
          elseif(G(i,j)<=low)
              J(i,j)=0;
          end
      end

    end
end

disp('Examining vibrating pixels above L and below H...');
for i=3:s1-2 
    for j=3:s2-2
        if(J(i,j)==2)
            a1=G(i-1, j-1);
            a2=G(i-1, j);
            a3=G(i-1, j+1);
            a4=G(i,j-1);
            a5=G(i,j+1);
            a6=G(i-1,j-1);
            a7=G(i+1,j);
            a8=G(i+1,j+1);
            %Setting vibrating pixels to 1 if they are greater than all of
            %their neighbors
            if(G(i,j)>a1 && G(i,j)>a2 && G(i,j)>a3 && G(i,j)>a4 && G(i,j)>a5 && G(i,j)>a6 && G(i,j)>a7 && G(i,j)>a8)
               J(i,j)=1;
            else
               J(i,j)=0;
            end
        end
    end
end
 
disp('Edge detection done!')

%Removing the initially added padding
J=J(3:s1-2, 3:s2-2);

%Converting the image to Logical
J=logical(J);