
## Neural Flows: estimation of velocities, detection and classification singularities in 3D+t brain data

If you use this toolbox, please cite:

Roberts JA, Gollo LL, Abeysuriya R, Roberts G, Mitchell PB, Woolrich MW, Breakspear M. Metastable brain waves. (2019) [Available from here.](https://www.nature.com/articles/s41467-019-08999-0)

Sanz-Leon P, Gollo LL, and Roberts JA (2020) (in prep).

DOI: 

## Brief Description 
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

## Getting started

### Dependencies:

**MATLAB**
    - tested on R2018b & R2020a
    - in principle should work on any OS that MATLAB supports; tested on Windows 10, Debian 10, Ubuntu 20.04, Ubuntu 16.l4, OpenSuse 15.1 

**CNEM**, https://m2p.cnrs.fr/sphinxdocs/cnem/index.html
    - used version (v03, 2014-05-04) available here: https://ff-m2p.cnrs.fr/frs/?group_id=14
    - aka cnemlib: https://au.mathworks.com/matlabcentral/linkexchange/links/3875

**input data**
    - `data`: a tpts-by-n 2D array with the data for unstructured datasets (i.e., soruce reconstructed MEG data) 
    - `locs`: a n-by-3 2D array with the locations of nodes/rois/sources, expressed in mm or m.
    - `ht`  : sampling period expressed in ms or s.
    
### Installation:

Unzip and add to the MATLAB path. 


### What can the toolbox do?
A bunch of things, mostly the ones described in the diagram above.

To get started follow the next steps: 

0. Inside directory `neural-flows`, make a new directory call `scratch` (by defualt we will store results there, you can change it later ...)
1. Open the file `rotating_wave_uah_in.json` under `examples/`
1a. if you are on windows change line 6 of that file
```json
      "dir_tmp": "/tmp",    

```

to 

```json
   "dir_tmp": "C:\Windows\Temp",    
```

or any other directory where some temporary files will be stored during execution.
1b. If you are on Mac, similary change that line of the .json file to an appropriate temp folder.
1c. If you re on Linux, you're good to go.

3. Run the function under `examples/` at
```matlab
rotating_wave('uah')
``` 
It should take about 5 minutes to run everything and pop up figures with flow mode decomposition and singularity tracking!


### Where is the user manual?

Coming soon, sorry <(~.~)> ...

