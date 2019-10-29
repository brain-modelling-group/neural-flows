% This function tries to assign a 'singularity' type to each 
% brain region 

load('513COG.mat');
locs = COG;

[x1, y1, z1] = sphere(12);

fig = figure(1);
ax = subplot(1,1,1, 'Parent', fig);
hold(ax, 'on')
alpha_radius = 15;

for nn=1:size(locs, 1)
    x = alpha_radius*x1(:)+locs(nn, 1);
    y = alpha_radius*y1(:)+locs(nn, 2);
    z = alpha_radius*z1(:)+locs(nn, 3);

    P = [x y z];
    alpha_shapes(nn).shp = alphaShape(P,15);
    plot(alpha_shapes(nn).shp)

    
end

%% 
tpts = 1;
for tt=1:tpts
    for nn=1:size(locs, 1)
 
    [in_sings(nn).innies] = inShape(alpha_shapes(nn).shp, null_points_3d(tt).x, null_points_3d(tt).y, null_points_3d(tt).z);
    
    if sum(in_sings(nn).innies) > 0
        disp('got something')
        %nn
        idx = find(in_sings(nn).innies);
        if length(idx) > 1
            [this_sng] = mode(singularity_list_num{tt}(find(in_sings(nn).innies)));
            if this_sng == 16
                in_sings(nn).innies(:) = 0;
            end
                
        else
            this_sng = singularity_list_num{tt}(idx)
        end
        %singularity_list_num{tt}(find(in_sings(nn).innies))
    end
    end
end


%%
tpts = 2048; 





num_base_sngs = 8;
num_nodes = size(locs, 1);

tracking_matrix(num_base_sngs, num_nodes, tpts) = 0;
transition_matrix(num_nodes, tpts) = 0;

for tt=1:tpts
    for nn=1:size(locs, 1)
         sings_temp = singularity_list_num{tt};
         idx = find(sings_temp < 9);
         base_sings_temp = sings_temp(idx);
         if ~isempty(idx)
             xyz_sings = [null_points_3d(tt).x(idx), null_points_3d(tt).y(idx), null_points_3d(tt).z(idx)];
             for ss=1:length(idx)
                 [~, nn_idx] = min(dis(xyz_sings(ss), locs.'));
                 tracking_matrix(base_sings_temp(ss), nn_idx, tt) = 1;
                 transition_matrix(nn_idx, tt) = base_sings_temp(ss);
             end
         end
                
    end
end
