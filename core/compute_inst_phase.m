function phase_y = compute_inst_phase(yp)
%% Calculate the calculate instantaneous phase of the
% timeseries at each individual nodes
% the phase is a good representation for a timeseries with a narrow
% bandwidth (eg, filtered signals)
%
% ARGUMENTS:
%          yp      -- an 2D array with dimensions T, X*Y*[Z]
%                  -- 
%
% OUTPUT: 
%          phase_y -- a 2D array of size time x nodes with instantaneous
%          unwrapped phases
%
% REQUIRES: 
%          None
%
% USAGE:
%{     
    phase_y =  compute_inst_phase(yp)

%}
%
% MODIFICATION HISTORY:
%     JA Roberts, QIMR Berghofer, 2018
%     P  Sanz-Leon, QIMR Berghofer, 2018
%
% PERFORMANCE:
% 
% Memory efficient version with:
% -> FOR loop ~ takes about 40s for yp of size 400001 x 513 @dracarys
% -> PARFOR loop ~ takes about 11s for yp of size 400001 x 513 @dracarys -
%    (12 workers)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp('Calculating node phases ...')

if length(yp)<100000
    % Short but inefficient with memory if yp is large  
    
    % Check version. If version > 2017, then implicit expansion exists
    this_version = version('-release');
   
    if str2double(this_version(1:4)) > 2016  
        % If using matlab 2016b or older this can be done directly as:
        phase_y = unwrap(angle(hilbert((yp - mean(yp))))); % faser than bsxfun
    else
        phase_y = unwrap(angle(hilbert(bsxfun(@minus,yp,mean(yp)))));
          
    end
    fprintf('Done. \n')
else
    
    phase_y = zeros(size(yp));
    nn      = size(yp,2);
    tic
    for jj=1:nn % NOTE: this could be done using parfor
        y=yp(:,jj);
        phase_y(:,jj)=unwrap(angle(hilbert(y-mean(y))));
    end
    toc
    fprintf('Done. \n')    
end