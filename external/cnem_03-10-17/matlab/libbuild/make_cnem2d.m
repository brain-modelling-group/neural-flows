clc;
delete *.o*

tbb_dir='F:\A\DATA\1\dev\lib\tbb41_20130314oss';

%linux
%TBB_INC_DIR =[tbb_dir '/include'];
%TBB_LIB_DIR =[tbb_dir '/lib/intel64/cc4.1.0_libc2.4_kernel2.6.16.21'];

%mac
%TBB_INC_DIR =[tbb_dir '/include'];
%TBB_LIB_DIR =[tbb_dir '/lib'];

%win
TBB_INC_DIR =[tbb_dir '/include'];
TBB_LIB_DIR =[tbb_dir '/lib/intel64/vc9'];

tbb_lib={'tbb'};

func_name='../bin/cnem2d';
src={{'../../src/CNEM2D/'} {'C_Pnt2d' 'C_Vec2d' 'C_Cellule' 'C_Meshless_2d' 'scni_cnem2d' 'interpol_cnem2d' 'mesh_cnem2d' 'gauss_cnem2d' 'cnem2d_mex'} {' -largeArrayDims -I../../src/UTILE/'}
     {'../../src/UTILE/'} {'pnt_gauss_2d'} {' -largeArrayDims'}};

lib={TBB_INC_DIR  TBB_LIB_DIR  tbb_lib};
lopt=' -largeArrayDims';
make_mex_func(func_name,src,lib,lopt)

delete *.o*