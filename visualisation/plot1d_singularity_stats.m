function figure_handles = plot1d_singularity_stats(inparams)
% Composite plotting function to display histograms and traces of each
% singularity over time

obj_sings = load_iomat_singularity(inparams);

figure_handles{1} = plot1d_singularity_traces_counts(obj_sings.count);
figure_handles{2} = plot1d_singularity_histograms(obj_sings.count);

end % function plot1d_singularity_stats()