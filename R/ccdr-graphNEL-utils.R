#
#  ccdr-graphNEL-utils.R
#  ccdr
#
#  Created by Bryon Aragam (local) on 7/26/15.
#  Copyright (c) 2014-2015 Bryon Aragam (local). All rights reserved.
#

#
# Various utility functions for enforcing compatibility with the 'graph' package from BioConductor.
#

#
# Helper function to convert an edge list to a graphNEL compatible edge list
#  The main difference is instead of listing parents for each node, graphNEL requires
#  listing children for each parent. There are also different naming and indexing conventions.
#
edge_list_to_graphNEL_edgeL <- function(el){
    #----------- EXAMPLE -----------
    # Default:
    # [[1]]
    # integer(0)
    #
    # [[2]]
    # [1] 1
    #
    # [[3]]
    # [1] 1
    #
    # graphNEL:
    # $`1`
    # $`1`$edges
    # [1] 2 3
    #
    #
    # $`2`
    # $`2`$edges
    # NULL
    #
    #
    # $`3`
    # $`3`$edges
    # NULL
    #
    #-------------------------------

    numnode <- length(el) # Number of nodes should be same as length of default edge list

    ### Invert the child-parent relationships (aka implicit transpose of adjacency matrix)
    el.graphNEL <- vector(mode = "list", length = numnode)
    for(j in 1:numnode){
        this.column <- el[[j]] # "column" = interpret as column in adj matrix
        for(i in seq_along(this.column)){
            el.graphNEL[[this.column[i]]] <- c(el.graphNEL[[this.column[i]]], j)
        }
    }

    ### Needs an extra component called "edges" (allows for possible specification of weights as well)
    el.graphNEL <- lapply(el.graphNEL, function(x){ list(edges = x)})

    ### List names MUST be character 1,...,numnode
    names(el.graphNEL) <- as.character(1:numnode)

    el.graphNEL
}

to_graphNEL <- function(x) UseMethod("to_graphNEL", x)

to_graphNEL.SparseBlockMatrixR <- function(sbm){
    el <- edge.list(sbm)
    el <- edge_list_to_graphNEL_edgeL(el)

    graphNEL(nodes = as.character(1:num.nodes(sbm)), edgeL = el, edgemode = 'directed')
}

to_graphNEL.ccdrFit <- function(cf){
    #
    # REALLY SHOULD RENAME SBM SINCE THIS CAN CHANGE TYPE (SBM, matrix, graphNEL)
    #
    cf$sbm <- to_graphNEL(cf$sbm)

    cf
}

to_graphNEL.ccdrPath <- function(cp){
    lapply(cp, to_graphNEL)
}
