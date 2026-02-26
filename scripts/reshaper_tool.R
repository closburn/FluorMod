# reshaper_tool.R

#' Reshape EEMs CSVs into a Matrix
#'
#' @param input_path String. Directory containing the CSV files. Default is current directory.
#' @param file_pattern String. Regex pattern for files. Default is "^p_.*\\.csv$".
#' @param output_file String. Name of output file. If NULL, does not save to disk.
#'
#' @return A matrix of flattened EEMs.
reshape_eems <- function(input_path = ".", 
                         file_pattern = "^p_.*\\.csv$", 
                         output_file = "unknown_eems.csv") {
  
  # 1. Get file names
  # full.names = TRUE is important so R can find the files if they are in a subfolder
  file_paths <- list.files(path = input_path, pattern = file_pattern, full.names = TRUE)
  
  # Check if files were found
  if (length(file_paths) == 0) {
    stop("No files found matching that pattern in the specified directory.")
  }
  
  message(paste("Found", length(file_paths), "files. Processing..."))
  
  # 2. Read CSVs
  # We use tryCatch to handle bad files gracefully
  data_list <- lapply(file_paths, function(x) {
    tryCatch({
      as.matrix(read.table(x, sep = "", header = FALSE, na.strings = c("NaN", "nan", "NA")))
    }, error = function(e) {
      warning(paste("Could not read file:", x))
      return(NULL)
    })
  })
  
  # Remove any NULL entries if a file failed to read
  data_list <- data_list[!sapply(data_list, is.null)]
  
  # 3. Stack to 3D Array
  # simplify2array automatically handles the 3D stacking
  my_array <- simplify2array(data_list)
  
  # 4. Vectorize (Flatten)
  # Dynamic calculation: We don't hardcode 151 or 43. 
  # We use prod(dim(my_array)[1:2]) to calculate total rows needed.
  rows_per_file <- prod(dim(my_array)[1:2])
  num_files <- dim(my_array)[3]
  
  final_matrix <- matrix(my_array, nrow = rows_per_file, ncol = num_files)
  
  # 5. Assign Headers
  # Extract just the filename without path or extension for the header
  clean_headers <- tools::file_path_sans_ext(basename(file_paths))
  colnames(final_matrix) <- clean_headers
  
  # 6. Export (Optional)
  if (!is.null(output_file)) {
    write.csv(final_matrix, file = output_file, row.names = FALSE)
    message(paste("Success! Saved as:", output_file))
  }
  
  # This passes the data back to 'unknown_data' but stops it from flooding the console
  invisible(as.data.frame(final_matrix))
}