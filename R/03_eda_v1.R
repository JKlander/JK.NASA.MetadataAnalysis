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

# Word Co-Occurrences ----
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
                         point.padding = ggplot2::unit(0.2, "lines")) +
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
                         point.padding = ggplot2::unit(0.2, "lines")) +
  ggplot2::theme_void()
# Shows a strong connection between "data" and "set" and a moderately
# strong connection with the top ~20 most frequent words, but there
# is not clear clustering structure in the network.


# What about the keywords?
keyword_pairs <- nasa_keyword |> 
  widyr::pairwise_count(keyword, id, sort = TRUE, upper = FALSE)

keyword_pairs

set.seed(1234)
keyword_pairs |> 
  dplyr::filter(n >= 600) |> 
  igraph::graph_from_data_frame() |> 
  ggraph::ggraph(layout = "fr") +
  ggraph::geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_color = "royalblue") +
  ggraph::geom_node_point(size = 5) +
  ggraph::geom_node_text(aes(label = name), repel = TRUE,
                         point.padding = ggplot2::unit(0.2, "lines")) +
  ggplot2::theme_void()
# There appears to be clustering here, and strong connections between
# keywords like "atmosphere", "earth science" and "land surface", or
# "oceans", "earth science", and "spectral/engineering"
# These are the most commonly co-occuring words, but also just the
# most common keywords in general.

# Correlation among keywords ----
# This looks for those keywords that are more likely to occur together
# than with other keywords for a dataset.
keyword_cors <- nasa_keyword |> 
  dplyr::group_by(keyword) |> 
  dplyr::filter(n() >= 50) |> 
  widyr::pairwise_cor(keyword, id, sort = TRUE, upper = FALSE)

keyword_cors
# Notice that the keywords at the top of this sorted data frame have
# correlation coefficients equal to 1; they always occur together.
# This means these are redundant keywords. It may not make sense to
# continue to use both of the keywords in these sets of pairs; instead
# just one keyword could be used

# Visualize the network of keyword correlations, just as we did for
# keyword co-occurrences.

set.seed(1234)
keyword_cors |> 
  dplyr::filter(correlation > .95 & correlation < 1.0) |> 
  igraph::graph_from_data_frame() |> 
  ggraph::ggraph(layout = "fr") +
  ggraph::geom_edge_link(aes(edge_alpha = correlation,
                             edge_width = correlation),
                         edge_color = "royalblue") +
  ggraph::geom_node_point(size = 5) +
  ggraph::geom_node_text(aes(label = name), repel = TRUE,
                         point.padding = ggplot2::unit(0.2, "lines")) +
  ggplot2::theme_void()

