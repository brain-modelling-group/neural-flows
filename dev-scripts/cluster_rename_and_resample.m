function cluster_rename_and_resample(idx_chunk)

% One-off function to be used on Artemis. 
% Map weird


filename  =  get_flowfile_name(idx_chunk);

if strcmp(filename, 'none')
    return
else
    path_on_artemis = '/scratch/CGMD/';
    mfile_obj = matfile([path_on_artemis filename], 'Writable', 'true');
    options = mfile_obj.options;

    % Just in case we didn't save this before
    if ~isfield(options, 'chunk')
        options.chunk = idx_chunk;
    else
        if options.chunk ~= idx_chunk
            disp('chunk indices do not match. Wrong file name?')
            return
        end
        

    end
    % Create new file name
    newfilename = ['flows_act_d1ms_c0-6_chunkidx_' numstr(idx_chunk, '%03d') '.mat');
    % Open new filename
    newfile_obj = matfile([path_on_artemis newfilename]); 

    downsample_factor_space = 4;

    % Save original grid
    newfile_obj.Xo = mfile_obj.X;
    newfile_obj.Yo = mfile_obj.Y;
    newfile_obj.Zo = mfile_obj.Z;
    newfile_obj.hxyzt_original = [mfile_obj.hz, mfile_obj.hy, mfile_obj.hz, mfile_obj.ht];
    newfile_obj.in_bdy_mask_original = mfile_obj.in_bdy_mask;
    newfile_obj.in_bdy_mask = mfile_obj.in_bdy_mask(1:downsample_factor_space:end, 1:downsample_factor_space:end, 1:downsample_factor_space:end);
    newfile_obj.downsample_factor_space = downsample_factor_space;

    % Save new grids
    X = mfile_obj.X;
    Y = mfile_obj.Y;
    Z = mfile_obj.Z;
    newfile_obj.X = X(1:downsample_factor_space:end, 1:downsample_factor_space:end, 1:downsample_factor_space:end);
    newfile_obj.Y = Y(1:downsample_factor_space:end, 1:downsample_factor_space:end, 1:downsample_factor_space:end); 
    newfile_obj.Z = Z(1:downsample_factor_space:end, 1:downsample_factor_space:end, 1:downsample_factor_space:end); 
    clear X Y Z

    tpts = size(mfile_obj, 'ux', 4); %#ok<GTARG>
    for tt=1:tpts
        newfile_obj.ux(:, :, :, tt) = mfile_obj.ux(1:downsample_factor_space:end, 1:downsample_factor_space:end, 1:downsample_factor_space:end, tt);
        newfile_obj.uy(:, :, :, tt) = mfile_obj.uy(1:downsample_factor_space:end, 1:downsample_factor_space:end, 1:downsample_factor_space:end, tt);
        newfile_obj.uz(:, :, :, tt) = mfile_obj.uz(1:downsample_factor_space:end, 1:downsample_factor_space:end, 1:downsample_factor_space:end, tt);

    end
    newfile_obj.max_nu = mfile_obj.max_nu;
    newfile_obj.max_uu = mfile_obj.max_uu;
    newfile_obj.max_ux = mfile_obj.max_ux;
    newfile_obj.max_uy = mfile_obj.max_uy;
    newfile_obj.max_uz = mfile_obj.max_uz;
    
    newfile_obj.min_nu = mfile_obj.min_nu;
    newfile_obj.min_uu = mfile_obj.min_uu;
    newfile_obj.min_ux = mfile_obj.min_ux;
    newfile_obj.min_uy = mfile_obj.min_uy;
    newfile_obj.min_uz = mfile_obj.min_uz;

    newfile_obj.sum_ux = mfile_obj.sum_ux;
    newfile_obj.sum_uy = mfile_obj.sum_uy;
    newfile_obj.sum_uz = mfile_obj.sum_uz;

    newfile_obj.options = options;

end
    

end % function cluster_rename_and_resample()
