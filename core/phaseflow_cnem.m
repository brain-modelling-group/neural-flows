function v = phaseflow_cnem(yphasep, loc, dt)
%% Calculate instantaneous phase flow at every time point
%
% ARGUMENTS:
%          yphasep -- a 2D array of size [time x nodes] matrix of phases,
%                     assumed unwrapped.
%          loc     -- a 2D array of size [nodes x 3] with the x,y,z
%                     coordinates of the nodes/regions centroids.
%          dt      -- time step or sampling interval of the timseries in
%                     yphasep
%
% OUTPUT: 
%          v -- velocity struct, with fields:
%            -- vnormp - magnitude of velocity (speed) [time x nodes]
%            -- vxp - x component of size [time x nodes]
%            -- vyp - y component of size [time x nodes]
%            -- vzp - z component of size [time x nodes]
%
% REQUIRES: 
%          None
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
fprintf('Calculating temporal gradient dphi/dt ...')

[~,dphidtp] = gradient(yphasep,dt);

fprintf('Done.')

% Create alpha shapes 
shpalpha = 30; % alpha radius; may need tweaking depending on geometry (of cortex?)
shp = alphaShape(loc, shpalpha);

% The boundary of the centroids is an approximation of the cortex
bdy = shp.boundaryFacets;

% Calculate matrix B of cnme
B = grad_B_cnem(loc, bdy);

% Timepoints
np = size(yphasep,1); 

% Allocate memory
dphidxp = zeros(size(yphasep));
dphidyp = zeros(size(yphasep));
dphidzp = zeros(size(yphasep));

fprintf('Calculating phase gradients ...')

for j=1:np
    yphase=yphasep(j,:);
    
    % wrap phases by differentiating exp(i*phi)
    yphasor   = exp(1i*yphase(:));
    gradphasor= grad_cnem(B,yphasor);
    
    dphidxp(j,:)=real(-1i*gradphasor(:,1).*conj(yphasor));
    dphidyp(j,:)=real(-1i*gradphasor(:,2).*conj(yphasor));
    dphidzp(j,:)=real(-1i*gradphasor(:,3).*conj(yphasor));
end

% L2 norm of the phase gradients
normgradphip = sqrt(dphidxp.^2+dphidyp.^2+dphidzp.^2);

% Magnitude of phase velocity = dphidt / magnitude of grad phi, as per Rubino et al. (2006)
vnormp = abs(dphidtp)./normgradphip;

v.vnormp = vnormp;
v.vxp=vnormp.*-dphidxp./normgradphip; % magnitude * unit vector component
v.vyp=vnormp.*-dphidyp./normgradphip;
v.vzp=vnormp.*-dphidzp./normgradphip;
fprintf('Done. \n')
end
