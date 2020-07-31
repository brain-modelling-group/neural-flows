function [tbx_abs_path] =  get_neural_flows_path()
% Small function to get absolute path to where the neural-flows toolbox is
% located.
% Returns the OS specific absolute path to the toolbox

% PSL, July 2020

% where am I

[filepath, ~, ~] = fileparts(mfilename('fullpath'));

split_file_path = strsplit(filepath, filesep);

who_am_i = check_os();

if strcmp(who_am_i, 'penguin')
    tbx_abs_path = [filesep strjoin(split_file_path(2:end-1), filesep)];
elseif strcmp(who_am_i, 'apple')
    tbx_abs_path = [filesep strjoin(split_file_path(2:end-1), filesep)];
else
    tbx_abs_path = strjoin(split_file_path(1:end-1), filesep);
end %

end % get_neural_flows_path()