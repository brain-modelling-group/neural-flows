function open_parpool(workers_proportion)
%% This function first checks if there is a parallel pool open,
%  then opens one pool if none exist. If there is a pool open, it deletes it 
%  and opens a  new one wuth the requested proportion of workers. 
%  The number of workers in the new pool is determined based 
%  on the hardware and the proportion specified in the input.
%
% ARGUMENTS:
%        workers_proportion -- a number between 0 and 1 (ideally 0.25, 0.5)
%                              specifying the proportion of workers that the 
%                              parallel pool will have available.
%
% OUTPUT: 
%        none
%
% REQUIRES: 
%       Matlab's parallel computing toolbox
%
% USAGE:
%{
  open_parpool(0.5) % uses half of the physically available workers
%}
% AUTHOR: 
%         Paula Sanz-Leon, QIMR Berghofer 2019
%

    p = gcp('nocreate'); 
    % If the parpool is not empty, then deletes the current parppol and
    % opens a new one with the requested proportion of workers.
    if ~isempty(p)
        delete(p);
    end
        
    my_cluster = parcluster('local');
    parpool(round(workers_proportion*my_cluster.NumWorkers));
    
end % function open_parpool()