#' FluorMod using Regression Tracking Sources (RTS)
#'
#' @param source_eem_data A data frame/matrix of source EEMs (The Library).
#' @param unknown_eem_data A data frame/matrix of unknown EEMs (The Samples).
#' @param output_prefix String prefix for saved files (e.g., "Run1").
#'
#' @return A list containing percentages, summed weights, and individual weights.
#' @export
FluorMod_RTS <- function(source_eem_data, 
                         unknown_eem_data, 
                         output_prefix = "FM_results") {
  
  # 1. Dependency Check
  if (!requireNamespace("nnls", quietly = TRUE)) stop("Package 'nnls' is required.")
  if (!requireNamespace("readr", quietly = TRUE)) stop("Package 'readr' is required.")
  
  # 2. Setup Source Grouping
  source_labels <- colnames(source_eem_data)
  sources <- unique(source_labels)
  K <- length(sources)       
  N <- length(source_labels) 
  
  # Create Grouping Matrix G
  G <- matrix(0, nrow = K, ncol = N)
  for(k in 1:K) {
    G[k, source_labels == sources[k]] <- 1
  }
  
  # 3. Prepare Data Matrices
  S <- as.matrix(source_eem_data)
  U <- unknown_eem_data
  num_samples <- ncol(U)
  
  # Initialize storage
  mycoefs <- matrix(0, nrow = num_samples, ncol = N)           # Individual Weights
  source_contributions_raw <- matrix(0, nrow = num_samples, ncol = K) # Summed Weights
  predicted_matrix <- matrix(0, nrow = nrow(S), ncol = num_samples)   # Predicted EEMs
  
  # 4. Regression Loop (Robust & Vectorized)
  for(j in 1:num_samples) {
    y <- U[[j]] # Single unknown sample vector
    
    # Only use rows where Source AND Unknown have valid data (No NAs)
    incl_rows <- complete.cases(S) & !is.na(y)
    
    if (sum(incl_rows) > 0) {
      # Solve NNLS
      fit <- nnls::nnls(S[incl_rows, ], y[incl_rows])
      
      # Store coefficients
      mycoefs[j, ] <- fit$x
      
      # Store summed group weights
      source_contributions_raw[j, ] <- as.numeric(G %*% fit$x)
      
      # Calculate predicted EEM (S * weights)
      predicted_matrix[, j] <- S %*% fit$x
    } else {
      warning(paste("Sample", j, "has no valid data points for regression."))
    }
  }
  
  # 5. Normalization (Percentages)
  row_sums <- rowSums(source_contributions_raw)
  row_sums[row_sums == 0] <- 1 # Avoid division by zero
  source_contributions_pct <- source_contributions_raw / row_sums
  
  # 6. Performance Metrics (RMSE, MAE, R2)
  residuals <- U - predicted_matrix
  
  # RMSE & MAE
  rmse_vals <- sqrt(colMeans(residuals^2, na.rm = TRUE))
  mae_vals <- colMeans(abs(residuals), na.rm = TRUE)
  
  # R2 Calculation
  ss_res <- colSums(residuals^2, na.rm = TRUE)
  u_means <- colMeans(U, na.rm = TRUE)
  ss_tot <- sapply(1:num_samples, function(i) {
    sum((U[[i]] - u_means[i])^2, na.rm = TRUE)
  })
  r2_vals <- 1 - (ss_res / ss_tot)
  
  # Fmax calculation
  fmax_vals <- sapply(U, max, na.rm = TRUE)
  
  # 7. Generate Output Files
  sample_names <- colnames(unknown_eem_data)
  metrics_df <- data.frame(R2 = r2_vals, Fmax = fmax_vals,
                           RMSE = rmse_vals, MAE = mae_vals)
  
  # File 1: Percentages
  df_pct <- data.frame(eem_name = sample_names, source_contributions_pct)
  colnames(df_pct)[2:(K+1)] <- sources
  df_pct <- cbind(df_pct, metrics_df)
  readr::write_csv(df_pct, paste0(output_prefix, "_pcts.csv"))
  
  # File 2: Summed Weights
  df_wts <- data.frame(eem_name = sample_names, source_contributions_raw)
  colnames(df_wts)[2:(K+1)] <- sources
  df_wts <- cbind(df_wts, metrics_df)
  readr::write_csv(df_wts, paste0(output_prefix, "_summed_weights.csv"))
  
  # File 3: Individual Weights
  df_ind <- data.frame(eem_name = sample_names, mycoefs)
  colnames(df_ind)[2:(N+1)] <- source_labels
  df_ind <- cbind(df_ind, metrics_df)
  readr::write_csv(df_ind, paste0(output_prefix, "_individual_weights.csv"))
  
  # Return object
  return(list(pcts = df_pct, summed_weights = df_wts, individual_weights = df_ind))
}