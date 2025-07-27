rm(list=ls())

#libraries
library(reticulate)
library(ggplot2)
library(factoextra)
library(stats)
library(cluster)
library(factoextra)
library(fpc)
library(clValid)
library(cluster)
library(recipes)
library(dplyr)
library(magrittr)
library(mltools)
library(ggplot2)
library(RColorBrewer)
library(plotly)
library(readxl)
library(rio)
library(lightgbm)
library(shapr)
library(moments)
library(lattice)
library(stargazer)
library(car)
library(lmtest)
library(corrplot)
library(survival)
library(caret)
library(ROCR)
library(corrplot)
library(mvoutlier) #for outlier removal

# Load data
 
test_data = read_excel("C:/Users/91884/Desktop/BAIS/Independent Study - dr. Zantedeschi/exercise1/test.xlsx", sheet = "test")
train_data = read_excel("C:/Users/91884/Desktop/BAIS/Independent Study - dr. Zantedeschi/exercise1/train.xlsx")
str(test_data)
str(train_data)

# One-hot encoding for specified categorical variables
train_data$default <- ifelse(train_data$default == "yes", 1, 0)
train_data$housing <- ifelse(train_data$housing == "yes", 1, 0)
train_data$loan <- ifelse(train_data$loan == "yes", 1, 0)

# For multi-level categorical variables
train_data <- cbind(train_data, model.matrix(~ job - 1, data = train_data))
train_data <- cbind(train_data, model.matrix(~ marital - 1, data = train_data))

# Ordinal encoding for education
education_levels <- c("primary", "secondary", "tertiary", "unknown")
train_data$education <- factor(train_data$education, levels = education_levels, ordered = TRUE)
train_data$education <- as.numeric(train_data$education)

# Scaling numeric variables
train_data$age <- scale(train_data$age) #so they're in same range
train_data$balance <- scale(train_data$balance)



#There's No package for removal of outliers in R, i tried 2 packages but there was error hence the for loop
columns_for_outliers <- c("age", "balance")  # Replace with your actual column names

# Loop through columns and identify outliers using IQR
outlier_indices <- c()
for (col in columns_for_outliers) {
  Q1 <- quantile(train_data[, col], probs = 0.25)
  Q3 <- quantile(train_data[, col], probs = 0.75)
  IQR <- IQR(train_data[, col])
  upper_limit <- Q3 + (1.5 * IQR)
  lower_limit <- Q1 - (1.5 * IQR)
  outlier_indices <- c(outlier_indices, which(train_data[, col] < lower_limit | train_data[, col] > upper_limit))
}

outlier_indices <- unique(outlier_indices)
train_data_no_outliers <- train_data[-outlier_indices, ]

summary(train_data_no_outliers)
summary(train_data)



#K Mean

#for no of cluster and finding k value we do elbow test and Silhouette score
set.seed(0)
data_no_outliers <- as.data.frame(cluster::clara(train_data_no_outliers[, -5], 3, correct.d = FALSE)$data)

# Function to compute total within-cluster sum of squares (wss)
wss <- function(k) {
  kmeans(data_no_outliers, k, nstart = 10)$tot.withinss
}

# Compute and plot wss for k = 2 to k = 10
k.values <- 2:10
wss_values <- sapply(k.values, wss)

# Create a data frame for ggplot
elbow_data <- data.frame(k = k.values, wss = wss_values)

# Plot the elbow graph
ggplot(elbow_data, aes(x = k, y = wss)) +
  geom_point() +
  geom_line() +
  ggtitle("Elbow Method for Optimal k") +
  xlab("Number of clusters k") +
  ylab("Total within-clusters sum of squares")


# Function to create silhouette plot
make_Silhouette_plot <- function(data, n_clusters) {
  # KMeans clustering
  set.seed(10)
  km.res <- kmeans(data, centers = n_clusters, nstart = 25)
  
  # Silhouette plot
  sil <- silhouette(km.res$cluster, dist(data))
  fviz_silhouette(sil) +
    ggtitle(paste("Silhouette plot for", n_clusters, "clusters")) +
    theme_minimal()
}

  
#k=5 , kmean algorithmn 

set.seed(42)
km <- kmeans(data_no_outliers, centers = 5, nstart = 10, iter.max = 100)

clusters_predict <- km$cluster
unique_clusters <- unique(clusters_predict)

print(clusters_predict)
print(unique_clusters)

# Davies-Bouldin Index
db_index <- cluster.stats(d = dist(data_no_outliers), clustering = clusters_predict)$db
cat("Davies-Bouldin Score:", db_index, "\n")

# Calinski-Harabasz Index
ch_index <- cluster.stats(d = dist(data_no_outliers), clustering = clusters_predict)$ch
cat("Calinski-Harabasz Score:", ch_index, "\n")

# Silhouette Score
silhouette <- silhouette(clusters_predict, dist(data_no_outliers))
sil_score <- mean(silhouette[, 3])
cat("Silhouette Score:", sil_score, "\n")



#visualisation of clusters

# Function to perform 2D PCA
get_pca_2d <- function(df, predict) {
  pca_2d_object <- prcomp(df, center = TRUE, scale. = TRUE)
  df_pca_2d <- as.data.frame(pca_2d_object$x[, 1:2])
  colnames(df_pca_2d) <- c("comp1", "comp2")
  df_pca_2d$cluster <- as.factor(predict)
  return(list(pca_2d_object = pca_2d_object, df_pca_2d = df_pca_2d))
}

# Function to plot 2D PCA results
plot_pca_2d <- function(df, title = "PCA 2D Space") {
  ggplot(df, aes(x = comp1, y = comp2, color = cluster)) +
    geom_point(size = 2) +
    scale_color_brewer(palette = "Set1") +
    theme_minimal() +
    labs(title = title, x = "Component 1", y = "Component 2", color = "Cluster")
}

# Function to perform 3D PCA
get_pca_3d <- function(df, predict) {
  pca_3d_object <- prcomp(df, center = TRUE, scale. = TRUE)
  df_pca_3d <- as.data.frame(pca_3d_object$x[, 1:3])
  colnames(df_pca_3d) <- c("comp1", "comp2", "comp3")
  df_pca_3d$cluster <- as.factor(predict)
  return(list(pca_3d_object = pca_3d_object, df_pca_3d = df_pca_3d))
}

# Function to plot 3D PCA results
plot_pca_3d <- function(df, title = "PCA Space", opacity = 0.8, width_line = 0.1) {
  # Use Set1 color palette from RColorBrewer
  num_clusters <- length(unique(df$cluster))
  colors <- brewer.pal(n = min(9, num_clusters), name = "Set1")
  
  fig <- plot_ly(
    df, 
    x = ~comp1, 
    y = ~comp2, 
    z = ~comp3, 
    color = ~cluster,
    colors = colors,
    type = "scatter3d", 
    mode = "markers",
    marker = list(size = 4, opacity = opacity, line = list(width = width_line, color = "black")),
    width = 800,
    height = 800
  ) %>% layout(
    title = title,
    scene = list(
      xaxis = list(title = 'comp1'),
      yaxis = list(title = 'comp2'),
      zaxis = list(title = 'comp3')
    ),
    legend = list(title = list(text = "Cluster"))
  )
  
  fig
}

# Perform 2D PCA
pca_2d_results <- get_pca_2d(data_no_outliers, clusters_predict)
df_pca_2d <- pca_2d_results$df_pca_2d
pca_2d_object <- pca_2d_results$pca_2d_object

# Perform 3D PCA
pca_3d_results <- get_pca_3d(data_no_outliers, clusters_predict)
df_pca_3d <- pca_3d_results$df_pca_3d
pca_3d_object <- pca_3d_results$pca_3d_object

# Plot the 2D PCA results
plot_2d <- plot_pca_2d(df_pca_2d, title = "PCA 2D Space")
print(plot_2d)

# Plot the 3D PCA results
fig <- plot_pca_3d(df_pca_3d, title = "PCA Space", opacity = 1, width_line = 0.1)
fig

# Print the variability explained by each component for 3D PCA
cat("The variability is :", summary(pca_3d_object)$importance[2, 1:3], "\n")


#final summary 
str(train_data_no_outliers)
train_data_no_outliers$cluster <- clusters_predict
