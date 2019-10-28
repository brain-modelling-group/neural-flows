function mfile_vel = flows3d_hs3d_flow_stats(mfile_vel, ux, uy, uz, un, this_tpt)
% Get basic info of a velocity vector field
% ARGUMENTS:
%   mfile_vel  -- an mFile handle to the file where the data will be stored 
%   ux, uy, yz -- arrays with the componentns of the velocity vector field
%   this_tpt   -- index to store the info.
% OUTPUT       
%  mfile_vel  -- an mFile handle to the file where the data will be stored 
% REQUIRES: 
%        None
%
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon, QIMR Berghofer 2018
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    mfile_vel.min_ux(1,this_tpt) = nanmin(ux(:));
    mfile_vel.max_ux(1,this_tpt) = nanmax(ux(:));

    mfile_vel.min_uy(1,this_tpt) = nanmin(uy(:));
    mfile_vel.max_uy(1,this_tpt) = nanmax(uy(:));

    mfile_vel.min_uz(1,this_tpt) = nanmin(uz(:));
    mfile_vel.max_uz(1,this_tpt) = nanmax(uz(:));

    mfile_vel.sum_ux(1, this_tpt) = nansum(ux(:));
    mfile_vel.sum_uy(1, this_tpt) = nansum(uy(:));
    mfile_vel.sum_uz(1, this_tpt) = nansum(uz(:));

    % NOTE-TO-SELF: not sure this is an important/useful metric
    uu = abs(ux(:) .* uy(:) .* uz(:));

    mfile_vel.min_uu(1, this_tpt) = nanmin(uu(:));
    mfile_vel.max_uu(1, this_tpt) = nanmax(uu(:));

    % 

    mfile_vel.min_un(1, this_tpt) = nanmin(un(:));
    mfile_vel.max_un(1, this_tpt) = nanmax(un(:));
    
end % function flows3d_hs3d_flow_stats()
