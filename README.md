
# TRN_MGB_celltypespecific

Models to accompany Rolon-Martinez et al.

---

# Paper link

[doi](url)

---

# Model usage

follow matlab setup -> [Here](docs/Matlab%20setup.md)

make a new directory for simulation run.

Copy src model files to new simulation directory.

edit the Run_dsim.m template script.

Visualize vm data from sims by running display_graph in the sim directory.

run extractData to extract spike times and firing rate from vm data for analysis.


# Simulations used in Paper

The simulations directory contains code files for all simulations that went into the final paper. Raw vm data results were ommitted for space and exist on lab storage.

---

# Documentation

Further information on running simulations and details of the model code can be found in the docs directory:

doc file | description | code file
-------- | ----------- | ---------
[Run_dsim](docs/Run_dsim.md) | Script controlling variables and driving parallel simulation runs | [Run_dsim.m](src/Run_dsim.m)
[dsim](docs/dsim.md) | Function containing HH equations for model cells | [dsim.m](src/dsim.m)
[simParams](docs/simParams.md) | Object containing parameters for model cells | [simParams.m](src/simParams.m)
