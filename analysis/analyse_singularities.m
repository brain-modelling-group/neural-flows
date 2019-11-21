function fig_handles = analyse_singularities(mobj_sings, fig_visibility, to_plot, marker_plot)
% This function takes as an input a matfile with the list of
% singularities, and generates plots to give an idea of their
% beahviour over time and space (1d). It's basically a visual summary.
%
%
% ARGUMENTS:
%           mobj_sings -- a MatFile or a structure with the same internal
%                        structure with the singularitiy classification
%           fig_visibility   -- for the time being a 1 x 2 cell array with
%                         {'Visible', 'off'}, to set figures to invisible;
%           to_plot -- a string to tell this function what to plot in terms of scatter
%                     plots over time.
%
% OUTPUT:   
%
% REQUIRES: 
%        s3d_get_base_singularity_list()
%        s3d_get_numlabel()
%        s3d_count_singularities()
%        plot_singularity_scatter_xyz_vs_time()
%        plot_singularity_count_traces
%
% USAGE:
%{
    
%}
% PSL, QIMR August 2019

if nargin < 2
    fig_visibility = {'Visible', 'on'};
end

if nargin < 3
    to_plot = 'all';
end

if nargin < 4
    marker_plot = 'line';
end

singularity_list_num = s3d_str2num_label(mobj_sings.singularity_classification_list);
base_list = s3d_get_base_singularity_list();

% Basic options
cp_base = base_list(1:4);
cp_saddles = base_list(5:8);

options = mobj_sings.options;

% Plot scatters over time
fig_handles = cell(0); 
switch to_plot
    case {'counts'}
       % Count how many singularities of each type we have
       sing_count = s3d_count_singularities(singularity_list_num);
       % Plot traces of each singularity
       fig_counts = plot_singularity_count_traces(sing_count, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_counts;
    case {'foci'}
        fig_xyz_base = plot_singularity_scatter_xyz_vs_time(singularity_list_num, ...
                                                            mobj_sings.null_points_3d, ...
                                                            cp_base, ...
                                                            options.interpolation.xyz_lims, ...
                                                            marker_plot, fig_visibility{:});
        fig_handles{length(fig_handles)+1} = fig_xyz_base;
    case {'saddles'}
        fig_xyz_saddles = plot_singularity_scatter_xyz_vs_time(singularity_list_num, ...
                                                               mobj_sings.null_points_3d, ...
                                                               cp_saddles, ...
                                                               options.interpolation.xyz_lims, ...
                                                               marker_plot, fig_visibility{:});
        fig_handles{length(fig_handles)+1} = fig_xyz_saddles;
    case {'orbits'}
        fig_xyz_po = plot_singularity_scatter_xyz_vs_time(singularity_list_num, ...
                                                          mobj_sings.null_points_3d, ...
                                                          base_list(9:14), ...
                                                          options.interpolation.xyz_lims, ...
                                                          marker_plot, fig_visibility{:});
        fig_handles{length(fig_handles)+1} = fig_xyz_po;
    case {'combined'}
       fig_xyz_all_cp = plot_singularity_scatter_xyz_vs_time(singularity_list_num, ...
                                                            mobj_sings.null_points_3d, ...
                                                            base_list(1:14), ...
                                                            options.interpolation.xyz_lims, ...
                                                            marker_plot, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_xyz_all_cp;
    case {'all'}
       % We could use recursion, but that means singularity_num_list would
       % get recalculated every time ... not optimal
       % Count how many singularities of each type we have
       sing_count = s3d_count_singularities(singularity_list_num);
       % Plot traces of each singularity
       fig_counts = plot_singularity_count_traces(sing_count, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_counts;
       
       % FOCI
       fig_xyz_base = plot_singularity_scatter_xyz_vs_time(singularity_list_num, ...
                                                           mobj_sings.null_points_3d, ...
                                                           cp_base, ...
                                                           options.interpolation.xyz_lims, ...
                                                           marker_plot, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_xyz_base;
       
       % SADDLES
       fig_xyz_saddles = plot_singularity_scatter_xyz_vs_time(singularity_list_num, ...
                                                              mobj_sings.null_points_3d, ...
                                                              cp_saddles, ...
                                                              options.interpolation.xyz_lims, ...
                                                              marker_plot, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_xyz_saddles;
       
       % ORBITS
       fig_xyz_orbits = plot_singularity_scatter_xyz_vs_time(singularity_list_num, ...
                                                             mobj_sings.null_points_3d, ...
                                                             base_list(9:14), ...
                                                             options.interpolation.xyz_lims, ...
                                                             marker_plot, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_xyz_orbits;
       
       % COMBINED SINGS
       fig_xyz_all_cp = plot_singularity_scatter_xyz_vs_time(singularity_list_num, ...
                                                             mobj_sings.null_points_3d, ...
                                                             base_list(1:14), ...
                                                             options.interpolation.xyz_lims, ...
                                                             marker_plot, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_xyz_all_cp;
       
    otherwise
      disp('Unknown case')     
end 


end % function analyse_singularities()
