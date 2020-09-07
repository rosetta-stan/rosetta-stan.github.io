# About this site

I am NOT a statistician and in the limit maybe no one is. This site is the site I would have appreciated as a fairly good computational linguist with no background in statistics and not a lot of math talent. But I have preservered and wish to help others on the path. I have suffered so you don't have to. 

So this site is organized to help programmers use Bayesian techniques as well as help staticians transition from whatever framework they prefer to a Bayesian framework--hence the play on words with Rosetta Stone. Instead of translations of ancient Greek into Egyptian hyroglyphics see:(Rosetta Stone)[https://en.wikipedia.org/wiki/Rosetta_Stone] we offer various implementations of the same data/inferential goal in lme4, tensor flow, etc. and Stan programs. I'll offer a direct quote from the wikipedia page: "The term Rosetta Stone is now used to refer to the essential clue to a new field of knowledge." Your new field of knowledge is Bayesian inference. So there. 

Most of this content is written while drinking beer, while confessory that is not the point because divulging it serves a different goal which is reducing expectations. Everything I do is approximate, loosey-goosey information from what I have figured out so far. Bayesian modeling is an approximate enterprise with many more ways to fall off the mountain than stay on the ridge of enlightenment so beer driven writing fits the overall approach. 

We should talk about enlightenment. You want enough information to make the next informed result, not decompile the universe. 



# Working with posteriors in the context of inference and AI

In learning Bayesian methods writ Stan I have been casting about trying to find places where posteriors are useful for inference. I found myself writing a regexp to match some text from a web page scraper and needed to extract a number from text like `There are 4,203 downloads` with an expression like `There are ([\\d+,]) downloads` where `([\\d+,])` matches a sequence of numbers and commas. 

Regular expressions are not probabilistic at all in conception. They match a string/character sequence or they don't. But that is a lie. Given any string/regular expresion pair t
