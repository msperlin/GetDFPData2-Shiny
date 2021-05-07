make_panel_introduction <- function(size_pages) {
  
  size_panels <- 3
  
  tabPanel('Introduction',
           position = 'center',
           fluidPage(shinyjs::useShinyjs(),
                     tags$head(includeScript("GAnalytics/google-analytics.js"),
                               includeCSS('css/my_css.css')
                     ),
                     titlePanel(title = ' ', windowTitle = 'GetDFPData2 - Web'),
                     fluidRow(
                       column(size_panels,
                              h3('Welcome!'),
                              p('GetDFPData2 is the second iteration of GetDFPData, an academic project to provide free and unrestricted access to corporate datasets from B3, the Brazilian financial exchange.',
                                'GetDFPData2 is released as an R package available in github (soon in CRAN). You can find more details about the project in ', 
                                ' its ', a('academic paper', href = 'http://bibliotecadigital.fgv.br/ojs/index.php/rbfin/article/view/78654'), 
                                ' and ', a('Github page.', href = 'https://github.com/msperlin/GetDFPData2'), 
                                ' The code for this shiny app is also available in ', a('Github', href = 'https://github.com/msperlin/GetDFPData2-Shiny')),  
                              p("In this site you'll be able to use the same code to download financial information from the exchange with a web interface",
                                'of package GetDFPData2. ',
                                'Be aware that command line version offers far more functionality.') ),
                       column(size_panels,
                              h3('Instructions:'),
                              p('Tab ', strong('Info about companies'), ' offers several details about companies.',
                                ' This includes official names, cnpj, cvm id, and much more.',
                                ' You can also download the table to your computer as csv or xlsx',
                                ' Notice that a search box is available at top right of displayed table. You can use it for finding details about a particular company.'),
                              p('Tab ', strong("Download DFP Data"), ' is the main application. In order to use it, select your companies, ',
                                'date range, type of output and press ', strong("Get Data"), '. ',
                                'After the server imports the data from the internet and cleans it, a ', strong("Download"), ' button should appear, with a link ',
                                'to an Excel, csv or rds file.')
                       ) 
                     ),
                     fluidRow(
                       column(size_panels,
                              h3('Access to Compiled Datasets'),
                              p('Recently I released the full, up to date, datasets for all R projects, including GetDFPData2 and GetFREData. ',
                                'More details in this ', a('blog post.', href = 'https://www.msperlin.com/blog/post/2020-04-20-free-compiled-data-in-site/')),
                              p('If youre using it for research, please cite the original source using dataverse (details at blog post).')
                       ),
                       column(size_panels,
                              h3('Support the project!'),
                              p("This web interface is written in shiny and hosted in a DigitalOcean server with a 10 USD per month overhead.",
                                " The GetDFPData project has no formal financial support and, ",
                                "so far, I've been paying it myself, with the proceeds of my ", 
                                a('books', href='https://www.msperlin.com/blog/publication/#5'), ".",
                                " If you're using the shiny interface, please help us keeping the project alive."),
                              p('All we need is to cover the costs of the server. If you can, please make one-time or continuous donation.',
                                'All supporters will be featured anonymously in the Supporters tab.'),
                              HTML(paste0(readLines('html_components/paypal.html'), collapse = '\n'))
                       )),
                     fluidRow(
                       column(size_panels,
                              h3('Bug reports'),
                              p('The package is in constant development. ',
                                'If you have found an error or bug, please use ', a('Github', href = 'https://github.com/msperlin/GetDFPData2/issues'),
                                " to report it. I'll look into as soon as I can. If you don't have a github account, just drop me an email (marceloperlin@gmail.com).")
                       ),
                       column(size_panels,
                              h3('Citation'),
                              p('If you have used the data for scientific research, please cite the data source as:'),
                              br(),
                              p('Perlin, M. S., Kirch, G., & Vancin, D. (2019). Accessing financial reports and corporate events with GetDFPData. Revista Brasileira de Finanças, 17(3).')
                       )
                     ),
                     fluidRow(
                       column(size_panels,
                              img(src='logo_ufrgs.png', align = "left", width="100", height="100")
                       ),
                       column(size_panels,
                              img(src='logo_ea.png', align = "left", width="100", height="100")
                       )
                     )
           )
           
  )
  
  
}