function [mfile_obj, temp_file_sentinel] = create_temp_file(fname, keep_file)
%% Creates a matfile object intended as a temporary file with a pseudorandom 
% filename intended as a temporary file. Optionally, it retutrns an OnCleanup 
% file sentinel, which will  delete the file upon its destruction. 
%
%
% ARGUMENTS:
%        fname -- string with the 'root' name for that file. Timestamp and
%                 random string will be appended to it.
%        keep_file -- a boolean flag. If one intends to keep the file, then 
%                     temp_file_sentinel is an empty array. 
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
    
    temp_fname = generate_temp_filename(fname);
    temp_fname = [temp_fname, '.mat'];
    mfile_obj  = matfile(temp_fname, 'Writable', true);

    % Clean up after ourselves
    if ~keep_file
        temp_file_sentinel = onCleanup(@() remove_temp_file(temp_fname));
    else
        temp_file_sentinel = [];
    end
    
    fprintf('%s \n', 'Creating file:')
    fprintf('\t \t %s \n', temp_fname)
end

function remove_temp_file(fname)
% This action will be performed when
% temp_file_sentinel is destroyed

 fprintf('%s \n', 'Removing file:')
 fprintf('\t \t %s \n', fname)
 delete(fname)
 
end