function fig_handles = plot_singularity_counts(obj_sings, varargin)
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
%        plot1d_singularity_scatter_xyz_vs_time()
%        plot1d_singularity_count_traces
%
% USAGE:
%{
    
%}
% PSL, QIMR August 2019

%fig_visibility, to_plot, marker_plot

if nargin < 2
    fig_visibility = {'Visible', 'on'};
else
    fig_visibility = {'Visible', vis_status};
end
if nargin < 3
    to_plot = 'all';
end

if nargin < 4
    marker_plot = 'line';
end

base_list = s3d_get_base_singularity_list();

% Basic options
cp_base    = base_list(1:4);
cp_saddles = base_list(5:8);


% Plot scatters over time
fig_handles = cell(0); 
switch to_plot
    case {'counts'}
       % Count how many singularities of each type we have
       % Plot traces of each singularity
       fig_counts = plot1d_singularity_count_traces(obj_sings.count, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_counts;
    case {'foci'}
        fig_xyz_base = plot1d_singularity_scatter_xyz_vs_time(obj_sings.classification_num, ...
                                                              obj_sings.nullflow_points3d, ...
                                                              cp_base, ...
                                                              options.interpolation.xyz_lims, ...
                                                              marker_plot, fig_visibility{:});
        fig_handles{length(fig_handles)+1} = fig_xyz_base;
    case {'saddles'}
        fig_xyz_saddles = plot1d_singularity_scatter_xyz_vs_time(obj_sings.classification_num, ...
                                                                 obj_sings.nullflow_points3d, ...
                                                                 cp_saddles, ...
                                                                 options.interpolation.xyz_lims, ...
                                                                 marker_plot, fig_visibility{:});
        fig_handles{length(fig_handles)+1} = fig_xyz_saddles;
    case {'orbits'}
        fig_xyz_po = plot1d_singularity_scatter_xyz_vs_time(obj_sings.classification_num, ...
                                                            obj_sings.nullflow_points3d, ...
                                                            base_list(9:14), ...
                                                            options.interpolation.xyz_lims, ...
                                                            marker_plot, fig_visibility{:});
        fig_handles{length(fig_handles)+1} = fig_xyz_po;
    case {'combined'}
       fig_xyz_all_cp = plot1d_singularity_scatter_xyz_vs_time(obj_sings.classification_num, ...
                                                               obj_sings.nullflow_points3d, ...
                                                               base_list(1:14), ...
                                                               options.interpolation.xyz_lims, ...
                                                               marker_plot, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_xyz_all_cp;
    case {'all'}       
       % Plot traces of each singularity
       fig_counts = plot1d_singularity_count_traces(obj_sings.count, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_counts;
       
       % FOCI
       fig_xyz_base = plot1d_singularity_scatter_xyz_vs_time(obj_sings.classification_num, ...   
                                                             obj_sings.nullflow_points3d, ...
                                                             cp_base, ...
                                                             options.interpolation.xyz_lims, ...
                                                             marker_plot, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_xyz_base;
       
       % SADDLES
       fig_xyz_saddles = plot1d_singularity_scatter_xyz_vs_time(obj_sings.classification_num, ...   
                                                              obj_sings.nullflow_points3d, ...
                                                              cp_saddles, ...
                                                              options.interpolation.xyz_lims, ...
                                                              marker_plot, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_xyz_saddles;
       
       % ORBITS
       fig_xyz_orbits = plot1d_singularity_scatter_xyz_vs_time(obj_sings.classification_num, ...   
                                                               obj_sings.nullflow_points3d, ...
                                                               base_list(9:14), ...
                                                               options.interpolation.xyz_lims, ...
                                                               marker_plot, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_xyz_orbits;
       
       % COMBINED SINGS
       fig_xyz_all_cp = plot1d_singularity_scatter_xyz_vs_time(obj_sings.classification_num, ... 
                                                               obj_sings.nullflow_points3d, ...
                                                               base_list(1:14), ...
                                                               options.interpolation.xyz_lims, ...
                                                               marker_plot, fig_visibility{:});
       fig_handles{length(fig_handles)+1} = fig_xyz_all_cp;
       
    otherwise
       error(['neural-flows:' mfilename ':UnknownCase'], ...
               'Requested unknown visualisation case. Options: {"all", "foci", "counts"}');
end 


end % function plot_singularity_counts()
