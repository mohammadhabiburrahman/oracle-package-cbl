CREATE OR REPLACE PACKAGE custom_client IS
	FUNCTION getclientattributebyparamid
	(
		vclientid NUMBER
	   ,vparamid  VARCHAR2
	) RETURN VARCHAR2;
	/*FUNCTION getclientattributebyparamid
    (
      vclientid NUMBER
       ,vparamid  VARCHAR
    ) RETURN CHAR;*/
	FUNCTION get_client_photo(p_client tclient.idclient%TYPE) RETURN BLOB;
	FUNCTION get_client_signature(p_client tclient.idclient%TYPE) RETURN BLOB;
	FUNCTION get_attr_desv(vparamid VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_name_by_clientid(p_idclient tclient.idclient%TYPE) RETURN VARCHAR2;
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
		p_enttype VARCHAR2
	   ,p_pan     VARCHAR2
	   ,p_device  VARCHAR2
	   ,p_docno   NUMBER
	) RETURN NUMBER;
END custom_client;
/
CREATE OR REPLACE PACKAGE BODY custom_client IS
	FUNCTION getclientattributebyparamid
	(
		vclientid NUMBER
	   ,vparamid  VARCHAR2
	) RETURN VARCHAR2 IS
		v_result VARCHAR2(200);
		--v_contract VARCHAR2(20);
	BEGIN
		BEGIN
			FOR i IN (SELECT --c.no
					   oapc.valuestr
					  ,oapc.valuenum
					  ,oapc.valuedate --,oapc.valuexml
					  ,oap.ptype
					  FROM   tobjadditionalproperty oap
					  JOIN   tobjaddpropdata_client oapc
					  ON     oapc.propid = oap.id
					  JOIN   tclient t
					  ON     t.objectuid = oapc.ownerid
					  WHERE  oap.extid = vparamid
					  AND    t.idclient = vclientid)
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

	FUNCTION get_client_photo(p_client tclient.idclient%TYPE) RETURN BLOB IS
		v_photo BLOB;
	BEGIN
		BEGIN
			SELECT t.data
			INTO   v_photo
			FROM   timagedata t
			JOIN   timagedoc d
			ON     d.id = t.imagedocid
			JOIN   tclient c
			ON     c.objectuid = d.ownerid
			
			WHERE  c.idclient = p_client
			AND    d.doctypeid = 2; ---Photo
		EXCEPTION
			WHEN OTHERS THEN
				v_photo := NULL;
		END;
		RETURN v_photo;
	END;

	FUNCTION get_client_signature(p_client tclient.idclient%TYPE) RETURN BLOB IS
		v_photo BLOB;
	BEGIN
		BEGIN
			SELECT t.data
			INTO   v_photo
			FROM   timagedata t
			JOIN   timagedoc d
			ON     d.id = t.imagedocid
			JOIN   tclient c
			ON     c.objectuid = d.ownerid
			
			WHERE  c.idclient = p_client
			AND    d.doctypeid = 3; ---Photo
		EXCEPTION
			WHEN OTHERS THEN
				v_photo := NULL;
		END;
		RETURN v_photo;
	END;

	FUNCTION get_attr_desv(vparamid VARCHAR2) RETURN VARCHAR2 IS
		v_result tobjadditionalproperty.description%TYPE;
	BEGIN
		BEGIN
			SELECT oap.description
			INTO   v_result
			FROM   tobjadditionalproperty oap
			WHERE  oap.extid = vparamid;
		EXCEPTION
			WHEN OTHERS THEN
				v_result := '';
		END;
		RETURN v_result;
	END;

	FUNCTION get_name_by_clientid(p_idclient tclient.idclient%TYPE) RETURN VARCHAR2 IS
		v_name tclientpersone.fio%TYPE := '';
	BEGIN
		BEGIN
			SELECT t.fio INTO v_name FROM tclientpersone t WHERE t.idclient = p_idclient;
		EXCEPTION
			WHEN OTHERS THEN
				v_name := 'Not Found';
		END;
		RETURN v_name;
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
			AND    o.trancode <> 111
			
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
				AND    o.trancode <> 111
				
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
		p_enttype VARCHAR2
	   ,p_pan     VARCHAR2
	   ,p_device  VARCHAR2
	   ,p_docno   NUMBER
	) RETURN NUMBER IS
		vtid VARCHAR2(40);
		vrrn NUMBER;
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

END custom_client;
/
