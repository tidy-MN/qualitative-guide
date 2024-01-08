library(tidyverse)

nodes <- read_csv("posts/data/example_parent_child_nodes.csv") %>%
         rowwise() %>%
         mutate(child = paste(child, child_plural, sep = "|")) %>%
         select(-child_plural)

nodes <- tibble(parent = "people", child = "human|humans") %>%
         bind_rows(nodes)

write_csv(nodes, "posts/data/tv_parent_child_nodes.csv")
write_csv(nodes, "_site/posts/data/tv_parent_child_nodes.csv")
