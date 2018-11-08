function  F = ransacF(nPts,imPts)

nTrial = 10;  %% Number of ransac trials to use

%% RANSAC for F
seeds = {};
sigma = 2.0; rho = 2;
for kTrial = 1: nTrial
  %% Test out F matrix on a random sample of 8 points
  idTest = randperm(nPts);
  nTest = min(8, nPts);
  idTest = idTest(1:nTest);

  %% Solve for F matrix on the random sample
  [F Sa Sf] = linEstF(imPts(:,idTest,1), imPts(:,idTest,2),1);
  
  %% Compute perpendicular error of all points to epipolar lines
  perpErrL = zeros(1,nPts);
  for k = 1:nPts
    lk = imPts(:,k,2)' * F';
    perpErrL(k) = (lk* imPts(:,k,1))/norm(lk(1:2));
  end
  
  %% Detect inliers
  idInlier = abs(perpErrL) < rho*sigma;
  
  %% Count inliers
  nInlier = sum(idInlier);
  if nInlier > 20
    %% Store sets of sampled points with at least 20 inliers
    seed = struct;
    seed.id = idTest;
    seed.idInlier = idInlier;
    seed.nInlier = nInlier;
    seed.F = F;
    
    kSeed = length(seeds)+1;
    seeds{kSeed} = seed;
  end
end 
%% Done RANSAC trials

%% Extract best solution
nInliers = zeros(1, length(seeds));
for ks = 1:length(seeds)
  nInliers(ks) = seeds{ks}.nInlier;
end 
[nM ks] = max(nInliers);
nInliers(ks);

%%  Refine estimate of F using all inliers.
F = seeds{ks}.F;
idInlier = seeds{ks}.idInlier;

idInlierOld = idInlier;
sum(idInlier);
%% Do at most 10 iterations attempting to entrain as many points as possible.
for kIt = 1: 10
  %% Fit F using all current inliers
  [F Sa Sf] = linEstF(imPts(:,idInlier,1), imPts(:,idInlier,2),1);
  
  %% Compute perpendicular error to epipolar lines
  perpErrL = zeros(1,nPts);
  for k = 1:nPts
    lk = imPts(:,k,2)' * F';
    perpErrL(k) = (lk* imPts(:,k,1))/norm(lk(1:2));
  end
  idInlier = abs(perpErrL) < rho*sigma;
  nInlier = sum(idInlier);
  
  %% If we have the same set of inliers as the previous iteration then stop.
  if all(idInlier == idInlierOld)
    break;
  end
  idInlierOld = idInlier;
end


end