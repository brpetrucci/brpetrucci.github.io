#########################################################
##          Setup for canid SRFBD analysis             ##
##   Palaeoverse tutorial - Bruno do Rosario Petrucci  ##
#########################################################

###
# source xml writer

# get base directory
base_dir <- "/Users/petrucci/Documents/website/brpetrucci.github.io/files/tutorials/srfbd/"

# source xml_writer.R
source(paste0(base_dir, "xml_writer.R"))

###
# write scripts

# function to write scripts for a given setup
scripts_setup <- function(n_scripts, n_gens, attach, suffix = "") {
  # header
  header <- readLines(paste0(base_dir, "header.xml"))
  
  # maps
  maps <- readLines(paste0(base_dir, "maps.xml"))
  
  # data
  ranges <- read.delim(paste0(base_dir, "data/canidae_ranges.tsv"))
  morpho <- read.nexus.data(paste0(base_dir, "data/canidae_morpho.nex"))
  
  # rewrite polymorphisms
  morpho <- rewrite_polymorphisms(morpho)
  
  # get morpho partitions data
  morpho_partitions <- morpho_partitions(morpho, ascertain = TRUE)
  
  # start partitions list
  partitions <- list()
  
  # add partitions for morpho
  for (i in 1:length(morpho_partitions)) {
    # get this partition
    part <- morpho_partitions[[i]]
    
    # get the name
    part_name <- names(morpho_partitions)[i]
    
    # add partition
    partitions[[part_name]] <- list(
      data = "morpho",
      filter = part$filter,
      ascertained = part$ascertain,
      dataType = list(
        type = "StandardData",
        nrOfStates = as.numeric(sub('.*([0-9]+)', '\\1', part_name))
      ),
      excludefrom = part$excludefrom,
      excludeto = part$excludeto,
      siteModel = list(
        id = paste0("SiteModel.s:", part_name),
        gammaCategoryCount = 0,
        shape = 1,
        mutationRate = paste0("@mutationRate.s:", part_name),
        proportionInvariant = 0,
        substModel = list(
          model = "LewisMK"
        )
      ),
      threaded = FALSE)
    
    # branch rate model only for the first partition
    if (i == 1) {
      partitions[[part_name]]$branchRateModel <- list(
        id = "RelaxedClock.c:morpho",
        model = "ucld",
        clock.rate = "@ucldMean.c:morpho",
        rateCategories = "@rateCategories.c:morpho",
        dist = "LogNormal",
        M = 1, 
        S = "@ucldStdev.c:morpho"
      )
    }
  }
  
  # parameter list (with priors)
  priors = list(
    `mutationRate.s:morpho2` = list(
      spec = "parameter.RealParameter",
      value = 1
    ),
    `mutationRate.s:morpho3` = list(
      spec = "parameter.RealParameter",
      value = 1
    ),
    `mutationRate.s:morpho4` = list(
      spec = "parameter.RealParameter",
      value = 1
    ),
    `mutationRate.s:morpho5` = list(
      spec = "parameter.RealParameter",
      value = 1
    ),
    `diversificationRateFBD.t:tree` = list(
      dist = "Exponential",
      lower = 0,
      mean = 0.0767
    ),
    `turnoverFBD.t:tree` = list(
      dist = "Beta",
      lower = 0,
      upper = 1,
      alpha = 2,
      beta = 1
    ),
    `samplingProportionFBD.t:tree` = list(
      dist = "Beta",
      lower = 0,
      upper = 1,
      alpha = 3.1,
      beta = 6.9
    ),
    `originFBD.t:tree` = list(
      dist = "Exponential",
      lower = 0,
      mean = 9.67,
      offset = 37,
      init = 50
    ),
    `ucldMean.c:morpho` = list(
      dist = "LogNormal",
      lower = 0,
      M = -4,
      S = 0.5
    ),
    `ucldStdev.c:morpho` = list(
      dist = "Gamma",
      lower = 0,
      alpha = 0.5396,
      beta = 0.3819
    ))
  
  # use number of taxa
  priors <- append(priors, list(
    `rateCategories.c:morpho` = list(
      spec = "parameter.IntegerParameter",
      dimension = 2 * length(unique(ranges$taxon)) - 2,
      value = 1
    )
  ))
  
  # extra parameters we might need around the script
  extra_params <- c(rho = 5/36, removalProbability = 0)
  
  # operators
  operators <- list(
    FixMeanMutationRatesOperator = list(
      spec = "operator.kernel.BactrianDeltaExchangeOperator",
      delta = 0.75,
      weight = 2,
      parameter = setNames(as.list(paste0("mutationRate.s:morpho", 2:5)),
                           rep("parameter", 4)),
      weightvector = list(
        `weightparameter` = list(
          spec = "parameter.IntegerParameter",
          dimension = 4,
          estimate = "false",
          lower = 0,
          upper = 0,
          value = "76 36 7 4")
      )
    ))
  operators <- c(operators,
                 part_operators("morpho", partitions))
  operators <- append(operators, list(
    `originScalerFBD.t:tree` = list(
      spec = "ScaleOperator",
      parameter = "@originFBD.t:tree",
      weight = 3
    ),
    `divRateScalerFBD.t:tree` = list(
      spec = "ScaleOperator",
      parameter = "@diversificationRateFBD.t:tree",
      weight = 10
    ),
    `turnoverScalerFBD.t:tree` = list(
      spec = "ScaleOperator",
      parameter = "@turnoverFBD.t:tree",
      weight = 10
    ),
    `samplingPScalerFBD.t:tree` = list(
      spec = "ScaleOperator",
      parameter = "@samplingProportionFBD.t:tree",
      weight = 10
    )))
  
  
  # logs
  logs <- c(list(
    `posterior` = "posterior",
    `likelihood` = "likelihood",
    `prior` = "prior",
    `diversificationRateFBD.t:tree` = "diversificationRateFBD.t:tree",
    `turnoverFBD.t:tree` = "turnoverFBD.t:tree",
    `samplingProportionFBD.t:tree` = "samplingProportionFBD.t:tree",
    `originFBD.t:tree` = "originFBD.t:tree"),
    make_logs("treeLikelihood.", names(partitions)),
    make_logs("mutationRate.s:", paste0("morpho", 2:5)),
    make_logs("ucldMean.c:", "morpho"),
    make_logs("ucldStdev.c:", "morpho"),
    make_logs("rate.c:", "morpho"))
  
  # srfbd operators
  operators <- append(operators, list(
    `SRTreeRootScaler` = list(
      spec = "SAScaleOperator",
      rootOnly = "true",
      scaleFactor = 0.95,
      tree = "@Tree.t:tree",
      weight = 1
    ),
    `SRWilsonBalding` = list(
      spec = "SRWilsonBalding",
      tree = "@Tree.t:tree",
      weight = 20
    ),
    `LeftRightChildSwap` = list(
      spec = "LeftRightChildSwap",
      tree = "@Tree.t:tree",
      weight = 3
    ),
    `LeafToSampledAncestorJump` = list(
      spec = "SRLeafToSampledAncestorJump",
      tree = "@Tree.t:tree",
      weight = 10
    ),
    `SRUniformOperator` = list(
      spec = "SAUniform",
      tree = "@Tree.t:tree",
      weight = 20
    ),
    `SRTreeScaler` = list(
      spec = "SAScaleOperator",
      scaleFactor = 0.95,
      tree = "@Tree.t:tree",
      weight = 3
    )
  ))
  
  # srfbd logs
  logs <- c(logs, list(
    `srfbd` = "srfbd",
    `SACountFBD.t:tree` = list(
      spec = "sr.evolution.tree.SampledAncestorLogger",
      tree = "@Tree.t:tree"
    ),
    `treeHeight.t:tree` = list(
      spec = "beast.base.evolution.tree.TreeHeightLogger",
      tree = "@Tree.t:tree"
    )
  ))
  
  # get script name
  script_name <- paste0("srfbd_", attach, 
                        ifelse(suffix != "", "_", ""), suffix)
  
  # write scripts
  write_n_scripts(n_scripts, header, maps,
                  priors, operators, logs,
                  extra_params, ranges, mol = NULL, morpho,
                  partitions, attach,
                  n_gens, 1000000, 1000000,
                  paste0(base_dir, "scripts/"),
                  script_name)
  
}

# set script number
n_scripts <- 5

# number of generations
n_gens <- 1000000000

# write scripts
scripts_setup(n_scripts, n_gens, "both")
scripts_setup(n_scripts, n_gens, "first")