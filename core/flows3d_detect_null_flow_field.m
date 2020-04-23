function flows3d_detect_null_flow_field(obj_singularity, obj_flows, params)
% This evaluates the singularity detection functions, and the effect of the 
% threshold currently used.
%
% ARGUMENTS:
%          obj_singularity, where we need to store stuff 
%          obj_flows, data we need
%          params, almight structure
%                         
% OUTPUT: None
%          null_points_3d -- a struture of length tpts, with the following
%                            fields:
%                                   xyz_idx -- linear indices, with respect
%                                              to the grid size of the detected
%                                              singularities. 
%                                   x, y, z -- a float with the best approximation of the
%                                              coordinates of the singularities. 
%                                              Values wiill depend on the
%                                              resolution of the grid.
%
% REQUIRES: 
%           
%          
% USAGE:
%{     

%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon -- QIMR February 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tpts = params.flows.data.shape.t; 

    
null_points_3d = struct([]); 
X = mvel_obj.X;
Y = mvel_obj.Y;
Z = mvel_obj.Z;

    for tt=1:tpts
        % TODO: remove in the future as we now calculate the norm by
        % default
         un = sqrt(mvel_obj.ux(:, :, :, tt).^2 + mvel_obj.uy(:, :, :, tt).^2 +mvel_obj.uz(:, :, :, tt).^2);
         null_points_3d(tt).xyz_idx = locate_null_velocity_coordinates(un, detection_threshold);      
         null_points_3d(tt).x = locate_points(X, null_points_3d(tt).xyz_idx);
         null_points_3d(tt).y = locate_points(Y, null_points_3d(tt).xyz_idx);
         null_points_3d(tt).z = locate_points(Z, null_points_3d(tt).xyz_idx);
    end 
    
end

% Uses the vector fields to locate singularities
function xyz_idx = locate_null_velocity_coordinates(un, detection_threshold)
        
        % NOTE: need to come up with better ways to detect these points
        xyz_idx = find(un >= detection_threshold(1) & un < detection_threshold(2));

end

function p = locate_points(XX, idx)
    p = XX(idx);
end


