% Load data
wave_data = struct2cell(load('/home/paula/Work/Code/Networks/patchflow/demo-data/metastable_patterns_W_c1_d1ms_trial1.mat'));

% Load region mapping and project BNM data-> Surface data
load('/home/paula/Work/Code/Networks/patchflow/demo-data/RegionMapping_513parc_to_Cortex_reg13.mat')
load('/home/paula/Work/Code/Networks/patchflow/demo-data/Cortex_reg13_to_513parc.mat')

% Load nearest neighbour connectivity to smooth data
load('/home/paula/Work/Code/Networks/patchflow/demo-data/Cortex_reg13_LocalCoupling_NN_2ring.mat')

% Create time vector -- not really needed at the moment
time_data = 1:1:size(wave_data{1}, 1);

% wave data:
%           1 - 
%           2 - 
%           3 - 
%           4 - 
%% Put surface data into a struct
cortex.faces = Triangles;
cortex.vertices = Vertices;
cortex.vertex_normals = VertexNormals;
cortex.VertexNormals  = VertexNormals;

%% Smooth signal 
cortex_signal   = cell(size(wave_data));
weighted_signal = cell(size(wave_data));

for this_dataset=1:length(wave_data)
    cortex_signal{this_dataset} = wave_data{this_dataset}(:, RegionMapping_voronoi);
    weighted_signal{this_dataset} = (cortex_signal{this_dataset}*LocalCoupling)*LocalCoupling;
end

smooth_wave_data = weighted_signal;
save('neural_flows_surf_wave_data', 'smooth_wave_data')