function [obj_streams, varargout] = load_iomat_flows(params)
% Load flow data
obj_streams = matfile(fullfile(params.streamlines.file.dir, ...
                             params.streamlines.file.name), ...
                             'Writable', false);

end % function load_iomat_streams()