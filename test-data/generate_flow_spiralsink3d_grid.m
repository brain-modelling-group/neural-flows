function [ux, uy, uz] = generate_flow_spiralsink3d_grid()

x = linspace(-5, 5, 43);
[X, Y, Z] = meshgrid(x, x, x);

R = sqrt(X.^2+Y.^2+Z.^2);

h = 5;
a = 10;
r = 1;
ux	=	((h-R)./h)*r.*cos(a.*R);
uy	=	((h-R)./h)*r.*sin(a.*R);	
uz	=	-Z;

end % function generate_spiralsink_3d_structured()