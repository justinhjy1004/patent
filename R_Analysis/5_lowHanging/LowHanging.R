library(tidyverse)

df <- read_csv("sample_patents_stats.csv")

# General description of the data
lmod <- lm(log(edge_density)~log(unq_assignees), df)
summary(lmod)

lmod <- lm(log(num_edge)~log(unq_assignees), df)
summary(lmod)

lmod <- lm(log(edge_density)~log(unq_assignees) + log(num_edge), df)
summary(lmod)

lmod <- lm(log(edge_density) ~ log(unq_inventors), df)
summary(lmod)

lmod <- lm(log(edge_density) ~ log(unq_inventors) + log(num_edge), df)
summary(lmod)

lmod <- lm(log(edge_density) ~ log(unq_inventors) + log(num_edge) + log(unq_assignees), df)
summary(lmod)

lmod <- lm(log(edge_density) ~ log(num_edge), df)
summary(lmod)

# Plot inventors and edge density
ggplot(data=df) +
  geom_point(aes(x=log(edge_density),y=log(unq_inventors), col=log(num_edge)), size=1) +
  theme_light() +
  xlab("log(Edge Density)") +
  ylab("log(Unique Inventors)") +
  ggtitle("Edge Density vs Unique Inventors")

# Plot assignees and edge density
ggplot(data=df) +
  geom_point(aes(x=log(edge_density),y=log(unq_assignees), col=log(num_edge)), size=1) +
  theme_light() +
  xlab("log(Edge Density)") +
  ylab("log(Unique Assignees)") +
  ggtitle("Edge Density vs Unique Assignees")

# Claims and assignees and inventors
lmod <- lm(log(avg_claims)~log(unq_assignees), df)
summary(lmod)

lmod <- lm(log(avg_claims)~log(unq_inventors), df)
summary(lmod)

lmod <- lm(log(avg_claims)~log(unq_inventors) + log(unq_assignees), df)
summary(lmod)

lmod <- lm(log(avg_claims)~log(unq_inventors) + log(edge_density), df)
summary(lmod)

lmod <- lm(log(edge_density)~avg_sim,df)
summary(lmod)

lmod <- lm(log(edge_density)~log(avg_claims),df)
summary(lmod)
