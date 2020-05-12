function fig_handle = plot3d_flow_frame(fig_handle, ux, uy, uz, X, Y, Z)

    if isempty(fig_handle)
        fig_handle = figure('Name', 'nflows-flow-frame');
    end

    for kk=1:4
        ax(kk) = subplot(2, 2, kk, 'Parent', fig_handle);
        ax(kk).XLabel.String = 'x';
        ax(kk).YLabel.String = 'y';
        ax(kk).ZLabel.String = 'z';
        ax(kk).View = [-37.5 30];
    end

    % Norm
    unorm = sqrt(ux.^2 + uy.^2 + uz.^2);

    hcone = coneplot(ax(1), X, Y, Z, ux, uy, uz, X, Y, Z, unorm);
    camlight right
    lighting gouraud
    hcone_ux = coneplot(ax(2), X, Y, Z, ux, uy, uz, X, Y, Z, ux);
    ax(2).Colormap = bluegred(256);
    ax(2).CLim = [-1.5 1.5];


    camlight right
    lighting gouraud
    hcone_uy = coneplot(ax(3), X, Y, Z, ux, uy, uz, X, Y, Z, uy);
    ax(3).Colormap = bluegred(256);
    ax(3).CLim = [-1.5 1.5];
    camlight right
    lighting gouraud

    hcone_uz = coneplot(ax(4), X, Y, Z, ux, uy, uz, X, Y, Z, uz);
    ax(4).Colormap = bluegred(256);
    ax(4).CLim = [-1.5 1.5];
    camlight right
    lighting gouraud

    set(hcone,'EdgeColor','none');
    set(hcone_ux,'EdgeColor','none');
    set(hcone_uy,'EdgeColor','none');
    set(hcone_uz,'EdgeColor','none');


    hcone.DiffuseStrength = 0.8;
    hcone_ux.DiffuseStrength = 0.8;
    hcone_uy.DiffuseStrength = 0.8;
    hcone_uz.DiffuseStrength = 0.8;

end % function plot3d_flow_frame()
