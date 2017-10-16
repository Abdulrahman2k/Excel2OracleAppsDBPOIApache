CREATE OR REPLACE PACKAGE        "XXTG_CA_DEPLOYMENT_PKG" AUTHID DEFINER
--  $Header: XXTG_CA_PKG.pls 12.1 2016/10/16  10:30:06 mrahman noship $
--
--
-- PROGRAM NAME
--
--
-- DESCRIPTION
--  This Package is the default Package containing the Procedures
-- |              used by XXTG_HR_PKG Extract
-- USAGE
--   To install       How to Install
--   To execute       How to Execute
--
-- PROGRAM LIST         DESCRIPTION
-- DEPENDENCIES
--   1. Common Error Check Package.
--
-- CALLED BY
--   Which script, if any, calls this one
--
-- LAST UPDATE DATE   16-OCT-2016
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION  DATE        AUTHOR(S)               DESCRIPTION
-- ------- ----------- --------------- ------------------------------------
-- DRAFT 1A 16-OCT-2016  Mohammed Abdul Rahman    Initial draft version
--************************************************************************
AS
  P_CONC_REQUEST_ID                     NUMBER DEFAULT to_number(FND_GLOBAL.CONC_REQUEST_ID);
  P_PERSON_ID                           NUMBER;
  P_BUSINESS_GROUP_ID                   NUMBER;
  P_BU_ORG_ID                           NUMBER;
  P_SBU_ORG_ID                          NUMBER;
  P_DEP_ORG_ID                          NUMBER;
  P_SEC_ORG_ID                          NUMBER;
  P_CNT_ORG_ID                          NUMBER;
  P_START_DATE                          DATE;
  P_END_DATE                            DATE;
  P_DATE                                DATE;
  P_PAYROLL_ID                          NUMBER;
  P_DIFFERED                            VARCHAR2(1);
  P_TIME_PERIOD_ID                      NUMBER;
  P_PERIOD_END_DATE                     DATE;
  P_ELEMENT_NAME                        VARCHAR2(2000);
  P_ACCOUNT_CODE                        VARCHAR2(2000);
  P_EMP_OR_EX                           VARCHAR2(10);
  P_EMPLOYER                            VARCHAR2(2000);
  P_EMP_OR_EX_SQL                       VARCHAR2(2000)  := 'AND 1=1';
  P_PAY_DATE                            VARCHAR2(2000);
  P_PERIOD                              VARCHAR2(10);
  P_LOCATION_ID                         NUMBER;
  P_LEDGER_ID                           NUMBER;
  P_CONTRACT_BATCH                      VARCHAR2(240);
  P_RISK                                VARCHAR2(240);
  FUNCTION CONTRACT_AT_RISK (P_PERSON_ID NUMBER
                             ,P_BASIC NUMBER
                             , P_HRA NUMBER
                             , P_TRA NUMBER
                             , P_ORGANIZATION    VARCHAR2
                             , P_JOB             VARCHAR2
                             , P_ROSTER          VARCHAR2
                             , P_EFFECTIVE_DATE DATE) RETURN VARCHAR2;
  FUNCTION BEFOREREPORT                 RETURN BOOLEAN;
  FUNCTION AFTERREPORT                  RETURN BOOLEAN;
    PROCEDURE PUSH_ALLOWANCE_BATCH(
    P_CONTRACT_BATCH  VARCHAR2
    );
  PROCEDURE PUSH_ALLOWANCE_DETAILS(
--    P_BASIC           NUMBER,
    P_ALLOWANCE            VARCHAR2,
    P_ALLOWANCE_AMOUNT     NUMBER,
--    P_EMIRATE         VARCHAR2,
--    P_CAMP            VARCHAR2,
--    P_ROOM            VARCHAR2,
    P_CONTRACT_BATCH  VARCHAR2,
    P_EFFECTIVE_START_DATE  DATE,
    P_TG_ID            VARCHAR2,
    O_SAL_MSG OUT VARCHAR2) ;
   PROCEDURE PUSH_SAL_DETAILS(
    P_BASIC           NUMBER,
    P_HRA             NUMBER,
    P_TRA             NUMBER,
    P_EMIRATE         VARCHAR2,
    P_CAMP            VARCHAR2,
    P_ROOM            VARCHAR2,
    P_CONTRACT_BATCH  VARCHAR2,
    P_EFFECTIVE_START_DATE  DATE,
    P_TG_ID            VARCHAR2,
    O_SAL_MSG OUT VARCHAR2);
  PROCEDURE PUSH_ASG_DETAILS(
       P_ORGANIZATION    VARCHAR2,
    P_JOB            VARCHAR2,
    P_ROSTER         VARCHAR2,
    P_BASIC           NUMBER,
    P_HRA             NUMBER,
    P_TRA             NUMBER,
    P_EMIRATE         VARCHAR2,
    P_CAMP            VARCHAR2,
    P_ROOM            VARCHAR2,
    P_CONTRACT_BATCH  VARCHAR2,
    P_EFFECTIVE_START_DATE  DATE,
    P_TG_ID            VARCHAR2,
    O_ASG_MSG       OUT VARCHAR2 );
-- PROCEDURE INSERT_BATCH_LINES
--  (
--   ERRBUF        OUT VARCHAR2,
--   RETCODE       OUT VARCHAR2,
--  P_CONTRACT_ID     NUMBER,
----    P_OBJECT_VERSION_NUMBER      IN   OUT NUMBER,
--    P_CONTRACT_ACCEPTED VARCHAR2  DEFAULT NULL,
--    P_RESIGNED_DUE_TO_CONTRACT VARCHAR2 DEFAULT NULL,
--    P_CONTRACT_SIGNED_DATE     DATE  DEFAULT SYSDATE,
----    P_UPDATED_BY             NUMBER,
----    P_UPDATE_DATE            DATE,
--    P_CONTRACT_STATUS       VARCHAR2 DEFAULT 'A-ACTIVE', --:='A-ACTIVE';
--    P_CONTRACT_REASON       VARCHAR2 DEFAULT 'PROCESSED', --:='PROPOSED';
--    P_CONTRACT_DOC_STATUS   VARCHAR2 DEFAULT 'PROCESSED',  --:='CREATED';
--    P_ASSIGNMENTS_CREATION_DATE DATE   DEFAULT SYSDATE
--   );
 PROCEDURE INSERT_BATCH_LINES
  (
   ERRBUF        OUT VARCHAR2,
   RETCODE       OUT VARCHAR2,
  P_CONTRACT_ID     NUMBER,
--    P_OBJECT_VERSION_NUMBER      IN   OUT NUMBER,
    P_CONTRACT_ACCEPTED VARCHAR2         DEFAULT NULL,
    P_RESIGNED_DUE_TO_CONTRACT VARCHAR2  DEFAULT NULL,
    P_CONTRACT_SIGNED_DATE     DATE  DEFAULT SYSDATE,
--    P_UPDATED_BY             NUMBER,
--    P_UPDATE_DATE            DATE,
    P_CONTRACT_STATUS       VARCHAR2 DEFAULT 'A-ACTIVE', --:='A-ACTIVE';
    P_CONTRACT_REASON       VARCHAR2 DEFAULT 'PROCESSED', --:='PROPOSED';
    P_CONTRACT_DOC_STATUS   VARCHAR2 DEFAULT 'PROCESSED',  --:='CREATED';
    P_ASSIGNMENTS_CREATION_DATE DATE   DEFAULT SYSDATE
--    ,
--    P_RISK_FLAG                    VARCHAR2
   );
  FUNCTION CHANGE_PRINT_STATUS          RETURN VARCHAR2;
  FUNCTION AUTO_UPDATE_CONT_FOR_RISK_N  RETURN VARCHAR2;
  PROCEDURE XXTG_CONTRACT
  ( P_ORGANIZATION    VARCHAR2,
    P_JOB             VARCHAR2,
    P_ROSTER          VARCHAR2,
    P_BASIC           NUMBER,
    P_HRA             NUMBER,
    P_TRA             NUMBER,
--    P_OTHER             NUMBER,
    P_RISK         VARCHAR2,
    P_CAMP            VARCHAR2,
    P_ROOM            VARCHAR2,
    P_CONTRACT_BATCH  VARCHAR2,
    P_EFFECTIVE_START_DATE  DATE,
    P_OPERATIONS_MGR_PERSON  VARCHAR2,
--    P_PERSON_ID             NUMBER,
    P_TG_ID                VARCHAR2,
    P_EMP_CONTRACT_ID        OUT   NUMBER);
--  PROCEDURE UPDATE_CONTRACT
--  ( P_CONTRACT_ID     VARCHAR,
----    P_OBJECT_VERSION_NUMBER      IN   OUT NUMBER,
--    P_CONTRACT_ACCEPTED VARCHAR2,
--    P_RESIGNED_DUE_TO_CONTRACT VARCHAR2,
--    P_CONTRACT_SIGNED_DATE     DATE  DEFAULT SYSDATE,
----    P_UPDATED_BY             NUMBER,
----    P_UPDATE_DATE            DATE,
--    P_CONTRACT_STATUS       VARCHAR2 DEFAULT 'A-ACTIVE', --:='A-ACTIVE';
--    P_CONTRACT_REASON       VARCHAR2 DEFAULT 'PROCESSED', --:='PROPOSED';
--    P_CONTRACT_DOC_STATUS   VARCHAR2 DEFAULT 'PROCESSED',  --:='CREATED';
--    P_ASSIGNMENTS_CREATION_DATE DATE   DEFAULT SYSDATE
--   );
  PROCEDURE UPDATE_CONTRACT
  ( P_CONTRACT_ID     VARCHAR,
--    P_OBJECT_VERSION_NUMBER      IN    OUT NUMBER,
    P_CONTRACT_ACCEPTED VARCHAR2,
    P_RESIGNED_DUE_TO_CONTRACT VARCHAR2,
    P_CONTRACT_SIGNED_DATE     DATE  DEFAULT SYSDATE,
--    P_UPDATED_BY             NUMBER,
--    P_UPDATE_DATE            DATE,
    P_CONTRACT_STATUS       VARCHAR2 DEFAULT 'A-ACTIVE', --:='A-ACTIVE';
    P_CONTRACT_REASON       VARCHAR2 DEFAULT 'PROCESSED', --:='PROPOSED';
    P_CONTRACT_DOC_STATUS   VARCHAR2 DEFAULT 'PROCESSED',  --:='CREATED';
    P_ASSIGNMENTS_CREATION_DATE DATE   DEFAULT SYSDATE
--    P_RISK_FLAG VARCHAR2
   );
   FUNCTION SUBMIT_REQUEST_BURST
--  ( P_CONC_REQUEST_ID in number
--  ) 
  return VARCHAR2;
   PROCEDURE SUBMIT_PRINT_REQUEST (P_CONTRACT_BATCH varchar2, P_REQUEST_ID OUT varchar2) ;
   PROCEDURE SUBMIT_LOG_REQUEST (P_CONTRACT_BATCH varchar2, P_REQUEST_ID OUT varchar2) ;
   FUNCTION GET_CONTRACT_CS_ALLOWANCE (P_CONTRACT_ID NUMBER) RETURN NUMBER ;
   PROCEDURE VALIDATE_CONTRACT_BATCH(
   ERRBUF        OUT VARCHAR2,
   RETCODE       OUT VARCHAR2,
   P_CONTRACT_BATCH varchar2);
   PROCEDURE UPDATE_FOREIGN_KEY (P_CONTRACT_BATCH varchar2);
   PROCEDURE DELETE_ORPHAN_RECORDS(
   ERRBUF        OUT VARCHAR2,
   RETCODE       OUT VARCHAR2);
   -- ------- ----------- --------------- ------------------------------------
-- Procedure for Primary Address Update used for udpating camp and room from OAF Page
--************************************************************************
  PROCEDURE PRIMARY_ADDRESS_UPDATE(
    P_EMPLOYEE_NUMBER  VARCHAR2 ,    
    P_CAMP_NAME        VARCHAR2 ,            
    P_EFFECTIVE_DATE   DATE,     
    P_CAMP_ROOM_NO          VARCHAR2 , 
    P_ADDRESS_ID OUT NUMBER );
 PROCEDURE UPDATE_ADDR_FROM_CONTRACT
  ( P_CONTRACT_ID     VARCHAR,
    P_CAMP_NAME         VARCHAR2,
    P_CAMP_ROOM_NAME    VARCHAR2,
    P_ADDR_DEPLOYMENT_DATE  DATE  DEFAULT SYSDATE
   );
  FUNCTION GET_CHARGE_OUT_RATE_MONTHLY( P_CONTRACT_ID     IN     NUMBER,
                                  P_ASSIGNMENT_ID   IN     NUMBER,
                                  P_DATE            IN     DATE,
--                                  O_MSR                OUT NUMBER,
--                                  O_HSR                OUT NUMBER,
--                                  O_OT1                OUT NUMBER,
--                                  O_OT2                OUT NUMBER,
                                  P_ROSTER_ID       IN     NUMBER ) 
                                RETURN NUMBER;
PROCEDURE GET_TG_ID_IN_APPROVAL (p_header_id IN NUMBER  , p_tg_id_in_approval OUT VARCHAR2);
  FUNCTION Get_Batch_Risk
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;
  FUNCTION GET_BATCH_BAS_SAL_CHG_STATUS(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;  
  END XXTG_CA_DEPLOYMENT_PKG;
/


CREATE OR REPLACE PACKAGE BODY        "XXTG_CA_DEPLOYMENT_PKG" 
--
--  $Header: XXTG_CA_PKG.pls 12.1 2016/10/16  10:30:06 mrahman noship $
--
-- PROGRAM NAME
--
--
-- DESCRIPTION
--  This Package is the default Package containing the Procedures
-- |              used by XXTG_HR_PKG Extract
-- USAGE
--   To install       How to Install
--   To execute       How to Execute
--
-- PROGRAM LIST         DESCRIPTION
-- DEPENDENCIES
--   1. Common Error Check Package.
--
-- CALLED BY
--   Which script, if any, calls this one
--
-- LAST UPDATE DATE   16-OCT-2016
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION  DATE        AUTHOR(S)               DESCRIPTION
-- ------- ----------- --------------- ------------------------------------
-- DRAFT 1A 16-OCT-2016  Mohammed Abdul Rahman    Initial draft version
-- 51617 1A 06-Mar-2017  Mohammed Abdul Rahman    Added Code for Bug 51617 to enable create Null Roster
--************************************************************************
AS
    LN_OBJECT_VERSION_NUMBER NUMBER;
    LN_CONTRACT_ID NUMBER;
    LD_EFFECTIVE_START_DATE DATE;
    LD_EFFECTIVE_END_DATE DATE;

    LC_CONTRACT_TYPE    VARCHAR2(240);
    LC_CONTRACT_STATUS  VARCHAR2(240);
    LC_CONTRACT_DOC_STATUS VARCHAR2(240);
    LC_CONTRACT_REASON     VARCHAR2(240);
    LC_CONTRACT_AT_RISK    VARCHAR2(240);
    LC_STATUS              VARCHAR2(20);
    LN_PERSON_ID           NUMBER;
    g_package  varchar2(33) := 'hr_workflow_ss.';
  CURSOR XXTG_PREV_COMP_CHECK ( LN_PERSON_ID NUMBER, LD_EFFECTIVE_DATE DATE, LC_ELEMENT_NAME VARCHAR2, LC_INPUT_NAME VARCHAR2)
  IS 
  select PPP.PROPOSED_SALARY_N VALUE from PER_PAY_PROPOSALS PPP
where PPP.assignment_id = (select assignment_id from per_all_assignments_f where person_id = LN_PERSON_ID
and trunc(LD_EFFECTIVE_DATE) between effective_start_date and effective_end_date)
AND trunc(LD_EFFECTIVE_DATE) BETWEEN  PPP.change_date AND PPP.DATE_TO;
--  
--  
--  
--    SELECT NVL(TO_NUMBER(peevf.screen_entry_value),0) VALUE
--    FROM  PAY_ELEMENT_ENTRY_VALUES_F PEEVF,
--    PAY_INPUT_VALUES_F PIVF,
--    PAY_ELEMENT_ENTRIES_F PEEF ,
--    PER_ALL_ASSIGNMENTS_F PAAF,
--    PAY_ELEMENT_TYPES_F PETF
--    WHERE 
--    PEEVF.INPUT_VALUE_ID = PIVF.INPUT_VALUE_ID
--    AND PEEVF.ELEMENT_ENTRY_ID = PEEF.ELEMENT_ENTRY_ID
--    AND PAAF.ASSIGNMENT_ID = PEEF.ASSIGNMENT_ID
--    AND PEEF.ELEMENT_TYPE_ID = PETF.ELEMENT_TYPE_ID
--    AND TRUNC(LD_EFFECTIVE_DATE) BETWEEN PEEF.EFFECTIVE_START_DATE AND PEEF.EFFECTIVE_END_DATE
--    AND TRUNC(LD_EFFECTIVE_DATE) BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
--    AND PAAF.PERSON_ID = LN_PERSON_ID
--    AND PETF.ELEMENT_NAME = LC_ELEMENT_NAME --'Transportation Allowance' --='House Rent Allowance'-- ='Basic Salary'
--    AND pivf.name = LC_INPUT_NAME ;--'Override Amount' --='Override Amount'--='Basic Salary'
  CURSOR XXTG_RESP_ID_APPROVER_CUR (LN_USER_ID NUMBER)
  IS
   SELECT  frsp.application_id , frsp.responsibility_id,
 fpo.profile_option_name SHORT_NAME,
         fpot.user_profile_option_name NAME,
         DECODE (fpov.level_id,
                 10001, 'Site',
                 10002, 'Application',
                 10003, 'Responsibility',
                 10004, 'User',
                 10005, 'Server',
                 'UnDef')
            LEVEL_SET,
         DECODE (TO_CHAR (fpov.level_id),
                 '10001', '',
--                 '10002', fap.application_short_name,
                 '10003', frsp.responsibility_key,
--                 '10005', fnod.node_name,
--                 '10006', hou.name,
                 '10004', fu.user_name,
                 'UnDef')
            "CONTEXT",
         fpov.profile_option_value VALUE
    FROM fnd_profile_options fpo,
         fnd_profile_option_values fpov,
         fnd_profile_options_tl fpot,
         fnd_user_resp_groups_direct        furg,
         fnd_user fu,
--         fnd_application fap,
         fnd_responsibility frsp
--         fnd_nodes fnod,
--         hr_operating_units hou
   WHERE     fpo.profile_option_id = fpov.profile_option_id(+)
         AND fpo.profile_option_name = fpot.profile_option_name
--         AND fu.user_id(+) = fpov.level_value
         AND frsp.application_id = fpov.level_value_application_id
         AND frsp.responsibility_id = fpov.level_value
--         AND fap.application_id(+) = fpov.level_value
--         AND fnod.node_id(+) = fpov.level_value
--         AND hou.organization_id(+) = fpov.level_value
         AND furg.user_id             =  fu.user_id
         AND furg.responsibility_id   =  frsp.responsibility_id
         and fpot.profile_option_name='XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE'
         AND fpot.language             =  USERENV('LANG')
         AND fpov.level_id = '10003'
         and sysdate between furg.start_date and nvl(furg.end_date,to_date('31-DEC-4712','DD-MON-RRRR'))
         and sysdate between fu.start_date and nvl(fu.end_date,to_date('31-DEC-4712','DD-MON-RRRR'))
         AND  fu.user_id  = LN_USER_ID
         AND ROWNUM =1    ;
    CURSOR XXTG_ASSIGNMENT_CUR (LN_PERSON_ID NUMBER, LD_EFFECTIVE_START_DATE DATE) IS 
    SELECT PAAF.BUSINESS_GROUP_ID , PAAF.ASSIGNMENT_ID
     , (SELECT NAME FROM PER_JOBS WHERE JOB_ID = PAAF.JOB_ID )JOB_NAME FROM PER_ALL_ASSIGNMENTS_F PAAF
     WHERE PAAF.PERSON_ID = LN_PERSON_ID
     AND LD_EFFECTIVE_START_DATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE;
    CURSOR XXTG_COR_ALLOWANCE (LD_EFFECTIVE_DATE DATE, LN_BUSINESS_GROUP_ID NUMBER, LC_JOB_NAME VARCHAR2, LC_ORG_NAME VARCHAR2,LN_BASIC_SALARY NUMBER, LC_ROSTER_NAME VARCHAR2)
    IS 
    SELECT  NVL(M.ALLOWANCE_AMOUNT,0)  ALLOWANCE_AMOUNT --, M.BASIC_SALARY 
       FROM TG_MOS_CS_ALLOWANCE_MASTER_V M
     WHERE      
 
           M.JOB_NAME =LC_JOB_NAME 
           AND  M.ORG_NAME =LC_ORG_NAME 
          AND  M.BASIC_SALARY = LN_BASIC_SALARY
           AND NVL( M.ROSTER_NAME, '' ) = NVL(LC_ROSTER_NAME , ''  )
           AND  fnd_conc_date.string_to_date(LD_EFFECTIVE_DATE) BETWEEN M.EFFECTIVE_START_DATE AND NVL( M.EFFECTIVE_END_DATE, fnd_conc_date.string_to_date('31-DEC-4712' ))
            AND      M.BGID = LN_BUSINESS_GROUP_ID;
    CURSOR XXTG_CONT_CUR (LC_CONTRACT_BATCH VARCHAR2, LN_BU_ORG_ID NUMBER, LN_SBU_ORG_ID NUMBER, LN_DEP_ORG_ID NUMBER, LN_SEC_ORG_ID NUMBER, LN_CNT_ORG_ID NUMBER,  LN_PERSON_ID NUMBER, LC_RISK VARCHAR2) --, LD_EFFECTIVE_DATE DATE)
    IS 
            SELECT PPF.EMPLOYEE_NUMBER
--            , PPF.FULL_NAME 
--            , PPF.PERSON_ID
--            , TO_CHAR(SYSDATE, 'DD/MM/RRRR') REPORT_DATE
--            , TO_CHAR(PCF.EFFECTIVE_START_DATE,'DD-MON-RRRR') DATE_START
--            , PCF.ATTRIBUTE1 ORGANIZATION
--            , PCF.ATTRIBUTE2 JOB
--            , PCF.ATTRIBUTE3 ROSTER
--            , TO_NUMBER(PCF.ATTRIBUTE4) BASIC_SALARY
--            , TO_NUMBER(PCF.ATTRIBUTE5) HRA
--            , TO_NUMBER(PCF.ATTRIBUTE6) TRA
--            , NVL(TO_NUMBER(PCF.ATTRIBUTE4),0) +NVL(TO_NUMBER(PCF.ATTRIBUTE5),0)+NVL(TO_NUMBER(PCF.ATTRIBUTE6),0)  TOTAL
--            , PCF.ATTRIBUTE7 EMIRATE
--            , PCF.ATTRIBUTE8 CAMP
--            , PCF.ATTRIBUTE9 ROOM
--            , PCF.REFERENCE BATCH_NAME
            , TO_CHAR(PCF.CONTRACT_ID) CONTRACT_ID
            , PCF.ATTRIBUTE20 CONTRACT_ACCEPTED
            , PCF.ATTRIBUTE19 RISK
            , PCF.ATTRIBUTE18 RESIGNED
            FROM   
            per_assignments_f paf , 
            per_people_f ppf,
             PER_CONTRACTS_F PCF 
             WHERE ppf.person_id               = paf.person_id
             AND PCF.PERSON_ID = PPF.PERSON_ID
            --AND (paf.assignment_status_type_id is null or paf.assignment_status_type_id= 1 )-- 6 stands for Applicant Accepted
            AND PCF.EFFECTIVE_START_DATE BETWEEN paf.EFFECTIVE_START_DATE AND paf.EFFECTIVE_END_DATE
            AND PCF.EFFECTIVE_START_DATE BETWEEN pPf.EFFECTIVE_START_DATE AND pPf.EFFECTIVE_END_DATE
            AND paf.assignment_type           = 'E'
            AND paf.primary_flag              = 'Y'
            AND paf.assignment_status_type_id = 1 
            AND (paF.primary_flag is null or  paF.primary_flag    = 'Y')
            AND PCF.REFERENCE = LC_CONTRACT_BATCH
            AND (LC_RISK IS NULL OR LC_RISK =PCF.ATTRIBUTE19)
            AND 
               ( PPF.PERSON_ID = NVL(LN_PERSON_ID , PPF.PERSON_ID) 
                  OR 
                ( 
                  ( 
                       NVL(LN_BU_ORG_ID,0) =0 
                   AND NVL(LN_SBU_ORG_ID,0) =0
                   AND NVL(LN_DEP_ORG_ID,0) =0
                   AND NVL(LN_SEC_ORG_ID,0) =0
                   AND NVL(LN_CNT_ORG_ID,0) =0
                   )
                    OR 
                    paf.organization_id      IN
                      (SELECT POSE.organization_id_CHILD
                      FROM PER_ORG_STRUCTURE_ELEMENTS POSE
                        START WITH pose.organization_id_child IN (
                        CASE
                          WHEN NVL(LN_CNT_ORG_ID,0) =0
                          THEN ( 
                                CASE 
                                  WHEN NVL(LN_SEC_ORG_ID,0) = 0 
                                  THEN (
                                        CASE 
                                          WHEN NVL(LN_DEP_ORG_ID,0) = 0 
                                          THEN (
                                                CASE 
                                                  WHEN NVL(LN_SBU_ORG_ID,0) = 0 
                                                  THEN  TO_NUMBER(LN_BU_ORG_ID)                                      
                                                    ELSE TO_NUMBER(LN_SBU_ORG_ID)
                                                END )                      
                                             ELSE TO_NUMBER(LN_DEP_ORG_ID)
                                          END ) 
                                   ELSE TO_NUMBER(LN_SEC_ORG_ID)
                                END )
                          ELSE  TO_NUMBER(LN_CNT_ORG_ID)
                        END )
                        CONNECT BY PRIOR POSE.organization_id_child = POSE.organization_id_parent
                      ) 
                    )
                  );
  FUNCTION BEFOREREPORT                 RETURN BOOLEAN
  IS
  BEGIN
  NULL;
  END;
  FUNCTION AFTERREPORT                  RETURN BOOLEAN
  IS
  BEGIN
  NULL;
  END;
    PROCEDURE PUSH_ALLOWANCE_BATCH(
    P_CONTRACT_BATCH  VARCHAR2
    )
    IS
    CURSOR XXTG_ELE_CUR (LC_CONTRACT_BATCH VARCHAR2)
    IS 
    SELECT HEADER_ID, LINE_ID, ELEMENT_LINE_ID, ELEMENT_NAME,VALIDATION_MESSAGE,  PAY_VALUE FROM XXTG_CA_LINES_ELE_ALL
    WHERE HEADER_ID = TO_NUMBER(LC_CONTRACT_BATCH)
    AND PAY_VALUE IS NOT NULL
    AND ELEMENT_NAME IS NOT NULL
    AND VALIDATION_MESSAGE IS NULL
    FOR UPDATE OF VALIDATION_MESSAGE;
    CURSOR XXTG_LINE_CUR (LN_LINE_ID NUMBER)
    IS SELECT TG_ID , EFFECTIVE_DATE FROM XXTG_CA_LINES_ALL 
    WHERE LINE_ID = LN_LINE_ID;
      LC_TG_ID VARCHAR2(40) := NULL;
      LD_EFF_DATE DATE := NULL;
      LC_SAL_MSG  VARCHAR2(240);
    BEGIN
    FOR XXTG_REC IN XXTG_ELE_CUR(P_CONTRACT_BATCH)
      LOOP
      LC_TG_ID := NULL;
      LD_EFF_DATE := NULL;
    FOR  XXTG_LINE_REC IN XXTG_LINE_CUR (XXTG_REC.LINE_ID)
      LOOP
          LC_TG_ID := XXTG_LINE_REC.TG_ID;
          LD_EFF_DATE := XXTG_LINE_REC.EFFECTIVE_DATE;
      END LOOP;
      LC_SAL_MSG := NULL;
        XXTG_CA_DEPLOYMENT_PKG.PUSH_ALLOWANCE_DETAILS(
    P_ALLOWANCE   =>XXTG_REC.ELEMENT_NAME ,
    P_ALLOWANCE_AMOUNT =>XXTG_REC.PAY_VALUE ,    
    P_CONTRACT_BATCH  => TO_CHAR(XXTG_REC.HEADER_ID),
    P_EFFECTIVE_START_DATE  => LD_EFF_DATE,
    P_TG_ID=> LC_TG_ID,
    O_SAL_MSG =>LC_SAL_MSG);
    UPDATE XXTG_CA_LINES_ELE_ALL
    SET VALIDATION_MESSAGE = NVL(LC_SAL_MSG,'I')
    WHERE CURRENT OF XXTG_ELE_CUR;
      END LOOP;
    COMMIT;
   END PUSH_ALLOWANCE_BATCH;
  PROCEDURE PUSH_ALLOWANCE_DETAILS(
    P_ALLOWANCE            VARCHAR2,
    P_ALLOWANCE_AMOUNT     NUMBER,
    P_CONTRACT_BATCH  VARCHAR2,
    P_EFFECTIVE_START_DATE  DATE,
    P_TG_ID            VARCHAR2,
    O_SAL_MSG OUT VARCHAR2) AS
  
    V_ERR_FLAG                  VARCHAR2(1);
    V_ERR_MESG                  VARCHAR2(4000);
    V_PROPOSAL_REASON           VARCHAR2(400);
    V_OBJ_VER                   NUMBER DEFAULT NULL;
    V_INV_NEXT_SAL_DATE_WARNING BOOLEAN;
    V_PROPOSED_SALARY_WARNING   BOOLEAN;
    V_APPROVED_WARNING          BOOLEAN; 
    V_PAYROLL_WARNING           BOOLEAN;
    V_PAY_PROPOSAL_ID           NUMBER;
    V_PERSON_ID                 NUMBER;
    V_ASSIGN_ID                 NUMBER;
    V_EFFECTIVE_DATE            DATE;
  
    --
    V_HIRE_DATE            DATE;
    V_BG_ID                NUMBER;
    V_ELEMENT_ENTRY_ID     NUMBER;
    V_MODE                 VARCHAR2(100);
    V_EFFECTIVE_START_DATE DATE;
    V_EFFECTIVE_END_DATE   DATE;
    V_UPDATE_WARNING       BOOLEAN;
    V_CREATE_WARNING       BOOLEAN;
    V_INPUT_VALUE_ID       NUMBER;
    V_ELEMENT_LINK_ID      NUMBER;
  
    L_SAL_CHANGE_DATE DATE;
    L_FUTURE_DATE     DATE;
    L_FUTURE_AMOUNT   NUMBER;
    V_ELEMENT_TYPE_ID NUMBER;
  
   CURSOR XXTG_ASS_CUR (LC_TG_ID VARCHAR2, LD_EFFECTIVE_DATE DATE)
   IS
        SELECT  PPF.PERSON_ID,
                ORIGINAL_DATE_OF_HIRE,
                PAF.ASSIGNMENT_ID,
                PPF.BUSINESS_GROUP_ID
          FROM PER_ALL_ASSIGNMENTS_F PAF,
               PER_ALL_PEOPLE_F      PPF
         WHERE PPF.PERSON_ID = PAF.PERSON_ID
            AND FND_CONC_DATE.STRING_TO_DATE(LD_EFFECTIVE_DATE) BETWEEN PPF.EFFECTIVE_START_DATE AND
               PPF.EFFECTIVE_END_DATE
           AND FND_CONC_DATE.STRING_TO_DATE(LD_EFFECTIVE_DATE) BETWEEN PAF.EFFECTIVE_START_DATE AND
               PAF.EFFECTIVE_END_DATE
           AND PPF.CURRENT_EMPLOYEE_FLAG = 'Y'
           AND paf.assignment_type      = 'E'
           AND paf.primary_flag         = 'Y'
           AND paf.assignment_status_type_id = 1 
           AND PPF.EMPLOYEE_NUMBER = LC_TG_ID;
  CURSOR XXTG_ELE_TYPE_CUR (LD_EFFECTIVE_DATE DATE, LP_ELEMENT_NAME VARCHAR2)
  IS 
           SELECT ET.ELEMENT_TYPE_ID
            FROM PAY_ELEMENT_TYPES_F ET
           WHERE ET.ELEMENT_NAME = LP_ELEMENT_NAME  --'House Rent Allowance'
             AND LD_EFFECTIVE_DATE BETWEEN ET.EFFECTIVE_START_DATE AND
                 ET.EFFECTIVE_END_DATE;
  CURSOR  XXTG_ELEMENT_ENTRIES (LN_ASSIGN_ID NUMBER,LN_ELEMENT_TYPE_ID NUMBER, LD_EFFECTIVE_DATE DATE)
  IS 
  SELECT PEE.ELEMENT_ENTRY_ID,
                   PEE.OBJECT_VERSION_NUMBER,
                   (SELECT INPUT_VALUE_ID
                      FROM PAY_INPUT_VALUES_F
                     WHERE ELEMENT_TYPE_ID = LN_ELEMENT_TYPE_ID
                       AND NAME ='Override Amount'
                       AND UOM = 'M'
                       AND LD_EFFECTIVE_DATE BETWEEN
                           EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE) INPUT_VALUE_ID,
                   PEE.EFFECTIVE_START_DATE
              FROM PAY_ELEMENT_ENTRIES_F PEE
             WHERE PEE.ASSIGNMENT_ID = LN_ASSIGN_ID
               AND PEE.ELEMENT_TYPE_ID = LN_ELEMENT_TYPE_ID
               AND LD_EFFECTIVE_DATE BETWEEN PEE.EFFECTIVE_START_DATE AND
                   PEE.EFFECTIVE_END_DATE;
  CURSOR  XXTG_FUTURE_ELEMENT_ENTRIES (LN_ASSIGN_ID NUMBER,LN_ELEMENT_TYPE_ID NUMBER, LD_EFFECTIVE_DATE DATE)
  IS
            SELECT EF.EFFECTIVE_START_DATE,
                   APPSLINK_PAYROLL_PKG.GET_ELEMENT_ENTRY_BY_DATE(EF.ELEMENT_ENTRY_ID,
                                                                  (SELECT INPUT_VALUE_ID
                                                                     FROM PAY_INPUT_VALUES_F
                                                                    WHERE ELEMENT_TYPE_ID =
                                                                          LN_ELEMENT_TYPE_ID
                                                                      AND NAME ='Override Amount'
                                                                      AND UOM = 'M'
                                                                      AND LD_EFFECTIVE_DATE BETWEEN
                                                                          EFFECTIVE_START_DATE AND
                                                                          EFFECTIVE_END_DATE),
                                                                  EF.EFFECTIVE_START_DATE) ENTRY_VALUE
              FROM PAY_ELEMENT_ENTRIES_F EF
             WHERE EF.ASSIGNMENT_ID = LN_ASSIGN_ID
               AND EF.ELEMENT_TYPE_ID = LN_ELEMENT_TYPE_ID
               AND EF.EFFECTIVE_START_DATE =
                   (SELECT MIN(EFF.EFFECTIVE_START_DATE)
                      FROM PAY_ELEMENT_ENTRIES_F EFF
                     WHERE EFF.ASSIGNMENT_ID = LN_ASSIGN_ID
                       AND EFF.ELEMENT_TYPE_ID = LN_ELEMENT_TYPE_ID
                       AND EFF.EFFECTIVE_START_DATE > LD_EFFECTIVE_DATE);
  CURSOR XXTG_ELE_LINK (LN_ASSIGN_ID NUMBER,LN_ELEMENT_TYPE_ID NUMBER, LD_EFFECTIVE_DATE DATE)
  IS 
                SELECT L.ELEMENT_LINK_ID,
                     (SELECT INPUT_VALUE_ID
                        FROM PAY_INPUT_VALUES_F
                       WHERE ELEMENT_TYPE_ID = LN_ELEMENT_TYPE_ID
                         AND NAME ='Override Amount'
                         AND UOM = 'M'
                         AND LD_EFFECTIVE_DATE BETWEEN
                             EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE) INPUT_VALUE_ID
                FROM PAY_ELEMENT_LINKS_F L,
                     PER_ASSIGNMENTS_F   A
               WHERE LD_EFFECTIVE_DATE BETWEEN L.EFFECTIVE_START_DATE AND
                     L.EFFECTIVE_END_DATE
                 AND LD_EFFECTIVE_DATE BETWEEN A.EFFECTIVE_START_DATE AND
                     A.EFFECTIVE_END_DATE
                 AND NVL(L.PAY_BASIS_ID, A.PAY_BASIS_ID) = A.PAY_BASIS_ID
                 AND NVL(L.JOB_ID, A.JOB_ID) = A.JOB_ID
                 AND NVL(L.PAYROLL_ID, A.PAYROLL_ID) = A.PAYROLL_ID
                 AND NVL(L.LOCATION_ID, A.LOCATION_ID) = A.LOCATION_ID
                 AND NVL(L.ORGANIZATION_ID, A.ORGANIZATION_ID) =
                     A.ORGANIZATION_ID
                 AND NVL(NVL(L.PEOPLE_GROUP_ID, A.PEOPLE_GROUP_ID), 0) =
                     NVL(A.PEOPLE_GROUP_ID, 0)
                 AND NVL(NVL(L.GRADE_ID, A.GRADE_ID), 0) =
                     NVL(A.GRADE_ID, 0)
                 AND L.BUSINESS_GROUP_ID = A.BUSINESS_GROUP_ID
                 AND A.ASSIGNMENT_ID = LN_ASSIGN_ID
                 AND L.ELEMENT_TYPE_ID =LN_ELEMENT_TYPE_ID;

  BEGIN
      V_ERR_MESG                  := NULL;
      V_ERR_FLAG                  := NULL;
      V_OBJ_VER                   := NULL;
      V_PAY_PROPOSAL_ID           := NULL;
      V_INV_NEXT_SAL_DATE_WARNING := NULL;
      V_APPROVED_WARNING          := NULL;
      V_PAYROLL_WARNING           := NULL;
      V_ELEMENT_ENTRY_ID          := NULL;
      V_PERSON_ID                 := NULL;
      V_HIRE_DATE                 := NULL;
      V_ASSIGN_ID                 := NULL;
      V_BG_ID                     := NULL;
      V_MODE                      := NULL;
      V_EFFECTIVE_START_DATE      := NULL;
      V_EFFECTIVE_END_DATE        := NULL;
      V_UPDATE_WARNING            := NULL;
      V_INPUT_VALUE_ID            := NULL;
      V_ELEMENT_LINK_ID           := NULL;
      L_SAL_CHANGE_DATE           := NULL;
      L_FUTURE_AMOUNT             := 0;
      V_ELEMENT_TYPE_ID           := NULL;
    
      FOR XXTG_REC IN XXTG_ASS_CUR (P_TG_ID,P_EFFECTIVE_START_DATE)
        LOOP
          V_PERSON_ID:=XXTG_REC.PERSON_ID;
               V_HIRE_DATE:=XXTG_REC.ORIGINAL_DATE_OF_HIRE;
               V_ASSIGN_ID:=XXTG_REC.ASSIGNMENT_ID;
               V_BG_ID:=XXTG_REC.BUSINESS_GROUP_ID;
        END LOOP;
        IF V_PERSON_ID IS NULL THEN
        BEGIN
          O_SAL_MSG := P_TG_ID || ' ' || P_EFFECTIVE_START_DATE ||
                        ' : Employee not found.';
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG);
        END;
        END IF;
        IF NVL(P_ALLOWANCE_AMOUNT,0) > 0 AND O_SAL_MSG IS NULL THEN
--           DBMS_OUTPUT.PUT_LINE('01 : '|| P_ALLOWANCE_AMOUNT);
          FOR XXTG_REC IN XXTG_ELE_TYPE_CUR (P_EFFECTIVE_START_DATE,P_ALLOWANCE)
            LOOP
              V_ELEMENT_TYPE_ID :=XXTG_REC.ELEMENT_TYPE_ID;
            END LOOP;
          FOR XXTG_REC IN XXTG_ELEMENT_ENTRIES (V_ASSIGN_ID,V_ELEMENT_TYPE_ID, P_EFFECTIVE_START_DATE)
           LOOP
             V_ELEMENT_ENTRY_ID:=XXTG_REC.ELEMENT_ENTRY_ID;
             V_OBJ_VER:=XXTG_REC.OBJECT_VERSION_NUMBER;
             V_INPUT_VALUE_ID:=XXTG_REC.INPUT_VALUE_ID;
             V_EFFECTIVE_DATE:=XXTG_REC.EFFECTIVE_START_DATE;
           END LOOP;

          IF V_ELEMENT_ENTRY_ID IS NOT NULL THEN
            V_MODE := 'UPDATE';
          ELSIF V_ELEMENT_ENTRY_ID IS NULL THEN
          V_MODE := 'CREATE';
          END IF;
          
       
          L_FUTURE_DATE   := NULL;
          L_FUTURE_AMOUNT := 0;
        
         FOR XXTG_REC IN XXTG_FUTURE_ELEMENT_ENTRIES(V_ASSIGN_ID,V_ELEMENT_TYPE_ID, P_EFFECTIVE_START_DATE) 
           LOOP
                   L_FUTURE_DATE:=XXTG_REC.EFFECTIVE_START_DATE;
                   L_FUTURE_AMOUNT:=XXTG_REC.ENTRY_VALUE;
           END LOOP;

        
          IF O_SAL_MSG IS NULL AND V_MODE = 'UPDATE' THEN
            BEGIN
              IF V_EFFECTIVE_DATE = P_EFFECTIVE_START_DATE THEN
                V_MODE := 'CORRECTION';
              ELSIF L_FUTURE_DATE IS NOT NULL THEN
                V_MODE := 'UPDATE_CHANGE_INSERT';
              ELSE
                V_MODE := 'UPDATE';
              END IF;
            
              PY_ELEMENT_ENTRY_API.UPDATE_ELEMENT_ENTRY(P_VALIDATE              => FALSE,
                                                        P_DATETRACK_UPDATE_MODE => V_MODE,
                                                        P_EFFECTIVE_DATE        => P_EFFECTIVE_START_DATE,
                                                        P_BUSINESS_GROUP_ID     => V_BG_ID,
                                                        P_ELEMENT_ENTRY_ID      => V_ELEMENT_ENTRY_ID,
                                                        P_OBJECT_VERSION_NUMBER => V_OBJ_VER,
                                                        P_INPUT_VALUE_ID1       => V_INPUT_VALUE_ID,
                                                        P_ENTRY_VALUE1          => P_ALLOWANCE_AMOUNT,
                                                        P_EFFECTIVE_START_DATE  => V_EFFECTIVE_START_DATE,
                                                        P_EFFECTIVE_END_DATE    => V_EFFECTIVE_START_DATE,
                                                        P_UPDATE_WARNING        => V_UPDATE_WARNING);
            

            
              IF L_FUTURE_DATE IS NOT NULL THEN
                O_SAL_MSG := O_SAL_MSG || ' - Future element exist on ' ||P_ALLOWANCE ||' '||
                              TO_CHAR(L_FUTURE_DATE, 'DD-MON-RRRR') ||
                              ' Amount : ' || L_FUTURE_AMOUNT;
              END IF;
            
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG);
            EXCEPTION
              WHEN OTHERS THEN
O_SAL_MSG := P_TG_ID || ' : Error : ' ||' Element Name:'||P_ALLOWANCE ||' Amount :'|| P_ALLOWANCE_AMOUNT ||'  P_CONTRACT_BATCH :'|| P_CONTRACT_BATCH||'  P_TGID :'||P_TG_ID ||'  P_EFFECTIVE_START_DATE :'||P_EFFECTIVE_START_DATE||' '|| SUBSTR(SQLERRM, 1, 500);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG);
            END;
          ELSIF O_SAL_MSG IS NULL AND V_MODE = 'CREATE' THEN
            ----
            BEGIN
              FOR XXTG_REC IN  XXTG_ELE_LINK (V_ASSIGN_ID,V_ELEMENT_TYPE_ID, P_EFFECTIVE_START_DATE) 
                LOOP
                     V_ELEMENT_LINK_ID:=XXTG_REC.ELEMENT_LINK_ID;
                     V_INPUT_VALUE_ID:=XXTG_REC.INPUT_VALUE_ID;
                END LOOP;
    
             IF V_ELEMENT_LINK_ID IS NULL THEN
                             O_SAL_MSG := P_TG_ID ||  ' : Error : ' ||P_ALLOWANCE ||' '||
                              SUBSTR(SQLERRM, 1, 500);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG); 
             END IF;
           END;
            IF O_SAL_MSG IS NULL THEN
              BEGIN
                --
                V_ELEMENT_ENTRY_ID := NULL;
                V_OBJ_VER          := NULL;
                V_CREATE_WARNING   := NULL;
                --
                PY_ELEMENT_ENTRY_API.CREATE_ELEMENT_ENTRY(P_EFFECTIVE_DATE        => P_EFFECTIVE_START_DATE,
                                                          P_BUSINESS_GROUP_ID     => V_BG_ID,
                                                          P_ASSIGNMENT_ID         => V_ASSIGN_ID,
                                                          P_ELEMENT_LINK_ID       => V_ELEMENT_LINK_ID,
                                                          P_ENTRY_TYPE            => 'E',
                                                          P_INPUT_VALUE_ID1       => V_INPUT_VALUE_ID,
                                                          P_ENTRY_VALUE1          => P_ALLOWANCE_AMOUNT,
                                                          P_EFFECTIVE_START_DATE  => V_EFFECTIVE_START_DATE,
                                                          P_EFFECTIVE_END_DATE    => V_EFFECTIVE_START_DATE,
                                                          P_ELEMENT_ENTRY_ID      => V_ELEMENT_ENTRY_ID,
                                                          P_OBJECT_VERSION_NUMBER => V_OBJ_VER,
                                                          P_CREATE_WARNING        => V_CREATE_WARNING);
              
                IF L_FUTURE_DATE IS NOT NULL THEN
                  O_SAL_MSG := O_SAL_MSG || ' - Future element exist on ' ||P_ALLOWANCE ||' '||
                                TO_CHAR(L_FUTURE_DATE, 'DD-MON-RRRR') ||
                                ' Amount : ' || L_FUTURE_AMOUNT;
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  O_SAL_MSG := P_TG_ID || ' : HRA : ' || ' Error : ' ||P_ALLOWANCE ||' '||
                                SUBSTR(SQLERRM, 1, 500);
              END;
            
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG);
            END IF;
          END IF;
          END IF;    
       IF  O_SAL_MSG IS NULL THEN 
          O_SAL_MSG :='SUCCESS';
       END IF;
  
  END PUSH_ALLOWANCE_DETAILS;


 PROCEDURE PUSH_SAL_DETAILS(
    P_BASIC           NUMBER,
    P_HRA             NUMBER,
    P_TRA             NUMBER,
    P_EMIRATE         VARCHAR2,
    P_CAMP            VARCHAR2,
    P_ROOM            VARCHAR2,
    P_CONTRACT_BATCH  VARCHAR2,
    P_EFFECTIVE_START_DATE  DATE,
    P_TG_ID            VARCHAR2,
    O_SAL_MSG OUT VARCHAR2) AS
    --
  
    V_ERR_FLAG                  VARCHAR2(1);
    V_ERR_MESG                  VARCHAR2(4000);
    V_PROPOSAL_REASON           VARCHAR2(400);
    V_OBJ_VER                   NUMBER DEFAULT NULL;
    V_INV_NEXT_SAL_DATE_WARNING BOOLEAN;
    V_PROPOSED_SALARY_WARNING   BOOLEAN;
    V_APPROVED_WARNING          BOOLEAN; 
    V_PAYROLL_WARNING           BOOLEAN;
    V_PAY_PROPOSAL_ID           NUMBER;
    V_PERSON_ID                 NUMBER;
    V_ASSIGN_ID                 NUMBER;
    V_EFFECTIVE_DATE            DATE;
  
    --
    V_HIRE_DATE            DATE;
    V_BG_ID                NUMBER;
    V_ELEMENT_ENTRY_ID     NUMBER;
    V_MODE                 VARCHAR2(100);
    V_EFFECTIVE_START_DATE DATE;
    V_EFFECTIVE_END_DATE   DATE;
    V_UPDATE_WARNING       BOOLEAN;
    V_CREATE_WARNING       BOOLEAN;
    V_INPUT_VALUE_ID       NUMBER;
    V_ELEMENT_LINK_ID      NUMBER;
  
    L_SAL_CHANGE_DATE DATE;
    L_FUTURE_DATE     DATE;
    L_FUTURE_AMOUNT   NUMBER;
    V_ELEMENT_TYPE_ID NUMBER;
    LN_PREV_BAS_SAL    NUMBER;
  
    --
--    CURSOR CUR_SAL IS
--      SELECT D.TGID,
--             D.NEW_HRA,
--             D.NEW_TRA,
--             D.EFFECTIVE_DATE,
--             D.NEW_BASIC,
--             D.BGID
--        FROM TG_PFORM_DEPLOYMENT D
--       WHERE D.SRNO = P_SEQ;
   CURSOR XXTG_ASS_CUR (LC_TG_ID VARCHAR2, LD_EFFECTIVE_DATE DATE)
   IS
        SELECT  PPF.PERSON_ID,
                ORIGINAL_DATE_OF_HIRE,
                PAF.ASSIGNMENT_ID,
                PPF.BUSINESS_GROUP_ID
--          INTO V_PERSON_ID,
--               V_HIRE_DATE,
--               V_ASSIGN_ID,
--               V_BG_ID
          FROM PER_ALL_ASSIGNMENTS_F PAF,
               PER_ALL_PEOPLE_F      PPF
         WHERE PPF.PERSON_ID = PAF.PERSON_ID
            AND FND_CONC_DATE.STRING_TO_DATE(LD_EFFECTIVE_DATE) BETWEEN PPF.EFFECTIVE_START_DATE AND
               PPF.EFFECTIVE_END_DATE
           AND FND_CONC_DATE.STRING_TO_DATE(LD_EFFECTIVE_DATE) BETWEEN PAF.EFFECTIVE_START_DATE AND
               PAF.EFFECTIVE_END_DATE
           AND PPF.CURRENT_EMPLOYEE_FLAG = 'Y'
           AND paf.assignment_type      = 'E'
           AND paf.primary_flag         = 'Y'
           AND paf.assignment_status_type_id = 1 
           AND PPF.EMPLOYEE_NUMBER = LC_TG_ID;

          
 CURSOR XXTG_FUTURE_CUR(LN_ASSIGNMENT_ID NUMBER, LD_EFFECTIVE_DATE DATE)
 IS 
            SELECT PY.CHANGE_DATE,
                   PY.PROPOSED_SALARY_N
--              INTO L_FUTURE_DATE,
--                   L_FUTURE_AMOUNT
              FROM PER_PAY_PROPOSALS PY
             WHERE PY.ASSIGNMENT_ID = LN_ASSIGNMENT_ID
               AND PY.CHANGE_DATE =
                   (SELECT MIN(PYY.CHANGE_DATE)
                      FROM PER_PAY_PROPOSALS PYY
                     WHERE PYY.ASSIGNMENT_ID = LN_ASSIGNMENT_ID
                       AND PYY.CHANGE_DATE > FND_CONC_DATE.STRING_TO_DATE(LD_EFFECTIVE_DATE));
  CURSOR XXTG_PROPOSE_CUR ( LN_ASSIGNMENT_ID NUMBER, LD_EFFECTIVE_DATE DATE)
   IS
              SELECT        PPP.CHANGE_DATE,
                            PPP.OBJECT_VERSION_NUMBER,
                            PPP.PAY_PROPOSAL_ID
--              INTO L_SAL_CHANGE_DATE,
--                   V_OBJ_VER,
--                   V_PAY_PROPOSAL_ID
              FROM PER_ALL_ASSIGNMENTS_F PAF,
                   PER_PAY_PROPOSALS     PPP
             WHERE PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
               AND   FND_CONC_DATE.STRING_TO_DATE(LD_EFFECTIVE_DATE) BETWEEN PAF.EFFECTIVE_START_DATE
                                       AND   PAF.EFFECTIVE_END_DATE
               AND FND_CONC_DATE.STRING_TO_DATE(LD_EFFECTIVE_DATE) BETWEEN PPP.CHANGE_DATE
                                     AND PPP.DATE_TO
               AND paf.assignment_type      = 'E'
               AND paf.primary_flag         = 'Y'
               AND paf.assignment_status_type_id = 1 
               AND PAF.ASSIGNMENT_ID = LN_ASSIGNMENT_ID;
  CURSOR XXTG_ELE_TYPE_CUR (LD_EFFECTIVE_DATE DATE, LP_ELEMENT_NAME VARCHAR2)
  IS 
           SELECT ET.ELEMENT_TYPE_ID
--            INTO V_ELEMENT_TYPE_ID
            FROM PAY_ELEMENT_TYPES_F ET
           WHERE ET.ELEMENT_NAME = LP_ELEMENT_NAME  --'House Rent Allowance'
             AND LD_EFFECTIVE_DATE BETWEEN ET.EFFECTIVE_START_DATE AND
                 ET.EFFECTIVE_END_DATE;
  CURSOR  XXTG_ELEMENT_ENTRIES (LN_ASSIGN_ID NUMBER,LN_ELEMENT_TYPE_ID NUMBER, LD_EFFECTIVE_DATE DATE)
  IS 
  SELECT PEE.ELEMENT_ENTRY_ID,
                   PEE.OBJECT_VERSION_NUMBER,
                   (SELECT INPUT_VALUE_ID
                      FROM PAY_INPUT_VALUES_F
                     WHERE ELEMENT_TYPE_ID = LN_ELEMENT_TYPE_ID
                       AND NAME ='Override Amount'
                       AND UOM = 'M'
                       AND LD_EFFECTIVE_DATE BETWEEN
                           EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE) INPUT_VALUE_ID,
                   PEE.EFFECTIVE_START_DATE
              FROM PAY_ELEMENT_ENTRIES_F PEE
             WHERE PEE.ASSIGNMENT_ID = LN_ASSIGN_ID
               AND PEE.ELEMENT_TYPE_ID = LN_ELEMENT_TYPE_ID
               AND LD_EFFECTIVE_DATE BETWEEN PEE.EFFECTIVE_START_DATE AND
                   PEE.EFFECTIVE_END_DATE;
  CURSOR  XXTG_FUTURE_ELEMENT_ENTRIES (LN_ASSIGN_ID NUMBER,LN_ELEMENT_TYPE_ID NUMBER, LD_EFFECTIVE_DATE DATE)
  IS
            SELECT EF.EFFECTIVE_START_DATE,
                   APPSLINK_PAYROLL_PKG.GET_ELEMENT_ENTRY_BY_DATE(EF.ELEMENT_ENTRY_ID,
                                                                  (SELECT INPUT_VALUE_ID
                                                                     FROM PAY_INPUT_VALUES_F
                                                                    WHERE ELEMENT_TYPE_ID =
                                                                          LN_ELEMENT_TYPE_ID
                                                                      AND NAME ='Override Amount'
                                                                      AND UOM = 'M'
                                                                      AND LD_EFFECTIVE_DATE BETWEEN
                                                                          EFFECTIVE_START_DATE AND
                                                                          EFFECTIVE_END_DATE),
                                                                  EF.EFFECTIVE_START_DATE) ENTRY_VALUE
              FROM PAY_ELEMENT_ENTRIES_F EF
             WHERE EF.ASSIGNMENT_ID = LN_ASSIGN_ID
               AND EF.ELEMENT_TYPE_ID = LN_ELEMENT_TYPE_ID
               AND EF.EFFECTIVE_START_DATE =
                   (SELECT MIN(EFF.EFFECTIVE_START_DATE)
                      FROM PAY_ELEMENT_ENTRIES_F EFF
                     WHERE EFF.ASSIGNMENT_ID = LN_ASSIGN_ID
                       AND EFF.ELEMENT_TYPE_ID = LN_ELEMENT_TYPE_ID
                       AND EFF.EFFECTIVE_START_DATE > LD_EFFECTIVE_DATE);
  CURSOR XXTG_ELE_LINK (LN_ASSIGN_ID NUMBER,LN_ELEMENT_TYPE_ID NUMBER, LD_EFFECTIVE_DATE DATE)
  IS 
                SELECT L.ELEMENT_LINK_ID,
                     (SELECT INPUT_VALUE_ID
                        FROM PAY_INPUT_VALUES_F
                       WHERE ELEMENT_TYPE_ID = LN_ELEMENT_TYPE_ID
                         AND NAME ='Override Amount'
                         AND UOM = 'M'
                         AND LD_EFFECTIVE_DATE BETWEEN
                             EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE) INPUT_VALUE_ID
--                INTO V_ELEMENT_LINK_ID,
--                     V_INPUT_VALUE_ID
                FROM PAY_ELEMENT_LINKS_F L,
                     PER_ASSIGNMENTS_F   A
               WHERE LD_EFFECTIVE_DATE BETWEEN L.EFFECTIVE_START_DATE AND
                     L.EFFECTIVE_END_DATE
                 AND LD_EFFECTIVE_DATE BETWEEN A.EFFECTIVE_START_DATE AND
                     A.EFFECTIVE_END_DATE
                 AND NVL(L.PAY_BASIS_ID, A.PAY_BASIS_ID) = A.PAY_BASIS_ID
                 AND NVL(L.JOB_ID, A.JOB_ID) = A.JOB_ID
                 AND NVL(L.PAYROLL_ID, A.PAYROLL_ID) = A.PAYROLL_ID
                 AND NVL(L.LOCATION_ID, A.LOCATION_ID) = A.LOCATION_ID
                 AND NVL(L.ORGANIZATION_ID, A.ORGANIZATION_ID) =
                     A.ORGANIZATION_ID
                 AND NVL(NVL(L.PEOPLE_GROUP_ID, A.PEOPLE_GROUP_ID), 0) =
                     NVL(A.PEOPLE_GROUP_ID, 0)
                 AND NVL(NVL(L.GRADE_ID, A.GRADE_ID), 0) =
                     NVL(A.GRADE_ID, 0)
                 AND L.BUSINESS_GROUP_ID = A.BUSINESS_GROUP_ID
                 AND A.ASSIGNMENT_ID = LN_ASSIGN_ID
                 AND L.ELEMENT_TYPE_ID =LN_ELEMENT_TYPE_ID;

  BEGIN
--    FOR REC_SAL IN CUR_SAL LOOP
      --
      V_ERR_MESG                  := NULL;
      V_ERR_FLAG                  := NULL;
      V_OBJ_VER                   := NULL;
      V_PAY_PROPOSAL_ID           := NULL;
      V_INV_NEXT_SAL_DATE_WARNING := NULL;
      V_APPROVED_WARNING          := NULL;
      V_PAYROLL_WARNING           := NULL;
      V_ELEMENT_ENTRY_ID          := NULL;
      V_PERSON_ID                 := NULL;
      V_HIRE_DATE                 := NULL;
      V_ASSIGN_ID                 := NULL;
      V_BG_ID                     := NULL;
      V_MODE                      := NULL;
      V_EFFECTIVE_START_DATE      := NULL;
      V_EFFECTIVE_END_DATE        := NULL;
      V_UPDATE_WARNING            := NULL;
      V_INPUT_VALUE_ID            := NULL;
      V_ELEMENT_LINK_ID           := NULL;
      L_SAL_CHANGE_DATE           := NULL;
      L_FUTURE_AMOUNT             := 0;
      V_ELEMENT_TYPE_ID           := NULL;
      LN_PREV_BAS_SAL             :=0;
    
    BEGIN
--           DBMS_OUTPUT.PUT_LINE('00 : '|| O_SAL_MSG);
      FOR XXTG_REC IN XXTG_ASS_CUR (P_TG_ID,P_EFFECTIVE_START_DATE)
        LOOP
          V_PERSON_ID:=XXTG_REC.PERSON_ID;
               V_HIRE_DATE:=XXTG_REC.ORIGINAL_DATE_OF_HIRE;
               V_ASSIGN_ID:=XXTG_REC.ASSIGNMENT_ID;
               V_BG_ID:=XXTG_REC.BUSINESS_GROUP_ID;
        END LOOP;
        IF V_PERSON_ID IS NULL THEN
        BEGIN
          O_SAL_MSG := P_TG_ID || ' ' || P_EFFECTIVE_START_DATE ||
                        ' : Employee not found.';
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG);
--           DBMS_OUTPUT.PUT_LINE('01 : '|| O_SAL_MSG);
        END;
        END IF;
--        SELECT DISTINCT PPF.PERSON_ID,
--                        ORIGINAL_DATE_OF_HIRE,
--                        PAF.ASSIGNMENT_ID,
--                        PPF.BUSINESS_GROUP_ID
--          INTO V_PERSON_ID,
--               V_HIRE_DATE,
--               V_ASSIGN_ID,
--               V_BG_ID
--          FROM PER_ALL_ASSIGNMENTS_F PAF,
--               PER_ALL_PEOPLE_F      PPF
--         WHERE REC_SAL.EFFECTIVE_DATE BETWEEN PPF.EFFECTIVE_START_DATE AND
--               PPF.EFFECTIVE_END_DATE
--           AND REC_SAL.EFFECTIVE_DATE BETWEEN PAF.EFFECTIVE_START_DATE AND
--               PAF.EFFECTIVE_END_DATE
--           AND PPF.PERSON_ID = PAF.PERSON_ID
--           AND PPF.EMPLOYEE_NUMBER = REC_SAL.TGID
--           AND PPF.CURRENT_EMPLOYEE_FLAG = 'Y'
--           AND PPF.BUSINESS_GROUP_ID = REC_SAL.BGID;
--      EXCEPTION
--        WHEN NO_DATA_FOUND THEN
--          V_ERR_FLAG := 'E';
--          V_ERR_MESG := REC_SAL.TGID || ' ' || REC_SAL.EFFECTIVE_DATE ||
--                        ' : Employee not found.';
--          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, V_ERR_MESG);
--          DBMS_OUTPUT.PUT_LINE('880 : ' || V_ERR_MESG);
--      END;
    
      IF O_SAL_MSG IS NULL THEN
        IF NVL(P_BASIC,0) > 0 THEN
          L_FUTURE_DATE   := NULL;
          L_FUTURE_AMOUNT := 0;
        FOR XXTG_REC IN XXTG_FUTURE_CUR(P_TG_ID,P_EFFECTIVE_START_DATE)
          LOOP
            L_FUTURE_DATE:=XXTG_REC.CHANGE_DATE;
            L_FUTURE_AMOUNT:=XXTG_REC.PROPOSED_SALARY_N;
          END LOOP;
          -- Get future element date and amount
        FOR XXTG_REC IN XXTG_PROPOSE_CUR(P_TG_ID,P_EFFECTIVE_START_DATE)
          LOOP
            L_SAL_CHANGE_DATE:=XXTG_REC.CHANGE_DATE;
            V_OBJ_VER:=XXTG_REC.OBJECT_VERSION_NUMBER;
            V_PAY_PROPOSAL_ID:=XXTG_REC.PAY_PROPOSAL_ID;
          END LOOP;
         FOR XXTG_REC IN XXTG_PREV_COMP_CHECK ( V_PERSON_ID, P_EFFECTIVE_START_DATE, 'Basic Salary', 'Basic Salary')
           LOOP
             LN_PREV_BAS_SAL := NVL(XXTG_REC.VALUE,0);
           END LOOP;  
          
         IF NVL(TO_NUMBER(P_BASIC),0) <> NVL(LN_PREV_BAS_SAL,0) THEN
          BEGIN
            IF (P_EFFECTIVE_START_DATE <> L_SAL_CHANGE_DATE) OR
               (L_SAL_CHANGE_DATE IS NULL) THEN
              V_PAY_PROPOSAL_ID := NULL;
              V_OBJ_VER         := NULL;
--              DBMS_OUTPUT.PUT_LINE('02 : '|| L_SAL_CHANGE_DATE);
              HR_MAINTAIN_PROPOSAL_API.CRE_OR_UPD_SALARY_PROPOSAL(P_VALIDATE                  => FALSE,
                                                                  P_PAY_PROPOSAL_ID           => V_PAY_PROPOSAL_ID,
                                                                  P_OBJECT_VERSION_NUMBER     => V_OBJ_VER,
                                                                  P_BUSINESS_GROUP_ID         => V_BG_ID,
                                                                  P_ASSIGNMENT_ID             => V_ASSIGN_ID,
                                                                  P_CHANGE_DATE               => P_EFFECTIVE_START_DATE,
                                                                  P_PROPOSED_SALARY_N         => TO_NUMBER(P_BASIC),
                                                                  P_DATE_TO                   => NULL,
                                                                  P_MULTIPLE_COMPONENTS       => 'N',
                                                                  P_APPROVED                  => 'Y',
                                                                  P_INV_NEXT_SAL_DATE_WARNING => V_INV_NEXT_SAL_DATE_WARNING,
                                                                  P_PROPOSED_SALARY_WARNING   => V_PROPOSED_SALARY_WARNING,
                                                                  P_APPROVED_WARNING          => V_APPROVED_WARNING,
                                                                  P_PAYROLL_WARNING           => V_PAYROLL_WARNING);
            ELSE
--              DBMS_OUTPUT.PUT_LINE('03 : ');
              HR_MAINTAIN_PROPOSAL_API.UPDATE_SALARY_PROPOSAL(P_PAY_PROPOSAL_ID           => V_PAY_PROPOSAL_ID,
                                                              P_OBJECT_VERSION_NUMBER     => V_OBJ_VER,
                                                              P_CHANGE_DATE               => P_EFFECTIVE_START_DATE,
                                                              P_PROPOSAL_REASON           => V_PROPOSAL_REASON,
                                                              P_PROPOSED_SALARY_N         => TO_NUMBER(P_BASIC),
                                                              P_MULTIPLE_COMPONENTS       => 'N',
                                                              P_APPROVED                  => 'Y',
                                                              P_INV_NEXT_SAL_DATE_WARNING => V_INV_NEXT_SAL_DATE_WARNING,
                                                              P_PROPOSED_SALARY_WARNING   => V_PROPOSED_SALARY_WARNING,
                                                              P_APPROVED_WARNING          => V_APPROVED_WARNING,
                                                              P_PAYROLL_WARNING           => V_PAYROLL_WARNING);
            END IF;
          
--            V_ERR_MESG := P_TG_ID || ' : Basic Salary ' ||
--                          ' : Uploaded successfully.';
            IF L_FUTURE_DATE IS NOT NULL THEN
--              V_ERR_FLAG := 'E';
              O_SAL_MSG := O_SAL_MSG ||
                            ' - Future basic salary exist on ' ||
                            TO_CHAR(L_FUTURE_DATE, 'DD-MON-RRRR') ||
                            ' Amount : ' || L_FUTURE_AMOUNT;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
--              V_ERR_FLAG := 'E';
              O_SAL_MSG := P_TG_ID || ' : Basic Salary ' ||
                            ' Error : ' || SUBSTR(SQLERRM, 1, 500);
              DBMS_OUTPUT.PUT_LINE('957 : ' || SQLERRM);
          END;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG);
          DBMS_OUTPUT.PUT_LINE('964 : ' || V_ERR_MESG);
       END IF; -- END IF TO CHECK FOR CHANGE IN BASIC SALARY 
      END IF;
      
        --            ELSIF REC_SAL.NEW_HRA > 0
        IF NVL(P_HRA,0) > 0 AND O_SAL_MSG IS NULL THEN
        
          FOR XXTG_REC IN XXTG_ELE_TYPE_CUR (P_EFFECTIVE_START_DATE,'House Rent Allowance')
            LOOP
              V_ELEMENT_TYPE_ID :=XXTG_REC.ELEMENT_TYPE_ID;
            END LOOP;

          FOR XXTG_REC IN XXTG_ELEMENT_ENTRIES (V_ASSIGN_ID,V_ELEMENT_TYPE_ID, P_EFFECTIVE_START_DATE)
           LOOP
             V_ELEMENT_ENTRY_ID:=XXTG_REC.ELEMENT_ENTRY_ID;
             V_OBJ_VER:=XXTG_REC.OBJECT_VERSION_NUMBER;
             V_INPUT_VALUE_ID:=XXTG_REC.INPUT_VALUE_ID;
             V_EFFECTIVE_DATE:=XXTG_REC.EFFECTIVE_START_DATE;
           END LOOP;

          IF V_ELEMENT_ENTRY_ID IS NOT NULL THEN
            V_MODE := 'UPDATE';
          ELSIF V_ELEMENT_ENTRY_ID IS NULL THEN
          V_MODE := 'CREATE';
          END IF;
          
        
          L_FUTURE_DATE   := NULL;
          L_FUTURE_AMOUNT := 0;
        
         FOR XXTG_REC IN XXTG_FUTURE_ELEMENT_ENTRIES(V_ASSIGN_ID,V_ELEMENT_TYPE_ID, P_EFFECTIVE_START_DATE) 
           LOOP
                   L_FUTURE_DATE:=XXTG_REC.EFFECTIVE_START_DATE;
                   L_FUTURE_AMOUNT:=XXTG_REC.ENTRY_VALUE;
           END LOOP;

        
          IF O_SAL_MSG IS NULL AND V_MODE = 'UPDATE' THEN
            BEGIN
              IF V_EFFECTIVE_DATE = P_EFFECTIVE_START_DATE THEN
                V_MODE := 'CORRECTION';
              ELSIF L_FUTURE_DATE IS NOT NULL THEN
                V_MODE := 'UPDATE_CHANGE_INSERT';
              ELSE
                V_MODE := 'UPDATE';
              END IF;
            
              PY_ELEMENT_ENTRY_API.UPDATE_ELEMENT_ENTRY(P_VALIDATE              => FALSE,
                                                        P_DATETRACK_UPDATE_MODE => V_MODE,
                                                        P_EFFECTIVE_DATE        => P_EFFECTIVE_START_DATE,
                                                        P_BUSINESS_GROUP_ID     => V_BG_ID,
                                                        P_ELEMENT_ENTRY_ID      => V_ELEMENT_ENTRY_ID,
                                                        P_OBJECT_VERSION_NUMBER => V_OBJ_VER,
                                                        P_INPUT_VALUE_ID1       => V_INPUT_VALUE_ID,
                                                        P_ENTRY_VALUE1          => P_HRA,
                                                        P_EFFECTIVE_START_DATE  => V_EFFECTIVE_START_DATE,
                                                        P_EFFECTIVE_END_DATE    => V_EFFECTIVE_START_DATE,
                                                        P_UPDATE_WARNING        => V_UPDATE_WARNING);
            
--              O_SAL_MSG := P_TG_ID || ' : HRA ' ||
--                            ' : Uploaded Successfully.';
            
              IF L_FUTURE_DATE IS NOT NULL THEN
--                V_ERR_FLAG := 'E';
                O_SAL_MSG := O_SAL_MSG || ' - Future element exist on ' ||
                              TO_CHAR(L_FUTURE_DATE, 'DD-MON-RRRR') ||
                              ' Amount : ' || L_FUTURE_AMOUNT;
              END IF;
            
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, V_ERR_MESG);
--              DBMS_OUTPUT.PUT_LINE('1074 : ' || V_ERR_MESG);
            EXCEPTION
              WHEN OTHERS THEN
--                V_ERR_FLAG := 'E';
                O_SAL_MSG := P_TG_ID || ' : HRA ' || ' : Error : ' ||
                              SUBSTR(SQLERRM, 1, 500);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG);
--                DBMS_OUTPUT.PUT_LINE('1081 : ' || O_SAL_MSG);
            END;
          ELSIF O_SAL_MSG IS NULL AND V_MODE = 'CREATE' THEN
            ----
            BEGIN
              FOR XXTG_REC IN  XXTG_ELE_LINK (V_ASSIGN_ID,V_ELEMENT_TYPE_ID, P_EFFECTIVE_START_DATE) 
                LOOP
                     V_ELEMENT_LINK_ID:=XXTG_REC.ELEMENT_LINK_ID;
                     V_INPUT_VALUE_ID:=XXTG_REC.INPUT_VALUE_ID;
                END LOOP;
    
             IF V_ELEMENT_LINK_ID IS NULL THEN
                             O_SAL_MSG := P_TG_ID || ' : HRA ' || ' : Error : ' ||
                              SUBSTR(SQLERRM, 1, 500);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG); 
             END IF;
           END;
            IF O_SAL_MSG IS NULL THEN
              BEGIN
                --
                V_ELEMENT_ENTRY_ID := NULL;
                V_OBJ_VER          := NULL;
                V_CREATE_WARNING   := NULL;
                --
                PY_ELEMENT_ENTRY_API.CREATE_ELEMENT_ENTRY(P_EFFECTIVE_DATE        => P_EFFECTIVE_START_DATE,
                                                          P_BUSINESS_GROUP_ID     => V_BG_ID,
                                                          P_ASSIGNMENT_ID         => V_ASSIGN_ID,
                                                          P_ELEMENT_LINK_ID       => V_ELEMENT_LINK_ID,
                                                          P_ENTRY_TYPE            => 'E',
                                                          P_INPUT_VALUE_ID1       => V_INPUT_VALUE_ID,
                                                          P_ENTRY_VALUE1          => P_HRA,
                                                          P_EFFECTIVE_START_DATE  => V_EFFECTIVE_START_DATE,
                                                          P_EFFECTIVE_END_DATE    => V_EFFECTIVE_START_DATE,
                                                          P_ELEMENT_ENTRY_ID      => V_ELEMENT_ENTRY_ID,
                                                          P_OBJECT_VERSION_NUMBER => V_OBJ_VER,
                                                          P_CREATE_WARNING        => V_CREATE_WARNING);
              
                IF L_FUTURE_DATE IS NOT NULL THEN
--                  V_ERR_FLAG := 'E';
                  O_SAL_MSG := O_SAL_MSG || ' - Future element exist on ' ||
                                TO_CHAR(L_FUTURE_DATE, 'DD-MON-RRRR') ||
                                ' Amount : ' || L_FUTURE_AMOUNT;
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
--                  V_ERR_FLAG := 'E';
                  O_SAL_MSG := P_TG_ID || ' : HRA : ' || ' Error : ' ||
                                SUBSTR(SQLERRM, 1, 500);
              END;
            
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG);
--              DBMS_OUTPUT.PUT_LINE('1162 : ' || V_ERR_MESG);
            END IF;
          END IF;
        
        END IF;
      
        --            ELSIF REC_SAL.NEW_TRA > 0
        V_ELEMENT_TYPE_ID :=NULL;
        IF NVL(P_TRA,0) > 0 AND O_SAL_MSG IS NULL THEN
         FOR XXTG_REC IN XXTG_ELE_TYPE_CUR (P_EFFECTIVE_START_DATE,'Transportation Allowance')
            LOOP
              V_ELEMENT_TYPE_ID :=XXTG_REC.ELEMENT_TYPE_ID;
            END LOOP;
          FOR XXTG_REC IN XXTG_ELEMENT_ENTRIES (V_ASSIGN_ID,V_ELEMENT_TYPE_ID, P_EFFECTIVE_START_DATE)
           LOOP
             V_ELEMENT_ENTRY_ID:=XXTG_REC.ELEMENT_ENTRY_ID;
             V_OBJ_VER:=XXTG_REC.OBJECT_VERSION_NUMBER;
             V_INPUT_VALUE_ID:=XXTG_REC.INPUT_VALUE_ID;
             V_EFFECTIVE_DATE:=XXTG_REC.EFFECTIVE_START_DATE;
           END LOOP;

          IF V_ELEMENT_ENTRY_ID IS NOT NULL THEN
            V_MODE := 'UPDATE';
          ELSIF V_ELEMENT_ENTRY_ID IS NULL THEN
          V_MODE := 'CREATE';
          END IF;
          

        
          L_FUTURE_DATE   := NULL;
          L_FUTURE_AMOUNT := 0;
         FOR XXTG_REC IN XXTG_FUTURE_ELEMENT_ENTRIES(V_ASSIGN_ID,V_ELEMENT_TYPE_ID, P_EFFECTIVE_START_DATE) 
           LOOP
                   L_FUTURE_DATE:=XXTG_REC.EFFECTIVE_START_DATE;
                   L_FUTURE_AMOUNT:=XXTG_REC.ENTRY_VALUE;
           END LOOP;
                     
          IF O_SAL_MSG IS NULL AND V_MODE = 'UPDATE' THEN
            BEGIN
              IF V_EFFECTIVE_DATE IS NULL OR  V_EFFECTIVE_DATE = P_EFFECTIVE_START_DATE THEN
                V_MODE := 'CORRECTION';
              ELSIF L_FUTURE_DATE IS NOT NULL THEN
                V_MODE := 'UPDATE_CHANGE_INSERT';
              ELSE
                V_MODE := 'UPDATE';
              END IF;
            
              PY_ELEMENT_ENTRY_API.UPDATE_ELEMENT_ENTRY(P_VALIDATE              => FALSE,
                                                        P_DATETRACK_UPDATE_MODE => V_MODE,
                                                        P_EFFECTIVE_DATE        => P_EFFECTIVE_START_DATE,
                                                        P_BUSINESS_GROUP_ID     => V_BG_ID,
                                                        P_ELEMENT_ENTRY_ID      => V_ELEMENT_ENTRY_ID,
                                                        P_OBJECT_VERSION_NUMBER => V_OBJ_VER,
                                                        P_INPUT_VALUE_ID1       => V_INPUT_VALUE_ID,
                                                        P_ENTRY_VALUE1          => P_TRA,
                                                        P_EFFECTIVE_START_DATE  => V_EFFECTIVE_START_DATE,
                                                        P_EFFECTIVE_END_DATE    => V_EFFECTIVE_START_DATE,
                                                        P_UPDATE_WARNING        => V_UPDATE_WARNING);
            
              IF L_FUTURE_DATE IS NOT NULL THEN
                O_SAL_MSG := O_SAL_MSG || ' - Future element exist on ' ||
                              TO_CHAR(L_FUTURE_DATE, 'DD-MON-RRRR') ||
                              ' Amount : ' || L_FUTURE_AMOUNT;
              END IF;
            
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, V_ERR_MESG);
            EXCEPTION
              WHEN OTHERS THEN
--                V_ERR_FLAG := 'E';
                O_SAL_MSG := P_TG_ID || ' : TRA ' || ' : Error : ' ||
                              SUBSTR(SQLERRM, 1, 500);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG);
--                DBMS_OUTPUT.PUT_LINE('1081 : ' || O_SAL_MSG);
            END;
          ELSIF O_SAL_MSG IS NULL AND V_MODE = 'CREATE' THEN
            ----
            BEGIN
              FOR XXTG_REC IN  XXTG_ELE_LINK (V_ASSIGN_ID,V_ELEMENT_TYPE_ID, P_EFFECTIVE_START_DATE) 
                LOOP
                     V_ELEMENT_LINK_ID:=XXTG_REC.ELEMENT_LINK_ID;
                     V_INPUT_VALUE_ID:=XXTG_REC.INPUT_VALUE_ID;
                END LOOP;
                
             IF V_ELEMENT_LINK_ID IS NULL THEN
                             O_SAL_MSG := P_TG_ID || ' : TRA ' || ' : Error : ' ||
                              SUBSTR(SQLERRM, 1, 500);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG); 
             END IF;
           END;
            IF O_SAL_MSG IS NULL THEN
              BEGIN        
                --
                V_ELEMENT_ENTRY_ID := NULL;
                V_OBJ_VER          := NULL;
                V_CREATE_WARNING   := NULL;
                --
                PY_ELEMENT_ENTRY_API.CREATE_ELEMENT_ENTRY(P_EFFECTIVE_DATE        => P_EFFECTIVE_START_DATE,
                                                          P_BUSINESS_GROUP_ID     => V_BG_ID,
                                                          P_ASSIGNMENT_ID         => V_ASSIGN_ID,
                                                          P_ELEMENT_LINK_ID       => V_ELEMENT_LINK_ID,
                                                          P_ENTRY_TYPE            => 'E',
                                                          P_INPUT_VALUE_ID1       => V_INPUT_VALUE_ID,
                                                          P_ENTRY_VALUE1          => P_TRA,
                                                          P_EFFECTIVE_START_DATE  => V_EFFECTIVE_START_DATE,
                                                          P_EFFECTIVE_END_DATE    => V_EFFECTIVE_START_DATE,
                                                          P_ELEMENT_ENTRY_ID      => V_ELEMENT_ENTRY_ID,
                                                          P_OBJECT_VERSION_NUMBER => V_OBJ_VER,
                                                          P_CREATE_WARNING        => V_CREATE_WARNING);

              
                IF L_FUTURE_DATE IS NOT NULL THEN
--                  V_ERR_FLAG := 'E';
                  O_SAL_MSG := O_SAL_MSG || ' - Future element exist on ' ||
                                TO_CHAR(L_FUTURE_DATE, 'DD-MON-RRRR') ||
                                ' Amount : ' || L_FUTURE_AMOUNT;
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
--                  V_ERR_FLAG := 'E';
                  O_SAL_MSG := P_TG_ID || ' : TRA : ' || ' Error : ' ||
                                SUBSTR(SQLERRM, 1, 500);
              END;
            
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_SAL_MSG);
--              DBMS_OUTPUT.PUT_LINE('1366 : ' || V_ERR_MESG);
            END IF;
          END IF;
        
        END IF; -- End if of Basic Salary or Allowances
      END IF;
    
--      DBMS_OUTPUT.PUT_LINE('1372 : After Endif');
--      END IF;
       IF  O_SAL_MSG IS NULL THEN 
          O_SAL_MSG :='SUCCESS';
       END IF;
    END LOOP;

    --
    --  COMMIT;
  
  END PUSH_SAL_DETAILS;


  PROCEDURE PUSH_ASG_DETAILS(
    P_ORGANIZATION    VARCHAR2,
    P_JOB            VARCHAR2,
    P_ROSTER         VARCHAR2,
    P_BASIC           NUMBER,
    P_HRA             NUMBER,
    P_TRA             NUMBER,
    P_EMIRATE         VARCHAR2,
    P_CAMP            VARCHAR2,
    P_ROOM            VARCHAR2,
    P_CONTRACT_BATCH  VARCHAR2,
    P_EFFECTIVE_START_DATE  DATE,
    P_TG_ID            VARCHAR2,
    O_ASG_MSG       OUT VARCHAR2 )
    IS
    L_PAYROLL_ID     NUMBER;
    L_JOB_ID         NUMBER;
    L_ROSTER_ID      NUMBER;
    L_ERROR          VARCHAR2(1000);
    L_MSG            VARCHAR2(2000);
    L_ASG_ID         NUMBER;
    L_ASG_OVN        NUMBER;
    L_EFFECTIVE_DATE DATE;
    L_CONTRACT_ID    NUMBER;
    L_PPL_GRP_ID     NUMBER;
    L_GRADE_ID       NUMBER;
    L_LOCATION_ID    NUMBER;
    L_BG_ID          NUMBER;
    L_ASG_TYPE       VARCHAR2(200);
    ---------------------------------
    L_TOTAL                   NUMBER := 0;
    L_ERROR_COUNT             NUMBER := 0;
    L_SUCCESS_COUNT           NUMBER := 0;
    L_FUTURE_ASG              NUMBER := 0;
    L_FUTURE_DATE             DATE;
    L_SPECIAL_CEILING_STEP_ID NUMBER;
  
    L_GROUP_NAME                   VARCHAR2(1000);
    L_EFFECTIVE_START_DATE         DATE;
    L_EFFECTIVE_END_DATE           DATE;
    L_ORG_NOW_NO_MANAGER_WARNING   BOOLEAN;
    L_OTHER_MANAGER_WARNING        BOOLEAN;
    L_SPP_DELETE_WARNING           BOOLEAN;
    L_ENTRIES_CHANGED_WARNING      VARCHAR2(1000);
    L_TAX_DISTRICT_CHANGED_WARNING BOOLEAN;
    LC_MODE                         VARCHAR2(100);
  
    L_HRA_FLAG           CHAR(1);
    L_TRA_FLAG           CHAR(1);
    L_COMMENT_ID         NUMBER;
    L_NO_MANAGER_WARNING BOOLEAN;
    L_CONCAT_SEG         VARCHAR2(200);
    L_SOFT_CODE          NUMBER;
    LD_FUTURE_DATE       DATE;
    LN_FUTURE_ASG        NUMBER;
    LN_PERSON_ID         NUMBER;
    -----------------------------------------------------------
-- Determine the date track mode
-----------------------------------------------------------
  -- DT_API Output Variables
   lb_correction             BOOLEAN;
   lb_update                 BOOLEAN;
   lb_update_override        BOOLEAN;
   lb_update_change_insert   BOOLEAN;

  
    ---------------------------------
--    CURSOR ALL_REC IS
--      SELECT D.* FROM TG_PFORM_DEPLOYMENT D WHERE D.SRNO = P_SEQ;
   CURSOR XXTG_ASSIGN (LC_TG_ID VARCHAR2 , LD_EFFECTIVE_START_DATE DATE)
    IS
            SELECT      A.ASSIGNMENT_ID,
                        A.OBJECT_VERSION_NUMBER,
                        A.EFFECTIVE_START_DATE,
                        A.ORGANIZATION_ID,
                        A.PEOPLE_GROUP_ID,
                        A.GRADE_ID,
                        A.JOB_ID,
                        A.PAYROLL_ID,
                        A.LOCATION_ID,
                        A.SPECIAL_CEILING_STEP_ID,
                        A.BUSINESS_GROUP_ID,
                        A.PERSON_ID,
                        (SELECT USER_STATUS FROM PER_ASSIGNMENT_STATUS_TYPES
                        WHERE ASSIGNMENT_STATUS_TYPE_ID = A.ASSIGNMENT_STATUS_TYPE_ID) USER_STATUS
          FROM PER_ALL_ASSIGNMENTS_F       A
         WHERE  A.ASSIGNMENT_NUMBER = LC_TG_ID
           AND LD_EFFECTIVE_START_DATE  BETWEEN A.EFFECTIVE_START_DATE AND
               A.EFFECTIVE_END_DATE
           AND A.ASSIGNMENT_TYPE = 'E';
           
    CURSOR  XXTG_ROSTER(LC_ROSTER VARCHAR2)
    IS SELECT PG.PEOPLE_GROUP_ID  
          FROM PAY_PEOPLE_GROUPS PG
         WHERE UPPER(TRIM(PG.GROUP_NAME)) = UPPER(TRIM(LC_ROSTER));
    CURSOR XXTG_CONTRACT(LC_CONTRACT VARCHAR2 , LD_EFFECTIVE_START_DATE DATE, LN_BG_ID NUMBER)
    IS 
      SELECT U.ORGANIZATION_ID
--            INTO L_CONTRACT_ID
            FROM HR_ALL_ORGANIZATION_UNITS U
           WHERE UPPER(TRIM(U.NAME)) = UPPER(TRIM(LC_CONTRACT))
             AND U.BUSINESS_GROUP_ID = LN_BG_ID
--             AND LD_EFFECTIVE_START_DATE BETWEEN U.DATE_FROM AND
--                U.DATE_TO
             AND U.TYPE = 'CNRT';
    CURSOR XXTG_PAYROLL(LN_CONTRACT_ID NUMBER, LN_BG_ID NUMBER) 
    IS 
    SELECT U.ATTRIBUTE17 PAYROLL_ID
    FROM HR_ALL_ORGANIZATION_UNITS U
    WHERE U.ORGANIZATION_ID = LN_CONTRACT_ID
    AND U.BUSINESS_GROUP_ID = LN_BG_ID;
    CURSOR   XXTG_JOB_CUR (LC_JOB_NAME VARCHAR2, LN_BG_ID NUMBER) 
    IS 
          SELECT JOB_ID
            FROM PER_JOBS PJ
           WHERE UPPER(TRIM(PJ.NAME)) = UPPER(TRIM(LC_JOB_NAME))
            AND PJ.BUSINESS_GROUP_ID = LN_BG_ID; 
    CURSOR XXTG_COUNT_FUTURE (P_ASSIGNMENT_ID NUMBER, P_DATE DATE, LN_BG_ID NUMBER)  
    IS SELECT COUNT(1) COUNT,
               MIN(A.EFFECTIVE_START_DATE) EFFECTIVE_START_DATE
          FROM PER_ALL_ASSIGNMENTS_F A
         WHERE A.ASSIGNMENT_ID = P_ASSIGNMENT_ID
           AND A.EFFECTIVE_START_DATE > P_DATE;
    CURSOR  XXTG_ROSTER_NAME (LC_ROSTER_NAME VARCHAR2, LN_BG_ID NUMBER)  IS
    SELECT ORGANIZATION_ID FROM HR_ALL_ORGANIZATION_UNITS WHERE UPPER(TRIM(NAME)) = UPPER(TRIM(LC_ROSTER_NAME))
    AND BUSINESS_GROUP_ID = LN_BG_ID;
  BEGIN
 --   FOR REC IN ALL_REC LOOP
      FOR XXTG_REC IN XXTG_ASSIGN (P_TG_ID , P_EFFECTIVE_START_DATE)
       LOOP
      L_ERROR                   := NULL;
      L_SPECIAL_CEILING_STEP_ID := NULL;
      L_PPL_GRP_ID              := NULL;
      L_ASG_OVN                 := NULL;
      L_FUTURE_ASG              := 0;
      L_FUTURE_DATE             := NULL;
      LC_MODE                    := NULL;
      L_ASG_ID                  := NULL;
      L_EFFECTIVE_DATE          := NULL;
      L_CONTRACT_ID             := NULL;
      L_GRADE_ID                := NULL;
      L_JOB_ID                  := NULL;
      L_PAYROLL_ID              := NULL;
      L_ASG_TYPE                := NULL;
    

        L_ASG_ID  := XXTG_REC.ASSIGNMENT_ID;
        L_ASG_OVN := XXTG_REC.OBJECT_VERSION_NUMBER;
        L_EFFECTIVE_DATE :=  XXTG_REC.EFFECTIVE_START_DATE;
        L_CONTRACT_ID    :=  XXTG_REC.ORGANIZATION_ID;
        L_PPL_GRP_ID     :=  XXTG_REC.PEOPLE_GROUP_ID;
        L_GRADE_ID       :=  XXTG_REC.GRADE_ID;
        L_JOB_ID         :=  XXTG_REC.JOB_ID;
        L_PAYROLL_ID     :=  XXTG_REC.PAYROLL_ID;
        L_LOCATION_ID    :=  XXTG_REC.LOCATION_ID;
        L_SPECIAL_CEILING_STEP_ID :=   XXTG_REC.SPECIAL_CEILING_STEP_ID;
        L_ASG_TYPE       :=   XXTG_REC.USER_STATUS;
        L_BG_ID          :=   XXTG_REC.BUSINESS_GROUP_ID;
        LN_PERSON_ID     :=   XXTG_REC.PERSON_ID;
--  why do we need this for?      
--       FOR XXTG_REC IN XXTG_ROSTER (L_PPL_GRP_ID)
--         LOOP
--           L_ROSTER_ID := XXTG_REC.ROSTER;
--         END LOOP;
--    
      --------------------------------------------------   For Active Assignment Only
      IF   L_ASG_TYPE <> 'Active Assignment' THEN
        L_ERROR := 'Employee assignment as of effective date is : ' ||
                   L_ASG_TYPE || ', cannot proceed.';
        O_ASG_MSG   := P_TG_ID || ' : ' || L_ERROR;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_ASG_MSG);
      END IF;
    
      --------------------------------------------------   Validate Organization
      IF  P_ORGANIZATION IS NOT NULL THEN
        FOR XXTG_REC IN  XXTG_CONTRACT(P_ORGANIZATION , P_EFFECTIVE_START_DATE,L_BG_ID)
          LOOP
            L_CONTRACT_ID := XXTG_REC.ORGANIZATION_ID;
          END LOOP;
      END IF;
          IF L_CONTRACT_ID IS NULL THEN
             O_ASG_MSG   := O_ASG_MSG||' '|| P_TG_ID 
                                    || ' : Error while fetching contract details for : ' 
                                    ||  P_ORGANIZATION || '--' || P_EFFECTIVE_START_DATE||'--'||L_BG_ID;
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_ASG_MSG);
          END IF;
 
      --------------------------------------------------   Validate Payroll
      IF P_ORGANIZATION IS NOT NULL THEN
        FOR XXTG_REC IN XXTG_PAYROLL(L_CONTRACT_ID,L_BG_ID)
          LOOP
            L_PAYROLL_ID := XXTG_REC.PAYROLL_ID;
          END LOOP;
      END IF;
          IF L_PAYROLL_ID IS NULL THEN
--             O_ASG_MSG   := O_ASG_MSG||' '|| P_TG_ID 
--                                    || ' : Error while fetching Payroll For  Contract : ' 
--                                    ||  P_ORGANIZATION || '--' || P_EFFECTIVE_START_DATE;
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Payroll is not attached to Contract '|| O_ASG_MSG);
          END IF;
    
    
    
    
    
    
      --------------------------------------------------   Validate Job
      IF P_JOB IS NOT NULL THEN
        FOR XXTG_REC IN XXTG_JOB_CUR(P_JOB,L_BG_ID)
          LOOP
            L_JOB_ID := XXTG_REC.JOB_ID;
          END LOOP;
      END IF;
          IF L_JOB_ID IS NULL THEN
             O_ASG_MSG   := O_ASG_MSG||' '|| P_TG_ID 
                                    || ' : Error while fetching Job For  Contract : ' 
                                    ||  P_JOB || '--' || P_EFFECTIVE_START_DATE;
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_ASG_MSG);
          END IF;
     
    
-- Need to ask ayaz on this code
--      --------------------------------------------------   Validate Roster
--      IF L_ERROR IS NULL AND REC.NEW_ROSTER IS NOT NULL THEN
--        BEGIN
--          SELECT V.CHILD_ORG_ID
--            INTO L_ROSTER_ID
--            FROM TG_ORG_STRUCTURE_ALL_V V
--           WHERE V.BUSINESS_GROUP_ID = L_BG_ID
--             AND UPPER(TRIM(V.CHILD_ORG_NAME)) =
--                 UPPER(TRIM(REC.NEW_ROSTER))
--             AND V.CHILD_ORG_TYPE = 'RSTR'
--             AND V.PARENT_ORG_ID = L_CONTRACT_ID
--             AND V.PARENT_ORG_TYPE = 'CNRT';
--        EXCEPTION
--          WHEN OTHERS THEN
--            L_ERROR := SUBSTR(SQLERRM, 1, 1000);
--            L_MSG   := REC.TGID ||
--                       ' : Error while fetching roaster details from organization hierarchy : ' ||
--                       REC.NEW_ROSTER || ' - (Error : ' || L_ERROR || ')';
--          
--            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, L_MSG);
--            DBMS_OUTPUT.PUT_LINE('638 : ' || L_MSG);
--          
--            UPDATE TG_PFORM_DEPLOYMENT D
--               SET D.ASG_FLAG = 'E', D.ASG_MSG = L_MSG
--             WHERE D.SRNO = P_SEQ;
--            --   COMMIT;
--        END;

       IF P_ROSTER IS NOT NULL THEN
          FOR XXTG_REC IN XXTG_ROSTER(P_ROSTER)
            LOOP
              L_PPL_GRP_ID := XXTG_REC.PEOPLE_GROUP_ID;
            END LOOP;
            
            FOR XXTG_REC IN XXTG_ROSTER_NAME(P_ROSTER,L_BG_ID)
            LOOP
              L_ROSTER_ID := XXTG_REC.ORGANIZATION_ID;
            END LOOP;
       END IF;
       IF L_PPL_GRP_ID IS NULL THEN
          O_ASG_MSG   := P_TG_ID||
                       ' : Error while fetching roster details for : ' ||
                       P_ROSTER ;
          
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, O_ASG_MSG);
       END IF;
  ---------Added for Bug 51617 wherein Null roster was not getting updated for an employee 06-Mar-2017
        IF P_ROSTER IS NULL THEN
                L_PPL_GRP_ID := NULL;
                L_ROSTER_ID := NULL;
         END IF;
------------------------------------------------------- Upload roster Assignments
        LN_FUTURE_ASG := 0;
        FOR XXTG_REC IN XXTG_COUNT_FUTURE(L_ASG_ID, P_EFFECTIVE_START_DATE,L_BG_ID)
             LOOP
               LN_FUTURE_ASG  := XXTG_REC.COUNT;
               LD_FUTURE_DATE := XXTG_REC.EFFECTIVE_START_DATE;
             END LOOP;
--          IF LN_FUTURE_ASG > 0 THEN
--            O_ASG_MSG := O_ASG_MSG || ' Future record exist on ' ||
--                     TO_CHAR(LD_FUTURE_DATE, 'DD-MON-YYYY');
--          END IF;

lb_correction:= false;
lb_update := false;
lb_update_override := false;
lb_update_change_insert:= false;
begin
    -- determine the datetrack mode
    dt_api.find_dt_upd_modes
        (p_effective_date       => P_EFFECTIVE_START_DATE,
         p_base_table_name   => 'PER_ALL_ASSIGNMENTS_F', --'PER_ALL_PEOPLE_F'
         p_base_key_column   => 'ASSIGNMENT_ID',         --'PERSON_ID'
         p_base_key_value      => L_ASG_ID,        --lv_person_id
         --Out Variables
         p_correction               => lb_correction,
         p_update                    => lb_update,
         p_update_override      => lb_update_override,
         p_update_change_insert => lb_update_change_insert
        );
  
--    if lv_correction then
--      --Correction - Over writes the existing record, no history will be maintained
--      LC_MODE:='CORRECTION';
--    elsif lv_update then
--      --Inserts a new record effective as of the effective date parameter and keeps the history
--      LC_MODE:='UPDATE';
--    elsif lv_update_override then
--      --Future dated changes - do insert then overrides the future record
--      LC_MODE:='UPDATE_OVERRIDE';
--    elsif lv_update_change_insert then
--      --Future dated changes - do insert and keeps the future record
--      LC_MODE:='UPDATE_CHANGE_INSERT';
--    end if;     
  IF ( lb_update_override = TRUE OR lb_update_change_insert = TRUE )
   THEN
       -- UPDATE_OVERRIDE
       -- ---------------------------------
       LC_MODE := 'UPDATE_OVERRIDE';
   END IF;

 

  IF ( lb_correction = TRUE )
  THEN
      -- CORRECTION
      -- ----------------------
     LC_MODE := 'CORRECTION';
  END IF;

 

  IF ( lb_update = TRUE )
  THEN
      -- UPDATE
      -- --------------
      LC_MODE := 'UPDATE';
   END IF;
    --   
--    insert into xxtg_test values ('LC_MODE is '||LC_MODE);
exception
   when others then
      O_ASG_MSG := O_ASG_MSG ||'Error: '||sqlerrm;
end;             
          
          
--        IF P_EFFECTIVE_START_DATE = LD_FUTURE_DATE THEN
--          LC_MODE := 'CORRECTION';
--        ELSE
--          IF LN_FUTURE_ASG > 0 THEN --  Testing for Bug in DEV Instance
--            LC_MODE := 'UPDATE_CHANGE_INSERT';
--          ELSE
--            LC_MODE := 'UPDATE';
--          END IF;
--        END IF;      
      
--       
--      IF O_ASG_MSG IS NULL THEN  --- commented on 07-May-17 for testing future changes

--FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '1 the object version number of assignment before update is '||L_ASG_OVN);
      
        BEGIN
          HR_ASSIGNMENT_API.UPDATE_EMP_ASG_CRITERIA(P_EFFECTIVE_DATE               => P_EFFECTIVE_START_DATE,
                                                    P_DATETRACK_UPDATE_MODE        => LC_MODE,
                                                    P_ASSIGNMENT_ID                => L_ASG_ID,
                                                    P_JOB_ID                       => L_JOB_ID,
                                                    P_PAYROLL_ID                   => L_PAYROLL_ID,
                                                    P_LOCATION_ID                  => L_LOCATION_ID,
                                                    P_ORGANIZATION_ID              => L_CONTRACT_ID, --TESTING FOR ORG NOT GETTING UPDATED
                                                    P_GRADE_ID                     => L_GRADE_ID,
                                                    P_OBJECT_VERSION_NUMBER        => L_ASG_OVN,
                                                    P_SPECIAL_CEILING_STEP_ID      => L_SPECIAL_CEILING_STEP_ID,
                                                    P_PEOPLE_GROUP_ID              => L_PPL_GRP_ID,
                                                    P_SEGMENT1                     => L_ROSTER_ID,
                                                    P_GROUP_NAME                   => L_GROUP_NAME,
                                                    P_EFFECTIVE_START_DATE         => L_EFFECTIVE_START_DATE,
                                                    P_EFFECTIVE_END_DATE           => L_EFFECTIVE_END_DATE,
                                                    P_ORG_NOW_NO_MANAGER_WARNING   => L_ORG_NOW_NO_MANAGER_WARNING,
                                                    P_OTHER_MANAGER_WARNING        => L_OTHER_MANAGER_WARNING,
                                                    P_SPP_DELETE_WARNING           => L_SPP_DELETE_WARNING,
                                                    P_ENTRIES_CHANGED_WARNING      => L_ENTRIES_CHANGED_WARNING,
                                                    P_TAX_DISTRICT_CHANGED_WARNING => L_TAX_DISTRICT_CHANGED_WARNING);
            EXCEPTION
            WHEN OTHERS THEN
            O_ASG_MSG := SQLCODE ||' - '||SQLERRM  ||' - '||' ERROR IN UPDATE_EMP_ASG_CRITERIA';
         END ;             
--FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '1 the object version number of assignment after update is '||L_ASG_OVN);
        
          IF NVL(P_TRA, 0) > 0 THEN
            L_TRA_FLAG := 'N';
          ELSE
            L_TRA_FLAG := 'Y';
          END IF;
        
          IF NVL(P_HRA, 0) > 0 THEN
            L_HRA_FLAG := 'N';
          ELSE
            L_HRA_FLAG := 'Y';
          END IF;
--FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '2 the object version number of assignment before update is '||L_ASG_OVN);
        
          BEGIN
          HR_AE_ASSIGNMENT_API.UPDATE_AE_EMP_ASG(P_EFFECTIVE_DATE          => P_EFFECTIVE_START_DATE,
                                                 P_DATETRACK_UPDATE_MODE   => 'CORRECTION', -- always correction as previous API already created record
                                                 P_ASSIGNMENT_ID           => L_ASG_ID,
                                                 P_OBJECT_VERSION_NUMBER   => L_ASG_OVN,
                                                 P_ACCOMMODATION_PROVIDED  => L_HRA_FLAG,
                                                 P_TRANSPORTATION_PROVIDED => L_TRA_FLAG,
                                                 P_EMPLOYER                => L_BG_ID,
                                                 P_CONCATENATED_SEGMENTS   => L_CONCAT_SEG,
                                                 P_SOFT_CODING_KEYFLEX_ID  => L_SOFT_CODE,
                                                 P_COMMENT_ID              => L_COMMENT_ID,
                                                 P_EFFECTIVE_START_DATE    => L_EFFECTIVE_START_DATE,
                                                 P_EFFECTIVE_END_DATE      => L_EFFECTIVE_END_DATE,
                                                 P_NO_MANAGERS_WARNING     => L_NO_MANAGER_WARNING,
                                                 P_OTHER_MANAGER_WARNING   => L_OTHER_MANAGER_WARNING);
        
            EXCEPTION
            WHEN OTHERS THEN
            O_ASG_MSG := SQLCODE ||' - '||SQLERRM  ||' - '||' ERROR IN UPDATE_AE_EMP_ASG';
            END ;   --   COMMIT;
--FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '2 the object version number of assignment after update is '||L_ASG_OVN);
        
--        END IF;  --- for testing and allowing future changes
       IF  O_ASG_MSG IS NULL THEN 
          O_ASG_MSG :='SUCCESS';
       END IF;

    END LOOP;
  END PUSH_ASG_DETAILS;
 PROCEDURE INSERT_BATCH_LINES
  (
   ERRBUF        OUT VARCHAR2,
   RETCODE       OUT VARCHAR2,
  P_CONTRACT_ID     NUMBER,
--    P_OBJECT_VERSION_NUMBER      IN   OUT NUMBER,
    P_CONTRACT_ACCEPTED VARCHAR2         DEFAULT NULL,
    P_RESIGNED_DUE_TO_CONTRACT VARCHAR2  DEFAULT NULL,
    P_CONTRACT_SIGNED_DATE     DATE  DEFAULT SYSDATE,
--    P_UPDATED_BY             NUMBER,
--    P_UPDATE_DATE            DATE,
    P_CONTRACT_STATUS       VARCHAR2 DEFAULT 'A-ACTIVE', --:='A-ACTIVE';
    P_CONTRACT_REASON       VARCHAR2 DEFAULT 'PROCESSED', --:='PROPOSED';
    P_CONTRACT_DOC_STATUS   VARCHAR2 DEFAULT 'PROCESSED',  --:='CREATED';
    P_ASSIGNMENTS_CREATION_DATE DATE   DEFAULT SYSDATE
--    P_RISK_FLAG                 VARCHAR2
   )
   IS
   LD_CONTRACT_PRINT_DATE  VARCHAR2(20);
   LC_CONTRACT_PRINT_BY_STAFF VARCHAR2(240);
   LC_USER_NAME            VARCHAR2(240);
   LN_PERSON_ID            NUMBER := NULL;
   LC_BATCH_REFERENCE            VARCHAR2(240) :=NULL;
   LN_OBJECT_VERSION_NUMBER NUMBER := NULL;
   LC_STATUS               VARCHAR2(20) := NULL;
   LC_CONTRACT_SIGNED_DATE    VARCHAR2(20);
   LC_TYPE                    VARCHAR2(24);
   LC_CONTRACT_STATUS         VARCHAR2(20);
   LC_ASSIGNMENT_FLAG_STATUS  VARCHAR2(240);
   LC_SAL_FLAG_STATUS         VARCHAR2(240);
   
   CURSOR XXTG_USER_CUR (LN_USER_ID NUMBER) IS
   SELECT USER_NAME FROM FND_USER WHERE USER_ID = LN_USER_ID;
   
   CURSOR XXTG_CONT (LN_CONTRACT_ID NUMBER) IS
SELECT PCF.PERSON_ID,
  PCF.CONTRACT_ID,
  PCF.REFERENCE,
  PCF.TYPE,
  PCF.OBJECT_VERSION_NUMBER,
  PCF.STATUS ,
  PCF.EFFECTIVE_START_DATE,
  PCF.ATTRIBUTE1 ORGANIZATION,
  PCF.ATTRIBUTE2 JOB,
  PCF.ATTRIBUTE3 ROSTER,
  PCF.ATTRIBUTE4 BASIC,
  PCF.ATTRIBUTE5 HRA,
  PCF.ATTRIBUTE6 TRA,
  PCF.ATTRIBUTE7 EMIRATE,
  PCF.ATTRIBUTE8 CAMP,
  PCF.ATTRIBUTE9 OPERATION_MANAGER,
  PCF.ATTRIBUTE14 S_NO_BATCH_REFERENCE,
  PCF.ATTRIBUTE15 CONTRACT_PRINT_DATE ,
  PCF.ATTRIBUTE16 CONTRACT_PRINT_BY_STAFF ,
  PCF.ATTRIBUTE19  CONTRACT_AT_RISK,
  PCF.ATTRIBUTE20  CONTRACT_ACCEPTED,
  (SELECT PAPF.EMPLOYEE_NUMBER
  FROM PER_ALL_PEOPLE_F PAPF
  WHERE PCF.EFFECTIVE_START_DATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
  AND PAPF.PERSON_ID = PCF.PERSON_ID
  ) TG_ID
FROM PER_CONTRACTS_F PCF
WHERE PCF.CONTRACT_ID = LN_CONTRACT_ID ;

  CURSOR XXTG_ALLOWANCE_CUR (LC_BATCH_REFERENCE VARCHAR2, LC_TG_ID VARCHAR2)
   IS 
   SELECT HEADER_ID, LINE_ID, ELEMENT_LINE_ID, ELEMENT_NAME,VALIDATION_MESSAGE,  PAY_VALUE FROM XXTG_CA_LINES_ELE_ALL
    WHERE HEADER_ID = TO_NUMBER(LC_BATCH_REFERENCE)
    AND PAY_VALUE IS NOT NULL
    AND ELEMENT_NAME IS NOT NULL
    AND VALIDATION_MESSAGE IS NULL
    AND LINE_ID  IN (SELECT LINE_ID FROM XXTG_CA_LINES_ALL WHERE HEADER_ID = TO_NUMBER(LC_BATCH_REFERENCE) AND TG_ID = LC_TG_ID)
    FOR UPDATE OF VALIDATION_MESSAGE;
    
   

  LC_ASSIGN_MSG VARCHAR2(2400):= NULL;
  LC_SAL_MSG VARCHAR2(2400):= NULL;
  LC_HRA_MSG VARCHAR2(2400):= NULL;
  LC_TRA_MSG VARCHAR2(2400):= NULL;
  LN_CONTRACT_ID NUMBER := NULL;
  LC_TG_ID     VARCHAR2(240) :=NULL;
  LC_ORGANIZATION           VARCHAR2(240) := NULL;
  LC_JOB           VARCHAR2(240) := NULL;
  LC_ROSTER            VARCHAR2(240) := NULL;
  LN_BASIC              NUMBER := NULL;
  LN_HRA                NUMBER := NULL;
  LN_TRA                NUMBER := NULL;
  LC_EMIRATE           VARCHAR2(240) := NULL;
  LC_CAMP              VARCHAR2(240) := NULL;
  LC_ROOM               VARCHAR2(240) := NULL;
  LD_CONT_EFFECTIVE_START_DATE   DATE :=NULL;
--  LD_EFFECTIVE_START_DATE  DATE := NULL;
   BEGIN
   
   LN_PERSON_ID := NULL;
   LC_BATCH_REFERENCE :=NULL;
   LN_OBJECT_VERSION_NUMBER := NULL;
   LC_STATUS := NULL;
   LD_EFFECTIVE_START_DATE  := NULL;
   LD_EFFECTIVE_END_DATE    := NULL;
   LC_CONTRACT_STATUS       := 'A-ACTIVE';

--insert into xxtg_test values (' P_CONTRACT_DOC_STATUS '||P_CONTRACT_DOC_STATUS);
   
  FOR XXTG_CONT_REC IN XXTG_CONT (P_CONTRACT_ID)
    LOOP
      LN_PERSON_ID:= XXTG_CONT_REC.PERSON_ID;
      LC_BATCH_REFERENCE:= XXTG_CONT_REC.REFERENCE;
      LN_OBJECT_VERSION_NUMBER:= XXTG_CONT_REC.OBJECT_VERSION_NUMBER;
      LC_STATUS:= XXTG_CONT_REC.STATUS;
      LC_TYPE  := XXTG_CONT_REC.TYPE;  --UNlimited Contract by Default
      LC_TG_ID  := XXTG_CONT_REC.TG_ID;
      LC_ORGANIZATION :=  XXTG_CONT_REC.ORGANIZATION;
      LC_JOB  :=  XXTG_CONT_REC.JOB;
      LC_ROSTER :=  XXTG_CONT_REC.ROSTER;
      LD_CONT_EFFECTIVE_START_DATE := XXTG_CONT_REC.EFFECTIVE_START_DATE;
--      LD_EFFECTIVE_START_DATE := XXTG_CONT_REC.EFFECTIVE_START_DATE;
    
--      LN_CONTRACT_ID :=XXTG_CONT_REC.CONTRACT_ID;
      LD_CONTRACT_PRINT_DATE :=XXTG_CONT_REC.CONTRACT_PRINT_DATE; --IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
      LC_CONTRACT_PRINT_BY_STAFF :=XXTG_CONT_REC.CONTRACT_PRINT_BY_STAFF;
      LN_BASIC :=  XXTG_CONT_REC.BASIC;
      LN_HRA :=  XXTG_CONT_REC.HRA;
      LN_TRA :=  XXTG_CONT_REC.TRA;
    END LOOP;
   
--DBMS_OUTPUT.PUT_LINE('CONTRACT_ID IS '||LN_CONTRACT_ID);
--DBMS_OUTPUT.PUT_LINE('CONTRACT_ID IS '||P_CONTRACT_ID);
  IF P_CONTRACT_ACCEPTED IS NULL THEN
   LC_CONTRACT_STATUS := LC_STATUS;
   ELSIF P_CONTRACT_ACCEPTED ='Y' THEN
    LC_CONTRACT_STATUS    :='A-ACTIVE';
  ELSIF P_CONTRACT_ACCEPTED ='N' THEN
    LC_CONTRACT_STATUS    :='A-REJECTED' ; --'A-ACTIVE', 
  END IF;

/*------------------------------------------------------------------
-------------------------Start of P_CONTRACT_DOC_STATUS IF Clause---
-------------------------------------------------------------------*/
  IF  P_CONTRACT_DOC_STATUS ='PROCESSED' AND P_CONTRACT_ACCEPTED ='N' THEN
    LC_CONTRACT_SIGNED_DATE := TO_CHAR(SYSDATE,'DD-MON-RRRR HH24:MI:SS');
  ELSIF  P_CONTRACT_DOC_STATUS ='PROCESSED' AND P_CONTRACT_ACCEPTED ='Y' THEN
    LC_CONTRACT_SIGNED_DATE := TO_CHAR(SYSDATE,'DD-MON-RRRR HH24:MI:SS');

BEGIN
            -------------------------------------------------------
            --// Assignment Details Update
            ---------------------------------------------------------
            BEGIN
            XXTG_CA_DEPLOYMENT_PKG.PUSH_ASG_DETAILS(
            P_ORGANIZATION   =>LC_ORGANIZATION  ,--'TGSS - Aviation Security TAS  - EKFC' ,
              P_JOB           =>LC_JOB , --'Accommodation Boss' ,
              P_ROSTER        =>LC_ROSTER , --'TGSS - Aviation Security TAS  - EKFC - EKFC' ,
              P_BASIC         =>LN_BASIC,
              P_HRA           =>LN_HRA ,
              P_TRA           =>LN_TRA,
              P_EMIRATE       =>LC_EMIRATE ,
              P_CAMP          =>LC_CAMP ,
              P_ROOM          =>LC_ROOM ,
              P_CONTRACT_BATCH =>LC_BATCH_REFERENCE ,
              P_EFFECTIVE_START_DATE  => LD_CONT_EFFECTIVE_START_DATE,
              P_TG_ID                 => LC_TG_ID,
              O_ASG_MSG       =>LC_ASSIGN_MSG );
              EXCEPTION
            WHEN OTHERS THEN
              LC_ASSIGN_MSG := LC_TG_ID || ' : Error : ' ||' Assignment Details '||
                            SUBSTR(SQLERRM, 1, 500);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LC_ASSIGN_MSG);
            --    DBMS_OUTPUT.PUT_LINE('01 : '|| LC_ASSIGN_MSG);
            END;
            -------------------------------------------------------
            --// Basic Salary
            ---------------------------------------------------------
--      IF      LC_ASSIGN_MSG ='SUCCESS' THEN             
            
            BEGIN
            XXTG_CA_DEPLOYMENT_PKG.PUSH_SAL_DETAILS(
              P_BASIC         =>LN_BASIC,
              P_HRA           =>LN_HRA ,
              P_TRA           =>LN_TRA,
              P_EMIRATE       =>LC_EMIRATE ,
              P_CAMP          =>LC_CAMP ,
              P_ROOM          =>LC_ROOM ,
              P_CONTRACT_BATCH =>LC_BATCH_REFERENCE ,
              P_EFFECTIVE_START_DATE  => LD_CONT_EFFECTIVE_START_DATE,
              P_TG_ID          => LC_TG_ID,
              O_SAL_MSG        =>LC_SAL_MSG );
              EXCEPTION
            WHEN OTHERS THEN
              LC_SAL_MSG := LC_TG_ID || ' : Error : ' ||' Basic Salary '||
                            SUBSTR(SQLERRM, 1, 500);
            --    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LC_SAL_MSG);
            END;
      
 
            -------------------------------------------------------
            --// All Allowance Insert/Update
            ---------------------------------------------------------
        FOR XXTG_ALL_REC IN XXTG_ALLOWANCE_CUR (LC_BATCH_REFERENCE, LC_TG_ID)
          LOOP
          
--           LC_TG_ID VARCHAR2(40) := NULL;
--      LD_EFF_DATE DATE := NULL;
--      LC_SAL_MSG  VARCHAR2(240);
--    BEGIN
--    FOR XXTG_REC IN XXTG_ELE_CUR(P_CONTRACT_BATCH)
--      LOOP
--      LC_TG_ID := NULL;
--      LD_EFF_DATE := NULL;
--    FOR  XXTG_LINE_REC IN XXTG_LINE_CUR (XXTG_REC.LINE_ID)
--      LOOP
--          LC_TG_ID := XXTG_LINE_REC.TG_ID;
--          LD_EFF_DATE := XXTG_LINE_REC.EFFECTIVE_DATE;
--      END LOOP;
      LC_SAL_MSG := NULL;
        XXTG_CA_DEPLOYMENT_PKG.PUSH_ALLOWANCE_DETAILS(
    P_ALLOWANCE   =>XXTG_ALL_REC.ELEMENT_NAME ,
    P_ALLOWANCE_AMOUNT =>XXTG_ALL_REC.PAY_VALUE ,    
    P_CONTRACT_BATCH  => LC_BATCH_REFERENCE, --TO_CHAR(XXTG_REC.HEADER_ID),
    P_EFFECTIVE_START_DATE  => LD_CONT_EFFECTIVE_START_DATE, --LD_EFF_DATE,
    P_TG_ID=> LC_TG_ID,
    O_SAL_MSG =>LC_SAL_MSG);
    UPDATE XXTG_CA_LINES_ELE_ALL
    SET VALIDATION_MESSAGE = NVL(LC_SAL_MSG,'I')
    WHERE CURRENT OF XXTG_ALLOWANCE_CUR;
      END LOOP;       
          
--     END IF;     
          
            ------------------------------------------------------------------
            -------------------------Start of P_CONTRACT_DOC_STATUS ELSIF Clause-
            -------------------------------------------------------------------
END;

ELSIF P_CONTRACT_DOC_STATUS ='PRINTED' THEN
  
  FOR XXTG_REC IN XXTG_USER_CUR(FND_PROFILE.VALUE('USER_ID')) --P_UPDATED_BY)
    LOOP
       LC_USER_NAME := XXTG_REC.USER_NAME;
    END LOOP;

    LD_CONTRACT_PRINT_DATE  := TO_CHAR(SYSDATE,'DD-MON-RRRR HH24:MI:SS'); 
    LC_CONTRACT_PRINT_BY_STAFF := LC_USER_NAME;
  

END IF;
/*------------------------------------------------------------------
-------------------------End of P_CONTRACT_DOC_STATUS IF Clause---
-------------------------------------------------------------------*/
  LD_EFFECTIVE_START_DATE:= NULL;


--IF LC_ASSIGN_MSG='SUCCESS' OR  LC_SAL_MSG='SUCCESS' THEN
              begin

              
              hr_ae_contract_api.update_ae_contract
              (p_validate                       => FALSE
              ,p_contract_id                    => P_CONTRACT_ID
              ,p_effective_start_date           => LD_EFFECTIVE_START_DATE --OUT NOCOPY DATE
              ,p_effective_end_date             => LD_EFFECTIVE_END_DATE --OUT NOCOPY DATE
              ,p_object_version_number          => LN_OBJECT_VERSION_NUMBER
              ,p_person_id                      => LN_PERSON_ID --IN  NUMBER
              ,p_reference                      => LC_BATCH_REFERENCE --IN  VARCHAR2
              ,p_type                           => LC_TYPE    --IN  VARCHAR2
              ,p_status                         => LC_CONTRACT_STATUS --P_CONTRACT_STATUS
              ,p_status_reason                  => P_CONTRACT_REASON 
              ,p_doc_status                     => P_CONTRACT_DOC_STATUS
              ,p_doc_status_change_date         => SYSDATE
              ,p_attribute10                    =>  TO_CHAR(P_ASSIGNMENTS_CREATION_DATE,'DD-MON-RRRR') --IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
              ,p_attribute11                    =>  SUBSTR(NVL(LC_HRA_MSG,''),0,100) --IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
              ,p_attribute12                    =>  SUBSTR(NVL(LC_ASSIGN_MSG,''),0,100) -- IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2   --- Assignment Status Flag
              ,p_attribute13                    =>  SUBSTR((NVL(LC_SAL_MSG,'') ),0,100) --IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2   --- Salary Status Flag
              ,p_attribute14                    =>  SUBSTR( NVL(LC_TRA_MSG,''),0,100) --IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
              ,p_attribute15                    => LD_CONTRACT_PRINT_DATE --IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
              ,p_attribute16                    => LC_CONTRACT_PRINT_BY_STAFF --IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
              ,p_attribute17                    => LC_CONTRACT_SIGNED_DATE --TO_CHAR(P_CONTRACT_SIGNED_DATE,'DD-MON-RRRR') --IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
              ,p_attribute18                    => P_RESIGNED_DUE_TO_CONTRACT  --IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
            --  ,p_attribute19                    IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
              ,p_attribute20                    => P_CONTRACT_ACCEPTED --IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
              ,p_effective_date                 =>LD_CONT_EFFECTIVE_START_DATE
              ,p_datetrack_mode                 =>'CORRECTION' --'UPDATE' -- comment, we have confirmed that system will override the existing future contracts
              );

--  DBMS_OUTPUT.PUT_LINE('AFTER API CALL LD_EFFECTIVE_START_DATE :'||LD_EFFECTIVE_START_DATE);
--  DBMS_OUTPUT.PUT_LINE('AFTER API CALL LD_EFFECTIVE_END_DATE :'||LD_EFFECTIVE_END_DATE);
              EXCEPTION
            WHEN OTHERS THEN
              LC_TRA_MSG := LC_TG_ID || ' : Error : ' ||' Contract Update with Status '||P_CONTRACT_DOC_STATUS ||' '||
                            SUBSTR(SQLERRM, 1, 500);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, LC_TRA_MSG);
                DBMS_OUTPUT.PUT_LINE('01 : '|| LC_TRA_MSG);
            END;
--ELSE
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'P_CONTRACT_ID :'||P_CONTRACT_ID);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'LD_EFFECTIVE_START_DATE :'||LD_EFFECTIVE_START_DATE);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'LD_EFFECTIVE_END_DATE :'||LD_EFFECTIVE_END_DATE);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'LN_OBJECT_VERSION_NUMBER :'||LN_OBJECT_VERSION_NUMBER);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'LN_PERSON_ID :'||LN_PERSON_ID);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'LC_REFERENCE :'||LC_BATCH_REFERENCE);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'LC_TYPE :'||LC_TYPE);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'LC_CONTRACT_STATUS :'||LC_CONTRACT_STATUS);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'P_CONTRACT_REASON :'||P_CONTRACT_REASON);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'P_CONTRACT_DOC_STATUS :'||P_CONTRACT_DOC_STATUS);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'P_ASSIGNMENTS_CREATION_DATE :'||TO_CHAR(P_ASSIGNMENTS_CREATION_DATE,'DD-MON-RRRR'));
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'LC_ASSIGN_MSG :'||SUBSTR(NVL(LC_ASSIGN_MSG,''),0,240));
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'LC_SAL_MSG :'||SUBSTR((NVL(LC_SAL_MSG,'')||'sal'||NVL(LC_HRA_MSG,'')||'hra '|| NVL(LC_TRA_MSG,'')),0,240));
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'LD_CONTRACT_PRINT_DATE :'||LD_CONTRACT_PRINT_DATE);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'LC_CONTRACT_PRINT_BY_STAFF :'||LC_CONTRACT_PRINT_BY_STAFF);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'P_CONTRACT_DOC_STATUS :'||P_CONTRACT_DOC_STATUS);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'P_RESIGNED_DUE_TO_CONTRACT :'||P_RESIGNED_DUE_TO_CONTRACT);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'P_CONTRACT_ACCEPTED :'||P_CONTRACT_ACCEPTED);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'LC_CONTRACT_SIGNED_DATE :'||LC_CONTRACT_SIGNED_DATE);


--END IF;
 COMMIT;
  END INSERT_BATCH_LINES;
  
  
  FUNCTION CONTRACT_AT_RISK (P_PERSON_ID NUMBER
                             ,P_BASIC NUMBER
                             , P_HRA NUMBER
                             , P_TRA NUMBER
                             , P_ORGANIZATION    VARCHAR2
                             , P_JOB             VARCHAR2
                             , P_ROSTER          VARCHAR2
                             , P_EFFECTIVE_DATE DATE) RETURN VARCHAR2
  IS

  CURSOR XXTG_OLD_CS_ALLOWANCE (LN_BUSINESS_GROUP_ID NUMBER ,LN_ASSIGNMENT_ID NUMBER ,LD_EFFECTIVE_DATE DATE)
  IS 
SELECT M.ALLOWANCE_AMOUNT
  FROM PER_ALL_ASSIGNMENTS_F A, TG_MOS_CS_ALLOWANCE_MASTER_V M, PER_PAY_PROPOSALS SAL
 WHERE   M.BGID = A.BUSINESS_GROUP_ID
       AND A.BUSINESS_GROUP_ID = LN_BUSINESS_GROUP_ID
       AND A.ASSIGNMENT_ID = LN_ASSIGNMENT_ID
       AND A.JOB_ID = M.JOB_ID
       AND A.ORGANIZATION_ID = M.ORGANIZATION_ID
       AND SAL.ASSIGNMENT_ID = A.ASSIGNMENT_ID
       AND SAL.BUSINESS_GROUP_ID = A.BUSINESS_GROUP_ID
       AND SAL.PROPOSED_SALARY_N = M.BASIC_SALARY
       AND P_EFFECTIVE_DATE BETWEEN SAL.CHANGE_DATE AND SAL.DATE_TO
       AND NVL( M.ROSTER_ID, 1 ) = NVL( ( SELECT SEGMENT1
                                            FROM PAY_PEOPLE_GROUPS
                                           WHERE PEOPLE_GROUP_ID = A.PEOPLE_GROUP_ID ),
                                        1 )
      AND  LD_EFFECTIVE_DATE BETWEEN A.EFFECTIVE_START_DATE AND  A.EFFECTIVE_END_DATE
      AND (LD_EFFECTIVE_DATE >= M.EFFECTIVE_START_DATE AND  M.EFFECTIVE_END_DATE IS NULL);
--    AND PEEF.assignment_id = 14717;
    LC_CONTRACT_AT_RISK  VARCHAR2(1) :='N';
    LC_SAL_INC_AT_RISK  VARCHAR2(1) :='N';
    LC_SAL_DEC_AT_RISK  VARCHAR2(1) :='N';
    LC_JOB_CHNG_AT_RISK  VARCHAR2(1) :='N';
    LN_PREV_BAS_SAL      NUMBER  :=0;
    LN_PREV_HRA          NUMBER  :=0;
    LN_PREV_TRA          NUMBER  :=0;
    LN_NEW_CS_ALL        NUMBER  :=0;
    LN_OLD_CS_ALL        NUMBER  :=0;
    LC_OLD_JOB           VARCHAR2(240);
    LN_ASSIGNMENT_ID     NUMBER;
    LN_BUSINESS_GROUP_ID NUMBER;
    XXTG_COR_ALLOWANCE_REC  XXTG_COR_ALLOWANCE%ROWTYPE;
    ln_user_id number;
    ln_resp_id number;
    ln_resp_appl_id number;
  BEGIN
      LC_CONTRACT_AT_RISK   :='N';
    LC_SAL_INC_AT_RISK   :='N';
    LC_SAL_DEC_AT_RISK   :='N';
    LC_JOB_CHNG_AT_RISK   :='N';
       ln_user_id := null;
    ln_resp_id := null;
    ln_resp_appl_id := null;
--   select FND_PROFILE.VALUE('USER_ID') into ln_user_id from dual;
--    FOR XXTG_REC IN XXTG_RESP_ID_APPROVER_CUR (ln_user_id)
--      LOOP
--        apps.fnd_global.apps_initialize (user_id=>ln_user_id,resp_id=>XXTG_REC.responsibility_id,resp_appl_id=>XXTG_REC.application_id);
--      END LOOP;

    FOR XXTG_REC IN XXTG_PREV_COMP_CHECK ( P_PERSON_ID, P_EFFECTIVE_DATE, 'Basic Salary', 'Basic Salary')
      LOOP
         LN_PREV_BAS_SAL := XXTG_REC.VALUE;
      END LOOP;
--DBMS_OUTPUT.PUT_LINE('USER_ID '||ln_USER_id||'RESP_ID '||FND_PROFILE.VALUE('RESP_ID')||'RESP_APPL_ID '||FND_PROFILE.VALUE('RESP_APPL_ID')||' Beginning of program '||FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE')||' DECREASING basic is '||NVL(P_BASIC,0) ||' and Previous Basic is '||LN_PREV_BAS_SAL);

    FOR XXTG_REC IN XXTG_ASSIGNMENT_CUR ( P_PERSON_ID, P_EFFECTIVE_DATE)
      LOOP
         LC_OLD_JOB := XXTG_REC.JOB_NAME;
         LN_ASSIGNMENT_ID  := XXTG_REC.ASSIGNMENT_ID;
         LN_BUSINESS_GROUP_ID := XXTG_REC.BUSINESS_GROUP_ID ;
      END LOOP;

    FOR XXTG_REC IN XXTG_COR_ALLOWANCE (P_EFFECTIVE_DATE, LN_BUSINESS_GROUP_ID, P_JOB , P_ORGANIZATION ,P_BASIC, P_ROSTER)
      LOOP
         LN_NEW_CS_ALL := XXTG_REC.ALLOWANCE_AMOUNT;
      END LOOP;
      
      OPEN XXTG_COR_ALLOWANCE (P_EFFECTIVE_DATE, LN_BUSINESS_GROUP_ID, P_JOB , P_ORGANIZATION ,P_BASIC, P_ROSTER);
         FETCH XXTG_COR_ALLOWANCE INTO XXTG_COR_ALLOWANCE_REC;
           IF XXTG_COR_ALLOWANCE%NOTFOUND THEN
             LN_NEW_CS_ALL := 0;
           END IF;
       CLOSE XXTG_COR_ALLOWANCE;
       
       FOR XXTG_REC IN XXTG_OLD_CS_ALLOWANCE (LN_BUSINESS_GROUP_ID,LN_ASSIGNMENT_ID,P_EFFECTIVE_DATE)
         LOOP
           LN_OLD_CS_ALL:= XXTG_REC.ALLOWANCE_AMOUNT;
         END LOOP;
       

--     LN_OLD_CS_ALL := tg_payroll_general_pkg.get_cs_allowance(LN_BUSINESS_GROUP_ID,LN_ASSIGNMENT_ID,FND_CONC_DATE.STRING_TO_DATE(P_EFFECTIVE_DATE));
    IF FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_BAS_SAL_INCREASE') ='Y' THEN 
    
      IF  NVL(P_BASIC,0)> LN_PREV_BAS_SAL  THEN
      
        LC_SAL_INC_AT_RISK :='Y';
--      insert into xxtg_test values ('USER_ID '||ln_USER_id||'RESP_ID '||FND_PROFILE.VALUE('RESP_ID')||'RESP_APPL_ID '||FND_PROFILE.VALUE('RESP_APPL_ID')||'XXTG_ENABLE_RISK_IF_BAS_SAL_INCREASE '||FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_BAS_SAL_INCREASE')||' INCREASING basic is '||NVL(P_BASIC,0) ||' and Previous Basic is '||LN_PREV_BAS_SAL);
--        DBMS_OUTPUT.PUT_LINE('USER_ID '||ln_USER_id||'RESP_ID '||FND_PROFILE.VALUE('RESP_ID')||'RESP_APPL_ID '||FND_PROFILE.VALUE('RESP_APPL_ID')||'XXTG_ENABLE_RISK_IF_BAS_SAL_INCREASE '||FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_BAS_SAL_INCREASE')||' INCREASING basic is '||NVL(P_BASIC,0) ||' and Previous Basic is '||LN_PREV_BAS_SAL);

      END IF;
      
    ELSE  LC_SAL_INC_AT_RISK :='N';
    
    END IF; 
--     insert into xxtg_test values ('Before IF Clause USER_ID '||ln_USER_id||'RESP_ID '||FND_PROFILE.VALUE('RESP_ID')||'RESP_APPL_ID '||FND_PROFILE.VALUE('RESP_APPL_ID')||' XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE '||FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE')||' DECREASING basic is '||NVL(P_BASIC,0) ||' and Previous Basic is '||LN_PREV_BAS_SAL);
    
    IF FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE')='Y' THEN 
--     insert into xxtg_test values ('Before IF Clause USER_ID '||ln_USER_id||'RESP_ID '||FND_PROFILE.VALUE('RESP_ID')||'RESP_APPL_ID '||FND_PROFILE.VALUE('RESP_APPL_ID')||' XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE '||FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE')||' DECREASING basic is '||NVL(P_BASIC,0) ||' and Previous Basic is '||LN_PREV_BAS_SAL);
    
      IF  NVL(P_BASIC,0)< LN_PREV_BAS_SAL  THEN
      
        LC_SAL_DEC_AT_RISK :='Y';
--      insert into xxtg_test values ('USER_ID '||ln_USER_id||'RESP_ID '||FND_PROFILE.VALUE('RESP_ID')||'RESP_APPL_ID '||FND_PROFILE.VALUE('RESP_APPL_ID')||' XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE '||FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE')||' DECREASING basic is '||NVL(P_BASIC,0) ||' and Previous Basic is '||LN_PREV_BAS_SAL);
--        DBMS_OUTPUT.PUT_LINE('USER_ID '||ln_USER_id||'RESP_ID '||FND_PROFILE.VALUE('RESP_ID')||'RESP_APPL_ID '||FND_PROFILE.VALUE('RESP_APPL_ID')||' XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE '||FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE')||' DECREASING basic is '||NVL(P_BASIC,0) ||' and Previous Basic is '||LN_PREV_BAS_SAL);
      END IF;
      
    ELSE  LC_SAL_DEC_AT_RISK :='N';
    
    END IF;   
      
    IF FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_JOB_CHANGE')='Y' THEN 
    
      IF  LC_OLD_JOB  <> P_JOB  THEN
      
        LC_JOB_CHNG_AT_RISK :='Y';
--      insert into xxtg_test values ('USER_ID '||ln_USER_id||'RESP_ID '||FND_PROFILE.VALUE('RESP_ID')||'RESP_APPL_ID '||FND_PROFILE.VALUE('RESP_APPL_ID')||'XXTG_ENABLE_RISK_IF_JOB_CHANGE '||FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_JOB_CHANGE') ||' LC_OLD_JOB is '||LC_OLD_JOB ||' and new JOB is '||P_JOB);      
--        DBMS_OUTPUT.PUT_LINE('USER_ID '||ln_USER_id||'RESP_ID '||FND_PROFILE.VALUE('RESP_ID')||'RESP_APPL_ID '||FND_PROFILE.VALUE('RESP_APPL_ID')||'XXTG_ENABLE_RISK_IF_JOB_CHANGE '||FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_JOB_CHANGE') ||' LC_OLD_JOB is '||LC_OLD_JOB ||' and new JOB is '||P_JOB);      
      END IF;
      
    ELSE  LC_JOB_CHNG_AT_RISK :='N';
    
    END IF;       
      
      
      IF LC_JOB_CHNG_AT_RISK='Y' OR  LC_SAL_DEC_AT_RISK ='Y' OR LC_SAL_INC_AT_RISK ='Y' THEN
        LC_CONTRACT_AT_RISK:='Y';
      END IF;
--    IF 
--          LC_OLD_JOB  <> P_JOB    OR
--          NVL(LN_NEW_CS_ALL,0) <> NVL(LN_OLD_CS_ALL,0)
--          
--      THEN  LC_CONTRACT_AT_RISK :='Y';
----      INSERT INTO TEST VALUES (LN_PREV_BAS_SAL ||P_BASIC ||LC_OLD_JOB||P_JOB||LN_NEW_CS_ALL||LN_OLD_CS_ALL);
----      COMMIT;
--      ELSE  LC_CONTRACT_AT_RISK :='N';
--      END IF;
      RETURN (LC_CONTRACT_AT_RISK);
     
  END CONTRACT_AT_RISK;
  PROCEDURE XXTG_CONTRACT
  ( P_ORGANIZATION    VARCHAR2,
    P_JOB             VARCHAR2,
    P_ROSTER          VARCHAR2,
    P_BASIC           NUMBER,
    P_HRA             NUMBER,
    P_TRA             NUMBER,
--    P_OTHER             NUMBER,
    P_RISK         VARCHAR2,
    P_CAMP            VARCHAR2,
    P_ROOM            VARCHAR2,
    P_CONTRACT_BATCH  VARCHAR2,
    P_EFFECTIVE_START_DATE  DATE,
    P_OPERATIONS_MGR_PERSON  VARCHAR2,
--    P_PERSON_ID             NUMBER,
    P_TG_ID                VARCHAR2,
    P_EMP_CONTRACT_ID        OUT   NUMBER)
    IS


cursor approver_user_id_cur (ln_header_id number)
is select user_id from fnd_user where employee_id in (select person_id from per_all_people_f 
where full_name = (select selected_approver_name from xxtg_ca_headers_all where header_id = ln_header_id)
and  full_name is not null and rownum =1);
    
CURSOR TG_CUR (LC_EMP_NO VARCHAR2, LD_EFFECTIVE_DATE DATE)
IS 
SELECT PAPF.PERSON_ID , PAPF.BUSINESS_GROUP_ID
FROM APPS.PER_ALL_PEOPLE_F PAPF
WHERE PAPF.EMPLOYEE_NUMBER = LC_EMP_NO
AND TRUNC(LD_EFFECTIVE_DATE) BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE;
LN_BUSINESS_GROUP_ID NUMBER;
LC_SQL_ERRM   VARCHAR2(2000);
LC_SQL_CODE   VARCHAR2(240);
LN_APPROVER_USER_ID  NUMBER;
BEGIN
   FOR TG_REC IN TG_CUR (P_TG_ID,P_EFFECTIVE_START_DATE)
      LOOP
        LN_PERSON_ID:=TG_REC.PERSON_ID;
        LN_BUSINESS_GROUP_ID :=TG_REC.BUSINESS_GROUP_ID;
      END LOOP;
--    DBMS_OUTPUT.PUT_LINE('LN_PERSON_ID :'||LN_PERSON_ID);

     LC_CONTRACT_TYPE := 'UNLIMITED_CONTRACT';
     LC_CONTRACT_STATUS :='A-ACTIVE';
     LC_CONTRACT_REASON :='PROPOSED';
     LC_CONTRACT_DOC_STATUS:='CREATED';
--     LC_CONTRACT_AT_RISK :='N';
      LN_APPROVER_USER_ID := NULL;
  for approver_rec in approver_user_id_cur (TO_NUMBER(P_CONTRACT_BATCH))
   loop
      LN_APPROVER_USER_ID := approver_rec.user_id;
   END LOOP;
      FOR XXTG_REC IN XXTG_RESP_ID_APPROVER_CUR (LN_APPROVER_USER_ID)
      LOOP
        apps.fnd_global.apps_initialize (user_id=>LN_APPROVER_USER_ID,resp_id=>XXTG_REC.responsibility_id,resp_appl_id=>XXTG_REC.application_id);
      END LOOP;
   dbms_session.set_nls ('nls_date_format','''DD-MON-RR''');
     LC_CONTRACT_AT_RISK := XXTG_CA_DEPLOYMENT_PKG.CONTRACT_AT_RISK (LN_PERSON_ID,P_BASIC , P_HRA , P_TRA , P_ORGANIZATION,   P_JOB ,    P_ROSTER  , P_EFFECTIVE_START_DATE);
  --To set environment context.
  --Hardcoding User TG.HCM.SCHED  and Responsiblity TG_SCHED_PROG  and Application  Human Resources
  -- Testing by commenting code to initialize this to execute from TG_SCHED_PROG user.

  apps.fnd_global.apps_initialize (user_id=>1677,resp_id=>50866,resp_appl_id=>800);
   dbms_session.set_nls ('nls_date_format','''DD-MON-RR''');
  BEGIN
     APPS.hr_ae_contract_api.create_ae_contract
 (p_validate                        =>FALSE        -- IN BOOLEAN DEFAULT FALSE
  ,p_contract_id                    =>LN_CONTRACT_ID --OUT NOCOPY NUMBER
  ,p_effective_start_date           => LD_EFFECTIVE_START_DATE --OUT NOCOPY DATE
  ,p_effective_end_date             => LD_EFFECTIVE_END_DATE --OUT NOCOPY DATE
  ,p_object_version_number          => LN_OBJECT_VERSION_NUMBER --OUT NOCOPY NUMBER
  ,p_person_id                      => LN_PERSON_ID --P_PERSON_ID --IN  NUMBER
  ,p_reference                      => P_CONTRACT_BATCH--IN  VARCHAR2
  ,p_type                           => LC_CONTRACT_TYPE--IN  VARCHAR2
  ,p_status                         => LC_CONTRACT_STATUS --IN  VARCHAR2
  ,p_status_reason                  => LC_CONTRACT_REASON--IN  VARCHAR2  DEFAULT NULL
  ,p_doc_status                     => LC_CONTRACT_DOC_STATUS--IN  VARCHAR2  DEFAULT NULL
  ,p_doc_status_change_date         => P_EFFECTIVE_START_DATE --IN  DATE      DEFAULT NULL
  ,p_description                    => P_CONTRACT_BATCH--IN  VARCHAR2  DEFAULT NULL
--  ,p_duration                       => --IN  NUMBER    DEFAULT NULL
--  ,p_duration_units                 => --IN  VARCHAR2  DEFAULT NULL
--  ,p_contractual_job_title          => --IN  VARCHAR2  DEFAULT NULL
--  ,p_parties                        => --IN  VARCHAR2  DEFAULT NULL
--  ,p_start_reason                   => --VARCHAR2  DEFAULT NULL
--  ,p_end_reason                     => --VARCHAR2  DEFAULT NULL
--  ,p_number_of_extensions           => --NUMBER    DEFAULT NULL
--  ,p_extension_reason               => --VARCHAR2  DEFAULT NULL
--  ,p_extension_period               => --NUMBER    DEFAULT NULL
--  ,p_extension_period_units         => --VARCHAR2  DEFAULT NULL
--  ,p_employment_status              => --VARCHAR2  DEFAULT NULL
--  ,p_expiry_date                    => --VARCHAR2  DEFAULT NULL
  ,p_attribute_category             => LN_BUSINESS_GROUP_ID--FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID') --VARCHAR2  DEFAULT NULL
  ,p_attribute1                     => P_ORGANIZATION --VARCHAR2  DEFAULT NULL
  ,p_attribute2                     => P_JOB          --VARCHAR2  DEFAULT NULL
  ,p_attribute3                     => P_ROSTER --VARCHAR2  DEFAULT NULL
  ,p_attribute4                     => P_BASIC--VARCHAR2  DEFAULT NULL
--  ,p_attribute5                     => P_HRA--VARCHAR2  DEFAULT NULL
--  ,p_attribute6                     => P_TRA--VARCHAR2  DEFAULT NULL
  ,p_attribute7                     => P_CAMP --VARCHAR2  DEFAULT NULL
  ,p_attribute8                     => P_ROOM --VARCHAR2  DEFAULT NULL
  ,p_attribute9                     => P_OPERATIONS_MGR_PERSON --P_ROOM--VARCHAR2  DEFAULT NULL
  ,p_attribute19                    => P_RISK  --LC_CONTRACT_AT_RISK--IN  VARCHAR2  DEFAULT NULL
  ,p_effective_date                 => P_EFFECTIVE_START_DATE
 );
     P_EMP_CONTRACT_ID := LN_CONTRACT_ID;

     EXCEPTION  WHEN OTHERS THEN
     P_EMP_CONTRACT_ID := 0;
     LC_SQL_ERRM := SQLERRM;
     LC_SQL_CODE := SQLCODE;
     INSERT INTO XXTG_CONTRACT_AUDIT_LOG
    (
    CONTRACT_BATCH  ,
    TG_ID                ,
    EFFECTIVE_START_DATE  ,
    ORGANIZATION    ,
    JOB             ,
    ROSTER          ,
    BASIC           ,
    HRA             ,
    TRA             ,
    OPERATIONS_MGR_PERSON  ,
    PERSON_ID             ,
    OPERATIONS_MGR_PERSON_EMAIL  ,
    BUSINESS_GROUP_ID        ,
--    EMP_CONTRACT_ID        ,
--    OBJECT_VERSION_NUMBER ,
    SQLCODE               ,
    SQLERRM               
    )
    VALUES 
    (
    P_CONTRACT_BATCH,
    P_TG_ID,
    P_EFFECTIVE_START_DATE,
     P_ORGANIZATION    ,
    P_JOB             ,
    P_ROSTER          ,
    P_BASIC           ,
    P_HRA             ,
    P_TRA             ,
    P_OPERATIONS_MGR_PERSON  ,
    LN_PERSON_ID             ,
    P_OPERATIONS_MGR_PERSON  ,
    LN_BUSINESS_GROUP_ID        ,
--    LN_CONTRACT_ID        ,
--    LN_OBJECT_VERSION_NUMBER ,
    LC_SQL_CODE               ,
    LC_SQL_ERRM               
    
    );
    END;
     INSERT INTO XXTG_CONTRACT_AUDIT_LOG
    (
    CONTRACT_BATCH  ,
    TG_ID                ,
    EFFECTIVE_START_DATE  ,
    ORGANIZATION    ,
    JOB             ,
    ROSTER          ,
    BASIC           ,
    HRA             ,
    TRA             ,
    OPERATIONS_MGR_PERSON  ,
    PERSON_ID             ,
    OPERATIONS_MGR_PERSON_EMAIL  ,
    BUSINESS_GROUP_ID        ,
    EMP_CONTRACT_ID        ,
    OBJECT_VERSION_NUMBER 
--    SQLCODE               ,
--    SQLERRM               
    )
    VALUES 
    (
    P_CONTRACT_BATCH,
    P_TG_ID,
    P_EFFECTIVE_START_DATE,
     P_ORGANIZATION    ,
    P_JOB             ,
    P_ROSTER          ,
    P_BASIC           ,
    P_HRA             ,
    P_TRA             ,
    P_OPERATIONS_MGR_PERSON  ,
    LN_PERSON_ID             ,
    P_OPERATIONS_MGR_PERSON  ,
    LN_BUSINESS_GROUP_ID        ,
    LN_CONTRACT_ID        ,
    LN_OBJECT_VERSION_NUMBER 
--    LC_SQL_CODE               ,
--    LC_SQL_ERRM               
    
    );
--       COMMIT;
  END XXTG_CONTRACT;
  PROCEDURE UPDATE_CONTRACT
  ( P_CONTRACT_ID     VARCHAR,
--    P_OBJECT_VERSION_NUMBER      IN    OUT NUMBER,
    P_CONTRACT_ACCEPTED VARCHAR2,
    P_RESIGNED_DUE_TO_CONTRACT VARCHAR2,
    P_CONTRACT_SIGNED_DATE     DATE  DEFAULT SYSDATE,
--    P_UPDATED_BY             NUMBER,
--    P_UPDATE_DATE            DATE,
    P_CONTRACT_STATUS       VARCHAR2 DEFAULT 'A-ACTIVE', --:='A-ACTIVE';
    P_CONTRACT_REASON       VARCHAR2 DEFAULT 'PROCESSED', --:='PROPOSED';
    P_CONTRACT_DOC_STATUS   VARCHAR2 DEFAULT 'PROCESSED',  --:='CREATED';
    P_ASSIGNMENTS_CREATION_DATE DATE   DEFAULT SYSDATE
--    ,
--    P_RISK_FLAG VARCHAR2
   )
   IS
   LD_CONTRACT_PRINT_DATE  VARCHAR2(20);
   LC_CONTRACT_PRINT_BY_STAFF VARCHAR2(240);
   LC_USER_NAME            VARCHAR2(240);
   LN_PERSON_ID            NUMBER := NULL;
   LC_REFERENCE            VARCHAR2(240) :=NULL;
   LN_OBJECT_VERSION_NUMBER NUMBER := NULL;
   LC_STATUS               VARCHAR2(20) := NULL;
   LC_CONTRACT_SIGNED_DATE    VARCHAR2(20);
   LC_TYPE                    VARCHAR2(24);
   LC_CONTRACT_STATUS         VARCHAR2(20);
   LC_ASSIGNMENT_FLAG_STATUS  VARCHAR2(240);
   LC_SAL_FLAG_STATUS         VARCHAR2(240);
   LC_CONTRACT_RECEIVED_DATE  VARCHAR2(240);
   LN_REQUEST_ID              NUMBER;
   CURSOR XXTG_USER_CUR (LN_USER_ID NUMBER) IS
   SELECT USER_NAME FROM FND_USER WHERE USER_ID = LN_USER_ID;
   
   CURSOR XXTG_CONT (LN_CONTRACT_ID VARCHAR2) IS
   SELECT PERSON_ID,CONTRACT_ID, REFERENCE, TYPE,OBJECT_VERSION_NUMBER,  STATUS
   , ATTRIBUTE15 CONTRACT_PRINT_DATE
   , ATTRIBUTE16 CONTRACT_PRINT_BY_STAFF 
   , ATTRIBUTE17 CONTRACT_RECEIVED_DATE
   FROM PER_CONTRACTS_F
   WHERE to_char(CONTRACT_ID) = LN_CONTRACT_ID ;
   
   BEGIN
   
   LN_PERSON_ID := NULL;
   LC_REFERENCE :=NULL;
   LN_OBJECT_VERSION_NUMBER := NULL;
   LC_STATUS := NULL;
--  LN_OBJECT_VERSION_NUMBER := P_OBJECT_VERSION_NUMBER;
   LD_EFFECTIVE_START_DATE  := NULL;
   LD_EFFECTIVE_END_DATE    := NULL;
   LC_CONTRACT_STATUS       := 'A-ACTIVE';
   
  FOR XXTG_CONT_REC IN XXTG_CONT (P_CONTRACT_ID)
    LOOP
      LN_PERSON_ID:= XXTG_CONT_REC.PERSON_ID;
      LC_REFERENCE:= XXTG_CONT_REC.REFERENCE;
      LN_OBJECT_VERSION_NUMBER:= XXTG_CONT_REC.OBJECT_VERSION_NUMBER;
      LC_STATUS:= XXTG_CONT_REC.STATUS;
      LC_TYPE  := XXTG_CONT_REC.TYPE;  --UNlimited Contract by Default
      LN_CONTRACT_ID :=XXTG_CONT_REC.CONTRACT_ID;
      LD_CONTRACT_PRINT_DATE :=XXTG_CONT_REC.CONTRACT_PRINT_DATE; --IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
      LC_CONTRACT_PRINT_BY_STAFF :=XXTG_CONT_REC.CONTRACT_PRINT_BY_STAFF;
      LC_CONTRACT_RECEIVED_DATE :=XXTG_CONT_REC.CONTRACT_RECEIVED_DATE;
    END LOOP; 
     IF LC_CONTRACT_RECEIVED_DATE IS NULL THEN 
         BEGIN
             dbms_session.set_nls ('nls_date_format','''DD-MON-RR''');
               ln_request_id := fnd_request.submit_request ( 
                                    application   => 'TGCUST', 
                                    program       => 'XXTG_UPDATE_CONTRACT', 
                                    description   => 'XXTG Update Contract Assignment Salary HRA TRA', 
                                    start_time    => sysdate, 
                                    sub_request   => FALSE,
                                    argument1     => P_CONTRACT_ID,
                                    argument2     => P_CONTRACT_ACCEPTED,
                                    argument3     => P_RESIGNED_DUE_TO_CONTRACT,
                                    argument4     => P_CONTRACT_SIGNED_DATE,
                                    argument5     => P_CONTRACT_STATUS,
                                    argument6     => P_CONTRACT_REASON,
                                    argument7     => P_CONTRACT_DOC_STATUS,
                                    argument8     => P_ASSIGNMENTS_CREATION_DATE
          );
--              INSERT INTO XXTG_TEST VALUES(' Inside submit_request  P_CONTRACT_DOC_STATUS and P_CONTRACT_REASON P_CONTRACT_SIGNED_DATE P_ASSIGNMENTS_CREATION_DATE '||P_CONTRACT_DOC_STATUS||' '||P_CONTRACT_REASON||' '||P_CONTRACT_SIGNED_DATE||' '||P_ASSIGNMENTS_CREATION_DATE);

          IF ln_request_id = 0
          THEN
          fnd_file.put_line(fnd_file.LOG,'Concurrent request failed to submit');
          ELSE
          fnd_file.put_line(fnd_file.LOG,'Successfully Submitted the Concurrent Request');
          END IF;
 
        EXCEPTION
        WHEN OTHERS THEN
          fnd_file.put_line(fnd_file.LOG,'Error While Submitting Concurrent Request '||TO_CHAR(SQLCODE)||'-'||sqlerrm);
        END;
     END IF; 

  COMMIT;
 
  END UPDATE_CONTRACT;
  
    FUNCTION CHANGE_PRINT_STATUS          RETURN VARCHAR2
    IS   
    BEGIN
    
    FOR XXTG_REC IN XXTG_CONT_CUR (P_CONTRACT_BATCH , P_BU_ORG_ID, P_SBU_ORG_ID, P_DEP_ORG_ID, P_SEC_ORG_ID, P_CNT_ORG_ID, P_PERSON_ID, P_RISK)
     LOOP
        XXTG_CA_DEPLOYMENT_PKG.UPDATE_CONTRACT
  ( P_CONTRACT_ID  =>XXTG_REC.CONTRACT_ID,
    P_CONTRACT_ACCEPTED=>  NULL, --XXTG_REC.CONTRACT_ACCEPTED,
    P_RESIGNED_DUE_TO_CONTRACT=> NULL, --XXTG_REC.RESIGNED, 
    P_CONTRACT_SIGNED_DATE    => SYSDATE,
    P_CONTRACT_STATUS         => NULL, --'A-ACTIVE', --:='A-ACTIVE';
    P_CONTRACT_REASON         =>'PRINTED' , -- 'PROCESSED', --:='PROPOSED';
    P_CONTRACT_DOC_STATUS    =>'PRINTED' , --VARCHAR2 DEFAULT 'PROCESSED',  --:='CREATED';
    P_ASSIGNMENTS_CREATION_DATE => SYSDATE
--    ,
--    P_RISK_FLAG                 =>NULL
   );
     END LOOP;
     COMMIT;
     RETURN ('Y');

    END CHANGE_PRINT_STATUS;
  FUNCTION AUTO_UPDATE_CONT_FOR_RISK_N  RETURN VARCHAR2
  IS 
    LC_SYSDATE VARCHAR2(240);
    BEGIN
    FOR XXTG_REC IN XXTG_CONT_CUR (P_CONTRACT_BATCH , P_BU_ORG_ID, P_SBU_ORG_ID, P_DEP_ORG_ID, P_SEC_ORG_ID, P_CNT_ORG_ID, P_PERSON_ID, 'N')
     LOOP
        LC_SYSDATE:=TO_CHAR(SYSDATE,'DD-MON-RRRR');
        XXTG_CA_DEPLOYMENT_PKG.UPDATE_CONTRACT
  ( P_CONTRACT_ID  =>XXTG_REC.CONTRACT_ID,
    P_CONTRACT_ACCEPTED=>  'Y', --XXTG_REC.CONTRACT_ACCEPTED,
    P_RESIGNED_DUE_TO_CONTRACT=> 'N', --XXTG_REC.RESIGNED, 
--    P_CONTRACT_SIGNED_DATE    => SYSDATE, --LC_SYSDATE
    P_CONTRACT_STATUS         => 'A-ACTIVE',
    P_CONTRACT_REASON         =>'PROCESSED', --:='PROPOSED';--'PRINTED' , -- 
    P_CONTRACT_DOC_STATUS    =>'PROCESSED'  --:='CREATED';'PRINTED' , --VARCHAR2 DEFAULT 
--    P_ASSIGNMENTS_CREATION_DATE => SYSDATE --LC_SYSDATE
--    ,
--    P_RISK_FLAG                 =>'N'
   );
     END LOOP;
     COMMIT;
     RETURN ('Y');

    END AUTO_UPDATE_CONT_FOR_RISK_N;
     FUNCTION SUBMIT_REQUEST_BURST
--  ( P_CONC_REQUEST_ID in number
--  )
  return VARCHAR2
  is
  l_req_id number := 0;
  LN_REQUEST_ID VARCHAR2(240);
  CURSOR XXTG_REQUEST IS 
  SELECT FND_GLOBAL.CONC_REQUEST_ID REQUEST_ID FROM DUAL;
  begin
--   FOR XXTG_REC IN XXTG_REQUEST
--     LOOP
--       LN_REQUEST_ID:=XXTG_REC.REQUEST_ID;
--     END LOOP;
     BEGIN
      SELECT FND_GLOBAL.CONC_REQUEST_ID  INTO LN_REQUEST_ID FROM DUAL;
     END;
     
     l_req_id :=FND_REQUEST.SUBMIT_REQUEST (
                                        'XDO',
                                        'XDOBURSTREP',
                                        '',
                                        '',
                                        FALSE,
                                        'Y', TO_NUMBER(fnd_global.conc_request_id), 'Y',
                                        chr(0), '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '',
                                        '', '', '', '', '', '', '', '', '', '');
     
--    l_req_id := fnd_request.submit_request('XDO','XDOBURSTREP',NULL,NULL,FALSE,
--                                           fnd_global.conc_request_id);
    P_CONC_REQUEST_ID:=to_number(fnd_global.conc_request_id);                                       
  return TO_CHAR(l_req_id);
  end SUBMIT_REQUEST_BURST;
PROCEDURE  SUBMIT_PRINT_REQUEST (P_CONTRACT_BATCH varchar2, P_REQUEST_ID OUT varchar2) 
     IS
l_responsibility_id 	NUMBER;
l_application_id    	NUMBER;
l_user_id           	NUMBER;
l_request_id            NUMBER;
LC_LOG_REQUEST_ID       varchar2(240);
BEGIN
  --
  --
  --To set environment context.
  --Hardcoding User TG.HCM.SCHED  and Responsiblity TG_SCHED_PROG  and Application  Human Resources
  -- Testing by commenting code to initialize this to execute from TG_SCHED_PROG user.
  apps.fnd_global.apps_initialize (user_id=>1677,resp_id=>50866,resp_appl_id=>800);
   dbms_session.set_nls ('nls_date_format','''DD-MON-RR''');
  --
  --Submitting Concurrent Request
  --
  P_REQUEST_ID := fnd_request.submit_request ( 
                            application   => 'TGCUST', 
                            program       => 'XXTG_CONTRACT_PRINT', 
--                            description   => 'Scheduled Program Call From Perfect forms', 
                            start_time    => sysdate, 
                            sub_request   => FALSE,
			                      argument1     => P_CONTRACT_BATCH
  );
  --
--  XXTG_CA_PKG.SUBMIT_LOG_REQUEST (P_CONTRACT_BATCH => P_CONTRACT_BATCH, P_REQUEST_ID =>LC_LOG_REQUEST_ID) ;
--  fnd_file.put_line(fnd_file.LOG,'Concurrent request for Error Log:'||LC_LOG_REQUEST_ID);
--  Commmented import audit, will enable if neccasery
--  P_REQUEST_ID := fnd_request.submit_request ( 
--                            application   => 'TGCUST', 
--                            program       => 'XXTG_CONTRACT_IMPORT_AUDIT', 
----                            description   => 'Scheduled Program Call From Perfect forms to call Log of contract batch Status', 
--                            start_time    => sysdate, 
--                            sub_request   => FALSE,
--			                      argument1     => P_CONTRACT_BATCH
--  );
  COMMIT;
  --
  IF P_REQUEST_ID = 0
  THEN
  fnd_file.put_line(fnd_file.LOG,'Concurrent request failed to submit');
  ELSE
  fnd_file.put_line(fnd_file.LOG,'Successfully Submitted the Concurrent Request');
  END IF;
--  return to_char(l_request_id);
  --
EXCEPTION
WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.LOG,'Error While Submitting Concurrent Request '||TO_CHAR(SQLCODE)||'-'||sqlerrm);
--  return sqlerrm;
END SUBMIT_PRINT_REQUEST;

PROCEDURE SUBMIT_LOG_REQUEST (P_CONTRACT_BATCH varchar2, P_REQUEST_ID OUT varchar2) 
     IS
l_responsibility_id 	NUMBER;
l_application_id    	NUMBER;
l_user_id           	NUMBER;
l_request_id            NUMBER;
BEGIN
  --
  --
  --To set environment context.
  --Hardcoding User TG.HCM.SCHED  and Responsiblity TG_SCHED_PROG  and Application  Human Resources
--  apps.fnd_global.apps_initialize (user_id=>1677,resp_id=>50866,resp_appl_id=>800);
  --
  --Submitting Concurrent Request
  --
  P_REQUEST_ID := fnd_request.submit_request ( 
                            application   => 'TGCUST', 
                            program       => 'XXTG_CONTRACT_IMPORT_AUDIT', 
                            description   => 'Scheduled Program Call From Perfect forms to call Log of contract batch Status', 
                            start_time    => sysdate, 
                            sub_request   => FALSE,
			                      argument1     => P_CONTRACT_BATCH
  );
  --
  COMMIT;
  --
  IF P_REQUEST_ID = 0
  THEN
  fnd_file.put_line(fnd_file.LOG,'Concurrent request failed to submit');
  ELSE
  fnd_file.put_line(fnd_file.LOG,'Successfully Submitted the Concurrent Request');
  END IF;
--  return to_char(l_request_id);
  --
EXCEPTION
WHEN OTHERS THEN
  fnd_file.put_line(fnd_file.LOG,'Error While Submitting Concurrent Request '||TO_CHAR(SQLCODE)||'-'||sqlerrm);
--  return sqlerrm;
END SUBMIT_LOG_REQUEST;
  FUNCTION GET_CONTRACT_CS_ALLOWANCE (P_CONTRACT_ID NUMBER) RETURN NUMBER 
  IS
  cursor XXTG_CS_ALL_CUR (ln_contract_id number) is
SELECT M.ALLOWANCE_AMOUNT
  FROM PER_CONTRACTS_F A ,
  TG_MOS_CS_ALLOWANCE_MASTER_V M
 WHERE   m.job_name = a. attribute2 
    AND  M.org_name =  a.attribute1
    and  m.basic_salary = a.attribute4
    and nvl( m.roster_name,1) = nvl( a.attribute3,1)
       AND M.BGID = A.BUSINESS_GROUP_ID
        AND A.CONTRACT_ID = ln_contract_id;
        LN_CS_ALLOWANCE NUMBER := 0;
  BEGIN
    FOR XXTG_REC IN XXTG_CS_ALL_CUR(P_CONTRACT_ID)
      LOOP
        LN_CS_ALLOWANCE := XXTG_REC.ALLOWANCE_AMOUNT;
      END LOOP;
    RETURN (LN_CS_ALLOWANCE);
  END GET_CONTRACT_CS_ALLOWANCE;
  
-- ------- ----------- --------------- ------------------------------------
-- Procedure for Primary Address Update used for udpating camp and room from OAF Page
--************************************************************************
  PROCEDURE PRIMARY_ADDRESS_UPDATE(
P_EMPLOYEE_NUMBER  VARCHAR2 ,    
P_CAMP_NAME        VARCHAR2 ,            
P_EFFECTIVE_DATE   DATE,     
P_CAMP_ROOM_NO          VARCHAR2 , 
P_ADDRESS_ID OUT NUMBER )
IS
  V_ERROR                 VARCHAR2(1000);
  L_CNT                   NUMBER := 0;
  v_object_version_number NUMBER;
  v_effective_date        DATE; v_Address_id            NUMBER;
    v_obj_ver_num           NUMBER;
    LC_EMIRATE_CODE       VARCHAR2(240);
    LC_CAMP_LOOKUP_CODE   VARCHAR2(240);
    CURSOR get_rec
       (LC_EMPLOYEE_NUMBER VARCHAR2
      )
    IS
      SELECT pap.person_id
        FROM 
             per_all_people_f         pap
        where 
         (LC_EMPLOYEE_NUMBER is not null and LC_EMPLOYEE_NUMBER = pap.employee_number)
         and trunc(sysdate) between pap.effective_start_date and
             pap.effective_end_date
             and pap.business_group_id <> 83
             and pap.person_id = (select max(person_id) from per_all_people_f p
             where  (LC_EMPLOYEE_NUMBER is not null and LC_EMPLOYEE_NUMBER = p.employee_number)
             and trunc(sysdate) between p.effective_start_date and p.effective_end_date)
         and pap.person_id not in
             (select hpd.from_person_id
                from hr_person_deployments hpd
               where trunc(sysdate) between hpd.start_date and hpd.end_date);
  
    CURSOR old_address(p_person_id in number, p_date in date) IS
      SELECT *
        FROM per_addresses a
       where a.person_id = p_person_id
         and a.primary_flag = 'Y'
         and a.date_from < p_date
         and (a.date_to is null or a.date_to >= p_date);
  
    CURSOR  XXTG_CAMP_CUR (LC_CAMP_NAME VARCHAR2)
    IS 
    select   DECODE(C.DESCRIPTION,'Abu Dhabi',1,
                    'Dubai',2,
                    'Sharjah',3,
                    'Ajman',4,
                    'Umm al-Qaiwain',5,
                    'Ras al-Khaimah',6,
                    'Fujairah',7) EMIRATE_CODE,
                c.LOOKUP_CODE CAMP_LOOKUP_CODE
--             ,
--             c.MEANING
        from    fnd_common_lookups  c
        where   c.LOOKUP_TYPE = 'TG_CAMP_NAME'
        and c.MEANING= LC_CAMP_NAME  ; 
  BEGIN
    for rec in get_rec(
                       P_EMPLOYEE_NUMBER    
                       )
      loop
      V_ERROR := NULL;
    
      V_EFFECTIVE_DATE := FND_CONC_DATE.STRING_TO_DATE(P_EFFECTIVE_DATE);
    
      for oa in old_address(rec.person_id, v_effective_date) 
       loop
        BEGIN
          v_object_version_number := oa.object_version_number;
          hr_ae_person_address_api.update_ae_person_address(p_validate              => FALSE,
                                                            p_effective_date        => v_effective_date - 1,
                                                            p_address_id            => oa.address_id,
                                                            p_object_version_number => v_object_version_number,
                                                            p_primary_flag          => oa.primary_flag,
                                                            p_date_from             => oa.date_from,
                                                            p_date_to               => v_effective_date - 1,
                                                            p_address_line1         => oa.address_line1,
                                                            p_emirate               => oa.address_line3);
        
        EXCEPTION
          WHEN OTHERS THEN
            V_ERROR := SQLERRM;
            DBMS_OUTPUT.PUT_LINE( '~' || 'END' || '~' ||
                                 V_ERROR);
        END;
      END LOOP;
    
    LC_EMIRATE_CODE:= NULL;
    FOR XXTG_REC IN XXTG_CAMP_CUR(P_CAMP_NAME)
      LOOP
          LC_EMIRATE_CODE := XXTG_REC.emirate_code;
          LC_CAMP_LOOKUP_CODE := XXTG_REC.CAMP_LOOKUP_CODE;
       END LOOP;
    
    
      v_obj_ver_num := NULL;
      v_Address_id  := NULL;
      BEGIN
      
        hr_person_address_api.create_person_address(p_validate                => FALSE,
                                                    p_effective_date          => v_effective_date,
                                                    p_pradd_ovlapval_override => FALSE,
                                                    p_validate_county         => TRUE,
                                                    p_person_id               => rec.person_id,
                                                    p_primary_flag            => 'Y',
                                                    p_style                   => 'AE',
                                                    p_date_from               => v_effective_date,
                                                    p_date_to                 => NULL,
                                                    p_address_type            => NULL,
                                                    p_comments                => NULL,
                                                    p_address_line1           => P_CAMP_NAME, --rec.camp_name,
                                                    p_address_line3           => LC_emirate_code,
                                                    p_country                 => 'AE',
                                                    p_add_information19       => P_CAMP_ROOM_NO, ---rec.camp_room_no,
                                                    p_add_information20       => LC_CAMP_LOOKUP_CODE, --rec.camp_lookup_code,
                                                    p_address_id            => v_Address_id,
                                                    p_object_version_number => v_obj_ver_num);
      
      EXCEPTION
        WHEN OTHERS THEN
          V_ERROR := V_ERROR || SQLERRM;
          DBMS_OUTPUT.PUT_LINE( '~' || 'START' || '~' ||
                               V_ERROR);
      END;
      IF (V_ERROR IS NOT NULL) THEN
        INSERT INTO TG_camp_update_interface_log
          (
           Employee_Number,
           Camp_Name,
           Lookup_Code,
           Camp_Room_No,
           Effective_Date,
           Transaction_Date,
           Upload_date,
           Status,
           Error)
        VALUES
          (
           P_EMPLOYEE_NUMBER, --rec.employee_number,
           P_CAMP_NAME,  --rec.camp_name,
           LC_CAMP_LOOKUP_CODE,
           P_CAMP_ROOM_NO , --rec.camp_room_no,
           v_effective_date , --rec.effective_date,
           v_effective_date , --rec.transaction_date,
           sysdate,
           'ERROR',
           v_error);
      ELSE
        INSERT INTO TG_camp_update_interface_log
          (
           Employee_Number,
           Camp_Name,
           Lookup_Code,
           Camp_Room_No,
           Effective_Date,
           Transaction_Date,
           Upload_date,
           Status,
           Error)
        VALUES
          (
           P_EMPLOYEE_NUMBER, --rec.employee_number,
           P_CAMP_NAME,  --rec.camp_name,
           LC_CAMP_LOOKUP_CODE,
           P_CAMP_ROOM_NO , --rec.camp_room_no,
           v_effective_date , --rec.effective_date,
           v_effective_date , --rec.transaction_date,
           sysdate,
           'OK',
           NULL);
      END IF;
    END LOOP;
  COMMIT;
    P_ADDRESS_ID:= NVL(v_Address_id,0);
  END PRIMARY_ADDRESS_UPDATE;  
---------------------  
----------  Following program called by Concurrent program to validate contract Batch
-------------------  
     PROCEDURE VALIDATE_CONTRACT_BATCH(
   ERRBUF        OUT VARCHAR2,
   RETCODE       OUT VARCHAR2,
   P_CONTRACT_BATCH varchar2)
   IS 

  L_PAYROLL_ID     NUMBER;
  L_JOB_ID         NUMBER;
  L_ROSTER_ID      NUMBER;
  L_ERROR          VARCHAR2(1000);
  L_MSG            VARCHAR2(2000);
  L_ASG_ID         NUMBER;
  L_ASG_OVN        NUMBER;
  L_EFFECTIVE_DATE DATE;
  L_CONTRACT_ID    NUMBER;
  L_PPL_GRP_ID     NUMBER;
  L_GRADE_ID       NUMBER;
  L_LOCATION_ID    NUMBER;
  L_BG_ID          NUMBER;
  L_PERSON_ID      NUMBER;
  L_ASG_TYPE       VARCHAR2(240);
  L_ASG_SYSTEM_STATUS  VARCHAR2(240);
  L_ERROR_CONTRACT  NUMBER;
  ---------------------------------
  L_TOTAL                   NUMBER := 0;
  L_ERROR_COUNT             NUMBER := 0;
  L_SUCCESS_COUNT           NUMBER := 0;
  L_FUTURE_ASG              NUMBER := 0;
  L_FUTURE_DATE             DATE;
  L_SPECIAL_CEILING_STEP_ID NUMBER;
  LC_EXTERNAL_CLIENT        VARCHAR2(1);
  L_BUSINESS_GROUP_ID       NUMBER;

  L_GROUP_NAME                   VARCHAR2(1000);
  L_EFFECTIVE_START_DATE         DATE;
  L_EFFECTIVE_END_DATE           DATE;
  L_ORG_NOW_NO_MANAGER_WARNING   BOOLEAN;
  L_OTHER_MANAGER_WARNING        BOOLEAN;
  L_SPP_DELETE_WARNING           BOOLEAN;
  L_ENTRIES_CHANGED_WARNING      VARCHAR2(1000);
  L_TAX_DISTRICT_CHANGED_WARNING BOOLEAN;
  L_MODE                         VARCHAR2(100);
  ---------------------------------
  CURSOR TG_COR_CUR 
  (P_CONTRACT_ID  NUMBER,
  P_BASIC_SALARY NUMBER,
  P_JOB_ID       NUMBER,
  P_CAMP         VARCHAR2,
  P_ROSTER_ID    NUMBER,
  P_DATE        DATE)
  IS
  SELECT COR.MONTHLY_SERVICE_RATE ,
  COR.HOURLY_SERVICE_RATE 
--  , COR.OTHER_ALLOWANCE, COR.COMBINATION_SALARY,COR.JOB_ID
--, HR_GENERAL.DECODE_JOB(COR.JOB_ID) JOB
--,CINFO.CONTRACT_ID
--, HR_GENERAL.DECODE_ORGANIZATION(CINFO.CONTRACT_ID)
        FROM TG_MOS_INV_CLIENT_INFO CINFO,
             TG_MOS_INV_CLIENT_MODE CMODE,
             TG_MOS_INV_CLIENT_COR  COR
       WHERE 
         CMODE.CLIENT_INFO_ID = CINFO.CLIENT_INFO_ID
         AND COR.CLIENT_MODE_ID = CMODE.CLIENT_MODE_ID
         AND CINFO.CONTRACT_ID  = P_CONTRACT_ID
         AND COR.COMBINATION_SALARY = P_BASIC_SALARY
         AND COR.JOB_ID = P_JOB_ID 
         AND NVL(CINFO.ROSTER_ID, 1) = NVL(P_ROSTER_ID, 1)
         AND trunc (P_DATE)   BETWEEN CMODE.DATE_FROM AND
             NVL(CMODE.DATE_TO, '31-DEC-4712')
         AND ROWNUM =1;
  
  
-- SELECT COR.MONTHLY_SERVICE_RATE
--        FROM TG_MOS_INV_CLIENT_INFO CINFO,
--             TG_MOS_INV_CLIENT_MODE CMODE,
--             TG_MOS_INV_CLIENT_COR  COR
--       WHERE 
--         CMODE.CLIENT_INFO_ID = CINFO.CLIENT_INFO_ID
--         AND COR.CLIENT_MODE_ID = CMODE.CLIENT_MODE_ID
--         AND CINFO.CONTRACT_ID  = P_CONTRACT_ID
--         AND COR.COMBINATION_SALARY = P_BASIC_SALARY
--         AND COR.JOB_ID  = P_JOB_ID
--       AND (( COR.ATTRIBUTE1 IS NULL AND P_CAMP IS NULL) or (  COR.ATTRIBUTE1 = P_CAMP ))
--         AND ( ( CINFO.ROSTER_ID is null AND P_ROSTER_ID IS NULL) or ( CINFO.ROSTER_ID = P_ROSTER_ID ))
--         AND fnd_conc_date.string_to_date(P_DATE) BETWEEN CMODE.DATE_FROM AND
--             NVL(CMODE.DATE_TO, '31-DEC-4712')
--         AND ROWNUM =1;
--         
         
         
--  SELECT COR.MONTHLY_SERVICE_RATE
--        FROM TG_MOS_INV_CLIENT_INFO CINFO,
--             TG_MOS_INV_CLIENT_MODE CMODE,
--             TG_MOS_INV_CLIENT_COR  COR
--       WHERE 
--         CMODE.CLIENT_INFO_ID = CINFO.CLIENT_INFO_ID
--         AND COR.CLIENT_MODE_ID = CMODE.CLIENT_MODE_ID
--         AND CINFO.CONTRACT_ID  = P_CONTRACT_ID
--         AND COR.COMBINATION_SALARY = P_BASIC_SALARY
--         AND NVL(COR.JOB_ID, P_JOB_ID) = P_JOB_ID
--         AND NVL(COR.ATTRIBUTE1, P_CAMP) = P_CAMP
--         AND NVL(CINFO.ROSTER_ID, 1) = NVL(P_ROSTER_ID, 1)
--         AND P_DATE BETWEEN CMODE.DATE_FROM AND
--             NVL(CMODE.DATE_TO, '31-DEC-4712')
--         AND ROWNUM =1;
  CURSOR ALL_REC (LN_HEADER_ID NUMBER) IS
    SELECT XCLA.LINE_ID                 	,
      XCLA.HEADER_ID                        	,
      XCLA.SNO                              	,
      replace(
           replace(
               replace(replace(XCLA.TG_ID,'TG'), CHR(10))
           , CHR(13))
       , CHR(09))   TG_ID                    	,
      XCLA.PERSON_ID                        	,
      XCLA.ASSIGNMENT_ID                    	,
      XCLA.FULL_NAME                 	,
      fnd_conc_date.string_to_date(XCLA.EFFECTIVE_DATE)    EFFECTIVE_DATE                	,
      XCLA.OLD_CONTRACT_CODE         	,
      XCLA.OLD_CONTRACT_NAME         	,
      XCLA.OLD_JOB                   	,
      XCLA.OLD_ROSTER                	,
      XCLA.OLD_BASIC_SALARY                 	,
      XCLA.OLD_TOTAL_SALARY                 	,
      XCLA.NEW_CONTRACT_CODE         	,
      XCLA.NEW_CONTRACT_NAME         	,
      XCLA.NEW_JOB                   	,
      XCLA.NEW_ROSTER                	,
      XCLA.NEW_BASIC_SALARY                 	,
      XCLA.NEW_TOTAL_SALARY                 	,
      XCLA.DIFFERENCE                       	,
      XCLA.COMMENTS                  	,
      XCLA.ATTRIBUTE1                	,
      XCLA.ATTRIBUTE2                	,
      XCLA.ATTRIBUTE3                	,
      XCLA.ATTRIBUTE4                	,
      XCLA.ATTRIBUTE5                 ,	
      XCLA.CONTRACT_ID                  ,
      XCLA.CAMP_NAME                     ,
      XCLA.CAMP_ROOM_NAME                ,
      XCLA.ADDRESS_ID                    ,
      XCLA.ADDR_DEPLOYMENT_DATE          ,
      XCLA.VALIDATION_MESSAGE          
      FROM XXTG_CA_LINES_ALL XCLA
     WHERE HEADER_ID = LN_HEADER_ID
     FOR UPDATE OF  
      XCLA.ATTRIBUTE1, -- Allowance
      XCLA.ATTRIBUTE2, -- Allowance
      XCLA.ATTRIBUTE5, -- Risk
      XCLA.RISK_FLAG,
      XCLA.VALIDATION_MESSAGE          ,
      XCLA.CONTRACT_ID                  ,
      XCLA.PERSON_ID,
      XCLA.ASSIGNMENT_ID,
      XCLA.NEW_JOB                   	,
      XCLA.NEW_BASIC_SALARY                 	,
      XCLA.TG_ID;
      LN_HEADER_ID NUMBER;
  CURSOR XXTG_CONT_CUR (LC_TG_ID VARCHAR2, LN_HEADER_ID NUMBER) IS 
    select  DISTINCT HEADER_ID 
    from xxtg_ca_lines_all
    where tg_id = LC_TG_ID --'063851'
    AND HEADER_ID <>LN_HEADER_ID
    AND HEADER_ID NOT IN (select header_id from xxtg_ca_headers_all
    WHERE  
--    CLOSED_DATE IS NOT NULL OR   bug fixed
    CANCEL_FLAG='Y' OR approval_status IN ( 'Draft', 'Rejected' ))
  AND 
   ( header_id in (select header_id from xxtg_ca_headers_all where approval_status= 'In Approval Process')--NVL(approval_status,'Draft') IN ('In Approval Process','Draft'))
    OR 
    (
    header_id in (select header_id from xxtg_ca_headers_all where approval_status= 'Approved  Sent')
    AND
    (NVL(RISK_FLAG,'N')='Y' AND  (contract_id IS NULL OR TO_NUMBER(contract_id) IN  (SELECT CONTRACT_ID FROM PER_CONTRACTS_F WHERE ATTRIBUTE20 IS NULL)))
--    (  (contract_id IS NULL OR TO_NUMBER(contract_id) IN  (SELECT CONTRACT_ID FROM PER_CONTRACTS_F WHERE ATTRIBUTE20 IS NULL)))
    )
    );
  CURSOR XXTG_EMP_CUR (LC_EMP_NUMBER VARCHAR2,LD_EFFECTIVE_DATE VARCHAR2)
  IS 
       SELECT         A.PERSON_ID,
                      A.ASSIGNMENT_ID,  --REMOVED DISTINCT
                      A.OBJECT_VERSION_NUMBER,
                      A.EFFECTIVE_START_DATE,
                      A.ORGANIZATION_ID,
                      A.PEOPLE_GROUP_ID,
                      A.GRADE_ID,
                      A.JOB_ID,
                      A.PAYROLL_ID,
                      A.LOCATION_ID,
                      A.SPECIAL_CEILING_STEP_ID,
                      (SELECT USER_STATUS FROM PER_ASSIGNMENT_STATUS_TYPES
                        WHERE ASSIGNMENT_STATUS_TYPE_ID = A.ASSIGNMENT_STATUS_TYPE_ID) USER_STATUS,
                      (SELECT per_system_status FROM PER_ASSIGNMENT_STATUS_TYPES
                        WHERE ASSIGNMENT_STATUS_TYPE_ID = A.ASSIGNMENT_STATUS_TYPE_ID) SYSTEM_STATUS,
                      A.BUSINESS_GROUP_ID
        FROM PER_ASSIGNMENTS_F      A,PER_ALL_PEOPLE_F PAPF
       WHERE  A.PERSON_ID = PAPF.PERSON_ID 
       AND  trim(PAPF.EMPLOYEE_NUMBER)=TRIM(LC_EMP_NUMBER)
       AND TO_DATE(LD_EFFECTIVE_DATE,'DD-MON-RR')  --TO_DATE('01-AUG-17','DD-MON-RR') --
         BETWEEN PAPF.EFFECTIVE_START_DATE AND
             PAPF.EFFECTIVE_END_DATE
         AND TO_DATE(LD_EFFECTIVE_DATE,'DD-MON-RR')  --TO_DATE('01-AUG-17','DD-MON-RR') --
         BETWEEN A.EFFECTIVE_START_DATE AND
             A.EFFECTIVE_END_DATE
         AND A.ASSIGNMENT_TYPE = 'E'
         AND A.BUSINESS_GROUP_ID = FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
          
       CURSOR XXTG_BG_CUR (LN_BG_ID NUMBER) IS
       SELECT NAME  FROM PER_BUSINESS_GROUPS
       WHERE BUSINESS_GROUP_ID = LN_BG_ID;

        CURSOR XXTG_SAL_CUR (LN_ASG_ID NUMBER, LN_BUSINESS_GROUP_ID NUMBER, LD_EFFECTIVE_DATE DATE)
          IS SELECT SAL.PROPOSED_SALARY_N
          FROM PER_PAY_PROPOSALS SAL
          WHERE  SAL.ASSIGNMENT_ID =LN_ASG_ID
       AND SAL.BUSINESS_GROUP_ID = LN_BUSINESS_GROUP_ID
       AND LD_EFFECTIVE_DATE BETWEEN SAL.CHANGE_DATE AND SAL.DATE_TO;
       LC_BUSINESS_GROUP   VARCHAR2(240);
       LN_COR              NUMBER;
       LN_HOURLY_COR        NUMBER := NULL;
       LN_DERIVED_NEW_BASIC_SALARY  NUMBER:= NULL;
--       XXTG_EMP_REC XXTG_EMP_CUR%ROWTYPE;
       LC_BATCH_RISK VARCHAR2(1) :='N';
       LC_LINE_RISK VARCHAR2(1) :='N';
       CURSOR XXTG_ORG_CUR (LN_BG_ID NUMBER, LC_CONTRACT_NAME VARCHAR2,LD_EFFECTIVE_DATE VARCHAR2   ) 
       IS
               SELECT U.ORGANIZATION_ID, NVL(U.ATTRIBUTE19,'Y') EXTERNAL_CLIENT
--          INTO L_CONTRACT_ID, LC_EXTERNAL_CLIENT
          FROM HR_ALL_ORGANIZATION_UNITS U
         WHERE UPPER(TRIM(U.NAME)) = UPPER(TRIM(LC_CONTRACT_NAME))
           AND U.BUSINESS_GROUP_ID = LN_BG_ID
           AND  TO_DATE(LD_EFFECTIVE_DATE,'DD-MON-RR')
           BETWEEN U.DATE_FROM AND
               NVL(U.DATE_TO, '31-DEC-4712')
           AND U.TYPE = 'CNRT';
         CURSOR XXTG_ACC_CUR (LC_ACC_NAME VARCHAR2)IS
  select MEANING Accommodation, hr_general.DECODE_LOOKUP('TG_CAMP_CLASSIFICATION',ATTRIBUTE4) TYPE
    from fnd_common_lookups
    where lookup_type='TG_CAMP_NAME' and enabled_flag='Y'
    AND UPPER(TRIM(MEANING)) = UPPER(TRIM(LC_ACC_NAME));
    LC_ACCOMODATION_TYPE  VARCHAR2(240);
    CURSOR XXTG_TIME_CUR IS
    SELECT TO_NUMBER(to_char(sysdate,'HH24')) HOURS FROM DUAL;
    CURSOR XXTG_TIME_DIFF_CUR (LC_EFF_DATE DATE) IS
    SELECT (LC_EFF_DATE  -  SYSDATE ) NUMBER_OF_DAYS FROM DUAL;
       LN_3PM_DAY_TIME_CHECK     NUMBER  := NULL;
       LN_NUMBER_OF_DAYS_CHECK   NUMBER  := NULL;
BEGIN
  LN_HEADER_ID := TO_NUMBER(P_CONTRACT_BATCH);
  L_BG_ID := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID'); -- FND_GLOBAL.PER_BUSINESS_GROUP_ID;
  LC_BATCH_RISK :=XXTG_CA_DEPLOYMENT_PKG.GET_BATCH_RISK(LN_HEADER_ID);
     UPDATE XXTG_CA_HEADERS_ALL
     SET RISK_FLAG = LC_BATCH_RISK
     WHERE HEADER_ID= LN_HEADER_ID;
--insert into xxtg_test values('Risk for batch '||LN_HEADER_ID||' is ' ||LC_BATCH_RISK);
  LC_BUSINESS_GROUP:= NULL;
   FOR XXTG_REC IN  XXTG_BG_CUR (L_BG_ID)
     LOOP
       LC_BUSINESS_GROUP := XXTG_REC.NAME;
     END LOOP;
  
  FOR REC IN ALL_REC(LN_HEADER_ID) LOOP
    L_ERROR                   := NULL;
    L_SPECIAL_CEILING_STEP_ID := NULL;
    L_PPL_GRP_ID              := NULL;
    L_ASG_OVN                 := NULL;
    L_FUTURE_ASG              := 0;
    L_FUTURE_DATE             := NULL;
    L_MODE                    := NULL;
    L_ASG_ID                  := NULL;
    L_EFFECTIVE_DATE          := NULL;
    L_CONTRACT_ID             := NULL;
    L_GRADE_ID                := NULL;
    L_JOB_ID                  := NULL;
    L_PAYROLL_ID              := NULL;
    L_ASG_TYPE                := NULL;
    L_ASG_SYSTEM_STATUS       := NULL;
    L_PERSON_ID               := NULL;
    L_MSG                     := NULL;
    L_ERROR_CONTRACT          := NULL;
    L_BUSINESS_GROUP_ID       := NULL;
    LC_ACCOMODATION_TYPE      := NULL;
  
  UPDATE XXTG_CA_LINES_ALL 
  SET TG_ID = REPLACE(TG_ID,'TG')
  WHERE CURRENT OF ALL_REC;
  
--    BEGIN
--            insert into xxtg_test values(REC.TG_ID||'effective date'|| REC.EFFECTIVE_DATE);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, REC.TG_ID||'effective date '|| TO_CHAR(REC.EFFECTIVE_DATE,'DD-MON-RR')||' LC_BUSINESS_GROUP'||LC_BUSINESS_GROUP);
    FOR XXTG_EMP_REC IN XXTG_EMP_CUR(REC.TG_ID, TO_CHAR(REC.EFFECTIVE_DATE,'DD-MON-RR'))
    
    
    
      LOOP           
          L_ASG_ID                 :=XXTG_EMP_REC.ASSIGNMENT_ID;
          L_ASG_OVN                :=XXTG_EMP_REC.OBJECT_VERSION_NUMBER;
          L_EFFECTIVE_DATE         :=XXTG_EMP_REC.EFFECTIVE_START_DATE;
          L_CONTRACT_ID            :=XXTG_EMP_REC.ORGANIZATION_ID;
          L_PPL_GRP_ID             :=XXTG_EMP_REC.PEOPLE_GROUP_ID;
          L_GRADE_ID               :=XXTG_EMP_REC.GRADE_ID;
          L_JOB_ID                 :=XXTG_EMP_REC.JOB_ID;
          L_PAYROLL_ID             :=XXTG_EMP_REC.PAYROLL_ID;
          L_LOCATION_ID            :=XXTG_EMP_REC.LOCATION_ID;
          L_SPECIAL_CEILING_STEP_ID:=XXTG_EMP_REC.SPECIAL_CEILING_STEP_ID;
          L_ASG_TYPE               :=XXTG_EMP_REC.USER_STATUS;
          L_ASG_SYSTEM_STATUS      :=XXTG_EMP_REC.SYSTEM_STATUS;
          L_PERSON_ID              := XXTG_EMP_REC.PERSON_ID;
          L_MSG                    := NULL;
          L_BUSINESS_GROUP_ID      :=XXTG_EMP_REC.BUSINESS_GROUP_ID;
--insert into xxtg_test values('iNSIDE   Loop  '||L_ASG_ID );
      END LOOP;
--       OPEN XXTG_EMP_CUR(REC.TG_ID, REC.EFFECTIVE_DATE);
--  
--       LOOP
--          FETCH XXTG_EMP_CUR INTO XXTG_EMP_REC;
--          EXIT WHEN XXTG_EMP_CUR%NOTFOUND;
--          L_ASG_ID                 :=XXTG_EMP_REC.ASSIGNMENT_ID;
--          L_ASG_OVN                :=XXTG_EMP_REC.OBJECT_VERSION_NUMBER;
--          L_EFFECTIVE_DATE         :=XXTG_EMP_REC.EFFECTIVE_START_DATE;
--          L_CONTRACT_ID            :=XXTG_EMP_REC.ORGANIZATION_ID;
--          L_PPL_GRP_ID             :=XXTG_EMP_REC.PEOPLE_GROUP_ID;
--          L_GRADE_ID               :=XXTG_EMP_REC.GRADE_ID;
--          L_JOB_ID                 :=XXTG_EMP_REC.JOB_ID;
--          L_PAYROLL_ID             :=XXTG_EMP_REC.PAYROLL_ID;
--          L_LOCATION_ID            :=XXTG_EMP_REC.LOCATION_ID;
--          L_SPECIAL_CEILING_STEP_ID:=XXTG_EMP_REC.SPECIAL_CEILING_STEP_ID;
--          L_ASG_TYPE               :=XXTG_EMP_REC.USER_STATUS;
--          L_PERSON_ID              := XXTG_EMP_REC.PERSON_ID;
--          L_MSG                    := NULL;
--          L_BUSINESS_GROUP_ID      :=XXTG_EMP_REC.BUSINESS_GROUP_ID;
--          insert into xxtg_test values('iNSIDE   Loop  '||L_ASG_ID );
--       END LOOP;
--  
--      CLOSE XXTG_EMP_CUR;
--  END;  
----      insert into xxtg_test values ('after loop USER_ID '||FND_PROFILE.VALUE('USER_ID')||' RESP_ID '||FND_PROFILE.VALUE('RESP_ID')||' RESP_APPL_ID '||FND_PROFILE.VALUE('RESP_APPL_ID')||' XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE '||FND_PROFILE.VALUE('XXTG_ENABLE_RISK_IF_BAS_SAL_DECREASE') ||' TG ID is '||REC.TG_ID ||' PER_BUSINESS_GROUP_ID'||FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')||'L_ASG_ID'||L_ASG_ID );      

      IF  L_ASG_ID IS NULL THEN
              L_ERROR := SUBSTR(SQLERRM, 1, 1000);
              L_MSG   := REC.TG_ID ||' : Assignment details not found.';
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, L_MSG);
--              DBMS_OUTPUT.PUT_LINE(L_MSG);
      END IF;
  
    --------------------------------------------------   For Active Assignment Only
    IF  L_ASG_SYSTEM_STATUS  <> 'ACTIVE_ASSIGN' THEN 
    --IF  L_ASG_TYPE <> 'Active Assignment' THEN
      L_ERROR := 'Employee assignment as of effective date is : ' ||L_ASG_TYPE || ', cannot proceed.';
      L_MSG   := L_MSG  || ' : ' || L_ERROR;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, L_MSG);
--      DBMS_OUTPUT.PUT_LINE(L_MSG);
    END IF;
    --------------------------------------------------   Validate Organization
    L_CONTRACT_ID := NULL;
    LC_EXTERNAL_CLIENT := NULL;
    IF  REC.NEW_CONTRACT_NAME IS NOT NULL THEN
    
     FOR XXTG_ORG_REC IN XXTG_ORG_CUR(L_BG_ID, REC.NEW_CONTRACT_NAME,TO_CHAR(REC.EFFECTIVE_DATE,'DD-MON-RR'))
        LOOP
           L_CONTRACT_ID:=XXTG_ORG_REC.ORGANIZATION_ID;
           LC_EXTERNAL_CLIENT:=XXTG_ORG_REC.EXTERNAL_CLIENT;
        END LOOP;
    
--      BEGIN
--        SELECT U.ORGANIZATION_ID, NVL(U.ATTRIBUTE19,'Y') EXTERNAL_CLIENT
--          INTO L_CONTRACT_ID, LC_EXTERNAL_CLIENT
--          FROM HR_ALL_ORGANIZATION_UNITS U
--         WHERE UPPER(TRIM(U.NAME)) = UPPER(TRIM(REC.NEW_CONTRACT_NAME))
--           AND U.BUSINESS_GROUP_ID = L_BG_ID
--           AND REC.EFFECTIVE_DATE BETWEEN U.DATE_FROM AND
--               NVL(U.DATE_TO, '31-DEC-4712')
--           AND U.TYPE = 'CNRT';
--      EXCEPTION
--        WHEN OTHERS THEN
      IF L_CONTRACT_ID IS NULL THEN
          L_ERROR := SUBSTR(SQLERRM, 1, 1000);
          L_MSG   := L_MSG  ||' : Error while fetching contract details for : ' ||
                     REC.NEW_CONTRACT_NAME || ' REC.EFFECTIVE_DATE '||REC.EFFECTIVE_DATE||' L_BG_ID '||L_BG_ID||' - (Error : ' || L_ERROR || ')';
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, L_MSG);
      END IF;
--          DBMS_OUTPUT.PUT_LINE(L_MSG);
--          L_CONTRACT_ID := NULL;
--      END;
    
    END IF;
    --------------------------------------------------   Validate Accomodation
    IF  REC.CAMP_NAME    IS NOT NULL THEN
    
    LC_ACCOMODATION_TYPE := NULL;
     FOR XXTG_ACC_REC IN XXTG_ACC_CUR (REC.CAMP_NAME)
       LOOP
         LC_ACCOMODATION_TYPE:=XXTG_ACC_REC.TYPE;
       END LOOP;
       
       IF LC_ACCOMODATION_TYPE IS NULL THEN
          L_ERROR := SUBSTR(SQLERRM, 1, 1000);
          L_MSG   := L_MSG  ||' : Error while fetching Accomodation details for : ' ||
                     REC.CAMP_NAME ;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, L_MSG);
       
       END IF;
-----------------------------------------------------
-------Test For 3 PM Cutoff FOR Address Changes only
-----------------------------------------------------
       IF LC_ACCOMODATION_TYPE IS NOT NULL THEN
       LN_3PM_DAY_TIME_CHECK:= NULL;
        FOR XXTG_TIME_REC IN XXTG_TIME_CUR
          LOOP
            LN_3PM_DAY_TIME_CHECK :=XXTG_TIME_REC.HOURS;
          END LOOP;
       LN_NUMBER_OF_DAYS_CHECK:= NULL;
        FOR XXTG_NUMBER_OF_DAYS_REC IN XXTG_TIME_DIFF_CUR (REC.effective_date)
          LOOP
            LN_NUMBER_OF_DAYS_CHECK :=XXTG_NUMBER_OF_DAYS_REC.NUMBER_OF_DAYS;
          END LOOP;
---------------------LN_3PM_DAY_TIME_CHECK>14
        IF (LN_3PM_DAY_TIME_CHECK>14 AND LN_NUMBER_OF_DAYS_CHECK=1) OR (LN_NUMBER_OF_DAYS_CHECK<1) THEN
       
          L_ERROR := SUBSTR(SQLERRM, 1, 1000);
          L_MSG   := L_MSG  ||' : 3PM Check, Cannot Assign Staff For Accomodation after 3 PM For Next Day or for Earlier Dates,please delete this entry and upload accommodation changes (only) for future dates other than: ' ||
                     REC.effective_date ;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, L_MSG);
         END IF; -- TIME CHECK
       END IF;
   END IF;
--      BEGIN
--        SELECT L.LOCATION_ID
--          INTO L_LOCATION_ID
--          FROM HR_LOCATIONS_ALL L
--         WHERE UPPER(TRIM(L.LOCATION_CODE)) = UPPER(TRIM(REC.attribute5 ));
--      EXCEPTION
--        WHEN OTHERS THEN
--          L_ERROR := SUBSTR(SQLERRM, 1, 1000);
--          L_MSG   := L_MSG  ||' : Error while fetching location details for : ' ||REC.attribute5 || ' - (Error : ' || L_ERROR || ')';
--        
--          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, L_MSG);
--          DBMS_OUTPUT.PUT_LINE(L_MSG);
--      END;
--    
--    END IF;
 
    --------------------------------------------------   Validate Employee is already in pending for Approval

    L_ERROR_CONTRACT := NULL;
    FOR XXTG_REC IN XXTG_CONT_CUR (REC.TG_ID, LN_HEADER_ID)
      LOOP
        L_ERROR_CONTRACT := XXTG_REC.HEADER_ID ;
      END LOOP; 
    IF  L_ERROR_CONTRACT  IS NOT NULL THEN
          L_MSG   := L_MSG  || ' : ' ||L_ERROR_CONTRACT||' : Contract Batch Exists in Approval or has TG ID with Contract Acceptance Pending ' ;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, L_MSG);
--          DBMS_OUTPUT.PUT_LINE(L_MSG);
          L_ERROR_CONTRACT := NULL;
    END IF;
    
    --------------------------------------------------   Validate Job null
--      INSERT INTO XXTG_TEST VALUES (' REC.NEW_JOB IS '||REC.NEW_JOB ||' LC_EXTERNAL_CLIENT '||LC_EXTERNAL_CLIENT ||' NEW JOB '||HR_GENERAL.DECODE_JOB (L_JOB_ID)||'L_JOB_ID'||L_JOB_ID);
    IF REC.NEW_JOB IS NULL AND LC_EXTERNAL_CLIENT='N' THEN
    
      UPDATE XXTG_CA_LINES_ALL 
      SET NEW_JOB = HR_GENERAL.DECODE_JOB (L_JOB_ID)
      WHERE CURRENT OF ALL_REC;
    
    
    END IF;
    --------------------------------------------------   Validate Job
    L_JOB_ID := NULL;
    IF  REC.NEW_JOB IS NOT NULL THEN
    
      BEGIN
        SELECT JOB_ID
          INTO L_JOB_ID
          FROM PER_JOBS PJ
         WHERE UPPER(TRIM(PJ.NAME)) = UPPER(TRIM(REC.NEW_JOB))
           AND PJ.BUSINESS_GROUP_ID = L_BG_ID;
      EXCEPTION
        WHEN OTHERS THEN
          L_ERROR := SUBSTR(SQLERRM, 1, 1000);
          L_MSG   := L_MSG  || ' : Error while fetching job details for : ' ||REC.NEW_JOB || ' - (Error : ' || L_ERROR || ')';
          L_JOB_ID:= NULL;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, L_MSG);
          DBMS_OUTPUT.PUT_LINE(L_MSG);
      END;
    END IF;

  
    --------------------------------------------------   Validate Roaster
    L_ROSTER_ID := NULL;
    IF  trim(REC.NEW_ROSTER) IS NOT NULL THEN
    
      BEGIN
        SELECT V.CHILD_ORG_ID
          INTO L_ROSTER_ID
          FROM TG_ORG_STRUCTURE_ALL_V V
         WHERE V.BUSINESS_GROUP_ID = L_BG_ID
           AND UPPER(TRIM(V.CHILD_ORG_NAME)) = UPPER(TRIM(REC.NEW_ROSTER))
           AND V.CHILD_ORG_TYPE = 'RSTR'
           AND V.PARENT_ORG_ID = L_CONTRACT_ID
           AND V.PARENT_ORG_TYPE = 'CNRT';
      
      EXCEPTION
        WHEN OTHERS THEN
          L_ERROR := SUBSTR(SQLERRM, 1, 1000);
          L_ROSTER_ID := NULL;
          L_MSG   := L_MSG  || ' : Error while fetching roaster details from organization hierarchy : ' || REC.NEW_ROSTER || ' - (Error : ' || L_ERROR || ')';
        
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, L_MSG);
          DBMS_OUTPUT.PUT_LINE(L_MSG);
      END;
    L_PPL_GRP_ID:= NULL;
      BEGIN
        SELECT PEOPLE_GROUP_ID
          INTO L_PPL_GRP_ID
          FROM PAY_PEOPLE_GROUPS PPG
         WHERE UPPER(TRIM(PPG.GROUP_NAME)) = UPPER(TRIM(REC.NEW_ROSTER));
      
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_PPL_GRP_ID := NULL; -- Only happened when roster is new and is not attached to any emp so far.
        WHEN OTHERS THEN
          L_ERROR := SUBSTR(SQLERRM, 1, 1000);
          L_MSG   := L_MSG  || ' :  Error while fetching roaster details for : ' ||REC.NEW_ROSTER || ' - (Error : ' || L_ERROR || ')';
          L_PPL_GRP_ID:= NULL;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, L_MSG);
          DBMS_OUTPUT.PUT_LINE(L_MSG);
      END;
    END IF;
    
    LN_DERIVED_NEW_BASIC_SALARY := NULL;

   IF REC.NEW_BASIC_SALARY IS NULL AND LC_EXTERNAL_CLIENT='N' AND   L_ASG_ID IS NOT NULL AND   L_BUSINESS_GROUP_ID IS NOT NULL  AND REC.EFFECTIVE_DATE  IS NOT NULL THEN
    
    FOR XXTG_SAL_REC IN XXTG_SAL_CUR (L_ASG_ID ,  L_BUSINESS_GROUP_ID, REC.EFFECTIVE_DATE)
      LOOP
        LN_DERIVED_NEW_BASIC_SALARY:= XXTG_SAL_REC.PROPOSED_SALARY_N;
      END LOOP;

      UPDATE XXTG_CA_LINES_ALL 
      SET NEW_BASIC_SALARY = LN_DERIVED_NEW_BASIC_SALARY
      WHERE CURRENT OF ALL_REC;
    
    
    END IF;
     LC_LINE_RISK:= NULL;
     LC_LINE_RISK:=  xxtg_ca_deployment_pkg.CONTRACT_AT_RISK (P_PERSON_ID =>L_PERSON_ID
                             ,P_BASIC =>REC.new_basic_salary
                             , P_HRA =>null
                             , P_TRA =>null
                             , P_ORGANIZATION    =>REC.new_contract_name
                             , P_JOB             =>REC.new_job
                             , P_ROSTER          =>REC.new_roster
                             , P_EFFECTIVE_DATE =>REC.effective_date
                             );
                             ---UPDATE LINE RISK

    
    LN_COR:= NULL;
    LN_HOURLY_COR := NULL;
    IF LC_BUSINESS_GROUP='Manpower and OutSource' THEN
      FOR XXTG_REC IN TG_COR_CUR 
                                (P_CONTRACT_ID  => L_CONTRACT_ID,
                                P_BASIC_SALARY => REC.NEW_BASIC_SALARY,
                                P_JOB_ID      => L_JOB_ID,
                                P_CAMP         =>REC.CAMP_NAME,
                                P_ROSTER_ID    =>L_ROSTER_ID,
                                P_DATE        => REC.EFFECTIVE_DATE )  
        LOOP
        LN_COR := XXTG_REC.MONTHLY_SERVICE_RATE  ;   
        LN_HOURLY_COR:= XXTG_REC.HOURLY_SERVICE_RATE  ;
        END LOOP;
    
    IF   LN_COR IS NULL AND  LN_HOURLY_COR IS NULL AND LC_EXTERNAL_CLIENT<>'N'  THEN
            L_MSG   := L_MSG  || ' : Charge Out Rate Does not Exist For Combination of Destination Contract, Roster, Job, Camp, Basic Salary ';
    END IF;
    
    END IF ; ---End of Check for Manpower and OutSource
--         IF LC_LINE_RISK IS NOT NULL THEN
--         UPDATE XXTG_CA_LINES_ALL 
--      SET ATTRIBUTE5 = LC_LINE_RISK
--      WHERE CURRENT OF ALL_REC;
--     END IF;
    UPDATE XXTG_CA_LINES_ALL
    SET 
      Validation_Message= NVL(substr(L_MSG,1,2000),'Y'), --Validation Message
      RISK_FLAG= LC_LINE_RISK,
      ATTRIBUTE5= LC_LINE_RISK,
      PERSON_ID = L_PERSON_ID,
      ASSIGNMENT_ID= L_ASG_ID
    WHERE CURRENT OF ALL_REC;
    IF L_MSG IS NULL THEN
      L_SUCCESS_COUNT := L_SUCCESS_COUNT + 1;
    ELSE 
     L_ERROR_COUNT   := L_ERROR_COUNT + 1; 
    END IF;
    L_TOTAL := L_TOTAL + 1;
  END LOOP;
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Summary : ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '----------');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Total Records : ' || L_TOTAL);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Success Count : ' || L_SUCCESS_COUNT);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error Count: ' || L_ERROR_COUNT);
  END VALIDATE_CONTRACT_BATCH; 
    PROCEDURE UPDATE_ADDR_FROM_CONTRACT
  ( P_CONTRACT_ID     VARCHAR,
    P_CAMP_NAME         VARCHAR2,
    P_CAMP_ROOM_NAME    VARCHAR2,
    P_ADDR_DEPLOYMENT_DATE  DATE  DEFAULT SYSDATE
--    P_CONTRACT_ACCEPTED VARCHAR2,
--    P_RESIGNED_DUE_TO_CONTRACT VARCHAR2,
--    P_CONTRACT_SIGNED_DATE     DATE  DEFAULT SYSDATE,
--    P_CONTRACT_STATUS       VARCHAR2 DEFAULT 'A-ACTIVE', --:='A-ACTIVE';
--    P_CONTRACT_REASON       VARCHAR2 DEFAULT 'PROCESSED', --:='PROPOSED';
--    P_CONTRACT_DOC_STATUS   VARCHAR2 DEFAULT 'PROCESSED',  --:='CREATED';
--    P_ASSIGNMENTS_CREATION_DATE DATE   DEFAULT SYSDATE
   )
   IS
   LD_CONTRACT_PRINT_DATE  VARCHAR2(20);
   LC_CONTRACT_PRINT_BY_STAFF VARCHAR2(240);
   LC_USER_NAME            VARCHAR2(240);
   LN_PERSON_ID            NUMBER := NULL;
   LC_REFERENCE            VARCHAR2(240) :=NULL;
   LN_OBJECT_VERSION_NUMBER NUMBER := NULL;
   LC_STATUS               VARCHAR2(20) := NULL;
   LC_CONTRACT_SIGNED_DATE    VARCHAR2(20);
   LC_TYPE                    VARCHAR2(24);
   LC_CONTRACT_STATUS         VARCHAR2(20);
   LC_ASSIGNMENT_FLAG_STATUS  VARCHAR2(240);
   LC_SAL_FLAG_STATUS         VARCHAR2(240);
   LC_CONTRACT_RECEIVED_DATE  VARCHAR2(240);
   LN_REQUEST_ID              NUMBER;
   CURSOR XXTG_USER_CUR (LN_USER_ID NUMBER) IS
   SELECT USER_NAME FROM FND_USER WHERE USER_ID = LN_USER_ID;
   
   CURSOR XXTG_CONT (LN_CONTRACT_ID VARCHAR2) IS
   SELECT PERSON_ID,CONTRACT_ID, REFERENCE, TYPE,OBJECT_VERSION_NUMBER,  STATUS
   , ATTRIBUTE15 CONTRACT_PRINT_DATE
   , ATTRIBUTE16 CONTRACT_PRINT_BY_STAFF 
   , ATTRIBUTE17 CONTRACT_RECEIVED_DATE
   FROM PER_CONTRACTS_F
   WHERE to_char(CONTRACT_ID) = LN_CONTRACT_ID ;
   
   BEGIN
   
   LN_PERSON_ID := NULL;
   LC_REFERENCE :=NULL;
   LN_OBJECT_VERSION_NUMBER := NULL;
   LC_STATUS := NULL;
--  LN_OBJECT_VERSION_NUMBER := P_OBJECT_VERSION_NUMBER;
   LD_EFFECTIVE_START_DATE  := NULL;
   LD_EFFECTIVE_END_DATE    := NULL;
   LC_CONTRACT_STATUS       := 'A-ACTIVE';
   
  FOR XXTG_CONT_REC IN XXTG_CONT (P_CONTRACT_ID)
    LOOP
      LN_PERSON_ID:= XXTG_CONT_REC.PERSON_ID;
      LC_REFERENCE:= XXTG_CONT_REC.REFERENCE;
      LN_OBJECT_VERSION_NUMBER:= XXTG_CONT_REC.OBJECT_VERSION_NUMBER;
      LC_STATUS:= XXTG_CONT_REC.STATUS;
      LC_TYPE  := XXTG_CONT_REC.TYPE;  --UNlimited Contract by Default
      LN_CONTRACT_ID :=XXTG_CONT_REC.CONTRACT_ID;
      LD_CONTRACT_PRINT_DATE :=XXTG_CONT_REC.CONTRACT_PRINT_DATE; --IN  VARCHAR2  DEFAULT hr_api.g_VARCHAR2
      LC_CONTRACT_PRINT_BY_STAFF :=XXTG_CONT_REC.CONTRACT_PRINT_BY_STAFF;
      LC_CONTRACT_RECEIVED_DATE :=XXTG_CONT_REC.CONTRACT_RECEIVED_DATE;
    END LOOP; 
     IF LC_CONTRACT_RECEIVED_DATE IS NULL THEN 
         BEGIN
        
               ln_request_id := fnd_request.submit_request ( 
                                    application   => 'TGCUST', 
                                    program       => 'XXTG_UPDATE_CONTRACT_ADDRESS', 
                                    description   => 'Update Contract Address', 
                                    start_time    => sysdate, 
                                    sub_request   => FALSE,
                                    argument1     => P_CONTRACT_ID,
                                    argument2     => P_CAMP_NAME,
                                    argument3     => P_CAMP_ROOM_NAME,
                                    argument4     => P_ADDR_DEPLOYMENT_DATE
--                                    argument5     => P_CONTRACT_STATUS,
--                                    argument6     => P_CONTRACT_REASON,
--                                    argument7     => P_CONTRACT_DOC_STATUS,
--                                    argument8     => P_ASSIGNMENTS_CREATION_DATE
          );
        
          IF ln_request_id = 0
          THEN
          fnd_file.put_line(fnd_file.LOG,'Concurrent request failed to submit');
          ELSE
          fnd_file.put_line(fnd_file.LOG,'Successfully Submitted the Concurrent Request');
          END IF;
 
        EXCEPTION
        WHEN OTHERS THEN
          fnd_file.put_line(fnd_file.LOG,'Error While Submitting Concurrent Request '||TO_CHAR(SQLCODE)||'-'||sqlerrm);
        END;
     END IF; 

  COMMIT;
 
  END UPDATE_ADDR_FROM_CONTRACT;
  PROCEDURE UPDATE_FOREIGN_KEY (P_CONTRACT_BATCH varchar2) IS
  CURSOR LINES_CUR IS SELECT HEADER_ID, LINE_ID, SNO FROM XXTG_CA_LINES_ALL 
  WHERE HEADER_ID IS NULL FOR UPDATE OF HEADER_ID;
  CURSOR LINES_ELE_CUR IS SELECT HEADER_ID, LINE_ID,SNO FROM XXTG_CA_LINES_ELE_ALL 
  WHERE HEADER_ID IS NULL AND LINE_ID IS NULL FOR UPDATE OF HEADER_ID, LINE_ID;
  BEGIN
  FOR LINES_REC IN LINES_CUR
    LOOP
  UPDATE XXTG_CA_LINES_ALL SET HEADER_ID = TO_NUMBER(P_CONTRACT_BATCH)
  WHERE CURRENT OF LINES_CUR;
  FOR LINES_ELE_REC IN LINES_ELE_CUR
    LOOP
    IF LINES_ELE_REC.SNO =LINES_REC.SNO THEN
      UPDATE XXTG_CA_LINES_ELE_ALL SET HEADER_ID = TO_NUMBER(P_CONTRACT_BATCH)
      , LINE_ID = LINES_REC.LINE_ID
      WHERE CURRENT OF LINES_ELE_CUR;
    END IF;
    END LOOP;
  END LOOP;
  END UPDATE_FOREIGN_KEY;
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
  PROCEDURE GET_TG_ID_IN_APPROVAL (p_header_id IN NUMBER  , p_tg_id_in_approval OUT VARCHAR2) IS
    CURSOR XXTG_TG_ID_APPROVAL_CUR (LN_HEADER_ID NUMBER) IS  select  listagg(( HEADER_ID  ||' Batch with TG ID ' ||tg_id),' ') within group (order by to_number(tg_id)) TG_ID
    from xxtg_ca_lines_all
    where tg_id  in (select TG_ID from xxtg_ca_lines_all where header_id  = LN_HEADER_ID) -- LC_TG_ID --'063851'
    AND HEADER_ID <>LN_HEADER_ID
    AND HEADER_ID NOT IN (select header_id from xxtg_ca_headers_all
    WHERE 
--    CLOSED_DATE IS NOT NULL OR   bug fixed
    CANCEL_FLAG='Y'  OR approval_status IN ( 'Draft', 'Rejected' ))
    AND 
   ( header_id in (select header_id from xxtg_ca_headers_all where approval_status= 'In Approval Process')--NVL(approval_status,'Draft') IN ('In Approval Process','Draft'))
    OR 
    (
    header_id in (select header_id from xxtg_ca_headers_all where approval_status= 'Approved  Sent')
    AND
     (contract_id IS NULL OR TO_NUMBER(contract_id) IN  (SELECT CONTRACT_ID FROM PER_CONTRACTS_F WHERE ATTRIBUTE20 IS NULL))
    )
    )
  HAVING listagg(( HEADER_ID  ||' Batch with TG ID ' ||tg_id),'|') within group (order by to_number(tg_id)) IS NOT NULL;
  BEGIN
    FOR XXTG_REC IN XXTG_TG_ID_APPROVAL_CUR(p_header_id)
      LOOP
        p_tg_id_in_approval:= XXTG_REC.TG_ID;
      END LOOP;
  END;
  FUNCTION Get_Batch_Risk
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 
        IS
LC_RISK VARCHAR2(1):= 'N';
cursor xxtg_line_cur (ln_header_id number)
is 
select header_id, person_id, effective_date, new_contract_name, new_job,new_roster, new_basic_salary from xxtg_ca_lines_all where header_id = ln_header_id;
BEGIN
  LC_RISK := 'N';
BEGIN
 FOR XXTG_REC IN xxtg_line_cur (p_transaction_id)
  LOOP
 LC_RISK:=  xxtg_ca_deployment_pkg.CONTRACT_AT_RISK (P_PERSON_ID =>XXTG_REC.person_id
                             ,P_BASIC =>XXTG_REC.new_basic_salary
                             , P_HRA =>null
                             , P_TRA =>null
                             , P_ORGANIZATION    =>XXTG_REC.new_contract_name
                             , P_JOB             =>XXTG_REC.new_job
                             , P_ROSTER          =>XXTG_REC.new_roster
                             , P_EFFECTIVE_DATE =>XXTG_REC.effective_date
                             );
  EXIT WHEN LC_RISK = 'Y';
  END LOOP;



   exception
   when others then
       raise;
   end;
   RETURN (LC_RISK);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
end Get_Batch_Risk;
FUNCTION GET_BATCH_BAS_SAL_CHG_STATUS(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 
        IS
CURSOR XXTG_CA_LINES_CUR (LN_HEADER_ID NUMBER)
IS 
SELECT   
    NVL(TO_NUMBER(DECODE (XCL.ASSIGNMENT_ID,NULL,0,
  (select PPP.PROPOSED_SALARY_N from PER_PAY_PROPOSALS PPP
where PPP.assignment_id = XCL.ASSIGNMENT_ID
AND XCL.EFFECTIVE_DATE BETWEEN  PPP.change_date AND PPP.DATE_TO
   ))),0) - NVL(XCL.NEW_BASIC_SALARY,0) SAL_CHANGE_VALUE
FROM XXTG_CA_LINES_ALL  XCL
WHERE XCL.HEADER_ID = LN_HEADER_ID;
LC_SALARY_CHANGE VARCHAR2(1) :='N';
BEGIN
LC_SALARY_CHANGE  :='N';
FOR XXTG_CA_REC IN  XXTG_CA_LINES_CUR (p_transaction_id)
  LOOP
    IF XXTG_CA_REC.SAL_CHANGE_VALUE<>0 THEN 
      LC_SALARY_CHANGE  :='Y';
    END IF;
    EXIT WHEN LC_SALARY_CHANGE = 'Y';  
  END LOOP;
  RETURN (LC_SALARY_CHANGE);
END GET_BATCH_BAS_SAL_CHG_STATUS;
   PROCEDURE DELETE_ORPHAN_RECORDS(
   ERRBUF        OUT VARCHAR2,
   RETCODE       OUT VARCHAR2)
   IS 
   CURSOR XXTG_ELE_CUR IS
       SELECT COUNT(1) count FROM XXTG_CA_LINES_ELE_ALL WHERE HEADER_ID IS NULL OR LINE_ID IS NULL;
   CURSOR XXTG_CUR IS
       SELECT COUNT(1) count FROM XXTG_CA_LINES_ALL WHERE HEADER_ID IS NULL;

   BEGIN
      FOR XXTG_ELE_REC IN XXTG_ELE_CUR
        LOOP
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Count of Element Lines Orphan Rows Deleted: ' || XXTG_ELE_REC.count);
          fnd_file.put_line(fnd_file.LOG    ,'Count of Element Lines Orphan Rows Deleted: ' || XXTG_ELE_REC.count);
        END LOOP;
      FOR XXTG_REC IN XXTG_CUR
        LOOP
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Count of Lines Orphan Rows Deleted: ' || XXTG_REC.count);
          fnd_file.put_line(fnd_file.LOG    ,'Count of Lines Orphan Rows Deleted: ' || XXTG_REC.count);
        END LOOP;
     DELETE FROM XXTG_CA_LINES_ELE_ALL WHERE HEADER_ID IS NULL OR LINE_ID IS NULL;
     DELETE FROM XXTG_CA_LINES_ALL WHERE HEADER_ID IS NULL;
     COMMIT;
   END DELETE_ORPHAN_RECORDS;
  END XXTG_CA_DEPLOYMENT_PKG;
/
