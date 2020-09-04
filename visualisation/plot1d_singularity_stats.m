function figure_handles = plot1d_singularity_stats(inparams)
% Composite plotting function to display histograms and traces of each
% singularity over time

obj_sings = load_iomat_singularity(inparams);

if inparams.singularity.quantification.nodal_occupancy.enabled
   singularity_count = squeeze(sum(obj_sings.tracking_3d_matrix, 2)).';
else
   singularity_count = obj_sings.count;
end
figure_handles{1} = plot1d_singularity_traces_counts(singularity_count);
figure_handles{2} = plot1d_singularity_histograms(singularity_count);

end % function plot1d_singularity_stats()