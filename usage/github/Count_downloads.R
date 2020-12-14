library(ggplot2)

version <-   c(2.25,2.24, 2.23, 2.22,2.21, 2.20,  2.19,       2.18,     2.17,      2.16,   2.15, 2.14,    2.131,      2.12, 2.11,   2.10,  2.09,2.08, 2.07,    2.06,    2.05,  2.04,2.03)
downloads <- c(6329,3012, 5702,  152,5999, 2373,  400 , 516 + 1603,1381 + 394,511 + 260,501+481,892+4480, 349+54,627 + 504,274+298,421+187,1229+953,398+321,553+291, 629+482, 1071,517,421)

cmdstan.df <- data.frame(version,downloads)

ggplot(aes(x=version,y=downloads),
       data=cmdstan.df) +
  scale_x_continuous("version", labels = as.character(version), breaks = version) +
  geom_point()+
  geom_line()+
  labs(title = "Downloads of CmdStan from github.com by minor release version")
