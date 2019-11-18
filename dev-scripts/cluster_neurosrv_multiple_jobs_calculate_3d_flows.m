function cluster_neurosrv_multiple_jobs_calculate_3d_flows(idx_chunk)
% Script to process chunks of simulated data on neurosrv

    %load('/home/paulasl/Code/neural-flows/demo-data/long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat', 'soln');
    load('/home/paula/Work/Code/Networks/neural-flows/demo-data/long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat', 'soln');
    % Remove transient
    soln(:, 1:256) = [];


    %in1 = load('/headnode2/paula123/Code/neural-flows/demo-data/W_c1_d1ms_trial1.mat');
    %soln = in1.nodes.'; 
    load('513COG.mat', 'COG')

    % window size
    ws = 128;
    overlap_percentage = 0.0625;

    %ws=32;
    shift_step = ws - round(overlap_percentage*ws);
    datalen  = size(soln, 2);
    idx = ws:shift_step:datalen;
    if idx_chunk < length(idx)+1
        idx_start = idx(idx_chunk)-ws+1; 
        idx_stop =  idx(idx_chunk);
    else
        idx_start = idx(end);
        idx_stop = datalen;
    end
    data = soln(:, idx_start:idx_stop)';
    locs = COG;

    clear COG soln

    % Cluster properties
    workers_fraction = 0.8;
    open_parpool(workers_fraction)

    %local_cluster = parcluster('local');
    %local_cluster.NumWorkers = 24;   % This should match the requested number of cpus
    %parpool(local_cluster.NumWorkers, 'IdleTimeout', 1800);

    % Change directory to scratch, so temp files will be created there
    % Storage options 
    options.storedir = '/home/paula/Work/Code/Networks/neural-flows/scratch';
    %options.storedir = '/home/paulasl/scratch';
    cd(options.storedir)

    
    % Data properties
    options.data.ht = 1;

    % Options for the flow computation
    options.interpolation.file_exists = false;
    
    % Resolution
    options.interpolation.hx = 4;
    options.interpolation.hy = 4;
    options.interpolation.hz = 4;
    
    % Slice of data
    options.chunk = idx_chunk;
    options.chunk_start = idx_start;
    options.chunk_stop  = idx_stop;
    
    % Flow calculation
    options.flows.init_conditions.mode = 'random';
    options.flows.init_conditions.seed = 42;
    options.flows.method.name = 'hs3d';
    options.flows.method.alpha_smooth   = 0.1;
    options.flows.method.max_iterations = 64;

    % Singularity detection and classification
    options.singularity.detection.enabled = true;    
    options.singularity.detection.mode  = 'vel';
    options.singularity.detection.threshold = [0 2^-9];


    % Tic
    tstart = tik();

    % Do the stuff 
    main_neural_flows_hs3d_scatter(data, locs, options);
    
    % Toc
    tok(tstart)

end % cluster_neurosrv_multiple_jobs_calculate_3d_flows(()

