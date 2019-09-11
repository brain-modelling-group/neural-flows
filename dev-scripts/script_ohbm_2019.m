load('/home/paula/Work/Code/Networks/brain-waves/data/simulations/EEG_long_cd_ictime50_seg7999_outdt1_d0ms_W_coupling0.2_trial1_interp_end40s.mat')

mask = isnan(data_eeg_inter(:, :, 1));
mask_data = double(~mask);
bad_electrodes = find(mask);


%% 
n = 67;
options.bound = 'sym';

v = randn(n,n,2);
v = perform_blurring(v,50);
v = v.*mask_data;
%%
% compute the Hodge decomposition
[v1,v2, U] = compute_hodge_decompositon(v,options);

v1 = v1.*mask_data;
v2 = v2.*mask_data;

U = U.* mask_data;

%% display
options.subsampling = 1;
options.display_streamlines = 0;
options.normalize_flow = 2;
options.display_arrows = 1;
options.lgd = { 'Neural flow field' 'Irrotational component' 'Incompressible component'  };
%%
plot_vf( {v v1 v2}, [], options );

%%
figure
subplot(2,2,1)
imagesc(sqrt(v(:, :, 1).^2+v(:, :, 2).^2))

%%
subplot(2,2,2)
imagesc(sqrt(v1(:, :, 1).^2+v1(:, :, 2).^2))

%%
subplot(2,2,3)
imagesc(sqrt(v2(:, :, 1).^2+v2(:, :, 2).^2))

subplot(2,2,4)
h=imagesc(U);
set(h, 'AlphaData', mask_data) 

colormap(BlueGreyRed)

%% Run neuropatt


% 0) - Load data
my_data = data_eeg_inter(:, :, 1:4000);
my_data(isnan(my_data)) = 0;

my_data = bsxfun(@times,my_data, mask_data);

% 1) Create basic structure with parameters for NeuroPatt
fs = 1000; % sampling frequency of our data in Hz
eeg_params = setNeuroPattParams(fs); 

% 2) Update some of the default parameters
eeg_params.downsampleScale  = 5; % temporal downsampling
eeg_params.subtractBaseline = 0; % temporal mean subtraction gives problems with SVD
eeg_params.filterData = true;    %
eeg_params.useHilbert = true;
eeg_param.hilbFreqLow = 8;
eeg_params.hilbFreqHigh = 12;
eeg_params.opAlpha = 2.5;


% 3) Call main function bypassing the GUI
outputs = mainProcessingWithOutput(my_data, fs, eeg_params, [], false, true);

% Changed number of iterations to 128 (from 1000)

%%

vx = real(outputs.velocityFields);
vy = imag(outputs.velocityFields);

%%


T = 3999;
for tt=1:T
    v = zeros(67,67,2);
    v(:, :, 1) = vx(:, :, ii).*mask_data;
    v(:, :, 2) = vy(:, :, ii).*mask_data;
    % compute the Hodge decomposition
    [v1,v2, U] = compute_hodge_decompositon(v,options);

    V1(:, :, :, tt) = bsxfun(@times,v1, mask_data);
    V2(:, :, :, tt) = bsxfun(@times,v2, mask_data);

    U(:, :, :, tt) = bsxfun(@times,U, mask_data);
end

%%
for ii=1
    v(:, :, 1) = vx(:, :, ii).*mask_data;
    v(:, :, 2) = vy(:, :, ii).*mask_data;
    plot_vf( {v,  V1(:, :, :, 1),  V2(:, :, :, 1)}, [], options );

end
%%
fig_handle= gcf;
ax = fig_handle.Children;

quiv_handle_1 = ax(1).Children(1);
quiv_handle_2 = ax(2).Children(1);
quiv_handle_3 = ax(3).Children(1);


%%
[X,Y] = meshgrid(1:67,1:67);
%%
for ii=1:T
    set(quiv_handle_3, 'UData', 10*squeeze(vx(:, :, ii)).*mask_data, 'VData', 10*squeeze(vy(:, :, ii)).*mask_data)
    set(quiv_handle_2, 'UData', 100*squeeze(V1(:, :, 1, ii)).*mask_data, 'VData', 100*squeeze(V1(:, :, 2, ii)).*mask_data)
    set(quiv_handle_1, 'UData', 100*squeeze(V2(:, :, 1, ii)).*mask_data, 'VData', 100*squeeze(V2(:, :, 2, ii)).*mask_data)


    pause(0.1)
    TheMovie(1,ii) = getframe(fig_handle);
end

%% Write movie to file
videoname = 'neural_flows_eeg_HHD_d1ms_coupling_0-6';

v = VideoWriter([ videoname '.avi']);
v.FrameRate = 10;

open(v);
for kk=1:size(TheMovie,2)
   writeVideo(v,TheMovie(1, kk)) 
end
close(v)

%% Energy metrics


EV2 = squeeze(0.5*(sqrt(V2(:, :, 1, :).^2 + V2(:, :, 2, :).^2)).^2);

EV1 = squeeze(0.5*(sqrt(V1(:, :, 1, :).^2 + V1(:, :, 2, :).^2)).^2);

figure

subplot(121)
h1 = imagesc(EV1(:, :, 1));
subplot(122)
h2=imagesc(EV2(:, :, 1));

%%
for ii=1:T
    set(h1, 'CData', EV1(:, :, 1), 'AlphaData', mask_data)
    set(h2, 'CData', EV2(:, :, 1), 'AlphaData', mask_data)
    pause(0.1)
    %TheMovie(1,ii) = getframe(fig_handle);
end

%%
%% Flow
for ii=1
    h1 = streakarrow(X, Y, vx(:, :, 1).*mask_data,  vy(:, :, 1).*mask_data, 1.5, 1); 
end

im_h = imagesc(sqrt(vx(:, :, 1).^2+vy(:, :, 1).^2));
im_mask = imagesc(mask_data);


%% 
figure(33)
for ii=1
    h2 = streakarrow(X, Y, V1(:, :, 1,  1).*mask_data,  V1(:, :, 2, 1).*mask_data, 1.5, 1); 
end

im_h = imagesc(sqrt(V1(:, :, 1, 1).^2+V1(:, :, 2, 1).^2));
set(im_h, 'AlphaData', ~mask_data)
im_mask = imagesc(mask_data);
set(im_mask, 'AlphaData', ~mask_data)

%%
figure(34)
for ii=1
    h2 = streakarrow(X, Y, V2(:, :, 1,  1).*mask_data,  V2(:, :, 2, 1).*mask_data, 1.5, 1); 
end

im_h = imagesc(sqrt(V2(:, :, 1, 1).^2+V2(:, :, 2, 1).^2));
set(im_h, 'AlphaData', ~mask_data)
im_mask = imagesc(mask_data);
set(im_mask, 'AlphaData', ~mask_data)
