CREATE INDEX code_type_ps_index ON etl_input.patient_sluten_long (code_type);
CREATE INDEX code_type_po_index ON etl_input.patient_oppen_long (code_type);
CREATE INDEX code_type_pdk_index ON etl_input.patient_dag_kiru_long (code_type);
CREATE INDEX code_type_d_index ON etl_input.death_long (code_type);

CREATE INDEX code_ps_index ON etl_input.patient_sluten_long (code);
CREATE INDEX code_po_index ON etl_input.patient_oppen_long (code);
CREATE INDEX code_pdk_index ON etl_input.patient_dag_kiru_long (code);
CREATE INDEX code_d_index ON etl_input.death_long (code);
