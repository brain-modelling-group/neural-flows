% Two waves

w1 = 2*pi*1;
w2 = 2*pi*5;
k1x = 2*pi*4;
k1y = 2*pi*4;
k2x = 2*pi*2.2;
k2y = 2*pi*2.2;

k2 = sqrt(k2x.^2 + k2y.^2);
k1 = sqrt(k1x.^2 + k1y.^2);

vp = w1 ./ k1;
vg = (w2-w1) / (k2-k1);

 
[x, y, t] = meshgrid(0:0.02:2, 0:0.02:2, 0:0.02:10);
u = cos(w1.*t-k1x.*x+k1y.*y);
v = cos(w2.*t-k2x.*x+k2y.*y);
wv = u+v;
imagesc(wv(:, :, 2))
figure
plot(squeeze(wv(25, :, 1)))

figure
plot(squeeze(wv(50, 50, :)))


time = t(1,1,:);


y = hilbert(wv);
env = abs(y);
%%
for tt =1:length(time)
imagesc(env(40:50, 40:50, tt))
%imagesc(wv(:, :, tt))

drawnow
pause(0.1)
end

%%


data = permute(wv, [3 1 2]);
data = reshape(data, 501, 101*101);
phi = calculate_insta_phase(data);
phi = reshape(phi, 501, 101, 101);

phi = permute(phi, [2 3 1]);

figure
plot(squeeze(phi(25, :, 1)))

figure
plot(squeeze(phi(50, 50, :)))



%%

y = hilbert(wv);
env = abs(y);

plot(unwrap(angle(hilbert(squeeze(real(y(50,50,:)))))))


fl1 = 30;
[up1,lo1] = envelope(squeeze(wv(50,50,:)), fl1,'analytic');


