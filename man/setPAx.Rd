\name{setPAx}
\alias{setPAx}
\title{A special version of setPA for use inside the plot15 function}
\usage{
  setPAx(paStart = 10, paLong = 12, window = 30,
    localINFO = INFO)
}
\arguments{
  \item{paStart}{A numeric value for the starting month of
  the Period of Analysis, default is 10}

  \item{paLong}{A numeric value for the length of the
  Period of Analysis in months, default is 12}

  \item{window}{A numeric value for the half-width of a
  smoothing window for annual streamflow values, default is
  30}

  \item{localINFO}{A character string specifying the name
  of the metadata data frame}
}
\value{
  localInfo A data frame containing the metadata
}
\description{
  Part of the flowHistory system Users should not need to
  call this function
}
\examples{
INFO <- exINFOStart
INFO <- setPAx(paStart=12, paLong=3)
}
\keyword{statistics}
\keyword{streamflow}

