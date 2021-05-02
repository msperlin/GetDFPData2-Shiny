#' Export tibble to an excel or csv (zipped) file
#'
#' Export information from gdfpd_GetDFPData() to an excel file or csv. In the csv case, all tables are exported as csv
#' files and zipped in a single zip file.
#'
#' @param l_dfp Tibble with financial information (output of gdfpd.GetDFPData)
#' @param base_file_name The basename of excel file (make sure you dont include the file extension)
#' @param type_export The extension of the desired format: 'xlsx' (default) or 'csv'
#'
#' @return TRUE, if successfull (invisible)
#' @export
#'
#' @examples
#'
#' # get example data from RData file
#' my_f <- system.file('extdata/Example_DFP_Report_Petrobras.RData', package = 'GetDFPData')
#' load(my_f)
#'
#' \dontrun{ # dontrun: keep cran check time short
#' gdfpd.export.DFP.data(df.reports, base_file_name = 'MyExcelFile', format.data = 'wide')
#' }
shinny_export_DFP_data <- function(l_dfp,
                                   base_file_name,
                                   type_export) {
  
  # check args
  possible.exports <- c('xlsx', 'csv', 'rds')
  if (any(!(type_export %in% type_export))) {
    stop('input type_export should be "xlsx", "csv" or "rds"')
  }
  
  # possible.formats <- c('wide', 'long')
  # if (any(!(type_export %in% type_export))) {
  #   stop('input format.data should be "wide" or "long"')
  # }
  
  f_out <- file.path(tempdir(),
                     paste0(base_file_name, 
                            switch(type_export,
                                   'xlsx' = '.xlsx',
                                   'csv' = '.zip',
                                   'rds' = '.rds')))
  
  if (file.exists(f_out)) {
    cat('File ', f_out, ' already exists. Deleting it..')
    file.remove(f_out)
  }
  
  # set dir for csv files
  csv_dir <- file.path(tempdir(), 'CSV-DIR')
  dir.create(csv_dir)
  
  if (type_export == 'csv') {
    
    for (i_df in seq(length(l_dfp)) ) {
      
      name_df <- names(l_dfp)[i_df]
      name_file <- paste0(name_df, '.csv')
      current_df <- l_dfp[[i_df]]
      
      readr::write_csv(x = current_df, 
                       file = file.path(csv_dir, name_file))
      # check if it is financial report and wheter we want wide format
      # if (test.fr) {
      #   if (format.data == 'wide') {
      #     current.df = gdfpd.convert.to.wide(current.df)
      #   }
      # }
      
      # copy
      
      
    }
    
    files_to_zip <- list.files(csv_dir, full.names = TRUE)
    zip(zipfile = f_out, files = files_to_zip, flags = '-j')
    
  }
  
  if (type_export == 'rds') {
    
    readr::write_rds(x = l_dfp, 
                     file = f_out)
    
  }
  
  if (type_export == 'xlsx') {
    
    writexl::write_xlsx(l_dfp,
                        path = f_out)

  }
  
  return(f_out)
  
}

