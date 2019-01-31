% case LFP or VSDI ECOG (may need interpolation)
function [activity_pattern] = generate_activity_2d_rectangular(data_type, singularity_type)

    % Singularity list for rectangular domains 
    singularity_list = {'sink', 'source', 'spiral', 'saddle'};

    if length(singularity_type.list) == 1 && strcmp(singularity_type.list, 'random')
       singularities = singularity_list{randi(length(singularity_list))};
    else
       singularities = singularity_type.list;
    end 
    
    % NOTE: The grid coordinates will be centred at half the sampling interval --
    % makes it easier for the treatment of periodic boundary conditions
    half_ds = data_type.ds / 2;

    
    % Idiomatic indexing for space
    xdim = 1;
    ydim = 2;
    % NOTE: Time starts at dt
    [x, y, t] = meshgrid((1:data_type.xyz_shape(xdim))*data_type.ds - half_ds, ...
                         (1:data_type.xyz_shape(ydim))*data_type.ds - half_ds, ...
                         (1:data_type.t_shape)*data_type.dt);
    

        
    % Check if we want a gaussian window around the singularity
    % Gaussian width parameter
    if isscalar(singularity_type.gausswidth) && singularity_type.gausswidth~=0
       c = singularity_type.gausswidth / (2*sqrt(2*log(2)));
       gaussian_handle = @(c, loc) exp(-1/(2*c^2) * (((x(:,:,1)-loc(1)).^2 + (y(:,:,1)-loc(2)).^2)));
    else
       gaussian_handle = @(c, loc) 1;
    end
             
    % Pre-allocate space; 
    activity_pattern = zeros(size(x));
    for this_singularity=1:length(singularities)
        % Angular frequency
        w = 2*pi*singularity_type.freq(this_singularity);
        % Angular wavenumber
        k = 2*pi/singularity_type.wavelength(this_singularity);
        
        % A source pattern is just a sink pattern with negative frequency
        if strcmp(singularities{this_singularity}, 'source')
           w = -w;
        end
        
        loc = singularity_type.centroids{this_singularity};

        vel = singularity_type.vel{this_singularity};
        

        switch singularities{this_singularity}
            case 'plane'
                % Plane wave
                %vel = singularity_type.vel{this_singularity}/abs(sum(vel)); % Ensure direction sums to 1
                activity_pattern = activity_pattern + exp(1i * (w*t + k*(vel(xdim)*x + vel(ydim)*y))).* gaussian_handle(c, loc).';

            case {'sink', 'source'}
                % Sink pattern
                activity_pattern = activity_pattern + exp(1i * (w*t + k*sqrt((x-loc(xdim)-vel(ydim)*t).^2 + ...
                                  (y-loc(ydim)-vel(ydim)*t).^2))) .* gaussian_handle(c, loc).';

            case 'spiral'
                % Spiral wave
                activity_pattern = activity_pattern + ...
                                   exp(1i*(-w*t + angle(x-loc(xdim)-vel(xdim)*t + 1i*(y-loc(ydim)-vel(ydim)*t))- ...
                                   k*sqrt((x-loc(xdim)-vel(xdim)*t).^2 + (y-loc(ydim)-vel(ydim)*t).^2))).* gaussian_handle(c, loc).' ;

            case 'saddle'
                % Saddle pattern
                activity_pattern = activity_pattern + exp(1i * (-w*t + k*abs(x-loc(xdim)-vel(xdim)*t) - ...
                                   k*abs(y-loc(ydim)-vel(ydim)*t))) .* gaussian_handle(c, loc).';

            otherwise
                error(['patchflow:' mfilename ':NotImplemented'], ...
                       'Unknown singularity type. Use plane, source, sink or saddle.');
        end
        
        
    end

        
end
% function generate_activity_2d_rectangular()

