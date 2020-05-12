function [ux, uy, uz, X, Y, Z] = generate_singularity3d_hyperbolic_critical_points(cp_type)
% Generate 8 canonical hyperbolic 3D critical points in a grid of side 2 in the
% range of [-1 1];
%
% ARGUMENTS:
%        cp_type -- a string specifying the type of hyperbolic critical
%                   point. Options: {'source', ...
%                                    'sink', ...
%                                    '2-1-saddle', 
%                                    '1-2-saddle', ...
%                                    'spiral-sink', 
%                                    'spiral-source', ...
%                                    '2-1-spiral-saddle', 
%                                    '1-2-spiral-saddle',
%                                    'all'}
%       
%
% OUTPUT: 
%        ux -- 3D array with the x component of the vector field
%        uy -- 3D array with the y component of the vector field
%        uz -- 3D array with the z component of the vector field
%        X, Y, Z -- 3D arrays with the grid of the space where fields are defined 
%
% REQUIRES: 
%        None
% USAGE:
%{
    
%}
% AUTHOR: Paula Sanz-Leon, QIMR September 2019 

x = -1:2^-4:1;
y = -1:2^-4:1;
z = -1:2^-4:1;

[X, Y, Z] = meshgrid(x, y, z);

switch cp_type
    case {'source'}
        ux = X;
        uy = Y;
        uz = Z;
        
        p1 = [0.01 0.01  0.1];
        p2 = [0.01 0.01 -0.1];
                
    case {'sink'}
        ux = -X;
        uy = -Y;
        uz = -Z;
        
        p1 = [ 0.5  0.5  0.5];
        p2 = [-0.5 -0.5 -0.5];
            
    case {'2-1-saddle'}
        % 2-in-1-out
        TH = atan2(Y, X);
        R = sqrt(X.^2+Y.^2);
        ux = -R.* cos(TH);
        uy = -R.* sin(TH);
        uz = Z;
        
        p1 = [  0.5  0.8  0.1];
        p2 = [ -0.5  -0.8 -0.1];
        
    case {'1-2-saddle'}
        % 1-in-2-out
        TH = atan2(Y, X);
        R = sqrt(X.^2+Y.^2);
        ux = R.* cos(TH);
        uy = R.* sin(TH);
        uz = -Z;
        
        p1 = [ 0.1   0.1  1];
        p2 = [ 0.1  -0.1 -1];
           
    case {'spiral-sink'}
        ux =  Y-X;
        uy = -X-Y;
        uz = -2*Z;
        
        p1 = [-0.5, -0.5,  0.9];
        p2 = [-0.5,  0.8, -0.9];
        
    case {'spiral-source'}
        
        %NOTE: I'm not sure this critical point is entirely correct, as it 
        % basically becomes a limit cycle - centre 
        
        [ux, uy, uz] = spiral_source();
        uz = 3.5.*uz;
        % Seed xyz points for sample trajectory
        p1 = [0.0, -0.01, -0.01];
        p2 = [0.0,  0.01, +0.01];
 
    case {'2-1-spiral-saddle'}
        % 2-in-1-out
        [ux, uy, uz] = spiral_source();
        ux = -ux;
        uy = -uy;
 
        p1 = [ 0.5, -0.5,  0.05];
        p2 = [-0.5, -0.5, -0.05];
        
    case {'1-2-spiral-saddle'}
        % Source Spiral saddle - 1-in-2-out 
        [ux, uy, uz] = spiral_source();
        uz = -uz;
        
        p1 = [0.01, 0.01,  0.5];
        p2 = [0.01, 0.01, -0.5];
    case 'all'
        singularity_list = s3d_get_singularity_list();
        for kk=1:8
            generate_singularity3d_hyperbolic_critical_points(singularity_list{kk});
        end
        return
    otherwise
        error(['neural-flows::' mfilename '::UnknownCase'], 'Unknown type of critical points. Check docs to see types available.')

end

function [ux, uy, uz] = spiral_source()
        a = 0.2;
        b = 0.5;
        ux =  a*Y-(a.*abs(z)).*X;
        uy = -a*X-(a.*abs(z)).*Y;
        uz = -((b*Z)); %zeros(size(Z));
        uz(isnan(uz)) = 0;
        
        ux = -ux;
        uy = -uy;
        UV = sqrt(ux.^2 + uy.^2);
        ux = ux./UV; % This normalisation is basically for visaulisation purposes
        uy = uy./UV;
        ux(isnan(ux)) = 0; 
        uy(isnan(uy)) = 0;
        uz = -uz;
end
end
