function ouparams = main_core(inparams)
%% High-level function that navigates through available workflows based on 
% the parameters of the configuration file .json, which are stored in `inparams`.
% This function performs a combination of the following stages in neural-flows: 
%              1) interpolates the data onto a regular grid (ie, meshgrid).
%              2a) estimates neural flows using mesh-based methods.
%              2b) estimates neural flows using meshless methods  .
%              3) detects singularities (ie, detects null flows).
%              4) classifies singularities.
%              5) traces streamlines
display_info_banner(mfilename, 'STARTED CORE.', '#18181b', false);
% Tic
tstart = tik();
if inparams.general.parallel.enabled   
  open_parpool(inparams.general.parallel.workers_fraction);
end
% Copy structure
tmp_params = inparams;
% Save the date
tmp_params.general.timestamp = datetime;
%---------------------------------INTERPOLATION--------------------------------%
if inparams.interpolation.enabled
display_info_banner(mfilename, 'DATA INTERPOLATION', '#57a545', true)
 % Check if we need to interpolate data
    if strcmp(tmp_params.data.grid.type, 'structured') && tmp_params.interpolation.enabled
      error(['neural-flows:' mfilename ':IncompatibleOptions'], ...
              'Will not perform interpolation on gridded/structured data.');

    elseif strcmp(tmp_params.data.grid.type, 'unstructured') && ~tmp_params.interpolation.enabled
      warning(['neural-flows:' mfilename ':NoInterpolation'], ...
                'Skipping interpolation ...');

    elseif strcmp(tmp_params.data.grid.type, 'unstructured') && tmp_params.interpolation.enabled
       % Do the interpolation  
       [tmp_params, ~, obj_interp_sentinel] = data3d_interpolate(tmp_params);
    else
      % Presumably structured data
    end
end
%---------------------------------INTERPOLATION--------------------------------%
% Save parameters up to this point
save_params_checkpoint(tmp_params);
%---------------------------------FLOWS----------------------------------------%
if inparams.flows.enabled
   display_info_banner(mfilename, 'FLOWS ESTIMATION', '#4e947a', true);
   % Check which method we want to use - hsd3 only works with interpolated data, while cnem
   switch tmp_params.flows.method.implementation 
       case {'mesh-based'} % ONLY HS available       
           [tmp_params, ~, obj_flows_sentinel] = flows3d_hs3d_estimate(tmp_params);
       case {'meshless'}
            [tmp_params, ~, obj_flows_sentinel] = flows3d_cnem_estimate(tmp_params);
       otherwise
           error(['neural-flows:' mfilename ':UnknownCase'], ...
                  'Requested unknown method. Options: {"hs3d", "cnem"}');
   end
end
%---------------------------------FLOWS----------------------------------------%
% Save parameters up to this point
save_params_checkpoint(tmp_params);
%---------------------------------STREAMLINES----------------------------------%

% Check what else we want to do
if inparams.streamlines.enabled
   display_info_banner(mfilename, 'STREAMLINES TRACING', '#507895', true)
   [tmp_params, ~, obj_streamline_sentinel] = streams3d_trace(tmp_params);
end 
%---------------------------------STREAMLINES----------------------------------%
% Save parameters up to this point
save_params_checkpoint(tmp_params);
%---------------------------------SINGULARITY----------------------------------%
if inparams.singularity.enabled
   display_info_banner(mfilename, 'SINGULARITY IDENTIFICATION', '#455d86', true)
   % DETECTION
   if tmp_params.singularity.detection.enabled 
       [tmp_params, ~, obj_singularity_sentinel] = singularity3d_detect(tmp_params);
   end
   %--------------------------------------------------------------------------%
   % Save parameters up to this point
   save_params_checkpoint(tmp_params);
   %--------------------------------------------------------------------------%
   % CLASSIFICATION
   if tmp_params.singularity.classification.enabled 
      tmp_params = singularity3d_classify(tmp_params);
   end
end
%---------------------------------SINGULARITY----------------------------------%
%---------------------------------THE END -------------------------------------%
% Save parameters up to this point
ouparams = tmp_params;
% Toc
tok(tstart, 'minutes');
display_info_banner(mfilename, 'FINISHED CORE.', '#18181b', false);

% Save parameter structure with updated fields and values
read_write_json(ouparams.general.params.output.file.name, ...
                ouparams.general.params.output.file.dir, ...
                'write', ...
                ouparams);

   % Delete files if we don't want to keep them
   if inparams.interpolation.enabled
      delete(obj_interp_sentinel)
   end
   if inparams.flows.enabled
      delete(obj_flows_sentinel)
   end
   if inparams.streamlines.enabled
      delete(obj_streamline_sentinel)
   end

   if inparams.singularity.enabled
      delete(obj_singularity_sentinel)
   end
end % function main_core()
