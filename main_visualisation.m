function ouparams = main_visualisation(inparams)
%% Wrapper function to perform basic analysis:
%  (1): svd decomposition
%  (2): singularity analysis

% Tic
tstart = tik();

% Copy structure
tmp_params = inparams;

%---------------------------------DECOMPOSITION-------------------------%
if inparams.flows.visualisation.enabled
    plot1d_speed_distribution(output_params)
end
%---------------------------SINGULARITY---------------------------------%
if inparams.singularity.visualisation.enabled
   plot2d_singularity_occupancy(inparams)
   plot1d_singularity_traces(inparams)
end
%-------------------------------------------------------------------------------%
% save_tmp_params(tmp_params)
%TRACKING
% TODO: write output parameters if reequired

% Toc
 tok(tstart, 'seconds');
 tok(tstart, 'minutes');
 tok(tstart, 'hours');

end % function main_analysis()
