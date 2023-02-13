library(tidyverse)

df <- read_csv("generation.csv")

df_lag <- df %>% 
  group_by(root) %>%
  mutate(inv_lag = lag(inventor)) %>%
  mutate(assignee_lag = lag(assignee)) %>%
  mutate(claims_lag = lag(claims)) %>%
  mutate(sim_lag = lag(similarity)) %>%
  mutate(loc_lag = lag(location)) %>%
  mutate(root = factor(root)) %>%
  mutate(id_lag = lag(id)) %>%
  mutate(gen = factor(gen))

m <- lm(inventor ~ inv_lag*gen + root, df_lag)
summary(m)

m <- lm(log(inventor) ~ log(inv_lag) + root + gen, df_lag)
summary(m)

# Lag Inventors and Number of Patents
m1 <- lm(log(id) ~ log(inv_lag) + root, df_lag)
summary(m1)

ggplot(data = df_lag) +
  geom_point(aes(x=log(id),y=log(inv_lag))) +
  theme_light() + 
  xlab("Number of Patents at Generation g") + 
  ylab("Number of Inventors at Generation g-1") + 
  ggtitle("Number of Patents and Lag Number of Inventors") +
  geom_smooth(aes(x=log(id),y=log(inv_lag)),method='lm')

# Lag Assignees and Number of Patents
m2 <- lm(log(id) ~ log(assignee_lag) + root, df_lag)
summary(m2)

ggplot(data = df_lag) +
  geom_point(aes(x=log(id),y=log(assignee_lag))) +
  theme_light() + 
  xlab("Number of Patents at Generation g") + 
  ylab("Number of Assignees at Generation g-1") + 
  ggtitle("Number of Patents and Lag Number of Assignees") +
  geom_smooth(aes(x=log(id),y=log(assignee_lag)),method='lm')


# Assignees and Inventors and Number of Patents
m3 <- lm(log(id) ~ log(inv_lag) + log(assignee_lag) + root, df_lag)
summary(m3)

ggplot(data = df_lag) +
  geom_point(aes(x=log(id),y=log(inv_lag),color=log(assignee_lag))) +
  theme_bw() + 
  xlab("Number of Patents at Generation g") + 
  ylab("Number of Assignees at Generation g-1") + 
  ggtitle("Number of Patents and Lag Number of Inventors")

ggplot(data = df_lag) +
  geom_point(aes(x=log(id),y=log(inventor),color=log(assignee))) +
  theme_bw() + 
  xlab("Number of Patents at Generation g") + 
  ylab("Number of Assignees at Generation g") + 
  ggtitle("Number of Patents and Number of Assignees")
  

# Similarity and Patents
m4 <- lm(log(id) ~ log(similarity) + root, df_lag)
summary(m4)

m5 <- lm(log(id) ~ log(sim_lag) + root, df_lag)
summary(m5)

# Claims and Patents
m6 <- lm(log(id) ~ log(claims) + root, df_lag)
summary(m6)

m7 <- lm(log(id) ~ log(claims_lag) + root, df_lag)
summary(m7)

# Claims and Similarity
m8 <- lm(log(claims) ~ log(similarity) + root, df_lag)
summary(m8)

m13 <- lm(log(claims) ~ log(sim_lag) + root, df_lag)
summary(m13)

# Similarity and Claims and Patents
m9 <- lm(log(id) ~ log(claims) + log(similarity) + root, df_lag)
summary(m9)

m10 <- lm(log(id) ~ log(claims_lag) + log(similarity) + root, df_lag)
summary(m10)

m11 <- lm(log(id) ~ log(claims) + log(sim_lag) + log(claims_lag) + root, df_lag)
summary(m11)

m12 <- lm(log(id) ~ log(claims_lag) + log(sim_lag) + root, df_lag)
summary(m12)

# AutoRegression?
m14 <- lm(log(id) ~ log(id_lag) + root, df_lag)
summary(m14)

m15 <- lm(log(claims)~log(claims_lag) + root, df_lag)
summary(m15)

m16 <- lm(log(id)~log(similarity) + log(sim_lag)+root, df_lag)
summary(m16)

m17 <- lm(log(inventor) ~ log(inv_lag) + root, df_lag)
summary(m17)

m18 <- lm(log(assignee) ~ log(assignee_lag) + root, df_lag)
summary(m18)

# At time t itself
m1 <- lm(log(id) ~ log(inventor) + root, df_lag)
summary(m1)

m2 <- lm(log(id) ~ log(assignee) + root, df_lag)
summary(m2)

m3 <- lm(log(id) ~  log(inventor) + log(assignee) + root, df_lag)
summary(m3)

m4 <- lm(log(inventor) ~ log(assignee) + root, df_lag)
summary(m4)

m5 <- lm(log(id) ~ log(id_lag) + root, df_lag)
summary(m5)

# White Standard Errors
library("lmtest")
library("sandwich")

m1 <- lm(log(id) ~ log(inventor) + log(assignee) + root, df_lag)
coeftest(m1, vcov = vcovHC(m1, type = "HC0"))

m2 <- lm(lm(log(id) ~ log(inventor) + root, df_lag))
coeftest(m2, vcov = vcovHC(m2, type = "HC0"))

m3 <- lm(lm(log(id) ~ log(assignee) + root, df_lag))
coeftest(m3, vcov = vcovHC(m3, type = "HC0"))

m4 <- lm(log(id) ~ log(inv_lag) + log(assignee_lag) + root, df_lag)
coeftest(m4, vcov = vcovHC(m4, type = "HC0"))
