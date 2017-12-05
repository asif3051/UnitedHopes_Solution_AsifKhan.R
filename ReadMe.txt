Code Explanation:

R PAckages Installed: CAtools: For divinding the dataset into train and test data sets,and using them to train and validadate the the model performance
						in terms of accuracy,sensitivity and specificity
					RTextTools: Package used for text classification.It  offers 9 different algorithms. 
					SVM has been used for this use case.Reason to use SVM algorithm over other algorithms:
					Reson1: Text data when converted into Document Term frequenc Matirx, usually have very high number of dimensions because each token 
					
					becomes a column. SVMs have their ability to learn independent of the dimensionality of the featue space.SVMs measure the complexity of the hypothesis based on the margin,planes which they use to separate the data,not the features.
					
					Reason2: This algorithm does not depands on number of features, hence become more suitable to handle large text feature space.
					Reason3:Most text categorization problems(text data) are linearly separable.SVM works to find the best planes that ca separate this text data.

					Caret:This package is used to generate the confusion Matrix.
					
					
1.Read the data file using read.csv() function.
fulldata <- read.csv("D:\\Analytics\\UnitedHopes\\train.csv", na=c('NA',''))
While reading, replace all blank spaces with NA

2.Divide the data in train and test sets()train2,test2 in the code).Change the type of column breadcrumbs to character and label to factors
Drop the other colums and keep only breadcrumbs and labels.
Reason: Since the evaluation data(production data) has no data in most of the columns like StoreID,AdditionalAttributes,url ,it would not be good to train the model 
using these columns. As we have to predict the type of the label, we can use only breadbrumbs column which has sufficient data in train and evaluation dataset as well.Also, the data in
breadcrumbs column looks most important to train the model as it has the most meaningful text which we would want our model to learn.
 
3.As we are left with  only breadcrumbs,we can remove the rows which has a blank/NA in the breadcrumbs column. We can omit them because we have enough volume of text to train our model.
For evaluation set, the blank/NAs will be predicted as rest.

4.Use create_matrix function to create a document Term Frequency Matrix on breadcrumbs text.
cm_train2 <- create_matrix(textColumns = train2[,c("breadcrumbs")],removePunctuation = TRUE)

5.In order to train the SVM model with RTextTools package, we need to put the Document Term Frequency Matrix in a container.
Inside the container's configuration, we indicate the whole in the train dataset will be used for training.

container_train <- create_container(matrix = cm_train2,labels = train2$label,trainSize = 1:nrow(train2),virgin = TRUE )

6.Train the model on the container created in step 5 and specifying SVM as the algorithm to be used.
trm2 <- train_model(container = container_train,algorithm = "SVM",kernel = "linear")

7.Now the model is trained, create a document term frequency matrix on test data. Use the training document term frequency matrix and provide it
as a parameter in the create_matrix function used to create DTFM on test data.
Reason for providing the training data DTFM as parameter is that we want the test data DTFM to be created on the same seemantics/vocabulary.
This will keep the train and test data in same semantic space which the model understands.

cm_test2 <- create_matrix(test2, originalMatrix=cm_train2)


8.Create container on test data DTFM
container_test <- create_container(matrix = cm_test2,labels = rep(0,l_test),testSize=1:l_test,virgin=FALSE)

9.Use the model to make predictions now. Output of the prediction is assigned to the object 'output' which contains
the predicted lable and its associated probability.Use output[,1] to access just the predicted labels.
output <- classify_model(container = container_test,model = trm2)

Create the  confusion matrix for the predictin VS real label values.Check the acuracy level.
confusionMatrix(data = output[,1],reference = test2$label)

Perform the same steps,steps no 7 to 9 on evaluation dataset and check the predictions. Model has made very acuurate predictions.


Challenges Faced with the use case:
1. Most of the rows in the evaluation set are not complete. This made it difficult to impute the blank values in breadcrumbs field by 
analyziing the other fields. 
2. Since the data type here is text, model selection become more important as the model should be able to handle the 
high number of features and deliver more accuracy.

To Overcome the challenges:
1. created model on data with and without the blank values in the breadcrubs field. Later one worked better.
2.Imputations were also not made in the train data as the text in breadcrumbs was sufficientand clean  enough to train the model.
3. Also tested by creating the RandomForest model.Due to its dependence on number of features, SVD had to be applied before training
the model. SVD generated high level columns are approximations of the real columns in the DTFM. It generated predictions with less accuracy.


How to run the code:
1.R(3.4.2) and RStudio should be installed. 
2.Open the script in Rstudio.
3.In the first line of the code, there is a method setwd(), enter the location of train.csv file . Output files will also be written in this folder.
Notes: 
#Code line numer 43 throws error due to a bug in package.To fix the problem,run line numer 45.This pops up a new window with code.In the code,at line numer 42,change the name of the string 'Acronym' to 'acronym'.Save and
#run line 43 again and then rest of the code,
# Due to memory limits of my machine, I have taken 100000 sample rows for trainig model and 20000 rows for validating it. And From the evaluation file, only 5000 rows have been takeen. This can be changed when using a better configuration machine.

