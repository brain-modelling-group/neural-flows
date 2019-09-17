#-------------------------------------------------------------------------------
# Modify occording your tbb instalation path

TBB_DIR='/home/paula/Downloads/Software/tbb2018_20170919oss_lin/tbb2018_20170919oss';
	
	      
#win
# TBB_INC_DIR=TBB_DIR+'/include'
# #TBB_LIB_DIR=TBB_DIR+'/lib/intel64/vc9'
# TBB_LIB_DIR=TBB_DIR+'/lib/ia32/vc9'

#linux
TBB_INC_DIR=TBB_DIR+'/include'
TBB_LIB_DIR=TBB_DIR+'/lib/intel64/gcc4.7'

##mac
#TBB_INC_DIR=TBB_DIR+'/include'
#TBB_LIB_DIR=TBB_DIR+'/lib'

#-------------------------------------------------------------------------------

import os
import shutil
from distutils.core import setup, Extension
import distutils.ccompiler
compiler=distutils.ccompiler.new_compiler(verbose=1)
import ctypes
_64=ctypes.sizeof(ctypes.c_voidp)==8

if os.name=='nt':
    args_0=['/DTETLIBRARY','/EHsc','/D_CRT_SECURE_NO_WARNINGS']
    args_1=['/EHsc','/D_CRT_SECURE_NO_WARNINGS','/Od']
    args_2=['']
elif os.name=='posix':
    args_0=['-DTETLIBRARY','-fPIC','-m64' if _64 else '-m32']
    args_1=['-O0','-fPIC','-m64' if _64 else '-m32']
    args_2=['-fPIC','-m64' if _64 else '-m32']

SRC_DIR='../../src'
src_cnem3d=['C_Meshless_3d_Tri.cpp','C_Meshless_3d_DVC.cpp','C_Pnt3d.cpp',\
            'C_Meshless_3d_PntGau.cpp','Const_Top_Front.cpp','GradStabParal.cpp',\
            'C_Diag_Vor.cpp','C_Meshless_3d_C_Meshless_3d.cpp','C_Meshless_3d_ff.cpp',\
            'C_Vec3d.cpp','C_Meshless_3d_Util.cpp','C_Cellule.cpp','C_Meshless_3d_IntNoeEsc.cpp',\
            'out_elem_celqt.cpp','Group_Tet.cpp','scni_cnem3d.cpp','interpol_cnem3d.cpp','mesh_cnem3d.cpp',\
            'InterpolParal.cpp','C_Sommet.cpp','cnem3d_py.cpp']
    
for i in range(len(src_cnem3d)):
    src_cnem3d[i]=os.path.abspath(SRC_DIR+'/CNEM3D/'+src_cnem3d[i])
src_cnem3d.append(os.path.abspath(SRC_DIR+'/UTILE/utile_py.cpp'))
src_cnem3d.append(os.path.abspath(SRC_DIR+'/TETGEN/tetgen.cpp'))

obj_pred=compiler.compile([os.path.abspath(SRC_DIR+'/TETGEN/predicates.cpp')],\
                          include_dirs=[SRC_DIR+'/TETGEN/'],output_dir='temp',extra_preargs=args_1)
Nom_Module='CNEM3D'
Module=Extension(Nom_Module,
                 define_macros = [('PYTHON_VERSION', 3)],
                 include_dirs=[SRC_DIR+'/CNEM3D',SRC_DIR+'/TETGEN',SRC_DIR+'/UTILE',TBB_INC_DIR],
                 library_dirs=[TBB_LIB_DIR],
                 libraries=['tbb'],
                 extra_objects=obj_pred,
                 sources=src_cnem3d,
                 extra_compile_args=args_0,
                 extra_link_args=args_2)

setup(name=Nom_Module,ext_modules=[Module])

L=os.listdir('build')
for dir_out in L:
    if dir_out[0:3]=='lib':
        break
L=os.listdir('build/'+dir_out)
for Ext in L:
    if Ext[0:6]==Nom_Module :
        break
shutil.copyfile('build/'+dir_out+'/'+Ext,'../bin/'+Ext)

shutil.rmtree('build')
