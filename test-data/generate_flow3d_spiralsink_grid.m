function [ux, uy, uz] = generate_flow_spiralsink3d_grid()

hxyz = 0.5;
max_val = 4;
x = -max_val:hxyz:max_val;

[X, Y, Z] = meshgrid(x, x, x);

R = sqrt(X.^2+Y.^2+Z.^2);

h = 5;
a = 10;
r = 1;
ux	=	((h-R)./h)*r.*cos(a.*R);
uy	=	((h-R)./h)*r.*sin(a.*R);	
uz	=	-Z/max(abs(Z(:)));


fig_handle = figure('Name', 'nflows-abcflow');
unorm = sqrt(ux.^2 + uy.^2 + uz.^2);

quiver3(X, Y, Z, ux, uy, uz)


%hcone = coneplot(X, Y, Z, ux, uy, uz, X, Y, Z, unorm);
%set(hcone,'EdgeColor','none');
%camlight right
%lighting gouraud

%hcone.DiffuseStrength = 0.8;

%slice(X, Y, Z, ux, 0, 0, 0)

end % function generate_spiralsink_3d_structured()