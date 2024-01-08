library(tidyverse)

tv_shows <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-04-20/netflix_titles.csv')  %>%
  rename(genre = listed_in) %>%
  filter(str_detect(genre, "Kids|Children"))


write_csv(tv_shows, "posts/data/kids_netflix_shows.csv")
write_csv(tv_shows, "_site/posts/data/kids_netflix_shows.csv")
