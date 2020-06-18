function ke  = kinetic_eenrgy(v, varargin)

if nargin < 2,
	m = 1.0; % mass is 1
end
% E = (1/2)*m*v^2
    ke = 0.5.*m.*(Fx.^2 + Fy.^2 + Fz.^2).^2;	
end % function kinetic_energy()