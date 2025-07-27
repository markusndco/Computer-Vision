# 🧠 Enriching Customer Segmentation with K-Means, K-Prototypes, and LLM-Powered Clustering

A comprehensive machine learning project showcasing how traditional and modern techniques can be integrated for high-impact customer segmentation. This project combines **K-means**, **K-prototype**, and a hybrid approach of **Language Models (LLMs) + K-means**, using real-world marketing data from a public Kaggle dataset.

---

## 📊 Project Objective

To explore advanced clustering techniques for effective customer segmentation using a structured dataset of bank marketing targets. By blending **statistical rigor**, **machine learning**, and **natural language processing**, the project aims to deliver meaningful, visual, and interpretable customer groups.

---

## 📁 Folder Structure

| File/Folder | Description |
|-------------|-------------|
| `train.xlsx`, `test.xlsx` | Raw structured data with numeric and categorical fields |
| `train_data_no_outliers.xlsx` | Cleaned training data after ECOD outlier removal |
| `Documentation_V3.pdf` | Full research report with visuals, clustering validation, and methodology |

---

## 🚀 Methodologies Used

### 1. **K-Means Clustering**
- Applied to numerically encoded and scaled data
- Outlier detection via **ECOD**
- Cluster validation: **Elbow Method**, **Silhouette Score**, **Davies-Bouldin Index**
- Visualizations using **2D PCA**, **3D PCA**, and **t-SNE**

### 2. **K-Prototypes Clustering**
- Handles mixed-type data (numerical + categorical)
- Encodes factors appropriately
- Optimal clusters determined using **cost plots**
- Visualization with **Multiple Correspondence Analysis (MCA)**

### 3. **LLM + K-Means Hybrid Clustering**
- Transforms structured data into **descriptive sentences**
- Uses **GloVe embeddings** to vectorize these sentences
- Applies K-means on vectorized data
- Clustering visualized using **2D PCA**

---

## 🧠 NLP Integration

- Text conversion: Structured records turned into synthetic sentences
- Embedding: GloVe model trained using **term co-occurrence matrix**
- Dimensionality reduction and clustering applied to sentence embeddings
- Leverages **semantic representation** for more natural segment discovery

---

## 📉 Dimensionality Reduction Techniques

| Technique | Purpose |
|-----------|---------|
| **PCA** (Principal Component Analysis) | For visualizing high-dimensional numeric data |
| **t-SNE** | For non-linear structure visualization |
| **MCA** (Multiple Correspondence Analysis) | For analyzing and plotting categorical data clustering |

---

## 📌 Results Summary

- Optimal clusters observed: **5 or 6** across methods
- Hybrid LLM + K-means outperformed others in interpretability
- Visual tools like PCA/t-SNE/MCA made clustering insights actionable
- Demonstrated that **quality preprocessing** + **NLP enrichment** lead to more robust segmentation models

---

## 🧰 Tools & Libraries

- **Python**, **R**
- `scikit-learn`, `PyOD`, `ggplot2`, `GloVe`, `shap`, `pandas`, `matplotlib`, `text2vec`, `clustMixType`, `cluster`, `factoextra`

---

## 🎯 Key Learning Outcomes

- How to cluster mixed-type data using K-means and K-prototypes
- How to transform structured data into meaningful text representations
- The value of hybrid ML + NLP approaches in customer analytics
- How to validate clustering results through multiple statistical indices

---

## 🔍 Tags

`#customer-segmentation` `#kmeans` `#kprototypes` `#nlp` `#glove`  
`#unsupervised-learning` `#pca` `#tsne` `#mca` `#shap`  
`#cluster-validation` `#banking-data` `#marketing-analytics`

---

## 👨‍💻 Author

**Aryan Sharma**  
*Data Scientist | NLP Enthusiast | Customer Analytics | R & Python*

---

## 📜 License

This project is intended for academic, learning, and non-commercial demonstration purposes. Attribution is appreciated.

---

## 📎 Reference Dataset

[Kaggle - Bank Marketing Dataset](https://www.kaggle.com/datasets/)

