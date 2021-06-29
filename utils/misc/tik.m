function tstart = tik(varargin)
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
% TODO: generalise so as input argument we pass a number of \n and or \t,
% that is a sequence of string formatters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
   tstart = string(datetime('now'));
   if nargin < 1
      fprintf('\n%s%s\n', ['Started: ' tstart]);
   else
      fprintf('\n\t%s%s\n', ['Started: ' tstart]);
   end
end % function tik()
