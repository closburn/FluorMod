This repository is associated with Osburn, C.L., Bianchi, T.S., Paerl, H.W., Hall, N.S., Hounshell, A.G., Rudolph, J.C., Bhattacharya, R., and Paerl, R.W. (2026) Carbon Sources and Weather in Coastal North Carolina. _Limnology and Oceanography_, accepted.

The files herein correspond to a tutorial for the FluorMod v.4.0 modeling framework described in the main text and Supporting Information. FluroMod uses the Regress-Then-Sum (RTS) method described in Bryan, J., Hoff, P., & Osburn, C. L. (2023). Routine estimation of dissolved organic matter sources using fluorescence data and linear least squares. ACS ES&T Water, 3(8), 2073-2082. The tutorial uses a subset of EEMs from the Neuse River Estuary, eastern North Carolina, to demonstrate how to vectorize EEMs (matrices) of dimension M x N to vectors of dimension M*N x 1, then how to apply the RTS. A dictionary of source EEMs, already vectorized, also is included. 

The files included in this repository include:

**data** - EEMs used in the tutorial included in the raw_eems folder and the source_eems.csv file. 

**scripts** - The reshaper_tool.R file that transforms matrices into vectors. FluorMod_RTS.R, the file that applies the RTS method and calculates performance statistics, such as R<sup>2</sup>, RMSE, and MAE. 

**FluorMod.Rproj** - RStudio project file.

**fm_workflow.R** - File that vectorizes EENs and then runs FluorMod.

**.gitignore** - GitHub file which may be ignored. 

This GitHub project code is provided on an ‘as is’ basis and the user assumes responsibility for its use.

Refer any questions or issues to Chris Osburn, closburn@ncsu.edu. 
