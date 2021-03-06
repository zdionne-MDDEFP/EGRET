#' Create a table of the changes in flow-normalized concentration or flux values between various points in time in the record
#'
#' This table describe trends in flow-normalized concentration or flux depending on if flux is defined as TRUE or FALSE. 
#' The results are described as changes in real units or in percent and als as slopes in real units per year or in percent per year.
#' They are computed over pairs of time points (Year1 to Year2).  These time points can be user-defined or
#' they can be set by the program to be the final year of the record and a set of years that are multiple of 5 years prior to that.
#'
#' @param localAnnualResults string specifying the name of the data frame that contains the concentration and discharge data, default name is AnnualResults
#' @param localINFO string specifying the name of the data frame that contains the metadata, default name is INFO
#' @param fluxUnit object of fluxUnit class. \code{\link{fluxConst}}, or numeric represented the short code, or character representing the descriptive name.
#' @param yearPoints numeric vector listing the years for which the change or slope computations are made, they need to be in chronological order.  For example yearPoints=c(1975,1985,1995,2005), default is NA (which allows the program to set yearPoints automatically)
#' @param flux logical if TRUE results are returned in flux, if FALSE concentration. Default is set to FALSE.
#' @param returnDataFrame logical, if a dataframe is required to be returned set this to TRUE.  Otherwise, the default is FALSE
#' @keywords water-quality statistics
#' @export
#' @return dataframe with Year1, Year2, change[mg/L], slope[mg/L], change[percent], slope[percent] columns. The data in each row is the change or slope calculated from Year1 to Year2
#' @examples
#' AnnualResults <- exAnnualResults
#' INFO <- exINFOEnd
#' tableChangeSingle(fluxUnit=6,yearPoints=c(2001,2005,2008,2009), flux=FALSE)  #This returns concentration ASCII table in the console 
#' tableChangeSingle(fluxUnit=6,yearPoints=c(2001,2005,2008,2009), flux=TRUE)  #This returns flux values ASCII table in the console
#' tableChangeConc <-tableChangeSingle(fluxUnit=9, returnDataFrame = TRUE, flux=FALSE)    #This returns concentration values in a dataframe
#' tableChangeFlux <-tableChangeSingle(fluxUnit=9, returnDataFrame = TRUE, flux=TRUE)  #This returns flux values in a dataframe
tableChangeSingle<-function(localAnnualResults = AnnualResults, localINFO = INFO, fluxUnit = 9, yearPoints = NA, returnDataFrame = FALSE, flux = FALSE) {
  ################################################################################
  # I plan to make this a method, so we don't have to repeat it in every funciton:
  if (is.numeric(fluxUnit)){
    fluxUnit <- fluxConst[shortCode=fluxUnit][[1]]    
  } else if (is.character(fluxUnit)){
    fluxUnit <- fluxConst[fluxUnit][[1]]
  }
  ################################################################################ 
  firstYear<-trunc(localAnnualResults$DecYear[1])
  numYears<-length(localAnnualResults$DecYear)
  lastYear<-trunc(localAnnualResults$DecYear[numYears])
  defaultYearPoints<-seq(lastYear,firstYear,-5)
  numPoints<-length(defaultYearPoints)
  defaultYearPoints[1:numPoints]<-defaultYearPoints[numPoints:1]
  yearPoints<-if(is.na(yearPoints[1])) defaultYearPoints else yearPoints
  numPoints<-length(yearPoints)
  # these last three lines check to make sure that the yearPoints are in the range of the data  
  yearPoints<-if(yearPoints[numPoints]>lastYear) defaultYearPoints else yearPoints
  yearPoints<-if(yearPoints[1]<firstYear) defaultYearPoints else yearPoints
  numPoints<-length(yearPoints)
  fluxFactor<-fluxUnit@unitFactor
  fName<-fluxUnit@shortName
  
  
  cat("\n  ",localINFO$shortName,"\n  ",localINFO$paramShortName)
  periodName<-setSeasonLabel(localAnnualResults = localAnnualResults)
  cat("\n  ",periodName,"\n")
  
  header1<-"\n           Concentration trends\n   time span       change     slope    change     slope\n                     mg/L   mg/L/yr        %       %/yr"
  header2<-"\n\n\n                 Flux Trends\n   time span          change        slope       change        slope"
  
  fNameNoSpace <- gsub(" ","", fName)
  
  if (flux) header1 <- paste(header2, "\n              ",fName,fName,"/yr      %         %/yr", sep="")
  
  blankHolder<-"      ---"
  results<-rep(NA,4)
  indexPoints<-yearPoints-firstYear+1
  numPointsMinusOne<-numPoints-1
  write(header1,file="")
  
  if (flux){
    header <- c("Year1", "Year2", paste("change [", fNameNoSpace, "]", sep=""), paste("slope [", fNameNoSpace, "]", sep=""),"change[%]", "slope [%/yr]" )
  } else {
    header <- c("Year1", "Year2", "change [mg/L]","slope [mg/L/yr]","change[%]", "slope [%/yr]")    
  }
  
  resultDF <- as.data.frame(sapply(1:6, function(x) data.frame(x)))
  colnames(resultDF) <- header  
  
  for(iFirst in 1:numPointsMinusOne) {
    xFirst<-indexPoints[iFirst]
    yFirst<-localAnnualResults$FNConc[indexPoints[iFirst]]
    iFirstPlusOne<-iFirst+1
    for(iLast in iFirstPlusOne:numPoints) {
      xLast<-indexPoints[iLast]
      
      if (flux) {
        yLast<-localAnnualResults$FNFlux[indexPoints[iLast]]
        widthLength <- 12
      } else {
        yLast<-localAnnualResults$FNConc[indexPoints[iLast]]
        widthLength <- 9
      }      
      
      xDif<-xLast - xFirst
      yDif<-yLast - yFirst
      
      
      results[1]<-if(is.na(yDif)) blankHolder else format(yDif,digits=2,width=widthLength)
      results[2]<-if(is.na(yDif)) blankHolder else format(yDif/xDif,digits=2,width=widthLength)
      results[3]<-if(is.na(yDif)) blankHolder else format(100*yDif/yFirst,digits=2,width=widthLength)
      results[4]<-if(is.na(yDif)) blankHolder else format(100*yDif/yFirst/xDif,digits=2,width=widthLength)
      cat("\n",yearPoints[iFirst]," to ",yearPoints[iLast],results)
      resultDF <- rbind(resultDF, c(yearPoints[iFirst], yearPoints[iLast],results))
    }
  }
  cat("\n")
  resultDF <- resultDF[-1,]
  row.names(resultDF) <- NULL
  resultDF <- as.data.frame(lapply(resultDF,as.numeric))
  colnames(resultDF) <- header
  
  if (!returnDataFrame) {
    return()
  }
  
  return(resultDF)
}