function[params, obj_sings, obj_sings_sentinel] = singularity3d_detect(params)
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



     % Load flows data
    obj_flows = load_iomat_data(params);

    if isempty(params.singularity.detection.threshold)
        % Dodgy way of setting a threshold
        un_min = sqrt(obj_flows.ux_min.^2 + obj_flows.uy_min.^2 + obj_flows.uz_min.^2);
        params.singularity.detection.threshold = guesstimate_nullflows_threshold(un);
    end
    % Check if we are receiving one slice of the data
    if params.data.slice.enabled
        rng(params.data.slice.id)
        params = generate_slice_filename(params, 'singularity') 
    else
        rng(2020)
    end
    
    % Save flow calculation parameters
    [obj_singularity, obj_singularity_sentinel] = create_iomat_file(params.singularity.file.label, ...
                                                                    params.general.storage.dir, ...
                                                                    params.singularity.file.keep); 

    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started detection of null flows.'))

    switch inparams.singularity.detection.mode
        case {'null-flow-field', 'vel', 'flowfield', 'vectorfield'}
             % Use velocity vector fields
             flows3d_grid_detect_null_flow_field(obj_singularity, obj_flows, params);
        
        case {'surf', 'null-flow-surf', 'null-flow-isosurf'}
            error(['neural-flows:' mfilename ':NotImplemented'], ...
                   'This feature is not fully implemented.');
        otherwise
            error(['neural-flows:' mfilename ':UnknownCase'], ...
                   'Available detection methods: {"null-flow-field"}.');
            
    end  

    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished detection of null flows.'))
           
end %function singularity3d_detect()
