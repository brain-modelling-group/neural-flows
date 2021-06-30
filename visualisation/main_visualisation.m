function ouparams = main_visualisation(inparams)
%% Wrapper function to perform basic visualisation:
% People can write their own main_visualisation function calling different combinations of 
% plotting functions

display_info_banner(mfilename, 'STARTED VISUALISATION', '#966797', false)
%---------------------------------DECOMPOSITION--------------------------------%
if inparams.flows.visualisation.enabled
    %plot1d_speed_distribution(inparams);
    plot2d_svd_modes(inparams);
end
%---------------------------SINGULARITY----------------------------------------%
if inparams.singularity.visualisation.enabled
   plot3d_singularity_temporal_occupancy(inparams);
   plot2d_singularity_tracking_cross_stitch(inparams);
   plot1d_singularity_relative_temporal_occupancy(inparams);
   plot1d_singularity_relative_spatial_occupancy(inparams);
   plot1d_singularity_traces_sandplot(inparams);
   plot1d_singularity_stats(inparams);
   plotcomp_singularity_absolute_occupancy(inparams);
end
%------------------------------------------------------------------------------%
% TODO: write output parameters if required
display_info_banner(mfilename, 'FINISHED VISUALISATION', '#966797', false)

end % function main_analysis()
