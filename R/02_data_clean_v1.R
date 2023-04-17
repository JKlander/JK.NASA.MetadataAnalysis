# Get Data ---- 

# metadata <- jsonlite::fromJSON("https://data.nasa.gov/data.json")

# Save Data Locally ---- metadata |> readr::write_rds(file =
# "./data/raw/nasa_metadata.rds")

# Load local copy of data from a prior run of lines 3-6 above
metadata <- readr::read_rds(file = "./data/raw/nasa_metadata.rds")

# Let's peek at the names of the different parts of the dataset
(metadata_names <- names(metadata$dataset))

# Looks like there is a lot of options from who last modified the data to the
# editor. Let's grab the title, description and keywords for each dataset as a
# first pass for drawing connections between datasets
metadata_dataset <- metadata$dataset
class(metadata_dataset$title)         # character vector
class(metadata_dataset$description)   # character vector
class(metadata_dataset$keyword)       # list of character vectors

# Wrangle and tidy the data ----

# Let's set up separate tidy data frames for title, description and keyword
# keeping the dataset ids for each so that we can connect them later in the
# analysis if necessary
nasa_title <- dplyr::tibble(id = metadata_dataset$identifier,
                            title = metadata_dataset$title)
nasa_title

nasa_desc <- dplyr::tibble(id = metadata_dataset$identifier,
                           desc = metadata_dataset$description)
nasa_desc |> 
  dplyr::select(desc) |> 
  dplyr::sample_n(5)

nasa_keyword <- dplyr::tibble(id = metadata_dataset$identifier,
                              keyword = metadata_dataset$keyword) |> 
  tidyr::unnest(keyword)

# Extract tokens and remove stop words for text analysis
nasa_title <- nasa_title |> 
  tidytext::unnest_tokens(output = word, input = title) |> 
  dplyr::anti_join(tidytext::stop_words)

nasa_desc <- nasa_desc |> 
  tidytext::unnest_tokens(word, desc) |> 
  dplyr::anti_join(tidytext::stop_words)

# After initial EDA it appears there are more words that don't add any real
# useful information to the analysis, so let's create our own list of stop
# words to strip from the title and description datasets.

# Remove common words in these datasets like "data", "global" and digits like
# "v1" since they are not too meaningful for most audiences.
my_stopwords <- dplyr::tibble(word = c(as.character(1:10),
                                       "v1", "v03", "12", "13", "14", "v5.2.0",
                                       "v003", "v004", "v005", "v006", "v7",
                                       "v1.0"))

nasa_title <- nasa_title |> 
  dplyr::anti_join(my_stopwords)
nasa_desc <- nasa_desc |> 
  dplyr::anti_join(my_stopwords)
