# -*- coding: utf-8 -*-
"""
Created on Mon Jun  6 10:36:15 2016
@author: Maxim
Creates a sql script to load the source tables into a postgresql database.
"""
import os, sys, csv, copy

class ColumnFormat(object):

    def __init__(self, source_col_name, data_type_str, required, target_col_name ):
        """
        *data_type_str* - In string the desired data_type for create_table statement
        """
        self.name = source_col_name
        self.target_name = target_col_name
        self.data_type_str = data_type_str
        if required:
            self.is_required = True
        else:
            self.is_required = False

        self.column_index = None
        self.is_set = False
        self.query_created = False # keeps track whether create_query_string is called

    def set_column_index(self, index):
        """ Place at which the index is expected """
        self.column_index = index
        self.set_is_seen(True)

    def set_is_seen(self, v = True):
        self.is_set = v

    def get_is_seen(self):
        return self.is_set

    def get_column_index(self):
        return self.column_index

    def get_target_colname(self):
        return self.target_name

    def create_query_string(self):
        self.query_created = True
        return "%s  %s" % (self.name, self.data_type_str)

    def get_data_type(self):
        return self.data_type_str


class FormatRegistry(object):

    def __init__(self, input_filename, out_table_name, out_schema_name = 'etl_input'):
        self.table_name = "%s.%s" % (out_schema_name, out_table_name)
        self.input_filename = input_filename
        self.column_formats = dict()

        self.columns_out = list()
        self.columns_to_be_created = list() #columns to be added with an alter command.

    def process_column(self ):
        pass

    def set_file_header( self, file_header ):
        """
        Two functions:
         - Checks whether column_format and input header correspond (which column is missing where)
         - Puts columns in the correct order by giving them an index.
        """

        i = 0
        for column_name in file_header:
            column_name = column_name.lower()

            if column_name not in self.column_formats:
                dummy_colname = "%s_DUMMY" % (column_name)
                output_format = ColumnFormat( column_name, 'varchar(255)', 0, dummy_colname )
                # also add to list of additional columns
                self.columns_to_be_created.append( output_format )
                print( "\tWarning: '%s' not recognised. Creating a dummy column '%s'." % (column_name, dummy_colname))
            else:
                input_format = self.column_formats[ column_name ]
                input_format.set_is_seen()
                output_format = copy.copy( input_format )

            output_format.set_column_index( i )
            self.columns_out.append( output_format )
            i += 1

        # Check which columns are not set, but present in the format file.
        for column_format in self.column_formats.values():
            if not column_format.get_is_seen() and column_format.is_required:
                print( "\tWarning: '%s' is required, but not found in input file." % ( column_format.target_name ))
#                raise Warning("Column '%s' is not present in '<filename>', but is a required column." % column_format.name )


    def set_format( self, format_file_path ):
        """
        Creates dictionary of columns with each a column format
        """

        with open(format_file_path, 'r') as f_format:
            csv_reader = csv.reader( f_format, dialect='excel' )
            next(csv_reader) #remove header
            columns = {}
            for row in csv_reader:
                column_name = row[0].lower()

                if column_name in columns:
                    print( "'%s' duplicated in the format file %s" % (column_name, format_file_path))
                    print( "Using first definition")
                    continue

                column_format = ColumnFormat( column_name, row[1], row[2], row[3] )
                self.column_formats[ column_name ] = column_format

    def write_create_table( self, out_filepath ):
        f_out = open(out_filepath, 'w')

        f_out.write( "CREATE TABLE %s (\n" % self.table_name )

        columns_sorted = sorted(self.columns_out, key = lambda x: x.get_column_index() )

        query_lines = []
        for column_format in columns_sorted:
            # Skip column not set (not present in input header)
            if not column_format.is_set:
                continue
            column_query = column_format.create_query_string()
            query_lines.append( column_query )

        f_out.write( ',\n'.join(query_lines) )

        f_out.write( "\n);")

        f_out.close()

    def process_file(self):

        with open(self.input_filename, 'r') as f_in:
            csv_reader = csv.reader( f_in, dialect='excel' )
            header = next(csv_reader)

        self.set_file_header( header )

    def get_column_in_order(self):
        columns_sorted = sorted(self.columns_out, key = lambda x: x.get_column_index() )

        result = []
        for column_format in columns_sorted:
            # Skip column not set (not present in input header)
            if not column_format.is_set:
                continue
            col_name = column_format.get_target_colname()
            result.append( col_name )
        return result

    def create_copy_query( self, encoding ):
        """ Creates a postgresql copy qeury with the columns in the right order """
        template = "\copy %s (%s) FROM '%s' WITH HEADER CSV ENCODING '%s'"

        columns = self.get_column_in_order()
        columns_str = ','.join(columns)

        return template % (self.table_name, columns_str, self.input_filename, encoding)

    def create_add_column_query( self ):
        """ Creates an add_column query for each temp column (not found in original context)"""
        template = "ALTER TABLE %s ADD COLUMN %s %s;"

        query = ""
        for column in self.columns_to_be_created:
            query += template % ( self.table_name, column.get_target_colname(), column.get_data_type() )
            query += '\n'
        return query.strip()

    def create_add_type( self, type_colname, type_value ):
        """ Sets an additional column value for all non null values.
            e.g. sets year for lisa register."""
        template = "UPDATE %s SET %s = '%s' WHERE %s IS NULL;"
        if type_colname in self.column_formats:
            return template % (self.table_name, type_colname, type_value, type_colname)
        else:
            print( "Type column %s is not present in the table." % type_colname)
            return False

def main( source_folder, source_files_overview, schema_name, encoding, out_filepath ):
    # Open the overview file with all the tables listed


    for filename, directory, target_table, format_filename, type_column, type_value in source_files_overview:
        if filename == '*':
            # Get all filenames in the <folder>
            filenames = os.listdir( directory )
            # Extension must be csv or txt
            filenames = filter( lambda x: x[-3::] in ['csv','txt'], filenames)
        else:
            filenames = [ filename ]

        if not format_filename:
            print( "No format filename found for %s" % filename)
            continue

        format_path = os.path.join( source_folder, format_filename )

        for filename in filenames:
            file_path = os.path.join( directory, filename )
            print( "Processing file '%s'" % file_path)

            formatRegistry = FormatRegistry( file_path, target_table, schema_name )
            formatRegistry.set_format( format_path )

            try:
                formatRegistry.process_file( )
            except IOError:
                print( "Warning: could not find '%s'" % file_path)
                continue

            with open(out_filepath, 'a') as f_out:
                f_out.write( formatRegistry.create_add_column_query() )
                f_out.write('\n')
                f_out.write( formatRegistry.create_copy_query( encoding ) )
                f_out.write('\n')
                # If type non_empty, add the create type
                if type_column.strip() != '':
                    f_out.write( formatRegistry.create_add_type( type_column, type_value ) )
                f_out.write('\n\n')
            # print( "" #newline)

def process_overview_file( file_object, source_folder, long_tables_folder ):
    """
    All source tables are placed in the source_folder. The tables in the long format are in the long_tables_folder.
    """
    csv_file_overview = csv.reader( file_object, dialect='excel' )
    next(csv_file_overview) #remove header

    result = []
    for row in csv_file_overview:
        filename, registry_folder, target_table, format_filename, type_column, type_value = row
        directory = os.path.join(source_folder,registry_folder)
        result.append( [filename, directory, target_table, format_filename, type_column, type_value] )

        # Also add preprocessed long patient and death registries
        if registry_folder == 'patient_register' or registry_folder == 'death_register':
            base, extension = filename.rsplit('.',1)
            new_filename = '%s_long.%s' % (base, extension)
            target_table_new = target_table + '_long'
            directory = os.path.join( long_tables_folder, registry_folder )
            result.append( [new_filename, directory, target_table_new, format_filename, type_column, type_value] )

    return result


if __name__ == '__main__':

    FILE_EXTENSION = 'csv'
    SCHEMA_NAME = 'etl_input'
    OUT_FILENAME = 'load_tables.sql'
    OVERVIEW_FILENAME = 'overview_source_files.csv'
    RENDERED_SOURCE_FOLDER = 'rendered_tables'

    try:
        source_folder = sys.argv[1]
        encoding = sys.argv[2]
        output_folder = sys.argv[3]
    except:
        print( "Please supply a folder and encoding")
        print( "Usage: create_copy_sql.py <source_folder> <encoding> <output_folder>")
#        sys.exit(1)
        source_folder = '../source_tables'
        encoding = 'UTF8' # Options are: WIN1252, UTF8, LATIN1
        output_folder = '../scripts/rendered_sql'

    # Create new out_file
    out_filepath = os.path.join( output_folder, OUT_FILENAME )
    open(out_filepath, 'w').close()

    overview_file = os.path.join(source_folder, OVERVIEW_FILENAME)
    with open(overview_file) as f_overview:
        source_files_overview = process_overview_file( f_overview, source_folder, RENDERED_SOURCE_FOLDER )

    main( source_folder, source_files_overview, SCHEMA_NAME, encoding, out_filepath )
