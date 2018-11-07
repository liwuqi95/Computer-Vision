function [E] = estimateError(points, region, F1, F0)




E = 0;

for i = 1:size(points, 2)
    
    epipolar_f0 = points(:, i).' * F0;
    epipolar_f1 = points(:, i).' * F1;

%     ploting epipolar lines
%     x = -150:150;
%     y = -epipolar_f0(3)/epipolar_f0(2) - epipolar_f0(1) / epipolar_f0(2) * x;
%     plot(x,y)
%     hold on 
    
    
    crop_line = cropLineInBox(epipolar_f0(1:2), epipolar_f0(3), region);
    
    if ~isnan(crop_line(1))
        
        
%         ploting cropped lines
%         dline = crop_line.';
%         figure(1);
%         line(dline(1,:) , dline(2,:));

        %the perpendicular distance between two lines can be transfered
        %into the distance between line and edge point. Since the distance
        %is maximum in the edge.
        
        distance1 = distanceFromPointToLine(epipolar_f1, crop_line(1, :));
        distance2 = distanceFromPointToLine(epipolar_f1, crop_line(2, :));
        
        error = max(distance1, distance2);
        
        if E < error 
            E = error;
        end
        
    end
    
end

end

