% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function B_M=cal_B_Mat_meca(B,Dim)

if Dim==2
    Mat_Var1_to_Var2=[1. 0. 0. 0. 0. 0.
                      0. 0. 0. 0. 1. 0.
                      0. 1. 0. 1. 0. 0.];                     
else
    Mat_Var1_to_Var2=[1. 0. 0. 0.  0. 0. 0. 0.  0. 0. 0. 0.
                      0. 0. 0. 0.  0. 1. 0. 0.  0. 0. 0. 0.
                      0. 0. 0. 0.  0. 0. 0. 0.  0. 0. 1. 0.
                      0. 0. 0. 0.  0. 0. 1. 0.  0. 1. 0. 0.
                      0. 0. 1. 0.  0. 0. 0. 0.  1. 0. 0. 0.
                      0. 1. 0. 0.  1. 0. 0. 0.  0. 0. 0. 0.];                
end             

B_M=sparse_block(Mat_Var1_to_Var2,size(Mat_Var1_to_Var2,1),size(B,1)/size(Mat_Var1_to_Var2,2))*B;
