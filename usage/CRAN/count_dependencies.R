avail_pks <- available.packages()

blah = vector(mode = "list", length = length(avail_pks[, "Package"]))
deps = tools::package_dependencies(packages = avail_pks[, "Package"], recursive = TRUE)
beeoboo = c()
for (j in 1:length(deps)) {
  if ("rstan" %in% deps[[j]]) {
    beeoboo = c(beeoboo, names(deps[j]))
  }
}
print(beeboo)

beeoboo
# [1] "adnuts"             "autoTS"             "baggr"              "BANOVA"            
# [5] "bayes4psy"          "bayesbr"            "bayesdfa"           "bayesGAM"          
# [9] "BayesianFROC"       "BayesSenMC"         "bayesvl"            "beanz"             
# [13] "bellreg"            "bkmrhat"            "blavaan"            "bmgarch"           
# [17] "bmlm"               "bmscstan"           "bpcs"               "breathteststan"    
# [21] "brms"               "brxx"               "bsem"               "CausalQueries"     
# [25] "cbq"                "clinDR"             "CNVRG"              "conStruct"         
# [29] "CopulaDTA"          "ctsem"              "ctsemOMX"           "DAMisc"            
# [33] "dclone"             "dcmle"              "DCPO"               "DeLorean"          
# [37] "densEstBayes"       "dfped"              "dfpk"               "DrBats"            
# [41] "edstan"             "eefAnalytics"       "eggCounts"          "embed"             
# [45] "EpiNow2"            "escalation"         "ESTER"              "evidence"          
# [49] "fable.prophet"      "fergm"              "fishflux"           "FlexReg"           
# [53] "gastempt"           "ggfan"              "ggstatsplot"        "glmmfields"        
# [57] "GPP"                "gppm"               "GPRMortality"       "hBayesDM"          
# [61] "HCT"                "hsstan"             "iCARH"              "JMbayes"           
# [65] "llbayesireg"        "MADPop"             "MCMCvis"            "metaBMA"           
# [69] "MetaStan"           "MIXFIM"             "modeltime"          "modeltime.ensemble"
# [73] "modeltime.gluonts"  "modeltime.resample" "mrbayes"            "multinma"          
# [77] "OncoBayes2"         "PandemicLP"         "pcFactorStan"       "pivmet"            
# [81] "pollimetry"         "PosteriorBootstrap" "precautionary"      "promotionImpact"   
# [85] "prophet"            "psrwe"              "publipha"           "PVAClone"          
# [89] "qmix"               "rater"              "RBesT"              "Replication"       
# [93] "Rlgt"               "rmdcev"             "rmsb"               "rstanarm"          
# [97] "rstanemax"          "rstap"              "sharx"              "shinybrms"         
# [101] "shinystan"          "spatialfusion"      "spsurv"             "ssMousetrack"      
# [105] "statsExpressions"   "survHE"             "themetagenomics"    "thurstonianIRT"    
# [109] "tidyBF"             "tidyposterior"      "tmbstan"            "trialr"            
# [113] "varian"             "visit"              "walker"             "YPBP"              
# [117] "YPPE"     