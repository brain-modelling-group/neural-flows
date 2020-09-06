function varargout = tok(tstart, time_unit)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

    tend = string(datetime('now'));
    fprintf('%s%s\n', ['Finished: ' tend])
  
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
    
    fprintf('%s%s%s%s\n', ['Elapsed time: ' string(tik_tok/divisor) ' ' time_unit]);
    if nargout > 0
        varargout{1} = tik_tok;
    end
end % function tok()
