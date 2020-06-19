function [seeding_locs] = get_seeding_locations_3d_slice(X0, Y0, Z0, modality, seed)

if nargin < 5
    seed = 2020;
end

rng(seed)

switch modality
    case {'grid', 'gridded'}
        seeding_locs.X = X0(:); 
        seeding_locs.Y = Y0(:);
        seeding_locs.Z = Z0(:);
    case {'random_sparse', 'random-sparse'}
        seeding_locs.X = min(X0(:)) + (max(X0(:)) - min(X0(:))) * rand(floor(size(X0,1)./4), 1);
        seeding_locs.Y = min(Y0(:)) + (max(Y0(:)) - min(Y0(:))) * rand(floor(size(Y0,1)./4), 1); 
        seeding_locs.Z = min(Z0(:)) + (max(Z0(:)) - min(Z0(:))) * rand(floor(size(Z0,1)./4), 1);               
    case {'random_dense', 'random-dense'}
        seeding_locs.X = min(X0(:)) + (max(X0(:)) - min(X0(:))) * rand(size(X0,1),1);
        seeding_locs.Y = min(Y0(:)) + (max(Y0(:)) - min(Y0(:))) * rand(size(Y0,1),1);
        seeding_locs.Z = min(Z0(:)) + (max(Z0(:)) - min(Z0(:))) * rand(size(Z0,1),1);
    otherwise
        error(['neural-flows::' mfilename '::UnknownCase'], ...
              'Unknown modality for seeding streamlines on a structured 3D grid.');        
end

end % function get_seeding_locations_3d_slice()