# UCLL Data Visualisation — Group F2: Food Dataset Validation Dashboard

## About the Project
This repository contains the R Shiny dashboard for Group F2. Our client needs to validate newly scanned food products and detect duplicates. This app helps dietitians compare products, filter by match confidence, and allows developers to simulate similarity threshold weights.

## Team Members
*  BELABED Lina
*  ROTTÉ Nand
*  NDACASABA Eddy

## How to Run the App
1. Open the project folder in RStudio.
2. Make sure you have the required packages installed:
   ```R
   install.packages(c("shiny", "reactable", "ggplot2", "tidymodels", "tidyverse"))
   ```
3. Click the "Run App" button in RStudio, or run the following command in the console:
    ```R
    shiny::runApp()
    ```

## Repository Structure
- **```app.R```:** The main Shiny application (UI and Server).
- **```R/```:** Helper functions for data processing and machine learning.
- **```data/```:** Mock data currently used for the prototype.
- **```models/```:** Precomputed ML similarity scores (to ensure fast reactivity).
- **```docs/```:** Design blueprints (User Questions, Mermaid diagrams, Pitch).

## Machine Learning Integration
We are using the Precomputed Predictions method. The similarity algorithm (Cosine Similarity for text + distance metrics for nutrition) is run offline, and the scores are loaded into the app. This prevents the dashboard from freezing during expensive calculations.