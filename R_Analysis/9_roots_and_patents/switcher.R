library(tidyverse)

df <- read_csv("switchers.csv")

df <- df %>%
  mutate(assignee_id = factor(assignee_id)) %>%
  mutate(switch = as.ordered(switch)) %>%
  mutate(nber_category = factor(nber_category)) %>%
  mutate(count = 1) %>%
  group_by(assignee_id, switch) %>%
  mutate(count = cumsum(count))

summary(lm(log(num_citation) ~ switch + count + assignee_id, df))
