from contextlib import closing
import fileinput
filename='data.txt'
with closing(fileinput.FileInput(filename, inplace=True, backup='.bak')) as file:
    for line in file:
        for elem in ['beta','theta','delta','gamma','eta','sigma','lambda','rho','tau']:
            line=line.replace(elem, '%'+elem) 
        line=line.replace('b%eta', 'beta')
        line=line.replace('th%eta', 'theta')
        print(line,end='')

    file.close
