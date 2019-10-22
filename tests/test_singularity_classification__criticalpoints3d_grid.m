function test_singularity_classification__criticalpoints3d_grid(cp_type)
% This function test the accuracy of the singularity classification functions 
% called via singularity3d_classify_singularities(). The current function
% only tests the 8 canonical critical points in 3D. It first generates the 
% vector field with the requested singularity and then applies the
% classification. If the singularity is missclassified, an error message
% is displayed.
%
% ARGUMENTS:
%          cp_type  -- a string with the name of the singularity to test.
%                      Options: {'source', 
%                                'sink',
%                                '2-1-saddle', 
%                                '1-2-saddle', 
%                                'spiral-sink', 
%                                'spiral-source',
%                                '2-1-spiral-saddle', 
%                                '1-2-spiral-saddle',
%                                'all'}
% OUTPUT: 
%          None
%
% REQUIRES: 
%           generate_singularity3d_hyperbolic_critical_points()
%          
% USAGE:
%{     

%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon -- QIMR October 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1
    cp_type = 'all';
end

if strcmp(cp_type, 'all')
    s3d_list = s3d_get_singularity_list();
    s3d_list(9:end) = [];
end

for this_cp=1:length(s3d_list)
    cp_type = s3d_list(this_cp);
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
end
end %function test_sing_classification_critical_points_grid()
