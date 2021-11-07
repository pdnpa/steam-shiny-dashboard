# Shiny Web Application for the Peak District National Park
# Created by David Alexander

# Load packages ----
library(shiny)
library(knitr)
library(leaflet)
library(rgdal)
library(jsonlite)
library(markdown)
library(ggplot2)
library(dplyr)

# Load data ----
topoData <- readLines('./data/pdnp_poly.geojson') %>% paste(collapse = '\n')
pdnp <-  read.csv(file = './data/pdnp.csv')
pdnp_inf <-  read.csv(file = './data/pdnp_inf.csv')

# Graph for Key Measures Economic Impact
target<- c('Serviced Accommodation', 'Non-Serviced Accommodation', 'SFR', 'Staying Visitor', 'Day Visitor')
ei_g <- pdnp %>%
  select(Year, Measure, Sub.Measure, Total) %>%
  filter(Measure == 'Economic Impact') %>%
  filter(Sub.Measure %in% target)

# Source helper functions -----
source('map.R')

# This is the user interface logic ----
ui <- navbarPage('Tourism Dashboard',
                 # Front page including .md
                 tabPanel('Introduction',
                          includeMarkdown('intro.md'),
                          leafletOutput('pdnpmap'),
                          p(),
                 ),
                 tabPanel('Headlines',
                  # Define the sidebar with three inputs
                   sidebarPanel(
                     selectInput("selecter", label = h3("Visitor Type"), 
                                 choices = list("Serviced Accomodation", "Non-Serviced Accomodation",
                                               "SFR", "Staying Visitor", "Day Visitor"), 
                                 selected = "Serviced Accomodation"),
                     radioButtons('checkboxGroupa', label = h3('Reflect Pice Inflation?'),
                     choices = list("Yes" = 1, "No" = 2),
                     selected = 1),
                     radioButtons("checkGroup", label = h3("Boundary"), 
                                        choices = list("PDNP" = 1, "PDNP + IFA" = 2),
                                        selected = 1),
                     width = 2),
                  # Create a spot for the matrix of plots
                   mainPanel(
                     plotOutput(outputId = "ec_plot")
                   )
                 ),
                 tabPanel('Economy'),
                 navbarMenu('Visitors',
                            tabPanel('Visitor Numbers'),
                            tabPanel('Visitor Days')),
                 tabPanel('Employment'),
                 tabPanel('Accommodation'),
                 tabPanel('Sectoral Analysis'),
                 tabPanel('Annual Impact'),
                 tabPanel('Monthly Impact')
)



# This is the server logic ----
server <- function(input, output) {
  # Create MAP
  output$pdnpmap <- renderLeaflet({
    mymap
  })
  
  # Create a bar plot
  plot1 <- reactive(
    ei_g %>% 
      {if (input$selecter == "Serviced Accomodation") {.} 
        else {filter(., Sub.Measure == input$selecter)}} %>% 
      ggplot() +
      aes(Year, Total, fill = Sub.Measure) %>%
      geom_bar(stat = "identity", position = "dodge", fill="steelblue") +
      theme(axis.text.x = element_text(angle = 90))
  )
  output$ec_plot <- renderPlot({
    plot1() + ylim(0,600000) + theme(legend.position="bottom")
  })
  
}

# Run app ----
shinyApp(ui, server)