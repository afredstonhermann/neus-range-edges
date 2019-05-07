This repository contains all the scripts for the analysis and figures in Fredston-Hermann et al. 2019. 

Wherever external data must be used, the scripts contain instructions for obtaining the data. [EXPLAIN AQUAMAPS AND CONSIDER UPLOADING SMALL DATASETS]

At the moment (May 2019), these scripts rely heavily on the development version of the `sf` package from `r-spatial`. This is because recently added functions, including `st_crop` and `st_nearest_points`, are extremely useful for our analysis, but not yet in CRAN. In the short term, to run these scripts, users will need to install the development version of `sf` which can be a slightly tricky process (see issues on the Github page for that package). Once the CRAN version of `sf` is updated, this issue will be resolved. 

Scripts should be run in the following order: 

1. `get_trawl_data.R`
1. `clean_trawl_data.R`
1. `coastline_length.R`
1. `calculate_edges.R`
1. `analyze_edges.R`