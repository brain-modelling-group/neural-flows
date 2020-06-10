function [x0, y0] = get_seeing_locations_slice(X0, Y0, modality, seed)

if nargin < 4
    seed = 2020;
end

rng(seed)

switch modality
    case {'grid', 'gridded'}
        start_X = X0(:); 
        start_Y = Y0(:);
    case {'random_sparse', 'random-sparse'}
        start_X = min(X0(:)) + (max(X0(:)) - min(X0(:))) * rand(floor(size(X0)./2));
        start_Y = min(Y0(:)) + (max(Y0(:)) - min(Y0(:))) * rand(floor(size(Y0)./2));        
    case {'random_dense', 'random-dense'}
        start_X = min(X0(:)) + (max(X0(:)) - min(X0(:))) * rand(size(X0));
        start_Y = min(Y0(:)) + (max(Y0(:)) - min(Y0(:))) * rand(size(Y0));
    otherwise
        error(['neural-flows::' mfilename '::UnknownCase'], ...
              'Unknown modality for seeding streamlines');
        
end
 x0 = start_X(:); 
 y0 = start_Y(:);

end