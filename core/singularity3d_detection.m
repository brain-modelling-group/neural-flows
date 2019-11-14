function mfile_sings = singularity3d_detection(mfile_flows, detection_threshold)
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


options = mfile_flows.options; 

if nargin < 2
    try 
        % Newer version
        detection_threshold = guesstimate_nullflows_threshold(mfile_flows.min_un);
    catch 
        % Older version, to remove
        detection_threshold = guesstimate_nullflows_threshold(mfile_flows.min_nu);
    end
end



% Save what we just found
if isfield(options.sing_analysis, 'filename_string')
   root_fname_sings = [options.sing_analysis.filename_string '-temp_snglrty-' num2str(options.chunk, '%03d')];
else
   root_fname_sings = ['temp_snglrty-' num2str(options.chunk, '%03d')];
end

keep_sings_file = true;
[mfile_sings, mfile_sings_sentinel] = create_temp_file(root_fname_sings, keep_sings_file);

fprintf('%s \n', strcat('neural-flows:: ', mfilename, ':: Started detection of null flows.'))

% Use velocity vector fields
[null_points_3d]  = flows3d_grid_detect_nullflows_velocities(mfile_flows, detection_threshold);

mfile_sings.null_points_3d = null_points_3d;
% Save threshold again
mfile_sings.detection_threshold = detection_threshold;
delete(mfile_sings_sentinel)

fprintf('%s \n', strcat('neural-flows:: ', mfilename, ':: Finished detection of null flows.'))
       
end %function singularity3d_detection()
