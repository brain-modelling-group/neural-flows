function test_singularity_detection__abcflow_grid(mstruct_vel, abc, detection_threshold)
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
% REFERENCES:
% Didov, Ulysky (2018) Analysis of stationary points and their bifurcations in the ABC flow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% arbitrary threshold
if nargin < 3
    detection_threshold = [0 2^-4]; % velocity norm values
end

mstruct_vel.detection_threshold = detection_threshold;

null_points_3d = flows3d_grid_detect_nullflows_velocities(mstruct_vel);

% Perform classification
[singularity_classification_list] =   singularity3d_classify_singularities(null_points_3d, mstruct_vel);

[singularity_classification_num_list] =   s3d_str2num_label(singularity_classification_list);


% % Eqs(9)
% b = abc(:, 2);
% c = abc(:, 3);
% 
% % valid for c^2 >= 1- b^2
% px = sqrt((b.^2-c.^2+1)./(2*b.^2));
% py = sqrt((b.^2+c.^2-1)./(2*c.^2));
% py = sqrt((-b.^2+c.^2+1)./(2));
% 
% di = struct([]);
% gi = struct([]);
% 
% for tt=1:length(null_points_3d)
%        
%     di(tt).dx = sign(null_points_3d.x);
%     di(tt).dx(di(tt).dx == 0) = 1;
%     di(tt).dy = sign(null_points_3d.y);
%     di(tt).dy(di(tt).dy == 0) = 1;
%     di(tt).dz = sign(null_points_3d.z);
%     di(tt).dz(di(tt).dz == 0) = 1;
%     
%     gi(tt).gx = sign(sin(null_points_3d.x+pi/2));
%     gi(tt).dx(gi(tt).gx == 0) = 1;
%     gi(tt).gy = sign(sin(null_points_3d.y+pi/2));
%     gi(tt).gz = sign(sin(null_points_3d.z+pi/2));
%     
%     
% end

end %function test_singularity_detection__abcflow_grid()
