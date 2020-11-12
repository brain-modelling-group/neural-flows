function ouparams = main_visualisation(inparams)
%% Wrapper function to perform basic visualisation:
% People can write their own main_visualisation function calling different combinations of 
% plotting functions
disp('------------------------------------------------------------------------')
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: MAIN VISUALISATION.'))              
disp('------------------------------------------------------------------------')
%---------------------------------DECOMPOSITION--------------------------------%
if inparams.flows.visualisation.enabled
    plot1d_speed_distribution(inparams);
    plot2d_svd_modes(inparams);
end
%---------------------------SINGULARITY----------------------------------------%
if inparams.singularity.visualisation.enabled
   plot3d_singularity_spheres(inparams);
   plot2d_singularity_occupancy(inparams);
   plot2d_singularity_cross_stitch_tracking(inparams);
   plot1d_singularity_punchcard(inparams);
   plot1d_singularity_punchcard_nodal(inparams);
   plot1d_singularity_traces_sandplot(inparams);
   plot1d_singularity_stats(inparams);
end
%------------------------------------------------------------------------------%
% TODO: write output parameters if required
end % function main_analysis()
