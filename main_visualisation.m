function ouparams = main_visualisation(inparams)
%% Wrapper function to perform basic visualisation:
% People can write their own main function calling different combinations of 
% plotting functions
disp('------------------------------------------------------------------------')
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: VISUALISATION.'))              
disp('------------------------------------------------------------------------')
%---------------------------------DECOMPOSITION--------------------------------%
if inparams.flows.visualisation.enabled
    plot1d_speed_distribution(inparams);
    plot2d_svd_modes(inparams);
end
%---------------------------SINGULARITY----------------------------------------%
if inparams.singularity.visualisation.enabled
   plot2d_singularity_occupancy(inparams);
   plot1d_singularity_traces_sandplot(inparams);
   plot1d_singularity_stats(inparams);
end
%------------------------------------------------------------------------------%
% save_tmp_params(tmp_params)
%TRACKING
% TODO: write output parameters if reequired
end % function main_analysis()
