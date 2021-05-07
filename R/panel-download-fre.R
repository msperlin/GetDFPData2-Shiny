make_panel_dl_fre <- function(size_pages) {
  tabPanel('Download FRE Data',
           fluidPage(column(size_pages,
                            h4('Not Available..'),
                            p('FRE data is sparse and demands a heavy download for every user query as every pair of company/year is a 15 to 20 MB download.',
                              'Despite my efforts, the server simply can\'t handle multiple queries from package GetFREData. ',
                              'As a alternative, you can download parsed FRE data from 2010 in my ',
                              a('dataverse library', href = 'https://dataverse.harvard.edu/dataverse/msperlin'), 
                              '. Or, if you dig some coding, simply use function get_fre_data from package ', 
                              a('GetFREData', href = 'https://github.com/msperlin/GetFREData'),
                              ' for making live queries froma local R session.'))
           )
  )
}