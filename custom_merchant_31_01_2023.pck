CREATE OR REPLACE PACKAGE custom_merchant AS
	FUNCTION get_rid_by_pan(p_pan VARCHAR2) RETURN VARCHAR2;
END custom_merchant;
/
CREATE OR REPLACE PACKAGE BODY custom_merchant AS
	FUNCTION get_rid_by_pan(p_pan VARCHAR2) RETURN VARCHAR2 IS
		retailerid VARCHAR2(25) := '';
	BEGIN
		IF p_pan IS NOT NULL
		THEN
			SELECT rr.ident
			INTO   retailerid
			FROM   a4m.tcard              c
				  ,a4m.tidentity          i
				  ,a4m.treferenceretailer rr
			WHERE  c.branch = 1
			AND    c.pan = p_pan
			AND    c.branch = i.branch
			AND    c.idclient = i.idclient
			AND    i.branch = rr.branch
			AND    i.no = rr.ident;
		ELSE
			retailerid := '';
			--RETURN RetailerID;
		END IF;
		RETURN retailerid;
	END;

END custom_merchant;
/
