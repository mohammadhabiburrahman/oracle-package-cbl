CREATE OR REPLACE PACKAGE custom_two AS
	FUNCTION get_ibas_actual_service_amt(p_id NUMBER) RETURN NUMBER;
	FUNCTION get_ibas_feesvat_amt(p_id NUMBER) RETURN NUMBER;

END custom_two;
/
CREATE OR REPLACE PACKAGE BODY custom_two AS

	FUNCTION get_ibas_actual_service_amt(p_id NUMBER) RETURN NUMBER IS
	
		v_actual_service_amt NUMBER := 0.00;
	BEGIN
		BEGIN
			SELECT substr(a.textmess
						 ,instr(a.textmess, '|', 1, 2) + 1
						 ,instr(a.textmess, '|', 1, 3) - instr(a.textmess, '|', 1, 2) - 1)
			INTO   v_actual_service_amt
			FROM   tla a
			WHERE  a.id = p_id;
		EXCEPTION
			WHEN OTHERS THEN
				v_actual_service_amt := 0.00;
		END;
		RETURN round(nvl(v_actual_service_amt, 0), 2);
	END;

	FUNCTION get_ibas_feesvat_amt(p_id NUMBER) RETURN NUMBER IS
	
		v_actual_service_amt NUMBER := 0.00;
		v_fourth_bar         NUMBER := 0;
	BEGIN
		BEGIN
			SELECT nvl(instr(a.textmess, '|', 1, 4), 0)
			INTO   v_fourth_bar
			FROM   tla a
			WHERE  a.id = p_id;
		EXCEPTION
			WHEN OTHERS THEN
				v_fourth_bar := 0;
		END;
		IF v_fourth_bar <> 0
		THEN
			BEGIN
				SELECT substr(a.textmess
							 ,instr(a.textmess, '|', 1, 3) + 1
							 ,instr(a.textmess, '|', 1, 4) - instr(a.textmess, '|', 1, 3) - 1)
				INTO   v_actual_service_amt
				FROM   tla a
				WHERE  a.id = p_id;
			EXCEPTION
				WHEN OTHERS THEN
					v_actual_service_amt := 0.00;
			END;
			RETURN round(nvl(v_actual_service_amt, 0), 2);
		ELSE
			BEGIN
				SELECT substr(a.textmess, instr(a.textmess, '|', 1, 3) + 1)
				INTO   v_actual_service_amt
				FROM   tla a
				WHERE  a.id = p_id;
			EXCEPTION
				WHEN OTHERS THEN
					v_actual_service_amt := 0.00;
			END;
			RETURN round(nvl(v_actual_service_amt, 0), 2);
		
		END IF;
	END;

END custom_two;
/
