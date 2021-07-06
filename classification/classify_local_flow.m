function local_flow_label = classify_local_flow(div_mag, curl_av, px, qy, rz)


%  s_px = sign(px);
%  s_qy = sign(qy);
%  s_rz = sign(rz);
 
  
% % Find well-edfined, rotationally invariant - zero-divergence flow
% zerodivergence = ismember([s_px(:) s_qy(:) s_rz(:)], [0  0  0], 'rows');
%  
% % Find well-defined, rotationally invariant - diverging flow
% diverging  = ismember([s_px(:) s_qy(:) s_rz(:)], [1  1  1], 'rows');
%  
% % Find well-defined, rotationally invariant - converging flow
% converging = ismember([s_px(:) s_qy(:) s_rz(:)], [-1  -1  -1], 'rows');
% 
% % Other cases                                         
% 
% % nonzero divergence in one or two dimensions parallel to the main
% % axes, but zero in the other - diverging
% nonzerodivergence_diverging1d2d = ismember([s_px(:) s_qy(:) s_rz(:)], [0  0  1;
%                                                                        1  0  0;
%                                                                        0  1  0;
%                                                                        1  1  0;
%                                                                        0  1  1;
%                                                                        1  0  1], 'rows');
%  % nonzero divergence in one or two dimensions parallel to the main
%  % axes, but zero in the other - converging                                       
% nonzerodivergence_converging1d2d = ismember([s_px(:) s_qy(:) s_rz(:)], [ 0   0  -1;
%                                                                         -1   0   0;
%                                                                          0  -1   0;
%                                                                         -1  -1   0;
%                                                                         -1   0  -1;
%                                                                          0  -1  -1], 'rows');
% 
% % Fringe case where sign sum is zero, but divergence is pos and neg in two other axis                                                                
% nonzerodivergence_straining = ismember([s_px(:) s_qy(:) s_rz(:)], [ 1   0  -1;
%                                                                     1  -1   0;
%                                                                     0   1  -1;
%                                                                     0  -1   1;
%                                                                    -1   1   0;
%                                                                    -1   0   1],'rows');
                                                                                                                                  
                                        

local_flow_label = nan(size(curl_av));

% Hardcoced threshold for curl and divergence
curl_th = 1e-6; % NOTE: to add as a parameter in params
div_th = 1e-3;  % NOTE: to add as a parameter in params

%
curl_abs = abs(curl_av);
curl_abs(curl_abs <= curl_th) = 0;
curl_av(curl_abs <= curl_th) = 0;

% Threshold divergence based on the magnitude
div_abs = abs(div_mag);
div_mag(div_abs <= div_th) = 0;

% Zero curl
class_00 = find((curl_av == 0) & (div_mag == 0));
class_01 = find((curl_av == 0) & (div_mag > 0));
class_02 = find((curl_av == 0) & (div_mag < 0));
class_03 = find((curl_av > 0) & (div_mag > 0));
class_04 = find((curl_av > 0) & (div_mag < 0));
class_05 = find((curl_av < 0) & (div_mag > 0));
class_06 = find((curl_av < 0) & (div_mag < 0));
class_07 = find((curl_av > 0) & (div_mag == 0));
class_08 = find((curl_av < 0) & (div_mag == 0));
class_09 = find(isnan(curl_av) | isnan(div_mag));

local_flow_label(class_00) = 0; %#ok<*FNDSB>
local_flow_label(class_01) = 1; 
local_flow_label(class_02) = 2;
local_flow_label(class_03) = 3; 
local_flow_label(class_04) = 4; 
local_flow_label(class_05) = 5; 
local_flow_label(class_06) = 6; 
local_flow_label(class_07) = 7; 
local_flow_label(class_08) = 8;
local_flow_label(class_09) = 9; 

end