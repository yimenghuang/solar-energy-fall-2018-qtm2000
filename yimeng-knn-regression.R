###READ DATASETS###
full=read.csv("openpv_all.csv") #read full dataset

#read cleaned datasets
clean1=read.csv("TTSX_LBNL_OpenPV_public_file_p1.csv")
clean2=read.csv("TTSX_LBNL_OpenPV_public_file_p2.csv")

#Vertically merge cleaned datasets
library("dplyr")
clean=bind_rows(clean1,clean2)

#Check data types
str(full)
str(clean)

###DATA CLEANING & EXPLORATION###
#Change data types
full$date_installed=as.character(full$date_installed)
clean$Installation.Date=as.character(clean$Installation.Date)

full$zipcode=as.factor(full$zipcode)
clean$Zip.Code=as.factor(clean$Zip.Code)

full$installer=as.character(full$installer)
clean$Installer.Name=as.character(clean$Installer.Name)

#Merge full dataset with clean dataset based on 4 primary keys
innerjoin=inner_join(clean,full,by=c("Installation.Date"="date_installed","System.Size"="size_kw","Zip.Code"="zipcode","Installer.Name"="installer"))
#Check duplicate rows
anyDuplicated(innerjoin)
#Keep only unique rows
innerjoin=distinct(innerjoin)

#Create new dataset only containing useful variables
new_innerjoin=select(innerjoin,Module.Efficiency..1,System.Size,DC.Optimizer,annual_insolation,reported_annual_energy_prod,Total.Installed.Price,Ground.Mounted)
str(new_innerjoin)
#Change variable types to factor
new_innerjoin$DC.Optimizer=as.factor(new_innerjoin$DC.Optimizer)
new_innerjoin$Ground.Mounted=as.factor(new_innerjoin$Ground.Mounted)

#Replace -9999 with NA in all columns
new_innerjoin$Module.Efficiency..1[new_innerjoin$Module.Efficiency..1== -9999] <- NA
new_innerjoin$System.Size[new_innerjoin$System.Size== -9999] <- NA
new_innerjoin$DC.Optimizer[new_innerjoin$DC.Optimizer== -9999] <- NA
new_innerjoin$annual_insolation[new_innerjoin$annual_insolation== -9999] <- NA
new_innerjoin$reported_annual_energy_prod[new_innerjoin$reported_annual_energy_prod== -9999] <- NA
new_innerjoin$Total.Installed.Price[new_innerjoin$Total.Installed.Price== -9999] <- NA
new_innerjoin$Ground.Mounted[new_innerjoin$Ground.Mounted== -9999] <- NA

apply(new_innerjoin,2,anyNA)
#Remove rows based on NAs in DC Optimizer, Ground Mounted & Reported_annual_energy_prod
new_innerjoin=new_innerjoin[-which(is.na(new_innerjoin$reported_annual_energy_prod)),]
new_innerjoin=new_innerjoin[-which(is.na(new_innerjoin$DC.Optimizer)),]
new_innerjoin=new_innerjoin[-which(is.na(new_innerjoin$Ground.Mounted)),]
#Replace NAs with means of the column for numerical variables
new_innerjoin$Module.Efficiency..1[is.na(new_innerjoin$Module.Efficiency..1)]=mean(new_innerjoin$Module.Efficiency..1,na.rm=TRUE)
new_innerjoin$annual_insolation[is.na(new_innerjoin$annual_insolation)]=mean(new_innerjoin$annual_insolation,na.rm=TRUE)
new_innerjoin$Total.Installed.Price[is.na(new_innerjoin$Total.Installed.Price)]=mean(new_innerjoin$Total.Installed.Price,na.rm=TRUE)

str(new_innerjoin)

#Reorder columns
new_innerjoin=new_innerjoin[c(1,2,3,4,6,7,5)] #Cleaned dataset

#Descriptive Statistics
summary(new_innerjoin)

#Check Outliers
boxplot(new_innerjoin$Module.Efficiency..1,ylab="Module Efficiency",main="Boxplot for Module Efficiency")
boxplot(new_innerjoin$System.Size,ylab="System Size",main="Boxplot for System Size")
boxplot(new_innerjoin$annual_insolation,ylab="Annual Insolation",main="Boxplot for Annual Insolation")
boxplot(new_innerjoin$Total.Installed.Price,ylab="Total Installed Price",main="Boxplot for Total Installed Price")
boxplot(new_innerjoin$reported_annual_energy_prod,ylab="Annual Energy Production",main="Boxplot for Annual Energy Production")
#Find and remove outliers in "Total.Installed.Price" and "reported_annual_energy_prod"
which.max(new_innerjoin$reported_annual_energy_prod)
which.max(new_innerjoin$Total.Installed.Price)
new_innerjoin=new_innerjoin[-c(3969,4477),]
which.max(new_innerjoin$Total.Installed.Price)
new_innerjoin=new_innerjoin[-4476,]
#Remove 3 rows
summary(new_innerjoin)

#Explanatory Analysis
reg_exp=lm(reported_annual_energy_prod~.,new_innerjoin)
summary(reg_exp)

#Evaluate each variable
#Histogram to check skewness
hist(new_innerjoin$Module.Efficiency..1)
hist(new_innerjoin$System.Size) #Highly skewed right
hist(new_innerjoin$annual_insolation)  
hist(new_innerjoin$Total.Installed.Price) #Highly skewed right

#Test skewness
library(e1071)
skewness(new_innerjoin$Module.Efficiency..1)
skewness(new_innerjoin$System.Size)
skewness(new_innerjoin$annual_insolation)
skewness(new_innerjoin$Total.Installed.Price)
#System.Size and Total.Installed.Price are highly skewed to the right that need to be transformed

#Choose to use log transformation for System.Size and Total.Installed.Price
new_innerjoin$System.Size=log(new_innerjoin$System.Size)
new_innerjoin$Total.Installed.Price=log(new_innerjoin$Total.Installed.Price)
#Check skewness again
hist(new_innerjoin$System.Size)
skewness(new_innerjoin$System.Size)
hist(new_innerjoin$Total.Installed.Price)
skewness(new_innerjoin$Total.Installed.Price)
#Still highly skewed
#Second round of transformation
#Choose to use square root transformation for System.Size
new_innerjoin$System.Size=(new_innerjoin$System.Size)^(1/2)
anyNA(new_innerjoin$System.Size) #Found NAs in transformed results
#Replace NAs with means
new_innerjoin$System.Size[is.na(new_innerjoin$System.Size)]=mean(new_innerjoin$System.Size,na.rm=TRUE)
#Check skewness again
hist(new_innerjoin$System.Size)
skewness(new_innerjoin$System.Size) #Ready
#Choose to use log transformation for Total.Installed.Price
new_innerjoin$Total.Installed.Price=log(new_innerjoin$Total.Installed.Price)
#Check skewness again
hist(new_innerjoin$Total.Installed.Price)
skewness(new_innerjoin$Total.Installed.Price)
#Still highly skewed: We decided to stop transformation here since it is already significantly better than the original data and more transformation will not significantly improve its normality
str(new_innerjoin)

#Change Variable Names
colnames(new_innerjoin)[1]="Module.Efficiency"
colnames(new_innerjoin)[4]="Annual.Insolation"
colnames(new_innerjoin)[7]="Annual.Energy.Prod"

#######################################################################################
###kNN REGRESSION###
#Change 2 binary categorical variables to numeric
new_innerjoin$DC.Optimizer=as.character(new_innerjoin$DC.Optimizer)
new_innerjoin$Ground.Mounted=as.character(new_innerjoin$Ground.Mounted)
new_innerjoin$DC.Optimizer=as.numeric(new_innerjoin$DC.Optimizer)
new_innerjoin$Ground.Mounted=as.numeric(new_innerjoin$Ground.Mounted)

#Split dataset
row=nrow(new_innerjoin)
set.seed(009) #set seed
trainIndex=sample(row,0.8*row) #80% of data are training
training=new_innerjoin[trainIndex,]
validation=new_innerjoin[-trainIndex,]

#Find best k
library("class")
accr_results=array(dim=c(1,10)) #Create an array to save the generated list

for(k in 1:10) {
  pred <- knn.cv(scale(new_innerjoin[,c(1:6)]),new_innerjoin[,7],k)
  accr_results[1,k] <- sum(new_innerjoin[,7]==pred)/nrow(new_innerjoin)
}

round(accr_results,3) #Rounded to 3 decimals
plot(accr_results[1,],xlab="k",ylab="Overall Accuracy",main="Accuracy for Different k",col="goldenrod1",pch=19,cex=1.5)
#k=1 is the most accurate
#Starting with k=1, also testing other k values

#kNN Regression Models with different k's
Pred_knn_1=FNN::knn.reg(train=training,test=validation,y=training$Annual.Energy.Prod,k=1)
Pred_knn_3=FNN::knn.reg(train=training,test=validation,y=training$Annual.Energy.Prod,k=3)
Pred_knn_5=FNN::knn.reg(train=training,test=validation,y=training$Annual.Energy.Prod,k=5)
Pred_knn_9=FNN::knn.reg(train=training,test=validation,y=training$Annual.Energy.Prod,k=9)
Pred_knn_11=FNN::knn.reg(train=training,test=validation,y=training$Annual.Energy.Prod,k=11)
Pred_knn_25=FNN::knn.reg(train=training,test=validation,y=training$Annual.Energy.Prod,k=25)
#Check accuracy
library("forecast")
accuracy(Pred_knn_1$pred,validation$Annual.Energy.Prod)
accuracy(Pred_knn_3$pred,validation$Annual.Energy.Prod)
accuracy(Pred_knn_5$pred,validation$Annual.Energy.Prod)
accuracy(Pred_knn_9$pred,validation$Annual.Energy.Prod)
accuracy(Pred_knn_11$pred,validation$Annual.Energy.Prod)
accuracy(Pred_knn_25$pred,validation$Annual.Energy.Prod)
#k=1 is the most accurate; however, we also use models with other k values for comparison with Linear regression and tree models

###IMPROVING PREDICTIVE PERFORMANCE OF KNN MODEL###
#Rescale training and validation separately
library("caret")
normParam=preProcess(training)
norm.training=predict(normParam,training)
norm.validation=predict(normParam,validation)

#kNN Regression on rescaled datasets
Pred_knn_1.=FNN::knn.reg(train=norm.training,test=norm.validation,y=norm.training$Annual.Energy.Prod,k=1)
Pred_knn_3.=FNN::knn.reg(train=norm.training,test=norm.validation,y=norm.training$Annual.Energy.Prod,k=3)
Pred_knn_5.=FNN::knn.reg(train=norm.training,test=norm.validation,y=norm.training$Annual.Energy.Prod,k=5)
Pred_knn_9.=FNN::knn.reg(train=norm.training,test=norm.validation,y=norm.training$Annual.Energy.Prod,k=9)
Pred_knn_11.=FNN::knn.reg(train=norm.training,test=norm.validation,y=norm.training$Annual.Energy.Prod,k=11)
Pred_knn_25.=FNN::knn.reg(train=norm.training,test=norm.validation,y=norm.training$Annual.Energy.Prod,k=25)
#Check accuracy for rescaled model
accuracy(Pred_knn_1.$pred,norm.validation$Annual.Energy.Prod)
accuracy(Pred_knn_3.$pred,norm.validation$Annual.Energy.Prod)
accuracy(Pred_knn_5.$pred,norm.validation$Annual.Energy.Prod)
accuracy(Pred_knn_9.$pred,norm.validation$Annual.Energy.Prod)
accuracy(Pred_knn_11.$pred,norm.validation$Annual.Energy.Prod)
accuracy(Pred_knn_25.$pred,norm.validation$Annual.Energy.Prod)