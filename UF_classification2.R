setwd("D:/Analytics/UnitedHopes")

install.packages(c("caTools", "RTextTools", "caret"))

library("caTools" )
library("RTextTools")
library("caret")

fulldata <- read.csv("train.csv", na=c('NA',''))
eval <- read.csv("evaluation.csv", na=c('NA',''),stringsAsFactors = FALSE)

smpl <- sample.split(fulldata$label,SplitRatio = 0.7)
train2 <- subset(fulldata,smpl==TRUE)
test2 <- subset(fulldata,smpl==FALSE)


#taking smaller sample size sue to memory limitations of the computer.
#Also,subsetting data to keep only BreadCrumbs and Label columns
train2 <- train2[1:100000,c(4,5)]
test2 <- test2[100000:120000,c(4,5)]

#Using SVM
#train(train$breadcrumbs)
train2$breadcrumbs <- as.character(train2$breadcrumbs)
train2$label <- as.factor(train2$label)
#step1
train2 <- na.omit(train2)
nrow(train2)


levels(train2$label)
#colSums(is.na(train2))

cm_train2 <- create_matrix(textColumns = train2[,c("breadcrumbs")],removePunctuation = TRUE)
container_train <- create_container(matrix = cm_train2,labels = train2$label,trainSize = 1:nrow(train2),virgin = TRUE )
trm2 <- train_model(container = container_train,algorithm = "SVM",kernel = "linear")


str(test2)
test2$breadcrumbs <- as.character(test2$breadcrumbs)
test2$label <- as.factor(test2$label)

cm_test2 <- create_matrix(test2, originalMatrix=cm_train2)

trace("create_matrix", edit=T)
#Code line numer 43 throws error due to a bug in package.To fix the problem,run line numer 45.This opens a code.In the line numer 42 of that code,change the name of the string 'Acronym' to 'acronym'.Save and
#run line 43 again and then rest of the code,
l_test <- nrow(test2)
container_test <- create_container(matrix = cm_test2,labels = rep(0,l_test),testSize=1:l_test,virgin=FALSE)
output <- classify_model(container = container_test,model = trm2)


validate <- data.frame(test2,predicted_label=output[,1])
#View(validate)
confM <- confusionMatrix(data = output[,1],reference = test2$label)
write.csv(validate,"test_submission.csv")



#names(eval)
eval <- eval$breadcrumbs
eval <- na.omit(eval)

#using only 500 rows due to memory limitation of my computer machine.To take all the rows,comment line 65
eval <- eval[1:5000]

# class(eval)
# length(eval)
# class(eval)
# head(eval)
eval_m <- create_matrix(textColumns = eval,originalMatrix = cm_train2)
eval_c <- create_container(matrix = eval_m,labels = rep(0,length(eval)),testSize = 1:length(eval),virgin = TRUE)
output_eval <- classify_model(container = eval_c,model = trm2)
#output_eval$SVM_LABEL

validation_evaluationdata <- data.frame(evalBreadcrumbs=eval,predicted_label=output_eval$SVM_LABEL)
#View(validation_evaluationdata)

write.csv(validation_evaluationdata,"evaluation_submission.csv")
confM

#code will finish with genetating two files in the directory that was used as parameter in the first line of code;setw().Also please check last lies of the console to see accuracy.