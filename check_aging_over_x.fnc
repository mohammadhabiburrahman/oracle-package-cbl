CREATE OR REPLACE FUNCTION check_aging_over_x
(
	p_contract  VARCHAR2
   ,p_ref_month NUMBER
) RETURN VARCHAR2 IS
	v_result   VARCHAR2(20) := '';
	r_contract tcontractstatehistory%ROWTYPE;
	v_date     DATE := add_months(SYSDATE, -p_ref_month);
	v_state    VARCHAR2(20) := '';
	CURSOR c_contract IS
		SELECT t.*
		FROM   tcontractstatehistory t
		WHERE  t.contractno = p_contract
		AND    (t.operdate >= v_date OR p_ref_month IS NULL);

BEGIN
	BEGIN
		SELECT DISTINCT th.statecode
		INTO   v_state
		FROM   tcontractstatehistory th
		WHERE  th.operdate =
			   (SELECT MAX(t.operdate) FROM tcontractstatehistory t WHERE t.contractno = p_contract)
		AND    (th.operdate < v_date OR p_ref_month IS NULL)
		AND    rownum = 1;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
	END;

	IF (v_state = 'X' OR v_state = '0')
	THEN
		v_result := 'MOF';
		RETURN v_result;
	ELSE
		NULL;
	END IF;

	OPEN c_contract;
	FETCH c_contract
		INTO r_contract;
	IF c_contract % NOTFOUND
	THEN
		v_result := 'NFH';
	END IF;
	--dbms_output.put_line(r_contract.statecode || ' ' || r_contract.operdate);
	IF (r_contract.statecode != '0' OR r_contract.statecode != 'X')
	THEN
		v_result := 'FH';
		--dbms_output.put_line(r_contract.statecode || ' ' || v_result);
		RETURN v_result;
	END IF;
	CLOSE c_contract;
	RETURN v_result;
END;
/
