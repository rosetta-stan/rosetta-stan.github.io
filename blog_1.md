# Working with posteriors in the context of inference and AI

In learning Bayesian methods writ Stan I have been casting about trying to find places where posteriors are useful for inference. I found myself writing a regexp to match some text from a web page scraper and needed to extract a number from text like `There are 4,203 downloads` with an expression like `There are ([\\d+,]) downloads` where `([\\d+,])` matches a sequence of numbers and commas. 

Regular expressions are not probabilistic at all in conception. They match a string/character sequence or they don't. But that is a lie. Given any string/regular expresion pair t
