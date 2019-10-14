function neural_flows_process_multiple_epochs(subj_idx)
% Function to apply neural flow analysis to meg data defined on scattered
% points - Naples 58 subjects dataset. Each subject will have multiple
% epochs, that will be handled inside this function via a for loop.
% The files that this function processes are the output of
% extract_isolen_epochs()
%
% ARGUMENTS:
%          subj_idx  -- an integer with the subject number between 1-58
%                       this function assumes that .mat files with a
%                       consistent naming exist in output_data/
%
% OUTPUT: 
%          TBD
%
% REQUIRES: 
%           neural-flows
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon -- QIMR October 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: add filename string expression as input variable

    filename = ['meg_rs_subj_' num2str(subj_idx, '%02d') '_epochlen_1024_nofilt'];
    in1 = load(filename);
    in2 = load('locs_90_rois');
    
    fs = 1024;
    locs = in2.locs;
  
    %num_epochs = size(in1.serie_temp, 2);
    max_epochs = 4; % we may want to have the same number of epochs for all subjects
    cd ../output_data

    
    %Cluster properties
    try
        local_cluster = parcluster('local');
        local_cluster.NumWorkers = 12;   % This should match the requested number of cpus
        parpool(local_cluster.NumWorkers, 'IdleTimeout', 1800);
    catch
        disp('Parallel pool alrady exists')
    end
    
   filename_append_string = ['meg_rs_subj_' num2str(subj_idx, '%02d')];
   useful_nodes = 1:90; 
   for this_epoch = 1:max_epochs
        data = in1.serie_temp{1, this_epoch};
        data = data(useful_nodes, :).';
        
        % Options for the flow computation
        options.data_interpolation.filename_string = filename_append_string;
        options.data_interpolation.file_exists = false;
        options.data_interpolation.bdy_alpha_radius = 35;

        % Resolution
        options.hx = 4; % in mm
        options.hy = 4; % in mm
        options.hz = 4; % in mm
        options.ht = (1/fs)*1000; % in ms
    
        % indexing
        options.chunk = this_epoch;

        % Flow parameters
        options.flow_calculation.filename_string = filename_append_string;
        options.flow_calculation.init_conditions = 'random';
        options.flow_calculation.seed_init_vel = 42;
        options.flow_calculation.alpha_smooth   = 0.1;
        options.flow_calculation.max_iterations = 128;
        
        % Singularity analysis parametrs
        options.sing_analysis.filename_string = filename_append_string;
        options.sing_analysis.detection = true;    
        options.sing_analysis.detection_datamode  = 'vel';


        % Tic
        tstart = string(datetime('now'));
        fprintf('%s%s\n', ['Started: ' tstart])

        % Do the stuff 
        [mfile_flows, ~, ~] = main_neural_flows_hs3d_scatter(data, locs, options);
        mfile_flows.Properties.Writable = true;

        
        
        % Find fastest routes
        MFP = find_fastest_routes(mfile_flows);
        mfile_flows.MFP = MFP;
        
        % Toc
        tend = string(datetime('now'));
        fprintf('%s%s\n', ['Finished: ' tend])
        tictoc = etime(datevec(tend), datevec(tstart)) / 3600;
        fprintf('%s%s%s\n\n', ['Elapsed time: ' string(tictoc) ' hours'])
        
        
    end
    
    cd ../routing

end % function neural_flows_process_multiple_epochs
