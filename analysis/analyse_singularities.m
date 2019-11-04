function varargout = analyse_singularities(mobj_sings, fig_visibility)
% This function takes as an input a matfile with the list of
% singularities, and generates plots to give an idea of their
% beahviour over time and space (1d). It's basically a visual summary.
%
%
% ARGUMENTS:
%           mobj_sings -- a MatFile or a structure with the same internal
%                        structure with the singularitiy classification
%            fig_visibility   -- for the time being a 1 x 2 cell array with
%                         {'Visible', 'off'}, to set figures to invisible;
%
% OUTPUT:   
%
% REQUIRES: 
%        s3d_get_base_singularity_list()
%        s3d_get_numlabel()
%        s3d_count_singularities()
%        plot_singularity_scatter_xyz_vs_time
%
% USAGE:
%{
    
%}
% PSL, QIMR August 2019

if nargin < 2
    fig_visibility = {'Visible', 'on'};
end
singularity_list_num = s3d_str2num_label(mobj_sings.singularity_classification_list);
    
% Count how many singularities of each type we have
sing_count = s3d_count_singularities(singularity_list_num);

% Plot traces of each singularity
fig_counts = plot_singularity_count_traces(sing_count, fig_visibility{:});

base_list = s3d_get_base_singularity_list();

% Basic options
cp_base = base_list(1:4);
cp_saddles = base_list(5:8);

% Plot scatters over time
 fig_xyz_base    = plot_singularity_scatter_xyz_vs_time(singularity_list_num, mobj_sings.null_points_3d, cp_base, fig_visibility{:});
 fig_xyz_saddles = plot_singularity_scatter_xyz_vs_time(singularity_list_num, mobj_sings.null_points_3d, cp_saddles, fig_visibility{:});
 fig_xyz_po = plot_singularity_scatter_xyz_vs_time(singularity_list_num, mobj_sings.null_points_3d, base_list(9:14), fig_visibility{:});
 fig_xyz_all_cp = plot_singularity_scatter_xyz_vs_time(singularity_list_num, mobj_sings.null_points_3d, base_list(1:14), fig_visibility{:});
 
 % Return figure handles
 varargout{1} = {fig_xyz_base};
 varargout{2} = {fig_xyz_saddles};
 varargout{3} = {fig_xyz_all_cp};
 varargout{4} = {fig_xyz_po};
 varargout{5} = {fig_counts};

end % function analyse_singularities()
