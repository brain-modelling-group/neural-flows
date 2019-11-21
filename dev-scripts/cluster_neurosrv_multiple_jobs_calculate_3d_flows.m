function cluster_neurosrv_multiple_jobs_calculate_3d_flows(slice_idx)
% Script to process chunks of simulated data on neurosrv

    [~, host_name]  = system('hostname');
    host_name = string(host_name(1:end-1));
    
    if strcmp(host_name, 'dracarys')
            load('/home/paula/Work/Code/Networks/neural-flows/demo-data/long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat', 'soln');
    elseif strcmp(host_name, 'neurosrv01')
        load('/home/paulasl/Code/neural-flows/demo-data/long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat', 'soln');
    else % artemis?
        load('/home/psan7097/neural-flows/demo-data/long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat', 'soln');
    end
    % Remove transient
    soln(:, 1:256) = [];


    %in1 = load('/headnode2/paula123/Code/neural-flows/demo-data/W_c1_d1ms_trial1.mat');
    %soln = in1.nodes.'; 
    load('513COG.mat', 'COG')

    % window size
    ws = 128;
    overlap_percentage = 0.0625;
    shift_step = ws - round(overlap_percentage*ws);
    datalen  = size(soln, 2);
    idx = ws:shift_step:datalen;
    if slice_idx < length(idx)+1
        idx_start = idx(slice_idx)-ws+1; 
        idx_stop =  idx(slice_idx);
    else
        idx_start = idx(end);
        idx_stop = datalen;
    end
    data = soln(:, idx_start:idx_stop)';
    locs = COG;

    clear COG soln

    if strcmp(host_name, 'dracarys')

        % Cluster properties
        workers_fraction = 1;
        open_parpool(workers_fraction)
        options.storedir = '/home/paula/Work/Code/Networks/neural-flows/scratch';

    else
    % Set maximum number of threads for nonparallel stuff
        maxNumCompThreads(24);
        local_cluster = parcluster('local');
        local_cluster.NumWorkers = 24;   % This should match the requested number of cpus
        parpool(local_cluster.NumWorkers, 'IdleTimeout', 1800);
        options.storedir = '/home/paulasl/scratch';
    end

    % Change directory to scratch, so temp files will be created there
    cd(options.storedir)
    
    % Data properties
    options.data.ht = 1;
    
    % Slice of data
    options.data.slice.id = slice_idx;
    options.data.slice.start = idx_start;
    options.data.slice.stop  = idx_stop;
    
    % Options for data interpolaton
    options.interpolation.file.exists = false;
    options.interpolation.file.keep = true;
    %options.interpolation.file.name = 'test';
    
    % Resolution
    options.interpolation.hx = 3;
    options.interpolation.hy = 3;
        strcmp(h
    options.interpolation.hz = 3;
    
    options.interpolation.boundary.alpha_radius = 30;
    options.interpolation.boundary.thickness = 3;
    
    % Flow calculation
    options.flows.file.keep = true;
    options.flows.init_conditions.mode = 'random';
    options.flows.init_conditions.seed = 42;
    options.flows.method.name = 'hs3d';
    options.flows.method.alpha_smooth   = 0.1;
    options.flows.method.max_iterations = 64;

    % Singularity detection and classification
    options.singularity.file.keep = true;
    options.singularity.detection.enabled = true;    
    options.singularity.detection.mode  = 'vel';
    options.singularity.detection.threshold = [0 2^-9];
    options.singularity.classification.enabled = true;    


    % Tic
    tstart = tik();

    % Do the stuff 
    main_neural_flows_hs3d_scatter(data, locs, options);
    
    % Toc
    tok(tstart)

end % cluster_neurosrv_multiple_jobs_calculate_3d_flows(()
