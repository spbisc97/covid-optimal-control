from contextlib import closing
import fileinput
filename='data.txt'
with closing(fileinput.FileInput(filename, inplace=True, backup='.bak')) as file:
    for line in file:
        line=' '+line.replace('/',' / ')
        line=line.replace('*',' * ' )
        for elem in ['beta','theta','zeta','delta','gamma','eta','sigma','lambda','rho','tau']:
            line=line.replace(' '+elem, ' %'+elem) 
        print(line,end='')

    file.close
