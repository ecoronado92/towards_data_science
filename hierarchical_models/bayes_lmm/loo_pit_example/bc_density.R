# Based on code by Yang Hu and Carl Scarrott in evmix package
# and code from bayesplot developers (Aki Vehtari, Jonah Gabry, et al)

# Boundary correction KDE helper function
bc_dunif <- function(xs, pvals, b, xmax = 1){
  
  # Function based on biased-corrected (modified) beta kernel 
  # Chen, Song Xi. "Beta kernel estimators for density functions." 
  # Computational Statistics & Data Analysis 31.2 (1999): 131-145.
  
  # Re-scaling inputs based on upper_bound given beta kernel is defined [0,1]
  
  xs <- xs/xmax
  pvals <- pvals/xmax
  b <-  b/xmax # smoothing parameter (i.e. bw)
  
  # Bias correction function
  rho <- function(x, b) {
    return(2*b^2 + 2.5 - sqrt(4*b^4 + 6*b^2 + 2.25 - x^2 - x/b))
  }
  
  bc_kde_calc <- function(xs, b,  pvals){
    # Piecewise kernel value estimation
    if ((xs >= 2*b) & (xs <= (1 - 2*b))) {
      d <- mean(dbeta(pvals, xs/b, (1 - xs)/b))
      
    } else if ((xs >= 0) & (xs < 2*b)) {
      d <- mean(dbeta(pvals, rho(xs, b), (1 - xs)/b))
      
    } else if ((xs > (1 - 2*b)) & (xs <= 1)) {
      d <- mean(dbeta(pvals, xs/b, rho(1 - xs, b)))
      
    } else {
      d <- 0
    }
  }

    d <- vapply(X = xs, 
             FUN = bc_kde_calc, 
             b = b,
             pvals = pvals, 
             FUN.VALUE = 0)
  
  return(d/xmax)
  
}

# Wrapper helper function, transforms pvals / pit vals into bc values
bc_pvals <- function(x, bw = "nrd0"){
  
  # Set-up
  xs  <- seq(0, 1, length.out = length(x))
  d <- xs
  xmax <- 1 + 1e-9
  
  bw <- density(x, bw = bw)$bw # extract bw
  
  # get only valid pvals
  valid_pvals <- x[is.finite(x)]
  
  # Some sanity checks
  if (abs(xmax - max(valid_pvals)) >= 1e-1) {
    stop("largest PIT value must be below 1")
  }
  
  # Ignore zeros to avoid problems during KDE estimation
  if (any(valid_pvals == 0)) {
    warning(paste("Ignored", sum(valid_pvals == 0),
                  "PIT values == 0, they are invalid for beta KDE method"))
    valid_pvals = valid_pvals[valid_pvals != 0]
  }
  
  bc_vals <- bc_dunif(xs = xs, pvals=valid_pvals, b =bw)
  
  # Set any negative values to zero and output bc density values
  bc_vals[which(bc_vals < 0)] = 0
  d[ifelse(!is.na(xs), (xs >= 0) & (xs <= 1), FALSE)] = bc_vals
  
  return(d)
  
}

# Use bc_pvals to generate random uniform bc pvals
generate_bc_runifs <- function(x, n, bw = "nrd0"){
  unifs <- matrix(runif(length(x) * n), nrow = n)
  bcunif <- apply(unifs, 1, function(x) bc_pvals(x, bw = bw))
 
  return(t(bcunif))
}

# Modified function, commented out internal funcs
ppc_loo_pit_overlay2 <- function(y,
                                yrep,
                                lw,
                                pit,
                                samples = 100,
                                ...,
                                size = 0.25,
                                alpha = 0.7,
                                trim = FALSE,
                                bw = "nrd0"
                                #adjust = 1,
                                #kernel = "gaussian",
                                #n_dens = 1024
                                ) {
  #check_ignored_arguments(...)
  
  if (!missing(pit)) {
  #  stopifnot(is.numeric(pit), is_vector_or_1Darray(pit))
    inform("'pit' specified so ignoring 'y','yrep','lw' if specified.")
  } else {
    #suggested_package("rstantools")
    #y <- validate_y(y)
    #yrep <- validate_yrep(yrep, y)
    stopifnot(identical(dim(yrep), dim(lw)))
    pit <- rstantools::loo_pit(object = yrep, y = y, lw = lw)
    
    bcpit <- bc_pvals(x = pit, bw = bw) 
  }
  
  unifs <- generate_bc_runifs(x = bcpit, n = samples, bw = bw )

  data <- ppc_data(bcpit, unifs) %>% 
    arrange(rep_id) %>% 
    mutate(xx = rep(seq(0, 1, length.out = length(bcpit)), 
                    times = samples + 1))
  
  ggplot(data) +
    aes_(x = ~ xx, y = ~ value) +
    geom_line(aes_(group = ~rep_id,  color = "yrep"),
              data = function(x) dplyr::filter(x, !.data$is_y),
              alpha = 0.7,
              size = 0.25,
              na.rm = TRUE) +
    geom_line(aes_(color = "y"),
              data = function(x) dplyr::filter(x, .data$is_y),
              size = 1,
              na.rm = TRUE) +
    scale_color_ppc_dist(labels = c("PIT", "Unif")) +
    scale_x_continuous(
      limits = c(0, 1),
      expand = expansion(0, 0),
      breaks = seq(from = .1, to = .9, by = .2)) +
    scale_y_continuous(
      limits = c(0, NA),
      expand = expansion(mult = c(0, .25))) +
    bayesplot_theme_get() +
    yaxis_title(FALSE) +
    xaxis_title(FALSE) +
    yaxis_text(FALSE) +
    yaxis_ticks(FALSE)
  
}

## BAYESPLOT INTERNAL FUNCTIONS 
# (credit goes to package contributors)
scale_color_ppc_dist <- function(name = NULL, values = NULL, labels = NULL) {
  scale_color_manual(
    name = name %||% "",
    values = values %||% get_color(c("dh", "lh")),
    labels = labels %||% c(y_label(), yrep_label())
  )
}

get_color <- function(levels) {
  levels <- full_level_name(levels)
  stopifnot(all(levels %in% scheme_level_names()))
  color_vals <- color_scheme_get()[levels]
  unlist(color_vals, use.names = FALSE)
}

full_level_name <- function(x) {
  map <- c(
    l = "light",
    lh = "light_highlight",
    m = "mid",
    mh = "mid_highlight",
    d = "dark",
    dh = "dark_highlight",
    light = "light",
    light_highlight = "light_highlight",
    mid = "mid",
    mid_highlight = "mid_highlight",
    dark = "dark",
    dark_highlight = "dark_highlight"
  )
  unname(map[x])
}

scheme_level_names <- function() {
  c("light",
    "light_highlight",
    "mid",
    "mid_highlight",
    "dark",
    "dark_highlight")
}

