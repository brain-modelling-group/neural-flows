#-------------------------------------------------------------------------------
# Modify occording your tbb instalation path

TBB_DIR='../../extern/tbb42_20140122oss'

#win
TBB_INC_DIR=TBB_DIR+'/include'
TBB_LIB_DIR=TBB_DIR+'/lib/intel64/vc9'

#linux
#TBB_INC_DIR=TBB_DIR+'/include'
#TBB_LIB_DIR=TBB_DIR+'/lib/intel64/gcc4.4'

##mac
#TBB_INC_DIR=TBB_DIR+'/include'
#TBB_LIB_DIR=TBB_DIR+'/lib'


#-------------------------------------------------------------------------------

import os
import shutil
from distutils.core import setup, Extension
import ctypes
_64=ctypes.sizeof(ctypes.c_voidp)==8

SRC_DIR='../../src'
src_cnem2d=['C_Pnt2d.cpp','C_Vec2d.cpp','C_Cellule.cpp','C_Meshless_2d.cpp',\
            'mesh_cnem2d.cpp','scni_cnem2d.cpp','interpol_cnem2d.cpp','cnem2d_py.cpp']
for i in range(len(src_cnem2d)):
    src_cnem2d[i]=os.path.abspath(SRC_DIR+'/CNEM2D/'+src_cnem2d[i])
src_cnem2d.append(os.path.abspath(SRC_DIR+'/UTILE/utile_py.cpp'))

if os.name=='nt':
    args_0=['/EHsc','/D_CRT_SECURE_NO_WARNINGS']
    args_1=['']
elif os.name=='posix':
    args_0=['-fPIC','-m64' if _64 else '-m32']
    args_1=args_0

Nom_Module='CNEM2D'
Module=Extension(Nom_Module,
                 define_macros = [('PYTHON_VERSION', 2)],
                 include_dirs=[SRC_DIR+'/CNEM2D/',SRC_DIR+'/UTILE/',TBB_INC_DIR],
                 sources=src_cnem2d,
		 library_dirs=[TBB_LIB_DIR],
		 libraries=['tbb'],
                 extra_compile_args=args_0,
                 extra_link_args=args_1)

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
