function cluster_interp_rename_and_resample(idx_chunk)

% One-off function to be used on Artemis. 
% Map weird


filename  =  get_flowfile_name(idx_chunk);

if strcmp(filename, 'none')
    disp('chunk not available yet')
    return
else
    path_on_artemis = '/scratch/CGMD/';
    mfile_obj = matfile([path_on_artemis filename], 'Writable', false);
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
    newfilename = ['interp_act_d1ms_c0-6_chunkidx_' num2str(idx_chunk, '%03d') '.mat'];
    % Open new filename
    newfile_obj = matfile([path_on_artemis newfilename], 'Writable', true); 

    downsample_factor_space = 2;

    % Original grid is in the flow files
    newfile_obj.downsample_factor_space = downsample_factor_space;


    disp('Saving interp data ...')
    tpts = size(mfile_obj, 'data', 4); %#ok<GTARG>

    x_size = size(mfile_obj, 'data', 1); %#ok<GTARG>
    y_size = size(mfile_obj, 'data', 2); %#ok<GTARG>
    z_size = size(mfile_obj, 'data', 3); %#ok<GTARG>

    x_size_down = length(1:downsample_factor_space:x_size);
    y_size_down = length(1:downsample_factor_space:y_size);
    z_size_down = length(1:downsample_factor_space:z_size);

    % Preallocate variable sapace
    newfile_obj.data(x_size_down, y_size_down, z_size_down, tpts) = 0;


    for tt=1:tpts
        % make local variables
        data = mfile_obj.data(:, :, :, tt);
        newfile_obj.data(:, :, :, tt) = data(1:downsample_factor_space:end, 1:downsample_factor_space:end, 1:downsample_factor_space:end);
    end

    newfile_obj.options = options;

    % now that everything is saved, delete file
    delete([path_on_artemis filename])

end
    

end % function cluster_interp_rename_and_resample()
