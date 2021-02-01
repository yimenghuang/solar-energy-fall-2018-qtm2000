# solar-energy-fall-2018-qtm2000
QTM2000 Fall 2018 Final Group Project
- **QTM 2000:** Case Studies in Business Analytics
- **Contributors:** Yimeng (Silvia) Huang, Haorui (Raymond) Huang, Jiayan (Shirley) Ying, Xianle Jin
- **Programming Language:** R (RStudio)
- **Note:** In this Github repo, I will only include my own portion of code and any code necessary for cleaning and exploring the data before building models. Future students should not copy the project as their own to submit for QTM2000 Final Project.


## Project Requirements:
Students are expected to complete a data analysis/machine learning project from scratch that addresses a business problem.
- They are asked to define their own business problem of interest and search for their own dataset for analyses. The dataset cannot be overly analyzed before (e.g. datasets from UCI Machine Learning Repository or Kaggle competitions, etc.).
- For data analysis/machine learning, they should clean the dataset, explore the variables, and build their own machine learning models.
- In the end, they should draw conclusions and insights from their analyses to make recommendations.
- Deliverables: in-class presentation, written report


## Dataset Description:
The two raw datasets used in our project were obtained from [*The Open PV Project*](https://www.nrel.gov/pv/open-pv-project.html) (no longer available) of the National Renewable Energy Laboratory in November 2018.
- **full Open PV Dataset:** 1,020,813 records, 81 variables
- [**Tracking the Sun Public Data File**](https://emp.lbl.gov/tracking-the-sun): 1,094,909 records, 52 variables (collected and processed by Lawrence Berkeley National Laboratory based on the full dataset)
- **Note:** The datasets on the website were already updated as of 1/31/2021. In this Github repo, I will not include the original datasets (.csv) we used in the project due to copyright considerations. If anyone is interested, please DM me to discuss privately.


## Our Project:
Solar energy is one of the cleanest and most abundant renewable energy source available today. There has been significant development due to the advancement of technology. Government incentive programs and the reduction in solar energy infrastructure costs also prompted individuals and households to consider adopting this new technology. However, the increasing rate of adoption in solar energy has sparked disruptions in both utility and oil industries. This signifies a shift in customer demand for energy and presents an interesting dynamic in the energy market. To explore more about this disruptive technology, our team is particularly interested in its energy production efficiency. We believe that this is also valuable information for customers who are considering adopting solar energy technology. This is because when making decision to install solar panels, a solar power contractor is often hired to provide information about the amount of space that is required for installation, module efficiency, system size, and etc. Therefore, based on these available information, we would like to provide additional information by constructing models to predict the annual energy production and better educate customers on the realistic return of implementing solar panels.
- In this Github repo, I share my code of cleaning the dataset, exploring and transforming the variables, and building the kNN regression model.
- R Packages Needed:
  - dplyr
  - e1071
  - class
  - FNN
  - forecast
  - caret


## Files:
- **Data Analytics with R for Solar PV Production Efficiency.pdf:** in-class presentation slides
- **QTM Final Project Written Report - Team 1.pdf:** written report
- **yimeng-knn-regression.R:** my portion of R code for cleaning the dataset, exploring and transforming the variables, and building the kNN regression model
