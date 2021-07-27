library(tidyverse)

df <- read_csv("intrapatent.csv")

hist(df$intra_sim, xlab="Intrapatent Inventor Similarity", main="Histogram of Intrapatent Inventor Similarity")
