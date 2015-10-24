library(shiny);library(ggplot2)
shinyUI(fluidPage(
  titlePanel("Linear Regression Plot of Iris (Sepal.Width vs Petal.Width)",
             windowTitle="Iris - Sepal width vs Petal Width"),
  sidebarLayout(
      sidebarPanel(     # Config controls
          checkboxGroupInput("species","Select species:",
              c("Setosa" = "setosa",
                "Versicolor" = "versicolor",
                "Virginica" = "virginica"),
              selected=c("setosa","versicolor"),inline=TRUE),
          selectInput("theme","Select a ggplot2 theme:",
                      c("Gray" = "theme_gray()",
                        "Classic" = "theme_classic()",
                        "BW" = "theme_bw()",
                        "Light" = "theme_light()",
                        "Linedraw" = "theme_linedraw()",
                        "Minimal" = "theme_minimal()")),
          submitButton("Apply settings"),
          h4("Introduction"),
          p("This simple app fits a linear regression model of iris with a plot in ggplots"),
          h4("Usage"),
          p("1. Select one or more Species from the multi-checkbox to subset the iris dataset",
            "and/or choose a theme from the dropdown box."),
          p("2. Click 'Apply settings' button to see effects."),
          p("The regression model coef table as well as the plot in the main panel",
            "will be updated automatically.")
      ),
      mainPanel(        # results
          strong("Coef. of Model Call: "),
          code("lm(Sepal.Width~Petal.Width)"),
          p(" "),
          tableOutput("irisModel"),
          plotOutput("irisPlot")
      )
  )
))