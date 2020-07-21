function who_am_i = check_os()
% small function to check for os
if ismac
    % Code to run on Mac platform
    who_am_i = 'apple';
elseif isunix
    % Code to run on Linux platform
    who_am_i = 'penguin';
elseif ispc
    % Code to run on Windows platform
    who_am_i = 'windows';
else
    disp('Platform not supported')
end

end % check_os()