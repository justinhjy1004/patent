library(tidyverse)

df <- read_csv("interpatent.csv")

# Log transformation of "combination"
df['combination'] <- lapply(df['combination'], log)

# Histogram of log(Combination)
hist(df$combination, 
     xlab="log(Number of Pairwise Combination)",
     col="pink",
     main="Histogram of Pairwise Combination")

# Create bar graph of frequency for each hop
bar <- df %>%
  mutate(count = 1) %>%
  group_by(hops) %>%
  summarize(freq = sum(count))

ggplot(data = bar, aes(x=hops,y=freq)) +
  geom_bar(stat='identity', col='pink', fill='pink') +
  theme_minimal() +
  ylab("frequency") +
  ggtitle("Distribution of Hops")

# Histogram of Inventor Similarity
hist(df$inventor_sim,
     xlab="Inventor Similarity",
     main="Histogram of Inventor Similarity",
     col='pink')

# Histogram of Patent Similarity
hist(df$similarity,
     xlab="Patent Similarity",
     main="Histogram of Patent Similarity",
     col='pink')

# lm and plot for values 
lmod <- lm(similarity ~ inventor_sim, df)
summary(lmod)

lmod2 <- lm(similarity ~ combination, df)
summary(lmod2)

lmod3 <- lm(inventor_sim ~ combination, df)
summary(lmod3)

lmod4 <- lm(similarity ~ combination + inventor_sim, df)
summary(lmod4)

df["lmod_residuals"] <- lmod$residuals

lmod5 <- lm(lmod_residuals ~ combination, df)
summary(lmod5)

lmod6 <- lm(inventor_sim ~ hops, df)
summary(lmod6)

ggplot(data = df, aes(x=similarity, y=combination, color=hops)) + 
  geom_point(size=0.1) + 
  geom_smooth(col='red') + 
  theme_minimal() +
  xlab("Patent Similarity") + 
  ylab("log(Number of Pairwise Combination)") + 
  ggtitle("Patent Similarity and # Pairwise Combination")

ggplot(data = df, aes(x=inventor_sim, y=combination, color=hops)) + 
  geom_point(size=0.1) + 
  geom_smooth(col='red') + 
  theme_minimal() +
  xlab("Inventor Similarity") + 
  ylab("log(Number of Pairwise Combination)") + 
  ggtitle("Inventor Similarity and # Pairwise Combination")

ggplot(data = df, aes(x=similarity, y=inventor_sim, color=hops)) + 
  geom_point(size=0.1) + 
  geom_smooth(col='red') + 
  theme_minimal() +
  xlab("Patent Similarity") + 
  ylab("Inventor Similarity") + 
  ggtitle("Patent Similarity and Inventor Similarity")

ggplot(data = df, aes(x=combination, y=lmod_residuals, color=hops)) + 
  geom_point(size=0.1) + 
  geom_smooth(col='red') + 
  theme_minimal() +
  xlab("log(# Pairwise Combination)") + 
  ylab("Residuals Inventor Patent~Inventor") + 
  ggtitle("Residuals for Patent~Inventor and Combination")
