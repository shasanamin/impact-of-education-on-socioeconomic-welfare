# Impact of Education on Socioeconomic Welfare of Countries

This repository contains work carried out as part of an independent project for the course Data Science for Decision Making at Lahore University of Management Sciences. The scope of this project was limited to problem formulation, data gathering and preparation, exploratory data analysis and hypothesis testing. The general insight from this project was that socioeconomic welfare (as measured through HDI, Gini Index, GDP per capita, etc.) of countries is strongly impacted by their quality of/ interest in education (as measured through literacy rate, government expenditure on education, percentage population with an undergraduate degree, etc.). More details are available in accompanying [report](report.pdf).

Publicly available datasets, available in [data_raw](data/data_raw), were used for this project. They were obtained primarily from:
- http://data.uis.unesco.org/
- http://hdr.undp.org/
- https://data.worldbank.org/

Sample processed data (obtained using [process.R](process.R)) is available in [data_processed](data/data_processed). Sample plots (obtained using [analyze.R](analyze.R)) are available in [eda](eda).

Note: While this project focuses on a particular problem, the work may be helpful for many (data science) projects. For example, I have found myself reusing provided utility functions that load multiple files of same format, turn continuous variables to quantiles (categorical), plot multiple 2D plots from array of variables, etc. on multiple instances.

### Code explanation

(1) process.R: Generate a CSV file containing processed data from multiple sources and formats.

(2) analyze.R: Perform exploratory data analysis and hypothesis testing.

(3) utils.R: Some utility functions.

### Command inputs:
(1) process.R
-   data_path: path of directory with raw data files
-   out_dir: path of directory where processed data file would be stored
-   data_year (optional): year for which processed data has to be prepared

(2) analyze.R
-   data_path: path of directory where processed data file is stored
-	save_dir: path of directory where graphs are to be stored

Note: Constants, e.g. URLs for web scraping and variables for plotting, are currently set inside respective files, as was considered convenient. They may be passed as input and/or read from a separate file instead with only minor changes to relevant files.

### Example command

```shell
$ Rscript process.py "data/data_raw" "data/data_processed" 2019
```

```shell
$ Rscript analyze.py "data/data_processed/data2019_processed.csv" "eda"
```

### Outputs
(1) process.R
-	dataXXXX_processed: CSV file containing processed data for year XXXX

(2) analyze.R
-	results of performed t-tests
-	images of plotted graphs