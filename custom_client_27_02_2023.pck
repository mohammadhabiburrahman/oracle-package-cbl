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
END custom_client;
/
