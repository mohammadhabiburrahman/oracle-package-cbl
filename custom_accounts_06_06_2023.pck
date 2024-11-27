CREATE OR REPLACE PACKAGE custom_accounts AS

	crevision CONSTANT VARCHAR(100) := '$Rev: 61513 $';

	object_name CONSTANT VARCHAR(10) := 'ACCOUNT';
	object_type NUMBER;

	right_view CONSTANT VARCHAR2(20) := '1';

	right_open CONSTANT VARCHAR2(20) := '2';

	right_modify      CONSTANT VARCHAR2(20) := '3';
	right_modify_attr CONSTANT VARCHAR2(20) := '31';
	right_modify_oper CONSTANT VARCHAR2(20) := '32';

	right_change_client       CONSTANT VARCHAR2(20) := '34';
	right_del_hold            CONSTANT VARCHAR2(20) := '35';
	right_modify_branchpart   CONSTANT VARCHAR2(20) := '36';
	right_modify_limits       CONSTANT VARCHAR2(20) := '37';
	right_modify_tran_reverse CONSTANT VARCHAR2(20) := '38';
	right_cancel_hold         CONSTANT VARCHAR2(20) := '39';
	right_del_cash_reqs       CONSTANT VARCHAR2(20) := '3DCR';
	right_undo_cash_reqs      CONSTANT VARCHAR2(20) := '3UCR';

	right_move_hold CONSTANT VARCHAR2(20) := '3MOVEHOLD';

	right_delete                  CONSTANT VARCHAR2(20) := '4';
	right_view_all_branchpart     CONSTANT VARCHAR2(20) := '7';
	right_view_vip                CONSTANT VARCHAR2(20) := '8';
	right_view_vip_all_branchpart CONSTANT VARCHAR2(20) := '81';

	right_reference        CONSTANT VARCHAR2(20) := '9';
	right_reference_view   CONSTANT VARCHAR2(20) := '91';
	right_reference_modify CONSTANT VARCHAR2(20) := '92';

	right_block             CONSTANT VARCHAR2(20) := 'BLOCK';
	right_viewfinattrs      CONSTANT VARCHAR2(20) := 'VIEWFINATTRS';
	right_generatestatement CONSTANT VARCHAR2(20) := 'GENERATESTATEMENT';

	right_arrest        CONSTANT VARCHAR2(20) := 'ARREST';
	right_add_arrest    CONSTANT VARCHAR2(20) := 'AADD';
	right_modify_arrest CONSTANT VARCHAR2(20) := 'AMODIFY';
	right_delete_arrest CONSTANT VARCHAR2(20) := 'ADELETE';

	right_perstatement        CONSTANT VARCHAR2(20) := 'PERSTATEMENT';
	right_add_perstatement    CONSTANT VARCHAR2(20) := 'PSADD';
	right_modify_perstatement CONSTANT VARCHAR2(20) := 'PSMODIFY';
	right_delete_perstatement CONSTANT VARCHAR2(20) := 'PSDELETE';

	right_notification        CONSTANT VARCHAR2(20) := 'NOTIFICATION';
	right_add_notification    CONSTANT VARCHAR2(20) := 'NADD';
	right_modify_notification CONSTANT VARCHAR2(20) := 'NMODIFY';
	right_delete_notification CONSTANT VARCHAR2(20) := 'NDELETE';

	right_finprofile CONSTANT VARCHAR2(20) := 'FINPROFILE';

	right_save_search_res CONSTANT VARCHAR(20) := 'SAVERSL';

	SUBTYPE typeaccountoperationid IS VARCHAR2(16);
	caoimark      CONSTANT typeaccountoperationid := 'MARK';
	caoiarrest    CONSTANT typeaccountoperationid := 'ARREST';
	caoinosub     CONSTANT typeaccountoperationid := 'NOSUB';
	caoibook      CONSTANT typeaccountoperationid := 'BOOK';
	caoiundoclose CONSTANT typeaccountoperationid := 'UNDOCLOSE';

	stat_mark   CONSTANT CHAR(1) := '0';
	stat_arrest CONSTANT CHAR(1) := '1';
	stat_close  CONSTANT CHAR(1) := '2';
	stat_nosub  CONSTANT CHAR(1) := '3';
	stat_book   CONSTANT CHAR(1) := '4';
	stat_report CONSTANT CHAR(1) := '5';

	account_private CONSTANT VARCHAR(32) := 'ACCOUNT';
	account_company CONSTANT VARCHAR(32) := 'ACCOUNT_COMPANY';

	account_company_bank CONSTANT VARCHAR(32) := 'ACCOUNT_COMPANY_BANK';

	SUBTYPE typeaccountexistsinpc IS NUMBER(1);
	cyesexistsinpc  CONSTANT typeaccountexistsinpc := 1;
	cnoexistsinpc   CONSTANT typeaccountexistsinpc := 0;
	cnullexistsinpc CONSTANT typeaccountexistsinpc := NULL;

	ctypeoverdraft_null CONSTANT PLS_INTEGER := 0;
	ctypeoverdraft_perc CONSTANT PLS_INTEGER := 1;
	ctypeoverdraft_val  CONSTANT PLS_INTEGER := 2;

	SUBTYPE typeaccountno IS taccount.accountno%TYPE;

	TYPE typeaccount IS RECORD(
		 openmode                 VARCHAR(1)
		,branch                   taccount.branch%TYPE
		,accountno                taccount.accountno%TYPE
		,accounttype              taccount.accounttype%TYPE
		,currencyno               taccount.currencyno%TYPE
		,idclient                 taccount.idclient%TYPE
		,remain                   taccount.remain%TYPE
		,available                taccount.available%TYPE
		,overdraft                taccount.overdraft%TYPE
		,noplan                   taccount.noplan%TYPE
		,createdate               taccount.createdate%TYPE
		,createclerkcode          taccount.createclerkcode%TYPE
		,updatedate               taccount.updatedate%TYPE
		,updateclerkcode          taccount.updateclerkcode%TYPE
		,updatesysdate            taccount.updatesysdate%TYPE
		,stat                     taccount.stat%TYPE
		,acct_typ                 taccount.acct_typ%TYPE
		,acct_stat                taccount.acct_stat%TYPE
		,closedate                taccount.closedate%TYPE
		,remark                   taccount.remark%TYPE
		,debitreserve             taccount.debitreserve%TYPE
		,creditreserve            taccount.creditreserve%TYPE
		,lowremain                taccount.lowremain%TYPE
		,branchpart               taccount.branchpart%TYPE
		,limitgrp                 taccount.limitgrpid%TYPE
		,countergrp               taccount.countergrpid%TYPE
		,internallimitsgroupsysid taccount.internallimitsgroupsysid%TYPE
		,notactualbalance         BOOLEAN
		,updaterevision           taccount.updaterevision%TYPE
		,accforcedlock            BOOLEAN
		,remainupdatedate         taccount.remainupdatedate%TYPE
		,finprofile               taccount.finprofile%TYPE
		,objectuid                taccount.objectuid%TYPE
		,overdraft_comment        taccounteventlog.additionalinfo%TYPE
		,debitreserve_comment     taccounteventlog.additionalinfo%TYPE
		,creditreserve_comment    taccounteventlog.additionalinfo%TYPE
		,limitgrp_comment         taccounteventlog.additionalinfo%TYPE
		,countergrp_comment       taccounteventlog.additionalinfo%TYPE
		,intlimitgrp_comment      taccounteventlog.additionalinfo%TYPE
		,lowremain_comment        taccounteventlog.additionalinfo%TYPE
		,finprofile_comment       taccounteventlog.additionalinfo%TYPE
		,acct_typ_comment         taccounteventlog.additionalinfo%TYPE
		,acct_stat_comment        taccounteventlog.additionalinfo%TYPE
		,stat_comment             taccounteventlog.additionalinfo%TYPE
		,accuserproplist          apitypes.typeuserproplist
		,isrb                     BOOLEAN
		,permissibleexcesstype    NUMBER
		,permissibleexcess        NUMBER
		,protectedamount          NUMBER
		,extaccountno             tacc2acc.oldaccountno%TYPE
		
		);

	TYPE typeentryrecord IS RECORD(
		 docno         tentry.docno%TYPE
		,no            tentry.no%TYPE
		,doctype       tdocument.doctype%TYPE
		,opdate        tdocument.opdate%TYPE
		,clerkcode     tdocument.clerkcode%TYPE
		,station       tdocument.station%TYPE
		,parentdocno   tdocument.parentdocno%TYPE
		,childdocno    tdocument.childdocno%TYPE
		,description   tdocument.description%TYPE
		,valuedate     tentry.valuedate%TYPE
		,entcode       tentry.debitentcode%TYPE
		,addentcode    tentry.creditentcode%TYPE
		,debitaccount  tentry.debitaccount%TYPE
		,VALUE         tentry.value%TYPE
		,creditaccount tentry.creditaccount%TYPE
		,shortremark   tentry.shortremark%TYPE
		,fullremark    tentry.fullremark%TYPE
		,remain        taccount.remain%TYPE
		,pan           tatmext.pan%TYPE
		,mbr           tatmext.mbr%TYPE
		,trentcode     tatmext.entcode%TYPE
		,trcurrency    tatmext.currency%TYPE
		,trvalue       tatmext.value%TYPE
		,orgcurrency   tatmext.orgcurrency%TYPE
		,orgvalue      tatmext.orgvalue%TYPE
		,fromacct      tatmext.accountnoone%TYPE
		,toacct        tatmext.accountnotwo%TYPE
		,approval      tatmext.approval%TYPE
		,issuercode    tatmext.isscode%TYPE
		,acquirercode  tatmext.ficode%TYPE
		,retailerid    tposcheque.retailer%TYPE
		,device        tatmext.device%TYPE
		,termcode      tatmext.termcode%TYPE
		,termid        tatmext.term%TYPE
		,termlocation  tatmext.termlocation%TYPE
		,invoice       tatmext.invoice%TYPE
		,siccode       tatmext.siccode%TYPE
		,stan          tatmext.stan%TYPE
		,expdate       tatmext.expdate%TYPE
		,acquireriin   tatmext.acquireriin%TYPE
		,forwardiin    tatmext.forwardiin%TYPE
		,isscountry    tatmext.isscountry%TYPE
		,acqcountry    tatmext.acqcountry%TYPE
		,trancode      tatmext.trancode%TYPE
		,enttype       tatmext.enttype%TYPE
		,userdata      texcommon.userdata%TYPE
		,paymode       tpaymentext.paymentmode%TYPE
		,paycode       tpaymentext.code%TYPE
		,paybic        tpaymentext.bic%TYPE
		,paybankname   tpaymentext.bankname%TYPE
		,paycorracc    tpaymentext.corraccount%TYPE
		,payvendorname tpaymentext.vendorname%TYPE
		,paysettlacc   tpaymentext.account%TYPE
		,payinn        tpaymentext.inn%TYPE
		,payinfo       tpaymentext.destinfo%TYPE
		,paydate       tpaymentext.paymentdate%TYPE);

	emptyuserattributeslist apitypes.typeuserproplist;

	cdm_api    CONSTANT NUMBER := 0;
	cdm_dialog CONSTANT NUMBER := 1;

	sdeletemode NUMBER := cdm_api;
	smode       NUMBER := cdm_api;

	CURSOR cursorentrylist(paccountno IN typeaccountno) RETURN typeentryrecord;
	CURSOR cursorentrylistarc
	(
		paccountno IN typeaccountno
	   ,pstartdate IN DATE := NULL
	   ,penddate   IN DATE := NULL
	) RETURN typeentryrecord;

	TYPE typelastdcerrorinfo IS RECORD(
		 errorcode       NUMBER
		,errormessage    VARCHAR2(512)
		,accountno       typeaccountno
		,onlineaccountno VARCHAR2(25)
		,flcheck         NUMBER
		,onlinepriority  NUMBER
		,VALUE           NUMBER
		,onlinevalue     NUMBER);

	PROCEDURE setlastdcerrortrackingon;

	PROCEDURE setlastdcerrortrackingoff;

	FUNCTION getlastdcerrorinfo RETURN typelastdcerrorinfo;

	TYPE typeremainasofspecificopdate IS RECORD(
		 opdate DATE
		,remain NUMBER);

	TYPE typeremainhistory IS TABLE OF typeremainasofspecificopdate INDEX BY BINARY_INTEGER;

	TYPE typeopremain IS RECORD(
		 docno  NUMBER
		,no     NUMBER
		,opdate DATE
		,VALUE  NUMBER
		,remain NUMBER);
	TYPE typeopremains IS TABLE OF typeopremain INDEX BY BINARY_INTEGER;

	FUNCTION getversion RETURN VARCHAR;

	FUNCTION accountexist(paccountno IN typeaccountno) RETURN BOOLEAN;
	FUNCTION capturedobjectinfo(paccountno IN typeaccountno) RETURN VARCHAR;
	PROCEDURE changedebitreserve
	(
		paccountno  IN typeaccountno
	   ,pvalue      IN NUMBER
	   ,plockobject IN BOOLEAN := FALSE
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	);
	PROCEDURE changecreditreserve
	(
		paccountno  IN typeaccountno
	   ,pvalue      IN NUMBER
	   ,plockobject IN BOOLEAN := FALSE
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	);
	FUNCTION checkavailable
	(
		pdebitaccount  IN typeaccountno
	   ,pcreditaccount IN typeaccountno
	   ,pvalue         IN NUMBER
	) RETURN NUMBER;
	FUNCTION checkavailabledebit
	(
		pdebitaccount IN typeaccountno
	   ,pvalue        IN NUMBER
	) RETURN NUMBER;
	FUNCTION checkavailablecredit
	(
		pcreditaccount IN typeaccountno
	   ,pvalue         IN NUMBER
	) RETURN NUMBER;
	FUNCTION checkremain
	(
		pdebitaccount  IN typeaccountno
	   ,pcreditaccount IN typeaccountno
	   ,pvalue         IN NUMBER
	) RETURN NUMBER;
	FUNCTION checkright
	(
		pright              IN VARCHAR2
	   ,paccountno          IN typeaccountno := NULL
	   ,paccounttype        IN NUMBER := NULL
	   ,paccountoperationid IN typeaccountoperationid := NULL
	   ,psotemplateid       IN tsot.id%TYPE := NULL
	) RETURN BOOLEAN;
	PROCEDURE createaccount
	(
		paccountrow               IN OUT taccount%ROWTYPE
	   ,puserattributeslist       IN apitypes.typeuserproplist := emptyuserattributeslist
	   ,pdisableuserpropscreation IN BOOLEAN := FALSE
	   ,
		
		pdisableuserblockedcheck IN BOOLEAN := FALSE
	   ,
		
		ponlineprocessing IN BOOLEAN := FALSE
	   ,plog              IN BOOLEAN := FALSE
	   ,pisrollback       IN BOOLEAN := FALSE
	   ,pextaccountno     IN VARCHAR2 := NULL
	);
	FUNCTION createobject(pdialog IN NUMBER) RETURN VARCHAR;
	FUNCTION credit
	(
		this            IN NUMBER
	   ,pvalue          IN NUMBER
	   ,pcheck          IN NUMBER
	   ,ponlinepriority IN NUMBER
	   ,ponlineacc      IN VARCHAR2
	   ,ponlinetranid   IN OUT NUMBER
	   ,ponlinevalue    IN OUT NUMBER
	   ,pusebonusdebt   IN BOOLEAN := TRUE
	   ,pneednotify     IN BOOLEAN := TRUE
	   ,pfimicomment    IN VARCHAR2 := NULL
	   ,
		
		ponlinedebitremaincheck IN BOOLEAN := TRUE
	   ,
		
		ponlinepan IN VARCHAR := NULL
	   ,ponlinembr IN NUMBER := NULL
	) RETURN NUMBER;
	FUNCTION debit
	(
		this            IN NUMBER
	   ,pvalue          IN NUMBER
	   ,pcheck          IN NUMBER
	   ,ponlinepriority IN NUMBER
	   ,ponlineacc      IN VARCHAR2
	   ,ponlinetranid   IN OUT NUMBER
	   ,ponlinevalue    IN OUT NUMBER
	   ,pcheckonline    IN NUMBER := NULL
	   ,pusebonusdebt   IN BOOLEAN := TRUE
	   ,pneednotify     IN BOOLEAN := TRUE
	   ,pfimicomment    IN VARCHAR2 := NULL
	   ,
		
		poonlinedebitremaincheck IN OUT BOOLEAN
	   ,
		
		ponlinepan IN VARCHAR := NULL
	   ,ponlinembr IN NUMBER := NULL
		
	) RETURN NUMBER;
	PROCEDURE deleteaccount
	(
		paccountno        IN typeaccountno
	   ,pcheckright       IN BOOLEAN := TRUE
	   ,ponlineprocessing IN BOOLEAN := FALSE
	   ,plog              IN BOOLEAN := FALSE
	   ,pwithowner        IN BOOLEAN := FALSE
	);
	FUNCTION dialogcreate
	(
		paccounttype IN NUMBER
	   ,pclienttype  IN PLS_INTEGER
	   ,pidclient    IN NUMBER := NULL
	) RETURN NUMBER;
	PROCEDURE dialogcreateproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	FUNCTION dialogcreategetaccountno(pdialog IN NUMBER) RETURN VARCHAR;
	FUNCTION dialogdelete(paccountno IN typeaccountno) RETURN NUMBER;
	PROCEDURE dialogdeleteproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	FUNCTION exist(paccountno IN typeaccountno) RETURN NUMBER;
	PROCEDURE fillsecurityarray
	(
		plevel IN NUMBER
	   ,pkey   IN VARCHAR
	);
	PROCEDURE freeobject(this IN NUMBER);

	FUNCTION getaccountno(this IN NUMBER) RETURN VARCHAR;
	FUNCTION getaccounttype(this IN NUMBER) RETURN NUMBER;
	FUNCTION getaccounttype(paccountno IN typeaccountno) RETURN taccount.accounttype%TYPE;
	FUNCTION getaccountnobyobjuid(pobjectuid IN taccount.objectuid%TYPE) RETURN typeaccountno;
	FUNCTION getaccountrecord
	(
		paccountno IN typeaccountno
	   ,pguid      types.guid := NULL
	) RETURN apitypes.typeaccountrecord;
	FUNCTION getacct_stat(this IN NUMBER) RETURN CHAR;
	FUNCTION getacct_typ(this IN NUMBER) RETURN CHAR;
	FUNCTION getavailable(this IN NUMBER) RETURN NUMBER;
	FUNCTION getbranchpart(this IN NUMBER) RETURN NUMBER;
	FUNCTION getclosedate(this IN NUMBER) RETURN DATE;
	FUNCTION getcardlist(paccountno IN typeaccountno) RETURN apitypes.typeaccount2cardlist;
	FUNCTION getcreateclerkcode(this IN NUMBER) RETURN NUMBER;
	FUNCTION getcreatedate(this IN NUMBER) RETURN DATE;
	FUNCTION getcreditreserve(this IN NUMBER) RETURN NUMBER;
	FUNCTION getcurrency(this IN NUMBER) RETURN NUMBER;
	FUNCTION getcurrencybyaccountno(paccountno IN typeaccountno) RETURN NUMBER;
	FUNCTION getcurrentaccount RETURN typeaccountno;

	FUNCTION getcurrentaccountrecord(pthis IN NUMBER) RETURN apitypes.typeaccountrecord;

	FUNCTION getclienttype(this IN NUMBER) RETURN PLS_INTEGER;
	FUNCTION getclienttypebyaccno(paccountno IN typeaccountno) RETURN PLS_INTEGER;
	FUNCTION getdebitreserve(this IN NUMBER) RETURN NUMBER;
	FUNCTION getidclient(this IN NUMBER) RETURN NUMBER;
	FUNCTION getidclientbyaccno(paccountno IN typeaccountno) RETURN NUMBER;
	FUNCTION getkeyvalue(this IN NUMBER) RETURN VARCHAR;
	FUNCTION getlowremain(this IN NUMBER) RETURN NUMBER;
	FUNCTION getnewupdaterevision RETURN NUMBER;
	FUNCTION getnoplan(this IN NUMBER) RETURN NUMBER;
	FUNCTION getnoplanbyaccno(paccountno IN typeaccountno) RETURN NUMBER;
	FUNCTION getoverdraft(this IN NUMBER) RETURN NUMBER;
	FUNCTION getremain(this IN NUMBER) RETURN NUMBER;

	FUNCTION getaccount(this IN NUMBER) RETURN typeaccount;
	FUNCTION getovertype(this IN NUMBER) RETURN NUMBER;
	FUNCTION getovervalue(this IN NUMBER) RETURN NUMBER;

	FUNCTION getprotectedamountfo(this IN NUMBER) RETURN NUMBER;

	FUNCTION getremainhistory
	(
		paccountno  IN typeaccountno
	   ,pstartdate  IN DATE := NULL
	   ,pfinishdate IN DATE := NULL
	) RETURN typeremainhistory;

	FUNCTION getopremains
	(
		paccountno IN typeaccountno
	   ,pdocno     IN NUMBER
	) RETURN typeopremains;

	FUNCTION getremark(this IN NUMBER) RETURN VARCHAR;
	FUNCTION getrightkey
	(
		pright              IN VARCHAR2
	   ,paccounttype        IN NUMBER := NULL
	   ,paccountoperationid IN typeaccountoperationid := NULL
	   ,psotemplateid       IN tsot.id%TYPE := NULL
	) RETURN VARCHAR2;
	FUNCTION getsign(this IN NUMBER) RETURN NUMBER;
	FUNCTION getsoftstat(this IN NUMBER) RETURN VARCHAR;
	FUNCTION getstat(this IN NUMBER) RETURN VARCHAR;
	FUNCTION getstatname(pstat IN VARCHAR) RETURN VARCHAR;
	FUNCTION getregularpaymentlist(paccountno IN typeaccountno) RETURN apitypes.typeregularpaymentlist;
	FUNCTION getupdatedate(this IN NUMBER) RETURN DATE;
	FUNCTION getupdateclerkcode(this IN NUMBER) RETURN NUMBER;
	FUNCTION getupdatesysdate(this IN NUMBER) RETURN DATE;
	FUNCTION getlimitgrp(this IN NUMBER) RETURN NUMBER;
	FUNCTION getcountergrp(this IN NUMBER) RETURN NUMBER;

	FUNCTION getinternallimitsgroupsysid(this IN NUMBER) RETURN NUMBER;

	PROCEDURE setinternallimitsgroupsysid
	(
		this                      IN NUMBER
	   ,pinternallimitsgroupsysid IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	);

	PROCEDURE setinternallimitsgroupsysid
	(
		this                      IN NUMBER
	   ,pinternallimitsgroupsysid IN NUMBER
	   ,pchangesource             IN VARCHAR2
	   ,pterminalid               IN VARCHAR2
	   ,ptransactionid            IN VARCHAR2
	);

	FUNCTION getmemolist(paccountno IN typeaccountno) RETURN apitypes.typememolist;

	FUNCTION getfinprofile(pthis IN NUMBER) RETURN NUMBER;

	FUNCTION getremainupdatedate(paccounthandle IN NUMBER) RETURN DATE;

	PROCEDURE init;
	FUNCTION isarrest(this IN NUMBER) RETURN BOOLEAN;
	FUNCTION isclose(this IN NUMBER) RETURN BOOLEAN;
	FUNCTION ismark(this IN NUMBER) RETURN BOOLEAN;
	FUNCTION isnosub(this IN NUMBER) RETURN BOOLEAN;
	FUNCTION isbook(this IN NUMBER) RETURN BOOLEAN;
	FUNCTION isreport(this IN NUMBER) RETURN BOOLEAN;
	FUNCTION isclientpersone(pidclient IN tclient.idclient%TYPE) RETURN BOOLEAN;
	FUNCTION lockobject
	(
		paccountno    IN typeaccountno
	   ,pmod          IN CHAR
	   ,pattempt      PLS_INTEGER := NULL
	   ,pattemptpause NUMBER := NULL
	) RETURN NUMBER;
	FUNCTION newobject
	(
		paccountno IN typeaccountno
	   ,pmod       IN CHAR
	) RETURN NUMBER;
	PROCEDURE readobject(this IN NUMBER);
	PROCEDURE refreshaccount(paccountno IN typeaccountno);

	PROCEDURE closeaccount
	(
		paccounthandle IN NUMBER
	   ,pclosedate     IN DATE := NULL
	);
	PROCEDURE cancelaccountclosure(paccounthandle IN NUMBER);

	PROCEDURE closeanyaccount
	(
		paccounthandle IN NUMBER
	   ,pclosedate     IN DATE := NULL
	);

	PROCEDURE setacct_stat
	(
		this              IN NUMBER
	   ,pacct_stat        IN CHAR
	   ,ponlineprocessing IN BOOLEAN := FALSE
	   ,pcomment          IN VARCHAR2 := NULL
	);
	PROCEDURE setacct_typ
	(
		this      IN NUMBER
	   ,pacct_typ IN CHAR
	   ,pcomment  IN VARCHAR2 := NULL
	);
	PROCEDURE setavailable
	(
		this       IN NUMBER
	   ,pavailable IN NUMBER
	);
	PROCEDURE setclosedate
	(
		this       IN NUMBER
	   ,pclosedate IN DATE
	);
	PROCEDURE setcreatedate
	(
		this        IN NUMBER
	   ,pcreatedate IN DATE
	);
	PROCEDURE setcurrentaccount(paccountno IN typeaccountno);
	PROCEDURE setidclient
	(
		this      IN NUMBER
	   ,pidclient IN NUMBER
	);
	PROCEDURE setlowremain
	(
		this       IN NUMBER
	   ,plowremain IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
	   ,
		
		ponlineprocessing       IN BOOLEAN := FALSE
	   ,pdisableonlinelowremain IN BOOLEAN := FALSE
	);
	PROCEDURE setaccounttype
	(
		vaccounthandle  IN NUMBER
	   ,pnewaccounttype IN NUMBER
	);
	PROCEDURE setoverdraft
	(
		this       IN NUMBER
	   ,poverdraft IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
	   ,
		
		ponlineprocessing IN BOOLEAN := FALSE
	);
	PROCEDURE setremain
	(
		this    IN NUMBER
	   ,premain IN NUMBER
	);
	PROCEDURE setremark
	(
		this    IN NUMBER
	   ,premark IN VARCHAR
	);
	PROCEDURE setextaccountno
	(
		this     IN NUMBER
	   ,paccount IN VARCHAR
	);
	PROCEDURE setbranchpart
	(
		this        IN NUMBER
	   ,pbranchpart IN NUMBER
	);
	PROCEDURE setdebitreserve
	(
		this          IN NUMBER
	   ,pdebitreserve IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	);
	PROCEDURE setcreditreserve
	(
		this           IN NUMBER
	   ,pcreditreserve IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	);

	PROCEDURE changedebitreservebyhandle
	(
		paccounthandle IN NUMBER
	   ,pdelta         IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	);

	PROCEDURE changecreditreservebyhandle
	(
		paccounthandle IN NUMBER
	   ,pdelta         IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	);

	PROCEDURE setstat
	(
		this     IN NUMBER
	   ,pstat    IN CHAR
	   ,pcomment IN VARCHAR2 := NULL
	);
	PROCEDURE setlimitgrp
	(
		this      IN NUMBER
	   ,plimitgrp IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	);

	PROCEDURE setlimitgrp
	(
		this           IN NUMBER
	   ,plimitgrp      IN NUMBER
	   ,pchangesource  IN VARCHAR2
	   ,pterminalid    IN VARCHAR2
	   ,ptransactionid IN VARCHAR2
	);

	PROCEDURE setcountergrp
	(
		this        IN NUMBER
	   ,pcountergrp IN NUMBER
	   ,pcomment    IN VARCHAR := NULL
	);

	PROCEDURE setcountergrp
	(
		this           IN NUMBER
	   ,pcountergrp    IN NUMBER
	   ,pchangesource  IN VARCHAR2
	   ,pterminalid    IN VARCHAR2
	   ,ptransactionid IN VARCHAR2
	);

	PROCEDURE setfinprofile
	(
		pthis       IN NUMBER
	   ,pfinprofile IN NUMBER
	   ,pcomment    IN VARCHAR2 := NULL
	);

	PROCEDURE setovertype
	(
		this      IN NUMBER
	   ,povertype IN NUMBER
	);
	PROCEDURE setovervalue
	(
		this       IN NUMBER
	   ,povervalue IN NUMBER
	);
	PROCEDURE setaccount
	(
		this     IN NUMBER
	   ,paccinfo IN typeaccount
	);

	PROCEDURE setprotectedamountfo
	(
		this             IN NUMBER
	   ,pprotectedamount IN NUMBER
	);
	PROCEDURE changeprotectedamountfo
	(
		this   NUMBER
	   ,pdelta NUMBER
	);

	PROCEDURE changeprotectedamountfo
	(
		paccountno  IN typeaccountno
	   ,pvalue      IN NUMBER
	   ,plockobject IN BOOLEAN := FALSE
	);

	PROCEDURE setbookflag(paccountno IN typeaccountno);
	FUNCTION starrest RETURN CHAR;
	FUNCTION stclose RETURN CHAR;
	FUNCTION stmark RETURN CHAR;
	FUNCTION stnosub RETURN CHAR;
	FUNCTION stbook RETURN CHAR;
	FUNCTION streport RETURN CHAR;
	FUNCTION testhandle
	(
		this  IN NUMBER
	   ,pfrom IN VARCHAR
	) RETURN CHAR;
	PROCEDURE unlockobject(paccountno IN typeaccountno);
	PROCEDURE writeobject(this IN NUMBER
						 ,
						  
						  plog                  IN BOOLEAN := FALSE
						 ,plocalacct_statchange IN BOOLEAN := FALSE
						 ,pactiontype           IN VARCHAR := NULL
						  
						  );

	FUNCTION getflagnotactualbalance(paccountno IN typeaccountno) RETURN BOOLEAN;
	FUNCTION getstatementlist(paccountno IN typeaccountno) RETURN apitypes.typestatementlist;

	FUNCTION changeobjectmode
	(
		paccounthandle IN NUMBER
	   ,pnewmode       IN VARCHAR2
	   ,pforcedchange  IN BOOLEAN := FALSE
	) RETURN VARCHAR2;
	PROCEDURE changeobjectmode
	(
		paccounthandle IN NUMBER
	   ,pnewmode       IN VARCHAR2
	   ,pforcedchange  IN BOOLEAN := FALSE
	);

	FUNCTION getcurrentdlgaccountrecord RETURN apitypes.typeaccountrecord;

	PROCEDURE getmaskedfieldslist(psubobject IN VARCHAR2);

	FUNCTION getuserattributeslist(paccountno IN typeaccountno) RETURN apitypes.typeuserproplist;

	FUNCTION getuserattributerecord
	(
		paccountno IN typeaccountno
	   ,pfieldname IN VARCHAR2
	) RETURN apitypes.typeuserproprecord;

	PROCEDURE saveuserattributeslist
	(
		paccountno          IN typeaccountno
	   ,plist               IN apitypes.typeuserproplist
	   ,pclearpropnotinlist IN BOOLEAN := FALSE
	);

	PROCEDURE updateaccountsplannobytype
	(
		paccounttype IN NUMBER
	   ,pplanno      IN NUMBER
	);

	FUNCTION getinternalaccountnumber(pexternalaccountnumber IN VARCHAR2) RETURN VARCHAR2;

	FUNCTION getexternalaccountnumber(pinternalaccountnumber IN VARCHAR2) RETURN VARCHAR2;

	SUBTYPE typebranchoptionname IS VARCHAR2(32);
	cbonallowaccswopencardsclosing CONSTANT typebranchoptionname := 'AllowClosingAccountsOfOpenCards';

	FUNCTION getbranchoption(poptionname IN typebranchoptionname) RETURN BOOLEAN;

	PROCEDURE setbranchoption
	(
		poptionname  IN typebranchoptionname
	   ,poptionvalue IN BOOLEAN
	);

	PROCEDURE checklimitgrpid(plimitgrpid IN NUMBER);

	FUNCTION acct_typisvalid(pacct_typ IN treferenceacct_typ.acct_typ%TYPE) RETURN BOOLEAN;

	FUNCTION acct_statisvalid(pacct_stat IN treferenceacct_stat.acct_stat%TYPE) RETURN BOOLEAN;

	FUNCTION getuid(paccountno IN typeaccountno)
	
	 RETURN NUMBER;

	FUNCTION getuid(pthis IN NUMBER)
	
	 RETURN NUMBER;

	FUNCTION getguid(pthis IN NUMBER) RETURN types.guid;

	FUNCTION getguid(paccountno IN typeaccountno) RETURN types.guid;

	PROCEDURE logcreation(paccountno IN typeaccountno);

	PROCEDURE logdeletion
	(
		paccountno IN typeaccountno
	   ,pwithowner IN BOOLEAN := FALSE
	   ,powner     NUMBER := NULL
	);

	PROCEDURE logbookissuing(paccountno IN typeaccountno);

	PROCEDURE logattributeschange
	(
		ppreviousaccountdata  IN apitypes.typeaccountrecord
	   ,pnewaccountdata       IN apitypes.typeaccountrecord
	   ,plocalacct_statchange IN BOOLEAN := FALSE
	);

	PROCEDURE logbolimitsgroupchanging
	(
		paccountno                IN typeaccountno
	   ,ppreviouslimitsgroupsysid IN NUMBER
	   ,pnewlimitsgroupsysid      IN NUMBER
	);

	PROCEDURE logfolimitsgroupchanging
	(
		paccountno                IN typeaccountno
	   ,ppreviouslimitsgroupsysid IN NUMBER
	   ,pnewlimitsgroupsysid      IN NUMBER
	);

	PROCEDURE logownerchanging
	(
		paccountno        IN typeaccountno
	   ,ppreviousclientid IN NUMBER
	   ,pnewclientid      IN NUMBER
	);

	PROCEDURE logviewing(paccountno IN typeaccountno);

	PROCEDURE logclosure(paccountno IN typeaccountno);

	PROCEDURE logclosurecancelling(paccountno IN typeaccountno);

	PROCEDURE logfindocumentdeletion
	(
		paccountno     IN typeaccountno
	   ,pfindocumentno IN NUMBER
	);

	PROCEDURE logfindocumentreversing
	(
		paccountno     IN typeaccountno
	   ,pfindocumentno IN NUMBER
	);

	PROCEDURE logentrycorrection
	(
		paccountno     IN typeaccountno
	   ,pfindocumentno IN NUMBER
	   ,pentryno       IN NUMBER
	);

	SUBTYPE typeobjectcontexthandle IS PLS_INTEGER;
	FUNCTION saveobjectcontext(paccounthandle IN NUMBER) RETURN typeobjectcontexthandle;

	PROCEDURE restoreobjectcontext(pobjectcontexthandle IN typeobjectcontexthandle);

	PROCEDURE freeobjectcontext(pobjectcontexthandle IN typeobjectcontexthandle);

	PROCEDURE changeowner
	(
		paccounthandle IN NUMBER
	   ,pnewclientid   IN NUMBER
	   ,plog           IN BOOLEAN := FALSE
	);

	PROCEDURE changelowremain
	(
		paccounthandle NUMBER
	   ,pdelta         NUMBER
	   ,pcomment       VARCHAR := NULL
	);
	PROCEDURE changelowremain
	(
		paccountno typeaccountno
	   ,pdelta     NUMBER
	   ,pcomment   VARCHAR := NULL
	);
	PROCEDURE changelowremain_fast
	(
		paccounthandle NUMBER
	   ,paccountno     typeaccountno
	   ,pdelta         NUMBER
	   ,pcomment       VARCHAR := NULL
	);

	FUNCTION isinfront(paccountno IN typeaccountno) RETURN BOOLEAN;

	FUNCTION getmaxdocnoforacc(paccountno IN typeaccountno) RETURN NUMBER;

	FUNCTION canview(paccountno IN typeaccountno) RETURN BOOLEAN;
	FUNCTION describescript(plocator IN VARCHAR2) RETURN VARCHAR2;

	PROCEDURE runcontrolblock
	(
		paccountno               typeaccountno
	   ,pclienttype              PLS_INTEGER
	   ,pintrabankaccount        BOOLEAN
	   ,pblocktype               PLS_INTEGER
	   ,pdialogattributescontext BOOLEAN := FALSE
	   ,ptypemode                PLS_INTEGER := NULL
	);
	FUNCTION rowtoapi
	(
		paccountrow  IN taccount%ROWTYPE
	   ,pwithoutguid BOOLEAN := FALSE
	) RETURN apitypes.typeaccountrecord;

	PROCEDURE setcurrent(prec apitypes.typeaccountrecord);
	FUNCTION getcurrent RETURN apitypes.typeaccountrecord;

	FUNCTION getcurrentuserprop RETURN apitypes.typeuserproplist;
	PROCEDURE setcurrentuserprop(puserproplist IN apitypes.typeuserproplist);

	PROCEDURE setuserproplist
	(
		pthis               IN NUMBER
	   ,puserproplist       IN apitypes.typeuserproplist
	   ,pclearpropnotinlist IN BOOLEAN := FALSE
	);
	FUNCTION getuserproplist(pthis IN NUMBER) RETURN apitypes.typeuserproplist;

	PROCEDURE setisrollback
	(
		this  IN NUMBER
	   ,pisrb IN BOOLEAN
	);
	FUNCTION getisrollback(this IN NUMBER) RETURN BOOLEAN;

	FUNCTION getidclientacc(paccountno typeaccountno) RETURN NUMBER;

	PROCEDURE setmode(pmode NUMBER);
	FUNCTION getmode RETURN NUMBER;
	PROCEDURE logchange
	(
		paccountno typeaccountno
	   ,paction    NUMBER
	   ,plogtext   VARCHAR2
	   ,pparamlist a4mlog.typelogparamrecord
	);

	FUNCTION getaccountnobyguid(pguid types.guid) RETURN typeaccountno;
	FUNCTION getaccountrecordbyguid(pguid types.guid) RETURN apitypes.typeaccountrecord;

	FUNCTION getexistsinpc(paccountno IN typeaccountno) RETURN NUMBER;
	PROCEDURE setexistsinpc
	(
		paccountno  IN typeaccountno
	   ,pexistsinpc IN NUMBER := NULL
	   ,pnocommit   IN BOOLEAN := TRUE
	);
	FUNCTION existsinpc(paccountno IN typeaccountno) RETURN BOOLEAN;

	FUNCTION getsecurityarray
	(
		plevel          IN NUMBER
	   ,pkey            IN VARCHAR2
	   ,pnodenumber     NUMBER := NULL
	   ,psearchtemplate VARCHAR2 := NULL
	) RETURN custom_security.typerights;
	PROCEDURE closesecuritycursors;

END;
/
CREATE OR REPLACE PACKAGE BODY custom_accounts AS

	cpackagename  CONSTANT VARCHAR2(8) := 'custom_Accounts';
	cbodyrevision CONSTANT VARCHAR(100) := '$Rev: 61900 $';

	TYPE typeaccountlist IS TABLE OF typeaccount INDEX BY BINARY_INTEGER;
	sopenacc typeaccountlist;

	TYPE typekey IS TABLE OF BINARY_INTEGER INDEX BY VARCHAR2(100);
	TYPE typelevel IS TABLE OF typekey INDEX BY BINARY_INTEGER;
	sarrsize      typelevel;
	ssearchrights BOOLEAN := FALSE;

	TYPE typeobjectcontexthandlearray IS TABLE OF typeobjectcontexthandle INDEX BY BINARY_INTEGER;
	TYPE typeobjectcontexthandles IS TABLE OF typeobjectcontexthandlearray INDEX BY BINARY_INTEGER;

	accobjectcontexthandles typeobjectcontexthandles;

	TYPE typestatname IS TABLE OF VARCHAR(50) INDEX BY BINARY_INTEGER;
	sstatname typestatname;

	scurrentaccount typeaccountno;
	scurrentrecord  apitypes.typeaccountrecord;
	sdeleteclient   CHAR(1);

	scurrentuserprop apitypes.typeuserproplist;

	CURSOR cursorentrylist(paccountno IN typeaccountno) RETURN typeentryrecord IS
		SELECT a.docno
			  ,a.no
			  ,b.doctype
			  ,b.opdate
			  ,b.clerkcode
			  ,b.station
			  ,b.parentdocno
			  ,b.childdocno
			  ,b.description
			  ,a.valuedate
			  ,a.debitentcode entcode
			  ,a.creditentcode addentcode
			  ,a.debitaccount
			  ,a.value
			  ,a.creditaccount
			  ,a.shortremark
			  ,a.fullremark
			  ,NULL remain
			  ,nvl(j.pan, nvl(c.pan, nvl(d.pan, e.pan))) pan
			  ,nvl(j.mbr, nvl(c.mbr, nvl(d.mbr, e.mbr))) mbr
			  ,nvl(j.entcode, nvl(c.entcode, nvl(d.entcode, e.entcode))) trentcode
			  ,nvl(j.currency, nvl(c.currency, nvl(d.currency, e.currency))) trcurrency
			  ,nvl(j.amount, nvl(c.value, nvl(d.value, e.value))) trvalue
			  ,nvl(j.orgcurrency, nvl(c.orgcurrency, nvl(d.orgcurrency, e.orgcurrency))) orgcurrency
			  ,nvl(j.orgamount, nvl(c.orgvalue, nvl(d.orgvalue, e.orgvalue))) orgvalue
			  ,nvl(j.fromacct, c.accountnoone) fromacct
			  ,nvl(j.toacct, c.accountnotwo) toacct
			  ,nvl(j.approval, nvl(c.approval, nvl(d.approval, e.approval))) approval
			  ,nvl(j.issficode, nvl(c.isscode, nvl(d.isscode, e.isscode))) issuercode
			  ,nvl(j.acqficode, nvl(c.ficode, nvl(d.ficode, e.ficode))) acquirercode
			  ,nvl(j.retailer, nvl(d.retailer, e.retailer)) retailerid
			  ,nvl(j.device, nvl(c.device, nvl(d.device, e.device))) device
			  ,nvl(j.termcode, nvl(c.termcode, nvl(d.termcode, e.termcode))) termcode
			  ,nvl(j.term, nvl(c.term, nvl(d.term, e.imprinter))) termid
			  ,nvl(j.termlocation, nvl(c.termlocation, nvl(d.termlocation, e.termlocation))) termlocation
			  ,nvl(j.invoice, nvl(c.invoice, d.invoice)) invoice
			  ,nvl(j.mcc, nvl(c.siccode, nvl(d.siccode, e.siccode))) siccode
			  ,nvl(j.stan, nvl(c.stan, nvl(d.stan, e.stan))) stan
			  ,nvl(j.expdate, nvl(c.expdate, nvl(d.expdate, e.expdate))) expdate
			  ,nvl(j.acqiin, nvl(c.acquireriin, nvl(d.acquireriin, e.acquireriin))) acquireriin
			  ,nvl(j.forwardiin, nvl(c.forwardiin, nvl(d.forwardiin, e.forwardiin))) forwardiin
			  ,nvl(j.isscountry, nvl(c.isscountry, nvl(d.isscountry, e.isscountry))) isscountry
			  ,nvl(j.acqcountry, nvl(c.acqcountry, nvl(d.acqcountry, e.acqcountry))) acqcountry
			  ,nvl(j.code, nvl(c.trancode, nvl(d.trancode, e.trancode))) trancode
			  ,nvl(j.enttype, nvl(c.enttype, nvl(d.enttype, e.enttype))) enttype
			  ,j.userdata
			  ,f.paymentmode paymode
			  ,f.code paycode
			  ,f.bic paybic
			  ,f.bankname paybankname
			  ,f.corraccount paycorracc
			  ,f.vendorname payvendorname
			  ,f.account paysettlacc
			  ,f.inn payinn
			  ,f.destinfo payinfo
			  ,f.paymentdate paydate
		FROM   tentry      a
			  ,tdocument   b
			  ,texcommon   j
			  ,tatmext     c
			  ,tposcheque  d
			  ,tvoiceslip  e
			  ,tpaymentext f
		WHERE  a.branch = seance.getbranch
		AND    a.debitaccount = paccountno
		AND    b.branch = a.branch
		AND    b.docno = a.docno
		AND    b.newdocno IS NULL
		AND    j.branch(+) = a.branch
		AND    j.docno(+) = a.docno
		AND    c.branch(+) = a.branch
		AND    c.docno(+) = a.docno
		AND    d.branch(+) = a.branch
		AND    d.docno(+) = a.docno
		AND    e.branch(+) = a.branch
		AND    e.docno(+) = a.docno
		AND    f.branch(+) = a.branch
		AND    f.docno(+) = a.docno
		UNION ALL
		SELECT a.docno
			  ,a.no
			  ,b.doctype
			  ,b.opdate
			  ,b.clerkcode
			  ,b.station
			  ,b.parentdocno
			  ,b.childdocno
			  ,b.description
			  ,a.valuedate
			  ,a.debitentcode entcode
			  ,a.creditentcode addentcode
			  ,a.debitaccount
			  ,a.value
			  ,a.creditaccount
			  ,a.shortremark
			  ,a.fullremark
			  ,NULL remain
			  ,nvl(j.pan, nvl(c.pan, nvl(d.pan, e.pan))) pan
			  ,nvl(j.mbr, nvl(c.mbr, nvl(d.mbr, e.mbr))) mbr
			  ,nvl(j.entcode, nvl(c.entcode, nvl(d.entcode, e.entcode))) trentcode
			  ,nvl(j.currency, nvl(c.currency, nvl(d.currency, e.currency))) trcurrency
			  ,nvl(j.amount, nvl(c.value, nvl(d.value, e.value))) trvalue
			  ,nvl(j.orgcurrency, nvl(c.orgcurrency, nvl(d.orgcurrency, e.orgcurrency))) orgcurrency
			  ,nvl(j.orgamount, nvl(c.orgvalue, nvl(d.orgvalue, e.orgvalue))) orgvalue
			  ,nvl(j.fromacct, c.accountnoone) fromacct
			  ,nvl(j.toacct, c.accountnotwo) toacct
			  ,nvl(j.approval, nvl(c.approval, nvl(d.approval, e.approval))) approval
			  ,nvl(j.issficode, nvl(c.isscode, nvl(d.isscode, e.isscode))) issuercode
			  ,nvl(j.acqficode, nvl(c.ficode, nvl(d.ficode, e.ficode))) acquirercode
			  ,nvl(j.retailer, nvl(d.retailer, e.retailer)) retailerid
			  ,nvl(j.device, nvl(c.device, nvl(d.device, e.device))) device
			  ,nvl(j.termcode, nvl(c.termcode, nvl(d.termcode, e.termcode))) termcode
			  ,nvl(j.term, nvl(c.term, nvl(d.term, e.imprinter))) termid
			  ,nvl(j.termlocation, nvl(c.termlocation, nvl(d.termlocation, e.termlocation))) termlocation
			  ,nvl(j.invoice, nvl(c.invoice, d.invoice)) invoice
			  ,nvl(j.mcc, nvl(c.siccode, nvl(d.siccode, e.siccode))) siccode
			  ,nvl(j.stan, nvl(c.stan, nvl(d.stan, e.stan))) stan
			  ,nvl(j.expdate, nvl(c.expdate, nvl(d.expdate, e.expdate))) expdate
			  ,nvl(j.acqiin, nvl(c.acquireriin, nvl(d.acquireriin, e.acquireriin))) acquireriin
			  ,nvl(j.forwardiin, nvl(c.forwardiin, nvl(d.forwardiin, e.forwardiin))) forwardiin
			  ,nvl(j.isscountry, nvl(c.isscountry, nvl(d.isscountry, e.isscountry))) isscountry
			  ,nvl(j.acqcountry, nvl(c.acqcountry, nvl(d.acqcountry, e.acqcountry))) acqcountry
			  ,nvl(j.code, nvl(c.trancode, nvl(d.trancode, e.trancode))) trancode
			  ,nvl(j.enttype, nvl(c.enttype, nvl(d.enttype, e.enttype))) enttype
			  ,j.userdata
			  ,f.paymentmode paymode
			  ,f.code paycode
			  ,f.bic paybic
			  ,f.bankname paybankname
			  ,f.corraccount paycorracc
			  ,f.vendorname payvendorname
			  ,f.account paysettlacc
			  ,f.inn payinn
			  ,f.destinfo payinfo
			  ,f.paymentdate paydate
		FROM   tentry      a
			  ,tdocument   b
			  ,texcommon   j
			  ,tatmext     c
			  ,tposcheque  d
			  ,tvoiceslip  e
			  ,tpaymentext f
		WHERE  a.branch = seance.getbranch
		AND    a.creditaccount = paccountno
		AND    b.branch = a.branch
		AND    b.docno = a.docno
		AND    b.newdocno IS NULL
		AND    j.branch(+) = a.branch
		AND    j.docno(+) = a.docno
		AND    c.branch(+) = a.branch
		AND    c.docno(+) = a.docno
		AND    d.branch(+) = a.branch
		AND    d.docno(+) = a.docno
		AND    e.branch(+) = a.branch
		AND    e.docno(+) = a.docno
		AND    f.branch(+) = a.branch
		AND    f.docno(+) = a.docno
		ORDER  BY 4
				 ,1
				 ,2;

	CURSOR cursorentrylistarc
	(
		paccountno IN typeaccountno
	   ,pstartdate IN DATE := NULL
	   ,penddate   IN DATE := NULL
	) RETURN typeentryrecord IS
		SELECT a.docno
			  ,a.no
			  ,b.doctype
			  ,b.opdate
			  ,b.clerkcode
			  ,b.station
			  ,b.parentdocno
			  ,b.childdocno
			  ,b.description
			  ,a.valuedate
			  ,a.debitentcode entcode
			  ,a.creditentcode addentcode
			  ,a.debitaccount
			  ,a.value
			  ,a.creditaccount
			  ,a.shortremark
			  ,a.fullremark
			  ,NULL remain
			  ,nvl(j.pan, nvl(c.pan, nvl(d.pan, e.pan))) pan
			  ,nvl(j.mbr, nvl(c.mbr, nvl(d.mbr, e.mbr))) mbr
			  ,nvl(j.entcode, nvl(c.entcode, nvl(d.entcode, e.entcode))) trentcode
			  ,nvl(j.currency, nvl(c.currency, nvl(d.currency, e.currency))) trcurrency
			  ,nvl(j.amount, nvl(c.value, nvl(d.value, e.value))) trvalue
			  ,nvl(j.orgcurrency, nvl(c.orgcurrency, nvl(d.orgcurrency, e.orgcurrency))) orgcurrency
			  ,nvl(j.orgamount, nvl(c.orgvalue, nvl(d.orgvalue, e.orgvalue))) orgvalue
			  ,nvl(j.fromacct, c.accountnoone) fromacct
			  ,nvl(j.toacct, c.accountnotwo) toacct
			  ,nvl(j.approval, nvl(c.approval, nvl(d.approval, e.approval))) approval
			  ,nvl(j.issficode, nvl(c.isscode, nvl(d.isscode, e.isscode))) issuercode
			  ,nvl(j.acqficode, nvl(c.ficode, nvl(d.ficode, e.ficode))) acquirercode
			  ,nvl(j.retailer, nvl(d.retailer, e.retailer)) retailerid
			  ,nvl(j.device, nvl(c.device, nvl(d.device, e.device))) device
			  ,nvl(j.termcode, nvl(c.termcode, nvl(d.termcode, e.termcode))) termcode
			  ,nvl(j.term, nvl(c.term, nvl(d.term, e.imprinter))) termid
			  ,nvl(j.termlocation, nvl(c.termlocation, nvl(d.termlocation, e.termlocation))) termlocation
			  ,nvl(j.invoice, nvl(c.invoice, d.invoice)) invoice
			  ,nvl(j.mcc, nvl(c.siccode, nvl(d.siccode, e.siccode))) siccode
			  ,nvl(j.stan, nvl(c.stan, nvl(d.stan, e.stan))) stan
			  ,nvl(j.expdate, nvl(c.expdate, nvl(d.expdate, e.expdate))) expdate
			  ,nvl(j.acqiin, nvl(c.acquireriin, nvl(d.acquireriin, e.acquireriin))) acquireriin
			  ,nvl(j.forwardiin, nvl(c.forwardiin, nvl(d.forwardiin, e.forwardiin))) forwardiin
			  ,nvl(j.isscountry, nvl(c.isscountry, nvl(d.isscountry, e.isscountry))) isscountry
			  ,nvl(j.acqcountry, nvl(c.acqcountry, nvl(d.acqcountry, e.acqcountry))) acqcountry
			  ,nvl(j.code, nvl(c.trancode, nvl(d.trancode, e.trancode))) trancode
			  ,nvl(j.enttype, nvl(c.enttype, nvl(d.enttype, e.enttype))) enttype
			  ,j.userdata
			  ,f.paymentmode paymode
			  ,f.code paycode
			  ,f.bic paybic
			  ,f.bankname paybankname
			  ,f.corraccount paycorracc
			  ,f.vendorname payvendorname
			  ,f.account paysettlacc
			  ,f.inn payinn
			  ,f.destinfo payinfo
			  ,f.paymentdate paydate
		FROM   tentry      a
			  ,tdocument   b
			  ,texcommon   j
			  ,tatmext     c
			  ,tposcheque  d
			  ,tvoiceslip  e
			  ,tpaymentext f
		WHERE  a.branch = seance.getbranch
		AND    a.debitaccount = paccountno
		AND    b.branch = a.branch
		AND    b.docno = a.docno
		AND    b.newdocno IS NULL
		AND    b.opdate BETWEEN nvl(pstartdate, b.opdate) AND nvl(penddate, b.opdate)
		AND    j.branch(+) = a.branch
		AND    j.docno(+) = a.docno
		AND    c.branch(+) = a.branch
		AND    c.docno(+) = a.docno
		AND    d.branch(+) = a.branch
		AND    d.docno(+) = a.docno
		AND    e.branch(+) = a.branch
		AND    e.docno(+) = a.docno
		AND    f.branch(+) = a.branch
		AND    f.docno(+) = a.docno
		UNION ALL
		SELECT a.docno
			  ,a.no
			  ,b.doctype
			  ,b.opdate
			  ,b.clerkcode
			  ,b.station
			  ,b.parentdocno
			  ,b.childdocno
			  ,b.description
			  ,a.valuedate
			  ,a.debitentcode entcode
			  ,a.creditentcode addentcode
			  ,a.debitaccount
			  ,a.value
			  ,a.creditaccount
			  ,a.shortremark
			  ,a.fullremark
			  ,NULL remain
			  ,nvl(j.pan, nvl(c.pan, nvl(d.pan, e.pan))) pan
			  ,nvl(j.mbr, nvl(c.mbr, nvl(d.mbr, e.mbr))) mbr
			  ,nvl(j.entcode, nvl(c.entcode, nvl(d.entcode, e.entcode))) trentcode
			  ,nvl(j.currency, nvl(c.currency, nvl(d.currency, e.currency))) trcurrency
			  ,nvl(j.amount, nvl(c.value, nvl(d.value, e.value))) trvalue
			  ,nvl(j.orgcurrency, nvl(c.orgcurrency, nvl(d.orgcurrency, e.orgcurrency))) orgcurrency
			  ,nvl(j.orgamount, nvl(c.orgvalue, nvl(d.orgvalue, e.orgvalue))) orgvalue
			  ,nvl(j.fromacct, c.accountnoone) fromacct
			  ,nvl(j.toacct, c.accountnotwo) toacct
			  ,nvl(j.approval, nvl(c.approval, nvl(d.approval, e.approval))) approval
			  ,nvl(j.issficode, nvl(c.isscode, nvl(d.isscode, e.isscode))) issuercode
			  ,nvl(j.acqficode, nvl(c.ficode, nvl(d.ficode, e.ficode))) acquirercode
			  ,nvl(j.retailer, nvl(d.retailer, e.retailer)) retailerid
			  ,nvl(j.device, nvl(c.device, nvl(d.device, e.device))) device
			  ,nvl(j.termcode, nvl(c.termcode, nvl(d.termcode, e.termcode))) termcode
			  ,nvl(j.term, nvl(c.term, nvl(d.term, e.imprinter))) termid
			  ,nvl(j.termlocation, nvl(c.termlocation, nvl(d.termlocation, e.termlocation))) termlocation
			  ,nvl(j.invoice, nvl(c.invoice, d.invoice)) invoice
			  ,nvl(j.mcc, nvl(c.siccode, nvl(d.siccode, e.siccode))) siccode
			  ,nvl(j.stan, nvl(c.stan, nvl(d.stan, e.stan))) stan
			  ,nvl(j.expdate, nvl(c.expdate, nvl(d.expdate, e.expdate))) expdate
			  ,nvl(j.acqiin, nvl(c.acquireriin, nvl(d.acquireriin, e.acquireriin))) acquireriin
			  ,nvl(j.forwardiin, nvl(c.forwardiin, nvl(d.forwardiin, e.forwardiin))) forwardiin
			  ,nvl(j.isscountry, nvl(c.isscountry, nvl(d.isscountry, e.isscountry))) isscountry
			  ,nvl(j.acqcountry, nvl(c.acqcountry, nvl(d.acqcountry, e.acqcountry))) acqcountry
			  ,nvl(j.code, nvl(c.trancode, nvl(d.trancode, e.trancode))) trancode
			  ,nvl(j.enttype, nvl(c.enttype, nvl(d.enttype, e.enttype))) enttype
			  ,j.userdata
			  ,f.paymentmode paymode
			  ,f.code paycode
			  ,f.bic paybic
			  ,f.bankname paybankname
			  ,f.corraccount paycorracc
			  ,f.vendorname payvendorname
			  ,f.account paysettlacc
			  ,f.inn payinn
			  ,f.destinfo payinfo
			  ,f.paymentdate paydate
		FROM   tentry      a
			  ,tdocument   b
			  ,texcommon   j
			  ,tatmext     c
			  ,tposcheque  d
			  ,tvoiceslip  e
			  ,tpaymentext f
		WHERE  a.branch = seance.getbranch
		AND    a.creditaccount = paccountno
		AND    b.branch = a.branch
		AND    b.docno = a.docno
		AND    b.newdocno IS NULL
		AND    b.opdate BETWEEN nvl(pstartdate, b.opdate) AND nvl(penddate, b.opdate)
		AND    j.branch(+) = a.branch
		AND    j.docno(+) = a.docno
		AND    c.branch(+) = a.branch
		AND    c.docno(+) = a.docno
		AND    d.branch(+) = a.branch
		AND    d.docno(+) = a.docno
		AND    e.branch(+) = a.branch
		AND    e.docno(+) = a.docno
		AND    f.branch(+) = a.branch
		AND    f.docno(+) = a.docno
		UNION ALL
		SELECT a.docno
			  ,a.no
			  ,b.doctype
			  ,b.opdate
			  ,b.clerkcode
			  ,b.station
			  ,b.parentdocno
			  ,b.childdocno
			  ,b.description
			  ,a.valuedate
			  ,a.debitentcode entcode
			  ,a.creditentcode addentcode
			  ,a.debitaccount
			  ,a.value
			  ,a.creditaccount
			  ,a.shortremark
			  ,a.fullremark
			  ,NULL remain
			  ,nvl(j.pan, nvl(c.pan, nvl(d.pan, e.pan))) pan
			  ,nvl(j.mbr, nvl(c.mbr, nvl(d.mbr, e.mbr))) mbr
			  ,nvl(j.entcode, nvl(c.entcode, nvl(d.entcode, e.entcode))) trentcode
			  ,nvl(j.currency, nvl(c.currency, nvl(d.currency, e.currency))) trcurrency
			  ,nvl(j.amount, nvl(c.value, nvl(d.value, e.value))) trvalue
			  ,nvl(j.orgcurrency, nvl(c.orgcurrency, nvl(d.orgcurrency, e.orgcurrency))) orgcurrency
			  ,nvl(j.orgamount, nvl(c.orgvalue, nvl(d.orgvalue, e.orgvalue))) orgvalue
			  ,nvl(j.fromacct, c.accountnoone) fromacct
			  ,nvl(j.toacct, c.accountnotwo) toacct
			  ,nvl(j.approval, nvl(c.approval, nvl(d.approval, e.approval))) approval
			  ,nvl(j.issficode, nvl(c.isscode, nvl(d.isscode, e.isscode))) issuercode
			  ,nvl(j.acqficode, nvl(c.ficode, nvl(d.ficode, e.ficode))) acquirercode
			  ,nvl(j.retailer, nvl(d.retailer, e.retailer)) retailerid
			  ,nvl(j.device, nvl(c.device, nvl(d.device, e.device))) device
			  ,nvl(j.termcode, nvl(c.termcode, nvl(d.termcode, e.termcode))) termcode
			  ,nvl(j.term, nvl(c.term, nvl(d.term, e.imprinter))) termid
			  ,nvl(j.termlocation, nvl(c.termlocation, nvl(d.termlocation, e.termlocation))) termlocation
			  ,nvl(j.invoice, nvl(c.invoice, d.invoice)) invoice
			  ,nvl(j.mcc, nvl(c.siccode, nvl(d.siccode, e.siccode))) siccode
			  ,nvl(j.stan, nvl(c.stan, nvl(d.stan, e.stan))) stan
			  ,nvl(j.expdate, nvl(c.expdate, nvl(d.expdate, e.expdate))) expdate
			  ,nvl(j.acqiin, nvl(c.acquireriin, nvl(d.acquireriin, e.acquireriin))) acquireriin
			  ,nvl(j.forwardiin, nvl(c.forwardiin, nvl(d.forwardiin, e.forwardiin))) forwardiin
			  ,nvl(j.isscountry, nvl(c.isscountry, nvl(d.isscountry, e.isscountry))) isscountry
			  ,nvl(j.acqcountry, nvl(c.acqcountry, nvl(d.acqcountry, e.acqcountry))) acqcountry
			  ,nvl(j.code, nvl(c.trancode, nvl(d.trancode, e.trancode))) trancode
			  ,nvl(j.enttype, nvl(c.enttype, nvl(d.enttype, e.enttype))) enttype
			  ,j.userdata
			  ,f.paymentmode paymode
			  ,f.code paycode
			  ,f.bic paybic
			  ,f.bankname paybankname
			  ,f.corraccount paycorracc
			  ,f.vendorname payvendorname
			  ,f.account paysettlacc
			  ,f.inn payinn
			  ,f.destinfo payinfo
			  ,f.paymentdate paydate
		FROM   tentryarc      a
			  ,tdocumentarc   b
			  ,texcommonarc   j
			  ,tatmextarc     c
			  ,tposchequearc  d
			  ,tvoicesliparc  e
			  ,tpaymentextarc f
		WHERE  a.branch = seance.getbranch
		AND    a.debitaccount = paccountno
		AND    b.branch = a.branch
		AND    b.docno = a.docno
		AND    b.newdocno IS NULL
		AND    b.opdate BETWEEN nvl(pstartdate, b.opdate) AND nvl(penddate, b.opdate)
		AND    j.branch(+) = a.branch
		AND    j.docno(+) = a.docno
		AND    c.branch(+) = a.branch
		AND    c.docno(+) = a.docno
		AND    d.branch(+) = a.branch
		AND    d.docno(+) = a.docno
		AND    e.branch(+) = a.branch
		AND    e.docno(+) = a.docno
		AND    f.branch(+) = a.branch
		AND    f.docno(+) = a.docno
		UNION ALL
		SELECT a.docno
			  ,a.no
			  ,b.doctype
			  ,b.opdate
			  ,b.clerkcode
			  ,b.station
			  ,b.parentdocno
			  ,b.childdocno
			  ,b.description
			  ,a.valuedate
			  ,a.debitentcode entcode
			  ,a.creditentcode addentcode
			  ,a.debitaccount
			  ,a.value
			  ,a.creditaccount
			  ,a.shortremark
			  ,a.fullremark
			  ,NULL remain
			  ,nvl(j.pan, nvl(c.pan, nvl(d.pan, e.pan))) pan
			  ,nvl(j.mbr, nvl(c.mbr, nvl(d.mbr, e.mbr))) mbr
			  ,nvl(j.entcode, nvl(c.entcode, nvl(d.entcode, e.entcode))) trentcode
			  ,nvl(j.currency, nvl(c.currency, nvl(d.currency, e.currency))) trcurrency
			  ,nvl(j.amount, nvl(c.value, nvl(d.value, e.value))) trvalue
			  ,nvl(j.orgcurrency, nvl(c.orgcurrency, nvl(d.orgcurrency, e.orgcurrency))) orgcurrency
			  ,nvl(j.orgamount, nvl(c.orgvalue, nvl(d.orgvalue, e.orgvalue))) orgvalue
			  ,nvl(j.fromacct, c.accountnoone) fromacct
			  ,nvl(j.toacct, c.accountnotwo) toacct
			  ,nvl(j.approval, nvl(c.approval, nvl(d.approval, e.approval))) approval
			  ,nvl(j.issficode, nvl(c.isscode, nvl(d.isscode, e.isscode))) issuercode
			  ,nvl(j.acqficode, nvl(c.ficode, nvl(d.ficode, e.ficode))) acquirercode
			  ,nvl(j.retailer, nvl(d.retailer, e.retailer)) retailerid
			  ,nvl(j.device, nvl(c.device, nvl(d.device, e.device))) device
			  ,nvl(j.termcode, nvl(c.termcode, nvl(d.termcode, e.termcode))) termcode
			  ,nvl(j.term, nvl(c.term, nvl(d.term, e.imprinter))) termid
			  ,nvl(j.termlocation, nvl(c.termlocation, nvl(d.termlocation, e.termlocation))) termlocation
			  ,nvl(j.invoice, nvl(c.invoice, d.invoice)) invoice
			  ,nvl(j.mcc, nvl(c.siccode, nvl(d.siccode, e.siccode))) siccode
			  ,nvl(j.stan, nvl(c.stan, nvl(d.stan, e.stan))) stan
			  ,nvl(j.expdate, nvl(c.expdate, nvl(d.expdate, e.expdate))) expdate
			  ,nvl(j.acqiin, nvl(c.acquireriin, nvl(d.acquireriin, e.acquireriin))) acquireriin
			  ,nvl(j.forwardiin, nvl(c.forwardiin, nvl(d.forwardiin, e.forwardiin))) forwardiin
			  ,nvl(j.isscountry, nvl(c.isscountry, nvl(d.isscountry, e.isscountry))) isscountry
			  ,nvl(j.acqcountry, nvl(c.acqcountry, nvl(d.acqcountry, e.acqcountry))) acqcountry
			  ,nvl(j.code, nvl(c.trancode, nvl(d.trancode, e.trancode))) trancode
			  ,nvl(j.enttype, nvl(c.enttype, nvl(d.enttype, e.enttype))) enttype
			  ,j.userdata
			  ,f.paymentmode paymode
			  ,f.code paycode
			  ,f.bic paybic
			  ,f.bankname paybankname
			  ,f.corraccount paycorracc
			  ,f.vendorname payvendorname
			  ,f.account paysettlacc
			  ,f.inn payinn
			  ,f.destinfo payinfo
			  ,f.paymentdate paydate
		FROM   tentryarc      a
			  ,tdocumentarc   b
			  ,texcommonarc   j
			  ,tatmextarc     c
			  ,tposchequearc  d
			  ,tvoicesliparc  e
			  ,tpaymentextarc f
		WHERE  a.branch = seance.getbranch
		AND    a.creditaccount = paccountno
		AND    b.branch = a.branch
		AND    b.docno = a.docno
		AND    b.newdocno IS NULL
		AND    b.opdate BETWEEN nvl(pstartdate, b.opdate) AND nvl(penddate, b.opdate)
		AND    j.branch(+) = a.branch
		AND    j.docno(+) = a.docno
		AND    c.branch(+) = a.branch
		AND    c.docno(+) = a.docno
		AND    d.branch(+) = a.branch
		AND    d.docno(+) = a.docno
		AND    e.branch(+) = a.branch
		AND    e.docno(+) = a.docno
		AND    f.branch(+) = a.branch
		AND    f.docno(+) = a.docno
		ORDER  BY 4
				 ,1
				 ,2;

	slastdcerrortracking BOOLEAN;
	slastdcerrorinfo     typelastdcerrorinfo;

	FUNCTION getmultitasklockoptions RETURN options.typelockoptions;

	PROCEDURE logfocountergroupchanging
	(
		paccountno            IN typeaccountno
	   ,ppreviouscountergroup IN NUMBER
	   ,pnewcountergroup      IN NUMBER
	);

	PROCEDURE logfinprofilechanging
	(
		paccountno          IN typeaccountno
	   ,ppreviousfinprofile IN NUMBER
	   ,pnewfinprofile      IN NUMBER
	);
	PROCEDURE logaccstatchanging
	(
		paccountno    IN typeaccountno
	   ,ppreviousstat IN VARCHAR
	   ,pnewstat      IN VARCHAR
	);
	FUNCTION getaccstatvalue(pstat taccount.stat%TYPE) RETURN VARCHAR;

	PROCEDURE setdataforexchange(paccount typeaccountno);
	PROCEDURE convertapitorow
	(
		prec        IN apitypes.typeaccountrecord
	   ,orow        IN OUT taccount%ROWTYPE
	   ,pwithoutuid BOOLEAN := FALSE
	);
	PROCEDURE saveuserattributeslist_
	(
		paccountno          IN typeaccountno
	   ,plist               IN apitypes.typeuserproplist
	   ,pclearpropnotinlist IN BOOLEAN := FALSE
	);
	PROCEDURE runupdateblock
	(
		paccountrecord           IN OUT apitypes.typeaccountrecord
	   ,puserattrlist            IN OUT apitypes.typeuserproplist
	   ,pclienttype              PLS_INTEGER
	   ,pdialogattributescontext BOOLEAN := FALSE
	   ,pintrabankaccount        BOOLEAN
	   ,ptypemode                PLS_INTEGER := NULL
	   ,pisrollback              BOOLEAN := FALSE
	);

	FUNCTION getversion RETURN VARCHAR IS
	BEGIN
		RETURN service.formatpackageversion(cpackagename, crevision, cbodyrevision);
	END;

	FUNCTION typeobjectcontexthandlearray_ RETURN typeobjectcontexthandlearray IS
		vaempty typeobjectcontexthandlearray;
	BEGIN
		vaempty.delete();
		RETURN vaempty;
	END;

	FUNCTION getfreehandle RETURN NUMBER IS
		phandle NUMBER;
	BEGIN
		phandle := 0;
		LOOP
			phandle := phandle + 1;
			EXIT WHEN sopenacc(phandle).openmode = 'N';
		END LOOP;
		RETURN phandle;
	EXCEPTION
		WHEN no_data_found THEN
			RETURN phandle;
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetFreeHandle');
			RAISE;
	END;

	PROCEDURE setlastdcerrortrackingon IS
	BEGIN
		slastdcerrortracking := TRUE;
		slastdcerrorinfo     := NULL;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SetLastDCErrorTrackingOn');
	END;

	PROCEDURE setlastdcerrortrackingoff IS
	BEGIN
		slastdcerrortracking := FALSE;
		slastdcerrorinfo     := NULL;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SetLastDCErrorTrackingOff');
	END;

	FUNCTION getlastdcerrorinfo RETURN typelastdcerrorinfo IS
	BEGIN
		IF (NOT slastdcerrortracking)
		THEN
			error.raiseuser('Tracking of errors in account operations is disabled');
		END IF;
		RETURN slastdcerrorinfo;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetLastDCErrorInfo');
			RAISE;
	END;

	PROCEDURE setaccountnotfounderror
	(
		paccountno      IN VARCHAR2
	   ,perrorplacement IN VARCHAR2
	) IS
	BEGIN
		err.seterror(err.account_not_found
					,cpackagename || '.' || perrorplacement
					,
					 
					 nvl(paccountno, 'null'));
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SetAccountNotFoundError');
			RAISE;
	END;

	PROCEDURE setaccountdebiterror
	(
		paccountno      IN VARCHAR2
	   ,perrorplacement IN VARCHAR2
	) IS
	BEGIN
		err.seterror(err.account_debit_error
					,cpackagename || '.' || perrorplacement
					,nvl(paccountno, 'null'));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SetAccountDebitError');
			RAISE;
	END;

	PROCEDURE setaccountcrediterror
	(
		paccountno      IN VARCHAR2
	   ,perrorplacement IN VARCHAR2
	) IS
	BEGIN
		err.seterror(err.account_credit_error
					,cpackagename || '.' || perrorplacement
					,nvl(paccountno, 'null'));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SetAccountCreditError');
			RAISE;
	END;

	PROCEDURE setexceptionerror
	(
		pmethodname IN VARCHAR2
	   ,paccountno  IN VARCHAR2
	) IS
		vcontext err.typecontextrec;
	BEGIN
		error.save(pmethodname, ptext => paccountno);
		vcontext := err.getcontext();
		error.showstack(pclear => TRUE);
		err.putcontext(vcontext);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SetExceptionError');
			RAISE;
	END;

	FUNCTION capturedobjectinfo(paccountno IN typeaccountno) RETURN VARCHAR IS
	BEGIN
		RETURN object.capturedobjectinfo(account.object_name, paccountno)
		
		|| ' ACC/NO: ' || paccountno;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.CapturedObjectInfo');
			RAISE;
	END;

	PROCEDURE updateobjectuid
	(
		paccountno IN typeaccountno
	   ,pobjectuid IN objectuid.typeobjectuid
	) IS
		vbranch NUMBER := seance.getbranch();
		dummy   NUMBER;
	BEGIN
		s.say(cpackagename || '.UpdateObjectUId|vBranch = ' || vbranch || ', pAccountNo = ' ||
			  paccountno || ', pObjectUId = ' || pobjectuid
			 ,2);
	
		SELECT 1
		INTO   dummy
		FROM   taccount
		WHERE  branch = vbranch
		AND    accountno = paccountno
		FOR    UPDATE NOWAIT;
	
		s.say(cpackagename || '.UpdateObjectUId|Dummy = ' || dummy, 2);
	
		UPDATE taccount
		SET    objectuid = pobjectuid
		WHERE  branch = vbranch
		AND    accountno = paccountno;
	EXCEPTION
		WHEN OTHERS THEN
		
			IF (SQLCODE() = -54)
			THEN
				s.say('WARNING! Error while updating UId of account ' || paccountno || ': ' ||
					  SQLERRM());
				RETURN;
			END IF;
		
			s.say(cpackagename || '.UpdateObjectUId|EXCEPTION', 2);
			error.save(cpackagename || '.UpdateObjectUId');
			RAISE;
	END;

	PROCEDURE updateobjectuid_autonomous
	(
		paccountno IN VARCHAR2
	   ,pobjectuid IN objectuid.typeobjectuid
	) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
		updateobjectuid(paccountno, pobjectuid);
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.UpdateObjectUId_Autonomous');
			ROLLBACK;
			RAISE;
	END;

	FUNCTION createobjectuid_autonomous(paccountno IN VARCHAR2) RETURN objectuid.typeobjectuid IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vobjectuid NUMBER;
	BEGIN
		vobjectuid := objectuid.newuid(object_name, paccountno, pnocommit => TRUE);
		updateobjectuid(paccountno, vobjectuid);
		COMMIT;
		RETURN vobjectuid;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.CreateObjectUId_Autonomous');
			ROLLBACK;
			RAISE;
	END;

	FUNCTION createobjectuid_safe(paccountno IN VARCHAR2) RETURN objectuid.typeobjectuid IS
		vobjectuid NUMBER;
	BEGIN
		BEGIN
			vobjectuid := createobjectuid_autonomous(paccountno);
		EXCEPTION
			WHEN OTHERS THEN
				IF (SQLCODE() = -60)
				THEN
					vobjectuid := objectuid.newuid(object_name, paccountno, pnocommit => FALSE);
				ELSE
					RAISE;
				END IF;
		END;
		RETURN vobjectuid;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.CreateObjectUId_Safe');
			RAISE;
	END;

	FUNCTION getobjectuid
	(
		paccountno         IN VARCHAR2
	   ,pcreateifnotexists IN BOOLEAN := TRUE
	) RETURN objectuid.typeobjectuid IS
		vbranch    NUMBER := seance.getbranch();
		vobjectuid NUMBER := NULL;
	BEGIN
	
		SELECT objectuid
		INTO   vobjectuid
		FROM   taccount
		WHERE  branch = vbranch
		AND    accountno = paccountno;
	
		IF (vobjectuid IS NULL AND pcreateifnotexists)
		THEN
		
			vobjectuid := createobjectuid_safe(paccountno);
		
		END IF;
	
		RETURN vobjectuid;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetObjectUId');
			RAISE;
	END;

	PROCEDURE changedebitreserve
	(
		paccountno  IN typeaccountno
	   ,pvalue      IN NUMBER
	   ,plockobject IN BOOLEAN := FALSE
	   ,pcomment    IN VARCHAR2 := NULL
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.ChangeDebitReserve';
		voperdate      DATE := seance.getoperdate();
		vclerkcode     NUMBER := clerk.getcode();
		vaccountlocked BOOLEAN := NULL;
		vbranch        NUMBER := seance.getbranch();
	
		vaccountfound    BOOLEAN;
		volddebitreserve taccount.creditreserve%TYPE;
		vnewdebitreserve taccount.creditreserve%TYPE;
	
	BEGIN
		s.say(cpackagename || ': changing debit reserve of account ' || paccountno, 2);
	
		err.seterror(0, cpackagename || '.ChangeDebitReserve');
	
		IF (plockobject)
		THEN
			vaccountlocked := lockobject(paccountno, 'W') = 0;
		END IF;
	
		IF (err.geterrorcode() = 0)
		THEN
		
			vaccountfound := FALSE;
		
			FOR i IN (SELECT debitreserve
					  FROM   taccount
					  WHERE  branch = vbranch
					  AND    accountno = paccountno)
			LOOP
			
				vaccountfound := TRUE;
			
				IF (nvl(i.debitreserve, 0) + nvl(pvalue, 0) < 0)
				THEN
					err.seterror(err.account_invalid_value, cmethodname);
				
					EXIT;
				
				END IF;
			
				volddebitreserve := i.debitreserve;
			
			END LOOP;
		
			IF (NOT vaccountfound)
			THEN
				setaccountnotfounderror(paccountno, 'ChangeDebitReserve');
			END IF;
		
			IF (err.geterrorcode() = 0)
			THEN
				UPDATE taccount
				SET    debitreserve    = nvl(debitreserve, 0) + nvl(pvalue, 0)
					  ,updatedate      = voperdate
					  ,updateclerkcode = vclerkcode
					  ,updatesysdate   = SYSDATE()
					  ,updaterevision  = seq_accountupdaterevision.nextval
				WHERE  branch = vbranch
				AND    accountno = paccountno
				
				RETURNING debitreserve INTO vnewdebitreserve;
			
				IF (nvl(volddebitreserve, 0) != nvl(vnewdebitreserve, 0))
				THEN
					accounteventlog.registerevent(paccountno
												 ,accounteventlog.cetdebitreservechange
												 ,vnewdebitreserve
												 ,volddebitreserve
												 ,pcomment);
				END IF;
			
			END IF;
		END IF;
	
		IF (vaccountlocked)
		THEN
			unlockobject(paccountno);
			vaccountlocked := FALSE;
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
		
			error.save(cmethodname);
			BEGIN
				IF (vaccountlocked)
				THEN
					unlockobject(paccountno);
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					s.err('Error while releasing account ' || paccountno);
			END;
		
			err.seterror(SQLCODE(), cmethodname);
	END;

	PROCEDURE changecreditreserve
	(
		paccountno  IN typeaccountno
	   ,pvalue      IN NUMBER
	   ,plockobject IN BOOLEAN := FALSE
	   ,pcomment    IN VARCHAR2 := NULL
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.ChangeCreditReserve';
		voperdate      DATE := seance.getoperdate();
		vclerkcode     NUMBER := clerk.getcode();
		vaccountlocked BOOLEAN := NULL;
		vbranch        NUMBER := seance.getbranch();
	
		vaccountfound     BOOLEAN;
		voldcreditreserve taccount.creditreserve%TYPE;
		vnewcreditreserve taccount.creditreserve%TYPE;
	
	BEGIN
		s.say(cpackagename || ': changing credit reserve of account ' || paccountno, 2);
		err.seterror(0, cmethodname);
	
		IF (plockobject)
		THEN
			vaccountlocked := lockobject(paccountno, 'W') = 0;
		END IF;
	
		IF (err.geterrorcode() = 0)
		THEN
		
			vaccountfound := FALSE;
		
			FOR i IN (SELECT creditreserve
					  FROM   taccount
					  WHERE  branch = vbranch
					  AND    accountno = paccountno)
			LOOP
			
				vaccountfound := TRUE;
			
				IF (nvl(i.creditreserve, 0) + nvl(pvalue, 0) < 0)
				THEN
					err.seterror(err.account_invalid_value, cmethodname);
				
					EXIT;
				
				END IF;
			
				voldcreditreserve := i.creditreserve;
			
			END LOOP;
		
			IF (NOT vaccountfound)
			THEN
				setaccountnotfounderror(paccountno, 'ChangeCreditReserve');
			END IF;
		
			IF (err.geterrorcode() = 0)
			THEN
				UPDATE taccount
				SET    creditreserve   = nvl(creditreserve, 0) + nvl(pvalue, 0)
					  ,updatedate      = voperdate
					  ,updateclerkcode = vclerkcode
					  ,updatesysdate   = SYSDATE()
					  ,updaterevision  = seq_accountupdaterevision.nextval
				WHERE  branch = vbranch
				AND    accountno = paccountno
				
				RETURNING creditreserve INTO vnewcreditreserve;
			
				IF (nvl(voldcreditreserve, 0) != nvl(vnewcreditreserve, 0))
				THEN
					accounteventlog.registerevent(paccountno
												 ,accounteventlog.cetcreditreservechange
												 ,vnewcreditreserve
												 ,voldcreditreserve
												 ,pcomment);
				END IF;
			
			END IF;
		END IF;
	
		IF (vaccountlocked)
		THEN
			unlockobject(paccountno);
			vaccountlocked := FALSE;
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
		
			error.save(cmethodname);
			BEGIN
				IF (vaccountlocked)
				THEN
					unlockobject(paccountno);
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					s.err('Error while releasing account ' || paccountno);
			END;
		
			err.seterror(SQLCODE(), cmethodname);
	END;

	FUNCTION checkavailable
	(
		pdebitaccount  IN typeaccountno
	   ,pcreditaccount IN typeaccountno
	   ,pvalue         IN NUMBER
	) RETURN NUMBER IS
		vremain    NUMBER;
		vavailable NUMBER;
		vlowremain NUMBER;
		vsign      NUMBER;
		vaccountno VARCHAR2(20) := NULL;
		vbranch    NUMBER := seance.getbranch();
	BEGIN
		err.seterror(0, cpackagename || '.CheckAvailable');
	
		vaccountno := pdebitaccount;
		SELECT a.available
			  ,nvl(a.lowremain, 0) - a.overdraft
			  ,b.sign
		INTO   vavailable
			  ,vlowremain
			  ,vsign
		FROM   taccount     a
			  ,tplanaccount b
		WHERE  a.branch = vbranch
		AND    a.accountno = vaccountno
		AND    b.branch = vbranch
		AND    b.no = a.noplan;
		IF vsign IN (planaccount.sign_passive, planaccount.sign_credit)
		   AND vavailable - pvalue < vlowremain
		THEN
		
			setaccountdebiterror(vaccountno, 'CheckAvailable');
		
			RETURN err.geterrorcode;
		END IF;
	
		vaccountno := pcreditaccount;
		SELECT a.remain
			  ,b.sign
		INTO   vremain
			  ,vsign
		FROM   taccount     a
			  ,tplanaccount b
		WHERE  a.branch = vbranch
		AND    a.accountno = vaccountno
		AND    b.branch = vbranch
		AND    b.no = a.noplan;
		IF vsign IN (planaccount.sign_active, planaccount.sign_credit)
		   AND vremain + pvalue > 0
		THEN
		
			setaccountcrediterror(vaccountno, 'CheckAvailable');
		
			RETURN err.geterrorcode;
		END IF;
	
		RETURN 0;
	EXCEPTION
		WHEN no_data_found THEN
			setaccountnotfounderror(vaccountno, 'CheckAvailable');
			RETURN err.geterrorcode();
		WHEN OTHERS THEN
			error.save(cpackagename || '.CheckAvailable');
			RAISE;
	END;

	FUNCTION checkavailablecredit
	(
		pcreditaccount IN typeaccountno
	   ,pvalue         IN NUMBER
	) RETURN NUMBER IS
		vremain NUMBER;
		vsign   NUMBER;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		err.seterror(0, cpackagename || '.CheckAvailableCredit');
	
		SELECT a.remain
			  ,b.sign
		INTO   vremain
			  ,vsign
		FROM   taccount     a
			  ,tplanaccount b
		WHERE  a.branch = vbranch
		AND    a.accountno = pcreditaccount
		AND    b.branch = vbranch
		AND    b.no = a.noplan;
		IF vsign IN (planaccount.sign_active, planaccount.sign_credit)
		   AND vremain + pvalue > 0
		THEN
		
			setaccountcrediterror(pcreditaccount, 'CheckAvailableCredit');
		
			RETURN err.geterrorcode;
		END IF;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			setaccountnotfounderror(pcreditaccount, 'CheckAvailableCredit');
			RETURN err.geterrorcode;
	END;

	FUNCTION checkavailabledebit
	(
		pdebitaccount IN typeaccountno
	   ,pvalue        IN NUMBER
	) RETURN NUMBER IS
		vavailable NUMBER;
		vlowremain NUMBER;
		vsign      NUMBER;
		vbranch    NUMBER := seance.getbranch();
	BEGIN
		err.seterror(0, cpackagename || '.CheckAvailableDebit');
	
		SELECT a.available
			  ,nvl(a.lowremain, 0) - a.overdraft
			  ,b.sign
		INTO   vavailable
			  ,vlowremain
			  ,vsign
		FROM   taccount     a
			  ,tplanaccount b
		WHERE  a.branch = vbranch
		AND    a.accountno = pdebitaccount
		AND    b.branch = vbranch
		AND    b.no = a.noplan;
		IF vsign IN (planaccount.sign_passive, planaccount.sign_credit)
		   AND vavailable - pvalue < vlowremain
		THEN
		
			setaccountdebiterror(pdebitaccount, 'CheckAvailableDebit');
		
			RETURN err.geterrorcode;
		END IF;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			setaccountnotfounderror(pdebitaccount, 'CheckAvailableDebit');
			RETURN err.geterrorcode;
	END;

	FUNCTION checkremain
	(
		pdebitaccount  IN typeaccountno
	   ,pcreditaccount IN typeaccountno
	   ,pvalue         IN NUMBER
	) RETURN NUMBER IS
		vremain    NUMBER;
		vlowremain NUMBER;
		vsign      NUMBER;
		vaccountno VARCHAR2(20) := NULL;
		vbranch    NUMBER := seance.getbranch;
	BEGIN
		err.seterror(0, cpackagename || '.CheckRemain');
	
		vaccountno := pdebitaccount;
		SELECT a.remain
			  ,nvl(a.lowremain, 0) - a.overdraft
			  ,b.sign
		INTO   vremain
			  ,vlowremain
			  ,vsign
		FROM   taccount     a
			  ,tplanaccount b
		WHERE  a.branch = vbranch
		AND    a.accountno = vaccountno
		AND    b.branch = vbranch
		AND    b.no = a.noplan;
		IF vsign IN (planaccount.sign_passive, planaccount.sign_credit)
		   AND vremain - pvalue < vlowremain
		THEN
		
			setaccountdebiterror(vaccountno, 'CheckRemain');
		
			RETURN err.geterrorcode();
		END IF;
	
		vaccountno := pcreditaccount;
		SELECT a.remain
			  ,b.sign
		INTO   vremain
			  ,vsign
		FROM   taccount     a
			  ,tplanaccount b
		WHERE  a.branch = vbranch
		AND    a.accountno = vaccountno
		AND    b.branch = vbranch
		AND    b.no = a.noplan;
		IF vsign IN (planaccount.sign_active, planaccount.sign_credit)
		   AND vremain + pvalue > 0
		THEN
		
			setaccountcrediterror(vaccountno, 'CheckRemain');
		
			RETURN err.geterrorcode;
		END IF;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			setaccountnotfounderror(vaccountno, 'CheckRemain');
			RETURN err.geterrorcode;
	END;

	FUNCTION getnewupdaterevision RETURN NUMBER IS
		vrevision NUMBER;
	BEGIN
		SELECT seq_accountupdaterevision.nextval INTO vrevision FROM dual;
		RETURN vrevision;
	END;

	FUNCTION checkright
	(
		pright              IN VARCHAR2
	   ,paccountno          IN typeaccountno := NULL
	   ,paccounttype        IN NUMBER := NULL
	   ,paccountoperationid IN typeaccountoperationid := NULL
	   ,psotemplateid       IN tsot.id%TYPE := NULL
	) RETURN BOOLEAN IS
		vaccrec apitypes.typeaccountrecord;
	BEGIN
	
		IF paccountno IS NOT NULL
		THEN
			vaccrec := getaccountrecord(paccountno);
		END IF;
	
		IF (pright IN (right_view, right_open, right_viewfinattrs, right_generatestatement) AND
		   paccountno IS NOT NULL)
		THEN
			RETURN security.checkright(account.object_name
									  ,getrightkey(pright, vaccrec.accounttype));
		ELSE
			IF pright IN (right_view_vip, right_view_vip_all_branchpart)
			   AND NOT client.isvip(vaccrec.idclient)
			THEN
				RETURN TRUE;
			ELSIF pright IN (right_view_all_branchpart, right_view_vip_all_branchpart)
				  AND nvl(vaccrec.branchpart, seance.getbranchpart) = seance.getbranchpart
			THEN
				RETURN TRUE;
			ELSE
				RETURN security.checkright(account.object_name
										  ,getrightkey(pright
													  ,paccounttype
													  ,paccountoperationid
													  ,psotemplateid));
			END IF;
		END IF;
	END;

	PROCEDURE checklimitgrpid(plimitgrpid IN NUMBER) IS
		vgroupobject NUMBER;
	BEGIN
		err.seterror(0, cpackagename || '.CheckLimitGrpId');
		IF (nvl(plimitgrpid, 0) != 0)
		THEN
			vgroupobject := referencelimit.getobjtypebylimitgrp(plimitgrpid);
			IF (vgroupobject IS NULL OR vgroupobject != referencelimit.objtype_account)
			THEN
				err.seterror(err.limit_invalid_group_id, cpackagename || '.CheckLimitGrpId');
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.CheckLimitGrpId');
			RAISE;
	END;

	PROCEDURE checkcountergrpid(pcountergrpid IN NUMBER) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.CheckCounterGrpId';
		vgroupobject NUMBER;
	BEGIN
		err.seterror(0, cwhere);
		IF (nvl(pcountergrpid, 0) != 0)
		THEN
			vgroupobject := referencelimit.getobjtypebycountergrp(pcountergrpid);
			IF (vgroupobject IS NULL OR vgroupobject != referencelimit.objtype_account)
			THEN
				err.seterror(err.ue_other, cwhere);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE checkinternallimitsgroupsysid(pinternallimitsgroupsysid IN NUMBER) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.CheckInternalLimitsGroupSysId';
		vobjecttype NUMBER;
	BEGIN
		err.seterror(0, cmethodname);
		IF (nvl(pinternallimitsgroupsysid, 0) != 0)
		THEN
			vobjecttype := referencelimit.getobjtypebyintlimitgrp(pinternallimitsgroupsysid);
			IF (vobjecttype IS NULL OR vobjecttype != referencelimit.objtype_account)
			THEN
				err.seterror(err.limit_invalid_group_id, cmethodname);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION acct_typisvalid(pacct_typ IN treferenceacct_typ.acct_typ%TYPE) RETURN BOOLEAN IS
		vname treferenceacct_typ.name%TYPE;
	
		FUNCTION getmethodname RETURN VARCHAR2 IS
		BEGIN
			RETURN cpackagename || '.Acct_TypIsValid';
		END;
	
	BEGIN
		vname := referenceacct_typ.getname(pacct_typ);
		IF (vname IS NULL AND err.geterrorcode() != 0)
		THEN
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(getmethodname());
			RAISE;
	END;

	FUNCTION acct_statisvalid(pacct_stat IN treferenceacct_stat.acct_stat%TYPE) RETURN BOOLEAN IS
		vname treferenceacct_typ.name%TYPE;
	
		FUNCTION getmethodname RETURN VARCHAR2 IS
		BEGIN
			RETURN cpackagename || '.Acct_StatIsValid';
		END;
	
	BEGIN
		vname := referenceacct_stat.getname(pacct_stat);
		IF (vname IS NULL AND err.geterrorcode() != 0)
		THEN
			RETURN FALSE;
		END IF;
		RETURN TRUE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(getmethodname());
			RAISE;
	END;

	PROCEDURE insertaccountrow(paccountrow IN taccount%ROWTYPE) IS
	
		FUNCTION getmethodname RETURN VARCHAR2 IS
		BEGIN
			RETURN cpackagename || '.InsertAccountRow';
		END;
	
	BEGIN
		IF (paccountrow.acct_typ IS NOT NULL AND NOT acct_typisvalid(paccountrow.acct_typ))
		THEN
			err.seterror(err.account_invalid_value
						,getmethodname()
						,err.getmessage(err.account_invalid_value) || ' Acct_Typ = ' ||
						 paccountrow.acct_typ);
			RETURN;
		END IF;
	
		IF (paccountrow.acct_stat IS NOT NULL AND NOT acct_statisvalid(paccountrow.acct_stat))
		THEN
			err.seterror(err.account_invalid_value
						,getmethodname()
						,err.getmessage(err.account_invalid_value) || ' Acct_Stat = ' ||
						 paccountrow.acct_stat);
			RETURN;
		END IF;
	
		INSERT INTO taccount
			(branch
			,accountno
			,accounttype
			,currencyno
			,idclient
			,remain
			,available
			,overdraft
			,noplan
			,createdate
			,createclerkcode
			,updatedate
			,updateclerkcode
			,updatesysdate
			,stat
			,acct_typ
			,acct_stat
			,closedate
			,remark
			,debitreserve
			,creditreserve
			,lowremain
			,branchpart
			,limitgrpid
			,updaterevision
			,remainupdatedate
			,finprofile
			,
			 
			 objectuid
			,
			 
			 internallimitsgroupsysid
			,
			 
			 countergrpid
			,existsinpc
			,permissibleexcesstype
			,permissibleexcess
			,protectedamount)
		VALUES
			(paccountrow.branch
			,paccountrow.accountno
			,paccountrow.accounttype
			,paccountrow.currencyno
			,paccountrow.idclient
			,paccountrow.remain
			,paccountrow.available
			,paccountrow.overdraft
			,paccountrow.noplan
			,paccountrow.createdate
			,paccountrow.createclerkcode
			,paccountrow.updatedate
			,paccountrow.updateclerkcode
			,paccountrow.updatesysdate
			,paccountrow.stat
			,paccountrow.acct_typ
			,paccountrow.acct_stat
			,paccountrow.closedate
			,paccountrow.remark
			,paccountrow.debitreserve
			,paccountrow.creditreserve
			,paccountrow.lowremain
			,paccountrow.branchpart
			,paccountrow.limitgrpid
			,paccountrow.updaterevision
			,paccountrow.remainupdatedate
			,
			 
			 paccountrow.finprofile
			,
			 
			 paccountrow.objectuid
			,
			 
			 paccountrow.internallimitsgroupsysid
			,
			 
			 paccountrow.countergrpid
			,nvl(paccountrow.existsinpc, account.cnoexistsinpc)
			,
			 
			 paccountrow.permissibleexcesstype
			,paccountrow.permissibleexcess
			,
			 
			 paccountrow.protectedamount);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.InsertAccountRow');
			RAISE;
	END;

	PROCEDURE createaccount
	(
		paccountrow               IN OUT taccount%ROWTYPE
	   ,puserattributeslist       IN apitypes.typeuserproplist := emptyuserattributeslist
	   ,pdisableuserpropscreation IN BOOLEAN := FALSE
	   ,
		
		pdisableuserblockedcheck IN BOOLEAN := FALSE
	   ,
		
		ponlineprocessing IN BOOLEAN := FALSE
	   ,plog              IN BOOLEAN
	   ,pisrollback       IN BOOLEAN := FALSE
	   ,pextaccountno     IN VARCHAR2
	) IS
		vextaccountno        tacc2acc.oldaccountno%TYPE := pextaccountno;
		vuserattributeslist  apitypes.typeuserproplist := puserattributeslist;
		vclienttype          NUMBER;
		vsavedcurrentaccount scurrentaccount%TYPE;
	
		ecancelprocessing EXCEPTION;
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.CreateAccount';
		vaccountnowasnull  BOOLEAN;
		vpreviousaccountno VARCHAR2(64);
	
		vclientblocked BOOLEAN;
		vdummy         VARCHAR(4000);
		vaccountrow    taccount%ROWTYPE;
		vbranch        NUMBER := seance.getbranch();
	BEGIN
		err.seterror(0, cmethodname);
	
		s.say(cmethodname || '|creating account..', 2);
	
		checklimitgrpid(paccountrow.limitgrpid);
		IF (err.geterrorcode() != 0)
		THEN
			s.err(cmethodname || '|CheckLimitGrpId(' || to_char(paccountrow.limitgrpid) ||
				  ') error ' || err.gettext());
			RETURN;
		END IF;
	
		checkcountergrpid(paccountrow.countergrpid);
		IF (err.geterrorcode() != 0)
		THEN
			s.err(cmethodname || '|CheckCounterGrpId(' || to_char(paccountrow.countergrpid) ||
				  ') error ' || err.gettext());
			RETURN;
		END IF;
	
		checkinternallimitsgroupsysid(paccountrow.internallimitsgroupsysid);
		IF (err.geterrorcode() != 0)
		THEN
			s.err(cmethodname || ': CheckInternalLimitsGroupSysId(' ||
				  to_char(paccountrow.internallimitsgroupsysid) || ') error ' || err.gettext());
			RETURN;
		END IF;
	
		IF (NOT nvl(pdisableuserblockedcheck, FALSE))
		THEN
		
			vclientblocked := client.isblocked(paccountrow.idclient);
			IF (err.geterrorcode() != 0)
			THEN
				s.err(cmethodname || '|Client.IsBlocked(' || to_char(paccountrow.idclient) ||
					  ') error ' || err.gettext());
				RETURN;
			ELSIF (vclientblocked)
			THEN
				err.seterror(err.client_blocked
							,cmethodname
							,'customer objects creation prohibited');
				RETURN;
			END IF;
		
		END IF;
	
		vclienttype := client.getclienttype(paccountrow.idclient);
		IF (err.geterrorcode() != 0)
		THEN
			s.err(cmethodname || '|Client.GetClientType(' || to_char(paccountrow.idclient) ||
				  ') error ' || err.gettext());
			RETURN;
		END IF;
	
		IF (paccountrow.accounttype != listaccounttype.internalbank_accounttype)
		THEN
			IF (vclienttype = client.ct_persone AND
			   NOT nvl(accounttype.isuseprivate(paccountrow.accounttype), FALSE) OR
			   vclienttype = client.ct_company AND
			   NOT nvl(accounttype.isusecorporate(paccountrow.accounttype), FALSE))
			THEN
			
				err.seterror(err.accounttype_invalid_handle, cmethodname);
				s.err(cmethodname || '|Invalid AccountType ' || paccountrow.accounttype ||
					  ' and ClientType ' || vclienttype);
			END IF;
		
			IF (err.geterrorcode() != 0)
			THEN
				s.err(cmethodname || '|AccountType.IsUsePrivate(' ||
					  to_char(paccountrow.accounttype) || ') / AccountType.IsUseCorporate(' ||
					  to_char(paccountrow.accounttype) || ') error ' || err.gettext());
				RETURN;
			END IF;
		END IF;
	
		IF paccountrow.accounttype != 0
		THEN
			IF accounttype.getnoplan(paccountrow.accounttype) IS NOT NULL
			THEN
				paccountrow.noplan := accounttype.getnoplan(paccountrow.accounttype);
				IF (err.geterrorcode() != 0)
				THEN
					s.err(cmethodname || '|AccountType.GetNoPlan(' ||
						  to_char(paccountrow.accounttype) || ') error ' || err.gettext());
					RETURN;
				END IF;
			ELSIF accounttype.getaccmap(paccountrow.accounttype) IS NOT NULL
			THEN
				paccountrow.noplan := accountmap.resolveplan(accounttype.getaccmap(paccountrow.accounttype)
															,nvl(paccountrow.branchpart
																,seance.getbranchpart));
			END IF;
		ELSE
			IF planaccount.gettype(paccountrow.noplan) != planaccount.type_nonconsolidated
			THEN
				err.seterror(err.planaccount_plan_not_found, cmethodname);
				s.err(cmethodname || '|pAccountRow.NoPlan(' || paccountrow.noplan ||
					  ') != PlanAccount.TYPE_NONCONSOLIDATED');
				RETURN;
			END IF;
		END IF;
	
		paccountrow.branch     := vbranch;
		paccountrow.currencyno := planaccount.getcurrency(paccountrow.noplan);
	
		IF (err.geterrorcode() != 0)
		THEN
			s.err(cmethodname || '|PlanAccount.GetCurrency(' || to_char(paccountrow.noplan) ||
				  ') error ' || err.gettext());
			RETURN;
		END IF;
	
		BEGIN
			paccountrow.createdate      := nvl(paccountrow.createdate, seance.getoperdate());
			paccountrow.createclerkcode := clerk.getcode();
			paccountrow.updatedate      := seance.getoperdate();
			paccountrow.updateclerkcode := clerk.getcode();
			paccountrow.updatesysdate   := SYSDATE;
			paccountrow.branchpart      := nvl(paccountrow.branchpart, seance.getbranchpart());
			paccountrow.acct_typ        := nvl(paccountrow.acct_typ
											  ,nvl(accounttype.getdatamemberchar(paccountrow.accounttype
																				,'ACCT_TYP')
												  ,referenceacct_typ.typ_checking));
			paccountrow.acct_stat       := nvl(paccountrow.acct_stat
											  ,nvl(accounttype.getdatamemberchar(paccountrow.accounttype
																				,'ACCT_STAT')
												  ,referenceacct_stat.stat_open));
		
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '[init acc fields]');
				RETURN;
		END;
	
		IF (nvl(paccountrow.overdraft, 0) < 0 OR nvl(paccountrow.lowremain, 0) < 0 OR
		   nvl(paccountrow.debitreserve, 0) < 0 OR nvl(paccountrow.creditreserve, 0) < 0 OR
		   paccountrow.available > paccountrow.remain)
		THEN
		
			DECLARE
				verrortext VARCHAR(250);
			BEGIN
			
				IF (paccountrow.overdraft < 0)
				THEN
					verrortext := 'Invalid value of account credit limit ';
					s.err(cmethodname || '|overdraft less than 0: ' ||
						  to_char(paccountrow.overdraft));
				ELSIF (paccountrow.lowremain < 0)
				THEN
					verrortext := 'Invalid value of minimum account balance';
					s.err(cmethodname || '|lowremain less than 0: ' ||
						  to_char(paccountrow.lowremain));
				ELSIF (paccountrow.debitreserve < 0)
				THEN
					verrortext := 'Invalid value of account debit hold ';
					s.err(cmethodname || '|debitreserve less than 0: ' ||
						  to_char(paccountrow.debitreserve));
				ELSIF (paccountrow.creditreserve < 0)
				THEN
					verrortext := 'Invalid value of account credit hold ';
					s.err(cmethodname || '|creditreserve less than 0: ' ||
						  to_char(paccountrow.creditreserve));
				ELSIF (paccountrow.available > paccountrow.remain)
				THEN
					verrortext := 'Available account balance exceeds total account balance ';
					s.err(cmethodname || '|available greater than remain: ' ||
						  to_char(paccountrow.available) || ' > ' || to_char(paccountrow.remain));
				END IF;
			
				err.seterror(err.account_invalid_value, cmethodname, verrortext);
			END;
			RETURN;
		END IF;
	
		paccountrow.overdraft     := greatest(paccountrow.overdraft, 0);
		paccountrow.lowremain     := greatest(paccountrow.lowremain, 0);
		paccountrow.debitreserve  := greatest(paccountrow.debitreserve, 0);
		paccountrow.creditreserve := greatest(paccountrow.creditreserve, 0);
		paccountrow.available     := least(paccountrow.available, paccountrow.remain);
		paccountrow.limitgrpid    := nvl(paccountrow.limitgrpid
										,accounttype.getlimitgrp(paccountrow.accounttype));
	
		IF (err.geterrorcode() != 0)
		THEN
			s.err(cmethodname || '|LimitGrpID  error ' || err.gettext());
			err.seterror(0, cmethodname);
		END IF;
	
		paccountrow.countergrpid := nvl(paccountrow.countergrpid
									   ,accounttype.getcountergrp(paccountrow.accounttype));
		IF (err.geterrorcode() != 0)
		THEN
			s.err(cmethodname || '|CounterGrpID  error ' || err.gettext());
			err.seterror(0, cmethodname);
		END IF;
	
		paccountrow.internallimitsgroupsysid := nvl(paccountrow.internallimitsgroupsysid
												   ,accounttype.getinternallimitsgroupsysid(paccountrow.accounttype));
		IF (err.geterrorcode() != 0)
		THEN
			s.err(cmethodname || '|InternalLimitsGroupSysId  error ' || err.gettext());
			err.seterror(0, cmethodname);
		END IF;
	
		IF (planaccount.getflagnotactualbalance(paccountrow.noplan))
		THEN
			paccountrow.remainupdatedate := NULL;
		ELSE
			paccountrow.remainupdatedate := paccountrow.updatedate;
		END IF;
	
		SAVEPOINT accountcreateaccount;
		BEGIN
			vsavedcurrentaccount := getcurrentaccount();
		
			vaccountnowasnull  := paccountrow.accountno IS NULL;
			vpreviousaccountno := NULL;
		
			LOOP
			
				s.say(cmethodname || '|creating account / loop start, pAccountRow.AccountNo = ' ||
					  paccountrow.accountno
					 ,2);
				IF (paccountrow.accountno IS NULL)
				THEN
					s.say(cmethodname || '|generating no.. ', 2);
				
					accounttype.generateaccountno(paccountrow, vextaccountno);
					s.say(cmethodname || '|generated int_acc ' || paccountrow.accountno ||
						  ', err is ' || err.gettext()
						 ,2);
				
					s.say(cmethodname || '|generated ext_acc ' || vextaccountno);
				
					setcurrentaccount(paccountrow.accountno);
				ELSE
					setcurrentaccount(paccountrow.accountno);
					s.say(cmethodname || '|checking no.. ', 2);
					IF (NOT accounttype.checkaccountno(paccountrow))
					THEN
						s.say(cmethodname || '|no check failed ' || paccountrow.accountno ||
							  ', err is ' || err.gettext()
							 ,2);
						err.seterror(err.account_invalid, cmethodname);
					ELSE
					
						IF pextaccountno IS NULL
						THEN
							s.say(cmethodname || '|check succeeded, generating external..', 2);
							vextaccountno := accounttype.getexternalaccount(paccountrow);
							s.say(cmethodname || '|generated ' || vextaccountno || ', err is ' ||
								  err.gettext()
								 ,2);
						END IF;
					END IF;
				END IF;
				IF (err.geterrorcode != 0)
				THEN
				
					s.err(cmethodname || '|generate or check error ' || err.gettext());
					RAISE ecancelprocessing;
				
				END IF;
			
				paccountrow.updaterevision := 0;
			
				DECLARE
					vrule             NUMBER;
					vaccountrec       apitypes.typeaccountrecord;
					vintrabankaccount BOOLEAN;
					visrollback       BOOLEAN := pisrollback;
				BEGIN
				
					vaccountrow       := paccountrow;
					vintrabankaccount := planaccount.gettype(vaccountrow.noplan) =
										 planaccount.type_nonconsolidated;
					vaccountrec       := rowtoapi(vaccountrow, TRUE);
				
					runupdateblock(vaccountrec
								  ,vuserattributeslist
								  ,vclienttype
								  ,pdialogattributescontext => FALSE
								  ,pintrabankaccount        => vintrabankaccount
								  ,ptypemode                => accountblocks.cmtcreate
								  ,pisrollback              => visrollback);
					convertapitorow(vaccountrec, vaccountrow, TRUE);
				
					setcurrent(vaccountrec);
					setcurrentuserprop(vuserattributeslist);
				
					vrule := nvl(sqlblockoptions.getparameter(sqlblockoptions.cobj_account
															 ,sqlblockoptions.cblock_save)
								,sqlblockoptions.crule_always);
					s.say(cmethodname || ' vRule=' || vrule || ' sMode=' || smode);
					IF smode = cdm_dialog
					   OR (vrule = sqlblockoptions.crule_always AND
					   vaccountrow.accounttype != listaccounttype.internalbank_accounttype)
					THEN
					
						runcontrolblock(vaccountrow.accountno
									   ,vclienttype
									   ,vintrabankaccount
									   ,accountblocks.cbtclose
									   ,ptypemode => accountblocks.cmtcreate);
					END IF;
					paccountrow := vaccountrow;
				EXCEPTION
					WHEN OTHERS THEN
						error.save(cmethodname);
						RAISE ecancelprocessing;
				END;
			
				BEGIN
					insertaccountrow(paccountrow);
				
				EXCEPTION
					WHEN dup_val_on_index THEN
						s.say(cmethodname || '|Duplicated Internal Account: ' ||
							  paccountrow.accountno || ' Account type: ' ||
							  paccountrow.accounttype
							 ,1);
						err.seterror(err.account_duplicate_accountno, cmethodname);
					
					WHEN OTHERS THEN
						error.save(cmethodname || '[InsertAccountRow]');
						RAISE ecancelprocessing;
					
				END;
			
				IF (err.geterrorcode() = 0)
				THEN
					EXIT;
				ELSIF (err.geterrorcode() = err.account_duplicate_accountno AND
					  accountnogenerator.existschangingfieldsinschema(paccountrow.accounttype
																	  ,accountnogenerator.st_internal) AND
					  (vpreviousaccountno IS NULL OR paccountrow.accountno != vpreviousaccountno))
				THEN
					vpreviousaccountno := paccountrow.accountno;
					IF (vaccountnowasnull)
					THEN
						paccountrow.accountno := NULL;
					END IF;
				
					IF pextaccountno IS NULL
					THEN
						vextaccountno := NULL;
					ELSE
						vextaccountno := pextaccountno;
					END IF;
				
					setcurrentaccount(vsavedcurrentaccount);
				ELSE
					s.err(cmethodname || '|int iteration check error ' || err.gettext());
					RAISE ecancelprocessing;
				END IF;
			END LOOP;
		
			vpreviousaccountno := NULL;
			LOOP
			
				s.say(cmethodname || '|vIntAccountNo = ' || paccountrow.accountno ||
					  ' |vExtAccountNo = ' || vextaccountno);
				IF (vextaccountno IS NOT NULL AND
				   acc2acc.setoldaccountno(paccountrow.accountno, vextaccountno) != 0)
				THEN
				
					IF (err.geterrorcode() = err.account_duplicate_external AND
					   accountnogenerator.existschangingfieldsinschema(paccountrow.accounttype
																	   ,accountnogenerator.st_external) AND
					   (vpreviousaccountno IS NULL OR vextaccountno != vpreviousaccountno) AND
					   pextaccountno IS NULL)
					THEN
						vpreviousaccountno := vextaccountno;
						vextaccountno      := accounttype.getexternalaccount(paccountrow);
					ELSE
						s.err(cmethodname || '|ext iteration check error ' || err.gettext());
						RAISE ecancelprocessing;
					END IF;
				ELSE
					EXIT;
				
				END IF;
			END LOOP;
		
			IF (paccountrow.objectuid IS NULL)
			THEN
				paccountrow.objectuid := objectuid.newuid(object_name
														 ,paccountrow.accountno
														 ,pnocommit => TRUE);
				updateobjectuid(paccountrow.accountno, paccountrow.objectuid);
			END IF;
		
			BEGIN
				customerrule.eventcreateaccount(paccountrow.accountno
											   ,paccountrow.acct_stat
											   ,paccountrow.accounttype
											   ,accounttype.getname(paccountrow.accounttype)
											   ,paccountrow.idclient);
			
				IF (err.geterrorcode() != 0)
				THEN
					s.err(cmethodname || '|EvnAccountOpen.Put(' || paccountrow.accountno || ',' ||
						  to_char(seance.getoperdate(), 'YYYYMMDDHH24MISS') || ') error ' ||
						  err.gettext());
					RAISE ecancelprocessing;
				END IF;
			
			EXCEPTION
				WHEN OTHERS THEN
					error.save(cmethodname || '[CustomerRule.EventCreateAccount]');
					RAISE ecancelprocessing;
			END;
		
			IF (NOT nvl(pdisableuserpropscreation, FALSE))
			THEN
				BEGIN
				
					IF (vclienttype = client.ct_persone)
					THEN
					
						objuserproperty.newrecord(account_private
												 ,
												  
												  paccountrow.objectuid
												 ,
												  
												  vuserattributeslist
												 ,plog_clientid => paccountrow.idclient);
					
					ELSIF (vclienttype = client.ct_company)
					THEN
						IF (planaccount.gettype(paccountrow.noplan) = planaccount.type_consolidated)
						THEN
						
							objuserproperty.newrecord(account_company
													 ,
													  
													  paccountrow.objectuid
													 ,
													  
													  vuserattributeslist);
						
						ELSE
						
							objuserproperty.newrecord(account_company
													 ,
													  
													  paccountrow.objectuid
													 ,
													  
													  vuserattributeslist
													 ,account_company_bank);
						END IF;
					END IF;
				
				EXCEPTION
				
					WHEN ecancelprocessing THEN
						RAISE;
					
					WHEN OTHERS THEN
					
						error.save(cmethodname || '[user props block]');
					
						RAISE ecancelprocessing;
					
				END;
			END IF;
		
			evnaccountopen.put(paccountrow.accountno, seance.getoperdate());
			IF (err.geterrorcode() != 0)
			THEN
			
				s.err(cmethodname || '|EvnAccountOpen.Put(' || paccountrow.accountno || ',' ||
					  to_char(seance.getoperdate(), 'YYYYMMDDHH24MISS') || ') error ' ||
					  err.gettext());
			
				RAISE ecancelprocessing;
			END IF;
		
			setcurrentaccount(vsavedcurrentaccount);
		
			IF ponlineprocessing
			THEN
				remoteonline.createaccount(paccountrow.accountno
										  ,paccountrow.acct_typ
										  ,paccountrow.acct_stat
										  ,paccountrow.currencyno
										  ,paccountrow.remain
										  ,paccountrow.available
										  ,htools.iif(vclienttype = client.ct_persone
													 ,paccountrow.idclient
													 ,NULL));
				IF remoteonline.geterrorcode != remoteonline.err_approved
				THEN
					error.raiseerror('Error creating account online: ' ||
									 remoteonline.geterrortext(remoteonline.geterrorcode)
									 
									 );
				END IF;
			
				IF paccountrow.overdraft > 0
				THEN
					IF remoteonline.setaccountoverdraft(paccountrow.accountno
													   ,paccountrow.overdraft
													   ,NULL
													   ,NULL
													   ,TRUE
													   ,'Initial value'
													   ,NULL
													   ,NULL
													   ,vdummy) != remoteonline.err_approved
					THEN
						error.raiseerror('Error setting Overdraft value for account online: ' ||
										 remoteonline.geterrortext(remoteonline.geterrorcode));
					END IF;
				END IF;
			
				setexistsinpc(paccountrow.accountno, cyesexistsinpc);
			
			END IF;
		
		EXCEPTION
		
			WHEN ecancelprocessing THEN
				ROLLBACK TO accountcreateaccount;
				setcurrentaccount(vsavedcurrentaccount);
			
			WHEN OTHERS THEN
			
				error.save(cmethodname || '[AccountCreateAccount block]');
			
				ROLLBACK TO accountcreateaccount;
				setcurrentaccount(vsavedcurrentaccount);
				RAISE;
		END;
	
		IF (err.geterrorcode = 0)
		THEN
			accounteventlog.registerevent(paccountrow.accountno, accounteventlog.cetcreate);
			IF plog
			THEN
				logcreation(paccountrow.accountno);
			END IF;
		END IF;
	
	EXCEPTION
	
		WHEN OTHERS THEN
		
			error.save(cmethodname);
		
	END;

	FUNCTION createobject(pdialog IN NUMBER) RETURN VARCHAR IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.CreateObject';
		vaccountrow         taccount%ROWTYPE;
		vextaccountno       tacc2acc.oldaccountno%TYPE;
		voperdate           DATE;
		vclerkcode          NUMBER;
		vuserattributeslist apitypes.typeuserproplist;
		usererror EXCEPTION;
		vidclient            NUMBER;
		vacctype             NUMBER;
		vclienttype          NUMBER;
		vsavedcurrentaccount scurrentaccount%TYPE;
	
		vaccountnowasnull  BOOLEAN;
		vpreviousaccountno VARCHAR2(64);
	
		vclientblocked BOOLEAN;
	
		vextaccountnowasnull BOOLEAN;
	
		vbranch NUMBER := seance.getbranch();
	BEGIN
		err.seterror(0, cmethodname);
	
		SAVEPOINT accountcreateobject;
	
		vidclient := dialog.getnumber(pdialog, 'IdClient');
		vacctype  := dialog.getnumber(pdialog, 'AccountType');
	
		vclientblocked := client.isblocked(vidclient);
		IF (err.geterrorcode() != 0)
		THEN
			s.err(cmethodname || ': Client.IsBlocked(' || to_char(vidclient) || ') error ' ||
				  err.gettext());
		ELSIF (vclientblocked)
		THEN
			err.seterror(err.client_blocked
						,cpackagename || '.CreateObject'
						,'customer objects creation prohibited');
		END IF;
	
		IF (err.geterrorcode() = 0)
		THEN
		
			vclienttype := client.getclienttype(vidclient);
		
			IF err.geterrorcode = 0
			THEN
				IF (vclienttype = client.ct_persone AND
				   NOT nvl(accounttype.isuseprivate(vacctype), FALSE))
				   OR (vclienttype = client.ct_company AND
				   NOT nvl(accounttype.isusecorporate(vacctype), FALSE) AND vacctype != 0)
				THEN
					err.seterror(err.accounttype_invalid_handle, cmethodname);
					s.err('Invalid AccountType ' || vacctype || ' and ClientType ' || vclienttype);
				END IF;
			END IF;
		
			IF err.geterrorcode = 0
			   AND accounttype.capture(vacctype) = 0
			THEN
			
				DECLARE
					vintrabankaccount BOOLEAN;
				
				BEGIN
					vsavedcurrentaccount := getcurrentaccount();
				
					voperdate  := seance.getoperdate;
					vclerkcode := clerk.getcode;
				
					vaccountrow.branch          := vbranch;
					vaccountrow.accountno       := dialog.getchar(pdialog, 'AccountNo');
					vaccountrow.accounttype     := vacctype;
					vaccountrow.currencyno      := planaccount.getcurrency(dialog.getnumber(pdialog
																						   ,'NoPlan'));
					vaccountrow.idclient        := vidclient;
					vaccountrow.remain          := 0;
					vaccountrow.available       := 0;
					vaccountrow.overdraft       := 0;
					vaccountrow.lowremain       := 0;
					vaccountrow.noplan          := dialog.getnumber(pdialog, 'NoPlan');
					vaccountrow.createdate      := voperdate;
					vaccountrow.createclerkcode := vclerkcode;
					vaccountrow.updatedate      := voperdate;
					vaccountrow.updateclerkcode := vclerkcode;
					vaccountrow.updatesysdate   := SYSDATE;
					vaccountrow.acct_typ        := nvl(referenceacct_typ.getitemdata(pdialog
																					,'ACCT_TYPName')
													  ,nvl(accounttype.getdatamemberchar(vaccountrow.accounttype
																						,'ACCT_TYP')
														  ,referenceacct_typ.typ_checking));
					vaccountrow.acct_stat       := nvl(referenceacct_stat.getitemdata(pdialog
																					 ,'ACCT_STATName')
													  ,nvl(accounttype.getdatamemberchar(vaccountrow.accounttype
																						,'ACCT_STAT')
														  ,referenceacct_stat.stat_open));
					vaccountrow.remark          := dialog.getchar(pdialog, 'Remark');
				
					vaccountrow.branchpart := seance.getbranchpart;
					vaccountrow.limitgrpid := accounttype.getlimitgrp(vaccountrow.accounttype);
				
					vaccountrow.countergrpid             := accounttype.getcountergrp(vaccountrow.accounttype);
					vaccountrow.internallimitsgroupsysid := accounttype.getinternallimitsgroupsysid(vaccountrow.accounttype);
				
					IF (planaccount.getflagnotactualbalance(vaccountrow.noplan))
					THEN
						vaccountrow.remainupdatedate := NULL;
					ELSE
						vaccountrow.remainupdatedate := vaccountrow.updatedate;
					END IF;
				
					vextaccountno                     := dialog.getchar(pdialog
																	   ,'ExternalAccountNo');
					vaccountrow.finprofile            := finaccountinstance.getpageprofile(pdialog);
					vaccountrow.permissibleexcesstype := ctypeoverdraft_null;
					vaccountrow.protectedamount       := NULL;
				
					IF (err.geterrorcode() = 0)
					THEN
					
						vaccountnowasnull    := vaccountrow.accountno IS NULL;
						vpreviousaccountno   := NULL;
						vextaccountnowasnull := vextaccountno IS NULL;
						LOOP
						
							IF (vaccountrow.accountno IS NULL)
							THEN
							
								IF (vextaccountnowasnull)
								THEN
									vextaccountno := NULL;
								END IF;
							
								accounttype.generateaccountno(vaccountrow, vextaccountno);
								setcurrentaccount(vaccountrow.accountno);
							ELSE
								setcurrentaccount(vaccountrow.accountno);
								err.seterror(0, cmethodname);
								IF (NOT accounttype.checkaccountno(vaccountrow))
								THEN
									IF (err.geterrorcode() = 0)
									THEN
										err.seterror(err.account_invalid, cmethodname);
									END IF;
								ELSIF (vextaccountno IS NULL)
								THEN
									vextaccountno := accounttype.getexternalaccount(vaccountrow);
								END IF;
							END IF;
						
							IF (err.geterrorcode() != 0)
							THEN
							
								RAISE usererror;
							END IF;
						
							vintrabankaccount := planaccount.gettype(vaccountrow.noplan) =
												 planaccount.type_nonconsolidated;
							IF (vclienttype = client.ct_persone)
							THEN
								vuserattributeslist := objuserproperty.getpagedata(pdialog
																				  ,account_private);
							ELSIF (vclienttype = client.ct_company)
							THEN
								IF (vintrabankaccount)
								THEN
									vuserattributeslist := objuserproperty.getpagedata(pdialog
																					  ,account.account_company
																					  ,account.account_company_bank);
								ELSE
									vuserattributeslist := objuserproperty.getpagedata(pdialog
																					  ,account_company);
								END IF;
							END IF;
						
							DECLARE
								vaccountrec apitypes.typeaccountrecord;
							BEGIN
								vaccountrec := rowtoapi(vaccountrow, TRUE);
							
								runupdateblock(vaccountrec
											  ,vuserattributeslist
											  ,vclienttype
											  ,pintrabankaccount   => vintrabankaccount
											  ,ptypemode           => accountblocks.cmtcreate);
								convertapitorow(vaccountrec, vaccountrow, TRUE);
							
								setcurrent(vaccountrec);
								setcurrentuserprop(vuserattributeslist);
							
								runcontrolblock(vaccountrow.accountno
											   ,vclienttype
											   ,vintrabankaccount
											   ,accountblocks.cbtclose
											   ,ptypemode => accountblocks.cmtcreate);
							END;
						
							vaccountrow.updaterevision := 0;
						
							BEGIN
							
								insertaccountrow(vaccountrow);
							
							EXCEPTION
								WHEN dup_val_on_index THEN
									s.say('Duplicated Internal Account: ' || vaccountrow.accountno ||
										  ' Account type: ' || vaccountrow.accounttype
										 ,1);
									err.seterror(err.account_duplicate_accountno, cmethodname);
							END;
						
							IF (err.geterrorcode() = 0)
							THEN
								EXIT;
							ELSIF (err.geterrorcode() = err.account_duplicate_accountno AND
								  accountnogenerator.existschangingfieldsinschema(vaccountrow.accounttype
																				  ,accountnogenerator.st_internal) AND
								  (vpreviousaccountno IS NULL OR
								  vaccountrow.accountno != vpreviousaccountno))
							THEN
								vpreviousaccountno := vaccountrow.accountno;
								IF (vaccountnowasnull)
								THEN
									vaccountrow.accountno := NULL;
								END IF;
								setcurrentaccount(vsavedcurrentaccount);
							ELSE
								RAISE usererror;
							END IF;
						END LOOP;
					
						vpreviousaccountno := NULL;
						LOOP
						
							IF (vextaccountno IS NOT NULL AND
							   acc2acc.setoldaccountno(vaccountrow.accountno, vextaccountno) != 0)
							THEN
							
								IF (err.geterrorcode() = err.account_duplicate_external AND
								   vextaccountnowasnull AND
								   accountnogenerator.existschangingfieldsinschema(vaccountrow.accounttype
																				   ,accountnogenerator.st_external) AND
								   (vpreviousaccountno IS NULL OR
								   vextaccountno != vpreviousaccountno))
								THEN
									vpreviousaccountno := vextaccountno;
									vextaccountno      := accounttype.getexternalaccount(vaccountrow);
								ELSE
									RAISE usererror;
								END IF;
							ELSE
								EXIT;
							
							END IF;
						END LOOP;
					
						IF (vaccountrow.objectuid IS NULL)
						THEN
							vaccountrow.objectuid := objectuid.newuid(object_name
																	 ,vaccountrow.accountno
																	 ,pnocommit => TRUE);
							updateobjectuid(vaccountrow.accountno, vaccountrow.objectuid);
						END IF;
					
						customerrule.eventcreateaccount(vaccountrow.accountno
													   ,vaccountrow.acct_stat
													   ,vaccountrow.accounttype
													   ,accounttype.getname(vaccountrow.accounttype)
													   ,vaccountrow.idclient);
					
						IF (vclienttype = client.ct_persone)
						THEN
						
							objuserproperty.newrecord(account_private
													 ,vaccountrow.objectuid
													 ,vuserattributeslist
													 ,plog_clientid => vaccountrow.idclient);
						
						ELSIF (vclienttype = client.ct_company)
						THEN
						
							objuserproperty.newrecord(account_company
													 ,vaccountrow.objectuid
													 ,vuserattributeslist);
						
						END IF;
					
						finaccountinstance.savepage(pdialog, vaccountrow.accountno);
						IF (err.geterrorcode() != 0)
						THEN
							RAISE usererror;
						END IF;
					
						evnaccountopen.put(vaccountrow.accountno, seance.getoperdate());
						s.say('3 *** Err.GetErrorCode()=' || err.geterrorcode());
						IF (err.geterrorcode() != 0)
						THEN
							RAISE usererror;
						END IF;
					
					END IF;
				
					setcurrentaccount(vsavedcurrentaccount);
				EXCEPTION
					WHEN usererror THEN
						setcurrentaccount(vsavedcurrentaccount);
						s.err(cmethodname);
					
					WHEN OTHERS THEN
						setcurrentaccount(vsavedcurrentaccount);
						err.seterror(SQLCODE, cmethodname);
				END;
			END IF;
		
		END IF;
	
		IF (err.geterrorcode() = 0)
		THEN
			logcreation(vaccountrow.accountno);
		END IF;
	
		IF (err.geterrorcode() != 0)
		THEN
			vaccountrow.accountno := NULL;
			ROLLBACK TO accountcreateobject;
		END IF;
	
		err.saveerror;
		accounttype.release(dialog.getnumber(pdialog, 'AccountType'));
		err.restoreerror;
	
		RETURN vaccountrow.accountno;
	END;

	FUNCTION onlinecredit
	(
		paccount      IN VARCHAR
	   ,pvalue        IN NUMBER
	   ,ponlinetranid IN OUT NUMBER
	   ,pusebonusdebt IN BOOLEAN
	   ,pneednotify   IN BOOLEAN := TRUE
	   ,pfimicomment  IN VARCHAR2 := NULL
	   ,ppan          IN VARCHAR := NULL
	   ,pmbr          IN NUMBER := NULL
	) RETURN NUMBER IS
	BEGIN
		ponlinetranid := remoteonline.accountcredit(paccount
												   ,pvalue
												   ,pignoreimpact => TRUE
												   ,pforce        => FALSE
												   ,pprevtranid   => ponlinetranid
												   ,pusebonusdebt => pusebonusdebt
												   ,pneednotify   => pneednotify
												   ,pfimicomment  => pfimicomment
												   ,ppan          => ppan
												   ,pmbr          => pmbr);
		RETURN pvalue;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.OnlineCredit');
			s.say(cpackagename || '.OnlineCredit - exception', 2);
			ponlinetranid := NULL;
			RETURN NULL;
	END;

	FUNCTION onlinedebit
	(
		pcheck        NUMBER
	   ,paccount      IN VARCHAR
	   ,pvalue        IN NUMBER
	   ,ponlinetranid IN OUT NUMBER
	   ,pcheckonline  IN NUMBER
	   ,pusebonusdebt IN BOOLEAN
	   ,pneednotify   IN BOOLEAN := TRUE
	   ,pfimicomment  IN VARCHAR2 := NULL
	   ,ppan          IN VARCHAR := NULL
	   ,pmbr          IN NUMBER := NULL
	) RETURN NUMBER IS
	
	BEGIN
	
		ponlinetranid := remoteonline.accountdebit(paccount
												  ,pvalue
												  ,pignoreimpact   => TRUE
												  ,pforce          => (pcheckonline =
																	  entry.flnocheck)
												  ,pprevtranid     => ponlinetranid
												  ,pallowoverdraft => (pcheckonline !=
																	  entry.flnooverdraft())
												  ,pusebonusdebt   => pusebonusdebt
												  ,pneednotify     => pneednotify
												  ,pfimicomment    => pfimicomment
												  ,ppan            => ppan
												  ,pmbr            => pmbr);
		RETURN pvalue;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.OnlineDebit');
			ponlinetranid := NULL;
			RETURN NULL;
	END;

	FUNCTION dummyonlinedebit
	(
		this            NUMBER
	   ,pvalue          NUMBER
	   ,pcheck          NUMBER
	   ,ponlinepriority NUMBER
	) RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.DummyOnlineDebit';
		vonlineinfo  apitypes.typeaccountrecord;
		vonlinevalue NUMBER := 0;
		usererr EXCEPTION;
		vret NUMBER;
	BEGIN
		s.say(' Account.DummyOnlineDebit|Account=' || sopenacc(this).accountno || ', pValue=' ||
			  pvalue || ', pOnlinePriority=' || ponlinepriority
			 ,2);
		IF pcheck = entry.flcheck
		   AND getsign(this) IN (planaccount.sign_passive, planaccount.sign_credit)
		   AND sopenacc(this)
		  .available - pvalue < nvl(sopenacc(this).lowremain, 0) - sopenacc(this).overdraft
		THEN
			s.say(' Account.DummyOnlineDebit|Insufficient funds in acct debit, try use online...'
				 ,2);
			IF ponlinepriority = entry.use_two
			THEN
				BEGIN
					vret := remoteonline.getaccountinfo(sopenacc(this).accountno, vonlineinfo);
					IF vret NOT IN (remoteonline.err_approved)
					THEN
						RAISE usererr;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
					
						err.seterror(err.ue_other
									,cpackagename || '.DummyOnlineDebit'
									,'Impossible to get account details online: ' ||
									 remoteonline.geterrortext(vret));
						RETURN err.ue_other;
					
				END;
				s.say(cpackagename || '.DummyOnlineDebit|Online Available=' ||
					  vonlineinfo.available
					 ,2);
				vonlinevalue := pvalue - greatest((sopenacc(this)
												  .available - nvl(sopenacc(this).lowremain, 0) + sopenacc(this)
												  .overdraft)
												 ,0);
				IF vonlinevalue > 0
				THEN
					IF vonlinevalue > vonlineinfo.available
					THEN
					
						setaccountdebiterror(sopenacc(this).accountno, 'DummyOnlineDebit');
					
						s.say(cpackagename || '.DummyOnlineDebit|Online DEBIT ERROR', 2);
						RETURN err.account_debit_error;
					ELSE
						s.say(cpackagename || '.DummyOnlineDebit|Online ChangeAccountBalance: ' ||
							  -vonlinevalue
							 ,2);
						BEGIN
							vret := remoteonline.changeaccountbalance(sopenacc(this).accountno
																	 ,0
																	 ,-vonlinevalue
																	 ,0);
							IF vret NOT IN (remoteonline.err_approved)
							THEN
								RAISE usererr;
							END IF;
						EXCEPTION
							WHEN OTHERS THEN
							
								err.seterror(err.ue_other
											,cpackagename || '.DummyOnlineDebit'
											,'Error changing balance online: ' ||
											 remoteonline.geterrortext(vret));
								RETURN err.ue_other;
							
						END;
						sopenacc(this).available := sopenacc(this).available + vonlinevalue;
					END IF;
				END IF;
			ELSE
			
				setaccountdebiterror(sopenacc(this).accountno, 'DummyOnlineDebit');
			
				RETURN err.account_debit_error;
			END IF;
		END IF;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
		
			error.save(cmethodname);
			RETURN err.geterrorcode();
		
	END;

	FUNCTION booleantostring(pboolean IN BOOLEAN) RETURN VARCHAR2 IS
	BEGIN
		IF (pboolean IS NULL)
		THEN
			RETURN 'null';
		ELSIF (pboolean)
		THEN
			RETURN 'true';
		END IF;
		RETURN 'false';
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;

	PROCEDURE registerdcerror
	(
		paccountno       IN typeaccountno
	   ,ponlineaccountno IN VARCHAR2
	   ,pcheck           IN NUMBER
	   ,ponlinepriority  IN NUMBER
	   ,pvalue           IN NUMBER
	   ,ponlinevalue     IN NUMBER
	) IS
	BEGIN
		IF (slastdcerrortracking)
		THEN
			slastdcerrorinfo                 := NULL;
			slastdcerrorinfo.errorcode       := err.geterrorcode();
			slastdcerrorinfo.errormessage    := err.gettext();
			slastdcerrorinfo.accountno       := paccountno;
			slastdcerrorinfo.onlineaccountno := ponlineaccountno;
			slastdcerrorinfo.flcheck         := pcheck;
			slastdcerrorinfo.onlinepriority  := ponlinepriority;
			slastdcerrorinfo.value           := pvalue;
			slastdcerrorinfo.onlinevalue     := ponlinevalue;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.RegisterDCError');
			RAISE;
	END;

	FUNCTION credit
	(
		this   IN NUMBER
	   ,pvalue IN NUMBER
	   ,pcheck IN NUMBER
	   ,
		
		ponlinepriority IN NUMBER
	   ,ponlineacc      IN VARCHAR2
	   ,ponlinetranid   IN OUT NUMBER
	   ,ponlinevalue    IN OUT NUMBER
	   ,
		
		pusebonusdebt IN BOOLEAN := TRUE
	   ,pneednotify   IN BOOLEAN := TRUE
	   ,pfimicomment  IN VARCHAR2 := NULL
	   ,
		
		ponlinedebitremaincheck IN BOOLEAN
	   ,
		
		ponlinepan IN VARCHAR := NULL
	   ,ponlinembr IN NUMBER := NULL
	) RETURN NUMBER IS
	
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.Credit';
		vonlinedebitremaincheck BOOLEAN;
	
		vonlineacc           VARCHAR2(20) := nvl(ponlineacc, sopenacc(this).accountno);
		vonlinevalue         NUMBER := nvl(ponlinevalue, pvalue);
		voldremainupdatedate DATE;
		velsetwcms           BOOLEAN := FALSE;
	
	BEGIN
	
		err.seterror(0, cmethodname);
	
		SAVEPOINT accountcredit;
	
		IF sopenacc(this).openmode = 'E'
			AND sopenacc(this).notactualbalance
		THEN
			RETURN 0;
		END IF;
	
		IF (entry.dummyonline)
		THEN
			ponlinetranid := NULL;
			ponlinevalue  := NULL;
			IF (pcheck = entry.flcheck AND
			   getsign(this) IN (planaccount.sign_active, planaccount.sign_credit) AND sopenacc(this)
			   .remain + pvalue > 0)
			THEN
			
				setaccountcrediterror(sopenacc(this).accountno, 'Credit');
			
			END IF;
		ELSE
		
			s.say(' ' || cmethodname || '|OnlineDebitRemainCheck1=' ||
				  booleantostring(ponlinedebitremaincheck)
				 ,2);
			vonlinedebitremaincheck := nvl(ponlinedebitremaincheck, TRUE);
			s.say(' ' || cmethodname || '|OnlineDebitRemainCheck2=' ||
				  booleantostring(vonlinedebitremaincheck)
				 ,2);
			s.say(' ' || cmethodname || '|pOnlineTranId=' || to_char(ponlinetranid), 2);
		
			IF (ponlinepriority IN (entry.use_two, entry.use_two_else_twcms))
			THEN
				s.say(' ' || cmethodname || '|OnlineCredit|vOnlineAcc=' || vonlineacc ||
					  ', vOnlineValue=' || vonlinevalue || ', pUseBonusDebt=' ||
					  booleantostring(pusebonusdebt)
					 ,2);
				ponlinevalue := onlinecredit(vonlineacc
											,vonlinevalue
											,ponlinetranid
											,pusebonusdebt
											,pneednotify   => pneednotify
											,pfimicomment  => pfimicomment
											,ppan          => ponlinepan
											,pmbr          => ponlinembr);
				IF (ponlinevalue IS NULL)
				THEN
					s.say(' ' || cmethodname || '|OnlineCredit failed !!!', 2);
				
					s.say(err.geterror(), 2);
					IF (ponlinepriority = entry.use_two)
					THEN
						IF (err.geterrorcode() = 0)
						THEN
							err.seterror(err.ue_other
										,cpackagename || '.Credit'
										,'Error crediting TWO account: ' ||
										 remoteonline.geterrortext(remoteonline.geterrorcode()));
						END IF;
					
					ELSE
						IF (pvalue != 0 AND pcheck IN (entry.flag_check, entry.flag_no_overdraft) AND
						   getsign(this) IN (planaccount.sign_active, planaccount.sign_credit) AND sopenacc(this)
						   .remain + pvalue > 0 AND ponlinetranid IS NULL)
						THEN
							setaccountcrediterror(sopenacc(this).accountno, 'Credit');
						ELSE
							velsetwcms := TRUE;
							err.seterror(0, cmethodname);
						END IF;
					END IF;
				
				ELSIF (vonlinedebitremaincheck)
				THEN
				
					sopenacc(this).available := sopenacc(this).available - ponlinevalue;
				
				ELSE
					s.say(' ' || cmethodname || '|SKIP change available|Acc=' || sopenacc(this)
						  .accountno || ', cur available: ' || sopenacc(this).available
						 ,2);
				
				END IF;
			ELSIF (ponlinepriority IN (entry.use_twcms, entry.use_twcms_else_two))
			THEN
			
				s.say('--| pValue ' || pvalue, 3);
				s.say('--| pCheck ' || pcheck, 3);
				s.say('--| GetSign(this) ' || getsign(this), 3);
				s.say('--| sOpenAcc(this).Remain ' || sopenacc(this).remain, 3);
				IF (pvalue != 0 AND pcheck IN (entry.flag_check, entry.flag_no_overdraft) AND
				   getsign(this) IN (planaccount.sign_active, planaccount.sign_credit) AND sopenacc(this)
				   .remain + pvalue > 0 AND ponlinetranid IS NULL)
				THEN
				
					setaccountcrediterror(sopenacc(this).accountno, 'Credit');
				
				END IF;
			ELSE
			
				err.seterror(err.ue_other, cmethodname, 'Invalid priority of funds usage');
			
			END IF;
		
		END IF;
	
		IF (err.geterrorcode() = 0)
		THEN
		
			sopenacc(this).remain := sopenacc(this).remain + pvalue;
		
			IF velsetwcms = FALSE
			THEN
				sopenacc(this).available := sopenacc(this).available + pvalue;
			END IF;
		
			voldremainupdatedate := sopenacc(this).remainupdatedate;
			sopenacc(this).remainupdatedate := seance.getoperdate();
		
			writeobject(this);
			IF (err.geterrorcode() != 0)
			THEN
				sopenacc(this).remain := sopenacc(this).remain - pvalue;
			
				IF velsetwcms = FALSE
				THEN
					sopenacc(this).available := sopenacc(this).available - pvalue;
				END IF;
			
				sopenacc(this).remainupdatedate := voldremainupdatedate;
			
				ROLLBACK TO accountcredit;
			
			END IF;
		
		END IF;
	
		IF (err.geterrorcode() != 0)
		THEN
			s.say('RegisterDCError');
			registerdcerror(sopenacc(this).accountno
						   ,ponlineacc
						   ,pcheck
						   ,ponlinepriority
						   ,pvalue
						   ,ponlinevalue);
		END IF;
		RETURN err.geterrorcode();
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			registerdcerror(sopenacc(this).accountno
						   ,ponlineacc
						   ,pcheck
						   ,ponlinepriority
						   ,pvalue
						   ,ponlinevalue);
			RAISE;
		
	END;

	FUNCTION debit
	(
		this   IN NUMBER
	   ,pvalue IN NUMBER
	   ,pcheck IN NUMBER
	   ,
		
		ponlinepriority IN NUMBER
	   ,ponlineacc      IN VARCHAR2
	   ,ponlinetranid   IN OUT NUMBER
	   ,ponlinevalue    IN OUT NUMBER
	   ,
		
		pcheckonline  IN NUMBER := NULL
	   ,pusebonusdebt IN BOOLEAN := TRUE
	   ,pneednotify   IN BOOLEAN := TRUE
	   ,pfimicomment  IN VARCHAR2 := NULL
	   ,
		
		poonlinedebitremaincheck IN OUT BOOLEAN
	   ,
		
		ponlinepan IN VARCHAR := NULL
	   ,ponlinembr IN NUMBER := NULL
	) RETURN NUMBER IS
	
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.Debit';
		vremainenough BOOLEAN;
	
		usererr EXCEPTION;
		vonlineacc           VARCHAR2(20) := nvl(ponlineacc, sopenacc(this).accountno);
		vonlinevalue         NUMBER := nvl(ponlinevalue, pvalue);
		vaccremain           NUMBER := sopenacc(this).remain;
		vaccoverdraft        NUMBER := nvl(sopenacc(this).overdraft, 0);
		vaccountrecord       apitypes.typeaccountrecord;
		voldremainupdatedate DATE;
	
		FUNCTION forbiddebit RETURN BOOLEAN IS
			vret BOOLEAN := FALSE;
		BEGIN
			s.say(cpackagename || '.ForbidDebit: pValue=' || pvalue || ' pCheck=' || pcheck ||
				  ' GetSign(this)=' || getsign(this));
			s.say(cpackagename || '.ForbidDebit: sOpenAcc(this).Available=' || sopenacc(this)
				  .available || ' sOpenAcc(this).Overdraft=' || sopenacc(this).overdraft ||
				  ' sOpenAcc(this).LowRemain=' || sopenacc(this).lowremain);
		
			IF (pvalue = 0)
			THEN
				vret := FALSE;
			ELSIF (pcheck = entry.flcheck)
			THEN
				vret := getsign(this) IN (planaccount.sign_passive, planaccount.sign_credit) AND
						pvalue > sopenacc(this)
					   .available + sopenacc(this).overdraft - nvl(sopenacc(this).lowremain, 0);
			ELSIF (pcheck = entry.flnooverdraft)
			THEN
				vret := getsign(this) IN (planaccount.sign_passive, planaccount.sign_credit) AND
						pvalue > sopenacc(this).available - nvl(sopenacc(this).lowremain, 0);
			END IF;
			RETURN vret;
		
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.ForbidDebit');
				RAISE;
			
		END;
	
	BEGIN
	
		err.seterror(0, cmethodname);
	
		SAVEPOINT accountdebit;
	
		IF (sopenacc(this).openmode = 'E' AND sopenacc(this).notactualbalance)
		THEN
			RETURN 0;
		END IF;
	
		IF (entry.dummyonline())
		THEN
			s.say(' ' || cmethodname || '|DummyOnline...', 2);
			ponlinetranid := NULL;
			ponlinevalue  := NULL;
			IF (dummyonlinedebit(this, pvalue, pcheck, ponlinepriority) != 0)
			THEN
				s.say(cmethodname || ' .DummyOnlineDebit|OnlineDebit failed !!!', 2);
			
			END IF;
		ELSE
		
			s.say(' ' || cmethodname || '|OnlineDebitRemainCheck1=' ||
				  booleantostring(poonlinedebitremaincheck)
				 ,2);
			IF (poonlinedebitremaincheck IS NULL)
			THEN
				poonlinedebitremaincheck := TRUE;
			END IF;
			s.say(' ' || cmethodname || '|OnlineDebitRemainCheck2=' ||
				  booleantostring(poonlinedebitremaincheck)
				 ,2);
			s.say(' ' || cmethodname || '|pOnlineTranId=' || to_char(ponlinetranid), 2);
		
			IF (ponlinepriority IN (entry.use_two, entry.use_two_else_twcms))
			THEN
				IF (ponlineacc IS NOT NULL)
				THEN
					vaccountrecord := getaccountrecord(ponlineacc);
					vaccremain     := vaccountrecord.remain;
					vaccoverdraft  := nvl(vaccountrecord.crdlimit, 0);
				END IF;
			
				IF (err.geterrorcode() = 0)
				THEN
					vremainenough := pcheck = entry.flnocheck OR
									 pcheck = entry.flcheck AND
									 vonlinevalue <= vaccremain + vaccoverdraft OR
									 pcheck = entry.flnooverdraft AND vonlinevalue <= vaccremain;
					IF (NOT poonlinedebitremaincheck AND vremainenough AND ponlinetranid IS NULL)
					THEN
						poonlinedebitremaincheck := TRUE;
					END IF;
					s.say(' ' || cmethodname || '|RemainEnough=' || booleantostring(vremainenough)
						 ,2);
					s.say(' ' || cmethodname || '|OnlineDebitRemainCheck3=' ||
						  booleantostring(poonlinedebitremaincheck)
						 ,2);
				
					IF (poonlinedebitremaincheck AND NOT vremainenough
					   
					   AND ponlinetranid IS NULL)
					THEN
						s.say(' ' || cmethodname ||
							  '|Check remain|OnlineValue > Remain+OverDraft|vOnlineValue=' ||
							  vonlinevalue || ', Remain=' || sopenacc(this).remain ||
							  ', OverDraft=' || sopenacc(this).overdraft
							 ,2);
					
						ponlinevalue := NULL;
					
						IF (ponlinepriority = entry.use_two OR
						   ponlinepriority = entry.use_two_else_twcms AND forbiddebit())
						THEN
							s.say(' ' || cmethodname || '|Check remain|Debit TWCMS acc forbit', 2);
						
							setaccountdebiterror(sopenacc(this).accountno, 'Debit');
						
						END IF;
						s.say(' ' || cmethodname || '|Check remain|Debit TWCMS acc allow', 2);
					ELSE
					
						s.say(' ' || cmethodname || '|OnlineDebit|vOnlineAcc=' || vonlineacc ||
							  ', vOnlineValue=' || vonlinevalue || ', pUseBonusDebt=' ||
							  booleantostring(pusebonusdebt) || ' pCheck=' || pcheck ||
							  ' pCheckOnline=' || pcheckonline
							 ,2);
						ponlinevalue := onlinedebit(pcheck
												   ,vonlineacc
												   ,vonlinevalue
												   ,ponlinetranid
												   ,pcheckonline
												   ,pusebonusdebt
												   ,pneednotify   => pneednotify
												   ,pfimicomment  => pfimicomment
												   ,ppan          => ponlinepan
												   ,pmbr          => ponlinembr);
						IF (ponlinevalue IS NULL)
						THEN
							s.say(' ' || cmethodname || '|OnlineDebit failed !!!', 2);
							ponlinetranid := NULL;
							IF (ponlinepriority = entry.use_two)
							THEN
								IF (remoteonline.geterrorcode() =
								   remoteonline.err_insufficientfunds)
								THEN
								
									setaccountdebiterror(sopenacc(this).accountno, 'Debit');
								
								ELSE
								
									IF (err.geterrorcode() = 0)
									THEN
										err.seterror(err.ue_other
													,cmethodname
													,'Error debiting TWO account: ' ||
													 remoteonline.geterrortext(remoteonline.geterrorcode()));
									END IF;
								
								END IF;
							
							ELSE
								s.say(' ' || cmethodname || '|ELSE_TWCMS|check ForbidDebit', 2);
								IF (forbiddebit())
								THEN
									s.say(' ' || cmethodname ||
										  '|ELSE_TWCMS|Debit TWCMS acc forbit'
										 ,2);
								
									setaccountdebiterror(sopenacc(this).accountno, 'Debit');
								
								END IF;
								s.say(' ' || cmethodname || '|ELSE_TWCMS|Debit TWCMS acc allow', 2);
							END IF;
						
						ELSIF (poonlinedebitremaincheck)
						THEN
						
							s.say(' ' || cmethodname || '|OnlineDebit success|pOnlineTranId=' ||
								  ponlinetranid || ', pOnlineValue=' || ponlinevalue
								 ,2);
							s.say(' ' || cmethodname || '|Change available|Acc=' || sopenacc(this)
								  .accountno || ', cur available: ' || sopenacc(this).available
								 ,2);
							sopenacc(this).available := sopenacc(this).available + ponlinevalue;
						
							s.say(' ' || cmethodname || '|new available (before twcms debit): ' || sopenacc(this)
								  .available
								 ,2);
						
							IF (sopenacc(this).available > sopenacc(this).remain)
							THEN
								s.say(' ' || cmethodname ||
									  '|Check available|Available > Remain|Available=' || sopenacc(this)
									  .available || ', Remain=' || sopenacc(this).remain
									 ,2);
								sopenacc(this).available := sopenacc(this).remain;
								s.say(' ' || cmethodname ||
									  '|new available (before twcms debit): ' || sopenacc(this)
									  .available
									 ,2);
							END IF;
						
						ELSE
							s.say(' ' || cmethodname || '|SKIP change available and remain|Acc=' || sopenacc(this)
								  .accountno || ', cur available: ' || sopenacc(this).available ||
								  ', cur remain: ' || sopenacc(this).remain
								 ,2);
						
						END IF;
					END IF;
				
				END IF;
			
			ELSIF (ponlinepriority IN (entry.use_twcms, entry.use_twcms_else_two))
			THEN
				IF (forbiddebit())
				THEN
					s.say(' ' || cmethodname || '|Forbid debit', 2);
					IF (ponlinepriority = entry.use_twcms)
					THEN
					
						setaccountdebiterror(sopenacc(this).accountno, 'Debit');
					
					ELSE
						s.say(' ' || cmethodname || '|ELSE_TWO|try OnlineDebit', 2);
						IF (ponlineacc IS NOT NULL)
						THEN
							vaccountrecord := getaccountrecord(ponlineacc);
							vaccremain     := vaccountrecord.remain;
							vaccoverdraft  := nvl(vaccountrecord.crdlimit, 0);
						END IF;
					
						IF (err.geterrorcode() = 0)
						THEN
							vremainenough := pcheck = entry.flnocheck OR
											 pcheck = entry.flcheck AND
											 vonlinevalue <= vaccremain + vaccoverdraft OR
											 pcheck = entry.flnooverdraft AND
											 vonlinevalue <= vaccremain;
							IF (NOT poonlinedebitremaincheck AND vremainenough AND
							   ponlinetranid IS NULL)
							THEN
								poonlinedebitremaincheck := TRUE;
							END IF;
							s.say(' ' || cmethodname || '|RemainEnough=' ||
								  booleantostring(vremainenough)
								 ,2);
							s.say(' ' || cmethodname || '|OnlineDebitRemainCheck4=' ||
								  booleantostring(poonlinedebitremaincheck)
								 ,2);
						
							IF (poonlinedebitremaincheck AND NOT vremainenough AND
							   ponlinetranid IS NULL)
							THEN
							
								s.say(' ' || cmethodname ||
									  '|Check remain|OnlineValue > Remain+OverDraft|vOnlineValue=' ||
									  vonlinevalue || ', Remain=' || sopenacc(this).remain ||
									  ', OverDraft=' || sopenacc(this).overdraft
									 ,2);
							
								setaccountdebiterror(sopenacc(this).accountno, 'Debit');
							
							END IF;
						
						END IF;
					
						IF (err.geterrorcode() = 0)
						THEN
						
							s.say(' ' || cmethodname || '|OnlineDebit|vOnlineAcc=' || vonlineacc ||
								  ', vOnlineValue=' || vonlinevalue
								 ,2);
							ponlinevalue := onlinedebit(pcheck
													   ,vonlineacc
													   ,vonlinevalue
													   ,ponlinetranid
													   ,pcheckonline
													   ,pusebonusdebt
													   ,pneednotify   => pneednotify
													   ,pfimicomment  => pfimicomment
													   ,ppan          => ponlinepan
													   ,pmbr          => ponlinembr);
							IF (ponlinevalue IS NULL)
							THEN
							
								err.seterror(err.ue_other
											,cmethodname
											,'Error debiting TWO account: ' ||
											 remoteonline.geterrortext(remoteonline.geterrorcode()));
							
							END IF;
						
						END IF;
					
						IF (err.geterrorcode() = 0)
						THEN
							IF (poonlinedebitremaincheck)
							THEN
							
								s.say(' ' || cmethodname || '|OnlineDebit success|pOnlineTranId=' ||
									  ponlinetranid || ', pOnlineValue=' || ponlinevalue
									 ,2);
								s.say(' ' || cmethodname || '|Change available|Acc=' || sopenacc(this)
									  .accountno || ', cur available: ' || sopenacc(this).available
									 ,2);
								sopenacc(this).available := sopenacc(this).available + ponlinevalue;
								s.say(' ' || cmethodname ||
									  '|new available (before twcms debit): ' || sopenacc(this)
									  .available
									 ,2);
								IF (sopenacc(this).available > sopenacc(this).remain)
								THEN
									s.say(' ' || cmethodname ||
										  '|Check available|Available > Remain|Available=' || sopenacc(this)
										  .available || ', Remain=' || sopenacc(this).remain
										 ,2);
									sopenacc(this).available := sopenacc(this).remain;
									s.say(' ' || cmethodname ||
										  '|new available (before twcms debit): ' || sopenacc(this)
										  .available
										 ,2);
								END IF;
							
							ELSE
								s.say(' ' || cmethodname ||
									  '|SKIP change available and remain|Acc=' || sopenacc(this)
									  .accountno || ', cur available: ' || sopenacc(this).available ||
									  ', cur remain: ' || sopenacc(this).remain
									 ,2);
							END IF;
						END IF;
					
					END IF;
				ELSE
					ponlinetranid := NULL;
					ponlinevalue  := NULL;
				END IF;
			ELSE
			
				err.seterror(err.ue_other, cmethodname, 'Invalid priority of funds usage');
			
			END IF;
		
		END IF;
	
		IF (err.geterrorcode() = 0)
		THEN
		
			sopenacc(this).remain := sopenacc(this).remain - pvalue;
			sopenacc(this).available := sopenacc(this).available - pvalue;
		
			voldremainupdatedate := sopenacc(this).remainupdatedate;
			sopenacc(this).remainupdatedate := seance.getoperdate();
		
			s.say(cpackagename || '.debit: Pre WriteObject: account.GetMode=' || account.getmode);
			writeobject(this);
			IF (err.geterrorcode() != 0)
			THEN
				sopenacc(this).remain := sopenacc(this).remain + pvalue;
				sopenacc(this).available := sopenacc(this).available + pvalue;
			
				sopenacc(this).remainupdatedate := voldremainupdatedate;
			
				ROLLBACK TO accountdebit;
			
			END IF;
		
		END IF;
	
		IF (err.geterrorcode() != 0)
		THEN
			registerdcerror(sopenacc(this).accountno
						   ,ponlineacc
						   ,pcheck
						   ,ponlinepriority
						   ,pvalue
						   ,ponlinevalue);
		END IF;
		RETURN err.geterrorcode();
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			registerdcerror(sopenacc(this).accountno
						   ,ponlineacc
						   ,pcheck
						   ,ponlinepriority
						   ,pvalue
						   ,ponlinevalue);
			RAISE;
		
	END;

	PROCEDURE deleteaccount
	(
		paccountno        IN typeaccountno
	   ,pcheckright       IN BOOLEAN := TRUE
	   ,ponlineprocessing IN BOOLEAN := FALSE
	   ,plog              IN BOOLEAN
	   ,pwithowner        IN BOOLEAN
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.DeleteAccount';
		vbranch NUMBER;
		vcount  NUMBER;
	
		verrorcontext err.typecontextrec;
	
		vobjectuid objectuid.typeobjectuid;
	
		vlockoptions options.typelockoptions;
		vclienttype  NUMBER;
		vplantype    NUMBER;
		vdummy       NUMBER;
		vowner       NUMBER := getidclientacc(paccountno);
	
		FUNCTION holdsexist RETURN BOOLEAN IS
		BEGIN
			FOR r IN (SELECT 0
					  FROM   textractdelay
					  WHERE  branch = vbranch
					  AND    debitaccountno = paccountno
					  UNION ALL
					  SELECT 0
					  FROM   textractdelay
					  WHERE  branch = vbranch
					  AND    creditaccountno = paccountno)
			LOOP
				RETURN TRUE;
			END LOOP;
			RETURN FALSE;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.HoldsExist');
				RAISE;
		END;
	
		FUNCTION holdcount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
			SELECT (SELECT COUNT(0)
					FROM   textractdelay
					WHERE  branch = vbranch
					AND    debitaccountno = paccountno) +
				   (SELECT COUNT(0)
					FROM   textractdelay
					WHERE  branch = vbranch
					AND    creditaccountno = paccountno)
			INTO   vcount
			FROM   dual;
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.HoldCount');
				RAISE;
		END;
	
		FUNCTION documentsexist RETURN BOOLEAN IS
		BEGIN
			FOR r IN (SELECT /*+ first_rows(1) */
					   0
					  FROM   tentry    e
							,tdocument d
					  WHERE  e.branch = vbranch
					  AND    e.debitaccount = paccountno
					  AND    d.branch = e.branch
					  AND    d.docno = e.docno
					  AND    d.newdocno IS NULL
					  AND    rownum = 1
					  UNION ALL
					  SELECT /*+ first_rows(1) */
					   0
					  FROM   tentry    e
							,tdocument d
					  WHERE  e.branch = vbranch
					  AND    e.creditaccount = paccountno
					  AND    d.branch = e.branch
					  AND    d.docno = e.docno
					  AND    d.newdocno IS NULL
					  AND    rownum = 1
					  UNION ALL
					  SELECT /*+ first_rows(1) */
					   0
					  FROM   tentryarc    ea
							,tdocumentarc da
					  WHERE  ea.branch = vbranch
					  AND    ea.debitaccount = paccountno
					  AND    da.branch = ea.branch
					  AND    da.docno = ea.docno
					  AND    da.newdocno IS NULL
					  AND    rownum = 1
					  UNION ALL
					  SELECT /*+ first_rows(1) */
					   0
					  FROM   tentryarc    ea
							,tdocumentarc da
					  WHERE  ea.branch = vbranch
					  AND    ea.creditaccount = paccountno
					  AND    da.branch = ea.branch
					  AND    da.docno = ea.docno
					  AND    da.newdocno IS NULL
					  AND    rownum = 1)
			LOOP
				RETURN TRUE;
			END LOOP;
			RETURN FALSE;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.DocumentsExist');
				RAISE;
		END;
	
		FUNCTION documentcount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
			SELECT COUNT(0)
			INTO   vcount
			FROM   (SELECT d.docno docno
					FROM   tentry    e
						  ,tdocument d
					WHERE  e.branch = vbranch
					AND    e.debitaccount = paccountno
					AND    d.branch = e.branch
					AND    d.docno = e.docno
					AND    d.newdocno IS NULL
					UNION
					SELECT d.docno docno
					FROM   tentry    e
						  ,tdocument d
					WHERE  e.branch = vbranch
					AND    e.creditaccount = paccountno
					AND    d.branch = e.branch
					AND    d.docno = e.docno
					AND    d.newdocno IS NULL
					UNION
					SELECT da.docno docno
					FROM   tentryarc    ea
						  ,tdocumentarc da
					WHERE  ea.branch = vbranch
					AND    ea.debitaccount = paccountno
					AND    da.branch = ea.branch
					AND    da.docno = ea.docno
					AND    da.newdocno IS NULL
					UNION
					SELECT da.docno docno
					FROM   tentryarc    ea
						  ,tdocumentarc da
					WHERE  ea.branch = vbranch
					AND    ea.creditaccount = paccountno
					AND    da.branch = ea.branch
					AND    da.docno = ea.docno
					AND    da.newdocno IS NULL);
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.DocumentCount');
				RAISE;
		END;
	
		FUNCTION contractsexist RETURN BOOLEAN IS
		BEGIN
			FOR r IN (SELECT 0
					  FROM   tcontractitem
					  WHERE  branch = vbranch
					  AND    itemtype = contracttype.itemaccount
					  AND    key = paccountno)
			LOOP
				RETURN TRUE;
			END LOOP;
			RETURN FALSE;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.ContractsExist');
				RAISE;
		END;
	
		FUNCTION contractcount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tcontractitem
			WHERE  branch = vbranch
			AND    itemtype = contracttype.itemaccount
			AND    key = paccountno;
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.ContractCount');
				RAISE;
		END;
	
		FUNCTION cardcount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tacc2card
			WHERE  branch = vbranch
			AND    accountno = paccountno;
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.CardCount');
				RAISE;
		END;
	
		FUNCTION cashoperationcount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tcashoperations
			WHERE  branch = vbranch
			AND    accountno = paccountno;
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.CashOperationCount');
				RAISE;
		END;
	
		FUNCTION customercount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tcustomer
			WHERE  branch = vbranch
			AND    accountno = paccountno;
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.CustomerCount');
				RAISE;
		END;
	
		FUNCTION loancoveragecount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tloancoverage
			WHERE  branch = vbranch
			AND    accountno = paccountno;
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.LoanCoverageCount');
				RAISE;
		END;
	
		FUNCTION regularpaymentcount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tregularpayment
			WHERE  branch = vbranch
			AND    accountno = paccountno;
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.RegularPaymentCount');
				RAISE;
		END;
	
		FUNCTION rvpblocksheetcount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
		
			EXECUTE IMMEDIATE 'select Count(0)' || ' from (select distinct Id' ||
							  '         from tRVPBlockSheet' || '         where Branch = :1' ||
							  '           and (CostAccount = :2' ||
							  '                or ReserveAccount = :3' ||
							  '                or RevenueAccount = :4))'
				INTO vcount
				USING IN vbranch, paccountno, paccountno, paccountno;
		
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.RVPBlockSheetCount');
				RAISE;
		END;
	
		FUNCTION rvpitemcorraccountcount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
		
			EXECUTE IMMEDIATE 'select Count(0)' || ' from (select distinct Id' ||
							  '         from tRVPItemCorrAccount' || '         where Branch = :1' ||
							  '           and (CostAccount = :2' ||
							  '                or RevenueAccount = :3))'
				INTO vcount
				USING IN vbranch, paccountno, paccountno;
		
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.RVPItemCorrAccountCount');
				RAISE;
		END;
	
		FUNCTION statementcount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tstatement
			WHERE  branch = vbranch
			AND    accountno = paccountno;
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.StatementCount');
				RAISE;
		END;
	
		FUNCTION tastamentcount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
			SELECT COUNT(*)
			INTO   vcount
			FROM   ttastamentaccount
			WHERE  branch = vbranch
			AND    accountno = paccountno;
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.TastamentCount');
				RAISE;
		END;
	
		FUNCTION voucheecount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
			SELECT COUNT(*)
			INTO   vcount
			FROM   tvoucheeaccount
			WHERE  branch = vbranch
			AND    accountno = paccountno;
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.VoucheeCount');
				RAISE;
		END;
	
		FUNCTION warrantcount RETURN NUMBER IS
			vcount NUMBER;
		BEGIN
			SELECT COUNT(*)
			INTO   vcount
			FROM   twarrantaccount
			WHERE  branch = vbranch
			AND    accountno = paccountno;
			RETURN vcount;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname || '.WarrantCount');
				RAISE;
		END;
	
		FUNCTION objectsexistdescription(psqlerrm IN VARCHAR2) RETURN VARCHAR2 IS
			vsqlerrm     VARCHAR2(1024);
			vdescription VARCHAR2(2048);
		BEGIN
			vsqlerrm := upper(psqlerrm);
			CASE
				WHEN (instr(vsqlerrm, 'FK_ACC2CARD_ACCOUNTNO') > 0) THEN
					vdescription := 'cards: ' || cardcount();
				WHEN (instr(vsqlerrm, 'FK_TCASHOPERATIONS') > 0) THEN
					vdescription := 'cashier requests: ' || cashoperationcount();
				WHEN (instr(vsqlerrm, 'FK_CUSTOMERACCOUNT') > 0) THEN
					vdescription := 'Telebank customers: ' || customercount();
				WHEN (instr(vsqlerrm, 'FK_TLOANCOVERAGE_ACCOUNTNO') > 0) THEN
					vdescription := 'contracts collateral: ' || loancoveragecount();
				WHEN (instr(vsqlerrm, 'FK_REGULARPAYMENT_ACCOUNT') > 0) THEN
					vdescription := 'recurring payments: ' || regularpaymentcount();
				WHEN ((instr(vsqlerrm, 'FK_TRVPBLOCKSHEET_RESERVE') > 0) OR
					 (instr(vsqlerrm, 'FK_TRVPBLOCKSHEET_COST') > 0) OR
					 (instr(vsqlerrm, 'FK_TRVPBLOCKSHEET_REVENUE') > 0)) THEN
					vdescription := 'hold accounts: ' || rvpblocksheetcount();
				WHEN ((instr(vsqlerrm, 'FK_TRVPITEMCORRACCOUNT_COST') > 0) OR
					 (instr(vsqlerrm, 'FK_TRVPITEMCORRACCOUNT_REVENUE') > 0)) THEN
					vdescription := 'correspondent accounts: ' || rvpitemcorraccountcount();
				WHEN (instr(vsqlerrm, 'FK_TSTATEMENT_ACC') > 0) THEN
					vdescription := 'statements: ' || statementcount();
				WHEN (instr(vsqlerrm, 'FK_TASTAMENTACCOUNT2') > 0) THEN
					vdescription := 'testaments: ' || tastamentcount();
				WHEN (instr(vsqlerrm, 'FK_TVOUCHEEACC_ACCOUNTNO') > 0) THEN
					vdescription := 'collaterals: ' || voucheecount();
				WHEN (instr(vsqlerrm, 'FK_WARRANTACCOUNT2') > 0) THEN
					vdescription := 'warrants: ' || warrantcount();
				ELSE
					vdescription := 'other objects (' || psqlerrm || ')';
			END CASE;
			RETURN vdescription;
		EXCEPTION
			WHEN OTHERS THEN
				s.say(cmethodname || '.ObjectsExistDescription() error: ' || SQLERRM());
				RETURN psqlerrm;
		END;
	
	BEGIN
	
		SAVEPOINT sp_accountdeleteaccount;
	
		IF (pcheckright AND NOT account.checkright(account.right_delete))
		THEN
			err.seterror(err.account_security_failure, cmethodname);
		
		ELSE
			err.seterror(0, cmethodname);
			vbranch := seance.getbranch();
		END IF;
	
		s.say('vBranch = ' || vbranch, 2);
		s.say('pCheckRight = ' || htools.b2s(pcheckright) ||
			  ' Account.CheckRight(Account.Right_Delete) = ' ||
			  htools.b2s(account.checkright(account.right_delete))
			 ,2);
	
		s.say('Err.GetErrorCode() = ' || err.geterrorcode(), 2);
	
		IF err.geterrorcode() = 0
		THEN
			DECLARE
				vrule NUMBER;
			
			BEGIN
			
				vplantype := planaccount.gettype(planaccount.getplanbyaccountno(paccountno));
				s.say(cmethodname || '|PlanType: ' || vplantype, 2);
				error.clear();
				vclienttype := account.getclienttypebyaccno(paccountno);
				s.say(cmethodname || '|vClientType = ' || vclienttype, 2);
			
				IF err.geterrorcode = 0
				THEN
					vrule := nvl(sqlblockoptions.getparameter(sqlblockoptions.cobj_account
															 ,sqlblockoptions.cblock_delete)
								,sqlblockoptions.crule_always);
					s.say('sDeleteMode=' || sdeletemode || ' vRule=' || vrule);
					IF sdeletemode = cdm_dialog
					   OR vrule = sqlblockoptions.crule_always
					THEN
						runcontrolblock(paccountno
									   ,vclienttype
									   ,(vplantype = planaccount.type_nonconsolidated)
									   ,accountblocks.cbtdelete);
					
					END IF;
				END IF;
			END;
		END IF;
		IF (err.geterrorcode() = 0 AND holdsexist())
		THEN
			err.seterror(err.account_objects_exist
						,cmethodname
						,'amounts on-hold: ' || holdcount());
		END IF;
	
		IF (err.geterrorcode() = 0 AND documentsexist())
		THEN
			err.seterror(err.account_objects_exist
						,cmethodname
						,'financial documents: ' || documentcount());
		END IF;
		IF (err.geterrorcode() = 0 AND contractsexist())
		THEN
			err.seterror(err.account_objects_exist, cmethodname, 'contract: ' || contractcount());
		END IF;
	
		IF (err.geterrorcode() = 0)
		THEN
		
			vlockoptions := getmultitasklockoptions();
		
			vdummy := object.capture(object_name
									,paccountno
									,pattempt      => vlockoptions.multitask_attempt
									,pattemptpause => vlockoptions.multitask_attemptpause);
			IF (err.geterrorcode() = err.object_busy)
			THEN
			
				err.seterror(err.account_busy, cmethodname, capturedobjectinfo(paccountno));
			
			ELSIF (err.geterrorcode() = 0)
			THEN
			
				evnaccountopen.erase(paccountno, getaccountrecord(paccountno).createdate);
			
				IF (err.geterrorcode() = 0)
				THEN
				
					vobjectuid := getobjectuid(paccountno, FALSE);
				
					IF vplantype = planaccount.type_nonconsolidated
					THEN
						s.say(cmethodname || '|NonConsolidated account|Deleting attributes', 2);
						objuserproperty.deleterecord(account_company
													,vobjectuid
													,account_company_bank);
					ELSE
						IF vclienttype = client.ct_persone
						THEN
							s.say(cmethodname ||
								  '|Consolidated persone account|Deleting attributes'
								 ,2);
							objuserproperty.deleterecord(account_private
														,vobjectuid
														,plog_clientid => getidclientbyaccno(paccountno));
						ELSIF vclienttype = client.ct_company
						THEN
							s.say(cmethodname ||
								  '|Consolidated corporate account|Deleting attributes'
								 ,2);
							objuserproperty.deleterecord(account_company, vobjectuid);
						END IF;
					END IF;
				
					IF (err.geterrorcode() = 0)
					THEN
					
						IF ponlineprocessing
						THEN
							IF remoteonline.deleteaccount(paccountno, TRUE) !=
							   remoteonline.err_approved
							THEN
								error.raiseerror('Error deleting account online: ' ||
												 remoteonline.geterrortext(remoteonline.geterrorcode)
												 
												 );
							END IF;
						END IF;
					
						DELETE FROM taccount
						WHERE  branch = vbranch
						AND    accountno = paccountno;
					
						IF (vobjectuid IS NULL)
						THEN
							vobjectuid := objectuid.getidbyaccount(paccountno, FALSE);
						END IF;
						IF (vobjectuid IS NOT NULL)
						THEN
						
							objectuid.freeuid(vobjectuid);
						
						END IF;
					
						setdataforexchange(paccountno);
					END IF;
				
					IF (err.geterrorcode() = 0)
					THEN
					
						object.release(object_name, paccountno);
					
					ELSE
						verrorcontext := err.getcontext();
						object.release(object_name, paccountno);
						err.putcontext(verrorcontext, cmethodname);
					END IF;
				ELSE
					error.raisewhenerr();
				END IF;
			ELSE
				error.raisewhenerr();
			END IF;
		
		END IF;
	
		IF (err.geterrorcode() != 0)
		THEN
			ROLLBACK TO sp_accountdeleteaccount;
			s.say('rollback to SP_AccountDeleteAccount', 2);
		
		ELSE
			IF plog
			THEN
				logdeletion(paccountno, pwithowner, vowner);
			END IF;
		
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			s.err(cmethodname);
		
			verrorcontext := err.getcontext();
			object.release(object_name, paccountno);
		
			err.putcontext(verrorcontext, cmethodname);
		
			IF (SQLCODE() = -2292)
			THEN
				err.seterror(err.account_objects_exist
							,cmethodname
							,objectsexistdescription(SQLERRM()));
			END IF;
		
			IF (err.geterrorcode() != 0)
			THEN
				BEGIN
					ROLLBACK TO sp_accountdeleteaccount;
					s.say('exception: rollback to SP_AccountDeleteAccount', 2);
				EXCEPTION
					WHEN OTHERS THEN
						s.say('WARNING! Error while rolling back deletion of account ' ||
							  paccountno || ': ' || SQLERRM()
							 ,2);
				END;
			END IF;
		
	END;

	FUNCTION dialogcreate
	(
		paccounttype IN NUMBER
	   ,pclienttype  IN PLS_INTEGER
	   ,pidclient    IN NUMBER := NULL
	) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(64) := cpackagename || '.DialogCreate';
		vdialog NUMBER;
		vpage1  NUMBER;
	
		vpage2 NUMBER;
	
	BEGIN
		vdialog := dialog.new('Open account', 0, 0, 80, 10, pextid => cwhere);
	
		dialog.inputinteger(vdialog, 'F_CLIENTTYPE', 0, 0, '');
		ktools.visible(vdialog, 'F_CLIENTTYPE', FALSE);
		dialog.putnumber(vdialog, 'F_CLIENTTYPE', pclienttype);
	
		dialog.inputinteger(vdialog, 'NoPlan', 0, 0, ' ');
		dialog.setitemattributies(vdialog
								 ,'NoPlan'
								 ,dialog.echooff || dialog.selectoff || dialog.updateoff);
		dialog.inputinteger(vdialog, 'AccountType', 0, 0, ' ');
		dialog.setitemattributies(vdialog
								 ,'AccountType'
								 ,dialog.echooff || dialog.selectoff || dialog.updateoff);
	
		dialog.hiddennumber(vdialog, 'IdClient', pidclient);
	
		dialog.bevel(vdialog, 1, 1, 79, 4, dialog.bevel_frame, TRUE, pcaption => 'Customer');
		dialog.textlabel(vdialog, 'ClientText1', 3, 2, 60, ' ');
		dialog.textlabel(vdialog, 'ClientText2', 3, 3, 60, ' ');
		dialog.textlabel(vdialog, 'ClientText3', 3, 4, 60, ' ');
		dialog.button(vdialog, 'Client', 65, 2, 13, 'Search', 0, 0, 'Define acct holder');
	
		dialog.pagelist(vdialog, 'PageList', 1, 6, 79, 13);
		vpage1 := dialog.page(vdialog, 'PageList', 'General');
	
		accounttype.makeitem(vpage1
							,'AccType'
							,18
							,2
							,5
							,
							 
							 'Type:'
							,
							 
							 'Select account type from list'
							,pclienttype
							,40
							,FALSE
							,paccountcheckright => account.right_open);
	
		dialog.setitempre(vdialog, 'AccType', cpackagename || '.DialogCreateProc', dialog.proctype);
		dialog.setitempost(vdialog
						  ,'AccType'
						  ,cpackagename || '.DialogCreateProc'
						  ,dialog.proctype);
	
		dialog.inputchar(vpage1
						,'AccountNo'
						,18
						,3
						,20
						,'Enter acct No (created automatically if empty)'
						,
						 
						 20
						,'   No:');
		dialog.inputchar(vpage1
						,'ExternalAccountNo'
						,50
						,3
						,27
						,'Enter account external No (created automatically if empty)'
						,35
						,'External:');
	
		referenceacct_typ.makeitem(vpage1
								  ,'ACCT_TYPName'
								  ,18
								  ,4
								  ,2
								  ,
								   
								   'Type in PC:'
								  ,
								   
								   'Select account type in processing center'
								  ,30);
		referenceacct_stat.makeitem(vpage1
								   ,'ACCT_STATName'
								   ,18
								   ,5
								   ,2
								   ,
									
									'Status in PC:'
								   ,
									
									'Select account status in processing center'
								   ,30);
		dialog.inputchar(vpage1
						,'Remark'
						,18
						,6
						,59
						,'Enter acct comment'
						,
						 
						 250
						,
						 
						 '    Comment:');
	
		vpage2 := dialog.page(vdialog, 'PageList', 'Financial profile');
		finaccountinstance.makepage(vpage2
								   ,77
								   ,12
								   ,account.object_name
								   ,account.getrightkey(account.right_finprofile));
	
		IF (pclienttype = client.ct_persone)
		THEN
			objuserproperty.addpage(vdialog, 'PageList', 'User', 10, account_private);
		ELSIF (pclienttype = client.ct_company)
		THEN
			objuserproperty.addpage(vdialog, 'PageList', 'User', 10, account_company);
		END IF;
	
		dialog.button(vdialog, 'Ok', 29, 20, 10, '  Enter', dialog.cmok, 0, 'Open new acct');
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
		dialog.setitemattributies(vdialog, 'Ok', dialog.selectoff);
		dialog.button(vdialog
					 ,'Cancel'
					 ,41
					 ,20
					 ,10
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel account opening');
	
		dialog.setdialogpre(vdialog, cpackagename || '.DialogCreateProc');
		dialog.setdialogpost(vdialog, cpackagename || '.DialogCreateProc');
		dialog.setdialogvalid(vdialog, cpackagename || '.DialogCreateProc');
		dialog.setitempre(vdialog, 'Client', cpackagename || '.DialogCreateProc', dialog.proctype);
		dialog.setitempre(vdialog
						 ,'NoPlanName'
						 ,cpackagename || '.DialogCreateProc'
						 ,dialog.proctype);
		dialog.setitempost(vdialog, 'Client', cpackagename || '.DialogCreateProc', dialog.proctype);
		dialog.setitempost(vdialog
						  ,'NoPlanName'
						  ,cpackagename || '.DialogCreateProc'
						  ,dialog.proctype);
		dialog.putnumber(vdialog, 'AccountType', paccounttype);
	
		RETURN vdialog;
	END;

	PROCEDURE dialogcreateproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		vidclient     taccount.idclient%TYPE;
		vaccountno    typeaccountno;
		vdialog       NUMBER;
		vclienthandle NUMBER;
		vcode         NUMBER;
		vclienttype   NUMBER;
	
		PROCEDURE setparam IS
			vdmcode  VARCHAR(2);
			vacctype NUMBER;
		BEGIN
		
			vacctype := accounttype.getdata(pdialog, 'AccType');
		
			vdmcode := accounttype.getdatamemberchar(vacctype, 'ACCT_TYP');
			IF NOT vdmcode IS NULL
			THEN
				referenceacct_typ.changeitem(pdialog, 'ACCT_TYPName', vdmcode, TRUE);
			END IF;
			vdmcode := accounttype.getdatamemberchar(vacctype, 'ACCT_STAT');
			IF NOT vdmcode IS NULL
			THEN
				referenceacct_stat.changeitem(pdialog, 'ACCT_STATName', vdmcode, TRUE);
			END IF;
		
			dialog.putnumber(pdialog, 'NoPlan', accounttype.getnoplan(vacctype));
			dialog.putnumber(pdialog, 'AccountType', vacctype);
			s.say('NoPlan  - ' || dialog.getnumber(pdialog, 'NoPlan'), 3);
			s.say('AccountType  - ' || dialog.getnumber(pdialog, 'AccountType'), 3);
		
			IF (vacctype IS NULL)
			THEN
				finaccountinstance.loadpage(pdialog, NULL, NULL);
				finaccountinstance.enablepage(pdialog, FALSE);
			ELSE
				finaccountinstance.enablepage(pdialog, TRUE);
				finaccountinstance.loadpage(pdialog, accounttype.getfinprofile(vacctype), NULL);
			END IF;
		
		END;
	
	BEGIN
		s.say(cpackagename || '.DialogCreateProc pWhat=' || pwhat || ' pItemName=' || pitemname);
		IF pwhat = dialog.wtdialogpre
		THEN
			SAVEPOINT accountdialogcreate;
		
			vidclient := dialog.getnumber(pdialog, 'IdClient');
			IF vidclient IS NOT NULL
			THEN
				vclienthandle := client.newobject(vidclient, 'R');
				dialog.putchar(pdialog
							  ,'ClientText1'
							  ,service.cpad(client.getcardtext(vclienthandle, 1)
											
											|| ' (' || to_char(vidclient) || ')'
										   ,
											
											60
										   ,' '));
				dialog.putchar(pdialog
							  ,'ClientText2'
							  ,service.cpad(client.getcardtext(vclienthandle, 2), 60, ' '));
				dialog.putchar(pdialog
							  ,'ClientText3'
							  ,service.cpad(client.getcardtext(vclienthandle, 3), 60, ' '));
				client.freeobject(vclienthandle);
				dialog.setitemattributies(pdialog, 'Ok', dialog.selecton);
				dialog.setitemattributies(pdialog, 'Client', dialog.selectoff);
				dialog.goitem(pdialog, 'Ok');
			ELSE
				dialog.putchar(pdialog, 'ClientText1', NULL);
				dialog.putchar(pdialog, 'ClientText2', NULL);
				dialog.putchar(pdialog, 'ClientText3', NULL);
				dialog.setitemattributies(pdialog, 'Ok', dialog.selectoff);
				dialog.setitemattributies(pdialog, 'Client', dialog.selecton);
			END IF;
		
			dialog.putchar(pdialog, 'AccountNo', NULL);
		
			dialog.putchar(pdialog, 'ExternalAccountNo', NULL);
		
			dialog.putchar(pdialog, 'Remark', NULL);
		
			finaccountinstance.loadpage(pdialog, NULL, NULL);
			finaccountinstance.enablepage(pdialog, FALSE);
		
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF upper(pitemname) = 'CLIENT'
			THEN
			
				dialog.setitemdialog(pdialog
									,pitemname
									,listclient.dialogdefine(dialog.getnumber(pdialog
																			 ,'F_CLIENTTYPE')));
			
			ELSIF upper(pitemname) = 'ACCTYPE'
			THEN
				vcode := listaccounttype.selectaccounttype(dialog.getnumber(pdialog, 'F_CLIENTTYPE')
														  ,account.right_open
														  ,
														   
														   pactivity => listaccounttype.acctype_active);
			
				IF vcode IS NOT NULL
				THEN
					accounttype.setdata(pdialog, pitemname, vcode);
					setparam;
				END IF;
			END IF;
		
		ELSIF pwhat = dialog.wtitempost
		THEN
			IF upper(pitemname) = 'CLIENT'
			THEN
				err.seterror(0, cpackagename || '.DialogCreateProc');
			
				vdialog   := dialog.getitemdialog(pdialog, 'Client');
				vidclient := listclient.dialogdefinegetidclient(vdialog);
			
				IF nvl(vidclient, 0) != 0
				THEN
					vclienthandle := client.newobject(vidclient, 'R');
					dialog.putnumber(pdialog, 'IdClient', vidclient);
					dialog.putchar(pdialog
								  ,'ClientText1'
								  ,service.cpad(client.getcardtext(vclienthandle, 1)
												
												|| ' (' || to_char(vidclient) || ')'
											   ,
												
												60
											   ,' '));
					dialog.putchar(pdialog
								  ,'ClientText2'
								  ,service.cpad(client.getcardtext(vclienthandle, 2), 60, ' '));
					dialog.putchar(pdialog
								  ,'ClientText3'
								  ,service.cpad(client.getcardtext(vclienthandle, 3), 60, ' '));
					dialog.setitemattributies(pdialog, 'Ok', dialog.selecton);
				
					dialog.goitem(pdialog, 'Ok');
					client.freeobject(vclienthandle);
				END IF;
			
				IF err.geterrorcode != 0
				THEN
					service.sayerr(pdialog, 'Warning !');
					dialog.goitem(pdialog, pitemname);
				END IF;
			
				vclienttype := client.getclienttype(dialog.getnumber(pdialog, 'IdClient'));
				IF (vclienttype = client.ct_persone)
				THEN
				
					objuserproperty.fillpage(pdialog
											,account.account_private
											,powneruid               => NULL
											,plog_clientid           => dialog.getnumber(pdialog
																						,'IdClient'));
				
				ELSIF (vclienttype = client.ct_company)
				THEN
				
					objuserproperty.fillpage(pdialog, account.account_company, powneruid => NULL);
				
				END IF;
			
			END IF;
			dialog.destroy(dialog.getitemdialog(pdialog, pitemname));
			dialog.setitemdialog(pdialog, pitemname, 0);
		
		ELSIF pwhat = dialog.wt_nextfield
		THEN
			IF upper(pitemname) = 'ACCTYPE'
			THEN
				accounttype.setdata(pdialog, pitemname, dialog.getchar(pdialog, 'ACCTYPE'));
				setparam;
			END IF;
		
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			IF pcmd = dialog.cmok
			THEN
				err.seterror(0, cpackagename || '.DialogCreateProc');
			
				IF nvl(accounttype.getnoplan(accounttype.getdata(pdialog, 'AccType')), -1) = -1
				   AND nvl(accounttype.getaccmap(accounttype.getdata(pdialog, 'AccType')), -1) = -1
				THEN
					dialog.sethothint(pdialog, 'Error: Field not defined');
					dialog.goitem(pdialog, 'AccType');
					RETURN;
				END IF;
			
				IF nvl(accounttype.getnoplan(accounttype.getdata(pdialog, 'AccType')), -1) = -1
				   AND
				   nvl(accounttype.getaccmap(accounttype.getdata(pdialog, 'AccType')), -1) <> -1
				THEN
					dialog.putnumber(pdialog
									,'NoPlan'
									,accountmap.resolveplan(accounttype.getaccmap(accounttype.getdata(pdialog
																									 ,'AccType'))
														   ,seance.getbranchpart));
				END IF;
			
				IF nvl(dialog.getnumber(pdialog, 'NoPlan'), -1) = -1
				THEN
					dialog.sethothint(pdialog, 'Error: field not defined.');
					dialog.goitem(pdialog, 'AccType');
					RETURN;
				END IF;
			
				IF referenceacct_typ.getitemdata(pdialog, 'ACCT_TYPName') IS NULL
				THEN
					dialog.sethothint(pdialog, 'Error: Field not defined');
					dialog.goitem(pdialog, 'ACCT_TYPName');
					RETURN;
				END IF;
			
				IF referenceacct_stat.getitemdata(pdialog, 'ACCT_STATName') IS NULL
				THEN
					dialog.sethothint(pdialog, 'Error: Field not defined');
					dialog.goitem(pdialog, 'ACCT_STATName');
					RETURN;
				END IF;
			
				vclienttype := client.getclienttype(dialog.getnumber(pdialog, 'IdClient'));
				IF (vclienttype = client.ct_persone)
				THEN
					IF (NOT objuserproperty.validpage(pdialog, account_private))
					THEN
						RETURN;
					END IF;
				ELSIF (vclienttype = client.ct_company)
				THEN
					IF (NOT objuserproperty.validpage(pdialog, account_company))
					THEN
						RETURN;
					END IF;
				END IF;
			
				SAVEPOINT sp_acc_crpr;
			
				vaccountno := createobject(pdialog);
				s.say('6 *** Post CreateObject: Err.GetErrorCode=' || err.geterrorcode());
				IF (err.geterrorcode() = -20111 AND error.getcode() != 0)
				THEN
				
					ROLLBACK TO sp_acc_crpr;
				
					error.showerror();
					dialog.goitem(pdialog, pitemname);
					RETURN;
				ELSIF (err.geterrorcode() != 0)
				THEN
				
					ROLLBACK TO sp_acc_crpr;
				
					htools.message('Warning!', err.gettext());
					dialog.goitem(pdialog, pitemname);
					RETURN;
				END IF;
			
				dialog.putchar(pdialog, 'AccountNo', vaccountno);
			
			END IF;
		
		ELSIF pwhat = dialog.wtdialogpost
		THEN
			IF err.geterrorcode != 0
			   OR dialog.getdialogcommand(pdialog) != dialog.cmok
			THEN
				BEGIN
					ROLLBACK TO accountdialogcreate;
				EXCEPTION
					WHEN OTHERS THEN
						NULL;
				END;
			ELSE
				COMMIT;
			END IF;
		END IF;
	END;

	FUNCTION dialogcreategetaccountno(pdialog IN NUMBER) RETURN VARCHAR IS
	BEGIN
		IF dialog.getdialogcommand(pdialog) = dialog.cmok
		THEN
			RETURN dialog.getchar(pdialog, 'AccountNo');
		ELSE
			RETURN NULL;
		END IF;
	END;

	FUNCTION dialogdelete(paccountno IN typeaccountno) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(64) := cpackagename || '.DialogDelete';
		vdialog NUMBER;
	BEGIN
		vdialog := dialog.new('Delete account', 0, 0, 58, 11, pextid => cwhere);
	
		dialog.textlabel(vdialog, 'ClientText1', 4, 2, 50, ' ');
		dialog.textlabel(vdialog, 'ClientText2', 4, 3, 50, ' ');
		dialog.textlabel(vdialog, 'ClientText3', 4, 4, 50, ' ');
		dialog.textlabel(vdialog, 'AccountText', 4, 5, 50, ' ');
	
		dialog.inputchar(vdialog, 'AccountNo', 0, 0, 20, ' ');
		dialog.setitemattributies(vdialog
								 ,'AccountNo'
								 ,dialog.echooff || dialog.selectoff || dialog.updateoff);
	
		dialog.hiddennumber(vdialog, 'IdClient');
	
		dialog.checkbox(vdialog
					   ,'DeleteClient'
					   ,6
					   ,6
					   ,44
					   ,1
					   ,'Specify reason for deleting acct holder data');
		dialog.listaddrecord(vdialog, 'DeleteClient', 'Delete acct holder data', 0, 0);
	
		dialog.button(vdialog, 'Ok', 17, 9, 11, '  Delete', dialog.cmok, 0, 'Delete account');
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
		dialog.button(vdialog, 'Cancel', 30, 9, 9, '  Cancel', dialog.cmcancel, 0, 'Cancel');
	
		dialog.setdialogpre(vdialog, cpackagename || '.DialogDeleteProc');
		dialog.setdialogvalid(vdialog, cpackagename || '.DialogDeleteProc');
	
		dialog.putchar(vdialog, 'AccountNo', paccountno);
	
		RETURN vdialog;
	END;

	PROCEDURE dialogdeleteproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		vaccountno     VARCHAR(20);
		vaccounthandle NUMBER;
		vclienthandle  NUMBER;
		vidclient      NUMBER;
	BEGIN
		IF pwhat = dialog.wtdialogpre
		THEN
			vaccountno     := dialog.getchar(pdialog, 'AccountNo');
			vaccounthandle := newobject(vaccountno, 'R');
			IF vaccounthandle = 0
			THEN
				service.sayerr(pdialog, 'Warning !');
				dialog.abort(pdialog);
				RETURN;
			END IF;
			vidclient := account.getidclient(vaccounthandle);
			dialog.putnumber(pdialog, 'IdClient', vidclient);
			freeobject(vaccounthandle);
		
			vclienthandle := client.newobject(vidclient, 'R');
			IF vclienthandle != 0
			THEN
				dialog.putchar(pdialog
							  ,'ClientText1'
							  ,service.cpad(client.getcardtext(vclienthandle, 1) || ' (' ||
											to_char(vidclient) || ')'
										   ,50
										   ,' '));
				dialog.putchar(pdialog
							  ,'ClientText2'
							  ,service.cpad(client.getcardtext(vclienthandle, 2), 50, ' '));
				dialog.putchar(pdialog
							  ,'ClientText3'
							  ,service.cpad(client.getcardtext(vclienthandle, 3), 50, ' '));
				client.freeobject(vclienthandle);
			END IF;
		
			dialog.putchar(pdialog, 'AccountText', service.cpad('Acct: ' || vaccountno, 50, ' '));
			dialog.putchar(pdialog, 'DeleteClient', sdeleteclient);
		
		ELSIF (pwhat = dialog.wtdialogvalid)
		THEN
			SAVEPOINT accountdialogdelete;
		
			BEGIN
			
				vaccountno    := dialog.getchar(pdialog, 'AccountNo');
				sdeleteclient := dialog.getchar(pdialog, 'DeleteClient');
				sdeletemode   := cdm_dialog;
			
				account.deleteaccount(vaccountno, plog => TRUE, pwithowner => sdeleteclient = '1');
			
				error.raisewhenerr();
			
				IF sdeleteclient = '1'
				THEN
					client.deleteclient(dialog.getnumber(pdialog, 'IdClient'));
				
					error.raisewhenerr();
				
				END IF;
			
				COMMIT;
			
			EXCEPTION
				WHEN OTHERS THEN
					error.save(cpackagename || '.DialogDeleteProc/wtDialogValid');
					ROLLBACK TO accountdialogdelete;
					RAISE;
			END;
		
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.DialogDeleteProc');
			error.showerror();
			IF (pwhat = dialog.wtdialogpre)
			THEN
				dialog.destroy(pdialog);
				RAISE;
			ELSIF (pwhat = dialog.wtdialogvalid)
			THEN
				dialog.cancelclose(pdialog);
				dialog.goitem(pdialog, 'Cancel');
			END IF;
		
	END;

	FUNCTION exist(paccountno IN typeaccountno) RETURN NUMBER IS
		cwhere     VARCHAR2(100) := cpackagename || '.Exist';
		vaccountno typeaccountno;
		vbranch    NUMBER := seance.getbranch();
	BEGIN
		err.seterror(0, cpackagename || '.Exist');
		s.say(cwhere || '|vBranch = ' || vbranch || ', pAccountNo = ' || paccountno);
		BEGIN
			SELECT accountno
			INTO   vaccountno
			FROM   taccount
			WHERE  branch = vbranch
			AND    accountno = ltrim(rtrim(paccountno));
		EXCEPTION
			WHEN no_data_found THEN
				setaccountnotfounderror(paccountno, 'Exist');
				s.say(cwhere);
			WHEN OTHERS THEN
				err.seterror(SQLCODE, cpackagename || '.Exist');
		END;
		RETURN err.geterrorcode;
	END;

	FUNCTION accountexist(paccountno IN typeaccountno) RETURN BOOLEAN IS
		cwhere  VARCHAR2(100) := cpackagename || '.AccountExist';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		s.say(cwhere || '|vBranch = ' || vbranch || ', pAccountNo = ' || paccountno);
		FOR i IN (SELECT *
				  FROM   taccount
				  WHERE  branch = vbranch
				  AND    accountno = ltrim(rtrim(paccountno)))
		LOOP
			RETURN TRUE;
		END LOOP;
		RETURN FALSE;
	END;

	PROCEDURE fillsecurityarray
	(
		plevel IN NUMBER
	   ,pkey   IN VARCHAR
	) IS
		vatemplates apitypes.typesotemplatearray;
		i           PLS_INTEGER;
		vid         NUMBER;
		vbranch     NUMBER := seance.getbranch();
		CURSOR c1 IS
			SELECT accounttype
				  ,NAME
			FROM   taccounttype
			WHERE  branch = vbranch
			ORDER  BY accounttype;
	
	BEGIN
		security.cleararray();
	
		IF plevel = 1
		THEN
			security.stitle := 'List of allowed actions';
		
			security.addrecord(right_view, 'View');
			security.addrecord(right_open, 'Open');
			security.addrecord(right_modify, 'Modification');
			security.addrecord(right_delete, 'Delete', TRUE);
		
			security.addrecord(right_finprofile, 'Financial profile');
		
			security.addrecord(right_view_all_branchpart, 'View accounts of all branches', TRUE);
			security.addrecord(right_view_vip, 'View VIP accounts', TRUE);
			security.addrecord(right_view_vip_all_branchpart
							  ,'View VIP accounts of all branches'
							  ,TRUE);
			security.addrecord(right_viewfinattrs, 'View financial attributes');
			security.addrecord(right_generatestatement, 'Generate statement');
		
			security.addrecord(right_arrest, 'Arrests');
			security.addrecord(right_perstatement, 'Periodic statements');
			security.addrecord(right_notification, 'Notifications');
		
			security.addrecord(right_block, 'Blocks of additional control', TRUE);
			security.addrecord(right_reference, 'Dictionaries');
			security.addrecord(right_save_search_res, 'Save search results to file');
		
		ELSIF plevel = 2
		THEN
			security.sarraysize := 0;
			IF (substr(pkey, 2, 1) = right_modify)
			THEN
				security.stitle := 'List of allowed actions';
			
				security.addrecord(right_modify_attr, 'Modify attributes', TRUE);
				security.addrecord(right_modify_oper, 'Perform operations');
			
				security.addrecord(right_modify_tran_reverse, 'Reverse transaction', TRUE);
				security.addrecord(right_del_hold, 'Delete holds', TRUE);
				security.addrecord(right_cancel_hold, 'Cancel holds', TRUE);
				security.addrecord(right_move_hold, 'Transfer holds', TRUE);
				security.addrecord(right_change_client, 'Change customer', TRUE);
				security.addrecord(right_modify_branchpart, 'Change branch', TRUE);
				security.addrecord(right_modify_limits, 'Change account limits', TRUE);
				security.addrecord(right_del_cash_reqs, 'Delete cashier requests', TRUE);
				security.addrecord(right_undo_cash_reqs
								  ,'Cancel performing cashier requests'
								  ,TRUE);
			
			ELSIF (substr(pkey, 2, 1) = right_reference)
			THEN
				security.stitle := 'Dictionaries';
			
				security.addrecord(right_reference_view, 'View', TRUE);
				security.addrecord(right_reference_modify, 'Modification', TRUE);
			
			ELSIF (substr(pkey, 1, 12) = '|' || right_finprofile || '|')
			THEN
				finaccountinstance.fillsecurityarray();
			
			ELSIF (substr(pkey, 2, length(right_arrest)) = right_arrest)
			THEN
				security.addrecord(right_add_arrest, 'Add arrested amounts');
				security.addrecord(right_modify_arrest, 'Modify arrested amounts');
				security.addrecord(right_delete_arrest, 'Delete arrested amounts');
			
			ELSIF (substr(pkey, 2, length(right_notification)) = right_notification)
			THEN
				security.addrecord(right_add_notification, 'Add notifications');
				security.addrecord(right_modify_notification, 'Modify notifications');
				security.addrecord(right_delete_notification, 'Delete notifications');
			
			ELSIF (substr(pkey, 2, length(right_perstatement)) = right_perstatement)
			THEN
				security.addrecord(right_add_perstatement, 'Add periodic statements');
				security.addrecord(right_modify_perstatement, 'Modify periodic statements');
				security.addrecord(right_delete_perstatement, 'Delete periodic statements');
			
			ELSE
				security.stitle := 'List of acct types';
				IF (substr(pkey, 2, 1) IN (right_view, right_open) OR
				   substr(pkey, 2, length(right_viewfinattrs)) = right_viewfinattrs OR
				   substr(pkey, 2, length(right_generatestatement)) = right_generatestatement)
				THEN
				
					FOR i IN c1
					LOOP
					
						security.addrecord(i.accounttype, i.name, TRUE);
					END LOOP;
				
				END IF;
			END IF;
		
		ELSIF plevel = 3
		THEN
			security.sarraysize := 0;
		
			IF (pkey = '|' || right_modify || '|' || right_modify_oper || '|')
			THEN
				FOR r IN c1
				LOOP
					security.addrecord(r.accounttype, r.name);
				END LOOP;
			
			ELSIF (substr(pkey, 2, length(right_arrest)) = right_arrest OR
				  substr(pkey, 2, length(right_notification)) = right_notification OR
				  substr(pkey, 2, length(right_perstatement)) = right_perstatement)
			THEN
				FOR r IN c1
				LOOP
					security.addrecord(r.accounttype, r.name, TRUE);
				END LOOP;
			END IF;
		
		ELSIF (plevel = 4)
		THEN
			security.sarraysize := 0;
			IF (substr(pkey, 1, 6) = '|' || right_modify || '|' || right_modify_oper || '|')
			THEN
				i := instr(pkey, '|', 7);
				IF (i > 7)
				THEN
					BEGIN
						vid := to_number(substr(pkey, 7, i - 7));
						IF (vid IS NOT NULL)
						THEN
							security.addrecord(caoimark, 'Set / Remove mark', TRUE);
							security.addrecord(caoiarrest, 'Arrest / Cancel arrest', TRUE);
							security.addrecord(caoinosub
											  ,'Prohibit / Permit debit operations'
											  ,TRUE);
							security.addrecord(caoibook, 'Change passbook issue flag', TRUE);
							security.addrecord(caoiundoclose, 'Undo account closure', TRUE);
							vatemplates := sot_core.gettemplates(sot_core.ctcaccounttype
																,vid
																,FALSE);
							i           := vatemplates.first();
							WHILE (i IS NOT NULL)
							LOOP
								security.addrecord(vatemplates(i).id, vatemplates(i).name, TRUE);
								i := vatemplates.next(i);
							END LOOP;
						END IF;
					EXCEPTION
						WHEN OTHERS THEN
							NULL;
					END;
				END IF;
			END IF;
		ELSE
			security.sarraysize := 0;
		END IF;
	END;

	FUNCTION getsecurityarray
	(
		plevel          IN NUMBER
	   ,pkey            IN VARCHAR2
	   ,pnodenumber     NUMBER := NULL
	   ,psearchtemplate VARCHAR2 := NULL
	) RETURN custom_security.typerights IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.GetSecurityArray';
		vatemplates apitypes.typesotemplatearray;
		i           PLS_INTEGER;
		vid         NUMBER;
		vbranch     NUMBER := seance.getbranch;
		varights    custom_security.typerights;
		vindex      NUMBER := 0;
	
		PROCEDURE addrecord
		(
			pkey   VARCHAR2
		   ,ptext  VARCHAR2
		   ,pfinal BOOLEAN := FALSE
		) IS
		BEGIN
			vindex := vindex + 1;
			varights(vindex).key := pkey;
			varights(vindex).text := ptext;
			varights(vindex).final := pfinal;
		END;
	
		PROCEDURE getcursorrights(pfinal IN BOOLEAN) IS
		BEGIN
			s.say(cwhere || '.GetCursorRights begin');
		
			IF psearchtemplate IS NOT NULL
			   AND NOT ssearchrights
			THEN
				sarrsize(plevel)(pkey) := 0;
				ssearchrights := TRUE;
			ELSE
				IF psearchtemplate IS NULL
				   AND ssearchrights
				THEN
					sarrsize(plevel)(pkey) := 0;
					ssearchrights := FALSE;
				END IF;
			END IF;
		
			IF NOT sarrsize.exists(plevel)
			   OR NOT sarrsize(plevel).exists(pkey)
			THEN
				sarrsize(plevel)(pkey) := 0;
			END IF;
		
			FOR i IN (SELECT *
					  FROM   (SELECT accounttype
									,NAME
									,row_number() over(ORDER BY accounttype) row_num
							  FROM   taccounttype
							  WHERE  branch = vbranch
							  AND    (psearchtemplate IS NULL OR
									CASE
										WHEN instr(psearchtemplate, '%') > 0 THEN
										 1
										ELSE
										 0
									END = 1 AND lower(NAME) LIKE psearchtemplate OR
									CASE
										WHEN instr(psearchtemplate, '%') = 0 THEN
										 1
										ELSE
										 0
									END = 1 AND NAME = psearchtemplate)) tab
					  WHERE  (pnodenumber IS NOT NULL AND row_num BETWEEN 1 + sarrsize(plevel)
							  (pkey) AND pnodenumber + sarrsize(plevel) (pkey))
					  OR     (pnodenumber IS NULL))
			LOOP
				addrecord(i.accounttype, i.name, pfinal);
			END LOOP;
		
			sarrsize(plevel)(pkey) := sarrsize(plevel) (pkey) + nvl(pnodenumber, 0);
			s.say(cwhere || '.GetCursorRights end. vaRights count: ' || varights.count);
		END;
	
	BEGIN
		s.say(cwhere || ' Begin. pLevel: ' || plevel || ', pKey: ' || pkey || ', pNodeNumber: ' ||
			  pnodenumber || ', pSearchTemplate: ' || psearchtemplate);
	
		IF plevel = 1
		THEN
			security.stitle := 'List of allowed actions';
			addrecord(right_view, 'View');
			addrecord(right_open, 'Open');
			addrecord(right_modify, 'Modification');
			addrecord(right_delete, 'Delete', TRUE);
			addrecord(right_finprofile, 'Financial profile');
			addrecord(right_view_all_branchpart, 'View accounts of all branches', TRUE);
			addrecord(right_view_vip, 'View VIP accounts', TRUE);
			addrecord(right_view_vip_all_branchpart, 'View VIP accounts of all branches', TRUE);
			addrecord(right_viewfinattrs, 'View financial attributes');
			addrecord(right_generatestatement, 'Generate statement');
			addrecord(right_arrest, 'Arrests');
			addrecord(right_perstatement, 'Periodic statements');
			addrecord(right_notification, 'Notifications');
			addrecord(right_block, 'Blocks of additional control', TRUE);
			addrecord(right_reference, 'Dictionaries');
			addrecord(right_save_search_res, 'Save search results to file');
		
		ELSIF plevel = 2
		THEN
		
			IF substr(pkey, 2, 1) = right_modify
			THEN
				security.stitle := 'List of allowed actions';
				addrecord(right_modify_attr, 'Modify attributes', TRUE);
				addrecord(right_modify_oper, 'Perform operations');
				addrecord(right_modify_tran_reverse, 'Reverse transaction', TRUE);
				addrecord(right_del_hold, 'Delete holds', TRUE);
				addrecord(right_cancel_hold, 'Cancel holds', TRUE);
				addrecord(right_move_hold, 'Transfer holds', TRUE);
				addrecord(right_change_client, 'Change customer', TRUE);
				addrecord(right_modify_branchpart, 'Change branch', TRUE);
				addrecord(right_modify_limits, 'Change account limits', TRUE);
				addrecord(right_del_cash_reqs, 'Delete cashier requests', TRUE);
				addrecord(right_undo_cash_reqs, 'Cancel performing cashier requests', TRUE);
			
			ELSIF substr(pkey, 2, 1) = right_reference
			THEN
				security.stitle := 'Dictionaries';
				addrecord(right_reference_view, 'View', TRUE);
				addrecord(right_reference_modify, 'Modification', TRUE);
			
			ELSIF substr(pkey, 1, 12) = '|' || right_finprofile || '|'
			THEN
				varights := custom_finaccountinstance.getsecurityarray;
			
			ELSIF substr(pkey, 2, length(right_arrest)) = right_arrest
			THEN
				addrecord(right_add_arrest, 'Add arrested amounts');
				addrecord(right_modify_arrest, 'Modify arrested amounts');
				addrecord(right_delete_arrest, 'Delete arrested amounts');
			
			ELSIF substr(pkey, 2, length(right_notification)) = right_notification
			THEN
				addrecord(right_add_notification, 'Add notifications');
				addrecord(right_modify_notification, 'Modify notifications');
				addrecord(right_delete_notification, 'Delete notifications');
			
			ELSIF substr(pkey, 2, length(right_perstatement)) = right_perstatement
			THEN
				addrecord(right_add_perstatement, 'Add periodic statements');
				addrecord(right_modify_perstatement, 'Modify periodic statements');
				addrecord(right_delete_perstatement, 'Delete periodic statements');
			
			ELSE
				security.stitle := 'List of acct types';
			
				IF substr(pkey, 2, 1) IN (right_view, right_open)
				   OR substr(pkey, 2, length(right_viewfinattrs)) = right_viewfinattrs
				   OR substr(pkey, 2, length(right_generatestatement)) = right_generatestatement
				THEN
				
					getcursorrights(TRUE);
				
				END IF;
			END IF;
		
		ELSIF plevel = 3
		THEN
		
			IF pkey = '|' || right_modify || '|' || right_modify_oper || '|'
			THEN
			
				getcursorrights(FALSE);
			
			ELSIF substr(pkey, 2, length(right_arrest)) = right_arrest
				  OR substr(pkey, 2, length(right_notification)) = right_notification
				  OR substr(pkey, 2, length(right_perstatement)) = right_perstatement
			THEN
			
				getcursorrights(TRUE);
			
			END IF;
		
		ELSIF plevel = 4
		THEN
		
			IF substr(pkey, 1, 6) = '|' || right_modify || '|' || right_modify_oper || '|'
			THEN
				i := instr(pkey, '|', 7);
			
				IF i > 7
				THEN
					BEGIN
						vid := to_number(substr(pkey, 7, i - 7));
						IF vid IS NOT NULL
						THEN
							addrecord(caoimark, 'Set / Remove mark', TRUE);
							addrecord(caoiarrest, 'Arrest / Cancel arrest', TRUE);
							addrecord(caoinosub, 'Prohibit / Permit debit operations', TRUE);
							addrecord(caoibook, 'Change passbook issue flag', TRUE);
							addrecord(caoiundoclose, 'Undo account closure', TRUE);
						
							vatemplates := sot_core.gettemplates(sot_core.ctcaccounttype
																,vid
																,FALSE);
							i           := vatemplates.first();
							WHILE (i IS NOT NULL)
							LOOP
								addrecord(vatemplates(i).id, vatemplates(i).name, TRUE);
								i := vatemplates.next(i);
							END LOOP;
						END IF;
					EXCEPTION
						WHEN OTHERS THEN
							NULL;
					END;
				END IF;
			END IF;
		END IF;
		s.say(cwhere || ' End');
		RETURN varights;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cwhere);
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE closesecuritycursors IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.CloseSecurityCursors';
		vemptyarr typelevel;
	BEGIN
		s.say(cwhere || ' Begin');
		sarrsize := vemptyarr;
		s.say(cwhere || '. Cursor has been closed');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION testhandle
	(
		this  IN NUMBER
	   ,pfrom IN VARCHAR
	) RETURN CHAR IS
		vmode CHAR(1);
	BEGIN
		vmode := sopenacc(this).openmode;
	
		IF (vmode IN ('R', 'E', 'W'))
		THEN
		
			err.seterror(0, pfrom);
		ELSE
			err.seterror(err.account_invalid_handle, pfrom);
		
			vmode := 'N';
		
		END IF;
		RETURN vmode;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cpackagename || '.TestHandle: this=' || this || ', Err ' || SQLERRM);
			err.seterror(err.account_invalid_handle, pfrom);
			RETURN 'N';
	END;

	PROCEDURE testhandle
	(
		paccounthandle IN NUMBER
	   ,pmethodname    IN VARCHAR2
	) IS
	BEGIN
		IF (testhandle(paccounthandle, pmethodname) = 'N')
		THEN
			error.raisewhenerr();
		END IF;
	EXCEPTION
		WHEN error.error THEN
			RAISE;
		WHEN no_data_found THEN
			err.seterror(err.account_invalid_handle, pmethodname);
			error.raisewhenerr();
		WHEN OTHERS THEN
			error.save(cpackagename || '.TestHandle');
			RAISE;
	END;

	PROCEDURE markobjectcontextasfree(pobjectcontexthandle IN typeobjectcontexthandle) IS
	BEGIN
	
		IF (sopenacc(pobjectcontexthandle).openmode = 'C')
		THEN
			sopenacc(pobjectcontexthandle).openmode := 'N';
		
		END IF;
	
	EXCEPTION
		WHEN value_error THEN
			NULL;
		WHEN no_data_found THEN
			NULL;
		WHEN OTHERS THEN
			error.save(cpackagename || '.MarkObjectContextAsFree');
			RAISE;
	END;

	PROCEDURE freeobjectcontext(pobjectcontexthandle IN typeobjectcontexthandle) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.FreeObjectContext';
	
		PROCEDURE removecontexthandle(pobjectcontexthandle IN typeobjectcontexthandle) IS
			vaccounthandle NUMBER;
			i              PLS_INTEGER;
		BEGIN
			vaccounthandle := accobjectcontexthandles(pobjectcontexthandle) (0);
			i              := accobjectcontexthandles(vaccounthandle).first();
			WHILE (i IS NOT NULL AND accobjectcontexthandles(vaccounthandle)
				   (i) != pobjectcontexthandle)
			LOOP
				i := accobjectcontexthandles(vaccounthandle).next(i);
			END LOOP;
			accobjectcontexthandles(vaccounthandle).delete(i);
		EXCEPTION
			WHEN value_error THEN
				NULL;
			WHEN no_data_found THEN
				NULL;
		END;
	
		PROCEDURE removeobjecthandle(pobjectcontexthandle IN typeobjectcontexthandle) IS
		BEGIN
			accobjectcontexthandles(pobjectcontexthandle).delete(0);
		EXCEPTION
			WHEN no_data_found THEN
				NULL;
		END;
	
	BEGIN
	
		IF (nvl(sopenacc(pobjectcontexthandle).openmode, 'C') = 'C')
		THEN
			markobjectcontextasfree(pobjectcontexthandle);
			removecontexthandle(pobjectcontexthandle);
			removeobjecthandle(pobjectcontexthandle);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.say('WARNING! ' || cmethodname || ' failed with message: ' || SQLERRM(), 2);
	END;

	FUNCTION saveobjectcontext(paccounthandle IN NUMBER) RETURN typeobjectcontexthandle IS
		vobjectcontexthandle NUMBER := NULL;
		i                    PLS_INTEGER := NULL;
	BEGIN
		testhandle(paccounthandle, cpackagename || '.SaveObjectContext');
	
		vobjectcontexthandle := getfreehandle();
	
		accobjectcontexthandles(vobjectcontexthandle)(0) := paccounthandle;
		BEGIN
			i := nvl(accobjectcontexthandles(paccounthandle).last(), 0) + 1;
		EXCEPTION
			WHEN no_data_found THEN
				i := 1;
		END;
		accobjectcontexthandles(paccounthandle)(i) := vobjectcontexthandle;
	
		sopenacc(vobjectcontexthandle) := sopenacc(paccounthandle);
	
		sopenacc(vobjectcontexthandle).openmode := 'C';
	
		RETURN vobjectcontexthandle;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SaveObjectContext', getaccountno(paccounthandle));
			IF (vobjectcontexthandle IS NOT NULL)
			THEN
				freeobjectcontext(vobjectcontexthandle);
			END IF;
			RAISE;
	END;

	PROCEDURE restoreobjectcontext(pobjectcontexthandle IN typeobjectcontexthandle) IS
		vaccounthandle NUMBER := NULL;
		vmode          VARCHAR(1);
	BEGIN
		IF (pobjectcontexthandle IS NULL OR
		   nvl(sopenacc(pobjectcontexthandle).openmode, 'N') != 'C')
		THEN
		
			RAISE no_data_found;
		END IF;
		vaccounthandle := accobjectcontexthandles(pobjectcontexthandle) (0);
		testhandle(vaccounthandle, cpackagename || '.RestoreObjectContext');
	
		vmode := sopenacc(vaccounthandle).openmode;
		sopenacc(vaccounthandle) := sopenacc(pobjectcontexthandle);
		sopenacc(vaccounthandle).openmode := vmode;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.RestoreObjectContext');
			RAISE;
	END;

	PROCEDURE freeobject(this IN NUMBER) IS
	
		PROCEDURE freeobjectcontexts(paccounthandle IN NUMBER) IS
			i PLS_INTEGER;
		BEGIN
			BEGIN
				i := accobjectcontexthandles(paccounthandle).last();
				WHILE (i > 0)
				LOOP
					markobjectcontextasfree(accobjectcontexthandles(paccounthandle) (i));
					i := accobjectcontexthandles(paccounthandle).prior(i);
				END LOOP;
			EXCEPTION
				WHEN no_data_found THEN
					NULL;
			END;
			accobjectcontexthandles.delete(paccounthandle);
		EXCEPTION
			WHEN value_error THEN
				NULL;
			WHEN no_data_found THEN
				NULL;
			WHEN OTHERS THEN
				error.save(cpackagename || '.FreeObjectContexts', getaccountno(paccounthandle));
				RAISE;
		END;
	
	BEGIN
		s.say(cpackagename || '.FreeObject ' || getkeyvalue(this), 3);
	
		IF (testhandle(this, cpackagename || '.FreeObject') = 'W' OR
		   (testhandle(this, cpackagename || '.FreeObject') = 'E' AND
		   NOT sopenacc(this).notactualbalance))
		THEN
			object.release(object_name, getkeyvalue(this));
		END IF;
	
		freeobjectcontexts(this);
	
		sopenacc(this).openmode := 'N';
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
	END;

	FUNCTION getaccountno(this IN NUMBER) RETURN VARCHAR IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetAccountNo') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).accountno;
	END;

	FUNCTION getaccountrecord
	(
		paccountno IN typeaccountno
	   ,pguid      types.guid := NULL
	) RETURN apitypes.typeaccountrecord IS
		vbranch          NUMBER := seance.getbranch();
		vaccountrecord   apitypes.typeaccountrecord;
		vplanaccounttype NUMBER;
	BEGIN
	
		SELECT accountno
			  ,accounttype
			  ,noplan
			  ,stat
			  ,currencyno
			  ,idclient
			  ,remain
			  ,available
			  ,lowremain
			  ,overdraft
			  ,debitreserve
			  ,creditreserve
			  ,branchpart
			  ,createclerkcode
			  ,createdate
			  ,updateclerkcode
			  ,updatedate
			  ,updatesysdate
			  ,acct_typ
			  ,acct_stat
			  ,oldaccountno
			  ,closedate
			  ,remark
			  ,limitgrpid
			  ,remainupdatedate
			  ,
			   
			   finprofile
			  ,
			   
			   NULL
			  ,
			   
			   internallimitsgroupsysid
			  ,
			   
			   countergrpid
			  ,permissibleexcesstype
			  ,permissibleexcess
			  ,protectedamount
		INTO   vaccountrecord
		FROM   taccount a
			  ,tacc2acc b
		WHERE  a.branch = vbranch
		AND    a.accountno = paccountno
		AND    b.branch(+) = a.branch
		AND    b.newaccountno(+) = a.accountno;
	
		vplanaccounttype := planaccount.gettype(vaccountrecord.noplan);
		error.raisewhenerr();
		IF (vplanaccounttype = planaccount.type_nonconsolidated)
		THEN
			vaccountrecord.extaccountno := planaccount.getexternal(vaccountrecord.noplan);
			error.raisewhenerr();
		END IF;
	
		IF pguid IS NULL
		THEN
		
			vaccountrecord.guid := getguid(vaccountrecord.accountno);
			error.raisewhenerr();
		
		ELSE
			vaccountrecord.guid := pguid;
		END IF;
	
		RETURN vaccountrecord;
	EXCEPTION
		WHEN no_data_found THEN
			setaccountnotfounderror(paccountno, 'GetAccountRecord');
			RETURN NULL;
		WHEN OTHERS THEN
		
			setexceptionerror('GetAccountRecord', paccountno);
		
			RETURN NULL;
	END;

	FUNCTION getaccounttype(paccountno IN typeaccountno) RETURN taccount.accounttype%TYPE IS
		vacctype taccount.accounttype%TYPE;
	BEGIN
		SELECT t.accounttype
		INTO   vacctype
		FROM   taccount t
		WHERE  t.branch = seance.getbranch()
		AND    t.accountno = paccountno;
		RETURN vacctype;
	EXCEPTION
		WHEN no_data_found THEN
			setaccountnotfounderror(paccountno, 'GetAccountType');
			RETURN NULL;
		WHEN OTHERS THEN
			setexceptionerror('GetAccountType', paccountno);
			RETURN NULL;
	END;

	FUNCTION getaccountnobyobjuid(pobjectuid IN taccount.objectuid%TYPE) RETURN typeaccountno IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.GetAccountNoByObjUId';
		vaccountno typeaccountno;
		vbranch    NUMBER := seance.getbranch();
	BEGIN
		SELECT t.accountno
		INTO   vaccountno
		FROM   taccount t
		WHERE  t.branch = vbranch
		AND    t.objectuid = pobjectuid;
		RETURN vaccountno;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RETURN NULL;
	END;

	FUNCTION getaccountnobyguid(pguid types.guid) RETURN typeaccountno IS
		cwhere CONSTANT VARCHAR2(80) := cpackagename || '.GetAccountNoByGUId';
		vobjectuid objectuid.typeobjectuid;
		vaccountno typeaccountno := NULL;
	BEGIN
		s.say(cwhere || ': pGUID = ' || pguid);
		vobjectuid := objectuid.getuidbyguid(pguid);
		vaccountno := getaccountnobyobjuid(vobjectuid);
		RETURN vaccountno;
	EXCEPTION
		WHEN no_data_found THEN
			error.save(cwhere);
			RETURN vaccountno;
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION getaccountrecordbyguid(pguid types.guid) RETURN apitypes.typeaccountrecord IS
		cwhere CONSTANT VARCHAR(80) := cpackagename || '.GetAccountRecordByGUID';
		vaccountno typeaccountno := NULL;
	BEGIN
		vaccountno := getaccountnobyguid(pguid);
		RETURN getaccountrecord(vaccountno);
	EXCEPTION
		WHEN no_data_found THEN
			error.save(cwhere);
			RETURN NULL;
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION getaccount(this IN NUMBER) RETURN typeaccount IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetAccount') = 'N'
		THEN
			RETURN NULL;
		END IF;
		RETURN sopenacc(this);
	END;

	FUNCTION getovervalue(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetOverValue') = 'N'
		THEN
			RETURN NULL;
		END IF;
		RETURN sopenacc(this).permissibleexcess;
	END;

	FUNCTION getovertype(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetOverType') = 'N'
		THEN
			RETURN NULL;
		END IF;
		RETURN sopenacc(this).permissibleexcesstype;
	END;

	FUNCTION getprotectedamountfo(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetProtectedAmountFO') = 'N'
		THEN
			RETURN NULL;
		END IF;
		RETURN sopenacc(this).protectedamount;
	END;

	FUNCTION getprotectedamountbyaccno(paccountno IN typeaccountno) RETURN NUMBER IS
		vpramount NUMBER := NULL;
		vbranch   NUMBER := seance.getbranch();
	BEGIN
		SELECT protectedamount
		INTO   vpramount
		FROM   taccount
		WHERE  branch = vbranch
		AND    accountno = paccountno;
		RETURN vpramount;
	EXCEPTION
		WHEN no_data_found THEN
			setaccountnotfounderror(paccountno, 'GetProtectedAmountByAccNo');
			RETURN NULL;
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cpackagename || '.GetProtectedAmountByAccNo');
			RAISE;
	END;

	FUNCTION getaccounttype(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetAccountType') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).accounttype;
	END;

	FUNCTION getacct_stat(this IN NUMBER) RETURN CHAR IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetACCT_STAT') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).acct_stat;
	END;

	FUNCTION getacct_typ(this IN NUMBER) RETURN CHAR IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetACCT_TYP') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).acct_typ;
	END;

	FUNCTION getavailable(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetAvailable') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).available;
	END;

	FUNCTION getbranchpart(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetBranchPart') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).branchpart;
	END;

	FUNCTION getcardlist(paccountno IN typeaccountno) RETURN apitypes.typeaccount2cardlist IS
		vindex    NUMBER := 0;
		vcardlist apitypes.typeaccount2cardlist;
		vbranch   NUMBER := seance.getbranch();
		CURSOR c1 IS
			SELECT *
			FROM   tacc2card
			WHERE  branch = vbranch
			AND    accountno = paccountno;
	BEGIN
		FOR i IN c1
		LOOP
			vindex := vindex + 1;
			vcardlist(vindex).accountno := i.accountno;
			vcardlist(vindex).pan := i.pan;
			vcardlist(vindex).mbr := i.mbr;
			vcardlist(vindex).acct_stat := i.acct_stat;
			vcardlist(vindex).description := i.description;
		END LOOP;
		RETURN vcardlist;
	END;

	FUNCTION getclosedate(this IN NUMBER) RETURN DATE IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetCloseDate') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).closedate;
	END;

	FUNCTION getcreateclerkcode(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetCreateDate') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).createclerkcode;
	END;

	FUNCTION getcreatedate(this IN NUMBER) RETURN DATE IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetCreateDate') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).createdate;
	END;

	FUNCTION getcreditreserve(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetCreditReserve') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).creditreserve;
	END;

	FUNCTION getcurrency(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetCurrency') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).currencyno;
	END;

	FUNCTION getcurrencybyaccountno(paccountno IN typeaccountno) RETURN NUMBER IS
		vcurrency NUMBER;
		vbranch   NUMBER := seance.getbranch();
	BEGIN
		SELECT currencyno
		INTO   vcurrency
		FROM   taccount
		WHERE  branch = vbranch
		AND    accountno = paccountno;
		RETURN vcurrency;
	EXCEPTION
		WHEN OTHERS THEN
			setaccountnotfounderror(paccountno, 'pAccountNo');
			RETURN NULL;
	END;

	FUNCTION getcurrentaccount RETURN typeaccountno IS
	BEGIN
		RETURN scurrentaccount;
	END;

	FUNCTION getcurrentaccountrecord(pthis IN NUMBER) RETURN apitypes.typeaccountrecord IS
		vaccountrecord   apitypes.typeaccountrecord;
		vplanaccounttype NUMBER;
		vacc             typeaccount;
	BEGIN
		vacc                         := sopenacc(pthis);
		vaccountrecord.accountno     := vacc.accountno;
		vaccountrecord.accounttype   := vacc.accounttype;
		vaccountrecord.noplan        := vacc.noplan;
		vaccountrecord.stat          := vacc.stat;
		vaccountrecord.currency      := vacc.currencyno;
		vaccountrecord.idclient      := vacc.idclient;
		vaccountrecord.remain        := vacc.remain;
		vaccountrecord.available     := vacc.available;
		vaccountrecord.lowremain     := vacc.lowremain;
		vaccountrecord.crdlimit      := vacc.overdraft;
		vaccountrecord.debitreserve  := vacc.debitreserve;
		vaccountrecord.creditreserve := vacc.creditreserve;
		vaccountrecord.branchpart    := vacc.branchpart;
		vaccountrecord.createclerk   := vacc.createclerkcode;
		vaccountrecord.createdate    := vacc.createdate;
		vaccountrecord.updateclerk   := vacc.updateclerkcode;
		vaccountrecord.updatedate    := vacc.updatedate;
		vaccountrecord.updatesysdate := vacc.updatesysdate;
		vaccountrecord.acct_typ      := vacc.acct_typ;
		vaccountrecord.acct_stat     := vacc.acct_stat;
	
		vplanaccounttype := planaccount.gettype(vaccountrecord.noplan);
		error.raisewhenerr();
		IF (vplanaccounttype = planaccount.type_nonconsolidated)
		THEN
			vaccountrecord.extaccountno := planaccount.getexternal(vaccountrecord.noplan);
		ELSE
			vaccountrecord.extaccountno := acc2acc.getoldaccountno(vaccountrecord.accountno);
		END IF;
		s.say(cpackagename || '.GetCurrentAccountRecord: vAccountRecord.ExtAccountNo=' ||
			  vaccountrecord.extaccountno || ' vPlanAccountType=' || vplanaccounttype);
		error.raisewhenerr();
	
		vaccountrecord.closedate                := vacc.closedate;
		vaccountrecord.remark                   := vacc.remark;
		vaccountrecord.limitgrpid               := vacc.limitgrp;
		vaccountrecord.countergrpid             := vacc.countergrp;
		vaccountrecord.remainupdatedate         := vacc.remainupdatedate;
		vaccountrecord.finprofile               := vacc.finprofile;
		vaccountrecord.guid                     := getguid(pthis);
		vaccountrecord.internallimitsgroupsysid := vacc.internallimitsgroupsysid;
	
		vaccountrecord.permissibleexcesstype := vacc.permissibleexcesstype;
		vaccountrecord.permissibleexcess     := vacc.permissibleexcess;
	
		vaccountrecord.protectedamount := vacc.protectedamount;
		vaccountrecord.extaccountno    := vacc.extaccountno;
	
		RETURN vaccountrecord;
	EXCEPTION
		WHEN OTHERS THEN
			setexceptionerror('GetCurrentAccountRecord', vaccountrecord.accountno);
			RETURN NULL;
	END;

	FUNCTION getdebitreserve(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetDebitReserve') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).debitreserve;
	END;

	FUNCTION getidclient(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetIdClient') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).idclient;
	END;

	FUNCTION getclienttype(this IN NUMBER) RETURN PLS_INTEGER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetClientType') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN client.getclienttype(sopenacc(this).idclient);
	END;

	FUNCTION getclienttypebyaccno(paccountno IN typeaccountno) RETURN PLS_INTEGER IS
		vidclient NUMBER;
		vbranch   NUMBER := seance.getbranch();
	BEGIN
		SELECT idclient
		INTO   vidclient
		FROM   taccount
		WHERE  branch = vbranch
		AND    accountno = paccountno;
	
		RETURN client.getclienttype(vidclient);
	EXCEPTION
		WHEN no_data_found THEN
			setaccountnotfounderror(paccountno, 'GetClientTypeByAccNo');
			RETURN NULL;
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cpackagename || '.GetClientTypeByAccNo');
			RETURN NULL;
	END;

	FUNCTION getidclientbyaccno(paccountno IN typeaccountno) RETURN NUMBER IS
		vbranch   NUMBER := seance.getbranch();
		vidclient NUMBER := NULL;
	BEGIN
		SELECT idclient
		INTO   vidclient
		FROM   taccount
		WHERE  branch = vbranch
		AND    accountno = paccountno;
		RETURN vidclient;
	EXCEPTION
		WHEN no_data_found THEN
			setaccountnotfounderror(paccountno, 'GetIdClientByAccNo');
			RETURN NULL;
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetIdClientByAccNo [' || paccountno || ']');
			RAISE;
	END;

	FUNCTION isclientpersone(pidclient IN tclient.idclient%TYPE) RETURN BOOLEAN IS
	BEGIN
		RETURN client.getclienttype(pidclient) = client.ct_persone;
	END;

	FUNCTION getidclientacc(paccountno typeaccountno) RETURN NUMBER IS
		vidclient   NUMBER := NULL;
		vislogowner BOOLEAN := FALSE;
	BEGIN
		s.say(cpackagename || '.GetIdClientAcc[' || paccountno || ']');
		vidclient := getidclientbyaccno(paccountno);
		IF (vidclient IS NOT NULL)
		   AND isclientpersone(vidclient)
		THEN
			vislogowner := TRUE;
		END IF;
		RETURN htools.iif(vislogowner, vidclient, NULL);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetIdClientAcc [' || paccountno || ']');
			RAISE;
	END;

	FUNCTION getkeyvalue(this IN NUMBER) RETURN VARCHAR IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetKeyValue') != 'N'
		THEN
			RETURN ltrim(rtrim(sopenacc(this).accountno));
		ELSE
			RETURN NULL;
		END IF;
	END;

	FUNCTION getlowremain(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetLowRemain') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).lowremain;
	END;

	FUNCTION getnoplan(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetNoPlan') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).noplan;
	END;

	FUNCTION getnoplanbyaccno(paccountno IN typeaccountno) RETURN NUMBER IS
		vnoplan NUMBER;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		SELECT noplan
		INTO   vnoplan
		FROM   taccount
		WHERE  branch = vbranch
		AND    accountno = paccountno;
	
		RETURN vnoplan;
	EXCEPTION
		WHEN no_data_found THEN
			setaccountnotfounderror(paccountno, 'GetNoPlanByAccNo');
			RETURN NULL;
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cpackagename || '.GetNoPlanByAccNo');
			RETURN NULL;
	END;

	FUNCTION getoverdraft(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetOverdraft') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).overdraft;
	END;

	FUNCTION getremain(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetRemain') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).remain;
	END;

	FUNCTION getremainhistory
	(
		paccountno  IN typeaccountno
	   ,pstartdate  IN DATE := NULL
	   ,pfinishdate IN DATE := NULL
	) RETURN typeremainhistory IS
		vaccounthandle  NUMBER := NULL;
		vremain         NUMBER;
		vbranch         NUMBER;
		vstartdate      DATE;
		vfinishdate     DATE;
		vcurrentdate    DATE;
		varemainhistory typeremainhistory;
	
		CURSOR curentries IS
			SELECT *
			FROM   (SELECT
					/*+ ORDERED
                    INDEX(A IENTRY_DEBITACCOUNT)
                    INDEX(B IDOCUMENTS_DOCNO)
                    USE_NL(B) */
					 d.opdate opdate
					,-e.value VALUE
					FROM   tentry    e
						  ,tdocument d
					WHERE  e.branch = vbranch
					AND    e.debitaccount = paccountno
					AND    d.branch = e.branch
					AND    d.docno = e.docno
					AND    d.opdate >= vstartdate
					AND    d.newdocno IS NULL
					UNION ALL
					SELECT
					/*+ ORDERED
                    INDEX(A IENTRY_CREDITACCOUNT)
                    INDEX(B IDOCUMENTS_DOCNO)
                    USE_NL(B) */
					 d.opdate opdate
					,e.value  VALUE
					FROM   tentry    e
						  ,tdocument d
					WHERE  e.branch = vbranch
					AND    e.creditaccount = paccountno
					AND    d.branch = e.branch
					AND    d.docno = e.docno
					AND    d.opdate >= vstartdate
					AND    d.newdocno IS NULL
					UNION ALL
					SELECT
					/*+ ORDERED
                    INDEX(A IENTRYARC_DEBITACCOUNT)
                    INDEX(B IDOCUMENTARC_DOCNO)
                    USE_NL(B) */
					 da.opdate opdate
					,-ea.value VALUE
					FROM   tentryarc    ea
						  ,tdocumentarc da
					WHERE  ea.branch = vbranch
					AND    ea.debitaccount = paccountno
					AND    da.branch = ea.branch
					AND    da.docno = ea.docno
					AND    da.opdate >= vstartdate
					AND    da.newdocno IS NULL
					UNION ALL
					SELECT
					/*+ ORDERED
                    INDEX(A IENTRYARC_CREDITACCOUNT)
                    INDEX(B IDOCUMENTARC_DOCNO)
                    USE_NL(B) */
					 da.opdate opdate
					,ea.value  VALUE
					FROM   tentryarc    ea
						  ,tdocumentarc da
					WHERE  ea.branch = vbranch
					AND    ea.creditaccount = paccountno
					AND    da.branch = ea.branch
					AND    da.docno = ea.docno
					AND    da.opdate >= vstartdate
					AND    da.newdocno IS NULL)
			ORDER  BY opdate DESC;
	
		ventryinfo curentries%ROWTYPE;
		i          PLS_INTEGER;
	BEGIN
		vaccounthandle := newobject(paccountno, 'W');
		IF (err.geterrorcode() != 0)
		THEN
			error.raiseuser(err.gettext());
		END IF;
	
		vremain := account.getremain(vaccounthandle);
		vbranch := seance.getbranch();
	
		vstartdate := account.getcreatedate(vaccounthandle);
		IF (pstartdate IS NOT NULL)
		THEN
			vstartdate := greatest(trunc(pstartdate, 'DD'), vstartdate);
		END IF;
	
		vfinishdate := greatest(account.getupdatedate(vaccounthandle), seance.getoperdate());
		IF (pfinishdate IS NOT NULL)
		THEN
			vfinishdate := least(trunc(pfinishdate, 'DD'), vfinishdate);
		END IF;
	
		OPEN curentries;
		FETCH curentries
			INTO ventryinfo;
		vcurrentdate := vfinishdate;
		WHILE (vcurrentdate >= vstartdate)
		LOOP
			WHILE (curentries%FOUND AND ventryinfo.opdate > vcurrentdate)
			LOOP
				vremain := vremain - ventryinfo.value;
				FETCH curentries
					INTO ventryinfo;
			END LOOP;
		
			i := vcurrentdate - vstartdate + 1;
			varemainhistory(i).opdate := vcurrentdate;
			varemainhistory(i).remain := vremain;
		
			vcurrentdate := vcurrentdate - 1;
		END LOOP;
		CLOSE curentries;
	
		account.freeobject(vaccounthandle);
		vaccounthandle := NULL;
	
		RETURN varemainhistory;
	EXCEPTION
		WHEN OTHERS THEN
			IF (curentries%ISOPEN)
			THEN
				CLOSE curentries;
			END IF;
			IF (vaccounthandle > 0)
			THEN
				account.freeobject(vaccounthandle);
			END IF;
			error.save(cpackagename || '.GetRemainHistory');
			RAISE;
	END;

	FUNCTION getopremains
	(
		paccountno IN typeaccountno
	   ,pdocno     IN NUMBER
	) RETURN typeopremains IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.GetOpRemains';
	
		vaccounthandle NUMBER := NULL;
		vremain        NUMBER;
		vbranch        NUMBER;
		vstartdate     DATE;
		vfinishdate    DATE;
		vcurrentdate   DATE;
		vdoc           tdocument%ROWTYPE := NULL;
		vfinddoc       BOOLEAN;
	
		vaopremainhistrev typeopremains;
		vaopremainhistory typeopremains;
	
		CURSOR curentries
		(
			pbranch    IN NUMBER
		   ,paccountno IN CHAR
		   ,pstartdate IN DATE
		) IS
			SELECT *
			FROM   (SELECT
					/*+ ORDERED
                    INDEX(A IENTRY_DEBITACCOUNT)
                    INDEX(B IDOCUMENTS_DOCNO)
                    USE_NL(B) */
					 e.docno
					,e.no
					,d.opdate opdate
					,-e.value VALUE
					FROM   tentry    e
						  ,tdocument d
					WHERE  e.branch = pbranch
					AND    e.debitaccount = paccountno
					AND    d.branch = e.branch
					AND    d.docno = e.docno
					AND    d.opdate >= pstartdate
					AND    d.newdocno IS NULL
					UNION ALL
					SELECT
					/*+ ORDERED
                    INDEX(A IENTRY_CREDITACCOUNT)
                    INDEX(B IDOCUMENTS_DOCNO)
                    USE_NL(B) */
					 e.docno
					,e.no
					,d.opdate opdate
					,e.value  VALUE
					FROM   tentry    e
						  ,tdocument d
					WHERE  e.branch = pbranch
					AND    e.creditaccount = paccountno
					AND    d.branch = e.branch
					AND    d.docno = e.docno
					AND    d.opdate >= pstartdate
					AND    d.newdocno IS NULL
					UNION ALL
					SELECT
					/*+ ORDERED
                    INDEX(A IENTRYARC_DEBITACCOUNT)
                    INDEX(B IDOCUMENTARC_DOCNO)
                    USE_NL(B) */
					 ea.docno
					,ea.no
					,da.opdate opdate
					,-ea.value VALUE
					FROM   tentryarc    ea
						  ,tdocumentarc da
					WHERE  ea.branch = pbranch
					AND    ea.debitaccount = paccountno
					AND    da.branch = ea.branch
					AND    da.docno = ea.docno
					AND    da.opdate >= pstartdate
					AND    da.newdocno IS NULL
					UNION ALL
					SELECT
					/*+ ORDERED
                    INDEX(A IENTRYARC_CREDITACCOUNT)
                    INDEX(B IDOCUMENTARC_DOCNO)
                    USE_NL(B) */
					 ea.docno
					,ea.no
					,da.opdate opdate
					,ea.value  VALUE
					FROM   tentryarc    ea
						  ,tdocumentarc da
					WHERE  ea.branch = pbranch
					AND    ea.creditaccount = paccountno
					AND    da.branch = ea.branch
					AND    da.docno = ea.docno
					AND    da.opdate >= pstartdate
					AND    da.newdocno IS NULL)
			ORDER  BY opdate DESC
					 ,docno  DESC
					 ,no     DESC;
	
		ventryinfo curentries%ROWTYPE;
		i          PLS_INTEGER;
	BEGIN
		s.say(cwhere || '|pAccountNo = ' || paccountno || ', pDocNo = ' || pdocno);
	
		vaccounthandle := account.newobject(paccountno, 'W');
	
		error.raisewhenerr();
	
		vremain := account.getremain(vaccounthandle);
		vbranch := seance.getbranch();
	
		FOR c_findoc IN (SELECT *
						 FROM   tdocument t
						 WHERE  t.branch = vbranch
						 AND    t.docno = pdocno
						 AND    t.newdocno IS NULL
						 UNION ALL
						 SELECT *
						 FROM   tdocumentarc t
						 WHERE  t.branch = vbranch
						 AND    t.docno = pdocno
						 AND    t.newdocno IS NULL)
		LOOP
			vdoc := c_findoc;
			EXIT;
		END LOOP;
	
		IF (vdoc.docno IS NOT NULL)
		THEN
			vstartdate := vdoc.opdate;
		
			vfinishdate := greatest(account.getupdatedate(vaccounthandle), seance.getoperdate());
		
			s.say(cwhere || '|vStartDate  = ' || vstartdate);
			s.say(cwhere || '|vFinishDate = ' || vfinishdate);
		
			OPEN curentries(vbranch, paccountno, vstartdate);
			FETCH curentries
				INTO ventryinfo;
		
			vcurrentdate := vfinishdate;
			vfinddoc     := FALSE;
		
			WHILE (vcurrentdate >= vstartdate)
			LOOP
			
				WHILE (curentries%FOUND AND ventryinfo.opdate >= vcurrentdate AND
					  ventryinfo.docno != pdocno)
				LOOP
					vremain := vremain - ventryinfo.value;
					FETCH curentries
						INTO ventryinfo;
				END LOOP;
			
				i := 1;
				WHILE (ventryinfo.docno = pdocno)
				LOOP
				
					vaopremainhistrev(i).docno := ventryinfo.docno;
					vaopremainhistrev(i).no := ventryinfo.no;
					vaopremainhistrev(i).opdate := ventryinfo.opdate;
					vaopremainhistrev(i).value := ventryinfo.value;
					vaopremainhistrev(i).remain := vremain;
				
					vremain := vremain - ventryinfo.value;
					FETCH curentries
						INTO ventryinfo;
				
					vfinddoc := TRUE;
				
					IF curentries%NOTFOUND
					THEN
						EXIT;
					END IF;
				
					i := i + 1;
				
				END LOOP;
			
				IF (vfinddoc)
				THEN
					EXIT;
				END IF;
			
				vcurrentdate := vcurrentdate - 1;
			END LOOP;
		
			vaopremainhistory.delete();
			i := 1;
			FOR j IN REVERSE 1 .. vaopremainhistrev.count()
			LOOP
				vaopremainhistory(i) := vaopremainhistrev(j);
				i := i + 1;
			END LOOP;
		
			CLOSE curentries;
		ELSE
			s.say(cwhere || '|Findoc not found!');
		END IF;
	
		account.freeobject(vaccounthandle);
		vaccounthandle := NULL;
	
		RETURN vaopremainhistory;
	EXCEPTION
		WHEN OTHERS THEN
			IF (curentries%ISOPEN)
			THEN
				CLOSE curentries;
			END IF;
			IF (vaccounthandle > 0)
			THEN
				account.freeobject(vaccounthandle);
			END IF;
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION getremark(this IN NUMBER) RETURN VARCHAR IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetRemark') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).remark;
	END;

	FUNCTION getrightkey
	(
		pright              IN VARCHAR2
	   ,paccounttype        IN NUMBER := NULL
	   ,paccountoperationid IN typeaccountoperationid := NULL
	   ,psotemplateid       IN tsot.id%TYPE := NULL
	) RETURN VARCHAR2 IS
	BEGIN
		IF (pright IN (right_view
					  ,right_open
					  ,right_viewfinattrs
					  ,right_generatestatement
					  ,right_notification || '|' || right_add_notification
					  ,right_notification || '|' || right_modify_notification
					  ,right_notification || '|' || right_delete_notification
					  ,right_arrest || '|' || right_add_arrest
					  ,right_arrest || '|' || right_modify_arrest
					  ,right_arrest || '|' || right_delete_arrest
					  ,right_perstatement || '|' || right_add_perstatement
					  ,right_perstatement || '|' || right_modify_perstatement
					  ,right_perstatement || '|' || right_delete_perstatement) AND
		   paccounttype IS NOT NULL)
		THEN
			RETURN '|' || pright || '|' || to_char(paccounttype) || '|';
		ELSIF (pright = right_modify_oper)
		THEN
			IF (psotemplateid IS NOT NULL)
			THEN
				RETURN '|' || right_modify || '|' || right_modify_oper || '|' || to_char(paccounttype) || '|' || to_char(psotemplateid) || '|';
			ELSE
				RETURN '|' || right_modify || '|' || right_modify_oper || '|' || to_char(paccounttype) || '|' || paccountoperationid || '|';
			END IF;
		ELSIF pright IN (right_modify_attr
						,right_change_client
						,right_del_hold
						,right_modify_branchpart
						,right_modify_limits
						,right_modify_tran_reverse
						,right_cancel_hold
						,right_del_cash_reqs
						,right_undo_cash_reqs
						,
						 
						 right_move_hold)
		THEN
			RETURN '|' || right_modify || '|' || pright || '|';
		
		ELSIF (pright IN (right_reference_view, right_reference_modify))
		THEN
			RETURN '|' || right_reference || '|' || pright || '|';
		
		ELSE
			RETURN '|' || pright || '|';
		END IF;
	END;

	FUNCTION getsign(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetSign') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN planaccount.getsign(sopenacc(this).noplan);
	END;

	FUNCTION getsoftstat(this IN NUMBER) RETURN VARCHAR IS
		vstat VARCHAR(10);
	BEGIN
		IF testhandle(this, cpackagename || '.GetStat') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		IF service.getbit(sopenacc(this).stat, account.stat_mark) = 1
		THEN
			vstat := service.setbit(vstat, stat_mark);
		END IF;
		IF service.getbit(sopenacc(this).stat, account.stat_arrest) = 1
		THEN
			vstat := service.setbit(vstat, stat_arrest);
		END IF;
		IF service.getbit(sopenacc(this).stat, account.stat_close) = 1
		THEN
			vstat := service.setbit(vstat, stat_close);
		END IF;
		IF service.getbit(sopenacc(this).stat, account.stat_nosub) = 1
		THEN
			vstat := service.setbit(vstat, stat_nosub);
		END IF;
	
		RETURN vstat;
	END;

	FUNCTION getstat(this IN NUMBER) RETURN VARCHAR IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetStat') = 'N'
		THEN
			RETURN NULL;
		END IF;
		RETURN sopenacc(this).stat;
	END;

	FUNCTION getstatname(pstat IN VARCHAR) RETURN VARCHAR IS
	BEGIN
		RETURN sstatname(ascii(substr(pstat, 1, 1)) - 47);
	EXCEPTION
		WHEN OTHERS THEN
			RETURN 'UNKNOWN ACCT STATE';
	END;

	FUNCTION getregularpaymentlist(paccountno IN typeaccountno) RETURN apitypes.typeregularpaymentlist IS
	BEGIN
		RETURN payment.getregularpaymentlist(paccountno);
	END;

	FUNCTION getupdatedate(this IN NUMBER) RETURN DATE IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetUpdateDate') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).updatedate;
	END;

	FUNCTION getupdateclerkcode(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetUpdateClerkCode') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).updateclerkcode;
	END;

	FUNCTION getupdatesysdate(this IN NUMBER) RETURN DATE IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetUpdateSysDate') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).updatesysdate;
	END;

	FUNCTION getlimitgrp(this IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetLimitGrp') = 'N'
		THEN
			RETURN NULL;
		END IF;
	
		RETURN sopenacc(this).limitgrp;
	END;

	FUNCTION getcountergrp(this IN NUMBER) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.GetCounterGrp';
	BEGIN
		IF (testhandle(this, cwhere) = 'N')
		THEN
			RETURN NULL;
		END IF;
		RETURN sopenacc(this).countergrp;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	FUNCTION getinternallimitsgroupsysid(this IN NUMBER) RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.GetInternalLimitsGroupSysId';
	BEGIN
		IF (testhandle(this, cmethodname) = 'N')
		THEN
			RETURN NULL;
		END IF;
		RETURN sopenacc(this).internallimitsgroupsysid;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getmemolist(paccountno IN typeaccountno) RETURN apitypes.typememolist IS
	BEGIN
		RETURN memo.getmemolist(object_type, paccountno);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetMemoList');
			RAISE;
	END;

	FUNCTION getfinprofile(pthis IN NUMBER) RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.GetFinProfile';
		vfinprofile taccount.finprofile%TYPE;
	BEGIN
		IF (testhandle(pthis, cmethodname) != 'N')
		THEN
			vfinprofile := sopenacc(pthis).finprofile;
		ELSE
			vfinprofile := NULL;
		END IF;
	
		RETURN vfinprofile;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetFinProfile');
			RAISE;
	END;

	FUNCTION getremainupdatedate(paccounthandle IN NUMBER) RETURN DATE IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.GetRemainUpdateDate';
	BEGIN
		IF (testhandle(paccounthandle, cmethodname) = 'N')
		THEN
			RETURN NULL;
		END IF;
		RETURN sopenacc(paccounthandle).remainupdatedate;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE init IS
	BEGIN
	
		object_type := object.gettype(object_name);
	END;

	FUNCTION isarrest(this IN NUMBER) RETURN BOOLEAN IS
	BEGIN
		IF testhandle(this, cpackagename || '.IsArrest') != 'N'
		THEN
			RETURN(service.getbit(sopenacc(this).stat, account.stat_arrest) = 1);
		ELSE
			RETURN FALSE;
		END IF;
	END;

	FUNCTION isclose(this IN NUMBER) RETURN BOOLEAN IS
	BEGIN
		IF testhandle(this, cpackagename || '.IsClose') != 'N'
		THEN
			RETURN(service.getbit(sopenacc(this).stat, account.stat_close) = 1);
		ELSE
			RETURN FALSE;
		END IF;
	END;

	FUNCTION ismark(this IN NUMBER) RETURN BOOLEAN IS
	BEGIN
		IF testhandle(this, cpackagename || '.IsMark') != 'N'
		THEN
			RETURN(service.getbit(sopenacc(this).stat, account.stat_mark) = 1);
		ELSE
			RETURN FALSE;
		END IF;
	END;

	FUNCTION isnosub(this IN NUMBER) RETURN BOOLEAN IS
	BEGIN
		IF testhandle(this, cpackagename || '.IsNoSub') != 'N'
		THEN
			RETURN(service.getbit(sopenacc(this).stat, account.stat_nosub) = 1);
		ELSE
			RETURN FALSE;
		END IF;
	END;

	FUNCTION isbook(this IN NUMBER) RETURN BOOLEAN IS
	BEGIN
		IF testhandle(this, cpackagename || '.IsBook') != 'N'
		THEN
			RETURN(service.getbit(sopenacc(this).stat, account.stat_book) = 1);
		ELSE
			RETURN FALSE;
		END IF;
	END;

	FUNCTION isreport(this IN NUMBER) RETURN BOOLEAN IS
	BEGIN
		IF testhandle(this, cpackagename || '.IsReport') != 'N'
		THEN
			RETURN(service.getbit(sopenacc(this).stat, account.stat_report) = 1);
		ELSE
			RETURN FALSE;
		END IF;
	END;

	FUNCTION lockobject
	(
		paccountno    IN typeaccountno
	   ,pmod          IN CHAR
	   ,pattempt      PLS_INTEGER := NULL
	   ,pattemptpause NUMBER := NULL
	) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.LockObject';
	
		vbranch NUMBER := seance.getbranch();
		CURSOR c1_nowait
		(
			pbranch IN NUMBER
		   ,paccno  IN VARCHAR2
		) IS
			SELECT *
			FROM   taccount
			WHERE  branch = pbranch
			AND    accountno = ltrim(rtrim(paccno))
			FOR    UPDATE NOWAIT;
	
		CURSOR c1_wait
		(
			pbranch IN NUMBER
		   ,paccno  IN VARCHAR2
		) IS
			SELECT *
			FROM   taccount
			WHERE  branch = pbranch
			AND    accountno = ltrim(rtrim(paccno))
			FOR    UPDATE wait 1;
	
		vlockoptions options.typelockoptions;
		vseanceinfo  seance.typeseanceinfo;
	
		accobjlocked BOOLEAN := FALSE;
	
		vlockerr NUMBER := 0;
	
		FUNCTION capture
		(
			pobjectname   IN VARCHAR
		   ,paccountno    IN VARCHAR
		   ,pattempt      IN PLS_INTEGER := NULL
		   ,pattemptpause IN NUMBER := NULL
		) RETURN NUMBER IS
			verrcode NUMBER;
		BEGIN
			verrcode := object.capture(pobjectname
									  ,paccountno
									  ,pattempt      => pattempt
									  ,pattemptpause => pattemptpause);
			IF verrcode = err.object_busy
			THEN
				err.seterror(err.account_busy
							,cpackagename || '.LockObject'
							,capturedobjectinfo(paccountno));
			ELSIF verrcode != 0
			THEN
				error.raisewhenerr();
			END IF;
		
			RETURN verrcode;
		
		END;
	
		FUNCTION lockaccrow
		(
			pbranch  IN NUMBER
		   ,paccno   IN VARCHAR2
		   ,prowwait IN BOOLEAN
		) RETURN NUMBER IS
			cwherel CONSTANT VARCHAR2(100) := cwhere || '|LockAccRow';
			vfound   BOOLEAN := FALSE;
			vlockerr NUMBER := 0;
		BEGIN
		
			s.say(cwherel || '|pBranch = ' || pbranch || ', pAccNo = ' || paccno ||
				  ', pRowWait = ' || htools.b2s(prowwait));
		
			BEGIN
				IF (prowwait)
				THEN
					FOR i IN c1_wait(pbranch, paccno)
					LOOP
						vfound := TRUE;
					END LOOP;
				ELSE
					FOR i IN c1_nowait(pbranch, paccno)
					LOOP
						vfound := TRUE;
					END LOOP;
				END IF;
			
			EXCEPTION
				WHEN OTHERS THEN
					vfound := FALSE;
			END;
		
			IF NOT vfound
			THEN
				setaccountnotfounderror(paccno, 'LockObject');
				vlockerr := err.account_not_found;
			END IF;
		
			RETURN vlockerr;
		
		EXCEPTION
			WHEN OTHERS THEN
			
				IF NOT vfound
				THEN
					setaccountnotfounderror(paccno, 'LockObject');
					vlockerr := err.account_not_found;
				END IF;
			
				RETURN vlockerr;
		END;
	
	BEGIN
	
		IF upper(pmod) = 'E'
		   AND getflagnotactualbalance(paccountno)
		THEN
			vlockerr := 0;
		ELSIF upper(pmod) IN ('W', 'E')
		THEN
		
			SAVEPOINT accountlockobject;
		
			vseanceinfo := seance.getinfo();
		
			vlockoptions := options.getlockoptions();
		
			IF vseanceinfo.ismultitask
			THEN
				IF pattempt IS NULL
				   AND pattemptpause IS NULL
				THEN
				
					vlockerr := capture(object_name
									   ,paccountno
									   ,pattempt      => vlockoptions.multitask_attempt
									   ,pattemptpause => vlockoptions.multitask_attemptpause);
				ELSE
				
					vlockerr := capture(object_name
									   ,paccountno
									   ,pattempt      => pattempt
									   ,pattemptpause => pattemptpause);
				END IF;
			ELSE
				vlockerr := capture(object_name, paccountno);
			END IF;
		
			IF (vlockerr = 0)
			THEN
				accobjlocked := TRUE;
				vlockerr     := lockaccrow(vbranch, paccountno, vlockoptions.isrowlockwait);
				IF (vlockerr = err.account_not_found)
				THEN
					err.saveerror();
					object.release(object_name, paccountno);
					err.restoreerror();
				ELSE
					lockaccountstack.lockacct(paccountno);
				END IF;
			END IF;
		
			ROLLBACK TO accountlockobject;
		END IF;
	
		RETURN vlockerr;
	
	EXCEPTION
		WHEN OTHERS THEN
			BEGIN
				ROLLBACK TO accountlockobject;
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		
			IF (accobjlocked)
			THEN
				object.release(object_name, paccountno);
			END IF;
		
			IF SQLCODE = -54
			THEN
				err.seterror(err.account_busy
							,cpackagename || '.LockObject'
							,capturedobjectinfo(paccountno));
			ELSE
				err.seterror(SQLCODE, cpackagename || '.LockObject');
			END IF;
			RETURN err.geterrorcode;
	END;

	FUNCTION getmultitasklockoptions RETURN options.typelockoptions IS
		vseanceinfo  seance.typeseanceinfo := NULL;
		vlockoptions options.typelockoptions := NULL;
	BEGIN
		vseanceinfo := seance.getinfo();
		IF vseanceinfo.ismultitask
		THEN
			vlockoptions := options.getlockoptions();
		ELSE
			vlockoptions := NULL;
		END IF;
		RETURN vlockoptions;
	EXCEPTION
		WHEN OTHERS THEN
			error.raiseerror('Failed to get system-wide blocking settings');
	END;

	FUNCTION newobject
	(
		paccountno IN typeaccountno
	   ,pmod       IN CHAR
	) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(64) := cpackagename || '.NewObject';
		this      NUMBER;
		vkeyvalue VARCHAR(100);
		vfound    BOOLEAN := FALSE;
		userraise EXCEPTION;
		NOTFOUND EXCEPTION;
		vdummy  NUMBER;
		vbranch NUMBER := seance.getbranch();
	
		CURSOR c1 IS
			SELECT *
			FROM   taccount
			WHERE  branch = vbranch
			AND    accountno = ltrim(rtrim(paccountno))
			FOR    UPDATE NOWAIT;
	
		CURSOR c1_wait IS
			SELECT *
			FROM   taccount
			WHERE  branch = vbranch
			AND    accountno = ltrim(rtrim(paccountno))
			FOR    UPDATE wait 1;
	
		CURSOR c2 IS
			SELECT *
			FROM   taccount
			WHERE  branch = vbranch
			AND    accountno = ltrim(rtrim(paccountno));
	
		vlockoptions options.typelockoptions;
	
	BEGIN
		err.seterror(0, cwhere);
		s.say(cwhere || ' pAccountNo = ' || paccountno || ' pMod=' || pmod);
		vkeyvalue := ltrim(rtrim(paccountno));
	
		IF vkeyvalue IS NULL
		THEN
			s.err(cwhere || ' pAccountNo is null', 3);
			setaccountnotfounderror(paccountno, 'NewObject');
			RETURN 0;
		END IF;
	
		this := getfreehandle;
		sopenacc(this).notactualbalance := getflagnotactualbalance(paccountno);
		s.say('AccNotActualBalance ' || vkeyvalue || ' ' || upper(pmod) || ' - ...', 3);
		s.say(sopenacc(this).notactualbalance, 3);
		IF (err.geterrorcode() != 0)
		THEN
			RETURN 0;
		END IF;
	
		vlockoptions := getmultitasklockoptions();
		IF upper(pmod) = 'W'
		   OR (upper(pmod) = 'E' AND NOT sopenacc(this).notactualbalance)
		THEN
		
			vdummy := object.capture(object_name
									,vkeyvalue
									,pattempt      => vlockoptions.multitask_attempt
									,pattemptpause => vlockoptions.multitask_attemptpause);
			IF (err.geterrorcode = err.object_busy)
			THEN
			
				err.seterror(err.account_busy, cwhere, capturedobjectinfo(paccountno));
			
				s.err('pAccountNo: ' || paccountno || ' pMod:' || pmod, 3);
				RAISE userraise;
			ELSIF (err.geterrorcode != 0)
			THEN
				error.raisewhenerr();
			END IF;
		
		END IF;
	
		IF upper(pmod) = 'W'
		   OR (upper(pmod) = 'E' AND NOT sopenacc(this).notactualbalance)
		THEN
			SAVEPOINT accountnewobject;
		
			s.say(cwhere || ': vLockOptions.isRowLockWait=' ||
				  htools.bool2str(vlockoptions.isrowlockwait));
			IF vlockoptions.isrowlockwait
			THEN
				FOR i IN c1_wait
				LOOP
				
					sopenacc(this).branch := i.branch;
					sopenacc(this).accountno := i.accountno;
					sopenacc(this).accounttype := i.accounttype;
					sopenacc(this).currencyno := i.currencyno;
					sopenacc(this).idclient := i.idclient;
					sopenacc(this).remain := i.remain;
					sopenacc(this).available := i.available;
					sopenacc(this).overdraft := i.overdraft;
					sopenacc(this).noplan := i.noplan;
					sopenacc(this).createdate := i.createdate;
					sopenacc(this).createclerkcode := i.createclerkcode;
					sopenacc(this).updatedate := i.updatedate;
					sopenacc(this).updateclerkcode := i.updateclerkcode;
					sopenacc(this).updatesysdate := i.updatesysdate;
					sopenacc(this).stat := i.stat;
					sopenacc(this).acct_typ := i.acct_typ;
					sopenacc(this).acct_stat := i.acct_stat;
					sopenacc(this).closedate := i.closedate;
					sopenacc(this).remark := i.remark;
					sopenacc(this).debitreserve := i.debitreserve;
					sopenacc(this).creditreserve := i.creditreserve;
					sopenacc(this).lowremain := i.lowremain;
					sopenacc(this).branchpart := i.branchpart;
					sopenacc(this).limitgrp := i.limitgrpid;
					sopenacc(this).countergrp := i.countergrpid;
					sopenacc(this).updaterevision := nvl(i.updaterevision, 0);
					sopenacc(this).accforcedlock := FALSE;
					sopenacc(this).remainupdatedate := i.remainupdatedate;
					sopenacc(this).finprofile := i.finprofile;
					sopenacc(this).objectuid := i.objectuid;
				
					sopenacc(this).permissibleexcesstype := i.permissibleexcesstype;
					sopenacc(this).permissibleexcess := i.permissibleexcess;
				
					sopenacc(this).protectedamount := i.protectedamount;
				
					IF (sopenacc(this).objectuid IS NULL)
					THEN
						sopenacc(this).objectuid := objectuid.newuid(object_name
																	,sopenacc   (this).accountno
																	,pnocommit   => FALSE);
						updateobjectuid(sopenacc(this).accountno, sopenacc(this).objectuid);
					END IF;
				
					sopenacc(this).overdraft_comment := NULL;
					sopenacc(this).debitreserve_comment := NULL;
					sopenacc(this).creditreserve_comment := NULL;
				
					sopenacc(this).limitgrp_comment := NULL;
					sopenacc(this).countergrp_comment := NULL;
					sopenacc(this).intlimitgrp_comment := NULL;
				
					sopenacc(this).internallimitsgroupsysid := i.internallimitsgroupsysid;
					sopenacc(this).lowremain_comment := NULL;
					accobjectcontexthandles(this) := typeobjectcontexthandlearray_();
					sopenacc(this).finprofile_comment := NULL;
				
					sopenacc(this).accuserproplist := getuserattributeslist(sopenacc(this).accountno);
				
					sopenacc(this).extaccountno := acc2acc.getoldaccountno(i.accountno);
					vfound := TRUE;
				END LOOP;
			
			ELSE
			
				timer.start_(cwhere || '_' || paccountno || '_c1');
				FOR i IN c1
				LOOP
				
					sopenacc(this).branch := i.branch;
					sopenacc(this).accountno := i.accountno;
					sopenacc(this).accounttype := i.accounttype;
					sopenacc(this).currencyno := i.currencyno;
					sopenacc(this).idclient := i.idclient;
					sopenacc(this).remain := i.remain;
					sopenacc(this).available := i.available;
					sopenacc(this).overdraft := i.overdraft;
					sopenacc(this).noplan := i.noplan;
					sopenacc(this).createdate := i.createdate;
					sopenacc(this).createclerkcode := i.createclerkcode;
					sopenacc(this).updatedate := i.updatedate;
					sopenacc(this).updateclerkcode := i.updateclerkcode;
					sopenacc(this).updatesysdate := i.updatesysdate;
					sopenacc(this).stat := i.stat;
					sopenacc(this).acct_typ := i.acct_typ;
					sopenacc(this).acct_stat := i.acct_stat;
					sopenacc(this).closedate := i.closedate;
					sopenacc(this).remark := i.remark;
					sopenacc(this).debitreserve := i.debitreserve;
					sopenacc(this).creditreserve := i.creditreserve;
					sopenacc(this).lowremain := i.lowremain;
					sopenacc(this).branchpart := i.branchpart;
					sopenacc(this).limitgrp := i.limitgrpid;
					sopenacc(this).countergrp := i.countergrpid;
					sopenacc(this).updaterevision := nvl(i.updaterevision, 0);
					sopenacc(this).accforcedlock := FALSE;
					sopenacc(this).remainupdatedate := i.remainupdatedate;
					sopenacc(this).finprofile := i.finprofile;
					sopenacc(this).objectuid := i.objectuid;
				
					sopenacc(this).permissibleexcesstype := i.permissibleexcesstype;
					sopenacc(this).permissibleexcess := i.permissibleexcess;
				
					sopenacc(this).protectedamount := i.protectedamount;
				
					IF (sopenacc(this).objectuid IS NULL)
					THEN
						timer.start_(cwhere || '_' || paccountno || '_c1_UpdateObjectUId');
						sopenacc(this).objectuid := objectuid.newuid(object_name
																	,sopenacc   (this).accountno
																	,pnocommit   => FALSE);
						updateobjectuid(sopenacc(this).accountno, sopenacc(this).objectuid);
						timer.stop_(cwhere || '_' || paccountno || '_c1_UpdateObjectUId');
					END IF;
				
					sopenacc(this).overdraft_comment := NULL;
					sopenacc(this).debitreserve_comment := NULL;
					sopenacc(this).creditreserve_comment := NULL;
				
					sopenacc(this).limitgrp_comment := NULL;
					sopenacc(this).countergrp_comment := NULL;
					sopenacc(this).intlimitgrp_comment := NULL;
				
					sopenacc(this).internallimitsgroupsysid := i.internallimitsgroupsysid;
					sopenacc(this).lowremain_comment := NULL;
					accobjectcontexthandles(this) := typeobjectcontexthandlearray_();
					sopenacc(this).finprofile_comment := NULL;
				
					timer.start_(cwhere || '_' || paccountno || '_c1_GetUserAttributesList');
					sopenacc(this).accuserproplist := getuserattributeslist(sopenacc(this).accountno);
					timer.stop_(cwhere || '_' || paccountno || '_c1_GetUserAttributesList');
				
					sopenacc(this).extaccountno := acc2acc.getoldaccountno(i.accountno);
					vfound := TRUE;
				END LOOP;
				timer.stop_(cwhere || '_' || paccountno || '_c1');
			END IF;
		
			ROLLBACK TO accountnewobject;
		
		ELSIF upper(pmod) = 'E'
			  AND sopenacc(this).notactualbalance
		THEN
			SAVEPOINT accountnewobject;
			FOR i IN c2
			LOOP
			
				sopenacc(this).branch := i.branch;
				sopenacc(this).accountno := i.accountno;
				sopenacc(this).accounttype := i.accounttype;
				sopenacc(this).currencyno := i.currencyno;
				sopenacc(this).idclient := i.idclient;
				sopenacc(this).remain := i.remain;
				sopenacc(this).noplan := i.noplan;
				sopenacc(this).createdate := i.createdate;
				sopenacc(this).createclerkcode := i.createclerkcode;
				sopenacc(this).acct_typ := i.acct_typ;
			
				sopenacc(this).updatedate := NULL;
				sopenacc(this).updateclerkcode := NULL;
				sopenacc(this).updatesysdate := NULL;
				sopenacc(this).available := NULL;
				sopenacc(this).overdraft := NULL;
				sopenacc(this).stat := NULL;
				sopenacc(this).acct_stat := NULL;
				sopenacc(this).closedate := NULL;
				sopenacc(this).remark := NULL;
				sopenacc(this).debitreserve := NULL;
				sopenacc(this).creditreserve := NULL;
				sopenacc(this).lowremain := NULL;
				sopenacc(this).branchpart := NULL;
				sopenacc(this).limitgrp := NULL;
				sopenacc(this).countergrp := NULL;
				sopenacc(this).updaterevision := nvl(i.updaterevision, 0);
				sopenacc(this).accforcedlock := FALSE;
				sopenacc(this).remainupdatedate := NULL;
				sopenacc(this).finprofile := NULL;
				sopenacc(this).objectuid := i.objectuid;
			
				sopenacc(this).permissibleexcesstype := i.permissibleexcesstype;
				sopenacc(this).permissibleexcess := i.permissibleexcess;
			
				sopenacc(this).protectedamount := i.protectedamount;
			
				IF (sopenacc(this).objectuid IS NULL)
				THEN
				
					sopenacc(this).objectuid := createobjectuid_safe(sopenacc(this).accountno);
				END IF;
			
				sopenacc(this).overdraft_comment := NULL;
				sopenacc(this).debitreserve_comment := NULL;
				sopenacc(this).creditreserve_comment := NULL;
			
				sopenacc(this).limitgrp_comment := NULL;
				sopenacc(this).countergrp_comment := NULL;
				sopenacc(this).intlimitgrp_comment := NULL;
			
				sopenacc(this).internallimitsgroupsysid := NULL;
				sopenacc(this).lowremain_comment := NULL;
				accobjectcontexthandles(this) := typeobjectcontexthandlearray_();
				sopenacc(this).finprofile_comment := NULL;
			
				sopenacc(this).accuserproplist := getuserattributeslist(sopenacc(this).accountno);
				sopenacc(this).extaccountno := NULL;
			
				vfound := TRUE;
			END LOOP;
			ROLLBACK TO accountnewobject;
		
		ELSE
			FOR i IN c2
			LOOP
			
				sopenacc(this).branch := i.branch;
				sopenacc(this).accountno := i.accountno;
				sopenacc(this).accounttype := i.accounttype;
				sopenacc(this).currencyno := i.currencyno;
				sopenacc(this).idclient := i.idclient;
				sopenacc(this).remain := i.remain;
				sopenacc(this).available := i.available;
				sopenacc(this).overdraft := i.overdraft;
				sopenacc(this).noplan := i.noplan;
				sopenacc(this).createdate := i.createdate;
				sopenacc(this).createclerkcode := i.createclerkcode;
				sopenacc(this).updatedate := i.updatedate;
				sopenacc(this).updateclerkcode := i.updateclerkcode;
				sopenacc(this).updatesysdate := i.updatesysdate;
				sopenacc(this).stat := i.stat;
				sopenacc(this).acct_typ := i.acct_typ;
				sopenacc(this).acct_stat := i.acct_stat;
				sopenacc(this).closedate := i.closedate;
				sopenacc(this).remark := i.remark;
				sopenacc(this).debitreserve := i.debitreserve;
				sopenacc(this).creditreserve := i.creditreserve;
				sopenacc(this).lowremain := i.lowremain;
				sopenacc(this).branchpart := i.branchpart;
				sopenacc(this).limitgrp := i.limitgrpid;
				sopenacc(this).countergrp := i.countergrpid;
				sopenacc(this).updaterevision := nvl(i.updaterevision, 0);
				sopenacc(this).accforcedlock := FALSE;
				sopenacc(this).remainupdatedate := i.remainupdatedate;
				sopenacc(this).finprofile := i.finprofile;
				sopenacc(this).objectuid := i.objectuid;
			
				sopenacc(this).permissibleexcesstype := i.permissibleexcesstype;
				sopenacc(this).permissibleexcess := i.permissibleexcess;
			
				sopenacc(this).protectedamount := i.protectedamount;
			
				IF (sopenacc(this).objectuid IS NULL)
				THEN
				
					sopenacc(this).objectuid := createobjectuid_safe(sopenacc(this).accountno);
				END IF;
			
				sopenacc(this).overdraft_comment := NULL;
				sopenacc(this).debitreserve_comment := NULL;
				sopenacc(this).creditreserve_comment := NULL;
			
				sopenacc(this).limitgrp_comment := NULL;
				sopenacc(this).countergrp_comment := NULL;
				sopenacc(this).intlimitgrp_comment := NULL;
			
				sopenacc(this).internallimitsgroupsysid := i.internallimitsgroupsysid;
				sopenacc(this).lowremain_comment := NULL;
				accobjectcontexthandles(this) := typeobjectcontexthandlearray_();
				sopenacc(this).finprofile_comment := NULL;
			
				sopenacc(this).accuserproplist := getuserattributeslist(sopenacc(this).accountno);
			
				sopenacc(this).extaccountno := acc2acc.getoldaccountno(i.accountno);
				vfound := TRUE;
			END LOOP;
		END IF;
	
		IF NOT vfound
		THEN
			RAISE NOTFOUND;
		END IF;
	
		sopenacc(this).openmode := upper(pmod);
		sopenacc(this).isrb := FALSE;
		s.say(cwhere || '. sOpenAcc(this).AccUserPropList=' || sopenacc(this)
			  .accuserproplist.count);
	
		RETURN this;
	EXCEPTION
		WHEN userraise THEN
			s.err(cwhere || ' UserRaise pAccountNo: ' || paccountno || ' pMod:' || pmod, 3);
			RETURN 0;
		
		WHEN NOTFOUND THEN
			s.err(cwhere || ' NotFound pAccountNo: ' || paccountno || ' pMod:' || pmod, 3);
			IF upper(pmod) = 'W'
			   OR (upper(pmod) = 'E' AND NOT sopenacc(this).notactualbalance)
			THEN
				object.release(object_name, vkeyvalue);
			END IF;
			setaccountnotfounderror(paccountno, 'NewObject');
			RETURN 0;
		
		WHEN OTHERS THEN
			s.err(cwhere || ' OTHERS pAccountNo: ' || paccountno || ' pMod:' || pmod, 3);
			BEGIN
				ROLLBACK TO accountnewobject;
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			IF upper(pmod) = 'W'
			   OR (upper(pmod) = 'E' AND NOT sopenacc(this).notactualbalance)
			THEN
				object.release(object_name, vkeyvalue);
			END IF;
			IF SQLCODE = -54
			THEN
			
				err.seterror(err.account_busy, cwhere, capturedobjectinfo(paccountno));
			
			ELSE
				err.seterror(SQLCODE, cwhere);
			END IF;
			RETURN 0;
	END;

	PROCEDURE readobject(this IN NUMBER) IS
		vaccountrow taccount%ROWTYPE;
		vbranch     NUMBER := seance.getbranch();
		cwhere CONSTANT VARCHAR2(50) := cpackagename || '.ReadObject';
	BEGIN
		IF testhandle(this, cpackagename || '.ReadObject') != 'N'
		THEN
			SELECT *
			INTO   vaccountrow
			FROM   taccount
			WHERE  branch = vbranch
			AND    accountno = sopenacc(this).accountno;
		
			sopenacc(this).branch := vaccountrow.branch;
			sopenacc(this).accountno := vaccountrow.accountno;
			sopenacc(this).accounttype := vaccountrow.accounttype;
			sopenacc(this).currencyno := vaccountrow.currencyno;
			sopenacc(this).idclient := vaccountrow.idclient;
			sopenacc(this).remain := vaccountrow.remain;
			sopenacc(this).available := vaccountrow.available;
			sopenacc(this).overdraft := vaccountrow.overdraft;
			sopenacc(this).noplan := vaccountrow.noplan;
			sopenacc(this).createdate := vaccountrow.createdate;
			sopenacc(this).createclerkcode := vaccountrow.createclerkcode;
			sopenacc(this).updatedate := vaccountrow.updatedate;
			sopenacc(this).updateclerkcode := vaccountrow.updateclerkcode;
			sopenacc(this).updatesysdate := vaccountrow.updatesysdate;
			sopenacc(this).stat := vaccountrow.stat;
			sopenacc(this).acct_typ := vaccountrow.acct_typ;
			sopenacc(this).acct_stat := vaccountrow.acct_stat;
			sopenacc(this).closedate := vaccountrow.closedate;
			sopenacc(this).remark := vaccountrow.remark;
			sopenacc(this).debitreserve := vaccountrow.debitreserve;
			sopenacc(this).creditreserve := vaccountrow.creditreserve;
			sopenacc(this).lowremain := vaccountrow.lowremain;
			sopenacc(this).branchpart := vaccountrow.branchpart;
			sopenacc(this).limitgrp := vaccountrow.limitgrpid;
			sopenacc(this).countergrp := vaccountrow.countergrpid;
			sopenacc(this).updaterevision := nvl(vaccountrow.updaterevision, 0);
			sopenacc(this).finprofile := vaccountrow.finprofile;
			sopenacc(this).remainupdatedate := vaccountrow.remainupdatedate;
		
			sopenacc(this).permissibleexcesstype := vaccountrow.permissibleexcesstype;
			sopenacc(this).permissibleexcess := vaccountrow.permissibleexcess;
		
			sopenacc(this).protectedamount := vaccountrow.protectedamount;
		
			sopenacc(this).overdraft_comment := NULL;
			sopenacc(this).debitreserve_comment := NULL;
			sopenacc(this).creditreserve_comment := NULL;
		
			sopenacc(this).limitgrp_comment := NULL;
			sopenacc(this).countergrp_comment := NULL;
			sopenacc(this).intlimitgrp_comment := NULL;
		
			sopenacc(this).internallimitsgroupsysid := vaccountrow.internallimitsgroupsysid;
		
			sopenacc(this).lowremain_comment := NULL;
		
			sopenacc(this).finprofile_comment := NULL;
		
			sopenacc(this).accuserproplist := getuserattributeslist(sopenacc(this).accountno);
			s.say(cwhere || ' sOpenAcc(this).AccUserPropList=' || sopenacc(this)
				  .accuserproplist.count);
		
			sopenacc(this).isrb := FALSE;
			sopenacc(this).extaccountno := acc2acc.getoldaccountno(vaccountrow.accountno);
		END IF;
	EXCEPTION
		WHEN no_data_found THEN
			setaccountnotfounderror(sopenacc(this).accountno, cwhere);
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cwhere);
	END;

	PROCEDURE refreshaccount(paccountno IN typeaccountno) IS
		voperdate  DATE := seance.getoperdate();
		vclerkcode NUMBER := clerk.getcode();
		vbranch    NUMBER := seance.getbranch;
	BEGIN
		s.say(cpackagename || ': refreshing account ' || paccountno, 2);
	
		UPDATE taccount
		SET    updatedate      = voperdate
			  ,updateclerkcode = vclerkcode
			  ,updatesysdate   = SYSDATE()
		
		WHERE  branch = vbranch
		AND    accountno = paccountno;
	EXCEPTION
		WHEN OTHERS THEN
			s.say('> ' || cpackagename || '.RefreshAccount error: ' || SQLERRM());
			NULL;
	END;

	PROCEDURE closeaccount
	(
		paccounthandle IN NUMBER
	   ,pclosedate     IN DATE := NULL
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.CloseAccount';
		vaccountno typeaccountno;
		vclosedate DATE;
	BEGIN
		err.seterror(0, NULL);
		vaccountno := getaccountno(paccounthandle);
		IF (err.geterrorcode() = 0)
		THEN
			IF (contract.getcontractnobyaccno(vaccountno, FALSE) IS NOT NULL)
			THEN
				err.seterror(err.account_belongs_to_contract
							,'Attempted closure of account belonging to contract');
			END IF;
			IF (err.geterrorcode() = 0)
			THEN
				IF (account.isclose(paccounthandle))
				THEN
					err.seterror(err.account_closed
								,cmethodname
								,'Attempted closure of closed account');
				END IF;
				IF (err.geterrorcode() = 0)
				THEN
					IF (getremain(paccounthandle) != 0)
					THEN
						err.seterror(err.account_remain_nonzero
									,cmethodname
									,'Account ledger balance is not zero when closing account');
					END IF;
				
					IF (err.geterrorcode() = 0)
					THEN
						IF (nvl(getdebitreserve(paccounthandle), 0) != 0 OR
						   nvl(getcreditreserve(paccounthandle), 0) != 0)
						THEN
							err.seterror(custom_err.account_holds_exist
										,cmethodname
										,'Amount on hold is not zero at account closure');
						END IF;
					
						IF (custom_err.geterrorcode() = 0)
						THEN
							IF (pclosedate IS NULL)
							THEN
								vclosedate := seance.getoperdate();
							ELSE
								vclosedate := pclosedate;
							END IF;
							setclosedate(paccounthandle, vclosedate);
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			setexceptionerror(cpackagename || '.CloseAccount', sopenacc(paccounthandle).accountno);
			s.err(cmethodname);
	END;

	PROCEDURE cancelaccountclosure(paccounthandle IN NUMBER) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.CancelAccountClosure';
		vaccountno typeaccountno;
	BEGIN
		err.seterror(0, NULL);
	
		vaccountno := getaccountno(paccounthandle);
		IF (err.geterrorcode() = 0)
		THEN
			IF (contract.getcontractnobyaccno(vaccountno, FALSE) IS NOT NULL)
			THEN
				err.seterror(err.account_belongs_to_contract
							,'Attempted cancellation of closing account belonging to contract');
			END IF;
			IF (err.geterrorcode() = 0)
			THEN
				IF (NOT account.isclose(paccounthandle))
				THEN
					err.seterror(err.ue_other
								,cmethodname
								,'Attempted cancellation of closing open account');
				END IF;
				IF (err.geterrorcode() = 0)
				THEN
					setclosedate(paccounthandle, NULL);
				END IF;
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			s.err(cmethodname);
	END;

	PROCEDURE closeanyaccount
	(
		paccounthandle IN NUMBER
	   ,pclosedate     IN DATE := NULL
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.CloseAnyAccount';
		vclosedate DATE;
	BEGIN
		err.seterror(0, NULL);
		IF (err.geterrorcode() = 0)
		THEN
			IF (account.isclose(paccounthandle))
			THEN
				err.seterror(err.account_closed
							,cmethodname
							,'Attempted closure of closed account');
			END IF;
			IF (err.geterrorcode() = 0)
			THEN
				IF (getremain(paccounthandle) != 0)
				THEN
					err.seterror(err.account_remain_nonzero
								,cmethodname
								,'Account ledger balance is not zero when closing account');
				END IF;
			
				IF (err.geterrorcode() = 0)
				THEN
					IF (nvl(getdebitreserve(paccounthandle), 0) != 0 OR
					   nvl(getcreditreserve(paccounthandle), 0) != 0)
					THEN
						err.seterror(custom_err.account_holds_exist
									,cmethodname
									,'Amount on hold is not zero at account closure');
					END IF;
				
					IF (err.geterrorcode() = 0)
					THEN
						IF (pclosedate IS NULL)
						THEN
							vclosedate := seance.getoperdate();
						ELSE
							vclosedate := pclosedate;
						END IF;
						setclosedate(paccounthandle, vclosedate);
					END IF;
				END IF;
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			setexceptionerror(cpackagename || '.CloseAnyAccount'
							 ,sopenacc(paccounthandle).accountno);
			s.err(cmethodname);
	END;

	PROCEDURE setacct_stat
	(
		this              IN NUMBER
	   ,pacct_stat        IN CHAR
	   ,ponlineprocessing IN BOOLEAN := FALSE
	   ,pcomment          IN VARCHAR2 := NULL
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetACCT_STAT') != 'N'
		THEN
		
			IF (pacct_stat IS NOT NULL AND NOT acct_statisvalid(pacct_stat))
			THEN
				err.seterror(err.account_invalid_value
							,cpackagename || '.SetACCT_STAT'
							,err.getmessage(err.account_invalid_value) || ' Acct_Stat = ' ||
							 pacct_stat);
				RETURN;
			END IF;
		
			sopenacc(this).acct_stat := pacct_stat;
			sopenacc(this).acct_stat_comment := pcomment;
		
			IF ponlineprocessing
			THEN
				IF remoteonline.setaccountstatus(sopenacc(this).accountno, pacct_stat) !=
				   remoteonline.err_approved
				THEN
					error.raiseerror('Error setting ACCT_STAT value for account online: ' ||
									 remoteonline.geterrortext(remoteonline.geterrorcode)
									 
									 );
				END IF;
			END IF;
		
		END IF;
	END;

	PROCEDURE setacct_typ
	(
		this      IN NUMBER
	   ,pacct_typ IN CHAR
	   ,pcomment  IN VARCHAR2 := NULL
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetACCT_TYP') != 'N'
		THEN
		
			IF (pacct_typ IS NOT NULL AND NOT acct_typisvalid(pacct_typ))
			THEN
				err.seterror(err.account_invalid_value
							,cpackagename || '.SetACCT_TYP'
							,err.getmessage(err.account_invalid_value) || ' Acct_Typ = ' ||
							 pacct_typ);
				RETURN;
			END IF;
		
			sopenacc(this).acct_typ := pacct_typ;
			sopenacc(this).acct_typ_comment := pcomment;
		END IF;
	END;

	PROCEDURE setavailable
	(
		this       IN NUMBER
	   ,pavailable IN NUMBER
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetAvailable') != 'N'
		THEN
			sopenacc(this).available := pavailable;
		END IF;
	END;

	PROCEDURE setclosedate
	(
		this       IN NUMBER
	   ,pclosedate IN DATE
	) IS
	
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.SetCloseDate';
		vacardlinks apitypes.typeaccount2cardlist;
		vcard       apitypes.typecardrecord;
		i           PLS_INTEGER;
	
		vatelebanks apitypes.typetelebanklist;
	
	BEGIN
		IF (testhandle(this, cmethodname) != 'N')
		THEN
		
			err.seterror(0, cmethodname);
			IF (pclosedate IS NOT NULL)
			THEN
			
				IF (NOT getbranchoption(cbonallowaccswopencardsclosing)
				   
				   )
				THEN
				
					vacardlinks := getcardlist(getaccountno(this));
					i           := vacardlinks.first();
					WHILE (i IS NOT NULL AND err.geterrorcode() = 0)
					LOOP
						IF (vacardlinks(i).acct_stat = referenceacct_stat.stat_primary)
						THEN
							vcard := card.getcardrecord(vacardlinks(i).pan, vacardlinks(i).mbr);
							IF (err.geterrorcode() = 0)
							THEN
								IF (vcard.closedate IS NULL)
								THEN
									err.seterror(err.account_objects_exist
												,cmethodname
												,'There are cards whose linked account being closed is of "Primary open" status');
								END IF;
							ELSIF (err.geterrorcode() = err.card_not_found)
							THEN
								err.seterror(0, cmethodname);
							END IF;
						END IF;
						IF (err.geterrorcode() = 0)
						THEN
							i := vacardlinks.next(i);
						END IF;
					END LOOP;
				
				END IF;
			
				IF (err.geterrorcode() = 0)
				THEN
					vatelebanks := telebank.getcustomerlistbypayaccount(getaccountno(this));
					i           := vatelebanks.first();
					WHILE (i IS NOT NULL AND err.geterrorcode() = 0)
					LOOP
						IF (vatelebanks(i).sign != referencecustomer.sign_close)
						THEN
							err.seterror(err.account_objects_exist
										,cmethodname
										,'There are opened Telebank customers whose accounts being closed are payment accounts');
						END IF;
						i := vatelebanks.next(i);
					END LOOP;
				END IF;
			
			END IF;
		
			IF (err.geterrorcode() = 0)
			THEN
			
				sopenacc(this).closedate := pclosedate;
				IF (pclosedate IS NULL)
				THEN
					setstat(this, service.clsbit(getstat(this), stat_close));
				ELSE
					setstat(this, service.setbit(getstat(this), stat_close));
				END IF;
			
			ELSE
				s.say(err.getfullmessage(), 3);
			END IF;
		
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
		
	END;

	PROCEDURE setcreatedate
	(
		this        IN NUMBER
	   ,pcreatedate IN DATE
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetCreateDate') != 'N'
		THEN
			sopenacc(this).createdate := pcreatedate;
		END IF;
	END;

	PROCEDURE setcurrentaccount(paccountno IN typeaccountno) IS
	BEGIN
		scurrentaccount := paccountno;
	END;

	PROCEDURE setcurrent(prec apitypes.typeaccountrecord) IS
	BEGIN
		scurrentrecord := prec;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cpackagename || '.SetCurrent');
			error.save(cpackagename || '.SetCurrent');
	END;

	FUNCTION getcurrent RETURN apitypes.typeaccountrecord IS
		vaccountrecord apitypes.typeaccountrecord;
	BEGIN
		IF scurrentrecord.accountno IS NOT NULL
		THEN
			RETURN scurrentrecord;
		END IF;
		s.say(cpackagename || '.GetCurrent Account Record is not defined!');
		RETURN NULL;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetCurrent');
			RETURN vaccountrecord;
	END;

	PROCEDURE setidclient
	(
		this      IN NUMBER
	   ,pidclient IN NUMBER
	) IS
	BEGIN
		IF testhandle(this, 'SetIdClient') != 'N'
		THEN
			sopenacc(this).idclient := pidclient;
		END IF;
	END;

	PROCEDURE setlowremain
	(
		this                    IN NUMBER
	   ,plowremain              IN NUMBER
	   ,pcomment                IN VARCHAR2 := NULL
	   ,ponlineprocessing       IN BOOLEAN := FALSE
	   ,pdisableonlinelowremain IN BOOLEAN := FALSE
	) IS
	
		vdelta NUMBER;
		vold   NUMBER;
		vres   NUMBER;
	BEGIN
	
		IF testhandle(this, cpackagename || '.SetLowRemain') != 'N'
		THEN
			IF nvl(plowremain, 0) < 0
			THEN
				err.seterror(err.account_invalid_value
							,cpackagename || '.SetLowRemain'
							,'Set negative minimum account balance');
				RETURN;
			END IF;
		
			IF ponlineprocessing
			THEN
				vold   := sopenacc(this).lowremain;
				vdelta := vold - plowremain;
				IF vold < plowremain
				THEN
				
					BEGIN
						vres := remoteonline.accountdebit(sopenacc(this).accountno
														 ,abs(vdelta)
														 ,pforce => pdisableonlinelowremain);
					EXCEPTION
						WHEN OTHERS THEN
							error.save(cpackagename || '.SetLowRemain');
					END;
					IF remoteonline.geterrorcode() != remoteonline.err_approved
					THEN
					
						error.raiseerror('Error setting LowRemain value for account online: ' ||
										 remoteonline.geterrortext(remoteonline.geterrorcode));
					END IF;
					s.say(cpackagename || 'AccountDebit vOld=' || vold || ' vDelta=' || vdelta ||
						  ' pLowRemain=' || plowremain || ' vRes=' || vres);
				ELSIF vold > plowremain
				THEN
				
					BEGIN
						vres := remoteonline.accountcredit(sopenacc(this).accountno, abs(vdelta));
					EXCEPTION
						WHEN OTHERS THEN
							error.save(cpackagename || '.SetLowRemain');
					END;
					IF remoteonline.geterrorcode() != remoteonline.err_approved
					THEN
					
						error.raiseerror('Error setting LowRemain value for account online: ' ||
										 remoteonline.geterrortext(remoteonline.geterrorcode));
					END IF;
					s.say(cpackagename || 'AccountCredit vOld=' || vold || ' vDelta=' || vdelta ||
						  ' pLowRemain=' || plowremain || ' vRes=' || vres);
				END IF;
			END IF;
			sopenacc(this).lowremain := plowremain;
			sopenacc(this).lowremain_comment := pcomment;
		
		END IF;
	END;

	PROCEDURE setaccounttype
	(
		vaccounthandle  IN NUMBER
	   ,pnewaccounttype IN NUMBER
	) IS
		cmethodname CONSTANT VARCHAR2(32) := cpackagename || '.SetAccountType';
		voldaccounttype  NUMBER := NULL;
		voldplanno       NUMBER := NULL;
		voldcurrencycode NUMBER;
		vnewplanno       NUMBER;
		vnewcurrencycode NUMBER;
		elocalscope EXCEPTION;
	
		PROCEDURE rollbackchanges IS
		BEGIN
			IF (vaccounthandle IS NOT NULL)
			THEN
				IF (voldaccounttype IS NOT NULL)
				THEN
					sopenacc(vaccounthandle).accounttype := voldaccounttype;
					IF (voldplanno IS NOT NULL)
					THEN
						sopenacc(vaccounthandle).noplan := voldplanno;
					END IF;
				END IF;
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	
	BEGIN
		err.seterror(0, cmethodname);
		IF (testhandle(vaccounthandle, cmethodname) != 'N')
		THEN
			voldaccounttype := sopenacc(vaccounthandle).accounttype;
			IF (voldaccounttype = pnewaccounttype)
			THEN
				RETURN;
			END IF;
		
			voldplanno := accounttype.getnoplan(voldaccounttype);
			IF (err.geterrorcode() != 0)
			THEN
				RAISE elocalscope;
			END IF;
		
			vnewplanno := accounttype.getnoplan(pnewaccounttype);
			IF (err.geterrorcode() != 0)
			THEN
				RAISE elocalscope;
			END IF;
		
			IF (nvl(voldplanno, -1) != nvl(vnewplanno, -1))
			THEN
				voldcurrencycode := planaccount.getcurrency(voldplanno);
				IF (err.geterrorcode() != 0)
				THEN
					RAISE elocalscope;
				END IF;
			
				vnewcurrencycode := planaccount.getcurrency(vnewplanno);
				IF (err.geterrorcode() != 0)
				THEN
					RAISE elocalscope;
				END IF;
			
				IF (nvl(voldcurrencycode, -1) != nvl(vnewcurrencycode, -1))
				THEN
					err.seterror(err.mb_error_change_acc_curr, cmethodname);
					RAISE elocalscope;
				END IF;
			
				sopenacc(vaccounthandle).noplan := vnewplanno;
			
				sopenacc(vaccounthandle).notactualbalance := planaccount.getflagnotactualbalance(vnewplanno);
				IF (err.geterrorcode() != 0)
				THEN
					RAISE elocalscope;
				END IF;
			
			END IF;
		
			sopenacc(vaccounthandle).accounttype := pnewaccounttype;
		
		END IF;
	EXCEPTION
		WHEN elocalscope THEN
			rollbackchanges();
		WHEN OTHERS THEN
			rollbackchanges();
			err.seterror(SQLCODE(), cmethodname, SQLERRM());
	END;

	PROCEDURE setoverdraft
	(
		this              IN NUMBER
	   ,poverdraft        IN NUMBER
	   ,pcomment          IN VARCHAR2 := NULL
	   ,ponlineprocessing IN BOOLEAN := FALSE
	) IS
		vdelta      NUMBER;
		vold        NUMBER;
		voldcomment taccounteventlog.additionalinfo%TYPE;
		vdummy      VARCHAR(4000);
	BEGIN
		IF testhandle(this, cpackagename || '.SetOverdraft') != 'N'
		THEN
			IF nvl(poverdraft, 0) < 0
			THEN
				err.seterror(err.account_invalid_value, cpackagename || '.SetOverdraft');
				RETURN;
			END IF;
			vold := sopenacc(this).overdraft;
			voldcomment := sopenacc(this).overdraft_comment;
			vdelta := poverdraft - vold;
			sopenacc(this).overdraft := poverdraft;
			sopenacc(this).overdraft_comment := pcomment;
		
			IF ponlineprocessing
			THEN
				IF remoteonline.setaccountoverdraft(sopenacc(this).accountno
												   ,vdelta
												   ,NULL
												   ,NULL
												   ,TRUE
												   ,pcomment
												   ,NULL
												   ,NULL
												   ,vdummy) != remoteonline.err_approved
				THEN
					error.raiseerror('Error setting Overdraft value for account online: ' ||
									 remoteonline.geterrortext(remoteonline.geterrorcode));
				END IF;
			END IF;
		
		END IF;
	END;

	PROCEDURE setovertype
	(
		this      IN NUMBER
	   ,povertype IN NUMBER
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetOverType') != 'N'
		THEN
			sopenacc(this).permissibleexcesstype := povertype;
		END IF;
	END;

	PROCEDURE setovervalue
	(
		this       IN NUMBER
	   ,povervalue IN NUMBER
	) IS
	BEGIN
		s.say(cpackagename || '.SetOverValue: pOverValue=' || povervalue);
		IF testhandle(this, cpackagename || '.SetOverValue') != 'N'
		THEN
			sopenacc(this).permissibleexcess := povervalue;
		END IF;
	END;

	PROCEDURE setaccount
	(
		this     IN NUMBER
	   ,paccinfo IN typeaccount
	) IS
		vupdaterevision taccount.updaterevision%TYPE;
	BEGIN
		IF testhandle(this, cpackagename || '.SetAccount') != 'N'
		THEN
			vupdaterevision := sopenacc(this).updaterevision;
			sopenacc(this) := paccinfo;
			sopenacc(this).updaterevision := vupdaterevision;
		END IF;
	END;

	PROCEDURE setprotectedamountfo
	(
		this             IN NUMBER
	   ,pprotectedamount IN NUMBER
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetProtectedAmountFO') != 'N'
		THEN
			sopenacc(this).protectedamount := pprotectedamount;
		END IF;
	END;

	PROCEDURE changeprotectedamountfo
	(
		this   NUMBER
	   ,pdelta NUMBER
	) IS
		vpacurrent NUMBER := account.getprotectedamountfo(this);
	BEGIN
		err.seterror(0, 'ChangeProtectedAmountFO');
	
		IF vpacurrent IS NULL
		THEN
			error.raiseerror(err.account_pamount_forbidden
							,' Impossible to change protected amount as it is not used ');
		END IF;
		IF pdelta IS NULL
		THEN
			error.raiseerror(err.ue_value_notdefined
							,'Impossible to change protected amount to zero ');
		ELSIF pdelta = 0
		THEN
			s.say('ChangeProtectedAmountFO: pDelta=' || pdelta);
			RETURN;
		END IF;
	
		s.say('ChangeProtectedAmountFO: vPACurrent=' || vpacurrent || '  pDelta=' || pdelta);
		account.setprotectedamountfo(this, vpacurrent + pdelta);
		error.raisewhenerr();
		account.writeobject(this);
		error.raisewhenerr();
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.ChangeProtectedAmountFO this [' || this || '], pDelta [' ||
					   pdelta || ']');
			RAISE;
	END;

	PROCEDURE changeprotectedamountfo
	(
		paccountno  IN typeaccountno
	   ,pvalue      IN NUMBER
	   ,plockobject IN BOOLEAN := FALSE
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.ChangeProtectedAmountFO';
		voperdate      DATE := seance.getoperdate();
		vclerkcode     NUMBER := clerk.getcode();
		vaccountlocked BOOLEAN := NULL;
		vbranch        NUMBER := seance.getbranch();
		vaccountfound  BOOLEAN;
	BEGIN
		s.say(cpackagename || ': changing protected amount of account ' || paccountno, 2);
	
		err.seterror(0, cpackagename || '.ChangeProtectedAmountFO');
	
		IF (plockobject)
		THEN
			vaccountlocked := lockobject(paccountno, 'W') = 0;
		END IF;
	
		IF (err.geterrorcode() = 0)
		THEN
			vaccountfound := FALSE;
		
			FOR i IN (SELECT 1
					  FROM   taccount
					  WHERE  branch = vbranch
					  AND    accountno = paccountno)
			LOOP
				vaccountfound := TRUE;
			END LOOP;
		
			IF (NOT vaccountfound)
			THEN
				setaccountnotfounderror(paccountno, 'ChangeProtectedAmountFO');
			END IF;
		
			IF getprotectedamountbyaccno(paccountno) IS NULL
			THEN
				error.raiseerror(err.account_pamount_forbidden
								,' Impossible to change protected amount as it is not used ');
			END IF;
			IF pvalue IS NULL
			THEN
				error.raiseerror(err.ue_value_notdefined
								,'Impossible to change protected amount to zero ');
			END IF;
		
			IF (err.geterrorcode() = 0)
			THEN
				UPDATE taccount
				
				SET    protectedamount = protectedamount + pvalue
					  ,updatedate      = voperdate
					  ,updateclerkcode = vclerkcode
					  ,updatesysdate   = SYSDATE()
					  ,updaterevision  = seq_accountupdaterevision.nextval
				WHERE  branch = vbranch
				AND    accountno = paccountno;
			END IF;
		END IF;
	
		IF (vaccountlocked)
		THEN
			unlockobject(paccountno);
			vaccountlocked := FALSE;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			BEGIN
				IF (vaccountlocked)
				THEN
					unlockobject(paccountno);
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					s.err('Error while releasing account ' || paccountno);
			END;
			err.seterror(SQLCODE(), cmethodname);
	END;

	PROCEDURE setremain
	(
		this    IN NUMBER
	   ,premain IN NUMBER
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetRemain') != 'N'
		THEN
			sopenacc(this).remain := premain;
		END IF;
	END;

	PROCEDURE setremark
	(
		this    IN NUMBER
	   ,premark IN VARCHAR
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetRemark') != 'N'
		THEN
			sopenacc(this).remark := substr(premark, 1, 250);
		END IF;
	END;

	PROCEDURE setextaccountno
	(
		this     IN NUMBER
	   ,paccount IN VARCHAR
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetExtAccountNo') != 'N'
		THEN
			sopenacc(this).extaccountno := paccount;
		END IF;
	END;

	PROCEDURE setbranchpart
	(
		this        IN NUMBER
	   ,pbranchpart IN NUMBER
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.BranchPart') != 'N'
		THEN
			sopenacc(this).branchpart := pbranchpart;
		END IF;
	END;

	PROCEDURE setdebitreserve
	(
		this          IN NUMBER
	   ,pdebitreserve IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetDebitReserve') != 'N'
		THEN
			IF nvl(pdebitreserve, 0) < 0
			THEN
				err.seterror(err.account_invalid_value, cpackagename || '.SetDebitReserve');
				RETURN;
			END IF;
			sopenacc(this).debitreserve := pdebitreserve;
		
			sopenacc(this).debitreserve_comment := pcomment;
		
		END IF;
	END;

	PROCEDURE setcreditreserve
	(
		this           IN NUMBER
	   ,pcreditreserve IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetCreditReserve') != 'N'
		THEN
			IF nvl(pcreditreserve, 0) < 0
			THEN
				err.seterror(err.account_invalid_value, cpackagename || '.SetCreditReserve');
				RETURN;
			END IF;
			sopenacc(this).creditreserve := pcreditreserve;
		
			sopenacc(this).creditreserve_comment := pcomment;
		
		END IF;
	END;

	PROCEDURE changedebitreservebyhandle
	(
		paccounthandle IN NUMBER
	   ,pdelta         IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.ChangeDebitReserveByHandle';
		vnewdebitreserve NUMBER;
	BEGIN
		IF (testhandle(paccounthandle, cmethodname) != 'N')
		THEN
			vnewdebitreserve := nvl(sopenacc(paccounthandle).debitreserve, 0) + nvl(pdelta, 0);
			IF (vnewdebitreserve < 0)
			THEN
				err.seterror(err.account_invalid_value, cmethodname);
				RETURN;
			END IF;
			sopenacc(paccounthandle).debitreserve := vnewdebitreserve;
		
			sopenacc(paccounthandle).debitreserve_comment := pcomment;
		
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE changecreditreservebyhandle
	(
		paccounthandle IN NUMBER
	   ,pdelta         IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.ChangeCreditReserve';
		vnewcreditreserve NUMBER;
	BEGIN
		IF (testhandle(paccounthandle, cmethodname) != 'N')
		THEN
			vnewcreditreserve := nvl(sopenacc(paccounthandle).creditreserve, 0) + nvl(pdelta, 0);
			IF (vnewcreditreserve < 0)
			THEN
				err.seterror(err.account_invalid_value, cmethodname);
				RETURN;
			END IF;
			sopenacc(paccounthandle).creditreserve := vnewcreditreserve;
		
			sopenacc(paccounthandle).creditreserve_comment := pcomment;
		
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE setstat
	(
		this     IN NUMBER
	   ,pstat    IN CHAR
	   ,pcomment IN VARCHAR2 := NULL
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetStat') != 'N'
		THEN
			sopenacc(this).stat := pstat;
			sopenacc(this).stat_comment := pcomment;
		END IF;
	END;

	PROCEDURE setbookflag(paccountno IN typeaccountno) IS
		voperdate  DATE;
		vclerkcode NUMBER;
		vstat      taccount.stat%TYPE;
		vbranch    NUMBER := seance.getbranch();
	BEGIN
		s.say(cpackagename || ': setting book flag of account ' || paccountno, 2);
	
		voperdate  := seance.getoperdate;
		vclerkcode := clerk.getcode;
	
		SELECT stat
		INTO   vstat
		FROM   taccount
		WHERE  branch = vbranch
		AND    accountno = paccountno;
	
		IF (service.getbit(vstat, account.stbook) != 1)
		THEN
		
			err.seterror(0, NULL);
			logbookissuing(paccountno);
			IF (err.geterrorcode() = 0)
			THEN
			
				vstat := service.setbit(vstat, account.stbook);
				UPDATE taccount
				SET    stat            = vstat
					  ,updatedate      = voperdate
					  ,updateclerkcode = vclerkcode
					  ,updatesysdate   = SYSDATE()
					  ,updaterevision  = seq_accountupdaterevision.nextval
				WHERE  branch = vbranch
				AND    accountno = paccountno;
			
			END IF;
		
		END IF;
	EXCEPTION
		WHEN no_data_found THEN
			setaccountnotfounderror(paccountno, 'SetBookFlag');
	END;

	PROCEDURE setlimitgrp
	(
		this      IN NUMBER
	   ,plimitgrp IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.SetLimitGrp';
	BEGIN
		IF (testhandle(this, cmethodname) != 'N')
		THEN
			sopenacc(this).limitgrp := plimitgrp;
		
			sopenacc(this).limitgrp_comment := pcomment;
		
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE setlimitgrp
	(
		this           IN NUMBER
	   ,plimitgrp      IN NUMBER
	   ,pchangesource  IN VARCHAR2
	   ,pterminalid    IN VARCHAR2
	   ,ptransactionid IN VARCHAR2
	) IS
	BEGIN
		setlimitgrp(this
				   ,plimitgrp
				   ,pchangesource || ';' || pterminalid || ';' || ptransactionid || ';');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SetLimitGrp');
			RAISE;
	END;

	PROCEDURE setcountergrp
	(
		this        IN NUMBER
	   ,pcountergrp IN NUMBER
	   ,pcomment    IN VARCHAR := NULL
	) IS
		cwhere CONSTANT VARCHAR2(64) := cpackagename || '.SetCounterGrp';
	BEGIN
		IF (testhandle(this, cwhere) != 'N')
		THEN
			sopenacc(this).countergrp := pcountergrp;
			sopenacc(this).countergrp_comment := pcomment;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE setcountergrp
	(
		this           IN NUMBER
	   ,pcountergrp    IN NUMBER
	   ,pchangesource  IN VARCHAR2
	   ,pterminalid    IN VARCHAR2
	   ,ptransactionid IN VARCHAR2
	) IS
		cwhere CONSTANT VARCHAR2(64) := cpackagename || '.SetCounterGrp';
	BEGIN
		setcountergrp(this
					 ,pcountergrp
					 ,pchangesource || ';' || pterminalid || ';' || ptransactionid || ';');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
	END;

	PROCEDURE setinternallimitsgroupsysid
	(
		this                      IN NUMBER
	   ,pinternallimitsgroupsysid IN NUMBER
	   ,
		
		pcomment IN VARCHAR2 := NULL
		
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.SetInternalLimitsGroupSysId';
	BEGIN
		IF (testhandle(this, cmethodname) != 'N')
		THEN
			sopenacc(this).internallimitsgroupsysid := pinternallimitsgroupsysid;
		
			sopenacc(this).intlimitgrp_comment := pcomment;
		
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE setinternallimitsgroupsysid
	(
		this                      IN NUMBER
	   ,pinternallimitsgroupsysid IN NUMBER
	   ,pchangesource             IN VARCHAR2
	   ,pterminalid               IN VARCHAR2
	   ,ptransactionid            IN VARCHAR2
	) IS
	BEGIN
		setinternallimitsgroupsysid(this
								   ,pinternallimitsgroupsysid
								   ,pchangesource || ';' || pterminalid || ';' || ptransactionid || ';');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SetInternalLimitsGroupSysId');
			RAISE;
	END;

	PROCEDURE setfinprofile
	(
		pthis       IN NUMBER
	   ,pfinprofile IN NUMBER
	   ,pcomment    IN VARCHAR2 := NULL
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.SetFinProfile';
	BEGIN
		IF (testhandle(pthis, cmethodname) != 'N')
		THEN
			sopenacc(pthis).finprofile := pfinprofile;
			sopenacc(pthis).finprofile_comment := pcomment;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE setuserproplist
	(
		pthis               IN NUMBER
	   ,puserproplist       IN apitypes.typeuserproplist
	   ,pclearpropnotinlist IN BOOLEAN := FALSE
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.SetUserPropList';
	
	BEGIN
		s.say(cmethodname || '. start');
		IF (testhandle(pthis, cmethodname) != 'N')
		THEN
			IF pclearpropnotinlist
			THEN
				sopenacc(pthis).accuserproplist := puserproplist;
			ELSE
				objuserproperty.concatproplist_(sopenacc(pthis).accuserproplist, puserproplist);
			END IF;
		END IF;
		s.say(cmethodname || '. end= ' || sopenacc(pthis).accuserproplist.count);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getuserproplist(pthis IN NUMBER) RETURN apitypes.typeuserproplist IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.GetUserPropList';
		vaccuserproplist apitypes.typeuserproplist := account.emptyuserattributeslist;
	BEGIN
		IF (testhandle(pthis, cmethodname) != 'N')
		THEN
			vaccuserproplist := sopenacc(pthis).accuserproplist;
		END IF;
	
		RETURN vaccuserproplist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE setisrollback
	(
		this  IN NUMBER
	   ,pisrb IN BOOLEAN
	) IS
	BEGIN
		IF testhandle(this, cpackagename || '.SetIsRollBack') != 'N'
		THEN
			sopenacc(this).isrb := pisrb;
		END IF;
	END;

	FUNCTION getisrollback(this IN NUMBER) RETURN BOOLEAN IS
	BEGIN
		IF testhandle(this, cpackagename || '.GetIsRollBack') = 'N'
		THEN
			RETURN NULL;
		END IF;
		RETURN sopenacc(this).isrb;
	END;

	FUNCTION starrest RETURN CHAR IS
	BEGIN
		RETURN stat_arrest;
	END;

	FUNCTION stclose RETURN CHAR IS
	BEGIN
		RETURN stat_close;
	END;

	FUNCTION stmark RETURN CHAR IS
	BEGIN
		RETURN stat_mark;
	END;

	FUNCTION stnosub RETURN CHAR IS
	BEGIN
		RETURN stat_nosub;
	END;

	FUNCTION stbook RETURN CHAR IS
	BEGIN
		RETURN stat_book;
	END;

	FUNCTION streport RETURN CHAR IS
	BEGIN
		RETURN stat_report;
	END;

	PROCEDURE unlockobject(paccountno IN typeaccountno) IS
		vindex NUMBER;
	BEGIN
	
		vindex := lockaccountstack.checkaccinstack(paccountno);
	
		IF vindex IS NOT NULL
		THEN
			object.release(object_name, paccountno);
			lockaccountstack.unlockacct(vindex);
		END IF;
	END;

	FUNCTION changeobjectmode
	(
		paccounthandle IN NUMBER
	   ,pnewmode       IN VARCHAR2
	   ,pforcedchange  IN BOOLEAN := FALSE
	) RETURN VARCHAR2 IS
	
		clocation CONSTANT VARCHAR2(32) := cpackagename || '.ChangeObjectMode';
		vprevmode         VARCHAR2(1) := NULL;
		vnewmode          VARCHAR2(1) := NULL;
		vprevforcedlock   BOOLEAN := NULL;
		vnotactualbalance BOOLEAN := NULL;
		vaccountrow       taccount%ROWTYPE;
		vfound            BOOLEAN;
		vlockoptions      options.typelockoptions := NULL;
		vdummy            NUMBER;
		vbranch           NUMBER := seance.getbranch();
	
		CURSOR curaccountrec(pno IN VARCHAR2) IS
			SELECT *
			FROM   taccount
			WHERE  branch = vbranch
			AND    accountno = pno
			FOR    UPDATE NOWAIT;
	
		PROCEDURE releasetablelock IS
		BEGIN
			ROLLBACK TO spchangeobjectmode;
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	
		PROCEDURE ehcleanup IS
			vsqlcode PLS_INTEGER := NULL;
		BEGIN
			vsqlcode := SQLCODE();
		
			releasetablelock();
			IF (vnewmode IS NOT NULL AND vprevmode IS NOT NULL AND vnotactualbalance IS NOT NULL AND
			   vprevforcedlock IS NOT NULL)
			THEN
				IF ((vnewmode = 'W' OR vnewmode = 'E' AND NOT vnotactualbalance) AND
				   (vprevmode = 'R' OR vprevmode = 'E' AND vnotactualbalance))
				THEN
					BEGIN
						object.release(object_name, getkeyvalue(paccounthandle));
					EXCEPTION
						WHEN OTHERS THEN
							NULL;
					END;
				END IF;
			
				IF ((vprevmode = 'W' OR vprevmode = 'E' AND NOT vnotactualbalance) AND
				   (vnewmode = 'R' OR vnewmode = 'E' AND vnotactualbalance))
				THEN
					BEGIN
						vlockoptions := getmultitasklockoptions();
						IF (object.capture(object_name
										  ,getkeyvalue(paccounthandle)
										  ,pattempt => vlockoptions.multitask_attempt
										  ,pattemptpause => vlockoptions.multitask_attemptpause) IS NULL)
						THEN
							NULL;
						END IF;
					EXCEPTION
						WHEN OTHERS THEN
							NULL;
					END;
				END IF;
			END IF;
		
			IF (vprevmode IS NOT NULL)
			THEN
			
				sopenacc(paccounthandle).openmode := vprevmode;
			END IF;
		
			IF (vprevforcedlock IS NOT NULL)
			THEN
				sopenacc(paccounthandle).accforcedlock := vprevforcedlock;
			END IF;
		
			IF (vsqlcode = -54)
			THEN
				err.seterror(err.account_busy
							,clocation
							,capturedobjectinfo(getkeyvalue(paccounthandle)));
			ELSE
				err.seterror(vsqlcode, clocation);
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				IF (vsqlcode IS NULL)
				THEN
					err.seterror(SQLCODE(), clocation);
				ELSE
					err.seterror(vsqlcode, clocation);
				END IF;
		END;
	
	BEGIN
	
		vnewmode := upper(pnewmode);
	
		vprevmode := testhandle(paccounthandle, clocation);
		s.say(cpackagename || '.ChangeObjectMode: pAccountHandle=' || paccounthandle ||
			  ', changing object mode, vPrevMode = ' || vprevmode
			 ,2);
		s.say(cpackagename || ': changing object mode, vNewMode = ' || vnewmode, 2);
	
		IF (err.geterrorcode() = 0)
		THEN
		
			vprevforcedlock := sopenacc(paccounthandle).accforcedlock;
		
			vnotactualbalance := sopenacc(paccounthandle).notactualbalance;
			s.say(cpackagename || ': changing object mode, vNotActualBalance = ' ||
				  service.iif(vnotactualbalance IS NULL
							 ,'null'
							 ,service.iif(vnotactualbalance, 'true', 'false'))
				 ,2);
			s.say(cpackagename || ': changing object mode, vPrevForcedLock = ' ||
				  service.iif(vprevforcedlock IS NULL
							 ,'null'
							 ,service.iif(vprevforcedlock, 'true', 'false'))
				 ,2);
		
			IF (vnewmode IS NULL OR vprevmode IS NULL OR vnotactualbalance IS NULL OR
			   vprevforcedlock IS NULL)
			THEN
				err.seterror(err.account_invalid_value, clocation);
			
			ELSIF ((vprevmode = 'R' OR
				  vprevmode = 'E' AND sopenacc(paccounthandle).notactualbalance) AND
				  (vnewmode = 'W' OR
				  vnewmode = 'E' AND NOT sopenacc(paccounthandle).notactualbalance))
			THEN
			
				vlockoptions := getmultitasklockoptions();
			
				vdummy := object.capture(object_name
										,getkeyvalue(paccounthandle)
										,pattempt => vlockoptions.multitask_attempt
										,pattemptpause => vlockoptions.multitask_attemptpause);
				IF err.geterrorcode() = 0
				THEN
				
					SAVEPOINT spchangeobjectmode;
					vaccountrow := NULL;
					vfound      := FALSE;
					FOR i IN curaccountrec(sopenacc(paccounthandle).accountno)
					LOOP
						vaccountrow := i;
						vfound      := TRUE;
						EXIT;
					END LOOP;
					releasetablelock();
				
					IF (vfound)
					THEN
						s.say(cpackagename || ': changing object mode, revision in base =' ||
							  vaccountrow.updaterevision
							 ,2);
						s.say(cpackagename || ': changing object mode, revision in memory =' || sopenacc(paccounthandle)
							  .updaterevision
							 ,2);
					
						IF (sopenacc(paccounthandle).updaterevision = vaccountrow.updaterevision OR
							vaccountrow.updaterevision IS NULL)
						THEN
							s.say(cpackagename || ': changing object mode, revision OK', 2);
						
							sopenacc(paccounthandle).openmode := vnewmode;
							IF (pforcedchange)
							THEN
								s.say(cpackagename || ': changing object mode, forcing lock', 2);
								sopenacc(paccounthandle).accforcedlock := TRUE;
							END IF;
						ELSE
							s.say(cpackagename || ': changing object mode, revision CHANGED!', 2);
							object.release(object_name, getkeyvalue(paccounthandle));
							err.seterror(err.account_revision_changed, clocation);
						END IF;
					ELSE
						s.say(cpackagename || ': changing object mode, account not found!', 2);
						setaccountnotfounderror(sopenacc(paccounthandle).accountno, clocation);
					END IF;
				ELSIF err.geterrorcode() = err.object_busy
				THEN
					s.say(cpackagename || ': changing object mode, account busy!', 2);
					err.seterror(err.account_busy
								,clocation
								,capturedobjectinfo(getkeyvalue(paccounthandle)));
				ELSE
					error.raisewhenerr();
				END IF;
			
			ELSIF ((vprevmode = 'W' OR
				  vprevmode = 'E' AND NOT sopenacc(paccounthandle).notactualbalance) AND
				  (vnewmode = 'R' OR vnewmode = 'E' AND sopenacc(paccounthandle).notactualbalance))
			THEN
				IF (NOT sopenacc(paccounthandle).accforcedlock OR pforcedchange)
				THEN
					object.release(object_name, getkeyvalue(paccounthandle));
				
					sopenacc(paccounthandle).openmode := vnewmode;
					IF (vprevforcedlock)
					THEN
						sopenacc(paccounthandle).accforcedlock := FALSE;
					END IF;
				END IF;
			ELSE
			
				sopenacc(paccounthandle).openmode := vnewmode;
				IF (pforcedchange)
				THEN
					sopenacc(paccounthandle).accforcedlock := TRUE;
				END IF;
			END IF;
		END IF;
	
		s.say(cpackagename || ': changing object mode, result: ' || err.gettext(), 2);
	
		RETURN vprevmode;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cpackagename || ': changing object mode, exception: ' || SQLERRM());
			ehcleanup();
		
			RETURN vprevmode;
	END;

	PROCEDURE changeobjectmode
	(
		paccounthandle IN NUMBER
	   ,pnewmode       IN VARCHAR2
	   ,pforcedchange  IN BOOLEAN := FALSE
	) IS
	BEGIN
		IF (changeobjectmode(paccounthandle, pnewmode, pforcedchange) IS NULL)
		THEN
			NULL;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE(), cpackagename || '.ChangeObjectMode');
	END;

	PROCEDURE writeobject(this IN NUMBER
						 ,
						  
						  plog                  IN BOOLEAN
						 ,plocalacct_statchange IN BOOLEAN
						 ,pactiontype           IN VARCHAR
						  
						  ) IS
		cmethodname CONSTANT VARCHAR2(32) := cpackagename || '.WriteObject';
		vprevopenmode        VARCHAR2(1) := NULL;
		vupdatedate          DATE;
		vupdatesysdate       DATE;
		vupdateclerkcode     NUMBER;
		vupdaterevision      taccount.updaterevision%TYPE;
		vcontext             err.typecontextrec;
		vrestorecontext      BOOLEAN;
		vpreviousaccountdata apitypes.typeaccountrecord;
		vnewaccountdata      apitypes.typeaccountrecord;
		vrule                NUMBER;
		vintrabankaccount    BOOLEAN;
		vuserattributeslist  apitypes.typeuserproplist;
		visrollback          BOOLEAN;
		vbranch              NUMBER;
	
		PROCEDURE convertapitotype(prec IN apitypes.typeaccountrecord) IS
		
			vacc typeaccount := NULL;
		BEGIN
		
			IF sopenacc.exists(this)
			THEN
				vacc := sopenacc(this);
			END IF;
		
			vacc.accountno        := prec.accountno;
			vacc.accounttype      := prec.accounttype;
			vacc.noplan           := prec.noplan;
			vacc.stat             := prec.stat;
			vacc.currencyno       := prec.currency;
			vacc.idclient         := prec.idclient;
			vacc.remain           := prec.remain;
			vacc.available        := prec.available;
			vacc.lowremain        := prec.lowremain;
			vacc.overdraft        := prec.crdlimit;
			vacc.debitreserve     := prec.debitreserve;
			vacc.creditreserve    := prec.creditreserve;
			vacc.branchpart       := prec.branchpart;
			vacc.createclerkcode  := prec.createclerk;
			vacc.createdate       := prec.createdate;
			vacc.updateclerkcode  := prec.updateclerk;
			vacc.updatedate       := prec.updatedate;
			vacc.updatesysdate    := prec.updatesysdate;
			vacc.acct_typ         := prec.acct_typ;
			vacc.acct_stat        := prec.acct_stat;
			vacc.closedate        := prec.closedate;
			vacc.remark           := prec.remark;
			vacc.limitgrp         := prec.limitgrpid;
			vacc.remainupdatedate := prec.remainupdatedate;
			vacc.finprofile       := prec.finprofile;
		
			vacc.internallimitsgroupsysid := prec.internallimitsgroupsysid;
			vacc.countergrp               := prec.countergrpid;
			vacc.permissibleexcesstype    := prec.permissibleexcesstype;
			vacc.permissibleexcess        := prec.permissibleexcess;
		
			vacc.protectedamount := prec.protectedamount;
			vacc.extaccountno    := prec.extaccountno;
		
			IF vacc.objectuid IS NULL
			THEN
				vacc.objectuid := getuid(prec.accountno);
			END IF;
		
			sopenacc(this) := vacc;
		
		END;
	
	BEGIN
		s.say('starting [' || cmethodname || '] ' || sopenacc(this).accountno, 2);
	
		vbranch := seance.getbranch();
	
		vprevopenmode := changeobjectmode(this, 'W');
		IF (err.geterrorcode() = 0)
		THEN
		
			checklimitgrpid(sopenacc(this).limitgrp);
			IF (err.geterrorcode() = 0)
			THEN
			
				checkcountergrpid(sopenacc(this).countergrp);
				IF (err.geterrorcode() = 0)
				THEN
				
					checkinternallimitsgroupsysid(sopenacc(this).internallimitsgroupsysid);
					IF (err.geterrorcode() = 0)
					THEN
					
						IF (testhandle(this, cmethodname) = 'W' OR
						   (testhandle(this, cmethodname) = 'E' AND
						   NOT sopenacc(this).notactualbalance))
						THEN
							vupdatedate      := sopenacc(this).updatedate;
							vupdatesysdate   := sopenacc(this).updatesysdate;
							vupdateclerkcode := sopenacc(this).updateclerkcode;
							vupdaterevision  := sopenacc(this).updaterevision;
						
							vpreviousaccountdata := getaccountrecord(sopenacc(this).accountno);
						
							vnewaccountdata := getcurrentaccountrecord(this);
						
							s.say(cmethodname || '.sMode = ' || smode);
							vintrabankaccount := planaccount.gettype(vnewaccountdata.noplan) =
												 planaccount.type_nonconsolidated;
						
							vuserattributeslist := getuserproplist(this);
							s.say(cmethodname || '.vUserAttributesList=' ||
								  vuserattributeslist.count);
							visrollback := getisrollback(this);
						
							runupdateblock(vnewaccountdata
										  ,vuserattributeslist
										  ,client.getclienttype(vnewaccountdata.idclient)
										  ,
										   
										   pdialogattributescontext => (smode = cdm_dialog)
										  ,pintrabankaccount        => vintrabankaccount
										  ,ptypemode                => accountblocks.cmtmodify
										  ,pisrollback              => visrollback);
						
							setuserproplist(this, vuserattributeslist, TRUE);
						
							vrule := nvl(sqlblockoptions.getparameter(sqlblockoptions.cobj_account
																	 ,sqlblockoptions.cblock_save)
										,sqlblockoptions.crule_always);
							s.say(cmethodname || ': vRule=' || vrule || ' sMode=' || smode);
							IF smode = cdm_dialog
							   OR vrule = sqlblockoptions.crule_always
							THEN
							
								setcurrent(vnewaccountdata);
								setcurrentuserprop(vuserattributeslist);
								runcontrolblock(vnewaccountdata.accountno
											   ,client.getclienttype(vnewaccountdata.idclient)
											   ,vintrabankaccount
											   ,accountblocks.cbtclose
											   ,pdialogattributescontext => (smode = cdm_dialog)
											   ,ptypemode => accountblocks.cmtmodify);
							END IF;
						
							convertapitotype(vnewaccountdata);
						
							IF (err.geterrorcode() = 0)
							THEN
							
								SAVEPOINT accountwriteobject;
								BEGIN
									sopenacc(this).updatedate := greatest(seance.getoperdate()
																		 ,sopenacc(this).updatedate);
									sopenacc(this).updatesysdate := greatest(SYSDATE()
																			,sopenacc(this)
																			 .updatesysdate);
									sopenacc(this).updateclerkcode := clerk.getcode();
									sopenacc(this).updaterevision := getnewupdaterevision();
								
									UPDATE taccount
									SET    accounttype              = sopenacc(this).accounttype
										  ,currencyno               = sopenacc(this).currencyno
										  ,idclient                 = sopenacc(this).idclient
										  ,remain                   = sopenacc(this).remain
										  ,available                = sopenacc(this).available
										  ,overdraft                = sopenacc(this).overdraft
										  ,noplan                   = sopenacc(this).noplan
										  ,updatedate               = sopenacc(this).updatedate
										  ,updateclerkcode          = sopenacc(this).updateclerkcode
										  ,updatesysdate            = sopenacc(this).updatesysdate
										  ,stat                     = sopenacc(this).stat
										  ,acct_typ                 = sopenacc(this).acct_typ
										  ,acct_stat                = sopenacc(this).acct_stat
										  ,closedate                = sopenacc(this).closedate
										  ,remark                   = sopenacc(this).remark
										  ,debitreserve             = sopenacc(this).debitreserve
										  ,creditreserve            = sopenacc(this).creditreserve
										  ,lowremain                = sopenacc(this).lowremain
										  ,branchpart               = sopenacc(this).branchpart
										  ,limitgrpid               = sopenacc(this).limitgrp
										  ,createdate               = sopenacc(this).createdate
										  ,updaterevision           = sopenacc(this).updaterevision
										  ,remainupdatedate         = sopenacc(this)
																	  .remainupdatedate
										  ,finprofile               = sopenacc(this).finprofile
										  ,internallimitsgroupsysid = sopenacc(this)
																	  .internallimitsgroupsysid
										  ,countergrpid             = sopenacc(this).countergrp
										  ,permissibleexcesstype    = sopenacc(this)
																	  .permissibleexcesstype
										  ,permissibleexcess        = sopenacc(this)
																	  .permissibleexcess
										  ,protectedamount          = sopenacc(this).protectedamount
									
									WHERE  branch = vbranch
									AND    accountno = sopenacc(this).accountno
									AND    (updaterevision IS NULL OR
										  updaterevision = vupdaterevision);
								
									IF (nvl(SQL%ROWCOUNT, 0) <= 0)
									THEN
										IF (accountexist(sopenacc(this).accountno))
										THEN
											err.seterror(err.account_revision_changed, cmethodname);
										ELSE
											setaccountnotfounderror(sopenacc(this).accountno
																   ,cmethodname);
										END IF;
									END IF;
								
									IF acc2acc.setoldaccountno(sopenacc(this).accountno
															  ,sopenacc(this).extaccountno) != 0
									THEN
										err.seterror(err.geterrorcode, cmethodname, err.geterror);
									END IF;
								
								EXCEPTION
									WHEN OTHERS THEN
										err.seterror(SQLCODE(), cmethodname);
								END;
							
							END IF;
						
							IF (err.geterrorcode() != 0)
							THEN
								s.say(cpackagename || '.WriteObject Err: ' || err.geterrorcode());
								BEGIN
									ROLLBACK TO accountwriteobject;
								
									sopenacc(this).updatedate := vupdatedate;
									sopenacc(this).updatesysdate := vupdatesysdate;
									sopenacc(this).updateclerkcode := vupdateclerkcode;
									sopenacc(this).updaterevision := vupdaterevision;
								EXCEPTION
									WHEN OTHERS THEN
										NULL;
								END;
							
							ELSE
								IF (nvl(vpreviousaccountdata.crdlimit, 0) !=
								   nvl(sopenacc(this).overdraft, 0))
								THEN
									s.say('WriteObject -> OverdraftChange', 2);
									accounteventlog.registerevent(sopenacc                          (this)
																  .accountno
																 ,accounteventlog.cetoverdraftchange
																 ,sopenacc                          (this)
																  .overdraft
																 ,vpreviousaccountdata.crdlimit
																 ,sopenacc                          (this)
																  .overdraft_comment);
								END IF;
								IF (nvl(vpreviousaccountdata.debitreserve, 0) !=
								   nvl(sopenacc(this).debitreserve, 0))
								THEN
									s.say('WriteObject -> DebitReserveChange', 2);
									accounteventlog.registerevent(sopenacc                             (this)
																  .accountno
																 ,accounteventlog.cetdebitreservechange
																 ,sopenacc                             (this)
																  .debitreserve
																 ,vpreviousaccountdata.debitreserve
																 ,sopenacc                             (this)
																  .debitreserve_comment);
								END IF;
								IF (nvl(vpreviousaccountdata.creditreserve, 0) !=
								   nvl(sopenacc(this).creditreserve, 0))
								THEN
									s.say('WriteObject -> CreditReserveChange', 2);
									accounteventlog.registerevent(sopenacc                              (this)
																  .accountno
																 ,accounteventlog.cetcreditreservechange
																 ,sopenacc                              (this)
																  .creditreserve
																 ,vpreviousaccountdata.creditreserve
																 ,sopenacc                              (this)
																  .creditreserve_comment);
								END IF;
							
								IF (nvl(vpreviousaccountdata.limitgrpid, -1) !=
								   nvl(sopenacc(this).limitgrp, -1))
								THEN
									s.say('WriteObject -> FOLimitGroupChange', 2);
									accounteventlog.registerevent(sopenacc                             (this)
																  .accountno
																 ,accounteventlog.cetfolimitgroupchange
																 ,sopenacc                             (this)
																  .limitgrp
																 ,vpreviousaccountdata.limitgrpid
																 ,sopenacc                             (this)
																  .limitgrp_comment);
								END IF;
							
								IF (nvl(vpreviousaccountdata.countergrpid, -1) !=
								   nvl(sopenacc(this).countergrp, -1))
								THEN
									s.say('WriteObject -> FOCounterGroupChange', 2);
									accounteventlog.registerevent(sopenacc                               (this)
																  .accountno
																 ,accounteventlog.cetfocountergroupchange
																 ,sopenacc                               (this)
																  .countergrp
																 ,vpreviousaccountdata.countergrpid
																 ,sopenacc                               (this)
																  .countergrp_comment);
								END IF;
							
								IF (nvl(vpreviousaccountdata.internallimitsgroupsysid, -1) !=
								   nvl(sopenacc(this).internallimitsgroupsysid, -1))
								THEN
									s.say('WriteObject -> cetBOLimitGroupChange', 2);
									accounteventlog.registerevent(sopenacc                                     (this)
																  .accountno
																 ,accounteventlog.cetbolimitgroupchange
																 ,sopenacc                                     (this)
																  .internallimitsgroupsysid
																 ,vpreviousaccountdata.internallimitsgroupsysid
																 ,sopenacc                                     (this)
																  .intlimitgrp_comment);
								END IF;
							
								IF (nvl(vpreviousaccountdata.lowremain, 0) !=
								   nvl(sopenacc(this).lowremain, 0))
								THEN
									s.say('WriteObject -> LowRemainChange', 2);
									accounteventlog.registerevent(sopenacc                          (this)
																  .accountno
																 ,accounteventlog.cetlowremainchange
																 ,sopenacc                          (this)
																  .lowremain
																 ,vpreviousaccountdata.lowremain
																 ,sopenacc                          (this)
																  .lowremain_comment);
								END IF;
							
								IF (nvl(vpreviousaccountdata.finprofile, 0) !=
								   nvl(sopenacc(this).finprofile, 0))
								THEN
									s.say('WriteObject -> FinProfileChange', 2);
									accounteventlog.registerevent(sopenacc                           (this)
																  .accountno
																 ,accounteventlog.cetfinprofilechange
																 ,sopenacc                           (this)
																  .finprofile
																 ,vpreviousaccountdata.finprofile
																 ,sopenacc                           (this)
																  .finprofile_comment);
								END IF;
							
								IF (nvl(vpreviousaccountdata.acct_typ, 0) !=
								   nvl(sopenacc(this).acct_typ, 0))
								THEN
									s.say('WriteObject -> ACCT_TYPChange', 2);
									accounteventlog.registerevent(sopenacc                      (this)
																  .accountno
																 ,accounteventlog.cetfotypchange
																 ,sopenacc                      (this)
																  .acct_typ
																 ,vpreviousaccountdata.acct_typ
																 ,sopenacc                      (this)
																  .acct_typ_comment);
								END IF;
							
								IF (nvl(vpreviousaccountdata.acct_stat, 0) !=
								   nvl(sopenacc(this).acct_stat, 0))
								THEN
									s.say('WriteObject -> ACCT_STATChange', 2);
									accounteventlog.registerevent(sopenacc                       (this)
																  .accountno
																 ,accounteventlog.cetfostatchange
																 ,sopenacc                       (this)
																  .acct_stat
																 ,vpreviousaccountdata.acct_stat
																 ,sopenacc                       (this)
																  .acct_stat_comment);
								END IF;
							
								IF (nvl(vpreviousaccountdata.stat, 0) !=
								   nvl(sopenacc(this).stat, 0))
								THEN
									s.say('WriteObject -> StatChange', 2);
									accounteventlog.registerevent(sopenacc(this).accountno
																 ,accounteventlog.cetbostatchange
																 ,getaccstatvalue(sopenacc(this).stat)
																 ,getaccstatvalue(vpreviousaccountdata.stat)
																 ,sopenacc(this).stat_comment);
								END IF;
							
								IF (nvl(vpreviousaccountdata.permissibleexcesstype, 0) !=
								   nvl(sopenacc(this).permissibleexcesstype, 0))
								THEN
									s.say('WriteObject -> PermissibleExcessType', 2);
									accounteventlog.registerevent(sopenacc                                  (this)
																  .accountno
																 ,accounteventlog.cetpermissibleexcess
																 ,sopenacc                                  (this)
																  .permissibleexcesstype
																 ,vpreviousaccountdata.permissibleexcesstype);
								END IF;
								IF (nvl(vpreviousaccountdata.permissibleexcess, 0) !=
								   nvl(sopenacc(this).permissibleexcess, 0))
								THEN
									s.say('WriteObject -> PermissibleExcess', 2);
									accounteventlog.registerevent(sopenacc                              (this)
																  .accountno
																 ,accounteventlog.cetpermissibleexcess
																 ,sopenacc                              (this)
																  .permissibleexcess
																 ,vpreviousaccountdata.permissibleexcess);
								END IF;
							
								IF (nvl(vpreviousaccountdata.protectedamount, 0) !=
								   nvl(sopenacc(this).protectedamount, 0))
								THEN
									s.say('WriteObject -> ProtectedAmount', 2);
									accounteventlog.registerevent(sopenacc                            (this)
																  .accountno
																 ,accounteventlog.cetprotectedamount
																 ,sopenacc                            (this)
																  .protectedamount
																 ,vpreviousaccountdata.protectedamount);
								END IF;
							
								IF plog
								THEN
									IF pactiontype = 'CLOSE'
									THEN
										account.logclosure(sopenacc(this).accountno);
									ELSIF pactiontype = 'CLOSECANCEL'
									THEN
										account.logclosurecancelling(sopenacc(this).accountno);
									ELSIF pactiontype = 'UPDATE'
										  OR pactiontype IS NULL
									THEN
									
										account.logattributeschange(vpreviousaccountdata
																   ,vnewaccountdata
																   ,NOT plocalacct_statchange);
									END IF;
								END IF;
							
								s.say(cmethodname || ': Save vUserAttributesList=' || sopenacc(this)
									  .accuserproplist.count);
								saveuserattributeslist_(vnewaccountdata.accountno
													   ,sopenacc                 (this)
														.accuserproplist
													   ,pclearpropnotinlist       => TRUE);
							
							END IF;
						
						ELSIF testhandle(this, cmethodname) = 'E'
							  AND sopenacc(this).notactualbalance
						THEN
							s.say(sopenacc(this).updatedate, 2);
							s.say(sopenacc(this).updateclerkcode, 2);
							s.say(sopenacc(this).updatesysdate, 2);
							s.say(sopenacc(this).available, 2);
							s.say(sopenacc(this).overdraft, 2);
							s.say(sopenacc(this).stat, 2);
							s.say(sopenacc(this).acct_stat, 2);
							s.say(sopenacc(this).closedate, 2);
							s.say(sopenacc(this).remark, 2);
							s.say(sopenacc(this).debitreserve, 2);
							s.say(sopenacc(this).creditreserve, 2);
							s.say(sopenacc(this).lowremain, 2);
							s.say(sopenacc(this).branchpart, 2);
							s.say(sopenacc(this).limitgrp, 2);
							s.say(sopenacc(this).countergrp, 2);
						
							s.say(sopenacc(this).internallimitsgroupsysid, 2);
						
							s.say(sopenacc(this).remainupdatedate, 2);
							s.say(sopenacc(this).finprofile, 2);
							s.say(sopenacc(this).acct_typ, 2);
							s.say(sopenacc(this).permissibleexcesstype, 2);
							s.say(sopenacc(this).permissibleexcess, 2);
							s.say(sopenacc(this).protectedamount, 2);
							IF sopenacc(this).updatedate IS NOT NULL
								OR sopenacc(this).updateclerkcode IS NOT NULL
								OR sopenacc(this).updatesysdate IS NOT NULL
								OR sopenacc(this).available IS NOT NULL
								OR sopenacc(this).overdraft IS NOT NULL
								OR sopenacc(this).stat IS NOT NULL
								OR sopenacc(this).acct_stat IS NOT NULL
								OR sopenacc(this).closedate IS NOT NULL
								OR sopenacc(this).remark IS NOT NULL
								OR sopenacc(this).debitreserve IS NOT NULL
								OR sopenacc(this).creditreserve IS NOT NULL
								OR sopenacc(this).lowremain IS NOT NULL
								OR sopenacc(this).branchpart IS NOT NULL
								OR sopenacc(this).limitgrp IS NOT NULL
								OR sopenacc(this).countergrp IS NOT NULL
								OR sopenacc(this).internallimitsgroupsysid IS NOT NULL
								OR sopenacc(this).remainupdatedate IS NOT NULL
								OR sopenacc(this).finprofile IS NOT NULL
								OR sopenacc(this).acct_typ IS NOT NULL
							THEN
								err.seterror(err.account_veto
											,cmethodname || ' [attrs was changed]');
							END IF;
						
						ELSE
							err.seterror(err.account_veto, cmethodname);
						END IF;
					
						IF (err.geterrorcode() = 0)
						THEN
							vrestorecontext := FALSE;
						ELSE
							vcontext        := err.getcontext();
							vrestorecontext := TRUE;
						END IF;
						changeobjectmode(this, vprevopenmode);
					
						IF (vrestorecontext)
						THEN
							err.putcontext(vcontext);
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	
		s.say('finished [' || cmethodname || '] ' || sopenacc(this).accountno || ', result: ' ||
			  err.gettext()
			 ,2);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname || ' [' || sopenacc(this).accountno || ']');
			vcontext := err.getcontext();
			IF (vprevopenmode IS NOT NULL)
			THEN
				BEGIN
					err.seterror(0, NULL);
					changeobjectmode(this, vprevopenmode);
				EXCEPTION
					WHEN OTHERS THEN
						s.err('Error while changing account mode: ' || SQLERRM());
				END;
			END IF;
			error.showstack(pclear => TRUE);
			err.putcontext(vcontext);
	END;

	FUNCTION getflagnotactualbalance(paccountno IN typeaccountno) RETURN BOOLEAN IS
		vnoplan NUMBER;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		SELECT noplan
		INTO   vnoplan
		FROM   taccount
		WHERE  branch = vbranch
		AND    accountno = paccountno;
		RETURN planaccount.getflagnotactualbalance(vnoplan);
	EXCEPTION
		WHEN no_data_found THEN
			setaccountnotfounderror(paccountno, 'GetFlagNotActualBalance');
			RETURN NULL;
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetFlagNotActualBalance');
			RAISE;
	END;

	FUNCTION getstatementlist(paccountno IN typeaccountno) RETURN apitypes.typestatementlist IS
	BEGIN
		RETURN statementrt.getaccountstatementlist(paccountno);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetStatementList');
			RAISE;
	END;

	FUNCTION getcurrentdlgaccountrecord RETURN apitypes.typeaccountrecord IS
	BEGIN
		RETURN accountcard.getdialogattraccountrecord();
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetCurrentDlgAccountRecord');
			RAISE;
	END;

	PROCEDURE getmaskedfieldslist(psubobject IN VARCHAR2) IS
	BEGIN
		a4mlog.addmaskedfield('PAN', s.cmask_pan);
		a4mlog.addmaskedfield('MBR', s.cmask_str);
		objuserproperty.fillmaskedfieldslistforlog(object_name, psubobject);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetMaskedFieldsList');
			RAISE;
	END;

	PROCEDURE getaccountuserpropertyobjs
	(
		paccountno                IN typeaccountno
	   ,oobjuserpropertyobject    IN OUT VARCHAR2
	   ,oobjuserpropertysubobject IN OUT VARCHAR2
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.GetAccountUserPropertyObjs';
		vaccount         apitypes.typeaccountrecord;
		vclienttype      client.tclienttype;
		vplanaccounttype NUMBER;
	BEGIN
		err.seterror(0, NULL, NULL);
		vaccount := account.getaccountrecord(paccountno);
		error.raisewhenerr();
	
		vclienttype := client.getclienttype(vaccount.idclient);
		error.raisewhenerr();
	
		IF (vclienttype = client.ct_persone)
		THEN
			oobjuserpropertyobject    := account.account_private;
			oobjuserpropertysubobject := NULL;
		ELSIF (vclienttype = client.ct_company)
		THEN
			vplanaccounttype := planaccount.gettype(vaccount.noplan);
			error.raisewhenerr();
		
			IF (vplanaccounttype = planaccount.type_consolidated)
			THEN
				oobjuserpropertyobject    := account.account_company;
				oobjuserpropertysubobject := NULL;
			ELSE
				oobjuserpropertyobject    := account.account_company;
				oobjuserpropertysubobject := account.account_company_bank;
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getuserattributeslist(paccountno IN typeaccountno) RETURN apitypes.typeuserproplist IS
	
		vobjuserpropertyobject    VARCHAR2(64);
		vobjuserpropertysubobject VARCHAR2(256);
	
	BEGIN
		getaccountuserpropertyobjs(paccountno, vobjuserpropertyobject, vobjuserpropertysubobject);
	
		RETURN objuserproperty.getrecord(vobjuserpropertyobject
										,getobjectuid(paccountno)
										,vobjuserpropertysubobject);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetUserAttributesList');
			RAISE;
	END;

	FUNCTION getuserattributerecord
	(
		paccountno IN typeaccountno
	   ,pfieldname IN VARCHAR2
	) RETURN apitypes.typeuserproprecord IS
	
		vobjuserpropertyobject    VARCHAR2(64);
		vobjuserpropertysubobject VARCHAR2(256);
	BEGIN
		getaccountuserpropertyobjs(paccountno, vobjuserpropertyobject, vobjuserpropertysubobject);
	
		RETURN objuserproperty.getfield(vobjuserpropertyobject
									   ,getobjectuid(paccountno)
									   ,pfieldname
									   ,vobjuserpropertysubobject);
	
	EXCEPTION
		WHEN OTHERS THEN
		
			error.save(cpackagename || '.GetUserAttributeRecord');
		
			RAISE;
	END;

	PROCEDURE saveuserattributeslist
	(
		paccountno          IN typeaccountno
	   ,plist               IN apitypes.typeuserproplist
	   ,pclearpropnotinlist IN BOOLEAN := FALSE
	) IS
	
		vaccounthandle NUMBER;
	BEGIN
		s.say(cpackagename || '.SaveUserAttributesList');
		vaccounthandle := account.newobject(paccountno, 'W');
		error.raisewhenerr();
		setuserproplist(vaccounthandle, plist, pclearpropnotinlist);
		account.writeobject(vaccounthandle);
		account.freeobject(vaccounthandle);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SaveUserAttributesList');
			account.freeobject(vaccounthandle);
			RAISE;
	END;

	PROCEDURE saveuserattributeslist_
	(
		paccountno          IN typeaccountno
	   ,plist               IN apitypes.typeuserproplist
	   ,pclearpropnotinlist IN BOOLEAN := FALSE
	) IS
	
		vobjuserpropertyobject    VARCHAR2(64);
		vobjuserpropertysubobject VARCHAR2(256);
	BEGIN
		getaccountuserpropertyobjs(paccountno, vobjuserpropertyobject, vobjuserpropertysubobject);
	
		s.say('SaveUserAttributesList_: pList=' || plist.count);
		objuserproperty.saverecord(vobjuserpropertyobject
								  ,getobjectuid(paccountno, FALSE)
								  ,plist
								  ,pclearpropnotinlist
								  ,vobjuserpropertysubobject
								  ,object_type
								  ,TRIM(paccountno)
								  ,plog_clientid => getidclientbyaccno(paccountno));
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SaveUserAttributesList_');
			RAISE;
	END;

	PROCEDURE updateaccountsplannobytype
	(
		paccounttype IN NUMBER
	   ,pplanno      IN NUMBER
	) IS
		voldcurrencyid  NUMBER;
		vnewcurrencyid  NUMBER;
		vbranch         NUMBER;
		vupdaterevision NUMBER;
		vaccountno      VARCHAR2(20);
	
		FUNCTION getmethodname RETURN VARCHAR2 IS
		BEGIN
			RETURN cpackagename || '.UpdateAccountsPlanNoByType';
		EXCEPTION
			WHEN OTHERS THEN
				RETURN NULL;
		END;
	
	BEGIN
		IF accounttype.getaccmap(paccounttype) IS NOT NULL
		THEN
			RETURN;
		END IF;
	
		SAVEPOINT sp_account_updateplannobytype;
	
		err.seterror(0, getmethodname());
	
		voldcurrencyid := planaccount.getcurrency(accounttype.getnoplan(paccounttype));
		error.raisewhenerr();
	
		vnewcurrencyid := planaccount.getcurrency(pplanno);
		error.raisewhenerr();
	
		IF (vnewcurrencyid != voldcurrencyid)
		THEN
			error.raiseerror(err.mb_error_change_acc_curr);
		END IF;
	
		vaccountno      := NULL;
		vbranch         := seance.getbranch();
		vupdaterevision := getnewupdaterevision();
		FOR a IN (SELECT accountno
				  FROM   taccount
				  WHERE  branch = vbranch
				  AND    accounttype = paccounttype)
		LOOP
			IF (lockobject(a.accountno, 'W') = 0)
			THEN
				vaccountno := a.accountno;
			END IF;
			error.raisewhenerr();
		
			UPDATE taccount
			SET    noplan         = pplanno
				  ,updaterevision = vupdaterevision
			WHERE  branch = vbranch
			AND    accountno = vaccountno;
		
			unlockobject(a.accountno);
			vaccountno := NULL;
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(getmethodname());
			BEGIN
				ROLLBACK TO sp_account_updateplannobytype;
			EXCEPTION
				WHEN OTHERS THEN
					s.say('Warning! Error while rolling back to SP_Account_UpdatePlanNoByType: ' ||
						  SQLERRM()
						 ,2);
			END;
			IF (vaccountno IS NOT NULL)
			THEN
				BEGIN
					unlockobject(vaccountno);
				EXCEPTION
					WHEN OTHERS THEN
						s.say('Warning! Error while unlocking account ' || vaccountno || ': ' ||
							  SQLERRM()
							 ,2);
				END;
			END IF;
			RAISE;
	END;

	FUNCTION getinternalaccountnumber(pexternalaccountnumber IN VARCHAR2) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.GetInternalAccountNumber';
		vinternalaccountnumber typeaccountno;
		verrorcode             NUMBER;
		vaplanaccountno        types.arrnum;
	BEGIN
		err.seterror(0, cmethodname);
		vinternalaccountnumber := acc2acc.getnewaccountno(pexternalaccountnumber);
		verrorcode             := err.geterrorcode();
		IF (verrorcode = err.account_not_found)
		THEN
			vaplanaccountno := planaccount.getnobyexternal(pexternalaccountnumber);
			IF (vaplanaccountno.count() = 0)
			THEN
				error.raiseerror(err.account_not_found);
			ELSIF (vaplanaccountno.count() > 1)
			THEN
				error.raiseerror(err.ue_other
								,'There are several accounts with external No ' ||
								 pexternalaccountnumber);
			END IF;
			err.seterror(0, cmethodname);
			vinternalaccountnumber := planaccount.getinternal(vaplanaccountno(1));
			error.raisewhenerr();
		ELSE
			error.raisewhenerr();
		END IF;
		RETURN vinternalaccountnumber;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getexternalaccountnumber(pinternalaccountnumber IN VARCHAR2) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.GetExternalAccountNumber';
		vplanaccountno         NUMBER;
		vplanaccounttype       NUMBER;
		vexternalaccountnumber VARCHAR2(64);
	BEGIN
		err.seterror(0, cmethodname);
		vplanaccountno := getaccountrecord(pinternalaccountnumber).noplan;
		error.raisewhenerr();
	
		vplanaccounttype := planaccount.gettype(vplanaccountno);
		error.raisewhenerr();
	
		IF (vplanaccounttype = planaccount.type_nonconsolidated)
		THEN
			vexternalaccountnumber := planaccount.getexternal(vplanaccountno);
		ELSE
			vexternalaccountnumber := acc2acc.getoldaccountno(pinternalaccountnumber);
		END IF;
		error.raisewhenerr();
	
		RETURN vexternalaccountnumber;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE checkbranchoptionname(poptionname IN typebranchoptionname) IS
	BEGIN
		IF (poptionname NOT IN (cbonallowaccswopencardsclosing))
		THEN
			error.raiseerror(err.ue_value_incorrect, 'Unknown parameter: ' || poptionname);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.CheckBranchOptionName');
			RAISE;
	END;

	FUNCTION getbranchoption(poptionname IN typebranchoptionname) RETURN BOOLEAN IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.GetBranchOption[boolean]';
		voptionvalue NUMBER;
	BEGIN
		err.seterror(0, cmethodname);
	
		checkbranchoptionname(poptionname);
	
		voptionvalue := datamember.getnumber(object_type, 0, poptionname);
		error.raisewhenerr();
	
		IF (voptionvalue > 0)
		THEN
			RETURN TRUE;
		END IF;
	
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE setbranchoption
	(
		poptionname  IN typebranchoptionname
	   ,poptionvalue IN BOOLEAN
	) IS
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.SetBranchOption[boolean]';
		voptionvalue NUMBER;
		vresult      NUMBER;
	BEGIN
		err.seterror(0, cmethodname);
	
		checkbranchoptionname(poptionname);
	
		IF (poptionvalue)
		THEN
			voptionvalue := 1;
		ELSE
			voptionvalue := 0;
		END IF;
	
		vresult := datamember.setnumber(object_type
									   ,0
									   ,poptionname
									   ,voptionvalue
									   ,'Indicator of closing account with linked opened cards');
		error.raisewhenerr();
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getuid(paccountno IN typeaccountno)
	
	 RETURN NUMBER IS
	
	BEGIN
		RETURN getobjectuid(paccountno);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetUId(pAccountNo)');
			RAISE;
	END;

	FUNCTION getuid(pthis IN NUMBER)
	
	 RETURN NUMBER IS
	
		cmethodname CONSTANT VARCHAR2(64) := cpackagename || '.GetUId(pThis)';
		vobjectuid taccount.objectuid%TYPE;
	BEGIN
		IF (testhandle(pthis, cmethodname) != 'N')
		THEN
			vobjectuid := sopenacc(pthis).objectuid;
		ELSE
			vobjectuid := NULL;
		END IF;
		RETURN vobjectuid;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getguid(pthis IN NUMBER) RETURN types.guid IS
	BEGIN
		RETURN objectuid.getguid(getuid(pthis));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetGUId(pThis)');
			RAISE;
	END;

	FUNCTION getguid(paccountno IN typeaccountno) RETURN types.guid IS
	BEGIN
		RETURN objectuid.getguid(getuid(paccountno));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetGUId(pAccountNo)');
			RAISE;
	END;

	PROCEDURE logcreation(paccountno IN typeaccountno) IS
	
		vidclient   NUMBER := NULL;
		vislogowner BOOLEAN := FALSE;
	
		vplno NUMBER;
	BEGIN
	
		vidclient := getidclientbyaccno(paccountno);
		IF (vidclient IS NOT NULL)
		   AND isclientpersone(vidclient)
		THEN
			vislogowner := TRUE;
		END IF;
	
		vplno := a4mlog.getfreeplistno();
		a4mlog.cleanplist(vplno);
		a4mlog.addparamrec('ExistsInPC'
						  ,nvl(to_char(getexistsinpc(paccountno)), 'null')
						  ,plistnum => vplno);
	
		a4mlog.logobject(object_type
						,paccountno
						,'Create acct'
						,a4mlog.act_add
						,pparamlist     => a4mlog.putparamlist(vplno)
						,powner         => htools.iif(vislogowner, vidclient, NULL));
		a4mlog.cleanplist(vplno);
	EXCEPTION
		WHEN OTHERS THEN
			setexceptionerror(cpackagename || '.LogCreation', paccountno);
	END;

	PROCEDURE logdeletion
	(
		paccountno IN typeaccountno
	   ,pwithowner IN BOOLEAN := FALSE
	   ,powner     NUMBER := NULL
	) IS
	BEGIN
	
		IF (pwithowner)
		THEN
			a4mlog.logobject(object_type
							,paccountno
							,'Delete account with information on customer'
							,a4mlog.act_del
							,powner);
		ELSE
			a4mlog.logobject(object_type, paccountno, 'Delete account', a4mlog.act_del, powner);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			setexceptionerror(cpackagename || '.LogDeletion', paccountno);
	END;

	PROCEDURE logbookissuing(paccountno IN typeaccountno) IS
	BEGIN
	
		a4mlog.logobject(object_type
						,paccountno
						,'Issue passbook'
						,a4mlog.act_change
						,powner => getidclientacc(paccountno));
	EXCEPTION
		WHEN OTHERS THEN
			setexceptionerror(cpackagename || '.LogBookIssuing', paccountno);
	END;

	PROCEDURE logattributeschange
	(
		ppreviousaccountdata  IN apitypes.typeaccountrecord
	   ,pnewaccountdata       IN apitypes.typeaccountrecord
	   ,plocalacct_statchange IN BOOLEAN := FALSE
	) IS
		vbit          NUMBER;
		vloginfo      VARCHAR2(4096) := NULL;
		vparamslogged BOOLEAN := FALSE;
	
		PROCEDURE addtologstring(pstring IN VARCHAR2) IS
		BEGIN
			vloginfo := vloginfo || pstring;
		EXCEPTION
			WHEN value_error THEN
				NULL;
		END;
	
		PROCEDURE addparamtologstring
		(
			pparamdescription   IN VARCHAR2
		   ,pparampreviousvalue IN VARCHAR2
		   ,pparamnewvalue      IN VARCHAR2
		) IS
		BEGIN
			addtologstring(CASE WHEN vparamslogged THEN ',' ELSE NULL
						   END || ' ' || pparamdescription || ' (' || pparampreviousvalue || '->' ||
						   pparamnewvalue || ')');
			IF (NOT vparamslogged)
			THEN
				vparamslogged := TRUE;
			END IF;
		EXCEPTION
			WHEN value_error THEN
				NULL;
		END;
	
		FUNCTION logparam
		(
			pparamname          IN VARCHAR2
		   ,pparamdescription   IN VARCHAR2
		   ,pparampreviousvalue IN NUMBER
		   ,pparamnewvalue      IN NUMBER
		) RETURN BOOLEAN IS
		BEGIN
			IF (pparamnewvalue != pparampreviousvalue OR
			   pparamnewvalue IS NULL AND pparampreviousvalue IS NOT NULL OR
			   pparamnewvalue IS NOT NULL AND pparampreviousvalue IS NULL)
			THEN
				addparamtologstring(pparamdescription
								   ,to_char(pparampreviousvalue)
								   ,to_char(pparamnewvalue));
				a4mlog.addparamrec(pparamname, pparampreviousvalue, pparamnewvalue);
				RETURN TRUE;
			END IF;
			RETURN FALSE;
		END;
	
		PROCEDURE logparam
		(
			pparamname          IN VARCHAR2
		   ,pparamdescription   IN VARCHAR2
		   ,pparampreviousvalue IN NUMBER
		   ,pparamnewvalue      IN NUMBER
		) IS
		BEGIN
			IF (logparam(pparamname, pparamdescription, pparampreviousvalue, pparamnewvalue) IS NULL)
			THEN
				NULL;
			END IF;
		END;
	
		FUNCTION logparam
		(
			pparamname          IN VARCHAR2
		   ,pparamdescription   IN VARCHAR2
		   ,pparampreviousvalue IN VARCHAR2
		   ,pparamnewvalue      IN VARCHAR2
		) RETURN BOOLEAN IS
		BEGIN
			IF (pparamnewvalue != pparampreviousvalue OR
			   pparamnewvalue IS NULL AND pparampreviousvalue IS NOT NULL OR
			   pparamnewvalue IS NOT NULL AND pparampreviousvalue IS NULL)
			THEN
				addparamtologstring(pparamdescription, pparampreviousvalue, pparamnewvalue);
				a4mlog.addparamrec(pparamname, pparampreviousvalue, pparamnewvalue);
				RETURN TRUE;
			END IF;
			RETURN FALSE;
		END;
	
		PROCEDURE logparam
		(
			pparamname          IN VARCHAR2
		   ,pparamdescription   IN VARCHAR2
		   ,pparampreviousvalue IN VARCHAR2
		   ,pparamnewvalue      IN VARCHAR2
		) IS
		BEGIN
			IF (logparam(pparamname, pparamdescription, pparampreviousvalue, pparamnewvalue) IS NULL)
			THEN
				NULL;
			END IF;
		END;
	
	BEGIN
		a4mlog.cleanplist();
	
		vloginfo      := '       Edit account:';
		vparamslogged := FALSE;
	
		logparam('Available'
				,'Available'
				,ppreviousaccountdata.available
				,pnewaccountdata.available);
		logparam('LowRemain'
				,'LowRemain'
				,ppreviousaccountdata.lowremain
				,pnewaccountdata.lowremain);
		logparam('Overdraft', 'Overdraft', ppreviousaccountdata.crdlimit, pnewaccountdata.crdlimit);
		logparam('DebitReserve'
				,'DebitReserve'
				,ppreviousaccountdata.debitreserve
				,pnewaccountdata.debitreserve);
		logparam('CreditReserve'
				,'CreditReserve'
				,ppreviousaccountdata.creditreserve
				,pnewaccountdata.creditreserve);
		IF (logparam('ACC_STAT'
					,'Status'
					,ppreviousaccountdata.acct_stat
					,pnewaccountdata.acct_stat))
		THEN
			IF (plocalacct_statchange)
			THEN
				addtologstring(' locally');
			END IF;
			a4mlog.addparamrec('LocalChange', htools.bool2str(plocalacct_statchange));
		END IF;
		logparam('BranchPart'
				,'BranchPart'
				,ppreviousaccountdata.branchpart
				,pnewaccountdata.branchpart);
		logparam('ExtAccount'
				,'ExtAccount'
				,ppreviousaccountdata.extaccountno
				,pnewaccountdata.extaccountno);
		logparam('ACCT_TYP', 'Type in PC', ppreviousaccountdata.acct_typ, pnewaccountdata.acct_typ);
	
		IF (vparamslogged)
		THEN
			a4mlog.logobject(object_type
							,ppreviousaccountdata.accountno
							,vloginfo
							,a4mlog.act_change
							,a4mlog.putparamlist()
							,powner => htools.iif(isclientpersone(ppreviousaccountdata.idclient)
												 ,ppreviousaccountdata.idclient
												 ,NULL));
		END IF;
		a4mlog.cleanplist();
	
		vbit := service.getbit(pnewaccountdata.stat, account.stbook);
		IF (vbit = 1 AND vbit != service.getbit(ppreviousaccountdata.stat, account.stbook))
		THEN
			logbookissuing(ppreviousaccountdata.accountno);
		END IF;
	
		IF (pnewaccountdata.limitgrpid != ppreviousaccountdata.limitgrpid OR
		   pnewaccountdata.limitgrpid IS NULL AND ppreviousaccountdata.limitgrpid IS NOT NULL OR
		   pnewaccountdata.limitgrpid IS NOT NULL AND ppreviousaccountdata.limitgrpid IS NULL)
		THEN
			logfolimitsgroupchanging(ppreviousaccountdata.accountno
									,ppreviousaccountdata.limitgrpid
									,pnewaccountdata.limitgrpid);
		END IF;
	
		IF (pnewaccountdata.countergrpid != ppreviousaccountdata.countergrpid OR
		   pnewaccountdata.countergrpid IS NULL AND ppreviousaccountdata.countergrpid IS NOT NULL OR
		   pnewaccountdata.countergrpid IS NOT NULL AND ppreviousaccountdata.countergrpid IS NULL)
		THEN
			logfocountergroupchanging(ppreviousaccountdata.accountno
									 ,ppreviousaccountdata.countergrpid
									 ,pnewaccountdata.countergrpid);
		END IF;
	
		IF (pnewaccountdata.internallimitsgroupsysid !=
		   ppreviousaccountdata.internallimitsgroupsysid OR
		   pnewaccountdata.internallimitsgroupsysid IS NULL AND
		   ppreviousaccountdata.internallimitsgroupsysid IS NOT NULL OR
		   pnewaccountdata.internallimitsgroupsysid IS NOT NULL AND
		   ppreviousaccountdata.internallimitsgroupsysid IS NULL)
		THEN
			logbolimitsgroupchanging(ppreviousaccountdata.accountno
									,ppreviousaccountdata.internallimitsgroupsysid
									,pnewaccountdata.internallimitsgroupsysid);
		END IF;
	
		IF (pnewaccountdata.finprofile != ppreviousaccountdata.finprofile OR
		   pnewaccountdata.finprofile IS NULL AND ppreviousaccountdata.finprofile IS NOT NULL OR
		   pnewaccountdata.finprofile IS NOT NULL AND ppreviousaccountdata.finprofile IS NULL)
		THEN
			logfinprofilechanging(ppreviousaccountdata.accountno
								 ,ppreviousaccountdata.finprofile
								 ,pnewaccountdata.finprofile);
		END IF;
		IF (pnewaccountdata.stat != ppreviousaccountdata.stat OR
		   pnewaccountdata.stat IS NULL AND ppreviousaccountdata.stat IS NOT NULL OR
		   pnewaccountdata.stat IS NOT NULL AND ppreviousaccountdata.stat IS NULL)
		THEN
			logaccstatchanging(ppreviousaccountdata.accountno
							  ,ppreviousaccountdata.stat
							  ,pnewaccountdata.stat);
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			a4mlog.cleanplist();
			setexceptionerror(cpackagename || '.LogAttributesChange'
							 ,ppreviousaccountdata.accountno);
	END;

	PROCEDURE logbolimitsgroupchanging
	(
		paccountno                IN typeaccountno
	   ,ppreviouslimitsgroupsysid IN NUMBER
	   ,pnewlimitsgroupsysid      IN NUMBER
	) IS
	BEGIN
		a4mlog.cleanplist();
		a4mlog.addparamrec('InternalLimitsGroupSysId'
						  ,ppreviouslimitsgroupsysid
						  ,pnewlimitsgroupsysid);
		a4mlog.logobject(object_type
						,paccountno
						,'Edit account (group of internal limits): ' ||
						 to_char(ppreviouslimitsgroupsysid) || ' -> ' ||
						 to_char(pnewlimitsgroupsysid)
						,a4mlog.act_change
						,a4mlog.putparamlist()
						,powner => getidclientacc(paccountno));
		a4mlog.cleanplist();
	EXCEPTION
		WHEN OTHERS THEN
			setexceptionerror(cpackagename || '.LogInternalLimitsGroupChanging', paccountno);
	END;

	PROCEDURE logfinprofilechanging
	(
		paccountno          IN typeaccountno
	   ,ppreviousfinprofile IN NUMBER
	   ,pnewfinprofile      IN NUMBER
	) IS
	BEGIN
		a4mlog.cleanplist();
		a4mlog.addparamrec('FinProfile', ppreviousfinprofile, pnewfinprofile);
	
		a4mlog.logobject(object_type
						,paccountno
						,'Edit account (financial profile): ' || to_char(ppreviousfinprofile) ||
						 ' -> ' || to_char(pnewfinprofile)
						,a4mlog.act_change
						,a4mlog.putparamlist()
						,powner => getidclientacc(paccountno));
		a4mlog.cleanplist();
	EXCEPTION
		WHEN OTHERS THEN
			a4mlog.cleanplist();
			setexceptionerror(cpackagename || '.LogFinProfileChanging', paccountno);
	END;

	PROCEDURE logaccstatchanging
	(
		paccountno    IN typeaccountno
	   ,ppreviousstat IN VARCHAR
	   ,pnewstat      IN VARCHAR
	) IS
	BEGIN
		a4mlog.cleanplist();
		a4mlog.addparamrec('Stat', getaccstatvalue(ppreviousstat), getaccstatvalue(pnewstat));
		a4mlog.logobject(object_type
						,paccountno
						,'Edit account (account state in BO): ' || getaccstatvalue(ppreviousstat) ||
						 ' -> ' || getaccstatvalue(pnewstat)
						,a4mlog.act_change
						,a4mlog.putparamlist()
						,powner => getidclientacc(paccountno));
		a4mlog.cleanplist();
	EXCEPTION
		WHEN OTHERS THEN
			a4mlog.cleanplist();
			setexceptionerror(cpackagename || '.LogAccStatChanging', paccountno);
	END;

	PROCEDURE logfolimitsgroupchanging
	(
		paccountno                IN typeaccountno
	   ,ppreviouslimitsgroupsysid IN NUMBER
	   ,pnewlimitsgroupsysid      IN NUMBER
	) IS
	BEGIN
		a4mlog.cleanplist();
		a4mlog.addparamrec('LimitGrp', ppreviouslimitsgroupsysid, pnewlimitsgroupsysid);
		a4mlog.logobject(object_type
						,paccountno
						,'Edit account (group of limits in PC): ' ||
						 to_char(ppreviouslimitsgroupsysid) || ' -> ' ||
						 to_char(pnewlimitsgroupsysid)
						,a4mlog.act_change
						,a4mlog.putparamlist()
						,powner => getidclientacc(paccountno));
		a4mlog.cleanplist();
	EXCEPTION
		WHEN OTHERS THEN
			a4mlog.cleanplist();
			setexceptionerror(cpackagename || '.LogLimitsGroupChanging', paccountno);
	END;

	PROCEDURE logfocountergroupchanging
	(
		paccountno            IN typeaccountno
	   ,ppreviouscountergroup IN NUMBER
	   ,pnewcountergroup      IN NUMBER
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.LogFOCounterGroupChanging';
	BEGIN
		a4mlog.cleanplist();
		a4mlog.addparamrec('CounterGrp', ppreviouscountergroup, pnewcountergroup);
		a4mlog.logobject(object_type
						,paccountno
						,'Edit account (group of counters in PC): ' ||
						 to_char(ppreviouscountergroup) || ' -> ' || to_char(pnewcountergroup)
						,a4mlog.act_change
						,a4mlog.putparamlist()
						,powner => getidclientacc(paccountno));
		a4mlog.cleanplist();
	EXCEPTION
		WHEN OTHERS THEN
			a4mlog.cleanplist();
			setexceptionerror(cwhere, paccountno);
	END;

	PROCEDURE logownerchanging
	(
		paccountno        IN typeaccountno
	   ,ppreviousclientid IN NUMBER
	   ,pnewclientid      IN NUMBER
	) IS
	BEGIN
		a4mlog.cleanplist();
		a4mlog.addparamrec('IDCLIENT', ppreviousclientid, pnewclientid);
		a4mlog.logobject(object_type
						,paccountno
						,'Change account holder'
						,a4mlog.act_change
						,a4mlog.putparamlist()
						,powner => htools.iif(isclientpersone(ppreviousclientid)
											 ,ppreviousclientid
											 ,NULL));
		a4mlog.cleanplist();
	
		a4mlog.addparamrec('IDCLIENT', ppreviousclientid, pnewclientid);
		a4mlog.logobject(object_type
						,paccountno
						,'Change account holder'
						,a4mlog.act_change
						,a4mlog.putparamlist()
						,powner => htools.iif(isclientpersone(pnewclientid), pnewclientid, NULL));
		a4mlog.cleanplist();
	
	EXCEPTION
		WHEN OTHERS THEN
			a4mlog.cleanplist();
			setexceptionerror(cpackagename || '.LogOwnerChanging', paccountno);
	END;

	PROCEDURE logviewing(paccountno IN typeaccountno) IS
	BEGIN
		a4mlog.logobject(object_type
						,paccountno
						,'View'
						,a4mlog.act_view
						,powner => getidclientacc(paccountno));
	EXCEPTION
		WHEN OTHERS THEN
			setexceptionerror(cpackagename || '.LogViewing', paccountno);
	END;

	PROCEDURE logclosure(paccountno IN typeaccountno) IS
	BEGIN
		a4mlog.logobject(object_type
						,paccountno
						,'Close'
						,a4mlog.act_change
						,powner => getidclientacc(paccountno));
	EXCEPTION
		WHEN OTHERS THEN
			setexceptionerror(cpackagename || '.LogClosure', paccountno);
	END;

	PROCEDURE logclosurecancelling(paccountno IN typeaccountno) IS
	BEGIN
		a4mlog.logobject(object_type
						,paccountno
						,'Cancel closure'
						,a4mlog.act_change
						,powner => getidclientacc(paccountno));
	EXCEPTION
		WHEN OTHERS THEN
			setexceptionerror(cpackagename || '.LogClosureCancelling', paccountno);
	END;

	PROCEDURE logfindocumentdeletion
	(
		paccountno     IN typeaccountno
	   ,pfindocumentno IN NUMBER
	) IS
	BEGIN
		a4mlog.cleanplist();
		a4mlog.addparamrec('DOCNO', pfindocumentno);
		a4mlog.logobject(object_type
						,paccountno
						,'Delete financial document: ' || to_char(pfindocumentno)
						,a4mlog.act_del
						,a4mlog.putparamlist()
						,powner => getidclientacc(paccountno));
		a4mlog.cleanplist();
	EXCEPTION
		WHEN OTHERS THEN
			a4mlog.cleanplist();
			setexceptionerror(cpackagename || '.LogFinDocumentDeletion', paccountno);
	END;

	PROCEDURE logfindocumentreversing
	(
		paccountno     IN typeaccountno
	   ,pfindocumentno IN NUMBER
	) IS
	BEGIN
		a4mlog.cleanplist();
		a4mlog.addparamrec('DOCNO', pfindocumentno);
		a4mlog.logobject(object_type
						,paccountno
						,'Reverse financial document: ' || to_char(pfindocumentno)
						,a4mlog.act_change
						,a4mlog.putparamlist()
						,powner => getidclientacc(paccountno));
		a4mlog.cleanplist();
	EXCEPTION
		WHEN OTHERS THEN
			a4mlog.cleanplist();
			setexceptionerror(cpackagename || '.LogFinDocumentReversing', paccountno);
	END;

	PROCEDURE logentrycorrection
	(
		paccountno     IN typeaccountno
	   ,pfindocumentno IN NUMBER
	   ,pentryno       IN NUMBER
	) IS
	BEGIN
		a4mlog.cleanplist();
		a4mlog.addparamrec('DOCNO', pfindocumentno);
		a4mlog.addparamrec('NO', pentryno);
		a4mlog.logobject(object_type
						,paccountno
						,'Edit entry: ' || to_char(pfindocumentno) || '/' || to_char(pentryno)
						,a4mlog.act_change
						,a4mlog.putparamlist()
						,powner => getidclientacc(paccountno));
		a4mlog.cleanplist();
	EXCEPTION
		WHEN OTHERS THEN
			a4mlog.cleanplist();
			setexceptionerror(cpackagename || '.LogEntryCorrection', paccountno);
	END;

	PROCEDURE logchange
	(
		paccountno typeaccountno
	   ,paction    NUMBER
	   ,plogtext   VARCHAR2
	   ,pparamlist a4mlog.typelogparamrecord
	) IS
	BEGIN
	
		a4mlog.logobject(object_type
						,paccountno
						,plogtext
						,paction
						,pparamlist
						,powner => getidclientacc(paccountno));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.LogChange');
			RAISE;
	END;

	PROCEDURE changeowner
	(
		paccounthandle IN NUMBER
	   ,pnewclientid   IN NUMBER
	   ,plog           IN BOOLEAN := FALSE
	) IS
		vobjectcontexthandle typeobjectcontexthandle := NULL;
	BEGIN
		s.say(cpackagename || '.ChangeOwner');
		SAVEPOINT sp_account_changeowner;
	
		vobjectcontexthandle := saveobjectcontext(paccounthandle);
	
		testhandle(paccounthandle, cpackagename || '.ChangeOwner');
	
		regularpayment.changeclient4account(sopenacc(paccounthandle).accountno, pnewclientid);
		error.raisewhenerr();
		statementrt.changeowneraccount(sopenacc(paccounthandle).accountno, pnewclientid);
		error.raisewhenerr();
		IF (nvl(plog, FALSE))
		THEN
			logownerchanging(sopenacc(paccounthandle).accountno
							,account.getidclient(paccounthandle)
							,pnewclientid);
			error.raisewhenerr();
		END IF;
		setidclient(paccounthandle, pnewclientid);
		error.raisewhenerr();
	
		freeobjectcontext(vobjectcontexthandle);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.ChangeOwner', getaccountno(paccounthandle));
			ROLLBACK TO sp_account_changeowner;
			IF (vobjectcontexthandle IS NOT NULL)
			THEN
				freeobjectcontext(vobjectcontexthandle);
			END IF;
			RAISE;
	END;

	PROCEDURE changelowremain
	(
		paccounthandle NUMBER
	   ,pdelta         NUMBER
	   ,pcomment       VARCHAR
	) IS
	BEGIN
		err.seterror(0, 'ChangeLowRemain');
	
		account.setlowremain(paccounthandle
							,greatest(nvl(account.getlowremain(paccounthandle), 0), 0) + pdelta
							,pcomment);
		error.raisewhenerr();
		account.writeobject(paccounthandle);
		error.raisewhenerr();
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.ChangeLowRemain pAccountHandle [' || paccounthandle ||
					   '], pDelta [' || pdelta || ']');
			RAISE;
	END;

	PROCEDURE changelowremain
	(
		paccountno typeaccountno
	   ,pdelta     NUMBER
	   ,pcomment   VARCHAR
	) IS
		vaccounthandle NUMBER := NULL;
	BEGIN
		err.seterror(0, 'ChangeLowRemain');
		vaccounthandle := newobject(paccountno, 'W');
		error.raisewhenerr;
		account.changelowremain(vaccounthandle, pdelta, pcomment);
	
		account.freeobject(vaccounthandle);
		vaccounthandle := NULL;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.ChangeLowRemain pAccountNo [' || paccountno || ']');
			IF (vaccounthandle > 0)
			THEN
				account.freeobject(vaccounthandle);
			END IF;
			RAISE;
	END;

	PROCEDURE changelowremain_fast
	(
		paccounthandle NUMBER
	   ,paccountno     typeaccountno
	   ,pdelta         NUMBER
	   ,pcomment       VARCHAR
	) IS
		vres NUMBER := 0;
	BEGIN
		s.say(cpackagename || '.ChangeLowRemain_Fast: pAccountHandle [' || paccounthandle ||
			  '], pAccount [' || paccountno || '], pDelta [' || pdelta || ']');
		IF paccounthandle IS NOT NULL
		THEN
			changelowremain(paccounthandle => paccounthandle
						   ,pdelta         => pdelta
						   ,pcomment       => pcomment);
			RETURN;
		END IF;
	
		SAVEPOINT x_changelowremain_fast;
		UPDATE taccount t
		SET    t.lowremain   = coalesce(t.lowremain, 0) + pdelta
			  ,updatesysdate = SYSDATE()
		WHERE  branch = seance.getbranch
		AND    accountno = paccountno
		RETURNING lowremain INTO vres;
		IF vres < 0
		THEN
			ROLLBACK TO x_changelowremain_fast;
			error.raiseerror(err.account_invalid_value, 'Set negative minimum account balance');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.ChangeLowRemain_Fast pAccountHandle [' || paccounthandle ||
					   '], pAccount [' || paccountno || '], pDelta [' || pdelta || ']');
			RAISE;
	END;

	FUNCTION isinfront(paccountno IN typeaccountno) RETURN BOOLEAN IS
		vbranch     NUMBER := seance.getbranch();
		vexistsinpc NUMBER;
	BEGIN
	
		vexistsinpc := getexistsinpc(paccountno);
		CASE vexistsinpc
			WHEN cyesexistsinpc THEN
				RETURN TRUE;
			WHEN cnoexistsinpc THEN
				RETURN FALSE;
			ELSE
			
				FOR i IN (SELECT m.*
						  FROM   texmodule     m
								,texmoduletype t
						  WHERE  t.sysname = 'A4MF'
						  AND    m.code_type = t.code
						  AND    m.branch = vbranch)
				LOOP
					IF exchange.isaccountrefresh(i.code, paccountno)
					THEN
						RETURN TRUE;
					END IF;
				END LOOP;
				RETURN FALSE;
		END CASE;
	
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.IsInFront');
			RAISE;
	END;

	FUNCTION getmaxdocnoforacc(paccountno IN typeaccountno) RETURN NUMBER IS
		cbranch CONSTANT NUMBER := seance.getbranch;
		vresult NUMBER := NULL;
	BEGIN
	
		IF paccountno IS NOT NULL
		THEN
		
			SELECT /*+ ALL_ROWS */
			 MAX(docno)
			INTO   vresult
			FROM   (SELECT e.docno
					FROM   (SELECT branch
								  ,docno
							FROM   tentry
							WHERE  branch = cbranch
							AND    debitaccount = paccountno
							UNION ALL
							SELECT branch
								  ,docno
							FROM   tentry
							WHERE  branch = cbranch
							AND    creditaccount = paccountno) e
					
					JOIN   tdocument d
					ON     d.branch = e.branch
					AND    d.docno = e.docno
					WHERE  d.newdocno IS NULL
					
					UNION ALL
					
					SELECT ea.docno
					FROM   (SELECT branch
								  ,docno
							FROM   tentryarc
							WHERE  branch = cbranch
							AND    debitaccount = paccountno
							UNION ALL
							SELECT branch
								  ,docno
							FROM   tentryarc
							WHERE  branch = cbranch
							AND    creditaccount = paccountno) ea
					
					JOIN   tdocumentarc da
					ON     da.branch = ea.branch
					AND    da.docno = ea.docno
					WHERE  da.newdocno IS NULL);
		
		END IF;
	
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || 'GetMaxDocNoForAcc');
			RAISE;
	END;

	FUNCTION canview(paccountno IN typeaccountno) RETURN BOOLEAN IS
		vright    BOOLEAN := TRUE;
		vidclient tclient.idclient%TYPE;
	BEGIN
		vidclient := getaccountrecord(paccountno).idclient;
		vright    := client.canview(vidclient);
		IF vright
		THEN
			vright := account.checkright(account.right_view, paccountno) AND
					  account.checkright(account.right_view_all_branchpart, paccountno) AND
					  account.checkright(account.right_view_vip, paccountno) AND
					  account.checkright(account.right_view_vip_all_branchpart, paccountno);
		END IF;
		RETURN vright;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN vright;
	END;

	FUNCTION describescript(plocator IN VARCHAR2) RETURN VARCHAR2 IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.DescribeScript';
		vmaindescr VARCHAR2(10) := object.getremarkbyname(account.object_name);
		valevels   types.arrtext;
	BEGIN
		valevels := htools.parsestring(plocator, '/');
		IF valevels(1) != account.object_name
		   OR NOT valevels.exists(2)
		THEN
			error.raiseerror(err.ue_value_incorrect, 'Invalid object');
		END IF;
		RETURN vmaindescr || '/' || accountblocks.getblockdescription(to_number(valevels(2))
																	 ,to_number(valevels(3)));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RETURN plocator;
	END;

	FUNCTION getaccstatvalue(pstat taccount.stat%TYPE) RETURN VARCHAR IS
		vstat taccount.stat%TYPE;
	BEGIN
		s.say(cpackagename || '.GetAccStatValue: ' || pstat);
		vstat := pstat;
		IF service.getbit(vstat, account.stat_close) = 1
		THEN
			RETURN account.stat_close;
		ELSIF service.getbit(vstat, account.stat_arrest) = 1
		THEN
			RETURN account.stat_arrest;
		ELSIF service.getbit(vstat, account.stat_mark) = 1
		THEN
			RETURN account.stat_mark;
		ELSIF service.getbit(vstat, account.stat_nosub) = 1
		THEN
			RETURN account.stat_nosub;
		ELSE
			RETURN NULL;
		END IF;
	END;

	PROCEDURE setdataforexchange(paccount typeaccountno) IS
		vobjinfo exchange.typeobjectinforecord;
	BEGIN
		vobjinfo.locator    := paccount;
		vobjinfo.objecttype := object_type;
		vobjinfo.opertype   := exchange.cop_delete;
		vobjinfo.systemdate := SYSDATE;
		vobjinfo.operdate   := seance.getoperdate;
		vobjinfo.comment    := 'Deleted by user';
	
		exchange.setobjectinfo(vobjinfo);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SetDataForExchange');
			RAISE;
	END;

	FUNCTION rowtoapi
	(
		paccountrow  IN taccount%ROWTYPE
	   ,pwithoutguid BOOLEAN
	) RETURN apitypes.typeaccountrecord IS
		vplanaccounttype NUMBER;
		vrec             apitypes.typeaccountrecord;
	BEGIN
	
		vrec.accountno     := paccountrow.accountno;
		vrec.accounttype   := paccountrow.accounttype;
		vrec.noplan        := paccountrow.noplan;
		vrec.stat          := paccountrow.stat;
		vrec.currency      := paccountrow.currencyno;
		vrec.idclient      := paccountrow.idclient;
		vrec.remain        := paccountrow.remain;
		vrec.available     := paccountrow.available;
		vrec.lowremain     := paccountrow.lowremain;
		vrec.crdlimit      := paccountrow.overdraft;
		vrec.debitreserve  := paccountrow.debitreserve;
		vrec.creditreserve := paccountrow.creditreserve;
		vrec.branchpart    := paccountrow.branchpart;
		vrec.createclerk   := paccountrow.createclerkcode;
		vrec.createdate    := paccountrow.createdate;
		vrec.updateclerk   := paccountrow.updateclerkcode;
		vrec.updatedate    := paccountrow.updatedate;
		vrec.updatesysdate := paccountrow.updatesysdate;
		vrec.acct_typ      := paccountrow.acct_typ;
		vrec.acct_stat     := paccountrow.acct_stat;
		vplanaccounttype   := planaccount.gettype(vrec.noplan);
		error.raisewhenerr();
		IF (vplanaccounttype = planaccount.type_nonconsolidated)
		THEN
			vrec.extaccountno := planaccount.getexternal(vrec.noplan);
		ELSE
			vrec.extaccountno := acc2acc.getoldaccountno(vrec.accountno);
		END IF;
		error.raisewhenerr();
		vrec.closedate        := paccountrow.closedate;
		vrec.remark           := paccountrow.remark;
		vrec.limitgrpid       := paccountrow.limitgrpid;
		vrec.remainupdatedate := paccountrow.remainupdatedate;
		vrec.finprofile       := paccountrow.finprofile;
		IF NOT pwithoutguid
		THEN
			vrec.guid := objectuid.getguid(paccountrow.objectuid);
		END IF;
		vrec.internallimitsgroupsysid := paccountrow.internallimitsgroupsysid;
		vrec.countergrpid             := paccountrow.countergrpid;
	
		vrec.permissibleexcesstype := paccountrow.permissibleexcesstype;
		vrec.permissibleexcess     := paccountrow.permissibleexcess;
	
		vrec.protectedamount := paccountrow.protectedamount;
	
		RETURN vrec;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.RowToAPI');
			RAISE;
	END;

	PROCEDURE runcontrolblock
	(
		paccountno               typeaccountno
	   ,pclienttype              PLS_INTEGER
	   ,pintrabankaccount        BOOLEAN
	   ,pblocktype               PLS_INTEGER
	   ,pdialogattributescontext BOOLEAN
	   ,ptypemode                PLS_INTEGER
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.RunControlBlock';
	BEGIN
		IF pclienttype = client.ct_persone
		THEN
			s.say(cwhere || '|Consolidated persone account pAccountNo=' || paccountno);
		
			accountblocks.run(accountblocks.casperson
							 ,pblocktype
							 ,paccountno
							 ,pdialogattributescontext
							 ,ptypemode);
		
		ELSE
			IF pintrabankaccount
			THEN
				s.say(cwhere || '|NonConsolidated account ');
				accountblocks.run(accountblocks.casbankinternal
								 ,pblocktype
								 ,paccountno
								 ,pdialogattributescontext
								 ,ptypemode);
			ELSE
				s.say(cwhere || '|Consolidated corporate account ');
				accountblocks.run(accountblocks.cascorporate
								 ,pblocktype
								 ,paccountno
								 ,pdialogattributescontext
								 ,ptypemode);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere || ' [' || paccountno || ']');
			error.raiseerror(error.getcode, 'Error in user-defined block: ' || error.gettext());
		
	END;

	PROCEDURE convertapitorow
	(
		prec        IN apitypes.typeaccountrecord
	   ,orow        IN OUT taccount%ROWTYPE
	   ,pwithoutuid BOOLEAN
	) IS
	BEGIN
		orow.accountno        := prec.accountno;
		orow.accounttype      := prec.accounttype;
		orow.noplan           := prec.noplan;
		orow.stat             := prec.stat;
		orow.currencyno       := prec.currency;
		orow.idclient         := prec.idclient;
		orow.remain           := prec.remain;
		orow.available        := prec.available;
		orow.lowremain        := prec.lowremain;
		orow.overdraft        := prec.crdlimit;
		orow.debitreserve     := prec.debitreserve;
		orow.creditreserve    := prec.creditreserve;
		orow.branchpart       := prec.branchpart;
		orow.createclerkcode  := prec.createclerk;
		orow.createdate       := prec.createdate;
		orow.updateclerkcode  := prec.updateclerk;
		orow.updatedate       := prec.updatedate;
		orow.updatesysdate    := prec.updatesysdate;
		orow.acct_typ         := prec.acct_typ;
		orow.acct_stat        := prec.acct_stat;
		orow.closedate        := prec.closedate;
		orow.remark           := prec.remark;
		orow.limitgrpid       := prec.limitgrpid;
		orow.remainupdatedate := prec.remainupdatedate;
		orow.finprofile       := prec.finprofile;
		IF (NOT pwithoutuid)
		THEN
			orow.objectuid := getuid(prec.accountno);
		END IF;
		orow.internallimitsgroupsysid := prec.internallimitsgroupsysid;
		orow.countergrpid             := prec.countergrpid;
	
		orow.permissibleexcesstype := prec.permissibleexcesstype;
		orow.permissibleexcess     := prec.permissibleexcess;
	
		orow.protectedamount := prec.protectedamount;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.ConvertAPIToRow');
			RAISE;
	END;

	PROCEDURE runupdateblock
	(
		paccountrecord           IN OUT apitypes.typeaccountrecord
	   ,puserattrlist            IN OUT apitypes.typeuserproplist
	   ,pclienttype              PLS_INTEGER
	   ,pdialogattributescontext BOOLEAN := FALSE
	   ,pintrabankaccount        BOOLEAN
	   ,ptypemode                PLS_INTEGER
	   ,pisrollback              BOOLEAN := FALSE
	) IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.RunUpdateBlock';
	BEGIN
		s.say(cwhere || ': start, pUserAttrList=' || puserattrlist.count);
		setcurrent(paccountrecord);
		setcurrentuserprop(puserattrlist);
	
		IF pclienttype = client.ct_persone
		THEN
			s.say(cwhere || '|Consolidated persone account pAccountNo=' ||
				  paccountrecord.accountno);
			accountblocks.run(accountblocks.casperson
							 ,accountblocks.cbtupdate
							 ,paccountrecord.accountno
							 ,pdialogattributescontext
							 ,ptypemode
							 ,pisrollback);
		
		ELSE
			IF pintrabankaccount
			THEN
				s.say(cwhere || '|NonConsolidated account ');
				accountblocks.run(accountblocks.casbankinternal
								 ,accountblocks.cbtupdate
								 ,paccountrecord.accountno
								 ,pdialogattributescontext
								 ,ptypemode
								 ,pisrollback);
			ELSE
				s.say(cwhere || '|Consolidated corporate account ');
				accountblocks.run(accountblocks.cascorporate
								 ,accountblocks.cbtupdate
								 ,paccountrecord.accountno
								 ,pdialogattributescontext
								 ,ptypemode
								 ,pisrollback);
			END IF;
		END IF;
		paccountrecord := account.getcurrent();
		puserattrlist  := account.getcurrentuserprop();
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			error.raiseerror(error.getcode, 'Error in user-defined block: ' || error.gettext());
		
	END;

	FUNCTION getcurrentuserprop RETURN apitypes.typeuserproplist IS
		vuserproplist apitypes.typeuserproplist;
	BEGIN
		RETURN scurrentuserprop;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetCurrentAccountUserProp');
			RETURN vuserproplist;
	END;

	PROCEDURE setcurrentuserprop(puserproplist IN apitypes.typeuserproplist) IS
	BEGIN
		scurrentuserprop := puserproplist;
		s.say(cpackagename || '.SetCurrentUserProp: ' || scurrentuserprop.count);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SetCurrentAccountUserProp');
	END;

	PROCEDURE setmode(pmode NUMBER) IS
	BEGIN
		s.say(cpackagename || '.SetMode [' || pmode || ']');
		sdeletemode := pmode;
		smode       := pmode;
	END;

	FUNCTION getmode RETURN NUMBER IS
	BEGIN
		RETURN smode;
	END;

	FUNCTION getexistsinpc(paccountno IN typeaccountno) RETURN NUMBER IS
		vbranch     NUMBER := seance.getbranch();
		vexistsinpc NUMBER(1);
	BEGIN
	
		SELECT existsinpc
		INTO   vexistsinpc
		FROM   taccount
		WHERE  branch = vbranch
		AND    accountno = paccountno;
	
		RETURN vexistsinpc;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetExistsInPC (' || paccountno || ')');
			RAISE;
	END;

	PROCEDURE setexistsinpc
	(
		paccountno  IN typeaccountno
	   ,pexistsinpc IN NUMBER
	   ,pnocommit   IN BOOLEAN := TRUE
	) IS
		vbranch NUMBER := seance.getbranch();
		vplno   NUMBER;
	BEGIN
		s.say(cpackagename || '.SetExistsInPC: pAccountNo=' || paccountno || ' pExistsInPC=' ||
			  pexistsinpc);
		UPDATE taccount
		SET    existsinpc = pexistsinpc
		WHERE  branch = vbranch
		AND    accountno = paccountno;
		IF NOT (pnocommit)
		THEN
			COMMIT;
		END IF;
	
		vplno := a4mlog.getfreeplistno();
		a4mlog.cleanplist(vplno);
		a4mlog.addparamrec('ExistsInPC', nvl(to_char(pexistsinpc), 'null'), plistnum => vplno);
	
		a4mlog.logobject(object_type
						,paccountno
						,'Edit account (indicator of whether account exists in external system)'
						,a4mlog.act_change
						,pparamlist => a4mlog.putparamlist(vplno));
		a4mlog.cleanplist(vplno);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.SetExistsInPC (' || paccountno || ')');
			RAISE;
	END;

	FUNCTION existsinpc(paccountno IN typeaccountno) RETURN BOOLEAN IS
		vexistsinpc NUMBER(1);
	BEGIN
	
		vexistsinpc := getexistsinpc(paccountno);
		IF vexistsinpc = cyesexistsinpc
		THEN
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.ExistsInPC (' || paccountno || ')');
			RAISE;
	END;

BEGIN

	object_type := object.gettype(object_name);
	sstatname(1) := 'Marked';
	sstatname(2) := 'Arrested';
	sstatname(3) := 'Closed';
	sstatname(4) := 'Debit prohibited!';
	sstatname(5) := 'Passbook issued';
	sdeleteclient := '1';

	setlastdcerrortrackingoff();
END;
/
