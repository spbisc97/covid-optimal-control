from contextlib import closing
import fileinput
filename='data.txt'
with closing(fileinput.FileInput(filename, inplace=True, backup='.bak')) as file:
    for line in file:
        for elem in ['beta','theta','zeta','delta','gamma','eta','sigma','lambda','rho','tau']:
            line=line.replace(elem, '%'+elem) 
        line=line.replace('b%eta', 'beta')
        line=line.replace('th%eta', 'theta')
        line=line.replace('z%eta', 'zeta')
    
        print(line,end='')

    file.close
