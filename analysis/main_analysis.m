function ouparams = main_analysis(inparams)
%% Wrapper function to perform basic analysis:
%  (1): svd decomposition
%  (2): singularity analysis

% Tic
tstart = tik();

% Copy structure
tmp_params = inparams;

%---------------------------------DECOMPOSITION-------------------------%
if inparams.flows.decomposition.svd.enabled
    % Check if we need to interpolate data
    perform_svd_mode_decomposition(inparams);

end
%---------------------------SINGULARITY---------------------------------%
if inparams.singularity.quantification.enabled

end

% Toc
 tok(tstart, 'seconds');
 tok(tstart, 'minutes');
 tok(tstart, 'hours');

end % function main_analysis()
