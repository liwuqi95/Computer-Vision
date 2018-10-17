function [circles] = getProposals(normals, p, numGuesses)
% [circles] = getProposals(normals, p, numGuesses)
% Attempt to produce up to numGuesses circle proposals from
% the edgel data p and normals.  For typical data sets
% we will be able to produce numGuesses proposals.  However,
% on some datasets, say with only a few edgels, we may not be
% able to generate any proposals.  In this case size(circles,1)
% can be zero.
% Input:
%  normals - N x 2 edgel normals
%  p         N x 2 edgel positions
%  numGuesses - attempt to propose this number of circles.
% Return:
%   circles a P x 3 array, each row contains [x0(1) x0(2) r]
%           with 0 <= P <= numGuesses.

p_ordered = [];
p_ordered(1, :) = p(1, :);
p(1, :) = [];

n_ordered = [];
n_ordered(1, :) = normals(1, :);


normals(1, :) = [];


while size(p,1) > 1
    
    edge = p_ordered(end,:);
    
    closet_distance = -1;
    index = -1;
    
    for i = 1:size(p,1)
        
        point = p(i, :);
        
        distance = norm (edge - point);
        
        if closet_distance == -1 || distance < closet_distance
            closet_distance = distance;
            index = i;
        end
    end
    
    p_ordered(size(p_ordered,1) + 1, :) = p(index, :);
    p(index,:) = [];
    
    n_ordered(size(n_ordered,1) + 1, :) = normals(index, :);
    normals(index,:) = [];
end

groups = {};

group = [p_ordered(1,:)];

for i = 2:size(p_ordered, 1) - 1
    
    if dot(n_ordered(i - 1 , :), n_ordered(i, :)) > 0.87 || size(groups, 2) >=  (numGuesses) || size(group,1) < 2
        group(end + 1,:) = p_ordered(i,:);
    else
        groups{end + 1} = group;
        group = [p_ordered(i,:)];
    end
end

first_group = groups{1};

if size(group,1) > 0
    if dot( first_group(1 , :)  , group(end, :) ) > 0.87
        groups{1} = vertcat(groups{1}, group);
    elseif size(groups, 2) >=  (numGuesses)
        groups{end} = vertcat(groups{end}, group);
    end
end



circles = [];

for i=1:size(groups,2)
    
    group = groups{i};
    circle_center = mean(group);
    
    total_r = 0;
    
    for j= 1:size(group,1)
        total_r = norm (group(j,:) - circle_center) + total_r;
        

    end
    
    r = total_r / size(group,1);
    circles(end + 1, :)= [circle_center(1), circle_center(2), r];
   
end

return




