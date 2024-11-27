CREATE OR REPLACE PACKAGE custom_account IS

	FUNCTION get_acc_currency(p_account VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_occupation_by_acc(p_account VARCHAR2) RETURN VARCHAR2;

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

END custom_account;
/