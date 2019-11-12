% This script runs the whole neural-flows workflow on a small epoch of
% simulated data, that mostly corresponds to a travelling wave.

% Load data and centroid locations
load('travelling_wave_W_c1_d1ms_trial1.mat')

% Options for the data interpolation
options.data_interpolation.file_exists = false;
    
% Resolution
options.hx = 3;
options.hy = 3;
options.hz = 3;
options.ht = 1;

% Storage options
options.tempdir = '/home/paula/Work/Code/Networks/neural-flows/scratch';
cd(options.tempdir)
    
% Flow calculation
options.flow_calculation.init_conditions = 'random';
options.flow_calculation.seed_init_vel = 42;
options.flow_calculation.alpha_smooth   = 0.1;
options.flow_calculation.max_iterations = 64;

% Singularity detection and classification
options.sing_analysis.detection = true;    
options.sing_analysis.detection_datamode  = 'vel';
options.sing_analysis.detection_threshold = [0 2^-9];

    
% Define Parallel Cluster properties for parallel processing
workers_fraction = 0.8;
open_parpool(workers_fraction)

% Tic
tstart = tik();

% Do the stuff 
[minterp_obj, mflows_obj, msings_obj] = main_neural_flows_hs3d_scatter(data, locs, options);
     
% Toc
tok(tstart)
% Analyse singularities -- in this case all the plots will be empty because
% there are no singularities in a travelling wave.
analyse_singularities(msings_obj)

% SVD decompostion
data_type = 'scattered';
perform_mode_decomposition_svd(mflows_obj, data_type);

