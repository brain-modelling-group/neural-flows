function [mfile_obj, temp_file_sentinel] = create_temp_file(fname)
% Creates a matfile object for temporary storage of chubby nDarrays
% Returns a file sentinel to delete the temporary file 
    
    temp_fname = generate_temp_filename(fname);
    temp_fname = [temp_fname, '.mat'];
    mfile_obj  = matfile(temp_fname, 'Writable', true);

    % Clean up after ourselves    
    temp_file_sentinel = onCleanup(@() remove_temp_file(temp_fname));
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