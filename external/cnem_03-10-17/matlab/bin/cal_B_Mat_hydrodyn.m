% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function B_Th=cal_B_Mat_hydrodyn(B,Dim)
              
if Dim==2
    
    Mat_Var1_to_Var2=[1. 0. 0. 0. 0. 0. 0. 0. 0.
                      0. 1. 0. 0. 0. 0. 0. 0. 0.
                      0. 0. 0. 1. 0. 0. 0. 0. 0.
                      0. 0. 0. 0. 1. 0. 0. 0. 0.
                      0. 0. 0. 0. 0. 0. 0. 0. 1.];                  
else 
    Mat_Var1_to_Var2=[1. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 
                      0. 1. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 
                      0. 0. 1. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 
                      0. 0. 0. 0. 1. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 
                      0. 0. 0. 0. 0. 1. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 
                      0. 0. 0. 0. 0. 0. 1. 0. 0. 0. 0. 0. 0. 0. 0. 0. 
                      0. 0. 0. 0. 0. 0. 0. 0. 1. 0. 0. 0. 0. 0. 0. 0. 
                      0. 0. 0. 0. 0. 0. 0. 0. 0. 1. 0. 0. 0. 0. 0. 0. 
                      0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 1. 0. 0. 0. 0. 0. 
                      0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 0. 1.];                  
end             

B_Th=sparse_block(Mat_Var1_to_Var2,size(Mat_Var1_to_Var2,1),size(B,1)/size(Mat_Var1_to_Var2,2))*B;
