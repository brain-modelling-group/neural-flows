function params = generate_slice_filename(params, field_name)
% TODO: document

    if eval(['isfield(params.' [field_name] '.file, "label")'])
        slice_str = ['-tmp_interp-' num2str(params.data.slice.id, '%03d')];
        eval(['root_fname = [params.' field_name '.file.label slice_str]' ]) 
    else       
        root_fname = ['tmp_interp-' num2str(params.data.slice.id, '%03d')];
    end
    eval(['params.' field_name '.file.label = root_fname']);

end % function generate_slice_filename()
