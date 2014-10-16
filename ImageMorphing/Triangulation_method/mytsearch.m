function triangle_id = mytsearch(TRI,x,y,X,Y)
%Locate the Triangle in which the given point lies
triangle_id = -1; found_flag=0;

for i = 1:size(TRI,1)
    triangle_id = i;
    %Find the triangle indices
     pt1=TRI(i,1);
     pt2=TRI(i,2);
     pt3=TRI(i,3);
     
     %Locate points
     x1=x(pt1); x2=x(pt2); x3=x(pt3);
     y1=y(pt1); y2=y(pt2); y3=y(pt3);
     
     %Find Barycentric coordinates
     alpha =  ((y2 - y3)*(X - x3) + (x3 - x2)*(Y - y3)) / ((y2 - y3)*(x1 - x3) + (x3 - x2)*(y1 - y3));
     beta =  ((y3 - y1)*(X - x3) + (x1 - x3)*(Y - y3)) / ((y2 - y3)*(x1 - x3) + (x3 - x2)*(y1 - y3));
     gamma = 1-alpha-beta;
     
     %Point is within the triangle if alpha+beta+gamma=1
     if(((alpha>=0)&&(alpha<=1)) && ((beta>=0)&&(beta<=1)) && ((gamma>=0)&&(gamma<=1)))
      found_flag=1; break;
     end
end 
if(found_flag==0) 
     triangle_id=-1;  %The point is not within the triangle
end
end