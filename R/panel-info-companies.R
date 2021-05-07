make_panel_info <- function(size_pages) {
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
  )
}