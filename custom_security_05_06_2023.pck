CREATE OR REPLACE PACKAGE custom_security AS

	TYPE tkeytable IS TABLE OF VARCHAR(250) INDEX BY BINARY_INTEGER;
	object_name CONSTANT VARCHAR(20) := 'custom_SECURITY';

	chversion CONSTANT VARCHAR(100) := '$Rev: 44809 $';
	scodearray tkeytable;
	stextarray tkeytable;
	sarraysize NUMBER;

	stitle VARCHAR2(250);

	ccfg_root                 CONSTANT VARCHAR2(100) := object_name || '.CONFIG.';
	ccfg_view_curr_treebranch CONSTANT VARCHAR2(100) := ccfg_root || 'VIEW_CURR_TREEBRANCH';

	FUNCTION checkright
	(
		pobject IN VARCHAR
	   ,pkey    IN VARCHAR := NULL
	) RETURN BOOLEAN;
	PROCEDURE revokeallright(pclerkid IN NUMBER);
	PROCEDURE revokerightfromall
	(
		pobject       IN VARCHAR
	   ,pkey          IN VARCHAR := NULL
	   ,pincludechild BOOLEAN := FALSE
	);
	FUNCTION dialoglist RETURN NUMBER;

	PROCEDURE cleararray;
	PROCEDURE addrecord
	(
		pkey   VARCHAR
	   ,ptext  VARCHAR
	   ,pfinal BOOLEAN := FALSE
	);

	PROCEDURE fillsecurityarray
	(
		plevel IN NUMBER
	   ,pkey   IN VARCHAR
	);

	PROCEDURE makeuser2groupitem
	(
		puser    NUMBER
	   ,pdialog  NUMBER
	   ,pitem    VARCHAR
	   ,px       INTEGER
	   ,py       INTEGER
	   ,pw       INTEGER
	   ,ph       INTEGER
	   ,pcaption VARCHAR := NULL
	);

	PROCEDURE makegroupofuseritem
	(
		pgroupid NUMBER
	   ,pdialog  NUMBER
	   ,pitem    VARCHAR
	   ,px       INTEGER
	   ,py       INTEGER
	   ,pw       INTEGER
	   ,ph       INTEGER
	);
	PROCEDURE savegroupofuseritem
	(
		pgroupid NUMBER
	   ,pdialog  NUMBER
	   ,pitem    VARCHAR
	   ,pcommit  BOOLEAN := FALSE
	);

	ot_user  CONSTANT NUMBER := 1;
	ot_group CONSTANT NUMBER := 2;

	cbunchecked CONSTANT NUMBER := 0;
	cbchecked   CONSTANT NUMBER := 1;
	cbgrayed    CONSTANT NUMBER := 2;

	cmaxcountnode CONSTANT NUMBER := 1000;

	TYPE typeright IS RECORD(
		 key   VARCHAR(255)
		,text  VARCHAR(250)
		,FINAL BOOLEAN);
	TYPE typerights IS TABLE OF typeright INDEX BY BINARY_INTEGER;

	FUNCTION gettree
	(
		puserid   NUMBER := NULL
	   ,pusertype NUMBER := NULL
	) RETURN apitypes.typesecurnodetree;

	FUNCTION getuserlist RETURN apitypes.typesecuruserinfolist;
	FUNCTION getgrouplist RETURN apitypes.typesecurgroupinfolist;
	FUNCTION getaccessobjectlist RETURN apitypes.typesecurobjectinfolist;
	FUNCTION getusersofgrouplist(pgroupid NUMBER) RETURN apitypes.typesecuruserinfolist;
	FUNCTION getgroupsofuserlist(puserid NUMBER) RETURN apitypes.typesecurgroupinfolist;
	FUNCTION getuserinfo(puserid NUMBER) RETURN apitypes.typesecuruserinfo;
	FUNCTION getgroupinfo(pgroupid NUMBER) RETURN apitypes.typesecurgroupinfo;
	FUNCTION getaccessobjectinfo(pobjectid NUMBER) RETURN apitypes.typesecurobjectinfo;
	FUNCTION getuserrightlist
	(
		puserid          NUMBER
	   ,pwithgrouprigths BOOLEAN := TRUE
	) RETURN apitypes.typesecurrightinfolist;
	FUNCTION getgrouprightlist(pgroupid NUMBER) RETURN apitypes.typesecurrightinfolist;
	FUNCTION getaccesskeydescription
	(
		pobjectid   NUMBER
	   ,paccesskey  VARCHAR
	   ,pwithobject BOOLEAN := TRUE
	   ,pissearch   BOOLEAN := FALSE
	) RETURN VARCHAR;
	FUNCTION getaccesskeyid
	(
		pobjectid  NUMBER
	   ,paccesskey VARCHAR
	) RETURN NUMBER;
	FUNCTION getaccesskeylevel
	(
		pobjectid  NUMBER
	   ,paccesskey VARCHAR
	) RETURN NUMBER;

	FUNCTION isgrandedforuser
	(
		pobjectid        NUMBER
	   ,paccesskey       VARCHAR
	   ,puserid          NUMBER
	   ,pwithgrouprights BOOLEAN
	) RETURN BOOLEAN;
	FUNCTION isgrandedforgroup
	(
		pobjectid  NUMBER
	   ,paccesskey VARCHAR
	   ,pgroupid   NUMBER
	) RETURN BOOLEAN;
	FUNCTION getuserrightsforkey
	(
		pobjectid        NUMBER
	   ,paccesskey       VARCHAR
	   ,puserid          NUMBER
	   ,pwithgrouprights BOOLEAN
	) RETURN apitypes.typesecurrightinfolist;
	FUNCTION getgrouprightsforkey
	(
		pobjectid  NUMBER
	   ,paccesskey VARCHAR
	   ,pgroupid   NUMBER
	) RETURN apitypes.typesecurrightinfolist;

	PROCEDURE addrightnode
	(
		porights   IN OUT NOCOPY types.utree
	   ,pparent_i  PLS_INTEGER
	   ,prightkey  VARCHAR
	   ,prightname VARCHAR
	   ,pbefore_i  PLS_INTEGER := NULL
	);

	FUNCTION addrightnode
	(
		porights   IN OUT NOCOPY types.utree
	   ,pparent_i  PLS_INTEGER
	   ,prightkey  VARCHAR
	   ,prightname VARCHAR
	   ,pbefore_i  PLS_INTEGER := NULL
	) RETURN PLS_INTEGER;

	FUNCTION addrighttree
	(
		porights   IN OUT NOCOPY types.utree
	   ,pparent_i  PLS_INTEGER
	   ,psubrights IN OUT NOCOPY types.utree
	   ,pbefore_i  PLS_INTEGER := NULL
	) RETURN PLS_INTEGER;

	PROCEDURE delrightnode
	(
		porights IN OUT NOCOPY types.utree
	   ,pnode_i  PLS_INTEGER
	);

	PROCEDURE addrightstree(porights IN OUT NOCOPY types.utree);

	PROCEDURE dialoglisthandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE grantnodedialoghandler
	(
		pwhat   CHAR
	   ,pdialog NUMBER
	   ,pitem   VARCHAR
	   ,pcmd    NUMBER
	);
	PROCEDURE groupdialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE addgroupdialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE usergldialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE detaildialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE propertydialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE selectclerksdialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE selectgroupsdialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE accessdialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE dialogsearchrighthandler
	(
		pwhat   CHAR
	   ,pdialog NUMBER
	   ,pitem   VARCHAR
	   ,pcmd    NUMBER
	);
	PROCEDURE dialogsearchrightfunchandler
	(
		pwhat   CHAR
	   ,pdialog NUMBER
	   ,pitem   VARCHAR
	   ,pcmd    NUMBER
	);
	PROCEDURE user2grouphandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);

	FUNCTION getversion RETURN VARCHAR;
END;
/
CREATE OR REPLACE PACKAGE BODY custom_security AS

	cpackagename CONSTANT VARCHAR(100) := 'custom_Security';
	cversion     CONSTANT VARCHAR(100) := cpackagename ||
										  ' : ver $Rev: 45322 $ at $Date:: 2022-08-19 14:15:17#$';

	cnodecycleid    CONSTANT VARCHAR2(100) := 'NodeCycle';
	cnodecycleoneid CONSTANT VARCHAR2(100) := 'NodeCycle1';
	cnodecycletwoid CONSTANT VARCHAR2(100) := 'NodeCycle2';
	csubsystemid    CONSTANT VARCHAR2(100) := 'SubSystem';
	csubsystemdata  CONSTANT VARCHAR2(100) := 'SubSystemData';

	group_object_name CONSTANT VARCHAR(100) := 'CLERKGROUP';
	right_view        CONSTANT NUMBER := 1;
	right_modify      CONSTANT NUMBER := 2;

	right_grant           CONSTANT NUMBER := 2;
	right_grant_user      CONSTANT NUMBER := 21;
	right_grant_self      CONSTANT NUMBER := 22;
	right_grant_group     CONSTANT NUMBER := 23;
	right_grant_group_all CONSTANT NUMBER := -230;

	right_group            CONSTANT NUMBER := 3;
	right_group_create     CONSTANT NUMBER := 31;
	right_group_delete     CONSTANT NUMBER := 32;
	right_group_modify     CONSTANT NUMBER := 33;
	right_group_modify_all CONSTANT NUMBER := -330;

	right_delegate CONSTANT NUMBER := 5;

	SUBTYPE typetree IS VARCHAR(1);
	ctree_grant  CONSTANT typetree := 'G';
	ctree_access CONSTANT typetree := 'A';

	cnode_undefine CONSTANT NUMBER := -1;
	cnode_leaf     CONSTANT NUMBER := 0;

	SUBTYPE typenodestate IS PLS_INTEGER;

	cstate_notavail  CONSTANT typenodestate := -8;
	cstate_undefined CONSTANT typenodestate := -1;
	cstate_uncheck   CONSTANT typenodestate := cbunchecked;
	cstate_check     CONSTANT typenodestate := cbchecked;
	cstate_gray      CONSTANT typenodestate := cbgrayed;
	cstate_checkall  CONSTANT typenodestate := 8;

	caaddgrants  CONSTANT NUMBER := 0;
	cadropgrants CONSTANT NUMBER := 1;
	caaddaccess  CONSTANT NUMBER := 2;
	cadropaccess CONSTANT NUMBER := 3;

	cmax_view_rows NUMBER := 1000;
	cnull CONSTANT VARCHAR2(10) := 'NULL';
	dummy VARCHAR(32767);

	TYPE typecashrigths IS TABLE OF BOOLEAN INDEX BY VARCHAR(50);

	scashrigths typecashrigths;
	TYPE typecashobjectid IS TABLE OF NUMBER INDEX BY VARCHAR(40);
	sacashobjectid typecashobjectid;
	scashbranch    NUMBER;
	scashclerk     NUMBER;
	scashtime      DATE;
	ccashlatency CONSTANT NUMBER := 5 * 1 / (24 * 60);

	TYPE tobjectinfo IS RECORD(
		 packagename VARCHAR(128)
		,objectid    NUMBER);

	TYPE tobjectinfoarray IS TABLE OF tobjectinfo INDEX BY BINARY_INTEGER;

	SUBTYPE keytype IS VARCHAR2(250);
	SUBTYPE idxkeytype IS VARCHAR2(500);

	TYPE typeaccesskey IS RECORD(
		 id          NUMBER
		,objectid    NUMBER
		,key         keytype
		,LEVEL       NUMBER
		,description VARCHAR(1000));

	TYPE typeaccesskeymap IS TABLE OF typeaccesskey INDEX BY idxkeytype;

	slastsisize NUMBER;
	slastsicode security.tkeytable;
	slastsitext security.tkeytable;
	slastsifin  types.arrbool;

	sfinarray types.arrbool;

	slasttree    types.utree;
	suseoldarray BOOLEAN;

	sbasetree      apitypes.typesecurnodetree;
	sbasetreemap   typeaccesskeymap;
	sbasetreenames types.arrtext;
	saccesstree    apitypes.typesecurnodetree;

	sasearchtree         apitypes.typesecurnodetree;
	ssearchbasetree      apitypes.typesecurnodetree;
	ssearchbasetreemap   typeaccesskeymap;
	ssearchbasetreenames types.arrtext;
	ssearchnotendbranch  apitypes.typesecurnodetree;
	safuncobjects        types.arrnum;

	satree           apitypes.typesecurnodetree;
	saprevtree       apitypes.typesecurnodetree;
	saobjectinfo     tobjectinfoarray;
	scurobjectindex  NUMBER;
	snumobjects      NUMBER;
	slastnodeid      NUMBER := 0;
	ssomenodechanged BOOLEAN := FALSE;

	snumusers NUMBER;
	scurlevel NUMBER := 0;

	scuruserid   NUMBER;
	scurusertype NUMBER;

	sprevuserid   NUMBER;
	sprevusertype NUMBER;

	scurusername    VARCHAR(80);
	snumgroups      NUMBER;
	scurgroupid     NUMBER;
	scurgroupname   tclerkgroup.name%TYPE;
	scurgroupremark tclerkgroup.remark%TYPE;
	streemode       typetree;
	isfullview      BOOLEAN := FALSE;

	sagroup types.arrnum;
	saclerk types.arrnum;

	TYPE typecurinfo IS RECORD(
		 branch   trights.branch%TYPE
		,userid   trights.userid%TYPE
		,username VARCHAR(1000)
		,usertype trights.usertype%TYPE
		,oldkeys  typeaccesskeymap
		,newkeys  typeaccesskeymap);

	scurinfo    typecurinfo;
	smaindialog NUMBER;

	PROCEDURE clearsiarrays;

	PROCEDURE fillsecurityinfofor(pnode IN apitypes.typesecurnode);
	PROCEDURE fillsecurityinfobyfunc
	(
		pnode           IN apitypes.typesecurnode
	   ,psearchmode     BOOLEAN := FALSE
	   ,psearchtemplate VARCHAR := NULL
	);
	PROCEDURE buildsearchbasenode
	(
		pparentnode     IN apitypes.typesecurnode
	   ,psearchtemplate VARCHAR
	);
	FUNCTION getflaglimitedview RETURN BOOLEAN;

	FUNCTION getnode(pnodeid IN NUMBER) RETURN apitypes.typesecurnode;

	PROCEDURE checkratio(pnode IN apitypes.typesecurnode);
	FUNCTION getratio(pnode IN apitypes.typesecurnode) RETURN NUMBER;

	PROCEDURE filluserlist(pdialog IN NUMBER);

	FUNCTION groupdialog RETURN NUMBER;
	FUNCTION usergldialog RETURN NUMBER;
	FUNCTION addgroupdialog RETURN NUMBER;
	FUNCTION detaildialog RETURN NUMBER;
	FUNCTION propertydialog RETURN NUMBER;
	PROCEDURE fillgrouplist(pdialog IN NUMBER);

	FUNCTION groupexists(pgname IN VARCHAR) RETURN BOOLEAN;
	FUNCTION existsingroup
	(
		pclerkcode IN NUMBER
	   ,pgroupid   IN NUMBER
	) RETURN BOOLEAN;

	PROCEDURE deleteuserfromgroup
	(
		puserid  NUMBER
	   ,pgroupid NUMBER
	);

	PROCEDURE insertuserintocurrentgroup(puserid NUMBER);
	PROCEDURE insertuserintogroup
	(
		puserid  NUMBER
	   ,pgroupid NUMBER
	);

	FUNCTION hasmarked
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	) RETURN BOOLEAN;
	FUNCTION getposofcode
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcode     IN NUMBER
	) RETURN NUMBER;

	FUNCTION thisobjectgranted(pobjid IN NUMBER) RETURN BOOLEAN;
	FUNCTION haskeylikethis(pkey IN VARCHAR) RETURN BOOLEAN;
	FUNCTION haskeyexactlythis(pkey IN VARCHAR) RETURN BOOLEAN;
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
	FUNCTION getcharmark(pstate IN NUMBER) RETURN VARCHAR;
	FUNCTION getstatebychar(pchar IN NUMBER) RETURN NUMBER;
	FUNCTION getcheckweight(pstate IN NUMBER) RETURN NUMBER;
	PROCEDURE savetree;
	PROCEDURE logaction
	(
		paction IN NUMBER
	   ,pnode   IN apitypes.typesecurnode
	);
	FUNCTION getsubnodedtext
	(
		ptext     IN VARCHAR
	   ,psubnodes IN INTEGER
	) RETURN VARCHAR;

	FUNCTION clerkvalid(pcode NUMBER) RETURN BOOLEAN;

	PROCEDURE fillusersofgroup
	(
		pdialog  NUMBER
	   ,plist    VARCHAR
	   ,pgroupid NUMBER
	);
	FUNCTION selectclerksdialog RETURN NUMBER;

	PROCEDURE fillgroupsofuser
	(
		pdialog       NUMBER
	   ,plist         VARCHAR
	   ,pclerkid      NUMBER
	   ,pbuttonremove VARCHAR := 'btnRemove'
	);
	FUNCTION selectgroupsdialog RETURN NUMBER;

	FUNCTION gethashvalue
	(
		pobjectid  NUMBER
	   ,paccesskey VARCHAR
	) RETURN VARCHAR2;

	PROCEDURE showsearchright(pnodeid NUMBER);

	PROCEDURE starttimer(cwhere VARCHAR2);
	PROCEDURE stoptimer(cwhere VARCHAR2);

	FUNCTION getversion RETURN VARCHAR IS
	BEGIN
		RETURN service.formatpackageversion(cpackagename, chversion, cversion);
	END;

	PROCEDURE say(ptext VARCHAR) IS
	BEGIN
		IF ptext LIKE cpackagename || '%'
		THEN
			s.say(ptext);
		ELSE
			s.say(cpackagename || ': ' || ptext);
		END IF;
	END;

	PROCEDURE refreshcash IS
	BEGIN
		IF (scashbranch = seance.getbranch)
		   AND (scashclerk = seance.getclerkcode)
		   AND ((SYSDATE - scashtime) < ccashlatency)
		THEN
			RETURN;
		END IF;
		scashbranch := seance.getbranch;
		scashclerk  := seance.getclerkcode;
		scashtime   := SYSDATE;
		scashrigths.delete;
		cmax_view_rows := nvl(htools.getcfg_num('SECURITY.VIEW.MAX_ROWS'), 1000);
	END;

	PROCEDURE putnodetomap
	(
		pomap IN OUT NOCOPY typeaccesskeymap
	   ,pnode apitypes.typesecurnode
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.putNodeToMap';
		vkey typeaccesskey := NULL;
		vidx idxkeytype;
	BEGIN
		timer.start_(cwhere);
		vkey.id          := pnode.id;
		vkey.objectid    := pnode.objectid;
		vkey.key         := pnode.key;
		vkey.level       := pnode.level;
		vkey.description := pnode.text;
		vidx             := gethashvalue(vkey.objectid, vkey.key);
		s.say(cwhere || ' hash-key: ' || vidx || '~: ID=' || vkey.id || ', ObjectID=' ||
			  vkey.objectid || ', Key=' || vkey.key || ', Level=' || vkey.level ||
			  ', Description=' || vkey.description);
	
		IF pomap.exists(vidx)
		THEN
			htools.message('Hash collision!'
						  ,'Equal hash-key:~Exists node: ObjectID=' || pomap(vidx).objectid ||
						   ', Key=' || pomap(vidx).key || ', Text=' || pomap(vidx).description ||
						   '~New node: ObjectID=' || pnode.objectid || ', Key=' || pnode.key ||
						   ', Text=' || pnode.text);
		END IF;
	
		pomap(vidx) := vkey;
		timer.stop_(cwhere);
	END;

	PROCEDURE log_init IS
	BEGIN
		a4mlog.cleaneventlist;
		a4mlog.cleanplist;
	END;

	PROCEDURE log_add
	(
		pobjectid NUMBER
	   ,pkey      VARCHAR
	) IS
	BEGIN
		timer.start_(cpackagename || '.log_add');
	
		a4mlog.addparamrec(pobjectid || ':' || pkey, getaccesskeydescription(pobjectid, pkey));
		timer.stop_(cpackagename || '.log_add');
	EXCEPTION
		WHEN OTHERS THEN
			error.save('LogAction');
			RAISE;
	END;

	PROCEDURE log_write(paction NUMBER) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.log_write';
		vlogaction VARCHAR(50);
		vloginfo   VARCHAR(32000);
		vaction    NUMBER;
	BEGIN
		timer.start_(cwhere);
		CASE paction
			WHEN caaddgrants THEN
				vlogaction := 'Add rights';
				vaction    := a4mlog.act_add;
			WHEN cadropgrants THEN
				vlogaction := 'Delete rights';
				vaction    := a4mlog.act_del;
			WHEN caaddaccess THEN
				vlogaction := 'Add access to assign right';
				vaction    := a4mlog.act_add;
			WHEN cadropaccess THEN
				vlogaction := 'Block access to assign right';
				vaction    := a4mlog.act_del;
			ELSE
				NULL;
		END CASE;
	
		IF (scurusertype = ot_user)
		THEN
			vloginfo := 'For ';
			a4mlog.addparamrec('User', scurusername);
		ELSE
			vloginfo := 'For group';
			a4mlog.addparamrec('Group', scurusername);
		END IF;
		vloginfo := vloginfo || scurusername || ' ';
	
		a4mlog.logobject(object.gettype('SECURITY')
						,vlogaction
						,vloginfo
						,vaction
						,a4mlog.putparamlist);
		timer.stop_(cwhere);
	END;

	FUNCTION readrights
	(
		puserid   NUMBER
	   ,pusertype NUMBER
	) RETURN typeaccesskeymap IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.readRights';
		vmap    typeaccesskeymap;
		vaobj   types.arrnum;
		vakey   types.arrstr250;
		vhash   idxkeytype;
		vbranch NUMBER := seance.getbranch();
	
		vflaglimitedview BOOLEAN := getflaglimitedview();
		vafuncobjects    tblnumber := tblnumber();
		i                NUMBER := 0;
	
	BEGIN
		timer.start_(cwhere);
	
		timer.start_(cwhere || '.read');
	
		IF vflaglimitedview
		   AND safuncobjects.count > 0
		THEN
			i := safuncobjects.first();
			WHILE i IS NOT NULL
			LOOP
				vafuncobjects.extend(1);
				vafuncobjects(i) := safuncobjects(i);
				s.say(cwhere || ' vaFuncObjects(i)=' || vafuncobjects(i));
				i := safuncobjects.next(i);
			END LOOP;
			s.say(cwhere || ' vaFuncObjects.count=' || vafuncobjects.count);
		
			SELECT t.objectid
				  ,t.accesskey BULK COLLECT
			INTO   vaobj
				  ,vakey
			FROM   trights t
			WHERE  branch = vbranch
			AND    userid = puserid
			AND    usertype = pusertype
			AND    objectid NOT IN (SELECT * FROM TABLE(vafuncobjects));
		
		ELSE
			SELECT t.objectid
				  ,t.accesskey BULK COLLECT
			INTO   vaobj
				  ,vakey
			FROM   trights t
			WHERE  branch = vbranch
			AND    userid = puserid
			AND    usertype = pusertype;
		END IF;
		timer.stop_(cwhere || '.read');
	
		FOR i IN 1 .. vakey.count
		LOOP
			IF vakey(i) = cnull
			THEN
				vakey(i) := '|';
			END IF;
			vhash := gethashvalue(vaobj(i), vakey(i));
			vmap(vhash).objectid := vaobj(i);
			vmap(vhash).key := vakey(i);
		END LOOP;
	
		timer.stop_(cwhere);
		RETURN vmap;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere || '(' || puserid || ',' || pusertype || ')');
			RAISE;
	END;

	PROCEDURE writerights
	(
		puserid   NUMBER
	   ,pusertype NUMBER
	   ,pmap      typeaccesskeymap
	) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.writeRights';
		vbranch NUMBER := seance.getbranch;
		vaobj   types.arrnum;
		vakey   types.arrstr250;
		vhash   idxkeytype;
		i       NUMBER;
	BEGIN
		timer.start_(cwhere);
		vhash := pmap.first;
		i     := 0;
		WHILE vhash IS NOT NULL
		LOOP
			i := i + 1;
			vaobj(i) := pmap(vhash).objectid;
			vakey(i) := pmap(vhash).key;
			IF vakey(i) = '|'
			THEN
				vakey(i) := cnull;
			END IF;
			vhash := pmap.next(vhash);
		END LOOP;
	
		timer.start_(cwhere || '.insert');
		FORALL i IN INDICES OF vakey
			INSERT INTO trights
				(branch
				,userid
				,usertype
				,objectid
				,accesskey)
			VALUES
				(vbranch
				,puserid
				,pusertype
				,vaobj(i)
				,vakey(i));
		timer.stop_(cwhere || '.insert');
		timer.stop_(cwhere);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE removerights
	(
		puserid   NUMBER
	   ,pusertype NUMBER
	   ,pmap      typeaccesskeymap
	) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.removeRights';
		vbranch NUMBER := seance.getbranch;
		vaobj   types.arrnum;
		vakey   types.arrstr250;
		vhash   idxkeytype;
		i       NUMBER;
	BEGIN
		timer.start_(cwhere);
		vhash := pmap.first;
		i     := 0;
		WHILE vhash IS NOT NULL
		LOOP
			i := i + 1;
			vaobj(i) := pmap(vhash).objectid;
			vakey(i) := pmap(vhash).key;
			IF vakey(i) = '|'
			THEN
				vakey(i) := cnull;
			END IF;
			vhash := pmap.next(vhash);
		END LOOP;
	
		timer.start_(cwhere || '.delete');
		FORALL i IN INDICES OF vakey
			DELETE FROM trights
			WHERE  branch = vbranch
			AND    userid = puserid
			AND    usertype = pusertype
			AND    objectid = vaobj(i)
			AND    accesskey = vakey(i);
		timer.stop_(cwhere || '.delete');
		timer.stop_(cwhere);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE initcurrent
	(
		puserid   NUMBER
	   ,pusertype NUMBER
	   ,pusername VARCHAR := NULL
	   ,pnoload   BOOLEAN := FALSE
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.initCurrent';
	BEGIN
		s.say(cwhere || ' pNoLoad=' || htools.b2s(pnoload));
		scurinfo          := NULL;
		scurinfo.branch   := seance.getbranch;
		scurinfo.userid   := puserid;
		scurinfo.usertype := pusertype;
		scurinfo.username := pusername;
		IF NOT pnoload
		THEN
			scurinfo.oldkeys := readrights(scurinfo.userid, scurinfo.usertype);
		END IF;
	END;

	FUNCTION checkright_
	(
		pobjectid IN NUMBER
	   ,pkey      IN VARCHAR
	) RETURN BOOLEAN IS
		vbranch CONSTANT NUMBER := seance.getbranch();
		vclerk   NUMBER;
		vsysdate DATE;
	BEGIN
		s.say('Run:CheckRight_(pObjectID=' || pobjectid || ', pKey=' || pkey || ') ', 3);
		IF ((clerk.getname = 'A4M') AND (pobjectid = sacashobjectid(object_name)))
		THEN
			RETURN TRUE;
		END IF;
		vclerk := clerk.getcode;
	
		vsysdate := SYSDATE;
		FOR i IN (SELECT /*+ Ordered INDEX(r iRight)*/
				   r.accesskey
				  FROM   tclerk2group g
						,tclerkgroup  gr
						,trights      r
				  WHERE  g.branch = vbranch
				  AND    g.clerkid = vclerk
				  AND    gr.branch = g.branch
				  AND    gr.id = g.groupid
				  AND    gr.active = 1
				  AND    (vsysdate BETWEEN coalesce(gr.startdate, vsysdate) AND
						coalesce(gr.enddate, vsysdate))
				  AND    r.branch = g.branch
				  AND    r.userid = g.groupid
				  AND    r.usertype = ot_group
				  AND    r.objectid = pobjectid
				  AND    r.accesskey LIKE nvl(pkey, cnull) || '%')
		LOOP
			RETURN TRUE;
		END LOOP;
	
		FOR i IN (SELECT /*+ Ordered INDEX(r iRight)*/
				   r.accesskey
				  FROM   trights r
				  WHERE  r.branch = vbranch
				  AND    r.userid = vclerk
				  AND    r.usertype = ot_user
				  AND    r.objectid = pobjectid
				  AND    r.accesskey LIKE nvl(pkey, cnull) || '%')
		LOOP
			RETURN TRUE;
		END LOOP;
	
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN FALSE;
	END;

	FUNCTION checkaright_
	(
		pobjectid IN NUMBER
	   ,pkey      IN VARCHAR
	) RETURN BOOLEAN IS
		vbranch CONSTANT NUMBER := seance.getbranch();
		vclerk   NUMBER;
		vsysdate DATE;
	BEGIN
		s.say('Run:CheckARight_(pObjectID=' || pobjectid || ', pKey=' || pkey || ') ', 3);
		IF (clerk.getname = 'A4M')
		THEN
			RETURN TRUE;
		END IF;
		vclerk := clerk.getcode;
	
		vsysdate := SYSDATE;
		FOR i IN (SELECT /*+ Ordered INDEX(r iAccessRight)*/
				   r.accesskey
				  FROM   tclerk2group  g
						,tclerkgroup   gr
						,taccessrights r
				  WHERE  g.branch = vbranch
				  AND    g.clerkid = vclerk
				  AND    gr.branch = g.branch
				  AND    gr.id = g.groupid
				  AND    gr.active = 1
				  AND    (vsysdate BETWEEN coalesce(gr.startdate, vsysdate) AND
						coalesce(gr.enddate, vsysdate))
				  AND    r.branch = g.branch
				  AND    r.userid = g.groupid
				  AND    r.usertype = ot_group
				  AND    r.objectid = pobjectid
				  AND    nvl(pkey, cnull) LIKE r.accesskey)
		LOOP
			RETURN TRUE;
		END LOOP;
	
		FOR i IN (SELECT /*+ Ordered INDEX(r iAccessRight)*/
				   r.accesskey
				  FROM   taccessrights r
				  WHERE  r.branch = vbranch
				  AND    r.userid = vclerk
				  AND    r.usertype = ot_user
				  AND    r.objectid = pobjectid
				  AND    nvl(pkey, cnull) LIKE r.accesskey)
		LOOP
			RETURN TRUE;
		END LOOP;
	
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN FALSE;
	END;

	FUNCTION checkright
	(
		pobject IN VARCHAR
	   ,pkey    IN VARCHAR
	) RETURN BOOLEAN IS
		vkey   VARCHAR(50 BYTE);
		vcheck BOOLEAN;
	BEGIN
		s.say('Run:CheckRight(pObject=' || pobject || ', pKey=' || pkey || ') ', 3);
		refreshcash;
		BEGIN
			vkey := sacashobjectid(pobject) || ':' || pkey;
		EXCEPTION
			WHEN value_error THEN
				s.say('Warning!!! Access key too long! Use most optimality code');
				vkey := NULL;
		END;
	
		IF vkey IS NOT NULL
		   AND scashrigths.exists(vkey)
		THEN
			RETURN scashrigths(vkey);
		END IF;
	
		vcheck := checkright_(sacashobjectid(pobject), pkey);
		IF vkey IS NOT NULL
		THEN
			scashrigths(vkey) := vcheck;
		END IF;
	
		RETURN vcheck;
	
	EXCEPTION
		WHEN OTHERS THEN
			s.err('Secutity.CheckRight()');
			RETURN FALSE;
	END;

	FUNCTION checkright(pright IN NUMBER) RETURN BOOLEAN IS
	BEGIN
		IF pright IN (right_group_create, right_group_delete, right_group_modify)
		THEN
			RETURN checkright(object_name, '|' || right_group || '|' || to_char(pright) || '|');
		
		ELSIF pright IN (right_grant_group, right_grant_user, right_grant_self)
		THEN
			RETURN checkright(object_name, '|' || right_grant || '|' || to_char(pright) || '|');
		
		ELSIF pright IN (right_group_modify_all)
		THEN
			RETURN checkright(object_name
							 ,'|' || right_group || '|' || right_group_modify || '|' ||
							  to_char(pright) || '|');
		
		ELSIF pright IN (right_grant_group_all)
		THEN
			RETURN checkright(object_name
							 ,'|' || right_grant || '|' || right_grant_group || '|' ||
							  to_char(pright) || '|');
		
		ELSE
			RETURN checkright(object_name, '|' || to_char(pright) || '|');
		
		END IF;
	END;

	FUNCTION checkright2group
	(
		pright      IN NUMBER
	   ,pgroupid    NUMBER
	   ,pwithoutall BOOLEAN := FALSE
	) RETURN BOOLEAN IS
	BEGIN
		IF NOT pwithoutall
		THEN
			IF (CASE pright
				   WHEN right_grant_group THEN
					checkright(object_name
							  ,'|' || right_grant || '|' || right_grant_group || '|' ||
							   right_grant_group_all || '|')
				   WHEN right_group_modify THEN
					checkright(object_name
							  ,'|' || right_group || '|' || right_group_modify || '|' ||
							   right_group_modify_all || '|')
				   ELSE
					NULL
			   END)
			THEN
				RETURN TRUE;
			END IF;
		END IF;
		RETURN CASE pright WHEN right_grant_group THEN checkright(object_name
																 ,'|' || right_grant || '|' ||
																  right_grant_group || '|' ||
																  to_char(pgroupid) || '|') WHEN right_group_modify THEN checkright(object_name
																																   ,'|' ||
																																	right_group || '|' ||
																																	right_group_modify || '|' ||
																																	to_char(pgroupid) || '|') ELSE NULL END;
	END;

	FUNCTION haskeylikethis(pkey IN VARCHAR) RETURN BOOLEAN IS
	
		CURSOR vcursor(prightkey IN VARCHAR2) IS
			SELECT *
			FROM   trights
			WHERE  branch = seance.getbranch
			AND    userid = scuruserid
			AND    usertype = scurusertype
			AND    objectid = saobjectinfo(scurobjectindex).objectid
			AND    accesskey LIKE prightkey || '%';
	BEGIN
		FOR i IN vcursor(nvl(pkey, cnull))
		LOOP
			RETURN TRUE;
		END LOOP;
		RETURN FALSE;
	END;

	FUNCTION hasakeyexactlythis(pkey IN VARCHAR) RETURN BOOLEAN IS
	
		CURSOR vcursor IS
			SELECT *
			FROM   taccessrights
			WHERE  branch = seance.getbranch
			AND    userid = scuruserid
			AND    usertype = scurusertype
			AND    objectid = saobjectinfo(scurobjectindex).objectid
			AND    accesskey = pkey;
	
		CURSOR vcursor2 IS
			SELECT *
			FROM   taccessrights
			WHERE  branch = seance.getbranch
			AND    userid = scuruserid
			AND    usertype = scurusertype
			AND    objectid = saobjectinfo(scurobjectindex).objectid
			AND    accesskey = cnull;
	BEGIN
		IF (pkey = '|')
		THEN
			FOR i IN vcursor2
			LOOP
				s.say(' +++++++++2+ HasAKeyExactlyThis  ' || pkey || ' true');
				RETURN TRUE;
			END LOOP;
		ELSE
			FOR i IN vcursor
			LOOP
				s.say(' +++++++++++ HasAKeyExactlyThis ' || pkey || ' true');
				RETURN TRUE;
			END LOOP;
		END IF;
		s.say(' ---------- HasAKeyExactlyThis ' || pkey || ' false');
		RETURN FALSE;
	END;

	FUNCTION haskeyexactlythis(pkey IN VARCHAR) RETURN BOOLEAN IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.HasKeyExactlyThis';
		vbranch NUMBER := seance.getbranch();
	
		CURSOR vcursor(prightkey IN VARCHAR2) IS
			SELECT *
			FROM   trights
			WHERE  branch = vbranch
			AND    userid = scuruserid
			AND    usertype = scurusertype
			AND    objectid = saobjectinfo(scurobjectindex).objectid
			AND    accesskey = pkey;
	
		CURSOR vcursor2(prightkey IN VARCHAR2) IS
			SELECT *
			FROM   trights
			WHERE  branch = vbranch
			AND    userid = scuruserid
			AND    usertype = scurusertype
			AND    objectid = saobjectinfo(scurobjectindex).objectid
			AND    accesskey = cnull;
	BEGIN
		timer.start_(cwhere);
		IF (pkey = '|')
		THEN
			FOR i IN vcursor2(nvl(pkey, cnull))
			LOOP
				timer.stop_(cwhere);
				RETURN TRUE;
			END LOOP;
		ELSE
			FOR i IN vcursor(nvl(pkey, cnull))
			LOOP
				timer.stop_(cwhere);
				RETURN TRUE;
			END LOOP;
		END IF;
		timer.stop_(cwhere);
		RETURN FALSE;
	END;

	FUNCTION hasaccessallkey
	(
		pobject NUMBER := NULL
	   ,pkey    VARCHAR
	) RETURN BOOLEAN IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.HasAccessAllKey(' || pobject ||
										 ', key : ' || pkey || ')';
	BEGIN
		say(cwhere || ' : start');
		IF USER = 'A4M'
		THEN
			RETURN TRUE;
		END IF;
	
		FOR i IN (WITH s AS
					   (SELECT seance.getclerkcode AS userid
							 ,security.ot_user    AS usertype
					   FROM   dual
					   UNION ALL
					   SELECT gr.groupid        AS userid
							 ,security.ot_group AS usertype
					   FROM   tclerk2group gr
					   WHERE  gr.branch = seance.getbranch
					   AND    gr.clerkid = seance.getclerkcode)
					  SELECT 1
					  FROM   taccessrights t
							,s
					  WHERE  t.branch = seance.getbranch
					  AND    (pobject IS NULL OR t.objectid = pobject)
					  AND    t.userid = s.userid
					  AND    t.usertype = s.usertype
					  AND    coalesce(pkey, '%') LIKE t.accesskey
					  AND    rownum = 1)
		LOOP
			say(cwhere || ' : return true');
			RETURN TRUE;
		END LOOP;
		say(cwhere || ' : return false');
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION hasanyaccesskey(pobject NUMBER := NULL) RETURN BOOLEAN IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.HasAnyAccessKey(' || pobject || ')';
	BEGIN
		say(cwhere || ' : start');
		IF USER = 'A4M'
		THEN
			RETURN TRUE;
		END IF;
	
		FOR i IN (WITH s AS
					   (SELECT seance.getclerkcode AS userid
							 ,security.ot_user    AS usertype
					   FROM   dual
					   UNION ALL
					   SELECT gr.groupid        AS userid
							 ,security.ot_group AS usertype
					   FROM   tclerk2group gr
					   WHERE  gr.branch = seance.getbranch
					   AND    gr.clerkid = seance.getclerkcode)
					  SELECT 1
					  FROM   taccessrights t
							,s
					  WHERE  t.branch = seance.getbranch
					  AND    (pobject IS NULL OR t.objectid = pobject)
					  AND    t.userid = s.userid
					  AND    t.usertype = s.usertype
					  AND    rownum = 1)
		LOOP
			say(cwhere || ' : return true');
			RETURN TRUE;
		END LOOP;
		say(cwhere || ' : return false');
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE setsubnodesstate
	(
		pnode  IN apitypes.typesecurnode
	   ,pstate IN NUMBER
	) IS
	BEGIN
		IF cstate_notavail = pnode.state
		THEN
			RETURN;
		END IF;
		satree(pnode.id).state := pstate;
		IF NOT cnode_leaf = pnode.subnodes
		THEN
			FOR i IN 0 .. pnode.subnodes - 1
			LOOP
				setsubnodesstate(satree(pnode.substart + i), pstate);
			END LOOP;
		END IF;
	END;

	FUNCTION getsubnodedtext(pnode apitypes.typesecurnode) RETURN VARCHAR IS
	BEGIN
		RETURN pnode.text || CASE pnode.subnodes WHEN 0 THEN ' [' || pnode.subnodes || ']' ELSE '' END;
	END;

	FUNCTION getsubnodecount(pparentid IN NUMBER) RETURN NUMBER IS
		vcount NUMBER := 0;
	BEGIN
		IF NOT satree.exists(pparentid)
		THEN
			RETURN NULL;
		END IF;
		IF satree(pparentid).subnodes != cnode_leaf
		THEN
			FOR i IN satree(pparentid).substart .. (satree(pparentid)
												   .substart + satree(pparentid).subnodes - 1)
			LOOP
				IF satree(i).state NOT IN (cstate_notavail, cstate_undefined)
				THEN
					vcount := vcount + 1;
				END IF;
			END LOOP;
		END IF;
	
		RETURN vcount;
	END;

	FUNCTION getstateaccordingsubnodes
	(
		pnode  apitypes.typesecurnode
	   ,pratio NUMBER := NULL
	) RETURN NUMBER IS
		vratio NUMBER := pratio;
	BEGIN
		IF vratio IS NULL
		THEN
			vratio := getratio(pnode);
		END IF;
	
		RETURN CASE vratio WHEN 0 THEN cstate_uncheck WHEN getsubnodecount(pnode.id) THEN cstate_check ELSE cstate_gray END;
	END;

	PROCEDURE checkratio(pnode IN apitypes.typesecurnode) IS
		vratio NUMBER := 0;
	BEGIN
		IF (pnode.subnodes = cnode_leaf)
		THEN
			RETURN;
		END IF;
	
		FOR i IN 0 .. pnode.subnodes - 1
		LOOP
			checkratio(satree(pnode.substart + i));
			vratio := vratio + getcheckweight(satree(pnode.substart + i).state);
		END LOOP;
	
		IF satree(pnode.id).state != cstate_checkall
		THEN
			satree(pnode.id).state := getstateaccordingsubnodes(pnode, vratio);
		END IF;
	
	END;

	FUNCTION getratio(pnode IN apitypes.typesecurnode) RETURN NUMBER IS
		vratio NUMBER := 0;
	BEGIN
		IF pnode.state = cstate_checkall
		THEN
			RETURN pnode.subnodes;
		END IF;
	
		FOR i IN 0 .. pnode.subnodes - 1
		LOOP
			vratio := vratio + getcheckweight(satree(pnode.substart + i).state);
		END LOOP;
	
		RETURN vratio;
	END;

	FUNCTION getcheckweight(pstate IN NUMBER) RETURN NUMBER IS
	BEGIN
		RETURN CASE pstate WHEN cstate_check THEN 1 WHEN cstate_uncheck THEN 0 WHEN cstate_checkall THEN 1 WHEN cstate_gray THEN 0.5 ELSE 0 END;
	
	END;

	PROCEDURE grant_
	(
		pnode     apitypes.typesecurnode
	   ,puserid   NUMBER := NULL
	   ,pusertype NUMBER := NULL
	) IS
		vrow trights%ROWTYPE;
	BEGIN
		vrow.branch    := seance.getbranch;
		vrow.userid    := coalesce(puserid, scuruserid);
		vrow.usertype  := coalesce(pusertype, scurusertype);
		vrow.objectid  := pnode.objectid;
		vrow.accesskey := pnode.key;
		IF vrow.accesskey = '|'
		THEN
			vrow.accesskey := cnull;
		END IF;
	
		INSERT INTO trights VALUES vrow;
		logaction(caaddgrants, pnode);
	EXCEPTION
		WHEN dup_val_on_index THEN
			NULL;
		WHEN OTHERS THEN
			error.save(cpackagename || '.grant_(' || pnode.key || ', Obj = ' || pnode.objectid || ')');
			RAISE;
	END;

	PROCEDURE revoke_
	(
		pnode     apitypes.typesecurnode
	   ,puserid   NUMBER := NULL
	   ,pusertype NUMBER := NULL
	) IS
		vrow trights%ROWTYPE;
	BEGIN
		vrow.branch    := seance.getbranch;
		vrow.userid    := coalesce(puserid, scuruserid);
		vrow.usertype  := coalesce(pusertype, scurusertype);
		vrow.objectid  := pnode.objectid;
		vrow.accesskey := pnode.key;
		IF vrow.accesskey = '|'
		THEN
			vrow.accesskey := cnull;
		END IF;
	
		DELETE FROM trights
		WHERE  branch = vrow.branch
		AND    userid = vrow.userid
		AND    usertype = vrow.usertype
		AND    objectid = vrow.objectid
		AND    accesskey = vrow.accesskey;
	
		IF SQL%ROWCOUNT > 0
		THEN
			logaction(cadropgrants, pnode);
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.revoke_(' || pnode.key || ', Obj = ' || pnode.objectid || ')');
			RAISE;
	END;

	PROCEDURE grantaccess_
	(
		pnode     apitypes.typesecurnode
	   ,puserid   NUMBER := NULL
	   ,pusertype NUMBER := NULL
	) IS
		vrow taccessrights%ROWTYPE;
	BEGIN
		vrow.branch   := seance.getbranch;
		vrow.userid   := coalesce(puserid, scuruserid);
		vrow.usertype := coalesce(pusertype, scurusertype);
		vrow.objectid := pnode.objectid;
		IF pnode.subnodes = cnode_leaf
		THEN
			vrow.accesskey := pnode.key;
		ELSE
			vrow.accesskey := pnode.key || '%';
		END IF;
		IF vrow.accesskey = '|'
		THEN
			vrow.accesskey := cnull;
		END IF;
	
		INSERT INTO taccessrights VALUES vrow;
		logaction(caaddaccess, pnode);
	EXCEPTION
		WHEN dup_val_on_index THEN
			NULL;
		WHEN OTHERS THEN
			error.save(cpackagename || '.grantAccess_(' || pnode.key || ', Obj = ' ||
					   pnode.objectid || ')');
			RAISE;
	END;

	PROCEDURE revokeaccess_
	(
		pnode     apitypes.typesecurnode
	   ,puserid   NUMBER := NULL
	   ,pusertype NUMBER := NULL
	) IS
		vrow taccessrights%ROWTYPE;
	BEGIN
		vrow.branch   := seance.getbranch;
		vrow.userid   := coalesce(puserid, scuruserid);
		vrow.usertype := coalesce(pusertype, scurusertype);
		vrow.objectid := pnode.objectid;
		IF pnode.subnodes = cnode_leaf
		THEN
			vrow.accesskey := pnode.key;
		ELSE
			vrow.accesskey := pnode.key || '%';
		END IF;
		IF vrow.accesskey = '|'
		THEN
			vrow.accesskey := cnull;
		END IF;
	
		DELETE FROM taccessrights
		WHERE  branch = vrow.branch
		AND    userid = vrow.userid
		AND    usertype = vrow.usertype
		AND    objectid = vrow.objectid
		AND    accesskey = vrow.accesskey;
	
		IF SQL%ROWCOUNT > 0
		THEN
			logaction(cadropaccess, pnode);
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.revokeAccess_(' || pnode.key || ', Obj = ' ||
					   pnode.objectid || ')');
			RAISE;
	END;

	PROCEDURE savetreenode(pnode apitypes.typesecurnode) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.SaveTreeNode(key : ' || pnode.key || ')';
	BEGIN
		IF cstate_notavail = pnode.state
		THEN
			RETURN;
		END IF;
		IF cnode_undefine = pnode.subnodes
		THEN
			error.raiseerror('Node is undefined: Obj : ' || pnode.objectid || ', Key : ' ||
							 pnode.key);
		END IF;
	
		CASE streemode
			WHEN ctree_access THEN
			
				IF cnode_leaf = pnode.subnodes
				THEN
					CASE pnode.state
						WHEN cstate_check THEN
							grantaccess_(pnode);
						WHEN cstate_uncheck THEN
							revokeaccess_(pnode);
						ELSE
							NULL;
					END CASE;
				ELSE
					IF hasaccessallkey(pnode.objectid, pnode.key)
					THEN
						IF cstate_checkall = pnode.state
						THEN
							grantaccess_(pnode);
						ELSE
							revokeaccess_(pnode);
						END IF;
					END IF;
					FOR i IN pnode.substart .. (pnode.substart + pnode.subnodes - 1)
					LOOP
						savetreenode(satree(i));
					END LOOP;
				END IF;
			
			WHEN ctree_grant THEN
			
				IF cnode_leaf = pnode.subnodes
				THEN
					CASE pnode.state
						WHEN cstate_check THEN
							grant_(pnode);
						WHEN cstate_uncheck THEN
							revoke_(pnode);
						ELSE
							NULL;
					END CASE;
				ELSE
					FOR i IN pnode.substart .. (pnode.substart + pnode.subnodes - 1)
					LOOP
						savetreenode(satree(i));
					END LOOP;
				END IF;
			
			ELSE
				error.raiseerror('Unknown mode of Tree ' || streemode);
		END CASE;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION getleftouterjoin
	(
		plistone IN typeaccesskeymap
	   ,plisttwo IN typeaccesskeymap
	) RETURN typeaccesskeymap IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.GetLeftOuterJoin';
		vidx     idxkeytype;
		vreslist typeaccesskeymap;
	BEGIN
	
		vidx := plistone.first;
		WHILE vidx IS NOT NULL
		LOOP
			IF NOT plisttwo.exists(vidx)
			THEN
				vreslist(vidx) := plistone(vidx);
			END IF;
			vidx := plistone.next(vidx);
		END LOOP;
	
		RETURN vreslist;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE processrightschanges
	(
		ptype    IN NUMBER
	   ,pcurinfo IN typecurinfo
	   ,pdata    IN typeaccesskeymap
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.ProcessRightsChanges';
		vidx idxkeytype;
	BEGIN
		s.say(cwhere || ' | pType = ' || ptype);
	
		IF pdata.count > 0
		THEN
			log_init();
			vidx := pdata.first;
			WHILE vidx IS NOT NULL
			LOOP
				log_add(pdata(vidx).objectid, pdata(vidx).key);
				vidx := pdata.next(vidx);
			END LOOP;
		
			log_write(ptype);
		
			CASE ptype
				WHEN cadropgrants THEN
					removerights(pcurinfo.userid, pcurinfo.usertype, pdata);
				WHEN caaddgrants THEN
					writerights(pcurinfo.userid, pcurinfo.usertype, pdata);
			END CASE;
		
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE savetree IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.SaveTree()';
		i     NUMBER;
		vnode apitypes.typesecurnode;
		vkeys typeaccesskeymap;
		vnew  typeaccesskeymap;
		vdel  typeaccesskeymap;
		vidx  idxkeytype;
	BEGIN
		timer.start_(cwhere);
		IF ctree_access = streemode
		THEN
			IF checkaright_(satree(0).objectid, satree(0).key)
			THEN
				CASE satree(0).state
					WHEN cstate_checkall THEN
						grantaccess_(satree(0));
					WHEN cstate_uncheck THEN
						revokeaccess_(satree(0));
					ELSE
						NULL;
				END CASE;
			END IF;
		END IF;
	
		IF streemode = ctree_grant
		THEN
		
			timer.start_(cwhere || '.read tree');
		
			vkeys.delete;
			i := satree.next(0);
			WHILE i IS NOT NULL
			LOOP
				vnode := satree(i);
				IF vnode.state = cstate_check
				THEN
					vidx := gethashvalue(vnode.objectid, vnode.key);
					IF cnode_leaf = vnode.subnodes
					THEN
						vkeys(vidx).objectid := vnode.objectid;
						vkeys(vidx).key := vnode.key;
					END IF;
				END IF;
				i := satree.next(i);
			END LOOP;
			s.say(cwhere || ' | vKeys.count() = ' || vkeys.count());
		
			timer.stop_(cwhere || '.read tree');
		
			timer.start_(cwhere || '.make del-list');
		
			vdel := getleftouterjoin(scurinfo.oldkeys, vkeys);
			s.say(cwhere || ' | vDel.count() = ' || vdel.count());
			timer.stop_(cwhere || '.make del-list');
		
			processrightschanges(cadropgrants, scurinfo, vdel);
			vdel.delete();
		
			vnew := getleftouterjoin(vkeys, scurinfo.oldkeys);
			s.say(cwhere || ' | vNew.count() = ' || vnew.count());
			timer.stop_(cwhere || '.make add-list');
		
			vkeys.delete();
		
			processrightschanges(caaddgrants, scurinfo, vnew);
			vnew.delete();
		
		END IF;
	
		ssomenodechanged := FALSE;
		timer.stop_(cwhere);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.show;
	END;

	FUNCTION state2bool(pstate IN NUMBER) RETURN BOOLEAN IS
	BEGIN
		RETURN CASE pstate WHEN cstate_check THEN TRUE WHEN cstate_uncheck THEN FALSE WHEN cstate_checkall THEN TRUE ELSE NULL END;
	END;

	PROCEDURE buildbasenode
	(
		pparentnode IN apitypes.typesecurnode
	   ,prights     IN OUT NOCOPY types.utree
	) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.BuildBaseNode[from Tree](lvl ' ||
										 pparentnode.level || ', key ' || pparentnode.key || ')';
		vnode       apitypes.typesecurnode;
		vaqueuelink types.arrnum;
		i           NUMBER;
		i_parent    NUMBER;
		vparentnode apitypes.typesecurnode;
	BEGIN
		s.say(cwhere || ' start...');
		timer.start_(cpackagename || '.BuildBaseNode[from Tree]');
	
		vparentnode := pparentnode;
		i_parent    := utree.getfirst(prights);
	
		LOOP
		
			IF s.isanydebug
			   AND s.isidenable('SYSTEM')
			THEN
				s.say('|= ' || rpad('-', vparentnode.level, '-') || vparentnode.text
					 ,pid => 'SYSTEM');
			END IF;
		
			i := utree.getfirst(prights, i_parent);
			IF i IS NULL
			THEN
				sbasetree(vparentnode.id).subnodes := cnode_leaf;
				sbasetree(pparentnode.id).nullable := FALSE;
			ELSE
				LOOP
					vnode          := NULL;
					vnode.id       := sbasetree.last + 1;
					vnode.parentid := vparentnode.id;
					vnode.level    := vparentnode.level + 1;
					vnode.key      := vparentnode.key || prights(i).data.id || '|';
					vnode.text     := prights(i).data.asstr;
					IF prights(i).ichild IS NULL
					THEN
						vnode.subnodes := cnode_leaf;
						vnode.nullable := TRUE;
					ELSE
						vnode.subnodes := cnode_undefine;
						vnode.nullable := FALSE;
						vaqueuelink(vnode.id) := i;
					END IF;
					--vnode.isfunction := vparentnode.isfunction;
					vnode.state    := cnode_undefine;
					vnode.objectid := vparentnode.objectid;
				
					sbasetree(vnode.id) := vnode;
					putnodetomap(sbasetreemap, vnode);
					sbasetreenames(vnode.id) := getaccesskeydescription(vnode.objectid, vnode.key);
				
					IF sbasetree(vparentnode.id).subnodes = cnode_undefine
					THEN
						sbasetree(vparentnode.id).substart := vnode.id;
						sbasetree(vparentnode.id).subnodes := 1;
					ELSE
						sbasetree(vparentnode.id).subnodes := sbasetree(vparentnode.id).subnodes + 1;
					END IF;
				
					EXIT WHEN utree.islast(prights, i);
					i := prights(i).iright;
				END LOOP;
			END IF;
		
			EXIT WHEN vaqueuelink.next(vparentnode.id) IS NULL;
		
			vparentnode := sbasetree(vaqueuelink.next(vparentnode.id));
			i_parent    := vaqueuelink(vparentnode.id);
		END LOOP;
		timer.stop_(cpackagename || '.BuildBaseNode[from Tree]');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE starttimer(cwhere VARCHAR2) IS
	BEGIN
		timer.start_(cwhere);
	END;

	PROCEDURE stoptimer(cwhere VARCHAR2) IS
		vtime NUMBER;
	BEGIN
		timer.stop_(cwhere);
		vtime := timer.getresult(cwhere).score / 100;
		s.say(cwhere || ' = ' || vtime);
		timer.clear(cwhere);
	END;

	PROCEDURE buildbasenode(pparentnode IN apitypes.typesecurnode) IS
		cwhere   CONSTANT VARCHAR(1000) := cpackagename || '.BuildBaseNode(lvl ' ||
										   pparentnode.level || ', key ' || pparentnode.key || ')';
		clastpos CONSTANT NUMBER := nvl(sbasetree.last, 0);
		vnode apitypes.typesecurnode;
	
		vflaglimitedview BOOLEAN := getflaglimitedview();
		vhash            idxkeytype;
		vaccesskey       typeaccesskey;
	
	BEGIN
		s.say(cwhere || ' start...');
	
		IF s.isanydebug
		   AND s.isidenable('SYSTEM')
		THEN
			s.say('|= ' || rpad('-', pparentnode.level, '-') || pparentnode.text, pid => 'SYSTEM');
		END IF;
	
		suseoldarray := TRUE;
	
		BEGIN
			fillsecurityinfofor(pparentnode);
		EXCEPTION
			WHEN OTHERS THEN
				s.say(cwhere || ' delete Node.Id=' || pparentnode.id || ' pNode.Key=' ||
					  pparentnode.key);
				sbasetree(pparentnode.id).state := cstate_undefined;
				sbasetree(pparentnode.id).nullable := TRUE;
				sbasetree(pparentnode.id).subnodes := cnode_leaf;
				RETURN;
		END;
	
		IF NOT suseoldarray
		THEN
			buildbasenode(pparentnode, slasttree);
			RETURN;
		END IF;
	
		s.say(cwhere || ' sLastSISize=' || slastsisize);
	
		IF (slastsisize IS NULL)
		THEN
		
			sbasetree(pparentnode.id).state := cstate_undefined;
			sbasetree(pparentnode.id).nullable := TRUE;
			sbasetree(pparentnode.id).subnodes := cnode_leaf;
			RETURN;
		END IF;
	
		sbasetree(pparentnode.id).nullable := FALSE;
	
		IF (slastsisize = 0)
		THEN
			sbasetree(pparentnode.id).subnodes := cnode_leaf;
			timer.stop_(cpackagename || '.BuildBaseNode');
			RETURN;
		END IF;
	
		s.say(cwhere || ' cLastPos=' || clastpos);
	
		sbasetree(pparentnode.id).subnodes := slastsisize;
		sbasetree(pparentnode.id).substart := clastpos + 1;
	
		starttimer(cnodecycleid);
	
		BEGIN
			FOR i IN 1 .. slastsisize
			LOOP
			
				dummy          := i;
				vnode          := NULL;
				vnode.id       := clastpos + i;
				vnode.parentid := pparentnode.id;
				vnode.level    := pparentnode.level + 1;
				vnode.key      := pparentnode.key || slastsicode(i) || '|';
				vnode.text     := slastsitext(i);
				vnode.subnodes := cnode_undefine;
				vnode.objectid := pparentnode.objectid;
				vnode.nullable := FALSE;
				--vnode.isfunction := pparentnode.isfunction;
			
				vnode.state := cnode_undefine;
			
				vaccesskey := NULL;
				IF /*vnode.isfunction
                                                                                                                                                                                                   AND*/
				 vflaglimitedview
				THEN
					IF haskeyexactlythis(vnode.key)
					THEN
						vaccesskey.objectid := vnode.objectid;
						vaccesskey.key := vnode.key;
						vhash := gethashvalue(vaccesskey.objectid, vaccesskey.key);
						scurinfo.oldkeys(vhash) := vaccesskey;
					END IF;
				END IF;
			
				IF slastsifin.exists(i)
				   AND slastsifin(i)
				THEN
					vnode.subnodes := cnode_leaf;
				END IF;
			
				sbasetree(vnode.id) := vnode;
				putnodetomap(sbasetreemap, vnode);
				sbasetreenames(vnode.id) := getaccesskeydescription(vnode.objectid, vnode.key);
			
			END LOOP;
		EXCEPTION
			WHEN OTHERS THEN
				htools.message('Cannot add node ~' || slastsitext(dummy)
							  ,'Internal Exception handled');
				RETURN;
		END;
	
		stoptimer(cnodecycleid);
	
		FOR i IN 1 .. slastsisize
		LOOP
			IF cnode_leaf != nvl(sbasetree(clastpos + i).subnodes, cnode_undefine)
			THEN
				buildbasenode(sbasetree(clastpos + i));
			END IF;
		END LOOP;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE buildbasetree IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.BuildBaseTree()';
		vcount NUMBER := 0;
		vnode  apitypes.typesecurnode;
	
		visfunction      BOOLEAN;
		vflaglimitedview BOOLEAN := getflaglimitedview();
	
	BEGIN
		s.say(cwhere || ' start');
		safuncobjects.delete;
	
		timer.start_(cwhere);
		IF sbasetree.count = 0
		   OR vflaglimitedview
		THEN
			sbasetree.delete;
			sbasetreemap.delete;
			sbasetreenames.delete;
		
			FOR i IN (SELECT * FROM taccessobjects t ORDER BY description)
			LOOP
				visfunction := service.existproc(i.packagename
												,'GetSecurityArray'
												,'/in:N/in:V/in:N/in:V/ret:A');
				IF (service.existproc(i.packagename, 'FillSecurityArray', '/in:N/in:V/ret:E') OR
				   visfunction)
				THEN
					vcount         := vcount + 1;
					vnode          := NULL;
					vnode.id       := vcount;
					vnode.parentid := 0;
					vnode.level    := 0;
					vnode.key      := '|';
					vnode.text     := i.description;
					vnode.subnodes := cnode_undefine;
					vnode.state    := cstate_undefined;
					vnode.objectid := i.id;
					--vnode.isfunction := visfunction;
					sbasetree(vcount) := vnode;
					s.say(cwhere || ' sBaseTree.count=' || sbasetree.count);
					putnodetomap(sbasetreemap, vnode);
					sbasetreenames(vnode.id) := getaccesskeydescription(vnode.objectid, vnode.key);
				
					saobjectinfo(vcount).packagename := i.packagename;
					saobjectinfo(vcount).objectid := i.id;
				
					IF vflaglimitedview
					   AND visfunction
					THEN
					
						safuncobjects(safuncobjects.count + 1) := i.id;
					END IF;
				
				END IF;
			END LOOP;
		END IF;
		s.say(cwhere || ' saFuncObjects=' || safuncobjects.count);
		snumobjects := vcount;
		s.say(cwhere || ' sNumObjects=' || snumobjects);
	
		IF vflaglimitedview
		THEN
			scurinfo.oldkeys := readrights(scurinfo.userid, scurinfo.usertype);
		END IF;
	
		dialog.percentbox('INIT', snumobjects, 'Create tree of rights');
	
		FOR i IN 1 .. snumobjects
		LOOP
			dialog.percentbox('SHOW'
							 ,i - 1
							 ,ptext => 'Object "' || getaccessobjectinfo(saobjectinfo(sbasetree(i).id).objectid)
									  .description || '"');
			scurobjectindex := i;
		
			BEGIN
				buildbasenode(sbasetree(i));
			EXCEPTION
				WHEN OTHERS THEN
					s.err(cpackagename || '.BuildTree for PackageName:' || getaccessobjectinfo(saobjectinfo(sbasetree(i).id).objectid)
						  .packagename || chr(10) || ' sqlerrm:' || SQLERRM);
					htools.message('Cannot expand node ~' || sbasetree(i).text
								  ,'Internal Exception handled'
								  ,TRUE);
			END;
		
			dialog.percentbox('SHOW', i);
		
		END LOOP;
	
		dialog.percentbox('DOWN');
	
		timer.stop_(cwhere);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			dialog.percentbox('DOWN');
			timer.stop_(cwhere);
			RAISE;
	END;

	PROCEDURE accesstree_addleafnode(pnode apitypes.typesecurnode) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.AccessTree_AddEndNode(' || pnode.key || ')';
		i NUMBER;
	BEGIN
		IF pnode.subnodes = cnode_leaf
		   AND pnode.state = cstate_notavail
		THEN
			saccesstree(pnode.id).state := cstate_undefined;
			say('activate asccess to [' || pnode.id || '] key ' || pnode.key);
			i := pnode.parentid;
			WHILE i > 0
			LOOP
				IF saccesstree(i).state = cstate_notavail
				THEN
					say('activate asccess to [' || saccesstree(i).id || '] key ' || saccesstree(i).key);
					saccesstree(i).state := cstate_undefined;
					i := saccesstree(i).parentid;
				ELSE
					i := 0;
				END IF;
			END LOOP;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE accesstree_addsubtree(proot apitypes.typesecurnode) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.AccessTree_AddSubTree(' || proot.key || ')';
	BEGIN
		IF proot.subnodes = cnode_leaf
		THEN
			RETURN;
		END IF;
	
		FOR i IN proot.substart .. (proot.substart + proot.subnodes - 1)
		LOOP
			IF saccesstree(i).subnodes = cnode_leaf
			THEN
				accesstree_addleafnode(saccesstree(i));
			ELSE
				accesstree_addsubtree(saccesstree(i));
			END IF;
		END LOOP;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE buildaccesstree IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.BuildAccessTree()';
		vnode            apitypes.typesecurnode;
		vkey             keytype;
		vidx             idxkeytype;
		i                NUMBER;
		vobjectid        NUMBER;
		vflaglimitedview BOOLEAN := getflaglimitedview();
	BEGIN
		s.say(cwhere || ' start');
		timer.start_(cwhere);
		IF sbasetree.count = 0
		   OR vflaglimitedview
		THEN
			buildbasetree;
		END IF;
		saccesstree.delete;
		saccesstree := sbasetree;
	
		say('All rigths is Assessed!');
		FOR i IN 0 .. saccesstree.last
		LOOP
			saccesstree(i).state := cstate_undefined;
		END LOOP;
		timer.stop_(cwhere);
		RETURN;
	
		dialog.percentbox('INIT', saobjectinfo.count, 'Initialize tree of allowed rights');
	
		FOR i IN 0 .. saccesstree.last
		LOOP
			saccesstree(i).state := cstate_notavail;
		END LOOP;
	
		say('sNumObjects = ' || snumobjects);
		FOR i IN 1 .. snumobjects
		LOOP
		
			vobjectid := saccesstree(i).objectid;
			s.say('Detect access for object ' || vobjectid || ', state = ' || saccesstree(i).state);
			FOR c IN (WITH s AS
						   (SELECT seance.getclerkcode AS userid
								 ,security.ot_user    AS usertype
						   FROM   dual
						   UNION ALL
						   SELECT gr.groupid        AS userid
								 ,security.ot_group AS usertype
						   FROM   tclerk2group gr
						   WHERE  gr.branch = seance.getbranch
						   AND    gr.clerkid = seance.getclerkcode)
						  SELECT t.accesskey
						  FROM   taccessrights t
								,s
						  WHERE  t.branch = seance.getbranch
						  AND    t.userid = s.userid
						  AND    t.usertype = s.usertype
						  AND    t.objectid = vobjectid
						  ORDER  BY t.accesskey)
			LOOP
				vnode := NULL;
				say('find key ' || c.accesskey);
			
				IF substr(c.accesskey, -1) = '%'
				THEN
				
					vkey := substr(c.accesskey, 1, length(c.accesskey) - 1);
					IF vkey = '|'
					THEN
						accesstree_addsubtree(saccesstree(i));
					ELSE
						vidx := gethashvalue(vobjectid, vkey);
						IF sbasetreemap.exists(vidx)
						THEN
							vnode := saccesstree(sbasetreemap(vidx).id);
						
							accesstree_addsubtree(vnode);
						END IF;
					END IF;
				ELSE
					IF c.accesskey = cnull
					THEN
						vidx := gethashvalue(vobjectid, '|');
					ELSE
						vidx := gethashvalue(vobjectid, c.accesskey);
					END IF;
				
					IF sbasetreemap.exists(vidx)
					THEN
					
						vnode := saccesstree(sbasetreemap(vidx).id);
						IF vnode.subnodes = cnode_leaf
						THEN
							accesstree_addleafnode(vnode);
						END IF;
					END IF;
				
				END IF;
			
			END LOOP;
		
			dialog.percentbox('SHOW', i);
		
		END LOOP;
		dialog.percentbox('DOWN');
	
		timer.stop_(cwhere);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			dialog.percentbox('SHOW', i);
			RAISE;
	END;

	PROCEDURE fillnodegrant(pnode apitypes.typesecurnode) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.fillNodeGrant()';
	BEGIN
	
		IF cstate_notavail = pnode.state
		THEN
			RETURN;
		END IF;
		IF pnode.subnodes = cnode_leaf
		THEN
			timer.start_(cwhere);
		
			IF scurinfo.oldkeys.exists(gethashvalue(pnode.objectid, pnode.key))
			THEN
				satree(pnode.id).state := cstate_check;
			ELSE
				satree(pnode.id).state := cstate_uncheck;
			END IF;
			timer.stop_(cwhere);
		ELSE
			FOR i IN pnode.substart .. (pnode.substart + pnode.subnodes - 1)
			LOOP
				fillnodegrant(satree(i));
			END LOOP;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere || '(key ' || pnode.key || ')');
			RAISE;
	END;

	PROCEDURE fillnodeaccessgrant(pnode apitypes.typesecurnode) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.fillNodeAccessGrant()';
	BEGIN
		IF cstate_notavail = pnode.state
		THEN
			RETURN;
		END IF;
	
		IF pnode.subnodes = cnode_leaf
		THEN
			IF hasakeyexactlythis(pnode.key)
			THEN
				satree(pnode.id).state := cstate_check;
			ELSE
				satree(pnode.id).state := cstate_uncheck;
			END IF;
		ELSE
			IF hasakeyexactlythis(pnode.key || '%')
			THEN
				satree(pnode.id).state := cstate_checkall;
			END IF;
			FOR i IN pnode.substart .. (pnode.substart + pnode.subnodes - 1)
			LOOP
				fillnodeaccessgrant(satree(i));
			END LOOP;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere || '(key ' || pnode.key || ')');
			RAISE;
	END;

	PROCEDURE fillgranttree IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.FillGrantTree()';
		vflaglimitedview BOOLEAN := getflaglimitedview();
	BEGIN
		s.say(cwhere || ' start');
		timer.start_(cwhere);
		streemode := ctree_grant;
		IF saccesstree.count = 0
		   OR vflaglimitedview
		THEN
			buildaccesstree;
		END IF;
	
		satree := saccesstree;
		dialog.percentbox('INIT', snumobjects, 'Define tree of rights');
	
		FOR i IN 1 .. snumobjects
		LOOP
			scurobjectindex := i;
			dialog.percentbox('SHOW'
							 ,i - 1
							 , 'Rights for object "' || getaccessobjectinfo(saobjectinfo(satree(i).id).objectid)
							  .description || '"');
			say(cwhere || ' for PackageName:' || getaccessobjectinfo(saobjectinfo(satree(i).id).objectid)
				.packagename);
			IF NOT cstate_notavail = satree(i).state
			THEN
			
				fillnodegrant(satree(i));
				IF NOT cnode_leaf = satree(i).subnodes
				THEN
					checkratio(satree(i));
					satree(i).state := getstateaccordingsubnodes(satree(i));
				END IF;
			END IF;
		
			dialog.percentbox('SHOW', i);
		END LOOP;
	
		dialog.percentbox('DOWN');
		timer.stop_(cwhere);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			dialog.percentbox('DOWN');
			RAISE;
	END;

	PROCEDURE fillaccesstree IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.FillAccessTree()';
	BEGIN
		s.say(cwhere || ' start');
		timer.start_(cwhere);
		streemode := ctree_access;
	
		IF saccesstree.count = 0
		THEN
			buildaccesstree;
		END IF;
		satree := saccesstree;
		dialog.percentbox('INIT', snumobjects, 'Define tree of allowed rights');
	
		FOR i IN 1 .. snumobjects
		LOOP
			scurobjectindex := i;
			dialog.percentbox('SHOW'
							 ,i - 1
							 , 'Rights for object "' || getaccessobjectinfo(saobjectinfo(satree(i).id).objectid)
							  .description || '"');
			say(cwhere || ' for PackageName:' || getaccessobjectinfo(saobjectinfo(satree(i).id).objectid)
				.packagename);
			IF saobjectinfo(i).objectid = 0
			THEN
				satree(0).state := cstate_notavail;
				satree(0).subnodes := cnode_leaf;
				satree(0).objectid := 0;
				satree(0).key := '%';
				satree(0).text := 'All rights';
			
				IF checkaright_(satree(0).objectid, satree(0).key)
				THEN
					IF hasakeyexactlythis('%')
					THEN
						satree(0).state := cstate_checkall;
					ELSE
						satree(0).state := cstate_uncheck;
					END IF;
				END IF;
			
			END IF;
		
			IF NOT cstate_notavail = satree(i).state
			THEN
			
				fillnodeaccessgrant(satree(i));
			
				IF NOT cnode_leaf = satree(i).subnodes
				THEN
					checkratio(satree(i));
					IF satree(i).state != cstate_checkall
					THEN
						satree(i).state := getstateaccordingsubnodes(satree(i));
					END IF;
				END IF;
			END IF;
		
			dialog.percentbox('SHOW', i);
		END LOOP;
		dialog.percentbox('DOWN');
		timer.stop_(cwhere);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			dialog.percentbox('DOWN');
			RAISE;
	END;

	PROCEDURE dialogs__________________ IS
	BEGIN
		NULL;
	END;

	FUNCTION grantnodedialog(pnodeid NUMBER) RETURN NUMBER IS
		vdlg      NUMBER;
		cdw       NUMBER := 80;
		cdh       NUMBER := 22;
		vcaption  VARCHAR(1000);
		vmenu     NUMBER;
		vopermenu NUMBER;
		cbw CONSTANT NUMBER := 11;
		vnode apitypes.typesecurnode := NULL;
		vi    NUMBER;
		cevent CONSTANT VARCHAR(1000) := cpackagename || '.GrantNodeDialogHandler';
	BEGIN
		IF pnodeid IS NOT NULL
		THEN
			vnode    := satree(pnodeid);
			cdw      := cdw - (vnode.level) * 2;
			cdh      := cdh - (vnode.level);
			vcaption := vnode.text || ' ("' || scurinfo.username || '")';
		ELSE
			vcaption := 'Objects for "' || scurinfo.username || '"';
		END IF;
		IF isfullview
		THEN
			vcaption := vcaption || ' (view mode)';
		END IF;
	
		vdlg := dialog.new(vcaption
						  ,0
						  ,0
						  ,cdw
						  ,cdh
						  ,presizable => TRUE
						  ,pextid     => cpackagename || '.GrantNodeDialog');
		dialog.setdialogpre(vdlg, cevent);
		dialog.setdialogvalid(vdlg, cevent);
		dialog.setdialogpost(vdlg, cevent);
		dialog.hiddennumber(vdlg, 'eNodeId', pnodeid);
	
		vi := 1;
	
		dialog.checkbox(vdlg
					   ,'chNodes'
					   ,2
					   ,vi
					   ,cdw - 5
					   ,cdh - vi - 3
					   ,''
					   ,panchor => dialog.anchor_all
					   ,pusebottompanel => TRUE);
		dialog.listaddfield(vdlg, 'chNodes', 'ID', 'N', 0, 0);
		dialog.listaddfield(vdlg, 'chNodes', 'Key', 'C', 0, 0);
		dialog.listaddfield(vdlg, 'chNodes', 'Name', 'C', cdw - 5, 1);
		dialog.setitempre(vdlg, 'chNodes', cevent);
		dialog.setitemmark(vdlg, 'chNodes', cevent, peverypos => TRUE);
		dialog.setreadonly(vdlg, 'chNodes', isfullview);
	
		vmenu     := dialog.menu(vdlg);
		vopermenu := dialog.submenu(vmenu, 'Operations', '');
		dialog.menuitem(vopermenu
					   ,'SELECT_ALL'
					   ,'Assign all rights'
					   ,0
					   ,0
					   ,'Assign all rights included in current level and its sublevels'
					   ,phandler => cevent);
		dialog.menuitem(vopermenu
					   ,'CLEAR_ALL'
					   ,'Remove all rights'
					   ,0
					   ,0
					   ,'Remove all rights included in current level and its sublevels'
					   ,phandler => cevent);
		IF isfullview
		THEN
			dialog.setenable(vdlg, 'SELECT_ALL', FALSE);
			dialog.setenable(vdlg, 'CLEAR_ALL', FALSE);
		END IF;
	
		dialog.menuitem(vmenu
					   ,'SearchRight'
					   ,'Search for rights'
					   ,0
					   ,0
					   ,'Search for rights by name'
					   ,phandler => cevent);
	
		dummy := dialog.makemenusearch(vmenu, 'chNodes', NULL, FALSE);
	
		IF (pnodeid IS NULL)
		THEN
			dialog.button(vdlg
						 ,'btnSave'
						 ,cdw / 2 - 1 - cbw
						 ,cdh - 1
						 ,cbw
						 ,'Enter'
						 ,dialog.cmok
						 ,0
						 ,'Save changes'
						 ,panchor => dialog.anchor_bottom);
			dialog.setdefault(vdlg, 'btnSave');
			dialog.setenable(vdlg, 'btnSave', NOT isfullview);
			dialog.button(vdlg
						 ,'btnCancel'
						 ,cdw / 2 + 1
						 ,cdh - 1
						 ,cbw
						 ,'Cancel'
						 ,dialog.cmcancel
						 ,0
						 ,'Exit without saving'
						 ,panchor => dialog.anchor_bottom
						 ,phandler => cevent);
		ELSE
			dialog.button(vdlg
						 ,'btnCancel'
						 ,cdw / 2 - cbw / 2
						 ,cdh - 1
						 ,cbw
						 ,'Exit'
						 ,dialog.cmok
						 ,0
						 ,'Return to previous level'
						 ,panchor => dialog.anchor_bottom);
		END IF;
	
		RETURN vdlg;
	END;

	PROCEDURE showgrantnode(pnodeid NUMBER) IS
	BEGIN
		dialog.exec(grantnodedialog(pnodeid));
	END;

	PROCEDURE fillcheckboxeslist
	(
		pdialog IN NUMBER
	   ,pnode   apitypes.typesecurnode
	) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.FillCheckBoxesList(' || pdialog ||
										 ', nodeid = ' || pnode.id || ')';
		vmark       VARCHAR(32767) := '';
		vcount      NUMBER;
		vcond_name  VARCHAR(32767) := '%';
		vcond_state NUMBER;
		FUNCTION check_(i NUMBER) RETURN BOOLEAN IS
		BEGIN
			IF satree(i).text NOT LIKE vcond_name
			THEN
				RETURN FALSE;
			END IF;
			CASE vcond_state
				WHEN 2 THEN
					IF satree(i).state = cstate_uncheck
					THEN
						RETURN FALSE;
					END IF;
				WHEN 3 THEN
					IF satree(i).state != cstate_uncheck
					THEN
						RETURN FALSE;
					END IF;
				ELSE
					NULL;
			END CASE;
			RETURN TRUE;
		END;
	BEGIN
		s.say(cwhere || ': strart');
		dialog.listclear(pdialog, 'chNodes');
	
		vcond_state := dialog.getcurrec(pdialog, 'Check');
		IF pnode.id IS NULL
		THEN
			FOR i IN 1 .. snumobjects
			LOOP
				s.say('add object ' || satree(i).objectid || ' root saTree(' || i || ').Key ' || satree(i).key ||
					  ' state = ' || satree(i).state);
				IF satree(i).state NOT IN (cstate_notavail, cstate_undefined)
				THEN
				
					dialog.listaddrecord(pdialog
										,'chNodes'
										,i || '~' || satree(i).key || '~' ||
										 getsubnodedtext(satree(i).text, getsubnodecount(i)) || '~');
					vmark := vmark || getcharmark(satree(i).state);
				
				END IF;
			END LOOP;
			dialog.putchar(pdialog, 'chNodes', vmark);
			IF streemode = ctree_access
			THEN
				dialog.setaddinfo(pdialog, 'chAll', 0);
				IF satree(0).state = cstate_checkall
				THEN
					dialog.putbool(pdialog, 'chAll', TRUE);
				END IF;
			END IF;
		
		ELSE
			IF ctree_access = streemode
			THEN
				dialog.setaddinfo(pdialog, 'chAll', pnode.id);
				IF pnode.state = cstate_checkall
				THEN
					dialog.putbool(pdialog, 'chAll', TRUE);
				END IF;
			END IF;
			vcount := 0;
			FOR j IN pnode.substart .. (pnode.substart + pnode.subnodes - 1)
			LOOP
				IF vcount > cmax_view_rows
				THEN
					htools.message('Warning!'
								  ,' Too many records to be displayed.~Only first ' ||
								   cmax_view_rows ||
								   ' records are displayed.~Use search option to find rights');
					EXIT;
				END IF;
			
				IF satree(j).state NOT IN (cstate_notavail, cstate_undefined)
				THEN
				
					vcount := vcount + 1;
					dialog.listaddrecord(pdialog
										,'chNodes'
										,satree(j)
										 .id || '~' || satree(j).key || '~' ||
										  getsubnodedtext(satree(j).text, getsubnodecount(j)) || '~');
					vmark := vmark || getcharmark(satree(j).state);
				
				END IF;
			END LOOP;
			dialog.putchar(pdialog, 'chNodes', vmark);
		END IF;
	END;

	PROCEDURE grantnodedialoghandler
	(
		pwhat   CHAR
	   ,pdialog NUMBER
	   ,pitem   VARCHAR
	   ,pcmd    NUMBER
	) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.GrantNodeDialogHandler(what:' || pwhat ||
										 ', dlg:' || pdialog || ', item:' || pitem || ', cmd:' || pcmd || ')';
		vpos  NUMBER := 0;
		vid   NUMBER;
		vnode apitypes.typesecurnode;
	
		PROCEDURE changestate_
		(
			ppos   NUMBER
		   ,pstate NUMBER := NULL
		) IS
			vchangedid NUMBER;
			vstate     typenodestate := pstate;
		BEGIN
			vchangedid := dialog.getrecordnumber(pdialog, 'chNodes', 'ID', ppos);
		
			IF vstate IS NULL
			THEN
				IF dialog.getbool(pdialog, 'chNodes', ppos)
				THEN
					vstate := cstate_check;
				ELSE
					vstate := cstate_uncheck;
				END IF;
			END IF;
			setsubnodesstate(satree(vchangedid), vstate);
			ssomenodechanged := TRUE;
		END;
	
	BEGIN
		s.say(cwhere || ': start');
		vnode.id := dialog.getnumber(pdialog, 'eNodeId');
		IF vnode.id IS NOT NULL
		THEN
			vnode := satree(vnode.id);
		END IF;
		CASE pwhat
			WHEN dialog.wtdialogpre THEN
			
				fillcheckboxeslist(pdialog, vnode);
				dialog.goitem(pdialog, 'chNodes');
			
			WHEN dialog.wtdialogvalid THEN
				IF (pitem = upper('btnSave'))
				THEN
				
					savetree;
					COMMIT;
				END IF;
			
			WHEN dialog.wtitempost THEN
				IF (pitem = upper('btnCancel'))
				   AND (checkright(right_modify))
				THEN
					IF (vnode.id IS NULL AND ssomenodechanged)
					THEN
						CASE dialog.exec(service.dialogconfirm3('Confirmation'
														   ,'Warning!~Changes not saved.~Save ?~'
														   ,'     Yes    '
														   ,''
														   ,'     No     '
														   ,''
														   ,'  Continue   '
														   ,'Continue edit'))
							WHEN dialog.cmok THEN
								savetree();
								COMMIT;
							WHEN dialog.cmcancel THEN
								dialog.cancelclose(pdialog);
							ELSE
								satree           := saprevtree;
								ssomenodechanged := FALSE;
						END CASE;
					END IF;
				END IF;
			
			WHEN dialog.wtitempre THEN
			
				IF (pitem = upper('chNodes'))
				THEN
				
					vpos := dialog.getcurrec(pdialog, 'chNodes');
					vid  := dialog.getcurrentrecordnumber(pdialog, 'chNodes', 'ID');
				
					IF (NOT cnode_leaf = satree(vid).subnodes)
					THEN
						showgrantnode(vid);
						checkratio(satree(vid));
						satree(vid).state := getstateaccordingsubnodes(satree(vid));
						dialog.putbool(pdialog, 'chNodes', state2bool(satree(vid).state), vpos);
					END IF;
				
				ELSIF (pitem = 'SELECT_ALL')
				THEN
				
					FOR i IN 1 .. dialog.getlistreccount(pdialog, 'chNodes')
					LOOP
						changestate_(i, cstate_check);
						dialog.putbool(pdialog, 'chNodes', state2bool(cstate_check), i);
					END LOOP;
				
				ELSIF (pitem = 'CLEAR_ALL')
				THEN
				
					FOR i IN 1 .. dialog.getlistreccount(pdialog, 'chNodes')
					LOOP
						changestate_(i, cstate_uncheck);
						dialog.putbool(pdialog, 'chNodes', state2bool(cstate_uncheck), i);
					END LOOP;
				
				ELSIF (pitem = upper('SearchRight'))
				THEN
					showsearchright(vnode.id);
					FOR i IN 1 .. dialog.getlistreccount(pdialog, 'chNodes')
					LOOP
						vid := dialog.getrecordnumber(pdialog, 'chNodes', 'ID', i);
						checkratio(satree(vid));
						dialog.putbool(pdialog, 'chNodes', state2bool(satree(vid).state), i);
					
					END LOOP;
				
				END IF;
			
			WHEN dialog.wtitemmark THEN
				IF (pitem = upper('chNodes'))
				THEN
					changestate_(dialog.getcurrec(pdialog, 'chNodes'));
				END IF;
			ELSE
				NULL;
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.showerror('Error');
			dialog.cancelclose(pdialog);
	END;

	FUNCTION dialogsearchright(pcurrentnodeid NUMBER := NULL) RETURN NUMBER IS
		vdlg NUMBER;
		cdw        CONSTANT NUMBER := 80;
		cdh        CONSTANT NUMBER := 20;
		cbw        CONSTANT NUMBER := 11;
		cevent     CONSTANT VARCHAR(100) := cpackagename || '.DialogSearchRightHandler';
		ceventfunc CONSTANT VARCHAR(100) := cpackagename || '.DialogSearchRightFuncHandler';
		vevent      VARCHAR(100) := cevent;
		visfunction BOOLEAN := FALSE;
		vi          NUMBER;
		vmenu       NUMBER;
	
	BEGIN
	
		IF pcurrentnodeid IS NOT NULL
		THEN
			--IF satree(pcurrentnodeid).isfunction
			--    THEN
			vevent      := ceventfunc;
			visfunction := TRUE;
			--END IF;
		END IF;
	
		vdlg := dialog.new('Search for rights by name'
						  ,0
						  ,0
						  ,cdw
						  ,cdh
						  ,presizable                 => TRUE
						  ,pextid                     => 'DialogSearchRight');
		dialog.setdialogpre(vdlg, vevent);
		dialog.hiddennumber(vdlg, 'eNodeId', pcurrentnodeid);
		dialog.hiddenbool(vdlg, 'hNeedMorePart', TRUE);
		IF pcurrentnodeid IS NOT NULL
		THEN
			dialog.setcaption(vdlg
							 ,'Search for rights by name in ' ||
							  getaccesskeydescription(satree     (pcurrentnodeid).objectid
													 ,satree     (pcurrentnodeid).key
													 ,pwithobject => TRUE));
		END IF;
	
		vi := 1;
		dialog.bevel(vdlg
					,1
					,vi
					,cdw - 1
					,3
					,pshape => dialog.bevel_frame
					,pcaption => 'Search conditions'
					,panchor => dialog.anchor_all - dialog.anchor_bottom);
		vi := vi + 1;
		dialog.inputchar(vdlg
						,'Name'
						,20
						,vi
						,30
						,phint    => 'Specify name of right or its part (in Oracle like notation, for example "%123789%")'
						,pcaption => '         Name:');
		dialog.inputcheck(vdlg
						 ,'Strong'
						 ,20 + 30 + 2
						 ,vi
						 ,10
						 ,phint => 'Keep strict compliance with search mask'
						 ,pcaption => 'Strict');
		dialog.inputchar(vdlg, 'Check', 20, vi + 1, 18, 'State of right', pcaption => '    State:');
		dialog.setreadonly(vdlg, 'Check');
		dialog.listaddrecord(vdlg, 'Check', 'All');
		dialog.listaddrecord(vdlg, 'Check', 'Assigned');
		dialog.listaddrecord(vdlg, 'Check', 'Not assigned');
		dialog.setcurrec(vdlg, 'Check', 1);
	
		dialog.button(vdlg
					 ,'Find'
					 ,cdw - cbw - 2
					 ,2
					 ,cbw
					 ,'Apply'
					 ,0
					 ,0
					 ,'Apply current search conditions'
					 ,phandler => vevent
					 ,panchor => dialog.anchor_right + dialog.anchor_top);
		dialog.setdefault(vdlg, 'Find');
		dialog.button(vdlg
					 ,'Next'
					 ,cdw - cbw - 2
					 ,2
					 ,cbw
					 ,'Next'
					 ,0
					 ,0
					 ,'View next records found'
					 ,phandler => vevent
					 ,panchor => dialog.anchor_right + dialog.anchor_top);
		dialog.setvisible(vdlg, 'Next', FALSE);
		vi := vi + 1;
		dialog.button(vdlg
					 ,'Clear'
					 ,cdw - 2 - cbw
					 ,vi
					 ,cbw
					 ,'Clear'
					 ,phint => 'Clear search conditions to display all records'
					 ,phandler => vevent
					 ,panchor => dialog.anchor_right + dialog.anchor_top);
		vi := vi + 1;
		dialog.checkbox(vdlg
					   ,'chNodes'
					   ,2
					   ,vi
					   ,cdw - 5
					   ,cdh - vi - 3
					   ,''
					   ,panchor => dialog.anchor_all
					   ,pusebottompanel => TRUE);
		dialog.listaddfield(vdlg, 'chNodes', 'ID', 'N', 0, 0);
		dialog.listaddfield(vdlg, 'chNodes', 'Key', 'C', 0, 0);
		dialog.listaddfield(vdlg, 'chNodes', 'Name', 'C', cdw - 3, 1);
	
		dialog.setitemmark(vdlg, 'chNodes', vevent, peverypos => TRUE);
		dialog.setreadonly(vdlg, 'chNodes', isfullview);
	
		vmenu := dialog.menu(vdlg);
		dummy := dialog.makemenusearch(vmenu, 'chNodes', NULL, FALSE);
	
		dialog.button(vdlg
					 ,'btnCancel'
					 ,cdw / 2 - cbw / 2
					 ,cdh - 1
					 ,cbw
					 ,'Close'
					 ,dialog.cmok
					 ,0
					 ,'Close dialog box'
					 ,panchor => dialog.anchor_bottom);
	
		RETURN vdlg;
	
	END;

	PROCEDURE dialogsearchrighthandler
	(
		pwhat   CHAR
	   ,pdialog NUMBER
	   ,pitem   VARCHAR
	   ,pcmd    NUMBER
	) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.DialogSearchRightHandler(what:' || pwhat ||
										 ', dlg:' || pdialog || ', item:' || pitem || ', cmd:' || pcmd || ')';
		vnode apitypes.typesecurnode;
	
		PROCEDURE find_ IS
			vcount NUMBER := 0;
			i      NUMBER;
			vmark  VARCHAR(32767);
			vmax_view_rows CONSTANT NUMBER := 1000;
			vcond_name   VARCHAR(32767) := '%';
			vcond_state  NUMBER;
			vcond_strong BOOLEAN := FALSE;
			vstart       VARCHAR(32767) := NULL;
		
			FUNCTION check__(i NUMBER) RETURN BOOLEAN IS
			BEGIN
				IF i <= 0
				THEN
					RETURN FALSE;
				END IF;
				IF cnode_leaf != satree(i).subnodes
				THEN
					RETURN FALSE;
				END IF;
				IF vcond_strong
				THEN
					IF sbasetreenames(i) NOT LIKE vcond_name
					THEN
						RETURN FALSE;
					END IF;
				ELSE
					IF lower(sbasetreenames(i)) NOT LIKE vcond_name
					THEN
						RETURN FALSE;
					END IF;
				END IF;
				CASE vcond_state
					WHEN 2 THEN
						IF satree(i).state = cstate_uncheck
						THEN
							RETURN FALSE;
						END IF;
					WHEN 3 THEN
						IF satree(i).state != cstate_uncheck
						THEN
							RETURN FALSE;
						END IF;
					ELSE
						NULL;
				END CASE;
				RETURN TRUE;
			EXCEPTION
				WHEN OTHERS THEN
					error.save(cwhere || '.check__(i = ' || i || ')');
					s.say('saTree[' || i || '].text = ' || satree(i).text);
					error.clear;
					RETURN NULL;
			END;
		
		BEGIN
		
			vstart := dialog.getaddinfo(pdialog, 'Next');
			s.say(cpackagename || '.SearchRight.find_: Start with ' || vstart);
			vcond_name   := dialog.getchar(pdialog, 'Name');
			vcond_strong := dialog.getbool(pdialog, 'Strong');
			IF NOT vcond_strong
			THEN
				vcond_name := '%' || vcond_name || '%';
				vcond_name := REPLACE(vcond_name, '%%', '%');
			END IF;
			vnode.id := dialog.getnumber(pdialog, 'eNodeId');
			IF vnode.id IS NOT NULL
			THEN
				vnode      := satree(vnode.id);
				vcond_name := getaccesskeydescription(vnode.objectid
													 ,vnode.key
													 ,pwithobject => TRUE) || vcond_name;
			END IF;
			IF NOT vcond_strong
			THEN
				vcond_name := lower(vcond_name);
			END IF;
			vcond_state := dialog.getcurrec(pdialog, 'Check');
			s.say(cpackagename || '.SearchRight.find_: Search condition: ' || vcond_name);
		
			dialog.listclear(pdialog, 'chNodes');
		
			i := nvl(to_number(vstart), nvl(vnode.id, satree.first));
		
			WHILE i IS NOT NULL
			LOOP
				IF vcount >= vmax_view_rows
				THEN
					htools.message('Warning!'
								  ,' Too many records to be displayed.~Only first ' ||
								   vmax_view_rows ||
								   ' records are displayed.~To view next records, click Next button.');
					dialog.setaddinfo(pdialog, 'Next', i);
					dialog.setvisible(pdialog, 'Next', TRUE);
					dialog.setvisible(pdialog, 'Find', FALSE);
					dialog.goitem(pdialog, 'Find');
					EXIT;
				END IF;
				IF check__(i)
				THEN
					vcount := vcount + 1;
					dialog.listaddrecord(pdialog
										,'chNodes'
										,satree(i)
										 .id || '~' || satree(i).key || '~' || sbasetreenames(i) || '~');
					vmark := vmark || getcharmark(satree(i).state);
				END IF;
				i := satree.next(i);
			END LOOP;
			dialog.putchar(pdialog, 'chNodes', vmark);
		
			IF vstart IS NOT NULL
			   AND vcount < vmax_view_rows
			THEN
				dialog.setaddinfo(pdialog, 'Next', NULL);
				dialog.setvisible(pdialog, 'Find', TRUE);
				dialog.setvisible(pdialog, 'Next', FALSE);
			END IF;
		
		END;
	
		PROCEDURE findnew_ IS
		BEGIN
			dialog.setaddinfo(pdialog, 'Next', NULL);
			dialog.setvisible(pdialog, 'Next', FALSE);
			dialog.setvisible(pdialog, 'Find', TRUE);
			find_;
		END;
	
		PROCEDURE changestate_
		(
			ppos   NUMBER
		   ,pstate NUMBER := NULL
		) IS
			vchangedid NUMBER;
			vstate     typenodestate := pstate;
		BEGIN
			vchangedid := dialog.getrecordnumber(pdialog, 'chNodes', 'ID', ppos);
		
			IF vstate IS NULL
			THEN
				IF dialog.getbool(pdialog, 'chNodes', ppos)
				THEN
					vstate := cstate_check;
				ELSE
					vstate := cstate_uncheck;
				END IF;
			END IF;
			setsubnodesstate(satree(vchangedid), vstate);
			ssomenodechanged := TRUE;
		END;
	
	BEGIN
		s.say(cwhere || ': start');
		CASE pwhat
			WHEN dialog.wtdialogpre THEN
				dialog.goitem(pdialog, 'Name');
			WHEN dialog.wtitempre THEN
				IF (pitem = 'FIND')
				THEN
					findnew_();
				ELSIF (pitem = 'NEXT')
				THEN
					find_();
				
				ELSIF (pitem = 'CLEAR')
				THEN
					IF dialog.getaddinfo(pdialog, 'Next') IS NULL
					THEN
						dialog.putchar(pdialog, 'Name', NULL);
						dialog.setcurrec(pdialog, 'Check', 1);
						dialog.listclear(pdialog, 'chNodes');
					ELSE
						dialog.setvisible(pdialog, 'Find', TRUE);
						dialog.setvisible(pdialog, 'Next', FALSE);
						dialog.setaddinfo(pdialog, 'Next', NULL);
					END IF;
				END IF;
			
			WHEN dialog.wtitemmark THEN
				IF (pitem = upper('chNodes'))
				THEN
					changestate_(dialog.getcurrec(pdialog, 'chNodes'));
				END IF;
			ELSE
				NULL;
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.showerror('Error');
			dialog.cancelclose(pdialog);
	END;

	PROCEDURE showsearchright(pnodeid NUMBER) IS
	BEGIN
		dialog.exec(dialogsearchright(pnodeid));
	END;

	PROCEDURE dialogsearchrightfunchandler
	(
		pwhat   CHAR
	   ,pdialog NUMBER
	   ,pitem   VARCHAR
	   ,pcmd    NUMBER
	) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.DialogSearchRightFuncHandler';
		vnode          apitypes.typesecurnode;
		vcond_name     VARCHAR(32767);
		vcond_name_    VARCHAR(32767);
		vcond_fullname VARCHAR(32767);
		vmax_view_rows CONSTANT NUMBER := 1000;
		vcond_state   NUMBER;
		vcond_strong  BOOLEAN := FALSE;
		vstart        VARCHAR(32767) := NULL;
		vneedmorepart BOOLEAN := FALSE;
	
		PROCEDURE clearcursors_ IS
			cwhere_ CONSTANT VARCHAR2(100) := cwhere || '.clearCursors_';
		BEGIN
			EXECUTE IMMEDIATE 'begin ' || saobjectinfo(scurobjectindex).packagename ||
							  '.CloseSecurityCursors(); end;';
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cwhere_);
				RAISE;
		END;
	
		PROCEDURE find_ IS
			vcount      NUMBER := 0;
			i           NUMBER;
			vmark       VARCHAR(32767);
			vsearchnode apitypes.typesecurnode;
		
			FUNCTION check__(i NUMBER) RETURN BOOLEAN IS
			BEGIN
				s.say(cwhere || '.check__: Search i: ' || i);
			
				IF i <= 0
				THEN
					RETURN FALSE;
				END IF;
				IF cnode_leaf != ssearchbasetree(i).subnodes
				THEN
					RETURN FALSE;
				END IF;
			
				IF vcond_name IS NULL
				   AND NOT vcond_strong
				THEN
					vcond_name_ := '%';
				ELSE
					vcond_name_ := vcond_name;
				END IF;
			
				vcond_fullname := vcond_name_;
			
				IF NOT vcond_strong
				THEN
					vcond_fullname := getaccesskeydescription(vnode.objectid
															 ,vnode.key
															 ,pwithobject    => TRUE
															 ,pissearch      => TRUE) ||
									  vcond_fullname;
					vcond_fullname := lower(vcond_fullname);
				ELSE
					vcond_fullname := getaccesskeydescription(vnode.objectid
															 ,vnode.key
															 ,pwithobject    => TRUE
															 ,pissearch      => TRUE) || '%' ||
									  vcond_fullname || '%';
				END IF;
			
				s.say(cwhere || '.check__ vCond_FullName=' || vcond_fullname);
				s.say(cwhere || '.check__ sSearchBaseTreeNames(' || i || ')=' ||
					  ssearchbasetreenames(i));
			
				IF vcond_strong
				THEN
					IF ssearchbasetreenames(i) NOT LIKE vcond_fullname
					THEN
						RETURN FALSE;
					END IF;
				ELSE
					IF lower(ssearchbasetreenames(i)) NOT LIKE vcond_fullname
					THEN
						RETURN FALSE;
					END IF;
				END IF;
				s.say(cwhere || '.check__ condName - true');
			
				CASE vcond_state
					WHEN 2 THEN
						IF ssearchbasetree(i).state = cstate_uncheck
						THEN
							RETURN FALSE;
						END IF;
					WHEN 3 THEN
						IF ssearchbasetree(i).state != cstate_uncheck
						THEN
							RETURN FALSE;
						END IF;
					ELSE
						NULL;
				END CASE;
				RETURN TRUE;
			EXCEPTION
				WHEN OTHERS THEN
					error.save(cwhere || '.check__(i = ' || i || ')');
					s.say('sSearchBaseTree[' || i || '].text = ' || ssearchbasetree(i).text);
					error.clear;
					RETURN NULL;
			END;
		
		BEGIN
		
			vnode.id      := dialog.getnumber(pdialog, 'eNodeId');
			vcond_name    := dialog.getchar(pdialog, 'Name');
			vcond_strong  := dialog.getbool(pdialog, 'Strong');
			vcond_state   := dialog.getcurrec(pdialog, 'Check');
			vstart        := dialog.getaddinfo(pdialog, 'Next');
			vneedmorepart := dialog.getbool(pdialog, 'hNeedMorePart');
		
			IF NOT vcond_strong
			   AND vcond_name IS NOT NULL
			THEN
				vcond_name := '%' || vcond_name || '%';
				vcond_name := REPLACE(vcond_name, '%%', '%');
				vcond_name := lower(vcond_name);
			END IF;
		
			s.say(cwhere || '.find_: Start with ' || vstart);
			s.say(cwhere || '.find_: Search condition: ' || vcond_name);
		
			dialog.listclear(pdialog, 'chNodes');
		
			vnode := ssearchbasetree(vnode.id);
			IF ssearchnotendbranch.count > 0
			THEN
				vsearchnode := ssearchnotendbranch(ssearchnotendbranch.last);
			ELSE
				vsearchnode := vnode;
			END IF;
		
			IF vneedmorepart
			THEN
				buildsearchbasenode(vsearchnode, vcond_name);
			END IF;
		
			IF vstart IS NOT NULL
			THEN
				i := ssearchbasetree.next(vstart);
			ELSE
				i := ssearchbasetree.first;
			END IF;
			s.say(cwhere || ' start with i=' || i);
		
			WHILE i IS NOT NULL
			LOOP
				s.say(cwhere || 'while for sSearchBaseTree i=' || i);
				vneedmorepart := TRUE;
			
				IF check__(i)
				THEN
					vcount := vcount + 1;
					dialog.listaddrecord(pdialog
										,'chNodes'
										,ssearchbasetree(i).id || '~' || ssearchbasetree(i).key || '~' ||
										  ssearchbasetreenames(i) || '~');
					vmark := vmark || getcharmark(ssearchbasetree(i).state);
				ELSE
					s.say(cwhere || ' check - false');
				END IF;
				dialog.setaddinfo(pdialog, 'Next', i);
			
				IF (vcount >= vmax_view_rows)
				THEN
					vneedmorepart := FALSE;
					EXIT;
				END IF;
			
				i := ssearchbasetree.next(i);
			END LOOP;
		
			dialog.putchar(pdialog, 'chNodes', vmark);
			dialog.putbool(pdialog, 'hNeedMorePart', vneedmorepart);
		
			IF NOT vneedmorepart
			   OR ssearchnotendbranch.count > 0
			THEN
				htools.message('Warning!'
							  ,'Shown ' || vcount ||
							   ' records of those found.~To view next records click Next');
				dialog.setvisible(pdialog, 'Next', TRUE);
				dialog.setvisible(pdialog, 'Find', FALSE);
				dialog.goitem(pdialog, 'Find');
			ELSE
				htools.message('Warning!', 'Shown all records satisfying search conditions');
				dialog.setaddinfo(pdialog, 'Next', NULL);
				dialog.setvisible(pdialog, 'Find', TRUE);
				dialog.setvisible(pdialog, 'Next', FALSE);
			END IF;
		
		END;
	
		PROCEDURE findnew_ IS
			vparentnode apitypes.typesecurnode;
		BEGIN
			s.say(cwhere || '.findnew_ sCurUserId=' || scuruserid || ' sCurUserType=' ||
				  scurusertype);
		
			sasearchtree.delete;
			ssearchbasetree.delete;
			ssearchbasetreemap.delete;
			ssearchbasetreenames.delete;
			ssearchnotendbranch.delete;
			dialog.putbool(pdialog, 'hNeedMorePart', TRUE);
		
			vnode.id := dialog.getnumber(pdialog, 'eNodeId');
		
			IF vnode.id IS NOT NULL
			THEN
				vnode           := satree(vnode.id);
				scurobjectindex := vnode.id;
				vparentnode     := vnode;
				LOOP
					s.say(cwhere || '.findnew__ vParentNode.id=' || vparentnode.id);
					scurobjectindex := vparentnode.id;
				
					sasearchtree(vparentnode.id) := satree(vparentnode.id);
					ssearchbasetree(vparentnode.id) := sbasetree(vparentnode.id);
					putnodetomap(ssearchbasetreemap, vparentnode);
					ssearchbasetreenames(vparentnode.id) := sbasetreenames(vparentnode.id);
				
					vparentnode := satree(vparentnode.parentid);
					IF (nvl(vparentnode.id, -1) <= 0)
					THEN
						EXIT;
					END IF;
				END LOOP;
			END IF;
		
			clearcursors_;
			s.say(cwhere || ' sCurObjectIndex=' || scurobjectindex);
		
			dialog.setaddinfo(pdialog, 'Next', NULL);
			dialog.setvisible(pdialog, 'Next', FALSE);
			dialog.setvisible(pdialog, 'Find', TRUE);
			find_;
		END;
	
		PROCEDURE changestate_
		(
			ppos   NUMBER
		   ,pstate NUMBER := NULL
		) IS
			vchangedid NUMBER;
			vstate     typenodestate := pstate;
		BEGIN
			vchangedid := dialog.getrecordnumber(pdialog, 'chNodes', 'ID', ppos);
		
			IF dialog.getbool(pdialog, 'chNodes', ppos)
			THEN
			
				grant_(ssearchbasetree(vchangedid));
			ELSE
			
				revoke_(ssearchbasetree(vchangedid));
			END IF;
		
			ssomenodechanged := TRUE;
		END;
	
	BEGIN
		s.say(cwhere || ': start (what:' || pwhat || ', dlg:' || pdialog || ', item:' || pitem ||
			  ', cmd:' || pcmd || ')');
	
		CASE pwhat
			WHEN dialog.wtdialogpre THEN
			
				dialog.goitem(pdialog, 'Name');
			
			WHEN dialog.wtitempre THEN
				IF (pitem = 'FIND')
				THEN
					findnew_();
				ELSIF (pitem = 'NEXT')
				THEN
					find_();
				
				ELSIF (pitem = 'CLEAR')
				THEN
				
					clearcursors_;
				
					dialog.putchar(pdialog, 'Name', NULL);
					dialog.setcurrec(pdialog, 'Check', 1);
					dialog.listclear(pdialog, 'chNodes');
					dialog.setvisible(pdialog, 'Find', TRUE);
					dialog.setvisible(pdialog, 'Next', FALSE);
					dialog.setaddinfo(pdialog, 'Next', NULL);
				END IF;
			
			WHEN dialog.wtitemmark THEN
				IF (pitem = upper('chNodes'))
				THEN
					changestate_(dialog.getcurrec(pdialog, 'chNodes'));
				END IF;
			ELSE
				NULL;
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.showerror('Error');
			dialog.cancelclose(pdialog);
	END;

	PROCEDURE buildsearchbasenode
	(
		pparentnode     IN apitypes.typesecurnode
	   ,psearchtemplate VARCHAR
	) IS
		cwhere   CONSTANT VARCHAR(1000) := cpackagename || '.BuildSearchBaseNode';
		clastpos CONSTANT NUMBER := nvl(ssearchbasetree.last, 0);
		vnode  apitypes.typesecurnode;
		vshift NUMBER := 0;
	BEGIN
		s.say(cwhere || ' start... (lvl ' || pparentnode.level || ', key ' || pparentnode.key || ')');
	
		BEGIN
			cleararray;
		
			clearsiarrays();
		
			fillsecurityinfobyfunc(pparentnode, TRUE, psearchtemplate);
		
		EXCEPTION
			WHEN OTHERS THEN
				s.say(cwhere || ' error with Node.Id=' || pparentnode.id || ' pNode.Key=' ||
					  pparentnode.key);
				RETURN;
		END;
	
		timer.start_(cwhere);
		s.say(cwhere || ' sLastSISize=' || slastsisize);
	
		IF (slastsisize IS NULL)
		THEN
		
			ssearchbasetree(pparentnode.id).state := cstate_undefined;
			ssearchbasetree(pparentnode.id).nullable := TRUE;
			ssearchbasetree(pparentnode.id).subnodes := cnode_leaf;
			RETURN;
		END IF;
	
		sbasetree(pparentnode.id).nullable := FALSE;
	
		IF (slastsisize = 0)
		THEN
			ssearchbasetree(pparentnode.id).subnodes := cnode_leaf;
			IF ssearchnotendbranch.exists(pparentnode.id)
			THEN
				ssearchnotendbranch.delete(pparentnode.id);
				s.say(cwhere || ' delete sSearchNotEndBranch sLastSISize=0 pParentNode.Id=' ||
					  pparentnode.id);
				s.say(cwhere || ' sSearchNotEndBranch.count=' || ssearchnotendbranch.count);
			END IF;
			timer.stop_(cwhere);
			RETURN;
		END IF;
	
		IF ssearchnotendbranch.exists(pparentnode.id)
		THEN
			vshift := ssearchbasetree(pparentnode.id).subnodes;
			IF slastsisize < cmaxcountnode
			THEN
				ssearchnotendbranch.delete(pparentnode.id);
				s.say(cwhere || ' delete 2 sSearchNotEndBranch sLastSISize=' || slastsisize ||
					  ' pParentNode.Id=' || pparentnode.id);
				s.say(cwhere || ' sSearchNotEndBranch.count=' || ssearchnotendbranch.count);
			END IF;
		ELSIF slastsisize = cmaxcountnode
		THEN
			ssearchnotendbranch(pparentnode.id) := pparentnode;
			s.say(cwhere || ' add sSearchNotEndBranch(pParentNode.Id).id=' || ssearchnotendbranch(pparentnode.id).id);
		END IF;
	
		s.say(cwhere || ' cLastPos=' || clastpos);
		s.say(cwhere || ' vShift=' || vshift);
		ssearchbasetree(pparentnode.id).subnodes := slastsisize + vshift;
		ssearchbasetree(pparentnode.id).substart := clastpos + 1;
	
		s.say(cwhere || ' sSearchNotEndBranch.count=' || ssearchnotendbranch.count);
	
		DECLARE
			vkeycode NUMBER;
		BEGIN
			FOR i IN 1 .. slastsisize
			LOOP
				dummy          := i;
				vnode          := NULL;
				vnode.id       := clastpos + i;
				vnode.parentid := pparentnode.id;
				vnode.level    := pparentnode.level + 1;
				vnode.key      := pparentnode.key || slastsicode(i) || '|';
				vnode.text     := slastsitext(i);
				vnode.subnodes := cnode_undefine;
			
				vnode.objectid := pparentnode.objectid;
				vnode.nullable := FALSE;
				--vnode.isfunction := pparentnode.isfunction;
				IF slastsifin.exists(i)
				   AND slastsifin(i)
				THEN
					vnode.subnodes := cnode_leaf;
				END IF;
			
				IF haskeyexactlythis(vnode.key)
				THEN
					vnode.state := cstate_check;
				ELSE
					vnode.state := cstate_uncheck;
				END IF;
			
				ssearchbasetree(vnode.id) := vnode;
				s.say(cwhere || ' vNode.Id=' || vnode.id);
				putnodetomap(ssearchbasetreemap, vnode);
				ssearchbasetreenames(vnode.id) := getaccesskeydescription(vnode.objectid
																		 ,vnode.key
																		 ,pissearch => TRUE);
			END LOOP;
		EXCEPTION
			WHEN OTHERS THEN
				htools.message('Cannot add node ~' || slastsitext(dummy)
							  ,'Internal Exception handled');
				RETURN;
		END;
	
		timer.stop_(cwhere);
	
		FOR i IN 1 .. slastsisize
		LOOP
			IF cnode_leaf != nvl(ssearchbasetree(clastpos + i).subnodes, cnode_undefine)
			THEN
				buildsearchbasenode(ssearchbasetree(clastpos + i), psearchtemplate);
			END IF;
		END LOOP;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION getflaglimitedview RETURN BOOLEAN IS
	BEGIN
		RETURN nvl(htools.getcfg_bool(ccfg_view_curr_treebranch), FALSE);
	END;

	FUNCTION dialoglist RETURN NUMBER IS
		cwhere    CONSTANT VARCHAR2(100) := cpackagename || '.DialogList';
		cevent    CONSTANT VARCHAR2(100) := cpackagename || '.DialogListHandler';
		ceventgrp CONSTANT VARCHAR2(100) := cpackagename || '.GroupDialogHandler';
	
		vdialog   NUMBER;
		vmenu     NUMBER;
		vpropmenu NUMBER;
		vpage     NUMBER;
	
		cdialogwidth  CONSTANT NUMBER := 80;
		cdialogheight CONSTANT NUMBER := 20;
		clistwidth    CONSTANT NUMBER := cdialogwidth - 2;
		clistheight   CONSTANT NUMBER := cdialogheight - 2;
		cbutlen       CONSTANT NUMBER := 10;
	
	BEGIN
		isfullview := FALSE;
		IF NOT (checkright(right_grant) OR checkright(right_group_create) OR
			checkright(right_group_modify))
		THEN
			IF checkright(right_view)
			THEN
				isfullview := TRUE;
			ELSE
				RETURN htools.messagebox('Application is unavailable'
										,'You are not authorized to enter discretionary access system.~Contact system administrator.~'
										,pbutton => htools.mb_ok);
			END IF;
		END IF;
	
		vdialog := dialog.new('Discretionary access system' ||
							  service.iif(isfullview, ' (view mode)', '')
							 ,0
							 ,0
							 ,cdialogwidth
							 ,cdialogheight
							 ,presizable => TRUE);
		dialog.setexternalid(vdialog, cwhere);
	
		vmenu := dialog.menu(vdialog);
		report_form.makeprintmenu(vdialog, vmenu, report_form.pfsecurity, NULL, TRUE);
		dummy := dialog.makemenusearch(vmenu);
	
		vpropmenu := dialog.submenu(vmenu, 'Setup', 'Setup');
		dialog.menuitem(vpropmenu, 'PROPERTY', 'Viewing parameters', 0, 0, 'Viewing parameters');
		dialog.setitempre(vdialog, 'PROPERTY', cevent);
	
		IF NOT isfullview
		   AND checkright(right_view)
		THEN
			dialog.separator(vmenu);
			dialog.menuitem(vmenu
						   ,'mnuFullView'
						   ,'Full view mode'
						   ,phint           => 'Switch to full view mode with no option to modify'
						   ,phandler        => cevent);
			dialog.menuitem(vmenu
						   ,'mnuEdit'
						   ,'Modification mode'
						   ,phint              => 'Switch to modification mode'
						   ,phandler           => cevent);
			dialog.setvisible(vmenu, 'mnuEdit', FALSE);
		END IF;
		dialog.setdialogmenu(vdialog, vmenu);
	
		dialog.pagelist(vdialog, 'PageList', 1, 1, clistwidth, clistheight);
	
		dialog.setanchor(vdialog, 'PageList', dialog.anchor_all);
	
		vpage := dialog.page(vdialog, 'PageList', 'Operators', ppagename => 'Page_Users');
	
		dialog.list(vpage
				   ,'lstUsers'
				   ,2
				   ,3
				   ,clistwidth - 4 - 3 - cbutlen - 3
				   ,clistheight - 5
				   ,'List of operators'
				   ,pevrypos => TRUE);
	
		dialog.setanchor(vpage, 'lstUsers', dialog.anchor_all);
		dialog.listaddfield(vpage, 'lstUsers', 'Id', 'N', 15, 0);
		dialog.listaddfield(vpage, 'lstUsers', 'InternalName', 'C', 25, 1);
		dialog.listaddfield(vpage, 'lstUsers', 'FullName', 'C', 33, 1);
		dialog.setcaption(vpage, 'lstUsers', 'User~Name~');
		dialog.setitempre(vpage, 'lstUsers', cevent);
		dialog.setitemchange(vpage, 'lstUsers', cevent);
	
		dialog.button(vpage
					 ,'btnGrant_U'
					 ,clistwidth - 3 - cbutlen
					 ,2
					 ,cbutlen
					 ,'Rights'
					 ,0
					 ,0
					 ,'List of group rights'
					 ,cevent);
		dialog.setanchor(vpage, 'btnGrant_U', dialog.anchor_right + dialog.anchor_top);
		dialog.button(vpage
					 ,'btnDetail'
					 ,clistwidth - 3 - cbutlen
					 ,4
					 ,cbutlen
					 ,'Parameters'
					 ,0
					 ,0
					 ,'View/modify list of operator groups'
					 ,cevent);
		dialog.setanchor(vpage, 'btnDetail', dialog.anchor_right + dialog.anchor_top);
	
		vpage := dialog.page(vdialog, 'PageList', 'Groups', ppagename => 'Page_Groups');
	
		dialog.list(vpage
				   ,'lstGroups'
				   ,2
				   ,3
				   ,clistwidth - 4 - 3 - cbutlen - 3
				   ,clistheight - 5
				   ,'List of groups'
				   ,pevrypos => TRUE);
		dialog.setanchor(vpage, 'lstGroups', dialog.anchor_all);
	
		dialog.listaddfield(vpage, 'lstGroups', 'ID', 'N', 10, 0);
		dialog.listaddfield(vpage, 'lstGroups', 'Active', 'C', 2, 1);
		dialog.listaddfield(vpage, 'lstGroups', 'Name', 'C', 25, 1);
		dialog.listaddfield(vpage, 'lstGroups', 'Remark', 'C', 40, 1);
		dialog.setcaption(vpage, 'lstGroups', 'A (active)~Name~Comment~');
		dialog.setitempre(vpage, 'lstGroups', ceventgrp);
		dialog.setitemchange(vpage, 'lstGroups', ceventgrp);
	
		dialog.button(vpage
					 ,'btnAdd'
					 ,clistwidth - 3 - cbutlen
					 ,3
					 ,cbutlen
					 ,'Add'
					 ,0
					 ,0
					 ,'Add group'
					 ,ceventgrp);
		dialog.setanchor(vpage, 'btnAdd', dialog.anchor_right + dialog.anchor_top);
		dialog.setenable(vpage, 'btnAdd', checkright(right_group_create));
		dialog.button(vpage
					 ,'btnDelete'
					 ,clistwidth - 3 - cbutlen
					 ,5
					 ,cbutlen
					 ,'Delete'
					 ,0
					 ,0
					 ,'Delete group'
					 ,ceventgrp);
		dialog.setanchor(vpage, 'btnDelete', dialog.anchor_right + dialog.anchor_top);
		dialog.button(vpage
					 ,'btnGrant'
					 ,clistwidth - 3 - cbutlen
					 ,8
					 ,cbutlen
					 ,'Rights'
					 ,0
					 ,0
					 ,'List of group rights'
					 ,ceventgrp);
		dialog.setanchor(vpage, 'btnGrant', dialog.anchor_right + dialog.anchor_top);
	
		dialog.button(vpage
					 ,'btnContain'
					 ,clistwidth - 3 - cbutlen
					 ,10
					 ,cbutlen
					 ,'Parameters'
					 ,0
					 ,0
					 ,'View/edit attributes or list of operators included in group'
					 ,ceventgrp);
		dialog.setanchor(vpage, 'btnContain', dialog.anchor_right + dialog.anchor_top);
	
		dialog.progressbar(vdialog, 'pb1', clistwidth - 3 - cbutlen, 17, 12);
		dialog.setanchor(vdialog, 'pb1', dialog.anchor_right + dialog.anchor_bottom);
		dialog.setvisible(vdialog, 'pb1', FALSE);
	
		dialog.button(vdialog
					 ,'btnCancel'
					 ,cdialogwidth / 2 - cbutlen / 2
					 ,cdialogheight
					 ,cbutlen
					 ,'Exit'
					 ,dialog.cmcancel
					 ,0
					 ,'Exit dialog box');
		dialog.setanchor(vdialog, 'btnCancel', dialog.anchor_bottom);
		dialog.setdialogpre(vdialog, cevent);
		dialog.setdialogpost(vdialog, cevent);
	
		smaindialog := vdialog;
		RETURN vdialog;
	END;

	PROCEDURE dialoglisthandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.DialogListHandler';
		vuserid          NUMBER;
		vusername        VARCHAR(40);
		vlockkey         VARCHAR(32767);
		vflaglimitedview BOOLEAN := getflaglimitedview();
	BEGIN
		s.say(cwhere || ' start with (pWhat = ' || pwhat || ', pDialog = ' || pdialog ||
			  ', Item = ' || pitemname || ', pCmd = ' || pcmd || ')');
		CASE pwhat
			WHEN dialog.wtdialogpre THEN
				IF (isfullview OR checkright(right_grant_user) OR checkright(right_grant_self))
				THEN
					filluserlist(pdialog);
				ELSE
					dialog.setvisible(pdialog, 'Page_Users', FALSE);
				END IF;
				IF (isfullview OR checkright(right_grant_group) OR checkright(right_group_create) OR
				   checkright(right_group_modify))
				THEN
					fillgrouplist(pdialog);
				ELSE
					dialog.setvisible(pdialog, 'Page_Groups', FALSE);
				END IF;
				dialog.goitem(pdialog, 'lstUsers');
			
			WHEN dialog.wtdialogpost THEN
			
				COMMIT;
				smaindialog := 0;
			
			WHEN dialog.wtitempre THEN
			
				IF (pitemname = upper('btnDetail'))
				THEN
					scuruserid   := dialog.getcurrentrecordnumber(pdialog, 'lstUsers', 'ID');
					scurusername := dialog.getcurrentrecordchar(pdialog, 'lstUsers', 'INTERNALNAME');
					scurusertype := ot_user;
					vlockkey     := 'M:' || scurusertype || scuruserid;
				
					IF (NOT object.setlock(security.object_name, vlockkey))
					THEN
						htools.message('Warning !'
									  ,'Opreator is being edited from another station~' ||
									   object.capturedobjectinfo(security.object_name, vlockkey) || '~');
						RETURN;
					END IF;
				
					dialog.exec(detaildialog());
				
					object.release(security.object_name, vlockkey);
					vlockkey := NULL;
				ELSIF pitemname = 'PROPERTY'
				THEN
					dialog.exec(propertydialog());
				ELSIF (pitemname IN (upper('lstUsers'), upper('btnGrant_U')))
				THEN
					vuserid   := dialog.getcurrentrecordnumber(pdialog, 'lstUsers', 'ID');
					vusername := clerk.getnamebycode(vuserid);
				
					s.say(cwhere || ' start initCurrent vUserId=' || vuserid);
					initcurrent(vuserid, ot_user, vusername, pnoload => vflaglimitedview);
					scuruserid   := vuserid;
					scurusertype := ot_user;
					scurusername := vusername;
					IF isfullview
					THEN
						fillgranttree();
						ssomenodechanged := FALSE;
						showgrantnode(NULL);
					ELSE
						IF vusername = seance.getclerkuser
						THEN
							IF NOT checkright(right_grant_self)
							THEN
								dialog.sethothint(pdialog, 'No privileges to assign own rights');
								RETURN;
							END IF;
						ELSE
							IF NOT checkright(right_grant_user)
							THEN
								dialog.sethothint(pdialog
												 ,'You are not authorized to assign rights to operators individually');
								RETURN;
							END IF;
						END IF;
						vlockkey := 'G:' || scurusertype || scuruserid;
					
						IF (NOT object.setlock(security.object_name, vlockkey))
						THEN
							htools.message('Warning !'
										  ,'Operator rights are being edited from another station~' ||
										   object.capturedobjectinfo(security.object_name
																	,vlockkey) || '~');
							RETURN;
						END IF;
					
						fillgranttree();
					
						ssomenodechanged := FALSE;
					
						showgrantnode(NULL);
					
						object.release(security.object_name, vlockkey);
						vlockkey := NULL;
					
					END IF;
					dialog.setprogressbar(pdialog, 'pb1', 0);
				
				ELSIF htools.equal(pitemname, 'mnuFullView')
				THEN
					isfullview := TRUE;
					dialog.setvisible(pdialog, 'mnuFullView', FALSE);
					dialog.setvisible(pdialog, 'mnuEdit', TRUE);
					dialog.setcaption(pdialog
									 ,'Discretionary access system' ||
									  service.iif(isfullview, ' (view mode)', ''));
					dialoglisthandler(dialog.wtdialogpre, pdialog, NULL, NULL);
				
				ELSIF htools.equal(pitemname, 'mnuEdit')
				THEN
					isfullview := FALSE;
					dialog.setvisible(pdialog, 'mnuFullView', TRUE);
					dialog.setvisible(pdialog, 'mnuEdit', FALSE);
					dialog.setcaption(pdialog
									 ,'Discretionary access system' ||
									  service.iif(isfullview, ' (view mode)', ''));
					dialoglisthandler(dialog.wtdialogpre, pdialog, NULL, NULL);
				END IF;
			
			WHEN dialog.wt_itemchange THEN
				CASE pitemname
					WHEN upper('lstUsers') THEN
						IF clerk.getnamebycode(dialog.getcurrentrecordnumber(pdialog
																			,'lstUsers'
																			,'ID')) =
						   seance.getclerkuser
						THEN
							dialog.setenable(pdialog
											,'btnGrant_U'
											,isfullview OR checkright(right_grant_self));
						ELSE
							dialog.setenable(pdialog
											,'btnGrant_U'
											,isfullview OR checkright(right_grant_user));
						END IF;
						dialog.sethothint(pdialog, '');
					ELSE
						NULL;
				END CASE;
			
			ELSE
				NULL;
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			IF vlockkey IS NOT NULL
			THEN
				object.release(security.object_name, vlockkey);
			END IF;
		
			RAISE;
	END;

	FUNCTION accessdialog(plevel IN NUMBER) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.AccessDialog';
		vdialog   NUMBER;
		vh        NUMBER;
		sw        NUMBER;
		vcaption  VARCHAR(90);
		vmenu     NUMBER;
		vopermenu NUMBER;
		cbutlen CONSTANT NUMBER := 10;
		cevent  CONSTANT VARCHAR(100) := cpackagename || '.AccessDialogHandler';
	BEGIN
		sw := 80 - (plevel - 1) * 2;
		vh := 22 - (plevel - 1);
		IF (plevel = 0)
		THEN
			vcaption := 'Allowed objects for"' || scurusername || '"';
		ELSE
			vcaption := substr(security.stitle || ' ("' || scurusername || '")', 1, 90);
		END IF;
		vdialog := dialog.new(vcaption, 0, 0, sw, vh, presizable => TRUE);
		dialog.setexternalid(vdialog, cwhere);
		dialog.setdialogpre(vdialog, cevent);
		dialog.setdialogvalid(vdialog, cevent);
		dialog.setdialogpost(vdialog, cevent);
	
		dialog.inputcheck(vdialog
						 ,'chAll'
						 ,2
						 ,1
						 ,plen     => 20
						 ,phint    => 'Allow all specified rights including nested ones'
						 ,pcaption => 'All');
		dialog.setitempre(vdialog, 'chAll', cevent);
		dialog.setreadonly(vdialog, 'chAll', NOT checkright(right_delegate));
	
		dialog.checkbox(vdialog, 'chNodes', 2, 1, sw - 5, vh - 4, '', panchor => dialog.anchor_all);
		dialog.listaddfield(vdialog, 'chNodes', 'ID', 'N', 0, 0);
		dialog.listaddfield(vdialog, 'chNodes', 'Key', 'C', 0, 0);
		dialog.listaddfield(vdialog, 'chNodes', 'Name', 'C', sw - 3, 1);
		dialog.setitempre(vdialog, 'chNodes', cevent);
		dialog.setitemmark(vdialog, 'chNodes', cevent, peverypos => TRUE);
		dialog.setreadonly(vdialog, 'chNodes', NOT checkright(right_delegate));
	
		vmenu     := dialog.menu(vdialog);
		vopermenu := dialog.submenu(vmenu, 'Operations', '');
		dialog.menuitem(vopermenu
					   ,'SELECT_ALL'
					   ,'Assign all rights'
					   ,0
					   ,0
					   ,'Assign all rights included in current level and its sublevels');
		dialog.menuitem(vopermenu
					   ,'CLEAR_ALL'
					   ,'Remove all rights'
					   ,0
					   ,0
					   ,'Remove all rights included in current level and its sublevels');
		dialog.setitempre(vdialog, 'SELECT_ALL', cevent);
		dialog.setitempre(vdialog, 'CLEAR_ALL', cevent);
		dialog.setenable(vdialog, 'Select_All', checkright(right_delegate));
		dialog.setenable(vdialog, 'Clear_All', checkright(right_delegate));
		dummy     := dialog.makemenusearch(vmenu, 'chNodes', NULL, FALSE);
		scurlevel := plevel;
	
		IF (scurlevel = 0)
		THEN
			slastnodeid := 0;
			dialog.button(vdialog
						 ,'btnSave'
						 ,sw / 2 - 1 - cbutlen
						 ,vh - 1
						 ,cbutlen
						 ,'Enter'
						 ,dialog.cmok
						 ,0
						 ,'Save changes');
			dialog.setanchor(vdialog, 'btnSave', dialog.anchor_bottom);
			IF NOT checkright(right_delegate)
			THEN
				dialog.setenable(vdialog, 'btnSave', FALSE);
			END IF;
			dialog.setdefault(vdialog, 'btnSave');
		
			dialog.button(vdialog
						 ,'btnCancel'
						 ,sw / 2 + 1
						 ,vh - 1
						 ,cbutlen
						 ,'Cancel'
						 ,dialog.cmcancel
						 ,0
						 ,'Exit without saving');
			dialog.setanchor(vdialog, 'btnCancel', dialog.anchor_bottom);
			dialog.setitempost(vdialog, 'btnCancel', cevent);
		ELSE
			dialog.button(vdialog
						 ,'btnCancel'
						 ,sw / 2 - cbutlen / 2
						 ,vh - 1
						 ,cbutlen
						 ,'Exit'
						 ,dialog.cmok
						 ,0
						 ,'Return to previous level');
			dialog.setanchor(vdialog, 'btnCancel', dialog.anchor_bottom);
		END IF;
	
		RETURN vdialog;
	
	END;

	PROCEDURE accessdialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
	
	BEGIN
		s.say('AccessDialogHandler(pWhat=' || pwhat || ')');
	
	EXCEPTION
		WHEN OTHERS THEN
			error.show();
			dialog.cancelclose(pdialog);
	END;

	FUNCTION groupdialog RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.GroupDialog';
		cevent CONSTANT VARCHAR2(100) := cpackagename || '.GroupDialogHandler';
		vdialog NUMBER;
	BEGIN
		vdialog := dialog.new('Groups of operators ', 0, 0, 72, 15);
		dialog.setexternalid(vdialog, cwhere);
	
		dialog.bevel(vdialog, 1, 1, 70, 12, dialog.bevel_frame, TRUE, 'Description');
	
		dialog.list(vdialog, 'lstGroups', 2, 2, 52, 9, 'List of operator groups');
		dialog.listaddfield(vdialog, 'lstGroups', 'ID', 'N', 10, 0);
		dialog.listaddfield(vdialog, 'lstGroups', 'Active', 'C', 2, 1);
		dialog.listaddfield(vdialog, 'lstGroups', 'Name', 'C', 25, 1);
		dialog.listaddfield(vdialog, 'lstGroups', 'Remark', 'C', 25, 1);
		dialog.setitempre(vdialog, 'lstGroups', cevent);
	
		dialog.button(vdialog, 'btnAdd', 56, 3, 12, 'Add', 0, 0, 'Add group');
		dialog.setitempre(vdialog, 'btnAdd', cevent);
	
		dialog.button(vdialog, 'btnDelete', 56, 5, 12, 'Delete', 0, 0, 'Delete current group');
		dialog.setitempre(vdialog, 'btnDelete', cevent);
	
		dialog.button(vdialog
					 ,'btnContain'
					 ,56
					 ,10
					 ,12
					 ,'Composition'
					 ,0
					 ,0
					 ,'List of operators included in group');
		dialog.setitempre(vdialog, 'btnContain', cevent);
	
		dialog.button(vdialog
					 ,'btnCancel'
					 ,72 / 2 - 12 / 2
					 ,14
					 ,12
					 ,'Exit'
					 ,dialog.cmcancel
					 ,0
					 ,'Exit dialog box');
	
		dialog.setdialogpre(vdialog, cevent);
		dialog.setdialogpost(vdialog, cevent);
		RETURN vdialog;
	END;

	PROCEDURE groupdialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.GroupDialogHandler';
		vdialog  NUMBER;
		vid      NUMBER;
		vcmd     NUMBER;
		vpos     NUMBER;
		vlockkey VARCHAR(1000);
		vnode    apitypes.typesecurnode;
	
		vflaglimitedview BOOLEAN := getflaglimitedview();
	
	BEGIN
		s.say(cwhere || ' start with (pWhat = ' || pwhat || ', pDialog = ' || pdialog ||
			  ', Item = ' || pitemname || ', pCmd = ' || pcmd || ')');
		CASE pwhat
		
			WHEN dialog.wtdialogpre THEN
				fillgrouplist(pdialog);
			WHEN dialog.wtdialogpost THEN
				COMMIT;
			WHEN dialog.wtitempre THEN
				IF (pitemname = upper('btnAdd'))
				THEN
					vdialog := addgroupdialog;
					vcmd    := dialog.execdialog(vdialog);
					dialog.destroy(vdialog);
					IF (vcmd = dialog.cmok)
					THEN
						SELECT sclerkgroup_id.nextval INTO vid FROM dual;
						INSERT INTO tclerkgroup
							(branch
							,id
							,NAME
							,remark
							,active
							,created
							,createby)
						VALUES
							(seance.getbranch
							,vid
							,scurgroupname
							,scurgroupremark
							,1
							,SYSDATE
							,seance.getclerkcode);
						vnode.objectid := 0;
						vnode.key      := '|' || right_group || '|' || right_group_modify || '|' || vid || '|';
						grant_(vnode, seance.getclerkcode, security.ot_user);
						vnode.key := '|' || right_grant || '|' || right_grant_group || '|' || vid || '|';
						grant_(vnode, seance.getclerkcode, security.ot_user);
						a4mlog.cleanplist;
						a4mlog.addparamrec('Name', scurgroupname);
						a4mlog.addparamrec('Description', scurgroupremark);
					
						a4mlog.logobject(object.gettype(group_object_name)
										,vid
										,'Created group "' || scurgroupname || '"'
										,a4mlog.act_add
										,a4mlog.putparamlist);
						COMMIT;
						fillgrouplist(pdialog);
						dialog.setcurrec(pdialog
										,'lstGroups'
										,dialog.getlistreccount(pdialog, 'lstGroups'));
					
					END IF;
				ELSIF (pitemname = upper('btnDelete'))
				THEN
				
					IF htools.ask('Confirmation'
								 ,'Do you really want to delete group' || chr(10) || '"' ||
								  dialog.getcurrentrecordchar(pdialog, 'lstGroups', 'Name') || '"?'
								 ,'Yes'
								 ,'No') = TRUE
					THEN
						vid  := dialog.getcurrentrecordnumber(pdialog, 'lstGroups', 'ID');
						vpos := dialog.getlistcurrentrecordnumber(pdialog, 'lstGroups');
					
						BEGIN
							SAVEPOINT sp_groupdialoghandler;
							DELETE FROM tclerkgroup
							WHERE  branch = seance.getbranch
							AND    id = vid;
							DELETE FROM tclerk2group
							WHERE  branch = seance.getbranch
							AND    groupid = vid;
							DELETE FROM trights
							WHERE  branch = seance.getbranch
							AND    userid = vid
							AND    usertype = ot_group;
							revokerightfromall(object_name
											  ,'|' || right_grant || '|' || right_grant_group || '|' ||
											   to_char(vid) || '|');
							revokerightfromall(object_name
											  ,'|' || right_group || '|' || right_group_modify || '|' ||
											   to_char(vid) || '|');
						
							a4mlog.cleanplist;
							a4mlog.addparamrec('Name'
											  ,dialog.getcurrentrecordchar(pdialog
																		  ,'lstGroups'
																		  ,'Name'));
						
							a4mlog.logobject(object.gettype(group_object_name)
											,vid
											,'Deleted group "' ||
											 dialog.getcurrentrecordchar(pdialog
																		,'lstGroups'
																		,'Name') || '"'
											,a4mlog.act_del
											,a4mlog.putparamlist);
							COMMIT;
						EXCEPTION
							WHEN OTHERS THEN
								s.err('Delete group');
								ROLLBACK TO spgroupdialoghandler;
						END;
						fillgrouplist(pdialog);
						IF (vpos > dialog.getlistreccount(pdialog, 'lstGroups'))
						THEN
							vpos := dialog.getlistreccount(pdialog, 'lstGroups');
						END IF;
						dialog.setcurrec(pdialog, 'lstGroups', vpos);
					END IF;
				
				ELSIF (pitemname IN (upper('lstGroups'), upper('btnGrant')))
				THEN
				
					s.say(cwhere || ' start initCurrent GroupsId=' ||
						  dialog.getcurrentrecordnumber(pdialog, 'lstGroups', 'ID'));
					initcurrent(dialog.getcurrentrecordnumber(pdialog, 'lstGroups', 'ID')
							   ,ot_group
							   ,dialog.getcurrentrecordchar(pdialog, 'lstGroups', 'Name')
							   ,pnoload => vflaglimitedview);
					scuruserid   := dialog.getcurrentrecordnumber(pdialog, 'lstGroups', 'ID');
					scurusername := dialog.getcurrentrecordchar(pdialog, 'lstGroups', 'Name');
					scurusertype := ot_group;
					IF isfullview
					THEN
						fillgranttree();
						showgrantnode(NULL);
					ELSE
						IF NOT checkright2group(right_grant_group, scuruserid)
						THEN
							dialog.sethothint(pdialog
											 ,'You are not authorized to assign rights to current group');
							RETURN;
						END IF;
					
						vlockkey := 'G:' || scurusertype || scuruserid;
					
						IF (NOT object.setlock(security.object_name, vlockkey))
						THEN
							htools.message('Warning !'
										  ,'Group rights are being edited from another station~' ||
										   object.capturedobjectinfo(security.object_name
																	,vlockkey) || '~');
							RETURN;
						END IF;
					
						fillgranttree();
						showgrantnode(NULL);
					
						object.release(security.object_name, vlockkey);
						vlockkey := NULL;
					END IF;
				
				ELSIF (pitemname = upper('btnContain'))
				THEN
					scuruserid   := dialog.getcurrentrecordnumber(pdialog, 'lstGroups', 'ID');
					scurusername := dialog.getcurrentrecordchar(pdialog, 'lstGroups', 'Name');
					scurusertype := ot_group;
				
					scurgroupid := ktools.lasnumber(pdialog, 'lstGroups', 'ID');
				
					SELECT NAME
						  ,remark
					INTO   scurgroupname
						  ,scurgroupremark
					FROM   tclerkgroup
					WHERE  branch = seance.getbranch
					AND    id = scurgroupid;
				
					vpos := ktools.lselected(pdialog, 'lstGroups');
				
					IF isfullview
					THEN
						dialog.exec(usergldialog());
					ELSE
						vlockkey := 'M:' || scurusertype || scuruserid;
					
						IF (NOT object.setlock(security.object_name, vlockkey))
						THEN
							htools.message('Warning !'
										  ,'Group is being edited from another station~' ||
										   object.capturedobjectinfo(security.object_name
																	,vlockkey) || '~');
							RETURN;
						END IF;
					
						IF (dialog.exec(usergldialog()) = dialog.cmok)
						THEN
							fillgrouplist(pdialog);
							ktools.lselect(pdialog, 'lstGroups', vpos);
						END IF;
					
						object.release(security.object_name, vlockkey);
						vlockkey := NULL;
					END IF;
				
				END IF;
			WHEN dialog.wt_itemchange THEN
				CASE pitemname
					WHEN upper('lstGroups') THEN
						dialog.setenable(pdialog
										,'btnGrant'
										,isfullview OR
										 checkright2group(right_grant_group
														 ,dialog.getcurrentrecordnumber(pdialog
																					   ,pitemname
																					   ,'Id')));
						dialog.setenable(pdialog
										,'btnContain'
										,isfullview OR
										 checkright2group(right_group_modify
														 ,dialog.getcurrentrecordnumber(pdialog
																					   ,pitemname
																					   ,'Id')));
						dialog.sethothint(pdialog, '');
					ELSE
						NULL;
				END CASE;
			ELSE
				NULL;
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			IF vlockkey IS NOT NULL
			THEN
				object.release(security.object_name, vlockkey);
			END IF;
			ROLLBACK TO spno_changes;
			error.showerror();
	END;

	FUNCTION addgroupdialog RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.AddGroupDialog';
		vdialog NUMBER;
	
		cbutlen       CONSTANT NUMBER := 10;
		cdialogwidth  CONSTANT NUMBER := 60;
		cdialogheight CONSTANT NUMBER := 5;
	
	BEGIN
	
		vdialog := dialog.new('New group of operators', 0, 0, cdialogwidth, cdialogheight);
		dialog.setexternalid(vdialog, cwhere);
	
		dialog.inputchar(vdialog, 'eName', 15, 2, 40, 'Group name', 40, '        Name:');
		dialog.setmandatory(vdialog, 'eName');
		dialog.inputchar(vdialog, 'eRemark', 15, 3, 40, 'Group comment', 40, '    Comment:');
	
		dialog.button(vdialog
					 ,'btnOk'
					 ,cdialogwidth / 2 - 1 - cbutlen
					 ,cdialogheight
					 ,cbutlen
					 ,'Enter'
					 ,dialog.cmok
					 ,0
					 ,'Save changes');
	
		IF NOT checkright(right_modify)
		THEN
			dialog.setenable(vdialog, 'btnOK', FALSE);
		END IF;
	
		dialog.button(vdialog
					 ,'btnCancel'
					 ,cdialogwidth / 2 + 1
					 ,cdialogheight
					 ,cbutlen
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Exit without saving');
	
		dialog.setitemattributies(vdialog, 'btnOk', dialog.defaulton);
		dialog.setdialogvalid(vdialog, cpackagename || '.AddGroupDialogHandler');
		RETURN vdialog;
	END;

	PROCEDURE addgroupdialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
	BEGIN
		IF (pwhat = dialog.wtdialogvalid)
		THEN
			IF (groupexists(dialog.getchar(pdialog, 'eName')))
			THEN
				dialog.sethothint(pdialog, 'Group with such name already exists');
				dialog.goitem(pdialog, 'eName');
			ELSE
			
				scurgroupname   := substr(dialog.getchar(pdialog, 'eName'), 1, 40);
				scurgroupremark := substr(dialog.getchar(pdialog, 'eRemark'), 1, 40);
			END IF;
		END IF;
	END;

	PROCEDURE addclerkintogroup
	(
		pclerkid NUMBER
	   ,pgroupid NUMBER
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.AddClerkIntoGroup';
	BEGIN
		INSERT INTO tclerk2group
			(branch
			,clerkid
			,groupid)
		VALUES
			(seance.getbranch
			,pclerkid
			,pgroupid);
	
		a4mlog.cleanplist;
		a4mlog.addparamrec('Operator', pclerkid);
		a4mlog.addparamrec('Username', getuserinfo(pclerkid).name);
	
		a4mlog.logobject(object.gettype(group_object_name)
						,pgroupid
						,'Operator ' || getuserinfo(pclerkid).name || ' (' || to_char(pclerkid) ||
						 ') added to group "' || getgroupinfo(pgroupid).name || '"'
						,a4mlog.act_add
						,a4mlog.putparamlist);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE removeclerkfromgroup
	(
		pclerkid NUMBER
	   ,pgroupid NUMBER
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.RemoveClerkFromGroup';
	BEGIN
		DELETE FROM tclerk2group
		WHERE  branch = seance.getbranch
		AND    groupid = pgroupid
		AND    clerkid = pclerkid;
	
		a4mlog.cleanplist;
		a4mlog.addparamrec('Operator', pclerkid);
		a4mlog.addparamrec('Username', getuserinfo(pclerkid).name);
	
		a4mlog.logobject(object.gettype(group_object_name)
						,pgroupid
						,'Operator ' || getuserinfo(pclerkid).name || ' (' || pclerkid ||
						 ') deleted from group "' || getgroupinfo(pgroupid).name || '"'
						,a4mlog.act_del
						,a4mlog.putparamlist);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION usergldialog RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.UserGLDialog';
		vdialog   NUMBER;
		vmenu     NUMBER;
		vmenudata NUMBER;
		cdw         CONSTANT NUMBER := 80;
		cdh         CONSTANT NUMBER := 20;
		cpw         CONSTANT NUMBER := cdw - 2;
		cph         CONSTANT NUMBER := cdh - 9;
		cbw         CONSTANT NUMBER := 10;
		cft         CONSTANT NUMBER := 18;
		clistwidth  CONSTANT NUMBER := cpw - 4 - 3 - cbw - 3;
		clistheight CONSTANT NUMBER := cph - 5;
		vpage NUMBER;
		vi    NUMBER;
		cevent   CONSTANT VARCHAR(100) := cpackagename || '.UserGLDialogHandler';
		ccanedit CONSTANT BOOLEAN := NOT isfullview AND
									 checkright2group(right_group_modify, scurgroupid);
	BEGIN
		vdialog := dialog.new('Group (ID ' || scurgroupid || ')' ||
							  service.iif(isfullview, ' (view-only)', '')
							 ,0
							 ,0
							 ,cdw
							 ,cdh
							 ,presizable => TRUE);
		dialog.setexternalid(vdialog, cwhere);
		dialog.setdialogpre(vdialog, cevent);
		dialog.setdialogvalid(vdialog, cevent);
		dialog.setdialogpost(vdialog, cevent);
	
		dialog.hiddennumber(vdialog, 'eGroupID', scurgroupid);
	
		vmenu     := dialog.menu(vdialog);
		vmenudata := dialog.submenu(vmenu, 'Data', '');
		dialog.menuitem(vmenudata
					   ,'Log'
					   ,'Event log'
					   ,phint      => 'View Event log for current group'
					   ,phandler   => cevent);
		dialog.menuitem(vmenudata
					   ,'Memo'
					   ,'Memo log'
					   ,phint     => 'Memos for current group'
					   ,phandler  => cevent);
	
		dummy := dialog.submenu(vmenu, 'Administration', '');
		dialog.setvisible(dummy, FALSE);
	
		dialog.menuitem(dummy
					   ,'mnuDelegate'
					   ,'List of allowed rights'
					   ,phint                   => 'Change list of allowed rights to delegate authority for managing subject rights'
					   ,phandler                => cevent);
		dialog.setvisible(vdialog, 'mnuDelegate', checkright(right_delegate));
	
		vi := 1;
		dialog.bevel(vdialog, 1, vi, cdw - 1, 3, pcaption => '', pshape => dialog.bevel_frame);
		vi := vi + 1;
		dialog.inputchar(vdialog, 'eName', cft, vi, 40, 'Group name', 40, '        Name:');
		dialog.setreadonly(vdialog, 'eName', NOT ccanedit);
		dialog.setmandatory(vdialog, 'eName');
		vi := vi + 1;
		dialog.inputchar(vdialog, 'eRemark', cft, vi, 40, 'Group comment', 40, '    Comment:');
		dialog.setreadonly(vdialog, 'eRemark', NOT ccanedit);
		vi := vi + 2;
	
		dialog.bevel(vdialog
					,1
					,vi
					,cdw - 1
					,2
					,pcaption => 'Rights validity period'
					,pshape => dialog.bevel_frame);
		vi := vi + 1;
		dialog.inputdate(vdialog
						,'StartDate'
						,cft
						,vi
						,'Rights validity start system date'
						,'  Start date:');
		dialog.setreadonly(vdialog, 'StartDate', NOT ccanedit);
		dialog.inputdate(vdialog
						,'EndDate'
						,cdw / 2 + cft
						,vi
						,'Rights validity end system date(inclusive)'
						,'       End date:');
		dialog.setreadonly(vdialog, 'EndDate', NOT ccanedit);
		vi := vi + 1;
		vi := vi + 1;
		dialog.pagelist(vdialog, 'MainPageList', 1, vi, cpw, cdh - 1 - vi);
	
		vpage := dialog.page(vdialog, 'MainPageList', 'List of operators');
	
		dialog.list(vpage, 'lstIn', 2, 3, clistwidth, clistheight, 'Operators included in group');
	
		dialog.setanchor(vpage, 'lstIn', dialog.anchor_all);
		dialog.listaddfield(vdialog, 'lstIn', 'CODE', 'N', 10, 0);
		dialog.listaddfield(vdialog, 'lstIn', 'NAME', 'C', 25, 1);
		dialog.listaddfield(vdialog, 'lstIn', 'FIO', 'C', 40, 1);
		dialog.setcaption(vdialog, 'lstIn', 'User~Name~');
	
		dummy := dialog.makemenusearch(vmenu, 'lstIn', NULL, FALSE);
	
		dialog.inputcheck(vdialog
						 ,'Active'
						 ,2
						 ,cdh - 1
						 ,plen => cdw - 3
						 ,pcaption => 'Active'
						 ,panchor => dialog.anchor_leftbottom);
		dialog.setreadonly(vdialog, 'Active', NOT ccanedit);
	
		dialog.button(vpage
					 ,'btnAdd'
					 ,cpw - 3 - cbw
					 ,3
					 ,cbw
					 ,'Add'
					 ,0
					 ,0
					 ,'Add operator to group'
					 ,cevent);
	
		dialog.setanchor(vpage, 'btnAdd', dialog.anchor_right + dialog.anchor_top);
		dialog.setenable(vpage, 'btnAdd', ccanedit);
	
		dialog.button(vpage
					 ,'btnRemove'
					 ,cpw - 3 - cbw
					 ,5
					 ,cbw
					 ,'Delete'
					 ,0
					 ,0
					 ,'Delete operator from group'
					 ,cevent);
	
		dialog.setenable(vpage, 'btnRemove', ccanedit);
		dialog.setanchor(vpage, 'btnRemove', dialog.anchor_right + dialog.anchor_top);
	
		vpage := dialog.page(vdialog, 'MainPageList', 'System');
		vi    := 2;
		dialog.inputchar(vpage, 'CreateBy', cft, vi, 30, '', pcaption => 'Created by:');
		dialog.setreadonly(vpage, 'CreateBy');
		vi := vi + 1;
		dialog.inputdate(vpage, 'Created', cft, vi, '', pcaption => 'Creation date:');
		dialog.setreadonly(vpage, 'Created');
		vi := vi + 1;
		dialog.inputchar(vpage, 'UpdateBy', cft, vi, 30, '', pcaption => 'Modified:');
		dialog.setreadonly(vpage, 'UpdateBy');
		vi := vi + 1;
		dialog.inputdate(vpage, 'Updated', cft, vi, '', pcaption => '    Change date:');
		dialog.setreadonly(vpage, 'Updated');
	
		dialog.button(vdialog
					 ,'btnSave'
					 ,cdw / 2 - 1 - cbw
					 ,cdh
					 ,cbw
					 ,'Enter'
					 ,dialog.cmok
					 ,0
					 ,'Save changes'
					 ,panchor => dialog.anchor_bottom);
		dialog.setenable(vdialog, 'btnSave', ccanedit);
		dialog.setdefault(vdialog, 'btnSave');
		dialog.button(vdialog
					 ,'btnCancel'
					 ,cdw / 2 + 1
					 ,cdh
					 ,cbw
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Exit without saving'
					 ,panchor => dialog.anchor_bottom);
	
		RETURN vdialog;
	END;

	PROCEDURE usergldialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		vid      NUMBER;
		vrow     tclerkgroup%ROWTYPE;
		vold     tclerkgroup%ROWTYPE;
		vclerkid NUMBER;
		PROCEDURE showmemolog IS
			PRAGMA AUTONOMOUS_TRANSACTION;
		BEGIN
			memo.showmemolist(object.gettype(group_object_name), vid);
			ROLLBACK;
		END;
	BEGIN
		vid := dialog.getnumber(pdialog, 'eGroupID');
		IF pwhat = dialog.wtdialogpre
		THEN
			SAVEPOINT sp_security_group;
			FOR i IN (SELECT *
					  FROM   tclerkgroup t
					  WHERE  t.branch = seance.getbranch
					  AND    t.id = vid)
			LOOP
				dialog.putchar(pdialog, 'eName', i.name);
				dialog.setaddinfo(pdialog, 'eName', i.name);
				dialog.putchar(pdialog, 'eRemark', i.remark);
				dialog.putdate(pdialog, 'StartDate', i.startdate);
				dialog.putdate(pdialog, 'EndDate', i.enddate);
				dialog.putbool(pdialog, 'Active', htools.i2b(i.active));
				dialog.putchar(pdialog, 'CreateBy', clerk.getclerkbycode(i.createby).name);
				dialog.putdate(pdialog, 'Created', i.created);
				dialog.putchar(pdialog, 'UpdateBy', clerk.getclerkbycode(i.modifyby).name);
				dialog.putdate(pdialog, 'Updated', i.modified);
				fillusersofgroup(pdialog, 'lstIn', i.id);
			END LOOP;
		
		ELSIF (pwhat = dialog.wtdialogvalid)
		THEN
			vrow.name      := TRIM(dialog.getchar(pdialog, 'eName'));
			vrow.remark    := TRIM(dialog.getchar(pdialog, 'eRemark'));
			vrow.active    := htools.b2i(dialog.getbool(pdialog, 'Active'));
			vrow.startdate := dialog.getdate(pdialog, 'StartDate');
			vrow.enddate   := dialog.getdate(pdialog, 'EndDate');
		
			IF NOT htools.equal(vrow.name, dialog.getaddinfo(pdialog, 'eName'), FALSE)
			   AND groupexists(vrow.name)
			THEN
				dialog.sethothint(pdialog, 'Group with such name already exists');
				dialog.goitem(pdialog, 'eName');
				RETURN;
			END IF;
			IF vrow.startdate > vrow.enddate
			THEN
				dialog.sethothint(pdialog, 'End date must not be less than start date');
				dialog.goitem(pdialog, 'EndDate');
				RETURN;
			END IF;
			SELECT *
			INTO   vold
			FROM   tclerkgroup
			WHERE  branch = seance.getbranch
			AND    id = vid;
		
			a4mlog.cleanplist;
			a4mlog.addparamrec('Name', vold.name, vrow.name);
			a4mlog.addparamrec('Comment', vold.remark, vrow.remark);
			a4mlog.addparamrec('Active', vold.active, vrow.active);
			a4mlog.addparamrec('Start date', vold.startdate, vrow.startdate);
			a4mlog.addparamrec('Expiration date', vold.enddate, vrow.enddate);
		
			a4mlog.logobject(object.gettype(group_object_name)
							,vid
							,'Modify group parameters "' || vold.name || '"'
							,a4mlog.act_change
							,a4mlog.putparamlist);
		
			UPDATE tclerkgroup
			SET    NAME      = vrow.name
				  ,remark    = vrow.remark
				  ,active    = vrow.active
				  ,startdate = vrow.startdate
				  ,enddate   = vrow.enddate
				  ,modifyby  = seance.getclerkcode
				  ,modified  = SYSDATE
			WHERE  branch = seance.getbranch
			AND    id = vid;
		
			COMMIT;
		
		ELSIF (pwhat = dialog.wtdialogpost)
		THEN
			IF (pcmd = dialog.cmcancel)
			THEN
				ROLLBACK TO sp_security_group;
			END IF;
		
		ELSIF (pwhat = dialog.wtitempre)
		THEN
			CASE pitemname
				WHEN upper('btnRemove') THEN
				
					vclerkid := dialog.getcurrentrecordnumber(pdialog, 'lstIn', 'CODE');
				
					IF htools.ask('Confirmation'
								 ,'Do you really want to delete operator "' || getuserinfo(vclerkid).name || '"' ||
								  chr(10) || 'from group "' || getgroupinfo(vid).name || '"?'
								 ,'Yes'
								 ,'No') = TRUE
					
					THEN
						removeclerkfromgroup(vclerkid, vid);
						fillusersofgroup(pdialog, 'lstIn', vid);
					END IF;
				
				WHEN upper('btnAdd') THEN
					IF (dialog.exec(selectclerksdialog()) = dialog.cmok)
					THEN
						FOR i IN 1 .. saclerk.count
						LOOP
							addclerkintogroup(saclerk(i), vid);
						END LOOP;
						fillusersofgroup(pdialog, 'lstIn', vid);
					END IF;
				
				WHEN upper('Log') THEN
					a4mlog.showlogbykey(object.gettype(group_object_name), vid);
				WHEN upper('Memo') THEN
					showmemolog;
				WHEN upper('mnuDelegate') THEN
					fillaccesstree();
					dialog.exec(accessdialog(0));
				
				ELSE
					NULL;
			END CASE;
		END IF;
	END;

	FUNCTION detaildialog RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.DetailDialog';
		cevent CONSTANT VARCHAR2(100) := cpackagename || '.DetailDialogHandler';
		vdialog NUMBER;
	
		vmenu NUMBER;
		cdialogwidth  CONSTANT NUMBER := 80;
		cdialogheight CONSTANT NUMBER := 20;
		cpagewidth    CONSTANT NUMBER := cdialogwidth - 2;
		cpageheight   CONSTANT NUMBER := cdialogheight - 6;
		cbutlen       CONSTANT NUMBER := 10;
		clistwidth    CONSTANT NUMBER := cpagewidth - 4 - 3 - cbutlen - 3;
		clistheight   CONSTANT NUMBER := cpageheight - 5;
		vpage NUMBER;
	
	BEGIN
	
		vdialog := dialog.new('Operator details'
							 ,0
							 ,0
							 ,cdialogwidth
							 ,cdialogheight
							 ,presizable => TRUE);
	
		dialog.setexternalid(vdialog, cwhere);
	
		dialog.inputchar(vdialog, 'UserName', 8, 2, 50, 'Operator name', 50, ' Login:');
	
		dialog.setitemattributies(vdialog, 'UserName', dialog.selectoff);
		dialog.putchar(vdialog, 'UserName', scurusername);
	
		dialog.inputchar(vdialog, 'UserFIO', 8, 3, 50, 'Operator name', 50, 'Name:');
		dialog.setitemattributies(vdialog, 'UserFIO', dialog.selectoff);
		dialog.putchar(vdialog, 'UserFIO', clerk.getclerkfio(scurusername));
	
		dialog.pagelist(vdialog, 'MainPageList', 1, 5, cpagewidth, cpageheight);
		dialog.setanchor(vdialog, 'MainPageList', dialog.anchor_all);
		vpage := dialog.page(vdialog, 'MainPageList', 'List of groups');
	
		dialog.list(vpage
				   ,'lstIn'
				   ,2
				   ,3
				   ,clistwidth
				   ,clistheight
				   ,'Groups where operator is included');
	
		vmenu := dialog.menu(vdialog);
		dummy := dialog.submenu(vmenu, 'Administration', '');
		dialog.setvisible(dummy, FALSE);
	
		dialog.menuitem(dummy
					   ,'mnuDelegate'
					   ,'List of allowed rights'
					   ,phint                   => 'Change list of allowed rights to delegate authority for managing subject rights'
					   ,phandler                => cevent);
		dialog.setvisible(vdialog, 'mnuDelegate', checkright(right_delegate));
		dummy := dialog.makemenusearch(vmenu, 'lstIn', NULL, FALSE);
		dialog.setanchor(vdialog, 'lstIn', dialog.anchor_all);
	
		dialog.listaddfield(vdialog, 'lstIn', 'CODE', 'N', 10, 0);
		dialog.listaddfield(vdialog, 'lstIn', 'NAME', 'C', 40, 1);
		dialog.setcaption(vdialog, 'lstIn', 'Name~');
	
		dialog.button(vpage
					 ,'btnAdd'
					 ,cpagewidth - 3 - cbutlen
					 ,3
					 ,cbutlen
					 ,'Add'
					 ,0
					 ,0
					 ,'Add operator to group'
					 ,cevent);
		dialog.setanchor(vpage, 'btnAdd', dialog.anchor_right + dialog.anchor_top);
		dialog.button(vpage
					 ,'btnRemove'
					 ,cpagewidth - 3 - cbutlen
					 ,5
					 ,cbutlen
					 ,'Delete'
					 ,0
					 ,0
					 ,'Delete operator from group'
					 ,cevent);
		dialog.setanchor(vpage, 'btnRemove', dialog.anchor_right + dialog.anchor_top);
		fillgroupsofuser(vdialog, 'lstIn', scuruserid);
	
		dialog.button(vdialog
					 ,'btnSave'
					 ,cdialogwidth / 2 - 1 - cbutlen
					 ,cdialogheight
					 ,cbutlen
					 ,'Enter'
					 ,dialog.cmok
					 ,0
					 ,'Save changes');
		dialog.setanchor(vdialog, 'btnSave', dialog.anchor_bottom);
	
		ktools.default_(vdialog, 'btnSave');
		IF isfullview
		   OR NOT checkright(right_modify)
		THEN
			dialog.setenable(vdialog, 'btnSave', FALSE);
			dialog.setenable(vdialog, 'btnAdd', FALSE);
			dialog.setenable(vdialog, 'btnRemove', FALSE);
		END IF;
	
		dialog.button(vdialog
					 ,'btnCancel'
					 ,cdialogwidth / 2 + 1
					 ,cdialogheight
					 ,cbutlen
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Exit without saving');
		dialog.setanchor(vdialog, 'btnCancel', dialog.anchor_bottom);
		dialog.setdialogvalid(vdialog, cevent);
		dialog.setdialogpost(vdialog, cevent);
	
		SAVEPOINT sp_security_group1;
	
		RETURN vdialog;
	END;

	PROCEDURE detaildialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
	BEGIN
		IF (pwhat = dialog.wtdialogvalid)
		THEN
			BEGIN
			
				COMMIT;
			EXCEPTION
				WHEN OTHERS THEN
					ktools.messagebox(SQLERRM, '!', TRUE);
			END;
		
		ELSIF (pwhat = dialog.wtdialogpost)
		THEN
			IF (pcmd = dialog.cmcancel)
			THEN
				ROLLBACK TO sp_security_group1;
			END IF;
		
		ELSIF (pwhat = dialog.wtitempre)
		THEN
			IF (pitemname = upper('btnRemove'))
			THEN
			
				DECLARE
					vgroupid NUMBER;
				BEGIN
					vgroupid := ktools.lasnumber(pdialog, 'lstIn', 'CODE');
					IF htools.ask('Confirmation'
								 ,'Do you really want to delete operator "' || getuserinfo(scuruserid).name || '"' ||
								  chr(10) || 'from group "' || getgroupinfo(vgroupid).name || '"?'
								 ,'Yes'
								 ,'No') = TRUE
					THEN
						removeclerkfromgroup(scuruserid, vgroupid);
						fillgroupsofuser(pdialog, 'lstIn', scuruserid);
					END IF;
				END;
			
			ELSIF (pitemname = upper('btnAdd'))
			THEN
				IF (dialog.exec(selectgroupsdialog()) = dialog.cmok)
				THEN
					FOR i IN 1 .. sagroup.count
					LOOP
						addclerkintogroup(scuruserid, sagroup(i));
					END LOOP;
					fillgroupsofuser(pdialog, 'lstIn', scuruserid);
				END IF;
			ELSIF pitemname = upper('mnuDelegate')
			THEN
				fillaccesstree();
				dialog.exec(accessdialog(0));
			END IF;
		END IF;
	END;

	FUNCTION propertydialog RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.PropertyDialog';
		cevent CONSTANT VARCHAR2(100) := cpackagename || '.PropertyDialogHandler';
	
		vdialog NUMBER;
		cdialogwidth  CONSTANT NUMBER := 60;
		cdialogheight CONSTANT NUMBER := 5;
		cbutlen       CONSTANT NUMBER := 10;
	BEGIN
		vdialog := dialog.new('Viewing parameters', 0, 0, cdialogwidth, cdialogheight);
		dialog.setexternalid(vdialog, cwhere);
	
		dialog.inputcheck(vdialog
						 ,'chViewParam'
						 ,4
						 ,2
						 ,60
						 ,'Restrict number of rights displayed in branches'
						 ,'Restrict number of rights displayed in branches');
	
		dialog.button(vdialog
					 ,'btnSave'
					 ,cdialogwidth / 2 - 1 - cbutlen
					 ,cdialogheight
					 ,cbutlen
					 ,'Enter'
					 ,dialog.cmok
					 ,0
					 ,'Save changes');
		dialog.button(vdialog
					 ,'btnCancel'
					 ,cdialogwidth / 2 + 1
					 ,cdialogheight
					 ,cbutlen
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Exit without saving');
		ktools.default_(vdialog, 'btnSave');
	
		dialog.setdialogpre(vdialog, cevent);
		dialog.setdialogvalid(vdialog, cevent);
		dialog.setdialogpost(vdialog, cevent);
	
		RETURN vdialog;
	END;

	PROCEDURE propertydialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.PropertyDialogHandler';
		vflaglimitedview BOOLEAN;
	BEGIN
		IF (pwhat = dialog.wtdialogpre)
		THEN
			vflaglimitedview := getflaglimitedview();
			s.say(cwhere || ' vFlagLimitedView=' || htools.b2s(vflaglimitedview));
			dialog.putbool(pdialog, 'chViewParam', vflaglimitedview);
		
		ELSIF (pwhat = dialog.wtdialogvalid)
		THEN
			BEGIN
				vflaglimitedview := dialog.getbool(pdialog, 'chViewParam');
				s.say(cwhere || ' vFlagLimitedView=' || htools.b2s(vflaglimitedview));
				htools.setcfg_bool(ccfg_view_curr_treebranch, vflaglimitedview);
				satree.delete;
				saccesstree.delete;
				sbasetree.delete;
				COMMIT;
			EXCEPTION
				WHEN OTHERS THEN
					ktools.messagebox(SQLERRM, '!', TRUE);
			END;
		END IF;
	END;

	FUNCTION thisobjectgranted(pobjid IN NUMBER) RETURN BOOLEAN IS
		CURSOR vcursor IS
			SELECT accesskey
			FROM   trights
			WHERE  branch = seance.getbranch
			AND    userid = scuruserid
			AND    usertype = scurusertype
			AND    objectid = pobjid;
	
		CURSOR vcursora IS
			SELECT accesskey
			FROM   taccessrights
			WHERE  branch = seance.getbranch
			AND    userid = scuruserid
			AND    usertype = scurusertype
			AND    objectid = pobjid;
	BEGIN
		IF streemode = ctree_access
		THEN
			FOR i IN vcursora
			LOOP
				RETURN TRUE;
			END LOOP;
		ELSE
			FOR i IN vcursor
			LOOP
				RETURN TRUE;
			END LOOP;
		END IF;
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN FALSE;
	END;

	PROCEDURE filluserlist(pdialog IN NUMBER) IS
	BEGIN
		dialog.listclear(pdialog, 'lstUsers');
		snumusers := 0;
		FOR i IN (SELECT c.code
						,c.name
						,cp.fio
				  FROM   tclerk c
				  LEFT   OUTER JOIN tclientpersone cp
				  ON     cp.branch = c.branch
				  AND    cp.idclient = c.clerkid, all_users au
				  WHERE  c.branch = seance.getbranch
				  AND    c.type = clerk.cctactive
				  AND    au.username = c.name
				  ORDER  BY c.name)
		LOOP
			dialog.listaddrecord(pdialog
								,'lstUsers'
								,to_char(i.code) || '~' || i.name || '~' || i.fio || '~');
			snumusers := snumusers + 1;
		END LOOP;
		dialog.setenable(pdialog, 'btnDetail', snumusers > 0);
	END;

	PROCEDURE fillgrouplist(pdialog IN NUMBER) IS
		vid NUMBER;
	BEGIN
		dialog.listclear(pdialog, 'lstGroups');
		snumgroups := 0;
		FOR i IN (SELECT * FROM tclerkgroup WHERE branch = seance.getbranch ORDER BY NAME)
		LOOP
			IF isfullview
			   OR checkright2group(right_group_modify, i.id)
			   OR checkright2group(right_grant_group, i.id)
			THEN
				dialog.listaddrecord(pdialog
									,'lstGroups'
									,i.id || '~' ||
									 service.iif(i.active = 1 AND
												 (SYSDATE BETWEEN nvl(i.startdate, SYSDATE) AND
												 nvl(i.enddate, SYSDATE))
												,'*'
												,'') || '~' || i.name || '~' || i.remark || '~');
			
				snumgroups := snumgroups + 1;
				IF snumgroups = 1
				THEN
					vid := i.id;
				END IF;
			END IF;
		END LOOP;
		dialog.setcurrec(pdialog, 'lstGroups', 1);
	
		dialog.setenable(pdialog, 'btnAdd', (checkright(right_group_create) AND NOT isfullview));
		dialog.setenable(pdialog
						,'btnDelete'
						,(snumgroups > 0) AND (checkright(right_group_delete) AND NOT isfullview));
		dialog.setenable(pdialog
						,'btnContain'
						,(snumgroups > 0) AND
						 (checkright2group(right_group_modify, vid) OR isfullview));
		dialog.setenable(pdialog
						,'btnGrant'
						,(snumgroups > 0) AND
						 (checkright2group(right_grant_group, vid) OR isfullview));
	
	END;

	PROCEDURE filluserglist(pdialog IN NUMBER) IS
	BEGIN
		dialog.listclear(pdialog, 'lstUserGIn');
		dialog.listclear(pdialog, 'lstUserGNotIn');
	
		FOR i IN (SELECT cl.code
						,cl.name
						,cp.fio
						,gr.groupid
				  FROM   tclerk cl
				  LEFT   OUTER JOIN tclientpersone cp
				  ON     cp.branch = cl.branch
				  AND    cp.idclient = cl.clerkid
				  LEFT   OUTER JOIN tclerk2group gr
				  ON     gr.branch = cl.branch
				  AND    gr.clerkid = cl.code
				  AND    gr.groupid = scurgroupid, all_users au
				  WHERE  cl.branch = seance.getbranch
				  AND    cl.type = clerk.cctactive
				  AND    au.username = cl.name
				  ORDER  BY cl.name)
		LOOP
			IF i.groupid IS NULL
			THEN
				dialog.listaddrecord(pdialog
									,'lstUserGNotIn'
									,to_char(i.code) || '~' || i.name || '~' || i.fio || '~');
			ELSE
				dialog.listaddrecord(pdialog
									,'lstUserGIn'
									,to_char(i.code) || '~' || i.name || '~' || i.fio || '~');
			END IF;
		END LOOP;
	
	END;

	FUNCTION existsingroup
	(
		pclerkcode IN NUMBER
	   ,pgroupid   IN NUMBER
	) RETURN BOOLEAN IS
		CURSOR vcur IS
			SELECT *
			FROM   tclerk2group
			WHERE  branch = seance.getbranch
			AND    clerkid = pclerkcode
			AND    groupid = pgroupid;
	BEGIN
		FOR i IN vcur
		LOOP
			RETURN TRUE;
		END LOOP;
		RETURN FALSE;
	END;

	PROCEDURE fillavailuserlist(pdialog IN NUMBER) IS
	BEGIN
		dialog.listclear(pdialog, 'lstAvailUsers');
		FOR i IN (SELECT cl.code
						,cl.name
						,cp.fio
				  FROM   tclerk cl
				  LEFT   OUTER JOIN tclientpersone cp
				  ON     cp.branch = cl.branch
				  AND    cp.idclient = cl.clerkid, all_users au
				  WHERE  cl.branch = seance.getbranch
				  AND    cl.type = clerk.cctactive
				  AND    au.username = cl.name
				  AND    NOT EXISTS (SELECT 1
						  FROM   tclerk2group gr
						  WHERE  gr.branch = cl.branch
						  AND    gr.clerkid = cl.code
						  AND    gr.groupid = scurgroupid)
				  ORDER  BY cl.name)
		LOOP
			dialog.listaddrecord(pdialog
								,'lstAvailUsers'
								,' ~' || i.code || '~' || i.name || '~' || i.fio || '~');
		END LOOP;
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

	FUNCTION getcharmark(pstate IN NUMBER) RETURN VARCHAR IS
	BEGIN
		RETURN CASE pstate WHEN cstate_check THEN '1' WHEN cstate_uncheck THEN ' ' WHEN cstate_checkall THEN '1' ELSE '2' END;
	END;

	FUNCTION getstatebychar(pchar IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF (pchar = '1')
		THEN
			RETURN cbchecked;
		ELSIF (pchar = ' ')
		THEN
			RETURN cbunchecked;
		ELSE
			RETURN cbgrayed;
		END IF;
	END;

	FUNCTION groupexists(pgname IN VARCHAR) RETURN BOOLEAN IS
		CURSOR vcur IS
			SELECT *
			FROM   tclerkgroup
			WHERE  branch = seance.getbranch
			AND    NAME = pgname;
	BEGIN
		FOR i IN vcur
		LOOP
			RETURN TRUE;
		END LOOP;
		RETURN FALSE;
	END;

	PROCEDURE deleteuserfromgroup
	(
		puserid  NUMBER
	   ,pgroupid NUMBER
	) IS
	BEGIN
		DELETE FROM tclerk2group
		WHERE  branch = seance.getbranch
		AND    groupid = pgroupid
		AND    clerkid = puserid;
	END;

	PROCEDURE insertuserintocurrentgroup(puserid IN NUMBER) IS
	BEGIN
		insertuserintogroup(puserid, scurgroupid);
	END;

	PROCEDURE insertuserintogroup
	(
		puserid  NUMBER
	   ,pgroupid NUMBER
	) IS
	BEGIN
		INSERT INTO tclerk2group
		VALUES
			(seance.getbranch
			,puserid
			,pgroupid);
	END;

	FUNCTION hasmarked
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	) RETURN BOOLEAN IS
	BEGIN
		FOR i IN 1 .. dialog.getlistreccount(pdialog, pitemname)
		LOOP
			IF (dialog.getrecordchar(pdialog, pitemname, 'CHECK', i) = '+')
			THEN
				RETURN TRUE;
			END IF;
		END LOOP;
		RETURN FALSE;
	END;

	FUNCTION getposofcode
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcode     IN NUMBER
	) RETURN NUMBER IS
		vcount NUMBER;
	BEGIN
		vcount := 1;
		FOR i IN 1 .. dialog.getlistreccount(pdialog, pitemname)
		LOOP
			IF (dialog.getrecordnumber(pdialog, pitemname, 'ID', i) = pcode)
			THEN
				RETURN vcount;
			END IF;
			vcount := vcount + 1;
		END LOOP;
		RETURN 1;
	END;

	PROCEDURE clearsiarrays IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.ClearSIArrays';
	BEGIN
	
		slastsisize := 0;
		slastsicode.delete();
		slastsitext.delete();
		slastsifin.delete();
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE fillsecurityinfobyfunc
	(
		pnode           IN apitypes.typesecurnode
	   ,psearchmode     BOOLEAN := FALSE
	   ,psearchtemplate VARCHAR := NULL
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.FillSecurityInfoByFunc';
		vaarray          custom_security.typerights;
		vsql             VARCHAR(250);
		vstr             VARCHAR(250);
		vflaglimitedview BOOLEAN := getflaglimitedview();
		vcountnode       NUMBER;
		vpackagename     VARCHAR2(500);
	BEGIN
		s.say(cwhere || ' start for ' || pnode.id);
		s.say(cwhere || ' vFlagLimitedView=' || htools.b2s(vflaglimitedview));
	
		IF (vflaglimitedview)
		THEN
			vcountnode := cmaxcountnode;
		END IF;
	
		s.say(cwhere || ' vCountNode=' || vcountnode);
		s.say(cwhere || ' sCurObjectIndex=' || scurobjectindex);
	
		vpackagename := saobjectinfo(scurobjectindex).packagename;
		s.say(cwhere || ' PackageName=' || vpackagename);
	
		starttimer(csubsystemid);
	
		BEGIN
			IF (pnode.level = 0)
			THEN
				vsql := 'begin :vaArray := ' || vpackagename ||
						'.GetSecurityArray(1, null, :vCountNode, :pSearchTemplate); end;';
				EXECUTE IMMEDIATE vsql
					USING OUT vaarray, vcountnode, psearchtemplate;
			ELSE
				vsql := 'begin :vaArray := ' || vpackagename ||
						'.GetSecurityArray(:pLevel, :pKey, :vCountNode, :pSearchTemplate); end;';
				EXECUTE IMMEDIATE vsql
					USING OUT vaarray, pnode.level + 1, pnode.key, vcountnode, psearchtemplate;
			END IF;
		
			IF NOT psearchmode
			THEN
				vsql := 'begin ' || vpackagename || '.CloseSecurityCursors(); end;';
				EXECUTE IMMEDIATE vsql;
			END IF;
		
		EXCEPTION
			WHEN OTHERS THEN
				s.say(cwhere || ' : ' || SQLERRM, 0);
				IF (pnode.level = 0)
				THEN
					vstr := 'Parameters: 1, null';
				ELSE
					vstr := 'Parameters: ' || (pnode.level + 1) || ', ' || pnode.key;
				END IF;
			
				s.err('Failed attempt to get data:~' || saobjectinfo(scurobjectindex).packagename ||
					  '.GetSecurityArray~' || vstr
					 ,'Warning!');
				RAISE;
		END;
	
		stoptimer(csubsystemid);
	
		s.say(cwhere || ' vaArray.count =' || vaarray.count);
	
		starttimer(csubsystemdata);
	
		IF (vaarray.count > 0)
		THEN
			FOR i IN 1 .. vaarray.count
			LOOP
				s.say(cwhere || ' vaArray(' || i || ') Key=' || vaarray(i).key || ' Text=' || vaarray(i).text ||
					  ' Final=' || htools.b2s(vaarray(i).final));
				addrecord(vaarray(i).key, vaarray(i).text, vaarray(i).final);
			END LOOP;
		
			slastsisize := sarraysize;
			--slastsicode := scodearray;
			--slastsitext := stextarray;
			slastsifin := sfinarray;
		ELSE
			sbasetree(pnode.id).subnodes := cnode_leaf;
			clearsiarrays();
		END IF;
	
		stoptimer(csubsystemdata);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE fillsecurityinfofor(pnode IN apitypes.typesecurnode) IS
		vparse VARCHAR(250);
		vcur   NUMBER;
		vstr   VARCHAR(250);
	BEGIN
		cleararray;
	
		/*IF (pnode.isfunction)
        THEN
            fillsecurityinfobyfunc(pnode);
            RETURN;
        END IF;*/
	
		IF (pnode.level = 0)
		THEN
			vparse := 'begin ' || saobjectinfo(scurobjectindex).packagename ||
					  '.FillSecurityArray(1,Null); end;';
		ELSE
		
			vparse := 'begin ' || saobjectinfo(scurobjectindex).packagename ||
					  '.FillSecurityArray(:pLevel,:pKey); end;';
		
		END IF;
	
		vcur := dbms_sql.open_cursor;
	
		BEGIN
			dbms_sql.parse(vcur, vparse, dbms_sql.v7);
		
			IF (pnode.level != 0)
			THEN
				dbms_sql.bind_variable(vcur, ':pLevel', pnode.level + 1);
				dbms_sql.bind_variable(vcur, ':pKey', pnode.key, types.cmaxlenchar);
			END IF;
		
			dummy := dbms_sql.execute(vcur);
		EXCEPTION
			WHEN OTHERS THEN
				dbms_sql.close_cursor(vcur);
				s.say('FillSecurityInfoFor: ' || SQLERRM, 0);
			
				IF (error.getcode() != custom_err.ue_module_not_supported)
				THEN
					IF (pnode.level = 0)
					THEN
						vstr := 'Parameters: 1,Null';
					ELSE
						vstr := 'Parameters: ' || (pnode.level + 1) || ', ' || pnode.key;
					END IF;
					ktools.messagebox('Failed attempt to get data:~' || saobjectinfo(scurobjectindex)
									  .packagename || '.FillSecurityArray~' || vstr
									 ,'Warning!'
									 ,TRUE);
				END IF;
			
				clearsiarrays();
			
				RETURN;
		END;
	
		dbms_sql.close_cursor(vcur);
		--   slastsisize := sarraysize;
		--slastsicode := scodearray;
		--   slastsitext := stextarray;
		--   slastsifin  := sfinarray;
	END;

	FUNCTION getnode(pnodeid IN NUMBER) RETURN apitypes.typesecurnode IS
		vnode apitypes.typesecurnode;
	BEGIN
		vnode.id       := pnodeid;
		vnode.parentid := 0;
		FOR i IN 1 .. satree.count
		LOOP
			IF (satree(i).id = pnodeid)
			THEN
				RETURN(satree(i));
			END IF;
		END LOOP;
		RETURN vnode;
	END;

	PROCEDURE revokeallright(pclerkid IN NUMBER) IS
	BEGIN
		err.seterror(0, cpackagename || '.RevokeAllRight');
		SAVEPOINT pdel;
		DELETE FROM tclerk2group
		WHERE  branch = seance.getbranch
		AND    clerkid = pclerkid;
		DELETE FROM trights
		WHERE  branch = seance.getbranch
		AND    userid = pclerkid
		AND    usertype = ot_user;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cpackagename || '.RevokeAllRight');
			ROLLBACK TO pdel;
	END;

	PROCEDURE revokerightfromall
	(
		pobject       IN VARCHAR
	   ,pkey          IN VARCHAR
	   ,pincludechild BOOLEAN := FALSE
	) IS
	
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.RevokeRightFromAll';
		vkey VARCHAR(32767);
	BEGIN
		err.seterror(0, cwhere);
		vkey := nvl(pkey, cnull);
	
		SAVEPOINT pdel;
	
		DELETE FROM trights
		WHERE  branch = seance.getbranch
		AND    objectid = sacashobjectid(pobject)
		AND    accesskey = pkey;
	
		a4mlog.logobject(object.gettype(object_name)
						,4
						,premark => 'Delete right of object ' || pobject || ' : ' || pkey ||
									'. Deleted rights ' || SQL%ROWCOUNT || ' .'
						,paction => a4mlog.act_del);
	
		IF pincludechild
		THEN
		
			vkey := vkey || CASE vkey LIKE '%|'
						WHEN TRUE THEN
						 '%'
						ELSE
						 '|%'
					END;
		
			DELETE FROM trights
			WHERE  branch = seance.getbranch
			AND    objectid = sacashobjectid(pobject)
			AND    accesskey LIKE vkey;
		
			a4mlog.logobject(object.gettype(object_name)
							,4
							,premark => 'Delete object subsidiary rights ' || pobject || ' : ' || pkey ||
										'. Deleted rights ' || SQL%ROWCOUNT || ' .'
							,paction => a4mlog.act_del);
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			ROLLBACK TO pdel;
	END;

	PROCEDURE logaction
	(
		paction IN NUMBER
	   ,pnode   IN apitypes.typesecurnode
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.LogAction';
		vlogaction VARCHAR(50);
		vloginfo   VARCHAR(32000);
		vtext      VARCHAR(32000);
		vnode      apitypes.typesecurnode;
		vaction    NUMBER;
		vparam     VARCHAR(32000) := 'Right';
	BEGIN
		timer.start_(cwhere);
		CASE paction
			WHEN caaddgrants THEN
				vlogaction := 'Add rights';
				vaction    := a4mlog.act_add;
			WHEN cadropgrants THEN
				vlogaction := 'Delete rights';
				vaction    := a4mlog.act_del;
			WHEN caaddaccess THEN
				vlogaction := 'Add access to assign right';
				vaction    := a4mlog.act_add;
				vparam     := 'AccessRight';
			WHEN cadropaccess THEN
				vlogaction := 'Block access to assign right';
				vaction    := a4mlog.act_del;
				vparam     := 'AccessRight';
			ELSE
				NULL;
		END CASE;
	
		a4mlog.cleanplist;
		IF (scurusertype = ot_user)
		THEN
			vloginfo := 'For ';
			a4mlog.addparamrec('User', scurusername);
		ELSE
			vloginfo := 'For group';
			a4mlog.addparamrec('Group', scurusername);
		END IF;
		vloginfo := vloginfo || scurusername || ' ';
	
		vnode := pnode;
		vtext := '';
		WHILE (vnode.parentid != 0)
		LOOP
			vtext := '|' || vnode.text || vtext;
			vnode := getnode(vnode.parentid);
			IF length(vtext) > 4000
			THEN
				EXIT;
			END IF;
		END LOOP;
		vtext := '|' || vnode.text || vtext || '|';
	
		vloginfo := vloginfo || vtext;
	
		a4mlog.addparamrec(vparam, substr(vtext, 1, 4000));
	
		a4mlog.logobject(object.gettype('SECURITY')
						,vlogaction
						,substr(vloginfo, 1, 1024)
						,vaction
						,a4mlog.putparamlist);
		timer.stop_(cwhere);
	EXCEPTION
		WHEN OTHERS THEN
			error.save('LogAction');
			RAISE;
	END;

	FUNCTION getsubnodedtext
	(
		ptext     IN VARCHAR
	   ,psubnodes IN INTEGER
	) RETURN VARCHAR IS
		vstr VARCHAR(1024);
	BEGIN
		vstr := ptext;
		IF (psubnodes != 0)
		THEN
			vstr := vstr || ' [' || psubnodes || ']';
		END IF;
		RETURN vstr;
	END;

	PROCEDURE makeuser2groupitem
	(
		puser    NUMBER
	   ,pdialog  NUMBER
	   ,pitem    VARCHAR
	   ,px       INTEGER
	   ,py       INTEGER
	   ,pw       INTEGER
	   ,ph       INTEGER
	   ,pcaption VARCHAR
	) IS
		CURSOR vcur IS
			SELECT * FROM tclerkgroup WHERE branch = seance.getbranch ORDER BY NAME;
	
		vitem VARCHAR(1000);
		cbw CONSTANT NUMBER := 10;
	BEGIN
	
		vitem := cpackagename || '.lstGroup';
	
		dialog.list(pdialog
				   ,vitem
				   ,px
				   ,py
				   ,pw - 2 - cbw - 2
				   ,ph
				   ,'Groups where operator is included'
				   ,panchor => dialog.anchor_all);
	
		dialog.listaddfield(pdialog, vitem, 'CODE', 'N', 10, 0);
		dialog.listaddfield(pdialog, vitem, 'NAME', 'C', 40, 1);
		dialog.setcaption(pdialog, vitem, 'Name~');
		dialog.setaddinfo(pdialog, vitem, puser);
	
		dialog.button(pdialog
					 ,cpackagename || '.btnAdd'
					 ,px + pw - 1 - cbw
					 ,py + 3
					 ,cbw
					 ,'Add'
					 ,0
					 ,0
					 ,'Add operator to group'
					 ,phandler => cpackagename || '.User2GroupHandler'
					 ,panchor => dialog.anchor_right + dialog.anchor_top);
		dialog.button(pdialog
					 ,cpackagename || '.btnRemove'
					 ,px + pw - 1 - cbw
					 ,py + 5
					 ,cbw
					 ,'Delete'
					 ,0
					 ,0
					 ,'Delete operator from group'
					 ,phandler => cpackagename || '.User2GroupHandler'
					 ,panchor => dialog.anchor_right + dialog.anchor_top);
	
		fillgroupsofuser(pdialog, cpackagename || '.lstGroup', puser, cpackagename || '.btnRemove');
	
	END;

	PROCEDURE user2grouphandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		vuserid NUMBER;
		cgroupname CONSTANT VARCHAR(100) := cpackagename || '.lstGroup';
	BEGIN
		vuserid := dialog.getaddinfo(pdialog, cgroupname);
		s.say(cpackagename || '.User2GroupHandler (what ' || pwhat || ', Item = ' || pitemname ||
			  ' start ');
		IF (pwhat = dialog.wtitempre)
		THEN
			CASE pitemname
				WHEN upper(cpackagename || '.btnRemove') THEN
					DECLARE
						vgroupid NUMBER;
					BEGIN
						vgroupid := dialog.getcurrentrecordnumber(pdialog, cgroupname, 'CODE');
					
						IF htools.ask('Confirmation'
									 ,'Do you really want to delete operator "' || getuserinfo(vuserid).name || '"' ||
									  chr(10) || 'from group "' || getgroupinfo(vgroupid).name || '"?'
									 ,'Yes'
									 ,'No')
						
						THEN
							removeclerkfromgroup(vuserid, vgroupid);
							fillgroupsofuser(pdialog
											,cgroupname
											,vuserid
											,cpackagename || '.btnRemove');
						END IF;
					END;
				WHEN upper(cpackagename || '.btnAdd') THEN
					scuruserid := vuserid;
					IF (dialog.exec(selectgroupsdialog()) = dialog.cmok)
					THEN
						FOR i IN 1 .. sagroup.count
						LOOP
							addclerkintogroup(vuserid, sagroup(i));
						END LOOP;
						fillgroupsofuser(pdialog, cgroupname, scuruserid);
					END IF;
				ELSE
					NULL;
			END CASE;
			dialog.setenable(pdialog
							,cpackagename || '.btnRemove'
							,dialog.getlistreccount(pdialog, cgroupname) > 0);
		END IF;
	END;

	PROCEDURE makegroupofuseritem
	(
		pgroupid NUMBER
	   ,pdialog  NUMBER
	   ,pitem    VARCHAR
	   ,px       INTEGER
	   ,py       INTEGER
	   ,pw       INTEGER
	   ,ph       INTEGER
	) IS
		CURSOR vcur IS
			SELECT * FROM tclerk c WHERE c.branch = seance.getbranch ORDER BY NAME;
		vmark VARCHAR(256);
	BEGIN
	
		dialog.checkbox(pdialog, pitem, px, py, pw, ph, '', panchor => dialog.anchor_all);
		dialog.listaddfield(pdialog, pitem, 'NAME', 'C', 10, 1);
		dialog.listaddfield(pdialog, pitem, 'FIO', 'C', 40, 1);
		dialog.setcaption(pdialog, pitem, '~User~Name');
	
		dialog.listclear(pdialog, pitem);
		vmark := '';
		saclerk.delete;
	
		FOR i IN vcur
		LOOP
			IF (clerkvalid(i.code))
			THEN
				saclerk(saclerk.count + 1) := i.code;
				ktools.ladd(pdialog
						   ,pitem
						   ,i.name || '~' || clerk.getclerkfio(clerk.getnamebycode(i.code)) || '~');
				vmark := vmark || service.iif(existsingroup(i.code, pgroupid), '1', '0');
			END IF;
		END LOOP;
	
		dialog.putchar(pdialog, pitem, vmark);
	END;

	PROCEDURE savegroupofuseritem
	(
		pgroupid NUMBER
	   ,pdialog  NUMBER
	   ,pitem    VARCHAR
	   ,pcommit  BOOLEAN
	) IS
	
	BEGIN
	
		FOR i IN 1 .. saclerk.count
		LOOP
		
			IF (dialog.getbool(pdialog, pitem, i))
			THEN
				IF (NOT existsingroup(saclerk(i), pgroupid))
				THEN
					insertuserintogroup(saclerk(i), pgroupid);
				END IF;
			ELSE
				IF (existsingroup(saclerk(i), pgroupid))
				THEN
					deleteuserfromgroup(saclerk(i), pgroupid);
				END IF;
			END IF;
		END LOOP;
		IF (pcommit)
		THEN
			COMMIT;
		END IF;
	END;

	FUNCTION clerkvalid(pcode NUMBER) RETURN BOOLEAN IS
		vdropped NUMBER;
	BEGIN
		SELECT TYPE
		INTO   vdropped
		FROM   tclerk
		WHERE  branch = seance.getbranch
		AND    code = pcode;
		RETURN(vdropped = 0);
	EXCEPTION
		WHEN OTHERS THEN
			RETURN TRUE;
	END;

	PROCEDURE fillusersofgroup
	(
		pdialog  NUMBER
	   ,plist    VARCHAR
	   ,pgroupid NUMBER
	) IS
	
		CURSOR vcur IS
			SELECT c.code
				  ,c.name
			FROM   tclerk2group g
				  ,tclerk       c
			WHERE  g.branch = seance.getbranch
			AND    g.groupid = pgroupid
			AND    c.branch = g.branch
			AND    c.code = g.clerkid
			ORDER  BY c.name;
		vpos NUMBER;
		ccanedit CONSTANT BOOLEAN := NOT isfullview AND
									 checkright2group(right_group_modify, pgroupid);
	BEGIN
		vpos := ktools.lselected(pdialog, plist);
		ktools.lclear(pdialog, plist);
	
		FOR i IN vcur
		LOOP
			IF (clerkvalid(i.code))
			THEN
				ktools.ladd(pdialog
						   ,plist
						   ,i.code || '~' || i.name || '~' ||
							clerk.getclerkfio(clerk.getnamebycode(i.code)) || '~');
			END IF;
		END LOOP;
	
		ktools.lselect(pdialog, plist, vpos);
	
		ktools.enable(pdialog
					 ,'btnRemove'
					 ,ccanedit AND (dialog.getlistreccount(pdialog, plist) != 0));
		ktools.setfocus(pdialog, plist);
	END;

	PROCEDURE fillgroupsofuser
	(
		pdialog       NUMBER
	   ,plist         VARCHAR
	   ,pclerkid      NUMBER
	   ,pbuttonremove VARCHAR := 'btnRemove'
	) IS
		vpos NUMBER;
	BEGIN
		vpos := dialog. getcurrec(pdialog, plist);
		dialog.listclear(pdialog, plist);
		FOR i IN (SELECT c2g.groupid
						,g.name
				  FROM   tclerk2group c2g
						,tclerkgroup  g
				  WHERE  c2g.branch = seance.getbranch
				  AND    c2g.clerkid = pclerkid
				  AND    g.branch = c2g.branch
				  AND    g.id = c2g.groupid
				  ORDER  BY g.name)
		LOOP
			dialog.listaddrecord(pdialog, plist, i.groupid || '~' || i.name || '~');
		END LOOP;
		dialog.setcurrec(pdialog, plist, vpos);
	
		dialog.setenable(pdialog, pbuttonremove, dialog.getlistreccount(pdialog, plist) > 0);
		dialog.goitem(pdialog, plist);
	END;

	FUNCTION selectclerksdialog RETURN NUMBER IS
		vdlg  NUMBER;
		vmenu NUMBER;
		cdw    CONSTANT NUMBER := 80;
		cdh    CONSTANT NUMBER := 22;
		cbw    CONSTANT NUMBER := 10;
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.SelectClerksDialog';
		cevent CONSTANT VARCHAR2(100) := cpackagename || '.SelectClerksDialogHandler';
		vi NUMBER;
	BEGIN
	
		vdlg := dialog.new('Add operator to group "' || scurgroupname || '"'
						  ,0
						  ,0
						  ,cdw
						  ,cdh
						  ,presizable => TRUE);
	
		dialog.setexternalid(vdlg, cwhere);
		dialog.setdialogpre(vdlg, cevent);
		dialog.setdialogvalid(vdlg, cevent);
	
		vi := 1;
		dialog.bevel(vdlg
					,1
					,vi
					,cdw - 1
					,4
					,pshape => dialog.bevel_frame
					,pcaption => 'Display settings'
					,panchor => dialog.anchor_all - dialog.anchor_bottom);
		vi := vi + 1;
	
		dialog.inputchar(vdlg
						,'FIO'
						,10
						,vi
						,50
						,phint    => 'Specify part of operator name (in Oracle notation)'
						,pcaption => 'Name:');
	
		dialog.inputchar(vdlg
						,'User'
						,10
						,vi + 2
						,30
						,phint => 'Specify part of operator name (in Oracle notation)'
						,pcaption => ' User:');
	
		dialog.button(vdlg
					 ,'Find'
					 ,cdw - cbw - 2
					 ,2
					 ,cbw
					 ,'Apply'
					 ,0
					 ,0
					 ,'Apply current display settings'
					 ,phandler => cevent
					 ,panchor => dialog.anchor_right + dialog.anchor_top);
		vi := vi + 1;
		vi := vi + 1;
		dialog.button(vdlg
					 ,'Clear'
					 ,cdw - 2 - cbw
					 ,vi
					 ,cbw
					 ,'Clear'
					 ,phint => 'Reset display settings to display all operators'
					 ,phandler => cevent
					 ,panchor => dialog.anchor_right + dialog.anchor_top);
	
		vi := vi + 1;
		vi := vi + 1;
	
		dialog.checkbox(vdlg
					   ,'cbClerks'
					   ,2
					   ,vi
					   ,cdw - 5
					   ,cdh - 2 - vi
					   ,'List of operators'
					   ,panchor => dialog.anchor_all
					   ,pusebottompanel => TRUE);
		dialog.listaddfield(vdlg, 'cbClerks', 'CODE', 'N', 10, 0);
		dialog.listaddfield(vdlg, 'cbClerks', 'NAME', 'C', 20, 1);
		dialog.listaddfield(vdlg, 'cbClerks', 'FIO', 'C', 40, 1);
		dialog.setcaption(vdlg, 'cbClerks', '~User~Name');
	
		vmenu := dialog.menu(vdlg);
		dummy := dialog.makemenusearch(vmenu, 'cbClerks', NULL, FALSE);
	
		dialog.button(vdlg
					 ,'btnOk'
					 ,cdw / 2 - 1 - cbw
					 ,cdh
					 ,cbw
					 ,'Enter'
					 ,dialog.cmok
					 ,0
					 ,'Save changes'
					 ,panchor => dialog.anchor_bottom);
		dialog.setdefault(vdlg, 'btnOk');
	
		dialog.button(vdlg
					 ,'btnCancel'
					 ,cdw / 2 + 1
					 ,cdh
					 ,cbw
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Exit without saving'
					 ,panchor => dialog.anchor_bottom);
	
		RETURN vdlg;
	END;

	PROCEDURE selectclerksdialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cwhere CONSTANT VARCHAR(1000) := cpackagename || '.SelectClerksDialogHandler()';
		PROCEDURE refresh IS
			vdlg       NUMBER := pdialog;
			vcond_fio  VARCHAR(1000);
			vcond_user VARCHAR(1000);
			vcount     NUMBER;
		BEGIN
			vcond_fio  := REPLACE(upper(dialog.getchar(vdlg, 'FIO')) || '%', '%%', '%');
			vcond_user := REPLACE(upper(dialog.getchar(vdlg, 'User')) || '%', '%%', '%');
			s.say('vCond_FIO = ' || vcond_fio);
			s.say('vCond_user = ' || vcond_user);
			dialog.listclear(vdlg, 'cbClerks');
		
			vcount := 0;
			FOR i IN (SELECT c.code
							,c.name
							,p.fio
					  FROM   tclerk c
					  LEFT   JOIN tclientpersone p
					  ON     p.branch = c.branch
					  AND    p.idclient = c.clerkid
					  WHERE  c.branch = seance.getbranch
					  AND    c.type = 0
					  AND    NOT EXISTS (SELECT branch
							  FROM   tclerk2group
							  WHERE  branch = c.branch
							  AND    clerkid = c.code
							  AND    groupid = scurgroupid)
					  AND    c.name LIKE vcond_user
					  AND    p.fio LIKE vcond_fio
					  ORDER  BY NAME)
			LOOP
				s.say(i.code || '~' || i.name || '~' || i.fio || '~');
				dialog.listaddrecord(vdlg
									,'cbClerks'
									,i.code || '~' || i.name || '~' || i.fio || '~');
				vcount := vcount + 1;
				IF vcount >= 32000
				THEN
					htools.message('Warning!'
								  ,' Too many records to be displayed.~Specify search conditions.');
					EXIT;
				END IF;
			END LOOP;
		END;
	BEGIN
	
		CASE pwhat
		
			WHEN dialog.wtdialogpre THEN
				refresh;
			
			WHEN dialog.wtdialogvalid THEN
				saclerk.delete;
				FOR i IN 1 .. dialog.getlistreccount(pdialog, 'cbClerks')
				LOOP
					IF (dialog.getbool(pdialog, 'cbClerks', i))
					THEN
						saclerk(saclerk.count + 1) := dialog.getrecordnumber(pdialog
																			,'cbClerks'
																			,'CODE'
																			,i);
					END IF;
				END LOOP;
			
			WHEN dialog.wtitempre THEN
				IF htools.equal('Find', pitemname)
				THEN
					refresh();
				ELSIF htools.equal('Clear', pitemname)
				THEN
					dialog.putchar(pdialog, 'User', NULL);
					dialog.putchar(pdialog, 'FIO', NULL);
				END IF;
			ELSE
				NULL;
		END CASE;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.show(cwhere);
			dialog.cancelclose(pdialog);
	END;

	FUNCTION selectgroupsdialog RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.SelectGroupsDialog';
		cevent CONSTANT VARCHAR2(100) := cpackagename || '.SelectGroupsDialogHandler';
		vdialog NUMBER;
	
		cdialogwidth  CONSTANT NUMBER := 60;
		cdialogheight CONSTANT NUMBER := 20;
		clistwidth    CONSTANT NUMBER := cdialogwidth - 6;
		clistheight   CONSTANT NUMBER := cdialogheight - 3;
		vmenu NUMBER;
		cbutlen CONSTANT NUMBER := 10;
	
	BEGIN
	
		vdialog := dialog.new('Add operator to group', 0, 0, cdialogwidth, cdialogheight);
	
		dialog.setexternalid(vdialog, cwhere);
		dialog.setdialogresizeable(vdialog, TRUE);
		dialog.setdialogcanmaximize(vdialog, TRUE);
	
		dialog.checkbox(vdialog
					   ,'cbG'
					   ,2
					   ,1
					   ,clistwidth
					   ,clistheight
					   ,'List of groups'
					   ,panchor => dialog.anchor_all);
		vmenu := dialog.menu(vdialog);
		dummy := dialog.makemenusearch(vmenu, 'cbG', NULL, FALSE);
		dialog.setanchor(vdialog, 'cbG', dialog.anchor_all);
	
		dialog.listaddfield(vdialog, 'cbG', 'CODE', 'N', 10, 0);
		dialog.listaddfield(vdialog, 'cbG', 'NAME', 'C', 40, 1);
		dialog.setcaption(vdialog, 'cbG', '~Name');
	
		dialog.button(vdialog
					 ,'btnOk'
					 ,cdialogwidth / 2 - 1 - cbutlen
					 ,cdialogheight
					 ,cbutlen
					 ,'Enter'
					 ,dialog.cmok
					 ,0
					 ,'Save changes');
		dialog.setanchor(vdialog, 'btnOk', dialog.anchor_bottom);
	
		dialog.setdefault(vdialog, 'btnOk');
		IF NOT checkright(right_modify)
		THEN
			dialog.setenable(vdialog, 'btnSave', FALSE);
		END IF;
	
		dialog.button(vdialog
					 ,'btnCancel'
					 ,cdialogwidth / 2 + 1
					 ,cdialogheight
					 ,cbutlen
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Exit without saving');
		dialog.setanchor(vdialog, 'btnCancel', dialog.anchor_bottom);
	
		dialog.setdialogvalid(vdialog, cevent);
	
		dialog.listclear(vdialog, 'cbG');
	
		FOR i IN (SELECT t.*
				  FROM   tclerkgroup t
				  LEFT   OUTER JOIN tclerk2group cc
				  ON     cc.branch = t.branch
				  AND    cc.groupid = t.id
				  AND    cc.clerkid = scuruserid
				  WHERE  t.branch = seance.getbranch
				  AND    cc.clerkid IS NULL
				  ORDER  BY NAME)
		LOOP
		
			IF checkright2group(right_group_modify, i.id)
			THEN
				dialog.listaddrecord(vdialog, 'cbG', i.id || '~' || i.name || '~');
			END IF;
		END LOOP;
	
		RETURN vdialog;
	END;

	PROCEDURE selectgroupsdialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
	
	BEGIN
		IF (pwhat = dialog.wtdialogvalid)
		THEN
			sagroup.delete;
		
			FOR i IN 1 .. dialog.getlistreccount(pdialog, 'cbG')
			LOOP
				IF (dialog.getbool(pdialog, 'cbG', i))
				THEN
				
					sagroup(sagroup.count + 1) := dialog.getrecordnumber(pdialog, 'cbG', 'CODE', i);
				END IF;
			END LOOP;
		END IF;
	END;

	PROCEDURE cleararray IS
	BEGIN
		scodearray.delete;
		stextarray.delete;
		sfinarray.delete;
		sarraysize := 0;
	END;

	PROCEDURE addrecord
	(
		pkey   VARCHAR
	   ,ptext  VARCHAR
	   ,pfinal BOOLEAN
	) IS
		i NUMBER;
	BEGIN
		i := scodearray.count + 1;
		scodearray(i) := pkey;
		stextarray(i) := ptext;
		sfinarray(i) := nvl(pfinal, FALSE);
		sarraysize := scodearray.count;
	END;

	FUNCTION gettree
	(
		puserid   NUMBER := NULL
	   ,pusertype NUMBER := NULL
	) RETURN apitypes.typesecurnodetree IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.GetTree';
	BEGIN
		initcurrent(nvl(puserid, clerk.getcode()), nvl(pusertype, ot_user));
		scuruserid   := nvl(puserid, clerk.getcode());
		scurusertype := nvl(pusertype, ot_user);
		streemode    := ctree_grant;
	
		fillgranttree;
		RETURN satree;
	END;

	FUNCTION getuserlist RETURN apitypes.typesecuruserinfolist IS
		CURSOR vcursor IS
			SELECT * FROM tclerk WHERE branch = seance.getbranch ORDER BY NAME;
		vuserlist apitypes.typesecuruserinfolist;
		n         NUMBER := 1;
	BEGIN
		FOR i IN vcursor
		LOOP
			vuserlist(n).code := i.code;
			vuserlist(n).clerkid := i.clerkid;
			vuserlist(n).name := i.name;
			vuserlist(n).usertype := i.type;
			n := n + 1;
		END LOOP;
		RETURN vuserlist;
	END;

	FUNCTION getgrouplist RETURN apitypes.typesecurgroupinfolist IS
		CURSOR vcursor IS
			SELECT * FROM tclerkgroup WHERE branch = seance.getbranch ORDER BY id;
		vgrouplist apitypes.typesecurgroupinfolist;
		n          NUMBER := 1;
	BEGIN
		FOR i IN vcursor
		LOOP
			vgrouplist(n).id := i.id;
			vgrouplist(n).name := i.name;
			vgrouplist(n).remark := i.remark;
			n := n + 1;
		END LOOP;
		RETURN vgrouplist;
	END;

	FUNCTION getaccessobjectlist RETURN apitypes.typesecurobjectinfolist IS
		CURSOR vcursor IS
			SELECT * FROM taccessobjects ORDER BY id;
		vobjectlist apitypes.typesecurobjectinfolist;
		n           NUMBER := 1;
	BEGIN
		FOR i IN vcursor
		LOOP
			vobjectlist(n).id := i.id;
			vobjectlist(n).name := i.name;
			vobjectlist(n).description := i.description;
			vobjectlist(n).packagename := i.packagename;
			n := n + 1;
		END LOOP;
		RETURN vobjectlist;
	END;

	FUNCTION getaccesskeyid
	(
		pobjectid  NUMBER
	   ,paccesskey VARCHAR
	) RETURN NUMBER IS
	BEGIN
		RETURN sbasetreemap(gethashvalue(pobjectid, paccesskey)).id;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;

	FUNCTION getaccesskeylevel
	(
		pobjectid  NUMBER
	   ,paccesskey VARCHAR
	) RETURN NUMBER IS
	BEGIN
		RETURN sbasetreemap(gethashvalue(pobjectid, paccesskey)).level;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;

	FUNCTION getaccesskeydescription_
	(
		pbasetreemap IN typeaccesskeymap
	   ,pobjectid    NUMBER
	   ,paccesskey   VARCHAR
	   ,pwithobject  BOOLEAN := TRUE
	) RETURN VARCHAR IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.GetAccessKeyDescription';
		vpos    NUMBER := 2;
		vsubkey keytype;
		vnewkey keytype := '|';
		vret    VARCHAR(1000) := '|';
		vidx    idxkeytype;
	BEGIN
		timer.start_(cwhere);
	
		WHILE htools.readsubstr(paccesskey, vpos, vsubkey, '|')
		LOOP
			vnewkey := vnewkey || vsubkey || '|';
			vidx    := gethashvalue(pobjectid, vnewkey);
			IF pbasetreemap.exists(vidx)
			THEN
				vret := vret || pbasetreemap(vidx).description || '|';
			ELSE
				vret := vret || vsubkey || '|';
			END IF;
		END LOOP;
	
		IF pwithobject
		THEN
			vret := getaccessobjectinfo(pobjectid).description || ':' || vret;
		END IF;
	
		timer.stop_(cwhere);
	
		RETURN vret;
	
	EXCEPTION
		WHEN OTHERS THEN
			s.say('EXCEPTION ' || SQLCODE || ', ' || SQLERRM);
			RETURN vret;
	END;

	FUNCTION getaccesskeydescription
	(
		pobjectid   NUMBER
	   ,paccesskey  VARCHAR
	   ,pwithobject BOOLEAN := TRUE
	   ,pissearch   BOOLEAN := FALSE
	) RETURN VARCHAR IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.GetAccessKeyDescription';
		vret VARCHAR(1000) := '|';
	BEGIN
	
		IF pissearch
		THEN
			vret := getaccesskeydescription_(ssearchbasetreemap, pobjectid, paccesskey, pwithobject);
		ELSE
			vret := getaccesskeydescription_(sbasetreemap, pobjectid, paccesskey, pwithobject);
		END IF;
	
		RETURN vret;
	
	EXCEPTION
		WHEN OTHERS THEN
			s.say('EXCEPTION ' || SQLCODE || ', ' || SQLERRM);
			RETURN vret;
	END;

	FUNCTION getuserrightlist
	(
		puserid          NUMBER
	   ,pwithgrouprigths BOOLEAN := TRUE
	) RETURN apitypes.typesecurrightinfolist IS
		CURSOR vcursor(vuserid IN NUMBER) IS
			SELECT userid
				  ,usertype
				  ,objectid
				  ,accesskey
			FROM   trights
			WHERE  (branch = seance.getbranch AND
				   ((usertype = 1 AND userid = vuserid) OR
				   (usertype = 2 AND
				   userid IN (SELECT groupid
								 FROM   tclerk2group
								 WHERE  branch = seance.getbranch
								 AND    clerkid = vuserid))))
			ORDER  BY objectid
					 ,security.getaccesskeylevel(objectid, accesskey)
					 ,security.getaccesskeyid(objectid, accesskey)
					 ,accesskey
					 ,usertype
					 ,userid;
	
		CURSOR vcursorwithoutgrouprights(vuserid IN NUMBER) IS
			SELECT userid
				  ,usertype
				  ,objectid
				  ,accesskey
			FROM   trights
			WHERE  (branch = seance.getbranch AND (usertype = 1 AND userid = vuserid))
			ORDER  BY objectid
					 ,security.getaccesskeylevel(objectid, accesskey)
					 ,security.getaccesskeyid(objectid, accesskey)
					 ,accesskey;
	
		vrights apitypes.typesecurrightinfolist;
		n       NUMBER := 1;
	BEGIN
		IF NOT pwithgrouprigths
		THEN
			FOR i IN vcursorwithoutgrouprights(puserid)
			LOOP
			
				vrights(n).userid := i.userid;
				vrights(n).usertype := i.usertype;
				vrights(n).objectid := i.objectid;
				vrights(n).accesskey := i.accesskey;
				IF i.accesskey = cnull
				THEN
					vrights(n).accesskey := NULL;
				END IF;
				n := n + 1;
			END LOOP;
		ELSE
			FOR i IN vcursor(puserid)
			LOOP
			
				vrights(n).userid := i.userid;
				vrights(n).usertype := i.usertype;
				vrights(n).objectid := i.objectid;
				vrights(n).accesskey := i.accesskey;
				IF i.accesskey = cnull
				THEN
					vrights(n).accesskey := NULL;
				END IF;
			
				n := n + 1;
			END LOOP;
		END IF;
		RETURN vrights;
	END;

	FUNCTION getgrouprightlist(pgroupid NUMBER) RETURN apitypes.typesecurrightinfolist IS
		CURSOR vcursor(vgroupid IN NUMBER) IS
			SELECT userid
				  ,usertype
				  ,objectid
				  ,accesskey
			FROM   trights
			WHERE  (branch = seance.getbranch AND (usertype = 2 AND userid = vgroupid))
			ORDER  BY objectid
					 ,security.getaccesskeylevel(objectid, accesskey)
					 ,security.getaccesskeyid(objectid, accesskey)
					 ,accesskey
					 ,usertype
					 ,userid;
	
		vrights apitypes.typesecurrightinfolist;
		n       NUMBER := 1;
	BEGIN
		FOR i IN vcursor(pgroupid)
		LOOP
			vrights(n).userid := i.userid;
			vrights(n).usertype := i.usertype;
			vrights(n).objectid := i.objectid;
			vrights(n).accesskey := i.accesskey;
			IF i.accesskey = cnull
			THEN
				vrights(n).accesskey := NULL;
			END IF;
			n := n + 1;
		END LOOP;
		RETURN vrights;
	END;

	FUNCTION getusersofgrouplist(pgroupid NUMBER) RETURN apitypes.typesecuruserinfolist IS
		CURSOR vcursor(vgroupid IN NUMBER) IS
		
			SELECT a.code
				  ,a.clerkid
				  ,a.name
				  ,a.type
			FROM   tclerk a
			WHERE  a.branch = seance.getbranch
			AND    a.code IN (SELECT b.clerkid
							  FROM   tclerk2group b
							  WHERE  b.groupid = vgroupid
							  AND    b.branch = seance.getbranch)
			ORDER  BY a.name;
		vuserlist apitypes.typesecuruserinfolist;
		n         NUMBER := 1;
	BEGIN
		FOR i IN vcursor(pgroupid)
		LOOP
			vuserlist(n) := i;
			n := n + 1;
		END LOOP;
		RETURN vuserlist;
	END;

	FUNCTION getgroupsofuserlist(puserid NUMBER) RETURN apitypes.typesecurgroupinfolist IS
		CURSOR vcursor(vuserid IN NUMBER) IS
		
			SELECT a.id
				  ,a.name
				  ,a.remark
			FROM   tclerkgroup a
			WHERE  a.branch = seance.getbranch
			AND    a.id IN (SELECT b.groupid
							FROM   tclerk2group b
							WHERE  b.branch = seance.getbranch
							AND    b.clerkid = vuserid)
			ORDER  BY a.name;
		vgrouplist apitypes.typesecurgroupinfolist;
		n          NUMBER := 1;
	BEGIN
		FOR i IN vcursor(puserid)
		LOOP
			vgrouplist(n) := i;
			n := n + 1;
		END LOOP;
		RETURN vgrouplist;
	END;

	FUNCTION gethashvalue
	(
		pobjectid  NUMBER
	   ,paccesskey VARCHAR
	) RETURN VARCHAR2 IS
	BEGIN
		RETURN to_char(pobjectid) || paccesskey;
	END;

	FUNCTION isgrandedforuser
	(
		pobjectid        NUMBER
	   ,paccesskey       VARCHAR
	   ,puserid          NUMBER
	   ,pwithgrouprights BOOLEAN
	) RETURN BOOLEAN IS
		CURSOR vcursorwithgrouprights
		(
			vobjectid  NUMBER
		   ,vaccesskey VARCHAR
		   ,vuserid    NUMBER
		) IS
			SELECT accesskey
			FROM   trights
			WHERE  branch = seance.getbranch
			AND    objectid = vobjectid
			AND    accesskey = vaccesskey
			AND    ((usertype = 1 AND userid = vuserid) OR
				  (usertype = 2 AND
				  userid IN (SELECT groupid
								FROM   tclerk2group
								WHERE  branch = seance.getbranch
								AND    clerkid = vuserid)));
	
		CURSOR vcursorwithoutgrouprights
		(
			vobjectid  NUMBER
		   ,vaccesskey VARCHAR
		   ,vuserid    NUMBER
		) IS
			SELECT accesskey
			FROM   trights
			WHERE  branch = seance.getbranch
			AND    objectid = vobjectid
			AND    accesskey = vaccesskey
			AND    usertype = 1
			AND    userid = vuserid;
	BEGIN
		IF pwithgrouprights
		THEN
			FOR i IN vcursorwithgrouprights(pobjectid, nvl(paccesskey, cnull), puserid)
			LOOP
				RETURN TRUE;
			END LOOP;
			RETURN FALSE;
		ELSE
			FOR i IN vcursorwithoutgrouprights(pobjectid, nvl(paccesskey, cnull), puserid)
			LOOP
				RETURN TRUE;
			END LOOP;
			RETURN FALSE;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN FALSE;
	END;

	FUNCTION isgrandedforgroup
	(
		pobjectid  NUMBER
	   ,paccesskey VARCHAR
	   ,pgroupid   NUMBER
	) RETURN BOOLEAN IS
		CURSOR vcursor
		(
			vobjectid  NUMBER
		   ,vaccesskey VARCHAR
		   ,vgroupid   NUMBER
		) IS
			SELECT accesskey
			FROM   trights
			WHERE  branch = seance.getbranch
			AND    objectid = vobjectid
			AND    accesskey = vaccesskey
			AND    usertype = 2
			AND    userid = vgroupid;
	BEGIN
		FOR i IN vcursor(pobjectid, nvl(paccesskey, cnull), pgroupid)
		LOOP
			RETURN TRUE;
		END LOOP;
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN FALSE;
	END;

	FUNCTION getuserrightsforkey
	(
		pobjectid        NUMBER
	   ,paccesskey       VARCHAR
	   ,puserid          NUMBER
	   ,pwithgrouprights BOOLEAN
	) RETURN apitypes.typesecurrightinfolist IS
		vrights apitypes.typesecurrightinfolist;
		CURSOR vcursorwithgrouprights
		(
			vobjectid  NUMBER
		   ,vaccesskey VARCHAR
		   ,vuserid    NUMBER
		) IS
			SELECT userid
				  ,usertype
				  ,objectid
				  ,accesskey
			FROM   trights
			WHERE  branch = seance.getbranch
			AND    objectid = vobjectid
			AND    accesskey = vaccesskey
			AND    ((usertype = 1 AND userid = vuserid) OR
				  (usertype = 2 AND
				  userid IN (SELECT groupid
								FROM   tclerk2group
								WHERE  branch = seance.getbranch
								AND    clerkid = vuserid)))
			ORDER  BY usertype
					 ,userid;
	
		CURSOR vcursorwithoutgrouprights
		(
			vobjectid  NUMBER
		   ,vaccesskey VARCHAR
		   ,vuserid    NUMBER
		) IS
			SELECT userid
				  ,usertype
				  ,objectid
				  ,accesskey
			FROM   trights
			WHERE  branch = seance.getbranch
			AND    objectid = vobjectid
			AND    accesskey = vaccesskey
			AND    usertype = 1
			AND    userid = vuserid
			ORDER  BY usertype
					 ,userid;
		n NUMBER := 1;
	BEGIN
		IF pwithgrouprights
		THEN
			FOR i IN vcursorwithgrouprights(pobjectid, nvl(paccesskey, cnull), puserid)
			LOOP
				vrights(n).userid := i.userid;
				vrights(n).usertype := i.usertype;
				vrights(n).objectid := i.objectid;
				vrights(n).accesskey := i.accesskey;
				n := n + 1;
			END LOOP;
			RETURN vrights;
		ELSE
			FOR i IN vcursorwithoutgrouprights(pobjectid, nvl(paccesskey, cnull), puserid)
			LOOP
				vrights(n).userid := i.userid;
				vrights(n).usertype := i.usertype;
				vrights(n).objectid := i.objectid;
				vrights(n).accesskey := i.accesskey;
				n := n + 1;
			END LOOP;
			RETURN vrights;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN vrights;
	END;

	FUNCTION getgrouprightsforkey
	(
		pobjectid  NUMBER
	   ,paccesskey VARCHAR
	   ,pgroupid   NUMBER
	) RETURN apitypes.typesecurrightinfolist IS
		vrights apitypes.typesecurrightinfolist;
		CURSOR vcursor
		(
			vobjectid  NUMBER
		   ,vaccesskey VARCHAR
		   ,vgroupid   NUMBER
		) IS
			SELECT userid
				  ,usertype
				  ,objectid
				  ,accesskey
			FROM   trights
			WHERE  branch = seance.getbranch
			AND    objectid = vobjectid
			AND    accesskey = vaccesskey
			AND    usertype = 2
			AND    userid = vgroupid;
		n NUMBER := 1;
	BEGIN
		FOR i IN vcursor(pobjectid, nvl(paccesskey, cnull), pgroupid)
		LOOP
			vrights(n).userid := i.userid;
			vrights(n).usertype := i.usertype;
			vrights(n).objectid := i.objectid;
			vrights(n).accesskey := i.accesskey;
			n := n + 1;
		END LOOP;
		RETURN vrights;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN vrights;
	END;

	FUNCTION getuserinfo(puserid NUMBER) RETURN apitypes.typesecuruserinfo IS
		vuserinfo apitypes.typesecuruserinfo;
	BEGIN
		SELECT a.code
			  ,a.clerkid
			  ,a.name
			  ,a.type
		INTO   vuserinfo
		FROM   tclerk a
		WHERE  a.branch = seance.getbranch
		AND    a.code = puserid;
		RETURN vuserinfo;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;

	FUNCTION getgroupinfo(pgroupid NUMBER) RETURN apitypes.typesecurgroupinfo IS
		vgroupinfo apitypes.typesecurgroupinfo;
	BEGIN
		SELECT a.id
			  ,a.name
			  ,a.remark
		INTO   vgroupinfo
		FROM   tclerkgroup a
		WHERE  a.branch = seance.getbranch
		AND    a.id = pgroupid;
		RETURN vgroupinfo;
	END;

	FUNCTION getaccessobjectinfo(pobjectid NUMBER) RETURN apitypes.typesecurobjectinfo IS
		vaccessobjectinfo apitypes.typesecurobjectinfo;
	BEGIN
		SELECT a.id
			  ,a.name
			  ,a.description
			  ,a.packagename
		INTO   vaccessobjectinfo
		FROM   taccessobjects a
		WHERE  a.id = pobjectid;
		RETURN vaccessobjectinfo;
	END;

	PROCEDURE fillsecurityarray
	(
		plevel IN NUMBER
	   ,pkey   IN VARCHAR
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.FillSecurityArray[T]';
		vrtree types.utree;
		i0     PLS_INTEGER;
		i1     PLS_INTEGER;
		i2     PLS_INTEGER;
	BEGIN
		s.say(cwhere || ' start level ' || plevel);
	
		i0 := security.addrightnode(vrtree, NULL, pkey, 'root');
		security.addrightnode(vrtree, i0, right_view, 'View');
		i1 := security.addrightnode(vrtree, i0, right_grant, 'Modify rights');
		i2 := security.addrightnode(vrtree, i1, right_grant_group, 'Groups');
		security.addrightnode(vrtree, i2, right_grant_group_all, '(All groups)');
	
		FOR crow IN (SELECT * FROM tclerkgroup t WHERE t.branch = seance.getbranch ORDER BY t.name)
		LOOP
			IF checkright(right_grant_group_all)
			   OR checkright2group(right_grant_group, crow.id)
			THEN
				security.addrightnode(vrtree, i2, crow.id, crow.name);
			END IF;
		END LOOP;
	
		i2 := security.addrightnode(vrtree, i1, right_grant_user, 'Operators');
		i2 := security.addrightnode(vrtree, i1, right_grant_self, 'Own rights');
	
		i1 := security.addrightnode(vrtree, i0, right_group, 'Groups of operators');
		security.addrightnode(vrtree, i1, right_group_create, 'Create');
		security.addrightnode(vrtree, i1, right_group_delete, 'Delete');
		i2 := security.addrightnode(vrtree, i1, right_group_modify, 'Modification');
		security.addrightnode(vrtree, i2, right_group_modify_all, '(All groups)');
	
		FOR crow IN (SELECT * FROM tclerkgroup t WHERE t.branch = seance.getbranch ORDER BY t.name)
		LOOP
			IF checkright(right_group_modify_all)
			   OR checkright2group(right_group_modify, crow.id)
			THEN
				security.addrightnode(vrtree, i2, crow.id, crow.name);
			END IF;
		END LOOP;
		utree.printtree(vrtree);
		security.addrightstree(vrtree);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE addrightnode
	(
		porights   IN OUT NOCOPY types.utree
	   ,pparent_i  PLS_INTEGER
	   ,prightkey  VARCHAR
	   ,prightname VARCHAR
	   ,pbefore_i  PLS_INTEGER := NULL
	) IS
	BEGIN
		dummy := addrightnode(porights, pparent_i, prightkey, prightname, pbefore_i);
	END;

	FUNCTION addrightnode
	(
		porights   IN OUT NOCOPY types.utree
	   ,pparent_i  PLS_INTEGER
	   ,prightkey  VARCHAR
	   ,prightname VARCHAR
	   ,pbefore_i  PLS_INTEGER := NULL
	) RETURN PLS_INTEGER IS
		vvalue types.uvalue;
	BEGIN
		vvalue.id    := prightkey;
		vvalue.asstr := prightname;
		vvalue.type  := types.cstring;
		RETURN utree.addnode(potree    => porights
							,pparent_i => pparent_i
							,pvalue    => vvalue
							,pbefore_i => pbefore_i);
	END;

	FUNCTION addrighttree
	(
		porights   IN OUT NOCOPY types.utree
	   ,pparent_i  PLS_INTEGER
	   ,psubrights IN OUT NOCOPY types.utree
	   ,pbefore_i  PLS_INTEGER := NULL
	) RETURN PLS_INTEGER IS
	BEGIN
		RETURN utree.addsubtree(potree    => porights
							   ,pparent_i => pparent_i
							   ,psubtree  => psubrights
							   ,pbefore_i => pbefore_i);
	END;

	PROCEDURE delrightnode
	(
		porights IN OUT NOCOPY types.utree
	   ,pnode_i  PLS_INTEGER
	) IS
	BEGIN
		utree.delnode(potree => porights, pnode_i => pnode_i);
	END;

	PROCEDURE addrightstree(porights IN OUT NOCOPY types.utree) IS
	BEGIN
		suseoldarray := FALSE;
		slasttree    := porights;
	END;

BEGIN

	sacashobjectid.delete;
	FOR i IN (SELECT * FROM taccessobjects)
	LOOP
		sacashobjectid(i.name) := i.id;
	END LOOP;

	sprevuserid   := 0;
	sprevusertype := 0;
	smaindialog   := 0;
EXCEPTION
	WHEN OTHERS THEN
		NULL;
END;
/
