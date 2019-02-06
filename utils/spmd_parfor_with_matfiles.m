function [output_matfile_obj] = spmd_parfor_with_matfiles(number_of_things, parfun, output_matfile_obj, storage_expression)
%% This is a horrible name for a function, but I'm not sure what else to call it
% This functions uses SPMD statements to generate temporary files that will
% be accessed by the workers, at the end the partial results are glued
% together into the (mat)file the user passed as an input. Assumes a
% parpool is already open. If unsure call open_parpool(0.8).
%
%
% ARGUMENTS:
%        number_of_things   -- an integer. The number of things we are
%                              iterating over.
%        parfun             -- a function handle which accepts as input the 
%                              index of the parfor loop. 
%        temp_fname_object  -- a Writable matFile()
%        storage_expression -- a string with the expression that will be
%                              evaluated to store the results in temp_fname_obj
%                              For instance if the results are to be stored/glued 
%                              in 'data', which exists in output_matfile_obj, 
%                              and number_of_things is the size of 'data' along 
%                              the 3rd dimension: 
%
%                                  storage_expression = 'data(:, :, jdx)';
%
%                              where jdx is the internal name of the counter. 
%                              
%                              
% OUTPUT: 
%        temp_matfile_obj -- the same matFile object of the input. Not really
%                            necessary, but felt like the function should 
%                            output something. 
%
% REQUIRES: 
%        parallel computing toolbox
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
% AUTHOR:
%        Paula Sanz-Leon, QIMR Berghofer 2019-02
%

    % Step 1: create a matfile per worker using SPMD
    spmd
        WorkerFname      = tempname(pwd); % each worker gets a unique filename and writes to disk
        worker_matfile   = matfile(WorkerFname, 'Writable', true);  
        % Seed the variables in the matfile object
        worker_matfile.result     = cell(1, number_of_things);
        worker_matfile.got_result = false(1, number_of_things);
    end

    % Step 2: create a parallel.pool.Constant from the 'Composite' 
    % This allows the worker-local-variable to used inside PARFOR
    matfile_constant = parallel.pool.Constant(worker_matfile);

    %%Step 3: run PARFOR
    parfor idx = 1:number_of_things
        % DO THE THING HERE
        result_to_save = feval(parfun, idx);
        % Get the correct matfile object for each worker
        matfile_obj   = matfile_constant.Value;
        % Assign into 'testOut'
        matfile_obj.result(1, idx) = {result_to_save}
        matfile_obj.got_result(1, idx) = true;
    end

    % Step 4: accumulate results on a separate file 
    % Here we retrieve the filenames from 'WorkerFname' Composite,
    % and use them to accumulate the overall result in disk

    for this_temp_file = 1:numel(WorkerFname)
        worker_fname = WorkerFname{this_temp_file};
        % Load the worker temp file
        worker_matfile = matfile(worker_fname);

        for jdx = 1:number_of_things
            if worker_matfile.got_result(1, jdx)
                 result = worker_matfile.result(1, jdx);
                %  This line is meant to be generic and adaptbale
                eval(['output_matfile_obj.' storage_expression  '= result{1};']);
            end
        end
        delete([worker_fname '.mat'])
    end
end % function spdm_parfor_with_matfiles()
