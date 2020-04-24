function [obj_data, obj_data_sentinel] = load_iomat_data(params)
% Load interpolated data iomat or put regular data into an appropriate structure?
% or make a temporary iomatfile??
% TODO: make a sentinel, delete object handle or file? 
% Delete handle for interpolated data file but delete file for noninterpolated data

 % Load interpolated data
    if strcmp(params.data.grid.type, 'unstructured')
        % Load file with interpolated datafile
        obj_data = matfile(fullfile(params.interpolation.file.dir, ...
                                    params.interpolation.file.name), ...
                                    'Writable', false);
    else
        % NOTE: NOT IMPLEMENTED YET
        %obj_data = matfile(fullfile(params.data.file.dir, ...
        %                            params.data.file.name), ...
        %                            'Writable', true);
        disp('continue')
    end


end % function load_iomat_data()