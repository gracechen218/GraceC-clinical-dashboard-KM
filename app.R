#------------------------------------------------------#
# Purpose: Create R shiny dashboard to create KM curve #
# Author:  Grace Chen                                  #
# Date:    5/5/2025                                    #
#------------------------------------------------------#


# Load library ------------------------------------------------------------

library(shiny)
library(ggplot2)
library(plotly)
library(survival)
library(viridis)
library(readxl)
library(haven)
library(vroom)
library(DT)
library(psych)
library(plotly)
library(broom)


# Set UI ------------------------------------------------------------------
ui <- fluidPage(
  navbarPage("User Interface:",
             
             # Tab 1 - Data
             tabPanel("Data",
                                        titlePanel("Select Input data"),
                                        sidebarLayout(
                                          sidebarPanel(
                                            fileInput("file1", "Choose Dataset/File",
                                                      multiple = TRUE,
                                                      accept = c("text/csv",
                                                                 "text/comma-separated-values,text/plain",
                                                                 ".csv"))
                                            ),
                                          mainPanel(
                                            verbatimTextOutput("summary"),
                                            #tableOutput("contents")
                                            dataTableOutput("contents")
                                          ))), 
             
             # Tab 2 - Plots
             tabPanel(
               "Plots",
               tabsetPanel(
                 tabPanel(
                   "KM Plot",
                   pageWithSidebar(
                     headerPanel(''),
                     sidebarPanel( selectInput("paramcd_filter", "Select PARAMCD:",
                                               choices = NULL, selected = NULL),
                                   uiOutput("variable_kanl"),
                                   uiOutput("variable_cnsr"),
                                   uiOutput("variable_bygrp")
                                   ),
                     mainPanel(plotlyOutput('plot4'),
                               br(),
                               h4("KM Estimates at Key Time Points"),
                               dataTableOutput("km_estimate_table")
                     )
                   )
                 )
               )
             ),
             
  ))



# Set Server --------------------------------------------------------------

server <- function(input, output, session) {
  onSessionEnded(stopApp)
  data <- reactive({
    req(input$file1)
    
     if(stringr::str_ends(input$file1$datapath, "csv")) {
      df <- read.csv(input$file1$datapath)
    } else if (stringr::str_ends(input$file1$datapath, "(xlsx|xls)")) {
      df <- read_excel(input$file1$datapath)
    } else if (stringr::str_ends(input$file1$datapath, "sas7bdat")) {
      df <- read_sas(input$file1$datapath)
    }
  })
  
  output$contents <- DT::renderDataTable(
    
      return(data())
  )
  

  output$summary <- renderPrint({
    #summary(data())
    str(as.data.frame(data()))
    #describe(data())
  })
  
  
  output$variable_kanl <- renderUI({
    selectInput("variableNames_kanl", label = "Analysis Variable", choices = names(data()))  
  })
  
  output$variable_cnsr <- renderUI({
    selectInput("variableNames_cnsr", label = "Censor Variable", choices = names(data()) ) 
  })
  
  output$variable_bygrp <- renderUI({
    selectInput("variableNames_bygrp", label = "By Group Variable", choices = names(data()))  
  })

  observe({
    req(data())
    updateSelectInput(session, "paramcd_filter",
                      choices = unique(data()[["PARAMCD"]]),
                      selected = unique(data()[["PARAMCD"]])[1])
  })

  survdat <- reactive({
    req(input$paramcd_filter, input$variableNames_kanl, input$variableNames_cnsr, input$variableNames_bygrp)
    
    df <- data()
    df <- df[df$PARAMCD == input$paramcd_filter, ]
    
    test <- data.frame(
      AVAL = df[[input$variableNames_kanl]],
      CNSR = df[[input$variableNames_cnsr]],
      BYGRP = df[[input$variableNames_bygrp]]
    )
    test
  })
  
  output$plot4 <- renderPlotly({
    req(data)
    
    # Fit survival model
    fit <- survfit(Surv(AVAL, CNSR) ~ BYGRP, data = survdat())
    
    # Tidy the survfit output
    surv_df <- broom::tidy(fit)
    
    # Plot with ggplot2
    p <- ggplot(surv_df, aes(x = time, y = estimate, color = strata, fill = strata)) +
      geom_step() +
      geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.2, color = NA) +
      labs(
        title = "KM Estimates of Overall Survival",
        x = "Day(s)",
        y = "Survival Probability",
        color = "Group",
        fill = "Group"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$km_estimate_table <- DT::renderDataTable({
    req(survdat())
    
    fit <- survfit(Surv(AVAL, CNSR) ~ BYGRP, data = survdat())
    
    # Time points (0, 30, 180 days)
    time_points <- c(0, 30, 180)
    
    # Summarize survival at those times
    summary_fit <- summary(fit, times = time_points)
    
    # Extract into table
    df_km <- data.frame(
      Time = summary_fit$time,
      Group = summary_fit$strata,
      Survival = round(summary_fit$surv, 3),
      Lower_CI = round(summary_fit$lower, 3),
      Upper_CI = round(summary_fit$upper, 3)
    )
    
    df_km
  })
  
  
}

shinyApp(ui, server)
