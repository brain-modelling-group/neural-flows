
inparams_filename = 'rotating_wave_in.json';
ouparams_filename = 'rotating_wave_ou.json'
inparams_dir  = '/home/paula/Work/Code/matlab-neuro/neural-flows/examples';
inparams_mode = 'write';

% Output storage inparams
inparams.general.storage.time_stamp = [];
inparams.general.storage.dir = '/home/paula/Work/Code/matlab-neuro/neural-flows/scratch'; % Final location for output
inparams.general.storage.dir_tmp = '/tmp'; % temporary directory for intermediate results parallel calculations
inparams.general.storage.params.input.filename = inparams_filename;
inparams.general.storage.params.input.dir = inparams_dir;
inparams.general.storage.params.output.filename = ouparams_filename;        
inparams.general.storage.params.output.dir = inparams_dir; 


% Internal inparams, datatypes to use, use parallel computing toolbox. 
inparams.general.storage.format = 'iomat'; %{'iomat', 'mat'}
inparams.general.parallel.enabled = true; 
inparams.general.parallel.workers_fraction = 0.8;

% Properties of input data, data file should come with data and locations
inparams.data.dir.name = '/home/paula/Work/Code/matlab-neuro/neural-flows/demo-data';
inparams.data.file.name = 'rotating_wave_W_c1_d1ms_trial1.mat';
inparams.data.slice.enabled = false; 
inparams.data.slice.id = 0;
inparams.data.grid.type = 'unstructured';
inparams.data.ht = 0.25;
inparams.data.hx = [];
inparams.data.hy = [];
inparams.data.hz = [];
%params.data.shape.x = params.data.shape.size(2); 
%params.data.shape.y = params.data.shape.size(3);
%params.data.shape.z = params.data.shape.size(4);
inparams.data.units.space = 'mm';
inparams.data.units.time  = 'ms';
inparams.data.mode = 'amplitude';
inparams.data.phase.enabled = true; % calculate phase


% inparams for the data interpolation
inparams.interpolation.enabled = true;
inparams.interpolation.file.exists = false;
inparams.interpolation.dir.name = '';
inparams.interpolation.file.name = '';
inparams.interpolation.file.label = '';
inparams.interpolation.file.keep = true;
    
% Resolution
inparams.interpolation.hx = 3;
inparams.interpolation.hy = 3;
inparams.interpolation.hz = 3;
%inparams.interpolation.ht = 4; % Integer multiple of inparams.data.ht

% Convex hull boundary for unstructured 3d grids    
inparams.interpolation.boundary.alpha_radius = 30; % au
inparams.interpolation.boundary.thickness = 2; % voxels
inparams.interpolation.visualisation.enabled = true;

% Flow calculation
inparams.flows.file.keep = true;
inparams.flows.file.dir = [];
inparams.flows.file.name = [];

% Estimation of flows
inparams.flows.method.data.mode = 'amplitude'; %{'phase', 'amplitude'}

% Horn-Schunk
inparams.flows.method.name = 'hs3d';
inparams.flows.method.hs3d.alpha_smooth   = 0.1;
inparams.flows.method.hs3d.max_iterations = 128;
inparams.flows.method.hs3d.initial_conditions.mode = 'random';
inparams.flows.method.hs3d.initial_conditions.seed = 42;

% CNEM
inparams.flows.method.name = 'cnem';
inparams.flows.method.cnem.alpha_radius = 30;

inparams.flows.visualisation.enabled = true;

% Flow analysis
inparams.flows.decomposition.svd.enabled = true;
inparams.flows.decomposition.svd.modes = 4;
inparams.flows.decomposition.svd.grid.type = 'unstructured'; 

% Streamline analysis 
inparams.flows.streamlines.enabled = true
inparams.flows.streamlines.grid.type = 'unstructured';


% Singularity detection and classification
inparams.singularity.file.keep = true;
inparams.singularity.file.dir = [];  % or false
inparams.singularity.file.name = []; % or false
inparams.singularity.detection.enabled = true;    
inparams.singularity.detection.mode  = 'vel';
inparams.singularity.detection.threshold = [0 2^-6];

inparams.singularity.classification.enabled = true;
inparams.singularity.quantification.enabled = true;    
inparams.singularity.visualisation.enabled = true;

%%
read_write_json(inparams_filename, inparams_dir, inparams_mode, inparams);



