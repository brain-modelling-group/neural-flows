function display_info_banner(mfilename_fun, core_stage_name, core_stage_colour, stage) 

 cprintf(core_stage_colour, '\n------------------------------------------------------------------------\n')
 cprintf('#18181b', '%s', strcat('neural-flows:: ', mfilename_fun, '::Info:: '))
 cprintf(core_stage_colour, core_stage_name)
 if stage
     cprintf('#18181b', ' STAGE.\n')
 else
     cprintf('#18181b', '\n')
 end
 cprintf(core_stage_colour, '------------------------------------------------------------------------\n')
 
 
end % display_info_banner()