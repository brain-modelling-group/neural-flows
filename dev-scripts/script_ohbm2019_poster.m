% 
load('/home/paula/Work/Code/Networks/patchflow/demo-data/metastable_patterns_W_c1_d1ms_trial1.mat')
load('/home/paula/Work/Code/Networks/brain-waves/data/513COG.mat')

locs = COG; % Both hemispheres


%% a) Travelling wave
data = travelling_wave;
interpolated_data_options.exists = false;
tic;compute_neural_flows_3d_ug(data, locs, interpolated_data_options);toc 

%% b) Rotating wave
data = rotating_wave;
interpolated_data_options.exists = false;
tic; compute_neural_flows_3d_ug(data, locs, interpolated_data_options);toc 

%% c) Sinks-sources wave
data = sink_sources_wave;
interpolated_data_options.exists = false;

tic; compute_neural_flows_3d_ug(data, locs, interpolated_data_options);toc 

%% d) Rotating sink wave (eg, spiral sink)
data = rotating_sink_wave;
interpolated_data_options.exists = true;

tic; compute_neural_flows_3d_ug(data, locs, interpolated_data_options);toc 