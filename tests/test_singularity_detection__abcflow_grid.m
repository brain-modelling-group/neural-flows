function test_singularity3d_detection__abcflow()
% This evaluates the singularity detection functions, and the effect of the 
% threshold currently used.
%
% ARGUMENTS:
%          mstruct_vel -- a structure with an unsteady abc flow, 
%                         generatedvia generate_flow3d_abc_unsteady_grid()
% OUTPUT: 
%          None
%
% REQUIRES: 
%          flows3d_grid_detect_nullflows_velocities()
%          singularity3d_classify_singularities()
%          s3d_produce_visual_summary()
%          
% USAGE:
%{     

%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon -- QIMR October 2019
% REFERENCES:
% Didov, Ulysky (2018) Analysis of stationary points and their bifurcations in the ABC flow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% arbitrary threshold
if nargin < 3
    detection_threshold = [0 2^-3]; % velocity norm values
end

mstruct_vel.detection_threshold = detection_threshold;

mobj_sing.null_points_3d = flows3d_grid_detect_nullflows_velocities(mstruct_vel);

% Perform classification
mobj_sing.singularity_classification_list = singularity3d_classify_singularities(mobj_sing.null_points_3d, mstruct_vel);

analyse_singularities(mobj_sing)


end %function test_singularity_detection__abcflow_grid()
