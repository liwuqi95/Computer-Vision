%% File: grappleFmatrix
%% A2 2017 handout code
%% Uses RANSAC to estimate F matrix from corresponding points.
%%
%% ADJ

clear
close all
FALSE = 1 == 0;
TRUE = ~FALSE;
global matlabVisRoot

%% We need to ensure the path is set for the iseToolbox.
if length(matlabVisRoot)==0
  dir = pwd;
  cd ../matlab   %% CHANGE THIS
  startup;
  cd(dir);
end

reconRoot = '.';  %% CHANGE THIS
addpath([reconRoot '/data/wadham']);
addpath([reconRoot '/utils']);


% Random number generator seed:
seed = round(sum(1000*clock));
rand('state', seed);
seed0 = seed;
% We also need to start randn. Use a seedn generated from seed:
seedn = round(rand(1,1) * 1.0e+6);
randn('state', seedn);

nTrial = 10;  % Number of ransac trials to try.

%% Wadham left image: use  wadham/001.jpg
imPath = 'data/wadham/'; fnameLeft = '001'; 
im = imread([imPath fnameLeft],'jpg');
im = double(im(:,:,2));
imDwn = blurDn(im,1)/2;
imLeft = imDwn;

%% Read correspondence data
load data/wadham/corrPnts5
%% Wadham right image data/wadham002-5.jpg use for corrPnts2-5 respectively
fnameRight = '005';
im = imread([imPath fnameRight],'jpg');
im = double(im(:,:,2));
imDwn = blurDn(im,1)/2;
imRight = imDwn;

clear imPts;
imPts = cat(3, im_pos1', im_pos2');
nPts = size(imPts,2);
if size(imPts,1) == 2
  imPts = cat(1, imPts, ones(1,nPts,2));
end

%% RANSAC for H
seeds = {};
sigma = 2.0; rho = 2;
for kTrial = 1: nTrial
  %% Test out H matrix on a random sample of 8 points
  idTest = randperm(nPts);
  nTest = min(4, nPts);
  idTest = idTest(1:nTest);

  %% Solve for H matrix on the random sample
  [H Sa] = linEstH(imPts(:,idTest,1), imPts(:,idTest,2),1);
  
  %% Compute distance error of all points to epipolar lines
  DErr = zeros(1,nPts);
  for k = 1:nPts
    est = (H * imPts(:,k,1));
    estP = est / est(3) - imPts(:,k,2);
    DErr(k) = sqrt(estP(1)^2 + estP(2)^2);
  end
  
  %% Detect inliers
  idInlier = abs(DErr) < rho*sigma;
  
  %% Count inliers
  nInlier = sum(idInlier);
  if nInlier > 20
    %% Store sets of sampled points with at least 20 inliers
    seed = struct;
    seed.id = idTest;
    seed.idInlier = idInlier;
    seed.nInlier = nInlier;
    seed.H = H;
    
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
nInliers(ks)

%%  Refine estimate of H using all inliers.
H = seeds{ks}.H;
idInlier = seeds{ks}.idInlier;

idInlierOld = idInlier;
sum(idInlier)
%% Do at most 10 iterations attempting to entrain as many points as possible.
for kIt = 1: 10
  %% Fit F using all current inliers
  [H Sa] = linEstH(imPts(:,idInlier,1), imPts(:,idInlier,2),1);
  
  %% Compute distance error to epipolar lines
  DErr = zeros(1,nPts);
  for k = 1:nPts
    est = (H * imPts(:,k,1));
    estP = est / est(3) - imPts(:,k,2);
    DErr(k) = sqrt(estP(1)^2 + estP(2)^2);
  end
  
  %% Detect inliers
  idInlier = abs(DErr) < rho*sigma;
  
  nInlier = sum(idInlier)
  
  %% If we have the same set of inliers as the previous iteration then stop.
  if all(idInlier == idInlierOld)
    break;
  end
  idInlierOld = idInlier;
end
  
%%%%%%%%%%%%%%%%%%%%% Plot results
nTest = 64;  %% Number of epipolar lines to plot
nCol = 16;   %% Number of different colours to use.
col = hsv(nCol);  %% Colour map.

%% Random sample the lines to plot
idLines = randperm(nPts);  
idLines = idLines(1:nTest);

%% Show left image
SUPERIMPOSE = TRUE;
hFig = figure(2);
clf;
if SUPERIMPOSE
  image(imLeft);
  colormap(gray(256));
end
resizeImageFig(hFig, size(imDwn), 1); hold on;
set(get(hFig,'CurrentAxes'),'Ydir','reverse');
hold on;

homogLeft = homogWarp(imLeft, inv(H));
%% Show left Homog image
SUPERIMPOSE = TRUE;
hFig = figure(3);
clf;
if SUPERIMPOSE
  image(homogLeft);
  colormap(gray(256));
end
resizeImageFig(hFig, size(imDwn), 1); hold on;
set(get(hFig,'CurrentAxes'),'Ydir','reverse');
hold on;



%% Show right image
SUPERIMPOSE = TRUE;
hFig = figure(4);
clf;
if SUPERIMPOSE
  image(imRight);
  colormap(gray(256));
end
resizeImageFig(hFig, size(imDwn), 1); hold on;
set(get(hFig,'CurrentAxes'),'Ydir','reverse');
hold on;

homogRight = homogWarp(imRight, H);
%% Show right Homog image
SUPERIMPOSE = TRUE;
hFig = figure(5);
clf;
if SUPERIMPOSE
  image(homogRight);
  colormap(gray(256));
end
resizeImageFig(hFig, size(imDwn), 1); hold on;
set(get(hFig,'CurrentAxes'),'Ydir','reverse');
hold on;
