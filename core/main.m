function ouparams = main(inparams)
%% Wrapper function to decide which workflow to use
% This function takes as input neural activity recorded from scattered 
% points in 3D space (aka an unstructured grid)
% This function performs all the analysis steps availabe in neural-flows: 
%              1) interpolates the data onto a regular grid (ie, meshgrid).
%              2a) estimates neural flows (ie, velocity fields).
%              2b) estimates neural flows (ie, velocity fields).
%              3) detects singularities (ie, detects null flows).
%              4) classifies singularities.
%              5) Track singularities
% Tic
tstart = tik();
%-------------------------------------------------------------------------------%
if inparams.general.parallel.enabled
  open_parpool(inparams.general.parallel.workers_fraction)
end
% Copy structure
tmp_params = inparams;
%---------------------------------INTERPOLATION--------------------------------%
if inparams.interpolation.enabled
    % Check if we need to interpolate data
    if strcmp(tmp_params.data.grid.type, 'structured') && tmp_params.interpolation.enabled
       error(['neural-flows:' mfilename ':IncompatibleOptions'], ...
              'Will not perform interpolation on gridded/structured data.');

    elseif strcmp(tmp_params.data.grid.type, 'unstructured') && ~tmp_params.interpolation.enabled
       warning(['neural-flows:' mfilename ':NoInterpolation'], ...
                'Skipping interpolation ...')

    elseif strcmp(tmp_params.data.grid.type, 'unstructured') && tmp_params.interpolation.enabled
       % Do the interpolation  
       [tmp_params, obj_data, obj_interp_sentinel] = data3d_interpolate(tmp_params);
    else
      % Presumably structured data
    end
end
%---------------------------------INTERPOLATION--------------------------------%
% Save parameters up to this point
save_params_checkpoint(tmp_params)
%---------------------------------FLOWS----------------------------------------%
if inparams.flows.enabled
    % Check which method we want to use - hsd3 only works with interpolated data, while cnem
    switch tmp_params.flows.method.name
        case {'hs3d', 'horn-schunk', 'hs'}
            %
            [tmp_params, obj_flows, obj_flows_sentinel] = flows3d_hs3d_estimate(tmp_params);
        case {'cnem'}
            %[tmp_params, obj_flows, obj_flows_sentinel] = flows3d_estimate_cnem_hs(tmp_params, masks);
            % 
            error(['neural-flows:' mfilename ':NotTested'], ...
                   'Sorry mate, have not tested this one yet.');
        otherwise
            error(['neural-flows:' mfilename ':UnknownCase'], ...
                   'Requested unknown method. Options: {"hs3d", "cnem"}');
    end
end
%---------------------------------FLOWS----------------------------------------%
% Save parameters up to this point
save_params_checkpoint(tmp_params)
%---------------------------------STREAMLINES----------------------------------%

% Check what else we want to do
if tmp_params.flows.streamlines.enabled
     error(['neural-flows:' mfilename ':NotImplemented'], ...
               'This feature has not been implemented yet. Next!');
end 
%---------------------------------STREAMLINES----------------------------------%
% Save parameters up to this point
save_params_checkpoint(tmp_params)
%---------------------------------SINGULARITY----------------------------------%
if tmp_params.singularity.enabled
    % DETECTION
    if tmp_params.singularity.detection.enabled 
        [tmp_params, obj_singularity, obj_singularity_sentinel] = singularity3d_detect(tmp_params);
    end
    %-------------------------------------------------------------------------------%
    % Save parameters up to this point
    save_params_checkpoint(tmp_params)
    %-------------------------------------------------------------------------------%
    % CLASSIFICATION
    if tmp_params.singularity.classification.enabled 
       tmp_params = singularity3d_classify(tmp_params);
    end
end
%-------------------------------------------------------------------------------%
% save_tmp_params(tmp_params)
%TRACKING
%---------------------------------SINGULARITY----------------------------------%
%---------------------------------THE END -------------------------------------%
% Save parameters up to this point
ouparams = tmp_params;

% Toc
tok(tstart, 'seconds');
tok(tstart, 'minutes');
tok(tstart, 'hours');

% Save parameter structure with updated fields and values
read_write_json(ouparams.general.storage.params.output.filename, ...
                ouparams.general.storage.params.output.dir, ...
                'write', ...
                ouparams)

% Delete files if we don't want to keep them
%delete(obj_interp_sentinel)
%delete(obj_flows_sentinel)
%delete(obj_streamline_sentinel)
%delete(obj_singularity_sentinel)
end % function main()
