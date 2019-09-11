function [v, norm_vf] = normalise_vector_field(v, dim)
%% Normalises the input vector field using the L2 norm
%
% ARGUMENTS:
%           v   -- a 2D array of size [M, dim];
%           dim -- dimension of the embedding space (2 or 3)
% OUTPUT:
%           v   -- nD array of size [M, dim] whose vectors have unit
%                  norm.
%           norm_vf -- an array of size [M, 1] with the norm of the
%                      original vector field.
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2019-01
% USAGE:
%{
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
norm_vf = sqrt(sum(v.^2, 2));

% Avoid division by zero
norm_vf(norm_vf < 1e-8) = 1;

try 
    v = v./norm_vf;
catch 
    disp('Cannot perform implicit expansion/broadcasting of arrays. Using repmat instead ...')
    v = v .* repmat(1./norm_vf, [ones(dim-1,1)' size(v, dim)]);
end

end % function normalise_vector_field()
