library(tidyverse)

nodes <- read_csv("posts/data/example_parent_child_nodes.csv") %>%
         rowwise() %>%
         mutate(child_words = paste(child, child_plural, sep = "|")) %>%
         select(-child_plural)

nodes <- tibble(parent = "people", child = "mother", child_words = "mom|moms|ma|mamas") %>%
  bind_rows(nodes)

nodes <- tibble(parent = "people", child = "father", child_words = "dad|dads|papa|papas") %>%
  bind_rows(nodes)

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

#nodes <- bind_rows(nodes,
#                   tibble(parent = "events", child = "birth", child_words = "birth|births|born"))

nodes <- unnest_tokens(nodes, child_words, child_words, drop = FALSE)

nodes <- bind_rows(nodes,
                   tibble(parent = "events", child = "death", child_words = "dying"))

nodes <- filter(nodes,
                parent %in% c("people", "places", "events"),
                !child %in% c("murder"))

nodes <- bind_rows(nodes %>% filter(parent == "people") %>% arrange(child),
                   nodes %>% filter(parent != "people") %>% arrange(desc(parent), child))

write_csv(nodes, "posts/data/people_codes.csv")
write_csv(nodes, "_site/posts/data/people_codes.csv")
