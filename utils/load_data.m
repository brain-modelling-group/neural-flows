function [data, locs, params] = load_data(params)
% the .mat data file should have

% Write some additional infor
% ARGUMENTS:
%            data -- a 2D array of size [timepoints x nodes/points] and 
%
%            locs -- 2D array of size [nodes/points x 3] with coordinates of points in 3D Euclidean space for which data values are known. 
%                  These corresponds to the centres of gravity: ie, node locations 
%                  of brain network embedded in 3D dimensional space, or source
%                  locations from MEG. 


    data_path = fullfile(params.data.dir.name, params.data.file.name);
    data_struct = load(data_path);
    params.data.shape.size = size(data_struct.data);
    params.data.shape.dims = length(params.data.shape.size);

    switch params.data.grid.type
        case 'unstructured'
            params.data.shape.timepoints = params.data.shape.size(1);
            params.data.shape.nodes = params.data.shape.size(2);
        case 'structured'
            params.data.shape.timepoints = params.data.shape.size(1);
            % This may bring problems if x, y are swapped
            params.data.shape.x = params.data.shape.size(2); 
            params.data.shape.y = params.data.shape.size(3);
            params.data.shape.z = params.data.shape.size(4);
        otherwise
            error(['neural-flows:' mfilename ':UnknownCase'], ...
                   'Unknown grid type. Options: {"unstructured", "structured"}');
            
    end
            
    % TODO: handle the case of slicing data == althoug that can be left as an example rather than something the code handles

end % load_data()
