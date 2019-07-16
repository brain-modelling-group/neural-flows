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
%     Paula Sanz-Leon, QIMR Berghofer 2019 - use explicit expansion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function phi = calculate_insta_phase(data)

disp('Calculating instantaneous phases ...')

if length(data) < 100000 % arbitrary biggish number
    % short but inefficient with memory
    % calculate phase
    % If using matlab 2016b or older this can be done directly as:
    phi = unwrap(angle(hilbert((data - mean(data))))); % faster than bsxfun
    
else
    % Memory efficient ~ takes about 40s for a data of size [400001 x 513]
    % on a Dell Precision Tower 5820 circa 2017.
    phi(size(data)) = 0;
    nn = size(data, 2);
    for jj=1:nn
        y = data(:, jj);
        phi(:, jj) = unwrap(angle(hilbert(y - mean(y))));
    end
    fprintf('Done. \n')
    
end
end % function calculate_insta_phase()
