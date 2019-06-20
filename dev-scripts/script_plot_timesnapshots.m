% Plot some metastable states from brainwaves paper. 


%in1 W_c1_d1ms_trial1.mat
in1 = load('/home/paula/Work/Code/Networks/brain-waves/data/simulations/W_c1_d1ms_trial1.mat');

travelling_wave_st = 2704;
rotating_wave_st   = 10500;
sink_sources_st    = 5264;
rotating_sink_st   = 75400; 

% Take 100 samples from the start;
period_samples = 200;

travelling_wave    = standardise_range(in1.nodes(travelling_wave_st:travelling_wave_st+period_samples, :), [-1 1]);
rotating_wave      = standardise_range(in1.nodes(rotating_wave_st:rotating_wave_st+period_samples, :), [-1 1]);
sink_sources_wave  = standardise_range(in1.nodes(sink_sources_st:sink_sources_st+period_samples, :), [-1 1]);
rotating_sink_wave = standardise_range(in1.nodes(rotating_sink_st:rotating_sink_st+period_samples, :), [-1 1]);

%% 
% data = [travelling_wave;  rotating_wave; sink_sources_wave; rotating_sink_wave];
%timepoints=[1 102 203 304]; 

data = [travelling_wave];
timepoints = [150];


%%
figure('color','w')
set(gcf,'position',[680   678-(550-420)   800   550])
labelopts ={'fontsize',10,'fontweight','bold','horizontalalignment','center'};
letters   ={'a','b','c','d','e','f','g','h','i','j','k','l'};
sphereax=axes('position',[0.01 0 0.9 1]);

cmap = bluered(256);
frameopts=struct('nframes',27,'dframe',1);
spacingopts=struct('spacing',500,'frameoffx',90,'frameoffy',130);
spheres_framestack(sphereax,data,timepoints,frameopts,spacingopts, cmap)

for j=1:length(timepoints)
    text(sphereax,(j-1)*spacingopts.spacing+(frameopts.nframes-2.5)*spacingopts.frameoffx,...
         (frameopts.nframes-0.5)*spacingopts.frameoffy,letters{j},labelopts{:});
end


%%
save('metastable_patterns_W_c1_d1ms_trial1', 'travelling_wave', 'rotating_wave', 'sink_sources_wave', 'rotating_sink_wave')