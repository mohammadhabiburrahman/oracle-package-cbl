CREATE OR REPLACE PACKAGE npsb_xml_pck IS
	PROCEDURE app_npstransactions_table_i
	(
		p_filename             app_npstransactions.filename%TYPE
	   ,p_cardnumber           app_npstransactions.cardnumber%TYPE
	   ,p_srn                  app_npstransactions.srn%TYPE
	   ,p_drn                  app_npstransactions.drn%TYPE
	   ,p_rrn                  app_npstransactions.rrn%TYPE
	   ,p_authorizationcode    app_npstransactions.authorizationcode%TYPE
	   ,p_transactiondate      VARCHAR2
	   ,p_transactiontype      app_npstransactions.transactiontype%TYPE
	   ,p_transactionamount    app_npstransactions.transactionamount%TYPE
	   ,p_settlementtme        VARCHAR2
	   ,p_requestcategory      app_npstransactions.requestcategory%TYPE
	   ,p_atmid                app_npstransactions.atmid%TYPE
	   ,p_sic                  app_npstransactions.sic%TYPE
	   ,p_atmlocation          app_npstransactions.atmlocation%TYPE
	   ,p_billingamount        app_npstransactions.billingamount%TYPE
	   ,p_billingphasedate     VARCHAR2
	   ,p_issuerbank           app_npstransactions.issuerbank%TYPE
	   ,p_acquirerbank         app_npstransactions.acquirerbank%TYPE
	   ,p_reconciliationamount app_npstransactions.reconciliationamount%TYPE
	   ,p_reconciliationdate   VARCHAR2
	   ,p_what_trx             app_npstransactions.what_trx%TYPE
	   ,p_srvc                 app_npstransactions.srvc%TYPE
	   ,p_cpid                 app_npstransactions.cpid%TYPE
	);

	PROCEDURE check_file_log
	(
		p_file_name VARCHAR2
	   ,p_result    OUT NUMBER
		
	);

	PROCEDURE app_npsfilelog_i
	
	(p_filename app_npsfilelog.filename%TYPE
	 
	,p_description app_npsfilelog.description%TYPE
	 
	,p_date app_npsfilelog.datetime%TYPE
	 
	,p_totaltxtcount app_npsfilelog.totaltxtcount%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY npsb_xml_pck IS
	PROCEDURE app_npstransactions_table_i
	(
		p_filename             app_npstransactions.filename%TYPE
	   ,p_cardnumber           app_npstransactions.cardnumber%TYPE
	   ,p_srn                  app_npstransactions.srn%TYPE
	   ,p_drn                  app_npstransactions.drn%TYPE
	   ,p_rrn                  app_npstransactions.rrn%TYPE
	   ,p_authorizationcode    app_npstransactions.authorizationcode%TYPE
	   ,p_transactiondate      VARCHAR2
	   ,p_transactiontype      app_npstransactions.transactiontype%TYPE
	   ,p_transactionamount    app_npstransactions.transactionamount%TYPE
	   ,p_settlementtme        VARCHAR2
	   ,p_requestcategory      app_npstransactions.requestcategory%TYPE
	   ,p_atmid                app_npstransactions.atmid%TYPE
	   ,p_sic                  app_npstransactions.sic%TYPE
	   ,p_atmlocation          app_npstransactions.atmlocation%TYPE
	   ,p_billingamount        app_npstransactions.billingamount%TYPE
	   ,p_billingphasedate     VARCHAR2
	   ,p_issuerbank           app_npstransactions.issuerbank%TYPE
	   ,p_acquirerbank         app_npstransactions.acquirerbank%TYPE
	   ,p_reconciliationamount app_npstransactions.reconciliationamount%TYPE
	   ,p_reconciliationdate   VARCHAR2
	   ,p_what_trx             app_npstransactions.what_trx%TYPE
	   ,p_srvc                 app_npstransactions.srvc%TYPE
	   ,p_cpid                 app_npstransactions.cpid%TYPE
		
	) IS
		v_id NUMBER;
	BEGIN
		SELECT app_nps_trans_id_seq.nextval INTO v_id FROM dual;
	
		--SELECT id_seq.nextval INTO v_id FROM dual;
		INSERT INTO app_npstransactions
			(id
			,filename
			,cardnumber
			,srn
			,drn
			,rrn
			,authorizationcode
			,transactiondate
			,transactiontype
			,transactionamount
			,settlementtme
			,requestcategory
			,atmid
			,sic
			,atmlocation
			,billingamount
			,billingphasedate
			,issuerbank
			,acquirerbank
			,reconciliationamount
			,reconciliationdate
			,what_trx
			,srvc
			,cpid)
		VALUES
			(v_id
			,p_filename
			,p_cardnumber
			,p_srn
			,p_drn
			,p_rrn
			,p_authorizationcode
			,p_transactiondate
			,p_transactiontype
			,p_transactionamount
			,p_settlementtme
			,p_requestcategory
			,p_atmid
			,p_sic
			,p_atmlocation
			,p_billingamount
			,p_billingphasedate
			,p_issuerbank
			,p_acquirerbank
			,p_reconciliationamount
			,p_reconciliationdate
			,p_what_trx
			,p_srvc
			,p_cpid);
	
		---output := 'Inserted successfully !';
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
			---    output := 'Insertion Error !';
	
	END;

	PROCEDURE check_file_log
	(
		p_file_name VARCHAR2
	   ,p_result    OUT NUMBER
		
	) IS
		v_result NUMBER := 0;
	BEGIN
		BEGIN
			SELECT 1 INTO v_result FROM app_npsfilelog WHERE filename = p_file_name;
			p_result := v_result;
		EXCEPTION
			WHEN OTHERS THEN
				p_result := v_result;
			
		END;
	END;

	PROCEDURE app_npsfilelog_i(p_filename app_npsfilelog.filename%TYPE
							   
							  ,p_description app_npsfilelog.description%TYPE
							   
							  ,p_date app_npsfilelog.datetime%TYPE
							   
							  ,p_totaltxtcount app_npsfilelog.totaltxtcount%TYPE) IS
		v_id NUMBER;
	BEGIN
		SELECT app_npsfilelog_id_seq.nextval INTO v_id FROM dual;
		INSERT INTO app_npsfilelog
			(id
			,filename
			,description
			,datetime
			,totaltxtcount)
		VALUES
			(v_id
			,p_filename
			,p_description
			,p_date
			,p_totaltxtcount);
	END;
	--INSERT INTO app_npsfilelog (filename,description,date,totaltxtcount)VALUES ('{0}', '{1}', '{2}', '{3}')", fileName, DateTime.Now, DateTime.Now.ToString("yyyyMMdd"), totalRecord);

END;
/
