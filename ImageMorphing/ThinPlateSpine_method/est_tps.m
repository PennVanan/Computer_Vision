function [a1,ax,ay,w] = est_tps(ctr_pts, target_value)
sz = size(ctr_pts,1);
K = zeros(sz,sz);
O = zeros(3,3);
%Setting lambda close to 0
lambda = 0; 
I = eye(sz+3,sz+3);
for i=1:sz
    x1 = ctr_pts(i,1);
    y1 = ctr_pts(i,2);
    for j=1:sz
        x2 = ctr_pts(j,1);
        y2 = ctr_pts(j,2);
        tmp = power(y2-y1,2) + power(x2-x1,2);
        if(tmp==0)  %Not taking log for difference 0
            K(i,j) = 0;
        else
        K(i,j) =  tmp .* log(tmp);
        end;
    end
end 
P = [ctr_pts, ones(size(ctr_pts,1),1)];
P_t = P';
mat1 = [K P;P_t O]; 
v = [target_value; zeros(3,1)];
b = lambda * I;
a = mat1 + b;
ans1 = a \ v;  
%Extract Affine co-efficients and weights
ax = ans1(end-2);
ay = ans1(end-1);
a1 = ans1(end);
w = ans1(1:end-3);
end
