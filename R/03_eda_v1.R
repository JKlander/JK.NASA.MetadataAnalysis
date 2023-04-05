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

desc_word_pairs
# These are the pairs of words that occur together most often in the
# description fields. "data" is a very common word in description fields

# Examine word networks for these fields; this may help us see, for
# example, which datasets are related to each other.
set.seed(1234)
title_word_pairs |> 
  dplyr::filter(n >= 250) |> 
  igraph::graph_from_data_frame() |> 
  ggraph::ggraph(layout = "fr") +
  ggraph::geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_color = "cyan4") +
  ggraph::geom_node_point(size = 5) +
  ggraph::geom_node_text(aes(label = name), repel = TRUE, 
                         point.padding = unit(0.2, "lines")) +
  ggplot2::theme_void()
# There is some clear clustering of title words in this network.

# What about the words from the description fields?
desc_word_pairs |> 
  dplyr::filter(n >= 3000) |> 
  igraph::graph_from_data_frame() |> 
  ggraph::ggraph(layout = "fr") +
  ggraph::geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_color = "darkred") +
  ggraph::geom_node_point(size = 5) +
  ggraph::geom_node_text(aes(label = name), repel = TRUE,
                         point.padding = unit(0.2, "lines")) +
  ggplot2::theme_void()
# Shows a strong connection between "data" and "set" and a moderately
# strong connection with the top ~20 most frequent words, but there
# is not clear clustering structure in the network.