%
mfile_surf = matfile('temp_isosurf_2019-03-21_16-45-07_qvGv');
%% Get one frame
surf_data = mfile_surf.isosurfs(1, 42);

% First isosurface
surfx.vertices = surf_data.vertices_ux;
surfx.faces    = surf_data.faces_x;

% Second isosurface
surfy.vertices = surf_data.vertices_uy;
surfy.faces    = surf_data.faces_y;

% Thirs isosurface
surfz.vertices = surf_data.vertices_uz;
surfz.faces    = surf_data.faces_z;

%% Plot surfaces
figure_surf = figure; 
ax = subplot(1,1,1);
hold(ax, 'on')

% 
xdim = 1;
ydim = 2;
zdim = 3;

trisurf(surfx.faces, surfx.vertices(:, xdim), surfx.vertices(:, ydim), surfx.vertices(:, zdim), 'FaceAlpha', 0.5, 'FaceColor', 'r', 'Edgecolor', 'none');
trisurf(surfy.faces, surfy.vertices(:, xdim), surfy.vertices(:, ydim), surfy.vertices(:, zdim), 'FaceAlpha', 0.5, 'FaceColor', 'g', 'Edgecolor', 'none');
trisurf(surfz.faces, surfz.vertices(:, xdim), surfz.vertices(:, ydim), surfz.vertices(:, zdim), 'FaceAlpha', 0.5, 'FaceColor', 'b', 'Edgecolor', 'none');
view([3 1 1])
axis equal
title ('Three test surfaces')
legend({'#1', '#2', '#3'});


%% Decimate surfaces for detection -- try this to move on 

fraction_to_keep = 0.1;

[mF, mV] = reducepatch(surfx.faces, surfx.vertices, fraction_to_keep);
dsurfx.faces = mF;
dsurfx.vertices = mV;

[mF, mV] = reducepatch(surfy.faces, surfy.vertices, fraction_to_keep);
dsurfy.faces = mF;
dsurfy.vertices = mV;

[mF, mV] = reducepatch(surfz.faces, surfz.vertices, fraction_to_keep);
dsurfz.faces = mF;
dsurfz.vertices = mV;



figure_dsurf = figure; 
ax = subplot(1,1,1);
hold(ax, 'on')

% 
xdim = 1;
ydim = 2;
zdim = 3;

trisurf(dsurfx.faces, dsurfx.vertices(:, xdim), dsurfx.vertices(:, ydim), dsurfx.vertices(:, zdim), 'FaceAlpha', 0.1, 'FaceColor', 'r', 'Edgecolor', 'none');
trisurf(dsurfy.faces, dsurfy.vertices(:, xdim), dsurfy.vertices(:, ydim), dsurfy.vertices(:, zdim), 'FaceAlpha', 0.1, 'FaceColor', 'g', 'Edgecolor', 'none');
trisurf(dsurfz.faces, dsurfz.vertices(:, xdim), dsurfz.vertices(:, ydim), dsurfz.vertices(:, zdim), 'FaceAlpha', 0.1, 'FaceColor', 'b', 'Edgecolor', 'none');
view([3 1 1])
axis equal
title ('Three decimated surfaces')
legend({'#1', '#2', '#3'});


%% Run SurfaceIntersection and plot the results
% Parts of Surface #1 and #2 are on the same plane and the intersection is
% a 2D area instead of collection of 1D edges

[intersect13, SurfXZ] = find_surface_intersection(dsurfx, dsurfz);
[intersect23, SurfYZ] = find_surface_intersection(dsurfy, dsurfz);
[intersect12, SurfXY] = find_surface_intersection(dsurfx, dsurfy);

%figure_intersection =figure;
%ax  = subplot(1,1,1);
%hold(ax, 'on');
%%
S=SurfXY; 
trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'r', 'FaceColor', 'r', 'marker', '.');
S=SurfXZ; 
trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'g', 'FaceColor', 'g', 'marker', '.');
S=SurfYZ; 
trisurf(S.faces, S.vertices(:,1),S.vertices(:,2),S.vertices(:,3),'EdgeColor', 'b', 'FaceColor', 'b', 'marker', '.');
title ('Surface/Surface intersections')
legend({'#1/#2', '#1/#3', '#2/#3'});
view([3 1 1])
axis equal