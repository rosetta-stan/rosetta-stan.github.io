---
layout: default
title: Stones
---

# Translation Stones
Stones are translations of the same model and data into various frameworks as well as a .stan program. Each stone is a directory containing run.* programs that runs the relevant `translations` over the same data with the same model. At the very least you can expect to see:
* A page describing what is being translated at a high level in index.md
* A run.R and run.py that interface with either data or simulate data and run the .stan and translations appropriate for the interface language.
* A run.sh that runs the .stan program minimally using the `cmdstan` interface to Stan.

# Stones
* [One parameter linear regression from simulated data](one_param_linear_regression)
