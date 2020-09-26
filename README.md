# Impact of Education on Socioeconomic Welfare of Countries

This repository contains work carried out as part of an independent project for the course Data Science for Decision Making at Lahore University of Management Sciences. The scope of this project was limited to problem formulation, data gathering and preparation, exploratory data analysis and hypothesis testing. The general insight from this project is that socioeconomic welfare (as measured through HDI, Gini Index, GDP per capita, etc.) is strongly impacted by the quality of/ interest in education (as measured through literacy rate, government expenditure on education, percentage population with an undergraduate degree, etc.). More details are available in [report](report.pdf).

Publicly available datasets, available in [data_raw](data/data_raw), were used for this project. These were obtained primarily from:
- http://data.uis.unesco.org/
- http://hdr.undp.org/
- https://data.worldbank.org/

Sample processed data (obtained using [process.R](process.R)) is available in [data/data_processed](data/data_processed). Sample plots (obtained using [analyze.R](analyze.R)) is available in [eda](eda).

Note: While this project is focused on a particular problem, the work may be helpful for many (data science) projects. For example, I have found myself reusing provided utility functions for loading multiple files of same format, turning continuous data to quantiles (categorical), plotting multiple 2D plots from array of variables, etc. in multiple projects.

### Code explanation

(1) process.R: Generate single processed CSV file containing raw data from multiple sources and formats.

(2) analyze.R: Perform exploratory data analysis and hypothesis testing.

(3) utils.R: Some utility functions.

### Command inputs:
(1) process.R
-   data_path: path of directory with raw data
-   out_dir: path of directory where processed file would be stored
-   data_year (optional): year for which processed data has to be prepared

(2) analyze.R
-   data_path: path of directory where processed file is stored
-	save_dir: path of directory where graphs would be stored

Note: Constants, e.g. URLs for web scraping and variables for plotting, are currently set inside respective files, as was considered convenient. They may be passed as input and/or read from a separate file through minor changes to relevant files.

### Example command

```shell
$ Rscript process.py "data/data_raw" "data/data_processed" 2019
```

```shell
$ Rscript analyze.py "data/data_processed/data2019_processed.csv" "eda"
```

### Outputs
(1) process.R
-	dataxxxx_processed: CSV file containing processed data for xxxx year

(2) analyze.R
-	results of performed t-tests
-	images of plotted graphs