observeEvent(input$actionid_itr, {
  
  my_companies <- input$user_companies_itr
  first_date <- input$daterange_itr[1]
  last_date <- input$daterange_itr[2]
  type_docs <- input$user_choice_type_docs_itr
  type_format <- input$user_choice_type_format_itr
  
  format_output <- switch(input$format_output_itr,
                          'Single Excel file (xlsx)' = 'xlsx',
                          'Single Zipped file with data as csv' = 'csv', 
                          'Single RDS file (R native format)' = 'rds')
  
  # error checking
  
  if (is.null(my_companies)) {
    my_text <- 'You must select at least one company..'
    alert(my_text)
    #output$text_action_id <- renderText(my_text)
    return()
  }
  
  if (is.null(type_docs)) {
    my_text <- 'You must select at least one type of doc..'
    alert(my_text)
    #output$text_action_id <- renderText(my_text)
    return()
  }
  
  if (is.null(type_format)) {
    my_text <- 'You must select at least one type of format..'
    alert(my_text)
    #output$text_action_id <- renderText(my_text)
    return()
  }
  
  #if ( (length(my_companies) > max_companies)&(format_output == 'xlsx') ) {
  
  # my_text <- paste0('When selecting output to a xlsx file, you can only choose five companies. ',
  #                   '\nOur server is modest and writing to xlsx can be memory consuming..', 
  #                   '\n\nYou have no such restriction when outputing to csv or rds..')
  # alert(my_text)
  # return()
  #}
  
  #if ( (length(my_companies) > max_companies) ) {
  
  # my_text <- paste0('You cannot select more than 20 companies in the web version. \n\n',
  #                   'We are running GetDFPData in a modest server.')
  # alert(my_text)
  # return()
  #}
  
  n_years <- dplyr::n_distinct(as.numeric(lubridate::year(first_date)):as.numeric(lubridate::year(last_date)))
  
  withProgress({
    
    #for (i.company in my_companies) {
    
    # df.report <- gdfpd.GetDFPData(name.companies = i.company,
    #                               first.date = first.date,
    #                               last.date = last.date,
    #                               type.info =  type.info, do.cache = TRUE,
    #                               cache.folder = 'DFP Cache Folder',
    #                               inflation.index = inflation.index)
    #incProgress(amount = 1, message = paste0('Done for ', i.company))
    
    #}
    
    df_info <- GetDFPData2::get_info_companies(cache_folder = my_app_cache_folder)
    
    
    my_cvm_codes <- df_info$CD_CVM[df_info$DENOM_SOCIAL %in% my_companies]
    
    if ((length(my_cvm_codes) == 0)&(my_companies != 'All Companies') ) {
      my_text <- paste0('Cant find data for ', my_companies) 
      
      alert(my_text)
      return()
    }
    
    if (any(my_companies == 'All Companies')) {
      my_cvm_codes <- NULL
      #incProgress(amount = 1, message = paste0('Getting Data for all companies'))
    } else {
      #incProgress(amount = 1, message = paste0('Getting Data for ', length(my_companies), ' companies'),
      #           detail = 'This may take a while...')
    }
    
    # shiny::Progress$new(
    #   session = session, # shiny session
    #   min = 0,
    #   max = dplyr::n_distinct(as.numeric(lubridate::year(first_date)):as.numeric(lubridate::year(last_date))),
    #   style = shiny::getShinyOption("progress.style",
    #                                 default = "notification")
    # )
    
    browser()
    l_dfp <- GetDFPData2::get_dfp_data(companies_cvm_codes = my_cvm_codes, 
                                       first_year =  lubridate::year(as.Date(first_date)),
                                       last_year = lubridate::year(as.Date(last_date)), 
                                       type_docs = type_docs,
                                       type_format = type_format,
                                       use_memoise = FALSE,
                                       cache_folder = my_app_cache_folder,
                                       do_shiny_progress = TRUE)
    
    # check if table output exists
    if (length(l_dfp) == 0) {
      my_text <- paste0(':( \n',
                        'Cant find data for your selection of companies and periods.\nTry again..') 
      
      alert(my_text)
      return()
    }
    # saving file
    withProgress({
      
      incProgress(amount = 1, message = paste0('Exporting data to ', format_output, ' (might take some time..)'))
      
      shinny_export_DFP_data(l_dfp = l_dfp, 
                             base_file_name = base_file_name, 
                             type_export =  format_output ) 
      
      incProgress(amount = 1, message = paste0('Done!'))
    }, 
    min = 0, 
    max = 2,
    message = 'Saving Data')
    
  }, 
  min = 0, 
  max = n_years,
  message = 'Warming up..')
  
  
  
  output$text_action_id_str <- renderText({
    paste0('DONE. Hit download..')
  })
  
  # NOT USED 
  output$code_text <- renderText({
    
    use.quotes <- function(str.in) paste0('"',str.in,'"')
    
    if (format_output == 'rds') {
      
      my_code_text_export <- paste0('"saveRDS(object = df.reports, file = paste0("',
                                    base_file_name, '.rds") )"')
      
    } else {
      
      my_code_text_export <- 'gdfpd.export.DFP.data(df.reports = df.reports, type.export = type.export)'
      
    }
    
    
    if (any(my_companies == 'All Companies')) {
      id_string <- 'NULL'
    } else {
      id_string <-paste0(my_cvm_codes,
                         collapse = ', ')
    }
    
    my_code_text <- paste0('# install pkg if not found\n',
                           'if (!require(devtools)) install.packages("devtools")\n',
                           'if (!require(GetDFPData2)) devtools::install_github("msperlin/GetDFPData2") \n\n',
                           '# load pkg\n',
                           'library(GetDFPData2)\n\n',
                           '# set input options\n',
                           'my_ids <- c(',id_string , ') \n',
                           'first_year  <- lubridate::year(as.Date(',  use.quotes(first_date), '))\n',
                           'last_year   <- lubridate::year(as.Date(', use.quotes(last_date), '))\n',
                           '\n',
                           '# get data using get_dfp_data\n',
                           '# This can take a while since the local data is not yet cached..\n',
                           'l_dfp <- get_dfp_data(companies_cvm_codes = my_ids, \n',
                           '                      first_year = first_year, \n',
                           '                      last_year  = last_year,\n',
                           '                      type_docs = c(', paste0(use.quotes(type_docs),
                                                                          collapse = ', '), '), \n', 
                           '                      type_format = c(',paste0(use.quotes(type_format),
                                                                           collapse = ', '), '))') 
    
    print(my_code_text)
    
  })
  
  
})