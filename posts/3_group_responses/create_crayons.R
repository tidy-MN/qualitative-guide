library(tidyverse)

crayons <- tibble(id = 1:12,
                  name = c("Brick Red",
                           "Vibrant Orange",
                           "Warm Yellow",
                           "Slate Green",
                           "Indigo Blue",
                           "Grey Black",
                           "Plum Purple",
                           "Beige Brown",
                           "Denim Blue",
                           "Incredible Pink",
                           "Sap Green",
                           "Cloudy Off-White")) %>%
          mutate(name = tolower(name))

write_csv(crayons, "posts/data/crayons.csv")
write_csv(crayons, "_site/posts/data/crayons.csv")
