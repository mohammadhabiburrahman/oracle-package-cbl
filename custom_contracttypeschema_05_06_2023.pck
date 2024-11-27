CREATE OR REPLACE PACKAGE custom_contracttypeschema AS

	cpackagedescr CONSTANT VARCHAR2(100) := 'System package used to control contract financial operations';

	cheaderversion CONSTANT VARCHAR2(50) := '22.01.01';

	cheaderdate CONSTANT DATE := to_date('01.12.2022', 'DD.MM.YYYY');

	cheadertwcms CONSTANT VARCHAR2(50) := '4.15.88';

	cheaderrevision CONSTANT VARCHAR2(100) := '$Rev: 62408 $';

	cdepositaccount    CONSTANT NUMBER := 1;
	ccreditaccount     CONSTANT NUMBER := 2;
	cadddepositaccount CONSTANT NUMBER := 3;

	TYPE typeinterest IS RECORD(
		
		 estimateddate  DATE
		,paymentduedate DATE
		,
		
		interest  NUMBER
		,principal NUMBER);

	TYPE typeinterestlist IS TABLE OF typeinterest INDEX BY BINARY_INTEGER;

	sainterestlist typeinterestlist;

	sacardaccountlist apitypes.typeaccount2cardlist;

	sdirectdebit  CONSTANT NUMBER := 1;
	sdirectcredit CONSTANT NUMBER := 2;

	operacc_in  CONSTANT NUMBER := 1;
	operacc_out CONSTANT NUMBER := 2;
	operbalance CONSTANT NUMBER := 3;
	operpayoff  CONSTANT NUMBER := 4;
	operinsure  CONSTANT NUMBER := 5;

	ident_accin       CONSTANT VARCHAR2(20) := 'ACC_IN';
	ident_accout      CONSTANT VARCHAR2(20) := 'ACC_OUT';
	ident_balance     CONSTANT VARCHAR2(20) := 'BALANCE';
	ident_payoff      CONSTANT VARCHAR2(20) := 'PAY_OFF';
	ident_loan_off    CONSTANT VARCHAR2(20) := 'LOAN_OFF';
	ident_loanprc_off CONSTANT VARCHAR2(20) := 'LOAN_PRC_OFF';

	coper_date  CONSTANT NUMBER := 1;
	cvalue_date CONSTANT NUMBER := 2;

	cautocreate_add  CONSTANT NUMBER := 1;
	cautocreate_edit CONSTANT NUMBER := 2;

	centrymode_del      CONSTANT NUMBER := 1;
	centrymode_undo     CONSTANT NUMBER := 2;
	centrymode_undofast CONSTANT NUMBER := 3;
	centrymode_edit     CONSTANT NUMBER := 4;
	centrymode_reverse  CONSTANT NUMBER := 5;

	coperationtype_extract        CONSTANT NUMBER := 1;
	coperationtype_event          CONSTANT NUMBER := 2;
	coperationtype_statementrt    CONSTANT NUMBER := 3;
	coperationtype_finprofile     CONSTANT NUMBER := 4;
	coperationtype_loyaltyprogram CONSTANT NUMBER := 5;
	coperationtype_transfer       CONSTANT NUMBER := 6;
	coperationtype_extractdelay   CONSTANT NUMBER := 7;

	TYPE typenotification IS RECORD(
		 neednotify  BOOLEAN := TRUE
		,fimicomment VARCHAR2(4000));

	cclientmenu_bustcriteria CONSTANT VARCHAR2(50) := 'CLIENTMENU_BUSTCRITERIA';

	TYPE typeclientparams IS RECORD(
		 idclient NUMBER
		,menuitem VARCHAR2(50)
		,readonly BOOLEAN := FALSE);

	semptyclientparams typeclientparams;

	TYPE typeclientmenuitem IS RECORD(
		 menuitem VARCHAR2(50)
		,caption  VARCHAR2(100)
		,hint     VARCHAR2(100));
	TYPE typeclientmenuitemlist IS TABLE OF typeclientmenuitem INDEX BY BINARY_INTEGER;

	TYPE typeentryproperties IS RECORD(
		 entrymode     NUMBER
		,entrycheck    NUMBER
		,docno         NUMBER
		,entryno       NUMBER
		,VALUE         NUMBER
		,contractno    tcontract.no%TYPE
		,contracttype  tcontract.type%TYPE
		,accounthandle NUMBER
		,packagename   tcontractschemas.packagename%TYPE
		,
		
		newdocno   tdocument.docno%TYPE := NULL
		,newentryno tentry.no%TYPE
		,
		
		notification typenotification
		,docno4update tdocument.docno%TYPE := NULL
		,
		
		debitaccount  taccount.accountno%TYPE
		,creditaccount taccount.accountno%TYPE
		,
		
		makeentry      BOOLEAN := TRUE
		,createdocument BOOLEAN := FALSE);
	sentryprops typeentryproperties;

	TYPE tadjustingrecord IS RECORD(
		 flagcheckavl NUMBER
		,no           NUMBER
		,debit        VARCHAR2(20)
		,credit       VARCHAR2(20)
		,VALUE        NUMBER
		,entident     VARCHAR2(40)
		,entcode      NUMBER
		,shortremark  VARCHAR2(10)
		,fullremark   tentry.fullremark%TYPE
		,twodebit     VARCHAR2(20)
		,twocredit    VARCHAR2(20));
	TYPE tadjustingarray IS TABLE OF tadjustingrecord INDEX BY BINARY_INTEGER;
	saadjusting tadjustingarray;

	TYPE taggregatearray IS TABLE OF taccount%ROWTYPE INDEX BY BINARY_INTEGER;
	TYPE taggregateitemarray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	TYPE taggroutparams IS RECORD(
		 parentaccount VARCHAR2(20)
		,bonus         NUMBER
		,code          VARCHAR2(40)
		,priority      NUMBER
		,bonusprograms types.arrnum);
	saaggregate        taggregatearray;
	saaggregateacctype taggregateitemarray;
	sparentaccountno   VARCHAR2(30);
	sbonus             NUMBER;
	scode              VARCHAR2(40);
	spriority          NUMBER;
	sabonusprograms    types.arrnum;

	TYPE trecoper IS RECORD(
		 NAME VARCHAR2(40));
	TYPE toperation IS TABLE OF trecoper INDEX BY BINARY_INTEGER;
	saoperation toperation;

	TYPE trecparam IS RECORD(
		 accountno    VARCHAR2(20)
		,currencysum  NUMBER
		,VALUE        NUMBER
		,currencydest NUMBER
		,entident     VARCHAR2(20)
		,checkavl     BOOLEAN
		,shortremark  tentry.shortremark%TYPE
		,fullremark   tentry.fullremark%TYPE
		,valuedate    tentry.valuedate%TYPE);
	sparameters trecparam;

	TYPE tclosecontractparamrec IS RECORD(
		 accountno VARCHAR2(20)
		,schparams VARCHAR2(1000));
	sclosecontractparamrec tclosecontractparamrec;

	TYPE tcontractinforecord IS RECORD(
		 NAME        VARCHAR2(40)
		,VALUE       VARCHAR2(2000)
		,elementname VARCHAR2(100)
		,elementkey  VARCHAR2(100));
	TYPE tcontractinfoarray IS TABLE OF tcontractinforecord INDEX BY BINARY_INTEGER;
	sacontractinfo tcontractinfoarray;

	TYPE tentryrecord IS RECORD(
		 docno     tentry.docno%TYPE
		,no        tentry.no%TYPE
		,accountno taccount.accountno%TYPE
		,debit     BOOLEAN
		,entvalue  tentry.value%TYPE
		,entcode   tentry.debitentcode%TYPE
		,remain    taccount.remain%TYPE
		
		,opdate tdocument.opdate%TYPE
		
		);

	TYPE tentryarray IS TABLE OF tentryrecord INDEX BY BINARY_INTEGER;
	saentry tentryarray;

	TYPE typeentryinforecord IS RECORD(
		 docno     tentry.docno%TYPE
		,no        tentry.no%TYPE
		,accountno taccount.accountno%TYPE
		,debit     NUMBER
		,entvalue  tentry.value%TYPE
		,entcode   tentry.debitentcode%TYPE
		,remain    taccount.remain%TYPE);
	TYPE typeentryinfoarray IS TABLE OF typeentryinforecord INDEX BY BINARY_INTEGER;

	SUBTYPE typecurrencyrangevalue IS VARCHAR2(50);

	ccurrrange_any     CONSTANT NUMBER := 1;
	ccurrrange_branch  CONSTANT NUMBER := 2;
	ccurrrange_ubranch CONSTANT NUMBER := 3;
	ccurrrange_item    CONSTANT NUMBER := 4;
	ccurrrange_const   CONSTANT NUMBER := 5;

	TYPE typeaccountoptions IS RECORD(
		 currrangemethod         PLS_INTEGER := ccurrrange_any
		,currrange               typecurrencyrangevalue
		,permitacctypedifference BOOLEAN := TRUE);

	cemptyaccountoptions typeaccountoptions;

	TYPE typeaccountoptionslist IS TABLE OF typeaccountoptions INDEX BY tcontracttypeitemname.itemname%TYPE;

	TYPE titemaccrecord IS RECORD(
		 itemname                tcontracttypeitemname.itemname%TYPE
		,description             tcontracttypeitems.description%TYPE
		,createmode              NUMBER
		,refaccounttype          NUMBER
		,iscardaccount           PLS_INTEGER := 1
		,currrangemethod         PLS_INTEGER := ccurrrange_any
		,currrange               typecurrencyrangevalue
		,permitacctypedifference BOOLEAN := TRUE
		,
		
		accountsign NUMBER := NULL
		
		);
	TYPE titemaccarray IS TABLE OF titemaccrecord INDEX BY BINARY_INTEGER;
	saitemaccountarray titemaccarray;

	TYPE tcapitemrecord IS RECORD(
		 code NUMBER
		,NAME VARCHAR2(80));

	TYPE tcapitemarray IS TABLE OF tcapitemrecord INDEX BY BINARY_INTEGER;

	sacapitems tcapitemarray;

	TYPE tmainaccountsarray IS TABLE OF taccount.accountno%TYPE INDEX BY BINARY_INTEGER;

	samainaccounts tmainaccountsarray;

	TYPE tatminforecord IS RECORD(
		 ident NUMBER
		,VALUE VARCHAR2(30));
	TYPE tatminfoarray IS TABLE OF tatminforecord INDEX BY BINARY_INTEGER;
	sainfo tatminfoarray;

	TYPE tcontractquery IS RECORD(
		 contractno tcontract.no%TYPE
		,querytype  VARCHAR2(40)
		,accountno  taccount.accountno%TYPE
		,pan        tcard.pan%TYPE
		,mbr        tcard.mbr%TYPE);
	srecinfo tcontractquery;

	TYPE trequestrecord IS RECORD(
		 infotype  VARCHAR2(40)
		,identtype NUMBER
		,ident     VARCHAR2(40)
		,format    NUMBER
		,addparams VARCHAR2(32000));
	SUBTYPE tresponsearray IS types.arrtext;
	scontractrequest   trequestrecord;
	sacontractresponse tresponsearray;

	TYPE toperpaymentparams IS RECORD(
		 direction NUMBER);
	sregpayparams      toperpaymentparams;
	sregpaycontractrec apipayment.tregpaycontractrec;
	soperstage         NUMBER;

	sstagepre  CONSTANT NUMBER := -1;
	sstageexec CONSTANT NUMBER := 0;
	sstagepost CONSTANT NUMBER := 1;

	scontractsh  apitypesfordc.typecontractsnapshotrecord;
	sitemsshlist apitypesfordc.typecontractitemshapshotlist;
	scontractrec apitypesfordc.typecontractrecord;
	sitemslist   apitypesfordc.typecontractitemlist;
	stranslist   apitypesfordc.typedctranslist;
	sactions     apitypesfordc.typeactionrecord;
	sstatelist   apitypesfordc.typecontractstatelist;
	soverduelist apitypesfordc.typecontractoverduelist;

	savcfperiodlist  apitypesforvcf.typeperiodlist;
	savcfbalancelist apitypesforvcf.typebalancelist;

	TYPE typefinruncommission IS RECORD(
		 clientaccount       taccount.accountno%TYPE
		,docno               NUMBER
		,entryno             NUMBER
		,commission          NUMBER
		,VALUE               NUMBER
		,valuecurrency       NUMBER
		,exchange            NUMBER
		,bankaccount         taccount.accountno%TYPE
		,clientaccounthandle NUMBER);

	TYPE tsop_params IS RECORD(
		 procname      VARCHAR2(40)
		,debitaccount  NUMBER
		,creditaccount NUMBER
		,
		
		debitaccountno  taccount.accountno%TYPE
		,creditaccountno taccount.accountno%TYPE
		,
		
		operamount         NUMBER
		,currency           NUMBER
		,exchrate           NUMBER
		,enrtycode          NUMBER
		,debitpriority      NUMBER
		,creditpriority     NUMBER
		,direction          NUMBER
		,commdebitplus      NUMBER
		,commdebitminus     NUMBER
		,commcreditplus     NUMBER
		,commcreditminus    NUMBER
		,remaincheckmode    NUMBER
		,onlinecheckmode    NUMBER
		,neednotify         BOOLEAN := TRUE
		,fimicomment        VARCHAR2(1000) := NULL
		,debitusebonusdebt  BOOLEAN := TRUE
		,creditusebonusdebt BOOLEAN := TRUE
		,useschemarules     BOOLEAN := FALSE
		,checkcredit        NUMBER
		,neednotifycredit   BOOLEAN := TRUE
		,fimicommentcredit  VARCHAR2(1000)
		,
		
		extractrow       apitypes.typeextractrecord
		,eventrow         apitypes.typeeventrecord
		,statementrow     apitypes.typestatementfeerecord
		,finruncommission typefinruncommission
		,bonusrow         apitypes.typeextractbonusrecord
		,delayrow         apitypes.typeextractdelayrecord
		,transferrow      apitypes.typetransferrecord
		,contractrow      contract.typecontractitemrecord
		,contractrow2     contract.typecontractitemrecord
		,undorec          tcontractrollback%ROWTYPE
		,objecttype       NUMBER
		,key              VARCHAR2(100)
		,execresult       NUMBER
		,operationtype    NUMBER
		,
		
		donemanually BOOLEAN := FALSE);

	sop_params tsop_params;

	TYPE tsop_entryrec IS RECORD(
		 entryno       NUMBER
		,debitaccount  VARCHAR2(20)
		,creditaccount VARCHAR2(20)
		,amount        NUMBER
		,currency      NUMBER
		,enrtycode     NUMBER
		,shortremark   VARCHAR2(10)
		,fullremark    VARCHAR2(250));
	TYPE tsop_entrylist IS TABLE OF tsop_entryrec INDEX BY BINARY_INTEGER;
	sop_entrylist tsop_entrylist;

	SUBTYPE typeparamid IS PLS_INTEGER;
	TYPE typeparamlist IS TABLE OF typeparamid;
	TYPE typedataarray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
	TYPE typedatatypesarray IS TABLE OF PLS_INTEGER INDEX BY typeparamid;

	sdataarray typedataarray;
	sparamlist typeparamlist;

	TYPE typeinterestparams IS RECORD(
		 begindate DATE
		,enddate   DATE
		,amount    NUMBER);

	semptyinterestparams typeinterestparams;
	sinterestparams      typeinterestparams;

	TYPE typet2tlinklist IS TABLE OF tcontracttypelink%ROWTYPE INDEX BY BINARY_INTEGER;

	TYPE typelinkparams IS RECORD(
		
		 t2tlinklist  typet2tlinklist
		,linkedscheme tcontractschemas.packagename%TYPE);

	slinkparams typelinkparams;

	TYPE typeregister IS RECORD(
		 register         tcollectioncontracttyperule.register%TYPE
		,registerid       VARCHAR2(100)
		,registercurrency treferencecurrency.currency%TYPE);

	TYPE typeregisterlist IS TABLE OF typeregister INDEX BY PLS_INTEGER;

	TYPE typecollectionperformedaction IS RECORD(
		 actioncode       VARCHAR2(40)
		,contractstate    VARCHAR2(40)
		,feeamount        NUMBER
		,feecurrency      NUMBER
		,feeentrycode     NUMBER
		,feeincomeaccount VARCHAR2(40)
		,description      VARCHAR2(300)
		,registerarray    typeregisterlist);

	scollectperformedaction typecollectionperformedaction;

	TYPE typecollectionactionresult IS RECORD(
		 message      VARCHAR2(300)
		,rollbackdata VARCHAR2(250));

	scollectactionresult typecollectionactionresult;

	SUBTYPE typecollectiondatelist IS types.arrdate;
	sacollectiondatelist typecollectiondatelist;

	TYPE typecontractcollectionstruct IS RECORD(
		 maincontractno tcontract.no%TYPE
		,registerlist   typeregisterlist);

	scontractcollectionstruct typecontractcollectionstruct;

	TYPE typecollectionamount IS RECORD(
		 amount   NUMBER
		,currency treferencecurrency.currency%TYPE);

	scollectionamount typecollectionamount;

	TYPE typecontract2typelink IS RECORD(
		 linkid       tcontract2typelink.linkid%TYPE
		,branch       tcontract2typelink.branch%TYPE
		,contractno   tcontract2typelink.contractno%TYPE
		,contracttype tcontract2typelink.contracttype%TYPE
		,ctname       tcontracttype.name%TYPE
		,clientname   tclientbank.name%TYPE);

	TYPE typeanylink IS RECORD(
		 linktype         PLS_INTEGER
		,kindoftype       PLS_INTEGER
		,linkrelation     NUMBER
		,link_contr2contr tcontractlink%ROWTYPE
		,link_type2type   tcontracttypelink%ROWTYPE
		,link_sch2sch     tcontractschemaslink%ROWTYPE
		,link_contr2type  typecontract2typelink);

	sanylink typeanylink;

	cdateformat CONSTANT VARCHAR2(10) := 'DD/MM/YYYY';

	scontractrow tcontract%ROWTYPE;

	srollbackdata tadjpackrow.rollbackdata%TYPE;

	sobject_type  NUMBER;
	sobject_key   VARCHAR2(100);
	sextractrow   apitypes.typeextractrecord;
	seventrow     apitypes.typeeventrecord;
	sstatementrow apitypes.typestatementfeerecord;
	sdelayrow     apitypes.typeextractdelayrecord;
	sbonusrow     apitypes.typeextractbonusrecord;
	sundorec      tcontractrollback%ROWTYPE;
	sdialog       NUMBER;
	saccountno    VARCHAR2(40);
	sitemcode     NUMBER;
	serrortext    VARCHAR2(250);
	sprevcapdate  DATE;
	senddate      DATE;
	sthandle      NUMBER;
	sinfomode     NUMBER;
	sdocno        NUMBER;
	sentryno      NUMBER;
	semptyrec     apitypes.typeuserproplist;

	sfinruncommission typefinruncommission;

	ssearchdatetype NUMBER;

	fcrediton BOOLEAN;

	fcreditoff BOOLEAN;

	screditsum NUMBER;

	screditoffsum NUMBER;

	fviolationon BOOLEAN;

	fviolationoff BOOLEAN;

	screditprcoffsum NUMBER;

	sasotoperlist       apitypes.typesoperationsysidarray;
	sadebtreservinglist types.arrstr40;

	method_not_found EXCEPTION;
	PRAGMA EXCEPTION_INIT(method_not_found, -06550);

	contract_closed EXCEPTION;
	exccontract_closed CONSTANT PLS_INTEGER := -20310;
	PRAGMA EXCEPTION_INIT(contract_closed, -20310);

	schema_invalid_setup EXCEPTION;
	excschema_invalid_setup CONSTANT PLS_INTEGER := -20320;
	PRAGMA EXCEPTION_INIT(schema_invalid_setup, -20320);

	system_error EXCEPTION;
	excsystem_error CONSTANT PLS_INTEGER := -20399;
	PRAGMA EXCEPTION_INIT(system_error, -20399);

	incorrect_parameter EXCEPTION;
	excincorrect_parameter CONSTANT NUMBER := -20824;
	PRAGMA EXCEPTION_INIT(incorrect_parameter, -20824);

	csop_manualexec CONSTANT NUMBER := 0;
	csop_batchexec  CONSTANT NUMBER := 1;

	SUBTYPE typefschparamid IS VARCHAR2(64);
	SUBTYPE typefschstringvalue IS VARCHAR2(4000);

	TYPE typefschparam IS RECORD(
		 id          typefschparamid
		,CONTEXT     PLS_INTEGER
		,opdate      DATE
		,currency    NUMBER
		,stringvalue typefschstringvalue);

	TYPE typefschparamlist IS TABLE OF typefschparam INDEX BY PLS_INTEGER;

	TYPE accounttypeparams IS RECORD(
		 startdate      DATE
		,intmonth       tcontractacctypeperiod.intmonths%TYPE
		,intdays        tcontractacctypeperiod.intdays%TYPE
		,resident       tcontractacctypeperiod.resident%TYPE
		,currency       tcontractacctypeperiod.currency%TYPE
		,shiftmonthmode NUMBER := 1);

	saccounttypeparams accounttypeparams;

	TYPE typeoperationresult IS RECORD(
		 resultvalue PLS_INTEGER);
	soperresult typeoperationresult;

	TYPE typefillsecurityarrayparams IS RECORD(
		 contracttype tcontracttype.type%TYPE);
	semptyfillsecurityarrayparams typefillsecurityarrayparams;

	saccrefreshlist apitypes.listaccrefreshrow;

	SUBTYPE typetag IS VARCHAR2(30);

	ctagtype_stringvariable CONSTANT NUMBER := 1;
	ctagtype_bindvariable   CONSTANT NUMBER := 2;

	TYPE typeremarktag IS RECORD(
		 tag typetag
		,
		
		tagtype     NUMBER
		,tagdatatype NUMBER
		,
		
		description VARCHAR2(100)
		,active      BOOLEAN := TRUE
		,
		
		tagnumvalue  NUMBER
		,tagdatevalue DATE
		,
		
		tagvalue VARCHAR2(100));
	TYPE typeremarktaglist IS TABLE OF contracttypeschema.typeremarktag INDEX BY typetag;

	saremarktaglist typeremarktaglist;

	TYPE typeoverduerecord IS RECORD(
		 cycle         NUMBER
		,overduedate   DATE
		,overdueamount NUMBER
		,overdueremain NUMBER);

	TYPE typeoverduelist IS TABLE OF typeoverduerecord INDEX BY BINARY_INTEGER;

	saoverduelist typeoverduelist;

	TYPE typekeyvaluelist IS TABLE OF tcontractparameters.value%TYPE INDEX BY tcontractparameters.key%TYPE;
	saprolongationparamnamelist typekeyvaluelist;

	TYPE typechangecontracttypeparams IS RECORD(
		 newtype     tcontracttype.type%TYPE
		,writerbdata BOOLEAN := TRUE);
	schangectparams typechangecontracttypeparams;

	c_oper_undefined       CONSTANT PLS_INTEGER := 0;
	c_oper_canceled        CONSTANT PLS_INTEGER := 1;
	c_oper_completed       CONSTANT PLS_INTEGER := 2;
	c_rollback_supported   CONSTANT PLS_INTEGER := 3;
	c_rollback_unsupported CONSTANT PLS_INTEGER := 4;

	c_contractperiod_indays   CONSTANT typefschparamid := 'CONTRACTPERIOD_INDAYS';
	c_contractperiod_inmonths CONSTANT typefschparamid := 'CONTRACTPERIOD_INMONTHS';
	c_contractstatus          CONSTANT typefschparamid := 'CONTRACT_STATUS';
	c_schema_status           CONSTANT typefschparamid := 'SCHEMA_STATUS';
	c_contract_begindate      CONSTANT typefschparamid := 'CONTRACT_BEGINDATE';
	c_contract_expdate        CONSTANT typefschparamid := 'CONTRACT_EXPDATE';
	c_contract_firstdate      CONSTANT typefschparamid := 'CONTRACT_FIRSTDATE';

	c_contract_overdebt         CONSTANT typefschparamid := 'CONTRACT_OVERDEBT';
	c_contractloan_amount       CONSTANT typefschparamid := 'CONTRACTLOAN_AMOUNT';
	c_overdraft_amount          CONSTANT typefschparamid := 'OVERDRAFT_AMOUNT';
	c_monthly_fee_amount        CONSTANT typefschparamid := 'MONTHLY_FEE_AMOUNT';
	c_monthly_overfee_amount    CONSTANT typefschparamid := 'MONTHLY_OVERFEE_AMOUNT';
	c_delay_limitfee_amount     CONSTANT typefschparamid := 'DELAY_LIMITFEE_AMOUNT';
	c_monthly_limitfee_amount   CONSTANT typefschparamid := 'MONTHLY_LIMITFEE_AMOUNT';
	c_once_limitfee_amount      CONSTANT typefschparamid := 'ONCE_LIMITFEE_AMOUNT';
	c_rest_limitfee_amount      CONSTANT typefschparamid := 'REST_LIMITFEE_AMOUNT';
	c_servicecommission_amount  CONSTANT typefschparamid := 'SERVICECOM_AMOUNT';
	c_transactcommission_amount CONSTANT typefschparamid := 'TRANSACTCOM_AMOUNT';

	c_cashwithdrawal_feerate CONSTANT typefschparamid := 'CASHWITHDRAWAL_FEERATE';
	c_maintenance_feerate    CONSTANT typefschparamid := 'MAINTENANCE_FEERATE';
	c_maintenancefee_amount  CONSTANT typefschparamid := 'MAINTENANCEFEE_AMOUNT';

	c_credit_amount           CONSTANT typefschparamid := 'CREDIT_AMOUNT';
	c_creditforgrace_amount   CONSTANT typefschparamid := 'CREDITFORGRACE_AMOUNT';
	c_creditfornograce_amount CONSTANT typefschparamid := 'CREDITFORNOGRACE_AMOUNT';
	c_creditpaymentdate       CONSTANT typefschparamid := 'CREDIT_PAYMENT_DATE';
	c_credittype              CONSTANT typefschparamid := 'CREDIT_TYPE';
	c_delaycredit_amount      CONSTANT typefschparamid := 'DELAYCREDIT_AMOUNT';
	c_currentcredit           CONSTANT typefschparamid := 'CURRENT_CREDIT';
	c_contractdebt_amount     CONSTANT typefschparamid := 'CONTRACTDEBT_AMOUNT';

	c_closecreditlimit            CONSTANT typefschparamid := 'CREDITLIMIT_CLOSE';
	c_creditlimit                 CONSTANT typefschparamid := 'CREDITLIMIT';
	c_creditlimitrub              CONSTANT typefschparamid := 'CREDITLIMIT_RUB';
	c_creditlimitdate_param       CONSTANT typefschparamid := 'CREDITLIMIT_DATE_PARAM';
	c_creditlimitenddate_calcfrom CONSTANT typefschparamid := 'CREDITLIMITENDDATE_CALCFROM';
	c_creditlimitenddate_indays   CONSTANT typefschparamid := 'CREDITLIMITENDDATE_INDAYS';
	c_creditlimitenddate_inmonths CONSTANT typefschparamid := 'CREDITLIMITENDDATE_INMONTHS';
	c_unusedcreditlimit           CONSTANT typefschparamid := 'UNUSEDCREDITLIMIT';

	c_percent_overaddcreditgrace CONSTANT typefschparamid := 'PERCENT_OVERADDCREDITGRACE';
	c_currcreditpercenttopay     CONSTANT typefschparamid := 'CURR_CREDIT_PERCENT_TOPAY';
	c_currcreditpercent          CONSTANT typefschparamid := 'CURR_CREDIT_PERCENT';
	c_currovercreditpercent      CONSTANT typefschparamid := 'CURR_OVERCREDIT_PERCENT';
	c_currdebtpercent            CONSTANT typefschparamid := 'CURR_DEBTPERCENT';
	c_currdelayoverdraftpercent  CONSTANT typefschparamid := 'CURR_DELAYOVER_PERCENT';
	c_currcrlimitpercent         CONSTANT typefschparamid := 'CURR_CRLIMIT_PERCENT';

	c_percent_credit           CONSTANT typefschparamid := 'PERCENT_CREDIT';
	c_percent_credit2          CONSTANT typefschparamid := 'PERCENT_CREDIT2';
	c_percent_overcredit       CONSTANT typefschparamid := 'PERCENT_OVERCREDIT';
	c_percent_overcredit2      CONSTANT typefschparamid := 'PERCENT_OVERCREDIT2';
	c_percent_overdraft        CONSTANT typefschparamid := 'PERCENT_OVERDRAFT';
	c_percent_overdraft2       CONSTANT typefschparamid := 'PERCENT_OVERDRAFT2';
	c_delaypercent_credit      CONSTANT typefschparamid := 'DELAYPERCENT_CREDIT';
	c_delaypercent_credit2     CONSTANT typefschparamid := 'DELAYPERCENT_CREDIT2';
	c_delaypercent_overcredit  CONSTANT typefschparamid := 'DELAYPERCENT_OVERCREDIT';
	c_delaypercent_overcredit2 CONSTANT typefschparamid := 'DELAYPERCENT_OVERCREDIT2';

	c_percentpaymentdate CONSTANT typefschparamid := 'PERCENT_PAYMENT_DATE';

	c_credit_graceinterestrate   CONSTANT typefschparamid := 'CREDIT_GRACEINTERESTRATE';
	c_credit_highinterestrate    CONSTANT typefschparamid := 'CREDIT_HIGHINTERESTRATE';
	c_credit_maininterestrate    CONSTANT typefschparamid := 'CREDIT_MAININTERESTRATE';
	c_overduecredit_interestrate CONSTANT typefschparamid := 'OVERDUECREDIT_INTERESTRATE';
	c_creditlimit_prcrate        CONSTANT typefschparamid := 'CREDITLIMIT_INTERESTRATE';
	c_creditprcrate              CONSTANT typefschparamid := 'CREDIT_PRCRATE';
	c_overduecredit_feerate      CONSTANT typefschparamid := 'OVERDUECREDIT_FEERATE';
	c_overduecredit_finerate     CONSTANT typefschparamid := 'OVERDUECREDIT_FINERATE';
	c_overduepercent_finerate    CONSTANT typefschparamid := 'OVERDUEPERCENT_FINERATE';
	c_techoverdraftprcrate       CONSTANT typefschparamid := 'TECHOVER_PRCRATE';
	c_averagecardprcrate         CONSTANT typefschparamid := 'AVG_CARD_PRCRATE';

	c_curroverpercentpeny CONSTANT typefschparamid := 'CURR_OVERPERCENT_PENY';
	c_currdebtpeny        CONSTANT typefschparamid := 'CURR_DEBT_PENY';
	c_currovercreditpeny  CONSTANT typefschparamid := 'CURR_OVERCREDIT_PENY';
	c_debt_finerate       CONSTANT typefschparamid := 'DEBT_FINERATE';

	c_ratedatedebtpeny    CONSTANT typefschparamid := 'RATE_DATE_DEBTPENY';
	c_ratedatepercentpeny CONSTANT typefschparamid := 'RATE_DATE_PERCENTPENY';
	c_ratedatecreditpeny  CONSTANT typefschparamid := 'RATE_DATE_CREDITPENY';
	c_curradddebtpeny     CONSTANT typefschparamid := 'CURR_ADDDEBT_PENY';
	c_curraddcreditpeny   CONSTANT typefschparamid := 'CURR_ADDCREDIT_PENY';
	c_curraddpercentpeny  CONSTANT typefschparamid := 'CURR_ADDPERCENT_PENY';

	c_billingcycle_begindate CONSTANT typefschparamid := 'BILLINGCYCLE_BEGINDATE';
	c_billingcycle_enddate   CONSTANT typefschparamid := 'BILLINGCYCLE_ENDDATE';
	c_billingcycle_indays    CONSTANT typefschparamid := 'BILLINGCYCLE_INDAYS';
	c_billingcycle_inmonths  CONSTANT typefschparamid := 'BILLINGCYCLE_INMONTHS';
	c_billingcycle_startday  CONSTANT typefschparamid := 'BILLINGCYCLE_STARTDAY';
	c_statementdate_last     CONSTANT typefschparamid := 'STATEMENTDATE_LAST';
	c_statementdate_next     CONSTANT typefschparamid := 'STATEMENTDATE_NEXT';
	c_paymentduedate         CONSTANT typefschparamid := 'PAYMENTDUEDATE';
	c_paymentperiod_indays   CONSTANT typefschparamid := 'PAYMENTPERIOD_INDAYS';
	c_paymentperiod_inmonths CONSTANT typefschparamid := 'PAYMENTPERIOD_INMONTHS';
	c_statementdate          CONSTANT typefschparamid := 'STATEMENTDATE';
	c_lastchargeinterestdate CONSTANT typefschparamid := 'LAST_CHARGEINERESTDATE';
	c_billingcycle_counts    CONSTANT typefschparamid := 'BILLINGCYCLE_COUNT';

	crvpfschparamidprefix CONSTANT contracttypeschema.typefschparamid := 'RVP_';

	c_ratecat     CONSTANT typefschparamid := 'RATE_CAT';
	c_portfcredit CONSTANT typefschparamid := 'PORTF_CREDIT';
	c_reserverate CONSTANT typefschparamid := 'RESERVE_RATE';

	c_countdelcredit  CONSTANT typefschparamid := 'COUNT_DEL_CREDIT';
	c_countprcdel     CONSTANT typefschparamid := 'COUNT_DEL_PRC';
	c_violationscount CONSTANT typefschparamid := 'VIOLATIONSCOUNT';

	c_graceperiod_calcfrom CONSTANT typefschparamid := 'GRACEPERIOD_CALCFROM';
	c_graceperiod_param    CONSTANT typefschparamid := 'GRACEPERIOD_PARAM';
	c_graceperiod_end      CONSTANT typefschparamid := 'GRACEPERIOD_END';
	c_graceperiod_type     CONSTANT typefschparamid := 'GRACEPERIOD_TYPE';
	c_graceperiod_active   CONSTANT typefschparamid := 'GRACEPERIOD_ACTIVE';

	c_minpayment_used        CONSTANT typefschparamid := 'MINPAYMENT_USED';
	c_minpayment_amount      CONSTANT typefschparamid := 'MINPAYMENT_AMOUNT';
	c_minpayment_prc_amount  CONSTANT typefschparamid := 'MINPAYMENT_PRC_AMOUNT';
	c_minpayment_fixedamount CONSTANT typefschparamid := 'MINPAYMENT_FIXEDAMOUNT';
	c_minpayment_percent     CONSTANT typefschparamid := 'MINPAYMENT_PERCENT';
	c_minpayment_graceperiod CONSTANT typefschparamid := 'MINPAYMENT_GRACEPERIOD';

	c_deposit_amount             CONSTANT typefschparamid := 'DEPOSIT_AMOUNT';
	c_deposit_reserve            CONSTANT typefschparamid := 'DEPOSIT_RESERVE';
	c_deposit_amount_ondenounce  CONSTANT typefschparamid := 'DEPOSIT_AMOUNT_ONDENOUNCE';
	c_deposit_futurepercentonpay CONSTANT typefschparamid := 'DEPOSIT_FUTURE_PERCENT_ON_PAY';
	c_deposit_interestrate       CONSTANT typefschparamid := 'DEPOSIT_INT_RATE';

	c_insurancedeposit          CONSTANT typefschparamid := 'INSURANCEDEPOSIT';
	c_insdeposit_interestrate   CONSTANT typefschparamid := 'DEPOSIT_INS_INT_RATE';
	c_deposit_lowremain         CONSTANT typefschparamid := 'DEPOSIT_LOWREMAIN';
	c_deposit_ndfl_ret          CONSTANT typefschparamid := 'DEPOSIT_NDFL_RET';
	c_depositinterest_amount    CONSTANT typefschparamid := 'DEPOSIT_INT_AMOUNT';
	c_depositinterest_current   CONSTANT typefschparamid := 'DEPOSIT_INT_CURRENT';
	c_deposit_permit_withdrawal CONSTANT typefschparamid := 'DEPOSIT_PERMIT_WITHDRAWAL';
	c_deposit_writeoff_account  CONSTANT typefschparamid := 'DEPOSIT_WRITEOFF_ACCOUNT';
	c_interest_paymentdate      CONSTANT typefschparamid := 'INTEREST_PAYDATE';
	c_minimumdeposit_amount     CONSTANT typefschparamid := 'MINIMUMDEPOSIT_AMOUNT';
	c_minimumdeposit_period     CONSTANT typefschparamid := 'MINIMUMDEPOSIT_PERIOD';

	FUNCTION readpackageinfo
	(
		ppackagename IN custom_fintypes.typepackagename
	   ,opackageinfo OUT custom_fintypes.typepackageinfo
	) RETURN BOOLEAN;
	/*FUNCTION getpackageinfo
    (
        ppackagename IN custom_fintypes.typepackagename
       ,pdoexception BOOLEAN := TRUE
    ) RETURN custom_fintypes.typepackageinfo;
    
    PROCEDURE addpackageaboutinfo
    (
        poaaboutinfo  IN OUT NOCOPY types.arrstr100
       ,ppackagename  IN custom_fintypes.typepackagename
       ,paddemptyline BOOLEAN := TRUE
       ,plevel        PLS_INTEGER := 2
    );*/

	--FUNCTION getschemaabout(ppackagename IN custom_fintypes.typepackagename) RETURN types.arrstr100;

	FUNCTION getversion RETURN VARCHAR2;

	FUNCTION getpackageinfo RETURN custom_fintypes.typepackageinfo;
	/*
    FUNCTION deletecontract
    (
        pcontractno IN tcontract.no%TYPE
       ,pmode       IN PLS_INTEGER := NULL
    ) RETURN typeoperationresult;*/

	/*  PROCEDURE oncreatecontract
              (
                  pcontractno custom_fintypes.typecontractno
                 ,pschparams  VARCHAR2
              );
              PROCEDURE oncreatecontract
              (
                  pcontractrow custom_fintypes.typecontractrow
                 ,pschparams   VARCHAR2
              );
          
              PROCEDURE onundocreatecontract
              (
                  pcontractno custom_fintypes.typecontractno
                 ,prbdata     VARCHAR2
              );
              PROCEDURE onundocreatecontract
              (
                  pcontractrow custom_fintypes.typecontractrow
                 ,prbdata      VARCHAR2
              );
         
          PROCEDURE oncreateaccounts
          (
              pcontractno custom_fintypes.typecontractno
             ,pmode       custom_contract.typeaddaccountmode
             ,pschparams  VARCHAR2
             ,poaaccounts IN OUT contract.typeaccountarray
          );
          PROCEDURE oncreateaccounts
          (
              pcontractrow custom_fintypes.typecontractrow
             ,pmode        custom_contract.typeaddaccountmode
             ,pschparams   VARCHAR2
             ,poaaccounts  IN OUT custom_contract.typeaccountarray
          );
       
          PROCEDURE oncreateaccount
          (
              pcontractno custom_fintypes.typecontractno
             ,poaccount   IN OUT contract.typeaccountrow
          );
      
       FUNCTION getcardaccountlist
       (
           pcontractno     IN tcontract.no%TYPE
          ,praiseexception IN BOOLEAN := TRUE
       ) RETURN apitypes.typeaccount2cardlist;
    */
	FUNCTION getmainaccount
	(
		pno       IN tcontract.no%TYPE
	   ,pcurrency IN treferencecurrency.currency%TYPE
	) RETURN taccount.accountno%TYPE;

	FUNCTION closecontract
	(
		pcontractno VARCHAR2
	   ,pparams     tclosecontractparamrec
	) RETURN contractrb.trollbackdata;

	PROCEDURE undoclosecontract
	(
		pcontractno   VARCHAR2
	   ,prollbackdata VARCHAR2
	);

	PROCEDURE changecontractno
	(
		poldcontractno IN tcontract.no%TYPE
	   ,pnewcontractno IN tcontract.no%TYPE
	   ,poldtype       IN tcontracttype.type%TYPE
	);

	PROCEDURE changecontractparams
	(
		pcontractno     IN tcontract.no%TYPE
	   ,pcontracttype   IN tcontracttype.type%TYPE
	   ,pafschparamlist IN typefschparamlist
	);

	FUNCTION changecontractparams
	(
		pcontractno        IN VARCHAR2
	   ,pnewcontractparams IN contract.typecontractrow
	   ,pcontuserdata      IN apitypes.typeuserproplist := semptyrec
	) RETURN NUMBER;

	FUNCTION undochangecontractparams
	(
		pcontractno   IN VARCHAR2
	   ,pcontuserdata IN apitypes.typeuserproplist := semptyrec
	) RETURN NUMBER;

	PROCEDURE exectemplate
	(
		pcontractno   IN tcontract.no%TYPE
	   ,ptemplateid   IN NUMBER
	   ,orunprintform OUT NUMBER
	);

	PROCEDURE changecontracttype
	(
		pcontractno     IN tcontract.no%TYPE
	   ,pchangectparams IN typechangecontracttypeparams
	);

	PROCEDURE changecontracttype_post
	(
		pcontractno     IN tcontract.no%TYPE
	   ,pchangectparams IN typechangecontracttypeparams
	);

	FUNCTION getaccounttypeforchange
	(
		pcontractno       IN tcontract.no%TYPE
	   ,pcontracttypefrom IN tcontracttype.type%TYPE
	   ,pcontracttypeto   IN tcontracttype.type%TYPE
	   ,pitemname         IN tcontracttypeitemname.itemname%TYPE
	) RETURN taccount.accounttype%TYPE;

	PROCEDURE autocreate_makelink
	(
		pmaincontract   IN tcontract.no%TYPE
	   ,plinkedcontract IN tcontract.no%TYPE
	);

	PROCEDURE applylinkaction
	(
		pschemepackage IN VARCHAR2
	   ,panylink       IN typeanylink
	   ,paction        IN NUMBER
	);

	FUNCTION getschemapackagebycontractno(pcontractno IN VARCHAR2) RETURN VARCHAR2;

	FUNCTION getinterestbydate
	(
		pcontractno     IN tcontract.no%TYPE
	   ,pkindofaccount  IN NUMBER
	   ,pinterestparams IN typeinterestparams := semptyinterestparams
	) RETURN typeinterestlist;

	FUNCTION getoverdueremainlist
	(
		pcontractno IN tcontract.no%TYPE
	   ,pondate     IN DATE
	   ,ponlyfixed  IN BOOLEAN := FALSE
	) RETURN typeoverduelist;

	PROCEDURE getcontractinformation
	(
		pcontractno      IN tcontract.no%TYPE
	   ,poafschparamlist IN OUT typefschparamlist
	);

	FUNCTION getcontractinformation
	(
		pcontractno  IN tcontract.no%TYPE
	   ,pfschparamid IN typefschparamid
	   ,pstartdate   DATE := NULL
	   ,penddate     DATE := NULL
	) RETURN VARCHAR2;

	FUNCTION getdataforreport
	(
		pno             IN VARCHAR2
	   ,pstartdate      IN DATE
	   ,penddate        IN DATE
	   ,pmaxcount       IN NUMBER
	   ,parchive        BOOLEAN := FALSE
	   ,pneedremain     BOOLEAN := TRUE
	   ,psearchdatetype NUMBER := coper_date
	) RETURN NUMBER;

	PROCEDURE execdialogproc
	(
		pcontractno IN VARCHAR2
	   ,pwhat       IN CHAR
	   ,pdialog     IN NUMBER
	   ,pitemname   IN VARCHAR2
	   ,pcmd        IN NUMBER
	);

	FUNCTION contractpost(pno IN VARCHAR2) RETURN NUMBER;

	FUNCTION addparameterpage
	(
		pdialog       IN NUMBER
	   ,ppagelist     IN VARCHAR2
	   ,pparamstype   IN NUMBER
	   ,pcontractno   IN tcontract.no%TYPE
	   ,pcontracttype IN tcontracttype.type%TYPE
	) RETURN NUMBER;

	FUNCTION validparameterpage
	(
		pdialog       IN NUMBER
	   ,pparamstype   IN NUMBER
	   ,pcontractno   IN tcontract.no%TYPE
	   ,pcontracttype IN tcontracttype.type%TYPE
	) RETURN BOOLEAN;

	PROCEDURE saveparameterpage
	(
		pdialog       IN NUMBER
	   ,pparamstype   IN NUMBER
	   ,pcontractno   IN tcontract.no%TYPE
	   ,pcontracttype IN tcontracttype.type%TYPE
	);

	PROCEDURE drawinfopanel
	(
		phandle    IN NUMBER
	   ,pdialog    IN NUMBER
	   ,ppanelname IN VARCHAR2
	);

	PROCEDURE fillinfopanel
	(
		phandle    IN NUMBER
	   ,pdialog    IN NUMBER
	   ,ppanelname IN VARCHAR2
	);

	FUNCTION importcontracttype
	(
		pctypefrom NUMBER
	   ,pctypeto   NUMBER
	) RETURN NUMBER;

	FUNCTION getmainitemcode(pctype IN NUMBER) RETURN NUMBER;

	FUNCTION autocreate_paramdialog
	(
		pmode         IN PLS_INTEGER
	   ,pmaintype     IN tcontracttype.type%TYPE
	   ,plinkedscheme IN tcontractschemas.packagename%TYPE
	   ,plinkparams   IN OUT typelinkparams
	) RETURN NUMBER;

	PROCEDURE fillitemaccountarray(ppackage IN VARCHAR2);
	PROCEDURE fillitemaccountarray
	(
		ppackage       IN VARCHAR2
	   ,oaaccountarray OUT NOCOPY titemaccarray
	);

	FUNCTION initadjusting
	(
		pcontracttype IN tcontracttype.type%TYPE
	   ,pprepareexec  IN BOOLEAN := TRUE
	) RETURN NUMBER;

	FUNCTION execadjusting(ppackno tadjpack.packno%TYPE) RETURN NUMBER;

	PROCEDURE downadjusting;

	PROCEDURE initializeadjusting;

	PROCEDURE finalizeadjusting;

	FUNCTION getinitcontracttype RETURN NUMBER;

	FUNCTION initundoadjusting(pcontracttype IN NUMBER) RETURN NUMBER;

	FUNCTION undoadjusting RETURN NUMBER;

	PROCEDURE downundoadjusting;

	FUNCTION initaggregate RETURN NUMBER;
	FUNCTION initaggregate(pctype IN NUMBER) RETURN NUMBER;

	FUNCTION execaggregate
	(
		pcontractno IN VARCHAR2
	   ,pitemcode   IN NUMBER
	   ,paccountno  IN VARCHAR2
	) RETURN NUMBER;
	FUNCTION execaggregate
	(
		pcontractno IN VARCHAR2
	   ,pitemcode   IN NUMBER
	   ,paccountno  IN VARCHAR2
	   ,oparams     OUT taggroutparams
	) RETURN NUMBER;

	PROCEDURE execaggregatepost(poaccrefreshlist IN OUT apitypes.listaccrefreshrow);

	PROCEDURE downaggregate(pctype IN NUMBER);
	PROCEDURE downaggregate;

	FUNCTION fillaggregateacctype
	(
		ptype     IN NUMBER
	   ,pitemcode IN NUMBER
	) RETURN NUMBER;

	FUNCTION initcapitalise
	(
		pcontracttype IN NUMBER
	   ,pitemcode     IN NUMBER
	   ,pdate         IN DATE
	   ,pfrom         IN NUMBER
	) RETURN NUMBER;

	FUNCTION execcapitalise
	(
		pcontractno IN VARCHAR2
	   ,penddate    IN DATE := NULL
	   ,pthandle    IN NUMBER := NULL
	   ,pinfomode   IN NUMBER := 1
	) RETURN NUMBER;

	PROCEDURE downcapitalise;

	FUNCTION fillcaparray(pctype IN NUMBER) RETURN NUMBER;

	FUNCTION filloperlist
	(
		pcontracttype IN NUMBER
	   ,pdialog       IN NUMBER
	   ,pitemname     IN VARCHAR2
	) RETURN NUMBER;

	FUNCTION executeoperation
	(
		pcontractno    IN tcontract.no%TYPE
	   ,poperationcode IN VARCHAR2
	) RETURN typeoperationresult;

	FUNCTION initoper
	(
		pctype  IN NUMBER
	   ,popcode NUMBER
	) RETURN NUMBER;
	FUNCTION execoper(pcontractno IN VARCHAR2) RETURN NUMBER;
	PROCEDURE downoper(pctype IN NUMBER);

	FUNCTION initundooper
	(
		pctype  IN NUMBER
	   ,popcode NUMBER
	) RETURN NUMBER;
	FUNCTION execundooper(pcontractno IN VARCHAR2) RETURN NUMBER;
	PROCEDURE downundooper(pctype IN NUMBER);

	PROCEDURE opinit;
	PROCEDURE oppreexec
	(
		pobjecttype IN NUMBER
	   ,pkey        IN VARCHAR2
	);
	PROCEDURE oppostexec
	(
		pobjecttype   IN NUMBER
	   ,pkey          IN VARCHAR2
	   ,pdonemanually IN BOOLEAN := FALSE
	);
	PROCEDURE oppreundo
	(
		pobjecttype IN NUMBER
	   ,pkey        IN VARCHAR2
	);
	PROCEDURE oppostundo
	(
		pobjecttype IN NUMBER
	   ,pkey        IN VARCHAR2
	);
	PROCEDURE opdown;
	PROCEDURE opdelete
	(
		pobjecttype IN NUMBER
	   ,pkey        IN VARCHAR2
	   ,pall        BOOLEAN := FALSE
	);

	FUNCTION cancontractmakepayment(pcontractno IN VARCHAR2) RETURN BOOLEAN;

	FUNCTION reserveforpayment(pregpaycontractrec IN OUT apipayment.tregpaycontractrec) RETURN NUMBER;

	FUNCTION unreserveforpayment(pregpaycontractrec IN apipayment.tregpaycontractrec) RETURN NUMBER;

	FUNCTION executepayment
	(
		pstage             NUMBER
	   ,pparams            toperpaymentparams
	   ,pregpaycontractrec IN OUT apipayment.tregpaycontractrec
	) RETURN NUMBER;

	FUNCTION getmainaccountlist(pcontractno IN tcontract.no%TYPE) RETURN contract.typeaccountarray;

	FUNCTION requestclose
	(
		pcontractno IN VARCHAR2
	   ,paccountno  IN VARCHAR2
	   ,preqno      IN NUMBER
	   ,psumma      IN NUMBER
	   ,pentcode    IN NUMBER
	) RETURN NUMBER;
	FUNCTION fillcloseentrylist(pcontractno IN VARCHAR2) RETURN NUMBER;
	FUNCTION contractadd
	(
		pcontractno IN VARCHAR2
	   ,preqno      IN NUMBER
	) RETURN NUMBER;
	FUNCTION contractsub
	(
		pcontractno IN VARCHAR2
	   ,preqno      IN NUMBER
	) RETURN NUMBER;
	FUNCTION contractclose
	(
		pcontractno IN VARCHAR2
	   ,pparameters IN VARCHAR2
	   ,preqno      IN NUMBER
	) RETURN NUMBER;

	PROCEDURE sop_preexec
	(
		pdocno    IN OUT NUMBER
	   ,pno       IN OUT NUMBER
	   ,pparams   IN OUT tsop_params
	   ,pexecmode IN NUMBER := csop_manualexec
	);

	PROCEDURE sop_postexec
	(
		pdocno    IN OUT NUMBER
	   ,pno       IN OUT NUMBER
	   ,pparams   IN tsop_params
	   ,pexecmode IN NUMBER := csop_manualexec
	);

	PROCEDURE sop_acceptpreexec
	(
		pcontractno      IN VARCHAR2
	   ,pparams          IN tsop_params
	   ,pacceptentrylist IN OUT tsop_entrylist
	);

	PROCEDURE sop_acceptpostexec
	(
		pcontractno      IN VARCHAR2
	   ,pparams          IN tsop_params
	   ,pacceptentrylist IN OUT tsop_entrylist
	);

	PROCEDURE sop_init;

	PROCEDURE sop_down;

	PROCEDURE initgetdata4dc(pcontracttype IN NUMBER);

	PROCEDURE execgetdata4dc
	(
		pcontractno   IN VARCHAR2
	   ,pcontractsh   IN OUT apitypesfordc.typecontractsnapshotrecord
	   ,pitemsshlist  IN apitypesfordc.typecontractitemshapshotlist
	   ,pcontractrec  OUT apitypesfordc.typecontractrecord
	   ,pitemslist    OUT apitypesfordc.typecontractitemlist
	   ,ptranslist    OUT apitypesfordc.typedctranslist
	   ,prollbackdata OUT VARCHAR2
	   ,poverduelist  OUT apitypesfordc.typecontractoverduelist
	);

	PROCEDURE downgetdata4dc(pcontracttype IN NUMBER);

	PROCEDURE undogetdata4dc
	(
		pcontractno   IN VARCHAR2
	   ,prollbackdata IN VARCHAR2
	);

	PROCEDURE complyrequest
	(
		pactions      IN apitypesfordc.typeactionrecord
	   ,prollbackdata OUT VARCHAR2
	);

	PROCEDURE undocomplyrequest
	(
		pactions      IN apitypesfordc.typeactionrecord
	   ,prollbackdata IN VARCHAR2
	);

	PROCEDURE getstatelist4dc
	(
		pcontracttype IN NUMBER
	   ,pstatelist    OUT apitypesfordc.typecontractstatelist
	);

	FUNCTION getcontractstatelist(pcontractno IN tcontract.no%TYPE)
		RETURN apitypesfordc.typecontractstatelist;

	FUNCTION atmgetcontractinfo(precinfo IN tcontractquery) RETURN tatminfoarray;

	FUNCTION getcontractinfo(pparams trequestrecord) RETURN NUMBER;

	FUNCTION checkpossibilitycrd_stat
	(
		ppan     IN tcard.pan%TYPE
	   ,pmbr     IN tcard.mbr%TYPE
	   ,poldstat IN tcard.crd_stat%TYPE
	   ,pnewstat IN tcard.crd_stat%TYPE
	) RETURN BOOLEAN;
	FUNCTION checkpossibilitysignstat
	(
		ppan     IN tcard.pan%TYPE
	   ,pmbr     IN tcard.mbr%TYPE
	   ,poldsign IN tcard.signstat%TYPE
	   ,pnewsign IN tcard.signstat%TYPE
	) RETURN BOOLEAN;

	PROCEDURE initgetdata4vcf(pcontracttype IN tcontracttype.type%TYPE);

	FUNCTION execgetperiod4vcf
	(
		pcontractno IN tcontract.no%TYPE
	   ,pbegindate  IN DATE := NULL
	) RETURN apitypesforvcf.typeperiodlist;

	FUNCTION execgetbalance4vcf
	(
		pcontractno IN tcontract.no%TYPE
	   ,penddate    IN DATE
	) RETURN apitypesforvcf.typebalancelist;

	PROCEDURE downgetdata4vcf(pcontracttype IN tcontracttype.type%TYPE);

	PROCEDURE execservicefeepayment
	(
		pdocno          IN OUT tentry.docno%TYPE
	   ,pentryno        IN OUT tentry.no%TYPE
	   ,pbonusaccountno IN taccount.accountno%TYPE
	   ,paccountno      IN taccount.accountno%TYPE
	   ,pexchrate       IN NUMBER
	   ,pamount         IN OUT NUMBER
	   ,pentrycode      IN treferenceentry.code%TYPE
	);

	PROCEDURE fillsecurityarray
	(
		pschemepackage IN tcontractschemas.packagename%TYPE
	   ,popercode      IN VARCHAR2
	   ,pparams        IN typefillsecurityarrayparams := semptyfillsecurityarrayparams
	);

	FUNCTION initsotoperlist RETURN apitypes.typesoperationsysidarray;

	PROCEDURE getsotoperlist
	(
		pcontracttype  IN NUMBER
	   ,poasotoperlist IN OUT apitypes.typesoperationsysidarray
	);

	FUNCTION needstatementgenerate
	(
		pcontractno IN VARCHAR2
	   ,pprevdate   IN OUT DATE
	   ,pcurdate    IN DATE
	   ,pperiodtype IN NUMBER
	) RETURN BOOLEAN;

	FUNCTION getclientmenuitems(pclientparams IN typeclientparams := semptyclientparams)
		RETURN typeclientmenuitemlist;

	PROCEDURE execclientmenuitem(pclientparams IN typeclientparams);

	FUNCTION getrollbackdata RETURN VARCHAR2;

	FUNCTION existrollbackdata RETURN BOOLEAN;

	FUNCTION getlabeldescription
	(
		pcontractno IN tcontract.no%TYPE
	   ,plabel      IN contractrb.tlabel
	) RETURN VARCHAR2;

	FUNCTION getlabeldescription
	(
		pcontractno IN tcontract.no%TYPE
	   ,plabel      IN VARCHAR2
	) RETURN VARCHAR2;

	PROCEDURE undolabel
	(
		pcontractno tcontract.no%TYPE
	   ,plabel      contractrb.tlabel
	);

	FUNCTION getcontractstructure(pcontractno IN tcontract.no%TYPE) RETURN typecontractcollectionstruct;

	FUNCTION collectionrulesetupdialog
	(
		pcontracttype IN tcontracttype.type%TYPE
	   ,pregister     IN tcollectioncontracttyperule.register%TYPE
	   ,pruleid       IN tcollectioncontracttyperule.ruleid%TYPE
	   ,oinuse        OUT BOOLEAN
	) RETURN NUMBER;

	FUNCTION collectioncheckrule
	(
		pcontractno IN tcontract.no%TYPE
	   ,pregister   IN tcollectioncontracttyperule.register%TYPE
	   ,pruleid     IN tcollectioncontracttyperule.ruleid%TYPE
	) RETURN NUMBER;

	FUNCTION collectiongetcontractamount
	(
		pcontractno IN tcontract.no%TYPE
	   ,pregister   IN tcollectioncontracttyperule.register%TYPE
	   ,pregisterid IN tcollectioncontractrules.registerid%TYPE
	   ,pamountcode IN NUMBER
	   ,oamount     OUT typecollectionamount
	) RETURN NUMBER;

	FUNCTION getrepaymentamount
	(
		pcontractno IN tcontract.no%TYPE
	   ,pstartdate  IN DATE
	   ,penddate    IN DATE
	) RETURN typecollectionamount;

	FUNCTION getruleblock
	(
		pschemepackage IN tcontractschemas.packagename%TYPE
	   ,pruleid        IN tcollectioncontracttyperule.ruleid%TYPE
	) RETURN VARCHAR2;

	FUNCTION getcyclecalendar
	(
		pcontractno IN tcontract.no%TYPE
	   ,pstartdate  IN DATE
	   ,pendcycle   IN NUMBER
	) RETURN typecollectiondatelist;

	FUNCTION collectionperformaction
	(
		pcontractno      IN tcontract.no%TYPE
	   ,pperformedaction IN typecollectionperformedaction
	   ,oactionresult    OUT typecollectionactionresult
	) RETURN NUMBER;

	FUNCTION collectionrollbackaction
	(
		pcontractno   IN tcontract.no%TYPE
	   ,pactioncode   IN VARCHAR2
	   ,prollbackdata IN VARCHAR2
	   ,oactionresult OUT typecollectionactionresult
	) RETURN NUMBER;

	FUNCTION getdebtreservinglist RETURN types.arrstr40;

	PROCEDURE getremarktaglist
	(
		pschemepackage IN VARCHAR2
	   ,pcontext       IN PLS_INTEGER
	   ,ptaglist       IN OUT typeremarktaglist
	);

	PROCEDURE getremarkvalues
	(
		pschemepackage IN VARCHAR2
	   ,ptaglist       IN OUT typeremarktaglist
	);

	FUNCTION remarktaglistitem
	(
		ptag          typetag
	   ,ptagtype      NUMBER := NULL
	   ,ptagdatatype  NUMBER := NULL
	   ,pdescription  VARCHAR2 := NULL
	   ,pactive       BOOLEAN := TRUE
	   ,ptagnumvalue  NUMBER := NULL
	   ,ptagdatevalue DATE := NULL
	   ,ptagvalue     VARCHAR2 := NULL
	) RETURN typeremarktag;

	FUNCTION getcontractoperations
	(
		pno        IN VARCHAR2
	   ,pstartdate IN DATE
	   ,penddate   IN DATE
	   ,parchive   NUMBER := 0
	) RETURN tentryarray;

	FUNCTION getentryarray RETURN tentryarray;
	PROCEDURE setentryarray(paentryarray IN tentryarray);

	PROCEDURE entrydopre
	(
		pdocno    IN OUT NUMBER
	   ,pno       IN OUT NUMBER
	   ,pparams   IN OUT tsop_params
	   ,pexecmode IN NUMBER := csop_batchexec
	);

	PROCEDURE entrydopost
	(
		pdocno    IN OUT NUMBER
	   ,pno       IN OUT NUMBER
	   ,pparams   IN OUT tsop_params
	   ,pexecmode IN NUMBER := csop_batchexec
	);

	PROCEDURE entryundoinit(poentryprops IN OUT typeentryproperties);

	PROCEDURE entryundodone(poentryprops IN OUT typeentryproperties);
	PROCEDURE entryundopre(poentryprops IN OUT typeentryproperties);
	PROCEDURE entryundopost(poentryprops IN OUT typeentryproperties);

	PROCEDURE entryrestorepre
	(
		pmode      IN NUMBER
	   ,pcheck     IN NUMBER
	   ,pdocno     IN NUMBER
	   ,pno        IN NUMBER
	   ,pvalue     IN NUMBER
	   ,pacchandle IN NUMBER
	);
	PROCEDURE entryrestorepost
	(
		pmode      IN NUMBER
	   ,pcheck     IN NUMBER
	   ,pdocno     IN NUMBER
	   ,pno        IN NUMBER
	   ,pvalue     IN NUMBER
	   ,pacchandle IN NUMBER
	);

	PROCEDURE tran_postexec(pdocno IN NUMBER);

	FUNCTION getobjecttype(pobjectname IN VARCHAR2) RETURN NUMBER;

	FUNCTION canlinkaccttocust(paccountno IN taccount.accountno%TYPE) RETURN BOOLEAN;

	FUNCTION getaccounttypeparams
	(
		pcontractno IN tcontract.no%TYPE
	   ,pitemname   IN tcontracttypeitemname.itemname%TYPE
	) RETURN accounttypeparams;

	FUNCTION getprolongationparamnamelist(pcontractno IN tcontract.no%TYPE) RETURN typekeyvaluelist;
END;
/
CREATE OR REPLACE PACKAGE BODY custom_contracttypeschema AS

	cpackage_name CONSTANT VARCHAR2(100) := 'ContractTypeSchema';

	cbodyversion CONSTANT VARCHAR2(10) := '22.01.01';

	cbodydate CONSTANT DATE := to_date('01.12.2022', 'DD.MM.YYYY');

	cbodytwcms CONSTANT VARCHAR2(50) := '4.15.88';

	cbodyrevision CONSTANT VARCHAR2(100) := '$Rev: 62408 $';

	csay_level CONSTANT NUMBER := 5;

	SUBTYPE typemethodname IS VARCHAR2(100);

	TYPE tarrvarchar IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

	call_function  CONSTANT NUMBER := 1;
	call_procedure CONSTANT NUMBER := 2;

	sparsestr VARCHAR2(512);

	scontracttype types.arrnum;
	spackage      tarrvarchar;
	spackagetemp  VARCHAR2(255);
	sexecret      NUMBER;
	scontractno   tcontract.no%TYPE;

	SUBTYPE typesop_cursor IS VARCHAR2(100);

	ctran_postexec    CONSTANT NUMBER := 1;
	centryundopre     CONSTANT NUMBER := 2;
	csop_preexec      CONSTANT NUMBER := 3;
	csop_postexec     CONSTANT NUMBER := 4;
	centryrestorepre  CONSTANT NUMBER := 5;
	centryrestorepost CONSTANT NUMBER := 6;
	centryundopost    CONSTANT NUMBER := 7;

	coppreexec   CONSTANT NUMBER := 8;
	coppreexec2  CONSTANT NUMBER := 9;
	centrydopre  CONSTANT NUMBER := 10;
	coppostexec  CONSTANT NUMBER := 11;
	coppostexec2 CONSTANT NUMBER := 12;
	centrydopost CONSTANT NUMBER := 13;
	coppreundo   CONSTANT NUMBER := 14;
	coppostundo  CONSTANT NUMBER := 15;

	cexecadjusting CONSTANT NUMBER := 16;
	cundoadjusting CONSTANT NUMBER := 17;

	cexecres_unsupported CONSTANT NUMBER := 1;
	cexecres_supported   CONSTANT NUMBER := 2;

	ctransferprefix CONSTANT VARCHAR2(4) := '_TSF';

	TYPE typetran_cursor IS RECORD(
		 supported BOOLEAN
		,cursorid  NUMBER);
	TYPE typetran_cursorarray IS TABLE OF typetran_cursor INDEX BY BINARY_INTEGER;
	satran_cursorarray typetran_cursorarray;

	TYPE typesop_cursorsarray IS TABLE OF typetran_cursor INDEX BY typesop_cursor;

	sasop_cursors          typesop_cursorsarray;
	saentryundopre_cursors typesop_cursorsarray;
	saentryrestore_cursors typesop_cursorsarray;
	sacursors              typesop_cursorsarray;

	TYPE typesop_parameter IS RECORD(
		 contractno tcontract.no%TYPE
		,docno      NUMBER
		,no         NUMBER
		,params     tsop_params
		,
		
		retvalue NUMBER
		
		);

	SUBTYPE typestr4index IS VARCHAR2(500);
	TYPE typeentrypropertieslist IS TABLE OF typeentryproperties INDEX BY typestr4index;

	saentrypropertieslist typeentrypropertieslist;

	TYPE tobjecttype IS RECORD(
		 extract        NUMBER
		,event          NUMBER
		,statementrt    NUMBER
		,finprofile     NUMBER
		,loyaltyprogram NUMBER);
	sobjtype tobjecttype;

	TYPE typecurrenttransaction IS RECORD(
		 contractno   tcontract.no%TYPE
		,contracttype tcontract.type%TYPE
		,packname     tcontractschemas.packagename%TYPE
		,contractno2  tcontract.no%TYPE
		,packname2    tcontractschemas.packagename%TYPE);
	TYPE typecurrenttransactionarray IS TABLE OF typecurrenttransaction INDEX BY VARCHAR2(100);

	cfinprofileindex CONSTANT VARCHAR2(15) := 'FINPROFILEINDEX';

	sacurrenttransaction typecurrenttransactionarray;

	TYPE typesop_contractlist IS TABLE OF tcontractschemas.packagename%TYPE INDEX BY VARCHAR2(40);
	sasop_contractlist typesop_contractlist;

	FUNCTION getversion RETURN VARCHAR2 IS
	BEGIN
		RETURN service.formatpackageversion(cpackage_name, cheaderrevision, cbodyrevision);
	END;

	FUNCTION getpackageinfo RETURN custom_fintypes.typepackageinfo IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.GetPackageInfo';
		vresult custom_fintypes.typepackageinfo;
	BEGIN
		t.enter(cmethodname);
	
		vresult.packagename  := cpackage_name;
		vresult.packagedescr := cpackagedescr;
	
		vresult.headerversion  := cheaderversion;
		vresult.headerdate     := cheaderdate;
		vresult.headertwcms    := cheadertwcms;
		vresult.headerrevision := cheaderrevision;
	
		vresult.bodyversion  := cbodyversion;
		vresult.bodydate     := cbodydate;
		vresult.bodytwcms    := cbodytwcms;
		vresult.bodyrevision := cbodyrevision;
	
		t.leave(cmethodname);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getpackageinfo;

	PROCEDURE cleararrays IS
	BEGIN
		scontracttype.delete;
		spackage.delete;
	END;

	FUNCTION isarrayitemsnotnull(pindex NUMBER) RETURN BOOLEAN IS
	BEGIN
		RETURN scontracttype.exists(pindex) AND scontracttype(pindex) IS NOT NULL AND spackage.exists(pindex) AND spackage(pindex) IS NOT NULL;
	END;

	FUNCTION sop_getcursorindex
	(
		ppackage  IN VARCHAR2
	   ,pproccode IN NUMBER
	) RETURN VARCHAR2
	
	 IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.SOP_GetCursorIndex';
	BEGIN
		CASE pproccode
			WHEN ctran_postexec THEN
				RETURN ppackage || '.' || 'Tran_PostExec';
			WHEN centryundopre THEN
				RETURN ppackage || '.' || 'EntryUndoPre';
			WHEN centryundopost THEN
				RETURN ppackage || '.' || 'EntryUndoPost';
			WHEN centryrestorepre THEN
				RETURN ppackage || '.' || 'EntryRestorePre';
			WHEN centryrestorepost THEN
				RETURN ppackage || '.' || 'EntryRestorePost';
			WHEN csop_preexec THEN
				RETURN ppackage || '.' || 'SOP_PreExec';
			WHEN csop_postexec THEN
				RETURN ppackage || '.' || 'SOP_PostExec';
			
			WHEN coppreexec THEN
				RETURN ppackage || '.' || 'OpPreExec';
			WHEN coppreexec2 THEN
				RETURN ppackage || '.' || 'OpPreExec2';
			WHEN centrydopre THEN
				RETURN ppackage || '.' || 'EntryDoPre';
			WHEN coppostexec THEN
				RETURN ppackage || '.' || 'OpPostExec';
			WHEN coppostexec2 THEN
				RETURN ppackage || '.' || 'OpPostExec2';
			WHEN centrydopost THEN
				RETURN ppackage || '.' || 'EntryDoPost';
			WHEN coppreundo THEN
				RETURN ppackage || '.' || 'OpPreUndo';
			WHEN coppostundo THEN
				RETURN ppackage || '.' || 'OpPostUndo';
			
			WHEN cexecadjusting THEN
				RETURN ppackage || '.' || 'ExecAdjusting';
			WHEN cundoadjusting THEN
				RETURN ppackage || '.' || 'UndoAdjusting';
			
			ELSE
				error.raiseerror('Internal error: unknown procedure code');
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION globalcursoropened(pindex IN typesop_cursor) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GlobalCursorOpened';
		vret BOOLEAN;
	BEGIN
		t.enter(cmethod_name, 'pIndex=' || pindex);
		IF sacursors.exists(pindex)
		THEN
			t.note('point 01');
			vret := dbms_sql.is_open(sacursors(pindex).cursorid);
		ELSE
			t.note('point 02');
			vret := FALSE;
		END IF;
		t.leave(cmethod_name, 'vRet=' || t.b2t(vret));
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION globalcursorexists(pindex IN typesop_cursor) RETURN BOOLEAN IS
	BEGIN
		IF sacursors.exists(pindex)
		THEN
			t.var('saCursors.exists(' || pindex || ')', 'TRUE');
			RETURN TRUE;
		ELSE
			t.var('saCursors.exists(' || pindex || ')', 'FALSE');
			RETURN FALSE;
		END IF;
	END;

	FUNCTION globalcursoropenedcv RETURN BOOLEAN IS
	BEGIN
		IF dbms_sql.is_open(sacursors('1').cursorid)
		THEN
			RETURN TRUE;
		END IF;
		RETURN FALSE;
	END;

	PROCEDURE closeglobalcursor(pindex IN typesop_cursor) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CloseGlobalCursor';
	BEGIN
		t.enter(cmethod_name, 'pIndex=' || pindex);
		IF globalcursoropened(pindex)
		THEN
			t.note(cmethod_name, 'start close CursorId=' || sacursors(pindex).cursorid);
			dbms_sql.close_cursor(sacursors(pindex).cursorid);
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION isglobalcursoropened
	(
		pacursorlist IN typesop_cursorsarray
	   ,pindex       IN typesop_cursor
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.IsGlobalCursorOpened';
		vret BOOLEAN := FALSE;
	BEGIN
		s.say(cmethod_name || ': Start ', csay_level);
		IF pacursorlist.exists(pindex)
		THEN
			vret := dbms_sql.is_open(pacursorlist(pindex).cursorid);
		END IF;
		s.say(cmethod_name || ': Finish vRet=' || htools.bool2str(vret), csay_level);
		RETURN vret;
	END isglobalcursoropened;

	PROCEDURE sop_cleararray IS
	BEGIN
		sasop_cursors.delete;
	END;

	PROCEDURE closecursor
	(
		pacursorlist IN typesop_cursorsarray
	   ,pindex       IN typesop_cursor
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CloseCursor';
		vcursor NUMBER;
	BEGIN
		t.enter(cmethod_name, 'pIndex=' || pindex, csay_level);
		IF isglobalcursoropened(pacursorlist, pindex)
		THEN
			vcursor := pacursorlist(pindex).cursorid;
			t.var('pIndex=', pindex);
			dbms_sql.close_cursor(vcursor);
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END closecursor;

	PROCEDURE releasecursorlist(palist IN OUT NOCOPY typesop_cursorsarray) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ReleaseCursorList';
		vindex typesop_cursor;
	BEGIN
		t.enter(cmethod_name, 'paList.Count ' || palist.count, csay_level);
		vindex := palist.first();
		WHILE vindex IS NOT NULL
		LOOP
			closecursor(palist, vindex);
			vindex := palist.next(vindex);
		END LOOP;
		palist.delete;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE sop_closeallcursors IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SOP_CloseAllCursors';
	BEGIN
		releasecursorlist(sasop_cursors);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END sop_closeallcursors;

	PROCEDURE initializeadjusting IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.InitializeAdjusting';
	BEGIN
		t.enter(cmethod_name);
		sacursors.delete();
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE finalizeadjusting IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FinalizeAdjusting';
	BEGIN
		t.enter(cmethod_name);
	
		releasecursorlist(sacursors);
		sacursors.delete();
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE closeglobalcursorcv IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CloseGlobalCursorCV';
	BEGIN
		s.say(cmethod_name || ': cursor ' || sacursors('1').cursorid, csay_level);
		IF dbms_sql.is_open(sacursors('1').cursorid)
		THEN
			dbms_sql.close_cursor(sacursors('1').cursorid);
			s.say(cmethod_name || ': cursor is closed', csay_level);
		END IF;
	END;

	PROCEDURE prepareglobalcursorcv(ppackage IN VARCHAR2) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.PrepareGlobalCursorCV';
	BEGIN
		sparsestr := 'BEGIN :VALUE := ' || upper(ppackage) || '.' || 'EXECCAPITALISE; END;';
		sacursors('1').cursorid := dbms_sql.open_cursor;
		dbms_sql.parse(sacursors('1').cursorid, sparsestr, dbms_sql.native);
		dbms_sql.bind_variable(sacursors('1').cursorid, ':VALUE', sexecret);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION execglobalcursor(pindex IN typesop_cursor) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ExecGlobalCursor';
		vres NUMBER;
	BEGIN
		t.enter(cmethod_name, 'pIndex=' || pindex, csay_level);
		IF globalcursoropened(pindex)
		THEN
			t.var('saCursors(pIndex).CursorId', sacursors(pindex).cursorid, csay_level);
			vres := dbms_sql.execute(sacursors(pindex).cursorid);
			dbms_sql.variable_value(sacursors(pindex).cursorid, ':VALUE', sexecret);
		ELSE
			err.seterror(err.contract_type_not_init, cmethod_name);
			t.leave(cmethod_name);
			RETURN err.contract_type_not_init;
		END IF;
		t.leave(cmethod_name);
		RETURN sexecret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION execglobalcursorcv RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ExecGlobalCursorCV';
		vres NUMBER;
	BEGIN
		s.say(cmethod_name || ': ', csay_level);
		vres := dbms_sql.execute(sacursors('1').cursorid);
		s.say(cmethod_name || ': ', csay_level);
		dbms_sql.variable_value(sacursors('1').cursorid, ':VALUE', sexecret);
		s.say(cmethod_name || ': ', csay_level);
		RETURN sexecret;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ': general exception ' || SQLCODE || ' ' || SQLERRM, csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE prepareglobalcursor
	(
		pindex        IN typesop_cursor
	   ,ppackage      IN tcontractschemas.packagename%TYPE
	   ,pfunc         IN VARCHAR2
	   ,pparams       IN VARCHAR2 := NULL
	   ,pparamsformat IN VARCHAR2 := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.PrepareGlobalCursor';
		vsql VARCHAR2(512);
	BEGIN
		t.enter(cmethod_name
			   ,'pIndex=' || pindex || ', pPackage=' || ppackage || ', pFunc=' || pfunc ||
				', pParams=' || pparams);
	
		IF (pparams IS NOT NULL AND pparamsformat IS NULL)
		   OR (pparams IS NULL AND pparamsformat IS NOT NULL)
		THEN
			error.raiseerror('Internal error: incorrect call of PrepareGlobalCursor method');
		END IF;
	
		IF contractschemas.existsmethod(ppackage, pfunc, pparamsformat || '/ret:N')
		THEN
			vsql := 'BEGIN :VALUE := ' || upper(ppackage || '.' || pfunc || pparams) || '; END;';
		
			sacursors(pindex).cursorid := dbms_sql.open_cursor;
			t.var('saCursors(pIndex).CursorId', sacursors(pindex).cursorid, csay_level);
		
			dbms_sql.parse(sacursors(pindex).cursorid, vsql, dbms_sql.native);
			dbms_sql.bind_variable(sacursors(pindex).cursorid, ':VALUE', sexecret);
			sacursors(pindex).supported := TRUE;
		
		ELSE
			sacursors(pindex).supported := FALSE;
			contractschemas.reportunsupportedoperation(ppackage, pfunc, 'adjustment');
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION initadjusting
	(
		pcontracttype IN tcontracttype.type%TYPE
	   ,pprepareexec  IN BOOLEAN := TRUE
	) RETURN NUMBER IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.InitAdjusting';
		cexecprocname CONSTANT VARCHAR2(100) := 'InitAdjusting';
		vret     NUMBER;
		vindex   typesop_cursor;
		vpackage VARCHAR2(100);
	BEGIN
		t.enter(cmethod_name
			   ,'pContractType=' || pcontracttype || ', pPrepareExec=' || t.b2t(pprepareexec));
	
		vpackage := contracttype.getschemapackage(pcontracttype);
		scontracttype(1) := pcontracttype;
		spackage(1) := vpackage;
	
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:N/ret:N')
		THEN
		
			BEGIN
			
				EXECUTE IMMEDIATE 'BEGIN :VALUE := ' || upper(vpackage) || '.' || cexecprocname ||
								  '(:TYPE); END;'
					USING OUT vret, IN pcontracttype;
			
				IF vret = 0
				THEN
					IF nvl(pprepareexec, TRUE)
					THEN
						vindex := sop_getcursorindex(vpackage, cexecadjusting);
						t.var('vIndex', vindex);
						IF NOT globalcursorexists(vindex)
						THEN
							prepareglobalcursor(vindex, vpackage, 'EXECADJUSTING');
						ELSIF NOT globalcursoropened(vindex)
						THEN
						
							t.note('POINT 01');
							prepareglobalcursor(vindex, vpackage, 'EXECADJUSTING');
						END IF;
					END IF;
				ELSE
					cleararrays;
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					error.save(cmethod_name);
					cleararrays;
					RAISE;
			END;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cexecprocname, 'adjustment');
		END IF;
	
		t.leave(cmethod_name);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END initadjusting;

	FUNCTION execadjusting(ppackno tadjpack.packno%TYPE) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExecAdjusting';
		vret        NUMBER;
		vcontractno tcontract.no%TYPE;
		vindex      typesop_cursor;
	BEGIN
		t.enter(cmethod_name, 'sContractRow.No=' || scontractrow.no);
		vcontractno      := contract.getcurrentno;
		fcrediton        := NULL;
		fcreditoff       := NULL;
		screditsum       := NULL;
		screditoffsum    := NULL;
		fviolationon     := NULL;
		fviolationoff    := NULL;
		screditprcoffsum := NULL;
		srollbackdata    := NULL;
		scontractrow     := contract.getcontractrowtype(scontractrow.no);
		saadjusting.delete();
		sdocno := NULL;
	
		IF NOT scontracttype.exists(1)
		   OR NOT spackage.exists(1)
		THEN
			error.raiseerror('Internal error: adjustment not prepared');
		ELSIF (scontractrow.type != scontracttype(1))
		THEN
			error.raiseerror('Internal error: Mismatch of contract types when preparing and performing adjustment');
		ELSE
			contract.setcurrentno(scontractrow.no);
			vindex := sop_getcursorindex(spackage(1), cexecadjusting);
			t.var('vIndex', vindex);
			vret := execglobalcursor(vindex);
			contract.setcurrentno(vcontractno);
		END IF;
		t.leave(cmethod_name);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			contract.setcurrentno(vcontractno);
			RAISE;
	END execadjusting;

	PROCEDURE downadjusting IS
		cmethod_name  CONSTANT VARCHAR2(65) := cpackage_name || '.DownAdjusting';
		cexecprocname CONSTANT VARCHAR2(100) := 'DownAdjusting';
	
	BEGIN
	
		t.enter(cmethod_name);
		IF spackage.exists(1)
		THEN
			t.var('sPackage(1)', spackage(1));
		END IF;
		IF scontracttype.exists(1)
		THEN
			t.var('sContractType(1)', scontracttype(1));
		END IF;
	
		IF isarrayitemsnotnull(1)
		   AND contractschemas.existsmethod(spackage(1), cexecprocname, '/in:N/ret:E')
		THEN
			EXECUTE IMMEDIATE 'begin ' || spackage(1) || '.' || cexecprocname || '(:TYPE); end;'
				USING IN scontracttype(1);
		END IF;
	
		cleararrays;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
		
	END;

	FUNCTION initundoadjusting(pcontracttype IN NUMBER) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.InitUndoAdjusting';
		cfuncname    CONSTANT VARCHAR2(100) := 'InitUndoAdjusting';
		vret     NUMBER;
		vindex   typesop_cursor;
		vpackage VARCHAR2(100);
	BEGIN
		t.enter(cmethod_name, 'pContractType=' || pcontracttype);
	
		vpackage := contracttype.getschemapackage(pcontracttype);
	
		scontracttype(1) := pcontracttype;
		spackage(1) := vpackage;
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:N/ret:N')
		THEN
		
			BEGIN
				EXECUTE IMMEDIATE 'begin :RET := ' || upper(vpackage) || '.' || cfuncname ||
								  '(:TYPE); end;'
					USING OUT vret, IN pcontracttype;
			
				IF vret = 0
				THEN
					vindex := sop_getcursorindex(vpackage, cundoadjusting);
					t.var('vIndex', vindex);
					IF NOT globalcursorexists(vindex)
					THEN
						prepareglobalcursor(vindex, vpackage, 'UNDOADJUSTING');
					ELSIF NOT globalcursoropened(vindex)
					THEN
					
						t.note('POINT 01');
						prepareglobalcursor(vindex, vpackage, 'UNDOADJUSTING');
					END IF;
				ELSE
					cleararrays;
				END IF;
			
			EXCEPTION
				WHEN OTHERS THEN
					error.save(cmethod_name);
					cleararrays;
					RAISE;
			END;
		
		END IF;
		t.leave(cmethod_name);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION undoadjusting RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.UndoAdjusting';
		vret   NUMBER := 0;
		vindex typesop_cursor;
	BEGIN
		t.enter(cmethod_name, 'sContractRow.No=' || scontractrow.no);
		IF NOT scontracttype.exists(1)
		   OR NOT spackage.exists(1)
		THEN
			error.saveraise(cmethod_name
						   ,error.errorconst
						   ,'Internal error: undo of adjustment not prepared');
		ELSIF scontractrow.type != scontracttype(1)
		THEN
			error.saveraise(cmethod_name
						   ,error.errorconst
						   ,'Internal error: Mismatch of contract types when calling, preparing and performing adjustment undo');
		ELSE
			t.note(cmethod_name, 'start ContractRb.Undo()');
			srollbackdata := contractrb.undo(scontractrow.no, srollbackdata);
			vindex        := sop_getcursorindex(spackage(1), cundoadjusting);
			t.var('vIndex', vindex);
			vret := execglobalcursor(vindex);
		END IF;
		t.leave(cmethod_name);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE downundoadjusting IS
		cmethod_name  CONSTANT VARCHAR2(65) := cpackage_name || '.DownUndoAdjusting';
		cexecprocname CONSTANT VARCHAR2(65) := 'DownUndoAdjusting';
	
	BEGIN
		t.enter(cmethod_name);
		IF spackage.exists(1)
		THEN
			t.var('sPackage(1)', spackage(1));
		END IF;
		IF scontracttype.exists(1)
		THEN
			t.var('sContractType(1)', scontracttype(1));
		END IF;
	
		IF isarrayitemsnotnull(1)
		   AND contractschemas.existsmethod(spackage(1), cexecprocname, '/in:N/ret:E')
		THEN
			EXECUTE IMMEDIATE 'begin ' || spackage(1) || '.' || cexecprocname || '(:Type); end;'
				USING scontracttype(1);
		END IF;
	
		cleararrays;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			cleararrays;
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE releaseresourcestill
	(
		prange        IN NUMBER
	   ,pcall         IN NUMBER
	   ,pdownfuncname IN VARCHAR2
	) IS
		vret NUMBER;
	BEGIN
		FOR i IN 1 .. prange
		LOOP
			IF pcall = call_function
			THEN
				IF contractschemas.existsmethod(spackage(i), pdownfuncname, '/in:N/ret:N')
				THEN
					EXECUTE IMMEDIATE 'BEGIN :RET:= ' || upper(spackage(i) || '.' || pdownfuncname) ||
									  '(:TYPE); END;'
						USING OUT vret, scontracttype(i);
				END IF;
			ELSE
				IF contractschemas.existsmethod(spackage(i), pdownfuncname, '/in:N/ret:E')
				THEN
					EXECUTE IMMEDIATE 'BEGIN ' || upper(spackage(i) || '.' || pdownfuncname) ||
									  '(:TYPE); END;'
						USING scontracttype(i);
				END IF;
			END IF;
		
			IF globalcursoropened(to_char(scontracttype(i)))
			THEN
				closeglobalcursor(to_char(scontracttype(i)));
			END IF;
		
		END LOOP;
	END releaseresourcestill;

	FUNCTION initaggregate(pctype IN NUMBER) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.InitAggregate';
		cfuncname    CONSTANT VARCHAR2(65) := 'InitAggregate';
		vret     NUMBER;
		vpackage VARCHAR2(40);
	BEGIN
		vpackage := contracttype.getschemapackage(pctype);
		IF vpackage IS NULL
		THEN
			vret := err.geterrorcode();
		ELSE
			spackagetemp := vpackage;
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:N/ret:N')
			THEN
				EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.' || cfuncname ||
								  '(:TYPE); END;'
					USING OUT vret, pctype;
				IF vret = 0
				THEN
				
					IF contractschemas.existsmethod(vpackage, 'ExecAggregate', '/ret:N')
					THEN
						prepareglobalcursor(to_char(pctype), vpackage, 'EXECAGGREGATE');
					ELSE
						err.seterror(err.refct_undefined_oper
									,' [' || vpackage || '.ExecAggregate]');
						vret := err.refct_undefined_oper;
					END IF;
				
				END IF;
			
			ELSE
				err.seterror(err.refct_undefined_oper, ' [' || vpackage || '.' || cfuncname || ']');
				vret := err.refct_undefined_oper;
			END IF;
		
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END initaggregate;

	FUNCTION initaggregate RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.InitAggregate';
		vbranch NUMBER := seance.getbranch();
	
		CURSOR vcur IS
			SELECT TYPE FROM tcontracttype WHERE branch = vbranch;
	
		vcount NUMBER;
		vret   NUMBER;
	BEGIN
		vcount := 0;
		sacursors.delete();
		spackage.delete();
	
		FOR i IN vcur
		LOOP
			vcount := vcount + 1;
			scontracttype(vcount) := i.type;
			vret := initaggregate(i.type);
			IF vret = err.refct_undefined_schema
			THEN
				releaseresourcestill(vcount - 1, call_procedure, 'DOWNAGGREGATE');
				RETURN vret;
			ELSE
				IF vret = 0
				THEN
					spackage(vcount) := spackagetemp;
				ELSE
					releaseresourcestill(vcount - 1, call_procedure, 'DOWNAGGREGATE');
					closeglobalcursor(to_char(i.type));
					err.seterror(vret, cmethod_name);
					RETURN vret;
				END IF;
			END IF;
		END LOOP;
	
		RETURN 0;
	END initaggregate;

	FUNCTION execaggregate
	(
		pcontractno IN VARCHAR2
	   ,pitemcode   IN NUMBER
	   ,paccountno  IN VARCHAR2
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExecAggregate[3]';
		vret        PLS_INTEGER;
		vcontractno tcontract.no%TYPE;
	BEGIN
		vcontractno := contract.getcurrentno;
		scontractno := pcontractno;
		sitemcode   := pitemcode;
		saccountno  := paccountno;
	
		scontractrow := contract.getcontractrowtype(pcontractno);
		contract.setcurrentno(pcontractno);
		contracttypeschema.saaggregate.delete();
	
		vret := execglobalcursor(to_char(scontractrow.type));
	
		contract.setcurrentno(vcontractno);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			contract.setcurrentno(vcontractno);
			error.save(cmethod_name);
			RAISE;
	END execaggregate;

	FUNCTION execaggregate
	(
		pcontractno IN VARCHAR2
	   ,pitemcode   IN NUMBER
	   ,paccountno  IN VARCHAR2
	   ,oparams     OUT taggroutparams
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExecAggregate[4]';
		vret PLS_INTEGER;
	BEGIN
		sparentaccountno := NULL;
		sbonus           := NULL;
	
		scode     := NULL;
		spriority := NULL;
	
		sabonusprograms.delete;
	
		IF execaggregate(pcontractno, pitemcode, paccountno) != 0
		THEN
			RETURN err.geterrorcode();
		END IF;
	
		oparams.parentaccount := sparentaccountno;
		oparams.bonus         := sbonus;
	
		oparams.code     := scode;
		oparams.priority := spriority;
	
		oparams.bonusprograms := sabonusprograms;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END execaggregate;

	PROCEDURE execaggregatepost(poaccrefreshlist IN OUT apitypes.listaccrefreshrow) IS
		cmethod_name  CONSTANT VARCHAR2(65) := cpackage_name || '.ExecAggregatePost';
		cexecprocname CONSTANT VARCHAR2(65) := 'EXECAGGREGATEPOST';
		vcontractno  tcontract.no%TYPE;
		vpackagename tcontractschemas.packagename%TYPE;
		vindex       BINARY_INTEGER;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('poAccRefreshList.count', poaccrefreshlist.count);
	
		vindex := poaccrefreshlist.first();
		WHILE vindex IS NOT NULL
		LOOP
			vcontractno := contract.getcontractnobyaccno(poaccrefreshlist(vindex).accountno, FALSE);
			EXIT WHEN vcontractno IS NOT NULL;
			vindex := poaccrefreshlist.next(vindex);
		END LOOP;
		t.var('vContractNo', vcontractno);
		IF vcontractno IS NOT NULL
		THEN
			vpackagename := contracttype.getschemapackage(contract.gettype(vcontractno));
			t.var('vPackageName', vpackagename);
		
			IF contractschemas.existsmethod(vpackagename, cexecprocname, '/inout:A/ret:E')
			THEN
			
				saccrefreshlist := poaccrefreshlist;
				EXECUTE IMMEDIATE 'BEGIN ' || vpackagename || '.' || cexecprocname ||
								  '(CONTRACTTYPESCHEMA.SACCREFRESHLIST); END;';
				poaccrefreshlist := saccrefreshlist;
			
			END IF;
		
		ELSE
			t.note(cmethod_name, 'Contract is not found', csay_level);
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE downaggregate(pctype IN NUMBER) IS
		cmethod_name  CONSTANT VARCHAR2(65) := cpackage_name || '.DownAggregate';
		cexecprocname CONSTANT VARCHAR2(65) := 'DownAggregate';
		vpackage VARCHAR2(40);
	BEGIN
		vpackage := contracttype.getschemapackage(pctype);
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:N/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname || '(:TYPE); END;'
				USING IN pctype;
		END IF;
	
		IF globalcursoropened(to_char(pctype))
		THEN
			closeglobalcursor(to_char(pctype));
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethod_name);
			closeglobalcursor(to_char(pctype));
	END downaggregate;

	PROCEDURE downaggregate IS
	BEGIN
		FOR i IN 1 .. scontracttype.count
		LOOP
			downaggregate(scontracttype(i));
		END LOOP;
	
		sacursors.delete();
		spackage.delete();
	END downaggregate;

	FUNCTION initcapitalise
	(
		pcontracttype IN NUMBER
	   ,pitemcode     IN NUMBER
	   ,pdate         IN DATE
	   ,pfrom         IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.InitCapitalise';
		cfuncname    CONSTANT VARCHAR2(65) := 'InitCapitalise';
		vret NUMBER;
	BEGIN
		scontracttype(1) := pcontracttype;
		spackage(1) := contracttype.getschemapackage(pcontracttype);
	
		IF (spackage(1) IS NULL)
		THEN
			RETURN err.geterrorcode();
		END IF;
		IF contractschemas.existsmethod(spackage(1), cfuncname, '/in:N/in:N/in:D/in:N/ret:N')
		THEN
			sitemcode := pitemcode;
		
			EXECUTE IMMEDIATE 'BEGIN :RET := ' || upper(spackage(1)) || '.' || cfuncname ||
							  '(:CONTRACTTYPE, :ITEMCODE, :INDATE, :TFROM); END;'
				USING OUT vret, pcontracttype, pitemcode, pdate, pfrom;
		
			IF vret = 0
			THEN
				prepareglobalcursorcv(spackage(1));
			END IF;
		ELSE
			contractschemas.reportunsupportedoperation(spackage(1), cfuncname);
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION execcapitalise
	(
		pcontractno IN VARCHAR2
	   ,penddate    IN DATE := NULL
	   ,pthandle    IN NUMBER := NULL
	   ,pinfomode   IN NUMBER := 1
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExecCapitalise';
	BEGIN
		senddate  := penddate;
		sthandle  := pthandle;
		sinfomode := pinfomode;
		percent.resetarrays;
	
		scontractrow := contract.getcontractrowtype(pcontractno);
	
		RETURN execglobalcursorcv();
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END execcapitalise;

	PROCEDURE downcapitalise IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.DownCapitalise';
		cexecprocname CONSTANT VARCHAR2(100) := 'DownCapitalise';
	BEGIN
	
		IF isarrayitemsnotnull(1)
		   AND contractschemas.existsmethod(spackage(1), cexecprocname, '/in:N/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || upper(spackage(1)) || '.' || cexecprocname ||
							  '(:TYPE); END;'
				USING IN scontracttype(1);
		END IF;
	
		cleararrays;
	
		IF globalcursoropenedcv()
		THEN
			s.say(cmethod_name || ': before closing cursor ', csay_level);
			closeglobalcursorcv();
			s.say(cmethod_name || ': after closing cursor ', csay_level);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END downcapitalise;

	FUNCTION tran_cursorprepare
	(
		ppackage  IN VARCHAR2
	   ,pproccode IN NUMBER
	) RETURN typetran_cursor IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.Tran_CursorPrepare';
		vselect VARCHAR2(200);
	
		vresult typetran_cursor;
		vcursor NUMBER;
	BEGIN
		t.enter(cmethod_name);
		t.inpar('pPackage', ppackage);
		t.inpar('pProcCode', pproccode);
	
		CASE pproccode
		
			WHEN ctran_postexec THEN
				IF contractschemas.existsmethod(ppackage, 'Tran_PostExec', '/in:V/in:N/ret:E')
				THEN
					vselect := 'BEGIN ' || ppackage || '.Tran_PostExec(:CNO, :DOCNO); end;';
				END IF;
			WHEN centryundopre THEN
				IF contractschemas.existsmethod(ppackage, 'EntryUndoPre', '/inout:S/ret:E')
				THEN
				
					vselect := 'BEGIN ' || ppackage ||
							   '.EntryUndoPre(CONTRACTTYPESCHEMA.SENTRYPROPS); end;';
				
				END IF;
			WHEN centryundopost THEN
				IF contractschemas.existsmethod(ppackage, 'EntryUndoPost', '/inout:S/ret:E')
				THEN
					vselect := 'BEGIN ' || ppackage ||
							   '.EntryUndoPost(CONTRACTTYPESCHEMA.SENTRYPROPS); end;';
				END IF;
			WHEN centryrestorepre THEN
				IF contractschemas.existsmethod(ppackage, 'EntryRestorePre', '/inout:S/ret:E')
				THEN
					vselect := 'BEGIN ' || ppackage ||
							   '.EntryRestorePre(CONTRACTTYPESCHEMA.SENTRYPROPS); end;';
				END IF;
			WHEN centryrestorepost THEN
				IF contractschemas.existsmethod(ppackage, 'EntryRestorePost', '/inout:S/ret:E')
				THEN
					vselect := 'BEGIN ' || ppackage ||
							   '.EntryRestorePost(CONTRACTTYPESCHEMA.SENTRYPROPS); end;';
				END IF;
			WHEN csop_preexec THEN
				IF contractschemas.existsmethod(ppackage
											   ,'SOP_PreExec'
											   ,'/in:V/inout:N/inout:N/inout:S/ret:E')
				   OR contractschemas.existsmethod(ppackage
												  ,'SOP_PreExec'
												  ,'/in:V/inout:N/inout:N/in:S/ret:E')
				THEN
					vselect := 'BEGIN ' || ppackage ||
							   '.SOP_PreExec(:CONTNO, :DOCNO, :NO, ContractTypeSchema.SOP_Params); END;';
				END IF;
			WHEN csop_postexec THEN
				IF contractschemas.existsmethod(ppackage
											   ,'SOP_PostExec'
											   ,'/in:V/inout:N/inout:N/in:S/ret:E')
				THEN
					vselect := 'BEGIN ' || ppackage ||
							   '.SOP_PostExec(:CONTNO, :DOCNO, :NO, ContractTypeSchema.SOP_Params); END;';
				END IF;
			
			WHEN coppreexec THEN
				IF contractschemas.existsmethod(ppackage, 'OpPreExec', '/ret:N')
				THEN
					vselect := 'BEGIN :VALUE := ' || upper(ppackage) || '.OpPreExec; END;';
				END IF;
			WHEN coppreexec2 THEN
				IF contractschemas.existsmethod(ppackage, 'OpPreExec2', '/in:V/ret:E')
				THEN
					vselect := 'BEGIN ' || upper(ppackage) || '.OPPREEXEC2(:CONTNO); END;';
				END IF;
			WHEN centrydopre THEN
				IF contractschemas.existsmethod(ppackage
											   ,'EntryDoPre'
											   ,'/in:V/inout:N/inout:N/inout:S/ret:E')
				THEN
					vselect := 'BEGIN ' || ppackage ||
							   '.ENTRYDOPRE(:CONTNO, :DOCNO, :NO, ContractTypeSchema.SOP_Params); END;';
				END IF;
			
			WHEN coppostexec THEN
				IF contractschemas.existsmethod(ppackage, 'OpPostExec', '/ret:N')
				THEN
					vselect := 'BEGIN :VALUE := ' || upper(ppackage) || '.OpPostExec; END;';
				END IF;
			WHEN coppostexec2 THEN
				IF contractschemas.existsmethod(ppackage, 'OpPostExec2', '/in:V/ret:E')
				THEN
					vselect := 'BEGIN ' || upper(ppackage) || '.OPPOSTEXEC2(:CONTNO); END;';
				END IF;
			WHEN centrydopost THEN
				IF contractschemas.existsmethod(ppackage
											   ,'EntryDoPost'
											   ,'/in:V/inout:N/inout:N/inout:S/ret:E')
				THEN
					vselect := 'BEGIN ' || ppackage ||
							   '.ENTRYDOPOST(:CONTNO, :DOCNO, :NO, ContractTypeSchema.SOP_Params); END;';
				END IF;
			
			WHEN coppreundo THEN
				IF contractschemas.existsmethod(ppackage, 'OpUndo', '/ret:N')
				THEN
					vselect := 'BEGIN :VALUE := ' || upper(ppackage) || '.OpUndo; END;';
				END IF;
			
			WHEN coppostundo THEN
				IF contractschemas.existsmethod(ppackage, 'OpPostUndo', '/ret:N')
				THEN
					vselect := 'BEGIN :VALUE := ' || upper(ppackage) || '.OpPostUndo; END;';
				END IF;
			
			ELSE
				error.raiseerror('Internal error: unknown procedure code');
		END CASE;
		IF vselect IS NOT NULL
		THEN
			vcursor := dbms_sql.open_cursor;
		
			BEGIN
				dbms_sql.parse(vcursor, vselect, dbms_sql.native);
				vresult.supported := TRUE;
				vresult.cursorid  := vcursor;
			
			EXCEPTION
			
				WHEN OTHERS THEN
					t.note(cmethod_name, 'Err=' || SQLERRM);
					error.save(cmethod_name);
					RAISE;
			END;
		
		ELSE
			vresult.supported := FALSE;
		END IF;
	
		t.leave(cmethod_name, 'vResult.Supported=' || t.b2t(vresult.supported));
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE sop_execcursor
	(
		pcursor        IN OUT typetran_cursor
	   ,pproccode      IN NUMBER
	   ,psop_parameter IN OUT typesop_parameter
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SOP_ExecCursor';
		vres NUMBER;
	BEGIN
		t.enter(cmethod_name, 'pProcCode=' || pproccode, csay_level);
		CASE pproccode
			WHEN csop_preexec THEN
				dbms_sql.bind_variable(pcursor.cursorid, ':CONTNO', psop_parameter.contractno);
				dbms_sql.bind_variable(pcursor.cursorid, ':DOCNO', psop_parameter.docno);
				dbms_sql.bind_variable(pcursor.cursorid, ':NO', psop_parameter.no);
			WHEN csop_postexec THEN
				dbms_sql.bind_variable(pcursor.cursorid, ':CONTNO', psop_parameter.contractno);
				dbms_sql.bind_variable(pcursor.cursorid, ':DOCNO', psop_parameter.docno);
				dbms_sql.bind_variable(pcursor.cursorid, ':NO', psop_parameter.no);
			WHEN centryundopre THEN
				NULL;
			WHEN centryundopost THEN
				NULL;
			WHEN centryrestorepre THEN
				NULL;
			WHEN centryrestorepost THEN
				NULL;
			
			WHEN coppreexec THEN
			
				t.var('[cOpPreExec] pSOP_Parameter.Params.Direction'
					 ,psop_parameter.params.direction);
				sop_params := psop_parameter.params;
			
				dbms_sql.bind_variable(pcursor.cursorid, ':VALUE', psop_parameter.retvalue);
			WHEN coppreexec2 THEN
			
				t.var('[cOpPreExec2] pSOP_Parameter.Params.Direction'
					 ,psop_parameter.params.direction);
				sop_params := psop_parameter.params;
			
				dbms_sql.bind_variable(pcursor.cursorid, ':CONTNO', psop_parameter.contractno);
			WHEN centrydopre THEN
			
				t.var('[cEntryDoPre] pSOP_Parameter.Params.Direction'
					 ,psop_parameter.params.direction);
				sop_params := psop_parameter.params;
			
				dbms_sql.bind_variable(pcursor.cursorid, ':CONTNO', psop_parameter.contractno);
				dbms_sql.bind_variable(pcursor.cursorid, ':DOCNO', psop_parameter.docno);
				dbms_sql.bind_variable(pcursor.cursorid, ':NO', psop_parameter.no);
			WHEN coppostexec THEN
			
				t.var('[cOpPostExec] pSOP_Parameter.Params.Direction'
					 ,psop_parameter.params.direction);
				sop_params := psop_parameter.params;
			
				dbms_sql.bind_variable(pcursor.cursorid, ':VALUE', psop_parameter.retvalue);
			WHEN coppostexec2 THEN
				dbms_sql.bind_variable(pcursor.cursorid, ':CONTNO', psop_parameter.contractno);
			WHEN centrydopost THEN
			
				t.var('[EntryDoPost] pSOP_Parameter.Params.Direction'
					 ,psop_parameter.params.direction);
				sop_params := psop_parameter.params;
			
				dbms_sql.bind_variable(pcursor.cursorid, ':CONTNO', psop_parameter.contractno);
				dbms_sql.bind_variable(pcursor.cursorid, ':DOCNO', psop_parameter.docno);
				dbms_sql.bind_variable(pcursor.cursorid, ':NO', psop_parameter.no);
			WHEN coppreundo THEN
			
				t.var('[cOpPreUndo] pSOP_Parameter.Params.Direction'
					 ,psop_parameter.params.direction);
				sop_params := psop_parameter.params;
			
				dbms_sql.bind_variable(pcursor.cursorid, ':VALUE', psop_parameter.retvalue);
			WHEN coppostundo THEN
			
				t.var('[cOpPostUndo] pSOP_Parameter.Params.Direction'
					 ,psop_parameter.params.direction);
				sop_params := psop_parameter.params;
			
				dbms_sql.bind_variable(pcursor.cursorid, ':VALUE', psop_parameter.retvalue);
			
			ELSE
				error.raiseerror('Internal error: unknown procedure code');
		END CASE;
		BEGIN
			vres := dbms_sql.execute(pcursor.cursorid);
		
			CASE pproccode
				WHEN csop_preexec THEN
					dbms_sql.variable_value(pcursor.cursorid, ':DOCNO', psop_parameter.docno);
					dbms_sql.variable_value(pcursor.cursorid, ':NO', psop_parameter.no);
				WHEN csop_postexec THEN
					dbms_sql.variable_value(pcursor.cursorid, ':DOCNO', psop_parameter.docno);
					dbms_sql.variable_value(pcursor.cursorid, ':NO', psop_parameter.no);
				
				WHEN coppreexec THEN
					psop_parameter.params := sop_params;
					dbms_sql.variable_value(pcursor.cursorid, ':VALUE', psop_parameter.retvalue);
				
				WHEN centrydopre THEN
					psop_parameter.params := sop_params;
					dbms_sql.variable_value(pcursor.cursorid, ':DOCNO', psop_parameter.docno);
					dbms_sql.variable_value(pcursor.cursorid, ':NO', psop_parameter.no);
				WHEN coppostexec THEN
					psop_parameter.params := sop_params;
					dbms_sql.variable_value(pcursor.cursorid, ':VALUE', psop_parameter.retvalue);
				WHEN centrydopost THEN
					psop_parameter.params := sop_params;
					dbms_sql.variable_value(pcursor.cursorid, ':DOCNO', psop_parameter.docno);
					dbms_sql.variable_value(pcursor.cursorid, ':NO', psop_parameter.no);
				WHEN coppreundo THEN
					psop_parameter.params := sop_params;
					dbms_sql.variable_value(pcursor.cursorid, ':VALUE', psop_parameter.retvalue);
				WHEN coppostundo THEN
					psop_parameter.params := sop_params;
					dbms_sql.variable_value(pcursor.cursorid, ':VALUE', psop_parameter.retvalue);
				
				ELSE
					t.note(cmethod_name
						  ,'Undefined procedure code [' || pproccode || ']'
						  ,csay_level);
			END CASE;
		
		EXCEPTION
		
			WHEN OTHERS THEN
				RAISE;
		END;
		t.leave(cmethod_name, 'pCursor.Supported=' || t.b2t(pcursor.supported), csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, 'error=' || SQLERRM, csay_level);
			error.save(cmethod_name);
			RAISE;
	END sop_execcursor;

	PROCEDURE sop_batchexec
	(
		pacursorarray  IN OUT NOCOPY typesop_cursorsarray
	   ,psop_parameter IN OUT NOCOPY typesop_parameter
	   ,ppackage       IN VARCHAR2
	   ,pproccode      IN NUMBER
	   ,pdoexception   IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.SOP_BatchExec';
		vindex typesop_cursor;
	
	BEGIN
		t.enter(cmethod_name, '========<<' || cmethod_name || '>>======== : ', csay_level);
		t.var('[1] pSOP_Parameter.DocNo', psop_parameter.docno);
		t.var('[1] pSOP_Parameter.No', psop_parameter.no);
		t.var('[1] paCursorArray.count', pacursorarray.count);
	
		vindex := upper(sop_getcursorindex(ppackage, pproccode));
	
		t.var('vIndex', vindex, csay_level);
	
		IF NOT pacursorarray.exists(vindex)
		THEN
			pacursorarray(vindex) := tran_cursorprepare(ppackage, pproccode);
		END IF;
	
		IF pacursorarray(vindex).supported
		THEN
			psop_parameter.params.execresult := cexecres_supported;
		
			t.var('paCursorArray(vIndex).CursorId', pacursorarray(vindex).cursorid);
		
			sop_execcursor(pacursorarray(vindex), pproccode, psop_parameter);
		
			t.var('[2] pSOP_Parameter.DocNo', psop_parameter.docno);
			t.var('[2] pSOP_Parameter.No', psop_parameter.no);
		
		ELSE
			psop_parameter.params.execresult := cexecres_unsupported;
			contractschemas.reportunsupportedoperation(ppackage, NULL, NULL, pdoexception);
		END IF;
	
		t.leave(cmethod_name, '========<< END >>======== : ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END sop_batchexec;

	PROCEDURE exec_cursor
	(
		pacursorarray  IN OUT NOCOPY typesop_cursorsarray
	   ,psop_parameter IN OUT NOCOPY typesop_parameter
	   ,ppackage       IN VARCHAR2
	   ,pproccode      IN NUMBER
	   ,pexecmode      IN NUMBER := csop_manualexec
	   ,pexception     IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.Exec_Cursor';
		vcontractno tcontract.no%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pPackage=' || ppackage || ', pProcCode=' || pproccode || ', pExecMode=' ||
				pexecmode
			   ,csay_level);
		t.inpar('pSOP_Parameter.Params.ProcName', psop_parameter.params.procname, csay_level);
		vcontractno := contract.getcurrentno;
		contract.setcurrentno(psop_parameter.contractno);
	
		IF pproccode = csop_postexec
		   AND psop_parameter.contractno IS NOT NULL
		   AND NOT sasop_contractlist.exists(psop_parameter.contractno)
		THEN
			sasop_contractlist(psop_parameter.contractno) := ppackage;
			t.note('added ', psop_parameter.contractno || '[' || ppackage || ']');
		END IF;
	
		IF pexecmode = csop_batchexec
		THEN
		
			sop_batchexec(pacursorarray
						 ,psop_parameter
						 ,ppackage
						 ,pproccode
						 ,nvl(pexception, FALSE));
		
		ELSE
			CASE pproccode
				WHEN csop_preexec THEN
					IF contractschemas.existsmethod(ppackage
												   ,'SOP_PreExec'
												   ,'/in:V/inout:N/inout:N/inout:S/ret:E')
					   OR contractschemas.existsmethod(ppackage
													  ,'SOP_PreExec'
													  ,'/in:V/inout:N/inout:N/in:S/ret:E')
					THEN
						EXECUTE IMMEDIATE upper('BEGIN ' || ppackage ||
												'.SOP_PreExec(:CONTNO, :DOCNO, :NO, ContractTypeSchema.SOP_Params); END;')
							USING IN psop_parameter.contractno, IN OUT psop_parameter.docno, IN OUT psop_parameter.no;
						psop_parameter.params := sop_params;
					
					END IF;
				WHEN csop_postexec THEN
					IF contractschemas.existsmethod(ppackage
												   ,'SOP_PostExec'
												   ,'/in:V/inout:N/inout:N/in:S/ret:E')
					THEN
						EXECUTE IMMEDIATE upper('BEGIN ' || ppackage ||
												'.SOP_PostExec(:CONTNO, :DOCNO, :NO, ContractTypeSchema.SOP_Params); END;')
							USING IN psop_parameter.contractno, IN OUT psop_parameter.docno, IN OUT psop_parameter.no;
						psop_parameter.params := sop_params;
					END IF;
				ELSE
					error.raiseerror('Internal error: unknown procedure code');
			END CASE;
		END IF;
		contract.setcurrentno(vcontractno);
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
	
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			contract.setcurrentno(vcontractno);
			RAISE;
	END;

	PROCEDURE processcursor
	(
		pcontractno IN tcontract.no%TYPE
	   ,pdocno      IN OUT NUMBER
	   ,pno         IN OUT NUMBER
	   ,pparams     IN OUT tsop_params
	   ,pproccode   IN NUMBER
	   ,pexecmode   IN NUMBER := csop_manualexec
	   ,pexception  IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.ProcessCursor';
		vpackage       tcontractschemas.packagename%TYPE;
		vsop_parameter typesop_parameter;
	BEGIN
		t.enter(cmethod_name, 'ContractNo=' || pcontractno, csay_level);
	
		t.inpar('[in] pDocNo', pdocno);
		t.inpar('[in] pNo', pno);
		t.inpar('pProcCode', pproccode);
	
		scontractrow := contract.getcontractrowtype(pcontractno);
		vpackage     := contracttype.getschemapackage(scontractrow.type);
	
		IF vpackage IS NULL
		THEN
			error.raiseerror(excsystem_error
							,'Not found name of scheme batch for contract type: ' ||
							 scontractrow.type);
		ELSE
			vsop_parameter.contractno := pcontractno;
			vsop_parameter.docno      := pdocno;
			vsop_parameter.no         := pno;
			vsop_parameter.params     := pparams;
		
			exec_cursor(sasop_cursors
					   ,vsop_parameter
					   ,vpackage
					   ,pproccode
					   ,pexecmode
					   ,nvl(pexception, FALSE));
		
			pdocno := vsop_parameter.docno;
			pno    := vsop_parameter.no;
		
			t.outpar('[out] pDocNo', pdocno);
			t.outpar('[out] pNo', pno);
			t.outpar('vSOP_Parameter.Params.ExecResult', vsop_parameter.params.execresult);
			pparams := vsop_parameter.params;
			t.outpar('[1] pParams.FinRunCommission.ClientAccount'
					,pparams.finruncommission.clientaccount);
			t.outpar('[1] pParams.FinRunCommission.BankAccount'
					,pparams.finruncommission.bankaccount);
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE sop_preexec
	(
		pdocno    IN OUT NUMBER
	   ,pno       IN OUT NUMBER
	   ,pparams   IN OUT tsop_params
	   ,pexecmode IN NUMBER := csop_manualexec
	) IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.SOP_PreExec';
		vcontractnodebit  tcontract.no%TYPE;
		vcontractnocredit tcontract.no%TYPE;
	BEGIN
		s.say(cmethod_name || ': ', csay_level);
		vcontractnodebit := contract.getcontractnobyaccno(account.getaccountno(pparams.debitaccount)
														 ,FALSE);
		s.say('vContractNoDebit=' || vcontractnodebit, csay_level);
		vcontractnocredit := contract.getcontractnobyaccno(account.getaccountno(pparams.creditaccount)
														  ,FALSE);
		s.say('vContractNoCredit=' || vcontractnocredit, csay_level);
		IF vcontractnodebit IS NULL
		   AND vcontractnocredit IS NULL
		THEN
			s.say('return', csay_level);
			RETURN;
		END IF;
	
		IF vcontractnodebit IS NOT NULL
		THEN
			pparams.direction := sdirectdebit;
			sop_params        := pparams;
			processcursor(vcontractnodebit, pdocno, pno, pparams, csop_preexec, pexecmode);
		END IF;
		IF vcontractnocredit IS NOT NULL
		THEN
			pparams.direction := sdirectcredit;
			sop_params        := pparams;
			processcursor(vcontractnocredit, pdocno, pno, pparams, csop_preexec, pexecmode);
		END IF;
	
		pparams := sop_params;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END sop_preexec;

	PROCEDURE opinit IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.OpInit';
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		sop_cleararray();
		sacurrenttransaction.delete;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getdirection_extract(pextractrow IN apitypes.typeextractrecord) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetDirection_Extract';
		vret NUMBER;
	
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pExtractRow.Device', pextractrow.device);
		t.inpar('pExtractRow.EntCode', pextractrow.entcode);
	
		IF extract.isdebit()
		THEN
			t.note('Extract.IsDebit');
			vret := sdirectdebit;
		ELSIF extract.iscredit()
		THEN
			t.note('Extract.IsCredit');
		
			vret := sdirectcredit;
		ELSE
			vret := NULL;
		END IF;
		t.outpar('vRet', vret);
		t.leave(cmethod_name, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getfinruncommissiondata RETURN typefinruncommission IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || 'GetFinRunCommissionData';
		vcommissiondata finruncommissiondata.typecommission;
		vret            typefinruncommission;
	BEGIN
		t.enter(cmethod_name);
		vret.clientaccount := finruncommissionscheme.getclientaccount();
		t.var('vRet.ClientAccount', vret.clientaccount);
	
		--vret.clientaccounthandle := finruncommissionscheme.getclientaccounthandle();
		t.var('vRet.ClientAccountHandle', vret.clientaccounthandle);
	
		vret.bankaccount := finruncommissionscheme.getbankaccount();
		t.var('vRet.BankAccount', vret.bankaccount);
	
		vret.docno := finruncommissionscheme.getdocno();
		t.var('vRet.DocNo', vret.docno);
	
		vret.entryno := finruncommissionscheme.getentryno();
		t.var('vRet.EntryNo', vret.entryno, csay_level);
	
		vcommissiondata := finruncommissionscheme.getcommissiondata;
	
		vret.commission := vcommissiondata.run.commission;
		t.var('vRet.Commission', vret.commission, csay_level);
	
		vret.value := vcommissiondata.run.value;
		t.var('vRet.Value', vret.value, csay_level);
	
		vret.valuecurrency := vcommissiondata.run.valuecurrency;
		t.var('vRet.ValueCurrency', vret.valuecurrency, csay_level);
	
		vret.exchange := vcommissiondata.data.exchange;
		t.var('vRet.Exchange', vret.exchange, csay_level);
	
		t.leave(cmethod_name);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name || '.GetFinRunCommissionData');
			RAISE;
	END;

	PROCEDURE entrydopre
	(
		pdocno    IN OUT NUMBER
	   ,pno       IN OUT NUMBER
	   ,pparams   IN OUT tsop_params
	   ,pexecmode IN NUMBER := csop_batchexec
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.EntryDoPre';
		vindex            VARCHAR2(100);
		ventrydosupported PLS_INTEGER;
		vcount            NUMBER;
	
		FUNCTION checkcontractno
		(
			pfirstcontract BOOLEAN
		   ,pparams        IN OUT tsop_params
		) RETURN BOOLEAN IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CheckContractNo';
			vcontract contract.typecontractitemrecord;
			vresult   BOOLEAN := TRUE;
		BEGIN
			t.enter(cmethod_name, 'pParams.ObjectType=' || pparams.objecttype);
		
			IF pparams.objecttype = getobjecttype(extract.object_name)
			   AND pparams.operationtype = coperationtype_extract
			THEN
				IF pfirstcontract
				THEN
					vcontract := contract.getcontractbyaccount(extract.sextractrow.debitaccountno
															  ,FALSE);
				
					vresult := vcontract.contractno IS NULL OR
							   pparams.contractrow.contractno = vcontract.contractno;
				
					IF NOT vresult
					THEN
						pparams.contractrow         := vcontract;
						pparams.extractrow.fromacct := extract.sextractrow.debitaccountno;
						sextractrow                 := pparams.extractrow;
						IF pparams.direction = sdirectdebit
						THEN
							pparams.debitaccountno  := pparams.extractrow.fromacct;
							pparams.creditaccountno := pparams.extractrow.toacct;
						
						ELSIF pparams.direction = sdirectcredit
						THEN
							pparams.debitaccountno  := pparams.extractrow.toacct;
							pparams.creditaccountno := pparams.extractrow.fromacct;
						END IF;
					END IF;
				
				ELSE
					vcontract := contract.getcontractbyaccount(extract.sextractrow.creditaccountno
															  ,FALSE);
				
					vresult := vcontract.contractno IS NULL OR
							   pparams.contractrow2.contractno = vcontract.contractno;
				
					IF NOT vresult
					THEN
						pparams.contractrow2        := vcontract;
						pparams.extractrow.fromacct := extract.sextractrow.creditaccountno;
						sextractrow                 := pparams.extractrow;
						IF pparams.direction = sdirectdebit
						THEN
							pparams.debitaccountno  := pparams.extractrow.fromacct;
							pparams.creditaccountno := pparams.extractrow.toacct;
						
						ELSIF pparams.direction = sdirectcredit
						THEN
							pparams.debitaccountno  := pparams.extractrow.toacct;
							pparams.creditaccountno := pparams.extractrow.fromacct;
						END IF;
					END IF;
				END IF;
			
			END IF;
		
			t.leave(cmethod_name, t.b2t(vresult));
			RETURN vresult;
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name);
				error.save(cmethod_name);
				RAISE;
		END;
	
		PROCEDURE getsop_params
		(
			pdocno  IN OUT NUMBER
		   ,pno     IN OUT NUMBER
		   ,pparams IN OUT tsop_params
		) IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetSOP_Params';
		BEGIN
			t.enter(cmethod_name, 'pParams.ObjectType=' || pparams.objecttype);
		
			CASE pparams.objecttype
			
				WHEN getobjecttype(extract.object_name) THEN
					t.note(cmethod_name, 'when GetObjectType(Extract.OBJECT_NAME)', csay_level);
					pparams.extractrow  := extract.getextractrecord();
					sextractrow         := pparams.extractrow;
					pparams.transferrow := extractmultitransfer.gettransferdata();
					t.var('pParams.TransferRow.EntryCode', pparams.transferrow.entrycode);
					IF pparams.transferrow.entrycode IS NOT NULL
					THEN
						pparams.operationtype  := coperationtype_transfer;
						pparams.debitaccountno := pparams.transferrow.debitaccountno;
						t.var('[Debit] pParams.DebitAccountNo', pparams.debitaccountno);
						pparams.contractrow := contract.getcontractbyaccount(pparams.debitaccountno
																			,FALSE);
						t.var('[Debit] pParams.ContractRow.No', pparams.contractrow.contractno);
						pparams.creditaccountno := pparams.transferrow.creditaccountno;
						t.var('[Credit] pParams.CreditAccountNo', pparams.creditaccountno);
						pparams.contractrow2 := contract.getcontractbyaccount(pparams.creditaccountno
																			 ,FALSE);
						t.var('[Credit] pParams.ContractRow2.No', pparams.contractrow2.contractno);
						pdocno := extractmultitransfer.getdocno();
						t.var('[Transfer] pDocNo', pdocno);
						pno := extractmultitransfer.getentryno();
						t.var('[Transfer] pNo', pno);
					ELSE
						pparams.operationtype := coperationtype_extract;
						pparams.contractrow   := contract.getcontractbyaccount(sextractrow.fromacct
																			  ,FALSE);
						t.var('[2] pParams.ContractRow.No', pparams.contractrow.contractno);
						pparams.contractrow2 := contract.getcontractbyaccount(sextractrow.toacct
																			 ,FALSE);
						t.var('[2] pParams.ContractRow2.No', pparams.contractrow2.contractno);
					
						pparams.direction := getdirection_extract(pparams.extractrow);
						t.var('pParams.Direction', pparams.direction);
						IF pparams.direction = sdirectdebit
						THEN
							pparams.debitaccountno := pparams.extractrow.fromacct;
							t.var('pParams.DebitAccountNo', pparams.debitaccountno);
							pparams.creditaccountno := pparams.extractrow.toacct;
							t.var('pParams.CreditAccountNo', pparams.creditaccountno);
						ELSIF pparams.direction = sdirectcredit
						THEN
							pparams.debitaccountno := pparams.extractrow.toacct;
							t.var('pParams.DebitAccountNo', pparams.debitaccountno);
							pparams.creditaccountno := pparams.extractrow.fromacct;
							t.var('pParams.CreditAccountNo', pparams.creditaccountno);
						
						END IF;
					END IF;
				
				WHEN getobjecttype(event.object_name) THEN
					t.note(cmethod_name, 'when GetObjectType(Event.OBJECT_NAME)', csay_level);
					pparams.eventrow := eventscheme.geteventrecord();
					seventrow        := pparams.eventrow;
					t.var('debit account no ', pparams.eventrow.debitaccount, csay_level);
					pparams.contractrow := contract.getcontractbyaccount(seventrow.debitaccount
																		,FALSE);
					t.var('pParams.ContractRow.No', pparams.contractrow.contractno);
					pparams.operationtype := coperationtype_event;
				
				WHEN getobjecttype(statementrt.object_name) THEN
					t.note(cmethod_name, 'when GetObjectType(StatementRT.OBJECT_NAME)', csay_level);
					pparams.statementrow := statementscheme.getstatementfeerecord();
					sstatementrow        := pparams.statementrow;
					t.var('debit account no', pparams.statementrow.debitaccount, csay_level);
					pparams.contractrow := contract.getcontractbyaccount(sstatementrow.debitaccount
																		,FALSE);
					t.var('pParams.ContractRow.No', pparams.contractrow.contractno);
					pparams.operationtype := coperationtype_statementrt;
				
				WHEN getobjecttype(finprofile.sobject_name) THEN
					t.note(cmethod_name, 'when GetObjectType(FinProfile.sOBJECT_NAME)', csay_level);
					pparams.finruncommission := getfinruncommissiondata();
					sfinruncommission        := pparams.finruncommission;
					t.var('account no', pparams.finruncommission.clientaccount, csay_level);
					pparams.contractrow := contract.getcontractbyaccount(pparams.finruncommission.clientaccount
																		,FALSE);
					t.var('pParams.ContractRow.No', pparams.contractrow.contractno);
					pparams.operationtype := coperationtype_finprofile;
				WHEN getobjecttype(loyaltyprogram.object_name) THEN
					t.note(cmethod_name
						  ,'when GetObjectType(LoyaltyProgram.OBJECT_NAME)'
						  ,csay_level);
					pparams.bonusrow := extractbonusscheme.getbonusdata();
					sbonusrow        := pparams.bonusrow;
					t.var(cmethod_name
						 ,'sBonusRow.AccountNo=' || pparams.bonusrow.accountno
						 ,csay_level);
					pparams.contractrow   := contract.getcontractbyaccount(pparams.bonusrow.accountno
																		  ,FALSE);
					pparams.operationtype := coperationtype_loyaltyprogram;
				ELSE
					err.seterror(err.refct_undefined_oper, cmethod_name);
					RETURN;
			END CASE;
			t.leave(cmethod_name);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name);
				error.save(cmethod_name);
				RAISE;
		END;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pParams.ObjectType=' || pparams.objecttype || ', pKey=' || pparams.key
			   ,csay_level);
		t.inpar('pDocNo', pdocno);
		t.inpar('pNo', pno);
		t.inpar('pExecMode', pexecmode);
	
		err.seterror(0, cmethod_name);
	
		scontractrow.no   := NULL;
		scontractrow.type := NULL;
		sdocno            := NULL;
		sentryno          := NULL;
	
		getsop_params(pdocno, pno, pparams);
	
		IF pparams.operationtype = coperationtype_transfer
		THEN
			vindex := to_char(pparams.objecttype) || '_' || nvl(pparams.key, cfinprofileindex) ||
					  ctransferprefix;
		ELSE
			vindex := to_char(pparams.objecttype) || '_' || nvl(pparams.key, cfinprofileindex);
		END IF;
		t.var('vIndex', vindex, csay_level);
	
		IF pparams.contractrow.contractno IS NOT NULL
		THEN
			scontractrow.no   := pparams.contractrow.contractno;
			scontractrow.type := pparams.contractrow.contracttype;
		
			IF sacurrenttransaction.exists(vindex)
			THEN
				error.raiseerror(err.bop_oper_ident_duplicate);
			
			END IF;
		
			sacurrenttransaction(vindex).contractno := pparams.contractrow.contractno;
			sacurrenttransaction(vindex).contracttype := pparams.contractrow.contracttype;
		
			sacurrenttransaction(vindex).packname := contracttype.getschemapackage(sacurrenttransaction(vindex)
																				   .contracttype);
			t.var('current package', sacurrenttransaction(vindex).packname, csay_level);
		
			IF sacurrenttransaction(vindex).packname IS NULL
			THEN
				error.raiseerror(err.refct_undefined_schema);
			
			END IF;
		
			IF pparams.operationtype = coperationtype_transfer
			THEN
				pparams.operamount := pparams.transferrow.debitvalue;
				t.var('[Debit] pParams.OperAmount', pparams.operamount);
				pparams.currency := pparams.transferrow.debitcurrency;
				t.var('[Debit] pParams.Currency', pparams.currency);
				pparams.direction := sdirectdebit;
				t.var('[Debit] pParams.Direction', pparams.direction);
			
			END IF;
		
			processcursor(pparams.contractrow.contractno
						 ,pdocno
						 ,pno
						 ,pparams
						 ,centrydopre
						 ,nvl(pexecmode, csop_batchexec));
			ventrydosupported := pparams.execresult;
			IF pparams.execresult = cexecres_unsupported
			THEN
				processcursor(pparams.contractrow.contractno
							 ,pdocno
							 ,pno
							 ,pparams
							 ,coppreexec
							 ,nvl(pexecmode, csop_batchexec));
			ELSE
				t.var('pDocNo', pdocno);
				t.var('pNo', pno);
				IF pparams.operationtype = coperationtype_transfer
				THEN
					IF pno IS NOT NULL
					THEN
						extractmultitransfer.setentryno(pno);
					ELSE
						error.raiseerror('Entry number not defined');
					END IF;
				END IF;
			END IF;
		
			vcount := 0;
			WHILE NOT checkcontractno(TRUE, pparams)
			LOOP
				t.note(cmethod_name, 'Changed contract no');
				sacurrenttransaction(vindex).contractno := pparams.contractrow.contractno;
				sacurrenttransaction(vindex).contracttype := pparams.contractrow.contracttype;
				sacurrenttransaction(vindex).packname := contracttype.getschemapackage(sacurrenttransaction(vindex)
																					   .contracttype);
				t.var('current package', sacurrenttransaction(vindex).packname, csay_level);
			
				IF sacurrenttransaction(vindex).packname IS NULL
				THEN
					error.raiseerror(err.refct_undefined_schema);
				END IF;
			
				processcursor(pparams.contractrow.contractno
							 ,pdocno
							 ,pno
							 ,pparams
							 ,centrydopre
							 ,nvl(pexecmode, csop_batchexec));
				ventrydosupported := pparams.execresult;
				IF pparams.execresult = cexecres_unsupported
				THEN
					processcursor(pparams.contractrow.contractno
								 ,pdocno
								 ,pno
								 ,pparams
								 ,coppreexec
								 ,nvl(pexecmode, csop_batchexec));
				ELSE
					t.var('pDocNo', pdocno);
					t.var('pNo', pno);
					IF pparams.operationtype = coperationtype_transfer
					THEN
						IF pno IS NOT NULL
						THEN
							extractmultitransfer.setentryno(pno);
						ELSE
							error.raiseerror('Entry number not defined');
						END IF;
					END IF;
				END IF;
				vcount := vcount + 1;
				IF vcount > 100
				THEN
					error.raiseerror('Too many account substitutions ' || vcount);
				END IF;
			END LOOP;
		END IF;
	
		t.note(cmethod_name, 'point 00, pParams.ObjectType=' || pparams.objecttype);
		IF pparams.objecttype = getobjecttype(extract.object_name)
		THEN
			t.note(cmethod_name, 'point 01');
			IF pparams.contractrow2.contractno IS NOT NULL
			THEN
				sacurrenttransaction(vindex).contractno2 := pparams.contractrow2.contractno;
				sacurrenttransaction(vindex).packname2 := contracttype.getschemapackage(pparams.contractrow2.contracttype);
				t.var('PackName2', sacurrenttransaction(vindex).packname2, csay_level);
				IF sacurrenttransaction(vindex).packname2 IS NULL
				THEN
					RETURN;
				ELSE
					IF pparams.operationtype = coperationtype_transfer
					THEN
						pparams.operamount := pparams.transferrow.creditvalue;
						t.var('[Credit] pParams.OperAmount', pparams.operamount);
						pparams.currency := pparams.transferrow.creditcurrency;
						t.var('[Credit] pParams.Currency', pparams.currency);
						pparams.direction := sdirectcredit;
						t.var('[Credit] pParams.Direction', pparams.direction);
					
					ELSE
					
						pparams.direction := service.iif(pparams.direction = sdirectdebit
														,sdirectcredit
														,sdirectdebit);
						t.var('[Credit2] pParams.Direction', pparams.direction);
					
					END IF;
				
					processcursor(pparams.contractrow2.contractno
								 ,pdocno
								 ,pno
								 ,pparams
								 ,centrydopre
								 ,nvl(pexecmode, csop_batchexec));
				
					IF pparams.execresult = cexecres_unsupported
					THEN
						processcursor(pparams.contractrow2.contractno
									 ,pdocno
									 ,pno
									 ,pparams
									 ,coppreexec2
									 ,nvl(pexecmode, csop_batchexec));
					ELSE
						t.var('pDocNo', pdocno);
						t.var('pNo', pno);
						IF pparams.operationtype = coperationtype_transfer
						THEN
							IF pno IS NOT NULL
							THEN
								extractmultitransfer.setentryno(pno);
							ELSE
								error.raiseerror('Entry number not defined');
							END IF;
						END IF;
					END IF;
				
					vcount := 0;
					WHILE NOT checkcontractno(FALSE, pparams)
					LOOP
						t.note(cmethod_name, 'Changed contract no 2');
						sacurrenttransaction(vindex).contractno2 := pparams.contractrow2.contractno;
						sacurrenttransaction(vindex).packname2 := contracttype.getschemapackage(pparams.contractrow2.contracttype);
						t.var('PackName2', sacurrenttransaction(vindex).packname2, csay_level);
						IF sacurrenttransaction(vindex).packname2 IS NULL
						THEN
							RETURN;
						ELSE
							processcursor(pparams.contractrow2.contractno
										 ,pdocno
										 ,pno
										 ,pparams
										 ,centrydopre
										 ,nvl(pexecmode, csop_batchexec));
						
							IF pparams.execresult = cexecres_unsupported
							THEN
								processcursor(pparams.contractrow2.contractno
											 ,pdocno
											 ,pno
											 ,pparams
											 ,coppreexec2
											 ,nvl(pexecmode, csop_batchexec));
							ELSE
								t.var('pDocNo', pdocno);
								t.var('pNo', pno);
								IF pparams.operationtype = coperationtype_transfer
								THEN
									IF pno IS NOT NULL
									THEN
										extractmultitransfer.setentryno(pno);
									ELSE
										error.raiseerror('Entry number not defined');
									END IF;
								END IF;
							END IF;
						END IF;
						vcount := vcount + 1;
						IF vcount > 100
						THEN
							error.raiseerror('Too many account substitutions ' || vcount);
						END IF;
					END LOOP;
				
				END IF;
			END IF;
		ELSIF pparams.objecttype = getobjecttype(finprofile.sobject_name)
		THEN
			t.note(cmethod_name, 'point 02');
			t.var('pParams.FinRunCommission.ClientAccount', pparams.finruncommission.clientaccount);
			t.var('sFinRunCommission.ClientAccount', sfinruncommission.clientaccount, csay_level);
			t.var('pParams.FinRunCommission.BankAccount', pparams.finruncommission.bankaccount);
			t.var('sFinRunCommission.BankAccount', sfinruncommission.bankaccount, csay_level);
			t.var('pParams.FinRunCommission.EntryNo', pparams.finruncommission.entryno, csay_level);
			t.var('sFinRunCommission.EntryNo', sfinruncommission.entryno, csay_level);
			t.var('vEntryDoSupported', ventrydosupported);
		
			IF nvl(ventrydosupported, cexecres_unsupported) = cexecres_unsupported
			THEN
				finruncommissionscheme.setclientaccount(sfinruncommission.clientaccount);
				finruncommissionscheme.setbankaccount(sfinruncommission.bankaccount);
				finruncommissionscheme.setentryno(sfinruncommission.entryno);
			ELSE
				finruncommissionscheme.setclientaccount(pparams.finruncommission.clientaccount);
				finruncommissionscheme.setbankaccount(pparams.finruncommission.bankaccount);
				finruncommissionscheme.setentryno(pparams.finruncommission.entryno);
			END IF;
		
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE oppreexec
	(
		pobjecttype IN NUMBER
	   ,pkey        IN VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.OpPreExec';
		vdocno      NUMBER;
		vno         NUMBER;
		vsop_params tsop_params;
	BEGIN
		t.enter(cmethod_name, 'pObjectType=' || pobjecttype || ', pKey=' || pkey, csay_level);
		sobject_type           := pobjecttype;
		sobject_key            := pkey;
		vsop_params.objecttype := pobjecttype;
		vsop_params.key        := pkey;
		entrydopre(vdocno, vno, vsop_params, csop_batchexec);
		t.leave(cmethod_name, 'vDocNo=' || vdocno || ', vNo=' || vno, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE entrydopost
	(
		pdocno    IN OUT NUMBER
	   ,pno       IN OUT NUMBER
	   ,pparams   IN OUT tsop_params
	   ,pexecmode IN NUMBER := csop_batchexec
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.EntryDoPost';
		vindex            VARCHAR2(100);
		ventrydosupported PLS_INTEGER;
	
		PROCEDURE getsop_params
		(
			pdocno  IN OUT NUMBER
		   ,pno     IN OUT NUMBER
		   ,pparams IN OUT tsop_params
		) IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetSOP_Params';
		BEGIN
			t.enter(cmethod_name, 'pParams.ObjectType=' || pparams.objecttype);
			err.seterror(0, cmethod_name);
			CASE pparams.objecttype
			
				WHEN getobjecttype(extract.object_name) THEN
					t.note(cmethod_name, 'when GetObjectType(Extract.OBJECT_NAME)', csay_level);
					pparams.extractrow := extract.getextractrecord();
					t.var('pParams.ExtractRow.DocNo', pparams.extractrow.docno);
					sextractrow.docno := pparams.extractrow.docno;
					pdocno            := pparams.extractrow.docno;
					t.var('[Extract] pDocNo=' || pdocno);
					pparams.transferrow := extractmultitransfer.gettransferdata();
					t.var('pParams.TransferRow.EntryCode', pparams.transferrow.entrycode);
					IF pparams.transferrow.entrycode IS NOT NULL
					THEN
						pparams.operationtype  := coperationtype_transfer;
						pparams.debitaccountno := pparams.transferrow.debitaccountno;
						t.var('pParams.DebitAccountNo', pparams.debitaccountno);
						pparams.creditaccountno := pparams.transferrow.creditaccountno;
						t.var('pParams.CreditAccountNo', pparams.creditaccountno);
						pparams.direction := NULL;
						pdocno            := extractmultitransfer.getdocno();
						t.var('[Transfer] pDocNo', pdocno);
						pno := extractmultitransfer.getentryno();
						t.var('[Transfer] pNo', pno);
					ELSE
						pparams.operationtype := coperationtype_extract;
					
						pparams.direction := getdirection_extract(pparams.extractrow);
						t.var('pParams.Direction', pparams.direction);
						IF pparams.direction = sdirectdebit
						THEN
							pparams.debitaccountno := pparams.extractrow.fromacct;
							t.var('pParams.DebitAccountNo', pparams.debitaccountno);
							pparams.creditaccountno := pparams.extractrow.toacct;
							t.var('pParams.CreditAccountNo', pparams.creditaccountno);
						ELSIF pparams.direction = sdirectcredit
						THEN
							pparams.debitaccountno := pparams.extractrow.toacct;
							t.var('pParams.DebitAccountNo', pparams.debitaccountno);
							pparams.creditaccountno := pparams.extractrow.fromacct;
							t.var('pParams.CreditAccountNo', pparams.creditaccountno);
						
						END IF;
					END IF;
				
				WHEN getobjecttype(event.object_name) THEN
					t.note(cmethod_name, 'when GetObjectType(Event.OBJECT_NAME)', csay_level);
					pparams.eventrow      := eventscheme.geteventrecord();
					seventrow             := pparams.eventrow;
					pparams.operationtype := coperationtype_event;
				
					pdocno := pparams.eventrow.docno;
					pno    := nvl(pparams.eventrow.entryno, 1);
				
				WHEN getobjecttype(statementrt.object_name) THEN
					t.note(cmethod_name, 'when GetObjectType(StatementRT.OBJECT_NAME)', csay_level);
					pparams.statementrow  := statementscheme.getstatementfeerecord();
					sstatementrow         := pparams.statementrow;
					pparams.operationtype := coperationtype_statementrt;
				
				WHEN getobjecttype(finprofile.sobject_name) THEN
					t.note(cmethod_name, 'when GetObjectType(FinProfile.sOBJECT_NAME)', csay_level);
				
					pparams.finruncommission := getfinruncommissiondata();
				
					sfinruncommission.entryno := pparams.finruncommission.entryno;
					pno                       := pparams.finruncommission.entryno;
				
					pdocno := pparams.finruncommission.docno;
				
					pparams.operationtype := coperationtype_finprofile;
				WHEN getobjecttype(loyaltyprogram.object_name) THEN
					t.note(cmethod_name
						  ,'when GetObjectType(LoyaltyProgram.OBJECT_NAME)'
						  ,csay_level);
				
					pparams.bonusrow := extractbonusscheme.getbonusdata();
					t.note('point pParams.BonusRow');
				
					sdocno := extractbonusscheme.getdocno();
					t.var(cmethod_name, 'sDocNo=' || sdocno, csay_level);
					pdocno                := sdocno;
					sentryno              := extractbonusscheme.getentryno();
					pno                   := sentryno;
					pparams.operationtype := coperationtype_loyaltyprogram;
				ELSE
					err.seterror(err.refct_undefined_oper, cmethod_name);
			END CASE;
			t.leave(cmethod_name);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name);
				error.save(cmethod_name);
				RAISE;
		END;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pParams.ObjectType=' || pparams.objecttype || ', pParams.Key=' || pparams.key
			   ,csay_level);
		t.inpar('pDocNo', pdocno);
		t.inpar('pNo', pno);
		t.inpar('pExecMode', pexecmode);
	
		err.seterror(0, cmethod_name);
	
		getsop_params(pdocno, pno, pparams);
		t.var('[1] pParams.DoneManually', t.b2t(pparams.donemanually));
	
		IF pparams.operationtype = coperationtype_transfer
		THEN
			vindex := to_char(pparams.objecttype) || '_' || nvl(pparams.key, cfinprofileindex) ||
					  ctransferprefix;
		ELSE
			vindex := to_char(pparams.objecttype) || '_' || nvl(pparams.key, cfinprofileindex);
		END IF;
		t.var('vIndex', vindex, csay_level);
	
		IF err.geterrorcode = err.refct_undefined_oper
		THEN
			IF sacurrenttransaction.exists(vindex)
			THEN
				sacurrenttransaction.delete(vindex);
			END IF;
			RETURN;
		END IF;
	
		IF sacurrenttransaction.exists(vindex)
		   AND sacurrenttransaction(vindex).packname IS NOT NULL
		THEN
			t.var('currentTransaction.package', sacurrenttransaction(vindex).packname, csay_level);
			scontractrow.no   := sacurrenttransaction(vindex).contractno;
			scontractrow.type := sacurrenttransaction(vindex).contracttype;
		
			IF pparams.operationtype = coperationtype_transfer
			THEN
				pparams.operamount := pparams.transferrow.debitvalue;
				t.var('[Debit] pParams.OperAmount', pparams.operamount);
				pparams.currency := pparams.transferrow.debitcurrency;
				t.var('[Debit] pParams.Currency', pparams.currency);
				pparams.direction := sdirectdebit;
				t.var('[Debit] pParams.Direction', pparams.direction);
			
			END IF;
		
			processcursor(sacurrenttransaction(vindex).contractno
						 ,pdocno
						 ,pno
						 ,pparams
						 ,centrydopost
						 ,nvl(pexecmode, csop_batchexec));
			ventrydosupported := pparams.execresult;
			IF pparams.execresult = cexecres_unsupported
			THEN
				processcursor(sacurrenttransaction(vindex).contractno
							 ,pdocno
							 ,pno
							 ,pparams
							 ,coppostexec
							 ,nvl(pexecmode, csop_batchexec));
			ELSE
				t.var('pDocNo', pdocno);
				t.var('pNo', pno);
				IF pparams.operationtype = coperationtype_transfer
				THEN
					IF pno IS NOT NULL
					THEN
						extractmultitransfer.setentryno(pno);
					ELSE
						error.raiseerror('Entry number not defined');
					END IF;
				END IF;
			END IF;
			t.var('[2] pParams.DoneManually', t.b2t(pparams.donemanually));
		END IF;
	
		IF pparams.objecttype = getobjecttype(extract.object_name)
		THEN
			IF sacurrenttransaction.exists(vindex)
			   AND sacurrenttransaction(vindex).contractno2 IS NOT NULL
			THEN
				t.note(cmethod_name, 'Point OPPOSTEXEC2', csay_level);
				IF sacurrenttransaction(vindex).packname2 IS NULL
				THEN
					sacurrenttransaction.delete(vindex);
					RETURN;
				ELSE
				
					IF pparams.operationtype = coperationtype_transfer
					THEN
						pparams.operamount := pparams.transferrow.creditvalue;
						t.var('[Credit] pParams.OperAmount', pparams.operamount);
						pparams.currency := pparams.transferrow.creditcurrency;
						t.var('[Credit] pParams.Currency', pparams.currency);
						pparams.direction := sdirectcredit;
						t.var('[Credit] pParams.Direction', pparams.direction);
					
					ELSE
					
						pparams.direction := service.iif(pparams.direction = sdirectdebit
														,sdirectcredit
														,sdirectdebit);
						t.var('[Credit2] pParams.Direction', pparams.direction);
					
					END IF;
				
					t.var('[3] pParams.DoneManually', t.b2t(pparams.donemanually));
					processcursor(sacurrenttransaction(vindex).contractno2
								 ,pdocno
								 ,pno
								 ,pparams
								 ,centrydopost
								 ,csop_batchexec);
					IF pparams.execresult = cexecres_unsupported
					THEN
						processcursor(sacurrenttransaction(vindex).contractno2
									 ,pdocno
									 ,pno
									 ,pparams
									 ,coppostexec2
									 ,csop_batchexec);
					ELSE
						t.var('pDocNo', pdocno);
						t.var('pNo', pno);
						IF pparams.operationtype = coperationtype_transfer
						THEN
							IF pno IS NOT NULL
							THEN
								extractmultitransfer.setentryno(pno);
							ELSE
								error.raiseerror('Entry number not defined');
							END IF;
						END IF;
					END IF;
					t.var('[4] pParams.DoneManually', t.b2t(pparams.donemanually));
				END IF;
			END IF;
		ELSIF pparams.objecttype = getobjecttype(finprofile.sobject_name)
		THEN
			t.var('pParams.FinRunCommission.EntryNo', pparams.finruncommission.entryno, csay_level);
			t.var('sFinRunCommission.EntryNo', sfinruncommission.entryno, csay_level);
			t.var('vEntryDoSupported', ventrydosupported);
		
			IF nvl(ventrydosupported, cexecres_unsupported) = cexecres_unsupported
			THEN
				finruncommissionscheme.setentryno(sfinruncommission.entryno);
			ELSE
				finruncommissionscheme.setentryno(pparams.finruncommission.entryno);
			END IF;
		
		ELSIF pparams.objecttype = getobjecttype(loyaltyprogram.object_name)
		THEN
			t.var('SetEntryNo sEntryNo', sentryno, csay_level);
			t.var('pNo', pno, csay_level);
			extractbonusscheme.setentryno(nvl(pno, sentryno));
		END IF;
	
		IF sacurrenttransaction.exists(vindex)
		THEN
			sacurrenttransaction.delete(vindex);
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			IF sacurrenttransaction.exists(vindex)
			THEN
				sacurrenttransaction.delete(vindex);
			END IF;
			RAISE;
	END;

	PROCEDURE oppostexec
	(
		pobjecttype   IN NUMBER
	   ,pkey          IN VARCHAR2
	   ,pdonemanually IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.OpPostExec';
		vdocno      NUMBER;
		vno         NUMBER;
		vsop_params tsop_params;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pObjectType=' || pobjecttype || ', pKey=' || pkey || ', pDoneManually=' ||
				t.b2t(pdonemanually)
			   ,csay_level);
		sobject_type             := pobjecttype;
		sobject_key              := pkey;
		vsop_params.objecttype   := pobjecttype;
		vsop_params.key          := pkey;
		vsop_params.donemanually := nvl(pdonemanually, FALSE);
	
		entrydopost(vdocno, vno, vsop_params, csop_batchexec);
		t.leave(cmethod_name, 'vDocNo=' || vdocno || ', vNo=' || vno, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE oppreundo
	(
		pdocno    IN OUT NUMBER
	   ,pno       IN OUT NUMBER
	   ,pparams   IN OUT tsop_params
	   ,pexecmode IN NUMBER := csop_batchexec
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.OpPreUndo[1]';
		vobjtype NUMBER;
		vbranch  NUMBER := seance.getbranch();
	
		PROCEDURE getsop_params(pparams IN OUT tsop_params) IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetSOP_Params';
		BEGIN
			t.enter(cmethod_name, 'pParams.ObjectType=' || pparams.objecttype);
		
			CASE pparams.objecttype
			
				WHEN getobjecttype(extract.object_name) THEN
					t.note(cmethod_name, 'when GetObjectType(Extract.OBJECT_NAME)', csay_level);
					pparams.extractrow    := extract.getextractrecord();
					sextractrow           := pparams.extractrow;
					pparams.operationtype := coperationtype_extract;
				
				WHEN getobjecttype(event.object_name) THEN
					t.note(cmethod_name, 'when GetObjectType(Event.OBJECT_NAME)', csay_level);
					pparams.eventrow      := eventscheme.geteventrecord();
					seventrow             := pparams.eventrow;
					pparams.operationtype := coperationtype_event;
				WHEN extractdelayscheme.getobjecttype() THEN
					t.note(cmethod_name, 'when ExtractDelayScheme.GetObjectType()', csay_level);
					pparams.delayrow      := extractdelayscheme.getdelayrecord();
					sdelayrow             := pparams.delayrow;
					pparams.operationtype := coperationtype_extractdelay;
				
				WHEN getobjecttype(statementrt.object_name) THEN
					t.note(cmethod_name, 'when GetObjectType(StatementRT.OBJECT_NAME)', csay_level);
					pparams.statementrow := statementscheme.getstatementfeerecord();
					t.var('debit account no', pparams.statementrow.debitaccount, csay_level);
					sstatementrow         := pparams.statementrow;
					pparams.operationtype := coperationtype_statementrt;
				
				ELSE
					t.note(cmethod_name, 'Err.REFCT_UNDEFINED_OPER', csay_level);
					err.seterror(err.refct_undefined_oper, cmethod_name);
					RETURN;
			END CASE;
			t.leave(cmethod_name);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name);
				error.save(cmethod_name);
				RAISE;
		END;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pParams.ObjectType=' || pparams.objecttype || ', pParams.Key=' || pparams.key
			   ,csay_level);
		t.inpar('pDocNo', pdocno);
		t.inpar('pNo', pno);
		t.inpar('pExecMode', pexecmode);
	
		err.seterror(0, cmethod_name);
	
		getsop_params(pparams);
	
		IF err.geterrorcode = err.refct_undefined_oper
		THEN
			RETURN;
		END IF;
	
		IF pparams.objecttype = extractdelayscheme.getobjecttype()
		THEN
			vobjtype := getobjecttype(extract.object_name);
		
		ELSE
			vobjtype := pparams.objecttype;
		
		END IF;
	
		FOR i IN (SELECT *
				  FROM   tcontractrollback
				  WHERE  branch = vbranch
				  AND    object_type = vobjtype
				  AND    object_key = pparams.key)
		LOOP
			sundorec        := i;
			scontractrow.no := i.contractno;
			t.var('i.ContractNo', i.contractno);
			scontractrow.type := contract.gettype(scontractrow.no);
		
			pparams.undorec                  := i;
			pparams.contractrow.contractno   := i.contractno;
			pparams.contractrow.contracttype := scontractrow.type;
		
			processcursor(pparams.contractrow.contractno
						 ,pdocno
						 ,pno
						 ,pparams
						 ,coppreundo
						 ,csop_batchexec);
		
		END LOOP;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE oppreundo
	(
		pobjecttype IN NUMBER
	   ,pkey        IN VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.OpPreUndo[2]';
		vdocno      NUMBER;
		vno         NUMBER;
		vsop_params tsop_params;
	BEGIN
		t.enter(cmethod_name, 'pObjectType=' || pobjecttype || ', pKey=' || pkey, csay_level);
		sobject_type           := pobjecttype;
		sobject_key            := pkey;
		vsop_params.objecttype := pobjecttype;
		vsop_params.key        := pkey;
		oppreundo(vdocno, vno, vsop_params, csop_batchexec);
		t.leave(cmethod_name, 'vDocNo=' || vdocno || ', vNo=' || vno, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
	END;

	PROCEDURE oppostundo
	(
		pdocno    IN OUT NUMBER
	   ,pno       IN OUT NUMBER
	   ,pparams   IN OUT tsop_params
	   ,pexecmode IN NUMBER := csop_batchexec
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.OpPostUndo[1]';
		vobjtype NUMBER;
		vbranch  NUMBER := seance.getbranch();
	
		PROCEDURE getsop_params(pparams IN OUT tsop_params) IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetSOP_Params';
		BEGIN
			t.enter(cmethod_name, 'pParams.ObjectType=' || pparams.objecttype);
		
			CASE pparams.objecttype
			
				WHEN getobjecttype(extract.object_name) THEN
					t.note(cmethod_name, 'when GetObjectType(Extract.OBJECT_NAME)', csay_level);
					pparams.extractrow    := extract.getextractrecord();
					sextractrow           := pparams.extractrow;
					pparams.operationtype := coperationtype_extract;
				
				WHEN getobjecttype(event.object_name) THEN
					t.note(cmethod_name, 'when GetObjectType(Event.OBJECT_NAME)', csay_level);
					pparams.eventrow      := eventscheme.geteventrecord();
					seventrow             := pparams.eventrow;
					pparams.operationtype := coperationtype_event;
				WHEN extractdelayscheme.getobjecttype() THEN
					t.note(cmethod_name, 'when ExtractDelayScheme.GetObjectType()', csay_level);
					pparams.delayrow      := extractdelayscheme.getdelayrecord();
					sdelayrow             := pparams.delayrow;
					pparams.operationtype := coperationtype_extractdelay;
				
				WHEN getobjecttype(statementrt.object_name) THEN
					t.note(cmethod_name, 'when GetObjectType(StatementRT.OBJECT_NAME)', csay_level);
					pparams.statementrow := statementscheme.getstatementfeerecord();
					t.var('debit account no', pparams.statementrow.debitaccount, csay_level);
					sstatementrow         := pparams.statementrow;
					pparams.operationtype := coperationtype_statementrt;
				
				ELSE
					err.seterror(err.refct_undefined_oper, cmethod_name);
					RETURN;
			END CASE;
			t.leave(cmethod_name);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name);
				error.save(cmethod_name);
				RAISE;
		END;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pParams.ObjectType=' || pparams.objecttype || ', pParams.Key=' || pparams.key
			   ,csay_level);
		t.inpar('pDocNo', pdocno);
		t.inpar('pNo', pno);
		t.inpar('pExecMode', pexecmode);
	
		err.seterror(0, cmethod_name);
	
		getsop_params(pparams);
	
		IF err.geterrorcode = err.refct_undefined_oper
		THEN
			RETURN;
		END IF;
	
		IF pparams.objecttype = extractdelayscheme.getobjecttype()
		THEN
			vobjtype := getobjecttype(extract.object_name);
		
		ELSE
			vobjtype := pparams.objecttype;
		
		END IF;
	
		FOR i IN (SELECT *
				  FROM   tcontractrollback
				  WHERE  branch = vbranch
				  AND    object_type = vobjtype
				  AND    object_key = pparams.key)
		LOOP
			sundorec          := i;
			scontractrow.no   := i.contractno;
			scontractrow.type := contract.gettype(scontractrow.no);
		
			pparams.undorec                  := i;
			pparams.contractrow.contractno   := i.contractno;
			pparams.contractrow.contracttype := scontractrow.type;
		
			processcursor(pparams.contractrow.contractno
						 ,pdocno
						 ,pno
						 ,pparams
						 ,coppostundo
						 ,csop_batchexec);
		
		END LOOP;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE oppostundo
	(
		pobjecttype IN NUMBER
	   ,pkey        IN VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.OpPostUndo[2]';
		vdocno      NUMBER;
		vno         NUMBER;
		vsop_params tsop_params;
	BEGIN
		t.enter(cmethod_name, 'pObjectType=' || pobjecttype || ', pKey=' || pkey, csay_level);
		sobject_type           := pobjecttype;
		sobject_key            := pkey;
		vsop_params.objecttype := pobjecttype;
		vsop_params.key        := pkey;
		oppostundo(vdocno, vno, vsop_params, csop_batchexec);
		t.leave(cmethod_name, 'vDocNo=' || vdocno || ', vNo=' || vno, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
	END;

	PROCEDURE opdelete
	(
		pobjecttype IN NUMBER
	   ,pkey        IN VARCHAR2
	   ,pall        BOOLEAN
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.OpDelete';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		err.seterror(0, cmethod_name);
		sobject_type := pobjecttype;
	
		IF NOT pall
		THEN
			DELETE FROM tcontractrollback
			WHERE  branch = vbranch
			AND    object_type = pobjecttype
			AND    object_key = pkey;
		ELSE
			DELETE FROM tcontractrollback
			WHERE  branch = vbranch
			AND    object_type = pobjecttype
			AND    object_key LIKE pkey || '%';
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
	END opdelete;

	PROCEDURE opdown IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.OpDown';
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		sop_closeallcursors();
		sacurrenttransaction.delete;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
	END opdown;

	PROCEDURE sop_init IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SOP_Init';
	BEGIN
		s.say(cmethod_name || ': Start ', csay_level);
		sop_cleararray();
		sasop_contractlist.delete;
		s.say(cmethod_name || ': Finish ', csay_level);
	END sop_init;

	PROCEDURE sop_down IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SOP_Down';
	
		vcontractno contract.typecontractno;
	BEGIN
		s.say(cmethod_name || ': Start, count ' || sasop_cursors.count, csay_level);
	
		sop_closeallcursors;
	
		t.var('saSOP_ContractList.Count', sasop_contractlist.count);
		vcontractno := sasop_contractlist.first;
		WHILE vcontractno IS NOT NULL
		LOOP
			t.var('ContractNo', vcontractno);
			t.var('Package', sasop_contractlist(vcontractno));
			IF contractschemas.existsmethod(sasop_contractlist(vcontractno)
										   ,'SOP_Down'
										   ,'/in:V/ret:E')
			THEN
				EXECUTE IMMEDIATE upper('begin ' || sasop_contractlist(vcontractno) ||
										'.SOP_Down(:CONTNO); end;')
					USING IN vcontractno;
			END IF;
		
			vcontractno := sasop_contractlist.next(vcontractno);
		END LOOP;
		sasop_contractlist.delete;
	
		s.say(cmethod_name || ': Finish ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
	END sop_down;

	FUNCTION filloperlist
	(
		pcontracttype IN NUMBER
	   ,pdialog       IN NUMBER
	   ,pitemname     IN VARCHAR2
	) RETURN NUMBER IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.FillOperList';
		cexecprocname CONSTANT VARCHAR2(100) := 'FillOperList';
	
		vpackage VARCHAR2(40);
	BEGIN
		vpackage := contracttype.getschemapackage(pcontracttype);
		IF (vpackage IS NULL)
		THEN
			RETURN err.geterrorcode;
		END IF;
	
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:N/in:V/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
							  '(:PDIALOG, :PITEMNAME); END;'
				USING pdialog, pitemname;
		ELSE
			err.seterror(err.refct_undefined_oper, cmethod_name);
			RETURN err.refct_undefined_oper;
		END IF;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END filloperlist;

	FUNCTION execoperation
	(
		pcontractrow IN fintypes.typecontractrow
	   ,pcode        IN VARCHAR2
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.ExecOperation(Row)';
		cfuncname    CONSTANT VARCHAR2(100) := 'ExecOperation';
		vret     NUMBER;
		vpackage VARCHAR2(40);
	
		vsavedcontractrow tcontract%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractrow.no || ', pCode=' || pcode);
		vsavedcontractrow := scontractrow;
		t.var('SavedContractRow.No', vsavedcontractrow.no);
		scontractrow  := pcontractrow;
		srollbackdata := NULL;
		vpackage      := contracttype.getschemapackage(scontractrow.type);
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/ret:N')
		THEN
			EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.' || cfuncname || '(:CODE);  END;'
				USING OUT vret, IN pcode;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname);
		END IF;
		scontractrow := vsavedcontractrow;
		t.leave(cmethod_name);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			scontractrow := vsavedcontractrow;
			RAISE;
	END execoperation;

	FUNCTION execoperation
	(
		pcontractno IN VARCHAR2
	   ,pcode       IN VARCHAR2
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.ExecOperation';
		cfuncname    CONSTANT VARCHAR2(100) := 'ExecOperation';
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno || ', pCode=' || pcode);
		RETURN execoperation(contract.getcontractrowtype(pcontractno), pcode);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END execoperation;

	PROCEDURE exectemplate
	(
		pcontractno   IN tcontract.no%TYPE
	   ,ptemplateid   IN NUMBER
	   ,orunprintform OUT NUMBER
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.ExecTemplate';
		cexecprocname CONSTANT VARCHAR2(100) := 'ExecTemplate';
		vpackage VARCHAR2(40);
	
		vaccount taccount.accountno%TYPE;
		vaparams apitypes.typesoparamarray;
	BEGIN
		s.say(cmethod_name || ': Start', csay_level);
		orunprintform := operationsingle.cfdontneedtocall;
		scontractrow  := contract.getcontractrowtype(pcontractno);
		srollbackdata := NULL;
		vpackage      := contracttype.getschemapackage(scontractrow.type);
		IF vpackage IS NULL
		THEN
			error.raiseerror(excsystem_error
							,'Not found name of scheme batch for contract type: ' ||
							 scontractrow.type);
		ELSE
		
			IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:I/out:N/ret:E')
			THEN
				EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
								  '(:CONTRACTNO, :CODE, :RUNPRINTFORM);  END;'
					USING IN pcontractno, IN ptemplateid, OUT orunprintform;
			ELSE
			
				err.seterror(0, cmethod_name);
				vaccount := getmainaccount(pcontractno, NULL);
				IF vaccount IS NOT NULL
				THEN
					vaparams      := sot_core.gettemplate(ptemplateid).params;
					orunprintform := sot_core.executeoperation_retrfcflag(ptemplateid
																		 ,vaccount
																		 ,vaparams);
				ELSE
					error.raiseerror(excsystem_error, 'No account defined to execute operation');
				END IF;
			END IF;
		END IF;
		s.say(cmethod_name || ': Finish', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END exectemplate;

	FUNCTION initoper
	(
		pctype  IN NUMBER
	   ,popcode NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.InitOper';
		cfuncname    CONSTANT VARCHAR2(100) := 'InitOper';
		vpackage VARCHAR2(40);
		vret     NUMBER;
	BEGIN
		vpackage := contracttype.getschemapackage(pctype);
		IF vpackage IS NULL
		THEN
			vret := err.geterrorcode();
		ELSE
			spackagetemp := vpackage;
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:N/in:N/ret:N')
			THEN
				EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.' || cfuncname ||
								  '(:TYPE,:CODE);  END;'
					USING OUT vret, IN pctype, IN popcode;
			
				IF vret = 0
				THEN
					prepareglobalcursor(pctype, vpackage, 'ExecOper');
				END IF;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage
														  ,cfuncname
														  ,pdoexception => FALSE);
				err.seterror(err.refct_undefined_oper, cmethod_name);
				vret := err.refct_undefined_oper;
			END IF;
		
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END initoper;

	FUNCTION execoper(pcontractno IN VARCHAR2) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ExecOper';
		vcontractno tcontract.no%TYPE;
		vret        NUMBER;
	BEGIN
		vcontractno := contract.getcurrentno;
		contract.setcurrentno(pcontractno);
		saadjusting.delete;
	
		scontractrow := contract.getcontractrowtype(pcontractno);
	
		vret := execglobalcursor(scontractrow.type);
		contract.setcurrentno(vcontractno);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			contract.setcurrentno(vcontractno);
			RAISE;
	END execoper;

	PROCEDURE downoper(pctype IN NUMBER) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.DownOper';
		cexecprocname CONSTANT VARCHAR2(100) := 'DownOper';
	
		vpackage VARCHAR2(40);
	BEGIN
		vpackage := contracttype.getschemapackage(pctype);
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:N/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname || '(:TYPE); END;'
				USING IN pctype;
		END IF;
	
		IF globalcursoropened(to_char(pctype))
		THEN
			closeglobalcursor(to_char(pctype));
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethod_name);
			closeglobalcursor(to_char(pctype));
		
	END downoper;

	FUNCTION initundooper
	(
		pctype  IN NUMBER
	   ,popcode NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.InitUndoOper';
		cfuncname    CONSTANT VARCHAR2(100) := 'InitUndoOper';
		vpackage VARCHAR2(40);
		vret     NUMBER;
	BEGIN
		vpackage := contracttype.getschemapackage(pctype);
		IF (vpackage IS NULL)
		THEN
			vret := err.geterrorcode;
		ELSE
			spackagetemp := vpackage;
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:N/in:N/ret:N')
			THEN
				EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.' || cfuncname ||
								  '(:TYPE,:CODE); END;'
					USING OUT vret, IN pctype, IN popcode;
				IF vret = 0
				THEN
					prepareglobalcursor(pctype, vpackage, 'EXECUNDOOPER');
				END IF;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage
														  ,cfuncname
														  ,pdoexception => FALSE);
				err.seterror(err.refct_undefined_oper, cmethod_name);
				vret := err.refct_undefined_oper;
			END IF;
		
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END initundooper;

	FUNCTION execundooper(pcontractno IN VARCHAR2) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ExecUndoOper';
	BEGIN
		scontractrow := contract.getcontractrowtype(pcontractno);
	
		RETURN execglobalcursor(scontractrow.type);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END execundooper;

	PROCEDURE downundooper(pctype IN NUMBER) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.DownUndoOper';
		cexecprocname CONSTANT VARCHAR2(100) := 'DownUndoOper';
		vpackage VARCHAR2(40);
	BEGIN
		vpackage := contracttype.getschemapackage(pctype);
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:N/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname || '(:TYPE); END;'
				USING IN pctype;
		END IF;
	
		IF globalcursoropened(to_char(pctype))
		THEN
			closeglobalcursor(to_char(pctype));
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethod_name);
			closeglobalcursor(to_char(pctype));
		
	END downundooper;

	PROCEDURE sop_postexec
	(
		pdocno    IN OUT NUMBER
	   ,pno       IN OUT NUMBER
	   ,pparams   IN tsop_params
	   ,pexecmode IN NUMBER := csop_manualexec
	) IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.SOP_PostExec';
		vcontractnodebit  tcontract.no%TYPE;
		vcontractnocredit tcontract.no%TYPE;
		vparams           tsop_params;
	BEGIN
		s.say(cmethod_name || ': ', csay_level);
	
		vparams          := pparams;
		vcontractnodebit := contract.getcontractnobyaccno(account.getaccountno(vparams.debitaccount)
														 ,FALSE);
		s.say('vContractNoDebit=' || vcontractnodebit, csay_level);
		vcontractnocredit := contract.getcontractnobyaccno(account.getaccountno(vparams.creditaccount)
														  ,FALSE);
		s.say('vContractNoCredit=' || vcontractnocredit, csay_level);
		IF vcontractnodebit IS NULL
		   AND vcontractnocredit IS NULL
		THEN
			s.say('return', csay_level);
			RETURN;
		END IF;
	
		IF vcontractnodebit IS NOT NULL
		THEN
			sop_params           := vparams;
			sop_params.direction := sdirectdebit;
			processcursor(vcontractnodebit, pdocno, pno, vparams, csop_postexec, pexecmode);
		END IF;
		IF vcontractnocredit IS NOT NULL
		THEN
			sop_params           := vparams;
			sop_params.direction := sdirectcredit;
			processcursor(vcontractnocredit, pdocno, pno, vparams, csop_postexec, pexecmode);
		
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END sop_postexec;

	FUNCTION tran_getcursorcode
	(
		pschematype IN NUMBER
	   ,pproccode   IN NUMBER
	) RETURN PLS_INTEGER IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.Tran_GetCursorCode';
	BEGIN
		RETURN pschematype * 8 + pproccode;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END tran_getcursorcode;

	PROCEDURE tran_cursorexec
	(
		pschematype IN NUMBER
	   ,pproccode   IN NUMBER
	   ,pcontractno IN VARCHAR2
	   ,pdocno      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.Tran_CursorExec';
		vcursorcode PLS_INTEGER;
		vcursorid   NUMBER;
		vres        NUMBER;
		vschema     VARCHAR2(30);
	BEGIN
		vcursorcode := tran_getcursorcode(pschematype, pproccode);
		vschema     := contractschemas.getrecord(pschematype).packagename;
		IF NOT satran_cursorarray.exists(vcursorcode)
		THEN
			satran_cursorarray(vcursorcode) := tran_cursorprepare(vschema, pproccode);
		END IF;
		IF NOT satran_cursorarray(vcursorcode).supported
		THEN
			s.say(cmethod_name || ': is not supported', csay_level);
			RETURN;
		END IF;
		vcursorid := satran_cursorarray(vcursorcode).cursorid;
		dbms_sql.bind_variable(vcursorid, ':CNO', pcontractno);
		dbms_sql.bind_variable(vcursorid, ':DOCNO', pdocno);
		BEGIN
			vres := dbms_sql.execute(vcursorid);
		EXCEPTION
			WHEN method_not_found THEN
				s.say(cmethod_name || ': is not found', csay_level);
				dbms_sql.close_cursor(vcursorid);
				satran_cursorarray(vcursorcode).supported := FALSE;
			WHEN OTHERS THEN
				RAISE;
		END;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END tran_cursorexec;

	PROCEDURE tran_postexec(pdocno IN NUMBER) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.TranPostExec';
		CURSOR curcontracts
		(
			pbranch IN NUMBER
		   ,pdocno  IN NUMBER
		) IS
			SELECT DISTINCT c.no
						   ,ct.schematype
			FROM   tcontractitem ci
				  ,tcontract c
				  ,tcontracttype ct
				  ,(SELECT branch
						  ,debitaccount AS accountno
					FROM   tentry
					WHERE  branch = pbranch
					AND    docno = pdocno
					UNION
					SELECT branch
						  ,creditaccount AS accountno
					FROM   tentry
					WHERE  branch = pbranch
					AND    docno = pdocno) acc
			WHERE  ci.branch = acc.branch
			AND    ci.key = acc.accountno
			AND    c.branch = ci.branch
			AND    c.no = ci.no
			AND    ct.branch = c.branch
			AND    ct.type = c.type;
	BEGIN
		s.say(cmethod_name || ': pDocNo = ' || pdocno, csay_level);
		FOR i IN curcontracts(seance.getbranch, pdocno)
		LOOP
			s.say(cmethod_name || ': i.No = ' || i.no, csay_level);
			s.say(cmethod_name || ': i.SchemaType = ' || i.schematype, csay_level);
			tran_cursorexec(i.schematype, ctran_postexec, i.no, pdocno);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END tran_postexec;

	PROCEDURE sop_acceptpreexec
	(
		pcontractno      IN VARCHAR2
	   ,pparams          IN tsop_params
	   ,pacceptentrylist IN OUT tsop_entrylist
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.SOP_AcceptPreExec';
		cexecprocname CONSTANT VARCHAR2(100) := 'SOP_AcceptPreExec';
		vpackage VARCHAR2(100);
	BEGIN
		s.say(cmethod_name || ': ', csay_level);
		sop_params    := pparams;
		sop_entrylist := pacceptentrylist;
		scontractrow  := contract.getcontractrowtype(pcontractno);
	
		vpackage := contracttype.getschemapackage(scontractrow.type);
	
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:S/inout:A/ret:E')
		THEN
			EXECUTE IMMEDIATE upper('BEGIN ' || vpackage || '.' || cexecprocname ||
									'(:CONTNO, ContractTypeSchema.SOP_Params, ContractTypeSchema.SOP_EntryList); END;')
				USING IN pcontractno;
		END IF;
	
		pacceptentrylist := sop_entrylist;
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END sop_acceptpreexec;

	PROCEDURE sop_acceptpostexec
	(
		pcontractno      IN VARCHAR2
	   ,pparams          IN tsop_params
	   ,pacceptentrylist IN OUT tsop_entrylist
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.SOP_AcceptPostExec';
		cexecprocname CONSTANT VARCHAR2(100) := 'SOP_AcceptPostExec';
		vpackage VARCHAR2(100);
	BEGIN
		s.say(cmethod_name || ': ', csay_level);
		sop_params    := pparams;
		sop_entrylist := pacceptentrylist;
		scontractrow  := contract.getcontractrowtype(pcontractno);
	
		vpackage := contracttype.getschemapackage(scontractrow.type);
		IF vpackage IS NULL
		THEN
			error.raiseerror(excsystem_error
							,'Not found name of scheme batch for contract type: ' ||
							 scontractrow.type);
		END IF;
	
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:S/inout:A/ret:E')
		THEN
			EXECUTE IMMEDIATE upper('BEGIN ' || vpackage || '.' || cexecprocname ||
									'(:CONTNO, ContractTypeSchema.SOP_Params, ContractTypeSchema.SOP_EntryList); END;')
				USING IN pcontractno;
			pacceptentrylist := sop_entrylist;
		END IF;
	
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END sop_acceptpostexec;

	FUNCTION cancontractmakepayment(pcontractno IN VARCHAR2) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.CanContractMakePayment';
		cfuncname    CONSTANT VARCHAR2(100) := 'CanContractMakePayment';
		vpackage VARCHAR2(40);
		vret     NUMBER := 0;
	BEGIN
		scontractrow := contract.getcontractrowtype(pcontractno);
		vpackage     := contracttype.getschemapackage(scontractrow.type);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/ret:N')
		THEN
			EXECUTE IMMEDIATE 'BEGIN :RET := SERVICE.IIF(' || vpackage || '.' || cfuncname ||
							  ', 1, 0); END;'
				USING OUT vret;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname, pdoexception => FALSE);
			err.seterror(err.refct_undefined_oper, cmethod_name);
			vret := err.refct_undefined_oper;
		END IF;
		RETURN vret = 1;
	EXCEPTION
	
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN FALSE;
	END cancontractmakepayment;

	FUNCTION reserveforpayment(pregpaycontractrec IN OUT apipayment.tregpaycontractrec) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.ReserveForPayment';
		cfuncname    CONSTANT VARCHAR2(100) := 'ReserveForPayment';
		vret     NUMBER := 0;
		vpackage VARCHAR2(40);
	
	BEGIN
		scontractrow := contract.getcontractrowtype(pregpaycontractrec.contractno);
		vpackage     := contracttype.getschemapackage(scontractrow.type);
		IF vpackage IS NULL
		THEN
			vret := err.geterrorcode();
		ELSE
			IF contractschemas.existsmethod(vpackage, cfuncname, '/inout:S/ret:N')
			THEN
				sregpaycontractrec := pregpaycontractrec;
				EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.' || cfuncname ||
								  '(CONTRACTTYPESCHEMA.SREGPAYCONTRACTREC); END;'
					USING OUT vret;
				pregpaycontractrec := sregpaycontractrec;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage
														  ,cfuncname
														  ,pdoexception => FALSE);
				err.seterror(err.refct_undefined_oper, cmethod_name);
				vret := err.refct_undefined_oper;
			END IF;
		END IF;
		RETURN vret;
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END reserveforpayment;

	FUNCTION unreserveforpayment(pregpaycontractrec IN apipayment.tregpaycontractrec) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.UnReserveForPayment';
		cfuncname    CONSTANT VARCHAR2(100) := 'UnReserveForPayment';
		vret     NUMBER := 0;
		vpackage VARCHAR2(40);
	
	BEGIN
		scontractrow := contract.getcontractrowtype(pregpaycontractrec.contractno);
		vpackage     := contracttype.getschemapackage(scontractrow.type);
		IF vpackage IS NULL
		THEN
			vret := err.geterrorcode();
		ELSE
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:S/ret:N')
			THEN
				sregpaycontractrec := pregpaycontractrec;
				EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.' || cfuncname ||
								  '(CONTRACTTYPESCHEMA.SREGPAYCONTRACTREC); END;'
					USING OUT vret;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage
														  ,cfuncname
														  ,pdoexception => FALSE);
				err.seterror(err.refct_undefined_oper, cmethod_name);
				vret := err.refct_undefined_oper;
			END IF;
		
		END IF;
		RETURN vret;
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END unreserveforpayment;

	FUNCTION executepayment
	(
		pstage             NUMBER
	   ,pparams            toperpaymentparams
	   ,pregpaycontractrec IN OUT apipayment.tregpaycontractrec
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ExecutePayment';
		cfuncname    CONSTANT VARCHAR2(100) := 'ExecutePayment';
		vret     NUMBER := 0;
		vpackage VARCHAR2(40);
	BEGIN
		saadjusting.delete;
		scontractrow := contract.getcontractrowtype(pregpaycontractrec.contractno);
		vpackage     := contracttype.getschemapackage(scontractrow.type);
		IF vpackage IS NULL
		THEN
			vret := err.geterrorcode;
		ELSE
			soperstage         := pstage;
			sregpayparams      := pparams;
			sregpaycontractrec := pregpaycontractrec;
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:N/in:S/inout:S/ret:N')
			THEN
				EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.' || cfuncname ||
								  '(ContractTypeSchema.sOperStage, ContractTypeSchema.sRegPayParams, ContractTypeSchema.sRegPayContractRec); END;'
					USING OUT vret;
				pregpaycontractrec := sregpaycontractrec;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage
														  ,cfuncname
														  ,pdoexception => FALSE);
				err.seterror(err.refct_undefined_oper, cmethod_name);
				vret := err.refct_undefined_oper;
			END IF;
		END IF;
		RETURN vret;
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END executepayment;

	PROCEDURE initgetdata4dc(pcontracttype IN NUMBER) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.InitGetData4DC';
		cexecprocname CONSTANT VARCHAR2(100) := 'InitGetData4DC';
	BEGIN
		spackage(pcontracttype) := contracttype.getschemapackage(pcontracttype);
		IF spackage(pcontracttype) IS NULL
		THEN
			error.raisewhenerr();
		
		END IF;
		IF contractschemas.existsmethod(spackage(pcontracttype), cexecprocname, '/in:N/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || upper(spackage(pcontracttype)) || '.' ||
							  upper(cexecprocname) || '(:TYPE); END;'
				USING IN pcontracttype;
		ELSE
			contractschemas.reportunsupportedoperation(spackage(pcontracttype), cexecprocname);
		END IF;
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END initgetdata4dc;

	PROCEDURE execgetdata4dc
	(
		pcontractno   IN VARCHAR2
	   ,pcontractsh   IN OUT apitypesfordc.typecontractsnapshotrecord
	   ,pitemsshlist  IN apitypesfordc.typecontractitemshapshotlist
	   ,pcontractrec  OUT apitypesfordc.typecontractrecord
	   ,pitemslist    OUT apitypesfordc.typecontractitemlist
	   ,ptranslist    OUT apitypesfordc.typedctranslist
	   ,prollbackdata OUT VARCHAR2
	   ,poverduelist  OUT apitypesfordc.typecontractoverduelist
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetData4DebtCollection';
		vcontracttype NUMBER;
		cexecprocname CONSTANT VARCHAR2(100) := 'ExecGetData4DC';
	BEGIN
		scontractsh  := pcontractsh;
		sitemsshlist := pitemsshlist;
		scontractrec := NULL;
		sitemslist.delete;
		stranslist.delete;
		soverduelist.delete;
	
		vcontracttype := contract.gettype(pcontractno);
		IF vcontracttype IS NULL
		THEN
		
			error.raisewhenerr();
		
		END IF;
	
		IF NOT spackage.exists(vcontracttype)
		THEN
			error.raiseerror('Internal error: getting data for DebtCollector without preparation');
		END IF;
	
		IF contractschemas.existsmethod(spackage(vcontracttype)
									   ,cexecprocname
									   ,'/in:V/inout:S/in:A/out:S/out:A/out:A/out:V/out:A/ret:E')
		THEN
		
			EXECUTE IMMEDIATE 'BEGIN ' || upper(spackage(vcontracttype)) || '.' ||
							  upper(cexecprocname) ||
							  '(:NO, CONTRACTTYPESCHEMA.SCONTRACTSH, CONTRACTTYPESCHEMA.SITEMSSHLIST, CONTRACTTYPESCHEMA.SCONTRACTREC, CONTRACTTYPESCHEMA.SITEMSLIST, CONTRACTTYPESCHEMA.STRANSLIST, :RB, CONTRACTTYPESCHEMA.SOVERDUELIST); END;'
				USING IN pcontractno, OUT prollbackdata;
		
			pcontractrec := scontractrec;
			pcontractsh  := scontractsh;
			pitemslist   := sitemslist;
			ptranslist   := stranslist;
			poverduelist := soverduelist;
		
		ELSE
			contractschemas.reportunsupportedoperation(spackage(vcontracttype), cexecprocname);
		END IF;
	
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END execgetdata4dc;

	PROCEDURE downgetdata4dc(pcontracttype IN NUMBER) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.DownGetData4DC';
		cexecprocname CONSTANT VARCHAR2(100) := 'DownGetData4DC';
	BEGIN
		IF contractschemas.existsmethod(spackage(pcontracttype), cexecprocname, '/in:N/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || upper(spackage(pcontracttype)) || '.' ||
							  upper(cexecprocname) || '(:TYPE); END;'
				USING IN pcontracttype;
		END IF;
		spackage.delete(pcontracttype);
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			s.say(cmethod_name || ': general exception ' || SQLCODE || ' ' || SQLERRM, csay_level);
	END downgetdata4dc;

	PROCEDURE undogetdata4dc
	(
		pcontractno   IN VARCHAR2
	   ,prollbackdata IN VARCHAR2
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.UndoGetData4DC';
		cexecprocname CONSTANT VARCHAR2(100) := 'UndoGetData4DC';
		vpackage      VARCHAR2(50);
		vcontracttype NUMBER;
	BEGIN
		vcontracttype := contract.gettype(pcontractno);
		IF vcontracttype IS NULL
		THEN
		
			error.raisewhenerr();
		
		END IF;
	
		vpackage := contracttype.getschemapackage(vcontracttype);
		IF vpackage IS NULL
		THEN
		
			error.raisewhenerr();
		
		END IF;
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:V/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || upper(cexecprocname) ||
							  '(:NO, :RD); END;'
				USING IN pcontractno, IN prollbackdata;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cexecprocname);
		END IF;
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END undogetdata4dc;

	PROCEDURE complyrequest
	(
		pactions      IN apitypesfordc.typeactionrecord
	   ,prollbackdata OUT VARCHAR2
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.ComplyRequest';
		cexecprocname CONSTANT VARCHAR2(100) := 'ComplyRequest';
		vpackage      VARCHAR2(50);
		vcontracttype NUMBER;
	BEGIN
		sactions := pactions;
	
		vcontracttype := contract.gettype(sactions.contractno);
		IF vcontracttype IS NULL
		THEN
		
			error.raisewhenerr();
		
		END IF;
	
		vpackage := contracttype.getschemapackage(vcontracttype);
		IF vpackage IS NULL
		THEN
		
			error.raisewhenerr();
		
		END IF;
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:S/out:V/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || upper(cexecprocname) ||
							  '(CONTRACTTYPESCHEMA.SACTIONS, :RD); END;'
				USING OUT prollbackdata;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cexecprocname);
		END IF;
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END complyrequest;

	PROCEDURE undocomplyrequest
	(
		pactions      IN apitypesfordc.typeactionrecord
	   ,prollbackdata IN VARCHAR2
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.UndoComplyRequest';
		cexecprocname CONSTANT VARCHAR2(100) := 'UndoComplyRequest';
		vpackage      VARCHAR2(50);
		vcontracttype NUMBER;
	BEGIN
		sactions := pactions;
	
		vcontracttype := contract.gettype(sactions.contractno);
		IF vcontracttype IS NULL
		THEN
		
			error.raisewhenerr();
		
		END IF;
	
		vpackage := contracttype.getschemapackage(vcontracttype);
		IF vpackage IS NULL
		THEN
		
			error.raisewhenerr();
		
		END IF;
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:S/in:V/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || upper(cexecprocname) ||
							  '(CONTRACTTYPESCHEMA.SACTIONS, :RD); END;'
				USING IN prollbackdata;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cexecprocname);
		END IF;
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END undocomplyrequest;

	PROCEDURE getstatelist4dc
	(
		pcontracttype IN NUMBER
	   ,pstatelist    OUT apitypesfordc.typecontractstatelist
	) IS
		cmethod_name  CONSTANT VARCHAR2(65) := cpackage_name || '.GetStateList4DC';
		cexecprocname CONSTANT VARCHAR2(100) := 'GetStateList4DC';
		vpackage VARCHAR2(50);
	BEGIN
		sstatelist.delete;
	
		IF pcontracttype IS NULL
		THEN
			error.raiseerror('Contracts type not specified');
		END IF;
	
		vpackage := contracttype.getschemapackage(pcontracttype);
		IF vpackage IS NULL
		THEN
		
			error.raisewhenerr();
		
		END IF;
	
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:N/out:A/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || upper(cexecprocname) ||
							  '(:TYPE, CONTRACTTYPESCHEMA.SSTATELIST); END;'
				USING IN pcontracttype;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cexecprocname);
		END IF;
	
		pstatelist := sstatelist;
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getstatelist4dc;

	FUNCTION getcontractstatelist(pcontractno IN tcontract.no%TYPE)
		RETURN apitypesfordc.typecontractstatelist IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetContractStateList';
		vcontract tcontract%ROWTYPE;
		vret      apitypesfordc.typecontractstatelist;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pContractNo', pcontractno);
		IF TRIM(pcontractno) IS NULL
		THEN
			error.raiseerror('Contract No not defined');
		END IF;
		vcontract := contract.getcontractrowtype(pcontractno, FALSE);
	
		IF vcontract.no IS NULL
		THEN
			error.raiseerror('Contract [' || pcontractno || '] not found');
		END IF;
	
		t.var('vContract.Type', vcontract.type);
	
		getstatelist4dc(vcontract.type, vret);
		t.leave(cmethod_name, 'vRet.count=' || vret.count, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION atmgetcontractinfo(precinfo IN tcontractquery) RETURN tatminfoarray IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.ATMGetContractInfo';
		cfuncname    CONSTANT VARCHAR2(100) := 'ATMGetContractInfo';
		vpackage VARCHAR2(40);
		vreturn  tatminfoarray;
	BEGIN
		srecinfo     := precinfo;
		scontractrow := contract.getcontractrowtype(srecinfo.contractno);
		s.say(cmethod_name || ': contract no ' || scontractrow.no, csay_level);
	
		IF contract.checkstatus(scontractrow.status, contract.stat_close)
		THEN
			s.say(cmethod_name || ': it''s closed ', csay_level);
			error.raiseerror(exccontract_closed, 'Contract ' || scontractrow.no || ' closed');
		END IF;
	
		vpackage := contracttype.getschemapackage(scontractrow.type);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:S/out:A/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || cpackage_name || '.SAINFO :=' || vpackage || '.' ||
							  cfuncname || '(CONTRACTTYPESCHEMA.SRECINFO); END;';
			vreturn := sainfo;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname);
		END IF;
	
		RETURN vreturn;
	
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END atmgetcontractinfo;

	FUNCTION closecontract
	(
		pcontractno VARCHAR2
	   ,pparams     tclosecontractparamrec
	) RETURN contractrb.trollbackdata IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.CloseContract';
		cfuncname    CONSTANT VARCHAR2(100) := 'CloseContract';
		vpackage VARCHAR2(40);
	
		vpackno NUMBER;
		vret    contractrb.trollbackdata;
	BEGIN
		scontractrow := contract.getcontractrowtype(pcontractno);
	
		s.say(cmethod_name || ': no ' || scontractrow.no, csay_level);
		vpackage := contracttype.getschemapackage(scontractrow.type);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:S/ret:V')
		THEN
			BEGIN
				vpackno := contractrb.initpack(contractrb.c_changeparams
											  ,issclient.getcurrentpacketno()
											  ,issclient.getcurrentrecordno());
			
				sclosecontractparamrec := pparams;
				EXECUTE IMMEDIATE 'BEGIN  :RET :=' || vpackage || '.' || cfuncname || '(:CONT_NO, ' ||
								  cpackage_name || '.sCloseContractParamRec); END;'
					USING OUT vret, IN scontractrow.no;
			
				contractrb.done(vpackno);
			EXCEPTION
				WHEN OTHERS THEN
					contractrb.clearlaststate();
					RAISE;
			END;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname);
		END IF;
	
		RETURN vret;
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END closecontract;

	PROCEDURE undoclosecontract
	(
		pcontractno   VARCHAR2
	   ,prollbackdata VARCHAR2
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.UndoCloseContract';
		cexecprocname CONSTANT VARCHAR2(100) := 'UndoCloseContract';
		vpackage VARCHAR2(40);
	BEGIN
		scontractrow := contract.getcontractrowtype(pcontractno);
		s.say(cmethod_name || ': no ' || scontractrow.no, csay_level);
	
		vpackage := contracttype.getschemapackage(scontractrow.type);
	
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:V/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || upper(cexecprocname) ||
							  '(:CONT_NO, :RB); END;'
				USING IN scontractrow.no, IN prollbackdata;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cexecprocname);
		END IF;
	
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END undoclosecontract;

	FUNCTION changecontractparams
	(
		pcontractno        IN VARCHAR2
	   ,pnewcontractparams contract.typecontractrow
	   ,pcontuserdata      IN apitypes.typeuserproplist := semptyrec
	) RETURN NUMBER
	
	 IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.ChangeContractParams';
		cfuncname    CONSTANT VARCHAR2(100) := 'ChangeContractParams';
		vpackage VARCHAR2(40);
		vret     NUMBER := 0;
		vhandle  NUMBER;
		vpack    apitypes.typeissclientpacket;
		vpackno  NUMBER;
	
		vrollbackdata1     tcontract.rollbackdata%TYPE;
		vrollbackdata2     tcontract.rollbackdata%TYPE;
		vnewcontractparams contract.typecontractrow;
	
		vaparamscontracts contracttools.typestrbystr;
	BEGIN
		t.enter(cmethod_name);
		vnewcontractparams        := pnewcontractparams;
		vpack                     := issclient.getcurrentpacketrow();
		vnewcontractparams.packno := vpack.packno;
		t.note(cmethod_name, 'vPackNo=' || vpack.packno || ', PackType=' || vpack.packtype);
		scontractrow := contract.getcontractrowtype(pcontractno);
		t.var('sContractRow.No', scontractrow.no);
		t.var('sContractRow.Type', scontractrow.type);
		t.var('sContractRow.IdClient', scontractrow.idclient);
		t.var('sContractRow.CreateDate', htools.d2s(scontractrow.createdate));
	
		vpackno := contractrb.initpack(contractrb.c_changeparams
									  ,vpack.packno
									  ,issclient.getcurrentrecordno());
		t.var('vPackNo', vpackno);
	
		vhandle := contract.newobject(pcontractno, 'W');
		IF vhandle = 0
		THEN
		
			error.raisewhenerr();
		
		END IF;
	
		contract.changecontractparameters(scontractrow, vnewcontractparams, FALSE);
		t.var('sContractRow.No', scontractrow.no);
		t.var('sContractRow.Type', scontractrow.type);
		t.var('sContractRow.IdClient', scontractrow.idclient);
		t.var('sContractRow.CreateDate', htools.d2s(scontractrow.createdate));
	
		t.note(cmethod_name, 'sContractRow.Objectuid=' || scontractrow.objectuid, csay_level);
		objuserproperty.newrecord(contract.object_name
								 ,scontractrow.objectuid
								 ,pcontuserdata
								 ,plog_clientid => scontractrow.idclient);
	
		vpackage := contracttype.getschemapackage(scontractrow.type);
		IF (vpackage IS NULL)
		THEN
			contractrb.clearlaststate();
			vret := err.geterrorcode();
		ELSE
			IF contract.sparams IS NOT NULL
			THEN
			
				vaparamscontracts := contracttools.parsedelimparamlinkcontract(contract.sparams);
			
				contract.sparams := vaparamscontracts('MAIN');
			
				IF contractschemas.existsmethod(vpackage, cfuncname, '/ret:N')
				THEN
					EXECUTE IMMEDIATE 'BEGIN :RET:= ' || vpackage || '.' || cfuncname || '; END;'
						USING OUT vret;
				ELSE
					contractschemas.reportunsupportedoperation(vpackage
															  ,cfuncname
															  ,pdoexception => FALSE);
					err.seterror(err.refct_undefined_oper, cmethod_name);
					vret := err.refct_undefined_oper;
				END IF;
			END IF;
			s.say(cmethod_name || ': rollback data ' || contract.srollbackdata, csay_level);
		
			vrollbackdata1 := contractrb.done(vpackno);
			t.var('vRollbackData1', vrollbackdata1);
			vrollbackdata2 := service.iif((vrollbackdata1 IS NULL AND
										  contract.srollbackdata IS NULL)
										 ,''
										 ,contract.cseparator) || contract.srollbackdata;
			t.var('vRollbackData2', vrollbackdata2);
			contract.srollbackdata := vrollbackdata1 || vrollbackdata2;
			t.var('Contract.sRollBackData', contract.srollbackdata);
		
		END IF;
	
		IF vhandle != 0
		THEN
			contract.freeobject(vhandle);
		END IF;
	
		t.leave(cmethod_name);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			contractrb.clearlaststate();
			error.save(cmethod_name);
			IF vhandle != 0
			THEN
				contract.freeobject(vhandle);
			END IF;
			RAISE;
	END changecontractparams;

	FUNCTION undochangecontractparams
	(
		pcontractno   IN VARCHAR2
	   ,pcontuserdata IN apitypes.typeuserproplist := semptyrec
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.UndoChangeContractParams';
		cfuncname    CONSTANT VARCHAR2(100) := 'UndoChangeContractParams';
		vpackage    VARCHAR2(40);
		vret        NUMBER := 0;
		vhandle     NUMBER;
		vcontractno tcontract.no%TYPE;
		vmodifrec   tcontractmodification%ROWTYPE;
		vpack       apitypes.typeissclientpacket;
	
		vseppos NUMBER;
		v1part  tcontract.rollbackdata%TYPE;
		v2part  tcontract.rollbackdata%TYPE;
	
	BEGIN
		t.enter(cmethod_name);
	
		vcontractno := pcontractno;
		IF NOT contract.contractexists(vcontractno)
		THEN
			t.note(cmethod_name, 'point 1');
			vpack := issclient.getcurrentpacketrow();
			t.note(cmethod_name, 'vPackNo=' || vpack.packno || ', PackType=' || vpack.packtype);
			IF vpack.packtype IN (issclient.rt_contract_make, issclient.rt_contract_company_make)
			THEN
				vmodifrec := contract.getmodificationbysourceno(vcontractno, vpack.packno);
				t.note(cmethod_name, 'TargetNo=' || vmodifrec.targetno);
				IF vmodifrec.targetno IS NOT NULL
				THEN
					vcontractno := vmodifrec.targetno;
				END IF;
			END IF;
		END IF;
	
		scontractrow := contract.getcontractrowtype(vcontractno);
	
		t.var('sContractRow.No', scontractrow.no);
		t.var('sContractRow.Type', scontractrow.type);
		t.var('sContractRow.IdClient', scontractrow.idclient);
		t.var('sContractRow.CreateDate', htools.d2s(scontractrow.createdate));
	
		vhandle := contract.newobject(vcontractno, 'W');
		IF vhandle = 0
		THEN
		
			error.raisewhenerr();
		
		END IF;
		contract.srollbackdata := NULL;
	
		t.var('Contract.sParams', contract.sparams);
		vseppos := instr(contract.sparams, contract.cseparator, 1);
		t.var('vSepPos', vseppos, csay_level);
		IF vseppos > 0
		THEN
			v1part := substr(contract.sparams, 1, vseppos - 1);
			t.var('v1Part', v1part);
			v2part := substr(contract.sparams, vseppos + length(contract.cseparator));
			t.var('v2Part', v2part);
		ELSE
			v1part := contract.sparams;
		END IF;
	
		IF v2part IS NOT NULL
		THEN
		
			vpackage := contracttype.getschemapackage(scontractrow.type);
		
			IF vpackage IS NULL
			THEN
				vret := err.geterrorcode();
			ELSE
			
				contract.sparams := v2part;
				IF contractschemas.existsmethod(vpackage, cfuncname, '/ret:N')
				THEN
					EXECUTE IMMEDIATE 'BEGIN :RET:= ' || vpackage || '.' || cfuncname || '; END;'
						USING OUT vret;
				ELSE
					vret := 0;
				END IF;
			
			END IF;
		END IF;
	
		t.var('vRet', vret);
	
		IF vret = 0
		THEN
		
			IF v1part IS NOT NULL
			THEN
			
				v2part := contractrb.undo(vcontractno, v1part);
				t.var('v2Part', v2part);
			
				IF v2part IS NULL
				THEN
				
					scontractrow := contract.getcontractrowtype(pcontractno);
				ELSE
					error.raiseerror('Impossible to undo data [' || v2part || ']');
				
				END IF;
			END IF;
		
			t.var('sContractRow.No', scontractrow.no);
			t.var('sContractRow.Type', scontractrow.type);
			t.var('sContractRow.IdClient', scontractrow.idclient);
			t.var('sContractRow.CreateDate', htools.d2s(scontractrow.createdate));
		
			s.say(cmethod_name || ': rollback data ' || contract.srollbackdata, csay_level);
			objuserproperty.newrecord(contract.object_name
									 ,scontractrow.objectuid
									 ,pcontuserdata
									 ,plog_clientid => scontractrow.idclient);
		END IF;
	
		IF vhandle != 0
		THEN
			contract.freeobject(vhandle);
		END IF;
		t.leave(cmethod_name);
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			IF vhandle != 0
			THEN
				contract.freeobject(vhandle);
			END IF;
			RAISE;
	END undochangecontractparams;

	FUNCTION fillaggregateacctype
	(
		ptype     IN NUMBER
	   ,pitemcode IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.FillAggregateAccType';
		cfuncname    CONSTANT VARCHAR2(100) := 'FillAggregateAccType';
		vcursor  NUMBER;
		vres     NUMBER;
		vret     NUMBER;
		vpackage VARCHAR2(40);
	BEGIN
		vpackage := contracttype.getschemapackage(ptype);
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:N/in:N/ret:N')
		THEN
			BEGIN
				vcursor   := dbms_sql.open_cursor;
				sparsestr := 'begin :VALUE := ' || vpackage || '.' || cfuncname ||
							 '(:TYPE,:CODE); end;';
				dbms_sql.parse(vcursor, sparsestr, dbms_sql.native);
				dbms_sql.bind_variable(vcursor, ':TYPE', ptype);
				dbms_sql.bind_variable(vcursor, ':CODE', pitemcode);
				dbms_sql.bind_variable(vcursor, ':VALUE', vret);
				vres := dbms_sql.execute(vcursor);
				dbms_sql.variable_value(vcursor, ':VALUE', vret);
				dbms_sql.close_cursor(vcursor);
			EXCEPTION
				WHEN OTHERS THEN
					dbms_sql.close_cursor(vcursor);
					err.seterror(SQLCODE, cmethod_name);
					vret := SQLCODE;
			END;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname);
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RETURN error.getcode();
	END fillaggregateacctype;

	FUNCTION getentryarray RETURN tentryarray IS
	BEGIN
		RETURN saentry;
	END getentryarray;

	FUNCTION getinfotext
	(
		pdialog NUMBER
	   ,pno     IN VARCHAR2
	   ,pnumstr IN NUMBER
	) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetInfoText';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetInfoText';
		vret     VARCHAR2(255);
		vpackage VARCHAR2(40);
	BEGIN
		sdialog      := pdialog;
		scontractrow := contract.getcontractrowtype(pno);
	
		vpackage := contracttype.getschemapackage(scontractrow.type);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:N/ret:V')
		THEN
			EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.' || cfuncname || '(:NUM); END;'
				USING OUT vret, IN pnumstr;
		ELSE
			vret := err.getfullmessage();
		END IF;
	
		RETURN substr(vret, 1, 73);
	
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN substr(SQLERRM, 1, 73);
	END getinfotext;

	FUNCTION getdataforreport
	(
		pno             IN VARCHAR2
	   ,pstartdate      IN DATE
	   ,penddate        IN DATE
	   ,pmaxcount       IN NUMBER
	   ,parchive        BOOLEAN := FALSE
	   ,pneedremain     BOOLEAN := TRUE
	   ,psearchdatetype NUMBER := coper_date
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetDataForReport';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetDataForReport';
		vpackage VARCHAR2(40);
		vret     NUMBER := 0;
	BEGIN
		sacontractinfo.delete;
		saentry.delete;
		samainaccounts.delete;
	
		ssearchdatetype := psearchdatetype;
	
		scontractrow := contract.getcontractrowtype(pno);
	
		vpackage := contracttype.getschemapackage(scontractrow.type);
	
		IF (vpackage IS NULL)
		THEN
			vret := err.geterrorcode();
		ELSE
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:D/in:D/in:N/in:B/in:B/ret:N')
			THEN
				EXECUTE IMMEDIATE 'BEGIN :RET:= ' || vpackage || '.' || cfuncname ||
								  '(:1, :2, :3, :4 = 1, :5 = 1); END;'
					USING OUT vret, IN pstartdate, IN penddate, IN pmaxcount, IN service.iif(parchive, 1, 0), IN service.iif(pneedremain, 1, 0);
			ELSE
				err.seterror(err.refct_undefined_oper, cmethod_name);
				vret := err.refct_undefined_oper;
			END IF;
		
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END getdataforreport;

	FUNCTION getmainaccount
	(
		pno       IN tcontract.no%TYPE
	   ,pcurrency IN treferencecurrency.currency%TYPE
	) RETURN taccount.accountno%TYPE IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetMainAccount';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetMainAccount';
		vpackage     tcontractschemas.packagename%TYPE;
		vret         taccount.accountno%TYPE;
		vcontractrow tcontract%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pNo', pno);
		t.inpar('pCurrency', pcurrency);
	
		IF pno IS NULL
		THEN
			error.raiseerror('Contract No not defined');
		END IF;
	
		vcontractrow := contract.getcontractrowtype(pno);
		vpackage     := contracttype.getschemapackage(vcontractrow.type);
		t.note(vpackage);
		IF (vpackage IS NULL)
		THEN
			error.raiseerror('Not defined scheme for contract type [' || vcontractrow.type || ']');
		ELSE
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:N/ret:V')
			THEN
			
				t.note(cmethod_name
					  ,'New : no / currency ' || pno || ' / ' || pcurrency
					  ,csay_level);
				EXECUTE IMMEDIATE 'BEGIN
							  :RET := ' || vpackage || '.' || cfuncname || '(:NO, :CURRENCY);  -- 17.12.2021
							END;'
					USING OUT vret, pno, pcurrency;
			ELSE
			
				scontractrow := vcontractrow;
			
				IF contractschemas.existsmethod(vpackage, cfuncname, '/in:N/ret:V')
				THEN
				
					t.note(cmethod_name
						  ,'old : no / currency ' || pno || ' / ' || pcurrency
						  ,csay_level);
					EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.' || cfuncname ||
									  '(:CURRENCY); END;'
						USING OUT vret, pcurrency;
				ELSE
					contractschemas.reportunsupportedoperation(vpackage, cfuncname);
				END IF;
			END IF;
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			scontractrow := vcontractrow;
			error.save(cmethod_name);
			RAISE;
	END getmainaccount;

	FUNCTION getmainitemcode(pctype IN NUMBER) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetMainItemCode';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetMainItemCode';
		vcontractrow tcontract%ROWTYPE;
		vpackage     VARCHAR2(40);
		vret         NUMBER := NULL;
	BEGIN
	
		t.enter(cmethod_name, 'pCType=' || pctype, csay_level);
		vcontractrow := scontractrow;
	
		IF pctype IS NULL
		THEN
			error.raiseerror('Undefined contract type');
		END IF;
	
		IF (scontractrow.type IS NULL)
		   OR (scontractrow.type <> pctype)
		THEN
			scontractrow.type := pctype;
			scontractrow.no   := NULL;
		END IF;
	
		err.seterror(0, cmethod_name);
		vpackage := contracttype.getschemapackage(scontractrow.type);
		error.raisewhenerr();
	
		IF (vpackage IS NULL)
		THEN
			error.raiseerror('Not defined scheme for contract type [' || pctype || ']');
		ELSE
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/ret:N')
			THEN
			
				t.note(cmethod_name
					  ,'scheme [' || vpackage || '] supports ' || cfuncname || ' method'
					  ,csay_level);
				EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.' || cfuncname || '; END;'
					USING OUT vret;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage, cfuncname);
			END IF;
		END IF;
		scontractrow := vcontractrow;
		t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			scontractrow := vcontractrow;
			error.save(cmethod_name);
			RAISE;
		
	END getmainitemcode;

	FUNCTION contractpost(pno IN VARCHAR2) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ContractPost';
		cfuncname    CONSTANT VARCHAR2(100) := 'ContractPost';
		vpackage VARCHAR2(255);
		vret     NUMBER := 0;
	BEGIN
		err.seterror(0, cmethod_name);
		serrortext   := NULL;
		scontractrow := contract.getcontractrowtype(pno);
	
		vpackage := contracttype.getschemapackage(scontractrow.type);
		IF (vpackage IS NULL)
		THEN
			vret := err.geterrorcode();
		ELSE
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/ret:N')
			THEN
				EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.' || cfuncname || '; END;'
					USING OUT vret;
			ELSE
				err.seterror(SQLCODE, cmethod_name);
				serrortext := err.getfullmessage();
				vret       := SQLCODE;
			END IF;
		
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			serrortext := err.getfullmessage();
			RETURN SQLCODE;
	END contractpost;

	FUNCTION getschemapackagebycontractno(pcontractno IN VARCHAR2) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetSchemaPackageByContractNo';
		vtype    NUMBER;
		vpackage VARCHAR2(40);
	BEGIN
		scontractrow.no := pcontractno;
		vtype           := contract.gettype(pcontractno);
		IF vtype IS NULL
		THEN
			RETURN NULL;
		END IF;
	
		vpackage := contracttype.getschemapackage(vtype);
		RETURN vpackage;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN NULL;
	END getschemapackagebycontractno;

	FUNCTION getcontractinfo(pparams trequestrecord) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetContractInfo';
		vpackage     VARCHAR2(40);
		vcontractno  VARCHAR2(20);
		vret         NUMBER;
		vcount       NUMBER;
		vpos         NUMBER;
		vpan         VARCHAR2(20);
		vmbr         NUMBER;
		vclientid    NUMBER;
		vresultarray tresponsearray;
		vbranch      NUMBER := seance.getbranch();
	
		CURSOR c1(pclientid NUMBER) IS
			SELECT *
			FROM   tcontract a
			WHERE  a.branch = vbranch
			AND    a.idclient = pclientid;
	
		FUNCTION callscheme(pcontractno VARCHAR2) RETURN NUMBER IS
			cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetContractInfo.CallScheme';
			cfuncname    CONSTANT VARCHAR2(100) := 'GetContractInfo';
		BEGIN
			s.say(cmethod_name || ': contract ' || pcontractno, csay_level);
			scontractrow := contract.getcontractrowtype(pcontractno);
			vpackage     := upper(contracttype.getschemapackage(scontractrow.type));
			s.say(cmethod_name || ': package ' || vpackage, csay_level);
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/ret:N')
			THEN
				EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.' || cfuncname ||
								  '(:NO);  END;'
					USING OUT vret, IN pcontractno;
				CASE vret
					WHEN 0 THEN
						vret := rpc.err_success;
					WHEN err.refct_undefined_oper THEN
						vret := rpc.err_contractunsupportedop;
					WHEN err.account_not_found THEN
						vret := rpc.err_generaldataerror;
					ELSE
					
						error.raisewhenerr();
					
				END CASE;
			ELSE
				vret := rpc.err_contractunsupportedop;
			END IF;
		
			RETURN vret;
		EXCEPTION
		
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END callscheme;
	
		PROCEDURE mergearrays
		(
			psource      IN tresponsearray
		   ,pdestination IN OUT tresponsearray
		) IS
			cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetContractInfo.MergeArrays';
			vcount NUMBER;
		BEGIN
			vcount := pdestination.count;
			FOR k IN 1 .. psource.count
			LOOP
				vcount := vcount + 1;
				pdestination(vcount) := psource(k);
			END LOOP;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END mergearrays;
	
	BEGIN
		sacontractresponse.delete();
		scontractrequest := pparams;
		IF pparams.ident IS NULL
		THEN
			RETURN rpc.err_contractnotauthorized;
		END IF;
	
		CASE pparams.identtype
			WHEN rpc.ident_type_contract_no THEN
				vcontractno := pparams.ident;
				IF vcontractno IS NULL
				THEN
					RETURN rpc.err_contractnotauthorized;
				END IF;
				vret := callscheme(vcontractno);
			WHEN rpc.ident_type_account_no THEN
				vcontractno := contract.getcontractnobyaccno(pparams.ident, FALSE);
				IF vcontractno IS NULL
				THEN
					RETURN rpc.err_contractnotauthorized;
				END IF;
				vret := callscheme(vcontractno);
			WHEN rpc.ident_type_card THEN
				vpos        := instr(pparams.ident, '-', 1, 1);
				vpan        := substr(pparams.ident, 1, vpos - 1);
				vmbr        := to_number(substr(pparams.ident, vpos + 1));
				vcontractno := contract.getcontractnobycard(vpan, vmbr, FALSE);
				IF vcontractno IS NULL
				THEN
					RETURN rpc.err_contractnotauthorized;
				END IF;
				vret := callscheme(vcontractno);
			WHEN rpc.ident_type_client_ext THEN
				IF pparams.identtype = rpc.ident_type_client
				THEN
					vclientid := to_number(pparams.ident);
				ELSIF pparams.identtype = rpc.ident_type_client_ext
				THEN
					vclientid := clientpersone.getpersonidbyextid(to_number(pparams.ident));
				END IF;
				s.say(cmethod_name || ': client id ' || vclientid, csay_level);
				IF vclientid IS NULL
				THEN
					RETURN rpc.err_generaldataerror;
				END IF;
			
				vresultarray.delete;
				FOR i IN c1(vclientid)
				LOOP
					sacontractresponse.delete;
					vret := callscheme(i.no);
					IF vret != rpc.err_success
					THEN
						RETURN vret;
					END IF;
					mergearrays(sacontractresponse, vresultarray);
				END LOOP;
				sacontractresponse := vresultarray;
			WHEN rpc.ident_type_client THEN
				IF pparams.identtype = rpc.ident_type_client
				THEN
					vclientid := to_number(pparams.ident);
				ELSIF pparams.identtype = rpc.ident_type_client_ext
				THEN
					vclientid := clientpersone.getpersonidbyextid(to_number(pparams.ident));
				END IF;
				s.say(cmethod_name || ': client id ' || vclientid, csay_level);
				IF vclientid IS NULL
				THEN
					RETURN rpc.err_generaldataerror;
				END IF;
			
				vresultarray.delete;
				FOR i IN c1(vclientid)
				LOOP
					sacontractresponse.delete;
					vret := callscheme(i.no);
					IF vret != rpc.err_success
					THEN
						RETURN vret;
					END IF;
					mergearrays(sacontractresponse, vresultarray);
				END LOOP;
				sacontractresponse := vresultarray;
			ELSE
				vret := rpc.err_generaldataerror;
		END CASE;
	
		RETURN vret;
	EXCEPTION
		WHEN method_not_found THEN
			s.say(cmethod_name || ': method not found ', csay_level);
			RETURN rpc.err_contractunsupportedop;
		WHEN OTHERS THEN
			s.say(cmethod_name || ': general exception ' || SQLCODE || ' ' || SQLERRM, csay_level);
			error.save(cmethod_name);
			RAISE;
	END getcontractinfo;

	FUNCTION getcontractoperations
	(
		pno        IN VARCHAR2
	   ,pstartdate IN DATE
	   ,penddate   IN DATE
	   ,parchive   NUMBER := 0
	) RETURN tentryarray IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetContractOperations';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetContractOperations';
		vpackage VARCHAR2(40);
	
		vmnf         BOOLEAN := FALSE;
		vmainaccount taccount.accountno%TYPE;
		varchive     BOOLEAN;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pNo=' || pno || ', pStartDate=' || pstartdate || ', pEndDate=' || penddate ||
				', pArchive=' || parchive
			   ,csay_level);
		saentry.delete;
		scontractrow := contract.getcontractrowtype(pno);
		s.say(cmethod_name || ': no ' || scontractrow.no, csay_level);
		vpackage := contracttype.getschemapackage(scontractrow.type);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:D/in:D/in:N/ret:A')
		THEN
			EXECUTE IMMEDIATE 'BEGIN CONTRACTTYPESCHEMA.SAENTRY := ' || vpackage || '.' ||
							  cfuncname || '(:NO, :SD, :ED, :ARC); END;'
				USING IN pno, IN pstartdate, IN penddate, IN parchive;
		ELSE
			vmnf := TRUE;
		END IF;
	
		IF vmnf
		THEN
			err.seterror(0, cmethod_name);
			vmainaccount := getmainaccount(pno, NULL);
			t.var('vMainAccount', vmainaccount);
			IF vmainaccount IS NOT NULL
			THEN
				IF nvl(parchive, 0) = 1
				THEN
					varchive := TRUE;
				ELSE
					varchive := FALSE;
				END IF;
				t.var('vArchive', t.b2t(varchive));
				/*saentry := custom_contracttools.getentryarray(vmainaccount
                ,pstartdate
                ,penddate
                ,NULL
                ,varchive);*/
			END IF;
		END IF;
	
		t.leave(cmethod_name
			   ,'Contracttypeschema.saEntry.count=' || contracttypeschema.saentry.count
			   ,csay_level);
		RETURN saentry;
	EXCEPTION
	
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END getcontractoperations;

	FUNCTION requestclose
	(
		pcontractno IN VARCHAR2
	   ,paccountno  IN VARCHAR2
	   ,preqno      IN NUMBER
	   ,psumma      IN NUMBER
	   ,pentcode    IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.RequestClose';
		cfuncname    CONSTANT VARCHAR2(100) := 'RequestClose';
		vpackage VARCHAR2(40);
		vret     NUMBER;
	BEGIN
		vpackage := getschemapackagebycontractno(pcontractno);
		IF (vpackage IS NULL)
		THEN
			vret := err.geterrorcode();
		ELSE
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:N/in:N/in:N/ret:N')
			THEN
			
				s.say(cmethod_name || ': account ' || paccountno || ', request ' || preqno ||
					  ', amount ' || psumma || ', entry code ' || pentcode
					 ,csay_level);
				EXECUTE IMMEDIATE upper('begin :RET := ' || vpackage || '.' || cfuncname ||
										'(:pAccountNo, :pReqNo, :pSumma, :pEntCode); end;')
					USING OUT vret, paccountno, preqno, psumma, pentcode;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage
														  ,cfuncname
														  ,pdoexception => FALSE);
				err.seterror(err.refct_undefined_oper, cmethod_name);
				vret := err.refct_undefined_oper;
			END IF;
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END requestclose;

	FUNCTION fillcloseentrylist(pcontractno IN VARCHAR2) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillCloseEntryList';
		cfuncname    CONSTANT VARCHAR2(100) := 'FillCloseEntryList';
		vpackage VARCHAR2(40);
		vret     NUMBER;
	BEGIN
		vpackage := getschemapackagebycontractno(pcontractno);
		IF (vpackage IS NULL)
		THEN
			vret := NULL;
		ELSE
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/ret:N')
			THEN
			
				s.say(cmethod_name || ': ', csay_level);
				EXECUTE IMMEDIATE upper('begin :RET := ' || vpackage || '.' || cfuncname ||
										'; end;')
					USING OUT vret;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage
														  ,cfuncname
														  ,pdoexception => FALSE);
				err.seterror(err.refct_undefined_oper, cmethod_name);
				vret := NULL;
			END IF;
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN NULL;
	END fillcloseentrylist;

	FUNCTION contractsubadd
	(
		poper       VARCHAR2
	   ,pcontractno IN VARCHAR2
	   ,preqno      IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ContractSubAdd';
		vpackage VARCHAR2(255);
		vret     NUMBER;
	BEGIN
		vpackage := getschemapackagebycontractno(pcontractno);
		IF (vpackage IS NULL)
		THEN
			vret := NULL;
		ELSE
		
			IF contractschemas.existsmethod(vpackage, poper, '/in:N/ret:N')
			THEN
			
				s.say(cmethod_name || ': operation ' || poper || ' request ' || preqno, csay_level);
				EXECUTE IMMEDIATE upper('begin :RET := ' || vpackage || '.' || poper ||
										'(:pReqNo); end;')
					USING OUT vret, preqno;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage, poper, pdoexception => FALSE);
				err.seterror(err.refct_undefined_oper, cmethod_name);
				vret := NULL;
			END IF;
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN NULL;
	END contractsubadd;

	FUNCTION contractadd
	(
		pcontractno IN VARCHAR2
	   ,preqno      IN NUMBER
	) RETURN NUMBER IS
	BEGIN
		RETURN contractsubadd('ContractAdd', pcontractno, preqno);
	END contractadd;

	FUNCTION contractsub
	(
		pcontractno IN VARCHAR2
	   ,preqno      IN NUMBER
	) RETURN NUMBER IS
	BEGIN
		RETURN contractsubadd('ContractSub', pcontractno, preqno);
	END contractsub;

	FUNCTION contractclose
	(
		pcontractno IN VARCHAR2
	   ,pparameters IN VARCHAR2
	   ,preqno      IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ContractClose';
		cfuncname    CONSTANT VARCHAR2(100) := 'ContractClose';
		vpackage VARCHAR2(40);
		vret     NUMBER;
	BEGIN
		vpackage := getschemapackagebycontractno(pcontractno);
		IF (vpackage IS NULL)
		THEN
			vret := NULL;
		ELSE
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:V/in:N/ret:N')
			THEN
			
				contracttypeschema.srollbackdata   := NULL;
				contracttypeschema.scontractrow.no := pcontractno;
				s.say(cmethod_name || ': no ' || pcontractno || ', parameters ' || pparameters ||
					  ', request ' || preqno
					 ,csay_level);
				EXECUTE IMMEDIATE upper('begin :RET := ' || vpackage || '.' || cfuncname ||
										'(:pContractNo, :pParameters, :pReqNo); end;')
					USING OUT vret, pcontractno, pparameters, preqno;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage
														  ,cfuncname
														  ,pdoexception => FALSE);
				err.seterror(err.refct_undefined_oper, cmethod_name);
				vret := NULL;
			END IF;
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN NULL;
	END contractclose;
	FUNCTION clonetemplates
	(
		pcontracttypefrom IN NUMBER
	   ,pcontracttypeto   IN NUMBER
	) RETURN apitypes.typesotemplatearray IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CloneTemplates';
		vatemplatesfrom apitypes.typesotemplatearray;
		vatemplatesto   apitypes.typesotemplatearray;
		vnewid          apitypes.typesotemplatesysid;
	BEGIN
		s.say(cmethod_name || ': from ' || pcontracttypefrom || ' to ' || pcontracttypeto
			 ,csay_level);
	
		vatemplatesto := sot_core.gettemplates(apitypes.csotcsocontracttype, pcontracttypeto);
		IF vatemplatesto.count > 0
		THEN
			FOR i IN 1 .. vatemplatesto.count
			LOOP
				sot_core.droptemplate(vatemplatesto(i).id);
			END LOOP;
			vatemplatesto.delete;
		END IF;
	
		vatemplatesfrom := sot_core.gettemplates(apitypes.csotcsocontracttype, pcontracttypefrom);
		IF vatemplatesfrom.count > 0
		THEN
			FOR i IN 1 .. vatemplatesfrom.count
			LOOP
				vnewid := sot_core.clonetemplate(vatemplatesfrom(i).id
												,vatemplatesfrom(i).name
												,pcontracttypeto);
				vatemplatesfrom(i).parenttemplateid := vnewid;
			END LOOP;
		END IF;
		s.say(cmethod_name || ': count ' || vatemplatesfrom.count, csay_level);
		RETURN vatemplatesfrom;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END clonetemplates;

	FUNCTION importcontracttype
	(
		pctypefrom NUMBER
	   ,pctypeto   NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ImportContractType';
		cfuncname    CONSTANT VARCHAR2(100) := 'ImportContractType';
		vpackage          VARCHAR2(40);
		vret              NUMBER;
		vaclonedtemplates apitypes.typesotemplatearray;
		vprintformcount   NUMBER;
		vbranch           NUMBER := seance.getbranch();
	BEGIN
		vpackage := contracttype.getschemapackage(pctypefrom);
		IF (vpackage IS NULL)
		THEN
			vret := err.geterrorcode();
		ELSE
			vaclonedtemplates := clonetemplates(pctypefrom, pctypeto);
			t.note(cmethod_name, 'point 1');
			vprintformcount := contractprintform.cloneprintformssettings(pctypefrom, pctypeto);
			s.say(cmethod_name || ': vPrintFormCount=' || vprintformcount, csay_level);
			IF vaclonedtemplates.count > 0
			   AND vprintformcount > 0
			THEN
				FOR i IN 1 .. vaclonedtemplates.count
				LOOP
					s.say(cmethod_name || ': copy from ' || to_char(vaclonedtemplates(i).id) ||
						  ' to ' || to_char(vaclonedtemplates(i).parenttemplateid)
						 ,csay_level);
					UPDATE tcontractprintform t
					SET    t.opercode = to_char(vaclonedtemplates(i).parenttemplateid)
					WHERE  t.branch = vbranch
					AND    t.contracttype = pctypeto
					AND    t.opercode = to_char(vaclonedtemplates(i).id);
				END LOOP;
			END IF;
			t.note(cmethod_name, 'point 2');
			contracttools.copyacctypeperiod(pctypefrom, pctypeto);
			t.note(cmethod_name, 'point 3');
			contracttools.cloneitems(pctypefrom, pctypeto);
			t.note(cmethod_name, 'point 4');
			contractparams.copyparameters(contractparams.ccontracttype, pctypefrom, pctypeto);
			t.note(cmethod_name, 'point 5');
			referenceprchistory.copypercentid(referenceprchistory.ccontracttype
											 ,pctypefrom
											 ,pctypeto
											 ,TRUE);
			t.note(cmethod_name, 'point 6');
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:N/in:N/ret:N')
			THEN
				s.say(cmethod_name || ': from ' || pctypefrom || ' to ' || pctypeto, csay_level);
				EXECUTE IMMEDIATE upper('begin :RET := ' || vpackage || '.' || cfuncname ||
										'(:pCTypeFrom, :pCTypeTo); end;')
					USING OUT vret, IN pctypefrom, IN pctypeto;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage
														  ,cfuncname
														  ,pdoexception => FALSE);
				err.seterror(err.refct_undefined_oper, cmethod_name);
				vret := err.refct_undefined_oper;
			END IF;
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END importcontracttype;

	PROCEDURE checkitemaccountarraysetup IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CheckItemAccountArraySetup';
		cmaxlen      CONSTANT NUMBER := 500;
		vindex      NUMBER;
		vitem       titemaccrecord;
		verrorcount NUMBER := 0;
		verrortext  VARCHAR2(32767);
	BEGIN
		vindex := contracttypeschema.saitemaccountarray.first;
		LOOP
			EXIT WHEN vindex IS NULL;
			vitem                := custom_contracttypeschema.saitemaccountarray(vindex);
			vitem.createmode     := nvl(vitem.createmode, contractaccount.createmode_atonceonly);
			vitem.refaccounttype := nvl(vitem.refaccounttype, contractaccount.refaccounttype_single);
		
			IF vitem.refaccounttype = contractaccount.refaccounttype_period
			   AND vitem.createmode != contractaccount.createmode_dynamiconly
			THEN
			
				verrorcount := verrorcount + 1;
				verrortext  := verrortext || service.iif(verrortext IS NOT NULL, ', ', NULL) || contracttypeschema.saitemaccountarray(vindex)
							  .itemname;
			END IF;
		
			custom_contracttypeschema.saitemaccountarray(vindex) := vitem;
		
			vindex := contracttypeschema.saitemaccountarray.next(vindex);
		END LOOP;
		IF verrorcount > 0
		THEN
			t.note(cmethod_name, 'Full List of error: ' || verrortext);
			IF length(verrortext) > cmaxlen
			THEN
				verrortext := substr(verrortext, 1, instr(verrortext, ',', cmaxlen));
				IF instr(verrortext, ',', -1) - 1 > 0
				THEN
					verrortext := substr(verrortext, 1, instr(verrortext, ',', -1) - 1);
				END IF;
				verrortext := verrortext || ' and others';
			END IF;
			error.raiseerror(err.refct_undefined_schema
							,'Only dynamic account creation is possible [' || verrortext || ']');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END checkitemaccountarraysetup;

	PROCEDURE fillitemaccountarray(ppackage IN VARCHAR2) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FillItemAccountArray';
		cexecname    CONSTANT VARCHAR2(65) := 'FillItemAccountArray';
		vret   NUMBER;
		vindex NUMBER;
	BEGIN
	
		saitemaccountarray.delete;
		IF contractschemas.existsmethod(ppackage, cexecname, '/out:A/ret:E')
		THEN
			EXECUTE IMMEDIATE upper('begin ' || ppackage || '.' || cexecname ||
									'(:ACCOUNTITEMARRAY); end;')
				USING OUT saitemaccountarray;
		
		ELSIF contractschemas.existsmethod(ppackage, cexecname, '/ret:N')
		THEN
			EXECUTE IMMEDIATE upper('begin :RET := ' || ppackage || '.' || cexecname || '; end;')
				USING OUT vret;
			IF vret != 0
			THEN
				error.raisewhenerr();
			END IF;
		
		ELSE
			contractschemas.reportunsupportedoperation(ppackage, cexecname);
		END IF;
	
		checkitemaccountarraysetup();
	
		vindex := saitemaccountarray.first;
		WHILE vindex IS NOT NULL
		LOOP
			t.note('AccountItem'
				  , vindex || ': ' || saitemaccountarray(vindex).itemname || ' [' || saitemaccountarray(vindex)
				   .description || '] ' || ', CreateMode=' || saitemaccountarray(vindex).createmode ||
					', RefAccountType=' || saitemaccountarray(vindex).refaccounttype ||
					', IsCardAccount=' || saitemaccountarray(vindex).iscardaccount ||
					', CurrRangeMethod=' || saitemaccountarray(vindex).currrangemethod ||
					', CurrRange=' || saitemaccountarray(vindex).currrange ||
					', PermitAccTypeDifference=' ||
					htools.b2s(saitemaccountarray(vindex).permitacctypedifference) ||
					', AccountSign=' || saitemaccountarray(vindex).accountsign);
			vindex := saitemaccountarray.next(vindex);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END fillitemaccountarray;

	PROCEDURE fillitemaccountarray
	(
		ppackage       IN VARCHAR2
	   ,oaaccountarray OUT NOCOPY titemaccarray
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.FillItemAccountArray[2]';
	BEGIN
		fillitemaccountarray(ppackage);
		oaaccountarray := saitemaccountarray;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END fillitemaccountarray;

	FUNCTION fillcaparray(pctype IN NUMBER) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillCapArray';
		vpackage VARCHAR2(40);
		vret     NUMBER;
	BEGIN
		scontractrow.type := pctype;
		vpackage          := contracttype.getschemapackage(pctype);
		IF (vpackage IS NULL)
		THEN
			vret := err.geterrorcode();
		ELSE
		
			IF contractschemas.existsmethod(vpackage, 'FillCapArray', '/ret:N')
			THEN
			
				EXECUTE IMMEDIATE upper('begin :RET := ' || vpackage || '.FillCapArray; end;')
					USING OUT vret;
			ELSE
				err.seterror(err.refct_undefined_oper, cmethod_name);
				vret := err.refct_undefined_oper;
			END IF;
		END IF;
	
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END fillcaparray;

	PROCEDURE fillsecurityarray
	(
		pschemepackage IN tcontractschemas.packagename%TYPE
	   ,popercode      IN VARCHAR2
	   ,pparams        IN typefillsecurityarrayparams := semptyfillsecurityarrayparams
	) IS
		cmethod_name  CONSTANT VARCHAR2(65) := cpackage_name || '.FillSecurityArray';
		cexecprocname CONSTANT VARCHAR2(65) := 'FillSecurityArray';
		vschemerow tcontractschemas%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
	
		vschemerow        := contractschemas.getrecord(pschemepackage, TRUE);
		scontractrow.type := pparams.contracttype;
		IF contractschemas.existsmethod(vschemerow.packagename, cexecprocname, '/in:V/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vschemerow.packagename || '.' || cexecprocname ||
							  '(:OPER); END;'
				USING IN popercode;
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END fillsecurityarray;

	PROCEDURE execdialogproc
	(
		pcontractno IN VARCHAR2
	   ,pwhat       IN CHAR
	   ,pdialog     IN NUMBER
	   ,pitemname   IN VARCHAR2
	   ,pcmd        IN NUMBER
	) IS
		cmethod_name  CONSTANT VARCHAR2(200) := cpackage_name || '.ExecDialogProc';
		cexecprocname CONSTANT VARCHAR2(65) := 'ExecDialogProc';
	
		vpackage VARCHAR2(40);
	
	BEGIN
		scontractrow := contract.getcontractrowtype(pcontractno);
		vpackage     := contracttype.getschemapackage(scontractrow.type);
	
		IF vpackage IS NULL
		THEN
			RETURN;
		ELSE
			IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:C/in:N/in:V/in:N/ret:E')
			THEN
				EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || upper(cexecprocname) ||
								  '(:WHAT, :DIALOG, :ITEMCODE, :CMD); END;'
					USING IN pwhat, pdialog, pitemname, pcmd;
			ELSE
				RETURN;
			END IF;
		END IF;
	
	EXCEPTION
	
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END execdialogproc;

	PROCEDURE undolabel
	(
		pcontractno tcontract.no%TYPE
	   ,plabel      contractrb.tlabel
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.UndoLabel';
		cexecprocname CONSTANT VARCHAR2(100) := 'UndoLabel';
		vpackagename tcontractschemas.packagename%TYPE;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno || ', pLabel=' || plabel);
		vpackagename := contracttype.getschemapackage(contract.gettype(pcontractno));
		IF vpackagename IS NULL
		THEN
			error.raisewhenerr();
		END IF;
		IF contractschemas.existsmethod(vpackagename, cexecprocname, '/in:V/in:I/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackagename || '.' || cexecprocname ||
							  '(:PCONTRACTNO, :PLABEL); END;'
				USING IN pcontractno, IN plabel;
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END undolabel;

	FUNCTION getlabeldescription
	(
		pcontractno IN tcontract.no%TYPE
	   ,plabel      IN contractrb.tlabel
	) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetLabelDescription';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetLabelDescription';
		vpackagename tcontractschemas.packagename%TYPE;
		vname        VARCHAR2(200);
		cwarningmessage CONSTANT VARCHAR2(200) := 'Scheme ' || vpackagename ||
												  ' does not support labels decryption';
	BEGIN
		vpackagename := contracttype.getschemapackage(contract.gettype(pcontractno));
	
		IF contractschemas.existsmethod(vpackagename, cfuncname, '/in:V/in:I/ret:V')
		THEN
			EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackagename || '.' || cfuncname ||
							  '(:PCONTRACTNO, :PLABEL); END;'
				USING OUT vname, IN pcontractno, IN plabel;
		ELSE
			vname := cwarningmessage;
		END IF;
	
		RETURN substr(vname, 1, 65);
	EXCEPTION
		WHEN OTHERS THEN
			RETURN cwarningmessage;
	END getlabeldescription;

	FUNCTION getlabeldescription
	(
		pcontractno IN tcontract.no%TYPE
	   ,plabel      IN VARCHAR2
	) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetLabelDescription';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetLabelDescription';
		vpackagename tcontractschemas.packagename%TYPE;
		vname        VARCHAR2(200);
		cwarningmessage CONSTANT VARCHAR2(200) := 'Scheme ' || vpackagename ||
												  ' does not support labels decryption';
	BEGIN
		vpackagename := contracttype.getschemapackage(contract.gettype(pcontractno));
	
		IF contractschemas.existsmethod(vpackagename, cfuncname, '/in:V/in:V/ret:V')
		THEN
			EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackagename || '.' || cfuncname ||
							  '(:PCONTRACTNO, :PLABEL); END;'
				USING OUT vname, IN pcontractno, IN plabel;
		ELSE
			vname := cwarningmessage;
		END IF;
	
		RETURN substr(vname, 1, 65);
	EXCEPTION
		WHEN OTHERS THEN
			RETURN cwarningmessage;
	END getlabeldescription;

	PROCEDURE addentrypropertiesitem
	(
		pcontractuid         IN tcontract.objectuid%TYPE
	   ,pentrypropertiesitem IN typeentryproperties
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.AddEntryPropertiesItem';
		vuid tcontract.objectuid%TYPE;
	BEGIN
		s.say(cmethod_name || ' start, pContractUID=' || pcontractuid || ', ContractNo=' ||
			  pentrypropertiesitem.contractno
			 ,csay_level);
		vuid := pcontractuid;
		IF vuid IS NULL
		THEN
			vuid := contract.getuid(pentrypropertiesitem.contractno);
		END IF;
		saentrypropertieslist(to_char(vuid)) := pentrypropertiesitem;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE delentrypropertiesitem(pcontractuid IN tcontract.objectuid%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.DelEntryPropertiesItem';
	BEGIN
	
		IF saentrypropertieslist.exists(to_char(pcontractuid))
		THEN
			saentrypropertieslist.delete(to_char(pcontractuid));
		
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getentrypropertiescount RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.EntryPropertiesCount';
	BEGIN
		RETURN saentrypropertieslist.count;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE clearentryproperties IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.ClearEntryProperties';
	BEGIN
		saentrypropertieslist.delete();
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getentrypropertieslist RETURN typeentrypropertieslist IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetEntryPropertiesList';
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.leave(cmethod_name
			   ,'saEntryPropertiesList.count=' || saentrypropertieslist.count
			   ,csay_level);
		RETURN saentrypropertieslist;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE entryundoinit(poentryprops IN OUT typeentryproperties) IS
		cmethod_name  CONSTANT VARCHAR2(65) := cpackage_name || '.EntryUndoInit [1]';
		cexecprocname CONSTANT VARCHAR2(65) := 'EntryUndoInit';
		vpackagename tcontractschemas.packagename%TYPE;
	
		vbranch     NUMBER := seance.getbranch();
		ventryprops typeentryproperties;
	
		CURSOR c1 IS
			SELECT DISTINCT objectuid
						   ,(no) contractno
						   ,(TYPE) contracttype
			FROM   (SELECT c.objectuid
						  ,c.no
						  ,c.type
					FROM   tentry e
					INNER  JOIN tdocument d
					ON     d.branch = e.branch
					AND    d.docno = e.docno
					AND    d.newdocno IS NULL
					INNER  JOIN tcontractitem i
					ON     i.branch = e.branch
					AND    i.key = e.debitaccount
					INNER  JOIN tcontract c
					ON     c.branch = i.branch
					AND    c.no = i.no
					WHERE  e.branch = vbranch
					AND    e.docno = poentryprops.docno
					UNION ALL
					SELECT c.objectuid
						  ,c.no
						  ,c.type
					FROM   tentry e
					INNER  JOIN tdocument d
					ON     d.branch = e.branch
					AND    d.docno = e.docno
					AND    d.newdocno IS NULL
					INNER  JOIN tcontractitem i
					ON     i.branch = e.branch
					AND    i.key = e.creditaccount
					INNER  JOIN tcontract c
					ON     c.branch = i.branch
					AND    c.no = i.no
					WHERE  e.branch = vbranch
					AND    e.docno = poentryprops.docno);
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
	
		t.inpar('poEntryProps.EntryMode', poentryprops.entrymode);
		t.inpar('poEntryProps.EntryCheck', poentryprops.entrycheck);
		t.inpar('poEntryProps.DocNo', poentryprops.docno);
		t.inpar('poEntryProps.EntryNo', poentryprops.entryno);
		t.inpar('poEntryProps.Value', poentryprops.value);
		t.inpar('poEntryProps.AccountHandle', poentryprops.accounthandle);
		t.inpar('poEntryProps.NewDocNo', poentryprops.newdocno);
		t.inpar('poEntryProps.NewEntryNo', poentryprops.newentryno);
	
		clearentryproperties();
	
		FOR i IN c1
		LOOP
		
			ventryprops              := poentryprops;
			ventryprops.contractno   := i.contractno;
			ventryprops.contracttype := i.contracttype;
		
			vpackagename := contracttype.getschemapackage(i.contracttype);
			t.var('vPackageName', vpackagename);
			IF (vpackagename IS NULL)
			THEN
				error.raiseerror(excsystem_error
								,'Not found name of scheme batch for contract type: ' ||
								 i.contracttype);
			ELSE
				ventryprops.packagename := vpackagename;
				addentrypropertiesitem(i.objectuid, ventryprops);
			
				sentryprops := ventryprops;
			
				IF contractschemas.existsmethod(vpackagename, cexecprocname, '/inout:S/ret:E')
				THEN
					EXECUTE IMMEDIATE 'BEGIN ' || vpackagename || '.' || cexecprocname ||
									  '(CONTRACTTYPESCHEMA.SENTRYPROPS); END;';
					t.var('[1] sEntryProps.NewDocNo', sentryprops.newdocno);
					t.var('[1] sEntryProps.NewEntryNo', sentryprops.newentryno);
				
					IF sentryprops.newentryno IS NULL
					   AND ventryprops.newentryno IS NOT NULL
					THEN
						error.raiseerror('Scheme [' || vpackagename ||
										 '] returned incorrect entry number (null)');
					END IF;
					sentryprops.newentryno := nvl(sentryprops.newentryno, 0);
					poentryprops           := sentryprops;
				
				ELSE
					IF contractschemas.existsmethod(vpackagename, cexecprocname, '/in:V/in:N/ret:E')
					THEN
					
						EXECUTE IMMEDIATE 'BEGIN ' || vpackagename || '.' || cexecprocname ||
										  '(:CONTRACTNO, :DOCNO); END;'
							USING IN i.contractno, IN poentryprops.docno;
					ELSE
						t.note(cmethod_name
							  ,'[2] Method is not supported by Scheme [' || vpackagename || ']'
							  ,csay_level);
					END IF;
				END IF;
			END IF;
		END LOOP;
	
		t.leave(cmethod_name, 'EntryPropertiesCount=' || getentrypropertiescount(), csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			clearentryproperties();
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE entryundopre(poentryprops IN OUT typeentryproperties) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.EntryUndoPre[1]';
		vsop_params typesop_parameter;
	
		vindex typestr4index;
	
		vaentryproplist typeentrypropertieslist;
		ventry          apitypes.typeentryrecord;
		vcontractno     tcontract.no%TYPE;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('poEntryProps.EntryMode', poentryprops.entrymode);
		t.inpar('poEntryProps.EntryCheck', poentryprops.entrycheck);
		t.inpar('poEntryProps.DocNo', poentryprops.docno);
		t.inpar('poEntryProps.EntryNo', poentryprops.entryno);
		t.inpar('poEntryProps.Value', poentryprops.value);
		t.inpar('poEntryProps.AccountHandle', poentryprops.accounthandle);
		t.inpar('poEntryProps.NewDocNo', poentryprops.newdocno);
		t.inpar('poEntryProps.NewEntryNo', poentryprops.newentryno);
	
		t.inpar('poEntryProps.DebitAccount', poentryprops.debitaccount);
		t.inpar('poEntryProps.CreditAccount', poentryprops.creditaccount);
	
		t.inpar('poEntryProps.MakeEntry', t.b2t(poentryprops.makeentry));
		poentryprops.makeentry := nvl(poentryprops.makeentry, TRUE);
	
		IF poentryprops.entryno IS NOT NULL
		THEN
			ventry := entry.getentryrecord(poentryprops.docno, poentryprops.entryno);
		
			vcontractno := contract.getcontractnobyaccno(ventry.debitaccount, FALSE);
			t.var('[debit] vContractNo', vcontractno);
			IF vcontractno IS NOT NULL
			THEN
			
				vindex := to_char(contract.getuid(vcontractno));
				IF saentrypropertieslist.exists(vindex)
				THEN
					vaentryproplist(vindex) := saentrypropertieslist(vindex);
				
				END IF;
			END IF;
		
			vcontractno := contract.getcontractnobyaccno(ventry.creditaccount, FALSE);
			t.var('[credit] vContractNo', vcontractno);
			IF vcontractno IS NOT NULL
			THEN
			
				vindex := to_char(contract.getuid(vcontractno));
				IF saentrypropertieslist.exists(vindex)
				THEN
					vaentryproplist(vindex) := saentrypropertieslist(vindex);
				
				END IF;
			END IF;
			t.note('[1] vaEntryPropList.Count', vaentryproplist.count);
		ELSE
			vaentryproplist := getentrypropertieslist();
		END IF;
	
		sentryprops            := poentryprops;
		sentryprops.newentryno := nvl(sentryprops.newentryno, 0);
	
		vindex := vaentryproplist.first();
		WHILE vindex IS NOT NULL
		LOOP
			t.note(cmethod_name
				  ,', vIndex=' || vindex || ', ContractNo=' || vaentryproplist(vindex).contractno
				  ,csay_level);
			sentryprops.contractno   := vaentryproplist(vindex).contractno;
			sentryprops.contracttype := vaentryproplist(vindex).contracttype;
			sentryprops.packagename  := vaentryproplist(vindex).packagename;
		
			sop_batchexec(saentryundopre_cursors
						 ,vsop_params
						 ,vaentryproplist(vindex).packagename
						 ,centryundopre);
		
			t.var('sEntryProps.NewDocNo', sentryprops.newdocno);
			t.var('sEntryProps.NewEntryNo', sentryprops.newentryno);
		
			t.var('sEntryProps.DebitAccount', sentryprops.debitaccount);
			t.var('sEntryProps.CreditAccount', sentryprops.creditaccount);
		
			IF sentryprops.newentryno IS NULL
			   AND poentryprops.newentryno IS NOT NULL
			THEN
				error.raiseerror('Scheme [' || vaentryproplist(vindex).packagename ||
								 '] returned incorrect entry number (null)');
			END IF;
			sentryprops.newentryno := nvl(sentryprops.newentryno, 0);
			poentryprops           := sentryprops;
		
			vindex := vaentryproplist.next(vindex);
		
		END LOOP;
	
		t.outpar('poEntryProps.DebitAccount', poentryprops.debitaccount);
		t.outpar('poEntryProps.CreditAccount', poentryprops.creditaccount);
	
		t.outpar('poEntryProps.MakeEntry', t.b2t(poentryprops.makeentry));
		poentryprops.makeentry := nvl(poentryprops.makeentry, TRUE);
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			clearentryproperties();
			error.save(cmethod_name);
			RAISE;
	END entryundopre;

	PROCEDURE entryundopost(poentryprops IN OUT typeentryproperties) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.EntryUndoPost[1]';
		vsop_params typesop_parameter;
	
		vindex typestr4index;
	
		vaentryproplist typeentrypropertieslist;
		ventry          apitypes.typeentryrecord;
		vcontractno     tcontract.no%TYPE;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('poEntryProps.EntryMode', poentryprops.entrymode);
		t.inpar('poEntryProps.EntryCheck', poentryprops.entrycheck);
		t.inpar('poEntryProps.DocNo', poentryprops.docno);
		t.inpar('poEntryProps.EntryNo', poentryprops.entryno);
		t.inpar('poEntryProps.Value', poentryprops.value);
		t.inpar('poEntryProps.AccountHandle', poentryprops.accounthandle);
		t.inpar('poEntryProps.NewDocNo', poentryprops.newdocno);
		t.inpar('poEntryProps.NewEntryNo', poentryprops.newentryno);
	
		t.inpar('poEntryProps.DebitAccount', poentryprops.debitaccount);
		t.inpar('poEntryProps.CreditAccount', poentryprops.creditaccount);
	
		t.inpar('poEntryProps.MakeEntry', t.b2t(poentryprops.makeentry));
		poentryprops.makeentry := nvl(poentryprops.makeentry, TRUE);
	
		IF poentryprops.entryno IS NOT NULL
		THEN
			ventry := entry.getentryrecord(poentryprops.docno, poentryprops.entryno);
		
			vcontractno := contract.getcontractnobyaccno(ventry.debitaccount, FALSE);
			t.var('[debit] vContractNo', vcontractno);
			IF vcontractno IS NOT NULL
			THEN
			
				vindex := to_char(contract.getuid(vcontractno));
				IF saentrypropertieslist.exists(vindex)
				THEN
					vaentryproplist(vindex) := saentrypropertieslist(vindex);
				
				END IF;
			END IF;
		
			vcontractno := contract.getcontractnobyaccno(ventry.creditaccount, FALSE);
			t.var('[credit] vContractNo', vcontractno);
			IF vcontractno IS NOT NULL
			THEN
			
				vindex := to_char(contract.getuid(vcontractno));
				IF saentrypropertieslist.exists(vindex)
				THEN
					vaentryproplist(vindex) := saentrypropertieslist(vindex);
				
				END IF;
			END IF;
			t.note('[1] vaEntryPropList.Count', vaentryproplist.count);
		ELSE
			vaentryproplist := getentrypropertieslist();
		END IF;
	
		sentryprops            := poentryprops;
		sentryprops.newentryno := nvl(sentryprops.newentryno, 0);
	
		vindex := vaentryproplist.first();
		WHILE vindex IS NOT NULL
		LOOP
			t.note(cmethod_name
				  ,', vIndex=' || vindex || ', ContractNo=' || vaentryproplist(vindex).contractno
				  ,csay_level);
			sentryprops.contractno   := vaentryproplist(vindex).contractno;
			sentryprops.contracttype := vaentryproplist(vindex).contracttype;
			sentryprops.packagename  := vaentryproplist(vindex).packagename;
		
			sop_batchexec(saentryundopre_cursors
						 ,vsop_params
						 ,vaentryproplist(vindex).packagename
						 ,centryundopost);
		
			t.var('sEntryProps.NewDocNo', sentryprops.newdocno);
			t.var('sEntryProps.NewEntryNo', sentryprops.newentryno);
		
			t.var('sEntryProps.DebitAccount', sentryprops.debitaccount);
			t.var('sEntryProps.CreditAccount', sentryprops.creditaccount);
		
			t.var('poEntryProps.MakeEntry', t.b2t(poentryprops.makeentry));
		
			IF sentryprops.newentryno IS NULL
			   AND poentryprops.newentryno IS NOT NULL
			THEN
				error.raiseerror('Scheme [' || vaentryproplist(vindex).packagename ||
								 '] returned incorrect entry number (null)');
			END IF;
			sentryprops.newentryno := nvl(sentryprops.newentryno, 0);
			poentryprops           := sentryprops;
		
			vindex := vaentryproplist.next(vindex);
		
		END LOOP;
	
		IF poentryprops.entrymode = contracttypeschema.centrymode_del
		THEN
		
			contractentrylog.setannulcontractentrylog(poentryprops.docno);
		
		ELSIF poentryprops.entrymode = contracttypeschema.centrymode_edit
		THEN
			contractentrylog.updatedocno(poentryprops.docno, poentryprops.docno4update);
		ELSIF poentryprops.entrymode IN (centrymode_undo, centrymode_undofast)
		THEN
			contractentrylog.deletecontractentrylog(poentryprops.docno);
		
		END IF;
	
		t.outpar('poEntryProps.DebitAccount', poentryprops.debitaccount);
		t.outpar('poEntryProps.CreditAccount', poentryprops.creditaccount);
	
		t.outpar('poEntryProps.MakeEntry', t.b2t(poentryprops.makeentry));
		poentryprops.makeentry := nvl(poentryprops.makeentry, TRUE);
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			clearentryproperties();
			error.save(cmethod_name);
			RAISE;
	END entryundopost;

	PROCEDURE entryundodone(poentryprops IN OUT typeentryproperties) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.EntryUndoDone[1]';
		cexecprocname CONSTANT VARCHAR2(100) := 'EntryUndoDone';
		vaentryproplist typeentrypropertieslist;
	
		vindex typestr4index;
	
		ventryprops typeentryproperties;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
	
		t.inpar('poEntryProps.EntryMode', poentryprops.entrymode);
		t.inpar('poEntryProps.EntryCheck', poentryprops.entrycheck);
		t.inpar('poEntryProps.DocNo', poentryprops.docno);
		t.inpar('poEntryProps.EntryNo', poentryprops.entryno);
		t.inpar('poEntryProps.Value', poentryprops.value);
		t.inpar('poEntryProps.AccountHandle', poentryprops.accounthandle);
		t.inpar('poEntryProps.NewDocNo', poentryprops.newdocno);
		t.inpar('poEntryProps.NewEntryNo', poentryprops.newentryno);
	
		vaentryproplist := getentrypropertieslist();
	
		vindex := vaentryproplist.first();
		WHILE vindex IS NOT NULL
		LOOP
			t.var('vaEntryPropList(vIndex).PackageName', vaentryproplist(vindex).packagename);
			IF vaentryproplist(vindex).packagename IS NULL
			THEN
				error.raiseerror(excsystem_error
								, 'Not found name of scheme batch for contract type ' || vaentryproplist(vindex)
								 .contracttype);
			ELSE
				ventryprops := vaentryproplist(vindex);
				vaentryproplist(vindex) := poentryprops;
				vaentryproplist(vindex).contractno := ventryprops.contractno;
				vaentryproplist(vindex).contracttype := ventryprops.contracttype;
				vaentryproplist(vindex).packagename := ventryprops.packagename;
			
				sentryprops            := vaentryproplist(vindex);
				sentryprops.newentryno := nvl(sentryprops.newentryno, 0);
			
				IF contractschemas.existsmethod(vaentryproplist(vindex).packagename
											   ,cexecprocname
											   ,'/inout:S/ret:E')
				THEN
					EXECUTE IMMEDIATE 'BEGIN ' || vaentryproplist(vindex).packagename || '.' ||
									  cexecprocname || '(CONTRACTTYPESCHEMA.SENTRYPROPS); END;';
					t.var('[1] sEntryProps.NewDocNo', sentryprops.newdocno);
					t.var('[1] sEntryProps.NewEntryNo', sentryprops.newentryno);
				
					IF sentryprops.newentryno IS NULL
					   AND poentryprops.newentryno IS NOT NULL
					THEN
						error.raiseerror('Scheme [' || vaentryproplist(vindex).packagename ||
										 '] returned incorrect entry number (null)');
					END IF;
					sentryprops.newentryno := nvl(sentryprops.newentryno, 0);
					poentryprops           := sentryprops;
				ELSE
					IF contractschemas.existsmethod(vaentryproplist(vindex).packagename
												   ,cexecprocname
												   ,'/in:V/in:N/ret:E')
					THEN
					
						EXECUTE IMMEDIATE 'BEGIN ' || vaentryproplist(vindex).packagename || '.' ||
										  cexecprocname || '(:CONTRACTNO, :DOCNO); END;'
							USING IN vaentryproplist(vindex).contractno, IN poentryprops.docno;
					ELSE
						t.note(cmethod_name
							  , '[2] Method is not supported by Scheme [' || vaentryproplist(vindex)
							   .packagename || ']'
							  ,csay_level);
					END IF;
				END IF;
			END IF;
			vindex := vaentryproplist.next(vindex);
		
		END LOOP;
		clearentryproperties();
		t.leave(cmethod_name, 'EntryPropertiesCount=' || getentrypropertiescount(), csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			clearentryproperties();
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION needstatementgenerate
	(
		pcontractno IN VARCHAR2
	   ,pprevdate   IN OUT DATE
	   ,pcurdate    IN DATE
	   ,pperiodtype IN NUMBER
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.NeedStatementGenerate';
		cfuncname    CONSTANT VARCHAR2(100) := 'NeedStatementGenerate';
		vtype    tcontract.type%TYPE;
		vpackage tcontractschemas.packagename%TYPE;
		vresult  NUMBER;
	BEGIN
		s.say(cmethod_name || ': ', csay_level);
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Contract No not specified');
		END IF;
	
		vtype := contract.gettype(pcontractno);
		IF vtype IS NULL
		THEN
			error.raisewhenerr();
		END IF;
		s.say(cmethod_name || ': contract type ' || vtype, csay_level);
	
		vpackage := contracttype.getschemapackage(vtype);
		IF vpackage IS NULL
		THEN
			error.raisewhenerr();
		END IF;
		s.say(cmethod_name || ': package name ' || vpackage, csay_level);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/inout:D/in:D/in:N/ret:N')
		THEN
			EXECUTE IMMEDIATE 'begin :1 := ' || vpackage || '.' || cfuncname ||
							  '(:2, :3, :4, :5); end;'
				USING OUT vresult, IN pcontractno, IN OUT pprevdate, IN pcurdate, IN pperiodtype;
		ELSE
			IF pperiodtype = statementrt.periodtype_contract
			THEN
				vresult := 0;
			ELSE
				vresult := 1;
			END IF;
		END IF;
	
		IF vresult NOT IN (0, 1)
		THEN
			error.raiseerror('Financial scheme error: invalid response to statement generation request. Contact developer.');
		END IF;
	
		IF (vresult = 1)
		   AND (pprevdate IS NULL)
		THEN
			error.raiseerror('Financial scheme error: response contains no statement start date. Contact developer.');
		END IF;
	
		s.say(cmethod_name || ': result ' || vresult, csay_level);
		RETURN vresult = 1;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END needstatementgenerate;

	FUNCTION initsotoperlist RETURN apitypes.typesoperationsysidarray IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.InitSOTOperList';
		varet apitypes.typesoperationsysidarray;
		CURSOR coperationcode IS
			SELECT rownum      idx
				  ,object_name code
			FROM   user_objects
			WHERE  object_type = 'PACKAGE BODY'
			AND    status = 'VALID'
			AND    object_name IN ('SOP_ACCADD'
								  ,'SOP_ACCADDCURRENCY'
								  ,'SOP_ACCIN'
								  ,'SOP_ACCOUT'
								  ,'SOP_ACCSUB'
								  ,'SOP_ACCSUBCURRENCY'
								  ,'SOP_ADDACCEPT'
								  ,'SOP_ADDACCEPTCONV'
								  ,'SOP_CASHPAYMENT2'
								  ,'SOP_CURRENCYBUY'
								  ,'SOP_CURRENCYSALE'
								  ,'SOP_SINGLEPAYMENT2'
								  ,'SOP_SUBACCEPT'
								  ,'SOP_SUBACCEPTCONV');
	BEGIN
		FOR i IN coperationcode
		LOOP
			varet(i.idx) := i.code;
		END LOOP;
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END initsotoperlist;

	PROCEDURE getsotoperlist
	(
		pcontracttype  IN NUMBER
	   ,poasotoperlist IN OUT apitypes.typesoperationsysidarray
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.GetSOTOperList';
		cexecprocname CONSTANT VARCHAR2(100) := 'GetSOTOperList';
		vpackage VARCHAR2(30);
	BEGIN
		s.say(cmethod_name || ': ', csay_level);
		vpackage := contracttype.getschemapackage(pcontracttype);
		IF vpackage IS NULL
		THEN
			error.raiseerror(excsystem_error
							,'Not found name of scheme batch for contract type: ' ||
							 scontractrow.type);
		END IF;
	
		sasotoperlist := initsotoperlist();
		s.say(cmethod_name || ': initial operations count ' || sasotoperlist.count, csay_level);
	
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:N/in:A/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
							  '(:TYPE, ContractTypeSchema.saSOTOperList); END;'
				USING IN pcontracttype;
		END IF;
	
		poasotoperlist := sasotoperlist;
		s.say(cmethod_name || ': final operations count ' || sasotoperlist.count, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getsotoperlist;

	PROCEDURE changecontracttype
	(
		pcontractno     IN tcontract.no%TYPE
	   ,pchangectparams IN typechangecontracttypeparams
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.ChangeContractType';
		cexecprocname CONSTANT VARCHAR2(100) := 'ChangeContractType';
		vpackage VARCHAR2(30);
		voldtype tcontract.type%TYPE;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pChangeCTParams.NewType=' ||
				pchangectparams.newtype || ', pChangeCTParams.WriteRBData=' ||
				t.b2t(pchangectparams.writerbdata)
			   ,csay_level);
	
		voldtype := contract.gettype(pcontractno, TRUE);
		t.var('vOldType', voldtype);
		vpackage := contracttype.getschemapackage(voldtype);
		IF vpackage IS NULL
		THEN
			error.raiseerror(excsystem_error
							,'Not found name of scheme batch for contract type ' || voldtype);
		END IF;
		IF pchangectparams.newtype IS NULL
		THEN
			error.raiseerror(excsystem_error, 'Contract type code not specified');
		END IF;
		IF voldtype != pchangectparams.newtype
		THEN
			t.note('point 01');
			schangectparams := pchangectparams;
		
			IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:S/ret:E')
			THEN
				EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
								  '(:NO, CONTRACTTYPESCHEMA.sChangeCTParams); END;'
					USING IN pcontractno;
			ELSE
				t.note('point 03');
				IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:N/in:N/ret:E')
				THEN
					EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
									  '(:NO,:OLDTYPE,:NEWTYPE); END;'
						USING IN pcontractno, IN voldtype, IN pchangectparams.newtype;
				ELSE
					contractschemas.reportunsupportedoperation(vpackage, cexecprocname);
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

	PROCEDURE changecontracttype_post
	(
		pcontractno     IN tcontract.no%TYPE
	   ,pchangectparams IN typechangecontracttypeparams
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.ChangeContractType_Post';
		cexecprocname CONSTANT VARCHAR2(100) := 'ChangeContractType_Post';
		vpackage VARCHAR2(30);
		voldtype tcontract.type%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pChangeCTParams.NewType=' ||
				pchangectparams.newtype || ', pChangeCTParams.WriteRBData=' ||
				t.b2t(pchangectparams.writerbdata)
			   ,csay_level);
	
		voldtype := contract.gettype(pcontractno, TRUE);
		t.var('vOldType', voldtype);
		vpackage := contracttype.getschemapackage(voldtype);
		IF vpackage IS NULL
		THEN
			error.raiseerror(excsystem_error
							,'Not found name of scheme batch for contract type ' || voldtype);
		END IF;
		IF pchangectparams.newtype IS NULL
		THEN
			error.raiseerror(excsystem_error, 'Contract type code not specified');
		END IF;
		IF voldtype != pchangectparams.newtype
		THEN
			t.note('point 01');
		
			schangectparams := pchangectparams;
		
			IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:S/ret:E')
			THEN
				EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
								  '(:NO, CONTRACTTYPESCHEMA.sChangeCTParams); END;'
					USING IN pcontractno;
			ELSE
				t.note('point 03');
				IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:N/in:N/ret:E')
				THEN
					EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
									  '(:NO, :OLDTYPE, :NEWTYPE); END;'
						USING IN pcontractno, IN voldtype, IN pchangectparams.newtype;
				ELSE
					t.note('point 04');
					t.note(cmethod_name
						  ,'[2] Method is not supported by Scheme [' || vpackage || ']'
						  ,csay_level);
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

	FUNCTION deletecontract
	(
		pcontractno IN tcontract.no%TYPE
	   ,pmode       IN PLS_INTEGER := NULL
	) RETURN typeoperationresult IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.DeleteContract';
		cfuncname    CONSTANT VARCHAR2(100) := 'DeleteContract';
		vpackage VARCHAR2(30);
		vret     typeoperationresult;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno || ', pMode=' || pmode, csay_level);
	
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Undefined contract No');
		ELSIF NOT contract.contractexists(pcontractno)
		THEN
			error.raiseerror('Contract with No [' || pcontractno || '] does not exist');
		END IF;
	
		vpackage := contracttype.getschemapackage(contract.gettype(pcontractno));
		IF vpackage IS NULL
		THEN
			error.raiseerror(excsystem_error, 'Not found name of scheme batch for contract type');
		END IF;
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:N/ret:N')
		THEN
			EXECUTE IMMEDIATE 'BEGIN :RET:=' || vpackage || '.' || cfuncname ||
							  '(:NO, :MODE); END;'
				USING OUT vret.resultvalue, IN pcontractno, IN pmode;
			t.var('vRet.ResultValue', vret.resultvalue);
		
			IF vret.resultvalue NOT IN (c_rollback_supported, c_rollback_unsupported)
			THEN
				error.saveraise(cmethod_name
							   ,error.errorconst
							   ,'Undefined value [' || vret.resultvalue ||
								'] received from scheme "' || vpackage || '"');
			END IF;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname, pdoexception => FALSE);
			vret.resultvalue := c_rollback_unsupported;
		END IF;
	
		t.leave(cmethod_name, ' vRet=' || vret.resultvalue, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION checkpossibilitycrd_stat
	(
		ppan     IN tcard.pan%TYPE
	   ,pmbr     IN tcard.mbr%TYPE
	   ,poldstat IN tcard.crd_stat%TYPE
	   ,pnewstat IN tcard.crd_stat%TYPE
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.CheckPossibilityCRD_STAT';
		cfuncname    CONSTANT VARCHAR2(100) := 'CheckPossibilityCRD_STAT';
		vresult     INTEGER;
		vcontractno tcontract.no%TYPE;
		vtype       tcontract.type%TYPE;
		vpackage    tcontractschemas.packagename%TYPE;
	BEGIN
		t.enter(cmethod_name, NULL, csay_level);
	
		vcontractno := contract.getcontractnobycard(ppan, pmbr, FALSE);
		s.say(cmethod_name || ': contract number ' || vcontractno, csay_level);
	
		IF vcontractno IS NULL
		THEN
			RETURN TRUE;
		END IF;
	
		vtype := contract.gettype(vcontractno);
		IF vtype IS NULL
		THEN
		
			error.raisewhenerr();
		
		END IF;
		s.say(cmethod_name || ': contract type ' || vtype, csay_level);
	
		vpackage := contracttype.getschemapackage(vtype);
		IF vpackage IS NULL
		THEN
		
			error.raisewhenerr();
		
		END IF;
		s.say(cmethod_name || ': package name ' || vpackage, csay_level);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:V/in:N/in:C/in:C/ret:N')
		THEN
			EXECUTE IMMEDIATE 'begin :1 := ' || vpackage || '.' || cfuncname ||
							  '(:2, :3, :4, :5, :6); end;'
				USING OUT vresult, IN vcontractno, IN ppan, IN pmbr, IN poldstat, IN pnewstat;
			IF vresult NOT IN (0, 1)
			THEN
				error.raiseerror('Error: financial scheme has returned value not in range (0, 1). Result=' ||
								 vresult);
			END IF;
		ELSE
			vresult := 1;
		END IF;
		t.leave(cmethod_name, ' return ' || t.b2t(vresult = 1), plevel => csay_level);
		RETURN vresult = 1;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END checkpossibilitycrd_stat;

	FUNCTION checkpossibilitysignstat
	(
		ppan     IN tcard.pan%TYPE
	   ,pmbr     IN tcard.mbr%TYPE
	   ,poldsign IN tcard.signstat%TYPE
	   ,pnewsign IN tcard.signstat%TYPE
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.CheckPossibilitySignStat';
		cfuncname    CONSTANT VARCHAR2(100) := 'CheckPossibilitySignStat';
		vresult     INTEGER;
		vcontractno tcontract.no%TYPE;
		vtype       tcontract.type%TYPE;
		vpackage    tcontractschemas.packagename%TYPE;
	BEGIN
		t.enter(cmethod_name, NULL, csay_level);
	
		vcontractno := contract.getcontractnobycard(ppan, pmbr, FALSE);
		s.say(cmethod_name || ': contract number ' || vcontractno, csay_level);
	
		IF vcontractno IS NULL
		THEN
			RETURN TRUE;
		END IF;
	
		vtype := contract.gettype(vcontractno);
		IF vtype IS NULL
		THEN
			error.raisewhenerr();
		END IF;
		s.say(cmethod_name || ': contract type ' || vtype, csay_level);
	
		vpackage := contracttype.getschemapackage(vtype);
		IF vpackage IS NULL
		THEN
			error.raisewhenerr();
		END IF;
		s.say(cmethod_name || ': package name ' || vpackage, csay_level);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:V/in:N/in:C/in:C/ret:N')
		THEN
			EXECUTE IMMEDIATE 'begin :1 := ' || vpackage || '.' || cfuncname ||
							  '(:2, :3, :4, :5, :6); end;'
				USING OUT vresult, IN vcontractno, IN ppan, IN pmbr, IN poldsign, IN pnewsign;
			IF vresult NOT IN (0, 1)
			THEN
				error.raiseerror('Error: financial scheme has returned value not in range (0, 1). Result=' ||
								 vresult);
			END IF;
		ELSE
			vresult := 1;
		END IF;
		t.leave(cmethod_name, ' return ' || t.b2t(vresult = 1), plevel => csay_level);
		RETURN vresult = 1;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END checkpossibilitysignstat;

	FUNCTION canlinkaccttocust(paccountno IN taccount.accountno%TYPE) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.CanLinkAcctToCust';
		cfuncname    CONSTANT VARCHAR2(100) := 'CanLinkAcctToCust';
		vcontractno tcontract.no%TYPE;
		vtype       tcontract.type%TYPE;
		vpackage    tcontractschemas.packagename%TYPE;
		vret        NUMBER;
	BEGIN
		t.enter(cmethod_name, 'Account number: ' || paccountno, csay_level);
		IF TRIM(paccountno) IS NULL
		THEN
			vret := 0;
		ELSE
			vcontractno := contract.getcontractnobyaccno(paccountno, FALSE);
			s.say(cmethod_name || ': contract number ' || vcontractno, csay_level);
		
			IF vcontractno IS NULL
			THEN
				vret := 1;
			ELSE
				vtype := contract.gettype(vcontractno);
				IF vtype IS NULL
				THEN
					error.raisewhenerr();
				END IF;
				s.say(cmethod_name || ': contract type ' || vtype, csay_level);
			
				vpackage := contracttype.getschemapackage(vtype);
				IF vpackage IS NULL
				THEN
					error.raisewhenerr();
				END IF;
				s.say(cmethod_name || ': package name ' || vpackage, csay_level);
			
				IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:V/ret:N')
				THEN
					EXECUTE IMMEDIATE 'begin :RET := ' || vpackage || '.' || cfuncname ||
									  '(:CONTRACTNO,:ACCOUNTNO); end;'
						USING OUT vret, IN vcontractno, IN paccountno;
					IF vret NOT IN (0, 1)
					THEN
						error.raiseerror('Error: financial scheme has returned value not in range (0, 1). Result=' || vret);
					END IF;
				ELSE
					vret := 1;
				END IF;
			END IF;
		END IF;
		t.leave(cmethod_name, ' return ' || t.b2t(vret = 1), plevel => csay_level);
		RETURN vret = 1;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ': generate exception: code ' || SQLCODE || ', message ' ||
				  SQLERRM
				 ,csay_level);
			RETURN FALSE;
	END canlinkaccttocust;

	FUNCTION getinitcontracttype RETURN NUMBER IS
	BEGIN
		IF scontracttype.exists(1)
		THEN
			RETURN scontracttype(1);
		ELSE
			RETURN NULL;
		END IF;
	END getinitcontracttype;

	FUNCTION getrollbackdata RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetRollbackData';
	BEGIN
		RETURN srollbackdata || contractrb.getrbdata();
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getrollbackdata;

	FUNCTION existrollbackdata RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.ExistRollbackData';
	BEGIN
		RETURN getrollbackdata() IS NOT NULL;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END existrollbackdata;

	PROCEDURE getcontractinformation
	(
		pcontractno      IN tcontract.no%TYPE
	   ,poafschparamlist IN OUT typefschparamlist
	) IS
		cmethod_name     CONSTANT VARCHAR2(100) := cpackage_name || '.GetContractInformation[1]';
		cexecprocname    CONSTANT VARCHAR2(100) := 'GetContractInformation';
		cmethod4checkrvp CONSTANT VARCHAR2(100) := 'RVPONGET_RESERVECONTEXT';
	
		vpackage        tcontractschemas.packagename%TYPE;
		vindex          NUMBER;
		varvpparamlist  typefschparamlist;
		vafschparamlist typefschparamlist;
		vaallparamlist  typefschparamlist;
		vfillall        BOOLEAN;
	BEGIN
		t.enter(cmethod_name
			   ,': ContractNo=' || pcontractno || ', poaFSchParamList.Count=' ||
				poafschparamlist.count
			   ,csay_level);
		vfillall := poafschparamlist.count = 0;
	
		vpackage := contracttype.getschemapackage(contract.gettype(pcontractno
																  ,pdoexception => TRUE)
												 ,pdoexception => TRUE);
		s.say(cmethod_name || ': package name ' || vpackage, csay_level);
	
		vindex := poafschparamlist.first;
		WHILE vindex IS NOT NULL
		LOOP
			t.note(cmethod_name
				  , 'ID(' || vindex || ')=' || poafschparamlist(vindex).id || ', Value=' || poafschparamlist(vindex)
				   .stringvalue);
			IF poafschparamlist(vindex).id LIKE crvpfschparamidprefix || '%'
			THEN
				varvpparamlist(varvpparamlist.count + 1) := poafschparamlist(vindex);
			ELSE
				vafschparamlist(vafschparamlist.count + 1) := poafschparamlist(vindex);
			END IF;
			vindex := poafschparamlist.next(vindex);
		END LOOP;
	
		IF vfillall
		   OR (varvpparamlist.count > 0)
		THEN
			IF contractschemas.existsmethod(vpackage, cmethod4checkrvp, '/ret:S')
			THEN
				IF contractschemas.existsmethod('Reserve', cexecprocname, '/in:V/inout:A/ret:E')
				THEN
					EXECUTE IMMEDIATE 'begin Reserve.' || cexecprocname ||
									  '(:CONTRACTNO, :PARAMLIST); end;'
						USING IN pcontractno, IN OUT varvpparamlist;
				ELSE
					contractschemas.reportunsupportedoperation(vpackage
															  ,cexecprocname
															  ,pdoexception => varvpparamlist.count > 0);
				END IF;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage
														  ,cmethod4checkrvp
														  ,pdoexception => varvpparamlist.count > 0);
			END IF;
		END IF;
	
		vaallparamlist := varvpparamlist;
	
		IF vfillall
		   OR (vafschparamlist.count > 0)
		   AND contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/inout:A/ret:E')
		THEN
			t.var('FSchParamList_Count(1)', vafschparamlist.count);
			EXECUTE IMMEDIATE 'begin ' || vpackage || '.' || cexecprocname ||
							  '(:CONTRACTNO, :PARAMLIST); end;'
				USING IN pcontractno, IN OUT vafschparamlist;
			t.var('FSchParamList_Count(2)', vafschparamlist.count);
		
			vindex := vafschparamlist.first;
			WHILE vindex IS NOT NULL
			LOOP
				vaallparamlist(vaallparamlist.count + 1) := vafschparamlist(vindex);
				vindex := vafschparamlist.next(vindex);
			END LOOP;
		
		ELSE
			contractschemas.reportunsupportedoperation(vpackage
													  ,cexecprocname
													  ,pdoexception => FALSE);
		END IF;
	
		poafschparamlist := vaallparamlist;
	
		FOR i IN 1 .. poafschparamlist.count
		LOOP
			t.note(cmethod_name
				  , 'ID (' || i || ')=' || poafschparamlist(i).id || ', Value=' || poafschparamlist(i)
				   .stringvalue);
		END LOOP;
	
		t.leave(cmethod_name, ': finished [' || poafschparamlist.count || ']', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcontractinformation;

	PROCEDURE changecontractparams
	(
		pcontractno     IN tcontract.no%TYPE
	   ,pcontracttype   IN tcontracttype.type%TYPE
	   ,pafschparamlist IN typefschparamlist
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.ChangeContractParams';
		cexecprocname CONSTANT VARCHAR2(100) := 'ChangeContractParams';
		vtype    tcontract.type%TYPE;
		vpackage tcontractschemas.packagename%TYPE;
	BEGIN
		s.say(cmethod_name || ': contract number: ' || pcontractno, csay_level);
	
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Contract No not defined');
		END IF;
	
		IF pafschparamlist.count = 0
		THEN
			error.raiseerror('Parameters to be changed not defined');
		END IF;
	
		vtype := nvl(pcontracttype, contract.gettype(pcontractno, pdoexception => TRUE));
		s.say(cmethod_name || ': contract type ' || vtype, csay_level);
	
		vpackage := contracttype.getschemapackage(vtype, pdoexception => TRUE);
		s.say(cmethod_name || ': package name ' || vpackage, csay_level);
	
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:N/in:A/ret:E')
		THEN
			EXECUTE IMMEDIATE 'begin ' || vpackage || '.' || cexecprocname ||
							  '(:CONTRACTNO, :CONTRACTTYPE, :PARAMLIST); end;'
				USING IN pcontractno, IN vtype, IN pafschparamlist;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cexecprocname);
		END IF;
	
		s.say(cmethod_name || ': finished', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecontractparams;

	FUNCTION getaccounttypeforchange
	(
		pcontractno       IN tcontract.no%TYPE
	   ,pcontracttypefrom IN tcontracttype.type%TYPE
	   ,pcontracttypeto   IN tcontracttype.type%TYPE
	   ,pitemname         IN tcontracttypeitemname.itemname%TYPE
	) RETURN taccount.accounttype%TYPE IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetAccountTypeForChange';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetAccountTypeForChange';
		vpackage tcontractschemas.packagename%TYPE;
		vret     NUMBER := 0;
	BEGIN
		s.say('Start ' || cmethod_name || ': pContractNo=' || pcontractno ||
			  ', pContractTypeFrom=' || pcontracttypefrom || ', pContractTypeTo=' ||
			  pcontracttypeto || ', pItemName=' || pitemname);
		vpackage := contracttype.getschemapackage(pcontracttypefrom);
		IF vpackage IS NULL
		THEN
			error.raisewhenerr();
		END IF;
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:N/in:N/in:V/ret:N')
		THEN
			EXECUTE IMMEDIATE 'BEGIN :RET :=' || vpackage || '.' || cfuncname ||
							  '(:NO,:OLDTYPE,:NEWTYPE,:ITEMNAME); END;'
				USING OUT vret, IN pcontractno, IN pcontracttypefrom, IN pcontracttypeto, IN pitemname;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname);
		END IF;
	
		s.say(cmethod_name || ': finished, vRet=' || vret, csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE drawinfopanel
	(
		phandle    IN NUMBER
	   ,pdialog    IN NUMBER
	   ,ppanelname IN VARCHAR2
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.DrawInfoPanel';
		cexecprocname CONSTANT VARCHAR2(100) := 'DrawInfoPanel';
		vpackage VARCHAR2(40);
	
		vpanel NUMBER := dialog.idbyname(pdialog, ppanelname);
	BEGIN
	
		sdialog      := pdialog;
		scontractrow := contract.getobject(phandle);
	
		vpackage := contracttype.getschemapackage(scontractrow.type);
		IF vpackage IS NULL
		THEN
			error.raisewhenerr();
		END IF;
	
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:N/in:N/in:N/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
							  '(:NO,:TYPE,:DIALOG,:PANEL); END;'
				USING IN scontractrow.no, IN scontractrow.type, IN pdialog, IN vpanel;
		ELSE
			FOR i IN 1 .. contractdlg.cschematextcount
			LOOP
				dialog.textlabel(vpanel
								,'SchemaText' || to_char(i)
								,1
								,i
								,contractdlg.cschematextwidth
								,' ');
			END LOOP;
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE fillinfopanel
	(
		phandle    IN NUMBER
	   ,pdialog    IN NUMBER
	   ,ppanelname IN VARCHAR2
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.FillInfoPanel';
		cexecprocname CONSTANT VARCHAR2(100) := 'FillInfoPanel';
		vpackage VARCHAR2(40);
	
		vret   VARCHAR2(255);
		vpanel NUMBER := dialog.idbyname(pdialog, ppanelname);
	BEGIN
		sdialog      := pdialog;
		scontractrow := contract.getobject(phandle);
	
		vpackage := contracttype.getschemapackage(scontractrow.type);
		IF vpackage IS NULL
		THEN
			error.raisewhenerr();
		END IF;
	
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:N/in:N/in:N/ret:E')
		THEN
			BEGIN
				EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
								  '(:NO,:TYPE,:DIALOG,:PANEL); END;'
					USING IN scontractrow.no, IN scontractrow.type, IN pdialog, IN vpanel;
			
			EXCEPTION
				WHEN OTHERS THEN
					error.save(cmethod_name);
				
					dialog.clearcontainer(vpanel);
				
					dialog.textlabel(vpanel
									,'SchemaText1'
									,1
									,1
									,contractdlg.cschematextwidth
									,' ');
					dialog.textlabel(vpanel
									,'SchemaText2'
									,1
									,2
									,contractdlg.cschematextwidth
									,' ');
				
					dialog.putchar(pdialog
								  ,'SchemaText1'
								  ,'Error getting informational data of scheme:');
					dialog.putchar(pdialog, 'SchemaText2', error.gettext());
					error.clear;
			END;
		
		ELSE
			FOR i IN 1 .. contractdlg.cschematextcount
			LOOP
				BEGIN
					error.clear;
					EXECUTE IMMEDIATE 'BEGIN :RET := ' || vpackage || '.GETINFOTEXT(:NUM); END;'
						USING OUT vret, IN i;
					vret := substr(vret, 1, contractdlg.cschematextwidth);
				EXCEPTION
					WHEN OTHERS THEN
					
						error.save(cmethod_name);
						vret := error.gettext();
					
				END;
				dialog.putchar(pdialog
							  ,'SchemaText' || to_char(i)
							  ,service.cpad(vret, contractdlg.cschematextwidth, ' '));
			END LOOP;
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE changecontractno
	(
		poldcontractno IN tcontract.no%TYPE
	   ,pnewcontractno IN tcontract.no%TYPE
	   ,poldtype       IN tcontracttype.type%TYPE
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.ChangeContractNo';
		cexecprocname CONSTANT VARCHAR2(100) := 'ChangeContractNo';
		vpackage VARCHAR2(30);
	BEGIN
		s.say('Start ' || cmethod_name || ': ', csay_level);
	
		vpackage := contracttype.getschemapackage(poldtype);
		IF vpackage IS NULL
		THEN
			error.raiseerror('Not found name of scheme batch for contract type: ' || poldtype);
		END IF;
	
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:V/in:V/in:N/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || upper(cexecprocname) ||
							  '(:OLDNO, :NEWNO, :OLDTYPE); END;'
				USING IN poldcontractno, IN pnewcontractno, IN poldtype;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cexecprocname);
		END IF;
	
		s.say('Finish ' || cmethod_name, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecontractno;

	PROCEDURE entryrestorepre
	(
		pmode      IN NUMBER
	   ,pcheck     IN NUMBER
	   ,pdocno     IN NUMBER
	   ,pno        IN NUMBER
	   ,pvalue     IN NUMBER
	   ,pacchandle IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.EntryRestorePre';
		vpackagename VARCHAR2(40);
		vsop_params  typesop_parameter;
		vbranch      NUMBER := seance.getbranch();
		CURSOR c1 IS
			SELECT DISTINCT objectuid
						   ,(no) contractno
						   ,(TYPE) contracttype
			FROM   (SELECT c.objectuid
						  ,c.no
						  ,c.type
					FROM   tcontract     c
						  ,tcontractitem i
						  ,tentry        e
					WHERE  e.branch = vbranch
					AND    e.docno = pdocno
					AND    i.branch = e.branch
					AND    i.key = e.debitaccount
					AND    c.branch = i.branch
					AND    c.no = i.no
					UNION ALL
					SELECT c.objectuid
						  ,c.no
						  ,c.type
					FROM   tcontract     c
						  ,tcontractitem i
						  ,tentry        e
					WHERE  e.branch = vbranch
					AND    e.docno = pdocno
					AND    i.branch = e.branch
					AND    i.key = e.creditaccount
					AND    c.branch = i.branch
					AND    c.no = i.no);
	
	BEGIN
		s.say(cmethod_name || ': ', csay_level);
		sentryprops.entrymode     := pmode;
		sentryprops.entrycheck    := pcheck;
		sentryprops.docno         := pdocno;
		sentryprops.entryno       := pno;
		sentryprops.value         := pvalue;
		sentryprops.accounthandle := pacchandle;
	
		FOR i IN c1
		LOOP
			sentryprops.contractno   := i.contractno;
			sentryprops.contracttype := i.contracttype;
			vpackagename             := contracttype.getschemapackage(i.contracttype);
			IF (vpackagename IS NULL)
			THEN
				error.raiseerror(excsystem_error
								,'Not found name of scheme batch for contract type: ' ||
								 i.contracttype);
			ELSE
				sentryprops.packagename := vpackagename;
				addentrypropertiesitem(i.objectuid, sentryprops);
				sop_batchexec(saentryrestore_cursors
							 ,vsop_params
							 ,vpackagename
							 ,centryrestorepre
							 ,TRUE);
			END IF;
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ': general exception ' || SQLCODE || ' ' || SQLERRM, csay_level);
			clearentryproperties();
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE entryrestorepost
	(
		pmode      IN NUMBER
	   ,pcheck     IN NUMBER
	   ,pdocno     IN NUMBER
	   ,pno        IN NUMBER
	   ,pvalue     IN NUMBER
	   ,pacchandle IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.EntryRestorePost';
		vsop_params typesop_parameter;
		vindex      typestr4index;
	BEGIN
		s.say(cmethod_name || ': ', csay_level);
		sentryprops.entrymode     := pmode;
		sentryprops.entrycheck    := pcheck;
		sentryprops.docno         := pdocno;
		sentryprops.entryno       := pno;
		sentryprops.value         := pvalue;
		sentryprops.accounthandle := pacchandle;
	
		vindex := saentrypropertieslist.last();
		WHILE vindex IS NOT NULL
		LOOP
			s.say(cmethod_name || ', vIndex=' || vindex || ', ContractNo=' || saentrypropertieslist(vindex)
				  .contractno
				 ,csay_level);
			sentryprops.contractno   := saentrypropertieslist(vindex).contractno;
			sentryprops.contracttype := saentrypropertieslist(vindex).contracttype;
			sop_batchexec(saentryrestore_cursors
						 ,vsop_params
						 ,saentrypropertieslist(vindex).packagename
						 ,centryrestorepost
						 ,TRUE);
			delentrypropertiesitem(vindex);
			vindex := saentrypropertieslist.prior(vindex);
		
		END LOOP;
		clearentryproperties;
	EXCEPTION
		WHEN OTHERS THEN
			s.say(cmethod_name || ': general exception ' || SQLCODE || ' ' || SQLERRM, csay_level);
			clearentryproperties();
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcontractinformation
	(
		pcontractno  IN tcontract.no%TYPE
	   ,pfschparamid IN typefschparamid
	   ,pstartdate   DATE := NULL
	   ,penddate     DATE := NULL
	) RETURN VARCHAR2 IS
		cmethod_name     CONSTANT VARCHAR2(100) := cpackage_name || '.GetContractInformation[2]';
		cfuncname        CONSTANT VARCHAR2(100) := 'GetContractInformation';
		cmethod4checkrvp CONSTANT VARCHAR2(100) := 'RVPONGET_RESERVECONTEXT';
		vpackage tcontractschemas.packagename%TYPE;
		vret     typefschstringvalue;
	BEGIN
		t.enter(cmethod_name
			   ,'contractNo=' || pcontractno || ', ParamId=' || pfschparamid || ', StartDate=' ||
				pstartdate || ', EndDate=' || penddate);
	
		IF pfschparamid IS NULL
		THEN
			error.raiseerror('Parameter ID not defined');
		END IF;
	
		vpackage := contracttype.getschemapackage(contract.gettype(pcontractno
																  ,pdoexception => TRUE)
												 ,pdoexception => TRUE);
		s.say(cmethod_name || ': package name ' || vpackage, csay_level);
	
		IF pfschparamid LIKE crvpfschparamidprefix || '%'
		THEN
			IF contractschemas.existsmethod(vpackage, cmethod4checkrvp, '/ret:S')
			THEN
				IF contractschemas.existsmethod('Reserve', cfuncname, '/in:V/in:V/ret:V')
				THEN
					EXECUTE IMMEDIATE 'begin :RET := Reserve.' || cfuncname ||
									  '(:CONTRACTNO, :PARAMID); end;'
						USING OUT vret, IN pcontractno, IN pfschparamid;
				ELSE
					contractschemas.reportunsupportedoperation(vpackage
															  ,cfuncname
															  ,pdoexception => TRUE);
				END IF;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage
														  ,cmethod4checkrvp
														  ,pdoexception => TRUE);
			END IF;
		ELSE
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:V/in:D/in:D/ret:V')
			THEN
				EXECUTE IMMEDIATE 'begin :RET :=' || vpackage || '.' || cfuncname ||
								  '(:CONTRACTNO, :PARAMID, :STARTDATE, :ENDDATE); end;'
					USING OUT vret, IN pcontractno, IN pfschparamid, IN pstartdate, IN penddate;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage, cfuncname);
			END IF;
		
		END IF;
		s.say(cmethod_name || ': finished, vRet=' || vret, csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setobjecttype IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetObjectType';
	BEGIN
		sobjtype.extract        := object.gettype(extract.object_name);
		sobjtype.event          := object.gettype(event.object_name);
		sobjtype.statementrt    := object.gettype(statementrt.object_name);
		sobjtype.finprofile     := object.gettype(finprofile.sobject_name);
		sobjtype.loyaltyprogram := object.gettype(loyaltyprogram.object_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getobjecttype(pobjectname IN VARCHAR2) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetObjectType';
	BEGIN
		CASE pobjectname
			WHEN extract.object_name THEN
				RETURN sobjtype.extract;
			WHEN event.object_name THEN
				RETURN sobjtype.event;
			WHEN statementrt.object_name THEN
				RETURN sobjtype.statementrt;
			WHEN finprofile.sobject_name THEN
				RETURN sobjtype.finprofile;
			
			WHEN loyaltyprogram.object_name THEN
				RETURN sobjtype.loyaltyprogram;
			
			ELSE
				error.raiseerror('Invalid name of object: ' || pobjectname);
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setentryarray(paentryarray IN tentryarray) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetEntryArray';
	BEGIN
		saentry := paentryarray;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION execgetperiod4vcf
	(
		pcontractno IN tcontract.no%TYPE
	   ,pbegindate  IN DATE := NULL
	) RETURN apitypesforvcf.typeperiodlist IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.ExecGetPeriod4VCF';
		cexecprocname CONSTANT VARCHAR2(100) := 'ExecGetPeriod4VCF';
		vcontracttype  NUMBER;
		vschemapackage tcontractschemas.packagename%TYPE;
	BEGIN
		vcontracttype := contract.gettype(pcontractno);
		IF vcontracttype IS NULL
		THEN
			error.raisewhenerr();
		END IF;
	
		vschemapackage := contracttype.getschemapackage(vcontracttype);
		IF vschemapackage IS NULL
		THEN
			error.raisewhenerr();
		END IF;
	
		savcfperiodlist.delete();
	
		IF contractschemas.existsmethod(vschemapackage, cexecprocname, '/in:V/in:D/ret:A')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || cpackage_name || '.SAVCFPERIODLIST:=' || vschemapackage || '.' ||
							  upper(cexecprocname) || '(:CONTRACTNO, :BEGINDATE); END;'
				USING IN pcontractno, IN pbegindate;
		END IF;
	
		RETURN savcfperiodlist;
	
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE initgetdata4vcf(pcontracttype IN tcontracttype.type%TYPE) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.InitGetData4VCF';
		cexecprocname CONSTANT VARCHAR2(100) := 'InitGetData4VCF';
	BEGIN
		spackage(pcontracttype) := contracttype.getschemapackage(pcontracttype);
		IF spackage(pcontracttype) IS NULL
		THEN
			error.raisewhenerr();
		END IF;
		IF contractschemas.existsmethod(spackage(pcontracttype), cexecprocname, '/in:N/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || spackage(pcontracttype) || '.' || cexecprocname ||
							  '(:TYPE); END;'
				USING IN pcontracttype;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION execgetbalance4vcf
	(
		pcontractno IN tcontract.no%TYPE
	   ,penddate    IN DATE
	) RETURN apitypesforvcf.typebalancelist IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.ExecGetBalance4VCF';
		cexecprocname CONSTANT VARCHAR2(100) := 'ExecGetBalance4VCF';
		vcontracttype NUMBER;
	BEGIN
		vcontracttype := contract.gettype(pcontractno);
		IF vcontracttype IS NULL
		THEN
			error.raisewhenerr();
		END IF;
	
		IF NOT spackage.exists(vcontracttype)
		THEN
			error.raiseerror('Internal error: getting data for VCF without preparation');
		END IF;
	
		savcfbalancelist.delete();
	
		IF contractschemas.existsmethod(spackage(vcontracttype), cexecprocname, '/in:V/in:D/ret:A')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || cpackage_name || '.SAVCFBALANCELIST:=' ||
							  spackage(vcontracttype) || '.' || cexecprocname ||
							  '(:CONTRACTNO, :ENDDATE); END;'
				USING IN pcontractno, IN penddate;
		END IF;
	
		RETURN savcfbalancelist;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE downgetdata4vcf(pcontracttype IN tcontracttype.type%TYPE) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.DownGetData4VCF';
		cexecprocname CONSTANT VARCHAR2(100) := 'DownGetData4VCF';
	BEGIN
		IF contractschemas.existsmethod(spackage(pcontracttype), cexecprocname, '/in:N/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || spackage(pcontracttype) || '.' || cexecprocname ||
							  '(:TYPE); END;'
				USING IN pcontracttype;
		END IF;
		spackage.delete(pcontracttype);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			s.say(cmethod_name || ': general exception ' || SQLCODE || ' ' || SQLERRM, csay_level);
	END;

	FUNCTION getaccounttypeparams
	(
		pcontractno IN tcontract.no%TYPE
	   ,pitemname   IN tcontracttypeitemname.itemname%TYPE
	) RETURN accounttypeparams
	
	 IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetAccountTypeParams';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetAccountTypeParams';
		vcontracttype tcontract.type%TYPE;
		vpackage      VARCHAR2(40);
		vreturn       accounttypeparams;
	BEGIN
		s.say(cmethod_name || ': begin [pContractNo=' || pcontractno || ', pItemName=' ||
			  pitemname || ']'
			 ,csay_level);
	
		vcontracttype := contract.gettype(pcontractno);
		IF vcontracttype IS NULL
		THEN
			s.say(cmethod_name || ': vContractType is null', csay_level);
			error.raisewhenerr();
		END IF;
	
		vpackage := contracttype.getschemapackage(vcontracttype);
		IF vpackage IS NULL
		THEN
			s.say(cmethod_name || ': vPackage is null', csay_level);
			error.raisewhenerr();
		END IF;
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:V/ret:S')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || cpackage_name || '.SACCOUNTTYPEPARAMS :=' || vpackage || '.' ||
							  cfuncname || '(:CONO, :ITEMNAME); END;'
				USING pcontractno, pitemname;
			vreturn := saccounttypeparams;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname);
		END IF;
	
		RETURN vreturn;
	EXCEPTION
	
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION addparameterpage
	(
		pdialog       IN NUMBER
	   ,ppagelist     IN VARCHAR2
	   ,pparamstype   IN NUMBER
	   ,pcontractno   IN tcontract.no%TYPE
	   ,pcontracttype IN tcontracttype.type%TYPE
	) RETURN NUMBER IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.AddParameterPage';
		cexecprocname CONSTANT VARCHAR2(100) := 'FillParameterPage';
		vret          NUMBER := 0;
		vpage         NUMBER;
		vcontracttype tcontracttype.type%TYPE;
		vpackage      tcontractschemas.packagename%TYPE;
	
		PROCEDURE deleteparameterpage(pdialog IN NUMBER) IS
			cmethod_name CONSTANT VARCHAR2(85) := cpackage_name || '.AddParameterPage.DeletePage';
		BEGIN
			IF dialog.idbyname(pdialog, 'PARAMETERPAGEID') > 0
			THEN
				IF nvl(dialog.getnumber(pdialog, 'PARAMETERPAGEID'), 0) > 0
				THEN
					dialog.destroy(dialog.getnumber(pdialog, 'PARAMETERPAGEID'));
				END IF;
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pContractType=' || pcontracttype
			   ,plevel => csay_level);
		IF pcontractno IS NULL
		   AND pcontracttype IS NULL
		THEN
			deleteparameterpage(pdialog);
		ELSE
			IF pcontracttype IS NULL
			THEN
				t.note(cmethod_name, 'point 1', csay_level);
				vcontracttype := contract.gettype(pcontractno);
			ELSE
				t.note(cmethod_name, 'point 2', csay_level);
				vcontracttype := pcontracttype;
			END IF;
		END IF;
	
		IF dialog.idbyname(pdialog, 'PARAMETERPAGEID') > 0
		THEN
			deleteparameterpage(pdialog);
		ELSE
			dialog.hiddennumber(pdialog, 'PARAMETERPAGEID');
		END IF;
		vpackage := contracttype.getschemapackage(vcontracttype);
	
		IF (pcontractno IS NOT NULL OR pcontracttype IS NOT NULL)
		   AND contractschemas.existsmethod(vpackage, cexecprocname, '/in:N/in:N/in:V/in:N/ret:E')
		THEN
			vpage := dialog.page(pdialog, ppagelist, 'Parameters');
			dialog.putnumber(pdialog, 'PARAMETERPAGEID', vpage);
			vret := vpage;
			EXECUTE IMMEDIATE 'begin ' || vpackage || '.' || cexecprocname ||
							  '(:PageId, :ParamType, :ContractNo, :ContractType); end;'
				USING vpage, pparamstype, pcontractno, vcontracttype;
		END IF;
	
		t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION validparameterpage
	(
		pdialog       IN NUMBER
	   ,pparamstype   IN NUMBER
	   ,pcontractno   IN tcontract.no%TYPE
	   ,pcontracttype IN tcontracttype.type%TYPE
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.ValidParameterPage';
		cfuncname    CONSTANT VARCHAR2(100) := 'ValidParameterPage';
		vret          BOOLEAN := TRUE;
		vpage         NUMBER;
		vvalue        NUMBER;
		vcontracttype tcontracttype.type%TYPE;
		vpackage      tcontractschemas.packagename%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pParamsType=' || pparamstype || ', pContractNo=' || pcontractno ||
				', pContractType=' || pcontracttype
			   ,plevel => csay_level);
		IF pcontractno IS NULL
		   AND pcontracttype IS NULL
		THEN
			error.raiseerror('Undefined contract No or contract type ID');
		ELSIF pcontracttype IS NULL
		THEN
			t.note(cmethod_name, 'point 1', csay_level);
			vcontracttype := contract.gettype(pcontractno);
		ELSE
			t.note(cmethod_name, 'point 2', csay_level);
			vcontracttype := pcontracttype;
		END IF;
	
		IF dialog.idbyname(pdialog, 'PARAMETERPAGEID') > 0
		   AND nvl(dialog.getnumber(pdialog, 'PARAMETERPAGEID'), 0) > 0
		THEN
		
			vpage    := dialog.getnumber(pdialog, 'PARAMETERPAGEID');
			vpackage := contracttype.getschemapackage(vcontracttype);
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:N/in:N/in:V/in:N/ret:N')
			THEN
				EXECUTE IMMEDIATE 'begin :Value:=' || vpackage || '.' || cfuncname ||
								  '(:PageId, :ParamType, :ContractNo, :ContractType); end;'
					USING OUT vvalue, IN vpage, IN pparamstype, IN pcontractno, IN vcontracttype;
				vret := nvl(vvalue, 1) = 1;
			END IF;
		
		END IF;
	
		t.leave(cmethod_name, 'vRet=' || t.b2t(vret), plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE saveparameterpage
	(
		pdialog       IN NUMBER
	   ,pparamstype   IN NUMBER
	   ,pcontractno   IN tcontract.no%TYPE
	   ,pcontracttype IN tcontracttype.type%TYPE
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.SaveParameterPage';
		cexecprocname CONSTANT VARCHAR2(100) := 'SaveParameterPage';
		vpage         NUMBER;
		vcontracttype tcontracttype.type%TYPE;
		vpackage      tcontractschemas.packagename%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pParamsType=' || pparamstype || ', pContractNo=' || pcontractno ||
				', pContractType=' || pcontracttype
			   ,plevel => csay_level);
	
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Undefined contract No');
		END IF;
	
		IF pcontracttype IS NULL
		THEN
			t.note(cmethod_name, 'point 1', csay_level);
			vcontracttype := contract.gettype(pcontractno);
		ELSE
			vcontracttype := pcontracttype;
		END IF;
	
		IF dialog.idbyname(pdialog, 'PARAMETERPAGEID') > 0
		   AND nvl(dialog.getnumber(pdialog, 'PARAMETERPAGEID'), 0) > 0
		THEN
		
			vpage    := dialog.getnumber(pdialog, 'PARAMETERPAGEID');
			vpackage := contracttype.getschemapackage(vcontracttype);
		
			IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:N/in:N/in:V/in:N/ret:E')
			THEN
				EXECUTE IMMEDIATE 'begin ' || vpackage || '.' || cexecprocname ||
								  '(:PageId, :ParamType, :ContractNo, :ContractType); end;'
					USING IN vpage, IN pparamstype, IN pcontractno, IN vcontracttype;
			ELSE
				contractschemas.reportunsupportedoperation(vpackage, cexecprocname);
			END IF;
		
		END IF;
		t.leave(cmethod_name, 'vRet=', plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE execservicefeepayment
	(
		pdocno          IN OUT tentry.docno%TYPE
	   ,pentryno        IN OUT tentry.no%TYPE
	   ,pbonusaccountno IN taccount.accountno%TYPE
	   ,paccountno      IN taccount.accountno%TYPE
	   ,pexchrate       IN NUMBER
	   ,pamount         IN OUT NUMBER
	   ,pentrycode      IN treferenceentry.code%TYPE
	) IS
		cmethod_name  CONSTANT VARCHAR2(65) := cpackage_name || '.ExecServiceFeePayment';
		cexecprocname CONSTANT VARCHAR2(100) := 'Ext_PayServiceCommission';
		vcontract tcontract%ROWTYPE;
		vpackage  tcontractschemas.packagename%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pDocNo=' || pdocno || ', pEntryNo=' || pentryno || ', pAccountNo=' || paccountno ||
				', pBonusAccountNo=' || pbonusaccountno || ', pExchRate=' || pexchrate ||
				', pAmount=' || pamount || ', pEntryCode=' || pentrycode
			   ,csay_level);
	
		vcontract.no := contract.getcontractnobyaccno(pbonusaccountno, FALSE);
		t.var(cmethod_name, 'vContract.No=' || vcontract.no, csay_level);
		IF vcontract.no IS NOT NULL
		THEN
		
			vcontract := contract.getcontractrowtype(vcontract.no);
			vpackage  := contracttype.getschemapackage(vcontract.type);
			t.var(cmethod_name, 'vPackage=' || vpackage, csay_level);
		
			IF contractschemas.existsmethod(vpackage
										   ,cexecprocname
										   ,'/inout:N/inout:N/in:V/in:V/in:N/inout:N/in:N/ret:E')
			THEN
				EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
								  '(:pDocNo, :pEntryNo, :pContractNo, :pAccountNo, :pExchRate, :pAmount, :pEntryCode); END;'
					USING IN OUT pdocno, IN OUT pentryno, IN vcontract.no, IN paccountno, IN pexchrate, IN OUT pamount, IN pentrycode;
			END IF;
		
		END IF;
		t.leave(cmethod_name, '', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getinterestbydate
	(
		pcontractno     IN tcontract.no%TYPE
	   ,pkindofaccount  IN NUMBER
	   ,pinterestparams IN typeinterestparams := semptyinterestparams
	) RETURN typeinterestlist IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetInterestByDate';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetInterestByDate';
		vcontract tcontract%ROWTYPE;
		vpackage  tcontractschemas.packagename%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pKindOfAccount=' || pkindofaccount ||
				', pBeginDate=' || pinterestparams.begindate || ', EndDate=' ||
				pinterestparams.enddate || ', Amount=' || pinterestparams.amount
			   ,csay_level);
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Undefined contract No');
		END IF;
		IF pkindofaccount IS NULL
		THEN
			error.raiseerror('Undefined account type');
		ELSIF pkindofaccount NOT IN (cdepositaccount, ccreditaccount)
		THEN
			error.raiseerror('Invalid account type [' || pkindofaccount || ']');
		END IF;
	
		vcontract := contract.getcontractrowtype(pcontractno);
		t.var(cmethod_name, 'vContract.Type=' || vcontract.type, csay_level);
		vpackage := contracttype.getschemapackage(vcontract.type);
		t.var(cmethod_name, 'vPackage=' || vpackage, csay_level);
		sainterestlist.delete();
		sinterestparams := pinterestparams;
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:N/in:S/ret:A')
		THEN
		
			EXECUTE IMMEDIATE 'BEGIN CONTRACTTYPESCHEMA.SAINTERESTLIST:= ' || vpackage || '.' ||
							  cfuncname ||
							  '(:CONTRACTNO, :KINDOFACCOUNT, CONTRACTTYPESCHEMA.SINTERESTPARAMS); END;'
				USING IN pcontractno, IN pkindofaccount;
		
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname);
		END IF;
	
		t.leave(cmethod_name, 'saInterestList.count=' || sainterestlist.count, csay_level);
		RETURN sainterestlist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION autocreate_paramdialog
	(
		pmode         IN PLS_INTEGER
	   ,pmaintype     IN tcontracttype.type%TYPE
	   ,plinkedscheme IN tcontractschemas.packagename%TYPE
	   ,plinkparams   IN OUT typelinkparams
	) RETURN NUMBER
	
	 IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.AutoCreate_ParamDialog';
		cfuncname    CONSTANT VARCHAR2(100) := 'Ext_AutoCreate_ParamDialog';
		vres NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'pMode=' || pmode || ', pMainType=' || pmaintype || ', pLinkedScheme=' ||
				plinkedscheme || ', pLinkParams.T2TLinkList.count=' ||
				plinkparams.t2tlinklist.count
			   ,plevel => csay_level);
		IF pmaintype IS NULL
		THEN
			error.raiseerror('Undefined main contract type');
		END IF;
		IF plinkedscheme IS NULL
		THEN
			error.raiseerror('Undefined scheme of linked contract types');
		END IF;
		plinkparams.linkedscheme := plinkedscheme;
	
		slinkparams := plinkparams;
	
		IF contractschemas.existsmethod(plinkedscheme, cfuncname, '/in:N/in:N/inout:S/ret:N')
		THEN
			EXECUTE IMMEDIATE 'BEGIN :VALUE := ' || plinkedscheme || '.' || cfuncname ||
							  '(:DIALOGMODE, :MAINTYPE, ContractTypeSchema.sLinkParams); END;'
				USING OUT vres, IN pmode, IN pmaintype;
		ELSE
			vres := dialog.cmcancel;
		END IF;
	
		plinkparams := slinkparams;
	
		t.leave(cmethod_name, 'vRes=' || vres, plevel => csay_level);
		RETURN vres;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE autocreate_makelink
	(
		pmaincontract   IN tcontract.no%TYPE
	   ,plinkedcontract IN tcontract.no%TYPE
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.AutoCreate_MakeLink';
		cexecprocname CONSTANT VARCHAR2(100) := 'Ext_AutoCreate_MakeLink';
		vlinkedscheme tcontractschemas.packagename%TYPE;
		vcontract     tcontract%ROWTYPE;
		vt2tlinklist  contractlink.typetype2typelist;
		vfound        BOOLEAN := FALSE;
	BEGIN
		t.enter(cmethod_name
			   ,'pMainContract=[' || pmaincontract || '] pLinkedContract=[' || plinkedcontract || ']'
			   ,csay_level);
	
		IF pmaincontract IS NULL
		   OR NOT contract.contractexists(pmaincontract)
		THEN
			error.raiseerror('Undefined main contract [' || pmaincontract || ']');
		END IF;
		IF plinkedcontract IS NULL
		   OR NOT contract.contractexists(plinkedcontract)
		THEN
			error.raiseerror('Undefined linked contract [' || plinkedcontract || ']');
		END IF;
	
		vcontract := contract.getcontractrowtype(plinkedcontract);
		t.var(cmethod_name, 'vContract.Type=' || vcontract.type, csay_level);
		vlinkedscheme := contracttype.getschemapackage(vcontract.type);
		t.var(cmethod_name, 'vLinkedScheme=' || vlinkedscheme, csay_level);
	
		slinkparams.t2tlinklist.delete();
		vt2tlinklist := contractlink.gettype2typelist(contract.gettype(pmaincontract)
													 ,contractlink.cmain
													 ,NULL
													 ,NULL
													 ,FALSE);
		FOR i IN 1 .. vt2tlinklist.count
		LOOP
			IF vt2tlinklist(i).linktype = vcontract.type
			THEN
				t.var(cmethod_name
					 ,'vT2TLinkList(i).LinkParams=' || vt2tlinklist(i).linkparams
					 ,csay_level);
				t.var(cmethod_name
					 ,'vT2TLinkList(i).LinkName=' || vt2tlinklist(i).linkname
					 ,csay_level);
				t.var(cmethod_name
					 ,'vT2TLinkList(i).LinkCode=' || vt2tlinklist(i).linkcode
					 ,csay_level);
			
				slinkparams.t2tlinklist(slinkparams.t2tlinklist.count + 1) := vt2tlinklist(i);
				vfound := TRUE;
				EXIT;
			END IF;
		END LOOP;
	
		IF NOT vfound
		THEN
			error.raiseerror('Settings of link with contract type [' || vcontract.type ||
							 '] not found');
		END IF;
	
		IF contractschemas.existsmethod(vlinkedscheme, cexecprocname, '/in:V/in:V/in:S/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vlinkedscheme || '.' || cexecprocname ||
							  '(:MAINNO, :LINKEDNO, ContractTypeSchema.sLinkParams); END;'
				USING IN pmaincontract, IN plinkedcontract;
		ELSE
			contractschemas.reportunsupportedoperation(vlinkedscheme, cexecprocname);
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION executeoperation
	(
		pcontractno    IN tcontract.no%TYPE
	   ,poperationcode IN VARCHAR2
	) RETURN typeoperationresult IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.ExecuteOperation';
		cfuncname    CONSTANT VARCHAR2(100) := 'ExecuteOperation';
		vret     typeoperationresult;
		vpackage tcontractschemas.packagename%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pcontractNo=[' || pcontractno || '] pOperationCode=[' || poperationcode || ']'
			   ,csay_level);
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Undefined contract No');
		ELSIF NOT contract.contractexists(pcontractno)
		THEN
			error.raiseerror('Contract with No [' || pcontractno || '] does not exist');
		END IF;
	
		err.seterror(0, cmethod_name);
		vpackage := contracttype.getschemapackage(contract.gettype(pcontractno));
		t.var(cmethod_name, 'vPackage=' || vpackage, csay_level);
		error.raisewhenerr();
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:V/ret:S')
		THEN
			EXECUTE IMMEDIATE 'BEGIN  CONTRACTTYPESCHEMA.SOPERRESULT:= ' || vpackage || '.' ||
							  cfuncname || '(:CONTRACTNO, :CODE);  END;'
				USING IN pcontractno, IN poperationcode;
			vret := soperresult;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname, pdoexception => FALSE);
			vret.resultvalue := contracttypeschema.c_oper_undefined;
		END IF;
	
		IF vret.resultvalue = contracttypeschema.c_oper_undefined
		THEN
			err.seterror(0, cmethod_name);
			t.note(cmethod_name, 'an attempt to run ExecOperation');
			IF execoperation(pcontractno, poperationcode) != 0
			THEN
				error.raisewhenerr();
			ELSE
				err.seterror(0, cmethod_name);
			
			END IF;
		END IF;
	
		t.leave(cmethod_name, 'return ResultValue=' || vret.resultvalue, csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE oncreatecontract
	(
		pcontractrow fintypes.typecontractrow
	   ,pschparams   VARCHAR2
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.OnCreateContract(Row)';
		cexecprocname CONSTANT VARCHAR2(100) := 'OnCreateContract';
		vpackage          tcontractschemas.packagename%TYPE;
		vsavedcontractrow fintypes.typecontractrow;
	BEGIN
		t.enter(cmethod_name);
	
		vsavedcontractrow := scontractrow;
		t.var('SavedContractRow.No', vsavedcontractrow.no);
		scontractrow  := pcontractrow;
		srollbackdata := NULL;
	
		vpackage := contracttype.getschemapackage(pcontractrow.type);
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:S/in:V/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
							  '(:CONTRACTROW, :SCHEMAPARAMS); END;'
				USING IN pcontractrow, IN pschparams;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage
													  ,cexecprocname
													  ,pdoexception => FALSE);
		
			IF execoperation(pcontractrow, 'SET_DEF') <> 0
			THEN
				error.raisewhenerr();
			END IF;
		
		END IF;
		scontractrow := vsavedcontractrow;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			scontractrow := vsavedcontractrow;
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE oncreatecontract
	(
		pcontractno fintypes.typecontractno
	   ,pschparams  VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.OnCreateContract';
	BEGIN
		t.enter(cmethod_name);
		--oncreatecontract(contract.getcontractrowtype(pcontractno), pschparams);
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE onundocreatecontract
	(
		pcontractrow fintypes.typecontractrow
	   ,prbdata      VARCHAR2
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.OnUndoCreateContract(Row)';
		cexecprocname CONSTANT VARCHAR2(100) := 'OnUndoCreateContract';
		vpackage          tcontractschemas.packagename%TYPE;
		vsavedcontractrow fintypes.typecontractrow;
	BEGIN
		t.enter(cmethod_name);
	
		vsavedcontractrow := scontractrow;
		t.var('SavedContractRow.No', vsavedcontractrow.no);
		scontractrow := pcontractrow;
	
		srollbackdata := prbdata;
	
		vpackage := contracttype.getschemapackage(pcontractrow.type);
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:S/in:V/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
							  '(:CONTRACTROW, :RBDATA); END;'
				USING IN pcontractrow, IN prbdata;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage
													  ,cexecprocname
													  ,pdoexception => FALSE);
		
			IF execoperation(pcontractrow, 'UNDO_DEF') <> 0
			THEN
				error.raisewhenerr();
			END IF;
		
		END IF;
		scontractrow := vsavedcontractrow;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			scontractrow := vsavedcontractrow;
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE onundocreatecontract
	(
		pcontractno fintypes.typecontractno
	   ,prbdata     VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.OnUndoCreateContract';
	BEGIN
		t.enter(cmethod_name);
		--onundocreatecontract(contract.getcontractrowtype(pcontractno), prbdata);
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE oncreateaccounts
	(
		pcontractrow fintypes.typecontractrow
	   ,pmode        custom_contract.typeaddaccountmode
	   ,pschparams   VARCHAR2
	   ,poaaccounts  IN OUT contract.typeaccountarray
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.OnCreateAccounts(Row)';
		cexecprocname CONSTANT VARCHAR2(100) := 'OnCreateAccounts';
		vpackage tcontractschemas.packagename%TYPE;
	BEGIN
		t.enter(cmethod_name);
	
		vpackage := contracttype.getschemapackage(pcontractrow.type);
	
		IF contractschemas.existsmethod(vpackage, cexecprocname, '/in:S/in:I/in:V/inout:A/ret:E')
		THEN
			EXECUTE IMMEDIATE 'BEGIN ' || vpackage || '.' || cexecprocname ||
							  '(:CONTRACTROW, :MODE, :SCHEMAPARAMS, :ACCOUNTLIST); END;'
				USING IN pcontractrow, IN pmode, IN pschparams, IN OUT poaaccounts;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage
													  ,cexecprocname
													  ,pdoexception => FALSE);
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE oncreateaccounts
	(
		pcontractno custom_fintypes.typecontractno
	   ,pmode       custom_contract.typeaddaccountmode
	   ,pschparams  VARCHAR2
	   ,poaaccounts IN OUT custom_contract.typeaccountarray
	) IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.OnCreateAccounts';
	BEGIN
		t.enter(cmethod_name);
		/*oncreateaccounts(custom_contract.getcontractrowtype(pcontractno)
        ,pmode
        ,pschparams
        ,poaaccounts);*/
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE oncreateaccount
	(
		pcontractno fintypes.typecontractno
	   ,poaccount   IN OUT custom_contract.typeaccountrow
	) IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.OnCreateAccounts';
		vaaccounts custom_contract.typeaccountarray;
	BEGIN
		t.enter(cmethod_name);
		vaaccounts(1) := poaccount;
		/*      oncreateaccounts(custom_contract.getcontractrowtype(pcontractno)
        ,custom_contract.caamode_addtocontract
        ,custom_contract.semptyparams
        ,vaaccounts);*/
		poaccount := vaaccounts(1);
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcardaccountlist
	(
		pcontractno     IN tcontract.no%TYPE
	   ,praiseexception IN BOOLEAN := TRUE
	) RETURN custom_api_type.typeaccount2cardlist IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetCardAccountList';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetCardAccountList';
		vret     custom_api_type.typeaccount2cardlist;
		vpackage tcontractschemas.packagename%TYPE;
	BEGIN
		t.enter(cmethod_name, 'pcontractNo=[' || pcontractno || ']', csay_level);
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Undefined contract No');
		ELSIF NOT contract.contractexists(pcontractno)
		THEN
			error.raiseerror('Contract with No [' || pcontractno || '] does not exist');
		END IF;
	
		err.seterror(0, cmethod_name);
		vpackage := contracttype.getschemapackage(contract.gettype(pcontractno));
		t.var(cmethod_name, 'vPackage=' || vpackage, csay_level);
		error.raisewhenerr();
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/ret:A')
		THEN
			EXECUTE IMMEDIATE 'BEGIN CONTRACTTYPESCHEMA.SACARDACCOUNTLIST:= ' || vpackage || '.' ||
							  cfuncname || '(:CONTRACTNO);  END;'
				USING IN pcontractno;
			--vret := sacardaccountlist;
		ELSE
			IF nvl(praiseexception, TRUE)
			THEN
				contractschemas.reportunsupportedoperation(vpackage, cfuncname);
			END IF;
		END IF;
	
		t.leave(cmethod_name, 'return vRet.Count=' || vret.count, csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getmainaccountlist(pcontractno IN tcontract.no%TYPE) RETURN contract.typeaccountarray IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetMainAccountList';
		vacc2cardlist apitypes.typeaccount2cardlist;
		vaccountno    taccount.accountno%TYPE;
		vacclist      contract.typeaccountarray;
		vpackage      tcontractschemas.packagename%TYPE;
	BEGIN
		t.enter(cmethod_name, 'pcontractNo=[' || pcontractno || ']', csay_level);
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Undefined contract No');
		ELSIF NOT contract.contractexists(pcontractno)
		THEN
			error.raiseerror('Contract with No [' || pcontractno || '] does not exist');
		END IF;
	
		err.seterror(0, cmethod_name);
		vpackage := contracttype.getschemapackage(contract.gettype(pcontractno));
		t.var(cmethod_name, 'vPackage=' || vpackage, csay_level);
		error.raisewhenerr();
	
		--vacc2cardlist := getcardaccountlist(pcontractno, FALSE);
		t.var('vAcc2CardList.Count', vacc2cardlist.count);
		IF vacc2cardlist.count = 0
		THEN
			err.seterror(0, cmethod_name);
			vaccountno := getmainaccount(pcontractno, NULL);
			t.var('vAccountNo', vaccountno);
			vacc2cardlist(1).accountno := vaccountno;
		END IF;
		FOR i IN 1 .. vacc2cardlist.count
		LOOP
		
			vacclist(i) := contract.loadaccount(vacc2cardlist(i).accountno);
		END LOOP;
	
		t.leave(cmethod_name, 'return vAccList.Count=' || vacclist.count, csay_level);
		RETURN vacclist;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION collectionrulesetupdialog
	(
		pcontracttype IN tcontracttype.type%TYPE
	   ,pregister     IN tcollectioncontracttyperule.register%TYPE
	   ,pruleid       IN tcollectioncontracttyperule.ruleid%TYPE
	   ,oinuse        OUT BOOLEAN
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.CollectionRuleSetupDialog';
		cfuncname    CONSTANT VARCHAR2(100) := 'CollectionRuleSetupDialog';
		vpackage tcontractschemas.packagename%TYPE;
		vret     NUMBER;
		vinuse   NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractType=' || pcontracttype || ', pRegister=' || pregister || ', pRuleId=' ||
				pruleid
			   ,plevel => csay_level);
	
		contracttype.checkcontracttype(pcontracttype);
		vpackage := contracttype.getschemapackage(pcontracttype, TRUE);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:N/in:V/in:N/out:N/ret:N')
		THEN
			EXECUTE IMMEDIATE 'BEGIN :RET:= ' || vpackage || '.' || cfuncname ||
							  '(:CONTRACTTYPE,:REGISTER,:RULEID, :INUSE);  END;'
				USING OUT vret, IN pcontracttype, IN pregister, IN pruleid, OUT vinuse;
		
			oinuse := nvl(vinuse, 0) = 1;
			t.var('oInUse', t.b2t(oinuse));
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname);
		END IF;
	
		t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION collectioncheckrule
	(
		pcontractno IN tcontract.no%TYPE
	   ,pregister   IN tcollectioncontracttyperule.register%TYPE
	   ,pruleid     IN tcollectioncontracttyperule.ruleid%TYPE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.CollectionCheckRule';
		cfuncname    CONSTANT VARCHAR2(100) := 'CollectionCheckRule';
		vpackage tcontractschemas.packagename%TYPE;
		vret     NUMBER;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pRegister=' || pregister || ', pRuleId=' ||
				pruleid
			   ,plevel => csay_level);
	
		contract.checkcontractno(pcontractno);
		vpackage := contracttype.getschemapackage(contract.gettype(pcontractno), TRUE);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:V/in:N/ret:N')
		THEN
			EXECUTE IMMEDIATE 'BEGIN :RET:= ' || vpackage || '.' || cfuncname ||
							  '(:CONTRACTNO, :REGISTER, :RULEID);  END;'
				USING OUT vret, IN pcontractno, IN pregister, IN pruleid;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname);
		END IF;
	
		t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION collectiongetcontractamount
	(
		pcontractno IN tcontract.no%TYPE
	   ,pregister   IN tcollectioncontracttyperule.register%TYPE
	   ,pregisterid IN tcollectioncontractrules.registerid%TYPE
	   ,pamountcode IN NUMBER
	   ,
		
		oamount OUT typecollectionamount
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.CollectionGetContractAmount';
		cfuncname    CONSTANT VARCHAR2(100) := 'CollectionGetContractAmount';
		vpackage tcontractschemas.packagename%TYPE;
		vret     NUMBER := contractcollection.camtresok;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pRegister=' || pregister || ', pRegisterId=' ||
				pregisterid || ', pAmountCode=' || pamountcode
			   ,plevel => csay_level);
	
		BEGIN
			contract.checkcontractno(pcontractno);
		EXCEPTION
			WHEN OTHERS THEN
				t.note(cmethod_name, 'CheckContractNo failed: ' || SQLERRM, csay_level);
				vret := contractcollection.camtrescontractnotfound;
		END;
	
		IF vret = contractcollection.camtresok
		THEN
		
			vpackage := contracttype.getschemapackage(contract.gettype(pcontractno), TRUE);
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:V/in:V/in:N/out:S/ret:N')
			THEN
				EXECUTE IMMEDIATE 'BEGIN :RET:= ' || vpackage || '.' || cfuncname ||
								  '(:CONTRACTNO,:REGISTER, :REGISTERID, :AMOUNTCODE, CONTRACTTYPESCHEMA.SCOLLECTIONAMOUNT);  END;'
					USING OUT vret, IN pcontractno, IN pregister, IN pregisterid, IN pamountcode;
			
				t.var('vRet[1]', vret);
				oamount := scollectionamount;
				t.var('oAmount.Amount', oamount.amount);
				t.var('oAmount.Currency', oamount.currency);
			ELSE
				vret := contractcollection.camtresmethodnotfound;
			END IF;
		
		END IF;
		t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION saycollectperformedaction(pperformedaction IN typecollectionperformedaction)
		RETURN VARCHAR2 IS
	BEGIN
		RETURN 'ActionCode=' || pperformedaction.actioncode || ', Description=' || pperformedaction.description || ', RegisterArray.count=' || pperformedaction.registerarray.count;
	END;

	FUNCTION saycollectactionresult(pperformedaction IN typecollectionactionresult) RETURN VARCHAR2 IS
	BEGIN
		RETURN 'Message=' || pperformedaction.message || ', RollBackData=[]';
	END;

	FUNCTION collectionperformaction
	(
		pcontractno      IN tcontract.no%TYPE
	   ,pperformedaction IN typecollectionperformedaction
	   ,oactionresult    OUT typecollectionactionresult
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.CollectionPerformAction';
		cfuncname    CONSTANT VARCHAR2(100) := 'CollectionPerformAction';
	
		vpackage tcontractschemas.packagename%TYPE;
		vret     NUMBER := contractcollection.cactionresok;
	
		vpackno NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || saycollectperformedaction(pperformedaction)
			   ,plevel => csay_level);
	
		BEGIN
			contract.checkcontractno(pcontractno);
		EXCEPTION
			WHEN OTHERS THEN
				t.note(cmethod_name, 'CheckContractNo failed: ' || SQLERRM, csay_level);
				vret := contractcollection.cactionrescontractnotfound;
		END;
	
		IF vret = contractcollection.cactionresok
		THEN
		
			vpackage                := contracttype.getschemapackage(contract.gettype(pcontractno)
																	,TRUE);
			scollectperformedaction := pperformedaction;
		
			vpackno := contractrb.init();
			t.var('vPackNo', vpackno);
		
			IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:S/out:S/ret:N')
			THEN
				EXECUTE IMMEDIATE 'BEGIN :RET:= ' || vpackage || '.' || cfuncname ||
								  '(:CONTRACTNO,ContractTypeSchema.sCollectPerformedAction,ContractTypeSchema.sCollectActionResult);  END;'
					USING OUT vret, IN pcontractno;
			
				scollectactionresult.rollbackdata := contractrb.done(vpackno);
				t.var('vRet[1]', vret);
				t.note(saycollectactionresult(scollectactionresult));
				oactionresult := scollectactionresult;
			ELSE
				contractrb.clearlaststate();
				vret := contractcollection.cactionresmethodnotfound;
			END IF;
		
		END IF;
		t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getrepaymentamount
	(
		pcontractno IN tcontract.no%TYPE
	   ,pstartdate  IN DATE
	   ,penddate    IN DATE
	) RETURN typecollectionamount IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetRepaymentAmount';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetRepaymentAmount';
		vpackage tcontractschemas.packagename%TYPE;
		vret     typecollectionamount;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pStartDate=' || pstartdate || ', pEndDate=' ||
				penddate
			   ,plevel => csay_level);
	
		contract.checkcontractno(pcontractno);
	
		vpackage := contracttype.getschemapackage(contract.gettype(pcontractno), TRUE);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:D/in:D/ret:S')
		THEN
			EXECUTE IMMEDIATE 'BEGIN CONTRACTTYPESCHEMA.SCOLLECTIONAMOUNT:= ' || vpackage || '.' ||
							  cfuncname || '(:CONTRACTNO,:STARTDATE,:ENDDATE); END;'
				USING IN pcontractno, IN pstartdate, IN penddate;
		
			vret := scollectionamount;
			t.var('sCollectionAmount.Amount', scollectionamount.amount);
			t.var('sCollectionAmount.Currency', scollectionamount.currency);
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname);
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
		RETURN vret;
	
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getruleblock
	(
		pschemepackage IN tcontractschemas.packagename%TYPE
	   ,pruleid        IN tcollectioncontracttyperule.ruleid%TYPE
	) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetRuleBlock';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetRuleBlock';
		vret        VARCHAR2(3000);
		vrulerecord tcollectionrefuserrule%ROWTYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pSchemePackage=' || pschemepackage || ', pRuleId=' || pruleid
			   ,plevel => csay_level);
	
		IF NOT contractschemas.existsscheme(pschemepackage)
		THEN
			error.raiseerror('Financial scheme [' || pschemepackage || '] not found');
		END IF;
	
		vrulerecord := refcollectionrules.getrulerecord(pruleid);
		IF vrulerecord.id IS NOT NULL
		THEN
		
			IF contractschemas.existsmethod(pschemepackage, cfuncname, '/in:N/ret:V')
			THEN
				EXECUTE IMMEDIATE 'BEGIN :RET:= ' || pschemepackage || '.' || cfuncname ||
								  '(:RULEID); END;'
					USING OUT vret, IN pruleid;
			ELSE
				contractschemas.reportunsupportedoperation(pschemepackage, cfuncname);
			END IF;
		
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION collectionrollbackaction
	(
		pcontractno   IN tcontract.no%TYPE
	   ,pactioncode   IN VARCHAR2
	   ,prollbackdata IN VARCHAR2
	   ,oactionresult OUT typecollectionactionresult
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CollectionRollbackAction';
		vret NUMBER := contractcollection.cactionresok;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pActionCode=' || pactioncode ||
				', pRollBackData=' || prollbackdata
			   ,plevel => csay_level);
	
		IF pactioncode != contractcollection.cchargefee
		THEN
		
			vret := contractcollection.cactionresnotsupported;
			t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
			RETURN vret;
		END IF;
	
		BEGIN
			contract.checkcontractno(pcontractno);
		EXCEPTION
			WHEN OTHERS THEN
				t.note(cmethod_name, 'CheckContractNo failed: ' || SQLERRM, csay_level);
				vret := contractcollection.cactionrescontractnotfound;
		END;
	
		IF vret = contractcollection.cactionresok
		THEN
		
			oactionresult.rollbackdata := contractrb.undo(pcontractno, prollbackdata);
			t.var('oActionResult.RollbackData', oactionresult.rollbackdata);
		
		END IF;
		t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcyclecalendar
	(
		pcontractno IN tcontract.no%TYPE
	   ,pstartdate  IN DATE
	   ,pendcycle   IN NUMBER
	) RETURN typecollectiondatelist IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetCycleCalendar';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetCycleCalendar';
		vpackage tcontractschemas.packagename%TYPE;
		vret     typecollectiondatelist;
	
		FUNCTION getcollectiondatelist
		(
			pstartdate IN DATE
		   ,pendcycle  IN NUMBER
		) RETURN typecollectiondatelist IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCollectionDateList';
			vret         typecollectiondatelist;
			vlastday     DATE;
			vlastlastday DATE;
		BEGIN
			t.enter(cmethod_name
				   ,'pStartDate=' || pstartdate || ', pEndCycle=' || pendcycle
				   ,csay_level);
			vlastday := last_day(pstartdate);
			t.var('vLastDay=' || vlastlastday);
			vlastlastday := add_months(vlastday, pendcycle);
			t.var('vLastLastDay=' || vlastlastday);
			WHILE vlastday <= vlastlastday
			LOOP
				vret(vret.count + 1) := vlastday;
				vlastday := add_months(vlastday, 1);
			END LOOP;
			t.leave(cmethod_name, 'vRet.count=' || vret.count, plevel => csay_level);
			RETURN vret;
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethod_name, plevel => csay_level);
				error.save(cmethod_name);
				RAISE;
		END;
	
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pStartDate=' || pstartdate || ', pEndCycle=' ||
				pendcycle
			   ,plevel => csay_level);
	
		contract.checkcontractno(pcontractno);
	
		IF pstartdate IS NULL
		THEN
			error.raiseerror('Cycle start date not specified');
		END IF;
	
		IF pendcycle IS NULL
		THEN
			error.raiseerror('Number of cycles not defined');
		END IF;
	
		vpackage := contracttype.getschemapackage(contract.gettype(pcontractno), TRUE);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:D/in:N/ret:A')
		THEN
			EXECUTE IMMEDIATE 'BEGIN CONTRACTTYPESCHEMA.SACOLLECTIONDATELIST:= ' || vpackage || '.' ||
							  cfuncname || '(:CONTRACTNO,:STARTDATE,:ENDCYCLE); END;'
				USING IN pcontractno, IN pstartdate, IN pendcycle;
			vret := sacollectiondatelist;
			t.var('[1] vRet.count', vret.count);
		ELSE
			vret := getcollectiondatelist(pstartdate, pendcycle);
			t.var('[2] vRet.count', vret.count);
		END IF;
	
		t.leave(cmethod_name, 'vRet.count=' || vret.count, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getcontractstructure(pcontractno IN tcontract.no%TYPE) RETURN typecontractcollectionstruct IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetContractStructure';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetContractStructure';
		vpackage tcontractschemas.packagename%TYPE;
		vret     typecontractcollectionstruct;
	
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno, plevel => csay_level);
	
		contract.checkcontractno(pcontractno);
	
		vpackage := contracttype.getschemapackage(contract.gettype(pcontractno), TRUE);
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/ret:S')
		THEN
		
			EXECUTE IMMEDIATE 'BEGIN CONTRACTTYPESCHEMA.SCONTRACTCOLLECTIONSTRUCT:= ' || vpackage || '.' ||
							  cfuncname || '(:CONTRACTNO); END;'
				USING IN pcontractno;
		
			vret := scontractcollectionstruct;
			t.var('[1] vRet.RegisterList.count', vret.registerlist.count);
		END IF;
	
		t.leave(cmethod_name
			   ,'vRet.MainContractNo=' || vret.maincontractno || ', vRet.RegisterList.count=' ||
				vret.registerlist.count
			   ,plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getdebtreservinglist RETURN types.arrstr40 IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetContractStructure';
		vret types.arrstr40;
	
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
	
		IF contractschemas.existsmethod('Reserve', 'GetDebtReservingTypeName', '/ret:A')
		THEN
		
			EXECUTE IMMEDIATE 'BEGIN CONTRACTTYPESCHEMA.SADEBTRESERVINGLIST:=' ||
							  upper('Reserve.GetDebtReservingTypeName') || '; END;';
		
			vret := sadebtreservinglist;
			t.var('[1] vRet.count=', vret.count);
		END IF;
	
		t.leave(cmethod_name, 'vRet.Count=' || vret.count, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE getremarktaglist
	(
		pschemepackage IN VARCHAR2
	   ,pcontext       IN PLS_INTEGER
	   ,ptaglist       IN OUT typeremarktaglist
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.GetRemarkTagList';
		cexecprocname CONSTANT VARCHAR2(100) := 'GetRemarkTagList';
		vret typeremarktaglist;
	
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pSchemePackage', pschemepackage);
	
		t.inpar('pContext', pcontext);
		t.inpar('pTagList.count', ptaglist.count);
	
		IF pcontext IS NULL
		   OR pcontext NOT IN
		   (contractentryremark.ccontext_entryremark, contractentryremark.ccontext_accountname)
		THEN
			error.raiseerror('Invalid value of parameter [pContext=' || pcontext || ']');
		END IF;
	
		vret := ptaglist;
	
		IF contractschemas.existsmethod(pschemepackage, cexecprocname, '/in:N/inout:A/ret:E')
		THEN
			saremarktaglist := vret;
			EXECUTE IMMEDIATE 'BEGIN ' || pschemepackage || '.' || cexecprocname ||
							  '(:CONTEXT, CONTRACTTYPESCHEMA.SAREMARKTAGLIST); END;'
				USING IN pcontext;
			t.var('saRemarkTagList.count=', saremarktaglist.count);
			IF saremarktaglist.count > 0
			THEN
				vret := saremarktaglist;
			END IF;
		
			t.var('[1] vRet.count', vret.count);
		END IF;
	
		ptaglist := vret;
		t.leave(cmethod_name, 'vRet.Count=' || vret.count, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE getremarkvalues
	(
		pschemepackage IN VARCHAR2
	   ,ptaglist       IN OUT typeremarktaglist
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.GetRemarkValues';
		cexecprocname CONSTANT VARCHAR2(100) := 'GetRemarkValues';
		vret typeremarktaglist;
	
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pSchemePackage', pschemepackage);
		t.inpar('pTagList.count', ptaglist.count);
	
		vret := ptaglist;
	
		IF contractschemas.existsmethod(pschemepackage, 'GetRemarkValues', '/inout:A/ret:E')
		THEN
			saremarktaglist := vret;
			EXECUTE IMMEDIATE 'BEGIN ' || upper(pschemepackage) || '.' || cexecprocname ||
							  '(CONTRACTTYPESCHEMA.SAREMARKTAGLIST); END;';
		
			t.var('saRemarkTagList.count=', saremarktaglist.count);
			vret := saremarktaglist;
		
			t.var('[2] vRet.count', vret.count);
		END IF;
	
		ptaglist := vret;
		t.leave(cmethod_name, 'vRet.Count=' || vret.count, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE applylinkaction
	(
		pschemepackage IN VARCHAR2
	   ,panylink       IN typeanylink
	   ,paction        IN NUMBER
	) IS
		cmethod_name  CONSTANT VARCHAR2(100) := cpackage_name || '.ApplyLinkAction';
		cexecprocname CONSTANT VARCHAR2(100) := 'ApplyLinkAction';
	
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pSchemePackage', pschemepackage);
		t.inpar('pAction', paction);
		t.inpar('pAnyLink.LinkType', panylink.linktype);
		t.inpar('pAnyLink.KindOfType', panylink.kindoftype);
		t.inpar('pAnyLink.LinkRelation', panylink.linkrelation);
		t.inpar('pAnyLink.Link_Contr2Contr.MainNo', panylink.link_contr2contr.mainno);
		t.inpar('pAnyLink.Link_Contr2Contr.LinkNo', panylink.link_contr2contr.linkno);
	
		IF contractschemas.existsmethod(pschemepackage, cexecprocname, '/in:S/in:N/ret:E')
		THEN
			sanylink := panylink;
			EXECUTE IMMEDIATE 'BEGIN ' || upper(pschemepackage) || '.' || cexecprocname ||
							  '(CONTRACTTYPESCHEMA.SANYLINK, :ACTION); END;'
				USING IN paction;
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION remarktaglistitem
	(
		ptag          typetag
	   ,ptagtype      NUMBER := NULL
	   ,ptagdatatype  NUMBER := NULL
	   ,pdescription  VARCHAR2 := NULL
	   ,pactive       BOOLEAN := TRUE
	   ,ptagnumvalue  NUMBER := NULL
	   ,ptagdatevalue DATE := NULL
	   ,ptagvalue     VARCHAR2 := NULL
	) RETURN typeremarktag IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.RemarkTagListItem';
		vret typeremarktag;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		vret.tag     := ptag;
		vret.tagtype := ptagtype;
		IF vret.tagtype IS NULL
		   OR
		   vret.tagtype NOT IN
		   (contracttypeschema.ctagtype_bindvariable, contracttypeschema.ctagtype_stringvariable)
		THEN
			IF substr(ptag, 1, 1) = ':'
			THEN
				vret.tagtype := contracttypeschema.ctagtype_bindvariable;
			ELSE
				vret.tagtype := contracttypeschema.ctagtype_stringvariable;
			END IF;
		END IF;
		vret.tagdatatype  := nvl(ptagdatatype, contractsql.ctype_funcchar);
		vret.description  := pdescription;
		vret.active       := nvl(pactive, TRUE);
		vret.tagnumvalue  := ptagnumvalue;
		vret.tagdatevalue := ptagdatevalue;
		vret.tagvalue     := ptagvalue;
	
		t.leave(cmethod_name, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getoverdueremainlist
	(
		pcontractno IN tcontract.no%TYPE
	   ,pondate     IN DATE
	   ,ponlyfixed  IN BOOLEAN := FALSE
	) RETURN typeoverduelist IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetOverdueRemainList';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetOverdueRemainList';
		vret       typeoverduelist;
		vpackage   tcontractschemas.packagename%TYPE;
		vtype      tcontract.type%TYPE;
		vonlyfixed NUMBER := 0;
	BEGIN
		t.enter(cmethod_name
			   ,'pcontractNo=[' || pcontractno || '] pOnDate=[' || pondate || '] pOnlyFixed=[' ||
				t.b2t(ponlyfixed) || ']'
			   ,csay_level);
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Undefined contract No');
		ELSIF NOT contract.contractexists(pcontractno)
		THEN
			error.raiseerror('Contract with No [' || pcontractno || '] does not exist');
		END IF;
	
		vtype := contract.gettype(pcontractno);
		err.seterror(0, cmethod_name);
		vpackage := contracttype.getschemapackage(vtype);
		t.var(cmethod_name, 'vPackage=' || vpackage, csay_level);
		error.raisewhenerr();
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:N/in:D/in:N/ret:A')
		THEN
			IF nvl(ponlyfixed, FALSE)
			THEN
				vonlyfixed := 1;
			END IF;
			EXECUTE IMMEDIATE 'BEGIN  CONTRACTTYPESCHEMA.saOverdueList:= ' || vpackage || '.' ||
							  cfuncname ||
							  '(:CONTRACTNO, :CONTRACTTYPE, :ONDATE, :ONLYFIXED);  END;'
				USING IN pcontractno, IN vtype, IN pondate, IN vonlyfixed;
			vret := saoverduelist;
		ELSE
			contractschemas.reportunsupportedoperation(vpackage, cfuncname);
		END IF;
	
		t.leave(cmethod_name, 'vRet.count=' || vret.count, csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getprolongationparamnamelist(pcontractno IN tcontract.no%TYPE) RETURN typekeyvaluelist IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.GetProlongationParamNameList';
		cfuncname    CONSTANT VARCHAR2(100) := 'GetProlongationParamNameList';
		vret     typekeyvaluelist;
		vpackage tcontractschemas.packagename%TYPE;
		vtype    tcontract.type%TYPE;
	BEGIN
		t.enter(cmethod_name, 'pcontractNo=[' || pcontractno || ']', csay_level);
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Undefined contract No');
		ELSIF NOT contract.contractexists(pcontractno)
		THEN
			error.raiseerror('Contract with No [' || pcontractno || '] does not exist');
		END IF;
	
		vtype := contract.gettype(pcontractno);
		err.seterror(0, cmethod_name);
		vpackage := contracttype.getschemapackage(vtype);
		t.var(cmethod_name, 'vPackage=' || vpackage, csay_level);
		error.raisewhenerr();
	
		IF contractschemas.existsmethod(vpackage, cfuncname, '/in:V/in:N/ret:A')
		THEN
			EXECUTE IMMEDIATE 'BEGIN  CONTRACTTYPESCHEMA.saProlongationParamNameList:= ' ||
							  vpackage || '.' || cfuncname || '(:CONTRACTNO, :CONTRACTTYPE);  END;'
				USING IN pcontractno, IN vtype;
			vret := saprolongationparamnamelist;
		END IF;
	
		t.leave(cmethod_name, 'vRet.count=' || vret.count, csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getclientmenuitems(pclientparams IN typeclientparams := semptyclientparams)
		RETURN typeclientmenuitemlist IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetClientMenuItems';
		vrec typeclientmenuitem;
		vret typeclientmenuitemlist;
	BEGIN
		t.enter(cmethod_name
			   ,'pClientParams.IdClient=[' || pclientparams.idclient ||
				'], pClientparams.MenuItem=[' || pclientparams.menuitem || ']'
			   ,csay_level);
		vrec.menuitem := cclientmenu_bustcriteria;
		vrec.caption := 'Indicator of default';
		vrec.hint := 'View indicator of default for this customer';
		vret(1) := vrec;
		t.leave(cmethod_name, 'vRet.count=' || vret.count, csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE execclientmenuitem(pclientparams IN typeclientparams) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ExecClientMenuItem';
	
		vret typeclientmenuitemlist;
	BEGIN
		t.enter(cmethod_name
			   ,'pClientParams.IdClient=[' || pclientparams.idclient ||
				'], pClientparams.MenuItem=[' || pclientparams.menuitem || ']'
			   ,csay_level);
		CASE pclientparams.menuitem
			WHEN cclientmenu_bustcriteria THEN
				t.note(cmethod_name, 'Exec ContractBust.RunBustCriteria()');
				IF contractbust.runbustcriteria(contractbust.cobjecttype_client
											   ,pclientparams.idclient
											   ,NULL
											   ,pclientparams.readonly) = 1
				THEN
					NULL;
				END IF;
			ELSE
				error.raiseerror('Not supported to invoke menu item [' || pclientparams.menuitem || '] ');
		END CASE;
		t.leave(cmethod_name, 'vRet.count=' || vret.count, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION readpackageinfo
	(
		ppackagename IN custom_fintypes.typepackagename
	   ,opackageinfo OUT custom_fintypes.typepackageinfo
	) RETURN BOOLEAN IS
		cmethodname    CONSTANT typemethodname := cpackage_name || '.ReadPackageInfo';
		cextmethodname CONSTANT typemethodname := 'GetPackageInfo';
		vresult BOOLEAN := FALSE;
	BEGIN
		t.enter(cmethodname, ppackagename);
	
		IF contractschemas.existsmethod(ppackagename, cextmethodname, '/ret:S')
		THEN
			EXECUTE IMMEDIATE 'begin :Result:= ' || ppackagename || '.' || cextmethodname ||
							  '; end;'
				USING OUT opackageinfo;
			vresult := TRUE;
		END IF;
	
		t.leave(cmethodname, htools.b2s(vresult));
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END readpackageinfo;

	FUNCTION getpackageinfo
	(
		ppackagename IN fintypes.typepackagename
	   ,pdoexception BOOLEAN := TRUE
	) RETURN custom_fintypes.typepackageinfo IS
		cmethodname    CONSTANT typemethodname := cpackage_name || '.GetPackageInfo';
		cextmethodname CONSTANT typemethodname := 'GetPackageInfo';
		vpackageinfo custom_fintypes.typepackageinfo;
	BEGIN
		t.enter(cmethodname, ppackagename);
	
		IF contractschemas.existsmethod(ppackagename, cextmethodname, '/ret:S')
		THEN
			EXECUTE IMMEDIATE 'begin :Result:= ' || ppackagename || '.' || cextmethodname ||
							  '; end;'
				USING OUT vpackageinfo;
		END IF;
	
		t.leave(cmethodname);
		RETURN vpackageinfo;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			IF pdoexception
			THEN
				error.save(cmethodname);
				RAISE;
			ELSE
				s.err(cmethodname);
				RETURN NULL;
			END IF;
	END getpackageinfo;

	PROCEDURE addpackageaboutinfo
	(
		poaaboutinfo  IN OUT NOCOPY types.arrstr100
	   ,ppackagename  IN fintypes.typepackagename
	   ,paddemptyline BOOLEAN := TRUE
	   ,plevel        PLS_INTEGER := 2
	) IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.AddPackageAboutInfo';
	
		vpackageinfo custom_fintypes.typepackageinfo;
	
		vainfolist  types.arrstr100;
		vwhitespace VARCHAR2(100);
	BEGIN
		t.enter(cmethodname, ppackagename);
	
		vwhitespace := lpad(' ', (plevel - 1) * 2);
	
		IF readpackageinfo(ppackagename, vpackageinfo)
		THEN
			poaaboutinfo(poaaboutinfo.count + 1) := vwhitespace ||
													custom_contracttools.getpackageinfo_maindescription(vpackageinfo);
			poaaboutinfo(poaaboutinfo.count + 1) := vwhitespace ||
													custom_contracttools.getpackageinfo_headerdescription(vpackageinfo);
			poaaboutinfo(poaaboutinfo.count + 1) := vwhitespace ||
													custom_contracttools.getpackageinfo_bodydescription(vpackageinfo);
		ELSE
		
			poaaboutinfo(poaaboutinfo.count + 1) := vwhitespace || 'Batch ' || ppackagename;
			poaaboutinfo(poaaboutinfo.count + 1) := vwhitespace || '  Error getting batch data!';
		
		END IF;
	
		IF paddemptyline
		THEN
			poaaboutinfo(poaaboutinfo.count + 1) := '';
		END IF;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END addpackageaboutinfo;

	FUNCTION getschemaabout(ppackagename IN fintypes.typepackagename) RETURN types.arrstr100 IS
		cmethodname    CONSTANT typemethodname := cpackage_name || '.GetSchemaAbout';
		cextmethodname CONSTANT typemethodname := 'GetSchemaAbout';
		varesult types.arrstr100;
	BEGIN
		t.enter(cmethodname, ppackagename);
	
		IF contractschemas.existsmethod(ppackagename, cextmethodname, '/ret:A')
		THEN
			EXECUTE IMMEDIATE 'begin :Result:= ' || ppackagename || '.' || cextmethodname ||
							  '; end;'
				USING OUT varesult;
		END IF;
	
		t.leave(cmethodname, varesult.count);
		RETURN varesult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getschemaabout;

BEGIN
	custom_contracttools.saypackageinfo(getpackageinfo);
	sentryprops := NULL;
	setobjecttype();
	saoperation(operacc_in).name := 'Non-cash credit';
	saoperation(operacc_out).name := 'Non-cash debit';
	saoperation(operbalance).name := 'Balance';
	saoperation(operpayoff).name := 'Payment';
END;
/
