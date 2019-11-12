function tok(tstart)

    tend = string(datetime('now'));
    fprintf('%s%s\n', ['Finished: ' tend])
    tictoc = etime(datevec(tend), datevec(tstart));
    fprintf('%s%s%s\n\n', ['Elapsed time: ' string(tictoc/3600) ' hours'])
    fprintf('%s%s%s\n\n', ['Elapsed time: ' string(tictoc/60) ' minutes'])
    fprintf('%s%s%s\n\n', ['Elapsed time: ' string(tictoc) ' seconds'])

end