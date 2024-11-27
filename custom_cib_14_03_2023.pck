CREATE OR REPLACE PACKAGE custom_cib IS
	PROCEDURE nosubmitted_table_i
	(
		p_pan           VARCHAR2
	   ,p_name          VARCHAR2
	   ,p_cno           VARCHAR2
	   ,p_createdate    VARCHAR2
	   ,p_fname         VARCHAR2
	   ,p_mname         VARCHAR2
	   ,p_sex           VARCHAR2
	   ,p_address       VARCHAR2
	   ,p_region        VARCHAR2
	   ,p_bdlimit       VARCHAR2
	   ,p_usdlimit      VARCHAR2
	   ,p_bdate         VARCHAR2
	   ,p_tin           VARCHAR2
	   ,p_aging         VARCHAR2
	   ,p_outstanding   VARCHAR2
	   ,p_overdueamount VARCHAR2
	   ,p_nid           VARCHAR2
	   ,p_ficontract    VARCHAR2
	);

	PROCEDURE cib_writeoffs_table_i
	(
		p_pan            VARCHAR2
	   ,p_contractno     VARCHAR2
	   ,p_pdate          VARCHAR2
	   ,p_name           VARCHAR2
	   ,p_tin            VARCHAR2
	   ,p_outstandingbdt VARCHAR2
	   ,p_outstandingusd VARCHAR2
	   ,p_clstatus       VARCHAR2
	   ,p_remarks        VARCHAR2
	   ,p_state          VARCHAR2
	   ,p_status         VARCHAR2
	);

	PROCEDURE cib_submitted_table_i
	(
		p_id                  NUMBER
	   ,p_pan                 VARCHAR2
	   ,p_name                VARCHAR2
	   ,p_cno                 VARCHAR2
	   ,p_contract_no         VARCHAR2
	   ,p_createdate          VARCHAR2
	   ,p_fname               VARCHAR2
	   ,p_mname               VARCHAR2
	   ,p_sex                 VARCHAR2
	   ,p_address             VARCHAR2
	   ,p_region              VARCHAR2
	   ,p_bdlimit             VARCHAR2
	   ,p_usdlimit            VARCHAR2
	   ,p_bdate               VARCHAR2
	   ,p_tin                 VARCHAR2
	   ,p_nid                 VARCHAR2
	   ,p_aging               VARCHAR2
	   ,p_outstanding         VARCHAR2
	   ,p_overdueamount       VARCHAR2
	   ,p_clasifieddate       VARCHAR2
	   ,p_submitdate          VARCHAR2
	   ,p_lastupdate          VARCHAR2
	   ,p_updateflag          VARCHAR2
	   ,p_alivestatus         VARCHAR2
	   ,p_closingdate         VARCHAR2
	   ,p_otheridtype         NUMBER
	   ,p_otheridtypenr       VARCHAR2
	   ,p_otheridissuedate    VARCHAR2
	   ,p_otheridissuecountry VARCHAR2
	   ,p_print               VARCHAR2
	   ,p_ficontract          VARCHAR2
		
	);

	PROCEDURE cib_notsubmitted_table_i
	(
		p_id                  NUMBER
	   ,p_pan                 VARCHAR2
	   ,p_name                VARCHAR2
	   ,p_cno                 VARCHAR2
	   ,p_createdate          VARCHAR2
	   ,p_fname               VARCHAR2
	   ,p_mname               VARCHAR2
	   ,p_sex                 VARCHAR2
	   ,p_address             VARCHAR2
	   ,p_region              VARCHAR2
	   ,p_bdlimit             VARCHAR2
	   ,p_usdlimit            VARCHAR2
	   ,p_bdate               VARCHAR2
	   ,p_tin                 VARCHAR2
	   ,p_nid                 VARCHAR2
	   ,p_aging               VARCHAR2
	   ,p_outstanding         VARCHAR2
	   ,p_overdueamount       VARCHAR2
	   ,p_clasifieddate       VARCHAR2
	   ,p_alivestatus         VARCHAR2
	   ,p_updateflag          VARCHAR2
	   ,p_closingdate         VARCHAR2
	   ,p_otheridtype         VARCHAR2
	   ,p_otheridtypenr       VARCHAR2
	   ,p_otheridissuedate    VARCHAR2
	   ,p_otheridissuecountry VARCHAR2
	   ,p_ficontract          VARCHAR2
		
	);

	PROCEDURE cib_new_customer_table_u(
									   --p_id                  NUMBER
									   p_pan      VARCHAR2
									  ,p_cno      VARCHAR2
									  ,p_status   VARCHAR2
									  ,p_cycle    VARCHAR2
									  ,p_passport VARCHAR2);

	PROCEDURE cib_new_customer_table_i(
									   --p_id                  NUMBER
									   p_pan           VARCHAR2
									  ,p_name          VARCHAR2
									  ,p_cno           VARCHAR2
									  ,p_createdate    VARCHAR2
									  ,p_fname         VARCHAR2
									  ,p_mname         VARCHAR2
									  ,p_sex           VARCHAR2
									  ,p_address       VARCHAR2
									  ,p_region        VARCHAR2
									  ,p_bdlimit       VARCHAR2
									  ,p_usdlimit      VARCHAR2
									  ,p_bdate         VARCHAR2
									  ,p_tin           VARCHAR2
									  ,p_aging         VARCHAR2
									  ,p_outstanding   VARCHAR2
									  ,p_overdueamount VARCHAR2
									  ,p_nid           VARCHAR2
									  ,p_status        VARCHAR2
									  ,p_cycle         VARCHAR2
									  ,p_passport      VARCHAR2);
	PROCEDURE cib_closed_table_i
	(
		p_id          NUMBER
	   ,p_pan         VARCHAR2
	   ,p_cno         VARCHAR2
	   ,p_status      VARCHAR2
	   ,p_closingdate VARCHAR2
		
	);

	PROCEDURE cib_all_customer_table_i(
									   --p_id                  NUMBER
									   p_pan           VARCHAR2
									  ,p_name          VARCHAR2
									  ,p_cno           VARCHAR2
									  ,p_createdate    VARCHAR2
									  ,p_fname         VARCHAR2
									  ,p_mname         VARCHAR2
									  ,p_sex           VARCHAR2
									  ,p_address       VARCHAR2
									  ,p_region        VARCHAR2
									  ,p_bdlimit       VARCHAR2
									  ,p_usdlimit      VARCHAR2
									  ,p_bdate         VARCHAR2
									  ,p_tin           VARCHAR2
									  ,p_aging         VARCHAR2
									  ,p_outstanding   VARCHAR2
									  ,p_alivestatus   VARCHAR2
									  ,p_cycle         VARCHAR2
									  ,p_overdueamount VARCHAR2
									   ---,p_nid           VARCHAR2
									   
									   --,p_clasifieddate VARCHAR2
									   --,p_alivestatus   VARCHAR2
									   --,p_updateflag          VARCHAR2
									   --,p_alivestatus         VARCHAR2
									   --,p_closingdate         VARCHAR2
									   --,p_otheridtype         VARCHAR2
									   --,p_otheridtypenr       VARCHAR2
									   --,p_otheridissuedate    VARCHAR2
									   --,p_otheridissuecountry VARCHAR2
									   --,p_print               VARCHAR2
									   ---,output                OUT VARCHAR2
									   );

	PROCEDURE cib_all_closed_customer_table_i
	(
		p_pan        VARCHAR2
	   ,p_name       VARCHAR2
	   ,p_cno        VARCHAR2
	   ,p_createdate VARCHAR2
	   ,p_fname      VARCHAR2
	   ,p_mname      VARCHAR2
	   ,p_sex        VARCHAR2
	   ,p_address    VARCHAR2
	   ,p_region     VARCHAR2
	   ,p_bdlimit    VARCHAR2
	   ,p_usdlimit   VARCHAR2
	   ,p_bdate      VARCHAR2
	   ,p_tin        VARCHAR2
	);
END;
/
CREATE OR REPLACE PACKAGE BODY custom_cib IS

	PROCEDURE nosubmitted_table_i(
								  --p_id                  NUMBER
								  p_pan           VARCHAR2
								 ,p_name          VARCHAR2
								 ,p_cno           VARCHAR2
								 ,p_createdate    VARCHAR2
								 ,p_fname         VARCHAR2
								 ,p_mname         VARCHAR2
								 ,p_sex           VARCHAR2
								 ,p_address       VARCHAR2
								 ,p_region        VARCHAR2
								 ,p_bdlimit       VARCHAR2
								 ,p_usdlimit      VARCHAR2
								 ,p_bdate         VARCHAR2
								 ,p_tin           VARCHAR2
								 ,p_aging         VARCHAR2
								 ,p_outstanding   VARCHAR2
								 ,p_overdueamount VARCHAR2
								 ,p_nid           VARCHAR2
								 ,p_ficontract    VARCHAR2) IS
	
		v_id NUMBER;
	
	BEGIN
		SELECT id_seq.nextval INTO v_id FROM dual;
		INSERT INTO notsubmitted
			(id
			,pan
			,NAME
			,cno
			,createdate
			,fname
			,mname
			,sex
			,address
			,region
			,bdlimit
			,usdlimit
			,bdate
			,tin
			,aging
			,outstanding
			,overdueamount
			,nid
			,ficontract
			 
			 --,clasifieddate
			 --,alivestatus
			 )
		VALUES
			(v_id
			,p_pan
			,p_name
			,p_cno
			,p_createdate
			,p_fname
			,p_mname
			,p_sex
			,p_address
			,p_region
			,p_bdlimit
			,p_usdlimit
			,p_bdate
			,p_tin
			,p_aging
			,p_outstanding
			,p_overdueamount
			,p_nid
			,p_ficontract
			 
			 --,p_clasifieddate
			 --,p_alivestatus
			 );
		---output := 'Inserted successfully !';
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
			---    output := 'Insertion Error !';
	
	END;

	PROCEDURE cib_writeoffs_table_i
	(
		p_pan            VARCHAR2
	   ,p_contractno     VARCHAR2
	   ,p_pdate          VARCHAR2
	   ,p_name           VARCHAR2
	   ,p_tin            VARCHAR2
	   ,p_outstandingbdt VARCHAR2
	   ,p_outstandingusd VARCHAR2
	   ,p_clstatus       VARCHAR2
	   ,p_remarks        VARCHAR2
	   ,p_state          VARCHAR2
	   ,p_status         VARCHAR2
	) IS
	
		v_id NUMBER;
	
	BEGIN
		SELECT id_seq_writeoff.nextval INTO v_id FROM dual;
		INSERT INTO writeoffs
			(id
			,pan
			,contractno
			,pdate
			,NAME
			,tin
			,outstandingbdt
			,outstandingusd
			,clstatus
			,remarks
			,state
			,status)
		VALUES
			(v_id
			,p_pan
			,p_contractno
			,p_pdate
			,p_name
			,p_tin
			,p_outstandingbdt
			,p_outstandingusd
			,p_clstatus
			,p_remarks
			,p_state
			,p_status);
	
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
		
	END;

	PROCEDURE cib_submitted_table_i
	(
		p_id                  NUMBER
	   ,p_pan                 VARCHAR2
	   ,p_name                VARCHAR2
	   ,p_cno                 VARCHAR2
	   ,p_contract_no         VARCHAR2
	   ,p_createdate          VARCHAR2
	   ,p_fname               VARCHAR2
	   ,p_mname               VARCHAR2
	   ,p_sex                 VARCHAR2
	   ,p_address             VARCHAR2
	   ,p_region              VARCHAR2
	   ,p_bdlimit             VARCHAR2
	   ,p_usdlimit            VARCHAR2
	   ,p_bdate               VARCHAR2
	   ,p_tin                 VARCHAR2
	   ,p_nid                 VARCHAR2
	   ,p_aging               VARCHAR2
	   ,p_outstanding         VARCHAR2
	   ,p_overdueamount       VARCHAR2
	   ,p_clasifieddate       VARCHAR2
	   ,p_submitdate          VARCHAR2
	   ,p_lastupdate          VARCHAR2
	   ,p_updateflag          VARCHAR2
	   ,p_alivestatus         VARCHAR2
	   ,p_closingdate         VARCHAR2
	   ,p_otheridtype         NUMBER
	   ,p_otheridtypenr       VARCHAR2
	   ,p_otheridissuedate    VARCHAR2
	   ,p_otheridissuecountry VARCHAR2
	   ,p_print               VARCHAR2
	   ,p_ficontract          VARCHAR2
		
	) IS
	
		--v_id NUMBER;
	
	BEGIN
		--SELECT id_seq.nextval INTO v_id FROM dual;
		INSERT INTO submitted_new
			(id
			,pan
			,NAME
			,cno
			,contract_no
			,createdate
			,fname
			,mname
			,sex
			,address
			,region
			,bdlimit
			,usdlimit
			,bdate
			,tin
			,nid
			,aging
			,outstanding
			,overdueamount
			,clasifieddate
			,submitdate
			,lastupdate
			,updateflag
			,alivestatus
			,closingdate
			,otheridtype
			,otheridtypenr
			,otheridissuedate
			,otheridissuecountry
			,print
			,ficontract)
		VALUES
			(p_id
			,p_pan
			,p_name
			,p_cno
			,p_contract_no
			,p_createdate
			,p_fname
			,p_mname
			,p_sex
			,p_address
			,p_region
			,p_bdlimit
			,p_usdlimit
			,p_bdate
			,p_tin
			,p_nid
			,p_aging
			,p_outstanding
			,p_overdueamount
			,p_clasifieddate
			,p_submitdate
			,p_lastupdate
			,p_updateflag
			,p_alivestatus
			,p_closingdate
			,p_otheridtype
			,p_otheridtypenr
			,p_otheridissuedate
			,p_otheridissuecountry
			,p_print
			,p_ficontract);
		---output := 'Inserted successfully !';
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
			---    output := 'Insertion Error !';
	
	END;

	PROCEDURE cib_notsubmitted_table_i
	(
		p_id                  NUMBER
	   ,p_pan                 VARCHAR2
	   ,p_name                VARCHAR2
	   ,p_cno                 VARCHAR2
	   ,p_createdate          VARCHAR2
	   ,p_fname               VARCHAR2
	   ,p_mname               VARCHAR2
	   ,p_sex                 VARCHAR2
	   ,p_address             VARCHAR2
	   ,p_region              VARCHAR2
	   ,p_bdlimit             VARCHAR2
	   ,p_usdlimit            VARCHAR2
	   ,p_bdate               VARCHAR2
	   ,p_tin                 VARCHAR2
	   ,p_nid                 VARCHAR2
	   ,p_aging               VARCHAR2
	   ,p_outstanding         VARCHAR2
	   ,p_overdueamount       VARCHAR2
	   ,p_clasifieddate       VARCHAR2
	   ,p_alivestatus         VARCHAR2
	   ,p_updateflag          VARCHAR2
	   ,p_closingdate         VARCHAR2
	   ,p_otheridtype         VARCHAR2
	   ,p_otheridtypenr       VARCHAR2
	   ,p_otheridissuedate    VARCHAR2
	   ,p_otheridissuecountry VARCHAR2
	   ,p_ficontract          VARCHAR2
		
	) IS
	
		--v_id NUMBER;
	
	BEGIN
		--SELECT id_seq.nextval INTO v_id FROM dual;
		INSERT INTO notsubmitted
			(id
			,pan
			,NAME
			,cno
			,createdate
			,fname
			,mname
			,sex
			,address
			,region
			,bdlimit
			,usdlimit
			,bdate
			,tin
			,nid
			,aging
			,outstanding
			,overdueamount
			,clasifieddate
			,alivestatus
			,updateflag
			,closingdate
			,otheridtype
			,otheridtypenr
			,otheridissuedate
			,otheridissuecountry
			,ficontract)
		VALUES
			(p_id
			,p_pan
			,p_name
			,p_cno
			,p_createdate
			,p_fname
			,p_mname
			,p_sex
			,p_address
			,p_region
			,p_bdlimit
			,p_usdlimit
			,p_bdate
			,p_tin
			,p_nid
			,p_aging
			,p_outstanding
			,p_overdueamount
			,p_clasifieddate
			,p_alivestatus
			,p_updateflag
			,p_closingdate
			,p_otheridtype
			,p_otheridtypenr
			,p_otheridissuedate
			,p_otheridissuecountry
			,p_ficontract);
		---output := 'Inserted successfully !';
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
			---    output := 'Insertion Error !';
	
	END;

	PROCEDURE cib_new_customer_table_u(
									   --p_id                  NUMBER
									   p_pan      VARCHAR2
									  ,p_cno      VARCHAR2
									  ,p_status   VARCHAR2
									  ,p_cycle    VARCHAR2
									  ,p_passport VARCHAR2) IS
	
	BEGIN
		UPDATE cib_new_customer t
		
		SET    t.status   = p_status
			  ,t.cycle    = p_cycle
			  ,t.passport = p_passport
		WHERE  t.pan = p_pan
		AND    t.cno = p_cno;
		--and (t.status is not null or t.cycle is not null)
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
		
	END;

	PROCEDURE cib_new_customer_table_i(
									   --p_id                  NUMBER
									   p_pan           VARCHAR2
									  ,p_name          VARCHAR2
									  ,p_cno           VARCHAR2
									  ,p_createdate    VARCHAR2
									  ,p_fname         VARCHAR2
									  ,p_mname         VARCHAR2
									  ,p_sex           VARCHAR2
									  ,p_address       VARCHAR2
									  ,p_region        VARCHAR2
									  ,p_bdlimit       VARCHAR2
									  ,p_usdlimit      VARCHAR2
									  ,p_bdate         VARCHAR2
									  ,p_tin           VARCHAR2
									  ,p_aging         VARCHAR2
									  ,p_outstanding   VARCHAR2
									  ,p_overdueamount VARCHAR2
									  ,p_nid           VARCHAR2
									  ,p_status        VARCHAR2
									  ,p_cycle         VARCHAR2
									  ,p_passport      VARCHAR2) IS
	
		v_id NUMBER;
	
	BEGIN
		SELECT id_seq.nextval INTO v_id FROM dual;
		DELETE FROM cib_new_customer;
		INSERT INTO cib_new_customer
			(id
			,pan
			,NAME
			,cno
			,createdate
			,fname
			,mname
			,sex
			,address
			,region
			,bdlimit
			,usdlimit
			,bdate
			,tin
			,aging
			,outstanding
			,overdueamount
			,nid
			,status
			,cycle
			,passport)
		VALUES
			(v_id
			,p_pan
			,p_name
			,p_cno
			,p_createdate
			,p_fname
			,p_mname
			,p_sex
			,p_address
			,p_region
			,p_bdlimit
			,p_usdlimit
			,p_bdate
			,p_tin
			,p_aging
			,p_outstanding
			,p_overdueamount
			,p_nid
			,p_status
			,p_cycle
			,p_passport);
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
		
	END;

	PROCEDURE cib_closed_table_i
	(
		p_id          NUMBER
	   ,p_pan         VARCHAR2
	   ,p_cno         VARCHAR2
	   ,p_status      VARCHAR2
	   ,p_closingdate VARCHAR2
		
	) IS
	
	BEGIN
		INSERT INTO closed
			(id
			,pan
			,cno
			,status
			,closingdate)
		VALUES
			(p_id
			,p_pan
			,p_cno
			,p_status
			,p_closingdate);
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
		
	END;

	PROCEDURE cib_all_customer_table_i(
									   --p_id                  NUMBER
									   p_pan           VARCHAR2
									  ,p_name          VARCHAR2
									  ,p_cno           VARCHAR2
									  ,p_createdate    VARCHAR2
									  ,p_fname         VARCHAR2
									  ,p_mname         VARCHAR2
									  ,p_sex           VARCHAR2
									  ,p_address       VARCHAR2
									  ,p_region        VARCHAR2
									  ,p_bdlimit       VARCHAR2
									  ,p_usdlimit      VARCHAR2
									  ,p_bdate         VARCHAR2
									  ,p_tin           VARCHAR2
									  ,p_aging         VARCHAR2
									  ,p_outstanding   VARCHAR2
									  ,p_alivestatus   VARCHAR2
									  ,p_cycle         VARCHAR2
									  ,p_overdueamount VARCHAR2
									   ---,p_nid           VARCHAR2
									   
									   --,p_clasifieddate VARCHAR2
									   --,p_alivestatus   VARCHAR2
									   --,p_updateflag          VARCHAR2
									   --,p_alivestatus         VARCHAR2
									   --,p_closingdate         VARCHAR2
									   --,p_otheridtype         VARCHAR2
									   --,p_otheridtypenr       VARCHAR2
									   --,p_otheridissuedate    VARCHAR2
									   --,p_otheridissuecountry VARCHAR2
									   --,p_print               VARCHAR2
									   ---,output                OUT VARCHAR2
									   ) IS
	
		v_id NUMBER;
		/*pan 0 name1 cno2 createdate3 fname4 mname5 sex6 address7 region8 bdlimit9 usdlimit10 
        bdate11 tin12 aging13 outstanding14 alivestatus15 cycle16 overdue17*/
	BEGIN
		SELECT id_seq_all.nextval INTO v_id FROM dual;
		INSERT INTO cib_all_customer
			(id
			,pan
			,NAME
			,cno
			,createdate
			,fname
			,mname
			,sex
			,address
			,region
			,bdlimit
			,usdlimit
			,bdate
			,tin
			,aging
			,outstanding
			,alivestatus
			,cycle
			,overdueamount
			 --,nid
			 
			 --,clasifieddate
			 --,alivestatus
			 )
		VALUES
			(v_id
			,p_pan
			,p_name
			,p_cno
			,p_createdate
			,p_fname
			,p_mname
			,p_sex
			,p_address
			,p_region
			,p_bdlimit
			,p_usdlimit
			,p_bdate
			,p_tin
			,p_aging
			,p_outstanding
			,p_alivestatus
			,p_cycle
			,p_overdueamount
			 --,p_nid
			 
			 --,p_clasifieddate
			 --,p_alivestatus
			 );
		---output := 'Inserted successfully !';
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
			---    output := 'Insertion Error !';
	
	END;

	PROCEDURE cib_all_closed_customer_table_i
	(
		p_pan        VARCHAR2
	   ,p_name       VARCHAR2
	   ,p_cno        VARCHAR2
	   ,p_createdate VARCHAR2
	   ,p_fname      VARCHAR2
	   ,p_mname      VARCHAR2
	   ,p_sex        VARCHAR2
	   ,p_address    VARCHAR2
	   ,p_region     VARCHAR2
	   ,p_bdlimit    VARCHAR2
	   ,p_usdlimit   VARCHAR2
	   ,p_bdate      VARCHAR2
	   ,p_tin        VARCHAR2
	) IS
	
		v_id NUMBER;
	BEGIN
		SELECT id_seq_closed.nextval INTO v_id FROM dual;
		INSERT INTO cib_all_closed_customer
			(id
			,pan
			,NAME
			,cno
			,createdate
			,fname
			,mname
			,sex
			,address
			,region
			,bdlimit
			,usdlimit
			,bdate
			,tin)
		VALUES
			(v_id
			,p_pan
			,p_name
			,p_cno
			,p_createdate
			,p_fname
			,p_mname
			,p_sex
			,p_address
			,p_region
			,p_bdlimit
			,p_usdlimit
			,p_bdate
			,p_tin);
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
		
	END;

END;
/
