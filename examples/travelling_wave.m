% This script runs the whole neurla-flows workflow on a small epoch of
% simulated data, that mostly corresponds to a travelling wave.

% Load data
load('travelling_wave_W_c1_d1ms_trial1.mat')

% Load centroids
load('513COG.mat');
locs = COG;
clear COG

% Options for the flow computation
options.data_interpolation.file_exists = false;
    
% Resolution
options.hx = 3;
options.hy = 3;
options.hz = 3;
options.ht = 1;

% Storage
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
local_cluster = parcluster('local');
local_cluster.NumWorkers = 8;   
parpool(local_cluster.NumWorkers, 'IdleTimeout', 1800);

% Tic
tstart = string(datetime('now'));
fprintf('%s%s\n', ['Started: ' tstart])

% Do the stuff 
main_neural_flows_hs3d_scatter(data, locs, options);
    
% Toc
tend = string(datetime('now'));
fprintf('%s%s\n', ['Finished: ' tend])
tictoc = etime(datevec(tend), datevec(tstart)) / 3600;
fprintf('%s%s%s\n\n', ['Elapsed time: ' string(tictoc) ' hours'])