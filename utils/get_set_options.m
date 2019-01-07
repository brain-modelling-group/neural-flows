function [v, varargout] = get_set_options(options, fieldname, v)
% getoptions - gets a value of options.fieldname value
%
% v = getoptions(options, 'thisfield', v0);
% is equivalent to:
%   if isfield(options, 'thisfield')
%       v = options.thisfield;
%   else
%       v = v0;
%       options.thisfield=v0;
%   end
%
% Paula QIMR 2019
% NOTE: probably better to have get and a set functions separately

if nargin < 3
    error('Not enough arguments.');
end

if isfield(options, fieldname)
    v = eval(['options.' fieldname ';']);
end

% If the field did not exist before, the function creates it and assigns
% the value passed as input argument.
eval(['options.' name ' = v;']);
varargout{1} = options;
end