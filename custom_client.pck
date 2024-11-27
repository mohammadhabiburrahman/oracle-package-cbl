CREATE OR REPLACE PACKAGE custom_client IS
	FUNCTION getclientattributebyparamid
	(
		vclientid NUMBER
	   ,vparamid  VARCHAR
	) RETURN CHAR;
END custom_client;
/
CREATE OR REPLACE PACKAGE BODY custom_client IS
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
