
## Token version

### Prepare the description text
```{r}
tv_shows <- tv_shows %>%
  unnest_tokens(word, description, drop = FALSE)
```


### Join the parent/child `tv_nodes` table to `tv_shows`
```{r}
tagged <- left_join(tv_shows, tv_nodes, by = join_by(word == child)) %>%
  left_join(tv_nodes, by = join_by(word == child_plural)) %>%
  mutate(parent = coalesce(parent.x, parent.y),
         child = coalesce(child, word),
         .keep = "unused"
  )

tagged
```

### Clean up
```{r}
tagged <- tagged %>%
  drop_na(parent) %>%
  select(-child_plural,
         -child,
         child)
```


---


  ### Load the parent and child node table

  Here we provide an example where we will search the text and assign groups based on multiple words. In this case, the singular and plural version of a term - such as *home* and *homes*, is included as a child node. We can add as many terms as we like to a child node by separating each word with a vertical bar symbol (`|`).

```{r}
#| eval: false
tv_nodes <- read_csv("https://tidy-mn.github.io/qualitative-guide/posts/data/tv_parent_child_nodes.csv")
```


### Create a multiple string detect function
```{r}
#| eval: false
#| echo: false
multi_str_detect <- function(left, right) {

  regex_str <- paste0("\\b", str_split(right, "[|]") %>% unlist, "\\b", collapse = "|")

  str_detect(left, regex_str)
}
```

```{r}
#| eval: false
tv_nodes <- tv_nodes %>%
  rowwise() %>%
  mutate(child_words = paste0("\\b", str_split(child, "[|]") %>% unlist, "\\b",
                              collapse = "|"))
```

### Fuzzy join the parent/child `nodes` table to `tv_shows`
```{r}
#| eval: false
tv_groups <- tv_shows %>%
  fuzzy_left_join(tv_nodes,
                  by = join_by(description == child_words),
                  match_fun = str_detect) %>%
  select(-child_words)

tv_groups %>%
  select(title, description, parent, child) %>%
  head()

tv_groups %>%
  select(title, description, parent, child) %>%
  head() %>%
  knitr::kable()
```

## Summarize

