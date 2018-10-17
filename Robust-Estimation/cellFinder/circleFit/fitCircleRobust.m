function [x0, r, w, maxW] = fitCircleRobust(pts, initx0, initr, normals, sigmaGM)
%
% function [x0, r, w, maxW] = fitCircleRobust(pts, initx0, initr,
%                                  normals, sigmaGM)
%
%  minimize sum_i  rho( a'x_i + b + x_i'x_i, sigma)
%  w.r.t. a and b, where a = -2x_0 and b = x_0'x_0 - r^2
% Input:
%  pts: an Nx2 matrix containing 2D x_i, i=1...N
%  initx0: 2-vector initial guess for centre
%  initr: initial guess for radius
%  normals: an Nx2 matrix of corresponding 2D edge normal directions nrml_i
% Output
%  x0 - 2x1 fitted circle's center position
%  r  - fitted circle's radius
%  w  - N x 1 robust weights for edgels.
%  maxW  - maximum possible robust weight (i.e. for zero error)
%          This may be used by the calling code to scale the weights
%          to be between 0 and 1.

%
x0 = initx0;
r = initr;

for l=1:100
    
    a = - 2 * x0;
    b = x0.'*x0 - r^2;
    
    w = [];

    
    x_squared = [];
    
    for i = 1:size(pts,1)
        
        point = pts(i,:);
        
        e_k =  point * a + b + dot(point , point);
        
        w_k = (2 * sigmaGM^2 ) / (e_k^2 + sigmaGM^2)^2;
        
        w(end+1, :) = w_k;        
        x_squared(end+1, :) = point(1)^2 + point(2)^2;
    end
    
    maxW = max(w);
    W = diag(w);
    
    X_h = [pts ones(size(pts, 1), 1)];
    
    c =  inv(X_h.' * W * X_h) * (- X_h.' * W * x_squared);
    
    new_center = -c(1:2)/2;
    
    new_r = sqrt(dot(new_center, new_center) - c(3));
    
    if norm([new_center.' new_r] - [x0.' r]) < 0.01
        break;
    else
        x0 = new_center;
        r = new_r;
    end
end

return