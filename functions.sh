#!/bin/bash

###############################################################################
#                                  Functions                                  #
###############################################################################

# Logging #####################################################################
initLog() { # Init Log (for initalization messages)
    echo -e "INIT - $1"
}

infoLog() { # Info Log (for task specific messages)
    echo -e "INFO - $1"
}

errorLog() { # Error log (for error messages)
    echo -e "ERROR - $1"
}
