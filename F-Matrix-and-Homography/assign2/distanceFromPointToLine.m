function [d] = distanceFromPointToLine(line, point)
   d = abs(line(1) * point(1) + line(2) * point(2) + line(3))/ sqrt(line(1)^2 + line(2)^2);
    
end