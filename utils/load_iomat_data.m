function obj_data = load_io_mat_file(params)
% Load interpolated data iomat or put regular data into an appropriate structure?
% or make a temporary iomatfile??

 % Load interpolated data
    if strcmp(params.data.grid.type, 'unstructured')
        % Load data file
        obj_data = matfile(fullfile(params.interpolation.file.dir, ...
                                    params.interpolation.file.name), ...
                                    'Writable', false);
    else
        % NOTE: NOT IMPLEMENTED YET
        %obj_data = matfile(fullfile(params.data.file.dir, ...
        %                            params.data.file.name), ...
        %                            'Writable', true);
        continue
    end


end % function load_iomat_file()