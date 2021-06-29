
## Neural Flows: estimation of velocities, detection and classification singularities in 3D+t brain data

If you use this toolbox, please cite:

[![DOI](https://zenodo.org/badge/163922377.svg)](https://zenodo.org/badge/latestdoi/163922377)


## Brief Description 
This is `neural-flows`, a library to estimate wave velocities and singularities in 3D+t in neuroimaging data.  
The figure below gives you an idea of a typical workflow you can run with this toolbox:  
Each link of the path is a component of the `core/` namely: 
+ data interpolation, 
+ flow estimation, 
+ singularity detection and classification, and
+ streamline tracing. 

The toolbox has a number of ancillary modules, including:

+ `examples/` with exemplary scripts to execute a full or partial workflow; 
+ `external/`, which contains code implemented by others, the most prominent being C-NEM invoked by so-called meshless methods, and the Hungarian method  used track singularities; and finally, 
+  `utils/` which gathers small standalone functions that support the main modules. 



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

If you download the zip folder, first unzip and then ... 

- Windows 10: see the instructions [here](https://github.com/brain-modelling-group/neural-flows/wiki/Getting-started::Windows10::). 
- Linux: on the terminal change directory to `neura-flows` folder, then start matlab. That's it. The toolbox paths should be appended automatically. 

If you clone the repo, same rules as above apply. 

### What can the toolbox do?
A bunch of things, mostly the ones described in the diagram above.

To get started follow the next steps (timestamp: Fri 31 Jul 2020 21:21:17 AEST): 

0. (Optional) Inside directory `neural-flows`, make a new directory called `scratch/` (by default we will store results there, you can change it later ...)
1. (Optional) Open the file `rotating-wave_ustructured-amplitude-hs-meshless.json` under `examples/`
1a.(Optional) if you are on Windows change line 6 of that file from
```
      "dir_tmp": "/tmp",    

```

to 

```
   "dir_tmp": "C:\Users\guest\AppData\Local\Temp",    
```

or any other directory where some temporary files will be stored during execution.

1b. (Optional) If you are on Mac, the default value `/tmp` should work, otherwise change it to an appropriate temporary folder.

1c. (Optional) If you re on Linux, you're good to go.

2. Call the following function from within the top level directory `neural-flows/`
```matlab
rotating_wave()
``` 
It should take about 5 minutes to run everything and pop up figures with flow mode decomposition and singularity tracking!

##### Flow mode decomposition
![alt text](https://github.com/brain-modelling-group/neural-flows/blob/master/demo-data/img/fig_rotating_wave_svd.png?raw=true)

#### Singularity statistics
![alt text](https://github.com/brain-modelling-group/neural-flows/blob/master/demo-data/img/fig_summary_stats.png?raw=true)
![alt text](https://github.com/brain-modelling-group/neural-flows/blob/master/demo-data/img/fig_sing_tracking.png?raw=true)


