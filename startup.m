% Add neural-flows modules to path at startup, provided we are not
%  invoking the compiler(mcc) or running a deployed instance.
if ~(ismcc || isdeployed)
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Adding neural-flows folders to Matlab''s path.'))
    % Add main modules 
    addpath('io', '-begin');
    addpath('core', '-begin');
    addpath('analysis', '-begin');
    addpath('visualisation', '-begin');
    % Add ancilliary modules
    addpath('utils', '-begin');
    addpath('utils/calc', '-begin');
    addpath('utils/misc', '-begin');
    addpath('utils/signal', '-begin');
    addpath('utils/vis', '-begin');
    addpath('utils/vis/colourmaps', '-begin');
    % Add data
    addpath('demo-data', '-begin');
    % Add examples
    addpath('examples', '-begin');
    % Add external modules
    addpath(genpath('external'), '-begin');
    % Add top directory 
    addpath('../neural-flows/', '-begin');
    display_toolbox_name()
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Done!'))
end
% end of startup()