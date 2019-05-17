
load('/home/paula/Work/Code/Networks/brain-waves/data/simulations/long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat', 'soln')
load('/home/paula/Work/Code/Networks/brain-waves/data/513COG.mat')

data  = soln(:, end-25000:end)';
locs = COG;

clear COG

interpolated_data_options.exists = false;
tic;compute_neural_flows_3d_ug(data, locs, interpolated_data_options);toc 