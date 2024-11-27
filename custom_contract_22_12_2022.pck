CREATE OR REPLACE PACKAGE custom_contract IS
	FUNCTION chk_brtday_cake_eligibility
	(
		p_contract  VARCHAR2
	   ,p_ref_month NUMBER
	) RETURN VARCHAR2;

	PROCEDURE get_seq_imposed_lpc
	(
		p_from_date DATE
	   ,p_to_date   DATE
	   ,p_currency  NUMBER
	   ,p_contract  VARCHAR2
	   ,p_recordset OUT SYS_REFCURSOR
	);

	FUNCTION get_month_diff
	(
		p_account   VARCHAR2
	   ,p_from_date DATE
	   ,p_to_date   DATE
		--,p_contract  VARCHAR2
	   ,p_currency NUMBER
	) RETURN VARCHAR2;

	FUNCTION get_late_pay_contract_data
	(
		p_from_date DATE
	   ,p_to_date   DATE
	   ,p_contract  VARCHAR2
	   ,p_currency  NUMBER
	) RETURN NUMBER;

	FUNCTION get_month_diff_m2
	(
		p_account   VARCHAR2
	   ,p_from_date DATE
	   ,p_to_date   DATE
		--,p_contract  VARCHAR2
	   ,p_currency NUMBER
	) RETURN VARCHAR2;

	FUNCTION get_late_pay_contract_data_m2
	(
		p_from_date DATE
	   ,p_to_date   DATE
	   ,p_contract  VARCHAR2
	   ,p_currency  NUMBER
	) RETURN NUMBER;
	FUNCTION get_con_bdt_lmt_by_clnt(p_client VARCHAR2) RETURN NUMBER;
	FUNCTION get_con_usd_lmt_by_clnt(p_client VARCHAR2) RETURN NUMBER;
	FUNCTION getcontractattributebyparamid
	(
		p_client_id VARCHAR
	   ,vparamid    VARCHAR
	) RETURN VARCHAR2;
	FUNCTION getcntrbctattrbyparamidbycon
	(
		vcontractno VARCHAR
	   ,vparamid    VARCHAR
	) RETURN VARCHAR2;
	FUNCTION get_con_bdt_lmt_by_con(p_con VARCHAR2) RETURN NUMBER;
	FUNCTION get_con_usd_lmt_by_con(p_con VARCHAR2) RETURN NUMBER;
	FUNCTION con_usd_lmt_by_clnt_dt
	(
		p_client   VARCHAR2
	   ,p_frm_date DATE
	   ,p_to_date  DATE
		--,p_rate     NUMBER
	) RETURN NUMBER;
	FUNCTION con_bdt_lmt_by_clnt_dt
	(
		p_client   VARCHAR2
	   ,p_frm_date DATE
	   ,p_to_date  DATE
	) RETURN NUMBER;
	FUNCTION get_cust_contract_type RETURN VARCHAR2;
	FUNCTION get_bdt_overdue_by_con(p_con VARCHAR2) RETURN NUMBER;
	FUNCTION get_usd_overdue_by_con(p_con VARCHAR2) RETURN NUMBER;
	FUNCTION get_cycle_by_con(p_con VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_ageing_by_con
	(
		p_con  VARCHAR2
	   ,p_date DATE
	) RETURN VARCHAR2;
	FUNCTION get_classified_date
	(
		p_aging NUMBER
	   ,p_dt    DATE
	   ,p_dd    NUMBER
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

	PROCEDURE get_seq_imposed_lpc
	(
		p_from_date DATE
	   ,p_to_date   DATE
	   ,p_currency  NUMBER
	   ,p_contract  VARCHAR2
	   ,p_recordset OUT SYS_REFCURSOR
	) IS
	
	BEGIN
	
		OPEN p_recordset FOR
			WITH total_amount AS
			 (SELECT contractno contract_no
					,ctl.accountno account_no
					,SUM(amount) amount
			  FROM   a4m.tcontracttrxnlist ctl
					,a4m.taccount          act
			  WHERE  act.accountno = ctl.accountno
			  AND    act.branch = ctl.branch
			  AND    ctl.debitentcode = '18'
			  AND    (ctl.contractno = p_contract OR p_contract IS NULL)
			  AND    ctl.postdate BETWEEN p_from_date AND p_to_date
			  AND    act.currencyno = p_currency
			  GROUP  BY contractno
					   ,ctl.accountno)
			SELECT contractno
				  ,accountno
				  ,cnt
				  ,c.amount
			FROM   (SELECT contractno
						  ,accountno
						  ,COUNT(*) + 1 AS cnt
					FROM   (SELECT t.contractno
								  ,t.accountno
								  ,trunc(t.postdate, 'MM') postdate
								  ,t.amount
								  ,lag(trunc(t.postdate, 'MM')) over(PARTITION BY t.contractno ORDER BY t.postdate) fast_row_value_dt
							FROM   a4m.tcontracttrxnlist t
							JOIN   a4m.taccount a
							ON     a.accountno = t.accountno
							AND    a.branch = t.branch
							WHERE  t.debitentcode = '18'
							AND    (t.contractno = p_contract OR p_contract IS NULL)
							AND    t.postdate BETWEEN p_from_date AND p_to_date
							AND    a.currencyno = p_currency)
					WHERE  CASE
							   WHEN fast_row_value_dt IS NULL THEN
								NULL
							   ELSE
								months_between(postdate, fast_row_value_dt)
						   END = 1
					GROUP  BY contractno
							 ,accountno) x
				  ,total_amount c
			WHERE  c.contract_no = x.contractno
			AND    c.account_no = x.accountno;
	
	END;
	FUNCTION get_month_diff
	(
		p_account   VARCHAR2
	   ,p_from_date DATE
	   ,p_to_date   DATE
		--,p_contract  VARCHAR2
	   ,p_currency NUMBER
	) RETURN VARCHAR2 IS
		v_row_count NUMBER := 0;
		v_amount    NUMBER := 0;
		v_amnt      VARCHAR2(50) := '';
	BEGIN
		FOR i IN (SELECT diff
						,accountno
						,amount
				  -- INTO   v_row_count
				  FROM   (SELECT t.accountno
								,trunc(t.postdate, 'MM') postdate
								,t.amount
								,lag(trunc(t.postdate, 'MM')) over(PARTITION BY t.accountno ORDER BY t.postdate) fast_row_value_dt
								,CASE
									 WHEN (lag(trunc(t.postdate, 'MM'))
										   over(PARTITION BY t.accountno ORDER BY t.postdate)) IS NULL THEN
									  NULL
									 ELSE
									  months_between(trunc(t.postdate, 'MM')
													,(lag(trunc(t.postdate, 'MM'))
													  over(PARTITION BY t.accountno ORDER BY t.postdate)))
								 END diff
						  FROM   tcontracttrxnlist t
						  JOIN   taccount a
						  ON     a.accountno = t.accountno
						  AND    a.branch = t.branch
						  WHERE  t.debitentcode = '18'
						  AND    t.postdate BETWEEN p_from_date AND p_to_date
						  AND    t.accountno = p_account
						  AND    a.currencyno = p_currency
						  /*ORDER  BY trunc(t.postdate, 'MM') ASC*/
						  ))
		LOOP
			IF v_amount = 0
			THEN
				v_amount := i.amount;
			ELSE
				v_amount := v_amount + i.amount;
			END IF;
		
			--v_amount := v_amount + v_amount ;
			IF i.diff > 1
			THEN
				v_row_count := i.diff;
				RETURN v_row_count;
			END IF;
		END LOOP;
		v_amnt   := to_char(v_amount);
		v_amount := 0;
		RETURN v_row_count || ',' || v_amnt;
	
		/*  SELECT COUNT(*)
        INTO   v_row_count
        FROM   (SELECT t.debitaccount
                      ,trunc(t.valuedate, 'MM') valuedate
                      ,lag(trunc(t.valuedate, 'MM')) over(PARTITION BY t.debitaccount ORDER BY t.valuedate) fast_row_value_dt
                FROM   tentry t
                JOIN   taccount a
                ON     a.accountno = t.debitaccount
                AND    a.branch = t.branch
                WHERE  t.debitentcode = '18'
                AND    t.valuedate BETWEEN '01-OCT-2020' AND '31-DEC-2020'
                AND    t.debitaccount = p_account
                AND    a.currencyno = '50')
        WHERE  CASE
                   WHEN fast_row_value_dt IS NULL THEN
                    NULL
                   ELSE
                    months_between(valuedate, fast_row_value_dt)
               END > 1;*/
		RETURN v_row_count;
	END;

	FUNCTION get_late_pay_contract_data
	(
		p_from_date DATE
	   ,p_to_date   DATE
	   ,p_contract  VARCHAR2
	   ,p_currency  NUMBER
	) RETURN NUMBER IS
		v_debt_acc VARCHAR2(50);
		v_amount   VARCHAR2(50) := '0';
		--v_count    NUMBER := 0;
		--v_first_month DATE;
		--v_frst_mnt    DATE := '01-OCT-2020';
		--v_count       NUMBER := 0;
		--vmonth_dif    NUMBER;
		--v_yes_no      VARCHAR2(10) := NULL;
	
		--v_row_count NUMBER := NULL;
		v_result VARCHAR2(100);
	
	BEGIN
		dbms_output.put_line('CONTRACT NUMBER' || ' | ' || 'ACCOUNT NUMBER' || ' | ' ||
							 'CONSECUTIVE MONTHS' || '|' || 'AMOUNT');
		FOR i IN (SELECT a.contractno
						,a.accountno
						,COUNT(contractno) c
				  FROM   a4m.tcontracttrxnlist a
						,a4m.taccount          b
				  WHERE  a.branch = 1
				  AND    b.branch = a.branch
				  AND    b.accountno = a.accountno
				  AND    a.debitentcode = '18'
				  AND    a.postdate BETWEEN p_from_date AND p_to_date
				  AND    b.currencyno = p_currency
				  AND    (a.contractno = p_contract OR p_contract IS NULL)
				  GROUP  BY a.contractno
						   ,a.accountno
				  HAVING COUNT(a.contractno) > 1)
		LOOP
			v_debt_acc := i.accountno;
			/*      FOR x IN (SELECT t.*
                      FROM   a4m.tentry t
                      WHERE  t.debitentcode = '18'
                      AND    t.valuedate BETWEEN '01-OCT-2020' AND '31-DEC-2020'
                      AND    t.debitaccount = v_debt_acc
                      ORDER  BY t.valuedate ASC)
            LOOP
                --dbms_output.put_line(x.valuedate || ' : ' || x.value);
            
                v_count := v_count + 1;
            
                IF v_count >= 2
                THEN
                    NULL;
                    vmonth_dif := months_between(x.valuedate, v_frst_mnt);
                    IF vmonth_dif < 2
                    THEN
                        v_frst_mnt := x.valuedate;
                        --dbms_output.put_line(x.debitaccount || ' : ' || x.valuedate || ' : ' ||x.value);
                        v_yes_no := 'YES';
                    ELSE
                        NULL;
                    END IF;
                ELSE
                    v_frst_mnt := x.valuedate;
                END IF;
            END LOOP;*/
		
			/*BEGIN
                SELECT COUNT(*)
                INTO   v_row_count
                FROM   (SELECT t.debitaccount
                              ,trunc(t.valuedate, 'MM') valuedate
                              ,lag(trunc(t.valuedate, 'MM')) over(PARTITION BY t.debitaccount ORDER BY t.valuedate) fast_row_value_dt
                        FROM   tentry t
                        JOIN   taccount a
                        ON     a.accountno = t.debitaccount
                        AND    a.branch = t.branch
                        WHERE  t.debitentcode = '18'
                        AND    t.valuedate BETWEEN '01-OCT-2020' AND '31-DEC-2020'
                        AND    t.debitaccount = v_debt_acc
                        AND    a.currencyno = '50')
                WHERE  CASE
                           WHEN fast_row_value_dt IS NULL THEN
                            NULL
                           ELSE
                            months_between(valuedate, fast_row_value_dt)
                       END > 1;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
                
            END;*/
		
			v_result := get_month_diff(p_account   => v_debt_acc
									  ,p_from_date => p_from_date
									  ,p_to_date   => p_to_date
									  ,p_currency  => p_currency);
		
			IF (substr(v_result, 1, instr(v_result, ',') - 1) = 0)
			THEN
				v_amount := substr(v_result, instr(v_result, ',') + 1);
				dbms_output.put_line(i.contractno || '|' || i.accountno || '|' || i.c || '|' ||
									 v_amount);
			ELSE
				NULL;
				--dbms_output.put_line(i.no || '    | ' || i.debitaccount || '  | ' || i.c);
			END IF;
		
		END LOOP;
		RETURN 1;
	
	END;

	FUNCTION get_month_diff_m2
	(
		p_account   VARCHAR2
	   ,p_from_date DATE
	   ,p_to_date   DATE
		--,p_contract  VARCHAR2
	   ,p_currency NUMBER
	) RETURN VARCHAR2 IS
		v_row_count NUMBER := 0;
		v_count     NUMBER := 0;
		v_amount    NUMBER := 0;
		v_amnt      VARCHAR2(50) := '';
	
		is_seq_found NUMBER := 0;
	BEGIN
		FOR i IN (SELECT diff
						,accountno
						,amount
				  -- INTO   v_row_count
				  FROM   (SELECT t.accountno
								,trunc(t.postdate, 'MM') postdate
								,t.amount
								,lag(trunc(t.postdate, 'MM')) over(PARTITION BY t.accountno ORDER BY t.postdate) fast_row_value_dt
								,CASE
									 WHEN (lag(trunc(t.postdate, 'MM'))
										   over(PARTITION BY t.accountno ORDER BY t.postdate)) IS NULL THEN
									  NULL
									 ELSE
									  months_between(trunc(t.postdate, 'MM')
													,(lag(trunc(t.postdate, 'MM'))
													  over(PARTITION BY t.accountno ORDER BY t.postdate)))
								 END diff
						  FROM   tcontracttrxnlist t
						  JOIN   taccount a
						  ON     a.accountno = t.accountno
						  AND    a.branch = t.branch
						  WHERE  t.debitentcode = '18'
						  AND    t.postdate BETWEEN p_from_date AND p_to_date
						  AND    t.accountno = p_account
						  AND    a.currencyno = p_currency
						  /*ORDER  BY trunc(t.postdate, 'MM') ASC*/
						  ))
		LOOP
			--v_amount := v_amount + v_amount ;
			IF i.diff IS NULL
			THEN
				v_row_count := 1;
				v_amount    := i.amount;
			ELSIF (i.diff = 1 AND v_amount <> 0)
			THEN
				is_seq_found := 1;
				IF v_row_count = 0
				THEN
					v_row_count := i.diff;
				ELSE
					v_row_count := v_row_count + i.diff;
					v_amount    := v_amount + i.amount;
				END IF;
				--RETURN v_row_count;
			ELSIF i.diff > 1
			THEN
				IF is_seq_found = 1
				THEN
					v_amnt      := to_char(v_amount);
					v_amount    := 0;
					v_count     := v_row_count;
					v_row_count := 0;
					RETURN v_count || ',' || v_amnt;
				
				ELSE
					v_row_count := 1;
					v_amount    := i.amount;
				END IF;
			
			END IF;
		
		/*          IF v_row_count > 1
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            THEN
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                v_amount := v_amount + i.amount;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            ELSE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                NULL;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            END IF;*/
		END LOOP;
		--v_amnt   := to_char(v_amount);
		--v_amount := 0;
		--RETURN v_row_count || ',' || v_amnt;
	
		/*  SELECT COUNT(*)
        INTO   v_row_count
        FROM   (SELECT t.debitaccount
                      ,trunc(t.valuedate, 'MM') valuedate
                      ,lag(trunc(t.valuedate, 'MM')) over(PARTITION BY t.debitaccount ORDER BY t.valuedate) fast_row_value_dt
                FROM   tentry t
                JOIN   taccount a
                ON     a.accountno = t.debitaccount
                AND    a.branch = t.branch
                WHERE  t.debitentcode = '18'
                AND    t.valuedate BETWEEN '01-OCT-2020' AND '31-DEC-2020'
                AND    t.debitaccount = p_account
                AND    a.currencyno = '50')
        WHERE  CASE
                   WHEN fast_row_value_dt IS NULL THEN
                    NULL
                   ELSE
                    months_between(valuedate, fast_row_value_dt)
               END > 1;*/
		v_amnt      := to_char(v_amount);
		v_amount    := 0;
		v_count     := v_row_count;
		v_row_count := 0;
		RETURN v_count || ',' || v_amnt;
	
	END;

	FUNCTION get_late_pay_contract_data_m2
	(
		p_from_date DATE
	   ,p_to_date   DATE
	   ,p_contract  VARCHAR2
	   ,p_currency  NUMBER
	) RETURN NUMBER IS
		v_debt_acc VARCHAR2(50);
		v_amount   VARCHAR2(50) := '0';
		--v_count    NUMBER := 0;
		--v_first_month DATE;
		--v_frst_mnt    DATE := '01-OCT-2020';
		--v_count       NUMBER := 0;
		--vmonth_dif    NUMBER;
		--v_yes_no      VARCHAR2(10) := NULL;
	
		--v_row_count NUMBER := NULL;
		v_result    VARCHAR2(100);
		v_row_count VARCHAR2(10) := '';
		vcontract   VARCHAR2(50) := '';
	
	BEGIN
		dbms_output.put_line('CONTRACT NUMBER' || ' | ' || 'ACCOUNT NUMBER' || ' | ' ||
							 'CONSECUTIVE MONTHS' || '|' || 'AMOUNT');
		FOR i IN (SELECT a.contractno
						,a.accountno
						,COUNT(contractno) c
				  FROM   a4m.tcontracttrxnlist a
						,a4m.taccount          b
				  WHERE  a.branch = 1
				  AND    b.branch = a.branch
				  AND    b.accountno = a.accountno
				  AND    a.debitentcode = '18'
				  AND    a.postdate BETWEEN p_from_date AND p_to_date
				  AND    b.currencyno = p_currency
				  AND    (a.contractno = p_contract OR p_contract IS NULL)
				  GROUP  BY a.contractno
						   ,a.accountno
				  HAVING COUNT(a.contractno) > 1)
		LOOP
			v_debt_acc := i.accountno;
			/*      FOR x IN (SELECT t.*
                      FROM   a4m.tentry t
                      WHERE  t.debitentcode = '18'
                      AND    t.valuedate BETWEEN '01-OCT-2020' AND '31-DEC-2020'
                      AND    t.debitaccount = v_debt_acc
                      ORDER  BY t.valuedate ASC)
            LOOP
                --dbms_output.put_line(x.valuedate || ' : ' || x.value);
            
                v_count := v_count + 1;
            
                IF v_count >= 2
                THEN
                    NULL;
                    vmonth_dif := months_between(x.valuedate, v_frst_mnt);
                    IF vmonth_dif < 2
                    THEN
                        v_frst_mnt := x.valuedate;
                        --dbms_output.put_line(x.debitaccount || ' : ' || x.valuedate || ' : ' ||x.value);
                        v_yes_no := 'YES';
                    ELSE
                        NULL;
                    END IF;
                ELSE
                    v_frst_mnt := x.valuedate;
                END IF;
            END LOOP;*/
		
			/*BEGIN
                SELECT COUNT(*)
                INTO   v_row_count
                FROM   (SELECT t.debitaccount
                              ,trunc(t.valuedate, 'MM') valuedate
                              ,lag(trunc(t.valuedate, 'MM')) over(PARTITION BY t.debitaccount ORDER BY t.valuedate) fast_row_value_dt
                        FROM   tentry t
                        JOIN   taccount a
                        ON     a.accountno = t.debitaccount
                        AND    a.branch = t.branch
                        WHERE  t.debitentcode = '18'
                        AND    t.valuedate BETWEEN '01-OCT-2020' AND '31-DEC-2020'
                        AND    t.debitaccount = v_debt_acc
                        AND    a.currencyno = '50')
                WHERE  CASE
                           WHEN fast_row_value_dt IS NULL THEN
                            NULL
                           ELSE
                            months_between(valuedate, fast_row_value_dt)
                       END > 1;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
                
            END;*/
			vcontract := i.contractno;
			v_result  := get_month_diff_m2(p_account   => v_debt_acc
										  ,p_from_date => p_from_date
										  ,p_to_date   => p_to_date
										  ,p_currency  => p_currency);
			BEGIN
				IF (substr(v_result, 1, instr(v_result, ',') - 1) > 1)
				THEN
					v_amount    := substr(v_result, instr(v_result, ',') + 1);
					v_row_count := substr(v_result, 1, instr(v_result, ',') - 1);
					dbms_output.put_line(i.contractno || '|' || i.accountno || '|' || v_row_count || '|' ||
										 v_amount);
				ELSE
					NULL;
				
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					dbms_output.put_line('exception: ' || i.contractno);
					--NULL;
			END;
		
		END LOOP;
		--v_result := '';
		RETURN 1;
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line(v_result);
			dbms_output.put_line(vcontract);
			--NULL;
			RETURN 2;
		
	END;

	FUNCTION get_con_bdt_lmt_by_clnt(p_client VARCHAR2) RETURN NUMBER IS
	
		v_return NUMBER := 0;
	BEGIN
		BEGIN
		
			SELECT SUM(nvl(a.overdraft, 0))
			INTO   v_return
			FROM   tcontract c
			
			JOIN   tcontractitem i
			ON     c.no = i.no
			AND    c.branch = i.branch
			
			JOIN   taccount a
			ON     i.key = a.accountno
			AND    i.branch = a.branch
			
			WHERE  c.idclient = p_client
			AND    a.currencyno <> '9999'
			AND    a.currencyno = 50
			AND    decode(rtrim(c.status)
						 ,'1'
						 ,'Closed'
						 ,' 1'
						 ,'Violated'
						 ,'  1'
						 ,'Suspended'
						 ,'   1'
						 ,'In Debt Collector'
						 ,'Ok') != 'Closed';
			RETURN v_return;
		EXCEPTION
			WHEN OTHERS THEN
				v_return := 0;
		END;
		RETURN v_return;
	END;

	FUNCTION get_con_usd_lmt_by_clnt(p_client VARCHAR2) RETURN NUMBER IS
	
		v_return NUMBER := 0;
	BEGIN
		BEGIN
		
			SELECT SUM(nvl(a.overdraft, 0))
			INTO   v_return
			FROM   tcontract c
			
			JOIN   tcontractitem i
			ON     c.no = i.no
			AND    c.branch = i.branch
			
			JOIN   taccount a
			ON     i.key = a.accountno
			AND    i.branch = a.branch
			
			WHERE  c.idclient = p_client
			AND    a.currencyno <> '9999'
			AND    a.currencyno = 840
			AND    decode(rtrim(c.status)
						 ,'1'
						 ,'Closed'
						 ,' 1'
						 ,'Violated'
						 ,'  1'
						 ,'Suspended'
						 ,'   1'
						 ,'In Debt Collector'
						 ,'Ok') != 'Closed';
			RETURN v_return;
		EXCEPTION
			WHEN OTHERS THEN
				v_return := 0;
		END;
		RETURN v_return;
	END;

	FUNCTION getcontractattributebyparamid
	(
		p_client_id VARCHAR
	   ,vparamid    VARCHAR
	) RETURN VARCHAR2 IS
		v_result   VARCHAR2(4000);
		v_contract VARCHAR2(50);
		v_count    NUMBER := 0;
	BEGIN
	
		FOR i IN (SELECT t.no
						,oapc.valuestr
				  FROM   tobjadditionalproperty oap
				  
				  JOIN   tobjaddpropdata_contract oapc
				  ON     oapc.propid = oap.id
				  
				  JOIN   tcontract t
				  ON     t.objectuid = oapc.ownerid
				  
				  WHERE  oap.extid = vparamid
				  AND    t.idclient = p_client_id)
		LOOP
			v_contract := i.no;
			v_result   := i.valuestr;
			IF v_result IS NOT NULL
			THEN
				RETURN v_result;
			END IF;
		END LOOP;
		IF v_result IS NULL
		THEN
			v_result := ' ';
		END IF;
		RETURN v_result;
	
	END;

	FUNCTION getcntrbctattrbyparamidbycon
	(
		vcontractno VARCHAR
	   ,vparamid    VARCHAR
	) RETURN VARCHAR2 IS
		v_result   VARCHAR2(200);
		v_contract VARCHAR2(20);
		v_count    NUMBER := 0;
	BEGIN
	
		FOR i IN (SELECT t.no
						,oapc.valuestr
				  -- oap.id, oap.extid 
				  ---INTO   v_contract,v_result
				  FROM   tobjadditionalproperty oap
				  
				  JOIN   tobjaddpropdata_contract oapc
				  ON     oapc.propid = oap.id
				  
				  JOIN   tcontract t
				  ON     t.objectuid = oapc.ownerid
				  
				  WHERE  oap.extid = vparamid
				  AND    t.no = vcontractno) --p_client_id
		LOOP
			v_contract := i.no;
			v_result   := i.valuestr;
			IF v_result IS NOT NULL
			THEN
				RETURN v_result;
			END IF;
		END LOOP;
		IF v_result IS NULL
		THEN
			v_result := ' ';
		END IF;
		RETURN v_result;
	END;

	FUNCTION get_con_bdt_lmt_by_con(p_con VARCHAR2) RETURN NUMBER IS
	
		v_return NUMBER := 0;
	BEGIN
		BEGIN
		
			SELECT nvl(SUM(nvl(a.overdraft, 0)), 0)
			INTO   v_return
			FROM   tcontract c
			
			JOIN   tcontractitem i
			ON     c.no = i.no
			AND    c.branch = i.branch
			
			JOIN   taccount a
			ON     i.key = a.accountno
			AND    i.branch = a.branch
			
			WHERE  c.no = p_con
			AND    a.currencyno <> '9999'
			AND    a.currencyno = 50
			AND    decode(rtrim(c.status)
						 ,'1'
						 ,'Closed'
						 ,' 1'
						 ,'Violated'
						 ,'  1'
						 ,'Suspended'
						 ,'   1'
						 ,'In Debt Collector'
						 ,'Ok') != 'Closed';
			RETURN v_return;
		EXCEPTION
			WHEN OTHERS THEN
				v_return := 0;
		END;
		RETURN v_return;
	END;

	FUNCTION get_con_usd_lmt_by_con(p_con VARCHAR2) RETURN NUMBER IS
	
		v_return NUMBER := 0;
	BEGIN
		BEGIN
		
			SELECT nvl(SUM(nvl(a.overdraft, 0)), 0)
			INTO   v_return
			FROM   tcontract c
			
			JOIN   tcontractitem i
			ON     c.no = i.no
			AND    c.branch = i.branch
			
			JOIN   taccount a
			ON     i.key = a.accountno
			AND    i.branch = a.branch
			
			WHERE  c.no = p_con
			AND    a.currencyno <> '9999'
			AND    a.currencyno = 840
			AND    decode(rtrim(c.status)
						 ,'1'
						 ,'Closed'
						 ,' 1'
						 ,'Violated'
						 ,'  1'
						 ,'Suspended'
						 ,'   1'
						 ,'In Debt Collector'
						 ,'Ok') != 'Closed';
			RETURN v_return;
		EXCEPTION
			WHEN OTHERS THEN
				v_return := 0;
		END;
		RETURN v_return;
	END;

	FUNCTION con_usd_lmt_by_clnt_dt
	(
		p_client   VARCHAR2
	   ,p_frm_date DATE
	   ,p_to_date  DATE
		-- ,p_rate     NUMBER
	) RETURN NUMBER IS
	
		v_return NUMBER := 0;
		--v_rate   NUMBER;
	BEGIN
		BEGIN
			--v_rate := nvl(p_rate, 0);
			SELECT nvl(SUM(nvl(a.overdraft, 0)), 0)
			INTO   v_return
			FROM   tcontract c
			
			JOIN   tcontractitem i
			ON     c.no = i.no
			AND    c.branch = i.branch
			
			JOIN   taccount a
			ON     i.key = a.accountno
			AND    i.branch = a.branch
			
			WHERE  c.idclient = p_client
			AND    a.currencyno <> '9999'
			AND    a.currencyno = 840
			AND    c.createdate BETWEEN p_frm_date AND p_to_date
			AND    decode(rtrim(c.status)
						 ,'1'
						 ,'Closed'
						 ,' 1'
						 ,'Violated'
						 ,'  1'
						 ,'Suspended'
						 ,'   1'
						 ,'In Debt Collector'
						 ,'Ok') != 'Closed';
			RETURN v_return;
		EXCEPTION
			WHEN OTHERS THEN
				v_return := 0;
		END;
		RETURN v_return;
	END;

	FUNCTION con_bdt_lmt_by_clnt_dt
	(
		p_client   VARCHAR2
	   ,p_frm_date DATE
	   ,p_to_date  DATE
	) RETURN NUMBER IS
	
		v_return NUMBER := 0;
	BEGIN
		BEGIN
		
			SELECT nvl(SUM(nvl(a.overdraft, 0)), 0)
			INTO   v_return
			FROM   tcontract c
			
			JOIN   tcontractitem i
			ON     c.no = i.no
			AND    c.branch = i.branch
			
			JOIN   taccount a
			ON     i.key = a.accountno
			AND    i.branch = a.branch
			
			WHERE  c.idclient = p_client
			AND    a.currencyno <> '9999'
			AND    a.currencyno = 50
			AND    c.createdate BETWEEN p_frm_date AND p_to_date
			AND    decode(rtrim(c.status)
						 ,'1'
						 ,'Closed'
						 ,' 1'
						 ,'Violated'
						 ,'  1'
						 ,'Suspended'
						 ,'   1'
						 ,'In Debt Collector'
						 ,'Ok') != 'Closed';
			RETURN v_return;
		EXCEPTION
			WHEN OTHERS THEN
				v_return := 0;
		END;
		RETURN v_return;
	END;

	FUNCTION get_cust_contract_type RETURN VARCHAR2 IS
		v_contract_type CLOB := '';
	
	BEGIN
		FOR i IN (SELECT UNIQUE c.type
						,t.name
				  FROM   a4m.tcontracttypeitems c
				  INNER  JOIN a4m.tcontractaccount a
				  ON     c.itemcode = a.code
				  INNER  JOIN a4m.tcontracttype t
				  ON     c.type = t.type
				  AND    t.status = '1'
				  AND    (a.acctype = 1 OR a.acctype = 2 OR a.acctype = 9 OR a.acctype = 10 OR
						a.acctype = 30 OR a.acctype = 31 OR a.acctype = 20 OR a.acctype = 35 OR
						a.acctype = 36 OR a.acctype = 49 OR a.acctype = 50)
						--and T.status = '1' and (A.ACCTYPE = 9 or A.ACCTYPE = 10 or A.ACCTYPE = 30 or A.ACCTYPE = 31)
						--and T.status = '1' and (A.ACCTYPE = 20 or A.ACCTYPE = 35 or A.ACCTYPE = 36)--without vendor card
				  AND    c.branch = 1
				  AND    c.branch = a.branch
				  AND    c.branch = t.branch
				  ORDER  BY t.name)
		LOOP
			IF TRIM(v_contract_type) IS NULL
			THEN
				v_contract_type := v_contract_type || i.type;
			ELSE
				v_contract_type := v_contract_type || ',' || i.type;
			END IF;
		END LOOP;
	
		RETURN v_contract_type;
	END;
	FUNCTION get_bdt_overdue_by_con(p_con VARCHAR2) RETURN NUMBER IS
		v_bdt_overdue NUMBER := 0;
	
	BEGIN
		BEGIN
			SELECT substr(substr(t.calcinfo, instr(t.calcinfo, 'DD=', 1, 1) + 3)
						 ,1
						 ,instr(substr(t.calcinfo, instr(t.calcinfo, 'DD=') + 3), ';') - 1)
			INTO   v_bdt_overdue
			
			FROM   a4m.toverduefeecalclogmain t
			JOIN   taccount a
			ON     a.accountno = t.accountno
			AND    a.branch = t.branch
			AND    a.currencyno = 50
			WHERE  t.contractno = p_con
			AND    t.operdate = (SELECT MAX(l.operdate)
								 FROM   a4m.toverduefeecalclogmain l
								 WHERE  l.contractno = t.contractno
								 AND    t.accountno = l.accountno);
		EXCEPTION
			WHEN OTHERS THEN
				v_bdt_overdue := 0;
		END;
		RETURN v_bdt_overdue;
	END;

	FUNCTION get_usd_overdue_by_con(p_con VARCHAR2) RETURN NUMBER IS
		v_usd_overdue NUMBER := 0;
	
	BEGIN
		BEGIN
			SELECT CASE
					   WHEN instr(t.calcinfo, 'DD=', 1, 2) <> 0 THEN
						substr(substr(t.calcinfo, instr(t.calcinfo, 'DD=', 1, 2) + 3)
							  ,1
							  ,instr(substr(t.calcinfo, instr(t.calcinfo, 'DD=', 1, 2) + 3), ';') - 1)
					   ELSE
						'0'
				   END
			INTO   v_usd_overdue
			
			FROM   a4m.toverduefeecalclogmain t
			JOIN   taccount a
			ON     a.accountno = t.accountno
			AND    a.branch = t.branch
			AND    a.currencyno = 840
			WHERE  t.contractno = p_con
			AND    t.operdate = (SELECT MAX(l.operdate)
								 FROM   a4m.toverduefeecalclogmain l
								 WHERE  l.contractno = t.contractno
								 AND    t.accountno = l.accountno);
		EXCEPTION
			WHEN OTHERS THEN
				v_usd_overdue := 0;
		END;
		RETURN v_usd_overdue;
	END;

	FUNCTION get_cycle_by_con(p_con VARCHAR2) RETURN VARCHAR2 IS
		v_cycle VARCHAR2(10) := ' ';
	BEGIN
		BEGIN
			SELECT CASE
					   WHEN instr(t.name, 'CREDIT SCHEME') > 0 THEN
						substr(substr(t.name, instr(t.name, '[MG:') + 4)
							  ,1
							  ,instr(substr(t.name, instr(t.name, '[MG:') + 4), ']') - 1)
					   WHEN (instr(lower(t.name), 'installment') = 0 AND
							instr(substr(TRIM(t.name), -2), '-') = 0 AND
							instr(lower(t.name), 'reward') = 0 AND
							instr(lower(t.name), 'weekly') = 0 AND instr(lower(t.name), 'beta') = 0) THEN
						substr(TRIM(t.name), -2)
				   
					   WHEN instr(t.name, 'Reward') > 0 THEN
						'None'
					   WHEN instr(lower(t.name), 'weekly') > 0 THEN
						'None'
					   WHEN instr(lower(t.name), 'beta') > 0 THEN
						'None'
					   WHEN instr(lower(t.name), 'installment') > 0 THEN
						'None'
					   WHEN instr(lower(t.name), 'cycle-') > 0 THEN
						substr(t.name, instr(lower(t.name), 'cycle-') + 6)
					   WHEN instr(lower(t.name), 'cycle ') > 0 THEN
						substr(t.name, instr(lower(t.name), 'cycle ') + 6)
				   END AS cycle
			INTO   v_cycle
			FROM   tcontracttype t
			JOIN   tcontract c
			ON     c.type = t.type
			AND    c.branch = t.branch
			WHERE  c.no = p_con;
		EXCEPTION
			WHEN OTHERS THEN
				v_cycle := ' ';
		END;
		RETURN v_cycle;
	END;

	FUNCTION get_ageing_by_con
	(
		p_con  VARCHAR2
	   ,p_date DATE
	) RETURN VARCHAR2 IS
		v_ageing VARCHAR2(20) := '';
	BEGIN
		BEGIN
			SELECT DISTINCT statecode
			INTO   v_ageing
			FROM   (
					
					SELECT DISTINCT t.contractno
									 --,t.packno
									 --,t.recno
									,t.operdate  operdate
									,t.statecode statecode
					-- ,t.overdue
					-- ,t.overlimit
					-- ,t.operation                   key
					-- ,t.aggregatedoverdueamount
					--  ,t.aggregatedoverdueamountcurr
					-- ,t.calculatedovdperiodinterval
					FROM   tcontractstatehistory t
					WHERE  t.contractno = p_con
					AND    (t.operdate <= p_date OR p_date IS NULL)
					
					UNION
					
					SELECT h.contractno
						   --,h.packno
						   --,h.recno
						  ,h.operdate operdate
						  ,h.value    statecode
					--  ,0            AS overdue
					--  ,0            AS overlimit
					--,h.key
					--  ,0            AS aggregatedoverdueamount
					-- ,0            AS aggregatedoverdueamountcurr
					-- ,0            AS calculatedovdperiodinterval
					FROM   tcontracthistory h
					WHERE  h.contractno = p_con
					AND    (h.operdate <= p_date OR p_date IS NULL)
					AND    h.key = 'CHANGE_DELINQUENCY_STATE'
					ORDER  BY operdate DESC)
			
			WHERE  rownum = 1;
		EXCEPTION
			WHEN OTHERS THEN
				v_ageing := '';
		END;
		RETURN v_ageing;
	END;

	FUNCTION get_classified_date
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
			IF (p_aging >= 3 AND p_aging <= 8)
			THEN
				v_s := 3;
				/*      ELSIF (p_aging >= 6 AND p_aging <= 8)
                THEN
                    v_s := 6;*/
			ELSIF (p_aging >= 9 AND p_aging <= 11)
			THEN
				v_s := 9;
			ELSE
				v_s := 12;
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

END;
/
