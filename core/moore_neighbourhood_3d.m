function [Mx, My, Mz] = moore_neighbourhood_3d(ii, jj, kk)
% Returns 3x3x3 matrices with the subscripts for each dimension of the
% neighbours of point located at ii, jj, kk in a 3D Moore neighbourhood. 
        
k_centre = 2;

           Mx(:, :, k_centre-1) = [ ii-1  ii   ii+1;
                                    ii-1  ii   ii+1;
                                    ii-1  ii   ii+1];
                       
           Mx(:, :, k_centre)  =  [ ii-1  ii   ii+1;
                                    ii-1  ii   ii+1;
                                    ii-1  ii   ii+1];
                       
           Mx(:, :, k_centre+1) = [ ii-1  ii   ii+1;
                                    ii-1  ii   ii+1;
                                    ii-1  ii   ii+1];
                       
                       
                       
           My(:, :, k_centre-1) =  [ jj-1  jj-1   jj-1;
                                     jj    jj     jj;
                                     jj+1  jj+1   jj+1];
                        
           My(:, :, k_centre)   =  [ jj-1  jj-1   jj-1;
                                     jj    jj     jj;
                                     jj+1  jj+1   jj+1];
                        
           My(:, :, k_centre+1) =  [ jj-1  jj-1   jj-1;
                                     jj    jj     jj;
                                     jj+1  jj+1   jj+1];
        
                                 
                        
           Mz(:, :, k_centre-1) =  [ kk-1  kk-1   kk-1;
                                     kk-1  kk-1   kk-1;
                                     kk-1  kk-1   kk-1];
                        
                                   
           Mz(:, :, k_centre)   =  [ kk    kk     kk;
                                     kk    kk     kk;
                                     kk    kk     kk];
                        
           Mz(:, :, k_centre+1) =  [ kk+1  kk+1   kk+1;
                                     kk+1  kk+1   kk+1;
                                     kk+1  kk+1   kk+1];
end   % function moore_neighbourhood_3d()
