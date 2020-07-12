function path_to_dir = get_directory_path(full_path_to_exec_file, dir_path)

    C = strsplit(full_path_to_exec_file, filesep);
    O =  strcat(C(1:end-1), filesep);
    path_to_dir = strcat(O{:}, dir_path);

end