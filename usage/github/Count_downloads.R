library(ggplot2)

version <-c(2.25,2.24,2.23,2.22,2.21,2.20,2.19,2.18,2.17,2.16,2.15,2.14)
downloads <- c(6329,3012,316,66,2129,577,185,612,65,19,34,1245)

cmdstan.df <- data.frame(version,downloads)

ggplot(aes(x=version,y=downloads),
       data=cmdstan.df) +
  scale_x_continuous("version", labels = as.character(version), breaks = version) +
  geom_point()+
  geom_line()+
  labs(title = "Downloads of CmdStan from github.com by version")
