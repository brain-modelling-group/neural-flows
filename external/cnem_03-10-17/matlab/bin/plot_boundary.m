function plot_boundary(XY_Node,Nb_Node_Front,Ind_Node_Front)

j=1;
for i=1:size(Nb_Node_Front,1)
    XY_Node_Front_i=XY_Node(Ind_Node_Front([j:(j+Nb_Node_Front(i)-1)]),:);
     for k=1:Nb_Node_Front(i)
         text(XY_Node_Front_i(k,1),XY_Node_Front_i(k,2),num2str(k))
     end
     plot(XY_Node_Front_i(:,1),XY_Node_Front_i(:,2),'color','red','LineWidth',2);
    j=j+Nb_Node_Front(i);
end
