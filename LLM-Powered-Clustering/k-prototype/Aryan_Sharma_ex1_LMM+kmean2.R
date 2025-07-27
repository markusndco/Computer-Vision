
rm(list=ls())

library(readxl)
library(dplyr)
library(tidyr)
library(text2vec)
library(purrr)
library(ggplot2)
library(rio)  # Load 

# Load data using rio's import function
train_data <- import("C:/Users/91884/Desktop/BAIS/Independent Study - Zantedeschi/exercise1/LMM+kMean/train_embeddings_no_outliers.csv")

# Perform elbow test
elbow_data <- data.frame(K = integer(), WCSS = numeric())

for (k in 1:10) {
  kmeans_model <- kmeans(train_data, centers = k, nstart = 25)
  elbow_data <- rbind(elbow_data, data.frame(K = k, WCSS = kmeans_model$tot.withinss))
}

# Plot the elbow curve
library(ggplot2)
ggplot(elbow_data, aes(x = K, y = WCSS)) +
  geom_line() +
  geom_point() +
  labs(x = "Number of clusters (K)", y = "Within-Cluster Sum of Squares (WCSS)",
       title = "Elbow Method for Optimal K in K-Means Clustering")

# Perform k-means clustering with k = 5
kmeans_model <- kmeans(train_data, centers = 5, nstart = 25)

# Add cluster labels to the original data
train_data_with_clusters <- cbind(train_data, Cluster = kmeans_model$cluster)

# View the cluster centers
cluster_centers <- kmeans_model$centers
print(cluster_centers)

# View the cluster sizes
cluster_sizes <- table(kmeans_model$cluster)
print(cluster_sizes)

# Calculate cluster means
cluster_means <- aggregate(. ~ Cluster, train_data_with_clusters, mean)
print(cluster_means)

# Visualize cluster centers in the embedding space (assuming 2-dimensional embeddings)

ggplot(train_data_with_clusters, aes(x = V1, y = V2, color = factor(Cluster))) +
  geom_point() +
  geom_point(data = as.data.frame(cluster_centers), aes(x = V1, y = V2), color = "black", size = 3, shape = 17) +
  labs(x = "Embedding Dimension 1", y = "Embedding Dimension 2", title = "K-Means Clustering with K = 5")

