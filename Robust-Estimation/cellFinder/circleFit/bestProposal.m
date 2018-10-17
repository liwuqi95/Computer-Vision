function [circle] = bestProposal(circles, sigmaGM, normals, p)
% [circle] = bestProposal(circles, sigmaGM, normals, p)
% Chose the best circle from the proposed circles.
% Input
%  circles K x 3 matrix each row containing [x0(1), x0(2), r] for
%          the center and radius of a proposed circle.
%  sigmaGM - the robust scale parameter
%  normals - P x 2 edgel normal data
%  p       - P x 2 edgel position data.
% Output
%  circle  1 x 3  best circle params [x0(1), x0(2), r] from the proposals

min_o = -1;
index = 1;

for i= 1:size(circles,1)
    
    
    
    center_x = circles(i, 1);
    center_y = circles(i, 2);
    r = circles(i, 3);
    
    o = 0;
    
    for j=1:size(p,1)
  
        x = p(j, 1);
        y = p(j, 2);
        
        e = (x-center_x)^2 + (y-center_y)^2 - r^2;
        
        
        rho = e^2 / (sigmaGM^2 + e^2);
        o = o + rho;
    end
    
    if o < min_o || min_o < 0
        min_o = o;
        index = i; 
    end
    
end


circle = circles(index,:);

return




