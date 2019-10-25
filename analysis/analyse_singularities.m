function sing_count = analyse_singularities(singularity_list_str, null_points_3d)
% This function takes as an input a matfile with the list of
% singularities, and generates plots to give an idea of their
% beahviour over time
%
%
% ARGUMENTS:
%        singularity_list_str -- singularity cell array of size 1 x tpts,
%                                with the string labels of singularities detected at each time
%                                point
%        XYZ       -- the original XYZ grid as a 2D array of size [numpoints x 3] array  
%
% OUTPUT: 
%        sing_numeric_labels -- a struct of length num_frames/timepoints
%             .numlabels     -- 
%             .color         --  
%
% REQUIRES: 
%        s3d_get_base_singularity_list()
%        s3d_get_numlabel()
%        s3d_count_singularities()
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
% PSL, QIMR 2019

% Get basic info
num_frames = length(singularity_list_str);

singularity_list_num = s3d_str2d_num_label(singularity_list_str);

% Count how many singularities of each type we have
sing_count = s3d_count_singularities(singularity_list_num);

% Plot traces of each singularity
plot_singularity_count_traces(sing_count)

% NOTE: use sing_labels, rather than the file, so we can 
% pass directly the output of this function and save ourselves a bit of
% time.
plot_singularity_scatter_xyz_vs_time(singularity_list_str, sing_labels, XYZ, num_frames)


end % function analyse_singularities()


