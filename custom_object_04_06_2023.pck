CREATE OR REPLACE PACKAGE custom_object AS

	crevision CONSTANT VARCHAR(100) := '$Rev: 44809 $';

	sdebug BOOLEAN := FALSE;

	TYPE typenumber IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	TYPE typevarchar IS TABLE OF VARCHAR(60) INDEX BY BINARY_INTEGER;

	mode_pessimistic CONSTANT NUMBER := 1;
	mode_optimistic  CONSTANT NUMBER := 2;

	svsession_sid       v$session.audsid%TYPE;
	svsession_logontime v$session.logon_time%TYPE;
	svsession_process   v$session.process%TYPE;
	svsession_terminal  v$session.terminal%TYPE;
	svsession_orauser   v$session.username%TYPE;
	svsession_info      v$session.client_info%TYPE;

	cobjtype_class     CONSTANT ta4mobj.type%TYPE := 'CLASS';
	cobjtype_resource  CONSTANT ta4mobj.type%TYPE := 'RESOURCE';
	cobjtype_userclass CONSTANT ta4mobj.type%TYPE := 'USERCLASS';

	FUNCTION getversion RETURN VARCHAR;

	FUNCTION setlock
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	   ,pattempt      PLS_INTEGER := 1
	   ,pattemptpause NUMBER := 0.01
	) RETURN BOOLEAN;

	FUNCTION setlockread
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	   ,pattempt      PLS_INTEGER := 1
	   ,pattemptpause NUMBER := 0.01
	) RETURN BOOLEAN;

	PROCEDURE setlock
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	   ,pattempt      PLS_INTEGER := 1
	   ,pattemptpause NUMBER := 0.01
	);

	PROCEDURE setlockread
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	   ,pattempt      PLS_INTEGER := 1
	   ,pattemptpause NUMBER := 0.01
	);

	PROCEDURE freelock
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	);

	FUNCTION capture
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	   ,pattempt      PLS_INTEGER := 1
	   ,pattemptpause NUMBER := 0.01
	) RETURN NUMBER;

	FUNCTION captureread
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	   ,pattempt      PLS_INTEGER := 1
	   ,pattemptpause NUMBER := 0.01
	) RETURN NUMBER;

	FUNCTION iscaptured
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN BOOLEAN;

	PROCEDURE release
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	);

	FUNCTION capturedobjectinfo
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN VARCHAR;

	FUNCTION getcapturedinfo_seanceuid
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN VARCHAR;

	FUNCTION getremark
	(
		pcode         NUMBER
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN VARCHAR;

	FUNCTION gettype
	(
		pname         VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN NUMBER;

	FUNCTION getremarkbyname
	(
		pname         VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN VARCHAR;

	FUNCTION fillobjectarray
	(
		pacode   IN OUT NOCOPY typenumber
	   ,paremark IN OUT NOCOPY typevarchar
	) RETURN NUMBER;

	PROCEDURE insertobject
	(
		pname        VARCHAR
	   ,premark      VARCHAR
	   ,ppackagename VARCHAR := NULL
	);

	PROCEDURE deleteobject(pname VARCHAR);

	PROCEDURE changeobjectremark
	(
		pname      VARCHAR
	   ,pnewremark VARCHAR
	);

	PROCEDURE insertsysobject
	(
		pname        VARCHAR
	   ,ptype        VARCHAR
	   ,premark      VARCHAR
	   ,pbranch      NUMBER
	   ,ppackagename VARCHAR := NULL
	);

	FUNCTION capture4live
	(
		pname IN CHAR
	   ,pkey  IN CHAR
	) RETURN NUMBER;

	PROCEDURE setbranch(pbranch IN NUMBER);

	FUNCTION getcapturemode RETURN NUMBER;

	FUNCTION gethandleexpire RETURN INTEGER;
	PROCEDURE sethandleexpire(pseconds INTEGER);

	FUNCTION clearpipe
	(
		pname   VARCHAR
	   ,pkey    VARCHAR
	   ,pbranch NUMBER := NULL
	) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY custom_object IS

	cpackage      CONSTANT VARCHAR(100) := 'Object';
	cbodyrevision CONSTANT VARCHAR(100) := '$Rev: 44809 $';

	ctimewait CONSTANT NUMBER := 15;
	cdelim    CONSTANT CHAR(1) := chr(1);

	SUBTYPE typelockmode IS VARCHAR(1);
	clockmode_exclusive CONSTANT typelockmode := 'X';
	clockmode_shared    CONSTANT typelockmode := 'S';

	svsid         NUMBER;
	shandleexpire INTEGER;
	sdummy        VARCHAR(32000);

	scurbranch NUMBER;

	nowaitblocker EXCEPTION;
	slocklevel NUMBER;

	slockmode     VARCHAR(100) := NULL;
	scommonbranch BOOLEAN := FALSE;

	scash_lastbranch NUMBER := NULL;
	TYPE typeobjlist IS TABLE OF VARCHAR(40) INDEX BY VARCHAR(40);
	scash_objlist_4limitedaccess typeobjlist;
	TYPE typeobjcodelist IS TABLE OF NUMBER INDEX BY VARCHAR(40);
	scash_objcodelist typeobjcodelist;

	FUNCTION getversion RETURN VARCHAR IS
	BEGIN
		RETURN service.formatpackageversion(cpackage, crevision, cbodyrevision);
	END;

	PROCEDURE say
	(
		pwhere VARCHAR
	   ,ptext  VARCHAR
	) IS
	BEGIN
		IF sdebug
		THEN
			IF pwhere IS NOT NULL
			THEN
				s.say(pwhere || ' : ' || ptext, 8, 'SYSTEM');
			ELSE
				s.say(cpackage || ' : ' || ptext, 8, 'SYSTEM');
			END IF;
		END IF;
	END;

	PROCEDURE setcommonbranch(penable BOOLEAN) IS
	BEGIN
		scommonbranch := penable;
		s.say(cpackage || '.setCommonBranch(' || htools.bool2str(penable) || ')');
	END;

	FUNCTION getbranch RETURN NUMBER IS
	BEGIN
		IF scommonbranch
		THEN
			RETURN seance.cbranch_common;
		END IF;
		IF scurbranch IS NOT NULL
		THEN
			RETURN scurbranch;
		END IF;
		RETURN seance.getbranch;
	END;

	PROCEDURE initcash(pnow BOOLEAN := FALSE) IS
		vbranch NUMBER;
	BEGIN
		vbranch := getbranch();
		IF NOT pnow
		THEN
			IF nvl(scash_lastbranch = vbranch, FALSE)
			THEN
				RETURN;
			END IF;
		END IF;
		scash_objlist_4limitedaccess.delete;
		FOR i IN (SELECT *
				  FROM   ta4mobjparam t
				  WHERE  t.branch = vbranch
				  AND    t.forlimitedaccess = 1)
		LOOP
			scash_objlist_4limitedaccess(i.name) := i.name;
		END LOOP;
		scash_objlist_4limitedaccess('BRANCH') := 'BRANCH';
		scash_objlist_4limitedaccess('LOGIN') := 'LOGIN';
		FOR i IN (SELECT * FROM ta4mobj t WHERE t.branch = vbranch)
		LOOP
			scash_objcodelist(i.name) := i.code;
		END LOOP;
		scash_lastbranch := vbranch;
	END;

	PROCEDURE old_hash________________ IS
	BEGIN
		NULL;
	END;

	FUNCTION gethashvalue
	(
		pname             IN CHAR
	   ,pkey              IN CHAR
	   ,pisuseobjectlevel BOOLEAN := FALSE
	) RETURN NUMBER IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.GetHashValue( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ')';
		vpipename  ta4mobj.pipename%TYPE;
		vname      VARCHAR(4000);
		vlocklevel ta4mobj.locklevel%TYPE;
		vbranch CONSTANT NUMBER := getbranch();
	BEGIN
		IF pkey IS NULL
		THEN
			error.raiseerror('Object.GetHashValue: Key is null !!!');
		END IF;
		slocklevel := NULL;
		BEGIN
			EXECUTE IMMEDIATE 'SELECT Upper(trim(PipeName)), NVL(t.locklevel,0)
		   FROM tA4mObj t
		   WHERE
			 Branch = :Branch AND
			 Name = :Name'
				INTO vpipename, vlocklevel
				USING vbranch, upper(TRIM(pname));
			slocklevel := vlocklevel;
		EXCEPTION
			WHEN OTHERS THEN
				s.err(cprocname || ' : Error obtaining character code for object ' || pname);
				error.save(cprocname || ' : Error obtaining character code for object ' || pname);
				sdummy := a4mlog.logobjectsys(object.gettype('BRANCH')
											 ,2
											 ,'Error obtaining character code for object ' || pname || ': ' ||
											  SQLCODE);
				error.raiseerror(cpackage || ' : Error obtaining character code for object ' ||
								 pname);
		END;
		IF pisuseobjectlevel
		THEN
			vname := 'A4M$' || ltrim(rtrim(to_char(vbranch))) || '-' || to_char(vlocklevel) || '$' ||
					 vpipename;
		ELSE
			vname := 'A4M$' || ltrim(rtrim(to_char(vbranch))) || '$' || vpipename;
		END IF;
		RETURN dbms_utility.get_hash_value(vname || '$' || pkey, 0, 1073741824);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			s.err(cprocname);
			RAISE;
	END;

	PROCEDURE new_handle______________ IS
	BEGIN
		NULL;
	END;

	FUNCTION gethandleexpire RETURN INTEGER IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.GetHandleExpire';
		verr err.typecontextrec;
	BEGIN
		verr := err.getcontext;
		RETURN datamember.getnumber(0, 0, 'LOCK_CFG_HANDLEEXPIRE');
		err.putcontext(verr);
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE sethandleexpire(pseconds INTEGER) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.SetHandleExpire(secs = ' || pseconds || ')';
	BEGIN
		sdummy := datamember.setnumber(0
									  ,0
									  ,'LOCK_CFG_HANDLEEXPIRE'
									  ,pseconds
									  ,'Lifetime of handle for blocking system');
		COMMIT;
		sdummy        := a4mlog.logobjectsys(object.gettype('BRANCH')
											,99
											,'HandleExpiration set =  ' || pseconds || ': user ' || USER);
		shandleexpire := gethandleexpire;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION islockmodehash RETURN BOOLEAN IS
		verr err.typecontextrec;
	BEGIN
		IF slockmode IS NULL
		THEN
			verr      := err.getcontext;
			slockmode := nvl(datamember.getchar(0, 0, 'LOCK_CFG_MODE'), 'CONTEXT');
			say(cpackage, 'LOCK-MODE : ' || slockmode);
			err.putcontext(verr);
		END IF;
		RETURN nvl(slockmode = 'HASH', FALSE);
	END;

	FUNCTION islockmodecontext RETURN BOOLEAN IS
		verr err.typecontextrec;
	BEGIN
		IF slockmode IS NULL
		THEN
			verr      := err.getcontext;
			slockmode := nvl(datamember.getchar(0, 0, 'LOCK_CFG_MODE'), 'CONTEXT');
			say(cpackage, 'LOCK-MODE : ' || slockmode);
			err.putcontext(verr);
		END IF;
		RETURN nvl(slockmode = 'CONTEXT', FALSE);
	END;

	FUNCTION islockmodetable RETURN BOOLEAN IS
		verr err.typecontextrec;
	BEGIN
		IF slockmode IS NULL
		THEN
			verr      := err.getcontext;
			slockmode := nvl(datamember.getchar(0, 0, 'LOCK_CFG_MODE')
							,service.iif(seance.isoraclerac, 'TABLE', 'CONTEXT'));
			say(cpackage, 'LOCK-MODE : ' || slockmode);
			err.putcontext(verr);
		END IF;
		RETURN nvl(slockmode = 'TABLE', FALSE);
	END;

	FUNCTION islockmodehandle RETURN BOOLEAN IS
		verr err.typecontextrec;
	BEGIN
		IF slockmode IS NULL
		THEN
			verr      := err.getcontext;
			slockmode := nvl(datamember.getchar(0, 0, 'LOCK_CFG_MODE'), 'CONTEXT');
			say(cpackage, 'LOCK-MODE : ' || slockmode);
			err.putcontext(verr);
		END IF;
		RETURN nvl(slockmode = 'HANDLE', FALSE);
	END;

	PROCEDURE blockaccess2context(plockkey PLS_INTEGER) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.BlockAccess2Context(pLockKey = ' ||
											plockkey || ')';
		verr NUMBER;
	BEGIN
		verr := dbms_lock.request(plockkey, dbms_lock.x_mode, ctimewait);
		IF (verr = 1)
		   OR (verr = 2)
		THEN
		
			error.raiseerror('Error blocking access : IsLocked (' ||
							 service.iif(verr = 1, 'timeout', 'deadlock') || ')');
		ELSIF verr = 4
		THEN
			error.raiseerror('Error blocking access : IsLocked');
		
		ELSIF (verr = 3)
			  OR (verr = 5)
		THEN
			error.raiseerror(' : Error blocking access ' || plockkey || ': Not Locked (' ||
							 service.iif(verr = 3, 'parameter error', 'illegal lockhandle') ||
							 ') !!!');
		
		ELSIF (verr > 0)
		THEN
			error.raiseerror(' : Error blocking access ' || plockkey ||
							 ': IsLocked(unknow error = ' || verr || ') !!!');
		
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE unblockaccess2context(plockkey PLS_INTEGER) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.UnblockAccess2Context(pLockKey = ' ||
											plockkey || ')';
		verr NUMBER;
	BEGIN
		verr := dbms_lock.release(plockkey);
	
		IF verr = 4
		THEN
			say(cprocname
			   ,' Error unblocking access : Not found (don`t own lock specified by `id` or `lockhandle`)');
			error.raiseerror(' Error unblocking access : Not found (don`t own lock specified by `id` or `lockhandle`)');
		
		ELSIF verr = 3
			  OR (verr = 5)
		THEN
			say(cprocname
			   ,' Error unblocking access : ' ||
				service.iif(verr = 3, 'parameter error', 'illegal lockhandle'));
			error.raiseerror(' Error unblocking access : ' ||
							 service.iif(verr = 3, 'parameter error', 'illegal lockhandle'));
		
		ELSIF verr > 0
		THEN
			say(cprocname, ' Error unblocking access : unknow error = ' || verr);
			error.raiseerror(' Error unblocking access : unknow error = ' || verr);
		
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			error.save(cprocname);
	END;

	PROCEDURE release_sys_context(plockid VARCHAR) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.Release_sys( id = ' || plockid || ')';
		voldlockdata VARCHAR(32767);
		vnewlockdata VARCHAR(32767);
		vlockkey     PLS_INTEGER;
		vblocked     BOOLEAN := FALSE;
	BEGIN
		vlockkey := dbms_utility.get_hash_value(plockid, 0, 1073741824);
		blockaccess2context(vlockkey);
		vblocked     := TRUE;
		voldlockdata := sys_context(objectcontext.cnamespace, vlockkey);
		vnewlockdata := voldlockdata;
		vnewlockdata := REPLACE(vnewlockdata
							   ,cdelim || clockmode_exclusive || ':' || seance.getuid() || ':' ||
								plockid || cdelim
							   ,cdelim);
		vnewlockdata := REPLACE(vnewlockdata
							   ,cdelim || clockmode_shared || ':' || seance.getuid() || ':' ||
								plockid || cdelim
							   ,cdelim);
		IF htools.equal(vnewlockdata, voldlockdata, puseupperrtrim => FALSE)
		THEN
			error.raiseerror('Object is not blocked');
		END IF;
		IF (vnewlockdata = cdelim)
		THEN
			objectcontext.clear_context(vlockkey);
		ELSE
			objectcontext.set_context(vlockkey, vnewlockdata);
		END IF;
		unblockaccess2context(vlockkey);
		say(cprocname, 'obj released');
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			error.save(cprocname);
			IF vblocked
			THEN
				unblockaccess2context(vlockkey);
			END IF;
			RAISE;
	END;

	PROCEDURE release_sys(vlockid VARCHAR) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.Release_sys( id = ' || vlockid || ')';
		verr NUMBER := -1;
	BEGIN
		IF islockmodehandle
		THEN
			verr := dbms_lock.release(vlockid);
		ELSIF islockmodehash
		THEN
			verr := dbms_lock.release(to_number(vlockid));
		ELSE
			error.raiseerror(cpackage || ' : Blocking mechanism not defined');
		END IF;
	
		IF verr = 4
		THEN
			say(cprocname
			   ,' Error unblocking resource : Not found (don`t own lock specified by `id` or `lockhandle`)');
			error.raiseerror(' Error unblocking resource : Not found (don`t own lock specified by `id` or `lockhandle`)');
		
		ELSIF verr = 3
			  OR (verr = 5)
		THEN
			say(cprocname
			   ,' Error unblocking resource : ' ||
				service.iif(verr = 3, 'parameter error', 'illegal lockhandle'));
			error.raiseerror(' Error unblocking resource : ' ||
							 service.iif(verr = 3, 'parameter error', 'illegal lockhandle'));
		
		ELSIF verr > 0
		THEN
			say(cprocname, ' Error unblocking resource : unknow error = ' || verr);
			error.raiseerror(' Error unblocking resource : unknow error = ' || verr);
		
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE release_sys_table(plockid VARCHAR) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.Release_sys_T( id = ' || plockid || ')';
	BEGIN
		DELETE FROM tlock
		WHERE  key = plockid
		AND    sessionuid = seance.getuid;
		IF SQL%ROWCOUNT = 0
		THEN
			error.raiseerror('Object is not blocked');
		END IF;
		COMMIT;
		say(cprocname, 'obj released');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			ROLLBACK;
			RAISE;
	END;

	FUNCTION getunique(pname VARCHAR) RETURN VARCHAR IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vlockhandle VARCHAR(1000);
	BEGIN
		dbms_lock.allocate_unique(lockname        => pname
								 ,lockhandle      => vlockhandle
								 ,expiration_secs => shandleexpire);
		RETURN vlockhandle;
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			s.err('Object.GetUnique');
			RAISE;
	END;

	FUNCTION getlockvalue
	(
		pname             IN CHAR
	   ,pkey              IN CHAR
	   ,pisuseobjectlevel BOOLEAN := FALSE
	) RETURN VARCHAR IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.GetLockValue( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ')';
		vpipename  ta4mobj.pipename%TYPE;
		vpipecode  ta4mobj.code%TYPE;
		vname      VARCHAR(4000);
		vlocklevel ta4mobj.locklevel%TYPE;
		vbranch CONSTANT NUMBER := getbranch();
	BEGIN
		IF islockmodehash
		THEN
			RETURN gethashvalue(pname, pkey, pisuseobjectlevel);
		END IF;
		IF pkey IS NULL
		THEN
			error.raiseerror('Object.GetHashValue: Key is null !!!');
		END IF;
		slocklevel := NULL;
		BEGIN
			SELECT upper(ltrim(rtrim(pipename)))
				  ,t.code
				  ,nvl(t.locklevel, 0)
			INTO   vpipename
				  ,vpipecode
				  ,vlocklevel
			FROM   ta4mobj t
			WHERE  branch = vbranch
			AND    NAME = upper(ltrim(rtrim(pname)));
			slocklevel := vlocklevel;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cprocname || ' : Error obtaining character code for object ' || pname);
				s.err(cprocname || ' : Error obtaining character code for object ' || pname);
				sdummy := a4mlog.logobjectsys(object.gettype('BRANCH')
											 ,2
											 ,'Error obtaining character code for object ' || pname || ': ' ||
											  SQLCODE);
				error.raiseerror(cpackage || ' : Error obtaining character code for object ' ||
								 pname);
		END;
		vname := NULL;
		IF pisuseobjectlevel
		THEN
		
			vname := TRIM(to_char(vbranch)) || '-' || to_char(vlocklevel);
		ELSE
		
			vname := TRIM(to_char(vbranch));
		END IF;
		vname := 'A4M$' || vname || '$' || vpipename;
		say(cprocname, ' vName = ' || vname);
	
		IF islockmodehandle
		THEN
			RETURN getunique(vname || '$' || pkey);
		ELSIF islockmodecontext
		THEN
			RETURN vname || '$' || pkey;
		ELSIF islockmodetable
		THEN
			RETURN pname || '$' || TRIM(to_char(vbranch)) || '$' || pkey;
		ELSE
			error.raiseerror(cpackage || ' : Blocking mechanism not defined');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			s.err(cprocname);
			sdummy := a4mlog.logobjectsys(object.gettype('BRANCH')
										 ,2
										 ,'Error obtaining code to block object ' || pname || ': ' ||
										  SQLCODE);
			RAISE;
	END;

	PROCEDURE locklevelup(pname VARCHAR) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.LockLevelUp( Name = ' || pname || ')';
		vbranch   CONSTANT NUMBER := getbranch();
	BEGIN
		IF slocklevel IS NOT NULL
		THEN
			UPDATE ta4mobj t
			SET    t.locklevel = t.locklevel + 1
			WHERE  vbranch = t.branch
			AND    upper(ltrim(rtrim(pname))) = t.name
			AND    slocklevel = nvl(t.locklevel, 0);
			COMMIT;
		ELSE
			error.raiseerror(cprocname || ' : Buffer contains invalid data');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION capture_context
	(
		pname     VARCHAR
	   ,pkey      VARCHAR
	   ,plockmode typelockmode := clockmode_exclusive
	) RETURN NUMBER IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.Capture( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ', lockmode = ' ||
											plockmode || ')';
		vlockvalue VARCHAR(1000);
		vlockkey   PLS_INTEGER;
		vsid       NUMBER;
		vuid       VARCHAR(100);
		vlockmode  typelockmode;
		vserial#   NUMBER;
		vlockdata  VARCHAR(32167);
		vstr       VARCHAR(32000);
		i          PLS_INTEGER;
		vblocked   BOOLEAN := FALSE;
	BEGIN
		s.say(cprocname || ' : start');
		IF pkey IS NULL
		THEN
			error.raiseerror('Object.Capture: Key is null !!!');
		END IF;
	
		vlockvalue := getlockvalue(pname, pkey);
		say(cprocname, ' : LockValue=' || vlockvalue);
		vlockkey := dbms_utility.get_hash_value(vlockvalue, 0, 1073741824);
		say(cprocname, ' : block...');
		blockaccess2context(vlockkey);
		vblocked := TRUE;
		say(cprocname, ' : read lock...');
		vlockdata := sys_context(objectcontext.cnamespace, vlockkey);
		IF vlockdata IS NOT NULL
		THEN
			i := 1;
		
			LOOP
				i    := i + 1;
				vstr := htools.getsubstr(vlockdata, i, cdelim);
				s.say('lock_data = ' || vstr);
				EXIT WHEN vstr IS NULL;
				IF vstr NOT LIKE '_:%'
				THEN
					vlockdata := REPLACE(vlockdata, cdelim || vstr || cdelim, cdelim);
					objectcontext.set_context(vlockkey, vlockdata);
					i    := i - 1;
					vstr := NULL;
				END IF;
				vuid      := htools.getsubstr(vstr, 2, ':');
				vlockmode := htools.getsubstr(vstr, 1, ':');
				IF substr(vstr, 2 + length(vuid) + 2) = vlockvalue
				THEN
					seance.decodeuid(vuid, vsid, vserial#);
					BEGIN
						SELECT sid
						INTO   vsid
						FROM   v$session
						WHERE  sid = vsid
						AND    serial# = vserial#
						AND    status != 'KILLED';
						IF NOT ((plockmode = clockmode_shared) AND (vlockmode = clockmode_shared))
						THEN
							err.seterror(err.object_busy, 'Object.Capture');
							say(cprocname, ' : object is busy...');
							say(cprocname, ' : unblock...');
							unblockaccess2context(vlockkey);
							RETURN err.object_busy;
						ELSE
							IF (vuid = seance.getuid)
							THEN
								s.say(cprocname || ' : WARNING!!! dublicate lock.');
								sdummy := a4mlog.logobjectsys(object.gettype('BRANCH')
															 ,2
															 ,'Repeated blocking for reading resource ' ||
															  pname || '/' || s.maskdata(pkey));
								say(cprocname, ' : unblock...');
								unblockaccess2context(vlockkey);
								say(cprocname, ' : OK');
								RETURN 0;
							END IF;
						END IF;
					EXCEPTION
						WHEN no_data_found THEN
						
							vlockdata := REPLACE(vlockdata, cdelim || vstr || cdelim, cdelim);
							objectcontext.set_context(vlockkey, vlockdata);
							i := i - 1;
						WHEN OTHERS THEN
							RAISE;
					END;
				END IF;
			END LOOP;
		END IF;
		say(cprocname, ' : lock...');
		vlockdata := nvl(vlockdata, cdelim) || nvl(plockmode, clockmode_exclusive) || ':' ||
					 seance.getuid || ':' || vlockvalue || cdelim;
		objectcontext.set_context(vlockkey, vlockdata);
		say(cprocname, ' : unblock...');
		unblockaccess2context(vlockkey);
		say(cprocname, ' : OK');
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname || ': Error blocking resource (others) ');
			err.seterror(SQLCODE, cprocname, 'Error blocking resource' || ' : ' || SQLERRM);
			sdummy := a4mlog.logobjectsys(object.gettype('BRANCH')
										 ,2
										 ,'Error blocking resource ' || pname || '/' ||
										  s.maskdata(pkey) || ': ' || SQLERRM);
			IF vblocked
			THEN
				unblockaccess2context(vlockkey);
			END IF;
			RETURN SQLCODE;
	END;

	FUNCTION iscaptured_table
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN BOOLEAN IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.isCaptured( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ')';
		vlockvalue    VARCHAR(1000);
		vchangebranch BOOLEAN := FALSE;
		vnow          DATE;
	BEGIN
		s.say(cprocname || ' : start');
		IF pkey IS NULL
		THEN
			error.raiseerror('Object.Capture: Key is null !!!');
		END IF;
	
		IF pcommonbranch
		   AND getbranch != seance.cbranch_common
		THEN
			vchangebranch := TRUE;
			setcommonbranch(TRUE);
		END IF;
	
		vlockvalue := getlockvalue(pname, pkey);
		say(cprocname, ' : LockValue=' || vlockvalue);
	
		IF vchangebranch
		THEN
			setcommonbranch(FALSE);
			vchangebranch := FALSE;
		END IF;
		vnow := SYSDATE;
		FOR i IN (SELECT * FROM tlock WHERE key = vlockvalue)
		LOOP
			IF (vnow - i.created) < 60 * (1 / (24 * 3600))
			THEN
				RETURN TRUE;
			ELSE
				DECLARE
					vsid     NUMBER;
					vserial# NUMBER;
					vinstid  NUMBER;
				BEGIN
					seance.decodeuid(i.sessionuid, vsid, vserial#);
					vinstid := htools.getsubstr(i.sessionuid, 3, ',');
					SELECT sid
					INTO   vsid
					FROM   gv$session v
					WHERE  sid = vsid
					AND    serial# = vserial#
					AND    v.inst_id = vinstid
					AND    status != 'KILLED';
					RETURN TRUE;
				EXCEPTION
					WHEN no_data_found THEN
					
						NULL;
					WHEN OTHERS THEN
						RAISE;
				END;
			END IF;
		END LOOP;
	
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			IF vchangebranch
			THEN
				setcommonbranch(FALSE);
			END IF;
			RAISE;
	END;

	FUNCTION iscaptured
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN BOOLEAN IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.isCaptured( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ')';
		vlockvalue    VARCHAR(1000);
		vlockkey      PLS_INTEGER;
		vsid          NUMBER;
		vuid          VARCHAR(100);
		vserial#      NUMBER;
		vlockdata     VARCHAR(32167);
		vstr          VARCHAR(32000);
		i             PLS_INTEGER;
		vblocked      BOOLEAN := FALSE;
		vchangebranch BOOLEAN := FALSE;
	BEGIN
		s.say(cprocname || ' : start');
		IF pkey IS NULL
		THEN
			error.raiseerror('Object.Capture: Key is null !!!');
		END IF;
		IF islockmodetable
		THEN
			RETURN iscaptured_table(pname, pkey, pcommonbranch);
		END IF;
	
		IF pcommonbranch
		   AND getbranch != seance.cbranch_common
		THEN
			vchangebranch := TRUE;
			setcommonbranch(TRUE);
		END IF;
	
		vlockvalue := getlockvalue(pname, pkey);
		say(cprocname, ' : LockValue=' || vlockvalue);
		vlockkey := dbms_utility.get_hash_value(vlockvalue, 0, 1073741824);
		say(cprocname, ' : block...');
		blockaccess2context(vlockkey);
		vblocked := TRUE;
		say(cprocname, ' : read lock...');
		vlockdata := sys_context(objectcontext.cnamespace, vlockkey);
		IF vlockdata IS NOT NULL
		THEN
			i := 1;
			LOOP
				i    := i + 1;
				vstr := htools.getsubstr(vlockdata, i, cdelim);
				EXIT WHEN vstr IS NULL;
				IF vstr NOT LIKE '_:%'
				THEN
					vlockdata := REPLACE(vlockdata, cdelim || vstr || cdelim, cdelim);
					objectcontext.set_context(vlockkey, vlockdata);
					i    := i - 1;
					vstr := NULL;
				END IF;
				vuid := htools.getsubstr(vstr, 2, ':');
				IF substr(vstr, 2 + length(vuid) + 2) = vlockvalue
				THEN
					seance.decodeuid(vuid, vsid, vserial#);
					BEGIN
						SELECT sid
						INTO   vsid
						FROM   v$session
						WHERE  sid = vsid
						AND    serial# = vserial#
						AND    status != 'KILLED';
					
						say(cprocname, ' : object is busy...');
						say(cprocname, ' : unblock...');
						unblockaccess2context(vlockkey);
						RETURN TRUE;
					EXCEPTION
						WHEN no_data_found THEN
						
							vlockdata := REPLACE(vlockdata, cdelim || vstr || cdelim, cdelim);
							objectcontext.set_context(vlockkey, vlockdata);
							i := i - 1;
						WHEN OTHERS THEN
							RAISE;
					END;
				END IF;
			END LOOP;
		END IF;
		say(cprocname, ' : unblock...');
		unblockaccess2context(vlockkey);
		say(cprocname, ' : OK');
	
		IF vchangebranch
		THEN
			setcommonbranch(FALSE);
		END IF;
	
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname || ': Error blocking resource (others) ');
			err.seterror(SQLCODE, cprocname, 'Error blocking resource' || ' : ' || SQLERRM);
			IF vchangebranch
			THEN
				setcommonbranch(FALSE);
			END IF;
			sdummy := a4mlog.logobjectsys(object.gettype('BRANCH')
										 ,2
										 ,'Error blocking resource ' || pname || '/' ||
										  s.maskdata(pkey) || ': ' || SQLERRM);
			IF vblocked
			THEN
				unblockaccess2context(vlockkey);
			END IF;
		
			RETURN TRUE;
	END;

	FUNCTION capture_table
	(
		pname     VARCHAR
	   ,pkey      VARCHAR
	   ,plockmode typelockmode := clockmode_exclusive
	) RETURN NUMBER IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.Capture_Table( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ', lockmode = ' ||
											plockmode || ')';
		vlockvalue VARCHAR(1000);
		vsid       NUMBER;
		vserial#   NUMBER;
		vinstid    NUMBER;
		visrepeat  BOOLEAN := FALSE;
		vnow       DATE;
	BEGIN
		s.say(cprocname || ' : start');
		IF pkey IS NULL
		THEN
			error.raiseerror('Object.Capture: Key is null !!!');
		END IF;
	
		vlockvalue := getlockvalue(pname, pkey);
		say(cprocname, ' : LockValue=' || vlockvalue);
	
		LOOP
			visrepeat := FALSE;
			BEGIN
				vnow := SYSDATE;
				INSERT INTO tlock
					(key
					,sessionuid
					,created)
				VALUES
					(vlockvalue
					,seance.getuid
					,vnow);
				COMMIT;
			EXCEPTION
				WHEN dup_val_on_index THEN
					FOR i IN (SELECT * FROM tlock WHERE key = vlockvalue)
					LOOP
						IF (vnow - i.created) < 60 * (1 / (24 * 3600))
						THEN
							err.seterror(err.object_busy, 'Object.Capture');
							say(cprocname, ' : object is busy...');
							ROLLBACK;
							RETURN err.object_busy;
						END IF;
						seance.decodeuid(i.sessionuid, vsid, vserial#);
						vinstid := htools.getsubstr(i.sessionuid, 3, ',');
						BEGIN
							SELECT sid
							INTO   vsid
							FROM   gv$session v
							WHERE  sid = vsid
							AND    serial# = vserial#
							AND    v.inst_id = vinstid
							AND    status != 'KILLED';
							err.seterror(err.object_busy, 'Object.Capture');
							say(cprocname, ' : object is busy...');
							ROLLBACK;
							RETURN err.object_busy;
						EXCEPTION
							WHEN no_data_found THEN
							
								DELETE FROM tlock
								WHERE  key = vlockvalue
								AND    sessionuid = i.sessionuid;
								COMMIT;
							WHEN OTHERS THEN
								RAISE;
						END;
						visrepeat := TRUE;
					END LOOP;
				WHEN OTHERS THEN
					error.save(cprocname);
					RAISE;
			END;
			EXIT WHEN NOT visrepeat;
		END LOOP;
		say(cprocname, ' : OK');
		COMMIT;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname || ': Error blocking resource (others) ');
			a4mlog.logobjectsys(object.gettype('BRANCH')
							   ,2
							   ,'Error blocking resource ' || pname || '/' || s.maskdata(pkey) || ': ' ||
								SQLERRM);
			ROLLBACK;
			RETURN error.getcode;
	END;

	FUNCTION capture_
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,plockmode     typelockmode
	   ,pcommonbranch BOOLEAN
	   ,pattempt      PLS_INTEGER
	   ,pattemptpause NUMBER
	   ,puseexception BOOLEAN := FALSE
	) RETURN NUMBER IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.Capture( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ', mode = ' ||
											plockmode || ')';
		verr          NUMBER;
		vchangebranch BOOLEAN := FALSE;
		vattempt      PLS_INTEGER := greatest(nvl(pattempt, 1), 1);
	BEGIN
		IF seance.getaccessmode = seance.access_limited
		THEN
			initcash;
			IF NOT scash_objlist_4limitedaccess.exists(TRIM(upper(pname)))
			THEN
				error.raiseerror(err.seance_access_limited);
			END IF;
		END IF;
	
		IF pkey IS NULL
		THEN
			error.raiseerror('Object.Capture: Key is null !!!');
		END IF;
		err.seterror(0, 'Object.Capture');
	
		IF pcommonbranch
		   AND getbranch != seance.cbranch_common
		THEN
			vchangebranch := TRUE;
			setcommonbranch(TRUE);
		END IF;
	
		LOOP
			vattempt := vattempt - 1;
			IF islockmodetable
			THEN
				verr := capture_table(pname, pkey, nvl(plockmode, clockmode_exclusive));
			ELSE
				verr := capture_context(pname, pkey, nvl(plockmode, clockmode_exclusive));
			END IF;
			EXIT WHEN verr = 0;
			EXIT WHEN vattempt <= 0;
			s.say(cprocname || ' : next attempt of capture after ' || pattemptpause || ' sec.');
			dbms_lock.sleep(nvl(pattemptpause, 0.01));
		END LOOP;
	
		IF vchangebranch
		THEN
			setcommonbranch(FALSE);
		END IF;
		IF verr != 0
		THEN
			error.raisewhenerr;
		END IF;
		RETURN verr;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname || ': Error of blocking resource (others)');
			IF vchangebranch
			THEN
				setcommonbranch(FALSE);
			END IF;
			sdummy := a4mlog.logobjectsys(object.gettype('BRANCH')
										 ,2
										 ,'Error blocking resource ' || pname || '/' ||
										  s.maskdata(pkey) || ': ' || SQLCODE);
			IF puseexception
			THEN
				RAISE;
			END IF;
			RETURN error.getcode;
	END;

	FUNCTION capture
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN
	   ,pattempt      PLS_INTEGER
	   ,pattemptpause NUMBER
	) RETURN NUMBER IS
	BEGIN
		RETURN capture_(pname, pkey, clockmode_exclusive, pcommonbranch, pattempt, pattemptpause);
	END;

	FUNCTION captureread
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN
	   ,pattempt      PLS_INTEGER
	   ,pattemptpause NUMBER
	) RETURN NUMBER IS
	BEGIN
		RETURN capture_(pname, pkey, clockmode_shared, pcommonbranch, pattempt, pattemptpause);
	END;

	FUNCTION setlock
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN
	   ,pattempt      PLS_INTEGER
	   ,pattemptpause NUMBER
	) RETURN BOOLEAN IS
	BEGIN
		sdummy := capture_(pname
						  ,pkey
						  ,clockmode_exclusive
						  ,pcommonbranch
						  ,pattempt
						  ,pattemptpause
						  ,puseexception => TRUE);
		RETURN TRUE;
	EXCEPTION
		WHEN error.a4merror THEN
			IF error.getcode = err.object_busy
			THEN
				RETURN FALSE;
			END IF;
			RAISE;
	END;

	FUNCTION setlockread
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN
	   ,pattempt      PLS_INTEGER
	   ,pattemptpause NUMBER
	) RETURN BOOLEAN IS
	BEGIN
		sdummy := capture_(pname
						  ,pkey
						  ,clockmode_shared
						  ,pcommonbranch
						  ,pattempt
						  ,pattemptpause
						  ,puseexception => TRUE);
		RETURN TRUE;
	EXCEPTION
		WHEN error.a4merror THEN
			IF error.getcode = err.object_busy
			THEN
				RETURN FALSE;
			END IF;
			RAISE;
	END;

	PROCEDURE setlock
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN
	   ,pattempt      PLS_INTEGER
	   ,pattemptpause NUMBER
	) IS
	BEGIN
		sdummy := capture_(pname
						  ,pkey
						  ,clockmode_exclusive
						  ,pcommonbranch
						  ,pattempt
						  ,pattemptpause
						  ,puseexception => TRUE);
	END;

	PROCEDURE setlockread
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN
	   ,pattempt      PLS_INTEGER
	   ,pattemptpause NUMBER
	) IS
	BEGIN
		sdummy := capture_(pname
						  ,pkey
						  ,clockmode_shared
						  ,pcommonbranch
						  ,pattempt
						  ,pattemptpause
						  ,puseexception => TRUE);
	END;

	FUNCTION capture4live
	(
		pname IN CHAR
	   ,pkey  IN CHAR
	) RETURN NUMBER IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.Capture4Live( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ')';
		vlockvalue       VARCHAR(1000);
		vlockval_        NUMBER;
		vlockvalueaccess VARCHAR(1000);
		vlockvalaccess_  NUMBER;
		verr             NUMBER;
		vcount           NUMBER;
	BEGIN
		IF pkey IS NULL
		THEN
			error.raiseerror('Object.Capture4Live: Key is null !!!');
		END IF;
		IF islockmodecontext
		THEN
			RETURN capture_context(pname, pkey);
		END IF;
		verr := 999;
	
		LOOP
		
			say(cprocname, '  --< 3 >-- ');
			vlockvalueaccess := getlockvalue(pname, '$', TRUE);
			vlockvalaccess_  := to_number(substr(vlockvalueaccess, 1, 10));
			say(cprocname, ' vLockValueAccess : ' || vlockvalueaccess);
		
			say(cprocname, '  --< 4 >-- ');
			IF islockmodehandle
			THEN
				verr := dbms_lock.request(vlockvalueaccess, dbms_lock.x_mode, 3);
			ELSE
				verr := dbms_lock.request(to_number(vlockvalueaccess), dbms_lock.x_mode, 3);
			END IF;
			say(cprocname, '  --< 5 >-- err = ' || verr);
		
			IF (verr IN (1, 2, 4))
			THEN
			
				BEGIN
					SELECT 1
					INTO   vcount
					FROM   v$lock l
					WHERE  l.type = 'UL'
					AND    l.lmode = 6
					AND    l.id1 = vlockvalaccess_
					AND    EXISTS (SELECT s.sid
							FROM   v$session s
							WHERE  l.sid = s.sid
							AND    'KILLED' != s.status)
					AND    rownum = 1;
				EXCEPTION
					WHEN OTHERS THEN
						vcount := 0;
				END;
				say(cprocname, '  --< 5 >-- Count = ' || vcount);
				IF vcount = 0
				THEN
				
					say(cprocname, '  --< 5a >-- ');
					locklevelup(pname);
				END IF;
			ELSIF verr > 0
			THEN
				err.seterror(verr, cprocname);
				say(cprocname
				   ,'Error blocking resource : Not Locked (' ||
					service.iif(verr = 3, 'parameter error', 'illegal lockhandle') || ')');
				error.raiseerror(cprocname || ' : Error blocking resource ' || pname || '/' ||
								 s.maskdata(pkey) || ': Not Locked (' ||
								 service.iif(verr = 3, 'parameter error', 'illegal lockhandle') ||
								 ') !!!');
			END IF;
			EXIT WHEN verr = 0;
		
		END LOOP;
	
		say(cprocname, '  --< 6,7 >-- ');
		BEGIN
			vlockvalue := getlockvalue(pname, pkey);
			vlockval_  := to_number(substr(vlockvalue, 1, 10));
			say(cprocname, ' vLockValue : ' || vlockvalue);
			say(cprocname, '  --< 8 >-- ');
		
			IF islockmodehandle
			THEN
				verr := dbms_lock.request(vlockvalue, dbms_lock.s_mode, 3);
			ELSE
				verr := dbms_lock.request(to_number(vlockvalue), dbms_lock.s_mode, 3);
			END IF;
			say(cprocname, '  --< 8 >-- err=' || verr);
			IF (verr = 1)
			   OR (verr = 2)
			THEN
			
				err.seterror(err.object_busy, cprocname);
				say(cprocname
				   ,'Error blocking resource : IsLocked (' ||
					service.iif(verr = 1, 'timeout', 'deadlock') || ')');
			ELSIF verr = 4
			THEN
				err.seterror(err.object_busy, cprocname);
				say(cprocname, 'Error blocking resource : IsLocked');
			
			ELSIF (verr = 3)
				  OR (verr = 5)
			THEN
				err.seterror(verr, cprocname);
				say(cprocname
				   ,'Error blocking resource : Not Locked (' ||
					service.iif(verr = 3, 'parameter error', 'illegal lockhandle') || ')');
				error.raiseerror(cprocname || ' : Error blocking resource ' || pname || '/' || pkey ||
								 ': Not Locked (' ||
								 service.iif(verr = 3, 'parameter error', 'illegal lockhandle') ||
								 ') !!!');
			
			ELSIF (verr > 0)
			THEN
				err.seterror(verr, cprocname);
				say(cprocname, 'Error blocking resource : IsLocked(unknow error = ' || verr || ')');
				error.raiseerror(cprocname || ' : Error blocking resource ' || pname || '/' || pkey ||
								 ': IsLocked(unknow error = ' || verr || ') !!!');
			
			END IF;
		
			vcount := 0;
		
			BEGIN
				SELECT 1
				INTO   vcount
				FROM   v$lock l
				WHERE  l.type = 'UL'
				AND    l.lmode = 4
				AND    l.id1 = vlockval_
				AND    EXISTS (SELECT 1
						FROM   v$session s
						WHERE  l.sid = s.sid
						AND    'KILLED' != s.status
						AND    s.audsid != svsid)
				AND    rownum = 1;
				say(cprocname, ' --< 9 >-- count = ' || vcount || ' vsid=' || svsid);
			EXCEPTION
				WHEN no_data_found THEN
					vcount := 0;
				WHEN OTHERS THEN
					s.err(cprocname ||
						  ' : error searching for sessions attempting to block object simultaneously');
					RAISE;
			END;
			IF vcount > 0
			THEN
				say(cprocname, '  --< 10 >-- ');
			
				err.seterror(err.object_busy, 'Object.Capture4Live');
				say(cprocname, 'Error blocking resource : IsLocked ');
				release_sys(vlockvalue);
				verr := 10;
			END IF;
		
		EXCEPTION
			WHEN OTHERS THEN
				release_sys(vlockvalueaccess);
				RAISE;
		END;
		release_sys(vlockvalueaccess);
		RETURN verr;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cprocname);
			s.err(cprocname || ': Error blocking resource (others) ');
			sdummy := a4mlog.logobjectsys(object.gettype('BRANCH')
										 ,2
										 ,'Error blocking resource ' || pname || '/' ||
										  s.maskdata(pkey) || ': ' || SQLCODE);
			RETURN SQLCODE;
	END;

	PROCEDURE release
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.Release( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ')';
		vlockvalue    VARCHAR(1000);
		vchangebranch BOOLEAN := FALSE;
	BEGIN
	
		IF pcommonbranch
		   AND getbranch != seance.cbranch_common
		THEN
			vchangebranch := TRUE;
			setcommonbranch(TRUE);
		END IF;
	
		vlockvalue := getlockvalue(pname, pkey);
	
		IF islockmodetable
		THEN
			release_sys_table(vlockvalue);
		ELSE
			release_sys_context(vlockvalue);
		END IF;
	
		IF vchangebranch
		THEN
			setcommonbranch(FALSE);
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname || ': Error unblocking resource');
			IF vchangebranch
			THEN
				setcommonbranch(FALSE);
			END IF;
			a4mlog.logobjectsys(object.gettype('BRANCH')
							   ,2
							   ,'Error unblocking resource ' || pname || '/' || s.maskdata(pkey) || ': ' ||
								err.getfullmessage);
	END;

	PROCEDURE freelock
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) IS
	BEGIN
		release(pname, pkey, pcommonbranch);
	END;

	FUNCTION capturedobjectinfo_context
	(
		pname VARCHAR
	   ,pkey  VARCHAR
	) RETURN VARCHAR IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.CapturedObjectInfo( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ')';
		vuid       VARCHAR(100);
		vsid       NUMBER;
		vserial#   NUMBER;
		vlockdata  VARCHAR(32167);
		vlockvalue VARCHAR(32167);
		vlockkey   PLS_INTEGER;
		i          PLS_INTEGER;
		vstr       VARCHAR(32167);
	BEGIN
		err.seterror(0, 'Object.CapturedObjectInfo_context');
	
		svsession_sid       := NULL;
		svsession_logontime := NULL;
		svsession_process   := NULL;
		svsession_terminal  := NULL;
		svsession_orauser   := NULL;
		svsession_info      := NULL;
	
		vlockvalue := getlockvalue(pname, pkey);
		vlockkey   := dbms_utility.get_hash_value(vlockvalue, 0, 1073741824);
	
		vlockdata := sys_context(objectcontext.cnamespace, vlockkey);
		IF vlockdata IS NOT NULL
		THEN
			i := 1;
			LOOP
				i    := i + 1;
				vstr := htools.getsubstr(vlockdata, i, cdelim);
				EXIT WHEN vstr IS NULL;
				IF vstr NOT LIKE '_:%'
				THEN
					vlockdata := REPLACE(vlockdata, cdelim || vstr || cdelim, cdelim);
					objectcontext.set_context(vlockkey, vlockdata);
					i    := i - 1;
					vstr := NULL;
				END IF;
				vuid := htools.getsubstr(vstr, 2, ':');
				IF substr(vstr, 2 + length(vuid) + 2) = vlockvalue
				THEN
					seance.decodeuid(vuid, vsid, vserial#);
					EXIT;
				END IF;
			END LOOP;
		END IF;
	
		IF vsid IS NOT NULL
		THEN
			FOR crow IN (SELECT *
						 FROM   v$session
						 WHERE  sid = vsid
						 AND    serial# = vserial#)
			LOOP
				svsession_sid       := crow.sid;
				svsession_logontime := crow.logon_time;
				svsession_process   := crow.process;
				svsession_terminal  := crow.terminal;
				svsession_orauser   := crow.username;
				svsession_info      := crow.client_info;
				RETURN 'TERM: ' || crow.terminal || ' ORACLE/USR: ' || crow.username || ' SES/ID: ' || crow.sid || ' STATION: ' || htools.getsubstr(crow.client_info
																																				   ,4
																																				   ,'$');
			END LOOP;
			RETURN 'Error obtaining information on blocking session ' || vuid;
		END IF;
		RETURN 'Object is not blocked';
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			error.save(cprocname);
			err.seterror(SQLCODE, cpackage || '.CapturesObjectInfo', SQLERRM);
			RETURN 'Error obtaining information on blocking session';
	END;

	FUNCTION capturedobjectinfo_table
	(
		pname VARCHAR
	   ,pkey  VARCHAR
	) RETURN VARCHAR IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.CapturedObjectInfo_T( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ')';
		vuid     VARCHAR(100);
		vsid     NUMBER;
		vserial# NUMBER;
		vinst_id NUMBER;
	BEGIN
	
		svsession_sid       := NULL;
		svsession_logontime := NULL;
		svsession_process   := NULL;
		svsession_terminal  := NULL;
		svsession_orauser   := NULL;
		svsession_info      := NULL;
	
		vuid := getcapturedinfo_seanceuid(pname, pkey);
		seance.decodeuid(vuid, vsid, vserial#);
		vinst_id := htools.getsubstr(vuid, 3, ',');
	
		IF vsid IS NOT NULL
		THEN
			FOR crow IN (SELECT *
						 FROM   gv$session
						 WHERE  sid = vsid
						 AND    serial# = vserial#
						 AND    inst_id = vinst_id)
			LOOP
				svsession_sid       := crow.sid;
				svsession_logontime := crow.logon_time;
				svsession_process   := crow.process;
				svsession_terminal  := crow.terminal;
				svsession_orauser   := crow.username;
				svsession_info      := crow.client_info;
				RETURN 'TERM: ' || crow.terminal || ' ORACLE/USR: ' || crow.username || ' SES/ID: ' || crow.sid || ' STATION: ' || htools.getsubstr(crow.client_info
																																				   ,4
																																				   ,'$');
			END LOOP;
			RETURN 'Error obtaining information on blocking session ' || vuid;
		END IF;
		RETURN 'Object is not blocked';
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RETURN 'Error obtaining information on blocking session';
	END;

	FUNCTION getcapturedinfo_seanceuid_
	(
		pname VARCHAR
	   ,pkey  VARCHAR
	) RETURN VARCHAR IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.CapturedObjectInfo_SeanceUID( Object = ' ||
											pname || ', Key = ' || s.maskdata(pkey) || ')';
		vuid       VARCHAR(100);
		vlockdata  VARCHAR(32167);
		vlockvalue VARCHAR(32167);
		vlockkey   PLS_INTEGER;
		i          PLS_INTEGER;
		vstr       VARCHAR(32167);
	BEGIN
		err.seterror(0, 'Object.CapturedObjectInfo_SeanceIDcontext');
	
		vlockvalue := getlockvalue(pname, pkey);
		vlockkey   := dbms_utility.get_hash_value(vlockvalue, 0, 1073741824);
	
		vlockdata := sys_context(objectcontext.cnamespace, vlockkey);
		IF vlockdata IS NOT NULL
		THEN
			i := 1;
			LOOP
				i    := i + 1;
				vstr := htools.getsubstr(vlockdata, i, cdelim);
				EXIT WHEN vstr IS NULL;
				IF vstr NOT LIKE '_:%'
				THEN
					vlockdata := REPLACE(vlockdata, cdelim || vstr || cdelim, cdelim);
					objectcontext.set_context(vlockkey, vlockdata);
					i    := i - 1;
					vstr := NULL;
				END IF;
				IF vstr IS NOT NULL
				THEN
					vuid := htools.getsubstr(vstr, 2, ':');
					RETURN vuid;
				END IF;
			END LOOP;
		END IF;
		RETURN NULL;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			RETURN NULL;
	END;

	FUNCTION getcapturedinfo_seanceuid_t_
	(
		pname VARCHAR
	   ,pkey  VARCHAR
	) RETURN VARCHAR IS
		cprocname CONSTANT VARCHAR(1000) := cpackage ||
											'.CapturedObjectInfo_SeanceUID_T( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ')';
		vlockvalue VARCHAR(32167);
	BEGIN
		vlockvalue := getlockvalue(pname, pkey);
		FOR i IN (SELECT sessionuid FROM tlock WHERE key = vlockvalue)
		LOOP
			RETURN i.sessionuid;
		END LOOP;
		RETURN NULL;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			RETURN NULL;
	END;

	FUNCTION getcapturedinfo_seanceuid
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN VARCHAR IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.getCapturedInfo_SeanceUID( Object = ' ||
											pname || ', Key = ' || s.maskdata(pkey) || ')';
		vchangebranch BOOLEAN := FALSE;
		vret          VARCHAR(32767);
	BEGIN
	
		IF pcommonbranch
		   AND getbranch != seance.cbranch_common
		THEN
			vchangebranch := TRUE;
			setcommonbranch(TRUE);
		END IF;
	
		IF islockmodetable
		THEN
			vret := getcapturedinfo_seanceuid_t_(pname, pkey);
		ELSE
			vret := getcapturedinfo_seanceuid_(pname, pkey);
		END IF;
	
		IF vchangebranch
		THEN
			setcommonbranch(FALSE);
		END IF;
	
		RETURN vret;
	
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			IF vchangebranch
			THEN
				setcommonbranch(FALSE);
			END IF;
			RETURN NULL;
	END;

	FUNCTION capturedobjectinfo
	(
		pname         VARCHAR
	   ,pkey          VARCHAR
	   ,pcommonbranch BOOLEAN := FALSE
	) RETURN VARCHAR IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.CapturedObjectInfo( Object = ' || pname ||
											', Key = ' || s.maskdata(pkey) || ')';
		vchangebranch BOOLEAN := FALSE;
		vret          VARCHAR(32767);
	BEGIN
	
		IF pcommonbranch
		   AND getbranch != seance.cbranch_common
		THEN
			vchangebranch := TRUE;
			setcommonbranch(TRUE);
		END IF;
	
		IF islockmodetable
		THEN
			vret := capturedobjectinfo_table(pname, pkey);
		ELSE
			vret := capturedobjectinfo_context(pname, pkey);
		END IF;
	
		IF vchangebranch
		THEN
			setcommonbranch(FALSE);
		END IF;
	
		RETURN vret;
	
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cprocname);
			IF vchangebranch
			THEN
				setcommonbranch(FALSE);
			END IF;
			RETURN NULL;
	END;

	FUNCTION getremark
	(
		pcode         IN NUMBER
	   ,pcommonbranch BOOLEAN
	) RETURN VARCHAR IS
		vremark ta4mobj.remark%TYPE;
		vbranch NUMBER := getbranch();
	BEGIN
		IF pcommonbranch
		THEN
			vbranch := seance.cbranch_common;
		END IF;
	
		EXECUTE IMMEDIATE 'select Remark
	   from tA4mObj
	   where Branch = :Branch and
			 Code   = :Code'
			INTO vremark
			USING vbranch, pcode;
	
		RETURN vremark;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;

	FUNCTION gettype
	(
		pname         VARCHAR
	   ,pcommonbranch BOOLEAN
	) RETURN NUMBER IS
		vtype NUMBER;
		--vbranch NUMBER := getbranch();
		vbranch NUMBER := 1;
	BEGIN
		IF pcommonbranch
		THEN
			-- vbranch := cseance.cbranch_common;
			vbranch := custom_seance.cbranch_common;
		
			EXECUTE IMMEDIATE 'SELECT code
		 FROM tA4mObj
		 WHERE
		   Branch = :Branch AND
		   Name = :Name'
				INTO vtype
				USING vbranch, upper(TRIM(pname));
		ELSE
			initcash;
			vtype := scash_objcodelist(upper(TRIM(pname)));
		END IF;
	
		RETURN vtype;
	EXCEPTION
		WHEN OTHERS THEN
			--IF seance.getsystemmode != seance.mode_none
			IF custom_seance.getsystemmode != seance.mode_none
			THEN
				--s.err('Object.GetType(' || pname || ',common=' || htools.b2s(pcommonbranch) || ')');
				custom_s.err('Object.GetType(' || pname || ',common=' || htools.b2s(pcommonbranch) || ')');
			END IF;
			RETURN 0;
	END;

	FUNCTION getremarkbyname
	(
		pname         IN VARCHAR
	   ,pcommonbranch BOOLEAN
	) RETURN VARCHAR IS
		vremark ta4mobj.remark%TYPE;
		vbranch NUMBER := getbranch();
	BEGIN
		IF pcommonbranch
		THEN
			vbranch := seance.cbranch_common;
		END IF;
		EXECUTE IMMEDIATE 'select Remark
	   from tA4mObj
	   where Branch = :Branch and
			 Name = :Name'
			INTO vremark
			USING vbranch, upper(TRIM(pname));
		RETURN vremark;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;

	FUNCTION fillobjectarray
	(
		pacode   IN OUT NOCOPY typenumber
	   ,paremark IN OUT NOCOPY typevarchar
	) RETURN NUMBER IS
		vcount NUMBER;
		vbranch CONSTANT NUMBER := getbranch();
		CURSOR c1 IS
			SELECT * FROM ta4mobj WHERE branch = vbranch ORDER BY remark;
	BEGIN
		vcount := 0;
		FOR i IN c1
		LOOP
			vcount := vcount + 1;
			pacode(vcount) := i.code;
			paremark(vcount) := substr(i.remark, 1, 60);
		END LOOP;
		RETURN vcount;
	END;

	PROCEDURE setbranch(pbranch IN NUMBER) IS
	BEGIN
		scurbranch := pbranch;
	END;

	FUNCTION getcapturemode RETURN NUMBER IS
	BEGIN
		RETURN objectcapturemode.getcapturemode();
	END;

	PROCEDURE insertobject
	(
		pname        VARCHAR
	   ,premark      VARCHAR
	   ,ppackagename VARCHAR
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.InsertObject( Name = ' || pname ||
											', Remark = ' || premark || ', Package = ' ||
											ppackagename || ')';
	BEGIN
		s.say(cprocname || ' : start');
		insertsysobject(pname        => pname
					   ,ptype        => cobjtype_userclass
					   ,premark      => premark
					   ,pbranch      => getbranch()
					   ,ppackagename => ppackagename);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE deleteobject(pname VARCHAR) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.DeleteObject(' || pname || ')';
		vbranch   CONSTANT NUMBER := getbranch();
	BEGIN
		s.say(cprocname || ' : start');
	
		FOR cobj IN (SELECT *
					 FROM   ta4mobj
					 WHERE  branch = vbranch
					 AND    NAME = TRIM(upper(pname)))
		LOOP
			IF NOT htools.equal(cobj.type, cobjtype_userclass)
			THEN
				error.raiseerror(err.object_not_found
								,'System object ' || pname || ' cannot be deleted');
			END IF;
		
			DELETE FROM ta4mobj
			WHERE  branch = cobj.branch
			AND    code = cobj.code;
			BEGIN
				a4mlog.logobject(object.gettype('BRANCH')
								,0
								,'Deleted object ' || pname
								,a4mlog.act_del);
			EXCEPTION
				WHEN OTHERS THEN
					s.err(cprocname || '.log');
			END;
		
		END LOOP;
		initcash(pnow => TRUE);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE changeobjectremark
	(
		pname      IN VARCHAR
	   ,pnewremark VARCHAR
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.ChangeObjectRemark(Obj = ' || pname ||
											', new remark = ' || pnewremark || ')';
		vbranch NUMBER := getbranch();
	BEGIN
		FOR cobj IN (SELECT *
					 FROM   ta4mobj
					 WHERE  branch = vbranch
					 AND    NAME = TRIM(upper(pname)))
		LOOP
			IF NOT htools.equal(cobj.type, cobjtype_userclass)
			THEN
				error.raiseerror(err.object_not_found
								,'System object ' || pname || ' cannot be modified');
			END IF;
		
			UPDATE ta4mobj
			SET    remark = pnewremark
			WHERE  branch = cobj.branch
			AND    code = cobj.code;
		
			BEGIN
				IF SQL%ROWCOUNT > 0
				THEN
					a4mlog.cleanparamlist;
					a4mlog.addparamrec('Remark', cobj.remark, pnewremark);
					a4mlog.logobject(object.gettype('BRANCH')
									,0
									,'Modify object ' || pname
									,a4mlog.act_change
									,pparamlist => a4mlog.putparamlist);
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					s.err(cprocname || '.log');
			END;
		
		END LOOP;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION getnewobjtypecode RETURN NUMBER IS
		vcode NUMBER;
	BEGIN
		SELECT seq_a4mobjcode.nextval INTO vcode FROM dual;
		RETURN vcode;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackage || '.getNewObjTypeCode');
			RAISE;
	END;

	PROCEDURE insertsysobject
	(
		pname        VARCHAR
	   ,ptype        VARCHAR
	   ,premark      VARCHAR
	   ,pbranch      NUMBER
	   ,ppackagename VARCHAR := NULL
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.InsertSysObject( Name = ' || pname ||
											', Type = ' || ptype || ', pBranch = ' || pbranch ||
											', pRemark = ' || premark || ', Package = ' ||
											ppackagename || ' )';
		vcode NUMBER;
	BEGIN
		s.say(cprocname || ' : start');
		IF ptype NOT IN (cobjtype_class, cobjtype_resource, cobjtype_userclass)
		THEN
			error.raiseerror(err.object_internal_error
							,'Wrong type of object ' || pname || ' : ' || ptype);
		END IF;
		vcode := getnewobjtypecode();
	
		INSERT INTO ta4mobj
			(branch
			,code
			,NAME
			,TYPE
			,pipename
			,remark
			,packagename)
		VALUES
			(pbranch
			,vcode
			,TRIM(upper(pname))
			,ptype
			,TRIM(upper(pname))
			,premark
			,ppackagename);
		BEGIN
			a4mlog.logobject(object.gettype('BRANCH'), 0, 'Added object ' || pname, a4mlog.act_add);
		EXCEPTION
			WHEN OTHERS THEN
				s.err(cprocname || '.log');
		END;
		initcash(TRUE);
	EXCEPTION
		WHEN dup_val_on_index THEN
			error.save(cprocname);
			error.raiseerror(err.object_type_dublicate
							,'Branch : ' || getbranch || ', Object type : ' || pname);
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION clearpipe
	(
		pname   VARCHAR
	   ,pkey    VARCHAR
	   ,pbranch NUMBER := NULL
	) RETURN NUMBER IS
	BEGIN
		RETURN 2007;
	END;

BEGIN

	svsid := to_number(userenv('SESSIONID'));

	shandleexpire       := nvl(gethandleexpire, 864000 * 3.5);
	svsession_sid       := NULL;
	svsession_logontime := NULL;
	svsession_process   := NULL;
	svsession_terminal  := NULL;
	svsession_orauser   := NULL;
	svsession_info      := NULL;

END;
/
