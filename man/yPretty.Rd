\name{yPretty}
\alias{yPretty}
\title{Sets up tick marks for an axis for a graph with an arithmetic scale which starts at zero}
\usage{
  yPretty(yMax)
}
\arguments{
  \item{yMax}{A numeric value for the maximum value to be
  plotted, it must be >0}
}
\value{
  yTicks A numeric vector representing the values for each
  of the tick marks
}
\description{
  Axis tick marks that run from zero to some specified
  maximum, creates about 4 to 8 ticks marks.
}
\examples{
yPretty(7.8)
yPretty(125)
}
\keyword{graphics}
\keyword{statistics}

