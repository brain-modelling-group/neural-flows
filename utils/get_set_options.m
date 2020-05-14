function [v, varargout] = get_set_options(options, fieldname, v)
% getoptions - gets a value of options.fieldname value
%
% v = get_set_options(options, 'thisfield', v0);
% is equivalent to:
%   if isfield(options, 'thisfield') % get
%       v = options.thisfield;
%   else
%       v = v0;
%       options.thisfield=v0;         % set
%   end
%
% Paula QIMR 2019
% NOTE: probably better to have get and a set functions separately

if nargin < 3
    error('Not enough arguments.');
end

if isfield(options, fieldname)
    v = eval(['options.' fieldname ';']);
    return
end

% If the field did not exist before, the function creates it and assigns
% the value passed as input argument.
eval(['options.' fieldname ' = v;']);
varargout{1} = options;
end % function get_set_options()