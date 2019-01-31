
function compute_neural_flows_3d_unstructured()

% This function takes a 2D array of size T x Nodes
% The nodes are assumed to be a brain network embedded in 3D dimensional space

% we need:
% centres of gravity (COGS) of each node
% dt
% limits of space, presumably coming from fmri data
% process one hemisphere or the whole brain

x_dim = 1;
y_dim = 2;
z_dim = 3;


lh_idx = [1:256, 513];
rh_idx = [257:512];

this_hm = lh_idx;
int_COG = round(COG);

% Data from one hemisphere
data_hm = data(this_hm, 1);

% This is the key step for the optical flow method to work
F = scatteredInterpolant(COG(this_hm, x_dim), COG(this_hm, y_dim), COG(this_hm, z_dim), data_hm(:), 'natural', 'none');

down_factor_xyz = 1; % Not allowed to get different downsampling for space
down_factor_t   = 1;

% Get limits for the structured grid if people did not give those
min_x = min(int_COG(this_hm, x_dim));
min_y = min(int_COG(this_hm, y_dim));
min_z = min(int_COF(this_hm, z_dim));

max_x = max(int_COG(this_hm, x_dim));
max_y = max(int_COG(this_hm, y_dim));
max_z = max(int_COF(this_hm, z_dim));

[X, Y, Z] = meshgrid(min_x:down_factor_xyz:max_x, ...
                     min_y:down_factor_xyz:max_y, ...
                     min_z:down_factor_xyz:max_z);

interpolated_data = F(X,Y,Z);


d2 = data(this_hm, 10);
F2 = scatteredInterpolant(int_COG(this_hm, 1), int_COG(this_hm, 2), int_COG(this_hm, 3), d2(:), 'natural', 'none');
v2 = F2(x, Y, Z);

[ux,uy,uz]=HS3D(v,v2,1,20);
% Enhance the quiver plot visually by downsizing vectors  
%   -f : downsizing factor
f=1;
uu=ux(1:f:size(ux,1),1:f:size(ux,2),1:f:size(ux,3)); 
vv=uy(1:f:size(ux,1),1:f:size(ux,2),1:f:size(ux,3)); 
ww=uz(1:f:size(ux,1),1:f:size(ux,2),1:f:size(ux,3)); 

xx = x(1:f:size(ux,1),1:f:size(ux,2),1:f:size(ux,3));
yy = y(1:f:size(ux,1),1:f:size(ux,2),1:f:size(ux,3));
zz = Z(1:f:size(ux,1),1:f:size(ux,2),1:f:size(ux,3));

figure;
quiver3(xx,yy,zz,uu,vv,ww,1); 

[curlx,curly,curlz,cav] = curl(xx,yy,zz,uu,vv,ww);

streamline(stream3(xx,yy,zz,uu,vv,ww, int_COG(:, 1),int_COG(:, 2),int_COG(:, 3)))



%% 
pcolor3(xx, yy, zz, cav, 'direct', 'alpha', 0.5)
cmap = bluered(256);
max_val = max(abs(cav(:)));
caxis([-max_val/2, max_val/2])
%%
pcolor3(xx, yy, zz, v2, 'direct', 'alpha', 0.5)


shpalpha = 3initial flow vectors, default value
%                                     is 0;0; % alpha radius; may need tweaking depending on geometry (of cortex?)
shp = alphaShape(COG(this_hm, :), shpalpha);

% The boundary of the centroids is an approximation of the cortex
bdy = shp.boundaryFacets;

%% Detect which points are in the alpha shape.
shp = alphaShape(COG(this_hm, :), shpalpha);
in = inShape(shp,xx(:),yy(:), zz(:));

%%
v2in = v2;
v2in(~in) = nan;
figure; pcolor3(xx, yy, zz, v2in, 'direct', 'alpha', 0.5);

trisurf(bdy, COG(this_hm, 1), COG(this_hm, 2), COG(this_hm, 3))

%% Plot isosurfaces

isosurface(xx,yy,zz,round(1000*v2in),-140);isonormals(xx,yy,zz,v2in,p)
daspect([1 1 1])
trisurf(bdy, COG(this_hm, 1), COG(this_hm, 2), COG(this_hm, 3))

nodeidx = 20;
ellipsoid(COG(nodeidx, 1), COG(nodeidx, 2), COG(nodeidx, 3), 5, 5, 5)
end % function compute_neural_flows_3d_unstructured()
