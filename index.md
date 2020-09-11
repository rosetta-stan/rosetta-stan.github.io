# Welcome to Rosetta Stan

Rosetta Stan plays a similar role to the <a [Rosetta Stone](href="https://en.wikipedia.org/wiki/Rosetta_Stone") in that it shows different ways to model in common packages using the same data and interface language. Each "stone" is a directory with a descriptive name, for example [simple linear regression](https://simple_linear_regression) has:
  * Both R (run.R) and Python(run.py) scripts to generate/access data and run the translations. The scripts are interfaces to the various packages and they do roughly the same thing. 
  * If a package has both R and Python interfaces then the framework will be in both run scripts, e.g., Stan. 
  * Documentation will be minimal but links will be provided to relevant resources. 
  * If the number of translations or amount of code becomes unmanageable then then directories will have a prefix indicating the common topic and the suffix detailing the packages covered. So simple linear regression has [simple_linear_regresion_stan_users_guide]() covers the varioius implementations from the Stan User's Guide, [simple_linear_regression_keras_lme4](). 
  
The current set of stones are:

  * Simple Linear Regression
  ** [simple_linear_regresion_stan_users_guide]()
  ** [simple_linear_regresion_stan_lme4_rstanarm]()
  ** [simple_linear_regresion_stan_keras]()

e.g., simple linear regression in Python, R using Stan, RStanArm, . Like the our inspiration, the site is driven by examples leaving it to the reader to sort out the translation. The Stan environment is the common element across all the translations. 

Each "stone"  

We welcome external contributions. The repo is at [https://github.com/rosetta-stan/rosetta-stan.github.io](https://github.com/rosetta-stan/rosetta-stan.github.io) where contributions can be made or you can reach out to Breck at <a href="mailto:fbb2116@columbia.edu">fbb2116@columbia.edu</a>
