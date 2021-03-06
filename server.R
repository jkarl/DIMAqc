
library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
if (Sys.info()[1]=="Windows") {
  library(RODBC)
}

# Change the default file upload size to accomodate a DIMA file
options(shiny.maxRequestSize=100*1024^2)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  output$Log <- eventReactive(input$DIMAfile,{
    
    ## On upload of the DIMA database, read in the tables
    infile <- input$DIMAfile
    if(is.null(infile)) {
      return(NULL)
    }

    # If running on Windows
    if (Sys.info()[1]=="Windows") {
      dima <- odbcConnectAccess(infile$datapath)
      #sqlTables(dima)  # List all of the tables/querries in the database
      tblApp <- sqlFetch(dima,"tblApplicationConstants")
      tblPlots <- sqlFetch(dima,"tblPlots")
      tblSites <- sqlFetch(dima,"tblSites",stringsAsFactors=F)
      odbcClose(dima)
    } else {
      ## Logic for importing tables in Linux using mdbtools
      tables <- c("tblApplicationConstants","tblPlots","tblSites","tblPeople")
      for (table in tables) {
        read.string <- paste("mdb-export -d '|' '",infile$datapath,"' ",table,sep="")
        #message(read.string)
        assign(paste(table),read.table(pipe(read.string),sep="|",header=TRUE,stringsAsFactors=FALSE))
      }
      tblApp <- tblApplicationConstants
    }
    
    # Winnow and join the tables
    tblPlots_sub <- dplyr::select(tblPlots, one_of(c("PlotKey","PlotID","SiteKey","EstablishDate","State","County","Slope","Aspect","Elevation",
                                              "LandscapeType","EcolSiteMLRA","EcolSiteSubMLRA","AvgPrecip","AvgPrecipUOM",
                                              "ESD_SlopeShape")))
    tblSites_sub <- dplyr::select(tblSites, one_of(c("SiteKey","SiteID","SiteName")))
    
    # fix the dates and get the year and Julian day for the plots
    tblPlots_sub$year <- year(as.Date(tblPlots_sub$EstablishDate,format="%m/%d/%y"))
    tblPlots_sub$yday <- yday(as.Date(tblPlots_sub$EstablishDate,format="%m/%d/%y"))
    yrs <- unique(tblPlots_sub$year)
    sites <- unique(tblSites_sub$SiteName)
    #message(yrs)

    ## Update the year and site select boxes with what's in the DIMA database tables
    updateSelectInput(session,"Year",choices=rbind("all",sort(yrs)))
    updateSelectInput(session,"Site",choices=rbind("all",sites[3:length(sites)]))
    
    
    ## report to the app log
    print(paste("Successfully loaded DIMA tables.",'\n',"DIMA version ",tblApp[1,1],sep=''))
  })
  
  
  output$runReport <- downloadHandler(
    filename = "report.html",
    content = function(file) {
      infile <- input$DIMAfile
      dpath <- infile$datapath
      tempReport <- file.path(tempdir(), "dimaqc.Rmd")
      file.copy("dimaqc.20161202.Rmd", tempReport, overwrite = TRUE)
      file.copy("PLANTSlist_Master.20161116.csv",file.path(tempdir(),"PLANTSlist_Master.20161116.csv"),overwrite=TRUE)
      file.copy(dpath,file.path(tempdir(),"DIMA.mdb"),overwrite=TRUE)
      params <- list(dimafile=infile$datapath,year=input$Year,site=input$Site)
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
    
  )
  
})

