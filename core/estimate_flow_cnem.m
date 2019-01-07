function v = calculate_flow_cnem(phi, loc, dt, is_phase)
%% Calculate instantaneous phase flow at every time point
%
% ARGUMENTS:
%          phi -- a 2D array of size [time x nodes] matrix of activity
%                     or phases (assumed unwrapped).
%          loc     -- a 2D array of size [nodes x 3] with the x,y,z
%                     coordinates of the nodes/regions centroids.
%          dt      -- time step or sampling interval of the timseries in
%                     yphasep
%          is_phase -- boolean flag to define is the input data phi is 
%                      an (unwrapped) angle value.
%
% OUTPUT: 
%          v -- velocity struct, with fields:
%            -- vnormp - magnitude of velocity (speed) [time x nodes]
%            -- vxp - x component of the vector field of size [time x nodes]
%            -- vyp - y component of the vector field of size [time x nodes]
%            -- vzp - z component of the vector field of size [time x nodes]
%
% REQUIRES: 
%          grad_cnem()
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
disp('Calculating temporal gradient dphi/dt ...')

[~,dphidtp] = gradient(phi, dt);

disp('Done.')

% Create alpha shapes 
shpalpha = 30; % alpha radius; may need tweaking depending on geometry and number of scattered points. 
shp      = alphaShape(loc, shpalpha);

% The boundary of the centroids is an approximation of the cortex
bdy = shp.boundaryFacets;

% Calculate matrix B of cnme
B = grad_B_cnem(loc, bdy);

% Timepoints
tpts = size(phi, 1); 

% Allocate memory
dphidxp = zeros(size(phi));
dphidyp = zeros(size(phi));
dphidzp = zeros(size(phi));

fprintf('Calculating phase gradients ...')

xdim=1;
ydim=2;
zdim=3;
% Chec if the values in phi are a phase value (angle) or not
if is_phase
    
    for j=1:tpts
        instant_phi = phi(j,:);

        % wrap phases by differentiating exp(i*phi)
        yphasor   = exp(1i*instant_phi(:));
        gradphasor= grad_cnem(B, yphasor);

        dphidxp(j,:)=real(-1i*gradphasor(:,xdim).*conj(yphasor));
        dphidyp(j,:)=real(-1i*gradphasor(:,ydim).*conj(yphasor));
        dphidzp(j,:)=real(-1i*gradphasor(:,zdim).*conj(yphasor));
    end
else
    for j=1:tpts
        instant_phi = phi(j,:);
        instant_phi = instant_phi(:);
        
        gradphi = grad_cnem(B, instant_phi);
        
        dphidxp(j,:)= gradphi(:,xdim);
        dphidyp(j,:)= gradphi(:,ydim);
        dphidzp(j,:)= gradphi(:,zdim);
    end
end
    
    

% L2 norm of the phase gradients
normgradphip = sqrt(dphidxp.^2+dphidyp.^2+dphidzp.^2);

% Magnitude of phase velocity = dphidt / magnitude of grad phi, as per Rubino et al. (2006)
vnormp = abs(dphidtp)./normgradphip;

v.vnormp = vnormp;
v.vxp=vnormp.*-dphidxp./normgradphip; % magnitude * unit vector component
v.vyp=vnormp.*-dphidyp./normgradphip;
v.vzp=vnormp.*-dphidzp./normgradphip;
disp('Done. \n')
end % function calculate_flow_cnem()
