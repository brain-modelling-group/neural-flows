function [varargout] = read_write_json(options_filename, options_dir, rw_mode, varargin)
%% This function read input parameters from a json file and translates to a Matlab structure, or 
%  alternatively writes the `options` structure to a json file. 
% 
% ARGUMENTS:
%      options_filename  --   a string with the name of the input json file. 
%      options_dir       --   a string with the path to the directory where the json file is stored
%      rw_mode           --   a string specifying if we're reading or writing a json file.
%                             Options: {'read', 'write'}  
%      varargin          --   if rw_mode == 'write', then varargin{1} should be the options structure to write to file
% OUTPUT:
%      varargout         --   if rw_mode == 'read', then varargout{1} is the options structure to be passed to other functions
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer December 2019
% USAGE:
%{
    options_filename = 'travelling_wave_parameters.json';
    options_dir = 'test-cases';
    rw_mode = 'read'

%}

% REQUIRES: 
% Matlab R2016b or later because of jsondecode() 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

% Create path to file
options_path = fullfile(options_dir, options_filename);

switch rw_mode
    case {'read', 'r', 'R'}
        options_json = fileread(options_filename);
        options_strc = jsondecode(options_json);
        varargout{1} = options_strc;
    case {'write', 'w', 'W'}
        options_strc = varargin{1}; % Not really necessary but makes the process explicit
        options_json = jsonencode(options_strc);
        options_file_id = fopen(options_path, 'w');
        fprintf(options_file_id, options_json);
        fclose(options_file_id);

    otherwise
        error(['neural-flows:' mfilename ':UnknownInput'], 'Unknown execution mode. Options: {"read", "write"}');
end

end % function read_write_json()
