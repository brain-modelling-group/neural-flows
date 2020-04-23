function mfile_sings = singularity3d_detect(obj_flows, params)
% This function runs the detection of null flows and saves the points in a new
% matfile. 
%
% ARGUMENTS:
%          
%          mfile_flows   -- a handle to the MatFile 
%
% OUTPUT: 
%          mfile_sings   -- a handle to a Matfile with the singulrities
%
% REQUIRES: 
%           guesstimate_nullflows_threshold()
%           flows3d_grid_detect_nullflows_parallel()
%           create_temp_file()
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%  Paula Sanz-Leon -- QIMR December 2018



detection_threshold = params.singularity.detection.threshold.



if nargin < 2
    % Newer version
    detection_threshold = guesstimate_nullflows_threshold(mfile_flows.min_un);
end

% Save what we just found
if isfield(params.singularity.file, 'name')
   root_fname_sings = [params.singularity.file.name '-temp_snglrty-' num2str(params.data.slice.id, '%03d')];
else
   root_fname_sings = ['temp_snglrty-' num2str(params.data.slice.id, '%03d')];
end

keep_sings_file = params.singularity.file.keep;
[mfile_sings, mfile_sings_sentinel] = create_temp_file(root_fname_sings, keep_sings_file);

fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started detection of null flows.'))

% Use velocity vector fields
[null_points_3d]  = flows3d_grid_detect_nullflows_velocities(mfile_flows, detection_threshold);

mfile_sings.null_points_3d = null_points_3d;
% Save used threshold 
params.singularity.detection.threshold = detection_threshold; 
mfile_sings.params = params;
delete(mfile_sings_sentinel)

fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished detection of null flows.'))
       
end %function singularity3d_detection()
