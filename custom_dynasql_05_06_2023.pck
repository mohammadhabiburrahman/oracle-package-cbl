CREATE OR REPLACE PACKAGE custom_dynasql AS

	object_name CONSTANT VARCHAR(40) := 'DYNASQL';
	crevision   CONSTANT VARCHAR(100) := '$Rev: 61347 $';

	SUBTYPE typetextarray IS dbms_sql.varchar2a;

	cmainnode CONSTANT VARCHAR2(100) := '/DYNASQL';

	TYPE typeouteridrec IS RECORD(
		 objtype   NUMBER
		,objmodule NUMBER
		,objident  tdynasql.objident%TYPE);
	SUBTYPE typeouterid IS typeouteridrec;
	SUBTYPE typecode IS tdynasql.code%TYPE;
	SUBTYPE typeremark IS tdynasql.remark%TYPE;
	SUBTYPE typelocator IS tdynasql.locator%TYPE;

	TYPE typemetadata IS RECORD(
		 outerid typeouterid
		,code    typecode);

	FUNCTION toouterid
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	) RETURN typeouterid;

	PROCEDURE delsql
	(
		pcode     NUMBER
	   ,ponlytext BOOLEAN := FALSE
	);
	PROCEDURE delsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,ponlytext  BOOLEAN := FALSE
	);

	FUNCTION addsql
	(
		parray   IN typetextarray
	   ,premark  typeremark := NULL
	   ,plocator typelocator := NULL
	) RETURN NUMBER;
	FUNCTION getsql
	(
		pcode  NUMBER
	   ,parray IN OUT typetextarray
	) RETURN NUMBER;
	PROCEDURE putsql
	(
		pcode  NUMBER
	   ,parray IN typetextarray
	);
	PROCEDURE testsql(parray IN typetextarray);

	FUNCTION addsql
	(
		ptext    VARCHAR
	   ,premark  typeremark := NULL
	   ,plocator typelocator := NULL
	) RETURN NUMBER;

	PROCEDURE putsql
	(
		pcode NUMBER
	   ,ptext VARCHAR
	);
	PROCEDURE testsql(ptext VARCHAR);

	FUNCTION addsql
	(
		ptext    CLOB
	   ,premark  typeremark := NULL
	   ,plocator typelocator := NULL
	) RETURN NUMBER;
	FUNCTION getsql(pcode NUMBER) RETURN CLOB;
	PROCEDURE putsql
	(
		pcode NUMBER
	   ,ptext CLOB
	);
	PROCEDURE testsql(ptext CLOB);

	FUNCTION addsql
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,parray        IN typetextarray
	   ,premark       typeremark := NULL
	   ,pcommonbranch BOOLEAN := FALSE
	   ,plocator      typelocator := NULL
	) RETURN NUMBER;
	PROCEDURE addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,parray     IN typetextarray
	   ,premark    typeremark := NULL
	   ,plocator   typelocator := NULL
	);

	FUNCTION addsql
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,pdata         CLOB
	   ,premark       typeremark := NULL
	   ,pcommonbranch BOOLEAN := FALSE
	   ,plocator      typelocator := NULL
	) RETURN NUMBER;
	PROCEDURE addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,pdata      CLOB
	   ,premark    typeremark := NULL
	   ,plocator   typelocator := NULL
	);
	FUNCTION addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,pdata      CLOB
	   ,premark    typeremark := NULL
	) RETURN NUMBER;
	PROCEDURE addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,pdata      CLOB
	   ,premark    typeremark := NULL
	);

	FUNCTION addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,ptext      VARCHAR2
	   ,premark    typeremark := NULL
	   ,plocator   typelocator := NULL
	) RETURN NUMBER;
	PROCEDURE addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,ptext      VARCHAR2
	   ,premark    typeremark := NULL
	   ,plocator   typelocator := NULL
	);
	FUNCTION addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,ptext      VARCHAR2
	   ,premark    typeremark := NULL
	) RETURN NUMBER;
	PROCEDURE addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,ptext      VARCHAR2
	   ,premark    typeremark := NULL
	);

	FUNCTION putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,parray     IN typetextarray
	   ,paddremark typeremark := NULL
	   ,plocator   typelocator := NULL
	) RETURN NUMBER;
	PROCEDURE putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,parray     IN typetextarray
	   ,paddremark typeremark := NULL
	   ,plocator   typelocator := NULL
	);

	FUNCTION putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,pdata      CLOB
	   ,paddremark typeremark := NULL
	   ,plocator   typelocator := NULL
	) RETURN NUMBER;
	PROCEDURE putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,pdata      CLOB
	   ,paddremark typeremark := NULL
	   ,plocator   typelocator := NULL
	);
	PROCEDURE putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,pdata      CLOB
	   ,paddremark typeremark := NULL
	);
	FUNCTION putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,pdata      CLOB
	   ,paddremark typeremark := NULL
	) RETURN NUMBER;

	FUNCTION putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,ptext      VARCHAR2
	   ,paddremark typeremark := NULL
	   ,plocator   typelocator := NULL
	) RETURN NUMBER;
	PROCEDURE putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,ptext      VARCHAR2
	   ,paddremark typeremark := NULL
	   ,plocator   typelocator := NULL
	);
	PROCEDURE putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,ptext      VARCHAR2
	   ,paddremark typeremark := NULL
	);
	FUNCTION putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,ptext      VARCHAR2
	   ,paddremark typeremark := NULL
	) RETURN NUMBER;

	FUNCTION getcodebyident
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION getlocatorbycode(pcode NUMBER) RETURN VARCHAR;
	FUNCTION getcodebylocator
	(
		plocator      typelocator
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN types.arrnum;

	FUNCTION copysql
	(
		pcode    NUMBER
	   ,premark  typeremark := NULL
	   ,plocator typelocator := NULL
	) RETURN NUMBER;
	FUNCTION copysql
	(
		pfromobjtype   NUMBER
	   ,pfromobjmodule NUMBER
	   ,pfromobjident  VARCHAR
	   ,ptoobjtype     NUMBER
	   ,ptoobjmodule   NUMBER
	   ,ptoobjident    VARCHAR
	   ,premark        typeremark := NULL
	   ,plocator       typelocator := NULL
	) RETURN NUMBER;
	PROCEDURE copysql
	(
		pfromobjtype   NUMBER
	   ,pfromobjmodule NUMBER
	   ,pfromobjident  VARCHAR
	   ,ptoobjtype     NUMBER
	   ,ptoobjmodule   NUMBER
	   ,ptoobjident    VARCHAR
	   ,premark        typeremark := NULL
	   ,plocator       typelocator := NULL
	);
	FUNCTION gettextline
	(
		pcode NUMBER
	   ,pline NUMBER
	) RETURN VARCHAR;
	FUNCTION getremark(pcode NUMBER) RETURN typeremark;
	PROCEDURE putremark
	(
		pcode   NUMBER
	   ,premark typeremark
	);

	FUNCTION importfile
	(
		pfile   VARCHAR
	   ,pcode   NUMBER
	   ,pencode VARCHAR := NULL
	) RETURN NUMBER;
	FUNCTION exportfile
	(
		pfile   VARCHAR
	   ,pcode   NUMBER
	   ,pencode VARCHAR := NULL
	) RETURN NUMBER;
	FUNCTION importfile
	(
		pfile   VARCHAR
	   ,parray  IN OUT typetextarray
	   ,pencode VARCHAR := NULL
	) RETURN NUMBER;
	FUNCTION exportfile
	(
		pfile   VARCHAR
	   ,parray  IN OUT typetextarray
	   ,pencode VARCHAR := NULL
	) RETURN NUMBER;

	FUNCTION importfile
	(
		pfile   VARCHAR
	   ,pencode VARCHAR := NULL
	) RETURN CLOB;
	FUNCTION exportfile
	(
		pfile   VARCHAR
	   ,ptext   CLOB
	   ,pencode VARCHAR := NULL
	) RETURN NUMBER;
	FUNCTION exportfile
	(
		pfile   VARCHAR
	   ,pstr    VARCHAR
	   ,pencode VARCHAR := NULL
	) RETURN NUMBER;

	PROCEDURE setvaluenum
	(
		pcode  NUMBER
	   ,pident VARCHAR
	   ,pval   NUMBER
	);
	PROCEDURE setvaluedate
	(
		pcode  NUMBER
	   ,pident VARCHAR
	   ,pval   DATE
	);
	PROCEDURE setvaluechar
	(
		pcode  NUMBER
	   ,pident VARCHAR
	   ,pval   VARCHAR
	);

	FUNCTION getvaluenum
	(
		pcode  NUMBER
	   ,pident VARCHAR
	) RETURN NUMBER;
	FUNCTION getvaluedate
	(
		pcode  NUMBER
	   ,pident VARCHAR
	) RETURN DATE;
	FUNCTION getvaluechar
	(
		pcode  NUMBER
	   ,pident VARCHAR
	) RETURN VARCHAR;

	PROCEDURE bindclear(pcode NUMBER);

	PROCEDURE runbatch
	(
		pcode                NUMBER
	   ,pexception           BOOLEAN
	   ,pusecommitcontrol    BOOLEAN := FALSE
	   ,pparamsourceuid      objectuid.typeobjectuid := NULL
	   ,pcursortxttodbgifexc BOOLEAN := TRUE
	);

	PROCEDURE runone
	(
		pcode                NUMBER
	   ,pexception           BOOLEAN
	   ,pusecommitcontrol    BOOLEAN := FALSE
	   ,pparamsourceuid      objectuid.typeobjectuid := NULL
	   ,pcursortxttodbgifexc BOOLEAN := TRUE
	);

	FUNCTION runbatch
	(
		pcode                NUMBER
	   ,pexception           BOOLEAN
	   ,pretval              NUMBER := 0
	   ,pusecommitcontrol    BOOLEAN := FALSE
	   ,pparamsourceuid      objectuid.typeobjectuid := NULL
	   ,pcursortxttodbgifexc BOOLEAN := TRUE
	) RETURN NUMBER;

	FUNCTION runone
	(
		pcode                NUMBER
	   ,pexception           BOOLEAN
	   ,pretval              NUMBER := 0
	   ,pusecommitcontrol    BOOLEAN := FALSE
	   ,pparamsourceuid      objectuid.typeobjectuid := NULL
	   ,pcursortxttodbgifexc BOOLEAN := TRUE
	) RETURN NUMBER;

	PROCEDURE runclear;
	PROCEDURE runclear
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	);

	FUNCTION parseone(pcode NUMBER) RETURN NUMBER;

	FUNCTION getuserproplist
	(
		pcode     NUMBER
	   ,powneruid objectuid.typeobjectuid := NULL
	) RETURN apitypes.typeuserproplist;
	FUNCTION getuserprop
	(
		pcode      NUMBER
	   ,pfieldname IN VARCHAR
	   ,powneruid  objectuid.typeobjectuid := NULL
	) RETURN apitypes.typeuserprop;
	PROCEDURE setuserproplist
	(
		pcode               NUMBER
	   ,plist               apitypes.typeuserproplist
	   ,powneruid           objectuid.typeobjectuid := NULL
	   ,pclearpropnotinlist BOOLEAN := FALSE
	);

	FUNCTION getuserattributeslist
	(
		pcode     NUMBER
	   ,powneruid objectuid.typeobjectuid := NULL
	) RETURN apitypes.typeuserproplist;
	FUNCTION getuserattributerecord
	(
		pcode      NUMBER
	   ,pfieldname IN VARCHAR
	   ,powneruid  objectuid.typeobjectuid := NULL
	) RETURN apitypes.typeuserprop;
	PROCEDURE saveuserattributeslist
	(
		pcode               NUMBER
	   ,plist               apitypes.typeuserproplist
	   ,powneruid           objectuid.typeobjectuid := NULL
	   ,pclearpropnotinlist BOOLEAN := FALSE
	);

	FUNCTION getobjectuid(pcode NUMBER) RETURN objectuid.typeobjectuid;

	FUNCTION getcurproplist RETURN apitypes.typeuserproplist;
	FUNCTION getcurprop(ppropname VARCHAR) RETURN apitypes.typeuserprop;

	PROCEDURE clearuserpropreference
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	);
	FUNCTION getsubobjectforup
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	) RETURN VARCHAR;

	FUNCTION exportsql
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN CLOB;
	PROCEDURE importsql
	(
		pdata         CLOB
	   ,pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	   ,plocator      typelocator := NULL
	);

	FUNCTION exportsql
	(
		pcode         NUMBER
	   ,pcommonbranch BOOLEAN := FALSE
	   ,pouterid      typeouterid := NULL
	) RETURN CLOB;
	PROCEDURE importsql
	(
		pdata                  CLOB
	   ,pcommonbranch          BOOLEAN := FALSE
	   ,poblockcode            IN OUT NOCOPY NUMBER
	   ,pouterid               typeouterid := NULL
	   ,plocator               typelocator := NULL
	   ,premark                typeremark := NULL
	   ,pautonomoustransaction BOOLEAN := TRUE
	);

	PROCEDURE setlocator
	(
		pcode    IN NUMBER
	   ,plocator IN typelocator
	);

	FUNCTION lookforouteridandcode(pdata xmltype) RETURN typemetadata;

	FUNCTION getversion RETURN VARCHAR;

END;
/
CREATE OR REPLACE PACKAGE BODY custom_dynasql AS

	cpackage      CONSTANT VARCHAR(100) := 'DynaSQL';
	cbodyrevision CONSTANT VARCHAR(100) := '$Rev: 45321 $';

	nl CONSTANT VARCHAR(2) := chr(10);

	co_num  CONSTANT NUMBER(1) := 1;
	co_date CONSTANT NUMBER(1) := 2;
	co_char CONSTANT NUMBER(1) := 3;

	sdummy VARCHAR(32000);

	cobjtypeattr   CONSTANT VARCHAR2(100) := 'ObjType';
	cobjmoduleattr CONSTANT VARCHAR2(100) := 'ObjModule';
	cobjidentattr  CONSTANT VARCHAR2(100) := 'ObjIdent';
	ccodeattr      CONSTANT VARCHAR2(100) := 'Code';

	SUBTYPE typesqlrec IS tdynasql%ROWTYPE;

	TYPE typecacherec IS RECORD(
		 code      NUMBER
		,run       NUMBER
		,objtype   NUMBER
		,objmodule NUMBER
		,objident  VARCHAR(250)
		,owneruid  objectuid.typeobjectuid
		,isrunning BOOLEAN := FALSE);
	TYPE typecachetab IS TABLE OF typecacherec INDEX BY BINARY_INTEGER;

	TYPE typebindrec IS RECORD(
		 code  NUMBER
		,ident VARCHAR(100)
		,vtype NUMBER(1)
		,NEXT  NUMBER
		,
		
		valbool BOOLEAN
		,valnum  NUMBER
		,valdate DATE
		,valchar types.text);

	TYPE typeenv IS RECORD(
		 paramsourceuid objectuid.typeobjectuid
		,params         apitypes.typeuserproplist
		,prevcode       NUMBER);
	TYPE typeenvlist IS TABLE OF typeenv INDEX BY BINARY_INTEGER;

	TYPE typebindtab IS TABLE OF typebindrec INDEX BY BINARY_INTEGER;
	TYPE typeroottab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

	s_arrcache  typecachetab;
	s_arrbind   typebindtab;
	s_arrroot   typeroottab;
	s_arrenv    typeenvlist;
	scurruncode NUMBER;

	PROCEDURE addtextline
	(
		pcode NUMBER
	   ,pline NUMBER
	   ,ptext VARCHAR
	);
	PROCEDURE deltextlines(pcode NUMBER);
	PROCEDURE delsqlrec(pcode NUMBER);
	FUNCTION getsqlrec(pcode NUMBER) RETURN typesqlrec;
	PROCEDURE putsqlrec
	(
		pcode   NUMBER
	   ,premark typeremark
	);
	FUNCTION normalize(ptext IN VARCHAR) RETURN VARCHAR;

	FUNCTION array2text(parray typetextarray) RETURN CLOB;
	FUNCTION text2array(ptext VARCHAR2) RETURN typetextarray;
	FUNCTION text2array(ptext CLOB) RETURN typetextarray;
	FUNCTION checkexists
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN BOOLEAN;
	PROCEDURE checkcode(pcode NUMBER);

	FUNCTION isexistingcode(pcode NUMBER) RETURN BOOLEAN;

	PROCEDURE closerun(prun IN OUT NUMBER);
	FUNCTION COMPILE(pcode NUMBER) RETURN typecacherec;
	FUNCTION compileonly(parray typetextarray) RETURN NUMBER;

	FUNCTION runrun
	(
		prec                 typecacherec
	   ,pret                 NUMBER
	   ,pusecommitcontrol    BOOLEAN := FALSE
	   ,pcursortxttodbgifexc BOOLEAN
	) RETURN NUMBER;

	PROCEDURE runrun
	(
		prec                 typecacherec
	   ,pusecommitcontrol    BOOLEAN := FALSE
	   ,pcursortxttodbgifexc BOOLEAN
	);

	PROCEDURE clearcache
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	);
	FUNCTION getcache(pcode NUMBER) RETURN typecacherec;
	PROCEDURE putcache
	(
		pcode NUMBER
	   ,prec  typecacherec
	);
	PROCEDURE updatecache
	(
		pcode NUMBER
	   ,prec  typecacherec
	);
	PROCEDURE freeenv(prec typecacherec);

	FUNCTION remarkwrapper
	(
		parray   IN typetextarray
	   ,pisdebug IN BOOLEAN := FALSE
	   ,pisexec  IN BOOLEAN := TRUE
	) RETURN typetextarray;

	PROCEDURE clearbindcache(pcode NUMBER);

	PROCEDURE setouterid
	(
		pcode IN NUMBER
	   ,pid   typeouterid
	);

	FUNCTION getversion RETURN VARCHAR IS
	BEGIN
		RETURN service.formatpackageversion(cpackage, crevision, cbodyrevision);
	END;

	PROCEDURE say(ptext VARCHAR) IS
	BEGIN
		s.say(ptext, 8, 3);
	END;

	FUNCTION getsubobjectforup
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	) RETURN VARCHAR IS
	BEGIN
		RETURN substr(TRIM(to_char(pobjtype)) || '_' || TRIM(to_char(pobjmodule)) || '_' ||
					  TRIM(pobjident)
					 ,1
					 ,250);
	END;

	FUNCTION getsubobjectforup(pcode NUMBER) RETURN VARCHAR IS
	BEGIN
		FOR i IN (SELECT substr(TRIM(to_char(objtype)) || '_' || TRIM(to_char(objmodule)) || '_' ||
								TRIM(objident)
							   ,1
							   ,250) subobj
				  FROM   tdynasql
				  WHERE  code = pcode)
		LOOP
			RETURN i.subobj;
		END LOOP;
		RETURN NULL;
	END;

	FUNCTION addsqlrec
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,premark       typeremark
	   ,pcommonbranch BOOLEAN
	   ,plocator      typelocator
	) RETURN NUMBER IS
		vcode      NUMBER;
		vbranch    NUMBER := seance.getbranch();
		vobjectuid objectuid.typeobjectuid;
	BEGIN
		SAVEPOINT sp_addsqlrec;
		IF pcommonbranch
		THEN
			vbranch := seance.cbranch_common;
		END IF;
	
		SELECT seqdynasql.nextval INTO vcode FROM dual;
		IF pobjtype IS NOT NULL
		THEN
			vobjectuid := objectuid.newuid(dynasql.object_name, TRIM(to_char(vcode)));
		END IF;
	
		INSERT INTO tdynasql
			(branch
			,code
			,objtype
			,objmodule
			,objident
			,remark
			,objectuid
			,locator)
		VALUES
			(vbranch
			,vcode
			,pobjtype
			,pobjmodule
			,pobjident
			,substr(premark, 1, 50)
			,vobjectuid
			,plocator);
	
		RETURN vcode;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.AddSQLRec');
			ROLLBACK TO sp_addsqlrec;
			RAISE;
	END;

	FUNCTION getobjectuid(pcode NUMBER) RETURN objectuid.typeobjectuid IS
	BEGIN
		FOR crow IN (SELECT objectuid FROM tdynasql WHERE code = pcode)
		LOOP
			RETURN crow.objectuid;
		END LOOP;
		RETURN NULL;
	END;

	PROCEDURE delsql
	(
		pcode     NUMBER
	   ,ponlytext BOOLEAN
	) IS
	
		vsubobject VARCHAR(250) := getsubobjectforup(pcode);
	BEGIN
		s.say(cpackage || '.DelSQL[' || pcode || '][' || htools.b2s(ponlytext) || ']');
		IF pcode IS NULL
		THEN
			RETURN;
		END IF;
	
		IF NOT ponlytext
		THEN
			IF TRIM(vsubobject) IS NOT NULL
			THEN
				objuserproperty.clearreference(object_name, vsubobject);
			END IF;
		END IF;
		SAVEPOINT sp_delsql;
		deltextlines(pcode);
		delsqlrec(pcode);
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.DelSQL');
			ROLLBACK TO sp_delsql;
			RAISE;
	END;

	PROCEDURE delsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,ponlytext  BOOLEAN
	) IS
		cwhere CONSTANT VARCHAR2(200) := cpackage || '.DelSQL(' || pobjtype || ', ' || pobjmodule || ', ' ||
										 pobjident || ')';
		vcode   NUMBER;
		vsubobj VARCHAR2(250);
		PROCEDURE rollback_sp_delsql2 IS
		BEGIN
			ROLLBACK TO sp_delsql2;
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	BEGIN
		s.say(cwhere || ': start...');
		vsubobj := getsubobjectforup(pobjtype, pobjmodule, pobjident);
		IF NOT ponlytext
		THEN
			IF TRIM(vsubobj) IS NOT NULL
			THEN
				objuserproperty.clearreference(object_name, vsubobj);
			END IF;
		END IF;
		vcode := getcodebyident(pobjtype, pobjmodule, pobjident);
		IF vcode IS NOT NULL
		THEN
			SAVEPOINT sp_delsql2;
			deltextlines(vcode);
			delsqlrec(vcode);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			rollback_sp_delsql2();
			RAISE;
	END;

	FUNCTION addsql
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,parray        typetextarray
	   ,premark       typeremark
	   ,pcommonbranch BOOLEAN
	   ,plocator      typelocator
	) RETURN NUMBER IS
		vcode NUMBER;
		vai   types.arrnum;
	BEGIN
		SAVEPOINT sp_addsqlbyident;
		IF pobjtype IS NULL
		   OR pobjmodule IS NULL
		   OR pobjident IS NULL
		THEN
			error.raiseerror('External identifier [' || pobjtype || ',' || pobjmodule || ',' ||
							 pobjident || '] is incomplete !');
		END IF;
	
		IF checkexists(pobjtype, pobjmodule, pobjident, pcommonbranch)
		THEN
			error.raiseerror('External identifier [' || pobjtype || ',' || pobjmodule || ',' ||
							 pobjident || '] already exists !');
		END IF;
	
		vcode := addsqlrec(pobjtype, pobjmodule, pobjident, premark, pcommonbranch, plocator);
	
		deltextlines(vcode);
		FOR i IN 1 .. parray.count
		LOOP
			vai(i) := i;
		END LOOP;
		FORALL i IN 1 .. parray.count
			INSERT INTO tdynasqlsource
				(code
				,line
				,text)
			VALUES
				(vcode
				,vai(i)
				,parray(i));
	
		RETURN vcode;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.AddSQL(Type, Module, Ident)');
			BEGIN
				ROLLBACK TO sp_addsqlbyident;
			EXCEPTION
				WHEN OTHERS THEN
					s.err('rollback');
			END;
			RAISE;
	END;

	FUNCTION addsql
	(
		pouterid typeouterid
	   ,parray   IN typetextarray
	   ,premark  typeremark
	   ,plocator typelocator
	) RETURN NUMBER IS
	BEGIN
		RETURN addsql(pouterid.objtype
					 ,pouterid.objmodule
					 ,pouterid.objident
					 ,parray
					 ,premark
					 ,plocator => plocator);
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.AddSQL(OuterId)');
			RAISE;
	END;

	PROCEDURE addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,parray     IN typetextarray
	   ,premark    typeremark
	   ,plocator   typelocator
	) IS
	BEGIN
		sdummy := addsql(pobjtype, pobjmodule, pobjident, parray, premark, plocator => plocator);
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.AddSQL2');
			RAISE;
	END;

	FUNCTION addsql
	(
		parray   IN typetextarray
	   ,premark  typeremark
	   ,plocator typelocator
	) RETURN NUMBER IS
		vcode NUMBER;
	BEGIN
		SAVEPOINT sp_addsqlbycode;
		vcode := addsqlrec(NULL, NULL, NULL, premark, FALSE, plocator);
	
		deltextlines(vcode);
		FOR i IN 1 .. parray.count()
		LOOP
			addtextline(vcode, i, parray(i));
		END LOOP;
		RETURN vcode;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.AddSQL');
			ROLLBACK TO sp_addsqlbycode;
			RAISE;
	END;

	FUNCTION getsql
	(
		pcode  NUMBER
	   ,parray IN OUT typetextarray
	) RETURN NUMBER IS
	
	BEGIN
		checkcode(pcode);
		parray.delete();
	
		SELECT text BULK COLLECT
		INTO   parray
		FROM   tdynasqlsource
		WHERE  code = pcode
		ORDER  BY code
				 ,line;
		RETURN parray.count;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.GetSQL');
			RAISE;
	END;

	PROCEDURE putsql
	(
		pcode  NUMBER
	   ,parray IN typetextarray
	) IS
	BEGIN
		SAVEPOINT sp_putsql;
	
		BEGIN
			checkcode(pcode);
		EXCEPTION
			WHEN OTHERS THEN
				INSERT INTO tdynasql
					(branch
					,code)
				VALUES
					(seance.getbranch
					,pcode);
		END;
	
		deltextlines(pcode);
		FOR i IN 1 .. parray.count()
		LOOP
			addtextline(pcode, i, parray(i));
		END LOOP;
		s_arrcache.delete(pcode);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.PutSQL');
			ROLLBACK TO sp_putsql;
			RAISE;
	END;

	FUNCTION putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,parray     IN typetextarray
	   ,paddremark typeremark
	   ,plocator   typelocator
	) RETURN NUMBER IS
		vcode NUMBER;
	BEGIN
		vcode := getcodebyident(pobjtype, pobjmodule, pobjident);
		IF vcode IS NULL
		THEN
			vcode := addsql(pobjtype
						   ,pobjmodule
						   ,pobjident
						   ,parray
						   ,paddremark
						   ,plocator => plocator);
		ELSE
			putsql(vcode, parray);
		END IF;
		RETURN vcode;
	END;

	PROCEDURE putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,parray     IN typetextarray
	   ,paddremark typeremark
	   ,plocator   typelocator
	) IS
	BEGIN
		sdummy := putsql(pobjtype, pobjmodule, pobjident, parray, paddremark, plocator);
	END;

	FUNCTION addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,ptext      VARCHAR2
	   ,premark    typeremark
	   ,plocator   typelocator
	) RETURN NUMBER IS
	BEGIN
		RETURN addsql(pobjtype
					 ,pobjmodule
					 ,pobjident
					 ,text2array(ptext)
					 ,premark
					 ,plocator => plocator);
	END;

	FUNCTION addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,ptext      VARCHAR2
	   ,premark    typeremark
	) RETURN NUMBER IS
	BEGIN
		RETURN addsql(pobjtype, pobjmodule, pobjident, text2array(ptext), premark);
	END;

	PROCEDURE addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,ptext      VARCHAR2
	   ,premark    typeremark
	   ,plocator   typelocator
	) IS
	BEGIN
		addsql(pobjtype, pobjmodule, pobjident, text2array(ptext), premark, plocator => plocator);
	END;

	PROCEDURE addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,ptext      VARCHAR2
	   ,premark    typeremark
	) IS
	BEGIN
		addsql(pobjtype, pobjmodule, to_char(pobjident), ptext, premark);
	END;

	FUNCTION addsql
	(
		ptext    VARCHAR
	   ,premark  typeremark
	   ,plocator typelocator
	) RETURN NUMBER IS
	BEGIN
		RETURN addsql(text2array(ptext), premark, plocator => plocator);
	END;

	PROCEDURE putsql
	(
		pcode NUMBER
	   ,ptext VARCHAR
	) IS
	BEGIN
		putsql(pcode, text2array(ptext));
	END;

	FUNCTION putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,ptext      VARCHAR2
	   ,paddremark typeremark
	   ,plocator   typelocator
	) RETURN NUMBER IS
		vcode NUMBER;
	BEGIN
		vcode := getcodebyident(pobjtype, pobjmodule, pobjident);
		IF vcode IS NULL
		THEN
			vcode := addsql(pobjtype
						   ,pobjmodule
						   ,pobjident
						   ,ptext
						   ,paddremark
						   ,plocator => plocator);
		ELSE
			putsql(vcode, ptext);
		END IF;
		RETURN vcode;
	END;

	FUNCTION putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,ptext      VARCHAR2
	   ,paddremark typeremark
	) RETURN NUMBER IS
	BEGIN
		RETURN putsql(pobjtype, pobjmodule, to_char(pobjident), ptext, paddremark);
	END;

	PROCEDURE putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,ptext      VARCHAR2
	   ,paddremark typeremark
	   ,plocator   typelocator
	) IS
	BEGIN
		sdummy := putsql(pobjtype, pobjmodule, pobjident, ptext, paddremark, plocator => plocator);
	END;
	PROCEDURE putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,ptext      VARCHAR2
	   ,paddremark typeremark
	) IS
	BEGIN
		putsql(pobjtype, pobjmodule, to_char(pobjident), ptext, paddremark);
	END;

	FUNCTION addsql
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,pdata         CLOB
	   ,premark       typeremark
	   ,pcommonbranch BOOLEAN
	   ,plocator      typelocator
	) RETURN NUMBER IS
	BEGIN
		RETURN addsql(pobjtype
					 ,pobjmodule
					 ,pobjident
					 ,text2array(pdata)
					 ,premark
					 ,pcommonbranch
					 ,plocator => plocator);
	END;

	FUNCTION addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,pdata      CLOB
	   ,premark    typeremark
	) RETURN NUMBER IS
	BEGIN
		RETURN addsql(pobjtype, pobjmodule, to_char(pobjident), pdata, premark);
	END;

	FUNCTION addsql
	(
		pid           typeouterid
	   ,pdata         CLOB
	   ,premark       typeremark
	   ,pcommonbranch BOOLEAN
	   ,plocator      typelocator
	) RETURN NUMBER IS
	BEGIN
		RETURN addsql(pid.objtype
					 ,pid.objmodule
					 ,pid.objident
					 ,pdata
					 ,premark
					 ,pcommonbranch
					 ,plocator);
	END;

	PROCEDURE addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,pdata      CLOB
	   ,premark    typeremark
	   ,plocator   typelocator
	) IS
	BEGIN
		addsql(pobjtype, pobjmodule, pobjident, text2array(pdata), premark, plocator => plocator);
	END;

	PROCEDURE addsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,pdata      CLOB
	   ,premark    typeremark
	) IS
	BEGIN
		addsql(pobjtype, pobjmodule, to_char(pobjident), pdata, premark);
	END;

	FUNCTION addsql
	(
		ptext    CLOB
	   ,premark  typeremark
	   ,plocator typelocator
	) RETURN NUMBER IS
	BEGIN
		RETURN addsql(text2array(ptext), premark, plocator => plocator);
	END;

	FUNCTION getsql(pcode NUMBER) RETURN CLOB IS
		varr  typetextarray;
		vtext typetextarray;
	BEGIN
		sdummy := getsql(pcode, varr);
		vtext  := remarkwrapper(varr, TRUE, FALSE);
		htools.printsql(vtext, pcode, 'SQL');
		RETURN array2text(varr);
	END;

	PROCEDURE putsql
	(
		pcode NUMBER
	   ,ptext CLOB
	) IS
	BEGIN
		putsql(pcode, text2array(ptext));
	END;

	FUNCTION putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,pdata      CLOB
	   ,paddremark typeremark
	   ,plocator   typelocator
	) RETURN NUMBER IS
		vcode NUMBER;
	BEGIN
		vcode := getcodebyident(pobjtype, pobjmodule, pobjident);
		IF vcode IS NULL
		THEN
			vcode := addsql(pobjtype
						   ,pobjmodule
						   ,pobjident
						   ,pdata      => pdata
						   ,premark    => paddremark
						   ,plocator   => plocator);
		ELSE
			putsql(vcode, pdata);
		END IF;
		RETURN vcode;
	END;

	PROCEDURE putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	   ,pdata      CLOB
	   ,paddremark typeremark
	   ,plocator   typelocator
	) IS
	BEGIN
		sdummy := putsql(pobjtype, pobjmodule, pobjident, pdata, paddremark, plocator => plocator);
	END;

	PROCEDURE putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,pdata      CLOB
	   ,paddremark typeremark
	) IS
	BEGIN
		putsql(pobjtype, pobjmodule, to_char(pobjident), pdata, paddremark);
	END;

	FUNCTION putsql
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  NUMBER
	   ,pdata      CLOB
	   ,paddremark typeremark
	) RETURN NUMBER IS
	BEGIN
		RETURN putsql(pobjtype, pobjmodule, to_char(pobjident), pdata, paddremark);
	END;

	FUNCTION gettextline
	(
		pcode NUMBER
	   ,pline NUMBER
	) RETURN VARCHAR IS
		vtext tdynasqlsource.text%TYPE;
	BEGIN
		SELECT text
		INTO   vtext
		FROM   tdynasqlsource
		WHERE  code = pcode
		AND    line = pline;
	
		RETURN vtext;
	END;

	FUNCTION getremark(pcode NUMBER) RETURN typeremark IS
	BEGIN
		RETURN getsqlrec(pcode).remark;
	END;

	PROCEDURE putremark
	(
		pcode   NUMBER
	   ,premark typeremark
	) IS
	BEGIN
		putsqlrec(pcode, premark);
	END;

	FUNCTION getcodebyident
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,pcommonbranch BOOLEAN
	) RETURN NUMBER IS
		vcode   NUMBER;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		IF pcommonbranch
		THEN
			vbranch := seance.cbranch_common;
		END IF;
		SELECT code
		INTO   vcode
		FROM   tdynasql
		WHERE  branch = vbranch
		AND    objtype = pobjtype
		AND    objmodule = pobjmodule
		AND    objident = pobjident;
		RETURN vcode;
	EXCEPTION
		WHEN no_data_found THEN
			RETURN NULL;
		WHEN OTHERS THEN
			s.err('DynaSQl.GetCodeByIdent, ot:' || pobjtype || ', om:' || pobjmodule || ', oi:' ||
				  pobjident);
			RETURN NULL;
	END;

	FUNCTION getcodebyouterid
	(
		pid           typeouterid
	   ,pcommonbranch BOOLEAN
	) RETURN NUMBER IS
	BEGIN
		RETURN getcodebyident(pid.objtype, pid.objmodule, pid.objident, pcommonbranch);
	END;

	FUNCTION getlocatorbycode(pcode NUMBER) RETURN VARCHAR IS
	BEGIN
		FOR i IN (SELECT * FROM tdynasql t WHERE t.code = pcode)
		LOOP
			RETURN i.locator;
		END LOOP;
		RETURN NULL;
	END;

	FUNCTION getcodebylocator
	(
		plocator      typelocator
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN types.arrnum IS
		vbranch NUMBER := seance.getbranch();
		vcodes  types.arrnum;
	BEGIN
		IF pcommonbranch
		THEN
			vbranch := seance.cbranch_common;
		END IF;
		SELECT code BULK COLLECT
		INTO   vcodes
		FROM   tdynasql
		WHERE  branch = vbranch
		AND    ((plocator IS NULL AND locator IS NULL) OR (locator = plocator));
		RETURN vcodes;
	END;

	FUNCTION copysql
	(
		pcode    NUMBER
	   ,premark  typeremark
	   ,plocator typelocator
	) RETURN NUMBER IS
		vcode NUMBER;
		vrec  tdynasql%ROWTYPE;
		varr  typetextarray;
	BEGIN
		IF pcode IS NULL
		THEN
			RETURN NULL;
		END IF;
	
		vrec := getsqlrec(pcode);
	
		sdummy := getsql(pcode, varr);
		vcode  := addsql(varr, nvl(premark, vrec.remark), plocator => plocator);
		RETURN vcode;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.CopySQL, fr:' || pcode || ', to:' || vcode || ', rm:' || premark);
			error.save('DynaSQL.CopySQL');
			RAISE;
	END;

	FUNCTION copysql
	(
		pfromobjtype   NUMBER
	   ,pfromobjmodule NUMBER
	   ,pfromobjident  VARCHAR
	   ,ptoobjtype     NUMBER
	   ,ptoobjmodule   NUMBER
	   ,ptoobjident    VARCHAR
	   ,premark        typeremark
	   ,plocator       typelocator
	) RETURN NUMBER IS
		vcode    NUMBER;
		vnewcode NUMBER;
		vrec     tdynasql%ROWTYPE;
		varr     typetextarray;
		vreport  CLOB;
		vupdata  CLOB;
	BEGIN
		vcode := getcodebyident(pfromobjtype, pfromobjmodule, pfromobjident);
		IF vcode IS NULL
		THEN
			RETURN NULL;
		END IF;
	
		vrec := getsqlrec(vcode);
	
		sdummy   := getsql(vcode, varr);
		vnewcode := addsql(ptoobjtype
						  ,ptoobjmodule
						  ,ptoobjident
						  ,varr
						  ,nvl(premark, vrec.remark)
						  ,plocator => plocator);
		vupdata  := objuserproperty.exportreference(pobject    => dynasql.object_name
												   ,psubobject => getsubobjectforup(pfromobjtype
																				   ,pfromobjmodule
																				   ,pfromobjident));
		IF vupdata IS NOT NULL
		   AND dbms_lob.getlength(vupdata) > 0
		THEN
			objuserproperty.importreference(pexportdata => vupdata
										   ,pobject     => dynasql.object_name
										   ,psubobject  => getsubobjectforup(ptoobjtype
																			,ptoobjmodule
																			,ptoobjident)
										   ,oreport     => vreport);
			say(vreport);
		END IF;
		objuserproperty.newrecord(pobject    => dynasql.object_name
								 ,psubobject => getsubobjectforup(ptoobjtype
																 ,ptoobjmodule
																 ,ptoobjident)
								 ,powneruid  => getobjectuid(vnewcode)
								 ,pdata      => getuserproplist(vcode));
	
		RETURN vnewcode;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.CopySQL, fr:' || pfromobjtype || ',' || pfromobjmodule || ',' ||
				  pfromobjident || ', to:' || ptoobjtype || ',' || ptoobjmodule || ',' ||
				  ptoobjident || ', rm:' || premark);
			error.save('DynaSQL.CopySQL');
			RAISE;
	END;

	PROCEDURE copysql
	(
		pfromobjtype   NUMBER
	   ,pfromobjmodule NUMBER
	   ,pfromobjident  VARCHAR
	   ,ptoobjtype     NUMBER
	   ,ptoobjmodule   NUMBER
	   ,ptoobjident    VARCHAR
	   ,premark        typeremark
	   ,plocator       typelocator
	) IS
	BEGIN
		sdummy := copysql(pfromobjtype
						 ,pfromobjmodule
						 ,pfromobjident
						 ,ptoobjtype
						 ,ptoobjmodule
						 ,ptoobjident
						 ,premark
						 ,plocator => plocator);
	END;

	FUNCTION importfile
	(
		pfile   VARCHAR
	   ,pcode   NUMBER
	   ,pencode VARCHAR
	) RETURN NUMBER IS
		vhand  NUMBER;
		vbuff  VARCHAR(512);
		vcount NUMBER := 0;
	BEGIN
		SAVEPOINT sp_importfile;
		vhand := term.fileopenread(pfile, penc => pencode);
	
		deltextlines(pcode);
		WHILE term.readrecord(vhand, vbuff)
		LOOP
			vcount := vcount + 1;
			addtextline(pcode, vcount, normalize(vbuff));
		END LOOP;
	
		term.close(vhand);
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.ImportFile (DB)');
			term.closeabort(vhand);
			ROLLBACK TO sp_importfile;
			RAISE;
	END;

	PROCEDURE topackagedebug
	(
		pwhere VARCHAR2
	   ,ptext  VARCHAR2 := NULL
	) IS
		climit CONSTANT NUMBER := 1000;
		vstr VARCHAR2(climit);
	BEGIN
	
		vstr := pwhere;
		IF (ptext IS NOT NULL)
		THEN
			vstr := vstr || ' | ' || ptext;
		END IF;
		s.say(vstr);
	
	EXCEPTION
		WHEN OTHERS THEN
			IF (SQLCODE != -6502)
			THEN
				RAISE;
			ELSE
				topackagedebug(pwhere, substr(ptext, climit));
			END IF;
	END;

	PROCEDURE topackagedebug
	(
		pwhere VARCHAR2
	   ,pid    typeouterid
	) IS
	BEGIN
		topackagedebug(pwhere, 'objType   = ' || pid.objtype);
		topackagedebug(pwhere, 'objModule = ' || pid.objmodule);
		topackagedebug(pwhere, 'objIdent  = ' || pid.objident);
	END;

	FUNCTION toouterid
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	   ,pobjident  VARCHAR
	) RETURN typeouterid IS
		vid typeouterid;
	BEGIN
		vid.objtype   := pobjtype;
		vid.objmodule := pobjmodule;
		vid.objident  := pobjident;
	
		RETURN vid;
	END;

	FUNCTION getouterid(pcode IN NUMBER) RETURN typeouterid IS
		vsql typesqlrec;
	BEGIN
		vsql := getsqlrec(pcode);
		RETURN toouterid(vsql.objtype, vsql.objmodule, vsql.objident);
	END;

	FUNCTION isnotnullandgreaterthanzero(pvalue CLOB) RETURN BOOLEAN IS
	BEGIN
		RETURN pvalue IS NOT NULL AND dbms_lob.getlength(pvalue) > 0;
	END;

	FUNCTION isouteridnotnull(pid typeouterid) RETURN BOOLEAN IS
	BEGIN
		RETURN pid.objtype IS NOT NULL;
	END;

	FUNCTION isouteridnull(pid typeouterid) RETURN BOOLEAN IS
	BEGIN
		RETURN pid.objtype IS NULL;
	END;

	FUNCTION toxmltype(pvalue CLOB) RETURN xmltype IS
		cwhere CONSTANT VARCHAR2(100) := cpackage || '.toXmlType';
	BEGIN
		IF isnotnullandgreaterthanzero(pvalue)
		THEN
			RETURN xmltype(pvalue);
		ELSE
			RETURN NULL;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION exportsql
	(
		pcode         IN NUMBER
	   ,pcommonbranch BOOLEAN
	   ,pouterid      IN typeouterid
	) RETURN CLOB IS
		cwhere CONSTANT VARCHAR2(100) := cpackage || '.exportSQL';
		vupdata  CLOB;
		vupref   CLOB;
		vsql     CLOB;
		vlocator typelocator;
		vouterid typeouterid;
	
		PROCEDURE todebug(ptext VARCHAR2) IS
		BEGIN
			topackagedebug(cwhere, ptext);
		END;
	
		PROCEDURE todebug(pid typeouterid) IS
		BEGIN
			topackagedebug(cwhere, pid);
		END;
	
		FUNCTION getuserpropref RETURN CLOB IS
		BEGIN
			RETURN objuserproperty.exportreference(pobject       => dynasql.object_name
												  ,psubobject    => getsubobjectforup(vouterid.objtype
																					 ,vouterid.objmodule
																					 ,vouterid.objident)
												  ,pcommonbranch => pcommonbranch);
		END;
	
		FUNCTION getuserprop RETURN CLOB IS
		BEGIN
			RETURN objuserproperty.packproplist(getuserproplist(pcode));
		END;
	
		FUNCTION getxmltoexport RETURN xmltype IS
			vupref_x  xmltype;
			vupdata_x xmltype;
			vres      xmltype;
			vremark   typeremark;
		BEGIN
			vupref_x  := toxmltype(vupref);
			vupdata_x := toxmltype(vupdata);
			vremark   := getsqlrec(pcode).remark;
		
			SELECT xmlelement("DYNASQL"
							  ,xmlattributes(vouterid.objtype AS "ObjType"
											,vouterid.objmodule AS "ObjModule"
											,vouterid.objident AS "ObjIdent"
											,vlocator AS "Locator"
											,pcode AS "Code"
											,vremark AS "Remark")
							  ,xmlforest(vsql AS "SQL"
										,vupref_x AS "UserPropReference"
										,vupdata_x AS "UserPropData"))
			INTO   vres
			FROM   dual;
			RETURN vres;
		END;
	BEGIN
	
		IF pcode IS NULL
		THEN
			error.raiseerror(err.ue_value_notdefined, 'pCode is null');
		END IF;
	
		todebug('pCode = ' || pcode || ', pCommonBranch = ' || htools.b2s(pcommonbranch));
	
		IF (isouteridnotnull(pouterid))
		THEN
			vouterid := pouterid;
		ELSE
			vouterid := getouterid(pcode);
		END IF;
	
		IF (isouteridnotnull(vouterid))
		THEN
			todebug(vouterid);
		END IF;
	
		vsql     := getsql(pcode);
		vupref   := getuserpropref();
		vupdata  := getuserprop();
		vlocator := getlocatorbycode(pcode);
	
		RETURN getxmltoexport().getclobval();
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION exportsql
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,pcommonbranch BOOLEAN
	) RETURN CLOB IS
		cwhere CONSTANT VARCHAR2(100) := cpackage || '.exportSQL';
		vouterid typeouterid;
		vcode    NUMBER;
	BEGIN
	
		vouterid := toouterid(pobjtype, pobjmodule, pobjident);
	
		vcode := getcodebyouterid(vouterid, pcommonbranch);
		IF vcode IS NULL
		THEN
			s.say(cwhere || ' : SQl Code is not exists. Return nullable export data.');
			RETURN NULL;
		END IF;
	
		RETURN exportsql(vcode, pcommonbranch, vouterid);
	
	EXCEPTION
		WHEN OTHERS THEN
			topackagedebug(cwhere, vouterid);
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE importsql
	(
		pdata         CLOB
	   ,pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,pcommonbranch BOOLEAN
	   ,plocator      typelocator
	) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.importSQL(' || pobjident || ', ' ||
											pobjmodule || ', ' || pobjident || ')';
		vxml        xmltype;
		vupdata     CLOB;
		vupref      CLOB;
		vupdata_x   xmltype := NULL;
		vupref_x    xmltype := NULL;
		vsql        CLOB;
		vreport     CLOB;
		vcode       NUMBER;
		voldsupport BOOLEAN := FALSE;
	BEGIN
		s.say(cprocname || ' : start');
		IF pdata IS NULL
		   OR dbms_lob.getlength(pdata) = 0
		THEN
			s.say('No data for import.');
			COMMIT;
			RETURN;
		END IF;
		BEGIN
			vxml := xmltype(pdata);
		EXCEPTION
			WHEN OTHERS THEN
				IF SQLCODE = -31011
				THEN
					s.say(cprocname || ' parse input data' ||
						  ' : It`s not xml - import old sql as text.');
					vsql        := pdata;
					voldsupport := TRUE;
				ELSE
					error.save(cprocname || '.parse xml');
					RAISE;
				END IF;
		END;
	
		IF voldsupport
		THEN
			s.say('import sql (old) ...');
			vcode := getcodebyident(pobjtype, pobjmodule, pobjident, pcommonbranch);
			IF vcode IS NULL
			THEN
				vcode := addsql(pobjtype
							   ,pobjmodule
							   ,pobjident
							   ,vsql
							   ,'Import'
							   ,pcommonbranch
							   ,plocator => plocator);
			ELSE
				s.say(' sql already exists, update...');
				putsql(vcode, vsql);
			
				IF TRIM(plocator) IS NOT NULL
				THEN
					setlocator(vcode, plocator);
				END IF;
			
			END IF;
			COMMIT;
			RETURN;
		END IF;
	
		IF vxml.existsnode('/DYNASQL') != 1
		THEN
			error.raiseerror(err.ue_value_incorrect, 'Invalid data for script import.');
		END IF;
		vsql     := custom_xmltools.getlvalue(vxml, '/DYNASQL/SQL');
		vupref_x := vxml.extract('/DYNASQL/UserPropReference/*');
		IF vupref_x IS NOT NULL
		THEN
			vupref := vxml.extract('/DYNASQL/UserPropReference/*').getclobval();
		END IF;
		vupdata_x := vxml.extract('/DYNASQL/UserPropData/*');
		IF vupdata_x IS NOT NULL
		THEN
			vupdata := vupdata_x.getclobval();
		END IF;
	
		s.say('import sql ...');
		vcode := getcodebyident(pobjtype, pobjmodule, pobjident, pcommonbranch);
		IF vcode IS NULL
		THEN
			vcode := addsql(pobjtype
						   ,pobjmodule
						   ,pobjident
						   ,vsql
						   ,'Import'
						   ,pcommonbranch
						   ,plocator => plocator);
		ELSE
			s.say(' sql already exists, update...');
			putsql(vcode, vsql);
		
			IF TRIM(plocator) IS NOT NULL
			THEN
				setlocator(vcode, plocator);
			END IF;
		
		END IF;
	
		s.say('import userprop ref ...');
		IF vupref IS NOT NULL
		THEN
			s.say(' ImportReference start ...');
			objuserproperty.importreference(pexportdata   => vupref
										   ,pobject       => dynasql.object_name
										   ,psubobject    => getsubobjectforup(pobjtype
																			  ,pobjmodule
																			  ,pobjident)
										   ,oreport       => vreport
										   ,pcommonbranch => pcommonbranch
										   ,pimportmode   => objuserproperty.cimportmode_full);
			say(vreport);
		
			IF dbms_lob.getlength(vupdata) > 0
			THEN
				s.say('import userprop value ...');
				setuserproplist(vcode, objuserproperty.unpackproplist(vupdata));
			END IF;
		
		END IF;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			ROLLBACK;
			RAISE;
	END;

	FUNCTION islocatornotnull(plocator typelocator) RETURN BOOLEAN IS
	BEGIN
		RETURN TRIM(plocator) IS NOT NULL;
	END;

	FUNCTION islocatornull(plocator typelocator) RETURN BOOLEAN IS
	BEGIN
		RETURN TRIM(plocator) IS NULL;
	END;

	FUNCTION isremarknotnull(premark typeremark) RETURN BOOLEAN IS
	BEGIN
		RETURN TRIM(premark) IS NOT NULL;
	END;

	FUNCTION isnodeexist
	(
		pxml xmltype
	   ,ptag VARCHAR2
	) RETURN BOOLEAN IS
	BEGIN
		RETURN pxml.existsnode(ptag) = 1;
	END;

	FUNCTION importsql__
	(
		pdata         CLOB
	   ,pouterid      typeouterid
	   ,pcommonbranch BOOLEAN
	   ,plocator      typelocator
	   ,premark       typeremark
	   ,pcode         NUMBER := NULL
	) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackage || '.importBlock';
		vcode NUMBER;
	
		PROCEDURE todebug(ptext VARCHAR2) IS
		BEGIN
			topackagedebug(cwhere, ptext);
		END;
	
	BEGIN
		vcode := pcode;
	
		IF (vcode IS NULL AND isouteridnull(pouterid))
		THEN
			todebug('The dynaSql-block is not found, the outer id is null - it will be created');
			vcode := addsql(pdata, premark, plocator);
		ELSIF (vcode IS NULL)
		THEN
			todebug('The dynaSql-block is not found, it will be created with the outer id');
			vcode := addsql(pouterid, pdata, premark, pcommonbranch, plocator);
		ELSE
		
			IF (isexistingcode(vcode))
			THEN
				todebug('The dynaSql-block with the code ' || vcode ||
						' is found, it will be updated');
			
				putsql(vcode, pdata);
			
				IF (isouteridnotnull(pouterid))
				THEN
					todebug('The outerId will be updated');
					setouterid(vcode, pouterid);
				END IF;
			
				IF (isremarknotnull(premark))
				THEN
					todebug('The remark will be updated');
					putremark(vcode, premark);
				END IF;
			
				IF (islocatornotnull(plocator))
				THEN
					todebug('The locator will be updated');
					setlocator(vcode, plocator);
				END IF;
			
			ELSE
			
				IF (isouteridnull(pouterid))
				THEN
					todebug('The dynaSql-block with the code ' || vcode ||
							' is not found, the outer id is null, it will be created');
					vcode := addsql(pdata, premark, plocator);
				ELSE
					todebug('The dynaSql-block with the code ' || vcode ||
							' is not found, it will be created with the outer id');
					vcode := addsql(pouterid, pdata, premark, pcommonbranch, plocator);
				END IF;
			END IF;
		
		END IF;
	
		RETURN vcode;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION toxml(pdata CLOB) RETURN xmltype IS
	BEGIN
		RETURN xmltype(pdata);
	END;

	FUNCTION getattrvalue
	(
		pxml      xmltype
	   ,pattrname VARCHAR2
	) RETURN VARCHAR2 IS
	BEGIN
		RETURN custom_xmltools.getatrvalue(pxml, cmainnode, patrname => pattrname);
	END;

	FUNCTION lookforouterid(pxml xmltype) RETURN typeouterid IS
		vid typeouterid;
	BEGIN
		vid.objtype   := getattrvalue(pxml, cobjtypeattr);
		vid.objmodule := getattrvalue(pxml, cobjmoduleattr);
		vid.objident  := getattrvalue(pxml, cobjidentattr);
		RETURN vid;
	END;

	FUNCTION lookforcode(pxml xmltype) RETURN typecode IS
	BEGIN
		RETURN getattrvalue(pxml, ccodeattr);
	END;

	FUNCTION lookforouteridandcode(pdata xmltype) RETURN typemetadata IS
		cwhere CONSTANT VARCHAR2(100) := cpackage || '.lookForOuterIdAndCode';
		vmetadata typemetadata;
	BEGIN
		vmetadata.outerid := lookforouterid(pdata);
		vmetadata.code    := lookforcode(pdata);
	
		RETURN vmetadata;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE importsql_
	(
		pdata         CLOB
	   ,pcommonbranch BOOLEAN
	   ,poblockcode   IN OUT NOCOPY NUMBER
	   ,pouterid      typeouterid
	   ,plocator      typelocator
	   ,premark       typeremark
	) IS
		cwhere            CONSTANT VARCHAR(1000) := cpackage || '.importSQL_';
		csqlnode          CONSTANT VARCHAR2(100) := cmainnode || '/SQL';
		cuserproprefnode  CONSTANT VARCHAR2(100) := cmainnode || '/UserPropReference';
		cuserpropdatanode CONSTANT VARCHAR2(100) := cmainnode || '/UserPropData';
		callchildsnodes   CONSTANT VARCHAR2(100) := '/*';
		clocator          CONSTANT VARCHAR2(100) := 'Locator';
		cremark           CONSTANT VARCHAR2(100) := 'Remark';
	
		vxml     xmltype;
		vupdata  CLOB;
		vupref   CLOB;
		vsql     CLOB;
		vreport  CLOB;
		vcode    NUMBER;
		vouterid typeouterid;
		vlocator typelocator;
		vremark  typeremark;
	
		PROCEDURE todebug(ptext VARCHAR2) IS
		BEGIN
			topackagedebug(cwhere, ptext);
		END;
	
		PROCEDURE todebug(pid typeouterid) IS
		BEGIN
			topackagedebug(cwhere, pid);
		END;
	
		FUNCTION isnotxml(pdata CLOB) RETURN BOOLEAN IS
			vtmp xmltype;
		BEGIN
			vtmp := toxml(pdata);
			RETURN FALSE;
		
		EXCEPTION
			WHEN OTHERS THEN
				RETURN TRUE;
		END;
	
		PROCEDURE toxmlandsetdata(pdata CLOB) IS
		BEGIN
			vxml := toxml(pdata);
		END;
	
		FUNCTION gettagvalue(ppath VARCHAR2) RETURN CLOB IS
			vret CLOB;
		BEGIN
			IF ppath = csqlnode
			THEN
				vret := custom_xmltools.getlvalue(vxml, ppath);
			ELSIF (ppath IN (cuserproprefnode, cuserpropdatanode))
			THEN
				IF (isnodeexist(vxml, ppath))
				THEN
					vret := custom_xmltools.getlvalues(vxml, ppath || callchildsnodes);
				END IF;
			END IF;
		
			RETURN vret;
		END;
	
		FUNCTION getlocator RETURN VARCHAR2 IS
		BEGIN
			RETURN getattrvalue(vxml, clocator);
		END;
	
		FUNCTION getremark RETURN typeremark IS
		BEGIN
			RETURN getattrvalue(vxml, cremark);
		END;
	
		FUNCTION getsql RETURN CLOB IS
		BEGIN
			RETURN gettagvalue(csqlnode);
		END;
	
		FUNCTION getuserpropref RETURN CLOB IS
		BEGIN
			RETURN gettagvalue(cuserproprefnode);
		END;
	
		FUNCTION getuserpropdata RETURN CLOB IS
		BEGIN
			RETURN gettagvalue(cuserpropdatanode);
		END;
	
		FUNCTION isnotdynasqldata RETURN BOOLEAN IS
		BEGIN
			RETURN NOT isnodeexist(vxml, cmainnode);
		END;
	
		PROCEDURE importuserpropref IS
		BEGIN
			objuserproperty.importreference(pexportdata   => vupref
										   ,pobject       => dynasql.object_name
										   ,psubobject    => getsubobjectforup(vouterid.objtype
																			  ,vouterid.objmodule
																			  ,vouterid.objident)
										   ,oreport       => vreport
										   ,pcommonbranch => pcommonbranch
										   ,pimportmode   => objuserproperty.cimportmode_full);
		END;
	
		PROCEDURE importuserprop IS
		BEGIN
			setuserproplist(vcode, objuserproperty.unpackproplist(vupdata));
		END;
	
		FUNCTION arenotequal
		(
			pcodefromprm   NUMBER
		   ,pcodebyouterid NUMBER
		) RETURN BOOLEAN IS
			cwherein CONSTANT VARCHAR2(100) := 'areNotEqual';
		BEGIN
			todebug(cwherein || ' | pCodeFromPrm = ' || pcodefromprm || ', pCodeByOuterId = ' ||
					pcodebyouterid);
			IF (pcodefromprm IS NOT NULL AND pcodebyouterid IS NOT NULL)
			THEN
				RETURN pcodefromprm != pcodebyouterid;
			ELSE
				RETURN FALSE;
			END IF;
		END;
	
	BEGIN
		IF (NOT isnotnullandgreaterthanzero(pdata))
		THEN
			todebug('No data to import');
			RETURN;
		END IF;
	
		todebug('before processing: ' || 'code = ' || poblockcode || ', locator = ' || plocator ||
				', remark = ' || premark || ', commonBranch = ' || htools.b2s(pcommonbranch));
		todebug(pouterid);
	
		vouterid := pouterid;
	
		IF (isnotxml(pdata))
		THEN
			poblockcode := importsql__(pdata
									  ,vouterid
									  ,pcommonbranch
									  ,plocator
									  ,premark
									  ,pcode => getcodebyouterid(vouterid, pcommonbranch));
			RETURN;
		ELSE
			toxmlandsetdata(pdata);
		END IF;
	
		IF (isnotdynasqldata())
		THEN
			error.raiseerror(err.ue_value_incorrect, 'Script contains no data for import');
		END IF;
	
		IF (isouteridnull(vouterid))
		THEN
			vouterid := lookforouterid(vxml);
			IF (isouteridnotnull(vouterid))
			THEN
				vlocator := getlocator();
			END IF;
		END IF;
	
		vlocator := coalesce(vlocator, plocator);
		vremark  := coalesce(premark, getremark());
	
		IF (isouteridnotnull(vouterid))
		THEN
			vcode := getcodebyouterid(vouterid, pcommonbranch);
			IF (arenotequal(poblockcode, vcode))
			THEN
				error.raiseerror(err.ue_value_incorrect
								,'Detected conflict between code of block found by external ID and parameter code');
			END IF;
		ELSE
			vcode := poblockcode;
		END IF;
	
		vcode := coalesce(vcode, poblockcode);
	
		vsql    := getsql();
		vupref  := getuserpropref();
		vupdata := getuserpropdata();
	
		todebug('after processing : code = ' || vcode || ', locator = ' || vlocator ||
				', remark = ' || vremark);
		todebug(vouterid);
	
		vcode := importsql__(vsql, vouterid, pcommonbranch, vlocator, vremark, pcode => vcode);
	
		IF isnotnullandgreaterthanzero(vupref)
		THEN
			importuserpropref();
			todebug(vreport);
		
			IF isnotnullandgreaterthanzero(vupdata)
			THEN
				importuserprop();
			END IF;
		END IF;
	
		poblockcode := vcode;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE importsql_autonomous
	(
		pdata         CLOB
	   ,pcommonbranch BOOLEAN
	   ,poblockcode   IN OUT NOCOPY NUMBER
	   ,pouterid      typeouterid
	   ,plocator      typelocator
	   ,premark       typeremark
	) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cwhere CONSTANT VARCHAR2(100) := cpackage || '.importSQL_autonomous';
	BEGIN
		importsql_(pdata, pcommonbranch, poblockcode, pouterid, plocator, premark);
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			ROLLBACK;
			RAISE;
	END;

	PROCEDURE importsql
	(
		pdata                  CLOB
	   ,pcommonbranch          BOOLEAN
	   ,poblockcode            IN OUT NOCOPY NUMBER
	   ,pouterid               typeouterid
	   ,plocator               typelocator
	   ,premark                typeremark
	   ,pautonomoustransaction BOOLEAN
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackage || '.importSQL';
	BEGIN
		CASE pautonomoustransaction
			WHEN TRUE THEN
				importsql_autonomous(pdata
									,pcommonbranch
									,poblockcode
									,pouterid
									,plocator
									,premark);
			WHEN FALSE THEN
				importsql_(pdata, pcommonbranch, poblockcode, pouterid, plocator, premark);
		END CASE;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION exportfile
	(
		pfile   VARCHAR
	   ,pcode   NUMBER
	   ,pencode VARCHAR
	) RETURN NUMBER IS
		vhand  NUMBER;
		vcount NUMBER;
		VARRAY typetextarray;
	BEGIN
		vhand  := term.fileopenwrite(pfile, penc => pencode);
		vcount := getsql(pcode, VARRAY);
		FOR i IN 1 .. vcount
		LOOP
			term.writerecord(vhand, VARRAY(i));
		END LOOP;
		term.close(vhand);
	
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.ExportFile (DB)');
			term.closeabort(vhand);
			RAISE;
	END;

	FUNCTION importfile
	(
		pfile   VARCHAR
	   ,parray  IN OUT typetextarray
	   ,pencode VARCHAR
	) RETURN NUMBER IS
		vhand  NUMBER;
		vbuff  VARCHAR(512);
		vcount NUMBER := 0;
	BEGIN
		parray.delete();
	
		vhand := term.fileopenread(pfile, penc => pencode);
	
		WHILE term.readrecord(vhand, vbuff)
		LOOP
			vcount := vcount + 1;
			parray(vcount) := normalize(vbuff);
		END LOOP;
	
		term.close(vhand);
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.ImportFile (Array)');
			term.closeabort(vhand);
			RAISE;
	END;

	FUNCTION exportfile
	(
		pfile   VARCHAR
	   ,parray  IN OUT typetextarray
	   ,pencode VARCHAR
	) RETURN NUMBER IS
		vhand  NUMBER;
		vcount NUMBER;
	BEGIN
		vhand  := term.fileopenwrite(pfile, penc => pencode);
		vcount := parray.count();
		FOR i IN 1 .. vcount
		LOOP
			term.writerecord(vhand, parray(i));
		END LOOP;
		term.close(vhand);
	
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.ExportFile (Array)');
			term.closeabort(vhand);
			RAISE;
	END;

	FUNCTION importfile
	(
		pfile   VARCHAR
	   ,pencode VARCHAR
	) RETURN CLOB IS
		vhand  NUMBER;
		vbuff  VARCHAR(512);
		VARRAY typetextarray;
		vcount NUMBER := 0;
	BEGIN
		vhand := term.fileopenread(pfile, penc => pencode);
	
		WHILE term.readrecord(vhand, vbuff)
		LOOP
			vcount := vcount + 1;
			VARRAY(vcount) := normalize(vbuff);
		END LOOP;
	
		term.close(vhand);
		RETURN array2text(VARRAY);
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.ImportFile (clob)');
			term.closeabort(vhand);
			RAISE;
	END;

	FUNCTION exportfile
	(
		pfile   VARCHAR
	   ,pstr    VARCHAR
	   ,pencode VARCHAR
	) RETURN NUMBER IS
		vhand  NUMBER;
		vcount NUMBER;
		VARRAY typetextarray;
	BEGIN
		vhand  := term.fileopenwrite(pfile, penc => pencode);
		VARRAY := text2array(pstr);
	
		vcount := varray.count();
		FOR i IN 1 .. vcount
		LOOP
			term.writerecord(vhand, VARRAY(i));
		END LOOP;
		term.close(vhand);
	
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.ExportFile (char)');
			term.closeabort(vhand);
			RAISE;
	END;

	FUNCTION exportfile
	(
		pfile   VARCHAR
	   ,ptext   CLOB
	   ,pencode VARCHAR
	) RETURN NUMBER IS
		vhand  NUMBER;
		vcount NUMBER;
		VARRAY typetextarray;
	BEGIN
		vhand  := term.fileopenwrite(pfile, penc => pencode);
		VARRAY := text2array(ptext);
	
		vcount := varray.count();
		FOR i IN 1 .. vcount
		LOOP
			term.writerecord(vhand, VARRAY(i));
		END LOOP;
		term.close(vhand);
	
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.ExportFile (clob)');
			term.closeabort(vhand);
			RAISE;
	END;

	PROCEDURE initenv
	(
		prec            typecacherec
	   ,pparamsourceuid objectuid.typeobjectuid
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.initEnv(' || prec.objtype || '_' ||
											prec.objmodule || '_' || prec.objident || ',paramuid=' ||
											pparamsourceuid || ')';
	BEGIN
		s.say(cprocname || ' : start');
		IF nvl(scurruncode != prec.code, TRUE)
		THEN
			s_arrenv(prec.code).prevcode := scurruncode;
		END IF;
		scurruncode := prec.code;
	
		IF s_arrenv.exists(prec.code)
		   AND s_arrenv(prec.code).paramsourceuid = nvl(pparamsourceuid, prec.owneruid)
		THEN
			NULL;
		ELSE
			s_arrenv(prec.code).paramsourceuid := nvl(pparamsourceuid, prec.owneruid);
			s_arrenv(prec.code).params.delete;
			IF s_arrenv(prec.code).paramsourceuid IS NOT NULL
			THEN
				s_arrenv(prec.code).params := getuserproplist(prec.code
															 ,s_arrenv(prec.code).paramsourceuid);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackage || '.initEnv()');
			RAISE;
	END;

	PROCEDURE freeenv(prec typecacherec) IS
	BEGIN
		IF s_arrenv.exists(prec.code)
		THEN
			scurruncode := s_arrenv(prec.code).prevcode;
			s_arrenv.delete(prec.code);
		END IF;
	END;

	PROCEDURE runclear IS
	BEGIN
		clearcache(NULL, NULL);
	END;

	PROCEDURE runclear
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	) IS
	BEGIN
		clearcache(pobjtype, pobjmodule);
	END;

	PROCEDURE runone
	(
		pcode                NUMBER
	   ,pexception           BOOLEAN
	   ,pusecommitcontrol    BOOLEAN
	   ,pparamsourceuid      objectuid.typeobjectuid := NULL
	   ,pcursortxttodbgifexc BOOLEAN
	) IS
		vrec typecacherec;
	
	BEGIN
		vrec := COMPILE(pcode);
		initenv(vrec, pparamsourceuid);
		runrun(vrec, pusecommitcontrol, pcursortxttodbgifexc);
		freeenv(vrec);
		closerun(vrec.run);
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.RunOne1');
			closerun(vrec.run);
			IF NOT pexception
			THEN
				error.clear();
				err.seterror(SQLCODE, 'DynaSQL.RunOne1');
			ELSE
				RAISE;
			END IF;
	END;

	PROCEDURE setisrunning
	(
		porec        IN OUT typecacherec
	   ,pisrunning   IN BOOLEAN
	   ,pupdatecache IN BOOLEAN := FALSE
	   ,pexception   IN BOOLEAN := TRUE
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackage || '.SetIsRunning';
	BEGIN
		IF (porec.code IS NULL)
		THEN
			RETURN;
		END IF;
	
		IF (porec.isrunning != pisrunning)
		THEN
			porec.isrunning := pisrunning;
			s.say(cwhere || ' | Code = ' || porec.code || ', isRunning = ' ||
				  htools.b2s(porec.isrunning));
		
			IF pupdatecache
			THEN
				s.say(cwhere || ' | Updating the cache!');
				updatecache(porec.code, porec);
			END IF;
		
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			IF (pexception)
			THEN
				error.save(cwhere);
				RAISE;
			END IF;
	END;

	PROCEDURE runbatch
	(
		pcode                NUMBER
	   ,pexception           BOOLEAN
	   ,pusecommitcontrol    BOOLEAN
	   ,pparamsourceuid      objectuid.typeobjectuid := NULL
	   ,pcursortxttodbgifexc BOOLEAN
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackage || '.RunBatch_proc';
		vrec typecacherec;
	BEGIN
		vrec := getcache(pcode);
	
		IF vrec.run IS NULL
		THEN
			vrec := COMPILE(pcode);
			setisrunning(vrec, TRUE);
			putcache(pcode, vrec);
		ELSIF vrec.isrunning
		THEN
			s.say(cwhere || ' | The script (code = ' || pcode ||
				  ') is running - create new cursor!');
			vrec := COMPILE(pcode);
		ELSE
			setisrunning(vrec, TRUE, pupdatecache => TRUE);
		END IF;
	
		initenv(vrec, pparamsourceuid);
		runrun(vrec, pusecommitcontrol, pcursortxttodbgifexc);
	
		IF (NOT vrec.isrunning)
		THEN
			closerun(vrec.run);
		END IF;
	
		setisrunning(vrec, FALSE, pupdatecache => TRUE);
	
	EXCEPTION
		WHEN OTHERS THEN
		
			BEGIN
				IF (NOT vrec.isrunning)
				THEN
					closerun(vrec.run);
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		
			setisrunning(vrec, FALSE, pupdatecache => TRUE, pexception => FALSE);
		
			IF NOT pexception
			THEN
				error.clear();
				err.seterror(SQLCODE, cwhere);
			ELSE
				RAISE;
			END IF;
	END;

	FUNCTION runone
	(
		pcode                NUMBER
	   ,pexception           BOOLEAN
	   ,pretval              NUMBER
	   ,pusecommitcontrol    BOOLEAN
	   ,pparamsourceuid      objectuid.typeobjectuid := NULL
	   ,pcursortxttodbgifexc BOOLEAN
	) RETURN NUMBER IS
		vrec typecacherec;
		vret NUMBER;
	BEGIN
		vrec := COMPILE(pcode);
		initenv(vrec, pparamsourceuid);
		vret := runrun(vrec, pretval, pusecommitcontrol, pcursortxttodbgifexc);
		freeenv(vrec);
		closerun(vrec.run);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('DynaSQL.RunOne');
			closerun(vrec.run);
			IF NOT pexception
			THEN
				error.clear();
				err.seterror(SQLCODE, 'DynaSQL.RunOne');
				RETURN - 1;
			ELSE
				RAISE;
			END IF;
	END;

	FUNCTION runbatch
	(
		pcode                NUMBER
	   ,pexception           BOOLEAN
	   ,pretval              NUMBER
	   ,pusecommitcontrol    BOOLEAN
	   ,pparamsourceuid      objectuid.typeobjectuid := NULL
	   ,pcursortxttodbgifexc BOOLEAN
	) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackage || '.RunBatch_func';
		vrec typecacherec;
		vret NUMBER;
	BEGIN
		vrec := getcache(pcode);
	
		IF vrec.run IS NULL
		THEN
			vrec := COMPILE(pcode);
			setisrunning(vrec, TRUE);
			putcache(pcode, vrec);
		ELSIF vrec.isrunning
		THEN
			s.say(cwhere || ' | The script (code = ' || pcode ||
				  ') is running - create new cursor!');
			vrec := COMPILE(pcode);
		ELSE
			setisrunning(vrec, TRUE, pupdatecache => TRUE);
		END IF;
	
		initenv(vrec, pparamsourceuid);
		vret := runrun(vrec, pretval, pusecommitcontrol, pcursortxttodbgifexc);
	
		IF (NOT vrec.isrunning)
		THEN
			closerun(vrec.run);
		END IF;
	
		setisrunning(vrec, FALSE, pupdatecache => TRUE);
	
		RETURN vret;
	
	EXCEPTION
		WHEN OTHERS THEN
		
			BEGIN
				IF (NOT vrec.isrunning)
				THEN
					closerun(vrec.run);
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		
			setisrunning(vrec, FALSE, pupdatecache => TRUE, pexception => FALSE);
		
			IF NOT pexception
			THEN
				error.clear();
				err.seterror(SQLCODE, 'DynaSQL.RunBatch');
				RETURN - 1;
			ELSE
				RAISE;
			END IF;
	END;

	FUNCTION parseone(pcode NUMBER) RETURN NUMBER IS
	BEGIN
		RETURN COMPILE(pcode).run;
	END;

	PROCEDURE testsql(ptext VARCHAR) IS
	BEGIN
		testsql(text2array(ptext));
	END;

	PROCEDURE testsql(ptext CLOB) IS
	BEGIN
		testsql(text2array(ptext));
	END;

	PROCEDURE testsql(parray typetextarray) IS
		vcur NUMBER;
	BEGIN
		IF parray.count() > 0
		THEN
			vcur := compileonly(parray);
			closerun(vcur);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.TestSQL');
			RAISE;
	END;

	FUNCTION normalize(ptext IN VARCHAR) RETURN VARCHAR IS
	BEGIN
		RETURN REPLACE(REPLACE(ptext, chr(9), ' '), chr(13));
	END;

	PROCEDURE addtextline
	(
		pcode NUMBER
	   ,pline NUMBER
	   ,ptext VARCHAR
	) IS
	BEGIN
	
		INSERT INTO tdynasqlsource
			(code
			,line
			,text)
		VALUES
			(pcode
			,pline
			,ptext);
	
	END;

	PROCEDURE deltextlines(pcode NUMBER) IS
	BEGIN
	
		DELETE FROM tdynasqlsource WHERE code = pcode;
	END;

	PROCEDURE delsqlrec(pcode NUMBER) IS
		vid     objectuid.typeobjectuid;
		vsubobj VARCHAR(1000) := getsubobjectforup(pcode);
	BEGIN
	
		DELETE FROM tdynasql WHERE code = pcode RETURNING objectuid INTO vid;
		objuserproperty.deleterecord(dynasql.object_name, vid, vsubobj);
		IF vid IS NOT NULL
		THEN
			objectuid.freeuid(vid);
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cpackage || '.DelSQLRec: some error occured: ' || SQLERRM());
		
	END;

	FUNCTION getsqlrec(pcode NUMBER) RETURN typesqlrec IS
		vrec typesqlrec;
	BEGIN
		SELECT * INTO vrec FROM tdynasql WHERE code = pcode;
		RETURN vrec;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.GetSQLRec, ' || pcode);
			RAISE;
	END;

	PROCEDURE putsqlrec
	(
		pcode   NUMBER
	   ,premark typeremark
	) IS
	BEGIN
		SAVEPOINT sp_putsqlrec;
	
		UPDATE tdynasql SET remark = premark WHERE code = pcode;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.PutSQLRec, ' || pcode || ',' || premark);
			ROLLBACK TO sp_putsqlrec;
			RAISE;
	END;

	FUNCTION array2text(parray typetextarray) RETURN CLOB IS
		vtext CLOB := '';
	BEGIN
		FOR i IN 1 .. parray.count()
		LOOP
			IF i > 1
			THEN
				vtext := vtext || nl || parray(i);
			ELSE
				vtext := vtext || parray(i);
			END IF;
		END LOOP;
		IF length(vtext) <= 0
		THEN
			vtext := NULL;
		END IF;
		RETURN vtext;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSql.Array2Text');
			error.save('DynaSql.Array2Text');
			RAISE;
	END;

	FUNCTION text2array(ptext VARCHAR2) RETURN typetextarray IS
		VARRAY typetextarray;
		vpos   NUMBER;
		vold   NUMBER := 1;
		vcount NUMBER := 0;
		vtext  VARCHAR(32000);
	BEGIN
		vtext := normalize(ptext);
		WHILE vtext IS NOT NULL
		LOOP
			vpos   := instr(vtext, nl, vold, 1);
			vcount := vcount + 1;
		
			IF vpos = 0
			THEN
				IF length(vtext) > 0
				THEN
					VARRAY(vcount) := substr(vtext, vold);
				END IF;
				EXIT;
			END IF;
		
			VARRAY(vcount) := substr(vtext, vold, vpos - vold);
			vold := vpos + length(nl);
		END LOOP;
		RETURN VARRAY;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSql.Text2Array');
			error.save('DynaSql.Text2Array');
			RAISE;
	END;

	FUNCTION text2array(ptext CLOB) RETURN typetextarray IS
		cprocname CONSTANT VARCHAR(1000) := 'DynaSQL.DynaSQL[clob]';
		VARRAY typetextarray;
		vpos   NUMBER;
		vold   NUMBER := 0;
		vcount NUMBER := 0;
		vtext  CLOB;
		vlen   NUMBER;
		k      NUMBER;
	BEGIN
		say(cprocname || ' : start');
		vtext := REPLACE(ptext, chr(13));
		vtext := REPLACE(vtext, chr(9), '  ');
		vtext := TRIM(vtext);
		vlen  := nvl(length(vtext), 0);
		IF vlen = 0
		THEN
			RETURN VARRAY;
		END IF;
		IF substr(vtext, -1, 1) != nl
		THEN
			vtext := vtext || nl;
			vlen  := vlen + 1;
		END IF;
	
		WHILE vold < vlen
		LOOP
		
			vpos := instr(vtext, nl, vold + 1, 1);
		
			IF vpos = 0
			THEN
				vpos := vlen + 1;
			END IF;
			WHILE vpos - vold > 255
			LOOP
			
				k := instr(vtext, ';', - (vlen - vold - 255));
			
				IF k <= vold
				THEN
					k := instr(vtext, ' ', - (vlen - vold - 255));
				END IF;
				IF k <= vold
				THEN
					error.raiseerror('DynaSQL.Text2Array[clob] : String too long (from' || vold ||
									 ' to ' || vpos || ')');
				END IF;
				vcount := vcount + 1;
				VARRAY(vcount) := to_char(substr(vtext, vold + 1, k - vold));
				vold := k;
			
			END LOOP;
			vcount := vcount + 1;
		
			IF vold < vpos
			THEN
				VARRAY(vcount) := to_char(substr(vtext, vold + 1, vpos - vold - 1));
				vold := vpos;
			END IF;
		END LOOP;
		s.say(cprocname || ': return array[' || varray.count || ']');
		RETURN VARRAY;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION checkexists
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,pcommonbranch BOOLEAN
	) RETURN BOOLEAN IS
		vbranch NUMBER := seance.getbranch();
	BEGIN
		IF pcommonbranch
		THEN
			vbranch := seance.cbranch_common;
		END IF;
		FOR r IN (SELECT objident
				  FROM   tdynasql
				  WHERE  branch = vbranch
				  AND    objtype = pobjtype
				  AND    objmodule = pobjmodule
				  AND    objident = pobjident)
		LOOP
			RETURN TRUE;
		END LOOP;
		RETURN FALSE;
	END;

	PROCEDURE bindvar
	(
		prun NUMBER
	   ,prec typebindrec
	) IS
	BEGIN
		IF prec.vtype = co_num
		THEN
			dbms_sql.bind_variable(prun, prec.ident, prec.valnum);
		ELSIF prec.vtype = co_date
		THEN
			dbms_sql.bind_variable(prun, prec.ident, prec.valdate);
		ELSIF prec.vtype = co_char
		THEN
			dbms_sql.bind_variable(prun, prec.ident, prec.valchar, types.cmaxlenchar);
		ELSE
			error.raiseerror('Unknown value type: ' || prec.ident || ', type: ' || prec.vtype);
		END IF;
	EXCEPTION
		WHEN error.error THEN
			error.save('DynaSQL.BindVar');
			RAISE;
		WHEN OTHERS THEN
			say('DynaSQL.BindVar, ' || prun || ',' || prec.ident || ', [' || SQLERRM || ']');
			NULL;
	END;

	PROCEDURE getvar
	(
		prun NUMBER
	   ,prec IN OUT typebindrec
	) IS
	BEGIN
		IF prun = 0
		THEN
			RETURN;
		END IF;
		IF prec.vtype = co_num
		THEN
			dbms_sql.variable_value(prun, prec.ident, prec.valnum);
		ELSIF prec.vtype = co_date
		THEN
			dbms_sql.variable_value(prun, prec.ident, prec.valdate);
		ELSIF prec.vtype = co_char
		THEN
			dbms_sql.variable_value(prun, prec.ident, prec.valchar);
		ELSE
			error.raiseerror('Unknown value type: ' || prec.ident || ', type: ' || prec.vtype);
		END IF;
	EXCEPTION
		WHEN error.error THEN
			error.save('DynaSQL.GetVar');
			RAISE;
		WHEN OTHERS THEN
			say('DynaSQL.GetVar, ' || prun || ',' || prec.ident || ', [' || SQLERRM || ']');
			NULL;
	END;

	PROCEDURE bindvars
	(
		pcode NUMBER
	   ,prun  NUMBER
	) IS
		i PLS_INTEGER;
	BEGIN
	
		IF s_arrroot.exists(pcode)
		THEN
			i := s_arrroot(pcode);
			WHILE i IS NOT NULL
			LOOP
				bindvar(prun, s_arrbind(i));
				i := s_arrbind(i).next;
			END LOOP;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.BindVars, ' || pcode || ',' || prun);
			RAISE;
	END;

	PROCEDURE getvars
	(
		pcode NUMBER
	   ,prun  NUMBER
	) IS
		i PLS_INTEGER;
	BEGIN
	
		IF s_arrroot.exists(pcode)
		THEN
			i := s_arrroot(pcode);
			WHILE i IS NOT NULL
			LOOP
				getvar(prun, s_arrbind(i));
				i := s_arrbind(i).next;
			END LOOP;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.GetVars, ' || pcode || ',' || prun);
			RAISE;
	END;

	PROCEDURE setbindrec
	(
		pcode  NUMBER
	   ,pident VARCHAR
	   ,prec   typebindrec
	) IS
		vrec  typebindrec := prec;
		i     PLS_INTEGER;
		vprev PLS_INTEGER;
		vlast PLS_INTEGER;
		r     typebindrec;
	BEGIN
		IF pcode IS NULL
		THEN
			error.raiseerror('Script code is null !');
		END IF;
	
		IF pident IS NULL
		THEN
			error.raiseerror('Variable ident is null !');
		END IF;
	
		vrec.code  := pcode;
		vrec.ident := upper(pident);
	
		IF s_arrroot.exists(pcode)
		THEN
			i := s_arrroot(pcode);
			WHILE (i IS NOT NULL)
			LOOP
				r := s_arrbind(i);
				IF r.ident = vrec.ident
				THEN
					IF r.code = pcode
					THEN
						vrec.next := r.next;
					
						s_arrbind(i) := vrec;
						RETURN;
					ELSE
						say('ERROR, DynaSQL.SetBindRec: ' || pcode || ',' || pident ||
							', invalid item: ' || i || ', ' || r.code);
						RAISE error.error;
					END IF;
				END IF;
				vprev := i;
				i     := r.next;
			END LOOP;
			vlast := nvl(s_arrbind.last(), 0) + 1;
			s_arrbind(vprev).next := vlast;
		ELSE
			vlast := nvl(s_arrbind.last(), 0) + 1;
			s_arrroot(pcode) := vlast;
		END IF;
	
		s_arrbind(vlast) := vrec;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.SetBindRec: ' || pcode || ',' || pident);
			error.save('DynaSQL.SetBindRec');
			RAISE;
	END;

	FUNCTION getbindrec
	(
		pcode  NUMBER
	   ,pident VARCHAR
	) RETURN typebindrec IS
		vkey VARCHAR(100) := upper(pident);
		i    PLS_INTEGER;
		r    typebindrec;
	BEGIN
		IF pcode IS NULL
		THEN
			error.raiseerror('Script code is null !');
		END IF;
	
		IF pident IS NULL
		THEN
			error.raiseerror('Variable ident is null !');
		END IF;
	
		IF s_arrroot.exists(pcode)
		THEN
			i := s_arrroot(pcode);
			WHILE (i IS NOT NULL)
			LOOP
				r := s_arrbind(i);
				IF r.ident = vkey
				THEN
				
					IF r.code = pcode
					THEN
						RETURN r;
					ELSE
						say('ERROR, DynaSQL.GetBindRec: ' || pcode || ', ' || pident ||
							', invalid item: ' || i || ', ' || r.code);
						RAISE error.error;
					END IF;
				END IF;
				i := r.next;
			END LOOP;
		END IF;
	
		say('ERROR, DynaSQL.GetBindRec: ' || pcode || ',' || pident || ', is not found!');
		RETURN NULL;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.GetBindRec: ' || pcode || ',' || pident);
			error.save('DynaSQL.GetBindRec');
			RAISE;
	END;

	PROCEDURE clearbindcache(pcode NUMBER) IS
		i PLS_INTEGER;
	
		r typebindrec;
	BEGIN
	
		IF pcode IS NOT NULL
		THEN
		
			IF s_arrroot.exists(pcode)
			THEN
				i := s_arrroot(pcode);
				WHILE (i IS NOT NULL)
				LOOP
					r := s_arrbind(i);
					IF (r.code = pcode)
					THEN
						s_arrbind.delete(i);
					ELSE
						say('ERROR, DynaSQL.ClearBindCache: ' || pcode || ', invalid item: ' || i || ', ' ||
							r.ident || ', ' || r.code);
					
					END IF;
					i := r.next;
				END LOOP;
			
				s_arrroot.delete(pcode);
			END IF;
		ELSE
			s_arrbind.delete();
		END IF;
	
	END;

	PROCEDURE closerun(prun IN OUT NUMBER) IS
	BEGIN
		IF prun > 0
		   AND dbms_sql.is_open(prun)
		THEN
			dbms_sql.close_cursor(prun);
		END IF;
	EXCEPTION
		WHEN no_data_found THEN
			NULL;
	END;

	FUNCTION remarkwrapper
	(
		parray   IN typetextarray
	   ,pisdebug IN BOOLEAN := FALSE
	   ,pisexec  IN BOOLEAN := TRUE
	) RETURN typetextarray IS
		vtext typetextarray;
		vstr  VARCHAR2(1) := '';
		n     NUMBER := 0;
	BEGIN
		IF pisdebug
		THEN
			vstr := chr(10);
		END IF;
		IF parray.count() > 0
		THEN
			IF pisexec
			THEN
				vtext(1) := 'begin ' || vstr;
				n := 1;
			END IF;
			FOR i IN 1 .. parray.count()
			LOOP
				vtext(n + i) := parray(i) || vstr;
			END LOOP;
			IF pisexec
			THEN
				vtext(vtext.count() + 1) := ' null; end;' || vstr;
			END IF;
		END IF;
	
		RETURN vtext;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('RemarkWrapper');
			RAISE;
	END;

	FUNCTION compileonly(parray typetextarray) RETURN NUMBER IS
		vcur  NUMBER;
		vtext typetextarray;
	BEGIN
	
		vtext := remarkwrapper(parray);
		vcur  := dbms_sql.open_cursor;
		dbms_sql.parse(vcur, vtext, 1, vtext.count(), TRUE, dbms_sql.native);
	
		RETURN vcur;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.CompileOnly, ' || vcur);
			vtext := remarkwrapper(parray, TRUE);
			htools.printsql(vtext, vcur, 0);
			closerun(vcur);
			RAISE;
	END;

	FUNCTION COMPILE(pcode NUMBER) RETURN typecacherec IS
		vrow   typesqlrec;
		vrec   typecacherec;
		vtext  typetextarray;
		vcount NUMBER;
	BEGIN
		vrow := getsqlrec(pcode);
	
		vrec.code      := pcode;
		vrec.objtype   := vrow.objtype;
		vrec.objmodule := vrow.objmodule;
		vrec.objident  := vrow.objident;
		vrec.owneruid  := vrow.objectuid;
	
		vcount := getsql(pcode, vtext);
		IF vcount > 0
		THEN
		
			vrec.run := compileonly(vtext);
		ELSE
			vrec.run := 0;
		END IF;
	
		RETURN vrec;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.Compile, ' || pcode);
			error.save('DynaSQL.Compile');
			closerun(vrec.run);
			RAISE;
	END;

	FUNCTION runrun
	(
		prec                 typecacherec
	   ,pret                 NUMBER
	   ,pusecommitcontrol    BOOLEAN
	   ,pcursortxttodbgifexc BOOLEAN
	) RETURN NUMBER IS
		vret     NUMBER := pret;
		verrcode NUMBER;
		verrtext VARCHAR(512);
		vtext    typetextarray;
	BEGIN
		IF prec.run = 0
		THEN
			say('DynaSQL.RunRun: execute skiped - script is empty');
			RETURN pret;
		END IF;
	
		IF pusecommitcontrol
		THEN
			htools.enablecommitcontrol('DynaSQL.RunRun:' || prec.code);
		END IF;
	
		verrcode := err.geterrorcode();
		verrtext := err.getplace();
	
		bindvars(prec.code, prec.run);
		BEGIN
			dbms_sql.bind_variable(prec.run, ':RET', vret);
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	
		sdummy := dbms_sql.execute(prec.run);
	
		getvars(prec.code, prec.run);
		BEGIN
			dbms_sql.variable_value(prec.run, ':RET', vret);
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	
		IF vret < 0
		   OR verrcode = err.geterrorcode()
		THEN
			NULL;
		ELSE
		
			err.seterror(verrcode, verrtext);
		END IF;
	
		IF pusecommitcontrol
		THEN
			htools.disablecommitcontrol('DynaSQL.RunRun:' || prec.code);
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.RunRun2');
			IF (pcursortxttodbgifexc)
			THEN
			
				sdummy := getsql(prec.code, vtext);
				vtext  := remarkwrapper(vtext, TRUE);
				htools.printsql(vtext, psayid => 0);
			
			END IF;
			IF pusecommitcontrol
			THEN
				htools.disablecommitcontrol('DynaSQL.RunRun:' || prec.code);
			END IF;
			RAISE;
	END;

	PROCEDURE runrun
	(
		prec                 typecacherec
	   ,pusecommitcontrol    BOOLEAN
	   ,pcursortxttodbgifexc BOOLEAN
	) IS
		verrcode NUMBER;
		verrtext VARCHAR(512);
		vtext    typetextarray;
	BEGIN
		IF prec.run = 0
		THEN
			say('DynaSQL.RunRun: execute skiped - script is empty');
			RETURN;
		END IF;
		IF pusecommitcontrol
		THEN
			htools.enablecommitcontrol('DynaSQL.RunRun:' || prec.code);
		END IF;
	
		verrcode := err.geterrorcode();
		verrtext := err.getplace();
	
		bindvars(prec.code, prec.run);
	
		sdummy := dbms_sql.execute(prec.run);
	
		getvars(prec.code, prec.run);
	
		IF err.geterrorcode() != 0
		   OR verrcode = err.geterrorcode()
		THEN
			NULL;
		ELSE
		
			err.seterror(verrcode, verrtext);
		END IF;
		IF pusecommitcontrol
		THEN
			htools.disablecommitcontrol('DynaSQL.RunRun:' || prec.code);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.RunRun1, ' || prec.code || ',' || prec.run);
			IF (pcursortxttodbgifexc)
			THEN
			
				sdummy := getsql(prec.code, vtext);
				vtext  := remarkwrapper(vtext, TRUE);
				htools.printsql(vtext, psayid => 0);
			
			END IF;
			IF pusecommitcontrol
			THEN
				htools.disablecommitcontrol('DynaSQL.RunRun:' || prec.code);
			END IF;
			RAISE;
	END;

	PROCEDURE clearcache
	(
		pobjtype   NUMBER
	   ,pobjmodule NUMBER
	) IS
		vindex NUMBER;
		vprev  NUMBER;
		vrec   typecacherec;
	BEGIN
	
		vindex := s_arrcache.first();
		WHILE (vindex IS NOT NULL)
		LOOP
			vrec   := s_arrcache(vindex);
			vprev  := vindex;
			vindex := s_arrcache.next(vindex);
			IF nvl(vrec.objtype = pobjtype, TRUE)
			   AND nvl(vrec.objmodule = pobjmodule, TRUE)
			THEN
				clearbindcache(vrec.code);
				closerun(vrec.run);
				s_arrcache.delete(vprev);
				freeenv(vrec);
			END IF;
		END LOOP;
	
	END;

	FUNCTION getcache(pcode NUMBER) RETURN typecacherec IS
	BEGIN
		RETURN s_arrcache(pcode);
	EXCEPTION
		WHEN no_data_found THEN
			RETURN NULL;
	END;

	PROCEDURE putcache
	(
		pcode NUMBER
	   ,prec  typecacherec
	) IS
	BEGIN
		IF pcode IS NOT NULL
		THEN
			IF s_arrcache.exists(pcode)
			THEN
				closerun(s_arrcache(pcode).run);
			END IF;
			s_arrcache(pcode) := prec;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.PutCache');
			RAISE;
	END;

	PROCEDURE updatecache
	(
		pcode NUMBER
	   ,prec  typecacherec
	) IS
	BEGIN
		IF pcode IS NOT NULL
		THEN
			s_arrcache(pcode) := prec;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('DynaSQL.UpdateCache');
			RAISE;
	END;

	PROCEDURE setvaluenum
	(
		pcode  NUMBER
	   ,pident VARCHAR
	   ,pval   NUMBER
	) IS
		vrec typebindrec;
	BEGIN
		vrec.vtype  := co_num;
		vrec.valnum := pval;
	
		setbindrec(pcode, pident, vrec);
	END;

	PROCEDURE setvaluedate
	(
		pcode  NUMBER
	   ,pident VARCHAR
	   ,pval   DATE
	) IS
		vrec typebindrec;
	BEGIN
		vrec.vtype   := co_date;
		vrec.valdate := pval;
	
		setbindrec(pcode, pident, vrec);
	END;

	PROCEDURE setvaluechar
	(
		pcode  NUMBER
	   ,pident VARCHAR
	   ,pval   VARCHAR
	) IS
		vrec typebindrec;
	BEGIN
		vrec.vtype   := co_char;
		vrec.valchar := pval;
	
		setbindrec(pcode, pident, vrec);
	END;

	FUNCTION getvaluenum
	(
		pcode  NUMBER
	   ,pident VARCHAR
	) RETURN NUMBER IS
		vrec typebindrec;
	BEGIN
		vrec := getbindrec(pcode, pident);
		IF nvl(vrec.vtype != co_num, TRUE)
		THEN
			error.raiseerror('Invalid value type: ' || vrec.ident || ', type: ' || vrec.vtype);
		END IF;
	
		RETURN vrec.valnum;
	END;

	FUNCTION getvaluedate
	(
		pcode  NUMBER
	   ,pident VARCHAR
	) RETURN DATE IS
		vrec typebindrec;
	BEGIN
		vrec := getbindrec(pcode, pident);
		IF nvl(vrec.vtype != co_date, TRUE)
		THEN
			error.raiseerror('Invalid value type: ' || vrec.ident || ', type: ' || vrec.vtype);
		END IF;
	
		RETURN vrec.valdate;
	END;

	FUNCTION getvaluechar
	(
		pcode  NUMBER
	   ,pident VARCHAR
	) RETURN VARCHAR IS
		vrec typebindrec;
	BEGIN
		vrec := getbindrec(pcode, pident);
		IF nvl(vrec.vtype != co_char, TRUE)
		THEN
			error.raiseerror('Invalid value type: ' || vrec.ident || ', type: ' || vrec.vtype);
		END IF;
	
		RETURN vrec.valchar;
	END;

	PROCEDURE bindclear(pcode NUMBER) IS
	BEGIN
		clearbindcache(pcode);
	END;

	PROCEDURE checkcode(pcode NUMBER) IS
	BEGIN
	
		IF (pcode IS NULL)
		THEN
			RETURN;
		END IF;
	
		FOR r IN (SELECT code FROM tdynasql WHERE code = pcode)
		LOOP
			RETURN;
		END LOOP;
	
		error.raiseerror('PL/SQL block with code `' || pcode || '` not found on database!');
	END;

	FUNCTION isexistingcode(pcode NUMBER) RETURN BOOLEAN IS
	BEGIN
		FOR i IN (SELECT 1 FROM tdynasql WHERE code = pcode)
		LOOP
			RETURN TRUE;
		END LOOP;
		RETURN FALSE;
	END;

	FUNCTION getuserproplist
	(
		pcode     NUMBER
	   ,powneruid objectuid.typeobjectuid := NULL
	) RETURN apitypes.typeuserproplist IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.GetUserPropList(' || pcode || ', uid = ' ||
											powneruid || ')';
		vid objectuid.typeobjectuid := powneruid;
	BEGIN
		IF vid IS NULL
		THEN
			SELECT objectuid INTO vid FROM tdynasql WHERE code = pcode;
		END IF;
		RETURN objuserproperty.getrecord(pobject    => dynasql.object_name
										,psubobject => getsubobjectforup(pcode)
										,powneruid  => vid);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION getuserprop
	(
		pcode      NUMBER
	   ,pfieldname IN VARCHAR
	   ,powneruid  objectuid.typeobjectuid := NULL
	) RETURN apitypes.typeuserprop IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.GetUserProp(' || pcode || ', uid = ' ||
											powneruid || ')';
		vid objectuid.typeobjectuid := powneruid;
	BEGIN
		IF vid IS NULL
		THEN
			SELECT objectuid INTO vid FROM tdynasql WHERE code = pcode;
		END IF;
		RETURN objuserproperty.getfield(pobject    => dynasql.object_name
									   ,psubobject => getsubobjectforup(pcode)
									   ,powneruid  => vid
									   ,pfieldname => pfieldname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE setuserproplist
	(
		pcode               NUMBER
	   ,plist               apitypes.typeuserproplist
	   ,powneruid           objectuid.typeobjectuid := NULL
	   ,pclearpropnotinlist BOOLEAN := FALSE
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.SetUserPropList(' || pcode || ', uid = ' ||
											powneruid || ')';
		vid objectuid.typeobjectuid := powneruid;
	BEGIN
		IF vid IS NULL
		THEN
			SELECT objectuid INTO vid FROM tdynasql WHERE code = pcode;
		END IF;
		objuserproperty.saverecord(pobject             => dynasql.object_name
								  ,psubobject          => getsubobjectforup(pcode)
								  ,powneruid           => vid
								  ,pdata               => plist
								  ,pclearpropnotinlist => pclearpropnotinlist);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION getuserattributeslist
	(
		pcode     NUMBER
	   ,powneruid objectuid.typeobjectuid := NULL
	) RETURN apitypes.typeuserproplist IS
	BEGIN
		RETURN getuserproplist(pcode, powneruid);
	END;

	FUNCTION getuserattributerecord
	(
		pcode      NUMBER
	   ,pfieldname IN VARCHAR
	   ,powneruid  objectuid.typeobjectuid := NULL
	) RETURN apitypes.typeuserprop IS
	BEGIN
		RETURN getuserprop(pcode, pfieldname, powneruid);
	END;

	PROCEDURE saveuserattributeslist
	(
		pcode               NUMBER
	   ,plist               apitypes.typeuserproplist
	   ,powneruid           objectuid.typeobjectuid := NULL
	   ,pclearpropnotinlist BOOLEAN := FALSE
	) IS
	BEGIN
		setuserproplist(pcode, plist, powneruid, pclearpropnotinlist);
	END;

	FUNCTION getcurproplist RETURN apitypes.typeuserproplist IS
	BEGIN
		IF scurruncode IS NOT NULL
		THEN
			RETURN s_arrenv(scurruncode).params;
		END IF;
		error.raiseerror('Script not started');
	END;

	FUNCTION getcurprop(ppropname VARCHAR) RETURN apitypes.typeuserprop IS
	BEGIN
		IF scurruncode IS NOT NULL
		THEN
			RETURN objuserproperty.getprop_(s_arrenv(scurruncode).params, ppropname);
		END IF;
		error.raiseerror('Script not started');
	END;

	PROCEDURE clearuserpropreference
	(
		pobjtype      NUMBER
	   ,pobjmodule    NUMBER
	   ,pobjident     VARCHAR
	   ,pcommonbranch BOOLEAN
	) IS
	BEGIN
		objuserproperty.clearreference(object_name
									  ,getsubobjectforup(pobjtype, pobjmodule, pobjident)
									  ,pcommonbranch);
		COMMIT;
	END;

	PROCEDURE setouterid
	(
		pcode IN NUMBER
	   ,pid   typeouterid
	) IS
	BEGIN
		SAVEPOINT sp_setouterid;
		UPDATE tdynasql t
		SET    t.objtype   = pid.objtype
			  ,t.objmodule = pid.objmodule
			  ,t.objident  = pid.objident
		WHERE  code = pcode;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK TO sp_setouterid;
			error.raiseerror('Failed to update external ID of DynaSql block');
	END;

	PROCEDURE setlocator
	(
		pcode    IN NUMBER
	   ,plocator typelocator
	) IS
	BEGIN
		SAVEPOINT sp_setlocator;
		UPDATE tdynasql SET locator = TRIM(plocator) WHERE code = pcode;
	EXCEPTION
		WHEN OTHERS THEN
		
			ROLLBACK TO sp_setlocator;
		
			error.raiseerror(err.ue_value_incorrect
							,'Invalid locator "' || plocator || '" [script: ' || pcode || ']');
	END;

BEGIN

	NULL;
END;
/
