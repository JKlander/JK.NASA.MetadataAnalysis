# Get Data ----
metadata <- jsonlite::fromJSON("https://data.nasa.gov/data.json")

# Let's peek at the names of the different parts of the dataset
names(metadata$dataset)

# Looks like there is a lot of options from who last modified the data
# to the editor. Let's grab the title, description and keywords for each
# dataset as a first pass for drawing connections between datasets
class(metadata$dataset$title)         # character vector
class(metadata$dataset$description)   # character vector
class(metadata$dataset$keyword)       # list of character vectors

# Wrangle and tidy the data ----

# Let's set up separate tidy data frames for title, description and
# keyword keeping the dataset ids for each so that we can connect
# them later in the analysis if necessary
