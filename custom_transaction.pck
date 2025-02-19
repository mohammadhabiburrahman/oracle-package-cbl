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
				dbms_output.put_line(v_balance_bdt);
				dbms_output.put_line(v_balance_usd);
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
				dbms_output.put_line(v_balance_bdt);
				dbms_output.put_line(v_balance_usd);
			END IF;
			v_result := v_balance_usd + v_balance_bdt;
			RETURN v_result;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
	END;

	FUNCTION get_installment_balance(p_acc_no VARCHAR2) RETURN NUMBER IS
		v_installment_amount NUMBER;
		v_acc_no             VARCHAR2(20);
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
				dbms_output.put_line(v_balance_bdt);
				dbms_output.put_line(v_balance_usd);
			END IF;
			v_result := v_balance_usd + v_balance_bdt;
			RETURN v_result;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
	END get_pur_trns_amt_contract;

END;
/
