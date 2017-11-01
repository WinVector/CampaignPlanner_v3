library(shinydashboard)
source("PlanCampaignModule.R")
source("EvaluateCampaignModule.R")

sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("Plan Campaign", tabName="planCampaign"),
    menuItem("Evaluate Campaign", tabName="evaluateCampaign")
  )

)

body = dashboardBody(
  HTML( "<p>
  For more information see the <a href='https://github.com/WinVector/CampaignPlanner/'>GitHub repository </a>.
        </p>"),

  tabItems(
    tabItem(tabName="planCampaign",titlePanel("Plan your A/B test campaign"),
            p("The purpose of this planning sheet is to use the user inputs -- prior bounds on conversion rate and conversion value --
              to estimate an acceptable absolute error in campaign value.  This acceptable error rate is used to pick campaign sizes
              that ensure the campaign
              chosen has a good probability of being close to the best choice in terms of relative error."),
            p("A good way to use this sheet is to enter two different rates you wish to be able to distinguish between."),

            fluidRow(
              column(width=6,
                     box(title="Enter Campaign Priors", solidHeader=TRUE, width=NULL, status="primary", PlanCampaignUI_priors("all"))
              ),
              column(width=6,
                     box(title="Enter Campaign Tolerances", solidHeader=TRUE, width=NULL,status="primary", PlanCampaignUI_tolerances("all"))
              )
            ),
            fluidRow(
              column(width=12,
                     box(title="Suggested Campaign Sizes", solidHeader=TRUE, width=NULL,status="info", PlanCampaignUI_suggestions("all"))
              )
            ),

            fluidRow(
              column(width=12,
                     box(title="Enter Campaign Sizes", solidHeader=TRUE, width=NULL,status="primary", PlanCampaignUI_setsizes("all"))
              )
            ),

            fluidRow(
              column(width=12,
                     box(title="Distribution of Possible Outcomes", width=NULL,solidHeader=TRUE, status="info", PlanCampaignUI_plangraph("all"))
              )
            ),
            fluidRow(
              column(width=12,
                     box(title="Posterior Probabilities", status="info", width=NULL,solidHeader=TRUE, PlanCampaignUI_posteriors("all"))
              )
            )

#             # this works
#             box(title="Enter Campaign Priors", solidHeader=TRUE, width=NULL, status="primary", PlanCampaignUI_priors("all")),
#             box(title="Enter Campaign Tolerances", solidHeader=TRUE, width=NULL,status="primary", PlanCampaignUI_tolerances("all")),
#             box(title="Suggested Campaign Sizes", solidHeader=TRUE, width=NULL,status="info", PlanCampaignUI_suggestions("all")),
#             box(title="Enter Campaign Sizes", solidHeader=TRUE, width=NULL,status="primary", PlanCampaignUI_setsizes("all")),
#             box(title="Posterior Probabilities", status="info", width=NULL,solidHeader=TRUE, PlanCampaignUI_posteriors("all")),
#             box(title="Distribution of Possible Outcomes", width=NULL,solidHeader=TRUE, status="info", PlanCampaignUI_plangraph("all"))


    ),
tabItem(tabName="evaluateCampaign",
        titlePanel("Evaluate an A/B test campaign"),
        p("The purpose of this evaluation sheet is to take results from a previously run campaign
              and estimate the likely unknown true values of the traffic sources."),

        box(title="Enter Campaign Results", solidHeader=TRUE, width=NULL,status="primary",
            EvaluateCampaignUI_results("all")),
        fluidRow(
          column(width=6,
                 box(title="What is your target value per action?",  solidHeader=TRUE, width=NULL,status="primary",
                     EvaluateCampaignUI_targetvalue("all"))
          ),
          column(width=6,
                 box(title="Scale Factor", solidHeader=TRUE, width=NULL,status="primary",
                     EvaluateCampaignUI_scale("all"))
          )
        ),
        box(title="Estimated Campaign Values", solidHeader=TRUE, width=NULL,status="info",
            EvaluateCampaignUI_planGraph("all")),
        box(width=NULL, EvaluateCampaignUI_resTable("all")),
        fluidRow(
          column(width=4,
                 box(width=NULL, background="aqua", "The posterior probability that Campaign1 is more valuable than Campaign2,
                         based on observed success rates and scaling factor:")
          ),
          column(width=4,  EvaluateCampaignUI_posterior("all")
          )
        )
)
  )
)

ui = dashboardPage(
  dashboardHeader(title = "A/B Testing Dashboard"),
  sidebar,
  body
)

server = function(input, output) {
  callModule(PlanCampaign, "all")
  callModule(EvaluateCampaign, "all")
}

# shinyApp(ui, server)
