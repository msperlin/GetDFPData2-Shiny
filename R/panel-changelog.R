make_panel_changelog <- function(size_pages) {
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
}