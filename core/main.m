function ouparams = main(inparams)
%% Wrapper function to decide which workflow to use
% This function takes as input neural activity recorded from scattered 
% points in 3D space (aka an unstructured grid)
% This function performs all the analysis steps availabe in neural-flows: 
%              1) interpolates the data onto a regular grid (ie, meshgrid).
%              2) estimates neural flows (ie, velocity fields).
%              3) detects singularities (ie, detects null flows).
%              4) classifies singularities.
% Tic
tstart = tik();

% Copy structure
tmp_params = inparams;

% Check if we need to interpolate data
if strcmp(tmp_params.data.grid.type, 'structured') && tmp_params.interpolation.enabled
   error(['neural-flows:' mfilename ':IncompatibleOptions'], ...
          'Will not perform interpolation on gridded/structured data.');

elseif strcmp(tmp_params.data.grid.type, 'unstructured') && ~tmp_params.interpolation.enabled
   warning(['neural-flows:' mfilename ':NoInterpolation'], ...
            'Skipping interpolation ...')

elseif strcmp(tmp_params.data.grid.type, 'unstructured') && tmp_params.interpolation.enabled
   % Do the interpolation  
   [tmp_params, masks] = data3d_interpolate(tmp_params)
else
  % Presumably structured data
end

% Check which method we want to use - hsd3 only works with interpolated data, while cnem
switch tmp_params.flows.method.name
    case {'hs3d', 'horn-schunk', 'hs'}
        %
        [tmp_params, obj_flows, obj_flows_sentinel] = flows3d_estimate_hs3d(tmp_params, masks);
    case {'cnem'}
        % temp_params = flows3d_estimate_cnem(params, masks)
        error(['neural-flows:' mfilename ':NotTested'], ...
               'Sorry mate, have not tested this one yet.');
    otherwise
        error(['neural-flows:' mfilename ':UnknownMethod'], ...
               'Unknown method. Options: {"hs3d", "cnem", "hours"}');
end

% Check what else we want to do
if tmp_params.flows.streamlines.enabled
    % Do x
    %streamlines3d_trace()
end 

if tmp_params.singularity.detection.enabled 
    tmp_params = singularity3d_detect(tmp_params)
end

if tmp_params.singularity.detection.enabled 
    tmp_params = singularity3d_detect(tmp_params)
end

ouparams = tmp_params;

% Toc
tok(tstart, 'seconds')
tok(tstart, 'minutes')
tok(tstart, 'hours')

% Save parameter structure with updated fields and values
read_write_json(tmp_params.general.storage.params.output.filename, ...
                tmp_params.general.storage.params.output.dir, ...
                'write', ...
                ouparams)

end % function main()