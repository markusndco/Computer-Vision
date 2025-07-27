# Clear workspace
rm(list=ls())

# Load required libraries
library(ggplot2)
library(plotly)
library(factoextra)
library(cluster)
library(clustMixType)
library(FactoMineR)
library(factoextra)
library(recipes)
library(dplyr)
library(magrittr)
library(mltools)
library(readxl)
library(rio)
library(moments)
library(lattice)
library(stargazer)
library(car)
library(lmtest)
library(corrplot)
library(survival)
library(caret)
library(ROCR)
library(mvoutlier) # for outlier removal

# Load data
test_data <- read_excel("C:/Users/91884/Desktop/BAIS/Independent Study - Zantedeschi/exercise1/test.xlsx", sheet = "test")
train_data <- read_excel("C:/Users/91884/Desktop/BAIS/Independent Study - Zantedeschi/exercise1/train.xlsx", sheet = "train")

# Inspect the structure of the data
str(test_data)
str(train_data)

# One-hot encoding for specified categorical variables
train_data$default <- ifelse(train_data$default == "yes", 1, 0)
train_data$housing <- ifelse(train_data$housing == "yes", 1, 0)
train_data$loan <- ifelse(train_data$loan == "yes", 1, 0)

# Scaling numeric variables
train_data$age <- scale(train_data$age) # Scaling 'age' column
train_data$balance <- scale(train_data$balance) # Scaling 'balance' column

# Identify and remove outliers
columns_for_outliers <- c("age", "balance")  # Columns to check for outliers

# Initialize vector to store indices of outliers
outlier_indices <- c()

# Loop through columns to find outliers using IQR method
for (col in columns_for_outliers) {
  Q1 <- quantile(train_data[[col]], probs = 0.25, na.rm = TRUE)
  Q3 <- quantile(train_data[[col]], probs = 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  upper_limit <- Q3 + (1.5 * IQR)
  lower_limit <- Q1 - (1.5 * IQR)
  outliers <- which(train_data[[col]] < lower_limit | train_data[[col]] > upper_limit)
  outlier_indices <- c(outlier_indices, outliers)
}

# Remove duplicates from outlier indices
outlier_indices <- unique(outlier_indices)

# Create a new data frame without outliers
train_data_no_outliers <- train_data[-outlier_indices, ]

# Summary of the data without outliers
summary(train_data_no_outliers)
str(train_data_no_outliers)


#asfactor
train_data_no_outliers$job <- factor(train_data_no_outliers$job)
train_data_no_outliers$marital <- factor(train_data_no_outliers$marital)
train_data_no_outliers$education <- factor(train_data_no_outliers$education)

str(train_data_no_outliers)

# Assuming `categorical_columns` contains the names of the categorical columns
categorical_columns <- c("job", "marital", "education")

# Elbow method to determine optimal K
cost <- c()
range_ <- 2:14

# Loop to calculate the cost for different numbers of clusters
for (k in range_) {
  kproto_result <- kproto(train_data_no_outliers, k, lambda = NULL, iter.max = 100, nstart = 10)
  cost <- c(cost, kproto_result$tot.withinss)
  print(paste('Cluster initiation:', k))
}

# Convert results to a data frame
df_cost <- data.frame(Cluster = range_, Cost = cost)

# Plot using ggplot2
ggplot(df_cost, aes(x = Cluster, y = Cost)) +
  geom_line() +
  geom_point() +
  geom_text(aes(label = Cluster), vjust = -0.5) +
  labs(title = 'Optimal number of clusters with Elbow Method',
       x = 'Number of Clusters k',
       y = 'Cost') +
  theme_minimal()

#model

k <- 5
kproto_model <- kproto(train_data_no_outliers, k, lambda = NULL, iter.max = 100, nstart = 10)
print(kproto_model)
summary(kproto_model)


# Cluster Visulatisation
# Perform MCA with 2 components
mca_result <- MCA(train_data_no_outliers[, categorical_columns], graph = FALSE)

# Check for NaN values in MCA result
if (any(is.nan(unlist(mca_result$ind$coord)))) {
  print("Warning: NaN values detected in MCA result")
}

# Get MCA coordinates for 2D visualization
mca_df <- data.frame(mca_result$ind$coord)
colnames(mca_df) <- c("comp1", "comp2")
mca_df$cluster <- as.factor(train_data_no_outliers$cluster)

# Visualize 2D MCA
ggplot(mca_df, aes(x = comp1, y = comp2, color = cluster)) +
  geom_point(size = 2) +
  labs(title = "MCA - 2D Visualization",
       x = "Component 1",
       y = "Component 2",
       color = "Cluster") +
  theme_minimal()

#3d
plot_ly(data = mca_df, 
        x = ~comp1, 
        y = ~comp2, 
        z = ~cluster, 
        color = ~cluster,
        type = 'scatter3d', 
        mode = 'markers') %>%
  layout(title = 'MCA - 3D Visualization',
         scene = list(xaxis = list(title = 'Component 1'),
                      yaxis = list(title = 'Component 2'),
                      zaxis = list(title = 'Cluster')))


# Get cluster assignments
cluster_assignments <- kproto_model$cluster

# Combine cluster assignments with original data
clustered_data <- cbind(train_data_no_outliers, Cluster = cluster_assignments)

# Add unscaled age and balance to clustered data
clustered_data$age <- unscaled_age
clustered_data$balance <- unscaled_balance

# Calculate average values of unscaled numerical variables for each cluster
average_values <- aggregate(. ~ Cluster, data = clustered_data[, c("Cluster", "age", "balance")], FUN = mean)

# Print average values
print(average_values)
