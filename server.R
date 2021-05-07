library(shiny)
library(stringr)
library(shinythemes)

shinyServer(function(input, output, session) {
  
  output$user_companies <- renderText(
    paste0(length(input$user_companies),
           ' companies selected')
  )
  output$user_companies_itr <- renderText(
    paste0(length(input$user_companies_itr),
           ' companies selected')
  )
  
  output$date_range <- renderPrint(input$daterange1)
  output$date_range_itr <- renderPrint(input$daterange_itr)
  
  # info table
  output$table <- renderDataTable({
    df_info_companies <- GetDFPData2::get_info_companies(cache_folder = my_app_cache_folder)
    
    # filter for available companies
    idx <- df_info_companies$SIT_REG == 'ATIVO'
    df_info_companies <- df_info_companies[idx, ]
    
    df_info_companies[, 1:5]
  })
  
  # donations table
  output$donations_table <- renderTable({
    df_donations <- readRDS(donation_file) 
    
    df_donations$Date <- as.character(df_donations$Date)
    df_donations
  })
  
  
  # dfp ui
  observeEvent(input$actionid, {
    
    my_companies <- input$user_companies
    first_date <- input$daterange1[1]
    last_date <- input$daterange1[2]
    type_docs <- input$user_choice_type_docs
    type_format <- input$user_choice_type_format
    
    format_output <- switch(input$format_output,
                            'Single Excel file (xlsx)' = 'xlsx',
                            'Single Zipped file with data as csv' = 'csv', 
                            'Single RDS file (R native format)' = 'rds')
    
    # error checking
    
    if (is.null(my_companies)) {
      my_text <- 'You must select at least one company..'
      alert(my_text)
      return()
    }
    
    if (is.null(type_docs)) {
      my_text <- 'You must select at least one type of doc..'
      alert(my_text)
      return()
    }
    
    if (is.null(type_format)) {
      my_text <- 'You must select at least one type of format..'
      alert(my_text)
      return()
    }
    
    n_years <- dplyr::n_distinct(
      as.numeric(lubridate::year(first_date)):as.numeric(lubridate::year(last_date))
    )
    
    withProgress({
      
      df_info <- GetDFPData2::get_info_companies(cache_folder = my_app_cache_folder)
      
      my_cvm_codes <- df_info$CD_CVM[df_info$DENOM_SOCIAL %in% my_companies]
      
      if ((length(my_cvm_codes) == 0)&(my_companies != 'All Companies') ) {
        my_text <- paste0('Cant find data for ', my_companies) 
        
        alert(my_text)
        return()
      }
      
      if (any(my_companies == 'All Companies')) {
        my_cvm_codes <- NULL
      } 
      
      # call to get_dfp_data
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
    
    
    
    output$text_action_id <- renderText({
      paste0('DONE. Hit download..')
    })
    
    # Produces text of R code in DFP page
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
  
  
  # handles dfp download
  output$downloadData <-  downloadHandler(
    filename = function() {
      my_filename <- switch(input$format_output,
                            'Single Excel file (xlsx)' = paste0(base_file_name, '.xlsx'),
                            'Single Zipped file with data as csv'  = paste0(base_file_name, '.zip'),
                            'Single RDS file (R native format)'  = paste0(base_file_name, '.rds'))
      
      print(my_filename)},
    content = function(file) {
      
      fileout <- switch(input$format_output,
                        'Single Excel file (xlsx)' = file.path(tempdir(), 
                                                               paste0(base_file_name, '.xlsx')),
                        'Single Zipped file with data as csv'  = file.path(tempdir(), 
                                                                           paste0(base_file_name, '.zip')),
                        'Single RDS file (R native format)'  = file.path(tempdir(), 
                                                                         paste0(base_file_name, '.rds')) )
      
      file.copy(from = fileout, 
                to = file, 
                overwrite = T)
      
    })
  
  output$downloadDfInfo_csv <- downloadHandler(
    filename = function() {
      print(paste0('Info_Companies_',
                   Sys.Date(), '.csv'))
    },
    content = function(con) {
      csv_out <- tempfile(fileext = '.csv')
      
      readr::write_csv(x = GetDFPData2::get_info_companies(my_app_cache_folder), 
                       file = csv_out)
      
      file.copy(from = csv_out, to = con, overwrite = T)
    }
  )
  
  output$downloadDfInfo_xlsx <- downloadHandler(
    filename = function() {
      print(paste0('Info_Companies_',
                   Sys.Date(), '.xlsx'))
    },
    content = function(con) {
      xlsx_out <- tempfile(fileext = '.xlsx')
      
      writexl::write_xlsx(x = GetDFPData2::get_info_companies(my_app_cache_folder), 
                          path = xlsx_out)

      file.copy(from = xlsx_out, to = con, overwrite = T)
    }
  )
})
