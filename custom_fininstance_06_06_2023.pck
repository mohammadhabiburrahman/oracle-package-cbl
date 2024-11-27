CREATE OR REPLACE PACKAGE custom_fininstance IS

	crevision CONSTANT VARCHAR2(100) := '$Rev: 44809 $';

	right_exchange CONSTANT NUMBER := 1;
	right_override CONSTANT NUMBER := 2;

	FUNCTION getversion RETURN VARCHAR2;

	PROCEDURE makepage
	(
		ppage     NUMBER
	   ,pident    VARCHAR
	   ,pwidth    NUMBER
	   ,pheight   NUMBER
	   ,pactivity NUMBER
	   ,peditmode BOOLEAN
	   ,pfilter   BOOLEAN := FALSE
	   ,pinfo     BOOLEAN := FALSE
	);
	PROCEDURE makepage
	(
		ppage     NUMBER
	   ,pident    VARCHAR
	   ,px        NUMBER
	   ,py        NUMBER
	   ,pwidth    NUMBER
	   ,pheight   NUMBER
	   ,pactivity NUMBER
	   ,peditmode BOOLEAN
	   ,pfilter   BOOLEAN := FALSE
	   ,pinfo     BOOLEAN := FALSE
	);
	PROCEDURE loadpage
	(
		ppage             NUMBER
	   ,pident            VARCHAR
	   ,pprofile          NUMBER
	   ,pinstance         NUMBER
	   ,pprofilefilterkey VARCHAR := NULL
	);
	FUNCTION savepage
	(
		ppage     NUMBER
	   ,pident    VARCHAR
	   ,pprofile  NUMBER
	   ,pinstance NUMBER
	) RETURN NUMBER;
	FUNCTION getpageprofile
	(
		ppage  NUMBER
	   ,pident VARCHAR
	) RETURN NUMBER;
	PROCEDURE setpageprofilefocus
	(
		ppage  NUMBER
	   ,pident VARCHAR
	);
	PROCEDURE enablepage
	(
		ppage   NUMBER
	   ,pident  VARCHAR
	   ,penable BOOLEAN := TRUE
	   ,pclear  BOOLEAN := FALSE
	);
	PROCEDURE pageproc
	(
		pwhat VARCHAR
	   ,pdlg  NUMBER
	   ,pitem VARCHAR
	   ,pcmd  NUMBER
	);

	FUNCTION copydata
	(
		pinstance    NUMBER
	   ,plog         BOOLEAN := FALSE
	   ,pobjecttype  NUMBER := NULL
	   ,pkeyvalue    VARCHAR2 := NULL
	   ,plogclientid NUMBER := NULL
	) RETURN NUMBER;
	PROCEDURE deletedata(pinstance NUMBER);

	FUNCTION getsecurityarray RETURN custom_security.typerights;
	PROCEDURE fillsecurityarray;
	PROCEDURE fillsecuritytree
	(
		porights    IN OUT NOCOPY types.utree
	   ,pparentnode PLS_INTEGER
	);
	FUNCTION getsecuritykey
	(
		ppage   NUMBER
	   ,pident  VARCHAR
	   ,pobject OUT VARCHAR
	   ,pkey    OUT VARCHAR
	) RETURN BOOLEAN;
	PROCEDURE setsecuritykey
	(
		ppage   NUMBER
	   ,pident  VARCHAR
	   ,pobject VARCHAR
	   ,pkey    VARCHAR
	);
	FUNCTION getlogkey
	(
		ppage        NUMBER
	   ,pident       VARCHAR
	   ,pobject      OUT VARCHAR
	   ,pkey         OUT VARCHAR
	   ,ologclientid OUT NUMBER
	) RETURN BOOLEAN;
	PROCEDURE setlogkey
	(
		ppage        NUMBER
	   ,pident       VARCHAR
	   ,pobject      VARCHAR
	   ,pkey         VARCHAR
	   ,plogclientid NUMBER := NULL
	);

	PROCEDURE tolog
	(
		ppage   NUMBER
	   ,ptext   VARCHAR
	   ,paction IN NUMBER
	);
	PROCEDURE logobject
	(
		pobjecttype  NUMBER
	   ,paction      IN NUMBER
	   ,pkeyvalue    VARCHAR2
	   ,ptext        VARCHAR
	   ,plogclientid NUMBER
	);

	FUNCTION checkuserright
	(
		ppage  NUMBER
	   ,pright VARCHAR
	) RETURN BOOLEAN;
	PROCEDURE checkuserright
	(
		ppage  NUMBER
	   ,pright VARCHAR
	);
	FUNCTION getctxlogobjecttype(pdlg NUMBER) RETURN NUMBER;
	FUNCTION getctxlogkey(pdlg NUMBER) RETURN VARCHAR;
	FUNCTION getctxlogclientid(pdlg NUMBER) RETURN NUMBER;

	FUNCTION getinstanceprofile(pinstance NUMBER) RETURN NUMBER;

	PROCEDURE delinstancedata
	(
		pinstance   NUMBER
	   ,pobjecttype NUMBER := NULL
	   ,pkeyvalue   VARCHAR2 := NULL
	);
	FUNCTION putinstancedata
	(
		pinstance   NUMBER
	   ,pprofile    NUMBER
	   ,pobjecttype NUMBER := NULL
	   ,pkeyvalue   VARCHAR2 := NULL
	) RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY custom_fininstance IS

	cpackagename CONSTANT VARCHAR2(30) := 'FinInstance';

	cbodyrevision CONSTANT VARCHAR2(100) := '$Rev: 44809 $';

	idpagelist    CONSTANT VARCHAR(16) := upper('finPageList');
	idfilter      CONSTANT VARCHAR(16) := upper('finFilter');
	idprofilecode CONSTANT VARCHAR(16) := upper('finProfileCode');

	idprof CONSTANT VARCHAR(16) := upper('finProfile');

	ctxactivity        CONSTANT VARCHAR(16) := 'ctAct';
	ctxinstanceprofile CONSTANT VARCHAR(16) := 'ctInstPro';
	ctxinstance        CONSTANT VARCHAR(16) := 'ctInst';
	ctxprofile         CONSTANT VARCHAR(16) := 'ctProf';
	ctxfilterkey       CONSTANT VARCHAR(16) := 'ctFilterKey';

	ctxpagecomm CONSTANT VARCHAR(16) := 'ctPComm';
	ctxpagecom2 CONSTANT VARCHAR(16) := 'ctPCom2';
	ctxpagepaym CONSTANT VARCHAR(16) := 'ctPPaym';
	ctxpagereta CONSTANT VARCHAR(16) := 'ctPReta';

	ctxcheckuserright CONSTANT VARCHAR(16) := 'ctCheckR';
	ctxuserobject     CONSTANT VARCHAR(16) := 'ctUserOb';
	ctxuserkey        CONSTANT VARCHAR(16) := 'ctUserKey';

	ctxlogenable     CONSTANT VARCHAR(16) := 'ctLogEna';
	ctxlogobject     CONSTANT VARCHAR(16) := 'ctLogObj';
	ctxlogobjecttype CONSTANT VARCHAR(16) := 'ctLogObTy';
	ctxlogkey        CONSTANT VARCHAR(16) := 'ctLogKey';
	ctxlogclientid   CONSTANT VARCHAR(16) := 'ctLogClientId';

	ctxident   CONSTANT VARCHAR(16) := 'ctIdent';
	ctxpage    CONSTANT VARCHAR(16) := 'ctiPage';
	ctxtest    CONSTANT VARCHAR(16) := 'ctxTest';
	co_testctx CONSTANT NUMBER := 11223344;

	sbranch NUMBER;

	PROCEDURE createpages
	(
		pdlg      NUMBER
	   ,pid       VARCHAR
	   ,pwidth    NUMBER
	   ,pheight   NUMBER
	   ,pactivity NUMBER
	   ,peditmode BOOLEAN
	   ,pinfo     BOOLEAN := FALSE
	);
	PROCEDURE clearpages(pdlg NUMBER);
	FUNCTION copydatapages
	(
		pinstancefrom NUMBER
	   ,pinstanceto   NUMBER
	   ,plog          BOOLEAN := FALSE
	   ,pobjecttype   NUMBER := NULL
	   ,pkeyvalue     VARCHAR2 := NULL
	   ,plogclientid  NUMBER := NULL
	) RETURN NUMBER;
	PROCEDURE loadpages
	(
		pdlg      NUMBER
	   ,pprofile  NUMBER
	   ,pinstance NUMBER
	);
	FUNCTION getnumberofchanges
	(
		pdlg     NUMBER
	   ,pprofile NUMBER
	) RETURN NUMBER;
	FUNCTION savepages
	(
		pdlg      NUMBER
	   ,pprofile  NUMBER
	   ,pinstance NUMBER
	) RETURN NUMBER;
	PROCEDURE resetpages(pdlg NUMBER);
	PROCEDURE enablepages
	(
		pdlg    NUMBER
	   ,penable BOOLEAN
	);

	PROCEDURE initpagecontext
	(
		pdlg   NUMBER
	   ,pident VARCHAR
	);
	FUNCTION getctxpage
	(
		pdlg   NUMBER
	   ,pident VARCHAR
	) RETURN NUMBER;

	PROCEDURE setctxactivity
	(
		pdlg      NUMBER
	   ,pactivity NUMBER
	);
	FUNCTION getctxactivity(pdlg NUMBER) RETURN NUMBER;
	PROCEDURE setctxinstanceprofile
	(
		pdlg             NUMBER
	   ,pinstanceprofile NUMBER
	);
	FUNCTION getctxinstanceprofile(pdlg NUMBER) RETURN NUMBER;
	PROCEDURE setctxprofile
	(
		pdlg     NUMBER
	   ,pprofile NUMBER
	);
	FUNCTION getctxprofile(pdlg NUMBER) RETURN NUMBER;
	PROCEDURE setctxinstance
	(
		pdlg      NUMBER
	   ,pinstance NUMBER
	);
	FUNCTION getctxinstance(pdlg NUMBER) RETURN NUMBER;
	PROCEDURE setctxfilterkey
	(
		pdlg              NUMBER
	   ,pprofilefilterkey VARCHAR
	);
	FUNCTION getctxfilterkey(pdlg NUMBER) RETURN VARCHAR;

	PROCEDURE setctxpagecomm
	(
		pdlg  NUMBER
	   ,ppage NUMBER
	);
	FUNCTION getctxpagecomm(pdlg NUMBER) RETURN NUMBER;
	PROCEDURE setctxpagecom2
	(
		pdlg  NUMBER
	   ,ppage NUMBER
	);
	FUNCTION getctxpagecom2(pdlg NUMBER) RETURN NUMBER;
	PROCEDURE setctxpagepay
	(
		pdlg  NUMBER
	   ,ppage NUMBER
	);
	FUNCTION getctxpagepay(pdlg NUMBER) RETURN NUMBER;
	PROCEDURE setctxpageret
	(
		pdlg  NUMBER
	   ,ppage NUMBER
	);
	FUNCTION getctxpageret(pdlg NUMBER) RETURN NUMBER;
	PROCEDURE testctxpage(ppage NUMBER);

	PROCEDURE setctxcheckuserright
	(
		pdlg NUMBER
	   ,pval BOOLEAN
	);
	FUNCTION getctxcheckuserright(pdlg NUMBER) RETURN BOOLEAN;
	PROCEDURE setctxuserobject
	(
		pdlg NUMBER
	   ,pval VARCHAR
	);
	FUNCTION getctxuserobject(pdlg NUMBER) RETURN VARCHAR;
	PROCEDURE setctxuserkey
	(
		pdlg NUMBER
	   ,pval VARCHAR
	);
	FUNCTION getctxuserkey(pdlg NUMBER) RETURN VARCHAR;

	PROCEDURE setctxlogenable
	(
		pdlg NUMBER
	   ,pval BOOLEAN
	);
	FUNCTION getctxlogenable(pdlg NUMBER) RETURN BOOLEAN;
	PROCEDURE setctxlogobjecttype
	(
		pdlg NUMBER
	   ,pval NUMBER
	);

	PROCEDURE setctxlogobject
	(
		pdlg NUMBER
	   ,pval VARCHAR
	);
	FUNCTION getctxlogobject(pdlg NUMBER) RETURN VARCHAR;
	PROCEDURE setctxlogkey
	(
		pdlg NUMBER
	   ,pval VARCHAR
	);

	PROCEDURE setctxlogclientid
	(
		pdlg         NUMBER
	   ,plogclientid NUMBER
	);

	FUNCTION makeident
	(
		pdlg  NUMBER
	   ,pitem VARCHAR
	) RETURN VARCHAR;
	FUNCTION getidentname(pitem VARCHAR) RETURN VARCHAR;
	FUNCTION getidentdlg(pitem VARCHAR) RETURN NUMBER;

	FUNCTION getactivitytext(pactivity NUMBER) RETURN VARCHAR;
	PROCEDURE fillprofile
	(
		pdlg              NUMBER
	   ,pid               VARCHAR
	   ,pprofile          NUMBER
	   ,pactivity         NUMBER
	   ,pcmd              NUMBER := 0
	   ,pprofilefilterkey VARCHAR
	   ,pprofileexclude   BOOLEAN := FALSE
	);

	PROCEDURE getinstancedata
	(
		pinstance NUMBER
	   ,prow      OUT tfininstance%ROWTYPE
	);

	PROCEDURE chooseprofile(ppage NUMBER);
	PROCEDURE prepareuserright(ppage NUMBER);

	PROCEDURE debugerr(ptext VARCHAR);
	PROCEDURE debug
	(
		ptext  VARCHAR
	   ,plevel NUMBER := 1
	);

	FUNCTION getversion RETURN VARCHAR2 IS
	BEGIN
		RETURN service.formatpackageversion(cpackagename, crevision, cbodyrevision);
	END;

	FUNCTION copydata
	(
		pinstance    NUMBER
	   ,plog         BOOLEAN
	   ,pobjecttype  NUMBER
	   ,pkeyvalue    VARCHAR2
	   ,plogclientid NUMBER
	) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.CopyData';
		vinstance NUMBER;
		vprofile  NUMBER;
		vcnt      NUMBER;
	BEGIN
		s.say(cwhere || ': start');
		IF pinstance IS NOT NULL
		THEN
			vprofile := getinstanceprofile(pinstance);
		
			vinstance := putinstancedata(NULL, vprofile);
			vcnt      := copydatapages(pinstance
									  ,vinstance
									  ,plog
									  ,pobjecttype
									  ,pkeyvalue
									  ,plogclientid);
			IF vcnt = 0
			THEN
				delinstancedata(vinstance);
				vinstance := NULL;
			END IF;
		
		END IF;
		s.say(cwhere || ': complete');
		RETURN vinstance;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE deletedata(pinstance NUMBER) IS
	BEGIN
		s.say(cpackagename || '.DeleteData start');
		delinstancedata(pinstance);
	END;

	FUNCTION getinstanceprofile(pinstance NUMBER) RETURN NUMBER IS
		vrow tfininstance%ROWTYPE;
	BEGIN
		IF pinstance IS NOT NULL
		THEN
			getinstancedata(pinstance, vrow);
		END IF;
		RETURN vrow.profile;
	END;

	FUNCTION getpageprofile
	(
		ppage  NUMBER
	   ,pident VARCHAR
	) RETURN NUMBER IS
		vprofile NUMBER;
		vp       NUMBER := getctxpage(ppage, pident);
	BEGIN
		debug('GetPageProfile, ' || ppage || ',' || pident);
		testctxpage(vp);
		vprofile := finprofile.getitemprofile(vp, makeident(vp, idprof));
	
		RETURN vprofile;
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('GetPageProfile, ' || ppage || ',' || pident || ',' || vp);
			error.save('FinInstance.GetPageProfile');
			RAISE;
	END;

	PROCEDURE setpageprofilefocus
	(
		ppage  NUMBER
	   ,pident VARCHAR
	) IS
		vp NUMBER := getctxpage(ppage, pident);
	BEGIN
		debug('SetPageProfileFocus, ' || ppage || ',' || pident);
		testctxpage(vp);
		dialog.goitem(vp, makeident(vp, idprof));
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('SetPageProfileFocus, ' || ppage || ',' || pident || ',' || vp);
			error.save('FinInstance.SetPageProfileFocus');
			RAISE;
	END;

	PROCEDURE enablepage
	(
		ppage   NUMBER
	   ,pident  VARCHAR
	   ,penable BOOLEAN := TRUE
	   ,pclear  BOOLEAN := FALSE
	) IS
		cprocname CONSTANT VARCHAR2(100) := cpackagename || '.EnablePage';
		vid     VARCHAR(64);
		vidlist VARCHAR(64);
		vp      NUMBER := getctxpage(ppage, pident);
		vidbtn  VARCHAR(64);
	BEGIN
		debug('EnablePage, ' || ppage || ',' || pident);
		vid     := makeident(vp, idprof);
		vidlist := makeident(vp, idpagelist);
		vidbtn  := makeident(vp, idfilter);
	
		testctxpage(vp);
		IF pclear
		THEN
			fillprofile(vp, vid, NULL, getctxactivity(vp), 0, NULL);
			clearpages(vp);
		END IF;
	
		dialog.setenabled(vp, vid, penable);
	
		enablepages(vp, penable);
	
		IF dialog.existsitembyname(vp, vidbtn)
		THEN
			dialog.setenable(vp, vidbtn, penable);
		END IF;
	
	END;

	PROCEDURE makepage
	(
		ppage     NUMBER
	   ,pident    VARCHAR
	   ,pwidth    NUMBER
	   ,pheight   NUMBER
	   ,pactivity NUMBER
	   ,peditmode BOOLEAN
	   ,pfilter   BOOLEAN := FALSE
	   ,pinfo     BOOLEAN := FALSE
	) IS
	BEGIN
		makepage(ppage, pident, 1, 2, pwidth, pheight, pactivity, peditmode, pfilter, pinfo);
	END;

	PROCEDURE makepage
	(
		ppage     NUMBER
	   ,pident    VARCHAR
	   ,px        NUMBER
	   ,py        NUMBER
	   ,pwidth    NUMBER
	   ,pheight   NUMBER
	   ,pactivity NUMBER
	   ,peditmode BOOLEAN
	   ,pfilter   BOOLEAN := FALSE
	   ,pinfo     BOOLEAN := FALSE
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.MakePage';
		vid     VARCHAR(64) := makeident(ppage, idprof);
		vidlist VARCHAR(64) := makeident(ppage, idpagelist);
		vidbtn  VARCHAR(64);
	BEGIN
		s.say(cwhere || ': start [Page=' || ppage || ', Ident=' || pident || ']');
		debug('MakePage, pEditMode - ' || service.iif(peditmode, 'true', 'false'));
	
		initpagecontext(ppage, pident);
		setctxactivity(ppage, pactivity);
		setctxcheckuserright(ppage, FALSE);
		setctxlogenable(ppage, FALSE);
	
		IF pfilter
		THEN
			finprofile.makeitemprofile(ppage
									  ,vid
									  ,pactivity
									  ,px + 12
									  ,py
									  ,pwidth - px - 36
									  ,'Profile:'
									  ,'Financial profile');
		ELSE
			finprofile.makeitemprofile(ppage
									  ,vid
									  ,pactivity
									  ,px + 12
									  ,py
									  ,pwidth - px - 30
									  ,'Profile:'
									  ,'Financial profile');
		END IF;
	
		dialog.setitempost(ppage, vid, 'FinInstance.PageProc');
	
		dialog.textlabel(ppage
						,idprofilecode
						,pwidth - 6
						,py
						,5
						,''
						,pcaption => 'Code:'
						,panchor => dialog.anchor_left + dialog.anchor_top);
		IF pfilter
		THEN
		
			vidbtn := makeident(ppage, idfilter);
			dialog.button(ppage
						 ,vidbtn
						 ,pwidth - 20
						 ,py
						 ,20
						 ,'Available profiles'
						 ,0
						 ,0
						 ,'Select available profiles'
						 ,'FinInstance.PageProc'
						 ,panchor => dialog.anchor_left + dialog.anchor_top);
			dialog.setvisible(ppage, idprofilecode, FALSE);
			dialog.setenable(ppage, vidbtn, peditmode);
		
		END IF;
	
		dialog.pagelist(ppage, vidlist, px, py + 2, pwidth, pheight - 4);
	
		createpages(ppage, vidlist, pwidth, pheight - 4, pactivity, peditmode, pinfo);
	
		dialog.setdialogpre(ppage, 'FinInstance.PageProc');
		dialog.setdialogpost(ppage, 'FinInstance.PageProc');
	EXCEPTION
		WHEN OTHERS THEN
			error.save('FinInstance.MakePage');
			error.showerror;
	END;

	PROCEDURE loadpage
	(
		ppage             NUMBER
	   ,pident            VARCHAR
	   ,pprofile          NUMBER
	   ,pinstance         NUMBER
	   ,pprofilefilterkey VARCHAR := NULL
	) IS
		vid       VARCHAR(64);
		vprofile  NUMBER;
		vinstance NUMBER;
		vp        NUMBER := getctxpage(ppage, pident);
	BEGIN
	
		debug('LoadPage, ' || ppage || ',' || pident || ',' || vp);
		vid := makeident(vp, idprof);
	
		vprofile  := nvl(pprofile, getinstanceprofile(pinstance));
		vinstance := pinstance;
	
		setctxinstanceprofile(vp, vprofile);
		setctxinstance(vp, vinstance);
		setctxprofile(vp, vprofile);
		setctxfilterkey(vp, pprofilefilterkey);
	
		fillprofile(vp, vid, vprofile, getctxactivity(vp), 0, getctxfilterkey(vp));
		loadpages(vp, vprofile, vinstance);
		dialog.putchar(vp, idprofilecode, to_char(vprofile));
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('LoadPage, ' || ppage || ',' || pident || ',' || pprofile || ',' || pinstance || ',' || vp || ',' || vid);
			error.save('FinInstance.LoadPage');
			RAISE;
	END;

	FUNCTION savepage
	(
		ppage     NUMBER
	   ,pident    VARCHAR
	   ,pprofile  NUMBER
	   ,pinstance NUMBER
	) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.SavePage';
		vcnt             NUMBER;
		vinstance        NUMBER := pinstance;
		vchangeflag      BOOLEAN;
		vinstanceprofile NUMBER;
		vctxpage         NUMBER := getctxpage(ppage, pident);
		vobjecttype      NUMBER;
		vkeyvalue        VARCHAR2(40);
	BEGIN
		s.say(cwhere || ': start[Page=' || ppage || ', Ident=' || pident || ', ParentPage=' ||
			  vctxpage || ', Instance = ' || pinstance || ']');
		vinstanceprofile := getctxinstanceprofile(vctxpage);
		vchangeflag      := (nvl(pprofile, 0) != nvl(vinstanceprofile, 0));
	
		IF getctxlogenable(vctxpage)
		THEN
			vobjecttype := getctxlogobjecttype(vctxpage);
			vkeyvalue   := getctxlogkey(vctxpage);
		END IF;
	
		IF pprofile IS NULL
		THEN
		
			delinstancedata(pinstance, vobjecttype, vkeyvalue);
			vinstance := NULL;
		
		ELSE
		
			vcnt := getnumberofchanges(vctxpage, pprofile);
			IF vcnt > 0
			THEN
				vinstance := putinstancedata(pinstance, pprofile, vobjecttype, vkeyvalue);
			END IF;
			vcnt := savepages(vctxpage, pprofile, vinstance);
		
		END IF;
	
		RETURN vinstance;
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('SavePage, ' || ppage || ',' || pident || ',' || pprofile || ',' || pinstance || ',' ||
					 vctxpage);
			error.save('FinInstance.SavePage');
			RAISE;
	END;

	PROCEDURE pageproc
	(
		pwhat VARCHAR
	   ,pdlg  NUMBER
	   ,pitem VARCHAR
	   ,pcmd  NUMBER
	) IS
		vpage   NUMBER;
		vid     VARCHAR(64);
		vdialog NUMBER;
		vcmd    NUMBER;
	BEGIN
	
		IF pwhat = dialog.wtdialogpre
		THEN
		
			NULL;
		
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF getidentname(pitem) = idfilter
			THEN
				vpage   := getidentdlg(pitem);
				vid     := makeident(vpage, idprof);
				vdialog := finprofilefilter.setupfilterdlg(getctxactivity(vpage)
														  ,getctxfilterkey(vpage));
				vcmd    := dialog.execdialog(vdialog);
				IF vcmd = dialog.cmok
				THEN
					fillprofile(vpage
							   ,vid
							   ,getctxprofile(vpage)
							   ,getctxactivity(vpage)
							   ,0
							   ,getctxfilterkey(vpage)
							   ,TRUE);
					chooseprofile(vpage);
				END IF;
			END IF;
		
		ELSIF pwhat = dialog.wt_nextfield
		THEN
			IF getidentname(pitem) = idprof
			THEN
				vpage := getidentdlg(pitem);
				chooseprofile(vpage);
			END IF;
			NULL;
		
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			NULL;
		
		ELSIF pwhat = dialog.wtdialogpost
		THEN
		
			NULL;
		
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save('FinInstance.PageProc');
			error.showerror;
			dialog.goitem(pdlg, NULL);
	END;

	FUNCTION getsecurityarray RETURN custom_security.typerights IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetSecurityArray';
		varights custom_security.typerights;
		vindex   NUMBER := 1;
	
		PROCEDURE addrecord
		(
			pkey   VARCHAR2
		   ,ptext  VARCHAR2
		   ,pfinal BOOLEAN := FALSE
		) IS
		BEGIN
			varights(vindex).key := pkey;
			varights(vindex).text := ptext;
			varights(vindex).final := pfinal;
			vindex := vindex + 1;
		END;
	
	BEGIN
		addrecord(right_exchange, 'Change financial profile', TRUE);
		addrecord(right_override, 'Redefine profile components', TRUE);
		RETURN varights;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE fillsecurityarray IS
	BEGIN
	
		security.addrecord(right_exchange, 'Change financial profile', TRUE);
		security.addrecord(right_override, 'Redefine profile components', TRUE);
	
	END;

	PROCEDURE fillsecuritytree
	(
		porights    IN OUT NOCOPY types.utree
	   ,pparentnode PLS_INTEGER
	) IS
	BEGIN
		security.addrightnode(porights, pparentnode, right_exchange, 'Change financial profile');
		security.addrightnode(porights, pparentnode, right_override, 'Redefine profile components');
	END;

	FUNCTION getsecuritykey
	(
		ppage   NUMBER
	   ,pident  VARCHAR
	   ,pobject OUT VARCHAR
	   ,pkey    OUT VARCHAR
	) RETURN BOOLEAN IS
		vp NUMBER := getctxpage(ppage, pident);
	BEGIN
		testctxpage(vp);
		pobject := getctxuserobject(vp);
		pkey    := getctxuserkey(vp);
		RETURN getctxcheckuserright(vp);
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('GetSecurityKey, pg:' || ppage || ',' || pident || ',' || vp);
			RAISE;
	END;

	PROCEDURE setsecuritykey
	(
		ppage   NUMBER
	   ,pident  VARCHAR
	   ,pobject VARCHAR
	   ,pkey    VARCHAR
	) IS
		vp NUMBER := getctxpage(ppage, pident);
	BEGIN
		testctxpage(vp);
		setctxuserobject(vp, pobject);
		setctxuserkey(vp, pkey);
		setctxcheckuserright(vp, TRUE);
	
		prepareuserright(vp);
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('FinInstance.SetSecurityKey, pg:' || ppage || ',' || pident || ',' || vp ||
					 ', ob:' || pobject || ', k:' || pkey);
			RAISE;
	END;

	PROCEDURE setlogkey
	(
		ppage        NUMBER
	   ,pident       VARCHAR
	   ,pobject      VARCHAR
	   ,pkey         VARCHAR
	   ,plogclientid NUMBER
	) IS
		vp NUMBER := getctxpage(ppage, pident);
	BEGIN
		testctxpage(vp);
		setctxlogobject(vp, pobject);
		setctxlogobjecttype(vp, object.gettype(pobject));
		setctxlogkey(vp, nvl(pkey, ' Copy ?'));
		setctxlogclientid(vp, plogclientid);
	
		setctxlogenable(vp, TRUE);
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('FinInstance.SetLogKey, pg:' || ppage || ',' || pident || ',' || vp ||
					 ', ob:' || pobject || ', k:' || pkey);
			RAISE;
	END;

	FUNCTION getlogkey
	(
		ppage        NUMBER
	   ,pident       VARCHAR
	   ,pobject      OUT VARCHAR
	   ,pkey         OUT VARCHAR
	   ,ologclientid OUT NUMBER
	) RETURN BOOLEAN IS
		vp NUMBER := getctxpage(ppage, pident);
	BEGIN
		testctxpage(vp);
		pobject      := getctxlogobject(vp);
		pkey         := getctxlogkey(vp);
		ologclientid := getctxlogclientid(vp);
		RETURN getctxlogenable(vp);
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('FinInstance.GetLogKey, pg:' || ppage || ',' || pident || ',' || vp);
			RAISE;
	END;

	PROCEDURE createpages
	(
		pdlg      NUMBER
	   ,pid       VARCHAR
	   ,pwidth    NUMBER
	   ,pheight   NUMBER
	   ,pactivity NUMBER
	   ,peditmode BOOLEAN
	   ,pinfo     BOOLEAN := FALSE
	) IS
	BEGIN
	
		IF finprofile.ispagecommission(pactivity, fincommission.co_subtype_one)
		THEN
			setctxpagecomm(pdlg
						  ,fininstancecommission.page(pdlg
													 ,pid
													 ,pwidth
													 ,pheight
													 ,pactivity
													 ,peditmode
													 ,pinfo));
		END IF;
	
		IF finprofile.ispagecommission(pactivity, fincommission.co_subtype_two)
		THEN
			setctxpagecom2(pdlg
						  ,fininstancecommission2.page(pdlg
													  ,pid
													  ,pwidth
													  ,pheight
													  ,pactivity
													  ,peditmode
													  ,pinfo));
		END IF;
	
		IF finprofile.ispagepayment(pactivity)
		THEN
			setctxpagepay(pdlg
						 ,fininstancepayment.page(pdlg
												 ,pid
												 ,pwidth
												 ,pheight
												 ,pactivity
												 ,peditmode
												 ,pinfo));
		END IF;
	
		IF finprofile.ispageretadjust(pactivity)
		THEN
			setctxpageret(pdlg
						 ,fininstanceretadjust.page(pdlg
												   ,pid
												   ,pwidth
												   ,pheight
												   ,pactivity
												   ,peditmode));
		END IF;
	END;

	PROCEDURE loadpages
	(
		pdlg      NUMBER
	   ,pprofile  NUMBER
	   ,pinstance NUMBER
	) IS
		vflag BOOLEAN := (nvl(getctxinstanceprofile(pdlg), 0) = nvl(pprofile, 0));
	BEGIN
	
		fininstancecommission3.clear();
	
		fininstancecommission.load(getctxpagecomm(pdlg), pprofile, pinstance, vflag);
		fininstancecommission2.load(getctxpagecom2(pdlg), pprofile, pinstance, vflag);
	
		fininstancecommission3.load(pprofile, pinstance, fincommission.co_subtype_four);
	
		fininstancepayment.load(getctxpagepay(pdlg), pprofile, pinstance, vflag);
		fininstanceretadjust.load(getctxpageret(pdlg), pprofile, pinstance, vflag);
	
		fininstancecommissiondata.copyinsttomultytemp(pinstance);
	
	END;

	FUNCTION copydatapages
	(
		pinstancefrom NUMBER
	   ,pinstanceto   NUMBER
	   ,plog          BOOLEAN
	   ,pobjecttype   NUMBER
	   ,pkeyvalue     VARCHAR2
	   ,plogclientid  NUMBER
	) RETURN NUMBER IS
		vcnt NUMBER := 0;
	BEGIN
		vcnt := vcnt + fininstancecommission.copydata(pinstancefrom
													 ,pinstanceto
													 ,plog
													 ,pobjecttype
													 ,pkeyvalue
													 ,plogclientid);
		vcnt := vcnt + fininstancecommission2.copydata(pinstancefrom
													  ,pinstanceto
													  ,plog
													  ,pobjecttype
													  ,pkeyvalue
													  ,plogclientid);
		vcnt := vcnt + fininstancepayment.copydata(pinstancefrom
												  ,pinstanceto
												  ,plog
												  ,pobjecttype
												  ,pkeyvalue
												  ,plogclientid);
		vcnt := vcnt + fininstanceretadjust.copydata(pinstancefrom, pinstanceto);
	
		vcnt := vcnt + fininstancecommission3.copydata(pinstancefrom
													  ,pinstanceto
													  ,fincommission.co_subtype_three
													  ,plog
													  ,pobjecttype
													  ,pkeyvalue
													  ,plogclientid);
		vcnt := vcnt + fininstancecommission3.copydata(pinstancefrom
													  ,pinstanceto
													  ,fincommission.co_subtype_four
													  ,plog
													  ,pobjecttype
													  ,pkeyvalue
													  ,plogclientid);
	
		vcnt := vcnt + fininstancecommissiondata.copyplandata(pinstancefrom
															 ,pinstanceto
															 ,plog
															 ,pobjecttype
															 ,pkeyvalue
															 ,plogclientid);
	
		RETURN vcnt;
	END;

	FUNCTION getnumberofchanges
	(
		pdlg     NUMBER
	   ,pprofile NUMBER
	) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.GetNumberOfChanges';
		vcount       NUMBER := 0;
		vobjecttype  NUMBER;
		vkeyvalue    VARCHAR2(40);
		vlogclientid NUMBER;
	BEGIN
		s.say(cwhere || ': start [Profile=' || pprofile || ']');
		vobjecttype  := fininstance.getctxlogobjecttype(pdlg);
		vkeyvalue    := fininstance.getctxlogkey(pdlg);
		vlogclientid := fininstance.getctxlogclientid(pdlg);
	
		vcount := vcount + fininstancecommission.getnumberofchanges(getctxpagecomm(pdlg), pprofile);
		vcount := vcount +
				  fininstancecommission2.getnumberofchanges(getctxpagecom2(pdlg), pprofile);
		vcount := vcount + fininstancepayment.getnumberofchanges(getctxpagepay(pdlg), pprofile);
		vcount := vcount + fininstanceretadjust.getnumberofchanges(getctxpageret(pdlg), pprofile);
		vcount := vcount + fininstancecommission3.getnumberofchanges;
	
		s.say(cwhere || ': return ' || vcount);
	
		RETURN vcount;
	END;

	FUNCTION savepages
	(
		pdlg      NUMBER
	   ,pprofile  NUMBER
	   ,pinstance NUMBER
	) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.SavePages';
		vcnt         NUMBER := 0;
		vobjecttype  NUMBER;
		vkeyvalue    VARCHAR2(40);
		vlogclientid NUMBER;
	BEGIN
		s.say(cwhere || ': start [Instance=' || pinstance || ', Profile=' || pprofile || ']');
		vobjecttype  := fininstance.getctxlogobjecttype(pdlg);
		vkeyvalue    := fininstance.getctxlogkey(pdlg);
		vlogclientid := fininstance.getctxlogclientid(pdlg);
	
		vcnt := vcnt + fininstancecommission.save(getctxpagecomm(pdlg), pprofile, pinstance);
		vcnt := vcnt + fininstancecommission2.save(getctxpagecom2(pdlg), pprofile, pinstance);
		vcnt := vcnt + fininstancepayment.save(getctxpagepay(pdlg), pprofile, pinstance);
		vcnt := vcnt + fininstanceretadjust.save(getctxpageret(pdlg), pprofile, pinstance);
	
		vcnt := vcnt + fininstancecommission3.save(pprofile
												  ,pinstance
												  ,TRUE
												  ,vobjecttype
												  ,vkeyvalue
												  ,vlogclientid);
	
		fininstancecommissiondata.copymultytemptoinst(pinstance
													 ,TRUE
													 ,vobjecttype
													 ,vkeyvalue
													 ,vlogclientid);
	
		fininstancecommissiondata.clearmultytemp;
	
		RETURN vcnt;
	END;

	PROCEDURE clearpages(pdlg NUMBER) IS
	BEGIN
		fininstancecommission.clear(getctxpagecomm(pdlg));
		fininstancecommission2.clear(getctxpagecom2(pdlg));
		fininstancepayment.clear(getctxpagepay(pdlg));
		fininstanceretadjust.clear(getctxpageret(pdlg));
	END;

	PROCEDURE resetpages(pdlg NUMBER) IS
	BEGIN
		fininstancecommission.reset(getctxpagecomm(pdlg));
		fininstancecommission2.reset(getctxpagecom2(pdlg));
		fininstancepayment.reset(getctxpagepay(pdlg));
		fininstanceretadjust.reset(getctxpageret(pdlg));
	END;

	FUNCTION getactivitytext(pactivity NUMBER) RETURN VARCHAR IS
	BEGIN
		RETURN finprofile.getactivitytext(pactivity);
	END;

	PROCEDURE setprofile
	(
		pdlg     NUMBER
	   ,pprofile NUMBER
	) IS
		vid VARCHAR(64) := makeident(pdlg, idprof);
	BEGIN
		testctxpage(pdlg);
		finprofile.setitemprofile(pdlg, vid, pprofile);
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('SetProfile, ' || pdlg || ',' || pprofile);
			RAISE;
	END;

	PROCEDURE chooseprofile(ppage NUMBER) IS
		vid       VARCHAR(64) := makeident(ppage, idprof);
		vprofile  NUMBER := getctxprofile(ppage);
		vinstance NUMBER := getctxinstance(ppage);
	BEGIN
	
		checkuserright(ppage, right_exchange);
	
		vprofile := finprofile.getitemprofile(ppage, vid);
		setctxprofile(ppage, vprofile);
	
		loadpages(ppage, vprofile, vinstance);
	
		dialog.putchar(ppage, idprofilecode, to_char(vprofile));
		dialog.goitem(ppage, NULL);
	EXCEPTION
		WHEN OTHERS THEN
		
			setprofile(ppage, vprofile);
			RAISE;
	END;

	PROCEDURE fillprofile
	(
		pdlg              NUMBER
	   ,pid               VARCHAR
	   ,pprofile          NUMBER
	   ,pactivity         NUMBER
	   ,pcmd              NUMBER := 0
	   ,pprofilefilterkey VARCHAR
	   ,pprofileexclude   BOOLEAN := FALSE
	) IS
	BEGIN
		finprofile.fillitemprofile(pdlg
								  ,pid
								  ,pactivity
								  ,pprofile
								  ,pcmd
								  ,TRUE
								  ,pprofilefilterkey
								  ,pprofileexclude);
	END;

	PROCEDURE initpagecontext
	(
		pdlg   NUMBER
	   ,pident VARCHAR
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.InitPageContext';
	BEGIN
		s.say(cwhere || ': start [Dlg=' || pdlg || ', Ident=' || pident || ']');
	
		IF dialog.existsitembyname(pdlg, pident || ctxpage)
		THEN
			error.raiseuser('Same page context already exists: ' || pdlg || ',' || pident);
		END IF;
	
		dialog.hiddennumber(pdlg, ctxactivity);
		dialog.hiddennumber(pdlg, ctxinstanceprofile);
		dialog.hiddennumber(pdlg, ctxprofile);
		dialog.hiddennumber(pdlg, ctxinstance);
		dialog.hiddenchar(pdlg, ctxfilterkey);
	
		dialog.hiddennumber(pdlg, ctxpagecomm);
		dialog.hiddennumber(pdlg, ctxpagecom2);
		dialog.hiddennumber(pdlg, ctxpagepaym);
		dialog.hiddennumber(pdlg, ctxpagereta);
	
		dialog.hiddenbool(pdlg, ctxcheckuserright);
		dialog.hiddenchar(pdlg, ctxuserobject);
		dialog.hiddenchar(pdlg, ctxuserkey);
	
		dialog.hiddenbool(pdlg, ctxlogenable);
		dialog.hiddennumber(pdlg, ctxlogobjecttype);
		dialog.hiddenchar(pdlg, ctxlogkey);
		dialog.hiddennumber(pdlg, ctxlogclientid);
	
		dialog.hiddenchar(pdlg, ctxident, pident);
	
		dialog.hiddennumber(pdlg, pident || ctxpage, pdlg);
		dialog.hiddennumber(pdlg, makeident(pdlg, ctxtest), co_testctx);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save('FinInstance.InitPageContext');
			RAISE;
	END;

	PROCEDURE testctxpage(ppage NUMBER) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.TestCTXpage';
		vtestctx NUMBER;
	BEGIN
		vtestctx := dialog.getnumber(ppage, makeident(ppage, ctxtest));
	
		IF nvl(vtestctx != co_testctx, TRUE)
		THEN
			error.raiseuser('Invalid page context, page:' || ppage);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION getctxpage
	(
		pdlg   NUMBER
	   ,pident VARCHAR
	) RETURN NUMBER IS
	BEGIN
		RETURN dialog.getnumber(pdlg, pident || ctxpage);
	END;

	PROCEDURE setctxactivity
	(
		pdlg      NUMBER
	   ,pactivity NUMBER
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putnumber(pdlg, ctxactivity, pactivity);
	END;

	FUNCTION getctxactivity(pdlg NUMBER) RETURN NUMBER IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getnumber(pdlg, ctxactivity);
	END;

	PROCEDURE setctxinstanceprofile
	(
		pdlg             NUMBER
	   ,pinstanceprofile NUMBER
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putnumber(pdlg, ctxinstanceprofile, pinstanceprofile);
	END;

	FUNCTION getctxinstanceprofile(pdlg NUMBER) RETURN NUMBER IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getnumber(pdlg, ctxinstanceprofile);
	END;

	PROCEDURE setctxprofile
	(
		pdlg     NUMBER
	   ,pprofile NUMBER
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putnumber(pdlg, ctxprofile, pprofile);
	END;

	FUNCTION getctxprofile(pdlg NUMBER) RETURN NUMBER IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getnumber(pdlg, ctxprofile);
	END;

	PROCEDURE setctxinstance
	(
		pdlg      NUMBER
	   ,pinstance NUMBER
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putnumber(pdlg, ctxinstance, pinstance);
	END;

	FUNCTION getctxinstance(pdlg NUMBER) RETURN NUMBER IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getnumber(pdlg, ctxinstance);
	END;

	PROCEDURE setctxfilterkey
	(
		pdlg              NUMBER
	   ,pprofilefilterkey VARCHAR
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putchar(pdlg, ctxfilterkey, pprofilefilterkey);
	END;

	FUNCTION getctxfilterkey(pdlg NUMBER) RETURN VARCHAR IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getchar(pdlg, ctxfilterkey);
	END;

	PROCEDURE setctxpagecomm
	(
		pdlg  NUMBER
	   ,ppage NUMBER
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putnumber(pdlg, ctxpagecomm, ppage);
	END;

	FUNCTION getctxpagecomm(pdlg NUMBER) RETURN NUMBER IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getnumber(pdlg, ctxpagecomm);
	END;

	PROCEDURE setctxpagecom2
	(
		pdlg  NUMBER
	   ,ppage NUMBER
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putnumber(pdlg, ctxpagecom2, ppage);
	END;

	FUNCTION getctxpagecom2(pdlg NUMBER) RETURN NUMBER IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getnumber(pdlg, ctxpagecom2);
	END;

	PROCEDURE setctxpagepay
	(
		pdlg  NUMBER
	   ,ppage NUMBER
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putnumber(pdlg, ctxpagepaym, ppage);
	END;

	FUNCTION getctxpagepay(pdlg NUMBER) RETURN NUMBER IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getnumber(pdlg, ctxpagepaym);
	END;

	PROCEDURE setctxpageret
	(
		pdlg  NUMBER
	   ,ppage NUMBER
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putnumber(pdlg, ctxpagereta, ppage);
	END;

	FUNCTION getctxpageret(pdlg NUMBER) RETURN NUMBER IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getnumber(pdlg, ctxpagereta);
	END;

	PROCEDURE setctxcheckuserright
	(
		pdlg NUMBER
	   ,pval BOOLEAN
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putbool(pdlg, ctxcheckuserright, pval);
	END;

	FUNCTION getctxcheckuserright(pdlg NUMBER) RETURN BOOLEAN IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getbool(pdlg, ctxcheckuserright);
	END;

	PROCEDURE setctxuserobject
	(
		pdlg NUMBER
	   ,pval VARCHAR
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putchar(pdlg, ctxuserobject, pval);
	END;

	FUNCTION getctxuserobject(pdlg NUMBER) RETURN VARCHAR IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getchar(pdlg, ctxuserobject);
	END;

	PROCEDURE setctxuserkey
	(
		pdlg NUMBER
	   ,pval VARCHAR
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putchar(pdlg, ctxuserkey, pval);
	END;

	FUNCTION getctxuserkey(pdlg NUMBER) RETURN VARCHAR IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getchar(pdlg, ctxuserkey);
	END;

	PROCEDURE setctxlogenable
	(
		pdlg NUMBER
	   ,pval BOOLEAN
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putbool(pdlg, ctxlogenable, pval);
	END;

	FUNCTION getctxlogenable(pdlg NUMBER) RETURN BOOLEAN IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getbool(pdlg, ctxlogenable);
	END;

	PROCEDURE setctxlogobject
	(
		pdlg NUMBER
	   ,pval VARCHAR
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putchar(pdlg, ctxlogobject, pval);
	END;

	FUNCTION getctxlogobject(pdlg NUMBER) RETURN VARCHAR IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getchar(pdlg, ctxlogobject);
	END;

	PROCEDURE setctxlogobjecttype
	(
		pdlg NUMBER
	   ,pval NUMBER
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putnumber(pdlg, ctxlogobjecttype, pval);
	END;

	FUNCTION getctxlogobjecttype(pdlg NUMBER) RETURN NUMBER IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getnumber(pdlg, ctxlogobjecttype);
	END;

	PROCEDURE setctxlogkey
	(
		pdlg NUMBER
	   ,pval VARCHAR
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putchar(pdlg, ctxlogkey, pval);
	END;

	FUNCTION getctxlogkey(pdlg NUMBER) RETURN VARCHAR IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getchar(pdlg, ctxlogkey);
	END;

	PROCEDURE setctxlogclientid
	(
		pdlg         NUMBER
	   ,plogclientid NUMBER
	) IS
	BEGIN
		testctxpage(pdlg);
		dialog.putnumber(pdlg, ctxlogclientid, plogclientid);
	END;

	FUNCTION getctxlogclientid(pdlg NUMBER) RETURN NUMBER IS
	BEGIN
		testctxpage(pdlg);
		RETURN dialog.getnumber(pdlg, ctxlogclientid);
	END;

	FUNCTION getidentname(pitem VARCHAR) RETURN VARCHAR IS
	BEGIN
		RETURN fininstancetools.getidentname(pitem);
	END;

	FUNCTION getidentdlg(pitem VARCHAR) RETURN NUMBER IS
	BEGIN
		RETURN fininstancetools.getidentdlg(pitem);
	END;

	FUNCTION makeident
	(
		pdlg  NUMBER
	   ,pitem VARCHAR
	) RETURN VARCHAR IS
	BEGIN
		RETURN fininstancetools.makeident(pdlg, pitem);
	END;

	PROCEDURE delinstancedata
	(
		pinstance   NUMBER
	   ,pobjecttype NUMBER
	   ,pkeyvalue   VARCHAR2
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.DelInstanceData';
		vprofile NUMBER;
	BEGIN
		s.say(cwhere || ': start [' || pinstance || ']');
		DELETE FROM tfininstance
		WHERE  branch = sbranch
		AND    instance = pinstance
		RETURNING profile INTO vprofile;
	
		s.say(cwhere || ': complete');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE getinstancedata
	(
		pinstance NUMBER
	   ,prow      OUT tfininstance%ROWTYPE
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.GetInstanceData';
	BEGIN
		s.say(cwhere || ': start [' || pinstance || ']');
		SELECT *
		INTO   prow
		FROM   tfininstance
		WHERE  branch = sbranch
		AND    instance = pinstance;
		s.say(cwhere || ': Profile=' || prow.profile);
	EXCEPTION
		WHEN OTHERS THEN
			error.save('FinInstance.GetInstanceData');
			RAISE;
	END;

	FUNCTION putinstancedata
	(
		pinstance   NUMBER
	   ,pprofile    NUMBER
	   ,pobjecttype NUMBER
	   ,pkeyvalue   VARCHAR2
	) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.PutInstanceData';
		vinstance NUMBER;
		voldrow   tfininstance%ROWTYPE;
	BEGIN
		s.say(cwhere || ': [Instance=' || pinstance || ', Profile=' || pprofile || ']');
		SAVEPOINT sp_insertfininstance;
	
		IF pinstance IS NOT NULL
		THEN
		
			getinstancedata(pinstance, voldrow);
			IF NOT htools.equal(voldrow.profile, pprofile)
			THEN
				UPDATE tfininstance
				SET    profile = pprofile
				WHERE  branch = sbranch
				AND    instance = pinstance;
			
			END IF;
			vinstance := pinstance;
		
		ELSE
		
			SELECT seqfininstance.nextval INTO vinstance FROM dual;
		
			INSERT INTO tfininstance
				(branch
				,profile
				,instance)
			VALUES
				(sbranch
				,pprofile
				,vinstance);
		
		END IF;
		s.say(cwhere || ': return ' || vinstance);
		RETURN vinstance;
	
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('PutInstanceData: ' || vinstance || ', ' || pprofile);
			ROLLBACK TO sp_insertfininstance;
			error.save('FinInstance.PutInstanceData');
			RAISE;
	END;

	FUNCTION checkuserright
	(
		ppage  NUMBER
	   ,pright VARCHAR
	) RETURN BOOLEAN IS
	BEGIN
		IF getctxcheckuserright(ppage)
		THEN
			RETURN security.checkright(getctxuserobject(ppage)
									  ,getctxuserkey(ppage) || pright || '|');
		END IF;
		RETURN TRUE;
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('CheckUserRight2, ' || ppage || ',' || pright);
			RAISE;
	END;

	PROCEDURE checkuserright
	(
		ppage  NUMBER
	   ,pright VARCHAR
	) IS
	BEGIN
		IF NOT checkuserright(ppage, pright)
		THEN
			error.raiseuser('You are not authorized to execute operation!~');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('CheckUserRight, ' || ppage || ',' || pright);
			RAISE;
	END;

	PROCEDURE prepareuserright(ppage NUMBER) IS
		vid       VARCHAR(64);
		vidfilter VARCHAR(64);
	BEGIN
		IF NOT checkuserright(ppage, right_exchange)
		THEN
			vid       := makeident(ppage, idprof);
			vidfilter := makeident(ppage, idfilter);
			dialog.setitemattributies(ppage, vid, dialog.select_off);
			dialog.setitemattributies(ppage, vidfilter, dialog.select_off);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('PrepareUserRight, ' || ppage);
			RAISE;
	END;

	PROCEDURE tolog
	(
		ppage   NUMBER
	   ,ptext   VARCHAR
	   ,paction IN NUMBER
	) IS
	BEGIN
		IF getctxlogenable(ppage)
		THEN
			logobject(getctxlogobjecttype(ppage)
					 ,paction
					 ,getctxlogkey(ppage)
					 ,ptext
					 ,getctxlogclientid(ppage));
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('toLog, ' || ppage || ',' || ptext);
			RAISE;
	END;

	PROCEDURE logobject
	(
		pobjecttype  NUMBER
	   ,paction      IN NUMBER
	   ,pkeyvalue    VARCHAR2
	   ,ptext        VARCHAR
	   ,plogclientid NUMBER
	) IS
	BEGIN
		IF pobjecttype IS NOT NULL
		   AND pkeyvalue IS NOT NULL
		THEN
			IF a4mlog.logobject(pobjecttype
							   ,pkeyvalue
							   ,ptext
							   ,paction
							   ,a4mlog.putparamlist
							   ,powner => plogclientid) != 0
			THEN
				error.raiseuser(err.gettext);
			END IF;
		END IF;
		a4mlog.cleanplist;
	EXCEPTION
		WHEN OTHERS THEN
			debugerr('LogObject, ' || pobjecttype || ',' || ptext);
			RAISE;
	END;

	PROCEDURE debug
	(
		ptext  VARCHAR
	   ,plevel NUMBER
	) IS
	BEGIN
		s.say('FinInstance.' || ptext, plevel);
	END;

	PROCEDURE debugerr(ptext VARCHAR) IS
	BEGIN
		IF err.geterrorcode != 0
		THEN
			s.err('FinInstance.' || ptext || ' : ' || err.geterror);
		ELSE
			s.err('FinInstance.' || ptext);
		END IF;
	END;

	PROCEDURE enablepages
	(
		pdlg    NUMBER
	   ,penable BOOLEAN
	) IS
		cprocname CONSTANT VARCHAR2(100) := cpackagename || '.EnablePages';
	BEGIN
		s.say(cprocname || ': start [' || pdlg || ', ' || htools.b2s(penable) || ']');
		fininstancecommission.enablepage(getctxpagecomm(pdlg), penable);
		fininstancecommission2.enablepage(getctxpagecom2(pdlg), penable);
		fininstancepayment.enablepage(getctxpagepay(pdlg), penable);
		fininstanceretadjust.enablepage(getctxpageret(pdlg), penable);
	END;

BEGIN
	sbranch := seance.getbranch();

END;
/
