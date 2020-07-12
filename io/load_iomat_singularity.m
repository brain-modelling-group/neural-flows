function [obj_singularity, varargout] = load_iomat_singularity(params)

% Load flow data
obj_singularity = matfile(fullfile(params.singularity.file.dir, ...
                                   params.singularity.file.name), ...
                                  'Writable', true);

end % function load_iomat_singularity()