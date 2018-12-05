function [L] = fitChromeSphere(chromeDir, nDir, chatty)
% [L] = fitChromeSphere(chromeDir, nDir, chatty)
% Input:
%  chromeDir (string) -- directory containing chrome images.
%  nDir -- number of different light source images.
%  chatty -- true to show results images.
% Return:
%  L is a 3 x nDir image of light source directions.

% Since we are looking down the z-axis, the direction
% of the light source from the surface should have
% a negative z-component, i.e., the light sources
% are behind the camera.

if ~exist('chatty', 'var')
    chatty = false;
end

mask = ppmRead([chromeDir, 'chrome.mask.ppm']);
mask = mask(:,:,1) / 255.0;

for n=1:nDir
    fname = [chromeDir,'chrome.',num2str(n-1),'.ppm'];
    im = ppmRead(fname);
    imData(:,:,n) = im(:,:,1);           % red channel
end

%%%%%%%%

% Looking for the center of the sphere

[row, col] = find(mask > 0);

c = [mean(col); mean(row)];

% Looking for the radius

r = (max(col)  - min(col)  + max(row) - min(row)) / 4;

for n=1:nDir
    % get all points for this image
    points = imData(:,:,n);
    
    % find the brightest point
    [b_points_row, b_points_col] = find(points >= max(max(points)));
    
    brightest = [mean(b_points_col); mean(b_points_row)];
        
    % distance in the image
    im_d = brightest - c;
    
    % find the displacement angle between center and the brightest point in
    theta = atan(norm(im_d) / r);
    
    % find the normal vector of brightest point and normalize
    n_vector = [im_d; -(r * cos(theta))];
    n_vector = n_vector / norm(n_vector);
    
    
    % find the light direction by the law of reflection
    L(:,n) = 2 * dot(n_vector, [0; 0; -1]) * n_vector - [0; 0; -1];
    
end

return;

