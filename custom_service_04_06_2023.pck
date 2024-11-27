CREATE OR REPLACE PACKAGE custom_service AS

	chversion CONSTANT VARCHAR(100) := '$Rev: 45204 $';
	lang_rus  CONSTANT NUMBER := 1;
	lang_ukr  CONSTANT NUMBER := 2;
	lang_eng  CONSTANT NUMBER := 3;

	FUNCTION existproc
	(
		ppackagename   IN VARCHAR
	   ,pprocname      IN VARCHAR
	   ,pformat        IN VARCHAR
	   ,psetreason2err BOOLEAN := FALSE
	) RETURN BOOLEAN;
	FUNCTION iif
	(
		pcondition IN BOOLEAN
	   ,pthen      IN DATE
	   ,pelse      IN DATE
	) RETURN DATE;
	FUNCTION iif
	(
		pcondition IN BOOLEAN
	   ,pthen      IN NUMBER
	   ,pelse      IN NUMBER
	) RETURN NUMBER;
	FUNCTION iif
	(
		pcondition IN BOOLEAN
	   ,pthen      IN VARCHAR
	   ,pelse      IN VARCHAR
	) RETURN VARCHAR;

	FUNCTION isoraclereservedword(pname VARCHAR) RETURN BOOLEAN;

	FUNCTION isoracleusedname(pname VARCHAR) RETURN BOOLEAN;

	FUNCTION isavaiblerecordfield(pname VARCHAR) RETURN BOOLEAN;

	FUNCTION str2guid(pstr VARCHAR) RETURN types.guid;
	FUNCTION guid2str(pguid types.guid) RETURN VARCHAR;

	FUNCTION dialogconfirm
	(
		ptitle    IN VARCHAR
	   ,pmessage  IN VARCHAR
	   ,pbutton1  IN VARCHAR
	   ,phint1    IN VARCHAR
	   ,pbutton2  IN VARCHAR
	   ,phint2    IN VARCHAR
	   ,pdlgextid VARCHAR := NULL
	) RETURN NUMBER;
	FUNCTION dialogconfirm3
	(
		ptitle    IN VARCHAR
	   ,pmessage  IN VARCHAR
	   ,pbutton1  IN VARCHAR
	   ,phint1    IN VARCHAR
	   ,pbutton2  IN VARCHAR
	   ,phint2    IN VARCHAR
	   ,pbutton3  IN VARCHAR
	   ,phint3    IN VARCHAR
	   ,pdlgextid VARCHAR := NULL
	) RETURN NUMBER;
	FUNCTION errordialog(ptitle IN VARCHAR) RETURN NUMBER;
	FUNCTION messagedialog
	(
		ptitle          VARCHAR
	   ,pmessage        VARCHAR
	   ,pdetail         VARCHAR := ''
	   ,pdetailshow     BOOLEAN := FALSE
	   ,pdlgextid       VARCHAR := NULL
	   ,pactionbtntitle VARCHAR := NULL
	   ,pactionbtnhint  VARCHAR := NULL
	   ,pactionscript   VARCHAR := NULL
	) RETURN NUMBER;
	PROCEDURE saymsg
	(
		piddialog IN NUMBER
	   ,ptitle    IN VARCHAR
	   ,pmessage  IN VARCHAR
	);
	PROCEDURE sayerr
	(
		piddialog IN NUMBER
	   ,ptitle    IN VARCHAR
	);
	FUNCTION dialogfromto
	(
		phandler IN VARCHAR
	   ,ptitle   IN VARCHAR
	   ,pmessage IN VARCHAR := NULL
	) RETURN NUMBER;
	FUNCTION getfromto
	(
		ptitle   IN VARCHAR
	   ,pfrom    IN OUT NUMBER
	   ,pto      IN OUT NUMBER
	   ,phandler IN VARCHAR := NULL
	   ,pmessage IN VARCHAR := NULL
	   ,pmin     IN NUMBER := NULL
	   ,pmax     IN NUMBER := NULL
	) RETURN BOOLEAN;

	PROCEDURE dialogfromtohandler
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN CHAR
	   ,pcmd    IN NUMBER
	);

	FUNCTION getdayname(pdate IN DATE) RETURN VARCHAR;
	FUNCTION getmonthname(pdate IN DATE) RETURN VARCHAR;

	FUNCTION cpad
	(
		pstr      IN CHAR
	   ,plen      IN NUMBER
	   ,pfillchar IN CHAR
	) RETURN CHAR;
	FUNCTION upperr(pstring IN VARCHAR) RETURN VARCHAR;

	FUNCTION clsbit
	(
		pstr IN VARCHAR
	   ,pbit IN VARCHAR
	) RETURN VARCHAR;
	FUNCTION getbit
	(
		pstr IN VARCHAR
	   ,pbit IN CHAR
	) RETURN NUMBER;
	FUNCTION setbit
	(
		pstr IN VARCHAR
	   ,pbit IN VARCHAR
	) RETURN VARCHAR;

	FUNCTION strpbrk
	(
		pstr1 IN CHAR
	   ,pstr2 IN CHAR
	) RETURN NUMBER;

	FUNCTION leftpad
	(
		pstring IN VARCHAR
	   ,plength IN NUMBER
	   ,pchar   IN VARCHAR := ' '
	) RETURN VARCHAR;
	FUNCTION rightpad
	(
		pstring IN VARCHAR
	   ,plength IN NUMBER
	   ,pchar   IN VARCHAR := ' '
	) RETURN VARCHAR;

	FUNCTION getchar
	(
		pstr   IN VARCHAR
	   ,pindex IN NUMBER
	) RETURN VARCHAR;
	FUNCTION setchar
	(
		pstr   IN VARCHAR
	   ,pindex IN NUMBER
	   ,pvalue IN VARCHAR
	) RETURN VARCHAR;

	FUNCTION TRIM(pparam IN VARCHAR) RETURN VARCHAR;
	FUNCTION splitstring
	(
		pstring   VARCHAR
	   ,padelimit types.arrchar
	   ,plength   NUMBER := 0
	   ,pdelfirst BOOLEAN := TRUE
	) RETURN types.arrstr250;
	FUNCTION replacestring
	(
		pstring         IN VARCHAR2
	   ,psearchstr      IN VARCHAR2
	   ,preplacementstr IN VARCHAR2 := NULL
	) RETURN VARCHAR2;

	FUNCTION numtohex(pnum IN NUMBER) RETURN VARCHAR;
	FUNCTION hextonum(phex IN VARCHAR) RETURN NUMBER;

	FUNCTION hextobin(phex IN VARCHAR) RETURN VARCHAR;
	FUNCTION bintohex(pbin IN VARCHAR) RETURN VARCHAR;

	FUNCTION numtobin(pnum IN NUMBER) RETURN VARCHAR;

	FUNCTION hextobch(phex IN VARCHAR) RETURN VARCHAR;
	FUNCTION bchtonum(praw VARCHAR) RETURN NUMBER;
	FUNCTION numtomoney
	(
		pnum       IN NUMBER
	   ,pprecision IN NUMBER
	   ,pwidth     IN NUMBER DEFAULT 13
	) RETURN VARCHAR2;

	FUNCTION convertnumber
	(
		pnumber IN NUMBER
	   ,psex    IN CHAR
	   ,plang   IN NUMBER := lang_rus
	) RETURN VARCHAR;
	FUNCTION convertdate
	(
		pdate IN DATE
	   ,plang IN NUMBER := lang_rus
	) RETURN VARCHAR;
	FUNCTION to_date_null
	(
		pdate   IN VARCHAR
	   ,pformat IN VARCHAR
	) RETURN DATE;
	PRAGMA RESTRICT_REFERENCES(to_date_null, WNDS, WNPS, RNDS, RNPS);

	FUNCTION getlicensesignature(pdata CLOB) RETURN CLOB;

	FUNCTION formatpackageversion
	(
		ppackagename     VARCHAR
	   ,pspecsvnrevision VARCHAR
	   ,pbodysvnrevision VARCHAR
	) RETURN VARCHAR;

	PROCEDURE startthread
	(
		psql        VARCHAR
	   ,pparamcount NUMBER := 0
	   ,pparam1     VARCHAR := NULL
	   ,pparam2     VARCHAR := NULL
	   ,pparam3     VARCHAR := NULL
	   ,prunaschild BOOLEAN := TRUE
	);

	PROCEDURE sys_startthread(pparams VARCHAR);

	PROCEDURE inc
	(
		pparam   IN OUT NUMBER
	   ,pbyvalue IN NUMBER := 1
	);
	PROCEDURE DEC
	(
		pparam   IN OUT NUMBER
	   ,pbyvalue IN NUMBER := 1
	);
	FUNCTION getnextsequencevalue(psequencename VARCHAR) RETURN NUMBER;

	SUBTYPE typectype IS VARCHAR(2);
	ccempty                       CONSTANT typectype := 'E';
	ccvarchar2                    CONSTANT typectype := 'V';
	ccnumber                      CONSTANT typectype := 'N';
	ccnativeinteger               CONSTANT typectype := 'I';
	cclong                        CONSTANT typectype := 'L';
	ccrowid                       CONSTANT typectype := 'W';
	ccdate                        CONSTANT typectype := 'D';
	ccraw                         CONSTANT typectype := 'R';
	cclongraw                     CONSTANT typectype := 'LR';
	ccopaque_type                 CONSTANT typectype := 'Y';
	ccchar                        CONSTANT typectype := 'C';
	ccbinary_float                CONSTANT typectype := 'BF';
	ccbinary_double               CONSTANT typectype := 'BD';
	ccurowid                      CONSTANT typectype := 'UW';
	ccmlslabel                    CONSTANT typectype := 'ML';
	ccclob                        CONSTANT typectype := 'CL';
	ccblob                        CONSTANT typectype := 'BL';
	ccbfile                       CONSTANT typectype := 'FL';
	ccobject                      CONSTANT typectype := 'O';
	ccnested_table                CONSTANT typectype := 'NT';
	ccvarray                      CONSTANT typectype := 'VA';
	ccplsql_record                CONSTANT typectype := 'S';
	ccplsql_table                 CONSTANT typectype := 'A';
	ccplsql_boolean               CONSTANT typectype := 'B';
	cctime                        CONSTANT typectype := 'M';
	cctime_withtimezone           CONSTANT typectype := 'MZ';
	cctimestamp                   CONSTANT typectype := 'T';
	cctimestamp_withtimezone      CONSTANT typectype := 'TZ';
	cctimestamp_withlocaltimezone CONSTANT typectype := 'TL';
	ccinterval_year_to_month      CONSTANT typectype := 'IY';
	ccinterval_day_to_second      CONSTANT typectype := 'ID';

	PROCEDURE messagedialogproc
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN CHAR
	   ,pcmd    IN NUMBER
	);
	FUNCTION checkcid(pcid VARCHAR) RETURN BOOLEAN;
	FUNCTION getversion RETURN VARCHAR;

	PROCEDURE clearbuffer;
	FUNCTION calltotp_subscribe(pparams VARCHAR) RETURN BLOB;

END;
/
CREATE OR REPLACE PACKAGE BODY custom_service AS
	cpackagename CONSTANT VARCHAR(40) := 'Service';
	cpackage     CONSTANT VARCHAR(100) := cpackagename;
	cversion     CONSTANT VARCHAR(100) := cpackage ||
										  ' : ver $Rev: 45204 $ at $Date:: 2022-07-29 17:37:31#$';

	cid CONSTANT VARCHAR(32000) := '434F4D504153535F5457434D535F53455256494345' || sys_guid();

	sthreadcount NUMBER := 0;

	FUNCTION getidtype(pdatatype IN VARCHAR) RETURN NUMBER;

	FUNCTION hexhalfbyte2bin(phex IN VARCHAR) RETURN VARCHAR;
	FUNCTION binhalfbyte2hex(pbin IN VARCHAR) RETURN VARCHAR;
	FUNCTION hexhalfbyte2num(phex IN VARCHAR) RETURN NUMBER;

	FUNCTION getversion RETURN VARCHAR IS
	BEGIN
		RETURN formatpackageversion(cpackagename, chversion, cversion);
	END;

	FUNCTION clsbit
	(
		pstr IN VARCHAR
	   ,pbit IN VARCHAR
	) RETURN VARCHAR IS
		vstr VARCHAR(100);
		vpos NUMBER;
	BEGIN
		vstr := pstr;
		FOR i IN 1 .. nvl(length(pbit), 0)
		LOOP
			vpos := ascii(substr(pbit, i, 1)) - 47;
			vstr := rpad(nvl(vstr, ' '), vpos - 1, ' ') || ' ' || substr(vstr, vpos + 1);
		END LOOP;
		RETURN rtrim(vstr);
	END;

	FUNCTION convertnumber
	(
		pnumber IN NUMBER
	   ,psex    IN CHAR
	   ,plang   IN NUMBER := lang_rus
	) RETURN VARCHAR IS
	BEGIN
		RETURN cnvnum.cnvnum(pnumber, plang, psex);
	END;

	FUNCTION convertdate
	(
		pdate IN DATE
	   ,plang IN NUMBER := lang_rus
	) RETURN VARCHAR IS
	BEGIN
		RETURN cnvdate.cnvdate(pdate, plang);
	END;

	FUNCTION cpad
	(
		pstr      IN CHAR
	   ,plen      IN NUMBER
	   ,pfillchar IN CHAR
	) RETURN CHAR IS
	BEGIN
		IF plen < length(pstr)
		THEN
			RETURN substr(pstr, 1, plen);
		ELSE
		
			RETURN service.leftpad(service.rightpad(pstr
												   ,round(length(pstr) + (plen - length(pstr)) / 2)
												   ,pfillchar)
								  ,plen
								  ,pfillchar);
		END IF;
	END;

	FUNCTION dialogconfirm
	(
		ptitle    IN VARCHAR
	   ,pmessage  IN VARCHAR
	   ,pbutton1  IN VARCHAR
	   ,phint1    IN VARCHAR
	   ,pbutton2  IN VARCHAR
	   ,phint2    IN VARCHAR
	   ,pdlgextid VARCHAR
	) RETURN NUMBER IS
	
		TYPE typevarchararray IS TABLE OF VARCHAR(200) INDEX BY BINARY_INTEGER;
		VARRAY     typevarchararray;
		vmessage   VARCHAR(1500);
		vmessage2  VARCHAR(1500);
		varraysize NUMBER;
		vmsgsize   NUMBER;
		vpos       NUMBER;
		vpos2      NUMBER;
		vdialog    NUMBER;
	BEGIN
		vmessage   := REPLACE(substr(pmessage, 1, 1500), chr(10), '~');
		varraysize := 0;
		vmsgsize   := greatest(length(ptitle), length(pbutton1) + length(pbutton2) + 2);
	
		LOOP
			vpos := instr(vmessage, '~');
			IF vpos = 0
			THEN
				vpos := length(vmessage) + 1;
			END IF;
		
			vmessage2 := nvl(substr(vmessage, 1, vpos - 1), ' ');
			WHILE length(vmessage2) > 70
			LOOP
				varraysize := varraysize + 1;
				vpos2      := instr(substr(vmessage2, 1, 70), ' ', -1);
				IF vpos2 = 0
				THEN
					vpos2 := 71;
				END IF;
				VARRAY(varraysize) := substr(vmessage2, 1, vpos2 - 1);
				vmessage2 := substr(vmessage2, vpos2 + 1);
				vmessage := substr(vmessage, vpos2 + 1);
				vmsgsize := greatest(vmsgsize, length(VARRAY(varraysize)));
				vpos := vpos - vpos2;
			END LOOP;
		
			varraysize := varraysize + 1;
			VARRAY(varraysize) := nvl(substr(vmessage, 1, vpos - 1), ' ');
			vmessage := substr(vmessage, vpos + 1);
			vmsgsize := greatest(vmsgsize, length(VARRAY(varraysize)));
		
			EXIT WHEN vmessage IS NULL;
		END LOOP;
	
		vdialog := dialog.new(ptitle, 0, 0, vmsgsize + 6, varraysize + 6);
		dialog.setexternalid(vdialog, nvl(pdlgextid, '*Service.Confirm'));
		FOR i IN 1 .. varraysize
		LOOP
			dialog.textlabel(vdialog, 'T' || to_char(i), 0, i + 1, vmsgsize + 6, VARRAY(i));
			dialog.settextanchor(vdialog, 'T' || to_char(i), 0);
		END LOOP;
	
		dialog.button(vdialog
					 ,'Ok'
					 ,round((vmsgsize + 6 - (length(pbutton1) + length(pbutton2) + 2)) / 2)
					 ,varraysize + 3
					 ,length(pbutton1)
					 ,pbutton1
					 ,dialog.cmok
					 ,0
					 ,phint1);
		dialog.button(vdialog
					 ,'Cancel'
					 ,round((vmsgsize + 6 - (length(pbutton1) + length(pbutton2) + 2)) / 2) +
					  length(pbutton1) + 2
					 ,varraysize + 3
					 ,length(pbutton2)
					 ,pbutton2
					 ,dialog.cmcancel
					 ,0
					 ,phint2);
		dialog.goitem(vdialog, 'Cancel');
	
		RETURN vdialog;
	END;

	FUNCTION dialogconfirm3
	(
		ptitle    IN VARCHAR
	   ,pmessage  IN VARCHAR
	   ,pbutton1  IN VARCHAR
	   ,phint1    IN VARCHAR
	   ,pbutton2  IN VARCHAR
	   ,phint2    IN VARCHAR
	   ,pbutton3  IN VARCHAR
	   ,phint3    IN VARCHAR
	   ,pdlgextid VARCHAR
	) RETURN NUMBER IS
		TYPE typevarchararray IS TABLE OF VARCHAR(200) INDEX BY BINARY_INTEGER;
	
		VARRAY     typevarchararray;
		vmessage   VARCHAR(1500);
		vmessage2  VARCHAR(1500);
		varraysize NUMBER;
		vmsgsize   NUMBER;
		vpos       NUMBER;
		vpos2      NUMBER;
		vdialog    NUMBER;
	BEGIN
		vmessage   := REPLACE(substr(pmessage, 1, 1500), chr(10), '~');
		varraysize := 0;
		vmsgsize   := greatest(length(ptitle)
							  ,length(pbutton1) + length(pbutton2) + length(pbutton3) + 4);
	
		LOOP
			vpos := instr(vmessage, '~');
			IF vpos = 0
			THEN
				vpos := length(vmessage) + 1;
			END IF;
		
			vmessage2 := nvl(substr(vmessage, 1, vpos - 1), ' ');
			WHILE length(vmessage2) > 70
			LOOP
				varraysize := varraysize + 1;
				vpos2      := instr(substr(vmessage2, 1, 70), ' ', -1);
				IF vpos2 = 0
				THEN
					vpos2 := 71;
				END IF;
				VARRAY(varraysize) := substr(vmessage2, 1, vpos2 - 1);
				vmessage2 := substr(vmessage2, vpos2 + 1);
				vmessage := substr(vmessage, vpos2 + 1);
				vmsgsize := greatest(vmsgsize, length(VARRAY(varraysize)));
				vpos := vpos - vpos2;
			END LOOP;
		
			varraysize := varraysize + 1;
			VARRAY(varraysize) := nvl(substr(vmessage, 1, vpos - 1), ' ');
			vmessage := substr(vmessage, vpos + 1);
			vmsgsize := greatest(vmsgsize, length(VARRAY(varraysize)));
		
			EXIT WHEN vmessage IS NULL;
		END LOOP;
	
		vdialog := dialog.new(ptitle, 0, 0, vmsgsize + 6, varraysize + 6);
		dialog.setexternalid(vdialog, nvl(pdlgextid, '*Service.Confirm3'));
	
		FOR i IN 1 .. varraysize
		LOOP
			dialog.textlabel(vdialog, 'T' || to_char(i), 0, i + 1, vmsgsize + 6, VARRAY(i));
			dialog.settextanchor(vdialog, 'T' || to_char(i), 0);
		END LOOP;
	
		dialog.button(vdialog
					 ,'Ok'
					 ,round((vmsgsize + 6 -
							(length(pbutton1) + length(pbutton2) + length(pbutton3) + 4)) / 2)
					 ,varraysize + 3
					 ,length(pbutton1)
					 ,pbutton1
					 ,dialog.cmok
					 ,0
					 ,phint1);
		dialog.button(vdialog
					 ,'Cancel'
					 ,round((vmsgsize + 6 -
							(length(pbutton1) + length(pbutton2) + length(pbutton3) + 4)) / 2) +
					  length(pbutton1) + 2
					 ,varraysize + 3
					 ,length(pbutton2)
					 ,pbutton2
					 ,dialog.cmconfirm
					 ,0
					 ,phint2);
		dialog.button(vdialog
					 ,'Continue'
					 ,round((vmsgsize + 6 -
							(length(pbutton1) + length(pbutton2) + length(pbutton3) + 4)) / 2) +
					  length(pbutton1) + length(pbutton2) + 4
					 ,varraysize + 3
					 ,length(pbutton3)
					 ,pbutton3
					 ,dialog.cmcancel
					 ,0
					 ,phint3);
		dialog.goitem(vdialog, 'Continue');
	
		RETURN vdialog;
	END;

	FUNCTION errordialog(ptitle IN VARCHAR) RETURN NUMBER IS
	BEGIN
		RETURN messagedialog(ptitle
							,err.getplace || '~' || to_char(err.geterrorcode) || ': ' ||
							 err.gettext() || '~'
							,pdlgextid => 'Service.Err');
	END;

	FUNCTION existproc
	(
		ppackagename   IN VARCHAR
	   ,pprocname      IN VARCHAR
	   ,pformat        IN VARCHAR
	   ,psetreason2err IN BOOLEAN
	) RETURN BOOLEAN IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.ExistProc(' || ppackagename || '.' ||
											pprocname || ', format = ' || pformat || ')';
	
		vaoverload      dbms_describe.number_table;
		vaposition      dbms_describe.number_table;
		valevel         dbms_describe.number_table;
		vaargument_name dbms_describe.varchar2_table;
		vadatatype      dbms_describe.number_table;
		vadefault_value dbms_describe.number_table;
		vain_out        dbms_describe.number_table;
		valength        dbms_describe.number_table;
		vaprecision     dbms_describe.number_table;
		vascale         dbms_describe.number_table;
		varadix         dbms_describe.number_table;
		vaspare         dbms_describe.number_table;
	
		vfunctionname  VARCHAR(1000);
		vpos           NUMBER;
		vtype          VARCHAR(2);
		vformat        VARCHAR2(240);
		vparam         VARCHAR(1000);
		i              PLS_INTEGER;
		vstr           VARCHAR(1000);
		vcurfail       BOOLEAN;
		vcuroverloadno NUMBER;
		vcheckret      BOOLEAN;
	
		TYPE typearrayoverload IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
		vafailedoverload typearrayoverload;
	
	BEGIN
		vfunctionname := 'A4M.';
		IF ppackagename IS NOT NULL
		THEN
			vfunctionname := vfunctionname || ppackagename || '.';
		END IF;
		vfunctionname := vfunctionname || pprocname;
		dbms_describe.describe_procedure(vfunctionname
										,NULL
										,NULL
										,vaoverload
										,vaposition
										,valevel
										,vaargument_name
										,vadatatype
										,vadefault_value
										,vain_out
										,valength
										,vaprecision
										,vascale
										,varadix
										,vaspare);
	
		vformat := upper(TRIM(pformat));
		vpos    := instr(vformat, '/RET:', 1);
		IF vpos = 0
		THEN
			error.raiseuser(cprocname || ' : Wrong format');
		END IF;
		vtype := substr(vformat, vpos + 5, 2);
		IF substr(vtype, 2, 1) = '/'
		THEN
			vtype := substr(vtype, 1, 1);
		END IF;
		vformat := substr(vformat, 1, vpos - 1);
		IF vformat IS NULL
		   AND vtype = ccempty
		THEN
		
			IF vaposition.count = 1
			   AND vadatatype(vaposition(vaposition.first)) = getidtype(ccempty)
			THEN
				RETURN TRUE;
			END IF;
		END IF;
	
		vcuroverloadno := -1;
		vcurfail       := TRUE;
	
		IF (vtype = ccempty)
		THEN
			vcheckret := TRUE;
		ELSE
			vcheckret := FALSE;
		END IF;
	
		vpos := 2;
		i    := vaposition.first;
		WHILE i IS NOT NULL
		LOOP
		
			IF vcuroverloadno != vaoverload(i)
			THEN
			
				IF vafailedoverload.exists(vcuroverloadno)
				   AND vafailedoverload(vcuroverloadno) = 1
				THEN
					vcurfail := TRUE;
				END IF;
			
				IF NOT vcurfail
				   AND vcheckret
				THEN
					IF htools.getsubstr(vformat, vpos, '/') IS NULL
					THEN
						RETURN TRUE;
					END IF;
				END IF;
				vcuroverloadno := vaoverload(i);
				vpos           := 2;
				vcurfail       := FALSE;
			
			END IF;
			IF NOT vcurfail
			   AND valevel(i) = 0
			THEN
				IF vaargument_name(i) IS NULL
				THEN
					IF vcheckret
					THEN
					
						vafailedoverload(vaoverload(i)) := 1;
					
					END IF;
				
					IF getidtype(vtype) != vadatatype(i)
					THEN
						vcurfail := TRUE;
					END IF;
					vcheckret := TRUE;
				ELSE
					vparam := htools.getsubstr(vformat, vpos, '/');
					IF vparam IS NULL
					THEN
						vcurfail := TRUE;
					ELSE
						vstr := CASE vain_out(i)
									WHEN 0 THEN
									 'IN:%'
									WHEN 1 THEN
									 'OUT:%'
									WHEN 2 THEN
									 'INOUT:%'
									ELSE
									 '!'
								END;
						IF (NOT vparam LIKE vstr)
						   OR (vadatatype(i) != getidtype(TRIM(htools.getsubstr(vparam, 2, ':'))))
						THEN
							vcurfail := TRUE;
						END IF;
					END IF;
					vpos := vpos + 1;
				END IF;
			END IF;
		
			i := vaposition.next(i);
		END LOOP;
		IF NOT vcurfail
		   AND vcheckret
		THEN
		
			IF htools.getsubstr(vformat, vpos, '/') IS NULL
			THEN
				RETURN TRUE;
			END IF;
		END IF;
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
		
			IF nvl(psetreason2err, FALSE)
			THEN
				err.seterror(SQLCODE, 'Service.ExistProc', SQLERRM);
			END IF;
			RETURN FALSE;
	END;

	FUNCTION getbit
	(
		pstr IN VARCHAR
	   ,pbit IN CHAR
	) RETURN NUMBER IS
	BEGIN
		RETURN to_number(nvl(substr(pstr, ascii(pbit) - 47, 1), '0'));
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 0;
	END;

	FUNCTION getdayname(pdate IN DATE) RETURN VARCHAR IS
		vday VARCHAR(11);
	BEGIN
		IF to_char(to_date('03012000', 'DDMMYYYY'), 'D') = '1'
		THEN
			SELECT decode(to_char(pdate, 'D')
						 ,'1'
						 ,'Monday'
						 ,'2'
						 ,'Tuesday'
						 ,'3'
						 ,'Wednesday'
						 ,'4'
						 ,'Thursday'
						 ,'5'
						 ,'Friday'
						 ,'6'
						 ,'Saturday'
						 ,'7'
						 ,'Sunday'
						 ,NULL)
			INTO   vday
			FROM   dual;
		ELSE
			SELECT decode(to_char(pdate, 'D')
						 ,'1'
						 ,'Sunday'
						 ,'2'
						 ,'Monday'
						 ,'3'
						 ,'Tuesday'
						 ,'4'
						 ,'Wednesday'
						 ,'5'
						 ,'Thursday'
						 ,'6'
						 ,'Friday'
						 ,'7'
						 ,'Saturday'
						 ,NULL)
			INTO   vday
			FROM   dual;
		END IF;
	
		RETURN vday;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;

	FUNCTION getmonthname(pdate IN DATE) RETURN VARCHAR IS
		vmonth VARCHAR(8);
	BEGIN
		SELECT decode(to_char(pdate, 'MM')
					 ,'01'
					 ,'January'
					 ,'02'
					 ,'February'
					 ,'03'
					 ,'March'
					 ,'04'
					 ,'April'
					 ,'05'
					 ,'May'
					 ,'06'
					 ,'June'
					 ,'07'
					 ,'July'
					 ,'08'
					 ,'August'
					 ,'09'
					 ,'September'
					 ,'10'
					 ,'October'
					 ,'11'
					 ,'November'
					 ,'12'
					 ,'December'
					 ,NULL)
		INTO   vmonth
		FROM   dual;
	
		RETURN vmonth;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;

	FUNCTION iif
	(
		pcondition IN BOOLEAN
	   ,pthen      IN DATE
	   ,pelse      IN DATE
	) RETURN DATE IS
	BEGIN
		IF pcondition
		THEN
			RETURN pthen;
		ELSE
			RETURN pelse;
		END IF;
	END;

	FUNCTION iif
	(
		pcondition IN BOOLEAN
	   ,pthen      IN NUMBER
	   ,pelse      IN NUMBER
	) RETURN NUMBER IS
	BEGIN
		IF pcondition
		THEN
			RETURN pthen;
		ELSE
			RETURN pelse;
		END IF;
	END;

	FUNCTION iif
	(
		pcondition IN BOOLEAN
	   ,pthen      IN VARCHAR
	   ,pelse      IN VARCHAR
	) RETURN VARCHAR IS
	BEGIN
		IF pcondition
		THEN
			RETURN pthen;
		ELSE
			RETURN pelse;
		END IF;
	END;

	FUNCTION messagedialog
	(
		ptitle          VARCHAR
	   ,pmessage        VARCHAR
	   ,pdetail         VARCHAR
	   ,pdetailshow     BOOLEAN
	   ,pdlgextid       VARCHAR
	   ,pactionbtntitle VARCHAR
	   ,pactionbtnhint  VARCHAR
	   ,pactionscript   VARCHAR
	) RETURN NUMBER IS
		VARRAY     types.arrtext;
		vmessage   VARCHAR(1500);
		vmessage2  VARCHAR(1500);
		varraysize NUMBER;
		vpos       NUMBER;
		vpos2      NUMBER;
		vdialog    NUMBER;
		cbw CONSTANT NUMBER := 10;
		cdw NUMBER := 50;
		cmaxlen CONSTANT NUMBER := 80;
		cevent  CONSTANT VARCHAR(100) := cpackagename || '.MessageDialogProc';
	BEGIN
		vmessage   := REPLACE(substr(pmessage, 1, 1500), chr(10), '~');
		varraysize := 0;
		cdw        := greatest(length(ptitle), cdw);
	
		LOOP
			vpos := instr(vmessage, '~');
			IF vpos = 0
			THEN
				vpos := length(vmessage) + 1;
			END IF;
		
			vmessage2 := nvl(substr(vmessage, 1, vpos - 1), ' ');
			WHILE length(vmessage2) > cmaxlen
			LOOP
				varraysize := varraysize + 1;
				vpos2      := instr(substr(vmessage2, 1, cmaxlen), ' ', -1);
				IF vpos2 = 0
				THEN
					vpos2 := cmaxlen + 1;
				END IF;
				VARRAY(varraysize) := substr(vmessage2, 1, vpos2 - 1);
				vmessage2 := substr(vmessage2, vpos2 + 1);
				vmessage := substr(vmessage, vpos2 + 1);
				cdw := greatest(cdw, length(VARRAY(varraysize)));
				vpos := vpos - vpos2;
			END LOOP;
		
			varraysize := varraysize + 1;
			VARRAY(varraysize) := nvl(substr(vmessage, 1, vpos - 1), ' ');
			vmessage := substr(vmessage, vpos + 1);
			cdw := greatest(cdw, length(VARRAY(varraysize)));
		
			EXIT WHEN vmessage IS NULL;
		END LOOP;
		cdw := cdw + 2;
	
		vdialog := dialog.new(ptitle, 0, 0, cdw, 3);
		dialog.setmeasure(vdialog, 'H');
	
		dialog.setexternalid(vdialog, nvl(pdlgextid, '*Service.Message'));
	
		FOR i IN 1 .. varraysize
		LOOP
			dialog.textlabel(vdialog, 'T' || to_char(i), 1, i + 1, cdw - 1, VARRAY(i));
			dialog.settextanchor(vdialog, 'T' || to_char(i), 0);
		END LOOP;
		dialog.hiddenchar(vdialog, 'size');
		dialog.putchar(vdialog, 'size', cdw || '~' || varraysize);
		dialog.hiddenchar(vdialog, 'detailtext');
		dialog.putchar(vdialog, 'detailtext', pdetail);
		IF pdetail IS NOT NULL
		   AND pdetailshow
		THEN
			dialog.edittext(vdialog, 'memo', 2, varraysize + 3, cdw - 3, 10);
			dialog.puttext(vdialog, 'memo', pdetail);
			dialog.setreadonly(vdialog, 'memo', TRUE);
			varraysize := varraysize + 10 + 1;
			dialog.setanchor(vdialog, 'memo', dialog.anchor_all);
			dialog.setdialogresizeable(vdialog, TRUE);
		END IF;
	
		dialog.button(vdialog
					 ,'Ok'
					 ,round(cdw / 2 - cbw / 2)
					 ,varraysize + 3
					 ,cbw
					 ,'OK'
					 ,dialog.cmok
					 ,0
					 ,'Press <Enter> to continue'
					 ,panchor => dialog.anchor_bottom);
		IF pactionbtntitle IS NOT NULL
		   AND pactionscript IS NOT NULL
		THEN
			dialog.button(vdialog
						 ,'Action'
						 ,2
						 ,varraysize + 3
						 ,least(greatest(cbw, length(pactionbtntitle) + 1)
							   ,round(cdw / 2 - 4 - cbw / 2 - 1))
						 ,pcaption => pactionbtntitle
						 ,phint => pactionbtnhint
						 ,phandler => '!' || pactionscript
						 ,panchor => dialog.anchor_leftbottom);
		END IF;
		IF (pdetail IS NOT NULL AND NOT pdetailshow)
		THEN
			dialog.button(vdialog
						 ,'Detail'
						 ,cdw - 2 - cbw
						 ,varraysize + 3
						 ,cbw
						 ,'Details>>'
						 ,0
						 ,0
						 ,'Show additional details'
						 ,phandler => cevent
						 ,panchor => dialog.anchor_rightbottom);
		END IF;
	
		RETURN vdialog;
	END;

	PROCEDURE messagedialogproc
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN CHAR
	   ,pcmd    IN NUMBER
	) IS
		cprocname CONSTANT VARCHAR(100) := cpackagename || '.MessageDialogProc(pWhat = ' || pwhat ||
										   ', pDialog = ' || pdialog || ', Item = ' || pitem ||
										   ', pCmd = ' || pcmd || ')';
		PROCEDURE showdetail IS
			vw    NUMBER;
			vh    NUMBER;
			vtext VARCHAR(32000);
			cbw CONSTANT NUMBER := 10;
			vh1 NUMBER := dialog.getitemdy(pdialog);
		BEGIN
			vw    := to_number(htools.getsubstr(dialog.getchar(pdialog, 'size'), 1));
			vh    := to_number(htools.getsubstr(dialog.getchar(pdialog, 'size'), 2));
			vtext := dialog.getchar(pdialog, 'detailtext');
			vtext := REPLACE(vtext, '~', chr(10));
			dialog.destroy(dialog.idbyname(pdialog, 'OK'));
			dialog.setvisible(pdialog, 'Detail', FALSE);
			dialog.edittext(pdialog, 'memo', 2, vh + 3, vw - 3, 10);
			dialog.puttext(pdialog, 'memo', vtext);
			dialog.setreadonly(pdialog, 'memo', TRUE);
			dialog.button(pdialog
						 ,'Ok'
						 ,round(vw / 2 - cbw / 2)
						 ,vh + 2 + 2 + 10
						 ,cbw
						 ,'OK'
						 ,dialog.cmok
						 ,0
						 ,'Press <Enter> to continue');
			dialog.setmeasure(pdialog, 'I');
			term.synchronize;
			dialog.setitemdy(pdialog
							,vh1 + dialog.getitemdy(dialog.idbyname(pdialog, 'memo')) +
							 dialog.getitemdy(dialog.idbyname(pdialog, 'ok')));
			IF dialog.existsitembyname(pdialog, 'Action')
			THEN
				dialog.setitemy(pdialog, 'Action', dialog.getitemy(dialog.idbyname(pdialog, 'ok')));
			END IF;
			dialog.setanchor(pdialog, 'Ok', dialog.anchor_bottom);
			dialog.setanchor(pdialog, 'memo', dialog.anchor_all);
			dialog.setanchor(pdialog, 'Action', dialog.anchor_leftbottom);
			dialog.setdialogresizeable(pdialog, TRUE);
		END;
	BEGIN
		IF pwhat = dialog.wtitempre
		THEN
			IF htools.equal(pitem, 'Detail')
			THEN
				showdetail;
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.show(pwhere => cprocname);
	END;

	FUNCTION setbit
	(
		pstr IN VARCHAR
	   ,pbit IN VARCHAR
	) RETURN VARCHAR IS
		vstr VARCHAR(100);
		vpos NUMBER;
	BEGIN
		vstr := pstr;
		FOR i IN 1 .. nvl(length(pbit), 0)
		LOOP
			vpos := ascii(substr(pbit, i, 1)) - 47;
			vstr := rpad(nvl(vstr, ' '), vpos - 1, ' ') || '1' || substr(vstr, vpos + 1);
		END LOOP;
		RETURN rtrim(vstr);
	END;

	PROCEDURE saymsg
	(
		piddialog IN NUMBER
	   ,ptitle    IN VARCHAR
	   ,pmessage  IN VARCHAR
	) IS
		viddialog NUMBER;
	BEGIN
		s.say(cpackagename || '.SayMsg : start...');
		viddialog := service.messagedialog(ptitle, pmessage);
	
		dialog.puthotdialog(piddialog, viddialog);
	END;

	PROCEDURE sayerr
	(
		piddialog IN NUMBER
	   ,ptitle    IN VARCHAR
	) IS
		viddialog NUMBER;
	BEGIN
		s.say(cpackagename || '.SayErr : start...');
		viddialog := service.errordialog(ptitle);
	
		dialog.puthotdialog(piddialog, viddialog);
	END;

	FUNCTION strpbrk
	(
		pstr1 IN CHAR
	   ,pstr2 IN CHAR
	) RETURN NUMBER IS
	BEGIN
		FOR i IN 1 .. length(pstr1)
		LOOP
			FOR j IN 1 .. length(pstr2)
			LOOP
				IF substr(pstr1, i, 1) = substr(pstr2, j, 1)
				THEN
					RETURN i;
				END IF;
			END LOOP;
		END LOOP;
		RETURN 0;
	END;

	FUNCTION to_date_null
	(
		pdate   IN VARCHAR
	   ,pformat IN VARCHAR
	) RETURN DATE IS
	BEGIN
		RETURN to_date(pdate, pformat);
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;

	FUNCTION upperr(pstring IN VARCHAR) RETURN VARCHAR IS
	BEGIN
	
		RETURN upper(pstring);
	END;

	FUNCTION rightpad
	(
		pstring IN VARCHAR
	   ,plength IN NUMBER
	   ,pchar   IN VARCHAR := ' '
	) RETURN VARCHAR IS
		vstring VARCHAR(32000);
		vlength NUMBER := nvl(length(pstring), 0);
	BEGIN
		IF vlength = 0
		   OR nvl(plength, 0) = 0
		THEN
			RETURN NULL;
		END IF;
		IF vlength > plength
		THEN
			RETURN substr(pstring, 1, plength);
		END IF;
		IF vlength = plength
		THEN
			RETURN pstring;
		END IF;
		vstring := pstring;
		IF ascii(pchar) < 256
		THEN
			vstring := vstring || rpad(pchar, plength - vlength, pchar);
		ELSE
			FOR i IN vlength .. plength - 1
			LOOP
				vstring := vstring || pchar;
			END LOOP;
		END IF;
		RETURN vstring;
	END;

	FUNCTION leftpad
	(
		pstring IN VARCHAR
	   ,plength IN NUMBER
	   ,pchar   IN VARCHAR := ' '
	) RETURN VARCHAR IS
		vstring VARCHAR(32000);
		vlength NUMBER := nvl(length(pstring), 0);
	BEGIN
		IF vlength = 0
		   OR nvl(plength, 0) = 0
		THEN
			RETURN NULL;
		END IF;
		IF vlength > plength
		THEN
			RETURN substr(pstring, 1, plength);
		END IF;
		IF vlength = plength
		THEN
			RETURN pstring;
		END IF;
		vstring := pstring;
		IF ascii(pchar) < 256
		THEN
			vstring := lpad(pchar, plength - vlength, pchar) || vstring;
		ELSE
			FOR i IN vlength .. plength - 1
			LOOP
				vstring := pchar || vstring;
			END LOOP;
		END IF;
		RETURN vstring;
	END;

	FUNCTION getidtype(pdatatype IN VARCHAR) RETURN NUMBER IS
	BEGIN
		RETURN CASE pdatatype WHEN ccempty THEN 0 WHEN ccvarchar2 THEN 1 WHEN ccnumber THEN 2 WHEN ccnativeinteger THEN 3 WHEN cclong THEN 8 WHEN ccrowid THEN 11 WHEN ccdate THEN 12 WHEN ccraw THEN 23 WHEN cclongraw THEN 24 WHEN ccopaque_type THEN 58 WHEN ccchar THEN 96 WHEN ccbinary_float THEN 100 WHEN ccbinary_double THEN 101 WHEN ccurowid THEN 104 WHEN ccmlslabel THEN 106 WHEN ccclob THEN 112 WHEN ccblob THEN 113 WHEN ccbfile THEN 114 WHEN ccobject THEN 121 WHEN ccnested_table THEN 122 WHEN ccvarray THEN 123 WHEN ccplsql_record THEN 250 WHEN ccplsql_table THEN 251 WHEN ccplsql_boolean THEN 252 WHEN cctime THEN 178 WHEN cctime_withtimezone THEN 179 WHEN cctimestamp THEN 180 WHEN cctimestamp_withtimezone THEN 181 WHEN cctimestamp_withlocaltimezone THEN 231 WHEN ccinterval_year_to_month THEN 182 WHEN ccinterval_day_to_second THEN 183 ELSE - 1 END;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'Service.GetIdType');
			RETURN - 1;
	END;

	FUNCTION TRIM(pparam IN VARCHAR) RETURN VARCHAR IS
	BEGIN
		RETURN rtrim(ltrim(pparam));
	END;

	FUNCTION getchar
	(
		pstr   IN VARCHAR
	   ,pindex IN NUMBER
	) RETURN VARCHAR IS
	BEGIN
		RETURN(substr(pstr, pindex, 1));
	END;

	FUNCTION setchar
	(
		pstr   IN VARCHAR
	   ,pindex IN NUMBER
	   ,pvalue IN VARCHAR
	) RETURN VARCHAR IS
	BEGIN
		RETURN(substr(pstr, 1, pindex - 1) || pvalue || substr(pstr, pindex + 1));
	END;

	FUNCTION hexhalfbyte2bin(phex IN VARCHAR) RETURN VARCHAR IS
		vret VARCHAR(4);
	BEGIN
		vret := '0000';
		IF (phex = '0')
		THEN
			vret := '0000';
		ELSIF (phex = '1')
		THEN
			vret := '0001';
		ELSIF (phex = '2')
		THEN
			vret := '0010';
		ELSIF (phex = '3')
		THEN
			vret := '0011';
		ELSIF (phex = '4')
		THEN
			vret := '0100';
		ELSIF (phex = '5')
		THEN
			vret := '0101';
		ELSIF (phex = '6')
		THEN
			vret := '0110';
		ELSIF (phex = '7')
		THEN
			vret := '0111';
		ELSIF (phex = '8')
		THEN
			vret := '1000';
		ELSIF (phex = '9')
		THEN
			vret := '1001';
		ELSIF (phex = 'A')
		THEN
			vret := '1010';
		ELSIF (phex = 'B')
		THEN
			vret := '1011';
		ELSIF (phex = 'C')
		THEN
			vret := '1100';
		ELSIF (phex = 'D')
		THEN
			vret := '1101';
		ELSIF (phex = 'E')
		THEN
			vret := '1110';
		ELSIF (phex = 'F')
		THEN
			vret := '1111';
		END IF;
		RETURN vret;
	END;

	FUNCTION binhalfbyte2hex(pbin IN VARCHAR) RETURN VARCHAR IS
		vret VARCHAR(1);
		vbin VARCHAR(4);
	BEGIN
		vbin := lpad(pbin, 4, '0');
		IF (vbin = '0000')
		THEN
			vret := '0';
		ELSIF (vbin = '0001')
		THEN
			vret := '1';
		ELSIF (vbin = '0010')
		THEN
			vret := '2';
		ELSIF (vbin = '0011')
		THEN
			vret := '3';
		ELSIF (vbin = '0100')
		THEN
			vret := '4';
		ELSIF (vbin = '0101')
		THEN
			vret := '5';
		ELSIF (vbin = '0110')
		THEN
			vret := '6';
		ELSIF (vbin = '0111')
		THEN
			vret := '7';
		ELSIF (vbin = '1000')
		THEN
			vret := '8';
		ELSIF (vbin = '1001')
		THEN
			vret := '9';
		ELSIF (vbin = '1010')
		THEN
			vret := 'A';
		ELSIF (vbin = '1011')
		THEN
			vret := 'B';
		ELSIF (vbin = '1100')
		THEN
			vret := 'C';
		ELSIF (vbin = '1101')
		THEN
			vret := 'D';
		ELSIF (vbin = '1110')
		THEN
			vret := 'E';
		ELSIF (vbin = '1111')
		THEN
			vret := 'F';
		END IF;
		RETURN vret;
	END;

	FUNCTION hexhalfbyte2num(phex IN VARCHAR) RETURN NUMBER IS
		vhex VARCHAR(1);
		vret NUMBER;
	BEGIN
		vhex := upper(phex);
		vret := 0;
		IF (vhex = '0')
		THEN
			vret := 0;
		ELSIF (vhex = '1')
		THEN
			vret := 1;
		ELSIF (vhex = '2')
		THEN
			vret := 2;
		ELSIF (vhex = '3')
		THEN
			vret := 3;
		ELSIF (vhex = '4')
		THEN
			vret := 4;
		ELSIF (vhex = '5')
		THEN
			vret := 5;
		ELSIF (vhex = '6')
		THEN
			vret := 6;
		ELSIF (vhex = '7')
		THEN
			vret := 7;
		ELSIF (vhex = '8')
		THEN
			vret := 8;
		ELSIF (vhex = '9')
		THEN
			vret := 9;
		ELSIF (vhex = 'A')
		THEN
			vret := 10;
		ELSIF (vhex = 'B')
		THEN
			vret := 11;
		ELSIF (vhex = 'C')
		THEN
			vret := 12;
		ELSIF (vhex = 'D')
		THEN
			vret := 13;
		ELSIF (vhex = 'E')
		THEN
			vret := 14;
		ELSIF (vhex = 'F')
		THEN
			vret := 15;
		END IF;
		RETURN vret;
	END;

	FUNCTION numtohex(pnum IN NUMBER) RETURN VARCHAR IS
	BEGIN
		IF (pnum IS NULL)
		THEN
			RETURN NULL;
		END IF;
		RETURN(bintohex(numtobin(pnum)));
	EXCEPTION
		WHEN OTHERS THEN
			error.save('Service.NumToHex()');
			RAISE;
	END;

	FUNCTION hextonum(phex IN VARCHAR) RETURN NUMBER IS
		vhex   VARCHAR(128);
		vbin   VARCHAR(512);
		vres   NUMBER;
		vpower NUMBER;
	BEGIN
		vres := 0;
		IF phex IS NULL
		THEN
			RETURN NULL;
		END IF;
		vhex := upper(phex);
	
		IF (length(vhex) = 1)
		THEN
			vres := hexhalfbyte2num(vhex);
		ELSE
			vbin := hextobin(vhex);
			FOR i IN 1 .. length(vbin)
			LOOP
				vpower := length(vbin) - i;
				IF (getchar(vbin, i) = '1')
				THEN
					vres := vres + power(2, vpower);
				END IF;
			END LOOP;
		END IF;
		RETURN vres;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('Service.HexToNum()');
			RAISE;
	END;

	FUNCTION hextobin(phex IN VARCHAR) RETURN VARCHAR IS
		vhex VARCHAR(128);
		vret VARCHAR(512);
		vch  VARCHAR(1);
	BEGIN
		vhex := upper(phex);
		vret := '';
		FOR i IN 1 .. nvl(length(vhex), 0)
		LOOP
			vch  := getchar(vhex, i);
			vret := vret || hexhalfbyte2bin(vch);
		END LOOP;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('Service.HexToBin()');
			RAISE;
	END;

	FUNCTION bintohex(pbin IN VARCHAR) RETURN VARCHAR IS
		vbin    VARCHAR(512);
		vret    VARCHAR(128);
		vmod    INTEGER;
		vbinlen INTEGER;
		vlen    INTEGER;
	BEGIN
	
		vbin    := pbin;
		vbinlen := length(vbin);
	
		IF (vbinlen <= 4)
		THEN
			vlen := 4;
		ELSE
			vmod := MOD(vbinlen, 4);
			IF (vmod != 0)
			THEN
				vlen := vbinlen + (4 - vmod);
			ELSE
				vlen := vbinlen;
			END IF;
		END IF;
	
		vbin := lpad(vbin, vlen, '0');
	
		vret := '';
		FOR i IN 1 .. (vlen / 4)
		LOOP
			vret := vret || binhalfbyte2hex(substr(vbin, 4 * (i - 1) + 1, 4));
		END LOOP;
	
		IF (MOD(length(vret), 2) != 0)
		THEN
			vret := '0' || vret;
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('Service.BinToHex()');
			RAISE;
	END;

	FUNCTION numtobin(pnum IN NUMBER) RETURN VARCHAR IS
		vmod INTEGER;
		vres VARCHAR(256);
		vnum INTEGER;
	BEGIN
	
		IF (pnum = 0)
		THEN
			RETURN '0';
		ELSIF (pnum = 1)
		THEN
			RETURN '1';
		END IF;
	
		vnum := pnum;
		vres := '';
	
		WHILE (vnum > 1)
		LOOP
			vmod := MOD(vnum, 2);
			vres := vmod || vres;
			vnum := trunc(vnum / 2);
		END LOOP;
	
		vres := '1' || vres;
	
		IF (MOD(length(vres), 2) != 0)
		THEN
			vres := '0' || vres;
		END IF;
	
		RETURN vres;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('Service.NumToBin()');
			RAISE;
	END;

	FUNCTION hextobch(phex IN VARCHAR) RETURN VARCHAR IS
		vhexstr VARCHAR(256);
		vstr    VARCHAR(256);
		vchar   VARCHAR(1);
		vhex    VARCHAR(2);
		vbyte   NUMBER;
		vindex  INTEGER;
	BEGIN
		vstr    := '';
		vindex  := 1;
		vhexstr := phex;
	
		IF (MOD(length(vhexstr), 2) != 0)
		THEN
			vhexstr := '0' || vhexstr;
		END IF;
	
		WHILE (vindex <= length(vhexstr))
		LOOP
			vhex := substr(vhexstr, vindex, 2);
			inc(vindex, 2);
			vbyte := hextonum(vhex);
			vchar := chr(vbyte);
			vstr  := vstr || vchar;
		END LOOP;
		RETURN vstr;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('Service.HexToBCH()');
			RAISE;
	END;

	FUNCTION bchtonum(praw VARCHAR) RETURN NUMBER IS
		vdata VARCHAR(255);
		vchar VARCHAR(1);
	BEGIN
		vdata := '';
		FOR i IN 1 .. nvl(length(praw), 0)
		LOOP
			vchar := substrb(praw, i, 1);
			vdata := vdata || numtohex(ascii(vchar));
		END LOOP;
		RETURN to_number(vdata);
	EXCEPTION
		WHEN OTHERS THEN
			error.save('Service.BCHToNum()');
			RAISE;
	END;

	FUNCTION numtomoney
	(
		pnum       IN NUMBER
	   ,pprecision IN NUMBER
	   ,pwidth     IN NUMBER
	) RETURN VARCHAR2 IS
		vvalue VARCHAR2(32767);
	BEGIN
		vvalue := to_char(pnum, 'fm' || lpad(rpad('0d', pprecision + 2, '0'), pwidth, '9'));
		RETURN lpad(nvl(vvalue, ' '), pwidth);
	EXCEPTION
		WHEN OTHERS THEN
			error.save('Service.NumTowMoney()');
			RAISE;
	END;

	PROCEDURE inc
	(
		pparam   IN OUT NUMBER
	   ,pbyvalue IN NUMBER
	) IS
	BEGIN
		pparam := pparam + pbyvalue;
	END;

	PROCEDURE DEC
	(
		pparam   IN OUT NUMBER
	   ,pbyvalue IN NUMBER
	) IS
	BEGIN
		inc(pparam, (-pbyvalue));
	END;

	FUNCTION getnextsequencevalue(psequencename VARCHAR) RETURN NUMBER IS
		vsql VARCHAR(255);
		vret NUMBER;
	BEGIN
		vsql := 'select ' || psequencename || '.NextVal from Dual';
		vret := htools.sql_getonevalue(vsql);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('Service.GetNextSequenceValue()');
			RAISE;
	END;

	FUNCTION splitstring
	(
		pstring   VARCHAR
	   ,padelimit types.arrchar
	   ,plength   NUMBER
	   ,pdelfirst BOOLEAN
	) RETURN types.arrstr250 IS
		vlist      types.arrstr250;
		vlistindex PLS_INTEGER := 0;
		vistrimon  BOOLEAN := FALSE;
		vdelims    VARCHAR(32767);
		vcurpos    PLS_INTEGER := 1;
		vmaxwidth  PLS_INTEGER;
		vposdelim  NUMBER;
		vpart      VARCHAR(32767);
		vlen CONSTANT PLS_INTEGER := nvl(length(pstring), 0);
		i PLS_INTEGER;
	
		FUNCTION getlastdelimpos(pstr VARCHAR) RETURN PLS_INTEGER IS
			vmax PLS_INTEGER;
			i    PLS_INTEGER;
		BEGIN
			vmax := 0;
			i    := padelimit.first;
			WHILE i IS NOT NULL
			LOOP
				vmax := greatest(vmax, instr(pstr, padelimit(i), -1));
				i    := padelimit.next(i);
			END LOOP;
			RETURN vmax;
		END;
	
		PROCEDURE appendlist(pstr VARCHAR) IS
		BEGIN
			IF pstr IS NOT NULL
			THEN
				vlistindex := vlistindex + 1;
			
				vlist(vlistindex) := pstr;
				IF vistrimon
				THEN
					vlist(vlistindex) := TRIM(vlist(vlistindex));
				END IF;
			
			END IF;
		END;
	
	BEGIN
		IF (pstring IS NULL)
		THEN
			RETURN vlist;
		END IF;
	
		IF plength IS NULL
		   OR plength <= 0
		THEN
			vmaxwidth := 250;
		ELSIF plength <= 250
		THEN
			vmaxwidth := plength;
		ELSE
			vmaxwidth := 250;
		END IF;
	
		i := padelimit.first;
		WHILE i IS NOT NULL
		LOOP
			vdelims := vdelims || padelimit(i);
			IF padelimit(i) = ' '
			THEN
				vistrimon := TRUE;
			END IF;
			i := padelimit.next(i);
		END LOOP;
	
		vcurpos := 1;
		WHILE vcurpos <= vlen
		LOOP
		
			IF pdelfirst
			THEN
				LOOP
					EXIT WHEN instr(vdelims, substr(pstring, vcurpos, 1)) = 0;
					vcurpos := vcurpos + 1;
					EXIT WHEN vcurpos > vlen;
				END LOOP;
			END IF;
			vpart := substr(pstring, vcurpos, vmaxwidth);
		
			IF vcurpos + vmaxwidth > vlen
			THEN
				appendlist(vpart);
				EXIT;
			END IF;
		
			vposdelim := getlastdelimpos(vpart);
			IF vposdelim > 0
			THEN
				vpart := substr(vpart, 1, vposdelim);
			END IF;
		
			appendlist(vpart);
			vcurpos := vcurpos + length(vpart);
		END LOOP;
	
		RETURN vlist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('Service.SplitString');
			RAISE;
	END;

	FUNCTION dialogfromto
	(
		phandler IN VARCHAR
	   ,ptitle   IN VARCHAR
	   ,pmessage IN VARCHAR := NULL
	) RETURN NUMBER IS
		vdialog   NUMBER;
		vx        NUMBER := 0;
		vwidth    NUMBER := 40;
		vbtnwidth NUMBER := 10;
		vadelimit types.arrchar;
		vameslist types.arrstr250;
	BEGIN
		IF (pmessage IS NOT NULL)
		THEN
			vadelimit(1) := ' ';
			vameslist := splitstring(pmessage, vadelimit, 35);
		END IF;
	
		vdialog := dialog.new(ptitle, 0, 0, vwidth, 0, pextid => '*Service.DialogFromTo');
	
		dialog.inputinteger(vdialog, 'MIN', 0, 0, NULL);
		dialog.inputinteger(vdialog, 'MAX', 0, 0, NULL);
		dialog.inputchar(vdialog, 'HANDLER', 0, 0, 150, NULL);
		dialog.setitemattributies(vdialog
								 ,'MIN'
								 ,dialog.echooff || dialog.selectoff || dialog.updateoff);
		dialog.setitemattributies(vdialog
								 ,'MAX'
								 ,dialog.echooff || dialog.selectoff || dialog.updateoff);
		dialog.setitemattributies(vdialog
								 ,'HANDLER'
								 ,dialog.echooff || dialog.selectoff || dialog.updateoff);
	
		dialog.inputinteger(vdialog, 'From', vwidth / 2 - 12, 2, 'The first No', 10, 'From:');
		dialog.inputinteger(vdialog, 'To', vwidth / 2 + 6, 2, 'The last No', 10, 'to: ');
		IF (pmessage IS NOT NULL)
		THEN
			FOR i IN 1 .. vameslist.count
			LOOP
				dialog.textlabel(vdialog
								,'InfoPacket'
								,(vwidth - length(vameslist(i))) / 2 + 1
								,3 + vx
								,vwidth - 3
								,vameslist(i));
				ktools.inc(vx);
			END LOOP;
		END IF;
		dialog.button(vdialog
					 ,'Ok'
					 ,vwidth / 2 - 1 - vbtnwidth
					 ,4 + vx
					 ,vbtnwidth
					 ,'Enter'
					 ,dialog.cmok
					 ,0
					 ,'Apply');
		dialog.button(vdialog
					 ,'Cancel'
					 ,vwidth / 2 + 1
					 ,4 + vx
					 ,vbtnwidth
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel');
	
		ktools.default_(vdialog, 'Ok');
	
		dialog.putchar(vdialog, 'HANDLER', nvl(phandler, ''));
		s.say('PutHandler ' || dialog.getchar(vdialog, 'HANDLER'), 3);
	
		dialog.setdialogpre(vdialog, cpackagename || '.DialogFromToHandler');
		dialog.setdialogvalid(vdialog, cpackagename || '.DialogFromToHandler');
	
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || 'DialogFromTo');
			error.showerror;
			IF vdialog != 0
			THEN
				dialog.destroy(vdialog);
			END IF;
			RETURN 0;
	END;

	FUNCTION getfromto
	(
		ptitle   IN VARCHAR
	   ,pfrom    IN OUT NUMBER
	   ,pto      IN OUT NUMBER
	   ,phandler IN VARCHAR := NULL
	   ,pmessage IN VARCHAR := NULL
	   ,pmin     IN NUMBER := NULL
	   ,pmax     IN NUMBER := NULL
	) RETURN BOOLEAN IS
		vdialog  NUMBER;
		vhandler VARCHAR(150);
	BEGIN
		vhandler := nvl(phandler, '');
	
		vdialog := dialogfromto(vhandler, ptitle, pmessage);
	
		IF (pfrom <> 0)
		THEN
			dialog.putnumber(vdialog, 'FROM', pfrom);
		END IF;
	
		IF (pto <> 0)
		THEN
			dialog.putnumber(vdialog, 'TO', pto);
		END IF;
	
		IF (pmin IS NOT NULL)
		THEN
			dialog.putnumber(vdialog, 'MIN', pmin);
		END IF;
	
		IF (pmax IS NOT NULL)
		THEN
			dialog.putnumber(vdialog, 'MAX', pmax);
		END IF;
	
		IF (dialog.execdialog(vdialog) = dialog.cmok)
		THEN
			pfrom := dialog.getnumber(vdialog, 'FROM');
			pto   := dialog.getnumber(vdialog, 'TO');
			s.say('Dialog.cmOk - ' || pfrom || ' ' || pto);
			IF vdialog != 0
			THEN
				dialog.destroy(vdialog);
			END IF;
		
			RETURN TRUE;
		ELSE
			s.say('Dialog.cmCancel');
		
			IF vdialog != 0
			THEN
				dialog.destroy(vdialog);
			END IF;
		
			RETURN FALSE;
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || 'GetFromTo');
			RAISE;
	END;

	PROCEDURE dialogfromtohandler
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN CHAR
	   ,pcmd    IN NUMBER
	) IS
		vfrom    NUMBER;
		vto      NUMBER;
		vmin     NUMBER;
		vmax     NUMBER;
		vhandler VARCHAR(150);
	BEGIN
		vhandler := dialog.getchar(pdialog, 'HANDLER');
		IF (pwhat = dialog.wtdialogvalid)
		THEN
			vfrom := dialog.getnumber(pdialog, 'FROM');
			vto   := dialog.getnumber(pdialog, 'TO');
			vmin  := dialog.getnumber(pdialog, 'MIN');
			vmax  := dialog.getnumber(pdialog, 'MAX');
		
			IF (vfrom IS NULL)
			THEN
				dialog.sethothint(pdialog, 'First parameter not specified');
				dialog.goitem(pdialog, 'FROM');
				RETURN;
			END IF;
			IF ((vmin IS NOT NULL) AND (vfrom < vmin))
			THEN
				dialog.sethothint(pdialog, 'The first parameter cannot be less than ' || vmin);
				dialog.goitem(pdialog, 'FROM');
				RETURN;
			END IF;
		
			IF (vto IS NULL)
			THEN
				dialog.sethothint(pdialog, 'Second parameter not specified');
				dialog.goitem(pdialog, 'TO');
				RETURN;
			END IF;
			IF ((vmax IS NOT NULL) AND (vto > vmax))
			THEN
				dialog.sethothint(pdialog, 'The second parameter cannot be greater than ' || vmax);
				dialog.goitem(pdialog, 'TO');
				RETURN;
			END IF;
		
			IF (vfrom > vto)
			THEN
				dialog.sethothint(pdialog, 'The first parameter cannot be greater than the second');
				dialog.goitem(pdialog, 'TO');
				RETURN;
			END IF;
		END IF;
		IF (nvl(length(vhandler), 0) != 0)
		THEN
			EXECUTE IMMEDIATE 'begin ' || vhandler || '(''' || pwhat || ''', ' || pdialog || ', ''' ||
							  pitem || ''', ' || pcmd || '); ' || 'end;';
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || 'DialogFromToHandler');
			error.showerror;
	END;

	FUNCTION replacestring
	(
		pstring         IN VARCHAR2
	   ,psearchstr      IN VARCHAR2
	   ,preplacementstr VARCHAR2
	) RETURN VARCHAR2 IS
		vtext2 VARCHAR2(4000);
		vstr   VARCHAR2(4000);
	
		vpos NUMBER;
		vc   NUMBER;
		vd   NUMBER;
		vl1  NUMBER;
		vl2  NUMBER;
	
		voutstr VARCHAR2(32767) := pstring;
	
	BEGIN
		vtext2 := upper(pstring);
		vstr   := upper(psearchstr);
		vpos   := instr(vtext2, vstr, 1);
		vc     := 0;
		vl1    := length(psearchstr);
		vl2    := length(preplacementstr);
		vd     := vl2 - vl1;
	
		WHILE vpos != 0
		LOOP
			voutstr := substr(voutstr, 1, vpos + vd * vc - 1) || preplacementstr ||
					   substr(voutstr, vpos + vd * vc + vl1);
			vpos    := instr(vtext2, vstr, vpos + vl1);
			vc      := vc + 1;
		END LOOP;
	
		RETURN voutstr;
	
	END;

	FUNCTION isoraclereservedword(pname VARCHAR) RETURN BOOLEAN IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.isOracleReservedWord(' || pname || ')';
	BEGIN
		FOR i IN (SELECT 1 FROM v$reserved_words WHERE keyword = upper(pname))
		LOOP
			RETURN TRUE;
		END LOOP;
	
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION isoracleusedname(pname VARCHAR) RETURN BOOLEAN IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.isOracleUsedName(' || pname || ')';
	BEGIN
		FOR i IN (SELECT 1 FROM all_objects WHERE upper(object_name) = upper(pname))
		LOOP
			RETURN TRUE;
		END LOOP;
	
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION isavaiblerecordfield(pname VARCHAR) RETURN BOOLEAN IS
	BEGIN
		IF instr(TRIM(pname), ' ') > 0
		THEN
			RETURN FALSE;
		END IF;
		EXECUTE IMMEDIATE 'declare type typeRec is record( ' || pname ||
						  ' number); begin null; end;';
		RETURN TRUE;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN FALSE;
	END;

	FUNCTION str2guid(pstr VARCHAR) RETURN types.guid IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.text2GUID(' || pstr || ')';
		vstr VARCHAR(32767) := TRIM(pstr);
	BEGIN
		vstr := REPLACE(vstr, '{', '');
		vstr := REPLACE(vstr, '}', '');
		IF vstr IS NULL
		THEN
			RETURN NULL;
		END IF;
		vstr := REPLACE(vstr, '-', '');
		IF nvl(length(vstr), 0) != 32
		THEN
			error.raiseerror('Wrong format of GUID : "' || pstr || '"');
		END IF;
		RETURN hextoraw(vstr);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION guid2str(pguid types.guid) RETURN VARCHAR IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.GUID2str()';
		vstr VARCHAR(32767) := hextoraw(pguid);
	BEGIN
		IF vstr IS NULL
		THEN
			RETURN NULL;
		END IF;
	
		RETURN '{' || substr(vstr, 1, 8) || '-' || substr(vstr, 9, 4) || '-' || substr(vstr, 13, 4) || '-' || substr(vstr
																													,17
																													,4) || '-' || substr(vstr
																																		,21
																																		,12) || '}';
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION sys_callbin
	(
		cmd VARCHAR
	   ,req VARCHAR
	) RETURN NUMBER IS
		LANGUAGE JAVA NAME 'A4MServer.execITPCmd_bigdata(java.lang.String, java.lang.String) return int';

	FUNCTION sys_getbuffer
	(
		pos NUMBER
	   ,len NUMBER
	) RETURN RAW IS
		LANGUAGE JAVA NAME 'A4MServer.getBuffer(int, int) return byte[]';

	FUNCTION getlicensesignature(pdata CLOB) RETURN CLOB IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.getLicenseSignature()';
		vsigned BLOB := NULL;
		vsize   NUMBER := 0;
		vpos    NUMBER := 0;
		vbuf    RAW(32767);
		vclob   CLOB := NULL;
	BEGIN
		s.say(cprocname || ': start...');
		IF pdata IS NOT NULL
		THEN
			htools.put2java_blob(term.chartobyte(pdata, 'utf-8'));
			vsize := sys_callbin('X', '');
			s.say(cprocname || ': signed ' || vsize || ' byte');
			dbms_lob.createtemporary(vsigned, TRUE);
			vpos := 0;
			WHILE vpos < vsize
			LOOP
				vbuf := sys_getbuffer(vpos, 32767);
				dbms_lob.writeappend(vsigned, utl_raw.length(vbuf), vbuf);
				vpos := vpos + 32767;
			END LOOP;
			vclob := term.bytetochar(vsigned, 'utf-8');
		ELSE
			s.say(cprocname || ': Input data is null');
		END IF;
		s.say(cprocname || ': signed : ');
		s.say(vclob);
		RETURN vclob;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackage || '.getLicenseSignature()');
			RAISE;
	END;

	FUNCTION formatpackageversion
	(
		ppackagename     VARCHAR
	   ,pspecsvnrevision VARCHAR
	   ,pbodysvnrevision VARCHAR
	) RETURN VARCHAR IS
	BEGIN
		RETURN ppackagename || ':{spec: ' || regexp_substr(pspecsvnrevision, '(\d)+') || ', body: ' || regexp_substr(pbodysvnrevision
																													,'(\d)+') || '}';
	END;

	PROCEDURE raiseerrstart(ptext VARCHAR) IS
	BEGIN
		error.showstack(TRUE);
		raise_application_error(seance.cerror_start, ptext);
	END;

	FUNCTION sys_clearbuffer RETURN NUMBER IS
		LANGUAGE JAVA NAME 'A4MServer.clearBuffer() return int';

	PROCEDURE clearbuffer IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.clearBuffer';
		ret INTEGER;
	BEGIN
		ret := sys_clearbuffer();
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.');
			RAISE;
	END;

	FUNCTION calltotp_subscribe(pparams VARCHAR) RETURN BLOB IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.callTOTP_subscribe';
		vsigned BLOB := NULL;
		vsize   NUMBER := 0;
		vpos    NUMBER := 0;
		vbuf    RAW(32767);
		vdata   BLOB := NULL;
	BEGIN
		s.say(cwhere || ': start...');
		vsize := sys_callbin('Y', 'subscribe' || ' ' || pparams);
		s.say(cwhere || ': signed ' || vsize || ' byte');
		dbms_lob.createtemporary(vsigned, TRUE);
		vpos := 0;
		WHILE vpos < vsize
		LOOP
			vbuf := sys_getbuffer(vpos, 32767);
			dbms_lob.writeappend(vsigned, utl_raw.length(vbuf), vbuf);
			vpos := vpos + 32767;
		END LOOP;
	
		vdata := htools.decodefrombase64(vsigned);
		clearbuffer;
		RETURN vdata;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE startthread
	(
		psql        VARCHAR
	   ,pparamcount NUMBER
	   ,pparam1     VARCHAR
	   ,pparam2     VARCHAR
	   ,pparam3     VARCHAR
	   ,prunaschild BOOLEAN
	) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vsql    VARCHAR(32767);
		vjob    NUMBER;
		vaparam types.arrtext;
		vparams VARCHAR(32767);
	BEGIN
	
		s.say('run new job...');
		sthreadcount := sthreadcount + 1;
		vaparam(1) := seance.getuid || ':' || sthreadcount;
		IF prunaschild
		   AND (seance.getsystemmode != seance.mode_none)
		THEN
			vaparam(2) := 'SEANCE_CHILD';
			vparams := seance.makestartchildparams(pcallsql    => psql
												  ,pparamcount => pparamcount
												  ,pparam1     => pparam1
												  ,pparam2     => pparam2
												  ,pparam3     => pparam3);
			vparams := htools.makestring(vaparam) || vparams;
		ELSE
			vaparam(2) := 'ALONE';
			vaparam(3) := nvl(pparamcount, 0);
			vaparam(4) := pparam1;
			vaparam(5) := pparam2;
			vaparam(6) := pparam3;
			vaparam(7) := psql;
			vparams := htools.makestring(vaparam);
		END IF;
		vsql := 'begin Service.sys_startThread(''' || REPLACE(vparams, '''', '''''') || '''); end;';
		s.say(vsql);
		dbms_job.submit(vjob, vsql, instance => htools.getsubstr(seance.getuid(), 3, ','));
		s.say('job created.');
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackage || '.startThread');
			ROLLBACK;
			RAISE;
	END;

	PROCEDURE sys_startthread(pparams VARCHAR) IS
		vparentinfo VARCHAR(32767);
		vparams     VARCHAR(32767);
		vaparam     types.arrtext;
	BEGIN
		javaport.prepare(NULL);
		vparentinfo := htools.getsubstr(pparams, 1);
		a4mlog.cleanplist;
		a4mlog.addparamrec('PARENT_ID', vparentinfo);
		a4mlog.addparamrec('PARAM', pparams);
		a4mlog.logadm('Service.StartThread: started', a4mlog.act_execstart, a4mlog.putparamlist);
		COMMIT;
		vaparam := htools.parsestring(pparams, '~', '\');
		IF vaparam.count < 6
		THEN
			raiseerrstart('Wrong number parameters on start session');
		END IF;
		s.say(cpackage || '.sys_StartThread : parent id ' || vparentinfo);
		CASE vaparam(2)
			WHEN 'SEANCE_CHILD' THEN
				vparams := substr(pparams, instr(pparams, '~', 1, 2) + 1);
				seance.startchildthreadora(vparams, cid);
			WHEN 'ALONE' THEN
			
				BEGIN
					s.say(cpackage || '.sys_StartThread : exec: ' || vaparam(7));
					CASE to_number(vaparam(3))
						WHEN 0 THEN
							EXECUTE IMMEDIATE vaparam(7);
						WHEN 1 THEN
							EXECUTE IMMEDIATE vaparam(7)
								USING vaparam(4);
						WHEN 2 THEN
							EXECUTE IMMEDIATE vaparam(7)
								USING vaparam(4), vaparam(5);
						WHEN 3 THEN
							EXECUTE IMMEDIATE vaparam(7)
								USING vaparam(4), vaparam(5), vaparam(6);
						ELSE
							raiseerrstart(cpackage || '.StartChildThread : ' ||
										  ' Run SQL: Wrong count parameters. It done not parameters for child thread!!!');
					END CASE;
				EXCEPTION
					WHEN OTHERS THEN
						error.save(cpackage || '.StartChildThread.exec');
						RAISE;
				END;
			ELSE
				raiseerrstart('Wrong target [' || vaparam(2) || '] on start session');
		END CASE;
	
		a4mlog.cleanplist;
		a4mlog.addparamrec('PARENT_ID', vparentinfo);
		a4mlog.addparamrec('PARAM', pparams);
		a4mlog.logadm('Service.StartThread: finish', a4mlog.act_execend, a4mlog.putparamlist);
		COMMIT;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackage || '.sys_StartThread');
			ROLLBACK;
			a4mlog.cleanplist;
			a4mlog.addparamrec('PARENT_ID', vparentinfo);
			a4mlog.addparamrec('PARAM', pparams);
			a4mlog.addparamrec('ERROR', error.gettext);
			a4mlog.addparamrec('CALLSTACK'
							  ,substr(error.printcallstack(error.getstackcallstack(error.stacklength))
									 ,1
									 ,3000));
			a4mlog.logadm('Service.StartThread: error ' || error.getcode()
						 ,a4mlog.act_error
						 ,a4mlog.putparamlist);
			COMMIT;
			error.clear;
	END;

	FUNCTION checkcid(pcid VARCHAR) RETURN BOOLEAN IS
	BEGIN
		IF pcid = cid
		THEN
			RETURN TRUE;
		END IF;
		RETURN FALSE;
	END;

END;
/
