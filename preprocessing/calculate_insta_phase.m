%% Calculate the calculate instantaneous phase of the
% timeseries at each individual nodes 
%
% ARGUMENTS:
%          data    --  a 2D array of size [time x nodes/locs/channels/vertices] with activity
%
% OUTPUT: 
%          phi     --  a 2D array of size [time x nodes/locs/channels/vertices] 
%                      with instantaneous unwrapped phases (of the signal's envelope).
%
% REQUIRES: 
%          none.
%
% USAGE:
%{     
    phase_data =  calculate_insta_phase(data)

%}
%
% MODIFICATION HISTORY:
%     James A Roberts, QIMR Berghofer, 2018
%     Paula Sanz-Leon, QIMR Berghofer, 2019 - use explicit expansion and
%                                             parfor if available
% PERFORMANCE:
% Memory efficient version with:
% -> FOR loop ~ takes about 40s for data of size 400001 x 513 @dracarys
% -> PARFOR loop ~ takes about 11s for data of size 400001 x 513 @dracarys -
%    (12 workers)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function phi = calculate_insta_phase(data)

fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Calculating instantaneous phases.'))

if length(data) < 100000 % arbitrary biggish number
    this_version = version('-release');
   
    if str2double(this_version(1:4)) > 2016  
        % If using matlab 2016b or older this can be done directly as:
        phi = unwrap(angle(hilbert((data - mean(data))))); % faster than bsxfun
        %phi = (angle(hilbert((data - mean(data))))); % faster than bsxfun

    else
        phi = unwrap(angle(hilbert(bsxfun(@minus,data,mean(data)))));
          
    end
    
else
    % Memory efficient ~ takes about 40s for a data of size [400001 x 513]
    % on a Dell Precision Tower 5820 circa 2017.
    phi(size(data, 1), size(data, 2)) = 0;
    nn = size(data, 2);
    try
        parfor jj=1:nn
            phi(:, jj) = unwrap(angle(hilbert(data(:, jj) - mean(data(:, jj)))));
        end
    catch
        for jj=1:nn
            phi(:, jj) = unwrap(angle(hilbert(data(:, jj) - mean(data(:, jj)))));
        end
        
    end  
end
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished calculating phases.'))
end % function calculate_insta_phase()
