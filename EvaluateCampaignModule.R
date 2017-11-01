library('shiny')
library('ggplot2')
source("functions.R")



EvaluateCampaignUI_results = function(id) {
  ns = NS(id)
  tagList( helpText("Enter the campaign results: size (number of trials/actions), number of successes and value of each success."),
           fluidRow(
             column(4,
                    numericInput(ns("actions1b"), "Actions   ", 100, min=0, max=100000)),
             column(4,
                    numericInput(ns("success1b"), "Successes", 1, min = 0, max = 100000)),
             column(4,
                    numericInput(ns("value1b"), "Success Value:", 1, min=0, max=10000))
           ), #end fluidRow
           fluidRow(
             column(4,
                    numericInput(ns("actions2b"), "Actions   ", 100, min=0, max=100000)),
             column(4,
                    numericInput(ns("success2b"), "Successes", 1, min = 0, max = 100000)),
             column(4,
                    numericInput(ns("value2b"), "Success Value:", 1, min=0, max=10000))
           ) #end fluidRow
  )
}

EvaluateCampaignUI_targetvalue = function(id) {
  ns=NS(id)
  numericInput(ns("wishPrice"), "Target Value per Action", 0.05,
               min=0, max=100000)
}

EvaluateCampaignUI_scale = function(id) {
  ns=NS(id)
  tagList(
    numericInput(ns("rescale"), "Scale Factor", 1,
                 min=0, max=100000),
    helpText("Scale Factor > 1 lets you see what a larger campaign with the same observed rates could look like.")
  )
}

EvaluateCampaignUI_planGraph = function(id) {
  ns=NS(id)
  tagList(
    p("Based on the observed results, we can estimate the posterior distributions of the value per action of each campaign.
          The heavily shaded region of the graph represents the probability that each campaign exceeds the target value-per-action."),
    plotOutput(ns("planGraph2"))
  )
}

EvaluateCampaignUI_resTable = function(id) {
  ns=NS(id)
  verbatimTextOutput(ns("resTable"))
}


EvaluateCampaignUI_posterior = function(id) {
  ns=NS(id)
  valueBoxOutput(ns("posterior"), width=NULL)

}

EvaluateCampaign = function(input, output, session) {
  actions = reactive(c(input$actions1b, input$actions2b))
  successes = reactive(c(input$success1b, input$success2b))
  svalues = reactive(c(input$value1b, input$value2b))

  resTable = reactive(assembleResultTable(round(input$rescale*actions()),
                                          round(input$rescale*successes()),
                                          svalues(),
                                          input$wishPrice))
  pgraph2 = reactive(posteriorGraph(resTable()))
  probTable2 = reactive(computeProbsGEP(resTable(),pgraph2()$graph))

  output$resTable = renderPrint(resTable()[,c("Label", "observedSuccessRate", "observedValuePerAction", "pAboveTargetValue")])
  output$planGraph2 = renderPlot(plotPosterior(pgraph2(),input$wishPrice))
 # output$probTable2 = renderPrint(computeProbsGEP(resTable(),pgraph2()$graph))

#   output$posterior = renderInfoBox(infoBox("P(C1 < C2)",
#                                            paste(round(probTable2()$p1Greater2 *100), "%"),
#                                             icon = icon("arrow-up"), color="aqua"))
  output$posterior = renderValueBox(valueBox(
                                           paste(round(probTable2()$p1Greater2 *100), "%"),
                                           "P(C1 < C2)",
                                           icon = icon("arrow-up"), color="aqua"))

}
