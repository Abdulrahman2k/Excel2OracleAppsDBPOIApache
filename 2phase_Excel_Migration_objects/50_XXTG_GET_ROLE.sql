--------------------------------------------------------
--  File created - Sunday-August-20-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function XXTG_GET_ROLE
--------------------------------------------------------
SET DEFINE OFF;
  CREATE OR REPLACE FUNCTION "APPS"."XXTG_GET_ROLE" 
(
  ROLE_NAME IN VARCHAR2 
) RETURN VARCHAR2 IS
---------------------------------------------------------
----Created by abdulrahman for getting role  20-Aug-2017
---------------------------------------------------------
CURSOR XXTG_ROLE_CUR (LC_ROLE_NAME VARCHAR2) IS
    SELECT 'PQH_ROLE:' || R.ROLE_ID  ROLES
        FROM PQH_ROLES R
       WHERE UPPER(TRIM(ROLE_NAME)) = UPPER(TRIM(LC_ROLE_NAME));
       LN_ROLE  VARCHAR2(240);

BEGIN
  FOR XXTG_REC IN XXTG_ROLE_CUR(ROLE_NAME)
    LOOP
      LN_ROLE:= XXTG_REC.ROLES;
    END LOOP;
  RETURN LN_ROLE;
END XXTG_GET_ROLE;

/
