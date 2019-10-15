print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Problem Set 3 - Lucas Garcez - Output<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")
#Loading matrix algebra, statistical and plot packages
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.formula.api as smf
from sklearn.linear_model import LinearRegression
from io import StringIO
from random import random
# Setting up the LaTeX file where the tables will be printed
beginningtex = """\\documentclass{report}
\\usepackage{booktabs}
\\begin{document}"""
endtex = "\end{document}"
# Loading Data
# os.chdir(r"C:\")
SampleData_Math=pd.read_stata('C:\Sample1_Data.dta')
SampleData_Verbal=pd.read_stata('C:\Sample1_Data.dta')
# Dropping varables with missing outcome
SampleData_Math=SampleData_Math.dropna(subset=['mathgrade2'])
SampleData_Verbal=SampleData_Verbal.dropna(subset=['verbalgrade2'])
# Replace missing gender by zero 
SampleData_Math['male']=SampleData_Math['male'].fillna(0)
SampleData_Verbal['male']=SampleData_Verbal['male'].fillna(0)
# Substituting missing continuous variables by the mean
SampleData_Math=SampleData_Math.fillna(SampleData_Math.mean())
SampleData_Verbal=SampleData_Verbal.fillna(SampleData_Verbal.mean())
# Calculating the mean of the outcomes for treatment and control groups
mean_math = SampleData_Math.groupby('grit')['mathgrade2'].mean()
mean_verbal = SampleData_Verbal.groupby('grit')['verbalgrade2'].mean()
print(mean_math)
print(mean_verbal)
# Running the regression for math grades using 3 different methods. One of them sends the output to LaTeX
dependent=pd.DataFrame(SampleData_Math['mathgrade2'])
independent=SampleData_Math[['grit','male','raven','mathscore1','verbalscore1','belief_survey1','grit_survey1','csize']]
# Method 1: Using the linear regression from sklearn library
model = LinearRegression().fit(independent,dependent)
print('Intercept:', model.intercept_)
print('Slope:', model.coef_)
# Method 2: Using the OLS from statsmodels library 
mod = smf.ols('mathgrade2 ~ grit + male + raven + mathscore1 + verbalscore1 + belief_survey1 + grit_survey1 + csize', data=SampleData_Math)
res = mod.fit()
print(res.summary())
f = open('C:\Table1.tex', 'w')
f.write(beginningtex)
f.write(res.summary().as_latex())
f.close()
# Method 3: Using Matrix algebra, i.e. creating a vector of ones for the intercept, adding other regressors, calculate beta=inv(X'X)X' and multiply it by math grade
SampleData_Math['intercept'] = pd.Series(1, index=SampleData_Math.index)
columns=['intercept','grit','male','raven','mathscore1','verbalscore1','belief_survey1','grit_survey1','csize']
X=pd.DataFrame(index=SampleData_Math.index, columns=columns)
X['intercept'] = SampleData_Math['intercept']
X['grit'] = SampleData_Math['grit']
X['male'] = SampleData_Math['male']
X['raven'] = SampleData_Math['raven']
X['mathscore1'] = SampleData_Math['mathscore1']
X['verbalscore1'] = SampleData_Math['verbalscore1']
X['belief_survey1'] = SampleData_Math['belief_survey1']
X['grit_survey1'] = SampleData_Math['grit_survey1']
X['csize'] = SampleData_Math['csize']
Ymath=SampleData_Math['mathgrade2'].values
X=X.values
X=np.matrix(X)
Xprime=X.transpose()
beta=np.dot(Xprime,X)
beta=np.dot(np.linalg.inv(beta),Xprime)
beta_math=np.dot(beta,Ymath)
print('Intercept and Coefficients for Math:',beta_math)
# Running the regression for verbal grades
dependent=pd.DataFrame(SampleData_Verbal['verbalgrade2'])
independent=SampleData_Verbal[['grit','male','raven','mathscore1','verbalscore1','belief_survey1','grit_survey1','csize']]
# Method 1: Same as above, but with the verbal grade
model = LinearRegression().fit(independent,dependent)
print('Intercept:', model.intercept_)
print('Slope:', model.coef_)
# Method 2: Same as above, but with the verbal grade
mod = smf.ols('verbalgrade2 ~ grit + male + raven + mathscore1 + verbalscore1 + belief_survey1 + grit_survey1 + csize', data=SampleData_Verbal)
res = mod.fit()
print(res.summary())
f = open('C:\Table2.tex', 'w')
f.write(beginningtex)
f.write(res.summary().as_latex())
f.write(endtex)
f.close()
# Method 3: Matrix algebra
SampleData_Verbal['intercept'] = pd.Series(1, index=SampleData_Verbal.index)
columns=['intercept','grit','male','raven','mathscore1','verbalscore1','belief_survey1','grit_survey1','csize']
X=pd.DataFrame(index=SampleData_Verbal.index, columns=columns)
X['intercept'] = SampleData_Verbal['intercept']
X['grit'] = SampleData_Verbal['grit']
X['male'] = SampleData_Verbal['male']
X['raven'] = SampleData_Verbal['raven']
X['mathscore1'] = SampleData_Verbal['mathscore1']
X['verbalscore1'] = SampleData_Verbal['verbalscore1']
X['belief_survey1'] = SampleData_Verbal['belief_survey1']
X['grit_survey1'] = SampleData_Verbal['grit_survey1']
X['csize'] = SampleData_Verbal['csize']
Yverbal=SampleData_Verbal['verbalgrade2'].values
X=X.values
X=np.matrix(X)
Xprime=X.transpose()
beta=np.dot(Xprime,X)
beta=np.dot(np.linalg.inv(beta),Xprime)
beta_verbal=np.dot(beta,Yverbal)
print('Intercept and Coefficients for Verbal:',beta_verbal)
# Two-step regression following FWL
SampleData_Math['intercept'] = pd.Series(1, index=SampleData_Math.index)
grit=SampleData_Math['grit']
columns=['intercept','male','raven','mathscore1','verbalscore1','belief_survey1','grit_survey1','csize']
X=pd.DataFrame(index=SampleData_Math.index, columns=columns)
X['intercept'] = SampleData_Math['intercept']
X['male'] = SampleData_Math['male']
X['raven'] = SampleData_Math['raven']
X['mathscore1'] = SampleData_Math['mathscore1']
X['verbalscore1'] = SampleData_Math['verbalscore1']
X['belief_survey1'] = SampleData_Math['belief_survey1']
X['grit_survey1'] = SampleData_Math['grit_survey1']
X['csize'] = SampleData_Math['csize']
Y=SampleData_Math['mathgrade2'].values
X=X.values
grit=grit.values
grit=np.matrix(grit)
Y=np.matrix(Y)
X=np.matrix(X)
Y=Y.transpose()
# Finding the residuals from the regression of mathgrade2 on controls
Xprime=X.transpose()
P=np.dot(Xprime,X)
P=np.dot(np.linalg.inv(P),Xprime)
P=np.dot(X,P)
M=np.identity(len(P))-P
Res1_math=np.dot(M,Y)
# Finding the residuals from the regression of grit on controls
Res2_math=np.dot(M,grit.transpose())
# Regressing the first residuals on the second
X=Res2_math
Y=Res1_math
Xprime=X.transpose()
beta_FWL=np.dot(Xprime,X)
beta_FWL=np.dot(np.linalg.inv(beta_FWL),Xprime)
beta_FWL=np.dot(beta_FWL,Y)
# Verifying that the coefficients are the same
beta_FWL=round(beta_FWL.item(0,0),8)
beta_FWL_math=beta_FWL
beta_math=round(beta_math.item(0,1),8)
print("Original Coefficient (mathgrade2):",beta_math)
print("FWL Coefficient (mathgrade2):",beta_FWL_math)
assert beta_FWL_math == beta_math
f = open('C:\Table3A.tex', 'w')
f.write(beginningtex)
f.write(str(beta_FWL_math))
f.write(endtex)
f.close()
# Doing the same for the verbal outcome
SampleData_Verbal['intercept'] = pd.Series(1, index=SampleData_Verbal.index)
grit=SampleData_Verbal['grit']
columns=['intercept','male','raven','mathscore1','verbalscore1','belief_survey1','grit_survey1','csize']
X=pd.DataFrame(index=SampleData_Verbal.index, columns=columns)
X['intercept'] = SampleData_Verbal['intercept']
X['male'] = SampleData_Verbal['male']
X['raven'] = SampleData_Verbal['raven']
X['mathscore1'] = SampleData_Verbal['mathscore1']
X['verbalscore1'] = SampleData_Verbal['verbalscore1']
X['belief_survey1'] = SampleData_Verbal['belief_survey1']
X['grit_survey1'] = SampleData_Verbal['grit_survey1']
X['csize'] = SampleData_Verbal['csize']
Y=SampleData_Verbal['verbalgrade2'].values
X=X.values
grit=grit.values
grit=np.matrix(grit)
Y=np.matrix(Y)
X=np.matrix(X)
Y=Y.transpose()
Xprime=X.transpose()
P=np.dot(Xprime,X)
P=np.dot(np.linalg.inv(P),Xprime)
P=np.dot(X,P)
M=np.identity(len(P))-P
Res2_verbal=np.dot(M,grit.transpose())
X=Res2_verbal
Res1_verbal=np.dot(M,Y)
Xprime=X.transpose()
beta_FWL_verbal=np.dot(Xprime,X)
beta_FWL_verbal=np.dot(np.linalg.inv(beta_FWL_verbal),Xprime)
beta_FWL_verbal=np.dot(beta_FWL_verbal,Y)
beta_FWL_verbal=round(beta_FWL_verbal.item(0,0),8)
beta_verbal=round(beta_verbal.item(0,1),8)
print("Original Coefficient (verbalgrade2):",beta_verbal)
print("FWL Coefficient (verbalgrade2):",beta_FWL_verbal)
assert beta_FWL_verbal == beta_verbal
f = open('C:\Table3B.tex', 'w')
f.write(beginningtex)
f.write(str(beta_FWL_verbal))
f.write(endtex)
f.close()
# Verifying that the residuals are the same for Math
mod = smf.ols('mathgrade2 ~ grit + male + raven + mathscore1 + verbalscore1 + belief_survey1 + grit_survey1 + csize', data=SampleData_Math)
res = mod.fit()
fitted=np.dot(Res2_math,beta_FWL_math)
Res3=Res1_math-fitted
ResOLS=res.resid
ResOLS=np.matrix(ResOLS)
ResOLS=ResOLS.transpose()
Res3=np.round(Res3,decimals=8)
ResOLS=np.round(ResOLS,decimals=8)
print("Original residuals (mathgrade2):",ResOLS)
print("FWL residuals (mathgrade2):",Res3)
assert Res3.all() == ResOLS.all()
# Verifying that the residuals are the same for verbal
mod = smf.ols('verbalgrade2 ~ grit + male + raven + mathscore1 + verbalscore1 + belief_survey1 + grit_survey1 + csize', data=SampleData_Verbal)
res = mod.fit()
fitted=np.dot(Res2_verbal,beta_FWL_verbal)
Res3=Res1_verbal-fitted
ResOLS=res.resid
ResOLS=np.matrix(ResOLS)
ResOLS=ResOLS.transpose()
Res3=np.round(Res3,decimals=8)
ResOLS=np.round(ResOLS,decimals=8)
print("Original residuals (verbalgrade2):",ResOLS)
print("FWL residuals (verbalgrade2):",Res3)
assert Res3.all() == ResOLS.all()
# Calculating R2 Manually for mathgrade2
mod = smf.ols('mathgrade2 ~ grit + male + raven + mathscore1 + verbalscore1 + belief_survey1 + grit_survey1 + csize', data=SampleData_Math)
res = mod.fit()
RSS=np.multiply(res.resid,res.resid)
RSS=RSS.sum()
Y=np.matrix(SampleData_Math['mathgrade2'].values)
TSS=Y-np.mean(Y)
TSS=np.multiply(TSS,TSS)
TSS=TSS.sum()
R2=1-(RSS/TSS)
R2=round(R2,7)
# Calculating R2 Automatically for mathgrade2
R2OLS=res.rsquared
R2OLS=round(R2OLS,7)
# Comparing for mathgrade2
print("Automatic R-Squared (mathgrade2):",R2OLS)
print("Manual R-Squared (mathgrade2):",R2)
assert R2OLS == R2
# Doing the same calculation for verbalgrade2
mod = smf.ols('verbalgrade2 ~ grit + male + raven + mathscore1 + verbalscore1 + belief_survey1 + grit_survey1 + csize', data=SampleData_Verbal)
res = mod.fit()
RSS=np.multiply(res.resid,res.resid)
RSS=RSS.sum()
Y=np.matrix(SampleData_Verbal['verbalgrade2'].values)
TSS=Y-np.mean(Y)
TSS=np.multiply(TSS,TSS)
TSS=TSS.sum()
R2=1-(RSS/TSS)
R2=round(R2,7)
R2OLS=res.rsquared
R2OLS=round(R2OLS,7)
print("Automatic R-Squared (verbalgrade2):",R2OLS)
print("Manual R-Squared (verbalgrade2):",R2)
assert R2OLS == R2
# Calculating leverage values and M* matrix
SampleData_Math['intercept'] = pd.Series(1, index=SampleData_Math.index)
columns=['intercept','grit','male','raven','mathscore1','verbalscore1','belief_survey1','grit_survey1','csize']
X=pd.DataFrame(index=SampleData_Math.index, columns=columns)
X['intercept'] = SampleData_Math['intercept']
X['grit'] = SampleData_Math['grit']
X['male'] = SampleData_Math['male']
X['raven'] = SampleData_Math['raven']
X['mathscore1'] = SampleData_Math['mathscore1']
X['verbalscore1'] = SampleData_Math['verbalscore1']
X['belief_survey1'] = SampleData_Math['belief_survey1']
X['grit_survey1'] = SampleData_Math['grit_survey1']
X['csize'] = SampleData_Math['csize']
Y=SampleData_Math['mathgrade2'].values
X=X.values
Y=np.matrix(Y)
X=np.matrix(X)
Y=Y.transpose()
Xprime=X.transpose()
P=np.dot(Xprime,X)
P=np.dot(np.linalg.inv(P),Xprime)
P=np.dot(X,P)
#print("Projection Matrix (mathgrade2):",P)
leverage_math=P.diagonal()
leverage_math=np.array(leverage_math)
#print("Leverage_math Values:",leverage_math)
Mstar=np.diag(leverage_math[0])
Mstar=np.identity(len(leverage_math[0]))-Mstar
Mstar=np.linalg.inv(Mstar)
#print("Mstar:",Mstar)
# Calculating residual difference for mathgrade2
mod = smf.ols('mathgrade2 ~ grit + male + raven + mathscore1 + verbalscore1 + belief_survey1 + grit_survey1 + csize', data=SampleData_Math)
res = mod.fit()
one_out_res=np.dot(Mstar,res.resid)
math_residual_diff=res.resid-one_out_res
# Calculating residual difference for verbalgrade2
SampleData_Math['intercept'] = pd.Series(1, index=SampleData_Verbal.index)
columns=['intercept','grit','male','raven','mathscore1','verbalscore1','belief_survey1','grit_survey1','csize']
X=pd.DataFrame(index=SampleData_Verbal.index, columns=columns)
X['intercept'] = SampleData_Verbal['intercept']
X['grit'] = SampleData_Verbal['grit']
X['male'] = SampleData_Verbal['male']
X['raven'] = SampleData_Verbal['raven']
X['mathscore1'] = SampleData_Verbal['mathscore1']
X['verbalscore1'] = SampleData_Verbal['verbalscore1']
X['belief_survey1'] = SampleData_Verbal['belief_survey1']
X['grit_survey1'] = SampleData_Verbal['grit_survey1']
X['csize'] = SampleData_Verbal['csize']
Y=SampleData_Verbal['verbalgrade2'].values
X=X.values
Y=np.matrix(Y)
X=np.matrix(X)
Y=Y.transpose()
Xprime=X.transpose()
P=np.dot(Xprime,X)
P=np.dot(np.linalg.inv(P),Xprime)
P=np.dot(X,P)
#print("Projection Matrix (verbalgrade2):",P)
leverage_verbal=P.diagonal()
leverage_verbal=np.array(leverage_verbal)
#print("Leverage_verbal Values:",leverage_verbal)
Mstar=np.diag(leverage_verbal[0])
Mstar=np.identity(len(leverage_verbal[0]))-Mstar
Mstar=np.linalg.inv(Mstar)
#print("Mstar:",Mstar)
mod = smf.ols('verbalgrade2 ~ grit + male + raven + mathscore1 + verbalscore1 + belief_survey1 + grit_survey1 + csize', data=SampleData_Verbal)
res = mod.fit()
one_out_res=np.dot(Mstar,res.resid)
verbal_residual_diff=res.resid-one_out_res
# Plotting Residual difference against leverage values
math_residual_diff=np.array(np.absolute(math_residual_diff))
verbal_residual_diff=np.array(np.absolute(verbal_residual_diff))
leverage_math=np.array(leverage_math)
leverage_math=leverage_math[0]
leverage_verbal=np.array(leverage_verbal)
leverage_verbal=leverage_verbal[0]
fig = plt.figure()
ax = plt.subplot(111)
# Math Grade Plot
ax.scatter(leverage_math, math_residual_diff, alpha=0.5, label='y = Difference between residuals (absolute value)')
plt.title('Leverage Values and Difference Between Residuals (Math Grades)')
ax.legend()
fig.savefig('C:\Graph1.png')
fig = plt.figure()
ax = plt.subplot(111)
# Verbal Grade Plot
ax.scatter(leverage_verbal, verbal_residual_diff, alpha=0.5, label='y = Difference between residuals (absolute value)')
plt.title('Leverage Values and Difference Between Residuals (Verbal Grades)')
ax.legend()
fig.savefig('C:\Graph2.png')
# Creating the random variable Bananas
SampleData_Math['bananas']=pd.DataFrame(10*np.random.random_sample((2574, 1)))
#print(SampleData_Math)
SampleData_Verbal['bananas']=pd.DataFrame(10*np.random.random_sample((2574, 1)))
#print(SampleData_Verbal)
# Running the regression for math and writing the table
mod = smf.ols('mathgrade2 ~ grit + bananas + male + raven + mathscore1 + verbalscore1 + belief_survey1 + grit_survey1 + csize', data=SampleData_Math)
res = mod.fit()
f = open('C:\Table4.tex', 'w')
print(res.summary())
f.write(beginningtex)
f.write(res.summary().as_latex())
f.write(endtex)
f.close()
# Running the regression for verbal and writing the table
mod = smf.ols('verbalgrade2 ~ grit + bananas + male + raven + mathscore1 + verbalscore1 + belief_survey1 + grit_survey1 + csize', data=SampleData_Verbal)
res = mod.fit()
print(res.summary())
f = open('C:\Table5.tex', 'w')
f.write(beginningtex)
f.write(res.summary().as_latex())
f.write(endtex)
f.close()


