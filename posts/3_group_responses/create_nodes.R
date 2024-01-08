library(tidyverse)

nodes <- read_csv("posts/data/example_parent_child_nodes.csv") %>%
         rowwise() %>%
         mutate(child_words = paste(child, child_plural, sep = "|")) %>%
         select(-child_plural)

nodes <- tibble(parent = "people", child = "human", child_words = "human|humans") %>%
         bind_rows(nodes)

nodes <- tibble(parent = "people", child = "uncle", child_words = "uncle|uncles") %>%
  bind_rows(nodes)

nodes <- tibble(parent = "people", child = "aunt", child_words = "aunt|aunts") %>%
  bind_rows(nodes)

nodes <- tibble(parent = "people", child = "grandma", child_words = "grandma|grandmas|grandmother|grandmothers") %>%
  bind_rows(nodes)

nodes <- tibble(parent = "people", child = "grandpa", child_words = "grandpa|grandpas|grandfather|grandfathers") %>%
  bind_rows(nodes)

nodes <- unnest_tokens(nodes, child_words, child_words, drop = FALSE)

nodes <- filter(nodes, parent %in% c("people"))

write_csv(nodes, "posts/data/people_nodes.csv")
write_csv(nodes, "_site/posts/data/people_nodes.csv")
