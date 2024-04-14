#subroutes for Toppan Assignment

#-------------------------------------------
#subroutes - sorted alphabetical

#Searches the given substring in an array of strings
#Input variables: 
#   array 		reference to array that contains all lines of the textfile
#   string_in	which string to look for
#Output variables:
#   line 		first line that contains substring
#   column 		position of first substring in that line
#   length 		substring length (= length of input string)
def find_string(array, string_in):
    #get length of input string
    length = len(string_in)
    
    #search for substring in the each line of the array until first hit
    #if found return the position of the beginning of the string and the string length
    for line in range(len(array)):
        column = array[line].find(string_in)
        
        if column != -1:
            #string found -> return position and length
            return line, column, length
    
    #no string found? -> return -1, -1, string_length
    return -1, -1, length
#-----------------
#Extracts required string from the orderform.txt
#If 2 spaces in a row or an | is detected, the string is finished and returned
#Input variables:
#	string_in		contains one line of the textfile
#	column			starting point for search
#Output variables:
#	sub_ret      substring that will be returned back
def get_string(string_in, column):
    #boolean to determine 2 space in a row
    double_space = 0
    sub_ret = ""
    
    #for-loop from first column to last character in string
    for i in range(column, len(string_in)):
        #get character at position
        char = string_in[i:i+1]
        
        #is character space and already had space as last character?
        if double_space == 1 and char == ' ':
            return sub_ret
        #is character |? -> string finished, return value
        elif char == "|":
            return sub_ret
        #is character space? -> set boolean to true
        elif char == ' ':
            double_space = 1
        #normal character
        else:
            #was last character a space? -> space is part of the string
            if double_space == 1:
                double_space = 0
                sub_ret = sub_ret + " "
            
            #add the normal character to string
            sub_ret = sub_ret + char
            
    return sub_ret

#-----------------
#Extracts data from a table like format in the .txt-file
#Input variables:
#	lines			        array containing some lines (= a table) of the .txt-input
#	extract_category		required for selecting the correct section (e.q. MASK CODIFICATION or GRP)
#	extract_line			number of the line to be extracted from the table (0 = first line of the table)			
#Output variables:
#	sub_ret				    substring with the requested information
def read_table(lines, extract_category, extract_line):
    #search for extract_category in lines
    line, column, string_length = find_string(lines, extract_category)
    
    if line == -1:
        print("Category not found in read_table()")
        return
    
    first_content_line = -1;    #first line after header with content
    content_column = -1;        #first column of the field that has the requested content
    found_bool = 0;             #for checking if "-" was already found once before
    sub_ret = ""
    
    #search for first line after header = begin of content
    for ind in range(1, len(lines)):
        sub_ret = lines[ind][column:(column + 1)]
        if found_bool == 1 and sub_ret != "-":
            first_content_line = ind
            break
        elif sub_ret == "-":
            found_bool = 1
    
    #search for beginning of cell (= next | to the left)
    for ind in range(column, -1, -1):   #from column to 0
        if lines[first_content_line + extract_line][ind:ind+1] == "|":
            content_column = ind + 1
            break
    
    #correction for spaces after beginning of cell
    for ind in range(content_column, len(lines[first_content_line + extract_line])):
        if lines[first_content_line + extract_line][ind:ind+1] == " ":
            content_column = content_column + 1
        else:
            break
    
    #get content from requested field
    sub_ret = get_string(lines[first_content_line + extract_line], content_column)
        
    return sub_ret
    
#-----------------
#Extracts the <CDs> parts from the .txt-file and writes them in the .xml file
#Input variables:
#	lines               array containing the form
#	filehandle          required to write to the file
#	cds_array_txt       array containing the names of the categories in txt-data for cds
#	cds_array_xml       array containing the names of the categories in xml-data (same order as txt-array) for cds
#Output variables:
#   none
def write_cds(lines, filehandle, cds_array_txt, cds_array_xml):
    #define search string
    search_string = "LEVEL"
    #define empty array which contains sub-arrays
    #each subarray contains one table extracted from the original lines
    filtered_lines = []
    
    #Search for lines that contain "LEVEL"
    for ind in range(len(lines)):
        #[lines[ind]] is used as syntax to have an array only containing one line
        line, column, string_length = find_string([lines[ind]], search_string)
        string_answer = get_string(lines[ind], column)
        
        #filter out lines that contain "LEVEL" with additions (e.q. "LEVEL INFORMATION")
        if string_answer == search_string:
            #get table into an array and put reference to that array into filtered_lines
			#define array for one table and put one line on first index
            level_array = [lines[ind]]
            table_content = 0   #boolean to check if already inside content of table (and not header)
            #count lines that contain table and put them into level_array
            for counter in range(ind, len(lines)):
                #check if the second character on a line is "-" or "X"
				#yes (= "-") and $table_content is true -> end of table reached
                if lines[counter][1:2] == "-" and table_content == 1:
                    break   #end for-loop
                #yes (= "X") and $table_content is true -> end of table reached
                elif lines[counter][1:2] == "X" and table_content == 1:
                    break   #end for-loop
                #yes, but $table_content is false -> content of table is starting
                elif lines[counter][1:2] == "-":
                    table_content = 1
                    level_array.append(lines[counter])
                #no, somewhere inside the table
                else:
                    level_array.append(lines[counter])
                
            #put reference to array into filtered_lines
            filtered_lines.append(level_array)
    
    #Get amount of layers
	#assumption: level/layer number always in first column
    layer_amount = 0
    for ind in range(len(filtered_lines)):
        #check last line of table(s) to get number of layers
        string_last_line = filtered_lines[ind][len(filtered_lines[ind]) - 1]
              
        #remove first |
        string_last_line = string_last_line[1:]
        
        #get index of next |
        line_pos = string_last_line.find("|")
        
        #max. level is the number until the | (might include some spaces)
        if line_pos != -1:
            layer_stack = int(string_last_line[:line_pos])
            
            #compare layer amount for different tables -> should be equal
            if layer_amount == 0:
                layer_amount = layer_stack
            elif layer_amount != layer_stack:
                print("Different anount of layers in tables!")
                break
                
            layer_amount = int(string_last_line[:line_pos])
        else:
            print("Error in layer tables!")
    
    #start with writing to .xml-file
    filehandle.write("<CDs>\n")
    
    #for each CD (= number of layers)
    for ind in range(layer_amount):
        filehandle.write("<CD>\n")
        
        filehandle.write("<" + cds_array_xml[0] + ">")
        filehandle.write(str(ind + 1))
        filehandle.write("</" + cds_array_xml[0] + ">\n")
        
        #search each category in table and print it to xml-file
        for i in range(1,len(cds_array_xml)):
            string_answer = read_table(filtered_lines[1], cds_array_txt[i], ind)
            
            filehandle.write("<" + cds_array_xml[i] + ">")
            filehandle.write(string_answer)
            filehandle.write("</" + cds_array_xml[i] + ">\n")
        
        filehandle.write("</CD>\n")
        
    filehandle.write("</CDs>\n")
    print ("CDs creating completed.")
    
#-----------------
#Extracts the <General> parts from the .txt-file and writes them in the .xml file
#Input variables:
#	lines			        array containing the form
#	filehandle			    required to write to the file
#	general_array_txt	    array containing the names of the categories in txt-data for general	
#	general_array_xml	    array containing the names of the categories in xml-data (same order as txt-array) for general
#Output variables:
#	none
def write_general(lines, filehandle, general_array_txt, general_array_xml):
    #variables for string search in array
    line = -1
    column = -1
    string_length = -1
    string_answer = ""

    #start of the output to .xml-file
    filehandle.write("<General>\n")
    
    #cycling through all keys-hash pairs defined for the general section
    for ind in range(len(general_array_txt)):
        #search for string, look up the search term in the list
        #check if Customer -> Customer has a different format than the others
        if general_array_xml[ind] == "Customer":
            #assumption: fixed position of customer name
            line, column, string_length = 2, 5, 0
        #normal routine for non-Customer string
        else:
            line, column, string_length = find_string(lines, general_array_txt[ind])
    
        #if searched string exists -> get the actual data (might be empty)
        if line != -1:
            string_answer = get_string(lines[line], column + string_length)
            if string_answer == "":
                print ("No" + general_array_xml + "!")
            #Check if data is a Contact -> if yes, use different format
            elif general_array_xml[ind].find("Contact") != -1:
                #divide first and last name
                first_name = ""
                last_name = ""
                dot_index = string_answer.find(".")
                if dot_index != -1:
                    first_name = string_answer[:(dot_index + 1)]
                    last_name = string_answer[(dot_index + 1):]
                # if not dot for separation found -> assumption: only last name
                else:
                    last_name = string_answer
                    
                #output full contact info to .xml file
                filehandle.write("<" + general_array_xml[ind] + ">\n<Contact>\n")
                filehandle.write("<FirstName>" + first_name + "</FirstName>\n")
                filehandle.write("<LastName>" + last_name + "</LastName>\n")
                filehandle.write("</Contact>\n</" + general_array_xml[ind] + ">\n")
            #normal data format    
            else:
                filehandle.write("<" + general_array_xml[ind] + ">" + string_answer + "</" + general_array_xml[ind] + ">\n")
        else:
            print("No" + general_array_txt[ind] + "found!")
      
    filehandle.write("</General>\n")
    print("Header creation completed.")

#-----------------
#Extracts the <Layers> parts from the .txt-file and writes them in the .xml file
#Input variables:
#   lines_ref_sub			array containing the form
#	filehandle_sub			required to write to the file
#	layers_array_txt	    array containing the names of the categories in txt-data for layers	
#	layers_array_xml	    array containing the names of the categories in xml-data (same order as txt-array) for layers
#Output variables:
#	none
def write_layers(lines, filehandle, layers_array_txt, layers_array_xml):
    #define search string
    search_string = "LEVEL"
    #define empty array which contains sub-arrays
    #each subarray contains one table extracted from the original lines
    filtered_lines = []
    
    #Search for lines that contain "LEVEL"
    for ind in range(len(lines)):
        #[lines[ind]] is used as syntax to have an array only containing one line
        line, column, string_length = find_string([lines[ind]], search_string)
        string_answer = get_string(lines[ind], column)
        
        #filter out lines that contain "LEVEL" with additions (e.q. "LEVEL INFORMATION")
        if string_answer == search_string:
            #get table into an array and put reference to that array into filtered_lines
			#define array for one table and put one line on first index
            level_array = [lines[ind]]
            table_content = 0   #boolean to check if already inside content of table (and not header)
            #count lines that contain table and put them into level_array
            for counter in range(ind, len(lines)):
                #check if the second character on a line is "-" or "X"
				#yes (= "-") and $table_content is true -> end of table reached
                if lines[counter][1:2] == "-" and table_content == 1:
                    break   #end for-loop
                #yes (= "X") and $table_content is true -> end of table reached
                elif lines[counter][1:2] == "X" and table_content == 1:
                    break   #end for-loop
                #yes, but $table_content is false -> content of table is starting
                elif lines[counter][1:2] == "-":
                    table_content = 1
                    level_array.append(lines[counter])
                #no, somewhere inside the table
                else:
                    level_array.append(lines[counter])
                
            #put reference to array into filtered_lines
            filtered_lines.append(level_array)
    
    #Get amount of layers
	#assumption: level/layer number always in first column
    layer_amount = 0
    for ind in range(len(filtered_lines)):
        #check last line of table(s) to get number of layers
        string_last_line = filtered_lines[ind][len(filtered_lines[ind]) - 1]
              
        #remove first |
        string_last_line = string_last_line[1:]
        
        #get index of next |
        line_pos = string_last_line.find("|")
        
        #max. level is the number until the | (might include some spaces)
        if line_pos != -1:
            layer_stack = int(string_last_line[:line_pos])
            
            #compare layer amount for different tables -> should be equal
            if layer_amount == 0:
                layer_amount = layer_stack
            elif layer_amount != layer_stack:
                print("Different anount of layers in tables!")
                break
                
            layer_amount = int(string_last_line[:line_pos])
        else:
            print("Error in layer tables!")
    
    #start writing the layer-part of the xml-file
    filehandle.write("<Layers>\n")
    
    #for each layer
    for ind in range(layer_amount):
        filehandle.write("<Layer>\n")
        filehandle.write("<LayerNumber>" + str(ind+1) + "</LayerNumber>\n")
        
        #define category for string searching
        category = "MASK CODIFICATION"
        #get string from table
        string_answer = read_table(filtered_lines[0], category, ind)
        #write category to xml-file
        filehandle.write("<LayerName>" + string_answer + "</LayerName>\n")
        
        #define category for string searching
        category = "REV"
        #get string from table
        string_answer = read_table(filtered_lines[1], category, ind)
        #write category to xml-file
        filehandle.write("<Revision>" + string_answer + "</Revision>\n")
        
        #define category for string searching
        category = "QTY"
        #get string from table
        string_answer = read_table(filtered_lines[0], category, ind)
        #write category to xml-file
        filehandle.write("<Quantity>" + string_answer + "</Quantity>\n")
        
        #get more categories via for loop
        for i in range(len(layers_array_xml)):       
            line, column, string_length = find_string(lines, layers_array_txt[i])
            string_answer = get_string(lines[line], column + string_length)
            filehandle.write("<" + layers_array_xml[i] + ">" + string_answer + "</" + layers_array_xml[i] + ">\n")
        
        category = "FIELD"
        string_answer = read_table(filtered_lines[1], category, ind)
        filehandle.write("<FieldTone>" + string_answer + "</FieldTone>\n")
        
        filehandle.write("</Layer>\n")
    
    filehandle.write("</Layers>\n")
    
    print ("Layers creating completed.")
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
