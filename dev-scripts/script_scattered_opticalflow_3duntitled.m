
function compute_neural_flows_3d_unstructured(data)
    % data: a 2D array of size T x Nodes
    % cogs: centres of gravity: node locations assumed to be a brain network embedded in 3D dimensional space
    % we need:
    % dt
    % limits of space, presumably coming from fmri data
    % flag to process one hemisphere or the whole brain. Default bh, lh, rh
    % TODO: estimate timeppints of interest using the second order temporal
    % derivative
    % NOTEs on perfromance: Elapsed time is 2602.606860 seconds for half
    % hemisphere, 32 iterations max per pair of frames

    % Labels for dimensions of 4D arrays arrays
    x_dim = 1;
    y_dim = 2;
    z_dim = 3;
    t_dim = 4;
    
    tpts      = size(data, 1);
    num_nodes = size(data, 2);
    
    down_factor_t = 50; % Downsampling factor for t-axis
    data_hm = data(1:down_factor_t:tpts, :);
    tpts    = size(data_hm, 1);

    clear data
    
    % NOTE: full resolution (eg, approx dxyz=1mm^3), each interpolation
    % step takes about 24 seconds.
    % downsampling to 8mm^3 - side 2mm it takes 3s.
    
    down_factor_xyz = 2; % Not allowed to get different downsampling for space


    lh_idx = [1:256, 513];
    rh_idx = [257:512];

    this_hm = lh_idx;
    int_COG = floor(COG);
    
    % Get limits for the structured grid if people did not give those
    min_x = min(int_COG(this_hm, x_dim));
    min_y = min(int_COG(this_hm, y_dim));
    min_z = min(int_COG(this_hm, z_dim));

    max_x = max(int_COG(this_hm, x_dim));
    max_y = max(int_COG(this_hm, y_dim));
    max_z = max(int_COG(this_hm, z_dim));
    
    % Create the grid
    [X, Y, Z] = meshgrid(min_x:down_factor_xyz:max_x, ...
                         min_y:down_factor_xyz:max_y, ...
                         min_z:down_factor_xyz:max_z);
   


    % This is the key step for the optical flow method to work
    neighbour_method = 'natural';
    extrapolation_method = 'none';
    
    
    % Trial run to get 
    
    shp_alpha_radius = 30; % alpha radius. May be adjustable
    shp = alphaShape(COG(this_hm, :), shp_alpha_radius);

    % The boundary of the centroids is an approximation of the cortex
    bdy = shp.boundaryFacets;
    
    %% Detect which points are in the alpha shape.
    inside_boundary_idx = inShape(shp, X(:), Y(:), Z(:));

    
    % Default parameters -- could be changed
    alpha_smooth   = 1;
    max_iterations = 8;
    
    % Determine some initial conditions based
    NAN_MASK = ~inside_boundary_idx;
    
    % Get some dummy initial conditions
    [uxo, uyo, uzo] = get_initial_velocity_distribution(X, NAN_MASK, 42);
    
    % We open a matfile to store output and avoid huge memory usage 
    mfile_object = matfile('test_file.mat','Writable', true);
    mfile_object.ux(size(uxo, x_dim), size(uxo, y_dim), size(uxo, z_dim), tpts-1) = 0;    
    mfile_object.uy(size(uyo, x_dim), size(uyo, y_dim), size(uyo, z_dim), tpts-1) = 0;
    mfile_object.uz(size(uzo, x_dim), size(uzo, y_dim), size(uzo, z_dim), tpts-1) = 0;
   %% 
   tic;
    for this_tpt = 1:tpts-1
        % Frame A
        data_interpolant_a = scatteredInterpolant(COG(this_hm, x_dim), ...
                                            COG(this_hm, y_dim), ...
                                            COG(this_hm, z_dim), ...
                                            data_hm(this_tpt, this_hm).', ...
                                            neighbour_method, ...
                                            extrapolation_method);
        % Frame B
        data_interpolant_b = scatteredInterpolant(COG(this_hm, x_dim), ...
                                            COG(this_hm, y_dim), ...
                                            COG(this_hm, z_dim), ...
                                            data_hm(this_tpt+1, this_hm).', ...
                                            neighbour_method, ...
                                            extrapolation_method);


        FA = data_interpolant_a(X, Y, Z);
       
        FB = data_interpolant_b(X, Y, Z);


       % Calculate the velocity components
       [uxo, uyo, uzo] = compute_flow_hs3d(FA, FB, alpha_smooth, max_iterations, ...
                                           uxo, uyo, uzo);                                
              
       % Save the velocity components
       % TODO: do it every 5-10 samples
       mfile_object.ux(:, :, :, this_tpt) = uxo;
       mfile_object.uy(:, :, :, this_tpt) = uyo;
       mfile_object.uz(:, :, :, this_tpt) = uzo;
       
    end
    % Free some space
    clear uxo uyo uzo
    toc;
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
% 
% isosurface(xx,yy,zz,round(1000*v2in),-140);isonormals(xx,yy,zz,v2in,p)
% daspect([1 1 1])
% trisurf(bdy, COG(this_hm, 1), COG(this_hm, 2), COG(this_hm, 3))
% 
% nodeidx = 20;
% ellipsoid(COG(nodeidx, 1), COG(nodeidx, 2), COG(nodeidx, 3), 5, 5, 5)
end % function compute_neural_flows_3d_unstructured()
