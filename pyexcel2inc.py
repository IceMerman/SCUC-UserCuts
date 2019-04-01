"""
DOCUMENTACION
	
Este programa sirve para la conversion de un archivo excel (.xls,.xlsx) a un archivo GAMS (.inc)
	
Entradas: 1. file : nombre de el archivo excel (.xls,.xlsx)
          2. sheet_name : hoja del archivo excel
          3. rang : rango que se tomara del sheet_name
	

Salidas:  1. archivo GAMS (.inc)
	

Comentarios: 1. (?)

Ejecucion:
	$ python pyexcel2inc file sheet_name -r rang -o output.inc

"""

#   Autor: Grupo GIMEL
#   Correo: (?)
#   Fecha: 25/06/2018
#   Versión: 0.1

import pandas as pd             #Librerias.
from tabulate import tabulate
from time import time
from datetime import datetime
import argparse 

parser = argparse.ArgumentParser(description = 'Generar archivos .inc')
parser.add_argument('file', type = str, help = 'Archivo excel de entrada')
parser.add_argument('sheet_name', type = str, help = 'Nombre de la hoja ')
parser.add_argument('-r', '--rang', type = str, help = 'Rango para generar la matriz ', default = ":")
parser.add_argument('-o','--output', type = str, help = 'Documento de salida ', default = "")
args = parser.parse_args()

def excel_to_inc(file, sheet_name,rang = ':', output = ''):
    """
    En esta funcion se establece el proceso para convertir un archivo excel(.xls, .xlsx)
    a un archivo GAMS (.inc), donde:
    file: es el archivo excel (.xls , .xlsx)
    sheet_name: nombre de la hoja en el archivo excel
    rang: el rango que se necesita tomar de la hoja
    output: es el archivo GAMS (.inc) que se tiene de salida.
    
    """
    start_time = time()
    
    orig = rang
    rang = rang.split(':') # Se convierte en una lista el rango que el usuario ingresa.

    #Se toman los caracteres que seran las columnas del archivo excel
    c1, c2 = ''.join(list(filter(str.isalpha,rang[0]))), ''.join(list(filter(str.isalpha,rang[1])))

    if c1 == '' and c2 == '': 
        columnas = None 
    elif c1 == c2:
        columnas = c1
    else:
        columnas = c1+':'+c2

    f1, f2 = ''.join(list(filter(str.isdigit,rang[0]))), ''.join(list(filter(str.isdigit,rang[1]))) # Se toman los digitos que seran las filas del archivo excel

    #Si no se ingresa un rango por defecto se tomara toda la hoja
    #Si se ingresa un rango se hara el respectivo 

    if f2 == '':
        nr = None
    else:
        f2= int(f2)
        nr = f2


    if f1 == '':
        f1 = 0
    else :
        f1 = int(f1) - 1
        nr = nr - f1

    #
    if output == '' :
        output = file.split('.')[0] + '_' + sheet_name    

   
    
    #print('columnas ', columnas)
    #print('skiprows', f1)
    #print('nrows', nr)
    try:
        if pd.__version__ < '0.21.0':
            df = pd.read_excel(file, sheet_name, parse_cols=columnas, header=None, skiprows=f1, nrows=nr) #usecols <-> parse_cols
        else:
            df = pd.read_excel(file, sheet_name, usecols=columnas, header=None, skiprows=f1, nrows=nr)
    except FileNotFoundError:
        # TODO: change to compare with a for loop
        print("\nError: File  %s not found!\n" % (file))
        return None
    df = df.fillna(value = '')
    #df = pd.to_numeric(df, errors='ignore')
    
    #print('Data readed')
    #print('Writing file '+ output.replace('.inc', '') + '.inc')
    f = open(output.replace('.inc', '') + '.inc', 'w')
    f.write("""* -----------------------------------------------------
* pyexcel2inc 0.1 Released TBA
* DEMIERI project. GIMEL, investigation group.
* Time stamp: %s
* -----------------------------------------------------
* Workbook:    %s
* Sheet:       %s
* Range:       %s
* -----------------------------------------------------\n"""%(datetime.now(), file, sheet_name, orig))
    f.write(tabulate(df, tablefmt='plain', showindex=False).replace('.0  ','    '))
    f.write("\n* -----------------------------------------------------")

    f.close()
    elapsed_time = time() - start_time
    print('---- Python: Successful convertion -> ' + file.split('.')[0]+'_' + sheet_name + ' range: ['+ orig + ']')
    print('---- Python: Excecution time: ' + str(time() - start_time))
    
if __name__== '__main__':
    excel_to_inc(args.file, args.sheet_name, args.rang, args.output)
