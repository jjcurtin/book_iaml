temp <- tempfile()
options(timeout = max(300, getOption("timeout")))
download.file("https://nlp.stanford.edu/data/glove.6B.zip", temp)
unzip(temp, files = "glove.6B.50d.txt")
glove_embeddings <- read_delim(here::here("glove.6B.50d.txt"),
                               delim = " ",
                               col_names = FALSE) 