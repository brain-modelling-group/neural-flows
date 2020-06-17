function [obj_data, varargout] = load_iomat_data(params)
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
             if ~isprop(obj_data, 'nodes_str_lbl')
                 nodes_str_lbl = cell(params.data.shape.nodes,1); 
                for nn=1:params.data.shape.nodes
                    nodes_str_lbl{nn} = num2str(nn, '%03d');
                end
             end
            obj_data.nodes_strl_lbl = nodes_str_lbl;
            params.data.nodes_strl_lbl = nodes_str_lbl;
        case 'structured'
            params.data.shape.timepoints = params.data.shape.size(4);
            params.data.shape.x = params.data.shape.size(2); 
            params.data.shape.y = params.data.shape.size(1);
            params.data.shape.z = params.data.shape.size(3);
            params.data.hx = obj_data.hx;
            params.data.hy = obj_data.hy;
            params.data.hz = obj_data.hz;
            params.data.ht = obj_data.ht;
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