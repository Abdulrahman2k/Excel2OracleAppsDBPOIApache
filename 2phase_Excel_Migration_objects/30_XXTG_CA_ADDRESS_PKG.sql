SET DEFINE OFF;
CREATE OR REPLACE PACKAGE XXTG_CA_ADDRESS_PKG AS 
/* Created by Abdulrahman V2.0 17-Jul02017
 This Package is used for Version 2 of the Deployment Module catering Exclusively for Address Update */ 
 /* This Function is called from inside AME XXTGPL*/
 FUNCTION GET_BATCH_ADDRESS_CHG_STATUS(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)  return varchar2 ;
     procedure XXTG_ADDRESS_CHANGE_EXISTS(  itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       out NOCOPY varchar2
                                 );
     procedure XXTG_DEPLOYMENT_CHANGE_EXISTS(  itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       out NOCOPY varchar2);
  FUNCTION GET_ACCOMODATION_TYPE (P_ACCOMODATION_NAME VARCHAR) RETURN VARCHAR2;
   PROCEDURE update_add_approved_status(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) ;
   PROCEDURE update_add_rejected_status(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2);
   PROCEDURE workflow_automatic_add_update(itemtype        in varchar2,
                            itemkey         in varchar2 ,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2
                            );
   -- ------- ----------- --------------- ------------------------------------
-- Procedure for Primary Address Update used for udpating camp and room from OAF Page
--************************************************************************
  PROCEDURE PRIMARY_ADDRESS_UPDATE(
    ERRBUF        OUT VARCHAR2,
    RETCODE       OUT VARCHAR2,
    P_LINE_ID          NUMBER,  
    P_CAMP_NAME        VARCHAR2 ,            
    P_CAMP_ROOM_NO     VARCHAR2 , 
    P_EFFECTIVE_DATE   DATE,    
    P_TRANSPORT_REQUESTED           VARCHAR2);
--P_ADDRESS_ID OUT NUMBER );
 PROCEDURE PRIMARY_ADDRESS_UPDATE_WRAPPER
  ( P_LINE_ID     NUMBER,
    P_CAMP_NAME         VARCHAR2,
    P_ADDR_DEPLOYMENT_DATE  DATE  DEFAULT SYSDATE,  --P_EFFECTIVE_DATE
    P_CAMP_ROOM_NO    VARCHAR2,
    P_TRANSPORT_REQUESTED           VARCHAR2
   );
  PROCEDURE  SUBMIT_PRINT_REQUEST (P_CONTRACT_BATCH varchar2, P_REQUEST_ID OUT varchar2) ;
END XXTG_CA_ADDRESS_PKG;
/


CREATE OR REPLACE PACKAGE BODY XXTG_CA_ADDRESS_PKG AS 
/* Created by Abdulrahman V2.0 17-Jul02017
 This Package is used for Version 2 of the Deployment Module catering Exclusively for Address Update */ 
  LD_EFFECTIVE_START_DATE DATE;
  LD_EFFECTIVE_END_DATE DATE;
    LN_CONTRACT_ID NUMBER;
    /* This Function is called from inside AME XXTGPL*/
FUNCTION GET_BATCH_ADDRESS_CHG_STATUS(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)

        return varchar2 
        IS
                          CURSOR XXTG_ADDRESS_CHANGE_CUR (LN_TRANACTION_ID NUMBER)
                          IS 
                          SELECT  COUNT(1) COUNT 
                          FROM  PER_ADDRESSES pa, XXTG_CA_LINES_ALL XCLA
                          where pa.person_Id =XCLA.PERSON_ID
                          AND XCLA.EFFECTIVE_DATE between pa.date_from and nvl(pa.date_to,fnd_conc_date.string_to_date('31-Mar-3172'))
                          AND 
                          TRIM(UPPER( hr_general.DECODE_FND_COMM_LOOKUP (p_lookup_type =>'TG_CAMP_NAME',
                                                        p_lookup_code=>pa.add_information20 ))) <>  TRIM(UPPER( XCLA.CAMP_NAME))
                          AND XCLA.HEADER_ID = LN_TRANACTION_ID;
                          LN_ITEMKEY            NUMBER;
                          LN_ADDRESS_DIFF_COUNT NUMBER;
LC_ADDRESS_CHANGE_EXISTS VARCHAR2(1) :='N';
BEGIN
LC_ADDRESS_CHANGE_EXISTS  :='N';
FOR XXTG_CA_REC IN  XXTG_ADDRESS_CHANGE_CUR (p_transaction_id)
  LOOP
    IF XXTG_CA_REC.count<>0 THEN 
      LC_ADDRESS_CHANGE_EXISTS  :='Y';
    END IF;
    EXIT WHEN LC_ADDRESS_CHANGE_EXISTS = 'Y';  
  END LOOP;
  RETURN (LC_ADDRESS_CHANGE_EXISTS);
exception
      when others then
      null;
        -- The line below records this function call in the error
        -- system in the case of an exception.
       
       
--        begin
--         resultout:='COMPLETE:'||'N';
--         return;
--         end;
  END GET_BATCH_ADDRESS_CHG_STATUS;       
     procedure XXTG_ADDRESS_CHANGE_EXISTS(  itemtype        in varchar2,
                                 itemkey         in varchar2 ,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       out NOCOPY varchar2
                                 )
                                 /* This procedure used in workflow for decision on whether there are changes in address for the batch
                                    based on this yes/no information, if yes we send the notification for approval to P&L Team
                                    else we process the batch as usual*/
                    
                                 is 
                          CURSOR XXTG_ADDRESS_CHANGE_CUR (LN_TRANACTION_ID NUMBER)
                          IS 
                          SELECT  COUNT(1) COUNT 
                          FROM  PER_ADDRESSES pa, XXTG_CA_LINES_ALL XCLA
                          where pa.person_Id =XCLA.PERSON_ID
                          AND XCLA.EFFECTIVE_DATE between pa.date_from and nvl(pa.date_to,fnd_conc_date.string_to_date('31-Mar-3172'))
                          AND 
                          TRIM(UPPER( hr_general.DECODE_FND_COMM_LOOKUP (p_lookup_type =>'TG_CAMP_NAME',
                                                        p_lookup_code=>pa.add_information20 ))) <>  TRIM(UPPER( XCLA.CAMP_NAME))
                          AND XCLA.HEADER_ID = LN_TRANACTION_ID;
                          LN_ITEMKEY            NUMBER;
                          LN_ADDRESS_DIFF_COUNT NUMBER;
                          LC_ADDRESS_CHANGE_EXISTS VARCHAR2(1):='N';
     BEGIN
--       LN_ITEMKEY:= TO_NUMBER(wf_engine.getItemAttrText( itemtype =>  itemtype,
--                                                         itemkey  => itemkey,
--                                                         aname    => 'HEADER_ID' ));
     LN_ITEMKEY := TO_number(itemkey);

      LN_ADDRESS_DIFF_COUNT:=0;
     FOR XXTG_REC IN XXTG_ADDRESS_CHANGE_CUR(LN_ITEMKEY)
       LOOP
         LN_ADDRESS_DIFF_COUNT:=XXTG_REC.COUNT;
--insert into xxtg_test values(' LN_ADDRESS_DIFF_COUNT is '||LN_ADDRESS_DIFF_COUNT);
       END LOOP;
     if (LN_ADDRESS_DIFF_COUNT=0) then
         resultout:='COMPLETE:'||'N';
         LC_ADDRESS_CHANGE_EXISTS :='N';
         UPDATE xxtg_ca_headers_all
         SET CHANGE_IN_ADD_FLAG='N',
          ADDRESS_APPROVAL_STATUS ='NA'
          WHERE HEADER_ID = LN_ITEMKEY;
      elsif (LN_ADDRESS_DIFF_COUNT > 0)  then
         resultout:='COMPLETE:'||'Y';
         LC_ADDRESS_CHANGE_EXISTS :='Y';
         UPDATE xxtg_ca_headers_all
         SET CHANGE_IN_ADD_FLAG='Y'
--          ADDRESS_APPROVAL_STATUS ='NA'
          WHERE HEADER_ID = LN_ITEMKEY;
      else 
              resultout:='COMPLETE:'||'N'; 
              LC_ADDRESS_CHANGE_EXISTS :='N';
        UPDATE xxtg_ca_headers_all
         SET CHANGE_IN_ADD_FLAG='N',
          ADDRESS_APPROVAL_STATUS ='NA'
          WHERE HEADER_ID = LN_ITEMKEY;
      end if;
--      insert into xxtg_test values (' LC_ADDRESS_CHANGE_EXISTS is '||LC_ADDRESS_CHANGE_EXISTS);
            wf_engine.SetItemAttrText( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'XXTG_ADDRESS_CHANGE_EXISTS' ,
                                  avalue     => LC_ADDRESS_CHANGE_EXISTS);
               return;

 
    exception
      when others then
      null;
        -- The line below records this function call in the error
        -- system in the case of an exception.
       
       
        begin
         resultout:='COMPLETE:'||'N';
         return;
         end;
  END XXTG_ADDRESS_CHANGE_EXISTS;
     PROCEDURE XXTG_DEPLOYMENT_CHANGE_EXISTS(  itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       out NOCOPY varchar2)
                                 /* This procedure used in workflow for decision on whether there are changes in address for the batch
                                    based on this yes/no information, if yes we send the notification for approval to P&L Team
                                    else we process the batch as usual*/
                    
                                 is 
                          CURSOR XXTG_DEP_CHANGE_CUR (LN_TRANACTION_ID NUMBER)
                          IS 
                          SELECT  COUNT(1) COUNT 
                          FROM   XXTG_CA_LINES_ALL XCLA
                          WHERE
                          (NEW_CONTRACT_NAME IS NOT NULL
                          OR NEW_JOB IS NOT NULL
                          OR NEW_ROSTER IS NOT NULL
                          OR  NEW_BASIC_SALARY IS NOT NULL
                          )
                          AND XCLA.HEADER_ID = LN_TRANACTION_ID;
                          LN_ITEMKEY            NUMBER;
                          LN_DEPLOYMENT_DIFF_COUNT NUMBER;
                          LC_DEPLOYMENT_CHANGE_EXISTS VARCHAR2(1):='N';
     BEGIN
       LN_ITEMKEY:= TO_NUMBER(wf_engine.getItemAttrText( itemtype =>  itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'HEADER_ID' ));
--     LN_ITEMKEY := TO_number(itemkey);
     FOR XXTG_REC IN XXTG_DEP_CHANGE_CUR(LN_ITEMKEY)
       LOOP
         LN_DEPLOYMENT_DIFF_COUNT:=XXTG_REC.COUNT;
       END LOOP;
     if (LN_DEPLOYMENT_DIFF_COUNT=0) then
         resultout:='COMPLETE:'||'N';
         LC_DEPLOYMENT_CHANGE_EXISTS :='N';
         UPDATE xxtg_ca_headers_all
         SET CHANGE_IN_DEP_FLAG='N',
          APPROVAL_STATUS ='NA'
          WHERE HEADER_ID = LN_ITEMKEY;
--         return;
      elsif (LN_DEPLOYMENT_DIFF_COUNT > 0)  then
         resultout:='COMPLETE:'||'Y';
         LC_DEPLOYMENT_CHANGE_EXISTS :='Y';
        UPDATE xxtg_ca_headers_all
         SET CHANGE_IN_DEP_FLAG='Y'
        WHERE HEADER_ID = LN_ITEMKEY;
--         return;
      else 
              resultout:='COMPLETE:'||'N'; 
              LC_DEPLOYMENT_CHANGE_EXISTS :='N';
--               return;
         UPDATE xxtg_ca_headers_all
         SET CHANGE_IN_DEP_FLAG='N',
          APPROVAL_STATUS ='NA'
          WHERE HEADER_ID = LN_ITEMKEY;
      end if;
            wf_engine.SetItemAttrText( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'XXTG_DEPLOYMENT_CHANGE_EXISTS' ,
                                  avalue     => LC_DEPLOYMENT_CHANGE_EXISTS);
               return;
    exception
      when others then
        -- The line below records this function call in the error
        -- system in the case of an exception.
--        wf_core.context('XXTG_AME_APPROVAL_PKG',
--                        'getNextApprover',
--                        itemtype,
--                        itemkey,
--                        to_char(actid),
--                        funcmode);
--        raise;
        begin
         resultout:='COMPLETE:'||'N';
         return;
         end;
  END  XXTG_DEPLOYMENT_CHANGE_EXISTS;
  FUNCTION GET_ACCOMODATION_TYPE (P_ACCOMODATION_NAME VARCHAR) RETURN VARCHAR2
  IS 
  CURSOR XXTG_ACC_CUR (LC_ACC_NAME VARCHAR2)IS
  select MEANING Accommodation, hr_general.DECODE_LOOKUP('TG_CAMP_CLASSIFICATION',ATTRIBUTE4) TYPE
    from fnd_common_lookups
    where lookup_type='TG_CAMP_NAME' and enabled_flag='Y'
    AND UPPER(TRIM(MEANING)) = UPPER(TRIM(LC_ACC_NAME));
    LC_ACC_TYPE   VARCHAR2(240);
  BEGIN
    LC_ACC_TYPE:= NULL;
    FOR XXTG_REC IN XXTG_ACC_CUR (P_ACCOMODATION_NAME)
      LOOP
        LC_ACC_TYPE:=XXTG_REC.TYPE;
      END LOOP;
      RETURN LC_ACC_TYPE;
  END GET_ACCOMODATION_TYPE;
   PROCEDURE update_add_approved_status(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) 
   IS
       l_transaction_id  NUMBER;
       CURSOR XXTG_REQUESTOR_EMAIL_CUR (LN_TRANSACTION_ID NUMBER)
       IS 
       SELECT DISTINCT PAPF.EMAIL_ADDRESS EMAIL_ADDRESS FROM xxtg_ca_headers_all XCHA, PER_ALL_PEOPLE_F PAPF, FND_USER FU
        WHERE  XCHA.CREATED_BY = FU.USER_ID
        AND PAPF.PERSON_ID = FU.EMPLOYEE_ID
        AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
        AND XCHA.HEADER_ID = LN_TRANSACTION_ID;
       CURSOR XXTG_LINE_CUR (LN_TRANSACTION_ID NUMBER)
       IS 
       SELECT 
      HEADER_ID                       	,
      TG_ID                	,
      EFFECTIVE_DATE           	,
      NEW_CONTRACT_NAME         	,
      NEW_JOB                   	,
      NEW_ROSTER                	,
      NEW_BASIC_SALARY                	,
      ATTRIBUTE5               ,
      CONTRACT_ID,
      CAMP_NAME           ,
      CAMP_ROOM_NAME      ,
      RISK_FLAG
      FROM XXTG_CA_LINES_ALL 
      WHERE HEADER_ID = LN_TRANSACTION_ID
      FOR UPDATE OF CONTRACT_ID;
      LC_EMAIL  VARCHAR2(240);
      LN_CONTRACT_ID NUMBER;
      lc_request_id    varchar2(240);
   BEGIN
       l_transaction_id:= TO_NUMBER(wf_engine.getItemAttrText( itemtype =>  itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'HEADER_ID' ));
      LC_EMAIL :=NULL;
--      FOR XXTG_EMAIL_REC IN  XXTG_REQUESTOR_EMAIL_CUR(l_transaction_id)
--         LOOP
--           LC_EMAIL := XXTG_EMAIL_REC.EMAIL_ADDRESS;
--         END LOOP;
--      FOR XXTG_REC IN  XXTG_LINE_CUR(l_transaction_id)
--        LOOP
--        LN_CONTRACT_ID :=NULL;
--        XXTG_CA_DEPLOYMENT_PKG.XXTG_CONTRACT
--  ( P_ORGANIZATION =>  XXTG_REC.NEW_CONTRACT_NAME,  -- VARCHAR2,
--    P_JOB          => XXTG_REC.NEW_JOB,  -- VARCHAR2,
--    P_ROSTER        => XXTG_REC.NEW_ROSTER,  -- VARCHAR2,
--    P_BASIC        => XXTG_REC.NEW_BASIC_SALARY,  --   NUMBER,
--    P_HRA            =>NULL,
--    P_TRA            =>NULL, 
--    P_RISK           => XXTG_REC.RISK_FLAG,
--    P_CAMP           =>XXTG_REC.CAMP_NAME,
--    P_ROOM           =>XXTG_REC.CAMP_ROOM_NAME,
--    P_CONTRACT_BATCH  => XXTG_REC.HEADER_ID,  --VARCHAR2,
--    P_EFFECTIVE_START_DATE => XXTG_REC.EFFECTIVE_DATE,  -- DATE,
--    P_OPERATIONS_MGR_PERSON  => LC_EMAIL,  --VARCHAR2,
--    P_TG_ID               => XXTG_REC.TG_ID,  -- VARCHAR2,
--    P_EMP_CONTRACT_ID       => LN_CONTRACT_ID ); --  OUT   NUMBER);
--
--    UPDATE XXTG_CA_LINES_ALL
--    SET CONTRACT_ID= LN_CONTRACT_ID
--    WHERE CURRENT OF XXTG_LINE_CUR ; --ROWID = XXTG_REC.ROW_ID; --
--    END LOOP;
        UPDATE xxtg_ca_headers_all 
        SET 
        CHANGE_IN_ADD_APPROVAL_FLAG  ='Y', --ATTRIBUTE15='Y', 
        CHANGE_IN_ADD_FLAG='Y', -- ATTRIBUTE14='Y'   
        ADDRESS_APPROVAL_STATUS      ='P&L Approved',
--        APPROVED_FLAG='Y',
        ADDRESS_APPROVED_DATE = SYSDATE
--        CLOSED_DATE = SYSDATE,
----        APPROVAL_REQUIRED_FLAG ='N',
--        AME_TRANSACTION_TYPE ='XXTGCA',
--        AME_APPROVAL_ID = l_transaction_id
        WHERE HEADER_ID = l_transaction_id;
                    wf_engine.setitemattrtext(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'XXTG_ADD_BATCH_STATUS',
                                avalue => 'APPROVED'
                                );
       
        XXTG_CA_ADDRESS_PKG.SUBMIT_PRINT_REQUEST (P_CONTRACT_BATCH=>TO_CHAR(l_transaction_id) , P_REQUEST_ID=>lc_request_id) ;
--
--        fnd_file.put_line(fnd_file.log,'Request ID of Print Batch is '||lc_request_id);
   END update_add_approved_status;
   PROCEDURE update_add_rejected_status(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) 
   IS
   l_transaction_id  NUMBER;
   BEGIN
       l_transaction_id:= TO_NUMBER(wf_engine.getItemAttrText( itemtype =>  itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'HEADER_ID' ));
 
UPDATE xxtg_ca_headers_all 
SET     CHANGE_IN_ADD_APPROVAL_FLAG  ='N', --ATTRIBUTE15='N',
        CHANGE_IN_ADD_FLAG='Y', -- ATTRIBUTE14='Y'
        ADDRESS_APPROVAL_STATUS      ='P&L Rejected'
--APPROVED_FLAG='N',
--APPROVAL_REQUIRED_FLAG ='Y',
--AME_TRANSACTION_TYPE ='XXTGCA',
--AME_APPROVAL_ID = l_transaction_id
WHERE HEADER_ID = l_transaction_id;
             wf_engine.setitemattrtext(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'XXTG_ADD_BATCH_STATUS',
                                avalue => 'REJECTED'
                                );
   END update_add_rejected_status;
   PROCEDURE WORKFLOW_AUTOMATIC_ADD_UPDATE(itemtype        in varchar2 ,
                            itemkey         in varchar2 ,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2
                            )
   is
   CURSOR XXTG_ADD_CUR (LN_HEADER_ID NUMBER) 
   IS 
    SELECT NVL(XCLA.ADDR_DEPLOYMENT_DATE,XCLA.EFFECTIVE_DATE)  EFFECTIVE_DATE,  XCLA.LINE_ID, XCLA.CAMP_ROOM_NAME, XCLA.CAMP_NAME NEW_ACCOMMODATION_ADDRESS , PER.EXISTING_ADDRESS , XCLA.TRANSPORT_REQUESTED FROM XXTG_CA_LINES_ALL  XCLA
    ,(SELECT PERSON_ID, hr_general.DECODE_LOOKUP('TG_CAMP_NAME',ADD_INFORMATION20) EXISTING_ADDRESS , XXTG_CA_ADDRESS_PKG.GET_ACCOMODATION_TYPE (hr_general.DECODE_LOOKUP('TG_CAMP_NAME',ADD_INFORMATION20)) EXISTING_ACC_TYPE  from per_addresses 
    WHERE sysdate between date_from and nvl(date_to,to_date('31-DEC-4712'))) PER
    WHERE PER.PERSON_ID = XCLA.PERSON_ID
    AND XXTG_CA_ADDRESS_PKG.GET_ACCOMODATION_TYPE (XCLA.CAMP_NAME) ='Client Accommodation'
    AND PER.EXISTING_ACC_TYPE = 'Client Accommodation'
    AND XCLA.ADDRESS_ID IS  NULL
    AND XCLA.HEADER_ID = LN_HEADER_ID;
    LN_HEADER_ID  NUMBER;
   BEGIN
   LN_HEADER_ID := NULL;
   LN_HEADER_ID := TO_NUMBER(wf_engine.getItemAttrText( itemtype =>  itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'HEADER_ID' ));
  apps.fnd_global.apps_initialize (user_id=>1677,resp_id=>50866,resp_appl_id=>800);
   dbms_session.set_nls ('nls_date_format','''DD-MON-RR''');
    FOR XXTG_REC IN XXTG_ADD_CUR (LN_HEADER_ID ) 
      LOOP 
        XXTG_CA_ADDRESS_PKG.PRIMARY_ADDRESS_UPDATE_WRAPPER
  ( P_LINE_ID   =>  XXTG_REC.LINE_ID ,
    P_CAMP_NAME   =>  XXTG_REC.NEW_ACCOMMODATION_ADDRESS ,
    P_ADDR_DEPLOYMENT_DATE  =>  XXTG_REC.EFFECTIVE_DATE ,  --P_EFFECTIVE_DATE
    P_CAMP_ROOM_NO  =>  XXTG_REC.CAMP_ROOM_NAME ,
    P_TRANSPORT_REQUESTED     =>  XXTG_REC.TRANSPORT_REQUESTED
    );
      END LOOP;
   END workflow_automatic_add_update;
-- ------- ----------- --------------- ------------------------------------
-- Procedure for Primary Address Update used for udpating camp and room from Concurrent Program
--************************************************************************ 
--PROCEDURE PRIMARY_ADDRESS_UPDATE(
--P_LINE_ID          NUMBER,
--P_CAMP_NAME        VARCHAR2 ,            
--P_EFFECTIVE_DATE   DATE,    --- ADDR_DEPLOYMENT_DATE          DATE         
--P_CAMP_ROOM_NO          VARCHAR2 , 
--P_TRANSPORT_REQUESTED           VARCHAR2
----,P_ADDRESS_ID OUT NUMBER 
--)
--IS
--BEGIN
-- ------- ----------- --------------- ------------------------------------
-- Procedure for Primary Address Update used for udpating camp and room from OAF Page
--************************************************************************
  PROCEDURE PRIMARY_ADDRESS_UPDATE(
    ERRBUF        OUT VARCHAR2,
    RETCODE       OUT VARCHAR2,
    P_LINE_ID          NUMBER,  
    P_CAMP_NAME        VARCHAR2 ,            
    P_CAMP_ROOM_NO     VARCHAR2 , 
    P_EFFECTIVE_DATE   DATE,    
    P_TRANSPORT_REQUESTED           VARCHAR2
)
--CAMP_NAME                     VARCHAR2(240)  
--CAMP_ROOM_NAME                VARCHAR2(240)  
--ADDRESS_ID                    NUMBER         
--ADDR_DEPLOYMENT_DATE          DATE           
--TRANSPORT_REQUESTED           VARCHAR2(1)
IS
  P_ADDRESS_ID NUMBER ;
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
                    'Fujairah',7,
                    2) EMIRATE_CODE,
                c.LOOKUP_CODE CAMP_LOOKUP_CODE
--             ,
--             c.MEANING
        from    fnd_common_lookups  c
        where   c.LOOKUP_TYPE = 'TG_CAMP_NAME'
        and upper(trim(c.MEANING))= upper(trim(LC_CAMP_NAME )) ; 
        CURSOR XXTG_CA_ADD_CUR (LN_LINE_ID NUMBER)
        IS SELECT TG_ID FROM XXTG_CA_LINES_ALL WHERE LINE_ID = LN_LINE_ID and ADDRESS_ID is null
        FOR UPDATE OF ADDRESS_ID,ADDR_DEPLOYMENT_DATE,TRANSPORT_REQUESTED,CAMP_NAME, CAMP_ROOM_NAME;
        LC_EMPLOYEE_NUMBER  VARCHAR2(40);
  BEGIN
   FOR XXTG_REC IN XXTG_CA_ADD_CUR (P_LINE_ID )
     LOOP
       LC_EMPLOYEE_NUMBER := XXTG_REC.TG_ID;

    for rec in get_rec(
                       LC_EMPLOYEE_NUMBER    
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
            fnd_file.put_line(fnd_file.LOG,'~' || 'END' || '~' ||
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
          fnd_file.put_line(fnd_file.LOG,'~' || 'START' || '~' ||
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
           LC_EMPLOYEE_NUMBER, --rec.employee_number,
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
           LC_EMPLOYEE_NUMBER, --rec.employee_number,
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
      UPDATE xxtg_ca_lines_all
      SET 
      TRANSPORT_REQUESTED = P_TRANSPORT_REQUESTED,
      ADDRESS_ID  =   v_Address_id      ,
       ADDR_DEPLOYMENT_DATE =v_effective_date
      WHERE      CURRENT OF XXTG_CA_ADD_CUR;
    END LOOP;
  COMMIT;
    P_ADDRESS_ID:= NVL(v_Address_id,0);
  END PRIMARY_ADDRESS_UPDATE;  
    PROCEDURE PRIMARY_ADDRESS_UPDATE_WRAPPER
  ( P_LINE_ID     NUMBER,
    P_CAMP_NAME         VARCHAR2,
    P_ADDR_DEPLOYMENT_DATE  DATE  DEFAULT SYSDATE,  --P_EFFECTIVE_DATE
    P_CAMP_ROOM_NO    VARCHAR2,
    P_TRANSPORT_REQUESTED           VARCHAR2
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
   LN_ADDRESS_ID              NUMBER;
   CURSOR XXTG_USER_CUR (LN_USER_ID NUMBER) IS
   SELECT USER_NAME FROM FND_USER WHERE USER_ID = LN_USER_ID;
   
   CURSOR XXTG_CONT (LN_LINE_ID NUMBER) IS
SELECT PERSON_ID,
  ADDRESS_ID,
  CAMP_NAME,
  CAMP_ROOM_NAME
FROM XXTG_CA_LINES_ALL
WHERE LINE_ID = LN_LINE_ID ;
   
   BEGIN
   
   LN_PERSON_ID := NULL;
   LC_REFERENCE :=NULL;
   LN_OBJECT_VERSION_NUMBER := NULL;
   LC_STATUS := NULL;
--  LN_OBJECT_VERSION_NUMBER := P_OBJECT_VERSION_NUMBER;
    LD_EFFECTIVE_START_DATE      := NULL;
    LD_EFFECTIVE_END_DATE        := NULL;
   LC_CONTRACT_STATUS       := 'A-ACTIVE';
   LN_ADDRESS_ID            := NULL;
--  apps.fnd_global.apps_initialize (user_id=>1677,resp_id=>50866,resp_appl_id=>800);
--   dbms_session.set_nls ('nls_date_format','''DD-MON-RR''');
  FOR XXTG_CONT_REC IN XXTG_CONT (P_LINE_ID)
    LOOP
      LN_PERSON_ID:= XXTG_CONT_REC.PERSON_ID;
      LN_ADDRESS_ID := XXTG_CONT_REC.ADDRESS_ID;
    END LOOP; 
     IF LN_ADDRESS_ID IS NULL THEN 
         BEGIN
               ln_request_id := fnd_request.submit_request ( 
                                    application   => 'TGCUST', 
                                    program       => 'XXTG_UPDATE_CONTRACT_ADDRESS', 
                                    description   => 'Update Contract Address', 
                                    start_time    => sysdate, 
                                    sub_request   => FALSE,
                                    argument1     => P_LINE_ID,
                                    argument2     => P_CAMP_NAME,
                                    argument3     => P_CAMP_ROOM_NO,
                                    argument4     => P_ADDR_DEPLOYMENT_DATE,
                                    argument5     => P_TRANSPORT_REQUESTED
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
 
  END PRIMARY_ADDRESS_UPDATE_WRAPPER;
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
                              program       => 'XXTG_PNL_PRINT', 
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
  END XXTG_CA_ADDRESS_PKG;
/
