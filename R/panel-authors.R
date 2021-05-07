make_panel_authors <- function(size_pages) {
  tabPanel('About authors',
           fluidPage(column(size_pages,
                            p('Marcelo S. Perlin - ', a('Personal webpage', href = 'https://www.msperlin.com/blog/')),
                            p('Guilherme Kirch - ', a('Personal webpage', 
                                                      href = 'http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4123414D0')),
                            p('Daniel Vancin - ', a('Personal webpage', 
                                                    href = 'http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=K4751835E9')))  )
  )
}