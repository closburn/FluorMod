# ==============================================================================
# FM_WORKFLOW: Master Script for FluorMod Analysis
# ==============================================================================

# 1. SETUP
# ------------------------------------------------------------------------------
# Set this to your project folder path if running line-by-line, e.g.
# setwd("C:/Users/YourName/Documents/My_FluorMod_Project")

if (!require("nnls")) install.packages("nnls")
if (!require("readr")) install.packages("readr")
library(nnls)
library(readr)

# Load the helper scripts
source("scripts/reshaper_tool.R")
source("scripts/FluorMod_RTS.R")

# 2. LOAD DATA
# ------------------------------------------------------------------------------
message("--- Step 1: Loading Data ---")

# A. Vectorize Unknown Samples
#    (Assumes your raw CSVs are in "data/raw_eems")
unknown_data <- reshape_eems(
  input_path = "data/raw_eems",
  file_pattern = "^p_.*\\.csv$",
  output_file = "unknown_eems.csv")

# B. Load Source Library
#    (Assumes you have a pre-made source file in "data")
source_data <- readr::read_csv("data/source_eems.csv", 
                               name_repair = "minimal")

# 3. RUN MODEL
# ------------------------------------------------------------------------------
message("--- Step 2: Running FluorMod RTS ---")

# SAFETY CHECK: Create results folder if it doesn't exist
if (!dir.exists("results")) {
  dir.create("results")
  message("Created 'results' directory.")
}

# Create a run ID (Results will save to "results/" folder)
run_id <- paste0("results/FM_", format(Sys.Date(), "%Y%m%d"))

# Run the function
results <- FluorMod_RTS(
  source_eem_data = source_data,
  unknown_eem_data = unknown_data,
  output_prefix = run_id
)

# 4. REVIEW
message("--- Analysis Complete! ---")
print("Top 5 Samples by Fit (R2):")
print(head(results$pcts[order(-results$pcts$R2), c("eem_name", "R2", "RMSE")], 5))
