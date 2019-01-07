function v = normalise_vector_field(v, dim)
% Normalizes vector field v along dimension 'dim'
% Paula Sanz-Leon, 2019, QIMR 
norm_vf = sqrt(sum(v.^2, dim));

% Avoid division by zero
norm_vf(norm_vf < 1e-8) = 1;

try 
    v = v./norm_vf;
catch 
    disp('Cannot perform implicit expansion/broadcasting of arrays')
    v = v .* repmat( 1./norm_vf, [ones(dim-1,1)' size(v, dim)] );
end

end % function normalize_vector_field()