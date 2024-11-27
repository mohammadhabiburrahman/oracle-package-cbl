CREATE OR REPLACE PACKAGE custom_contract IS
	FUNCTION chk_brtday_cake_eligibility
	(
		p_contract  VARCHAR2
	   ,p_ref_month NUMBER
	) RETURN VARCHAR2;
END;
/
CREATE OR REPLACE PACKAGE BODY custom_contract IS
	FUNCTION chk_brtday_cake_eligibility
	(
		p_contract  VARCHAR2
	   ,p_ref_month NUMBER
	) RETURN VARCHAR2 IS
		v_result    VARCHAR2(20) := '';
		r_contract  tcontractstatehistory%ROWTYPE;
		v_ref_month NUMBER := nvl(p_ref_month, 0);
		v_date      DATE;
		v_state     VARCHAR2(20) := '';
	
		v_state_2 VARCHAR2(20) := '';
	
		CURSOR c_contract IS
			SELECT t.*
			FROM   tcontractstatehistory t
			WHERE  t.contractno = p_contract
			AND    (t.operdate >= v_date OR v_date IS NULL);
	
	BEGIN
		BEGIN
			IF v_ref_month != 0
			THEN
				v_date := add_months(SYSDATE, -v_ref_month);
				--dbms_output.put_line(v_date);
			ELSE
				v_date := NULL;
				--dbms_output.put_line(v_date);
			END IF;
		
			SELECT DISTINCT th.statecode
			INTO   v_state
			FROM   tcontractstatehistory th
			WHERE  th.operdate = (SELECT MAX(t.operdate)
								  FROM   tcontractstatehistory t
								  WHERE  t.contractno = p_contract)
			AND    (th.operdate < v_date OR v_date IS NULL)
			AND    th.contractno = p_contract
			AND    rownum = 1;
			--dbms_output.put_line(v_state);
			--dbms_output.put_line(v_date);
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	
		IF v_state != 'X'
		THEN
			IF v_state != '0'
			
			THEN
				v_result := 'NOT_ALLOWED';
				RETURN v_result;
			ELSE
				NULL;
			END IF;
		ELSE
			NULL;
		END IF;
		BEGIN
			FOR r_contract IN c_contract
			LOOP
				v_state_2 := TRIM(r_contract.statecode);
			
				IF v_state_2 != 'X'
				THEN
					--dbms_output.put_line(v_state_2);
					IF v_state_2 != '0'
					THEN
						--dbms_output.put_line(v_state_2);
						v_result := 'NOT_ALLOWED';
						dbms_output.put_line(r_contract.statecode || ' ' || r_contract.operdate);
						RETURN v_result;
					END IF;
				END IF;
			END LOOP;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 'Exception';
				RETURN v_result;
		END;
		v_result := 'ALLOWED';
		RETURN v_result;
	END;

END;
/
