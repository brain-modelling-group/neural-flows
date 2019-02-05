function v = normalise_vector_field(v, dim)
%% Normalises the input vector field using the L2 norm
%
% ARGUMENTS:
%           v   -- nD array of size [M, N, [P], dim];
%           dim -- dimension of the embeeding space (eg, 2 or 3)
% OUTPUT:
%           v   -- nD array of size [M, N, [P], dim] whose vectors have unit
%                  norm.
% AUTHOR:
%     Paula Sanz-Leon
% USAGE:
%{
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
norm_vf = sqrt(sum(v.^2, dim));

% Avoid division by zero
norm_vf(norm_vf < 1e-8) = 1;

try 
    v = v./norm_vf;
catch 
    disp('Cannot perform implicit expansion/broadcasting of arrays. Using repmat instead ...')
    v = v .* repmat(1./norm_vf, [ones(dim-1,1)' size(v, dim)]);
end

end % function normalize_vector_field()