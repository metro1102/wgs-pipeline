#!/bin/bash

###############################################################################
#                                  Functions                                  #
###############################################################################

# Logging #####################################################################
initLog() { # Init Log (for initalization messages)
    echo -e "\e[37m""INIT - $1""\e[0m"
}

infoLog() { # Info Log (for task specific messages)
    echo -e "\e[36m""INFO - $1""\e[0m"
}

errorLog() { # Error log (for error messages)
    echo -e "\e[91m""ERROR - $1""\e[0m"
}
