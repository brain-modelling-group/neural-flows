function singularity3d_classify(params)
% 1) calculates jacobian for each critical point, and then 
% 2) classify type of critical point. 
% ARGUMENTS:
%          nullflow_points3d     -- a struct of size [1 x no. timepoints]
%                                -- locs.linear_idx [no. of singularities x 1] -- linear indices 
%                                -- locs.subscripts [no. of singularities x 3] -- subscripts
%          mvel_obj              -- a MatFile handle pointing to the flows/velocity
%                            fields. Needed for the calculation of the
%                            jacobian matrix. Or a matlab structure with
%                            the same fields as the matfile produced by the
%                            code.
% OUTPUT:
%         singularity_classification  --  a cell array of size [1 x no. timepoints]
%                                         where each element is a cell of size
%                                         [no. of singularities]. The cells
%                                         have human readable strings with
%                                         the type of singularity detected. 
% REQUIRES:
%          switch_index_mode()
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer February 2019
% USAGE:
%{
    
%}
% NOTE: as the timeseries get longer, we can in principle parallelise this
% function.

    

    % Load singularity data- writable
    obj_singularity = load_iomat_singularity(params);
    nullflow_points3d = obj_singularity.nullflow_points3d;

    % Check if we stored linear indices or subscripts 
    if ~isfield(nullflow_points3d(1).locs, 'subscripts')
        fprintf('\n%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started converting lindear indices into subscripts.'))
        for tt=1:tpts
            nullflow_points3d(tt).locs.subscripts = switch_index_mode(nullflow_points3d(tt).xyz_idx, 'subscript', grid_size);;
        end   
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished converting lindear indices into subscripts.'))
        obj_singularity.nullflow_points3d = nullflow_points3d;
    end

    if params.general.parallel.enabled
        singularity3d_classify_fun = @singularity3d_classify_parallel
    else
        singularity3d_classify_fun = @singularity3d_interpolate_serial
    end

    % Allocate output and save to file
    obj_singularity.classification_list = singularity_classify_fun(nullflow_points3d, params);

end % function singularity3d_classify()
