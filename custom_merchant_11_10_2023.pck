CREATE OR REPLACE PACKAGE custom_merchant AS
	FUNCTION get_rid_by_pan(p_pan VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_bangla_qr_by_retailer(p_retailer VARCHAR2) RETURN VARCHAR2;
	FUNCTION get_terminal_by_retlr(p_retailer_id IN VARCHAR2) RETURN VARCHAR2;
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

	FUNCTION get_bangla_qr_by_retailer(p_retailer VARCHAR2) RETURN VARCHAR2 IS
		v_yes_no VARCHAR2(3) := 'NO';
	BEGIN
		BEGIN
			SELECT 'YES'
			INTO   v_yes_no
			FROM   treferenceretailer t
			JOIN   tretailerextpsname n
			ON     t.code = n.retailercode
			AND    t.branch = n.branch
			
			JOIN   ttwirefnetwork nt
			ON     nt.id = n.networkid
			
			WHERE  n.networkid = 46
			AND    t.ident = p_retailer
			AND    t.ident LIKE ('8%');
		EXCEPTION
			WHEN OTHERS THEN
				v_yes_no := 'NO';
		END;
		RETURN v_yes_no;
	END;

	FUNCTION get_terminal_by_retlr(p_retailer_id IN VARCHAR2) RETURN VARCHAR2 IS
		v_terminalident VARCHAR2(50) := NULL;
	BEGIN
		IF p_retailer_id IS NOT NULL
		THEN
		
			BEGIN
			
				SELECT b.ident
				INTO   v_terminalident
				FROM   a4m.treferenceretailer a
					  ,a4m.treferenceterminal b
				WHERE  a.branch = 1
				AND    b.branch = a.branch
				AND    b.retailercode = a.code
				AND    a.ident LIKE ('8%')
				AND    a.ident = p_retailer_id;
			
			EXCEPTION
				WHEN no_data_found THEN
					v_terminalident := NULL;
			END;
		
		END IF;
	
		RETURN v_terminalident;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN('Execution error:' || SQLERRM);
	END;

END custom_merchant;
/
