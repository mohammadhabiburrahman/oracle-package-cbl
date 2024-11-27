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
	FUNCTION get_parm
	(
		pstring IN VARCHAR2
	   ,pno     IN NUMBER
	)
	
	 RETURN NUMBER;
	FUNCTION get_rate_by_comm_id(p_comm_id NUMBER) RETURN VARCHAR2;
	FUNCTION get_amt_by_comm_id(p_comm_id NUMBER) RETURN VARCHAR2;
	FUNCTION get_minamt_by_comm_id(p_comm_id NUMBER) RETURN VARCHAR2;
	FUNCTION get_maxamt_by_comm_id(p_comm_id NUMBER) RETURN VARCHAR2;
	/*FUNCTION get_bdt_install_acc_by_con(p_con VARCHAR2) RETURN VARCHAR2;
    FUNCTION get_usd_install_acc_by_con(p_con VARCHAR2) RETURN VARCHAR2;*/

	FUNCTION get_account_record(paccountno IN taccount.accountno%TYPE
								--,pguid      types.guid := NULL
								) RETURN apitypes.typeaccountrecord;
	FUNCTION get_account_list(pcontractno IN VARCHAR2) RETURN apitypes.typeaccountlist;

	FUNCTION getunpaidsum
	(
		pbranch         IN NUMBER
	   ,pccy            IN NUMBER
	   ,paccountno      IN VARCHAR
	   ,precno          IN NUMBER
	   ,pstdate         IN DATE
	   ,preverseenddate IN DATE
	   ,pdate           IN DATE
	) RETURN NUMBER;
	FUNCTION getcurrency
	(
		pbranch    IN NUMBER
	   ,paccountno IN VARCHAR
	) RETURN NUMBER;
	FUNCTION getoverdueamount
	(
		pbranch    IN NUMBER
	   ,paccountno IN VARCHAR
	   ,pdate      IN DATE
	) RETURN NUMBER;
	FUNCTION getoverdueamount_bdt
	(
		p_con  VARCHAR2
	   ,p_date DATE
	) RETURN NUMBER;
	FUNCTION getoverdueamount_usd
	(
		p_con  VARCHAR2
	   ,p_date DATE
	) RETURN NUMBER;
	FUNCTION check_brpd_eli_no_tran(p_con VARCHAR2) RETURN NUMBER;
	FUNCTION get_last_positive_bal_date(p_con VARCHAR2) RETURN DATE;
	FUNCTION get_primary_pan_frm_account(p_acc VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_latest_pan_frm_account(p_acc VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_branch_code_by_doc
	(
		p_doc     NUMBER
	   ,p_entcode NUMBER
	) RETURN VARCHAR2;
	FUNCTION get_os_spec_date_acc(p_account_no VARCHAR2
								  -- ,p_fromdate    DATE
								 ,p_to_date DATE) RETURN NUMBER;

	FUNCTION get_debit_bal_acc(p_account_no VARCHAR2
							   -- ,p_fromdate    DATE
							  ,p_to_date DATE) RETURN NUMBER;
	FUNCTION get_credit_bal_acc(p_account_no VARCHAR2
								-- ,p_fromdate    DATE
							   ,p_to_date DATE) RETURN NUMBER;
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
			AND    a.accounttype IN (2, 10, 31, 50, 22);
		
		EXCEPTION
			WHEN OTHERS THEN
				BEGIN
					SELECT t.account_usd
					INTO   v_account
					FROM   custom_global_limit t
					WHERE  t.contract_no = p_con;
				EXCEPTION
					WHEN OTHERS THEN
						v_account := '';
				END;
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

	FUNCTION get_parm
	(
		pstring IN VARCHAR2
	   ,pno     IN NUMBER
	)
	
	 RETURN NUMBER IS
		vbeg NUMBER;
		vend NUMBER;
	BEGIN
		vbeg := instr(pstring, '|', 1, pno);
		vend := instr(pstring, '|', 1, pno + 1);
		IF vbeg IS NULL
		   OR vend IS NULL
		THEN
			RETURN NULL;
		END IF;
		RETURN substr(pstring, vbeg + 1, vend - vbeg - 1);
	END;

	FUNCTION get_rate_by_comm_id(p_comm_id NUMBER) RETURN VARCHAR2 IS
		v_rate VARCHAR2(20) := '';
	BEGIN
		BEGIN
			SELECT custom_account.get_parm(i.cvalue, 2)
			INTO   v_rate
			FROM   treferencecommission c
			JOIN   tdatamember d
			ON     d.code = c.commission
			AND    d.branch = c.branch
			
			JOIN   tdatamemberinterval i
			ON     i.mbrcode = d.mbrcode
			
			WHERE  c.commission = p_comm_id;
		EXCEPTION
			WHEN OTHERS THEN
				v_rate := '';
		END;
		RETURN v_rate;
	END;

	FUNCTION get_amt_by_comm_id(p_comm_id NUMBER) RETURN VARCHAR2 IS
		v_rate VARCHAR2(20) := '';
	BEGIN
		BEGIN
			SELECT custom_account.get_parm(i.cvalue, 1)
			INTO   v_rate
			FROM   treferencecommission c
			JOIN   tdatamember d
			ON     d.code = c.commission
			AND    d.branch = c.branch
			
			JOIN   tdatamemberinterval i
			ON     i.mbrcode = d.mbrcode
			
			WHERE  c.commission = p_comm_id;
		EXCEPTION
			WHEN OTHERS THEN
				v_rate := '';
		END;
		RETURN v_rate;
	END;

	FUNCTION get_minamt_by_comm_id(p_comm_id NUMBER) RETURN VARCHAR2 IS
		v_rate VARCHAR2(20) := '';
	BEGIN
		BEGIN
			SELECT custom_account.get_parm(i.cvalue, 3)
			INTO   v_rate
			FROM   treferencecommission c
			JOIN   tdatamember d
			ON     d.code = c.commission
			AND    d.branch = c.branch
			
			JOIN   tdatamemberinterval i
			ON     i.mbrcode = d.mbrcode
			
			WHERE  c.commission = p_comm_id;
		EXCEPTION
			WHEN OTHERS THEN
				v_rate := '';
		END;
		RETURN v_rate;
	END;
	FUNCTION get_maxamt_by_comm_id(p_comm_id NUMBER) RETURN VARCHAR2 IS
		v_rate VARCHAR2(20) := '';
	BEGIN
		BEGIN
			SELECT custom_account.get_parm(i.cvalue, 4)
			INTO   v_rate
			FROM   treferencecommission c
			JOIN   tdatamember d
			ON     d.code = c.commission
			AND    d.branch = c.branch
			
			JOIN   tdatamemberinterval i
			ON     i.mbrcode = d.mbrcode
			
			WHERE  c.commission = p_comm_id;
		EXCEPTION
			WHEN OTHERS THEN
				v_rate := '';
		END;
		RETURN v_rate;
	END;

	/*FUNCTION get_bdt_install_acc_by_con(p_con VARCHAR2) RETURN VARCHAR2 IS
            v_install_acc taccount.accountno%TYPE;
        BEGIN
            BEGIN
                SELECT ci.key
                INTO   v_install_acc
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
                                 AND    i.no = p_con
                                 AND    l.linkname = 'INSTALLMENT');
            EXCEPTION
                WHEN OTHERS THEN
                    v_install_acc := NULL;
            END;
            RETURN v_install_acc;
        END;
    
        FUNCTION get_usd_install_acc_by_con(p_con VARCHAR2) RETURN VARCHAR2 IS
            v_install_acc taccount.accountno%TYPE;
        BEGIN
            BEGIN
                SELECT ci.key
                INTO   v_install_acc
                FROM   a4m.tcontractitem ci
                JOIN   a4m.taccount aa
                ON     aa.accountno = ci.key
                AND    aa.branch = ci.branch
                WHERE  aa.currencyno = 840
                AND    ci.no = (
                                
                                SELECT l.linkno
                                FROM   a4m.tcontractitem i
                                JOIN   a4m.taccount a
                                ON     a.accountno = i.key
                                AND    a.branch = i.branch
                                JOIN   a4m.tcontractlink l
                                ON     l.mainno = i.no
                                AND    l.branch = i.branch
                                
                                WHERE  a.currencyno = 840
                                AND    i.no = p_con
                                AND    l.linkname = 'INSTALLMENT');
            EXCEPTION
                WHEN OTHERS THEN
                    v_install_acc := NULL;
            END;
            RETURN v_install_acc;
        END;
    */

	FUNCTION get_account_record(paccountno IN taccount.accountno%TYPE
								--,pguid      types.guid := NULL
								) RETURN apitypes.typeaccountrecord IS
		vbranch        NUMBER := 1;
		vaccountrecord apitypes.typeaccountrecord;
		--vplanaccounttype NUMBER;
	BEGIN
	
		SELECT accountno
			  ,accounttype
			  ,noplan
			  ,stat
			  ,currencyno
			  ,idclient
			  ,remain
			  ,available
			  ,lowremain
			  ,overdraft
			  ,debitreserve
			  ,creditreserve
			  ,branchpart
			  ,createclerkcode
			  ,createdate
			  ,updateclerkcode
			  ,updatedate
			  ,updatesysdate
			  ,acct_typ
			  ,acct_stat
			  ,oldaccountno
			  ,closedate
			  ,remark
			  ,limitgrpid
			  ,remainupdatedate
			  ,
			   
			   finprofile
			  ,
			   
			   NULL
			  ,
			   
			   internallimitsgroupsysid
			  ,
			   
			   countergrpid
			  ,permissibleexcesstype
			  ,permissibleexcess
			  ,protectedamount
		INTO   vaccountrecord
		FROM   taccount a
			  ,tacc2acc b
		WHERE  a.branch = vbranch
		AND    a.accountno = paccountno
		AND    b.branch(+) = a.branch
		AND    b.newaccountno(+) = a.accountno;
	
		/*        vplanaccounttype := planaccount.gettype(vaccountrecord.noplan);
        error.raisewhenerr();
        IF (vplanaccounttype = planaccount.type_nonconsolidated)
        THEN
            vaccountrecord.extaccountno := planaccount.getexternal(vaccountrecord.noplan);
            error.raisewhenerr();
        END IF;
        
        IF pguid IS NULL
        THEN
        
            vaccountrecord.guid := getguid(vaccountrecord.accountno);
            error.raisewhenerr();
        
        ELSE
            vaccountrecord.guid := pguid;
        END IF;*/
	
		RETURN vaccountrecord;
	EXCEPTION
		WHEN no_data_found THEN
			-- setaccountnotfounderror(paccountno, 'GetAccountRecord');
			RETURN NULL;
		WHEN OTHERS THEN
		
			--setexceptionerror('GetAccountRecord', paccountno);
			RETURN NULL;
			RETURN NULL;
	END;

	FUNCTION get_account_list(pcontractno IN VARCHAR2) RETURN apitypes.typeaccountlist IS
		cbranch CONSTANT NUMBER := 1;
		vindex       NUMBER := 0;
		vaccountlist apitypes.typeaccountlist;
	
		CURSOR c1 IS
		
			SELECT t.key
			FROM   tcontractitem t
			WHERE  t.branch = cbranch
			AND    t.no = pcontractno
			
			UNION
			
			SELECT g.account_usd FROM custom_global_limit g WHERE g.contract_no = pcontractno;
	
	BEGIN
		FOR i IN c1
		LOOP
			vindex := vindex + 1;
			vaccountlist(vindex) := get_account_record(i.key);
		END LOOP;
	
		RETURN vaccountlist;
	EXCEPTION
		WHEN OTHERS THEN
			--error.save(cmethod_name);
			RAISE;
	END get_account_list;

	FUNCTION getunpaidsum
	(
		pbranch         IN NUMBER
	   ,pccy            IN NUMBER
	   ,paccountno      IN VARCHAR
	   ,precno          IN NUMBER
	   ,pstdate         IN DATE
	   ,preverseenddate IN DATE
	   ,pdate           IN DATE
	) RETURN NUMBER IS
		TYPE typerepaymrow IS RECORD(
			 amount   NUMBER
			,postdate DATE);
		TYPE typerepaymarray IS TABLE OF typerepaymrow INDEX BY BINARY_INTEGER;
		vret     NUMBER;
		vpaid    NUMBER;
		vapaid   typerepaymarray;
		vreverse NUMBER;
		vdelta   NUMBER;
	BEGIN
		--dbms_output.put_line(precno || '|' || pccy);
		SELECT minpayment
		INTO   vret
		FROM   tcontractstminpaymentdata
		WHERE  branch = pbranch
		AND    screcno = precno
		AND    currencynumber = pccy;
	
		SELECT nvl(SUM(amount), 0)
			  ,postdate BULK COLLECT
		INTO   vapaid
		FROM   (SELECT /*+ INDEX (a iContractTrxnList_ANoTGOrder) */
				 a.amount
				,a.postdate
				FROM   tcontracttrxnlist a
				WHERE  a.branch = pbranch
				AND    a.accountno = paccountno
				AND    a.trantype = 3
				AND    a.postdate BETWEEN pstdate + 1 AND pdate
				UNION
				SELECT /*+ INDEX (a iContractTrxnList_ANoTGOrder) */
				 -a.amount
				,a.postdate
				FROM   tcontracttrxnlist a
				WHERE  a.branch = pbranch
				AND    a.accountno = paccountno
				AND    a.trantype = 2
				AND    a.postdate BETWEEN pstdate + 1 AND pdate)
		GROUP  BY postdate
		ORDER  BY postdate;
		vpaid := 0;
		IF vapaid.count > 0
		THEN
			FOR i IN REVERSE 1 .. vapaid.count
			LOOP
				IF vapaid(i).amount < 0
					AND i > 1
				THEN
					vreverse := vapaid(i).amount;
					FOR j IN REVERSE 1 .. i - 1
					LOOP
						IF vapaid(j).amount > 0
							AND (vapaid(i).postdate > preverseenddate AND vapaid(j)
								 .postdate > preverseenddate OR vapaid(i)
								 .postdate <= preverseenddate AND vapaid(j)
								 .postdate <= preverseenddate)
						THEN
							vdelta := least(vapaid(j).amount, abs(vreverse));
							vapaid(j).amount := vapaid(j).amount - vdelta;
							vreverse := vreverse + vdelta;
						END IF;
						IF vreverse = 0
						THEN
							EXIT;
						END IF;
					END LOOP;
				END IF;
			END LOOP;
			FOR i IN 1 .. vapaid.count
			LOOP
				IF vapaid(i).amount > 0
				THEN
					vpaid := vpaid + vapaid(i).amount;
				END IF;
			END LOOP;
		END IF;
		RETURN greatest(least(vret - vpaid, vret), 0);
	EXCEPTION
		WHEN OTHERS THEN
			--dbms_output.put_line('GetUnpaidSum');
			RETURN 0;
			RAISE;
	END;

	FUNCTION getcurrency
	(
		pbranch    IN NUMBER
	   ,paccountno IN VARCHAR
	) RETURN NUMBER IS
		vitemname tcontracttypeitemname.itemname%TYPE;
	BEGIN
		SELECT itemname
		INTO   vitemname
		FROM   tcontractitem         ci
			  ,tcontracttypeitemname ctin
		WHERE  ci.branch = pbranch
		AND    ci.key = paccountno
		AND    ctin.branch = ci.branch
		AND    ctin.itemcode = ci.itemcode;
		CASE substr(vitemname, length(vitemname) - 2)
			WHEN 'DOM' THEN
				RETURN 1;
			WHEN 'INT' THEN
				RETURN 2;
			ELSE
				RETURN 0;
				--dbms_output.put_line(paccountno || ' does not belong to Revolving contract');
		END CASE;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 0;
			--dbms_output.put_line('GetCurrency');
			RAISE;
	END;

	FUNCTION getoverdueamount
	(
		pbranch    IN NUMBER
	   ,paccountno IN VARCHAR
	   ,pdate      IN DATE
	) RETURN NUMBER IS
		vcontractno tcontract.no%TYPE;
		vrecno      NUMBER;
		vrecno2     NUMBER;
		vddate      DATE;
		vstdate     DATE;
		vstdate2    DATE;
		vcurrency   NUMBER;
	BEGIN
		BEGIN
			SELECT a.no
			INTO   vcontractno
			FROM   tcontractitem a
			WHERE  a.branch = pbranch
			AND    a.key = paccountno;
		EXCEPTION
			WHEN no_data_found THEN
				RETURN 0;
				--dbms_output.put_line('GetDueAmount Customer contract not found');
		END;
		vrecno  := 0;
		vrecno2 := 0;
		FOR i IN (SELECT recno
						,statementdate
						,duedate
				  FROM   tcontractstcycle
				  WHERE  branch = pbranch
				  AND    contractno = vcontractno
				  AND    statementdate <= pdate
				  ORDER  BY statementdate DESC)
		LOOP
			IF vrecno = 0
			THEN
				vrecno  := i.recno;
				vstdate := i.statementdate;
				/*              dbms_output.put_line('1->' || i.recno || '|' || i.statementdate);
                */
			END IF;
			vddate   := i.duedate;
			vrecno2  := i.recno;
			vstdate2 := i.statementdate;
			/*          dbms_output.put_line('2->' || i.recno || '|' || i.statementdate || '|' || i.duedate);
            dbms_output.put_line('3->' || vddate || '|' || pdate);*/
			IF vddate <= pdate
			THEN
				EXIT;
			END IF;
		END LOOP;
		IF vrecno = 0
		THEN
			RETURN 0;
		END IF;
		vcurrency := getcurrency(pbranch, paccountno);
		--dbms_output.put_line('4->' || vddate || '|' || pdate);
		IF vddate > pdate
		THEN
			RETURN 0;
		ELSE
			/*          dbms_output.put_line(pbranch || '|' || vcurrency || '|' || paccountno || '|' ||
            vrecno2 || '|' || vstdate2 || '|' || vstdate || '|' || pdate);*/
			RETURN - getunpaidsum(pbranch
								 ,vcurrency
								 ,paccountno
								 ,vrecno2
								 ,vstdate2
								 ,vstdate
								 ,pdate);
		END IF;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 0;
			--dbms_output.put_line('GetOverDueAmount (3)');
		--RAISE;
	END;

	FUNCTION getoverdueamount_bdt
	(
		p_con  VARCHAR2
	   ,p_date DATE
		
	) RETURN NUMBER IS
	
		v_bdt_overude NUMBER := 0;
		v_bdt_account VARCHAR2(50) := NULL;
	
	BEGIN
		BEGIN
			v_bdt_account := get_bdt_acc_by_con(p_con);
		EXCEPTION
			WHEN OTHERS THEN
				v_bdt_account := NULL;
		END;
		IF v_bdt_account IS NOT NULL
		THEN
			v_bdt_overude := getoverdueamount(1, v_bdt_account, p_date);
		END IF;
		RETURN v_bdt_overude;
	END;
	FUNCTION getoverdueamount_usd
	(
		p_con  VARCHAR2
	   ,p_date DATE
	) RETURN NUMBER IS
		v_usd_overude NUMBER := 0;
		v_usd_account VARCHAR2(50) := NULL;
	BEGIN
		BEGIN
			v_usd_account := get_usd_acc_by_con(p_con);
		EXCEPTION
			WHEN OTHERS THEN
				v_usd_account := NULL;
		END;
		IF v_usd_account IS NOT NULL
		THEN
			v_usd_overude := getoverdueamount(1, v_usd_account, p_date);
		END IF;
		RETURN v_usd_overude;
	END;

	FUNCTION get_last_positive_bal_date(p_con VARCHAR2) RETURN DATE IS
		v_opdate DATE := NULL;
	BEGIN
		BEGIN
			WITH running_balance AS
			 (SELECT t.trantype
					,t.docno
					,t.amount
					,t.postdate
					,SUM(CASE
							 WHEN t.trantype IN (3, 4) THEN
							  t.amount
						 --over(ORDER BY t.postdate, t.docno rows BETWEEN unbounded preceding AND CURRENT ROW) --credit
							 WHEN t.trantype IN (1, 2) THEN
							  -t.amount
						 --debit
						 END) over(ORDER BY t.postdate DESC, t.docno DESC rows BETWEEN unbounded preceding AND CURRENT ROW) AS running_balance
			  FROM   tcontracttrxnlist t
			  WHERE  t.contractno = p_con)
			SELECT postdate
			INTO   v_opdate
			--,running_balance, trantype,docno,amount
			FROM   (SELECT trantype
						  ,docno
						  ,amount
						  ,postdate
						  ,running_balance
						  ,row_number() over(ORDER BY postdate DESC, docno DESC) AS rn
					FROM   running_balance
					WHERE  running_balance >= 0)
			WHERE  rn = 1;
		
		EXCEPTION
			WHEN OTHERS THEN
				v_opdate := NULL;
		END;
		RETURN v_opdate;
	
	END;

	FUNCTION check_brpd_eli_no_tran(p_con VARCHAR2) RETURN NUMBER IS
		v_flag NUMBER := 0;
		--0 = NOT ELIGIBLE, 1= ELIGIBLE
	BEGIN
		BEGIN
			SELECT 0
			INTO   v_flag
			FROM   dual
			WHERE  EXISTS (SELECT 0
					FROM   tcontracttrxnlist t
					WHERE  t.contractno = p_con
					AND    t.debitentcode IN (467
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
											 ,765
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
											 ,63
											 ,98
											 ,341
											 ,343
											 ,148));
		EXCEPTION
			WHEN no_data_found THEN
				v_flag := 1;
			WHEN OTHERS THEN
				v_flag := 0;
		END;
		IF v_flag = 0
		THEN
			BEGIN
				SELECT 1
				INTO   v_flag
				FROM   dual
				WHERE  EXISTS (SELECT 1
						FROM   tcontracttrxnlist t
						WHERE  t.contractno = p_con
						AND    t.postdate >= get_last_positive_bal_date(p_con)
						AND    t.debitentcode NOT IN (467
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
													 ,765
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
													 ,63
													 ,98
													 ,341
													 ,343
													 ,148));
			EXCEPTION
				WHEN OTHERS THEN
					v_flag := 0;
			END;
		END IF;
	
		RETURN v_flag;
	END;

	FUNCTION get_primary_pan_frm_account(p_acc VARCHAR2) RETURN VARCHAR2 IS
		v_pan VARCHAR2(25) := NULL;
	BEGIN
		BEGIN
			SELECT pan
			INTO   v_pan
			FROM   (SELECT c.*
					FROM   a4m.tacc2card t
					JOIN   a4m.tcard c
					ON     c.pan = t.pan
					AND    c.branch = t.branch
					AND    c.mbr = t.mbr
					WHERE  t.accountno = p_acc
					ORDER  BY c.createdate ASC)
			WHERE  rownum = 1;
		EXCEPTION
			WHEN OTHERS THEN
				v_pan := NULL;
		END;
		RETURN v_pan;
	END;

	FUNCTION get_latest_pan_frm_account(p_acc VARCHAR2) RETURN VARCHAR2 IS
		v_pan VARCHAR2(25) := NULL;
	BEGIN
		BEGIN
			SELECT pan
			INTO   v_pan
			FROM   (SELECT c.*
					FROM   a4m.tacc2card t
					JOIN   a4m.tcard c
					ON     c.pan = t.pan
					AND    c.branch = t.branch
					AND    c.mbr = t.mbr
					WHERE  t.accountno = p_acc
					ORDER  BY c.createdate DESC)
			WHERE  rownum = 1;
		EXCEPTION
			WHEN OTHERS THEN
				v_pan := NULL;
		END;
		RETURN v_pan;
	END;

	FUNCTION get_branch_code_by_doc
	(
		p_doc     NUMBER
	   ,p_entcode NUMBER
	) RETURN VARCHAR2 IS
		v_branch VARCHAR2(10) := NULL;
	BEGIN
		BEGIN
			SELECT CASE
					   WHEN c.name = 'CBLOMS2'
							OR c.name = 'CBLOMS3' THEN
						cr.branchpart
					   ELSE
						to_number(substr(d.station, 1, 3))
				   END branch_code
			INTO   v_branch
			FROM   a4m.tchequerequest cr
				  ,a4m.tchequebook    cb
				  ,a4m.tentry         e
				  ,a4m.tdocument      d
				  ,a4m.tclerk         c
			WHERE  cr.branch = 1
			AND    cr.status = 3
			AND    cb.branch = cr.branch
			AND    cb.no = cr.bookno
			AND    cb.branch = e.branch
			AND    cb.accountno = e.debitaccount
			AND    e.docno = p_doc
			AND    e.debitentcode = p_entcode
			AND    d.branch = e.branch
			AND    d.docno = e.docno
			AND    d.newdocno IS NULL
			AND    c.branch = d.branch
			AND    c.code = d.clerkcode
			AND    cr.serialno = (SELECT no
								  FROM   a4m.tcheque
								  WHERE  docno = p_doc
								  AND    branch = d.branch
								  AND    bookid = cb.id);
		EXCEPTION
			WHEN OTHERS THEN
				v_branch := NULL;
		END;
		RETURN v_branch;
	END;

	FUNCTION get_os_spec_date_acc(p_account_no VARCHAR2
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
		v_balance_bdt NUMBER := 0;
		v_balance_usd NUMBER := 0;
	
	BEGIN
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
				AND    a.creditaccount = p_account_no
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
				AND    a.debitaccount = p_account_no
				AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		
			v_balance_bdt := nvl(v_credit_value, 0) - nvl(v_debit_value, 0);
			v_balance_bdt := (v_balance_bdt);
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
		v_result := v_balance_bdt;
		RETURN v_result;
	END;

	FUNCTION get_debit_bal_acc(p_account_no VARCHAR2
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
		v_balance_bdt NUMBER := 0;
		v_balance_usd NUMBER := 0;
	
	BEGIN
		BEGIN
			BEGIN
				SELECT -sum(nvl(a.value, 0))
				INTO   v_debit_value
				FROM   tentry    a
					  ,tdocument b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				AND    a.debitaccount = p_account_no
				AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		
			v_balance_bdt := nvl(v_debit_value, 0);
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
		v_result := v_balance_bdt;
		RETURN v_result;
	END;

	FUNCTION get_credit_bal_acc(p_account_no VARCHAR2
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
		v_balance_bdt NUMBER := 0;
		v_balance_usd NUMBER := 0;
	
	BEGIN
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
				AND    a.creditaccount = p_account_no
				AND    (b.opdate <= p_to_date OR p_to_date IS NULL);
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		
			v_balance_bdt := nvl(v_credit_value, 0);
		EXCEPTION
			WHEN OTHERS THEN
				v_result := 0;
				RETURN v_result;
		END;
		v_result := v_balance_bdt;
		RETURN v_result;
	END;

END custom_account;
/
