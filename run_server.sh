#!/bin/bash

R -e "library(plumber); pr <- plumb('server.R'); pr\$run(port=4000)"
