function v = flows3d_cnem_phase(phi, locs, dt, opts)
%% Calculate instantaneous phase-based flow at every time point
%
% ARGUMENTS:
%          phi     -- a 2D array of size [time x nodes/locs] matrix of (signal's envelope) phases 
%                     (assumed unwrapped).
%          locs     -- a 2D array of size [nodes x 3] with the x,y,z
%                     coordinates of the nodes/regions centroids.
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
%     JA Roberts, QIMR Berghofer, 2018
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assume phases unwrapped in time already
% Calculate temporal gradient

if nargin < 4
    opts.is_phase = true;
    opts.alpha_radius = 30;
end

disp([mfilename ':: Calculating temporal gradient dphi/dt ...'])

[~, dphidtp] = gradient(phi, dt); %--> NOTE: This should be normalised by the time step size

disp([mfilename ':: Done.'])

% Create alpha shapes 
shpalpha = opts.alpha_radius; % alpha radius; may need tweaking depending on geometry and number of scattered points. 
shp      = alphaShape(locs, shpalpha);

% The boundary of the centroids is an approximation of the cortex
bdy = shp.boundaryFacets;

% Calculate matrix B of cnem
B = flows3d_cnem_get_B_mat(locs, bdy);

% Timepoints
tpts = size(phi, 1); 

% Allocate memory
dphidxp = zeros(size(phi));
dphidyp = zeros(size(phi));
dphidzp = zeros(size(phi));

fprintf([mfilename ':: Calculating phase-based flows ...'])

xdim = 1;
ydim = 2;
zdim = 3;

% Check if the values in phi are a phase value (angle) or not
if opts.is_phase
    
    for tt=1:tpts
        instant_phi = phi(tt, :);

        % wrap phases by differentiating exp(i*phi)
        yphasor   = exp(1i*instant_phi(:));
        gradphasor= flows3d_cnem_grad_V(B, yphasor);

        dphidxp(tt,:)=real(-1i*gradphasor(:,xdim).*conj(yphasor));
        dphidyp(tt,:)=real(-1i*gradphasor(:,ydim).*conj(yphasor));
        dphidzp(tt,:)=real(-1i*gradphasor(:,zdim).*conj(yphasor));
    end
else
    % NOTE: This part is not strictly correct because Rubino's work is based on
    %       the use of the phase of the signal envelope's.
    for tt=1:tpts
        instant_phi = phi(tt,:);
        instant_phi = instant_phi(:);
        gradphi = flows3d_cnem_grad_V(B, instant_phi);
        dphidxp(tt,:)= gradphi(:,xdim);
        dphidyp(tt,:)= gradphi(:,ydim);
        dphidzp(tt,:)= gradphi(:,zdim);
    end
end
    
% L2 norm of the phase gradients
normgradphip = sqrt(dphidxp.^2+dphidyp.^2+dphidzp.^2);

% Magnitude of phase-based velocity = dphidt / magnitude of grad phi, as per Rubino et al. (2006)
vnormp = abs(dphidtp)./normgradphip;

v.vnormp = vnormp;
v.vxp=vnormp.*-dphidxp./normgradphip; % magnitude * unit vector component
v.vyp=vnormp.*-dphidyp./normgradphip;
v.vzp=vnormp.*-dphidzp./normgradphip;
disp([mfilename ':: Done. \n'])
end % function flows3d_estimate_cnem_flow()
