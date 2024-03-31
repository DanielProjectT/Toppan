#!/usr/bin/perl
use strict;
use warnings;

#Perl implementation for Toppan Assignment
#-------------------------------------------
#User controlled variables
#Name of the input and output file
my $input_file_name = "orderform.txt";
my $output_file_name = "out.xml";

#defining pairs of key-hashs for the general section (keys = xml-names, hashs = names in .txt data)
my @general_keys;
$general_keys[0] = "OrderNumber";
$general_keys[1] = "Customer";
$general_keys[2] = "MfgSite";
$general_keys[3] = "Fab";
$general_keys[4] = "Device";
$general_keys[5] = "Technology";
$general_keys[6] = "PONumber";
$general_keys[7] = "OrderStatus";
$general_keys[8] = "CreatedDate";
$general_keys[9] = "TechnicalContact";
$general_keys[10] = "ShipToContact";

my %general_list;
$general_list{$general_keys[0]} = "ORDERFORM NUMBER : ";
#$general_list{$general_keys[0]} = ""; not required since there is nothing before the actual customer name
$general_list{$general_keys[2]} = "SITE OF : ";
$general_list{$general_keys[3]} = "FAB UNIT        : ";
$general_list{$general_keys[4]} = "DEVICE : ";
$general_list{$general_keys[5]} = "TECHNOLOGY NAME : ";
$general_list{$general_keys[6]} = "P.O. NUMBERS : ";
$general_list{$general_keys[7]} = "STATUS    : ";
$general_list{$general_keys[8]} = "DATE : ";
$general_list{$general_keys[9]} = "TECHNICAL CONTACT : ";
$general_list{$general_keys[10]} = "TO THE ATTENTION OF : ";

#defining pairs of key-hashs for the layer section (keys = xml-names, hashs = names in .txt data)
my @layers_keys;
$layers_keys[0] = "SendToSite";
$layers_keys[1] = "ShipMethod";

my %layers_list;
$layers_list{$layers_keys[0]} = "SITE TO SEND MASKS TO : ";
$layers_list{$layers_keys[1]} = "SHIPPING METHOD : ";

#defining pairs of key-hashs for the cds section (keys = xml-names, hashs = names in .txt data)
my @cds_keys;
$cds_keys[0] = "CDNumber";
$cds_keys[1] = "CDName";
$cds_keys[2] = "CDFeature";
$cds_keys[3] = "CDTone";
$cds_keys[4] = "CDBias";
$cds_keys[5] = "Filename";


my %cds_list;
$cds_list{$cds_keys[0]} = " NUM  |";
$cds_list{$cds_keys[1]} = "  NAME |";
$cds_list{$cds_keys[2]} = "FEATURE|";
$cds_list{$cds_keys[3]} = "  TONE |";
$cds_list{$cds_keys[4]} = " BIAS |";
$cds_list{$cds_keys[5]} = "FILE NAME";

#-------------------------------------------
#Reading the input file (read-only mode) and putting every line into array
open(input_file1, "<input/".$input_file_name) or die("Couldn't open file $input_file_name - $!");
my @lines = <input_file1>;
my $lines_ref = \@lines; #reference to the array containing the form (to give to subroutines)
#Closing the read file
close input_file1 or die("Couldn't close file properly - $!");
#-------------------------------------------
#Opening file for writing data (write only mode)
open(my $filehandle, ">output/".$output_file_name) or die("Couldn't create file $output_file_name - $!");
print $filehandle "<Order>\n";
#creation of the General part in .xml-file
write_general($lines_ref, $filehandle,\%general_list , \@general_keys);
#creation of the Layers part in .xml-file
write_layers($lines_ref, $filehandle,\%layers_list ,\@layers_keys);
#creation of the CDs part in .xml-file
write_cds($lines_ref, $filehandle,\%cds_list ,\@cds_keys);
print $filehandle "</Order>";

#Closing written file
close $filehandle or die("Couldn't close file properly - $!");
#end of main
#-------------------------------------------

#Subroutines - sorted alphabetically
#-------------------------------------------

#Searches the given substring in an array of strings
#Input variables: 
#	$array_ref 		reference to array that contains all lines of the textfile
#	$string			which string to look for
#Output variables:
#	$line 			first line that contains substring
#	$column 		position of first substring in that line
#	$length 		substring length (= length of input string)
sub find_string{
	# get total number of arguments passed.
	my $n = scalar(@_);
	#check for correct amount of inputs
	if($n != 2){
	   die("Too few input parameters in find_string");
	}
	#assign inputs to local variables
	my $array_ref = $_[0];
	my @array_input = @$array_ref;
	my $array_length = @array_input;
	my $search_string = $_[1];
	my $string_length = length($search_string);
	#search for substring in the each line of the array until first hit
	#if found return the position of the beginning of the string and the string length
	for(my $col = 0; $col < $array_length; $col++) {
		my $ind = index($array_input[$col],$search_string);
		if($ind != -1){
			#string found -> return position and length
			return $col, $ind, $string_length;
		}
    }
	
	#no string found? -> return -1, -1, string_length
	return -1, -1, $string_length;
}

#Extracts required string from the orderform.txt
#If 2 spaces in a row or an | is detected, the string is finished and returned
#Input variables:
#	$string			contains one line of the textfile
#	$column			starting point for search
#Output variables:
#	$substring
sub get_string{
	# get total number of arguments passed.
	my $n = scalar(@_);
	#check for correct amount of inputs
	if($n != 2){
		die("Too few input parameters in get_string");
	}
	#assign inputs to local variables
	my $string_input = $_[0];
	my $col = $_[1];
	my $string_return = ""; #String that will be returned
	my $double_space = 0;	#boolean to determine 2 space in a row
	for(my $i = $col; $i < length($string_input); $i++) {
		#get character at position
		my $char = substr($string_input, $i, 1);
		#is character space and already had space as last character?
		if($double_space == 1 and $char eq " "){
			return $string_return;
		}
		#is character |? -> string finished, return value
		elsif($char eq "|"){
			return $string_return;
		}
		#is character space? -> set boolean to true
		elsif($char eq " "){
			$double_space = 1;
		}
		#normal character
		else{
			#was last character a space? -> space is part of the string
			if($double_space == 1 ){
				$double_space = 0;
				#add space to string
				$string_return = $string_return." ";
			}
			#add the normal character to string
			$string_return = $string_return.$char;
		}
	}
		
	# input string length = 0 or no termination mark (space or |)
	return $string_return;
}

#Extracts data from a table like format in the .txt-file
#Input variables:
#	$lines_ref_sub			reference to the array containing some lines (= a table) of the .txt-input
#	$extract_category		required for selecting the correct section (e.q. MASK CODIFICATION or GRP)
#	$extract_line			number of the line to be extracted from the table (0 = first line of the table)			
#Output variables:
#	$substring				substring with the requested information
sub read_table{
	my $n = scalar(@_);
	#check for correct amount of inputs
	if($n != 3){
		die("Too few input parameters in read_table");
	}
	my $lines_ref_sub = $_[0];
	my @lines_sub = @$lines_ref_sub;
	my $extract_category = $_[1];
	my $extract_line = $_[2];
	
	#search for $extract_category
	my ($line, $column, $lengtj) = find_string($lines_ref_sub, $extract_category);
	if($line == -1){
		die("Category not found in read_table()");
	}
	my $first_content_line; #first line after header with content
	my $content_column; 	#first column of the field that has the requested content
	my $bool = 0; #for checking if "-" was already found once before
	#search for first line after header = begin of content
	for(my $ind = 1; $ind < scalar(@lines_sub); $ind++){
		my $sub_string = substr($lines_sub[$ind], $column, 1);		
		if(($bool == 1) and ($sub_string ne "-")){
			$first_content_line = $ind;
			last;
		}
		elsif($sub_string eq "-"){
			$bool = 1;
		}
	}
	#search for beginning of cell (= next | to the left)
	for(my $ind = $column; $ind >= 0; $ind--){
		if(substr($lines_sub[$first_content_line + $extract_line], $ind, 1) eq "|"){
			$content_column = $ind + 1;
			last;
		}
	}

	#get content from requested field
	my $substring = get_string($lines_sub[$first_content_line + $extract_line], , $content_column);
	
	#remove leading spaces
	for(my $ind = 0; $ind < length($substring); $ind++){
		if(substr($substring ,0 ,1) eq " "){
			$substring = substr($substring, 1, length($substring));
		}
	}
	return $substring;
}

#Extracts the <CDs> parts from the .txt-file and writes them in the .xml file
#Input variables:
#	$lines_ref_sub			reference to the array containing the form
#	$filehandle_sub			required to write to the file
#	$cds_list_ref_sub		contains the reference to the list of keys - hash pairs for the cds section	
#	$cds_keys_ref_sub		contains the reference to the array of keys for the cds section
#Output variables:
#	none
sub write_cds{
	my $n = scalar(@_);
	#check for correct amount of inputs
	if($n != 4){
		die("Too few input parameters in write_general");
	}
	my $lines_ref_sub = $_[0];
	my @lines_sub = @$lines_ref_sub;
	my ($filehandle_sub) = $_[1];
	my $cds_list_ref_sub = $_[2];
	my $cds_keys_ref_sub = $_[3];
	my %cds_list_sub = %$cds_list_ref_sub;
	my @cds_keys_sub = @$cds_keys_ref_sub;
	my $cds_keys_sub_length = @cds_keys_sub;
	
	#Search for lines that contain "LEVEL"
	my $search_string = "LEVEL";
	my @filtered_lines;	#has the indexes for the relevant lines
	for(my $ind = 0; $ind < scalar(@lines_sub); $ind++){
		my ($line, $column, $length) = find_string($lines_ref_sub, $search_string);
		my $string_answer = get_string($lines_sub[$ind], $column);
		
		#filter out lines that contain "LEVEL" with additions (e.q. "LEVEL INFORMATION")
		if($string_answer eq $search_string){
			
			#get table into an array and put reference to that array into @filtered_lines
			my @level_array;
			my $line_amount = 1;
			$level_array[$line_amount - 1] = $lines_sub[$ind];
			my $table_content = 0; #boolean to check if already inside content of table (and not header)
			#count lines that contain table and put them into @level_array
			for(my $counter = $ind + 1; $counter < scalar(@lines_sub); $counter++){
				#check if the second character on a line is "-" or "X"
				#yes (= "-") and $table_content is true -> end of table reached
				if((substr($lines_sub[$counter], 1, 1) eq "-") and $table_content == 1){
					last; #end for-loop
				}#yes (= "X") and $table_content is true -> end of table reached
				elsif((substr($lines_sub[$counter], 1, 1) eq "X") and $table_content == 1){
					last; #end for-loop
				}
				#yes, but $table_content is false -> content of table is starting
				elsif(substr($lines_sub[$counter], 1, 1) eq "-"){
					$table_content = 1;
					$line_amount++;
					$level_array[$line_amount - 1] = $lines_sub[$counter];
				}
				#no, somewhere inside the table
				else{
					$line_amount++;
					$level_array[$line_amount - 1] = $lines_sub[$counter];
				}
			}
			#put reference to array into @filtered_lines
			my $array_len = @filtered_lines;
			$filtered_lines[$array_len] = \@level_array;				
		}
	}
	
	
	#Get amount of layers
	#assumption: level/layer number always in first column
	my $layer_amount = 0;
	for(my $ind = 0; $ind < scalar(@filtered_lines); $ind++){
		my $ref = $filtered_lines[$ind];
		my @array_var = @$ref;
		
		#check last line of table(s) to get number of layers
		my $string1 = $array_var[scalar(@array_var) - 1];
		#remove first |
		$string1 = substr($string1, 1, length($string1) - 1);
		#get index of next |
		my $line_pos = index($string1, "|");
		#max. level is the number until the | (might include some spaces)
		if($line_pos != -1){
			my $layer_stack = substr($string1, 0, $line_pos - 1);
			#compare layer amount for different tables -> should be equal
			if($layer_amount == 0){
				$layer_amount = $layer_stack;
			}
			elsif($layer_amount != $layer_stack){
				die("Different anount of layers in tables!");
			}
			
			$layer_amount = substr($string1, 0, $line_pos - 1);
		}
		else{
			die("Error in layer tables!");
		}
	}
	
	
	
	
	print $filehandle_sub "<CDs>\n";
	
	#for each CD
	for(my $ind = 0; $ind < $layer_amount; $ind++){
		print $filehandle_sub "<CD>\n";
		
		
		print $filehandle_sub "<$cds_keys[$ind]>", $ind+1, "</$cds_keys[$ind]>\n";
		
		for(my $i = 1; $i < scalar(@cds_keys); $i++){
			my $string_result = read_table($filtered_lines[1], $cds_list{$cds_keys[$i]}, $ind);
			
					my $ref = $filtered_lines[1];
			print $filehandle_sub "<$cds_keys[$i]>".$string_result."</$cds_keys[$i]>\n";
		}
		
		print $filehandle_sub "</CD>\n";
	}
		
	
	print $filehandle_sub "</CDs>\n";
	print "CDs creating completed.\n";
	
}

#Extracts the <General> parts from the .txt-file and writes them in the .xml file
#Input variables:
#	$lines_ref_sub			reference to the array containing the form
#	$filehandle_sub			required to write to the file
#	$general_list_ref_sub	contains the reference to the list of keys - hash pairs for the general section	
#	$general_keys_ref_sub	contains the reference to the array of keys for the general section
#Output variables:
#	none
sub write_general{
	my $n = scalar(@_);
	#check for correct amount of inputs
	if($n != 4){
		die("Too few input parameters in write_general");
	}
	my $lines_ref_sub = $_[0];
	my @lines_sub = @$lines_ref_sub;
	my ($filehandle_sub) = $_[1];
	my $general_list_ref_sub = $_[2];
	my $general_keys_ref_sub = $_[3];
	my %general_list_sub = %$general_list_ref_sub;
	my @general_keys_sub = @$general_keys_ref_sub;
	my $general_keys_sub_length = @general_keys_sub;
	#variables for string search in array
	my $col_num;
	my $line_num;
	my $string_len;
	my $string_answer;
	
	#start of the output to .xml-file
	print $filehandle_sub "<General>\n";

	#cycling through all keys-hash pairs defined for the general section
	for(my $ind = 0; $ind < $general_keys_sub_length; $ind++){
		#search for string, look up the search term in the list
		if($general_keys_sub[$ind] eq "Customer"){ #Customer has a different format than the others
			($line_num, $col_num, $string_len) = (2, 5, 0); #assumption: fixed position of customer name
		}
		else{ #normal routine for non-Customer string
			($line_num, $col_num, $string_len) = find_string($lines_ref_sub, $general_list_sub{$general_keys_sub[$ind]});
		}
	
		#if searched string exists -> get the actual data (might be empty)
		if ($line_num != -1){
			$string_answer = get_string($lines_sub[$line_num], $col_num + $string_len);
			if($string_answer eq ""){
				die("No $general_keys_sub[$ind]!");
			}
			#Check if data is a Contact -> if yes, use different format
			elsif(index($general_keys_sub[$ind], "Contact") != -1  ){
				#divive first and last name
				my $first_name;
				my $last_name;
				my $dot_index = index($string_answer, ".");
								#substr($string_input, $i, 1)
				if($dot_index != -1){
					$first_name = substr($string_answer, 0, $dot_index);
					$last_name = substr($string_answer, $dot_index + 1, length($string_answer) - ($dot_index + 1));
				}
				else{
					$last_name = $string_answer; # if not dot for separation found -> assumption: only last name
				}
				
				#output full contact info to .xml file
				print $filehandle_sub "<$general_keys_sub[$ind]><Contact>\n";
				print $filehandle_sub "<FirstName>".$first_name."</FirstName>\n";
				print $filehandle_sub "<LastName>".$last_name."</LastName>\n";
				print $filehandle_sub "</Contact></$general_keys_sub[$ind]>\n";
			}
			#normal data format
			else{
				print $filehandle_sub "<$general_keys_sub[$ind]>".$string_answer."</$general_keys_sub[$ind]>\n";
			}
		}
		else{ #if searched string was not found for the requested categorie
			print "No $general_keys_sub[$ind] found!";
		}
	}					
	print $filehandle_sub "</General>\n";
	print "Header creating completed.\n";
}

#Extracts the <Layers> parts from the .txt-file and writes them in the .xml file
#Input variables:
#	$lines_ref_sub			reference to the array containing the form
#	$filehandle_sub			required to write to the file
#	$layers_list_ref_sub		contains the reference to the list of keys - hash pairs for the general section	
#	$layers_keys_ref_sub		contains the reference to the array of keys for the general section
#Output variables:
#	none
sub write_layers{
	my $n = scalar(@_);
	#check for correct amount of inputs
	if($n != 4){
		die("Too few input parameters in write_layers");
	}
	my $lines_ref_sub = $_[0];
	my @lines_sub = @$lines_ref_sub;
	my ($filehandle_sub) = $_[1];
	my $layers_list_ref_sub = $_[2];
	my $layers_keys_ref_sub = $_[3];
	my %layers_list_sub = %$layers_list_ref_sub;
	my @layers_keys_sub = @$layers_keys_ref_sub;
	my $layers_keys_sub_length = @layers_keys_sub;
	
	#Search for lines that contain "LEVEL"
	my $search_string = "LEVEL";
	my @filtered_lines;	#has the indexes for the relevant lines
	for(my $ind = 0; $ind < scalar(@lines_sub); $ind++){
		my ($line, $column, $length) = find_string($lines_ref_sub, $search_string);
		my $string_answer = get_string($lines_sub[$ind], $column);
		
		#filter out lines that contain "LEVEL" with additions (e.q. "LEVEL INFORMATION")
		if($string_answer eq $search_string){
			
			#get table into an array and put reference to that array into @filtered_lines
			my @level_array;
			my $line_amount = 1;
			$level_array[$line_amount - 1] = $lines_sub[$ind];
			my $table_content = 0; #boolean to check if already inside content of table (and not header)
			#count lines that contain table and put them into @level_array
			for(my $counter = $ind + 1; $counter < scalar(@lines_sub); $counter++){
				#check if the second character on a line is "-" or "X"
				#yes (= "-") and $table_content is true -> end of table reached
				if((substr($lines_sub[$counter], 1, 1) eq "-") and $table_content == 1){
					last; #end for-loop
				}#yes (= "X") and $table_content is true -> end of table reached
				elsif((substr($lines_sub[$counter], 1, 1) eq "X") and $table_content == 1){
					last; #end for-loop
				}
				#yes, but $table_content is false -> content of table is starting
				elsif(substr($lines_sub[$counter], 1, 1) eq "-"){
					$table_content = 1;
					$line_amount++;
					$level_array[$line_amount - 1] = $lines_sub[$counter];
				}
				#no, somewhere inside the table
				else{
					$line_amount++;
					$level_array[$line_amount - 1] = $lines_sub[$counter];
				}
			}
			#put reference to array into @filtered_lines
			my $array_len = @filtered_lines;
			$filtered_lines[$array_len] = \@level_array;				
		}
	}
	
	
	#Get amount of layers
	#assumption: level/layer number always in first column
	my $layer_amount = 0;
	for(my $ind = 0; $ind < scalar(@filtered_lines); $ind++){
		my $ref = $filtered_lines[$ind];
		my @array_var = @$ref;
		
		#check last line of table(s) to get number of layers
		my $string1 = $array_var[scalar(@array_var) - 1];
		#remove first |
		$string1 = substr($string1, 1, length($string1) - 1);
		#get index of next |
		my $line_pos = index($string1, "|");
		#max. level is the number until the | (might include some spaces)
		if($line_pos != -1){
			my $layer_stack = substr($string1, 0, $line_pos - 1);
			#compare layer amount for different tables -> should be equal
			if($layer_amount == 0){
				$layer_amount = $layer_stack;
			}
			elsif($layer_amount != $layer_stack){
				die("Different anount of layers in tables!");
			}
			
			$layer_amount = substr($string1, 0, $line_pos - 1);
		}
		else{
			die("Error in layer tables!");
		}
	}
	
	
	print $filehandle_sub "<Layers>\n";
	#for each layer
	for(my $ind = 0; $ind < $layer_amount; $ind++){
		print $filehandle_sub "<Layer>\n";
		print $filehandle_sub "<LayerNumber>", $ind+1, "</LayerNumber>\n";
		
		my $category = "MASK CODIFICATION";
		my $string_result = read_table($filtered_lines[0], $category, $ind);
		print $filehandle_sub "<LayerName>".$string_result."</LayerName>\n";
		
		$category = "REV";
		$string_result = read_table($filtered_lines[1], $category, $ind);
		print $filehandle_sub "<Revision>".$string_result."</Revision>\n";
		
		$category = "QTY";
		$string_result = read_table($filtered_lines[0], $category, $ind);
		print $filehandle_sub "<Quantity>".$string_result."</Quantity>\n";
		
		for(my $i = 0; $i < $layers_keys_sub_length; $i++){
			my ($line, $col, $length) = find_string($lines_ref_sub, $layers_list_sub{$layers_keys_sub[$i]});
			my $string_answer = get_string($lines_sub[$line], $col + $length);
			print $filehandle_sub "<$layers_keys_sub[$i]>".$string_answer."</$layers_keys_sub[$i]>\n";
		}		
		
		$category = "FIELD";
		$string_result = read_table($filtered_lines[1], $category, $ind);
		print $filehandle_sub "<FieldTone>".$string_result."</FieldTone>\n";
		print $filehandle_sub "</Layer>\n";
	}
	print $filehandle_sub "</Layers>\n";
	
	
	print "Layers creating completed.\n";
}