function f=f_bord_func(xy)

eps=1.e-9;

f=[0.
   0.];

if abs(xy(2)-1.)<eps
    
    f=[0.
       1.e5*xy(1)];
end


