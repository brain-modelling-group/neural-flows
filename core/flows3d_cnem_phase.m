function params = flows3d_cnem_phase(obj_data, obj_flows, params)
%function v = flows3d_cnem_phase(phi, locs, dt, opts)
%% Calculate instantaneous phase-based flow at every time point
%
% ARGUMENTS:
%          phi     -- a 2D array of size [time x nodes/locs] matrix of (signal's envelope) phases 
%                     (assumed unwrapped).
%          locs     -- a 2D array of size [nodes x 3] with the x,y,z
%                     coordinates of the nodes/regions centroidsnt = params.flows.data.shape.t.
%          dt      -- time step or sampling interval of the timseries in
%                     yphasep
%          opts    --  a struct with options, whose fields are:
%                      .is_phase -- boolean flag to define is the input data phi is 
%                                    an (unwrapped) angle value. Default:true.
%                      .alpha_radius -- radius of alpha shape to calculate
%                                       the convex hull encompassing all
%                                       points in `locs`. This parameter
%                                       may need tweaking depending on 
%                                       geometry and number of scattered points. 
%
% OUTPUT: 
%          v -- velocity struct, with fields:
%            -- vnormp - magnitude of velocity (speed) [time x nodes]
%            -- vxp - x component of the vector field of size [time x nodes]
%            -- vyp - y component of the vector field of size [time x nodes]
%            -- vzp - z component of the vector field of size [time x nodes]
%
% REQUIRES: 
%          flows3d_cnem_grad_V()
%          flows3d_cnem_get_B_mat()
%
% USAGE:
%{     
    

%}
%
% MODIFICATION HISTORY:
%     JA Roberts, QIMR Berghofer, 2018 -- Original.
%     PSL, QIMR Berghofer, 2020 -- Integration to neural flows toolbox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assume phases unwrapped in time already
% Calculate temporal gradient


% Get location and boundary masks
masks = obj_data.masks;
locs  = obj_data.locs;
ht    = params.data.resolution.ht;
tpts  = params.data.shape.timepoints;

switch params.flows.method.cnem.convex_hull
    case {'bi', 'bihemispheric'}
        boundary_triangles = masks.innies_triangles_bi; 
    case {'lr', 'left-right'}
        error(['neural-flows:' mfilename ':IncompatibleCase'], ...
              'CNEM will fail using individual convex hulls. Use bihemispheric.');
end


% Check if data was already transformed or not
if strcmp(params.data.modality, 'amplitude')
    phi = calculate_insta_phase(obj_data.data);
else
    phi = obj_data.phi;
end

fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Calculating temporal gradient dphi/dt.'))
[~, dphidtp] = gradient(phi, ht); %--> NOTE: This should be normalised by the time step size
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Done.'))

% Calculate matrix B of cnem
B = flows3d_cnem_get_B_mat(locs, boundary_triangles);

% Allocate memory - may get ugly if too large
dphidxp = zeros(size(phi));
dphidyp = zeros(size(phi));
dphidzp = zeros(size(phi));

fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Calculating phase-based flows with CNEM.'))
xdim = 1;
ydim = 2;
zdim = 3;

for tt=1:tpts
    instant_phi = phi(tt, :);

    % wrap phases by differentiating exp(i*phi)
    yphasor    = exp(1i*instant_phi(:));
    gradphasor = flows3d_cnem_grad_V(B, yphasor);

    dphidxp(tt, :) = real(-1i*gradphasor(:,xdim).*conj(yphasor));
    dphidyp(tt, :) = real(-1i*gradphasor(:,ydim).*conj(yphasor));
    dphidzp(tt, :) = real(-1i*gradphasor(:,zdim).*conj(yphasor));
end
    
% L2 norm of the phase gradients
normgradphip = sqrt(dphidxp.^2+dphidyp.^2+dphidzp.^2);

% Magnitude of phase-based velocity = dphidt / magnitude of grad phi, as per Rubino et al. (2006)
vnormp = abs(dphidtp)./normgradphip;

% Write to file - v is the name for phase based flows, while u is reserved for amplitude-based
obj_flows.vn = vnormp;
obj_flows.vx = vnormp.*-dphidxp./normgradphip; % magnitude * unit vector component
obj_flows.vy = vnormp.*-dphidyp./normgradphip;
obj_flows.vz = vnormp.*-dphidzp./normgradphip;
params.flows.data.shape.t = tpts;
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Done.'))

end % function flows3d_cnem_phase()
