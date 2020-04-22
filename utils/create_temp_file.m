function [mfile_handle, mfile_sentinel] = create_temp_file(filename, directory, keep_file)
%% Creates a matfile object intended as a temporary file with a pseudorandom 
% filename intended as a temporary file. Optionally, it retutrns an OnCleanup 
% file sentinel, which will  delete the file upon its destruction. 
%
%
% ARGUMENTS:
%        fname -- string with the 'root' name for that file. Timestamp and
%                 random string will be appended to it.
%        keep_file -- a boolean flag. If one intends to keep the file, then 
%                     mfile_sentinel is an empty array. 
%
% OUTPUT: 
%        mfile_obj     -- a Writable matFile() object. 
%        temp_sentinel -- an OnCleanup object or an empty array, depending
%                         on the value of keep_file.
%
% REQUIRES: 
%        generate_temp_filename()
%
% USAGE:
%{
    
%}
%
% AUTHOR: 
%        Paula Sanz-Leon, QIMR berghofer 2019-02
    
    mfile_name = generate_temp_filename(filename, 4);
    mfile_name = [mfile_name, '.mat'];
    mfile_handle  = matfile(fullfile(directory, mfile_name), 'Writable', true);

    % Clean up after ourselves
    if ~keep_file
        mfile_sentinel = onCleanup(@() remove_temp_file(mfile_name));
    else
        mfile_sentinel = [];
    end
    
    fprintf('%s \n', 'Creating file:')
    fprintf('\t \t %s \n', mfile_name)
end % function create_temp_file()

function remove_temp_file(fname)
% This action will be performed when
% mfile_sentinel is destroyed

 fprintf('%s \n', 'Removing file:')
 fprintf('\t \t %s \n', fname)
 delete(fname)
 
end % function remove_temp_file()
