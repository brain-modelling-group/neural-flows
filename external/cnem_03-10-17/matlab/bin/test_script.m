load('/home/paula/Work/Code/Networks/brain-waves/data/513COG.mat')
shpalpha = 30; % alpha radius; may need tweaking depending on geometry (of cortex?)
shp = alphaShape(COG, shpalpha);
bdy = shp.boundaryFacets;
Type_FF   = 0;% 0 -> Sibson, 1 -> Laplace, 2 -> Linear fem
Sup_NN_GS = 0;%

% tet needs to be in your system's PATH variable, does not work to 
% set it in matlab
% or make it executable

%setenv('PATH', ['/home/paula/Work/Code/Networks/neural-flows/external/cnem_03-10-17/matlab/bin:' getenv('PATH')]);
%export PATH=/home/paula/Work/Code/Networks/neural-flows/external/cnem_03-10-17/matlab/bin:$PATH
[GS,XYZ,IN_Tri_Ini,IN_Tri,IN_Tet,INV_NN,PNV_NN,IN_New_Old,IN_Old_New] = m_cnem3d_scni(COG, bdy, Type_FF, Sup_NN_GS);
