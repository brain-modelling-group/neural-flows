function input_params = check_storage_dirs(input_params, dir_to_check)
% input: input_params -- struct genereated fromr eadin the input
% configuration json file


switch dir_to_check
    % Check the directory we use to write partial results during parallel
    % execution
    
    case {'tmp', 'temp', 'temporary', 'temp_files'}
        
          if ~exist(input_params.general.storage.dir_tmp,'dir') 
              temp_dir_name = tempdir; % OS specific
              input_params.general.storage.dir_tmp = temp_dir_name;
          end
    case {'output', 'out', 'storage', 'results'}
        if ~exist(input_params.general.storage.dir, 'dir')
            % Check if it doesn't exist because it was an empty string
            if strcmp(input_params.general.storage.dir, '')
                wrn_message = "neural-flows:: Unspecified storage directory for output files";
            else
                wrn_message = "neural-flows:: Invalid storage directory for output files. It seems this directory doesn't exist";
            end    
            warning(wrn_message)
            
            fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Creating scratch/ directory to store results.'))              

            % Where is the neural-flows toolbox
            [tbx_abs_path] =  get_neural_flows_path();
            [yay, ~, ~] = mkdir(tbx_abs_path, 'scratch');
            
            if yay
                fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Succesfully created scratch/ directory to store results.'))              
            end
        end
end
        
end % function check_storage_dirs()