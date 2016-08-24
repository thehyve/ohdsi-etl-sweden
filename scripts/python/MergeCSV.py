# -*- coding: utf-8 -*-
"""
Created on Thu Apr  7 16:07:59 2016

@author: Maxim

Merge all csv files in the current directory.

"""

import os, sys, csv, copy

class MergeCSV(object):
    """
    Merge multiple text files. The one is appended to the other.
    Only single lines loaded into memory.
    """
    def __init__( self, output_filename = 'merged.csv', output_header = True ):
        """
        output_header - boolean or list of column names.
                        If header given as list, all files are aligned to this header.
                        If True, the header from the first file is used as output_header.
                        If False, no header is used and all lines are simply added.
        """
        self.out_filename = output_filename
        self.n_files_added = 0
        self.n_lines_added = 0

        # Create  new out file
        self.f_out = open(self.out_filename, 'w')
        self.csv_writer = csv.writer( self.f_out, dialect = 'excel')

        if output_header:
            self.has_header = True
            # If header specified, add it. If not, the first header of the first file is used.
            if type( output_header ) == list:
                self._set_output_header( output_header )
                self.add_line( output_header )
        else:
            self.has_header = False
            self.output_header = None

    def close(self):
        self.f_out.close()

    def add_file(self, filename ):
        f_in = open( filename, 'r')
        csv_reader = csv.reader( f_in, dialect='excel' )

        # Skip header if present
        if self.has_header:
            header = next(csv_reader)
            header = [x.lower() for x in header]
            self._set_current_header( header )

        # Copy every line from infile to outfile
        for values in csv_reader:
            if self.has_header:
                values = self._align( values )
            self.add_line( values )
#            break

        self.n_files_added += 1

        f_in.close()

    def add_line( self, values ):
        #with open(self.out_filename, 'a') as f_out:    #Note: opening the file a lot. Speed improvement?
        #self.f_out.write( line )
        self.csv_writer.writerow( values )
        self.n_lines_added += 1


    def add_folder(self, folder, file_extension = None ):
        """
        Add all files from a folder, with a certain file_extension.
        """
        # List all filenames
        filenames = os.listdir( folder )

        for filename in filenames:
            # Skip files with different file_extension, if file_extension specified.
            extension = filename.split('.')[-1]
            if file_extension and file_extension != extension:
                continue

            file_path = os.path.join( folder, filename )

            # Do not use own file as input
            if file_path == self.out_filename:
                continue

            print("Opening '%s'" % file_path)
            self.add_file( file_path )

    def _set_output_header( self, header_list ):
        """ Processes the output_header """
        self.output_header = copy.copy(header_list) #without copy, the list can be adjusted through values.
#        self.output_header_dict = { column:i for i, column in enumerate(self.output_header_list) }

    def _set_current_header( self, header_list ):
        """ Sets current header and checks whether all values are present in header_list """
        self.current_header = copy.copy(header_list)

        # If no output header inserted yet, set it and write it.
        if self.n_lines_added == 0:
            self._set_output_header( self.current_header )
            self.add_line( self.current_header )

        # Print warning if mismatch in colum names
        for column_name in self.current_header:
            if column_name not in self.output_header:
                print( "WARNING: column '%s' is not present in the output columns of the merge file." % column_name)
                print( "Values from column '%s' will NOT be written to merged file" % column_name)

    def _align(self, values, default_value = ''):
        """ Rearranges the values to comply with output_header columns.
            If output column name not in current column names, input the *default_value*.
            If current column name not in output column names, raise error."""
        # Create dictionary of values, with column name as key.
        values_dict = { column_name:value for column_name, value in zip(self.current_header, values) }

        # Realign by iterating over the output_header
        realigned_values = []
        for column in self.output_header:
            if column in values_dict:
                value = values_dict[ column ]
                realigned_values.append( value )
            else:
                realigned_values.append( default_value )

        return realigned_values


#if __name__ == '__main__':
#
#    try:
#        foldername = sys.argv[1]
#    except:
#        print("Please supply a folder")
##        sys.exit(1)
#        foldername = 'drug registries'
#
#    merger = MergeFiles( os.path.join(foldername,'merged.csv'), False )
#
#    merger.add_folder( foldername, 'csv' )
