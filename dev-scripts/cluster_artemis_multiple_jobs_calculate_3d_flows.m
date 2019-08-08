function cluster_artemis_multiple_jobs_calculate_3d_flows(idx_chunk)
% Script to process data on Artemis

    load('long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat', 'soln')
    load('513COG.mat', 'COG')

    % window size
    ws = 10;
    % shift step
    shift_step = ws - 5;
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
    local_cluster = parcluster('local');
    %local_cluster.NumWorkers = 24;   % This should match the requested number of cpus
    %local_cluster.IdleTimeout = 900; % Set idel timeout to 15h
    parpool(local_cluster.NumWorkers);

    % Change directory to scratch, so temp files will be created there
    %cd /scratch/CGMD

    % Options for the flow computation
    options.interp_data.file_exists = false;
    options.sing_detection.datamode = 'vel';
    options.sing_detection.indexmode = 'linear';
    options.chunk = idx_chunk;
    options.chunk_start = idx_start;
    options.chunk_stop  = idx_stop;

    % Tic
    tstart = string(datetime('now'));
    fprintf('%s%s\n', ['Started: ' tstart])

    % Do the stuff
    [mfile_vel, mfile_interp, mfile_sings] = compute_neural_flows_3d_ug(data, locs, options);

    % Toc
    tend = string(datetime('now'));
    fprintf('%s%s\n', ['Finished: ' tend])
    tictoc = etime(datevec(tend), datevec(tstart)) / 3600;
    fprintf('%s%s%s\n', ['Elapsed time: ' string(tictoc) ' hours'])

    % Perform downsampling
    tstart = string(datetime('now'));
    fprintf('%s%s\n', ['Started downsampling: ' tstart])
    
    downsample_stored_data(idx_chunk, mfile_vel, mfile_interp, mfile_sings)
    
    tend = string(datetime('now'));
    fprintf('%s%s\n', ['Finished downsampling: ' tend])
    tictoc = etime(datevec(tend), datevec(tstart)) / 3600;
    fprintf('%s%s%s\n', ['Elapsed downsampling time: ' string(tictoc) ' hours'])

end % 
