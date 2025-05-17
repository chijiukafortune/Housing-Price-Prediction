# 🏠 Housing Price Prediction using Machine Learning in R

This project builds, evaluates, and compares multiple machine learning models to predict housing sale prices using advanced regression techniques and feature engineering. The analysis is conducted in **R** and includes an end-to-end data science pipeline from preprocessing to deployment-ready model saving.

## 📁 Project Structure

```
├── Final_Cleaned_Predictive_Model.Rmd    # R Markdown report with all analysis
├── Housing Data_Same Region.csv          # Dataset used for training
├── model_objects.RData                   # Final saved model (Random Forest + preprocessing)
├── app.R                                 # Shiny dashboard (to be created)
└── README.md                             # Project documentation
```

## 🎯 Objectives

- Predict housing sale prices using key features
- Apply and compare machine learning models
- Optimize the best model using hyperparameter tuning
- Prepare the model for deployment

## 📊 Dataset

- **Source**: `Housing Data_Same Region.csv`
- **Target Variable**: `SALE_PRC` (Sale Price)
- **Size**: ~10,000 rows (assumed)
- **Features**: Lot size, tax value, number of bathrooms, etc.

## 🔧 Technologies Used

- R and RStudio
- Packages: `caret`, `randomForest`, `rpart`, `e1071`, `keras`, `ggplot2`, `corrplot`, `shiny`, etc.

## ⚙️ ML Models Evaluated

| Model                  | Kernel/Tree | Notes                          |
|------------------------|-------------|--------------------------------|
| Linear Regression      | —           | Baseline model                 |
| SVM                    | Linear, RBF, Poly | Tuned with different kernels |
| Decision Tree          | CART        | Basic interpretable model      |
| Random Forest          | 100–500 trees | Best model after tuning        |
| LSTM (Keras)           | Deep learning | Requires reshaped 3D input     |

## 📈 Model Performance (MAE Comparison)

A bar chart comparison is included in the report, showing model MAE values to determine the best performer.

## 🔍 Key Features

- Feature Importance (Random Forest + Correlation)
- Outlier detection and removal
- Missing value handling
- Log transformation for target normalization
- Model comparison using `RMSE`, `R²`, and `MAE`
- Hyperparameter tuning of `mtry` and `ntree`

## 🧠 Final Model

- **Algorithm**: Random Forest
- **Optimal ntree**: 457
- **Optimal mtry**: 4
- **Saved as**: `model_objects.RData`

## 📦 Deployment

The final model and preprocessing object are saved using `save()`:
```r
save(final_model, pre_proc, file = "model_objects.RData")
```

You can load and predict in a future session with:
```r
load("model_objects.RData")
predict(final_model, newdata = predict(pre_proc, new_data))
```

## 📜 Author

**Chijiuka Fortune Akuma**  
Student ID:######  
University of Greater Manchester  
Course: DAT7303 – Data Mining & Machine Learning

## 🏁 How to Run

1. Open `Final_Cleaned_Predictive_Model.Rmd` in RStudio.
2. Click **Knit** to run all code and render the report.
3. Ensure all libraries are installed before knitting.
