> 
>
> # Overconfidence and Financial Behaviors

I investigate whether overconfidence in financial literacy affect households' financial behaviors through the lens of retirement readiness, precautionary savings, and financial market participation. Machine learning classifiers are employed to measure overconfidence.   

The repository consists of four parts, namely `codes`, `data`, `outputs`, and `docs`. 

## 1. Codes

The codes are divided into three parts.

### (a) Clean the NFCS dataset  

The codes are shown in the Stata do file `process_NFCS.do` and the log file is uploaded to the `outputs/logs` folder. I extract necessary variables (financial behaviors, demographic characteristics, perceived & true financial literacy) from the raw data, merge the education data from the 2012 study, and do some basic cleaning. The cleaned data are exported to `processed_NFCS.csv` in the `data` folder.

### (b) Construct the overconfidence measures using machine learning classifiers

The codes are shown in the jupyter notebook `overconfidence_measure.ipynb`. After read the pre-cleaned data, I first examine the fundamental patterns of perceived and true financial literacy to form an initial impression of the data. Then I construct a learning set where households can be unambiguously categorized as overconfident or not overconfident. After that I train the classifiers with the learning set and compare the performances of them by MSE. The MSEs of different classifiers are exported as `MSE.png` to the `outputs/figures` folder, and as `MSE.csv` to the `outputs/tables` folder. Finally I generate the out-of-sample predictions and export the dataset as `overconfidence_measure.csv` in the `outputs/tables` folder for later use. Several figures are also exported to the `outputs/figures`. 
### (c) Explore the effects of overconfidence

The codes are shown in the Stata do file `Analysis.do` and the log file is uploaded to the `outputs/logs` folder. I translate `overconfidence_measure.csv` into excel and put it into the `data` folder before I read the data into Stata because of the precision loss when importing `.csv` files into Stata. I run the logit regression model (3) as presented in the paper to see whether overconfidence affects retirement readiness, precautionary savings, and financial market participation of households. Heterogeneous effects are also investigated. Multiple tables are exported to the `outputs/tables` folder.

## 2. Data

The data of my study come from the National Financial Capability Studies (NFCS), which can be downloaded [here](https://www.usfinancialcapability.org/downloads.php). To be specific, I utilized the [2018 State-by-State Survey — Tracking Dataset, Comma delimited Excel file (.csv)](https://www.usfinancialcapability.org/downloads/NFCS_2018_State_by_State_Tracking_Data_Excel.zip) and the [2012 State-by-State Survey — Respondent-Level Data, Comma delimited Excel file (.csv)](https://www.usfinancialcapability.org/downloads/NFCS_2012_State_by_State_Data_Excel.zip) to complete my analyses. They are also uploaded to this folder. 

## 3. Docs

This folder contains the poster and the paper for this project.







