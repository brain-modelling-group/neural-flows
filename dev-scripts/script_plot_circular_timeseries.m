% Should do the topo movie HERE




% For our 67x67 interpolation 
x = -33:33;
y = -33:33;

[X, Y] = meshgrid(x, y);
[I, J] = meshgrid(1:67, 1:67);
R = sqrt(X.^2 + Y.^2);
phi = linspace(0, 2*pi, 360);

% Centre of the circle
xo = 0;
yo = 0; 

% Plot contours
contoursf(x, y, my_data(:, :, 1))

% Plot lines across the origin
plot([0, 0], [-33, 33], 'k--')
plot([-33, 33], [0 0], 'k--')

% Three circles
ra = 1;
rb = 13;
rc = 21;
rd = 28;

x_ra = ra.*cos(phi);
y_ra = ra.*sin(phi);

x_rb = rb.*cos(phi);
y_rb = rb.*sin(phi);

x_rc = rc.*cos(phi);
y_rc = rc.*sin(phi);

x_rd = rd.*cos(phi);
y_rd = rd.*sin(phi);

% Plot radii
plot(x_rb, y_rb, 'w')
plot(x_rd, y_rd, 'linewidth', 15, 'color', [1 1 1 0.5])

%% Find points on a circle of given radius
outer_circle = (xo-X).^2 + (yo-Y).^2  < (1.2*5)^2;
inner_circle = (xo-X).^2 + (yo-Y).^2  < (0.8*5)^2;

ring_set = outer_circle - inner_circle;

i_loc = I(ring_set > 0);
j_loc = J(ring_set > 0);
x_loc = X(ring_set > 0);
y_loc = Y(ring_set > 0);

% Plot points we actually found. Note there has to be a better way of doing
% this
%plot(X(inCircle), Y(inCircle), 'k.')

[TH] = cart2pol(x_loc, y_loc) + pi;
TH_deg = rad2deg(TH);

% Make the range between 0 and 360 degrees
TH_deg(TH_deg<0) = TH_deg(TH_deg<0)+360;

% Sort the coordinates. There has to be a beter way to do this. 
[TH_deg, idx] = sort(TH_deg, 'ascend');

%% This should be transformed into a function - polar time series
figure
for kk=1:length(idx)
data(kk, :) = squeeze(my_data(i_loc(idx(kk)), j_loc(idx(kk)), :));
end
imagesc(t/1000, TH_deg, data)
colormap(BlueGreyRed)
caxis([-2 2])
xlim([365 366.5])
xlabel('time [s]')
ylabel('angle \phi [deg]')

%% 
data_bin =  data;
data_bin(data < 3.8) = nan;
%imagesc(t/1000, TH_deg, data_bin)
rho = (t - t(1))/1000;
%%

theta_val = [];
rho_val = [];
for tt=1:length(rho)
    
    [max_val, max_idx] = max(data_bin(:, tt));
    if max_val > 0
        theta_val = [theta_val TH_deg(max_idx)];
        rho_val   = [rho_val rho(tt)];
    end
end
%%
figure
%theta_val_q = interp1(rho_val, theta_val, rho); 
%polarplot(theta_val, rho_val, 'color', [0.6 0.6 0.6]); 
%polarplot(theta_val, rho_val, 'r.'); hold on
[xx, yy] = pol2cart(deg2rad(theta_val), rho_val);

plot(xx, yy, 'r.'); hold on
    
%% Achimeidean spiral 
%figure
a = rho_val(1:end-1);
b = rho_val(2:end);
c =  (a+b)/2;

for rr=30:30%length(theta_val)-1
    if theta_val(rr) == theta_val(rr+1)
        disp('No motion')
        continue
    else
        disp('Plot arc')
        if theta_val(rr) > theta_val(rr+1)
            theta_vec = theta_val(rr+1):0.5:theta_val(rr);
        else
            theta_vec = theta_val(rr):0.5:theta_val(rr+1);
        end
        
        polarplot(theta_vec, c(rr)*ones(length(theta_vec), 1), 'color', [0.6 0.6 0.6]);
    end
end

    