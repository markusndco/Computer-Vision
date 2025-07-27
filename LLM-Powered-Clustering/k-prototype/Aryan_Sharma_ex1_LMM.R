# Load necessary libraries
library(readxl)
library(dplyr)
library(tidyr)
library(text2vec)
library(purrr)

# Load data
train_data <- read_excel("C:/Users/91884/Desktop/BAIS/Independent Study - Zantedeschi/exercise1/train.xlsx", sheet = "train")

# Print column names
cat("Column names in train_data:\n")
print(names(train_data))

# expected arguments in compile_text function
expected_arguments <- c("age", "housing", "job", "marital", "education", "default", "balance", "loan", "contact")
if (!all(expected_arguments %in% names(train_data))) {
  stop("Column names in train_data do not match expected arguments in compile_text function.")
}

str(train_data)

# Removing NA values or any other preprocessing
train_data <- train_data %>% tidyr::drop_na()

# Convert to a list of sentences
compile_text <- function(age, housing, job, marital, education, default, balance, loan, contact) {
  text <- paste0(
    "Age: ", age, ", ",
    "Housing load: ", housing, ", ",
    "Job: ", job, ", ",
    "Marital: ", marital, ", ",
    "Education: ", education, ", ",
    "Default: ", default, ", ",
    "Balance: ", balance, ", ",
    "Personal loan: ", loan, ", ",
    "Contact: ", contact
  )
  return(text)
}

# Apply the function to create a list of sentences
sentences <- purrr::pmap_chr(train_data, compile_text)

# Create an iterator over tokens
tokens <- itoken(sentences, 
                 preprocessor = tolower, 
                 tokenizer = word_tokenizer, 
                 progressbar = TRUE)

# Create vocabulary
vocab <- create_vocabulary(tokens)

# Create a vectorizer
vectorizer <- vocab_vectorizer(vocab)

# Create a term-co-occurrence matrix (TCM)
tcm <- create_tcm(tokens, vectorizer)

# Fit a GloVe model
glove_model <- GlobalVectors$new(rank = 50, x_max = 10)
word_vectors <- glove_model$fit_transform(tcm, n_iter = 20)

# Combine main and context vectors
word_vectors <- word_vectors + t(glove_model$components)

# Create an embedding for each sentence by averaging word vectors
sentence_embeddings <- function(sent, word_vectors) {
  words <- unlist(word_tokenizer(tolower(sent)))
  valid_words <- words[words %in% rownames(word_vectors)]
  if (length(valid_words) == 0) return(rep(NA, ncol(word_vectors)))
  word_vecs <- word_vectors[valid_words, , drop = FALSE]
  colMeans(word_vecs, na.rm = TRUE)
}

# Apply the embedding function to all sentences
embeddings <- t(sapply(sentences, sentence_embeddings, word_vectors = word_vectors))

# Remove sentences that couldn't be embedded
embeddings <- embeddings[complete.cases(embeddings), ]

# Convert embeddings to data frame
embeddings_df <- as.data.frame(embeddings)

# Inspect the resulting embeddings
str(embeddings_df)

# Save embeddings to CSV for future use
write.csv(embeddings_df, "train_embeddings.csv", row.names = FALSE)

# Load data
embedding_data <- read.csv("C:/Users/91884/Desktop/BAIS/Independent Study - Zantedeschi/exercise1/LMM+kMean/train_embeddings.csv")


# Calculate z-scores for each column
z_scores <- apply(embedding_data, 2, function(x) (x - mean(x)) / sd(x))

# Find indices of outliers
outlier_indices <- apply(z_scores, 2, function(x) which(abs(x) > threshold))

# Flatten the list of outlier indices
all_outlier_indices <- unlist(outlier_indices)

# Remove duplicate indices
all_outlier_indices <- unique(all_outlier_indices)

# Remove outliers from embedding data
embedding_data_no_outliers <- embedding_data[-all_outlier_indices, ]

# Inspect the resulting embeddings without outliers
str(embedding_data_no_outliers)

# Optionally, save the embedding data without outliers to CSV
write.csv(embedding_data_no_outliers, "train_embeddings_no_outliers.csv", row.names = FALSE)
