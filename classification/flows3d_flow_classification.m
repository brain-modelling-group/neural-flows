function flow_class_vector = flows3d_flow_classification(div_equal_sign_vec, curl_magnitude_vec, divergence_vec)

% div_equal_sign_vec -- a vector with true, false and nans if the signs of
% the divergence are all equal, not equal or are all zero (ie, zero divergence)
% divergence_vec  -- divergence values

% curl_magnitude_vec -- the magnitude of the curl (ie, >=0);

% Paula Sanz-Leon, Apil 2021, QIMRB

% First decide what to do with div_equal_sign

% find indices == nan -> planar flow
div_sign_nan_idx = isnan(div_equal_sign_vec);

% find indices == 1 -> sources/sinks spiral 
div_sign_ones_idx = div_equal_sign_vec==1;

% find indices == 0 -> saddles 
div_sign_zeros_idx = div_equal_sign_vec==0;

% threshold curl vector
curl_th = 1e-6;

% Threshold the curl vector 
zero_curl_vector = curl_magnitude_vec <= curl_th;

% positive divergence 
pos_div = divergence_vec > 0;
neg_div = divergence_vec < 0;

% Laminar flow -> zero-divergence and curl almost zero
if ~isempty(div_sign_nan_idx)
    laminar_flow = div_sign_nan_idx & zero_curl_vector;
else
    laminar_flow = [];
end

% Shear flow --> divergence with different signs and curl can be zero or
% not
if ~isempty(div_sign_zeros_idx)
    shear_flow =  div_sign_zeros_idx;
else
    shear_flow = [];
end

if ~isempty(div_sign_ones_idx)
    
    % Diverging flow - > all divergence signs equal, positive divergence and
    % zero curl.
    diverging_flow = div_sign_ones_idx & pos_div & zero_curl_vector;

    % Diverging flow - > all divergence signs equal, negative divergence and
    % zero curl.
    converging_flow = div_sign_ones_idx & neg_div & zero_curl_vector;
    
    % Rotating flow ->   all divergence signs equal & nonzero curl
    rotating_flow = div_sign_ones_idx & ~(zero_curl_vector);
    
else
     diverging_flow =[];
     converging_flow =[];
     rotating_flow =[];
end

% Rotating flow ->   zero-divergence signs equal & nonzero curl
if ~isempty(div_sign_nan_idx)
    rotating_flow(div_sign_nan_idx & ~zero_curl_vector) = 1;
end
% one last pass for rotating


% -1: unclassfied/other/not-applicable
flow_class_vector = -ones(size(div_equal_sign_vec));

% Class 0: laminar flow
flow_class_vector(laminar_flow) = 0;
% Class 1: shear_flow 
flow_class_vector(shear_flow) = 1;
% Class 2: diverging flow
flow_class_vector(diverging_flow) = 2;
% Class 3: converging flow
flow_class_vector(converging_flow) = 3;
% Class 4: rotating flow
flow_class_vector(rotating_flow) = 4;

end %function flows3d_flow_classification()
