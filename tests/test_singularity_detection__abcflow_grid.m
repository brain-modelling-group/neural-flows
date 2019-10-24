function test_singularity_detection__abcflow_grid(mstruct_vel, detection_threshold)
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
%           flows3d_grid_detect_nullflows_velocities()
%          
% USAGE:
%{     

%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon -- QIMR October 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% arbitrary threshold
if nargin < 2
    detection_threshold = [0 2^-4]; % velocity norm values
end

mstruct_vel.detection_threshold = detection_threshold;

null_points_3d = flows3d_grid_detect_nullflows_velocities(mvel_obj);



end %function test_singularity_detection__abcflow_grid()
