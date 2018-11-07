

% code from handout
f = 100; % focal length
dLeft = [-50, 0, -150]';  
dRight = [50, 0, -150]';  

% dLeft = [-5, 0, -150]';  
% dRight = [5, 0, -150]';  


[pLeft polys MintLeft MextLeft] = projectDino(f, dLeft, [], 1.0);
Rleft = MextLeft(:, 1:3);
[pRight polys MintRight MextRight] = projectDino(f, dRight, [], 1.0);
Rright = MextRight(:, 1:3);

sclZ = 1;

[pLeft polys MintLeft MextLeft] = projectDino(f, dLeft, Rleft, sclZ);
[pRight polys MintRight MextRight] = projectDino(f, dRight, Rright, sclZ);



F0 = groundTruth( MextLeft, MextRight, MintLeft, MintRight);

estimateError(pLeft, [-150 -100 150 100], F, F0)

sigmas = [];
median_errors = [];

sigma = 0;
n = 0;

while sigma < 20
    
    errors = [];
    
    for i = 1:20
        
        noiseLeft = [];
        noiseRight = [];
        
        for i = 1:size(pLeft, 2)
            noiseLeft(:, i) = pLeft(:, i) + [normrnd(0, sigma, [1,2]), 0].';
            noiseRight(:, i) = pRight(:, i) + [normrnd(0, sigma, [1,2]), 0].';
        end
        
        [F1, ~, ~] = linEstF(noiseLeft,noiseRight,1);
        
        E = estimateError(pLeft, [-150 -100 150 100], F1, F0);
        
        errors(end + 1) = E;
        
    end

    sigmas(end + 1) = sigma;
    median_errors(end + 1) = mean(errors);
    
    sigma = 1.1^n;
    n = n + 1;
end

plot(sigmas,median_errors)







