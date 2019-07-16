%% Calculate the calculate instantaneous phase of the
% timeseries at each individual nodes 
%
% ARGUMENTS:
%          data    --  a 2D array of size [time x nodes/locs/channels/vertices] with activity
%
% OUTPUT: 
%          phi     --  a 2D array of size [time x nodes/locs/channels/vertices] 
%                      with instantaneous unwrapped phases.
%
% REQUIRES: 
%
% USAGE:
%{     
    phase_data =  calculate_insta_phase(data)

%}
%
% MODIFICATION HISTORY:
%     JA Roberts, QIMR Berghofer, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function phi = calculate_insta_phase(data)


disp('Calculating node phases...')

if length(data) < 100000 % arbitrary biggish number
    % short but inefficient with memory
    % calculate phase
    %phase_y = unwrap(angle(hilbert(bsxfun(@minus,yp,mean(yp)))));
    % If using matlab 2016b or older this can be done directly as:
     phi = unwrap(angle(hilbert((data - mean(data))))); % faster than bsxfun
    
    fprintf('Done. \n')
    toc
else
    % Memory efficient ~ takes about 40s for a yp in 400001 x 513 @dracarys
    tic
    phi = zeros(size(data));
    nn      = size(yp,2);
    for jj=1:nn
        y=data(:,jj);
        phi(:,jj)=unwrap(angle(hilbert(y-mean(y))));
    end
    fprintf('Done. \n')
    toc
    
end
end % function calculate_insta_phase()