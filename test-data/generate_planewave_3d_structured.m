function [wave3d] = generate_planewave_3d_structured()
x = linspace(-10, 10, 21);
[X, Y, Z] = meshgrid(x, x, x);
time = linspace(0, 2, 42);
omega = 2*pi*5;

kx = 0.5;
ky = 0.5;
kz = 0.5;

kr = sqrt(kx.^2 + ky.^2 + kz.*2);
c = omega ./ kr;

A = 1.0;
wave3d(21,21,21,42) = 0;

for tt=1:length(time)
    %wave3d(:, :, :, tt) = A.* exp(1i.*(kx.*X+ky.*Y+kz.*Z - omega.*time(tt)));
    wave3d(:, :, :, tt) = A.* exp(-(kx.*X+ky.*Y+kz.*Z));
end

fig_handle = figure('Name', 'nflows-planewave3d');
tt = 1;
hstart = pcolor3(X, Y, Z, real(wave3d(:, :, :, tt)));

end % function generate_embeddedvortex_3d_structured()

