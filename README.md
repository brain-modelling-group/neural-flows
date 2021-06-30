
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
+ `io/` that handles read and write operations of .json and .mat files.
+ `visualisation/` contains lots of plotting functions including some that produce movies like the one you can see at the end of this document. 
+ `external/`, which contains code implemented by others, the most prominent being C-NEM invoked by so-called meshless methods, and the Hungarian method  used track singularities; and finally, 
+  `utils/` which gathers small standalone functions that support the main modules. 



![alt text](https://github.com/brain-modelling-group/neural-flows/blob/master/demo-data/img/fig_workflow_pretty_vis.png?raw=true)

## Getting started

### Dependencies:

**MATLAB**
   
   - tested on R2018b & R2020a
   - in principle should work on any OS that MATLAB supports; tested on Windows 10, Debian 10, Ubuntu 20.04, Ubuntu 16.l4, OpenSuse 15.1 

**CNEM**, https://m2p.cnrs.fr/sphinxdocs/cnem/index.html
    - only relevant if you want to use the phase-gradient method for calculating flows and meshless method for tracing streamlines.
    - meshless methods speed up calculations significantly but installing cnem can be tricky. 
    - used version (v03, 2014-05-04) available here: https://ff-m2p.cnrs.fr/frs/?group_id=14
    - aka cnemlib: https://au.mathworks.com/matlabcentral/linkexchange/links/3875
    - if you have trouble, contact the author of the library (mail can be found on the cnrs.fr website linked above) who has been super helpful when we had issues. 


    
### Installation:

If you download the zip folder, first unzip and then ... 

- Windows 10: see the instructions [here](https://github.com/brain-modelling-group/neural-flows/wiki/Getting-started::Windows10::). 
- Linux: on the terminal change directory to `neura-flows` folder, then start matlab. That's it. The toolbox paths should be appended automatically. 

If you clone the repo, same rules as above apply. 

### What can the toolbox do?
A bunch of things, mostly the ones described in the diagram above.

To get started follow the next steps (timestamp: Tue 29 Jun 2021 14:49:38 AEST): 

### Out of the box examples

0. (Optional) Inside directory `neural-flows/`, make a new directory called `scratch/` (by default we will store results there, you can change it later ...). If this directory doesn't exist the toolbox will print a warning message and then proceed to create it. 

1. Call the following function from within the top level directory `neural-flows/`
```matlab
fmri_waves()
``` 
or 
```matlab
rotating_wave()
```

The first example take about 7 minutes to run everything and pop up figures with flow mode decomposition and singularity tracking! 
The second one takes about 9 minutes. The execution times are estimated using a high-end workstation (circa 2018). On a laptop it can take 2.5 longer to run (o.O it's heavy stuff).

##### Flow mode decomposition
![alt text](https://github.com/brain-modelling-group/neural-flows/blob/master/demo-data/img/fig_rotating_wave_svd.png?raw=true)

#### Singularity statistics
![alt text](https://github.com/brain-modelling-group/neural-flows/blob/master/demo-data/img/fig_summary_stats.png?raw=true)
![alt text](https://github.com/brain-modelling-group/neural-flows/blob/master/demo-data/img/fig_sing_tracking.png?raw=true)


#### Movies

Movies are not produced by default as they require more computational resources. However, we provide the visualisation tools to make movies like this one:

![neural-flows-256](https://user-images.githubusercontent.com/1563810/123740938-92b2b980-d8ec-11eb-9406-22e9e2a77b03.gif)



### What if I want to use my own data? Input data format
    
The toolbox reads data from a .mat file. It *will expect* the following variables to be stored.    
    
    - `data`: a tpts-by-n 2D array with the data for unstructured datasets (i.e., source reconstructed EEG/MEG data, whole-brain models/brain net) 
    - `locs`: a n-by-3 2D array with the locations of nodes/rois/sources, expressed in mm or m.
    - `ht`  : sampling period expressed in ms or s.
    
