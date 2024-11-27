CREATE OR REPLACE PACKAGE custom_client IS
	FUNCTION getclientattribute_new
	(
		vclientid NUMBER
	   ,vparamid  VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION getclientattributebyparamid
	(
		vclientid NUMBER
	   ,vparamid  VARCHAR
	) RETURN CHAR;
END custom_client;
/
CREATE OR REPLACE PACKAGE BODY custom_client IS
	FUNCTION getclientattribute_new
	(
		vclientid NUMBER
	   ,vparamid  VARCHAR2
	) RETURN VARCHAR2 IS
		---vrec   apitypes.typeuserproprecord;
		--vvalue VARCHAR(200);
		--vlist  apitypes.typeuserproplist;
		v_result   VARCHAR2(200) := ' ';
		v_contract VARCHAR2(20);
		--v_count    NUMBER := 0;
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
				  AND    t.idclient = vclientid) --p_client_id
		LOOP
			v_contract := i.no;
			v_result   := i.valuestr;
			IF v_result IS NOT NULL
			THEN
				RETURN v_result;
			ELSE
				RETURN v_result;
			END IF;
		END LOOP;
		/*IF v_result IS NULL
        THEN
            v_result := ' ';
            RETURN v_result;
        END IF;*/
	
	END;

	FUNCTION getclientattributebyparamid
	(
		vclientid NUMBER
	   ,vparamid  VARCHAR
	) RETURN CHAR IS
		vrec   apitypes.typeuserproprecord;
		vvalue VARCHAR(100);
	BEGIN
		vrec := client.getuserattributerecord(vclientid, vparamid);
	
		IF vrec.ptype = objuserproperty.pt_string
		THEN
			vvalue := vrec.valuestr;
		ELSIF vrec.ptype = objuserproperty.pt_number
		THEN
			vvalue := vrec.valuenum;
		ELSIF vrec.ptype = objuserproperty.pt_date
		THEN
			vvalue := vrec.valuedate;
		
		END IF;
	
		RETURN vvalue;
	
	EXCEPTION
		WHEN OTHERS THEN
			RETURN ' ';
	END;
END custom_client;
/
