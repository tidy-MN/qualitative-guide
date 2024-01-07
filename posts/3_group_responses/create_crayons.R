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
                           "Grayish Pink",
                           "Sap Green",
                           "Cloudy Off-White"))

write_csv(crayons, "posts/data/crayons.csv")
