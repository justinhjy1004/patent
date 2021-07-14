library(tidyverse)

df <- read_csv("inventor_sim.csv")
df <- df[!is.na(df$sim),]

lmod <- lm(sim~hops, df)
summary(lmod)

ggplot(data=df, aes(x=hops, y=sim)) +
  geom_point(color="red") +
  geom_smooth() +
  ggtitle("Similarity Score v. Number of Hops") +
  xlab("Number of Hops") +
  ylab("Dot Product Similarity") +
  theme_minimal()

mean_sim <- df %>%
  group_by(hops) %>%
  summarize(avg = mean(sim))

sd_sim <- df %>%
  group_by(hops) %>%
  summarize(sd = sd(sim))

inventor_sim <- df %>%
  group_by(inventor,hops) %>%
  summarize(avg = mean(sim))

inventor_sim <- inventor_sim[inventor_sim$hops != 0,]
