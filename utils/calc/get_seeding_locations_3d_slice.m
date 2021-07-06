function [seeding_locs] = get_seeding_locations_3d_slice(X0, Y0, Z0, modality, seed)

if nargin < 5
    seed = 2020;
end

rng(seed)

switch modality
    case {'grid', 'gridded'}
        num_points = size(X0, 1);
        locs_idx = 1:num_points;       
    case {'random_sparse', 'random-sparse'}
        num_points = 256; % Hardcode, otherwise it gets ugly
        locs_idx  = randi([1 length(X0(:))], num_points, 1);              
    case {'random_dense', 'random-dense'}
        num_points = 1024; % Hardocde, othwerwise it gets ugly
        locs_idx  = randi([1 length(X0(:))], num_points, 1);
    otherwise
        error(['neural-flows::' mfilename '::UnknownCase'], ...
              'Unknown modality for seeding streamlines on a structured 3D grid.');        
end
seeding_locs.X = X0(locs_idx); 
seeding_locs.Y = Y0(locs_idx);
seeding_locs.Z = Z0(locs_idx);

end % function get_seeding_locations_3d_slice()