function mfile_sings = singularity3d_detection(mfile_flows, detection_threshold)

% A complete mflows Matfile should have all necessary options. mfile flows
% should be writable.

options = mflows_obj.options; 

if nargin < 2
    
    try 
        % Newer version
        detection_threshold = guesstimate_nullflows_threshold(mfile_flows.min_un);
    catch 
        % Older version, to remove
        detection_threshold = guesstimate_nullflows_threshold(mfile_flows.min_nu);
    end
end

% Write new detection threshold
mfile_flows.detection_threshold = detection_threshold;
% Close the file to avoid corruption
mfile_flows.Properties.Writable = false;
       
switch options.sing_analysis.detection_datamode
    case 'surf'
        error(['neural-flows:: ', mfilename, '::FutureOption. This singularity detection datamode is not fully implemented yet.'])
        %fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started extraction of critical isosurfaces'))
        %Calculate critical isosurfaces
        %[mfile_surf, mfile_surf_sentinel] = xperimental_extract_null_isosurfaces_parallel(mfile_vel);
        %fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished extraction of critical isosurfaces'))
        % Detect intersection of critical isosurfaces
        % [null_points_3d]  = flows3d_hs3d_detect_nullflows_parallel(mfile_surf, X, Y, Z, in_bdy_mask, , options.sing_detection.datamode);
        % delete(mfile_surf_sentinel)
    case 'vel'
        % Use velocity vector fields
        [null_points_3d]  = flows3d_grid_detect_nullflows_parallel(mfile_flows, [], [], [], [], options.sing_analysis.detection_datamode);
               
    otherwise
        error(['neural-flows:: ', mfilename, '::UnknownOption. Invalid datamode for detecting singularities.'])
end

% Save what we just found
if isfield(options.sing_analysis, 'filename_string')
   root_fname_sings = [options.sing_analysis.filename_string '-temp_snglrty-' num2str(options.chunk, '%03d')];
else
   root_fname_sings = ['temp_snglrty-' num2str(options.chunk, '%03d')];
end

keep_sings_file = true;
[mfile_sings, mfile_sings_sentinel] = create_temp_file(root_fname_sings, keep_sings_file);
mfile_sings.null_points_3d = null_points_3d;
% Save threshold again
mfile_sings.detection_threshold = detection_threshold;
delete(mfile_sings_sentinel)
       
end %function singularity3d_detection()
