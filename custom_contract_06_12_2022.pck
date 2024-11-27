CREATE OR REPLACE PACKAGE custom_contract AS

	crevision CONSTANT VARCHAR2(100) := '$Rev: 62332 $';

	object_name CONSTANT VARCHAR2(10) := 'CONTRACT';

	right_view CONSTANT NUMBER := 1;
	right_open CONSTANT NUMBER := 2;

	right_modify            CONSTANT NUMBER := 3;
	right_modify_attr       CONSTANT NUMBER := 31;
	right_modify_oper       CONSTANT NUMBER := 32;
	right_change_client     CONSTANT NUMBER := 33;
	right_modify_branchpart CONSTANT NUMBER := 34;
	right_modify_account    CONSTANT NUMBER := 30;

	right_modify_account_add    CONSTANT NUMBER := 301;
	right_modify_account_remove CONSTANT NUMBER := 302;

	right_modify_card            CONSTANT NUMBER := 35;
	right_modify_card_issue_main CONSTANT NUMBER := 351;
	right_modify_card_issue_corp CONSTANT NUMBER := 352;
	right_modify_card_reissue    CONSTANT NUMBER := 353;
	right_modify_card_move       CONSTANT NUMBER := 354;
	right_modify_card_delete     CONSTANT NUMBER := 355;
	right_modify_card_add        CONSTANT NUMBER := 356;

	right_change_type CONSTANT NUMBER := 36;

	right_modify_process  CONSTANT NUMBER := 37;
	right_modify_adjust   CONSTANT NUMBER := 371;
	right_modify_undo_all CONSTANT NUMBER := 372;
	right_modify_undo_own CONSTANT NUMBER := 373;

	right_delete              CONSTANT NUMBER := 4;
	right_view_vip            CONSTANT NUMBER := 5;
	right_vip_all_branchpart  CONSTANT NUMBER := 51;
	right_vip_filial          CONSTANT NUMBER := 52;
	right_vip_own_branchpart  CONSTANT NUMBER := 53;
	right_block               CONSTANT NUMBER := 6;
	right_view_all_branchpart CONSTANT NUMBER := 7;
	right_reference           CONSTANT NUMBER := 8;
	right_reference_view      CONSTANT NUMBER := 81;
	right_reference_modify    CONSTANT NUMBER := 82;
	right_statement           CONSTANT NUMBER := 9;
	right_finprofile          CONSTANT NUMBER := 10;

	right_periodic_statement     CONSTANT NUMBER := 11;
	right_periodic_statement_add CONSTANT NUMBER := 111;
	right_periodic_statement_mod CONSTANT NUMBER := 112;
	right_periodic_statement_del CONSTANT NUMBER := 113;

	right_save_search_result CONSTANT NUMBER := 12;

	stat_ok            CONSTANT NUMBER := 0;
	stat_close         CONSTANT NUMBER := 1;
	stat_violate       CONSTANT NUMBER := 2;
	stat_suspend       CONSTANT NUMBER := 3;
	stat_investigation CONSTANT NUMBER := 4;

	viewmode_default  CONSTANT PLS_INTEGER := 0;
	viewmode_readonly CONSTANT PLS_INTEGER := 1;

	cschemaoperation   CONSTANT NUMBER := 1;
	ctemplateoperation CONSTANT NUMBER := 2;
	copernamesize      CONSTANT NUMBER := 100;

	caccdm_all CONSTANT VARCHAR2(20) := 'AccDM_All';

	caccdm_onlyenabled CONSTANT VARCHAR2(20) := 'AccDM_OnlyEnabled';

	ccomment        CONSTANT VARCHAR2(20) := 'Comment';
	burereadcomment CONSTANT VARCHAR2(20) := 'buRereadComment';

	csortbyaccount CONSTANT VARCHAR2(20) := 'SortByAccount';

	csortlikecontracttype CONSTANT VARCHAR2(20) := 'SortLikeCT';

	cattrtype     CONSTANT VARCHAR2(40) := 'TYPE';
	clogparam_pan CONSTANT VARCHAR2(50) := 'PAN';

	SUBTYPE typeoperationmode IS PLS_INTEGER;
	c_unknownmode     CONSTANT typeoperationmode := -1;
	c_batchmode       CONSTANT typeoperationmode := 1;
	c_interactivemode CONSTANT typeoperationmode := 2;
	c_rollbackmode    CONSTANT typeoperationmode := 3;
	c_omsmode         CONSTANT typeoperationmode := 4;

	cseparator CONSTANT CHAR(3) := '|*|';

	TYPE typenumber IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	TYPE typevarchar10 IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
	TYPE typevarchar20 IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
	TYPE typevarchar30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
	TYPE typevarchar IS TABLE OF VARCHAR2(40) INDEX BY BINARY_INTEGER;
	TYPE typevarchar250 IS TABLE OF VARCHAR2(250) INDEX BY BINARY_INTEGER;

	SUBTYPE typecontractno IS tcontract.no%TYPE;

	semptyrec apitypes.typeuserproplist;

	TYPE typecontractparams IS RECORD(
		 no         tcontract.no%TYPE
		,TYPE       tcontract.type%TYPE
		,idclient   tcontract.idclient%TYPE
		,createdate tcontract.createdate%TYPE
		,branchpart tcontract.branchpart%TYPE
		,objectuid  NUMBER
		,finprofile NUMBER
		,commentary CLOB
		,
		
		userproperty      apitypes.typeuserproplist := semptyrec
		,extrauserproperty apitypes.typeuserproplist := semptyrec
		,
		
		creationmode  PLS_INTEGER
		,operationmode typeoperationmode
		,packno        tisspackets.packetno%TYPE
		,
		
		addexistcard        BOOLEAN
		,addexistacc         BOOLEAN
		,createuserproperty  BOOLEAN := TRUE
		,changecontractno    BOOLEAN := FALSE
		,changecontracttype  BOOLEAN
		,changefinprofile    BOOLEAN
		,changeidclient      BOOLEAN
		,changeacccreatedate BOOLEAN
		,changeaccounttype   BOOLEAN
		,changecardstate     BOOLEAN
		,changecardidclient  BOOLEAN
		,checkidentacctype   BOOLEAN
		,checkidenttieracc   BOOLEAN
		,runcardcontrolblock BOOLEAN := FALSE
		
		);
	SUBTYPE typecontractrow IS typecontractparams;

	TYPE typeaccountrow IS RECORD(
		 accountno      taccount.accountno%TYPE
		,accounttype    taccount.accounttype%TYPE
		,noplan         taccount.noplan%TYPE
		,acct_typ       taccount.acct_typ%TYPE
		,acct_stat      taccount.acct_stat%TYPE
		,itemcode       NUMBER
		,extaccount     VARCHAR2(35)
		,createmode     tcontractaccount.acchow%TYPE
		,refaccounttype tcontracttypeitemname.refaccounttype%TYPE
		,itemname       tcontracttypeitemname.itemname%TYPE
		,description    tcontracttypeitems.description%TYPE
		,accountindex   NUMBER
		,acctypename    taccounttype.name%TYPE
		,currencycode   treferencecurrency.currency%TYPE
		,userproperty   apitypes.typeuserproplist := semptyrec
		,createdate     DATE
		,actualdate     DATE
		,accitemdescr   tcontractitem.itemdescr%TYPE);
	semptyaccount typeaccountrow;
	TYPE typeaccountarray IS TABLE OF typeaccountrow INDEX BY BINARY_INTEGER;

	SUBTYPE typeaddaccountmode IS PLS_INTEGER;
	caamode_createcontract CONSTANT typeaddaccountmode := 1;
	caamode_addtocontract  CONSTANT typeaddaccountmode := 2;

	TYPE typecardparams IS RECORD(
		
		 pan         tcard.pan%TYPE
		,mbr         tcard.mbr%TYPE
		,cardproduct tcard.cardproduct%TYPE
		,insure      tcard.insure%TYPE
		,orderdate   tcard.orderdate%TYPE
		,canceldate  tcard.canceldate%TYPE
		,currencyno  tcard.currencyno%TYPE
		,finprofile  tcard.finprofile%TYPE
		,pinoffset   tcard.pinoffset%TYPE
		,cvv         tcard.cvv%TYPE
		,cvv2        tcard.cvv2%TYPE
		,branchpart  tcard.branchpart%TYPE
		,nameoncard  tcard.nameoncard%TYPE
		,idclient    tcard.idclient%TYPE
		,ecstatus    tcard.ecstatus%TYPE
		,grplimit    tcard.grplimit%TYPE
		,ipvv        tcard.ipvv%TYPE
		,newidclient tcard.idclient%TYPE
		,externalid  tcard.externalid%TYPE
		,parentpan   tcard.pan%TYPE
		,parentmbr   tcard.mbr%TYPE
		,
		
		itemcode   NUMBER
		,cardtype   tcontractcard.cardtype%TYPE
		,createtype tcontractcard.cardhow%TYPE
		,
		
		userproperty apitypes.typeuserproplist := semptyrec
		,
		
		changeidclient        BOOLEAN := FALSE
		,link2existingcontract BOOLEAN := FALSE
		,useonline             BOOLEAN := FALSE);
	TYPE typecardparamsarray IS TABLE OF typecardparams INDEX BY BINARY_INTEGER;

	SUBTYPE typecardrow IS typecardparams;
	SUBTYPE typecardarray IS typecardparamsarray;

	saemptycardlist typecardparamsarray;

	TYPE typecontractitemrecord IS RECORD(
		 contractno   tcontract.no%TYPE
		,contracttype tcontract.type%TYPE
		,itemcode     tcontractitem.itemcode%TYPE
		,itemname     tcontracttypeitemname.itemname%TYPE
		,accountno    taccount.accountno%TYPE
		,accitemdescr tcontractitem.itemdescr%TYPE
		,pan          tcard.pan%TYPE
		,mbr          tcard.mbr%TYPE);
	TYPE typecontractitemlist IS TABLE OF typecontractitemrecord INDEX BY BINARY_INTEGER;

	TYPE typecmsparams IS RECORD(
		 cmsprofile    NUMBER
		,cmsscheme     NUMBER
		,cmschannel    NUMBER
		,cmsaddress    VARCHAR2(100)
		,createcms     BOOLEAN
		,cmsactive     VARCHAR2(1)
		,accountno     VARCHAR2(20)
		,disabled      NUMBER
		,usedynauth    NUMBER
		,usedefdynauth NUMBER
		,branchpart    NUMBER);

	TYPE typeacc2cardrow IS RECORD(
		 carditemcode    NUMBER
		,accountitemcode NUMBER
		,acct_stat       CHAR(1)
		,description     VARCHAR2(250));
	TYPE typeacc2cardarray IS TABLE OF typeacc2cardrow INDEX BY BINARY_INTEGER;

	TYPE typeexistcardrec IS RECORD(
		 pan         VARCHAR2(25)
		,accountno   VARCHAR2(20)
		,description VARCHAR2(250)
		,contractno  VARCHAR2(20)
		,idclient    NUMBER
		,branchpart  NUMBER);
	TYPE typeexistcardarr IS TABLE OF typeexistcardrec INDEX BY BINARY_INTEGER;

	TYPE typeexistaccountrec IS RECORD(
		 accountno VARCHAR2(20)
		,idclient  NUMBER);
	TYPE typeexistaccountarr IS TABLE OF typeexistaccountrec INDEX BY BINARY_INTEGER;

	TYPE typecnsidarr IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

	SUBTYPE typecontractrowdata IS tcontract%ROWTYPE;

	TYPE typeparameter IS RECORD(
		 paramkey  VARCHAR2(50)
		,paramname VARCHAR2(1000));
	TYPE typeparamlist IS TABLE OF typeparameter INDEX BY VARCHAR2(50);

	TYPE typeschemaoperations IS RECORD(
		 operationcode   VARCHAR2(40)
		,operationtype   NUMBER
		,operationname   VARCHAR2(100)
		,ismodifiability NUMBER
		,enabled         NUMBER := 1
		,paramlist       typeparamlist);
	TYPE typeschemaoperationsarray IS TABLE OF typeschemaoperations INDEX BY BINARY_INTEGER;

	TYPE typelogparams IS RECORD(
		 logmessage tobjectlog.remark%TYPE
		,paramlist  a4mlog.typepvlist);

	semptylogparams typelogparams;

	TYPE typeautocreateparams IS RECORD(
		 maincontractno tcontract.no%TYPE
		,LEVEL          PLS_INTEGER := 1);

	SUBTYPE typeoperationtype IS PLS_INTEGER;
	action_contractcreation   CONSTANT typeoperationtype := 1;
	action_clientchange       CONSTANT typeoperationtype := 2;
	action_contracttypechange CONSTANT typeoperationtype := 3;
	action_contractsaving     CONSTANT typeoperationtype := 4;

	action_issueprimarycard       CONSTANT typeoperationtype := 5;
	action_issuesupplementarycard CONSTANT typeoperationtype := 6;
	action_reissuecard            CONSTANT typeoperationtype := 7;
	action_addexistingcard        CONSTANT typeoperationtype := 8;
	action_movecard               CONSTANT typeoperationtype := 9;
	action_deletecard             CONSTANT typeoperationtype := 10;
	action_issuecorporatecard     CONSTANT typeoperationtype := 11;

	TYPE typecontractblockparams IS RECORD(
		 contracttype  tcontract.type%TYPE
		,operationtype PLS_INTEGER
		,operationmode typeoperationmode
		,
		
		opercode   NUMBER
		,operident  VARCHAR2(500)
		,operresult NUMBER);

	sparams      tcontract.rollbackdata%TYPE;
	semptyparams VARCHAR2(2000);

	semptycontractblockparams typecontractblockparams;

	semptyautocreateparams typeautocreateparams;
	soperationarray        typeschemaoperationsarray;
	scontractno            VARCHAR2(20);
	scompany               NUMBER;
	ssocnumber             VARCHAR2(250);
	srollbackdata          tcontract.rollbackdata%TYPE;
	saemptylinkedtypelist  types.arrnum;

	frunprintform BOOLEAN;

	FUNCTION getversion RETURN VARCHAR2;

	PROCEDURE deleteorunlinkaccount
	(
		pcontractno   VARCHAR2
	   ,paccountno    VARCHAR2
	   ,pexistaccount IN typeexistaccountarr
	);
	FUNCTION addcard
	(
		pno         IN tcontract.no%TYPE
	   ,ppan        IN tcard.pan%TYPE
	   ,pmbr        IN tcard.mbr%TYPE
	   ,pcreatemode IN NUMBER := 2
	   ,pitemcode   IN tcontractcarditem.itemcode%TYPE := NULL
	   ,pcardtype   IN tcontractcard.cardtype%TYPE := NULL
	) RETURN NUMBER;

	PROCEDURE addcardbypan
	(
		pno           IN tcontract.no%TYPE
	   ,pcardrow      IN OUT typecardparams
	   ,pcmsparams    IN typecmsparams
	   ,paddexistcard IN BOOLEAN := FALSE
	   ,psaverollback IN BOOLEAN := TRUE
	);

	FUNCTION deletecard
	(
		pno  IN tcontract.no%TYPE
	   ,ppan IN tcard.pan%TYPE
	   ,pmbr IN tcard.mbr%TYPE
	) RETURN NUMBER;

	PROCEDURE deletecardfromcontract
	(
		pno      IN tcontract.no%TYPE
	   ,ppan     IN tcard.pan%TYPE
	   ,pmbr     IN tcard.mbr%TYPE
	   ,pmakelog IN BOOLEAN := FALSE
	);

	PROCEDURE movecard
	(
		ppan          tcard.pan%TYPE
	   ,pmbr          tcard.mbr%TYPE
	   ,pfromcontract tcontract.no%TYPE
	   ,ptocontract   tcontract.no%TYPE
	   ,puseonline    BOOLEAN := FALSE
	);

	PROCEDURE createcontract
	(
		pcontract         IN OUT typecontractparams
	   ,paaccounts        IN typeaccountarray
	   ,pacards           IN typecardparamsarray
	   ,paacc2cardlinks   IN typeacc2cardarray
	   ,pcmsparams        IN typecmsparams := NULL
	   ,pguid             IN types.guid := NULL
	   ,pautocreateparams IN typeautocreateparams := semptyautocreateparams
	   ,palinkedtypelist  IN types.arrnum := saemptylinkedtypelist
	);

	PROCEDURE createcontract
	(
		pcontractrec       IN OUT apitypes.typecontractrecord
	   ,pschparams         IN VARCHAR2 := NULL
	   ,pcontuserdata      IN apitypes.typeuserproplist := semptyrec
	   ,pcontextrauserdata IN apitypes.typeuserproplist := semptyrec
	   ,pautocreateparams  IN typeautocreateparams := semptyautocreateparams
	);

	PROCEDURE deletecontract
	(
		pno           IN tcontract.no%TYPE
	   ,pdeleteclient IN BOOLEAN := FALSE
	   ,pmode         IN PLS_INTEGER := c_rollbackmode
	);

	PROCEDURE dialogcontractproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	);
	PROCEDURE dialogcreateproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	);

	FUNCTION dialogdelete(pno IN VARCHAR2) RETURN NUMBER;
	PROCEDURE dialogdeleteproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	);
	PROCEDURE dialognewcardproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	);
	PROCEDURE dialogremovecardproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	);

	FUNCTION contractexists(pcontract IN VARCHAR2) RETURN BOOLEAN;
	FUNCTION existscontract(pcontracttype IN NUMBER) RETURN BOOLEAN;

	FUNCTION getrightkey
	(
		pright        IN VARCHAR2
	   ,pcontracttype IN NUMBER := NULL
	   ,popercode     IN VARCHAR2 := NULL
	   ,pprop         IN VARCHAR2 := NULL
	) RETURN VARCHAR2;

	FUNCTION checkright
	(
		pright        IN NUMBER
	   ,pcontno       IN tcontract.no%TYPE := NULL
	   ,popercode     IN VARCHAR2 := NULL
	   ,pcontracttype IN tcontracttype.type%TYPE := NULL
	) RETURN BOOLEAN;

	FUNCTION checkoperright
	(
		pright    IN NUMBER
	   ,pcontno   IN VARCHAR2 := NULL
	   ,popercode IN VARCHAR2 := NULL
	   ,pprop     IN VARCHAR2 := NULL
	) RETURN BOOLEAN;
	FUNCTION checkstatus
	(
		pstat IN VARCHAR2
	   ,pflag IN NUMBER
	) RETURN BOOLEAN;

	FUNCTION getarcdate(pcontractno VARCHAR2) RETURN DATE;
	FUNCTION getbranchpart(pcontract IN VARCHAR2) RETURN NUMBER;
	FUNCTION getaccountno
	(
		pno       IN VARCHAR2
	   ,pitemcode IN NUMBER
	) RETURN VARCHAR2;
	FUNCTION getaccountnobyitemname
	(
		pno       IN VARCHAR2
	   ,pitemname IN VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION getaccountlist(pcontractno IN VARCHAR2) RETURN apitypes.typeaccountlist;
	FUNCTION getcardno
	(
		ppan          VARCHAR2
	   ,pmbr          NUMBER
	   ,prigthviewpan BOOLEAN := NULL
	) RETURN VARCHAR2;

	FUNCTION getcardlist
	(
		pcontractno       IN tcontract.no%TYPE
	   ,pstate            IN tcard.signstat%TYPE := NULL
	   ,pstatus           IN tcard.crd_stat%TYPE := NULL
	   ,pclientid4sorting IN tcard.idclient%TYPE := NULL
	) RETURN apitypes.typecardlist;

	FUNCTION getcardlist
	(
		pcontractno       IN tcontract.no%TYPE
	   ,paccountno        IN taccount.accountno%TYPE
	   ,pstate            IN tcard.signstat%TYPE := NULL
	   ,pstatus           IN tcard.crd_stat%TYPE := NULL
	   ,pclientid4sorting IN tcard.idclient%TYPE := NULL
	) RETURN apitypes.typecardlist;

	FUNCTION getcontractrecord(pcontractno IN VARCHAR2) RETURN apitypes.typecontractrecord;
	FUNCTION getcontractrowtype
	(
		pcontractno  IN tcontract.no%TYPE
	   ,pdoexception IN BOOLEAN := TRUE
	) RETURN tcontract%ROWTYPE;

	FUNCTION getcontractnobyaccno
	(
		paccno       IN taccount.accountno%TYPE
	   ,pdoexception IN BOOLEAN := TRUE
	) RETURN tcontract.no%TYPE;
	FUNCTION getcontractnobycard
	(
		ppan         tcard.pan%TYPE
	   ,pmbr         tcard.mbr%TYPE
	   ,pdoexception BOOLEAN := TRUE
	) RETURN tcontract.no%TYPE;

	PROCEDURE getcontractprimarycard
	(
		pcontractno IN tcontract.no%TYPE
	   ,opan        OUT tcard.pan%TYPE
	   ,ombr        OUT tcard.mbr%TYPE
	);
	FUNCTION getcommentary(pcontractno IN VARCHAR2) RETURN CLOB;
	FUNCTION getcurrentdlguserattributes RETURN apitypes.typeuserproplist;
	FUNCTION getcurrdlgextrauserattributes RETURN apitypes.typeuserproplist;
	FUNCTION getcurrentno RETURN VARCHAR2;
	PROCEDURE setcurrentno(pcontractno VARCHAR2);
	FUNCTION getfinprofilebycardproduct
	(
		pcardproduct IN tcard.cardproduct%TYPE
	   ,paccountno   taccount.accountno%TYPE
	   ,pcardtype    IN tcontractcard.cardtype%TYPE := NULL
	) RETURN NUMBER;
	FUNCTION getidclient(pno IN VARCHAR2) RETURN NUMBER;
	FUNCTION getstatus(pno IN VARCHAR2) RETURN VARCHAR2;
	FUNCTION getstatusname(pstatus VARCHAR2) RETURN VARCHAR2;
	FUNCTION getstatusnamebycode(pstatuscode NUMBER) RETURN VARCHAR2;
	FUNCTION gettype
	(
		pno          IN tcontract.no%TYPE
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION getuserattributeslist(pcontractno IN VARCHAR2) RETURN apitypes.typeuserproplist;
	FUNCTION getextrauserattributeslist(pcontractno IN VARCHAR2) RETURN apitypes.typeuserproplist;
	FUNCTION getuserattributerecord
	(
		pcontractno IN VARCHAR2
	   ,pfieldname  VARCHAR2
	) RETURN apitypes.typeuserproprecord;
	FUNCTION getextrauserattributerecord
	(
		pcontractno IN VARCHAR2
	   ,pfieldname  VARCHAR2
	) RETURN apitypes.typeuserproprecord;

	PROCEDURE setarcdate
	(
		pcontractno VARCHAR2
	   ,pdate       DATE
	);
	PROCEDURE setcommentary
	(
		pcontrno IN VARCHAR2
	   ,pcomment VARCHAR2
	   ,plog     IN BOOLEAN := TRUE
	);
	PROCEDURE setcommentary
	(
		pcontrno IN VARCHAR2
	   ,pcomment CLOB
	   ,plog     IN BOOLEAN := TRUE
	);
	PROCEDURE setcreatedate
	(
		pcontrno    IN VARCHAR2
	   ,pcreatedate IN DATE
	);

	FUNCTION setidclient
	(
		pcontrno       IN tcontract.no%TYPE
	   ,pidclient      IN NUMBER
	   ,poperationmode IN typeoperationmode := NULL
	) RETURN NUMBER;

	FUNCTION setstatus
	(
		pno   IN VARCHAR2
	   ,pflag IN NUMBER
	   ,pon   IN BOOLEAN
	   ,plog  IN BOOLEAN := TRUE
	) RETURN NUMBER;
	PROCEDURE setstatus
	(
		pno           IN VARCHAR2
	   ,pflag         IN NUMBER
	   ,pon           IN BOOLEAN
	   ,precnoforundo IN OUT NUMBER
	   ,pundo         BOOLEAN := FALSE
	   ,plog          IN BOOLEAN := TRUE
	);
	FUNCTION logchangestatus
	(
		pno        IN VARCHAR2
	   ,poldstatus IN VARCHAR2
	   ,pnewstatus IN VARCHAR2
	) RETURN NUMBER;
	PROCEDURE undologstatus(precno NUMBER);
	PROCEDURE makestatuscheckbox
	(
		pdialog  IN NUMBER
	   ,pitem    IN VARCHAR2
	   ,px       IN NUMBER
	   ,py       IN NUMBER
	   ,pwidth   NUMBER
	   ,pheigth  NUMBER
	   ,pcaption IN VARCHAR2 := NULL
	   ,phint    IN VARCHAR2 := NULL
	   ,penable  BOOLEAN := FALSE
	);
	PROCEDURE setstatuscheckbox
	(
		pdialog IN NUMBER
	   ,pitem   IN VARCHAR2
	   ,pstatus VARCHAR2
	);
	FUNCTION checkmarkedstatus
	(
		pdialog IN NUMBER
	   ,pitem   IN VARCHAR2
	   ,pstatus NUMBER
	) RETURN BOOLEAN;
	FUNCTION checkmarkedstatus
	(
		pstatusstr VARCHAR2
	   ,pstatus    NUMBER
	) RETURN BOOLEAN;

	PROCEDURE changecontractparameters
	(
		pcontractrow       IN OUT tcontract%ROWTYPE
	   ,pnewcontractparams IN contract.typecontractparams
	   ,pundo              BOOLEAN := FALSE
	);
	PROCEDURE undochangecontractparameters
	(
		pcontractrow IN OUT tcontract%ROWTYPE
	   ,prbdata      IN VARCHAR2
	);

	PROCEDURE createcontractrecord(pocontract IN OUT typecontractrowdata);

	PROCEDURE deletecontractrecord
	(
		pno   IN tcontract.no%TYPE
	   ,pmode IN PLS_INTEGER
	);

	PROCEDURE updatecontractrecord(pcontract IN typecontractrowdata);
	PROCEDURE linkexistaccounttocontract
	(
		paccountrow     IN typeaccountrow
	   ,pcontractrow    IN typecontractparams
	   ,psaverollback   IN BOOLEAN := TRUE
	   ,psavelog        IN BOOLEAN := FALSE
	   ,pchangeidclient IN BOOLEAN := TRUE
	   ,pdoschemacall   IN BOOLEAN := FALSE
	);

	PROCEDURE deleteaccountfromcontract
	(
		pno           IN tcontract.no%TYPE
	   ,paccountno    IN taccount.accountno%TYPE
	   ,psaverollback IN BOOLEAN := FALSE
	   ,pmakelog      IN BOOLEAN := FALSE
	   ,pmove2history IN BOOLEAN := FALSE
	);

	PROCEDURE getcurrentcardno
	(
		opan OUT VARCHAR2
	   ,ombr OUT NUMBER
	);
	PROCEDURE setcurrentcardno
	(
		ppan VARCHAR2
	   ,pmbr NUMBER
	);

	FUNCTION getstatementlist(pcontractno VARCHAR2) RETURN apitypes.typestatementlist;
	PROCEDURE changeobjectmode
	(
		phandle     IN NUMBER
	   ,pnewmod     IN CHAR
	   ,pchangelock IN BOOLEAN := FALSE
	);
	FUNCTION newobject
	(
		pcontractno IN tcontract.no%TYPE
	   ,pmod        IN CHAR
	) RETURN NUMBER;
	PROCEDURE abortfreeobject(phandle IN NUMBER);
	PROCEDURE freeobject(phandle IN NUMBER);

	PROCEDURE writeobject
	(
		phandle      IN NUMBER
	   ,pblockparams IN typecontractblockparams := semptycontractblockparams
	);

	FUNCTION getcurrentdlgcontractrecord RETURN tcontract%ROWTYPE;
	FUNCTION initoperlist
	(
		ptype       IN tcontract.type%TYPE
	   ,pcontractno IN tcontract.no%TYPE := NULL
	   ,pschemetype IN tcontractschemas.type%TYPE := NULL
	) RETURN NUMBER;
	PROCEDURE handler_selecttype
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	);
	PROCEDURE refreshsysdate(pcontractno IN tcontract.no%TYPE);
	PROCEDURE getclientinfo
	(
		pdialog   IN NUMBER
	   ,pidclient IN NUMBER
	);
	PROCEDURE getmaskedfieldslist(ptypesubobj IN VARCHAR2);
	PROCEDURE setlastadjdate
	(
		pcontractno  IN tcontract.no%TYPE
	   ,plastadjdate IN DATE
	);
	FUNCTION getlastadjdate(pcontractno IN tcontract.no%TYPE) RETURN DATE;
	FUNCTION getobject(phandle IN NUMBER) RETURN tcontract%ROWTYPE;

	PROCEDURE changecontracttype
	(
		pcontractno     IN tcontract.no%TYPE
	   ,pcontractparams IN typecontractparams
	   ,pundo           IN BOOLEAN
	   ,pwriterbdata    IN BOOLEAN := TRUE
	);

	PROCEDURE viewcontract
	(
		pcontractno  IN tcontract.no%TYPE
	   ,pinnewthread IN BOOLEAN
	   ,preadonly    IN BOOLEAN := FALSE
	);
	PROCEDURE setbranchpart
	(
		pcontractno IN tcontract.no%TYPE
	   ,pbranchpart NUMBER
	);
	FUNCTION getuid(pcontractno tcontract.no%TYPE) RETURN NUMBER;

	PROCEDURE changecontractidclient
	(
		pcontractno    IN tcontract.no%TYPE
	   ,pidclient      IN NUMBER
	   ,pchangeforcard IN BOOLEAN
	   ,poperationmode IN typeoperationmode := NULL
	);

	PROCEDURE saveuserattributeslist
	(
		pcontractno         IN tcontract.no%TYPE
	   ,plist               IN apitypes.typeuserproplist
	   ,pclearpropnotinlist BOOLEAN := FALSE
	);
	PROCEDURE saveextrauserattributeslist
	(
		pcontractno         IN tcontract.no%TYPE
	   ,plist               IN apitypes.typeuserproplist
	   ,pclearpropnotinlist BOOLEAN := FALSE
	);

	PROCEDURE undolabel
	(
		pcontractno IN tcontract.no%TYPE
	   ,plabel      IN PLS_INTEGER
	   ,pmakelog    IN BOOLEAN := FALSE
	);

	FUNCTION getfinprofile(pcontractno IN tcontract.no%TYPE) RETURN tcontract.finprofile%TYPE;
	PROCEDURE setfinprofile
	(
		pcontractno IN tcontract.no%TYPE
	   ,pfinprofile IN tcontract.finprofile%TYPE
	);
	FUNCTION getmemolist(pcontractno IN tcontract.no%TYPE) RETURN apitypes.typememolist;
	FUNCTION getprymarycardaccount(pcontractno tcontract.no%TYPE) RETURN taccount.accountno%TYPE;
	FUNCTION getdialogcontractno(pcontractno IN tcontract.no%TYPE) RETURN NUMBER;
	PROCEDURE getdialogcontractnoproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	);
	PROCEDURE changecontractno
	(
		poldcontractno IN tcontract.no%TYPE
	   ,pnewcontractno IN tcontract.no%TYPE
	);

	FUNCTION hascardsinstate(pcontractno IN tcontract.no%TYPE) RETURN BOOLEAN;

	PROCEDURE setviewmode(pviewmode IN PLS_INTEGER := viewmode_default);
	PROCEDURE setsubstatus
	(
		pno        IN tcontract.no%TYPE
	   ,psubstatus IN tcontract.substatus%TYPE
	);
	FUNCTION getsubstatus(pcontractno IN tcontract.no%TYPE) RETURN tcontract.substatus%TYPE;
	FUNCTION getguid(pcontractno IN tcontract.no%TYPE) RETURN types.guid;
	FUNCTION getcontractrecordbyuid(pobjectuid objectuid.typeobjectuid)
		RETURN apitypes.typecontractrecord;
	FUNCTION getcontractrecordbyguid(pguid types.guid) RETURN apitypes.typecontractrecord;
	PROCEDURE setstatus
	(
		pcontractno IN tcontract.no%TYPE
	   ,pstatus     IN tcontract.status%TYPE
	   ,plog        IN BOOLEAN := TRUE
	);
	PROCEDURE refreshuserattributes
	(
		pcontractno IN tcontract.no%TYPE
	   ,plist       IN apitypes.typeuserproplist
	);
	PROCEDURE refreshuserattribute
	(
		pcontractno IN tcontract.no%TYPE
	   ,pfieldname  VARCHAR2
	);
	PROCEDURE refreshextrauserattribute
	(
		pcontractno IN tcontract.no%TYPE
	   ,pfieldname  VARCHAR2
	);
	PROCEDURE refreshextrauserattributes
	(
		pcontractno IN tcontract.no%TYPE
	   ,plist       IN apitypes.typeuserproplist
	);
	FUNCTION getcurrentcardproduct RETURN tcard.cardproduct%TYPE;
	FUNCTION getcurrentcard RETURN typecardparams;
	FUNCTION getconvertedrow
	(
		pcontractrow         IN tcontract%ROWTYPE
	   ,paddexistcard        IN BOOLEAN := NULL
	   ,paddexistacc         IN BOOLEAN := NULL
	   ,pchangeacccreatedate IN BOOLEAN := NULL
	   ,pchangecontracttype  IN BOOLEAN := NULL
	   ,pchangeaccounttype   IN BOOLEAN := NULL
	   ,pcheckidentacctype   IN BOOLEAN := NULL
	   ,pcheckidenttieracc   IN BOOLEAN := NULL
	   ,pchangecardstate     IN BOOLEAN := NULL
	   ,pchangefinprofile    IN BOOLEAN := NULL
	   ,pchangeidclient      IN BOOLEAN := NULL
	   ,pchangecardidclient  IN BOOLEAN := NULL
	   ,pcreateuserproperty  IN BOOLEAN := TRUE
	   ,pauserproplist       IN apitypes.typeuserproplist := semptyrec
	) RETURN typecontractparams;

	PROCEDURE addaccounts2contract
	(
		pcontract     IN typecontractparams
	   ,paaccountlist IN typeaccountarray
	   ,psaverollback IN BOOLEAN := TRUE
	   ,psavelog      IN BOOLEAN := FALSE
	   ,pacardlist    IN typecardparamsarray := saemptycardlist
	   ,pmode         IN typeaddaccountmode := caamode_addtocontract
	   ,pschparams    IN VARCHAR2 := semptyparams
	);

	FUNCTION geterraccindex RETURN NUMBER;
	PROCEDURE createaccount
	(
		pcontractno     IN tcontract.no%TYPE
	   ,pitemname       IN tcontracttypeitemname.itemname%TYPE
	   ,pmove2history   IN BOOLEAN := FALSE
	   ,psaverollback   IN BOOLEAN := TRUE
	   ,psavelog        IN BOOLEAN := TRUE
	   ,paccountno      IN taccount.accountno%TYPE := NULL
	   ,prestoreaccount IN BOOLEAN := TRUE
	);

	PROCEDURE setactualdate
	(
		pkey        IN tcontractitem.key%TYPE
	   ,pactualdate IN DATE
	);
	FUNCTION getactualdate(pkey IN tcontractitem.key%TYPE) RETURN DATE;

	PROCEDURE insertaccountitem
	(
		pitemrow   IN OUT tcontractitem%ROWTYPE
	   ,pmakelog   IN BOOLEAN := FALSE
	   ,plogparams IN typelogparams := semptylogparams
	);

	FUNCTION getmodificationbysourceno
	(
		psourceno IN tcontractmodification.sourceno%TYPE
	   ,pkey      IN tcontractmodification.key%TYPE := 0
	) RETURN tcontractmodification%ROWTYPE;
	PROCEDURE uchangecontractno(pmodifid IN tcontractmodification.modifid%TYPE);
	FUNCTION changecontractno
	(
		poldcontractno IN tcontract.no%TYPE
	   ,pnewcontractno IN tcontract.no%TYPE
	   ,pkey           IN tcontractmodification.key%TYPE := 0
	) RETURN tcontractmodification.modifid%TYPE;

	PROCEDURE linkexistingcardtocontract
	(
		pcardrow      IN typecardparams
	   ,pcontractrow  IN typecontractparams
	   ,psaverollback IN BOOLEAN := TRUE
	   ,psavelog      IN BOOLEAN := FALSE
	);
	PROCEDURE getcontractrow
	(
		pcontractno  VARCHAR2
	   ,ocontractrow OUT typecontractparams
	);
	PROCEDURE addnewclientaccounttocontract
	(
		paccountrow   IN typeaccountrow
	   ,pcontract     IN typecontractparams
	   ,psavelog      IN BOOLEAN := FALSE
	   ,psaverollback IN BOOLEAN := FALSE
	   ,pdoschemacall IN BOOLEAN := FALSE
	);

	FUNCTION iscanwatch(pcontno VARCHAR2) RETURN BOOLEAN;
	PROCEDURE revokerights(pcontracttype IN tcontracttype.type%TYPE);

	FUNCTION loadaccount
	(
		paccountno   IN taccount.accountno%TYPE
	   ,pdoexception IN BOOLEAN := TRUE
	) RETURN typeaccountrow;
	FUNCTION getaccountdescription
	(
		paccountno   IN taccount.accountno%TYPE
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN tcontractitem.itemdescr%TYPE;

	PROCEDURE checkcontractno(pcontractno IN tcontract.no%TYPE);
	FUNCTION existscontractbyitemname
	(
		pcontracttype IN tcontracttype.type%TYPE
	   ,pitemname     IN tcontracttypeitemname.itemname%TYPE
	) RETURN BOOLEAN;

	FUNCTION getcontractbyaccount
	(
		paccountno   IN taccount.accountno%TYPE
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN typecontractitemrecord;
	FUNCTION getcontractbycard
	(
		ppan         IN tcard.pan%TYPE
	   ,pmbr         IN tcard.mbr%TYPE
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN typecontractitemrecord;

	FUNCTION getcontractlistbycard
	(
		ppan IN tcard.pan%TYPE
	   ,pmbr IN tcard.mbr%TYPE := NULL
	) RETURN typecontractitemlist;

	FUNCTION getaccountitemlist(pcontractno IN tcontract.no%TYPE) RETURN typecontractitemlist;
	FUNCTION getcarditemlist(pcontractno IN tcontract.no%TYPE) RETURN typecontractitemlist;

	PROCEDURE createcardaccountlinks
	(
		pcontractno   IN tcontract.no%TYPE
	   ,ppan          IN tcard.pan%TYPE
	   ,pmbr          IN tcard.mbr%TYPE
	   ,psaverollback IN BOOLEAN := FALSE
	   ,puseonline    IN BOOLEAN := FALSE
	);

	FUNCTION getobjectmode(phandle IN NUMBER) RETURN CHAR;

	FUNCTION getlaststatuschange
	(
		pcontractno IN tcontract.no%TYPE
	   ,pstatid     IN NUMBER
	   ,pdate       IN DATE := NULL
	) RETURN tcontractstatushistory%ROWTYPE;

	FUNCTION getstatusid(pstat IN tcontract.status%TYPE) RETURN PLS_INTEGER;

	PROCEDURE setactiveaccitem
	(
		pdialog      IN NUMBER
	   ,paccitemname IN tcontracttypeitemname.itemname%TYPE
	);

	FUNCTION getclientid(pcontractno IN tcontract.no%TYPE) RETURN tcontract.idclient%TYPE;

	FUNCTION getcurrentuserproplist RETURN apitypes.typeuserproplist;
	FUNCTION getcurrentextrauserproplist RETURN apitypes.typeuserproplist;
	PROCEDURE setcurrentuserproplist(puserproplist IN apitypes.typeuserproplist);
	PROCEDURE setcurrentextrauserproplist(puserproplist IN apitypes.typeuserproplist);
	FUNCTION getcurrent RETURN apitypes.typecontractrecord;

	FUNCTION getoperationtypedescription(poperationtype typeoperationtype) RETURN VARCHAR2;
	FUNCTION mergeschemaandsotoperations
	(
		paschemaoperations IN typeschemaoperationsarray
	   ,patemplatesonct    IN apitypes.typesotemplatearray
	) RETURN typeschemaoperationsarray;
	/*  FUNCTION getoperationsbyscheme
    (
        ppackage     IN fintypes.typepackagename
       ,pdoexception BOOLEAN := TRUE
    ) RETURN contract.typeschemaoperationsarray;*/

	FUNCTION getdynasqllocator RETURN VARCHAR2;
	FUNCTION describescript(plocator VARCHAR2) RETURN VARCHAR2;

	/*  FUNCTION getsecurityarray
    (
        plevel          IN NUMBER
       ,pkey            IN VARCHAR2
       ,pnodenumber     NUMBER := NULL
       ,psearchtemplate VARCHAR2 := NULL
    ) RETURN custom_security.typerights;*/
	PROCEDURE closesecuritycursor
	(
		plevel IN NUMBER
	   ,pkey   IN VARCHAR2
	);
	PROCEDURE closesecuritycursors;

END;
/
CREATE OR REPLACE PACKAGE BODY custom_contract AS

	cpackage_name CONSTANT VARCHAR2(40) := 'Contract';
	cbodyrevision CONSTANT VARCHAR2(100) := '$Rev: 63137 $';
	csay_level    CONSTANT NUMBER := 4;

	caccdm_set CONSTANT VARCHAR2(20) := 'AccDM_Set';
	saccountdisplaymode VARCHAR2(20);

	caccsm_set CONSTANT VARCHAR2(20) := 'AccSM_Set';
	saccountsortmode VARCHAR2(20);

	cdate_format CONSTANT VARCHAR2(20) := 'DD/MM/YYYY';

	cexist_card CONSTANT VARCHAR2(20) := 'EXIST_CARD';

	cexist_acc CONSTANT VARCHAR2(20) := 'EXIST_ACC';

	ccns_id CONSTANT VARCHAR2(20) := 'CNS_ID';

	ccreate_date CONSTANT VARCHAR2(20) := 'CON_CREATE_DATE';
	cchange_type CONSTANT VARCHAR2(20) := 'CON_CHANGE_TYPE';

	crl_change_contract_type CONSTANT contractrb.tlabel := contractrb.crs_contract + 1;
	crl_change_card_state    CONSTANT contractrb.tlabel := contractrb.crs_contract + 2;
	crl_change_finprofile    CONSTANT contractrb.tlabel := contractrb.crs_contract + 3;
	crl_change_createdate    CONSTANT contractrb.tlabel := contractrb.crs_contract + 4;
	crl_change_idclient      CONSTANT contractrb.tlabel := contractrb.crs_contract + 5;
	crl_link_existacc        CONSTANT contractrb.tlabel := contractrb.crs_contract + 6;
	crl_link_existcard       CONSTANT contractrb.tlabel := contractrb.crs_contract + 7;
	crl_create_cns           CONSTANT contractrb.tlabel := contractrb.crs_contract + 8;
	crl_create_newcard       CONSTANT contractrb.tlabel := contractrb.crs_contract + 9;
	crl_link_linkedcard      CONSTANT contractrb.tlabel := contractrb.crs_contract + 10;
	crl_move_acc2history     CONSTANT contractrb.tlabel := contractrb.crs_contract + 11;
	crl_create_newaccount    CONSTANT contractrb.tlabel := contractrb.crs_contract + 12;
	crl_unlink_existacc      CONSTANT contractrb.tlabel := contractrb.crs_contract + 13;
	crl_create_contract      CONSTANT contractrb.tlabel := contractrb.crs_contract + 14;
	crl_create_cardlink      CONSTANT contractrb.tlabel := contractrb.crs_contract + 15;
	crl_move_cardlink        CONSTANT contractrb.tlabel := contractrb.crs_contract + 16;
	crl_change_contract_no   CONSTANT contractrb.tlabel := contractrb.crs_contract + 17;

	ckey_contract_no        CONSTANT CHAR(2) := 'CN';
	ckey_contract_type      CONSTANT CHAR(2) := 'TY';
	ckey_card_state         CONSTANT CHAR(2) := 'CS';
	ckey_change_acctype     CONSTANT CHAR(2) := 'CA';
	ckey_checkident_acctier CONSTANT CHAR(2) := 'IP';
	ckey_checkident_acctype CONSTANT CHAR(2) := 'IT';
	ckey_change_finprofile  CONSTANT CHAR(2) := 'FP';
	ckey_createdate         CONSTANT CHAR(2) := 'CD';
	ckey_change_accdate     CONSTANT CHAR(2) := 'AD';
	ckey_idclient           CONSTANT CHAR(2) := 'IC';
	ckey_change_cardsclient CONSTANT CHAR(2) := 'CC';
	ckey_pan                CONSTANT CHAR(2) := 'PA';
	ckey_mbr                CONSTANT CHAR(2) := 'MB';
	ckey_carddescr          CONSTANT CHAR(2) := 'DE';
	ckey_accountno          CONSTANT CHAR(2) := 'AN';
	ckey_cono               CONSTANT CHAR(2) := 'CO';
	ckey_branchpart         CONSTANT CHAR(2) := 'BP';
	ckey_cnsid              CONSTANT CHAR(2) := 'NS';
	ckey_itemcode           CONSTANT CHAR(2) := 'IK';
	ckey_a2c_no             CONSTANT CHAR(2) := 'LA';
	ckey_a2c_stat           CONSTANT CHAR(2) := 'LS';
	ckey_a2c_descr          CONSTANT CHAR(2) := 'LD';
	ckey_a2c_limitgrp       CONSTANT CHAR(2) := 'LG';
	ckey_actualdate         CONSTANT CHAR(2) := 'DA';
	ckey_linkedcontract     CONSTANT CHAR(2) := 'CL';
	ckey_a2c_action         CONSTANT CHAR(2) := 'AC';
	ckey_modif_id           CONSTANT CHAR(2) := 'MI';

	c_a2c_create CONSTANT PLS_INTEGER := 1;
	c_a2c_delete CONSTANT PLS_INTEGER := 2;
	c_a2c_update CONSTANT PLS_INTEGER := 3;

	scontdlg  NUMBER;
	sreadonly BOOLEAN := FALSE;
	sviewmode PLS_INTEGER := viewmode_default;

	caction_renew   CONSTANT PLS_INTEGER := 1;
	caction_reread  CONSTANT PLS_INTEGER := 2;
	caction_restore CONSTANT PLS_INTEGER := 3;

	clogparam_mbr          CONSTANT VARCHAR2(50) := 'MBR';
	clogparam_contractno   CONSTANT VARCHAR2(50) := 'CONTRACTNO';
	clogparam_branchpart   CONSTANT VARCHAR2(50) := 'BRANCHPART';
	clogparam_createdate   CONSTANT VARCHAR2(50) := 'CREATEDATE';
	clogparam_idclient     CONSTANT VARCHAR2(50) := 'IDCLIENT';
	clogparam_status       CONSTANT VARCHAR2(50) := 'STATUS';
	clogparam_contracttype CONSTANT VARCHAR2(50) := 'CONTRACTTYPE';
	clogparam_finprofile   CONSTANT VARCHAR2(50) := 'FINPROFILE';
	clogparam_accno        CONSTANT VARCHAR2(50) := 'ACCOUNTNO';
	clogparam_itemcode     CONSTANT VARCHAR2(50) := 'ITEMCODE';
	clogparam_itemname     CONSTANT VARCHAR2(50) := 'ITEMNAME';
	clogparam_accitemdescr CONSTANT VARCHAR2(50) := 'ItemDescr';

	cmodiffilter_bysourceno CONSTANT VARCHAR2(50) := 'BYSOURCENO';
	cmodiffilter_bytargetno CONSTANT VARCHAR2(50) := 'BYTARGETNO';
	cmodiffilter_byid       CONSTANT VARCHAR2(50) := 'BYID';

	ccreation_batchmode       CONSTANT PLS_INTEGER := 1;
	ccreation_interactivemode CONSTANT PLS_INTEGER := 2;

	cdlg_list_linkedobjects CONSTANT VARCHAR2(30) := upper('LinkedTypeList');

	cadjustingitem CONSTANT VARCHAR2(20) := upper('AdjustingItem');
	cundoitem      CONSTANT VARCHAR2(20) := upper('UndoItem');

	scontracttype_object NUMBER;
	serraccindex         NUMBER;
	sastatusname         typevarchar30;
	span                 tcard.pan%TYPE;
	smbr                 tcard.mbr%TYPE;
	saccessory           NUMBER;
	scurrentcard         typecardparams;

	TYPE typecontractrec IS RECORD(
		 contractrow tcontract%ROWTYPE
		,
		
		userproperty      apitypes.typeuserproplist := semptyrec
		,extrauserproperty apitypes.typeuserproplist := semptyrec
		,
		
		contractmode CHAR(1)
		,contractlock BOOLEAN
		,guid         types.guid);
	TYPE typecontractarray IS TABLE OF typecontractrec INDEX BY BINARY_INTEGER;
	scontractarray typecontractarray;

	scurrentuserproplist      apitypes.typeuserproplist;
	scurrentextrauserproplist apitypes.typeuserproplist;
	scurrentrecord            apitypes.typecontractrecord;

	scurrenthandle NUMBER;

	TYPE typecontracttypeitems IS TABLE OF tcontracttypeitemname%ROWTYPE INDEX BY tcontracttypeitemname.itemname%TYPE;

	TYPE typenewcardlist IS TABLE OF card.typefullcardinfolist INDEX BY BINARY_INTEGER;
	sanewcardlist typenewcardlist;

	TYPE typeinitparameters IS RECORD(
		 contracttype  tcontracttype.type%TYPE
		,contractno    contract.typecontractno
		,schemetype    tcontractschemas.type%TYPE
		,schemepackage contractschemas.typeschemapackagename);

	TYPE typeschemeoperationlist IS TABLE OF typeschemaoperationsarray INDEX BY contractschemas.typeschemapackagename;
	saschemeoperationlist typeschemeoperationlist;

	method_not_found EXCEPTION;
	PRAGMA EXCEPTION_INIT(method_not_found, -06550);

	TYPE typeblockupdatevaluesparams IS RECORD(
		 ischangeduserattrlist      BOOLEAN
		,ischangedextrauserattrlist BOOLEAN);

	sblockupdatevalueparams typeblockupdatevaluesparams;

	FUNCTION getnewupdaterevision RETURN NUMBER;
	PROCEDURE setarcdatebyhandle
	(
		phandle IN NUMBER
	   ,pdate   DATE
	);
	PROCEDURE setbranchpartbyhandle
	(
		phandle     IN NUMBER
	   ,pbranchpart NUMBER
	);

	PROCEDURE execcontrolblock_contractoper
	(
		poperationtype typeoperationtype
	   ,pno            typecontractno
	);

	PROCEDURE clearcurrentno;

	FUNCTION getversion RETURN VARCHAR2 IS
	BEGIN
		RETURN service.formatpackageversion(cpackage_name, crevision, cbodyrevision);
	END;

	PROCEDURE resetblockupdatevaluesparams IS
		cmethodname CONSTANT VARCHAR2(100) := cpackage_name || '.ResetBlockUpdateValuesParams';
	BEGIN
		t.enter(cmethodname);
		sblockupdatevalueparams.ischangeduserattrlist      := FALSE;
		sblockupdatevalueparams.ischangedextrauserattrlist := FALSE;
		t.leave(cmethodname);
	END;

	PROCEDURE setischangeduserattrlist IS
		cmethodname CONSTANT VARCHAR2(100) := cpackage_name || '.SetIsChangedUserAttrList';
	BEGIN
		t.enter(cmethodname);
		sblockupdatevalueparams.ischangeduserattrlist := TRUE;
		t.leave(cmethodname);
	END;

	PROCEDURE setischangedextrauserattrlist IS
		cmethodname CONSTANT VARCHAR2(100) := cpackage_name || '.SetIsChangedExtraUserAttrList';
	BEGIN
		t.enter(cmethodname);
		sblockupdatevalueparams.ischangedextrauserattrlist := TRUE;
		t.leave(cmethodname);
	END;

	FUNCTION ischangeduserattrlist RETURN BOOLEAN IS
		cmethodname CONSTANT VARCHAR2(100) := cpackage_name || '.IsChangedUserAttrList';
	BEGIN
		t.leave(cmethodname
			   ,'return ' || htools.b2s(sblockupdatevalueparams.ischangeduserattrlist));
		RETURN sblockupdatevalueparams.ischangeduserattrlist;
	END;

	FUNCTION ischangedextrauserattrlist RETURN BOOLEAN IS
		cmethodname CONSTANT VARCHAR2(100) := cpackage_name || '.IsChangedExtraUserAttrList';
	BEGIN
		t.leave(cmethodname
			   ,'return ' || htools.b2s(sblockupdatevalueparams.ischangedextrauserattrlist));
		RETURN sblockupdatevalueparams.ischangedextrauserattrlist;
	END;

	FUNCTION getnewcardcollection RETURN typenewcardlist IS
	BEGIN
		RETURN sanewcardlist;
	END;

	PROCEDURE setnewcardcollection(panewcardlist IN typenewcardlist) IS
	BEGIN
		sanewcardlist := panewcardlist;
	END;

	PROCEDURE setnewcardlist
	(
		pindex       IN tcontractcard.code%TYPE
	   ,pnewcardlist IN card.typefullcardinfolist
	) IS
	BEGIN
		IF pindex IS NOT NULL
		THEN
			sanewcardlist(pindex) := pnewcardlist;
		END IF;
	END;

	PROCEDURE deletenewcardlist(pindex IN VARCHAR2) IS
	BEGIN
		IF sanewcardlist.exists(pindex)
		THEN
			sanewcardlist.delete(pindex);
		END IF;
	END;

	FUNCTION existnewcardlist(pindex IN tcontractcard.code%TYPE) RETURN BOOLEAN IS
	BEGIN
		IF sanewcardlist.exists(pindex)
		THEN
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;
	END;

	FUNCTION getnewcardlist(pindex IN tcontractcard.code%TYPE) RETURN card.typefullcardinfolist IS
		vcardlist card.typefullcardinfolist;
	BEGIN
		IF sanewcardlist.exists(pindex)
		THEN
			vcardlist := sanewcardlist(pindex);
		END IF;
		RETURN vcardlist;
	
	END;

	PROCEDURE clearnewcardlist IS
	BEGIN
		sanewcardlist.delete();
	END;

	FUNCTION capturedobjectinfo(pcontractno IN tcontract.no%TYPE) RETURN VARCHAR2 IS
	BEGIN
		RETURN object.capturedobjectinfo(object_name, pcontractno);
	END;

	FUNCTION getcurrentcardproduct RETURN tcard.cardproduct%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCurrentCardProduct';
	BEGIN
		s.say(cmethod_name || ' start, CardProduct=' || scurrentcard.cardproduct, csay_level);
		RETURN scurrentcard.cardproduct;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcurrentcard RETURN typecardparams IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCurrentCard';
	BEGIN
		s.say(cmethod_name || ' start' || scurrentcard.cardproduct, csay_level);
		RETURN scurrentcard;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setcurrentcardproduct(pcardproduct IN tcard.cardproduct%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCurrentCardProduct';
	BEGIN
		s.say(cmethod_name || ' start, CardProduct=' || pcardproduct, csay_level);
		scurrentcard.cardproduct := pcardproduct;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setcurrentcard(pcard IN typecardparams) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCurrentCard';
	BEGIN
		s.say(cmethod_name || ' start', csay_level);
		scurrentcard := pcard;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setcurrentemptycard IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCurrentEmptyCard';
		vcard typecardparams;
	BEGIN
		s.say(cmethod_name || ' start', csay_level);
		setcurrentcard(vcard);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE parserollbackdata
	(
		prollbackdata    IN VARCHAR2
	   ,oexistcardarr    OUT typeexistcardarr
	   ,oexistaccountarr OUT typeexistaccountarr
	   ,ocnsidarr        OUT typecnsidarr
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ParseRollbackData';
		varrparams uamp.tarrrecord;
		vaarg      contracttools.typevarchar50;
		vcardcount NUMBER := 0;
		vacccount  NUMBER := 0;
		vcnscount  NUMBER := 0;
		vret       NUMBER;
	BEGIN
	
		IF prollbackdata IS NOT NULL
		THEN
			varrparams := uamp.parsestring(srollbackdata, ';');
			FOR i IN 1 .. varrparams.count
			LOOP
				CASE upper(varrparams(i).name)
					WHEN cexist_card THEN
						vret := contracttools.getargforundo(varrparams(i).value, vaarg);
						s.say(cmethod_name || ': arg count ' || vret, csay_level);
						IF vret NOT IN (5, 6)
						THEN
							error.raiseerror('Invalid data for undo!');
						END IF;
					
						vcardcount := vcardcount + 1;
						oexistcardarr(vcardcount).pan := vaarg(1);
						oexistcardarr(vcardcount).accountno := vaarg(2);
						oexistcardarr(vcardcount).description := vaarg(3);
						oexistcardarr(vcardcount).contractno := vaarg(4);
						oexistcardarr(vcardcount).idclient := vaarg(5);
						IF vaarg.exists(6)
						THEN
							oexistcardarr(vcardcount).branchpart := vaarg(6);
						ELSE
							oexistcardarr(vcardcount).branchpart := NULL;
						END IF;
						s.say(cmethod_name || ': card exists before PAN ' ||
							  card.getmaskedpan(oexistcardarr(vcardcount).pan) || ', ACC ' || oexistcardarr(vcardcount)
							  .accountno || ' DESC ' || oexistcardarr(vcardcount).description ||
							  ' CONT ' || oexistcardarr(vcardcount).contractno || ' IDCL ' || oexistcardarr(vcardcount)
							  .idclient || ' BRPT ' || oexistcardarr(vcardcount).branchpart
							 ,csay_level);
					
					WHEN cexist_acc THEN
						vret := contracttools.getargforundo(varrparams(i).value, vaarg);
						s.say(cmethod_name || ': arg count ' || vret, csay_level);
						IF vret != 2
						THEN
							error.raiseerror('Invalid data for undo!');
						END IF;
					
						vacccount := vacccount + 1;
						oexistaccountarr(vacccount).accountno := vaarg(1);
						oexistaccountarr(vacccount).idclient := vaarg(2);
						s.say(cmethod_name || ': account exists before: ACC ' || oexistaccountarr(vacccount)
							  .accountno || ' IDCL ' || oexistaccountarr(vacccount).idclient
							 ,csay_level);
					WHEN ccns_id THEN
						s.say(cmethod_name || ': card CNS ' || varrparams(i).value, csay_level);
						vcnscount := vcnscount + 1;
						ocnsidarr(vcnscount) := varrparams(i).value;
					ELSE
						NULL;
				END CASE;
			END LOOP;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END parserollbackdata;

	PROCEDURE changeaccountidclient
	(
		paccountno VARCHAR2
	   ,pidclient  NUMBER
	   ,psavelog   IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeAccountIdClient';
		vaccounthandle NUMBER;
	BEGIN
		vaccounthandle := account.newobject(paccountno, 'W');
		IF vaccounthandle = 0
		THEN
			error.raiseerror('Account ' || paccountno || ' is blocked for write access!');
		END IF;
		account.changeowner(vaccounthandle, pidclient, psavelog);
		err.seterror(0, cmethod_name);
		account.writeobject(vaccounthandle);
		error.raisewhenerr();
		account.freeobject(vaccounthandle);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			s.say(cmethod_name || ': general exception, ' || SQLERRM, csay_level);
			IF vaccounthandle != 0
			THEN
				account.freeobject(vaccounthandle);
			END IF;
			RAISE;
	END changeaccountidclient;

	PROCEDURE changecardidclient
	(
		ppan      IN VARCHAR2
	   ,pmbr      IN NUMBER
	   ,pidclient IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeCardIDClient';
		vcardhandle NUMBER := 0;
	BEGIN
		s.say(cmethod_name || ': to ' || pidclient, csay_level);
		vcardhandle := card.newobject(ppan, pmbr, 'W');
		IF vcardhandle != 0
		THEN
			card.setidclient(vcardhandle, pidclient);
			card.writeobject(vcardhandle);
			card.freeobject(vcardhandle);
		ELSE
			error.raiseerror('Card ' || getcardno(ppan, pmbr) || ' is blocked for write access');
		END IF;
		s.say(cmethod_name || ': ok', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			s.say(cmethod_name || ': general exception, ' || SQLERRM, csay_level);
			IF vcardhandle != 0
			THEN
				card.freeobject(vcardhandle);
			END IF;
			RAISE;
	END changecardidclient;

	PROCEDURE changecardbranchpart
	(
		ppan        IN VARCHAR2
	   ,pmbr        IN NUMBER
	   ,pbranchpart IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeCardBranchPart';
		vcardhandle NUMBER := 0;
	BEGIN
		s.say(cmethod_name || ': to ' || pbranchpart, csay_level);
		vcardhandle := card.newobject(ppan, pmbr, 'W');
		IF vcardhandle != 0
		THEN
			card.cardbranchpart(vcardhandle) := pbranchpart;
			card.writeobject(vcardhandle);
			card.freeobject(vcardhandle);
		ELSE
			error.raiseerror('Card ' || getcardno(ppan, pmbr) || ' is blocked for write access');
		END IF;
		s.say(cmethod_name || ': ok', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			s.say(cmethod_name || ': general exception, ' || SQLERRM, csay_level);
			IF vcardhandle != 0
			THEN
				card.freeobject(vcardhandle);
			END IF;
			RAISE;
	END changecardbranchpart;

	PROCEDURE changecontractidclient
	(
		pcontractno    IN tcontract.no%TYPE
	   ,pidclient      IN NUMBER
	   ,pchangeforcard IN BOOLEAN
	   ,poperationmode IN typeoperationmode := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeContractIdClient';
		vcontractitemlist typecontractitemlist;
		vclientid         tcontract.idclient%TYPE;
		vbranch           NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethod_name
			   ,'pIdClient=' || pidclient || ', pCnageForCard=' || t.b2t(pchangeforcard) ||
				',pOperationMode=' || poperationmode);
		IF pidclient IS NULL
		THEN
			error.raiseerror('Customer ID not defined!');
		END IF;
	
		vcontractitemlist := getaccountitemlist(pcontractno);
		FOR i IN 1 .. vcontractitemlist.count
		LOOP
			s.say(cmethod_name || ', vAccountNo=' || vcontractitemlist(i).accountno, csay_level);
			changeaccountidclient(vcontractitemlist(i).accountno, pidclient);
		END LOOP;
	
		IF pchangeforcard
		THEN
			vcontractitemlist := getcarditemlist(pcontractno);
			vclientid         := getidclient(pcontractno);
			FOR i IN 1 .. vcontractitemlist.count
			LOOP
				IF card.getcardrecord(vcontractitemlist(i).pan, vcontractitemlist(i).mbr)
				 .idclient = vclientid
				THEN
					changecardidclient(vcontractitemlist(i).pan
									  ,vcontractitemlist(i).mbr
									  ,pidclient);
				END IF;
			END LOOP;
		END IF;
	
		UPDATE tgrouprisk t
		SET    t.idclient = pidclient
		WHERE  t.branch = vbranch
		AND    t.contractno = pcontractno;
	
		IF setidclient(pcontractno, pidclient, poperationmode) != 0
		THEN
			error.raisewhenerr();
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
		
			error.save(cmethod_name);
			RAISE;
	END changecontractidclient;

	PROCEDURE checkincorrectno(pcontractno IN tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetIncorrectNoMessage';
	BEGIN
		IF instr(pcontractno, '~') != 0
		THEN
			error.raiseerror('Contract number contains inadmissible character "tilde"');
		ELSIF instr(pcontractno, '#') != 0
			  OR instr(pcontractno, '@') != 0
			  OR instr(pcontractno, ';') != 0
			  OR instr(pcontractno, '$') != 0
			  OR instr(pcontractno, '^') != 0
			  OR instr(pcontractno, ':') != 0
			  OR instr(pcontractno, '=') != 0
		THEN
			error.raiseerror('Contract number <' || pcontractno ||
							 '> contains inadmissible characters: #@;=:^$');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE addcontractrow(pcontractrow IN tcontract%ROWTYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddContractRow';
	BEGIN
		INSERT INTO tcontract VALUES pcontractrow;
	EXCEPTION
		WHEN dup_val_on_index THEN
			error.saveraise(cmethod_name
						   ,err.ue_other
						   ,'Contract with No "' || pcontractrow.no || '" already exists');
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE makenewcontract
	(
		pocontractparams IN OUT NOCOPY typecontractparams
	   ,pguid            IN types.guid := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.MakeNewContract';
		vcontractrow  tcontract%ROWTYPE;
		vcontracttype tcontracttype%ROWTYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'poContractParams.Type=[' || pocontractparams.type || '], IdClient=[' ||
				pocontractparams.idclient || '], BranchPart=[' || pocontractparams.branchpart ||
				'], CreateDate=[' || pocontractparams.createdate || '], No=[' ||
				pocontractparams.no || ']'
			   ,csay_level);
	
		IF pocontractparams.type IS NULL
		THEN
			error.raiseerror('Contract type to be created not specified');
		END IF;
	
		IF contracttype.getname(pocontractparams.type) IS NULL
		THEN
			error.raiseerror('Contract type (' || pocontractparams.type || ') not defined');
		END IF;
	
		vcontracttype := contracttype.getrecord(pocontractparams.type);
	
		pocontractparams.createdate := nvl(pocontractparams.createdate, seance.getoperdate);
		IF substr(vcontracttype.status, 1, 1) != '1'
		THEN
			error.raiseerror('Contract type (' || pocontractparams.type || ') is not active');
		ELSIF NOT pocontractparams.createdate BETWEEN
			   nvl(vcontracttype.startdate, pocontractparams.createdate) AND
			  nvl(vcontracttype.enddate, pocontractparams.createdate + 1)
		THEN
			error.raiseerror('Contract type (' || pocontractparams.type ||
							 ') is not active on creation date [' ||
							 htools.d2s(pocontractparams.createdate) || ']');
		
		END IF;
	
		IF pocontractparams.idclient IS NULL
		THEN
			error.raiseerror('Contract holder not defined');
		ELSIF (client.isblocked(pocontractparams.idclient))
		THEN
			error.raiseerror(err.client_blocked, 'Prohibited to create contract for this customer');
		END IF;
	
		IF contracttype.getaccessory(pocontractparams.type) = contracttype.cclient
		   AND client.getclienttype(pocontractparams.idclient) = client.ct_company
		THEN
			error.raiseerror('Impossible to create private contract for corporate customer');
		ELSIF contracttype.getaccessory(pocontractparams.type) = contracttype.ccorporate
			  AND client.getclienttype(pocontractparams.idclient) = client.ct_persone
		THEN
			error.raiseerror('Impossible to create corporate contract for private customer');
		END IF;
	
		pocontractparams.branchpart := nvl(pocontractparams.branchpart, seance.getbranchpart);
		pocontractparams.finprofile := contracttype.getfinprofile(pocontractparams.type);
		s.say(cmethod_name || ': FinProfile=' || pocontractparams.finprofile, csay_level);
	
		IF pocontractparams.no IS NULL
		THEN
			custom_s.say(cmethod_name || ': need to generate Contract No', csay_level);
			custom_s.say(cmethod_name || ': poContractParams.BranchPart=' ||
						 pocontractparams.branchpart
						,csay_level);
		
			--pocontractparams.no := custom_contracttype.gencontractno(pocontractparams);
		
			custom_s.say(cmethod_name || ': generated no ' || pocontractparams.no, csay_level);
			IF pocontractparams.no IS NULL
			THEN
				error.raisewhenerr();
			END IF;
		END IF;
	
		IF pocontractparams.no IS NOT NULL
		THEN
			checkincorrectno(pocontractparams.no);
		END IF;
	
		IF pocontractparams.objectuid IS NULL
		THEN
			pocontractparams.objectuid := objectuid.newuid(object_name
														  ,pocontractparams.no
														  ,pguid               => pguid
														  ,pnocommit           => TRUE);
		END IF;
		vcontractrow.objectuid := pocontractparams.objectuid;
		s.say(cmethod_name || ': ' || to_char(pocontractparams.objectuid));
	
		vcontractrow.finprofile      := pocontractparams.finprofile;
		vcontractrow.branch          := seance.getbranch;
		vcontractrow.createclerk     := clerk.getcode;
		vcontractrow.branchpart      := pocontractparams.branchpart;
		vcontractrow.createdate      := pocontractparams.createdate;
		vcontractrow.no              := pocontractparams.no;
		vcontractrow.type            := pocontractparams.type;
		vcontractrow.idclient        := pocontractparams.idclient;
		vcontractrow.commentary      := pocontractparams.commentary;
		vcontractrow.updatedate      := seance.getoperdate;
		vcontractrow.updateclerkcode := clerk.getcode;
		vcontractrow.updatesysdate   := SYSDATE;
		vcontractrow.updaterevision  := 0;
	
		addcontractrow(vcontractrow);
	
		a4mlog.logobject(object.gettype(contract.object_name)
						,vcontractrow.no
						,'Create contract'
						,a4mlog.act_add
						,powner => vcontractrow.idclient);
		t.leave(cmethod_name, 'vContractRow.No=[' || vcontractrow.no || ']', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END makenewcontract;

	PROCEDURE createcontractrecord(pocontract IN OUT typecontractrowdata) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateContractRecord';
		vcontractrow typecontractparams;
	BEGIN
		vcontractrow.branchpart := pocontract.branchpart;
		vcontractrow.createdate := pocontract.createdate;
		vcontractrow.no         := pocontract.no;
		vcontractrow.type       := pocontract.type;
		vcontractrow.idclient   := pocontract.idclient;
		vcontractrow.commentary := pocontract.commentary;
	
		makenewcontract(vcontractrow);
		pocontract.no         := vcontractrow.no;
		pocontract.branchpart := vcontractrow.branchpart;
		pocontract.createdate := vcontractrow.createdate;
	
		contract.setcurrentno(pocontract.no);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END createcontractrecord;

	FUNCTION getdetaileddeletemessage
	(
		pcontractno IN tcontract.no%TYPE
	   ,psqlerrm    IN VARCHAR2
	) RETURN VARCHAR2 IS
		vmessage VARCHAR2(2000);
		vcount   NUMBER;
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetDetailedDeleteMessage';
		cbranch      CONSTANT NUMBER := seance.getbranch();
	BEGIN
		s.say('Start ' || cmethod_name || ', pSQLErrm=' || psqlerrm, csay_level);
		IF (instr(upper(psqlerrm), 'FK_CONTRACTITEM_NO') > 0)
		THEN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tcontractitem t1
			WHERE  t1.branch = cbranch
			AND    t1.no = pcontractno;
			IF vcount != 0
			THEN
				vmessage := 'accounts: ' || vcount;
			END IF;
			SELECT COUNT(*)
			INTO   vcount
			FROM   tcontractcarditem t1
			WHERE  t1.branch = cbranch
			AND    t1.no = pcontractno;
			IF vcount != 0
			THEN
				vmessage := service.iif(vmessage IS NULL
									   ,'cards: ' || vcount
									   ,vmessage || '~ cards: ' || vcount);
			END IF;
		END IF;
		IF (instr(upper(psqlerrm), 'FK_REGULARPAYMENT_CONTRACTNO') > 0)
		THEN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tregularpayment t1
			WHERE  t1.branch = cbranch
			AND    t1.contractno = pcontractno;
			IF vcount != 0
			THEN
				vmessage := 'recurring payments: ' || vcount;
			END IF;
		END IF;
		IF (instr(upper(psqlerrm), 'FK_TSTATEMENT_CNT') > 0)
		THEN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tstatement t1
			WHERE  t1.branch = cbranch
			AND    t1.contractno = pcontractno;
			IF vcount != 0
			THEN
				vmessage := 'periodic statements: ' || vcount;
			END IF;
		END IF;
		IF (instr(upper(psqlerrm), 'FK_TASTAMENTCONTRACT2') > 0)
		THEN
			SELECT COUNT(*)
			INTO   vcount
			FROM   ttastamentcontract t1
			WHERE  t1.branch = cbranch
			AND    t1.contractno = pcontractno;
			IF vcount != 0
			THEN
				vmessage := 'testaments: ' || vcount;
			END IF;
		END IF;
		IF (instr(upper(psqlerrm), 'FK_WARRANTCONTRACT2') > 0)
		THEN
			SELECT COUNT(*)
			INTO   vcount
			FROM   twarrantcontract t1
			WHERE  t1.branch = cbranch
			AND    t1.contractno = pcontractno;
			IF vcount != 0
			THEN
				vmessage := 'warrants: ' || vcount;
			END IF;
		END IF;
		IF (instr(upper(psqlerrm), 'FK_TINSUREDEPOSIT_CNNO') > 0)
		THEN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tinsuredeposit t1
			WHERE  t1.branch = cbranch
			AND    t1.contractno = pcontractno;
			IF vcount != 0
			THEN
				vmessage := 'insurance deposits: ' || vcount;
			END IF;
		END IF;
		IF (instr(upper(psqlerrm), 'FK_TSTANDINGORDER2') > 0)
		THEN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tstandingorder t1
			WHERE  t1.branch = cbranch
			AND    t1.opercontractno = pcontractno;
			IF vcount != 0
			THEN
				vmessage := '    standing orders: ' || vcount;
			END IF;
		END IF;
		IF TRIM(vmessage) IS NULL
		THEN
			vmessage := psqlerrm;
		END IF;
		RETURN vmessage;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ', exception occured errm=' || SQLERRM, csay_level);
			RETURN psqlerrm;
	END;

	FUNCTION getcontrolblockmode(pblocktype IN VARCHAR2) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetControlBlockMode';
		vret NUMBER;
	BEGIN
		t.enter(cmethod_name, 'pBlockType=' || pblocktype, csay_level);
		IF pblocktype NOT IN (sqlblockoptions.cblock_persdelete, sqlblockoptions.cblock_compdelete)
		THEN
			error.raiseerror('Unknown ID of control block [' || pblocktype || ']');
		END IF;
	
		vret := sqlblockoptions.getparameter(sqlblockoptions.cobj_contract, pblocktype);
		t.var('vRet', vret);
	
		vret := nvl(vret, sqlblockoptions.crule_dialogonly);
	
		t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getaccessory(pcontract IN tcontract%ROWTYPE) RETURN tcontracttype.accessory%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetAccessory';
		vtype      tcontract.type%TYPE;
		vidclient  tcontract.idclient%TYPE;
		vaccessory tcontracttype.accessory%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pContract.No=' || pcontract.no || ', pContract.Type=' || pcontract.type ||
				', pContract.IdClient=' || pcontract.idclient);
		IF pcontract.no IS NULL
		   AND pcontract.type IS NULL
		   AND pcontract.idclient IS NULL
		   OR (pcontract.no IS NULL AND (pcontract.type IS NULL OR pcontract.idclient IS NULL))
		THEN
			error.raiseerror('Not defined contract parameters');
		END IF;
	
		vtype     := pcontract.type;
		vidclient := pcontract.idclient;
		IF vtype IS NULL
		THEN
			vtype := gettype(pcontract.no);
			t.var('vType', vtype);
		END IF;
		IF vidclient IS NULL
		THEN
			vidclient := getclientid(pcontract.no);
			t.var('vIdClient', vidclient);
		END IF;
	
		IF contracttype.getaccessory(vtype) = contracttype.cclient
		   AND client.getclienttype(vidclient) = client.ct_persone
		THEN
			t.note('Accessory=ContractType.cCLIENT');
			vaccessory := contracttype.cclient;
		ELSIF contracttype.getaccessory(vtype) = contracttype.ccorporate
			  AND client.getclienttype(vidclient) = client.ct_company
		THEN
			t.note('Accessory=ContractType.cCORPORATE');
			vaccessory := contracttype.ccorporate;
		ELSE
			error.raiseerror('Impossible to determine belonging of contract [' || pcontract.no || ']');
		END IF;
		t.leave(cmethod_name, 'vAccessory=' || vaccessory, plevel => csay_level);
		RETURN vaccessory;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE execcontrolblock_ondelete
	(
		pmode       IN PLS_INTEGER
	   ,pcontractno IN tcontract.no%TYPE
	)
	
	 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExecControlBlock_onDelete';
		vcontrolblockmode NUMBER;
		vaccessory        tcontracttype.accessory%TYPE;
		vcontractrow      tcontract%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, 'pMode=' || pmode || ',pContractNo=' || pcontractno, csay_level);
	
		IF pmode IS NULL
		THEN
			error.raiseerror('Unknown mode of contract deletion');
		END IF;
		t.note('point 1');
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Undefined contract No');
		END IF;
		t.note('point 2');
	
		vcontractrow := getcontractrowtype(pcontractno);
	
		vaccessory := getaccessory(vcontractrow);
		IF vaccessory = contracttype.cclient
		THEN
			vcontrolblockmode := getcontrolblockmode(sqlblockoptions.cblock_persdelete);
		ELSIF vaccessory = contracttype.ccorporate
		THEN
			vcontrolblockmode := getcontrolblockmode(sqlblockoptions.cblock_compdelete);
		ELSE
			error.raiseerror('Impossible to determine belonging of block of contract deletion control [' ||
							 pcontractno || ']');
		END IF;
	
		t.note('point 3: vAccessory=' || vaccessory);
	
		IF pmode != c_rollbackmode
		   AND (pmode = c_interactivemode AND vcontrolblockmode = sqlblockoptions.crule_dialogonly OR
		   vcontrolblockmode = sqlblockoptions.crule_always)
		THEN
			t.note(cmethod_name, ' begin running block...', csay_level);
			contractblocks.run(contractblocks.bt_ondelete, pcontractno, vaccessory);
			t.note(cmethod_name, ' end running block', csay_level);
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE deletecontractrecord
	(
		pno   IN tcontract.no%TYPE
	   ,pmode IN PLS_INTEGER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DeleteContractRecord';
		vbranch    NUMBER := seance.getbranch;
		vobjectuid NUMBER;
	
		vmode PLS_INTEGER;
	
	BEGIN
		t.enter(cmethod_name, 'pNo=' || pno || ', pMode=' || pmode, csay_level);
	
		vmode := nvl(pmode, c_rollbackmode);
		t.var('vMode', vmode);
		execcontrolblock_ondelete(vmode, pno);
	
		DELETE FROM tcontract
		WHERE  branch = vbranch
		AND    no = pno
		RETURNING objectuid INTO vobjectuid;
	
		t.var('ObjectUID', to_char(vobjectuid));
	
		IF vobjectuid IS NOT NULL
		THEN
			objectuid.freeuid(vobjectuid);
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			IF SQLCODE = -2292
			THEN
				error.saveraise(cmethod_name
							   ,err.contract_exist_active_items
							   ,getdetaileddeletemessage(pno, SQLERRM));
			ELSE
				error.save(cmethod_name);
				RAISE;
			END IF;
	END deletecontractrecord;

	FUNCTION gethandle(pcontractno IN tcontract.no%TYPE) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetHandle';
		vindex NUMBER := scontractarray.first;
	BEGIN
		s.say(cmethod_name || ': pContractNo ' || pcontractno, csay_level);
		s.say(cmethod_name || ': total ' || scontractarray.count, csay_level);
		IF scontractarray.count = 0
		THEN
			s.say(cmethod_name || ': nothing ', csay_level);
			RETURN NULL;
		END IF;
	
		WHILE vindex IS NOT NULL
		LOOP
			s.say(cmethod_name || ': contract ' || scontractarray(vindex).contractrow.no
				 ,csay_level);
		
			IF scontractarray(vindex).contractrow.no = pcontractno
				AND scontractarray(vindex).contractmode != 'A'
			THEN
			
				s.say(cmethod_name || ': index ' || vindex, csay_level);
				RETURN vindex;
			END IF;
			vindex := scontractarray.next(vindex);
		END LOOP;
	
		s.say(cmethod_name || ': nothing', csay_level);
		RETURN NULL;
	END gethandle;

	PROCEDURE setcurrentrevision
	(
		pcontractno     tcontract.no%TYPE
	   ,pupdaterevision tcontract.updaterevision%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCurrentRevision';
	BEGIN
		t.enter(cmethod_name
			   ,'ContractNo=' || pcontractno || ', UpdateRevision=' || pupdaterevision);
	
		MERGE INTO ttempcontractcontrolrevision tr
		USING dual
		ON (tr.contractno = pcontractno)
		WHEN MATCHED THEN
			UPDATE SET updaterevision = pupdaterevision
		WHEN NOT MATCHED THEN
			INSERT
				(contractno
				,updaterevision)
			VALUES
				(pcontractno
				,pupdaterevision);
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getrevisionfromcontroltable(pcontractno tcontract.no%TYPE) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetRevisionFromControlTable';
		vret NUMBER;
	BEGIN
		t.enter(cmethod_name, 'ContractNo=' || pcontractno);
		SELECT updaterevision
		INTO   vret
		FROM   ttempcontractcontrolrevision
		WHERE  contractno = pcontractno;
		t.leave(cmethod_name, 'return ' || vret);
		RETURN vret;
	EXCEPTION
	
		WHEN no_data_found THEN
			s.err(cmethod_name);
			RETURN NULL;
		
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getupdaterevisionbyhandle(phandle NUMBER) RETURN tcontract.updaterevision%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetUpdateRevisionbyHandle';
		vret tcontract.updaterevision%TYPE;
	BEGIN
		t.enter(cmethod_name, 'Handle=' || phandle, csay_level);
	
		IF scontractarray(phandle).contractmode = 'R'
		THEN
			vret := scontractarray(phandle).contractrow.updaterevision;
		ELSE
		
			vret := getrevisionfromcontroltable(scontractarray(phandle).contractrow.no);
		END IF;
	
		t.leave(cmethod_name, 'return ' || vret, csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getupdaterevision(pcontractno IN tcontract.no%TYPE) RETURN tcontract.updaterevision%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetUpdateRevision';
		vhandle NUMBER;
		vnew    BOOLEAN;
		vret    tcontract.updaterevision%TYPE;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno, csay_level);
		vhandle := gethandle(pcontractno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontractno, 'R');
			vnew    := TRUE;
		END IF;
	
		vret := getupdaterevisionbyhandle(vhandle);
	
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
	
		t.leave(cmethod_name, 'return ' || vret, csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE refreshrevision
	(
		pcontractno IN tcontract.no%TYPE
	   ,paction     IN PLS_INTEGER
	   ,pvalue      IN tcontract.updaterevision%TYPE := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.RefreshRevision';
		vhandle NUMBER;
		vnew    BOOLEAN;
	BEGIN
		s.say(cmethod_name || ': start [pContractNo=' || pcontractno || ', pAction=' || paction ||
			  ', pValue=' || pvalue || ']'
			 ,csay_level);
		vhandle := gethandle(pcontractno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontractno, 'R');
			vnew    := TRUE;
		END IF;
	
		CASE paction
			WHEN caction_renew THEN
				writeobject(vhandle);
			
			WHEN caction_reread THEN
				scontractarray(vhandle).contractrow.updaterevision := getcontractrowtype(pcontractno)
																	  .updaterevision;
				setcurrentrevision(scontractarray(vhandle).contractrow.no
								  ,scontractarray(vhandle).contractrow.updaterevision);
			
			WHEN caction_restore THEN
				IF pvalue IS NULL
				THEN
					error.raiseerror('Contract revision not defined');
				ELSE
					s.say(cmethod_name || ': restore revision (' ||
						  to_char(scontractarray(vhandle).contractrow.updaterevision) || ')->(' ||
						  to_char(pvalue) || ')'
						 ,csay_level);
					scontractarray(vhandle).contractrow.updaterevision := pvalue;
					setcurrentrevision(pcontractno, pvalue);
				END IF;
			ELSE
				error.raiseerror('Unknown contract revision update mode: ' || to_char(paction));
		END CASE;
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ', ErrorText=' || error.geterrortext);
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END refreshrevision;

	FUNCTION getidclient(pno IN VARCHAR2) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetIdClient';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vidclient NUMBER;
	BEGIN
		SELECT idclient
		INTO   vidclient
		FROM   tcontract
		WHERE  branch = cbranch
		AND    no = pno;
		RETURN vidclient;
	EXCEPTION
		WHEN no_data_found THEN
			err.seterror(err.contract_not_found, cmethod_name);
			RETURN NULL;
	END getidclient;

	FUNCTION getclientid(pcontractno IN tcontract.no%TYPE) RETURN tcontract.idclient%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetClientId';
		vidclient tcontract.idclient%TYPE;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno);
		err.seterror(0, cmethod_name);
		vidclient := getidclient(pcontractno);
		error.raisewhenerr();
		t.leave(cmethod_name, 'vIdClient=' || vidclient);
		RETURN vidclient;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE insertaccountitem
	(
		pitemrow   IN OUT tcontractitem%ROWTYPE
	   ,pmakelog   IN BOOLEAN := FALSE
	   ,plogparams IN typelogparams := semptylogparams
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.InsertAccountItem';
		vbranch  NUMBER := seance.getbranch();
		vmakelog BOOLEAN := nvl(pmakelog, FALSE);
		vindex   VARCHAR2(200);
	
		vnameparams contractentryremark.typeremarkparams;
		vataglist   contracttypeschema.typeremarktaglist;
	BEGIN
		t.enter(cmethod_name
			   ,'pItemRow.No=' || pitemrow.no || ', pItemRow.Key=' || pitemrow.key ||
				', pItemRow.ItemCode=' || pitemrow.itemcode || ', pMakeLog=' || t.b2t(pmakelog)
			   ,csay_level);
	
		pitemrow.branch   := nvl(pitemrow.branch, vbranch);
		pitemrow.itemtype := contracttype.itemaccount;
		t.var('pItemRow.Actualdate', pitemrow.actualdate);
		IF pitemrow.actualdate IS NULL
		THEN
			pitemrow.actualdate := account.getaccountrecord(pitemrow.key).createdate;
		END IF;
	
		vnameparams.itemname := contracttypeitems.getcitnamerecord(pitemrow.itemcode).itemname;
		IF pitemrow.itemdescr IS NULL
		THEN
			vnameparams.contract.no := pitemrow.no;
			pitemrow.itemdescr      := contractentryremark.getname4account(vnameparams, vataglist);
		END IF;
	
		INSERT INTO tcontractitem VALUES pitemrow;
	
		IF vmakelog
		THEN
			a4mlog.cleanparamlist;
			a4mlog.addparamrec(clogparam_accno, pitemrow.key);
			a4mlog.addparamrec(clogparam_itemcode, pitemrow.itemcode);
			a4mlog.addparamrec(clogparam_itemname, vnameparams.itemname);
			a4mlog.addparamrec(clogparam_accitemdescr, pitemrow.itemdescr);
		
			vindex := plogparams.paramlist.first();
			WHILE vindex IS NOT NULL
			LOOP
				a4mlog.addparamrec(vindex, plogparams.paramlist(vindex));
				vindex := plogparams.paramlist.next(vindex);
			END LOOP;
		
			IF a4mlog.logobject(object.gettype(contract.object_name)
							   ,pitemrow.no
							   ,plogparams.logmessage
							   ,a4mlog.act_add
							   ,a4mlog.putparamlist()
							   ,powner => getclientid(pitemrow.no)) != 0
			THEN
				error.raisewhenerr();
			END IF;
			a4mlog.cleanparamlist;
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN dup_val_on_index THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.saveraise(cmethod_name
						   ,error.errorconst
						   ,'Account "' || pitemrow.key || '" already belongs to contract');
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			s.say(cmethod_name || ', ErrorText=' || error.geterrortext);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION contractcarditem
	(
		pcontractno IN tcontractcarditem.no%TYPE
	   ,pitemcode   IN tcontractcarditem.itemcode%TYPE
	   ,ppan        IN tcontractcarditem.pan%TYPE
	   ,pmbr        IN tcontractcarditem.mbr%TYPE
	   ,pbranch     IN tcontractcarditem.branch%TYPE := NULL
	) RETURN tcontractcarditem%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ContractCardItem';
		vret tcontractcarditem%ROWTYPE;
	BEGIN
	
		vret.branch   := coalesce(pbranch, seance.getbranch());
		vret.no       := pcontractno;
		vret.itemcode := pitemcode;
		vret.pan      := ppan;
		vret.mbr      := pmbr;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION contractaccountitem
	(
		pcontractno IN tcontractitem.no%TYPE
	   ,pitemcode   IN tcontractitem.itemcode%TYPE
	   ,pkey        IN tcontractitem.key%TYPE
	   ,pactualdate IN tcontractitem.actualdate%TYPE := NULL
	   ,pbranch     IN tcontractitem.branch%TYPE := NULL
	   ,pitemdescr  IN tcontractitem.itemdescr%TYPE := NULL
	) RETURN tcontractitem%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ContractCardItem';
		vret tcontractitem%ROWTYPE;
	BEGIN
	
		vret.branch     := coalesce(pbranch, seance.getbranch());
		vret.no         := pcontractno;
		vret.itemcode   := pitemcode;
		vret.key        := pkey;
		vret.actualdate := pactualdate;
		vret.itemtype   := contracttype.itemaccount;
		vret.itemdescr  := pitemdescr;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE insertcarditem(pcarditemrow IN OUT tcontractcarditem%ROWTYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.InsertCardItem';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		pcarditemrow.branch := nvl(pcarditemrow.branch, vbranch);
	
		INSERT INTO tcontractcarditem VALUES pcarditemrow;
	
		refreshrevision(pcarditemrow.no, caction_renew);
	EXCEPTION
		WHEN dup_val_on_index THEN
			error.saveraise(cmethod_name
						   ,error.errorconst
						   ,'Card "' || card.getmaskedpan(pcarditemrow.pan) || '-' ||
							to_char(pcarditemrow.mbr) || '" already belongs to contract');
		WHEN OTHERS THEN
			s.say(cmethod_name || ', ErrorText=' || error.geterrortext);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE addnewclientaccounttocontract
	(
		paccountrow   IN typeaccountrow
	   ,pcontract     IN typecontractparams
	   ,psavelog      IN BOOLEAN := FALSE
	   ,psaverollback IN BOOLEAN := FALSE
	   ,pdoschemacall IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddNewClientAccountToContract';
		vaccountsettings typeaccountrow := paccountrow;
		vaccountrow      taccount%ROWTYPE;
		vcontractitemrow tcontractitem%ROWTYPE;
		vlogparams       typelogparams;
	BEGIN
		s.say('Start ' || cmethod_name || '...', csay_level);
	
		IF pdoschemacall
		THEN
			--contracttypeschema.oncreateaccount(pcontract.no, vaccountsettings);
			NULL;
		END IF;
	
		vaccountrow.accountno := vaccountsettings.accountno;
	
		IF vaccountsettings.accounttype IS NOT NULL
		THEN
			vaccountrow.accounttype := vaccountsettings.accounttype;
		ELSE
			vaccountrow.accounttype := contractaccount.getaccounttype(vaccountsettings.itemcode);
		END IF;
	
		vaccountrow.idclient   := pcontract.idclient;
		vaccountrow.createdate := service.iif(pcontract.changeacccreatedate
											 ,pcontract.createdate
											 ,NULL);
		vaccountrow.branchpart := pcontract.branchpart;
		vaccountrow.remain     := 0;
		vaccountrow.available  := 0;
		vaccountrow.overdraft  := 0;
	
		vaccountrow.noplan := contractaccount.getnoplan(vaccountrow.accounttype
													   ,vaccountrow.branchpart
													   ,TRUE);
		IF accounttype.getaccmap(vaccountrow.accounttype) IS NOT NULL
		THEN
			contractaccount.checkcurrency4account(contract.gettype(pcontract.no)
												 ,vaccountsettings.itemcode
												 ,vaccountrow.accounttype);
		END IF;
	
		vaccountrow.acct_typ  := contractaccount.getacct_typ(vaccountsettings.itemcode);
		vaccountrow.acct_stat := contractaccount.getacct_stat(vaccountsettings.itemcode);
	
		account.createaccount(vaccountrow
							 ,vaccountsettings.userproperty
							 ,pdisableuserblockedcheck => TRUE);
		error.raisewhenerr();
	
		s.say(cmethod_name || ': account no ' || vaccountrow.accountno, csay_level);
		IF vaccountsettings.extaccount IS NOT NULL
		THEN
			IF acc2acc.setoldaccountno(vaccountrow.accountno, vaccountsettings.extaccount) != 0
			THEN
				s.say(cmethod_name || ': error setting old account no ' || err.getfullmessage()
					 ,csay_level);
				error.raisewhenerr();
			END IF;
		END IF;
	
		vcontractitemrow.no         := pcontract.no;
		vcontractitemrow.itemcode   := vaccountsettings.itemcode;
		vcontractitemrow.key        := vaccountrow.accountno;
		vcontractitemrow.actualdate := nvl(vaccountsettings.actualdate, vaccountrow.createdate);
	
		vlogparams.logmessage := 'new account added';
		vlogparams.paramlist(clogparam_idclient) := vaccountrow.idclient;
		insertaccountitem(vcontractitemrow, psavelog, vlogparams);
	
		IF psaverollback
		THEN
			contractrb.setlabel(crl_create_newaccount);
			contractrb.setcvalue(ckey_accountno, vaccountrow.accountno);
		END IF;
	
		t.leave(cmethod_name, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END addnewclientaccounttocontract;

	PROCEDURE linkexistaccounttocontract
	(
		paccountrow     IN typeaccountrow
	   ,pcontractrow    IN typecontractparams
	   ,psaverollback   IN BOOLEAN := TRUE
	   ,psavelog        IN BOOLEAN := FALSE
	   ,pchangeidclient IN BOOLEAN := TRUE
	   ,pdoschemacall   IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.LinkExistAccountToContract';
		vcontractno      tcontract.no%TYPE;
		vexistingaccount apitypes.typeaccountrecord;
		vcontractitemrow tcontractitem%ROWTYPE;
		voldidclient     NUMBER := NULL;
		vaccounttype     NUMBER;
		vitemnamerecord  tcontracttypeitemname%ROWTYPE;
		vlogparams       typelogparams;
		vaccountsettings typeaccountrow := paccountrow;
	BEGIN
		t.enter(cmethod_name, 'DoSchemaCall=' || htools.b2s(pdoschemacall));
		vcontractno := getcontractnobyaccno(vaccountsettings.accountno, FALSE);
	
		IF vcontractno IS NOT NULL
		THEN
			s.say(cmethod_name || ': account is already in a contract', csay_level);
			error.raiseerror('Attempted addition of account belonging to another contract to this contract');
		END IF;
	
		IF contract.getaccountno(pcontractrow.no, vaccountsettings.itemcode) IS NOT NULL
		THEN
			error.raiseerror('Contract ' || pcontractrow.no || ' already has account with ID ' ||
							 vaccountsettings.itemcode);
		END IF;
	
		vitemnamerecord := contracttypeitems.getcitnamerecord(vaccountsettings.itemcode);
		t.var(cmethod_name, 'vItemNameRecord.ItemName=' || vitemnamerecord.itemname, csay_level);
		t.var(cmethod_name, 'pContractRow.Type=' || pcontractrow.type, csay_level);
		IF contracttypeitems.getitemcode(pcontractrow.type, vitemnamerecord.itemname, TRUE) !=
		   vaccountsettings.itemcode
		THEN
			error.raiseerror('Settings of contract type [' || pcontractrow.type ||
							 '] contain no account with ID [' || vaccountsettings.itemcode || ']');
		END IF;
	
		vexistingaccount := account.getaccountrecord(vaccountsettings.accountno);
		s.say(cmethod_name || ': existing account type ' || vexistingaccount.accounttype
			 ,csay_level);
		s.say(cmethod_name || ':  vAccountSettings.AccountType=' || vaccountsettings.accounttype
			 ,csay_level);
		vaccounttype := vaccountsettings.accounttype;
	
		IF contractaccount.checkrefaccounttype(vitemnamerecord.refaccounttype
											  ,contractaccount.refaccounttype_single)
		THEN
			vaccounttype := nvl(contractaccount.getaccounttype(vaccountsettings.itemcode), -999);
		ELSIF contractaccount.checkrefaccounttype(vitemnamerecord.refaccounttype
												 ,contractaccount.refaccounttype_table)
		THEN
			vaccounttype := service.iif(ctaccounttypeperiod.existaccounttype(pcontractrow.type
																			,vitemnamerecord.itemname
																			,vexistingaccount.accounttype)
									   ,vexistingaccount.accounttype
									   ,-999);
		ELSE
			error.raiseerror('No settings for account with ID [' || vaccountsettings.itemcode ||
							 '] in contract type [' || pcontractrow.type || ']');
		END IF;
	
		s.say(cmethod_name || ': account type ' || vaccounttype, csay_level);
		IF vaccounttype = vexistingaccount.accounttype
		   OR ctdialog.ignoreaccounttype(pcontractrow.type)
		THEN
			NULL;
		ELSE
			s.say(cmethod_name || ': wrong account type', csay_level);
			error.raiseerror('Attempted addition of account of inappropriate type to contract');
		END IF;
	
		IF contracttype.getaccessory(pcontractrow.type) = contracttype.cclient
		   AND client.getclienttype(vexistingaccount.idclient) = client.ct_company
		THEN
			error.raiseerror('Attempted addition of corporate account to private contract');
		ELSIF contracttype.getaccessory(pcontractrow.type) = contracttype.ccorporate
			  AND client.getclienttype(vexistingaccount.idclient) = client.ct_persone
		THEN
			error.raiseerror('Attempted addition of private account to corporate contract');
		END IF;
	
		IF pdoschemacall
		THEN
			--    contracttypeschema.oncreateaccount(pcontractrow.no, vaccountsettings);
			NULL;
		END IF;
	
		vcontractitemrow.no         := pcontractrow.no;
		vcontractitemrow.itemcode   := vaccountsettings.itemcode;
		vcontractitemrow.key        := vaccountsettings.accountno;
		vcontractitemrow.actualdate := nvl(vaccountsettings.actualdate, vaccountsettings.createdate);
		vcontractitemrow.itemdescr  := vaccountsettings.accitemdescr;
	
		IF vcontractitemrow.actualdate IS NULL
		THEN
			vcontractitemrow.actualdate := seance.getoperdate();
		END IF;
	
		vlogparams.logmessage := 'existing account added';
		vlogparams.paramlist(clogparam_idclient) := vexistingaccount.idclient;
	
		insertaccountitem(vcontractitemrow, psavelog, vlogparams);
	
		IF psaverollback
		THEN
			contractrb.setlabel(crl_link_existacc);
			contractrb.setcvalue(ckey_accountno, vaccountsettings.accountno);
		END IF;
	
		IF pchangeidclient
		   AND vexistingaccount.idclient != pcontractrow.idclient
		THEN
			voldidclient := vexistingaccount.idclient;
			changeaccountidclient(vaccountsettings.accountno, pcontractrow.idclient, psavelog);
			IF psaverollback
			THEN
				contractrb.setnvalue(ckey_idclient, voldidclient);
			END IF;
		END IF;
	
		account.saveuserattributeslist(vaccountsettings.accountno, vaccountsettings.userproperty);
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END linkexistaccounttocontract;

	PROCEDURE deletecarditem
	(
		pno  IN tcontract.no%TYPE
	   ,ppan IN tcard.pan%TYPE
	   ,pmbr IN tcard.mbr%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DeleteCardItem';
		cbranch      CONSTANT NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
	
		DELETE FROM tcontractcarditem
		WHERE  branch = cbranch
		AND    pan = ppan
		AND    mbr = pmbr
		AND    no = pno;
	
		t.leave(cmethod_name, 'deleted cards: ' || SQL%ROWCOUNT, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE deleteprimarylink
	(
		ppan          VARCHAR2
	   ,pmbr          NUMBER
	   ,psaverollback IN BOOLEAN
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DeletePrimaryLink';
		cbranch      CONSTANT NUMBER := seance.getbranch();
	
		vcontract  typecontractitemrecord;
		vacclist   apitypes.typeaccount2cardlist;
		vaccountno tacc2card.accountno%TYPE;
		vdesc      tacc2card.description%TYPE;
	BEGIN
		err.seterror(0, cmethod_name);
		s.say(cmethod_name || ': for card ' || card.getmaskedpan(ppan) || '-' || pmbr, csay_level);
	
		vacclist := card.getaccountlist(ppan, pmbr);
		FOR i IN 1 .. vacclist.count
		LOOP
			IF vacclist(i).acct_stat = referenceacct_stat.stat_primary
			THEN
				vaccountno := vacclist(i).accountno;
				vdesc      := vacclist(i).description;
				EXIT;
			END IF;
		END LOOP;
		s.say(cmethod_name || ': primary Account ' || nvl(vaccountno, 'not found'), csay_level);
	
		IF vaccountno IS NOT NULL
		THEN
			card.deletelinkaccount(ppan, pmbr, vaccountno, FALSE);
			error.raisewhenerr();
		END IF;
	
		IF psaverollback
		THEN
			contractrb.setlabel(crl_link_existcard);
			contractrb.setcvalue(ckey_pan, ppan);
			contractrb.setnvalue(ckey_mbr, pmbr);
			contractrb.setcvalue(ckey_accountno, vaccountno);
			contractrb.setcvalue(ckey_carddescr, vdesc);
		END IF;
	
		vcontract := getcontractbycard(ppan, pmbr);
		s.say(cmethod_name || ': vContract.ContractNo=' || vcontract.contractno, csay_level);
		IF vcontract.contractno IS NOT NULL
		THEN
		
			vacclist := card.getaccountlist(ppan, pmbr);
			FOR i IN 1 .. vacclist.count
			LOOP
			
				FOR k IN (SELECT branch
						  FROM   tcontractitem
						  WHERE  branch = cbranch
						  AND    key = vacclist(i).accountno
						  AND    no = vcontract.contractno)
				LOOP
					s.say(cmethod_name || ': for account ' || vacclist(i).accountno, csay_level);
					card.deletelinkaccount(ppan, pmbr, vacclist(i).accountno, FALSE);
					IF psaverollback
					THEN
						contractrb.setnextcvalue(ckey_a2c_no, vacclist(i).accountno);
						contractrb.setnextcvalue(ckey_a2c_stat, vacclist(i).acct_stat);
						contractrb.setnextcvalue(ckey_a2c_descr
												,nvl(vacclist(i).description, 'null'));
						contractrb.setnextnvalue(ckey_a2c_limitgrp
												,nvl(vacclist(i).limitgrpid, -1));
					END IF;
				END LOOP;
			END LOOP;
		
			deletecarditem(vcontract.contractno, ppan, pmbr);
		
			IF psaverollback
			THEN
				contractrb.setcvalue(ckey_cono, vcontract.contractno);
				contractrb.setnvalue(ckey_itemcode, vcontract.itemcode);
			END IF;
		END IF;
	
		err.seterror(0, cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END deleteprimarylink;

	PROCEDURE deleteaccountfromcontract
	(
		pno           IN tcontract.no%TYPE
	   ,paccountno    IN taccount.accountno%TYPE
	   ,psaverollback IN BOOLEAN := FALSE
	   ,pmakelog      IN BOOLEAN := FALSE
	   ,pmove2history IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DeleteAccountFromContract';
	
		cbranch CONSTANT NUMBER := seance.getbranch();
		vactualdate DATE;
		voperdate   DATE;
	
		vitemcode    NUMBER;
		vitemname    tcontracttypeitemname.itemname%TYPE;
		vacc2history contractaccounthistory.typecontractacchistory;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pNo', pno);
		t.inpar('pAccountNo', paccountno);
		t.inpar('pSaveRollback', t.b2t(psaverollback));
		t.inpar('pMakeLog', t.b2t(pmakelog));
		t.inpar('pMove2History', t.b2t(pmove2history));
	
		IF nvl(pmakelog, FALSE)
		THEN
			vitemname := contracttypeitems.getitemnamebyaccountno(paccountno);
		END IF;
	
		DELETE FROM tcontractitem
		WHERE  branch = cbranch
		AND    key = paccountno
		AND    no = pno
		RETURNING actualdate, itemcode INTO vactualdate, vitemcode;
	
		t.note('deleted ' || SQL%ROWCOUNT || ' rows');
	
		IF psaverollback
		THEN
			contractrb.setlabel(crl_unlink_existacc);
			contractrb.setcvalue(ckey_accountno, paccountno);
			contractrb.setdvalue(ckey_actualdate, vactualdate);
			contractrb.setnvalue(ckey_itemcode, vitemcode);
		END IF;
	
		IF nvl(pmakelog, FALSE)
		THEN
			a4mlog.cleanparamlist;
			a4mlog.addparamrec(clogparam_accno, paccountno);
			a4mlog.addparamrec(clogparam_itemcode, vitemcode);
			a4mlog.addparamrec(clogparam_itemname, vitemname);
		
			IF a4mlog.logobject(object.gettype(contract.object_name)
							   ,pno
							   ,'account unlinked'
							   ,a4mlog.act_del
							   ,a4mlog.putparamlist()
							   ,powner => getclientid(pno)) != 0
			THEN
				error.raisewhenerr();
			END IF;
			a4mlog.cleanparamlist;
		END IF;
	
		IF pmove2history
		THEN
			voperdate := seance.getoperdate();
		
			vacc2history := contractaccounthistory.newaccounthistoryrecord(pno
																		  ,paccountno
																		  ,pitemname     => contracttypeitems.getcitnamerecord(vitemcode)
																							.itemname
																		  ,pdatestarting => vactualdate
																		  ,pdateexpiring => voperdate);
			contractaccounthistory.addacchistory(vacc2history.acchistory, psaverollback);
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END deleteaccountfromcontract;

	PROCEDURE addcontractitem
	(
		pcontractno IN VARCHAR2
	   ,pcardparams IN typecardparams
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddContractItem';
		vcarditemrow tcontractcarditem%ROWTYPE;
	BEGIN
		vcarditemrow := contractcarditem(pcontractno
										,pcardparams.itemcode
										,pcardparams.pan
										,pcardparams.mbr);
		insertcarditem(vcarditemrow);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END addcontractitem;

	PROCEDURE createlinkcard2contract
	(
		pcreatemode   IN NUMBER
	   ,pcontractno   IN VARCHAR2
	   ,pcardparams   IN typecardparams
	   ,psaverollback IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateLinkCard2Contract';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vaacc2cardlist apitypes.typeaccount2cardlist;
	
		CURSOR c1 IS
			SELECT ci.itemcode
				  ,ci.key accountno
				  ,cca.accstatus
				  ,cca.description
			FROM   tcontractitem    ci
				  ,tcontractcardacc cca
			WHERE  cca.branch = cbranch
			AND    cca.code = pcardparams.itemcode
			AND    ci.branch = cca.branch
			AND    ci.no = pcontractno
			AND    ci.itemcode = cca.acccode;
	BEGIN
	
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pContractNo', pcontractno);
		t.inpar('pCardParams.UseOnline', t.b2t(pcardparams.useonline));
		t.inpar('pCardParams.ItemCode', pcardparams.itemcode);
		s.say(cmethod_name || ': create mode ' || pcreatemode, csay_level);
		s.say(cmethod_name || ': pSaveRollback=' || htools.bool2str(psaverollback), csay_level);
		FOR i IN c1
		LOOP
			s.say(cmethod_name || ': account status ' || i.accstatus, csay_level);
			IF i.accstatus != referenceacct_stat.stat_primary
			   OR pcreatemode != contractcard.newcreate
			THEN
				s.say(cmethod_name || ': ' || card.getmaskedpan(pcardparams.pan) || ' to ' ||
					  i.accountno || ' descr ' || i.description
					 ,csay_level);
			
				IF psaverollback
				THEN
					vaacc2cardlist := card.getaccountlist(pcardparams.pan, pcardparams.mbr);
					FOR j IN 1 .. vaacc2cardlist.count
					LOOP
						IF vaacc2cardlist(j).accountno = i.accountno
						THEN
							contractrb.setnextcvalue(ckey_a2c_no, vaacc2cardlist(j).accountno);
							contractrb.setnextcvalue(ckey_a2c_stat, vaacc2cardlist(j).acct_stat);
							contractrb.setnextcvalue(ckey_a2c_descr
													,nvl(vaacc2cardlist(j).description, 'null'));
							contractrb.setnextnvalue(ckey_a2c_limitgrp
													,nvl(vaacc2cardlist(j).limitgrpid, -1));
							EXIT;
						END IF;
					END LOOP;
				END IF;
				t.note('POINT 001');
				card.createlinkaccount(pcardparams.pan
									  ,pcardparams.mbr
									  ,i.accountno
									  ,i.accstatus
									  ,i.description
									  ,pcreatemode     => pcreatemode
									  ,puseonline      => nvl(pcardparams.useonline, FALSE));
				t.note('POINT 002');
				error.raisewhenerr();
				t.note('POINT 003');
			
				IF getcontractnobycard(pcardparams.pan, pcardparams.mbr, FALSE) IS NULL
				THEN
					t.note('POINT 004');
					addcontractitem(pcontractno, pcardparams);
				END IF;
				t.note('POINT 005');
			END IF;
		END LOOP;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
		
			error.save(cmethod_name);
			RAISE;
	END createlinkcard2contract;

	PROCEDURE linkexistingcard2contract
	(
		pcardrow      IN typecardparams
	   ,pcontractrow  IN typecontractparams
	   ,psaverollback IN BOOLEAN := TRUE
	   ,psavelog      IN BOOLEAN := FALSE
	)
	
	 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.LinkExistingCard2Contract';
		vret  NUMBER;
		vcard typecardparams;
	
	BEGIN
		t.enter(cmethod_name
			   ,'No=' || pcontractrow.no || ', type=' || pcontractrow.type || ', ItemCode=' ||
				pcardrow.itemcode || ', pSaveRollback=' || htools.bool2str(psaverollback));
		vcard := pcardrow;
	
		t.note(cmethod_name || ': deleting account link ', csay_level);
		deleteprimarylink(vcard.pan, vcard.mbr, psaverollback);
		t.note(cmethod_name || ': creating contract link ', csay_level);
		createlinkcard2contract(contractcard.newlink, pcontractrow.no, vcard, psaverollback);
	
		t.note(cmethod_name || ': done ', csay_level);
		IF nvl(psavelog, FALSE)
		THEN
			t.note(cmethod_name || ': creating log', csay_level);
			a4mlog.cleanparamlist;
			a4mlog.addparamrec(clogparam_pan, vcard.pan);
			a4mlog.addparamrec(clogparam_mbr, vcard.mbr);
			vret := a4mlog.logobject(object.gettype(contract.object_name)
									,pcontractrow.no
									,'Added existing card'
									,a4mlog.act_add
									,a4mlog.putparamlist()
									,powner => getclientid(pcontractrow.no));
			IF vret != 0
			THEN
				error.raisewhenerr();
			END IF;
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE linkexistingcardtocontract
	(
		pcardrow      IN typecardparams
	   ,pcontractrow  IN typecontractparams
	   ,psaverollback IN BOOLEAN := TRUE
	   ,psavelog      IN BOOLEAN := FALSE
	)
	
	 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.LinkExistingCardToContract';
	
		vcard typecardparams;
	
		vacardlist complexcard.typecardlist;
		vcardtype  tcard.supplementary%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'No=' || pcontractrow.no || ', type=' || pcontractrow.type || ', ItemCode=' ||
				pcardrow.itemcode || ', pSaveRollback=' || htools.bool2str(psaverollback));
		vcard := pcardrow;
	
		IF vcard.pan IS NULL
		   OR vcard.mbr IS NULL
		THEN
			error.raiseerror('Define card to be added to contract');
		END IF;
		IF NOT card.cardexists(vcard.pan, vcard.mbr)
		THEN
			error.raiseerror('Selected card does not exist');
		END IF;
		IF vcard.cardproduct IS NULL
		THEN
			error.raiseerror('Define card product');
		END IF;
	
		t.var('[1] vCard.CardType', vcard.cardtype);
		vcardtype := contracttools.getcardtype(vcard.pan, vcard.mbr, FALSE);
		t.var('vCardType', vcardtype);
		IF vcardtype IS NOT NULL
		THEN
			vcard.cardtype := vcardtype;
		END IF;
	
		IF NOT contractcard.existscardproduct(vcard.cardproduct, pcontractrow.type, NULL)
		THEN
			error.raiseerror('Card product <' || referencecardproduct.getname(vcard.cardproduct) ||
							 '> is absent from settings of current contract type');
		END IF;
		IF contract.getcontractnobycard(vcard.pan, vcard.mbr, FALSE) IS NOT NULL
		THEN
			error.raiseerror('Unable to add card belonging to another contract');
		END IF;
	
		IF vcard.itemcode IS NULL
		THEN
			err.seterror(0, cmethod_name);
			vcard.itemcode := contractcard.getitemcodebycardproduct(pcontractrow.type
																   ,vcard.cardproduct
																   ,pcardtype => vcard.cardtype);
			error.raisewhenerr();
		END IF;
	
		linkexistingcard2contract(vcard, pcontractrow, psaverollback, psavelog);
	
		vacardlist := complexcard.getlinkedcardlist(vcard.pan, vcard.mbr);
		FOR i IN 1 .. vacardlist.count
		LOOP
			vcard.pan := vacardlist(i).pan;
			vcard.mbr := vacardlist(i).mbr;
		
			linkexistingcard2contract(vcard, pcontractrow, psaverollback, psavelog);
		END LOOP;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE createlinkcard2cns
	(
		pcontracttype NUMBER
	   ,ppan          VARCHAR2
	   ,pmbr          NUMBER
	   ,pitemcode     NUMBER
	   ,pidclient     NUMBER
	   ,pcmsparams    typecmsparams
	   ,psaverollback IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateLinkCard2CNS';
		vidcns     NUMBER;
		vidcnscard NUMBER;
	
	BEGIN
		s.say(cmethod_name || ': CMSProfile ' || pcmsparams.cmsprofile, csay_level);
	
		cns.createcns(pcmsparams.cmsprofile
					 ,pidclient
					 ,pcmsparams.cmsscheme
					 ,pcmsparams.cmschannel
					 ,pcmsparams.cmsaddress
					 ,ppan
					 ,pmbr
					 ,vidcns
					 ,vidcnscard
					 ,pstatus               => pcmsparams.cmsactive
					 ,paccountno            => pcmsparams.accountno
					 ,pdisabled             => pcmsparams.disabled
					 ,pusefordynauth        => pcmsparams.usedynauth
					 ,pisdefault            => pcmsparams.usedefdynauth
					 ,pbranchpart           => pcmsparams.branchpart);
	
		IF vidcnscard IS NOT NULL
		   AND psaverollback
		THEN
			contractrb.setlabel(crl_create_cns);
			contractrb.setnvalue(ckey_cnsid, vidcnscard);
			contractrb.setcvalue(ckey_pan, ppan);
			contractrb.setnvalue(ckey_mbr, pmbr);
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ': general exception, ' || SQLERRM, csay_level);
			error.save(cmethod_name);
			RAISE;
	END createlinkcard2cns;

	PROCEDURE createcardaccountlinks
	(
		pcontractno   IN tcontract.no%TYPE
	   ,ppan          IN tcard.pan%TYPE
	   ,pmbr          IN tcard.mbr%TYPE
	   ,psaverollback IN BOOLEAN := FALSE
	   ,puseonline    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateCardAccountLinks';
		vaacc2cardlist    apitypes.typeaccount2cardlist;
		vacardaccountlist apitypes.typeaccount2cardlist;
		vpackage          contractschemas.typeschemapackagename;
		voldacc2cardlink  apitypes.typeaccount2cardrecord;
		vmainaccount      taccount.accountno%TYPE;
	
		vgroup NUMBER;
	
		vprevcontract         tcontract.no%TYPE;
		vaprevcardaccountlist apitypes.typeaccount2cardlist;
		vbasecontract         tcontract.no%TYPE;
	
		FUNCTION existacc2cardlink
		(
			ppan             IN tcard.pan%TYPE
		   ,pmbr             IN tcard.mbr%TYPE
		   ,poacc2cardrecord IN OUT apitypes.typeaccount2cardrecord
		) RETURN BOOLEAN IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExistAcc2CardLink';
			vlink apitypes.typeaccount2cardrecord;
			vret  BOOLEAN;
		BEGIN
			t.enter(cmethod_name
				   ,'pPAN=' || card.getmaskedpan(ppan) || ', pMBR=' || pmbr || ', pAccountNo=' ||
					poacc2cardrecord.accountno
				   ,plevel => csay_level);
			BEGIN
				vlink            := card.getlinkbyaccount(ppan, pmbr, poacc2cardrecord.accountno);
				poacc2cardrecord := vlink;
				vret             := vlink.accountno = poacc2cardrecord.accountno;
			EXCEPTION
				WHEN no_data_found THEN
					vret := FALSE;
				WHEN OTHERS THEN
					RAISE;
			END;
			t.leave(cmethod_name, 'vRet=' || t.b2t(vret), plevel => csay_level);
			RETURN vret;
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name, plevel => csay_level);
				error.save(cmethod_name);
				RAISE;
		END;
	
		FUNCTION existlinkaccount
		(
			panewlinklist IN apitypes.typeaccount2cardlist
		   ,paccountno    IN taccount.accountno%TYPE
		) RETURN BOOLEAN IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExistLinkAccount';
			vret BOOLEAN;
		BEGIN
			t.enter(cmethod_name
				   ,'paNewLinkList.count=' || panewlinklist.count || ', pAccountNo=' || paccountno
				   ,plevel => csay_level);
			vret := FALSE;
			FOR i IN 1 .. panewlinklist.count
			LOOP
				IF panewlinklist(i).accountno = paccountno
				THEN
					vret := TRUE;
					EXIT;
				END IF;
			END LOOP;
			t.leave(cmethod_name, 'vRet=' || t.b2t(vret), plevel => csay_level);
			RETURN vret;
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name, plevel => csay_level);
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE addrollbackdata4link
		(
			poldlink      IN apitypes.typeaccount2cardrecord
		   ,pactiontype   IN PLS_INTEGER
		   ,psaverollback IN BOOLEAN := FALSE
		) IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddRollBackData4Link';
		BEGIN
			t.enter(cmethod_name
				   ,'pOldLink.AccountNo=' || poldlink.accountno || ', pOldLink.ACCT_STAT=' ||
					poldlink.acct_stat || ', pActionType=' || pactiontype || ', pSaveRollback=' ||
					t.b2t(psaverollback)
				   ,plevel => csay_level);
			IF nvl(psaverollback, FALSE)
			THEN
			
				IF pactiontype NOT IN (c_a2c_create, c_a2c_delete, c_a2c_update)
				THEN
					error.raiseerror('Undefined action: [' || pactiontype || ']');
				END IF;
			
				contractrb.setnextcvalue(ckey_a2c_action, pactiontype);
				contractrb.setnextcvalue(ckey_a2c_no, poldlink.accountno);
				contractrb.setnextcvalue(ckey_a2c_stat, poldlink.acct_stat);
				contractrb.setnextcvalue(ckey_a2c_descr, nvl(poldlink.description, 'null'));
				contractrb.setnextnvalue(ckey_a2c_limitgrp, nvl(poldlink.limitgrpid, -1));
			END IF;
			t.leave(cmethod_name, plevel => csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name, plevel => csay_level);
				error.save(cmethod_name);
				RAISE;
		END;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pPAN=' || card.getmaskedpan(ppan) || ', pMBR=' || pmbr ||
				', pSaveRollback=' || t.b2t(psaverollback) || ', pUseOnline=' || t.b2t(puseonline)
			   ,plevel => csay_level);
		vpackage := contracttype.getschemapackage(contract.gettype(pcontractno));
		t.var(cmethod_name, 'vPackage=' || vpackage, csay_level);
		vgroup := referencegroupcontract.getgroupbycontract(pcontractno);
		t.var('vGroup', vgroup);
	
		IF contractschemas.operationimplemented(vpackage, contractschemas.c_contractcardaccount_get)
		THEN
		
			vacardaccountlist := contracttypeschema.getcardaccountlist(pcontractno);
		
			err.seterror(0, cmethod_name);
			vmainaccount := contracttypeschema.getmainaccount(pcontractno, NULL);
			t.var('vMainAccount', vmainaccount);
		
			IF psaverollback
			THEN
				contractrb.setlabel(crl_create_cardlink);
				contractrb.setcvalue(ckey_pan, ppan);
				contractrb.setnvalue(ckey_mbr, pmbr);
			END IF;
		
			vprevcontract := getcontractnobycard(ppan, pmbr, FALSE);
			t.var('vPrevContract', vprevcontract);
			IF vprevcontract IS NOT NULL
			   AND vprevcontract != pcontractno
			THEN
				vpackage := contracttype.getschemapackage(contract.gettype(vprevcontract));
				IF contractschemas.operationimplemented(vpackage
													   ,contractschemas.c_contractcardaccount_get)
				THEN
				
					vaprevcardaccountlist := contracttypeschema.getcardaccountlist(vprevcontract);
				END IF;
			END IF;
			err.seterror(0, cmethod_name);
			vbasecontract := referencegroupcontract.getbasecontract(vgroup);
			t.var('vBaseContract', vbasecontract);
			err.seterror(0, cmethod_name);
		
			vaacc2cardlist := card.getaccountlist(ppan, pmbr);
			t.var('vaAcc2CardList.Count', vaacc2cardlist.count);
			FOR j IN 1 .. vaacc2cardlist.count
			LOOP
				t.var('[0] vaAcc2CardList(j).AccountNo', vaacc2cardlist(j).accountno);
				IF vaacc2cardlist(j).acct_stat = referenceacct_stat.stat_primary
				THEN
				
					voldacc2cardlink := vaacc2cardlist(j);
					t.var('[1] vOldAcc2CardLink.AccountNo', voldacc2cardlink.accountno);
					IF (vgroup IS NOT NULL AND pcontractno = vbasecontract OR vgroup IS NULL)
					   AND voldacc2cardlink.accountno IS NOT NULL
					   AND voldacc2cardlink.accountno != vmainaccount
					THEN
					
						addrollbackdata4link(voldacc2cardlink, c_a2c_update, psaverollback);
						card.createlinkaccount(ppan
											  ,pmbr
											  ,vmainaccount
											  ,referenceacct_stat.stat_primary
											  ,pcheckprimaryaccount            => FALSE
											  ,paddtocontract                  => FALSE
											  ,puseonline                      => nvl(puseonline
																					 ,FALSE));
						error.raisewhenerr();
						t.note(cmethod_name
							  ,'created primary link to account,vMainAccount=' || vmainaccount
							  ,csay_level);
						card.deletelinkaccount(ppan
											  ,pmbr
											  ,vaacc2cardlist      (j).accountno
											  ,pcheckprimaryaccount => FALSE);
						error.raisewhenerr();
						t.note(cmethod_name
							  , 'deleted primary link to account, vaAcc2CardList(j).AccountNo=' || vaacc2cardlist(j)
							   .accountno
							  ,csay_level);
					END IF;
				ELSE
				
					IF vaprevcardaccountlist.count > 0
					   AND existlinkaccount(vaprevcardaccountlist, vaacc2cardlist(j).accountno)
					   AND vprevcontract != pcontractno
					THEN
					
						addrollbackdata4link(vaacc2cardlist(j), c_a2c_delete, psaverollback);
						card.deletelinkaccount(ppan
											  ,pmbr
											  ,vaacc2cardlist      (j).accountno
											  ,pcheckprimaryaccount => FALSE
											  ,puseonline           => nvl(puseonline, FALSE));
						error.raisewhenerr();
						t.note(cmethod_name
							  , 'deleted link to account, vaAcc2CardList(j).AccountNo=' || vaacc2cardlist(j)
							   .accountno
							  ,csay_level);
					END IF;
				END IF;
			END LOOP;
		
			t.var('vaCardAccountList.count', vacardaccountlist.count);
			FOR i IN 1 .. vacardaccountlist.count
			LOOP
				t.var('AccountNo', vacardaccountlist(i).accountno);
			
				vacardaccountlist(i).acct_stat := referenceacct_stat.stat_open;
				addrollbackdata4link(vacardaccountlist(i), c_a2c_create, psaverollback);
				card.createlinkaccount(ppan
									  ,pmbr
									  ,vacardaccountlist   (i).accountno
									  ,vacardaccountlist   (i).acct_stat
									  ,pcheckprimaryaccount => FALSE
									  ,paddtocontract       => FALSE
									  ,puseonline           => nvl(puseonline, FALSE));
				t.note(cmethod_name
					  , 'created link to account, vaCardAccountList(i).AccountNo=' || vacardaccountlist(i)
					   .accountno
					  ,csay_level);
				error.raisewhenerr();
			
			END LOOP;
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE movecarditem
	(
		ppan          IN tcard.pan%TYPE
	   ,pmbr          IN tcard.mbr%TYPE
	   ,ptocontract   IN tcontract.no%TYPE
	   ,psaverollback IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.MoveCardItem';
	
		vcardrow     typecardparams;
		vcode        NUMBER;
		voldcontract typecontractitemrecord;
	BEGIN
		t.enter(cmethod_name
			   ,'pPAN=' || card.getmaskedpan(ppan) || '-' || pmbr || ', pToContract=' ||
				ptocontract || ', pSaveRollback=' || t.b2t(psaverollback)
			   ,csay_level);
	
		vcardrow.pan := ppan;
		vcardrow.mbr := pmbr;
	
		vcode := card.getcardrecord(ppan, pmbr).cardproduct;
	
		IF vcode IS NULL
		THEN
			error.raiseerror('For card ' || getcardno(ppan, pmbr) || ' card product not found');
		END IF;
	
		vcardrow.cardtype := contracttools.getcardtype(ppan, pmbr);
		t.var('vCardRow.CardType', vcardrow.cardtype);
	
		vcardrow.itemcode := contractcard.getitemcodebycardproduct(gettype(ptocontract)
																  ,vcode
																  ,pcardtype => vcardrow.cardtype);
		t.var('vCardRow.ItemCode', vcardrow.itemcode);
		IF vcardrow.itemcode IS NULL
		THEN
			IF err.geterrorcode() = err.refct_undefined_cardproduct
			THEN
				error.raiseerror('No card product "' || referencecardproduct.getname(vcode) ||
								 '" in receiving contract type.');
			ELSE
				error.raisewhenerr();
			END IF;
		END IF;
	
		voldcontract := getcontractbycard(ppan, pmbr, FALSE);
		t.var(voldcontract.contractno);
		IF voldcontract.contractno IS NOT NULL
		   AND contractexists(voldcontract.contractno)
		THEN
			vcardrow.itemcode := voldcontract.itemcode;
			deletecarditem(voldcontract.contractno, ppan, pmbr);
		END IF;
	
		IF psaverollback
		THEN
			contractrb.setlabel(crl_move_cardlink);
			contractrb.setcvalue(ckey_pan, ppan);
			contractrb.setnvalue(ckey_mbr, pmbr);
			contractrb.setnvalue(ckey_itemcode, nvl(vcardrow.itemcode, -1));
			contractrb.setcvalue(ckey_cono, nvl(voldcontract.contractno, 'null'));
		END IF;
	
		addcontractitem(ptocontract, vcardrow);
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE convertcardinfo
	(
		pcardinfo IN card.typefullcardinfo
	   ,pcardrow  IN OUT typecardparams
	) IS
	BEGIN
		pcardrow.pan          := pcardinfo.card.pan;
		pcardrow.mbr          := pcardinfo.card.mbr;
		pcardrow.cardproduct  := pcardinfo.card.cardproduct;
		pcardrow.insure       := pcardinfo.card.insure;
		pcardrow.orderdate    := pcardinfo.card.orderdate;
		pcardrow.canceldate   := pcardinfo.card.canceldate;
		pcardrow.currencyno   := pcardinfo.card.currencyno;
		pcardrow.finprofile   := pcardinfo.card.finprofile;
		pcardrow.pinoffset    := pcardinfo.card.pinoffset;
		pcardrow.cvv          := pcardinfo.card.cvv;
		pcardrow.cvv2         := pcardinfo.card.cvv2;
		pcardrow.branchpart   := pcardinfo.card.branchpart;
		pcardrow.nameoncard   := pcardinfo.card.nameoncard;
		pcardrow.idclient     := pcardinfo.card.idclient;
		pcardrow.userproperty := pcardinfo.userproplist;
		pcardrow.ecstatus     := pcardinfo.card.ecstatus;
		pcardrow.grplimit     := pcardinfo.card.grplimit;
		pcardrow.ipvv         := pcardinfo.card.ipvv;
		pcardrow.externalid   := pcardinfo.card.externalid;
	END;

	FUNCTION convert2cardinfo(pcardrow IN typecardparams) RETURN card.typefullcardinfo IS
		vcardinfo card.typefullcardinfo;
	BEGIN
		vcardinfo.card.pan         := pcardrow.pan;
		vcardinfo.card.mbr         := pcardrow.mbr;
		vcardinfo.card.cardproduct := pcardrow.cardproduct;
		vcardinfo.card.insure      := pcardrow.insure;
		vcardinfo.card.orderdate   := pcardrow.orderdate;
		vcardinfo.card.canceldate  := pcardrow.canceldate;
		vcardinfo.card.currencyno  := pcardrow.currencyno;
		vcardinfo.card.finprofile  := pcardrow.finprofile;
		vcardinfo.card.pinoffset   := pcardrow.pinoffset;
		vcardinfo.card.cvv         := pcardrow.cvv;
		vcardinfo.card.cvv2        := pcardrow.cvv2;
		vcardinfo.card.branchpart  := pcardrow.branchpart;
		vcardinfo.card.nameoncard  := pcardrow.nameoncard;
		vcardinfo.card.idclient    := pcardrow.idclient;
		vcardinfo.userproplist     := pcardrow.userproperty;
		vcardinfo.card.ecstatus    := pcardrow.ecstatus;
		vcardinfo.card.grplimit    := pcardrow.grplimit;
		vcardinfo.card.ipvv        := pcardrow.ipvv;
		vcardinfo.card.externalid  := pcardrow.externalid;
		RETURN vcardinfo;
	END;

	FUNCTION getcardparams
	(
		ppan                   tcard.pan%TYPE := NULL
	   ,pmbr                   tcard.mbr%TYPE := NULL
	   ,pcardproduct           tcard.cardproduct%TYPE := NULL
	   ,pinsure                tcard.insure%TYPE := NULL
	   ,porderdate             tcard.orderdate%TYPE := NULL
	   ,pcanceldate            tcard.canceldate%TYPE := NULL
	   ,pcurrencyno            tcard.currencyno%TYPE := NULL
	   ,pfinprofile            tcard.finprofile%TYPE := NULL
	   ,ppinoffset             tcard.pinoffset%TYPE := NULL
	   ,pcvv                   tcard.cvv%TYPE := NULL
	   ,pcvv2                  tcard.cvv2%TYPE := NULL
	   ,pbranchpart            tcard.branchpart%TYPE := NULL
	   ,pnameoncard            tcard.nameoncard%TYPE := NULL
	   ,pidclient              tcard.idclient%TYPE := NULL
	   ,pitemcode              NUMBER := NULL
	   ,pchangeidclient        BOOLEAN := FALSE
	   ,puserproperty          apitypes.typeuserproplist := semptyrec
	   ,pecstatus              tcard.ecstatus%TYPE := NULL
	   ,pgrplimit              tcard.grplimit%TYPE := NULL
	   ,pipvv                  tcard.ipvv%TYPE := NULL
	   ,pnewidclient           tcard.idclient%TYPE := NULL
	   ,pcardtype              tcontractcard.cardtype%TYPE := NULL
	   ,pcreatetype            tcontractcard.cardhow%TYPE := NULL
	   ,pexternalid            tcard.externalid%TYPE := NULL
	   ,plink2existingcontract BOOLEAN := FALSE
	   ,puseonline             BOOLEAN := FALSE
	) RETURN typecardparams IS
		vret typecardparams;
	BEGIN
		vret.pan                   := ppan;
		vret.mbr                   := pmbr;
		vret.cardproduct           := pcardproduct;
		vret.insure                := pinsure;
		vret.orderdate             := porderdate;
		vret.canceldate            := pcanceldate;
		vret.currencyno            := pcurrencyno;
		vret.finprofile            := pfinprofile;
		vret.pinoffset             := ppinoffset;
		vret.cvv                   := pcvv;
		vret.cvv2                  := pcvv2;
		vret.branchpart            := pbranchpart;
		vret.nameoncard            := pnameoncard;
		vret.idclient              := pidclient;
		vret.itemcode              := pitemcode;
		vret.changeidclient        := nvl(pchangeidclient, FALSE);
		vret.userproperty          := puserproperty;
		vret.ecstatus              := pecstatus;
		vret.grplimit              := pgrplimit;
		vret.ipvv                  := pipvv;
		vret.newidclient           := pnewidclient;
		vret.cardtype              := pcardtype;
		vret.createtype            := pcreatetype;
		vret.externalid            := pexternalid;
		vret.link2existingcontract := nvl(plink2existingcontract, FALSE);
		vret.useonline             := nvl(puseonline, FALSE);
	
		RETURN vret;
	END;

	FUNCTION getcardparams
	(
		pcardinfo              card.typefullcardinfo
	   ,pitemcode              NUMBER := NULL
	   ,pchangeidclient        BOOLEAN := FALSE
	   ,pnewidclient           tcard.idclient%TYPE := NULL
	   ,pcardtype              tcontractcard.cardtype%TYPE := NULL
	   ,pcreatetype            tcontractcard.cardhow%TYPE := NULL
	   ,plink2existingcontract BOOLEAN := FALSE
	   ,puseonline             BOOLEAN := FALSE
	) RETURN typecardparams IS
		vret typecardparams;
	BEGIN
		vret := getcardparams(ppan                   => pcardinfo.card.pan
							 ,pmbr                   => pcardinfo.card.mbr
							 ,pcardproduct           => pcardinfo.card.cardproduct
							 ,pinsure                => pcardinfo.card.insure
							 ,porderdate             => pcardinfo.card.orderdate
							 ,pcanceldate            => pcardinfo.card.canceldate
							 ,pcurrencyno            => pcardinfo.card.currencyno
							 ,pfinprofile            => pcardinfo.card.finprofile
							 ,ppinoffset             => pcardinfo.card.pinoffset
							 ,pcvv                   => pcardinfo.card.cvv
							 ,pcvv2                  => pcardinfo.card.cvv2
							 ,pbranchpart            => pcardinfo.card.branchpart
							 ,pnameoncard            => pcardinfo.card.nameoncard
							 ,pidclient              => pcardinfo.card.idclient
							 ,pitemcode              => pitemcode
							 ,pchangeidclient        => pchangeidclient
							 ,puserproperty          => pcardinfo.userproplist
							 ,pecstatus              => pcardinfo.card.ecstatus
							 ,pgrplimit              => pcardinfo.card.grplimit
							 ,pipvv                  => pcardinfo.card.ipvv
							 ,pnewidclient           => pnewidclient
							 ,pcardtype              => pcardtype
							 ,pcreatetype            => pcreatetype
							 ,pexternalid            => pcardinfo.card.externalid
							 ,plink2existingcontract => plink2existingcontract
							 ,puseonline             => puseonline);
		RETURN vret;
	END;

	PROCEDURE createcardlink
	(
		pcreatemode      IN NUMBER
	   ,pcontractrow     IN typecontractparams
	   ,pissuecardparams IN typecardparams
	   ,pcmsparams       IN typecmsparams := NULL
	   ,psaverollback    IN BOOLEAN := FALSE
	)
	
	 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateCardLink';
		vret NUMBER;
	
		vidclient      tcard.idclient%TYPE := NULL;
		voldbranchpart tcard.branchpart%TYPE := NULL;
		vnewbranchpart tcard.branchpart%TYPE := NULL;
	
		vpackage       contractschemas.typeschemapackagename;
		vmulticurrency BOOLEAN := FALSE;
	
		vcard typecardparams;
	
	BEGIN
		t.enter(cmethod_name
			   ,'mode=' || pcreatemode || ',pContractRow.No=' || pcontractrow.no || ', type=' ||
				pcontractrow.type || ', ItemCode=' || pissuecardparams.itemcode ||
				', pSaveRollback=' || htools.bool2str(psaverollback));
		vcard := pissuecardparams;
		t.var('vCard.CardProduct', vcard.cardproduct);
	
		vpackage := contracttype.getschemapackage(contract.gettype(pcontractrow.no));
		t.var(cmethod_name, 'vPackage=' || vpackage, csay_level);
		vmulticurrency := contractschemas.operationimplemented(vpackage
															  ,contractschemas.c_contractcardaccount_get);
	
		IF pcreatemode = contractcard.newlink
		THEN
			IF vcard.idclient IS NULL
			THEN
				vcard.idclient := card.getcardrecord(vcard.pan, vcard.mbr).idclient;
			END IF;
		
			IF vmulticurrency
			THEN
				createcardaccountlinks(pcontractrow.no
									  ,vcard.pan
									  ,vcard.mbr
									  ,psaverollback
									  ,nvl(vcard.useonline, FALSE));
			ELSE
				t.note(cmethod_name, 'deleting link ', csay_level);
				deleteprimarylink(vcard.pan, vcard.mbr, psaverollback);
			END IF;
		
			s.say(cmethod_name || ': change client id ' || htools.bool2str(vcard.changeidclient)
				 ,csay_level);
			s.say(cmethod_name || ': client id ' || vcard.idclient, csay_level);
		
			vidclient := nvl(vcard.newidclient, pcontractrow.idclient);
			s.say(cmethod_name || ': searching card owner (vCard.NewIdClient=' ||
				  vcard.newidclient || ', pContractRow.IdClient=' || pcontractrow.idclient ||
				  ') vIdClient=' || vidclient
				 ,csay_level);
			IF vcard.changeidclient
			   AND vidclient != vcard.idclient
			THEN
				s.say(cmethod_name || ': changing card owner (vCard.IdClient=' || vcard.idclient ||
					  '->vIdClient=' || vidclient || ')'
					 ,csay_level);
			
				changecardidclient(vcard.pan, vcard.mbr, vidclient);
				IF psaverollback
				THEN
					contractrb.setnvalue(ckey_idclient, vcard.idclient);
				END IF;
				vcard.idclient := vidclient;
			
			END IF;
			voldbranchpart := card.getcardrecord(vcard.pan, vcard.mbr).branchpart;
			IF (vcard.branchpart IS NOT NULL)
			THEN
				vnewbranchpart := vcard.branchpart;
			ELSE
				IF (contractcard.getusecontractbranchpart(pcontractrow.type, vcard.itemcode))
				THEN
					vnewbranchpart := pcontractrow.branchpart;
				END IF;
			END IF;
			IF vnewbranchpart IS NOT NULL
			   AND vnewbranchpart != voldbranchpart
			THEN
				s.say(cmethod_name || ': changing card BranchPart ', csay_level);
				changecardbranchpart(vcard.pan, vcard.mbr, vnewbranchpart);
				IF psaverollback
				THEN
					contractrb.setnvalue(ckey_branchpart, voldbranchpart);
				END IF;
				vcard.branchpart := vnewbranchpart;
			END IF;
		END IF;
	
		IF vmulticurrency
		THEN
			movecarditem(vcard.pan, vcard.mbr, pcontractrow.no, psaverollback);
		ELSE
			createlinkcard2contract(pcreatemode, pcontractrow.no, vcard, psaverollback);
		END IF;
	
		s.say(cmethod_name || ': creating CMS ' || htools.bool2str(pcmsparams.createcms)
			 ,csay_level);
		IF pcmsparams.createcms
		THEN
			createlinkcard2cns(pcontractrow.type
							  ,vcard.pan
							  ,vcard.mbr
							  ,vcard.itemcode
							  ,vcard.idclient
							  ,pcmsparams
							  ,psaverollback);
		END IF;
	
		vret := a4mlog.logobject(object.gettype(contract.object_name)
								,pcontractrow.no
								,'Added existing card'
								,a4mlog.act_add
								,a4mlog.putparamlist()
								,powner => getclientid(pcontractrow.no));
	
		IF vret != 0
		THEN
			error.raisewhenerr();
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcard2accountlink
	(
		pitemcode   IN tcontractitem.itemcode%TYPE
	   ,pcontractno IN tcontract.no%TYPE
	) RETURN tacc2card%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCard2AccountLink';
		vret    tacc2card%ROWTYPE;
		cbranch NUMBER := seance.getbranch();
	
		CURSOR c1
		(
			pitemcode   IN tcontractitem.itemcode%TYPE
		   ,pcontractno IN tcontract.no%TYPE
		) IS
			SELECT ci.itemcode
				  ,ci.key
				  ,cca.accstatus
				  ,cca.description
			FROM   tcontractitem    ci
				  ,tcontractcardacc cca
			WHERE  cca.branch = cbranch
			AND    cca.code = pitemcode
			AND    cca.accstatus = referenceacct_stat.stat_primary
			AND    ci.branch = cca.branch
			AND    ci.no = pcontractno
			AND    ci.itemcode = cca.acccode;
	BEGIN
	
		t.enter(cmethod_name);
		t.inpar('pItemCode', pitemcode);
		t.inpar('pContractNo', pcontractno);
	
		FOR i IN c1(pitemcode, pcontractno)
		LOOP
			vret.accountno   := i. key;
			vret.acct_stat   := i.accstatus;
			vret.description := i.description;
			EXIT;
		END LOOP;
	
		t.leave(cmethod_name, 'vRet.AccountNo=' || vret.accountno);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE createcards
	(
		pcreatemode      IN NUMBER
	   ,pcontractrow     IN typecontractparams
	   ,pissuecardparams IN OUT typecardparams
	   ,pcmsparams       IN typecmsparams := NULL
	   ,psaverollback    IN BOOLEAN := FALSE
	)
	
	 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateCards';
		vcardinfolist card.typefullcardinfolist;
	
		vacc2cardrow   tacc2card%ROWTYPE;
		vidclient      tcard.idclient%TYPE;
		vmulticurrency BOOLEAN := FALSE;
		vpackage       contractschemas.typeschemapackagename;
		vcreatetype    NUMBER;
		vret           NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'pCreateMode=' || pcreatemode || ', No=' || pcontractrow.no || ', type=' ||
				pcontractrow.type || ', ItemCode=' || pissuecardparams.itemcode ||
				', CardProduct=' || pissuecardparams.cardproduct || ', PAN=' ||
				card.getmaskedpan(pissuecardparams.pan) || ', MBR=' || pissuecardparams.mbr ||
				', pSaveRollback=' || htools.bool2str(psaverollback));
	
		IF pcreatemode = contractcard.newcreate
		THEN
		
			IF pcontractrow.no IS NULL
			THEN
				error.raiseerror('Contract No not defined');
			END IF;
		
			IF pcontractrow.type IS NULL
			THEN
				error.raiseerror('Contract type not defined');
			END IF;
		
			IF pissuecardparams.itemcode IS NULL
			THEN
				error.raiseerror('Not defined card product code for contract type ["' ||
								 pcontractrow.type || ']');
			END IF;
		
			IF NOT contractcard.getactive(pcontractrow.type, pissuecardparams.itemcode)
			THEN
				error.raiseerror('Card "' ||
								 referencecardproduct.getname(pissuecardparams.cardproduct) ||
								 '" not active for issue!');
			END IF;
		
			vacc2cardrow := getcard2accountlink(pissuecardparams.itemcode, pcontractrow.no);
		
			IF vacc2cardrow.accountno IS NULL
			THEN
				error.raiseerror('Impossible to add card "' ||
								 referencecardproduct.getname(pissuecardparams.cardproduct) ||
								 '" to contract since card account is not created in contract yet');
			END IF;
		
			vidclient := nvl(pissuecardparams.newidclient
							,nvl(pissuecardparams.idclient, pcontractrow.idclient));
			t.note(cmethod_name
				  ,': searching card owner (pIssueCardParams.NewIdClient=' ||
				   pissuecardparams.newidclient || ', pIssueCardParams.IdClient=' ||
				   pissuecardparams.idclient || ' pContractRow.IdClient=' || pcontractrow.idclient ||
				   ') vIdClient=' || vidclient
				  ,csay_level);
		
			IF existnewcardlist(pissuecardparams.itemcode)
			THEN
				vcardinfolist := getnewcardlist(pissuecardparams.itemcode);
				t.var('[1] vCardInfoList.Count', vcardinfolist.count);
				FOR i IN 1 .. vcardinfolist.count
				LOOP
					t.var('[1] vCardInfoList(i).ContractItem'
						 ,vcardinfolist(i).contractitem
						 ,csay_level);
					IF vcardinfolist(i).accountlink.accountno IS NULL
					THEN
						vcardinfolist(i).accountlink := vacc2cardrow;
					END IF;
				END LOOP;
			ELSE
			
				IF pissuecardparams.cardtype IS NULL
				THEN
					pissuecardparams.cardtype := contractcard.getitem(pissuecardparams.itemcode, FALSE)
												 .cardtype;
				END IF;
			
				t.var('[1] pIssueCardParams.CardType', pissuecardparams.cardtype);
				vcardinfolist := card.preparecardlist(pwhat         => nvl(pissuecardparams.cardtype
																		  ,card.ccsprimary)
													 ,ppan          => pissuecardparams.pan
													 ,pmbr          => pissuecardparams.mbr
													 ,paccountno    => vacc2cardrow.accountno
													 ,pidclient     => vidclient
													 ,pcardproduct  => pissuecardparams.cardproduct
													 ,pcontracttype => pcontractrow.type
													 ,pcontractitem => pissuecardparams.itemcode
													 ,pcontractno   => pcontractrow.no);
				t.var('[2] vCardInfoList.Count', vcardinfolist.count);
			
				FOR i IN 1 .. vcardinfolist.count
				LOOP
				
					IF vcardinfolist(i).card.mainpan IS NULL
					THEN
					
						IF pissuecardparams.branchpart IS NOT NULL
						THEN
							vcardinfolist(i).card.branchpart := pissuecardparams.branchpart;
						ELSE
							IF contractcard.getusecontractbranchpart(pcontractrow.type
																	,pissuecardparams.itemcode)
							THEN
								vcardinfolist(i).card.branchpart := pcontractrow.branchpart;
							ELSE
								vcardinfolist(i).card.branchpart := nvl(vcardinfolist(i)
																		.card.branchpart
																	   ,seance.getbranchpart());
							END IF;
						END IF;
						t.var('vCardInfoList(' || i || ').Card.BranchPart'
							 ,vcardinfolist(i).card.branchpart);
					
						IF pissuecardparams.grplimit IS NULL
						   OR pissuecardparams.grplimit = 0
						THEN
							vcardinfolist(i).card.grplimit := contractcard.getgrplimit(pcontractrow.type
																					  ,pissuecardparams.itemcode);
							t.var('[1] vCardInfoList(i).Card.Grplimit'
								 ,vcardinfolist(i).card.grplimit
								 ,csay_level);
							IF vcardinfolist(i).card.grplimit IS NULL
							THEN
								vcardinfolist(i).card.grplimit := referencecardproduct.getdefaultlimit(pissuecardparams.cardproduct);
								t.var('[2] vCardInfoList(i).Card.Grplimit'
									 ,vcardinfolist(i).card.grplimit
									 ,csay_level);
							END IF;
						ELSE
							vcardinfolist(i).card.grplimit := pissuecardparams.grplimit;
							t.var('[3] vCardInfoList(i).Card.Grplimit'
								 ,vcardinfolist(i).card.grplimit
								 ,csay_level);
						END IF;
					
						vcardinfolist(i).card.currencyno := nvl(pissuecardparams.currencyno
															   ,nvl(contractcard.getlimitcurrency(pcontractrow.type
																								 ,pissuecardparams.itemcode)
																   ,referencecardproduct.getdefaultcurrency(pissuecardparams.cardproduct)));
						t.var('vCardInfoList(' || i || ').Card.CurrencyNo'
							 ,vcardinfolist(i).card.currencyno);
					
						IF pissuecardparams.finprofile IS NULL
						THEN
							vcardinfolist(i).card.finprofile := contractcard.getfinprofile(pcontractrow.type
																						  ,pissuecardparams.itemcode);
							IF vcardinfolist(i).card.finprofile IS NULL
							THEN
								vcardinfolist(i).card.finprofile := referencecardproduct.getfinprofile(pissuecardparams.cardproduct);
							END IF;
						ELSE
							vcardinfolist(i).card.finprofile := pissuecardparams.finprofile;
						END IF;
					
						IF pissuecardparams.insure IS NOT NULL
						THEN
							vcardinfolist(i).card.insure := pissuecardparams.insure;
						END IF;
						IF pissuecardparams.orderdate IS NOT NULL
						THEN
							vcardinfolist(i).card.orderdate := pissuecardparams.orderdate;
						END IF;
						IF pissuecardparams.canceldate IS NOT NULL
						THEN
							vcardinfolist(i).card.canceldate := pissuecardparams.canceldate;
						END IF;
						IF pissuecardparams.pinoffset IS NOT NULL
						THEN
							vcardinfolist(i).card.pinoffset := pissuecardparams.pinoffset;
						END IF;
						IF pissuecardparams.cvv IS NOT NULL
						THEN
							vcardinfolist(i).card.cvv := pissuecardparams.cvv;
						END IF;
						IF pissuecardparams.cvv2 IS NOT NULL
						THEN
							vcardinfolist(i).card.cvv2 := pissuecardparams.cvv2;
						END IF;
						IF pissuecardparams.cardproduct IS NOT NULL
						THEN
							vcardinfolist(i).card.cardproduct := pissuecardparams.cardproduct;
						END IF;
						IF pissuecardparams.nameoncard IS NOT NULL
						THEN
							vcardinfolist(i).card.nameoncard := pissuecardparams.nameoncard;
						END IF;
						IF pissuecardparams.ipvv IS NOT NULL
						THEN
							vcardinfolist(i).card.ipvv := pissuecardparams.ipvv;
						END IF;
						IF pissuecardparams.externalid IS NOT NULL
						THEN
							vcardinfolist(i).card.externalid := pissuecardparams.externalid;
						END IF;
						IF pissuecardparams.ecstatus IS NOT NULL
						THEN
							vcardinfolist(i).card.ecstatus := pissuecardparams.ecstatus;
						END IF;
						IF vcardinfolist(i).card.cardproduct IS NOT NULL
						THEN
							vcardinfolist(i).card.grplimitint := referencecardproduct.getdefaultlimit2(vcardinfolist(i)
																									   .card.cardproduct);
						END IF;
					
						IF pissuecardparams.userproperty.count > 0
						THEN
							vcardinfolist(i).userproplist := pissuecardparams.userproperty;
						END IF;
					
					END IF;
					t.var('vCardInfoList(i).ContractItem'
						 ,vcardinfolist(i).contractitem
						 ,csay_level);
				END LOOP;
			
			END IF;
		
			t.var('[2] pIssueCardParams.CardType', pissuecardparams.cardtype);
			card.createcardbyfullinfolist(nvl(pissuecardparams.cardtype, card.ccsprimary)
										 ,vcardinfolist);
		
			vpackage := contracttype.getschemapackage(pcontractrow.type);
			t.var(cmethod_name, 'vPackage=' || vpackage, csay_level);
		
			vmulticurrency := contractschemas.operationimplemented(vpackage
																  ,contractschemas.c_contractcardaccount_get);
			vcreatetype    := contractcard.getcreatetype(pcontractrow.type
														,pissuecardparams.itemcode);
			t.var('vCreateType', vcreatetype, csay_level);
			FOR i IN 1 .. vcardinfolist.count
			LOOP
				IF vmulticurrency
				THEN
					movecarditem(vcardinfolist  (i).card.pan
								,vcardinfolist  (i).card.mbr
								,pcontractrow.no
								,psaverollback);
				ELSE
					createlinkcard2contract(contractcard.newcreate
										   ,pcontractrow.no
										   ,getcardparams(vcardinfolist(i)
														 ,pitemcode => pissuecardparams.itemcode
														 ,puseonline => pissuecardparams.useonline));
				END IF;
			
				t.note(cmethod_name
					  ,': creating CMS ' || htools.bool2str(pcmsparams.createcms)
					  ,csay_level);
				IF pcmsparams.createcms
				THEN
					createlinkcard2cns(pcontractrow.type
									  ,vcardinfolist            (i).card.pan
									  ,vcardinfolist            (i).card.mbr
									  ,pissuecardparams.itemcode
									  ,vcardinfolist            (i).card.idclient
									  ,pcmsparams
									  ,psaverollback);
				END IF;
			
				a4mlog.cleanparamlist;
				a4mlog.addparamrec(clogparam_pan, vcardinfolist(i).card.pan);
				a4mlog.addparamrec(clogparam_mbr, vcardinfolist(i).card.mbr);
				IF vcreatetype = card.ccsprimary
				THEN
					vret := a4mlog.logobject(object.gettype(contract.object_name)
											,pcontractrow.no
											,'New card created'
											,a4mlog.act_add
											,a4mlog.putparamlist()
											,powner => getclientid(pcontractrow.no));
				ELSIF vcreatetype = card.ccssupplementary
				THEN
					vret := a4mlog.logobject(object.gettype(contract.object_name)
											,pcontractrow.no
											,'New supplementary card created'
											,a4mlog.act_add
											,a4mlog.putparamlist()
											,powner => getclientid(pcontractrow.no));
				END IF;
				IF vret != 0
				THEN
					error.raisewhenerr();
				END IF;
			
				t.var('vCardInfoList(i).Card.PAN', card.getmaskedpan(vcardinfolist(i).card.pan));
				t.var('vCardInfoList(i).Card.MBR', vcardinfolist(i).card.mbr);
				t.var('vCardInfoList(i).Card.MainPAN'
					 ,card.getmaskedpan(vcardinfolist(i).card.mainpan));
				IF vcardinfolist(i).card.mainpan IS NULL
				THEN
					pissuecardparams.pan := vcardinfolist(i).card.pan;
					pissuecardparams.mbr := vcardinfolist(i).card.mbr;
				END IF;
			END LOOP;
		ELSIF pcreatemode = contractcard.newlink
		THEN
			createcardlink(pcreatemode, pcontractrow, pissuecardparams, pcmsparams, psaverollback);
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION updateobjectuid(pcontractno IN tcontract.no%TYPE) RETURN NUMBER IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.UpdateObjectUID';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vobjectuid NUMBER;
	BEGIN
		s.say(cmethod_name || ': pContractNo= ' || pcontractno, csay_level);
		vobjectuid := objectuid.newuid(object_name, pcontractno, pnocommit => TRUE);
		UPDATE tcontract
		SET    objectuid = vobjectuid
		WHERE  branch = cbranch
		AND    no = pcontractno;
		COMMIT;
		s.say(cmethod_name || ': vObjectUID=' || to_char(vobjectuid), csay_level);
	
		RETURN vobjectuid;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethod_name);
			error.save(cmethod_name);
			ROLLBACK;
			RAISE;
	END;

	FUNCTION getconvertedrow
	(
		pcontractrow         IN tcontract%ROWTYPE
	   ,paddexistcard        IN BOOLEAN := NULL
	   ,paddexistacc         IN BOOLEAN := NULL
	   ,pchangeacccreatedate IN BOOLEAN := NULL
	   ,pchangecontracttype  IN BOOLEAN := NULL
	   ,pchangeaccounttype   IN BOOLEAN := NULL
	   ,pcheckidentacctype   IN BOOLEAN := NULL
	   ,pcheckidenttieracc   IN BOOLEAN := NULL
	   ,pchangecardstate     IN BOOLEAN := NULL
	   ,pchangefinprofile    IN BOOLEAN := NULL
	   ,pchangeidclient      IN BOOLEAN := NULL
	   ,pchangecardidclient  IN BOOLEAN := NULL
	   ,pcreateuserproperty  IN BOOLEAN := TRUE
	   ,pauserproplist       IN apitypes.typeuserproplist := semptyrec
	) RETURN typecontractparams IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetConvertedRow';
		vcontractrow typecontractparams;
	BEGIN
		vcontractrow.no         := pcontractrow.no;
		vcontractrow.type       := pcontractrow.type;
		vcontractrow.idclient   := pcontractrow.idclient;
		vcontractrow.createdate := pcontractrow.createdate;
		vcontractrow.branchpart := pcontractrow.branchpart;
		vcontractrow.objectuid  := pcontractrow.objectuid;
		vcontractrow.finprofile := pcontractrow.finprofile;
		vcontractrow.branchpart := pcontractrow.branchpart;
	
		vcontractrow.addexistcard        := paddexistcard;
		vcontractrow.addexistacc         := paddexistacc;
		vcontractrow.changeacccreatedate := pchangeacccreatedate;
		vcontractrow.changecontracttype  := pchangecontracttype;
		vcontractrow.changeaccounttype   := pchangeaccounttype;
		vcontractrow.checkidentacctype   := pcheckidentacctype;
		vcontractrow.checkidenttieracc   := pcheckidenttieracc;
		vcontractrow.changecardstate     := pchangecardstate;
		vcontractrow.changefinprofile    := pchangefinprofile;
		vcontractrow.changeidclient      := pchangeidclient;
		vcontractrow.changecardidclient  := pchangecardidclient;
		vcontractrow.createuserproperty  := pcreateuserproperty;
		vcontractrow.userproperty        := pauserproplist;
		RETURN vcontractrow;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE getcontractrow
	(
		pcontractno  VARCHAR2
	   ,ocontractrow OUT typecontractparams
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractRow';
		vcrow tcontract%ROWTYPE;
	BEGIN
		IF contracttools.getcontractrecord(pcontractno, vcrow) != 0
		THEN
			error.raisewhenerr();
		END IF;
	
		ocontractrow.no         := vcrow.no;
		ocontractrow.type       := vcrow.type;
		ocontractrow.idclient   := vcrow.idclient;
		ocontractrow.createdate := vcrow.createdate;
		ocontractrow.branchpart := vcrow.branchpart;
		IF vcrow.objectuid IS NULL
		THEN
			ocontractrow.objectuid := updateobjectuid(pcontractno);
		ELSE
			ocontractrow.objectuid := vcrow.objectuid;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcontractrow;

	PROCEDURE deleteorunlinkaccount
	(
		pcontractno   VARCHAR2
	   ,paccountno    VARCHAR2
	   ,pexistaccount IN typeexistaccountarr
	) IS
		cmethod_name CONSTANT VARCHAR2(40) := cpackage_name || '.DeleteOrUnlinkAccount';
		fdeleteacc BOOLEAN := TRUE;
	BEGIN
		s.say(cmethod_name || ': ' || paccountno, csay_level);
	
		FOR l IN 1 .. pexistaccount.count
		LOOP
			IF pexistaccount(l).accountno = paccountno
			THEN
				fdeleteacc := FALSE;
				s.say(cmethod_name || ': no need to delete, unlink ', csay_level);
				deleteaccountfromcontract(pcontractno, paccountno);
			
				IF pexistaccount(l).idclient IS NOT NULL
				THEN
					changeaccountidclient(paccountno, pexistaccount(l).idclient);
				END IF;
				EXIT;
			END IF;
		END LOOP;
	
		IF fdeleteacc
		THEN
			deleteaccountfromcontract(pcontractno, paccountno);
			account.deleteaccount(paccountno, FALSE);
		
			IF err.geterrorcode != 0
			THEN
				s.say(cmethod_name || ': error deleting ' || err.getfullmessage(), csay_level);
				error.saveraise(cmethod_name
							   ,err.geterrorcode
							   ,err.getfullmessage() || ' ' || paccountno);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END deleteorunlinkaccount;

	PROCEDURE deletecard
	(
		pcontractno    IN tcontract.no%TYPE
	   ,ppan           IN tcard.pan%TYPE
	   ,pmbr           IN tcard.mbr%TYPE
	   ,pmakelog       IN BOOLEAN := TRUE
	   ,pisinteractive IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DeleteCard2';
		vupdaterevision tcontract.updaterevision%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pPan=' || card.getmaskedpan(ppan) || ', pMbr=' || pmbr ||
				', pMakeLog=' || t.b2t(pmakelog)
			   ,csay_level);
		t.inpar('pIsInteractive', t.b2t(pisinteractive));
	
		vupdaterevision := getupdaterevision(pcontractno);
	
		IF nvl(getcontractnobycard(ppan, pmbr, FALSE), 'NULL') != pcontractno
		THEN
			error.raiseerror('Attempted deletion of card not belonging to contract (' ||
							 pcontractno || ')');
		END IF;
	
		IF card.deletecardcomplex(ppan
								 ,pmbr
								 ,pisinteractive => nvl(pisinteractive, TRUE)
								 ,plog           => nvl(pmakelog, TRUE))
		THEN
			NULL;
		END IF;
	
		IF NOT nvl(pisinteractive, TRUE)
		THEN
			error.raisewhenerr();
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			refreshrevision(pcontractno, caction_restore, vupdaterevision);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE deleteorunlinkcard
	(
		pcontractno IN tcontract.no%TYPE
	   ,pcardrow    IN typecardparams
	   ,pexistcard  IN typeexistcardarr
	   ,pcnsid      IN typecnsidarr
	   ,pmode       IN PLS_INTEGER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DeleteOrUnlinkCard';
		fdeletecard   BOOLEAN := TRUE;
		vidcns_client NUMBER := NULL;
		vidcns_card   NUMBER := NULL;
		vcardcnsrec   apitypes.typecardcnsrecord;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pContractNo', pcontractno);
		t.inpar('pCardRow.PAN', card.getmaskedpan(pcardrow.pan));
		t.inpar('pCardRow.MBR', pcardrow.mbr);
		t.inpar('pExistCard.count', pexistcard.count);
		t.inpar('pCNSId.count', pcnsid.count);
		t.inpar('pMode', pmode);
	
		FOR i IN 1 .. pcnsid.count
		LOOP
			s.say(cmethod_name || ': card CNS id ' || pcnsid(i), csay_level);
			vcardcnsrec := cns.getcardcnsrec(pcnsid(i));
			IF vcardcnsrec.pan = pcardrow.pan
			   AND vcardcnsrec.mbr = pcardrow.mbr
			THEN
				vidcns_client := vcardcnsrec.idcns;
				vidcns_card   := pcnsid(i);
				s.say(cmethod_name || ': client CNS id ' || vidcns_client, csay_level);
				s.say(cmethod_name || ': card CNS id ' || vidcns_card, csay_level);
				EXIT;
			END IF;
		END LOOP;
	
		IF vidcns_card IS NOT NULL
		THEN
			s.say(cmethod_name || ': delete card CNS ' || vidcns_card, csay_level);
			cns.deletecardcns(vidcns_card);
		END IF;
	
		FOR j IN 1 .. pexistcard.count
		LOOP
			IF pexistcard(j).pan = pcardrow.pan || pcardrow.mbr
			THEN
				fdeletecard := FALSE;
				s.say(cmethod_name || ': no need to delete ', csay_level);
			
				IF pexistcard(j).accountno IS NOT NULL
				THEN
					deleteprimarylink(pcardrow.pan, pcardrow.mbr, FALSE);
				
					s.say(cmethod_name || ': set link to old account ' || pexistcard(j).accountno
						 ,csay_level);
					card.createlinkaccount(pcardrow.pan
										  ,pcardrow.mbr
										  ,pexistcard                     (j).accountno
										  ,referenceacct_stat.stat_primary
										  ,pexistcard                     (j).description);
				END IF;
			
				IF pexistcard(j).contractno IS NOT NULL
				THEN
					s.say(cmethod_name || ': link to old contract ' || pexistcard(j).contractno
						 ,csay_level);
					createlinkcard2contract(contractcard.newlink
										   ,pexistcard(j).contractno
										   ,pcardrow);
				END IF;
			
				IF pexistcard(j).idclient IS NOT NULL
				THEN
					s.say(cmethod_name || ': link to old client ' || pexistcard(j).idclient
						 ,csay_level);
					changecardidclient(pcardrow.pan, pcardrow.mbr, pexistcard(j).idclient);
				END IF;
				IF pexistcard(j).branchpart IS NOT NULL
				THEN
					s.say(cmethod_name || ': link to old BranchPart ' || pexistcard(j).branchpart
						 ,csay_level);
					changecardbranchpart(pcardrow.pan, pcardrow.mbr, pexistcard(j).branchpart);
				END IF;
				EXIT;
			END IF;
		END LOOP;
	
		IF fdeletecard
		THEN
			IF nvl(pmode, c_rollbackmode) = c_interactivemode
			THEN
				deletecard(pcontractno, pcardrow.pan, pcardrow.mbr, TRUE, FALSE);
			ELSE
				deletecard(pcontractno, pcardrow.pan, pcardrow.mbr, FALSE, FALSE);
			END IF;
		END IF;
	
		IF vidcns_client IS NOT NULL
		THEN
			s.say(cmethod_name || ': delete client CNS ' || vidcns_client, csay_level);
			cns.deleteclientcnswithcheck(vidcns_client);
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END deleteorunlinkcard;

	PROCEDURE addcard(pdialog IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddCard[1]';
		vcontractrow    typecontractparams;
		vcardparams     typecardparams;
		vcardcount      NUMBER;
		vcreatemode     NUMBER;
		vupdaterevision tcontract.updaterevision%TYPE;
		vmark           CHAR(1);
	BEGIN
		t.enter(cmethod_name);
		err.seterror(0, cmethod_name);
		SAVEPOINT contractaddcard;
	
		vupdaterevision := getupdaterevisionbyhandle(dialog.getnumber(dialog.getowner(pdialog)
																	 ,'Handle'));
	
		s.say(cmethod_name || ': 1. vUpdateRevision=' || to_char(vupdaterevision), csay_level);
	
		getcontractrow(dialog.getchar(pdialog, 'No'), vcontractrow);
		vcontractrow.runcardcontrolblock := TRUE;
	
		vcardcount := dialog.getlistreccount(pdialog, 'Card');
		FOR i IN 1 .. vcardcount
		LOOP
			vcardparams := NULL;
			vmark       := service.getchar(dialog.getchar(pdialog, 'Card'), i);
			s.say(cmethod_name || ': vMark=[' || vmark || ']');
			IF rtrim(vmark) IS NOT NULL
			THEN
				vcardparams.itemcode := dialog.getrecordnumber(pdialog, 'Card', 'ItemCode', i);
				vcreatemode          := dialog.getrecordnumber(pdialog, 'Card', 'CreateMode', i);
				IF vcreatemode = contractcard.newcreate
				THEN
				
					vcardparams.userproperty := semptyrec;
					vcardparams.pan          := NULL;
					vcardparams.mbr          := NULL;
				
					vcardparams.cardproduct := dialog.getrecordnumber(pdialog
																	 ,'Card'
																	 ,'CardProduct'
																	 ,i);
					t.var('vCardParams.CardProduct', vcardparams.cardproduct);
					vcardparams.idclient := dialog.getrecordnumber(pdialog, 'Card', 'IdClient', i);
				
					vcardparams.finprofile := dialog.getrecordnumber(pdialog
																	,'Card'
																	,'FinProfile'
																	,i);
					vcardparams.grplimit   := dialog.getrecordnumber(pdialog, 'Card', 'GrpLimit', i);
					s.say(cmethod_name || ': vCardParams.GrpLimit=' || vcardparams.grplimit
						 ,csay_level);
					vcardparams.currencyno := dialog.getrecordnumber(pdialog
																	,'Card'
																	,'LimitCurrency'
																	,i);
					s.say(cmethod_name || ': vCardParams.LimitCurrency=' || vcardparams.currencyno
						 ,csay_level);
				
					vcardparams.cardtype := dialog.getnumber(pdialog, 'CreateType');
					t.var('vCardParams.CardType', vcardparams.cardtype);
				
				ELSE
					vcardparams.pan := dialog.getrecordchar(pdialog, 'Card', 'PAN', i);
					vcardparams.mbr := dialog.getrecordnumber(pdialog, 'Card', 'MBR', i);
				END IF;
			
				createcards(vcreatemode, vcontractrow, vcardparams);
			
			END IF;
		END LOOP;
		COMMIT;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			ROLLBACK TO contractaddcard;
			refreshrevision(vcontractrow.no, caction_restore, vupdaterevision);
			error.showerror();
			dialog.cancelclose(pdialog);
	END addcard;

	FUNCTION getprymarycardaccount(pcontractno tcontract.no%TYPE) RETURN taccount.accountno%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetPrymaryCardAccount';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		CURSOR c1 IS
			SELECT b.key
			FROM   tcontractitem    b
				  ,tcontractcardacc a
			WHERE  b.branch = cbranch
			AND    b.no = pcontractno
			AND    a.branch = b.branch
			AND    a.acccode = b.itemcode
			AND    a.accstatus = referenceacct_stat.stat_primary
			ORDER  BY b.itemcode;
	BEGIN
		FOR i IN c1
		LOOP
			RETURN i.key;
		END LOOP;
		RETURN NULL;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getprymarycardaccount;

	PROCEDURE getstrfromclob
	(
		pcomment IN CLOB
	   ,ostr     OUT VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetStrFromCLOB';
		vstr    VARCHAR2(255);
		vreaded NUMBER := 255;
		voffset NUMBER := 1;
	BEGIN
		ostr := NULL;
		LOOP
			BEGIN
				dbms_lob.read(pcomment, vreaded, voffset, vstr);
				s.say(cmethod_name || ': str ' || vstr, csay_level);
				ostr := ostr || vstr;
			EXCEPTION
				WHEN no_data_found THEN
					EXIT;
			END;
			EXIT WHEN vreaded = 0;
			voffset := voffset + vreaded;
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getstrfromclob;

	PROCEDURE initaccountdisplaymode IS
		cmethod_name CONSTANT VARCHAR2(40) := cpackage_name || '.InitAccountDisplayMode';
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		saccountdisplaymode := datamember.getchar(object.gettype(contract.object_name)
												 ,clerk.getcode
												 ,caccdm_set);
		IF saccountdisplaymode IS NULL
		THEN
			saccountdisplaymode := caccdm_all;
		END IF;
		s.say(cmethod_name || ': leave ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			saccountdisplaymode := caccdm_all;
			err.seterror(SQLCODE, cmethod_name);
			error.save(cmethod_name);
	END initaccountdisplaymode;

	PROCEDURE initaccountsortmode IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.InitAccountSortMode';
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		saccountsortmode := datamember.getchar(object.gettype(contract.object_name)
											  ,clerk.getcode
											  ,caccsm_set);
		IF saccountsortmode IS NULL
		THEN
			saccountsortmode := csortbyaccount;
		END IF;
		s.say(cmethod_name || ': leave ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END initaccountsortmode;

	PROCEDURE updateaccountdisplaymodemenu(pdialog IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(40) := cpackage_name || '.UpdateAccountDisplayModeMenu';
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		dialog.putbool(pdialog, caccdm_all, saccountdisplaymode = caccdm_all);
		dialog.putbool(pdialog, caccdm_onlyenabled, saccountdisplaymode = caccdm_onlyenabled);
		s.say(cmethod_name || ': leave ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			error.save(cmethod_name);
	END updateaccountdisplaymodemenu;

	PROCEDURE updateaccountsortmodemenu(pdialog IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.UpdateAccountSortModeMenu';
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		dialog.putbool(pdialog, csortbyaccount, saccountsortmode = csortbyaccount);
		dialog.putbool(pdialog, csortlikecontracttype, saccountsortmode = csortlikecontracttype);
		s.say(cmethod_name || ': leave ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END updateaccountsortmodemenu;

	PROCEDURE updatecardsortmodemenu(pdialog IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.UpdateCardSortModeMenu';
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		dialog.putbool(pdialog
					  ,'SORTBYPANFIO'
					  ,dialog.getchar(pdialog, 'CARDSORTMODE') = 'SORTBYPANFIO');
		dialog.putbool(pdialog
					  ,'SORTBYFIOPAN'
					  ,dialog.getchar(pdialog, 'CARDSORTMODE') = 'SORTBYFIOPAN');
		s.say(cmethod_name || ': leave ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END updatecardsortmodemenu;

	FUNCTION setaccountdisplaymode(pmode IN VARCHAR2) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(40) := cpackage_name || '.SetAccountDisplayMode';
		vreturn BOOLEAN := FALSE;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		IF saccountdisplaymode != pmode
		THEN
			saccountdisplaymode := pmode;
			IF datamember.setchar(object.gettype(contract.object_name)
								 ,clerk.getcode
								 ,caccdm_set
								 ,saccountdisplaymode
								 ,'contract accounts viewing mode') != 0
			THEN
				error.saveraise(cmethod_name
							   ,err.geterrorcode()
							   ,err.gettext() || ' ' || clerk.getcode() || ' ' ||
								saccountdisplaymode);
			END IF;
			vreturn := TRUE;
		END IF;
		s.say(cmethod_name || ': leave ', csay_level);
		RETURN vreturn;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END setaccountdisplaymode;

	FUNCTION setaccountsortmode(pmode IN VARCHAR2) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.SetAccountSortMode';
		vreturn BOOLEAN := FALSE;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		IF saccountsortmode != pmode
		THEN
			saccountsortmode := pmode;
			IF datamember.setchar(object.gettype(contract.object_name)
								 ,clerk.getcode
								 ,caccsm_set
								 ,saccountsortmode
								 ,'contract accounts sorting mode') != 0
			THEN
				error.raiseerror(err.geterrorcode(), clerk.getcode() || ' ' || saccountsortmode);
			END IF;
			vreturn := TRUE;
		END IF;
		s.say(cmethod_name || ': leave ', csay_level);
		RETURN vreturn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setaccountsortmode;

	PROCEDURE setcardsortmode
	(
		pdialog IN NUMBER
	   ,pmode   IN VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.SetCardSortMode';
	
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		IF dialog.getchar(pdialog, 'CARDSORTMODE') != pmode
		THEN
			dialog.putchar(pdialog, 'CARDSORTMODE', pmode);
			contractparams.savechar(contractparams.getobjecttype(contracttype.ccontracttypebranch)
								   ,0
								   ,'CARDSORTMODE'
								   ,upper(pmode));
		END IF;
		s.say(cmethod_name || ': leave ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE putaccountdata
	(
		pdialog    IN NUMBER
	   ,paccountno VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.PutAccountData';
		vaccountrow apitypes.typeaccountrecord;
		vformat     VARCHAR2(10);
		vright      BOOLEAN;
	BEGIN
		IF paccountno IS NOT NULL
		   AND account.checkright(account.right_view, paccountno)
		   AND account.checkright(account.right_view_vip, paccountno)
		THEN
			vaccountrow := account.getaccountrecord(paccountno);
		END IF;
		dialog.putchar(pdialog
					  ,'NoPlan'
					  ,substr(planaccount.getledger(vaccountrow.noplan) ||
							  planaccount.getsubledger(vaccountrow.noplan) || '   ' ||
							  planaccount.getname(vaccountrow.noplan)
							 ,1
							 ,60));
	
		dialog.putchar(pdialog, 'AcOpenClerk', clerk.getnamebycode(vaccountrow.createclerk));
		dialog.putchar(pdialog, 'AcUpdateClerk', clerk.getnamebycode(vaccountrow.updateclerk));
		dialog.putdate(pdialog, 'AcOpenDate', vaccountrow.createdate);
		dialog.putdate(pdialog, 'AcUpdateDate', vaccountrow.updatedate);
	
		dialog.putdate(pdialog, 'AcSysUpdateDate', vaccountrow.updatesysdate);
		dialog.putdate(pdialog, 'AcCloseDate', vaccountrow.closedate);
		vright  := account.checkright(account.right_viewfinattrs, paccountno);
		vformat := operationsingle.getcurrencyformat(vaccountrow.currency);
		dialog.setinputformat(pdialog, 'Remain', vformat);
		dialog.setinputformat(pdialog, 'Available', vformat);
		dialog.setinputformat(pdialog, 'LowRemain', vformat);
		dialog.setinputformat(pdialog, 'Overdraft', vformat);
		dialog.setinputformat(pdialog, 'DebitReserve', vformat);
		dialog.setinputformat(pdialog, 'CreditReserve', vformat);
	
		dialog.putnumber(pdialog, 'Remain', service.iif(vright, vaccountrow.remain, NULL));
		dialog.putnumber(pdialog, 'Available', service.iif(vright, vaccountrow.available, NULL));
		dialog.putnumber(pdialog, 'LowRemain', service.iif(vright, vaccountrow.lowremain, NULL));
		dialog.putnumber(pdialog, 'Overdraft', service.iif(vright, vaccountrow.crdlimit, NULL));
		dialog.putnumber(pdialog
						,'DebitReserve'
						,service.iif(vright, vaccountrow.debitreserve, NULL));
		dialog.putnumber(pdialog
						,'CreditReserve'
						,service.iif(vright, vaccountrow.creditreserve, NULL));
		dialog.putchar(pdialog, 'Stat', substr(vaccountrow.stat, 1, 5));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END putaccountdata;

	PROCEDURE putcarddata
	(
		pdialog IN NUMBER
	   ,ppan    VARCHAR2
	   ,pmbr    NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.PutCardData';
		vcardrow apitypes.typecardrecord;
	BEGIN
		IF ppan IS NOT NULL
		   AND card.checkright(card.right_view, ppan, pmbr)
		THEN
			vcardrow := card.getcardrecord(ppan, pmbr);
		END IF;
	
		dialog.putchar(pdialog, 'CTCreateClerk', clerk.getnamebycode(vcardrow.createclerk));
		dialog.putchar(pdialog, 'CTUpdateClerk', clerk.getnamebycode(vcardrow.updateclerk));
	
		dialog.putchar(pdialog
					  ,'CTSost'
					  ,referencecardsign.getname(vcardrow.a4mstat) || ' (' ||
					   to_char(vcardrow.a4mstat) || ')');
		dialog.putchar(pdialog
					  ,'CRD_STATName'
					  ,referencecrd_stat.getname(vcardrow.pcstat) || ' (' || vcardrow.pcstat || ')');
	
		dialog.putdate(pdialog, 'CTCreateDate', vcardrow.createdate);
		dialog.putdate(pdialog, 'CTUpdateDate', vcardrow.updatedate);
		dialog.putdate(pdialog, 'CTDistributionDate', vcardrow.distributiondate);
		dialog.putdate(pdialog, 'CTCancelDate', vcardrow.expirationdate);
		dialog.putdate(pdialog, 'CTMakingDate', vcardrow.makingdate);
		dialog.putdate(pdialog, 'CTOrderDate', vcardrow.enterdate);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END putcarddata;

	PROCEDURE getaccountdata
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetAccountData';
		vaccountno VARCHAR2(20);
	BEGIN
		vaccountno := dialog.getcurrentrecordchar(pdialog, pitemname, 'AccountNo');
		putaccountdata(pdialog, vaccountno);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getaccountdata;

	PROCEDURE getcarddata
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCardData';
		vpan tcard.pan%TYPE;
		vmbr tcard.mbr%TYPE;
	BEGIN
		vpan := dialog.getcurrentrecordchar(pdialog, pitemname, 'PAN');
		vmbr := dialog.getcurrentrecordnumber(pdialog, pitemname, 'MBR');
		setcurrentcardno(vpan, vmbr);
		putcarddata(pdialog, vpan, vmbr);
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethod_name);
			err.seterror(SQLCODE, cmethod_name);
	END getcarddata;

	FUNCTION getstatusflag(ppos IN PLS_INTEGER) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetStatusFlag';
	
	BEGIN
		CASE ppos
			WHEN 1 THEN
				RETURN stat_close;
			WHEN 2 THEN
				RETURN stat_violate;
			WHEN 3 THEN
				RETURN stat_suspend;
			WHEN 4 THEN
				RETURN stat_investigation;
			ELSE
				error.raiseerror('Unknown contract status!');
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE getcontractdata(pdialog IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractData';
		vcontractrow tcontract%ROWTYPE;
	
		vsubstatusrow   tcontractstatus%ROWTYPE;
		vlaststatusdate DATE;
	BEGIN
		vcontractrow.no := dialog.getchar(pdialog, 'No');
		IF contracttools.getcontractrecord(vcontractrow.no, vcontractrow) != 0
		THEN
			service.sayerr(pdialog, 'Warning!');
			RETURN;
		END IF;
	
		vsubstatusrow.substatus := vcontractrow.substatus;
		IF vsubstatusrow.substatus IS NOT NULL
		THEN
			vsubstatusrow := contractstatus.getsubstatusrow(vcontractrow.no);
		ELSE
			vsubstatusrow.substatus := contractstatus.empty;
		END IF;
	
		dialog.putchar(pdialog
					  ,'ContractStatus'
					  ,getstatusname(vcontractrow.status) ||
					   service.iif(vsubstatusrow.substatus = contractstatus.empty
								  ,''
								  ,' (' || contractstatus.getcaption(vsubstatusrow.substatus) || ')'));
		vlaststatusdate := getlaststatuschange(vcontractrow.no, getstatusid(vcontractrow.status))
						   .operdate;
		IF vlaststatusdate IS NULL
		   AND checkstatus(vcontractrow.status, stat_close)
		THEN
			t.note('point 0');
			vlaststatusdate := vcontractrow.closedate;
		END IF;
		dialog.putchar(pdialog, upper('MainStatusField'), getstatusname(vcontractrow.status));
		dialog.putchar(pdialog, upper('MainStatusDateField'), htools.d2s(vlaststatusdate));
		dialog.putchar(pdialog
					  ,upper('SubStatusField')
					  ,contractstatus.getcaption(vsubstatusrow.substatus));
		dialog.putchar(pdialog, upper('SubStatusDateField'), htools.d2s(vsubstatusrow.operdate));
	
		contracttype.setdata(pdialog, 'eCType', vcontractrow.type);
	
		dialog.putchar(pdialog, 'OpenDate', htools.d2s(vcontractrow.createdate));
		dialog.putchar(pdialog, 'OpenClerk', clerk.getnamebycode(vcontractrow.createclerk));
		dialog.putchar(pdialog, 'CloseDate', htools.d2s(vcontractrow.closedate));
		dialog.putchar(pdialog, 'CloseClerk', clerk.getnamebycode(vcontractrow.closeclerk));
	
		contracttypeschema.fillinfopanel(dialog.getnumber(pdialog, 'Handle')
										,pdialog
										,'SchemaPanel');
	
		dialog.puttext(pdialog, ccomment, vcontractrow.commentary);
		referencebranchpart.setbptodialog(pdialog, vcontractrow.branchpart);
		fincontractinstance.loadpage(pdialog, vcontractrow.finprofile, vcontractrow.no);
	
		IF dialog.getlistreccount(pdialog, 'OperationsList') = 0
		THEN
			dialog.setitemattributies(pdialog, 'ExecOper', dialog.selectoff);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcontractdata;

	PROCEDURE getclientinfo
	(
		pdialog   IN NUMBER
	   ,pidclient IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetClientInfo';
		vclienthandle NUMBER;
	BEGIN
		vclienthandle := client.newobject(pidclient, 'R');
		dialog.putchar(pdialog
					  ,'ClientText1'
					  ,service.cpad(client.getcardtext(vclienthandle, 1) || ' (' ||
									to_char(pidclient) || ')'
								   ,60
								   ,' '));
		dialog.putchar(pdialog
					  ,'ClientText2'
					  ,service.cpad(client.getcardtext(vclienthandle, 2), 60, ' '));
		dialog.putchar(pdialog
					  ,'ClientText3'
					  ,service.cpad(client.getcardtext(vclienthandle, 3), 60, ' '));
		client.freeobject(vclienthandle);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getclientinfo;

	FUNCTION fillaccountlist
	(
		pdialog       IN NUMBER
	   ,pitemname     IN VARCHAR2
	   ,pcontracttype IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FillAccountList';
		vaccount typeaccountrow;
		vcount   NUMBER;
	BEGIN
		dialog.listclear(pdialog, pitemname);
	
		contractdlg.initaccountlist(pcontracttype);
		vcount := contractdlg.getcount;
	
		FOR i IN 1 .. vcount
		LOOP
			--vaccount := contractdlg.getaccountbyindex(i);
			dialog.listaddrecord(pdialog
								,pitemname
								,to_char(vaccount.itemcode) || '~' || to_char(vaccount.createmode) || '~' ||
								 to_char(vaccount.currencycode) || '~' || vaccount.description || '~' ||
								 vaccount.accountno || '~' || vaccount.accounttype || '~' ||
								 vaccount.acctypename || '~' || vaccount.itemname || '~' ||
								 vaccount.refaccounttype || '~'
								,0
								,0);
		END LOOP;
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(csay_level, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END fillaccountlist;

	FUNCTION fillcardlist
	(
		pdialog       IN NUMBER
	   ,pitemname     IN VARCHAR2
	   ,pcontracttype IN NUMBER
	   ,pidclient     IN NUMBER
	   ,pcardtype     IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FillCardList';
		vidclient        NUMBER;
		vcardproductname VARCHAR2(30);
		vclientname      tclientpersone.fio%TYPE;
		vmark            VARCHAR2(1);
		vcardrow         tcontractcard%ROWTYPE;
		vcount           NUMBER;
	
	BEGIN
	
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pItemName', pitemname);
		t.inpar('pContractType', pcontracttype);
		t.inpar('pIdClient', pidclient);
		t.inpar('pCardType', pcardtype);
	
		dialog.listclear(pdialog, pitemname);
		vcount := contractcard.initarray(pcontracttype, pcardtype);
		t.var('vCount', vcount);
		dialog.putchar(pdialog, 'MarkedItems', NULL);
	
		FOR i IN 1 .. vcount
		LOOP
			IF contractcard.activecardproduct(contractcard.getarraycardproduct(i))
			   AND card.checkright(pright       => card.right_create
								  ,pcardproduct => contractcard.getarraycardproduct(i))
			THEN
				IF contractcard.getarrayactive(i)
				THEN
					vcardrow := contractcard.getarraycardrow(i);
					t.note('vCardRow.Code=' || vcardrow.code || ', vCardRow.Cardproduct=' ||
						   vcardrow.cardproduct || ', vCardRow.Cardhow=' || vcardrow.cardhow ||
						   ', vCardRow.Cardtype=' || vcardrow.cardtype
						  ,csay_level);
					vcardproductname := substr(referencecardproduct.getname(vcardrow.cardproduct)
											  ,1
											  ,30);
					vmark            := service.iif(contractcard.getarraymark(i), '1', ' ');
					dialog.putchar(pdialog
								  ,'MarkedItems'
								  ,dialog.getchar(pdialog, 'MarkedItems') || vmark);
					s.say(cmethod_name || ': mark ' || vmark, csay_level);
					vcardrow.finprofile := nvl(vcardrow.finprofile
											  ,referencecardproduct.getfinprofile(vcardrow.cardproduct));
					s.say(cmethod_name || ': fin profile ' || vcardrow.finprofile, csay_level);
					vcardrow.grplimit := nvl(vcardrow.grplimit
											,contractcard.getgrplimit(pcontracttype
																	 ,contractcard.getarrayitemcode(i)));
					s.say(cmethod_name || ': grp limit ' || vcardrow.grplimit, csay_level);
					vcardrow.limitcurrency := nvl(vcardrow.limitcurrency
												 ,contractcard.getlimitcurrency(pcontracttype
																			   ,contractcard.getarrayitemcode(i)));
					s.say(cmethod_name || ': limit curr ' || vcardrow.limitcurrency, csay_level);
					IF vcardrow.cardtype = card.ccsprimary
					   AND pidclient IS NOT NULL
					THEN
						vidclient   := pidclient;
						vclientname := clientpersone.getpersonerecord(vidclient).fio;
					ELSE
						vidclient   := NULL;
						vclientname := NULL;
					END IF;
				
					dialog.listaddrecord(pdialog
										,pitemname
										,to_char(vcardrow.code) || '~' || to_char(vidclient) || '~' ||
										 to_char(vcardrow.cardhow) || '~' ||
										 to_char(vcardrow.cardproduct) || '~' ||
										 
										 service.iif(vcardrow.cardtype = card.ccsprimary, ' ', 'C') || '~' || NULL || '~' || NULL || '~' ||
										 vcardproductname || '~' || vclientname || '~' ||
										 vcardrow.finprofile || '~' || vcardrow.grplimit || '~' ||
										 vcardrow.limitcurrency || '~1~'
										,0
										,0);
				END IF;
			END IF;
		END LOOP;
		dialog.putchar(pdialog, pitemname, dialog.getchar(pdialog, 'MarkedItems'));
		t.leave(cmethod_name, 'vCount=' || vcount, plevel => csay_level);
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(csay_level, plevel => csay_level);
		
			error.save(cmethod_name);
			RAISE;
	END fillcardlist;

	PROCEDURE updateacctlist(pdialog NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(40) := cpackage_name || '.UpdateAcctList';
		vno              VARCHAR2(20);
		vaccountno       VARCHAR2(20);
		vitemcode        NUMBER;
		vcurrency        NUMBER;
		vaccdescription  tcontractitem.itemdescr%TYPE;
		vaccounttypename VARCHAR2(80);
		cbranch CONSTANT NUMBER := seance.getbranch();
		TYPE typeacclist IS REF CURSOR;
		curlist  typeacclist;
		vcurrpos NUMBER;
	
		vitemname   tcontracttypeitemname.itemname%TYPE;
		vactualdate tcontractitem.actualdate%TYPE;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		vcurrpos := dialog.getlistcurrentrecordnumber(pdialog, 'Account');
		vno      := dialog.getchar(pdialog, 'No');
		dialog.listclear(pdialog, 'Account');
		s.say(cmethod_name || ': accounts sort mode ' || saccountsortmode, csay_level);
		IF (saccountsortmode = csortbyaccount)
		THEN
			OPEN curlist FOR
				SELECT a.key
					  ,ac.currencyno
					  ,att.name
					  ,nvl(a.itemdescr, b.description)
					  ,a.actualdate
					  ,a.itemcode
					  ,c.itemname
				FROM   tcontractitem a
				INNER  JOIN taccount ac
				ON     ac.branch = a.branch
				AND    ac.accountno = a.key
				INNER  JOIN taccounttype att
				ON     att.branch = ac.branch
				AND    att.accounttype = ac.accounttype
				INNER  JOIN tcontracttypeitems b
				ON     b.branch = a.branch
				AND    b.itemcode = a.itemcode
				INNER  JOIN tcontracttypeitemname c
				ON     c.branch = b.branch
				AND    c.itemcode = b.itemcode
				WHERE  a.branch = cbranch
				AND    a.no = vno
				ORDER  BY a.key;
		
		ELSE
			OPEN curlist FOR
				SELECT a.key
					  ,ac.currencyno
					  ,att.name
					  ,nvl(a.itemdescr, b.description)
					  ,a.actualdate
					  ,a.itemcode
					  ,c.itemname
				FROM   tcontractitem         a
					  ,taccount              ac
					  ,taccounttype          att
					  ,tcontracttypeitems    b
					  ,tcontracttypeitemname c
				WHERE  a.branch = cbranch
				AND    a.no = vno
				AND    ac.branch = a.branch
				AND    ac.accountno = a.key
				AND    att.branch = ac.branch
				AND    att.accounttype = ac.accounttype
				AND    b.branch = a.branch
				AND    b.itemcode = a.itemcode
				AND    c.branch = b.branch
				AND    c.itemcode = b.itemcode
				ORDER  BY a.itemcode;
		END IF;
		LOOP
			FETCH curlist
				INTO vaccountno
					,vcurrency
					,vaccounttypename
					,vaccdescription
					,vactualdate
					,vitemcode
					,vitemname;
			EXIT WHEN curlist%NOTFOUND;
		
			IF (saccountdisplaymode = caccdm_all)
			   OR ((saccountdisplaymode = caccdm_onlyenabled) AND
			   account.checkright(account.right_view, vaccountno) AND
			   account.checkright(account.right_view_vip, vaccountno))
			THEN
				dialog.listaddrecord(pdialog
									,'Account'
									,vaccountno || '~' || to_char(vcurrency) || '~' ||
									 vaccdescription || '~' || vaccounttypename || '~' ||
									 htools.d2s(vactualdate) || '~' || vitemcode || '~' ||
									 vitemname || '~'
									,0
									,0);
			
			END IF;
		END LOOP;
		CLOSE curlist;
		IF dialog.getlistreccount(pdialog, 'Account') != 0
		THEN
			dialog.setcurrec(pdialog
							,'Account'
							,service.iif((vcurrpos = 0 OR
										 vcurrpos > dialog.getlistreccount(pdialog, 'Account'))
										,1
										,vcurrpos));
		
			vitemname := dialog.getcurrentrecordchar(pdialog, 'Account', upper('AccItemName'));
			t.var('vItemName', vitemname);
		ELSE
			vitemname := NULL;
		END IF;
		contractaccounthistory.refreshacchistpage(pdialog, vitemname);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			CLOSE curlist;
			RAISE;
	END updateacctlist;

	PROCEDURE updatecardlist(pdialog NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.UpdateCardList';
		vno              VARCHAR2(20);
		vcount           NUMBER;
		vcurrcardproduct NUMBER;
		frightviewpan    BOOLEAN := card.checkright(card.right_view_pan);
		vpan             tcard.pan%TYPE;
		vmbr             tcard.mbr%TYPE;
		vproductname     treferencecardproduct.name%TYPE;
		vidclient        tclientpersone.idclient%TYPE;
		vfio             tclientpersone.fio%TYPE;
		vitemcode        tcontractitem.itemcode%TYPE;
		cbranch CONSTANT NUMBER := seance.getbranch();
		TYPE typecardlist IS REF CURSOR;
		curlist typecardlist;
	BEGIN
		vcurrcardproduct := dialog.getlistcurrentrecordnumber(pdialog, 'Card');
		vno              := dialog.getchar(pdialog, 'No');
		dialog.listclear(pdialog, 'Card');
		vcount := 0;
		IF dialog.getchar(pdialog, 'CARDSORTMODE') = 'SORTBYFIOPAN'
		THEN
			OPEN curlist FOR
			
				SELECT c.pan
					  ,c.mbr
					  ,p.name      cardproductname
					  ,cp.idclient
					  ,cp.fio      clientname
					  ,a.itemcode
				FROM   tcontractcarditem a
				INNER  JOIN tcard c
				ON     c.branch = a.branch
				AND    c.pan = a.pan
				AND    c.mbr = a.mbr
				INNER  JOIN tclientpersone cp
				ON     cp.branch = c.branch
				AND    cp.idclient = c.idclient
				INNER  JOIN treferencecardproduct p
				ON     p.branch = c.branch
				AND    p.code = c.cardproduct
				WHERE  a.branch = cbranch
				AND    a.no = vno
				ORDER  BY cp.fio
						 ,a.pan
						 ,a.mbr;
		ELSE
			OPEN curlist FOR
			
				SELECT c.pan
					  ,c.mbr
					  ,p.name      cardproductname
					  ,cp.idclient
					  ,cp.fio      clientname
					  ,a.itemcode
				FROM   tcontractcarditem a
				INNER  JOIN tcard c
				ON     c.branch = a.branch
				AND    c.pan = a.pan
				AND    c.mbr = a.mbr
				INNER  JOIN tclientpersone cp
				ON     cp.branch = c.branch
				AND    cp.idclient = c.idclient
				INNER  JOIN treferencecardproduct p
				ON     p.branch = c.branch
				AND    p.code = c.cardproduct
				WHERE  a.branch = cbranch
				AND    a.no = vno
				ORDER  BY a.pan
						 ,a.mbr
						 ,cp.fio;
		
		END IF;
	
		LOOP
			FETCH curlist
				INTO vpan
					,vmbr
					,vproductname
					,vidclient
					,vfio
					,vitemcode;
			EXIT WHEN curlist%NOTFOUND;
		
			dialog.listaddrecord(pdialog
								,'Card'
								,vpan || '~' || vmbr || '~' ||
								 getcardno(vpan, vmbr, frightviewpan) || '~' || vproductname || '~' ||
								 vidclient || '~' || vfio || '~' || vitemcode || '~'
								,0
								,0);
		
			vcount := vcount + 1;
		END LOOP;
		CLOSE curlist;
	
		IF vcount = 0
		THEN
			RETURN;
		END IF;
	
		IF vcurrcardproduct = 0
		THEN
			vcurrcardproduct := 1;
		END IF;
	
		dialog.setcurrec(pdialog, 'Card', vcurrcardproduct);
	EXCEPTION
		WHEN OTHERS THEN
			CLOSE curlist;
			error.save(cmethod_name);
			RAISE;
	END updatecardlist;

	FUNCTION addcard
	(
		pno         IN tcontract.no%TYPE
	   ,ppan        IN tcard.pan%TYPE
	   ,pmbr        IN tcard.mbr%TYPE
	   ,pcreatemode IN NUMBER := 2
	   ,pitemcode   IN tcontractcarditem.itemcode%TYPE := NULL
	   ,pcardtype   IN tcontractcard.cardtype%TYPE := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddCard[2]';
		vctype        NUMBER;
		vcardproduct  NUMBER;
		vcardrow      apitypes.typecardrecord;
		vitemcode     NUMBER;
		vcpbyitemcode NUMBER;
		visactive     BOOLEAN;
		vcardtype     tcontractcard.cardtype%TYPE;
		vcontractno   typecontractno;
	
		PROCEDURE addnewitem
		(
			pno    IN tcontract.no%TYPE
		   ,picode IN tcontractcarditem.itemcode%TYPE
		   ,ppan   IN tcard.pan%TYPE
		   ,pmbr   IN tcard.mbr%TYPE
		) IS
			vcarditemrow tcontractcarditem%ROWTYPE;
		BEGIN
			t.note(cmethod_name, 'AddNewItem Start pICode=' || picode, csay_level);
			vcarditemrow := contractcarditem(pno, picode, ppan, pmbr);
			t.note(cmethod_name, 'AddNewItem Do it', csay_level);
			insertcarditem(vcarditemrow);
			t.note(cmethod_name, 'AddNewItem Finish AddNewItem', csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name || '.AddNewItem');
				RAISE;
		END;
	
	BEGIN
		t.note(cmethod_name
			  ,'no=' || pno || ', pan=' || card.getmaskedpan(ppan) || ', mbr=' || pmbr ||
			   ', pItemCode=' || pitemcode || ', pCardType=' || pcardtype
			  ,csay_level);
	
		vcontractno := contract.getcurrentno;
		t.var('vContractNo', vcontractno);
		setcurrentno(pno);
	
		vctype := contract.gettype(pno);
	
		IF vctype IS NULL
		THEN
			t.note(cmethod_name, 'There is no contract type ', csay_level);
			RETURN err.geterrorcode();
		END IF;
	
		vcardrow     := card.getcardrecord(ppan, pmbr);
		vcardproduct := vcardrow.cardproduct;
		s.say(cmethod_name || ': card product ' || vcardproduct, csay_level);
		IF vcardproduct IS NULL
		THEN
			s.say(cmethod_name || ': no card product ', csay_level);
			RETURN err.geterrorcode();
		END IF;
	
		IF pitemcode IS NOT NULL
		THEN
			vcpbyitemcode := contractcard.getcardproduct(vctype, pitemcode);
			IF vcpbyitemcode IS NULL
			THEN
				s.say(cmethod_name || ': ItemCode: ' || pitemcode ||
					  'does not exist in ContractType: ' || vctype
					 ,csay_level);
				RETURN err.geterrorcode();
			ELSE
				IF vcpbyitemcode != vcardproduct
				   AND referencecardproduct.getmainproduct(vcardproduct) != vcpbyitemcode
				THEN
				
					s.say(cmethod_name || ': CardProducts: ' || vcardproduct || ', ' ||
						  vcpbyitemcode || ' are not identical'
						 ,csay_level);
					err.seterror(err.contract_item_not_found, cmethod_name);
					RETURN err.geterrorcode();
				ELSE
					IF pcreatemode = contractcard.newcreate
					THEN
						visactive := contractcard.getactive(vctype, pitemcode);
						s.say(cmethod_name || ': is active ' || htools.bool2str(visactive)
							 ,csay_level);
						IF visactive
						THEN
							addnewitem(pno, pitemcode, ppan, pmbr);
							createcardaccountlinks(pno, ppan, pmbr);
						ELSIF NOT visactive
						THEN
							s.say(cmethod_name || ': Item: ' || pitemcode || ' is not active'
								 ,csay_level);
							err.seterror(err.contract_card_product_inactive, cmethod_name);
							RETURN err.geterrorcode();
						ELSE
							s.say(cmethod_name || ': Item: ' || pitemcode || ' not found'
								 ,csay_level);
							RETURN err.geterrorcode();
						END IF;
					ELSE
						addnewitem(pno, pitemcode, ppan, pmbr);
						createcardaccountlinks(pno, ppan, pmbr);
					END IF;
				END IF;
			END IF;
		ELSE
		
			vcardtype := contracttools.getcardtype(ppan, pmbr, FALSE);
			t.var('[1] vCardType', vcardtype);
			IF vcardtype IS NULL
			THEN
				vcardtype := pcardtype;
				t.var('[2] vCardType', vcardtype);
			END IF;
		
			IF pcreatemode = contractcard.newcreate
			THEN
				vitemcode := contractcard.getitemcodebycardproduct(vctype
																  ,vcardproduct
																  ,1
																  ,pcardtype => vcardtype);
				IF vitemcode IS NULL
				THEN
					err.seterror(err.contract_card_product_inactive, cmethod_name);
					RETURN err.geterrorcode();
				ELSE
					addnewitem(pno, vitemcode, ppan, pmbr);
					createcardaccountlinks(pno, ppan, pmbr);
				END IF;
			ELSE
				vitemcode := contractcard.getitemcodebycardproduct(vctype
																  ,vcardproduct
																  ,pcardtype => vcardtype);
				IF vitemcode IS NULL
				THEN
					s.say(cmethod_name || ': no item code ', csay_level);
					RETURN err.geterrorcode();
				ELSE
					addnewitem(pno, vitemcode, ppan, pmbr);
					createcardaccountlinks(pno, ppan, pmbr);
				END IF;
			END IF;
		
		END IF;
		setcurrentno(vcontractno);
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END addcard;

	PROCEDURE addcardbypan2
	(
		pno           IN tcontract.no%TYPE
	   ,pcardrow      IN OUT typecardparams
	   ,pcmsparams    IN typecmsparams
	   ,paddexistcard IN BOOLEAN := FALSE
	   ,psaverollback IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddCardByPAN2';
		vcontractrow typecontractparams;
		usererror EXCEPTION;
		vcontractno tcontract.no%TYPE;
		vnew        BOOLEAN;
		vhandle     NUMBER;
	
		vcardexist BOOLEAN;
		vcardtype  tcard.supplementary%TYPE;
	
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('No', pno, csay_level);
		t.inpar('PAN', card.getmaskedpan(pcardrow.pan), csay_level);
		t.inpar('MBR', pcardrow.mbr, csay_level);
		t.inpar('pin offset', pcardrow.pinoffset, csay_level);
		t.inpar('CVV', pcardrow.cvv, csay_level);
		t.inpar('CVV2', pcardrow.cvv2, csay_level);
		t.inpar('branch part', pcardrow.branchpart, csay_level);
		t.inpar('item code', pcardrow.itemcode, csay_level);
		t.inpar('card product', pcardrow.cardproduct, csay_level);
		t.inpar('client id', pcardrow.idclient, csay_level);
		t.inpar('pCardRow.CardType', pcardrow.cardtype, csay_level);
	
		vcontractno := contract.getcurrentno;
		t.var('vContractNo', vcontractno, csay_level);
		getcontractrow(pno, vcontractrow);
	
		vhandle := gethandle(pno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pno, 'W');
			IF vhandle = 0
			THEN
				error.raiseerror('Contract is blocked: ' ||
								 object.capturedobjectinfo(object_name, pno));
			END IF;
			vnew := TRUE;
		ELSE
			setcurrentno(pno);
		END IF;
	
		vcardexist := card.cardexists(pcardrow.pan, pcardrow.mbr);
		t.var('vCardExist', t.b2t(vcardexist));
	
		IF pcardrow.cardproduct IS NULL
		THEN
		
			IF vcardexist
			THEN
				pcardrow.cardproduct := card.getcardproduct(pcardrow.pan, pcardrow.mbr);
			END IF;
		
			IF pcardrow.cardproduct IS NULL
			THEN
				error.raiseerror(err.reffi_cp_undefined);
			END IF;
		END IF;
	
		IF vcardexist
		THEN
			vcardtype := contracttools.getcardtype(pcardrow.pan, pcardrow.mbr, FALSE);
			t.var('[1] vCardType', vcardtype);
			IF vcardtype IS NOT NULL
			THEN
				pcardrow.cardtype := vcardtype;
				t.var('[2] vCardType', vcardtype);
			END IF;
		END IF;
	
		IF pcardrow.itemcode IS NULL
		THEN
			pcardrow.itemcode := contractcard.getitemcodebycardproduct(vcontractrow.type
																	  ,pcardrow.cardproduct
																	  ,pcardtype => pcardrow.cardtype);
			t.var('pCardRow.ItemCode', pcardrow.itemcode, csay_level);
			IF pcardrow.itemcode IS NULL
			THEN
				error.raiseerror('Not found ID of card product [' ||
								 referencecardproduct.getname(pcardrow.cardproduct) ||
								 '] in contract type settings [' || vcontractrow.type || ']');
			END IF;
		END IF;
	
		IF pcardrow.pan IS NOT NULL
		   AND vcardexist
		THEN
			IF NOT paddexistcard
			THEN
				error.raiseerror('Attempted addition of existing card to contract');
			END IF;
			t.note(cmethod_name, 'addition existing card to the contract', csay_level);
			createcardlink(contractcard.newlink, vcontractrow, pcardrow, pcmsparams, psaverollback);
		ELSE
			t.note(cmethod_name, 'creating new card', csay_level);
			createcards(contractcard.newcreate, vcontractrow, pcardrow, pcmsparams, psaverollback);
			t.var('pCardRow.PAN', card.getmaskedpan(pcardrow.pan));
			t.var('pCardRow.MBR', pcardrow.mbr);
		END IF;
	
		IF vnew
		THEN
			freeobject(vhandle);
		ELSE
			contract.setcurrentno(vcontractno);
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
	
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			contract.setcurrentno(vcontractno);
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			RAISE;
	END addcardbypan2;

	PROCEDURE addcardbypan
	(
		pno           IN tcontract.no%TYPE
	   ,pcardrow      IN OUT typecardparams
	   ,pcmsparams    IN typecmsparams
	   ,paddexistcard IN BOOLEAN := FALSE
	   ,psaverollback IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddCardByPAN';
		vpackno NUMBER;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		vpackno := contractrb.init();
		addcardbypan2(pno, pcardrow, pcmsparams, paddexistcard, psaverollback);
		srollbackdata := contractrb.done(vpackno);
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			contractrb.clearlaststate();
			error.save(cmethod_name);
			RAISE;
	END addcardbypan;

	FUNCTION getlinkedtypes(pdialog IN NUMBER) RETURN types.arrnum IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetLinkedTypes';
		valinkedtypelist types.arrnum;
		cdlg_list_linkedobjects CONSTANT VARCHAR2(30) := upper('LinkedTypeList');
		vcount NUMBER;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		IF dialog.idbyname(pdialog, 'LINKEDTYPEPAGEID') > 0
		THEN
			t.note(cmethod_name
				  ,'point 1: PageId=' || dialog.getnumber(pdialog, 'LINKEDTYPEPAGEID'));
			IF nvl(dialog.getnumber(pdialog, 'LINKEDTYPEPAGEID'), 0) > 0
			THEN
				t.note(cmethod_name, 'point 2');
				vcount := dialog.getlistreccount(pdialog, cdlg_list_linkedobjects);
				FOR i IN 1 .. vcount
				LOOP
					IF dialog.getbool(pdialog, cdlg_list_linkedobjects, i)
					THEN
						t.note(cmethod_name
							  ,'LinkedType=[' || dialog.getrecordnumber(pdialog
																	   ,cdlg_list_linkedobjects
																	   ,'ContractTypeCode'
																	   ,i) || '] marked: [' ||
							   t.b2t(dialog.getbool(pdialog, cdlg_list_linkedobjects, i)) || ']');
						valinkedtypelist(valinkedtypelist.count + 1) := dialog.getrecordnumber(pdialog
																							  ,cdlg_list_linkedobjects
																							  ,'ContractTypeCode'
																							  ,i);
					END IF;
				END LOOP;
			END IF;
		END IF;
		t.leave(cmethod_name
			   ,'vaLinkedTypeList.count=' || valinkedtypelist.count
			   ,plevel => csay_level);
		RETURN valinkedtypelist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE createcontractfromdialog(pdialog IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateContractFromDialog';
		vcontractrow     typecontractparams;
		vaccountarray    typeaccountarray;
		vcardarray       typecardparamsarray;
		vacc2cardarray   typeacc2cardarray;
		vcount           NUMBER := 0;
		vcreatemode      NUMBER;
		vmark            CHAR(1);
		valinkedtypelist types.arrnum;
		vcardinfolist    card.typefullcardinfolist;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		err.seterror(0, cmethod_name);
	
		SAVEPOINT contractcreatecontract;
		srollbackdata := NULL;
	
		s.say(cmethod_name || ': fill contract''s attributes', csay_level);
		vcontractrow.no := TRIM(dialog.getchar(pdialog, 'No'));
		IF vcontractrow.no IS NOT NULL
		THEN
			checkincorrectno(vcontractrow.no);
		END IF;
	
		vcontractrow.type               := dialog.getnumber(pdialog, 'Type');
		vcontractrow.idclient           := dialog.getnumber(pdialog, 'IdClient');
		vcontractrow.addexistcard       := TRUE;
		vcontractrow.branchpart         := referencebranchpart.getbpfromdialog(pdialog);
		vcontractrow.addexistacc        := ctdialog.addexistaccount(vcontractrow.type);
		vcontractrow.createuserproperty := FALSE;
		vcontractrow.creationmode       := ccreation_interactivemode;
	
		t.var('vContractRow.No', vcontractrow.no, csay_level);
		t.var('vContractRow.Type', vcontractrow.type, csay_level);
		t.var('vContractRow.IdClient', vcontractrow.idclient, csay_level);
		t.var('vContractRow.BranchPart', vcontractrow.branchpart, csay_level);
	
		vaccountarray.delete;
		s.say(cmethod_name || ': fill array of accounts ', csay_level);
		s.say(cmethod_name || ': count of accounts ' || dialog.getlistreccount(pdialog, 'Account')
			 ,csay_level);
		FOR i IN 1 .. dialog.getlistreccount(pdialog, 'Account')
		LOOP
			vaccountarray(i).accountno := dialog.getrecordchar(pdialog, 'Account', 'AccountNo', i);
			s.say(cmethod_name || ': account no ' || vaccountarray(i).accountno, csay_level);
			vaccountarray(i).accounttype := dialog.getrecordchar(pdialog
																,'Account'
																,'AccountType'
																,i);
			s.say(cmethod_name || ': account type ' || vaccountarray(i).accounttype, csay_level);
			vaccountarray(i).itemcode := dialog.getrecordnumber(pdialog, 'Account', 'ItemCode', i);
			s.say(cmethod_name || ': item code ' || vaccountarray(i).itemcode, csay_level);
			vaccountarray(i).userproperty := contractdlg.getaccountbyindex(i).userproperty;
			vaccountarray(i).createmode := dialog.getrecordnumber(pdialog
																 ,'Account'
																 ,'CreateMode'
																 ,i);
			s.say(cmethod_name || ': create mode ' || vaccountarray(i).createmode, csay_level);
			vaccountarray(i).refaccounttype := dialog.getrecordnumber(pdialog
																	 ,'Account'
																	 ,'AccRefType'
																	 ,i);
			s.say(cmethod_name || ': Ref Type ' || vaccountarray(i).refaccounttype, csay_level);
			vaccountarray(i).extaccount := dialog.getrecordchar(pdialog, 'Account', 'External', i);
			s.say(cmethod_name || ': External No ' || vaccountarray(i).extaccount, csay_level);
			vaccountarray(i).itemname := dialog.getrecordchar(pdialog, 'Account', 'AccItemName', i);
			s.say(cmethod_name || ': ItemName ' || vaccountarray(i).itemname, csay_level);
		END LOOP;
	
		vcardarray.delete;
		s.say(cmethod_name || ': fill array of cards ', csay_level);
		s.say(cmethod_name || ': count of cards ' || dialog.getlistreccount(pdialog, 'Card')
			 ,csay_level);
		vcount := 0;
		FOR i IN 1 .. dialog.getlistreccount(pdialog, 'Card')
		LOOP
			vmark := service.getchar(dialog.getchar(pdialog, 'Card'), i);
			s.say(cmethod_name || ': vMark=[' || vmark || ']');
			IF rtrim(vmark) IS NOT NULL
			THEN
				vcount := vcount + 1;
				vcardarray(vcount).itemcode := dialog.getrecordnumber(pdialog
																	 ,'Card'
																	 ,'ItemCode'
																	 ,i);
				s.say(cmethod_name || ': item code ' || vcardarray(vcount).itemcode, csay_level);
			
				vcreatemode := dialog.getrecordnumber(pdialog, 'Card', 'CreateMode', i);
				s.say(cmethod_name || ': creation mode ' || vcreatemode, csay_level);
				IF vcreatemode = contractcard.newcreate
				THEN
				
					vcardarray(vcount).pan := NULL;
					vcardarray(vcount).mbr := NULL;
					vcardarray(vcount).userproperty := semptyrec;
				
					vcardarray(vcount).cardproduct := contractcard.getcardproduct(vcontractrow.type
																				 ,vcardarray(vcount)
																				  .itemcode);
					vcardarray(vcount).idclient := dialog.getrecordnumber(pdialog
																		 ,'Card'
																		 ,'IdClient'
																		 ,i);
					vcardarray(vcount).finprofile := dialog.getrecordnumber(pdialog
																		   ,'Card'
																		   ,'FinProfile'
																		   ,i);
					vcardarray(vcount).grplimit := dialog.getrecordnumber(pdialog
																		 ,'Card'
																		 ,'GrpLimit'
																		 ,i);
					vcardarray(vcount).currencyno := dialog.getrecordnumber(pdialog
																		   ,'Card'
																		   ,'LimitCurrency'
																		   ,i);
				
					IF existnewcardlist(vcardarray(vcount).itemcode)
					THEN
						vcardinfolist := getnewcardlist(vcardarray(vcount).itemcode);
						FOR k IN 1 .. vcardinfolist.count
						LOOP
							IF contractcard.getusecontractbranchpart(vcontractrow.type
																	,vcardarray(vcount).itemcode)
							THEN
								vcardinfolist(k).card.branchpart := vcontractrow.branchpart;
							ELSE
								vcardinfolist(k).card.branchpart := nvl(vcardinfolist(k)
																		.card.branchpart
																	   ,seance.getbranchpart());
							END IF;
						END LOOP;
						setnewcardlist(vcardarray(vcount).itemcode, vcardinfolist);
					END IF;
				
				ELSE
				
					IF existnewcardlist(vcardarray(vcount).itemcode)
					THEN
						vcardinfolist := getnewcardlist(vcardarray(vcount).itemcode);
						FOR k IN 1 .. vcardinfolist.count
						LOOP
							vcardarray(vcount).pan := vcardinfolist(k).card.pan;
							vcardarray(vcount).mbr := vcardinfolist(k).card.mbr;
							vcardarray(vcount).changeidclient := dialog.getrecordnumber(pdialog
																					   ,'Card'
																					   ,'ChangeClient'
																					   ,i) = 1;
							vcount := vcount + 1;
						END LOOP;
						IF vcardinfolist.count > 0
						THEN
							vcount := vcount - 1;
						END IF;
					ELSE
						vcardarray(vcount).pan := dialog.getrecordchar(pdialog, 'Card', 'PAN', i);
						vcardarray(vcount).mbr := dialog.getrecordnumber(pdialog, 'Card', 'MBR', i);
						vcardarray(vcount).changeidclient := dialog.getrecordnumber(pdialog
																				   ,'Card'
																				   ,'ChangeClient'
																				   ,i) = 1;
					END IF;
				
				END IF;
				s.say(cmethod_name || ': PAN ' || card.getmaskedpan(vcardarray(vcount).pan)
					 ,csay_level);
				s.say(cmethod_name || ': MBR ' || vcardarray(vcount).mbr, csay_level);
				s.say(cmethod_name || ': card product ' || vcardarray(vcount).cardproduct
					 ,csay_level);
				s.say(cmethod_name || ': client id ' || vcardarray(vcount).idclient, csay_level);
				s.say(cmethod_name || ': fin profile ' || vcardarray(vcount).finprofile
					 ,csay_level);
			END IF;
		END LOOP;
	
		valinkedtypelist := getlinkedtypes(pdialog);
		t.var('vaLinkedTypeList.count', valinkedtypelist.count, csay_level);
	
		vcontractrow.userproperty      := objuserproperty.getpagedata(pdialog, object_name);
		vcontractrow.extrauserproperty := objuserproperty.getpagedata(pdialog
																	 ,object_name
																	 ,vcontractrow.type);
		vcontractrow.operationmode     := ccreation_interactivemode;
	
		createcontract(vcontractrow
					  ,vaccountarray
					  ,vcardarray
					  ,vacc2cardarray
					  ,palinkedtypelist => valinkedtypelist);
	
		IF err.geterrorcode() != 0
		THEN
			s.say(cmethod_name || ': error creating contract ' || err.getfullmessage(), csay_level);
			IF err.geterrorcode() = err.contract_process_warning
			THEN
				IF NOT htools.ask('Warning!', '~Do you wish to create contract?', 'Yes', 'No')
				THEN
					ROLLBACK TO contractcreatecontract;
					err.seterror(0, cmethod_name);
					RETURN;
				END IF;
			ELSE
				error.raisewhenerr();
			END IF;
		END IF;
	
		s.say(cmethod_name || ': vContractRow.ObjectUID=' || vcontractrow.objectuid);
	
		contracttypeschema.saveparameterpage(pdialog
											,contractparams.ccontract
											,vcontractrow.no
											,vcontractrow.type);
	
		s.say(cmethod_name || ': no ' || vcontractrow.no, csay_level);
		dialog.putchar(pdialog, 'No', vcontractrow.no);
		err.seterror(0, cmethod_name);
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK TO contractcreatecontract;
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE seterraccindex(pindex IN NUMBER) IS
	BEGIN
		serraccindex := pindex;
	END;

	FUNCTION geterraccindex RETURN NUMBER IS
	BEGIN
		RETURN serraccindex;
	END;

	PROCEDURE addlinkedcard
	(
		paccount      IN typeaccountrow
	   ,pcontract     IN typecontractparams
	   ,pcardlist     IN typecardparamsarray
	   ,psaverollback IN BOOLEAN := TRUE
	   ,psavelog      IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddLinkedCard';
		vaccountcardlist apitypes.typeaccount2cardlist;
		j                PLS_INTEGER;
		vaccount         apitypes.typeaccountrecord;
		vcard            apitypes.typecardrecord;
		vitemcode        NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'pAccount.AccountNo=' || paccount.accountno || ', pContract.No=' || pcontract.no ||
				', pCardList.Count=' || pcardlist.count || ', pSaveRollBack=' ||
				t.b2t(psaverollback) || ', pSaveLog=' || t.b2t(psavelog)
			   ,csay_level);
		vaccountcardlist := account.getcardlist(paccount.accountno);
		t.var('vAccountCardList.count', vaccountcardlist.count, plevel => csay_level);
		IF vaccountcardlist.count > 0
		THEN
			FOR i IN 1 .. pcardlist.count
			LOOP
				j := vaccountcardlist.last;
				WHILE j IS NOT NULL
				LOOP
					IF pcardlist(i).pan = vaccountcardlist(j).pan
						AND pcardlist(i).mbr = vaccountcardlist(j).mbr
					THEN
						t.note(cmethod_name
							  ,'delete card [' || card.getmaskedpan(vaccountcardlist(j).pan) || '-' || vaccountcardlist(j).mbr ||
							   '] from list');
						vaccountcardlist.delete(j);
					END IF;
					j := vaccountcardlist.prior(j);
				END LOOP;
			END LOOP;
			j := vaccountcardlist.first;
			WHILE j IS NOT NULL
			LOOP
			
				IF getcontractnobycard(vaccountcardlist(j).pan, vaccountcardlist(j).mbr, FALSE) IS NULL
				THEN
					t.note(cmethod_name
						  ,'card [' || card.getmaskedpan(vaccountcardlist(j).pan) || '-' || vaccountcardlist(j).mbr ||
						   '] is not linked to any contract'
						  ,csay_level);
					IF psaverollback
					THEN
						contractrb.setlabel(crl_link_linkedcard);
						contractrb.setcvalue(ckey_pan, vaccountcardlist(j).pan);
						contractrb.setnvalue(ckey_mbr, vaccountcardlist(j).mbr);
					END IF;
				
					vaccount := account.getaccountrecord(paccount.accountno);
					vcard    := card.getcardrecord(vaccountcardlist(j).pan, vaccountcardlist(j).mbr);
					IF vaccount.idclient = vcard.idclient
					   AND vaccount.idclient != pcontract.idclient
					THEN
						t.note(cmethod_name, 'change client id', csay_level);
						changecardidclient(vaccountcardlist  (j).pan
										  ,vaccountcardlist  (j).mbr
										  ,pcontract.idclient);
						IF psaverollback
						THEN
							contractrb.setnvalue(ckey_idclient, vcard.idclient);
						END IF;
					END IF;
				
					t.var('vCard.CardProduct', vcard.cardproduct);
				
					vcard.supplementary := contracttools.getcardtype(vaccountcardlist(j).pan
																	,vaccountcardlist(j).mbr
																	,FALSE);
					t.var('[1] vCard.Supplementary', vcard.supplementary);
					vitemcode := contractcard.getitemcodebycardproduct(pcontract.type
																	  ,vcard.cardproduct
																	  ,pcardtype => vcard.supplementary);
				
					s.say(cmethod_name || ': item code=' || vitemcode, csay_level);
					IF vitemcode IS NULL
					THEN
						s.say(cmethod_name || ': no item code ', csay_level);
						error.raiseerror(err.geterrorcode()
										,'Error attempting to add card <' ||
										 getcardno(vaccountcardlist(j).pan
												  ,vaccountcardlist(j).mbr) ||
										 '> linked to account <' || paccount.accountno || '>: ' ||
										 err.getfullmessage);
					END IF;
					IF vcard.branchpart != pcontract.branchpart
					   AND (contractcard.getusecontractbranchpart(pcontract.type, vitemcode))
					THEN
						t.note(cmethod_name, 'change branchpart', csay_level);
						changecardbranchpart(vaccountcardlist    (j).pan
											,vaccountcardlist    (j).mbr
											,pcontract.branchpart);
						IF psaverollback
						THEN
							contractrb.setnvalue(ckey_branchpart, vcard.branchpart);
						END IF;
					END IF;
					IF addcard(pcontract.no
							  ,vaccountcardlist    (j).pan
							  ,vaccountcardlist    (j).mbr
							  ,contractcard.newlink
							  ,vitemcode) != 0
					THEN
						error.raisewhenerr();
						IF psavelog
						THEN
							a4mlog.cleanparamlist;
							a4mlog.addparamrec(clogparam_pan, vaccountcardlist(j).pan);
							a4mlog.addparamrec(clogparam_mbr, vaccountcardlist(j).mbr);
							IF a4mlog.logobject(object.gettype(contract.object_name)
											   ,pcontract.no
											   ,'linked card added'
											   ,a4mlog.act_add
											   ,a4mlog.putparamlist()
											   ,powner => getclientid(pcontract.no)) != 0
							THEN
								error.raisewhenerr();
							END IF;
							a4mlog.cleanparamlist;
						END IF;
					END IF;
				END IF;
				j := vaccountcardlist.next(j);
			END LOOP;
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE createorlinkaccount
	(
		pcontractno   IN tcontract.no%TYPE
	   ,poaccount     IN OUT typeaccountrow
	   ,psaverollback IN BOOLEAN := TRUE
	   ,psavelog      IN BOOLEAN := TRUE
	   ,pdoschemacall IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateOrLinkAccount';
		vcontract      typecontractparams;
		vaccountexists BOOLEAN;
		vacctypeparams contracttypeschema.accounttypeparams;
	
	BEGIN
		t.enter(cmethod_name
			   ,'[pContractNo=' || pcontractno || ', ItemName=' || poaccount.itemname ||
				', AccountNo=' || poaccount.accountno);
	
		getcontractrow(pcontractno, vcontract);
	
		vaccountexists := account.accountexist(poaccount.accountno);
		t.var('vAccountExists', t.b2t(vaccountexists));
		IF vaccountexists
		THEN
			t.note(cmethod_name, 'an attempt to link account', csay_level);
			linkexistaccounttocontract(poaccount
									  ,vcontract
									  ,psaverollback
									  ,psavelog
									  ,pdoschemacall => pdoschemacall);
		ELSE
			t.note(cmethod_name, 'an attempt to create account', csay_level);
			IF contractaccount.checkrefaccounttype(poaccount.refaccounttype
												  ,contractaccount.refaccounttype_table)
			THEN
			
				s.say(cmethod_name || ': RefAccountType_Table', csay_level);
				vacctypeparams := contracttypeschema.getaccounttypeparams(pcontractno
																		 ,poaccount.itemname);
				s.say(cmethod_name || ': got vAccTypeParams', csay_level);
				poaccount.accounttype := ctaccounttypeperiod.getaccounttype(vcontract.type
																		   ,poaccount.itemname
																		   ,vacctypeparams);
				s.say(cmethod_name || ': vAccount.AccountType=' || poaccount.accounttype
					 ,csay_level);
			END IF;
			addnewclientaccounttocontract(poaccount
										 ,vcontract
										 ,psavelog
										 ,psaverollback
										 ,pdoschemacall => pdoschemacall);
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE createaccount
	(
		pcontractno     IN tcontract.no%TYPE
	   ,poaccount       IN OUT typeaccountrow
	   ,pmove2history   IN BOOLEAN := FALSE
	   ,psaverollback   IN BOOLEAN := TRUE
	   ,psavelog        IN BOOLEAN := TRUE
	   ,prestoreaccount IN BOOLEAN := TRUE
	   ,pdoschemacall   IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateAccount[1]';
	
		voperdate DATE := seance.getoperdate();
	
		vaccountnobyitem   taccount.accountno%TYPE;
		vaccountitemexists BOOLEAN;
	
		verrcode        NUMBER;
		vaccfromhistory contractaccounthistory.typecontractacchistory;
	BEGIN
		t.enter(cmethod_name
			   ,'[pContractNo=' || pcontractno || ',Move2History=' ||
				htools.bool2str(pmove2history) || ',pSaveRollBack=' ||
				htools.bool2str(psaverollback) || ',pSaveLog=' || htools.bool2str(psavelog) ||
				', ItemName=' || poaccount.itemname || ', AccountNo=' || poaccount.accountno ||
				', pRestoreAccount=' || htools.bool2str(prestoreaccount)
			   ,csay_level);
		t.var('OperDate', voperdate, csay_level);
		err.seterror(0, cmethod_name);
	
		vaccountnobyitem   := getaccountnobyitemname(pcontractno, poaccount.itemname);
		vaccountitemexists := vaccountnobyitem IS NOT NULL;
		verrcode           := err.geterrorcode;
		t.var('vAccountNoByItem', vaccountnobyitem, csay_level);
	
		IF verrcode = err.contract_item_not_found
		THEN
			err.seterror(0, cmethod_name);
		END IF;
		IF verrcode <> 0
		THEN
			error.raisewhenerr();
		END IF;
	
		IF vaccountitemexists
		THEN
			IF pmove2history
			THEN
			
				deleteaccountfromcontract(pcontractno
										 ,vaccountnobyitem
										 ,psaverollback
										 ,psavelog
										 ,pmove2history);
			
				IF nvl(prestoreaccount, TRUE)
				   AND contractaccounthistory.accountexistinhistory(pcontractno
																   ,poaccount.itemname
																   ,poaccount.accounttype
																   ,vaccfromhistory)
				THEN
					s.say(cmethod_name || ': 1. vAccFromHistory.AccountNo=' ||
						  vaccfromhistory.acchistory.accountno
						 ,csay_level);
				
					---contractaccounthistory.restoreaccount(vaccfromhistory, psaverollback, psavelog);
					poaccount.accountno := vaccfromhistory.acchistory.accountno;
				ELSE
					createorlinkaccount(pcontractno
									   ,poaccount
									   ,psaverollback
									   ,psavelog
									   ,pdoschemacall);
				END IF;
			ELSE
				error.raiseerror('Contract [' || pcontractno || '] already has account with ID [' ||
								 poaccount.itemname || ']');
			END IF;
		
		ELSE
			createorlinkaccount(pcontractno, poaccount, psaverollback, psavelog, pdoschemacall);
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE createaccount
	(
		pcontractno     IN tcontract.no%TYPE
	   ,pitemname       IN tcontracttypeitemname.itemname%TYPE
	   ,pmove2history   IN BOOLEAN := FALSE
	   ,psaverollback   IN BOOLEAN := TRUE
	   ,psavelog        IN BOOLEAN := TRUE
	   ,paccountno      IN taccount.accountno%TYPE := NULL
	   ,prestoreaccount IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateAccount[2]';
		vaccount  typeaccountrow;
		vcontract typecontractparams;
		voperdate DATE := seance.getoperdate();
	BEGIN
		s.say(cmethod_name || ': begin [pContractNo=' || pcontractno || ',pItemName=' || pitemname ||
			  ',Move2History=' || htools.bool2str(pmove2history) || ',pSaveRollBack=' ||
			  htools.bool2str(psaverollback) || ',pSaveLog=' || htools.bool2str(psavelog) ||
			  ', pAccountNo=' || paccountno || ', pRestoreAccount=' ||
			  htools.bool2str(prestoreaccount) || ']'
			 ,csay_level);
		s.say(cmethod_name || ': [OperDate=' || voperdate || ']', csay_level);
		getcontractrow(pcontractno, vcontract);
	
		--vaccount := contractaccount.loadaccount(vcontract.type, pitemname);
		IF paccountno IS NOT NULL
		THEN
		
			vaccount.accountno   := paccountno;
			vaccount.accounttype := account.getaccounttype(paccountno);
		END IF;
	
		createaccount(pcontractno
					 ,vaccount
					 ,pmove2history
					 ,psaverollback
					 ,psavelog
					 ,prestoreaccount
					 ,TRUE);
		s.say(cmethod_name || ': vAccount.AccountType=' || vaccount.accounttype, csay_level);
		s.say(cmethod_name || ': ended', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE addaccounts2contract
	(
		pcontract     IN typecontractparams
	   ,paaccountlist IN typeaccountarray
	   ,psaverollback IN BOOLEAN := TRUE
	   ,psavelog      IN BOOLEAN := FALSE
	   ,pacardlist    IN typecardparamsarray := saemptycardlist
	   ,pmode         IN typeaddaccountmode := caamode_addtocontract
	   ,pschparams    IN VARCHAR2 := semptyparams
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddAccounts2Contract';
		vaaccountlist typeaccountarray;
		vindex        NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontract.no || ', AccCount=' || paaccountlist.count ||
				', CrdCount=' || pacardlist.count || '-------------------'
			   ,csay_level);
		vaaccountlist := paaccountlist;
	
		--contracttypeschema.oncreateaccounts(pcontract.no, pmode, pschparams, vaaccountlist);
	
		FOR i IN 1 .. vaaccountlist.count
		LOOP
			t.var('vaAccountList(' || i || ').ItemCode', vaaccountlist(i).itemcode, csay_level);
			t.var('vaAccountList(' || i || ').AccountNo', vaaccountlist(i).accountno, csay_level);
		
			vindex := i;
			IF account.accountexist(vaaccountlist(i).accountno)
			THEN
				t.note(cmethod_name, 'account was found', csay_level);
				IF NOT pcontract.addexistacc
				THEN
					t.note(cmethod_name, 'error, account already exist', csay_level);
					error.raiseerror('Attempted addition of existing account to contract');
				END IF;
				t.note(cmethod_name, 'add existing account to the contract', csay_level);
			
				IF ctdialog.addlinkedcard(pcontract.type)
				THEN
					t.note(cmethod_name, 'add linked cards', csay_level);
				
					addlinkedcard(vaaccountlist(i), pcontract, pacardlist, psaverollback, psavelog);
				END IF;
				t.note(cmethod_name
					  ,'link account [' || vaaccountlist(i).accountno || '] to contract [' ||
					   pcontract.no || ']'
					  ,csay_level);
				linkexistaccounttocontract(vaaccountlist(i)
										  ,pcontract
										  ,psaverollback
										  ,psavelog
										  ,pdoschemacall => FALSE);
			ELSE
				t.note(cmethod_name, 'account was not found', csay_level);
				IF vaaccountlist(i).createmode IS NULL
				THEN
					vaaccountlist(i).createmode := contractaccount.getcreatemode(vaaccountlist(i)
																				 .itemcode);
					t.var('vaAccountList(i).CreateMode', vaaccountlist(i).createmode);
				END IF;
			
				IF vaaccountlist(i).itemname IS NULL
				THEN
					vaaccountlist(i).itemname := contracttypeitems.getcitnamerecord(vaaccountlist(i).itemcode)
												 .itemname;
					t.var('vaAccountList(i).ItemName', vaaccountlist(i).itemname);
				END IF;
			
				IF vaaccountlist(i).refaccounttype IS NULL
				THEN
					vaaccountlist(i).refaccounttype := contracttypeitems.getcitnamerecord(vaaccountlist(i).itemcode)
													   .refaccounttype;
					t.var('vaAccountList(i).RefAccountType', vaaccountlist(i).refaccounttype);
				END IF;
				IF (vaaccountlist(i)
				   .createmode IN
					(contractaccount.createmode_atonceonly, contractaccount.createmode_atoncedefault))
				   OR vaaccountlist(i).accountno IS NOT NULL
				THEN
					IF (vaaccountlist(i).itemcode IS NULL OR
						contractaccount.getcurrency(vaaccountlist(i).itemcode) IS NULL AND vaaccountlist(i)
					   .refaccounttype != contractaccount.refaccounttype_currency)
					THEN
						error.raiseerror('Contract type <' || pcontract.type ||
										 '> contains invalid or no information on account types');
					END IF;
				
					t.note(cmethod_name, 'create client account', csay_level);
					createaccount(pcontract.no, vaaccountlist(i), FALSE, FALSE, psavelog, FALSE);
				ELSE
					t.note(cmethod_name, 'skip creating client account', csay_level);
				END IF;
			END IF;
		END LOOP;
		vindex := NULL;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			seterraccindex(vindex);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setcurrentuserproplist(puserproplist IN apitypes.typeuserproplist) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCurrentUserPropList';
	BEGIN
		scurrentuserproplist := puserproplist;
		setischangeduserattrlist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcurrentuserproplist RETURN apitypes.typeuserproplist IS
		cmethod_name CONSTANT VARCHAR2(64) := cpackage_name || '.GetCurrentUserPropList';
	BEGIN
		t.var('sCurrentUserPropList.count', scurrentuserproplist.count);
		RETURN scurrentuserproplist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setcurrentextrauserproplist(puserproplist IN apitypes.typeuserproplist) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCurrentExtraUserPropList';
	BEGIN
		scurrentextrauserproplist := puserproplist;
		setischangedextrauserattrlist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcurrentextrauserproplist RETURN apitypes.typeuserproplist IS
		cmethod_name CONSTANT VARCHAR2(64) := cpackage_name || '.GetCurrentExtraUserPropList';
	BEGIN
		t.var('sCurrentExtraUserPropList.count', scurrentextrauserproplist.count);
		RETURN scurrentextrauserproplist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setcurrent(prec apitypes.typecontractrecord) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCurrent';
	BEGIN
		scurrentrecord := prec;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcurrent RETURN apitypes.typecontractrecord IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCurrent';
	BEGIN
		t.note(cmethod_name, 'sCurrentRecord.No=' || scurrentrecord.no);
		RETURN scurrentrecord;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE clearcurrent IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ClearCurrent';
		vemptyrec apitypes.typecontractrecord;
	BEGIN
		scurrentrecord := vemptyrec;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION convert2apitypes(prow tcontract%ROWTYPE) RETURN apitypes.typecontractrecord IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.Convert2APITypes';
		vrec apitypes.typecontractrecord;
	BEGIN
		vrec.no          := prow.no;
		vrec.type        := prow.type;
		vrec.idclient    := prow.idclient;
		vrec.branchpart  := prow.branchpart;
		vrec.createclerk := prow.createclerk;
		vrec.createdate  := prow.createdate;
		vrec.closeclerk  := prow.closeclerk;
		vrec.closedate   := prow.closedate;
		vrec.status      := prow.status;
	
		RETURN vrec;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE execcontrolblock_updatevalues
	(
		pcontractrecord IN OUT typecontractrec
	   ,paccessory      IN PLS_INTEGER
	   ,pblockparams    IN typecontractblockparams
	)
	
	 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExecControlBlock_UpdateValues';
	BEGIN
		t.enter(cmethod_name
			   ,'pContractRecord.ContractRow.No=' || pcontractrecord.contractrow.no ||
				', pContractRecord.ContractRow.Type=' || pcontractrecord.contractrow.type ||
				', pContractRecord.UserProperty.count=' || pcontractrecord.userproperty.count ||
				', pContractRecord.ExtraUserProperty.count=' ||
				pcontractrecord.extrauserproperty.count || ', pBlockParams.ContractType=' ||
				pblockparams.contracttype || ', pBlockParams.OperationType=' ||
				pblockparams.operationtype || ', pBlockParams.OperationMode=' ||
				pblockparams.operationmode);
	
		IF pblockparams.operationtype IS NOT NULL
		   AND nvl(pblockparams.operationmode, c_unknownmode) != c_rollbackmode
		   AND
		   pblockparams.operationtype IN (action_contractcreation
										 ,action_clientchange
										 ,action_contracttypechange
										 ,action_contractsaving)
		THEN
			setcurrent(convert2apitypes(pcontractrecord.contractrow));
			setcurrentuserproplist(pcontractrecord.userproperty);
			setcurrentextrauserproplist(pcontractrecord.extrauserproperty);
			s.say(cmethod_name || ': p1');
			resetblockupdatevaluesparams;
			/*   
            contractblocks.run(contractblocks.bt_updatevalues
                              ,pcontractrecord.contractrow.no
                              ,paccessory
                              ,object_name
                              ,pblockparams);*/
		
			pcontractrecord.userproperty      := getcurrentuserproplist();
			pcontractrecord.extrauserproperty := getcurrentextrauserproplist();
			clearcurrent();
		ELSE
			s.say(cmethod_name || ': p2');
			resetblockupdatevaluesparams;
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			clearcurrent();
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setuserproplistbyhandle
	(
		phandle       IN NUMBER
	   ,puserproplist IN apitypes.typeuserproplist
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.SetUserPropListByHandle';
	BEGIN
		t.enter(cmethod_name
			   ,'pHandle= ' || phandle || ', pUserPropList.count=' || puserproplist.count);
	
		IF scontractarray.exists(phandle)
		THEN
			scontractarray(phandle).userproperty := puserproplist;
		ELSE
			error.raiseerror('Handle ' || phandle || ' not found!');
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setextrauserproplistbyhandle
	(
		phandle       IN NUMBER
	   ,puserproplist IN apitypes.typeuserproplist
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.SetExtraUserPropListByHandle';
	BEGIN
		t.enter(cmethod_name
			   ,'pHandle= ' || phandle || ', pUserPropList.count=' || puserproplist.count);
	
		IF scontractarray.exists(phandle)
		THEN
			scontractarray(phandle).extrauserproperty := puserproplist;
		ELSE
			error.raiseerror('Handle ' || phandle || ' not found!');
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE createcontract
	(
		pcontract         IN OUT typecontractparams
	   ,paaccounts        IN typeaccountarray
	   ,pacards           IN typecardparamsarray
	   ,paacc2cardlinks   IN typeacc2cardarray
	   ,pcmsparams        IN typecmsparams := NULL
	   ,pguid             IN types.guid := NULL
	   ,pautocreateparams IN typeautocreateparams := semptyautocreateparams
	   ,palinkedtypelist  IN types.arrnum := saemptylinkedtypelist
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateContract[2]';
		vcard          typecardparams;
		vhandle        NUMBER;
		vnew           BOOLEAN;
		vrollbackdata1 tcontract.rollbackdata%TYPE;
		vrollbackdata2 tcontract.rollbackdata%TYPE;
	
		valinkedtypelist  types.arrnum;
		vlinkedcontract   apitypes.typecontractrecord;
		vautocreateparams typeautocreateparams := pautocreateparams;
		valinkedcontracts types.arrstr100;
		vpackno           NUMBER;
	
		vlinkedparams     tcontract.rollbackdata%TYPE;
		vaparamscontracts contracttools.typestrbystr;
		vblockparams      typecontractblockparams;
	BEGIN
		t.note('--------------- CREATE CONTRACT -----------------------------------');
		t.enter(cmethod_name
			   ,'pContract.No=[' || pcontract.no || '] paAccounts.Count=[' || paaccounts.count ||
				'] paCards.Count=[' || pacards.count || '] pAutoCreateParams.Level=[' ||
				pautocreateparams.level || '] pAutoCreateParams.MainContractNo=[' ||
				pautocreateparams.maincontractno || '] ' || 'paLinkedTypeList.Count=' ||
				palinkedtypelist.count
			   ,csay_level);
		err.seterror(0, cmethod_name);
		BEGIN
			srollbackdata := NULL;
			vpackno       := contractrb.init();
		
			t.var('pContract.No', pcontract.no, csay_level);
			t.var('pContract.Type', pcontract.type, csay_level);
			t.var('pContract.IdClient', pcontract.idclient, csay_level);
			t.var('Contract.sParams', sparams);
		
			IF sparams IS NOT NULL
			THEN
			
				vaparamscontracts := contracttools.parsedelimparamlinkcontract(sparams);
			
				sparams := vaparamscontracts('MAIN');
			
			END IF;
		
			pcontract.no := TRIM(pcontract.no);
			makenewcontract(pcontract, pguid);
			setcurrentno(pcontract.no);
		
			t.var('paAccounts.count', paaccounts.count, csay_level);
			addaccounts2contract(pcontract
								,paaccounts
								,TRUE
								,FALSE
								,pacards
								,caamode_createcontract
								,sparams);
		
			t.var('paCards.count', pacards.count, csay_level);
		
			FOR i IN 1 .. pacards.count
			LOOP
			
				vcard := pacards(i);
			
				t.var(': PAN', card.getmaskedpan(vcard.pan), csay_level);
				t.var(': MBR', vcard.mbr, csay_level);
				t.var(': CardProduct', vcard.cardproduct, csay_level);
				t.var(': Insure', vcard.insure, csay_level);
				t.var(': OrderDate', vcard.orderdate, csay_level);
				t.var(': CancelDate', vcard.canceldate, csay_level);
				t.var(': FinProfile', vcard.finprofile, csay_level);
				t.var(': PINOFFSET', vcard.pinoffset, csay_level);
				t.var(': CVV', vcard.cvv, csay_level);
				t.var(': CVV2', vcard.cvv2, csay_level);
				t.var(': ItemCode', vcard.itemcode, csay_level);
				t.var(': IdClient', vcard.idclient, csay_level);
				t.var(': FinProfile', vcard.finprofile, csay_level);
				t.var(': ECStatus', to_char(vcard.ecstatus), csay_level);
			
				setcurrentcard(vcard);
			
				IF vcard.pan IS NOT NULL
				THEN
					addcardbypan2(pcontract.no, vcard, pcmsparams, pcontract.addexistcard, TRUE);
				ELSE
					createcards(contractcard.newcreate, pcontract, vcard, pcmsparams, TRUE);
				END IF;
			
			END LOOP;
		
			t.var(cmethod_name
				 ,': create user properties ' || htools.bool2str(pcontract.createuserproperty)
				 ,csay_level);
		
			IF pcontract.createuserproperty
			THEN
				t.var('pContract.UserProperty.count', pcontract.userproperty.count, csay_level);
				t.var('pContract.ObjectUID', pcontract.objectuid, csay_level);
				objuserproperty.newrecord(object_name
										 ,pcontract.objectuid
										 ,pcontract.userproperty
										 ,plog_clientid => pcontract.idclient);
				t.var('pContract.ExtraUserProperty.Count'
					 ,pcontract.extrauserproperty.count
					 ,csay_level);
				objuserproperty.newrecord(object_name
										 ,pcontract.objectuid
										 ,pcontract.extrauserproperty
										 ,psubobject                  => to_char(pcontract.type)
										 ,plog_clientid               => pcontract.idclient);
			END IF;
		
			IF pautocreateparams.level = 2
			THEN
				contracttypeschema.autocreate_makelink(pautocreateparams.maincontractno
													  ,pcontract.no);
			END IF;
		
			--contracttypeschema.oncreatecontract(pcontract.no, sparams);
		
			vrollbackdata1 := contractrb.done(vpackno);
		
		EXCEPTION
			WHEN OTHERS THEN
				contractrb.clearlaststate();
				RAISE;
		END;
	
		vrollbackdata2 := service.iif((vrollbackdata1 IS NULL AND srollbackdata IS NULL)
									 ,''
									 ,cseparator) || srollbackdata;
	
		srollbackdata := vrollbackdata1 || vrollbackdata2;
		t.var('sRollBackData', srollbackdata);
	
		evncontractopen.put(pcontract.no, seance.getoperdate());
	
		IF pcontract.creationmode = ccreation_interactivemode
		THEN
			valinkedtypelist := palinkedtypelist;
		ELSE
			valinkedtypelist := contractlink.getconvertedlinkedtypes(contractlink.gettype2typelist(pcontract.type
																								  ,contractlink.cmain
																								  ,plinkname          => NULL
																								  ,plinkcode          => NULL
																								  ,pautocreate        => TRUE));
		END IF;
	
		IF valinkedtypelist.count > 0
		THEN
		
			IF vautocreateparams.level < 2
			THEN
				clearnewcardlist();
				FOR i IN 1 .. valinkedtypelist.count
				LOOP
					vlinkedcontract.type       := valinkedtypelist(i);
					vlinkedcontract.idclient   := pcontract.idclient;
					vlinkedcontract.createdate := pcontract.createdate;
					vlinkedcontract.branchpart := pcontract.branchpart;
				
					vautocreateparams.maincontractno := pcontract.no;
					vautocreateparams.level          := nvl(pautocreateparams.level, 1) + 1;
				
					t.note(cmethod_name
						  ,'try to create linked contract Type=[' || vlinkedcontract.type || ']'
						  ,csay_level);
				
					IF vaparamscontracts.count > 1
					THEN
						vlinkedparams := contracttools.getparamsbycontracttype(vlinkedcontract.type
																			  ,vaparamscontracts);
						IF vlinkedparams IS NOT NULL
						THEN
							createcontract(vlinkedcontract
										  ,pschparams        => vlinkedparams
										  ,pautocreateparams => vautocreateparams);
						END IF;
					ELSE
						createcontract(vlinkedcontract, pautocreateparams => vautocreateparams);
					END IF;
					t.note(cmethod_name
						  ,'created linked contract No=[' || vlinkedcontract.no || ']'
						  ,csay_level);
					valinkedcontracts(i) := vlinkedcontract.no;
					vlinkedcontract.no := NULL;
				END LOOP;
			
				BEGIN
					vpackno := contractrb.init();
					contractrb.setlabel(crl_create_contract);
					FOR i IN 1 .. valinkedcontracts.count
					LOOP
						contractrb.setnextcvalue(ckey_linkedcontract, valinkedcontracts(i));
					END LOOP;
					vrollbackdata1 := vrollbackdata1 || contractrb.done(vpackno);
				EXCEPTION
					WHEN OTHERS THEN
						contractrb.clearlaststate();
						RAISE;
				END;
				vrollbackdata1 := vrollbackdata1 ||
								  service.iif((vrollbackdata1 IS NULL AND vrollbackdata2 IS NULL)
											 ,''
											 ,cseparator);
			END IF;
		END IF;
	
		vhandle := gethandle(pcontract.no);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontract.no, 'R');
			vnew    := TRUE;
		END IF;
		t.var('vNew', t.b2t(vnew), csay_level);
		t.var('RollbackData1||2', vrollbackdata1 || vrollbackdata2, csay_level);
		scontractarray(vhandle).contractrow.rollbackdata := vrollbackdata1 || vrollbackdata2;
	
		IF nvl(pcontract.operationmode, c_unknownmode) = c_interactivemode
		THEN
			setuserproplistbyhandle(vhandle, pcontract.userproperty);
			setextrauserproplistbyhandle(vhandle, pcontract.extrauserproperty);
		END IF;
		vblockparams.contracttype  := pcontract.type;
		vblockparams.operationtype := action_contractcreation;
		vblockparams.operationmode := pcontract.operationmode;
	
		writeobject(vhandle, vblockparams);
	
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
	
		clearcurrentno;
		setcurrentemptycard();
		err.seterror(0, cmethod_name);
		t.leave(cmethod_name, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			clearcurrentno;
			t.exc(cmethod_name, ': general exception, ' || SQLERRM, csay_level);
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END createcontract;

	PROCEDURE createcontract
	(
		pcontractrec       IN OUT apitypes.typecontractrecord
	   ,pschparams         IN VARCHAR2 := NULL
	   ,pcontuserdata      IN apitypes.typeuserproplist := semptyrec
	   ,pcontextrauserdata IN apitypes.typeuserproplist := semptyrec
	   ,pautocreateparams  IN typeautocreateparams := semptyautocreateparams
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateContract[3]';
		vnewcontract     contract.typecontractparams;
		vaaccounts       contract.typeaccountarray;
		vacards          contract.typecardparamsarray;
		vaacc2cardlinks  contract.typeacc2cardarray;
		varraysize       NUMBER;
		varraysize2      NUMBER;
		vindex           NUMBER;
		vindex2          NUMBER;
		valinkedtypelist types.arrnum;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractRec.Type=[' || pcontractrec.type || '] pAutoCreateParams.Level=[' ||
				pautocreateparams.level || '] pAutoCreateParams.MainContractNo=[' ||
				pautocreateparams.maincontractno || ']'
			   ,csay_level);
		t.inpar('pSchParams', pschparams);
	
		IF pcontractrec.no IS NOT NULL
		THEN
			checkincorrectno(pcontractrec.no);
		END IF;
	
		IF contracttype.getname(pcontractrec.type) IS NULL
		THEN
			error.raiseerror('Contract type <' || pcontractrec.type || '> not found');
		END IF;
	
		IF NOT client.objectexists(pcontractrec.idclient)
		THEN
			error.raiseerror('ClientId <' || pcontractrec.idclient || '> not found');
		END IF;
	
		vnewcontract.no                := TRIM(pcontractrec.no);
		vnewcontract.type              := pcontractrec.type;
		vnewcontract.idclient          := pcontractrec.idclient;
		vnewcontract.createdate        := pcontractrec.createdate;
		vnewcontract.userproperty      := pcontuserdata;
		vnewcontract.extrauserproperty := pcontextrauserdata;
		vnewcontract.branchpart        := pcontractrec.branchpart;
	
		varraysize := contractaccount.initarray(vnewcontract.type);
		IF (varraysize = 0)
		THEN
			error.raiseerror('Contract type <' || vnewcontract.type || '> not specified');
		END IF;
	
		FOR i IN 1 .. varraysize
		LOOP
			vaaccounts(i).accountno := NULL;
			vaaccounts(i).itemcode := contractaccount.getarrayitemcode(i);
			vaaccounts(i).createmode := contractaccount.getarraycreatemode(i);
			vaaccounts(i).refaccounttype := contractaccount.getarrayrefacctype(i);
			vaaccounts(i).extaccount := NULL;
		
			IF (vaaccounts(i)
			   .itemcode IS NULL OR contractaccount.getcurrency(vaaccounts(i).itemcode) IS NULL AND vaaccounts(i)
			   .refaccounttype != contractaccount.refaccounttype_currency)
			THEN
				error.raiseerror('Contract type <' || vnewcontract.type ||
								 '> contains invalid or no information on account types');
			END IF;
		END LOOP;
	
		vindex     := 0;
		vindex2    := 0;
		varraysize := contractcard.initarray(vnewcontract.type);
		FOR i IN 1 .. varraysize
		LOOP
			IF contractcard.getarraymark(i)
			THEN
				ktools.inc(vindex);
				vacards(vindex).itemcode := contractcard.getarrayitemcode(i);
				vacards(vindex).cardproduct := contractcard.getarraycardproduct(i);
				vacards(vindex).finprofile := contractcard.getarrayfinprofile(i);
				vacards(vindex).grplimit := contractcard.getarraygrplimit(i);
				vacards(vindex).currencyno := contractcard.getarraylimitcurrency(i);
				varraysize2 := contractcard.initacc2cardarray(vnewcontract.type
															 ,vacards(vindex).itemcode);
				IF (varraysize2 = 0)
				THEN
					error.raiseerror('Linked accounts not specified for card product <' ||
									 referencecardproduct.getname(vacards(vindex).cardproduct) || '>');
				END IF;
			
				FOR j IN 1 .. varraysize2
				LOOP
					ktools.inc(vindex2);
					vaacc2cardlinks(vindex2).carditemcode := vacards(vindex).itemcode;
					vaacc2cardlinks(vindex2).accountitemcode := contractcard.getacc2carditemcode(j);
					vaacc2cardlinks(vindex2).acct_stat := contractcard.getacc2cardacct_stat(j);
					vaacc2cardlinks(vindex2).description := contractcard.getacc2carddescription(j);
				END LOOP;
			END IF;
		END LOOP;
	
		contract.sparams := pschparams;
	
		valinkedtypelist := contractlink.getconvertedlinkedtypes(contractlink.gettype2typelist(vnewcontract.type
																							  ,contractlink.cmain
																							  ,plinkname          => NULL
																							  ,plinkcode          => NULL
																							  ,pautocreate        => FALSE));
		/*      createcontract(vnewcontract
                          ,vaaccounts
                          ,vacards
                          ,vaacc2cardlinks
                          ,pguid             => pcontractrec.guid
                          ,pautocreateparams => pautocreateparams
                          ,palinkedtypelist  => valinkedtypelist);
        */
		error.raisewhenerr();
	
		pcontractrec.no := vnewcontract.no;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			contract.sparams := NULL;
			RAISE;
	END createcontract;

	PROCEDURE deletecontract
	(
		pno           IN tcontract.no%TYPE
	   ,pdeleteclient IN BOOLEAN := FALSE
	   ,pmode         IN PLS_INTEGER := c_rollbackmode
	)
	
	 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DeleteContract';
	
		vret NUMBER;
	
		vcardrec      typecardparams;
		vexistcard    typeexistcardarr;
		vexistaccount typeexistaccountarr;
		vcnsid        typecnsidarr;
		vhandle       NUMBER;
		vseppos       NUMBER;
		v1part        tcontract.rollbackdata%TYPE;
		v2part        tcontract.rollbackdata%TYPE;
		cbranch CONSTANT NUMBER := seance.getbranch();
	
		vmode PLS_INTEGER;
	
		CURSOR curcardlist
		(
			pbranch     IN tcontract.branch%TYPE
		   ,pcontractno IN tcontract.no%TYPE
		) IS
		
			SELECT t1.*
			FROM   tcontractcarditem t1
			INNER  JOIN tcard t2
			ON     t2.branch = t1.branch
			AND    t2.pan = t1.pan
			AND    t2.mbr = t1.mbr
			WHERE  t1.branch = pbranch
			AND    t1.no = pcontractno
			AND    t2.mainpan IS NULL
			FOR    UPDATE wait 5;
	
		CURSOR curaccountlist
		(
			pbranch     IN tcontract.branch%TYPE
		   ,pcontractno IN tcontract.no%TYPE
		) IS
			SELECT *
			FROM   tcontractitem
			WHERE  branch = pbranch
			AND    no = pcontractno
			FOR    UPDATE;
	
	BEGIN
	
		t.enter(cmethod_name
			   ,'pNo=' || pno || ', pDeleteClient=' || t.b2t(pdeleteclient) || ', pMode=' || pmode
			   ,csay_level);
	
		err.seterror(0, cmethod_name);
	
		IF NOT checkright(right_delete)
		THEN
			err.seterror(err.contract_security_failure, cmethod_name);
			RETURN;
		END IF;
	
		SAVEPOINT contractdeletecontract;
	
		vhandle := gethandle(pno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pno, 'R');
		END IF;
	
		IF scontractarray(vhandle).contractmode != 'W'
		THEN
			changeobjectmode(vhandle, 'W');
			error.raisewhenerr();
		END IF;
	
		vmode := nvl(pmode, c_rollbackmode);
		t.var('vMode', vmode);
		execcontrolblock_ondelete(vmode, pno);
	
		t.var('RollBackData', scontractarray(vhandle).contractrow.rollbackdata, csay_level);
		vseppos := instr(scontractarray(vhandle).contractrow.rollbackdata, cseparator, 1);
		t.var('vSepPos', vseppos, csay_level);
	
		IF vseppos > 0
		THEN
			v1part        := substr(scontractarray(vhandle).contractrow.rollbackdata
								   ,1
								   ,vseppos - 1);
			v2part        := substr(scontractarray(vhandle).contractrow.rollbackdata
								   ,vseppos + length(cseparator));
			srollbackdata := v2part;
		ELSE
			srollbackdata := scontractarray(vhandle).contractrow.rollbackdata;
		END IF;
	
		---contracttypeschema.onundocreatecontract(pno, srollbackdata);
	
		IF v1part IS NOT NULL
		THEN
			v2part        := contractrb.undo(pno, v1part);
			srollbackdata := v2part || srollbackdata;
		END IF;
	
		parserollbackdata(srollbackdata, vexistcard, vexistaccount, vcnsid);
	
		s.say(cmethod_name || ': delete cards ', csay_level);
		FOR i IN curcardlist(cbranch, pno)
		LOOP
			t.note(cmethod_name
				  ,'card [' || card.getmaskedpan(i.pan) || '-' || i.mbr || ']'
				  ,csay_level);
			vcardrec.pan      := i.pan;
			vcardrec.mbr      := i.mbr;
			vcardrec.itemcode := i.itemcode;
			deleteorunlinkcard(pno, vcardrec, vexistcard, vcnsid, c_rollbackmode);
		END LOOP;
	
		s.say(cmethod_name || ': delete accounts ', csay_level);
		FOR i IN curaccountlist(cbranch, pno)
		LOOP
			s.say(cmethod_name || ': delete account ' || i.key, csay_level);
			deleteorunlinkaccount(pno, i.key, vexistaccount);
		END LOOP;
	
		referenceprchistory.deletepercentbelong(referenceprchistory.ccontract, pno);
		referenceprchistory.deletepercentname(referenceprchistory.ccontract, pno);
	
		t.note(cmethod_name
			  , 'deleting contract user properties, UID=' || scontractarray(vhandle)
			   .contractrow.objectuid);
		objuserproperty.deleterecord(object_name
									,scontractarray(vhandle).contractrow.objectuid
									,plog_clientid  => scontractarray(vhandle).contractrow.idclient);
		t.note(cmethod_name
			  , 'deleting contract extra user properties, UID=' || scontractarray(vhandle)
			   .contractrow.objectuid);
		objuserproperty.deleterecord(object_name
									,scontractarray(vhandle).contractrow.objectuid
									,psubobject     => to_char(scontractarray(vhandle)
															   .contractrow.type)
									,plog_clientid  => scontractarray(vhandle).contractrow.idclient);
	
		deletecontractrecord(pno, c_rollbackmode);
		IF pdeleteclient
		THEN
			s.say(cmethod_name || ': delete client ', csay_level);
			client.deleteclient(scontractarray(vhandle).contractrow.idclient);
			error.raisewhenerr();
		
			vret := a4mlog.logobject(object.gettype(contract.object_name)
									,pno
									,'Delete contract with customer data'
									,a4mlog.act_del
									,powner => scontractarray(vhandle).contractrow.idclient);
		ELSE
			vret := a4mlog.logobject(object.gettype(contract.object_name)
									,pno
									,'Delete contract'
									,a4mlog.act_del
									,powner => scontractarray(vhandle).contractrow.idclient);
		END IF;
		IF vret != 0
		THEN
			error.raisewhenerr();
		END IF;
		IF vhandle IS NOT NULL
		THEN
			freeobject(vhandle);
		END IF;
		srollbackdata := NULL;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN no_data_found THEN
			t.exc(cmethod_name, '[1]', csay_level);
			srollbackdata := NULL;
			IF vhandle IS NOT NULL
			THEN
				freeobject(vhandle);
			END IF;
			ROLLBACK TO contractdeletecontract;
			err.seterror(err.contract_not_found, cmethod_name);
		WHEN OTHERS THEN
			t.exc(cmethod_name, '[2]', csay_level);
			srollbackdata := NULL;
			t.note(cmethod_name, 'general exception: ' || SQLERRM, csay_level);
		
			IF vhandle IS NOT NULL
			THEN
				freeobject(vhandle);
			END IF;
			ROLLBACK TO contractdeletecontract;
			IF SQLCODE = -2292
			THEN
				err.seterror(err.contract_exist_active_items, cmethod_name);
			ELSE
				error.save(cmethod_name);
				RAISE;
			END IF;
	END deletecontract;

	FUNCTION deletecard
	(
		pno  IN tcontract.no%TYPE
	   ,ppan IN tcard.pan%TYPE
	   ,pmbr IN tcard.mbr%TYPE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DeleteCard';
		vcardrec typecardparams;
	
		vcontract     typecontractitemrecord;
		vexistcard    typeexistcardarr;
		vexistaccount typeexistaccountarr;
		vcnsid        typecnsidarr;
	
	BEGIN
		s.say(cmethod_name || ': ' || card.getmaskedpan(ppan) || '-' || pmbr, csay_level);
		IF ppan IS NULL
		THEN
			RETURN 0;
		END IF;
	
		vcontract    := getcontractbycard(ppan, pmbr);
		vcardrec.pan := ppan;
		vcardrec.mbr := pmbr;
		IF vcontract.itemcode IS NOT NULL
		THEN
			vcardrec.itemcode := vcontract.itemcode;
		
		END IF;
	
		srollbackdata := contractrb.undo(pno, srollbackdata);
		IF srollbackdata IS NOT NULL
		THEN
			s.say(cmethod_name || ' point 1', csay_level);
			parserollbackdata(srollbackdata, vexistcard, vexistaccount, vcnsid);
		
			deleteorunlinkcard(pno, vcardrec, vexistcard, vcnsid, c_rollbackmode);
		ELSIF nvl(getcontractnobycard(ppan, pmbr, FALSE), 'NULL') = pno
		THEN
			s.say(cmethod_name || ' point 2', csay_level);
			deleteorunlinkcard(pno, vcardrec, vexistcard, vcnsid, c_rollbackmode);
		END IF;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END deletecard;

	PROCEDURE deletecardfromcontract
	(
		pno      IN tcontract.no%TYPE
	   ,ppan     IN tcard.pan%TYPE
	   ,pmbr     IN tcard.mbr%TYPE
	   ,pmakelog IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DeleteCardFromContract';
	
		vhandle NUMBER;
		vnew    BOOLEAN;
	BEGIN
		t.enter(cmethod_name
			   ,'pNo=' || pno || 'pPan=' || card.getmaskedpan(ppan) || ', pMBR=' || pmbr ||
				', pMakeLog=' || t.b2t(pmakelog)
			   ,csay_level);
	
		vhandle := gethandle(pno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pno, 'W');
			IF vhandle = 0
			THEN
				error.raiseerror(err.geterrorcode
								,'Contract is blocked: ' ||
								 object.capturedobjectinfo(object_name, pno));
			END IF;
			vnew := TRUE;
		END IF;
		IF scontractarray(vhandle).contractmode != 'W'
		THEN
			changeobjectmode(vhandle, 'W');
			error.raisewhenerr();
		END IF;
	
		deletecarditem(pno, ppan, pmbr);
	
		IF nvl(pmakelog, FALSE)
		THEN
			a4mlog.cleanparamlist;
			a4mlog.addparamrec(clogparam_pan, ppan);
			a4mlog.addparamrec(clogparam_mbr, pmbr);
			IF a4mlog.logobject(object.gettype(contract.object_name)
							   ,pno
							   ,'Delete card'
							   ,a4mlog.act_del
							   ,a4mlog.putparamlist()
							   ,powner => getclientid(pno)) != 0
			THEN
				error.raisewhenerr();
			END IF;
		END IF;
	
		writeobject(vhandle);
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END deletecardfromcontract;

	PROCEDURE moveonecard
	(
		ppan          tcard.pan%TYPE
	   ,pmbr          tcard.mbr%TYPE
	   ,pfromcontract tcontract.no%TYPE
	   ,ptocontract   tcontract.no%TYPE
	   ,puseonline    BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.MoveOneCard';
		vcontractrow    typecontractparams;
		vcardrow        typecardparams;
		vcode           NUMBER;
		vgroupfrom      NUMBER;
		vgroupto        NUMBER;
		vbasecontract   tcontract.no%TYPE;
		vupdaterevision tcontract.updaterevision%TYPE;
		vcardtype       tcard.supplementary%TYPE;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pPAN', card.getmaskedpan(ppan));
		t.inpar('pMBR', pmbr);
		t.inpar('pFromContract', pfromcontract);
		t.inpar('pToContract', ptocontract);
		t.inpar('pUseOnline', t.b2t(puseonline));
	
		vupdaterevision := getupdaterevision(pfromcontract);
	
		vgroupfrom := referencegroupcontract.getgroupbycontract(pfromcontract);
	
		IF vgroupfrom IS NOT NULL
		THEN
			vgroupto      := referencegroupcontract.getgroupbycontract(ptocontract);
			vbasecontract := referencegroupcontract.getbasecontract(vgroupfrom);
			IF vgroupfrom = vgroupto
			   AND ptocontract != vbasecontract
			THEN
				error.raiseerror('Impossible to move card to linked contract');
			END IF;
		END IF;
	
		vgroupto := referencegroupcontract.getgroupbycontract(ptocontract);
		IF vgroupto IS NOT NULL
		THEN
			vbasecontract := referencegroupcontract.getbasecontract(vgroupto);
			IF vbasecontract != ptocontract
			THEN
				error.raiseerror('Impossible to move card to linked contract');
			END IF;
		END IF;
	
		getcontractrow(ptocontract, vcontractrow);
	
		vcardrow.pan := ppan;
		vcardrow.mbr := pmbr;
	
		vcode := card.getcardrecord(ppan, pmbr).cardproduct;
		IF vcode IS NULL
		THEN
			error.raiseerror('For card ' || getcardno(ppan, pmbr) || ' card product not found');
		END IF;
	
		vcardtype := contracttools.getcardtype(ppan, pmbr, FALSE);
		t.var('[1] vCardType', vcardtype);
		vcardrow.itemcode := contractcard.getitemcodebycardproduct(vcontractrow.type
																  ,vcode
																  ,pcardtype => vcardtype);
	
		t.var('vCardRow.ItemCode', vcardrow.itemcode);
	
		IF vcardrow.itemcode IS NULL
		THEN
			IF err.geterrorcode = err.refct_undefined_cardproduct
			THEN
				error.raiseerror('No card product "' || referencecardproduct.getname(vcode) ||
								 '" in receiving contract type.');
			ELSE
				error.raisewhenerr();
			END IF;
		END IF;
	
		vcardrow.useonline := nvl(puseonline, FALSE);
	
		createcardlink(contractcard.newlink, vcontractrow, vcardrow);
	
		a4mlog.cleanparamlist;
		a4mlog.addparamrec(clogparam_pan, ppan);
		a4mlog.addparamrec(clogparam_mbr, pmbr);
		a4mlog.addparamrec(clogparam_contractno, pfromcontract, ptocontract);
	
		IF a4mlog.logobject(object.gettype(contract.object_name)
						   ,pfromcontract
						   ,'Move card to contract ' || ptocontract
						   ,a4mlog.act_change
						   ,a4mlog.putparamlist
						   ,powner => getclientid(pfromcontract)) != 0
		THEN
			error.raisewhenerr();
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			refreshrevision(pfromcontract, caction_restore, vupdaterevision);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE movecard
	(
		ppan          tcard.pan%TYPE
	   ,pmbr          tcard.mbr%TYPE
	   ,pfromcontract tcontract.no%TYPE
	   ,ptocontract   tcontract.no%TYPE
	   ,puseonline    BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.MoveCard';
		vacardlist complexcard.typecardlist;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
	
		moveonecard(ppan, pmbr, pfromcontract, ptocontract, puseonline);
	
		vacardlist := complexcard.getlinkedcardlist(ppan, pmbr);
		FOR i IN 1 .. vacardlist.count
		LOOP
			moveonecard(vacardlist   (i).pan
					   ,vacardlist   (i).mbr
					   ,pfromcontract
					   ,ptocontract
					   ,puseonline);
		END LOOP;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setcurrentrecord(phandle IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCurrentRecord';
	BEGIN
		t.enter(cmethod_name);
		clearcurrentno;
		scurrenthandle := NULL;
		IF phandle IS NULL
		THEN
			RETURN;
		ELSIF scontractarray.exists(phandle)
		THEN
			setcurrentno(scontractarray(phandle).contractrow.no);
			scurrenthandle := phandle;
		ELSE
			error.saveraise(cmethod_name, error.errorconst, 'Handle ' || phandle || ' not found!');
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN error.error THEN
			RAISE;
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setcurrentrecord;

	PROCEDURE setfinprofilebyhandle
	(
		phandle     IN NUMBER
	   ,pfinprofile IN tcontract.finprofile%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetFinProfileByHandle';
	BEGIN
		s.say(cmethod_name || ' start: pFinProfile=' || pfinprofile, csay_level);
		IF scontractarray.exists(phandle)
		THEN
			IF nvl(scontractarray(phandle).contractrow.finprofile, 0) != pfinprofile
			THEN
				a4mlog.cleanparamlist;
				a4mlog.addparamrec(clogparam_finprofile
								  ,scontractarray(phandle).contractrow.finprofile
								  ,pfinprofile);
				IF a4mlog.logobject(object.gettype(contract.object_name)
								   ,scontractarray(phandle).contractrow.no
								   , 'Change contract fin. profile from ' || scontractarray(phandle)
									.contractrow.finprofile || ' to ' || pfinprofile
								   ,a4mlog.act_change
								   ,a4mlog.putparamlist
								   ,powner => scontractarray(phandle).contractrow.idclient) != 0
				THEN
				
					error.raisewhenerr();
				END IF;
			END IF;
			scontractarray(phandle).contractrow.finprofile := pfinprofile;
		ELSE
			error.raiseerror('Handle ' || phandle || ' is not found!');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setfinprofilebyhandle;

	PROCEDURE setfinprofile
	(
		pcontractno IN tcontract.no%TYPE
	   ,pfinprofile IN tcontract.finprofile%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetFinProfile';
		vhandle NUMBER;
		vnew    BOOLEAN;
	BEGIN
		s.say(cmethod_name || ': enter pFinProfile=' || pfinprofile, csay_level);
		vhandle := gethandle(pcontractno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontractno, 'R');
			vnew    := TRUE;
		END IF;
		setfinprofilebyhandle(vhandle, pfinprofile);
		writeobject(vhandle);
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END setfinprofile;

	PROCEDURE setviewmode(pviewmode IN PLS_INTEGER := viewmode_default) IS
	BEGIN
		sviewmode := nvl(pviewmode, viewmode_default);
	END;

	FUNCTION getviewmode RETURN PLS_INTEGER IS
	BEGIN
		RETURN nvl(sviewmode, viewmode_default);
	END;

	FUNCTION getoperationindex(poperationcode IN VARCHAR2) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetOperationIndex';
		vcount NUMBER := soperationarray.count;
		vindex NUMBER := soperationarray.first;
	BEGIN
		s.say(cmethod_name || ': for operation ' || poperationcode, csay_level);
		s.say(cmethod_name || ': total count ' || vcount, csay_level);
	
		FOR i IN 1 .. vcount
		LOOP
			IF soperationarray(vindex).operationcode = poperationcode
			THEN
				s.say(cmethod_name || ': ' || vindex, csay_level);
				RETURN vindex;
			END IF;
			vindex := soperationarray.next(vindex);
		END LOOP;
		s.say(cmethod_name || ': unknown ', csay_level);
	
		error.raiseerror('No index for operation with code: ' || poperationcode);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
		
	END;

	FUNCTION filloperlist
	(
		pdialog      IN NUMBER
	   ,pitemname    IN VARCHAR2
	   ,pcurrentcode IN VARCHAR2 := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FillOperList';
		vexist BOOLEAN := FALSE;
	BEGIN
		dialog.listclear(pdialog, pitemname);
		FOR i IN 1 .. soperationarray.count
		LOOP
			IF soperationarray(i).enabled = 1
			THEN
				IF checkright(right_modify_oper
							 ,dialog.getchar(pdialog, 'No')
							 ,soperationarray(i).operationcode)
				THEN
					dialog.listaddrecord(pdialog
										,pitemname
										,soperationarray(i)
										 .operationcode || '~' || soperationarray(i).operationname || '~' || soperationarray(i)
										 .operationtype || '~'
										,0
										,0);
					IF pcurrentcode IS NOT NULL
					   AND soperationarray(i).operationcode = pcurrentcode
					THEN
						vexist := TRUE;
					END IF;
				END IF;
			END IF;
		END LOOP;
		IF vexist
		THEN
			dialog.setcurrecbyvalue(pdialog, 'OperationsList', 'Code', pcurrentcode);
		ELSIF dialog.getlistreccount(pdialog, pitemname) != 0
		THEN
			dialog.setcurrec(pdialog, pitemname, 1);
		END IF;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END filloperlist;

	FUNCTION removeaccount
	(
		pcontractno IN tcontract.no%TYPE
	   ,paccountno  IN taccount.accountno%TYPE
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.RemoveAccount';
		vcardlist apitypes.typeaccount2cardlist;
		i         NUMBER;
		vdialog   NUMBER;
	
	BEGIN
	
		vcardlist := account.getcardlist(paccountno);
		FOR i IN REVERSE 1 .. vcardlist.count
		LOOP
			IF contract.getcontractnobycard(vcardlist(i).pan, vcardlist(i).mbr, FALSE) =
			   pcontractno
			THEN
				NULL;
			ELSE
				vcardlist.delete(i);
			END IF;
		END LOOP;
		vdialog := contractdlg.dialog_removeaccount(pcontractno, paccountno, vcardlist.count);
		IF dialog.execdialog(vdialog) = dialog.cmok
		THEN
		
			BEGIN
				SAVEPOINT removeacc;
				deleteaccountfromcontract(pcontractno
										 ,paccountno
										 ,pmove2history => TRUE
										 ,pmakelog      => TRUE);
			
				i := vcardlist.first();
				WHILE i IS NOT NULL
				LOOP
					deletecarditem(pcontractno, vcardlist(i).pan, vcardlist(i).mbr);
				
					a4mlog.cleanparamlist;
					a4mlog.addparamrec(clogparam_pan, vcardlist(i).pan);
					a4mlog.addparamrec(clogparam_mbr, vcardlist(i).mbr);
				
					IF a4mlog.logobject(object.gettype(contract.object_name)
									   ,pcontractno
									   ,'card unlinked'
									   ,a4mlog.act_del
									   ,a4mlog.putparamlist()
									   ,powner => getclientid(pcontractno)) != 0
					THEN
						error.raisewhenerr();
					END IF;
					a4mlog.cleanparamlist;
				
					i := vcardlist.next(i);
				END LOOP;
				IF dialog.getbool(vdialog, 'Try2DeleteAccount')
				THEN
					err.seterror(0, cmethod_name);
				
					account.deleteaccount(paccountno, plog => TRUE);
					error.raisewhenerr();
				
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					ROLLBACK TO removeacc;
					RAISE;
			END;
			dialog.destroy(vdialog);
			RETURN TRUE;
		ELSE
			dialog.destroy(vdialog);
			RETURN FALSE;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			IF vdialog > 0
			THEN
				dialog.destroy(vdialog);
			END IF;
			RAISE;
	END;

	PROCEDURE setcommentarybyhandle
	(
		phandle  IN NUMBER
	   ,pcomment IN CLOB
	   ,plog     IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCommentaryByHandle';
		vcompare NUMBER;
	BEGIN
		IF scontractarray.exists(phandle)
		THEN
			IF nvl(plog, TRUE)
			THEN
				IF pcomment IS NULL
				THEN
					IF scontractarray(phandle).contractrow.commentary IS NOT NULL
					THEN
						s.say('Point #1');
						IF a4mlog.logobject(object.gettype(contract.object_name)
										   ,scontractarray(phandle).contractrow.no
										   ,'Comment deleted'
										   ,a4mlog.act_del
										   ,powner => scontractarray(phandle).contractrow.idclient) != 0
						THEN
							error.raisewhenerr();
						END IF;
					END IF;
				ELSE
					vcompare := dbms_lob.compare(nvl(pcomment, '-1')
												,nvl(scontractarray(phandle).contractrow.commentary
													,'-1'));
					s.say('Point #2: ' || vcompare);
					IF vcompare != 0
					THEN
						IF a4mlog.logobject(object.gettype(contract.object_name)
										   ,scontractarray(phandle).contractrow.no
										   ,'Comment changed'
										   ,a4mlog.act_change
										   ,powner => scontractarray(phandle).contractrow.idclient) != 0
						THEN
							error.raisewhenerr();
						END IF;
					ELSIF vcompare IS NULL
					THEN
						error.raiseerror('Error of saving comment');
					END IF;
				END IF;
			END IF;
		
			scontractarray(phandle).contractrow.commentary := pcomment;
		ELSE
			error.raiseerror('Handle ' || phandle || ' is not found!');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setcommentarybyhandle;

	PROCEDURE refreshoperlist
	(
		pdialog              IN NUMBER
	   ,pcontractno          IN tcontract.no%TYPE
	   ,pcontracttype        IN tcontract.type%TYPE
	   ,pdefaltoperationcode IN VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.RefreshOperList';
	BEGIN
		IF initoperlist(pcontracttype, pcontractno) != 0
		THEN
			htools.message('Warning!', err.getfullmessage());
		END IF;
	
		IF filloperlist(pdialog, 'OperationsList', pdefaltoperationcode) != 0
		THEN
			error.raisewhenerr();
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION adjustcontractbydlg
	(
		pcontractno IN tcontract.no%TYPE
	   ,phandle     IN NUMBER := NULL
	) RETURN tadjpackrow.state%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AdjustContractByDlg';
		vadjcfg         contractadjconfig.typedialogsettings;
		vchangemode     BOOLEAN := FALSE;
		vmode           CHAR(1);
		vrow            tadjpackrow%ROWTYPE;
		vcontract       tcontract%ROWTYPE;
		vupdaterevision tcontract.updaterevision%TYPE;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno || ', pHandle=' || phandle, csay_level);
		vadjcfg := contractadjconfig.adjustcontractdialog(pcontractno);
		IF vadjcfg.dialogresult = dialog.cmok
		THEN
			vupdaterevision := getupdaterevision(pcontractno);
			IF phandle IS NOT NULL
			THEN
				vmode := contract.getobjectmode(phandle);
				IF vmode <> 'A'
				THEN
				
					changeobjectmode(phandle, 'A', TRUE);
					vchangemode := TRUE;
				END IF;
			END IF;
		
			vrow := balancepaypack.adjustonecontract(pcontractno
													,vadjcfg.adjmode
													,balancepaypack.cadjfromcontract
													,vadjcfg.packno);
		
			vcontract := getcontractrowtype(pcontractno);
			t.note(cmethod_name
				  ,'vContract.UpdateRevision=' || vcontract.updaterevision || ', vUpdateRevision=' ||
				   vupdaterevision);
		
			IF vcontract.updaterevision != vupdaterevision
			THEN
				t.note('Update revision ' || scontractarray(phandle).contractrow.updaterevision || '->' ||
					   vcontract.updaterevision);
				scontractarray(phandle).contractrow := vcontract;
			END IF;
		
			IF vchangemode
			THEN
			
				changeobjectmode(phandle, vmode, TRUE);
			END IF;
		
			CASE vrow.state
				WHEN balancepaypack.cstate_adjusted THEN
				
					htools.showmessage('Warning!'
									  ,'Contract is successfully adjusted in batch with No [' ||
									   vrow.packno || ']');
				WHEN balancepaypack.cstate_adjerror THEN
					htools.showmessage('Warning!'
									  ,'Error occurred during contract adjustment:~' ||
									   vrow.errordescription || '~');
				WHEN balancepaypack.cstate_done THEN
					htools.showmessage('Warning!', 'Contract state not changed after adjustment');
				ELSE
					IF vrow.packno IS NULL
					THEN
						htools.showmessage('Warning!'
										  ,'Contract state not changed after adjustment');
					ELSE
						htools.showmessage('Warning!', 'Contract state not defined');
					END IF;
			END CASE;
			refreshrevision(pcontractno, caction_restore, vupdaterevision);
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
		RETURN vrow.state;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
		
			IF vchangemode
			THEN
				contract.changeobjectmode(phandle, vmode, TRUE);
			END IF;
			refreshrevision(pcontractno, caction_restore, vupdaterevision);
		
			RAISE;
	END;

	FUNCTION undocontractbydlg
	(
		pcontractno IN tcontract.no%TYPE
	   ,phandle     IN NUMBER := NULL
	) RETURN tadjpackrow.state%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.UndoContractByDlg';
		vadjcfg         contractadjconfig.typedialogsettings;
		vchangemode     BOOLEAN := FALSE;
		vmode           CHAR(1);
		vrow            tadjpackrow%ROWTYPE;
		vcontract       tcontract%ROWTYPE;
		vupdaterevision tcontract.updaterevision%TYPE;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno || ', pHandle=' || phandle, csay_level);
		vadjcfg := contractadjconfig.undocontractdialog(pcontractno);
		IF vadjcfg.dialogresult = dialog.cmok
		THEN
			vupdaterevision := getupdaterevision(pcontractno);
			IF phandle IS NOT NULL
			THEN
				vmode := contract.getobjectmode(phandle);
				IF vmode <> 'A'
				THEN
				
					changeobjectmode(phandle, 'A', TRUE);
					vchangemode := TRUE;
				END IF;
			END IF;
		
			vrow := balancepaypack.undoonecontract(pcontractno
												  ,vadjcfg.packno
												  ,balancepaypack.cadjfromcontract);
		
			vcontract := getcontractrowtype(pcontractno);
		
			t.note(cmethod_name
				  ,'vContract.UpdateRevision=' || vcontract.updaterevision || ', vUpdateRevision=' ||
				   vupdaterevision);
		
			IF vcontract.updaterevision != vupdaterevision
			THEN
				t.note('Update revision ' || scontractarray(phandle).contractrow.updaterevision || '->' ||
					   vcontract.updaterevision);
				scontractarray(phandle).contractrow := vcontract;
			END IF;
		
			IF vchangemode
			THEN
			
				changeobjectmode(phandle, vmode, TRUE);
			END IF;
		
			CASE vrow.state
				WHEN balancepaypack.cstate_undoerr THEN
					htools.showmessage('Warning!'
									  ,'Error occurred when undoing contract adjustment:~' ||
									   vrow.errordescription || '~');
				ELSE
				
					htools.showmessage('Warning!', 'Contract adjustment successfully undone');
			END CASE;
			refreshrevision(pcontractno, caction_restore, vupdaterevision);
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
		RETURN vrow.state;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			refreshrevision(pcontractno, caction_restore, vupdaterevision);
			IF vchangemode
			THEN
				contract.changeobjectmode(phandle, vmode, TRUE);
			END IF;
			RAISE;
	END;

	PROCEDURE dialogcontractproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DialogContractProc';
		vcontractrow tcontract%ROWTYPE;
		vno          VARCHAR2(20);
	
		vidclient NUMBER;
		vdialog   NUMBER;
		vcmd      NUMBER;
	
		vcode        VARCHAR2(40);
		vhandle      NUMBER;
		vmod         CHAR(1);
		vcapturemode NUMBER;
	
		vcard      apitypes.typecardrecord;
		vacardlist complexcard.typecardlist;
	
		vremakesettings card.typeremakesettings;
	
		PROCEDURE enablemenuitems IS
			cmethod_name CONSTANT VARCHAR2(65) := dialogcontractproc.cmethod_name ||
												  '.EnableMenuItems';
		
		BEGIN
			IF sreadonly
			THEN
				s.say(cmethod_name || ': Read Only mode', csay_level);
				dialog.disablemenucase(pdialog, 'OperNewCard');
				dialog.disablemenucase(pdialog, 'OperFamilyCard');
				dialog.disablemenucase(pdialog, 'OperRemakeCard');
				dialog.disablemenucase(pdialog, 'OperAddExistingCard');
				dialog.disablemenucase(pdialog, 'OperRemoveCard');
				dialog.disablemenucase(pdialog, 'OperDeleteCard');
				dialog.disablemenucase(pdialog, 'OperChangeClient');
			
				dialog.disablemenucase(pdialog, 'OperRegPay');
			
				dialog.disablemenucase(pdialog, 'MenuBust');
				dialog.disablemenucase(pdialog, 'LockContract');
				dialog.disablemenucase(pdialog, 'UnLockContract');
			
				loancoverage.setreadonly(TRUE);
				referencebranchpart.setenablebpitem(pdialog, FALSE);
				objuserproperty.setpagereadonly(pdialog, object_name);
				objuserproperty.setpagereadonly(pdialog
											   ,object_name
											   ,psubobject => vcontractrow.type);
				dialog.setitemattributies(pdialog, ccomment, dialog.updateoff || dialog.selectoff);
				dialog.setenable(pdialog, 'Ok', FALSE);
				dialog.disablemenucase(pdialog, 'OperChangeType');
				dialog.setenable(pdialog, 'ExecOper', FALSE);
				dialog.setenable(pdialog, 'OperationsList', FALSE);
				dialog.disablemenucase(pdialog, 'OperAddAccount');
				dialog.disablemenucase(pdialog, 'OperAddAccounts');
				dialog.disablemenucase(pdialog, 'OperRemoveAccount');
			
				dialog.disablemenucase(pdialog, cadjustingitem);
				dialog.disablemenucase(pdialog, cundoitem);
			
				contracttools.enableprolongationmenu(pdialog, FALSE);
			ELSE
				IF NOT checkright(right_modify_attr)
				THEN
					s.say(cmethod_name || ': no rights to modify ', csay_level);
				
					dialog.disablemenucase(pdialog, 'OperRegPay');
				
					dialog.disablemenucase(pdialog, 'MenuBust');
				
					loancoverage.setreadonly(TRUE);
					objuserproperty.setpagereadonly(pdialog, object_name);
					objuserproperty.setpagereadonly(pdialog
												   ,object_name
												   ,psubobject => vcontractrow.type);
					dialog.setenable(pdialog, ccomment, FALSE);
					dialog.setenable(pdialog, 'Ok', FALSE);
					contracttools.enableprolongationmenu(pdialog, FALSE);
				ELSE
					IF (payment.checkright(payment.cregularpayment, payment.cview_right) OR
					   payment.checkright(payment.cregularpayment, payment.cedit_right))
					   AND contracttypeschema.cancontractmakepayment(dialog.getchar(pdialog, 'No'))
					THEN
					
						dialog.setvisible(pdialog, 'OperRegPay', TRUE);
					ELSE
					
						dialog.setvisible(pdialog, 'OperRegPay', FALSE);
					
					END IF;
				
					loancoverage.setreadonly(FALSE);
					dialog.setenable(pdialog, 'Ok', TRUE);
				END IF;
			
				IF NOT checkright(right_change_client)
				THEN
					dialog.disablemenucase(pdialog, 'OperChangeClient');
				END IF;
			
				IF NOT checkright(right_change_type)
				THEN
					dialog.disablemenucase(pdialog, 'OperChangeType');
				END IF;
			
				DECLARE
					fcardcreate BOOLEAN := card.checkright(card.right_create);
					fcarddelete BOOLEAN := card.checkright(card.right_delete);
					fexistcards BOOLEAN := dialog.getlistreccount(pdialog, 'Card') > 0;
				BEGIN
					IF NOT checkright(right_modify_card_issue_main)
					   OR NOT fcardcreate
					THEN
						dialog.disablemenucase(pdialog, 'OperNewCard');
					END IF;
					IF NOT checkright(right_modify_card_issue_corp)
					   OR NOT fcardcreate
					THEN
						dialog.disablemenucase(pdialog, 'OperFamilyCard');
					END IF;
					IF NOT checkright(right_modify_card_reissue)
					   OR NOT fcardcreate
					   OR NOT fexistcards
					THEN
						dialog.disablemenucase(pdialog, 'OperRemakeCard');
					ELSE
						dialog.enablemenucase(pdialog, 'OperRemakeCard');
					END IF;
					IF NOT checkright(right_modify_card_add)
					   OR NOT fcardcreate
					THEN
						dialog.disablemenucase(pdialog, 'OperAddExistingCard');
					ELSE
						dialog.enablemenucase(pdialog, 'OperAddExistingCard');
					END IF;
					IF NOT checkright(right_modify_card_move)
					   OR NOT fexistcards
					THEN
						dialog.disablemenucase(pdialog, 'OperRemoveCard');
					ELSE
						dialog.enablemenucase(pdialog, 'OperRemoveCard');
					END IF;
					IF NOT checkright(right_modify_card_delete)
					   OR NOT fcarddelete
					   OR NOT fexistcards
					THEN
						dialog.disablemenucase(pdialog, 'OperDeleteCard');
					ELSE
						dialog.enablemenucase(pdialog, 'OperDeleteCard');
					END IF;
				END;
			
				IF NOT checkright(right_modify_account_add)
				THEN
					dialog.disablemenucase(pdialog, 'OperAddAccount');
					dialog.disablemenucase(pdialog, 'OperAddAccounts');
				END IF;
				IF NOT checkright(right_modify_card_add)
				THEN
					dialog.disablemenucase(pdialog, 'OperAddExistingCard');
				END IF;
				IF NOT checkright(right_modify_account_remove)
				THEN
					dialog.disablemenucase(pdialog, 'OperRemoveAccount');
				END IF;
				s.say(cmethod_name || ': client id ' || vcontractrow.idclient, csay_level);
				IF client.isvip(vcontractrow.idclient)
				THEN
					s.say(cmethod_name || ': vip ', csay_level);
				END IF;
			
				s.say(cmethod_name || ': account no ' ||
					  dialog.getrecordchar(pdialog, 'Account', 'AccountNo', 1));
			
				IF (NOT
					account.checkright(account.right_view_vip
									   ,dialog.getrecordchar(pdialog, 'Account', 'AccountNo', 1)))
				  
				   OR (NOT contract.checkright(right_statement, dialog.getchar(pdialog, 'No')))
				THEN
					s.say(cmethod_name || ': cannot see vip ', csay_level);
				
					dialog.disablemenucase(pdialog, 'StatementRequest');
				ELSE
					dialog.enablemenucase(pdialog, 'StatementRequest');
				END IF;
			
				IF checkstatus(getstatus(dialog.getchar(pdialog, 'No')), stat_close)
				THEN
					dialog.disablemenucase(pdialog, 'OperNewCard');
					dialog.disablemenucase(pdialog, 'OperFamilyCard');
					dialog.disablemenucase(pdialog, 'OperRemakeCard');
					dialog.disablemenucase(pdialog, 'OperAddExistingCard');
				
					dialog.disablemenucase(pdialog, cadjustingitem);
				ELSE
				
					dialog.enablemenucase(pdialog, cadjustingitem);
				END IF;
			
				IF (object.getcapturemode = object.mode_pessimistic)
				THEN
					dialog.disablemenucase(pdialog, 'LockContract');
				ELSIF (object.getcapturemode = object.mode_optimistic)
				THEN
					dialog.disablemenucase(pdialog, 'UnLockContract');
				END IF;
			END IF;
		
			IF NOT
				security.checkright(client.object_name
								   ,client.getrightkey(client.right_view_client
													  ,client.getclienttype(vcontractrow.idclient)))
			THEN
				dialog.setenable(pdialog, 'Client', FALSE);
			END IF;
		
			IF contractentrylog.isentrylogempty(vcontractrow.no)
			THEN
				dialog.setvisible(pdialog, 'OperViewEntryLog', FALSE);
			ELSE
				dialog.setvisible(pdialog, 'OperViewEntryLog', TRUE);
			END IF;
		
			IF NOT checkright(right_modify_adjust)
			THEN
				dialog.disablemenucase(pdialog, cadjustingitem);
			END IF;
		
			IF NOT checkright(right_modify_undo_all)
			   AND NOT checkright(right_modify_undo_own)
			THEN
				dialog.disablemenucase(pdialog, cundoitem);
			END IF;
		
		END enablemenuitems;
	
		PROCEDURE settitle
		(
			pdialog     IN NUMBER
		   ,pcontractno IN tcontract.no%TYPE
		) IS
			vaccessory NUMBER;
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetTitle';
		BEGIN
			vaccessory := contracttype.getaccessory(gettype(pcontractno));
			IF vaccessory = contracttype.cclient
			THEN
				dialog.setcaption(pdialog
								 ,contractdlg.makedialogcaption(pcontractno
															   ,contractdlg.c_cap_concard));
			ELSIF vaccessory = contracttype.ccorporate
			THEN
				dialog.setcaption(pdialog
								 ,contractdlg.makedialogcaption(pcontractno
															   ,contractdlg.c_cap_corpcontract));
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pWhat=' || pwhat || ' pItemName=' || pitemname || ' pCmd=' || pcmd
			   ,csay_level);
	
		IF contracttools.getcontractrecord(dialog.getchar(pdialog, 'No'), vcontractrow) != 0
		THEN
			service.sayerr(pdialog, 'Warning!');
			IF pwhat = dialog.wtdialogpre
			THEN
				dialog.abort(pdialog);
			END IF;
			RETURN;
		END IF;
	
		CASE pwhat
		
			WHEN dialog.wtdialogpre THEN
				t.note(cmethod_name, 'Dialog.wtDialogPre', csay_level);
				scontdlg := pdialog;
			
				setcurrentno(dialog.getchar(pdialog, 'No'));
				settitle(pdialog, getcurrentno());
			
				sreadonly := nvl(dialog.getnumber(pdialog, 'ReadOnly'), 0) = 1;
			
				IF NOT iscanwatch(vcontractrow.no)
				THEN
					service.saymsg(pdialog
								  ,'Warning!'
								  ,'You are not authorized to view this contract~');
					dialog.abort(pdialog);
					RETURN;
				END IF;
			
				vcapturemode := object.getcapturemode();
				t.var(cmethod_name, 'capture mode=[' || to_char(vcapturemode) || ']', csay_level);
				IF vcapturemode = object.mode_pessimistic
				THEN
					vmod := service.iif(sreadonly, 'R', 'W');
				ELSE
					vmod := 'R';
				END IF;
				t.note(cmethod_name, 'mod=[' || vmod || ']', csay_level);
			
				vhandle        := newobject(vcontractrow.no, vmod);
				scurrenthandle := vhandle;
				t.var(cmethod_name, 'handle=[' || vhandle || ']', csay_level);
			
				saccessory := contracttype.getaccessory(vcontractrow.type);
			
				IF vhandle = 0
				THEN
					IF dialog.exec(service.dialogconfirm('Warning!'
														,'Contract ' || vcontractrow.no ||
														 ' is being used by another operator~' ||
														 object.capturedobjectinfo(object_name
																				  ,vcontractrow.no) || '~' ||
														 'Do you want to use view mode?' || '~'
														,'  Yes  '
														,''
														,'  No   '
														,'')) = dialog.cmok
					THEN
						vhandle   := newobject(vcontractrow.no, 'R');
						sreadonly := TRUE;
					ELSE
						dialog.abort(pdialog);
						RETURN;
					END IF;
				END IF;
			
				IF NOT sreadonly
				   AND vcapturemode = object.mode_optimistic
				THEN
					t.note(cmethod_name, 'optimistic lock ', csay_level);
				
					BEGIN
						IF object.capture(object_name, vcontractrow.no) != 0
						THEN
							t.note(cmethod_name, 'object is captured', csay_level);
							IF err.geterrorcode() = err.object_busy
							THEN
								IF dialog.exec(service.dialogconfirm('Warning!'
																	,'Contract ' || vcontractrow.no ||
																	 ' is being used by another operator~' ||
																	 object.capturedobjectinfo(object_name
																							  ,vcontractrow.no) || '~' ||
																	 'Do you want to use view mode?' || '~'
																	,'  Yes  '
																	,''
																	,'  No   '
																	,'')) = dialog.cmok
								THEN
									sreadonly := TRUE;
								ELSE
									contract.abortfreeobject(vhandle);
									dialog.abort(pdialog);
									RETURN;
								END IF;
							ELSE
								service.sayerr(pdialog, 'Warning!');
								contract.abortfreeobject(vhandle);
								dialog.abort(pdialog);
								RETURN;
							END IF;
						ELSE
							object.release(object_name, vcontractrow.no);
						END IF;
					EXCEPTION
						WHEN OTHERS THEN
							object.release(object_name, vcontractrow.no);
							RAISE;
					END;
				
				END IF;
			
				dialog.putnumber(pdialog, 'Handle', vhandle);
				dialog.putchar(pdialog, 'GUID', service.guid2str((scontractarray(vhandle).guid)));
				dialog.putchar(pdialog
							  ,'LastAdjDate'
							  ,htools.d2s(scontractarray(vhandle).contractrow.lastadjdate));
				BEGIN
					t.note(cmethod_name
						  ,'an attempt to run contract block ContractBlocks.bt_onShow...'
						  ,csay_level);
					contractblocks.run(contractblocks.bt_onshow, vcontractrow.no, saccessory);
					t.note(cmethod_name
						  ,'completed contract block ContractBlocks.bt_onShow'
						  ,csay_level);
					sreadonly := sreadonly OR getviewmode = viewmode_readonly;
					IF initoperlist(scontractarray(vhandle).contractrow.type
								   ,scontractarray(vhandle).contractrow.no) != 0
					THEN
						htools.message('Warning!', err.getfullmessage());
					END IF;
				
					IF filloperlist(pdialog, 'OperationsList') != 0
					THEN
						error.raisewhenerr();
					END IF;
				
					getclientinfo(pdialog, vcontractrow.idclient);
				
					initaccountdisplaymode();
					updateaccountdisplaymodemenu(pdialog);
				
					initaccountsortmode();
					updateaccountsortmodemenu(pdialog);
				
					updateacctlist(pdialog);
					getaccountdata(pdialog, 'Account');
				
					dialog.putchar(pdialog
								  ,'CARDSORTMODE'
								  ,nvl(contractparams.loadchar(contractparams.getobjecttype(contracttype.ccontracttypebranch)
															  ,0
															  ,'CARDSORTMODE'
															  ,FALSE)
									  ,'SORTBYPANFIO'));
					updatecardsortmodemenu(pdialog);
				
					updatecardlist(pdialog);
					getcarddata(pdialog, 'Card');
				
					contracttypeschema.drawinfopanel(vhandle, pdialog, 'SchemaPanel');
					getcontractdata(pdialog);
				
					enablemenuitems();
					t.note(cmethod_name
						  ,'an attempt to start FinContractInstance.LoadPage...'
						  ,csay_level);
					fincontractinstance.loadpage(pdialog, vcontractrow.finprofile, vcontractrow.no);
				
					BEGIN
						t.var(cmethod_name
							 , '[1] ObjUserProperty.FillPage sContractArray(vHandle).ContractRow.ObjectUID=' || scontractarray(vhandle)
							  .contractrow.objectuid
							 ,csay_level);
					
						objuserproperty.fillpage(pdialog
												,contract.object_name
												,scontractarray      (vhandle)
												 .contractrow.objectuid
												,plog_clientid        => scontractarray(vhandle)
																		 .contractrow.idclient);
					
						t.var(cmethod_name
							 ,'[2] ObjUserProperty.FillPage pSubObject=' ||
							  to_char(vcontractrow.type)
							 ,csay_level);
						objuserproperty.fillpage(pdialog
												,contract.object_name
												,scontractarray      (vhandle)
												 .contractrow.objectuid
												,psubobject           => to_char(vcontractrow.type)
												,plog_clientid        => scontractarray(vhandle)
																		 .contractrow.idclient);
					
					EXCEPTION
						WHEN OTHERS THEN
							error.save(cmethod_name);
							error.showerror();
							error.clear();
					END;
				
					t.note(cmethod_name, 'an attempt to run ExecDialogProc...', csay_level);
					contracttypeschema.execdialogproc(vcontractrow.no
													 ,pwhat
													 ,pdialog
													 ,pitemname
													 ,pcmd);
				
					IF a4mlog.logobject(object.gettype(contract.object_name)
									   ,vcontractrow.no
									   ,'View contract'
									   ,a4mlog.act_view
									   ,powner => vcontractrow.idclient) != 0
					THEN
						s.say(cmethod_name || ': error ' || err.getfullmessage(), csay_level);
					END IF;
				
					COMMIT;
				EXCEPTION
					WHEN OTHERS THEN
						t.exc(cmethod_name, plevel => csay_level);
						error.save(cmethod_name);
						ROLLBACK;
						error.showerror();
						object.release(object_name, dialog.getchar(pdialog, 'No'));
						dialog.abort(pdialog);
						clearcurrentno();
				END;
			
			WHEN dialog.wtitempre THEN
				vhandle        := dialog.getnumber(pdialog, 'Handle');
				scurrenthandle := vhandle;
				CASE upper(pitemname)
					WHEN upper(burereadcomment) THEN
						dialog.puttext(pdialog, ccomment, getcommentary(getcurrentno()));
						dialog.goitem(pdialog, ccomment);
					
					WHEN 'ACCOUNT' THEN
						DECLARE
							vcurraccount taccount.accountno%TYPE;
						BEGIN
						
							vcode := dialog.getcurrentrecordchar(pdialog, 'OperationsList', 'Code');
							t.var(cmethod_name, 'vCode=' || vcode, csay_level);
						
							vcurraccount := dialog.getcurrentrecordchar(pdialog
																	   ,pitemname
																	   ,'AccountNo');
							dialog.exec(accountcard.dialogcard(vcurraccount));
							updateacctlist(pdialog);
							dialog.setcurrecbyvalue(pdialog, pitemname, 'AccountNo', vcurraccount);
						
							getcontractdata(pdialog);
						
							refreshoperlist(pdialog
										   ,scontractarray(vhandle).contractrow.no
										   ,scontractarray(vhandle).contractrow.type
										   ,vcode);
						
							contractlink.refreshpage_linkedcontracts(dialog.getnumber(pdialog
																					 ,contractdlg.cpagecontractlinks));
						
						END;
					
					WHEN 'OPERADDACCOUNT' THEN
						DECLARE
							vfilter  contractdlg.typeaccountfilter;
							vdialog  NUMBER;
							vaccount typeaccountrow;
						BEGIN
							vfilter.filtertype := contractdlg.cexcludecontractaccounts;
							vfilter.contract   := scontractarray(vhandle).contractrow;
							/*                          vdialog            := contractdlg.dialogcreateaccount(vaccount
                            ,vfilter
                            ,contractdlg.cstyle_selectaccount
                            ,FALSE);*/
							IF dialog.exec(vdialog) = dialog.cmok
							THEN
								COMMIT;
								updateacctlist(pdialog);
								updatecardlist(pdialog);
								getaccountdata(pdialog, 'Account');
								getcarddata(pdialog, 'Card');
								getcontractdata(pdialog);
								enablemenuitems();
								setcurrentrecord(vhandle);
							END IF;
						END;
					
					WHEN 'OPERADDACCOUNTS' THEN
						DECLARE
							vfilter contractdlg.typeaccountfilter;
							vdialog NUMBER;
						
						BEGIN
							vfilter.filtertype := contractdlg.cexcludecontractaccounts;
							vfilter.contract   := scontractarray(vhandle).contractrow;
							vdialog            := contractdlg.dialog_addaccounts(vfilter);
							IF dialog.exec(vdialog) = dialog.cmok
							THEN
								COMMIT;
								updateacctlist(pdialog);
								updatecardlist(pdialog);
								getaccountdata(pdialog, 'Account');
								getcarddata(pdialog, 'Card');
								getcontractdata(pdialog);
								enablemenuitems();
								setcurrentrecord(vhandle);
							END IF;
						END;
					
					WHEN 'OPERREMOVEACCOUNT' THEN
					
						IF removeaccount(scontractarray(vhandle).contractrow.no
										,dialog.getcurrentrecordchar(pdialog
																	,'ACCOUNT'
																	,'AccountNo'))
						THEN
							COMMIT;
							updateacctlist(pdialog);
							updatecardlist(pdialog);
							getaccountdata(pdialog, 'Account');
							getcarddata(pdialog, 'Card');
							getcontractdata(pdialog);
							enablemenuitems();
							setcurrentrecord(vhandle);
						END IF;
					
					WHEN 'CARD' THEN
						vcard.pan := dialog.getcurrentrecordchar(pdialog, pitemname, 'PAN');
						vcard.mbr := dialog.getcurrentrecordnumber(pdialog, pitemname, 'MBR');
						dialog.exec(dialogcard.dialogedit(vcard.pan, vcard.mbr));
						getcarddata(pdialog, 'Card');
						getcontractdata(pdialog);
					
					WHEN 'OPERNEWCARD' THEN
					
						execcontrolblock_contractoper(action_issueprimarycard
													 ,scontractarray(vhandle).contractrow.no);
					
						DECLARE
							vcard typecardparams;
						BEGIN
							clearnewcardlist();
							vcard.cardtype   := card.ccsprimary;
							vcard.createtype := contractcard.newcreate;
							--vcmd             := dialog.exec(contractdlg.dialognewcard(vcard));
							IF vcmd = dialog.cmok
							THEN
								dialog.goitem(pdialog, 'Card');
								updatecardlist(pdialog);
								getcarddata(pdialog, 'Card');
								getcontractdata(pdialog);
								enablemenuitems();
							END IF;
							clearnewcardlist();
						END;
					
					WHEN 'OPERFAMILYCARD' THEN
					
						execcontrolblock_contractoper(service.iif(saccessory =
																  contracttype.ccorporate
																 ,action_issuecorporatecard
																 ,action_issuesupplementarycard)
													 ,scontractarray(vhandle).contractrow.no);
					
						DECLARE
							vcardrow typecardparams;
						BEGIN
							clearnewcardlist();
							vcardrow.cardtype   := card.ccssupplementary;
							vcardrow.createtype := contractcard.newcreate;
						
							IF ktools.lcount(pdialog, 'Card') > 0
							THEN
								vcardrow.parentpan := dialog.getcurrentrecordchar(pdialog
																				 ,'Card'
																				 ,'PAN');
								vcardrow.parentmbr := dialog.getcurrentrecordnumber(pdialog
																				   ,'Card'
																				   ,'MBR');
							END IF;
						
							--vcmd := dialog.exec(contractdlg.dialognewcard(vcardrow));
							IF vcmd = dialog.cmok
							THEN
								dialog.goitem(pdialog, 'Card');
								updatecardlist(pdialog);
								getcarddata(pdialog, 'Card');
								getcontractdata(pdialog);
								enablemenuitems();
							END IF;
							clearnewcardlist();
						END;
					
					WHEN 'OPERDELETECARD' THEN
					
						execcontrolblock_contractoper(action_deletecard
													 ,scontractarray(vhandle).contractrow.no);
					
						vno       := dialog.getchar(pdialog, 'No');
						vcard.pan := dialog.getcurrentrecordchar(pdialog, 'Card', 'PAN');
						vcard.mbr := dialog.getcurrentrecordnumber(pdialog, 'Card', 'MBR');
						vcmd      := dialog.exec(service.dialogconfirm('Warning!'
																	  ,'Card ' ||
																	   getcardno(vcard.pan
																				,vcard.mbr
																				,NULL) ||
																	   ' will be deleted'
																	  ,'  Yes '
																	  ,'Delete card'
																	  ,'  No   '
																	  ,'Cancel card deletion'));
						IF vcmd = dialog.cmok
						THEN
							BEGIN
								SAVEPOINT spdeletecard;
								deletecard(vno, vcard.pan, vcard.mbr, TRUE, TRUE);
								updatecardlist(pdialog);
								getcarddata(pdialog, 'Card');
								getcontractdata(pdialog);
								enablemenuitems();
								COMMIT;
							EXCEPTION
								WHEN OTHERS THEN
									error.save(cmethod_name);
									ROLLBACK TO spdeletecard;
									error.showerror();
									RETURN;
							END;
						END IF;
					
					WHEN 'OPERREMOVECARD' THEN
					
						execcontrolblock_contractoper(action_movecard
													 ,scontractarray(vhandle).contractrow.no);
					
						vcard.pan := dialog.getcurrentrecordchar(pdialog, 'Card', 'PAN');
						vcard.mbr := dialog.getcurrentrecordnumber(pdialog, 'Card', 'MBR');
						IF dialog.exec(contractdlg.dialogremovecard(vcard.pan
																   ,vcard.mbr
																   ,scontractarray(vhandle)
																	.contractrow.no)) = dialog.cmok
						THEN
							updatecardlist(pdialog);
							getcarddata(pdialog, 'Card');
							getcontractdata(pdialog);
							enablemenuitems();
							setcurrentrecord(vhandle);
						END IF;
					
					WHEN 'OPERREMAKECARD' THEN
					
						execcontrolblock_contractoper(action_reissuecard
													 ,scontractarray(vhandle).contractrow.no);
					
						vcard.pan         := dialog.getcurrentrecordchar(pdialog, 'Card', 'PAN');
						vcard.mbr         := dialog.getcurrentrecordnumber(pdialog, 'Card', 'MBR');
						vcard             := card.getcardrecord(vcard.pan, vcard.mbr);
						vcard.cardproduct := referencecardproduct.getmainproduct(vcard.cardproduct);
						t.var('vCard.MainCardProduct', vcard.cardproduct);
					
						BEGIN
							vdialog := dialogcard.dialogchoicecardproduct(pwhat             => card.mkremake
																		 ,ppan              => vcard.pan
																		 ,pmbr              => vcard.mbr
																		 ,pidclient         => vcard.idclient
																		 ,paccountno        => card.getaccountno(vcard.pan
																												,vcard.mbr)
																		 ,pcanchangeaccount => FALSE);
							IF dialog.execdialog(vdialog) = dialog.cmok
							THEN
								vcard.cardproduct := dialogcard.getcardproductfromdialog(vdialog);
								vremakesettings   := dialogcard.getremakesettingsfromdialog(vdialog);
								dialog.destroy(vdialog);
							ELSE
								dialog.destroy(vdialog);
								RETURN;
							END IF;
						EXCEPTION
							WHEN OTHERS THEN
								IF vdialog > 0
								THEN
									dialog.destroy(vdialog);
								END IF;
								RAISE;
						END;
					
						IF referencecardproduct.getcptype(vcard.cardproduct) =
						   referencecardproduct.ccpmultiapplication
						THEN
							t.note(cmethod_name, 'CreateMultiApplicationCard...', csay_level);
						
							DECLARE
							
								vupdaterevision tcontract.updaterevision%TYPE := getupdaterevisionbyhandle(vhandle);
							
							BEGIN
								vacardlist := complexcard.createmultiapplicationcard(card.mkremake
																					,vcard.pan
																					,vcard.mbr
																					,card.getaccountno(vcard.pan
																									  ,vcard.mbr)
																					,vcard.idclient
																					,vcard.cardproduct
																					,pcontracttype => scontractarray(vhandle)
																									  .contractrow.type
																					,pcontractitem => dialog.getcurrentrecordnumber(pdialog
																																   ,'Card'
																																   ,'ItemCode')
																					,premakesettings => vremakesettings
																					,pcanchangeaccount => FALSE
																					,pmode => complexcard.cminteractive
																					,pcontractno => dialog.getchar(pdialog
																												  ,'No'));
							
							EXCEPTION
								WHEN OTHERS THEN
								
									refreshrevision(scontractarray(vhandle).contractrow.no
												   ,caction_restore
												   ,vupdaterevision);
								
									RAISE;
							END;
						
							IF vacardlist.count > 0
							THEN
								updatecardlist(pdialog);
								getcarddata(pdialog, 'Card');
								getcontractdata(pdialog);
								enablemenuitems();
							END IF;
						ELSE
							vcmd := dialog.exec(dialogcard.dialogcreate(card.mkremake
																	   ,vcard.pan
																	   ,vcard.mbr
																	   ,card.getaccountno(vcard.pan
																						 ,vcard.mbr)
																	   ,vcard.idclient
																	   ,FALSE
																	   ,pcardprod => vcard.cardproduct
																	   ,pcontracttype => scontractarray(vhandle)
																						 .contractrow.type
																	   ,pcontractitem => dialog.getcurrentrecordnumber(pdialog
																													  ,'Card'
																													  ,'ItemCode')
																	   ,premakesettings => vremakesettings));
							IF vcmd = dialog.cmok
							THEN
								updatecardlist(pdialog);
								getcarddata(pdialog, 'Card');
								getcontractdata(pdialog);
								enablemenuitems();
							END IF;
						END IF;
					
					WHEN 'OPERADDEXISTINGCARD' THEN
						execcontrolblock_contractoper(action_addexistingcard
													 ,scontractarray(vhandle).contractrow.no);
						DECLARE
							vfilter contractdlg.typecardfilter;
						BEGIN
							vfilter.contract := scontractarray(vhandle).contractrow;
							vcmd             := dialog.exec(contractdlg.dialog_addexistingcard(pfilter => vfilter));
							IF vcmd = dialog.cmok
							THEN
								updatecardlist(pdialog);
								getcarddata(pdialog, 'Card');
								enablemenuitems();
							END IF;
						END;
					
					WHEN 'OPERWARRANT' THEN
						vno := dialog.getchar(pdialog, 'No');
						warrant.list(vno, warrant.wt_contract);
						writeobject(vhandle);
						COMMIT;
					
					WHEN 'OPERTASTAMENT' THEN
						vno := dialog.getchar(pdialog, 'No');
						testament.list(vno, testament.tt_contract);
						writeobject(vhandle);
						COMMIT;
					
					WHEN 'OPERADDENDUM' THEN
						vno  := dialog.getchar(pdialog, 'No');
						vcmd := dialog.exec(contractaddendum.getdialog_view(vno, sreadonly));
						IF NOT sreadonly
						THEN
							writeobject(vhandle);
						END IF;
						COMMIT;
					
					WHEN 'OPERREGPAY' THEN
						vno := dialog.getchar(pdialog, 'No');
						dialog.exec(payment.dialogregularpaymentcontract(vno));
					
					WHEN 'OPERVIEWLOG' THEN
						a4mlog.showlogbykey(object.gettype(contract.object_name)
										   ,dialog.getchar(pdialog, 'No'));
					
					WHEN 'OPERMEMO' THEN
					
						vidclient := contract.getidclient(dialog.getchar(pdialog, 'No'));
						t.var('vIdClient', vidclient);
						memo.showmemolist(object.gettype(contract.object_name)
										 ,dialog.getchar(pdialog, 'No')
										 ,vidclient);
					
						writeobject(vhandle);
						COMMIT;
					
					WHEN 'OPERNOTIFY' THEN
						statementrt.requestcontractnotify(dialog.getchar(pdialog, 'No'));
						writeobject(vhandle);
						COMMIT;
					
					WHEN 'MENUBUST' THEN
						DECLARE
							vcanedit BOOLEAN := NOT sreadonly AND checkright(right_modify_attr);
						BEGIN
							IF contractbust.runbustcriteria(contractbust.cobjecttype_contract
														   ,NULL
														   ,dialog.getchar(pdialog, 'No')
														   ,NOT vcanedit) = dialog.cmok
							THEN
								IF vcanedit
								THEN
									writeobject(vhandle);
									COMMIT;
								END IF;
							END IF;
						END;
					
					WHEN 'OPERVIEWENTRYLOG' THEN
						dialog.exec(contractentrylog.showdialog(dialog.getchar(pdialog, 'No')));
					
					WHEN 'CLIENT' THEN
						vidclient := contract.getidclient(dialog.getchar(pdialog, 'No'));
						dialog.exec(client.editdialog(vidclient));
						getclientinfo(pdialog, vidclient);
						getcarddata(pdialog, 'Card');
						getcontractdata(pdialog);
					
					WHEN 'STATEMENTREQUEST' THEN
						statementrt.requestcontractstatement(dialog.getchar(pdialog, 'No'));
					
					WHEN 'STATEMENTREGULAR' THEN
					
						DECLARE
							vright statementrt.typerightrecord;
						BEGIN
							vright.canadd    := checkright(right_periodic_statement_add
														  ,dialog.getchar(pdialog, 'No'));
							vright.canedit   := checkright(right_periodic_statement_mod
														  ,dialog.getchar(pdialog, 'No'));
							vright.candelete := checkright(right_periodic_statement_del
														  ,dialog.getchar(pdialog, 'No'));
							statementrt.showcontractstatement(dialog.getchar(pdialog, 'No')
															 ,vright);
						END;
					
					WHEN 'STANDINGORDERS' THEN
						standingorder.showstandingorderlistdialog(apipayment.csoccontract
																 ,dialog.getchar(pdialog, 'No'));
					
					WHEN 'EXECOPER' THEN
					
						DECLARE
							vmodifiability   BOOLEAN;
							vtype            NUMBER;
							vrunprintform    NUMBER;
							vcontractrow     tcontract%ROWTYPE;
							voperationresult contracttypeschema.typeoperationresult;
							vopercode        NUMBER;
							voperident       typeschemaoperations;
							vschemacode      NUMBER;
							vschemapackage   contractschemas.typeschemapackagename;
						
							vcontractblockparams typecontractblockparams;
						BEGIN
							t.note(cmethod_name, 'an attempt to run EXECOPER...', csay_level);
							frunprintform := FALSE;
							vno           := dialog.getchar(pdialog, 'No');
							vcontractrow  := scontractarray(vhandle).contractrow;
							vtype         := dialog.getcurrentrecordnumber(pdialog
																		  ,'OperationsList'
																		  ,'Type');
							t.var(cmethod_name, 'vType=' || vtype, csay_level);
						
							vcode := dialog.getcurrentrecordchar(pdialog, 'OperationsList', 'Code');
							t.var(cmethod_name, 'vCode=' || vcode, csay_level);
						
							IF vtype = cschemaoperation
							THEN
								vopercode                := NULL;
								voperident.operationcode := vcode;
							ELSIF vtype = ctemplateoperation
							THEN
								vopercode                := to_number(vcode);
								voperident.operationcode := NULL;
							END IF;
						
							vmodifiability := soperationarray(getoperationindex(vcode))
											  .ismodifiability IN (NULL, 1);
							t.var(cmethod_name
								 ,'vModifiability=' || htools.bool2str(vmodifiability)
								 ,csay_level);
							vschemacode := contracttype.getschematype(contract.gettype(vno));
						
							SAVEPOINT executeoperation;
						
							t.note(cmethod_name
								  ,'an attempt to run contract block ContractBlocks.bt_OnExecOper PRE ...'
								  ,csay_level);
							vcontractblockparams.opercode  := vopercode;
							vcontractblockparams.operident := voperident.operationcode;
							t.var('[1] vContractBlockParams.OperCode'
								 ,vcontractblockparams.opercode);
							t.var('[1] vContractBlockParams.OperIdent'
								 ,vcontractblockparams.operident);
							/*                          contractblocks.run(contractblocks.bt_onexecoper
                            ,vno
                            ,vschemacode
                            ,
                             
                             contractschemas.object_name
                            ,vcontractblockparams);*/
						
							IF vtype = cschemaoperation
							THEN
								t.note(cmethod_name
									  ,'an attempt to run ContractTypeSchema.ExecuteOperation...'
									  ,csay_level);
							
								voperationresult := contracttypeschema.executeoperation(vno, vcode);
							
								IF voperationresult.resultvalue =
								   contracttypeschema.c_oper_completed
								THEN
									t.note(cmethod_name
										  ,'ExecuteOperation is finished with c_Oper_Completed result'
										  ,csay_level);
									frunprintform := TRUE;
								ELSIF voperationresult.resultvalue =
									  contracttypeschema.c_oper_canceled
								THEN
								
									scontractarray(vhandle).contractrow := vcontractrow;
								
								END IF;
							
							ELSIF vtype = ctemplateoperation
							THEN
								contracttypeschema.exectemplate(vno
															   ,to_number(vcode)
															   ,vrunprintform);
								t.note(cmethod_name, 'need to call form ', csay_level);
							
								IF vrunprintform = operationsingle.cfneedtocall
								THEN
									frunprintform := TRUE;
								END IF;
								voperationresult.resultvalue := contracttypeschema.c_oper_undefined;
							ELSE
								error.raiseerror(contracttypeschema.excsystem_error
												,'Operation type not defined [Type=: ' || vtype ||
												 ', Code=' || vcode || ']');
							END IF;
						
							t.note(cmethod_name
								  ,'an attempt to run contract block ContractBlocks. bt_onPostExecOp POST ...'
								  ,csay_level);
						
							vschemapackage := contractschemas.getrecord(vschemacode, pdoexception => FALSE)
											  .packagename;
							IF vschemapackage IS NOT NULL
							   AND
							   contractschemas.operationimplemented(vschemapackage
																   ,contractschemas.c_contractoperation_exec)
							THEN
								vcontractblockparams.operresult := voperationresult.resultvalue;
								t.var('[2] vContractBlockParams.OperCode'
									 ,vcontractblockparams.opercode);
								t.var('[2] vContractBlockParams.OperIdent'
									 ,vcontractblockparams.operident);
								t.var('[2] vContractBlockParams.OperResult'
									 ,vcontractblockparams.operresult);
								/*contractblocks.run(contractblocks.bt_onpostexecop
                                ,vno
                                ,vschemacode
                                ,
                                 
                                 contractschemas.object_name
                                ,vcontractblockparams);*/
							
							END IF;
						
							writeobject(vhandle);
							COMMIT;
						EXCEPTION
							WHEN OTHERS THEN
								t.note(cmethod_name, 'rollback', csay_level);
								ROLLBACK TO executeoperation;
								scontractarray(vhandle).contractrow := vcontractrow;
								RAISE;
						END;
						t.var(cmethod_name, '[1] contract No=' || getcurrentno(), csay_level);
						setcurrentrecord(vhandle);
						vno := getcurrentno();
						t.var(cmethod_name, '[2] contract No=' || vno, csay_level);
						dialog.putchar(pdialog, 'No', vno);
					
						settitle(pdialog, vno);
					
						refreshoperlist(pdialog
									   ,scontractarray(vhandle).contractrow.no
									   ,scontractarray(vhandle).contractrow.type
									   ,vcode);
					
						IF frunprintform
						THEN
							contractprintform.show(gettype(vno), vcode);
							frunprintform := FALSE;
						END IF;
					
						updateacctlist(pdialog);
						getaccountdata(pdialog, 'Account');
						updatecardlist(pdialog);
						getcarddata(pdialog, 'Card');
						getcontractdata(pdialog);
						enablemenuitems();
					
						contractlink.refreshpage_linkedcontracts(dialog.getnumber(pdialog
																				 ,contractdlg.cpagecontractlinks));
					
					WHEN 'OPERCHANGECLIENT' THEN
						IF saccessory = contracttype.cclient
						THEN
							vdialog := listclient.dialogdefine(client.ct_persone);
						ELSIF saccessory = contracttype.ccorporate
						THEN
							vdialog := listclient.dialogdefine(client.ct_company);
						END IF;
					
						IF dialog.execdialog(vdialog) = dialog.cmok
						THEN
							vno := dialog.getchar(pdialog, 'No');
							s.say(cmethod_name || ': number ' || vno, csay_level);
							vidclient := listclient.dialogdefinegetidclient(vdialog);
							s.say(cmethod_name || ': client id ' || vidclient, csay_level);
							dialog.destroy(vdialog);
							IF vidclient = scontractarray(vhandle).contractrow.idclient
							THEN
								error.raiseerror('Selected customer is already contract holder');
							END IF;
						
							DECLARE
								fchangecardclient BOOLEAN := FALSE;
							BEGIN
								SAVEPOINT spchangeid;
								IF saccessory = contracttype.cclient
								THEN
									fchangecardclient := htools.ask('Warning!'
																   ,'Do you want to change also the holder of cards belonging to the contract?'
																   ,'Yes'
																   ,'No');
								END IF;
							
								vhandle := dialog.getnumber(pdialog, 'Handle');
								changecontractidclient(vno
													  ,vidclient
													  ,fchangecardclient
													  ,c_interactivemode);
								refreshuserattributes(vno, scontractarray(vhandle).userproperty);
								refreshextrauserattributes(vno
														  ,scontractarray(vhandle)
														   .extrauserproperty);
							
								COMMIT;
							EXCEPTION
								WHEN OTHERS THEN
									ROLLBACK TO spchangeid;
									RAISE;
							END;
							getclientinfo(pdialog, vidclient);
							updatecardlist(pdialog);
						END IF;
					
					WHEN 'OPERCHANGETYPE' THEN
						IF checkstatus(scontractarray(vhandle).contractrow.status, stat_close)
						THEN
							IF dialog.exec(service.dialogconfirm('Warning!'
																,'Contract closed.~ Continue changing type?'
																,'  Yes '
																,' '
																,'  No  '
																,' ')) != dialog.cmok
							THEN
								RETURN;
							END IF;
						END IF;
					
						vcontractrow := contract.getcontractrowtype(dialog.getchar(pdialog, 'No'));
						vdialog      := contractdlg.getdialog_selecttype(vcontractrow);
						IF dialog.exec(vdialog) = dialog.cmok
						THEN
						
							vhandle := dialog.getnumber(pdialog, 'Handle');
							refreshuserattributes(vcontractrow.no
												 ,scontractarray(vhandle).userproperty);
							refreshextrauserattributes(vcontractrow.no
													  ,scontractarray(vhandle).extrauserproperty);
						
							getcontractdata(pdialog);
							IF initoperlist(vcontractrow.type, vcontractrow.no) != 0
							THEN
								htools.message('Warning!', err.getfullmessage());
							END IF;
							IF filloperlist(pdialog, 'OperationsList') != 0
							THEN
								error.raisewhenerr();
							END IF;
							updateacctlist(pdialog);
							updatecardlist(pdialog);
						END IF;
					
					WHEN upper(caccdm_all) THEN
						BEGIN
							IF setaccountdisplaymode(caccdm_all)
							THEN
								updateacctlist(pdialog);
								updateaccountdisplaymodemenu(pdialog);
							END IF;
						EXCEPTION
							WHEN OTHERS THEN
								error.showerror();
						END;
					
					WHEN upper(caccdm_onlyenabled) THEN
						BEGIN
							IF setaccountdisplaymode(caccdm_onlyenabled)
							THEN
								updateacctlist(pdialog);
								updateaccountdisplaymodemenu(pdialog);
							END IF;
						EXCEPTION
							WHEN OTHERS THEN
								error.showerror();
						END;
					
					WHEN upper(csortbyaccount) THEN
						BEGIN
							IF setaccountsortmode(csortbyaccount)
							THEN
								updateacctlist(pdialog);
								updateaccountsortmodemenu(pdialog);
							END IF;
						EXCEPTION
							WHEN OTHERS THEN
								error.showerror();
						END;
					
					WHEN upper(csortlikecontracttype) THEN
						BEGIN
							IF setaccountsortmode(csortlikecontracttype)
							THEN
								updateacctlist(pdialog);
								updateaccountsortmodemenu(pdialog);
							END IF;
						EXCEPTION
							WHEN OTHERS THEN
								error.showerror;
						END;
					
					WHEN 'SORTBYPANFIO' THEN
						setcardsortmode(pdialog, 'SORTBYPANFIO');
						updatecardlist(pdialog);
						updatecardsortmodemenu(pdialog);
					
					WHEN 'SORTBYFIOPAN' THEN
						setcardsortmode(pdialog, 'SORTBYFIOPAN');
						updatecardlist(pdialog);
						updatecardsortmodemenu(pdialog);
					
					WHEN 'LOCKCONTRACT' THEN
						s.say(cmethod_name || ': handle ' || vhandle, csay_level);
						changeobjectmode(vhandle, 'W', TRUE);
						IF err.geterrorcode = err.contract_busy
						THEN
							htools.message('Warning!'
										  ,'Contract ' || scontractarray(vhandle).contractrow.no ||
										   ' is being used by another operator:~' ||
										   object.capturedobjectinfo(object_name
																	,scontractarray(vhandle)
																	 .contractrow.no));
							RETURN;
						ELSIF err.geterrorcode != 0
						THEN
							service.sayerr(pdialog, 'Warning!');
							RETURN;
						END IF;
						dialog.setenable(pdialog, 'LockContract', FALSE);
						dialog.setenable(pdialog, 'UnlockContract', TRUE);
					
					WHEN 'UNLOCKCONTRACT' THEN
						changeobjectmode(vhandle, 'R', TRUE);
						IF err.geterrorcode() != 0
						THEN
							s.say(cmethod_name || ': exception ', csay_level);
							service.sayerr(pdialog, 'Warning!');
							RETURN;
						END IF;
						dialog.setenable(pdialog, 'LockContract', TRUE);
						dialog.setenable(pdialog, 'UnlockContract', FALSE);
					
					WHEN 'DOCIMAGE' THEN
					
						image.showimagedocuments(objectuid.getidbycontract(scontractarray(vhandle)
																		   .contractrow.no)
												,contract.object_name
												,to_char(scontractarray(vhandle).contractrow.type)
												,NULL
												,'Document copies'
												,sreadonly OR NOT checkright(right_modify_attr));
					
					WHEN 'OPERAPPLICATION' THEN
						DECLARE
							vcanedit BOOLEAN := NOT sreadonly AND checkright(right_modify_attr);
						BEGIN
							vno := dialog.getchar(pdialog, 'No');
							applicationobjectlink.applcontractdlg(vno, vcanedit);
							IF vcanedit
							THEN
								writeobject(vhandle);
								COMMIT;
							END IF;
						END;
					
					WHEN upper('DirectDebit') THEN
						vno := dialog.getchar(pdialog, 'No');
						dialog.exec(contractddobject.dlg_directdebitlist(vno
																		,sreadonly OR NOT
																		  checkright(right_modify_attr)));
					
					WHEN cadjustingitem THEN
						IF adjustcontractbydlg(dialog.getchar(pdialog, 'No'), vhandle) =
						   balancepaypack.cstate_adjusted
						THEN
							getcontractdata(pdialog);
							IF initoperlist(scontractarray(vhandle).contractrow.type
										   ,scontractarray(vhandle).contractrow.no) != 0
							THEN
								htools.message('Warning!', err.getfullmessage());
							END IF;
							IF filloperlist(pdialog, 'OperationsList') != 0
							THEN
								error.raisewhenerr();
							END IF;
							updateacctlist(pdialog);
							updatecardlist(pdialog);
							enablemenuitems();
						END IF;
					WHEN cundoitem THEN
						IF undocontractbydlg(dialog.getchar(pdialog, 'No'), vhandle) !=
						   balancepaypack.cstate_undoerr
						THEN
							getcontractdata(pdialog);
							IF initoperlist(scontractarray(vhandle).contractrow.type
										   ,scontractarray(vhandle).contractrow.no) != 0
							THEN
								htools.message('Warning!', err.getfullmessage());
							END IF;
							IF filloperlist(pdialog, 'OperationsList') != 0
							THEN
								error.raisewhenerr();
							END IF;
							updateacctlist(pdialog);
							updatecardlist(pdialog);
							enablemenuitems();
						END IF;
					
					ELSE
						NULL;
				END CASE;
			
			WHEN dialog.wt_itemchange THEN
				scurrenthandle := dialog.getnumber(pdialog, 'Handle');
				IF pitemname = 'ACCOUNT'
				THEN
					getaccountdata(pdialog, 'Account');
					contractaccounthistory.setactiveaccitem(pdialog
														   ,dialog.getcurrentrecordchar(pdialog
																					   ,'Account'
																					   ,upper('AccItemName')));
				ELSIF pitemname = 'CARD'
				THEN
					getcarddata(pdialog, 'Card');
				END IF;
			
			WHEN dialog.wtdialogvalid THEN
				vhandle        := dialog.getnumber(pdialog, 'Handle');
				scurrenthandle := vhandle;
				s.say(cmethod_name || ': contract no ' || getcurrentno(), csay_level);
				DECLARE
				
					usermessage EXCEPTION;
					vcontract    typecontractrec;
					vblockparams typecontractblockparams;
				BEGIN
					SAVEPOINT spvalid;
					vno := dialog.getchar(pdialog, 'No');
				
					IF NOT objuserproperty.validpage(pdialog, object_name)
					THEN
						RAISE usermessage;
					END IF;
				
					IF NOT objuserproperty.validpage(pdialog
													,object_name
													,scontractarray(vhandle).contractrow.type)
					THEN
						RAISE usermessage;
					END IF;
				
					setuserproplistbyhandle(vhandle
										   ,objuserproperty.getpagedata(pdialog, object_name));
					setextrauserproplistbyhandle(vhandle
												,objuserproperty.getpagedata(pdialog
																			,object_name
																			,scontractarray(vhandle)
																			 .contractrow.type));
				
					vcontract.contractrow       := scontractarray(vhandle).contractrow;
					vcontract.userproperty      := scontractarray(vhandle).userproperty;
					vcontract.extrauserproperty := scontractarray(vhandle).extrauserproperty;
					vblockparams.operationtype  := action_contractsaving;
					vblockparams.operationmode  := c_interactivemode;
					vblockparams.contracttype   := scontractarray(vhandle).contractrow.type;
				
					execcontrolblock_updatevalues(vcontract
												 ,getaccessory(vcontract.contractrow)
												 ,vblockparams);
					scontractarray(vhandle).userproperty := vcontract.userproperty;
					scontractarray(vhandle).extrauserproperty := vcontract.extrauserproperty;
				
					contractblocks.run(contractblocks.bt_onclose, vno, saccessory);
				
					s.say(cmethod_name || ': sContractArray(vHandle).ContractRow.ObjectUID=' || scontractarray(vhandle)
						  .contractrow.objectuid
						 ,csay_level);
				
					setfinprofilebyhandle(vhandle, fincontractinstance.getpageprofile(pdialog));
					fincontractinstance.savepage(pdialog, vno);
					setcommentarybyhandle(vhandle, dialog.gettext(pdialog, ccomment));
					setbranchpartbyhandle(vhandle, referencebranchpart.getbpfromdialog(pdialog));
				
					vblockparams.operationtype := NULL;
					writeobject(vhandle, vblockparams);
				
					COMMIT;
				EXCEPTION
					WHEN usermessage THEN
						t.exc(cmethod_name, plevel => csay_level);
						ROLLBACK TO spvalid;
						RETURN;
					WHEN OTHERS THEN
						t.exc(cmethod_name, plevel => csay_level);
						error.save(cmethod_name);
						ROLLBACK TO spvalid;
						error.showerror();
						dialog.cancelclose(pdialog);
						RETURN;
				END;
			
			WHEN dialog.wtdialogpost THEN
				vno := dialog.getchar(pdialog, 'No');
				s.say(cmethod_name || ': number ' || vno, csay_level);
				s.say(cmethod_name || ': contract no ' || getcurrentno(), csay_level);
				IF contracttypeschema.contractpost(vno) != 0
				THEN
					service.saymsg(pdialog, 'Warning!', contracttypeschema.serrortext);
				END IF;
			
				freeobject(dialog.getnumber(pdialog, 'Handle'));
			
				IF pcmd != dialog.cmok
				THEN
					ROLLBACK;
				END IF;
				clearcurrentno();
				scontdlg       := NULL;
				scurrenthandle := NULL;
			ELSE
				NULL;
		END CASE;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			clearnewcardlist();
			error.showerror();
			dialog.cancelclose(pdialog);
	END dialogcontractproc;

	FUNCTION addlinkedtypespage
	(
		pdialog       IN NUMBER
	   ,ppagelist     IN VARCHAR2
	   ,pcontracttype IN tcontracttype.type%TYPE
	) RETURN NUMBER IS
		cmethod_name    CONSTANT VARCHAR2(65) := cpackage_name || '.AddLinkedTypesPage';
		cmethod_handler CONSTANT VARCHAR2(65) := cpackage_name || '.DialogCreateProc';
		vret             NUMBER := 0;
		vpage            NUMBER;
		valinkedtypelist contractlink.typetype2typelist;
		vpackage         contractschemas.typeschemapackagename;
	
		vopenright     BOOLEAN := FALSE;
		vacimplemented BOOLEAN := FALSE;
	
		PROCEDURE deletepage(pdialog IN NUMBER) IS
			cmethod_name CONSTANT VARCHAR2(85) := cpackage_name || '.DeletePage';
		BEGIN
			t.enter(cmethod_name, plevel => csay_level);
			IF dialog.idbyname(pdialog, 'LINKEDTYPEPAGEID') > 0
			THEN
				t.note(cmethod_name
					  ,'point 1: PageId=' || dialog.getnumber(pdialog, 'LINKEDTYPEPAGEID'));
				IF nvl(dialog.getnumber(pdialog, 'LINKEDTYPEPAGEID'), 0) > 0
				THEN
					t.note(cmethod_name, 'point 2');
					dialog.destroy(dialog.getnumber(pdialog, 'LINKEDTYPEPAGEID'));
					dialog.putnumber(pdialog, 'LINKEDTYPEPAGEID', 0);
				END IF;
			END IF;
			t.leave(cmethod_name, plevel => csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	BEGIN
		t.enter(cmethod_name, 'pContractType=' || pcontracttype, plevel => csay_level);
		deletepage(pdialog);
		IF contracttype.existstype(pcontracttype)
		THEN
			valinkedtypelist := contractlink.gettype2typelist(pcontracttype
															 ,contractlink.cmain
															 ,NULL
															 ,NULL
															 ,FALSE);
		END IF;
	
		IF valinkedtypelist.count > 0
		THEN
			t.note(cmethod_name, 'point 2', csay_level);
			vpage := dialog.page(pdialog, ppagelist, 'Autocreate contracts');
			dialog.putnumber(pdialog, 'LINKEDTYPEPAGEID', vpage);
			vret := vpage;
		
			dialog.checkbox(vpage, cdlg_list_linkedobjects, 1, 2, 75, 9, '');
			dialog.listaddfield(vpage, cdlg_list_linkedobjects, 'ID', 'N', 10, 0);
			dialog.listaddfield(vpage, cdlg_list_linkedobjects, 'Scheme', 'C', 20, 1);
			dialog.listaddfield(vpage, cdlg_list_linkedobjects, 'ContractTypeCode', 'N', 5, 1);
			dialog.listaddfield(vpage, cdlg_list_linkedobjects, 'ContractTypeName', 'C', 40, 1);
			dialog.listaddfield(vpage, cdlg_list_linkedobjects, 'LinkParams', 'C', 40, 0);
			dialog.setcaption(vpage, cdlg_list_linkedobjects, '~Scheme~Code~Contract type name');
			dialog.setanchor(vpage, cdlg_list_linkedobjects, dialog.anchor_all);
			dialog.setitemmark(vpage, cdlg_list_linkedobjects, cmethod_handler);
		
			FOR i IN 1 .. valinkedtypelist.count
			LOOP
				err.seterror(0, cmethod_name);
				vpackage := contracttype.getschemapackage(valinkedtypelist(i).linktype);
			
				error.raisewhenerr();
				dialog.listaddrecord(vpage
									,cdlg_list_linkedobjects
									,valinkedtypelist(i)
									 .linkid || '~' || vpackage || '~' ||
									  to_char(valinkedtypelist(i).linktype) || '~' ||
									  contracttype.getname(valinkedtypelist(i).linktype) || '~' || valinkedtypelist(i)
									 .linkparams || '~'
									,0
									,0);
			
				vopenright := security.checkright(object_name
												 ,getrightkey(right_open
															 ,valinkedtypelist(i).linktype));
				t.var('vOpenRight' || t.b2t(vopenright));
				vacimplemented := contractschemas.operationimplemented(upper(dialog.getrecordchar(pdialog
																								 ,cdlg_list_linkedobjects
																								 ,'Scheme'
																								 ,i))
																	  ,contractschemas.c_contract_autocreate);
				t.var('vACImplemented' || t.b2t(vacimplemented));
			
				dialog.putbool(vpage
							  ,cdlg_list_linkedobjects
							  ,(valinkedtypelist(i).autocreate = 1 AND nvl(vopenright, FALSE) AND
								nvl(vacimplemented, FALSE))
							  ,i);
			END LOOP;
		END IF;
		t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE refreshcardline
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pposition IN NUMBER
	   ,pcarditem IN typecardparams
	   ,pcardinfo IN card.typefullcardinfo
	) IS
	BEGIN
		dialog.listputrecord(pdialog
							,pitemname
							,to_char(pcarditem.itemcode) || '~' ||
							 to_char(pcardinfo.card.idclient) || '~' ||
							 to_char(pcarditem.createtype) || '~' ||
							 to_char(pcarditem.cardproduct) || '~' ||
							 service.iif(pcarditem.cardtype = card.ccsprimary, ' ', 'C') || '~' ||
							 pcardinfo.card.pan || '~' || to_char(pcardinfo.card.mbr) || '~' ||
							 substr(referencecardproduct.getname(pcardinfo.card.cardproduct)
								   ,1
								   ,30) || '~' || clientpersone.getpersonerecord(pcardinfo.card.idclient).fio || '~' ||
							 pcardinfo.card.finprofile || '~' || pcardinfo.card.grplimit || '~' ||
							 pcardinfo.card.currencyno || '~' ||
							 service.iif(pcarditem.changeidclient, '1', '0') || '~'
							,pposition);
	END;

	PROCEDURE dialogcreateproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DialogCreateProc';
		vdialog      NUMBER;
		vidclient    NUMBER;
		voldidclient NUMBER;
		vret         NUMBER;
		vcount       NUMBER;
		vtype        NUMBER;
	
		vmark       CHAR(1);
		vbranchpart tbranchpart.branchpart%TYPE;
		vaccount    typeaccountrow;
		vfilter     contractdlg.typeaccountfilter;
		vturnedon   BOOLEAN;
	
		PROCEDURE checkokbtnstate(pcanopen BOOLEAN) IS
		BEGIN
		
			IF dialog.getnumber(pdialog, 'IdClient') IS NOT NULL
			THEN
				dialog.setenabled(pdialog, 'Ok', pcanopen);
			
				IF pcanopen
				   AND dialog.getnumber(pdialog, 'Type') IS NOT NULL
				THEN
					dialog.goitem(pdialog, 'OK');
				END IF;
			ELSE
				dialog.setenabled(pdialog, 'Ok', FALSE);
				dialog.goitem(pdialog, 'Client');
			END IF;
		END checkokbtnstate;
	
		PROCEDURE filllists IS
			cmethod_name CONSTANT VARCHAR2(65) := dialogcreateproc.cmethod_name || '.FillLIsts';
			vtype NUMBER;
		BEGIN
			s.say(cmethod_name || ': accounts ', csay_level);
			vtype := dialog.getnumber(pdialog, 'Type');
			IF vtype IS NULL
			THEN
				dialog.listclear(pdialog, 'Account');
				contractdlg.clearaccountlist();
			ELSE
				vret := fillaccountlist(pdialog, 'Account', vtype);
			END IF;
			s.say(cmethod_name || ': cards ', csay_level);
			clearnewcardlist();
			vret := fillcardlist(pdialog
								,'Card'
								,vtype
								,dialog.getnumber(pdialog, 'IdClient')
								,card.ccsprimary);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END filllists;
	
		PROCEDURE changeclient(pidclient IN NUMBER) IS
			cmethod_name CONSTANT VARCHAR2(65) := dialogcreateproc.cmethod_name || '.ChangeClient';
			vcount      NUMBER := dialog.getlistreccount(pdialog, 'Card');
			vclientname tclientpersone.fio%TYPE;
		
			vitemcode     tcontractcard.code%TYPE;
			vcardinfolist card.typefullcardinfolist;
		BEGIN
			vclientname := clientpersone.getpersonerecord(pidclient).fio;
			FOR i IN 1 .. vcount
			LOOP
			
				IF nvl(dialog.getrecordnumber(pdialog, 'Card', 'ChangeClient', i), 1) = 1
				THEN
				
					vitemcode := dialog.getrecordchar(pdialog, 'Card', 'ItemCode', i);
					dialog.listputrecord(pdialog
										,'Card'
										,vitemcode || '~' || to_char(pidclient) || '~' ||
										 dialog.getrecordchar(pdialog, 'Card', 'CreateMode', i) || '~' ||
										 dialog.getrecordnumber(pdialog, 'Card', 'CardProduct', i) || '~' ||
										 
										 dialog.getrecordchar(pdialog, 'Card', 'CardType', i) || '~' ||
										 dialog.getrecordchar(pdialog, 'Card', 'PAN', i) || '~' ||
										 dialog.getrecordnumber(pdialog, 'Card', 'MBR', i) || '~' ||
										 dialog.getrecordchar(pdialog
															 ,'Card'
															 ,'CardProductName'
															 ,i) || '~' || vclientname || '~' ||
										 dialog.getrecordchar(pdialog, 'Card', 'FinProfile', i) || '~' ||
										 dialog.getrecordchar(pdialog, 'Card', 'GrpLimit', i) || '~' ||
										 dialog.getrecordchar(pdialog, 'Card', 'LimitCurrency', i) || '~' ||
										 dialog.getrecordchar(pdialog, 'Card', 'ChangeClient', i) || '~'
										,i);
				
					IF existnewcardlist(vitemcode)
					THEN
					
						vcardinfolist := getnewcardlist(vitemcode);
						FOR k IN 1 .. vcardinfolist.count
						LOOP
							vcardinfolist(k).card.idclient := pidclient;
							vcardinfolist(k).card.nameoncard := NULL;
						END LOOP;
						setnewcardlist(vitemcode, vcardinfolist);
					
					END IF;
				END IF;
			END LOOP;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE recreateextrausrattr
		(
			pdialog       IN NUMBER
		   ,pcontracttype IN tcontract.type%TYPE
		) IS
			cmethod_name CONSTANT VARCHAR2(65) := dialogcreateproc.cmethod_name ||
												  '.RecreateExtraUsrAttr';
			vpage NUMBER;
		BEGIN
			dialog.destroy(dialog.getnumber(pdialog, 'EXTRAUSRPAGEID'));
			IF pcontracttype IS NOT NULL
			   AND objuserproperty.existsproperty(contract.object_name, pcontracttype, FALSE)
			THEN
				vpage := objuserproperty.addpage(pdialog
												,'PageList'
												,'Additional'
												,14
												,contract.object_name
												,pcontracttype);
				objuserproperty.fillpage(pdialog
										,contract.object_name
										,powneruid            => NULL
										,psubobject           => to_char(pcontracttype)
										,plog_clientid        => dialog.getnumber(pdialog
																				 ,'IdClient'));
			ELSE
				vpage := dialog.page(pdialog, 'PageList', 'Additional');
			END IF;
			dialog.putnumber(pdialog, 'EXTRAUSRPAGEID', vpage);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		FUNCTION validcardselection
		(
			ppan     IN tcard.pan%TYPE
		   ,pmbr     IN tcard.mbr%TYPE
		   ,pcardrow IN typecardparams
		) RETURN BOOLEAN IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ValidCardSelection';
			vcardproduct tcard.cardproduct%TYPE;
		BEGIN
			IF ppan IS NOT NULL
			THEN
				IF NOT card.cardexists(ppan, pmbr)
				THEN
					error.raiseerror('Selected card does not exist');
				END IF;
				vcardproduct := card.getcardproduct(ppan, pmbr);
				IF vcardproduct != pcardrow.cardproduct
				THEN
					error.raiseerror('Card product <' ||
									 referencecardproduct.getname(vcardproduct) ||
									 '> of selected card does not match defined card product <' ||
									 referencecardproduct.getname(pcardrow.cardproduct) || '>');
				END IF;
			END IF;
			RETURN TRUE;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE changetype IS
			vcanopen BOOLEAN;
		BEGIN
			vtype := to_number(TRIM(dialog.getchar(pdialog, 'TypeList')));
			s.say('! ' || dialog.getnumber(pdialog, 'Type') || '->' || vtype);
			IF vtype IS NOT NULL
			   AND NOT contracttype.existstype(vtype)
			THEN
				htools.message('Warning!', 'Specified contract type does not exist!');
				dialog.putnumber(pdialog, 'Type', vtype);
				dialog.goitem(pdialog, 'TYPELIST');
				RETURN;
			END IF;
		
			IF NOT htools.equal(vtype, dialog.getnumber(pdialog, 'Type'))
			THEN
				dialog.putnumber(pdialog, 'Type', vtype);
			
				recreateextrausrattr(pdialog, vtype);
				IF contracttypeschema.addparameterpage(pdialog
													  ,'PageList'
													  ,contractparams.ccontract
													  ,NULL
													  ,vtype) > 0
				THEN
					t.note(cmethod_name, '1. Parameters page created successfully');
				END IF;
				IF addlinkedtypespage(pdialog, 'PageList', vtype) > 0
				THEN
					t.note(cmethod_name, '2. LinkedTypes page created successfully');
				END IF;
			END IF;
		
			filllists();
		
			vcanopen := checkright(right_open, pcontracttype => vtype);
		
			checkokbtnstate(vcanopen);
		
			IF NOT vcanopen
			THEN
				htools.message('Warning!'
							  ,'You are not authorized to open contracts of selected type!');
				dialog.goitem(pdialog, 'TYPELIST');
			END IF;
		END;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pWhat=' || pwhat || ' pItemName=' || pitemname || ' pCmd=' || pcmd
			   ,csay_level);
		CASE pwhat
			WHEN dialog.wtdialogpre THEN
				t.note('Dialog create contract point 01');
				clearnewcardlist();
				saccessory := dialog.getnumber(pdialog, 'Accessory');
				checkokbtnstate(FALSE);
				dialog.putchar(pdialog, 'No', NULL);
				t.note('Dialog create contract point 02');
				objuserproperty.fillpage(pdialog, contract.object_name);
				t.note('Dialog create contract point 03');
				setcurrentemptycard();
			WHEN dialog.wtitempre THEN
				CASE pitemname
					WHEN 'ACCOUNT' THEN
						NULL;
						/*                      vaccount := contractdlg.getaccountbyitemname(dialog.getcurrentrecordchar(pdialog
                        ,'Account'
                        ,'AccItemName'));*/
					
						IF contractaccount.checkrefaccounttype(vaccount.refaccounttype
															  ,contractaccount.refaccounttype_table)
						THEN
							htools.message('Warning!'
										  ,'This account can only be created dynamically');
						ELSIF dialog.getnumber(pdialog, 'IdClient') IS NULL
						THEN
							htools.message('Warning!', 'Define contract owner');
						ELSE
							/*    vaccount                  := contractdlg.getaccountbyitemname(dialog.getcurrentrecordchar(pdialog
                            ,'Account'
                            ,'AccItemName'));*/
							vfilter.filtertype        := contractdlg.callrows;
							vfilter.contract.type     := dialog.getnumber(pdialog, 'Type');
							vfilter.contract.idclient := dialog.getnumber(pdialog, 'IdClient');
							IF saccessory = contracttype.cclient
							THEN
								vfilter.clienttype := client.ct_persone;
							ELSIF saccessory = contracttype.ccorporate
							THEN
								vfilter.clienttype := client.ct_company;
							END IF;
							/*   
                            IF dialog.exec(contractdlg.dialogcreateaccount(vaccount
                                                                          ,vfilter
                                                                          ,contractdlg.cstyle_descriptiononly
                                                                          ,FALSE)) = dialog.cmok
                            THEN vaccount := contractdlg.getaccountbyitemname(dialog.getcurrentrecordchar(pdialog
                                                                                                         ,'Account'
                                                                                                         ,'AccItemName'));
                                                                                                         */
							dialog.listputrecord(pdialog
												,'Account'
												,to_char(vaccount.itemcode) || '~' ||
												 to_char(vaccount.createmode) || '~' ||
												 to_char(vaccount.currencycode) || '~' ||
												 vaccount.description || '~' || vaccount.accountno || '~' ||
												 vaccount.accounttype || '~' ||
												 vaccount.acctypename || '~' || vaccount.itemname || '~' ||
												 vaccount.refaccounttype || '~' ||
												 vaccount.extaccount || '~'
												,dialog.getlistcurrentrecordnumber(pdialog
																				  ,'Account'));
						END IF;
						--END IF;
					WHEN 'CARD' THEN
						DECLARE
						
							vcard         contract.typecardparams;
							vpan          tcard.pan%TYPE;
							vcontracttype tcontract.type%TYPE;
							vaddnewcard   BOOLEAN;
							vemptycard    apitypes.typecardrecord;
							vchangeclient BOOLEAN;
						
							vcardinfolist card.typefullcardinfolist;
							vacardlist    complexcard.typecardlist;
						
						BEGIN
						
							IF dialog.getnumber(pdialog, 'IdClient') IS NULL
							THEN
								htools.message('Warning!', 'Define contract owner');
								dialog.goitem(pdialog, 'IdClient');
								RETURN;
							END IF;
							card.setnewrecord(vemptycard);
							setcurrentemptycard();
							vpan := dialog.getcurrentrecordchar(pdialog, 'Card', 'PAN');
							t.var('vPan', card.getmaskedpan(vpan), csay_level);
							vcard.itemcode := dialog.getcurrentrecordnumber(pdialog
																		   ,'Card'
																		   ,'ItemCode');
							t.var('vCard.ItemCode', vcard.itemcode);
							vcontracttype := dialog.getnumber(pdialog, 'Type');
							t.var('vContractType', vcontracttype);
							vcard.cardtype := contractcard.getcreatetype(vcontracttype
																		,vcard.itemcode);
							t.var('vCard.CardType', vcard.cardtype);
						
							vcard.createtype := dialog.getcurrentrecordnumber(pdialog
																			 ,'Card'
																			 ,'CreateMode');
							t.var('vCard.CreateType', vcard.createtype);
							vcard.cardproduct := dialog.getcurrentrecordnumber(pdialog
																			  ,'Card'
																			  ,'CardProduct');
							t.var('vCard.CardProduct', vcard.cardproduct);
						
							t.var('ChangeClient'
								 ,dialog.getcurrentrecordnumber(pdialog, 'Card', 'ChangeClient'));
							IF dialog.getcurrentrecordnumber(pdialog, 'Card', 'ChangeClient') = 0
							THEN
								vcard.changeidclient := FALSE;
							ELSE
								vcard.changeidclient := TRUE;
							END IF;
						
							setcurrentcardproduct(vcard.cardproduct);
						
							IF vpan IS NULL
							THEN
							
								vaddnewcard := htools.askconfirm('Add card'
																,'Create new card or select existing one?'
																,'  Create  '
																,'Create new card and add it to contract'
																,'  Select  '
																,'Select existing card and add it to contract'
																,'  Cancel'
																,'Return to contract settings');
								t.var('vAddNewCard', t.b2t(vaddnewcard));
							
								IF vaddnewcard
								THEN
								
									t.note('POINT 001');
									t.var('[3] vCard.CardType', vcard.cardtype);
									vcardinfolist := card.getcardlistfromdialog(nvl(vcard.cardtype
																				   ,card.ccsprimary)
																			   ,paccountno => NULL
																			   ,pcardproduct => dialog.getcurrentrecordnumber(pdialog
																															 ,'Card'
																															 ,'CardProduct')
																			   ,pidclient => dialog.getnumber(pdialog
																											 ,'IdClient')
																			   ,pcontracttype => vcontracttype
																			   ,pcontractitem => vcard.itemcode
																			   ,pwithoutissuesettingsdialog => TRUE);
								
									t.note('POINT 002');
									IF vcardinfolist.count > 0
									   AND vcardinfolist(1).card.pan IS NOT NULL
									THEN
										setnewcardlist(vcard.itemcode, vcardinfolist);
										/*                                      refreshcardline(pdialog
                                        ,'Card'
                                        ,dialog.getlistcurrentrecordnumber(pdialog
                                                                          ,'Card')
                                        ,vcard
                                        ,vcardinfolist(1));*/
									
									END IF;
								ELSIF NOT vaddnewcard
								THEN
								
									IF dialog.exec(finder.maindialog(finder.ot_card)) = dialog.cmok
									THEN
										vcard.pan := finder.getfinderresult(finder.getlastdialogid).pan;
										t.var('vCard.PAN', card.getmaskedpan(vcard.pan));
										vcard.mbr := finder.getfinderresult(finder.getlastdialogid).mbr;
										t.var('vCard.MBR', vcard.mbr);
										IF vcard.pan IS NOT NULL
										THEN
										
											/*                    IF validcardselection(vcard.pan, vcard.mbr, vcard)
                                            THEN
                                                NULL;
                                            END IF;*/
											vcard.createtype := contractcard.newlink;
										
											vcardinfolist(1) := card.getfullcardinfo(vcard.pan
																					,vcard.mbr);
										
											IF vcardinfolist(1)
											 .card.idclient !=
												dialog.getnumber(pdialog, 'IdClient')
											THEN
												vchangeclient := htools.ask('Add card'
																		   ,'Cardholder [' || clientpersone.getpersonerecord(vcardinfolist(1).card.idclient).fio || ']~' ||
																			'is not contract holder [' || clientpersone.getpersonerecord(dialog.getnumber(pdialog,'IdClient')).fio || ']~' ||
																			'Change cardholder?'
																		   ,'Change cardholder to contract holder'
																		   ,'Do not change current cardholder');
												t.var('vChangeClient', t.b2t(vchangeclient));
												IF vchangeclient
												THEN
													vcardinfolist(1).card.idclient := dialog.getnumber(pdialog
																									  ,'IdClient');
													vcardinfolist(1).card.nameoncard := NULL;
													vcard.changeidclient := TRUE;
												ELSE
													vcard.changeidclient := FALSE;
												END IF;
											END IF;
										
											vacardlist := complexcard.getlinkedcardlist(vcard.pan
																					   ,vcard.mbr);
											t.var('vaCardList.count', vacardlist.count);
											FOR i IN 1 .. vacardlist.count
											LOOP
												vcardinfolist(i + 1) := card.getfullcardinfo(vacardlist(i).pan
																							,vacardlist(i).mbr);
												IF vcard.changeidclient
												THEN
													vcardinfolist(i + 1).card.idclient := dialog.getnumber(pdialog
																										  ,'IdClient');
													vcardinfolist(i + 1).card.nameoncard := NULL;
												END IF;
											END LOOP;
										
											setnewcardlist(vcard.itemcode, vcardinfolist);
											/*                     refreshcardline(pdialog
                                            ,'Card'
                                            ,dialog.getlistcurrentrecordnumber(pdialog
                                                                              ,'Card')
                                            ,vcard
                                            ,vcardinfolist(1));*/
										
										END IF;
									
									END IF;
								
								END IF;
							
							ELSE
							
								IF existnewcardlist(vcard.itemcode)
								THEN
									vcardinfolist := getnewcardlist(vcard.itemcode);
									t.note('POINT 003');
									vcardinfolist := card.getcardlistfromdialog(vcardinfolist
																			   ,vcard.cardtype
																			   ,vcontracttype
																			   ,vcard.itemcode);
									t.note('POINT 004');
									IF vcardinfolist.count > 0
									   AND vcardinfolist(1).card.pan IS NOT NULL
									THEN
									
										setnewcardlist(vcard.itemcode, vcardinfolist);
										/*      refreshcardline(pdialog
                                        ,'Card'
                                        ,dialog.getlistcurrentrecordnumber(pdialog
                                                                          ,'Card')
                                        ,vcard
                                        ,vcardinfolist(1));*/
									
									END IF;
								END IF;
							
							END IF;
							card.setnewrecord(vemptycard);
							setcurrentemptycard();
						EXCEPTION
							WHEN OTHERS THEN
								card.setnewrecord(vemptycard);
								setcurrentemptycard();
								RAISE;
							
						END;
					WHEN 'CLIENT' THEN
						vtype        := dialog.getnumber(pdialog, 'Type');
						voldidclient := dialog.getnumber(pdialog, 'IdClient');
						IF saccessory = contracttype.cclient
						THEN
							vdialog := listclient.dialogdefine(client.ct_persone);
						ELSIF saccessory = contracttype.ccorporate
						THEN
							vdialog := listclient.dialogdefine(client.ct_company);
						END IF;
					
						dialog.execdialog(vdialog);
						vidclient := listclient.dialogdefinegetidclient(vdialog);
						dialog.destroy(vdialog);
					
						IF nvl(vidclient, 0) != 0
						   AND nvl(voldidclient, 0) != vidclient
						THEN
							dialog.putnumber(pdialog, 'IdClient', vidclient);
							getclientinfo(pdialog, vidclient);
							s.say(cmethod_name || ': contract type ' || vtype, csay_level);
							IF vtype IS NOT NULL
							THEN
								changeclient(vidclient);
							END IF;
							checkokbtnstate(checkright(right_open, pcontracttype => vtype));
						END IF;
					ELSE
						NULL;
				END CASE;
			WHEN
			
			 dialog.wtitempost THEN
				IF (pitemname = 'TYPELIST')
				THEN
					changetype;
				END IF;
			WHEN dialog.wtnextfield THEN
				IF (pitemname = 'TYPELIST')
				THEN
					changetype;
				END IF;
			
			WHEN dialog.wtdialogvalid THEN
				IF pcmd = dialog.cmconfirm
				THEN
				
					IF pitemname = 'GROUP'
					THEN
						DECLARE
							vgroupid NUMBER;
							vfilter  contracttype.typectypefilter;
						BEGIN
							vgroupid := dialog.getcurrentrecordnumber(pdialog, 'Group', 'Ident');
							dialog.putchar(pdialog, 'Group', vgroupid);
							s.say(cmethod_name || ': group ident ' || vgroupid, csay_level);
						
							vfilter         := contracttype.getitemfilter(pdialog, 'TypeList');
							vfilter.ctgroup := vgroupid;
							contracttype.updateitemfilter(pdialog, 'TypeList', vfilter);
							contracttype.setdata(pdialog, 'TypeList', NULL);
						END;
					
						vtype := NULL;
						dialog.putnumber(pdialog, 'Type', NULL);
						recreateextrausrattr(pdialog, vtype);
					
						IF contracttypeschema.addparameterpage(pdialog
															  ,'PageList'
															  ,contractparams.ccontract
															  ,NULL
															  ,vtype) > 0
						THEN
							t.note(cmethod_name, '2. Parameters page created successfully');
						END IF;
						IF addlinkedtypespage(pdialog, 'PageList', vtype) > 0
						THEN
							t.note(cmethod_name, '2. LinkedTypes page created successfully');
						END IF;
					
						filllists();
						checkokbtnstate(FALSE);
						dialog.goitem(pdialog, 'TypeList');
						RETURN;
					ELSIF pitemname = 'TYPELIST'
					THEN
						changetype;
					END IF;
				ELSE
					IF dialog.getchar(pdialog, 'TYPELIST') IS NULL
					THEN
						htools.message('Warning!', 'Contract type not selected!');
						dialog.goitem(pdialog, 'TYPELIST');
						RETURN;
					END IF;
					IF NOT htools.equal(to_number(TRIM(dialog.getchar(pdialog, 'TYPELIST')))
									   ,dialog.getnumber(pdialog, 'Type'))
					THEN
						htools.message('Warning!', 'Internal error. Check entered data!');
						dialog.goitem(pdialog, 'TYPELIST');
						RETURN;
					END IF;
					IF NOT contracttype.existstype(dialog.getnumber(pdialog, 'Type'))
					THEN
						htools.message('Warning!', 'Specified contract type does not exist!');
						dialog.goitem(pdialog, 'TYPELIST');
						RETURN;
					END IF;
				
					IF NOT
						checkright(right_open, pcontracttype => dialog.getnumber(pdialog, 'Type'))
					THEN
						service.saymsg(pdialog
									  ,'Warning!'
									  ,'You are not authorized to create contracts of this type~');
						dialog.goitem(pdialog, 'Type');
						RETURN;
					END IF;
					IF contractdlg.getcount <= 0
					THEN
						service.saymsg(pdialog, 'Warning!', 'No accounts for this contract type~');
						dialog.goitem(pdialog, 'Account');
						RETURN;
					END IF;
				
					vbranchpart := referencebranchpart.getbpfromdialog(pdialog);
					IF vbranchpart != seance.getbranchpart()
					   AND NOT account.checkright(account.right_modify_branchpart)
					THEN
						service.saymsg(pdialog
									  ,'Warning!'
									  ,'You are not authorized to change branch for accounts~');
						dialog.goitem(pdialog, 'Account');
						RETURN;
					END IF;
				
					FOR i IN 1 .. dialog.getlistreccount(pdialog, 'Account')
					LOOP
						--vaccount := contractdlg.getaccountbyindex(i);
					
						t.var('vAccount.AccountNo', vaccount.accountno);
						t.var('vAccount.CreateMode', vaccount.createmode);
						IF vaccount.createmode IN
						   (contractaccount.createmode_atonceonly
						   ,contractaccount.createmode_atoncedefault)
						   OR vaccount.accountno IS NOT NULL
						THEN
						
							IF contractaccount.checkrefaccounttype(vaccount.refaccounttype
																  ,contractaccount.refaccounttype_single)
							   AND vaccount.accounttype IS NULL
							   OR
							   contractaccount.checkrefaccounttype(vaccount.refaccounttype
																  ,contractaccount.refaccounttype_table)
							   AND ctaccounttypeperiod.emptyperiodslice(dialog.getnumber(pdialog
																						,'Type')
																	   ,vaccount.itemname)
							THEN
								service.saymsg(pdialog, 'Warning!', 'Acct not defined');
								dialog.goitem(pdialog, 'Account');
								dialog.setcurrec(pdialog, 'Account', i);
								RETURN;
							END IF;
						END IF;
					
					END LOOP;
				
					FOR i IN 1 .. dialog.getlistreccount(pdialog, 'Card')
					LOOP
						vmark := service.getchar(dialog.getchar(pdialog, 'Card'), i);
						s.say(cmethod_name || ': vMark=[' || vmark || ']');
						IF rtrim(vmark) IS NOT NULL
						THEN
							IF dialog.getrecordnumber(pdialog, 'Card', 'IdClient', i) IS NULL
							THEN
								dialog.sethothint(pdialog, 'Error: cardholder not defined');
								dialog.goitem(pdialog, 'Card');
								dialog.setcurrec(pdialog, 'Card', i);
								RETURN;
							END IF;
						
							IF vbranchpart != seance.getbranchpart()
							   AND
							   contractcard.getusecontractbranchpart(dialog.getnumber(pdialog
																					 ,'Type')
																	,dialog.getrecordnumber(pdialog
																						   ,'Card'
																						   ,'ItemCode'
																						   ,i))
							   AND NOT card.checkright(card.right_modify_branchpart)
							THEN
								service.saymsg(pdialog
											  ,'Warning!'
											  ,'You are not authorized to change branch for cards~');
								dialog.goitem(pdialog, 'Card');
								RETURN;
							END IF;
							IF dialog.getrecordnumber(pdialog, 'Card', 'CreateMode', i) IS NULL
							THEN
								dialog.sethothint(pdialog, 'Error: card not defined');
								dialog.goitem(pdialog, 'Card');
								dialog.setcurrec(pdialog, 'Card', i);
								RETURN;
							END IF;
						END IF;
					END LOOP;
				
					IF NOT objuserproperty.validpage(pdialog, object_name)
					THEN
						RETURN;
					END IF;
				
					IF NOT objuserproperty.validpage(pdialog
													,object_name
													,dialog.getnumber(pdialog, 'Type'))
					THEN
						RETURN;
					END IF;
				
					IF NOT
						contracttypeschema.validparameterpage(pdialog
															 ,contractparams.ccontract
															 ,NULL
															 ,dialog.getnumber(pdialog, 'Type'))
					THEN
						RETURN;
					END IF;
				
					DECLARE
						vno tcontract.no%TYPE;
					BEGIN
						createcontractfromdialog(pdialog);
						IF err.geterrorcode() = 0
						THEN
							vno := dialog.getchar(pdialog, 'No');
							s.say(cmethod_name || ', contract created with No=' || vno, csay_level);
							contractblocks.run(contractblocks.bt_onclose, vno, saccessory);
							COMMIT;
						ELSE
							ROLLBACK;
							service.sayerr(pdialog, 'Warning!');
							dialog.cancelclose(pdialog);
							RETURN;
						END IF;
					EXCEPTION
						WHEN OTHERS THEN
							ROLLBACK;
							error.save(cmethod_name);
							error.showerror();
							dialog.cancelclose(pdialog);
							RETURN;
					END;
				END IF;
			
			WHEN dialog.wtdialogpost THEN
				IF pcmd = dialog.cmcancel
				THEN
					dialog.putchar(pdialog, 'No', NULL);
				END IF;
				clearnewcardlist();
			WHEN dialog.wtitemmark THEN
				IF pitemname = cdlg_list_linkedobjects
				THEN
					vturnedon := dialog.getbool(pdialog
											   ,cdlg_list_linkedobjects
											   ,dialog.getcurrec(pdialog, cdlg_list_linkedobjects));
					t.var('vTurnedOn', t.b2t(vturnedon));
					IF vturnedon
					THEN
						IF NOT
							security.checkright(object_name
											   ,getrightkey(right_open
														   ,dialog.getcurrentrecordnumber(pdialog
																						 ,cdlg_list_linkedobjects
																						 ,'ContractTypeCode')))
						THEN
							dialog.putbool(pdialog
										  ,cdlg_list_linkedobjects
										  ,FALSE
										  ,dialog.getcurrec(pdialog, cdlg_list_linkedobjects));
							htools.message('Warning'
										  ,'You are not authorized to create contracts of this type');
							RETURN;
						END IF;
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
			ELSE
				NULL;
		END CASE;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			clearnewcardlist();
			error.showerror();
			dialog.cancelclose(pdialog);
	END;

	PROCEDURE dialogremovecardproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DialogRemoveCardProc';
		vdialog       NUMBER;
		vitemname     VARCHAR2(30);
		vno           tcontract.no%TYPE;
		vpan          tcard.pan%TYPE;
		vmbr          tcard.mbr%TYPE;
		vfromcontract tcontract.no%TYPE;
	BEGIN
		CASE pwhat
			WHEN dialog.wtitempre THEN
				IF pitemname = 'CONTRACTNO'
				THEN
					IF dialog.getchar(pdialog, 'ContractNo') IS NULL
					THEN
						vdialog := finder.finderdialog(finder.ct_clientpersone, finder.fm_contract);
						IF dialog.execdialog(vdialog) = dialog.cmok
						THEN
							vno := finder.getcontractno;
							dialog.putchar(pdialog, 'ContractNo', vno);
							getclientinfo(pdialog, getidclient(vno));
							dialog.destroy(vdialog);
							dialog.goitem(pdialog, 'ContractNo');
						END IF;
					END IF;
				END IF;
			WHEN dialog.wtnextfield THEN
				IF upper(pitemname) = 'CONTRACTNO'
				THEN
					getclientinfo(pdialog, getidclient(dialog.getchar(pdialog, 'ContractNo')));
				END IF;
			WHEN dialog.wtdialogvalid THEN
				IF pitemname = 'OK'
				THEN
					vno           := dialog.getchar(pdialog, 'ContractNo');
					vfromcontract := dialog.getchar(vdialog, 'FromContract');
				
					IF vno IS NULL
					THEN
						vitemname := 'ContractNo';
					ELSE
					
						DECLARE
							vacardlist complexcard.typecardlist;
							vuseonline BOOLEAN;
						
						BEGIN
							SAVEPOINT spbeginremove;
						
							IF NOT contractexists(vno)
							THEN
								htools.message('Warning', 'Contract "' || vno || '" not found');
								dialog.goitem(pdialog, 'ContractNo');
								RETURN;
							ELSIF vfromcontract = vno
							THEN
								dialog.sethothint(pdialog, 'Card already belongs to contract');
								dialog.goitem(pdialog, 'ContractNo');
								RETURN;
							END IF;
						
							vpan := dialog.getchar(pdialog, 'PAN');
							vmbr := dialog.getchar(pdialog, 'MBR');
						
							vuseonline := nvl(dialog.getbool(pdialog, 'UseOnline'), FALSE);
							vacardlist := complexcard.getlinkedcardlist(vpan, vmbr);
							IF vacardlist.count > 0
							THEN
								IF dialog.exec(service.dialogconfirm('Warning!'
																	,'Linked cards [' ||
																	 to_char(vacardlist.count) ||
																	 '] will also be moved.~ Continue moving?'
																	,'  Yes '
																	,' '
																	,'  No  '
																	,' ')) != dialog.cmok
								THEN
									dialog.sethothint(pdialog, 'Moving cancelled');
									dialog.goitem(pdialog, 'ContractNo');
									RETURN;
								END IF;
							END IF;
							movecard(vpan, vmbr, vfromcontract, vno, vuseonline);
						
							COMMIT;
						EXCEPTION
							WHEN OTHERS THEN
								error.save(cmethod_name);
								ROLLBACK TO spbeginremove;
								error.showerror();
								error.showstack();
								dialog.cancelclose(pdialog);
								RETURN;
						END;
					END IF;
				
					IF vitemname IS NOT NULL
					THEN
						dialog.sethothint(pdialog, 'Error: Field not defined');
						dialog.goitem(pdialog, vitemname);
						RETURN;
					END IF;
				END IF;
			ELSE
				NULL;
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END dialogremovecardproc;

	FUNCTION dialogdelete(pno IN VARCHAR2) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DialogDelete';
		vdialog NUMBER;
	BEGIN
		vdialog := dialog.new('Delete contract', 0, 0, 58, 11, pextid => cmethod_name);
	
		dialog.textlabel(vdialog, 'ClientText1', 4, 2, 50, ' ');
		dialog.textlabel(vdialog, 'ClientText2', 4, 3, 50, ' ');
		dialog.textlabel(vdialog, 'ClientText3', 4, 4, 50, ' ');
		dialog.textlabel(vdialog, 'ContractText', 4, 5, 50, ' ');
	
		dialog.hiddenchar(vdialog, 'No', pno);
	
		dialog.hiddennumber(vdialog, 'IdClient');
	
		dialog.hiddennumber(vdialog, 'ContractType');
		dialog.hiddennumber(vdialog, 'ContractAccessory');
	
		dialog.checkbox(vdialog
					   ,'DeleteClient'
					   ,6
					   ,6
					   ,44
					   ,1
					   ,'Specify reason for deleting details of contract holder');
		dialog.listaddrecord(vdialog, 'DeleteClient', 'Delete details of contract holder', 0, 0);
	
		dialog.button(vdialog, 'Ok', 17, 9, 11, '  Delete', dialog.cmok, 0, 'Delete contract');
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
		dialog.button(vdialog
					 ,'Cancel'
					 ,30
					 ,9
					 ,9
					 ,'  Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel deletion');
	
		dialog.setdialogpre(vdialog, 'Contract.DialogDeleteProc');
		dialog.setdialogvalid(vdialog, 'Contract.DialogDeleteProc');
	
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END dialogdelete;

	PROCEDURE dialogdeleteproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DialogDeleteProc';
		vno          tcontract.no%TYPE;
		vcontractrow tcontract%ROWTYPE;
	
		vdeleteclient BOOLEAN;
	BEGIN
		CASE pwhat
			WHEN dialog.wtdialogpre THEN
				vno          := dialog.getchar(pdialog, 'No');
				vcontractrow := getcontractrowtype(vno);
				dialog.putnumber(pdialog, 'IdClient', vcontractrow.idclient);
				dialog.putnumber(pdialog, 'ContractType', vcontractrow.type);
				dialog.putnumber(pdialog
								,'ContractAccessory'
								,contracttype.getaccessory(vcontractrow.type));
			
				getclientinfo(pdialog, vcontractrow.idclient);
			
				dialog.putchar(pdialog, 'ContractText', service.cpad('Contract: ' || vno, 50, ' '));
				dialog.putchar(pdialog, 'DeleteClient', NULL);
			WHEN dialog.wtdialogvalid THEN
				vno := dialog.getchar(pdialog, 'No');
			
				vdeleteclient := (nvl(dialog.getchar(pdialog, 'DeleteClient'), '0') = '1');
				deletecontract(vno, vdeleteclient, c_interactivemode);
				IF err.geterrorcode() != 0
				THEN
					ROLLBACK;
					service.sayerr(pdialog, 'Warning!');
					dialog.cancelclose(pdialog);
					RETURN;
				END IF;
			
				COMMIT;
			ELSE
				NULL;
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			error.showerror();
			ROLLBACK;
			dialog.cancelclose(pdialog);
	END dialogdeleteproc;

	PROCEDURE dialognewcardproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DialogNewCardProc';
		vdialog       NUMBER;
		vcount        NUMBER;
		vret          NUMBER;
		fmarked       BOOLEAN := FALSE;
		vcontractrow  tcontract%ROWTYPE;
		vmark         CHAR(1);
		vcard2acclink tacc2card%ROWTYPE;
	BEGIN
		CASE pwhat
			WHEN dialog.wtdialogpre THEN
				vdialog := dialog.getowner(pdialog);
			
				IF contracttools.getcontractrecord(dialog.getchar(vdialog, 'No'), vcontractrow) != 0
				THEN
					service.sayerr(pdialog, 'Warning!');
					dialog.abort(pdialog);
					RETURN;
				END IF;
			
				vcount := contractcard.initarray(vcontractrow.type);
				FOR i IN 1 .. vcount
				LOOP
					IF contractcard.getarraycardproduct(i) IS NULL
					   OR contractcard.getarraycreatetype(i) IS NULL
					   OR contractcard.getarraycreatemode(i) IS NULL
					THEN
						service.saymsg(pdialog
									  ,'Warning!'
									  ,'Card settings missing in contract type~');
						dialog.abort(pdialog);
						RETURN;
					END IF;
				END LOOP;
			
				dialog.putnumber(pdialog, 'Type', vcontractrow.type);
				dialog.putnumber(pdialog, 'IdClient', vcontractrow.idclient);
				dialog.putchar(pdialog, 'No', vcontractrow.no);
				getclientinfo(pdialog, vcontractrow.idclient);
				vret := fillcardlist(pdialog
									,'Card'
									,vcontractrow.type
									,vcontractrow.idclient
									,dialog.getnumber(pdialog, 'CreateType'));
			
				IF vret = 0
				THEN
					dialog.setenabled(pdialog, 'OK', FALSE);
					RETURN;
				END IF;
			WHEN dialog.wtitempre THEN
				IF pitemname = 'CARD'
				THEN
					DECLARE
					
						vparentcard apitypes.typecardrecord;
					
						vcard         typecardparams;
						vcardinfolist card.typefullcardinfolist;
					BEGIN
					
						vcard.pan := dialog.getcurrentrecordchar(pdialog, 'Card', 'PAN');
						t.var('vPan', card.getmaskedpan(vcard.pan), csay_level);
						vcard.itemcode := dialog.getcurrentrecordnumber(pdialog, 'Card', 'ItemCode');
						t.var('vCard.ItemCode', vcard.itemcode);
					
						vcard.cardtype := dialog.getnumber(pdialog, 'CreateType');
						t.var('vCard.CardType', vcard.cardtype);
						vcard.createtype  := contractcard.newcreate;
						vcard.cardproduct := dialog.getcurrentrecordnumber(pdialog
																		  ,'Card'
																		  ,'CardProduct');
						t.var('vCard.CardProduct', vcard.cardproduct);
						IF vcard.cardtype != card.ccssupplementary
						THEN
							vcard.idclient := dialog.getnumber(pdialog, 'IdClient');
						ELSIF referencecardproduct.getcptype(vcard.cardproduct) =
							  referencecardproduct.ccpmultiapplication
						THEN
							service.saymsg(pdialog
										  ,'Warning!'
										  ,'Creation of additional multiapplication cards is not supported~');
							dialog.cancelclose(pdialog);
							RETURN;
						END IF;
						vcard.link2existingcontract := TRUE;
					
						vcard2acclink := getcard2accountlink(vcard.itemcode
															,dialog.getchar(vdialog, 'No'));
					
						IF vcard.pan IS NULL
						THEN
						
							IF dialog.getchar(pdialog, 'PARENTPAN') IS NOT NULL
							THEN
								vparentcard := card.getcardrecord(dialog.getchar(pdialog
																				,'PARENTPAN')
																 ,dialog.getnumber(pdialog
																				  ,'PARENTMBR'));
								t.var('vParentCard.PAN', card.getmaskedpan(vparentcard.pan));
								t.var('vParentCard.MBR', vparentcard.mbr);
								t.var('vParentCard.CardProduct', vparentcard.cardproduct);
							
								IF vparentcard.cardproduct != vcard.cardproduct
								THEN
									vparentcard.pan := NULL;
									vparentcard.mbr := NULL;
								END IF;
							END IF;
						
							t.var(cmethod_name || ': vCard.CardType', vcard.cardtype);
							vcardinfolist := card.getcardlistfromdialog(vcard.cardtype
																	   ,
																		
																		ppan => vparentcard.pan
																	   ,pmbr => vparentcard.mbr
																	   ,
																		
																		paccountno                  => vcard2acclink.accountno
																	   ,pcardproduct                => vcard.cardproduct
																	   ,pidclient                   => vcard.idclient
																	   ,pcontracttype               => dialog.getnumber(pdialog
																													   ,'Type')
																	   ,pcontractitem               => vcard.itemcode
																	   ,pwithoutissuesettingsdialog => TRUE
																	   ,pcontractno                 => dialog.getchar(vdialog
																													 ,'No'));
						
							t.var('[1] vCardInfoList(1).Card.IdClient'
								 ,vcardinfolist(1).card.idclient);
							IF vcardinfolist.count > 0
							   AND vcardinfolist(1).card.pan IS NOT NULL
							THEN
								setnewcardlist(vcard.itemcode, vcardinfolist);
								refreshcardline(pdialog
											   ,'Card'
											   ,dialog.getlistcurrentrecordnumber(pdialog, 'Card')
											   ,vcard
											   ,vcardinfolist(1));
							END IF;
						ELSE
							t.note('point 02');
						
							IF existnewcardlist(vcard.itemcode)
							THEN
							
								vcardinfolist := getnewcardlist(vcard.itemcode);
								vcardinfolist := card.getcardlistfromdialog(pafullcardinfolist => vcardinfolist
																		   ,pwhat              => vcard.cardtype
																		   ,pcontracttype      => dialog.getnumber(pdialog
																												  ,'Type')
																		   ,pcontractitem      => vcard.itemcode);
							
								t.var('[2] vCardInfoList(1).Card.IdClient'
									 ,vcardinfolist(1).card.idclient);
								IF vcardinfolist.count > 0
								   AND vcardinfolist(1).card.pan IS NOT NULL
								THEN
								
									setnewcardlist(vcard.itemcode, vcardinfolist);
									refreshcardline(pdialog
												   ,'Card'
												   ,dialog.getlistcurrentrecordnumber(pdialog
																					 ,'Card')
												   ,vcard
												   ,vcardinfolist(1));
								
								END IF;
							END IF;
						END IF;
					
						FOR i IN 1 .. vcardinfolist.count
						LOOP
							t.note(cmethod_name
								  , 'vCardInfoList(' || i || ').ContractItem=' || vcardinfolist(i)
								   .contractitem
								  ,csay_level);
						END LOOP;
					
					END;
				END IF;
			WHEN dialog.wtdialogvalid THEN
				FOR i IN 1 .. dialog.getlistreccount(pdialog, 'Card')
				LOOP
					vmark := service.getchar(dialog.getchar(pdialog, 'Card'), i);
					s.say(cmethod_name || ': vMark=[' || vmark || ']');
					IF rtrim(vmark) IS NOT NULL
					THEN
						fmarked := TRUE;
						IF dialog.getrecordnumber(pdialog, 'Card', 'IdClient', i) IS NULL
						THEN
							htools.message('Warning', 'Cardholder not defined!');
							dialog.goitem(pdialog, 'Card');
							dialog.setcurrec(pdialog, 'Card', i);
							RETURN;
						END IF;
					
						IF dialog.getrecordnumber(pdialog, 'Card', 'CreateMode', i) IS NULL
						THEN
							s.say('point [2]');
							htools.message('Warning', 'Card not defined!');
							dialog.goitem(pdialog, 'Card');
							dialog.setcurrec(pdialog, 'Card', i);
							RETURN;
						END IF;
					END IF;
				END LOOP;
			
				IF NOT fmarked
				THEN
					htools.message('Warning', 'No marked card product for creation.');
					dialog.goitem(pdialog, 'Card');
					RETURN;
				END IF;
			
				addcard(pdialog);
			ELSE
				NULL;
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END dialognewcardproc;

	FUNCTION contractexists(pcontract IN VARCHAR2) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ContractExists';
		cbranch      CONSTANT NUMBER := seance.getbranch();
	BEGIN
		FOR ci IN (SELECT no
				   FROM   tcontract
				   WHERE  branch = cbranch
				   AND    no = pcontract)
		LOOP
			RETURN TRUE;
		END LOOP;
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END contractexists;

	FUNCTION existscontract(pcontracttype IN NUMBER) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExistsContract';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		CURSOR /*+ FIRST_ROWS(1) */
		c1 IS
			SELECT TYPE
			FROM   tcontract
			WHERE  branch = cbranch
			AND    TYPE = pcontracttype;
	BEGIN
		FOR i IN c1
		LOOP
			RETURN TRUE;
		END LOOP;
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END existscontract;

	FUNCTION getoperationlist
	(
		pinitparameters IN typeinitparameters
	   ,pdoexception    IN BOOLEAN := TRUE
	) RETURN typeschemaoperationsarray IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetOperationList';
		cfuncname    CONSTANT VARCHAR2(65) := 'GetOperationList';
		v1     VARCHAR2(250);
		v2     VARCHAR2(250);
		vcount NUMBER;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pInitParameters.SchemePackage=' || pinitparameters.schemepackage ||
				', pInitParameters.ContractType=' || pinitparameters.contracttype ||
				', pInitParameters.ContractNo=' || pinitparameters.contractno);
		t.inpar('pDoException', t.b2t(pdoexception));
	
		soperationarray.delete;
		IF contractschemas.existsmethod(pinitparameters.schemepackage
									   ,cfuncname
									   ,'/in:N/in:V/out:A/ret:N')
		THEN
			EXECUTE IMMEDIATE 'BEGIN :VALUE :=' || pinitparameters.schemepackage || '.' ||
							  cfuncname || '(:TYPE,:NO,Contract.sOperationArray); END;'
				USING OUT vcount, IN pinitparameters.contracttype, IN pinitparameters.contractno;
			t.var('[1] vCount', vcount);
			t.var('count2', soperationarray.count);
		ELSE
			BEGIN
				EXECUTE IMMEDIATE 'BEGIN :VALUE := ' || pinitparameters.schemepackage ||
								  '.SOPERCOUNT; END;'
					USING OUT vcount;
			
				FOR i IN 1 .. vcount
				LOOP
					EXECUTE IMMEDIATE 'BEGIN :NAME := ' || pinitparameters.schemepackage ||
									  '.SAOPERNAME(' || i || '); :CODE := ' ||
									  pinitparameters.schemepackage || '.SAOPERCODE(' || i ||
									  '); END;'
						USING OUT v1, OUT v2;
				
					soperationarray(i).operationname := TRIM(substr(v1, 1, copernamesize));
					soperationarray(i).operationcode := ltrim(rtrim(v2));
					soperationarray(i).operationtype := cschemaoperation;
					t.var('Operation name', v1);
					t.var('Operation code', v2);
					soperationarray(i).ismodifiability := 1;
					soperationarray(i).enabled := 1;
				
				END LOOP;
			
			EXCEPTION
				WHEN OTHERS THEN
					s.err(cmethod_name);
					soperationarray.delete;
					vcount := 0;
			END;
		END IF;
	
		t.leave(cmethod_name, 'return ' || vcount);
		RETURN soperationarray;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setschemeoperationlist
	(
		ppackage  IN contractschemas.typeschemapackagename
	   ,poperlist IN typeschemaoperationsarray
	) IS
	BEGIN
		saschemeoperationlist(upper(ppackage)) := poperlist;
	END;

	FUNCTION getoperationsbyscheme
	(
		ppackage     IN custom_fintypes.typepackagename
	   ,pdoexception BOOLEAN := TRUE
	) RETURN custom_contract.typeschemaoperationsarray IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetOperationsBySchema';
		vaoperations    custom_contract.typeschemaoperationsarray;
		vinitparameters custom_contract.typeinitparameters;
	BEGIN
		t.enter(cmethod_name, 'pPackage=' || ppackage);
		IF saschemeoperationlist.exists(upper(ppackage))
		THEN
			t.note(cmethod_name, 'from cache');
			vaoperations := saschemeoperationlist(upper(ppackage));
		ELSE
			t.note(cmethod_name, 'loading scheme operations...');
			vinitparameters.contracttype  := -1;
			vinitparameters.schemepackage := ppackage;
			vaoperations                  := getoperationlist(vinitparameters, pdoexception);
			setschemeoperationlist(ppackage, vaoperations);
		END IF;
		t.leave(cmethod_name, 'return ' || vaoperations.count || ' operations');
		RETURN vaoperations;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getschemepackage
	(
		pinitparams  IN typeinitparameters
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN contractschemas.typeschemapackagename IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetSchemePackage';
		vret contractschemas.typeschemapackagename;
		vstr VARCHAR2(150);
	BEGIN
		t.enter(cmethod_name
			   ,'pInitParams.ContractNo=' || pinitparams.contractno ||
				', pInitParams.ContractType=' || pinitparams.contracttype ||
				', pInitParams.SchemeType=' || pinitparams.schemetype);
	
		IF pinitparams.schemetype IS NOT NULL
		THEN
			vret := upper(contractschemas.getrecord(pinitparams.schemetype, TRUE).packagename);
			vstr := 'for scheme with code [' || pinitparams.schemetype || ']';
		ELSIF pinitparams.contracttype IS NOT NULL
		THEN
			vret := upper(contracttype.getschemapackage(pinitparams.contracttype, TRUE));
			vstr := 'for contract type with code [' || pinitparams.contracttype || ']';
		ELSIF pinitparams.contractno IS NOT NULL
		THEN
			vret := upper(contracttype.getschemapackage(gettype(pinitparams.contractno), TRUE));
			vstr := 'for contract with No [' || pinitparams.contractno || ']';
		ELSE
			error.raiseerror('Mandatory parameters not defined');
		END IF;
		IF nvl(pdoexception, FALSE)
		   AND vret IS NULL
		THEN
			error.raiseerror('Not defined financial scheme description procedure ' || vstr);
		END IF;
		t.leave(cmethod_name, 'vRet=' || vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION mergeschemaandsotoperations
	(
		paschemaoperations IN typeschemaoperationsarray
	   ,patemplatesonct    IN apitypes.typesotemplatearray
	) RETURN typeschemaoperationsarray
	
	 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.BuildOperList';
		vaoperationtemp typeschemaoperationsarray;
		k               PLS_INTEGER;
		i               PLS_INTEGER;
		vindex          BINARY_INTEGER;
		vatemplatesonct apitypes.typesotemplatearray;
	
		PROCEDURE addoperation
		(
			pindex         IN PLS_INTEGER
		   ,poperationname IN VARCHAR2
		   ,poperationcode IN VARCHAR2
		   ,poperationtype IN NUMBER := NULL
		   ,pmodifiability IN NUMBER := NULL
		   ,penabled       IN NUMBER := NULL
		) IS
		BEGIN
			vaoperationtemp(pindex).operationname := TRIM(substr(poperationname, 1, copernamesize));
			vaoperationtemp(pindex).operationcode := poperationcode;
			s.say(cmethod_name || ': name ' || vaoperationtemp(pindex).operationname, csay_level);
			s.say(cmethod_name || ': code ' || vaoperationtemp(pindex).operationcode, csay_level);
			vaoperationtemp(pindex).operationtype := nvl(poperationtype, ctemplateoperation);
			vaoperationtemp(pindex).ismodifiability := nvl(pmodifiability, 1);
			vaoperationtemp(pindex).enabled := nvl(penabled, 1);
		END;
	
	BEGIN
		vatemplatesonct := patemplatesonct;
		k               := 0;
		FOR i IN 1 .. paschemaoperations.count
		LOOP
			IF paschemaoperations(i).operationtype != ctemplateoperation
			THEN
				k := k + 1;
				vaoperationtemp(k) := paschemaoperations(i);
			ELSE
				vindex := vatemplatesonct.first();
				WHILE vindex IS NOT NULL
				LOOP
					IF vatemplatesonct(vindex).operationid = paschemaoperations(i).operationcode
					THEN
						k := k + 1;
						addoperation(k
									,vatemplatesonct(vindex).name
									,to_char(vatemplatesonct(vindex).id)
									,paschemaoperations(i).operationtype
									,paschemaoperations(i).ismodifiability
									,paschemaoperations(i).enabled);
						vatemplatesonct.delete(vindex);
					END IF;
					vindex := vatemplatesonct.next(vindex);
				END LOOP;
			END IF;
		END LOOP;
		s.say(cmethod_name || ': vaTemplatesOnCT.Count=' || vatemplatesonct.count, csay_level);
		vindex := vatemplatesonct.first();
		WHILE vindex IS NOT NULL
		LOOP
			k := k + 1;
			addoperation(k, vatemplatesonct(vindex).name, to_char(vatemplatesonct(vindex).id));
			vindex := vatemplatesonct.next(vindex);
		END LOOP;
		s.say(cmethod_name || ': count ' || vaoperationtemp.count, csay_level);
		RETURN vaoperationtemp;
	END;

	FUNCTION initoperlist(pinitparameters IN typeinitparameters) RETURN typeschemaoperationsarray IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.InitOperList[1]';
		vpackage        contractschemas.typeschemapackagename;
		vasotoperlist   apitypes.typesotemplatearray;
		vinitparameters typeinitparameters := pinitparameters;
	BEGIN
		t.enter(cmethod_name);
		vpackage := getschemepackage(vinitparameters);
		IF vpackage IS NULL
		THEN
			error.raiseerror('Financial scheme procedure not defined');
		END IF;
		vinitparameters.schemepackage := vpackage;
		soperationarray.delete;
	
		IF vinitparameters.contractno IS NOT NULL
		THEN
			soperationarray := getoperationlist(vinitparameters, FALSE);
		ELSE
			--soperationarray := getoperationsbyscheme(vpackage, FALSE);
			NULL;
		END IF;
	
		vasotoperlist := sot_core.gettemplates(apitypes.csotcsocontracttype
											  ,vinitparameters.contracttype);
		s.say(cmethod_name || ': SOT''s count ' || vasotoperlist.count, csay_level);
	
		soperationarray := mergeschemaandsotoperations(soperationarray, vasotoperlist);
		t.leave(cmethod_name, 'sOperationArray.count=' || soperationarray.count);
	
		RETURN soperationarray;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE revokerights(pcontracttype IN tcontracttype.type%TYPE) IS
	BEGIN
		--contractrights.revokerights(pcontracttype);
		NULL;
	END;

	FUNCTION getarcdate(pcontractno VARCHAR2) RETURN DATE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetArcDate';
		vhandle NUMBER;
		vnew    BOOLEAN;
		vret    DATE;
	BEGIN
		s.say(cmethod_name || ': enter', csay_level);
	
		vhandle := gethandle(pcontractno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontractno, 'R');
			vnew    := TRUE;
		END IF;
		vret := scontractarray(vhandle).contractrow.arcdate;
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN no_data_found THEN
			error.saveraise(cmethod_name
						   ,error.errorconst
						   ,'Contract "' || pcontractno || '" not found.');
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END getarcdate;

	FUNCTION getaccountno
	(
		pno       IN VARCHAR2
	   ,pitemcode IN NUMBER
	) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetAccountNo';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vkey tcontractitem.key%TYPE;
	BEGIN
		SELECT key
		INTO   vkey
		FROM   tcontractitem
		WHERE  branch = cbranch
		AND    no = pno
		AND    itemcode = pitemcode;
		RETURN vkey;
	EXCEPTION
		WHEN no_data_found THEN
			err.seterror(err.contract_item_not_found, cmethod_name);
			RETURN NULL;
	END getaccountno;

	FUNCTION getaccountnobyitemname
	(
		pno       IN VARCHAR2
	   ,pitemname IN VARCHAR2
	) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetAccountNoByItemName';
		vitemcode NUMBER;
		vctype    NUMBER;
	BEGIN
		vctype := gettype(pno);
		IF vctype IS NULL
		THEN
			err.seterror(err.geterrorcode(), cmethod_name);
			RETURN NULL;
		END IF;
		vitemcode := contracttypeitems.getitemcode(vctype, pitemname);
		IF vitemcode IS NULL
		THEN
			err.seterror(err.contract_item_not_found, cmethod_name);
			RETURN NULL;
		END IF;
	
		RETURN getaccountno(pno, vitemcode);
	EXCEPTION
		WHEN contracttools.valuenotexists THEN
			err.seterror(err.contract_item_not_found, cmethod_name);
			RETURN NULL;
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN NULL;
	END getaccountnobyitemname;

	FUNCTION getbranchpart(pcontract IN VARCHAR2) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetBranchPart';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vret NUMBER;
	BEGIN
		s.say(cmethod_name || ': for ' || pcontract, csay_level);
		SELECT branchpart
		INTO   vret
		FROM   tcontract
		WHERE  branch = cbranch
		AND    no = pcontract;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getbranchpart;

	FUNCTION getcommentary(pcontractno IN VARCHAR2) RETURN CLOB IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCommentary';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vret CLOB;
	BEGIN
		SELECT commentary
		INTO   vret
		FROM   tcontract
		WHERE  branch = cbranch
		AND    no = pcontractno;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcommentary;

	PROCEDURE getcontractprimarycard
	(
		pcontractno IN tcontract.no%TYPE
	   ,opan        OUT tcard.pan%TYPE
	   ,ombr        OUT tcard.mbr%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractPrimaryCard';
		cbranch      CONSTANT NUMBER := seance.getbranch();
	
		CURSOR c1 IS
			SELECT b.pan
				  ,b.mbr
				  ,b.crd_stat
			FROM   tcontract c
			INNER  JOIN tcontractcarditem a
			ON     a.branch = c.branch
			AND    a.no = c.no
			INNER  JOIN tcard b
			ON     b.branch = a.branch
			AND    b.pan = a.pan
			AND    b.mbr = a.mbr
			WHERE  c.branch = cbranch
			AND    c.no = pcontractno
			AND    c.idclient = b.idclient;
	
	BEGIN
		FOR i IN c1
		LOOP
			IF i.crd_stat != referencecrd_stat.card_closed
			THEN
				IF i.crd_stat = referencecrd_stat.card_open
				THEN
					opan := i.pan;
					ombr := i.mbr;
					RETURN;
				END IF;
			
				IF opan IS NULL
				THEN
					opan := i.pan;
					ombr := i.mbr;
				END IF;
			END IF;
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcontractprimarycard;

	FUNCTION getstatus(pno IN VARCHAR2) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetStatus';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vstatus VARCHAR2(10);
	BEGIN
		SELECT status
		INTO   vstatus
		FROM   tcontract
		WHERE  branch = cbranch
		AND    no = pno;
		RETURN nvl(vstatus, ' ');
	EXCEPTION
		WHEN no_data_found THEN
			err.seterror(err.contract_not_found, cmethod_name);
			RETURN NULL;
	END getstatus;

	FUNCTION getstatusname(pstatus VARCHAR2) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetStatusName';
		vstatstr VARCHAR2(100) := NULL;
	BEGIN
		IF checkstatus(pstatus, stat_ok)
		THEN
			vstatstr := getstatusnamebycode(stat_ok);
			RETURN vstatstr;
		END IF;
		IF checkstatus(pstatus, stat_close)
		THEN
			vstatstr := vstatstr || service.iif(vstatstr IS NULL, ' ', ', ') ||
						getstatusnamebycode(stat_close);
		END IF;
		IF checkstatus(pstatus, stat_violate)
		THEN
			vstatstr := vstatstr || service.iif(vstatstr IS NULL, ' ', ', ') ||
						getstatusnamebycode(stat_violate);
		END IF;
		IF checkstatus(pstatus, stat_suspend)
		THEN
			vstatstr := vstatstr || service.iif(vstatstr IS NULL, ' ', ', ') ||
						getstatusnamebycode(stat_suspend);
		END IF;
		IF checkstatus(pstatus, stat_investigation)
		THEN
			vstatstr := vstatstr || service.iif(vstatstr IS NULL, ' ', ', ') ||
						getstatusnamebycode(stat_investigation);
		END IF;
	
		RETURN service.trim(vstatstr);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getstatusname;

	FUNCTION getstatusnamebycode(pstatuscode NUMBER) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '. GetStatusNameByCode';
	BEGIN
		s.say(cmethod_name || ': status code ' || pstatuscode, csay_level);
		RETURN sastatusname(pstatuscode);
	EXCEPTION
		WHEN no_data_found THEN
			error.saveraise(cmethod_name, error.errorconst, 'Invalid contract status code');
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getstatusnamebycode;

	FUNCTION gettype
	(
		pno          IN tcontract.no%TYPE
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetType';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vtype NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'pNo=' || pno || ', pDoException=' || t.b2t(pdoexception)
			   ,csay_level);
	
		SELECT TYPE
		INTO   vtype
		FROM   tcontract
		WHERE  branch = cbranch
		AND    no = pno;
	
		t.leave(cmethod_name, 'vType=' || vtype, csay_level);
		RETURN vtype;
	EXCEPTION
		WHEN no_data_found THEN
			t.exc(cmethod_name, '[1]', plevel => csay_level);
			IF nvl(pdoexception, FALSE)
			THEN
				error.raiseerror(err.contract_not_found, 'Contract with No [' || pno || ']');
			ELSE
				err.seterror(err.contract_not_found, cmethod_name);
				RETURN NULL;
			END IF;
		WHEN OTHERS THEN
			t.exc(cmethod_name, '[2]', plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END gettype;

	FUNCTION getuserattributeslist(pcontractno IN VARCHAR2) RETURN apitypes.typeuserproplist IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetUserAttributesList';
		vuserattributeslist apitypes.typeuserproplist;
	BEGIN
		vuserattributeslist := objuserproperty.getrecord(object_name, getuid(pcontractno));
		RETURN vuserattributeslist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getuserattributeslist;

	FUNCTION getuserattributerecord
	(
		pcontractno IN VARCHAR2
	   ,pfieldname  VARCHAR2
	) RETURN apitypes.typeuserproprecord IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetUserAttributeRecord';
	BEGIN
		RETURN objuserproperty.getfield(object_name, getuid(pcontractno), pfieldname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getuserattributerecord;

	FUNCTION getcurrentdlguserattributes RETURN apitypes.typeuserproplist IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCurrentDlgUserAttributes';
		vuserattributeslist apitypes.typeuserproplist;
	BEGIN
		vuserattributeslist := objuserproperty.getpagedata(scontdlg, object_name);
		RETURN vuserattributeslist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcurrentdlguserattributes;

	PROCEDURE saveuserattributeslist
	(
		pcontractno         IN tcontract.no%TYPE
	   ,plist               IN apitypes.typeuserproplist
	   ,pclearpropnotinlist BOOLEAN
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SaveUserAttributesList';
		cobjecttype  CONSTANT NUMBER := object.gettype(object_name);
		vobjectuid objectuid.typeobjectuid;
	BEGIN
		t.enter(cmethod_name);
		vobjectuid := getuid(pcontractno);
		objuserproperty.saverecord(object_name
								  ,vobjectuid
								  ,plist
								  ,pclearpropnotinlist
								  ,NULL
								  ,cobjecttype
								  ,pcontractno
								  ,plog_clientid => getclientid(pcontractno));
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getrightkey
	(
		pright        IN VARCHAR2
	   ,pcontracttype IN NUMBER := NULL
	   ,popercode     IN VARCHAR2 := NULL
	   ,pprop         IN VARCHAR2 := NULL
	) RETURN VARCHAR2 IS
	BEGIN
		IF pright IN (right_view, right_open, right_statement)
		   AND pcontracttype IS NOT NULL
		THEN
			RETURN '|' || pright || '|' || to_char(pcontracttype) || '|';
		ELSIF pright IN (right_modify_attr
						,right_change_client
						,right_modify_branchpart
						,right_modify_card
						,right_change_type
						,right_modify_account
						,right_modify_process)
		THEN
			RETURN '|' || right_modify || '|' || pright || '|';
		ELSIF pright IN (right_modify_card_issue_main
						,right_modify_card_issue_corp
						,right_modify_card_reissue
						,right_modify_card_add
						,right_modify_card_move
						,right_modify_card_delete)
		THEN
			RETURN '|' || right_modify || '|' || right_modify_card || '|' || pright || '|';
		ELSIF pright IN (right_modify_account_add, right_modify_account_remove)
		THEN
			RETURN '|' || right_modify || '|' || right_modify_account || '|' || pright || '|';
		
		ELSIF pright IN (right_modify_adjust, right_modify_undo_all, right_modify_undo_own)
		THEN
			RETURN '|' || right_modify || '|' || right_modify_process || '|' || pright || '|';
		
		ELSIF pright = right_modify_oper
		THEN
			RETURN '|' || right_modify || '|' || pright || '|' || to_char(pcontracttype) || '|' || service.iif(popercode IS NOT NULL
																											  ,popercode || '|'
																											  ,'') || service.iif(pprop IS NOT NULL
																																 ,pprop || '|'
																																 ,'');
		
		ELSIF (pright IN (right_reference_view, right_reference_modify))
		THEN
			RETURN '|' || right_reference || '|' || pright || '|';
		
		ELSIF (pright IN (right_vip_all_branchpart, right_vip_filial, right_vip_own_branchpart))
		THEN
			RETURN '|' || right_view_vip || '|' || pright || '|';
		
		ELSIF pright IN (right_periodic_statement_add
						,right_periodic_statement_mod
						,right_periodic_statement_del)
		THEN
			RETURN '|' || right_periodic_statement || '|' || pright || '|' || to_char(pcontracttype) || '|';
		
		ELSE
			RETURN '|' || pright || '|';
		END IF;
	END getrightkey;

	FUNCTION iscanwatch(pcontno VARCHAR2) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.isCanWatch';
		TYPE typewhichunit IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(6);
		vwhichunit typewhichunit;
		vresult    BOOLEAN := FALSE;
		vcontract  tcontract%ROWTYPE;
	
		FUNCTION towhichunit RETURN VARCHAR2 IS
			vcurbranchpartcont NUMBER;
			vcurbranchpartoper NUMBER;
		
			csubmethodname CONSTANT VARCHAR2(80) := cpackage_name || '.isCanWatch.toWhichUnit';
		BEGIN
		
			vcurbranchpartcont := nvl(getbranchpart(pcontno), seance.getbranchpart);
			vcurbranchpartoper := seance.getbranchpart;
		
			IF (vcurbranchpartcont = vcurbranchpartoper)
			THEN
				RETURN 'own';
			END IF;
		
			IF referencebranchpart.ischild(vcurbranchpartcont, vcurbranchpartoper)
			THEN
				RETURN 'filial';
			END IF;
		
			t.leave(csubmethodname);
		
			RETURN 'other';
		EXCEPTION
			WHEN OTHERS THEN
				error.save(csubmethodname);
				RAISE;
		END towhichunit;
	BEGIN
		t.enter(cmethod_name);
		vwhichunit('other') := 1;
		vwhichunit('filial') := 2;
		vwhichunit('own') := 3;
		t.note('Unit operator: ' || towhichunit);
	
		vcontract := getcontractrowtype(pcontno);
	
		IF client.canview(vcontract.idclient)
		   AND security.checkright(object_name, getrightkey(right_view, vcontract.type))
		THEN
		
			IF NOT client.isvip(vcontract.idclient)
			THEN
			
				IF vwhichunit(towhichunit) = vwhichunit('own')
				THEN
				
					vresult := TRUE;
					t.note('A contract refers to the unit to which the operator');
				
				ELSIF security.checkright(object_name, getrightkey(right_view_all_branchpart))
				THEN
				
					vresult := TRUE;
					t.note('The operator has the right to view all units');
				END IF;
			
			ELSIF security.checkright(object_name, getrightkey(right_vip_all_branchpart))
			THEN
			
				vresult := TRUE;
				t.note('The operator has the right to review all contracts VIP units ');
			
			ELSIF (vwhichunit(towhichunit) = vwhichunit('filial'))
				  AND security.checkright(object_name, getrightkey(right_vip_filial))
			THEN
			
				vresult := TRUE;
				t.note('A contract belongs to the subsidiaries and the operator has the right to view subsidiaries');
			
			ELSIF (vwhichunit(towhichunit) = vwhichunit('own'))
				  AND security.checkright(object_name, getrightkey(right_vip_own_branchpart))
			THEN
			
				vresult := TRUE;
			
			END IF;
		
		END IF;
		t.leave(cmethod_name, 'result:=' || htools.bool2str(vresult));
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END iscanwatch;

	FUNCTION checkright
	(
		pright        IN NUMBER
	   ,pcontno       IN tcontract.no%TYPE := NULL
	   ,popercode     IN VARCHAR2 := NULL
	   ,pcontracttype IN tcontracttype.type%TYPE := NULL
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CheckRight';
		vcontracttype tcontracttype.type%TYPE;
		vright        BOOLEAN;
	BEGIN
		t.enter(cmethod_name);
		t.inpar('pRight', pright);
		t.inpar('pContNo', pcontno);
		t.inpar('pOperCode', popercode);
		t.inpar('pContractType', pcontracttype);
	
		IF pcontracttype IS NULL
		THEN
			vcontracttype := gettype(pcontno);
		ELSE
			vcontracttype := pcontracttype;
		END IF;
		t.inpar('[2] vContractType', vcontracttype);
	
		IF pright IN (right_view, right_open)
		THEN
			t.note('point [1]');
			vright := security.checkright(object_name, getrightkey(pright, vcontracttype));
		ELSIF pright = right_modify_oper
		THEN
			t.note('point [2]');
			vright := security.checkright(object_name
										 ,getrightkey(pright, vcontracttype, popercode));
		ELSIF pright = right_statement
		THEN
			t.note('point [3]');
			vright := security.checkright(object_name, getrightkey(pright, vcontracttype));
		ELSIF pright IN (right_periodic_statement_add
						,right_periodic_statement_mod
						,right_periodic_statement_del)
		THEN
			t.note('point [4]');
			vright := security.checkright(object_name, getrightkey(pright, vcontracttype));
		ELSE
		
			t.note('point [5]');
			vright := security.checkright(object_name, getrightkey(pright));
		END IF;
		t.leave(cmethod_name, 'vRight=' || t.b2t(vright));
		RETURN vright;
	
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END checkright;

	FUNCTION checkoperright
	(
		pright    IN NUMBER
	   ,pcontno   IN VARCHAR2 := NULL
	   ,popercode IN VARCHAR2 := NULL
	   ,pprop     IN VARCHAR2 := NULL
	) RETURN BOOLEAN IS
	BEGIN
		RETURN security.checkright(object_name
								  ,getrightkey(pright, gettype(pcontno), popercode, pprop));
	END checkoperright;

	FUNCTION checkstatus
	(
		pstat IN VARCHAR2
	   ,pflag IN NUMBER
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CheckStatus';
	BEGIN
		CASE pflag
			WHEN stat_ok THEN
				RETURN rtrim(pstat) IS NULL;
			WHEN stat_close THEN
				RETURN rtrim(substr(pstat, 1, 1)) IS NOT NULL;
			WHEN stat_violate THEN
				RETURN rtrim(substr(pstat, 2, 1)) IS NOT NULL;
			WHEN stat_suspend THEN
				RETURN rtrim(substr(pstat, 3, 1)) IS NOT NULL;
			WHEN stat_investigation THEN
				RETURN rtrim(substr(pstat, 4, 1)) IS NOT NULL;
			ELSE
				error.raiseerror('Unknown contract status!');
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END checkstatus;

	FUNCTION getinitparametersrecord
	(
		pcontractno   IN tcontract.no%TYPE
	   ,pcontracttype IN tcontracttype.type%TYPE
	   ,pschemetype   IN tcontractschemas.type%TYPE
	) RETURN typeinitparameters IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetInitParametersRecord';
		vret typeinitparameters;
	BEGIN
		vret.contractno   := pcontractno;
		vret.contracttype := pcontracttype;
		vret.schemetype   := pschemetype;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION initoperlist
	(
		ptype       IN tcontract.type%TYPE
	   ,pcontractno IN tcontract.no%TYPE := NULL
	   ,pschemetype IN tcontractschemas.type%TYPE := NULL
	) RETURN NUMBER
	
	 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.InitOperList[2]';
		vinitparams    typeinitparameters;
		voperationlist typeschemaoperationsarray;
	BEGIN
		vinitparams    := getinitparametersrecord(pcontractno, ptype, pschemetype);
		voperationlist := initoperlist(vinitparams);
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END initoperlist;

	PROCEDURE setarcdate
	(
		pcontractno VARCHAR2
	   ,pdate       DATE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetArcDate';
		vhandle NUMBER;
		vnew    BOOLEAN;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
	
		vhandle := gethandle(pcontractno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontractno, 'R');
			vnew    := TRUE;
		END IF;
		setarcdatebyhandle(vhandle, pdate);
		writeobject(vhandle);
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
	EXCEPTION
		WHEN no_data_found THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.saveraise(cmethod_name
						   ,error.errorconst
						   ,'Contract "' || pcontractno || '" not found.');
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END setarcdate;

	PROCEDURE setarcdatebyhandle
	(
		phandle IN NUMBER
	   ,pdate   DATE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetArcDateByHandle';
	BEGIN
		IF scontractarray.exists(phandle)
		THEN
			scontractarray(phandle).contractrow.arcdate := pdate;
		ELSE
			error.saveraise(cmethod_name, error.errorconst, 'Handle ' || phandle || ' not found!');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setarcdatebyhandle;

	PROCEDURE updatecontractrecord(pcontract IN typecontractrowdata) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.UpdateContractRecord';
		vhandle NUMBER;
		vnew    BOOLEAN;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
	
		vhandle := gethandle(pcontract.no);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontract.no, 'R');
			vnew    := TRUE;
		END IF;
		scontractarray(vhandle).contractrow.idclient := pcontract.idclient;
		scontractarray(vhandle).contractrow.branchpart := pcontract.branchpart;
		scontractarray(vhandle).contractrow.commentary := pcontract.commentary;
		writeobject(vhandle);
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
	EXCEPTION
		WHEN no_data_found THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.saveraise(cmethod_name
						   ,error.errorconst
						   ,'Contract "' || pcontract.no || '" not found.');
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END updatecontractrecord;

	PROCEDURE setbranchpartbyhandle
	(
		phandle     IN NUMBER
	   ,pbranchpart NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetBranchPartByHandle';
	BEGIN
		IF scontractarray.exists(phandle)
		THEN
			s.say(cmethod_name || ': ' || pbranchpart, csay_level);
			IF nvl(scontractarray(phandle).contractrow.branchpart, 0) != pbranchpart
			THEN
				a4mlog.cleanparamlist;
				a4mlog.addparamrec(clogparam_branchpart
								  ,scontractarray(phandle).contractrow.branchpart
								  ,pbranchpart);
				IF a4mlog.logobject(object.gettype(contract.object_name)
								   ,scontractarray(phandle).contractrow.no
								   , 'Change contract branch from ' || scontractarray(phandle)
									.contractrow.branchpart || ' to ' || pbranchpart
								   ,a4mlog.act_change
								   ,a4mlog.putparamlist
								   ,powner => scontractarray(phandle).contractrow.idclient) != 0
				THEN
					error.raisewhenerr();
				END IF;
			END IF;
			scontractarray(phandle).contractrow.branchpart := pbranchpart;
		ELSE
			error.raiseerror('Handle ' || phandle || ' is not found!');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setbranchpartbyhandle;

	PROCEDURE setbranchpart
	(
		pcontractno IN tcontract.no%TYPE
	   ,pbranchpart NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetBranchPart';
		vhandle NUMBER;
		vnew    BOOLEAN;
	BEGIN
		s.say(cmethod_name || ': enter pBranchPart=' || pbranchpart, csay_level);
		vhandle := gethandle(pcontractno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontractno, 'R');
			vnew    := TRUE;
		END IF;
		setbranchpartbyhandle(vhandle, pbranchpart);
		writeobject(vhandle);
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END setbranchpart;

	PROCEDURE setcreatedatebyhandle
	(
		phandle     IN NUMBER
	   ,pcreatedate IN DATE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCreateDateByHandle';
	BEGIN
		IF scontractarray.exists(phandle)
		THEN
			a4mlog.cleanparamlist();
			a4mlog.addparamrec(clogparam_createdate
							  ,htools.d2s(scontractarray(phandle).contractrow.createdate)
							  ,htools.d2s(pcreatedate));
		
			IF a4mlog.logobject(object.gettype(object_name)
							   ,scontractarray(phandle).contractrow.no
							   ,'Change creation date: ' ||
								htools.d2s(scontractarray(phandle).contractrow.createdate) ||
								' -> ' || htools.d2s(pcreatedate)
							   ,a4mlog.act_change
							   ,a4mlog.putparamlist()
							   ,powner => scontractarray(phandle).contractrow.idclient) != 0
			THEN
				error.raisewhenerr();
			END IF;
			scontractarray(phandle).contractrow.createdate := pcreatedate;
		ELSE
			error.saveraise(cmethod_name
						   ,error.errorconst
						   ,'Handle ' || phandle || ' is not found!');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setcreatedatebyhandle;

	PROCEDURE setcreatedate
	(
		pcontrno    IN VARCHAR2
	   ,pcreatedate IN DATE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCreateDate';
		vhandle NUMBER;
		vnew    BOOLEAN;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
	
		vhandle := gethandle(pcontrno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontrno, 'R');
			vnew    := TRUE;
		END IF;
		setcreatedatebyhandle(vhandle, pcreatedate);
		writeobject(vhandle);
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END setcreatedate;

	PROCEDURE setcommentary
	(
		pcontrno IN VARCHAR2
	   ,pcomment CLOB
	   ,plog     IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCommentary[1]';
		vhandle NUMBER;
		vnew    BOOLEAN;
	BEGIN
		s.say(cmethod_name || ': enter', csay_level);
		vhandle := gethandle(pcontrno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontrno, 'R');
			vnew    := TRUE;
		END IF;
		setcommentarybyhandle(vhandle, pcomment, plog);
		writeobject(vhandle);
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END setcommentary;

	PROCEDURE setcommentary
	(
		pcontrno IN VARCHAR2
	   ,pcomment VARCHAR2
	   ,plog     IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCommentary[2]';
		vcomment CLOB;
	BEGIN
		s.say(cmethod_name || ': enter', csay_level);
		vcomment := pcomment;
		setcommentary(pcontrno, vcomment, plog);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setcommentary;

	FUNCTION setidclientbyhandle
	(
		phandle   IN NUMBER
	   ,pidclient IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetIdClientByHandle';
	BEGIN
		IF scontractarray.exists(phandle)
		THEN
		
			a4mlog.cleanparamlist();
			a4mlog.addparamrec(clogparam_idclient
							  ,to_char(scontractarray(phandle).contractrow.idclient)
							  ,to_char(pidclient));
			IF a4mlog.logobject(object.gettype(object_name)
							   ,scontractarray(phandle).contractrow.no
							   ,'Change customer: ' ||
								to_char(scontractarray(phandle).contractrow.idclient) || ' -> ' ||
								to_char(pidclient)
							   ,a4mlog.act_change
							   ,a4mlog.putparamlist()
							   ,powner => scontractarray(phandle).contractrow.idclient) != 0
			THEN
				RETURN err.geterrorcode();
			END IF;
		
			IF a4mlog.logobject(object.gettype(object_name)
							   ,scontractarray(phandle).contractrow.no
							   ,'Change customer: ' ||
								to_char(scontractarray(phandle).contractrow.idclient) || ' -> ' ||
								to_char(pidclient)
							   ,a4mlog.act_change
							   ,a4mlog.putparamlist()
							   ,powner => pidclient) != 0
			THEN
				RETURN err.geterrorcode();
			END IF;
			a4mlog.cleanparamlist();
		
			scontractarray(phandle).contractrow.idclient := pidclient;
		ELSE
			error.saveraise(cmethod_name, error.errorconst, 'Handle ' || phandle || ' not found!');
		END IF;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setidclientbyhandle;

	FUNCTION setidclient
	(
		pcontrno       IN tcontract.no%TYPE
	   ,pidclient      IN NUMBER
	   ,poperationmode IN typeoperationmode := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetIdClient';
		vhandle      NUMBER;
		vnew         BOOLEAN;
		vblockparams typecontractblockparams;
	BEGIN
		s.say(cmethod_name || ': enter pIdClient=' || pidclient || ', pOperationMode=' ||
			  poperationmode
			 ,csay_level);
	
		vhandle := gethandle(pcontrno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontrno, 'R');
			vnew    := TRUE;
		END IF;
		s.say(cmethod_name || ': OldIdClient=' ||
			  to_char(scontractarray(vhandle).contractrow.idclient)
			 ,csay_level);
		IF contracttype.getaccessory(scontractarray(vhandle).contractrow.type) =
		   contracttype.cclient
		   AND client.getclienttype(pidclient) = client.ct_company
		THEN
			error.raiseerror('Private contract cannot belong to corporate customer');
		ELSIF contracttype.getaccessory(scontractarray(vhandle).contractrow.type) =
			  contracttype.ccorporate
			  AND client.getclienttype(pidclient) = client.ct_persone
		THEN
			error.raiseerror('Corporate contract cannot belong to private customer');
		END IF;
		IF setidclientbyhandle(vhandle, pidclient) != 0
		THEN
			error.raisewhenerr();
		END IF;
	
		vblockparams.operationtype := action_clientchange;
		vblockparams.operationmode := poperationmode;
		vblockparams.contracttype  := scontractarray(vhandle).contractrow.type;
		writeobject(vhandle, vblockparams);
	
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END setidclient;

	FUNCTION setstatusbyhandle
	(
		phandle IN NUMBER
	   ,pflag   IN NUMBER
	   ,pon     IN BOOLEAN
	   ,plog    IN BOOLEAN := TRUE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetStatusByHandle';
		vclerkcode NUMBER;
		voperdate  DATE;
		vflag      VARCHAR2(1);
		voldstatus VARCHAR2(10);
		vstatus    VARCHAR2(10);
	BEGIN
		IF pflag NOT IN (stat_close, stat_violate, stat_suspend, stat_investigation)
		THEN
			err.seterror(err.contract_invalid_status, cmethod_name);
			RETURN err.geterrorcode;
		END IF;
	
		IF pflag = stat_close
		THEN
			IF pon
			THEN
				vclerkcode := clerk.getcode;
				voperdate  := seance.getoperdate;
			ELSE
				vclerkcode := NULL;
				voperdate  := NULL;
			END IF;
		END IF;
	
		vflag := service.iif(pon, '1', ' ');
		IF scontractarray.exists(phandle)
		THEN
			voldstatus := scontractarray(phandle).contractrow.status;
			vstatus    := service.rightpad(nvl(substr(voldstatus, 1, pflag - 1), ' '), pflag - 1) ||
						  vflag || substr(voldstatus, pflag + 1);
		
			scontractarray(phandle).contractrow.status := vstatus;
			IF pflag = stat_close
			THEN
				scontractarray(phandle).contractrow.closedate := voperdate;
				scontractarray(phandle).contractrow.closeclerk := vclerkcode;
			END IF;
			IF plog
			THEN
				a4mlog.cleanparamlist;
				a4mlog.addparamrec(clogparam_status
								  ,getstatusname(voldstatus)
								  ,getstatusname(vstatus));
				IF a4mlog.logobject(object.gettype(object_name)
								   ,scontractarray(phandle).contractrow.no
								   ,'Changed status: "' || getstatusname(voldstatus) || '" -> "' ||
									getstatusname(vstatus) || '"'
								   ,a4mlog.act_change
								   ,a4mlog.putparamlist
								   ,powner => scontractarray(phandle).contractrow.idclient) != 0
				THEN
					RETURN err.geterrorcode();
				END IF;
			END IF;
		ELSE
			error.saveraise(cmethod_name, error.errorconst, 'Handle ' || phandle || ' not found!');
		END IF;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setstatusbyhandle;

	FUNCTION setstatus
	(
		pno   IN VARCHAR2
	   ,pflag IN NUMBER
	   ,pon   IN BOOLEAN
	   ,plog  IN BOOLEAN := TRUE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetStatus[3]';
		vhandle NUMBER;
		vnew    BOOLEAN;
		vret    NUMBER;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
	
		vhandle := gethandle(pno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pno, 'R');
			vnew    := TRUE;
		END IF;
	
		vret := setstatusbyhandle(vhandle, pflag, pon, plog);
		writeobject(vhandle);
	
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END setstatus;

	PROCEDURE setstatus
	(
		pno           IN VARCHAR2
	   ,pflag         IN NUMBER
	   ,pon           IN BOOLEAN
	   ,precnoforundo IN OUT NUMBER
	   ,pundo         BOOLEAN := FALSE
	   ,plog          IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetStatus[5]';
		voldstatus VARCHAR2(10);
		vnewstatus VARCHAR2(10);
	
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
	
		voldstatus := getstatus(pno);
		IF setstatus(pno, pflag, pon, plog) != 0
		THEN
			error.raisewhenerr();
		ELSE
			vnewstatus := getstatus(pno);
			IF NOT pundo
			THEN
				precnoforundo := logchangestatus(pno, voldstatus, vnewstatus);
			ELSIF precnoforundo IS NOT NULL
			THEN
				undologstatus(precnoforundo);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setstatus;

	FUNCTION logchangestatus
	(
		pno        IN VARCHAR2
	   ,poldstatus IN VARCHAR2
	   ,pnewstatus IN VARCHAR2
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.LogChangeStatus';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vcontstathistrow tcontractstatushistory%ROWTYPE;
	BEGIN
		IF (poldstatus != pnewstatus)
		THEN
			IF NOT contractexists(pno)
			THEN
				error.raiseerror('Contract "' || pno || '" not found!');
			END IF;
		
			vcontstathistrow.recno := scontractstatushistory.nextval();
		
			vcontstathistrow.branch     := cbranch;
			vcontstathistrow.contractno := pno;
			vcontstathistrow.operdate   := seance.getoperdate;
			vcontstathistrow.updsysdate := SYSDATE;
			vcontstathistrow.clerkcode  := clerk.getcode;
			vcontstathistrow.oldstatus  := poldstatus;
			vcontstathistrow.newstatus  := pnewstatus;
		
			INSERT INTO tcontractstatushistory
			VALUES
				(vcontstathistrow.branch
				,vcontstathistrow.recno
				,vcontstathistrow.contractno
				,vcontstathistrow.operdate
				,vcontstathistrow.updsysdate
				,vcontstathistrow.clerkcode
				,vcontstathistrow.oldstatus
				,vcontstathistrow.newstatus);
		
			RETURN vcontstathistrow.recno;
		END IF;
		RETURN NULL;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END logchangestatus;

	PROCEDURE undologstatus(precno NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.UndoLogStatus';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vcount  NUMBER := 0;
		vcontno VARCHAR2(20);
		vopdate DATE;
	BEGIN
		SELECT contractno
			  ,operdate
		INTO   vcontno
			  ,vopdate
		FROM   tcontractstatushistory
		WHERE  branch = cbranch
		AND    recno = precno;
	
		SELECT COUNT(branch)
		INTO   vcount
		FROM   tcontractstatushistory
		WHERE  branch = cbranch
		AND    contractno = vcontno
		AND    recno > precno;
	
		IF vcount > 0
		THEN
			error.raiseerror('Impossible to cancel changing status of contract "' || vcontno ||
							 '" for ' || htools.d2s(vopdate) ||
							 ', since after this date other status changes were performed');
		END IF;
	
		DELETE FROM tcontractstatushistory
		WHERE  branch = cbranch
		AND    recno = precno;
	EXCEPTION
		WHEN no_data_found THEN
			NULL;
		WHEN OTHERS THEN
			error.save(cpackage_name || cmethod_name);
			s.say(cmethod_name || ': general exception, ' || SQLERRM, csay_level);
			RAISE;
	END undologstatus;

	PROCEDURE makestatuscheckbox
	(
		pdialog  IN NUMBER
	   ,pitem    IN VARCHAR2
	   ,px       IN NUMBER
	   ,py       IN NUMBER
	   ,pwidth   NUMBER
	   ,pheigth  NUMBER
	   ,pcaption IN VARCHAR2 := NULL
	   ,phint    IN VARCHAR2 := NULL
	   ,penable  BOOLEAN := FALSE
	) IS
	BEGIN
		dialog.checkbox(pdialog, pitem, px, py, pwidth, pheigth, phint, pcaption);
		dialog.setitemattributies(pdialog
								 ,pitem
								 ,service.iif(penable, dialog.selecton, dialog.selectoff));
		FOR i IN 0 .. sastatusname.count - 1
		LOOP
			dialog.listaddrecord(pdialog, pitem, sastatusname(i), 0, 0);
		END LOOP;
	END makestatuscheckbox;

	PROCEDURE setstatuscheckbox
	(
		pdialog IN NUMBER
	   ,pitem   IN VARCHAR2
	   ,pstatus VARCHAR2
	) IS
		vstr VARCHAR2(10);
	BEGIN
		IF checkstatus(pstatus, stat_ok)
		THEN
			vstr := '1';
		ELSE
			vstr := ' ' || pstatus;
		END IF;
		dialog.putchar(pdialog, pitem, vstr);
	END setstatuscheckbox;

	FUNCTION checkmarkedstatus
	(
		pdialog IN NUMBER
	   ,pitem   IN VARCHAR2
	   ,pstatus NUMBER
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CheckMarkedStatus[3]';
		vstr VARCHAR2(11);
	BEGIN
		vstr := dialog.getchar(pdialog, pitem);
		RETURN checkmarkedstatus(vstr, pstatus);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END checkmarkedstatus;

	FUNCTION checkmarkedstatus
	(
		pstatusstr VARCHAR2
	   ,pstatus    NUMBER
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CheckMarkedStatus[2]';
	BEGIN
		RETURN substr(rpad(nvl(pstatusstr, ' '), 10), pstatus + 1, 1) = '1';
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END checkmarkedstatus;

	PROCEDURE changecreatedate
	(
		pcontractno     IN tcontract.no%TYPE
	   ,polddate        IN tcontract.createdate%TYPE
	   ,pcontractparams IN contract.typecontractparams
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.ChangeCreateDate';
	BEGIN
		contracttools.changecreatedate(pcontractno
									  ,pcontractparams.createdate
									  ,pcontractparams.changeacccreatedate);
		contractrb.setlabel(crl_change_createdate);
		contractrb.setdvalue(ckey_createdate, polddate);
		contractrb.setnvalue(ckey_change_accdate
							,service.iif(pcontractparams.changeacccreatedate, 1, 0));
		contractrb.setcvalue(ckey_contract_no, pcontractno);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE changeidclient
	(
		pcontractno        IN tcontract.no%TYPE
	   ,poldidclient       IN NUMBER
	   ,pnewidclient       IN NUMBER
	   ,pchangecardsclient IN BOOLEAN
	   ,
		
		poperationmode IN typeoperationmode
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.ChangeIdClient';
	BEGIN
		t.enter(cmethod_name, 'pOperationMode=' || poperationmode);
		changecontractidclient(pcontractno, pnewidclient, pchangecardsclient, poperationmode);
		contractrb.setlabel(crl_change_idclient);
		contractrb.setnvalue(ckey_idclient, poldidclient);
		contractrb.setnvalue(ckey_change_cardsclient, service.iif(pchangecardsclient, 1, 0));
		contractrb.setcvalue(ckey_contract_no, pcontractno);
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
		
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setlabel_changecontracttype
	(
		pcontractno     IN tcontract.no%TYPE
	   ,poldtype        IN tcontract.type%TYPE
	   ,pcontractparams IN typecontractparams
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.SetLabel_ChangeContractType';
	BEGIN
		contractrb.setlabel(crl_change_contract_type);
		contractrb.setnvalue(ckey_contract_type, poldtype);
		contractrb.setnvalue(ckey_change_acctype
							,service.iif(pcontractparams.changeaccounttype, 1, 0));
		contractrb.setnvalue(ckey_checkident_acctype
							,service.iif(pcontractparams.checkidentacctype, 1, 0));
		contractrb.setnvalue(ckey_checkident_acctier
							,service.iif(pcontractparams.checkidenttieracc, 1, 0));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcontracttypeaccitems(pcontracttype IN tcontracttype.type%TYPE)
		RETURN typecontracttypeitems IS
		cmethod_name CONSTANT VARCHAR2(64) := cpackage_name || '.GetContractTypeItems';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		TYPE typectitems IS TABLE OF tcontracttypeitemname%ROWTYPE INDEX BY BINARY_INTEGER;
		vactitemstemp typectitems;
		vactitems     typecontracttypeitems;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		SELECT * BULK COLLECT
		INTO   vactitemstemp
		FROM   tcontracttypeitemname
		WHERE  branch = cbranch
		AND    contracttype = pcontracttype;
	
		FOR i IN 1 .. vactitemstemp.count
		LOOP
			vactitems(vactitemstemp(i).itemname) := vactitemstemp(i);
		END LOOP;
		s.say(cmethod_name || ': total ' || vactitems.count, csay_level);
		RETURN vactitems;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcontracttypeaccitems;

	FUNCTION isidenticalschema
	(
		pcontracttype1 IN tcontracttype.type%TYPE
	   ,pcontracttype2 IN tcontracttype.type%TYPE
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(64) := cpackage_name || '.IsIdenticalSchema';
		vctrow1 tcontracttype%ROWTYPE;
		vctrow2 tcontracttype%ROWTYPE;
		vret    BOOLEAN := TRUE;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		vctrow1 := contracttype.getrecord(pcontracttype1);
		s.say(cmethod_name || ': schema 1 - ' || vctrow1.schematype, csay_level);
		vctrow2 := contracttype.getrecord(pcontracttype2);
		s.say(cmethod_name || ': schema 2 - ' || vctrow2.schematype, csay_level);
		IF vctrow1.schematype != vctrow2.schematype
		   OR vctrow1.schematype IS NULL
		   OR vctrow2.schematype IS NULL
		THEN
			vret := FALSE;
		END IF;
		s.say(cmethod_name || ': ' || htools.bool2str(vret), csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END isidenticalschema;

	PROCEDURE updateaccountitem
	(
		paccountitem IN typecontractitemrecord
	   ,pnewitemcode IN tcontractitem.itemcode%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(64) := cpackage_name || '.UpdateAccountItem';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		s.say(cmethod_name || ': enter ' || cmethod_name, csay_level);
		UPDATE tcontractitem t
		SET    t.itemcode = pnewitemcode
		WHERE  t.branch = vbranch
		AND    t.key = paccountitem.accountno;
		s.say(cmethod_name || ': done', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE updatecarditem
	(
		pcarditem    IN typecontractitemrecord
	   ,pnewitemcode IN tcontractitem.itemcode%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(64) := cpackage_name || '.UpdateCardItem';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		s.say(cmethod_name || ': enter ' || cmethod_name, csay_level);
		UPDATE tcontractcarditem t
		SET    t.itemcode = pnewitemcode
		WHERE  t.branch = vbranch
		AND    t.pan = pcarditem.pan
		AND    t.mbr = pcarditem.mbr;
		s.say(cmethod_name || ': done', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE changecontracttype4accounts
	(
		pcontractno      IN tcontract.no%TYPE
	   ,poldcontracttype IN tcontracttype.type%TYPE
	   ,pnewcontracttype IN tcontracttype.type%TYPE
	   ,pparams          IN typecontractparams
	   ,pwriterbdata     IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(64) := cpackage_name || '.ChangeContractType4Accounts';
		vindex       NUMBER;
		vnewitemcode NUMBER;
		vrow         tcontracttypeitemname%ROWTYPE;
	
		vaccounts    typecontractitemlist;
		vanewctitems typecontracttypeitems;
		voldacctype  NUMBER;
		vnewacctype  NUMBER;
		voldcurr     NUMBER;
		vnewcurr     NUMBER;
		vacchandle   NUMBER := 0;
		voldaccplan  NUMBER;
		vnewaccplan  NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pOldContractType=' || poldcontracttype ||
				', pNewContractType=' || pnewcontracttype || ', pParams.CheckIdentAccType=' ||
				t.b2t(pparams.checkidentacctype) || ', pParams.CheckIdentTierAcc=' ||
				t.b2t(pparams.checkidenttieracc) || ', pParams.ChangeAccountType=' ||
				t.b2t(pparams.changeaccounttype) || ', pWriteRBData=' || t.b2t(pwriterbdata)
			   ,csay_level);
		vanewctitems := getcontracttypeaccitems(pnewcontracttype);
		s.say(cmethod_name || ': new account''s count ' || vanewctitems.count, csay_level);
		vaccounts := getaccountitemlist(pcontractno);
		s.say(cmethod_name || ': accounts count ' || vaccounts.count, csay_level);
	
		vindex := vaccounts.first();
		WHILE vindex IS NOT NULL
		LOOP
			vrow := contracttypeitems.getcitnamerecord(vaccounts(vindex).itemcode);
			s.say(cmethod_name || ': item name ' || vrow.itemname, csay_level);
			vnewitemcode := vanewctitems(vrow.itemname).itemcode;
			s.say(cmethod_name || ': old item code ' || vaccounts(vindex).itemcode, csay_level);
			s.say(cmethod_name || ': new item code ' || vnewitemcode, csay_level);
			IF vnewitemcode IS NULL
			   OR vnewitemcode = vaccounts(vindex).itemcode
			THEN
				error.raiseerror('New account code not defined for element with code ' || vaccounts(vindex)
								 .itemcode);
			END IF;
		
			IF vanewctitems(vrow.itemname).refaccounttype = contractaccount.refaccounttype_single
			THEN
				vnewacctype := contractaccount.getaccounttype(vnewitemcode);
			ELSE
				vnewacctype := contracttypeschema.getaccounttypeforchange(pcontractno
																		 ,poldcontracttype
																		 ,pnewcontracttype
																		 ,vrow.itemname);
			END IF;
			IF vnewacctype IS NULL
			THEN
				error.raiseerror('Not defined account type <' || vrow.itemname || '> ' ||
								 contractaccount.getdescriptionbyitemcode(vnewitemcode) ||
								 ' for contract type ' || pnewcontracttype);
			END IF;
			vacchandle := account.newobject(vaccounts(vindex).accountno, 'W');
			IF vacchandle != 0
			THEN
				voldacctype := account.getaccounttype(vacchandle);
				IF vnewacctype != voldacctype
				THEN
					IF pparams.checkidentacctype
					THEN
						error.raiseerror('Type <' || vnewacctype || ' ' ||
										 accounttype.getname(vnewacctype) || '> of account <' ||
										 vrow.itemname || ' ' ||
										 contractaccount.getdescriptionbyitemcode(vnewitemcode) ||
										 '> ~ differs from type <' || voldacctype || ' ' ||
										 accounttype.getname(voldacctype) || '> of account~ ' || vaccounts(vindex)
										 .accountno);
					ELSE
						voldaccplan := contractaccount.getnoplan(voldacctype);
						s.say(cmethod_name || ': old Plan No =' || voldaccplan, csay_level);
						vnewaccplan := contractaccount.getnoplan(vnewacctype);
						s.say(cmethod_name || ': new Plan No =' || vnewaccplan, csay_level);
						IF pparams.checkidenttieracc
						   AND voldaccplan != vnewaccplan
						THEN
							error.raiseerror('AcctChart of account <' || vrow.itemname || ' ' ||
											 contractaccount.getdescriptionbyitemcode(vnewitemcode) ||
											 '> ~ differs from AcctChart of account ' || vaccounts(vindex)
											 .accountno);
						ELSE
						
							voldcurr := planaccount.getcurrency(voldaccplan);
							s.say(cmethod_name || ': old currency ' || voldcurr, csay_level);
							vnewcurr := planaccount.getcurrency(vnewaccplan);
							s.say(cmethod_name || ': new currency ' || vnewcurr, csay_level);
							IF voldcurr != vnewcurr
							THEN
								error.raiseerror('Currency <' || vnewcurr || ' - ' ||
												 referencecurrency.getname(vnewcurr) ||
												 '> of account <' || vrow.itemname || ' ' ||
												 contractaccount.getdescriptionbyitemcode(vnewitemcode) ||
												 '> in contract type ' || pnewcontracttype ||
												 '~ differs from currency <' || voldcurr || ' - ' ||
												 referencecurrency.getname(voldcurr) ||
												 '> of account ' || vaccounts(vindex).accountno);
							ELSIF pparams.changeaccounttype
							THEN
								account.setaccounttype(vacchandle, vnewacctype);
								account.writeobject(vacchandle);
							END IF;
						END IF;
					END IF;
				END IF;
				account.freeobject(vacchandle);
				vacchandle := 0;
				updateaccountitem(vaccounts(vindex), vnewitemcode);
			ELSE
				error.raiseerror('Account ' || vaccounts(vindex).accountno ||
								 ' is blocked for write access!');
			END IF;
			vindex := vaccounts.next(vindex);
		END LOOP;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			IF vacchandle != 0
			THEN
				account.freeobject(vacchandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END changecontracttype4accounts;

	PROCEDURE setlabel_changefinprofile
	(
		pcontractno    IN tcontract.no%TYPE
	   ,poldfinprofile IN tcontract.finprofile%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.SetLabel_ChangeFinProfile';
	BEGIN
		contractrb.setlabel(crl_change_finprofile);
		contractrb.setcvalue(ckey_contract_no, pcontractno);
		contractrb.setnvalue(ckey_change_finprofile, poldfinprofile);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE changecontracttype4cards
	(
		pcontractno      IN tcontract.no%TYPE
	   ,poldcontracttype IN tcontracttype.type%TYPE
	   ,pnewcontracttype IN tcontracttype.type%TYPE
	   ,pchangecardstate IN BOOLEAN
	   ,pwriterbdata     IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(64) := cpackage_name || '.ChangeContractType4Cards';
		vindex       NUMBER;
		vnewitemcode NUMBER;
		vcount       NUMBER;
		j            NUMBER;
	
		vcards       typecontractitemlist;
		vcard        apitypes.typecardrecord;
		vcardhandle  NUMBER;
		voldsignstat tcard.signstat%TYPE;
	
		vaacc2cardlist apitypes.typeaccount2cardlist;
	
		vaccountitem tcontracttypeitemname%ROWTYPE;
		vcontract    typecontractitemrecord;
	
		vaacc2carditemlist contractcard.typeacc2cardlist;
	
		vaccountno taccount.accountno%TYPE;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pOldContractType=' || poldcontracttype ||
				', pNewContractType=' || pnewcontracttype || ', pChangeCardState=' ||
				t.b2t(pchangecardstate) || ', pWriteRBData=' || t.b2t(pwriterbdata)
			   ,csay_level);
		vcards := getcarditemlist(pcontractno);
		IF vcards.count > 0
		THEN
			IF pchangecardstate
			   AND nvl(pwriterbdata, TRUE)
			THEN
				contractrb.setlabel(crl_change_card_state);
				contractrb.setcvalue(ckey_contract_no, pcontractno);
			END IF;
			vindex := vcards.first();
			vcount := contractcard.initarray(pnewcontracttype);
			t.var('vCount', vcount, csay_level);
			WHILE vindex IS NOT NULL
			LOOP
				t.var('vCards(' || vindex || ').ContractItem.ItemCode'
					 ,vcards(vindex).itemcode
					 ,csay_level);
				err.seterror(0, cmethod_name);
				vcard := card.getcardrecord(vcards(vindex).pan, vcards(vindex).mbr);
				error.raisewhenerr();
				t.var('old card product: vCard.Cardproduct', vcard.cardproduct, csay_level);
				t.var('vCard.Pan', card.getmaskedpan(vcard.pan));
				t.var('vCard.Mbr', vcard.mbr);
				vnewitemcode := NULL;
				j            := 1;
				WHILE j <= vcount
				LOOP
					IF contractcard.getarraycardproduct(j) = vcard.cardproduct
					THEN
						vnewitemcode := contractcard.getarrayitemcode(j);
						j            := j + 1;
						EXIT;
					END IF;
					j := j + 1;
				END LOOP;
				IF vnewitemcode IS NULL
				THEN
					error.raiseerror('Contract type <' || pnewcontracttype ||
									 '> contains no required card product: ' ||
									 referencecardproduct.getname(vcard.cardproduct));
				ELSE
					FOR k IN j .. vcount
					LOOP
						IF contractcard.getarraycardproduct(k) = vcard.cardproduct
						THEN
							BEGIN
								IF contractcard.getcardtype(vcard.pan, vcard.mbr) =
								   contractcard.getarraycreatetype(k)
								THEN
									vnewitemcode := contractcard.getarrayitemcode(k);
									EXIT;
								END IF;
							EXCEPTION
								WHEN OTHERS THEN
									t.note(cmethod_name
										  ,'Card not exist in ContractType, errm=' || SQLERRM
										  ,csay_level);
							END;
						END IF;
					END LOOP;
				END IF;
				t.var('new item code, vNewItemCode', vnewitemcode, csay_level);
				IF vnewitemcode IS NULL
				   OR vnewitemcode = vcards(vindex).itemcode
				THEN
					error.raiseerror('New card code not defined for element with code ' || vcards(vindex)
									 .itemcode);
				END IF;
			
				vaacc2carditemlist := contractcard.getacc2cardlist_byitemcode(vnewitemcode);
				t.var('vaAcc2CardItemList.Count', vaacc2carditemlist.count);
				FOR iindex IN 1 .. vaacc2carditemlist.count
				LOOP
					vaccountitem := contracttypeitems.getcitnamerecord(vaacc2carditemlist(iindex)
																	   .acccode);
					t.var('vAccountItem.ItemName', vaccountitem.itemname);
					err.seterror(0, cmethod_name);
					vaccountno := getaccountnobyitemname(pcontractno, vaccountitem.itemname);
					t.var('vAccountNo', vaccountno);
					err.seterror(0, cmethod_name);
					IF vaccountno IS NOT NULL
					THEN
					
						card.createlinkaccount(vcard.pan
											  ,vcard.mbr
											  ,vaccountno
											  ,vaacc2carditemlist(iindex).accstatus
											  ,
											   
											   pcheckprimaryaccount => FALSE
											  ,plog                 => FALSE);
						error.raisewhenerr();
					END IF;
				END LOOP;
			
				vaacc2cardlist := card.getaccountlist(vcard.pan, vcard.mbr);
				t.var('vaAcc2CardList.Count', vaacc2cardlist.count);
				FOR iindex IN 1 .. vaacc2cardlist.count
				LOOP
					t.var('vaAcc2CardList(' || iindex || ').AccountNo'
						 ,vaacc2cardlist(iindex).accountno);
					vcontract := getcontractbyaccount(vaacc2cardlist(iindex).accountno, FALSE);
					t.var('vContract.ContractNo', vcontract.contractno);
					IF vcontract.contractno IS NOT NULL
					   AND vcontract.contractno = pcontractno
					THEN
					
						t.var('vContract.Itemcode', vcontract.itemcode);
					
						t.var('vContract.ItemName', vcontract.itemname);
					
						vaacc2carditemlist := contractcard.getacc2cardlist_byitemname(pnewcontracttype
																					 ,vcontract.itemname
																					 ,vnewitemcode);
						t.var('vaAcc2CardItemList.Count', vaacc2carditemlist.count);
						IF vaacc2carditemlist.count <= 0
						THEN
							card.deletelinkaccount(vcard.pan
												  ,vcard.mbr
												  ,vaacc2cardlist(iindex).accountno
												  ,FALSE
												  ,plog           => FALSE);
							error.raisewhenerr();
						END IF;
					END IF;
				END LOOP;
			
				IF pchangecardstate
				THEN
					vcard.a4mstat := contractcard.getsignstat(pnewcontracttype, vnewitemcode);
					t.var('vCard.A4MStat', vcard.a4mstat, csay_level);
					IF vcard.a4mstat IS NOT NULL
					THEN
						vcardhandle := card.newobject(vcard.pan, vcard.mbr, 'W');
						IF vcardhandle != 0
						THEN
							voldsignstat := card.cardsignstat(vcardhandle);
							t.var('vOldSignStat', voldsignstat, csay_level);
							card.setsignstat(vcardhandle
											,vcard.a4mstat
											,TRUE
											,'Change contract type');
							IF card.cardsignstat(vcardhandle) != voldsignstat
							THEN
								card.writeobject(vcardhandle);
							
								IF nvl(pwriterbdata, TRUE)
								THEN
									contractrb.setnextcvalue(ckey_card_state
															,vcard.pan || '<P>' ||
															 to_char(vcard.mbr) || '<M>' ||
															 to_char(voldsignstat) || '<S>');
								END IF;
							
							END IF;
							card.freeobject(vcardhandle);
						ELSE
							error.raisewhenerr();
						END IF;
					END IF;
				END IF;
				updatecarditem(vcards(vindex), vnewitemcode);
			
				vindex := vcards.next(vindex);
			END LOOP;
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			IF vcardhandle != 0
			THEN
				card.freeobject(vcardhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END changecontracttype4cards;

	PROCEDURE changecontracttype
	(
		pcontract    IN tcontract%ROWTYPE
	   ,pcontractrow IN typecontractparams
	   ,pundo        IN BOOLEAN
	   ,pwriterbdata IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(64) := cpackage_name || '.ChangeContractType[2]';
		vlog               NUMBER;
		vhandle            NUMBER;
		vnew               BOOLEAN;
		voldtypefinprofile NUMBER;
		vnewtypefinprofile NUMBER;
		vhistid            NUMBER := NULL;
		vctparams          contracttypeschema.typechangecontracttypeparams;
		vblockparams       typecontractblockparams;
	BEGIN
		t.enter(cmethod_name
			   ,'from [' || pcontract.type || '] to [' || pcontractrow.type || ']' ||
				', pWriteRbData=' || t.b2t(pwriterbdata)
			   ,csay_level);
		IF NOT security.checkright(object_name, getrightkey(right_open, pcontractrow.type))
		THEN
			error.raiseerror('You are not authorized to create contracts of this type');
		ELSIF pcontractrow.type IS NULL
		THEN
			error.raiseerror('New contract type not selected');
		ELSIF pcontract.type = pcontractrow.type
		THEN
			error.raiseerror('Old and new contract types identical');
		ELSE
			IF NOT isidenticalschema(pcontract.type, pcontractrow.type)
			THEN
				error.raiseerror('Financial schemes of contract types not identical');
			END IF;
		
			vhandle := gethandle(pcontract.no);
			IF vhandle IS NULL
			THEN
				vhandle := newobject(pcontract.no, 'W');
				vnew    := TRUE;
			END IF;
		
			IF vhandle != 0
			THEN
				SAVEPOINT changect;
			
				IF NOT pundo
				THEN
				
					vctparams.newtype     := pcontractrow.type;
					vctparams.writerbdata := pwriterbdata;
				
					contracttypeschema.changecontracttype(pcontract.no, vctparams);
				
					IF pcontractrow.changefinprofile
					THEN
						voldtypefinprofile := contracttype.getfinprofile(pcontract.type);
						vnewtypefinprofile := contracttype.getfinprofile(pcontractrow.type);
						IF nvl(scontractarray(vhandle).contractrow.finprofile, -1) =
						   nvl(voldtypefinprofile, -1)
						   AND nvl(vnewtypefinprofile, -1) != nvl(voldtypefinprofile, -1)
						THEN
							IF nvl(pwriterbdata, TRUE)
							THEN
								setlabel_changefinprofile(pcontract.no
														 ,scontractarray(vhandle)
														  .contractrow.finprofile);
							END IF;
							setfinprofilebyhandle(vhandle, vnewtypefinprofile);
						END IF;
					END IF;
				END IF;
				changecontracttype4cards(pcontract.no
										,pcontract.type
										,pcontractrow.type
										,pcontractrow.changecardstate
										,pwriterbdata);
				changecontracttype4accounts(pcontract.no
										   ,pcontract.type
										   ,pcontractrow.type
										   ,pcontractrow
										   ,pwriterbdata);
			
				IF NOT pundo
				THEN
					vctparams.newtype     := pcontractrow.type;
					vctparams.writerbdata := pwriterbdata;
				
					contracttypeschema.changecontracttype_post(pcontract.no, vctparams);
				END IF;
			
				scontractarray(vhandle).contractrow.type := pcontractrow.type;
			
				vblockparams.contracttype  := pcontractrow.type;
				vblockparams.operationtype := action_contracttypechange;
				vblockparams.operationmode := pcontractrow.operationmode;
			
				writeobject(vhandle, vblockparams);
			
				contractparams.writehistory(pcontract.no
										   ,vhistid
										   ,cattrtype
										   ,NULL
										   ,pcontract.type
										   ,'contract type changed');
			
				a4mlog.cleanparamlist;
				a4mlog.addparamrec(clogparam_contracttype, pcontract.type, pcontractrow.type);
				vlog := a4mlog.logobject(object.gettype(contract.object_name)
										,pcontract.no
										,'Contract type changed: ' || pcontract.type || '->' ||
										 pcontractrow.type
										,a4mlog.act_change
										,a4mlog.putparamlist
										,powner => getclientid(pcontract.no));
				s.say(cmethod_name || ': done', csay_level);
				IF vnew
				THEN
					freeobject(vhandle);
				END IF;
			ELSE
				error.raiseerror('Contract is blocked ' || pcontract.no);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			IF vhandle != 0
			THEN
				ROLLBACK TO changect;
			END IF;
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END changecontracttype;

	PROCEDURE changecontracttypebyhandle
	(
		phandle         IN NUMBER
	   ,pcontractparams IN typecontractparams
	   ,pundo           IN BOOLEAN
	   ,pwriterbdata    IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeContractTypeByHandle';
	BEGIN
		t.enter(cmethod_name
			   ,'pHandle=' || phandle || ', pWriteRbData=' || t.b2t(pwriterbdata)
			   ,csay_level);
		IF scontractarray.exists(phandle)
		THEN
			changecontracttype(scontractarray(phandle).contractrow
							  ,pcontractparams
							  ,pundo
							  ,pwriterbdata);
		ELSE
			error.saveraise(cmethod_name, error.errorconst, 'Handle ' || phandle || ' not found!');
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
		
			error.save(cmethod_name);
			RAISE;
	END changecontracttypebyhandle;

	PROCEDURE changecontracttype
	(
		pcontractno     IN tcontract.no%TYPE
	   ,pcontractparams IN typecontractparams
	   ,pundo           IN BOOLEAN
	   ,pwriterbdata    IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.ChangeContractType[1]';
		vhandle         NUMBER;
		vnew            BOOLEAN;
		vcontractparams typecontractparams := pcontractparams;
		vchangeacctype  BOOLEAN;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pNewType=' || vcontractparams.type ||
				', pUndo=' || htools.bool2str(pundo) || ', pWriteRBData=' || t.b2t(pwriterbdata)
			   ,csay_level);
		vhandle := gethandle(pcontractno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontractno, 'R');
			vnew    := TRUE;
		END IF;
		t.var('vNew', htools.bool2str(vnew));
	
		IF NOT pundo
		THEN
			vcontractparams.changecardstate := nvl(pcontractparams.changecardstate, TRUE);
			vchangeacctype                  := nvl(contractparams.loadchar(contractparams.getobjecttype(contracttype.ccontracttypebranch)
																		  ,0
																		  ,'CHANGEACCTYPE'
																		  ,FALSE) = '1'
												  ,FALSE);
			s.say(cmethod_name || ': vChangeAccType is ' || htools.bool2str(vchangeacctype)
				 ,csay_level);
			s.say(cmethod_name || ': pContractParams.ChangeAccountType is ' ||
				  htools.bool2str(pcontractparams.changeaccounttype)
				 ,csay_level);
			vcontractparams.changeaccounttype := (vchangeacctype AND
												 nvl(pcontractparams.changeaccounttype, FALSE));
			s.say(cmethod_name || ': vContractParams.ChangeAccountType is ' ||
				  htools.bool2str(vcontractparams.changeaccounttype)
				 ,csay_level);
			vcontractparams.checkidentacctype := contractparams.loadchar(contractparams.getobjecttype(contracttype.ccontracttypebranch)
																		,0
																		,'CHECKIDENTACCTYPE'
																		,FALSE) = '1';
			s.say(cmethod_name || ': vContractParams.CheckIdentAccType is ' ||
				  htools.bool2str(vcontractparams.checkidentacctype)
				 ,csay_level);
			vcontractparams.checkidenttieracc := contractparams.loadchar(contractparams.getobjecttype(contracttype.ccontracttypebranch)
																		,0
																		,'CHECKIDENTTIERACC'
																		,FALSE) = '1';
			s.say(cmethod_name || ': vContractParams.CheckIdentTierAcc is ' ||
				  htools.bool2str(vcontractparams.checkidenttieracc)
				 ,csay_level);
			vcontractparams.changefinprofile := contractparams.loadchar(contractparams.getobjecttype(contracttype.ccontracttypebranch)
																	   ,0
																	   ,'CHANGEFINPROFILE'
																	   ,FALSE) = '1';
			s.say(cmethod_name || ': vContractParams.ChangeFinProfile is ' ||
				  htools.bool2str(vcontractparams.changefinprofile)
				 ,csay_level);
			IF nvl(pwriterbdata, TRUE)
			THEN
				setlabel_changecontracttype(pcontractno
										   ,scontractarray(vhandle).contractrow.type
										   ,vcontractparams);
			END IF;
		ELSE
			vcontractparams.changecardstate := nvl(pcontractparams.changecardstate, FALSE);
		END IF;
		changecontracttypebyhandle(vhandle, vcontractparams, pundo, pwriterbdata);
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
		
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE changecontractparameters
	(
		pcontractrow       IN OUT tcontract%ROWTYPE
	   ,pnewcontractparams IN contract.typecontractparams
	   ,pundo              BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeContractParameters';
	
		vwriterbdata BOOLEAN;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pContractRow.No', pcontractrow.no);
		t.inpar('pContractRow.Type', pcontractrow.type);
		t.inpar('pContractRow.IdClient', pcontractrow.idclient);
		t.inpar('pContractRow.CreateDate', htools.d2s(pcontractrow.createdate));
	
		t.inpar('pNewContractParams.Type', pnewcontractparams.type);
		t.inpar('pNewContractParams.IdClient', pnewcontractparams.idclient);
		t.inpar('pNewContractParams.CreateDate', htools.d2s(pnewcontractparams.createdate));
		t.inpar('pUndo', t.b2t(pundo));
		t.inpar('pNewContractParams.OperationMode', pnewcontractparams.operationmode);
	
		IF nvl(pnewcontractparams.no, pcontractrow.no) != pcontractrow.no
		THEN
			t.note(cmethod_name, '[4]', csay_level);
			IF nvl(pnewcontractparams.changecontractno, FALSE)
			THEN
				IF changecontractno(pcontractrow.no
								   ,pnewcontractparams.no
								   ,pnewcontractparams.packno) > 0
				THEN
					NULL;
				END IF;
				pcontractrow.no := pnewcontractparams.no;
			ELSE
				error.raiseerror('Attempted change of contract number. Change of contract number is not allowed in operation parameters.');
			END IF;
		END IF;
	
		IF nvl(pnewcontractparams.createdate, pcontractrow.createdate) != pcontractrow.createdate
		THEN
			t.note(cmethod_name, '[1]', csay_level);
			changecreatedate(pcontractrow.no, pcontractrow.createdate, pnewcontractparams);
			pcontractrow.createdate := pnewcontractparams.createdate;
		END IF;
	
		IF nvl(pnewcontractparams.type, pcontractrow.type) != pcontractrow.type
		THEN
			t.note(cmethod_name, '[2]', csay_level);
			IF nvl(pnewcontractparams.changecontracttype, FALSE)
			THEN
			
				vwriterbdata := NOT nvl(pundo, FALSE);
				t.var('vWriteRBData', t.b2t(vwriterbdata));
				--changecontracttype(pcontractrow.no, pnewcontractparams, pundo, vwriterbdata);
			
				pcontractrow.type := pnewcontractparams.type;
			ELSE
				error.raiseerror('Attempted change of contract type. Change of contract type is not allowed in operation parameters.');
			END IF;
		END IF;
	
		IF nvl(pnewcontractparams.idclient, pcontractrow.idclient) != pcontractrow.idclient
		THEN
			t.note(cmethod_name, '[3]', csay_level);
			IF nvl(pnewcontractparams.changeidclient, FALSE)
			THEN
				changeidclient(pcontractrow.no
							  ,pcontractrow.idclient
							  ,pnewcontractparams.idclient
							  ,nvl(pnewcontractparams.changecardidclient, TRUE)
							  ,pnewcontractparams.operationmode);
				pcontractrow.idclient := pnewcontractparams.idclient;
			END IF;
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END changecontractparameters;

	PROCEDURE undochangecontractparameters
	(
		pcontractrow IN OUT tcontract%ROWTYPE
	   ,prbdata      IN VARCHAR2
	)
	
	 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.UndoChangeContractParameters';
		varrparams uamp.tarrrecord;
		vaarg      contracttools.typevarchar50;
		vcontrow   typecontractparams;
		vret       NUMBER;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pContractRow.No', pcontractrow.no);
		IF prbdata IS NOT NULL
		THEN
			varrparams := uamp.parsestring(prbdata, ';');
			FOR i IN 1 .. varrparams.count
			LOOP
				s.say(cmethod_name || ': param name ' || varrparams(i).name || ', value ' || varrparams(i)
					  .value
					 ,csay_level);
				IF upper(varrparams(i).name) = ccreate_date
				THEN
					vret := contracttools.getargforundo(varrparams(i).value, vaarg);
					s.say(cmethod_name || ': record count ' || vret, csay_level);
					IF vret != 2
					THEN
						error.raiseerror('Invalid data for undo! (' || ccreate_date || ')');
					END IF;
					vcontrow.createdate          := to_date(vaarg(1), cdate_format);
					vcontrow.changeacccreatedate := (vaarg(2) = '1');
					--changecontractparameters(pcontractrow, vcontrow, TRUE);
				END IF;
				IF upper(varrparams(i).name) = cchange_type
				THEN
					vret := contracttools.getargforundo(varrparams(i).value, vaarg);
					s.say(cmethod_name || ': record count ' || vret, csay_level);
					IF vret != 2
					THEN
						error.raiseerror('Invalid data for undo! (' || cchange_type || ')');
					END IF;
					vcontrow.type               := to_number(vaarg(1));
					vcontrow.changeaccounttype  := (vaarg(2) = '1');
					vcontrow.changecontracttype := TRUE;
					--changecontractparameters(pcontractrow, vcontrow, TRUE);
				END IF;
			END LOOP;
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END undochangecontractparameters;

	FUNCTION getcardno
	(
		ppan          VARCHAR2
	   ,pmbr          NUMBER
	   ,prigthviewpan BOOLEAN := NULL
	) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCardNo';
	BEGIN
		RETURN card.getmaskedpan(ppan, prigthviewpan) || '-' || nvl(to_char(pmbr), '()');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcardno;

	FUNCTION getcontractrecord(pcontractno IN VARCHAR2) RETURN apitypes.typecontractrecord IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractRecord';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vcontractrecord apitypes.typecontractrecord;
		vguid           types.guid;
	BEGIN
		vguid := getguid(pcontractno);
		SELECT no
			  ,TYPE
			  ,idclient
			  ,createclerk
			  ,createdate
			  ,closeclerk
			  ,closedate
			  ,status
			  ,branchpart
			  ,vguid
		INTO   vcontractrecord.no
			  ,vcontractrecord.type
			  ,vcontractrecord.idclient
			  ,vcontractrecord.createclerk
			  ,vcontractrecord.createdate
			  ,vcontractrecord.closeclerk
			  ,vcontractrecord.closedate
			  ,vcontractrecord.status
			  ,vcontractrecord.branchpart
			  ,vcontractrecord.guid
		FROM   tcontract
		WHERE  branch = cbranch
		AND    no = pcontractno;
		RETURN vcontractrecord;
	EXCEPTION
		WHEN no_data_found THEN
			err.seterror(err.contract_not_found, cmethod_name);
			RETURN vcontractrecord;
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN vcontractrecord;
	END getcontractrecord;

	FUNCTION getcontractrowtype
	(
		pcontractno  IN tcontract.no%TYPE
	   ,pdoexception IN BOOLEAN := TRUE
	) RETURN tcontract%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractRowType';
		vbranch tseance.branch%TYPE := seance.getbranch();
		vret    tcontract%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno, csay_level);
	
		SELECT *
		INTO   vret
		FROM   tcontract
		WHERE  branch = vbranch
		AND    no = pcontractno;
	
		IF vret.objectuid IS NULL
		THEN
			vret.objectuid := updateobjectuid(pcontractno);
		END IF;
	
		t.leave(cmethod_name, 'vRet.ObjUID=' || vret.objectuid, csay_level);
		RETURN vret;
	EXCEPTION
		WHEN no_data_found THEN
			IF nvl(pdoexception, TRUE)
			THEN
				t.exc(cmethod_name, plevel => csay_level);
				error.saveraise(cmethod_name
							   ,error.errorconst
							   ,err.gettext(err.contract_not_found) || ' <' || pcontractno || '>');
			ELSE
				RETURN vret;
			END IF;
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
		
			error.save(cmethod_name);
			RAISE;
	END getcontractrowtype;

	FUNCTION getcontractnobyaccno
	(
		paccno       IN taccount.accountno%TYPE
	   ,pdoexception IN BOOLEAN := TRUE
	) RETURN tcontract.no%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractNoByAccNo';
		vcontract typecontractitemrecord;
	BEGIN
		vcontract := getcontractbyaccount(paccno, pdoexception);
		RETURN vcontract.contractno;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcontractnobyaccno;

	FUNCTION getcontractnobycard
	(
		ppan         tcard.pan%TYPE
	   ,pmbr         tcard.mbr%TYPE
	   ,pdoexception BOOLEAN := TRUE
	) RETURN tcontract.no%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractNoByCard';
		vcontract typecontractitemrecord;
	BEGIN
		vcontract := getcontractbycard(ppan, pmbr, pdoexception);
		RETURN vcontract.contractno;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcontractnobycard;

	FUNCTION getaccountitemlist(pcontractno IN tcontract.no%TYPE) RETURN typecontractitemlist IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetAccountItemList';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vaccountlist  typecontractitemlist;
		vindex        NUMBER := 0;
		vcontracttype tcontract.type%TYPE;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pContractNo', pcontractno);
		vcontracttype := gettype(pcontractno);
	
		FOR i IN (SELECT t.*
						,t1.itemname
				  FROM   tcontractitem t
				  INNER  JOIN tcontracttypeitemname t1
				  ON     t1.branch = t.branch
				  AND    t1.itemcode = t.itemcode
				  WHERE  t.branch = cbranch
				  AND    t.no = pcontractno)
		LOOP
			vindex := vindex + 1;
			vaccountlist(vindex).contractno := i.no;
			vaccountlist(vindex).contracttype := vcontracttype;
			vaccountlist(vindex).itemcode := i.itemcode;
			vaccountlist(vindex).itemname := i.itemname;
			vaccountlist(vindex).accountno := i.key;
		END LOOP;
	
		t.leave(cmethod_name, 'vAccountList.count=' || vaccountlist.count, csay_level);
		RETURN vaccountlist;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcarditemlist(pcontractno IN tcontract.no%TYPE) RETURN typecontractitemlist IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCardItemList';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vcardlist     typecontractitemlist;
		vindex        NUMBER := 0;
		vcontracttype tcontract.type%TYPE;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pContractNo', pcontractno);
		vcontracttype := gettype(pcontractno);
	
		FOR i IN (SELECT *
				  FROM   tcontractcarditem
				  WHERE  branch = cbranch
				  AND    no = pcontractno)
		LOOP
			vindex := vindex + 1;
			vcardlist(vindex).contractno := i.no;
			vcardlist(vindex).contracttype := vcontracttype;
			vcardlist(vindex).itemcode := i.itemcode;
			vcardlist(vindex).pan := i.pan;
			vcardlist(vindex).mbr := i.mbr;
		END LOOP;
	
		t.leave(cmethod_name, 'vCardList.count=' || vcardlist.count, csay_level);
		RETURN vcardlist;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcontractbycard
	(
		ppan         IN tcard.pan%TYPE
	   ,pmbr         IN tcard.mbr%TYPE
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN typecontractitemrecord IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractByCard';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vcarditem typecontractitemrecord;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pPAN', card.getmaskedpan(ppan));
		t.inpar('pMBR', pmbr);
		t.inpar('pDoException', t.b2t(pdoexception));
	
		BEGIN
			SELECT a.no
				  ,b.type
				  ,a.itemcode
				  ,a.pan
				  ,a.mbr
			INTO   vcarditem.contractno
				  ,vcarditem.contracttype
				  ,vcarditem.itemcode
				  ,vcarditem.pan
				  ,vcarditem.mbr
			FROM   tcontractcarditem a
			INNER  JOIN tcontract b
			ON     b.branch = a.branch
			AND    b.no = a.no
			WHERE  a.branch = cbranch
			AND    a.pan = ppan
			AND    a.mbr = pmbr;
		EXCEPTION
			WHEN no_data_found THEN
				IF nvl(pdoexception, FALSE)
				THEN
					error.raiseerror('Contract not found for card ' || getcardno(ppan, pmbr) || ' ');
				END IF;
			WHEN OTHERS THEN
				RAISE;
		END;
		t.leave(cmethod_name, 'vCardItem.ItemCode=' || vcarditem.itemcode, csay_level);
		RETURN vcarditem;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcontractlistbycard
	(
		ppan IN tcard.pan%TYPE
	   ,pmbr IN tcard.mbr%TYPE := NULL
	) RETURN typecontractitemlist IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractListByCard';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vcardlist typecontractitemlist;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pPAN', card.getmaskedpan(ppan));
		t.inpar('pMBR', pmbr);
	
		SELECT a.no       AS contractno
			  ,b.type     AS contracttype
			  ,a.itemcode
			  ,NULL       AS itemname
			  ,NULL       AS accountno
			  ,NULL       AS accitemdescr
			  ,a.pan
			  ,a.mbr      BULK COLLECT
		INTO   vcardlist
		FROM   tcontractcarditem a
		INNER  JOIN tcontract b
		ON     b.branch = a.branch
		AND    b.no = a.no
		WHERE  a.branch = cbranch
		AND    a.pan = ppan
		AND    (a.mbr = pmbr OR pmbr IS NULL);
	
		t.leave(cmethod_name, 'vCardList.count=' || vcardlist.count, csay_level);
		RETURN vcardlist;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcontractbyaccount
	(
		paccountno   IN taccount.accountno%TYPE
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN typecontractitemrecord IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractByAccount';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vaccountitem typecontractitemrecord;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pAccountNo', paccountno);
		t.inpar('pDoException', t.b2t(pdoexception));
	
		BEGIN
			SELECT a.no
				  ,b.contracttype
				  ,a.itemcode
				  ,a.key
				  ,b.itemname
				  ,a.itemdescr
			INTO   vaccountitem.contractno
				  ,vaccountitem.contracttype
				  ,vaccountitem.itemcode
				  ,vaccountitem.accountno
				  ,vaccountitem.itemname
				  ,vaccountitem.accitemdescr
			FROM   tcontractitem a
			INNER  JOIN tcontracttypeitemname b
			ON     b.branch = a.branch
			AND    b.itemcode = a.itemcode
			WHERE  a.branch = cbranch
			AND    a.key = paccountno;
		EXCEPTION
			WHEN no_data_found THEN
				IF nvl(pdoexception, FALSE)
				THEN
					error.raiseerror('Contract not found for account <' || paccountno || '> ');
				END IF;
			WHEN OTHERS THEN
				RAISE;
		END;
		t.leave(cmethod_name
			   ,'vAccountItem.ItemCode=' || vaccountitem.itemcode || ', ItemName=' ||
				vaccountitem.itemname
			   ,csay_level);
		RETURN vaccountitem;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getaccountlist(pcontractno IN VARCHAR2) RETURN apitypes.typeaccountlist IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetAccountList';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vindex       NUMBER := 0;
		vaccountlist apitypes.typeaccountlist;
		CURSOR c1 IS
			SELECT key
			FROM   tcontractitem
			WHERE  branch = cbranch
			AND    no = pcontractno;
	BEGIN
		FOR i IN c1
		LOOP
			vindex := vindex + 1;
			vaccountlist(vindex) := account.getaccountrecord(i.key);
		END LOOP;
		RETURN vaccountlist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getaccountlist;

	FUNCTION getcardlist
	(
		pcontractno       IN tcontract.no%TYPE
	   ,pstate            IN tcard.signstat%TYPE := NULL
	   ,pstatus           IN tcard.crd_stat%TYPE := NULL
	   ,pclientid4sorting IN tcard.idclient%TYPE := NULL
	) RETURN apitypes.typecardlist IS
		cmethod_name    CONSTANT VARCHAR2(65) := cpackage_name || '.GetCardList';
		csortbyclientid CONSTANT NUMBER := htools.b2i(pclientid4sorting IS NOT NULL);
		cbranch         CONSTANT NUMBER := seance.getbranch;
		vresult apitypes.typecardlist;
	BEGIN
		t.enter(cmethod_name
			   ,'ContractNo = ' || pcontractno || ', State = ' || pstate || ', Status = ' ||
				pstatus || ', ClientId4Sorting = ' || pclientid4sorting);
	
		FOR i IN (SELECT c.*
				  FROM   tcontractcarditem cci
				  JOIN   tcard c
				  ON     c.branch = cci.branch
				  AND    c.pan = cci.pan
				  AND    c.mbr = cci.mbr
				  WHERE  cci.branch = cbranch
				  AND    cci.no = pcontractno
				  AND    ((pstate IS NULL) OR (c.signstat = pstate))
				  AND    ((pstatus IS NULL) OR (c.crd_stat = pstatus))
				  ORDER  BY decode(csortbyclientid
								  ,0
								  ,c.pan
								  ,1
								  ,CASE c.idclient
									   WHEN pclientid4sorting THEN
										0
									   ELSE
										c.idclient
								   END)
						   ,decode(csortbyclientid, 0, c.mbr))
		LOOP
			vresult(vresult.count + 1) := card.converttoapitypes(i);
		END LOOP;
	
		t.leave(cmethod_name, vresult.count);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END getcardlist;

	FUNCTION getcardlist
	(
		pcontractno       IN tcontract.no%TYPE
	   ,paccountno        IN taccount.accountno%TYPE
	   ,pstate            IN tcard.signstat%TYPE := NULL
	   ,pstatus           IN tcard.crd_stat%TYPE := NULL
	   ,pclientid4sorting IN tcard.idclient%TYPE := NULL
	) RETURN apitypes.typecardlist IS
		cmethod_name    CONSTANT VARCHAR2(65) := cpackage_name || '.GetCardList';
		csortbyclientid CONSTANT NUMBER := htools.b2i(pclientid4sorting IS NOT NULL);
		cbranch         CONSTANT NUMBER := seance.getbranch;
		vresult apitypes.typecardlist;
	BEGIN
		t.enter(cmethod_name
			   ,'ContractNo = ' || pcontractno || ', AccountNo = ' || paccountno || ', State = ' ||
				pstate || ', Status = ' || pstatus || ', ClientId4Sorting = ' || pclientid4sorting);
	
		IF contracttools.notequal(getcontractnobyaccno(paccountno, FALSE), pcontractno)
		THEN
			error.raiseerror('Account [ ' || paccountno || '] does not belong to contract [' ||
							 pcontractno || ']!');
		END IF;
	
		FOR i IN (SELECT c.*
				  FROM   tcontractcarditem cci
				  JOIN   tacc2card ac
				  ON     ac.branch = cci.branch
				  AND    ac.accountno = paccountno
				  AND    ac.pan = cci.pan
				  AND    ac.mbr = cci.mbr
				  JOIN   tcard c
				  ON     c.branch = ac.branch
				  AND    c.pan = ac.pan
				  AND    c.mbr = ac.mbr
				  WHERE  cci.branch = cbranch
				  AND    cci.no = pcontractno
				  AND    ((pstate IS NULL) OR (c.signstat = pstate))
				  AND    ((pstatus IS NULL) OR (c.crd_stat = pstatus))
				  ORDER  BY decode(csortbyclientid
								  ,0
								  ,c.pan
								  ,1
								  ,CASE c.idclient
									   WHEN pclientid4sorting THEN
										0
									   ELSE
										c.idclient
								   END)
						   ,decode(csortbyclientid, 0, c.mbr))
		LOOP
			vresult(vresult.count + 1) := card.converttoapitypes(i);
		END LOOP;
	
		t.leave(cmethod_name, vresult.count);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END getcardlist;

	FUNCTION getcurrentno RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCurrentNo';
	BEGIN
		t.leave(cmethod_name, 'return ' || scontractno);
		RETURN scontractno;
	END getcurrentno;

	PROCEDURE setcurrentno(pcontractno VARCHAR2) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCurrentNo';
	BEGIN
		t.enter(cmethod_name, pcontractno);
		scontractno := pcontractno;
	END setcurrentno;

	PROCEDURE clearcurrentno IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ClearCurrentNo';
	BEGIN
		t.enter(cmethod_name);
		scontractno := NULL;
	END clearcurrentno;

	PROCEDURE getcurrentcardno
	(
		opan OUT VARCHAR2
	   ,ombr OUT NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCurrentCardNo';
	BEGIN
		opan := span;
		ombr := smbr;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcurrentcardno;

	PROCEDURE setcurrentcardno
	(
		ppan VARCHAR2
	   ,pmbr NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetCurrentCardNo';
	BEGIN
		span := ppan;
		smbr := pmbr;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setcurrentcardno;

	FUNCTION getfinprofilebycardproduct
	(
		pcardproduct IN tcard.cardproduct%TYPE
	   ,paccountno   IN taccount.accountno%TYPE
	   ,pcardtype    IN tcontractcard.cardtype%TYPE := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetFinProfileByCardProduct';
		vresult NUMBER;
	
		vcontract typecontractitemrecord;
	BEGIN
		vcontract := getcontractbyaccount(paccountno, FALSE);
		IF vcontract.contractno IS NULL
		THEN
			RETURN NULL;
		END IF;
	
		IF pcardproduct IS NULL
		THEN
			error.raiseerror(err.reffi_cp_undefined);
		END IF;
		vresult := contractcard.getfinprofilebycardproduct(vcontract.contracttype
														  ,pcardproduct
														  ,pcardtype);
	
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getfinprofilebycardproduct;

	FUNCTION getclienttype(pcontractno IN VARCHAR2) RETURN client.tclienttype IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetClientType';
		vret      client.tclienttype;
		vclientid NUMBER;
	BEGIN
		vclientid := getidclient(pcontractno);
		vret      := client.getclienttype(vclientid);
		s.say(cmethod_name || ': for ' || pcontractno || ', client id ' || vclientid ||
			  ', client type ' || vret
			 ,csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getclienttype;

	FUNCTION getstatementlist(pcontractno VARCHAR2) RETURN apitypes.typestatementlist IS
	BEGIN
		RETURN statementrt.getcontractstatementlist(pcontractno);
	END getstatementlist;

	FUNCTION testhandle
	(
		phandle IN NUMBER
	   ,pfrom   IN CHAR
	) RETURN CHAR IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.TestHandle';
	BEGIN
		s.say(cmethod_name || ': enter, pFrom=' || pfrom, csay_level);
		IF scontractarray.exists(phandle)
		THEN
			err.seterror(0, pfrom);
			s.say(cmethod_name || ': contract mode ' || scontractarray(phandle).contractmode
				 ,csay_level);
			s.say(cmethod_name || ': contract lock ' ||
				  htools.bool2str(scontractarray(phandle).contractlock)
				 ,csay_level);
			RETURN scontractarray(phandle).contractmode;
		END IF;
	
		err.seterror(err.contract_not_found, pfrom);
		RETURN 'N';
	END testhandle;

	FUNCTION getfreehandle RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetFreeHandle';
	BEGIN
		s.say(cmethod_name || ': last ' || scontractarray.last, csay_level);
		RETURN nvl(scontractarray.last, 0) + 1;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getfreehandle;

	PROCEDURE changeobjectmode
	(
		phandle     IN NUMBER
	   ,pnewmod     IN CHAR
	   ,pchangelock IN BOOLEAN
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeObjectMode';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vcurmod       CHAR(1);
		vdbrevision   NUMBER;
		vcurrrevision NUMBER;
		CURSOR curcontractrec(pno IN VARCHAR2) IS
			SELECT *
			FROM   tcontract
			WHERE  branch = cbranch
			AND    no = pno
			FOR    UPDATE NOWAIT;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pHandle', phandle);
		t.inpar('pNewMod', pnewmod);
		t.inpar('pChangeLock', t.b2t(pchangelock));
		err.seterror(0, cmethod_name);
	
		vcurmod := testhandle(phandle, cmethod_name);
		t.var('vCurMod', vcurmod);
	
		IF (upper(pnewmod) = 'W')
		THEN
			t.note('POINT 01');
		
			SAVEPOINT changeobjectmode;
			FOR i IN curcontractrec(scontractarray(phandle).contractrow.no)
			LOOP
				vdbrevision := i.updaterevision;
			END LOOP;
			t.var('vDBRevision', vdbrevision);
		
			s.say(cmethod_name || ': for ' || scontractarray(phandle).contractrow.no, csay_level);
			IF (vcurmod = 'R' OR vcurmod = 'A')
			THEN
			
				CASE object.capture(object_name, scontractarray(phandle).contractrow.no)
					WHEN err.object_busy THEN
						err.seterror(err.contract_busy
									,cmethod_name
									,capturedobjectinfo(scontractarray(phandle).contractrow.no));
						RETURN;
					WHEN 0 THEN
						t.note(cmethod_name
							  ,'contract was locked successfully'
							  ,plevel => csay_level);
					ELSE
						RETURN;
				END CASE;
			
			END IF;
		
			ROLLBACK TO changeobjectmode;
		
			vcurrrevision := getupdaterevisionbyhandle(phandle);
			t.note(cmethod_name
				  ,'curr revision [' || vcurrrevision || '], db revision [' || vdbrevision || ']');
		
			IF vcurrrevision != vdbrevision
			THEN
			
				s.say(cmethod_name || ': it has been changed', csay_level);
			
				object.release(object_name, scontractarray(phandle).contractrow.no);
				err.seterror(err.contract_revision_changed, cmethod_name);
				RETURN;
			END IF;
		
			s.say(cmethod_name || ': update ', csay_level);
		
			scontractarray(phandle).contractrow.updaterevision := vdbrevision;
			setcurrentrevision(scontractarray(phandle).contractrow.no, vdbrevision);
			scontractarray(phandle).contractmode := upper(pnewmod);
		
			IF pchangelock
			THEN
				scontractarray(phandle).contractlock := TRUE;
			END IF;
		
		ELSIF (upper(pnewmod) = 'R' OR upper(pnewmod) = 'A')
		THEN
			t.note('POINT 02');
			IF pchangelock
			THEN
				scontractarray(phandle).contractlock := FALSE;
			END IF;
			IF NOT scontractarray(phandle).contractlock
			THEN
				s.say(cmethod_name || ': no lock ', csay_level);
				scontractarray(phandle).contractmode := upper(pnewmod);
				IF vcurmod = 'W'
				THEN
					object.release(object_name, scontractarray(phandle).contractrow.no);
				END IF;
			END IF;
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			BEGIN
				ROLLBACK TO changeobjectmode;
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			t.exc(cmethod_name, plevel => csay_level);
			IF upper(pnewmod) = 'W'
			THEN
				object.release(object_name, scontractarray(phandle).contractrow.no);
			END IF;
			IF SQLCODE = -54
			THEN
				err.seterror(err.contract_busy, cmethod_name);
			ELSE
				err.seterror(SQLCODE, cmethod_name);
			END IF;
	END changeobjectmode;

	FUNCTION getnewupdaterevision RETURN NUMBER IS
		vret NUMBER;
	BEGIN
	
		vret := seq_contractupdaterevision.nextval();
	
		RETURN vret;
	END getnewupdaterevision;

	FUNCTION newobject
	(
		pcontractno IN tcontract.no%TYPE
	   ,pmod        IN CHAR
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.NewObject';
		this NUMBER;
		vrow tcontract%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, pcontractno || ', ' || pmod);
		err.seterror(0, cmethod_name);
	
		IF upper(pmod) = 'W'
		THEN
			CASE object.capture(contract.object_name, pcontractno)
				WHEN err.object_busy THEN
					err.seterror(err.contract_busy, cmethod_name, capturedobjectinfo(pcontractno));
					RETURN 0;
				WHEN 0 THEN
					t.note(cmethod_name, 'contract was locked successfully', plevel => csay_level);
				ELSE
					RETURN 0;
			END CASE;
		END IF;
		vrow := getcontractrowtype(pcontractno);
		this := getfreehandle();
		s.say(cmethod_name || ': handle ' || this, csay_level);
		scontractarray(this).contractrow := vrow;
		t.var('sContractArray(this).ContractRow.UpdateRevision'
			 ,scontractarray(this).contractrow.updaterevision);
		IF pmod <> 'R'
		THEN
			setcurrentrevision(pcontractno, scontractarray(this).contractrow.updaterevision);
		END IF;
	
		scontractarray(this).userproperty := getuserattributeslist(pcontractno);
		t.var('sContractArray(this).UserProperty.count', scontractarray(this).userproperty.count);
		scontractarray(this).extrauserproperty := getextrauserattributeslist(pcontractno);
		t.var('sContractArray(this).ExtraUserProperty.count'
			 ,scontractarray(this).extrauserproperty.count);
	
		scontractarray(this).contractmode := upper(pmod);
		scontractarray(this).contractlock := (upper(pmod) = 'W');
		scontractarray(this).guid := objectuid.getguid(vrow.objectuid);
		s.say(cmethod_name || ': items count ' || scontractarray.count, csay_level);
		setcurrentrecord(this);
		t.leave(cmethod_name);
		RETURN this;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			IF upper(pmod) = 'W'
			THEN
				object.release(contract.object_name, pcontractno);
			END IF;
			IF SQLCODE = -54
			THEN
				err.seterror(err.contract_busy, cmethod_name);
			ELSE
				err.seterror(SQLCODE, cmethod_name, SQLERRM);
			END IF;
			RETURN 0;
	END newobject;

	PROCEDURE freeobject(phandle IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FreeObject';
	BEGIN
		IF testhandle(phandle, cmethod_name) = 'W'
		THEN
			object.release(contract.object_name, scontractarray(phandle).contractrow.no);
		END IF;
	
		scontractarray.delete(phandle);
		IF scurrenthandle = phandle
		THEN
			clearcurrentno;
			scurrenthandle := NULL;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
	END freeobject;

	PROCEDURE abortfreeobject(phandle IN NUMBER) IS
		vctx err.typecontextrec;
	BEGIN
		vctx := err.getcontext();
		freeobject(phandle);
		IF err.geterrorcode() = 0
		THEN
			err.putcontext(vctx);
		END IF;
	END abortfreeobject;

	PROCEDURE readobject(phandle IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ReadObject';
	BEGIN
		IF testhandle(phandle, cmethod_name) != 'N'
		THEN
		
			scontractarray(phandle).contractrow := getcontractrowtype(scontractarray(phandle)
																	  .contractrow.no);
		
			scontractarray(phandle).userproperty := getuserattributeslist(scontractarray(phandle)
																		  .contractrow.no);
			t.var('sContractArray(pHandle).UserProperty.count'
				 ,scontractarray(phandle).userproperty.count);
			scontractarray(phandle).extrauserproperty := getextrauserattributeslist(scontractarray(phandle)
																					.contractrow.no);
			t.var('sContractArray(pHandle).ExtraUserProperty.count'
				 ,scontractarray(phandle).extrauserproperty.count);
		
		END IF;
	EXCEPTION
		WHEN no_data_found THEN
			err.seterror(err.contract_not_found, cmethod_name);
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END readobject;

	PROCEDURE writeobject
	(
		phandle      IN NUMBER
	   ,pblockparams IN typecontractblockparams := semptycontractblockparams
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.WriteObject';
	
		vcontract    typecontractrec;
		vblockparams typecontractblockparams := pblockparams;
	BEGIN
		t.enter(cmethod_name, 'pHandle=' || phandle, csay_level);
		IF scontractarray(phandle).contractmode != 'W'
		THEN
			changeobjectmode(phandle, 'W');
			error.raisewhenerr();
		END IF;
	
		IF testhandle(phandle, 'Contract.WriteObject') = 'W'
		THEN
			BEGIN
			
				vcontract.contractrow     := scontractarray(phandle).contractrow;
				vblockparams.contracttype := vcontract.contractrow.type;
			
				IF pblockparams.operationtype IN (action_clientchange, action_contracttypechange)
				   AND nvl(pblockparams.operationmode, c_unknownmode) IN (c_interactivemode)
				THEN
					vcontract.userproperty      := getcurrentdlguserattributes();
					vcontract.extrauserproperty := getcurrdlgextrauserattributes();
				ELSE
					vcontract.userproperty      := scontractarray(phandle).userproperty;
					vcontract.extrauserproperty := scontractarray(phandle).extrauserproperty;
				END IF;
			
				execcontrolblock_updatevalues(vcontract
											 ,getaccessory(vcontract.contractrow)
											 ,vblockparams);
			
				s.say(cmethod_name || ': do it ', csay_level);
				vcontract.contractrow.updatedate      := seance.getoperdate();
				vcontract.contractrow.updatesysdate   := SYSDATE;
				vcontract.contractrow.updateclerkcode := clerk.getcode();
				vcontract.contractrow.updaterevision  := getnewupdaterevision();
				UPDATE tcontract
				SET    idclient        = scontractarray(phandle).contractrow.idclient
					  ,status          = scontractarray(phandle).contractrow.status
					  ,updatedate      = vcontract.contractrow.updatedate
					  ,updateclerkcode = vcontract.contractrow.updateclerkcode
					  ,updatesysdate   = vcontract.contractrow.updatesysdate
					  ,TYPE            = scontractarray(phandle).contractrow.type
					  ,createdate      = scontractarray(phandle).contractrow.createdate
					  ,closedate       = scontractarray(phandle).contractrow.closedate
					  ,closeclerk      = scontractarray(phandle).contractrow.closeclerk
					  ,rollbackdata    = scontractarray(phandle).contractrow.rollbackdata
					  ,branchpart      = scontractarray(phandle).contractrow.branchpart
					  ,arcdate         = scontractarray(phandle).contractrow.arcdate
					  ,updaterevision  = vcontract.contractrow.updaterevision
					  ,lastadjdate     = scontractarray(phandle).contractrow.lastadjdate
					  ,finprofile      = scontractarray(phandle).contractrow.finprofile
					  ,substatus       = scontractarray(phandle).contractrow.substatus
					  ,commentary      = scontractarray(phandle).contractrow.commentary
				WHERE  branch = scontractarray(phandle).contractrow.branch
				AND    no = scontractarray(phandle).contractrow.no;
			
				scontractarray(phandle).contractrow.updatedate := vcontract.contractrow.updatedate;
				scontractarray(phandle).contractrow.updatesysdate := vcontract.contractrow.updatesysdate;
				scontractarray(phandle).contractrow.updateclerkcode := vcontract.contractrow.updateclerkcode;
				scontractarray(phandle).contractrow.updaterevision := vcontract.contractrow.updaterevision;
				setcurrentrevision(scontractarray(phandle).contractrow.no
								  ,scontractarray(phandle).contractrow.updaterevision);
			
				scontractarray(phandle).userproperty := vcontract.userproperty;
				t.var('sContractArray(this).UserProperty.count'
					 ,scontractarray(phandle).userproperty.count);
				scontractarray(phandle).extrauserproperty := vcontract.extrauserproperty;
				t.var('sContractArray(this).ExtraUserProperty.count'
					 ,scontractarray(phandle).extrauserproperty.count);
			
				t.var('OperationMode=' || pblockparams.operationmode);
				IF nvl(pblockparams.operationmode, c_unknownmode) = c_interactivemode
				   OR ischangeduserattrlist
				THEN
					saveuserattributeslist(scontractarray     (phandle).contractrow.no
										  ,scontractarray     (phandle).userproperty
										  ,pclearpropnotinlist => TRUE);
				END IF;
				IF nvl(pblockparams.operationmode, c_unknownmode) = c_interactivemode
				   OR ischangedextrauserattrlist
				THEN
					saveextrauserattributeslist(scontractarray     (phandle).contractrow.no
											   ,scontractarray     (phandle).extrauserproperty
											   ,pclearpropnotinlist => TRUE);
				END IF;
			
			EXCEPTION
				WHEN OTHERS THEN
					err.seterror(SQLCODE, cmethod_name);
					error.save(cmethod_name);
					RAISE;
			END;
		END IF;
	
		IF object.getcapturemode = object.mode_optimistic
		THEN
			changeobjectmode(phandle, 'R');
		END IF;
	
		t.leave(cmethod_name, 'pHandle=' || phandle, csay_level);
	
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
		
	END;

	FUNCTION getcurrentdlgcontractrecord RETURN tcontract%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(64) := cpackage_name || '.GetCurrentDlgContractRecord';
		vcontractrow tcontract%ROWTYPE;
	BEGIN
		IF (scontdlg IS NULL)
		THEN
			error.raiseerror('Cannot access contract dialog box!');
		ELSIF scurrenthandle IS NULL
			  OR testhandle(scurrenthandle, cmethod_name) IS NULL
		THEN
			error.raiseerror('Contract data unavailable!');
		END IF;
	
		vcontractrow            := scontractarray(scurrenthandle).contractrow;
		vcontractrow.branchpart := referencebranchpart.getbpfromdialog(scontdlg);
		RETURN vcontractrow;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcurrentdlgcontractrecord;

	FUNCTION getcurrentcontracttype RETURN tcontract.type%TYPE IS
		cmethod_name CONSTANT VARCHAR2(64) := cpackage_name || '.GetCurrentContractType';
		vtype tcontract.type%TYPE;
	BEGIN
		t.enter(cmethod_name, 'CurrDialog=' || scontdlg || ', CurrentHandle=' || scurrenthandle);
		IF (scontdlg IS NULL)
		THEN
			error.raiseerror('Cannot access contract dialog box!');
		ELSIF scurrenthandle IS NULL
			  OR testhandle(scurrenthandle, cmethod_name) IS NULL
		THEN
			error.raiseerror('Contract data unavailable!');
		END IF;
	
		vtype := scontractarray(scurrenthandle).contractrow.type;
		t.leave(cmethod_name, 'return ' || vtype);
		RETURN vtype;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcurrentcontracttype;

	PROCEDURE handler_selecttype
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.Handler_SelectType';
		pcontracttype NUMBER;
		pno           tcontract.no%TYPE;
		vcontrrow     typecontractparams;
		vcontractrow  tcontract%ROWTYPE;
	BEGIN
		pcontracttype := dialog.getnumber(pdialog, 'ContractType');
		s.say(cmethod_name || ': for type ' || pcontracttype, csay_level);
		pno := dialog.getchar(pdialog, 'No');
		s.say(cmethod_name || ': no ' || pno, csay_level);
		IF pwhat = dialog.wtdialogpre
		THEN
		
			IF ktools.lcount(pdialog, 'eCType') > 0
			THEN
				vcontractrow.type := dialog.getrecordnumber(pdialog, 'eCType', 'TYPE', 1);
				contracttype.setdata(pdialog, 'eCType', vcontractrow.type);
			
			END IF;
		
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			IF pcmd = dialog.cmok
			THEN
				vcontrrow.type := contracttype.getdata(pdialog, 'eCType');
				s.say(cmethod_name || ': type ' || vcontrrow.type, csay_level);
				vcontractrow := contract.getcontractrowtype(dialog.getchar(pdialog, 'No'));
				IF vcontrrow.type IS NOT NULL
				THEN
				
					IF contracttype.existstype(vcontrrow.type)
					THEN
						err.seterror(0, cmethod_name);
						IF contracttype.getschemapackage(vcontrrow.type) !=
						   contracttype.getschemapackage(vcontractrow.type)
						THEN
							dialog.sethothint(pdialog
											 ,'Invalid contract type code [' || vcontrrow.type || ']');
							dialog.goitem(pdialog, 'eCType');
							dialog.cancelclose(pdialog);
							err.seterror(0, cmethod_name);
							RETURN;
						END IF;
					ELSE
						dialog.sethothint(pdialog
										 ,'Invalid contract type code [' || vcontrrow.type || ']');
						dialog.goitem(pdialog, 'eCType');
						dialog.cancelclose(pdialog);
						RETURN;
					END IF;
				ELSE
					dialog.sethothint(pdialog, 'Contract type code not specified');
					dialog.goitem(pdialog, 'eCType');
					dialog.cancelclose(pdialog);
					RETURN;
				END IF;
			
				vcontrrow.changecontracttype := TRUE;
				vcontrrow.changecardstate    := TRUE;
				vcontrrow.changeaccounttype  := nvl(contractparams.loadchar(contractparams.getobjecttype(contracttype.ccontracttypebranch)
																		   ,0
																		   ,'CHANGEACCTYPE'
																		   ,FALSE)
												   ,'0') = '1' AND
												nvl(dialog.getbool(pdialog, 'ReplaceAccType')
												   ,FALSE);
				s.say(cmethod_name || ': vContrRow.ChangeAccountType is ' ||
					  htools.bool2str(vcontrrow.changeaccounttype)
					 ,csay_level);
				vcontrrow.checkidentacctype := contractparams.loadchar(contractparams.getobjecttype(contracttype.ccontracttypebranch)
																	  ,0
																	  ,'CHECKIDENTACCTYPE'
																	  ,FALSE) = '1';
				s.say(cmethod_name || ': vContrRow.CheckIdentAccType is ' ||
					  htools.bool2str(vcontrrow.checkidentacctype)
					 ,csay_level);
				vcontrrow.checkidenttieracc := contractparams.loadchar(contractparams.getobjecttype(contracttype.ccontracttypebranch)
																	  ,0
																	  ,'CHECKIDENTTIERACC'
																	  ,FALSE) = '1';
				s.say(cmethod_name || ': vContrRow.CheckIdentTierAcc is ' ||
					  htools.bool2str(vcontrrow.checkidenttieracc)
					 ,csay_level);
				vcontrrow.changefinprofile := contractparams.loadchar(contractparams.getobjecttype(contracttype.ccontracttypebranch)
																	 ,0
																	 ,'CHANGEFINPROFILE'
																	 ,FALSE) = '1';
				s.say(cmethod_name || ': vContrRow.ChangeFinProfile is ' ||
					  htools.bool2str(vcontrrow.changefinprofile)
					 ,csay_level);
				vcontrrow.operationmode := c_interactivemode;
				BEGIN
					SAVEPOINT changect;
					changecontracttype(vcontractrow, vcontrrow, FALSE, FALSE);
				EXCEPTION
					WHEN OTHERS THEN
						ROLLBACK TO changect;
						error.save(cmethod_name);
						RAISE;
				END;
				COMMIT;
			END IF;
		END IF;
		s.say(cmethod_name || ': done ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			error.showerror;
			dialog.cancelclose(pdialog);
	END handler_selecttype;

	PROCEDURE refreshsysdate(pcontractno IN tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.RefreshSysDate';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		voperdate  DATE;
		vclerkcode NUMBER;
	BEGIN
		s.say('Start ' || cmethod_name || ' No=' || pcontractno, csay_level);
		voperdate  := seance.getoperdate();
		vclerkcode := clerk.getcode();
		UPDATE tcontract
		SET    updatedate      = voperdate
			  ,updateclerkcode = vclerkcode
			  ,updatesysdate   = SYSDATE()
		WHERE  branch = cbranch
		AND    no = pcontractno;
		s.say('Finish ' || cmethod_name, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ', error: ' || SQLERRM());
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE getmaskedfieldslist(ptypesubobj IN VARCHAR2) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.' || 'GetMaskedFieldsList';
	BEGIN
		a4mlog.addmaskedfield(clogparam_pan, s.cmask_pan);
		objuserproperty.fillmaskedfieldslistforlog(object_name, ptypesubobj);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setlastadjdatebyhandle
	(
		phandle      IN NUMBER
	   ,plastadjdate IN DATE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetLastAdjDateByHandle';
	BEGIN
		s.say('Start ' || cmethod_name || ' pHandle=' || phandle || ', pLastAdjDate=' ||
			  plastadjdate
			 ,csay_level);
		IF scontractarray.exists(phandle)
		THEN
			scontractarray(phandle).contractrow.lastadjdate := plastadjdate;
		ELSE
			error.saveraise(cmethod_name, error.errorconst, 'Handle ' || phandle || ' not found!');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setlastadjdatebyhandle;

	PROCEDURE setlastadjdate
	(
		pcontractno  IN tcontract.no%TYPE
	   ,plastadjdate IN DATE
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.SetLastAdjDate';
		vhandle NUMBER;
		vnew    BOOLEAN;
	BEGIN
		s.say('Start ' || cmethod_name || ' pContractNo=' || pcontractno || ', pLastAdjDate=' ||
			  plastadjdate
			 ,csay_level);
		vhandle := gethandle(pcontractno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontractno, 'R');
			vnew    := TRUE;
		END IF;
		s.say(cmethod_name || ': vNew=' || htools.bool2str(vnew));
		setlastadjdatebyhandle(vhandle, plastadjdate);
		writeobject(vhandle);
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
		s.say('Finish ' || cmethod_name, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ', error: ' || SQLERRM());
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getobject(phandle IN NUMBER) RETURN tcontract%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetObject';
	BEGIN
		s.say('Start ' || cmethod_name || ' pHandle=' || phandle, csay_level);
		IF testhandle(phandle, 'Contract.GetObject') != 'N'
		THEN
			s.say('Finish ' || cmethod_name || ' return ContractRow.No=' || scontractarray(phandle)
				  .contractrow.no
				 ,csay_level);
			RETURN scontractarray(phandle).contractrow;
		ELSE
		
			error.raisewhenerr();
		
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ', error: ' || SQLERRM());
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getobjectmode(phandle IN NUMBER) RETURN CHAR IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetObjectMode';
	BEGIN
		t.enter(cmethod_name, ' pHandle=' || phandle, csay_level);
		IF testhandle(phandle, 'Contract.GetObject') != 'N'
		THEN
			t.leave(cmethod_name
				   ,' return ContractMode=' || scontractarray(phandle).contractmode
				   ,csay_level);
			RETURN scontractarray(phandle).contractmode;
		ELSE
			error.raisewhenerr();
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getlastadjdatebyhandle(phandle IN NUMBER) RETURN DATE IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetLastAdjDateByHandle';
	BEGIN
		s.say('Start ' || cmethod_name || ' pHandle=' || phandle, csay_level);
		IF testhandle(phandle, 'Contract.GetLastAdjDate') != 'N'
		THEN
			s.say('Finish ' || cmethod_name || ' return date=' ||
				  htools.d2s(scontractarray(phandle).contractrow.lastadjdate)
				 ,csay_level);
			RETURN scontractarray(phandle).contractrow.lastadjdate;
		ELSE
			error.raisewhenerr();
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ', error: ' || SQLERRM());
			error.save(cmethod_name);
			RAISE;
	END;
	FUNCTION getlastadjdate(pcontractno IN tcontract.no%TYPE) RETURN DATE IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetLastAdjDate';
		vhandle      NUMBER;
		vnew         BOOLEAN;
		vlastadjdate DATE;
	BEGIN
		s.say('Start ' || cmethod_name || ' pContractNo=' || pcontractno, csay_level);
		vhandle := gethandle(pcontractno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontractno, 'R');
			vnew    := TRUE;
		END IF;
		s.say(cmethod_name || ': vNew=' || htools.bool2str(vnew));
		vlastadjdate := getlastadjdatebyhandle(vhandle);
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
		s.say('Finish ' || cmethod_name, csay_level);
		RETURN vlastadjdate;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ', error: ' || SQLERRM());
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE viewcontract
	(
		pcontractno  IN tcontract.no%TYPE
	   ,pinnewthread IN BOOLEAN
	   ,preadonly    IN BOOLEAN := FALSE
	) IS
		cmethod_name VARCHAR2(60) := cpackage_name || '.ViewContract';
		vidclient    tclient.idclient%TYPE;
		vicon        VARCHAR2(25);
		vreadonly    NUMBER;
	BEGIN
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Contract No not defined');
		END IF;
		vreadonly := service.iif(preadonly OR getviewmode = viewmode_readonly, 1, 0);
		IF pinnewthread
		THEN
			vidclient := contract.getidclient(pcontractno);
			IF vidclient IS NULL
			   AND err.geterrorcode = err.contract_not_found
			THEN
			
				error.raisewhenerr();
			
			END IF;
			IF client.getclienttype(vidclient) = client.ct_persone
			THEN
				vicon := 'TWR_OPERCONTRACT2.GIF';
			ELSIF client.getclienttype(vidclient) = client.ct_company
			THEN
				vicon := 'TWR_CORPCONTRACT2.GIF';
			END IF;
			term.startthread('view Contract, No ' || pcontractno
							,vicon
							,'begin  Dialog.Exec(ContractDlg.DialogContract(''' || pcontractno ||
							 ''',' || to_char(vreadonly) || ')); end;');
		ELSE
			dialog.exec(contractdlg.dialogcontract(pcontractno, vreadonly));
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getuid(pcontractno tcontract.no%TYPE) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetUID';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vobjectuid NUMBER;
	BEGIN
	
		BEGIN
			SELECT objectuid
			INTO   vobjectuid
			FROM   tcontract
			WHERE  branch = cbranch
			AND    no = pcontractno;
		EXCEPTION
			WHEN no_data_found THEN
				NULL;
			WHEN OTHERS THEN
				RAISE;
		END;
	
		IF vobjectuid IS NULL
		THEN
			vobjectuid := updateobjectuid(pcontractno);
		END IF;
	
		RETURN vobjectuid;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE undolabel
	(
		pcontractno IN tcontract.no%TYPE
	   ,plabel      IN PLS_INTEGER
	   ,pmakelog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.UndoLabel';
		vcontract tcontract%ROWTYPE;
		vlabel    tadjpackrow.rollbackdata%TYPE;
		vmakelog  BOOLEAN := nvl(pmakelog, FALSE);
	
		PROCEDURE uchangecontracttype(pcontractno IN tcontract.no%TYPE) IS
			cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UChangeContractType';
			vcontrow typecontractparams;
		BEGIN
			vcontrow.type               := contractrb.getnvalue(ckey_contract_type);
			vcontrow.changeaccounttype  := (contractrb.getnvalue(ckey_change_acctype) = 1);
			vcontrow.checkidentacctype  := (contractrb.getnvalue(ckey_checkident_acctype) = 1);
			vcontrow.checkidenttieracc  := (contractrb.getnvalue(ckey_checkident_acctier) = 1);
			vcontrow.changecontracttype := TRUE;
			vcontrow.changecardstate    := FALSE;
			changecontracttype(pcontractno, vcontrow, TRUE, FALSE);
			s.say(cmethod_name || ': CT to ' || to_char(vcontrow.type) || ' changed successful'
				 ,csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE uchangecardstate
		(
			ppan      IN tcard.pan%TYPE
		   ,pmbr      IN tcard.mbr%TYPE
		   ,psignstat IN tcard.signstat%TYPE
		) IS
			cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UChangeCardState';
			vcardhandle NUMBER;
		BEGIN
			vcardhandle := card.newobject(ppan, pmbr, 'W');
			IF vcardhandle != 0
			THEN
				card.setsignstat(vcardhandle, psignstat, FALSE, 'Undo contract type change');
				card.writeobject(vcardhandle);
				card.freeobject(vcardhandle);
			ELSE
				error.raisewhenerr();
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE uchangecreatedate(pcontractno IN tcontract.no%TYPE) IS
			cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UChangeCreateDate';
			volddate             tcontract.createdate%TYPE;
			vchangeacccreatedate BOOLEAN;
		BEGIN
			volddate             := contractrb.getdvalue(ckey_createdate);
			vchangeacccreatedate := (contractrb.getnvalue(ckey_change_accdate) = 1);
			contracttools.changecreatedate(pcontractno, volddate, vchangeacccreatedate);
			s.say(cmethod_name || ': CD to ' || htools.d2s(volddate) || ' changed successful'
				 ,csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE uchangeidclient(pcontractno IN tcontract.no%TYPE) IS
			cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UChangeIdClient';
			voldidclient       NUMBER;
			vchangecardsclient BOOLEAN;
		BEGIN
			voldidclient       := contractrb.getnvalue(ckey_idclient);
			vchangecardsclient := (contractrb.getnvalue(ckey_change_cardsclient) = 1);
			changecontractidclient(pcontractno, voldidclient, vchangecardsclient, c_rollbackmode);
			s.say(cmethod_name || ': changed client to ' || to_char(voldidclient) || ' successful'
				 ,csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE ulinkcardcns IS
			cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.ULinkCardCNS';
			vpan          tcard.pan%TYPE;
			vmbr          tcard.mbr%TYPE;
			vidcardcns    NUMBER;
			vidcns_client NUMBER;
			vcardcnsrec   apitypes.typecardcnsrecord;
		BEGIN
			vpan        := contractrb.getcvalue(ckey_pan);
			vmbr        := contractrb.getnvalue(ckey_mbr);
			vidcardcns  := contractrb.getnvalue(ckey_cnsid);
			vcardcnsrec := cns.getcardcnsrec(vidcardcns);
			IF vcardcnsrec.pan = vpan
			   AND vcardcnsrec.mbr = vmbr
			THEN
				vidcns_client := vcardcnsrec.idcns;
			END IF;
			s.say(cmethod_name || ': delete card CNS ' || vidcardcns, csay_level);
			cns.deletecardcns(vidcardcns);
			s.say(cmethod_name || ': client CNS ' || vidcns_client, csay_level);
			IF vidcns_client IS NOT NULL
			THEN
				s.say(cmethod_name || ': delete client CNS ' || vidcns_client, csay_level);
				cns.deleteclientcnswithcheck(vidcns_client);
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE ulinkexistcard(pcontractno IN tcontract.no%TYPE) IS
			cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '. ULinkExistCard';
			vaccountno    taccount.accountno%TYPE;
			vdescription  tacc2card.description%TYPE;
			vidclient     NUMBER;
			vcontractno   tcontract.no%TYPE;
			vbranchpart   tcard.branchpart%TYPE;
			vcardrow      typecardparams;
			vacc2cardlink apitypes.typeaccount2cardrecord;
		BEGIN
			vcardrow.pan := contractrb.getcvalue(ckey_pan);
			vcardrow.mbr := contractrb.getnvalue(ckey_mbr);
			IF card.cardexists(vcardrow.pan, vcardrow.mbr)
			THEN
				vcardrow.itemcode := contractrb.getnvalue(ckey_itemcode);
				vaccountno        := contractrb.getcvalue(ckey_accountno);
				IF NOT account.accountexist(vaccountno)
				THEN
					error.raiseerror('Error unlinking card [' || card.getmaskedpan(vcardrow.pan) || '-' ||
									 vcardrow.mbr || '] from contract [' || pcontractno ||
									 '].~Impossible to create link to account [' || vaccountno ||
									 '] as account does not exist.');
				END IF;
				vdescription := contractrb.getcvalue(ckey_carddescr);
				vidclient    := contractrb.getnvalue(ckey_idclient);
				vcontractno  := contractrb.getcvalue(ckey_cono);
				vbranchpart  := contractrb.getnvalue(ckey_branchpart);
				s.say(cmethod_name || ': delete current primary link', csay_level);
				deleteprimarylink(vcardrow.pan, vcardrow.mbr, FALSE);
				s.say(cmethod_name || ': set link to old account ' || vaccountno, csay_level);
				card.createlinkaccount(vcardrow.pan
									  ,vcardrow.mbr
									  ,vaccountno
									  ,referenceacct_stat.stat_primary
									  ,vdescription);
				error.raisewhenerr();
				IF vcontractno IS NOT NULL
				THEN
					IF getcontractnobycard(vcardrow.pan, vcardrow.mbr, FALSE) IS NULL
					THEN
						addcontractitem(pcontractno, vcardrow);
						s.say(cmethod_name || ': link to old contract ' || vcontractno, csay_level);
					END IF;
				END IF;
				IF vidclient IS NOT NULL
				THEN
					s.say(cmethod_name || ': link to old client ' || vidclient, csay_level);
					changecardidclient(vcardrow.pan, vcardrow.mbr, vidclient);
				END IF;
				IF vbranchpart IS NOT NULL
				THEN
					s.say(cmethod_name || ': link to old BranchPart ' || vbranchpart, csay_level);
					changecardbranchpart(vcardrow.pan, vcardrow.mbr, vbranchpart);
				END IF;
				vacc2cardlink.accountno := contractrb.getnextcvalue(ckey_a2c_no);
				WHILE vacc2cardlink.accountno IS NOT NULL
				LOOP
					vacc2cardlink.acct_stat   := contractrb.getnextcvalue(ckey_a2c_stat);
					vacc2cardlink.description := contractrb.getnextcvalue(ckey_a2c_descr);
					vacc2cardlink.description := service.iif(vacc2cardlink.description = 'null'
															,''
															,vacc2cardlink.description);
					vacc2cardlink.limitgrpid  := contractrb.getnextnvalue(ckey_a2c_limitgrp);
					vacc2cardlink.limitgrpid  := service.iif(vacc2cardlink.limitgrpid = -1
															,NULL
															,vacc2cardlink.limitgrpid);
					card.createlinkaccount(vcardrow.pan
										  ,vcardrow.mbr
										  ,vacc2cardlink.accountno
										  ,vacc2cardlink.acct_stat
										  ,pdescription            => vacc2cardlink.description
										  ,plimitgrpid             => vacc2cardlink.limitgrpid
										  ,paddtocontract          => FALSE);
					vacc2cardlink.accountno := contractrb.getnextcvalue(ckey_a2c_no);
				END LOOP;
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE ulinklinkedcard(pcontractno IN tcontract.no%TYPE) IS
			cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '. ULinkLinkedCard';
			vidclient   NUMBER;
			vbranchpart tcard.branchpart%TYPE;
			vcardrow    typecardparams;
		BEGIN
			vcardrow.pan := contractrb.getcvalue(ckey_pan);
			vcardrow.mbr := contractrb.getnvalue(ckey_mbr);
			vidclient    := contractrb.getnvalue(ckey_idclient);
			vbranchpart  := contractrb.getnvalue(ckey_branchpart);
			IF vidclient IS NOT NULL
			THEN
				s.say(cmethod_name || ': link to old client ' || vidclient, csay_level);
				changecardidclient(vcardrow.pan, vcardrow.mbr, vidclient);
			END IF;
			IF vbranchpart IS NOT NULL
			THEN
				s.say(cmethod_name || ': link to old BranchPart ' || vbranchpart, csay_level);
				changecardbranchpart(vcardrow.pan, vcardrow.mbr, vbranchpart);
			END IF;
			deletecardfromcontract(pcontractno, vcardrow.pan, vcardrow.mbr, FALSE);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE ulinkexistaccount
		(
			pcontractno tcontract.no%TYPE
		   ,pmakelog    IN BOOLEAN := FALSE
		) IS
			cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '. ULinkExistAccount';
			vaccountno taccount.accountno%TYPE;
			vidclient  NUMBER;
			vmakelog   BOOLEAN := nvl(pmakelog, FALSE);
		BEGIN
			t.enter(cmethod_name
				   ,'pContractNo=' || pcontractno || ', pMakeLog=' || t.b2t(pmakelog)
				   ,csay_level);
			vaccountno := contractrb.getcvalue(ckey_accountno);
			vidclient  := contractrb.getnvalue(ckey_idclient);
			s.say(cmethod_name || ': unlink account: ' || vaccountno || ' from contract: ' ||
				  pcontractno
				 ,csay_level);
			deleteaccountfromcontract(pcontractno, vaccountno, pmakelog => vmakelog);
			IF vidclient IS NOT NULL
			THEN
				s.say(cmethod_name || ': change owner to: ' || vidclient || ' for account: ' ||
					  vaccountno
					 ,csay_level);
				changeaccountidclient(vaccountno, vidclient, vmakelog);
			END IF;
			t.leave(cmethod_name, plevel => csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name, plevel => csay_level);
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE undocreatecard(pcontractno tcontract.no%TYPE) IS
			cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '. UndoCreateCard';
			vpan tcard.pan%TYPE;
			vmbr tcard.mbr%TYPE;
		BEGIN
			vpan := contractrb.getcvalue(ckey_pan);
			vmbr := contractrb.getnvalue(ckey_mbr);
		
			IF getcontractnobycard(vpan, vmbr, FALSE) = pcontractno
			THEN
				s.say(cmethod_name || ': deleting card PAN=' || card.getmaskedpan(vpan) ||
					  ', MBR=' || vmbr || ' from contract ' || pcontractno
					 ,csay_level);
			
				IF card.deletecardcomplex(vpan, vmbr, FALSE, FALSE, FALSE)
				THEN
					NULL;
				END IF;
			
				error.raisewhenerr();
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE undocreateaccount
		(
			pcontractno tcontract.no%TYPE
		   ,pmakelog    IN BOOLEAN := FALSE
		) IS
			cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.UndoCreateAccount';
			vaccno   taccount.accountno%TYPE;
			vmakelog BOOLEAN := nvl(pmakelog, FALSE);
		BEGIN
			t.enter(cmethod_name
				   ,'pContractNo=' || pcontractno || ', pMakeLog=' || t.b2t(pmakelog)
				   ,csay_level);
			vaccno := contractrb.getcvalue(ckey_accountno);
			IF getcontractnobyaccno(vaccno, FALSE) = pcontractno
			THEN
				s.say(cmethod_name || ': deleting account vAccNo=' || vaccno || ' from contract ' ||
					  pcontractno
					 ,csay_level);
				deleteaccountfromcontract(pcontractno, vaccno, pmakelog => vmakelog);
				s.say(cmethod_name || ': deleting account vAccNo=' || vaccno, csay_level);
				account.deleteaccount(vaccno, FALSE);
				error.raisewhenerr();
			END IF;
			t.leave(cmethod_name, plevel => csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name, plevel => csay_level);
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE linkaccount
		(
			pcontractno tcontract.no%TYPE
		   ,pmakelog    IN BOOLEAN := FALSE
		) IS
			cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.LinkAccount';
			vitemrow tcontractitem%ROWTYPE;
			vmakelog BOOLEAN := nvl(pmakelog, FALSE);
		BEGIN
			t.enter(cmethod_name
				   ,'pContractNo=' || pcontractno || ', pMakeLog=' || t.b2t(pmakelog)
				   ,csay_level);
			vitemrow := contractaccountitem(pcontractno
										   ,contractrb.getnvalue(ckey_itemcode)
										   ,contractrb.getcvalue(ckey_accountno)
										   ,contractrb.getdvalue(ckey_actualdate));
		
			insertaccountitem(vitemrow, vmakelog);
			t.leave(cmethod_name, plevel => csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name, plevel => csay_level);
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE ucreatelinkedcontract(pcontractno tcontract.no%TYPE) IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.UCreateLinkedContract';
			vlinkedcontractno tcontract.no%TYPE;
		BEGIN
			t.enter(cmethod_name, 'pContractNo=' || pcontractno, csay_level);
			vlinkedcontractno := contractrb.getnextcvalue(ckey_linkedcontract);
			t.var('1. vLinkedContractNo', vlinkedcontractno, csay_level);
			WHILE vlinkedcontractno IS NOT NULL
			LOOP
				IF contractexists(vlinkedcontractno)
				THEN
					t.note('Save StoreState');
					contractrb.storestate(cmethod_name);
					deletecontract(vlinkedcontractno);
					t.note('Reload StoreState');
					contractrb.restorestate(cmethod_name);
				END IF;
			
				vlinkedcontractno := contractrb.getnextcvalue(ckey_linkedcontract);
				t.var('2. vLinkedContractNo', vlinkedcontractno, csay_level);
			END LOOP;
		
			t.leave(cmethod_name, plevel => csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE ulinkcardaccounts(pcontractno IN tcontract.no%TYPE) IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ULinkCardAccounts';
		
			vidclient NUMBER;
		
			vbranchpart   tcard.branchpart%TYPE;
			vcardrow      typecardparams;
			vacc2cardlink apitypes.typeaccount2cardrecord;
			vaction       PLS_INTEGER;
		BEGIN
			t.enter(cmethod_name, 'pContractNo=' || pcontractno, csay_level);
			vcardrow.pan := contractrb.getcvalue(ckey_pan);
			vcardrow.mbr := contractrb.getnvalue(ckey_mbr);
		
			IF card.cardexists(vcardrow.pan, vcardrow.mbr)
			THEN
				vacc2cardlink.accountno := contractrb.getnextcvalue(ckey_a2c_no);
				WHILE vacc2cardlink.accountno IS NOT NULL
				LOOP
					vacc2cardlink.acct_stat   := contractrb.getnextcvalue(ckey_a2c_stat);
					vacc2cardlink.description := contractrb.getnextcvalue(ckey_a2c_descr);
					vacc2cardlink.description := service.iif(vacc2cardlink.description = 'null'
															,''
															,vacc2cardlink.description);
					vacc2cardlink.limitgrpid  := contractrb.getnextnvalue(ckey_a2c_limitgrp);
					vacc2cardlink.limitgrpid  := service.iif(vacc2cardlink.limitgrpid = -1
															,NULL
															,vacc2cardlink.limitgrpid);
					vaction                   := contractrb.getnextnvalue(ckey_a2c_limitgrp);
					t.var('vAction', vaction);
					CASE vaction
						WHEN c_a2c_create THEN
							t.note(cmethod_name
								  ,'delete link to account: ' || vacc2cardlink.accountno
								  ,csay_level);
							card.deletelinkaccount(vcardrow.pan
												  ,vcardrow.mbr
												  ,vacc2cardlink.accountno
												  ,pcheckprimaryaccount => FALSE);
							error.raisewhenerr();
						WHEN c_a2c_delete THEN
							t.note(cmethod_name
								  ,'create link to account: ' || vacc2cardlink.accountno
								  ,csay_level);
							card.createlinkaccount(vcardrow.pan
												  ,vcardrow.mbr
												  ,vacc2cardlink.accountno
												  ,vacc2cardlink.acct_stat
												  ,vacc2cardlink.description
												  ,vacc2cardlink.limitgrpid
												  ,FALSE
												  ,paddtocontract => FALSE);
							error.raisewhenerr();
						WHEN c_a2c_update THEN
							t.note(cmethod_name
								  ,'update link to account: ' || vacc2cardlink.accountno
								  ,csay_level);
							card.createlinkaccount(vcardrow.pan
												  ,vcardrow.mbr
												  ,vacc2cardlink.accountno
												  ,vacc2cardlink.acct_stat
												  ,vacc2cardlink.description
												  ,vacc2cardlink.limitgrpid
												  ,FALSE
												  ,paddtocontract => FALSE);
							error.raisewhenerr();
						ELSE
							error.raiseerror('Undefined action: [' || vaction || ']');
					END CASE;
					card.createlinkaccount(vcardrow.pan
										  ,vcardrow.mbr
										  ,vacc2cardlink.accountno
										  ,vacc2cardlink.acct_stat
										  ,pdescription            => vacc2cardlink.description
										  ,plimitgrpid             => vacc2cardlink.limitgrpid
										  ,paddtocontract          => FALSE);
					vacc2cardlink.accountno := contractrb.getnextcvalue(ckey_a2c_no);
				END LOOP;
			
				vidclient := contractrb.getnvalue(ckey_idclient);
			
				vbranchpart := contractrb.getnvalue(ckey_branchpart);
			
				IF vidclient IS NOT NULL
				THEN
					s.say(cmethod_name || ': link to old client ' || vidclient, csay_level);
					changecardidclient(vcardrow.pan, vcardrow.mbr, vidclient);
				END IF;
				IF vbranchpart IS NOT NULL
				THEN
					s.say(cmethod_name || ': link to old BranchPart ' || vbranchpart, csay_level);
					changecardbranchpart(vcardrow.pan, vcardrow.mbr, vbranchpart);
				END IF;
			
			END IF;
			t.leave(cmethod_name, plevel => csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name, plevel => csay_level);
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE umovecardlink(pcontractno IN tcontract.no%TYPE) IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.UMoveCardLink';
		
			vcontractno tcontract.no%TYPE;
		
			vcard typecardparams;
		
		BEGIN
			t.enter(cmethod_name, 'pContractNo=' || pcontractno, csay_level);
		
			vcard.pan   := contractrb.getcvalue(ckey_pan);
			vcard.mbr   := contractrb.getnvalue(ckey_mbr);
			vcontractno := contractrb.getcvalue(ckey_cono);
			t.var('vContractNo', vcontractno);
		
			IF card.cardexists(vcard.pan, vcard.mbr)
			   AND getcontractnobycard(vcard.pan, vcard.mbr, FALSE) = pcontractno
			THEN
				IF vcontractno = 'null'
				THEN
					deletecardfromcontract(pcontractno, vcard.pan, vcard.mbr, FALSE);
				ELSIF contractexists(vcontractno)
				THEN
					deletecardfromcontract(pcontractno, vcard.pan, vcard.mbr, FALSE);
					vcard.itemcode := contractrb.getnvalue(ckey_itemcode);
					t.var('vCard.ItemCode', vcard.itemcode);
				
					IF vcard.itemcode != -1
					THEN
						addcontractitem(vcontractno, vcard);
					END IF;
				END IF;
			END IF;
		
			t.leave(cmethod_name, plevel => csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name, plevel => csay_level);
				error.save(cmethod_name);
				RAISE;
		END;
	
	BEGIN
		s.say(cmethod_name || ': start, pContractNo=' || pcontractno || ', pLabel=' ||
			  to_char(plabel) || ', pMakeLog=' || t.b2t(pmakelog)
			 ,csay_level);
		CASE plabel
			WHEN crl_change_contract_type THEN
				vcontract.no := contractrb.getcvalue(ckey_contract_no);
				IF vcontract.no != pcontractno
				THEN
					error.raiseerror('Error undoing label: ' || crl_change_contract_type ||
									 ' contract numbers do not match');
				END IF;
				uchangecontracttype(pcontractno);
			WHEN crl_change_card_state THEN
				vcontract.no := contractrb.getcvalue(ckey_contract_no);
				IF vcontract.no != pcontractno
				THEN
					error.raiseerror('Error undoing label: ' || crl_change_card_state ||
									 ', contract numbers do not match');
				END IF;
				DECLARE
					vpan      tcard.pan%TYPE;
					vmbr      tcard.mbr%TYPE;
					vsignstat tcard.signstat%TYPE;
					vposmbr   BINARY_INTEGER;
					vpospan   BINARY_INTEGER;
				BEGIN
					LOOP
						vlabel := contractrb.getnextcvalue(ckey_card_state);
						EXIT WHEN vlabel IS NULL;
						vpospan   := instr(vlabel, '<P>', 1);
						vposmbr   := instr(vlabel, '<M>', 1);
						vpan      := substr(vlabel, 1, vpospan - 1);
						vmbr      := substr(vlabel, vpospan + 3, vposmbr - vpospan - 3);
						vsignstat := substr(vlabel
										   ,vposmbr + 3
										   ,instr(vlabel, '<S>', 1) - vposmbr - 3);
						s.say(cmethod_name || ': vSignStat=' || vsignstat);
						uchangecardstate(vpan, vmbr, vsignstat);
					END LOOP;
				END;
			WHEN crl_change_finprofile THEN
				vcontract.no := contractrb.getcvalue(ckey_contract_no);
				IF vcontract.no != pcontractno
				THEN
					error.raiseerror('Error undoing label: ' || crl_change_finprofile ||
									 ' contract numbers do not match');
				END IF;
				vcontract.finprofile := contractrb.getnvalue(ckey_change_finprofile);
				setfinprofile(vcontract.no, vcontract.finprofile);
			WHEN crl_change_createdate THEN
				vcontract.no := contractrb.getcvalue(ckey_contract_no);
				IF vcontract.no != pcontractno
				THEN
					error.raiseerror('Error undoing label: ' || crl_change_createdate ||
									 ' contract numbers do not match');
				END IF;
				uchangecreatedate(vcontract.no);
			WHEN crl_change_idclient THEN
				vcontract.no := contractrb.getcvalue(ckey_contract_no);
				IF vcontract.no != pcontractno
				THEN
					error.raiseerror('Error undoing label: ' || crl_change_createdate ||
									 ' contract numbers do not match');
				END IF;
				uchangeidclient(vcontract.no);
			
			WHEN crl_change_contract_no THEN
			
				vcontract.objectuid := contractrb.getnvalue(ckey_modif_id);
				uchangecontractno(vcontract.objectuid);
			
			WHEN crl_create_cns THEN
				ulinkcardcns();
			WHEN crl_link_existcard THEN
				ulinkexistcard(pcontractno);
			WHEN crl_link_existacc THEN
				ulinkexistaccount(pcontractno, vmakelog);
			WHEN crl_create_newcard THEN
				undocreatecard(pcontractno);
			WHEN crl_link_linkedcard THEN
				ulinklinkedcard(pcontractno);
			WHEN crl_create_newaccount THEN
				undocreateaccount(pcontractno, vmakelog);
			WHEN contractaccounthistory.crl_added_in_history THEN
				contractaccounthistory.undolabel(pcontractno, plabel);
			WHEN contractaccounthistory.crl_resto_from_history THEN
				contractaccounthistory.undolabel(pcontractno, plabel);
			WHEN crl_unlink_existacc THEN
				linkaccount(pcontractno, vmakelog);
			WHEN crl_create_contract THEN
				ucreatelinkedcontract(pcontractno);
			WHEN crl_create_cardlink THEN
				ulinkcardaccounts(pcontractno);
			WHEN crl_move_cardlink THEN
				umovecardlink(pcontractno);
			ELSE
				error.raiseerror('Unknown label for undo');
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getfinprofilebyhandle(phandle IN NUMBER) RETURN tcontract.finprofile%TYPE IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetFinProfileByHandle';
	BEGIN
		s.say('Start ' || cmethod_name || ' pHandle=' || phandle, csay_level);
		IF testhandle(phandle, cmethod_name) != 'N'
		THEN
			s.say('Finish ' || cmethod_name || ', return FinProfile=' ||
				  to_char(scontractarray(phandle).contractrow.finprofile)
				 ,csay_level);
			RETURN scontractarray(phandle).contractrow.finprofile;
		ELSE
		
			error.raisewhenerr();
		
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ', error: ' || SQLERRM());
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getfinprofile(pcontractno IN tcontract.no%TYPE) RETURN tcontract.finprofile%TYPE IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetFinProfile';
		vhandle     NUMBER;
		vnew        BOOLEAN;
		vfinprofile tcontract.finprofile%TYPE;
	BEGIN
		s.say('Start ' || cmethod_name || ' pContractNo=' || pcontractno, csay_level);
		vhandle := gethandle(pcontractno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontractno, 'R');
			vnew    := TRUE;
		END IF;
		s.say(cmethod_name || ': vNew=' || htools.bool2str(vnew));
		vfinprofile := getfinprofilebyhandle(vhandle);
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
		s.say('Finish ' || cmethod_name, csay_level);
		RETURN vfinprofile;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ', error: ' || SQLERRM());
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getmemolist(pcontractno IN tcontract.no%TYPE) RETURN apitypes.typememolist IS
	BEGIN
		RETURN memo.getmemolist(object.gettype(object_name), pcontractno);
	END;

	PROCEDURE getdialogcontractnoproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetDialogContractNoProc';
	BEGIN
		CASE pwhat
			WHEN dialog.wtitempre THEN
				IF pitemname = 'GENERATOR'
				THEN
					DECLARE
					
						vcontract typecontractparams;
					
					BEGIN
						vcontract.type       := dialog.getnumber(pdialog, 'ContractType');
						vcontract.idclient   := dialog.getnumber(pdialog, 'IdClient');
						vcontract.branchpart := dialog.getnumber(pdialog, 'BranchPart');
						s.say(cmethod_name || ': BranchPart=' || vcontract.branchpart, csay_level);
						IF (vcontract.type IS NOT NULL AND vcontract.idclient IS NOT NULL)
						THEN
						
							/*    dialog.putchar(pdialog
                            ,'ContractNo'
                            ,contracttype.gencontractno(vcontract));*/
							NULL;
						END IF;
					END;
				END IF;
			WHEN dialog.wtdialogvalid THEN
				IF pcmd = dialog.cmok
				THEN
					IF dialog.getchar(pdialog, 'ContractNo') IS NULL
					THEN
						dialog.sethothint(pdialog, 'Value must be specified');
						dialog.goitem(pdialog, 'ContractNo');
					
					ELSIF upper(TRIM(dialog.getchar(pdialog, 'OldContractNo'))) =
						  upper(TRIM(dialog.getchar(pdialog, 'ContractNo')))
					THEN
						dialog.sethothint(pdialog, 'Specify new contract number');
						dialog.goitem(pdialog, 'ContractNo');
					
					END IF;
				END IF;
			ELSE
				NULL;
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ': general exception, ' || SQLERRM, csay_level);
			error.save(cmethod_name);
			error.showerror();
			dialog.cancelclose(pdialog);
	END;

	FUNCTION getdialogcontractno(pcontractno IN tcontract.no%TYPE) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetDialogContractNo';
		vdialog NUMBER;
		vhandle NUMBER;
		vnew    BOOLEAN;
	BEGIN
		vdialog := dialog.new('Specify new number', 0, 0, 30, 8, pextid => cmethod_name);
		dialog.hiddenchar(vdialog, 'OldContractNo');
		dialog.hiddennumber(vdialog, 'ContractType');
		dialog.hiddennumber(vdialog, 'IdClient');
		dialog.hiddennumber(vdialog, 'BranchPart');
		IF pcontractno IS NOT NULL
		THEN
			err.seterror(0, cmethod_name);
			vhandle := gethandle(pcontractno);
			IF vhandle IS NULL
			THEN
				vhandle := newobject(pcontractno, 'R');
			
				error.raisewhenerr();
			
				vnew := TRUE;
			
			END IF;
			dialog.putchar(vdialog, 'OldContractNo', scontractarray(vhandle).contractrow.no);
			dialog.putnumber(vdialog, 'ContractType', scontractarray(vhandle).contractrow.type);
			dialog.putnumber(vdialog, 'IdClient', scontractarray(vhandle).contractrow.idclient);
			dialog.putnumber(vdialog, 'BranchPart', scontractarray(vhandle).contractrow.branchpart);
		END IF;
		dialog.inputchar(vdialog
						,'ContractNo'
						,6
						,2
						,20
						,'Specify new contract number'
						,pmaxlen                      => 20
						,pcaption                     => 'No:');
		dialog.button(vdialog
					 ,'Generator'
					 ,27
					 ,2
					 ,1
					 ,'#'
					 ,0
					 ,0
					 ,'Generate new No'
					 ,cpackage_name || '.GetDialogContractNoProc');
		dialog.button(vdialog
					 ,'Ok'
					 ,4
					 ,4
					 ,10
					 ,'Enter'
					 ,dialog.cmok
					 ,0
					 ,'Change contract number to specified number');
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
		dialog.button(vdialog
					 ,'Cancel'
					 ,16
					 ,4
					 ,10
					 ,'Exit'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel changes and exit');
		dialog.setdialogvalid(vdialog, cpackage_name || '.GetDialogContractNoProc');
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION newcontractmodificationrecord
	(
		psourceno IN tcontractmodification.sourceno%TYPE := NULL
	   ,ptargetno IN tcontractmodification.targetno%TYPE := NULL
	   ,pkey      IN tcontractmodification.key%TYPE := 0
	   ,pbranch   IN tcontractmodification.branch%TYPE := NULL
	   ,pmodifid  IN tcontractmodification.modifid%TYPE := NULL
	) RETURN tcontractmodification%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.NewContractModificationRecord';
		vret tcontractmodification%ROWTYPE;
	BEGIN
		t.enter(cmethod_name);
		t.note(cmethod_name, 'pSourceNo=' || psourceno);
		t.note(cmethod_name, 'pTargetNo=' || ptargetno);
		t.note(cmethod_name, 'pKey=' || pkey);
		t.note(cmethod_name, 'pBranch=' || pbranch);
		t.note(cmethod_name, 'pModifId=' || pmodifid);
	
		vret.modifid  := pmodifid;
		vret.branch   := nvl(pbranch, seance.getbranch());
		vret.key      := nvl(pkey, 0);
		vret.sourceno := psourceno;
		vret.targetno := ptargetno;
	
		t.leave(cmethod_name);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE addcontractmodification(pmodifrec IN OUT tcontractmodification%ROWTYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddContractModification';
		vbranch NUMBER := seance.getbranch;
	BEGIN
		t.enter(cmethod_name
			   ,'SourceNo=' || pmodifrec.sourceno || ', TargetNo=' || pmodifrec.targetno ||
				', Branch=' || pmodifrec.branch);
		pmodifrec.branch := nvl(pmodifrec.branch, vbranch);
	
		pmodifrec.modifid := contractmodification_seq.nextval();
	
		INSERT INTO tcontractmodification VALUES pmodifrec;
	
		t.leave(cmethod_name, 'ModifId=' || pmodifrec.modifid);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION delcontractmodification(pmodifid IN tcontractmodification.modifid%TYPE) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DelContractModification';
	
		vret NUMBER;
	BEGIN
		t.enter(cmethod_name, 'pModifId=' || pmodifid);
		IF pmodifid IS NULL
		THEN
			error.raiseerror('Undefined identifier ModifId');
		END IF;
	
		DELETE FROM tcontractmodification WHERE modifid = pmodifid;
	
		vret := SQL%ROWCOUNT;
	
		t.leave(cmethod_name, 'deleted rows: ' || vret);
		RETURN vret;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcontractmodificationrecord
	(
		pmodifrec    IN tcontractmodification%ROWTYPE
	   ,pmodiffilter IN VARCHAR2
	) RETURN tcontractmodification%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractModificationRecord';
		vrec    tcontractmodification%ROWTYPE;
		vbranch NUMBER;
	BEGIN
		t.enter(cmethod_name, 'pModifFilter=' || pmodiffilter);
		vbranch := nvl(pmodifrec.branch, seance.getbranch());
		CASE pmodiffilter
			WHEN cmodiffilter_byid THEN
				SELECT * INTO vrec FROM tcontractmodification WHERE modifid = pmodifrec.modifid;
			WHEN cmodiffilter_bysourceno THEN
				SELECT *
				INTO   vrec
				FROM   tcontractmodification
				WHERE  sourceno = pmodifrec.sourceno
				AND    key = pmodifrec.key
				AND    branch = vbranch;
			WHEN cmodiffilter_bytargetno THEN
				SELECT *
				INTO   vrec
				FROM   tcontractmodification
				WHERE  sourceno = pmodifrec.targetno
				AND    key = pmodifrec.key
				AND    branch = vbranch;
			ELSE
				error.raiseerror('Undefined selection mode: ' || pmodiffilter);
		END CASE;
		t.leave(cmethod_name, 'SourceNo=' || vrec.sourceno || ', TargetNo=' || vrec.targetno);
		RETURN vrec;
	EXCEPTION
		WHEN no_data_found THEN
			RETURN vrec;
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getmodificationbyid(pmodifid IN tcontractmodification.modifid%TYPE)
		RETURN tcontractmodification%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetModificationById';
		vrec tcontractmodification%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, 'pModifId=' || pmodifid);
		IF pmodifid IS NULL
		THEN
			error.raiseerror('Undefined identifier ModifId');
		END IF;
		vrec := newcontractmodificationrecord(pmodifid => pmodifid);
		vrec := getcontractmodificationrecord(vrec, cmodiffilter_byid);
	
		IF vrec.modifid IS NULL
		THEN
			error.raiseerror('contains no record with ID ModifId=' || pmodifid);
		END IF;
		t.leave(cmethod_name, 'SoourceNo=' || vrec.sourceno || ', TargetNo=' || vrec.targetno);
		RETURN vrec;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getmodificationbysourceno
	(
		psourceno IN tcontractmodification.sourceno%TYPE
	   ,pkey      IN tcontractmodification.key%TYPE := 0
	) RETURN tcontractmodification%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetModificationBySourceNo';
		vrec tcontractmodification%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, 'pSourceNo=' || psourceno || ', pKey=' || pkey);
		IF psourceno IS NULL
		THEN
			error.raiseerror('Source contract number not specified');
		END IF;
		IF pkey IS NULL
		THEN
			error.raiseerror('Subsystem ID not defined');
		END IF;
		vrec := newcontractmodificationrecord(psourceno => psourceno, pkey => pkey);
		vrec := getcontractmodificationrecord(vrec, cmodiffilter_bysourceno);
	
		t.leave(cmethod_name, 'ModifIdNo=' || vrec.modifid || ', TargetNo=' || vrec.targetno);
		RETURN vrec;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getmodificationbytargetno
	(
		ptargetno IN tcontractmodification.targetno%TYPE
	   ,pkey      IN tcontractmodification.key%TYPE := 0
	) RETURN tcontractmodification%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetModificationByTargetNo';
		vrec tcontractmodification%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, 'pTargetNo=' || ptargetno || ',pKey=' || pkey);
		IF ptargetno IS NULL
		THEN
			error.raiseerror('New contract number not specified');
		END IF;
		IF pkey IS NULL
		THEN
			error.raiseerror('Subsystem ID not defined');
		END IF;
		vrec := newcontractmodificationrecord(ptargetno => ptargetno, pkey => pkey);
		vrec := getcontractmodificationrecord(vrec, cmodiffilter_bytargetno);
	
		t.leave(cmethod_name, 'ModifIdNo=' || vrec.modifid || ', TargetNo=' || vrec.targetno);
		RETURN vrec;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE changecontractno
	(
		poldcontractno IN tcontract.no%TYPE
	   ,pnewcontractno IN tcontract.no%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeContractNo[1]';
		vhandle                  NUMBER;
		vnew                     BOOLEAN;
		vcontractrow             tcontract%ROWTYPE;
		vuserattributeslist      apitypes.typeuserproplist;
		vextrauserattributeslist apitypes.typeuserproplist;
		volduid                  NUMBER;
		vapayments               apipayment.typestandingorderlist;
	BEGIN
		s.say(cmethod_name || ' start, pOldContractNo=[' || poldcontractno ||
			  '], pNewContractNo=[' || pnewcontractno || ']'
			 ,csay_level);
	
		IF poldcontractno IS NULL
		THEN
			error.raiseerror('Source contract number not specified');
		END IF;
	
		vcontractrow := getcontractrowtype(poldcontractno);
	
		vcontractrow.no := TRIM(pnewcontractno);
		IF vcontractrow.no IS NULL
		THEN
			error.raiseerror('New contract number not specified');
		END IF;
	
		IF upper(vcontractrow.no) = upper(poldcontractno)
		THEN
			error.raiseerror('New contract number identical to previous one');
		END IF;
	
		checkincorrectno(vcontractrow.no);
	
		err.seterror(0, cmethod_name);
		s.say(cmethod_name || ', Point 1', csay_level);
		vhandle := gethandle(poldcontractno);
		IF vhandle IS NULL
		THEN
			s.say(cmethod_name || ', Point 2', csay_level);
			vhandle := newobject(poldcontractno, 'W');
			error.raisewhenerr();
			vnew := TRUE;
		ELSE
			s.say(cmethod_name || ', Point 3', csay_level);
			IF scontractarray(vhandle).contractmode != 'W'
			THEN
				changeobjectmode(vhandle, 'W');
				error.raisewhenerr();
			END IF;
		END IF;
		vcontractrow        := getobject(vhandle);
		volduid             := vcontractrow.objectuid;
		vuserattributeslist := objuserproperty.getrecord(object_name, volduid);
		s.say(cmethod_name || ': vUserAttributesList.Count=' || vuserattributeslist.count
			 ,csay_level);
		vextrauserattributeslist := objuserproperty.getrecord(object_name
															 ,volduid
															 ,psubobject => to_char(vcontractrow.type));
		s.say(cmethod_name || ': vExtraUserAttributesList.Count=' ||
			  vextrauserattributeslist.count
			 ,csay_level);
	
		vcontractrow.no := TRIM(pnewcontractno);
		s.say(cmethod_name || ', Point 4', csay_level);
	
		BEGIN
			SAVEPOINT changecono;
			vcontractrow.objectuid := objectuid.newuid(object_name
													  ,vcontractrow.no
													  ,pnocommit => TRUE);
			s.say(cmethod_name || ', Point 45: vContractRow.Objectuid=' || vcontractrow.objectuid
				 ,csay_level);
			s.say(cmethod_name || ', Point 6', csay_level);
			addcontractrow(vcontractrow);
			s.say(cmethod_name || ', Point 5', csay_level);
			contracttypeschema.changecontractno(poldcontractno, vcontractrow.no, vcontractrow.type);
		
			t.note(cmethod_name, 'exploring reserve...', csay_level);
		
			IF contractschemas.existsmethod('Reserve', 'CHANGECONTRACTNO', '/in:V/in:V/ret:E')
			THEN
				EXECUTE IMMEDIATE 'BEGIN RESERVE.CHANGECONTRACTNO(:OLDNO,:NEWNO); END;'
					USING poldcontractno, vcontractrow.no;
			END IF;
		
			t.note(cmethod_name, 'changing No for contract items', csay_level);
		
			UPDATE tcontractitem
			SET    no = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    no = poldcontractno;
			s.say(cmethod_name || ', Point 8', csay_level);
		
			UPDATE tcontractcarditem
			SET    no = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    no = poldcontractno;
			s.say(cmethod_name || ', Point 8.1', csay_level);
		
			UPDATE tcontractacchistory
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
			s.say(cmethod_name || ', Point 8.2', csay_level);
		
			UPDATE tcontractparameters
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
			s.say(cmethod_name || ', Point 9', csay_level);
		
			UPDATE tcontractparametershistory
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
		
			UPDATE tcontractparameterslog
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
		
			UPDATE tcontractprolongation
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
		
			UPDATE tcontractrollback
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
		
			UPDATE tcontractctrldate
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
		
			UPDATE tcontractstatus
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
			s.say(cmethod_name || ', Point 10', csay_level);
		
			UPDATE tcontractstatushistory
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
		
			UPDATE tcoverage2contract
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
			s.say(cmethod_name || ', Point 11', csay_level);
		
			UPDATE tgrouprisk
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
			s.say(cmethod_name || ', Point 12', csay_level);
		
			UPDATE tstatement
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
			s.say(cmethod_name || ', Point 13', csay_level);
		
			UPDATE ttastamentcontract
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
		
			UPDATE twarrantcontract
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
		
			UPDATE tmemo
			SET    keyobject = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    typeobject = object.gettype(object_name)
			AND    keyobject = poldcontractno;
		
			UPDATE tobjectlog
			SET    keyobject = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    typeobject = object.gettype(object_name)
			AND    keyobject = poldcontractno;
		
			UPDATE tadjpackrow
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
		
			UPDATE tcontractoplog
			SET    contractno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    contractno = poldcontractno;
		
			UPDATE tpercentbelong
			SET    objectno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    objectno = poldcontractno;
		
			UPDATE tpercentname
			SET    objectno = vcontractrow.no
			WHERE  branch = vcontractrow.branch
			AND    objectno = poldcontractno
			AND    category = referenceprchistory.ccontract;
		
			s.say(cmethod_name || ', Point 14', csay_level);
			objuserproperty.saverecord(object_name
									  ,vcontractrow.objectuid
									  ,vuserattributeslist
									  ,plog_type              => object.gettype(object_name)
									  ,plog_key               => vcontractrow.no
									  ,plog_clientid          => vcontractrow.idclient);
			s.say(cmethod_name || ', Point 14_1', csay_level);
			objuserproperty.deleterecord(object_name
										,volduid
										,plog_type     => object.gettype(object_name)
										,plog_key      => poldcontractno
										,plog_clientid => vcontractrow.idclient);
			s.say(cmethod_name || ', Point 14_2', csay_level);
			objuserproperty.saverecord(object_name
									  ,vcontractrow.objectuid
									  ,vextrauserattributeslist
									  ,psubobject               => to_char(vcontractrow.type)
									  ,plog_type                => object.gettype(object_name)
									  ,plog_key                 => vcontractrow.no
									  ,plog_clientid            => vcontractrow.idclient);
			s.say(cmethod_name || ', Point 14_3', csay_level);
			objuserproperty.deleterecord(object_name
										,volduid
										,psubobject    => to_char(vcontractrow.type)
										,plog_type     => object.gettype(object_name)
										,plog_key      => poldcontractno
										,plog_clientid => vcontractrow.idclient);
			s.say(cmethod_name || ', Point 14_4', csay_level);
		
			fincontractinstance.copyfinprofile(poldcontractno, vcontractrow.no);
			fincontractinstance.deleteinstance(poldcontractno);
		
			vapayments := standingorder.getstandingordersbycontractno(poldcontractno);
			FOR i IN 1 .. vapayments.count
			LOOP
				vapayments(i).opercontractno := vcontractrow.no;
				standingorder.modifystandingorder(vapayments(i));
			END LOOP;
		
			IF vnew
			THEN
				s.say(cmethod_name || ', Point 15', csay_level);
				freeobject(vhandle);
			ELSE
				s.say(cmethod_name || ', Point 16', csay_level);
				scontractarray(vhandle).contractrow := vcontractrow;
				setcurrentno(vcontractrow.no);
				IF scontractarray(vhandle).contractmode = 'W'
				THEN
					object.release(contract.object_name, poldcontractno);
				
					IF NOT object.setlock(object_name, vcontractrow.no)
					THEN
						error.raiseerror(err.contract_busy, capturedobjectinfo(vcontractrow.no));
					END IF;
				
				END IF;
			
			END IF;
		
			DELETE FROM tcontract
			WHERE  branch = vcontractrow.branch
			AND    no = poldcontractno;
			s.say(cmethod_name || ', Point 17', csay_level);
		
			a4mlog.cleanparamlist;
			a4mlog.addparamrec(clogparam_contractno, poldcontractno, vcontractrow.no);
			a4mlog.logobject(object.gettype(object_name)
							,vcontractrow.no
							,'Contract No changed: ' || poldcontractno || '->' || vcontractrow.no
							,a4mlog.act_change
							,a4mlog.putparamlist
							,powner => vcontractrow.idclient);
			s.say(cmethod_name || ': done', csay_level);
		EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK TO changecono;
				RAISE;
		END;
	EXCEPTION
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION changecontractno
	(
		poldcontractno IN tcontract.no%TYPE
	   ,pnewcontractno IN tcontract.no%TYPE
	   ,pkey           IN tcontractmodification.key%TYPE := 0
	) RETURN tcontractmodification.modifid%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeContractNo[2]';
		vmodifrec tcontractmodification%ROWTYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pOldContractNo=[' || poldcontractno || '], pNewContractNo=[' || pnewcontractno ||
				'], pKey=[' || pkey || ']');
		changecontractno(poldcontractno, pnewcontractno);
		vmodifrec := newcontractmodificationrecord(poldcontractno, pnewcontractno, pkey);
		addcontractmodification(vmodifrec);
	
		contractrb.setlabel(crl_change_contract_no);
		contractrb.setnvalue(ckey_modif_id, vmodifrec.modifid);
	
		t.leave(cmethod_name);
		RETURN vmodifrec.modifid;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE uchangecontractno(pmodifid IN tcontractmodification.modifid%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.UChangeContractNo';
		vmodifrec tcontractmodification%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, 'pModifId=[' || pmodifid || ']');
		vmodifrec := getmodificationbyid(pmodifid);
		changecontractno(vmodifrec.targetno, vmodifrec.sourceno);
		IF delcontractmodification(pmodifid) <= 0
		THEN
			error.raiseerror('Error deleting record with ID: ' || pmodifid);
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION hascardsinstate(pcontractno IN tcontract.no%TYPE) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.HasCardsInState';
		vaselsign types.arrnum;
		vacard    apitypes.typecardlist;
	BEGIN
		vaselsign := contractschemas.getcardstates(contracttype.getschemapackage(contract.gettype(pcontractno))
												  ,TRUE);
	
		vacard := getcardlist(pcontractno);
		FOR i IN 1 .. vacard.count
		LOOP
			IF (vaselsign.exists(vacard(i).a4mstat))
			THEN
				RETURN TRUE;
			END IF;
		END LOOP;
	
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END hascardsinstate;

	PROCEDURE setsubstatusbyhandle
	(
		phandle    IN NUMBER
	   ,psubstatus IN tcontract.substatus%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.SetSubStatus';
	
	BEGIN
		s.say(cmethod_name || ': pHandle= ' || phandle || ', pSubStatus=' || psubstatus);
	
		IF scontractarray.exists(phandle)
		THEN
			scontractarray(phandle).contractrow.substatus := psubstatus;
		ELSE
			error.raiseerror('Handle ' || phandle || ' not found!');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setsubstatus
	(
		pno        IN tcontract.no%TYPE
	   ,psubstatus IN tcontract.substatus%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetSubStatus';
		vhandle NUMBER;
		vnew    BOOLEAN;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
		vhandle := gethandle(pno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pno, 'R');
			vnew    := TRUE;
		END IF;
	
		setsubstatusbyhandle(vhandle, psubstatus);
		writeobject(vhandle);
	
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getsubstatusbyhandle(phandle IN NUMBER) RETURN tcontract.substatus%TYPE IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetSubStatusByHandle';
	BEGIN
		s.say('Start ' || cmethod_name || ' pHandle=' || phandle, csay_level);
		IF testhandle(phandle, cmethod_name) != 'N'
		THEN
			s.say('Finish ' || cmethod_name || ', return SubStatus=' || scontractarray(phandle)
				  .contractrow.substatus
				 ,csay_level);
			RETURN scontractarray(phandle).contractrow.substatus;
		ELSE
			error.raisewhenerr();
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ', error: ' || SQLERRM());
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getsubstatus(pcontractno IN tcontract.no%TYPE) RETURN tcontract.substatus%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetSubStatus';
		cpref        CONSTANT VARCHAR2(10) := '';
		vsubstatus tcontract.substatus%TYPE := NULL;
		vhandle    NUMBER;
		vnew       BOOLEAN;
	BEGIN
		s.say(cpref || 'Enter ' || cmethod_name, csay_level);
		vhandle := gethandle(pcontractno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontractno, 'R');
			vnew    := TRUE;
		END IF;
		s.say(cmethod_name || ': vNew=' || htools.bool2str(vnew));
		vsubstatus := getsubstatusbyhandle(vhandle);
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
		s.say(cpref || 'Leave ' || cmethod_name || ' with ' || vsubstatus, csay_level);
		RETURN vsubstatus;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ', error: ' || SQLERRM());
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getguid(pcontractno IN tcontract.no%TYPE) RETURN types.guid IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetGUID';
	BEGIN
		RETURN objectuid.getguid(getuid(pcontractno));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcontractrecordbyguid(pguid types.guid) RETURN apitypes.typecontractrecord IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractRecordByGUID';
		vobjectuid objectuid.typeobjectuid;
		vno        tcontract.no%TYPE;
	BEGIN
		vobjectuid := objectuid.getuidbyguid(pguid);
		SELECT no INTO vno FROM tcontract WHERE objectuid = vobjectuid;
		RETURN getcontractrecord(vno);
	EXCEPTION
		WHEN no_data_found THEN
			error.save(cmethod_name);
			error.raiseerror(err.contract_not_found
							,'(GUID: ' || service.guid2str(pguid) || ', ObjectUID: ' ||
							 to_char(vobjectuid) || ')');
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcontractrecordbyuid(pobjectuid objectuid.typeobjectuid)
		RETURN apitypes.typecontractrecord IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractRecordByUID';
		vno tcontract.no%TYPE;
	BEGIN
		SELECT no INTO vno FROM tcontract WHERE objectuid = pobjectuid;
		RETURN getcontractrecord(vno);
	EXCEPTION
		WHEN no_data_found THEN
			error.save(cmethod_name);
			error.raiseerror(err.contract_not_found, '(ObjectUID: ' || to_char(pobjectuid) || ')');
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setstatus
	(
		pcontractno IN tcontract.no%TYPE
	   ,pstatus     IN tcontract.status%TYPE
	   ,plog        IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetStatus[4]';
		vhandle      NUMBER;
		vnew         BOOLEAN;
		voldstatus   tcontract.status%TYPE;
		vcontractrow tcontract%ROWTYPE;
		vflag        NUMBER;
		von          BOOLEAN;
		vret         NUMBER;
		vstatus      tcontract.status%TYPE;
	BEGIN
		s.say(cmethod_name || ': enter ', csay_level);
	
		vhandle := gethandle(pcontractno);
		IF vhandle IS NULL
		THEN
			vhandle := newobject(pcontractno, 'R');
			vnew    := TRUE;
		END IF;
		voldstatus := scontractarray(vhandle).contractrow.status;
		vstatus    := rpad(nvl(pstatus, ' '), 4, ' ');
		IF nvl(voldstatus, 'null') != vstatus
		THEN
			vcontractrow := scontractarray(vhandle).contractrow;
			FOR i IN 1 .. length(substr(vstatus, 1, 4))
			LOOP
				IF nvl(substr(voldstatus, i, 1), '^') != substr(vstatus, i, 1)
				THEN
					vflag := getstatusflag(i);
					IF TRIM(substr(vstatus, i, 1)) IS NOT NULL
					THEN
						von := TRUE;
					ELSE
						von := FALSE;
					END IF;
					vret := setstatusbyhandle(vhandle, vflag, von, FALSE);
				END IF;
			END LOOP;
			IF plog
			THEN
				a4mlog.cleanparamlist;
				a4mlog.addparamrec(clogparam_status
								  ,getstatusname(voldstatus)
								  ,getstatusname(vstatus));
				IF a4mlog.logobject(object.gettype(object_name)
								   ,scontractarray(vhandle).contractrow.no
								   ,'Changed status: "' || getstatusname(voldstatus) || '" -> "' ||
									getstatusname(vstatus) || '"'
								   ,a4mlog.act_change
								   ,a4mlog.putparamlist
								   ,powner => scontractarray(vhandle).contractrow.idclient) != 0
				THEN
					error.raisewhenerr();
				END IF;
			END IF;
			writeobject(vhandle);
		END IF;
		IF vnew
		THEN
			freeobject(vhandle);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			IF vnew
			THEN
				freeobject(vhandle);
			END IF;
			IF vcontractrow.no IS NOT NULL
			THEN
				scontractarray(vhandle).contractrow := vcontractrow;
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE refreshuserattributes
	(
		pcontractno IN tcontract.no%TYPE
	   ,plist       IN apitypes.typeuserproplist
	) IS
		vobjectuid objectuid.typeobjectuid;
		vlist      apitypes.typeuserproplist;
	BEGIN
		IF scontdlg IS NOT NULL
		THEN
			vobjectuid := getuid(pcontractno);
			vlist      := getcurrentdlguserattributes();
			objuserpropertykernel.concatproplist_(vlist, plist);
			objuserproperty.fillpage(scontdlg
									,object_name
									,vlist
									,plog_clientid => getclientid(pcontractno));
		END IF;
	END;

	PROCEDURE refreshuserattribute
	(
		pcontractno IN tcontract.no%TYPE
	   ,pfieldname  VARCHAR2
	) IS
		vobjectuid objectuid.typeobjectuid;
		vlist      apitypes.typeuserproplist;
		pattribute apitypes.typeuserproprecord;
	BEGIN
		IF scontdlg IS NOT NULL
		THEN
			vobjectuid := getuid(pcontractno);
			vlist      := getcurrentdlguserattributes();
			pattribute := objuserproperty.getfield(object_name, vobjectuid, pfieldname);
			objuserpropertykernel.setprop_(vlist, pattribute);
			objuserproperty.fillpage(scontdlg
									,object_name
									,vlist
									,plog_clientid => getclientid(pcontractno));
		END IF;
	END;

	FUNCTION getcurrdlgextrauserattributes RETURN apitypes.typeuserproplist IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCurrDlgExtraUserAttributes';
	BEGIN
		RETURN objuserproperty.getpagedata(scontdlg, object_name, getcurrentcontracttype());
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getextrauserattributerecord
	(
		pcontractno IN VARCHAR2
	   ,pfieldname  VARCHAR2
	) RETURN apitypes.typeuserproprecord IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetExtraUserAttributeRecord';
	BEGIN
		RETURN objuserproperty.getfield(pobject    => object_name
									   ,powneruid  => getuid(pcontractno)
									   ,pfieldname => pfieldname
									   ,psubobject => to_char(gettype(pcontractno)));
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getextrauserattributeslist(pcontractno IN VARCHAR2) RETURN apitypes.typeuserproplist IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetExtraUserAttributesList';
		vuserattributeslist apitypes.typeuserproplist;
	BEGIN
		vuserattributeslist := objuserproperty.getrecord(object_name
														,getuid(pcontractno)
														,psubobject => to_char(gettype(pcontractno)));
		RETURN vuserattributeslist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE saveextrauserattributeslist
	(
		pcontractno         IN tcontract.no%TYPE
	   ,plist               IN apitypes.typeuserproplist
	   ,pclearpropnotinlist BOOLEAN
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SaveExtraUserAttributesList';
		cobjecttype  CONSTANT NUMBER := object.gettype(object_name);
		vobjectuid objectuid.typeobjectuid;
	BEGIN
		t.enter(cmethod_name);
		vobjectuid := getuid(pcontractno);
		objuserproperty.saverecord(pobject             => object_name
								  ,powneruid           => vobjectuid
								  ,pdata               => plist
								  ,pclearpropnotinlist => pclearpropnotinlist
								  ,psubobject          => to_char(gettype(pcontractno))
								  ,plog_type           => cobjecttype
								  ,plog_key            => pcontractno
								  ,plog_clientid       => getclientid(pcontractno));
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE refreshextrauserattributes
	(
		pcontractno IN tcontract.no%TYPE
	   ,plist       IN apitypes.typeuserproplist
	) IS
	
		vlist apitypes.typeuserproplist;
	BEGIN
		IF scontdlg IS NOT NULL
		THEN
		
			vlist := getcurrdlgextrauserattributes();
			objuserpropertykernel.concatproplist_(vlist, plist);
			objuserproperty.fillpage(scontdlg
									,object_name
									,vlist
									,psubobject    => to_char(gettype(pcontractno))
									,plog_clientid => getclientid(pcontractno));
		END IF;
	END;

	PROCEDURE refreshextrauserattribute
	(
		pcontractno IN tcontract.no%TYPE
	   ,pfieldname  VARCHAR2
	) IS
		vobjectuid objectuid.typeobjectuid;
		vlist      apitypes.typeuserproplist;
		pattribute apitypes.typeuserproprecord;
		vtype      tcontract.type%TYPE;
	BEGIN
		IF scontdlg IS NOT NULL
		THEN
			vobjectuid := getuid(pcontractno);
			vtype      := gettype(pcontractno);
			vlist      := getcurrdlgextrauserattributes();
			pattribute := objuserproperty.getfield(object_name
												  ,vobjectuid
												  ,pfieldname
												  ,psubobject => to_char(vtype));
			objuserpropertykernel.setprop_(vlist, pattribute);
			objuserproperty.fillpage(scontdlg
									,object_name
									,vlist
									,psubobject    => to_char(vtype)
									,plog_clientid => getclientid(pcontractno));
		END IF;
	END;

	PROCEDURE setactualdate
	(
		pkey        IN tcontractitem.key%TYPE
	   ,pactualdate IN DATE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetActualDate';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		s.say(cmethod_name || ': begining [pKey=' || pkey || ', pActualDate=' || pactualdate
			 ,csay_level);
		UPDATE tcontractitem
		SET    actualdate = pactualdate
		WHERE  branch = vbranch
		AND    key = pkey;
		s.say(cmethod_name || ': ended, updated ' || SQL%ROWCOUNT, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getactualdate(pkey IN tcontractitem.key%TYPE) RETURN DATE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetActualDate';
		vbranch NUMBER := seance.getbranch();
		vret    DATE;
	BEGIN
		s.say(cmethod_name || ': begining [pKey=' || pkey, csay_level);
		BEGIN
			SELECT actualdate
			INTO   vret
			FROM   tcontractitem
			WHERE  branch = vbranch
			AND    key = pkey;
		EXCEPTION
			WHEN no_data_found THEN
				error.raiseerror(err.contract_item_not_found);
		END;
		IF vret IS NULL
		THEN
			vret := account.getaccountrecord(pkey).createdate;
			setactualdate(pkey, vret);
		END IF;
		s.say(cmethod_name || ': ended, vRet=' || vret, csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION loadaccount
	(
		paccountno   IN taccount.accountno%TYPE
	   ,pdoexception IN BOOLEAN := TRUE
	) RETURN typeaccountrow IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.LoadAccount';
		vaccount typeaccountrow;
		vbranch  NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethod_name, 'pAccountNo=' || paccountno, csay_level);
		BEGIN
			SELECT t1.key
				  ,t1.itemcode
				  ,t2.description
				  ,t1.actualdate
				  ,t1.itemdescr
			INTO   vaccount.accountno
				  ,vaccount.itemcode
				  ,vaccount.description
				  ,vaccount.actualdate
				  ,vaccount.accitemdescr
			FROM   tcontractitem t1
			INNER  JOIN tcontracttypeitems t2
			ON     t2.branch = t1.branch
			AND    t2.itemcode = t1.itemcode
			AND    t2.itemtype = t1.itemtype
			WHERE  t1.branch = vbranch
			AND    t1.key = paccountno;
		EXCEPTION
			WHEN no_data_found THEN
				IF nvl(pdoexception, TRUE)
				THEN
					error.raiseerror('Account with number [' || paccountno || '] not found');
				END IF;
			
			WHEN OTHERS THEN
				RAISE;
		END;
		t.leave(cmethod_name
			   ,'vAccount.No=' || vaccount.accountno || ', vAccount.ItemCode=' ||
				vaccount.itemcode || ', vAccount.Description=' || vaccount.description
			   ,plevel => csay_level);
		RETURN vaccount;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getaccountdescription
	(
		paccountno   IN taccount.accountno%TYPE
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN tcontractitem.itemdescr%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetAccountDescription';
		vaccount typeaccountrow;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pAccountNo=' || paccountno || ', pDoException=' || t.b2t(pdoexception)
			   ,csay_level);
		IF paccountno IS NULL
		THEN
			error.raiseerror('Account No not specified');
		END IF;
		vaccount := loadaccount(paccountno, nvl(pdoexception, FALSE));
		t.leave(cmethod_name
			   ,'vAccount.No=' || vaccount.accountno || ', vAccount.AccItemDescr=' ||
				vaccount.accitemdescr || ', vAccount.Description=' || vaccount.description
			   ,plevel => csay_level);
		RETURN nvl(vaccount.accitemdescr, vaccount.description);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE checkcontractno(pcontractno IN tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CheckContractNo';
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno, csay_level);
	
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Contract No not defined!');
		END IF;
	
		IF NOT contractexists(pcontractno)
		THEN
			error.raiseerror('Contract with No [' || pcontractno || '] does not exist!');
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END checkcontractno;

	FUNCTION existscontractbyitemname
	(
		pcontracttype IN tcontracttype.type%TYPE
	   ,pitemname     IN tcontracttypeitemname.itemname%TYPE
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExistsContractByItemName';
		vret    BOOLEAN;
		vcount  NUMBER;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethod_name
			   ,'pContractType=' || pcontracttype || ', pItemName=' || pitemname
			   ,csay_level);
	
		SELECT COUNT(t1.no)
		INTO   vcount
		FROM   tcontract t1
		INNER  JOIN tcontractitem t2
		ON     t2.branch = t1.branch
		AND    t2.no = t1.no
		INNER  JOIN tcontracttypeitemname t3
		ON     t3.branch = t1.branch
		AND    t3.contracttype = t1.type
		AND    t3.itemcode = t2.itemcode
		WHERE  t1.branch = vbranch
		AND    t1.type = pcontracttype
		AND    t3.itemname = upper(pitemname);
	
		t.var('vCount', vcount);
		vret := vcount > 0;
	
		t.leave(cmethod_name, 'vRet=' || t.b2t(vret), csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getlaststatuschange
	(
		pcontractno IN tcontract.no%TYPE
	   ,pstatid     IN NUMBER
	   ,pdate       IN DATE := NULL
	) RETURN tcontractstatushistory%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetLastStatusChange';
		vbranch NUMBER := seance.getbranch();
		vdate   DATE := nvl(pdate, seance.getoperdate());
		vresult tcontractstatushistory%ROWTYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pStatId=' || pstatid || ', pDate=' || pdate);
		checkcontractno(pcontractno);
	
		IF pstatid = contract.stat_ok
		THEN
			SELECT *
			INTO   vresult
			FROM   (SELECT *
					FROM   tcontractstatushistory
					WHERE  branch = vbranch
					AND    contractno = pcontractno
					AND    oldstatus IS NOT NULL
					AND    newstatus IS NULL
					AND    operdate <= vdate
					ORDER  BY recno DESC)
			WHERE  rownum < 2;
		ELSE
			SELECT *
			INTO   vresult
			FROM   (SELECT *
					FROM   tcontractstatushistory
					WHERE  branch = vbranch
					AND    contractno = pcontractno
					AND    nvl(substr(oldstatus, pstatid, 1), ' ') = ' '
					AND    substr(newstatus, pstatid, 1) = '1'
					AND    operdate <= vdate
					ORDER  BY recno DESC)
			WHERE  rownum < 2;
		END IF;
		t.leave(cmethod_name, 'vResult.RecNo=' || vresult.recno);
		RETURN vresult;
	EXCEPTION
		WHEN no_data_found THEN
			RETURN vresult;
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getstatusid(pstat IN tcontract.status%TYPE) RETURN PLS_INTEGER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetStatusId';
		vret PLS_INTEGER;
	BEGIN
		t.enter(cmethod_name);
		CASE
			WHEN checkstatus(pstat, stat_ok) THEN
				vret := stat_ok;
			WHEN checkstatus(pstat, stat_violate) THEN
				vret := stat_violate;
			WHEN checkstatus(pstat, stat_close) THEN
				vret := stat_close;
			WHEN checkstatus(pstat, stat_suspend) THEN
				vret := stat_suspend;
			WHEN checkstatus(pstat, stat_investigation) THEN
				vret := stat_investigation;
			ELSE
				error.raiseerror('Unknown contract status!');
		END CASE;
		t.leave(cmethod_name, 'vRet=' || vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setactiveaccitem
	(
		pdialog      IN NUMBER
	   ,paccitemname IN tcontracttypeitemname.itemname%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetActiveAccItem';
	
		vaccountno  taccount.accountno%TYPE;
		vcontractno tcontract.no%TYPE;
	BEGIN
		t.enter(cmethod_name, 'pAccItemName=' || paccitemname);
		IF dialog.existsitembyname(pdialog, 'Account')
		THEN
			IF paccitemname IS NOT NULL
			THEN
			
				vcontractno := dialog.getchar(pdialog, 'No');
				err.seterror(0, cmethod_name);
				vaccountno := getaccountnobyitemname(vcontractno, paccitemname);
				err.seterror(0, cmethod_name);
				t.var('vAccountNo', vaccountno);
				IF vaccountno IS NOT NULL
				THEN
					dialog.setcurrecbyvalue(pdialog, 'Account', 'AccItemName', paccitemname);
					getaccountdata(pdialog, 'Account');
				END IF;
			END IF;
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE execcontrolblock_contractoper
	(
		poperationtype typeoperationtype
	   ,pno            typecontractno
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExecControlBlock_ContractOper';
		vcontractblockparams typecontractblockparams;
	BEGIN
		t.enter(cmethod_name, 'OperationType=' || poperationtype || ', ContractNo=' || pno);
		vcontractblockparams.operationtype := poperationtype;
		/*contractblocks.run(contractblocks.bt_execcontractoper
        ,pno
        ,saccessory
        ,contract.object_name
        ,vcontractblockparams);*/
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.raiseerror('Block of contract operations execution control: ~' ||
							 error.getusertext);
	END;

	FUNCTION getoperationtypedescription(poperationtype typeoperationtype) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetOperationTypeDescription';
		vret VARCHAR2(100);
	BEGIN
		CASE poperationtype
			WHEN action_contractcreation THEN
				vret := 'Create contract';
			WHEN action_clientchange THEN
				vret := 'Change customer';
			WHEN action_contracttypechange THEN
				vret := 'Change contract type';
			WHEN action_contractsaving THEN
				vret := 'Save contract';
			WHEN action_issueprimarycard THEN
				vret := 'Issue primary card';
			WHEN action_issuesupplementarycard THEN
				vret := 'Issue supplementary card';
			WHEN action_reissuecard THEN
				vret := 'Reissue card';
			WHEN action_addexistingcard THEN
				vret := 'Add existing card';
			WHEN action_movecard THEN
				vret := 'Move card';
			WHEN action_deletecard THEN
				vret := 'Delete card';
			WHEN action_issuecorporatecard THEN
				vret := 'Issue corporate card';
			ELSE
				error.raiseerror('Unknown type of contract operation!');
		END CASE;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
	END;

	FUNCTION getdynasqllocator RETURN VARCHAR2 IS
	BEGIN
		RETURN object_name;
	END;

	FUNCTION describescript(plocator VARCHAR2) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.DescribeScript';
		crootdescr   CONSTANT VARCHAR2(100) := 'Contract';
		vret         VARCHAR2(1000);
		vrootlocator VARCHAR2(1000);
	BEGIN
		t.enter(cmethod_name, 'Locator=' || plocator);
		vrootlocator := getdynasqllocator || '/';
		IF instr(plocator, vrootlocator, 1, 1) = 1
		THEN
			vret := crootdescr || '/' ||
					contractblocks.describescript(substr(plocator, length(vrootlocator) + 1));
		ELSE
			error.raiseerror(err.ue_value_incorrect, 'Invalid object');
		END IF;
	
		t.leave(cmethod_name, 'return ' || vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name || ' [' || plocator || ']');
			RETURN plocator;
	END;

	/*FUNCTION getsecurityarray
    (
        plevel          IN NUMBER
       ,pkey            IN VARCHAR2
       ,pnodenumber     NUMBER := NULL
       ,psearchtemplate VARCHAR2 := NULL
    ) RETURN custom_security.typerights IS
        cmethodname CONSTANT VARCHAR2(100) := cpackage_name || '.GetSecurityArray';
    BEGIN
        t.enter(cmethodname
               ,'Level=' || plevel || ', Key=' || pkey || ', NodeNumber=' || pnodenumber);
        RETURN custom_contractrights.getsecurityarray(plevel, pkey, pnodenumber, psearchtemplate);
    
        t.leave(cmethodname);
    EXCEPTION
        WHEN OTHERS THEN
            error.save(cmethodname
                      ,ptext => 'Error obtaining information [' || plevel || ', ' || pkey || ']: ' ||
                                error.gettext());
            RAISE;
    END;*/

	PROCEDURE closesecuritycursor
	(
		plevel IN NUMBER
	   ,pkey   IN VARCHAR2
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackage_name || '.CloseSecurityCursor';
	BEGIN
		t.enter(cmethodname, 'Level=' || plevel || ', Key=' || pkey);
		--contractrights.closesecuritycursor(plevel, pkey);
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE closesecuritycursors IS
		cmethodname CONSTANT VARCHAR2(100) := cpackage_name || '.CloseSecurityCursors';
	BEGIN
		t.enter(cmethodname);
		--contractrights.closesecuritycursors;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

BEGIN
	scontracttype_object := object.gettype(contracttype.object_name);
	sastatusname(stat_ok) := 'OK';
	sastatusname(stat_close) := 'Closed';
	sastatusname(stat_violate) := 'Violated';
	sastatusname(stat_suspend) := 'Suspended';
	sastatusname(stat_investigation) := 'In Debt Collector';

	scontdlg := NULL;
EXCEPTION
	WHEN OTHERS THEN
		s.say(cpackage_name || '.INIT_PACKAGE ' || SQLERRM, csay_level);
		error.save(cpackage_name || '.INIT_PACKAGE');
		RAISE;
END;
/
