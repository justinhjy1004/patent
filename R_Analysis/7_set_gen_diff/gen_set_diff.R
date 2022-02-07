library(tidyverse)

df <- read_csv("generation.csv")
df_set <- read_csv("gen_set_diff.csv")

# "Left" and "Right" pair of the combination
df_set <- df_set %>%
  mutate(left_pair = as.numeric(substr(combination,2,2))+1) %>%
  mutate(right_pair = as.numeric(substr(combination,5,5))+1)

# Relevant columns in df set
df_left <- df %>%
  select(c(root,gen,inventor, assignee, location)) %>%
  rename(left_pair = gen) %>%
  rename(left_inventor = inventor) %>%
  rename(left_assignee = assignee) %>%
  rename(left_location = location)

df_right <- df %>%
  select(c(root,gen,inventor, assignee, location)) %>%
  rename(right_pair = gen) %>%
  rename(right_inventor = inventor) %>%
  rename(right_assignee = assignee) %>%
  rename(right_location = location)

# Join relevant values
df_set <- df_set %>%
  left_join(df_left, by = c('root','left_pair')) %>%
  left_join(df_right, by = c('root','right_pair'))

# Calculate Unions and Intersects
df_set <- df_set %>%
  mutate(cup_inventors = left_inventor + right_inventor) %>%
  mutate(cup_assignees = left_assignee + right_assignee) %>%
  mutate(cup_locations = left_location + right_location) %>%
  mutate(cap_inventors = cup_inventors*inventor) %>%
  mutate(cap_assignees = cup_assignees*assignee) %>%
  mutate(cap_locations = cup_locations*location)

