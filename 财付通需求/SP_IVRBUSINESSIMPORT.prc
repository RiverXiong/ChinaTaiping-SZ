CREATE OR REPLACE Procedure SP_IVRBUSINESSIMPORT(I_Templist    in VARCHAR2,
																								 I_Rolegroupid in VARCHAR2,
																								 I_Staffid     in VARCHAR2,
																								 I_Dealflag    in VARCHAR2,
																								 Outstring     Out VARCHAR2) Is
	Dcursorsql1      Varchar2(4000);
	SelectSQL        Varchar2(4000);
	InsertSQL        Varchar2(4000);
	UpdateSQL        Varchar2(4000);
	Var_Temp_guid    Varchar2(100);
	var_bankid       Varchar2(100);
	var_bankdesc     Varchar2(100);
	var_cardkind     Varchar2(100);
	var_cardkinddesc Varchar2(100);
	var_business     Varchar2(100);
	var_businessdesc Varchar2(100);
	var_Dealflag     Varchar2(100);

	Int_Countnum  int;
	Var_Outstring Varchar2(1000);

	Type cur is ref cursor;
	cura cur;

	Errorcode1 varchar(300);
	Errordesc1 varchar(2000);

	/****************************************************
  Program_Name: SP_IVRBUSINESSIMPORT
  Program_Desc: 首选支付商设置导入存储过程
  Commentary:上海过河兵
  Revision: V1.0
  Author: River
  Date: 2015-03-19
  ***************************************************/
Begin
	--var_Dealflag   := I_Dealflag;
	var_Dealflag := 'NOTDEAL';
	Dcursorsql1  := 'select temp_guid,column1,column2,column3,column4,column5,column6 from templist_' ||
									I_Templist || '';
	open cura for Dcursorsql1;
	loop
		fetch cura
			into Var_Temp_guid,
					 var_bankid,
					 var_bankdesc,
					 var_cardkind,
					 var_cardkinddesc,
					 var_business,
					 var_businessdesc;
	
		exit when cura%notfound;
		if var_bankid is not null and var_cardkind is not null then
			SelectSQL := 'select count(*) from ivr_bank_business where bank_id=''' ||
									 var_bankid || ''' and cardkind=''' || var_cardkind || '''';
			execute immediate SelectSQL
				into Int_Countnum;
			if Int_Countnum > 0 then
				if var_Dealflag = 'UPDATE' then
				
					UpdateSQL := 'update ivr_bank_business set business_id  = ''' ||
											 var_business || ''',business_desc =''' ||
											 var_businessdesc || ''',modifiedby=''' || I_Staffid ||
											 ''',,modifiedgroup=''' || I_Rolegroupid ||
											 ''',modifieddate=sysdate  where  bank_id=''' ||
											 var_bankid || ''' and cardkind=''' || var_cardkind || '''';
					insert into sqlhis values ('UpdateSQL', UpdateSQL, sysdate);
					execute immediate UpdateSQL;
				
					UpdateSQL := 'update templist_' || I_Templist ||
											 ' set checkstatus=''1'',errdesc=''数据已经存在更新处理'' where temp_guid=''' ||
											 Var_Temp_guid || '''';
					execute immediate UpdateSQL;
				else
					if var_Dealflag = 'DELETE' then
						UpdateSQL := 'delete from ivr_bank_business where bank_id=''' ||
												 var_bankid || ''' and cardkind=''' || var_cardkind || '''';
						insert into sqlhis values ('UpdateSQL', UpdateSQL, sysdate);
						execute immediate UpdateSQL;
						InsertSQL := 'insert into ivr_bank_business (bank_id,bank_desc,cardkind ,cardkind_desc,business_id,business_desc,createddate ,creadedby ,createdgroup      ) values (''' ||
												 var_bankid || ''',''' || var_bankdesc || ''',''' ||
												 var_cardkind || ''',''' || var_cardkinddesc ||
												 ''',''' || var_business || ''',''' ||
												 var_businessdesc || ''',sysdate,''' || I_Staffid ||
												 ''',''' || I_Rolegroupid || '''';
						insert into sqlhis values ('InsertSQL', InsertSQL, sysdate);
						execute immediate InsertSQL;
						UpdateSQL := 'update templist_' || I_Templist ||
												 ' set checkstatus=''1'',errdesc=''数据已经存在先删后插处理'' where temp_guid=''' ||
												 Var_Temp_guid || '''';
						execute immediate UpdateSQL;
					else
						if var_Dealflag = 'NOTDEAL' then
							UpdateSQL := 'update templist_' || I_Templist ||
													 ' set checkstatus=''2'',errdesc=''数据已经存在放弃处理'' where temp_guid=''' ||
													 Var_Temp_guid || '''';
							execute immediate UpdateSQL;
						end if;
					end if;
				end if;
			
			else
				InsertSQL := 'insert into ivr_bank_business (bank_id,bank_desc,cardkind ,cardkind_desc,business_id,business_desc,createddate ,creadedby ,createdgroup      ) values (''' ||
										 var_bankid || ''',''' || var_bankdesc || ''',''' ||
										 var_cardkind || ''',''' || var_cardkinddesc || ''',''' ||
										 var_business || ''',''' || var_businessdesc ||
										 ''',sysdate,''' || I_Staffid || ''',''' ||
										 I_Rolegroupid || '''';
			
				insert into sqlhis values ('InsertSQL', InsertSQL, sysdate);
				commit;
				execute immediate InsertSQL;
			
				UpdateSQL := 'update templist_' || I_Templist ||
										 ' set checkstatus=''1'',errdesc=''导入成功'' where temp_guid=''' ||
										 Var_Temp_guid || '''';
				execute immediate UpdateSQL;
			end if;
		
		else
			UpdateSQL := 'update templist_' || I_Templist ||
									 ' set checkstatus=''3'',errdesc=''银行编号为空'' where temp_guid=''' ||
									 Var_Temp_guid || '''';
			execute immediate UpdateSQL;
		end if;
	end loop;

	SelectSQL := 'select ''导入成功''||sum(case when checkstatus=''1'' then 1 else 0 end)||''  重复条目''||sum(case when checkstatus=''2'' then 1 else 0 end)||''  银行编号为空''||sum(case when checkstatus=''0'' then 1 else 0 end) from templist_' ||
							 I_Templist || '';
	execute immediate SelectSQL
		into Var_Outstring;
	Outstring := Var_Outstring;
	/*Exception
  When Others Then
    Begin
      rollback;
      Errorcode1 := Sqlcode;
      Errordesc1 := Sqlerrm;
      Insert Into Oracle_Sperror
        (Error, Errornum, Createddate, Type)
      Values
        (Errorcode1,
         Errordesc1 || Dbms_Utility.Format_Error_Backtrace(),
         Sysdate,
         'SP_IVRBUSINESSIMPORT默认支付商导入程序');
      Outstring := '' || Errordesc1 || '';
    End;*/

End SP_IVRBUSINESSIMPORT;
/
