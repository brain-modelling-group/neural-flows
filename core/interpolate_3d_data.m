function interpolate_3d_data(data, locs, X, Y, Z, in_bdy_mask)
% This is a wrapper function for scattered interpolant. We can interpolate
% each frame independtly using parfor and save the interpolated data for 
% later use with optical flow and then just delete the interpolated data
% or offer to keep it.

%  locs: locations of known data
%  data: scatter data known at locs of size tpts x nodes
% X, Y Z -- grid points to get interpolation out

% This is the key step for the optical flow method to work
% These parameters are eesential

neighbour_method = 'natural';
extrapolation_method = 'none';


% Frame A

x_dim = 1;
y_dim = 2;
z_dim = 3;


mfile_object = matfile('temp_file_interpolated_data.mat','Writable', true);

mfile_object.data(size(X, x_dim), size(Y, y_dim), size(Z, z_dim), tpts) = 0;

temp_data = nan(size(X));

for this_tpt=1:tpts
    
    data_interpolant = scatteredInterpolant(locs(1:end, x_dim), ...
                                            locs(1:end, y_dim), ...
                                            locs(1:end, z_dim), ...
                                            data(this_tpt, :).', ...
                                            neighbour_method, ...
                                            extrapolation_method);

    temp_data(in_bdy_mask) = data_interpolant(X(in_bdy_mask).', Y(in_bdy_mask).', Z(in_bdy_mask).');
    
    % Only get 
    mfile_object.data(:, :, :, this_tpt) = temp_data;

end

end
