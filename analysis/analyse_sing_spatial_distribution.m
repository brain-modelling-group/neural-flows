function analyse_sing_spatial_distribution(mfile_sing, sing_labels, XYZ, num_frames)

% Dummy function to analyse the distribution of type of singularity with
% respect to one of the main orthogonal axes. 
% XYZ have to be the original grids -- not donwsampled grids
% XYZ size - npoints x 3
% sing_labels -- > struct not cell with the numeric labels

[~, cmap] = singularity3d_get_numlabel();
% figure_handle_xyz = figure('Name', 'nflows-singularities-over-spacetime');
% numsubplot = 3; % One for each spatial dimension
% ax_xyz = gobjects(numsubplot);
% 
% for jj=1:numsubplot
%     ax_xyz(jj) = subplot(numsubplot, 1, jj, 'Parent', figure_handle_xyz);
%     hold(ax_xyz(jj), 'on')
% end

% Kindda hardcoded values, but at least make it idiomatic
source_ = 1;
spiral_source_ = 3;
saddle_source  = 5;
saddle_source_ = 7;

sink_ = 2;
spiral_sink_ = 4;
saddle_sink  = 6;
saddle_sink_ = 8; 

xyz_idx = mfile_sing.xyz_idx;    

% Save x-direction
Xsource = [];
Xsink = Xsource;
Xsaddle_sink = [];
Xsaddle_source = [];

% Save y-direction
Ysource = [];
Ysink = [];
Ysaddle_sink = [];
Ysaddle_source = [];

% Save z-direction
Zsource = [];
Zsink = [];
Zsaddle_sink = [];
Zsaddle_source = [];

start_tt = 256;
        for tt=start_tt:num_frames
            xyz = xyz_idx(1, tt).xyz_idx;  
            idx_source = find(sing_labels(tt).numlabel == source_);
            idx_spiral_source = find(sing_labels(tt).numlabel == spiral_source_);
            idx_saddle_source = find(sing_labels(tt).numlabel == saddle_source);
            idx_saddle_source_ = find(sing_labels(tt).numlabel == saddle_source_);

            idx_sink = find(sing_labels(tt).numlabel == sink_);
            idx_spiral_sink = find(sing_labels(tt).numlabel == spiral_sink_);
            idx_saddle_sink = find(sing_labels(tt).numlabel == saddle_sink);
            idx_saddle_sink_ = find(sing_labels(tt).numlabel == saddle_sink_);
            % X-axis
            Xsource = [Xsource; XYZ(xyz(idx_source), 1)];
            Xsource = [Xsource; XYZ(xyz(idx_spiral_source), 1)];
            
            Xsink = [Xsink; XYZ(xyz(idx_sink),1)];
            Xsink = [Xsink; XYZ(xyz(idx_spiral_sink),1)];
            
            Xsaddle_sink = [Xsaddle_sink; XYZ(xyz(idx_saddle_sink), 1)];
            Xsaddle_sink = [Xsaddle_sink; XYZ(xyz(idx_saddle_sink_), 1)];
            
            Xsaddle_source = [Xsaddle_source; XYZ(xyz(idx_saddle_source),1)];
            Xsaddle_source = [Xsaddle_source; XYZ(xyz(idx_saddle_source_),1)];
            
            % Y-axis
            Ysource = [Ysource; XYZ(xyz(idx_source), 2)];
            Ysource = [Ysource; XYZ(xyz(idx_spiral_source), 2)];
            
            Ysink = [Ysink; XYZ(xyz(idx_sink),2)];
            Ysink = [Ysink; XYZ(xyz(idx_spiral_sink),2)];
            
            Ysaddle_sink = [Ysaddle_sink; XYZ(xyz(idx_saddle_sink), 2)];
            Ysaddle_sink = [Ysaddle_sink; XYZ(xyz(idx_saddle_sink_), 2)];
            
            Ysaddle_source = [Ysaddle_source; XYZ(xyz(idx_saddle_source),2)];
            Ysaddle_source = [Ysaddle_source; XYZ(xyz(idx_saddle_source_),2)];
            
            
            % Z-axis
            Zsource = [Zsource; XYZ(xyz(idx_source), 3)];
            Zsource = [Zsource; XYZ(xyz(idx_spiral_source), 3)];
            
            Zsink = [Zsink; XYZ(xyz(idx_sink),3)];
            Zsink = [Zsink; XYZ(xyz(idx_spiral_sink),3)];
            
            Zsaddle_sink = [Zsaddle_sink; XYZ(xyz(idx_saddle_sink), 3)];
            Zsaddle_sink = [Zsaddle_sink; XYZ(xyz(idx_saddle_sink_), 3)];
            
            Zsaddle_source = [Zsaddle_source; XYZ(xyz(idx_saddle_source),3)];
            Zsaddle_source = [Zsaddle_source; XYZ(xyz(idx_saddle_source_),3)];
            

        end
        
        
         label = [source_*ones(length(Xsource), 1); sink_*ones(length(Xsink), 1); ...
         saddle_sink*ones(length(Xsaddle_sink), 1); ...
         saddle_source*ones(length(Xsaddle_source), 1)];

     
     figure_handle = figure('Name', 'neural-flows-marginal-distributions');
     figure_handle.Color = [1,1,1];
     
     % NOTE: there is a smarter way of doing this using scatterhist. 
     % TODO: do it for the other two combinations of axes. XZ, YZ.
     scatterhist([Xsource; Xsink; Xsaddle_sink; Xsaddle_source], ...
                 [Ysource; Ysink; Ysaddle_sink; Ysaddle_source], ...
                'Group', label, 'Kernel','on','Location','SouthEast',...
                'Direction','out','Color',[cmap(source_, 1:3);  cmap(sink_, 1:3); cmap(saddle_sink_, 1:3); cmap(saddle_source_, 1:3)],'LineStyle',{'-','-','--', '--'},...
                'LineWidth',[2,2,2, 2],'Marker','..v^','MarkerSize',[10, 10, 4, 4]);

     ax = gca;
     
     ax.Children(4).Color = cmap(source_, 1:3);
     ax.Children(3).Color = cmap(sink_, 1:3);
     ax.Children(2).Color = cmap(saddle_sink_, 1:3);
     ax.Children(2).MarkerFaceColor = cmap(saddle_sink_, 1:3);

     ax.Children(1).Color = cmap(saddle_source_, 1:3);
     ax.Children(1).MarkerFaceColor = cmap(saddle_source_, 1:3);
end
