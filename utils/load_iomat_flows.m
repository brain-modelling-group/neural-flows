function [obj_flows, varargout] = load_iomat_flows(params)
% Load flow data
obj_flows = matfile(fullfile(params.flows.file.dir, ...
                             params.flows.file.name), ...
                             'Writable', false);

end % function load_iomat_flows()