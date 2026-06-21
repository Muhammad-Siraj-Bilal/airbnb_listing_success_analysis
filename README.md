# Airbnb Listing Success Prediction in R

An end-to-end data analytics and machine-learning project that analyses Airbnb listing data and predicts whether a property is likely to be classified as a successful listing.

The project uses R for data cleaning, exploratory data analysis, feature engineering, visualisation and classification modelling.

## Project Overview

Airbnb listing performance can be influenced by factors such as price, availability, reviews, property characteristics, host behaviour and amenities.

This project analyses these factors and creates a binary classification target:

* **Good** – listings meeting the defined revenue and rating criteria
* **Bad** – listings that do not meet those criteria

Two classification models are developed and evaluated:

* Logistic Regression
* Decision Tree

The project also includes class balancing, correlation analysis, confusion matrices and ROC/AUC evaluation.

## Objectives

The main objectives of this project are to:

* Explore the structure and quality of Airbnb listing data
* Clean and prepare raw listing information
* Estimate occupancy and annual revenue
* Engineer meaningful listing and host features
* Define a practical measure of listing success
* Identify factors associated with successful listings
* Train classification models
* Compare model performance
* Visualise important patterns in the data

## Project Workflow

The analysis follows these main stages:

1. Import the Airbnb dataset
2. Inspect the structure and summary statistics
3. Select relevant columns
4. Clean price and percentage variables
5. Handle missing values
6. Extract bathroom information
7. Calculate amenity counts
8. Estimate nights booked
9. Estimate annual revenue
10. Calculate occupancy rate
11. Remove extreme outliers
12. Create the Good/Bad success label
13. Conduct exploratory data analysis
14. Prepare the modelling dataset
15. Split the data into training and testing sets
16. Balance the training classes
17. Train Logistic Regression and Decision Tree models
18. Evaluate the models using classification metrics

## Success Definition

Listings are grouped using comparable property characteristics such as:

* Neighbourhood
* Room type
* Number of guests accommodated
* Number of bedrooms

A listing is classified as **Good** when:

* The comparison group contains at least five listings
* Its estimated annual revenue is equal to or above the group median
* Its review score is at least 4.5

Listings that do not meet these conditions are classified as **Bad**.

## Feature Engineering

Several additional variables are created during the analysis.

### Numeric Price

Currency symbols and commas are removed from the original price field to create a numeric price variable.

### Estimated Nights Booked

```r
nights_booked = 365 - availability_365
```

### Estimated Annual Revenue

```r
annual_revenue = price_num * nights_booked
```

### Occupancy Rate

```r
occupancy_rate = nights_booked / 365
```

### Amenity Count

The number of amenities is estimated by counting the comma-separated items in the amenities field.

### Bathroom Count

Bathroom information is extracted from text values such as:

```text
1 bath
1.5 baths
Half-bath
```

### Log Price

A logarithmic price variable is created to reduce the effect of price skewness:

```r
log_price = log(price_num)
```

## Exploratory Data Analysis

The project includes visualisations for:

* Raw price distribution
* Room-type frequency
* Availability distribution
* Review-score distribution
* Annual revenue by number of bedrooms
* Success proportion by room type
* Annual revenue distribution
* Occupancy-rate distribution
* Success proportion by Superhost status
* Minimum-night distribution
* Maximum-night distribution
* Log-price distribution
* Correlation heatmap

## Data Preparation

The project performs several preprocessing steps before modelling:

* Removal of records with missing essential fields
* Removal of extreme price and revenue values using the 99th percentile
* Filtering invalid availability values
* Median imputation for numeric predictors
* Mode imputation for categorical predictors
* Conversion of categorical variables into factors
* Alignment of factor levels between training and testing data
* Removal of incomplete modelling records

## Class Balancing

The original Good/Bad target may be imbalanced.

The training data is balanced using down-sampling:

```r
train_data = downSample(
  x = train_data %>% select(-success),
  y = train_data$success,
  yname = "success"
)
```

This helps prevent the models from favouring the majority class.

## Models

### Logistic Regression

Logistic Regression is used to estimate the probability that a listing belongs to the Good category.

The model is evaluated using:

* Confusion matrix
* Accuracy
* Sensitivity
* Specificity
* ROC curve
* Area Under the Curve

### Decision Tree

A Decision Tree is trained to identify interpretable rules that separate Good and Bad listings.

The tree structure is visualised to show the variables and thresholds used during classification.

## Predictor Variables

The final modelling dataset includes variables such as:

* Availability in the next 30 days
* Reviews per month
* Log price
* Number of bedrooms
* Minimum nights
* Maximum nights
* Number of guests accommodated
* Review cleanliness score
* Review location score
* Calculated host listing count
* Room type
* Amenity count
* Superhost status
* Host acceptance rate
* Host response rate
* Instant-booking status

## Technologies Used

* R
* RStudio
* Tidyverse
* ggplot2
* dplyr
* stringr
* readxl
* caret
* tree
* rpart
* pROC
* reshape2

## Repository Structure

```text
airbnb-listing-success-prediction/
├── airbnb_listing_success_analysis.R
├── README.md
├── .gitignore
├── LICENSE
├── data/
│   └── README.md
└── outputs/
    └── .gitkeep
```

## Installation

Install R from the official R website and optionally install RStudio.

Open R or RStudio and install the required packages:

```r
install.packages(c(
  "tidyverse",
  "readxl",
  "caret",
  "tree",
  "rpart",
  "pROC",
  "stringr",
  "reshape2"
))
```

## Dataset Setup

Place the Airbnb dataset inside the following folder:

```text
data/listings.xlsx
```

Update the data-loading line in the R script to:

```r
listings_raw = read_excel("data/listings.xlsx")
```

Avoid using a computer-specific path such as:

```r
C:/Users/bilal/Downloads/listings.xlsx
```

The dataset is not included in this repository unless redistribution is permitted.

## Running the Project

Clone the repository:

```bash
git clone https://github.com/Muhammad-Siraj-Bilal/airbnb-listing-success-prediction.git
```

Open the project folder:

```bash
cd airbnb-listing-success-prediction
```

Open the following file in RStudio:

```text
airbnb_listing_success_analysis.R
```

Run the script section by section or select:

```text
Source
```

to execute the complete analysis.

## Important Assumptions

The project uses estimated rather than confirmed financial performance.

Estimated annual revenue is calculated using:

```r
price × estimated nights booked
```

The calculation assumes that unavailable dates represent booked nights. However, listings may also be unavailable because:

* The host blocked the calendar
* The property was temporarily removed
* The listing was reserved for personal use
* The calendar was not fully updated

Therefore, annual revenue and occupancy should be interpreted as analytical estimates.

## Current Limitations

* Revenue is estimated rather than obtained from confirmed bookings
* Calendar unavailability may not always represent occupancy
* The analysis depends on the quality of the source dataset
* The Good/Bad success definition is rule-based
* Results may not generalise to every city or market
* Seasonal changes are not modelled explicitly
* Location information could be analysed in greater detail
* Model hyperparameter tuning is limited

## Future Improvements

Future versions could include:

* Random Forest classification
* Gradient Boosting models
* Cross-validated hyperparameter tuning
* Feature-importance visualisations
* Interactive dashboards
* Geospatial neighbourhood analysis
* Seasonal occupancy modelling
* More robust revenue estimation
* SHAP-based model explanations
* Automated reporting
* Deployment through a Shiny application

## Educational Purpose

This project was developed for educational and portfolio purposes to demonstrate:

* Data cleaning
* Exploratory data analysis
* Feature engineering
* Classification modelling
* Model evaluation
* Business-focused interpretation

## Author

**Muhammad Siraj Bilal**

## Licence

This project is provided for educational and research purposes.

Before using or redistributing the Airbnb dataset, review its original licence and usage conditions.
