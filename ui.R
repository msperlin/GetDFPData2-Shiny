# SERVER SIDE NOTES
# * ALWAYS install pkgs as sudo ($ sudo R -> install.packages(..)), including git pkgs
# * all cache files goes in /home/shiny/gdfpd2-cache

# increase memory for java
options(java.parameters = "-Xmx1000m")

library(shiny)
library(stringr)
library(writexl)
library(shinyjs)
library(shinythemes)

my.f <- list.files('fcts', full.names = T)
sapply(my.f, source)

my_app_cache_folder <<- '~/gdfpd2-cache'
df_info_companies <- GetDFPData2::get_info_companies(cache_folder = my_app_cache_folder)
donation_file <<- 'data/donations_2021-03-05.rds'
size_pages <- 6
max_companies <- NULL # not used
base_file_name <<- paste0('gdfd2_Export_', 
                          format(Sys.time(), '%Y%m%d-%H%M%S'))
first_date <- as.Date('2010-01-01')

# filter for available companies
idx <- df_info_companies$SIT_REG == 'ATIVO'
df_info_companies <- df_info_companies[idx, ]

available_companies <- sort(unique(df_info_companies$DENOM_SOCIAL))

# clean dir out
#my_f <- list.files('DataOut/', full.names = T)
#file.remove(my_f)

#saveRDS(object = df.info, file = 'temp/dfinfo.rds')
#saveRDS(object = df_info_companies, file = 'temp/dfinfo_companies.rds')
# source components

shinyUI(fluidPage(#shinythemes::themeSelector(),
  navbarPage("GetDFPData2 Web",
             theme = shinytheme("united"),
             
             #position = 'fixed-top',
             fluid=TRUE,
             tabPanel('Introduction',
                      position = 'center',
                      fluidPage(shinyjs::useShinyjs(),
                                tags$head(includeScript("GAnalytics/google-analytics.js"),
                                          includeCSS('css/my_css.css')
                                ),
                                titlePanel(title = ' ', windowTitle = 'GetDFPData2 - Web'),
                                fluidRow(
                                  column(size_pages,
                                         h3('Welcome!'),
                                         p('GetDFPData2 is the second iteration of GetDFPData, an academic project to provide free and unrestricted access to corporate datasets from B3, the Brazilian financial exchange.',
                                           'GetDFPData2 is released as an R package available in github (soon in CRAN). You can find more details about the project in ', 
                                           ' its ', a('academic paper', href = 'http://bibliotecadigital.fgv.br/ojs/index.php/rbfin/article/view/78654'), 
                                           ' and ', a('Github page.', href = 'https://github.com/msperlin/GetDFPData2'), 
                                           ' The code for this shiny app is also available in ', a('Github', href = 'https://github.com/msperlin/GetDFPData2-Shiny')),  
                                         p("In this site you'll be able to use the same code to download financial information from the exchange with a web interface",
                                           'of package GetDFPData2. ',
                                           'Be aware that command line version offers far more functionality.'),
                                         
                                         br(),
                                         h3('Support the project!'),
                                         p("This web interface is written in shiny and hosted in a DigitalOcean server with a 10 USD per month overhead.",
                                           " The GetDFPData project has no formal financial support and, ",
                                           "so far, I've been paying it myself, with the proceeds of my ", 
                                           a('books', href='https://www.msperlin.com/blog/publication/#5'), ".",
                                           " If you're using the shiny interface, please help us keeping the project alive."),
                                         p('All we need is to cover the costs of the server. If you can, please make one-time or continuous donation.',
                                           'All supporters will be featured anonymously in the Supporters tab.'),
                                         HTML(paste0(readLines('html_components/paypal.html'), collapse = '\n')),
                                         br(),
                                         h3('Instructions:'),
                                         p('Tab ', strong('Info about companies'), ' offers several details about companies.',
                                           ' This includes official names, cnpj, cvm id, and much more.',
                                           ' You can also download the table to your computer as csv or xlsx',
                                           ' Notice that a search box is available at top right of displayed table. You can use it for finding details about a particular company.'),
                                         p('Tab ', strong("Download DFP Data"), ' is the main application. In order to use it, select your companies, ',
                                           'date range, type of output and press ', strong("Get Data"), '. ',
                                           'After the server imports the data from the internet and cleans it, a ', strong("Download"), ' button should appear, with a link ',
                                           'to an Excel, csv or rds file.'),
                                         br(),
                                         h3('Access to Compiled Datasets'),
                                         p('Recently I released the full, up to date, datasets for all R projects, including GetDFPData2 and GetFREData. ',
                                           'More details in this ', a('blog post.', href = 'https://www.msperlin.com/blog/post/2020-04-20-free-compiled-data-in-site/')),
                                         p('If youre using it for research, please cite the original source using dataverse (details at blog post).'),
                                         br(),
                                         h3('Bug reports'),
                                         p('The package is in constant development. ',
                                           'If you have found an error or bug, please use ', a('Github', href = 'https://github.com/msperlin/GetDFPData2/issues'),
                                           " to report it. I'll look into as soon as I can. If you don't have a github account, just drop me an email (marceloperlin@gmail.com)."),
                                         br(),
                                         h3('Citation'),
                                         p('If you have used the data for scientific research, please cite the data source as:'),
                                         br(),
                                         p('Perlin, M. S., Kirch, G., & Vancin, D. (2019). Accessing financial reports and corporate events with GetDFPData. Revista Brasileira de Finanças, 17(3).'),
                                         br(),
                                         h3('Maintainer'),
                                         p(a('Marcelo S. Perlin', href = 'https://www.msperlin.com/blog/' ), '/ EA - UFRGS (marceloperlin@gmail.com)'),
                                         img(src='logo_ufrgs.png', align = "left", width="100", height="100"),
                                         img(src='logo_ea.png', align = "left", width="100", height="100")
                                  )
                                )
                      )
             ),
             tabPanel('Info companies',
                      fluidPage(
                        fluidRow(
                          column(size_pages,
                                 p('This web interface only includes **active** companies with stocks listed in B3.',
                                   'The full list can be dowloaded from R session with the following code ',
                                   '(open a new R script in RStudio, copy and paste all code, execute with control+shift+enter)'),
                                 br(),
                                 div(id='myDiv', class='code-div',
                                     code('if (!require(devtools)) install.packages("devtools")'),
                                     br(),
                                     code('if (!require(GetDFPData2)) devtools::install_github("msperlin/GetDFPData2")'),
                                     br(),
                                     br(),
                                     code('library(GetDFPData2)'),
                                     br(),
                                     code('df_info <- get_info_companies()'),
                                     br(),
                                     code('print(df_info)')
                                 ),
                                 br(),
                                 br(),
                                 
                                 p('Alternatively, you can download the **complete table** in two formats:'))),
                        br(),
                        fluidRow(column(size_pages,
                                        downloadButton("downloadDfInfo_csv", 'Download as csv'),
                                        br(),
                                        br(),
                                        downloadButton("downloadDfInfo_xlsx", 'Download as xlsx')))),
                      br(),
                      fluidRow(column(size_pages,
                                      h4('Information Table'),
                                      dataTableOutput('table')))
             ),
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
                                                       start = first_date,
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
                      
             ),
             
             # tabPanel('Download ITR Data',
             #          fluidPage(fluidRow(column(size_pages,
             #                                    h3('Quarterly  Financial Reports'),
             #                                    p('Here you\'ll be able to download quarterly financial reports from the DFP system. ',
             #                                      'Be aware that, this web interface only includes ', strong('active'),
             #                                      ' companies within B3. When using the R package, there is no such restriction.'),
             #                                    p('After executing your query, a block of R code will appear, helping you using the R package in a R session.'),
             #                                    hr())),
             #                    fluidRow(column(size_pages,
             #                                    selectInput('user_companies_itr', label = 'Select available companies',
             #                                                choices = c('All Companies',
             #                                                            available_companies), multiple=TRUE, selectize=TRUE,
             #                                                selected = available_companies[1], width = '100%')#,
             #                                    #textOutput('user_companies_itr')
             #                    )
             #                    ),
             #                    br(),
             #                    fluidRow(column(size_pages,
             #                                    dateRangeInput("daterange_itr", "Select date range:",
             #                                                   start = first_date,
             #                                                   end   = Sys.Date(),
             #                                                   min = as.Date('2010-01-01'),
             #                                                   startview = 'year'))
             #                    ),
             #                    br(),
             #                    fluidRow(column(size_pages,
             #                                    checkboxGroupInput("user_choice_type_docs_itr", "Selected Financial Statements:",
             #                                                       choiceNames =
             #                                                         list("BPA - Assets",
             #                                                              "BPP - Liabilities",
             #                                                              "DRE - Income Statement",
             #                                                              "DFC_MD - cash flow by direct method",
             #                                                              "DFC_MI - cash flow by indirect method",
             #                                                              "DMPL - statement of changes in equity",
             #                                                              "DVA - value added report"),
             #                                                       choiceValues =
             #                                                         list("BPA", "BPP", "DRE", "DFC_MD",
             #                                                              "DFC_MI", "DMPL", "DVA"),
             #                                                       selected = c("BPA", 'BPP', 'DRE')) )),
             #                    br(),
             #                    fluidRow(column(size_pages,
             #                                    checkboxGroupInput("user_choice_type_format_itr", "Type of Statements:",
             #                                                       choiceNames =
             #                                                         list("Individual",
             #                                                              "Consolidated"),
             #                                                       choiceValues =
             #                                                         list("con", "ind"),
             #                                                       selected = c("con", 'ind')) )),
             #                    #br(),
             #                    fluidRow(column(size_pages,
             #                                    selectInput('format_output_itr', label = 'Download format',
             #                                                choices = c('Single Excel file (xlsx)',
             #                                                            'Single Zipped file with data as csv',
             #                                                            'Single RDS file (R native format)'),
             #                                                multiple=FALSE, selected = 'Single Zipped file with data as csv')) ),
             #                    br(),
             #                    fluidRow(column(2,
             #                                    actionButton('actionid_itr', 'Get Data!', icon = NULL, width = NULL)),
             #                             column(3,
             #                                    conditionalPanel("input.actionid_itr != 0",
             #                                                     verbatimTextOutput('text_action_id_itr')))
             #                    ),
             #                    br(),
             #                    fluidRow(column(size_pages,
             #                                    conditionalPanel("output.text_action_id_itr =='DONE. Hit download..'",
             #                                                     downloadButton("downloadData", 'Download')))),
             #                    br(),
             #                    fluidRow(column(size_pages,
             #                                    conditionalPanel("output.text_action_id_itr =='DONE. Hit download..'",
             #                                                     p('Your query can be replicated in R with the following script. Just copy it and execute in R: ')),
             #                                    br(),
             #                                    verbatimTextOutput('code_text'))),
             #          ),
             #),
             tabPanel('Download FRE Data',
                      fluidPage(column(size_pages,
                                       h4('Not Available..'),
                                       p('FRE data is sparse and demands a heavy download for every user query as every pair of company/year is a 15 to 20 MB download.',
                                         'Despite my efforts, the server simply can\'t handle a live query from GetFREData. ',
                                         'As a alternative, you can download parsed FRE data from 2010 in my ',
                                         a('dataverse library', href = 'https://dataverse.harvard.edu/dataverse/msperlin'), 
                                         '. Or, if you like some coding, simply use function get_fre_data from package ', 
                                         a('GetFREData', href = 'https://github.com/msperlin/GetFREData'),
                                         ' for making local live queries from R.'))
                      )),
             tabPanel('About authors',
                      fluidPage(column(size_pages,
                                       p('Marcelo S. Perlin - ', a('Personal webpage', href = 'https://www.msperlin.com/blog/')),
                                       p('Guilherme Kirch - ', a('Personal webpage', 
                                                                 href = 'http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4123414D0')),
                                       p('Daniel Vancin - ', a('Personal webpage', 
                                                               href = 'http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4751835E9')))  )
             ),
             tabPanel('Supporters',
                      fluidPage(column(size_pages,
                                       strong('Thank you everyone for supporting the GetDFPData project! '),
                                       p('The resources are being used to pay for the DigitalOcean server that hosts this app.'),
                                       p('You can make a donation with paypal:'),
                                       br(),
                                       HTML(paste0(readLines('html_components/paypal.html'), collapse = '\n')),
                                       br(),
                                       p(paste0('Full list of donations up to ', 
                                                as.Date(file.info(donation_file)$mtime), ':')),
                                       br(),
                                       tableOutput('donations_table')))),
             tabPanel('Changelog',
                      fluidPage(column(size_pages,
                                       h4('History'),
                                       p('2018-02-20 - Update on cache file. Modified df.info and output data.'),
                                       p('2018-04-02 - Update on cache file (new fr statements).'),
                                       p('2018-09-20 - Update on cache file (new fr statements).'),
                                       p('2019-01-12 - Update on cache file (see', a('here', 
                                                                                     href = 'https://www.msperlin.com/blog/post/2019-01-12-getdfpdata-ver14/'), 
                                         ' for details)' ),
                                       p('2019-05-28 - Update on cache file: new FR statements (4T2018) & bug fixes'),
                                       p('2019-10-12 - Update on interface (it once again supports xlsx)'),
                                       p('2020-04-17 - Update on cache file: new dfp and fre data from 2019'),
                                       p('2021-03-07 - New and improved GetDFPData2 interface. Now with REAL data feed. ',
                                         'See this', a('blog post', href="")),
                                       br(),
                                       h4('Next steps'),
                                       p('* implement ITR data -- NOT implemented (still testing for bugs)'),
                                       p('* implement FRE data -- NOT implemente (server cant handle a live query)')
                      )
                      )
             )
  )
)
)