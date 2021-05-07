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

# Options
my_app_cache_folder <<- '~/gdfpd2-cache'
df_info_companies <- GetDFPData2::get_info_companies(cache_folder = my_app_cache_folder)
donation_file <<- 'data/donations_2021-03-05.rds'
size_pages <- 6
max_companies <- NULL # not used
base_file_name <<- paste0('gdfd2_Export_', 
                          format(Sys.time(), '%Y%m%d-%H%M%S'))

# filter for available companies
idx <- df_info_companies$SIT_REG == 'ATIVO'
df_info_companies <- df_info_companies[idx, ]

available_companies <- sort(unique(df_info_companies$DENOM_SOCIAL))

shinyUI(fluidPage(#shinythemes::themeSelector(),
  navbarPage("GetDFPData2 Web",
             theme = shinytheme("united"),
             fluid=TRUE,
             # Intro tab ----
             make_panel_introduction(size_pages),
             # info companies ----
             make_panel_info(size_pages),
             # DFP panel ----
             make_panel_dl_dfp(size_pages, available_companies),
             # FRE panel ----
             make_panel_dl_fre(size_pages),
             # About authors panel ----
             make_panel_authors(size_pages),
             # supporters panel ----
             make_panel_supporters(size_pages),
             # changelog panel ----
             make_panel_changelog(size_pages)
  )
)
)