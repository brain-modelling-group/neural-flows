function MFP = find_fastest_routes(mobj)
% mobj is either a matfile or a struct with similar fields
% Returns instantaneous modal fastest speed.


% AUTHORS: 
% Paula Sanz-Leon, QIMR October 2019
% Pierpaolo Sorrentino, QIMR, October 2019


try 
    tpts = size(mfile_obj, 'ux', 4); %#ok<GTARG>
catch 
    tpts = size(mobj.ux, 4);
end

% Load cogs
in1 = load('locs_90_rois.mat');
locs = in1.locs;

% This should be calculated during the flow estimation
in2 = load('locs_idx_42x36x33_grid_hxyz_4mm.mat');
locs_idx_grid = in2.locs_idx_grid;
locs_idx_mask = in2.locs_idx_mask;

% This should be corrected during the flow calculation.
in3 = load('fake_in_bdy_mask_42x36x33_grid_hxyz_4mm.mat');
in_bdy_mask = in3.in_bdy_mask;

% Matrix stack
nnodes = size(locs, 1);
MFP(nnodes, nnodes, tpts) = 0;

X = mobj.X;
Y = mobj.Y;
Z = mobj.Z;

% NOTE: without the parfor, this is excruciatingly slow ... about 1.5h to
% process 1024 samples.

parfor tt=1:tpts
    % Get current frame
    uu = sqrt(mobj.ux(:, :, :, tt).^2 + mobj.uy(:, :, :, tt).^2 + mobj.uz(:, :, :, tt).^2);
    speeds = uu(in_bdy_mask);
    [~, W] = build_velocity_graph(X, Y, Z, locs_idx_grid, locs_idx_mask, in_bdy_mask, speeds);
    %[~, W] = build_velocity_graph_weights(X, Y, Z, locs_idx_grid, locs_idx_mask, in_bdy_mask, speeds);
    [spaths, ~] = find_fastest_path(W, locs_idx_mask, nnodes);
    msp = calculate_modal_path_speed(spaths, in_bdy_mask, uu);
    MFP(:, :, tt) = msp; 
end


end % function find_fastest_routes()