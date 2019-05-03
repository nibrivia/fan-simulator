library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(
  skin = "purple",

  dashboardHeader(title = "Fan simulator"),

  dashboardSidebar(
    numericInput("led_density", "LEDS/m" ,
                min = 30, max = 200, step = 10, value = 30),
    p("LED density is low so that rendering is reasonably fast"),
    numericInput("n_blades", "# blades" ,
                min = 1, step = 1, value = 8),
    sliderInput("fan_size", "Fan size (m)",
                min = 0.1, max = 3, step = .1, value = 2.5),
    sliderInput("fan_freq", "Fan rotation frequency (Hz)",
                min = 0, max = 1, value = 1),
    sliderInput("tip_resolution", "Tip spatial resolution (cm)",
                min = 0.1, max = 10, value = 2),
    sliderInput("pov_freq", "Frequence of POV (Hz)",
                min = 1, max = 30, value = 10)

  ),

  dashboardBody(
    fluidRow(
      valueBoxOutput("tip_refresh_rate", width = 5),
      valueBoxOutput("full_data_rate",   width = 7)
    ),

    fluidRow(
      box(title = "Fan view (ggplot)",
          plotOutput("fan_plot", width = "100%", height = "800px"),
          width = 12, height = "800px")
    ),

    fluidRow(
      box(title = "Fan view (D3)",
          plotOutput("fan_plot", width = "100%", height = "800px"),
          width = 12, height = "800px")
    )

  )
))
