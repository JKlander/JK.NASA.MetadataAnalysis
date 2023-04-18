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
# Examine which words commonly occur together in the titles, descriptions and
# keywords of NASA datasets.
title_word_pairs <- nasa_title |> 
  widyr::pairwise_count(word, id, sort = TRUE, upper = FALSE)

title_word_pairs
# These are the pairs of words that occur together most often in the title
# fields. Some of these words are obviously acronyms used within NASA, and we
# see how often words like "project" and "system" are used.

desc_word_pairs <- nasa_desc |> 
  widyr::pairwise_count(word, id, sort = TRUE, upper = FALSE)

desc_word_pairs
# These are the pairs of words that occur together most often in the
# description fields. "data" is a very common word in description fields

# Examine word networks for these fields; this may help us see, for example,
# which datasets are related to each other.
set.seed(1234)
title_word_pairs |> 
  dplyr::filter(n >= 250) |> 
  igraph::graph_from_data_frame() |> 
  ggraph::ggraph(layout = "fr") +
  ggraph::geom_edge_link(ggplot2::aes(edge_alpha = n, edge_width = n), edge_color = "cyan4") +
  ggraph::geom_node_point(size = 5) +
  ggraph::geom_node_text(ggplot2::aes(label = name), repel = TRUE, 
                         point.padding = ggplot2::unit(0.2, "lines")) +
  ggplot2::theme_void()
# There is some clear clustering of title words in this network.

# What about the words from the description fields?
desc_word_pairs |> 
  dplyr::filter(n >= 1000) |> 
  igraph::graph_from_data_frame() |> 
  ggraph::ggraph(layout = "fr") +
  ggraph::geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_color = "darkred") +
  ggraph::geom_node_point(size = 5) +
  ggraph::geom_node_text(aes(label = name), repel = TRUE,
                         point.padding = ggplot2::unit(0.2, "lines")) +
  ggplot2::theme_void()
# Shows a strong connection between "data" and "set" and a moderately strong
# connection with the top ~20 most frequent words, but there is not clear
# clustering structure in the network.


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
# There appears to be clustering here, and strong connections between keywords
# like "atmosphere", "earth science" and "land surface", or "oceans", "earth
# science", and "spectral/engineering" These are the most commonly co-occuring
# words, but also just the most common keywords in general.

# Correlation among keywords ---- This looks for those keywords that are more
# likely to occur together than with other keywords for a dataset.
keyword_cors <- nasa_keyword |> 
  dplyr::group_by(keyword) |> 
  dplyr::filter(n() >= 50) |> 
  widyr::pairwise_cor(keyword, id, sort = TRUE, upper = FALSE)

keyword_cors
# Notice that the keywords at the top of this sorted data frame have
# correlation coefficients equal to 1; they always occur together. This means
# these are redundant keywords. It may not make sense to continue to use both
# of the keywords in these sets of pairs; instead just one keyword could be
# used

# Visualize the network of keyword correlations, just as we did for keyword
# co-occurrences.

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
# the network appears much different than the co-occurence network. The
# difference is that the co-occurrence network asks a question about which
# keyword pairs occur most often, and the correlation network asks a
# question about which keyword pairs occur most often, and the correlation
# network asks a question about which keywords occur more often together
# than with other keywords. Notice here the high number of small clusters
# of keywords; the network structure can be extracted (for further analysis)
# from the graph_from_data_frame() function.

# Calculating tf-idf for the descripton fields
# the network graph showed us that the description fields are dominated by
# a few common words like "data", "global", and "resolution"; this would be
# an excellent opportunity to use tf-idf as a statistic to find characteristic
# words for individual description fields. You can use tf-idf, the term
# frequency times inverse document frequency, to identify words that are
# especially important to a document within a collection of documents. Let's
# apply that approach to the description fields of these NASA datasets.

# what is tf-idf for the description field words?
# we will consider each description field a document, and the whole set of
# description fields the collection or corpus of documents. We have already
# used unnest_tokens() earlier in this chapter to make a tidy data frame
# of the words in the description fields, so now you can use bind_tf_idf()
# to calculate tf-idf for each word.
desc_tf_idf <- nasa_desc |> 
  count(id, word, sort = TRUE) |> 
  tidytext::bind_tf_idf(word, id, n)

# what are the highest tf-idf words in the NASA description fields?
desc_tf_idf |> 
  arrange(-tf_idf) |> 
  head(15) |> 
  gt::gt()
# These are the most important words in the description fields as measured
# by tf-idf, meaning they are common but not too common. Notice, we have run
# into an issue here; both n and term frequency are equal to 1 for these
# terms, meaning that these were description fields that only had a single
# word in them. If a description field only contains one word, the tf-idf
# algorithm will think that is a very important word.

# depending on the analytic goals, it might be a good idea to throw out all 
# description fields that have very few words.