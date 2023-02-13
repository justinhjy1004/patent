library(tidyverse)

# Function to identify the 'peak' of an inventor
peak <- function(df) {
  max_citation <- df %>% 
    group_by(inventor_id) %>%
    mutate(max_citation = ifelse(num_citations == max(num_citations), 1, 0)) %>%
    mutate(max_citation_date = max_citation*patent_date) %>%
    mutate(max_citation_date = ifelse(max_citation_date == 0, max(max_citation_date), max_citation_date)) %>%
    mutate(peaked = ifelse(patent_date < max_citation_date, 0, 1))
  
  return(max_citation)
}

# Successful inventor profiles
df_top <- read_csv("inventor_profiles_top_citations.csv")
df_sig <- read_csv("inventor_profiles_successful.csv")
df_sample <- read_csv("inventor_profiles_sampled.csv")

# Getting 'peaked data'
df_top <- peak(df_top)
df_sig <- peak(df_sig)
df_sample <- peak(df_sample)

# Getting max citations
df_top$inventor_dummy <- factor(df_top$inventor_id)
df_sig$inventor_dummy <- factor(df_sig$inventor_id)
df_sample$inventor_dummy <- factor(df_sample$inventor_id)

# Top Inventors
lmod <- lm(same_prev_team ~ peaked + inventor_dummy, df_top)
summary(lmod)
lmod <- lm(same_prev_assignee ~ peaked + inventor_dummy, df_top)
summary(lmod)

# Significant Inventors
lmod <- lm(same_prev_team ~ peaked + inventor_dummy, df_sig)
summary(lmod)
lmod <- lm(same_prev_assignee ~ peaked + inventor_dummy, df_sig)
summary(lmod)

# Sampled Inventors
lmod <- lm(same_prev_team ~ peaked + inventor_dummy, df_sample)
summary(lmod)
lmod <- lm(same_prev_assignee ~ peaked + inventor_dummy, df_sample)
summary(lmod)

fixed_top <- plm(same_prev_team ~ peaked, data=df_top, index=c("inventor_id"), model="within")
summary(fixed_top)
