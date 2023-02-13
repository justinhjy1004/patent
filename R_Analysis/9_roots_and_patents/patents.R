library(tidyverse)

df <- read_csv("roots_and_patents.csv")

summary(lm(log(avg_citation) ~ log(num_fine_roots), df))

hist(df$avg_citation)
