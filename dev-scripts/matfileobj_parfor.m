parpool(12);
%%
%%step 1: create a mat-file per worker using SPMD
N = 400;


spmd
    WorkerFname = tempname(pwd); % each worker gets a unique filename and writes to disk
    myMatfile   = matfile(WorkerFname, 'Writable', true);
    % Seed the variables in the matfile object
    myMatfile.data_interp = cell(1, N);
    myMatfile.gotResult   = false(1, N);
end
%%step 2: create a parallel.pool.Constant from the 'Composite'
% This allows the worker-local-variable to used inside PARFOR
myMatfileConstant = parallel.pool.Constant(myMatfile);

%%Step 3: run PARFOR
m = 3;
n = 2;

parfor idx = 1:N
    resultToSave = rand(m, n);
    matfileObj   = myMatfileConstant.Value;
    % Assign into 'testOut'
    matfileObj.data_interp(1, idx) = {resultToSave}
    matfileObj.gotResult(1, idx)   = true;
end
%%Step 4: accumulate the results on the client
% Here we retrieve the filenames from 'myFname' Composite,
% and use them to accumulate the overall result in memory
% We're going to concatenate results in the 3rd dimension
%%
[temp_fname_obj, temp_file_sentinel] = create_temp_file('dummy_parfor', true);
temp_fname_obj.data(m, n, N) = 0; 
for idx = 1:numel(WorkerFname)
    workerFname = WorkerFname{idx};
    workerMatfile = matfile(workerFname);
    for jdx = 1:N
        if workerMatfile.gotResult(1, jdx)
            pageCell = workerMatfile.data_interp(1, jdx);
            temp_fname_obj.data(:, :, jdx) = pageCell{1};
        end
    end
end
