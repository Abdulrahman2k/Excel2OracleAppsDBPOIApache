set define off;
CREATE OR REPLACE PACKAGE XXTG_CA_GEN_PKG AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  -------------------------------------------------------------------------------
---------   function get_final_approver  --------------------------------------------
----------  Function to get the final approver from the supervisor chain for current transaction ---------
-------------------------------------------------------------------------------
  FUNCTION GET_POSITION_ID (P_TRANSACTION_ID IN NUMBER,RANK IN NUMBER) RETURN VARCHAR2;
function get_item_type
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;
function get_item_key
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2;
        function getApprStartingPointPersonId
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;
function get_final_approver
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number;
function Get_Business_Group
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;
function GET_APPROVER (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;
FUNCTION GET_REQUESTOR_POSITION_ID (P_TRANSACTION_ID IN NUMBER) RETURN VARCHAR2;
FUNCTION GET_REQUESTOR_ORGANIZATION (P_TRANSACTION_ID IN NUMBER) RETURN NUMBER;
FUNCTION allow_requestor_approval
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;
FUNCTION Get_Batch_Risk
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 ;
END XXTG_CA_GEN_PKG;
/


CREATE OR REPLACE PACKAGE BODY XXTG_CA_GEN_PKG AS
--g_asg_api_name          constant  varchar2(80)
--                         default 'HR_PROCESS_ASSIGNMENT_SS.PROCESS_API';
---- Salary Basis Enhancement Change Begins
--g_mid_pay_period_change  constant varchar2(30) := 'HR_MID_PAY_PERIOD_CHANGE';
--g_oa_media     constant varchar2(100) DEFAULT fnd_web_config.web_server||'OA_MEDIA/';
--g_oa_html      constant varchar2(100) DEFAULT fnd_web_config.jsp_agent;
g_package  varchar2(33) := 'hr_workflow_ss.';
g_debug boolean := hr_utility.debug_enabled;
  CURSOR XXTG_EMP_CUR (LN_TRANSACTION_ID NUMBER) IS
    SELECT --DISTINCT 
--                   PAT.SELECTED_PERSON_ID,
--                    PAT.TRANSACTION_EFFECTIVE_DATE,
                    PAT.selected_approver_name APPROVER_NAME,
                    PAT.BUSINESS_GROUP_ID,
                    PAT.CREATED_BY CREATOR_PERSON_ID
--      INTO L_SELECTED_PERSON_ID,
--           L_EFFECTIVE_DATE,
--           L_CREATOR_ID
      FROM XXTG_CA_HEADERS_ALL PAT
     WHERE PAT.HEADER_ID = LN_TRANSACTION_ID;

CURSOR XXTG_ASS_CUR (LN_PERSON_ID NUMBER) --, LD_EFFECTIVE_DATE DATE )
IS SELECT 
PAAF.ORGANIZATION_ID
--,
--PAAF.BUSINESS_GROUP_ID,
--PAAF.PAYROLL_ID,
--PAAF.ASSIGNMENT_ID
--        INTO LN_EMP_ASG_ORG_ID,
--             L_BUSINESS_GROUP_ID
        FROM PER_ALL_ASSIGNMENTS_F PAAF
--        ,
--             HR_ALL_ORGANIZATION_UNITS HAOU
       WHERE 
--       PAAF.ORGANIZATION_ID = HAOU.ORGANIZATION_ID
--         AND 
         PAAF.PERSON_ID = LN_PERSON_ID  
         AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND
             PAAF.EFFECTIVE_END_DATE
         AND PAAF.PRIMARY_FLAG = 'Y';
 CURSOR XXTG_GET_POSITION_CUR (LN_TRANSACTION_ID NUMBER, LN_LEVEL NUMBER)
  IS SELECT 
ppse.subordinate_position_id position_id 
FROM 
PER_POS_STRUCTURE_ELEMENTS PPSE
where 
ppse.pos_structure_version_id= (select pps.position_structure_id from PER_POSITION_STRUCTURES pps
where pps.name='TG Position Hierarchy')
AND LEVEL=LN_LEVEL
--and level <=(  select nvl(to_number(ATTRIBUTE20),0)  from hr_all_organization_units where name= XXTG_LOA_PKG.GET_REQUESTOR_ORGANIZATION(LN_TRANSACTION_ID) and business_group_id = 81)
START WITH ppse.subordinate_position_id= 
(
SELECT PAAF.POSITION_ID FROM PER_ALL_ASSIGNMENTS_F PAAF, PER_ALL_PEOPLE_F PAPF
WHERE PAPF.PERSON_ID = PAAF.PERSON_ID AND 
trim(upper(PAPF.FULL_NAME))=trim(upper(XXTG_CA_GEN_PKG.GET_APPROVER (LN_TRANSACTION_ID  ))) --'Amreshan Thottathil Puthanpurayil')) --XXTG_CA_GEN_PKG.GET_APPROVER(LN_TRANSACTION_ID )
AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
AND SYSDATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
--SELECT TO_NUMBER(ATTRIBUTE15) FROM HR_ALL_ORGANIZATION_UNITS
--WHERE ORGANIZATION_ID =XXTG_CA_GEN_PKG.GET_APPROVER(LN_TRANSACTION_ID )
--(                     
--         SELECT organization_id_parent 
--          FROM PER_ORG_STRUCTURE_ELEMENTS POSE
--          where POSE.organization_id_CHILD = XXTG_CA_GEN_PKG.GET_REQUESTOR_ORGANIZATION(LN_TRANSACTION_ID )
--          and POSE.organization_id_parent in  (select organization_Id from hr_all_organization_UNITS where  TYPE ='SEC')
--          )
          )
connect by NOCYCLE  PRIOR    ppse.parent_position_id =PPSE.SUBORDINATE_POSITION_ID ;

  FUNCTION GET_REQUESTOR_ORGANIZATION (P_TRANSACTION_ID IN NUMBER) RETURN NUMBER IS
  L_CREATOR_ID  NUMBER;
  L_EFFECTIVE_DATE DATE;
  LN_EMP_ASG_ORG_ID  NUMBER;
  BEGIN
  
    FOR XXTG_REC IN XXTG_EMP_CUR(P_TRANSACTION_ID)
    LOOP
--      L_SELECTED_PERSON_ID := XXTG_REC.SELECTED_PERSON_ID;
--      L_EFFECTIVE_DATE     := XXTG_REC.TRANSACTION_EFFECTIVE_DATE;
      L_CREATOR_ID         := XXTG_REC.CREATOR_PERSON_ID;
    END LOOP;
    FOR XXTG_REC IN XXTG_ASS_CUR(L_CREATOR_ID)
    LOOP
      LN_EMP_ASG_ORG_ID        := XXTG_REC.ORGANIZATION_ID;
    END LOOP;
      RETURN LN_EMP_ASG_ORG_ID;
  
  END GET_REQUESTOR_ORGANIZATION;


function GET_APPROVER (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 IS
    L_SELECTED_PERSON_ID NUMBER;
    L_EFFECTIVE_DATE     DATE;
    L_CREATOR_ID         NUMBER;
    L_DEPT_ORG_ID        NUMBER;
    L_SEC_ORG_ID         NUMBER;
    L_ROLE_ID            VARCHAR2(1000);
    L_ROLE               VARCHAR2(1000);
    L_SEC_ROLE_ID        NUMBER;
    L_DEPT_ORG_NAME      VARCHAR2(1000);
    LN_POSITION_ID       NUMBER;
    LC_APPROVER_NAME     VARCHAR2(240);
  BEGIN
    FOR XXTG_REC IN XXTG_EMP_CUR(P_TRANSACTION_ID)
    LOOP
--      L_SELECTED_PERSON_ID := XXTG_REC.SELECTED_PERSON_ID;
--      L_EFFECTIVE_DATE     := XXTG_REC.TRANSACTION_EFFECTIVE_DATE;
      LC_APPROVER_NAME         := XXTG_REC.APPROVER_NAME;
    END LOOP;
    RETURN LC_APPROVER_NAME;

  END GET_APPROVER;
  

  FUNCTION GET_REQUESTOR_POSITION_ID (P_TRANSACTION_ID IN NUMBER) RETURN VARCHAR2
  IS 
      LN_POSITION_ID       VARCHAR2(240);
      CURSOR XXTG_GET_REQ_POSITION_CUR (LN_TRANSACTION_ID NUMBER)
      IS 
      SELECT POSITION_ID FROM PER_ALL_ASSIGNMENTS_F PAAF , FND_USER FU, XXTG_CA_HEADERS_ALL XCHA
      WHERE XCHA.CREATED_BY = FU.USER_ID
      AND FU.EMPLOYEE_ID = PAAF.PERSON_ID
      AND SYSDATE BETWEEN PAAF.EFFECTIVE_START_DATE AND PAAF.EFFECTIVE_END_DATE
      AND XCHA.HEADER_ID = LN_TRANSACTION_ID;
  BEGIN
    FOR XXTG_REC IN XXTG_GET_REQ_POSITION_CUR ( P_TRANSACTION_ID)
    LOOP
       LN_POSITION_ID := to_char(XXTG_REC.position_id);
    END LOOP;
    RETURN LN_POSITION_ID;
--      RETURN ('PER:'||185710); --('USER_ID:12720');select XXTG_CA_GEN_PKG.GET_REQUESTOR_USER_ID (:transactionId) from dual
  END GET_REQUESTOR_POSITION_ID;
  FUNCTION GET_POSITION_ID (P_TRANSACTION_ID IN NUMBER,RANK IN NUMBER) RETURN VARCHAR2 IS
    L_SELECTED_PERSON_ID NUMBER;
    L_EFFECTIVE_DATE     DATE;
    L_CREATOR_ID         NUMBER;
    L_DEPT_ORG_ID        NUMBER;
    L_SEC_ORG_ID         NUMBER;
    L_ROLE_ID            VARCHAR2(1000);
    L_ROLE               VARCHAR2(1000);
    L_SEC_ROLE_ID        NUMBER;
    L_DEPT_ORG_NAME      VARCHAR2(1000);
    LN_POSITION_ID       NUMBER;
  BEGIN
  FOR XXTG_REC IN XXTG_GET_POSITION_CUR ( P_TRANSACTION_ID, RANK)
    LOOP
       LN_POSITION_ID := to_char(XXTG_REC.position_id);
    END LOOP;
    RETURN LN_POSITION_ID;
  END GET_POSITION_ID;
-------------------------------------------------------------------------------
---------   function get_item_type  --------------------------------------------

----------  private function to get item type for current transaction ---------
-------------------------------------------------------------------------------
function get_item_type
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
c_item_type    varchar2(50);

begin

 begin
    if g_debug then
      hr_utility.set_location('querying hr_api_transactions.item_type for p_transaction_id:'||p_transaction_id, 2);
    end if;
    select t.Wf_item_type
    into c_item_type
    from XXTG_CA_HEADERS_ALL t
    where HEADER_id=get_item_type.p_transaction_id;
  exception
    when no_data_found then
    c_item_type:='XXTGCA';
     -- get the data from the steps
--     if g_debug then
--      hr_utility.set_location('querying hr_api_transaction_steps.item_type for p_transaction_id:'||p_transaction_id, 2);
--    end if;
--     select ts.item_type
--     into get_item_type.c_item_type
--     from hr_api_transaction_steps ts
--     where ts.transaction_id=get_item_type.p_transaction_id
--     and ts.item_type is not null and rownum <=1;
  end;

--return c_item_type;
return nvl(c_item_type,'XXTGCA');
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_item_type',p_transaction_id);
    RAISE;

end get_item_type;



-------------------------------------------------------------------------------
---------   function get_item_key  --------------------------------------------
----------  private function to get item key for current transaction ---------
-------------------------------------------------------------------------------

function get_item_key
(p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 is
c_item_key    varchar2(50);

begin

 begin
    if g_debug then
      hr_utility.set_location('querying hr_api_transactions.item_type for p_transaction_id:'||p_transaction_id, 2);
    end if;
    select t.wf_item_key
    into get_item_key.c_item_key
    from XXTG_CA_HEADERS_ALL t
    where HEADER_id=get_item_key.p_transaction_id;
  exception
    when no_data_found then
     -- get the data from the steps
     if g_debug then
      hr_utility.set_location('querying hr_api_transaction_steps.item_type for p_transaction_id:'||p_transaction_id, 2);
     end if;
--     select ts.item_key
--     into get_item_key.c_item_key
--     from hr_api_transaction_steps ts
--     where ts.transaction_id=get_item_key.p_transaction_id
--     and ts.item_type is not null and rownum <=1;
  end;

--return get_item_key.c_item_key;
return nvl(get_item_key.c_item_key,'-1');
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_item_key',p_transaction_id);
    RAISE;

end get_item_key;

function getApprStartingPointPersonId
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number
is
c_item_type    varchar2(50);
c_item_key     number;
c_creator_person_id per_all_people_f.person_id%type default null;
lv_transaction_ref_table hr_api_transactions.transaction_ref_table%type;
lv_transaction_ref_id hr_api_transactions.transaction_ref_id%type;

begin
   -- get the creator person_id from hr_api_transactions
   -- this would be the default  for all SSHR approvals.
   begin
     select t.created_by
     into c_creator_person_id
     from   XXTG_CA_HEADERS_ALL t
    where t.HEADER_id=getApprStartingPointPersonId.p_transaction_id;
   exception
   when others then
       raise;
   end;


return nvl(c_creator_person_id,0);

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.getApprStartingPointPersonId',c_item_type,c_item_key);
    RAISE;
end getApprStartingPointPersonId;
function Get_Business_Group
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 
        IS
        c_BUSINESS_GROUP VARCHAR2(240); 
begin
   -- get the creator person_id from hr_api_transactions
   -- this would be the default  for all SSHR approvals.
   begin
     select hr_general.decode_organization(T.BUSINESS_GROUP_ID)
     into c_BUSINESS_GROUP
     from   XXTG_CA_HEADERS_ALL t
    where t.HEADER_id=Get_Business_Group.p_transaction_id;
   exception
   when others then
       raise;
   end;


return nvl(c_BUSINESS_GROUP,'0');

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.getApprStartingPointPersonId',GET_item_type(p_transaction_id),GET_item_key(p_transaction_id));
    RAISE;
end Get_Business_Group;
function Get_Batch_Risk
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2 
        IS
LC_RISK VARCHAR2(1):= 'N';
cursor xxtg_line_cur (ln_header_id number)
is 
select Risk_flag from xxtg_ca_headers_all where header_id = ln_header_id;
BEGIN
  LC_RISK := 'N';
--        apps.fnd_global.apps_initialize (user_id=>1350,resp_id=>53423,resp_appl_id=>800);
BEGIN
 FOR XXTG_REC IN xxtg_line_cur (p_transaction_id)
  LOOP
 LC_RISK:=  XXTG_REC.RISK_FLAG;
  END LOOP;



   exception
   when others then
       raise;
   end;
   RETURN (LC_RISK);

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.Get_Batch_Risk',GET_item_type(p_transaction_id),GET_item_key(p_transaction_id));
    RAISE;
end Get_Batch_Risk;
  function get_final_approver
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return number 
    -- TODO: Implementation required for function XXTG_CA_GEN_PKG.get_final_approver
is
c_item_type    varchar2(50);
c_item_key     number;
c_creator_person_id per_all_people_f.person_id%type default null;
c_final_appprover_id per_all_people_f.person_id%type default null;
c_forward_to_person_id per_all_people_f.person_id%type default null;
lv_response varchar2(3);

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key  := get_item_key(p_transaction_id);

-- bug 4333335 begins
hr_approval_custom.g_itemtype := c_item_type;
hr_approval_custom.g_itemkey := c_item_key;
-- bug 4333335 ends

/*c_creator_person_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                               aname => 'CREATOR_PERSON_ID');
*/
c_creator_person_id := getApprStartingPointPersonId(p_transaction_id);
c_final_appprover_id := c_creator_person_id;

lv_response := hr_approval_custom.Check_Final_approver(p_forward_to_person_id       => c_creator_person_id,
                                                       p_person_id                  => c_creator_person_id );


while lv_response='N' loop

  c_forward_to_person_id := hr_approval_custom.Get_Next_Approver(p_person_id =>c_final_appprover_id);

  c_final_appprover_id := c_forward_to_person_id;

  lv_response := hr_approval_custom.Check_Final_approver(p_forward_to_person_id       => c_forward_to_person_id,
                                                         p_person_id                  => c_creator_person_id );

 end loop;

return c_final_appprover_id;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.get_final_approver',c_item_type,c_item_key);
    RAISE;


end get_final_approver;

  function allow_requestor_approval
         (p_transaction_id IN hr_api_transactions.transaction_id%TYPE)
        return varchar2  AS
    -- TODO: Implementation required for function XXTG_CA_GEN_PKG.allow_requestor_approval

c_item_type    varchar2(50);
c_item_key     varchar2(100);
c_final_approver number;
c_creator_person_id number;

begin

c_item_type := get_item_type(p_transaction_id);
c_item_key := get_item_key(p_transaction_id);
c_final_approver := get_final_approver(p_transaction_id);
/*c_creator_person_id := wf_engine.GetItemAttrNumber(itemtype => c_item_type ,
                                               itemkey  => c_item_key,
                                               aname => 'CREATOR_PERSON_ID');
*/
c_creator_person_id := getApprStartingPointPersonId(p_transaction_id);
if(c_final_approver=c_creator_person_id) then
 return 'true';
else return 'false';
end if;


EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT(g_package,'.allow_requestor_approval',c_item_type,c_item_key);
    RAISE;
end allow_requestor_approval ;

END XXTG_CA_GEN_PKG;
/
