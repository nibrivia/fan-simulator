library(ggforce)
library(hrbrthemes)
library(r2d3)
library(shiny)
library(tidyverse)

pretty <- function(xs) {
  prettyNum(round(xs), big.mark = ",")
}

scale <- function(xs, min = 0, max = 1) {
  x_min <- min(xs)
  x_max <- max(xs)
  (xs - x_min) / (x_max-x_min)
}
shinyServer(function(input, output) {
  ### Variables =======================================
  refresh_rate <- reactive({
    input$fan_freq*2*100*pi*input$fan_size/input$tip_resolution
  })

  n_leds <- reactive({
    input$n_blades * input$fan_size * input$led_density
  })

  data_rate <- reactive({
    refresh_rate() * n_leds()
  })

  leds <- reactive({
    n_leds_per_blade <- input$fan_size*input$led_density

    expand.grid(blade = seq_len(input$n_blades),
                        led   = seq_len(n_leds_per_blade)) %>%
      as_tibble() %>%
      mutate(color = "#000000")
  })

  ### Info boxes =======================================
  output$tip_refresh_rate <- renderValueBox({
    valueBox(value = HTML(paste0(pretty(n_leds()), " leds", br(),
                                 "@", pretty(refresh_rate()), "Hz")),
             subtitle = "Refresh rate",
             color = "purple",
             width = 5)
  })

  output$full_data_rate <- renderValueBox({
    valueBox(value = HTML(paste("<div style='text-align: right;'>",
                                  pretty(data_rate()), "led/s", br(),
                                  pretty(data_rate()*24), "bits/s",
                                "</div>")),
             subtitle = "Data rate",
             color = "purple",
             width = 7)
  })

  ### Graphs & data =======================================
  led_df <- reactive({
    phase <- 0
    leds() %>%
      mutate(angle = blade/input$n_blades*2*pi + phase,
             x     = led*cos(angle)/(input$fan_size*input$led_density),
             y     = led*sin(angle)/(input$fan_size*input$led_density))
  })

  output$fan_plot <- renderPlot({
    print(log(1/max(led_df()$led)))
     led_df() %>%

      ggplot() +
      geom_arc(aes(x0 = 0, y0 = 0, r = led/(input$fan_size*input$led_density),
                   end = angle,
                   start = angle - 2*pi/input$pov_freq*input$fan_freq,
                   alpha = scale(stat(index)),#*log(1/led_df()$led),
                   color = factor(sort(led_df()$x))
                   )) +

      scale_alpha_identity() +
      scale_color_hue() +
      xlim(-1., 1.) +
      ylim(-1., 1.) +

      labs(title = NULL, x = NULL, y = NULL, color = NULL) +
      theme_ipsum_rc() +
      theme(axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            panel.grid  = element_blank(),
            legend.position = "none",
            plot.background  = element_rect(fill = "black"),
            panel.background = element_rect(fill = "black")

            ) +
      coord_equal()
  })

  output$fan_d3 <- renderD3({
    data <- led_df()
    r2d3(
      data = data,
      script = "fan.js"
    )
  })

})
