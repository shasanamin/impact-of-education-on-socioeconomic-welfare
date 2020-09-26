library('ggplot2')
library('lattice')

source('utils.R')

## constants
## variables and labels for box-and-whisker plots using lattice
# categ. variables to be created from cont. variables in processed data file
X_bw_latt <- c('SLE_Cat', 'LR_Cat', 'GEE_PC_Cat', 'EEPTGE_Cat')
X_bw_latt_labs <- c(
  'School Life Expectancy', 
  'Literacy Rate', 
  'Government Expenditure on Education Per Capita', 
  'Expenditure On Education as a Percentage of Total Government Expenditure'
)
# can be any variable (column identifier) from processed data file
Y_bw_latt <- c('HDI', 
               'IHDI', 
               'Govt_Budget_Per_Capita_USD_Nominal', 
               'GDP_Per_Capita_USD', 'Urban_Population', 
               'Percent_Pop_living_under_USD_1.9_Per_Day', 
               'Percent_Pop_living_under_USD_3.2_Per_Day', 
               'Percent_Pop_living_under_USD_5.5_Per_Day', 
               'Gini_Index')
Y_bw_latt_labs <- c('Human Development Index', 
                    'Inequality-Adjusted Human Development Index', 
                    'Government Budget Per Capita (USD)', 
                    'GDP Per Capita (USD)', 
                    'Urban Population', 
                    'Percentage Population Living Under USD 1.9 Per Day', 
                    'Percentage Population Living Under USD 3.2 Per Day', 
                    'Percentage Population Living Under USD 5.5 Per Day', 
                    'Gini Index')

## variables and labels for scatter plots with linear fit using ggplot
# can be any variable from processed data file
X_sf_gg <- c(
  'Expenditure_On_Education_As_A_Percentage_Of_Total_Government_Expenditure', 
  'GEE_PC', 
  'Literacy_Rate'
)
X_sf_gg_labs <- c(
  'Expenditure on Education as a Percentage of Total Government Expenditure', 
  'Government Expenditure on Education Per Capita', 
  'Literacy Rate'
)
Y_sf_gg <- c('GDP_Per_Capita_USD', 
             'Govt_Budget_Per_Capita_USD_Nominal', 
             'Gini_Index', 
             'HDI', 
             'Percent_Pop_living_under_USD_5.5_Per_Day', 
             'Urban_Population')
Y_sf_gg_labs <- c('GDP per Capita (USD)', 
                  'Government Budget Per Capita', 
                  'Gini Index', 
                  'Human Development Index', 
                  'Population Living Under 5.5 USD Per Day', 
                  'Urban Population')

## variables and labels for density plots using ggplot
# can be any variable from processed data file
X_density_gg <- c('Literacy_Rate', 
                  'School_Life_Expectancy', 
                  'GEE_PC', 
                  'Govt_Budget_Per_Capita_USD_Nominal', 
                  'Expenditure_On_Education_As_A_Percentage_Of_Total_Government_Expenditure', 
                  'Urban_Population', 
                  'Population_By_Bachelors_Completed')
X_density_labs <- c(
  'Literacy Rate', 
  'School Life Expectancy', 
  'Government Expenditure on Education Per Capita', 
  'Government Budget Per Capita (USD)', 
  'Expenditure on Education as a Percentage of Total Government Expenditure', 
  'Urban Population', 
  'Population By Bachelors Completed'
)

## variables for hypothesis testing, i.e., to perform statistical inference
X_SI <- c('LR_Cat', 'SLE_Cat', 'GEE_PC_Cat')
Y_SI <- c('GDP_Per_Capita_USD', 
          'Govt_Budget_Per_Capita_USD_Nominal', 
          'HDI', 
          'Urban_Population', 
          'Percent_Pop_living_under_USD_5.5_Per_Day')

## main function to analyze (perform EDA and hypothesis testing) processed data
# takes paths of directory with processed data and
# directory where graphs would be saved as command line inputs,
# and outputs results of performed hypothesis testing while 
# saving produced graphs in provided directory for saving
main <- function(){
  args <- commandArgs(trailingOnly = TRUE)
  data_path <- args[1]
  save_dir <- args[2]

  # create directory for saving graphs, if it does not already exist
  if(!file.exists(save_dir)){
    dir.create(save_dir)
  }
  setwd(save_dir)
  
  # load processed data file
  df <- read.csv(data_path)

  ## handle misread data
  df$Population <- as.numeric(
    gsub(',', '', as.character(df$Population))
  )
  df$Government_Expenditure_On_Education_In_USD_Millions <- as.numeric(
    gsub(',', '', as.character(df$Government_Expenditure_On_Education_In_USD_Millions))
  )
  df$GDP_Per_Capita_USD <- as.numeric(
    gsub(',', '', as.character(df$GDP_Per_Capita_USD))
  )
  df$Govt_Budget_Per_Capita_USD_Nominal <- as.numeric(
    gsub(',', '', as.character(df$Govt_Budget_Per_Capita_USD_Nominal))
  )
  df$Percent_Pop_living_under_USD_1.9_Per_Day <- as.numeric(
    gsub('%', '', as.character(df$Percent_Pop_living_under_USD_1.9_Per_Day))
  )
  df$Percent_Pop_living_under_USD_3.2_Per_Day <- as.numeric(
    gsub('%', '', as.character(df$Percent_Pop_living_under_USD_3.2_Per_Day))
  )
  df$Percent_Pop_living_under_USD_5.5_Per_Day <- as.numeric(
    gsub('%', '', as.character(df$Percent_Pop_living_under_USD_5.5_Per_Day))
  )
  df$Urban_Population <- as.numeric(
    gsub('%', '', as.character(df$Urban_Population))
  )
  df$GEE_PC <- df$Government_Expenditure_On_Education_In_USD_Millions / df$Population

  ## transform (continuous) data to (categorical) quantiles 
  # for exploratory data analysis (esp. for boxplots) and hypothesis testing
  df <- add_var_quantiles(df, 'Literacy_Rate', 'LR_Cat')
  df <- add_var_quantiles(df, 'School_Life_Expectancy', 'SLE_Cat')
  df <- add_var_quantiles(df, 'GEE_PC', 'GEE_PC_Cat')
  df <- add_var_quantiles(
    df, 
    'Expenditure_On_Education_As_A_Percentage_Of_Total_Government_Expenditure', 
    'EEPTGE_Cat'
  )

  ## perform exploratory data analysis
  bwplots_lattice(df=df, X=X_bw_latt, X_labs=X_bw_latt_labs, 
                  Y=Y_bw_latt, Y_labs=Y_bw_latt_labs)
  plots_gg(plt_type='scatter_fit', df=df, X=X_sf_gg, X_labs=X_sf_gg_labs, 
           Y=Y_sf_gg, Y_labs= Y_sf_gg_labs)
  plots_gg(plt_type='density', df=df, X=X_density_gg, X_labs=X_density_labs)

  ## perform hypothesis testing
  t_tests(df, X_SI, Y_SI)
}


main()