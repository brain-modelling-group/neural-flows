% This script makes us of Rory's NeuroPatt toolbox on simulated EEG
% data projected onto 2D

% PSL -- Original -- 2018-11-16

% 0) - Load data
load('/home/paula/Work/Code/Networks/brain-waves/data/simulations/EEG_long_cd_ictime50_seg7999_outdt1_d0ms_W_coupling0.2_trial1_interp_end40s.mat', 'data_eeg_inter')
my_data = data_eeg_inter(:, :, 1:2000);
my_data(isnan(my_data)) = 0;

% 1) Create basic structure with parameters for NeuroPatt
fs = 1000; % sampling frequency of our data in Hz
eeg_params = setNeuroPattParams(fs); 

% 2) Update some of the default parameters
eeg_params.downsampleScale  = 5; % temporal downsampling
eeg_params.subtractBaseline = 1; % temporal mean subtraction gives problems with SVD
eeg_params.filterData = true;    % nope, we want all the gory details
eeg_params.useHilbert = true;
eeg_param.hilbFreqLow = 8;
eeg_params.hilbFreqHigh = 12;
eeg_params.opAlpha = 2.5;


% 3) Call main function bypassing the GUI
outputs = mainProcessingWithOutput(my_data, fs, eeg_params, [], false, true);

% Changed number of iterations to 128 (from 1000)