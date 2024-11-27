CREATE OR REPLACE PACKAGE custom_contracttype AS

	object_name CONSTANT VARCHAR(20) := 'CONTRACTTYPE';
	crevision   CONSTANT VARCHAR2(100) := '$Rev: 63655 $';

	itemaccount CONSTANT NUMBER := 1;

	itemcard CONSTANT NUMBER := 2;

	cclient CONSTANT NUMBER := 1;

	ccorporate CONSTANT NUMBER := 2;

	call_types CONSTANT PLS_INTEGER := cclient + ccorporate;

	SUBTYPE typecontracttype IS tcontracttype.type%TYPE;

	right_view   CONSTANT NUMBER := 0;
	right_modify CONSTANT NUMBER := 1;
	right_change CONSTANT NUMBER := 2;

	right_scheme_parameters CONSTANT NUMBER := 3;

	get_scheme_parameters_rights VARCHAR2(30) := 'GET_SCHEME_PARAMETERS_RIGHTS';

	can_modify BOOLEAN;
	can_view   BOOLEAN;
	can_change BOOLEAN;

	TYPE typecheckrightparams IS RECORD(
		 contracttype typecontracttype
		,schemetype   tcontractschemas.type%TYPE
		,rightident   VARCHAR2(40));

	semptyrightparams typecheckrightparams;

	TYPE tarrnumber IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	TYPE tarrvarchar IS TABLE OF VARCHAR(40) INDEX BY BINARY_INTEGER;
	samultisel    tarrnumber;
	sselectedcode NUMBER;
	saaccessory   tarrvarchar;

	ccontracttypebranch CONSTANT VARCHAR2(20) := 'CTBranch';

	csortbyschemacust CONSTANT VARCHAR2(1) := '1';
	csortbyschemacode CONSTANT VARCHAR2(1) := '2';
	csortbytypecode   CONSTANT VARCHAR2(1) := '3';
	csortbytypeno     CONSTANT VARCHAR2(1) := '4';
	csortbytypename   CONSTANT VARCHAR2(1) := '5';
	csortreversesign  CONSTANT VARCHAR2(1) := '-';

	csortbyorder  CONSTANT VARCHAR2(20) := 'SortByOrder';
	csortbycode   CONSTANT VARCHAR2(20) := 'SortByCode';
	csortbyname   CONSTANT VARCHAR2(20) := 'SortByName';
	csortbyschema CONSTANT VARCHAR2(20) := 'SortBySchema';

	TYPE typectypefilter IS RECORD(
		 useviewoption BOOLEAN := FALSE
		,userrights    VARCHAR2(20) := NULL
		,schematype    NUMBER := NULL
		,ctgroup       NUMBER := NULL
		,accessory     NUMBER := NULL
		,readonly      BOOLEAN := FALSE
		,enablenull    BOOLEAN := FALSE
		,favoriteonly  BOOLEAN := FALSE
		,activeonly    BOOLEAN := FALSE
		,
		
		startdate DATE
		,enddate   DATE
		,
		
		excludedtype typecontracttype := NULL
		,selectedonly BOOLEAN := FALSE);

	fl_default typectypefilter;
	fl_browse  typectypefilter;

	fl_findercn typectypefilter;
	fl_createcn typectypefilter;

	TYPE typelistparams IS RECORD(
		 canselect   BOOLEAN := TRUE
		,multiselect BOOLEAN := FALSE
		,userproc    VARCHAR2(61) := NULL
		,width       NUMBER := 6
		,labellength NUMBER := 40
		,sizetype    NUMBER := 6
		,sizename    NUMBER := 60
		,sizepackage NUMBER := 0);
	lp_default     typelistparams;
	lp_showpackage typelistparams;

	TYPE typeselectedctlist IS TABLE OF ttempcontracttype%ROWTYPE INDEX BY BINARY_INTEGER;

	FUNCTION getversion RETURN VARCHAR2;

	FUNCTION getcontracttype4dc(ptype NUMBER) RETURN apitypesfordc.typecontracttyperecord;

	PROCEDURE makeitem
	(
		pdialog      IN NUMBER
	   ,pitem        IN VARCHAR
	   ,px           IN NUMBER
	   ,py           IN NUMBER
	   ,pwidth       IN NUMBER
	   ,pcaption     IN VARCHAR
	   ,phint        IN VARCHAR := NULL
	   ,plablen      IN NUMBER := 50
	   ,pmultisel    IN BOOLEAN := FALSE
	   ,paccessory   IN NUMBER := cclient
	   ,puserproc    IN VARCHAR := NULL
	   ,pctypefilter typectypefilter := NULL
	);

	PROCEDURE makeitem2
	(
		pdialog      IN NUMBER
	   ,pitem        IN VARCHAR
	   ,px           IN NUMBER
	   ,py           IN NUMBER
	   ,pcaption     IN VARCHAR
	   ,phint        IN VARCHAR
	   ,plistparams  IN typelistparams
	   ,pctypefilter IN typectypefilter
	   ,pcmd         IN NUMBER := 0
	);

	PROCEDURE itemhandler
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN VARCHAR
	   ,pcmd    IN NUMBER
	);

	PROCEDURE setdata
	(
		pdialog IN NUMBER
	   ,pitem   IN VARCHAR
	   ,pdata   IN VARCHAR
	);
	FUNCTION getdata
	(
		pdialog IN NUMBER
	   ,pitem   IN VARCHAR
	) RETURN VARCHAR;

	FUNCTION dialoglist
	(
		pselection IN BOOLEAN := FALSE
	   ,pmultisel  IN BOOLEAN := FALSE
	) RETURN NUMBER;
	PROCEDURE dialoglisthandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);

	PROCEDURE dialogtypehandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE dialogservicehandler
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN CHAR
	   ,pcmd    IN NUMBER
	);

	PROCEDURE clearmultisel;

	PROCEDURE fillsecurityarray
	(
		plevel IN NUMBER
	   ,pkey   IN VARCHAR
	);
	FUNCTION getrightkey
	(
		pright       IN NUMBER
	   ,prightparams IN typecheckrightparams := semptyrightparams
	) RETURN VARCHAR2;

	FUNCTION gencontractno(pcontract IN contract.typecontractrow) RETURN tcontract.no%TYPE;

	FUNCTION filllist
	(
		pdialog      IN NUMBER
	   ,pitemname    IN VARCHAR
	   ,pcmd         IN NUMBER
	   ,pctypefilter IN typectypefilter
	) RETURN NUMBER;

	FUNCTION filllist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) RETURN NUMBER;

	FUNCTION getitemfilter
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	) RETURN typectypefilter;
	PROCEDURE updateitemfilter
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pfilter   IN typectypefilter
	);

	FUNCTION initarray
	(
		paddnotactive IN BOOLEAN := FALSE
	   ,paccessory    IN NUMBER := NULL
	   ,porderprofile IN contractorderprofiles.typeorderprofilefilter := contractorderprofiles.cemptyorderprofile
	   ,pselectedonly IN BOOLEAN := FALSE
	) RETURN NUMBER;

	FUNCTION getarray RETURN custom_fintypes.typecontracttypelist;

	FUNCTION getarraytype(pno IN NUMBER) RETURN NUMBER;
	FUNCTION getarrayname(pno IN NUMBER) RETURN VARCHAR;
	FUNCTION getarrayaccessory(pno IN NUMBER) RETURN VARCHAR;
	FUNCTION getarrayschemaname(pno IN NUMBER) RETURN VARCHAR;

	FUNCTION getcontracttypearray
	(
		paccessory     NUMBER
	   ,pctypesortmode VARCHAR2
	   ,pctypefilter   typectypefilter := NULL
	   ,porderprofile  IN contractorderprofiles.typeorderprofilefilter := contractorderprofiles.cemptyorderprofile
	) RETURN custom_fintypes.typecontracttypelist;

	FUNCTION getrecord(pcontracttype IN typecontracttype
					  ,
					   
					   pdoexception IN BOOLEAN := FALSE) RETURN tcontracttype%ROWTYPE;

	FUNCTION getcontracttyperecord(pcontracttype IN NUMBER) RETURN apitypes.typecontracttyperecord;
	FUNCTION getschematype
	(
		pcontracttype IN NUMBER
	   ,pdoexception  BOOLEAN := FALSE
	) RETURN NUMBER;

	PROCEDURE saveschematype
	(
		pcontracttype IN NUMBER
	   ,pschematype   IN NUMBER
	);

	FUNCTION getname(pctype IN NUMBER) RETURN VARCHAR;
	FUNCTION getschemaname(pctype IN NUMBER) RETURN VARCHAR;

	FUNCTION getschemapackage
	(
		pctype       IN typecontracttype
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN tcontractschemas.packagename%TYPE;

	FUNCTION getaccessory(ptype IN NUMBER) RETURN NUMBER;

	PROCEDURE setdatamembernumber
	(
		pcode  IN NUMBER
	   ,pname  IN VARCHAR
	   ,pvalue IN NUMBER
	);
	FUNCTION getdatamembernumber
	(
		pcode IN NUMBER
	   ,pname IN VARCHAR
	) RETURN NUMBER;

	FUNCTION getcount RETURN NUMBER;
	FUNCTION gettext(pno IN NUMBER) RETURN VARCHAR;
	PROCEDURE setselectedtypes;

	FUNCTION getsortmodesql(pctypesortmode IN VARCHAR2 := NULL) RETURN VARCHAR2;

	FUNCTION getuid(pcontracttype typecontracttype) RETURN NUMBER;
	FUNCTION getuserattributerecord
	(
		pcontracttype IN typecontracttype
	   ,pfieldname    IN VARCHAR2
	) RETURN apitypes.typeuserproprecord;
	FUNCTION getuserattributeslist(pcontracttype IN typecontracttype) RETURN apitypes.typeuserproplist;
	PROCEDURE saveuserattributeslist
	(
		pcontracttype       IN typecontracttype
	   ,plist               apitypes.typeuserproplist
	   ,pclearpropnotinlist BOOLEAN
	);

	FUNCTION checkright
	(
		pright       IN NUMBER
	   ,prightparams IN typecheckrightparams := semptyrightparams
	) RETURN BOOLEAN;

	PROCEDURE setactivecardscount
	(
		pcontracttype     IN typecontracttype
	   ,pactivecardscount IN tcontracttype.activecardscount%TYPE
	);
	FUNCTION getactivecardscount(pcontracttype IN typecontracttype)
		RETURN tcontracttype.activecardscount%TYPE;
	PROCEDURE dialogoptionshandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	FUNCTION getfinprofile(pcontracttype IN typecontracttype) RETURN tcontracttype.finprofile%TYPE;
	PROCEDURE setfinprofile
	(
		pcontracttype IN typecontracttype
	   ,pfinprofile   IN tcontracttype.finprofile%TYPE
	);
	PROCEDURE importcontracttype
	(
		psourcecontracttype IN typecontracttype
	   ,ptargetcontracttype IN typecontracttype
	   ,plog                IN BOOLEAN := TRUE
	);
	FUNCTION allowedacctypechanging RETURN BOOLEAN;

	FUNCTION getcurrdlgcontracttyperecord RETURN apitypes.typecontracttyperecord;
	FUNCTION getcurrentdlguserattributes RETURN apitypes.typeuserproplist;

	FUNCTION activecontracttype
	(
		pcontracttype IN typecontracttype
	   ,poperdate     IN DATE := NULL
	) RETURN BOOLEAN;

	FUNCTION getcontracttypelist
	(
		pschemacode     IN tcontractschemas.type%TYPE := NULL
	   ,psearchtemplate VARCHAR2 := NULL
	   ,paexcludelist   IN tblnumber := tblnumber()
	) RETURN apitypes.typecontracttypelist;

	FUNCTION getcontracttypelistbyoper(poperation IN tcontractschemas.implementedoper%TYPE)
		RETURN apitypes.typecontracttypelist;
	PROCEDURE makelinkedobjectspage
	(
		ppage         NUMBER
	   ,pwidth        NUMBER
	   ,phight        NUMBER
	   ,preadonly     BOOLEAN
	   ,pbuttonwidth  NUMBER
	   ,pstarty       NUMBER
	   ,pcontracttype typecontracttype
	);

	PROCEDURE makelinkedobjectspage_handler
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN CHAR
	   ,pcmd    IN NUMBER
	);
	PROCEDURE saveautocreatepage(pdialog IN NUMBER);
	FUNCTION existstype(pcontracttype IN typecontracttype) RETURN BOOLEAN;
	FUNCTION getsortmodebylist(pasortcodelist IN types.arrstr100) RETURN VARCHAR2;
	PROCEDURE checkcontracttype(pcontracttype IN typecontracttype);
	PROCEDURE refreshlinkedobjectspage(pdialog IN NUMBER);
	FUNCTION getrecordbyident
	(
		pident     IN tcontracttype.ident%TYPE
	   ,puppercase IN BOOLEAN := FALSE
	) RETURN tcontracttype%ROWTYPE;
	PROCEDURE findpanel_handler
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN CHAR
	   ,pcmd    IN NUMBER
	);
	FUNCTION active
	(
		pcontracttype IN typecontracttype
	   ,pondate       IN DATE := NULL
	) RETURN BOOLEAN;

	FUNCTION getsavedsortmode(psetdefaultvalue BOOLEAN := TRUE) RETURN VARCHAR2;
	FUNCTION getsavedsortdesc(psetdefaultvalue BOOLEAN := TRUE) RETURN NUMBER;

	PROCEDURE clearselectedctlist;
	PROCEDURE setselectedctlist(pctlist IN typeselectedctlist);

	PROCEDURE setselectedfullctlist;
END;
/
CREATE OR REPLACE PACKAGE BODY custom_contracttype AS

	cpackage_name CONSTANT VARCHAR(30) := 'ContractType';
	cbodyrevision CONSTANT VARCHAR2(100) := '$Rev: 62486 $';
	csay_level    CONSTANT PLS_INTEGER := 6;

	object_type NUMBER;

	cdlg_list_linkedobjects CONSTANT VARCHAR2(30) := upper('LinkedObjectsList');
	cdlg_pager              CONSTANT VARCHAR2(30) := upper('Pager');
	cdlg_btn_add            CONSTANT VARCHAR2(30) := upper('BtnAdd');
	cdlg_btn_del            CONSTANT VARCHAR2(30) := upper('BtnDel');
	cdlg_hv_readonly        CONSTANT VARCHAR2(30) := upper('ReadOnly');
	cdlg_hv_contracttype    CONSTANT VARCHAR2(30) := upper('ContractType');
	cdlg_hv_scheme          CONSTANT VARCHAR2(30) := upper('ContractScheme');

	cdlg_ident   CONSTANT VARCHAR2(30) := upper('IdentField');
	ctempl_ident CONSTANT VARCHAR2(30) := upper('Type_');

	cdlg_type CONSTANT VARCHAR2(30) := upper('TypeField');

	cdlg_panel         CONSTANT VARCHAR2(30) := upper('DLGPANEL');
	cdlg_grouplist     CONSTANT VARCHAR2(30) := upper('GroupList');
	cdlg_startdate     CONSTANT VARCHAR2(30) := upper('StartDate');
	cdlg_enddate       CONSTANT VARCHAR2(30) := upper('EndDate');
	cdlg_activeonly    CONSTANT VARCHAR2(30) := upper('ACTIVEONLY');
	cdlg_priorityonly  CONSTANT VARCHAR2(30) := upper('PriorityOnly');
	cdlg_schemetype    CONSTANT VARCHAR2(30) := upper('SchemeType');
	cdlg_accessorylist CONSTANT VARCHAR2(30) := upper('AccessoryList');
	cdlg_btn_find      CONSTANT VARCHAR2(30) := upper('BtnFind');
	cdlg_btn_clear     CONSTANT VARCHAR2(30) := upper('cDlgBtnClear');
	cdlg_multiselect   CONSTANT VARCHAR2(30) := upper('MultiSelect');
	cdlg_controlname   CONSTANT VARCHAR2(30) := upper('cDlgControlName');

	scontracttyperecarr custom_fintypes.typecontracttypelist;
	cdocimage CONSTANT VARCHAR(20) := 'DocImage';

	SUBTYPE titempostfix IS VARCHAR;
	ip_label    CONSTANT titempostfix(16) := '_LBL';
	ip_multisel CONSTANT titempostfix(16) := '_MS';

	val_multi CONSTANT CHAR(4) := ' -> ';

	smultiselection BOOLEAN;
	smultimark      VARCHAR2(32767);

	cctypesortmode CONSTANT VARCHAR2(20) := 'CTypeSortMode';
	cctypesortdesc CONSTANT VARCHAR2(20) := 'SortCTypeDesc';
	caccessorymode CONSTANT VARCHAR2(20) := 'AccessoryFilter';

	sctypesortmode VARCHAR(20);

	cschemafilter  CONSTANT VARCHAR2(20) := 'SchemaFilter';
	cctypegroup    CONSTANT VARCHAR2(20) := 'GroupCType';
	cctypeactive   CONSTANT VARCHAR2(20) := 'CTypeActive';
	cctypepriority CONSTANT VARCHAR2(20) := 'CTypePriority';

	cctypestartdate CONSTANT VARCHAR2(20) := 'CTypeStartDate';
	cctypeenddate   CONSTANT VARCHAR2(20) := 'CTypeEndDate';

	cmode_add  CONSTANT PLS_INTEGER := 1;
	cmode_copy CONSTANT PLS_INTEGER := 2;

	cemptycontracttype CONSTANT typecontracttype := -999;

	FUNCTION candeletetype(ptype IN NUMBER) RETURN BOOLEAN;
	FUNCTION ismultiselect
	(
		pdialog IN NUMBER
	   ,pname   IN VARCHAR
	) RETURN BOOLEAN;

	method_not_found EXCEPTION;
	PRAGMA EXCEPTION_INIT(method_not_found, -06550);

	FUNCTION getversion RETURN VARCHAR2 IS
	BEGIN
		RETURN service.formatpackageversion(cpackage_name, crevision, cbodyrevision);
	END;

	PROCEDURE savesortmode(pmode IN VARCHAR2) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.SaveSortMode';
	BEGIN
		IF datamember.setchar(object.gettype(object_name)
							 ,clerk.getcode()
							 ,cctypesortmode
							 ,pmode
							 ,'contract types sorting mode'
							 ,FALSE) != 0
		THEN
			error.raiseerror(err.geterrorcode()
							,err.getfullmessage() || ', ' || clerk.getcode() || ' ' ||
							 sctypesortmode);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END savesortmode;

	FUNCTION getsavedsortmode(psetdefaultvalue BOOLEAN := TRUE) RETURN VARCHAR2 IS
		vret VARCHAR2(50);
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetSavedSortMode';
	BEGIN
		t.enter(cmethod_name, '', csay_level);
		vret := datamember.getchar(object.gettype(object_name), clerk.getcode(), cctypesortmode);
		IF psetdefaultvalue
		   AND vret IS NULL
		THEN
			vret := csortbyorder;
		END IF;
		t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getsavedsortdesc(psetdefaultvalue BOOLEAN := TRUE) RETURN NUMBER IS
		vret NUMBER;
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetSavedSortMode';
	BEGIN
		t.enter(cmethod_name, '', csay_level);
		vret := datamember.getnumber(object.gettype(object_name), clerk.getcode(), cctypesortdesc);
		IF psetdefaultvalue
		   AND vret IS NULL
		THEN
			vret := 0;
		END IF;
		t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setsortmode(pmode IN VARCHAR2) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.SetSortMode';
		vmode VARCHAR2(20) := coalesce(pmode, csortbyorder);
	BEGIN
		s.say(cmethod_name || ': set pMode=' || pmode, csay_level);
		sctypesortmode := nvl(sctypesortmode, csortbyorder);
		IF sctypesortmode != vmode
		THEN
			sctypesortmode := vmode;
			savesortmode(vmode);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setsortmode;

	FUNCTION getsortmode RETURN VARCHAR2 IS
	BEGIN
		RETURN sctypesortmode;
	END;

	PROCEDURE initsortmode(psortorder IN VARCHAR2 := NULL) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.InitSortMode';
	BEGIN
		IF psortorder IS NULL
		THEN
			sctypesortmode := getsavedsortmode();
			s.say(cmethod_name || ': sCTypeSortMode=' || sctypesortmode, csay_level);
			IF sctypesortmode IS NULL
			THEN
				setsortmode(csortbyorder);
			END IF;
		ELSE
			setsortmode(psortorder);
		END IF;
		s.say(cmethod_name || ': sort mode ' || sctypesortmode, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END initsortmode;

	FUNCTION getsortmodebylist(pasortcodelist IN types.arrstr100) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetSortModeByList';
		vsortmode VARCHAR2(2000);
	
		FUNCTION getfieldname(psortcode IN VARCHAR2) RETURN VARCHAR2 IS
			cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetFieldName';
		BEGIN
			s.say(cmethod_name || ' starting pSortCode=' || psortcode);
			IF psortcode IN (csortbyorder, csortbytypeno)
			THEN
				RETURN 'ct.SortOrder';
			ELSIF psortcode = csortreversesign || csortbytypeno
			THEN
				RETURN 'ct.SortOrder desc';
			ELSIF psortcode IN (csortbycode, csortbytypecode)
			THEN
				RETURN 'ct.Type';
			ELSIF psortcode = csortreversesign || csortbytypecode
			THEN
				RETURN 'ct.Type desc';
			ELSIF psortcode IN (csortbyname, csortbytypename)
			THEN
				RETURN 'ct.Name';
			ELSIF psortcode = csortreversesign || csortbytypename
			THEN
				RETURN 'ct.Name desc';
			ELSIF psortcode IN (csortbyschema, csortbyschemacode)
			THEN
				RETURN 'ct.SchemaType';
			ELSIF psortcode = csortreversesign || csortbyschemacode
			THEN
				RETURN 'ct.SchemaType desc';
			ELSIF psortcode = csortbyschemacust
			THEN
				RETURN 'p.SelectOrder';
			ELSE
				error.raiseerror('Sorting invalid code');
			END IF;
		
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
	BEGIN
		t.enter(cmethod_name, 'paSortCodeList.Count=' || pasortcodelist.count, csay_level);
	
		FOR i IN 1 .. pasortcodelist.count
		LOOP
			vsortmode := service.iif(vsortmode IS NULL, vsortmode, vsortmode || ',') ||
						 getfieldname(pasortcodelist(i));
		END LOOP;
	
		t.leave(cmethod_name, 'vSortMode=' || vsortmode, plevel => csay_level);
		RETURN vsortmode;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcontracttypearray
	(
		paccessory     NUMBER
	   ,pctypesortmode VARCHAR2
	   ,pctypefilter   typectypefilter := NULL
	   ,porderprofile  IN contractorderprofiles.typeorderprofilefilter := contractorderprofiles.cemptyorderprofile
	) RETURN custom_fintypes.typecontracttypelist IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractTypeArray';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		TYPE cursor_ref IS REF CURSOR;
		c1                 cursor_ref;
		vacontracttypelist custom_fintypes.typecontracttypelist;
		vsql               VARCHAR(1000);
		vsortmode          VARCHAR2(2000);
		voperdate          DATE := seance.getoperdate();
		vstartdate         DATE := nvl(pctypefilter.startdate, voperdate);
		venddate           DATE := nvl(pctypefilter.enddate, voperdate);
	
	BEGIN
		t.enter(cmethod_name
			   ,'pOrderProfile.ProfileId=[' || porderprofile.profileid || '],' ||
				' pOrderProfile.RankId=[' || porderprofile.rankid || '],' ||
				' pOrderProfile.PropId=[' || porderprofile.propid || '],' ||
				' pOrderProfile.SortCode.count=[' || porderprofile.sortcodelist.count || '],' ||
				' pCTypeSortMode=[' || pctypesortmode || ']' || '],' ||
				' pCTypeFilter.SelectedOnly=[' || t.b2t(pctypefilter.selectedonly) || ']'
			   ,csay_level);
	
		vsql := 'select ct.Type, ct.Name, ct.Accessory, rowNum as SortOrder, case when ct.Favorite=''1'' then 1 else 0 end Favorite, ct.Status, ct.Ident, ct.StartDate, ct.EndDate, ' ||
				chr(10) || '  ct.SchemaType, s.PackageName, ' ||
				htools.b2i(pctypefilter.selectedonly) || ' as isSelected, null as Description' ||
				chr(10) || 'from tContractType ct' || chr(10) ||
				'join TContractSchemas s on s.Type=ct.Schematype ' || chr(10);
		IF pctypefilter.selectedonly
		THEN
			vsql := vsql || ' join tTempContractType t on ct.Type = t.TypeCode' || chr(10);
		END IF;
		IF pctypefilter.ctgroup IS NOT NULL
		THEN
			vsql := vsql ||
					' join tGroupCT g on g.Branch = ct.Branch and ct.Type = g.ContractType  and g.Ident = ' ||
					pctypefilter.ctgroup || chr(10);
		END IF;
	
		IF porderprofile.profileid IS NOT NULL
		   AND porderprofile.rankid IS NOT NULL
		   AND porderprofile.propid IS NOT NULL
		THEN
			vsql := vsql || 'left join tOrderProfileCustomProperty p on p.profileid=' ||
					porderprofile.profileid || chr(10) || 'and p.rankid=' || porderprofile.rankid ||
					chr(10) || 'and p.propid=' || porderprofile.propid || chr(10) ||
					'and p.customcode=s.type' || chr(10);
		END IF;
	
		vsql := vsql || ' where ct.Branch = ' || cbranch || chr(10);
	
		IF (paccessory IS NOT NULL)
		THEN
			vsql := vsql || ' and ct.Accessory = ' || paccessory;
		END IF;
	
		IF pctypefilter.favoriteonly
		THEN
			vsql := vsql || ' and ct.Favorite = ''1''';
		END IF;
	
		IF pctypefilter.activeonly
		THEN
			vsql := vsql || ' and substr(ct.Status, 1, 1) = ''1''' ||
					' and (startdate is null or startdate <= to_date(''' ||
					to_char(vstartdate, 'DD.MM.YYYY') || ''',''DD.MM.YYYY''))' ||
					' and (enddate is null or enddate >= to_date(''' ||
					to_char(venddate, 'DD.MM.YYYY') || ''',''DD.MM.YYYY'')) ';
		END IF;
	
		IF pctypefilter.schematype IS NOT NULL
		THEN
			vsql := vsql || ' and ct.SchemaType = ' || pctypefilter.schematype;
		END IF;
	
		IF pctypefilter.excludedtype IS NOT NULL
		THEN
			vsql := vsql || ' and ct.Type <> ' || pctypefilter.excludedtype;
		END IF;
	
		IF porderprofile.sortcodelist.count > 0
		THEN
			t.note(cmethod_name, 'point 1', csay_level);
			vsortmode := getsortmodebylist(porderprofile.sortcodelist);
			vsql      := vsql || ' order by ct.Branch, ' || vsortmode;
		ELSE
			t.note(cmethod_name, 'point 2', csay_level);
			vsortmode := pctypesortmode;
			initsortmode(vsortmode);
			vsql := vsql || getsortmodesql(vsortmode);
		END IF;
	
		t.note(cmethod_name, 'before open: ' || vsql, csay_level);
		OPEN c1 FOR vsql;
		t.note(cmethod_name, 'point 7', csay_level);
		FETCH c1 BULK COLLECT
			INTO vacontracttypelist;
		t.note(cmethod_name, 'point 8', csay_level);
		CLOSE c1;
	
		t.var('vaContractTypeList.Count', vacontracttypelist.count, csay_level);
	
		IF (pctypefilter.userrights IS NOT NULL)
		THEN
		
			DECLARE
				vatempcontracttypelist custom_fintypes.typecontracttypelist;
			BEGIN
				vatempcontracttypelist := vacontracttypelist;
				vacontracttypelist.delete;
				FOR i IN 1 .. vatempcontracttypelist.count
				LOOP
					IF security.checkright(contract.object_name
										  ,contract.getrightkey(pctypefilter.userrights
															   ,vatempcontracttypelist(i).type))
					THEN
						vacontracttypelist(vacontracttypelist.count + 1) := vatempcontracttypelist(i);
					END IF;
				END LOOP;
			END;
		
		END IF;
	
		t.leave(cmethod_name, 'vaContractTypeList.Count=' || vacontracttypelist.count, csay_level);
		RETURN vacontracttypelist;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			IF (c1%ISOPEN)
			THEN
				CLOSE c1;
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE fillctarrays
	(
		paccessory     IN NUMBER
	   ,pctypesortmode IN VARCHAR
	   ,pctypefilter   IN typectypefilter := NULL
	   ,porderprofile  IN contractorderprofiles.typeorderprofilefilter := contractorderprofiles.cemptyorderprofile
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.FillCTArrays';
	
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		scontracttyperecarr.delete();
		scontracttyperecarr := getcontracttypearray(paccessory
												   ,pctypesortmode
												   ,pctypefilter
												   ,porderprofile);
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END fillctarrays;

	FUNCTION getsortmodesql(pctypesortmode IN VARCHAR2 := NULL) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetSortModeSQL';
		vsql      VARCHAR2(2000);
		vsortmode VARCHAR2(40);
	
		vctypesortdesc NUMBER;
	
	BEGIN
		t.enter(cmethod_name, 'pCTypeSortMode=' || pctypesortmode, csay_level);
		vsortmode := pctypesortmode;
		IF (vsortmode IS NULL)
		THEN
			vsortmode := getsavedsortmode();
		END IF;
		s.say(cmethod_name || ': vSortMode=' || vsortmode, csay_level);
	
		vsql := ' order by ct.Branch, ';
		CASE vsortmode
			WHEN csortbyorder THEN
				vsql := vsql || 'ct.SortOrder';
			WHEN csortbycode THEN
				vsql := vsql || 'ct.Type';
			WHEN csortbyname THEN
				vsql := vsql || 'ct.Name';
			WHEN csortbyschema THEN
				vsql := vsql || 'ct.SchemaType';
			
			ELSE
				vsql := vsql || 'ct.SortOrder';
		END CASE;
	
		vctypesortdesc := getsavedsortdesc();
		IF vctypesortdesc = 1
		THEN
			vsql := vsql || ' desc';
		END IF;
		t.leave(cmethod_name, 'return "' || vsql || '"', csay_level);
		RETURN vsql;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getsortmodesql;

	FUNCTION getfilteroption_groupid RETURN treferencegroupct.ident%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetFilterOption_GroupId';
		vret treferencegroupct.ident%TYPE;
	BEGIN
		vret := contractparams.loadnumber(contractparams.getobjecttype(ccontracttypebranch)
										 ,clerk.getcode()
										 ,cctypegroup
										 ,FALSE);
		IF vret IS NULL
		THEN
			t.note('[1] Loading from DataMember...');
			vret := datamember.getnumber(object_type, clerk.getcode(), cctypegroup);
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getfilteroption_startdate RETURN tcontracttype.startdate%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetFilterOption_StartDate';
		vret tcontracttype.startdate%TYPE;
	BEGIN
		vret := contractparams.loaddate(contractparams.getobjecttype(ccontracttypebranch)
									   ,clerk.getcode()
									   ,cctypestartdate
									   ,FALSE);
		IF vret IS NULL
		THEN
			t.note('[2] Loading from DataMember...');
			vret := datamember.getdate(object_type, clerk.getcode, cctypestartdate);
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getfilteroption_enddate RETURN tcontracttype.enddate%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetFilterOption_EndDate';
		vret tcontracttype.enddate%TYPE;
	BEGIN
		vret := contractparams.loaddate(contractparams.getobjecttype(ccontracttypebranch)
									   ,clerk.getcode()
									   ,cctypeenddate
									   ,FALSE);
		IF vret IS NULL
		THEN
			t.note('[3] Loading from DataMember...');
			vret := datamember.getdate(object_type, clerk.getcode, cctypeenddate);
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getfilteroption_activeonly RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetFilterOption_ActiveOnly';
		vvalue tcontractotherparameters.value%TYPE;
	BEGIN
		vvalue := contractparams.loadchar(contractparams.getobjecttype(ccontracttypebranch)
										 ,clerk.getcode()
										 ,cctypeactive
										 ,FALSE);
		IF vvalue IS NULL
		THEN
			t.note('[4] Loading from DataMember...');
			vvalue := to_char(datamember.getnumber(object_type, clerk.getcode, cctypeactive));
		END IF;
	
		RETURN nvl(vvalue, '0') = '1';
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getfilteroption_priorityonly RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetFilterOption_PriorityOnly';
		vvalue tcontractotherparameters.value%TYPE;
	BEGIN
		vvalue := contractparams.loadchar(contractparams.getobjecttype(ccontracttypebranch)
										 ,clerk.getcode()
										 ,cctypepriority
										 ,FALSE);
		IF vvalue IS NULL
		THEN
			t.note('[5] Loading from DataMember...');
			vvalue := to_char(datamember.getnumber(object_type, clerk.getcode, cctypepriority));
		END IF;
	
		RETURN nvl(vvalue, '0') = '1';
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getfilteroption_schemetype RETURN tcontracttype.schematype%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetFilterOption_SchemeType';
		vret tcontracttype.schematype%TYPE;
	BEGIN
		vret := contractparams.loadnumber(contractparams.getobjecttype(ccontracttypebranch)
										 ,clerk.getcode()
										 ,cschemafilter
										 ,FALSE);
		IF vret IS NULL
		THEN
			t.note('[6] Loading from DataMember...');
			vret := datamember.getnumber(object_type, clerk.getcode(), cschemafilter);
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getfilteroption_accessory RETURN tcontracttype.accessory%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetFilterOption_Accessory';
		vret tcontracttype.accessory%TYPE;
	BEGIN
		vret := contractparams.loadnumber(contractparams.getobjecttype(ccontracttypebranch)
										 ,clerk.getcode()
										 ,caccessorymode
										 ,FALSE);
		IF vret IS NULL
		THEN
			t.note('[7] Loading from DataMember...');
			vret := datamember.getnumber(object_type, clerk.getcode(), caccessorymode);
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setfilter
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pfilter   IN typectypefilter
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.SetFilter';
	BEGIN
		dialog.putnumber(pdialog
						,'useViewOption_' || pitemname
						,CASE pfilter.useviewoption WHEN TRUE THEN 1 WHEN FALSE THEN 0 ELSE NULL END);
	
		dialog.putchar(pdialog, 'userRights_' || pitemname, pfilter.userrights);
		dialog.putnumber(pdialog, 'SchemaType_' || pitemname, pfilter.schematype);
		dialog.putnumber(pdialog, 'CTGroup_' || pitemname, pfilter.ctgroup);
		dialog.putnumber(pdialog, 'accessory_' || pitemname, pfilter.accessory);
		dialog.putnumber(pdialog
						,'ReadOnly_' || pitemname
						,CASE pfilter.readonly WHEN TRUE THEN 1 WHEN FALSE THEN 0 ELSE NULL END);
		dialog.putnumber(pdialog
						,'EnableNull_' || pitemname
						,CASE pfilter.enablenull WHEN TRUE THEN 1 WHEN FALSE THEN 0 ELSE NULL END);
		dialog.putnumber(pdialog
						,'favoriteOnly_' || pitemname
						,CASE pfilter.favoriteonly WHEN TRUE THEN 1 WHEN FALSE THEN 0 ELSE NULL END);
		dialog.putnumber(pdialog
						,'activeOnly_' || pitemname
						,CASE pfilter.activeonly WHEN TRUE THEN 1 WHEN FALSE THEN 0 ELSE NULL END);
		dialog.putdate(pdialog, 'startdate_' || pitemname, pfilter.startdate);
		dialog.putdate(pdialog, 'enddate_' || pitemname, pfilter.enddate);
		dialog.putnumber(pdialog, 'ExcludedType_' || pitemname, pfilter.excludedtype);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE createfilterfields
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pfilter   IN typectypefilter
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.CreateFilterFields';
	BEGIN
		dialog.hiddennumber(pdialog, 'useViewOption_' || pitemname);
		dialog.hiddenchar(pdialog, 'userRights_' || pitemname);
		dialog.hiddennumber(pdialog, 'SchemaType_' || pitemname);
		dialog.hiddennumber(pdialog, 'CTGroup_' || pitemname);
		dialog.hiddennumber(pdialog, 'accessory_' || pitemname);
		dialog.hiddennumber(pdialog, 'ReadOnly_' || pitemname);
		dialog.hiddennumber(pdialog, 'EnableNull_' || pitemname);
		dialog.hiddennumber(pdialog, 'favoriteOnly_' || pitemname);
		dialog.hiddennumber(pdialog, 'activeOnly_' || pitemname);
		dialog.hiddendate(pdialog, 'startdate_' || pitemname);
		dialog.hiddendate(pdialog, 'enddate_' || pitemname);
		dialog.hiddennumber(pdialog, 'ExcludedType_' || pitemname);
		setfilter(pdialog, pitemname, pfilter);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE createdialogfilterfields
	(
		pdialog IN NUMBER
	   ,pfilter IN typectypefilter
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.CreateDialogFilterFields';
	BEGIN
		createfilterfields(pdialog, 'Dummy', pfilter);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE createitemfilterfields
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pfilter   IN typectypefilter
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.CreateItemFilterFields';
	BEGIN
		createfilterfields(pdialog, pitemname, pfilter);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getfilter
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	) RETURN typectypefilter IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.GetFilter';
		vreturn typectypefilter;
	BEGIN
		vreturn.useviewoption := CASE dialog.getnumber(pdialog, 'useViewOption_' || pitemname)
									 WHEN 1 THEN
									  TRUE
									 WHEN 0 THEN
									  FALSE
									 ELSE
									  NULL
								 END;
		IF vreturn.useviewoption
		THEN
		
			vreturn.schematype   := getfilteroption_schemetype();
			vreturn.ctgroup      := getfilteroption_groupid();
			vreturn.accessory    := getfilteroption_accessory();
			vreturn.activeonly   := getfilteroption_activeonly();
			vreturn.startdate    := getfilteroption_startdate();
			vreturn.enddate      := getfilteroption_enddate();
			vreturn.favoriteonly := getfilteroption_priorityonly();
		
		ELSE
			vreturn.schematype   := dialog.getnumber(pdialog, 'SchemaType_' || pitemname);
			vreturn.ctgroup      := dialog.getnumber(pdialog, 'CTGroup_' || pitemname);
			vreturn.accessory    := dialog.getnumber(pdialog, 'accessory_' || pitemname);
			vreturn.favoriteonly := CASE dialog.getnumber(pdialog, 'favoriteOnly_' || pitemname)
										WHEN 1 THEN
										 TRUE
										WHEN 0 THEN
										 FALSE
										ELSE
										 NULL
									END;
			vreturn.activeonly   := CASE dialog.getnumber(pdialog, 'activeOnly_' || pitemname)
										WHEN 1 THEN
										 TRUE
										WHEN 0 THEN
										 FALSE
										ELSE
										 NULL
									END;
			vreturn.startdate    := dialog.getdate(pdialog, 'startdate_' || pitemname);
			vreturn.enddate      := dialog.getdate(pdialog, 'enddate_' || pitemname);
		END IF;
		vreturn.userrights   := dialog.getchar(pdialog, 'userRights_' || pitemname);
		vreturn.readonly     := CASE dialog.getnumber(pdialog, 'ReadOnly_' || pitemname)
									WHEN 1 THEN
									 TRUE
									WHEN 0 THEN
									 FALSE
									ELSE
									 NULL
								END;
		vreturn.enablenull   := CASE dialog.getnumber(pdialog, 'EnableNull_' || pitemname)
									WHEN 1 THEN
									 TRUE
									WHEN 0 THEN
									 FALSE
									ELSE
									 NULL
								END;
		vreturn.excludedtype := dialog.getnumber(pdialog, 'ExcludedType_' || pitemname);
		RETURN vreturn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getdialogfilter(pdialog IN NUMBER) RETURN typectypefilter IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.GetDialogFilter';
		vreturn typectypefilter;
	BEGIN
		vreturn := getfilter(pdialog, 'Dummy');
		RETURN vreturn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getitemfilter
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	) RETURN typectypefilter IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.GetItemFilter';
		vreturn typectypefilter;
	BEGIN
		vreturn := getfilter(pdialog, pitemname);
		RETURN vreturn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE makeitem
	(
		pdialog      IN NUMBER
	   ,pitem        IN VARCHAR
	   ,px           IN NUMBER
	   ,py           IN NUMBER
	   ,pwidth       IN NUMBER
	   ,pcaption     IN VARCHAR
	   ,phint        IN VARCHAR
	   ,plablen      IN NUMBER
	   ,pmultisel    IN BOOLEAN
	   ,paccessory   IN NUMBER := cclient
	   ,puserproc    IN VARCHAR := NULL
	   ,pctypefilter typectypefilter := NULL
	) IS
		vlistparams typelistparams;
		vfilter     typectypefilter;
	BEGIN
		vlistparams.width       := pwidth;
		vlistparams.labellength := plablen;
		vlistparams.sizetype    := pwidth;
		vlistparams.sizename    := plablen;
		vlistparams.multiselect := pmultisel;
		vlistparams.userproc    := puserproc;
		vfilter                 := pctypefilter;
	
		vfilter.accessory := paccessory;
	
		makeitem2(pdialog, pitem, px, py, pcaption, phint, vlistparams, vfilter, 0);
	END makeitem;

	PROCEDURE makeitem2
	(
		pdialog      IN NUMBER
	   ,pitem        IN VARCHAR
	   ,px           IN NUMBER
	   ,py           IN NUMBER
	   ,pcaption     IN VARCHAR
	   ,phint        IN VARCHAR
	   ,plistparams  IN typelistparams
	   ,pctypefilter IN typectypefilter
	   ,pcmd         IN NUMBER := 0
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.MakeItem2';
	
		vitem       VARCHAR2(100);
		vlistparams typelistparams := plistparams;
		vdummy      NUMBER;
	
		PROCEDURE addfield
		(
			pfieldname IN VARCHAR2
		   ,ptype      IN CHAR
		   ,psize      IN NUMBER
		) IS
		BEGIN
			dialog.listaddfield(pdialog
							   ,pitem
							   ,pfieldname
							   ,ptype
							   ,psize
							   ,CASE psize > 0 WHEN TRUE THEN 1 ELSE 0 END);
		END addfield;
	
	BEGIN
	
		dialog.inputinteger(pdialog
						   ,pitem
						   ,px
						   ,py
						   ,nvl(phint, pcaption)
						   ,plistparams.width
						   ,pcaption);
		addfield('TYPE', 'N', vlistparams.sizetype);
		addfield('NAME', 'C', vlistparams.sizename);
	
		IF (plistparams.canselect)
		THEN
			dialog.setitempre(pdialog, pitem, 'ContractType.ItemHandler');
		END IF;
		dialog.setreadonly(pdialog, pitem, nvl(pctypefilter.readonly, FALSE));
	
		dialog.hiddenchar(pdialog, cdlg_controlname, pitem);
	
		vitem := pitem || ip_multisel;
		dialog.inputinteger(pdialog, vitem, 0, 0, '');
		dialog.setvisible(pdialog, vitem, FALSE);
		dialog.putnumber(pdialog, vitem, service.iif(plistparams.multiselect, 1, 0));
	
		IF (plistparams.labellength > 0)
		THEN
			dialog.textlabel(pdialog
							,pitem || ip_label
							,px + plistparams.width + 3
							,py
							,plistparams.labellength);
			dialog.setitemchange(pdialog, pitem, 'ContractType.ItemHandler');
			dialog.setitempost(pdialog, pitem, 'ContractType.ItemHandler');
		END IF;
	
		dialog.inputchar(pdialog, 'UserFunction_', 0, 0, 150, '');
		dialog.setvisible(pdialog, 'UserFunction_', FALSE);
		dialog.putchar(pdialog, 'UserFunction_', plistparams.userproc);
	
		createitemfilterfields(pdialog, pitem, pctypefilter);
		dialog.inputinteger(pdialog, 'cmd_' || pitem, 0, 0, '', 20);
		ktools.visible(pdialog, 'cmd_' || pitem, FALSE);
		dialog.putnumber(pdialog, 'cmd_' || pitem, nvl(pcmd, 0));
		vdummy := filllist(pdialog, pitem, pcmd, pctypefilter);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END makeitem2;

	FUNCTION filllistscroller
	(
		pdialog       IN NUMBER
	   ,pcontracttype typecontracttype
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.FillListScroller';
		vlistrecno NUMBER;
	BEGIN
	
		s.say(cmethod_name || ': starting...', csay_level);
		fillctarrays(getdialogfilter(pdialog).accessory, getsortmode(), getdialogfilter(pdialog));
		IF pcontracttype IS NOT NULL
		THEN
			FOR i IN 1 .. getcount()
			LOOP
				IF pcontracttype = scontracttyperecarr(i).type
				THEN
					vlistrecno := i;
					EXIT;
				END IF;
			END LOOP;
		END IF;
	
		vlistrecno := nvl(vlistrecno, 1);
		s.say(cmethod_name || ': vListRecNo=' || to_char(vlistrecno), csay_level);
		RETURN vlistrecno;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(object_name || '.FillListScroller');
			RAISE;
	END filllistscroller;

	PROCEDURE fillchecklist(pdialog IN NUMBER) IS
		vfilter typectypefilter;
	BEGIN
		ktools.lclear(pdialog, 'cbList');
		vfilter := getdialogfilter(pdialog);
		t.note('vFilter.CTGroup', vfilter.ctgroup);
		fillctarrays(getdialogfilter(pdialog).accessory, getsortmode(), vfilter);
	
		FOR i IN 1 .. scontracttyperecarr.count
		LOOP
		
			dialog.listaddrecord(pdialog
								,'cbList'
								,scontracttyperecarr(i)
								 .type || '~' || scontracttyperecarr(i).name || '~');
		
		END LOOP;
	END fillchecklist;

	PROCEDURE findpanel_init(pdialog IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FindPanel_Init';
	
		vschemefilter   contractschemas.typeschemefilter;
		vtypelistfilter typectypefilter;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
	
		vschemefilter                   := contractschemas.getemptyschemefilter();
		vschemefilter.contracttypegroup := getfilteroption_groupid;
		referencegroupct.setdata(pdialog, cdlg_grouplist, vschemefilter.contracttypegroup);
	
		vschemefilter.startdate := getfilteroption_startdate();
		dialog.putdate(pdialog, cdlg_startdate, vschemefilter.startdate);
		vschemefilter.enddate := getfilteroption_enddate();
		dialog.putdate(pdialog, cdlg_enddate, vschemefilter.enddate);
	
		vtypelistfilter.activeonly := getfilteroption_activeonly();
		dialog.putbool(pdialog, cdlg_activeonly, vtypelistfilter.activeonly);
		IF vtypelistfilter.activeonly
		THEN
			vschemefilter.byactivect := contractschemas.cactiveonly;
		ELSE
			dialog.setenabled(pdialog, cdlg_startdate, FALSE);
			dialog.setenabled(pdialog, cdlg_enddate, FALSE);
		END IF;
	
		vtypelistfilter.favoriteonly := getfilteroption_priorityonly();
		dialog.putbool(pdialog, cdlg_priorityonly, vtypelistfilter.favoriteonly);
		IF vtypelistfilter.favoriteonly
		THEN
			vschemefilter.bypriorityct := contractschemas.cactiveonly;
		END IF;
	
		vtypelistfilter.schematype := getfilteroption_schemetype();
		contractschemas.updateitem(pdialog
								  ,cdlg_schemetype
								  ,vschemefilter
								  ,vtypelistfilter.schematype);
	
		vtypelistfilter.accessory := getfilteroption_accessory();
	
		dialog.listaddrecord(pdialog, cdlg_accessorylist, '~All', 0, 0);
		dialog.listaddrecord(pdialog
							,cdlg_accessorylist
							,cclient || '~' || saaccessory(cclient)
							,0
							,0);
		dialog.listaddrecord(pdialog
							,cdlg_accessorylist
							,ccorporate || '~' || saaccessory(ccorporate)
							,0
							,0);
		dialog.setcurrecbyvalue(pdialog, cdlg_accessorylist, 'TYPE', vtypelistfilter.accessory);
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE findpanel_refresh
	(
		pdialog   IN NUMBER
	   ,pctfilter IN typectypefilter
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FindPanel_Refresh';
	
		vschemefilter contractschemas.typeschemefilter;
	
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		vschemefilter                   := contractschemas.getemptyschemefilter();
		vschemefilter.contracttypegroup := pctfilter.ctgroup;
		referencegroupct.setdata(pdialog, cdlg_grouplist, pctfilter.ctgroup);
	
		vschemefilter.startdate := pctfilter.startdate;
		dialog.putdate(pdialog, cdlg_startdate, pctfilter.startdate);
		vschemefilter.enddate := pctfilter.enddate;
		dialog.putdate(pdialog, cdlg_enddate, pctfilter.enddate);
		dialog.putbool(pdialog, cdlg_activeonly, pctfilter.activeonly);
		IF pctfilter.activeonly
		THEN
			vschemefilter.byactivect := contractschemas.cactiveonly;
		ELSE
			dialog.setenabled(pdialog, cdlg_startdate, FALSE);
			dialog.setenabled(pdialog, cdlg_enddate, FALSE);
		END IF;
	
		dialog.putbool(pdialog, cdlg_priorityonly, pctfilter.favoriteonly);
		IF pctfilter.favoriteonly
		THEN
			vschemefilter.bypriorityct := contractschemas.cactiveonly;
		END IF;
	
		contractschemas.updateitem(pdialog, cdlg_schemetype, vschemefilter, pctfilter.schematype);
	
		IF pctfilter.accessory IS NOT NULL
		THEN
			dialog.setcurrecbyvalue(pdialog, cdlg_accessorylist, 'TYPE', pctfilter.accessory);
		ELSE
			dialog.setcurrec(pdialog, cdlg_accessorylist, 1);
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE savefilteroption_groupid(pgroupid IN treferencegroupct.ident%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SaveFilterOption_GroupId';
	BEGIN
		contractparams.savenumber(contractparams.getobjecttype(ccontracttypebranch)
								 ,clerk.getcode()
								 ,cctypegroup
								 ,pgroupid);
		IF datamember.getnumber(object_type, clerk.getcode(), cctypegroup) IS NOT NULL
		THEN
			err.seterror(0, cmethod_name);
			IF datamember.datamemberdelete(object_type, clerk.getcode(), cctypegroup) != 0
			THEN
				error.raisewhenerr();
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE savefilteroption_startdate(pstartdate IN tcontracttype.startdate%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SaveFilterOption_StartDate';
	BEGIN
		contractparams.savedate(contractparams.getobjecttype(ccontracttypebranch)
							   ,clerk.getcode()
							   ,cctypestartdate
							   ,pstartdate);
		IF datamember.getdate(object_type, clerk.getcode, cctypestartdate) IS NOT NULL
		THEN
			err.seterror(0, cmethod_name);
			IF datamember.datamemberdelete(object_type, clerk.getcode, cctypestartdate) != 0
			THEN
				error.raisewhenerr();
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE savefilteroption_enddate(penddate IN tcontracttype.enddate%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SaveFilterOption_EndDate';
	BEGIN
		contractparams.savedate(contractparams.getobjecttype(ccontracttypebranch)
							   ,clerk.getcode()
							   ,cctypeenddate
							   ,penddate);
		IF datamember.getdate(object_type, clerk.getcode, cctypeenddate) IS NOT NULL
		THEN
			err.seterror(0, cmethod_name);
			IF datamember.datamemberdelete(object_type, clerk.getcode, cctypeenddate) != 0
			THEN
				error.raisewhenerr();
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE savefilteroption_activeonly(pactiveonly IN BOOLEAN) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SaveFilterOption_ActiveOnly';
	BEGIN
		contractparams.savebool(contractparams.getobjecttype(ccontracttypebranch)
							   ,clerk.getcode()
							   ,cctypeactive
							   ,pactiveonly);
		IF datamember.getdate(object_type, clerk.getcode, cctypeactive) IS NOT NULL
		THEN
			err.seterror(0, cmethod_name);
			IF datamember.datamemberdelete(object_type, clerk.getcode, cctypeactive) != 0
			THEN
				error.raisewhenerr();
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE savefilteroption_priorityonly(ppriorityonly IN BOOLEAN) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SaveFilterOption_PriorityOnly';
	BEGIN
		contractparams.savebool(contractparams.getobjecttype(ccontracttypebranch)
							   ,clerk.getcode()
							   ,cctypepriority
							   ,ppriorityonly);
		IF datamember.getdate(object_type, clerk.getcode, cctypepriority) IS NOT NULL
		THEN
			err.seterror(0, cmethod_name);
			IF datamember.datamemberdelete(object_type, clerk.getcode, cctypepriority) != 0
			THEN
				error.raisewhenerr();
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE savefilteroption_schemetype(pschemetype IN tcontracttype.schematype%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SaveFilterOption_SchemeType';
	BEGIN
		contractparams.savenumber(contractparams.getobjecttype(ccontracttypebranch)
								 ,clerk.getcode()
								 ,cschemafilter
								 ,pschemetype);
		IF datamember.getnumber(object_type, clerk.getcode(), cschemafilter) IS NOT NULL
		THEN
			err.seterror(0, cmethod_name);
			IF datamember.datamemberdelete(object_type, clerk.getcode(), cschemafilter) != 0
			THEN
				error.raisewhenerr();
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE savefilteroption_accessory(paccessory IN tcontracttype.accessory%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SaveFilterOption_Accessory';
	BEGIN
		contractparams.savenumber(contractparams.getobjecttype(ccontracttypebranch)
								 ,clerk.getcode()
								 ,caccessorymode
								 ,paccessory);
		IF datamember.getnumber(object_type, clerk.getcode(), caccessorymode) IS NOT NULL
		THEN
			err.seterror(0, cmethod_name);
			IF datamember.datamemberdelete(object_type, clerk.getcode(), caccessorymode) != 0
			THEN
				error.raisewhenerr();
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE findpanel_down(pdialog IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FindPanel_Down';
	
		PROCEDURE savefilter IS
			PRAGMA AUTONOMOUS_TRANSACTION;
		BEGIN
			t.note('point 001');
			savefilteroption_groupid(referencegroupct.getdata(pdialog, cdlg_grouplist));
			t.note('point 002');
			savefilteroption_startdate(dialog.getdate(pdialog, cdlg_startdate));
			t.note('point 003');
			savefilteroption_enddate(dialog.getdate(pdialog, cdlg_enddate));
			t.note('point 004');
			savefilteroption_activeonly(dialog.getbool(pdialog, cdlg_activeonly));
			t.note('point 005');
			savefilteroption_priorityonly(dialog.getbool(pdialog, cdlg_priorityonly));
			t.note('point 006');
			savefilteroption_schemetype(contractschemas.getdata(pdialog, cdlg_schemetype));
			t.note('point 007');
			savefilteroption_accessory(dialog.getcurrentrecordnumber(pdialog
																	,cdlg_accessorylist
																	,'TYPE'));
			COMMIT;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackage_name || '.SaveFilter');
				ROLLBACK;
				RAISE;
		END;
	
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		savefilter();
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE findpanel_clear(pdialog IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FindPanel_Clear';
	
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		referencegroupct.setdata(pdialog, cdlg_grouplist, NULL);
		dialog.putdate(pdialog, cdlg_startdate, NULL);
		dialog.putdate(pdialog, cdlg_enddate, NULL);
		dialog.putbool(pdialog, cdlg_activeonly, FALSE);
		dialog.putbool(pdialog, cdlg_priorityonly, FALSE);
	
		contractschemas.updateitem(pdialog, cdlg_schemetype, NULL);
	
		dialog.setcurrec(pdialog, cdlg_accessorylist, 1);
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE findpanel_draw
	(
		pdialog      IN NUMBER
	   ,px           IN NUMBER
	   ,py           IN NUMBER
	   ,pwidth       IN NUMBER
	   ,pheight      IN NUMBER
	   ,pmultiselect IN BOOLEAN := FALSE
	) IS
	
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FindPanel_Draw';
		chandler     CONSTANT VARCHAR2(65) := cpackage_name || '.FindPanel_Handler';
		vbtnwidth NUMBER := 10;
		vdy       NUMBER;
		vparams   referencegroupct.typelistparams;
		vpanel    NUMBER;
	BEGIN
		vpanel := dialog.panel(pdialog
							  ,cdlg_panel
							  ,px + 0
							  ,py + 0
							  ,pwidth
							  ,pheight
							  ,pshape => dialog.panel_none);
		dialog.setdialogpre(vpanel, chandler);
		vdy := 1;
	
		dialog.hiddenbool(vpanel, cdlg_multiselect, nvl(pmultiselect, FALSE));
		vparams.width    := pwidth - 33;
		vparams.sizename := 50;
	
		contractschemas.makeitem(vpanel
								,cdlg_schemetype
								,18
								,vdy
								,5
								,'Scheme type'
								,pmakeemptyitem  => TRUE
								,plablen         => 40);
	
		vdy := vdy + 1;
		dialog.inputchar(vpanel
						,cdlg_accessorylist
						,18
						,vdy
						,pwidth - 33
						,'Select contract type belonging to be displayed in list'
						,pcaption => 'Belongs to:');
		dialog.listaddfield(vpanel, cdlg_accessorylist, 'TYPE', 'N', 5, 0);
		dialog.listaddfield(vpanel, cdlg_accessorylist, 'NAME', 'C', 40, 1);
		dialog.setitempre(vpanel, cdlg_accessorylist, chandler);
	
		dialog.button(vpanel, cdlg_btn_find, 64, vdy, vbtnwidth, 'Search', 0, 0, 'Apply filter');
	
		dialog.setitempre(vpanel, cdlg_btn_find, chandler, dialog.proctype);
	
		vdy := vdy + 1;
		referencegroupct.makeitem2(vpanel
								  ,cdlg_grouplist
								  ,18
								  ,vdy
								  ,'Group:'
								  ,''
								  ,vparams
								  ,pitemchangehandler => chandler
								  ,pitemposthandler   => chandler);
	
		vdy := vdy + 1;
		dialog.inputcheck(vpanel, cdlg_priorityonly, 18, vdy, pwidth - 18 - 4, ' Priority');
		dialog.setitempost(vpanel, cdlg_priorityonly, chandler);
	
		dialog.button(vpanel, cdlg_btn_clear, 64, vdy, vbtnwidth, 'Clear', 0, 0, 'Clear filter');
		dialog.setitempre(vpanel, cdlg_btn_clear, chandler, dialog.proctype);
	
		vdy := vdy + 1;
		dialog.inputcheck(vpanel, cdlg_activeonly, 18, vdy, pwidth - 18 - 4, ' Active');
		dialog.setitempost(vpanel, cdlg_activeonly, chandler);
		dialog.setitempre(vpanel, cdlg_activeonly, chandler, dialog.proctype);
	
		dialog.inputdate(vpanel, cdlg_startdate, 37, vdy, 'Start date', pcaption => 'from:');
		dialog.inputdate(vpanel, cdlg_enddate, 52, vdy, 'Expiration date', pcaption => 'to:');
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE findpanel_handler
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN CHAR
	   ,pcmd    IN NUMBER
	) IS
		vgroup          NUMBER;
		vschemefilter   contractschemas.typeschemefilter;
		vtypelistfilter typectypefilter;
	
		PROCEDURE applyfilter
		(
			pdialog       IN NUMBER
		   ,pcontracttype typecontracttype
		) IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ApplyFilter';
			vrecno NUMBER;
		BEGIN
			IF NOT smultiselection
			THEN
				t.note('point 002: sMultiSelection');
				vrecno := filllistscroller(pdialog, pcontracttype);
				browser.scrollerrefresh(pdialog, vrecno);
			
			ELSE
				t.note('point 003:');
				fillchecklist(pdialog);
				setselectedtypes;
				dialog.putchar(pdialog, 'cbList', smultimark);
			END IF;
		END;
	
	BEGIN
		IF pwhat IN (dialog.wt_nextfield, dialog.wtitempost)
		THEN
			s.say('ItemChange/Post event ItemName=' || pitem);
			IF pitem = cdlg_grouplist
			THEN
				vschemefilter := contractschemas.getfilter(pdialog, cdlg_schemetype);
				BEGIN
					vgroup := dialog.getcurrentrecordnumber(pdialog, pitem, 'IDENT');
				EXCEPTION
					WHEN OTHERS THEN
						vgroup := NULL;
				END;
				referencegroupct.setdata(pdialog, pitem, vgroup);
				vschemefilter.contracttypegroup := vgroup;
				contractschemas.updateitem(pdialog
										  ,cdlg_schemetype
										  ,vschemefilter
										  ,contractschemas.getdata(pdialog, cdlg_schemetype));
			ELSIF pitem = cdlg_activeonly
			THEN
				vschemefilter            := contractschemas.getfilter(pdialog, cdlg_schemetype);
				vschemefilter.byactivect := service.iif(dialog.getbool(pdialog, cdlg_activeonly)
													   ,contractschemas.cactiveonly
													   ,contractschemas.callrows);
				contractschemas.updateitem(pdialog
										  ,cdlg_schemetype
										  ,vschemefilter
										  ,contractschemas.getdata(pdialog, cdlg_schemetype));
			ELSIF pitem = cdlg_priorityonly
			THEN
				vschemefilter              := contractschemas.getfilter(pdialog, cdlg_schemetype);
				vschemefilter.bypriorityct := service.iif(dialog.getbool(pdialog, cdlg_priorityonly)
														 ,contractschemas.cactiveonly
														 ,contractschemas.callrows);
				contractschemas.updateitem(pdialog
										  ,cdlg_schemetype
										  ,vschemefilter
										  ,contractschemas.getdata(pdialog, cdlg_schemetype));
			END IF;
		
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF pitem = cdlg_activeonly
			THEN
				IF dialog.getbool(pdialog, cdlg_activeonly)
				THEN
					dialog.setenabled(pdialog, cdlg_startdate, TRUE);
					dialog.setenabled(pdialog, cdlg_enddate, TRUE);
				ELSE
					dialog.setenabled(pdialog, cdlg_startdate, FALSE);
					dialog.setenabled(pdialog, cdlg_enddate, FALSE);
				END IF;
			ELSIF pitem = cdlg_btn_clear
			THEN
				findpanel_clear(pdialog);
			ELSIF pitem = cdlg_btn_find
			THEN
			
				vtypelistfilter              := getfilter(dialog.getowner(pdialog)
														 ,dialog.getchar(dialog.getowner(pdialog)
																		,cdlg_controlname));
				vtypelistfilter.ctgroup      := referencegroupct.getdata(pdialog, cdlg_grouplist);
				vtypelistfilter.schematype   := contractschemas.getdata(pdialog, cdlg_schemetype);
				vtypelistfilter.accessory    := dialog.getcurrentrecordnumber(pdialog
																			 ,cdlg_accessorylist
																			 ,'TYPE');
				vtypelistfilter.favoriteonly := dialog.getbool(pdialog, cdlg_priorityonly);
				vtypelistfilter.activeonly   := dialog.getbool(pdialog, cdlg_activeonly);
				vtypelistfilter.startdate    := dialog.getdate(pdialog, cdlg_startdate);
				vtypelistfilter.enddate      := dialog.getdate(pdialog, cdlg_enddate);
				t.note('vTypeListFilter.CTGroup', vtypelistfilter.ctgroup);
				t.note('vTypeListFilter.SchemaType', vtypelistfilter.schematype);
				setfilter(dialog.getowner(pdialog), 'Dummy', vtypelistfilter);
				setfilter(dialog.getowner(pdialog)
						 ,dialog.getchar(dialog.getowner(pdialog), cdlg_controlname)
						 ,vtypelistfilter);
				applyfilter(pdialog, NULL);
			
				IF dialog.getbool(pdialog, cdlg_multiselect)
				THEN
					t.note('point 00: MultiSel');
				
				ELSE
					t.note('point 01: ');
				
					IF (scontracttyperecarr.count = 0)
					THEN
						dialog.setenabled(pdialog, 'btnDelete', FALSE);
						dialog.setenabled(pdialog, 'btnCopy', FALSE);
					ELSE
						dialog.setenabled(pdialog, 'btnDelete', TRUE);
						dialog.setenabled(pdialog, 'btnCopy', TRUE);
					END IF;
				END IF;
			END IF;
		END IF;
	END;

	FUNCTION intdialoglist
	(
		pselection IN BOOLEAN
	   ,pmultisel  IN BOOLEAN
	   ,pfilter    IN typectypefilter
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.IntDialogList';
		chandlename  CONSTANT VARCHAR2(80) := cpackage_name || '.DialogListHandler';
		vdialog   NUMBER;
		vtitle    VARCHAR(80);
		vmnuid    NUMBER;
		vviewmenu NUMBER;
		vdictmenu NUMBER;
	
		cdialogwidth CONSTANT NUMBER := 75;
	BEGIN
		smultiselection := pmultisel;
	
		can_view   := checkright(right_view);
		can_modify := checkright(right_modify);
		can_change := checkright(right_change);
	
		IF (NOT can_view)
		THEN
			vdialog := service.messagedialog('Warning!'
											,'You are not authorized to view~Dictionary of contract types.~Contact system administrator.~');
			RETURN vdialog;
		END IF;
	
		IF (pselection)
		THEN
			IF (NOT pmultisel)
			THEN
				vtitle := 'Contract types - [ selection mode ]';
			ELSE
				vtitle := 'Contract types - [ multi-selection mode ]';
			END IF;
		ELSE
			vtitle := 'Contract types ';
		END IF;
	
		IF (NOT pmultisel)
		THEN
			vdialog := browser.new(object_name, vtitle, 0, 0, cdialogwidth, 21);
			dialog.setdialogresizeable(vdialog, TRUE);
			dialog.setdialogcanmaximize(vdialog, TRUE);
		
			dialog.setexternalid(vdialog, cmethod_name);
		
			findpanel_draw(vdialog, 1, 1, cdialogwidth, 8, pmultisel);
		
			browser.scroller(vdialog
							,1
							,7
							,cdialogwidth - 2
							,20 - 7
							,dialog.firstrecord
							,''
							,FALSE);
			dialog.listaddfield(vdialog, 'SCROLLER', 'Order', 'N', 6, 1);
			dialog.listaddfield(vdialog, 'SCROLLER', 'Favorite', 'C', 1, 1);
			dialog.listaddfield(vdialog, 'SCROLLER', 'Status', 'C', 1, 1);
			dialog.listaddfield(vdialog, 'SCROLLER', 'AccessoryClient', 'C', 2, 1);
			dialog.listaddfield(vdialog, 'SCROLLER', 'AccessoryCorp', 'C', 2, 1);
			dialog.listaddfield(vdialog, 'SCROLLER', 'Type', 'N', 6, 1);
			dialog.listaddfield(vdialog, 'SCROLLER', 'Name', 'C', 80, 1);
			dialog.listaddfield(vdialog, 'SCROLLER', 'StartDate', 'C', 10, 1);
			dialog.listaddfield(vdialog, 'SCROLLER', 'EndDate', 'C', 10, 1);
			dialog.listaddfield(vdialog, 'SCROLLER', 'Ident', 'C', 15, 1);
		
			browser.setcaption(vdialog
							  ,'SCROLLER'
							  ,'No~P~A~Private~Corporate~Code~Name~From~To~ID');
			dialog.setanchor(vdialog, 'SCROLLER', dialog.anchor_all);
		
			IF (pselection)
			THEN
				dialog.setitemcommand(vdialog, 'SCROLLER', dialog.cmok);
			
				dialog.button(vdialog
							 ,'btnExit'
							 ,30
							 ,20
							 ,12
							 ,'Exit'
							 ,dialog.cmcancel
							 ,0
							 ,'Exit'
							 ,panchor => dialog.anchor_bottom);
			ELSE
				dialog.setitempre(vdialog, 'SCROLLER', chandlename, dialog.proctype);
			
				dialog.button(vdialog
							 ,'btnAdd'
							 ,8
							 ,20
							 ,13
							 ,'Add'
							 ,0
							 ,0
							 ,'Add new contract type'
							 ,panchor => dialog.anchor_bottom);
				dialog.setitempre(vdialog, 'btnAdd', chandlename, dialog.proctype);
				dialog.button(vdialog
							 ,'btnDelete'
							 ,23
							 ,20
							 ,13
							 ,'Delete'
							 ,0
							 ,0
							 ,'Delete contract type'
							 ,panchor => dialog.anchor_bottom);
				dialog.setitempre(vdialog, 'btnDelete', chandlename, dialog.proctype);
				dialog.button(vdialog
							 ,'btnCopy'
							 ,38
							 ,20
							 ,13
							 ,'Copy'
							 ,0
							 ,0
							 ,'Add current contract type copy'
							 ,panchor => dialog.anchor_bottom);
				dialog.setitempre(vdialog, 'btnCopy', chandlename, dialog.proctype);
				dialog.button(vdialog
							 ,'btnOk'
							 ,53
							 ,20
							 ,13
							 ,'Exit'
							 ,dialog.cmok
							 ,0
							 ,'Exit dialog box'
							 ,panchor => dialog.anchor_bottom);
			
				vmnuid := mnu.new(vdialog);
			
				browser.standardmenufind(vmnuid);
			
				vdictmenu := mnu.submenu(vmnuid, 'Dictionaries', 'Additional dictionaries');
				mnu.item(vdictmenu
						,'SchemaList'
						,'Financial schemes'
						,0
						,0
						,'Open dictionary of financial schemes');
				dialog.setitempre(vdialog, 'SchemaList', chandlename, dialog.proctype);
				adjustingmode.addmenu_moderefview(vdialog, vdictmenu);
				mnu.item(vdictmenu, 'Group', 'Groups', 0, 0, 'Open dictionary of groups');
				dialog.setitempre(vdialog, 'Group', chandlename, dialog.proctype);
				mnu.item(vdictmenu
						,cdocimage
						,'Document copies'
						,0
						,0
						,'Open dictionary of document copies');
				dialog.setitempre(vdialog, cdocimage, chandlename, dialog.proctype);
				mnu.item(vdictmenu
						,'mnu_Base_SOT'
						,'Operation templates'
						,0
						,0
						,'Open dictionary of operation basic templates');
				dialog.setitempost(vdialog, 'mnu_Base_SOT', chandlename, dialog.proctype);
				mnu.item(vdictmenu
						,'mnu_RateRef'
						,'Interest rates'
						,0
						,0
						,'Open dictionary of interest rates');
				dialog.setitempre(vdialog, 'mnu_RateRef', chandlename);
				IF can_modify
				THEN
					refloancoverage.addmenu_view(vdialog, vdictmenu);
				ELSE
					mnu.item(vdictmenu
							,'mnu_RefLoanCoverage'
							,'Dictionary of collateral types'
							,0
							,0
							,'Open dictionary of collateral types');
					dialog.setenable(vdialog, 'mnu_RefLoanCoverage', FALSE);
				END IF;
				mnu.item(vdictmenu
						,'mnu_UserPropRef'
						,'User attributes'
						,0
						,0
						,'Open dictionary of user attributes');
				dialog.setitempre(vdialog, 'mnu_UserPropRef', chandlename);
			
				IF contractcollection.isavailable
				THEN
					mnu.item(vdictmenu
							,'RefColRules'
							,'Dictionary of case opening rules'
							,0
							,0
							,'Open dictionary of case opening rules');
					dialog.setitempre(vdialog, 'RefColRules', chandlename, dialog.proctype);
				END IF;
			
				vviewmenu := mnu.submenu(vmnuid, 'Service', 'Set up viewing');
				mnu.item(vviewmenu, 'Service', 'Viewing parameters', 0, 0, 'Viewing parameters');
				dialog.setitempre(vdialog, 'Service', chandlename, dialog.proctype);
				mnu.item(vviewmenu, 'Options', 'Setup', 0, 0, 'Setup');
				dialog.setitempre(vdialog, 'Options', chandlename, dialog.proctype);
				IF (NOT can_modify)
				THEN
					dialog.setenabled(vdialog, 'btnAdd', FALSE);
					dialog.setenabled(vdialog, 'btnCopy', FALSE);
					dialog.setenabled(vdialog, 'btnDelete', FALSE);
				END IF;
			
				browser.setdialogmenu(vdialog, vmnuid);
			END IF;
		
			browser.setdialogpre(vdialog, chandlename);
			browser.setdialogpost(vdialog, chandlename);
		ELSE
			vdialog := dialog.new(vtitle, 0, 0, cdialogwidth, 21, pextid => cmethod_name);
			dialog.setdialogpre(vdialog, chandlename);
			dialog.setdialogvalid(vdialog, chandlename);
			dialog.setdialogpost(vdialog, chandlename);
		
			dialog.setdialogresizeable(vdialog, TRUE);
			dialog.setdialogcanmaximize(vdialog, TRUE);
		
			findpanel_draw(vdialog, 1, 1, cdialogwidth, 8, pmultisel);
		
			dialog.checkbox(vdialog
						   ,'cbList'
						   ,1
						   ,6
						   ,cdialogwidth - 2 - 3
						   ,20 - 8
						   ,phint => ''
						   ,pusebottompanel => TRUE);
			dialog.listaddfield(vdialog, 'cbList', 'TCode', 'N', 5, 1);
			dialog.listaddfield(vdialog, 'cbList', 'Name', 'C', 40, 1);
		
			dialog.setcaption(vdialog, 'cbList', '~Code~Name~~');
		
			dialog.setanchor(vdialog, 'cbList', dialog.anchor_all);
		
			dialog.button(vdialog
						 ,'btnOk'
						 ,cdialogwidth / 2 - 12 / 2 - 12 - 3
						 ,20
						 ,12
						 ,'Enter'
						 ,dialog.cmok
						 ,0
						 ,''
						 ,panchor => dialog.anchor_bottom);
			dialog.button(vdialog
						 ,'btnClear'
						 ,cdialogwidth / 2 - 12 / 2
						 ,20
						 ,12
						 ,'Clear'
						 ,0
						 ,0
						 ,'Remove all marks'
						 ,'!Dialog.PutChar(:DIALOG, ''cbList'', Null);'
						 ,panchor => dialog.anchor_bottom);
			dialog.button(vdialog
						 ,'btnCancel'
						 ,cdialogwidth / 2 + 12 / 2 + 3
						 ,20
						 ,12
						 ,'Cancel'
						 ,dialog.cmcancel
						 ,0
						 ,''
						 ,panchor => dialog.anchor_bottom);
		
			findpanel_refresh(vdialog, pfilter);
		END IF;
	
		createdialogfilterfields(vdialog, pfilter);
	
		RETURN vdialog;
	END intdialoglist;

	FUNCTION selectcontracttype
	(
		pmulti       IN BOOLEAN
	   ,pctypefilter IN typectypefilter
	   ,pcode        OUT NUMBER
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.SelectContractType';
		vreturn BOOLEAN := FALSE;
	BEGIN
		pcode   := NULL;
		vreturn := dialog.exec(intdialoglist(TRUE, pmulti, pctypefilter)) = dialog.cmok;
		IF vreturn
		THEN
			pcode := service.iif(pmulti, -1, sselectedcode);
		END IF;
		RETURN vreturn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE itemhandler
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN VARCHAR
	   ,pcmd    IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ItemHandler';
		vcode VARCHAR(256);
	
		PROCEDURE execuserproc IS
			vuserproc VARCHAR(150);
		BEGIN
			setdata(pdialog, pitem, vcode);
			vuserproc := TRIM(substr(dialog.getchar(pdialog, 'UserFunction_'), 1, 150));
			s.say(cmethod_name || ': ' || vuserproc || '(' || pwhat || ', ' || pdialog || ', ''' ||
				  pitem || ''', ' || pcmd || ');'
				 ,csay_level);
			IF NOT vuserproc IS NULL
			THEN
				htools.execproc(vuserproc || '(' || pwhat || ', ' || pdialog || ', ''' || pitem ||
								''', ' || pcmd || ');');
			END IF;
		END execuserproc;
	
	BEGIN
		s.say(cmethod_name || ': ' || '(' || pwhat || ', ' || pdialog || ', ''' || pitem || ''', ' || pcmd || ');'
			 ,csay_level);
	
		IF (pwhat = dialog.wtitempre)
		THEN
			IF (pcmd = 0)
			THEN
				IF selectcontracttype(ismultiselect(pdialog, pitem)
									 ,getitemfilter(pdialog, pitem)
									 ,vcode)
				THEN
					IF ismultiselect(pdialog, pitem)
					THEN
						IF (samultisel.count = 1)
						THEN
							vcode := samultisel(1);
						END IF;
						IF (samultisel.count = 0)
						THEN
							vcode := NULL;
						END IF;
					END IF;
					execuserproc();
				END IF;
			END IF;
		
		ELSIF pwhat IN (dialog.wt_nextfield, dialog.wtitempost)
		THEN
			vcode := dialog.getchar(pdialog, pitem);
			execuserproc();
		
			IF vcode IS NULL
			THEN
				clearmultisel();
			END IF;
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			error.showerror;
			dialog.cancelclose(pdialog);
		
	END itemhandler;

	PROCEDURE setdata
	(
		pdialog IN NUMBER
	   ,pitem   IN VARCHAR
	   ,pdata   IN VARCHAR
	) IS
	BEGIN
		IF (pdata IS NOT NULL)
		THEN
			IF (pdata = '-1')
			   OR (TRIM(pdata) = TRIM(val_multi))
			THEN
				dialog.putchar(pdialog, pitem, val_multi);
				dialog.putchar(pdialog, pitem || ip_label, 'Multiple selection');
			ELSE
				IF NOT htools.equal(dialog.getcurrentrecordnumber(pdialog, pitem, 'TYPE')
								   ,to_number(pdata))
				THEN
					dialog.setcurrecbyvalue(pdialog, pitem, 'TYPE', pdata);
				END IF;
				dialog.putchar(pdialog
							  ,pitem || ip_label
							  ,dialog.getcurrentrecordchar(pdialog, pitem, 'Name'));
				IF dialog.getchar(pdialog, pitem) IS NULL
				THEN
					dialog.putchar(pdialog, pitem, pdata);
					dialog.putchar(pdialog, pitem || ip_label, getname(pdata));
				END IF;
			END IF;
		ELSE
			dialog.putchar(pdialog, pitem, NULL);
			dialog.putchar(pdialog, pitem || ip_label, NULL);
		END IF;
	END setdata;

	FUNCTION getdata
	(
		pdialog IN NUMBER
	   ,pitem   IN VARCHAR
	) RETURN VARCHAR IS
		vret VARCHAR(256);
	BEGIN
		vret := dialog.getchar(pdialog, pitem);
		IF (TRIM(vret) = TRIM(val_multi))
		THEN
			vret := NULL;
		END IF;
	
		IF (NOT ktools.isnumber(vret))
		THEN
			setdata(pdialog, pitem, NULL);
			vret := NULL;
		END IF;
		RETURN vret;
	END getdata;

	FUNCTION ismultiselect
	(
		pdialog IN NUMBER
	   ,pname   IN VARCHAR
	) RETURN BOOLEAN IS
	BEGIN
		RETURN(nvl(dialog.getnumber(pdialog, pname || ip_multisel), 0) = 1);
	END ismultiselect;

	PROCEDURE clearmultisel IS
	BEGIN
		smultimark := NULL;
		samultisel.delete();
	END clearmultisel;

	FUNCTION dialogservice RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DialogService';
		vdialog   NUMBER := 0;
		vwidth    NUMBER := 60;
		vbtnwidth NUMBER := 13;
		vdy       NUMBER;
	
	BEGIN
		vdialog := dialog.new('Viewing parameters', 0, 0, vwidth, 0, pextid => cmethod_name);
	
		vdy := 1;
	
		dialog.bevel(vdialog, 1, vdy, vwidth - 1, 3, dialog.bevel_frame, TRUE, 'Sorting');
	
		vdy := vdy + 1;
		dialog.inputinteger(vdialog, 'SSORT', 18, vdy, '', vwidth - 18 - 4, 'Field:');
		dialog.listaddfield(vdialog, 'SSORT', 'CODE', 'C', 20, 0);
		dialog.listaddfield(vdialog, 'SSORT', 'TEXT', 'C', 50, 1);
	
		vdy := vdy + 1;
		dialog.inputcheck(vdialog
						 ,'SSORT_DESC'
						 ,18
						 ,vdy
						 ,vwidth - 18 - 4
						 ,' Sort in reverse order');
	
		vdy := vdy + 2;
		dialog.button(vdialog
					 ,'btnSet'
					 ,vwidth / 2 - vbtnwidth
					 ,vdy
					 ,vbtnwidth
					 ,'Save'
					 ,dialog.cmok
					 ,0
					 ,'Enter');
		dialog.button(vdialog
					 ,'btnCancel'
					 ,vwidth / 2 + 2
					 ,vdy
					 ,vbtnwidth
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Exit without saving');
	
		dialog.setitemattributies(vdialog, 'BTNSET', dialog.defaulton);
		dialog.setdialogpre(vdialog, cpackage_name || '.DialogServiceHandler');
		dialog.setdialogvalid(vdialog, cpackage_name || '.DialogServiceHandler');
	
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackage_name || '.Service');
			error.showerror();
			IF vdialog != 0
			THEN
				dialog.destroy(vdialog);
			END IF;
			RETURN 0;
	END dialogservice;

	PROCEDURE dialogservicehandler
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN CHAR
	   ,pcmd    IN NUMBER
	) IS
	
		PROCEDURE savefilter IS
			PRAGMA AUTONOMOUS_TRANSACTION;
			vret      NUMBER;
			vsortmode VARCHAR2(100);
		BEGIN
			s.say('!!!point 11');
		
			vsortmode := dialog.getcurrentrecordchar(pdialog, 'SSORT', 'CODE');
		
			setsortmode(vsortmode);
			s.say('!!!point 115');
			vret := datamember.setnumber(object_type
										,clerk.getcode
										,cctypesortdesc
										,service.iif(dialog.getbool(pdialog, 'SSORT_DESC'), 1, 0)
										,'SORT CONTRACT TYPE DESC');
			s.say('!!!point 116');
		
			COMMIT;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackage_name || '.SaveFilter');
				ROLLBACK;
				RAISE;
		END;
	
	BEGIN
		IF pwhat = dialog.wtdialogpre
		THEN
			s.say('DialogPre event ItemName=' || pitem);
		
			dialog.listaddrecord(pdialog, 'SSORT', csortbyorder || '~No', 0, 0);
			dialog.listaddrecord(pdialog, 'SSORT', csortbycode || '~Code', 0, 0);
			dialog.listaddrecord(pdialog, 'SSORT', csortbyname || '~Name', 0, 0);
			dialog.listaddrecord(pdialog, 'SSORT', csortbyschema || '~Procedure', 0, 0);
			dialog.setcurrecbyvalue(pdialog, 'SSORT', 'CODE', getsavedsortmode());
		
			dialog.putbool(pdialog
						  ,'SSORT_DESC'
						  ,nvl(datamember.getnumber(object_type, clerk.getcode, cctypesortdesc), 0) = 1);
		
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			IF (pcmd = dialog.cmok)
			THEN
				s.say('!!!point 2');
				savefilter();
			END IF;
		
		END IF;
	END dialogservicehandler;

	FUNCTION dialoglist
	(
		pselection IN BOOLEAN := FALSE
	   ,pmultisel  IN BOOLEAN := FALSE
	) RETURN NUMBER IS
	BEGIN
		RETURN intdialoglist(pselection, pmultisel, fl_browse);
	END;

	PROCEDURE setselectedtypes IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.SetSelectedTypes';
		vcount NUMBER;
		vadd   BOOLEAN := FALSE;
	BEGIN
		s.say(cmethod_name || ': selected types ' || samultisel.count, csay_level);
		s.say(cmethod_name || ': total contracts ' || scontracttyperecarr.count, csay_level);
		IF samultisel.count > 0
		THEN
			IF scontracttyperecarr.count > 0
			THEN
				smultimark := NULL;
				vcount     := 0;
				FOR i IN 1 .. scontracttyperecarr.count
				LOOP
					FOR j IN 1 .. samultisel.count
					LOOP
						IF samultisel(j) = scontracttyperecarr(i).type
						THEN
							smultimark := smultimark || '1';
							vcount     := vcount + 1;
							vadd       := TRUE;
							EXIT;
						END IF;
					END LOOP;
				
					IF NOT vadd
					THEN
						smultimark := smultimark || ' ';
					ELSE
						vadd := FALSE;
					END IF;
					EXIT WHEN vcount >= samultisel.count;
				END LOOP;
			END IF;
		END IF;
		s.say(cmethod_name || ': selected ' || smultimark, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setselectedtypes;

	FUNCTION getrightkey
	(
		pright       IN NUMBER
	   ,prightparams IN typecheckrightparams := semptyrightparams
	) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetRightKey';
		vschemetype tcontractschemas.type%TYPE;
	BEGIN
		IF pright IN (right_scheme_parameters)
		THEN
			vschemetype := prightparams.schemetype;
		
			IF vschemetype IS NULL
			THEN
				IF prightparams.contracttype IS NOT NULL
				THEN
					vschemetype := getschematype(prightparams.contracttype);
					error.raisewhenerr();
				ELSE
					error.raiseerror('Not defined financial scheme ID');
				END IF;
			END IF;
		
			IF prightparams.rightident IS NULL
			THEN
				RETURN '|' || pright || '|' || to_char(vschemetype) || '|';
			ELSE
				RETURN '|' || pright || '|' || to_char(vschemetype) || '|' || prightparams.rightident || '|';
			END IF;
		ELSE
			RETURN '|' || to_char(pright) || '|';
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getrightkey;

	FUNCTION checkright
	(
		pright       IN NUMBER
	   ,prightparams IN typecheckrightparams := semptyrightparams
	) RETURN BOOLEAN
	
	 IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.CheckRight';
	BEGIN
		RETURN security.checkright(object_name, getrightkey(pright, prightparams));
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END checkright;

	FUNCTION dialogoptions RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.DialogOptions';
		vdialog     NUMBER := 0;
		width       NUMBER := 60;
		height      NUMBER := 0;
		clientwidth NUMBER := width - 1;
		buttonwidth NUMBER := 12;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		vdialog := dialog.new('Contract types setup', 0, 0, width, height, pextid => cmethod_name);
		dialog.setdialogpre(vdialog, cpackage_name || '.DialogOptionsHandler');
		dialog.setdialogvalid(vdialog, cpackage_name || '.DialogOptionsHandler');
	
		dialog.bevel(vdialog
					,1
					,1
					,clientwidth
					,5
					,dialog.bevel_frame
					,pcaption => 'Restrictions on changing contract type');
	
		dialog.inputcheck(vdialog
						 ,'CheckIdentAccType'
						 ,5
						 ,2
						 ,plen               => 50
						 ,pcaption           => 'Check correspondence of account types'
						 ,phint              => '');
		dialog.setitempre(vdialog
						 ,'CheckIdentAccType'
						 ,cpackage_name || '.DialogOptionsHandler'
						 ,dialog.proctype);
		dialog.inputcheck(vdialog
						 ,'CheckIdentTierAcc'
						 ,5
						 ,3
						 ,plen               => 50
						 ,pcaption           => 'Check correspondence of balance accounts'
						 ,phint              => '');
		dialog.inputcheck(vdialog
						 ,'ChangeAccType'
						 ,5
						 ,4
						 ,plen           => 50
						 ,pcaption       => 'Allow changing account types'
						 ,phint          => 'Allow changing account types if they are not identical');
		dialog.inputcheck(vdialog
						 ,'ChangeFinProfile'
						 ,5
						 ,5
						 ,plen              => 50
						 ,pcaption          => 'Allow changing financial profile'
						 ,phint             => 'Allow changing financial profile of contract');
		dialog.setitempre(vdialog
						 ,'ChangeAccType'
						 ,cpackage_name || '.DialogOptionsHandler'
						 ,dialog.proctype);
	
		dialog.button(vdialog
					 ,'Ok'
					 ,17
					 ,7
					 ,buttonwidth
					 ,'Enter'
					 ,dialog.cmok
					 ,0
					 ,'Save and exit dialog box');
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
		dialog.button(vdialog
					 ,'Cancel'
					 ,31
					 ,7
					 ,buttonwidth
					 ,'Exit'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel data saving and exit dialog box');
	
		s.say(cmethod_name || ': returns ' || vdialog, csay_level);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			IF vdialog != 0
			THEN
				dialog.destroy(vdialog);
				vdialog := 0;
			END IF;
			error.showerror;
			RETURN 0;
	END;

	PROCEDURE dialogoptionshandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.DialogOptionsHandler';
		pright_modify BOOLEAN;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		IF pwhat = dialog.wtdialogpre
		THEN
			dialog.putbool(pdialog
						  ,'ChangeAccType'
						  ,contractparams.loadchar(contractparams.getobjecttype(ccontracttypebranch)
												  ,0
												  ,'CHANGEACCTYPE'
												  ,FALSE) = '1');
			dialog.putbool(pdialog
						  ,'CheckIdentAccType'
						  ,contractparams.loadchar(contractparams.getobjecttype(ccontracttypebranch)
												  ,0
												  ,'CHECKIDENTACCTYPE'
												  ,FALSE) = '1');
			dialog.putbool(pdialog
						  ,'CheckIdentTierAcc'
						  ,contractparams.loadchar(contractparams.getobjecttype(ccontracttypebranch)
												  ,0
												  ,'CHECKIDENTTIERACC'
												  ,FALSE) = '1');
			dialog.putbool(pdialog
						  ,'ChangeFinProfile'
						  ,contractparams.loadchar(contractparams.getobjecttype(ccontracttypebranch)
												  ,0
												  ,'CHANGEFINPROFILE'
												  ,FALSE) = '1');
			pright_modify := contracttype.checkright(contracttype.right_modify);
			IF NOT pright_modify
			THEN
				dialog.setenable(pdialog, 'CheckIdentAccType', pright_modify);
				dialog.setenable(pdialog, 'CheckIdentTierAcc', pright_modify);
				dialog.setenable(pdialog, 'ChangeAccType', pright_modify);
				dialog.setenable(pdialog, 'ChangeFinProfile', pright_modify);
				dialog.setenable(pdialog, 'Ok', pright_modify);
			END IF;
		ELSIF pwhat = dialog.wtitempre
		THEN
			s.say('Dailog.ItemPre', csay_level);
			IF (pitemname = upper('CheckIdentAccType'))
			THEN
				s.say('pItemName=CheckIdentAccType', csay_level);
				IF dialog.getbool(pdialog, 'CheckIdentAccType')
				THEN
					dialog.putbool(pdialog, 'ChangeAccType', FALSE);
				END IF;
			ELSIF (pitemname = upper('ChangeAccType'))
			THEN
				s.say('pItemName=ChangeAccType', csay_level);
				IF dialog.getbool(pdialog, 'ChangeAccType')
				THEN
					dialog.putbool(pdialog, 'CheckIdentAccType', FALSE);
				END IF;
			END IF;
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			IF pcmd = dialog.cmok
			THEN
				contractparams.savechar(contractparams.getobjecttype(ccontracttypebranch)
									   ,0
									   ,'CHANGEACCTYPE'
									   ,service.iif(dialog.getbool(pdialog, 'ChangeAccType')
												   ,'1'
												   ,'0'));
				contractparams.savechar(contractparams.getobjecttype(ccontracttypebranch)
									   ,0
									   ,'CHECKIDENTACCTYPE'
									   ,service.iif(dialog.getbool(pdialog, 'CheckIdentAccType')
												   ,'1'
												   ,'0'));
				contractparams.savechar(contractparams.getobjecttype(ccontracttypebranch)
									   ,0
									   ,'CHECKIDENTTIERACC'
									   ,service.iif(dialog.getbool(pdialog, 'CheckIdentTierAcc')
												   ,'1'
												   ,'0'));
				contractparams.savechar(contractparams.getobjecttype(ccontracttypebranch)
									   ,0
									   ,'CHANGEFINPROFILE'
									   ,service.iif(dialog.getbool(pdialog, 'ChangeFinProfile')
												   ,'1'
												   ,'0'));
				COMMIT;
			END IF;
		END IF;
		s.say(cmethod_name || ': leave ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			error.showerror;
			dialog.cancelclose(pdialog);
	END;

	FUNCTION gettyperecbyrecno(precno IN NUMBER) RETURN custom_fintypes.typecontracttyperecord IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetTypeRecByRecNo';
		vret custom_fintypes.typecontracttyperecord;
	BEGIN
		IF scontracttyperecarr.exists(precno)
		THEN
			RETURN scontracttyperecarr(precno);
		ELSE
			RETURN vret;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getrecordbyident
	(
		pident     IN tcontracttype.ident%TYPE
	   ,puppercase IN BOOLEAN := FALSE
	) RETURN tcontracttype%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.GetRecordByIdent';
		vreturn tcontracttype%ROWTYPE := NULL;
		vident  tcontracttype.ident%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pIdent=' || pident || ', pUpperCase=' || t.b2t(puppercase)
			   ,csay_level);
	
		vident := TRIM(pident);
	
		IF vident IS NULL
		THEN
			error.raiseerror('Contract type ID not defined');
		END IF;
	
		IF NOT nvl(puppercase, FALSE)
		THEN
			SELECT * INTO vreturn FROM tcontracttype WHERE ident = vident;
		ELSE
			SELECT * INTO vreturn FROM tcontracttype WHERE upper(ident) = upper(vident);
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
		RETURN vreturn;
	EXCEPTION
		WHEN no_data_found THEN
			t.leave(cmethod_name, '[no data found]', plevel => csay_level);
			RETURN vreturn;
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getnextuniqtype RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.GetNextUniqType';
		vret   NUMBER;
		vctrow tcontracttype%ROWTYPE;
	BEGIN
		SELECT scontracttype.nextval INTO vret FROM dual;
	
		vctrow := getrecord(vret);
		IF vctrow.type IS NOT NULL
		THEN
			vret := getnextuniqtype;
		END IF;
	
		RETURN vret;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE addnewtype(pocontracttyperow IN OUT tcontracttype%ROWTYPE) IS
		cmethod_name CONSTANT VARCHAR(80) := cpackage_name || '.AddNewType';
	BEGIN
		t.enter(cmethod_name
			   ,'Branch=' || pocontracttyperow.branch || ', Type=' || pocontracttyperow.type ||
				', ObjectUID=' || pocontracttyperow.objectuid
			   ,csay_level);
		IF pocontracttyperow.branch IS NULL
		THEN
			pocontracttyperow.branch := seance.getbranch();
		END IF;
	
		IF pocontracttyperow.type IS NULL
		THEN
			pocontracttyperow.type := getnextuniqtype();
		END IF;
		t.note(cmethod_name, 'poContractTypeRow.Type=' || pocontracttyperow.type, csay_level);
	
		IF TRIM(pocontracttyperow.ident) IS NULL
		THEN
			pocontracttyperow.ident := ctempl_ident || to_char(pocontracttyperow.type);
		ELSE
			pocontracttyperow.ident := TRIM(pocontracttyperow.ident);
		END IF;
		t.var('poContractTypeRow.Ident', pocontracttyperow.ident);
	
		IF pocontracttyperow.objectuid IS NULL
		THEN
			pocontracttyperow.objectuid := objectuid.newuid(object_name
														   ,pocontracttyperow.type
														   ,pnocommit => TRUE);
		END IF;
	
		SELECT nvl(MAX(sortorder), 0) + 1
		INTO   pocontracttyperow.sortorder
		FROM   tcontracttype
		WHERE  branch = pocontracttyperow.branch;
	
		INSERT INTO tcontracttype VALUES pocontracttyperow;
		t.leave(cmethod_name
			   ,'poContractTypeRow.ObjectUID=' || pocontracttyperow.objectuid
			   ,csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE deletetype(pcontracttype IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR(80) := cpackage_name || '.DeleteType';
		vsortorder NUMBER;
		vobjectuid NUMBER;
		vbranch    NUMBER := seance.getbranch();
	BEGIN
		s.say(cmethod_name || ': start', csay_level);
	
		SELECT sortorder
		INTO   vsortorder
		FROM   tcontracttype
		WHERE  branch = vbranch
		AND    TYPE = pcontracttype;
	
		DELETE FROM tcontracttype
		WHERE  branch = vbranch
		AND    TYPE = pcontracttype
		RETURNING objectuid INTO vobjectuid;
	
		s.say(cmethod_name || ', delete: ObjectUID=' || to_char(vobjectuid));
	
		IF vobjectuid IS NOT NULL
		THEN
			objectuid.freeuid(vobjectuid);
		END IF;
	
		contractbankaccounts.deleteobjectsettings(contractparams.ccontracttype, pcontracttype);
	
		UPDATE tcontracttype
		SET    sortorder = sortorder - 1
		WHERE  branch = vbranch
		AND    sortorder > vsortorder;
	
		s.say(cmethod_name || ': finish', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE copyextrauserattributes
	(
		psourcecontracttype   IN typecontracttype
	   ,ptargetcontracttype   IN typecontracttype
	   ,pclearsourceextraattr IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CopyExtraUserAttributes';
		vextrausrattr CLOB;
		vreport       CLOB;
	BEGIN
		IF objuserproperty.existsproperty(contract.object_name, psourcecontracttype, FALSE)
		THEN
			vextrausrattr := objuserproperty.exportreference(contract.object_name
															,psourcecontracttype);
			objuserproperty.clearreference(contract.object_name, ptargetcontracttype);
			objuserproperty.importreference(vextrausrattr
										   ,contract.object_name
										   ,ptargetcontracttype
										   ,vreport);
			s.say(cmethod_name || ': vReport=' || vreport, csay_level);
			IF nvl(pclearsourceextraattr, FALSE)
			THEN
				objuserproperty.clearreference(contract.object_name, psourcecontracttype);
			END IF;
		ELSE
			objuserproperty.clearreference(contract.object_name, ptargetcontracttype);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION dialogtype
	(
		pfilter IN contracttype.typectypefilter
	   ,pmode   IN PLS_INTEGER := cmode_add
	   ,precno  IN NUMBER := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DialogType';
		vdialog    NUMBER;
		vtitle     VARCHAR2(30);
		vctrec     custom_fintypes.typecontracttyperecord;
		vpage      NUMBER;
		vextrapage NUMBER;
		vwidth     NUMBER := 72;
	BEGIN
		t.enter(cmethod_name, 'pFilter.SchemaType=' || pfilter.schematype, csay_level);
		CASE pmode
			WHEN cmode_copy THEN
				IF precno IS NULL
				   OR precno <= 0
				THEN
					error.raiseerror('Error copying contract type: source contract type not defined');
				END IF;
				vtitle := 'Copy contract type';
				vctrec := gettyperecbyrecno(precno);
			ELSE
				vtitle            := 'Add contract type';
				vctrec.accessory  := nvl(pfilter.accessory, cclient);
				vctrec.schematype := pfilter.schematype;
				vctrec.favorite   := '1';
				vctrec.status     := '1';
		END CASE;
		vdialog := dialog.new(vtitle, 0, 0, vwidth, 0, pextid => cmethod_name);
		dialog.hiddennumber(vdialog, 'Mode');
		dialog.putnumber(vdialog, 'Mode', pmode);
		dialog.hiddennumber(vdialog, 'SourceContractType');
		dialog.hiddennumber(vdialog, 'TargetContractType');
	
		vpage := vdialog;
		CASE pmode
			WHEN cmode_add THEN
				dialog.pagelist(vdialog, 'PAGER', 1, 1, vwidth - 1, 17);
				vpage := dialog.page(vdialog, 'PAGER', 'General');
				objuserproperty.addpage(vdialog, 'PAGER', 'User', 16, contracttype.object_name);
			
				vextrapage := dialog.page(vdialog, 'PAGER', 'Additional');
				dialog.hiddennumber(vdialog, 'EXTRAUSRPAGEID', vextrapage);
				objuserproperty.clearreference(contract.object_name, cemptycontracttype);
				objuserproperty.makereferencepage(contract.object_name
												 ,cemptycontracttype
												 ,vextrapage
												 ,vwidth - 2
												 ,16
												 ,nvl(contracttype.can_modify, FALSE)
												 ,12
												 ,pstarty => 1);
				objuserproperty.fillreferencepage(vextrapage);
			ELSE
				dialog.bevel(vpage, 1, 1, vwidth - 1, 16, dialog.bevel_frame, NULL, '');
		END CASE;
	
		dialog.inputinteger(vpage, cdlg_type, 18, 2, 'Contract type code', 6, 'Code:');
	
		dialog.inputchar(vpage
						,cdlg_ident
						,18
						,3
						,40
						,'Contract type unique ID'
						,40
						,'           ID:');
	
		dialog.inputchar(vpage, 'eName', 18, 4, 47, 'Contract type name', 80, '        Name:');
		dialog.setitemcommand(vpage, 'eName', dialog.cmok);
	
		IF pmode = cmode_copy
		THEN
			dialog.putchar(vpage, 'eName', 'Copy-' || vctrec.name);
			dialog.putnumber(vpage, 'SourceContractType', vctrec.type);
		END IF;
	
		dialog.inputchar(vpage
						,'eAccessory'
						,18
						,5
						,40
						,'Contract type belonging'
						,NULL
						,'Belongs to:');
		dialog.listaddfield(vpage, 'eAccessory', 'Type', 'N', 1, 0);
		dialog.listaddfield(vpage, 'eAccessory', 'Name', 'C', 17, 1);
		dialog.listaddrecord(vpage
							,'eAccessory'
							,cclient || '~' || saaccessory(cclient) || '~'
							,0
							,0);
		dialog.listaddrecord(vpage
							,'eAccessory'
							,ccorporate || '~' || saaccessory(ccorporate) || '~'
							,0
							,0);
	
		dialog.setreadonly(vpage, 'eAccessory', TRUE);
		dialog.setcurrecbyvalue(vpage, 'eAccessory', 'Type', vctrec.accessory);
	
		dialog.bevel(vpage, 2, 6, 65, 3, dialog.bevel_frame, pcaption => 'Status');
	
		dialog.inputcheck(vpage, 'chStatus', 18, 7, 13, 'Active');
		dialog.setitempre(vpage, 'chStatus', cpackage_name || '.DialogTypeHandler');
		dialog.inputdate(vpage, 'StartDate', 35, 7, 'Start date', 'from:');
		dialog.putdate(vpage, 'StartDate', vctrec.startdate);
		dialog.inputdate(vpage, 'EndDate', 50, 7, 'Expiration date', 'to:');
		dialog.putdate(vpage, 'EndDate', vctrec.enddate);
	
		dialog.inputcheck(vpage, 'chFavorite', 18, 8, 15, 'Priority');
		dialog.putbool(vpage, 'chStatus', substr(vctrec.status, 1, 1) = '1');
		dialog.putbool(vpage, 'chFavorite', vctrec.favorite = '1');
	
		dialog.bevel(vpage, 2, 9, 65, 4, dialog.bevel_frame, NULL, 'Financial scheme');
		ctdialog.schema_create(vpage, 'eSchema', px => 18, py => 10, plen => 40);
		ctdialog.schema_prepare(vpage, 'eSchema', vctrec.schematype, 0, pinsempty => TRUE);
		dialog.setitemchange(vpage, 'eSchema', cpackage_name || '.DialogTypeHandler');
		dialog.setitempost(vpage, 'eSchema', cpackage_name || '.DialogTypeHandler');
	
		IF vctrec.schematype IS NOT NULL
		THEN
			dialog.setenabled(vpage, 'eSchema', FALSE);
		END IF;
	
		s.say(cpackage_name || '.DialogType contract type group = ' || pfilter.ctgroup, csay_level);
		referencegroupct.makeitem(vpage
								 ,'eGroup'
								 ,18
								 ,14
								 ,7
								 ,'Group:'
								 ,'Belonging to group'
								 ,plablen             => 35
								 ,pcmd                => 0
								 ,pfilter             => pfilter
								 ,pdisabled           => pfilter.ctgroup IS NOT NULL);
	
		dialog.button(vdialog
					 ,'btnOk'
					 ,vwidth / 2 - 11 - 2
					 ,19
					 ,11
					 ,'Enter'
					 ,dialog.cmok
					 ,0
					 ,'Save changes');
		dialog.button(vdialog
					 ,'btnCancel'
					 ,vwidth / 2 + 2
					 ,19
					 ,11
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel changes');
		dialog.setdefault(vdialog, 'btnOk');
	
		dialog.setdialogpre(vdialog, 'ContractType.DialogTypeHandler');
		dialog.setdialogvalid(vdialog, 'ContractType.DialogTypeHandler');
		dialog.setdialogpost(vdialog, 'ContractType.DialogTypeHandler');
	
		--createdialogfilterfields(vdialog, pfilter);
	
		t.leave(cmethod_name, plevel => csay_level);
		RETURN vdialog;
	
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END dialogtype;

	PROCEDURE dialogtypehandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR(40) := cpackage_name || '.DialogTypeHandler';
	
		vident     NUMBER;
		vgroup     NUMBER := NULL;
		vctrow     tcontracttype%ROWTYPE;
		vctrowtemp tcontracttype%ROWTYPE;
		vmode      PLS_INTEGER;
	BEGIN
		IF (pwhat = dialog.wtdialogpre)
		THEN
			vmode := dialog.getnumber(pdialog, 'Mode');
			CASE vmode
				WHEN cmode_copy THEN
					dialog.setenabled(pdialog, 'eAccessory', FALSE);
					dialog.setenabled(pdialog, 'chStatus', FALSE);
					dialog.setenabled(pdialog, 'StartDate', FALSE);
					dialog.setenabled(pdialog, 'EndDate', FALSE);
					dialog.setenabled(pdialog, 'chFavorite', FALSE);
					dialog.setenabled(pdialog, 'chStatus', FALSE);
					dialog.setenabled(pdialog, 'eSchema', FALSE);
				ELSE
					dialog.putbool(pdialog, 'chStatus', TRUE);
					dialog.setenabled(pdialog, 'StartDate', TRUE);
					dialog.setenabled(pdialog, 'EndDate', TRUE);
					dialog.putbool(pdialog, 'chFavorite', TRUE);
					objuserproperty.fillpage(pdialog, contracttype.object_name);
			END CASE;
		
		ELSIF pwhat = dialog.wt_nextfield
		THEN
			vident := dialog.getrecordnumber(pdialog
											,pitemname
											,'ItemID'
											,dialog.getlistcurrentrecordnumber(pdialog, pitemname));
			ctdialog.schema_prepare(pdialog, pitemname, vident, 0, pinsempty => TRUE);
			IF vident IS NULL
			THEN
				dialog.putchar(pdialog, 'SchemaCode_' || pitemname, NULL);
				dialog.putchar(pdialog, 'Pack_' || pitemname, NULL);
			END IF;
		
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF pitemname = upper('chStatus')
			THEN
				IF dialog.getbool(pdialog, 'chStatus')
				THEN
					dialog.setenabled(pdialog, 'StartDate', TRUE);
					dialog.setenabled(pdialog, 'EndDate', TRUE);
				ELSE
					dialog.setenabled(pdialog, 'StartDate', FALSE);
					dialog.setenabled(pdialog, 'EndDate', FALSE);
				END IF;
			END IF;
		
		ELSIF (pwhat = dialog.wtdialogvalid)
		THEN
			vmode := dialog.getnumber(pdialog, 'Mode');
		
			IF (dialog.getchar(pdialog, 'eName') IS NULL)
			THEN
				dialog.sethothint(pdialog, 'Field name must be specified');
				dialog.goitem(pdialog, 'eName');
				dialog.cancelclose(pdialog);
				RETURN;
			END IF;
		
			IF vmode = cmode_copy
			   AND dialog.getnumber(pdialog, pitem => 'SchemaCode_eSchema') IS NULL
			THEN
				dialog.sethothint(pdialog, 'Financial scheme must be specified');
				dialog.goitem(pdialog, 'SchemaCode_eSchema');
				dialog.cancelclose(pdialog);
				RETURN;
			END IF;
		
			IF vmode = cmode_add
			   AND pcmd = dialog.cmok
			THEN
				IF NOT objuserproperty.validpage(pdialog, contracttype.object_name)
				THEN
					dialog.cancelclose(pdialog);
					RETURN;
				END IF;
			
				vctrow.startdate := nvl(dialog.getdate(pdialog, 'StartDate')
									   ,nvl(dialog.getdate(pdialog, 'EndDate'), seance.getoperdate));
				vctrow.enddate   := nvl(dialog.getdate(pdialog, 'EndDate'), vctrow.startdate);
				IF vctrow.enddate < vctrow.startdate
				THEN
					htools.message('Warning!'
								  ,'Contract type expiration date must be later than start date');
					dialog.goitem(pdialog, 'EndDate');
					dialog.cancelclose(pdialog);
					RETURN;
				END IF;
			
			END IF;
		
			vctrow.type := dialog.getnumber(pdialog, cdlg_type);
			IF vctrow.type IS NOT NULL
			THEN
			
				vctrowtemp := getrecord(vctrow.type, pdoexception => FALSE);
				IF vctrowtemp.type IS NOT NULL
				THEN
					dialog.sethothint(pdialog
									 ,'Dictionary already contains contract type with code [' ||
									  vctrow.type || ']');
					dialog.goitem(pdialog, cdlg_type);
					dialog.cancelclose(pdialog);
					RETURN;
				END IF;
			END IF;
		
			vctrow.ident := TRIM(dialog.getchar(pdialog, cdlg_ident));
			IF vctrow.ident IS NOT NULL
			THEN
				vctrowtemp := getrecordbyident(vctrow.ident, FALSE);
				IF vctrowtemp.type IS NOT NULL
				THEN
					dialog.sethothint(pdialog
									 ,'Dictionary already contains contract type with ID [' ||
									  vctrow.ident || ']');
					dialog.goitem(pdialog, cdlg_ident);
					dialog.cancelclose(pdialog);
					RETURN;
				ELSE
					vctrowtemp := getrecordbyident(vctrow.ident, TRUE);
					IF vctrowtemp.type IS NOT NULL
					THEN
						IF NOT htools.askconfirm('Warning'
												,'Dictionary already contains contract type with similar ID:~[' ||
												 vctrowtemp.ident || ']-[' || vctrowtemp.type ||
												 ']-[' || vctrowtemp.name || ']~ Continue?')
						THEN
							dialog.goitem(pdialog, cdlg_ident);
							dialog.cancelclose(pdialog);
							RETURN;
						END IF;
					END IF;
				END IF;
			END IF;
		
		ELSIF (pwhat = dialog.wtdialogpost)
		THEN
			IF (pcmd = dialog.cmok)
			THEN
				vmode       := dialog.getnumber(pdialog, 'Mode');
				vctrow.type := dialog.getnumber(pdialog, cdlg_type);
			
				vctrow.ident := TRIM(dialog.getchar(pdialog, cdlg_ident));
			
				vctrow.name      := dialog.getchar(pdialog, 'eName');
				vctrow.accessory := dialog.getcurrentrecordnumber(pdialog, 'eAccessory', 'Type');
				IF (dialog.getbool(pdialog, 'chStatus'))
				THEN
					vctrow.status    := '1';
					vctrow.startdate := dialog.getdate(pdialog, 'StartDate');
					vctrow.enddate   := dialog.getdate(pdialog, 'EndDate');
				ELSE
					vctrow.status := ' ';
				END IF;
				IF (dialog.getbool(pdialog, 'chFavorite'))
				THEN
					vctrow.favorite := '1';
				ELSE
					vctrow.favorite := NULL;
				END IF;
				vctrow.schematype := dialog.getnumber(pdialog, pitem => 'SchemaCode_eSchema');
				vgroup            := referencegroupct.getdata(pdialog, pitem => 'eGroup');
			
				DECLARE
					vlogmessage VARCHAR2(500);
				BEGIN
					SAVEPOINT insertnewct;
					addnewtype(vctrow);
					dialog.putnumber(pdialog, 'TargetContractType', vctrow.type);
					IF vctrow.schematype IS NOT NULL
					THEN
						IF vmode = cmode_copy
						THEN
							ctdialog.changeschema(vctrow.type, vctrow.schematype, FALSE);
						ELSE
							ctdialog.changeschema(vctrow.type, vctrow.schematype);
						END IF;
					END IF;
					IF vgroup IS NOT NULL
					THEN
						referencegroupct.addtype2group(vctrow.type, vgroup);
					END IF;
					vlogmessage := 'Created contract type ' || saaccessory(vctrow.accessory);
					a4mlog.cleanparamlist();
					a4mlog.addparamrec('TYPE', vctrow.type);
					a4mlog.addparamrec('TYPENAME', vctrow.name);
					IF a4mlog.logobject(object.gettype(contracttype.object_name)
									   ,vctrow.type
									   ,vlogmessage
									   ,a4mlog.act_add
									   ,a4mlog.putparamlist()) != 0
					THEN
						error.raisewhenerr();
					END IF;
					a4mlog.cleanplist();
					IF vmode = cmode_copy
					THEN
						importcontracttype(dialog.getnumber(pdialog, 'SourceContractType')
										  ,vctrow.type
										  ,TRUE);
					ELSE
						objuserproperty.savepage(pdialog
												,contracttype.object_name
												,vctrow.objectuid);
						copyextrauserattributes(cemptycontracttype, vctrow.type, TRUE);
					END IF;
					COMMIT;
				EXCEPTION
					WHEN OTHERS THEN
						ROLLBACK TO insertnewct;
						error.save(cmethod_name);
						RAISE;
				END;
			ELSE
				objuserproperty.clearreference(contract.object_name, cemptycontracttype);
				COMMIT;
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			error.save(cmethod_name);
			error.showerror();
	END dialogtypehandler;

	PROCEDURE dialoglisthandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.DialogListHandler';
		vindex INTEGER;
		vmark  VARCHAR(10000);
	
		vrecno        NUMBER;
		vmode         PLS_INTEGER;
		vctrec        custom_fintypes.typecontracttyperecord;
		vcontracttype typecontracttype;
	BEGIN
		IF (pwhat = dialog.wtdialogpre)
		THEN
		
			IF (NOT smultiselection)
			THEN
				vrecno := filllistscroller(pdialog, NULL);
				browser.scrollerrefresh(pdialog, dialog.firstrecord);
				IF (scontracttyperecarr.count = 0)
				THEN
					dialog.setenabled(pdialog, 'btnDelete', FALSE);
					dialog.setenabled(pdialog, 'btnCopy', FALSE);
				ELSE
					IF (can_modify)
					THEN
						dialog.setenabled(pdialog, 'btnDelete', TRUE);
						dialog.setenabled(pdialog, 'btnCopy', TRUE);
					END IF;
				END IF;
				findpanel_init(pdialog);
			ELSE
				fillchecklist(pdialog);
				setselectedtypes;
				dialog.putchar(pdialog, 'cbList', smultimark);
			END IF;
			dialog.setenable(pdialog, 'mnu_UserPropRef', checkright(right_view));
		ELSIF (pwhat = dialog.wtitempre)
		THEN
			IF (pitemname IN ('BTNADD', 'BTNCOPY'))
			THEN
				vrecno := browser.getcurpos(pdialog);
				vctrec := gettyperecbyrecno(vrecno);
				IF pitemname = 'BTNCOPY'
				THEN
					vmode := cmode_copy;
				ELSE
					vmode := cmode_add;
				END IF;
				DECLARE
					vdialog NUMBER;
					vcmd    NUMBER;
				BEGIN
					--vdialog := dialogtype(getdialogfilter(pdialog), vmode, vrecno);
				
					vcmd := dialog.execdialog(vdialog);
					IF vcmd = dialog.cmok
					THEN
						vcontracttype := dialog.getnumber(vdialog, 'TargetContractType');
						s.say(cmethod_name || ', TargetContractType=' || vcontracttype, csay_level);
						IF (can_modify)
						THEN
							dialog.setenabled(pdialog, 'btnDelete', TRUE);
							dialog.setenabled(pdialog, 'btnCopy', TRUE);
						END IF;
						vrecno := filllistscroller(pdialog, vcontracttype);
						browser.scrollerrefresh(pdialog, vrecno);
					END IF;
					dialog.destroy(vdialog);
				EXCEPTION
					WHEN OTHERS THEN
						error.save(cmethod_name);
						error.showerror;
						dialog.destroy(vdialog);
				END;
			ELSIF (pitemname = 'BTNDELETE')
			THEN
				vrecno := browser.getcurpos(pdialog);
				vctrec := gettyperecbyrecno(vrecno);
				BEGIN
					IF contracttype.getname(vctrec.type) IS NULL
					THEN
						htools.showmessage('Warning!'
										  ,'Contract type [' || vctrec.type ||
										   '] does not exist.~');
						vrecno := filllistscroller(pdialog, vctrec.type);
						browser.scrollerrefresh(pdialog, vrecno);
						IF (scontracttyperecarr.count = 0)
						THEN
							dialog.setenabled(pdialog, 'btnDelete', FALSE);
							dialog.setenabled(pdialog, 'btnCopy', FALSE);
						END IF;
						RETURN;
					END IF;
					IF candeletetype(vctrec.type)
					THEN
						IF dialog.exec(service.dialogconfirm('Delete contract type'
															,'Delete type "' || vctrec.name || '"?'
															,'  Yes '
															,'Delete'
															,'  No   '
															,'Cancel deletion')) = dialog.cmok
						THEN
						
							CASE object.capture(object_name, vctrec.type)
								WHEN 0 THEN
									DECLARE
										vlogmessage VARCHAR2(500);
										vres        NUMBER;
									BEGIN
										vlogmessage := 'Deleted contract type';
										a4mlog.cleanparamlist();
										a4mlog.addparamrec('TYPE', vctrec.type);
										a4mlog.addparamrec('TYPENAME', vctrec.name);
										IF a4mlog.logobject(object.gettype(contracttype.object_name)
														   ,vctrec.type
														   ,vlogmessage
														   ,a4mlog.act_del
														   ,a4mlog.putparamlist()) != 0
										THEN
											error.raisewhenerr();
										END IF;
										a4mlog.cleanplist();
									
										contract.revokerights(vctrec.type);
										deletetype(vctrec.type);
									
										vres := datamember.datamemberdelete(object_type
																		   ,vctrec.type
																		   ,'CTSchemaType');
										objuserproperty.clearreference(contract.object_name
																	  ,vctrec.type);
										COMMIT;
										object.release(object_name, vctrec.type);
									EXCEPTION
										WHEN OTHERS THEN
											object.release(object_name, vctrec.type);
											error.save(cmethod_name);
											RAISE;
									END;
								WHEN err.object_busy THEN
									htools.showmessage('Warning!'
													  ,'Impossible to delete contract type,~' ||
													   'as it is being edited from another station~' ||
													   object.capturedobjectinfo(object_name
																				,vctrec.type) || '~');
								ELSE
									service.sayerr(pdialog, 'Warning!');
							END CASE;
						
							s.say(cmethod_name || ': current type ' || vctrec.type, csay_level);
							vrecno := filllistscroller(pdialog, vctrec.type);
							browser.scrollerrefresh(pdialog, vrecno);
							IF (scontracttyperecarr.count = 0)
							THEN
								dialog.setenabled(pdialog, 'btnDelete', FALSE);
								dialog.setenabled(pdialog, 'btnCopy', FALSE);
							END IF;
						END IF;
					ELSE
						htools.showmessage('Warning!'
										  ,'Impossible to delete contract type~' ||
										   'contracts of this type exist.~');
					END IF;
				END;
			ELSIF (pitemname = 'SCROLLER')
			THEN
				vrecno := browser.getcurpos(pdialog);
				vctrec := gettyperecbyrecno(vrecno);
				dialog.exec(ctdialog.getdialog_edit(vctrec.type));
				vrecno := filllistscroller(pdialog, vctrec.type);
				browser.scrollerrefresh(pdialog, vrecno);
			ELSIF pitemname = 'GROUP'
			THEN
				dialog.exec(referencegroupct.dialoggrouplist(NOT can_modify));
			ELSIF pitemname = upper(cdocimage)
			THEN
				image.showreferenceavailabledoctype(contract.object_name, can_modify);
			ELSIF pitemname = 'SERVICE'
			THEN
				vrecno := browser.getcurpos(pdialog);
				s.say('~point 1');
				vctrec := gettyperecbyrecno(vrecno);
				s.say('~point 2');
				dialog.exec(dialogservice());
				s.say('~point 3');
				vrecno := filllistscroller(pdialog, vctrec.type);
				s.say('~point 4');
				browser.scrollerrefresh(pdialog, vrecno);
				IF can_modify
				THEN
					dialog.setenabled(pdialog, 'btnDelete', getcount() > 0);
					dialog.setenabled(pdialog, 'btnCopy', getcount() > 0);
				END IF;
			ELSIF pitemname = 'SCHEMALIST'
			THEN
			
				DECLARE
					vcount NUMBER;
				BEGIN
					t.note('checking tContractSchemas...');
					SELECT COUNT(a.type)
					INTO   vcount
					FROM   tcontractschemas a
					WHERE  a.packagename != upper(a.packagename);
					t.var('vCount', vcount);
					IF vcount > 0
					THEN
						BEGIN
							SAVEPOINT updateschemalist;
							UPDATE tcontractschemas t SET t.packagename = upper(t.packagename);
							t.note('affected: ' || SQL%ROWCOUNT);
							COMMIT;
						EXCEPTION
							WHEN OTHERS THEN
								t.note('Exeption: ' || SQLERRM);
								ROLLBACK TO updateschemalist;
						END;
					END IF;
				END;
			
				dialog.exec(contractschemas.getdialog_view());
			
			ELSIF pitemname = 'REFCOLRULES'
			THEN
			
				dialog.exec(refcollectionrules.maindlg());
			
			ELSIF pitemname = 'MNU_RATEREF'
			THEN
				dialog.exec(referenceprchistory.maindialog(referenceprchistory.ccontracttype
														  ,NULL
														  ,preadonly => NOT can_modify));
			ELSIF pitemname = upper('mnu_UserPropRef')
			THEN
				objuserproperty.showreference(object_name
											 ,checkright(right_modify)
											 ,'Contract types');
			ELSIF pitemname = 'OPTIONS'
			THEN
				dialog.exec(dialogoptions());
			
			ELSIF pitemname = cdlg_btn_clear
			THEN
				findpanel_clear(pdialog);
			
			END IF;
		ELSIF pwhat = dialog.wtitempost
		THEN
			IF (pitemname = 'MNU_BASE_SOT')
			THEN
				IF checkright(right_modify)
				THEN
					sot_core.edittemplatesinteractive(apitypes.csotcsocontracttype
													 ,paallowedoperations => contracttypeschema.initsotoperlist());
				ELSE
					sot_core.viewtemplatesinteractive(apitypes.csotcsocontracttype
													 ,paallowedoperations => contracttypeschema.initsotoperlist());
				END IF;
			END IF;
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			IF (smultiselection)
			THEN
				clearmultisel();
				vindex     := 0;
				vmark      := dialog.getchar(pdialog, 'cbList');
				smultimark := vmark;
				FOR i IN 1 .. nvl(length(vmark), 0)
				LOOP
					IF (nvl(ktools.trim(ktools.getchar(vmark, i)), '0') = '1')
					THEN
						ktools.inc(vindex);
						samultisel(vindex) := scontracttyperecarr(i).type;
					END IF;
				END LOOP;
			END IF;
		ELSIF (pwhat = dialog.wtdialogpost)
		THEN
		
			IF dialog.existsitembyname(pdialog, 'SCROLLER')
			THEN
				vrecno := browser.getcurpos(pdialog);
			
				vrecno := least(vrecno, getcount());
				IF (nvl(vrecno, 0) != 0)
				THEN
					sselectedcode := scontracttyperecarr(vrecno).type;
				END IF;
			END IF;
			findpanel_down(pdialog);
		
		END IF;
	
	END dialoglisthandler;

	FUNCTION candeletetype(ptype IN NUMBER) RETURN BOOLEAN IS
		vnum    NUMBER;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		SELECT COUNT(*)
		INTO   vnum
		FROM   tcontract
		WHERE  branch = vbranch
		AND    TYPE = ptype;
		RETURN vnum = 0;
	END candeletetype;

	PROCEDURE fillsecurityarray
	(
		plevel IN NUMBER
	   ,pkey   IN VARCHAR
	) IS
	
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.FillSecurityArray';
		vsubkey      trights.accesskey%TYPE;
		vaschemelist contractschemas.typecontractschemas;
		vtypemaxlen  NUMBER := 0;
	
		FUNCTION getsubkey
		(
			pkey          IN VARCHAR2
		   ,pnestingdepth IN NUMBER
		) RETURN VARCHAR2 IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FillSecurityArray.GetSubKey';
			vpos1 NUMBER;
			vpos2 NUMBER;
		BEGIN
			t.note(cmethod_name, 'start, pKey=' || pkey || ', pNestingDepth=' || pnestingdepth);
			vpos1 := instr(pkey, '|', 1, pnestingdepth);
			t.var('vPos1', vpos1);
			vpos2 := instr(pkey, '|', 1, pnestingdepth + 1);
			t.var('vPos2', vpos2);
			t.note(cmethod_name, 'return ' || substr(pkey, vpos1 + 1, vpos2 - vpos1 - 1));
			RETURN substr(pkey, vpos1 + 1, vpos2 - vpos1 - 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		FUNCTION getrightnamebyscheme
		(
			pschemetype IN tcontractschemas.type%TYPE
		   ,pschemename IN tcontractschemas.name%TYPE
		   ,pmaxlen     IN NUMBER
		) RETURN VARCHAR2 IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name ||
												  '.FillSecurityArray.GetRightNameByScheme';
		BEGIN
			RETURN '[' || lpad(to_char(pschemetype), length(to_char(pmaxlen)), ' ') || '] ' || pschemename;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
	BEGIN
		CASE plevel
			WHEN 1 THEN
				security.stitle := 'List of allowed actions';
			
				security.sarraysize := 4;
				security.stextarray(1) := 'View';
				security.scodearray(1) := right_view;
				security.stextarray(2) := 'Modification';
				security.scodearray(2) := right_modify;
				security.stextarray(3) := 'Change account type in existing contracts';
				security.scodearray(3) := right_change;
				security.stextarray(4) := 'Scheme parameters';
				security.scodearray(4) := right_scheme_parameters;
			WHEN 2 THEN
				security.sarraysize := 0;
				vsubkey             := getsubkey(pkey, 1);
			
				IF vsubkey = to_char(right_scheme_parameters)
				THEN
					security.stitle := 'List of allowed actions';
					SELECT MAX(TYPE) INTO vtypemaxlen FROM tcontractschemas;
					vaschemelist := contractschemas.getschemaarray(contractschemas.csortdefault);
					t.var('vaSchemeList.Count', vaschemelist.count);
					security.sarraysize := vaschemelist.count;
					FOR i IN 1 .. security.sarraysize
					LOOP
						security.stextarray(i) := getrightnamebyscheme(vaschemelist(i).type
																	  ,vaschemelist(i).name
																	  ,vtypemaxlen);
						security.scodearray(i) := vaschemelist(i).type;
						t.note(cmethod_name
							  ,'i=' || i || ', Name=' || vaschemelist(i).name || ', Type=' || vaschemelist(i).type);
					END LOOP;
				END IF;
			
			WHEN 3 THEN
				security.sarraysize := 0;
				vsubkey             := getsubkey(pkey, 1);
			
				IF vsubkey = to_char(right_scheme_parameters)
				THEN
					security.stitle := 'List of transaction parameters';
					vsubkey         := getsubkey(pkey, 2);
					t.var('vSubKey', vsubkey);
					contracttypeschema.fillsecurityarray(contractschemas.getrecord(to_number(vsubkey))
														 .packagename
														,get_scheme_parameters_rights);
				END IF;
			ELSE
				security.sarraysize := 0;
		END CASE;
	END fillsecurityarray;

	PROCEDURE setdatamemberstring
	(
		pcode  IN NUMBER
	   ,pname  IN VARCHAR
	   ,pvalue IN VARCHAR
	) IS
		vret NUMBER;
	BEGIN
		vret := datamember.setchar(object_type, pcode, pname, pvalue, '4 CT_schema');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackage_name || '.SetDataMemberString');
			RAISE;
	END setdatamemberstring;

	FUNCTION getdatamemberstring
	(
		pcode IN NUMBER
	   ,pname IN VARCHAR
	) RETURN VARCHAR IS
		vret VARCHAR(40);
	BEGIN
		vret := datamember.getchar(object_type, pcode, pname);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackage_name || '.GetDataMemberString');
			RETURN NULL;
	END getdatamemberstring;

	PROCEDURE setdatamembernumber
	(
		pcode  IN NUMBER
	   ,pname  IN VARCHAR
	   ,pvalue IN NUMBER
	) IS
		vret NUMBER;
	BEGIN
		vret := datamember.setnumber(object_type, pcode, pname, pvalue, '4 CT_schema');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackage_name || '.SetDataMemberNumber');
			RAISE;
	END setdatamembernumber;

	FUNCTION getdatamembernumber
	(
		pcode IN NUMBER
	   ,pname IN VARCHAR
	) RETURN NUMBER IS
		vret NUMBER;
	BEGIN
		vret := datamember.getnumber(object_type, pcode, pname);
		RETURN nvl(vret, 0);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackage_name || '.GetDataMemberNumber');
			RETURN 0;
	END getdatamembernumber;

	FUNCTION gencontractno(pcontract IN contract.typecontractrow) RETURN tcontract.no%TYPE IS
	BEGIN
		RETURN contractno.gencontractno(pcontract);
	
	END gencontractno;

	FUNCTION getcontracttype4dc(ptype NUMBER) RETURN apitypesfordc.typecontracttyperecord IS
		cmethod_name CONSTANT VARCHAR(250) := cpackage_name || '.GetData4DebtCollection';
		vtyperec apitypesfordc.typecontracttyperecord;
		vpackage VARCHAR(100);
	BEGIN
		vpackage := contracttype.getschemapackage(ptype);
		IF vpackage IS NULL
		THEN
		
			error.raisewhenerr();
		
		END IF;
	
		vtyperec.type  := ptype;
		vtyperec.title := getname(ptype);
		IF vtyperec.title IS NULL
		THEN
			error.raiseerror('No name specified for contract type "' || ptype || '"!');
		END IF;
	
		IF contractschemas.existsmethod(vpackage, 'GetSchemaClass', '/ret:N')
		THEN
			EXECUTE IMMEDIATE 'BEGIN :RET := ' || upper(vpackage) || '.GetSchemaClass;  END;'
				USING OUT vtyperec.class;
		END IF;
	
		RETURN vtyperec;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcontracttype4dc;

	FUNCTION filllist
	(
		pdialog    IN NUMBER
	   ,pitemname  IN VARCHAR
	   ,pcmd       IN NUMBER
	   ,paccessory IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.FillList[4]';
		vfilter typectypefilter;
	BEGIN
		vfilter.accessory := paccessory;
		RETURN filllist(pdialog, pitemname, pcmd, vfilter);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END filllist;

	FUNCTION filllist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.FillList[3]';
	BEGIN
		RETURN filllist(pdialog, pitemname, pcmd, cclient);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END filllist;

	FUNCTION filllist
	(
		pdialog      IN NUMBER
	   ,pitemname    IN VARCHAR
	   ,pcmd         IN NUMBER
	   ,pctypefilter IN typectypefilter
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillList';
		vfilter   typectypefilter;
		vactarray custom_fintypes.typecontracttypelist;
	BEGIN
		setfilter(pdialog, pitemname, pctypefilter);
	
		vfilter              := pctypefilter;
		vfilter.favoriteonly := TRUE;
		dialog.listclear(pdialog, pitemname);
	
		vactarray := getcontracttypearray(vfilter.accessory, NULL, vfilter);
		IF vfilter.enablenull
		THEN
			dialog.listaddrecord(pdialog, pitemname, '~~', pcmd, 0);
		END IF;
		FOR i IN 1 .. vactarray.count
		LOOP
			dialog.listaddrecord(pdialog
								,pitemname
								,vactarray(i).type || '~' || vactarray(i).name
								,pcmd
								,0);
		END LOOP;
	
		RETURN vactarray.count;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END filllist;

	PROCEDURE updateitemfilter
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pfilter   IN typectypefilter
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.UpdateItemFilter';
		vcmd   NUMBER;
		vdummy NUMBER;
	BEGIN
		setfilter(pdialog, pitemname, pfilter);
		vcmd := dialog.getnumber(pdialog, 'cmd_' || pitemname);
	
		vdummy := filllist(pdialog, pitemname, vcmd, pfilter);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE clearselectedctlist IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.ClearSelectedCTList';
	BEGIN
		t.enter(cmethod_name);
		DELETE FROM ttempcontracttype;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setselectedctlist(pctlist IN typeselectedctlist) IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.SetSelectedCTList';
	BEGIN
		t.enter(cmethod_name, 'pCTList.count=' || pctlist.count);
		FORALL i IN 1 .. pctlist.count
			INSERT INTO ttempcontracttype (typecode) VALUES (pctlist(i).typecode);
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setselectedfullctlist IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.SetSelectedFullCTList';
		cbranch      CONSTANT NUMBER := seance.getbranch;
	BEGIN
		t.enter(cmethod_name);
	
		INSERT INTO ttempcontracttype
			(typecode)
			SELECT TYPE FROM tcontracttype WHERE branch = cbranch;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION initarray
	(
		paddnotactive IN BOOLEAN := FALSE
	   ,paccessory    IN NUMBER := NULL
	   ,porderprofile IN contractorderprofiles.typeorderprofilefilter := contractorderprofiles.cemptyorderprofile
	   ,pselectedonly IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.InitArray';
		vfilter typectypefilter;
	BEGIN
		s.say(cmethod_name || ': add not active ' || htools.bool2str(paddnotactive), csay_level);
	
		vfilter.userrights   := NULL;
		vfilter.favoriteonly := FALSE;
		vfilter.activeonly   := NOT paddnotactive;
		vfilter.selectedonly := nvl(pselectedonly, FALSE);
	
		fillctarrays(paccessory, NULL, vfilter, porderprofile);
	
		RETURN scontracttyperecarr.count;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END initarray;

	FUNCTION getarray RETURN custom_fintypes.typecontracttypelist IS
	BEGIN
		RETURN scontracttyperecarr;
	END;

	FUNCTION getarraytype(pno IN NUMBER) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetArrayType';
	BEGIN
		RETURN scontracttyperecarr(pno).type;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getarraytype;

	FUNCTION getarrayname(pno IN NUMBER) RETURN VARCHAR IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetArrayName';
	BEGIN
		RETURN scontracttyperecarr(pno).name;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getarrayname;

	FUNCTION getarrayaccessory(pno IN NUMBER) RETURN VARCHAR IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetArrayAccessory';
	BEGIN
		RETURN scontracttyperecarr(pno).accessory;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getarrayaccessory;

	FUNCTION getarrayschemaname(pno IN NUMBER) RETURN VARCHAR IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetArraySchemaName';
	BEGIN
		RETURN contractschemas.getrecord(scontracttyperecarr(pno).schematype, FALSE).name;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
		
	END getarrayschemaname;

	FUNCTION getrecord
	(
		pcontracttype IN typecontracttype
	   ,pdoexception  IN BOOLEAN := FALSE
	) RETURN tcontracttype%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.GetRecord';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vreturn tcontracttype%ROWTYPE;
	
		FUNCTION int_getrecord
		(
			pbranch       IN tcontracttype.branch%TYPE
		   ,pcontracttype IN typecontracttype
		) RETURN tcontracttype%ROWTYPE result_cache IS
			cmethod_name CONSTANT VARCHAR(60) := getrecord.cmethod_name || '.Int_GetRecord';
			vrow tcontracttype%ROWTYPE;
		BEGIN
			t.enter(cmethod_name, 'pContractType=' || pcontracttype);
		
			SELECT *
			INTO   vrow
			FROM   tcontracttype
			WHERE  branch = pbranch
			AND    TYPE = pcontracttype;
		
			t.leave(cmethod_name);
			RETURN vrow;
		EXCEPTION
			WHEN no_data_found THEN
				s.err(cmethod_name);
				RETURN NULL;
			WHEN OTHERS THEN
				t.exc(cmethod_name);
				error.save(cmethod_name);
				RAISE;
		END;
	
	BEGIN
		t.enter(cmethod_name, 'pContractType=' || pcontracttype);
	
		vreturn := int_getrecord(cbranch, pcontracttype);
		IF vreturn.type IS NULL
		   AND nvl(pdoexception, FALSE)
		THEN
			error.raiseerror('Contract type [' || pcontracttype || '] does not exist');
		END IF;
	
		t.leave(cmethod_name);
		RETURN vreturn;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcontracttyperecord(pcontracttype IN NUMBER) RETURN apitypes.typecontracttyperecord IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.GetContractTypeRecord';
		vrow    tcontracttype%ROWTYPE;
		vreturn apitypes.typecontracttyperecord;
	BEGIN
		IF (pcontracttype > 0)
		THEN
			vrow                := getrecord(pcontracttype);
			vreturn.type        := vrow.type;
			vreturn.name        := vrow.name;
			vreturn.status      := vrow.status;
			vreturn.accessory   := vrow.accessory;
			vreturn.schematype  := vrow.schematype;
			vreturn.description := vrow.description;
		
		END IF;
		RETURN vreturn;
	EXCEPTION
		WHEN no_data_found THEN
			RETURN vreturn;
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcontracttyperecord;

	FUNCTION getschematype
	(
		pcontracttype IN NUMBER
	   ,pdoexception  BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.GetSchemaType';
		vreturn NUMBER := NULL;
	BEGIN
		err.seterror(0, cmethod_name);
		vreturn := getrecord(pcontracttype, pdoexception).schematype;
	
		IF vreturn IS NULL
		THEN
			vreturn := getdatamembernumber(pcontracttype, 'CTSchemaType');
			IF (vreturn = 0)
			THEN
				err.seterror(err.refct_undefined_schema, cmethod_name);
			END IF;
		END IF;
	
		IF nvl(pdoexception, FALSE)
		THEN
			error.raisewhenerr;
		END IF;
	
		RETURN vreturn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getschematype;

	PROCEDURE saveschematype
	(
		pcontracttype IN NUMBER
	   ,pschematype   IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.SaveSchemaType';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		IF pcontracttype > 0
		THEN
			NULL;
		ELSE
			error.raiseerror('Error using parameter pContractType ' || pcontracttype);
		END IF;
	
		IF pschematype > 0
		THEN
			NULL;
		ELSE
			error.raiseerror(err.refct_undefined_schema
							,'Not defined scheme for contract type ' || pcontracttype);
		END IF;
	
		UPDATE tcontracttype
		SET    schematype = pschematype
		WHERE  branch = vbranch
		AND    TYPE = pcontracttype;
	
		setdatamembernumber(pcontracttype, 'CTSchemaType', pschematype);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END saveschematype;

	FUNCTION getname(pctype IN NUMBER) RETURN VARCHAR IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetName';
	BEGIN
		RETURN getrecord(pctype).name;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(err.refct_undefined_schema, cmethod_name);
			RETURN NULL;
	END getname;

	FUNCTION getaccessory(ptype IN NUMBER) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetAccessory';
	BEGIN
		RETURN getrecord(ptype).accessory;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN NULL;
	END getaccessory;

	FUNCTION getschemaname(pctype IN NUMBER) RETURN VARCHAR IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetSchemaName';
		vschtype NUMBER;
	BEGIN
		vschtype := getschematype(pctype);
		IF (vschtype = 0)
		THEN
			err.seterror(err.refct_undefined_schema, cmethod_name);
			RETURN NULL;
		END IF;
		RETURN contractschemas.getrecord(vschtype, FALSE).name;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(err.refct_undefined_schema, cmethod_name);
			RETURN NULL;
	END getschemaname;

	FUNCTION getschemapackage
	(
		pctype       IN typecontracttype
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN tcontractschemas.packagename%TYPE IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetSchemaPackage';
		vschtype   NUMBER;
		vreturn    tcontractschemas.packagename%TYPE;
		verrorcode NUMBER := 0;
	BEGIN
		t.enter(cmethod_name
			   ,'pCType=' || pctype || ', pDoException=' || t.b2t(pdoexception)
			   ,csay_level);
	
		IF pctype IS NULL
		THEN
			verrorcode := err.contract_type_not_init;
		ELSE
			vschtype := getschematype(pctype);
			IF (vschtype = 0)
			THEN
				verrorcode := err.refct_undefined_schema;
			END IF;
		END IF;
	
		IF verrorcode = 0
		THEN
			vreturn := contractschemas.getrecord(vschtype, FALSE).packagename;
		ELSE
			IF nvl(pdoexception, FALSE)
			THEN
				error.raiseerror(verrorcode, 'Contract type [' || pctype || ']');
			ELSE
				err.seterror(verrorcode, cmethod_name);
				vreturn := NULL;
			END IF;
		END IF;
	
		t.leave(cmethod_name
			   ,'vReturn(from row)=' || upper(vreturn) || '(' || vreturn || ')'
			   ,csay_level);
		RETURN upper(vreturn);
	
	EXCEPTION
		WHEN no_data_found THEN
			t.exc(cmethod_name, '[1]', csay_level);
			IF nvl(pdoexception, FALSE)
			THEN
				error.raiseerror(err.refct_undefined_schema, 'Contract type [' || pctype || ']');
			ELSE
				err.seterror(err.refct_undefined_schema, cmethod_name);
				RETURN NULL;
			END IF;
		WHEN OTHERS THEN
			t.exc(cmethod_name, '[2]', csay_level);
			IF nvl(pdoexception, FALSE)
			THEN
				error.save(cmethod_name);
				RAISE;
			ELSE
				err.seterror(SQLCODE, cmethod_name);
				RETURN NULL;
			END IF;
	END getschemapackage;

	FUNCTION getcount RETURN NUMBER IS
	BEGIN
		RETURN scontracttyperecarr.count;
	END getcount;

	FUNCTION gettext(pno IN NUMBER) RETURN VARCHAR IS
	BEGIN
		RETURN scontracttyperecarr(pno).sortorder || '~' || service.iif(scontracttyperecarr(pno)
																		.favorite = '1'
																	   ,'*'
																	   ,' ') || '~' || service.iif(substr(scontracttyperecarr(pno)
																										  .status
																										 ,1
																										 ,1) = '1'
																								  ,'*'
																								  ,' ') || '~' || service.iif(scontracttyperecarr(pno)
																															  .accessory =
																															   cclient
																															 ,'*'
																															 ,' ') || '~' || service.iif(scontracttyperecarr(pno)
																																						 .accessory =
																																						  ccorporate
																																						,'*'
																																						,' ') || '~' || scontracttyperecarr(pno).type || '~' || scontracttyperecarr(pno).name || '~' || scontracttyperecarr(pno).startdate || '~' || scontracttyperecarr(pno).enddate || '~' || scontracttyperecarr(pno).ident || '~';
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END gettext;

	FUNCTION updateobjectuid(pcontracttype IN typecontracttype) RETURN NUMBER IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.UpdateObjectUID';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vobjectuid NUMBER;
	BEGIN
		s.say(cmethod_name || ': pContractType= ' || pcontracttype, csay_level);
		vobjectuid := objectuid.newuid(object_name, pcontracttype, pnocommit => TRUE);
	
		UPDATE tcontracttype
		SET    objectuid = vobjectuid
		WHERE  branch = cbranch
		AND    TYPE = pcontracttype;
		COMMIT;
		s.say(cmethod_name || ': vObjectUID=' || to_char(vobjectuid), csay_level);
		RETURN vobjectuid;
	
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			s.err(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getuid(pcontracttype typecontracttype) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetUID';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vobjectuid NUMBER;
	BEGIN
		SELECT objectuid
		INTO   vobjectuid
		FROM   tcontracttype
		WHERE  branch = cbranch
		AND    TYPE = pcontracttype;
		IF vobjectuid IS NULL
		THEN
		
			vobjectuid := updateobjectuid(pcontracttype);
		
		END IF;
		RETURN vobjectuid;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getuserattributeslist(pcontracttype IN typecontracttype) RETURN apitypes.typeuserproplist IS
		vuserattributeslist apitypes.typeuserproplist;
	BEGIN
		vuserattributeslist := objuserproperty.getrecord(object_name, getuid(pcontracttype));
		RETURN vuserattributeslist;
	END;

	FUNCTION getuserattributerecord
	(
		pcontracttype IN typecontracttype
	   ,pfieldname    IN VARCHAR2
	) RETURN apitypes.typeuserproprecord IS
	BEGIN
		RETURN objuserproperty.getfield(object_name, getuid(pcontracttype), pfieldname);
	END;

	PROCEDURE saveuserattributeslist
	(
		pcontracttype       IN typecontracttype
	   ,plist               apitypes.typeuserproplist
	   ,pclearpropnotinlist BOOLEAN
	) IS
		cmethod_name CONSTANT VARCHAR(80) := cpackage_name || '.SaveUserAttributesList';
		cobjecttype  CONSTANT NUMBER := object.gettype(object_name);
		vobjectuid objectuid.typeobjectuid;
	BEGIN
		vobjectuid := getuid(pcontracttype);
		objuserproperty.saverecord(object_name
								  ,vobjectuid
								  ,plist
								  ,pclearpropnotinlist
								  ,NULL
								  ,cobjecttype
								  ,to_char(pcontracttype));
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setactivecardscount
	(
		pcontracttype     IN typecontracttype
	   ,pactivecardscount IN tcontracttype.activecardscount%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.SetActiveCardsCount';
		vcount  NUMBER;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethod_name
			   ,'ContractType=' || pcontracttype || ', ActiveCardsCount=' || pactivecardscount);
		IF pcontracttype > 0
		THEN
			NULL;
		ELSE
			error.raiseerror('Error using parameter pContractType ' || pcontracttype);
		END IF;
	
		vcount := contractcard.getactivecardscount(pcontracttype);
		s.say('vCount=' || vcount, csay_level);
		IF vcount > pactivecardscount
		THEN
			error.raiseerror('Restriction on number of card products active for issue (' ||
							 pactivecardscount || ') ~ ' ||
							 ' cannot be imposed as current number of card products active for issue (' ||
							 vcount || ') ' || 'exceeds the restriction.');
		END IF;
	
		UPDATE tcontracttype
		SET    activecardscount = pactivecardscount
		WHERE  branch = vbranch
		AND    TYPE = pcontracttype;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getactivecardscount(pcontracttype IN typecontracttype)
		RETURN tcontracttype.activecardscount%TYPE IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.GetActiveCardsCount';
	BEGIN
		RETURN getrecord(pcontracttype).activecardscount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getfinprofile(pcontracttype IN typecontracttype) RETURN tcontracttype.finprofile%TYPE IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.GetFinProfile';
	BEGIN
		RETURN getrecord(pcontracttype).finprofile;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setfinprofile
	(
		pcontracttype IN typecontracttype
	   ,pfinprofile   IN tcontracttype.finprofile%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.SetFinProfile';
	
		vbranch NUMBER := seance.getbranch();
	BEGIN
		s.say('Start ' || cmethod_name || ': pContractType=' || pcontracttype || ', pFinProfile=' ||
			  pfinprofile
			 ,csay_level);
		IF pcontracttype > 0
		THEN
			NULL;
		ELSE
			error.raiseerror('Error using parameter pContractType ' || pcontracttype);
		END IF;
	
		UPDATE tcontracttype
		SET    finprofile = pfinprofile
		WHERE  branch = vbranch
		AND    TYPE = pcontracttype;
		s.say('Finish ' || cmethod_name, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE importcontracttype
	(
		psourcecontracttype IN typecontracttype
	   ,ptargetcontracttype IN typecontracttype
	   ,plog                IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ImportContractType';
		vlogmessage VARCHAR(500);
	BEGIN
		s.say(cmethod_name || ' start, pSourceContractType=' || psourcecontracttype ||
			  ', pTargetContractType=' || ptargetcontracttype || ', pLog=' ||
			  htools.bool2str(plog)
			 ,csay_level);
		IF contracttypeschema.importcontracttype(psourcecontracttype, ptargetcontracttype) != 0
		THEN
		
			error.raisewhenerr();
		
		END IF;
		contracttype.saveschematype(ptargetcontracttype, getschematype(psourcecontracttype));
		contractno.copygenerator(psourcecontracttype, ptargetcontracttype, FALSE);
		contracttype.saveuserattributeslist(ptargetcontracttype
										   ,getuserattributeslist(psourcecontracttype)
										   ,TRUE);
	
		contractbankaccounts.copyobjectsettings(contractparams.ccontracttype
											   ,psourcecontracttype
											   ,ptargetcontracttype);
	
		copyextrauserattributes(psourcecontracttype, ptargetcontracttype, FALSE);
	
		contracttype.setfinprofile(ptargetcontracttype
								  ,contracttype.getfinprofile(psourcecontracttype));
		ctdialog.copy_restrictions(psourcecontracttype, ptargetcontracttype);
		image.object_clonedoctypelist(contract.object_name
									 ,to_char(psourcecontracttype)
									 ,to_char(ptargetcontracttype));
		IF plog
		THEN
			vlogmessage := 'Imported contract type ';
			a4mlog.cleanparamlist();
			a4mlog.addparamrec('SOURCE', psourcecontracttype);
			a4mlog.addparamrec('SOURCENAME', contracttype.getrecord(psourcecontracttype).name);
			IF a4mlog.logobject(object.gettype(contracttype.object_name)
							   ,ptargetcontracttype
							   ,vlogmessage
							   ,a4mlog.act_change
							   ,a4mlog.putparamlist()) != 0
			THEN
				a4mlog.cleanparamlist();
			
				error.raisewhenerr();
			
			END IF;
			a4mlog.cleanparamlist();
		END IF;
		s.say(cmethod_name || ': leave ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION allowedacctypechanging RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AllowedAccTypeChanging';
	BEGIN
		RETURN nvl(contractparams.loadchar(contractparams.getobjecttype(ccontracttypebranch)
										  ,0
										  ,'CHANGEACCTYPE'
										  ,FALSE)
				  ,'0') = '1';
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcurrdlgcontracttyperecord RETURN apitypes.typecontracttyperecord IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCurrDlgContractTypeRecord';
		vcontracttyperow tcontracttype%ROWTYPE;
		vcontracttype    apitypes.typecontracttyperecord;
	BEGIN
		vcontracttyperow          := ctdialog.getcurrdlgcontracttyperecord();
		vcontracttype.type        := vcontracttyperow.type;
		vcontracttype.name        := vcontracttyperow.name;
		vcontracttype.status      := vcontracttyperow.status;
		vcontracttype.accessory   := vcontracttyperow.accessory;
		vcontracttype.schematype  := vcontracttyperow.schematype;
		vcontracttype.description := vcontracttyperow.description;
	
		RETURN vcontracttype;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcurrdlgcontracttyperecord;

	FUNCTION getcurrentdlguserattributes RETURN apitypes.typeuserproplist IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.GetCurrentDlgUserAttributes';
		vuserattributeslist apitypes.typeuserproplist;
	BEGIN
		vuserattributeslist := objuserproperty.getpagedata(ctdialog.getcurrentdialogid, object_name);
		RETURN vuserattributeslist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcurrentdlguserattributes;

	FUNCTION getcontracttypelist
	(
		pschemacode     IN tcontractschemas.type%TYPE := NULL
	   ,psearchtemplate VARCHAR2 := NULL
	   ,paexcludelist   IN tblnumber
	) RETURN apitypes.typecontracttypelist IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.GetContractTypeList';
		vatypes apitypes.typecontracttypelist;
	
		vcount NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'pSchemaCode=' || pschemacode || ', pSearchTemplate="' || psearchtemplate || '"' ||
				', paExcludeList.Count=' || paexcludelist.count
			   ,csay_level);
	
		IF pschemacode IS NOT NULL
		   AND NOT contractschemas.existsscheme(pschemacode)
		THEN
			error.raiseerror('Scheme does not exist [' || pschemacode || ']');
		END IF;
	
		vcount := paexcludelist.count;
	
		SELECT ct.type
			  ,ct.name
			  ,ct.status
			  ,ct.accessory
			  ,ct.schematype
			  ,ct.description
			  ,startdate
			  ,enddate BULK COLLECT
		INTO   vatypes
		FROM   tcontracttype ct
		WHERE  ct.schematype = nvl(pschemacode, ct.schematype)
		AND    (psearchtemplate IS NULL OR upper(NAME) LIKE '%' || upper(psearchtemplate) || '%')
		AND    (vcount = 0 OR ct.type NOT IN (SELECT * FROM TABLE(paexcludelist)))
		ORDER  BY ct.type;
	
		t.leave(cmethod_name, 'count rows return= ' || vatypes.count, csay_level);
		RETURN vatypes;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcontracttypelist;

	FUNCTION activecontracttype
	(
		pcontracttype IN typecontracttype
	   ,poperdate     IN DATE := NULL
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ActiveContractType';
		vret      NUMBER;
		vrow      tcontracttype%ROWTYPE;
		voperdate DATE := nvl(poperdate, seance.getoperdate());
		vbranch   NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethod_name
			   ,'pContractType=' || pcontracttype || ', pOperDate=' || poperdate || ', vOperDate=' ||
				voperdate);
		vrow := getrecord(pcontracttype);
		IF vrow.type IS NULL
		THEN
			error.raiseerror('Dictionary contains no contract type with ID [' || pcontracttype || ']');
		ELSE
			t.note(cmethod_name
				  ,to_char(voperdate, 'DD.MM.YYYY') || '->[' ||
				   nvl(to_char(vrow.startdate, 'DD.MM.YYYY'), '(null)') || '..' ||
				   nvl(to_char(vrow.enddate, 'DD.MM.YYYY'), '(null)') || ']');
			SELECT COUNT(TYPE)
			INTO   vret
			FROM   tcontracttype
			WHERE  branch = vbranch
			AND    TYPE = pcontracttype
			AND    substr(tcontracttype.status, 1, 1) = '1'
			AND    voperdate BETWEEN nvl(startdate, voperdate) AND nvl(enddate, voperdate);
		END IF;
		t.leave(cmethod_name, 'vRet=' || vret);
		RETURN vret > 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcontracttypelistbyoper(poperation IN tcontractschemas.implementedoper%TYPE)
		RETURN apitypes.typecontracttypelist IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.GetContractTypeListByOper';
		vactlist apitypes.typecontracttypelist;
		vindex   NUMBER := 0;
		vbranch  NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethod_name, 'pOperation=' || poperation, csay_level);
		IF poperation IS NULL
		THEN
			error.raiseerror('Define operation code');
		END IF;
		contractschemas.checkimplementedoperations(poperation);
	
		FOR i IN (SELECT t2.*
				  FROM   tcontractschemas t1
				  INNER  JOIN tcontracttype t2
				  ON     t2.schematype = t1.type
				  WHERE  t2.branch = vbranch
				  AND    
						
						 (bitand(t1.implementedoper, poperation) = poperation))
		LOOP
			vindex := vindex + 1;
			vactlist(vindex).type := i.type;
			vactlist(vindex).name := i.name;
			vactlist(vindex).status := i.status;
			vactlist(vindex).accessory := i.accessory;
			vactlist(vindex).schematype := i.schematype;
			vactlist(vindex).description := i.description;
		END LOOP;
	
		t.leave(cmethod_name, 'vaCTList.Count=' || vactlist.count, csay_level);
		RETURN vactlist;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE makelinkedobjectspage
	(
		ppage         NUMBER
	   ,pwidth        NUMBER
	   ,phight        NUMBER
	   ,preadonly     BOOLEAN
	   ,pbuttonwidth  NUMBER
	   ,pstarty       NUMBER
	   ,pcontracttype typecontracttype
	) IS
		cmethod_name    CONSTANT VARCHAR2(65) := cpackage_name || '.MakeLinkedObjectsPage';
		cmethod_handler CONSTANT VARCHAR2(65) := cpackage_name || '.MakeLinkedObjectsPage_Handler';
	
		cdw CONSTANT NUMBER := pwidth;
		cdh CONSTANT NUMBER := phight;
		cbw CONSTANT NUMBER := nvl(pbuttonwidth, 10);
		vi   NUMBER;
		vdlg NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'pReadOnly=[' || t.b2t(preadonly) || '] pContractType=[' || pcontracttype || ']'
			   ,plevel => csay_level);
	
		vdlg := dialog.getdialog(ppage);
	
		IF NOT dialog.existsitembyname(vdlg, cdlg_hv_readonly)
		THEN
			dialog.hiddenbool(ppage, cdlg_hv_readonly, preadonly);
		END IF;
	
		IF NOT dialog.existsitembyname(vdlg, cdlg_hv_contracttype)
		THEN
			dialog.hiddennumber(ppage, cdlg_hv_contracttype, pcontracttype);
		END IF;
	
		dialog.setdialogpre(ppage, cmethod_handler);
		dialog.setdialogvalid(ppage, cmethod_handler);
	
		vi := nvl(pstarty, 1) + 1;
	
		dialog.checkbox(ppage
					   ,cdlg_list_linkedobjects
					   ,2
					   ,vi - 1
					   ,(cdw - 1) - cbw - 3 - 4
					   ,cdh - 2
					   ,phint => 'Linked contract types. Contracts of selected types will be created automatically'
					   ,pcaption => ''
					   ,pusebottompanel => TRUE);
		dialog.listaddfield(ppage, cdlg_list_linkedobjects, 'ID', 'N', 10, 0);
		dialog.listaddfield(ppage, cdlg_list_linkedobjects, 'Scheme', 'C', 20, 1);
		dialog.listaddfield(ppage, cdlg_list_linkedobjects, 'ContractTypeCode', 'N', 5, 1);
		dialog.listaddfield(ppage, cdlg_list_linkedobjects, 'ContractTypeName', 'C', 40, 1);
		dialog.listaddfield(ppage, cdlg_list_linkedobjects, 'LinkParams', 'C', 40, 0);
	
		dialog.listaddfield(ppage, cdlg_list_linkedobjects, 'LinkCode', 'C', 10, 1);
		dialog.listaddfield(ppage, cdlg_list_linkedobjects, 'LinkName', 'C', 15, 1);
	
		dialog.setcaption(ppage
						 ,cdlg_list_linkedobjects
						 ,'Ac~Scheme~Code~Contract type name~Link code~Link name~');
		dialog.setanchor(ppage, cdlg_list_linkedobjects, dialog.anchor_all);
		dialog.setenable(ppage, cdlg_list_linkedobjects, NOT preadonly);
		dialog.setitempre(ppage, cdlg_list_linkedobjects, cmethod_handler);
		dialog.setitemmark(ppage, cdlg_list_linkedobjects, cmethod_handler);
	
		dialog.button(ppage
					 ,cdlg_btn_add
					 ,(cdw - 1) - cbw - 1
					 ,vi
					 ,cbw
					 ,'Add'
					 ,0
					 ,0
					 ,'Add new contract type'
					 ,cmethod_handler);
		ktools.enable(ppage, cdlg_btn_add, NOT preadonly);
		dialog.setanchor(ppage, cdlg_btn_add, dialog.anchor_right + dialog.anchor_top);
	
		vi := vi + 2;
	
		dialog.button(ppage
					 ,cdlg_btn_del
					 ,(cdw - 1) - cbw - 1
					 ,vi
					 ,cbw
					 ,'Delete'
					 ,0
					 ,0
					 ,'Delete contract type'
					 ,cmethod_handler);
		ktools.enable(ppage, cdlg_btn_del, NOT preadonly);
		dialog.setanchor(ppage, cdlg_btn_del, dialog.anchor_right + dialog.anchor_top);
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE saveautocreatepage(pdialog IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SaveAutoCreatePage';
		vcount NUMBER;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		IF dialog.existsitembyname(pdialog, cdlg_list_linkedobjects)
		THEN
			vcount := dialog.getlistreccount(pdialog, cdlg_list_linkedobjects);
			FOR i IN 1 .. vcount
			LOOP
				contractlink.updateautocreatestate(dialog.getrecordchar(pdialog
																	   ,cdlg_list_linkedobjects
																	   ,'ID'
																	   ,i)
												  ,service.iif(dialog.getbool(pdialog
																			 ,cdlg_list_linkedobjects
																			 ,i)
															  ,1
															  ,0));
			END LOOP;
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE refreshlinkedobjectspage(pdialog IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.RefreshLinkedObjectsPage';
		vlinkid tcontracttypelink.linkid%TYPE;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		IF dialog.existsitembyname(pdialog, cdlg_list_linkedobjects)
		THEN
			IF dialog.getlistreccount(pdialog, cdlg_list_linkedobjects) > 0
			THEN
				vlinkid := dialog.getcurrentrecordnumber(pdialog, cdlg_list_linkedobjects, 'ID');
				t.var('vLinkId', vlinkid);
			END IF;
			contracttypelinkautocreate.filltypelist(pdialog
												   ,cdlg_list_linkedobjects
												   ,dialog.getnumber(pdialog, cdlg_hv_contracttype));
			IF vlinkid IS NOT NULL
			THEN
				dialog.setcurrecbyvalue(pdialog, cdlg_list_linkedobjects, 'ID', vlinkid);
			END IF;
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE makelinkedobjectspage_handler
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN CHAR
	   ,pcmd    IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.MakeLinkedObjectsPage_Handler';
		vdlgparams NUMBER;
	
		vlinkid     tcontracttypelink.linkid%TYPE;
		vlink       tcontracttypelink%ROWTYPE;
		vlinkparams contracttypeschema.typelinkparams;
		vturnedon   BOOLEAN;
	
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		IF pwhat = dialog.wtdialogpre
		THEN
			contracttypelinkautocreate.filltypelist(pdialog
												   ,cdlg_list_linkedobjects
												   ,dialog.getnumber(pdialog, cdlg_hv_contracttype));
		
		ELSIF pwhat = dialog.wtitemmark
		THEN
			IF pitem = cdlg_list_linkedobjects
			THEN
				vturnedon := dialog.getbool(pdialog
										   ,cdlg_list_linkedobjects
										   ,dialog.getcurrec(pdialog, cdlg_list_linkedobjects));
				t.var('vTurnedOn', t.b2t(vturnedon));
				IF vturnedon
				THEN
				
					IF NOT
						contractschemas.operationimplemented(upper(dialog.getcurrentrecordchar(pdialog
																							  ,cdlg_list_linkedobjects
																							  ,'Scheme'))
															,contractschemas.c_contract_autocreate)
					THEN
						dialog.putbool(pdialog
									  ,cdlg_list_linkedobjects
									  ,FALSE
									  ,dialog.getcurrec(pdialog, cdlg_list_linkedobjects));
						htools.message('Warning', 'Operation is not supported by scheme');
					END IF;
				END IF;
			
			END IF;
		
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF pitem = cdlg_btn_add
			THEN
				contractschemas.updateschemelistbyoper(contractschemas.c_contract_autocreate);
			
				IF dialog.exec(contracttypelinkautocreate.dlg_contracttypeselect(dialog.getnumber(pdialog
																								 ,cdlg_hv_contracttype)
																				,contractschemas.c_contract_autocreate)) =
				   dialog.cmok
				THEN
					contracttypelinkautocreate.filltypelist(pdialog
														   ,cdlg_list_linkedobjects
														   ,dialog.getnumber(pdialog
																			,cdlg_hv_contracttype)
														   ,dialog.getcurrentrecordnumber(pdialog
																						 ,cdlg_list_linkedobjects
																						 ,'ID'));
				END IF;
			
			ELSIF pitem = cdlg_btn_del
			THEN
				IF htools.askconfirm('Warning'
									,'Delete link to contract type:~[' ||
									 dialog.getcurrentrecordchar(pdialog
																,cdlg_list_linkedobjects
																,'ContractTypeCode') || '-' ||
									 dialog.getcurrentrecordchar(pdialog
																,cdlg_list_linkedobjects
																,'ContractTypeName') || ']?')
				THEN
					vlinkid := dialog.getcurrentrecordnumber(pdialog, cdlg_list_linkedobjects, 'ID');
					contractlink.deletetype2typelink(vlinkid);
					contracttypelinkautocreate.filltypelist(pdialog
														   ,cdlg_list_linkedobjects
														   ,dialog.getnumber(pdialog
																			,cdlg_hv_contracttype)
														   ,dialog.getrecordnumber(pdialog
																				  ,cdlg_list_linkedobjects
																				  ,'ID'
																				  ,greatest(dialog.getcurrec(pdialog
																											,cdlg_list_linkedobjects) - 1
																						   ,0)));
				END IF;
			ELSIF pitem = cdlg_list_linkedobjects
			THEN
			
				IF NOT
					contractschemas.operationimplemented(upper(dialog.getcurrentrecordchar(pdialog
																						  ,cdlg_list_linkedobjects
																						  ,'Scheme'))
														,contractschemas.c_contract_autocreate)
				THEN
					htools.message('Warning', 'Operation is not supported by scheme');
					RETURN;
				END IF;
			
				vlink := contractlink.gettype2typelink(dialog.getcurrentrecordnumber(pdialog
																					,cdlg_list_linkedobjects
																					,'ID'));
				vlinkparams.t2tlinklist(1) := vlink;
			
				vlinkparams.linkedscheme := dialog.getcurrentrecordchar(pdialog
																	   ,cdlg_list_linkedobjects
																	   ,'Scheme');
				vdlgparams               := contracttypeschema.autocreate_paramdialog(contracttypeschema.cautocreate_edit
																					 ,dialog.getnumber(pdialog
																									  ,cdlg_hv_contracttype)
																					 ,vlinkparams.linkedscheme
																					 ,vlinkparams);
			
				IF vdlgparams = dialog.cmok
				THEN
					BEGIN
						IF vlinkparams.t2tlinklist.count > 0
						THEN
							vlink := vlinkparams.t2tlinklist(1);
						END IF;
					
						SAVEPOINT sp_editlink;
					
						contractlink.updatelinkparams(dialog.getcurrentrecordnumber(pdialog
																				   ,cdlg_list_linkedobjects
																				   ,'ID')
													 ,vlink.linkparams);
						COMMIT;
					EXCEPTION
						WHEN OTHERS THEN
							ROLLBACK TO sp_editlink;
							RAISE;
					END;
				ELSE
					dialog.cancelclose(pdialog);
				END IF;
			
			END IF;
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.show(cmethod_name);
			dialog.cancelclose(pdialog);
	END;

	FUNCTION existstype(pcontracttype IN typecontracttype) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExistsType';
		vret BOOLEAN;
	
	BEGIN
		t.enter(cmethod_name, 'pContractType=' || pcontracttype, csay_level);
		IF getrecord(pcontracttype).type IS NOT NULL
		THEN
			vret := TRUE;
		ELSE
			vret := FALSE;
		END IF;
		t.leave(cmethod_name, 'vRet=[' || t.b2t(vret) || ']', plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE checkcontracttype(pcontracttype IN typecontracttype) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CheckContractType';
	BEGIN
		t.enter(cmethod_name, 'pContractType=' || pcontracttype, csay_level);
	
		IF pcontracttype IS NULL
		THEN
			error.raiseerror('Undefined contract type');
		END IF;
	
		IF NOT existstype(pcontracttype)
		THEN
			error.raiseerror('Contract type [' || pcontracttype || '] does not exist');
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getrightkey
	(
		pright        IN VARCHAR2
	   ,pcontracttype IN NUMBER := NULL
	) RETURN VARCHAR2 IS
	BEGIN
		RETURN '|' || pright || '|';
	END;

	FUNCTION active
	(
		pcontracttype IN typecontracttype
	   ,pondate       IN DATE := NULL
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.Active';
		vdate         DATE;
		vret          BOOLEAN;
		vcontracttype tcontracttype%ROWTYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractType=' || pcontracttype || ', pOnDate=' || pondate
			   ,csay_level);
	
		checkcontracttype(pcontracttype);
		vdate := coalesce(pondate, seance.getoperdate());
	
		vcontracttype := getrecord(pcontracttype);
		IF substr(vcontracttype.status, 1, 1) = '1'
		   AND (vcontracttype.startdate IS NULL OR vcontracttype.startdate <= vdate)
		   AND (vcontracttype.enddate IS NULL OR vcontracttype.enddate >= vdate)
		THEN
			vret := TRUE;
		ELSE
			vret := FALSE;
		END IF;
		t.leave(cmethod_name, 'vRet=' || t.b2t(vret), plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

BEGIN
	object_type := object.gettype(object_name);
	saaccessory(cclient) := 'private customers';
	saaccessory(ccorporate) := 'corp. customers';

	fl_browse.useviewoption := TRUE;

	fl_findercn.userrights := contract.right_view;

	fl_createcn.userrights := contract.right_open;
	fl_createcn.activeonly := TRUE;

	lp_showpackage.sizename := 40;

EXCEPTION
	WHEN OTHERS THEN
		s.say(cpackage_name || '.INIT ' || err.getfullmessage());
		error.save(cpackage_name || '.INIT');
		RAISE;
END;
/
