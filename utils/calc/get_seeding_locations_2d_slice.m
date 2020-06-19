function [seeding_locs] = get_seeing_locations_2d_slice(X0, Y0, modality, seed)

if nargin < 4
    seed = 2020;
end

rng(seed)

switch modality
    case {'grid', 'gridded'}
        seeding_locs.X = X0(:); 
        seeding_locs.Y = Y0(:);
    case {'random_sparse', 'random-sparse'}
        seeding_locs.X = min(X0(:)) + (max(X0(:)) - min(X0(:))) * rand(floor(size(X0)./2));
        seeding_locs.Y = min(Y0(:)) + (max(Y0(:)) - min(Y0(:))) * rand(floor(size(Y0)./2));        
    case {'random_dense', 'random-dense'}
        seeding_locs.X = min(X0(:)) + (max(X0(:)) - min(X0(:))) * rand(size(X0));
        seeding_locs.Y = min(Y0(:)) + (max(Y0(:)) - min(Y0(:))) * rand(size(Y0));
    otherwise
        error(['neural-flows::' mfilename '::UnknownCase'], ...
              'Unknown modality for seeding streamlines');
        
end

end % function get_seeding_locations_2d_slice()
