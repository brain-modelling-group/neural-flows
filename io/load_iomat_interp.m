function [obj_data, obj_data_sentinel] = load_iomat_interp(params)
% Load interpolated data iomat 

% Load file with interpolated datafile
 obj_data = matfile(fullfile(params.interpolation.file.dir, ...
                             params.interpolation.file.name), ...
                             'Writable', false);



end % function load_iomat_interp()