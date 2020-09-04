function figure_handles = plot1d_singularity_stats(inparams)
% Composite plotting function to display histograms and traces of each
% singularity over time

obj_sings = load_iomat_singularity(inparams);

figure_handles{1} = plot1d_singularity_traces_counts(obj_sings.count);

if inparams.singularity.quantification.nodal_occupancy.enabled
    figure_handles{2} = plot1d_singularity_histograms(obj_sings.tracking_3d_matrix);
else
    figure_handles{2} = plot1d_singularity_histograms(obj_sings.count);
end
end % function plot1d_singularity_stats()