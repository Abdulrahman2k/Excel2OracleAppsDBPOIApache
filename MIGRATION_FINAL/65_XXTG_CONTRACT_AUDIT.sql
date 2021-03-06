set define off;
CREATE OR REPLACE PACKAGE XXTG_CONTRACT_AUDIT AS 
    P_CONC_REQUEST_ID number;
    P_CONTRACT_BATCH NUMBER; 
    P_HIERARCHY_ID NUMBER;
    P_VERSION_ID number; 
    P_PAYROLL_ID number; 
    P_BU_ORG_ID number;
    P_SBU_ORG_ID number;
    P_DEP_ORG_ID number;
    P_SEC_ORG_ID number;
    P_CNT_ORG_ID number;
    P_PERSON_ID number; 
    P_FROM_DATE  DATE;
    P_TO_DATE    DATE;
  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
   FUNCTION GET_CHARGE_OUT_RATE_MONTHLY( P_CONTRACT_ID     IN     NUMBER,
                                  P_ASSIGNMENT_ID   IN     NUMBER,
                                  P_DATE            IN     DATE,
--                                  O_MSR                OUT NUMBER,
--                                  O_HSR                OUT NUMBER,
--                                  O_OT1                OUT NUMBER,
--                                  O_OT2                OUT NUMBER,
                                  P_ROSTER_ID       IN     NUMBER ) 
                                RETURN NUMBER; 
   FUNCTION GET_CURRENT_DATE_TIME RETURN VARCHAR2; 
   FUNCTION GET_BU_ORG_PARAM RETURN VARCHAR2;
   FUNCTION GET_SBU_ORG_PARAM RETURN VARCHAR2;
   FUNCTION GET_DEP_ORG_PARAM RETURN VARCHAR2;
   FUNCTION GET_SEC_ORG_PARAM RETURN VARCHAR2;
   FUNCTION GET_CNT_ORG_PARAM RETURN VARCHAR2;
   FUNCTION GET_PERSON_PARAM RETURN VARCHAR2;
   FUNCTION GET_PAYROLL_PARAM RETURN VARCHAR2;
   FUNCTION GET_CONTRACT_BATCH_PARAM RETURN VARCHAR2;
END XXTG_CONTRACT_AUDIT;
/


CREATE OR REPLACE PACKAGE BODY XXTG_CONTRACT_AUDIT AS

  FUNCTION GET_CHARGE_OUT_RATE_MONTHLY( P_CONTRACT_ID     IN     NUMBER,
                                  P_ASSIGNMENT_ID   IN     NUMBER,
                                  P_DATE            IN     DATE,
--                                  O_MSR                OUT NUMBER,
--                                  O_HSR                OUT NUMBER,
--                                  O_OT1                OUT NUMBER,
--                                  O_OT2                OUT NUMBER,
                                  P_ROSTER_ID       IN     NUMBER ) 
                                RETURN NUMBER AS
  LN_COR_BASIC_PM NUMBER;
  LN_COR_HOURLY_RATE NUMBER;
  LN_OT1  NUMBER;
  LN_OT2  NUMBER;
  BEGIN
   TG_MOS_INV_PKG.GET_CHARGE_OUT_RATE(P_CONTRACT_ID
                                      ,P_ASSIGNMENT_ID
                                      , P_DATE
                                      , LN_COR_BASIC_PM
                                      , LN_COR_HOURLY_RATE
                                      , LN_OT1   
                                      , LN_OT2
                                      , P_ROSTER_ID);
    RETURN LN_COR_BASIC_PM;
  END GET_CHARGE_OUT_RATE_MONTHLY;
   FUNCTION GET_CURRENT_DATE_TIME RETURN VARCHAR2
   IS
   CURSOR GET_TIME_DATE IS 
   SELECT TO_CHAR(SYSDATE,'DD-MON-RRRR, HH24:MI:SS') DATE_TIME FROM DUAL;
   LC_DATE_TIME VARCHAR2(240);
  BEGIN
     FOR XXTG_REC IN GET_TIME_DATE
       LOOP
         LC_DATE_TIME := XXTG_REC.DATE_TIME;
       END LOOP;
    RETURN LC_DATE_TIME;
  END GET_CURRENT_DATE_TIME;
   FUNCTION GET_BU_ORG_PARAM RETURN VARCHAR2
   IS
   CURSOR GET_ORG IS 
   SELECT hr_general.decode_organization(P_BU_ORG_ID) ORG FROM DUAL;
   LC_ORG VARCHAR2(240);
  BEGIN
     FOR XXTG_REC IN GET_ORG
       LOOP
         LC_ORG := XXTG_REC.ORG;
       END LOOP;
    RETURN LC_ORG;
  END GET_BU_ORG_PARAM;
   FUNCTION GET_SBU_ORG_PARAM RETURN VARCHAR2
   IS
   CURSOR GET_ORG IS 
   SELECT hr_general.decode_organization(P_SBU_ORG_ID) ORG FROM DUAL;
   LC_ORG VARCHAR2(240);
  BEGIN
     FOR XXTG_REC IN GET_ORG
       LOOP
         LC_ORG := XXTG_REC.ORG;
       END LOOP;
    RETURN LC_ORG;
  END GET_SBU_ORG_PARAM;
   FUNCTION GET_DEP_ORG_PARAM RETURN VARCHAR2
   IS
   CURSOR GET_ORG IS 
   SELECT hr_general.decode_organization(P_DEP_ORG_ID) ORG FROM DUAL;
   LC_ORG VARCHAR2(240);
  BEGIN
     FOR XXTG_REC IN GET_ORG
       LOOP
         LC_ORG := XXTG_REC.ORG;
       END LOOP;
    RETURN LC_ORG;
  END GET_DEP_ORG_PARAM;
   FUNCTION GET_SEC_ORG_PARAM RETURN VARCHAR2
   IS
   CURSOR GET_ORG IS 
   SELECT hr_general.decode_organization(P_SEC_ORG_ID) ORG FROM DUAL;
   LC_ORG VARCHAR2(240);
  BEGIN
     FOR XXTG_REC IN GET_ORG
       LOOP
         LC_ORG := XXTG_REC.ORG;
       END LOOP;
    RETURN LC_ORG;
  END GET_SEC_ORG_PARAM;
   FUNCTION GET_CNT_ORG_PARAM RETURN VARCHAR2
   IS
   CURSOR GET_ORG IS 
   SELECT hr_general.decode_organization(P_CNT_ORG_ID) ORG FROM DUAL;
   LC_ORG VARCHAR2(240);
  BEGIN
     FOR XXTG_REC IN GET_ORG
       LOOP
         LC_ORG := XXTG_REC.ORG;
       END LOOP;
    RETURN LC_ORG;
  END GET_CNT_ORG_PARAM;
   FUNCTION GET_PERSON_PARAM RETURN VARCHAR2
   IS
   CURSOR GET_PERSON (ln_person_id number) IS 
   SELECT full_name from per_all_people_f where full_name is not null and sysdate between 
   effective_start_date and effective_end_date and person_id = ln_person_id ;
   LC_ORG VARCHAR2(240);
  BEGIN
     FOR XXTG_REC IN GET_PERSON(P_PERSON_ID)
       LOOP
         LC_ORG := XXTG_REC.full_name;
       END LOOP;
    RETURN LC_ORG;
  END GET_PERSON_PARAM;
   FUNCTION GET_PAYROLL_PARAM RETURN VARCHAR2
   IS
   CURSOR GET_PAYROLL (P_PAYROLL_ID NUMBER) IS 
   SELECT PAYROLL_NAME FROM PAY_PAYROLLS_F WHERE PAYROLL_ID =P_PAYROLL_ID;
   LC_PAYROLL VARCHAR2(240);
  BEGIN
     FOR XXTG_REC IN GET_PAYROLL(P_PAYROLL_ID)
       LOOP
         LC_PAYROLL := XXTG_REC.PAYROLL_NAME;
       END LOOP;
    RETURN LC_PAYROLL;
  END GET_PAYROLL_PARAM;
   FUNCTION GET_CONTRACT_BATCH_PARAM RETURN VARCHAR2
   IS
  BEGIN
    RETURN P_CONTRACT_BATCH;
  END GET_CONTRACT_BATCH_PARAM;
END XXTG_CONTRACT_AUDIT;
/
