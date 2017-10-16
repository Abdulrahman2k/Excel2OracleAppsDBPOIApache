create or replace PROCEDURE XXTG_REGISTER_TABLE(LC_APP_SHORT_NAME VARCHAR2, LC_TABLE_NAME VARCHAR2)
IS 
   vc_appl_short_name    VARCHAR2 (40) ;--:= 'TGCUST';
   vc_tab_name           VARCHAR2 (32) ;--:= 'XXTG_CONTRACT_AUDIT_LOG';
   vc_tab_type          CONSTANT VARCHAR2 (50) := 'T';
   vc_next_extent       CONSTANT NUMBER        := 512;
   vc_pct_free          CONSTANT NUMBER        := 10;
   vc_pct_used          CONSTANT NUMBER        := 70;
BEGIN   -- Start Register Custom Table
   -- Get the table details in cursor
   vc_appl_short_name := LC_APP_SHORT_NAME;
   vc_tab_name        := LC_TABLE_NAME;
   FOR table_detail IN (SELECT table_name, tablespace_name, pct_free, pct_used,
                              ini_trans, max_trans, initial_extent,
                              next_extent
                          FROM dba_tables
                         WHERE table_name = vc_tab_name)
   LOOP
      -- Call the API to register table
      ad_dd.register_table (p_appl_short_name => vc_appl_short_name,
                            p_tab_name        => table_detail.table_name,
                            p_tab_type        => vc_tab_type,
                            p_next_extent     => NVL(table_detail.next_extent, vc_next_extent),
                            p_pct_free        => NVL(table_detail.pct_free, vc_pct_free),
                            p_pct_used        => NVL(table_detail.pct_used, vc_pct_used)
                           );
   END LOOP; -- End Register Custom Table

   -- Start Register Columns
   -- Get the column details of the table in cursor
   FOR table_columns IN (SELECT column_name, column_id, data_type, data_length,
                               nullable
                          FROM all_tab_columns
                         WHERE table_name = vc_tab_name)
   LOOP
      -- Call the API to register column
      ad_dd.register_column (p_appl_short_name      => vc_appl_short_name,
                             p_tab_name             => vc_tab_name,
                             p_col_name             => table_columns.column_name,
                             p_col_seq              => table_columns.column_id,
                             p_col_type             => table_columns.data_type,
                             p_col_width            => table_columns.data_length,
                             p_nullable             => table_columns.nullable,
                             p_translate            => 'N',
                             p_precision            => NULL,
                             p_scale                => NULL
                            );
   END LOOP;   -- End Register Columns
   -- Start Register Primary Key
   -- Get the primary key detail of the table in cursor
   FOR all_keys IN (SELECT constraint_name, table_name, constraint_type
                      FROM all_constraints
                     WHERE constraint_type = 'P' AND table_name = vc_tab_name)
   LOOP
      -- Call the API to register primary_key
      ad_dd.register_primary_key (p_appl_short_name      => vc_appl_short_name,
                                  p_key_name             => all_keys.constraint_name,
                                  p_tab_name             => all_keys.table_name,
                                  p_description          => 'Register primary key',
                                  p_key_type             => 'S',
                                  p_audit_flag           => 'Y',
                                  p_enabled_flag         => 'Y'
                                 );
      -- Start Register Primary Key Column
      -- Get the primary key column detial in cursor
      FOR all_columns IN (SELECT column_name, POSITION
                            FROM dba_cons_columns
                           WHERE table_name = all_keys.table_name
                             AND constraint_name = all_keys.constraint_name)
      LOOP
         -- Call the API to register primary_key_column
         ad_dd.register_primary_key_column
                                     (p_appl_short_name      => vc_appl_short_name,
                                      p_key_name             => all_keys.constraint_name,
                                      p_tab_name             => all_keys.table_name,
                                      p_col_name             => all_columns.column_name,
                                      p_col_sequence         => all_columns.POSITION
                                     );
      END LOOP; -- End Register Primary Key Column
   END LOOP;    -- End Register Primary Key

   COMMIT;
END XXTG_REGISTER_TABLE;