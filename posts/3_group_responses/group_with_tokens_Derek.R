
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
