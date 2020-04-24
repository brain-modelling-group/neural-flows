function[params, obj_sings, obj_sings_sentinel] = singularity3d_detect(params)
% This function runs the detection of null flows and saves the points in a new
% matfile. 
%
% ARGUMENTS:
%          
%          params   -- almighty structure 
%
% OUTPUT: 
%          obj_sings, obj_sings_sentinel
%
% REQUIRES: 
%           guesstimate_nullflows_threshold()
%           flows3d_grid_detect_null_flow_field()
%           create_iomat_file()
%           generate_slice_filename
% USAGE:
%{     

%}
%
% MODIFICATION HISTORY:
%  Paula Sanz-Leon -- QIMR December 2018



    % Load flows data
    obj_flows = load_iomat_flows(params);

    if isempty(params.singularity.detection.threshold)
        % Dodgy way of setting a threshold
        un_min = sqrt(obj_flows.ux_min.^2 + obj_flows.uy_min.^2 + obj_flows.uz_min.^2);
        params.singularity.detection.threshold = guesstimate_nullflows_threshold(un);
    end
    % Check if we are receiving one slice of the data
    if params.data.slice.enabled
        rng(params.data.slice.id)
        params = generate_slice_filename(params, 'singularity'); 
    else
        rng(2020)
    end
    
    % Save flow calculation parameters
    [obj_singularity, obj_singularity_sentinel] = create_iomat_file(params.singularity.file.label, ...
                                                                    params.general.storage.dir, ...
                                                                    params.singularity.file.keep); 

    obj_singularity_cell = strsplit(obj_singularity.Properties.Source, filesep);
    % Save properties of file
    params.singularity.file.exists = true;
    params.singularity.file.dir  = params.general.storage.dir;
    params.singularity.file.name = obj_singularity_cell{end};

    if strcmp(params.singularity.file.label, '')
        params.singularity.file.label = 'tmp_singularity';
    end

    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started detection of null flows.'))

    switch params.singularity.detection.mode
        case {'null-flow-field', 'vel', 'flowfield', 'vectorfield'}
             % Use velocity vector fields
             flows3d_detect_null_flow_field(obj_singularity, obj_flows, params);
        
        case {'surf', 'null-flow-surf', 'null-flow-isosurf'}
            %xperimental_detect_null_flow_isosurface(obj_singularity, obj_flows, params);
            error(['neural-flows:' mfilename ':NotImplemented'], ...
                   'This feature is not fully implemented.');
        otherwise
            error(['neural-flows:' mfilename ':UnknownCase'], ...
                   'Available detection methods: {"null-flow-field"}.');
            
    end  

    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished detection of null flows.'))
           
end %function singularity3d_detect()
