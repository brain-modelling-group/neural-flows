function test_flows3d_estimation__plane_wave_sah()
% This function generates a 3D plane wave  moving in a particular direction
% The wave is defined in a structured grid. 

 % Generate data
 [data, X, Y, Z, ~] = generate_data3d_plane_wave('visual_debugging', false, ...
                                                 'hxyz', 1, 'ht', 1, ...
                                                 'direction', 'radial', ...
                                                 'grid_type', 'structured');
 % Save data
 hx = 1;
 hy = 1;
 hz = 1;
 ht = 1;
 full_path_to_file = mfilename('fullpath'); 
 obj_data = matfile(full_path_to_file, 'Writable', true);
 obj_data.data = data;
 obj_data.X = X;
 obj_data.Y = Y;
 obj_data.Z = Z;
 
 obj_data.hx = hx;
 obj_data.hy = hy;
 obj_data.hz = hz;
 obj_data.ht = ht;
 
%
input_params_filename = 'test-flows3d-estimation_plane-wave_sah_in.json';
input_params_dir  = '/home/paula/Work/Code/matlab-neuro/neural-flows/tests';
json_mode = 'read';

% Load options -- TODO: the use of load_data is kind of a hack. The toolbox
% should make a new matfile for the data. Data should be stored in a basic
% matfile.
input_params = read_write_json(input_params_filename, input_params_dir, json_mode);
[~, input_params] = load_data(input_params);
%%
output_params = main(input_params); 

[obj_flows] = load_iomat_flows(output_params);

% Plot stuff
fig_hist = figure('Name', 'nflows-test-planewave3d-grid-hs3d');

subplot(1, 4, 1, 'Parent', fig_hist)
histogram(obj_flows.ux(2:end-1, 2:end-1, 2:end-1, :))
xlabel('ux [m/s]')
 
subplot(1, 4, 2, 'Parent', fig_hist)
histogram(obj_flows.uy(2:end-1, 2:end-1, 2:end-1, :))
xlabel('uy [m/s]')
 
subplot(1, 4, 3, 'Parent', fig_hist)
histogram(obj_flows.uz(2:end-1, 2:end-1, 2:end-1, :))
xlabel('uz [m/s]')
 
subplot(1, 4, 4, 'Parent', fig_hist)
histogram(obj_flows.un(2:end-1, 2:end-1, 2:end-1, :))
xlabel('u_{norm} [m/s]')
 
end % function test_flow_estimation__planewave3d_grid_hs3d()
