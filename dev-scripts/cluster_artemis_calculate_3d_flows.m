function cluster_artemis_calculate_3d_flows()
% Script to process data on Artemis

load('long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat', 'soln')
load('513COG.mat', 'COG')

idx_start = 1;
idx_stop  = 10;
data  = soln(:, idx_start:idx_stop)';
locs = COG;

clear COG soln

% Cluster properties
local_cluster = parcluster('local');
local_cluster.NumWorkers = 64; % This should match the requested number of cpus
parpool(local_cluster.NumWorkers);

% Change directory to scratch, so temp files will be created there
cd /scratch/CGMD

% Options for the flow computation
options.interp_data.file_exists = false;
options.sing_detection.datamode = 'vel';
options.sing_detection.indexmode = 'linear';

tic;compute_neural_flows_3d_ug(data, locs, options);toc 

end % 
