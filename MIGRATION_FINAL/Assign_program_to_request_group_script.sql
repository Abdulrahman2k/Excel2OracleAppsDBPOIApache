/*********************************************************
*PURPOSE: To Add a Concurrent Program to a Request Group *
*         from backend                                   *
*AUTHOR: Shailender Thallam                              *
**********************************************************/
--
DECLARE
  l_program_short_name  VARCHAR2 (200);
  l_program_application VARCHAR2 (200);
  l_request_group       VARCHAR2 (200);
  l_group_application   VARCHAR2 (200);
  l_check               VARCHAR2 (2);
  --
BEGIN
  --
  l_program_short_name  := 'XXTG_CA_DELETE_ORPHAN_RECORDS';
  l_program_application := 'TGCUST';
  l_request_group       := 'XXTG_CONTRACTS_REPORTS';
  l_group_application   := 'TGCUST';
  --
  --Calling API to assign concurrent program to a reqest group
  --
   apps.fnd_program.add_to_group (program_short_name  => l_program_short_name,
                                  program_application => l_program_application,
                                  request_group       => l_request_group,
                                  group_application   => l_group_application                            
                                 );  
  --
  COMMIT;
  --
  BEGIN
    --
    --To check whether a paramter is assigned to a Concurrent Program or not
    --
     SELECT 'Y'
--       INTO l_check
       FROM fnd_request_groups frg,
      fnd_request_group_units frgu,
      fnd_concurrent_programs fcp
      WHERE frg.request_group_id    = frgu.request_group_id
    AND frg.application_id          = frgu.application_id
    AND frgu.request_unit_id        = fcp.concurrent_program_id
    AND frgu.unit_application_id    = fcp.application_id
    AND fcp.concurrent_program_name = 'XXTG_CA_DELETE_ORPHAN_RECORDS'
    AND frg.REQUEST_GROUP_NAME ='XXTG_CONTRACTS_REPORTS';
    --
    dbms_output.put_line ('Adding Concurrent Program to Request Group Succeeded');
    --
  EXCEPTION
  WHEN no_data_found THEN
    dbms_output.put_line ('Adding Concurrent Program to Request Group Failed');
  END;
END;
