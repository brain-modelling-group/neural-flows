function tstart = tik()
%% Prints string with the current date time - does not actually time execution  of programs
% 
% ARGUMENTS:
%      None
% 
% OUTPUT:
%   tstart -- a datetime string
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer December 2019
% USAGE:
%{
    tstart = tik()
    tok(tsart)

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
   tstart = string(datetime('now'));
   fprintf('%s%s\n', ['Started: ' tstart]);
end % function tik()
