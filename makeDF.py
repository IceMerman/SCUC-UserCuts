"""
DOCUMENTACION
	
Este programa sirve para calcular la matriz PTDF y LODF, ademas nos da como salida las matrices en un archivo
GAMS (.inc)
	
Entradas: 1. file : nombre de el archivo excel (.xls,.xlsx)
          2. branchSheet : hoja del archivo excel de lineas
          3. busSheet : hoja del archivo excel de barras
	

Salidas:  1. Matriz PTDF en formato GAMS (.inc)
          2. Matriz LODF en formato GAMS (.inc)
	

Comentarios: 1. (?)

Ejecucion:
	$ python makeDF file branchSheet busSheet -o output.inc -o2 output2.inc 

"""

#   Autor: Grupo GIMEL
#   Correo: (?)
#   Fecha: 05/07/2018
#   Versión: 0.1

from pandas import read_excel
#import pandas as pd # M0
from numpy import r_, c_, zeros, ones, int8, int32, int64, float32, float64, dot, insert, delete, reciprocal
from scipy.sparse import csc_matrix as sparse
from scipy.sparse import lil_matrix
from scipy.sparse.linalg import inv
from tabulate import tabulate
from time import time
from datetime import datetime
import argparse 


parser = argparse.ArgumentParser(description = 'Generar archivos .inc')
parser.add_argument('file', type = str, help = 'Archivo excel de entrada')
parser.add_argument('branchSheet', type = str, help = 'Nombre de la hoja de ramas ')
parser.add_argument('busSheet', type = str, help = 'Nombre de la hoja de buses ')
parser.add_argument('-o1','--output', type = str, help = 'Documento de salida PTDF ', default = '')
parser.add_argument('-o2','--output2', type = str, help = 'Documento de salida LODF ', default = '')
args = parser.parse_args()


def makeDF(file, branchSheet, busSheet, output = '', output2 = ''):

    start_time = time()
    
    if output == '':
        output = file.split('.')[0]+'_'+'PTDF'  
        
    if output2 == '':
        output2 = file.split('.')[0]+'_'+'LODF'
        
    
    idBranchNi = 5
    idBranchNf = 6
    idBranchBij = 1
    
    integerPre = int8
    floatPre = float64
    
    busdf = read_excel(file, busSheet).values
    branchdf = read_excel(file, branchSheet).values
    
    # Dado que es un conjunto ordenado se puede crear mediante un range
    
    busLen = len(busdf[:, 0])
    branchLen = len(branchdf[:, 0])
    idSlack = int(busdf[0, 2])
    
    busSet = range(busLen)
    branchSet = range(branchLen)
    
    Ni = branchdf[:, idBranchNi]
    Nf = branchdf[:, idBranchNf]
    Xij = branchdf[:, idBranchBij].astype(floatPre)
    Bij = reciprocal(Xij)
    
    
    # Indicencia como sparse
    
    data = r_[ones(branchLen, dtype = integerPre), -ones(branchLen, dtype = integerPre)]
    data2 = r_[Bij, -Bij]
    row = r_[branchSet, branchSet]
    col = r_[Ni, Nf]
    
    A = sparse((data, (row, col)), (branchLen, busLen), dtype = integerPre)#.toarray()
    Barr = sparse((data2, (row, col)), (branchLen, busLen), dtype = floatPre)#.toarray()
    
    # Remover columna slack
    SlackB = [i for i in busSet if i != idSlack]
    
    Ap = lil_matrix(A[:,SlackB]) # Use delete()
    
    D = sparse((Bij, (branchSet, branchSet)), (branchLen, branchLen), dtype = floatPre)
    D = D.tolil()
    

    Bbus = A.T * Barr
    
    Bbus = Bbus.tolil()
    
    BbusP = delete(Bbus.toarray(), idSlack, 0)
    BbusP = delete(BbusP, idSlack, 1)
    BbusP = sparse(BbusP)
    
    prePTDF = dot(D, dot(Ap, inv(BbusP))).toarray()
    
    PTDF = insert(prePTDF, idSlack, 0, axis = 1)
    
    del prePTDF
    
    col = r_[branchSet, branchSet]
    row = r_[Ni, Nf]
    CFT = sparse((data, (row, col)), (busLen, branchLen), dtype = integerPre)
    
    H = PTDF * CFT
    
    LODF = zeros((branchLen, branchLen),dtype = floatPre)
    for i in branchSet:
        for j in branchSet:
            if i == j:
                LODF[i,j] = -1
            elif H[j,j] == 1:
                LODF[i,j] = 0
            else:
                LODF[i,j] = H[i,j]/(1-H[j,j])

    # Ingreso de etiquetas de nodos y lineas
    # Para las matrices PTDF y LODF

    PTDF = PTDF.astype(str)
    LODF = LODF.astype(str)

    nodes = busdf[:,0].astype(str)
    lines = branchdf[:,0]
    lines2 = insert(lines,0,'  ')
    
    PTDF = insert(PTDF,0,nodes,0)
    PTDF = insert(PTDF,0,lines2,1)

    LODF = insert(LODF,0,lines,0)
    LODF = insert(LODF,0,lines2,1)

    #lsf=pd.DataFrame(LODF)#M0
    #lsf.to_csv("LSF2.csv")#M0

    
    #Escritura de archivos .inc

    #Archivo .inc PTDF  
    f = open (output.replace('.inc','')+'.inc','w')
    f.write("""* -----------------------------------------------------
* makeDF 0.1 Released TBA
* DEMIERI project. GIMEL, investigation group.
* Time stamp : %s
* -----------------------------------------------------
* Workbook:    %s
* -----------------------------------------------------\n"""%(datetime.now(),file))
    f.write(tabulate(PTDF, tablefmt='plain', numalign = 'left' ))
    f.write("\n* -----------------------------------------------------")
    f.close()

    #Archivo .inc LODF   
    f2 = open (output2.replace('.inc','')+'.inc','w')
    f2.write("""* -----------------------------------------------------
* makeDF 0.1 Released TBA
* DEMIERI project. GIMEL, investigation group. 
* Time stamp : %s
* -----------------------------------------------------
* Workbook:    %s
* -----------------------------------------------------\n"""%(datetime.now(),file))
    f2.write(tabulate(LODF, tablefmt='plain'))
    f2.write("\n* -----------------------------------------------------")
    f2.close()
    
    elapsed_time = time() - start_time
    print('---- Python: Successful convertion -> ' + file.split('.')[0]+'_ range: [Automatic]')
    print('---- Python: Excecution time: ' + str(time() - start_time))
    
if __name__== '__main__':
    makeDF(args.file, args.branchSheet, args.busSheet, args.output , args.output2)    


