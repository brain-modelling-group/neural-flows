
function compute_neural_flows_3d_ug(data)
    % data: a 2D array of size T x Nodes or 4D array
    % compute neural flows from (u)nstructured (g)rids/scattered datapoints
    % cogs: centres of gravity: node locations assumed to be a brain network embedded in 3D dimensional space
    % we need: dt
    % limits of space, presumably coming from fmri data
    % flag to process one hemisphere or the whole brain. Default bh, lh, rh
    % TODO: estimate timeppints of interest using the second order temporal
    % derivative
    % NOTEs on performance: Elapsed time is 2602.606860 seconds for half
    % hemisphere, 32 iterations max per pair of frames
    % 
    
    % flags to decide what to do with temp intermediate files
    keep_interp_file = true;
    keep_vel_file    = true;

    % Labels for 2D input arrays
    n_dim = 1; % time
    t_dim = 2; % nodes/regions
    
    tpts      = size(data, t_dim);
    num_nodes = size(data, n_dim);
    
    down_factor_t = 50; % Downsampling factor for t-axis
    data_hm = data(1:down_factor_t:tpts-1, :);
    % Recalculate timepoints
    tpts = size(data_hm, 1);

  
    
    % NOTE: full resolution (eg, approx dxyz=1mm^3), each interpolation
    % step takes about 24 seconds.
    % downsampling to 8mm^3 - side 2mm it takes 3s.
    
    int_locs = floor(locs);
    data = data(:, this_hm);
    
    % Labels for dimensions of 4D arrays arrays
    x_dim = 1;
    y_dim = 2;
    z_dim = 3;
    %t_dim = 4;
    down_factor_xyz = 2; % Not allowed to get different downsampling for space

    
    % Get limits for the structured grid if people did not give those
    min_x = min(int_locs(:, x_dim));
    min_y = min(int_locs(:, y_dim));
    min_z = min(int_locs(:, z_dim));

    max_x = max(int_locs(:, x_dim));
    max_y = max(int_locs(:, y_dim));
    max_z = max(int_locs(:, z_dim));
    
    % Create the grid
    [X, Y, Z] = meshgrid(min_x:down_factor_xyz:max_x, ...
                         min_y:down_factor_xyz:max_y, ...
                         min_z:down_factor_xyz:max_z);
   
    
    
    % Trial run to get 
    shp_alpha_radius = 30; % alpha radius. May be adjustable
    shp = alphaShape(locs, shp_alpha_radius);

    % The boundary of the centroids is an approximation of the cortex
    %bdy = shp.boundaryFacets;
    
    % Detect which points are in the alpha shape.
    in_bdy_mask = inShape(shp, X(:), Y(:), Z(:));
    
    % Perform interpolation on the data and save in temp file
    
    fprintf('%s \n', strcat('patchflow: ', mfilename, ': Interpolating data'))
    [mfile_interp, mfile_interp_sentinel] = interpolate_3d_data(data, locs, X, Y, Z, in_bdy_mask, keep_interp_file); 
    

    % Default parameters -- could be changed
    alpha_smooth   = 1;
    max_iterations = 8;
    
    % Determine some initial conditions based
    NAN_MASK = ~in_bdy_mask;
    
    % Get some dummy initial conditions
    [uxo, uyo, uzo] = get_initial_velocity_distribution(X, NAN_MASK, 42);
    
    % We open a matfile to store output and avoid huge memory usage 
    root_fname_vel = 'temp_velocity';
    
    [mfile_vel, mfile_vel_sentinel] = create_temp_file(root_fname_vel, keep_vel_file); 
    
    % The following lines will create the file on disk
    mfile_vel.ux(size(uxo, x_dim), size(uxo, y_dim), size(uxo, z_dim), tpts-1) = 0;    
    mfile_vel.uy(size(uyo, x_dim), size(uyo, y_dim), size(uyo, z_dim), tpts-1) = 0;
    mfile_vel.uz(size(uzo, x_dim), size(uzo, y_dim), size(uzo, z_dim), tpts-1) = 0;
    
   %% 
   tic;
    for this_tpt = 1:tpts-1
           
       FA = mfile_interp.data(:, :, :, this_tpt);
       FB = mfile_interp.data(:, :, :, this_tpt+1);
       
       % Calculate the velocity components
       [uxo, uyo, uzo] = compute_flow_hs3d(FA, FB, alpha_smooth, max_iterations, ...
                                           uxo, uyo, uzo);                                
              
       % Save the velocity components
       % TODO: do it every 5-10 samples perhaps - spinning disks may be a
       % problem for execution times
       mfile_object.ux(:, :, :, this_tpt) = uxo;
       mfile_object.uy(:, :, :, this_tpt) = uyo;
       mfile_object.uz(:, :, :, this_tpt) = uzo;
       
    end
    % Free some space
    clear uxo uyo uzo
    
    % Delete interpolated data file if keep_interp_file==true, otherwise
    % the variable is an empty array.
    clear mfile_interp_sentinel mfile_vel_sentinel
    
    
    toc;
    %% 

%%
    quiver_downsample = 2;

    xx = Z(1:quiver_downsample:size(X,x_dim),1:quiver_downsample:size(X,y_dim),1:quiver_downsample:size(X,z_dim));
    yy = Y(1:quiver_downsample:size(X,x_dim),1:quiver_downsample:size(X,y_dim),1:quiver_downsample:size(X,z_dim));
    zz = Z(1:quiver_downsample:size(X,x_dim),1:quiver_downsample:size(X,y_dim),1:quiver_downsample:size(X,z_dim));
%%    
for this_tpt=1:tpts-1
    
    % Enhance the quiver plot visually by downsizing vectors  
    uu = mfile_object.ux(1:quiver_downsample:size(X,x_dim),1:quiver_downsample:size(X,y_dim),1:quiver_downsample:size(Z,z_dim), this_tpt); 
    vv = mfile_object.uy(1:quiver_downsample:size(X,x_dim),1:quiver_downsample:size(Y,y_dim),1:quiver_downsample:size(Z,z_dim), this_tpt); 
    ww = mfile_object.uz(1:quiver_downsample:size(X,x_dim),1:quiver_downsample:size(Y,y_dim),1:quiver_downsample:size(Z,z_dim), this_tpt); 
    quiver3(xx, yy, zz, uu, vv, ww, 1)
    xlim([min_x, max_x])
    ylim([min_y, max_y])
    zlim([min_z, max_z])
    drawnow
end

%% 
data =  mfile_object.data;
%%
[min_data, max_data] = find_min_max(data, 'symmetric');
%%
    this_tpt = 1;
    temp_data =  data(:, :, :, this_tpt);
    hpcolor3 = pcolor3(X, Y, Z, temp_data, 'nx', size(temp_data, x_dim), ...
                                'ny', size(temp_data, y_dim), ...
                                'nz', size(temp_data, z_dim));
colormap(cmap)                            
for this_tpt=2:10;%tpts-1
    temp_data =  data(:, :, :, this_tpt);
    pcolor3(X, Y, Z, temp_data, 'nx', size(temp_data, x_dim), ...
                                'ny', size(temp_data, y_dim), ...
                                'nz', size(temp_data, z_dim))
    caxis([min_data/2, max_data/2])
    drawnow()
end
%
% pcolor3(xx, yy, zz, cav, 'direct', 'alpha', 0.5)
% cmap = bluered(256);
% max_val = max(abs(cav(:)));
% caxis([-max_val/2, max_val/2])
% %%
% pcolor3(xx, yy, zz, v2, 'direct', 'alpha', 0.5)
% v2in(~in) = nan;
% figure; pcolor3(xx, yy, zz, v2in, 'direct', 'alpha', 0.5);
% 
% trisurf(bdy, COG(this_hm, 1), COG(this_hm, 2), COG(this_hm, 3))
% 
% %% Plot isosurfaces
% isosurface(xx,yy,zz,round(1000*v2in),-140);isonormals(xx,yy,zz,v2in,p)
% daspect([1 1 1])
% trisurf(bdy, COG(this_hm, 1), COG(this_hm, 2), COG(this_hm, 3))
% 
% nodeidx = 20;
% ellipsoid(COG(nodeidx, 1), COG(nodeidx, 2), COG(nodeidx, 3), 5, 5, 5)


end % function compute_neural_flows_3d_ug()
