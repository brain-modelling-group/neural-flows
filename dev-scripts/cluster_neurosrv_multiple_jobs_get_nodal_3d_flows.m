function cluster_neurosrv_multiple_jobs_get_nodal_3d_flows(idx_chunk)
% Script to obtain nodal flows on neurosrv
 


   this_file = get_flowfile_name(idx_chunk);


    load('513COG.mat', 'COG')

    locs = COG;

    clear COG

    % Cluster properties
    local_cluster = parcluster('local');
    local_cluster.NumWorkers = 8;   % This should match the requested number of cpus
    parpool(local_cluster.NumWorkers, 'IdleTimeout', 1800);

    % Change directory to where we have stored the data    
    %cd /home/paulasl/ldrive/Lab_JamesR/paulaSL/Projects/brainwaves-simulated
    cd /home/paula/TempData
     
    mfile_vel = matfile(this_file, 'Writable', true);
   
    % Tic
    tstart = string(datetime('now'));
    fprintf('%s%s\n', ['Started: ' tstart])

    % Do the stuff 
    flows3d_get_scattered_flows_parallel(mfile_vel, locs);
    
    % Toc
    tend = string(datetime('now'));
    fprintf('%s%s\n', ['Finished: ' tend])
    tictoc = etime(datevec(tend), datevec(tstart)) / 3600;
    fprintf('%s%s%s\n\n', ['Elapsed time: ' string(tictoc) ' hours'])

end % cluster_neurosv_multiple_get_nodal_calculate_3d_flows()

