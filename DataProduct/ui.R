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
              selected=c("setosa","versicolor")),
          selectInput("theme","Select a ggplot2 theme:",
                      c("Gray" = "theme_gray()",
                        "Classic" = "theme_classic()",
                        "BW" = "theme_bw()",
                        "Light" = "theme_light()",
                        "Linedraw" = "theme_linedraw()",
                        "Minimal" = "theme_minimal()")),
          h3("Introduction"),
          p("This simple app fits a linear regression model of iris with a plot in ggplots"),
          h3("Usage"),
          p("1. Select 1 or more Species to subset the iris dataset."),
          p("2. choose a theme."),
          p("The regression model coef table as well as the plot will be updated automatically.")
      ),
      mainPanel(        # results
          strong("Coef. of Model Call:"),
          code("lm(Sepal.Width~Petal.Width)"),
          tableOutput("irisModel"),
          plotOutput("irisPlot")
      )
  )
))