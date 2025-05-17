library(shiny)
library(randomForest)
library(bslib)
library(shinydashboard)
library(leaflet)
library(DT)
library(ggplot2)
library(shinyjs)
library(caret)
library(corrplot)
library(randomForest)
library(rpart)
library(caret)
library(Metrics)
library(e1071)
library(readxl)
library(dplyr)
library(zoo)
library(corrplot)
library(pROC)
library(reticulate)
library(keras)
library(lubridate)
library(tidyverse)
library(ggplot2)
library(doParallel)
library(mlr)


setwd("C:/Users/-/OneDrive - University of Bolton/DAT703-RClass/Porfolio 3")

# Load the saved randomForest model
load("model_objects.RData")

#Define function for prediction
predict_house_price <- function(input_data) {
  names(input_data) <- names(X_train)
  new_data <- input_data[, names(pre_proc$mean)]
  new_data_scaled <- predict(pre_proc, input_data)
  predicted_log_price <- predict(final_model, newdata = new_data_scaled)
  predicted_price <- exp(predicted_log_price)
  return(round(predicted_price, 2))
}

housing_data <- read.csv("housing_data-DESKTOP-MI1L3S5.csv")
View(housing_data)

# Define UI
ui <- tagList(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$script(src = "script.js")
  ),
  
  # Dynamic UI based on login state
  uiOutput("page")
)

# Define Server Logic
server <- function(input, output, session) {
  #####MAP of REgion
  
  # Define the bounding coordinates of the region
  lat_min <- 25.88728052
  lat_max <- 25.97438187
  lon_min <- -80.18366859
  lon_max <- -80.11974639
  
  # Render the map with leaflet
  output$region_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = (lon_min + lon_max) / 2, lat = (lat_min + lat_max) / 2, zoom = 13) %>%
      addRectangles(
        lng1 = lon_min, lat1 = lat_min, lng2 = lon_max, lat2 = lat_max,
        color = "blue", weight = 2, opacity = 0.5, fillColor = "blue", fillOpacity = 0.2
      )
  })
  
  
  
  output$total_houses <- renderValueBox({
    valueBox(
      value = formatC(nrow(housing_data), format = "f", digits = 2, big.mark = ","),
      subtitle = "Total Houses Available",
      icon = icon("home"),
      color = "blue"
    )
  })
  
  # Render the value boxes
  output$max_price <- renderValueBox({
    valueBox(
      value = paste0("£", formatC(max_price(), format = "f", digits = 2, big.mark = ",")),
      subtitle = "Maximum Sale Price",
      icon = icon("arrow-up"),
      color = "green"
    )
  })
  
  # Define reactive expressions to calculate max and min prices from the housing dataset
  max_price <- reactive({
    max(housing_data$SALE_PRC, na.rm = TRUE)
  })
  
  min_price <- reactive({
    min(housing_data$SALE_PRC, na.rm = TRUE)
  })
  
  output$min_price <- renderValueBox({
    valueBox(
      value = paste0("£", formatC(min_price(), format = "f", digits = 2, big.mark = ",")),
      subtitle = "Minimum Sale Price",
      icon = icon("arrow-down"),
      color = "red"
    )
  })
  
  
  output$total_clients <- renderValueBox({
    valueBox(
      value = formatC(floor(nrow(housing_data) / 3), format = "f", digits = 2, big.mark = ","),
      subtitle = "Clients Served",
      icon = icon("users"),
      color = "orange"
    )
  })
  
  output$houses_sold <- renderValueBox({
    valueBox(
      value = formatC(floor(nrow(housing_data) / 2), format = "f", digits = 2, big.mark = ","),
      subtitle = "Houses Sold",
      icon = icon("check-circle"),
      color = "purple"
    )
  })
  
  output$countries <- renderValueBox({
    valueBox(
      value = formatC(12, format = "f", digits = 2, big.mark = ","),
      subtitle = "Countries We Cover",
      icon = icon("globe"),
      color = "teal"
    )
  })
  
  
  
  
  # Reactive value to track login state
  logged_in <- reactiveVal(FALSE)
  
  # Render the appropriate page based on login state
  output$page <- renderUI({
    if (logged_in()) {
      # Admin Dashboard with Sidebar
      dashboardUI()
    } else {
      # Login Page (without Sidebar)
      loginUI()
    }
  })
  
  # Login Page UI (without Sidebar)
  loginUI <- function() {
    tagList(
      div(class = "login-page",
          div(class = "login-form",
              h2("Login"),
              textInput("username", "Username", placeholder = "Enter username"),
              passwordInput("password", "Password", placeholder = "Enter password"),
              actionButton("login", "Login", class = "btn btn-primary"),
              tags$p(class = "login-error", uiOutput("login_error"))
          )
      ),
      tags$footer(class = "footer mt-4",
                  p(paste0("© ", format(Sys.Date(), "%Y"), " Real Estate Admin Dashboard. All rights reserved."))
      )
    )
  }
  
  # Admin Dashboard UI (with Sidebar)
  dashboardUI <- function() {
    dashboardPage(
      dashboardHeader(title = "Real Estate Admin"),
      
      dashboardSidebar(
        sidebarMenu(
          menuItem("Home", tabName = "home", icon = icon("home")),
          menuItem("Prediction", tabName = "predict", icon = icon("building")),
          menuItem("Houses", tabName = "houses", icon = icon("building")),
          menuItem("Profile", tabName = "profile", icon = icon("user")),
          menuItem("Settings", tabName = "settings", icon = icon("cogs")),
          menuItem("Logout", icon = icon("sign-out-alt"),
                   onclick = "Shiny.setInputValue('logout', true, {priority: 'event'});")
        )
      ),
      
      dashboardBody(
        tabItems(
          tabItem(
            tabName = "home",
            h2("Welcome to the Admin Dashboard"),
            
            # First row (2 cards)
            fluidRow(
              valueBoxOutput("total_houses", width = 6),
              valueBoxOutput("houses_sold", width = 6)
            ), 
            
            # Second row (2 cards)
            fluidRow(
              valueBoxOutput("total_clients", width = 6),
              valueBoxOutput("max_price", width = 6)
            ),
            
            # Third row (2 cards)
            fluidRow(
              valueBoxOutput("min_price", width = 6),
              valueBoxOutput("countries", width = 6)
            ),
            
            # Fourth row: Displaying the map
            fluidRow(
              # Map of the region (using leaflet to render the map)
              box(
                title = "Region Map", status = "primary", solidHeader = TRUE, width = 12,
                leafletOutput("region_map", height = 500)
              )
            )
          ),
          tabItem(
            tabName = "predict",
            h2("Prediction"),
            
            # Wrapper div for the form styling
            div(id = "predict-form",
                fluidRow(
                  column(
                    width = 6,  # This makes the form occupy half the width
                    offset = 3,  # This centers the form horizontally
                    box(
                      title = "Input Parameters", 
                      status = "primary", 
                      solidHeader = TRUE,
                      width = NULL,
                      
                      # First row of inputs (2 per row)
                      fluidRow(
                        column(6, textInput("LND_SQFOOT", "Land Area (Square Feet)", value = "", placeholder = "0")),
                        column(6, textInput("TOT_LVG_AREA", "Total Living Area (Square Feet)", value = "", placeholder = "0"))
                      ),
                      
                      fluidRow(
                        column(6, textInput("SPEC_FEAT_VAL", "Special Feature Value", value = "", placeholder = "0")),
                        column(6, textInput("RAIL_DIST", "Distance to Nearest Rail", value = "", placeholder = "0"))
                      ),
                      
                      fluidRow(
                        column(6, textInput("OCEAN_DIST", "Distance to Ocean", value = "", placeholder = "0")),
                        column(6, textInput("WATER_DIST", "Distance to Water Body", value = "", placeholder = "0"))
                      ),
                      
                      fluidRow(
                        column(6, textInput("CNTR_DIST", "Distance to City Center", value = "", placeholder = "0")),
                        column(6, textInput("SUBCNTR_DI", "Distance to Sub-Center", value = "", placeholder = "0"))
                      ),
                      
                      fluidRow(
                        column(6, textInput("HWY_DIST", "Distance to Highway", value = "", placeholder = "0")),
                        column(6, textInput("age", "Age of Property", value = "", placeholder = "0"))
                      ),
                      
                      fluidRow(
                        column(6, textInput("structure_quality", "Structure Quality Rating (1-10)", value = "", placeholder = "0"))
                      ),
                      
                      # Predict button (spanning full width of the form)
                      actionButton("predict", "Predict Price", icon = icon("check"), width = "100%")
                    )
                  )
                )
            )
            ),
          tabItem(
            tabName = "houses",
            h2("Houses"),
            
            # Search bar and button in the same row, aligned to the top-right corner
            fluidRow(
              column(12,
                     # Wrapping div for the search bar and button to align them
                     div(
                       style = "display: flex; justify-content: flex-end; align-items: center; gap: 20px; margin-bottom: 20px;",  # Flexbox with space between
                       
                       # Global search input field with placeholder text
                       tags$div(
                         style = "display: flex; align-items: center;",  # Ensure vertical alignment
                         uiOutput("global_search_ui")
                       ),
                       
                       # "Add New House" button
                       actionButton("add_house", "Add New House", class = "btn btn-primary",
                                    style = "height: 38px; padding-top: 7px;"),  # Adjust height and padding
                       actionButton("delete_row", "Delete Selected Row", icon = icon("trash"), class = "btn-danger"),
                       br(), br(),
                     )
              )
            ),
            
            # Table for displaying house data below the search bar and button
            fluidRow(
              column(12,
                     DTOutput("houses_table")  # Table for displaying house data
              )
            )
          ),
          tabItem(tabName = "profile", h2("Your Profile")),
          tabItem(tabName = "settings", h2("Settings"))
        )
      )
    )
  }
  
  # Handle login logic
  observeEvent(input$login, {
    if (input$username == "admin" && input$password == "password") {
      logged_in(TRUE)  # Set login state to TRUE
    } else {
      output$login_error <- renderUI({
        "Invalid username or password"
      })
    }
  })
  
  # Handle logout logic
  observeEvent(input$logout, {
    logged_in(FALSE)  # Reset login state to FALSE when logout is clicked
  })
 
  ###Prediction Logic
  observeEvent(input$predict, {
    input_data <- data.frame(
      LND_SQFOOT = as.numeric(input$LND_SQFOOT),
      TOT_LVG_AREA = as.numeric(input$TOT_LVG_AREA),
      SPEC_FEAT_VAL = as.numeric(input$SPEC_FEAT_VAL),
      RAIL_DIST = as.numeric(input$RAIL_DIST),
      OCEAN_DIST = as.numeric(input$OCEAN_DIST),
      WATER_DIST = as.numeric(input$WATER_DIST),
      CNTR_DIST = as.numeric(input$CNTR_DIST),
      SUBCNTR_DI = as.numeric(input$SUBCNTR_DI),
      HWY_DIST = as.numeric(input$HWY_DIST),
      age = as.numeric(input$age),
      structure_quality = as.numeric(input$structure_quality)
    )
    
    # Check for NA inputs
    if (any(is.na(input_data))) {
      showModal(modalDialog(
        title = "Missing Input",
        "Please fill in all input fields correctly.",
        easyClose = TRUE,
        footer = modalButton("Close")
      ))
      return(NULL)
    }
    
    #se your prediction function
    predicted_price <- predict_house_price(input_data)
    
    # Format result
    formatted_price <- paste0("£", formatC(predicted_price, format = "f", digits = 2, big.mark = ","))
    
    # Show result
    showModal(modalDialog(
      title = tags$h3("Predicted Price", style = "font-weight: bold; text-align: center;"),
      tags$h4(formatted_price, style = "font-weight: bold; font-size: 1.5em; text-align: center; color: #007bff;"),
      easyClose = TRUE,
      footer = modalButton("Close")
    ))
  })
  
   ### HOUSE PAGE SERVER LOGIC #####################
  
  # Render the table of houses with global search feature enabled for SALE_PRC column only
  # Render the table initially with all data
  output$houses_table <- renderDT({
    datatable(
      housing_data,
      editable = TRUE,
      options = list(
        pageLength = 10,
        searching = FALSE,  # Enable DataTables' built-in search for the initial load
        dom = 'lfrtip'     # Ensure layout includes the search field
      )
    ) %>%
      formatCurrency('SALE_PRC', digits = 2)  # Format SALE_PRC as currency
  })
  
    # Observer for the global search input
  observeEvent(input$global_search, {
    search_value <- input$global_search
    
    # Convert the search value to numeric, handling any non-numeric input gracefully
    search_value_numeric <- as.numeric(search_value)
    
    # If the search value is empty or not numeric, show all data
    filtered_data <- if (is.na(search_value_numeric) || search_value == "") {
      housing_data  # No filter if search input is empty or invalid
    } else {
      # Filter using exact match on SALE_PRC (rounded to 2 decimal places)
      filtered_data <- housing_data[round(housing_data$SALE_PRC, 2) == round(search_value_numeric, 2), ]
    }
    
    # Render the filtered data
    output$houses_table <- renderDT({
      datatable(
        filtered_data,
        editable = TRUE,
        options = list(
          pageLength = 10,
          searching = FALSE,  # Disable DataTables' built-in search after global search
          dom = 'lfrtip',
          responsive = TRUE
        )
      ) %>%
        formatCurrency('SALE_PRC', digits = 2)  # Format SALE_PRC as currency
    })
  })
  
  output$global_search_ui <- renderUI({
    textInput("global_search", label = NULL, placeholder = "Search by Price")
  })
  
  # Show modal for adding new house
  observeEvent(input$add_house, {
    showModal(modalDialog(
      title = "Add New House",
      easyClose = TRUE,
      footer = tagList(
        modalButton("Close"),
        actionButton("save_house", "Save House", class = "btn btn-success")
      ),
      
      # Grid wrapper div for all inputs (12 fields, 2 per row)
      div(class = "modal-grid",  # This div class will use the grid styling
          fluidRow(
            column(6, numericInput("TOT_LVG_AREA", "Total Living Area (Square Feet)", value = 0, min = 0)),
            column(6, numericInput("SPEC_FEAT_VAL", "Special Feature Value", value = 0, min = 0))
          ),
          
          fluidRow(
            column(6, numericInput("structure_quality", "Structure Quality Rating (1-10)", value = 5, min = 1, max = 10)),
            column(6, numericInput("SUBCNTR_DI", "Distance to Sub-Center", value = 0, min = 0))
          ),
          
          fluidRow(
            column(6, numericInput("LND_SQFOOT", "Land Area (Square Feet)", value = 0, min = 0)),
            column(6, numericInput("OCEAN_DIST", "Distance to Ocean", value = 0, min = 0))
          ),
          
          fluidRow(
            column(6, numericInput("CNTR_DIST", "Distance to City Center", value = 0, min = 0)),
            column(6, numericInput("HWY_DIST", "Distance to Highway", value = 0, min = 0))
          ),
          
          fluidRow(
            column(6, numericInput("WATER_DIST", "Distance to Water Body", value = 0, min = 0)),
            column(6, numericInput("age", "Age of Property (Years)", value = 0, min = 0))
          ),
          
          fluidRow(
            column(6, numericInput("RAIL_DIST", "Distance to Nearest Rail", value = 0, min = 0)),
            column(6, numericInput("SALE_PRC", "Sale Price", value = 0, min = 0))
          )
      )
    ))
  })
  
  # Save the new house data
  observeEvent(input$save_house, {
    new_house <- data.frame(
      TOT_LVG_AREA = input$TOT_LVG_AREA,
      SPEC_FEAT_VAL = input$SPEC_FEAT_VAL,
      structure_quality = input$structure_quality,
      SUBCNTR_DI = input$SUBCNTR_DI,
      LND_SQFOOT = input$LND_SQFOOT,
      OCEAN_DIST = input$OCEAN_DIST,
      CNTR_DIST = input$CNTR_DIST,
      HWY_DIST = input$HWY_DIST,
      WATER_DIST = input$WATER_DIST,
      age = input$age,
      RAIL_DIST = input$RAIL_DIST,
      SALE_PRC = input$SALE_PRC
    )
    
    # Append new data to housing_data
    housing_data <<- rbind(housing_data, new_house)
    
    # Save updated dataset to CSV
    write.csv(housing_data, "C:/Users/-/OneDrive - University of Bolton/DAT703-RClass/Porfolio 3/housing_data.csv", row.names = FALSE)
    
    # Update the table with new data
    output$houses_table <- renderDT({
      datatable(housing_data, editable = TRUE, options = list(pageLength = 10))
    })
    
    # Close the modal
    removeModal()
    
    # Show success message
    showModal(modalDialog(
      title = "Success",
      "House added successfully!",
      easyClose = TRUE,
      footer = modalButton("Close")
    ))
  })
  
  
  # Edit a row from the table (if a cell is modified)
  observeEvent(input$houses_table_cell_edit, {
    info <- input$houses_table_cell_edit
    modified_data <- housing_data
    modified_data[info$row, info$col] <- info$value
    housing_data <<- modified_data
    
    # Save updated dataset to CSV
    write.csv(housing_data, "C:/Users/-/OneDrive - University of Bolton/DAT703-RClass/Porfolio 3/housing_data.csv", row.names = FALSE)
    
    # Update the table
    output$houses_table <- renderDT({
      datatable(housing_data, editable = TRUE, options = list(pageLength = 10))
    })
  })
  
  # Delete a row from the dataset (if a row is selected and deleted)
  observeEvent(input$delete_row, {
    selected_row <- input$houses_table_rows_selected
    if (length(selected_row) > 0) {
      housing_data <<- housing_data[-selected_row, ]
      
      # Save updated dataset to CSV
      write.csv(housing_data, "C:/Users/-/OneDrive - University of Bolton/DAT703-RClass/Porfolio 3/housing_data.csv", row.names = FALSE)
      
      # Update the table
      output$houses_table <- renderDT({
        datatable(housing_data, editable = TRUE, selection = "single", options = list(pageLength = 10))
      })
    }
  })
  
  
  
  
  
  
  ###END
  }

# Run the Shiny app
shinyApp(ui = ui, server = server)
