CREATE OR REPLACE PACKAGE custom_rewards IS
	/*
    Author : Mohammad Habibur Rahman
    Date   : 01-DEC-2025
    Purpose: For storing rewards program related functions and procedure
    */

	FUNCTION get_10x_check(p_date DATE) RETURN NUMBER;

END custom_rewards;
/
CREATE OR REPLACE PACKAGE BODY custom_rewards IS

	FUNCTION get_10x_check(p_date DATE) RETURN NUMBER IS
		v_count NUMBER := 0;
	BEGIN
		BEGIN
			SELECT COUNT(*)
			INTO   v_count
			FROM   custom_bonus_calender t
			WHERE  t.bonus_type = '10X'
			AND    t.bonus_date = p_date;
		EXCEPTION
			WHEN OTHERS THEN
				v_count := 0;
		END;
		IF v_count > 0
		THEN
			v_count := 1;
		ELSE
			v_count := 0;
		END IF;
		RETURN v_count;
	END;
END custom_rewards;
/
