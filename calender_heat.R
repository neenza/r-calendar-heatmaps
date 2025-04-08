#' Calendar Heatmap for Financial Returns
#'
#' Creates a calendar heatmap visualization of financial returns data.
#' 
#' @param returns Numeric vector of daily returns
#' @param start_date Date or character string (YYYY-MM-DD) for the start date
#' @param end_date Date or character string (YYYY-MM-DD) for the end date
#' @param title Character string for the plot title, defaults to "Calendar Heatmap of Returns"
#' @param low_color Color for negative returns, defaults to "red"
#' @param mid_color Color for zero returns, defaults to "white"
#' @param high_color Color for positive returns, defaults to "green"
#' 
#' @return A ggplot2 object
#' @examples
#' # Example with simulated data for a full year
#' set.seed(123)
#' returns <- rnorm(365, mean = 0, sd = 0.02)
#' create_calendar_heatmap(returns, "2023-01-01", "2023-12-31")
#' 
#' # Example with shorter period
#' set.seed(456)
#' returns <- rnorm(90, mean = 0, sd = 0.02)
#' create_calendar_heatmap(returns, "2023-01-01", "2023-03-31", 
#'                        title = "Q1 2023 Returns")
create_calendar_heatmap <- function(returns, 
                                    start_date = Sys.Date() - 365, 
                                    end_date = Sys.Date(),
                                    title = "Calendar Heatmap of Returns",
                                    low_color = "red", 
                                    mid_color = "white", 
                                    high_color = "green") {
  # Load required libraries
  if (!requireNamespace("ggplot2", quietly = TRUE)) stop("Package 'ggplot2' is required")
  if (!requireNamespace("lubridate", quietly = TRUE)) stop("Package 'lubridate' is required")
  if (!requireNamespace("dplyr", quietly = TRUE)) stop("Package 'dplyr' is required")
  
  library(ggplot2)
  library(lubridate)
  library(dplyr)
  
  # Convert input dates if needed
  if (!inherits(start_date, "Date")) start_date <- as.Date(start_date)
  if (!inherits(end_date, "Date")) end_date <- as.Date(end_date)
  
  # Validate inputs
  if (is.null(returns) || !is.numeric(returns)) {
    stop("Returns must be a numeric vector")
  }
  
  if (end_date < start_date) {
    stop("End date must be after start date")
  }
  
  # Create date sequence
  dates <- seq.Date(from = start_date, to = end_date, by = "day")
  
  # Validate returns length
  if (length(returns) != length(dates)) {
    stop(paste("Length of returns (", length(returns), 
               ") must match number of days between dates (", length(dates), ")", sep = ""))
  }
  
  # Prepare data for heatmap
  data <- data.frame(date = dates, returns = returns)
  
  data <- data %>%
    mutate(
      year = year(date),
      month = factor(format(date, "%b"), levels = month.abb),
      weekday = factor(format(date, "%a"), levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")),
      month_start = floor_date(date, "month"),
      first_weekday = (wday(floor_date(date, "month")) + 5) %% 7 + 1,
      week = as.integer((as.numeric(difftime(date, month_start, units = "days")) + first_weekday - 1) %/% 7 + 1),
      month_year = factor(format(date, "%b %Y"))
    )
  
  # Define color mapping
  heatmap_colors <- scale_fill_gradient2(
    low = low_color, mid = mid_color, high = high_color,
    midpoint = 0, na.value = "grey50",
    name = "Returns"
  )
  
  # Create the heatmap
  p <- ggplot(data, aes(x = weekday, y = week, fill = returns)) +
    geom_tile(color = "black") +
    facet_wrap(~month_year, ncol = 3, scales = "free") +
    heatmap_colors +
    scale_y_reverse(breaks = unique(data$week)) +
    theme_minimal() +
    labs(title = title) +
    theme(
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text.x = element_text(angle = 45, hjust = 1),
      panel.grid = element_blank(),
      strip.text = element_text(size = 11, face = "bold"),
      legend.position = "bottom"
    )
  
  return(p)
}

# Demo function to showcase usage with different parameters
demo_calendar_heatmap <- function() {
  # Load lubridate explicitly for the demo function
  library(lubridate)
  
  # Example 1: Full year of data
  set.seed(123)
  year <- 2023
  dates1 <- seq.Date(from = as.Date(paste0(year, "-01-01")), 
                     to = as.Date(paste0(year, "-12-31")), by = "day")
  returns1 <- rnorm(length(dates1), mean = 0, sd = 0.02)
  
  # Introduce some patterns
  returns1[lubridate::month(dates1) == 4] <- returns1[lubridate::month(dates1) == 4] + 0.01  # April trend
  returns1[lubridate::wday(dates1) == 2] <- returns1[lubridate::wday(dates1) == 2] - 0.005   # Monday effect
  
  p1 <- create_calendar_heatmap(
    returns = returns1,
    start_date = dates1[1],
    end_date = dates1[length(dates1)],
    title = paste("Calendar Heatmap of Returns -", year)
  )
  
  # Example 2: Quarter with different colors
  set.seed(456)
  dates2 <- seq.Date(from = as.Date("2023-01-01"), to = as.Date("2023-03-31"), by = "day")
  returns2 <- rnorm(length(dates2), mean = 0, sd = 0.015)
  
  p2 <- create_calendar_heatmap(
    returns = returns2,
    start_date = dates2[1],
    end_date = dates2[length(dates2)],
    title = "Q1 2023 Returns",
    low_color = "blue", 
    mid_color = "#F8F8F8", 
    high_color = "orange"
  )
  
  # Print the plots (you could also save them)
  print(p1)
  print(p2)
  
  return(list(yearly_plot = p1, quarterly_plot = p2))
}

# Uncomment this line to run the demo
# demo_calendar_heatmap()