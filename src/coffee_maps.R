# Coffee Shop Maps: Deserts and Oases
# Name: Add Your Name Here

# This script has 10 bugs hiding in it! Run it line by line (Cmd+Return /
# Ctrl+Enter). When R complains, read the error message, find the matching
# numbered bug comment, fix the code, and then DELETE that comment (and its
# hint) once it works.

# Clear environment and plots
rm(list = ls()) # clear all variables
graphics.off()  # clear all plots
cat("\014")    # clear the console

# Study area (a State College, PA sized box; all data are fictional)
lon_min <- -77.92; lon_max <- -77.80
lat_min <-  40.76; lat_max <-  40.83

# ---- Part 1: Load and inspect the data --------------------------------------

# TODO (Bug 1): R says `could not find function "libary"`.
# Hint: check the spelling of the function name.
libary(tidyverse)
library(plotly)


# Note there are different ways to load the data. You can use `file.choose()` to
# select the file interactively, or you can hard-code the path to the file. 
# The following lines are commented out because they are not needed if you hard-code the paths.
#shops     <- read_csv("../data/coffee-shops.csv")
#landmarks <- read_csv("../data/myLandmarks.csv")

# TODO (Bug 2): R says `'data/Coffee-Shops.csv' does not exist`.
# Hint: file names are case sensitive. Look in the data/ folder to see the
# exact name. Otherwise, you could use `file.choose()` to select the file interactively but that
# would take a buncha time to click through.

#fname_shops <- file.choose()
fname_shops <- "../data/Coffee-Shops.csv"

#fname_landmarks <- file.choose()
fname_landmarks <- "../data/Landmarks.csv"

shops     <- read_csv(fname_shops)
landmarks <- read_csv(fname_landmarks)

# TODO (Bug 3): R says `object 'Shops' not found`.
# Hint: R is case sensitive. What did you name the data frame above?
glimpse(Shops)
nrow(shops)

# ---- Part 2: A first map ----------------------------------------------------

# TODO (Bug 4): R says `unexpected symbol` inside aes().
# Hint: arguments in a function call are separated by a character.
ggplot(shops, aes(x = lon y = lat)) +
  geom_point(alpha = 0.6, color = "saddlebrown") +
  coord_quickmap() +
  labs(title = "Where Are the Coffee Shops?", x = "Longitude", y = "Latitude") +
  theme_minimal()

# ---- Part 3: Color the map by neighborhood ----------------------------------

# TODO (Bug 5): R says `object 'neigborhood' not found`.
# Hint: compare your spelling to the column names that glimpse() printed.
ggplot(shops, aes(x = lon, y = lat, color = neigborhood)) +
  geom_point(alpha = 0.7, size = 2) +
  coord_quickmap() +
  labs(title = "Coffee Shops by Neighborhood", x = "Longitude", y = "Latitude",
       color = "Neighborhood") +
  theme_minimal()

# ---- Part 4: Summarize by neighborhood --------------------------------------

# TODO (Bug 6): R says `could not find function "Group_by"`.
# Hint: tidyverse function names are all lowercase.
# TODO (Bug 7): R says `argument "x" is missing, with no default`.
# Hint: mean() needs to be told WHICH column to average.
neighborhood_summary <- shops %>%
  Group_by(neighborhood) %>%
  summarize(n_shops = n(), avg_rating = mean()) %>%
  arrange(desc(n_shops))

neighborhood_summary

ggplot(neighborhood_summary, aes(x = reorder(neighborhood, n_shops), y = n_shops)) +
  geom_col(fill = "saddlebrown") +
  coord_flip() +
  labs(title = "Number of Coffee Shops per Neighborhood",
       x = "", y = "Number of shops") +
  theme_minimal()

# ---- Part 5: Density map (where do shops pile up?) --------------------------

# Note: The package "hexbin" is required for `stat_bin_hex()`.
# You will be asked to install it.

# TODO (Bug 8): R says `invalid argument to unary operator`. Look at the
# START of each line in this plot.
# Hint: where does the `+` belong when a ggplot continues on the next line?
ggplot(shops, aes(x = lon, y = lat)) +
  geom_hex(bins = 15)
  + scale_fill_viridis_c(option = "magma") +
  coord_quickmap() +
  labs(title = "Coffee Shop Density", x = "Longitude", y = "Latitude",
       fill = "Shops") +
  theme_minimal()

# ---- Part 6: Find the deserts and oases -------------------------------------

# Chop the study area into cells of 0.01 degrees (roughly 1 km x 1 km)
cell_counts <- shops %>%
  mutate(lon_cell = round(lon * 100), lat_cell = round(lat * 100)) %>%
  count(lon_cell, lat_cell, name = "n_shops")

# Make sure empty cells are in the table too (they are the deserts!)
grid_all <- expand_grid(
  lon_cell = round(lon_min * 100):round(lon_max * 100),
  lat_cell = round(lat_min * 100):round(lat_max * 100)
)

# TODO (Bug 9): R says `must be a logical vector, not the number 0`.
# Hint: a single = ASSIGNS a value. To ASK whether two things are equal, you
# need a different operator (two characters).
zones <- grid_all %>%
  left_join(cell_counts, by = c("lon_cell", "lat_cell")) %>%
  mutate(
    n_shops = replace_na(n_shops, 0),
    lon_bin = lon_cell / 100,
    lat_bin = lat_cell / 100,
    zone = case_when(
      n_shops = 0  ~ "Desert",
      n_shops >= 8 ~ "Oasis",
      TRUE         ~ "Typical"
    )
  )

zones %>% count(zone)

# TODO (Bug 10): When you print p_zones, R says `Insufficient values in
# manual scale. 3 needed but only 0 provided`.
# Hint: look at scale_fill_manual(). The colors are there, but R does not
# know which argument they belong to. (A missing `VALUES` argument is a bug too!)
# Note: you could use an online engine to check the syntax of scale_fill_manual() 
# if you are unsure.

p_zones <- ggplot(zones, aes(x = lon_bin, y = lat_bin, fill = zone)) +
  geom_tile(color = "white") +
  geom_point(data = landmarks, aes(x = lon, y = lat, shape = type),
             inherit.aes = FALSE, size = 3) +
  scale_fill_manual(   c("Desert" = "#e8d9a8", "Typical" = "#b08968",
                      "Oasis" = "#3d2314")) +
  coord_quickmap() +
  labs(title = "Coffee Deserts and Oases", x = "Longitude", y = "Latitude",
       fill = "Zone", shape = "Landmark") +
  theme_minimal()

p_zones

# ---- Part 7: Make it interactive --------------------------------------------

# This part is bug-free. Hover over the points and look at the tooltips.
p_hover <- ggplot(shops, aes(x = lon, y = lat, color = chain_type,
                             text = paste0(name, "<br>Rating: ", rating))) +
  geom_point(alpha = 0.7) +
  coord_quickmap() +
  labs(title = "Hover Over a Shop", x = "Longitude", y = "Latitude",
       color = "Type") +
  theme_minimal()

ggplotly(p_hover, tooltip = "text")

# ---- Part 8: Put the shops on a (made-up) city map ----------------------------

# This part is bug-free. The "city" is invented: a street grid, blocks of
# buildings, a river, and a highway, all drawn in longitude/latitude units so
# the shops line up with it. The gray background shows through as the ROADS.
set.seed(301)
block_size <- 0.01

city_blocks <- expand_grid(
  x0 = seq(lon_min - 0.005, lon_max - 0.005 + 1e-9, by = block_size),
  y0 = seq(lat_min - 0.005, lat_max - 0.005 + 1e-9, by = block_size)
) %>%
  mutate(
    d_center = sqrt((x0 + 0.005 + 77.86)^2 + (y0 + 0.005 - 40.795)^2),
    block_type = case_when(
      runif(n()) < 0.07 ~ "Park",
      d_center < 0.012  ~ "High-rise",
      d_center < 0.03   ~ "Mid-rise",
      TRUE              ~ "Low-rise"
    )
  )

# Four buildings per block, leaving a gap along every side for the streets
buildings <- expand_grid(city_blocks, i = 0:1, j = 0:1) %>%
  mutate(
    xmin = x0 + 0.0012 + i * 0.0041,
    ymin = y0 + 0.0012 + j * 0.0041,
    xmax = xmin + 0.0035,
    ymax = ymin + 0.0035
  )

river <- tibble(lat = seq(lat_min - 0.005, lat_max + 0.005, length.out = 100)) %>%
  mutate(lon = -77.812 + 0.004 * sin((lat - lat_min) * 150))

highway <- tibble(x = lon_min - 0.005, y = 40.768, xend = lon_max + 0.005, yend = 40.782)

city_base <- ggplot() +
  geom_rect(data = buildings,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = block_type)) +
  geom_path(data = river, aes(x = lon, y = lat), color = "#6fa8dc", linewidth = 3) +
  geom_segment(data = highway, aes(x = x, y = y, xend = xend, yend = yend),
               color = "#f4b183", linewidth = 1.5) +
  scale_fill_manual(values = c("High-rise" = "#d37c7c", "Mid-rise" = "#937d47",
                               "Low-rise" = "#493507", "Park" = "#28e60f")) +
  coord_quickmap(xlim = c(lon_min - 0.005, lon_max + 0.005),
                 ylim = c(lat_min - 0.005, lat_max + 0.005)) +
  theme_minimal() +
  theme(panel.background = element_rect(fill = "#5c5c5c"),
        panel.grid = element_blank())

chain_colors <- c("National chain" = "#c0392b", "Regional chain" = "#2980b9",
                  "Independent" = "#e67e22")

# 8a: every shop on the city map
p_city_shops <- city_base +
  geom_point(data = shops, aes(x = lon, y = lat, color = chain_type),
             size = 2, alpha = 0.9) +
  scale_color_manual(values = chain_colors) +
  labs(title = "Coffee Shops in Our Made-Up City", x = "Longitude", y = "Latitude",
       fill = "Buildings", color = "Shop type")

p_city_shops

# 8b: shade the desert cells from Part 6 and label the landmarks
p_city_deserts <- city_base +
  geom_tile(data = zones %>% filter(zone == "Desert"),
            aes(x = lon_bin, y = lat_bin), fill = "red", alpha = 0.25,
            width = 0.01, height = 0.01) +
  geom_point(data = shops, aes(x = lon, y = lat), size = 1.5, color = "#3d2314") +
  geom_point(data = landmarks, aes(x = lon, y = lat), shape = 17, size = 4) +
  geom_text(data = landmarks, aes(x = lon, y = lat, label = landmark),
            vjust = -1, size = 3, check_overlap = TRUE) +
  labs(title = "Where the City Has No Coffee (red = desert cells)",
       x = "Longitude", y = "Latitude", fill = "Buildings")

p_city_deserts

# 8c: one panel per shop type
p_city_types <- city_base +
  geom_point(data = shops, aes(x = lon, y = lat, color = chain_type), size = 1.5) +
  scale_color_manual(values = chain_colors) +
  facet_wrap(~chain_type) +
  labs(title = "Shop Types Across the City", x = "Longitude", y = "Latitude",
       fill = "Buildings", color = "Shop type") +
  theme(legend.position = "bottom")

p_city_types
