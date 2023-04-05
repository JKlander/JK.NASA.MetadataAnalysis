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
