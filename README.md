
## Neural Flows: estimation of velocities, detection and classification singularities in 3D+t brain data

If you use this toolbox, please cite:

Roberts JA, Gollo LL, Abeysuriya R, Roberts G, Mitchell PB, Woolrich MW, Breakspear M. Metastable brain waves. (2019) [Available from here.](https://www.nature.com/articles/s41467-019-08999-0)

Sanz-Leon P, Gollo LL, and Roberts JA (2020) (in prep).

DOI: 

This is `neural-flows`, a library to estimate wave velocities and singularities in 3D+t in neuroimaging data.  
The figure below gives you an idea of a typical workflow you can run with this toolbox:  
Each link of the path is a component of the `core-module` namely: 
+ data interpolation, 
+ flow estimation, 
+ singularity detection and classification, and
+ streamline tracing. 

The toolbox has a number of ancillary modules, including `examples` with  exemplary scripts to execute a full or partial
workflow; `external`, which contains code implemented by others, the
most prominent being C-NEM invoked by so-called
meshless methods, and the Hungarian method 
used track singularities; and finally, `utils` which gathers small
standalone functions that support the main modules. 



![alt text](https://github.com/brain-modelling-group/neural-flows/blob/master/demo-data/img/fig_workflow_pretty_vis.png?raw=true)
