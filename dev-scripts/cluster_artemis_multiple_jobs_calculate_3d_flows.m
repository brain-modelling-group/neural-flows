function cluster_artemis_multiple_jobs_calculate_3d_flows(idx_chunk)
% Script to process data on Artemis

load('long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat', 'soln')
load('513COG.mat', 'COG')

idx = 2048:2048:400001;

if idx_chunk < 195
    idx_start = idx(idx_chunk);
    idx_stop  = idx(idx_chunk+1);
else
    idx_start = idx(idx_chunk);
    idx_stop = 400001;
end
data = soln(:, idx_start:idx_stop)';
locs = COG;

clear COG soln

% Cluster properties
local_cluster = parcluster('local');
local_cluster.NumWorkers = 24; % This should match the requested number of cpus
parpool(local_cluster.NumWorkers);

% Change directory to scratch, so temp files will be created there
cd /scratch/CGMD

% Options for the flow computation
options.interp_data.file_exists = false;
options.sing_detection.datamode = 'vel';
options.sing_detection.indexmode = 'linear';
options.chunk = idx_chunk;
tic;compute_neural_flows_3d_ug(data, locs, options);toc 

end % 
