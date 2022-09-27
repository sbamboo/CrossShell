# Simple calculator Allowing for the use of Addition, Subtraction, Multiplication, Division, FloorDivision and Exponents.
# Written by: Simon Kalmi Claesson for a school project and is my own property. You may take inspiration from it but not claim this code as your own. If you want to use my code ask me first.
#
# Obs! Every "# type: ignore" is for vscode ignore
#
# Things to do:
#  - String containg e not floatable message
#  - warn overflow
#  - Add support for nested parentheses
#  - Add support for functions from the math module
#  - Safechecks for nonfull expression "2" or "2+"
#  

# Import modules
from ast import operator
import math
from operator import index
import os
import re
import array
from itertools import islice

# Clear the screen
os.system("CLS")

# Top scope variables
dodebug = True

# Function to get index value of n occurence in array/list
def nth_index(iterable, value, n):
    matches = (idx for idx, val in enumerate(iterable) if val == value)
    return next(islice(matches, n-1, n), None)

# Scope function variables
expression = ""
numberList = []
operatorList = []
numberList = []
rebuild_operator = ""
# Function to buildLists
def buildlists(expression,rebuild_operator):
    global numberList
    global operatorList
    # Set and split lists
    oprpattern = r'§|@|\+|-|\*|\/'
    numberList = re.split(oprpattern,expression)
    # change numberList to floats
    floatnumberList = []
    for num in numberList:
        if (rebuild_operator == "-" or rebuild_operator == " - "):
            floatnumberList.append(str(num))
        else:
            floatnumberList.append(str(float(num)))
    numberList = floatnumberList
    operatorList = []
    # Rebuild the operator list
    for ch in list(expression):
        if (ch.isnumeric() != True and ch != "."):
            operatorList += ch
    # Return variables
    return expression

# Function to handleoperations
def handleOperation(operationPlaceholder,operation,expression,dodebug):
    global operatorList
    global numberList
    # Set indexnum
    for operator in operatorList:
        indexnum = 0
        if operator in operatorList:
            indexnum = nth_index(operatorList,operator,1)
        else:
            indexnum = 0
        # Match the operator and get numbers
        if (operator == operationPlaceholder):
            num1 = float(numberList[indexnum])  # type: ignore
            num2 = float(numberList[indexnum+1])  # type: ignore
            # Calulate number and replace the non calulated expression with the calculated one.
            # calculatedNum = eval(str(num1) + operation + str(num2))
            calculatedNum = ""
            if (operation == "**") : calculatedNum = float(num1)**float(num2)
            if (operation == "/") : calculatedNum = float(num1)//float(num2)
            if (operation == "*") : calculatedNum = float(num1)*float(num2)
            if (operation == "//") : calculatedNum = float(num1)/float(num2)
            if (operation == "+") : calculatedNum = float(num1)+float(num2)
            if (operation == "-") : calculatedNum = float(num1)-float(num2)
            checkString = str(num1) + str(operationPlaceholder) + str(num2)
            previousExpression = expression
            expression = expression.replace(checkString,str(calculatedNum))
            if (re.search('e', expression)): return expression
            #Debug
            if (dodebug): 
                print("\033[94mContent:         \033[92m" + str(operatorList) + " " + str(numberList) + " " + previousExpression,"\033[m")
                print("\033[94mCalculation:     \033[92m" + str(num1) + " " + str(operation) + " " + str(num2) + " = " + str(calculatedNum),"\033[m")
                print("\033[94mStringHandle:    \033[92min_" + str(indexnum) + "   " + checkString + " >> " + str(calculatedNum) + " == "+ expression + "\033[m\n")
            # Rebuild Lists
            expression = buildlists(expression,rebuild_operator)
    return expression

# Function to evaluate an expression
def evaluate(expr):
    global numberList
    global operatorList
    # Replace expressions with placeholders for effected operations.
    expression = expr
    expression = expression.replace('**',"§")
    expression = expression.replace('^',"§")
    expression = expression.replace('//',"@")
    # Build lists
    expression = buildlists(expression,rebuild_operator)

    # Change integers in expression to floats.
    newExpression = ""
    count = 0
    for number in numberList:
        if (number != operatorList[-1] and count < (len(operatorList))):
            # print(numberList,operatorList,number,count) # Testing print...
            newExpression += str(float(number)) + str(operatorList[count])
        count = count+1
    newExpression += numberList[-1]
    expression = newExpression

    if (dodebug):  #Debug lists and expressions.
        print("\033[94;46mInput:           \033[92m" + str(operatorList) + " " + str(numberList) + " " + expression + "\033[0m")

    #Power off
    expression = handleOperation("§","**",expression,dodebug)

    #Multiplication
    expression = handleOperation("*","*",expression,dodebug)

    #Division
    expression = handleOperation("/","/",expression,dodebug)

    #FloorDivision
    expression = handleOperation("@","//",expression,dodebug)

    #Addition
    expression = handleOperation("+","+",expression,dodebug)

    #Subtraction
    expression = handleOperation("-","-",expression,dodebug)

    #Fix final expression
    res = expression
    hasLetter = re.search('[a-zA-Z]', res)
    if (hasLetter): return res
    else:
        return float(res)

# Main ui code (terminal-ui)
print("\033[34mWrite an expression bellow or write 'exit' bellow to exit.\033[0m")
while (True):
    # Get input
    strinput = str(input("\033[32mExpression: \033[35m"))
    orginput = strinput
    print("\033[1A\033[0m")
    # Handle Exit
    if strinput == "exit":
        exit()
    # Handle Cls
    if strinput == "cls":
        os.system("CLS")
    else:
        # Negative numbers fix
        if (strinput[0] == "-"):
            strinput = "0" + strinput
        # Parentheses support
        if "(" in strinput:
            # Check for parentheses in the string with a regex pattern and split by it.
            parenthesesArray = re.findall('\((.*?)\)',strinput)  # type: ignore
            # Calulculate al expressions inside a parentheses
            for paranExpr in parenthesesArray:
                checkString = str("(" + paranExpr + ")")
                # Calculate expression inside parentheses
                calcparanString = str(evaluate(str(paranExpr)))
                # Negative numbers fix
                if (calcparanString[0] == "-"):
                    calcparanString = "0" + calcparanString
                # Replace the parentheses-expression with the calculated value of said expression.
                strinput = strinput.replace(checkString,calcparanString)
            #Debug
            if (dodebug):
                print("\033[94mParenthes data: \033[92m", str(strinput), "     ", str(parenthesesArray), "\033[0m")
                print("\033[94mInputs:         \033[92m", orginput, "   ", strinput, "\033[0m\n")

        #Calculate answer and print it out.
        print("\033[33m" + str(orginput) + " = " + str(evaluate(strinput)) + "\033[0m")




