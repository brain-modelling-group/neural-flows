function [idx_frame] = get_frame_index(idx_chunk, datalen, in_chunk_idx)


% window size
    ws = 8193;
    % shift step
    shift_step = ws - 64;
    idx = ws:shift_step:datalen;
    if idx_chunk < length(idx)+1
        idx_start = idx(idx_chunk)-ws+1; 
        idx_stop =  idx(idx_chunk);
    else
        idx_start = idx(end);
        idx_stop = datalen;
    end
    
    vec=idx_start:idx_stop;
    idx_frame = vec(in_chunk_idx);
    
    
end