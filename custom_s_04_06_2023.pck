CREATE OR REPLACE PACKAGE custom_s IS

	crevision CONSTANT VARCHAR(100) := '$Rev: 44809 $';

	must_send BOOLEAN := TRUE;

	SUBTYPE typemask IS debug.typemask;

	cmask_pan CONSTANT typemask := debug.cmask_pan;
	cmask_str CONSTANT typemask := debug.cmask_str;

	PROCEDURE err
	(
		pmsg   VARCHAR
	   ,plevel NUMBER := NULL
	   ,pid    VARCHAR := NULL
	);

	PROCEDURE say
	(
		pmsg   VARCHAR
	   ,plevel NUMBER := NULL
	   ,pid    VARCHAR := NULL
	);
	PROCEDURE say
	(
		pmsg   NUMBER
	   ,plevel NUMBER := NULL
	   ,pid    VARCHAR := NULL
	);
	PROCEDURE say
	(
		pmsg   DATE
	   ,plevel NUMBER := NULL
	   ,pid    VARCHAR := NULL
	);
	PROCEDURE say
	(
		pmsg   BOOLEAN
	   ,plevel NUMBER := NULL
	   ,pid    VARCHAR := NULL
	);
	PROCEDURE say
	(
		pmsg   CLOB
	   ,plevel NUMBER := NULL
	   ,pid    VARCHAR := NULL
	);

	PROCEDURE say
	(
		pmsg   VARCHAR
	   ,plevel NUMBER
	   ,pid    NUMBER
	);
	PROCEDURE say
	(
		pmsg   NUMBER
	   ,plevel NUMBER
	   ,pid    NUMBER
	);
	PROCEDURE say
	(
		pmsg   DATE
	   ,plevel NUMBER
	   ,pid    NUMBER
	);
	PROCEDURE say
	(
		pmsg   BOOLEAN
	   ,plevel NUMBER
	   ,pid    NUMBER
	);
	PROCEDURE say
	(
		pmsg   CLOB
	   ,plevel NUMBER
	   ,pid    NUMBER
	);

	FUNCTION maskdata
	(
		pdata VARCHAR2
	   ,pmask typemask := cmask_str
	) RETURN VARCHAR2;

	PROCEDURE setlevel(plevel IN NUMBER);
	PROCEDURE setid
	(
		pid    IN VARCHAR
	   ,pclear BOOLEAN := FALSE
	);
	PROCEDURE setdeflevel(plevel IN NUMBER);
	PROCEDURE setdefid(pdefaultid IN VARCHAR);

	SUBTYPE typeidfilter IS debug.typeidfilter;

	PROCEDURE setidfilter
	(
		pidfilter  typeidfilter
	   ,pdebugtype debug.typetype := debug.ctype_rdbms
	);
	FUNCTION getidfilter RETURN typeidfilter;
	FUNCTION isidenable
	(
		pid      VARCHAR := NULL
	   ,pdbgtype debug.typetype := NULL
	) RETURN BOOLEAN;
	FUNCTION isanydebug RETURN BOOLEAN;

	FUNCTION getlevel RETURN NUMBER;

	PROCEDURE init(pmustsend BOOLEAN := NULL);

	FUNCTION cash_create RETURN NUMBER;
	PROCEDURE cash_clearandclose(pcashid NUMBER);
	PROCEDURE cash_writeandclose(pcashid NUMBER);

	FUNCTION maskpan(ppan VARCHAR2) RETURN VARCHAR2;

	PROCEDURE setsystemdebugenable
	(
		penable BOOLEAN
	   ,pcid    VARCHAR
	);
	PROCEDURE setanydebugenable
	(
		penable BOOLEAN
	   ,pcid    VARCHAR
	);

	FUNCTION getversion RETURN VARCHAR;

END;
/
CREATE OR REPLACE PACKAGE BODY custom_s IS

	cpackagename  CONSTANT VARCHAR(10) := 's';
	cbodyrevision CONSTANT VARCHAR(100) := '$Rev: 44809 $';

	crdbmsprefix CONSTANT VARCHAR(100) := '[' || seance.getuid || ']: ';

	sidfilter     typeidfilter;
	sidfilter_sys typeidfilter;
	slevel        NUMBER := 0;

	sdeflevel NUMBER := 1;
	sdefid    NUMBER := 0;

	ssystemdebugenable BOOLEAN := TRUE;
	sanydebugenable    BOOLEAN := TRUE;
	sdbms_output       BOOLEAN := TRUE;

	erecurse EXCEPTION;

	scash        types.arrtext;
	scashenabled BOOLEAN := FALSE;

	serrdisable BOOLEAN := FALSE;
	srecurselvl PLS_INTEGER := 0;
	cmax_recurse_lvl CONSTANT PLS_INTEGER := 2;

	PROCEDURE sys_debug_
	(
		text     VARCHAR
	   ,datetime VARCHAR
	) IS
		LANGUAGE JAVA NAME 'A4MServer.debugOracleFile(java.lang.String,java.lang.String)';

	FUNCTION isanydebug RETURN BOOLEAN IS
	BEGIN
		RETURN sanydebugenable;
	
	END;

	FUNCTION isidenable
	(
		pid      VARCHAR
	   ,pdbgtype debug.typetype := NULL
	) RETURN BOOLEAN IS
		vid VARCHAR(40);
	BEGIN
		vid := nvl(upper(pid), sdefid);
		RETURN CASE pdbgtype WHEN debug.ctype_rdbms THEN sidfilter.exists(vid) WHEN debug.ctype_system THEN sidfilter_sys.exists(vid) ELSE(sidfilter.exists(pid) OR
																																		   sidfilter_sys.exists(vid)) END;
	EXCEPTION
		WHEN OTHERS THEN
			err('S.isIDEnable(' || pid || ')');
			RETURN FALSE;
	END;

	FUNCTION getidfilter RETURN typeidfilter IS
	BEGIN
		RETURN sidfilter;
	END;

	PROCEDURE setidfilter
	(
		pidfilter  typeidfilter
	   ,pdebugtype debug.typetype
	) IS
	BEGIN
		CASE pdebugtype
			WHEN debug.ctype_rdbms THEN
				sidfilter := pidfilter;
				sidfilter(sdefid) := 1;
			WHEN debug.ctype_system THEN
				sidfilter_sys := pidfilter;
				sidfilter_sys(sdefid) := 1;
			ELSE
				NULL;
		END CASE;
	END;

	PROCEDURE setlevel(plevel IN NUMBER) IS
	BEGIN
	
		slevel := plevel;
	END;

	PROCEDURE setid
	(
		pid    VARCHAR
	   ,pclear BOOLEAN
	) IS
	BEGIN
		IF pid IS NOT NULL
		THEN
			IF pclear
			THEN
				sidfilter.delete(upper(pid));
			ELSE
				sidfilter(upper(pid)) := 1;
			END IF;
		END IF;
	END;

	PROCEDURE setdeflevel(plevel IN NUMBER) IS
	BEGIN
		sdeflevel := nvl(plevel, 0);
	END;

	PROCEDURE setdefid(pdefaultid IN VARCHAR) IS
	BEGIN
		sdefid := nvl(pdefaultid, 0);
	END;

	FUNCTION getlevel RETURN NUMBER IS
	BEGIN
		RETURN slevel;
	END;

	PROCEDURE addrecurselvl IS
	BEGIN
		IF srecurselvl >= cmax_recurse_lvl
		THEN
			RAISE erecurse;
		END IF;
		srecurselvl := srecurselvl + 1;
	END;

	PROCEDURE delrecurselvl IS
	BEGIN
		IF srecurselvl > 0
		THEN
			srecurselvl := srecurselvl - 1;
		ELSE
			srecurselvl := 0;
		END IF;
	END;

	FUNCTION getshift RETURN VARCHAR IS
		vlvl NUMBER := utl_call_stack.dynamic_depth - 3;
	BEGIN
		RETURN '#' || to_char(vlvl, 'fm00') || '>';
	EXCEPTION
		WHEN OTHERS THEN
			RETURN '..' || utl_call_stack.dynamic_depth || '..';
	END;

	PROCEDURE putmsg
	(
		pmsg   VARCHAR
	   ,plevel NUMBER
	   ,pid    VARCHAR
	) IS
		vdebugstatus debug.typestatus;
	BEGIN
		IF NOT sanydebugenable
		THEN
			RETURN;
		END IF;
		addrecurselvl;
		vdebugstatus := debug.getdebugstatus(debug.ctype_alternative, pskiprefresh => TRUE);
		IF vdebugstatus != debug.cstatus_off
		THEN
			altdebug.put(getshift() || pmsg, plevel, pid);
		END IF;
		IF NOT isidenable(nvl(pid, sdefid))
		THEN
			delrecurselvl;
			RETURN;
		END IF;
	
		vdebugstatus := debug.getdebugstatus(debug.ctype_system, pskiprefresh => TRUE);
		IF vdebugstatus != debug.cstatus_off
		THEN
			IF isidenable(nvl(pid, sdefid), debug.ctype_system)
			THEN
				sys_debug_(getshift() ||
						   debug.viewmaskdata(pmsg
											 ,pfullview => (vdebugstatus = debug.cstatus_full))
						  ,to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss'));
			END IF;
		END IF;
	
		vdebugstatus := debug.getdebugstatus(debug.ctype_rdbms, pskiprefresh => TRUE);
		IF vdebugstatus != debug.cstatus_off
		THEN
		
			IF isidenable(nvl(pid, sdefid), debug.ctype_rdbms)
			   AND ((slevel IS NULL) OR (nvl(plevel, sdeflevel) <= slevel))
			THEN
				IF scashenabled
				THEN
					scash(nvl(scash.last, 0) + 1) := to_char(SYSDATE, 'dd.mm.yyyy hh24:mi:ss') ||
													 ' : ' || pmsg;
				ELSE
					IF seance.mode_twr = seance.getsystemmode()
					THEN
					
						term.senddebugmsg(crdbmsprefix || getshift() ||
										  debug.viewmaskdata(pmsg
															,pfullview => (vdebugstatus =
																		  debug.cstatus_full)));
					END IF;
				END IF;
			END IF;
		END IF;
		delrecurselvl;
	EXCEPTION
		WHEN erecurse THEN
			NULL;
		WHEN OTHERS THEN
			delrecurselvl;
			NULL;
	END;

	PROCEDURE say
	(
		pmsg   VARCHAR
	   ,plevel NUMBER
	   ,pid    VARCHAR
	) IS
	BEGIN
		putmsg('"' || pmsg || '"', plevel, pid);
	END;

	PROCEDURE err
	(
		pmsg   VARCHAR
	   ,plevel NUMBER
	   ,pid    VARCHAR
	) IS
		PROCEDURE say_(ptext VARCHAR) IS
			vtext VARCHAR(32767);
		BEGIN
			IF seance.getsystemmode = seance.mode_none
			THEN
				vtext := '"' || debug.viewmaskdata(ptext, pfullview => TRUE) || '"';
				FOR i IN 1 .. (trunc((nvl(length(vtext), 1) - 1) / 250) + 1)
				LOOP
					dbms_output.put_line(substr(vtext, ((i - 1) * 250 + 1), 250));
				END LOOP;
			ELSE
				s.say(ptext, 0);
			END IF;
		END;
	BEGIN
		IF serrdisable
		THEN
			RETURN;
		END IF;
		serrdisable := TRUE;
	
		IF SQLCODE = error.a4merrorconst
		THEN
			say_('ERROR: [' || pmsg || ']  ' || twcmserror.geterror);
		ELSE
			say_('ERROR: [' || pmsg || ']  ' || SQLERRM);
		END IF;
	
		say_('STACK:' || dbms_utility.format_error_backtrace());
		serrdisable := FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			serrdisable := FALSE;
	END;

	PROCEDURE say
	(
		pmsg   NUMBER
	   ,plevel NUMBER
	   ,pid    NUMBER
	) IS
	BEGIN
		say(pmsg, plevel);
	END;
	PROCEDURE say
	(
		pmsg   VARCHAR
	   ,plevel NUMBER
	   ,pid    NUMBER
	) IS
	BEGIN
		say(pmsg, plevel);
	END;
	PROCEDURE say
	(
		pmsg   DATE
	   ,plevel NUMBER
	   ,pid    NUMBER
	) IS
	BEGIN
		say(pmsg, plevel);
	END;
	PROCEDURE say
	(
		pmsg   BOOLEAN
	   ,plevel NUMBER
	   ,pid    NUMBER
	) IS
	BEGIN
		say(pmsg, plevel);
	END;
	PROCEDURE say
	(
		pmsg   CLOB
	   ,plevel NUMBER
	   ,pid    NUMBER
	) IS
	BEGIN
		say(pmsg, plevel);
	END;

	PROCEDURE say
	(
		pmsg   NUMBER
	   ,plevel NUMBER
	   ,pid    VARCHAR
	) IS
	BEGIN
		putmsg(to_char(pmsg), plevel, pid);
	END;

	PROCEDURE say
	(
		pmsg   DATE
	   ,plevel NUMBER
	   ,pid    VARCHAR
	) IS
	BEGIN
		putmsg(to_char(pmsg), plevel, pid);
	END;

	PROCEDURE say
	(
		pmsg   BOOLEAN
	   ,plevel NUMBER
	   ,pid    VARCHAR
	) IS
	BEGIN
		IF pmsg IS NULL
		THEN
			putmsg('NULL (Bool)', plevel, pid);
		ELSIF pmsg
		THEN
			putmsg('TRUE', plevel, pid);
		ELSE
			putmsg('FALSE', plevel, pid);
		END IF;
	END;

	PROCEDURE say
	(
		pmsg   CLOB
	   ,plevel NUMBER
	   ,pid    VARCHAR
	) IS
		i NUMBER;
	BEGIN
		IF pmsg IS NULL
		THEN
			putmsg('s.say: #CLOB locator is null', plevel, pid);
			RETURN;
		END IF;
		IF length(pmsg) < types.cmaxlenchar
		THEN
			say(to_char(substr(pmsg, 1)), plevel, pid);
			RETURN;
		END IF;
		putmsg('s.say: #CLOB length = ' || to_char(length(pmsg)), plevel, pid);
		i := 1;
		WHILE i <= length(pmsg)
		LOOP
			putmsg('s.say: #CLOB ' || i || '..' || (i + types.cmaxlenchar - 1) || ' : "' ||
				   to_char(substr(pmsg, i, types.cmaxlenchar)) || '"'
				  ,plevel
				  ,pid);
			i := i + types.cmaxlenchar;
		END LOOP;
	END;

	PROCEDURE init(pmustsend BOOLEAN := NULL) IS
	BEGIN
		sdbms_output := FALSE;
	
	END;

	PROCEDURE setsystemdebugenable
	(
		penable BOOLEAN
	   ,pcid    VARCHAR
	) IS
	BEGIN
		IF NOT seance.checkcid(pcid)
		   AND NOT a4m.checkcid(pcid)
		THEN
			error.raiseuser('S.SetSystemDebugEnable : ' || 'ACCESS DENIED');
		END IF;
		ssystemdebugenable := nvl(penable, FALSE);
	END;

	PROCEDURE setanydebugenable
	(
		penable BOOLEAN
	   ,pcid    VARCHAR
	) IS
	BEGIN
		sanydebugenable := nvl(penable, TRUE) OR
						   seance.getsystemmode NOT IN
						   (seance.mode_twr, seance.mode_bp, seance.mode_twrhi);
	
	END;

	FUNCTION cash_create RETURN NUMBER IS
		vindex NUMBER;
	BEGIN
		scashenabled := TRUE;
		vindex := nvl(scash.last, 0) + 1;
		scash(vindex) := NULL;
		RETURN vindex;
	END;

	PROCEDURE cash_close
	(
		pcashid NUMBER
	   ,pwrite  BOOLEAN
	) IS
		vtwr     BOOLEAN := seance.mode_twr = seance.getsystemmode();
		visinner BOOLEAN;
	BEGIN
		IF nvl(pcashid < 1
			   OR pcashid > scash.count
			  ,TRUE)
		THEN
			s.err('S.Cash_Close : invalid CashID = ' || pcashid);
			RETURN;
		END IF;
		visinner := pcashid > 1;
		IF (visinner AND pwrite)
		THEN
			RETURN;
		END IF;
		FOR i IN pcashid .. scash.count
		LOOP
			IF pwrite
			THEN
				IF vtwr
				THEN
					IF scash(i) IS NOT NULL
					THEN
						term.senddebugmsg(debug.viewmaskdata(scash(i)));
					END IF;
				END IF;
			END IF;
			scash.delete(i);
		END LOOP;
		IF scash.count = 0
		THEN
			scashenabled := FALSE;
		END IF;
	END;

	PROCEDURE cash_clearandclose(pcashid NUMBER) IS
	BEGIN
		cash_close(pcashid, FALSE);
	END;

	PROCEDURE cash_writeandclose(pcashid NUMBER) IS
	BEGIN
		cash_close(pcashid, TRUE);
	END;

	FUNCTION maskdata
	(
		pdata VARCHAR2
	   ,pmask typemask
	) RETURN VARCHAR2 IS
	BEGIN
		RETURN debug.makemaskdata(pmask, pdata);
	END;

	FUNCTION maskpan(ppan VARCHAR2) RETURN VARCHAR2 IS
	BEGIN
		RETURN debug.makemaskdata(debug.cmask_pan, ppan);
	END;

	FUNCTION getversion RETURN VARCHAR IS
	BEGIN
		RETURN service.formatpackageversion(cpackagename, crevision, cbodyrevision);
	END;

BEGIN
	sidfilter(sdefid) := 1;

END;
/
