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
	   ,p_contract_no    VARCHAR2
	   ,p_pdate          VARCHAR2
	   ,p_name           VARCHAR2
	   ,p_tin            VARCHAR2
	   ,p_outstandingbdt VARCHAR2
	   ,p_outstandingusd VARCHAR2
	   ,p_clstatus       VARCHAR2
	   ,p_remarks        VARCHAR2
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
	FUNCTION cib_get_boundary_distance
	(
		p_aging NUMBER
	   ,p_dt    DATE
	   ,p_dd    NUMBER
	) RETURN VARCHAR2;
	PROCEDURE cib_update_closing_date;
	PROCEDURE cib_update_classif_date;
	FUNCTION get_state_frn_awof(p_contractno VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_writoff_date(p_contract VARCHAR2) RETURN VARCHAR2;
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
	   ,p_contract_no    VARCHAR2
	   ,p_pdate          VARCHAR2
	   ,p_name           VARCHAR2
	   ,p_tin            VARCHAR2
	   ,p_outstandingbdt VARCHAR2
	   ,p_outstandingusd VARCHAR2
	   ,p_clstatus       VARCHAR2
	   ,p_remarks        VARCHAR2
	   ,p_status         VARCHAR2
	) IS
	
		v_id NUMBER;
	
	BEGIN
		SELECT id_seq_writeoff.nextval INTO v_id FROM dual;
		INSERT INTO writeoffs
			(id
			,pan
			,contractno
			,contract_no
			,pdate
			,NAME
			,tin
			,outstandingbdt
			,outstandingusd
			,clstatus
			,remarks
			,status)
		VALUES
			(v_id
			,p_pan
			,p_contractno
			,p_contract_no
			,p_pdate
			,p_name
			,p_tin
			,p_outstandingbdt
			,p_outstandingusd
			,p_clstatus
			,p_remarks
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
		--DELETE FROM cib_new_customer;
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
	
		--v_id NUMBER;
	BEGIN
		--SELECT id_seq_closed.nextval INTO v_id FROM dual;
		INSERT INTO cib_all_closed_customer
			(pan
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
			(p_pan
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

	FUNCTION cib_get_boundary_distance
	(
		p_aging NUMBER
	   ,p_dt    DATE
	   ,p_dd    NUMBER
	) RETURN VARCHAR2 IS
	
		v_cdt    VARCHAR2(60);
		v_s      NUMBER;
		v_dis    NUMBER;
		v_year   VARCHAR2(20);
		v_month  VARCHAR2(20);
		v_rmonth NUMBER;
		v_dd     NUMBER := p_dd;
	
	BEGIN
		IF p_aging <= 2
		THEN
			v_cdt := '00000000';
			RETURN v_cdt;
		
		ELSE
			IF (p_aging >= 3 AND p_aging <= 5)
			THEN
				v_s := 3;
			ELSIF (p_aging >= 6 AND p_aging <= 8)
			THEN
				v_s := 6;
			ELSIF (p_aging >= 9 AND p_aging <= 14)
			THEN
				v_s := 9;
			ELSE
				v_s := 13;
			END IF;
		
			v_dis := p_aging - v_s;
		
			v_year   := to_char(p_dt, 'YYYY');
			v_month  := to_char(p_dt, 'MM');
			v_rmonth := v_month - v_dis;
		
			IF (v_rmonth < 0)
			THEN
				v_year   := (v_year - abs(floor(v_rmonth / 12)));
				v_rmonth := MOD(v_rmonth, 12);
				v_rmonth := abs(v_rmonth);
			ELSIF (v_rmonth = 0)
			THEN
				v_rmonth := 12;
				v_year   := v_year - 1;
			END IF;
			IF (v_rmonth = 2 AND p_dd > 28)
			THEN
				v_dd     := 28;
				v_dd     := to_char(v_dd);
				v_rmonth := to_char(v_rmonth);
			END IF;
		
			v_cdt := (v_dd || '/' || v_rmonth || '/' || v_year);
		
			RETURN v_cdt;
		
		END IF;
	
	END;

	PROCEDURE cib_update_closing_date IS
		vclosingdate DATE := '';
	BEGIN
		FOR z IN (SELECT t.closingdate
						,t.contract_no
						,t.id
				  FROM   submitted_new t
				  WHERE  t.closingdate != '00000000'
				  --AND    t.contract_no IN ('37370000001509', '37370000001517')
				  )
		LOOP
			BEGIN
				vclosingdate := to_date(z.closingdate, 'ddmmyyyy');
				UPDATE submitted_new t
				SET    t.closing_date = vclosingdate
				WHERE  t.id = z.id
				AND    t.contract_no = z.contract_no;
				COMMIT;
			EXCEPTION
				WHEN OTHERS THEN
					vclosingdate := to_date(z.closingdate, 'yyyymmdd');
					UPDATE submitted_new t
					SET    t.closing_date = vclosingdate
					WHERE  t.id = z.id
					AND    t.contract_no = z.contract_no;
					COMMIT;
			END;
			--dbms_output.put_line('Value Check: ' || vclosingdate);
			vclosingdate := '';
		END LOOP;
		--COMMIT;
	END;

	FUNCTION get_state_frn_awof(p_contractno VARCHAR2) RETURN VARCHAR2 IS
		v_state VARCHAR2(10) := '';
	BEGIN
		BEGIN
			SELECT t.state
			INTO   v_state
			FROM   actual_writeoffs t
			WHERE  t.contractno = p_contractno
			AND    rownum = 1;
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
		RETURN v_state;
	END;

	FUNCTION get_writoff_date(p_contract VARCHAR2) RETURN VARCHAR2 IS
		v_writeoffdate VARCHAR2(50) := '00';
	BEGIN
		BEGIN
			SELECT to_char(t.writeof_date, 'ddmmyyyy')
			INTO   v_writeoffdate
			FROM   actual_writeoffs t
			JOIN   submitted_new s
			ON     s.cno = t.contractno
			WHERE  t.contractno = p_contract
			AND    s.alivestatus = 'LV'
			AND    t.state <> '81';
		EXCEPTION
			WHEN OTHERS THEN
				v_writeoffdate := '00';
		END;
		RETURN v_writeoffdate;
	END;

	PROCEDURE cib_update_classif_date IS
		vclosingdate DATE := '';
	BEGIN
		FOR z IN (SELECT t.clasifieddate
						,t.contract_no
						,t.id
				  FROM   submitted_new t
				  WHERE  t.clasifieddate != '00000000'
				  AND    t.clasifieddate != '0'
				  --AND    t.contract_no IN ('37370000001509', '37370000001517')
				  )
		LOOP
			BEGIN
				vclosingdate := to_date(z.clasifieddate, 'dd/mm/yyyy');
				UPDATE submitted_new t
				SET    t.clasified_date = vclosingdate
				WHERE  t.id = z.id
				AND    t.contract_no = z.contract_no;
				COMMIT;
			EXCEPTION
				WHEN OTHERS THEN
					BEGIN
						vclosingdate := to_date(z.clasifieddate, 'ddmmyyyy');
						UPDATE submitted_new t
						SET    t.clasified_date = vclosingdate
						WHERE  t.id = z.id
						AND    t.contract_no = z.contract_no;
						COMMIT;
					
					EXCEPTION
						WHEN OTHERS THEN
							dbms_output.put_line('Value Check: ' || z.clasifieddate);
					END;
			END;
			--dbms_output.put_line('Value Check: ' || z.clasifieddate);
			vclosingdate := '';
		END LOOP;
		--COMMIT;
	END;

END;
/
