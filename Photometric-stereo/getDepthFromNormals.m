function [depth] = getDepthFromNormals(n, mask)
% [depth] = getDepthFromNormals(n, mask)
%
% Input:
%    n is an [N, M, 3] matrix of surface normals (or zeros
%      for no available normal).
%    mask logical [N,M] matrix which is true for pixels
%      at which the object is present.
% Output
%    depth an [N,M] matrix providing depths which are
%          orthogonal to the normals n (in the least
%          squares sense).
%

[N,M] = size(mask);

num = N * M;

A = sparse(2*num, num);
v = sparse(2*num, 1);

 
for i = 1:M
    for j = 1:N
        
        index = (j-1) * M + i;
        
        if mask(j,i) > 0
            A(2*index-1, index + 1)  =  n(j,i,3);
            A(2*index-1, index)      = -n(j,i,3);
            
            A(2*index  , index + M ) =  n(j,i,3);
            A(2*index  , index)      = -n(j,i,3);
            
            v(2*index-1) = - n(j,i,1);
            v(2*index) = - n(j,i,2);
        end
    end
end

Z = A \ v;

depth = reshape(Z,[M,N])';




