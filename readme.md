## DIMA Quality Control Analysis Tool

The DIMA Quality Control Analysis Tool was designed to accept a DIMA Access Database containing core indicators monitoring data and produce a standard quality control report in RMarkdown that is downloadable. The tool was written in R Shiny, but could be adapted to run independently in R with minor modifications.

#### The following are the critical files with descriptions: ####
  - dimaqc.20161202.Rmd - This is the RMarkdown file that actutally runs the QC report. This file can be adapted to run independently in R with minor modifications.
  - PLANTSlist_Master.20161116.csv - called by the RMarkdown file, this is the master USDA PLANTS database species list from Nov 16, 2016. This file is used to check species codes used in the DIMA database.
  - server.R - Shiny server file.
  - us.R - Shiny UI file.
  - *.html - Example DIMA QC Reports
  
  
#### Running the RMarkdown file requires the following R packages to run: ####
   - dplyr
   - ggplot2
   - lubridate
   - quantreg
   - reshape2
   - leaflet
   - sp
   - multcomp
   
   When running on Windows, the RODBC package is needed to read the tables out of DIMA. If running on linux or Mac, then the external mdb-export tool needs to be installed first.