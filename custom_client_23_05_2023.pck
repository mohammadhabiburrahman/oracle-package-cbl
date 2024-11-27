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
END custom_client;
/
