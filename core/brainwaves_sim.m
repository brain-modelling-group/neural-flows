% solve neural mass model
% uses the Brain Dynamics Toolbox v2017c
% ensure bdtoolkit and bdtoolkit/models are on the MATLAB path

% assumes connectivity matrix normW is in the workspace

sys=BTF2003DDE(normW);

nnodes=size(normW,1);

% coupling parameters
coupling=0.6;
delay=1; % in ms
sys.pardef=bdSetValue(sys.pardef,'C',coupling); % Global coupling strength
sys.lagdef=bdSetValue(sys.lagdef,'d',delay); % delay (in ms) between all connections

% parameters of each local neural mass
sys.pardef=bdSetValue(sys.pardef,'a',[0.36 2 2 1 0.4]); % Within-node connection weights [aee, aei, aie, ane, ani] 
sys.pardef=bdSetValue(sys.pardef,'b',0.1); % Rate constant for inhibitory dynamics
sys.pardef=bdSetValue(sys.pardef,'r',0.25); % Relative contribution of NMDA versus AMPA receptors
sys.pardef=bdSetValue(sys.pardef,'phi',0.7); % Rate constant for potassium dynamics
sys.pardef=bdSetValue(sys.pardef,'gion',[1 2 6.7 0.5]); % Ion Conductances [gCa, gK, gNa, gL]
sys.pardef=bdSetValue(sys.pardef,'Vion',[1 -0.7 0.53 -0.5]); % Nernst Potential [VCa, VK, VNa, VL]
sys.pardef=bdSetValue(sys.pardef,'thrsh',[0 0 -0.01 0 0.3]); % Firing threshold [VT, ZT, TCa, TK, TNa]
sys.pardef=bdSetValue(sys.pardef,'delta',[0.65 0.65 0.15 0.3 0.15]); % Firing fun slope [deltaV, deltaZ, deltaCa, deltaK, deltaNa]
sys.pardef=bdSetValue(sys.pardef,'I',0.3); % Mean nonspecific input strength

% initial conditions (assumed constant)
randvec=rand(nnodes,1);
sys.vardef = [ struct('name','V', 'value',(randvec-0.5)*0.8-0.2);      % Mean firing rate of excitatory cells
               struct('name','W', 'value',(randvec-0.5)*0.6+0.3);      % Proportion of open K channels
               struct('name','Z', 'value',(randvec-0.5)*0.16+0.05) ];  % Mean firing rate of inhibitory cells

% solve
tspan = [0 1000];                  % integration time domain (in ms)
sys.ddesolver = {@dde23a};         % solver (dde23a can be faster than dde23 for large networks)
sol = bdSolve(sys,tspan);          % call the solver
tplot = 0:1:tspan(end);            % time domain of interest
V = bdEval(sol,tplot,(1:nnodes)).';% extract/interpolate the solution
figure, plot(tplot,V);             % plot the result
xlabel('t (ms)'); ylabel('V');

