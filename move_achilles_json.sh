# Copy the Achilles data to the Achilles folder
cp -r /media/sf_etl_vm/achilles_data/* /opt/ohdsi_docroot/achilles/data/
# Assign everyone read rights to the data folder. Recursively
chmod -R 755 /opt/ohdsi_docroot/achilles/data/*
