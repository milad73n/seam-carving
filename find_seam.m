function [seam, cum_energy, edges_from] = find_seam(energy_map, dir_string)
% FIND_SEAM finds the least energy path (with respect to an energy map) 
% when traversing the image in the direction indicated by dir_string.
%
%   Usage:
%       [seam, cum_energy, edges_from] = find_seam(energy_map, dir_string)
%
%   Input:
%       energy_map :   A n-by-m-by-1 matrix with numeric entries 
%       dir_string :   A string {'horizontal', 'vertical'}.
%           - 'horizontal': Traverse energy_map from left to right.
%           - 'vertical': Traverse energy_map from top to bottom.
%
%   Output:
%       seam       :   A vector defining the seam.
%           - If dir_string = 'horizontal': A m-by-1 vector with the 
%           column indices of a path crossing img from left to right.
%           - If dir_string = 'vertical': A n-by-1 vector with the row 
%             indices of a path crossing img from top to bottom.
%       cum_energy :   A n-by-m matrix with the cumulative energy when
%                      traversing energy_map in the direction indicated by 
%                      dir_string.
%       edges_from :   A n-by-m matrix encoding the links between each
%                      pixel in the paths found when traversing energy_map.
%                   
%
%   Example:
%       img = imread('img/5.jpg');
%       dir_string = 'vertical';
%       [Ix, Iy] = gradient(double(rgb2gray(img)));
%       energy_map = abs(Ix) + abs(Iy);
%       seam = find_seam(energy_map, dir_string);
%       img_marked = show_seams(img, seam, dir_string);
%       imshow(img);
%       figure;
%       imshow(img_marked);
%
%   See also: find_k_seams.m, show_seams.m, seam_carving.m
%
%   Requires:
%
%   References:
%       [1] Avidan, S. and Shamir, A. "Seam Carving for Content-Aware
%       Image Resizing". Mitsubishi Electric Research Laboratories.
%       Technical Report TR2007-087. August 2008.
%       [2] Rubinstein, M. et al. "Improved Seam Carving for Video
%       Retargeting". Mitsubishi Electric Research Laboratories.
%       Technical Report TR2008-064. August 2008.
%
% Author: Rodrigo Pena
% Date: 19 Nov 2014
% Testing: 

%% Parse input
% energy_map
[~, ~, d] = size(energy_map);
assert(d == 1, 'energy_map should be a n-by-m-by-1 matrix.');

% dir_string
assert(strcmp(dir_string,'horizontal') || strcmp(dir_string,'vertical'),...
    'dir_string must be ''horizontal'' or ''vertical''.');
if strcmp(dir_string,'horizontal')
    energy_map = energy_map.';
end

%% Initialization
[n, m, ~] = size(energy_map);
cum_energy = repmat(energy_map(1, :), n, 1);
edges_from = zeros(n, m);

%% Dynamic programming to find the paths of less energy
for i = 2:n
    for j = 1:m
        if (j == 1)
            origin_nodes = cum_energy(i-1, 1:2);
        elseif (j == m)
            origin_nodes = cum_energy(i-1, end-1:end);
        else
            origin_nodes = cum_energy(i-1, j-1:j+1);
        end
        
        [cum_energy(i,j), index] = min(energy_map(i,j) + origin_nodes);
        
        edges_from(i,j) = j + index - 2 + (j == 1);
    end
end

%% Backtrack and compute seam vector
[~, index] = min(cum_energy(end, :)); 
seam = index .* ones(n, 1);
for i = n:-1:2
    seam(i - 1) = edges_from(i, seam(i));
end

end

