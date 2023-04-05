# Exploratory Data Analysis ----

nasa_title
nasa_desc

# What are the most common words in titles?
nasa_title |> 
  dplyr::count(word, sort = TRUE)

# What are the most common words in descriptions?
nasa_desc |> 
  dplyr::count(word, sort = TRUE)

# What are the most common keywords?
nasa_keyword |> 
  dplyr::group_by(keyword) |> 
  dplyr::count(sort = TRUE)

# Word Co-Occurrences and Correlations ----
# Examine which words commonly occur together in the titles, descriptions
# and keywords of NASA datasets.
title_word_pairs <- nasa_title |> 
  widyr::pairwise_count(word, id, sort = TRUE, upper = FALSE)

title_word_pairs
# These are the pairs of words that occur together most often in the
# title fields. Some of these words are obviously acronyms used within
# NASA, and we see how often words like "project" and "system" are used.
desc_word_pairs <- nasa_desc |> 
  widyr::pairwise_count(word, id, sort = TRUE, upper = FALSE)

# Examine word networks for these fields; this may help us see, for
# example, which datasets are related to each other.