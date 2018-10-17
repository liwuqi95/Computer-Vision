function [goodCircle] = isGoodCircle(x0, r, w, ...
    circleEstimates, nFound)
% [goodCircle] = isGoodCircle(x0, r, w, normals, ...
%                                  circleEstimates, nFound)
% Decide if the circle with parameters x0 and r, with fitted
% weights w, is to be added to the current set of circles.
% Input:
%  x0 2-vector for circle center
%  r  radius of circle
%  w  robust weights of edgels supporting this circle,
%     weights have been scaled to have max possible value 1.
%  circleEstimates C x 3 array of circle parameters, the first
%     nFound rows of which specifies the [x0(1), x0(2) r] parameters
%     for a previously fitted circle for this data set.
%  nFound the number of previously fitted circles stored in circleEstimates
% Output:
%  goodCircle boolean, true if you wish to add this circle to the
%             list of previously fitted circles.

x0 = x0(:);  % Decide, row or column


goodCircle = true;


ave = mean(w);

if ave > 0.7
    goodCircle = false;
    return
end


if nFound > 0
    
    for i= 1:nFound
        
        circle = circleEstimates(:,i);
        
        center = circle(1:2);
        radius = circle(3);
        
        distance = norm(center - x0);
        
        if distance < ( radius + r ) * 0.5
            
            goodCircle = false;
            return
        end
        
    end
end











return




% YOU FINISH THIS