function downsample_stored_data(idx_chunk, mfile_vel, mfile_interp, mfile_sings)

    % NOTE: newfilename for flows and interp should be passed as an
    % argument
    newflowfilename  = ['flows_act_long_chunkidx_' num2str(idx_chunk, '%03d') '.mat'];
    resample_flows(newflowfilename)
    
    newinterpfilename = ['interp_act_long_chunkidx_' num2str(idx_chunk, '%03d') '.mat'];
    resample_interp(newinterpfilename)
        
    newsingfilename = ['sngs_act_long_chunkidx_' num2str(idx_chunk, '%03d') '.mat'];
    resample_sings(newsingfilename)

    
    function resample_sings(newfilename)
        options = mfile_sings.options;
        newfile_obj = matfile(newfilename, 'Writable', true); 
        newfile_obj.singularity_classification = mfile_sings.singularity_classification;
        newfile_obj.xyz_idx = mfile_sings.xyz_idx;
        newfile_obj.options = options;
        delete(mfile_sings.Properties.Source)
    end


    function resample_flows(newfilename)
        options = mfile_vel.options;
    
        % Create new file name
        % Open new filename
        newfile_obj = matfile(newfilename, 'Writable', true); 

        downsample_factor_space = 4;

        % Save original grid
        newfile_obj.Xo = mfile_vel.X;
        newfile_obj.Yo = mfile_vel.Y;
        newfile_obj.Zo = mfile_vel.Z;
        newfile_obj.hxyzt_original = [mfile_vel.hz, mfile_vel.hy, mfile_vel.hz, mfile_vel.ht];
        newfile_obj.in_bdy_mask_original = mfile_vel.in_bdy_mask;
        newfile_obj.in_bdy_mask = mfile_vel.in_bdy_mask(1:downsample_factor_space:end, 1:downsample_factor_space:end, 1:downsample_factor_space:end);
        newfile_obj.downsample_factor_space = downsample_factor_space;


        disp('Resampling and saving grids ...')
        % Save new grids
        X = mfile_vel.X;
        Y = mfile_vel.Y;
        Z = mfile_vel.Z;
        newfile_obj.X = X(1:downsample_factor_space:end, ...
                          1:downsample_factor_space:end, ...
                          1:downsample_factor_space:end);
        newfile_obj.Y = Y(1:downsample_factor_space:end, ...
                          1:downsample_factor_space:end, ...
                          1:downsample_factor_space:end); 
        newfile_obj.Z = Z(1:downsample_factor_space:end, ...
                          1:downsample_factor_space:end, ...
                          1:downsample_factor_space:end); 
        clear X Y Z

        tpts = size(mfile_vel, 'ux', 4); %#ok<GTARG>

        x_size = size(mfile_vel, 'ux', 1); %#ok<GTARG>
        y_size = size(mfile_vel, 'ux', 2); %#ok<GTARG>
        z_size = size(mfile_vel, 'ux', 3); %#ok<GTARG>

        x_size_down = length(1:downsample_factor_space:x_size);
        y_size_down = length(1:downsample_factor_space:y_size);
        z_size_down = length(1:downsample_factor_space:z_size);

        % Preallocate variable sapace
        newfile_obj.ux(x_size_down, y_size_down, z_size_down, tpts) = 0;
        newfile_obj.uy(x_size_down, y_size_down, z_size_down, tpts) = 0;
        newfile_obj.uz(x_size_down, y_size_down, z_size_down, tpts) = 0;


        for tt=1:tpts
            % make local variables
            ux = mfile_vel.ux(:, :, :, tt);
            uy = mfile_vel.uy(:, :, :, tt);
            uz = mfile_vel.uz(:, :, :, tt);

            newfile_obj.ux(:, :, :, tt) = ux(1:downsample_factor_space:end, ...
                                             1:downsample_factor_space:end, ...
                                             1:downsample_factor_space:end);
            newfile_obj.uy(:, :, :, tt) = uy(1:downsample_factor_space:end, ...
                                             1:downsample_factor_space:end, ...
                                             1:downsample_factor_space:end);
            newfile_obj.uz(:, :, :, tt) = uz(1:downsample_factor_space:end, ...
                                             1:downsample_factor_space:end, ...
                                             1:downsample_factor_space:end);

        end       

        disp('Resampling and saving flows ...')
        newfile_obj.max_nu = mfile_vel.max_nu;
        newfile_obj.max_uu = mfile_vel.max_uu;
        newfile_obj.max_ux = mfile_vel.max_ux;
        newfile_obj.max_uy = mfile_vel.max_uy;
        newfile_obj.max_uz = mfile_vel.max_uz;

        newfile_obj.min_nu = mfile_vel.min_nu;
        newfile_obj.min_uu = mfile_vel.min_uu;
        newfile_obj.min_ux = mfile_vel.min_ux;
        newfile_obj.min_uy = mfile_vel.min_uy;
        newfile_obj.min_uz = mfile_vel.min_uz;

        newfile_obj.sum_ux = mfile_vel.sum_ux;
        newfile_obj.sum_uy = mfile_vel.sum_uy;
        newfile_obj.sum_uz = mfile_vel.sum_uz;
        newfile_obj.detection_threshold = mfile_vel.detection_threshold;
        newfile_obj.options = options;

        % Delete original file once everything is saved
        delete(mfile_vel.Properties.Source)


    end


    function resample_interp(newfilename)
        options = mfile_interp.options;
        % Create new file name
        % Open new filename
        newfile_obj = matfile(newfilename, 'Writable', true); 

        downsample_factor_space = 4;

        % Original grid is in the flow files
        newfile_obj.downsample_factor_space = downsample_factor_space;


        disp('Resampling and saving interp data ...')
        tpts = size(mfile_interp, 'data', 4); %#ok<GTARG>

        x_size = size(mfile_interp, 'data', 1); %#ok<GTARG>
        y_size = size(mfile_interp, 'data', 2); %#ok<GTARG>
        z_size = size(mfile_interp, 'data', 3); %#ok<GTARG>

        x_size_down = length(1:downsample_factor_space:x_size);
        y_size_down = length(1:downsample_factor_space:y_size);
        z_size_down = length(1:downsample_factor_space:z_size);

        % Preallocate variable sapace
        newfile_obj.data(x_size_down, y_size_down, z_size_down, tpts) = 0;


        for tt=1:tpts
            % make local variables
            data = mfile_interp.data(:, :, :, tt);
            newfile_obj.data(:, :, :, tt) = data(1:downsample_factor_space:end, 1:downsample_factor_space:end, 1:downsample_factor_space:end);
        end

        newfile_obj.options = options;

        % now that everything is saved, delete file
        delete(mfile_interp.Properties.Source)

    end
  

end % function cluster_resample_data()
