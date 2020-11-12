function make_mex_func(func_name,src,lib,lopt)

%----------------------------------------------------------

libI='';
libL='';
libs='';
for i=1:size(lib,1)
    libI=[libI ' -I' char(lib{i,1})];
    libL=[libL ' -L' char(lib{i,2})];
    for j=1:size(lib{i,3},2)
        libs=[libs ' -l' char(lib{i,3}(j))];
    end
end

%----------------------------------------------------------

for i=1:size(src,1)
    for j=1:size(src{i,2},2)
        src_ij=strcat(char(src{i,1}),char(src{i,2}(j)),'.cpp');
        cmd=['mex ' char(src{i,3}) ' ' libI ' -c ' src_ij];
        eval(cmd);
    end
end

arch=computer('arch');
objext='.o';
if strcmp(arch(1:3),'win')
    objext='.obj';
end

cmd=['mex ' lopt ' -output ' func_name ' ' libL ' ' libs ' '];
for i=1:size(src,1)
    for j=1:size(src{i,2},2)
        obj_ij=strcat(char(src{i,2}(j)),objext);
        cmd=[cmd ' ' obj_ij];
    end
end
cmd
eval(cmd)