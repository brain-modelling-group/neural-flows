function test_sing_classification_critical_points_grid(cp_type)

[~, ux, uy, uz, X, ~, ~] = generate_singularity3d_hyperbolic_critical_points(cp_type);


% Fake time points
max_t = 16;
options.flow_calculation.grid_size = size(X);

null_points_3d = struct([]);
for ii=1:max_t
    mstruct_vel.ux(:, :, :, ii) =  ux;
    mstruct_vel.uy(:, :, :, ii) =  uy;
    mstruct_vel.uz(:, :, :, ii) =  uz;
    % Location of the critical points
    null_points_3d(ii).xyz_idx = floor(options.flow_calculation.grid_size/2);

end

mstruct_vel.options = options;
mstruct_vel.hx = 2^-4;
mstruct_vel.hy = 2^-4;
mstruct_vel.hz = 2^-4;

% Perform classification
[singularity_classification_list] =   singularity3d_classify_singularities(null_points_3d, mstruct_vel);

err_message = ['neural-flows' mfilename '::ClassificationError:: ', ...
               'Input singularity type (' cp_type ') does not match classification result '];

for tt=1:max_t
    assert(strcmp(singularity_classification_list{tt}, cp_type), [err_message '(' singularity_classification_list{tt} ').']);
end
end %function test_sing_classification_critical_points_grid()
