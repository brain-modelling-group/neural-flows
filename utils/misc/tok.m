function varargout = tok(tstart, time_unit, varargin)
%% Gets currrent datetime, calculates and prints elapsed time based on the input datetime string `tsart`
%  
% ARGUMENTS:
%      tsart -- a string generated with function tik()
% 
% OUTPUT:
%      Prints to screen
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

    tend = string(datetime('now'));
    

    if nargin < 2
	    time_unit = 'seconds';
	    divisor = 1;
    end

    tik_tok = etime(datevec(tend), datevec(tstart));
    
    switch time_unit
     	case {'seconds', 'sec', 's'}
     		divisor = 1;
     	case {'minutes', 'min', 'mins', 'm'}
     		divisor = 60;
     	case {'hours', 'hour', 'h', 'hr', 'hrs'}
     		divisor = 3600;
     	otherwise
     		error(['neural-flows:' mfilename ':UnknownUnits'], 'Unknown time units. Options: {"seconds", "minutes", "hours"}');

     end % switch case block
    
    if nargin < 3
        fprintf('%s%s\n', ['Finished: ' tend])
        fprintf('%s%s%s%s\n', ['Elapsed : ' string(tik_tok/divisor) ' ' time_unit]);
    else
        fprintf('\t%s%s\n', ['Finished: ' tend])
        fprintf('\t%s%s%s%s\n', ['Elapsed : ' string(tik_tok/divisor) ' ' time_unit]);
    end

    if nargout > 0
        varargout{1} = tik_tok;
    end
end % function tok()
