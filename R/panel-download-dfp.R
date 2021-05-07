make_panel_dl_dfp <- function(size_pages, available_companies) {
  tabPanel("Download DFP Data",
           fluidPage(
             fluidRow(
               column(size_pages,
                      h3('Annual Financial Reports'),
                      p('Here you\'ll be able to download annual financial reports from the DFP system. ',
                        'Be aware that, this web interface only includes ', strong('active'), 
                        ' companies within B3. When using the R package, there is no such restriction.'),
                      hr())),
             
             fluidRow(
               column(size_pages,
                      selectInput('user_companies', label = 'Select available companies', 
                                  choices = c('All Companies', 
                                              available_companies), multiple=TRUE, selectize=TRUE, 
                                  selected = available_companies[1], width = '100%'),
                      textOutput('user_companies'))),
             br(),
             fluidRow(column(size_pages,
                             dateRangeInput("daterange1", "Select date range:",
                                            start = as.Date('2010-01-01'),
                                            end   = Sys.Date(),
                                            min = as.Date('2010-01-01'),
                                            startview = 'year'))
             ),
             br(),
             fluidRow(column(size_pages,
                             checkboxGroupInput("user_choice_type_docs", "Selected Financial Statements:",
                                                choiceNames =
                                                  list("BPA - Assets", 
                                                       "BPP - Liabilities",
                                                       "DRE - Income Statement",
                                                       "DFC_MD - cash flow by direct method",
                                                       "DFC_MI - cash flow by indirect method",
                                                       "DMPL - statement of changes in equity",
                                                       "DVA - value added report"),
                                                choiceValues = 
                                                  list("BPA", "BPP", "DRE", "DFC_MD", 
                                                       "DFC_MI", "DMPL", "DVA"), 
                                                selected = c("BPA", 'BPP', 'DRE')) )),
             br(),
             fluidRow(column(size_pages,
                             checkboxGroupInput("user_choice_type_format", "Type of Statements:",
                                                choiceNames =
                                                  list("Individual", 
                                                       "Consolidated"),
                                                choiceValues = 
                                                  list("con", "ind"), 
                                                selected = c("con", 'ind')) )),
             #br(),
             fluidRow(column(size_pages,
                             selectInput('format_output', label = 'Download format', 
                                         choices = c('Single Excel file (xlsx)', 
                                                     'Single Zipped file with data as csv', 
                                                     'Single RDS file (R native format)'),
                                         multiple=FALSE, selected = 'Single Zipped file with data as csv')) ),
             br(),
             fluidRow(column(2,
                             actionButton('actionid', 'Get Data!', icon = NULL, width = NULL)),
                      column(3, 
                             conditionalPanel("input.actionid != 0",
                                              verbatimTextOutput('text_action_id')))
             ),
             br(),
             fluidRow(column(size_pages, 
                             conditionalPanel("output.text_action_id =='DONE. Hit download..'",
                                              downloadButton("downloadData", 'Download')))),
             br(),
             fluidRow(column(size_pages, 
                             conditionalPanel("output.text_action_id =='DONE. Hit download..'",
                                              p('Your query can be replicated in R with the following script. Just copy it and execute in R: ')),
                             br(),
                             verbatimTextOutput('code_text'))) 
           ),
           
  )
}