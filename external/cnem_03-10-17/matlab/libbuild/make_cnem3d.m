clc;
delete *.o*

tbb_dir='/home/paula/Downloads/Software/tbb2018_20170919oss_lin/tbb2018_20170919oss';
%'../../extern/tbb42_20140122oss';

%linux
TBB_INC_DIR =[tbb_dir '/include'];
TBB_LIB_DIR =[tbb_dir '/lib/intel64/gcc4.7'];%'/lib/intel64/cc4.1.0_libc2.4_kernel2.6.16.21'];

%tbb_dir='F:\A\DATA\1\dev\lib\tbb41_20130314oss';

%linux
%TBB_INC_DIR =[tbb_dir '/include'];
%TBB_LIB_DIR =[tbb_dir '/lib/intel64/cc4.1.0_libc2.4_kernel2.6.16.21'];

%mac
%TBB_INC_DIR =[tbb_dir '/include'];
%TBB_LIB_DIR =[tbb_dir '/lib'];

%win
%TBB_INC_DIR =[tbb_dir '/include'];
%TBB_LIB_DIR =[tbb_dir '/lib/intel64/vc9'];

tbb_lib={'tbb'};

func_name='../bin/cnem3d';
src={{'../../src/CNEM3D/'} {'cnem3d_mex' 'scni_cnem3d' 'interpol_cnem3d' 'mesh_cnem3d' 'C_Pnt3d' 'C_Vec3d' 'C_Sommet' 'C_Cellule'...
                         'C_Diag_Vor' 'C_Meshless_3d_DVC' 'C_Meshless_3d_C_Meshless_3d'...
                         'C_Meshless_3d_PntGau' 'C_Meshless_3d_Tri' 'Const_Top_Front' 'Group_Tet'...
                         'C_Meshless_3d_ff' 'C_Meshless_3d_IntNoeEsc' 'C_Meshless_3d_Util'...
                         'InterpolParal' 'GradStabParal' 'out_elem_celqt'} {'-DTETLIBRARY -I../../src/TETGEN/'}
     {'../../src/TETGEN/'} {'tetgen'} {'-DTETLIBRARY -DWall -DDSELF_CHECK'}
     {'../../src/TETGEN/'} {'predicates'} {'-g'}};
 

lib={TBB_INC_DIR  TBB_LIB_DIR  tbb_lib};
lopt='';
make_mex_func(func_name,src,lib,lopt)

delete *.o*