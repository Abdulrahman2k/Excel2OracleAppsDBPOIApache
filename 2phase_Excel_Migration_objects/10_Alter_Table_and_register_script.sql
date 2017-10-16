Alter Table TGCUSTOM.XXTG_CA_HEADERS_ALL 
add CHANGE_IN_ADD_FLAG VARCHAR2(1);


Alter Table TGCUSTOM.XXTG_CA_HEADERS_ALL 
add ADDRESS_APPROVAL_STATUS VARCHAR2(240);

Alter Table TGCUSTOM.XXTG_CA_HEADERS_ALL 
add ADDRESS_APPROVED_FLAG VARCHAR2(1);

Alter Table TGCUSTOM.xxtg_ca_headers_all 
add CHANGE_IN_ADD_APPROVAL_FLAG VARCHAR2(1);


Alter Table TGCUSTOM.xxtg_ca_headers_all 
add CHANGE_IN_DEP_FLAG VARCHAR2(1);


Alter Table TGCUSTOM.xxtg_ca_headers_all 
add  ADDRESS_APPROVED_DATE DATE;

Alter Table TGCUSTOM.XXTG_CA_LINES_ALL 
add ADDRESS_REJECT_FLAG VARCHAR2(1);


--DESC XXTG_CA_HEADERS_ALL  -->


SELECT * FROM FND_APPLICATION WHERE APPLICATION_SHORT_NAME LIKE 'TG%';


begin
XXTG_CUSTOM_TAB_REG 
(
--errbuff           OUT VARCHAR2, 
-- retcode           OUT NUMBER, 
 i_schema_name     =>'TGCUSTOM',  
 i_appl_short_name =>'TGCUST', 
 i_action          =>'3', 
 i_table_name      =>'XXTG_CA_HEADERS_ALL', --IN VARCHAR2, 
 i_table_type      =>'T', --IN VARCHAR2 DEFAULT 'T', 
 i_column_name     =>'CHANGE_IN_DEP_FLAG' 
);
COMMIT;
END;


begin
XXTG_CUSTOM_TAB_REG 
(
--errbuff           OUT VARCHAR2, 
-- retcode           OUT NUMBER, 
 i_schema_name     =>'TGCUSTOM', 
 i_appl_short_name =>'TGCUST', 
 i_action          =>'3', 
 i_table_name      =>'XXTG_CA_HEADERS_ALL', --IN VARCHAR2, 
 i_table_type      =>'T', --IN VARCHAR2 DEFAULT 'T', 
 i_column_name     =>'ADDRESS_APPROVED_DATE' 
);
COMMIT;
END;



begin
XXTG_CUSTOM_TAB_REG 
(
--errbuff           OUT VARCHAR2, 
-- retcode           OUT NUMBER, 
 i_schema_name     =>'TGCUSTOM', 
 i_appl_short_name =>'TGCUST', 
 i_action          =>'3', 
 i_table_name      =>'XXTG_CA_HEADERS_ALL', --IN VARCHAR2, 
 i_table_type      =>'T', --IN VARCHAR2 DEFAULT 'T', 
 i_column_name     =>'CHANGE_IN_ADD_FLAG' 
);
COMMIT;
END;

begin
XXTG_CUSTOM_TAB_REG 
(
--errbuff           OUT VARCHAR2, 
-- retcode           OUT NUMBER, 
 i_schema_name     =>'TGCUSTOM',
 i_appl_short_name =>'TGCUST', 
 i_action          =>'3', 
 i_table_name      =>'XXTG_CA_HEADERS_ALL', --IN VARCHAR2, 
 i_table_type      =>'T', --IN VARCHAR2 DEFAULT 'T', 
 i_column_name     =>'CHANGE_IN_ADD_APPROVAL_FLAG' 
);
COMMIT;
END;








begin
XXTG_CUSTOM_TAB_REG 
(
--errbuff           OUT VARCHAR2, 
-- retcode           OUT NUMBER, 
 i_schema_name     =>'TGCUSTOM',
 i_appl_short_name =>'TGCUST', 
 i_action          =>'3', 
 i_table_name      =>'XXTG_CA_HEADERS_ALL', --IN VARCHAR2, 
 i_table_type      =>'T', --IN VARCHAR2 DEFAULT 'T', 
 i_column_name     =>'ADDRESS_APPROVAL_STATUS' 
);
COMMIT;
END;

begin
XXTG_CUSTOM_TAB_REG 
(
--errbuff           OUT VARCHAR2, 
-- retcode           OUT NUMBER, 
 i_schema_name     =>'TGCUSTOM',
 i_appl_short_name =>'TGCUST', 
 i_action          =>'3', 
 i_table_name      =>'XXTG_CA_HEADERS_ALL', --IN VARCHAR2, 
 i_table_type      =>'T', --IN VARCHAR2 DEFAULT 'T', 
 i_column_name     =>'ADDRESS_APPROVED_FLAG' 
);
COMMIT;
END;

begin
XXTG_CUSTOM_TAB_REG 
(
--errbuff           OUT VARCHAR2, 
-- retcode           OUT NUMBER, 
 i_schema_name     =>'TGCUSTOM',
 i_appl_short_name =>'TGCUST', 
 i_action          =>'3', 
 i_table_name      =>'XXTG_CA_LINES_ALL', --IN VARCHAR2, 
 i_table_type      =>'T', --IN VARCHAR2 DEFAULT 'T', 
 i_column_name     =>'ADDRESS_REJECT_FLAG' 
);
COMMIT;
END;