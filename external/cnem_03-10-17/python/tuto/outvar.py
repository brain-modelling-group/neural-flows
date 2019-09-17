##
## Copyright (C) 2003-2011
## Lounes ILLOUL (illoul_lounes@yahoo.fr)
## Philippe LORONG (philippe.lorong@ensam.eu)
## Arts et Metiers ParisTech, Paris, France
##
## $Revision$ - $Date$

ls='\n'
def vtk(XYZ,Elem,Field,Vec,inc):
    
    File=open('var_'+str(inc)+'.vtk','w')
    File.write('# vtk DataFile Version 2.0\nVar \nASCII'+ls)
    File.write('DATASET UNSTRUCTURED_GRID'+ls)

    Nb_Noeud_Elem=XYZ.shape[0]
    Nb_Elem=Elem.shape[0]
    Size_Elem=Elem.shape[1]
    dim=2 if (XYZ.shape[1]==2) else 3
    
    File.write('POINTS '+str(Nb_Noeud_Elem)+' double'+ls)
    for i in range(Nb_Noeud_Elem):
        File.write(str(XYZ[i,0])+' '+str(XYZ[i,1])+' '+str(0. if dim==2 else XYZ[i,2])+ls)

    File.write('CELLS '+str(Nb_Elem)+' '+str((Size_Elem+1)*Nb_Elem)+ls)
    for i in range(Nb_Elem):
        STemp=str(Size_Elem)
        for j in range(Size_Elem):
            STemp+=' '+str(Elem[i,j])
        File.write(STemp+ls)

    File.write('CELL_TYPES '+str(Nb_Elem)+ls)
    Type_Elem='5' if Size_Elem==3 else '10'
    for i in range(Nb_Elem):
        File.write(Type_Elem+ls)

    File.write('POINT_DATA '+str(Nb_Noeud_Elem)+ls)
  
    if Field!=None:
        Field_shape_1 = 1 if Field.ndim==1 else Field.shape[1]
        File.write('FIELD VAR 1'+ls)
        File.write('var '+str(Field_shape_1)+' '+str(Field.shape[0])+' double'+ls)

        for i in range(Field.shape[0]):
            str_var=''
            for j in range(Field_shape_1):
                Field_i_j= Field[i] if Field_shape_1==1 else Field[i,j]
                str_var+=str(Field_i_j)+' '
            File.write(str_var+ls)

    if Vec!=None:
        for i in range(Vec.shape[1]/dim):
            File.write('VECTORS Vec_'+str(i)+' double'+ls)
            for j in range(Vec.shape[0]):
                File.write(str(Vec[j,dim*i])+' '+str(Vec[j,dim*i+1])+' '+str(0. if dim==2 else Vec[j,dim*i+2])+ls)

    File.close()

