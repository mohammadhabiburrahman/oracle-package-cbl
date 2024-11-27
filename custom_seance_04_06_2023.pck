CREATE OR REPLACE PACKAGE custom_seance IS

	crevision CONSTANT VARCHAR(100) := '$Rev: 39277 $';

	appshortname CONSTANT VARCHAR(100) := 'TWCMS';
	appfullname  CONSTANT VARCHAR(100) := 'TranzWare Suite v3.2 / TranzWare Card Management System';

	mode_none  CONSTANT NUMBER := 0;
	mode_twr   CONSTANT NUMBER := 1;
	mode_bp    CONSTANT NUMBER := 2;
	mode_twrhi CONSTANT NUMBER := 3;
	mode_sql   CONSTANT NUMBER := 4;
	mode_oms   CONSTANT NUMBER := 5;

	modename_none  CONSTANT VARCHAR(100) := 'NONE';
	modename_twr   CONSTANT VARCHAR(100) := 'ITC';
	modename_bp    CONSTANT VARCHAR(100) := 'BP';
	modename_twrhi CONSTANT VARCHAR(100) := 'TWRHI';
	modename_sql   CONSTANT VARCHAR(100) := 'SQL';
	modename_oms   CONSTANT VARCHAR(100) := 'OMS';

	cbranch_common CONSTANT NUMBER := 0;

	SUBTYPE typeaccess IS PLS_INTEGER;
	access_full    CONSTANT typeaccess := 0;
	access_limited CONSTANT typeaccess := 1;

	cerror_logon CONSTANT NUMBER := -20100;
	elogon EXCEPTION;
	PRAGMA EXCEPTION_INIT(elogon, -20100);

	cerror_start CONSTANT NUMBER := -20106;
	estart EXCEPTION;
	PRAGMA EXCEPTION_INIT(estart, -20106);

	TYPE typeseanceinfo IS RECORD(
		 ismultitask BOOLEAN
		,isvisual    BOOLEAN
		,isreadonly  BOOLEAN
		,ISOPEN      BOOLEAN);

	FUNCTION getinfo RETURN typeseanceinfo;
	FUNCTION getmodename(pmode NUMBER) RETURN VARCHAR;
	FUNCTION getsystemmode RETURN NUMBER;
	FUNCTION getaccessmode RETURN typeaccess;
	FUNCTION getmulticlerk RETURN BOOLEAN;

	FUNCTION checksysdate RETURN NUMBER;
	FUNCTION getbranch RETURN NUMBER;
	FUNCTION getbranchname RETURN VARCHAR;
	FUNCTION getbranchpart RETURN NUMBER;
	FUNCTION getcity RETURN VARCHAR;
	FUNCTION getcountry RETURN NUMBER;
	FUNCTION getcurrency RETURN NUMBER;
	FUNCTION getfiid RETURN VARCHAR;
	FUNCTION getoperdate RETURN DATE;
	FUNCTION getregim RETURN NUMBER;
	FUNCTION getregion RETURN VARCHAR;
	FUNCTION getstation RETURN NUMBER;
	FUNCTION gethostname RETURN VARCHAR;
	FUNCTION getclerkcode RETURN NUMBER;
	FUNCTION getclerkclientid RETURN NUMBER;
	FUNCTION getclerkuser RETURN VARCHAR;

	FUNCTION getuserproplist RETURN apitypes.typeuserproplist;
	FUNCTION getuserprop(pextid VARCHAR2) RETURN apitypes.typeuserprop;
	PROCEDURE setuserproplist
	(
		pdata               apitypes.typeuserproplist
	   ,pclearpropnotinlist BOOLEAN := FALSE
	);

	PROCEDURE enablecommonbranch;
	PROCEDURE disablecommonbranch;
	PROCEDURE setoperdate(poperdate IN DATE);
	PROCEDURE setregim(pregim IN NUMBER);
	PROCEDURE setregion(pregion IN VARCHAR);
	PROCEDURE settempoperdate(poperdate IN DATE);
	PROCEDURE extcallinit
	(
		pbranch  IN NUMBER
	   ,pstation IN NUMBER
	   ,pclerk   IN VARCHAR
	);

	PROCEDURE captureresources
	(
		phostname VARCHAR
	   ,papp      NUMBER
	   ,pclerk    VARCHAR
	   ,pstation  NUMBER
	);

	FUNCTION getcountactiveuser RETURN NUMBER;

	PROCEDURE login
	(
		ptwcms_mode NUMBER
	   ,pbranch     NUMBER
	   ,pstation    NUMBER
	   ,paccessmode typeaccess := access_full
	   ,pmulticlerk BOOLEAN := FALSE
	);
	FUNCTION login
	(
		ptwcms_mode NUMBER
	   ,pbranch     NUMBER
	   ,pstation    NUMBER
	) RETURN BOOLEAN;

	PROCEDURE logout;

	PROCEDURE changeclerk(pusername VARCHAR);

	FUNCTION getuid RETURN VARCHAR;
	PROCEDURE decodeuid
	(
		puid     VARCHAR
	   ,psid     OUT NUMBER
	   ,pserial# OUT NUMBER
	);

	FUNCTION getbranchobjectuid(pbranch NUMBER := NULL) RETURN objectuid.typeobjectuid;

	shared   CONSTANT NUMBER := 0;
	exclusiv CONSTANT NUMBER := 1;
	closed   CONSTANT NUMBER := 2;
	deleted  CONSTANT NUMBER := 4;
	serviced CONSTANT NUMBER := 8;

	clang_eng CONSTANT PLS_INTEGER := 1;
	clang_rus CONSTANT PLS_INTEGER := 2;
	FUNCTION getlanguage RETURN PLS_INTEGER;

	PROCEDURE setlogonwarning(ptext VARCHAR);

	FUNCTION getappversion RETURN VARCHAR;
	FUNCTION getappbuild RETURN NUMBER;
	FUNCTION isoraclerac RETURN BOOLEAN;

	PROCEDURE sendnotify4user
	(
		puser    VARCHAR
	   ,ptext    VARCHAR
	   ,pfrom    VARCHAR := NULL
	   ,pexpired DATE := NULL
	);

	PROCEDURE a4mstartup
	(
		pparams VARCHAR
	   ,pcid    VARCHAR
	);

	PROCEDURE startchildthread
	(
		papptype VARCHAR
	   ,pparams  VARCHAR
	   ,pcid     VARCHAR
	);

	PROCEDURE startchildthreadora
	(
		pparams VARCHAR
	   ,pcid    VARCHAR
	);
	FUNCTION makestartchildparams
	(
		pcallsql    VARCHAR
	   ,pparamcount NUMBER := 0
	   ,pparam1     VARCHAR := NULL
	   ,pparam2     VARCHAR := NULL
	   ,pparam3     VARCHAR := NULL
	) RETURN VARCHAR;

	FUNCTION checkcid(pcid VARCHAR) RETURN BOOLEAN;
	FUNCTION getdesktop RETURN NUMBER;
	FUNCTION gettaskbar RETURN NUMBER;
	FUNCTION dialoglogin(pmode IN NUMBER) RETURN NUMBER;
	PROCEDURE changeuserawaystatus
	(
		pstatus NUMBER
	   ,pcid    VARCHAR
	);
	PROCEDURE changeidlestatus
	(
		pstatus NUMBER
	   ,pcid    VARCHAR
	);

	FUNCTION getversion RETURN VARCHAR;
END;
/
CREATE OR REPLACE PACKAGE BODY custom_seance IS
	cpackagename CONSTANT VARCHAR2(100) := 'Seance';

	cbodyrevision CONSTANT VARCHAR2(100) := '$Rev: 62141 $';

	cid CONSTANT VARCHAR(32000) := '434F4D504153535F5457434D535F5345414E43455F' || sys_guid();

	csystemmode PLS_INTEGER := mode_none;
	caccessmode typeaccess := access_full;
	cmulticlerk BOOLEAN := FALSE;

	sseancerow    tseance%ROWTYPE;
	stempoperdate DATE;
	stempbranch   NUMBER := NULL;
	sbranchpart   NUMBER;
	scountry      NUMBER;
	scity         treferencecity.code%TYPE;
	sregion       treferenceregion.code%TYPE;
	scurrency     NUMBER;
	sstation      NUMBER;
	sstarter      NUMBER;
	suid          VARCHAR(100);
	sparentuid    VARCHAR(100);
	shostname     VARCHAR(1000);
	sidletimeout  NUMBER;
	sidleignore   BOOLEAN := FALSE;
	soraclerac    BOOLEAN := NULL;
	swarning      CLOB;
	sclerkrow     tclerk%ROWTYPE;

	slogincaptured BOOLEAN := FALSE;
	sdesktop       NUMBER;
	staskbar       NUMBER;

	sdummy NUMBER;

	FUNCTION calldialog
	(
		pname    IN VARCHAR
	   ,pthis    BOOLEAN := FALSE
	   ,pcaption VARCHAR := NULL
	   ,picon    VARCHAR := NULL
	) RETURN NUMBER;
	PROCEDURE showoperdaywarning;

	FUNCTION sys_check_(pcid VARCHAR) RETURN NUMBER IS
		LANGUAGE JAVA NAME 'A4MServer.checkCID(java.lang.String) return int';

	PROCEDURE setidletimeout_(psecond NUMBER) IS
		LANGUAGE JAVA NAME 'A4MServer.setSessionIdleTimeout(int)';
	PROCEDURE setchecktimeout_(psecond NUMBER) IS
		LANGUAGE JAVA NAME 'A4MServer.setSessionCheckTimeout(int)';

	PROCEDURE sys_reinitdebug(pcontinue NUMBER) IS
		LANGUAGE JAVA NAME 'A4MServer.reinitDebug(int)';

	PROCEDURE sys_setdebugdir(pdebugdir VARCHAR) IS
		LANGUAGE JAVA NAME 'A4MServer.setDebugDir(java.lang.String)';

	PROCEDURE sys_setdebugmode(pmode NUMBER) IS
		LANGUAGE JAVA NAME 'poste.tools.Debug.setMode(int)';

	PROCEDURE sys_debugstackenable IS
		LANGUAGE JAVA NAME 'A4MServer.debugStackEnable()';

	PROCEDURE sys_debugstackdisable IS
		LANGUAGE JAVA NAME 'A4MServer.debugStackDisable()';

	FUNCTION getversion RETURN VARCHAR IS
	BEGIN
		RETURN service.formatpackageversion(cpackagename, crevision, cbodyrevision);
	END;

	PROCEDURE say(pmsg VARCHAR) IS
	BEGIN
		IF pmsg LIKE cpackagename || '.'
		THEN
			s.say(pmsg, 0);
		ELSE
			s.say(cpackagename || '.' || pmsg, 0);
		END IF;
	END;
	PROCEDURE say(pmsg BOOLEAN) IS
	BEGIN
		s.say(pmsg, 0);
	END;
	PROCEDURE say(pmsg DATE) IS
	BEGIN
		s.say(pmsg, 0);
	END;
	PROCEDURE say(pmsg NUMBER) IS
	BEGIN
		s.say(pmsg, 0);
	END;

	PROCEDURE raiseerr(ptext VARCHAR) IS
	BEGIN
		error.showstack(TRUE);
		raise_application_error(custom_seance.cerror_logon, ptext);
	END;

	PROCEDURE cleargarbageofseanceid;
	PROCEDURE setdesktopcaption;
	PROCEDURE startitc;
	PROCEDURE createappsubmenu;

	PROCEDURE setsystemmode(pmode NUMBER) IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.SetSystemMode( MODE = ' || pmode || ')';
	BEGIN
		IF (NOT
			nvl((pmode IN (mode_none, mode_twr, mode_bp, mode_twrhi, mode_sql, mode_oms)), FALSE))
		THEN
			raiseerr('Unknown mode : `' || pmode || '`!');
		END IF;
		IF csystemmode != mode_none
		   AND pmode != mode_none
		THEN
			raiseerr('System is already initialized and cannot proceed to another mode!');
		END IF;
		csystemmode    := pmode;
		a4m.smode      := csystemmode;
		a4m.sfloramode := csystemmode IN (mode_bp, mode_twrhi);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION getsystemmode RETURN NUMBER IS
	BEGIN
		RETURN csystemmode;
	END;

	FUNCTION getmodename(pmode NUMBER) RETURN VARCHAR IS
	BEGIN
		IF pmode = mode_none
		THEN
			RETURN modename_none;
		ELSIF pmode = mode_twr
		THEN
			RETURN modename_twr;
		ELSIF pmode = mode_bp
		THEN
			RETURN modename_bp;
		ELSIF pmode = mode_twrhi
		THEN
			RETURN modename_twrhi;
		ELSIF pmode = mode_oms
		THEN
			RETURN modename_oms;
		ELSIF pmode = mode_sql
		THEN
			RETURN modename_sql;
		ELSE
			RETURN NULL;
		END IF;
	END;

	PROCEDURE setaccessmode(pmode typeaccess) IS
	BEGIN
		IF pmode NOT IN (access_full, access_limited)
		THEN
			raiseerr('Unknown access mode: `' || pmode || '`!');
		END IF;
	
		caccessmode := pmode;
	END;

	FUNCTION getaccessmode RETURN typeaccess IS
	BEGIN
		RETURN caccessmode;
	END;

	PROCEDURE setmulticlerk(penable BOOLEAN) IS
	BEGIN
		cmulticlerk := nvl(penable, FALSE);
	END;

	FUNCTION getmulticlerk RETURN BOOLEAN IS
	BEGIN
		RETURN cmulticlerk;
	END;

	FUNCTION checksysdate RETURN NUMBER IS
	BEGIN
		RETURN service.iif(trunc(SYSDATE) < getoperdate(), 1, 0);
	END;

	FUNCTION getappversion RETURN VARCHAR IS
		vret VARCHAR(4000);
	BEGIN
		SELECT t.version
		INTO   vret
		FROM   tupg_version t
		WHERE  upper(product) IN ('TWRR', 'TWRE')
		AND    rownum = 1;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;

	FUNCTION getappbuild RETURN NUMBER IS
		vret NUMBER;
	BEGIN
		SELECT t.build
		INTO   vret
		FROM   tupg_version t
		WHERE  upper(product) IN ('TWRR', 'TWRE')
		AND    rownum = 1;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;

	FUNCTION isoraclerac RETURN BOOLEAN IS
	BEGIN
		IF soraclerac IS NULL
		THEN
			soraclerac := FALSE;
			FOR i IN (SELECT * FROM v$active_instances)
			LOOP
				soraclerac := TRUE;
				EXIT;
			END LOOP;
		END IF;
		RETURN soraclerac;
	END;

	FUNCTION dialoglogin(pmode IN NUMBER) RETURN NUMBER IS
		ccopyright CONSTANT VARCHAR2(100) := 'Copyright (C) Compass Plus Ltd. 1994-2023';
		vcursor  NUMBER;
		vversion VARCHAR(100);
		id       NUMBER;
		panel    NUMBER;
		vi       NUMBER;
		cft      NUMBER;
		vstr     VARCHAR(4000);
	BEGIN
		BEGIN
			vcursor := dbms_sql.open_cursor;
			dbms_sql.parse(vcursor
						  ,'SELECT VERSION || '' ('' || BUILD || '') '' FROM TUPG_VERSION WHERE UPPER(PRODUCT) IN (''TWRR'', ''TWRE'')'
						  ,dbms_sql.v7);
			dbms_sql.define_column(vcursor, 1, 'VARCHAR2', 100);
			sdummy := dbms_sql.execute_and_fetch(vcursor);
			dbms_sql.column_value(vcursor, 1, vversion);
			dbms_sql.close_cursor(vcursor);
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	
		id    := dialog.new('About', 0, 0, 64, 18, pextid => 'About');
		cft   := 2 + length(ccopyright);
		panel := dialog.panel(id, 'P', 16, 2, cft, 5, 0);
		dialog.setanchor(id, 'P', dialog.anchor_left);
		vi := 2;
		dialog.textlabel(panel, 'Text1', 1, 1, cft, htools.getsubstr(appfullname, 1, ' / '));
		dialog.settextanchor(panel, 'Text1', 0);
		vi := vi + 1;
		dialog.textlabel(panel, 'Text1.1', 1, 2, cft, htools.getsubstr(appfullname, 2, ' / '));
		dialog.settextanchor(panel, 'Text1.1', 0);
		vi := vi + 1;
		dialog.textlabel(panel, 'Text2', 1, 3, cft, 'v.' || vversion);
		dialog.settextanchor(panel, 'Text2', 0);
		vi := vi + 1;
		dialog.textlabel(panel, 'Text3', 1, 4, cft, ccopyright);
		dialog.settextanchor(panel, 'Text3', 0);
		vi := vi + 1;
		vi := vi + 1;
		vi := vi + 1;
		windows.edittext(id, 'Memo', 3, vi, 64 - 5, 5);
		vi := vi + 6;
		dialog.setreadonly(id, 'Memo');
		vstr := 'Branch: ' || getbranchname || ' (' || to_char(sseancerow.branch) || ')' || chr(10) ||
				'Subbranch: ' || referencebranchpart.getbranchpartname(sbranchpart) || ' (' ||
				to_char(sbranchpart) || ')' || chr(10) || 'Station: ' ||
				referencebranchpart.getstationname(sstation) || ' (' || to_char(sstation) || ')' ||
				chr(10) || 'User: ' || clerk.getcardtext(1) || ' (' || getclerkuser || ')' ||
				chr(10);
		IF (pmode = shared)
		THEN
			vstr := vstr || 'Business day: ' || htools.d2s(getoperdate()) || chr(10) ||
					'System access mode: SHARED';
		ELSIF (pmode = exclusiv)
		THEN
			vstr := vstr || 'Business day: ' || htools.d2s(getoperdate()) || chr(10) ||
					'System access mode: EXCLUSIVE';
		ELSIF (pmode = closed)
		THEN
			vstr := vstr || 'Business day: ' || 'BUSINESS DAY CLOSED';
		END IF;
		dialog.puttext(id, 'Memo', vstr);
	
		dialog.picture(id, 'PIC', 3, 2, vi, 6, 'a4m.bmp');
		dialog.button(id, 'OK', 29, vi, 6, '  Ok', dialog.cmok, 0, 'Press <Enter> to continue');
		dialog.goitem(id, 'OK');
		RETURN id;
	END;

	FUNCTION getbranch RETURN NUMBER IS
	BEGIN
		/*   IF stempbranch IS NOT NULL
        THEN
            RETURN stempbranch;
        END IF;
        RETURN sseancerow.branch;*/
		RETURN 1;
	END;

	FUNCTION getbranchname RETURN VARCHAR IS
	BEGIN
		--RETURN sseancerow.branchname;
		RETURN 'Citybank';
	END;

	FUNCTION getbranchpart RETURN NUMBER IS
	BEGIN
		RETURN sbranchpart;
	END;

	FUNCTION getcity RETURN VARCHAR IS
	BEGIN
		RETURN scity;
	END;

	FUNCTION getcountry RETURN NUMBER IS
	BEGIN
		RETURN scountry;
	END;

	FUNCTION getcurrency RETURN NUMBER IS
	BEGIN
		RETURN scurrency;
	END;

	FUNCTION getfiid RETURN VARCHAR IS
	BEGIN
		--RETURN sseancerow.fiid;
		RETURN 'CITY';
	END;

	FUNCTION getoperdate RETURN DATE IS
	
	BEGIN
	
		IF stempoperdate IS NOT NULL
		THEN
			RETURN stempoperdate;
		END IF;
	
		IF sseancerow.branch = 0
		THEN
			RETURN NULL;
		END IF;
	
		IF getsystemmode NOT IN (custom_seance.mode_twr)
		THEN
			SELECT * INTO sseancerow FROM tseance WHERE branch = sseancerow.branch;
		END IF;
		RETURN sseancerow.operdate;
	END;

	FUNCTION getregim RETURN NUMBER IS
	BEGIN
		--RETURN sseancerow.flag;
		RETURN 0;
	END;

	FUNCTION getregion RETURN VARCHAR IS
	BEGIN
		RETURN sregion;
	END;

	FUNCTION getstation RETURN NUMBER IS
	BEGIN
		RETURN sstation;
	END;

	PROCEDURE createbranchobjectuid(pbranch NUMBER) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vobjuid objectuid.typeobjectuid;
	BEGIN
		vobjuid := objectuid.newuid('BRANCH', TRIM(to_char(pbranch)));
		UPDATE tseance SET objectuid = vobjuid WHERE branch = pbranch;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.CreateBranchObjectUID');
			ROLLBACK;
			RAISE;
	END;

	FUNCTION getbranchobjectuid(pbranch NUMBER) RETURN objectuid.typeobjectuid IS
		vuid    objectuid.typeobjectuid;
		vbranch NUMBER;
	BEGIN
		vbranch := nvl(pbranch, getbranch);
		IF vbranch = cbranch_common
		THEN
			RETURN NULL;
		END IF;
		SELECT objectuid INTO vuid FROM tseance WHERE branch = vbranch;
	
		IF vuid IS NULL
		THEN
			createbranchobjectuid(vbranch);
			SELECT objectuid INTO vuid FROM tseance WHERE branch = vbranch;
		END IF;
		RETURN vuid;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetBranchObjectUID(' || pbranch || ')');
			RAISE;
	END;

	FUNCTION getuserproplist RETURN apitypes.typeuserproplist IS
	BEGIN
		RETURN objuserproperty.getrecord(pobject       => 'BRANCH'
										,powneruid     => getbranchobjectuid()
										,pcommonbranch => TRUE);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetUserPropList');
			RAISE;
	END;

	FUNCTION getuserprop(pextid VARCHAR2) RETURN apitypes.typeuserprop IS
	BEGIN
		RETURN objuserproperty.getfield(pobject       => 'BRANCH'
									   ,powneruid     => getbranchobjectuid()
									   ,pfieldname    => pextid
									   ,pcommonbranch => TRUE);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetUserProp');
			RAISE;
	END;

	PROCEDURE setuserproplist
	(
		pdata               apitypes.typeuserproplist
	   ,pclearpropnotinlist BOOLEAN := FALSE
	) IS
	BEGIN
		objuserproperty.saverecord(pobject             => 'BRANCH'
								  ,powneruid           => getbranchobjectuid()
								  ,pdata               => pdata
								  ,pclearpropnotinlist => pclearpropnotinlist
								  ,plog_type           => object.gettype('BRANCH')
								  ,plog_key            => getbranch()
								  ,pcommonbranch       => TRUE);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SetUserPropList');
			RAISE;
	END;

	FUNCTION setauthbranch(pfiid IN VARCHAR) RETURN NUMBER IS
	BEGIN
		SELECT * INTO sseancerow FROM tseance WHERE fiid = pfiid;
		RETURN 0;
	EXCEPTION
		WHEN no_data_found THEN
			err.seterror(err.seance_invalid_branch, 'custom_seance.SetAuthBranch');
			RETURN err.seance_invalid_branch;
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'custom_seance.SetBranch');
			RETURN SQLCODE;
	END;

	PROCEDURE reset$ IS
	BEGIN
		operday.reset$;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('custom_seance.reset$');
	END;

	PROCEDURE openbranch(pbranch IN NUMBER) IS
	BEGIN
		IF sseancerow.branch != 0
		THEN
			IF pbranch != sseancerow.branch
			THEN
				raiseerr('Attempted repeated setting of branch');
			END IF;
			say('Warning! Branch already opened.');
			RETURN;
		END IF;
	
		SELECT * INTO sseancerow FROM tseance WHERE branch = pbranch;
		say('Branch ' || sseancerow.branch || ' opened.');
		reset$;
	
	EXCEPTION
		WHEN no_data_found THEN
			error.raiseerror(err.seance_invalid_branch, 'Branch = ' || pbranch);
		WHEN OTHERS THEN
			error.save('custom_seance.OpenBranch(' || pbranch || ')');
			RAISE;
	END;

	PROCEDURE enablecommonbranch IS
	BEGIN
		stempbranch := cbranch_common;
		s.say(cpackagename || ' : enableCommonBranch');
	END;

	PROCEDURE disablecommonbranch IS
	BEGIN
		stempbranch := NULL;
		s.say(cpackagename || ' : disableCommonBranch');
	END;

	PROCEDURE setbranchpart(pbranchpart IN NUMBER) IS
	BEGIN
		sbranchpart := pbranchpart;
	END;

	PROCEDURE setcity(pcity IN VARCHAR) IS
	BEGIN
		scity := pcity;
	END;

	PROCEDURE setcountry(pcountry IN NUMBER) IS
	BEGIN
		scountry := pcountry;
	END;

	PROCEDURE setcurrency(pcurrency IN NUMBER) IS
	BEGIN
		scurrency := pcurrency;
	END;

	PROCEDURE setoperdate(poperdate IN DATE) IS
		vseancerow tseance%ROWTYPE;
	BEGIN
		IF getaccessmode() = access_limited
		THEN
			error.raiseerror(err.seance_access_limited, 'Set OperDate');
		END IF;
		err.seterror(0, 'custom_seance.SetOperDate');
	
		vseancerow          := sseancerow;
		vseancerow.operdate := trunc(poperdate);
	
		BEGIN
			UPDATE tseance
			SET    operdate     = vseancerow.operdate
				  ,flag         = vseancerow.flag
				  ,openclerkid  = vseancerow.openclerkid
				  ,opensysdate  = vseancerow.opensysdate
				  ,closeclerkid = vseancerow.closeclerkid
				  ,closesysdate = vseancerow.closesysdate
				  ,remark       = vseancerow.remark
			WHERE  branch = sseancerow.branch;
		EXCEPTION
			WHEN OTHERS THEN
				err.seterror(SQLCODE, 'custom_seance.SetOperDate');
				RETURN;
		END;
	
		sdummy     := a4mlog.logobject(object.gettype('BRANCH')
									  ,1
									  ,'Change business day - ' || htools.d2s(vseancerow.operdate));
		sseancerow := vseancerow;
		setdesktopcaption();
		cleargarbageofseanceid;
	
	END;

	PROCEDURE setclerk(pusername VARCHAR) IS
		vbranch CONSTANT NUMBER := custom_seance.getbranch();
	BEGIN
		SELECT *
		INTO   sclerkrow
		FROM   tclerk t
		WHERE  branch = vbranch
		AND    NAME = pusername
		AND    TYPE = clerk.cctactive;
	
		IF (sclerkrow.startupdate IS NOT NULL AND SYSDATE < sclerkrow.startupdate)
		   OR (sclerkrow.expirationdate IS NOT NULL AND SYSDATE > sclerkrow.expirationdate)
		THEN
			raiseerr('Access to system for operator ' || pusername ||
					 ' is blocked due to activity period restriction.');
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			IF SQLCODE = 100
			THEN
				err.seterror(err.clerk_not_found
							,'custom_seance.SetClerk(name = ' || pusername || ',user = ' || USER());
			ELSE
				error.save('custom_seance.SetClerk'
						  ,ptext => 'custom_seance.SetClerk(name = ' || pusername || ',user = ' ||
									USER());
				RAISE;
			
			END IF;
	END;

	FUNCTION getclerkcode RETURN NUMBER IS
	BEGIN
		RETURN nvl(sclerkrow.code, -1);
	END;
	FUNCTION getclerkclientid RETURN NUMBER IS
	BEGIN
		RETURN nvl(sclerkrow.clerkid, -1);
	END;
	FUNCTION getclerkuser RETURN VARCHAR IS
	BEGIN
		RETURN sclerkrow.name;
	END;

	PROCEDURE changeclerk(pusername VARCHAR) IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.ChangeClerk( pUserName = ' ||
											pusername || ')';
	BEGIN
		error.clear();
		IF NOT getmulticlerk
		THEN
			raiseerr('Prohibited to change current operator!');
		END IF;
		setclerk(pusername);
		error.raisewhenerr;
		a4mlog.logobjectsys(object.gettype('LOGIN')
						   ,USER()
						   ,'Change clerk: ' || pusername
						   ,paction => a4mlog.act_change);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE setregim(pregim IN NUMBER) IS
		vseancerow tseance%ROWTYPE;
		captured EXCEPTION;
	
	BEGIN
		IF getaccessmode = access_limited
		THEN
			error.raiseerror(err.seance_access_limited, 'Set Rejim');
		END IF;
		err.seterror(0, 'custom_seance.SetRegim');
	
		IF pregim = sseancerow.flag
		THEN
			RETURN;
		END IF;
	
		vseancerow := sseancerow;
	
		IF pregim = shared
		THEN
			vseancerow.openclerkid := getclerkcode;
			vseancerow.opensysdate := SYSDATE;
			vseancerow.flag        := shared;
		ELSE
			BEGIN
			
				IF object.setlock('LOGIN', '$$LOGIN$$RESOURCE$$')
				THEN
					RAISE captured;
				END IF;
			
				err.seterror(err.seance_login_timeout, 'custom_seance.SetRegim');
				RETURN;
			EXCEPTION
				WHEN captured THEN
					NULL;
			END;
		
			IF getcountactiveuser > 1
			THEN
			
				object.release('LOGIN', '$$LOGIN$$RESOURCE$$');
				err.seterror(err.seance_users_exist, 'custom_seance.SetRegim');
				RETURN;
			END IF;
			s.say('pRegim = ' || pregim, 3);
		
			IF pregim = exclusiv
			THEN
				vseancerow.openclerkid := getclerkcode;
				vseancerow.opensysdate := SYSDATE;
				vseancerow.flag        := exclusiv;
			ELSIF pregim = closed
			THEN
				vseancerow.closeclerkid := getclerkcode;
				vseancerow.closesysdate := SYSDATE;
				vseancerow.flag         := closed;
			ELSE
				object.release('LOGIN', '$$LOGIN$$RESOURCE$$');
				err.seterror(err.seance_bad_regim, 'custom_seance.SetRegim');
				RETURN;
			END IF;
		END IF;
	
		BEGIN
			UPDATE tseance
			SET    flag         = vseancerow.flag
				  ,openclerkid  = vseancerow.openclerkid
				  ,opensysdate  = vseancerow.opensysdate
				  ,closeclerkid = vseancerow.closeclerkid
				  ,closesysdate = vseancerow.closesysdate
				  ,remark       = vseancerow.remark
			WHERE  branch = sseancerow.branch;
		EXCEPTION
			WHEN OTHERS THEN
				object.release('LOGIN', '$$LOGIN$$RESOURCE$$');
				err.seterror(SQLCODE, 'custom_seance.SetRegim');
				RETURN;
		END;
	
		sseancerow := vseancerow;
		IF pregim != shared
		THEN
			object.release('LOGIN', '$$LOGIN$$RESOURCE$$');
		END IF;
	
		setdesktopcaption();
	END;

	PROCEDURE setregion(pregion IN VARCHAR) IS
	BEGIN
		sregion := pregion;
	END;

	PROCEDURE setstation(pstation IN NUMBER) IS
	BEGIN
		sstation := pstation;
	END;

	PROCEDURE sethostname(phostname VARCHAR) IS
	BEGIN
		shostname := phostname;
	END;

	FUNCTION gethostname RETURN VARCHAR IS
	BEGIN
		RETURN shostname;
	END;

	PROCEDURE settempoperdate(poperdate IN DATE) IS
	BEGIN
	
		stempoperdate := poperdate;
	
		setdesktopcaption();
	
	END;

	PROCEDURE cleargarbageofseanceid IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		TYPE typearr IS TABLE OF NUMBER INDEX BY VARCHAR(100);
		valive typearr;
	BEGIN
	
		FOR i IN (SELECT (sid || ',' || serial# || ',' || inst_id) AS NAME FROM gv$session)
		LOOP
			valive(i.name) := 1;
		END LOOP;
	
		FOR i IN (SELECT * FROM ta4mseance)
		LOOP
			IF NOT valive.exists(i.sid || ',' || i.serial# || ',' || i.inst_id)
			THEN
				DELETE FROM ta4mseance t
				WHERE  t.sid = i.sid
				AND    t.serial# = i.serial#
				AND    t.inst_id = i.inst_id;
			END IF;
		END LOOP;
	
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('clearGarbageofSeanceID');
			ROLLBACK;
	END;

	PROCEDURE clearseanceid_
	(
		psid     NUMBER
	   ,pserial  NUMBER
	   ,pinst_id NUMBER
	) IS
	BEGIN
		DELETE FROM ta4mseance
		WHERE  sid = psid
		AND    serial# = pserial
		AND    inst_id = pinst_id;
	END;

	PROCEDURE clearseanceid IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vsid     NUMBER;
		vserial  NUMBER;
		vinst_id NUMBER;
	BEGIN
		vsid     := htools.getsubstr(getuid(), 1, ',');
		vserial  := htools.getsubstr(getuid(), 2, ',');
		vinst_id := htools.getsubstr(getuid(), 3, ',');
		clearseanceid_(vsid, vserial, vinst_id);
	
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('custom_seance.clearSeanceID');
			ROLLBACK;
	END;

	PROCEDURE registerseanceid
	(
		psid    NUMBER
	   ,pserial NUMBER
	   ,pinst   NUMBER
	) IS
		vparent_sid    NUMBER;
		vparent_serial NUMBER;
	BEGIN
		vparent_sid    := htools.getsubstr(sparentuid, 1, ',');
		vparent_serial := htools.getsubstr(sparentuid, 2, ',');
		INSERT INTO ta4mseance
			(sid
			,serial#
			,inst_id
			,systemmode
			,hostname
			,branch
			,station
			,parent_sid
			,parent_serial#
			,startdate
			,accessmode)
		VALUES
			(psid
			,pserial
			,pinst
			,getsystemmode()
			,shostname
			,getbranch()
			,getstation()
			,vparent_sid
			,vparent_serial
			,SYSDATE
			,getaccessmode());
	EXCEPTION
		WHEN OTHERS THEN
			s.err('custom_seance.registerSeanceID');
			RAISE;
	END;

	PROCEDURE trackcrashsession(pperiod NUMBER) IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.trackCrashSession(' || pperiod || ')';
		TYPE typesessionlist IS TABLE OF DATE INDEX BY VARCHAR(30);
		vcrashlist typesessionlist;
		vfinlist   typesessionlist;
		vuid       VARCHAR(30);
	BEGIN
	
		FOR i IN (SELECT t.systemdate
						,t.session_uid
						,t.action
						,t.remark
				  FROM   tobjectlog t
				  WHERE  t.branch = custom_seance.getbranch
				  AND    t.typeobject = object.gettype('LOGIN')
				  AND    t.keyobject = USER()
				  AND    t.systemdate >= (SYSDATE - pperiod)
				  ORDER  BY t.systemdate DESC
						   ,no           DESC)
		LOOP
			CASE i.action
				WHEN a4mlog.act_enter THEN
					IF NOT vfinlist.exists(i.session_uid)
					THEN
						vcrashlist(i.session_uid) := i.systemdate;
					END IF;
				WHEN a4mlog.act_exit THEN
					vfinlist(i.session_uid) := i.systemdate;
				WHEN a4mlog.act_error THEN
					vfinlist(htools.getsubstr(i.remark, 2, '=')) := i.systemdate;
				ELSE
					NULL;
			END CASE;
		END LOOP;
	
		FOR i IN (SELECT * FROM gv$session t WHERE t.username = USER())
		LOOP
			vuid := i.sid || ',' || i.serial# || ',' || i.inst_id;
			IF vcrashlist.exists(vuid)
			   AND (i.logon_time >= vcrashlist(vuid))
			THEN
				vcrashlist.delete(vuid);
			END IF;
		END LOOP;
	
		vuid := vcrashlist.first;
		WHILE vuid IS NOT NULL
		LOOP
			a4mlog.logobject(object.gettype('LOGIN')
							,USER()
							,'Detected emergency termination of session UID=' || vuid
							,paction => a4mlog.act_error);
			vuid := vcrashlist.next(vuid);
		END LOOP;
	
		COMMIT;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			error.showstack(TRUE);
	END;

	PROCEDURE setseanceid IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vsid       NUMBER;
		vserial    NUMBER;
		vinst      NUMBER;
		vopt       options.typeseanceoptions;
		i          NUMBER;
		k          NUMBER;
		vgrouplist apitypes.typesecurgroupinfolist;
	BEGIN
		vsid    := htools.getsubstr(getuid(), 1, ',');
		vserial := htools.getsubstr(getuid(), 2, ',');
		vinst   := htools.getsubstr(getuid(), 3, ',');
		clearseanceid_(vsid, vserial, vinst);
		registerseanceid(vsid, vserial, vinst);
		COMMIT;
		vopt         := options.getseanceoptions();
		sidletimeout := vopt.idletimeout * 60;
		setidletimeout_(sidletimeout);
		sidletimeout := sidletimeout / (3600 * 24);
		setchecktimeout_(vopt.checktimeout);
	
		vgrouplist := security.getgroupsofuserlist(custom_seance.getclerkcode);
		i          := vopt.usergroup4idleignore.first;
		WHILE i IS NOT NULL
		LOOP
			k := vgrouplist.first;
			WHILE k IS NOT NULL
			LOOP
				IF vgrouplist(k).id = vopt.usergroup4idleignore(i)
				THEN
					sidleignore := TRUE;
					EXIT;
				END IF;
				k := vgrouplist.next(k);
			END LOOP;
			EXIT WHEN k IS NOT NULL;
			i := vopt.usergroup4idleignore.next(i);
		END LOOP;
	
		COMMIT;
		loginenv.refresh;
		IF vopt.istrackingcrash
		   AND sparentuid IS NULL
		THEN
			trackcrashsession(vopt.trackcrashperiod);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('custom_seance.setSeanceID');
			ROLLBACK;
	END;

	FUNCTION calldialog
	(
		pname    IN VARCHAR
	   ,pthis    BOOLEAN := FALSE
	   ,pcaption VARCHAR := NULL
	   ,picon    VARCHAR := NULL
	) RETURN NUMBER IS
		vdbms   NUMBER;
		vdialog NUMBER;
	BEGIN
		IF pthis
		THEN
			vdbms := dbms_sql.open_cursor;
			dbms_sql.parse(vdbms, 'begin :RET := ' || pname || '; end;', dbms_sql.v7);
			dbms_sql.bind_variable(vdbms, ':RET', vdialog);
			sdummy := dbms_sql.execute(vdbms);
			dbms_sql.variable_value(vdbms, ':RET', vdialog);
			dbms_sql.close_cursor(vdbms);
		
			dialog.exec(vdialog);
		ELSE
		
			term.startthread(nvl(pcaption, 'No Caption')
							,nvl(picon, 'appicon.bmp')
							,'begin dialog.exec(' || pname || '); end;');
		
		END IF;
		RETURN NULL;
	END;

	PROCEDURE logenv IS
		vip  VARCHAR(100);
		venv a4mlog.typepvlist;
	BEGIN
		s.say(getversion());
	
		venv('USER') := USER();
		venv('SYSTEMMODE') := getmodename(getsystemmode());
		venv('ACCESSMODE') := getaccessmode();
		a4mlog.setlogenv(venv);
	
		a4mlog.cleanparamlist;
		BEGIN
			IF getsystemmode NOT IN
			   (custom_seance.mode_sql, custom_seance.mode_none, custom_seance.mode_oms)
			THEN
				vip := term.applicationgetip();
			ELSE
				vip := sys_context('USERENV', 'IP_ADDRESS');
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				vip := '';
		END;
	
		s.say('=======================================================');
		s.say('Seance Environment Info:');
		s.say('________________________');
		s.say('User          : ' || USER);
		s.say('Sid,Serial    : ' || getuid);
		s.say('Station       : ' || getstation);
		s.say('Host          : ' || gethostname);
		s.say('Branch        : ' || getbranch);
		s.say('Business Day  : ' || getoperdate);
		s.say('System mode   : ' || getmodename(getsystemmode));
		s.say('Access mode   : ' || CASE getaccessmode() WHEN access_full THEN 'FULL' WHEN
			  access_limited THEN 'LIMITED' ELSE '???' END);
		s.say('TWCMS regim   : ' || CASE getregim WHEN custom_seance.exclusiv THEN 'Exclusive' WHEN
			  custom_seance.shared THEN 'Shared' WHEN custom_seance.closed THEN 'Closed' ELSE
			  'Unknown' END);
		s.say('TWCMS Version : ' || getappversion || '(' || getappbuild || ')');
		s.say('Oracle        : ' || javaport.getoracleversion);
		s.say('Instance      : ' || sys_context('USERENV', 'INSTANCE'));
		s.say('Service Name  : ' || sys_context('USERENV', 'SERVICE_NAME'));
		s.say('Machine       : ' || sys_context('USERENV', 'HOST'));
		s.say('Terminal      : ' || sys_context('USERENV', 'TERMINAL'));
		s.say('Program       : ' || sys_context('USERENV', 'MODULE'));
		s.say('IP address    : ' || vip);
	
		a4mlog.addparamrec('User', USER);
		a4mlog.addparamrec('Sid,Serial', getuid);
		a4mlog.addparamrec('Station', getstation);
		a4mlog.addparamrec('Host', gethostname);
		a4mlog.addparamrec('Branch', getbranch);
		a4mlog.addparamrec('Business Day', getoperdate);
		a4mlog.addparamrec('System mode', getmodename(getsystemmode));
		a4mlog.addparamrec('Access mode'
						  ,CASE getaccessmode() WHEN access_full THEN 'FULL' WHEN access_limited THEN
						   'LIMITED' ELSE '???' END);
		a4mlog.addparamrec('TWCMS regim'
						  ,CASE getregim WHEN custom_seance.exclusiv THEN 'Exclusive' WHEN
						   custom_seance.shared THEN 'Shared' WHEN custom_seance.closed THEN
						   'Closed' ELSE 'Unknown' END);
		a4mlog.addparamrec('TWCMS Version', getappversion || '(' || getappbuild || ')');
		a4mlog.addparamrec('Oracle', javaport.getoracleversion);
	
		a4mlog.addparamrec('Instance', sys_context('USERENV', 'INSTANCE'));
		a4mlog.addparamrec('Service Name', sys_context('USERENV', 'SERVICE_NAME'));
		a4mlog.addparamrec('Terminal', sys_context('USERENV', 'TERMINAL'));
		a4mlog.addparamrec('Machine', sys_context('USERENV', 'HOST'));
		a4mlog.addparamrec('Program', sys_context('USERENV', 'MODULE'));
		a4mlog.addparamrec('IP', vip);
	
		s.say('=======================================================');
		setclerk(USER);
		a4mlog.logobjectsys(object.gettype('LOGIN')
						   ,USER()
						   ,'Open TWCMS session. IP:' || vip
						   ,paction => a4mlog.act_enter
						   ,pparamlist => a4mlog.putparamlist);
	
	END;

	PROCEDURE altersession IS
	BEGIN
		htools.execsql('ALTER SESSION ENABLE COMMIT IN PROCEDURE');
		htools.execsql('ALTER SESSION SET NLS_TERRITORY = ''AMERICA''');
		htools.execsql('Alter Session Set NLS_NUMERIC_CHARACTERS = ''. ''');
	END;

	PROCEDURE init IS
		vcurrency NUMBER;
		vcountry  NUMBER;
		vregion   VARCHAR(20);
		vcity     NUMBER;
	BEGIN
	
		s.say('ALTER SESSION SET nls_date_format = ''' || htools.getdateformat() || '''');
		htools.execsql('ALTER SESSION SET nls_date_format = ''' || htools.getdateformat() || '''');
	
		sessionparam.applyparams;
	
		vcurrency := datamember.getnumber(object.gettype('BRANCH')
										 ,custom_seance.getbranch
										 ,'CURRENCY');
		IF vcurrency IS NULL
		THEN
			error.raiseerror('Currency code not specified for branch!');
		END IF;
		custom_seance.setcurrency(vcurrency);
	
		vcountry := datamember.getnumber(object.gettype('BRANCH')
										,custom_seance.getbranch
										,'COUNTRY');
		IF vcountry IS NULL
		THEN
			error.raiseerror('Country code not specified for branch~');
		END IF;
		custom_seance.setcountry(vcountry);
	
		vregion := datamember.getchar(object.gettype('BRANCH'), custom_seance.getbranch, 'REGION');
		IF vregion IS NULL
		THEN
			error.raiseerror('Region code not specified for branch');
		END IF;
		custom_seance.setregion(vregion);
	
		vcity := datamember.getnumber(object.gettype('BRANCH'), custom_seance.getbranch, 'CITYCODE');
		IF vcity IS NULL
		THEN
			error.raiseerror('City code not specified for branch');
		END IF;
		custom_seance.setcity(vcity);
	EXCEPTION
		WHEN OTHERS THEN
			error.save('custom_seance.init');
			RAISE;
	END;

	PROCEDURE extcallinit
	(
		pbranch  IN NUMBER
	   ,pstation IN NUMBER
	   ,pclerk   IN VARCHAR
	) IS
	BEGIN
		sdummy         := pclerk;
		a4m.sfloramode := TRUE;
		IF NOT login(mode_twrhi, pbranch, pstation)
		THEN
			raiseerr(' Login is failed!');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('custom_seance.ExtCallInit');
			RAISE;
	END;

	PROCEDURE captureresources
	(
		phostname VARCHAR
	   ,papp      NUMBER
	   ,pclerk    VARCHAR
	   ,pstation  NUMBER
	) IS
	BEGIN
		s.say('WARNING! Method custom_seance.CaptureResources not supported at 02.07.2007.');
		sdummy := phostname;
		sdummy := papp;
		sdummy := pclerk;
		sdummy := pstation;
	END;

	FUNCTION getuid RETURN VARCHAR IS
		vsid    NUMBER;
		vserial NUMBER;
		vinst   NUMBER;
	BEGIN
		IF suid IS NULL
		THEN
			SELECT v.sid INTO vsid FROM v$mystat v WHERE rownum = 1;
			SELECT v.serial# INTO vserial FROM v$session v WHERE v.sid = vsid;
			vinst := sys_context('userenv', 'instance');
			suid  := to_char(vsid) || ',' || to_char(vserial) || ',' || vinst;
		END IF;
		RETURN suid;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('custom_seance.GetUID');
			RAISE;
	END;

	PROCEDURE decodeuid
	(
		puid     VARCHAR
	   ,psid     OUT NUMBER
	   ,pserial# OUT NUMBER
	) IS
	BEGIN
		psid     := to_number(htools.getsubstr(puid, 1, ','));
		pserial# := to_number(htools.getsubstr(puid, 2, ','));
	EXCEPTION
		WHEN OTHERS THEN
			s.err('custom_seance.DecodeUID(||' || puid || ')');
			RAISE;
	END;

	PROCEDURE closesession IS
		vnul tseance%ROWTYPE;
		venv a4mlog.typepvlist;
	BEGIN
		clearseanceid;
		a4mlog.logobjectsys(object.gettype('LOGIN')
						   ,USER()
						   ,'Terminate TWCMS session'
						   ,paction => a4mlog.act_exit);
		sseancerow        := vnul;
		sseancerow.branch := 0;
		sbranchpart       := NULL;
		scountry          := NULL;
		scity             := NULL;
		sregion           := NULL;
		scurrency         := NULL;
		sstation          := NULL;
		sstarter          := NULL;
		stempoperdate     := NULL;
		stempbranch       := NULL;
	
		venv('USER') := NULL;
		venv('SYSTEMMODE') := NULL;
		venv('ACCESSMODE') := NULL;
		a4mlog.cleanlogenv(venv);
	
	END;

	PROCEDURE checkandrepairoraclerigths IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.CheckAndRepairOracleRigths()';
		vstr VARCHAR(32767);
	BEGIN
		s.say(cprocname || ' : start');
	
		s.say(cprocname || ' : check oracle context...');
		BEGIN
			SELECT t.object_name
			INTO   vstr
			FROM   all_objects t
			WHERE  t.owner = 'SYS'
			AND    t.object_type = 'CONTEXT'
			AND    t.object_name LIKE objectcontext.cnamespace;
		EXCEPTION
			WHEN no_data_found THEN
				EXECUTE IMMEDIATE 'create or replace context A4M_CONTEXT ' ||
								  'using A4M.ObjectContext accessed globally';
		END;
	
		s.say(cprocname || ' : check javaport...');
		BEGIN
			SELECT t.object_name
			INTO   vstr
			FROM   all_objects t
			WHERE  t.owner = 'PUBLIC'
			AND    t.object_type = 'SYNONYM'
			AND    t.object_name LIKE 'JAVAPORT';
		EXCEPTION
			WHEN no_data_found THEN
				EXECUTE IMMEDIATE 'create public synonym JavaPort for JavaPort';
		END;
		BEGIN
			SELECT t.table_name
			INTO   vstr
			FROM   user_tab_privs t
			WHERE  t.owner = 'A4M'
			AND    t.grantee = 'A4MSTARTUP'
			AND    t.table_name = 'JAVAPORT'
			AND    t.privilege = 'EXECUTE';
		EXCEPTION
			WHEN no_data_found THEN
				EXECUTE IMMEDIATE 'grant execute on javaport to a4mstartup';
		END;
	
		s.say(cprocname || ' : check custom_seance...');
		BEGIN
			SELECT t.object_name
			INTO   vstr
			FROM   all_objects t
			WHERE  t.owner = 'PUBLIC'
			AND    t.object_type = 'SYNONYM'
			AND    t.object_name LIKE 'SEANCE';
		EXCEPTION
			WHEN no_data_found THEN
				EXECUTE IMMEDIATE 'create public synonym Seance for Seance';
		END;
		BEGIN
			SELECT t.table_name
			INTO   vstr
			FROM   user_tab_privs t
			WHERE  t.owner = 'A4M'
			AND    t.grantee = 'A4MSTARTUP'
			AND    t.table_name = 'SEANCE'
			AND    t.privilege = 'EXECUTE';
		EXCEPTION
			WHEN no_data_found THEN
				EXECUTE IMMEDIATE 'grant execute on Seance to a4mstartup';
		END;
	
		s.say(cprocname || ' : check twcmserr(err)...');
		BEGIN
			SELECT t.object_name
			INTO   vstr
			FROM   all_objects t
			WHERE  t.owner = 'PUBLIC'
			AND    t.object_type = 'SYNONYM'
			AND    t.object_name LIKE 'TWCMSERROR';
		EXCEPTION
			WHEN no_data_found THEN
				EXECUTE IMMEDIATE 'create public synonym TWCMSError for Err';
		END;
		BEGIN
			SELECT t.table_name
			INTO   vstr
			FROM   user_tab_privs t
			WHERE  t.owner = 'A4M'
			AND    t.grantee = 'A4MSTARTUP'
			AND    t.table_name = 'ERR'
			AND    t.privilege = 'EXECUTE';
		EXCEPTION
			WHEN no_data_found THEN
				EXECUTE IMMEDIATE 'grant execute on TWCMSError to a4mstartup';
		END;
	
		s.say(cprocname || ' : check error...');
		BEGIN
			SELECT t.object_name
			INTO   vstr
			FROM   all_objects t
			WHERE  t.owner = 'PUBLIC'
			AND    t.object_type = 'SYNONYM'
			AND    t.object_name LIKE 'ERROR';
		EXCEPTION
			WHEN no_data_found THEN
				EXECUTE IMMEDIATE 'create public synonym Error for Error';
		END;
		BEGIN
			SELECT t.table_name
			INTO   vstr
			FROM   user_tab_privs t
			WHERE  t.owner = 'A4M'
			AND    t.grantee = 'A4MSTARTUP'
			AND    t.table_name = 'ERROR'
			AND    t.privilege = 'EXECUTE';
		EXCEPTION
			WHEN no_data_found THEN
				EXECUTE IMMEDIATE 'grant execute on Error to a4mstartup';
		END;
	
		s.say(cprocname || ' : check htools...');
		BEGIN
			SELECT t.object_name
			INTO   vstr
			FROM   all_objects t
			WHERE  t.owner = 'PUBLIC'
			AND    t.object_type = 'SYNONYM'
			AND    t.object_name LIKE 'HTOOLS';
		EXCEPTION
			WHEN no_data_found THEN
				EXECUTE IMMEDIATE 'create public synonym HTools for HTools';
		END;
		BEGIN
			SELECT t.table_name
			INTO   vstr
			FROM   user_tab_privs t
			WHERE  t.owner = 'A4M'
			AND    t.grantee = 'A4MSTARTUP'
			AND    t.table_name = 'HTOOLS'
			AND    t.privilege = 'EXECUTE';
		EXCEPTION
			WHEN no_data_found THEN
				EXECUTE IMMEDIATE 'grant execute on HTools to a4mstartup';
		END;
		s.say(cprocname || ' : OK');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION getcountactiveuser RETURN NUMBER IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.GetCountActiveUser()';
		vret NUMBER := 0;
	BEGIN
		FOR i IN (WITH s AS
					   (SELECT t.*
							 ,vs.username
					   FROM   ta4mseance t
							 ,gv$session vs
					   WHERE  t.branch = getbranch
					   AND    t.accessmode != custom_seance.access_limited
					   AND    vs.sid = t.sid
					   AND    vs.serial# = t.serial#
					   AND    vs.inst_id = t.inst_id
					   AND    vs.status != 'KILLED'
					   AND    t.startdate >= vs.logon_time)
					  SELECT *
					  FROM   s
					  WHERE  (parent_sid IS NULL)
					  OR     NOT EXISTS (SELECT 1
							  FROM   s s1
							  WHERE  s1.sid = s.parent_sid
							  AND    s1.serial# = s.parent_serial#))
		LOOP
			vret := vret + 1;
			s.say(cprocname || ': FOUND ' || i.username || '[' || i.sid || ',' || i.serial# || ', ' ||
				  i.inst_id || '] branch = ' || i.branch || ', mode = ' || i.systemmode);
		END LOOP;
	
		s.say('custom_seance.GetCountActiveUser = ' || vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cpackagename || '.GetCountActiveUser');
			RETURN NULL;
	END;

	PROCEDURE showdelayedmsg IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.ShowDelayedMsg()';
		PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
		FOR i IN (SELECT ROWID
						,t.*
				  FROM   tlogonmsg t
				  WHERE  branch = getbranch
				  AND    username = USER()
				  ORDER  BY created)
		LOOP
			IF nvl(i.expired > SYSDATE, TRUE)
			THEN
				CASE getsystemmode
					WHEN custom_seance.mode_twr THEN
						setlogonwarning(i.createdby || ':' || chr(13) || chr(10) || i.text);
					WHEN custom_seance.mode_bp THEN
						batchproc.msgwarning(i.createdby || ':' || i.text);
					ELSE
						s.say('Warning! Print Delayed Message: System mode not supported');
						s.say(i.createdby);
						s.say(i.text);
				END CASE;
			END IF;
			DELETE FROM tlogonmsg WHERE ROWID = i.rowid;
			COMMIT;
		END LOOP;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			ROLLBACK;
	END;

	PROCEDURE login
	(
		ptwcms_mode NUMBER
	   ,pbranch     NUMBER
	   ,pstation    NUMBER
	   ,paccessmode typeaccess
	   ,pmulticlerk BOOLEAN
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.OpenSession( MODE = ' || ptwcms_mode ||
											', Branch = ' || pbranch || ', Station = ' || pstation ||
											', Access = ' || paccessmode || '||, MultiClerk = ' ||
											htools.b2s(pmulticlerk) || ')';
		vbranchpart NUMBER;
		vhostname   VARCHAR(1000);
		vmsg        VARCHAR(4000);
		vflag       NUMBER;
		vaccessmode typeaccess := paccessmode;
	BEGIN
		IF javaport.isserviced = 'true'
		THEN
			raiseerr('TWCMS CLOSED FOR MAINTENANCE! / Attention! System ' ||
					 custom_seance.appshortname || ' is closed for maintenance!');
		END IF;
	
		error.clear();
		IF (ptwcms_mode = getsystemmode)
		   AND pbranch = getbranch
		   AND pstation = getstation
		THEN
			s.say(cprocname || ' : already logined');
			RETURN;
		END IF;
	
		debugsetup.init;
		IF USER() = 'A4M'
		THEN
			checkandrepairoraclerigths();
		END IF;
		s.init(FALSE);
		say(cprocname || ': start...');
	
		CASE ptwcms_mode
			WHEN custom_seance.mode_twr THEN
				raiseerr('Prohibited to set visual mode via this method. Use ITC.');
			WHEN custom_seance.mode_none THEN
				raiseerr('Inadmissible connection mode!');
			ELSE
				say(cprocname || ': set system mode...');
				setsystemmode(ptwcms_mode);
		END CASE;
	
		setaccessmode(vaccessmode);
	
		IF pmulticlerk
		THEN
			IF getsystemmode() IN
			   (custom_seance.mode_sql, custom_seance.mode_oms, custom_seance.mode_bp)
			THEN
				setmulticlerk(pmulticlerk);
			ELSE
				raiseerr('Prohibited to connect with "Multiclerk" option in this mode!');
			END IF;
		ELSE
			setmulticlerk(FALSE);
		END IF;
	
		say(cprocname || ': set Decimal separator = `.` ...');
		altersession;
		IF ptwcms_mode IN (mode_sql)
		THEN
			javaport.prepare(NULL);
		END IF;
		say(cprocname || ': set branch');
		openbranch(pbranch);
		say(cprocname || ': set station');
		custom_seance.setstation(pstation);
		logenv;
	
		debugsetup.init;
		sys_debugstackdisable;
	
		say(cprocname || ': detect BranchPart...');
		vbranchpart := referencebranchpart.getbranchpart(pstation);
		IF (vbranchpart IS NULL)
		THEN
			IF USER <> 'A4M'
			THEN
				raiseerr(cprocname || ' : Station not authorized!');
			ELSE
				vbranchpart := referencebranchpart.c_undefine_branchpart;
			END IF;
		END IF;
		custom_seance.setbranchpart(vbranchpart);
	
		init();
	
		IF ptwcms_mode IN (mode_bp, mode_twrhi, mode_oms)
		THEN
			say(cprocname || ': init Term, detect HostName...');
			IF NOT term.getenvos('host://HOST_NAME', vhostname)
			THEN
				say('Environment variable "HOST_NAME" (Application server name)~not defined.~');
				vhostname := NULL;
			END IF;
		ELSE
			vhostname := NULL;
		END IF;
	
		say(cprocname || ': detect User ...');
		error.clear();
		setclerk(USER);
		IF (err.geterrorcode = err.clerk_not_found)
		THEN
			BEGIN
				SELECT (v.machine || ':' || v.osuser)
				INTO   vmsg
				FROM   v$session v
				WHERE  v.audsid = userenv('SESSIONID')
				AND    rownum = 1;
			EXCEPTION
				WHEN OTHERS THEN
					vmsg := ' ip not definded';
			END;
			vmsg   := vmsg || ', Station: ' || pstation;
			sdummy := a4mlog.logobjectsys(object.gettype('LOGIN')
										 ,0
										 ,'System login attempt ' || custom_seance.appshortname ||
										  ' user ' || USER || ' !' || chr(10) || vmsg);
			raiseerr(cprocname || ' : System login attempt ' || custom_seance.appshortname ||
					 ' user ' || USER || ' ! Contact system administrator.');
		ELSE
			error.raisewhenerr;
		END IF;
	
		IF vaccessmode = access_limited
		THEN
			vmsg := 'LimitedA4M-' || getmodename(getsystemmode()) || '$' || vhostname || '$' ||
					custom_seance.getbranch() || '$' || custom_seance.getstation || '$' || 'MAIN';
		
		ELSE
			vmsg := 'A4M-' || getmodename(getsystemmode()) || '$' || vhostname || '$' ||
					custom_seance.getbranch() || '$' || custom_seance.getstation || '$' || 'MAIN';
		END IF;
		dbms_application_info.set_client_info(vmsg);
		setseanceid();
		vflag := custom_seance.getregim;
		say(cprocname || ' : regim = ' || vflag);
	
		IF getaccessmode = custom_seance.access_full
		THEN
			IF (nvl(vflag, custom_seance.closed) != custom_seance.shared)
			THEN
				IF vflag = custom_seance.exclusiv
				THEN
				
					IF ptwcms_mode = mode_bp
					THEN
						IF custom_seance.getcountactiveuser > 1
						THEN
							DECLARE
								vuser VARCHAR(32767);
								vlist monitor.typesessioninfolist;
							BEGIN
								vlist := monitor.getsessioninfo(TRUE, custom_seance.mode_twr);
								FOR i IN 1 .. vlist.count
								LOOP
									EXIT WHEN length(vuser) > 32000;
									IF NOT custom_seance.getuid LIKE vlist(i).sid || ',%'
									THEN
										vuser := vuser || vlist(i).username || ',';
									END IF;
								END LOOP;
							
								vlist := monitor.getsessioninfo(TRUE, custom_seance.mode_bp);
								FOR i IN 1 .. vlist.count
								LOOP
									EXIT WHEN length(vuser) > 32000;
									IF NOT custom_seance.getuid LIKE vlist(i).sid || ',%'
									THEN
										vuser := vuser || vlist(i).username || ',';
									END IF;
								END LOOP;
							
								IF vuser IS NOT NULL
								THEN
									vuser := substr(vuser, 1, length(vuser) - 1);
									vuser := 'User is in system: ' || vuser || '~';
								END IF;
								raiseerr('System ' || custom_seance.appshortname ||
										 ' in EXCLUSIVE access mode.~' || vuser ||
										 'Impossible to continue.~');
							EXCEPTION
								WHEN OTHERS THEN
									error.save(cprocname);
									IF SQLCODE = -20100
									THEN
										RAISE;
									END IF;
									raiseerr('System ' || custom_seance.appshortname ||
											 ' in EXCLUSIVE access mode.~' ||
											 'Impossible to continue.~' || SQLERRM);
							END;
						END IF;
					
					ELSE
						raiseerr(cprocname || ' : ' || 'System ' || custom_seance.appshortname ||
								 ' in EXCLUSIVE access mode. Impossible to continue.');
					END IF;
				ELSIF vflag = custom_seance.closed
				THEN
				
					IF ptwcms_mode = mode_bp
					THEN
						IF custom_seance.getcountactiveuser > 1
						THEN
							DECLARE
								vuser VARCHAR(32767);
								vlist monitor.typesessioninfolist;
							BEGIN
								vlist := monitor.getsessioninfo(TRUE, custom_seance.mode_twr);
								FOR i IN 1 .. vlist.count
								LOOP
									EXIT WHEN length(vuser) > 32000;
									IF NOT custom_seance.getuid LIKE vlist(i).sid || ',%'
									THEN
										vuser := vuser || vlist(i).username || ',';
									END IF;
								END LOOP;
								vlist := monitor.getsessioninfo(TRUE, custom_seance.mode_bp);
								FOR i IN 1 .. vlist.count
								LOOP
									EXIT WHEN length(vuser) > 32000;
									IF NOT custom_seance.getuid LIKE vlist(i).sid || ',%'
									THEN
										vuser := vuser || vlist(i).username || ',';
									END IF;
								END LOOP;
								IF vuser IS NOT NULL
								THEN
									vuser := substr(vuser, 1, length(vuser) - 1);
									vuser := 'User is in system: ' || vuser || '~';
								END IF;
								raiseerr('Business day of system ' || custom_seance.appshortname ||
										 ' still CLOSED.~' || vuser || 'Impossible to continue.~');
							EXCEPTION
								WHEN OTHERS THEN
									error.save(cprocname);
									IF SQLCODE = -20100
									THEN
										RAISE;
									END IF;
									raiseerr('Business day of system ' ||
											 custom_seance.appshortname || ' still CLOSED.~' ||
											 'Impossible to continue.~' || SQLERRM);
							END;
						END IF;
					ELSE
						raiseerr(cprocname || ' : ' || 'Business day of system ' ||
								 custom_seance.appshortname ||
								 ' still CLOSED. You will be notified of business time opening.');
					END IF;
				
				ELSE
					raiseerr(cprocname || ' : ' || 'System internal error ' ||
							 custom_seance.appshortname ||
							 '! Business day is in UNDETERMINED state (' || to_char(vflag) ||
							 '). Contact system administrator.');
				END IF;
			END IF;
		END IF;
		cpiexpire.verify;
		say(cprocname || ': ..end.');
		IF getsystemmode = mode_bp
		THEN
			showdelayedmsg;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			logout;
			RAISE;
		
	END;

	FUNCTION login
	(
		ptwcms_mode NUMBER
	   ,pbranch     NUMBER
	   ,pstation    NUMBER
	) RETURN BOOLEAN IS
	BEGIN
		login(ptwcms_mode, pbranch, pstation);
		RETURN TRUE;
	END;

	PROCEDURE logout IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.Logout';
	BEGIN
		say(cprocname || ' : start...');
		IF getsystemmode = custom_seance.mode_twr
		   AND sparentuid IS NULL
		THEN
			say('unlock user and station ...');
			object.release('LOGIN', getclerkuser);
			object.release('LOGIN', 'STATION' || to_char(custom_seance.getstation));
			term.fullexit;
		END IF;
		closesession;
		dbms_application_info.set_client_info('-nothing-');
		setsystemmode(mode_none);
		say(cprocname || ' : ..end.');
	
		sys_debugstackenable;
	
		sys_setdebugdir(NULL);
		sys_reinitdebug(0);
	
		debugsetup.init;
	END;

	PROCEDURE a4mstartup
	(
		pparams VARCHAR
	   ,pcid    VARCHAR
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.A4MStartUp()';
	BEGIN
		IF NOT nvl(sys_check_(pcid) = 1, FALSE)
		THEN
			raiseerr(cpackagename || '.A4MStartUp : ' || 'ACCESS DENIED');
		END IF;
	
		IF custom_seance.getsystemmode != custom_seance.mode_none
		THEN
			custom_seance.logout();
		END IF;
	
		debugsetup.init;
		IF USER() = 'A4M'
		THEN
			checkandrepairoraclerigths();
		END IF;
		sys_setdebugmode(debug.cstatus_full);
		sys_debugstackenable;
		term.senddebugmsg(cpackagename || '.A4MStartUP(' || pparams || ')');
		s.init(TRUE);
		setsystemmode(mode_twr);
		setaccessmode(access_full);
		setmulticlerk(FALSE);
		startitc;
		setseanceid();
		debugsetup.init;
		sys_debugstackdisable;
		cpiexpire.verify;
		IF (getregim() IN (custom_seance.shared, custom_seance.exclusiv) AND
		   trunc(custom_seance.getoperdate) != trunc(SYSDATE))
		THEN
			showoperdaywarning;
		END IF;
		showdelayedmsg;
		IF swarning IS NOT NULL
		THEN
			htools.message('Warning!', substr(swarning, 1, 8000));
		END IF;
	EXCEPTION
		WHEN error.exiterror THEN
			s.err(cprocname);
			s.say('EXIT');
	END;

	FUNCTION checkcid(pcid VARCHAR) RETURN BOOLEAN IS
	BEGIN
		IF pcid = cid
		THEN
			RETURN TRUE;
		END IF;
		RETURN FALSE;
	END;

	PROCEDURE startmainthread_(pparam types.arrtext) IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.StartMainThread_()';
		vmode NUMBER;
	BEGIN
	
		s.say(cprocname);
		vmode := getsystemmode();
		setsystemmode(custom_seance.mode_none);
		login(ptwcms_mode => vmode
			 ,pbranch     => pparam(3)
			 ,pstation    => pparam(4)
			 ,paccessmode => pparam(5)
			 ,pmulticlerk => htools.i2b(pparam(8)));
	
		BEGIN
			say(cpackagename || '.StartMainThread_ : exec: ' || pparam(16));
			CASE to_number(pparam(12))
				WHEN 0 THEN
					EXECUTE IMMEDIATE pparam(16);
				WHEN 1 THEN
					EXECUTE IMMEDIATE pparam(16)
						USING pparam(13);
				WHEN 2 THEN
					EXECUTE IMMEDIATE pparam(16)
						USING pparam(13), pparam(14);
				WHEN 3 THEN
					EXECUTE IMMEDIATE pparam(16)
						USING pparam(13), pparam(14), pparam(15);
				ELSE
					raiseerr(cpackagename || '.StartChildThread : ' ||
							 ' Run SQL: Wrong count parameIt done not parameters for child thread!!!');
			END CASE;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.StartMainThread_.exec');
				RAISE;
		END;
	
		logout;
		term.sys_exit;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE startchildthread
	(
		papptype VARCHAR
	   ,pparams  VARCHAR
	   ,pcid     VARCHAR
	) IS
		cprocname CONSTANT VARCHAR(32000) := cpackagename || '.StartChildTread(AppType = ' ||
											 papptype || ', params = <' || pparams || '>)';
	
		vexit  PLS_INTEGER;
		vmsg   VARCHAR(32000);
		vparam types.arrtext;
	BEGIN
	
		s.init(TRUE);
		IF NOT nvl(sys_check_(pcid) = 1, FALSE)
		THEN
			raiseerr(cpackagename || '.A4MStartUp : ' || 'ACCESS DENIED');
		END IF;
	
		IF javaport.isserviced = 'true'
		THEN
			raiseerr('Attention! System ' || custom_seance.appshortname ||
					 ' is closed for maintenance!');
		END IF;
		term.setsessionlivemode(2);
		IF custom_seance.getsystemmode != custom_seance.mode_none
		THEN
			custom_seance.logout();
		END IF;
	
		sys_debugstackenable;
		sys_setdebugmode(debug.cstatus_full);
		debugsetup.init;
	
		IF NOT nvl(sys_check_(pcid) = 1, FALSE)
		THEN
			raiseerr(cpackagename || '.StartChildThread : ' || 'ACCESS DENIED');
		END IF;
		IF papptype NOT IN ('ITC', 'BP', 'TWRHI', 'WEB')
		THEN
			raiseerr(cpackagename || '.StartChildThread : ' || 'Wrong application type [' ||
					 papptype || ']!');
		END IF;
		say(cprocname || ' start... ');
		setsystemmode(CASE papptype WHEN 'ITC' THEN custom_seance.mode_twr WHEN 'BP' THEN
					  custom_seance.mode_bp WHEN 'TWRHI' THEN custom_seance.mode_twrhi WHEN 'WEB' THEN
					  custom_seance.mode_oms ELSE NULL END);
		altersession;
	
		vparam := htools.parsestring(pparams, '~', '/');
		IF vparam.count != 16
		THEN
			raiseerr(cpackagename || '.StartChildThread : ' ||
					 'Invalid params : Wrong number parameters (' || vparam.count || '!!!');
		END IF;
	
		IF NOT htools.equal(vparam(1), 'START_CHILD_THREAD')
		THEN
			raiseerr(cpackagename || '.StartChildThread : ' ||
					 'Invalid params : It done not parameters for child thread!!!');
		END IF;
	
		IF htools.equal(vparam(2), 'AS_MAIN_THREAD')
		THEN
			say(cprocname || ': run as Main...');
			startmainthread_(vparam);
			RETURN;
		END IF;
	
		say('set branch...');
		openbranch(vparam(2));
	
		say(' set branchpart...:' || vparam(3));
		custom_seance.setbranchpart(vparam(3));
	
		say(' set station...:' || vparam(4));
	
		custom_seance.setstation(vparam(4));
	
		say(' set access mode ...:' || vparam(5));
		setaccessmode(vparam(5));
	
		logenv;
	
		say('reinit debug...');
		debugsetup.init;
		sys_debugstackdisable;
	
		say(' set SessionID... :' || vparam(6));
		a4m.setmainsessionid(vparam(6), cid);
	
		say(' set Parent UID... :' || vparam(7));
		sparentuid := vparam(7);
	
		debug.setdebugstatus(debug.ctype_rdbms
							,debug.clevel_self
							,debug.getdebugstatus_(debug.ctype_rdbms
												  ,debug.clevel_self
												  ,sparentuid));
		debug.refreshdebugstatus(pnow => TRUE);
		IF debug.getdebugstatus(debug.ctype_rdbms) IN (debug.cstatus_on, debug.cstatus_full)
		THEN
			s.setlevel(NULL);
			s.setid(NULL);
		END IF;
	
		say(' set OperDate...:' || vparam(8));
		custom_seance.settempoperdate(to_date(vparam(8), 'dd/mm/yyyy'));
	
		say(' set Exitmode...:' || vparam(9));
		vexit := vparam(9);
	
		say(' set Session for Log...:' || vparam(10));
		a4mlog.initsession(vparam(10));
	
		IF getsystemmode = custom_seance.mode_twr
		THEN
			say(' set Icon...:' || vparam(11));
			IF vparam(11) IS NOT NULL
			   AND vparam(11) != '""'
			THEN
				dialog.setpicture(0, vparam(11));
			END IF;
		ELSE
			say(' skip set Icon.');
		END IF;
	
		init();
	
		IF getsystemmode() IN (mode_twr, mode_bp, mode_twrhi, mode_oms)
		THEN
			say(cpackagename || '.StartChildThread : ' || 'init Term, detect HostName...');
			IF NOT term.getenvos('host://HOST_NAME', shostname)
			THEN
				say('Environment variable "HOST_NAME" (Application server name)~not defined.~');
				shostname := NULL;
			END IF;
		ELSE
			shostname := NULL;
		END IF;
	
		IF getaccessmode = access_limited
		THEN
			vmsg := 'LimitedA4M-' || getmodename(getsystemmode()) || '$' || gethostname || '$' ||
					custom_seance.getbranch() || '$' || custom_seance.getstation || '$' || 'CHILD';
		ELSE
			vmsg := 'A4M-' || getmodename(getsystemmode()) || '$' || gethostname || '$' ||
					custom_seance.getbranch() || '$' || custom_seance.getstation || '$' || 'CHILD';
		END IF;
		dbms_application_info.set_client_info(vmsg);
	
		setseanceid();
	
		IF getsystemmode = mode_bp
		THEN
			batchproc.init('BPHandler');
		END IF;
		err.seterror(0, cprocname);
		setclerk(USER);
		error.raisewhenerr;
	
		IF getsystemmode = custom_seance.mode_twr
		THEN
			createappsubmenu();
		END IF;
	
		IF vexit = 2
		THEN
			term.setsessionlivemode(2);
		ELSE
			term.setsessionlivemode(0);
		END IF;
	
		BEGIN
			say(cpackagename || '.StartChildThread : exec: ' || vparam(16));
			CASE to_number(vparam(12))
				WHEN 0 THEN
					EXECUTE IMMEDIATE vparam(16);
				WHEN 1 THEN
					EXECUTE IMMEDIATE vparam(16)
						USING vparam(13);
				WHEN 2 THEN
					EXECUTE IMMEDIATE vparam(16)
						USING vparam(13), vparam(14);
				WHEN 3 THEN
					EXECUTE IMMEDIATE vparam(16)
						USING vparam(13), vparam(14), vparam(15);
				ELSE
					raiseerr(cpackagename || '.StartChildThread : ' ||
							 ' Run SQL: Wrong count parameIt done not parameters for child thread!!!');
			END CASE;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.StartChildThread.exec');
				RAISE;
		END;
	
		logout;
		term.sys_exit;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION makestartchildparams
	(
		pcallsql    VARCHAR
	   ,pparamcount NUMBER
	   ,pparam1     VARCHAR
	   ,pparam2     VARCHAR
	   ,pparam3     VARCHAR
	) RETURN VARCHAR IS
		vparam types.arrtext;
	BEGIN
		vparam(1) := 'START_CHILD_THREAD';
		vparam(2) := custom_seance.getbranch();
		vparam(3) := custom_seance.getbranchpart();
		vparam(4) := custom_seance.getstation();
		vparam(5) := custom_seance.getaccessmode();
		vparam(6) := userenv('SESSIONID');
		vparam(7) := custom_seance.getuid();
		vparam(8) := to_char(custom_seance.getoperdate(), 'dd/mm/yyyy');
		vparam(9) := 1;
		vparam(10) := a4mlog.getsession();
		vparam(11) := NULL;
		vparam(12) := pparamcount;
		vparam(13) := pparam1;
		vparam(14) := pparam2;
		vparam(15) := pparam3;
		vparam(16) := pcallsql;
	
		RETURN htools.makestring(vparam, '~', '/');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.makeStartChildParams');
			RAISE;
	END;

	PROCEDURE startchildthreadora
	(
		pparams VARCHAR
	   ,pcid    VARCHAR
	) IS
		cprocname CONSTANT VARCHAR(32000) := cpackagename || '.StartChildTreadOra(params = <' ||
											 pparams || '>)';
		vmsg   VARCHAR(32000);
		vparam types.arrtext;
	BEGIN
	
		s.init(TRUE);
		IF javaport.isserviced = 'true'
		THEN
			raiseerr('Attention! System ' || custom_seance.appshortname ||
					 ' is closed for maintenance!');
		END IF;
		IF custom_seance.getsystemmode != custom_seance.mode_none
		THEN
			custom_seance.logout();
		END IF;
		sys_debugstackenable;
		sys_setdebugmode(debug.cstatus_full);
		debugsetup.init;
		IF NOT service.checkcid(pcid)
		THEN
			raiseerr(cpackagename || '.StartChildThreadOra : ' || 'ACCESS DENIED');
		END IF;
		say(cprocname || ' start... ');
		setsystemmode(custom_seance.mode_sql);
		altersession;
	
		vparam := htools.parsestring(pparams, '~', '/');
		IF vparam.count != 16
		THEN
			raiseerr(cpackagename || '.StartChildThread : ' ||
					 'Invalid params : Wrong number parameters (' || vparam.count || '!!!');
		END IF;
	
		IF NOT htools.equal(vparam(1), 'START_CHILD_THREAD')
		THEN
			raiseerr(cpackagename || '.StartChildThread : ' ||
					 'Invalid params : It done not parameters for child thread!!!');
		END IF;
	
		say('set branch...');
		openbranch(vparam(2));
	
		say(' set branchpart...:' || vparam(3));
		custom_seance.setbranchpart(vparam(3));
	
		say(' set station...:' || vparam(4));
		custom_seance.setstation(vparam(4));
	
		say(' set access mode ...:' || vparam(5));
		setaccessmode(vparam(5));
	
		logenv;
	
		say('reinit debug...');
		debugsetup.init;
		sys_debugstackdisable;
	
		say(' set SessionID... :' || vparam(6));
		a4m.setmainsessionid(vparam(6), cid);
	
		say(' set Parent UID... :' || vparam(7));
		sparentuid := vparam(7);
		debug.setdebugstatus(debug.ctype_rdbms
							,debug.clevel_self
							,debug.getdebugstatus_(debug.ctype_rdbms
												  ,debug.clevel_self
												  ,sparentuid));
		debug.refreshdebugstatus(pnow => TRUE);
	
		IF debug.getdebugstatus(debug.ctype_rdbms) IN (debug.cstatus_on, debug.cstatus_full)
		THEN
			s.setlevel(NULL);
			s.setid(NULL);
		END IF;
	
		say(' set OperDate...:' || vparam(8));
		custom_seance.settempoperdate(to_date(vparam(8), 'dd/mm/yyyy'));
	
		say(' set Session for Log...:' || vparam(10));
		a4mlog.initsession(vparam(10));
	
		say(' skip set Icon.');
	
		init();
	
		shostname := NULL;
	
		IF getaccessmode = access_limited
		THEN
			vmsg := 'LimitedA4M-' || getmodename(getsystemmode()) || '$' || gethostname || '$' ||
					custom_seance.getbranch() || '$' || custom_seance.getstation || '$' || 'CHILD';
		ELSE
			vmsg := 'A4M-' || getmodename(getsystemmode()) || '$' || gethostname || '$' ||
					custom_seance.getbranch() || '$' || custom_seance.getstation || '$' || 'CHILD';
		END IF;
		dbms_application_info.set_client_info(vmsg);
	
		setseanceid();
	
		err.seterror(0, cprocname);
		setclerk(USER);
		error.raisewhenerr;
	
		BEGIN
			say(cpackagename || '.StartChildThread : exec: ' || vparam(16));
			CASE to_number(vparam(12))
				WHEN 0 THEN
					EXECUTE IMMEDIATE vparam(16);
				WHEN 1 THEN
					EXECUTE IMMEDIATE vparam(16)
						USING vparam(13);
				WHEN 2 THEN
					EXECUTE IMMEDIATE vparam(16)
						USING vparam(13), vparam(14);
				WHEN 3 THEN
					EXECUTE IMMEDIATE vparam(16)
						USING vparam(13), vparam(14), vparam(15);
				ELSE
					raiseerr(cpackagename || '.StartChildThread : ' ||
							 ' Run SQL: Wrong count parameIt done not parameters for child thread!!!');
			END CASE;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.StartChildThread.exec');
				RAISE;
		END;
	
		logout;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			logout;
			RAISE;
	END;

	FUNCTION getlanguage RETURN PLS_INTEGER IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.GetLanguage';
	BEGIN
		FOR i IN (SELECT upper(product) product FROM tupg_version)
		LOOP
			CASE i.product
				WHEN 'TWRR' THEN
					RETURN clang_rus;
				WHEN 'TWRE' THEN
					RETURN clang_eng;
				ELSE
					NULL;
			END CASE;
		END LOOP;
		RETURN NULL;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RETURN NULL;
	END;

	PROCEDURE setlogonwarning(ptext VARCHAR) IS
	BEGIN
		IF swarning IS NULL
		THEN
			swarning := ptext;
		ELSE
			swarning := swarning || chr(10) || chr(10) || ptext;
		END IF;
	END;

	PROCEDURE changeuserawaystatus
	(
		pstatus NUMBER
	   ,pcid    VARCHAR
	) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.changeUserAwayStatus()';
		vsid    NUMBER;
		vserial NUMBER;
		vinst   NUMBER;
	BEGIN
		IF NOT nvl(sys_check_(pcid) = 1, FALSE)
		THEN
			raiseerr(cpackagename || '.changeUserAwayStatus : ' || 'ACCESS DENIED');
		END IF;
		vsid    := htools.getsubstr(getuid(), 1, ',');
		vserial := htools.getsubstr(getuid(), 2, ',');
		vinst   := htools.getsubstr(getuid(), 3, ',');
		UPDATE ta4mseance t
		SET    user_away = pstatus
		WHERE  t.sid = vsid
		AND    t.serial# = vserial
		AND    t.inst_id = vinst;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			ROLLBACK;
			RAISE;
	END;

	FUNCTION getmainuid RETURN VARCHAR IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.getMainUID';
		vinfo         ta4mseance%ROWTYPE;
		vcyclecontrol PLS_INTEGER := 100;
	BEGIN
		SELECT *
		INTO   vinfo
		FROM   ta4mseance
		WHERE  sid = to_number(htools.getsubstr(getuid(), 1, ','))
		AND    serial# = to_number(htools.getsubstr(getuid(), 2, ','))
		AND    inst_id = to_number(htools.getsubstr(getuid(), 3, ','));
		IF vinfo.parent_sid IS NULL
		THEN
			RETURN getuid();
		END IF;
		WHILE vinfo.sid IS NOT NULL
		LOOP
			vcyclecontrol := vcyclecontrol - 1;
			IF vcyclecontrol < 0
			THEN
				raiseerr(cprocname || ' : CYCLING!!!');
			END IF;
			BEGIN
				SELECT *
				INTO   vinfo
				FROM   ta4mseance t
				WHERE  sid = vinfo.parent_sid
				AND    serial# = vinfo.parent_serial#
				AND    branch = vinfo.branch
				AND    EXISTS (SELECT 1
						FROM   gv$session
						WHERE  sid = t.sid
						AND    serial# = t.serial#
						AND    inst_id = t.inst_id);
			EXCEPTION
				WHEN no_data_found THEN
					RETURN TRIM(to_char(vinfo.sid)) || ',' || TRIM(to_char(vinfo.serial#)) || ',' || TRIM(to_char(vinfo.inst_id));
			END;
		END LOOP;
		raiseerr(cprocname || ' : parent session not found');
		RETURN NULL;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION isallchildidle
	(
		pparentsid     NUMBER
	   ,pparentserial# NUMBER
	   ,pcontrol       NUMBER := 0
	) RETURN BOOLEAN IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.isAllChildIdle(' || pparentsid || ',' ||
											pparentserial# || ')';
	BEGIN
		IF pcontrol >= 100
		THEN
			raiseerr(cprocname || ' : INFINITE RECURSION!!!');
		END IF;
		FOR i IN (SELECT *
				  FROM   ta4mseance t
				  WHERE  t.parent_sid = pparentsid
				  AND    t.parent_serial# = pparentserial#
				  AND    t.branch = getbranch
				  AND    EXISTS (SELECT 1
						  FROM   gv$session v
						  WHERE  v.sid = t.sid
						  AND    v.serial# = t.serial#
						  AND    v.inst_id = t.inst_id
						  AND    v.logon_time <= t.startdate)
				  
				  )
		LOOP
			IF i.idle_start IS NULL
			THEN
				RETURN FALSE;
			END IF;
			IF NOT isallchildidle(i.sid, i.serial#, pcontrol + 1)
			THEN
				RETURN FALSE;
			END IF;
		END LOOP;
		RETURN TRUE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE changeidlestatus
	(
		pstatus NUMBER
	   ,pcid    VARCHAR
	) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.changeIdleStation';
		vinfo    ta4mseance%ROWTYPE;
		voptions options.typeseanceoptions;
		vmainuid VARCHAR(100);
		PROCEDURE markkill
		(
			psid     NUMBER
		   ,pserial  NUMBER
		   ,pinst_id NUMBER
		   ,pcontrol NUMBER := 0
		) IS
		
		BEGIN
			s.say('custom_seance.markKill ( ' || psid || ',' || pserial || ',' || pinst_id || ')');
			IF pcontrol >= 50
			THEN
				error.raiseerror(cprocname || ': INFINITE RECURSION!!!');
			END IF;
		
			UPDATE ta4mseance
			SET    kill_date = SYSDATE
			WHERE  sid = psid
			AND    serial# = pserial
			AND    inst_id = pinst_id
			AND    kill_date IS NULL;
			IF SQL%ROWCOUNT = 0
			THEN
				RETURN;
			END IF;
			FOR i IN (SELECT sid
							,serial#
							,inst_id
					  FROM   ta4mseance t
					  WHERE  t.parent_sid = psid
					  AND    t.parent_serial# = pserial
					  AND    t.inst_id = pinst_id)
			LOOP
				markkill(i.sid, i.serial#, i.inst_id, pcontrol + 1);
			END LOOP;
		END;
	BEGIN
		IF NOT nvl(sys_check_(pcid) = 1, FALSE)
		THEN
			raiseerr(cpackagename || '.changeIdleStatus : ' || 'ACCESS DENIED');
		END IF;
	
		SELECT *
		INTO   vinfo
		FROM   ta4mseance t
		WHERE  t.sid = to_number(htools.getsubstr(getuid(), 1, ','))
		AND    t.serial# = to_number(htools.getsubstr(getuid(), 2, ','))
		AND    t.inst_id = to_number(htools.getsubstr(getuid(), 3, ','));
	
		IF ((vinfo.idle_start IS NULL) AND (pstatus = 1))
		THEN
			vinfo.idle_start := SYSDATE - sidletimeout;
			UPDATE ta4mseance t
			SET    idle_start = vinfo.idle_start
			WHERE  t.sid = vinfo.sid
			AND    t.serial# = vinfo.serial#
			AND    t.inst_id = vinfo.inst_id;
			COMMIT;
		ELSIF ((vinfo.idle_start IS NOT NULL) AND (pstatus = 0))
		THEN
			UPDATE ta4mseance t
			SET    idle_start = NULL
			WHERE  t.sid = vinfo.sid
			AND    t.serial# = vinfo.serial#
			AND    t.inst_id = vinfo.inst_id;
			COMMIT;
		END IF;
		IF pstatus = 0
		THEN
			RETURN;
		END IF;
		voptions := options.getseanceoptions();
		IF voptions.autokillidlesession
		THEN
			IF sidleignore
			THEN
				RETURN;
			END IF;
		
			vmainuid := getmainuid();
			SELECT *
			INTO   vinfo
			FROM   ta4mseance t
			WHERE  t.sid = to_number(htools.getsubstr(vmainuid, 1, ','))
			AND    t.serial# = to_number(htools.getsubstr(vmainuid, 2, ','))
			AND    t.inst_id = to_number(htools.getsubstr(vmainuid, 3, ','));
		
			IF getsystemmode = mode_twr
			   AND voptions.autokillonlyaway
			   AND nvl(vinfo.user_away, 0) = 0
			THEN
				RETURN;
			END IF;
		
			IF vinfo.idle_start IS NOT NULL
			   AND isallchildidle(vinfo.sid, vinfo.serial#)
			THEN
				markkill(vinfo.sid, vinfo.serial#, vinfo.inst_id);
				BEGIN
					term.applicationclose(term.proc_id);
					dbms_lock.sleep(1);
				EXCEPTION
					WHEN OTHERS THEN
						NULL;
				END;
				COMMIT;
			END IF;
		END IF;
	
	EXCEPTION
		WHEN no_data_found THEN
			error.save(cprocname);
			NULL;
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE sendnotify4user
	(
		puser    VARCHAR
	   ,ptext    VARCHAR
	   ,pfrom    VARCHAR := NULL
	   ,pexpired DATE := NULL
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.SendNotify4User(' || puser || ')';
		PRAGMA AUTONOMOUS_TRANSACTION;
		vrow        tlogonmsg%ROWTYPE;
		vuseronline BOOLEAN := FALSE;
		vproc       VARCHAR(100);
	BEGIN
		vrow.branch := getbranch;
		BEGIN
			SELECT username INTO vrow.username FROM all_users WHERE username = puser;
		EXCEPTION
			WHEN no_data_found THEN
				error.raiseerror('Nonexistent user "' || puser || '" specified as payee');
		END;
		IF TRIM(ptext) IS NULL
		THEN
			error.raiseerror('Message text must be specified');
		END IF;
		vrow.text      := ptext;
		vrow.created   := SYSDATE;
		vrow.createdby := nvl(pfrom, USER());
		IF pexpired < vrow.created
		THEN
			error.raiseerror('Message is out of date');
		END IF;
		vrow.expired := pexpired;
	
		BEGIN
			SELECT s.process
			INTO   vproc
			FROM   v$session  s
				  ,ta4mseance a
			WHERE  s.username = puser
			AND    a.sid = s.sid
			AND    a.serial# = s.serial#
			AND    a.branch = custom_seance.getbranch
			AND    a.parent_sid IS NULL
			AND    rownum = 1
			AND    a.systemmode = custom_seance.mode_twr;
			vuseronline := TRUE;
		EXCEPTION
			WHEN no_data_found THEN
				vuseronline := FALSE;
		END;
	
		IF vuseronline
		THEN
			term.applicationmessage(pprocid     => htools.getsubstr(vproc, 1, ':')
								   ,pdescr      => vrow.createdby
								   ,pappmsgtype => term.app_msg_type_noreply
								   ,pdata       => vrow.text
								   ,pdescrfrom  => vrow.createdby);
		ELSE
		
			INSERT INTO tlogonmsg VALUES vrow;
		END IF;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			ROLLBACK;
			RAISE;
	END;

	FUNCTION getcurrentinstancename RETURN VARCHAR IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.getCurrentInstanceName';
		vname VARCHAR2(100);
	BEGIN
	
		FOR i IN (SELECT * FROM v$instance)
		LOOP
			vname := i.instance_name;
		END LOOP;
	
		RETURN vname;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE dialoglogon___________________ IS
	BEGIN
		NULL;
	END;

	PROCEDURE createdesktop IS
	BEGIN
		sdesktop := dialog.desktop();
		staskbar := dialog.taskbar(sdesktop);
		dialog.setfontname(sdesktop, 'MS Sans Serif');
		dialog.setfontname(staskbar, 'MS Sans Serif');
		dialog.setfontsize(sdesktop, 8);
		dialog.setfontsize(staskbar, 8);
		a4m.setmainsessionid(userenv('SESSIONID'), cid);
		dialog.setcaption(0, custom_seance.appshortname);
		dialog.setcaption(staskbar, 'Start');
		dialog.setpicture(staskbar, 'a4mstart.bmp');
	END;

	PROCEDURE createappsubmenu IS
		vappmenu NUMBER;
	BEGIN
		vappmenu := mnu.new(0);
		IF debug.checkright(debug.cright_plsqlrunner)
		THEN
			dialog.menuitem(vappmenu
						   ,'Debug'
						   ,'PL/SQL Runner'
						   ,0
						   ,0
						   ,' '
						   ,'!Dialog.Exec(hDebug.DebugForm);');
			dialog.sethotkey(vappmenu, 'Debug', 'Alt+D');
		END IF;
		IF debug.checkright(debug.cright_viewsource)
		THEN
			dialog.menuitem(vappmenu, 'SourceV', 'Source View', 0, 0, ' ', '!hdebug.sourceview;');
		END IF;
		IF referencerepos.checkright(referencerepos.right_view)
		   OR referencerepos.checkright(referencerepos.right_modify)
		THEN
			dialog.menuitem(vappmenu
						   ,'Repos'
						   ,'Repository...'
						   ,0
						   ,0
						   ,' '
						   ,'!Dialog.Exec(ReferenceRepos.DialogScroller);');
		END IF;
	
		IF debug.checkright(debug.cright_rdbmsdebug)
		THEN
			dialog.separator(vappmenu);
		
			dialog.menuitem(vappmenu
						   ,'RDBMS'
						   ,'Application debug'
						   ,0
						   ,0
						   ,' '
						   ,'!if Dialog.GetBool(0, ''RDBMS'') then ' || chr(10) ||
							'  Debug.setDebugStatus(Debug.cTYPE_RDBMS,Debug.cLEVEL_SELF,Debug.cSTATUS_OFF); ' ||
							chr(10) || '  s.setlevel(0); s.setid(0); ' || chr(10) || 'else ' ||
							chr(10) ||
							'  Debug.setDebugStatus(Debug.cTYPE_RDBMS,Debug.cLEVEL_SELF,Debug.cSTATUS_ON); ' ||
							chr(10) || '  s.setlevel(null); s.setid(null);' || chr(10) ||
							'end if;' || chr(10) || '  Debug.refreshDebugStatus(pNow => true);' ||
							chr(10) ||
							'Dialog.PutBool(0, ''RDBMS'', not Dialog.GetBool(0, ''RDBMS''));' ||
							chr(10) || 'Dialog.PutBool(0, ''RDBMS_FULL'', false);');
			dialog.sethotkey(vappmenu, 'RDBMS', 'Alt+T');
			IF debug.getdebugstatus_(debug.ctype_rdbms, debug.clevel_self) = debug.cstatus_on
			THEN
				dialog.putbool(0, 'RDBMS', TRUE);
			END IF;
		
			dialog.menuitem(vappmenu
						   ,'RDBMS_FULL'
						   ,'Application full debug'
						   ,0
						   ,0
						   ,' '
						   ,'!if Dialog.GetBool(0, ''RDBMS_FULL'') then ' || chr(10) ||
							'  Debug.setDebugStatus(Debug.cTYPE_RDBMS,Debug.cLEVEL_SELF,Debug.cSTATUS_OFF); ' ||
							chr(10) || '  s.setlevel(0); s.setid(0); ' || chr(10) || 'else ' ||
							chr(10) ||
							'  Debug.setDebugStatus(Debug.cTYPE_RDBMS,Debug.cLEVEL_SELF,Debug.cSTATUS_FULL); ' ||
							chr(10) || '  s.setlevel(null); s.setid(null);' || chr(10) ||
							'end if;' || chr(10) || '  Debug.refreshDebugStatus(pNow => true);' ||
							chr(10) ||
							'Dialog.PutBool(0, ''RDBMS_FULL'', not Dialog.GetBool(0, ''RDBMS_FULL''));' ||
							chr(10) || 'Dialog.PutBool(0, ''RDBMS'', false);');
			dialog.setenable(vappmenu, 'RDBMS_FULL', debug.checkright(debug.cright_viewfulldebug));
			IF debug.getdebugstatus_(debug.ctype_rdbms, debug.clevel_self) = debug.cstatus_full
			THEN
				dialog.putbool(0, 'RDBMS', TRUE);
			END IF;
		
			dialog.menuitem(vappmenu
						   ,'FILTER'
						   ,'Debug filter'
						   ,0
						   ,0
						   ,' '
						   ,'!DebugSetup.setupSayFilter(user());' || chr(10) ||
							'Dialog.PutBool(0, ''FILTER'', s.getIDFilter().count>1);');
			dialog.putbool(0, 'FILTER', s.getidfilter().count > 1);
		END IF;
	END;

	FUNCTION getdesktop RETURN NUMBER IS
	BEGIN
		RETURN sdesktop;
	END;
	FUNCTION gettaskbar RETURN NUMBER IS
	BEGIN
		RETURN staskbar;
	END;

	PROCEDURE setdesktopcaption IS
	BEGIN
		IF getdesktop() IS NULL
		THEN
		
			RETURN;
		END IF;
		dialog.puttitle(getdesktop()
					   ,' ' || appshortname || ' (v.' || getappversion || ')' || ' - ' ||
						getbranchname() || '  -  ' || htools.d2s(getoperdate()) || ' ' ||
						service.getdayname(getoperdate()));
	END;

	FUNCTION defineapplication RETURN PLS_INTEGER IS
		vapp NUMBER;
	BEGIN
	
		say('A4M.StartUp_ : detect Application...');
		vapp := CASE nvl(term.getenv('APPLICATION'), 'A4M')
					WHEN 'INIT' THEN
					 a4m.a4m_init
					WHEN 'A4M' THEN
					 a4m.a4m_back
					WHEN 'ADMIN' THEN
					 8
					ELSE
					 NULL
				END;
		IF vapp IS NULL
		THEN
			raiseerr('Unknown application! Specify correct application in ITC connection settings ("APPLICATION" parameter).');
		END IF;
		say('StartUp_ : Application = ' || vapp);
		RETURN vapp;
	END;

	PROCEDURE definehostname IS
		vhostname VARCHAR(32767);
	BEGIN
		say('defineHostName : detect HostName...');
	
		IF term.getenvos('host://HOST_NAME', vhostname)
		THEN
			sethostname(vhostname);
			say('defineHostName : HostName = ' || vhostname);
		ELSE
			raiseerr('Environment variable "HOST_NAME" (Application server name)~not defined.~');
		END IF;
	END;

	PROCEDURE definebranch IS
		vbranch NUMBER;
	BEGIN
		say('defineBranch...');
	
		vbranch := term.getenv('BRANCH');
		IF (vbranch IS NULL)
		THEN
			raiseerr('Environment variable "BRANCH" (Branch No)~not defined.~');
		END IF;
		openbranch(vbranch);
		say(': branch defined as ' || vbranch || ' and current flag = ' ||
			custom_seance.getregim());
	END;

	PROCEDURE definestation IS
		vstr        VARCHAR(100);
		vstation    NUMBER;
		vbranchpart NUMBER;
	BEGIN
		say('defineStation...');
	
		vstr := term.getenv('STATION');
		say('defineStation: Station = ' || vstr);
		vstation := to_number(TRIM(vstr));
	
		say('defineStation : detect BranchPart...');
		vbranchpart := referencebranchpart.getbranchpart(vstation);
		say('defineStation : BranchPart = ' || vbranchpart);
	
		IF (vbranchpart IS NULL)
		THEN
			IF USER() = 'A4M'
			THEN
				vbranchpart := referencebranchpart.c_undefine_branchpart;
			ELSE
				raiseerr('Station ' || vstation || ' not authorized');
			END IF;
		END IF;
	
		say('A4M.StartUp_ : set BranchPart...');
		setbranchpart(vbranchpart);
		setstation(vstation);
	EXCEPTION
		WHEN custom_seance.elogon THEN
			s.err('custom_seance.defineStation');
			RAISE;
		WHEN OTHERS THEN
			error.save('custom_seance.defineStation');
			raiseerr('Error defining station:' || error.gettext);
	END;

	PROCEDURE captureloginresource IS
		vdialog NUMBER;
	
		vstr     VARCHAR(4000);
		vattempt NUMBER := 1;
	BEGIN
	
		LOOP
			IF object.setlock('LOGIN'
							 ,'$$LOGIN$$RESOURCE$$'
							 ,pattempt             => trunc(5 / 0.1)
							 ,pattemptpause        => 0.1)
			THEN
				slogincaptured := TRUE;
				RETURN;
			ELSE
				vstr := object.capturedobjectinfo('LOGIN', '$$LOGIN$$RESOURCE$$');
				IF vstr IS NULL
				THEN
					vstr := ' Return error ' || err.gettext;
				END IF;
			END IF;
		
			IF vattempt = 0
			THEN
				htools.message('Warning!'
							  ,'Give the following information to administrator:~' ||
							   'System login time-out ' || custom_seance.appshortname || '.~' || vstr);
				RETURN;
			END IF;
			vdialog := service.dialogconfirm('Warning !'
											,'System login time-out ' || custom_seance.appshortname || '.~' || vstr
											,'   Repeat  '
											,'Repeat login attempt'
											,'     Exit'
											,'Stop login attempts');
			dialog.goitem(vdialog, 'Ok');
		
			EXIT WHEN dialog.exec(vdialog) = dialog.cmcancel;
			vattempt := vattempt - 1;
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save('custom_seance.CaptureLoginResource(cancel)');
			htools.message('Warning!'
						  ,'Give the following information to administrator:~' ||
						   'System login error ' || custom_seance.appshortname || '.~' ||
						   error.gettext);
			RETURN;
	END;

	PROCEDURE showoperdaywarning IS
		vdlg NUMBER;
	BEGIN
	
		vdlg := dialog.new('Details', 0, 0, 59, 13, pextid => 'custom_seance.ShowOperDayWarning');
		dialog.textlabel(vdlg, 'd1', 0, 2, 59, 'WARNING!');
		dialog.setfontsize2(vdlg, 'd1', 300);
		dialog.setitemplace(vdlg, 'd1', 0, 2, 59, 3);
		dialog.textlabel(vdlg
						,'d2'
						,0
						,6
						,59
						,'          BUSINESS DAY: ' || htools.d2s(custom_seance.getoperdate));
		IF (trunc(custom_seance.getoperdate) > trunc(SYSDATE))
		THEN
			dialog.textlabel(vdlg
							,'d3'
							,0
							,7
							,59
							,'LATER THAN SYSTEM DATE: ' || htools.d2s(SYSDATE));
		ELSE
			dialog.textlabel(vdlg
							,'d3'
							,0
							,7
							,59
							,'LESS THAN SYSTEM DATE: ' || htools.d2s(SYSDATE));
		END IF;
		dialog.settextanchor(vdlg, 'd1', 0);
		dialog.settextanchor(vdlg, 'd2', 0);
		dialog.settextanchor(vdlg, 'd3', 0);
		dialog.button(vdlg, 'OK', 27, 10, 6, '  Ok', dialog.cmok, 0, 'Press <Enter> to continue');
		dialog.exec(vdlg);
	EXCEPTION
		WHEN OTHERS THEN
			error.save('custom_seance.ShowWarning');
			RAISE;
	END;

	PROCEDURE loginfree IS
		verr err.typecontextrec;
	BEGIN
		IF NOT slogincaptured
		THEN
			RETURN;
		END IF;
		verr := err.getcontext;
		err.seterror(0, NULL);
		say('A4M.LoginFree : free login...');
		object.release('LOGIN', '$$LOGIN$$RESOURCE$$');
		slogincaptured := FALSE;
		IF err.geterrorcode != 0
		THEN
			say('ERROR : A4M.LoginFree : login not released!!! : ' || err.geterror);
			sdummy := a4mlog.logobjectsys(object.gettype('BRANCH')
										 ,3
										 ,'Error free of loginresource: ' || err.geterror);
		END IF;
		err.putcontext(verr);
	END;

	FUNCTION dialogreattach RETURN NUMBER IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.DialogReattach()';
		vdlg NUMBER;
	BEGIN
		vdlg := dialog.new('Duplicate system entry!'
						  ,0
						  ,0
						  ,50
						  ,12
						  ,pextid => 'custom_seance.DialogReattach');
	
		dialog.textlabel(vdlg, 'User', 25, 2, 20, ' ', 'User:');
		dialog.textlabel(vdlg, 'Station', 25, 3, 10, ' ', 'Station:');
		dialog.textlabel(vdlg, 'Time', 25, 4, 20, ' ', 'Connection time:');
		dialog.textlabel(vdlg, 'State', 25, 5, 20, ' ', 'Status:');
		dialog.textlabel(vdlg, 'Process', 25, 6, 12, ' ', 'Process:');
	
		dialog.button(vdlg
					 ,'Connect'
					 ,2
					 ,8
					 ,14
					 ,'   Connect  '
					 ,dialog.cmconfirm
					 ,0
					 ,'Connect to session');
		dialog.button(vdlg
					 ,'Kill'
					 ,18
					 ,8
					 ,14
					 ,'   Terminate'
					 ,dialog.cmok
					 ,0
					 ,'Terminate session and start new');
		dialog.button(vdlg, 'Exit', 34, 8, 14, '     Exit', dialog.cmcancel, 0, 'Exit');
	
		RETURN vdlg;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE putinfo
	(
		pdlg NUMBER
	   ,puid VARCHAR
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.putInfo()';
		vstate   VARCHAR(32767);
		vprocess NUMBER;
	BEGIN
		say(cprocname || ' : start');
	
		FOR i IN (SELECT v.*
						,a.hostname
						,a.station
				  FROM   ta4mseance a
						,v$session  v
				  WHERE  a.sid = htools.getsubstr(puid, 1, ',')
				  AND    a.serial# = htools.getsubstr(puid, 2, ',')
				  AND    v.sid = a.sid
				  AND    v.serial# = a.serial#
				  ORDER  BY a.startdate DESC)
		LOOP
			vprocess := to_number(htools.getsubstr(i.process, 1, ':'));
			dialog.putchar(pdlg, 'User', i.username);
			dialog.putchar(pdlg
						  ,'Time'
						  ,to_char(i.logon_time) || ' ' || to_char(i.logon_time, 'HH24:MI:SS'));
			dialog.putchar(pdlg, 'Process', vprocess);
			dialog.putchar(pdlg, 'Station', i.station);
		
			dialog.setenable(pdlg, 'Connect', FALSE);
			IF i.state = 'KILLED'
			THEN
				vstate := 'KILLED';
			ELSE
				dialog.setenable(pdlg, 'Connect', TRUE);
				IF i.hostname = gethostname
				THEN
					BEGIN
						IF term.applicationisattached(vprocess)
						THEN
							vstate := 'Connected';
						ELSE
							vstate := 'Disconnected';
						END IF;
						dialog.setenable(pdlg, 'Connect', TRUE);
					EXCEPTION
						WHEN OTHERS THEN
							vstate := 'Undefined:' || SQLERRM;
					END;
				ELSE
					vstate := 'Undefined: another host';
				END IF;
			END IF;
			dialog.putchar(pdlg, 'State', vstate);
			RETURN;
		END LOOP;
		htools.message('Warning!', 'Information on blocking session is out of date. Repeat logon.');
		RAISE error.exiterror;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE reattach IS
		cprocname CONSTANT VARCHAR(1000) := cpackagename || '.Reattach()';
		vdlg     NUMBER;
		vuid     VARCHAR(30);
		vprocess NUMBER;
	BEGIN
		vuid := object.getcapturedinfo_seanceuid('LOGIN', USER());
		vdlg := dialogreattach();
		LOOP
			putinfo(vdlg, vuid);
			CASE dialog.execdialog(vdlg)
			
				WHEN dialog.cm_cancel THEN
					RAISE error.exiterror;
				
				WHEN dialog.cm_ok THEN
					IF htools.askconfirm('Warning!', 'Terminate session?')
					THEN
						BEGIN
							monitor.removesession(NULL
												 ,psid    => htools.getsubstr(vuid, 1, ',')
												 ,pserial => htools.getsubstr(vuid, 2, ',')
												 ,pcid    => cid);
							EXIT;
						EXCEPTION
							WHEN OTHERS THEN
								error.save('a4m');
								IF NOT htools.ask('Error!'
												 ,'Error closing session~' || error.gettext ||
												  '~Continue?')
								THEN
									RAISE error.exiterror;
								END IF;
						END;
					END IF;
				
				WHEN dialog.cm_confirm THEN
					vprocess := dialog.getnumber(vdlg, 'Process');
					BEGIN
						s.say('ApplicationIsAttached = ' || vprocess);
						IF term.applicationisattached(vprocess)
						THEN
							term.sendmessage(vprocess
											,USER
											,'Application is switched to another ITC.');
							term.applicationdetach(vprocess);
						END IF;
						a4mlog.logobjectsys(object.gettype('LOGIN')
										   ,1
										   ,'Reconnect to existing session: ' || vuid
										   ,paction => a4mlog.act_enter);
						term.applicationattach(vprocess);
						RAISE error.exiterror;
					EXCEPTION
						WHEN error.exiterror THEN
							RAISE;
						WHEN OTHERS THEN
							error.show('Error connecting to existing session');
					END;
				
				ELSE
					s.say(cprocname || ': Warning! unknown dialog retcode');
				
			END CASE;
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE manageservicemode IS
		vdlg NUMBER;
	BEGIN
		IF USER NOT IN ('A4M', 'OPS$A4M')
		THEN
			htools.message('Warning!', 'User "' || USER || '" has no privileges!');
			RETURN;
		END IF;
		BEGIN
			definehostname;
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	
		vdlg := dialog.new('Manage "Maintenance" mode'
						  ,0
						  ,0
						  ,40
						  ,5
						  ,pextid => 'custom_seance.ManageServiceMode');
		serviceworks.makemenu(vdlg);
	
		dialog.textlabel(vdlg, 'Text', 20, 2, 20, pcaption => '  Mode status:');
		dialog.button(vdlg, 'On', 8, 4, 11, 'Enable', pcmd => 101);
		dialog.button(vdlg, 'Off', 23, 4, 11, 'Disable', pcmd => 404);
	
		LOOP
			IF javaport.isserviced = 'true'
			THEN
				dialog.putchar(vdlg, 'Text', 'Enabled');
				dialog.setenable(vdlg, 'On', FALSE);
				dialog.setenable(vdlg, 'Off', TRUE);
			ELSE
				dialog.putchar(vdlg, 'Text', 'Disabled');
				dialog.setenable(vdlg, 'On', TRUE);
				dialog.setenable(vdlg, 'Off', FALSE);
			END IF;
			CASE dialog.execdialog(vdlg)
				WHEN 101 THEN
					params.setparam('TWCMS_SERVICED', 'true');
					COMMIT;
				WHEN 404 THEN
					params.setparam('TWCMS_SERVICED', 'false');
					COMMIT;
				ELSE
					EXIT;
			END CASE;
		
		END LOOP;
		dialog.destroy(vdlg);
	EXCEPTION
		WHEN OTHERS THEN
			error.save('custom_seance.ManageServiceMode');
			RAISE;
	END;

	PROCEDURE startitc IS
		vstation VARCHAR2(40);
		vdialog  NUMBER;
		vflag    NUMBER;
		loginresourcecaptured EXCEPTION;
		vmsg VARCHAR(200);
	BEGIN
		createdesktop;
		altersession();
		s.init();
		s.setlevel(NULL);
		s.setid(NULL);
	
		CASE defineapplication()
		
			WHEN a4m.a4m_init THEN
				dialog.exec(a4minit.branchbrowse());
				BEGIN
					COMMIT;
					term.fullexit();
				EXCEPTION
					WHEN OTHERS THEN
						NULL;
				END;
				RETURN;
			
			WHEN 8 THEN
				manageservicemode;
				BEGIN
					COMMIT;
					term.fullexit();
				EXCEPTION
					WHEN OTHERS THEN
						NULL;
				END;
				RETURN;
			
			ELSE
				NULL;
		END CASE;
	
		IF javaport.isserviced = 'true'
		THEN
			htools.message('Warning!'
						  ,'System ' || custom_seance.appshortname ||
						   ' is closed for maintenance!');
			RETURN;
		END IF;
	
		definehostname();
		definebranch();
		definestation();
		logenv;
	
		say('StartITC_ : Init custom_seance...');
		init();
	
		say('StartITC_ : connecting ...');
	
		say('StartITC_ : detect User ...');
		err.seterror(0, 'custom_seance.StartITC');
		setclerk(USER);
		CASE err.geterrorcode
			WHEN 0 THEN
				NULL;
			WHEN err.clerk_not_found THEN
				BEGIN
					vmsg := ' ip:' || term.applicationgetip();
					setclerk('A4M');
					setstation(-1);
				EXCEPTION
					WHEN OTHERS THEN
						vmsg := ' ip not definded';
				END;
				vmsg := vmsg || ', Station: ' || vstation;
				a4mlog.logadm('System login attempt ' || custom_seance.appshortname || ' user ' || USER || ' !' ||
							  chr(10) || vmsg);
				COMMIT;
				raiseerr('System login attempt ' || custom_seance.appshortname || ' user "' || USER ||
						 '"! Contact system administrator.');
			ELSE
				raiseerr('Error logging user ' || USER() || ': ' || err.gettext);
		END CASE;
	
		say('StartITC_ : User =' || USER);
		dialog.setappinfo('[' || USER || '] ' || clientpersone.getpersonerecord(getclerkclientid).fio);
		say('StartITC_ : setAppInfo OK');
	
		WHILE (NOT object.setlock('LOGIN', USER()))
		LOOP
			say('StartITC_ : Error logging user (duplicate entry)!!!');
			loginfree;
			reattach();
		END LOOP;
	
		say('StartITC_ : check valided Users station ...');
		IF (NOT htools.equal(USER, 'A4M'))
		   AND (NOT clerk.isvalidstation(getclerkuser, custom_seance.getstation))
		THEN
			object.release('LOGIN', USER);
			raiseerr('You are not authorized to work at this station.');
		END IF;
	
		IF USER = 'A4M'
		THEN
			say('StartITC_ : skip station lock');
		
		ELSIF (NOT object.setlock('LOGIN', 'STATION' || to_char(custom_seance.getstation)))
		THEN
			object.release('LOGIN', USER);
			raiseerr('Station No ' || custom_seance.getstation ||
					 ' already logged in to the system ' || custom_seance.appshortname || '.~' ||
					 object.capturedobjectinfo('LOGIN'
											  ,'STATION' || to_char(custom_seance.getstation)) || '~');
		END IF;
	
		say('StartITC_ : detect status operdays ...');
		vmsg := 'A4M-' || custom_seance.modename_twr || '$' || gethostname || '$' || getbranch() || '$' ||
				getstation || '$' || 'MAIN';
		say('StartITC_ : set_client_info ...');
		dbms_application_info.set_client_info(vmsg);
	
		vflag := custom_seance.getregim;
		say('StartITC_ : regim = ' || vflag);
	
		IF vflag != custom_seance.shared
		THEN
		
			say('StartITC_ : regim not shared - check users rights... ');
			IF NOT security.checkright(operday.object_name
									  ,operday.getrightkey(operday.right_change_regim))
			THEN
				object.release('LOGIN', getclerkuser);
				object.release('LOGIN', 'STATION' || to_char(custom_seance.getstation));
				raiseerr('System ' || custom_seance.appshortname || ' in EXCLUSIVE access mode.~' ||
						 'Impossible to continue.~');
			END IF;
		
			CASE vflag
				WHEN custom_seance.exclusiv THEN
					say('StartITC_ : regim exclusive... ');
					IF custom_seance.getcountactiveuser < 1
					THEN
						htools.message('Warning!', 'You work in EXCLUSIVE access mode.');
						vdialog := dialoglogin(vflag);
					ELSE
						say('StartITC_ : regim close usurpate... ');
						object.release('LOGIN', getclerkuser);
						object.release('LOGIN', 'STATION' || to_char(custom_seance.getstation));
					
						DECLARE
							vuser VARCHAR(32767);
							vlist monitor.typesessioninfolist;
						BEGIN
							vlist := monitor.getsessioninfo(TRUE, custom_seance.mode_twr);
							FOR i IN 1 .. vlist.count
							LOOP
								EXIT WHEN length(vuser) > 32000;
								IF NOT custom_seance.getuid LIKE vlist(i).sid || ',%'
								THEN
									vuser := vuser || vlist(i).username || ',';
								END IF;
							END LOOP;
							vlist := monitor.getsessioninfo(TRUE, custom_seance.mode_bp);
							FOR i IN 1 .. vlist.count
							LOOP
								EXIT WHEN length(vuser) > 32000;
								IF NOT custom_seance.getuid LIKE vlist(i).sid || ',%'
								THEN
									vuser := vuser || vlist(i).username || ',';
								END IF;
							END LOOP;
							IF vuser IS NOT NULL
							THEN
								vuser := substr(vuser, 1, length(vuser) - 1);
								vuser := 'User is in system: ' || vuser || '~';
							END IF;
							raiseerr('System ' || custom_seance.appshortname ||
									 ' in EXCLUSIVE access mode.~' || vuser ||
									 'Impossible to continue.~');
						EXCEPTION
							WHEN OTHERS THEN
								error.save('make list user');
								raiseerr('System ' || custom_seance.appshortname ||
										 ' in EXCLUSIVE access mode.~' || vuser ||
										 'Impossible to continue.~');
						END;
					END IF;
				
				WHEN custom_seance.closed THEN
					say('StartITC_ : regim closed ... ');
					IF custom_seance.getcountactiveuser < 1
					THEN
						loginfree;
						htools.message('Warning!'
									  ,'Business day of system ' || custom_seance.appshortname ||
									   ' CLOSED.~' || 'You may open NEW business day~' ||
									   'You are in exclusive system access mode.~');
						vdialog := dialoglogin(vflag);
					ELSE
						object.release('LOGIN', getclerkuser);
						object.release('LOGIN', 'STATION' || to_char(custom_seance.getstation));
						loginfree;
						raiseerr('Business day of system ' || custom_seance.appshortname ||
								 ' still CLOSED.~' ||
								 'You will be notified of business time opening.~');
					END IF;
				ELSE
					say('StartITC_ : vse ploho ... ');
					object.release('LOGIN', getclerkuser);
					object.release('LOGIN', 'STATION' || to_char(custom_seance.getstation));
					raiseerr('System internal error ' || custom_seance.appshortname || '!~' ||
							 'Business day is in UNDETERMINED state (' || to_char(vflag) || ').~' ||
							 'Contact system administrator.~');
			END CASE;
		END IF;
		loginfree;
	
		say('StartITC_ : exec vDialog = ' || vdialog);
		dialog.exec(vdialog);
	
		say('StartITC_ : set env proc_id = ' || term.proc_id || ' ... ');
		term.setenv('PROC_ID', term.proc_id);
		say('StartITC_ : set env proc_desr = ' || USER || ' ... ');
		term.setenv('PROC_DESC', USER);
	
		say('StartITC_ : Term.SetReattachable (TRUE)... ');
		term.setreattachable(TRUE);
		say('StartITC_ : init dialog ');
		setdesktopcaption();
		say('StartITC_ : init desctop ');
		referencerepos.initdesktop;
		say('StartITC_ : init submenu ');
		createappsubmenu();
	
		say('StartITC_ : OK');
		s.init();
		s.setlevel(0);
		s.setid(0);
		COMMIT;
		say('StartITC_ : if warning... ');
	EXCEPTION
		WHEN error.exiterror THEN
			s.err('custom_seance.StartITC_');
			loginfree;
			BEGIN
				COMMIT;
				term.fullexit();
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			RAISE;
		
		WHEN OTHERS THEN
			error.save('custom_seance.StartITC');
			loginfree;
			error.showerror('Error of login to TWCMS!');
			BEGIN
				COMMIT;
				term.fullexit();
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
	END;

	FUNCTION getinfo RETURN typeseanceinfo IS
		vinfo custom_seance.typeseanceinfo;
	BEGIN
		vinfo             := NULL;
		vinfo.isvisual    := (getsystemmode() = custom_seance.mode_twr) AND (NOT a4m.sfloramode);
		vinfo.isreadonly  := (getaccessmode = custom_seance.access_limited);
		vinfo.ismultitask := (multitaskworker.getfullid IS NOT NULL);
		vinfo.isopen      := (custom_seance.getsystemmode != custom_seance.mode_none);
		RETURN vinfo;
	END;

BEGIN
	sseancerow.branch := 0;
END;
/
