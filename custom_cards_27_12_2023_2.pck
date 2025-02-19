CREATE OR REPLACE PACKAGE custom_cards IS

	FUNCTION get_card_state_name(p_sign_stat NUMBER) RETURN VARCHAR2;

	FUNCTION get_limit_max_value
	(
		p_pan      VARCHAR2
	   ,p_limit_id NUMBER
	) RETURN VARCHAR2;

	FUNCTION get_period_type
	(
		p_pan      VARCHAR2
	   ,p_limit_id NUMBER
	) RETURN VARCHAR2;
	FUNCTION get_period
	(
		p_pan      VARCHAR2
	   ,p_limit_id NUMBER
	) RETURN VARCHAR2;

	FUNCTION get_card_stat_status
	(
		p_stat_id   VARCHAR2
	   ,p_event_typ NUMBER
	) RETURN VARCHAR2;

	FUNCTION get_ltst_prmry_crd_cntract(p_contract_no VARCHAR2
										
										) RETURN VARCHAR2;
	FUNCTION comma_to_table(p_list IN CLOB) RETURN t_my_list;
	FUNCTION mask(pan VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_ltst_crd_frm_card(p_card_no VARCHAR2) RETURN VARCHAR2;
	FUNCTION getcardtattributebyparamid
	(
		p_pan     VARCHAR2
	   ,p_paramid VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_card_type_frm_pan(p_pan VARCHAR2) RETURN VARCHAR2;
	FUNCTION getcardtattributebyparamiddesc
	(
		p_pan     VARCHAR2
	   ,p_paramid VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_prod_name_frm_pan(p_pan VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_prod_id_frm_pan(p_pan VARCHAR2) RETURN NUMBER;
	FUNCTION get_prod_name_frm_id(p_product_id NUMBER) RETURN VARCHAR2;
	FUNCTION get_rrn_by_doc_pan
	(
		p_doc NUMBER
	   ,p_pan VARCHAR2
	) RETURN NUMBER;
	FUNCTION getrrnfromtwobytid
	(
		vtid     CHAR
	   ,venttype CHAR
	   ,vpan     CHAR
	) RETURN NUMBER;
	FUNCTION getrrnbydocno(vdocno NUMBER) RETURN NUMBER;
	FUNCTION getstanbydocno(vdocno NUMBER) RETURN NUMBER;
	FUNCTION gettidbydocno
	(
		vdocno   NUMBER
	   ,p_device VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION get_rrn_by_doc_tid
	(
		p_tid     NUMBER
	   ,p_enttype VARCHAR2
	   ,p_pan     VARCHAR2
	   ,p_device  VARCHAR2
	   ,p_docno   NUMBER
	) RETURN NUMBER;
END custom_cards;
/
CREATE OR REPLACE PACKAGE BODY custom_cards IS
	FUNCTION get_card_state_name(p_sign_stat NUMBER) RETURN VARCHAR2 IS
		v_state_name VARCHAR2(500);
	BEGIN
		IF p_sign_stat IS NOT NULL
		THEN
			SELECT rcs.name
			INTO   v_state_name
			FROM   treferencecardsign rcs
			WHERE  rcs.cardsign = p_sign_stat;
			RETURN v_state_name;
		ELSE
			v_state_name := '';
			RETURN v_state_name;
		END IF;
	END;
	FUNCTION get_limit_max_value
	(
		p_pan      VARCHAR2
	   ,p_limit_id NUMBER
	) RETURN VARCHAR2 IS
		v_max_value VARCHAR2(100);
	BEGIN
		BEGIN
			SELECT t.maxvalue
			INTO   v_max_value
			FROM   tcardlimititem t
			WHERE  t.pan = p_pan
			AND    t.limitid = p_limit_id
			AND    t.branch = 1;
		EXCEPTION
			WHEN no_data_found THEN
				v_max_value := 'NDF';
		END;
	
		IF v_max_value IS NULL
		THEN
			v_max_value := 'NF';
		END IF;
		RETURN v_max_value;
	END;
	FUNCTION get_period_type
	(
		p_pan      VARCHAR2
	   ,p_limit_id NUMBER
	) RETURN VARCHAR2 IS
		v_period_type VARCHAR2(100);
	BEGIN
		BEGIN
			SELECT t.periodtype
			INTO   v_period_type
			FROM   tcardlimititem t
			WHERE  t.pan = p_pan
			AND    t.limitid = p_limit_id
			AND    t.branch = 1;
		EXCEPTION
			WHEN no_data_found THEN
				v_period_type := 'NDF';
		END;
	
		IF v_period_type IS NULL
		THEN
			v_period_type := 'NF';
		END IF;
		RETURN v_period_type;
	END;

	FUNCTION get_period
	(
		p_pan      VARCHAR2
	   ,p_limit_id NUMBER
	) RETURN VARCHAR2 IS
		v_period VARCHAR2(100);
	BEGIN
		BEGIN
			SELECT t.period
			INTO   v_period
			FROM   tcardlimititem t
			WHERE  t.pan = p_pan
			AND    t.limitid = p_limit_id
			AND    t.branch = 1;
		EXCEPTION
			WHEN no_data_found THEN
				v_period := 'NDF';
		END;
	
		IF v_period IS NULL
		THEN
			v_period := 'NF';
		END IF;
		RETURN v_period;
	END;

	FUNCTION get_card_stat_status
	(
		p_stat_id   VARCHAR2
	   ,p_event_typ NUMBER
	) RETURN VARCHAR2 IS
		v_result VARCHAR2(500) := NULL;
	BEGIN
	
		BEGIN
			IF p_event_typ = 5
			THEN
				SELECT t.name INTO v_result FROM treferencecrd_stat t WHERE t.crd_stat = p_stat_id;
			ELSIF p_event_typ = 6
			THEN
			
				SELECT t.name
				INTO   v_result
				FROM   treferencecardsign t
				WHERE  t.cardsign = to_number(p_stat_id);
			
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := NULL;
				RETURN v_result;
			
		END;
	
		RETURN v_result;
	END get_card_stat_status;
	/* Formatted on 11/13/2022 4:55:27 PM (QP5 v5.215.12089.38647) */
	FUNCTION get_ltst_prmry_crd_cntract(p_contract_no VARCHAR2
										--,p_client_id   VARCHAR2
										) RETURN VARCHAR2 IS
		v_card_no   VARCHAR2(20) := NULL;
		v_client_id VARCHAR2(20) := NULL;
	BEGIN
	
		BEGIN
			SELECT t.idclient INTO v_client_id FROM tcontract t WHERE t.no = p_contract_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_client_id := NULL;
		END;
	
		BEGIN
			SELECT pan
			INTO   v_card_no
			FROM   (SELECT c.pan
						  ,row_number() over(PARTITION BY a.no ORDER BY c.createdate DESC) seq
					FROM   a4m.tcontract         a
						  ,a4m.tcontractcarditem b
						  ,a4m.tcard             c
					WHERE  a.branch = 1
					AND    b.branch = a.branch
					AND    b.no = a.no
					AND    c.branch = b.branch
					AND    c.pan = b.pan
					AND    a.no = p_contract_no
					AND    c.idclient = v_client_id
					AND    c.pan NOT LIKE '78000%')
			WHERE  seq = 1;
		
			RETURN v_card_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_card_no := NULL;
				RETURN v_card_no;
		END;
	END;

	FUNCTION comma_to_table(p_list IN CLOB) RETURN t_my_list AS
		l_string      CLOB := p_list || ',';
		l_comma_index PLS_INTEGER;
		l_index       PLS_INTEGER := 1;
		l_tab         t_my_list := t_my_list();
	BEGIN
		LOOP
			l_comma_index := instr(l_string, ',', l_index);
			EXIT WHEN l_comma_index = 0;
			l_tab.extend;
			l_tab(l_tab.count) := TRIM(substr(l_string, l_index, l_comma_index - l_index));
			l_index := l_comma_index + 1;
		END LOOP;
		RETURN l_tab;
	END comma_to_table;

	FUNCTION mask(pan VARCHAR2) RETURN VARCHAR2 IS
	BEGIN
		IF pan LIKE '3%'
		THEN
			RETURN REPLACE(pan, substr(pan, 6, 6), '*****');
		
		ELSE
			RETURN REPLACE(pan, substr(pan, 6, 7), '*****');
		END IF;
	END;
	FUNCTION get_ltst_crd_frm_card(p_card_no VARCHAR2) RETURN VARCHAR2 IS
		v_card_no     VARCHAR2(20) := NULL;
		v_contract_no VARCHAR2(30) := NULL;
		v_client_id   VARCHAR2(20) := NULL;
		--v_card_product VARCHAR2(20) := NULL;
		v_acc_no VARCHAR2(20) := NULL;
	BEGIN
		BEGIN
			SELECT t.no INTO v_contract_no FROM tcontractcarditem t WHERE t.pan = p_card_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_contract_no := NULL;
		END;
	
		/*BEGIN
            SELECT t.cardproduct INTO v_card_product FROM tcard t WHERE t.pan = p_card_no;
        EXCEPTION
            WHEN OTHERS THEN
                v_card_product := NULL;
        END;*/
	
		BEGIN
			IF v_contract_no IS NOT NULL
			THEN
				SELECT t.idclient INTO v_client_id FROM tcard t WHERE t.pan = p_card_no;
			
				SELECT pan
				INTO   v_card_no
				FROM   (SELECT c.pan
							  ,row_number() over(PARTITION BY a.no ORDER BY c.createdate DESC) seq
						FROM   a4m.tcontract         a
							  ,a4m.tcontractcarditem b
							  ,a4m.tcard             c
						WHERE  a.branch = 1
						AND    b.branch = a.branch
						AND    b.no = a.no
						AND    c.branch = b.branch
						AND    c.pan = b.pan
						AND    a.no = v_contract_no
							  --AND    c.cardproduct = v_card_product
						AND    c.idclient = v_client_id
						--AND    c.pan NOT LIKE '78000%'
						)
				WHERE  seq = 1;
				RETURN v_card_no;
			ELSE
			
				/*              BEGIN
                    SELECT t.cardproduct INTO v_card_product FROM tcard t WHERE t.pan = p_card_no;
                EXCEPTION
                    WHEN OTHERS THEN
                        v_card_product := NULL;
                END;*/
				BEGIN
					SELECT t.accountno INTO v_acc_no FROM tacc2card t WHERE t.pan = p_card_no;
				
					SELECT seq.pan
					INTO   v_card_no
					FROM   (SELECT c.*
							FROM   tacc2card t
							JOIN   tcard c
							ON     c.pan = t.pan
							AND    c.branch = t.branch
							WHERE  t.accountno = v_acc_no
							--AND    c.cardproduct = v_card_product
							ORDER  BY c.createdate DESC) seq
					WHERE  rownum = 1;
				EXCEPTION
					WHEN OTHERS THEN
						v_card_no := NULL;
				END;
			END IF;
			RETURN v_card_no;
		EXCEPTION
			WHEN OTHERS THEN
				v_card_no := NULL;
				RETURN v_card_no;
		END;
	END;

	FUNCTION getcardtattributebyparamid
	(
		p_pan     VARCHAR2
	   ,p_paramid VARCHAR2
	) RETURN VARCHAR2 IS
		v_result VARCHAR2(200);
		--v_contract VARCHAR2(20);
	BEGIN
	
		BEGIN
			FOR i IN (SELECT oap.extid
							,t.pan
							,oapc.valuenum
							,oap.ptype
							,oapc.valuestr
							,oapc.valuedate
					  
					  FROM   tobjadditionalproperty oap
					  
					  JOIN   tobjaddpropdata_card oapc
					  ON     oapc.propid = oap.id
					  
					  JOIN   tcard t
					  ON     t.objectuid = oapc.ownerid
					  
					  WHERE  oap.extid = p_paramid
					  AND    t.pan = p_pan)
			LOOP
				--v_contract := i.no;
				IF lower(i.ptype) = 'date'
				THEN
				
					v_result := i.valuedate;
				ELSIF lower(i.ptype) = 'str'
				THEN
					v_result := i.valuestr;
				ELSIF lower(i.ptype) = 'num'
				THEN
					v_result := i.valuenum;
				ELSE
					v_result := ' ';
				END IF;
				IF v_result IS NOT NULL
				THEN
					RETURN v_result;
					/*ELSE
                    v_result := ' ';
                    RETURN v_result;*/
				END IF;
			END LOOP;
			IF v_result IS NULL
			THEN
				v_result := ' ';
				RETURN v_result;
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := ' ';
				RETURN v_result;
		END;
	
	END;

	FUNCTION get_card_type_frm_pan(p_pan VARCHAR2) RETURN VARCHAR2 IS
	
		master_card BOOLEAN;
		visa_card   BOOLEAN;
		--visa_card_1   BOOLEAN;
		amex_card     BOOLEAN;
		diners_card   BOOLEAN;
		discover_card BOOLEAN;
		jcb_card      BOOLEAN;
	
		priority_pass BOOLEAN;
		cup_card      BOOLEAN;
	
		--Regex regVisa = new Regex("^4[0-9]{12}(?:[0-9]{3})?$");
		--Regex regMaster = new Regex("^5[1-5][0-9]{14}$");
		--Regex regExpress = new Regex("^3[47][0-9]{13}$");
		--Regex regDiners = new Regex("^3(?:0[0-5]|[68][0-9])[0-9]{11}$");
		---Regex regDiscover = new Regex("^6(?:011|5[0-9]{2})[0-9]{12}$");
		--Regex regJCB = new Regex("^(?:2131|1800|35\\d{3})\\d{11}$");
	
	BEGIN
		BEGIN
			master_card   := regexp_like(p_pan, ('^5[1-5][0-9]{14}$'));
			visa_card     := regexp_like(p_pan, ('^4[0-9][0-9]{14}$'));
			amex_card     := regexp_like(p_pan, ('^3[47][0-9]{13}$'));
			diners_card   := regexp_like(p_pan, ('^3(?:0[0-5]|[68][0-9])[0-9]{11}$'));
			discover_card := regexp_like(p_pan, ('^6(?:011|5[0-9]{2})[0-9]{12}$'));
			jcb_card      := regexp_like(p_pan, ('^(?:2131|1800|35\\d{3})\\d{11}$'));
		
			--visa_card_1   := regexp_like(p_pan, ('^4[0-9]{12}(?:[0-9]{3})?$'));
			priority_pass := regexp_like(p_pan, ('^7[800]'));
			cup_card      := regexp_like(p_pan, ('^6[2][9]'));
		
		EXCEPTION
			WHEN OTHERS THEN
				RETURN 'ERROR IN REGEX';
		END;
		BEGIN
			IF master_card = TRUE
			THEN
				RETURN 'MASTER CARD';
			ELSIF visa_card = TRUE
			THEN
				RETURN 'VISA CARD';
				/*ELSIF visa_card_1 = TRUE
                THEN
                    RETURN 'VISA CARD 1';*/
			ELSIF amex_card = TRUE
			THEN
				RETURN 'AMEX CARD';
			ELSIF diners_card = TRUE
			THEN
				RETURN 'DINERS CARD';
			ELSIF discover_card = TRUE
			THEN
				RETURN 'DISCOVER CARD';
			ELSIF jcb_card = TRUE
			THEN
				RETURN 'JCB CARD';
			
				/*          ELSIF priority_pass = TRUE
                THEN
                    RETURN 'PRIORITY PASS CARD';*/
			ELSIF cup_card = TRUE
			THEN
				RETURN 'CUP CARD';
			ELSE
				RETURN 'OTHER CARD';
			END IF;
		
		EXCEPTION
			WHEN OTHERS THEN
				RETURN 'OTHER CARD';
		END;
	END;

	FUNCTION getcardtattributebyparamiddesc
	(
		p_pan     VARCHAR2
	   ,p_paramid VARCHAR2
	) RETURN VARCHAR2 IS
		v_result VARCHAR2(200);
		--v_contract VARCHAR2(20);
	BEGIN
	
		BEGIN
			FOR i IN (SELECT refe.valuestr
							,refe.description
							,t.pan
							,oapc.valuenum
							,oap.ptype
							,oapc.valuedate
					  
					  FROM   tobjadditionalproperty oap
					  
					  JOIN   tobjaddpropdata_card oapc
					  ON     oapc.propid = oap.id
					  
					  JOIN   tcard t
					  ON     t.objectuid = oapc.ownerid
					  
					  JOIN   tobjaddpropreference refe
					  ON     refe.valuestr = oapc.valuestr
					  AND    refe.propid = oap.id
					  
					  WHERE  oap.extid = p_paramid
					  AND    t.pan = p_pan)
			LOOP
				--v_contract := i.no;
				IF lower(i.ptype) = 'str'
				THEN
					v_result := i.description;
				ELSIF lower(i.ptype) = 'num'
				THEN
					v_result := i.valuenum;
				ELSE
					v_result := ' ';
				END IF;
				IF v_result IS NOT NULL
				THEN
					RETURN v_result;
				END IF;
			END LOOP;
			IF v_result IS NULL
			THEN
				v_result := ' ';
				RETURN v_result;
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := ' ';
				RETURN v_result;
		END;
	
	END;
	FUNCTION get_prod_name_frm_pan(p_pan VARCHAR2) RETURN VARCHAR2 IS
		v_prod_name VARCHAR2(200) := '';
	BEGIN
		BEGIN
			SELECT p.name product_name
			INTO   v_prod_name
			FROM   tcard c
			JOIN   treferencecardproduct p
			ON     p.code = c.cardproduct
			AND    p.branch = c.branch
			WHERE  c.pan = p_pan;
		EXCEPTION
			WHEN OTHERS THEN
				v_prod_name := '';
			
		END;
		RETURN v_prod_name;
	
	END;

	FUNCTION get_prod_id_frm_pan(p_pan VARCHAR2) RETURN NUMBER IS
		v_prod_id NUMBER := '';
	BEGIN
		BEGIN
			SELECT p.code product_name
			INTO   v_prod_id
			FROM   tcard c
			JOIN   treferencecardproduct p
			ON     p.code = c.cardproduct
			AND    p.branch = c.branch
			WHERE  c.pan = p_pan;
		EXCEPTION
			WHEN OTHERS THEN
				v_prod_id := '';
			
		END;
		RETURN v_prod_id;
	
	END;

	FUNCTION get_prod_name_frm_id(p_product_id NUMBER) RETURN VARCHAR2 IS
		v_prod_name VARCHAR2(200) := '';
	BEGIN
		BEGIN
			SELECT p.name product_name
			INTO   v_prod_name
			FROM   treferencecardproduct p
			WHERE  p.code = p_product_id;
		EXCEPTION
			WHEN OTHERS THEN
				v_prod_name := '';
			
		END;
		RETURN v_prod_name;
	
	END;

	FUNCTION get_rrn_by_doc_pan
	(
		p_doc NUMBER
	   ,p_pan VARCHAR2
	) RETURN NUMBER
	
	 IS
		v_rrn NUMBER := NULL;
	BEGIN
	
		BEGIN
			SELECT o.id
			INTO   v_rrn
			FROM   a4m.textwitran t
			JOIN   a4m.textract e
			ON     to_char(t.code) = to_char(e.trancode)
			AND    t.pan = e.pan
			
			LEFT   JOIN a4m.textractdelay d
			ON     to_char(t.code) = to_char(d.trancode)
			AND    t.pan = d.pan
			
			JOIN   a4m.tcard c
			ON     c.pan = t.pan
			AND    c.branch = t.branch
			
			JOIN   a4m.tatmext p
			ON     p.docno = e.docno
			AND    p.branch = e.branch
			
			JOIN   tla@cms2two o
			ON     o.pan = c.pan
			AND    o.approvalcode = p.approval
			
			JOIN   a4m.tatmext a
			ON     a.docno = e.docno
			AND    a.branch = e.branch
			
			WHERE  t.pan = p_pan
			AND    p.docno = p_doc;
		
		EXCEPTION
			WHEN OTHERS THEN
				v_rrn := NULL;
		END;
		IF v_rrn IS NULL
		THEN
			BEGIN
				SELECT o.id
				INTO   v_rrn
				FROM   a4m.textwitran t
				JOIN   a4m.textract e
				ON     to_char(t.code) = to_char(e.trancode)
				AND    t.pan = e.pan
				
				LEFT   JOIN a4m.textractdelay d
				ON     to_char(t.code) = to_char(d.trancode)
				AND    t.pan = d.pan
				
				JOIN   a4m.tcard c
				ON     c.pan = t.pan
				AND    c.branch = t.branch
				
				JOIN   a4m.tatmext p
				ON     p.docno = e.docno
				AND    p.branch = e.branch
				
				JOIN   tla@cms2two o
				ON     o.pan = c.pan
				AND    o.approvalcode = p.approval
				
				JOIN   a4m.tposcheque a
				ON     a.docno = e.docno
				AND    a.branch = e.branch
				
				WHERE  t.pan = p_pan
				AND    p.docno = p_doc;
			EXCEPTION
				WHEN OTHERS THEN
					v_rrn := NULL;
			END;
		END IF;
		RETURN v_rrn;
	END;

	FUNCTION getrrnfromtwobytid
	(
		vtid     CHAR
	   ,venttype CHAR
	   ,vpan     CHAR
	) RETURN NUMBER IS
		vrrn NUMBER := NULL;
	BEGIN
		IF vtid IS NOT NULL
		THEN
		
			BEGIN
				IF venttype <> 'R'
				THEN
					IF vpan LIKE '3%'
					THEN
						SELECT extrrn
						INTO   vrrn
						FROM   tla@cms2two
						WHERE  TYPE = 100
						AND    substr(incpsfields, instr(incpsfields, 'AMEX31') + 7, 15) = vtid
						AND    trancode <> 111
						AND    pan = vpan;
					ELSIF vpan LIKE '4%'
					THEN
						SELECT extrrn
						INTO   vrrn
						FROM   tla@cms2two
						WHERE  TYPE = 100
						AND    substr(incpsfields, instr(incpsfields, 'VISAF62_2') + 10, 15) = vtid
						AND    trancode <> 111
						AND    pan = vpan;
					END IF;
				ELSE
					IF vpan LIKE '3%'
					THEN
						SELECT extrrn
						INTO   vrrn
						FROM   tla@cms2two
						WHERE  TYPE = 420
						AND    substr(incpsfields, instr(incpsfields, 'AMEX31') + 7, 15) = vtid
						AND    trancode <> 111
						AND    pan = vpan;
					ELSIF vpan LIKE '4%'
					THEN
						SELECT extrrn
						INTO   vrrn
						FROM   tla@cms2two
						WHERE  TYPE = 420
						AND    substr(incpsfields, instr(incpsfields, 'VISAF62_2') + 10, 15) = vtid
						AND    trancode <> 111
						AND    pan = vpan;
					END IF;
				END IF;
			EXCEPTION
				WHEN no_data_found THEN
					vrrn := NULL;
			END;
		END IF;
	
		RETURN vrrn;
	END;

	FUNCTION getrrnbydocno(vdocno NUMBER) RETURN NUMBER IS
		vrrn NUMBER := NULL;
	BEGIN
		IF vdocno IS NOT NULL
		THEN
			BEGIN
				SELECT extrrn
				INTO   vrrn
				FROM   a4m.ttlg
				WHERE  branch = 1
				AND    code = (SELECT trancode
							   FROM   a4m.textractdelay
							   WHERE  branch = 1
							   AND    docno = vdocno
							   AND    rownum = 1);
			EXCEPTION
				WHEN no_data_found THEN
					vrrn := NULL;
			END;
		END IF;
	
		RETURN vrrn;
	END;

	FUNCTION getstanbydocno(vdocno NUMBER) RETURN NUMBER IS
		vstan NUMBER;
	BEGIN
		IF vdocno IS NOT NULL
		THEN
			BEGIN
				SELECT stan2
				INTO   vstan
				FROM   a4m.textractdelay
				WHERE  branch = 1
				AND    docno = vdocno
				AND    rownum = 1;
			EXCEPTION
				WHEN no_data_found THEN
					vstan := 0;
			END;
		END IF;
	
		RETURN vstan;
	END;

	FUNCTION gettidbydocno
	(
		vdocno   NUMBER
	   ,p_device VARCHAR2
	) RETURN VARCHAR2 IS
		vtid VARCHAR2(40);
	BEGIN
		IF vdocno IS NOT NULL
		THEN
			BEGIN
				IF p_device = 'P'
				THEN
				
					SELECT tid
					INTO   vtid
					FROM   a4m.textwitran
					WHERE  code = (SELECT trancode FROM a4m.tposcheque WHERE docno = vdocno);
				ELSIF p_device = 'A'
				THEN
					SELECT tid
					INTO   vtid
					FROM   a4m.textwitran
					WHERE  code = (SELECT trancode FROM a4m.tatmext WHERE docno = vdocno);
				END IF;
			EXCEPTION
				WHEN no_data_found THEN
					vtid := NULL;
			END;
		END IF;
	
		RETURN vtid;
	END;

	FUNCTION get_rrn_by_doc_tid
	(
		p_tid     NUMBER
	   ,p_enttype VARCHAR2
	   ,p_pan     VARCHAR2
	   ,p_device  VARCHAR2
	   ,p_docno   NUMBER
	) RETURN NUMBER IS
		v_rrn NUMBER := NULL;
		vtid  VARCHAR2(40);
		vrrn  NUMBER;
	BEGIN
	
		vtid := gettidbydocno(p_docno, p_device);
	
		IF vtid IS NOT NULL
		THEN
			vrrn := getrrnfromtwobytid(vtid, p_enttype, p_pan);
			IF vrrn IS NULL
			THEN
				vrrn := getrrnbydocno(p_docno);
				IF vrrn IS NULL
				THEN
					vrrn := getstanbydocno(p_docno);
				END IF;
			END IF;
		END IF;
		RETURN vrrn;
	END;

END custom_cards;
/
