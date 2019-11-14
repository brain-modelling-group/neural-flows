% This script runs the whole neural-flows workflow on a small epoch of
% simulated data, that looks like a rotating wave with a critical point.

% Load data and centroid locations
load('rotating-cp_wave_W_c1_d1ms_trial1.mat')
%load('sink-source_wave_W_c1_d1ms_trial1.mat')

%env = envelope(data, 2, 'peak');
%data = env;

% Options for the data interpolation
options.data_interpolation.file_exists = false;
    
% Desired spatial resolution
options.hx = 3;
options.hy = 3;
options.hz = 3;

% Data temporal sampling period
options.ht = 0.25;

% Storage options
options.storedir = '/home/paula/Work/Code/Networks/neural-flows/scratch';
cd(options.storedir)
    
% Flow calculation
options.flow_calculation.init_conditions = 'random';
options.flow_calculation.seed_init_vel = 42;
options.flow_calculation.alpha_smooth   = 0.1;
options.flow_calculation.max_iterations = 64;

% Singularity detection and classification
options.sing_analysis.detection = true;    
options.sing_analysis.detection_datamode  = 'vel';
options.sing_analysis.detection_threshold = [0 2^-5];

    
% Define Parallel Cluster properties for parallel processing
workers_fraction = 0.8;
open_parpool(workers_fraction)

% Tic
tstart = tik();

% Do the stuff 
[minterp_obj, mflows_obj, msings_obj] = main_neural_flows_hs3d_scatter(data, locs, options);
     
% Toc
tok(tstart)

% Analyse singularities 
analyse_singularities(msings_obj)

% SVD decompostion
grid_type = 'scattered';
perform_mode_decomposition_svd(mflows_obj, grid_type);

