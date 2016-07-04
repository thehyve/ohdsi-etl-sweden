# -*- coding: utf-8 -*-
"""
Created on Tue May 24 10:59:37 2016

@author: Maxim

Performs two transitions:
 - Wide to long format for each procedure/diagnostic/ekod code
 - Adds visit identifier. Identifies which codes belong together to the same visit.
"""
import re, copy, csv, os, sys
from MergeCSV import MergeCSV as MergeCSV

HAS_HEADER = True
#DELIMITER = ','

def is_code_column( column_name ):
    column_name = column_name.lower()
    if re.match(r'morsak\d|dbgrund\d', column_name):
        return True
    else:
        return False

#def create_csv_line( values, delimiter ):
#    values = [x.replace(delimiter,'') for x in values]
#    line = delimiter.join( values )
#    line += '\n'
#    return line

def main( input_files, path_out ):

    for filename, target_table in input_files.items():
        filebase, extension = filename.rsplit('.',1)
        filename_out = '%s_long.csv' % ( filebase)

        if os.path.exists(filename_out):
            print "Skipped '%s'" % target_table
            print "\tBecause long format file '%s' already exists." % filename_out
            continue
        elif not os.path.exists(filename):
            print "%s does not exist. Please add it." % filename
            continue
        else:
            print "Processing %s" % filename

        merger = MergeCSV( filename_out )

        with open(filename,'r') as f_in:
            # Read csv in the Excel dialect
            csv_reader = csv.reader(f_in, dialect='excel')

            # Read in the header with column names
            column_names = csv_reader.next()
            column_names = [x.lower() for x in column_names]
            # Determine which columns contain codes (morsak#)
            code_columns_bool = [is_code_column(col_name) for col_name in column_names]

            # Write the new header
            new_header = [column_name for column_name, is_code_bool in zip(column_names, code_columns_bool) if not is_code_bool]
            new_header.extend( ['code_type','code'] )
            merger.add_line( new_header )

            for values_array in csv_reader:

                # All values that are NOT morsak codes
                visit_values = [value for value, is_code_bool in zip(values_array, code_columns_bool) if not is_code_bool]

                # Write row for each morsak code with the same visit details
                visit_is_inserted = False
                for column_name, is_code_bool, value in zip(column_names, code_columns_bool, values_array):
                    # Write if column contains a code and if code value present
                    if is_code_bool and value:
                        out_values = copy.copy(visit_values)
                        # code_type (e.g. morsak3) and the code (e.g. 'I5099')
                        out_values.append(column_name)
                        out_values.append(value)

                        merger.add_line( out_values )

                        visit_is_inserted = True

                # If no morsak code found, insert visit without code
                if not visit_is_inserted:
                    visit_values.append('')
                    visit_values.append('')
                    merger.add_line( visit_values )
        # Close the outfile
        merger.close()

if __name__ == '__main__':
    try:
        source_folder = sys.argv[1]
    except:
        source_folder = '../source_tables'

    f_file_overview = open( os.path.join(source_folder, 'overview_source_files.csv') )
    csv_file_overview = csv.reader( f_file_overview, dialect='excel' )
    csv_file_overview.next() #remove header

    input_files = {}
    for row in csv_file_overview:
        # If a patient_register
        folder = row[1]
        filename = row[0]
        target_table = row[2]
        if folder == 'death_register' and 'long' not in filename: #hack to not by accident process the long files
            input_files[ os.path.join(source_folder,folder,filename) ] = filename

    path_out = os.path.join( source_folder, 'death_register' )
    main(input_files, path_out)
