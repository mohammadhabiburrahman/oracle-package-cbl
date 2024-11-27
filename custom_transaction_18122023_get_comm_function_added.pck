CREATE OR REPLACE PACKAGE custom_transaction IS
	FUNCTION get_sum_tras_amt_frm_contract
	(
		p_contract_no VARCHAR2
	   ,p_fromdate    DATE
	   ,p_to_date     DATE
	) RETURN NUMBER;

	FUNCTION get_sum_tras_amt_frm_contract(p_contract_no VARCHAR2) RETURN NUMBER;

	FUNCTION get_installment_balance(p_acc_no VARCHAR2) RETURN NUMBER;

	FUNCTION get_pur_trns_amt_contract
	(
		p_contract_no VARCHAR2
	   ,p_fromdate    DATE
	   ,p_to_date     DATE
	) RETURN NUMBER;

	FUNCTION get_ttl_bdt_outstanding_amt(p_con VARCHAR2) RETURN NUMBER;
	FUNCTION get_ttl_usd_outstanding_amt(p_con VARCHAR2) RETURN NUMBER;
	FUNCTION get_cash_w_amt_contract
	(
		p_contract_no VARCHAR2
	   ,p_fromdate    DATE
	   ,p_to_date     DATE
	) RETURN NUMBER;

	FUNCTION get_cash_usage_for_coll
	(
		p_contract_no VARCHAR2
	   ,p_fromdate    DATE
	   ,p_to_date     DATE
	) RETURN NUMBER;
	FUNCTION get_pur_usage_for_coll
	(
		p_contract_no VARCHAR2
	   ,p_fromdate    DATE
	   ,p_to_date     DATE
	) RETURN NUMBER;
	FUNCTION get_rrn_by_trncode(p_trncode NUMBER) RETURN NUMBER;
	FUNCTION get_bdt_by_doc(p_doc NUMBER) RETURN NUMBER;
	FUNCTION get_usd_by_doc(p_doc NUMBER) RETURN NUMBER;
	FUNCTION get_currency_by_doc(p_doc NUMBER) RETURN NUMBER;
	FUNCTION is_pos(p_docno NUMBER) RETURN NUMBER;
	FUNCTION is_pos_specfc_conditon(p_docno NUMBER) RETURN NUMBER;
	FUNCTION is_pos_specfc_conditon_new(p_docno NUMBER) RETURN NUMBER;
	FUNCTION get_bdt_outstanding_spec_date(p_contract_no VARCHAR2
										   --,p_fromdate    DATE
										  ,p_to_date DATE) RETURN NUMBER;
	FUNCTION get_pos_entry_mode
	(
		p_docno     NUMBER
	   ,p_card_no   VARCHAR2
	   ,p_tran_code VARCHAR2 := NULL
	) RETURN NUMBER;
	FUNCTION get_entcode_by_doc(p_doc NUMBER) RETURN NUMBER;
	FUNCTION get_pos_condition
	(
		p_docno     NUMBER
	   ,p_card_no   VARCHAR2 := NULL
	   ,p_tran_code VARCHAR2 := NULL
	) RETURN NUMBER;
	FUNCTION is_ecom
	(
		p_docno     NUMBER
	   ,p_card_no   VARCHAR2 := NULL
	   ,p_tran_code VARCHAR2 := NULL
	) RETURN NUMBER;
	FUNCTION get_bdt_os_spec_date_bb(p_contract_no VARCHAR2
									 -- ,p_fromdate    DATE
									,p_to_date DATE) RETURN NUMBER;
	FUNCTION get_usd_os_spec_date_bb(p_contract_no VARCHAR2
									 -- ,p_fromdate    DATE
									,p_to_date DATE) RETURN NUMBER;
	/*  FUNCTION get_bdt_purchase_by_cid
    (
        p_idclient NUMBER
       ,p_frm_date DATE
       ,p_to_date  DATE
    ) RETURN NUMBER;*/
	FUNCTION get_ttl_purchase_by_cid
	(
		p_idclient NUMBER
	   ,p_frm_date DATE
	   ,p_to_date  DATE
	) RETURN NUMBER;
	FUNCTION is_atm(p_doc_no NUMBER) RETURN NUMBER;
	FUNCTION is_qr
	(
		p_docno         NUMBER := 0
	   ,p_card_no       VARCHAR2 := NULL
	   ,p_approval_code VARCHAR2 := NULL
	   ,p_tran_code     VARCHAR2 := NULL
	) RETURN NUMBER;
	FUNCTION is_ecom_pos_qr_atm
	(
		p_docno     NUMBER
	   ,p_card_no   VARCHAR2 := NULL
	   ,p_tran_code VARCHAR2 := NULL
	) RETURN NUMBER;

	FUNCTION get_pos_con_online
	(
		p_docno     NUMBER
	   ,p_card_no   VARCHAR2 := NULL
	   ,p_tran_code VARCHAR2 := NULL
	) RETURN NUMBER;
	FUNCTION get_qr_rmt_onnus_rrn(p_doc NUMBER) RETURN NUMBER;
	FUNCTION get_exchange_rate(p_opdate DATE) RETURN NUMBER;
	FUNCTION get_comm_by_doc(p_doc NUMBER) RETURN NUMBER;

END custom_transaction;
/
CREATE OR REPLACE PACKAGE BODY custom_transaction IS
	FUNCTION get_sum_tras_amt_frm_contract
	(
		p_contract_no VARCHAR2
	   ,p_fromdate    DATE
	   ,p_to_date     DATE
	) RETURN NUMBER IS
		v_result           NUMBER := 0;
		v_credit_value     NUMBER := 0;
		v_debit_value      NUMBER := 0;
		v_credit_value_usd NUMBER := 0;
		v_debit_value_usd  NUMBER := 0;
		v_curr             NUMBER := 0;
		v_exchange_rate    NUMBER := 0;
		v_account_no_usd   VARCHAR2(20) := '';
		v_account_no_bdt   VARCHAR2(20) := '';
		v_balance_bdt      NUMBER := 0;
		v_balance_usd      NUMBER := 0;
	BEGIN
		BEGIN
			SELECT a.key
				  ,acc.currencyno
			INTO   v_account_no_usd
				  ,v_curr
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 840
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM', 'ITEMDEPOSITINT', 'ITEMINSTALLMENT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_usd := 0;
		END;
		BEGIN
		
			SELECT a.key
			INTO   v_account_no_bdt
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 50
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM', 'ITEMDEPOSITINT', 'ITEMINSTALLMENT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_bdt := 0;
		END;
		BEGIN
		
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_credit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.creditaccount = v_account_no_bdt
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_debit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitaccount = v_account_no_bdt
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			v_balance_bdt := nvl(v_debit_value, 0) - nvl(v_credit_value, 0);
			IF v_curr = 0
			THEN
				v_result := v_balance_bdt;
				RETURN v_result;
			ELSIF v_curr = 840
			THEN
				SELECT ex.destinamount
				INTO   v_exchange_rate
				FROM   texchangerate ex
				WHERE  ex.valuedate = (SELECT s.operdate FROM tseance s)
				AND    ex.sourcecurrency = 840
				AND    ex.destincurrency = 50;
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_credit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.creditaccount = v_account_no_usd
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_debit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitaccount = v_account_no_usd
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			
				v_debit_value_usd := v_exchange_rate * v_debit_value_usd;
				--dbms_output.put_line(v_debit_value_usd);
				v_credit_value_usd := v_exchange_rate * v_credit_value_usd;
				v_balance_usd      := v_debit_value_usd - v_credit_value_usd;
				--dbms_output.put_line(v_balance_bdt);
				--dbms_output.put_line(v_balance_usd);
			END IF;
			v_result := v_balance_usd + v_balance_bdt;
			RETURN v_result;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
	END;

	FUNCTION get_sum_tras_amt_frm_contract(p_contract_no VARCHAR2) RETURN NUMBER IS
		v_result           NUMBER := 0;
		v_credit_value     NUMBER := 0;
		v_debit_value      NUMBER := 0;
		v_credit_value_usd NUMBER := 0;
		v_debit_value_usd  NUMBER := 0;
		v_curr             NUMBER := 0;
		v_exchange_rate    NUMBER := 0;
		v_account_no_usd   VARCHAR2(20) := '';
		v_account_no_bdt   VARCHAR2(20) := '';
		v_account_no_mr    VARCHAR2(20) := '';
	
		v_balance_bdt NUMBER := 0;
		v_balance_usd NUMBER := 0;
		v_balance_mr  NUMBER := 0;
	
		v_curr_mr NUMBER := 0;
	BEGIN
		BEGIN
			SELECT a.key
				  ,acc.currencyno
			INTO   v_account_no_mr
				  ,v_curr_mr
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 9999
				  
			AND    t.itemname IN ('ITEMBONUS')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_mr := 0;
		END;
	
		BEGIN
			SELECT a.key
				  ,acc.currencyno
			INTO   v_account_no_usd
				  ,v_curr
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 840
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM', 'ITEMDEPOSITINT', 'ITEMINSTALLMENT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_usd := 0;
		END;
		BEGIN
		
			SELECT a.key
			INTO   v_account_no_bdt
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 50
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM', 'ITEMDEPOSITINT', 'ITEMINSTALLMENT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_bdt := 0;
		END;
	
		IF v_curr_mr <> 0
		THEN
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_credit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.creditaccount = v_account_no_mr;
				--AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR (p_fromdate IS NULL AND p_to_date IS NULL));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_debit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitaccount = v_account_no_mr;
				--AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR (p_fromdate IS NULL AND p_to_date IS NULL));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			v_balance_mr := nvl(v_debit_value, 0) - nvl(v_credit_value, 0);
			v_result     := v_balance_mr;
			RETURN v_result;
		ELSE
		
			BEGIN
			
				BEGIN
					SELECT SUM(nvl(a.value, 0))
					INTO   v_credit_value
					FROM   tentry    a
						  ,tdocument b
					WHERE  a.branch = 1
					AND    b.branch = a.branch
					AND    b.docno = a.docno
					AND    b.newdocno IS NULL
					AND    a.creditaccount = v_account_no_bdt;
					--AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR (p_fromdate IS NULL AND p_to_date IS NULL));
				EXCEPTION
					WHEN OTHERS THEN
						NULL;
				END;
				BEGIN
					SELECT SUM(nvl(a.value, 0))
					INTO   v_debit_value
					FROM   tentry    a
						  ,tdocument b
					WHERE  a.branch = 1
					AND    b.branch = a.branch
					AND    b.docno = a.docno
					AND    b.newdocno IS NULL
					AND    a.debitaccount = v_account_no_bdt;
					--AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR (p_fromdate IS NULL AND p_to_date IS NULL));
				EXCEPTION
					WHEN OTHERS THEN
						NULL;
				END;
				v_balance_bdt := nvl(v_debit_value, 0) - nvl(v_credit_value, 0);
				IF v_curr = 0
				THEN
					v_result := v_balance_bdt;
					RETURN v_result;
				ELSIF v_curr = 840
				THEN
					SELECT ex.destinamount
					INTO   v_exchange_rate
					FROM   texchangerate ex
					WHERE  ex.valuedate = (SELECT s.operdate FROM tseance s)
					AND    ex.sourcecurrency = 840
					AND    ex.destincurrency = 50;
				
					SELECT nvl(SUM(nvl(a.value, 0)), 0)
					INTO   v_credit_value_usd
					FROM   tentry    a
						  ,tdocument b
					WHERE  a.branch = 1
					AND    b.branch = a.branch
					AND    b.docno = a.docno
					AND    b.newdocno IS NULL
					AND    a.creditaccount = v_account_no_usd;
					--AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR (p_fromdate IS NULL AND p_to_date IS NULL));
				
					SELECT nvl(SUM(nvl(a.value, 0)), 0)
					INTO   v_debit_value_usd
					FROM   tentry    a
						  ,tdocument b
					WHERE  a.branch = 1
					AND    b.branch = a.branch
					AND    b.docno = a.docno
					AND    b.newdocno IS NULL
					AND    a.debitaccount = v_account_no_usd;
					--AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR (p_fromdate IS NULL AND p_to_date IS NULL));
				
					v_debit_value_usd := v_exchange_rate * v_debit_value_usd;
					--dbms_output.put_line(v_debit_value_usd);
					v_credit_value_usd := v_exchange_rate * v_credit_value_usd;
					v_balance_usd      := v_debit_value_usd - v_credit_value_usd;
					--dbms_output.put_line(v_balance_bdt);
					--dbms_output.put_line(v_balance_usd);
				END IF;
				v_result := v_balance_usd + v_balance_bdt;
				RETURN v_result;
			EXCEPTION
				WHEN OTHERS THEN
					v_result := 0;
					RETURN v_result;
			END;
		END IF;
	END;

	FUNCTION get_installment_balance(p_acc_no VARCHAR2) RETURN NUMBER IS
		v_installment_amount NUMBER;
		v_acc_no             VARCHAR2(20);
	BEGIN
		BEGIN
			WITH acc_info AS
			 (SELECT branch
					,accountno
					,currencyno
					,remain
			  FROM   a4m.taccount)
			SELECT /*x.BRANCH,x.contract_no,x.MAINNO,x.LINKNO,x.LINKNAME,x.INSTALLMENT_ACCOUNT_NO,*/
			 x.account_no
			,SUM(acc_info.remain) installment_amount
			INTO   v_acc_no
				  ,v_installment_amount
			FROM   (SELECT ci.branch
						  ,ci.no contract_no
						  ,ci.key account_no
						  ,cl.mainno
						  ,cl.linkno
						  ,cl.linkname
						  ,(SELECT key FROM a4m.tcontractitem WHERE no = cl.linkno) installment_account_no
					FROM   a4m.tcontractitem ci
						  ,a4m.tcontractlink cl
					WHERE  ci.branch = 1
					AND    cl.branch = ci.branch
					AND    cl.mainno = ci.no
					AND    ci.key = p_acc_no
					AND    cl.linkname = 'INSTALLMENT') x
				  ,acc_info
			WHERE  x.branch = acc_info.branch
			AND    x.installment_account_no = acc_info.accountno
			AND    acc_info.currencyno =
				   (SELECT currencyno FROM a4m.taccount WHERE accountno = x.account_no)
			GROUP  BY x.account_no;
		
			RETURN v_installment_amount;
		EXCEPTION
			WHEN OTHERS THEN
				v_installment_amount := 0;
				RETURN v_installment_amount;
		END;
	END;

	FUNCTION get_pur_trns_amt_contract
	(
		p_contract_no VARCHAR2
	   ,p_fromdate    DATE
	   ,p_to_date     DATE
	) RETURN NUMBER IS
		v_result           NUMBER := 0;
		v_credit_value     NUMBER := 0;
		v_debit_value      NUMBER := 0;
		v_credit_value_usd NUMBER := 0;
		v_debit_value_usd  NUMBER := 0;
		v_curr             NUMBER := 0;
		v_exchange_rate    NUMBER := 0;
		v_account_no_usd   VARCHAR2(20) := '';
		v_account_no_bdt   VARCHAR2(20) := '';
		v_balance_bdt      NUMBER := 0;
		v_balance_usd      NUMBER := 0;
	BEGIN
		BEGIN
			SELECT a.key
				  ,acc.currencyno
			INTO   v_account_no_usd
				  ,v_curr
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 840
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM', 'ITEMDEPOSITINT', 'ITEMINSTALLMENT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_usd := 0;
		END;
		BEGIN
		
			SELECT a.key
			INTO   v_account_no_bdt
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 50
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM', 'ITEMDEPOSITINT', 'ITEMINSTALLMENT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_bdt := 0;
		END;
		BEGIN
		
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_credit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (63, 203, 98, 341, 805, 104)
				AND    a.creditaccount = v_account_no_bdt
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_debit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (63, 203, 98, 341, 805, 104)
				AND    a.debitaccount = v_account_no_bdt
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			v_balance_bdt := nvl(v_debit_value, 0) - nvl(v_credit_value, 0);
			IF v_curr = 0
			THEN
				v_result := v_balance_bdt;
				RETURN v_result;
			ELSIF v_curr = 840
			THEN
				SELECT ex.destinamount
				INTO   v_exchange_rate
				FROM   texchangerate ex
				WHERE  ex.valuedate = (SELECT s.operdate FROM tseance s)
				AND    ex.sourcecurrency = 840
				AND    ex.destincurrency = 50;
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_credit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (63, 203, 98, 341, 805, 104) ---purchase
				AND    a.creditaccount = v_account_no_usd
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_debit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (63, 203, 98, 341, 805, 104)
				AND    a.debitaccount = v_account_no_usd
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			
				v_debit_value_usd := v_exchange_rate * v_debit_value_usd;
				--dbms_output.put_line(v_debit_value_usd);
				v_credit_value_usd := v_exchange_rate * v_credit_value_usd;
				v_balance_usd      := v_debit_value_usd - v_credit_value_usd;
				--dbms_output.put_line(v_balance_bdt);
				--dbms_output.put_line(v_balance_usd);
			END IF;
			v_result := v_balance_usd + v_balance_bdt;
			RETURN v_result;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
	END get_pur_trns_amt_contract;

	FUNCTION get_ttl_bdt_outstanding_amt(p_con VARCHAR2) RETURN NUMBER IS
		v_outstanding_amt NUMBER := 0;
		v_installment_out NUMBER := 0;
		v_bdt_account     VARCHAR2(20) := '';
	BEGIN
		BEGIN
			SELECT t.key
			INTO   v_bdt_account
			FROM   tcontractitem t
			
			JOIN   taccount a
			ON     a.accountno = t.key
			
			JOIN   tcontracttypeitemname i
			ON     t.itemcode = i.itemcode
			WHERE  t.no = p_con
			AND    i.itemname = 'ITEMDEPOSITDOM';
		EXCEPTION
			WHEN OTHERS THEN
				v_bdt_account := '0';
		END;
		v_installment_out := get_installment_balance(v_bdt_account);
		BEGIN
			SELECT nvl(a.remain, 0)
			INTO   v_outstanding_amt
			FROM   tcontractitem t
			
			JOIN   taccount a
			ON     a.accountno = t.key
			
			JOIN   tcontracttypeitemname i
			ON     t.itemcode = i.itemcode
			
			WHERE  i.itemname = 'ITEMDEPOSITDOM'
			AND    a.accountno = v_bdt_account;
		EXCEPTION
			WHEN OTHERS THEN
				v_outstanding_amt := 0;
		END;
		v_outstanding_amt := v_outstanding_amt + v_installment_out;
	
		RETURN v_outstanding_amt;
	END;

	FUNCTION get_ttl_usd_outstanding_amt(p_con VARCHAR2) RETURN NUMBER IS
		v_outstanding_amt NUMBER := 0;
		v_installment_out NUMBER := 0;
		v_usd_account     VARCHAR2(20) := '';
	BEGIN
		BEGIN
			SELECT t.key
			INTO   v_usd_account
			FROM   tcontractitem t
			
			JOIN   taccount a
			ON     a.accountno = t.key
			
			JOIN   tcontracttypeitemname i
			ON     t.itemcode = i.itemcode
			WHERE  t.no = p_con
			AND    i.itemname = 'ITEMDEPOSITINT';
		EXCEPTION
			WHEN OTHERS THEN
				v_usd_account := '0';
		END;
		v_installment_out := get_installment_balance(v_usd_account);
		BEGIN
			SELECT nvl(a.remain, 0)
			INTO   v_outstanding_amt
			FROM   tcontractitem t
			
			JOIN   taccount a
			ON     a.accountno = t.key
			
			JOIN   tcontracttypeitemname i
			ON     t.itemcode = i.itemcode
			
			WHERE  i.itemname = 'ITEMDEPOSITINT'
			AND    a.accountno = v_usd_account;
		EXCEPTION
			WHEN OTHERS THEN
				v_outstanding_amt := 0;
		END;
		v_outstanding_amt := v_outstanding_amt + v_installment_out;
	
		RETURN v_outstanding_amt;
	END;

	FUNCTION get_cash_w_amt_contract
	(
		p_contract_no VARCHAR2
	   ,p_fromdate    DATE
	   ,p_to_date     DATE
	) RETURN NUMBER IS
		v_result           NUMBER := 0;
		v_credit_value     NUMBER := 0;
		v_debit_value      NUMBER := 0;
		v_credit_value_usd NUMBER := 0;
		v_debit_value_usd  NUMBER := 0;
		v_curr             NUMBER := 0;
		v_exchange_rate    NUMBER := 0;
		v_account_no_usd   VARCHAR2(20) := '';
		v_account_no_bdt   VARCHAR2(20) := '';
		v_balance_bdt      NUMBER := 0;
		v_balance_usd      NUMBER := 0;
	BEGIN
		BEGIN
			SELECT a.key
				  ,acc.currencyno
			INTO   v_account_no_usd
				  ,v_curr
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 840
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM', 'ITEMDEPOSITINT', 'ITEMINSTALLMENT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_usd := 0;
		END;
		BEGIN
		
			SELECT a.key
			INTO   v_account_no_bdt
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 50
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM', 'ITEMDEPOSITINT', 'ITEMINSTALLMENT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_bdt := 0;
		END;
		BEGIN
		
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_credit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (53) ---Cash Withdraw
				AND    a.creditaccount = v_account_no_bdt
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_debit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (53) ---Cash Withdraw
				AND    a.debitaccount = v_account_no_bdt
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			v_balance_bdt := nvl(v_debit_value, 0) - nvl(v_credit_value, 0);
			IF v_curr = 0
			THEN
				v_result := v_balance_bdt;
				RETURN v_result;
			ELSIF v_curr = 840
			THEN
				SELECT ex.destinamount
				INTO   v_exchange_rate
				FROM   texchangerate ex
				WHERE  ex.valuedate = (SELECT s.operdate FROM tseance s)
				AND    ex.sourcecurrency = 840
				AND    ex.destincurrency = 50;
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_credit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (53) ---Cash Withdraw
				AND    a.creditaccount = v_account_no_usd
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_debit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (53)
				AND    a.debitaccount = v_account_no_usd
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			
				v_debit_value_usd := v_exchange_rate * v_debit_value_usd;
				--dbms_output.put_line(v_debit_value_usd);
				v_credit_value_usd := v_exchange_rate * v_credit_value_usd;
				v_balance_usd      := v_debit_value_usd - v_credit_value_usd;
				--dbms_output.put_line(v_balance_bdt);
				--dbms_output.put_line(v_balance_usd);
			END IF;
			v_result := v_balance_usd + v_balance_bdt;
			RETURN v_result;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
	END get_cash_w_amt_contract;

	FUNCTION get_cash_usage_for_coll
	(
		p_contract_no VARCHAR2
	   ,p_fromdate    DATE
	   ,p_to_date     DATE
	) RETURN NUMBER IS
		v_result           NUMBER := 0;
		v_credit_value     NUMBER := 0;
		v_debit_value      NUMBER := 0;
		v_credit_value_usd NUMBER := 0;
		v_debit_value_usd  NUMBER := 0;
		v_curr             NUMBER := 0;
		v_exchange_rate    NUMBER := 0;
		v_account_no_usd   VARCHAR2(20) := '';
		v_account_no_bdt   VARCHAR2(20) := '';
		v_balance_bdt      NUMBER := 0;
		v_balance_usd      NUMBER := 0;
	BEGIN
		BEGIN
			SELECT a.key
				  ,acc.currencyno
			INTO   v_account_no_usd
				  ,v_curr
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 840
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM', 'ITEMDEPOSITINT', 'ITEMINSTALLMENT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_usd := 0;
		END;
		BEGIN
		
			SELECT a.key
			INTO   v_account_no_bdt
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 50
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM', 'ITEMDEPOSITINT', 'ITEMINSTALLMENT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_bdt := 0;
		END;
		BEGIN
		
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_credit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (467
										 ,435
										 ,408
										 ,135
										 ,410
										 ,575
										 ,93
										 ,94
										 ,433
										 ,443
										 ,701
										 ,475
										 ,871
										 ,742
										 ,802
										 ,481
										 ,741
										 ,803
										 ,800
										 ,801
										 ,53
										 ,185
										 ,203
										 ,343
										 ,148) ---Cash usage
				AND    a.creditaccount = v_account_no_bdt
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_debit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (467
										 ,435
										 ,408
										 ,135
										 ,410
										 ,575
										 ,93
										 ,94
										 ,433
										 ,443
										 ,701
										 ,475
										 ,871
										 ,742
										 ,802
										 ,481
										 ,741
										 ,803
										 ,800
										 ,801
										 ,53
										 ,185
										 ,203
										 ,343
										 ,148) ---Cash Usage
				AND    a.debitaccount = v_account_no_bdt
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			v_balance_bdt := nvl(v_debit_value, 0) - nvl(v_credit_value, 0);
			IF v_curr = 0
			THEN
				v_result := v_balance_bdt;
				RETURN v_result;
			ELSIF v_curr = 840
			THEN
				SELECT ex.destinamount
				INTO   v_exchange_rate
				FROM   texchangerate ex
				WHERE  ex.valuedate = (SELECT s.operdate FROM tseance s)
				AND    ex.sourcecurrency = 840
				AND    ex.destincurrency = 50;
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_credit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (467
										 ,435
										 ,408
										 ,135
										 ,410
										 ,575
										 ,93
										 ,94
										 ,433
										 ,443
										 ,701
										 ,475
										 ,871
										 ,742
										 ,802
										 ,481
										 ,741
										 ,803
										 ,800
										 ,801
										 ,53
										 ,185
										 ,203
										 ,343
										 ,148) ---Cash Usage
				AND    a.creditaccount = v_account_no_usd
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_debit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (467
										 ,435
										 ,408
										 ,135
										 ,410
										 ,575
										 ,93
										 ,94
										 ,433
										 ,443
										 ,701
										 ,475
										 ,871
										 ,742
										 ,802
										 ,481
										 ,741
										 ,803
										 ,800
										 ,801
										 ,53
										 ,185
										 ,203
										 ,343
										 ,148) --Cash usage for collection
				AND    a.debitaccount = v_account_no_usd
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			
				v_debit_value_usd := v_exchange_rate * v_debit_value_usd;
				--dbms_output.put_line(v_debit_value_usd);
				v_credit_value_usd := v_exchange_rate * v_credit_value_usd;
				v_balance_usd      := v_debit_value_usd - v_credit_value_usd;
				--dbms_output.put_line(v_balance_bdt);
				--dbms_output.put_line(v_balance_usd);
			END IF;
			v_result := v_balance_usd + v_balance_bdt;
			RETURN v_result;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
	END get_cash_usage_for_coll;

	FUNCTION get_pur_usage_for_coll
	(
		p_contract_no VARCHAR2
	   ,p_fromdate    DATE
	   ,p_to_date     DATE
	) RETURN NUMBER IS
		v_result           NUMBER := 0;
		v_credit_value     NUMBER := 0;
		v_debit_value      NUMBER := 0;
		v_credit_value_usd NUMBER := 0;
		v_debit_value_usd  NUMBER := 0;
		v_curr             NUMBER := 0;
		v_exchange_rate    NUMBER := 0;
		v_account_no_usd   VARCHAR2(20) := '';
		v_account_no_bdt   VARCHAR2(20) := '';
		v_balance_bdt      NUMBER := 0;
		v_balance_usd      NUMBER := 0;
	BEGIN
		BEGIN
			SELECT a.key
				  ,acc.currencyno
			INTO   v_account_no_usd
				  ,v_curr
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 840
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM', 'ITEMDEPOSITINT', 'ITEMINSTALLMENT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_usd := 0;
		END;
		BEGIN
		
			SELECT a.key
			INTO   v_account_no_bdt
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 50
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM', 'ITEMDEPOSITINT', 'ITEMINSTALLMENT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_bdt := 0;
		END;
		BEGIN
		
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_credit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (63, 98, 341) ---Purchage usage for collection
				AND    a.creditaccount = v_account_no_bdt
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_debit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (63, 98, 341) ---Purchage usage for collection
				AND    a.debitaccount = v_account_no_bdt
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			v_balance_bdt := nvl(v_debit_value, 0) - nvl(v_credit_value, 0);
			IF v_curr = 0
			THEN
				v_result := v_balance_bdt;
				RETURN v_result;
			ELSIF v_curr = 840
			THEN
				SELECT ex.destinamount
				INTO   v_exchange_rate
				FROM   texchangerate ex
				WHERE  ex.valuedate = (SELECT s.operdate FROM tseance s)
				AND    ex.sourcecurrency = 840
				AND    ex.destincurrency = 50;
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_credit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (63, 98, 341) ---Purchage usage for collection
				AND    a.creditaccount = v_account_no_usd
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_debit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitentcode IN (63, 98, 341) ---Purchage usage for collection
				AND    a.debitaccount = v_account_no_usd
				AND    (b.opdate BETWEEN p_fromdate AND p_to_date OR
					  (p_fromdate IS NULL AND p_to_date IS NULL));
			
				v_debit_value_usd := v_exchange_rate * v_debit_value_usd;
				--dbms_output.put_line(v_debit_value_usd);
				v_credit_value_usd := v_exchange_rate * v_credit_value_usd;
				v_balance_usd      := v_debit_value_usd - v_credit_value_usd;
				--dbms_output.put_line(v_balance_bdt);
				--dbms_output.put_line(v_balance_usd);
			END IF;
			v_result := v_balance_usd + v_balance_bdt;
			RETURN v_result;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
	END get_pur_usage_for_coll;

	FUNCTION get_rrn_by_trncode(p_trncode NUMBER) RETURN NUMBER IS
		v_rrn NUMBER := 0;
	BEGIN
		BEGIN
			SELECT t.id
			INTO   v_rrn
			FROM   a4m.textwitran t
			JOIN   a4m.textran tr
			ON     tr.code = t.code
			AND    tr.branch = t.branch
			WHERE  t.code = p_trncode;
		EXCEPTION
			WHEN OTHERS THEN
				v_rrn := NULL;
		END;
		RETURN v_rrn;
	END;

	FUNCTION get_bdt_by_doc(p_doc NUMBER) RETURN NUMBER IS
		--v_doc_count NUMBER := 0;
		v_amount NUMBER := 0;
	BEGIN
		BEGIN
			SELECT amt
			INTO   v_amount
			FROM   (SELECT t.value amt
					--INTO   v_amount
					FROM   a4m.tentry t
					WHERE  t.docno = p_doc
					AND    t.branch = 1
					AND    (t.debitaccount = 20203050007 OR t.creditaccount = 20203050007)
					ORDER  BY t.no ASC)
			WHERE  rownum = 1;
		EXCEPTION
			WHEN no_data_found THEN
				BEGIN
					SELECT t.value
					INTO   v_amount
					FROM   a4m.tentry t
					WHERE  t.docno = p_doc
					AND    t.branch = 1
					AND    t.no = 1
					AND    get_currency_by_doc(p_doc) = 50;
				EXCEPTION
					WHEN OTHERS THEN
						v_amount := 0;
				END;
			WHEN OTHERS THEN
				v_amount := 0;
		END;
	
		RETURN v_amount;
	END;

	FUNCTION get_usd_by_doc(p_doc NUMBER) RETURN NUMBER IS
		--v_doc_count NUMBER := 0;
		v_amount NUMBER := 0;
	BEGIN
		BEGIN
		
			SELECT amt
			INTO   v_amount
			FROM   (SELECT t.value amt
					--INTO   v_amount
					FROM   a4m.tentry t
					WHERE  t.docno = p_doc
					AND    t.branch = 1
					AND    (t.debitaccount = 20203840001 OR t.creditaccount = 20203840001)
					ORDER  BY t.no ASC)
			WHERE  rownum = 1;
		EXCEPTION
			WHEN no_data_found THEN
				BEGIN
					SELECT t.value
					INTO   v_amount
					FROM   a4m.tentry t
					WHERE  t.docno = p_doc
					AND    t.branch = 1
					AND    t.no = 1
					AND    get_currency_by_doc(p_doc) = 840;
				
				EXCEPTION
					WHEN OTHERS THEN
						v_amount := 0;
				END;
			WHEN OTHERS THEN
				v_amount := 0;
		END;
		RETURN v_amount;
	END;

	FUNCTION get_currency_by_doc(p_doc NUMBER) RETURN NUMBER IS
		v_currency NUMBER := 0;
	BEGIN
	
		BEGIN
		
			SELECT DISTINCT t.currency
			INTO   v_currency
			FROM   tposcheque t
			WHERE  t.docno = p_doc
			AND    t.branch = 1;
		EXCEPTION
			WHEN OTHERS THEN
				BEGIN
					SELECT DISTINCT t.currency
					INTO   v_currency
					FROM   tatmext t
					WHERE  t.docno = p_doc
					AND    t.branch = 1;
				EXCEPTION
					WHEN OTHERS THEN
						BEGIN
							SELECT DISTINCT t.currency
							INTO   v_currency
							FROM   texcommon t
							WHERE  t.docno = p_doc
							AND    t.branch = 1;
						EXCEPTION
							WHEN OTHERS THEN
								BEGIN
									SELECT DISTINCT t.currency
									INTO   v_currency
									FROM   tvoiceslip t
									WHERE  t.docno = p_doc
									AND    t.branch = 1;
								EXCEPTION
									WHEN OTHERS THEN
										BEGIN
											SELECT DISTINCT t.currency
											INTO   v_currency
											FROM   tchequeext t
											WHERE  t.docno = p_doc
											AND    t.branch = 1;
										EXCEPTION
											WHEN OTHERS THEN
												v_currency := 0;
										END;
								END;
						END;
				END;
		END;
		RETURN v_currency;
	
	END;

	FUNCTION is_pos(p_docno NUMBER) RETURN NUMBER IS
		v_is_ecom NUMBER := 0; --0=POS,1=ECOM
	BEGIN
		BEGIN
			SELECT DISTINCT 1
			INTO   v_is_ecom
			FROM   tposcheque t
			JOIN   tentry e
			ON     e.docno = t.docno
			AND    e.branch = t.branch
			WHERE  t.posentrymode IN (10, 11, 12)
			AND    nvl(t.poscondition, 0) NOT IN (0, 91)
			AND    e.debitentcode IN (63, 98, 203)
			AND    t.docno = p_docno;
		EXCEPTION
			WHEN OTHERS THEN
				v_is_ecom := 0;
		END;
		--dbms_output.put_line(v_is_ecom) ;
		RETURN v_is_ecom;
	END;

	FUNCTION is_pos_specfc_conditon(p_docno NUMBER) RETURN NUMBER IS
		v_is_ecom NUMBER := 0; --0=POS,1=ECOM
	BEGIN
		BEGIN
			SELECT DISTINCT 1
			INTO   v_is_ecom
			FROM   tposcheque t
			JOIN   tentry e
			ON     e.docno = t.docno
			AND    e.branch = t.branch
			WHERE  t.posentrymode IN (10, 11, 12)
			AND    nvl(t.poscondition, 0) IN (08, 59, 61, 62, 65, 66, 81, 82, 87, 88, 89)
			AND    e.debitentcode IN (63, 98, 203)
			AND    t.docno = p_docno;
		EXCEPTION
			WHEN OTHERS THEN
				v_is_ecom := 0;
		END;
		--dbms_output.put_line(v_is_ecom) ;
		RETURN v_is_ecom;
	END;

	FUNCTION is_pos_specfc_conditon_new(p_docno NUMBER) RETURN NUMBER IS
		v_is_ecom NUMBER := 0; --0=POS,1=ECOM
	BEGIN
		BEGIN
			SELECT DISTINCT 1
			INTO   v_is_ecom
			FROM   tposcheque t
			JOIN   tentry e
			ON     e.docno = t.docno
			AND    e.branch = t.branch
			WHERE  t.posentrymode IN (10, 12)
			AND    nvl(t.poscondition, 0) IN
				   (5, 8, 51, 52, 59, 61, 62, 65, 66, 81, 82, 83, 84, 85, 86, 87, 88, 89)
			AND    e.debitentcode IN (63, 98, 203)
			AND    t.docno = p_docno;
		EXCEPTION
			WHEN OTHERS THEN
				v_is_ecom := 0;
		END;
		--dbms_output.put_line(v_is_ecom) ;
		RETURN v_is_ecom;
	END;

	FUNCTION get_bdt_outstanding_spec_date(p_contract_no VARCHAR2
										   -- ,p_fromdate    DATE
										  ,p_to_date DATE) RETURN NUMBER IS
		v_result           NUMBER := 0;
		v_credit_value     NUMBER := 0;
		v_debit_value      NUMBER := 0;
		v_credit_value_usd NUMBER := 0;
		v_debit_value_usd  NUMBER := 0;
		v_curr             NUMBER := 0;
		v_exchange_rate    NUMBER := 0;
		v_account_no_usd   VARCHAR2(20) := '';
		v_account_no_bdt   VARCHAR2(20) := '';
		--v_install_acc_bdt      VARCHAR2(20) := NULL;
		v_balance_bdt          NUMBER := 0;
		v_balance_usd          NUMBER := 0;
		v_install_debit_value  NUMBER := 0;
		v_install_credit_value NUMBER := 0;
		v_install_balance_bdt  NUMBER := 0;
		v_install_credit_bal   NUMBER := 0;
		v_install_debit_bal    NUMBER := 0;
	
		CURSOR install_acc_list IS
		
			SELECT ci.key accountno
			--INTO   v_install_acc
			FROM   a4m.tcontractitem ci
			JOIN   a4m.taccount aa
			ON     aa.accountno = ci.key
			AND    aa.branch = ci.branch
			WHERE  aa.currencyno = 50
			AND    ci.no IN (
							 
							 SELECT l.linkno
							 FROM   a4m.tcontractitem i
							 JOIN   a4m.taccount a
							 ON     a.accountno = i.key
							 AND    a.branch = i.branch
							 JOIN   a4m.tcontractlink l
							 ON     l.mainno = i.no
							 AND    l.branch = i.branch
							 
							 WHERE  a.currencyno = 50
							 AND    i.no = p_contract_no
							 AND    l.linkname = 'INSTALLMENT');
		--TYPE install_acc_tbl IS TABLE OF VARCHAR2(50);
		--v_install_acc_list install_acc_tbl;
	
	BEGIN
		BEGIN
			SELECT a.key
				  ,acc.currencyno
			INTO   v_account_no_usd
				  ,v_curr
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 840
				  
			AND    t.itemname IN ('ITEMDEPOSITINT')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_usd := 0;
		END;
		BEGIN
		
			SELECT a.key
			INTO   v_account_no_bdt
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 50
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_bdt := 0;
		END;
		BEGIN
		
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_credit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.creditaccount = v_account_no_bdt
				AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_debit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitaccount = v_account_no_bdt
				AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		
			BEGIN
				--OPEN install_acc_list;
				--FETCH install_acc_list BULK COLLECT INTO v_install_acc_list LIMIT 1000;
				FOR z IN install_acc_list --v_install_acc_list.first .. v_install_acc_list.last
				LOOP
					--v_install_acc_bdt := custom_account.get_bdt_install_acc_by_con(p_contract_no);
					IF z.accountno IS NOT NULL
					THEN
						BEGIN
							SELECT SUM(nvl(a.value, 0))
							INTO   v_install_credit_value
							FROM   tentry    a
								  ,tdocument b
							WHERE  a.branch = 1
							AND    b.branch = a.branch
							AND    b.docno = a.docno
							AND    b.newdocno IS NULL
							AND    a.creditaccount = z.accountno
							AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
						EXCEPTION
							WHEN OTHERS THEN
								NULL;
						END;
						BEGIN
							SELECT SUM(nvl(a.value, 0))
							INTO   v_install_debit_value
							FROM   tentry    a
								  ,tdocument b
							WHERE  a.branch = 1
							AND    b.branch = a.branch
							AND    b.docno = a.docno
							AND    b.newdocno IS NULL
							AND    a.debitaccount = z.accountno
							AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
						EXCEPTION
							WHEN OTHERS THEN
								NULL;
						END;
					
						v_install_credit_bal := nvl(v_install_credit_bal, 0) +
												nvl(v_install_credit_value, 0);
					
						v_install_debit_bal := nvl(v_install_debit_bal, 0) +
											   nvl(v_install_debit_value, 0);
					
					ELSE
						v_install_balance_bdt := 0;
					END IF;
				END LOOP;
				--CLOSE install_acc_list;
			END;
			v_install_balance_bdt := nvl(v_install_debit_bal, 0) - nvl(v_install_credit_bal, 0);
			v_balance_bdt         := nvl(v_debit_value, 0) - nvl(v_credit_value, 0);
			v_balance_bdt         := v_balance_bdt + v_install_balance_bdt;
			IF v_curr = 0
			THEN
				IF v_curr = 0
				THEN
					v_result := v_balance_bdt;
					RETURN v_result;
				ELSE
					v_balance_bdt := v_balance_bdt;
				END IF;
			ELSIF v_curr = 840
			THEN
				SELECT ex.destinamount
				INTO   v_exchange_rate
				FROM   texchangerate ex
				WHERE  ex.valuedate = (SELECT s.operdate FROM tseance s)
				AND    ex.sourcecurrency = 840
				AND    ex.destincurrency = 50;
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_credit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.creditaccount = v_account_no_usd
				AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_debit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitaccount = v_account_no_usd
				AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
			
				v_debit_value_usd := v_exchange_rate * v_debit_value_usd;
				--dbms_output.put_line(v_debit_value_usd);
				v_credit_value_usd := v_exchange_rate * v_credit_value_usd;
				v_balance_usd      := v_debit_value_usd - v_credit_value_usd;
				--dbms_output.put_line(v_balance_bdt);
				--dbms_output.put_line(v_balance_usd);
			END IF;
			v_result := v_balance_usd + v_balance_bdt;
			RETURN v_result;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
	END;

	FUNCTION get_pos_entry_mode
	(
		p_docno     NUMBER
	   ,p_card_no   VARCHAR2
	   ,p_tran_code VARCHAR2 := NULL
	) RETURN NUMBER IS
		v_pos_entry_mode NUMBER;
		v_trancode       NUMBER;
	BEGIN
	
		IF p_docno IS NOT NULL
		THEN
			BEGIN
			
				BEGIN
					SELECT DISTINCT nvl(t.posentrymode, 0)
					INTO   v_pos_entry_mode
					FROM   ttlg t
					WHERE  t.branch = 1
					AND    t.pan = p_card_no
					AND    t.trancode = p_tran_code
					AND    revrequestid IS NULL;
				
				EXCEPTION
					WHEN no_data_found THEN
						v_pos_entry_mode := NULL;
				END;
			
				BEGIN
					SELECT DISTINCT nvl(posentrymode, 0)
					INTO   v_pos_entry_mode
					FROM   textract
					WHERE  branch = 1
					AND    docno = p_docno
					AND    rownum <= 1;
				EXCEPTION
					WHEN no_data_found THEN
						v_pos_entry_mode := NULL;
				END;
			
				IF v_pos_entry_mode IS NULL
				THEN
					BEGIN
						SELECT DISTINCT trancode
						INTO   v_trancode
						FROM   textract
						WHERE  branch = 1
						AND    docno = p_docno
						AND    rownum <= 1;
					
						SELECT DISTINCT nvl(posentrymode, 0)
						INTO   v_pos_entry_mode
						FROM   textwitran
						WHERE  branch = 1
						AND    code = v_trancode
						AND    rownum <= 1;
					EXCEPTION
						WHEN no_data_found THEN
							v_pos_entry_mode := NULL;
					END;
				END IF;
			
				IF v_pos_entry_mode IS NULL
				THEN
					BEGIN
						SELECT DISTINCT nvl(posentrymode, 0)
						INTO   v_pos_entry_mode
						FROM   textractdelay
						WHERE  branch = 1
						AND    docno = p_docno
						AND    rownum <= 1;
					EXCEPTION
						WHEN no_data_found THEN
							v_pos_entry_mode := NULL;
					END;
				END IF;
			
			EXCEPTION
				WHEN no_data_found THEN
					v_pos_entry_mode := ' ';
			END;
		
		END IF;
	
		RETURN v_pos_entry_mode;
	
	END;

	FUNCTION get_entcode_by_doc(p_doc NUMBER) RETURN NUMBER IS
		v_entcode NUMBER := 0;
	BEGIN
	
		BEGIN
		
			SELECT DISTINCT t.debitentcode
			INTO   v_entcode
			FROM   tentry t
			WHERE  t.docno = p_doc
			AND    t.branch = 1;
		EXCEPTION
			WHEN OTHERS THEN
				v_entcode := NULL;
		END;
		RETURN v_entcode;
	
	END;
	FUNCTION get_pos_condition
	(
		p_docno     NUMBER
	   ,p_card_no   VARCHAR2 := NULL
	   ,p_tran_code VARCHAR2 := NULL
	) RETURN NUMBER IS
		v_pos_poscondition NUMBER;
		v_trancode         NUMBER;
	BEGIN
	
		IF p_docno IS NOT NULL
		THEN
			BEGIN
			
				BEGIN
					SELECT DISTINCT nvl(t.poscondition, 0)
					INTO   v_pos_poscondition
					FROM   ttlg t
					WHERE  t.branch = 1
					AND    t.pan = p_card_no
					AND    t.trancode = p_tran_code
					AND    revrequestid IS NULL;
				
				EXCEPTION
					WHEN no_data_found THEN
						v_pos_poscondition := NULL;
				END;
			
				BEGIN
					SELECT DISTINCT nvl(poscondition, 0)
					INTO   v_pos_poscondition
					FROM   textract
					WHERE  branch = 1
					AND    docno = p_docno
					AND    rownum <= 1;
				EXCEPTION
					WHEN no_data_found THEN
						v_pos_poscondition := NULL;
				END;
			
				IF v_pos_poscondition IS NULL
				THEN
					BEGIN
						SELECT DISTINCT trancode
						INTO   v_trancode
						FROM   textract
						WHERE  branch = 1
						AND    docno = p_docno
						AND    rownum <= 1;
					
						SELECT DISTINCT nvl(poscondition, 0)
						INTO   v_pos_poscondition
						FROM   textwitran
						WHERE  branch = 1
						AND    code = v_trancode
						AND    rownum <= 1;
					EXCEPTION
						WHEN no_data_found THEN
							v_pos_poscondition := NULL;
					END;
				END IF;
			
				IF v_pos_poscondition IS NULL
				THEN
					BEGIN
						SELECT DISTINCT nvl(poscondition, 0)
						INTO   v_pos_poscondition
						FROM   textractdelay
						WHERE  branch = 1
						AND    docno = p_docno
						AND    rownum <= 1;
					EXCEPTION
						WHEN no_data_found THEN
							v_pos_poscondition := NULL;
					END;
				END IF;
			
			EXCEPTION
				WHEN no_data_found THEN
					v_pos_poscondition := NULL;
			END;
		
		END IF;
	
		RETURN v_pos_poscondition;
	
	END;
	FUNCTION is_ecom
	(
		p_docno     NUMBER
	   ,p_card_no   VARCHAR2 := NULL
	   ,p_tran_code VARCHAR2 := NULL
	) RETURN NUMBER IS
		v_is_ecom NUMBER := 0; --0=POS,1=ECOM
	BEGIN
		BEGIN
			SELECT get_pos_condition(p_docno, p_card_no, p_tran_code) INTO v_is_ecom FROM dual;
			IF v_is_ecom IN (8, 89, 88, 87, 82, 81, 66, 65, 62, 61, 59, 53, 52) --ECOM
			THEN
				v_is_ecom := 1;
			ELSIF v_is_ecom IN (0, 1, 2, 4, 5, 7, 90, 91, 95, 67) --POS
			THEN
				v_is_ecom := 0;
			ELSIF v_is_ecom IS NULL
			THEN
				v_is_ecom := NULL;
			ELSE
				NULL; --undefined
			END IF;
			RETURN v_is_ecom;
		EXCEPTION
			WHEN OTHERS THEN
				v_is_ecom := NULL;
		END;
		--dbms_output.put_line(v_is_ecom) ;
		RETURN v_is_ecom;
	END;

	FUNCTION get_bdt_os_spec_date_bb(p_contract_no VARCHAR2
									 -- ,p_fromdate    DATE
									,p_to_date DATE) RETURN NUMBER IS
		v_result       NUMBER := 0;
		v_credit_value NUMBER := 0;
		v_debit_value  NUMBER := 0;
		--v_credit_value_usd NUMBER := 0;
		--v_debit_value_usd  NUMBER := 0;
		v_curr NUMBER := 0;
		--v_exchange_rate    NUMBER := 0;
		--   v_account_no_usd   VARCHAR2(20) := '';
		v_account_no_bdt VARCHAR2(20) := '';
		--v_install_acc_bdt      VARCHAR2(20) := NULL;
		v_balance_bdt          NUMBER := 0;
		v_balance_usd          NUMBER := 0;
		v_install_debit_value  NUMBER := 0;
		v_install_credit_value NUMBER := 0;
		v_install_balance_bdt  NUMBER := 0;
		v_install_credit_bal   NUMBER := 0;
		v_install_debit_bal    NUMBER := 0;
	
		CURSOR install_acc_list IS
		
			SELECT ci.key accountno
			--INTO   v_install_acc
			FROM   a4m.tcontractitem ci
			JOIN   a4m.taccount aa
			ON     aa.accountno = ci.key
			AND    aa.branch = ci.branch
			WHERE  aa.currencyno = 50
			AND    ci.no IN (
							 
							 SELECT l.linkno
							 FROM   a4m.tcontractitem i
							 JOIN   a4m.taccount a
							 ON     a.accountno = i.key
							 AND    a.branch = i.branch
							 JOIN   a4m.tcontractlink l
							 ON     l.mainno = i.no
							 AND    l.branch = i.branch
							 
							 WHERE  a.currencyno = 50
							 AND    i.no = p_contract_no
							 AND    l.linkname = 'INSTALLMENT');
		--TYPE install_acc_tbl IS TABLE OF VARCHAR2(50);
		--v_install_acc_list install_acc_tbl;
	
	BEGIN
		BEGIN
		
			SELECT a.key
			INTO   v_account_no_bdt
			FROM   tcontracttypeitemname t
				  ,tcontract             c
				  ,tcontractitem         a
				  ,taccount              acc
			WHERE  c.type = t.contracttype
			AND    c.branch = t.branch
				  
			AND    a.no = c.no
			AND    a.branch = c.branch
				  
			AND    a.itemcode = t.itemcode
			AND    a.branch = t.branch
				  
			AND    acc.accountno = a.key
			AND    acc.branch = a.branch
			AND    acc.currencyno = 50
				  
			AND    t.itemname IN ('ITEMDEPOSITDOM')
			AND    c.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_balance_bdt := 0;
		END;
		BEGIN
		
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_credit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.creditaccount = v_account_no_bdt
				AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			BEGIN
				SELECT SUM(nvl(a.value, 0))
				INTO   v_debit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitaccount = v_account_no_bdt
				AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		
			BEGIN
				--OPEN install_acc_list;
				--FETCH install_acc_list BULK COLLECT INTO v_install_acc_list LIMIT 1000;
				FOR z IN install_acc_list --v_install_acc_list.first .. v_install_acc_list.last
				LOOP
					--v_install_acc_bdt := custom_account.get_bdt_install_acc_by_con(p_contract_no);
					IF z.accountno IS NOT NULL
					THEN
						BEGIN
							SELECT SUM(nvl(a.value, 0))
							INTO   v_install_credit_value
							FROM   tentry    a
								  ,tdocument b
							WHERE  a.branch = 1
							AND    b.branch = a.branch
							AND    b.docno = a.docno
							AND    b.newdocno IS NULL
							AND    a.creditaccount = z.accountno
							AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
						EXCEPTION
							WHEN OTHERS THEN
								NULL;
						END;
						BEGIN
							SELECT SUM(nvl(a.value, 0))
							INTO   v_install_debit_value
							FROM   tentry    a
								  ,tdocument b
							WHERE  a.branch = 1
							AND    b.branch = a.branch
							AND    b.docno = a.docno
							AND    b.newdocno IS NULL
							AND    a.debitaccount = z.accountno
							AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
						EXCEPTION
							WHEN OTHERS THEN
								NULL;
						END;
					
						v_install_credit_bal := nvl(v_install_credit_bal, 0) +
												nvl(v_install_credit_value, 0);
					
						v_install_debit_bal := nvl(v_install_debit_bal, 0) +
											   nvl(v_install_debit_value, 0);
					
					ELSE
						v_install_balance_bdt := 0;
					END IF;
				END LOOP;
				--CLOSE install_acc_list;
			END;
			v_install_balance_bdt := nvl(v_install_credit_bal, 0) - nvl(v_install_debit_bal, 0);
			IF v_install_balance_bdt > 0
			THEN
				v_install_balance_bdt := 0;
			END IF;
		
			v_balance_bdt := nvl(v_credit_value, 0) - nvl(v_debit_value, 0);
			IF v_balance_bdt > 0
			THEN
				v_balance_bdt := 0;
			END IF;
		
			v_balance_bdt := (v_balance_bdt) + (v_install_balance_bdt);
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
		v_result := v_balance_bdt;
		RETURN v_result;
	END;

	FUNCTION get_usd_os_spec_date_bb(p_contract_no VARCHAR2
									 -- ,p_fromdate    DATE
									,p_to_date DATE) RETURN NUMBER IS
		v_result NUMBER := 0;
		--   v_credit_value     NUMBER := 0;
		--   v_debit_value      NUMBER := 0;
		v_credit_value_usd NUMBER := 0;
		v_debit_value_usd  NUMBER := 0;
		v_curr             NUMBER := 0;
		--   v_exchange_rate    NUMBER := 0;
		v_account_no_usd VARCHAR2(20) := '';
		--   v_account_no_bdt   VARCHAR2(20) := '';
		--v_install_acc_bdt      VARCHAR2(20) := NULL;
		--   v_balance_bdt          NUMBER := 0;
		v_balance_usd NUMBER := 0;
		--   v_install_debit_value  NUMBER := 0;
		--      v_install_credit_value NUMBER := 0;
		--   v_install_balance_bdt  NUMBER := 0;
		--   v_install_credit_bal   NUMBER := 0;
		--   v_install_debit_bal    NUMBER := 0;
	
		--TYPE install_acc_tbl IS TABLE OF VARCHAR2(50);
		--v_install_acc_list install_acc_tbl;
	
	BEGIN
		BEGIN
			BEGIN
				SELECT a.key
					  ,acc.currencyno
				INTO   v_account_no_usd
					  ,v_curr
				FROM   tcontracttypeitemname t
					  ,tcontract             c
					  ,tcontractitem         a
					  ,taccount              acc
				WHERE  c.type = t.contracttype
				AND    c.branch = t.branch
					  
				AND    a.no = c.no
				AND    a.branch = c.branch
					  
				AND    a.itemcode = t.itemcode
				AND    a.branch = t.branch
					  
				AND    acc.accountno = a.key
				AND    acc.branch = a.branch
				AND    acc.currencyno = 840
					  
				AND    t.itemname IN ('ITEMDEPOSITINT')
				AND    c.no = p_contract_no;
			EXCEPTION
				WHEN OTHERS THEN
					v_balance_usd := 0;
			END;
			IF v_curr = 840
			THEN
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_credit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.creditaccount = v_account_no_usd
				AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
			
				SELECT nvl(SUM(nvl(a.value, 0)), 0)
				INTO   v_debit_value_usd
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitaccount = v_account_no_usd
				AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
			
				v_debit_value_usd := v_debit_value_usd;
				--dbms_output.put_line(v_debit_value_usd);
				v_credit_value_usd := v_credit_value_usd;
				v_balance_usd      := nvl(v_credit_value_usd, 0) - nvl(v_debit_value_usd, 0);
				--dbms_output.put_line(v_balance_bdt);
				--dbms_output.put_line(v_balance_usd);
				IF v_balance_usd > 0
				THEN
					v_balance_usd := 0;
				END IF;
			END IF;
			v_result := v_balance_usd;
			RETURN v_result;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
		RETURN v_result;
	END;
	/*Purpose of this function is cricket world cup 2023 quiz project */
	/*FUNCTION get_bdt_purchase_by_cid
    (
        p_idclient NUMBER
       ,p_frm_date DATE
       ,p_to_date  DATE
    ) RETURN NUMBER IS
        v_bdt_amount NUMBER := 0;
    BEGIN
        BEGIN
            SELECT SUM(CASE
                           WHEN t.currency = 50 THEN
                            nvl(custom_transaction.get_bdt_by_doc(t.docno), 0)
                       END)
            INTO   v_bdt_amount
            
            FROM   tposcheque t
            JOIN   tdocument d
            ON     d.docno = t.docno
            AND    d.branch = t.branch
            JOIN   tcard c
            ON     c.pan = t.pan
            AND    c.branch = t.branch
            WHERE  custom_transaction.get_entcode_by_doc(t.docno) = 63
            AND    (t.pan LIKE ('371598%') OR t.pan LIKE ('376947%') OR t.pan LIKE ('376948%') OR
                    t.pan LIKE ('371599%'))
            AND    d.opdate BETWEEN p_frm_date AND p_to_date
            AND    c.idclient = p_idclient;
        EXCEPTION
            WHEN OTHERS THEN
                v_bdt_amount := 0;
        END;
    
        RETURN v_bdt_amount;
    
    END get_bdt_purchase_by_cid;*/

	/*Purpose of this function is cricket world cup 2023 quiz project */
	FUNCTION get_ttl_purchase_by_cid
	(
		p_idclient NUMBER
	   ,p_frm_date DATE
	   ,p_to_date  DATE
	) RETURN NUMBER IS
		v_usd_amount       NUMBER := 0;
		v_ttl_purchase_amt NUMBER := 0;
		v_bdt_amount       NUMBER := 0;
	BEGIN
		BEGIN
			SELECT SUM(nvl(CASE
							   WHEN t.currency = 50 THEN
								nvl(custom_transaction.get_bdt_by_doc(t.docno), 0)
						   END
						  ,0))
				  ,
				   
				   SUM(nvl(CASE
							   WHEN t.currency = 840 THEN
								nvl(custom_transaction.get_usd_by_doc(t.docno), 0)
						   END
						  ,0) * (SELECT ex.destinamount
								 FROM   texchangerate ex
								 WHERE  trunc(ex.valuedate) = trunc(d.opdate)
								 AND    ex.sourcecurrency = 840
								 AND    ex.destincurrency = 50))
			INTO   v_bdt_amount
				  ,v_usd_amount
			
			FROM   tposcheque t
			JOIN   tdocument d
			ON     d.docno = t.docno
			AND    d.branch = t.branch
			JOIN   tcard c
			ON     c.pan = t.pan
			AND    c.branch = t.branch
			JOIN   tentry e
			ON     e.docno = t.docno
			AND    e.branch = t.branch
			
			WHERE  e.debitentcode = 63
			AND    (t.pan LIKE ('371598%') OR t.pan LIKE ('376947%') OR t.pan LIKE ('376948%') OR
				  t.pan LIKE ('371599%'))
			AND    d.opdate BETWEEN p_frm_date AND p_to_date
			AND    c.idclient = p_idclient;
		EXCEPTION
			WHEN OTHERS THEN
				v_bdt_amount := 0;
				v_usd_amount := 0;
		END;
		/*
        BEGIN
            SELECT SUM(nvl(CASE
                               WHEN t.currency = 840 THEN
                                nvl(custom_transaction.get_usd_by_doc(t.docno), 0)
                           END
                          ,0) * (SELECT ex.destinamount
                                 FROM   texchangerate ex
                                 WHERE  trunc(ex.valuedate) = trunc(d.opdate)
                                 AND    ex.sourcecurrency = 840
                                 AND    ex.destincurrency = 50))
            INTO   v_usd_amount
            
            FROM   tposcheque t
            JOIN   tdocument d
            ON     d.docno = t.docno
            AND    d.branch = t.branch
            JOIN   tcard c
            ON     c.pan = t.pan
            AND    c.branch = t.branch
            JOIN   tentry e
            ON     e.docno = t.docno
            AND    e.branch = t.branch
            
            WHERE  e.debitentcode = 63
            AND    (t.pan LIKE ('371598%') OR t.pan LIKE ('376947%') OR t.pan LIKE ('376948%') OR
                  t.pan LIKE ('371599%'))
            AND    d.opdate BETWEEN p_frm_date AND p_to_date
            AND    c.idclient = p_idclient;
        EXCEPTION
            WHEN OTHERS THEN
                v_usd_amount := 0;
        END;*/
	
		v_ttl_purchase_amt := nvl(v_bdt_amount, 0) + nvl(v_usd_amount, 0);
		RETURN v_ttl_purchase_amt;
	
	END get_ttl_purchase_by_cid;

	FUNCTION is_atm(p_doc_no NUMBER) RETURN NUMBER IS
		v_flag NUMBER := 0; -- 3 = ATM
	BEGIN
		BEGIN
			SELECT 3
			INTO   v_flag
			FROM   tatmext t
			WHERE  t.entcode = 10
			AND    t.docno = p_doc_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_flag := 0;
		END;
		RETURN v_flag;
	END;

	FUNCTION is_qr
	(
		p_docno         NUMBER := 0
	   ,p_card_no       VARCHAR2 := NULL
	   ,p_approval_code VARCHAR2 := NULL
	   ,p_tran_code     VARCHAR2 := NULL
	) RETURN NUMBER IS
		v_field6        VARCHAR2(10) := NULL;
		v_field7        VARCHAR2(10) := NULL;
		v_terminst      VARCHAR2(10) := NULL;
		v_authfiname    VARCHAR2(10) := NULL;
		v_approval_code VARCHAR2(20) := NULL;
		return_value    NUMBER := 0;
	BEGIN
		BEGIN
			IF p_tran_code IS NOT NULL
			THEN
				SELECT substr(t.exttranattr, instr(t.exttranattr, '=') + 6, 1)
					  ,nvl(substr(t.exttranattr, instr(t.exttranattr, '=') + 7, 1), ' ')
					  ,(SELECT DISTINCT p.acquireriin
					   FROM   tposcheque p
					   WHERE  p.pan = p_card_no
					   AND    p.approval = t.approvalcode)
					  ,t.approvalcode
				-- ,t.authfiname
				INTO   v_field6
					  ,v_field7
					  ,v_terminst
					  ,v_approval_code
				--,v_authfiname
				FROM   ttlg t
				
				WHERE  t.approvalcode = v_approval_code
				AND    t.pan = p_card_no;
			END IF;
		
			IF ((v_field6 = '8' AND v_field7 = '3') OR (v_terminst = '44444444444') --and cEntry.sCursorRow.AcquirerIIN = '44444444444') 
			   OR (v_terminst = '55555555555') --and cEntry.sCursorRow.AcquirerIIN = '55555555555') 
			   OR (v_terminst = '99999999999') OR
			   ((v_field6 = '8' AND v_field7 = '3') OR v_terminst = '44444444444' --cEntry.sCursorRow.AcquirerIIN = '44444444444' 
			   OR v_terminst = '55555555555' OR v_terminst = '99999999999') --cEntry.sCursorRow.AcquirerIIN = '55555555555')
			   )
			THEN
				return_value := 1;
				RETURN return_value;
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				return_value := 0;
				RETURN return_value;
		END;
		RETURN return_value;
	END;

	FUNCTION is_ecom_pos_qr_atm
	(
		p_docno     NUMBER
	   ,p_card_no   VARCHAR2 := NULL
	   ,p_tran_code VARCHAR2 := NULL
	) RETURN NUMBER IS
		v_is_ecom      NUMBER := NULL; --0=POS, 1=ECOM, 3=ATM, 4=QR
		v_pos_condtion NUMBER := NULL;
	BEGIN
		BEGIN
			SELECT get_pos_con_online(p_docno, p_card_no, p_tran_code)
			INTO   v_pos_condtion
			FROM   dual;
			IF is_atm(p_docno) = 3
			THEN
				v_is_ecom := 3;
				RETURN v_is_ecom; --ATM*/
			ELSIF v_is_ecom IS NULL
				  AND v_pos_condtion IN (8, 88, 87, 82, 81, 66, 65, 64, 62, 61, 60, 59, 53, 52) --ECOM
			THEN
				v_is_ecom := 1;
				RETURN v_is_ecom; --ECOM
			END IF;
			IF v_is_ecom IS NULL
			--   AND v_pos_condtion IS NOT NULL
			THEN
				IF is_qr(p_docno         => p_docno
						,p_card_no       => p_card_no
						,p_approval_code => NULL
						,p_tran_code     => p_tran_code) = 1
				THEN
					v_is_ecom := 4;
					RETURN v_is_ecom; --QR 
				END IF;
				IF v_is_ecom IS NULL
				   AND v_pos_condtion IN (0, 1, 2, 4, 5, 7, 90, 91, 95, 67) --POS
				THEN
					v_is_ecom := 0; --POS
					RETURN v_is_ecom;
				END IF;
			
				/*          ELSE
                    IF v_is_ecom IS NULL
                       AND is_atm(p_docno) = 3
                    THEN
                        v_is_ecom := 3;
                        RETURN v_is_ecom; --ATM
                END IF; */
			END IF;
			RETURN v_is_ecom;
		EXCEPTION
			WHEN OTHERS THEN
				v_is_ecom := NULL;
		END;
		--dbms_output.put_line(v_is_ecom) ;
		RETURN v_is_ecom;
	END;

	FUNCTION get_pos_con_online
	(
		p_docno     NUMBER
	   ,p_card_no   VARCHAR2 := NULL
	   ,p_tran_code VARCHAR2 := NULL
	) RETURN NUMBER IS
		v_pos_poscondition NUMBER;
		v_trancode         NUMBER;
		v_pan              VARCHAR2(20) := NULL;
		v_approval_code    VARCHAR2(30) := NULL;
		v_acqps            VARCHAR2(30) := NULL;
		v_field6           VARCHAR2(10) := NULL;
		v_field7           VARCHAR2(10) := NULL;
	BEGIN
	
		IF p_docno IS NOT NULL
		THEN
			BEGIN
			
				BEGIN
					--checking from onlineDB
					SELECT t.pan
						  ,t.approval
						  ,t.acqps
					INTO   v_pan
						  ,v_approval_code
						  ,v_acqps
					FROM   tposcheque t
					WHERE  t.docno = p_docno;
				
					SELECT DISTINCT nvl(poscondition, 0)
					--   ,substr(exttranattr, instr(exttranattr, '=') + 6, 1)
					--  ,substr(exttranattr, instr(exttranattr, '=') + 7, 1)
					INTO   v_pos_poscondition
					--  ,v_field6
					--  ,v_field7
					FROM   tla@cms2two
					--FROM   ttlg
					WHERE  pan = v_pan
					AND    approvalcode = v_approval_code;
					--AND    termfiname = v_acqps;
				
				EXCEPTION
					WHEN OTHERS THEN
						v_pos_poscondition := NULL;
					
				END;
				IF v_pos_poscondition IS NOT NULL
				THEN
					RETURN v_pos_poscondition;
				END IF;
				IF v_pos_poscondition IS NOT NULL
				THEN
					RETURN v_pos_poscondition;
				END IF;
			
				BEGIN
					SELECT DISTINCT nvl(t.poscondition, 0)
					INTO   v_pos_poscondition
					FROM   ttlg t
					WHERE  t.branch = 1
					AND    t.pan = p_card_no
					AND    t.trancode = p_tran_code
					AND    revrequestid IS NULL;
				
				EXCEPTION
					WHEN no_data_found THEN
						v_pos_poscondition := NULL;
				END;
			
				IF v_pos_poscondition IS NOT NULL
				THEN
					RETURN v_pos_poscondition;
				END IF;
			
				IF v_pos_poscondition IS NULL
				THEN
					BEGIN
						SELECT DISTINCT nvl(poscondition, 0)
						INTO   v_pos_poscondition
						FROM   textract
						WHERE  branch = 1
						AND    docno = p_docno
						AND    rownum <= 1;
					EXCEPTION
						WHEN no_data_found THEN
							v_pos_poscondition := NULL;
					END;
				
					IF v_pos_poscondition IS NOT NULL
					THEN
						RETURN v_pos_poscondition;
					END IF;
				
				END IF;
				IF v_pos_poscondition IS NULL
				THEN
					BEGIN
						SELECT DISTINCT trancode
						INTO   v_trancode
						FROM   textract
						WHERE  branch = 1
						AND    docno = p_docno
						AND    rownum <= 1;
					
						SELECT DISTINCT nvl(poscondition, 0)
						INTO   v_pos_poscondition
						FROM   textwitran
						WHERE  branch = 1
						AND    code = v_trancode
						AND    rownum <= 1;
					EXCEPTION
						WHEN no_data_found THEN
							v_pos_poscondition := NULL;
					END;
				END IF;
				IF v_pos_poscondition IS NOT NULL
				THEN
					RETURN v_pos_poscondition;
				END IF;
			
				IF v_pos_poscondition IS NULL
				THEN
					BEGIN
						SELECT DISTINCT nvl(poscondition, 0)
						INTO   v_pos_poscondition
						FROM   textractdelay
						WHERE  branch = 1
						AND    docno = p_docno
						AND    rownum <= 1;
					EXCEPTION
						WHEN no_data_found THEN
							v_pos_poscondition := NULL;
					END;
				END IF;
			
			EXCEPTION
				WHEN no_data_found THEN
					v_pos_poscondition := NULL;
			END;
		
		END IF;
	
		RETURN v_pos_poscondition;
	
	END;

	FUNCTION get_qr_rmt_onnus_rrn(p_doc NUMBER) RETURN NUMBER IS
		v_rrn      NUMBER := NULL;
		v_incstan  VARCHAR2(50) := NULL;
		v_termname VARCHAR2(50) := NULL;
		v_type     VARCHAR2(50) := NULL;
		v_time     DATE := NULL;
		v_pan2     VARCHAR2(50) := NULL;
	BEGIN
		BEGIN
			SELECT TRIM(g.incstan)
				  ,g.termname
				  ,g.type
				  ,trunc(g.time)
				  ,t.pan
			INTO   v_incstan
				  ,v_termname
				  ,v_type
				  ,v_time
				  ,v_pan2
			FROM   a4m.tposcheque t
			JOIN   a4m.ttlg g
			ON     g.code = t.trancode
			AND    t.branch = g.branch
			AND    t.pan = g.pan
			WHERE  t.docno = p_doc;
		
		EXCEPTION
			WHEN OTHERS THEN
				v_incstan  := NULL;
				v_termname := NULL;
				v_type     := NULL;
				v_time     := NULL;
		END;
		IF v_incstan IS NOT NULL
		THEN
			BEGIN
			
				SELECT DISTINCT (extrrn)
				INTO   v_rrn
				FROM   tla@cms2two tl
				--FROM   ttlg tl
				WHERE  trunc(TIME) = v_time
				AND    tl.trancode = '356'
				AND    tl.pan2 = v_pan2
				AND    tl.termname = v_termname
				AND    TYPE = v_type
				AND    respcode = 1
				AND    TRIM(tl.trannumber) = v_incstan;
			
			EXCEPTION
				WHEN OTHERS THEN
					v_rrn := NULL;
				
			END;
		END IF;
		RETURN v_rrn;
	END;

	FUNCTION get_exchange_rate(p_opdate DATE) RETURN NUMBER IS
		v_exchange_rate NUMBER := 1;
	BEGIN
		BEGIN
			v_exchange_rate := referencecurrency.getrate(1, 840, 50, p_opdate);
		EXCEPTION
			WHEN OTHERS THEN
				v_exchange_rate := 1;
		END;
		RETURN v_exchange_rate;
	END;

	FUNCTION get_comm_by_doc(p_doc NUMBER) RETURN NUMBER IS
		--v_doc_count NUMBER := 0;
		v_amount NUMBER := 0;
	BEGIN
		BEGIN
			SELECT amt
			INTO   v_amount
			FROM   (SELECT t.value amt
					--INTO   v_amount
					FROM   a4m.tentry t
					WHERE  t.docno = p_doc
					AND    t.branch = 1
					AND    t.debitentcode NOT IN (63, 98, 805)
					ORDER  BY t.no DESC)
			WHERE  rownum = 1;
		EXCEPTION
			WHEN OTHERS THEN
				v_amount := 0;
		END;
	
		RETURN v_amount;
	END;

END custom_transaction;
/
