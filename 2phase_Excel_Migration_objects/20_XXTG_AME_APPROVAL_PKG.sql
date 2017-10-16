SET DEFINE OFF;
CREATE OR REPLACE package      XXTG_AME_APPROVAL_PKG is 
 
   procedure getAmeTransactionDetail (x_transaction_type in out varchar2 , x_application_id out number );
   procedure getNextApprover(itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out NOCOPY varchar2) ;
   PROCEDURE CREATE_WF_DOC(
      document_id   IN VARCHAR2,
      display_type  IN VARCHAR2,
      document      IN OUT nocopy VARCHAR2,
      document_type IN OUT nocopy VARCHAR2 );
   PROCEDURE initialize_workflow_status(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) ;
   PROCEDURE update_approved_status(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) ;
   PROCEDURE update_rejected_status(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) ;
   procedure NextApproverexists(itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out NOCOPY varchar2) ;
   procedure updateAmeWithResponse(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) ;
                            
      procedure getnextFYINotifiers(  itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       out NOCOPY varchar2);
      PROCEDURE GET_WF_HTML_URL ( document_id IN VARCHAR2
                                ,display_type IN VARCHAR2
                                ,document IN OUT VARCHAR2
                                ,document_type IN OUT VARCHAR2
                                );
 
END;
/


CREATE OR REPLACE package body      XXTG_AME_APPROVAL_PKG is 

    PROCEDURE initialize_workflow_status(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out nocopy varchar2) 
   IS
   l_transaction_id  NUMBER;
   LC_ROLE_NAME      varchar2(240);
   LC_RISK_FLAG      VARCHAR2(1);
   LC_TOP_BU_NAME    VARCHAR2(240);
       cursor XXTG_CREATED_BY(LN_HEADER_ID NUMBER) is
           select User_Name role_name from  fnd_user fu 
                   where  fu.USER_ID =  (SELECT CREATED_BY FROM 
                                  XXTG_CA_HEADERS_ALL WHERE HEADER_ID = LN_HEADER_ID);
        cursor XXTG_SECURITY_PROFILE  IS
        select  NVL(TOP_ORGANIZATION, Business_group_name) TOP_ORG
         from PER_SECURITY_PROFILES_V 
          where SECURITY_PROFILE_ID = FND_PROFILE.VALUE('PER_SECURITY_PROFILE_ID');
          
          
x_itemtype wf_item_types.NAME % TYPE;
x_itemkey VARCHAR2(200);
x_process VARCHAR2(200);
p_mail_id VARCHAR2(200);
p_requester VARCHAR2(100);
p_vendor_name VARCHAR2(200);
          
   BEGIN
       l_transaction_id:= TO_NUMBER(wf_engine.getItemAttrText( itemtype =>  itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'HEADER_ID' ));
      LC_ROLE_NAME := NULL;
      FOR XXTG_REC IN XXTG_CREATED_BY(l_transaction_id)
        LOOP
          LC_ROLE_NAME :=XXTG_REC.role_name;
       END LOOP;
             wf_engine.setitemattrtext(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'CREATED_BY_USER_NAME',
                                avalue => LC_ROLE_NAME
                                );  
            /* Hardcoding Value of Property and logistics approvers */
             wf_engine.setitemattrtext(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'XXTG_APPROVER_ROLE',
                                avalue => 'TG Property Logistics Approver'
                                ); 
                                
       LC_TOP_BU_NAME:= NULL;                         
       FOR  XXTG_SEC_REC IN XXTG_SECURITY_PROFILE
         LOOP
           LC_TOP_BU_NAME:= XXTG_SEC_REC.TOP_ORG;
         END LOOP;
         
                      wf_engine.setitemattrtext(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'XXTG_BU_NAME',
                                avalue => LC_TOP_BU_NAME
                                ); 
         
--                LC_RISK_FLAG := XXTG_CA_DEPLOYMENT_PKG.Get_Batch_Risk(l_transaction_id );
            UPDATE xxtg_ca_headers_all 
            SET APPROVAL_STATUS ='In Approval Process',
            APPROVAL_REQUIRED_FLAG ='Y',
--            RISK_FLAG = LC_RISK_FLAG,
            AME_TRANSACTION_TYPE ='XXTGCA',
            AME_APPROVAL_ID = l_transaction_id
            WHERE HEADER_ID = l_transaction_id;
            wf_engine.SetItemAttrText (itemtype => itemtype,
            itemkey =>itemkey,
            aname =>'XXTG_BODY_WITH_LINK',
            avalue => 'PLSQL:XXTG_AME_APPROVAL_PKG.GET_WF_HTML_URL/' || itemkey);      
            
   END initialize_workflow_status;
   PROCEDURE update_approved_status(itemtype        in varchar2,
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
      FOR XXTG_EMAIL_REC IN  XXTG_REQUESTOR_EMAIL_CUR(l_transaction_id)
         LOOP
           LC_EMAIL := XXTG_EMAIL_REC.EMAIL_ADDRESS;
         END LOOP;
      FOR XXTG_REC IN  XXTG_LINE_CUR(l_transaction_id)
        LOOP
        LN_CONTRACT_ID :=NULL;
        XXTG_CA_DEPLOYMENT_PKG.XXTG_CONTRACT
  ( P_ORGANIZATION =>  XXTG_REC.NEW_CONTRACT_NAME,  -- VARCHAR2,
    P_JOB          => XXTG_REC.NEW_JOB,  -- VARCHAR2,
    P_ROSTER        => XXTG_REC.NEW_ROSTER,  -- VARCHAR2,
    P_BASIC        => XXTG_REC.NEW_BASIC_SALARY,  --   NUMBER,
    P_HRA            =>NULL,
    P_TRA            =>NULL, 
    P_RISK           => XXTG_REC.RISK_FLAG,
    P_CAMP           =>XXTG_REC.CAMP_NAME,
    P_ROOM           =>XXTG_REC.CAMP_ROOM_NAME,
    P_CONTRACT_BATCH  => XXTG_REC.HEADER_ID,  --VARCHAR2,
    P_EFFECTIVE_START_DATE => XXTG_REC.EFFECTIVE_DATE,  -- DATE,
    P_OPERATIONS_MGR_PERSON  => LC_EMAIL,  --VARCHAR2,
    P_TG_ID               => XXTG_REC.TG_ID,  -- VARCHAR2,
    P_EMP_CONTRACT_ID       => LN_CONTRACT_ID ); --  OUT   NUMBER);

    UPDATE XXTG_CA_LINES_ALL
    SET CONTRACT_ID= LN_CONTRACT_ID
    WHERE CURRENT OF XXTG_LINE_CUR ; --ROWID = XXTG_REC.ROW_ID; --
    END LOOP;
        UPDATE xxtg_ca_headers_all 
        SET APPROVAL_STATUS ='Approved  Sent',
        APPROVED_FLAG='Y',
        APPROVED_DATE = SYSDATE,
        CLOSED_DATE = SYSDATE,
--        APPROVAL_REQUIRED_FLAG ='N',
        AME_TRANSACTION_TYPE ='XXTGCA',
        AME_APPROVAL_ID = l_transaction_id
        WHERE HEADER_ID = l_transaction_id;
       
       
        XXTG_CA_DEPLOYMENT_PKG.SUBMIT_PRINT_REQUEST (P_CONTRACT_BATCH=>TO_CHAR(l_transaction_id) , P_REQUEST_ID=>lc_request_id) ;

        fnd_file.put_line(fnd_file.log,'Request ID of Print Batch is '||lc_request_id);
   END update_approved_status;
   PROCEDURE update_rejected_status(itemtype        in varchar2,
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
SET APPROVAL_STATUS ='Rejected',
APPROVED_FLAG='N',
APPROVAL_REQUIRED_FLAG ='Y',
AME_TRANSACTION_TYPE ='XXTGCA',
AME_APPROVAL_ID = l_transaction_id
WHERE HEADER_ID = l_transaction_id;
   END update_rejected_status;
     procedure getAmeTransactionDetail (x_transaction_type in out varchar2 , x_application_id out NUMBER )
     is 
     
     cursor c1 (transaction_type varchar2) is 
            select fnd_application_id as application_id, 
                   transaction_type_id as transaction_type
              from ame_transaction_types_v
             where transaction_type_id = transaction_type;
     
     begin
     
            for crec in c1(x_transaction_type) loop
            
                x_transaction_type:=crec.transaction_type;
                x_application_id := crec.application_id ; 
                
            end loop ; 
     
     end ; 
  
PROCEDURE CREATE_WF_DOC(
      document_id   IN VARCHAR2,
      display_type  IN VARCHAR2,
      document      IN OUT nocopy VARCHAR2,
      document_type IN OUT nocopy VARCHAR2 )
IS
  l_body VARCHAR2(32767);
  ln_header_id  NUMBER;
BEGIN
  --
  ln_header_id  := to_number(replace(document_id, 'PLSQL:XXTG_AME_APPROVAL_PKG.CREATE_WF_DOC/',''));
  document_type := 'text/html';
  ----Blue Gray  Background
  l_body := ' 
<table  border="1" bordercolor="black">
<thead>
<tr>
<th style="background-color:#98AFC7;">S.No</th>      
<th style="background-color:#98AFC7;">TG ID</th>
<th style="background-color:#98AFC7;">Name</th> 
<th style="background-color:#98AFC7;">Effective Date</th>
<th style="background-color:#98AFC7;">Source Contract Code</th>
<th style="background-color:#98AFC7;">Source Contract Name</th>      
<th style="background-color:#98AFC7;">Source Emp Job</th>
<th style="background-color:#98AFC7;">Source Emp Roster</th>      
<th style="background-color:#98AFC7;">Source Emp Basic</th>
<th style="background-color:#98AFC7;">Destination Contract Code</th>      
<th style="background-color:#98AFC7;">Dest Contract Name</th>
<th style="background-color:#98AFC7;">Dest Emp Job</th>      
<th style="background-color:#98AFC7;">Dest Emp Roster</th>
<th style="background-color:#98AFC7;">Dest Emp Basic</th>      
<th style="background-color:#98AFC7;">Creation Date</th>
<th style="background-color:#98AFC7;">Created By</th>
</thead>
</tr>
<tbody>
';
  FOR i IN
  (select XCLA.SNO, XCLA.TG_ID, XCLA.FULL_NAME, XCLA.EFFECTIVE_DATE, XCLA.OLD_CONTRACT_CODE, XCLA.OLD_CONTRACT_NAME, XCLA.OLD_JOB, XCLA.OLD_ROSTER, XCLA.OLD_BASIC_SALARY, XCLA.NEW_CONTRACT_CODE, XCLA.NEW_CONTRACT_NAME, XCLA.NEW_JOB, XCLA.NEW_ROSTER, XCLA.NEW_BASIC_SALARY,TO_CHAR(XCLA.CREATION_DATE,'DD-MON-RRRR') CREATION_DATE, (SELECT FU.USER_NAME FROM FND_USER FU WHERE  FU.USER_ID = XCLA.CREATED_BY) CREATED_BY_USER  from  XXTG_CA_LINES_ALL XCLA
WHERE HEADER_ID = LN_HEADER_ID ORDER BY TO_NUMBER(SNO)
  )
  LOOP
    BEGIN
      l_body := l_body || '<tr>    
<td>'|| i.SNO || '</td>     
<td>' || i.TG_ID || '</td>   
<td>' || i.FULL_NAME || '</td>  
<td>'|| i.EFFECTIVE_DATE || '</td>     
<td>' || i.OLD_CONTRACT_CODE || '</td>  
<td>'|| i.OLD_CONTRACT_NAME || '</td>     
<td>' || i.OLD_JOB || '</td>  
<td>'|| i.OLD_ROSTER || '</td>     
<td>' || i.OLD_BASIC_SALARY || '</td>  
<td>'|| i.NEW_CONTRACT_CODE || '</td>     
<td>' || i.NEW_CONTRACT_NAME || '</td>  
<td>'|| i.NEW_JOB || '</td>     
<td>' || i.NEW_ROSTER || '</td>  
<td>'|| i.NEW_BASIC_SALARY || '</td>     
<td>' || i.CREATION_DATE || '</td>  
<td>' || i.CREATED_BY_USER || '</td> 
</tr>
';
    END;
  END LOOP;
l_body := l_body || 
'</tbody>
</table>';
  document := l_body;
--
--Setting document type which is nothing but MIME type
--
  document_type := 'text/html';
EXCEPTION
WHEN OTHERS THEN
  document := '<H4>Error: '|| sqlerrm || '</H4>';
      --       
END CREATE_WF_DOC;
     procedure getNextApprover(  itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       out NOCOPY varchar2) IS
 
      E_FAILURE                   EXCEPTION;
      l_transaction_id            VARCHAR2(240);
      l_next_approver             ame_util.approverRecord2;
      l_next_approvers            ame_util.approversTable2;
      l_next_approvers_count      number;
      l_approver_index            number;
      l_is_approval_complete      VARCHAR2(1);
      l_transaction_type          VARCHAR2(200);
      l_application_id            number;
      l_role_users  WF_DIRECTORY.UserTable;
      l_role_name                            VARCHAR2(320) ;
      l_role_display_name                    VARCHAR2(360)  ;
 
      l_all_approvers            ame_util.approversTable;
 
    cursor c1(p_user_name varchar2) is
           select papf.full_name from  fnd_user fu ,
                          per_all_people_f papf
                   where  fu.employee_id = papf.person_id
                     and  fu.user_name = p_user_name
                     and sysdate between papf.EFFECTIVE_START_DATE and nvl(papf.EFFECTIVE_end_DATE,sysdate+1)
                     and sysdate between fu.start_date and nvl(fu.end_date,sysdate+1) ;
   cursor xxtg_trxn_type (transaction_type varchar2) is 
            select fnd_application_id as application_id, 
                   transaction_type_id as transaction_type
              from ame_transaction_types_v
             where transaction_type_id = transaction_type;
    begin
 
    if (funcmode = 'RUN') THEN
 
      -- l_transaction_id :=  TO_NUMBER(itemkey);
       
       l_transaction_id:= wf_engine.getItemAttrText( itemtype =>  itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'AME_TRANSACTION_ID' );
 
 
       l_transaction_type := 'XXTGCA';
--      l_transaction_type := wf_engine.getItemAttrText( itemtype =>  itemtype,
--                                                         itemkey  => itemkey,
--                                                         aname    => 'AME_TRANSACTION_TYPE' );
--      FOR xxtg_trxn_rec IN xxtg_trxn_type(l_transaction_type)
--        LOOP
--           l_application_id:= xxtg_trxn_rec.application_id;
--        END LOOP;
      XXTG_AME_APPROVAL_PKG.getAmeTransactionDetail  ( l_transaction_type,l_application_id );
 
 
       ame_api2.getNextApprovers4(applicationIdIn=>l_application_id,
                                transactionTypeIn=>l_transaction_type,
                                transactionIdIn=>l_transaction_id,
                                flagApproversAsNotifiedIn => ame_util.booleanTrue,
                                approvalProcessCompleteYNOut => l_is_approval_complete,
                                nextApproversOut=>l_next_approvers);
 
      l_next_approvers_count:=l_next_approvers.count ;
 
--      if (l_is_approval_complete = ame_util.booleanTrue) then
--        resultout:='COMPLETE:'||'NO';
--        return;
-- 
--  --  Incase of consensus voting method, next approver count might be zero but there will be pending approvers
--      els
--           INSERT INTO XXTG_TEST VALUES ('Inside getNextApprover First l_next_approvers_count '||l_next_approvers_count);
      if (l_next_approvers.Count = 0) then
 
        ame_api2.getPendingApprovers(applicationIdIn=>l_application_id,
                                    transactionTypeIn=>l_transaction_type,
                                    transactionIdIn=>l_transaction_id,
                                    approvalProcessCompleteYNOut => l_is_approval_complete,
                                    approversOut =>l_next_approvers);
      end if;
 
      l_next_approvers_count := l_next_approvers.Count;
--            INSERT INTO XXTG_TEST VALUES ('Inside getNextApprover Second l_next_approvers_count '||l_next_approvers_count);
      if (l_next_approvers_count = 0)  then
         resultout:='COMPLETE:'||'N'; --'NO_NEXT_APPROVER';
         return;
      end if;
-- 
      if (l_next_approvers_count = 1)  then
 
          l_next_approver:=l_next_approvers(l_next_approvers.first());
          wf_engine.SetItemAttrText( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'APPROVER_USER_NAME' ,
                                  avalue     => l_next_approver.name);
 
           wf_engine.SetItemAttrText( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'APPROVER_DISPLAY_NAME' ,
                                  avalue     => l_next_approver.display_name);
 
           /*role name is user name here */
           for crec in c1(l_next_approver.name) loop
 
               l_role_display_name:=crec.full_name ;
 
           end loop  ;
                        --  l_role_name:=
 
--           resultout:='COMPLETE:'||'VALID_APPROVER';
             resultout:='COMPLETE:'||'Y';
           --return;
 
      end if;
      l_role_name:= null;
      l_approver_index := l_next_approvers.first();
  
      while ( l_approver_index is not null ) loop
 
          l_role_users(l_approver_index):= l_next_approvers(l_approver_index).name ;
          l_role_name :=l_next_approvers(l_approver_index).name;

          l_approver_index := l_next_approvers.next(l_approver_index);
 
 
      end loop;
 
 
      wf_engine.setitemattrtext(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'XXTG_APPROVER_POSITION' , --'RECIPIENT_ROLE',
                                avalue => l_role_name --l_role_name
                                );
     return;
 
	end if; -- run

    exception
      when others then
        -- The line below records this function call in the error
        -- system in the case of an exception.
--        resultout:='COMPLETE:'||'N'; 
        wf_core.context('XXTG_AME_APPROVAL_PKG',
                        'getNextApprover',
                        itemtype,
                        itemkey,
                        to_char(actid),
                        funcmode);
        raise;
    end getNextApprover;
      procedure getnextFYINotifiers(  itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       out NOCOPY varchar2) IS
 
      E_FAILURE                   EXCEPTION;
      l_transaction_id            number;
      l_next_approver             ame_util.approverRecord2;
      l_next_approvers            ame_util.approversTable2;
      l_next_approvers_count      number;
      l_approver_index            number;
      l_is_approval_complete      VARCHAR2(1);
      l_transaction_type          VARCHAR2(200);
      l_application_id            number;
      l_role_users  WF_DIRECTORY.UserTable;
      l_role_name                            VARCHAR2(320) ;
      l_role_display_name                    VARCHAR2(360)  ;
      lc_error                    VARCHAR2(240);
 
      l_all_approvers            ame_util.approversTable;
 
    cursor c1(p_user_name varchar2) is
           select papf.full_name from  fnd_user fu ,
                          per_all_people_f papf
                   where  fu.employee_id = papf.person_id
                     and  fu.user_name = p_user_name
                     and sysdate between papf.EFFECTIVE_START_DATE and nvl(papf.EFFECTIVE_end_DATE,sysdate+1)
                     and sysdate between fu.start_date and nvl(fu.end_date,sysdate+1) ;
 
    begin
 
    if (funcmode = 'RUN') THEN
 
      -- l_transaction_id :=  TO_NUMBER(itemkey);
       
       l_transaction_id:= wf_engine.getItemAttrText( itemtype =>  itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'AME_TRANSACTION_ID' );
 
 
       l_transaction_type := 'XXTGCA';
--      l_transaction_type := wf_engine.getItemAttrText( itemtype =>  itemtype,
--                                                         itemkey  => itemkey,
--                                                         aname    => 'AME_TRANSACTION_TYPE' );
 
       getAmeTransactionDetail  ( l_transaction_type,l_application_id );
 
 begin
       ame_api2.getNextApprovers4(applicationIdIn=>l_application_id,
                                transactionTypeIn=>l_transaction_type,
                                transactionIdIn=>l_transaction_id,
                                flagApproversAsNotifiedIn => ame_util.booleanTrue,
                                approvalProcessCompleteYNOut => l_is_approval_complete,
                                nextApproversOut=>l_next_approvers);
 exception
 when others then
 lc_error :=sqlerrm;
-- insert into xxtg_test values ('Inside first ame_api2.getNextApprovers4 '||lc_error );
 end;
      l_next_approvers_count:=l_next_approvers.count ;
 
--      if (l_is_approval_complete = ame_util.booleanTrue) then
--        resultout:='COMPLETE:'||'NO';
--        return;
-- 
--  --  Incase of consensus voting method, next approver count might be zero but there will be pending approvers
--      els

--insert into xxtg_test values ('value of l_next_approvers.count '||l_next_approvers_count);
      if (l_next_approvers.Count = 0) then
 
        ame_api2.getPendingApprovers(applicationIdIn=>l_application_id,
                                    transactionTypeIn=>l_transaction_type,
                                    transactionIdIn=>l_transaction_id,
                                    approvalProcessCompleteYNOut => l_is_approval_complete,
                                    approversOut =>l_next_approvers);
      end if;
 
      l_next_approvers_count := l_next_approvers.Count;
 
--insert into xxtg_test values ('value of l_next_approvers_count '||l_next_approvers_count);
      if (l_next_approvers_count = 0)  then
         resultout:='COMPLETE:'||'NO_NEXT_APPROVER';
         return;
      end if;
 
--      if (l_next_approvers_count > 0)  then
--         resultout:='COMPLETE:'||'YES';
--         --return;
--      end if;
-- 
      if (l_next_approvers_count>0 )  then --and l_is_approval_complete = ame_util.booleanTrue)  then
 
          l_next_approver:=l_next_approvers(l_next_approvers.first());
          wf_engine.SetItemAttrText( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'APPROVER_USER_NAME' ,
                                  avalue     => l_next_approver.name);
 
           wf_engine.SetItemAttrText( itemtype   => itemType,
                                  itemkey    => itemkey,
                                  aname      => 'APPROVER_DISPLAY_NAME' ,
                                  avalue     => l_next_approver.display_name);
 
           /*role name is user name here */
           for crec in c1(l_next_approver.name) loop
 
               l_role_display_name:=crec.full_name ;
 
           end loop  ;
                        --  l_role_name:=
 
           resultout:='COMPLETE:'||'VALID_APPROVER';
--             resultout:='COMPLETE:'||'Y';
           --return;
 
      end if;
      l_role_name:= null;
      l_approver_index := l_next_approvers.first();
  
      while ( l_approver_index is not null ) loop
 
          l_role_users(l_approver_index):= l_next_approvers(l_approver_index).name ;
          l_role_name :=l_next_approvers(l_approver_index).name;
--          insert into xxtg_test values (' Role Name from FYI '||l_role_name);
--           INSERT INTO XXTG_TEST VALUES (l_next_approvers(l_approver_index).name);
          l_approver_index := l_next_approvers.next(l_approver_index);

 
      end loop;
 
 /*COMMENTED FOR TESTING, NEED TO REENABLE*/
--	 wf_directory.CreateAdHocRole2( role_name => l_role_name
--								  ,role_display_name => l_role_display_name
--								  ,language => null
--								  ,territory => null
--								  ,role_description => 'AME ROLE DESC'
--								  ,notification_preference => null
--								  ,role_users => l_role_users
--								  ,email_address => null
--								  ,fax => null
--								  ,status => 'ACTIVE'
--								  ,expiration_date => null
--								  ,parent_orig_system => null
--								  ,parent_orig_system_id => null
--								  ,owner_tag => null
--								  );
       wf_engine.setitemattrtext(itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'XXTG_REQUESTOR' , --'RECIPIENT_ROLE',
                                avalue => l_role_name --l_role_name
                                ); 

     return;
 
	end if; -- run
 
    exception
      when others then
        -- The line below records this function call in the error
        -- system in the case of an exception.
--        resultout:='COMPLETE:'||'N'; 
-- insert into xxtg_test values ('Main Exception ame_api2.getNextApprovers4 ' );
        wf_core.context('XXTG_AME_APPROVAL_PKG',
                        'getFYINotifiers',
                        itemtype,
                        itemkey,
                        to_char(actid),
                        funcmode);
        raise;
    end getnextFYINotifiers;
     procedure NextApproverExists(  itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       out NOCOPY varchar2) IS
 
      E_FAILURE                   EXCEPTION;
      l_transaction_id            number;
      l_next_approver             ame_util.approverRecord2;
      l_next_approvers            ame_util.approversTable2;
      l_next_approvers_count      number;
      l_approver_index            number;
      l_is_approval_complete      VARCHAR2(1);
      l_transaction_type          VARCHAR2(200);
      l_application_id            number;
      l_role_users  WF_DIRECTORY.UserTable;
      l_role_name                            VARCHAR2(320) ;
      l_role_display_name                    VARCHAR2(360)  ;
 
      l_all_approvers            ame_util.approversTable;
 
--    cursor c1(p_user_name varchar2) is
--           select papf.full_name from  fnd_user fu ,
--                          per_all_people_f papf
--                   where  fu.employee_id = papf.person_id
--                     and  fu.user_name = p_user_name
--                     and sysdate between papf.EFFECTIVE_START_DATE and nvl(papf.EFFECTIVE_end_DATE,sysdate+1)
--                     and sysdate between fu.start_date and nvl(fu.end_date,sysdate+1) ;
 
    begin
 
    if (funcmode = 'RUN') THEN
 
      -- l_transaction_id :=  TO_NUMBER(itemkey);
       
       l_transaction_id:= wf_engine.getItemAttrNumber( itemtype =>  itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'AME_TRANSACTION_ID' );
 
       l_transaction_type := 'XXTGCA'; 
--       l_transaction_type :=  wf_engine.getItemAttrText( itemtype =>  itemtype,
--                                                         itemkey  => itemkey,
--                                                         aname    => 'AME_TRANSACTION_TYPE' );
 
       getAmeTransactionDetail  ( l_transaction_type,l_application_id );
 
 
       ame_api2.getNextApprovers4(applicationIdIn=>l_application_id,
                                transactionTypeIn=>l_transaction_type,
                                transactionIdIn=>l_transaction_id,
                                flagApproversAsNotifiedIn => ame_util.booleanTrue,
                                approvalProcessCompleteYNOut => l_is_approval_complete,
                                nextApproversOut=>l_next_approvers);
 
      l_next_approvers_count:=l_next_approvers.count ;
 
--      if (l_is_approval_complete = ame_util.booleanTrue) then
--        resultout:='COMPLETE:'||'N';
--        return;
 
--  --  Incase of consensus voting method, next approver count might be zero but there will be pending approvers
--      elsif (l_next_approvers.Count = 0) then
 
        ame_api2.getPendingApprovers(applicationIdIn=>l_application_id,
                                    transactionTypeIn=>l_transaction_type,
                                    transactionIdIn=>l_transaction_id,
                                    approvalProcessCompleteYNOut => l_is_approval_complete,
                                    approversOut =>l_next_approvers);
--      end if;
 
      l_next_approvers_count := l_next_approvers.Count;
 
--      if (l_next_approvers_count = 0)  then
      if (l_is_approval_complete = ame_util.booleanTrue) then
         resultout:='COMPLETE:'||'N';
         return;
      elsif (l_next_approvers_count > 0)  then
         resultout:='COMPLETE:'||'Y';
         return;
      else 
              resultout:='COMPLETE:'||'N'; 
               return;
      end if;
 
--      if (l_next_approvers_count = 1)  then
-- 
--          l_next_approver:=l_next_approvers(l_next_approvers.first());
--          wf_engine.SetItemAttrText( itemtype   => itemType,
--                                  itemkey    => itemkey,
--                                  aname      => 'APPROVER_USER_NAME' ,
--                                  avalue     => l_next_approver.name);
-- 
--           wf_engine.SetItemAttrText( itemtype   => itemType,
--                                  itemkey    => itemkey,
--                                  aname      => 'APPROVER_DISPLAY_NAME' ,
--                                  avalue     => l_next_approver.display_name);
-- 
--           /*role name is user name here */
--           for crec in c1(l_next_approver.name) loop
-- 
--               l_role_display_name:=crec.full_name ;
-- 
--           end loop  ;
--                        --  l_role_name:=
-- 
--           resultout:='COMPLETE:'||'VALID_APPROVER';
--           --return;
-- 
--      end if;
 
--      l_approver_index := l_next_approvers.first();
-- 
--      while ( l_approver_index is not null ) loop
-- 
--          l_role_users(l_approver_index):= l_next_approvers(l_approver_index).name ;
-- 
--          l_approver_index := l_next_approvers.next(l_approver_index);
-- 
-- 
--      end loop;
-- 
-- 
--	 wf_directory.CreateAdHocRole2( role_name => l_role_name
--								  ,role_display_name => l_role_display_name
--								  ,language => null
--								  ,territory => null
--								  ,role_description => 'AME ROLE DESC'
--								  ,notification_preference => null
--								  ,role_users => l_role_users
--								  ,email_address => null
--								  ,fax => null
--								  ,status => 'ACTIVE'
--								  ,expiration_date => null
--								  ,parent_orig_system => null
--								  ,parent_orig_system_id => null
--								  ,owner_tag => null
--								  );
-- 
--      wf_engine.setitemattrtext(itemtype => itemtype,
--                                itemkey => itemkey,
--                                aname => 'RECIPIENT_ROLE',
--                                avalue => l_role_name
--                                );
--     return;
 
	end if; -- run
 
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
    end NextApproverExists; 
    
    procedure updateAmeWithResponse(itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out nocopy varchar2) is
      e_failure                   exception;
      l_transaction_id            VARCHAR2(240); --number;
      l_nid                       number;
      l_gid                       number;
      l_approver_name             varchar2(240);
      l_result                    varchar2(100);
      l_ame_status                varchar2(20);
      l_original_approver_name         varchar2(240);
      l_forwardeein  ame_util.approverrecord2;
      
      l_transaction_type varchar2 (200 byte);
      l_application_id   number ;
      CURSOR XXTG_CUR (lC_transaction_type VARCHAR2,lC_transaction_id VARCHAR2) IS
         SELECT XX.Recipient_role approver_name,
--         XX.responder approver_name
         XX.notification_id FROM (
               select Recipient_role, responder,notification_id
--                              into  l_approver_name,l_nid
                         from wf_notifications
                         WHERE message_type = lC_transaction_type
                         AND    item_key     = lC_transaction_id
                         and status = 'CLOSED'
                         ORDER BY notification_id DESC
                         ) XX
                      WHERE ROWNUM =1 ;
    begin
    
     l_transaction_type := 'XXTGCA';
--     wf_engine.getItemAttrText( itemtype =>  itemtype,
--													   itemkey  => itemkey,
--													   aname    => 'AME_TRANSACTION_TYPE');
    
     getAmeTransactionDetail (l_transaction_type,
                              l_application_id);
      
     l_transaction_id:= wf_engine.getItemAttrTEXT( itemtype =>  itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'HEADER_ID');
    
     if (funcmode = 'RUN') then
 
                      -- l_transaction_id :=  itemkey;
                       l_gid := wf_engine.context_nid;

               FOR XXTG_REC IN XXTG_CUR (l_transaction_type,l_transaction_id)
                 LOOP
                   l_approver_name := XXTG_REC.approver_name;
                   l_nid           := XXTG_REC.notification_id;
                 END LOOP;
                        ---where group_id=l_gid
--                        where group_id=l_gid
--                          and status = 'CLOSED';
 
                       l_result := wf_notification.getattrtext(l_nid, 'RESULT');
 
 
                       if (l_result = 'APPROVED') then -- this may vary based on lookup type used for approval
                         l_ame_status := ame_util.approvedstatus;
                       elsif (l_result = 'REJECTED') then
                         l_ame_status := ame_util.rejectstatus;
                       else -- reject for lack of information, conservative approach
                         l_ame_status := ame_util.approvedstatus; --ame_util.rejectstatus;
                       end if;
                       --set approver as approved or rejected based on approver response
                       ame_api2.updateapprovalstatus2(  applicationidin=>l_application_id,
                                                        transactiontypein=>l_transaction_type,
                                                        transactionidin=>l_transaction_id,
                                                        approvalstatusin => l_ame_status,
                                                        approvernamein => l_approver_name);
 

     
     elsif  ( funcmode = 'TIMEOUT' ) then
     
           l_gid := wf_engine.context_nid;
 
           select Recipient_role, --responder
            notification_id
             into l_approver_name,l_nid
             from wf_notifications
            where group_id=l_gid;
            --and status = 'CLOSED';
 
           l_result := wf_notification.getattrtext(l_nid, 'RESULT');
 
           if (l_result = 'APPROVED') then -- this may vary based on lookup type used for approval
              l_ame_status := ame_util.approvedstatus;
           elsif (l_result = 'REJECTED') then
             l_ame_status := ame_util.rejectstatus;
           else -- reject for lack of information, conservative approach
             l_ame_status := ame_util.rejectstatus;
           end if;
           --set approver as approved or rejected based on approver response
           ame_api2.updateapprovalstatus2(  applicationidin=>l_application_id,
                                            transactiontypein=>l_transaction_type,
                                            transactionidin=>l_transaction_id,
                                            approvalstatusin => l_ame_status,
                                            approvernamein => l_approver_name);     
     
     elsif  ( funcmode = 'TRANSFER' ) then
 
            --l_transaction_id :=  itemkey;
            l_forwardeein.name :=wf_engine.context_new_role;
            l_original_approver_name:= wf_engine.context_original_recipient;
 
 
              ame_api2.updateapprovalstatus2(applicationidin=>l_application_id ,
                        transactiontypein=>l_transaction_type,
                        transactionidin=>l_transaction_id,
                        approvalstatusin => 'FORWARD',
                        approvernamein => l_original_approver_name,
          forwardeein => l_forwardeein );
 
     end if; -- run
 
     resultout:= wf_engine.eng_completed || ':' || l_result;
 
    exception
      when others then
        wf_core.context('XXTG_AME_APPROVAL_PKG',
                        'updateAmeWithResponse',
                        itemtype,
                        itemkey,
                        to_char(actid),
                        funcmode);
        
        raise;
    end updateAmeWithResponse;    
PROCEDURE GET_WF_HTML_URL ( document_id IN VARCHAR2
,display_type IN VARCHAR2
,document IN OUT VARCHAR2
,document_type IN OUT VARCHAR2
)
is
l_document VARCHAR2(32000) :=' ';
NL VARCHAR2(1) := fnd_global.newline;
lc_amp VARCHAR2(1) := '&';
l_htmlref VARCHAR2(4000);
ln_function_id  number;
ln_resp_appl_id  number;
ln_resp_id  number;
ln_header_id number;
ln_user_id number;
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
         AND  fu.user_id  = LN_USER_ID
         AND fpot.language             =  USERENV('LANG')
         AND fpov.level_id = '10003'
         AND ROWNUM =1    ;

begin

ln_header_id  := to_number(replace(document_id, 'PLSQL:XXTG_AME_APPROVAL_PKG.GET_WF_HTML_URL/',''));
document_type := 'text/html';
ln_function_id :=fnd_function.get_function_id ('XXTG_CA_NOTIFICATION');
 ln_user_id := null;
    ln_resp_id := null;
    ln_resp_appl_id := null;
--   select FND_PROFILE.VALUE('USER_ID') into ln_user_id from dual;
--   ln_user_id:=9464;
    FOR XXTG_REC IN XXTG_RESP_ID_APPROVER_CUR (ln_user_id)
      LOOP
      ln_resp_appl_id := XXTG_REC.application_id;
      ln_resp_id      := XXTG_REC.responsibility_id;
--        apps.fnd_global.apps_initialize (user_id=>ln_user_id,resp_id=>XXTG_REC.responsibility_id,resp_appl_id=>XXTG_REC.application_id);
      END LOOP;
--ln_resp_appl_id := 800; --fnd_profile.value('RESP_APPL_ID');
--ln_resp_id := 50638 ; -- fnd_profile.value('RESP_ID');
--insert into xxtg_test values ('ln_resp_appl_id '||ln_resp_appl_id||'ln_resp_id '||ln_resp_id||' ln_user_id'||ln_user_id);
--       ln_header_id:= wf_engine.getItemAttrNumber( itemtype =>  itemtype,
--                                                         itemkey  => itemkey,
--                                                         aname    => 'HEADER_ID' );
l_document := NL || NL || '<!? URL LINK FOR PAGE QUERY ?>'|| NL || NL ||'<P><B>';
l_htmlref := '<A HREF="' || FND_RUN_FUNCTION.get_run_function_url (p_function_id => ln_function_id
, p_resp_appl_id =>ln_resp_appl_id
, p_resp_id => ln_resp_id
, p_security_group_id => 0  --null
--, p_parameters => P_HEADER_ID='||ln_header_id||'&nbsp;P_READ_ONLY=Y&nbsp
, p_parameters => 'P_HEADER_ID='||ln_header_id||'&'||'P_READ_ONLY=Y'
) ||'"> OPEN DEPLOYMENT BATCH LINK [/URL]';
--
l_document := l_document || '<BR> ' || l_htmlref;
document := l_document;
--insert into xxtg_test values (ln_header_id);
end GET_WF_HTML_URL; 
 
END XXTG_AME_APPROVAL_PKG;
/
