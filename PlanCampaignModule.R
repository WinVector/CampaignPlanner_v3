library('shiny')
library('ggplot2')
source("functions.R")


PlanCampaignUI_priors = function(id) {
  ns = NS(id)
  tagList(
      helpText("Each row below is a campaign.  For each campaign supply a plausible lower bound on the success rate and the value per success assumed for the campaign."),
      fluidRow(column(4, numericInput(ns("conv1a"), "Success Rate:", 0.5, min = 0, max = 1)),
               column(4, numericInput(ns("value1a"), "Success Value:", 1,  min=0, max=10000))
      ),
      fluidRow(column(4, numericInput(ns("conv2a"), "Success Rate:", 0.5, min = 0, max = 1)),
               column(4, numericInput(ns("value2a"), "Success Value:", 1,min=0, max=10000))
      )
    )
}


PlanCampaignUI_tolerances = function(id) {
  ns = NS(id)
  tagList(
    helpText("To what tolerance do you want to estimate the best campaign value?"),
    numericInput(ns("relErr"), "Relative Error:", 0.2, min=0, max=1),
    helpText("What is the maximum allowed probability of mis-estimating campaign value to more than the above tolerance?"),
    numericInput(ns("errorProb"), "Error Probability:", 0.05, min = 0, max = 1),
    helpText("What is the minimum number of successes you want to see before deciding the campaign value?"),
    numericInput(ns("countGoal"), "Count Goal", 5, min=0, max=1000000)
  )
}


PlanCampaignUI_suggestions = function(id) {
  ns = NS(id)
  tableOutput(ns("plan"))
}

PlanCampaignUI_setsizes = function(id) {
  ns = NS(id)
  tagList(
    helpText("Input the proposed campaign sizes. You can look above to the Suggested Campaign Sizes for values to try."),
    # giving up and hard-coding the campaign names
    numericInput(ns("sizes1a"), "Size of first campaign", 100, min=0, max=100000),
    numericInput(ns("sizes2a"), "Size of second campaign", 100, min=0, max=100000)
  )
}

PlanCampaignUI_plangraph = function(id) {
  ns = NS(id)
  tagList(
    p("This section shows the distribution of observed success frequencies/values for
      the user specified (unobserved) true campaign rates. This is the likely distribution of
      what would be seen during estimation if the two campaigns had rates as you specified earlier in the Campaign Priors section."),
    p("The plot gives you an idea of how often the campaign that is truly more valuable appears to be more valuable during measurement."),
    plotOutput(ns("planGraph"))
  )
}

PlanCampaignUI_posteriors = function(id) {
  ns=NS(id)
  tagList(
    p("The posterior probabilities that Campaign1 will appear more/less valuable than Campaign2,
              based on the results of the given campaign sizes. Probabilities may not add to one"),
   # verbatimTextOutput(ns("probTable"))
   infoBoxOutput(ns("posterior1")),
   infoBoxOutput(ns("posterior2"))
  )
}


# ---- server -----

PlanCampaign = function(input, output, session) {
  cprobabilities = reactive(c(input$conv1a, input$conv2a))
  values = reactive(c(input$value1a, input$value2a))
  sizes = reactive(c(input$sizes1a, input$sizes2a))
  proposedsizes = reactive(heuristicPowerPlan(data.frame(Probability=cprobabilities(),
                                                         ValueSuccess=values()),
                                              errorProbability=input$errorProb,relativeError=input$relErr))
  countGoalV <- reactive(input$countGoal)

  docalc = reactive(sum(sizes()) != 0)

  planTable = reactive(data.frame(Label=c('Campaign1','Campaign2'),
                                  Probability=cprobabilities(),
                                  ValueSuccess=values()))
  typicalTable = reactive(makeTypicalTable(planTable(), sizes(), input$reseed))
  pgraph2T = reactive(posteriorGraph(typicalTable()))
  output$planGraph2T = renderPlot(plotPosterior(pgraph2T()))
  output$probTable2T = renderPrint(computeProbsGEP(typicalTable(),pgraph2T()$graph))

  pgraph = reactive(sampleGraph(planTable(),sizes()))
  bgraph = reactive(computeProbsGES(planTable(),pgraph()))

  output$plan = renderTable(labeledPlan(proposedsizes(),cprobabilities(),values(),countGoalV()),digits=4)
  output$typicalTable = renderPrint(typicalTable()) # I'll render it verbatim, rather than as a table.
  # Saves me from having to worry about sig figs
  output$planGraph = renderPlot(displayGraph(pgraph(), docalc()))
  # output$probTable = renderPrint(bgraph())
  output$posterior1 = renderInfoBox(infoBox("P(C1 > C2)", paste(round(bgraph()$p1gt2 *100), "%"),
                                   icon = icon("arrow-up"), color="aqua"))
  output$posterior2 = renderInfoBox(infoBox("P(C1 < C2)", paste(round(bgraph()$p1lt2 *100), "%"),
                                           icon = icon("arrow-down"), color="aqua"))
}
