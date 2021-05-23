function local_flow_label = classify_local_flow(div_mag, px, qy, rz, curl_mag)


 s_px = sign(px);
 s_qy = sign(qy);
 s_rz = sign(rz);
 
 
 div_sum_sign = s_px + s_qy + s_rz;
 
 % Find well-edfined, rotationally invariant - laminar - zero-divergence
 laminar = ismember([s_px(:) s_qy(:) s_rz(:)], [0  0  0], 'rows');
 
 diverging  = ismember([s_px(:) s_qy(:) s_rz(:)], [1  1  1], 'rows');
 
 converging = ismember([s_px(:) s_qy(:) s_rz(:)], [-1  -1  -1], 'rows');

                                          
 div_sum_sign(lia) = 1;
 % Find fringe cases that are closer to laminar flow rather than

 % laminar, flow in one dimension parallel to the main
 % axes - nonzero divergence
laminar_nonzerodivergence_positive = ismember([s_px(:) s_qy(:) s_rz(:)], [0  0  1;
                                                                          1  0  0;
                                                                          0  1  0], 'rows');
                                       
laminar_nonzerodivergence_negative = ismember([s_px(:) s_qy(:) s_rz(:)], [ 0   0  -1;
                                                                          -1   0   0;
                                                                           0  -1   0], 'rows');
% Find fringe cases that yield zero sign but they are closer to straining
% flows
lia = ismember([s_px(:) s_qy(:) s_rz(:)], [1  1  0; 
                                           0  1  1; 
                                           1  0  1], 'rows');                                       
                                       
% Find fringe cases that yield zero sign but they are closer to straining
% flows
lia = ismember([s_px(:) s_qy(:) s_rz(:)], [0 -1  1; 
                                           0  1 -1; 
                                           1  0 -1; 
                                          -1  0  1; 
                                           0  1 -1; 
                                           0 -1  1], 'rows');
                                        
div_sum_sign(lia) = 0;
    %div_equal_sign = div_sum_sign;
    
    % Sum of signs equal zero means zero divergence, equal sign is not applicable
    %div_equal_sign(div_sum_sign==0)  = 0;
    % Sum of signs equal +/-3  means divergence has the same sign along each direction
    %div_equal_sign(div_sum_sign==-3) = 1;
    %div_equal_sign(div_sum_sign== 3) = 1;
    % Sum of signs equal +/-2  means divergence has the same sign along two
    % directions and zero along a third. Divergence happens on a plane.
    % Maybe points close to the boundary. Add them to equal sign.
    %div_equal_sign(div_sum_sign==-2) = 1;
    %div_equal_sign(div_sum_sign== 2) = 1;
    % Sum of signs equal +/-1  means divergence does not have the same sign along each direction
    %div_equal_sign(div_sum_sign==-1) = -1;
    %div_equal_sign(div_sum_sign==-1) = -1;

local_flow_label = nan(size(curl_av));
% Hardcoced threshold for curl and divergence
curl_th = 1e-3;
%div_th = 1e-3;

%
curl_m = abs(curl_av);
curl_m(curl_m <= curl_th) = 0;

% Threshold divergence based on the magnitude
%div_m = abs(div);
%div(div_m <= div_th) = 0;

% Classify stuff with curl==0 and with curl !=0
zerocurl_idx = find(curl_m == 0);
nonzerocurl_idx = find(curl_m > 0);
%% Zero curl flows
% Zero-divergent flow/ laminar flow - index 0
laminar_idx = div_sum_sign(zerocurl_idx) == 0;

[ii, jj, kk] = ind2sub(size(local_flow_label), zerocurl_idx(laminar_idx));

for idx=1:length(ii)
    local_flow_label(ii(idx), jj(idx), kk(idx)) = 0;
end

% Find straining/elongational flows -- related to saddle points
temp1 = find(div_sum_sign(zerocurl_idx) == -1);
temp2 = find(div_sum_sign(zerocurl_idx) == 1);
straining_idx = [temp1; temp2];

[ii, jj, kk] = ind2sub(size(local_flow_label), zerocurl_idx(straining_idx));

for idx=1:length(ii)
    local_flow_label(ii(idx), jj(idx), kk(idx)) = 1;
end

% Find diverging flows -- related to sources
temp1 = find(div_sum_sign(zerocurl_idx) == 3);
temp2 = find(div_sum_sign(zerocurl_idx) == 2);
diverging_idx = [temp1 temp2];

[ii, jj, kk] = ind2sub(size(local_flow_label), zerocurl_idx(diverging_idx));

for idx=1:length(ii)
    local_flow_label(ii(idx), jj(idx), kk(idx)) = 2;
end


% Find diverging flows -- related to sources
temp1 = find(div_sum_sign(zerocurl_idx) == -3);
temp2 = find(div_sum_sign(zerocurl_idx) == -2);
converging_idx = [temp1 temp2];

[ii, jj, kk] = ind2sub(size(local_flow_label), zerocurl_idx(converging_idx));

for idx=1:length(ii)
    local_flow_label(ii(idx), jj(idx), kk(idx)) = 3;
end


%% Nonzero curl flows
% Zero-divergent flow/ laminar flow - index 0
bending_idx = div_sum_sign(nonzerocurl_idx) == 0;

[ii, jj, kk] = ind2sub(size(local_flow_label), nonzerocurl_idx(bending_idx));

for idx=1:length(ii)
    local_flow_label(ii(idx), jj(idx), kk(idx)) = 4;
end

% Find straining/elongational flows -- related to saddle points
temp1 = find(div_sum_sign(nonzerocurl_idx) == -1);
temp2 = find(div_sum_sign(nonzerocurl_idx) == 1);
bending_straining_idx = [temp1; temp2];

[ii, jj, kk] = ind2sub(size(local_flow_label), nonzerocurl_idx(bending_straining_idx));

for idx=1:length(ii)
    local_flow_label(ii(idx), jj(idx), kk(idx)) = 5;
end

% Find diverging flows -- related to sources
temp1 = find(div_sum_sign(nonzerocurl_idx) == 3);
temp2 = find(div_sum_sign(nonzerocurl_idx) == 2);
swirling_diverging_idx = [temp1; temp2];

[ii, jj, kk] = ind2sub(size(local_flow_label), nonzerocurl_idx(swirling_diverging_idx));
for idx=1:length(ii)
    local_flow_label(ii(idx), jj(idx), kk(idx)) = 6;
end


% Find diverging flows -- related to sources
temp1 = find(div_sum_sign(nonzerocurl_idx) == -3);
temp2 = find(div_sum_sign(nonzerocurl_idx) == -2);
swirling_converging_idx = [temp1; temp2];

[ii, jj, kk] = ind2sub(size(local_flow_label), nonzerocurl_idx(swirling_converging_idx));

for idx=1:length(ii)
    local_flow_label(ii(idx), jj(idx), kk(idx)) = 7;
end

end

%function local_flow_label = set_flow_label(local_flow_label, curl_idx, local_flow_idx, local_flow_num)

%end