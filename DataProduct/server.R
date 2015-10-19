library(shiny);library(ggplot2)

shinyServer(function(input,output){
    subdata <- reactive({iris[iris$Species %in% input$species,]})
    theme <- reactive({eval(parse(text=input$theme))})
    
    output$irisModel <- renderTable({
        data <- subdata()
        reg <- lm(Sepal.Width~Petal.Width,data=data)
        as.data.frame(summary(reg)$coef)})
    output$irisPlot <- renderPlot({
        data <- subdata()
        theme <- theme()
        g <- ggplot(data,aes(x=Petal.Width,y=Sepal.Width))+
            geom_point(aes(color=Species),size=6,alpha=0.4)+
            stat_smooth(method="lm",se=TRUE)+
            xlab("Petal Width")+ylab("Sepal Width")+
            ggtitle("Linear Reg of iris - Sepal Width vs Petal Width")+
            theme
        print(g)
    })
})