call "%VS90COMNTOOLS%vsvars32.bat"
cl /c ../../src/CNEM3D/main_tetgen_exe.cpp /DTETLIBRARY /I../../src/TETGEN/ /EHsc
cl /c ../../src/TETGEN/predicates.cpp /Od /EHsc
cl /c ../../src/TETGEN/tetgen.cpp -DTETLIBRARY /I../../src/TETGEN/ /EHsc
cl /Fe../bin/tet predicates.obj tetgen.obj main_tetgen_exe.obj /EHsc

