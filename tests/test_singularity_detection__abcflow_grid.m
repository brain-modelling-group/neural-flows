function test_singularity3d_detection__abcflow()
% This evaluates the singularity detection functions, and the effect of the 
% threshold currently used.
%
% ARGUMENTS:
%          mstruct_vel -- a structure with an unsteady abc flow, 
%                         generatedvia generate_flow3d_abc_unsteady_grid()
% OUTPUT: 
%          None
%
% REQUIRES: 
%          flows3d_grid_detect_nullflows_velocities()
%          singularity3d_classify_singularities()
%          s3d_produce_visual_summary()
%          
% USAGE:
%{     

%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon -- QIMR October 2019
% REFERENCES:
% Didov, Ulysky (2018) Analysis of stationary points and their bifurcations in the ABC flow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

input_params_filename = 'test-singularity-planewave3d-grid-in.json';
input_params_dir  = get_directory_path(mfilename('fullpath'), 'json');
input_params = read_write_json(input_params_filename, input_params_dir, 'read');

% Generate flow data - [ux, uy, uz] = generate_flows3d_abc_unsteady(abc, varargin)
% Save flow data with all the trimmings
% Output_params = main(input_params)


end %function test_singularity_detection__abcflow_grid()
