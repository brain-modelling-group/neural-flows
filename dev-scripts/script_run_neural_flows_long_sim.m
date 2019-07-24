
load('/home/paula/Work/Code/Networks/brain-waves/data/simulations/long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat', 'soln')
load('/home/paula/Work/Code/Networks/brain-waves/data/513COG.mat')

data  = soln(:, end-25000:end)';
locs = COG;

clear COG

options.interp_data.exist_file = false;
options.sing_detection.datamode = 'vel';
options.sing_detection.inexmode = 'linear';

tic;compute_neural_flows_3d_ug(data, locs, options);toc 