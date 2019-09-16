function [xyz_points] = find_curve_intersection(surf_xy, surf_xz, surf_yz, h)
% Find the intersections of 3 curves in 3D. The curves are the output of 
% find_surface_intersection.
% this function basically calculates the eculidean distance between points
% along each line and finds the points/coordinates with minimal distance

threshold = h; % Points that are at a distance <= are consider to be close enough to intersect

V  = cat(1, surf_xy.vertices, surf_xz.vertices, surf_yz.vertices);

D = pdist2(V, V, 'Euclidean');

xyz_points =surf_xy.vertices(idx, :);

end