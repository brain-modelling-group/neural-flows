% This script runs the whole neural-flows workflow on a small epoch of
% simulated data, that mostly corresponds to a pattern in which two sinks are 
% prominent, one on each hemisphere

% Performance: This takes about 5 minutes to run with 11 workers for parallel
% functions. Memory usage is approximately 6GB.

% Load data and centroid locations
load('sink-source_wave_W_c1_d1ms_trial1.mat')

% Options for the data interpolation
options.interpolation.file.exists = false;
options.interpolation.file.keep = true;
    
% Resolution
options.interpolation.hx = 3;
options.interpolation.hy = 3;
options.interpolation.hz = 3;
    
options.interpolation.boundary.alpha_radius = 30;
options.interpolation.boundary.thickness = 2;
options.data.ht = 0.25;
options.data.slice.id = 0;

% Storage options
options.storedir = '/home/paula/Work/Code/Networks/neural-flows/scratch';
cd(options.storedir)

% Flow calculation
options.flows.file.keep = true;
options.flows.init_conditions.mode = 'random';
options.flows.init_conditions.seed = 42;
options.flows.method.name = 'hs3d';
options.flows.method.alpha_smooth   = 0.1;
options.flows.method.max_iterations = 128;

% Singularity detection and classification
options.singularity.file.keep = true;
options.singularity.detection.enabled = true;    
options.singularity.detection.mode  = 'vel';
options.singularity.detection.threshold = [0 2^-6];
options.singularity.classification.enabled = true;    

    
% Define Parallel Cluster properties for parallel processing
workers_fraction = 0.8;
open_parpool(workers_fraction)

% Tic
tstart = tik();

% Do the stuff 
[minterp_obj, mflows_obj, msings_obj] = main_neural_flows_hs3d_scatter(data, locs, options);
     
% Toc
tok(tstart)

% SVD decompostion
data_type = 'scattered';
perform_mode_decomposition_svd(mflows_obj, data_type);

analyse_singularities(msings_obj)

plot1d_speed_distribution(mflows_obj)

