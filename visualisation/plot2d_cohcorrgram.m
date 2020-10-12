function fig_handle = plot2d_cohcorrgram(cohcorrgram_struct)

    % TODOC:
    %figure('position',[360 748 1200 200])
    cmap = bluegred(256);
    imagesc(cohcorrgram_struct.ct, cohcorrgram_struct.cl, cohcorrgram_struct.cc)
    set(gca,'YDir','normal')
    xlabel(strcat('t [', cohcorrgram_struct.str_units, ']'))
    ylabel(strcat('lag [', cohcorrgram_struct.str_units, ']'))
    caxis([-1 1])
    colormap(cmap);
    cbar = colorbar;
    ylabel(cbar,'cc')

end % function plot2d_cohcorrgram()
