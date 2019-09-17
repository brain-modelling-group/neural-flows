function out_var_vtk(xyz,elem,field,vec,inc)
File_name=['var_',num2str(inc),'.vtk'];
fid=fopen(File_name,'w');
fprintf(fid,'%s\n%s\n%s\n','# vtk DataFile Version 2.0','var','ASCII');
fprintf(fid,'%s\n','DATASET UNSTRUCTURED_GRID');
fprintf(fid,'%s%d%s\n','POINTS ',size(xyz,1),' double');
fprintf(fid,'%e %e %e\n',xyz');
fprintf(fid,'%s%d%s%d\n','CELLS ',size(elem,1),' ',(size(elem,2)+1)*size(elem,1));
format='';
for i=1:size(elem,2)+1
    format=[format,'%d '];
end
format=[format,'\n'];
fprintf(fid,format,[size(elem,2)*ones(size(elem,1),1),elem-1]');
fprintf(fid,'%s%d\n','CELL_TYPES ',size(elem,1));
cell_type=0;
if size(elem,2)==3
    cell_type=5;
elseif size(elem,2)==4
    cell_type=10;
end

fprintf(fid,'%d\n',cell_type*ones(size(elem,1),1));
fprintf(fid,'%s%d\n','POINT_DATA ',size(xyz,1));

if size(field,1)~=0
    fprintf(fid,'%s\n','FIELD VAR 1');
    fprintf(fid,'%s%d%s%d%s\n','var ',size(field,2),' ',size(field,1),' double');
    format='';
    for i=1:size(field,2)
        format=[format,'%e '];
    end
    format=[format,'\n'];
    fprintf(fid,format,field');
end

if size(vec,1)~=0
    for i=1:size(vec,2)/3
        fprintf(fid,'%s%d%s\n','VECTORS vec_',i,' float');
        fprintf(fid,'%e %e %e\n',vec(:,3*(i-1)+1:3*i)');
    end
end

fclose(fid);
