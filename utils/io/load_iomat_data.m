function [obj_data, obj_data_sentinel] = load_iomat_data(params)
% Load ioriginal data stored in an iomat file 

obj_data = matfile(fullfile(params.data.file.dir, ...
                            params.data.file.name), ...
                            'Writable', true);

end % function load_iomat_data()