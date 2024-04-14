#Python implementation of Toppan assigment
#missing exception handling

#import subroutines find_string, get_string, read_table, 
#write_cds, write_general and write_layers
try:
    import sub_toppan as toppan
    #from Subroutines_Toppan import *
    #import Subroutines_Toppan
except ModuleNotFoundError:
    print("Module sub_toppan could not be imported.")

#--------------------------------------------------------
#User controlled variables

#filename of the file to read
filename_read = "orderform.txt"

#filename of the file to write
filename_write = "out.xml"

#definition of arrays for finding and converting .txt data to .xml

#names of the categories in txt-data for general
general_array_txt = [
                    "ORDERFORM NUMBER : ",
                    "", # this element is not required -> empty
                    "SITE OF : ",
                    "FAB UNIT        : ",
                    "DEVICE : ",
                    "TECHNOLOGY NAME : ",
                    "P.O. NUMBERS : ",
                    "STATUS    : ",
                    "DATE : ",
                    "TECHNICAL CONTACT : ",
                    "TO THE ATTENTION OF : "
]

#names of the categories in xml-data (same order as txt-array) for general
general_array_xml = [
                    "OrderNumber", 
                    "Customer", 
                    "MfgSite", 
                    "Fab", 
                    "Device", 
                    "Technology", 
                    "PONumber", 
                    "OrderStatus", 
                    "CreatedDate", 
                    "TechnicalContact", 
                    "ShipToContact"
]

#names of the categories in txt-data for layers
layers_array_txt = [
                    "SITE TO SEND MASKS TO : ",
                    "SHIPPING METHOD : "
]

#names of the categories in xml-data (same order as txt-array) for layers
layers_array_xml = [
                    "SendToSite",
                    "ShipMethod"
]

#names of the categories in txt-data for cds
cds_array_txt = [
                " NUM  |",
                "  NAME |",
                "FEATURE|",
                "  TONE |",
                " BIAS |",
                "FILE NAME"
]

#names of the categories in xml-data (same order as txt-array) for cds
cds_array_xml = [
                "CDNumber",
                "CDName",
                "CDFeature",
                "CDTone",
                "CDBias",
                "Filename"
]
    
#--------------------------------------------------------
#begin of main

#reading the input file and putting every line into array/list
filehandle_r = open(filename_read, 'r')
lines = filehandle_r.readlines()
filehandle_r.close()

#open .xml-file for writing data
filehandle_w = open(filename_write, 'w')
filehandle_w.write("<Order>\n")
toppan.write_general(lines, filehandle_w, general_array_txt, general_array_xml)
toppan.write_cds(lines, filehandle_w, cds_array_txt, cds_array_xml)
toppan.write_layers(lines, filehandle_w, layers_array_txt, layers_array_xml)
filehandle_w.write("</Order>")
filehandle_w.close()

#end of main
#--------------------------------------------------------





