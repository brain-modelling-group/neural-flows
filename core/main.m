function ouparams = main(inparams)
%% Wrapper function to decide which workflow to use

% Tic
tstart = tik();

% Check if we need to interpolate data
if strcmp(inparams.data.grid.type, 'unstructured') && inparams.interpolation.enabled
   % Do the interpolation  
   data3d_interpolate()
elseif strcmp(inparams.data.grid.type, 'structured') && inparams.interpolation.enabled
   error(['neural-flows:' mfilename ':IncompatibleOptions'], 'Will not perform interpolation on gridded/structured data.');
elseif strcmp(inparams.data.grid.type, 'unstructured') && ~inparams.interpolation.enabled
   warning(['neural-flows:' mfilename ':NoInterpolation'], 'Skipping interpolation ...')
end

% Check which method we want to use - hsd3 only works with interpolate data, while cnem
switch inparams.flows.method.name
    case {'hs3d', 'horn-schunk', 'hs'}
        %
        tmp_params = main_flows_hs3d(data, locs, inparams);
    case {'cnem'}
        % main_flows_cnem()
        error(['neural-flows:' mfilename ':NotTested'], ...
               'Sorry mate, have not tested this one yet.');
    otherwise
        error(['neural-flows:' mfilename ':UnknownMethod'], ...
               'Unknown method. Options: {"hs3d", "cnem", "hours"}');
end

% Check what else we want to do
if inparams.flows.streamlines.enabled
    % Do x
    %main_streamlines()
end 

if inparams.singularity.detection.enabled 
    tmp_params = singularity3d_detect(temp_params)
end

if inparams.singularity.detection.enabled 
    tmp_params = singularity3d_detect(temp_params)
end

ouparams = tmp_params;

% Toc
tok(tstart, 'seconds')
tok(tstart, 'minutes')
tok(tstart, 'hours')

% Save parameter structure with updated fields and values
read_write_json(inparams.general.storage.params.output.filename, ...
                inparams.general.storage.params.output.dir, ...
                'write', ...
                ouparams)

end % function main()