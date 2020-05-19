function [obj_data,varargout] = load_iomat_data(params)
% Load ioriginal data stored in an iomat file 

obj_data = matfile(fullfile(params.data.file.dir, ...
                            params.data.file.name), ...
                            'Writable', true);

params.data.shape.size = size(obj_data, 'data');
params.data.shape.dims = length(params.data.shape.size);

switch params.data.grid.type
        case 'unstructured'
            params.data.shape.timepoints = size(obj_data, 'data', 1);
            params.data.shape.nodes =  size(obj_data, 'data', 2);
            
end

 % Human readable indexing locs array
 params.data.x_dim_locs = 1;
 params.data.y_dim_locs = 2;
 params.data.z_dim_locs = 3;

 % Human readable indexing grid array
 params.data.x_dim_mgrid = 2;
 params.data.y_dim_mgrid = 1;
 params.data.z_dim_mgrid = 3;

 varargout{1} = params;

end % function load_iomat_data()