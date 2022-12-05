# EPR Toolbox

[![DOI](zenodo.7401982.svg)](https://doi.org/10.5281/zenodo.7401982)

A MATLAB(r) toolbox for preprocessing, display, analysis, and postprocessing of electron spin resonance (EPR) spectroscopy data.

This toolbox implements methods of general interest for EPR spectroscopy and is used, *inter alia*, by the [cwEPR toolbox](https://github.com/tillbiskup/matlab-cwepr).

**Note:** While this MATLAB(r) toolbox should still work with current versions of MATLAB(r), you may be interested in the [Python package cwepr](https://docs.cwepr.de/) actively being developed and dedicated to fully reproducible data analysis.


## Features

* Modular design
* Load diverse data formats
* datasets and their structures
* magnetic-resonance specific functions
* Aiming at reproducible research


## Requirements

* [common toolbox](https://github.com/tillbiskup/matlab-common)


## Installation

Download the toolbox (usually as compressed archive), uncompress (if necessary), start MATLAB(r), change to the folder you have downloaded/uncompressed the toolbox files to, change to the directory `internal` and call the function `EPRinstall` from within the MATLAB(r) command line. This should guide you through the installation process (and add, *inter alia*, the toolbox to the MATLAB(r) search path).


## How to cite

The EPR toolbox is free software. However, if you use it for your own research, please cite it accordingly:

  * Till Biskup, Deborah Meyer. EPR toolbox (2022). [doi:10.5281/zenodo.7401982](https://doi.org/10.5281/zenodo.7401982)

    [![DOI](zenodo.7401982.svg)](https://doi.org/10.5281/zenodo.7401982)


## License

The toolbox is distributed under the GNU Lesser General Public License (LGPL) as published by the Free Software Foundation.

This ensures both, free availability in source-code form and compatibility with the (closed-source and commercial) MATLAB(r) environment.


## Authors

* Till Biskup (2015-2022)

    The principal author and main developer of the cwEPR toolbox

* Deborah Meyer (2015)

    Valuable contributions during her PhD time


## Related projects

There is a number of related MATLAB(r) projects you may be interested in, but have a look at the section with related Python projects as well that are actively being developed.


### MATLAB(r) projects

* [common toolbox](https://github.com/tillbiskup/matlab-common)

     Toolbox providing basic functionality for data analysis. Spiritual predecessor of the [ASpecD framework](https://docs.aspecd.de/) implemented in Python. Each processing and analysis step gets automatically logged with all parameters to ensure reproducibility. Provides basic functionality for installing and configuring as well as standard processing steps.

* [cwepr toolbox](https://github.com/tillbiskup/matlab-cwepr)

    Toolbox for analysing cwEPR data (common Toolbox based). Spiritual predecessor of the [cwepr package](https://docs.cwepr.de/) implemented in Python. Each processing and analysis step gets automatically logged with all parameters to ensure reproducibility. Focusses particularly on automating the pre-processing and representation of data.

* [trepr toolbox](https://github.com/tillbiskup/matlab-trepr)

    Toolbox for preprocessing, display, analysis, and postprocessing of transient (*i.e.*, time-resolved) electron spin resonance spectroscopy (in short: trEPR) data. Spiritual predecessor of the [trepr package](https://docs.trepr.de/) implemented in Python. Each processing and analysis step gets automatically logged with all parameters to ensure reproducibility. Focusses particularly on automating the pre-processing and representation of data.

* [TSim](https://github.com/tillbiskup/matlab-trepr-tsim) [(Documentation)](https://tsim.docs.till-biskup.de/)

    A toolbox for the simulation and fitting of spin-polarised triplet states, using EasySpin for the simulation part, but guiding the user with an extensive CLI and creating well-formatted reports of the results for enhanced reproducibility. Developed by D. Meyer and maintained by T. Biskup.

* [TA toolbox](https://github.com/tillbiskup/matlab-ta)

    Toolbox for preprocessing, display, analysis, and postprocessing of transient absorption (flash photolysis) data. Similarly to the trEPR toolbox, the TA toolbox is fully GUI-based, but all functions are accessible via command line (CLI) as well. Furthermore, the GUI is extensively documented.


### Python projects

* [ASpecD framework](https://docs.aspecd.de/)

    A Python framework for the analysis of spectroscopic data focussing on reproducibility and good scientific practice, developed by T. Biskup.

* [cwepr package](https://docs.cwepr.de/)

    Python package for processing and analysing continuous-wave electron paramagnetic resonance (cw-EPR) data, originally implemented by P. Kirchner, developed and maintained by M. Schröder and T. Biskup.

* [trEPR package](https://docs.trepr.de/)

    Python package for processing and analysing time-resolved electron paramagnetic resonance (trEPR) data, developed by J. Popp, currently developed and maintained by M. Schröder and T. Biskup.

* [FitPy](https://docs.fitpy.de/)

    Python framework for the advanced fitting of models to spectroscopic data focussing on reproducibility, developed by T. Biskup.
