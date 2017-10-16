create or replace PROCEDURE XXTG_CUSTOM_TAB_REG 
(
--errbuff           OUT VARCHAR2, 
-- retcode           OUT NUMBER, 
 i_schema_name     IN VARCHAR2 DEFAULT NULL, 
 i_appl_short_name IN VARCHAR2, 
 i_action          IN VARCHAR2 DEFAULT '2', 
 i_table_name      IN VARCHAR2, 
 i_table_type      IN VARCHAR2 DEFAULT 'T', 
 i_column_name     IN VARCHAR2 DEFAULT NULL 
) 
IS 
 translate_flag       VARCHAR2(1) DEFAULT 'N'; 
 err_wrk       VARCHAR2(255) := ''; 
 schema_name                    ALL_TAB_COLUMNS.OWNER%TYPE;

CURSOR add_all_table_info_cur IS 
   SELECT TABLE_NAME, NEXT_EXTENT, PCT_FREE, PCT_USED 
   FROM ALL_TABLES 
   WHERE OWNER = schema_name 
   ORDER BY 1;

CURSOR add_all_tab_col_info_cur IS 
   SELECT TABLE_NAME, COLUMN_NAME, COLUMN_ID, DATA_TYPE, 
   DATA_LENGTH, NULLABLE, DATA_PRECISION, DATA_SCALE 
   FROM ALL_TAB_COLUMNS 
   WHERE OWNER = schema_name 
   ORDER BY 1, 3;

CURSOR add_sin_table_info_cur IS 
   SELECT TABLE_NAME, NEXT_EXTENT, PCT_FREE, PCT_USED 
   FROM ALL_TABLES 
   WHERE OWNER = schema_name 
   AND   TABLE_NAME = i_table_name;

CURSOR add_sin_tab_col_info_cur IS 
   SELECT TABLE_NAME, COLUMN_NAME, COLUMN_ID, DATA_TYPE, 
   DATA_LENGTH, NULLABLE, DATA_PRECISION, DATA_SCALE 
   FROM ALL_TAB_COLUMNS 
   WHERE OWNER = schema_name 
   AND   TABLE_NAME = i_table_name 
   ORDER BY 1, 3;

CURSOR delete_column_info_cur IS 
   SELECT TABLE_NAME, COLUMN_NAME 
   FROM ALL_TAB_COLUMNS 
   WHERE OWNER = schema_name 
   AND   TABLE_NAME = i_table_name 
   AND   COLUMN_NAME = i_column_name;

CURSOR delete_table_info_cur IS 
   SELECT TABLE_NAME 
   FROM ALL_TABLES 
   WHERE OWNER = schema_name 
   AND   TABLE_NAME = i_table_name;

add_all_table_info_rec         add_all_table_info_cur%ROWTYPE; 
add_all_tab_col_info_rec       add_all_tab_col_info_cur%ROWTYPE; 
add_sin_table_info_rec         add_sin_table_info_cur%ROWTYPE; 
add_sin_tab_col_info_rec       add_sin_tab_col_info_cur%ROWTYPE; 
delete_column_info_rec         delete_column_info_cur%ROWTYPE; 
delete_table_info_rec          delete_table_info_cur%ROWTYPE;

TYPE column_rec_rectype IS RECORD 
     (TAB_NAME                 ALL_TAB_COLUMNS.TABLE_NAME%TYPE, 
      COL_NAME                 ALL_TAB_COLUMNS.COLUMN_NAME%TYPE, 
      COL_SEQ                  ALL_TAB_COLUMNS.COLUMN_ID%TYPE, 
      COL_TYPE                 ALL_TAB_COLUMNS.DATA_TYPE%TYPE, 
      COL_WIDTH                ALL_TAB_COLUMNS.DATA_LENGTH%TYPE, 
      NULLABLE                 ALL_TAB_COLUMNS.NULLABLE%TYPE, 
      PRECISION                ALL_TAB_COLUMNS.DATA_PRECISION%TYPE, 
      SCALE                    ALL_TAB_COLUMNS.DATA_SCALE%TYPE 
     );

column_rec         column_rec_rectype;

error_code           NUMBER := SQLCODE; 
error_msg         VARCHAR2(100) := SQLERRM;

invalid_parameter_table        EXCEPTION; 
invalid_parameter_column       EXCEPTION;

BEGIN

--  errbuff := ''; 
  err_wrk := ''; 
--  retcode := 0;

  IF i_schema_name IS NOT NULL 
    THEN 
      schema_name := i_schema_name; 
      ELSE 
      SELECT ORACLE_USERNAME 
                     INTO schema_name 
                     FROM FND_ORACLE_USERID 
                     WHERE ORACLE_ID = 
                       (SELECT ORACLE_ID 
                        FROM FND_PRODUCT_INSTALLATIONS 
                        WHERE STATUS = 'L' 
                        AND APPLICATION_ID = 
                          (SELECT APPLICATION_ID 
                           FROM FND_APPLICATION 
                           WHERE APPLICATION_SHORT_NAME = i_appl_short_name 
                          ) 
                       ) 
       ; 
  END IF;

  IF i_action = '1'  -- '1' Register All Tables and All Columns 
    THEN 
      IF i_table_name IS NOT NULL 
        THEN 
          RAISE invalid_parameter_table; 
      END IF;

      IF i_column_name IS NOT NULL 
        THEN 
          RAISE invalid_parameter_column; 
      END IF;


      OPEN add_all_table_info_cur; 
        LOOP 
          FETCH add_all_table_info_cur INTO add_all_table_info_rec; 
          EXIT WHEN add_all_table_info_cur%NOTFOUND;

                AD_DD.REGISTER_TABLE (i_appl_short_name, 
                                      add_all_table_info_rec.table_name, 
                                      i_table_type, 
                                      add_all_table_info_rec.next_extent, 
                                      add_all_table_info_rec.pct_free, 
                                      add_all_table_info_rec.pct_used);

        END LOOP ADD_ALL_TABLE_LOOP; 
      CLOSE add_all_table_info_cur;


        OPEN add_all_tab_col_info_cur; 
          LOOP 
            FETCH add_all_tab_col_info_cur INTO add_all_tab_col_info_rec; 
            EXIT WHEN add_all_tab_col_info_cur%NOTFOUND;

-- This section fixes the default for DATE to be Size 9

            IF add_all_tab_col_info_rec.data_type = 'DATE' 
              THEN add_all_tab_col_info_rec.data_length := 9; 
            END IF;

              AD_DD.REGISTER_COLUMN (i_appl_short_name, 
                                     add_all_tab_col_info_rec.table_name, 
                                     add_all_tab_col_info_rec.column_name, 
                                     add_all_tab_col_info_rec.column_id, 
                                     add_all_tab_col_info_rec.data_type, 
                                     add_all_tab_col_info_rec.data_length, 
                                     add_all_tab_col_info_rec.nullable, 
                                     translate_flag, 
                                     add_all_tab_col_info_rec.data_precision, 
                                     add_all_tab_col_info_rec.data_scale);

           END LOOP ADD_ALL_COLUMN_LOOP; 
         CLOSE add_all_tab_col_info_cur;

--         retcode := 0; 
  END IF;

  IF i_action = '2' -- '2' Add A Table And All of its Columns 
    THEN 
      IF i_table_name is NULL 
      OR i_column_name IS NOT NULL 
        THEN 
          RAISE invalid_parameter_table; 
      END IF;

    OPEN add_sin_table_info_cur; 
    LOOP 
    FETCH add_sin_table_info_cur INTO add_sin_table_info_rec; 
    EXIT WHEN add_sin_table_info_cur%NOTFOUND;

      AD_DD.REGISTER_TABLE (i_appl_short_name, 
                            add_sin_table_info_rec.table_name, 
                            i_table_type, 
                            add_sin_table_info_rec.next_extent, 
                            add_sin_table_info_rec.pct_free, 
                            add_sin_table_info_rec.pct_used);

    END LOOP ADD_SINGLE_TABLE_LOOP; 
    CLOSE add_sin_table_info_cur;

    OPEN add_sin_tab_col_info_cur; 
    LOOP 
    FETCH add_sin_tab_col_info_cur INTO add_sin_tab_col_info_rec; 
    EXIT WHEN add_sin_tab_col_info_cur%NOTFOUND;

-- This section fixes the default for DATE to be Size 9

      IF add_sin_tab_col_info_rec.data_type = 'DATE' 
        THEN add_sin_tab_col_info_rec.data_length := 9; 
      END IF;

      AD_DD.REGISTER_COLUMN (i_appl_short_name, 
                                     add_sin_tab_col_info_rec.table_name, 
                                     add_sin_tab_col_info_rec.column_name, 
                                     add_sin_tab_col_info_rec.column_id, 
                                     add_sin_tab_col_info_rec.data_type, 
                                     add_sin_tab_col_info_rec.data_length, 
                                     add_sin_tab_col_info_rec.nullable, 
                                     translate_flag, 
                                     add_sin_tab_col_info_rec.data_precision, 
                                     add_sin_tab_col_info_rec.data_scale);

    END LOOP ADD_SINGLE_TAB_COL_LOOP; 
    CLOSE add_sin_tab_col_info_cur;

--    retcode := 0;

  END IF;

  IF i_action = '3'  -- '3' Add A Column To Existing Table Definition 
    THEN 
      IF i_table_name IS NULL 
      OR i_column_name is NULL 
        THEN RAISE invalid_parameter_column; 
      END IF;

        SELECT TABLE_NAME, COLUMN_NAME, COLUMN_ID, DATA_TYPE, 
        DATA_LENGTH, NULLABLE, DATA_PRECISION, DATA_SCALE 
        INTO column_rec 
        FROM ALL_TAB_COLUMNS 
        WHERE OWNER = schema_name 
        AND   TABLE_NAME = i_table_name 
        AND   COLUMN_NAME = i_column_name;

-- This section fixes the default for DATE to be Size 9

        IF column_rec.col_type = 'DATE' 
          THEN column_rec.col_width := 9; 
        END IF; 
 

        AD_DD.REGISTER_COLUMN (i_appl_short_name, 
                               column_rec.tab_name, 
                               column_rec.col_name, 
                               column_rec.col_seq, 
                               column_rec.col_type, 
                               column_rec.col_width, 
                               column_rec.nullable, 
                               translate_flag, 
                               column_rec.precision, 
                               column_rec.scale); 
 

--    retcode := 0;

    END IF;

  IF i_action = '4' -- '4' Delete a Column 
    THEN 
      IF i_table_name IS NULL 
      OR i_column_name is NULL 
        THEN RAISE invalid_parameter_column;

      END IF;

      AD_DD.DELETE_COLUMN(i_appl_short_name, 
                          i_table_name, 
                          i_column_name);

--  retcode := 0;

  END IF;

  IF i_action = '5' -- '5' Delete A Table and All Associated Columns 
    THEN 
      IF i_table_name IS NULL 
      OR i_column_name IS NOT NULL 
        THEN RAISE invalid_parameter_table;

      END IF;

      AD_DD.DELETE_TABLE(i_appl_short_name, 
                         i_table_name); 
  END IF;

  IF i_action = '6' -- '6' Delete All Tables For The Schema 
    THEN 
      IF i_table_name IS NOT NULL 
      OR i_column_name IS NOT NULL 
        THEN RAISE invalid_parameter_table;

      END IF;

      OPEN add_all_table_info_cur; 
        LOOP 
          FETCH add_all_table_info_cur INTO add_all_table_info_rec; 
          EXIT WHEN add_all_table_info_cur%NOTFOUND;

                AD_DD.DELETE_TABLE (i_appl_short_name, 
                                    add_all_table_info_rec.table_name);

        END LOOP DEL_ALL_TABLE_LOOP; 
      CLOSE add_all_table_info_cur;

--  retcode := 0;

  END IF;

  IF error_code = 0 
    THEN err_wrk:='Process Completed: Shrt Nm: '; 
         err_wrk:= err_wrk||i_appl_short_name||' Sch Nm: '||schema_name; 
         err_wrk:= err_wrk||' Tbl Nm: '||i_table_name||' Col Nm: '; 
         err_wrk:= err_wrk||i_column_name||' Act: '||i_action; 
         err_wrk:= err_wrk||' 1=> Reg all tables/col 2=> Reg a Tab/Cols'; 
         err_wrk:= err_wrk||' 3=> Reg a Col 4=> Del A Col'; 
         err_wrk:= err_wrk||' 5=> Del Tab/Cols 6=> Del All Tabs/Cols'; 
--         errbuff:= err_wrk; 
--       retcode := 0;

  END IF;

EXCEPTION

  WHEN invalid_parameter_table 
  THEN err_wrk:='Inv Tab Spec.  Col is Incorrect or Not Needed: Shrt Nm: '; 
       err_wrk:= err_wrk||i_appl_short_name||' Sch Nm: '||schema_name; 
       err_wrk:= err_wrk||' Tbl Nm: '||i_table_name||' Col Nm: '; 
       err_wrk:= err_wrk||i_column_name||' Act: '||i_action; 
       err_wrk:= err_wrk||' 1=> Reg all tables/col 2=> Reg a Tab/Cols'; 
       err_wrk:= err_wrk||'5=> Del a Tab/Cols 6=> Del All Tabs'; 
--       errbuff:= err_wrk; 
--       retcode:= 2; 
 

  WHEN invalid_parameter_column 
  THEN err_wrk:='Inv Col Spec.  Tab is Incorrect or Not Needed: Shrt Nm: '; 
       err_wrk:= err_wrk||i_appl_short_name||' Sch Nm: '||schema_name; 
       err_wrk:= err_wrk||' Tbl Nm: '||i_table_name||' Col Nm: '; 
       err_wrk:= err_wrk||i_column_name||' Act: '||i_action; 
       err_wrk:= err_wrk||' 1=> Reg all tables/col 2=> Reg a Tab/Cols'; 
       err_wrk:= err_wrk||' 3=> Reg a Col 4=> Del A Col'; 
       err_wrk:= err_wrk||' 5=> Del Tab/Cols '; 
--       errbuff:= err_wrk; 
--       retcode := 2;

  WHEN OTHERS 
  THEN

  err_wrk:= 'ORA Err: '||error_code||error_msg; 
--       errbuff:= err_wrk; 
--       retcode := 2;

END XXTG_CUSTOM_TAB_REG;