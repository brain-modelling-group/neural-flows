function generate_data3d(data_type)
% Wrapper function to generate all test data before running "test" functions
% TODO: generalise so we can change parameters to generate waves eventually
% At the moment many parameters are hardcoded as we know which waves we want for tests
% Assumes this function is run from directory tests/
% This functions produces MatFiles and default matfiles with the data. 
% 

if nargin < 1
    data_type = 'all';
end

switch data_type 
    case {'plane', 'planar'}
        plane_wave_s()
        plane_wave_u()
    case {'travelling'}
        travelling_wave_s()
        travelling_wave_u()
    case {'rotating', 'spiral'}
        spiral_wave_s()
        spiral_wave_u()
    case {'biharmonic', 'biwave', 'travelling-biharmonic'}
        travelling_biharmonic_wave_s()
        travelling_biharmonic_wave_u()
    case {'all'}
        plane_wave_s()
        plane_wave_u()
        travelling_wave_s()
        travelling_wave_u()
        travelling_biharmonic_wave_s()
        travelling_biharmonic_wave_u()
        spiral_wave_s()
        spiral_wave_u()
    otherwise
       error(['neural-flows:' mfilename ':UnknownCase'], ...
              'Requested unknown method. Options: {"plane", "travelling", "rotating", "biharmonic"}');

end 
end % generate_data3d()

function plane_wave_s()
fprintf('%s \n', strcat('neural-flows:: ', mfilename, ...
        '::Info:: Generating plane wave (structured).'))
    % Save data
    options.visual_debugging = false;
    options.hxyz = 1;
    options.hx = 1;
    options.hy = 1;
    options.hz = 1;
    options.ht = 1;
    options.direction = 'radial';
    options.grid_type = 'structured';

    % Generate data
    [data, X, Y, Z, ~] = generate_data3d_plane_wave('visual_debugging', options.visual_debugging, ...
                                                     'hxyz', options.hxyz, ...
                                                     'ht', options.ht, ...
                                                     'direction', options.direction, ...
                                                     'grid_type', options.grid_type);
    obj_data = matfile('data/data-plane-wave-structured-iomat.mat', 'Writable', true);
    obj_data.data = data;
    obj_data.X = X;
    obj_data.Y = Y;
    obj_data.Z = Z;
     
    obj_data.hx = options.hx;
    obj_data.hy = options.hy;
    obj_data.hz = options.hz;
    obj_data.ht = options.ht;

end % function plane_wave_s()


function plane_wave_u()
fprintf('%s \n', strcat('neural-flows:: ', mfilename, ...
        '::Info:: Generating plane wave (unstructured).'))
    % Generate data
    options.hxyz = 2;
    options.ht = 1;
    options.visual_debugging = false;
    hemi1_idx = 1:257;
    load('513COG_lr.mat', 'locs')
    locs = locs(hemi1_idx, :);
     
    [data, ~] = generate_data3d_plane_wave('hxyz', options.hxyz, 'ht', options.ht, ...
                                            'visual_debugging', options.visual_debugging, ...
                                            'direction', 'x', ...
                                            'locs', locs, ...
                                            'grid_type', 'unstructured');
                                                   
    % save MatFile
    obj_data = matfile('data/data-plane-wave-unstructured-iomat.mat', 'Writable', true);
    % save in regular matfile
    save('data/data-plane-wave-unstructured.mat', 'data', 'locs');

    obj_data.data = data;
    obj_data.locs = locs;
    alpha_radius = 30;
    get_convex_hull(obj_data, alpha_radius, hemi1_idx, [])
 
end % function plane_wave_u()


function spiral_wave_s()
fprintf('%s \n', strcat('neural-flows:: ', mfilename, ...
        '::Info:: Generating spiral wave (structured).'))
% Generate data
 options.hx = 1;
 options.hy = 1;
 options.hz = 1;
 options.ht = 1;
 options.visual_debugging = false;
 [data, X, Y, Z, ~] = generate_data3d_spiral_wave('visual_debugging', options.visual_debugging, ...
                                                   'hxyz', options.hx, 'ht', options.ht, ...
                                                   'velocity', [0 0], 'filament', 'helix', ...
                                                   'grid_type', 'structured');

  obj_data = matfile('data/data-spiral-wave-structured-iomat.mat', 'Writable', true);
  obj_data.data = data;
  obj_data.X = X;
  obj_data.Y = Y;
  obj_data.Z = Z;
     
  obj_data.hx = options.hx;
  obj_data.hy = options.hy;
  obj_data.hz = options.hz;
  obj_data.ht = options.ht;

end % function spiral_wave_s()


function spiral_wave_u()
fprintf('%s \n', strcat('neural-flows:: ', mfilename, ...
        '::Info:: Generating spiral wave (unstructured).'))    
    % Generate data
    options.hxyz = 2;
    options.ht = 1;
    options.visual_debugging = false; 
    load('513COG_lr.mat', 'locs')
    [data, ~] = generate_data3d_spiral_wave('visual_debugging', options.visual_debugging, ...
                                             'locs', locs, ...
                                             'hxyz', options.hxyz, ...
                                             'ht', options.ht, ...
                                             'grid_type', 'unstructured');

    % save MatFile
    obj_data = matfile('data/data-spiral-wave-unstructured-iomat.mat', 'Writable', true);
    % save in regular matfile
    save('data/data-spiral-wave-unstructured.mat', 'data', 'locs');

    obj_data.data = data;
    obj_data.locs = locs;
    alpha_radius = 30;
    hemi1_idx = 1:257;
    hemi2_idx = 258:513;
    get_convex_hull(obj_data, alpha_radius, hemi1_idx, hemi2_idx)

end % function spiral_wave_u()


function travelling_wave_s()
fprintf('%s \n', strcat('neural-flows:: ', mfilename, ...
        '::Info:: Generating travelling wave (structured).'))
    % Generate data
    options.hx = 2;
    options.hy = 2;
    options.hz = 2;
    options.ht = 0.5;
    options.visual_debugging = false;
    [data, X, Y, Z, ~] = generate_data3d_travelling_wave('visual_debugging', options.visual_debugging, ...
                                                         'hxyz', options.hx, ...
                                                         'ht', options.ht, ...
                                                         'velocity', 1, ...
                                                         'direction', 'y', ...
                                                         'grid_type', 'structured');
    % Reflect wave
    data = [data(:, :, :, end:-1:1); data];
 
    obj_data = matfile('data/data-travelling-wave-structured-iomat.mat', 'Writable', true);
    obj_data.data = data;
    obj_data.X = X;
    obj_data.Y = Y;
    obj_data.Z = Z;
     
    obj_data.hx = options.hx;
    obj_data.hy = options.hy;
    obj_data.hz = options.hz;
    obj_data.ht = options.ht;
end % function function travelling_wave_s()


function travelling_wave_u()
fprintf('%s \n', strcat('neural-flows:: ', mfilename, ...
        '::Info:: Generating travelling wave (unstructured).'))
    options.hx = 2;
    options.hy = 2;
    options.hz = 2;
    options.ht = 0.5;
    options.visual_debugging = false;
     
    % Load centres of gravity
    load('513COG_lr.mat', 'locs')
     
    % Generate fake data
    [data, ~] = generate_data3d_travelling_wave('visual_debugging', options.visual_debugging, ...
                                                'locs', locs, 'hxyz',  options.hx, ...
                                                 'ht', options.ht, 'direction', 'y', ...
                                                 'velocity', 1, ...
                                                 'grid_type', 'unstructured');
    % Reflect wave
    data = [data(end:-1:1, :); data];

    % save MatFile 
    obj_data = matfile('data/data-travelling-wave-unstructured-iomat.mat', 'Writable', true);
    % save in regular matfile
    save('data/data-travelling-wave-unstructured.mat', 'data', 'locs');

    obj_data.data = data;
    obj_data.locs = locs;
    alpha_radius = 30;
    hemi1_idx = 1:257;
    hemi2_idx = 258:513;
    get_convex_hull(obj_data, alpha_radius, hemi1_idx, hemi2_idx)
end % function travelling_wave_u()


function travelling_biharmonic_wave_s()
fprintf('%s \n', strcat('neural-flows:: ', mfilename, ...
        '::Info:: Generating travelling biharmonic wave (structured).'))
    options.hx = 0.004;
    options.hy = 0.004;
    options.hz = 0.004;
    options.grid.lim_type = 'none'; % do not use ceil to calculate the grid.
    options.ht = 0.025;
    options.visual_debugging = false;
 
    [data, X, Y, Z, ~] = generate_data3d_travelling_biharmonic_wave('visual_debugging', options.visual_debugging, ...
                                                            'hxyz', options.hx, ...
                                                            'ht',   options.ht, ...
                                                            'lim_type', options.grid.lim_type, ...
                                                            'grid_type', 'structured');
    obj_data = matfile('data/data-biharmonic-wave-structured-iomat.mat', 'Writable', true);
    obj_data.data = data;
    obj_data.X = X;
    obj_data.Y = Y;
    obj_data.Z = Z;
     
    obj_data.hx = options.hx;
    obj_data.hy = options.hy;
    obj_data.hz = options.hz;
    obj_data.ht = options.ht;
end % function travelling_biharmonic_wave_s()


function travelling_biharmonic_wave_u()
fprintf('%s \n', strcat('neural-flows:: ', mfilename, ...
        '::Info:: Generating travelling biharmonic wave (unstructured).'))
    options.hx = 0.004;
    options.hy = 0.004;
    options.hz = 0.004;
    options.grid.lim_type = 'none'; % do not use ceil to calculate the grid.
    options.ht = 0.025;
    options.visual_debugging = false;
    % With these parameters the wave is moving at 4 m/s along the y-axis 
    load('513COG_lr.mat')
    locs = locs/1000;
     
    [data, ~] = generate_data3d_travelling_biharmonic_wave('visual_debugging', options.visual_debugging, ..., 
                                                           'locs', locs, 'hxyz', options.hx, ...
                                                            'ht',   options.ht, ...
                                                            'lim_type', options.grid.lim_type, ...
                                                            'grid_type', 'unstructured');

    % save MatFile
    obj_data = matfile('data/data-biharmonic-wave-unstructured-iomat.mat', 'Writable', true);
    % save in regular matfile
    save('data/data-biharmonic-wave-unstructured.mat', 'data', 'locs');

    obj_data.data = data;
    obj_data.locs = locs;
    alpha_radius = 30;
    hemi1_idx = 1:257;
    hemi2_idx = 258:513;
    get_convex_hull(obj_data, alpha_radius, hemi1_idx, hemi2_idx)
 
end %function travelling_biharmonic_wave_u()
