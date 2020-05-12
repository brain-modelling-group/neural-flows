function test_flow_estimation__travellingwave3d_grid_hs3d()
% Takes 17 seconds @tesseract

% Generate data
 options.hx = 2;
 options.hy = 2;
 options.hz = 2;
 options.ht = 0.5;
 [data, X, Y, Z, ~] = generate_wave3d_travelling_grid('visual_debugging', false, 'hxyz', options.hx, 'ht', options.ht, 'velocity', 1, 'direction', 'y');
 
 % Save data
 full_path_to_file = mfilename('fullpath'); 
 obj_data = matfile([full_path_to_file '.mat'], 'Writable', true);
 obj_data.data = data;
 obj_data.X = X;
 obj_data.Y = Y;
 obj_data.Z = Z;
 
 obj_data.hx = options.hx;
 obj_data.hy = options.hy;
 obj_data.hz = options.hz;
 obj_data.ht = options.ht;
 
%
 input_params_filename = 'test-flow-travellingwave3d-grid-in.json';
 input_params_dir  = '/home/paula/Work/Code/matlab-neuro/neural-flows/tests';
 json_mode = 'read';

% Load options -- TODO: the use of load_data is kind of a hack. The toolbox
% should make a new matfile for the data. Data should be stored in a basic
% matfile.
 input_params = read_write_json(input_params_filename, input_params_dir, json_mode);
 [~, input_params] = load_data(input_params);
 
 output_params = main(input_params); 
 
 [obj_flows] = load_iomat_flows(output_params);

 fig_hist = figure('Name', 'nflows-test-travellingwave3d-grid-hs3d');

 subplot(1, 4, 1, 'Parent', fig_hist)
 histogram(obj_flows.ux(2:end-1, 2:end-1, 2:end-1, :))
 xlabel('ux [m/s]')
 
 subplot(1, 4 ,2, 'Parent', fig_hist)
 histogram(obj_flows.uy(2:end-1, 2:end-1, 2:end-1, :))
 xlabel('uy [m/s]')
 
 subplot(1, 4, 3, 'Parent', fig_hist)
 histogram(obj_flows.uz(2:end-1, 2:end-1, 2:end-1, :))
 xlabel('uz [m/s]')

 subplot(1, 4, 4, 'Parent', fig_hist)
 histogram(sqrt(obj_flows.ux(2:end-1, 2:end-1, 2:end-1, :).^2 + ...
                obj_flows.uy(2:end-1, 2:end-1, 2:end-1, :).^2 + ...
                obj_flows.uz(2:end-1, 2:end-1, 2:end-1, :).^2))
 xlabel('u_{norm} [m/s]')
 
end % function test_flow_estimation__travellingwave3d_grid_hs3d()
