function crange = get_quantile_crange(data)
% This trick is used throughout plotting functions to get a decent colour
% range.
%
%
% ARGUMENTS:
%        data -- generally a ND array with timeseries of some sort.
%
% OUTPUT: 
%        crange -- a [2 x 1] vector with data limits, to be used as colour limits  
%
% REQUIRES: 
%        None
%
% AUTHOR:
%        James A. Roberts, QIMR 
% USAGE:
%{
    
%}
%

%NOTE: use quantiles because MOST points lie in a relatively fixed range, 
% and min and max values can be way outside. 
if length(data)>10000 % downsampling here for speed.
   crange=quantile(data(1:100:end),[0.001 0.999]); 
else
   crange=quantile(data(1:end),[0.001 0.999]);
end

end % get_quantile_crange()
