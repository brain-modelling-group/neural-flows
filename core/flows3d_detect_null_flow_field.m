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
%          nullflow_points3d -- a struture of length tpts, with the following
%                            fields:
%                                   locs.linear_idx -- linear indices, with respect
%                                              to the grid size of the detected
%                                              singularities. 
%                                   locs.x, .y, .z -- a float with the best approximation of the
%                                                     coordinates of the singularities. 
%                                                     Values wiill depend on the
%                                                     resolution of the grid.
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

    % Get parameters
    tpts = params.flows.data.shape.t; 
    detection_threshold = params.singularity.detection.threshold;
        
    nullflow_points3d = struct([]); 
    X = obj_flows.X;
    Y = obj_flows.Y;
    Z = obj_flows.Z;

    for tt=1:tpts     % hard to parallelise because obj_flows is a file or a structure
         un = obj_flows.un(:, :, :, tt);
         nullflow_points3d(tt).locs.linear_idx = locate_null_flow_index(un, detection_threshold);      
         nullflow_points3d(tt).locs.x = get_coordinate(X, nullflow_points3d(tt).locs.linear_idx);
         nullflow_points3d(tt).locs.y = get_coordinate(Y, nullflow_points3d(tt).locs.linear_idx);
         nullflow_points3d(tt).locs.z = get_coordinate(Z, nullflow_points3d(tt).locs.linear_idx);
    end 
    % Save
    obj_singularity.nullflow_points3d = nullflow_points3d;
    
end % function flows3d_detect_null_flow_field()

% Uses the vector fields to locate singularities
function idx = locate_null_flow_index(un, detection_threshold)
        
        % NOTE: need to come up with better ways to detect these points
        idx = find(un >= detection_threshold(1) & un < detection_threshold(2));

end % function locate_null_flow_index()

function p = get_coordinate(XX, idx)
    p = XX(idx);
end % function get_coordinate()
