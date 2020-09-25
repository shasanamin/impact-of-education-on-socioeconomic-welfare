library(xlsx)
library(jsonlite)
library(rvest)

source('utils.R')


## constants
# URLs and xpaths for web scraping
URLs <- vector(mode='list', length=6)
xpaths <- vector(mode='list', length=6)
names(URLs) <- c('pop', 'hdi', 'gdp', 'gbp', 'pov', 'equ')
names(xpaths) <- c('pop', 'hdi', 'gdp', 'gbp', 'pov', 'equ')
URLs[[1]] <- 'https://www.worldometers.info/world-population/population-by-country/'
xpaths[[1]] <- '//*[@id="example2"]'
URLs[[2]] <- 'https://en.wikipedia.org/wiki/List_of_countries_by_inequality-adjusted_HDI'
xpaths[[2]] <- '//*[@id="mw-content-text"]/div/table'
URLs[[3]] <- 'https://en.wikipedia.org/wiki/List_of_countries_by_GDP_(nominal)_per_capita'
xpaths[[3]] <- '//*[@id="mw-content-text"]/div/table/tbody/tr[2]/td[2]/table'
URLs[[4]] <- 'https://en.wikipedia.org/wiki/List_of_countries_by_government_budget_per_capita'
xpaths[[4]] <- '//*[@id="mw-content-text"]/div/table'
URLs[[5]] <- 'https://en.wikipedia.org/wiki/List_of_countries_by_percentage_of_population_living_in_poverty'
xpaths[[5]] <- '//*[@id="mw-content-text"]/div/table[2]'
URLs[[6]] <- 'https://en.wikipedia.org/wiki/List_of_countries_by_income_equality'
xpaths[[6]] <- '//*[@id="UNandCIA"]'


## main function for (pre)processing data from multiple sources
# takes path of directory with data files and output directory as command line inputs
# and saves a .csv file containing information from these files as well as that obtained through web scraping in provided output directory
main <- function(){
  args <- commandArgs(trailingOnly = TRUE)
  data_path <- args[1]
  out_dir <- args[2]
  # third argument is optional; data_year is 2018 by default
  if (length(grep(args[3],'NA')) == 1){
    data_year <- 2018
  } else{
    data_year <- args[3]
  }

  setwd(data_path)
  main_env <- environment()

  ## load data from local files
  # traverse data_path directory and store file names of respective formats
  excel_files <- list.files(data_path, pattern='.xlsx')
  csv_files <- list.files(data_path, pattern='.csv')
  json_files <- list.files(data_path, pattern='.json')

  excel_dfs <- load_files(excel_files, 'xlsx', read.xlsx)
  csv_dfs <- load_files(csv_files, 'csv', read.csv)
  json_dfs <- load_files(json_files, 'json', fromJSON)

  ## perform web scraping to gather data from online sources
  # additional geographic and demographic information
  countries_more_data <- get_table_as_df(as.character(URLs['pop']), as.character(xpaths['pop']))
  countries_more_data <- subset(countries_more_data, select=c('Country..or.dependency.', 'Population..2020.', 'Land.Area..Km².', 'Density..P.Km².', 'Urban.Pop..'))
  colnames(countries_more_data) <- c('Country', 'Population', 'Land_Area_km2', 'Density_per_km2', 'Urban_Population')

  # human development index and inequality adjusted human development index
  i_hdi <- get_table_as_df(as.character(URLs['hdi']), as.character(xpaths['hdi']))
  true_header <- unlist(i_hdi[1,], use.names = FALSE)
  true_header[1] <- 'HDI_Rank'
  i_hdi <- i_hdi[-1,]
  colnames(i_hdi) <- true_header
  i_hdi <- i_hdi[,c('Country', 'HDI', 'IHDI')]

  # gross domestic product per capita  
  gdp_pc <- get_table_as_df(as.character(URLs['gdp']), as.character(xpaths['gdp']))
  gdp_pc <- gdp_pc[,c('Country.Territory', 'US.')]
  colnames(gdp_pc) <- c('Country', 'GDP_Per_Capita_USD')

  # government budget per capita
  gb_pc <- get_table_as_df(as.character(URLs['gbp']), as.character(xpaths['gbp']))
  gb_pc <- gb_pc[,c('Country', 'Government.budget.per.capita..US...nominal.')]
  colnames(gb_pc) <- c('Country', 'Govt_Budget_Per_Capita_USD_Nominal')

  # population living below poverty level
  below_poverty <- get_table_as_df(as.character(URLs['pov']), as.character(xpaths['pov']))
  below_poverty <- below_poverty[,-which(colnames(below_poverty) == 'Year')]
  colnames(below_poverty) <- c('Country', 'Percent_Pop_living_under_USD_1.9_Per_Day', 'Percent_Pop_living_under_USD_3.2_Per_Day', 'Percent_Pop_living_under_USD_5.5_Per_Day', 'Continent')

  # gini index
  inequality <- get_table_as_df(as.character(URLs['equ']), as.character(xpaths['equ']))
  inequality <- inequality[3:dim(inequality)[1],]
  inequality <- subset(inequality, select=c('Country', 'World.Bank.Gini.4.'))
  colnames(inequality) <- c('Country', 'Gini_Index')

  ## merge available data into a single main dataframe
  # only include countries present in all individual dataframes (can update this if desired)
  df_int <- merge_by_country(c(excel_dfs, csv_dfs), data_year, select_year=TRUE)
  # remove year column since it would be added again on next merge_by_country call
  df_int <- df_int[,-2]
  df_processed <- merge_by_country(c('df_int', json_dfs, 'countries_more_data', 'i_hdi', 'gdp_pc', 'below_poverty', 'inequality'), data_year, select_year=FALSE, env=main_env)
  # budget values typically from 2017, which may not be very relevant for all years
  if(data_year=='2017'| data_year=='2018'){
    df_processed <- merge(df_processed, gb_pc, by='Country')
  }

  ## save main dataframe
  if(!file.exists(out_dir)){
    dir.create(out_dir)
  }
  out_file <- paste('data', data_year, '_processed.csv', sep='')
  write.csv(df_processed, paste(out_dir, '/data', data_year, '_processed.csv', sep=''), row.names=FALSE)
  cat(paste0('Processing Finished!\n', out_file, ' is now available in ', out_dir))
}


main()