library(tidyverse)

df <- read_csv("sample_patents_stats.csv")

df <- df %>%
  mutate(theoretical_max = num_edge/(0.5*num_patents*(num_patents+1)))

df_norm <- df %>%
  mutate(unq_assignees = unq_assignees/num_patents) %>%
  mutate(unq_inventors = unq_inventors/num_patents)

ggplot(data = df) + 
  geom_point(aes(x=num_patents,y=theoretical_max))

poisson_glm <- glm(log(edge_density) ~ log(unq_assignees) + log(unq_inventors),
                   family="poisson", data = df_norm)
summary(poisson_glm)

lmod <- lm(log(edge_density) ~ log(unq_assignees) + log(unq_inventors),
           df_norm)
summary(lmod)
