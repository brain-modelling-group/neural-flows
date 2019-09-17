function plot_cel_vc(Cel,Var)

Ind_Noeud_Cel=Cel.Ind_Noeud_Cel;
Nb_S_Cel=Cel.Nb_S_Cel;
S_Cel=Cel.S_Cel;

j=1;
for i=1:size(Ind_Noeud_Cel,1)
    J=j+Nb_S_Cel(i);
    patch(S_Cel(j:J-1,1),S_Cel(j:J-1,2),Var(Ind_Noeud_Cel(i)));
    j=J;
end
