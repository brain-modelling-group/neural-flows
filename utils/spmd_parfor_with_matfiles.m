function [temp_fname_obj] = spmd_parfor_with_matfiles(number_of_things, parfun, temp_fname_obj, storage_expression)
% This is a gorrible name, but I'm not sure what else to write
% Assumes a parpool is open
% number_of_things is the variable we are iterating over
% temp_fname_obj, the file where we will accumulate/glue final results
% field of interest -- where to store the data in temp_fname_ibj
% after
% the parfor loop
% Step 1: create a mat-file per worker using SPMD
spmd
    WorkerFname      = tempname(pwd); % each worker gets a unique filename and writes to disk
    worker_matfile   = matfile(WorkerFname, 'Writable', true);  
    % Seed the variables in the matfile object
    worker_matfile.result = cell(1, number_of_things);
    worker_matfile.got_result = false(1, number_of_things);
end

% Step 2: create a parallel.pool.Constant from the 'Composite' 
% This allows the worker-local-variable to used inside PARFOR
matfile_constant = parallel.pool.Constant(worker_matfile);

%%Step 3: run PARFOR

parfor idx = 1:number_of_things
    % DO THE THING HERE
    resultToSave = feval(parfun, idx);
    matfileObj   = matfile_constant.Value;
    % Assign into 'testOut'
    matfileObj.result(1, idx) = {resultToSave}
    matfileObj.got_result(1, idx) = true;
end

% Step 4: accumulate results on a separate file 
% Here we retrieve the filenames from 'WorkerFname' Composite,
% and use them to accumulate the overall result in dik
% We're going to concatenate results in the 4th dimension
%
for this_temp_file = 1:numel(WorkerFname)
    worker_fname = WorkerFname{this_temp_file};
    % Load the worker temp file
    worker_matfile = matfile(worker_filename);
    
    for jdx = 1:number_of_things
        if worker_matfile.got_result(1, jdx)
             result = worker_matfile.result(1, jdx);
            %  This line should be generic and adaptbale
            
            eval(['temp_fname_obj.' storage_expression  '= result{1};']);
        end
    end
    delete([worker_fname '.mat'])
end
end % function spdm_parfor_with_matfiles()