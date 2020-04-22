function [data, params, varargout] = load_data(params)
% the .mat data file should have
% ARGUMENTS:
%            data2d -- a 2D array of size [timepoints x nodes/points] and %
%            locs3d -- 2D array of size [nodes/points x 3] with coordinates of points in 3D Euclidean space for which data values are known. 
%                      These corresponds to the centres of gravity: ie, node locations 
%                      of brain network embedded in 3D dimensional space, or source
%                      locations from MEG. 

%            data4d -- a 4D array of size [timepoints, x, y, z]
%            hx, hy, hz, resolution voxel size



    data_path = fullfile(params.data.dir.name, params.data.file.name);
    data_struct = load(data_path);
    params.data.shape.size = size(data_struct.data);
    params.data.shape.dims = length(params.data.shape.size);

    switch params.data.grid.type
        case 'unstructured'
            params.data.shape.timepoints = params.data.shape.size(1);
            params.data.shape.nodes = params.data.shape.size(2);
            varargout{1} = data_struct.locs;
        case 'structured'
            params.data.shape.timepoints = params.data.shape.size(1);
            % This may bring problems if x, y are swapped
            params.data.shape.x = params.data.shape.size(2); 
            params.data.shape.y = params.data.shape.size(3);
            params.data.shape.z = params.data.shape.size(4);
            params.data.hx = data_struct.hx;
            params.data.hy = data_struct.hy;
            params.data.hz = data_struct.hz;
        otherwise
            error(['neural-flows:' mfilename ':UnknownCase'], ...
                   'Unknown grid type. Options: {"unstructured", "structured"}');
            
    end

    data = data_struct.data;
    % TODO: handle the case of slicing data. Though that can be left as an example rather than something the code handles

end % load_data()
