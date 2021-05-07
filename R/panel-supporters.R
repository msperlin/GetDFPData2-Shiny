make_panel_supporters <- function(size_pages) {
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
                            tableOutput('donations_table'))))
}