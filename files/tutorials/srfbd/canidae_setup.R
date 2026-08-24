#########################################################
##          Setup for canid SRFBD analysis             ##
##   Palaeoverse tutorial - Bruno do Rosario Petrucci  ##
#########################################################

###
# source xml_writer.R
source(paste0(base_dir, "xml_writer.R"))

###
# write scripts

# function to write scripts for a given setup
# can alter the specific priors, operators etc. within this function
# and then use the arguments to create scripts with a specific MCMC setup
scripts_setup <- function(n_scripts, n_gens, attach, 
                          scripts_dir, log_every, store_every,
                          suffix = "") {
  # header and maps--templates needed for the script
  header <- readLines(paste0(base_dir, "header.xml"))
  maps <- readLines(paste0(base_dir, "maps.xml"))
  
  # data--ranges and morphological matrix
  # if we had DNA, we would also read it here
  ranges <- read.delim(paste0(base_dir, "data/canidae_ranges.tsv"))
  morpho <- read.nexus.data(paste0(base_dir, "data/canidae_morpho.nex"))
  
  # rewrite polymorphisms--make sure they are written in the way BEAST2 expects
  morpho <- rewrite_polymorphisms(morpho)
  
  # build morphological partitions in a BEAST2-readable way
  morpho_partitions <- morpho_partitions(morpho, ascertain = TRUE)
  # we are partitioning by state number (2-5)
  
  # start partitions list
  partitions <- list()
  
  # if you have DNA in your dataset as well, you can
  # start your partition with the DNA parameters
  # partitions <- list(DNA = list(
  #   data = "mol",
  #   filter = paste0("1-", length(mol[[1]])),
  #   ascertained = "false",
  #   dataType = NULL,
  #   siteModel = list(
  #     id = "SiteModel.s:mol",
  #     gammaCategoryCount = 0,
  #     shape = 1,
  #     mutationRate = 1,
  #     proportionInvariant = 0,
  #     substModel = list(
  #       model = "jc"
  #     )),
  #   branchRateModel = list(
  #     id = "RelaxedClock.c:DNA",
  #     model = "ucld",
  #     clock.rate = "@clock.c:DNA",
  #     rateCategories = "@rateCategories.c:DNA",
  #     dist = "LogNormal",
  #     M = 1,
  #     S = "@ucldStdev.c:DNA"
  #   ),
  #   threaded = TRUE))
  # this is an example for JC+UCLN
  # of course then you'll need to add priors and operators for
  # these parameters as well
  
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
          # currently xml_writer accommodates LewisMK for morphology,
          # and Jukes-Cantor and HKY for molecular data
        )
      ),
      threaded = FALSE)
    
    # we only add a branch rate model for the first partition
    # all other ones just use this same clock
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
  # parameters without a dist element will not have an explicit prior attached
  priors = list(
    # mutation rates are moved by an operator, 
    # but do not require their own prior
    # if you had a strict clock model, you could 
    # omit the mutation rate parameters
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
      # we set an initial value much higher than the oldest fossil
      # because drawing from the prior might lead to value that is 
      # too low, leading to an analysis not starting
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
  
  # rate categories doesn't need a prior, but we need
  # to calculate the total dimension (number of branches)
  priors <- append(priors, list(
    `rateCategories.c:morpho` = list(
      spec = "parameter.IntegerParameter",
      dimension = 2 * length(unique(ranges$taxon)) - 2,
      value = 1
    )
  ))
  
  # extra parameters for the model
  # extant sampling and probability of extinction when sampled
  extra_params <- c(rho = 5/36, removalProbability = 0)
  
  # operators--just the default, nothing fancy
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
        # number of characters with each number of states (2-5)
      )
    ))
  
  # add the operators for morphological evolution model parameters
  operators <- c(operators,
                 part_operators("morpho", partitions))
  
  # add the SRFBD operators
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
    ),
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
    )))
  
  # parameters you'd like to log
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
    make_logs("rate.c:", "morpho"),
    list(
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
  
  # set script name
  # suffix is here in case you want to set up analyses with an extra
  # little name at the end, e.g. srfbd_first_strict.xml if you want
  # to test a strict clock, suffix = "strict"
  script_name <- paste0("srfbd_", attach, 
                        ifelse(suffix != "", "_", ""), suffix)
  
  # write scripts
  write_n_scripts(n_scripts, header, maps,
                  priors, operators, logs,
                  extra_params, ranges, mol = NULL, morpho,
                  partitions, attach,
                  n_gens, log_every, store_every,
                  scripts_dir,
                  script_name)
  
}