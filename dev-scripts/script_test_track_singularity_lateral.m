X = mfile_vel.X;
Y = mfile_vel.Y;

% Get colors for each singularity

num_sing = cellfun(@length, singularity_classification);

% get colors
for tt=5:200
    
    for ss=1:num_sing(tt)
     [label(tt).label(ss), color_map(tt).colormap(ss, :)] = map_str2int(singularity_classification{tt}{ss});
    
    end
end


figure_handle = figure;
ax = subplot(1,1,1);
hold(ax, 'on')
this_frame = 5;
size_marker = 100;

%ax.XLim = [min(X(:)) max(X(:))];
%ax.YLim = [min(Y(:)) max(Y(:))];
%ax.ZLim = [min(Z(:)) max(Z(:))];



for tt=this_frame+1:200
    
    for ss=1:num_sing(tt)
        
        if strcmp(singularity_classification{tt}{ss}, 'nan')
            disp('nan')          
        else
            p3_handle = scatter(ax, tt.*ones(length(xyz_idx(tt).xyz_idx(ss))), xyz_idx(tt).xyz_idx(ss), 100, color_map(tt).colormap(ss, 1:3), 'filled');

        end    
            
        
    
    end
    
 drawnow
 pause(0.1)   
end