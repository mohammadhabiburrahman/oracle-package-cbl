CREATE OR REPLACE PACKAGE custom_account IS

	FUNCTION get_acc_currency(p_account VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_occupation_by_acc(p_account VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_bdt_acc_by_con(p_con VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_usd_acc_by_con(p_con VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_payment_amount_acc
	(
		p_acc      IN VARCHAR2
	   ,p_frm_date IN DATE
	   ,p_to_date  IN DATE
	) RETURN NUMBER;
	FUNCTION get_con_by_acc(p_acc NUMBER) RETURN VARCHAR2;
END custom_account;
/
CREATE OR REPLACE PACKAGE BODY custom_account IS
	FUNCTION get_acc_currency(p_account VARCHAR2) RETURN VARCHAR2 IS
		v_currency VARCHAR2(200) := '';
	
	BEGIN
		BEGIN
			SELECT t.currencyno INTO v_currency FROM taccount t WHERE t.accountno = p_account;
		
		EXCEPTION
			WHEN no_data_found THEN
				v_currency := '';
			WHEN OTHERS THEN
				v_currency := '';
		END;
		IF v_currency = 50
		THEN
			v_currency := 'BDT';
		ELSIF v_currency = 840
		THEN
			v_currency := 'USD';
		ELSIF v_currency = 9999
		THEN
			v_currency := 'MR';
		ELSE
			v_currency := '';
		END IF;
		RETURN v_currency;
	END;

	FUNCTION get_occupation_by_acc(p_account VARCHAR2) RETURN VARCHAR2 IS
		v_occupation toccupation.name%TYPE := '';
	BEGIN
		BEGIN
			SELECT p.occupation || '#' || o.name
			INTO   v_occupation
			FROM   a4m.tclientpersone p
			JOIN   toccupation o
			ON     p.occupation = o.code
			AND    p.branch = o.branch
			WHERE  p.idclient = (SELECT idclient FROM a4m.taccount WHERE accountno = p_account);
		EXCEPTION
			WHEN OTHERS THEN
				v_occupation := '';
		END;
		RETURN v_occupation;
	
	END;

	FUNCTION get_bdt_acc_by_con(p_con VARCHAR2) RETURN VARCHAR2 IS
		v_account VARCHAR2(50) := '';
	BEGIN
		BEGIN
		
			SELECT a.accountno
			INTO   v_account
			FROM   a4m.tcontractitem t
			
			JOIN   a4m.taccount a
			ON     a.accountno = t.key
			AND    a.branch = t.branch
			
			JOIN   tcontract c
			ON     c.no = t.no
			AND    c.branch = t.branch
			
			JOIN   tcontracttypeitemname b
			ON     b.contracttype = c.type
			AND    b.branch = c.branch
			
			WHERE  t.no = p_con
			AND    a.currencyno = '50'
			AND    b.itemname = 'ITEMDEPOSITDOM'
			AND    a.accounttype IN (1, 9, 30, 49, 20, 35, 36);
		
		EXCEPTION
			WHEN OTHERS THEN
				v_account := '';
		END;
		RETURN v_account;
	END;
	FUNCTION get_usd_acc_by_con(p_con VARCHAR2) RETURN VARCHAR2 IS
		v_account VARCHAR2(50) := '';
	BEGIN
		BEGIN
		
			SELECT a.accountno
			INTO   v_account
			FROM   a4m.tcontractitem t
			JOIN   a4m.taccount a
			ON     a.accountno = t.key
			AND    a.branch = t.branch
			
			JOIN   tcontract c
			ON     c.no = t.no
			AND    c.branch = t.branch
			JOIN   tcontracttypeitemname b
			ON     b.contracttype = c.type
			AND    b.branch = c.branch
			
			WHERE  t.no = p_con
			AND    a.currencyno = '840'
			AND    b.itemname = 'ITEMDEPOSITINT'
			AND    a.accounttype IN (2, 10, 31, 50);
		
		EXCEPTION
			WHEN OTHERS THEN
				v_account := '';
		END;
		RETURN v_account;
	END;

	FUNCTION get_payment_amount_acc
	(
		p_acc      IN VARCHAR2
	   ,p_frm_date IN DATE
	   ,p_to_date  IN DATE
	) RETURN NUMBER IS
		v_paid             NUMBER;
		v_rev              NUMBER;
		v_rev_cash_deposit NUMBER;
	BEGIN
		BEGIN
			SELECT nvl(SUM(a.value), 0)
			INTO   v_paid
			FROM   tentry                  a
				  ,tdocument               b
				  ,tcontractentrygrouplist c
				  ,tcontractentrygroup     d
			WHERE  a.branch = b.branch
			AND    a.branch = c.branch
			AND    a.branch = d.branch
			AND    a.creditaccount = p_acc
			AND    b.branch = a.branch
			AND    b.docno = a.docno
			AND    b.opdate >= p_frm_date
			AND    b.opdate <= p_to_date
			AND    b.newdocno IS NULL
			AND    c.branch = a.branch
			AND    c.entcode = a.debitentcode
			AND    c.entcode NOT IN (21, 811)
			AND    
				  --c.EntCode = 84 and
				   d.branch = c.branch
			AND    d.groupid = c.groupid
			AND    d.cashadvance = 2;
			--(d.CashAdvance = 2 or d.CashAdvance = 3);
			--d.CashAdvance in (2,3); 
		EXCEPTION
			WHEN OTHERS THEN
				RETURN 1;
		END;
		BEGIN
			SELECT nvl(SUM(a.value), 0)
			INTO   v_rev
			FROM   tentry                  a
				  ,tdocument               b
				  ,tcontractentrygrouplist c
				  ,tcontractentrygroup     d
			WHERE  a.branch = b.branch
			AND    a.branch = c.branch
			AND    a.branch = d.branch
			AND    a.debitaccount = p_acc
			AND    b.branch = a.branch
			AND    b.docno = a.docno
			AND    b.opdate >= p_frm_date
			AND    b.opdate <= p_to_date
			AND    b.newdocno IS NULL
			AND    c.branch = a.branch
			AND    c.entcode = a.debitentcode
			AND    c.entcode <> 21
			AND    
				  --c.EntCode = 84 and
				   d.branch = c.branch
			AND    d.groupid = c.groupid
			AND    d.cashadvance = 2;
			--(d.CashAdvance = 2 or d.CashAdvance = 3);
			--d.CashAdvance in (2,3);
		EXCEPTION
			WHEN OTHERS THEN
				RETURN 2;
		END;
	
		BEGIN
			SELECT nvl(SUM(a.value), 0)
			INTO   v_rev_cash_deposit
			FROM   a4m.tentry    a
				  ,a4m.tdocument b
			WHERE  a.branch = b.branch
			AND    a.debitaccount = p_acc
			AND    b.branch = a.branch
			AND    b.docno = a.docno
			AND    b.opdate >= p_frm_date
			AND    b.opdate <= p_to_date
			AND    b.newdocno IS NULL
			AND    a.debitentcode = 84;
		EXCEPTION
			WHEN OTHERS THEN
				RETURN 3;
		END;
	
		RETURN v_paid - v_rev - v_rev_cash_deposit;
	END;

	FUNCTION get_con_by_acc(p_acc NUMBER) RETURN VARCHAR2 IS
		v_contract VARCHAR2(50) := '';
	BEGIN
		BEGIN
			SELECT DISTINCT t.no INTO v_contract FROM tcontractitem t WHERE t.key = p_acc;
		EXCEPTION
			WHEN OTHERS THEN
				v_contract := '';
		END;
		RETURN v_contract;
	END;

END custom_account;
/
