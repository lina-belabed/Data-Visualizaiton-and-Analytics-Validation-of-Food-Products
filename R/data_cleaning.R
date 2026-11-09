library(readxl)
library(dplyr)

# Function to load and clean the text data
load_text_data <- function() {
  # Assuming your files are in the data/ folder
  df <- read_excel("data/text_food.xlsx")
  # Add any cleaning steps here (e.g., removing NAs, formatting)
  return(df)
}

# Function to load and clean the numeric data
load_numeric_data <- function() {
  df <- read_excel("data/numeric_food.xlsx")
  return(df)
}