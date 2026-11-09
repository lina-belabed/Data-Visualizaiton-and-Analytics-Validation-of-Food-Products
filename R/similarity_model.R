# Function to load the precomputed ML scores
load_precomputed_scores <- function() {
  # Load the model you saved in the models/ folder
  scores <- readRDS("models/precomputed_scores.rds")
  return(scores)
}