function B=int_f_bord(XY_Noeud,Nb_Noeud_Front,IN_Front,n,f_bord_func)

B=zeros(2*n,1);

coef=sqrt(3./5.);
ff_0=(1.-coef)/2.;
ff_1=0.5;
ff_2=(1.+coef)/2.;

p_0=5./9.;
p_1=8./9.;
p_2=5./9.;
    
k=1;
for i=1:size(Nb_Noeud_Front,1)
    ind_n_a=k+Nb_Noeud_Front(i)-1;
    xy_n_a=XY_Noeud(ind_n_a,:);
    for j=1:Nb_Noeud_Front(i)
        ind_n_b=IN_Front(k);
        xy_n_b=XY_Noeud(ind_n_b,:);
        %--------------------
                               
        xy_0=xy_n_a+(xy_n_b-xy_n_a)*ff_0;
        xy_1=xy_n_a+(xy_n_b-xy_n_a)*ff_1;
        xy_2=xy_n_a+(xy_n_b-xy_n_a)*ff_2;


        V_0=f_bord_func(xy_0);
        V_1=f_bord_func(xy_1);
        V_2=f_bord_func(xy_2);

        contrib=0.5*norm(xy_n_b-xy_n_a);

        B(2*ind_n_a-1:2*ind_n_a)=B(2*ind_n_a-1:2*ind_n_a)+(V_0*(1-ff_0)*p_0+V_1*(1-ff_1)*p_1+V_2*(1-ff_2)*p_2)*contrib;
        B(2*ind_n_b-1:2*ind_n_b)=B(2*ind_n_b-1:2*ind_n_b)+(V_0*ff_0*p_0+V_1*ff_1*p_1+V_2*ff_2*p_2)*contrib; 

        %--------------------

        ind_n_a=ind_n_b;
        xy_n_a=xy_n_b; 
        k=k+1;
    end
end
