### utils.R
# (1) load_files: load files of same format as separate dataframes with same variable name as file name
# (2) get_table_as_df: load table from the web as a dataframe
# (3) merge_by_country: merge data for particular year from multiple dataframes with country names being the common key
# (4) add_var_quantiles: add column to dataframe for quantile information (first, second, third, fourth) of some variable of input dataframe
# (5) t_tests: perform multiple pairwise t-tests based on variable names from dataframe
# (6) bwplots_lattice: make box and whisker plots for all independent variables against all dependent variables using lattice
# (7) plots_gg: plot all independent variables against all dependent variables using desired ggplot functionality
###


load_files <- function(file_paths, file_ext, read_fun, env=.GlobalEnv){
  ### load files with same extension/format as separate dataframes with same variable name as file name
  # Arguments:
  #   - file_paths: list of paths of files to load
  #   - file_ext: extension for type of files to load
  #   - read_fun: function for loading a file of file_ext type given its paths
  #   - env: environment
  # 
  # Returns:
  #   - df_names: vector containing names of dataframes (with dataframes loaded into environment already)
  ###
  df_names = c()
  if (length(file_paths) > 0){
    for (f in 1:length(file_paths)){
      df_names <- c(df_names, toString(strsplit(file_paths[f], split=paste0('.',file_ext))))
      if (file_ext == 'xlsx') assign(df_names[length(df_names)], read_fun(file_paths[f], 1), envir=env)
      else assign(df_names[length(df_names)], read_fun(file_paths[f]), envir=env)
    }
  }
  return(df_names)  
}


get_table_as_df <- function(url, table_xpath){
  ### load table from the web as a dataframe
  # Arguments:
  #   - url: URL where table is available
  #   - table_xpath: xpath of table
  #
  # Returns:
  #   - df: dataframe containing data of table from the web
  ###
  data <- url %>%
    read_html() %>%
    html_nodes(xpath=table_xpath) %>%
    html_table(fill=TRUE)
  df <- data.frame(data)
  return(df)
}


# assumption: first column of each dataframe contains country names
merge_by_country <- function(df_names, year, select_year=FALSE, env=.GlobalEnv){
  ### merge data for particular year from multiple dataframes with country names being the common key
  # Arguments:
  #   - df_names: array of names of dataframes to merge
  #   - year: year for which data to choose
  #   - select_year: indicator for whether dataframe contain multiple years (of which year year needs to be selected)
  #                  or they already contain only data for the particular year (and such a selection is unnecessary)
  #   - env: environment
  #
  # Returns:
  #   - df: dataframe containing data after performing desired merge
  ###
  df <- data.frame(Country = eval(parse(text = df_names[1]), envir=env)[1])
  df['Year'] <- data.frame(Year=rep(year, dim(eval(parse(text = df_names[1]), envir=env))[1]))
  for (df_name in df_names){
    if(select_year){
      to_add <- eval(parse(text = df_name), envir=.GlobalEnv)[,c(colnames(eval(parse(text = df_name), envir=env))[1], paste('X',year,sep=''))]
      colnames(to_add)[2] <- df_name
    } else to_add <- eval(parse(text = df_name), envir=env)
    df <- merge(df, to_add[!duplicated(to_add[,1]),], by.x=colnames(df)[1], by.y=colnames(to_add)[1])
  }
  colnames(df)[1] = 'Country'
  return(df)
}


add_var_quantiles <- function(df, var, cat_name){
  ### add column to dataframe for quantile information (first, second, third, fourth) of some variable of input dataframe
  # Arguments:
  #   - df: dataframe with var feature/column that is a continuous variable
  #   - var: variable (feature/column) for which quantiles are to be made
  #   - cat_name: name to assign to the new column containing quantile information of var
  #
  # Returns:
  #   - df: same as input dataframe except that it has an additional column containing quantile information of var
  ###
  thresh_Q1 <- as.numeric(quantile(df[,var], 0.25, na.rm=TRUE))
  thresh_Q2 <- as.numeric(quantile(df[,var], 0.50, na.rm=TRUE))
  thresh_Q3 <- as.numeric(quantile(df[,var], 0.75, na.rm=TRUE))
  df[,cat_name] <- NA
  df[,cat_name][df[,var] <= thresh_Q1] <- 'First Quantile'
  df[,cat_name][df[,var] > thresh_Q1 & df[,var] <= thresh_Q2] <- 'Second Quantile'
  df[,cat_name][df[,var] > thresh_Q2 & df[,var] <= thresh_Q3] <- 'Third Quantile'
  df[,cat_name][df[,var] > thresh_Q3] <- 'Fourth Quantile'
  df[,cat_name] = factor(df[,cat_name], levels=c('First Quantile', 'Second Quantile', 'Third Quantile', 'Fourth Quantile'))
  return(df)
}


t_tests <- function(df, X, Y){
  ### perform multiple pairwise t-tests based on variable names from dataframe
  # Arguments:
  #   - df: dataframe containing all (categorical) variables of interest (i.e., for which t-test is to be performed)
  #   - X: array of dependent variables of interest
  #   - Y: array of independent variables of interest
  #
  # Returns:
  #   - res: array containing p-values of conducted tests
  ###
  res <- c()
  i <- 1
  for (x in X){
    for (y in Y){
      pvs <- pairwise.t.test(df[,y], df[,x])
      pvs$data.name <- paste(x, y, sep=' and ')
      res <- c(res, pvs)
      i <- i + 1
    }
  }
  return(res)
}


bwplots_lattice <- function(df, X, X_labs, Y, Y_labs, save=TRUE){
  ### make box and whisker plots for all independent variables against all dependent variables using lattice
  # Arguments:
  #   - df: dataframe containing values of all independent (x) and dependent (y) variables
  #   - X: vector of all variable names to use as independent variable
  #   - X_labs: labels for x-axis; in same order as X
  #   - Y: vector of all variable names to use as independent variable
  #   - Y_labs: labels for y-axis; in same order as Y
  #   - save: whether to save plot in current directory or not
  ###
  i <- 1
  for (x in X){
    j <- 1
    for (y in Y){
      if(save) png(paste0(y, '_vs_', x, '.png'))
      p <- bwplot(as.formula(paste(y,'~',x)), data = subset(df, !is.na(x)),
        xlab = X_labs[i], ylab = Y_labs[j])
      print(p)
      if(save) dev.off()
      j <- j + 1
    }
    i <- i + 1
  }
}


plots_gg <- function(plt_type, df, X, X_labs, Y=c(''), Y_labs=c(''), save=TRUE){
  ### plot all independent variables against all dependent variables using desired ggplot functionality
  # Arguments:
  #   - plt_type: type of plot; 'bw' for box-and-whisker, 'scatter', 'density', 
  #               and 'scatter_fit' (scatter plot with linear fitting) currently supported
  #   - df: dataframe containing values of all independent (x) and dependent (y) variables
  #   - X: vector of all variable names to use as independent variable
  #   - X_labs: labels for x-axis; in same order as X
  #   - Y: vector of all variable names to use as independent variable
  #   - Y_labs: labels for y-axis; in same order as Y
  #   - save: whether to save plot in current directory or not
  ###
  i <- 1
  for (x in X){
    j <- 1
    for (y in Y){
      if (save) png(paste0(y, '_vs_', x, '.png'))      
      if (plt_type == 'bw'){
        p <- ggplot(subset(df, !is.na(df[,x])), aes_string(x = x, y = y)) +
          geom_boxplot() +
          theme_bw() +
          labs(x = X_labs[i], y = Y_labs[j])        
      } else if (plt_type == 'scatter') {
        p <- ggplot(subset(df, !is.na(df[,x])), aes_string(x = x, y = y)) +
          geom_point() +
          theme_bw() +
          labs(x = X_labs[i], y = Y_labs[j])
      } else if (plt_type == 'scatter_fit'){
        p <- ggplot(subset(df, !is.na(df[,x])), aes_string(x = x, y = y)) +
          geom_point() +
          geom_smooth(method='lm', se=FALSE) +
          theme_bw() +
          labs(x = X_labs[i], y = Y_labs[j])        
      } else if (plt_type == 'density'){
        p <- ggplot(df, aes_string(x = x)) +
          geom_density(fill="lightblue") +
          theme_bw() +
          labs(x = X_labs[i])        
      } else {
        p <- 'Unrecognized plt_type'
      }
      print(p)
      if (save) dev.off()      
      j <- j + 1
    }
    i <- i + 1
  }
}