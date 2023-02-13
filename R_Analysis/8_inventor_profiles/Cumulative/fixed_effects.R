library(tidyverse)
library(plm)

# Reading CSV files
df_sig <- read_csv("inventor_profiles_cumulative_sig.csv")
df_random <- read_csv("inventor_profiles_cumulative_random.csv")
df_top <- read_csv("inventor_profiles_cumulative_top.csv")

peak <- function(df) {
  max_citation <- df %>% 
    group_by(inventor_id) %>%
    mutate(max_citation = ifelse(num_citations == max(num_citations), 1, 0)) %>%
    mutate(max_citation_date = max_citation*patent_date) %>%
    mutate(max_citation_date = ifelse(max_citation_date == 0, max(max_citation_date), max_citation_date)) %>%
    mutate(peaked = ifelse(patent_date < max_citation_date, 0, 1)) %>%
    mutate(has_new_inventor = ifelse(new_inventor == 0, 0, 1)) %>%
    mutate(has_new_assignee = ifelse(new_assignee == 0, 0, 1))
  
  return(max_citation)
}

# Convert files by adding peaked info
df_sig <- peak(df_sig)
df_random <-  peak(df_random)
df_top <-  peak(df_top)

# New Inventor and Assignee
fixed_sig <- plm(new_inventor ~ new_assignee, data=df_sig, index=c("inventor_id"), model="within")
summary(fixed_sig)
fixed_rand <- plm(new_inventor ~ new_assignee, data=df_random, index=c("inventor_id"), model="within")
summary(fixed_rand)
fixed_top <- plm(new_inventor ~ new_assignee, data=df_top, index=c("inventor_id"), model="within")
summary(fixed_top)

# Peak and Inventor
fixed_sig <- plm(new_inventor ~ peaked + mid_career, data=df_sig, index=c("inventor_id"), model="within")
summary(fixed_sig)
fixed_rand <- plm(new_inventor ~ peaked + mid_career, data=df_random, index=c("inventor_id"), model="within")
summary(fixed_rand)
fixed_top <- plm(new_inventor ~ peaked + mid_career, data=df_top, index=c("inventor_id"), model="within")
summary(fixed_top)

# Peak and Assignee
fixed_sig <- plm(new_assignee ~ peaked + mid_career, data=df_sig, index=c("inventor_id"), model="within")
summary(fixed_sig)
fixed_rand <- plm(new_assignee ~ peaked + mid_career, data=df_random, index=c("inventor_id"), model="within")
summary(fixed_rand)
fixed_top <- plm(new_assignee ~ peaked + mid_career, data=df_top, index=c("inventor_id"), model="within")
summary(fixed_top)

# Peak and Num Citations
fixed_sig <- plm(num_citations ~ peaked, data=df_sig, index=c("inventor_id"), model="within")
summary(fixed_sig)
fixed_rand <- plm(num_citations ~ peaked, data=df_random, index=c("inventor_id"), model="within")
summary(fixed_rand)
fixed_top <- plm(num_citations ~ peaked, data=df_top, index=c("inventor_id"), model="within")
summary(fixed_top)

# Peak and team size
fixed_sig <- plm(team_size ~ peaked, data=df_sig, index=c("inventor_id"), model="within")
summary(fixed_sig)
fixed_rand <- plm(team_size ~ peaked, data=df_random, index=c("inventor_id"), model="within")
summary(fixed_rand)
fixed_top <- plm(team_size ~ peaked, data=df_top, index=c("inventor_id"), model="within")
summary(fixed_top)

mid_career <- function(df) {
  mid_life <- df %>% 
    group_by(inventor_id) %>%
    mutate(mid_career = row_number()) %>%
    mutate(mid_career = ifelse(mid_career < median(mid_career), 0, 1))
  
  return(mid_life)
}

# Convert files to add mid career control
df_sig <- mid_career(df_sig)
df_random <-  mid_career(df_random)
df_top <- mid_career(df_top)

# Mid career and peak
fixed_sig <- plm(peaked ~ mid_career, data=df_sig, index=c("inventor_id"), model="within")
summary(fixed_sig)
fixed_rand <- plm(peaked ~ mid_career, data=df_random, index=c("inventor_id"), model="within")
summary(fixed_rand)
fixed_top <- plm(peaked ~ mid_career, data=df_top, index=c("inventor_id"), model="within")
summary(fixed_top)

### USING HAS_NEW (Indicator Variable)

# New Inventor and Assignee
fixed_sig <- plm(has_new_inventor ~ has_new_assignee, data=df_sig, index=c("inventor_id"), model="within")
summary(fixed_sig)
fixed_rand <- plm(has_new_inventor ~ has_new_assignee, data=df_random, index=c("inventor_id"), model="within")
summary(fixed_rand)
fixed_top <- plm(has_new_inventor ~ has_new_assignee, data=df_top, index=c("inventor_id"), model="within")
summary(fixed_top)

# Peak and Inventor
fixed_sig <- plm(has_new_inventor ~ peaked + mid_career, data=df_sig, index=c("inventor_id"), model="within")
summary(fixed_sig)
fixed_rand <- plm(has_new_inventor ~ peaked + mid_career, data=df_random, index=c("inventor_id"), model="within")
summary(fixed_rand)
fixed_top <- plm(has_new_inventor ~ peaked + mid_career, data=df_top, index=c("inventor_id"), model="within")
summary(fixed_top)

# Peak and Assignee
fixed_sig <- plm(has_new_assignee ~ peaked + mid_career, data=df_sig, index=c("inventor_id"), model="within")
summary(fixed_sig)
fixed_rand <- plm(has_new_assignee ~ peaked + mid_career, data=df_random, index=c("inventor_id"), model="within")
summary(fixed_rand)
fixed_top <- plm(has_new_assignee ~ peaked + mid_career, data=df_top, index=c("inventor_id"), model="within")
summary(fixed_top)
