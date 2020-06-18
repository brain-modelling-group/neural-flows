function ke  = kinetic_energy(v, varargin)

if nargin < 2
	m = 1.0; % mass is 1
end
% E = (1/2)*m*v^2
    ke = 0.5.*m.*v.^2;	
end % function kinetic_energy()