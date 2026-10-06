# Activity 05 - Coffee Walkability Shiny App
#
# How far is the nearest cup of coffee? This app measures the walking time
# from every spot on the map to the closest coffee shop, then highlights the
# "underserved" spots that are farther than your chosen walking time. Filter
# the shops (rating, chain type) to see how the deserts change. Click
# "Show Code" at any time to see the R code behind what is on screen.
#
# Run with:
#   install.packages(c("shiny", "tidyverse", "plotly"))
#   shiny::runApp("shiny_app")
#
# Note: run this from the activity root folder so the data/ path works.

library(shiny)
library(tidyverse)
library(plotly)

# --- Prepared data ----------------------------------------------------------

app_dir  <- if (file.exists("data/coffee_shops.csv")) "." else ".."
shops     <- read_csv(file.path(app_dir, "data", "coffee_shops.csv"), show_col_types = FALSE)
landmarks <- read_csv(file.path(app_dir, "data", "landmarks.csv"),    show_col_types = FALSE)

lon_min <- -77.92; lon_max <- -77.80
lat_min <-  40.76; lat_max <-  40.83

walk_speed_kmh <- 5

# Grid of "places someone might be standing" (0.004 degrees is about 350 m)
grid <- expand_grid(
  lon = seq(lon_min, lon_max, by = 0.004),
  lat = seq(lat_min, lat_max, by = 0.004)
)

# Walking minutes from each point to its NEAREST shop (flat-earth approximation)
nearest_walk_min <- function(lon, lat, shops_df) {
  km <- map2_dbl(lon, lat, function(x, y) {
    min(sqrt(((shops_df$lon - x) * cos(y * pi / 180) * 111.32)^2 +
             ((shops_df$lat - y) * 110.57)^2))
  })
  km / walk_speed_kmh * 60
}

chain_choices <- c("National chain", "Regional chain", "Independent")

# --- UI -----------------------------------------------------------------

ui <- fluidPage(
  titlePanel("Activity 05: Coffee Walkability Map"),

  sidebarLayout(
    sidebarPanel(
      sliderInput("max_walk", "Longest walk you will accept (minutes):",
                  min = 3, max = 30, value = 10, step = 1),

      sliderInput("min_rating", "Only count shops rated at least:",
                  min = 3, max = 5, value = 3, step = 0.1),

      checkboxGroupInput("chains", "Shop types to count:",
                         choices = chain_choices, selected = chain_choices),

      checkboxInput("show_shops", "Show shop locations", value = TRUE),

      hr(),
      actionButton("show_code", "Show Code", icon = icon("code")),
      helpText("Click to reveal the R code behind the map and the summary table.")
    ),

    mainPanel(
      h4("Who Can Walk to a Coffee Shop?"),
      plotlyOutput("walk_map", height = "480px"),
      hr(),
      h4("Summary"),
      tableOutput("summary_table"),
      h4("Landmarks"),
      tableOutput("landmark_table"),
      helpText("Walk time assumes 5 km/h in a straight line (no street network)."),

      conditionalPanel(
        condition = "input.show_code % 2 == 1",
        hr(),
        h4("Filter Code"),
        verbatimTextOutput("filter_code"),
        h4("Walk-Time Code"),
        verbatimTextOutput("walk_code"),
        h4("Plot Code"),
        verbatimTextOutput("plot_code")
      )
    )
  )
)

# --- Server ---------------------------------------------------------------

server <- function(input, output, session) {

  # Step 1: keep only the shops that pass the filters
  shops_used <- reactive({
    shops %>%
      filter(rating >= input$min_rating, chain_type %in% input$chains)
  })

  # Step 2: walking time from every grid point to the nearest remaining shop
  grid_walk <- reactive({
    validate(need(nrow(shops_used()) > 0, "No shops match these filters."))
    grid %>%
      mutate(
        walk_min = nearest_walk_min(lon, lat, shops_used()),
        status = if_else(walk_min <= input$max_walk, "Served", "Underserved")
      )
  })

  landmark_walk <- reactive({
    validate(need(nrow(shops_used()) > 0, "No shops match these filters."))
    landmarks %>%
      mutate(
        walk_min = round(nearest_walk_min(lon, lat, shops_used()), 1),
        status = if_else(walk_min <= input$max_walk, "Served", "Underserved")
      )
  })

  output$walk_map <- renderPlotly({
    g <- grid_walk()
    p <- ggplot(g, aes(x = lon, y = lat, fill = status,
                       text = paste0("Walk to nearest shop: ", round(walk_min, 1), " min"))) +
      geom_tile() +
      scale_fill_manual(values = c("Served" = "#b08968", "Underserved" = "#e8d9a8")) +
      geom_point(data = landmarks, aes(x = lon, y = lat, text = landmark),
                 inherit.aes = FALSE, shape = 17, size = 3, color = "black") +
      coord_quickmap() +
      labs(title = paste0("Within a ", input$max_walk, "-minute walk of coffee?"),
           x = "Longitude", y = "Latitude", fill = "") +
      theme_minimal()

    if (input$show_shops) {
      p <- p + geom_point(data = shops_used(), aes(x = lon, y = lat, text = name),
                          inherit.aes = FALSE, size = 1, color = "#3d2314")
    }

    ggplotly(p, tooltip = "text")
  })

  output$summary_table <- renderTable({
    g <- grid_walk()
    tibble(
      metric = c("Shops counted", "Share of map within walking limit (%)",
                 "Average walk to nearest shop (min)", "Longest walk to nearest shop (min)"),
      value = c(
        nrow(shops_used()),
        round(100 * mean(g$status == "Served"), 1),
        round(mean(g$walk_min), 1),
        round(max(g$walk_min), 1)
      )
    )
  })

  output$landmark_table <- renderTable({
    landmark_walk() %>%
      select(Landmark = landmark, Type = type,
             `Walk (min)` = walk_min, Status = status) %>%
      arrange(desc(`Walk (min)`))
  })

  # --- "Show Code" text -----------------------------------------------------

  output$filter_code <- renderText({
    sprintf(
      "shops_used <- shops %%>%%\n  filter(rating >= %s, chain_type %%in%% c(%s))",
      input$min_rating,
      paste0('"', input$chains, '"', collapse = ", ")
    )
  })

  output$walk_code <- renderText({
    paste0(
      "# km to the nearest shop, then minutes at 5 km/h\n",
      "km <- map2_dbl(lon, lat, function(x, y) {\n",
      "  min(sqrt(((shops_used$lon - x) * cos(y * pi / 180) * 111.32)^2 +\n",
      "           ((shops_used$lat - y) * 110.57)^2))\n",
      "})\n",
      "walk_min <- km / 5 * 60\n",
      sprintf("status <- if_else(walk_min <= %d, \"Served\", \"Underserved\")", input$max_walk)
    )
  })

  output$plot_code <- renderText({
    'ggplot(grid_walk, aes(x = lon, y = lat, fill = status)) +\n  geom_tile() +\n  scale_fill_manual(values = c("Served" = "#b08968", "Underserved" = "#e8d9a8")) +\n  coord_quickmap() +\n  labs(title = "Within a walk of coffee?", x = "Longitude", y = "Latitude")'
  })
}

shinyApp(ui = ui, server = server)
