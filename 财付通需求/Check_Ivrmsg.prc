CREATE OR REPLACE Procedure Check_Ivrmsg(i_Offer_No    In Varchar2, --ѯ�۵���
																				 i_Rolegroupid In Varchar2, ---��id
																				 i_Staffid     In Varchar2, ---��id
																				 Outstring     Out Varchar2) Is
	Rownum1              Int;
	Rownum2              Int;
	Var_Insurance_Status Varchar(100);
	Var_Handlegroup_Id   Varchar(100);
	Var_Handleby_Id      Varchar(100);
	Var_Pay_Method       Varchar(100);
	Var_Tradeno          Varchar(100);
	Var_Full_Policy_No   Varchar(100);
	Var_Carno            Varchar(100);
	Var_Branchno         Varchar(100);
	Var_Sendmode         Varchar(100);
	Var_Region           Varchar(100);
	Count1               Int;
	Count2               Int;
	Count3               Int;
	Count4               Int;
	Count5               Int;
	Count6               Int;
	Int_Countnum         Int;
	Errorcode1           Varchar(2000);
	Errordesc1           Varchar(2000);
	Is_Go                Varchar(20);

	/****************************************************
  Program_Name: check_ivr_msg
  Program_Desc: IVR֧��ǰ����У��
  Commentary:�Ϻ����ӱ�
  Revision: V1.0
  Author: Tomy
  Date: 2013-12-02
  ***************************************************/

Begin

	Begin
		Select T1.Insurance_Status,
					 T2.Handlegroup_Id,
					 T2.Handleby_Id,
					 T1.Pay_Method,
					 T1.Full_Policy_No,
					 T1.Tradeno
			Into Var_Insurance_Status,
					 Var_Handlegroup_Id,
					 Var_Handleby_Id,
					 Var_Pay_Method,
					 Var_Full_Policy_No,
					 Var_Tradeno
			From Tabccarinsurance T1
			Left Join Workorder2 T2
				On T1.Relation_Id = T2.Workorder_Guid
		 Where T1.Offerno = i_Offer_No;
		Is_Go := '1';
	Exception
		When No_Data_Found Then
			Is_Go := '0';
	End;
	If Is_Go != '0' Then
		If Var_Insurance_Status != '3' And Var_Insurance_Status != '1' And
			 Var_Insurance_Status != '27' And Var_Insurance_Status != '6' Then
			Outstring := i_Offer_No || '�õ�δ���ͨ��������IVR֧����';
		End If;
	
		If Var_Insurance_Status = '3' Or Var_Insurance_Status = '1' Or
			 Var_Insurance_Status = '27' Or Var_Insurance_Status = '6' Then
			If Var_Pay_Method = '2' Then
				Outstring := i_Offer_No || '����֧���ĵ��Ӳ��ܵ绰֧����';
			elsif Var_Pay_Method = '1' and Var_Tradeno is not null then
				Outstring := i_Offer_No || '������POS��ˢ���ɷ���ˮ�ţ����ܵ绰֧����';
			End If;
		
			If i_Rolegroupid != Var_Handlegroup_Id Or
				 i_Staffid != Var_Handleby_Id Then
				Outstring := 'û��Ȩ�޴���õ�' || i_Offer_No || '��';
			End If;
		
			Select Count(1)
				Into Rownum1
				From Tabcrelation T1
			 Where Offer_No = i_Offer_No
				 And T1.Status = '1';
			If Rownum1 > 0 Then
				Outstring := i_Offer_No || '�õ��Ѿ��ύ���ͣ������޸��κ���Ϣ!';
			End If;
			Select Count(T1.Sys_Id)
				Into Rownum2
				From Ivr_Limit T1
				Left Join Quotation T2
					On T1.Org_Id = Substr(T2.Branch_No, 1, 4)
			 Where T2.Offerno = i_Offer_No
				 And T1.Rolegroup_Id = i_Rolegroupid;
			If Rownum2 = 0 Then
				Outstring := i_Offer_No || '�õ��Ӷ�Ӧ�Ļ�������IVR֧��!';
			End If;
		
			If Var_Full_Policy_No Is Not Null Then
				Outstring := i_Offer_No || '�õ��Ѿ�ʵ�գ�';
			End If;
		
		End If;
		--�ж����Ͷ�������Ƶ绰֧��
		If Outstring Is Null And Is_Go != '0' Then
			Select a.Car_No, a.Branch_No, b.Send_Mode, b.Region_Level2
				Into Var_Carno, Var_Branchno, Var_Sendmode, Var_Region
				From Quotation a
				Left Join Quotation_Addressee b
					On a.Qt_Id = b.Qt_Id
			 Where a.Offerno = i_Offer_No;
			If Var_Sendmode != '2' Then
				--���ͷ�ʽΪ��ȡ�Ĳ����Ƶ绰֧��
				Select Count(*)
					Into Count1
					From Ivr_Carno
				 Where Orgid = Substr(Var_Branchno, 1, 6)
					 And Isuse = '1';
				Select Count(*)
					Into Count2
					From Ivr_Carno
				 Where Orgid = Substr(Var_Branchno, 1, 4)
					 And Isuse = '1';
				Select Count(*)
					Into Count3
					From Ivr_Carno
				 Where Orgid = Substr(Var_Branchno, 1, 6)
					 And Carno Like '%,��δ����,%'
					 And Isuse = '1';
				Select Count(*)
					Into Count4
					From Ivr_Carno
				 Where Orgid = Substr(Var_Branchno, 1, 4)
					 And Carno Like '%,��δ����,%'
					 And Isuse = '1';
				If (((Count1 > 0 And Count3 > 0) Or
					 ((Count1 < 1 And Count2 > 0) And Count4 > 0)) And
					 Var_Carno = '��δ����') Or Var_Carno != '��δ����' Then
					If Count1 > 0 And Var_Region Is Not Null Then
						Select Count(*)
							Into Count5
							From Ivr_Carno
						 Where 1 = 1
							 And Orgid = Substr(Var_Branchno, 1, 6)
							 And (Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 1) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 2) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 3) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 4) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 5) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 6) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno = '��δ����' Then
											'%,��δ����,%'
									 End) Or Carno Is Null)
							 And (Address = (Case
										 When Address Is Not Null Then
											Substr(Var_Region, 1, Length(Address))
										 Else
											Address
									 End) Or Address Is Null)
							 And Isuse = '1';
					End If;
					If Count1 > 0 And Var_Region Is Null Then
						Select Count(*)
							Into Count5
							From Ivr_Carno
						 Where 1 = 1
							 And Orgid = Substr(Var_Branchno, 1, 6)
							 And (Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 1) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 2) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 3) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 4) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 5) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 6) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno = '��δ����' Then
											'%,��δ����,%'
									 
									 End) Or Carno Is Null)
							 And Isuse = '1';
					End If;
					If Count1 < 1 And Count2 > 0 And Var_Region Is Not Null Then
						Select Count(*)
							Into Count6
							From Ivr_Carno
						 Where 1 = 1
							 And Orgid = Substr(Var_Branchno, 1, 4)
							 And (Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 1) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 2) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 3) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 4) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 5) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 6) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno = '��δ����' Then
											'%,��δ����,%'
									 End) Or Carno Is Null)
							 And (Address = (Case
										 When Address Is Not Null Then
											Substr(Var_Region, 1, Length(Address))
										 Else
											Address
									 End) Or Address Is Null)
							 And Isuse = '1';
					End If;
					If Count1 < 1 And Count2 > 0 And Var_Region Is Null Then
						Select Count(*)
							Into Count6
							From Ivr_Carno
						 Where 1 = 1
							 And Orgid = Substr(Var_Branchno, 1, 4)
							 And (Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 1) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 2) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 3) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 4) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 5) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno != '��δ����' Then
											'%,' || Substr(Var_Carno, 1, 6) || ',%'
										 Else
											Carno
									 End) Or Carno Like (Case
										 When Trim(Replace(Carno, ',')) Is Not Null And Var_Carno = '��δ����' Then
											'%,��δ����,%'
									 End) Or Carno Is Null)
							 And Isuse = '1';
					End If;
					If (Count1 > 0 And Count5 < 1) Or
						 (Count2 > 0 And Count1 < 1 And Count6 < 1) Then
						Outstring := '����Ϊ' || i_Offer_No || '�ı���Ϊ���Ͷ��������ʹ�õ绰֧����';
					End If;
				End If;
			End If;
		End If;
	
		If Outstring Is Null Then
			Select Count(*)
				Into Int_Countnum
				From Quotation R1
				Left Join Quotation_Addressee R2
					On R1.Qt_Id = R2.Qt_Id
			 Where R1.Offerno = i_Offer_No
				 And R2.Send_Mode = '3';
			If Int_Countnum > 0 Then
			
				Outstring := '�绰֧����֧�ֶ������ͣ����޸����ͷ�ʽ' || i_Offer_No;
			End If;
		End If;
	
		If Outstring Is Null Then
			Outstring := 'SUCC';
		End If;
	
	End If;

	If Is_Go = '0' Then
		Outstring := 'δ�ҵ�������ݻ��߸õ�δ�ύ������ˣ�';
		--Outstring := 'SUCC';
	End If;

Exception
	When Others Then
		Begin
			--�쳣����
			Errorcode1 := Sqlcode;
			Errordesc1 := Sqlerrm;
			Insert Into Oracle_Sperror
				(Error, Errornum, Createddate, Type)
			Values
				(Errorcode1,
				 Errordesc1 || Dbms_Utility.Format_Error_Backtrace(),
				 Sysdate,
				 ' check_ivrmsg ');
			Commit;
			Outstring := Errordesc1 || Dbms_Utility.Format_Error_Backtrace();
		End;
End Check_Ivrmsg;
/
