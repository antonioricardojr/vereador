library(plumber)
r = plumb("server.R")
r$run(port = 8000)
