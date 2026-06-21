########################################
# Q1A  Load packages
########################################

# install.packages("tidyverse")
# install.packages("readxl")
# install.packages("caret")
# install.packages("tree")
# install.packages("rpart")
# install.packages("pROC")
# install.packages("stringr")
# install.packages("reshape2")

library(tidyverse)
library(tree)
library(readxl)
library(caret)
library(rpart)
library(pROC)
library(stringr)
library(reshape2)


########################################
# Q1  Read dataset and basic overview
########################################

listings_raw = read_excel("C:/Users/bilal/Downloads/listings.xlsx")

glimpse(listings_raw)
view(listings_raw)
dim(listings_raw)
nrow(listings_raw)
ncol(listings_raw)
names(listings_raw)
summary(listings_raw)
summary(listings_raw$price)


########################################
# Q1  EDA – raw data
########################################

# Price distribution (raw) with numeric conversion
ggplot(
  listings_raw,
  aes(
    x = price %>%
      str_replace_all("[^0-9\\.]", "") %>%
      as.numeric()
  )
) +
  geom_histogram(bins = 50, fill = "steelblue") +
  labs(title = "Raw Price Distribution", x = "Price", y = "Count")

# Room type counts (raw)
ggplot(listings_raw, aes(x = room_type)) +
  geom_bar(fill = "purple") +
  labs(title = "Room Type Counts (Raw Data)", x = "Room type", y = "Count")

# Availability 365 distribution (raw)
ggplot(listings_raw, aes(x = availability_365)) +
  geom_histogram(bins = 50, fill = "darkgreen") +
  labs(title = "Availability 365 Distribution", x = "Available days", 
       y = "Count")

# Review score rating distribution (raw)
ggplot(listings_raw, aes(x = review_scores_rating)) +
  geom_histogram(bins = 50, fill = "coral") +
  labs(
    title = "Raw Review Score Rating Distribution",
    x = "Review score rating",
    y = "Count"
  )


########################################
# Q3A  Select relevant columns
########################################

listings = listings_raw %>%
  select(
    id,
    neighbourhood_cleansed, amenities,
    latitude, longitude,
    property_type, room_type,
    accommodates, bedrooms, beds, bathrooms_text,
    price, minimum_nights, maximum_nights,
    availability_365, availability_30,
    number_of_reviews, reviews_per_month,
    review_scores_rating,
    review_scores_cleanliness,
    review_scores_location,
    host_is_superhost, host_acceptance_rate, host_response_rate,
    host_total_listings_count,
    instant_bookable,
    calculated_host_listings_count
  )


########################################
# Q3B  Clean price to numeric
########################################

listings = listings %>%
  mutate(
    price_num = price %>%
      str_replace_all("[^0-9\\.]", "") %>%
      as.numeric()
  )


########################################
# Q3C  Remove rows with missing key fields
########################################

listings = listings %>%
  filter(
    !is.na(price_num),
    !is.na(availability_365),
    !is.na(review_scores_rating)
  )


########################################
# Q3D  Revenue and occupancy
########################################

listings = listings %>%
  mutate(
    nights_booked = 365 - availability_365,
    nights_booked = ifelse(nights_booked < 0, NA, nights_booked),
    annual_revenue = price_num * nights_booked,
    occupancy_rate = nights_booked / 365
  ) %>%
  filter(!is.na(annual_revenue))


########################################
# Q3E  Amenities and bathrooms
########################################

listings = listings %>%
  mutate(
    amenity_count = ifelse(
      is.na(amenities),
      0,
      str_count(amenities, ",") + 1
    )
  )

extract_bathrooms = function(x) {
  x = tolower(x)
  sapply(x, function(txt) {
    if (is.na(txt) || trimws(txt) == "") {
      return(NA_real_)
    }
    if (grepl("half[- ]bath", txt)) {
      num = suppressWarnings(as.numeric(gsub("([0-9\\.]+).*", "\\1", txt)))
      if (!is.na(num)) {
        return(num)
      } else {
        return(0.5)
      }
    }
    num = suppressWarnings(as.numeric(gsub("([0-9\\.]+).*", "\\1", txt)))
    if (!is.na(num)) {
      return(num)
    } else {
      return(NA_real_)
    }
  })
}

listings = listings %>%
  mutate(
    bathrooms = extract_bathrooms(bathrooms_text)
  )


########################################
# Q3F  Define success (Good Bad)
########################################

min_listings = 5

listings = listings %>%
  group_by(
    neighbourhood_cleansed,
    room_type,
    accommodates,
    bedrooms
  ) %>%
  mutate(
    group_n = n(),
    group_median_rev = median(annual_revenue, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  mutate(
    success = ifelse(
      group_n >= min_listings &
        annual_revenue >= group_median_rev &
        review_scores_rating >= 4.5,
      "Good", "Bad"
    ),
    success = factor(success, levels = c("Bad", "Good"))
  )

dim(listings)
table(listings$success)
prop.table(table(listings$success))


########################################
# Q3  EDA – engineered variables
########################################

# Annual revenue by bedrooms
ggplot(listings, aes(x = factor(bedrooms), y = annual_revenue)) +
  geom_boxplot(fill = "orange") +
  labs(title = "Annual Revenue by Bedrooms", x = "Bedrooms", y = "Annual Revenue")

# Success proportion by room type
ggplot(listings, aes(x = room_type, fill = success)) +
  geom_bar(position = "fill") +
  labs(title = "Success Proportion by Room Type", x = "Room type", y = "Proportion")

# Annual revenue distribution
ggplot(listings, aes(x = annual_revenue)) +
  geom_histogram(bins = 50, fill = "skyblue") +
  labs(
    title = "Annual Revenue Distribution",
    x = "Annual revenue",
    y = "Count"
  )

# Occupancy rate distribution
ggplot(listings, aes(x = occupancy_rate)) +
  geom_histogram(bins = 50, fill = "seagreen") +
  labs(
    title = "Occupancy Rate Distribution",
    x = "Occupancy rate",
    y = "Count"
  )

# Review score rating distribution after cleaning
ggplot(listings, aes(x = review_scores_rating)) +
  geom_histogram(bins = 50, fill = "tomato") +
  labs(
    title = "Review Score Rating Distribution (Cleaned Data)",
    x = "Review score rating",
    y = "Count"
  )

# Success proportion by Superhost status
ggplot(listings, aes(x = host_is_superhost, fill = success)) +
  geom_bar(position = "fill") +
  labs(
    title = "Success Proportion by Superhost Status",
    x = "Host is Superhost",
    y = "Proportion"
  ) +
  scale_fill_manual(values = c("Bad" = "tomato", "Good" = "seagreen3"))

# Minimum nights distribution
ggplot(listings, aes(x = minimum_nights)) +
  geom_histogram(bins = 50, fill = "steelblue") +
  labs(
    title = "Distribution of Minimum Nights",
    x = "Minimum Nights",
    y = "Count"
  )

# Maximum nights distribution
ggplot(listings, aes(x = maximum_nights)) +
  geom_histogram(bins = 50, fill = "darkorange") +
  labs(
    title = "Distribution of Maximum Nights",
    x = "Maximum Nights",
    y = "Count"
  )

########################################
# Q4A  Remove outliers and keep active listings
########################################

p99_price = quantile(listings$price_num, 0.99, na.rm = TRUE)
p99_rev   = quantile(listings$annual_revenue, 0.99, na.rm = TRUE)

listings = listings %>%
  filter(
    price_num <= p99_price,
    annual_revenue <= p99_rev,
    availability_365 > 0,
    availability_365 <= 365
  )


########################################
# Q4B  Safe log price
########################################

listings = listings %>%
  mutate(
    log_price = ifelse(price_num > 0, log(price_num), NA_real_)
  ) %>%
  filter(!is.na(log_price))

# EDA – log price distribution
ggplot(listings, aes(x = log_price)) +
  geom_histogram(bins = 50, fill = "grey40") +
  labs(title = "Distribution of Log Price", x = "Log price", y = "Count")


########################################
# Q4C  Factors and host rate cleaning
########################################

listings = listings %>%
  mutate(
    room_type = factor(room_type),
    property_type = factor(property_type),
    neighbourhood_cleansed = factor(neighbourhood_cleansed),
    host_is_superhost = factor(host_is_superhost),
    instant_bookable = factor(instant_bookable),
    host_acceptance_rate = as.numeric(str_replace(host_acceptance_rate, "%", "")),
    host_response_rate = as.numeric(str_replace(host_response_rate, "%", "")),
    host_total_listings_count = as.numeric(host_total_listings_count)
  )


########################################
# Q4D  Imputation (only predictors)
########################################

num_impute = c(
  "review_scores_cleanliness", "review_scores_location",
  "number_of_reviews",
  "minimum_nights", "maximum_nights",
  "bedrooms", "beds", "bathrooms",
  "amenity_count",
  "host_response_rate", "host_acceptance_rate",
  "calculated_host_listings_count",
  "host_total_listings_count",
  "availability_30", "reviews_per_month"
)

for (col in num_impute) {
  if (col %in% names(listings)) {
    med = median(listings[[col]], na.rm = TRUE)
    listings[[col]][is.na(listings[[col]])] = med
  }
}

factor_impute = c("room_type", "property_type", "host_is_superhost", "instant_bookable")

for (col in factor_impute) {
  if (col %in% names(listings)) {
    mode_val = names(which.max(table(listings[[col]])))
    listings[[col]][is.na(listings[[col]])] = mode_val
  }
}


########################################
# Q4E  Correlation heatmap
########################################

num_vars = listings %>%
  select(
    price_num, annual_revenue, log_price,
    bedrooms, accommodates, beds,
    number_of_reviews, availability_365,
    availability_30, amenity_count, reviews_per_month,
  )

corr = cor(num_vars, use = "complete.obs")

ggplot(melt(corr), aes(Var1, Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low = "red", mid = "white", high = "blue") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Correlation Heatmap", x = "", y = "")


########################################
# Q4F  Build model_data
########################################

model_data = listings %>%
  select(
    success,
    availability_30,
    reviews_per_month,
    log_price,
    bedrooms, 
    minimum_nights, 
    maximum_nights,
    accommodates, 
#    beds,
#    number_of_reviews,
    review_scores_cleanliness,
    review_scores_location,
#    bathrooms,
    calculated_host_listings_count,
    room_type,
    amenity_count,
    host_is_superhost,
    host_acceptance_rate,
    host_response_rate,
#    host_total_listings_count,
    instant_bookable
  ) %>%
  na.omit()

dim(model_data)
str(model_data)


########################################
# Q4G  Train test split and factor alignment
########################################

set.seed(123)
train_index = createDataPartition(model_data$success, p = 0.8, list = FALSE)

train_data = model_data[train_index, ]
test_data  = model_data[-train_index, ]

# Balance Dataset
train_data$success = factor(train_data$success, levels = c("Bad", "Good"))

set.seed(123)

train_data = downSample(
  x = train_data %>% select(-success),
  y = train_data$success,
  yname = "success"
)

# Class balance check
prop.table(table(train_data$success))
prop.table(table(test_data$success))

# Align factor levels
factor_cols = sapply(train_data, is.factor)
for (col in names(train_data)[factor_cols]) {
  test_data[[col]] = factor(test_data[[col]], levels = levels(train_data[[col]]))
}


########################################
# Q6A  Logistic regression model
########################################

logit_model = glm(
  success ~ .,
  data = train_data,
  family = binomial(link = "logit")
)

summary(logit_model)

logit_probs = predict(logit_model, newdata = test_data, type = "response")
logit_pred  = ifelse(logit_probs >= 0.5, "Good", "Bad") %>%
  factor(levels = c("Bad", "Good"))

confusionMatrix(logit_pred, test_data$success, positive = "Good")

roc_obj = roc(
  response = test_data$success,
  predictor = logit_probs,
  levels = c("Bad", "Good")
)
auc(roc_obj)
plot(roc_obj, main = "ROC Curve for Logistic Regression")


########################################
# Q6B  Decision tree model
########################################

tree_model = tree(success ~ ., data = train_data)

summary(tree_model)

plot(tree_model)
text(tree_model, pretty = 0)

tree_pred = predict(tree_model, newdata = test_data, type = "class")
confusionMatrix(tree_pred, test_data$success, positive = "Good")
