---
title: "3 — Group and code responses - test"
date: "2024-01-03"
date-modified: last-modified
format:
  html:
    toc: true
    toc-depth: 3
    warning: false
    message: false
categories: [code, group, themes]
---


## Crayon colors

<img src="" style="margin-right: 16px; margin-bottom: 2px; margin-left: -20px;" align="left" width="184" alt="A box of 12 Crayola crayons.">

Let's start simple and assign crayons a color based on their descriptive names. Below is a table of 12 crayons and their names. We want to create a group for each of the primary colors - `red`, `yellow`, and `blue` - and an everything-else group labeled `other`. 

We'll begin by searching for the primary color words in the name column of each of the crayons. If a color word is *detected*, it will be assigned to the appropriate group. 


### Load the data
```{r}
library(tidyverse)

crayons <- read_csv('https://tidy-mn.github.io/qualitative-guide/posts/data/crayons.csv') 

crayons
```


### Find color words

We'll use `case_when()` and `str_detect()` to test if a crayon name contains a given primary color word. If it does, we'll assign the crayon to that color. If none of the primary color words are detected, the crayon will be assigned to the group `other`.

```{r}
crayons_groups <- crayons %>%
                  mutate(group = case_when(str_detect(name, "red") ~ "RED",
                                           str_detect(name, "yellow") ~ "YELLOW",
                                           str_detect(name, "blue") ~ "BLUE",
                                           .default = "other"))

crayons_groups %>% head(5)
```


### Fuzzy join

The approach above works well for a small number of groups, but it can be cumbersome when you have lots of groups to assign. If we wanted to sort the crayons into many more color groups, a better approach would be to create a table to store our group names and the associated color word. 

Then we can use `fuzzyjoin` to join the groups table to the crayons table. The end result is the same, but it requires less code and will be much easier to update when we want to add new groups or change the words associated with a group.

Here's the same example as above using the new table approach.


### Create the group table

First, create a table of our groups with two columns:

- `group` The group name
- `word` The word associated with the group

```{r}
library(tidyverse)
library(fuzzyjoin)

color_groups <- tibble(group = c('RED','YELLOW','BLUE'), 
                       word = c("red", "yellow", "blue")) 
```


### Join groups with fuzzy_left_join

Now we can join our two tables using the `name` column in the *crayons* table, and the `word` column in the *color_groups* table. The function used to search text for a given word is `str_detect`, which tests whether a given color word occurs anywhere in the crayon's name. 

```{r}
crayons_groups <- crayons %>%
                  fuzzy_left_join(color_groups, 
                                  by = join_by(name == word), 
                                  match_fun = str_detect)

crayons_groups %>% head()
```


### Set group to "other" for the `NA`'s

Finally, we'll use `replace_na()` to assign the crayons without a color group to the group "other".

```{r}
crayons_groups <- crayons_groups %>%
                  replace_na(list(group = "other"))

crayons_groups %>%
  select(id, name, group) %>%
  head(10)
```


> Wait...what about row number 10? That's interesting. 
>
> Why do you think the **incredible pink** crayon was assigned to the group `RED`?


### Finding complete words

In the example above, the function `str_detect()` looked for the occurrence of the designated letters anywhere in the crayon name. So the pattern of letters "r-e-d" is detected even if it occurs within another word. In this case, the pattern occurs within the name "inc**red**ible pink". That could be useful in some contexts, but in our current crayon situation, we only want to detect the word "red". 

To ensure the color "red" is only detected as a complete word, we can add a special character to the start and end of our search term. Adding the character `\\b` to both sides of "red" will require the letters "r-e-d" to occur as its own word and not as part of a longer word.

Finally, let's paste `\\b` to both sides of the color words in the *color_groups* table and then try our `fuzzy_left_join` one more time.

```{r}
color_groups <- color_groups %>%
                mutate(word = paste0("\\b", word, "\\b"))

# Join the groups again, but with the added separate word requirement
crayons_groups <- crayons %>%
                  fuzzy_left_join(color_groups, 
                                  by = join_by(name == word), 
                                  match_fun = str_detect)

crayons_groups %>%
  replace_na(list(group = "other")) %>%
  select(id, name, group) %>%
  head(10)
```


> **Success!**



## Assign umbrella groups: Parent and child nodes

We want to sort our crayons into primary colors and secondary colors. To do this we'll need to check a crayon name for multiple words. For example, a crayon will be assigned to the primary color group if any of the following words occur in its name: `red`, `yellow`, or `blue`.

The larger umbrella group is sometimes referred to as the *parent node*, and the individual terms that fall under it are its *children nodes*. Here's the table of our color groups in terms of parent and child nodes.

```{r}
color_group_nodes <- tribble(
  ~parent, ~child,
  "primary",   "red",
  "primary",   "yellow",
  "primary",   "blue",
  "secondary", "green",
  "secondary", "orange",
  "secondary", "purple",
)
```


## Fuzzy join primary and secondary

Now we can repeat our previous fuzzy join steps to assign each of the crayons to the groups: `primary`, `secondary`, or `other`.

```{r}
color_group_nodes <- color_group_nodes %>%
                     mutate(child_word = paste0("\\b", child, "\\b"))

# Join the primary/secondary groups
crayons_groups <- crayons %>%
                  fuzzy_left_join(color_group_nodes, 
                                  by = join_by(name == child_word), 
                                  match_fun = str_detect) %>%
                  replace_na(list(parent = "other"))

crayons_groups %>%
  select(id, name, parent, child) %>%
  head(10)
```



## Assign multiple tags

When we work with longer pieces of text we may want to assign it multiple groups or tags. For example, the description of a kids' TV show may be about both `dinosaurs` and `siblings`. 

In this example we will label the shows about people and tag each description with the type of people it references, such as `sister`, `brother`, or `grandmother`.

### Load kids TV data
```{r}
#| echo: false
library(tidyverse)
library(tidytext)
library(fuzzyjoin)
```

```{r}
#| cache: true

library(tidyverse)
library(tidytext)
library(fuzzyjoin)

tv_shows <- read_csv('https://tidy-mn.github.io/qualitative-guide/posts/data/kids_netflix_shows.csv')
```


### Split up / `unnest` every word for easy group joining
```{r}
tv_shows <- tv_shows %>%
            unnest_tokens(word, description, drop = FALSE)
```


### Load the parent and child node table

Here we provide an example parent/child node table to tag descriptions with various types of people. We include both the singular and plural version of a term - such as *uncle* and *uncles*. 

```{r}
tv_nodes <- read_csv("https://tidy-mn.github.io/qualitative-guide/posts/data/people_nodes.csv")

tv_nodes %>% head()
```



### Join the parent/child `nodes` table to the `tv_shows`

```{r}
tv_groups <- tv_shows %>%
             left_join(tv_nodes, 
                       by = join_by(word == child_words))

# Drop the rows/words with no word matches
tv_groups <- tv_groups %>%
             filter(!is.na(parent))

# View word matches
tv_groups %>%
  select(title, description, parent, child) %>%
  arrange(child) %>%
  head() %>%
  knitr::kable()
```


## Summarize

To simplify things, let's take all of the parent and child tags assigned to each movie and bring them together into a comma separated list.

```{r}
tv_groups <- tv_groups %>%
              filter(!is.na(parent)) %>%
              group_by(show_id, type, title, country, release_year, description) %>%
              summarize(parent_nodes = paste(parent %>% unique %>% sort, collapse = ", "),
                        child_nodes = paste(child %>% unique %>% sort, collapse = ", "),
                        .groups = "drop")
  
# View groups
tv_groups %>%
  select(title, description, parent_nodes, child_nodes) %>%
  arrange(-nchar(child_nodes)) %>%
  head() %>%
  knitr::kable()
```  

