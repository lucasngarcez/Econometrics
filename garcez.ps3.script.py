# Loading matrix algebra and statistical packages
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
import statsmodels.formula.api as smf
# Setting up the LaTeX file where the tables will be printed
beginningtex = """\\documentclass{report}
\\usepackage{booktabs}
\\begin{document}"""
endtex = "\end{document}"
# Loading Data
SampleData=pd.read_stata('C:\Sample1_Data.dta')
# Dropping varables with missing gender
SampleData=SampleData.dropna(subset=['male'])
# Substituting missing continuous variables by the mean
SampleData=SampleData.fillna(SampleData.mean())
# Running the regression for math grades using 3 different methods. One of them sends the output to LaTeX
dependent=pd.DataFrame(SampleData['mathgrade2'])
independent=pd.DataFrame(SampleData.drop(['mathgrade2','verbalgrade2'],axis=1))
independent=SampleData[['grit','male','raven','mathscore1','verbalscore1','belief_survey1','grit_survey1','csize']]
# Method 1: Using the linear regression from sklearn library
model = LinearRegression().fit(independent,dependent)
print('Intercept:', model.intercept_)
print('Slope:', model.coef_)
# Method 2: Using the OLS from statsmodels library
mod = smf.ols('dependent ~ independent', data=SampleData)
res = mod.fit()
print(res.summary())
f = open('C:\myreg.tex', 'w')
f.write(beginningtex)
f.write(res.summary().as_latex())
f.close()
# Method 3: Using Matrix algebra, i.e. creating a vector of ones for the intercept, adding other regressors, calculate beta=inv(X'X)X' and multiply it by math grade
Y=dependent
i=0
X=[]
while i<len(Y):
	X.append(1)
	i=i+1
X=np.matrix(X)
X=X.transpose()
X=pd.DataFrame(X,SampleData[['grit','male','raven','mathscore1','verbalscore1','belief_survey1','grit_survey1','csize']])
X=np.matrix(X)
Xprime=X.transpose()
beta=np.linalg.inv(np.dot(Xprime,X))
beta=np.dot(beta,Xprime)
beta_math=np.dot(beta,Y)
# Running the regression for verbal grades
dependent=pd.DataFrame(SampleData['verbalgrade2'])
# Method 1: Same as above, but with the verbal grade
model = LinearRegression().fit(independent,dependent)
print('Intercept:', model.intercept_)
print('Slope:', model.coef_)
# Method 2: Same as above, but with the verbal grade
mod = smf.ols('dependent ~ independent', data=SampleData)
res = mod.fit()
print(res.summary())
f = open('C:\myreg.tex', 'w')
f.write(res.summary().as_latex())
f.write(endtex)
f.close()
# Method 3: Matrix algebra. Because we already built the matrix inv(X'X)X' we just have to multiply it by the new dependent variable
Y=dependent
beta_verbal=np.dot(beta,Y)
















#Question 8
#Creating the matrices
#y=np.matrix([[150],[18],[41],[20],[7]])
#xprime=np.matrix([[21,5,1],[13,2,1],[15,4,1],[10,3,1],[8,2,1]])
##Transposing x'
#x=xprime.transpose()
##Verifying that our variables are correct
#print("x="+str(x))
#print("xprime="+str(xprime))
#print("y="+str(y))
##Calculating coefficients manually with inv(xx')xy:
#beta=np.dot(np.linalg.inv(np.dot(x,xprime)),np.dot(x,y))
#print("Manual calculation of the beta vector:")
#print(beta)
##Redifining Matrices as Data Frames
#independent=pd.DataFrame(xprime)
#dependent=pd.DataFrame(y)
##Estimating the model
#model = LinearRegression().fit(independent,dependent)
##Printing the intercept and the slopes
#print("Using libarary to calculate the beta vector:")
#print('intercept:', model.intercept_)
#print('slope:', model.coef_)
##Calculating projection matrix P
#P=np.dot(xprime,np.dot(np.linalg.inv(np.dot(x,xprime)),x))
##Calculating matrix M
#M=np.identity(5)-P
#MM=np.dot(M,M)
##Verifying it is idempotent
#print("Matrix M:")
#print(M)
#print("Matrix MM:")
#print(MM)
#print("Test if M = MM:")
#print(np.array_equal(np.round(M,2),np.round(MM,2)))
##Showing that the residuals are obtained by M
#print("Residuals obtained with M:")
#print(np.dot(M,y))
#print("Residuals obtained with beta vector:")
#print(y-np.dot(xprime,beta))
#print("Test if the residuals are the same:")
#print(np.array_equal(np.round(np.dot(M,y),2),np.round(y-np.dot(xprime,beta),2)))
##Defining the partitioned matrices
#x1=np.delete(x,2,0)
#x1=np.delete(x1,1,0)
#print("First partitioned matrix:")
#print(x1)
#x2=np.delete(x,0,0)
#print("Second partitioned matrix:")
#print(x2)
##Creating the projection matrix P2 for x2
#P2=np.dot(x2.transpose(),np.dot(np.linalg.inv(np.dot(x2,x2.transpose())),x2))
##Projecting and calculating residuals
#x1hat=np.dot(x1,P2)
#u1=x1-x1hat
#print("Residuals obtained by using the projection:")
#print(u1)
##We project x1 this way because it was defined as row vector
##Confirming that it yields the same beta
#print("Beta obtained from the residuals:")
#print(np.dot(u1,y)/np.dot(u1,u1.transpose()))
#print("Beta previously obtained:")
#print(beta[0])
##Question 9
#ABE2019 = pd.read_csv('C:\ABE2019.csv')
#print("Opening the data set:")
#print(ABE2019)
##Note1: To iterate over the observations use "for elem in ABE2019.iterrows():"
##Note2: To access a particular observation of number "n" use "ABE2019.ix[n]"
##Note3: To drop observations with missing values use: ".dropna(inplace=True)"
##Calculating the number of missing values
#print("Number of missing values for grit_survey1:")
#print(ABE2019['grit_survey1'].isnull().values.ravel().sum())
#print("Number of missing values for belief_survey1:")
#print(ABE2019['belief_survey1'].isnull().values.ravel().sum())
##Substituting missing values by the mean and separating treatment and control
#print("Substituting missing values by the mean:")
#ABE2019.fillna(ABE2019.mean())
#print(ABE2019.fillna(ABE2019.mean()))
#sample1_treatment = ABE2019['treatment'] == 1
#sample1_treatment = ABE2019[sample1_treatment]
#sample1_control = ABE2019['treatment'] == 0
#sample1_control = ABE2019[sample1_control]
##Calculating descriptive statistics as in Table 2
#print("Descriptive statistics of grit survey and belief survey for treatment:")
#print(sample1_treatment['grit_survey1'].describe(percentiles=None))
#print(sample1_treatment['belief_survey1'].describe(percentiles=None))
#print("Descriptive statistics of grit survey and belief survey for control:")
#print(sample1_control['grit_survey1'].describe(percentiles=None))
#print(sample1_control['belief_survey1'].describe(percentiles=None))
##Calculating the ranges
#print("grit_survey1 range:")
#print(ABE2019['grit_survey1'].max())
#print(ABE2019['grit_survey1'].min())
#print("belief_survey1 range:")
#print(ABE2019['belief_survey1'].max())
#print(ABE2019['belief_survey1'].min())
#