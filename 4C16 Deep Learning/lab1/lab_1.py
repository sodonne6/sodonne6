# Lab 1: Linear Regression (corresponding to lecture handout 1)
import numpy as np

# This function computes the polynomial of order 'order' corresponding to a least-squares fit
# to the data (x, y), where 'y' contains the observed values and 'x' contains the x-ordinate
# of each observed value.
#
# The normal equation is sloved in the function 'linear regression'.
def LS_poly(x, y, order, eps = 0):
    # First build the polynomial design matrix (relies only x-ordinates, not observed values)
    X = polynomial_design_matrix(x, order);
    # Then find the polynomial using this matrix and the values 'y'.
    w = linear_regression(X, y, eps=eps);
    return w

# Computes the polynomial design matrix.
#
# For a vector 'x', this contains all powers up to 'order'
# of each element of 'x'.  This kind of matrix is also called
# a Vandermonde matrix.
#
# The numpy array 'x' contains the x-ordinates (x-axis
# values) which we are analyzing.
def polynomial_design_matrix(x, order=1): #takes array of numbers and order 
    # Create a matrix of zeros, with 'length-of-x' rows and 'order+1' cols
    X = np.zeros(shape=(x.size,order+1))
  
    # EXERCISE 1: fill the body of this function.
    # See slide 26 of the lecture 1 handout.
    # The exponentiation (power) operator in Python is '**'.
    # Assign to the element (row,col) of a numpy matrix with: M[r,c] = <expression>`
    for j in range(x.size):
      for i in range(order+1):
        X[j,i]=x[j]**i;
    return X
    #iterate each row starting at i=0 take in first number of array and put it to the power i for each column
  	
    # Hint:
    # Outer loop: iterating over columns; each column gets a higher power
    # for p in range(0, order+1):
    # Inner loop: iterating over rows: each row corresponds to an element of 'x'
    # for i in range(x.size):
    # Element (i,p) of X should be the ith element of 'x' to the power p:

    #X[i,p] = <something>

    #return X


# Given values 'y' and the polynomial design matrix for the x-ordinates of those
# values in 'X', find the polynomial having the best fit:
#
# theta = ((X'X + I)^(-1))*X'y
#
# This uses numpy to solve the normal equation (see slide 16 of handout 1)
def linear_regression(X, y, eps=0):
    order = X.shape[1] - 1;
    M = np.dot(X.transpose(), X)

    # EXERCISE 2: implement Tikhonov regularisation.
    # See lecture handout 1, slide 38.
    # print("Eps: " + str(eps))
    # 
    # <add 'eps' times the identity matrix to M>
    M = M + eps * np.identity(M.shape[0])
    # Hints:
    # There is a function 'identity' in numpy to generate an identity matrix
    # The 'identity' function takes an integer parameter: the size of the (square) identity matrix
    # The shape of a numpy matrix 'A' is accessed with 'A.shape' (no parentheses); this is a tuple
    # The number of rows in a matrix 'A' is then 'A.shape[0]' (or 'len(A)')
    # You can add matrices with '+' -- so you will update 'M' with 'M = M + <amount> * <identity>'
    # Note that the amount of regularization is denoted 'alpha' in the slides but here it's 'eps'.
    theta = np.dot(np.linalg.inv(M), np.dot(X.transpose(), y))
    return theta

# EXERCISE 3: implement computation of mean squared error between two vectors
def mean_squared_error(y1, y2):
    # You can use '-' to compute the elementwise difference of numpy vectors (i.e. y1 - y2).
    difference = y1 - y2
    # You can use '**' for elementwise exponentiation of a numpy vector.
    squared_difference = difference**2
    # You can use the numpy function 'mean' to compute the mean of a vector.
    mse = np.mean(squared_difference)
    return mse  # replace this with your answer.

# EXERCISE 4: return the number of the best order for the supplied
# data (see the notebook).
def question_4():
 return 3 # prime example of overcomplicating things // didnt need to write all that
# max_order = 12  #example of how many orders to test in the loop - subject to change
# order_mse = []  #define as an empty array in which we will store each mse order 
#
# for order in range(1,max_order+1): #iterate through orders from 1 to max_order+1(12+1)
#   #fit a polynomial for the test data at the current value of order
#   w = LS_poly(training_x, training_y,order)
#   #evaluate model for test and training data for the given order
#   training_pred = np.dot(polynomial_design_matrix(training_x, order),w)
#   test_pred = np.dot(polynomial_design_matrix(test_x, order),w)
#
#   #calculate the mse 
#   mse_test = mean_squared_error(test_y,test_pred)
#
#   #store this value in the array 
#   order_mse.append(mse_test)
#
# #sort from lowest to highest mse 
# min_max = np.argmin(order_mse) + 1
#
# return min_max   # replace '0' with your answer.
#
#use this same function for both plots
#def plot_mse_vs_order_train_vs_test(training_x,training_y,eval_x,eval_y):
#  max_order = 10
#  mse_train = [] #empty array to store values 
#  mse_eval = [] #empty array to store values
#
#  #iterate through orders
#  for order in range(1, max_order + 1):
#    #fit the polynomial at the current value of order 
#    w = LS_poly(training_x,training_y,order)
#
#    #calculate predictions for training set and evaluation set
#    train_pred = np.dot(polynomial_design_matrix(training_x,order),w)
#    eval_pred = np.dot(polynomial_design_matrix(eval_x,order),w)
#
#    mse_train.append(mean_squared_error(training_y,train_pred))
#    mse_eval.append(mean_squared_error(eval_y,eval_pred))
#
#  #plot the MSE vs polynomial order for training and evaluation sets
#  orders = range(1, max_order + 1)
#  plt.figure(figsize=(8,6))
#  plt.plot(orders,mse_train,label='Training MSE',marker ='o')
#  plt.title('MSE vs Polynomial Order')
#  plt.xlabel('Polynomial Order')
#  plt.ylabel('MSE')
#  plt.legend()
#  plt.grid(True)
#  plt.show()
#  
#
#
#
#
#