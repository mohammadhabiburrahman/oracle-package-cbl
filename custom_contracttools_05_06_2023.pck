CREATE OR REPLACE PACKAGE custom_contracttools AS
	cpackagedescr CONSTANT VARCHAR2(100) := ' Package of tools for financial schemes';

	cheaderversion CONSTANT VARCHAR2(50) := '22.00.00';

	cheaderdate CONSTANT DATE := to_date('17.10.2022', 'DD.MM.YYYY');

	cheadertwcms CONSTANT VARCHAR2(50) := '4.15.87';

	cheaderrevision CONSTANT VARCHAR2(100) := '$Rev: 61984 $';

	cchar_donotcheck CONSTANT PLS_INTEGER := 0;

	cnum_donotcheck  CONSTANT PLS_INTEGER := 0;
	cnum_negative    CONSTANT PLS_INTEGER := 1;
	cnum_nonpositive CONSTANT PLS_INTEGER := 2;
	cnum_zero        CONSTANT PLS_INTEGER := 3;
	cnum_nonzero     CONSTANT PLS_INTEGER := 4;
	cnum_nonnegative CONSTANT PLS_INTEGER := 5;
	cnum_positive    CONSTANT PLS_INTEGER := 6;

	cdate_donotcheck CONSTANT PLS_INTEGER := 0;
	cdate_nodayoff   CONSTANT PLS_INTEGER := 1;
	cdate_dayoffnow  CONSTANT PLS_INTEGER := 2;

	cacc_donotcheck CONSTANT PLS_INTEGER := 0;

	SUBTYPE typeaccountno IS taccount.accountno%TYPE;
	SUBTYPE typepan IS tcard.pan%TYPE;
	SUBTYPE typembr IS tcard.mbr%TYPE;

	TYPE typenumber IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	TYPE typedate IS TABLE OF DATE INDEX BY BINARY_INTEGER;
	TYPE typevarchar40 IS TABLE OF VARCHAR(40) INDEX BY BINARY_INTEGER;
	TYPE typevarchar50 IS TABLE OF VARCHAR(100) INDEX BY BINARY_INTEGER;
	TYPE typevarchar200 IS TABLE OF VARCHAR(200) INDEX BY BINARY_INTEGER;
	TYPE tarrcharbychar IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(100);
	TYPE tarrnumbychar IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
	TYPE typeaccountnoarray IS TABLE OF taccount.accountno%TYPE INDEX BY BINARY_INTEGER;
	TYPE typestrbystr IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(100);

	TYPE taccountrecord IS RECORD(
		 accountno     VARCHAR(20)
		,itemcode      NUMBER
		,accounttype   NUMBER
		,idclient      NUMBER
		,remain        NUMBER
		,available     NUMBER
		,acct_stat     CHAR(1)
		,currencyno    NUMBER
		,overdraft     NUMBER
		,lowremain     NUMBER
		,debitreserve  NUMBER
		,creditreserve NUMBER
		,stat          VARCHAR(10)
		,createdate    DATE
		,closedate     DATE
		,updatesysdate DATE);

	TYPE typeaccarray IS TABLE OF taccountrecord INDEX BY BINARY_INTEGER;

	TYPE typeprchistintrec IS RECORD(
		 pdate     DATE
		,pinterval NUMBER
		,ppercent  NUMBER);
	TYPE typeprchistintarray IS TABLE OF typeprchistintrec INDEX BY BINARY_INTEGER;

	TYPE typeprcrec IS RECORD(
		 pdate     DATE
		,pdays     NUMBER
		,ppercent  NUMBER
		,premain   NUMBER
		,pprcdate  DATE
		,pratebase PLS_INTEGER);
	TYPE typeprcarray IS TABLE OF typeprcrec INDEX BY BINARY_INTEGER;

	TYPE typeprcintrec IS RECORD(
		 pinterval NUMBER
		,ppercent  NUMBER);
	TYPE typeprcintarray IS TABLE OF typeprcintrec INDEX BY BINARY_INTEGER;

	TYPE typetrancherec IS RECORD(
		 ptranchedate   DATE
		,pperioddate    DATE
		,pperiodenddate DATE
		,pdays          NUMBER
		,ppercent       NUMBER
		,premain        NUMBER
		,pprcdate       DATE);
	TYPE typetranchearray IS TABLE OF typetrancherec INDEX BY BINARY_INTEGER;

	TYPE typesnapshotrec IS RECORD(
		 ident VARCHAR(40)
		,VALUE VARCHAR(200));
	TYPE typesnapshotarray IS TABLE OF typesnapshotrec INDEX BY BINARY_INTEGER;

	TYPE typeacctypeperiodarray IS TABLE OF tcontractacctypeperiod%ROWTYPE INDEX BY BINARY_INTEGER;

	TYPE typesshottrancherec IS RECORD(
		 ident   tcontractsshottranche.ident%TYPE
		,opdate  tcontractsshottranche.opdate%TYPE
		,VALUE   tcontractsshottranche.value%TYPE
		,entcode tcontractsshottranche.entcode%TYPE);
	TYPE typesshottranchearray IS TABLE OF typesshottrancherec INDEX BY BINARY_INTEGER;

	TYPE trate IS TABLE OF referenceprchistory.typeprcarray INDEX BY PLS_INTEGER;

	cenddate   CONSTANT PLS_INTEGER := 0;
	cbegindate CONSTANT PLS_INTEGER := 1;

	cexclude CONSTANT PLS_INTEGER := 0;
	cinclude CONSTANT PLS_INTEGER := 1;

	conlynegative CONSTANT PLS_INTEGER := -1;
	casis         CONSTANT PLS_INTEGER := 0;
	conlypositive CONSTANT PLS_INTEGER := 1;

	cemptyprcarray referenceprchistory.typeprcarray;

	TYPE tamount IS RECORD(
		 VALUE        NUMBER
		,currencycode treferencecurrency.currency%TYPE);

	TYPE typeremainparam IS RECORD(
		 debitcalcmode  PLS_INTEGER := cbegindate
		,creditcalcmode PLS_INTEGER := cbegindate
		,checkremain    PLS_INTEGER := casis
		,absremain      BOOLEAN := FALSE
		,includeenddate PLS_INTEGER := cexclude
		,includeny      PLS_INTEGER := cinclude);
	cemptyremainparam typeremainparam;

	TYPE trecprolongation IS RECORD(
		 idprol     tcontractprolongation.idprol%TYPE
		,contractno tcontractprolongation.contractno%TYPE
		,startdate  tcontractprolongation.startdate%TYPE
		,enddate    tcontractprolongation.enddate%TYPE
		,VALUE      tcontractprolongation.value%TYPE
		,currency   tcontractprolongation.currency%TYPE
		,clerkcode  tcontractprolongation.clerkcode%TYPE
		,accountno  tcontractprolongation.newcontractno%TYPE
		,params     contractparams.typearrayparam2);
	TYPE tarrprolongation IS TABLE OF trecprolongation INDEX BY PLS_INTEGER;

	cemptytaglist contracttypeschema.typeremarktaglist;

	cemptysshotparam   typesnapshotarray;
	cemptysshottranche typesshottranchearray;

	sdebitaccount          NUMBER;
	screditaccount         NUMBER;
	sactiveconvertaccount  NUMBER;
	spassiveconvertaccount NUMBER;
	sdifffromaccount       NUMBER;
	sdifftoaccount         NUMBER;
	sdebitaccountno        VARCHAR(20);
	screditaccountno       VARCHAR(20);
	vdebitcurrency         NUMBER;
	vcreditcurrency        NUMBER;

	cgrpcrd    CONSTANT NUMBER := 1;
	cgrpoutbal CONSTANT NUMBER := 2;

	chist        CONSTANT NUMBER := 1;
	chistint     CONSTANT NUMBER := 2;
	cprcgroup    CONSTANT NUMBER := 1;
	cprcpersonal CONSTANT NUMBER := 2;

	cfirstprolongation CONSTANT PLS_INTEGER := 1;
	clastprolongation  CONSTANT PLS_INTEGER := 2;

	cany           CONSTANT NUMBER := 0;
	cgreatestequal CONSTANT NUMBER := 1;
	cgreatest      CONSTANT NUMBER := 2;
	cleastequal    CONSTANT NUMBER := 3;

	cdefaultcarddelim CONSTANT CHAR := '-';

	accountnotexists EXCEPTION;
	usererror EXCEPTION;
	valuenotexists EXCEPTION;
	negativevalue EXCEPTION;
	incorrectvalue EXCEPTION;

	FUNCTION getversion RETURN VARCHAR2;

	FUNCTION getpackageinfo RETURN custom_fintypes.typepackageinfo;

	PROCEDURE raiseif
	(
		pcondition IN BOOLEAN
	   ,pmessage   IN VARCHAR2
	);

	FUNCTION addentry
	(
		pentryno       IN OUT NUMBER
	   ,pdebitaccount  IN OUT taccount%ROWTYPE
	   ,pcreditaccount IN OUT taccount%ROWTYPE
	   ,pentcode       IN NUMBER
	   ,pcurrencysum   IN NUMBER
	   ,pvalue         IN NUMBER
	   ,pshortrem      IN VARCHAR := NULL
	   ,pexchangeid    IN NUMBER := NULL
	   ,pcheckavl      IN NUMBER := NULL
	   ,pfullremark    IN tentry.fullremark%TYPE := NULL
	) RETURN NUMBER;

	FUNCTION addentry
	(
		pcontractrow   IN tcontract%ROWTYPE
	   ,pentryno       IN OUT NUMBER
	   ,pdebitaccount  IN OUT taccountrecord
	   ,pcreditaccount IN OUT taccountrecord
	   ,pentcode       IN NUMBER
	   ,pcurrencysum   IN NUMBER
	   ,pvalue         IN NUMBER
	   ,pshortrem      IN VARCHAR := NULL
	   ,pexchangeid    IN NUMBER := NULL
	   ,pcheckavl      IN NUMBER := NULL
	   ,pwriterollback IN BOOLEAN := FALSE
	   ,pfullremark    IN tentry.fullremark%TYPE := NULL
	) RETURN NUMBER;

	FUNCTION addentry
	(
		pdocno              IN OUT NUMBER
	   ,pentryno            IN OUT NUMBER
	   ,pdebitaccount       IN VARCHAR
	   ,pcreditaccount      IN VARCHAR
	   ,pentcode            IN NUMBER
	   ,pcurrencysum        IN NUMBER
	   ,pvalue              IN NUMBER
	   ,pshortrem           IN VARCHAR := NULL
	   ,pexchangeid         IN NUMBER := NULL
	   ,pcheckavl           IN NUMBER := entry.flcheck
	   ,ptrandate           IN DATE := NULL
	   ,pfullrem            IN VARCHAR := NULL
	   ,pdebitpriority      IN NUMBER := entry.use_twcms
	   ,pcreditpriority     IN NUMBER := entry.use_twcms
	   ,ponlinedebitacc     IN VARCHAR := NULL
	   ,ponlinecreditacc    IN VARCHAR := NULL
	   ,pdebithandle        IN NUMBER := NULL
	   ,pcredithandle       IN NUMBER := NULL
	   ,pdebitusebonusdebt  IN BOOLEAN := TRUE
	   ,pcreditusebonusdebt IN BOOLEAN := TRUE
	   ,pneednotify         IN BOOLEAN := TRUE
	   ,pfimicomment        IN VARCHAR2 := NULL
	   ,pcheckcredit        IN NUMBER := NULL
	   ,pneednotifycredit   IN BOOLEAN := NULL
	   ,pfimicommentcredit  IN VARCHAR := NULL
	   ,pparentdocno        IN NUMBER := NULL
	   ,pcreatedocument     IN BOOLEAN := FALSE
	) RETURN NUMBER;

	FUNCTION addentry
	(
		pdocno              IN OUT NUMBER
	   ,pentryno            IN OUT NUMBER
	   ,pdebitaccount       IN OUT taccount%ROWTYPE
	   ,pcreditaccount      IN OUT taccount%ROWTYPE
	   ,pcurrencysum        IN NUMBER
	   ,pvalue              IN NUMBER
	   ,pentident           IN VARCHAR
	   ,prem                IN VARCHAR := NULL
	   ,pexchangeid         IN NUMBER := NULL
	   ,pcheckavl           IN NUMBER := entry.flcheck
	   ,pfullrem            IN VARCHAR := NULL
	   ,pdebitpriority      IN NUMBER := entry.use_twcms
	   ,pcreditpriority     IN NUMBER := entry.use_twcms
	   ,ponlinedebitacc     IN VARCHAR := NULL
	   ,ponlinecreditacc    IN VARCHAR := NULL
	   ,pdebithandle        IN NUMBER := NULL
	   ,pcredithandle       IN NUMBER := NULL
	   ,pdebitusebonusdebt  IN BOOLEAN := TRUE
	   ,pcreditusebonusdebt IN BOOLEAN := TRUE
	   ,pneednotify         IN BOOLEAN := TRUE
	   ,pfimicomment        IN VARCHAR2 := NULL
	   ,pcheckcredit        IN NUMBER := NULL
	   ,pneednotifycredit   IN BOOLEAN := NULL
	   ,pfimicommentcredit  IN VARCHAR := NULL
	   ,pvaluedate          IN DATE := NULL
	   ,poperdate           IN DATE := NULL
	   ,pskipdiffentry      IN BOOLEAN := FALSE
	   ,pparentdocno        IN NUMBER := NULL
	   ,pcreatedocument     IN BOOLEAN := FALSE
	) RETURN NUMBER;

	FUNCTION addentry
	(
		pcontractrow        IN tcontract%ROWTYPE
	   ,pdocno              IN OUT NUMBER
	   ,pentryno            IN OUT NUMBER
	   ,pdebitaccount       IN OUT taccountrecord
	   ,pcreditaccount      IN OUT taccountrecord
	   ,pcurrencysum        IN NUMBER
	   ,pvalue              IN NUMBER
	   ,pentident           IN VARCHAR
	   ,prem                IN VARCHAR := NULL
	   ,pexchangeid         IN NUMBER := NULL
	   ,pcheckavl           IN NUMBER := entry.flcheck
	   ,pfullrem            IN VARCHAR := NULL
	   ,pdebitpriority      IN NUMBER := entry.use_twcms
	   ,pcreditpriority     IN NUMBER := entry.use_twcms
	   ,ponlinedebitacc     IN VARCHAR := NULL
	   ,ponlinecreditacc    IN VARCHAR := NULL
	   ,pwriterollback      IN BOOLEAN := FALSE
	   ,pdebithandle        IN NUMBER := NULL
	   ,pcredithandle       IN NUMBER := NULL
	   ,pdebitusebonusdebt  IN BOOLEAN := TRUE
	   ,pcreditusebonusdebt IN BOOLEAN := TRUE
	   ,pneednotify         IN BOOLEAN := TRUE
	   ,pfimicomment        IN VARCHAR2 := NULL
	   ,
		
		pcheckcredit      IN NUMBER := NULL
	   ,pneednotifycredit IN BOOLEAN := NULL
	   ,
		
		pfimicommentcredit IN VARCHAR2 := NULL
	   ,pvaluedate         IN DATE := NULL
	   ,
		
		poperdate      IN DATE := NULL
	   ,pskipdiffentry IN BOOLEAN := FALSE
	   ,ptaglist       IN contracttypeschema.typeremarktaglist := cemptytaglist
	   ,
		
		pparentdocno    IN NUMBER := NULL
	   ,pcreatedocument IN BOOLEAN := FALSE
	) RETURN NUMBER;

	FUNCTION addentrybysum
	(
		pdocno             IN NUMBER
	   ,pentryno           IN OUT NUMBER
	   ,pdebitaccount      IN VARCHAR
	   ,pcreditaccount     IN VARCHAR
	   ,pentcode           IN NUMBER
	   ,pdebitcurrency     IN NUMBER
	   ,pdebitvalue        IN NUMBER
	   ,pcreditcurrency    IN NUMBER
	   ,pcreditvalue       IN NUMBER
	   ,pshortrem          IN VARCHAR := NULL
	   ,pcheckavl          IN NUMBER := entry.flcheck
	   ,pfullrem           IN VARCHAR := NULL
	   ,pcheckcredit       IN NUMBER := NULL
	   ,pneednotifycredit  IN BOOLEAN := NULL
	   ,pfimicommentcredit IN VARCHAR := NULL
	) RETURN NUMBER;

	FUNCTION addentryfast
	(
		pcontractrow    IN tcontract%ROWTYPE
	   ,pdocno          IN OUT NUMBER
	   ,pentryno        IN OUT NUMBER
	   ,pdebitaccount   IN OUT taccountrecord
	   ,pcreditaccount  IN OUT taccountrecord
	   ,pcurrencysum    IN NUMBER
	   ,pvalue          IN NUMBER
	   ,pentcode        IN NUMBER
	   ,pshortrem       IN VARCHAR := NULL
	   ,pexchangeid     IN NUMBER := NULL
	   ,pcheckavl       IN NUMBER := entry.flnocheck
	   ,pfullrem        IN VARCHAR := NULL
	   ,pwriterollback  IN BOOLEAN := FALSE
	   ,pdebithandle    IN NUMBER := NULL
	   ,pcredithandle   IN NUMBER := NULL
	   ,pvaluedate      IN DATE := NULL
	   ,poperdate       IN DATE := NULL
	   ,pskipdiffentry  IN BOOLEAN := FALSE
	   ,ptaglist        IN contracttypeschema.typeremarktaglist := cemptytaglist
	   ,pparentdocno    IN NUMBER := NULL
	   ,pcreatedocument IN BOOLEAN := FALSE
	) RETURN NUMBER;

	PROCEDURE addentry2reference
	(
		pident       VARCHAR
	   ,pbasecode    CHAR
	   ,pname        VARCHAR
	   ,pshortremark IN VARCHAR2 := NULL
	);
	FUNCTION addentry2reference
	(
		pident       IN VARCHAR2
	   ,pbasecode    IN CHAR
	   ,pname        VARCHAR2
	   ,pshortremark IN VARCHAR2 := NULL
	) RETURN NUMBER;
	PROCEDURE addrecordforreport
	(
		pname  VARCHAR
	   ,pvalue VARCHAR
	);
	FUNCTION createstamprow
	(
		paccountno IN VARCHAR
	   ,poperdate  IN DATE := NULL
	) RETURN NUMBER;
	FUNCTION updatestamprow
	(
		paccountno IN VARCHAR
	   ,pupddate   IN DATE
	) RETURN NUMBER;
	PROCEDURE deletestamprow
	(
		paccountno IN VARCHAR
	   ,poperdate  IN DATE
	);
	FUNCTION getstartcrddate(paccountno IN VARCHAR2) RETURN DATE;
	FUNCTION getstartcrddate
	(
		paccountno IN VARCHAR2
	   ,pdate      IN DATE
	) RETURN DATE;
	FUNCTION setendcrddate
	(
		pstartdate IN DATE
	   ,paccountno IN VARCHAR
	) RETURN NUMBER;
	PROCEDURE setendcrddatetonull
	(
		paccountno IN VARCHAR
	   ,pstartdate IN DATE
	);

	FUNCTION setviolatedstat(pcontractno IN VARCHAR) RETURN NUMBER;
	FUNCTION resetviolatedstat(pcontractno IN VARCHAR) RETURN NUMBER;
	FUNCTION closecontract(pcontractno IN VARCHAR) RETURN NUMBER;
	FUNCTION opencontract(pcontractno IN VARCHAR) RETURN NUMBER;
	PROCEDURE setviolatedstat
	(
		pcontractno   IN VARCHAR
	   ,precnoforundo IN OUT NUMBER
	   ,pundo         BOOLEAN := FALSE
	);
	PROCEDURE resetviolatedstat
	(
		pcontractno   IN VARCHAR
	   ,precnoforundo IN OUT NUMBER
	   ,pundo         BOOLEAN := FALSE
	);
	PROCEDURE closecontract
	(
		pcontractno   IN VARCHAR
	   ,precnoforundo IN OUT NUMBER
	   ,pundo         BOOLEAN := FALSE
	);
	PROCEDURE opencontract
	(
		pcontractno   IN VARCHAR
	   ,precnoforundo IN OUT NUMBER
	   ,pundo         BOOLEAN := FALSE
	);

	TYPE typeremainsforacclist IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
	TYPE typeaccounttobulk IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
	TYPE typeremaintobulk IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

	FUNCTION getremainforacclist(pdate DATE) RETURN typeremainsforacclist;
	PROCEDURE loadcontractaccount
	(
		pitem       NUMBER
	   ,oaccountrow OUT taccount%ROWTYPE
	   ,pcontractno VARCHAR := NULL
	);
	PROCEDURE loadcontractaccount
	(
		pitem       NUMBER
	   ,oaccountrow OUT taccountrecord
	   ,pcontractno VARCHAR := NULL
	);
	PROCEDURE loadcontractaccounts
	(
		poaaccount  IN OUT typeaccarray
	   ,pcontractno VARCHAR := NULL
	   ,pdate       IN DATE := NULL
	);

	PROCEDURE loadcontractaccountbyaccno
	(
		paccountno   IN VARCHAR
	   ,oaccountrow  OUT taccount%ROWTYPE
	   ,pdoexception IN BOOLEAN := FALSE
	);

	PROCEDURE loadcontractaccountbyaccno
	(
		paccountno   IN VARCHAR
	   ,oaccountrow  OUT taccountrecord
	   ,pdoexception IN BOOLEAN := FALSE
	);

	PROCEDURE createaccountbycode
	(
		pcontractrow IN tcontract%ROWTYPE
	   ,paccount     IN OUT taccountrecord
	   ,puserbstd    IN BOOLEAN := FALSE
	);
	PROCEDURE copystruct
	(
		psrc  IN taccountrecord
	   ,pdest IN OUT taccount%ROWTYPE
	);
	PROCEDURE copystruct
	(
		psrc  IN taccount%ROWTYPE
	   ,pdest IN OUT taccountrecord
	);

	FUNCTION daycount
	(
		pbegdate IN DATE
	   ,penddate IN DATE
	) RETURN NUMBER;
	FUNCTION daysinyear(pdate IN DATE) RETURN NUMBER;
	FUNCTION dayscoefficient
	(
		pbegdate IN DATE
	   ,penddate IN DATE
	) RETURN NUMBER;
	FUNCTION getyear(pdate IN DATE) RETURN NUMBER;
	FUNCTION quarterlast_day(pdate IN DATE) RETURN DATE;
	FUNCTION add_quarters
	(
		pdate  IN DATE
	   ,pcount IN NUMBER
	) RETURN DATE;

	PROCEDURE openhandle
	(
		phandle    IN OUT NUMBER
	   ,paccountno IN VARCHAR
	   ,pmod       IN CHAR := 'W'
	);
	PROCEDURE freehandle
	(
		phandle    IN OUT NUMBER
	   ,pdonotfree IN BOOLEAN := FALSE
	);
	PROCEDURE freeaccountobjects;
	FUNCTION existacchandle(paccountno IN VARCHAR) RETURN NUMBER;
	FUNCTION updateaccount(paccountno IN VARCHAR) RETURN NUMBER;

	FUNCTION closeaccount
	(
		paccountno IN VARCHAR
	   ,pclosedate IN DATE := NULL
	) RETURN NUMBER;
	FUNCTION closeaccounts
	(
		pcontractno IN VARCHAR
	   ,pclosedate  IN DATE := NULL
	) RETURN NUMBER;
	FUNCTION openaccount(paccountno IN VARCHAR) RETURN NUMBER;
	FUNCTION openaccounts(pcontractno IN VARCHAR) RETURN NUMBER;

	PROCEDURE setcardsignstat
	(
		ppan            tcard.pan%TYPE
	   ,pmbr            tcard.mbr%TYPE
	   ,psign           tcard.signstat%TYPE
	   ,pstat           tcard.crd_stat%TYPE
	   ,pchecktranssign BOOLEAN := TRUE
	   ,pchecktransstat BOOLEAN := TRUE
	   ,pcomment        VARCHAR2 := NULL
	);

	FUNCTION closecard
	(
		pcontractno tcontract.no%TYPE
	   ,pcloseall   BOOLEAN := FALSE
	   ,pcomment    VARCHAR2 := NULL
	) RETURN BOOLEAN;

	FUNCTION unclosecard
	(
		pcontractno tcontract.no%TYPE
	   ,pcomment    VARCHAR2 := NULL
	) RETURN BOOLEAN;

	FUNCTION lockcard
	(
		pcontractno tcontract.no%TYPE
	   ,pstatuslock tcard.crd_stat%TYPE
	   ,pundo       BOOLEAN := FALSE
	   ,pcomment    VARCHAR2 := NULL
	) RETURN BOOLEAN;

	FUNCTION unlockcard
	(
		pcontractno tcontract.no%TYPE
	   ,pstatuslock tcard.crd_stat%TYPE
	   ,pundo       BOOLEAN := FALSE
	   ,pcomment    VARCHAR2 := NULL
	) RETURN BOOLEAN;

	PROCEDURE setavailable
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	);
	PROCEDURE setavailable
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	);

	PROCEDURE changeavailable
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	);
	PROCEDURE changeavailable
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	);

	FUNCTION setlowremain
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := TRUE
	) RETURN NUMBER;
	FUNCTION setlowremain
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := TRUE
	) RETURN NUMBER;

	PROCEDURE setlowremain
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	);
	PROCEDURE setlowremain
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	);

	PROCEDURE changelowremain
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	);
	PROCEDURE changelowremain
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	);

	FUNCTION setoverdraft
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := TRUE
	) RETURN NUMBER;
	FUNCTION setoverdraft
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := TRUE
	) RETURN NUMBER;

	PROCEDURE setoverdraft
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	);
	PROCEDURE setoverdraft
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	);

	PROCEDURE changeoverdraft
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	);
	PROCEDURE changeoverdraft
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	);

	FUNCTION setacccreatedate
	(
		paccount       IN OUT taccount%ROWTYPE
	   ,pvalue         IN DATE
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	) RETURN NUMBER;
	FUNCTION setacccreatedate
	(
		paccount       IN OUT taccountrecord
	   ,pvalue         IN DATE
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	) RETURN NUMBER;

	FUNCTION setaccacct_stat
	(
		paccount       IN OUT taccount%ROWTYPE
	   ,pvalue         IN taccount.acct_stat%TYPE
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	) RETURN NUMBER;
	FUNCTION setaccacct_stat
	(
		paccount       IN OUT taccountrecord
	   ,pvalue         IN taccount.acct_stat%TYPE
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	) RETURN NUMBER;

	FUNCTION getpreparesum
	(
		psummafrom    IN NUMBER
	   ,pcurrencyfrom IN NUMBER
	   ,psummato      IN NUMBER
	   ,pcurrencyto   IN NUMBER
	   ,pexchange     IN NUMBER
	   ,pdate         IN DATE
	   ,poutsum       OUT NUMBER
	   ,poutcurrency  OUT NUMBER
	) RETURN NUMBER;
	FUNCTION getpreparesumto
	(
		psummafrom    IN NUMBER
	   ,pcurrencyfrom IN NUMBER
	   ,psummato      IN NUMBER
	   ,pcurrencyto   IN NUMBER
	   ,pexchange     IN NUMBER
	   ,pdate         IN DATE
	   ,poutsumto     OUT NUMBER
	   ,poutsum       OUT NUMBER
	   ,poutcurrency  OUT NUMBER
	) RETURN NUMBER;

	FUNCTION readdmbrn
	(
		pkey          IN VARCHAR
	   ,pdoexeption   IN BOOLEAN := TRUE
	   ,pcontracttype IN NUMBER := NULL
	) RETURN NUMBER;
	FUNCTION readdmbrc
	(
		pkey          IN VARCHAR
	   ,pdoexeption   IN BOOLEAN := TRUE
	   ,pcontracttype IN NUMBER := NULL
	) RETURN VARCHAR;
	FUNCTION readdmbrd
	(
		pkey          IN VARCHAR
	   ,pdoexeption   IN BOOLEAN := TRUE
	   ,pcontracttype IN NUMBER := NULL
	) RETURN DATE;

	PROCEDURE writedmbrn
	(
		pkey          IN VARCHAR
	   ,pvalue        NUMBER
	   ,pdescription  VARCHAR := ' '
	   ,pcontracttype IN NUMBER := NULL
	);
	PROCEDURE writedmbrc
	(
		pkey          IN VARCHAR
	   ,pvalue        VARCHAR
	   ,pdescription  VARCHAR := ' '
	   ,pcontracttype IN NUMBER := NULL
	);
	PROCEDURE writedmbrd
	(
		pkey          IN VARCHAR
	   ,pvalue        DATE
	   ,pdescription  VARCHAR := ' '
	   ,pcontracttype IN NUMBER := NULL
	);

	PROCEDURE readentcode
	(
		pentcode  OUT NUMBER
	   ,pentident IN VARCHAR
	);
	PROCEDURE readchar
	(
		pdialog       IN NUMBER
	   ,pitem         IN VARCHAR
	   ,pcontracttype IN NUMBER := NULL
	   ,pdoexeption   IN BOOLEAN := FALSE
	);
	PROCEDURE readnumber
	(
		pdialog       IN NUMBER
	   ,pitem         IN VARCHAR
	   ,pcontracttype IN NUMBER := NULL
	   ,pdoexeption   IN BOOLEAN := FALSE
	);
	PROCEDURE readdate
	(
		pdialog       IN NUMBER
	   ,pitem         IN VARCHAR
	   ,pcontracttype IN NUMBER := NULL
	   ,pdoexeption   IN BOOLEAN := FALSE
	);
	PROCEDURE savechar
	(
		pdialog       IN NUMBER
	   ,pitem         IN VARCHAR
	   ,pcontracttype IN NUMBER := NULL
	   ,pdoexeption   IN BOOLEAN := TRUE
	);
	PROCEDURE savenumber
	(
		pdialog       IN NUMBER
	   ,pitem         IN VARCHAR
	   ,pcontracttype IN NUMBER := NULL
	   ,pdoexeption   IN BOOLEAN := TRUE
	);
	PROCEDURE savedate
	(
		pdialog       IN NUMBER
	   ,pitem         IN VARCHAR
	   ,pcontracttype IN NUMBER := NULL
	   ,pdoexeption   IN BOOLEAN := TRUE
	);
	PROCEDURE savefield
	(
		pdialog       NUMBER
	   ,pitem         VARCHAR
	   ,pchecknull    BOOLEAN := TRUE
	   ,pcontracttype IN NUMBER := NULL
	);
	PROCEDURE savefieldstr
	(
		pdialog       NUMBER
	   ,pitem         VARCHAR
	   ,pchecknull    BOOLEAN := TRUE
	   ,pcontracttype IN NUMBER := NULL
	);

	PROCEDURE setitemenabled
	(
		pdialog     NUMBER
	   ,pitem       VARCHAR
	   ,pcontractno VARCHAR
	   ,popercode   VARCHAR
	   ,pvalue      BOOLEAN := NULL
	   ,pparam      VARCHAR := NULL
	);

	PROCEDURE fillexchangelist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcurrent  IN NUMBER
	);
	PROCEDURE fillstatuslist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcurrent  IN VARCHAR
	);
	PROCEDURE fillsignstatlist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	);

	PROCEDURE savenewctaccount
	(
		pcontracttype   IN NUMBER
	   ,pitemname       IN VARCHAR
	   ,pitemcode       IN NUMBER
	   ,pitemdescr      IN VARCHAR
	   ,pitemcrmode     IN NUMBER
	   ,prefaccounttype IN NUMBER
	   ,paccounttype    IN NUMBER
	   ,prefaccttyp     IN VARCHAR
	   ,prefacctstat    IN VARCHAR
	   ,pledger         IN VARCHAR
	   ,psubledger      IN VARCHAR
	   ,paccsign        IN NUMBER
	   ,pcurrency       IN NUMBER
	);
	PROCEDURE savenewctaccount
	(
		pcontracttype IN NUMBER
	   ,pitemname     IN VARCHAR
	   ,pitemcode     IN NUMBER
	   ,pitemdescr    IN VARCHAR
	   ,pitemcrmode   IN NUMBER
	);

	PROCEDURE deletectaccount
	(
		pcontracttype IN NUMBER
	   ,pitemname     IN VARCHAR2
	);

	PROCEDURE additem
	(
		pctype          NUMBER
	   ,psourceitemcode NUMBER
	   ,pitem           VARCHAR
	   ,pdesc           VARCHAR
	   ,pitemtype       NUMBER
	);
	PROCEDURE cloneitems
	(
		pctypefrom IN NUMBER
	   ,pctypeto   IN NUMBER
	);
	PROCEDURE addprchistory
	(
		pname      VARCHAR
	   ,premark    VARCHAR
	   ,pctypeto   NUMBER
	   ,pctypefrom NUMBER
	);
	PROCEDURE addprchistoryint
	(
		pname      VARCHAR
	   ,premark    VARCHAR
	   ,pctypeto   NUMBER
	   ,pctypefrom NUMBER
	);
	PROCEDURE addhistoryint
	(
		pname      VARCHAR
	   ,premark    VARCHAR
	   ,pctypeto   NUMBER
	   ,pctypefrom NUMBER
	);

	FUNCTION getdatebyzero
	(
		paccount   IN taccount%ROWTYPE
	   ,pstartdate IN DATE
	) RETURN DATE;
	FUNCTION getdatebyzero
	(
		paccount   IN taccountrecord
	   ,pstartdate IN DATE
	) RETURN DATE;

	FUNCTION getfirstnotnullremaindate
	(
		paccountno IN taccount.accountno%TYPE
	   ,pstartdate IN DATE
	   ,pstopdate  IN DATE
	) RETURN DATE;

	FUNCTION getdate
	(
		pdate IN DATE
	   ,pday  IN NUMBER
	   ,pnext IN NUMBER := cany
	) RETURN DATE;

	FUNCTION creategrouprisk
	(
		pcontractno IN VARCHAR
	   ,poldgroup   IN NUMBER
	   ,pnewgroup   IN NUMBER
	   ,pno         OUT NUMBER
	   ,pdate       IN DATE := NULL
	   ,pgrouptype  IN NUMBER := cgrpcrd
	) RETURN NUMBER;

	FUNCTION deletegrouprisk
	(
		pcontractno IN VARCHAR
	   ,pgrouptype  IN NUMBER := cgrpcrd
	) RETURN NUMBER;
	FUNCTION deletegrouprisk(pno IN NUMBER) RETURN NUMBER;

	FUNCTION getgrouprisk
	(
		pidclient  IN NUMBER
	   ,pgrouptype IN NUMBER := cgrpcrd
	) RETURN NUMBER;
	FUNCTION getgrouprisk
	(
		pcontractno IN VARCHAR
	   ,pgrouptype  IN NUMBER := cgrpcrd
	) RETURN NUMBER;

	FUNCTION getgroupriskbydate
	(
		pcontractno tcontract.no%TYPE
	   ,pdate       DATE := NULL
	   ,pgrouptype  NUMBER := cgrpcrd
	) RETURN tgrouprisk.newgroup%TYPE;

	FUNCTION fillprchistarray
	(
		pcontracttype IN NUMBER
	   ,pname         IN CHAR
	   ,oardate       OUT typedate
	   ,oarpercent    OUT typenumber
	) RETURN NUMBER;
	FUNCTION fillprchistarray
	(
		pcontracttype IN NUMBER
	   ,pname         IN CHAR
	   ,oahistarray   OUT typeprchistintarray
	) RETURN NUMBER;

	FUNCTION fillprchistintarray
	(
		pcontracttype IN NUMBER
	   ,pname         IN CHAR
	   ,oardate       OUT typedate
	   ,oarpercent    OUT typenumber
	   ,oarinterval   OUT typenumber
	) RETURN NUMBER;
	FUNCTION fillprchistintarray
	(
		pcontracttype  IN NUMBER
	   ,pname          IN CHAR
	   ,oahistintarray OUT typeprchistintarray
	) RETURN NUMBER;

	FUNCTION fillprcintarray
	(
		pcontracttype IN NUMBER
	   ,pname         IN CHAR
	   ,oaintarray    OUT typeprcintarray
	) RETURN NUMBER;

	FUNCTION copyprchistarray
	(
		pardatein     IN typedate
	   ,parpercentin  IN typenumber
	   ,oardateout    OUT typedate
	   ,oarpercentout OUT typenumber
	   ,pcount        IN NUMBER
	) RETURN NUMBER;
	FUNCTION copyprchistarray
	(
		pahistarray IN typeprchistintarray
	   ,oahistarray OUT typeprchistintarray
	   ,pcount      IN NUMBER := NULL
	) RETURN NUMBER;

	FUNCTION copyprchistintarray
	(
		pardatein      IN typedate
	   ,parpercentin   IN typenumber
	   ,parintervalin  IN typenumber
	   ,oardateout     OUT typedate
	   ,oarpercentout  OUT typenumber
	   ,oarintervalout OUT typenumber
	   ,pcount         IN NUMBER
	) RETURN NUMBER;
	FUNCTION copyprchistintarray
	(
		pahistintarray IN typeprchistintarray
	   ,oahistintarray OUT typeprchistintarray
	   ,pcount         IN NUMBER := NULL
	) RETURN NUMBER;

	FUNCTION getpercent
	(
		pdate          IN DATE
	   ,pinterval      IN NUMBER
	   ,paprchistarray IN typeprchistintarray
	   ,oprcdate       OUT DATE
	   ,oprcvalue      OUT NUMBER
	) RETURN NUMBER;
	FUNCTION getpercentchange
	(
		pstartdate      IN DATE
	   ,penddate        IN DATE
	   ,pinterval       IN NUMBER
	   ,paprchistarray  IN typeprchistintarray
	   ,paprchistchange OUT typeprchistintarray
	) RETURN NUMBER;
	FUNCTION fillremainarray
	(
		paccount   IN taccountrecord
	   ,pstartdate IN DATE
	   ,penddate   IN DATE
	   ,oprcarray  OUT typeprcarray
	   ,pabsremain IN BOOLEAN := TRUE
	) RETURN NUMBER;

	FUNCTION filltranchearray
	(
		paccount      IN taccountrecord
	   ,pstartdate    IN DATE
	   ,penddate      IN DATE
	   ,otranchearray OUT typetranchearray
	) RETURN NUMBER;

	PROCEDURE copytranchearray
	(
		ptranchearray IN typetranchearray
	   ,otranchearray OUT typetranchearray
	);

	FUNCTION calcpercent
	(
		paprcarray typeprcarray
	   ,pratebase  NUMBER := NULL
	) RETURN NUMBER;

	PROCEDURE putinfo
	(
		pdatebegin IN DATE
	   ,pdays      IN NUMBER
	   ,pvalue     IN NUMBER
	   ,pprcvalue  IN NUMBER
	   ,pprcdate   IN DATE
	   ,pprccalc   IN NUMBER
	);

	FUNCTION getentsumbycode
	(
		paccount   IN taccountrecord
	   ,pentcode   IN NUMBER
	   ,pstartdate IN DATE
	   ,penddate   IN DATE
	) RETURN NUMBER;

	FUNCTION getcontractrecord
	(
		pcontractno  IN VARCHAR
	   ,ocontractrow OUT tcontract%ROWTYPE
	) RETURN NUMBER;

	FUNCTION getdataforundo(pkey IN VARCHAR) RETURN VARCHAR;
	FUNCTION getdataforundo
	(
		popos  IN OUT NUMBER
	   ,ovalue OUT VARCHAR
	) RETURN VARCHAR;

	FUNCTION getargforundo
	(
		pvalue IN VARCHAR
	   ,oaarg  OUT typevarchar50
	) RETURN NUMBER;

	FUNCTION savesnapshot
	(
		pcontractno    IN VARCHAR
	   ,popdate        IN DATE
	   ,psnapshotarray IN typesnapshotarray
	   ,pidsnapshot    OUT NUMBER
	) RETURN NUMBER;
	FUNCTION savesnapshot
	(
		pcontractno IN VARCHAR
	   ,popdate     IN DATE
	   ,pidsnapshot IN NUMBER
	   ,pident      IN VARCHAR
	   ,pvalue      IN VARCHAR
	) RETURN NUMBER;

	FUNCTION loadsnapshot
	(
		pcontractno    IN VARCHAR
	   ,popdate        IN DATE
	   ,psnapshotarray OUT typesnapshotarray
	   ,pdate          OUT DATE
	) RETURN NUMBER;
	FUNCTION loadsnapshot
	(
		pcontractno    IN VARCHAR
	   ,popdate        IN DATE
	   ,pident         IN VARCHAR
	   ,psnapshotarray OUT typesnapshotarray
	   ,pdate          OUT DATE
	) RETURN NUMBER;
	FUNCTION loadsnapshot
	(
		pcontractno IN VARCHAR
	   ,popdate     IN DATE
	   ,pident      IN VARCHAR
	   ,pvalue      OUT VARCHAR
	   ,pdate       OUT DATE
	) RETURN NUMBER;
	FUNCTION delsnapshot(pidsnapshot IN NUMBER) RETURN NUMBER;

	FUNCTION savesshot
	(
		pcontractno    tcontract.no%TYPE
	   ,psshotdate     DATE := NULL
	   ,passhotparam   typesnapshotarray := cemptysshotparam
	   ,passhottranche typesshottranchearray := cemptysshottranche
	) RETURN tcontractsshot.id%TYPE;

	FUNCTION getsshotbydate
	(
		pcontractno tcontract.no%TYPE
	   ,plookupdate DATE
	   ,psshotdate  OUT DATE
	) RETURN tcontractsshot.id%TYPE;

	FUNCTION loadsshotparam(pid tcontractsshot.id%TYPE) RETURN typesnapshotarray;

	FUNCTION getsshotvalue
	(
		passhotparam typesnapshotarray
	   ,pident       tcontractsshotparam.ident%TYPE
	) RETURN tcontractsshotparam.value%TYPE;

	PROCEDURE deletesshot(pid tcontractsshot.id%TYPE);

	PROCEDURE makeacctypeitem
	(
		pdialog       IN NUMBER
	   ,px            IN NUMBER
	   ,py            IN NUMBER
	   ,pwidth        IN NUMBER
	   ,pheight       IN NUMBER
	   ,pcontracttype IN NUMBER
	   ,pitemname     IN VARCHAR := ''
	   ,pcaption      IN VARCHAR := ''
	);
	PROCEDURE acctypeitemproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE acctypeperiodproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE copyacctypeperiod
	(
		ptypefrom IN NUMBER
	   ,ptypeto   IN NUMBER
	);

	FUNCTION fillacctypeperiodarray
	(
		pcontracttype IN NUMBER
	   ,pitemname     IN VARCHAR := ''
	) RETURN typeacctypeperiodarray;

	FUNCTION fillremainarray
	(
		paccountno taccount.accountno%TYPE
	   ,pstartdate DATE
	   ,penddate   DATE
	   ,prp        typeremainparam := cemptyremainparam
	) RETURN typeprcarray;

	FUNCTION fillremainarray
	(
		paccountnoarr typeaccountnoarray
	   ,pstartdate    DATE
	   ,penddate      DATE
	   ,prp           typeremainparam := cemptyremainparam
	) RETURN typeprcarray;

	FUNCTION mergepercent
	(
		paremain      typeprcarray
	   ,paprc         referenceprchistory.typeprcarray
	   ,pfixedprcdate DATE := NULL
	   ,pdebugon      IN BOOLEAN := FALSE
	) RETURN typeprcarray;

	FUNCTION getaverageremain
	(
		paccountno taccount.accountno%TYPE
	   ,pstartdate DATE
	   ,penddate   DATE
	   ,pclosedate DATE := NULL
	   ,prp        typeremainparam := cemptyremainparam
	) RETURN NUMBER;

	FUNCTION getentryinfo
	(
		paccount        IN taccount.accountno%TYPE
	   ,pstartdate      IN DATE
	   ,penddate        IN DATE
	   ,pmaxcount       IN NUMBER
	   ,parchive        IN BOOLEAN
	   ,pignoreentcodes IN sql_typenumbers
	) RETURN contracttypeschema.typeentryinfoarray;

	cnone CONSTANT PLS_INTEGER := 0;
	ctype CONSTANT PLS_INTEGER := 1;
	ccont CONSTANT PLS_INTEGER := 2;
	cboth CONSTANT PLS_INTEGER := 3;

	cmandatory CONSTANT PLS_INTEGER := 0;
	coptional  CONSTANT PLS_INTEGER := 1;

	FUNCTION loadparam
	(
		pctype       tcontract.type%TYPE
	   ,paitem       tblschitem
	   ,pdoexception BOOLEAN := TRUE
	   ,pstartdate   DATE := NULL
	) RETURN types.arrstr1000;

	FUNCTION loadparam
	(
		pcno         tcontract.no%TYPE
	   ,paitem       tblschitem
	   ,pactparam    types.arrstr1000
	   ,pdoexception BOOLEAN := TRUE
	) RETURN types.arrstr1000;

	FUNCTION loadschemaparam
	(
		pschemacode tcontractschemas.type%TYPE
	   ,paitem      tblschitem
	) RETURN types.arrstr1000;

	FUNCTION loadcaccounts
	(
		pctype       tcontract.type%TYPE
	   ,pcno         tcontract.no%TYPE
	   ,paitem       tblschitem
	   ,pdoexception BOOLEAN := TRUE
	) RETURN typeaccarray;

	FUNCTION loadcaccounts
	(
		pcno     IN tcontract.no%TYPE
	   ,paicodes IN tblschitem
	) RETURN typeaccarray;

	FUNCTION loadbaccounts
	(
		pctype       tcontract.type%TYPE
	   ,paitem       tblschitem
	   ,pdoexception BOOLEAN := TRUE
	) RETURN typeaccarray;

	FUNCTION loadrateid
	(
		pctype IN tcontract.type%TYPE
	   ,paitem IN tblschitem
	) RETURN types.arrnum;

	FUNCTION loadrate
	(
		pctype       tcontract.type%TYPE
	   ,paitem       tblschitem
	   ,pdoexception BOOLEAN := TRUE
	) RETURN trate;

	FUNCTION loadrateid
	(
		pcno   IN tcontract.no%TYPE
	   ,paitem IN tblschitem
	) RETURN types.arrnum;

	FUNCTION loadrate
	(
		pcno         tcontract.no%TYPE
	   ,paitem       tblschitem
	   ,pctrate      trate
	   ,pdoexception BOOLEAN := TRUE
	) RETURN trate;

	FUNCTION loadentrycodes
	(
		paitem       tblschitem
	   ,pdoexception BOOLEAN := TRUE
	) RETURN types.arrnum;

	FUNCTION loaditemcodes
	(
		pctype       IN tcontract.type%TYPE
	   ,paitem       IN tblschitem
	   ,pdoexception IN BOOLEAN := TRUE
	) RETURN types.arrnum;

	FUNCTION loaditemnames(pctype tcontract.type%TYPE) RETURN types.arrstr40;

	PROCEDURE changecreatedate
	(
		pcontractno          IN tcontract.no%TYPE
	   ,pcreatedate          IN tcontract.createdate%TYPE
	   ,pchangeacccreatedate IN BOOLEAN
	);

	PROCEDURE setacctype
	(
		paccountno      IN taccount.accountno%TYPE
	   ,pnewaccounttype IN NUMBER
	   ,paccounthandle  IN NUMBER := NULL
	);

	FUNCTION years_between
	(
		pdateto   IN DATE
	   ,pdatefrom IN DATE
	) RETURN NUMBER;

	FUNCTION getentcode
	(
		pentident    IN treferenceentry.ident%TYPE
	   ,pbasecode    IN CHAR
	   ,pname        IN VARCHAR2
	   ,pshortremark IN VARCHAR2 := NULL
	) RETURN treferenceentry.code%TYPE;

	FUNCTION changecontractno(pcontractno IN tcontract.no%TYPE) RETURN BOOLEAN;
	PROCEDURE changecontractno(pcontractno IN tcontract.no%TYPE);
	FUNCTION parsedelimparam
	(
		pparam VARCHAR2
	   ,pdelim VARCHAR2
	) RETURN tarrcharbychar;
	FUNCTION shiftparam(paparam contracttypeschema.typefschparamlist) RETURN tarrcharbychar;
	PROCEDURE addprolongation
	(
		pprolongationrow IN OUT tcontractprolongation%ROWTYPE
	   ,psaverollback    IN BOOLEAN := TRUE
	);
	FUNCTION addprolongation
	(
		pcontractno    IN tcontractprolongation.contractno%TYPE
	   ,pstartdate     IN tcontractprolongation.startdate%TYPE
	   ,penddate       IN tcontractprolongation.enddate%TYPE
	   ,pvalue         IN tcontractprolongation.value%TYPE
	   ,pcurrency      IN tcontractprolongation.currency%TYPE
	   ,pnewcontractno IN tcontractprolongation.newcontractno%TYPE := NULL
	   ,psaverollback  IN BOOLEAN := TRUE
	) RETURN tcontractprolongation.idprol%TYPE;
	PROCEDURE deleteprolongation(pidprol IN tcontractprolongation.idprol%TYPE);
	FUNCTION getprolongation(pidprol IN tcontractprolongation.idprol%TYPE)
		RETURN tcontractprolongation%ROWTYPE;
	FUNCTION getprolongation
	(
		pcontractno       IN tcontractprolongation.contractno%TYPE
	   ,pprolongationtype IN PLS_INTEGER
	) RETURN tcontractprolongation%ROWTYPE;
	FUNCTION getprolongationcount(pcontractno IN tcontractprolongation.contractno%TYPE) RETURN NUMBER;

	PROCEDURE addprolongation
	(
		pcontractno   tcontractprolongation.contractno%TYPE
	   ,pstartdate    tcontractprolongation.startdate%TYPE
	   ,penddate      tcontractprolongation.enddate%TYPE
	   ,pvalue        tcontractprolongation.value%TYPE
	   ,pcurrency     tcontractprolongation.currency%TYPE
	   ,paccountno    tcontractprolongation.newcontractno%TYPE
	   ,paparams      contractparams.typearrayparam2
	   ,psaverollback BOOLEAN := TRUE
	);
	FUNCTION getprolongationparams(pidprol tcontractprolongation.idprol%TYPE)
		RETURN contractparams.typearrayparam2;
	FUNCTION getprolongationlist(pcontractno tcontract.no%TYPE) RETURN tarrprolongation;
	FUNCTION getrecprolongation(pidprol tcontractprolongation.idprol%TYPE) RETURN trecprolongation;
	FUNCTION getrecprolongation
	(
		pcontractno       tcontract.no%TYPE
	   ,pprolongationtype PLS_INTEGER
	) RETURN trecprolongation;

	FUNCTION getobjecttype(pobjectname VARCHAR2) RETURN NUMBER;

	PROCEDURE dolog
	(
		pobjectname VARCHAR2
	   ,pobjectid   VARCHAR2
	   ,plogaction  NUMBER
	   ,plogmsg     VARCHAR2
	   ,palogparam  tblchar100 := NULL
	   ,paoldvalue  tblchar100 := NULL
	   ,panewvalue  tblchar100 := NULL
	   ,powner      a4mlog.typeclientid := NULL
	);

	FUNCTION getentryarray
	(
		paccount   IN taccount.accountno%TYPE
	   ,pstartdate IN DATE
	   ,penddate   IN DATE
	   ,pmaxcount  IN NUMBER
	   ,parchive   IN BOOLEAN
	) RETURN contracttypeschema.tentryarray;

	FUNCTION getleast
	(
		pfromvalue IN NUMBER
	   ,pfromcurr  IN treferencecurrency.currency%TYPE
	   ,ptovalue   IN NUMBER
	   ,ptocurr    IN treferencecurrency.currency%TYPE
	   ,pexchrate  IN NUMBER := NULL
	   ,poperdate  IN DATE := NULL
	) RETURN tamount;

	PROCEDURE getleast
	(
		ovalue     OUT NUMBER
	   ,ocurr      OUT NUMBER
	   ,pfromvalue IN NUMBER
	   ,pfromcurr  IN treferencecurrency.currency%TYPE
	   ,ptovalue   IN NUMBER
	   ,ptocurr    IN treferencecurrency.currency%TYPE
	   ,pexchrate  IN NUMBER := NULL
	   ,poperdate  IN DATE := NULL
	);

	FUNCTION getgreatest
	(
		pfromvalue IN NUMBER
	   ,pfromcurr  IN treferencecurrency.currency%TYPE
	   ,ptovalue   IN NUMBER
	   ,ptocurr    IN treferencecurrency.currency%TYPE
	   ,pexchrate  IN NUMBER := NULL
	   ,poperdate  IN DATE := NULL
	) RETURN tamount;

	PROCEDURE getgreatest
	(
		ovalue     OUT NUMBER
	   ,ocurr      OUT NUMBER
	   ,pfromvalue IN NUMBER
	   ,pfromcurr  IN treferencecurrency.currency%TYPE
	   ,ptovalue   IN NUMBER
	   ,ptocurr    IN treferencecurrency.currency%TYPE
	   ,pexchrate  IN NUMBER := NULL
	   ,poperdate  IN DATE := NULL
	);

	FUNCTION showmessage
	(
		pcaption     IN VARCHAR2
	   ,pmessage     IN VARCHAR2
	   ,pflagcaption IN VARCHAR2
	   ,pnoshowagain IN OUT BOOLEAN
	   ,pbutton      IN NUMBER
	) RETURN NUMBER;
	PROCEDURE dialogmessageproc
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN VARCHAR2
	   ,pcmd    IN NUMBER
	);

	FUNCTION xirr
	(
		padate     types.arrdate
	   ,paamount   types.arrnum
	   ,pguess     NUMBER := NULL
	   ,pprecision NUMBER := 0.00001
	) RETURN NUMBER;

	FUNCTION isitemnameexistsintype
	(
		pcontracttype IN tcontract.type%TYPE
	   ,pitemname     IN tcontracttypeitemname.itemname%TYPE
	) RETURN BOOLEAN;
	FUNCTION getcontractstatus4ib
	(
		pcontractno IN tcontract.no%TYPE
	   ,pstatus     IN tcontract.status%TYPE := 'NONE'
	) RETURN NUMBER;

	PROCEDURE fixarrestedremain(paccount IN OUT NOCOPY taccountrecord);
	PROCEDURE fixarrestedremain(paccount IN OUT NOCOPY taccount%ROWTYPE);

	FUNCTION parsestring
	(
		pstring     IN VARCHAR2
	   ,pdelimiter  IN VARCHAR2
	   ,pmincount   IN NUMBER := NULL
	   ,pmaxcount   IN NUMBER := NULL
	   ,pparamcount IN NUMBER := NULL
	) RETURN types.arrstr4000;

	FUNCTION paramstringtolist
	(
		pparamsstring  IN VARCHAR2
	   ,ppairdelimiter IN VARCHAR2 := ';'
	   ,pkeydelimiter  IN VARCHAR2 := '='
	   ,pprohibitdups  IN BOOLEAN := FALSE
	) RETURN contracttypeschema.typefschparamlist;
	FUNCTION paramstringtoarray
	(
		pparamsstring  IN VARCHAR2
	   ,ppairdelimiter IN VARCHAR2 := ';'
	   ,pkeydelimiter  IN VARCHAR2 := '='
	) RETURN tarrcharbychar;

	FUNCTION parsedelimparamlinkcontract
	(
		pparam          VARCHAR2
	   ,pstartdelimiter VARCHAR2 := '['
	   ,penddelimiter   VARCHAR2 := ']'
	) RETURN typestrbystr;

	FUNCTION getparamsbycontracttype
	(
		pcontracttype IN tcontract.type%TYPE
	   ,paparams      typestrbystr
	) RETURN tcontract.rollbackdata%TYPE;

	FUNCTION getparamfromstring
	(
		pparamstring   IN VARCHAR2
	   ,pparam         IN VARCHAR2
	   ,pmandatory     IN BOOLEAN := TRUE
	   ,pprohibitnull  IN BOOLEAN := TRUE
	   ,ppairdelimiter VARCHAR2 := ';'
	   ,pkeydelimiter  VARCHAR2 := '='
	) RETURN VARCHAR2;

	PROCEDURE legacyparsekey2pan
	(
		pkey IN VARCHAR2
	   ,opan OUT VARCHAR2
	   ,ombr OUT NUMBER
	);

	PROCEDURE parsecardstring
	(
		pstring    VARCHAR2
	   ,opan       OUT tcard.pan%TYPE
	   ,ombr       OUT tcard.mbr%TYPE
	   ,pdelimiter VARCHAR2 := cdefaultcarddelim
	);

	FUNCTION parsecardstring
	(
		pstring    VARCHAR2
	   ,pdelimiter VARCHAR2 := cdefaultcarddelim
	) RETURN apitypes.typeaccount2cardrecord;

	FUNCTION makecardstring
	(
		ppan       IN VARCHAR2
	   ,pmbr       IN VARCHAR2
	   ,pdelimiter VARCHAR2 := cdefaultcarddelim
	) RETURN VARCHAR2;

	FUNCTION isnumber
	(
		pvalue      IN VARCHAR2
	   ,pwhatisnull IN BOOLEAN := FALSE
	) RETURN BOOLEAN;

	FUNCTION isdate
	(
		pvalue      IN VARCHAR2
	   ,pformat     IN VARCHAR2 := contractparams.cparam_date_format
	   ,pwhatisnull IN BOOLEAN := FALSE
	) RETURN BOOLEAN;

	PROCEDURE checkvalue_exists
	(
		pvalue     IN NUMBER
	   ,pvaluename IN VARCHAR2
	);

	PROCEDURE checkvalue_exists
	(
		pvalue     IN DATE
	   ,pvaluename IN VARCHAR2
	);

	PROCEDURE checkvalue_exists
	(
		pvalue     IN VARCHAR2
	   ,pvaluename IN VARCHAR2
	);

	PROCEDURE validatechar
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cchar_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN NUMBER := NULL
	   ,pallowedvalues   IN tblchar1000 := tblchar1000()
	   ,pforbiddenvalues IN tblchar1000 := tblchar1000()
	   ,perrmsg          IN VARCHAR2 := NULL
	);

	FUNCTION validchar
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cchar_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN NUMBER := NULL
	   ,pallowedvalues   IN tblchar1000 := tblchar1000()
	   ,pforbiddenvalues IN tblchar1000 := tblchar1000()
	   ,oerrmsg          OUT VARCHAR2
	) RETURN BOOLEAN;

	FUNCTION getvalidchar
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cchar_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN NUMBER := NULL
	   ,pallowedvalues   IN tblchar1000 := tblchar1000()
	   ,pforbiddenvalues IN tblchar1000 := tblchar1000()
	   ,perrmsg          IN VARCHAR2 := NULL
	) RETURN VARCHAR2;

	PROCEDURE validatenumber
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cnum_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN NUMBER := NULL
	   ,pminvalue        IN NUMBER := NULL
	   ,pmaxvalue        IN NUMBER := NULL
	   ,pallowedvalues   IN tblnumber := tblnumber()
	   ,pforbiddenvalues IN tblnumber := tblnumber()
	   ,perrmsg          IN VARCHAR2 := NULL
	);

	FUNCTION validnumber
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cnum_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN NUMBER := NULL
	   ,pminvalue        IN NUMBER := NULL
	   ,pmaxvalue        IN NUMBER := NULL
	   ,pallowedvalues   IN tblnumber := tblnumber()
	   ,pforbiddenvalues IN tblnumber := tblnumber()
	   ,oerrmsg          OUT VARCHAR2
	) RETURN BOOLEAN;

	FUNCTION getvalidnumber
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cnum_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN NUMBER := NULL
	   ,pminvalue        IN NUMBER := NULL
	   ,pmaxvalue        IN NUMBER := NULL
	   ,pallowedvalues   IN tblnumber := tblnumber()
	   ,pforbiddenvalues IN tblnumber := tblnumber()
	   ,perrmsg          IN VARCHAR2 := NULL
	) RETURN NUMBER;

	PROCEDURE validatedate
	(
		pvalue           IN DATE
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cdate_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN DATE := NULL
	   ,pminvalue        IN DATE := NULL
	   ,pmaxvalue        IN DATE := NULL
	   ,pallowedvalues   IN tbldate := tbldate()
	   ,pforbiddenvalues IN tbldate := tbldate()
	   ,perrmsg          IN VARCHAR2 := NULL
	);

	PROCEDURE validatedate
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pformat          IN VARCHAR2 := contractparams.cparam_date_format
	   ,pcheckmode       IN PLS_INTEGER := cdate_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN DATE := NULL
	   ,pminvalue        IN DATE := NULL
	   ,pmaxvalue        IN DATE := NULL
	   ,pallowedvalues   IN tbldate := tbldate()
	   ,pforbiddenvalues IN tbldate := tbldate()
	   ,perrmsg          IN VARCHAR2 := NULL
	);

	FUNCTION validdate
	(
		pvalue           IN DATE
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cdate_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN DATE := NULL
	   ,pminvalue        IN DATE := NULL
	   ,pmaxvalue        IN DATE := NULL
	   ,pallowedvalues   IN tbldate := tbldate()
	   ,pforbiddenvalues IN tbldate := tbldate()
	   ,oerrmsg          OUT VARCHAR2
	) RETURN BOOLEAN;

	FUNCTION validdate
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pformat          IN VARCHAR2 := contractparams.cparam_date_format
	   ,pcheckmode       IN PLS_INTEGER := cdate_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN DATE := NULL
	   ,pminvalue        IN DATE := NULL
	   ,pmaxvalue        IN DATE := NULL
	   ,pallowedvalues   IN tbldate := tbldate()
	   ,pforbiddenvalues IN tbldate := tbldate()
	   ,oerrmsg          OUT VARCHAR2
	) RETURN BOOLEAN;

	FUNCTION getvaliddate
	(
		pvalue           IN DATE
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cdate_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN DATE := NULL
	   ,pminvalue        IN DATE := NULL
	   ,pmaxvalue        IN DATE := NULL
	   ,pallowedvalues   IN tbldate := tbldate()
	   ,pforbiddenvalues IN tbldate := tbldate()
	   ,perrmsg          IN VARCHAR2 := NULL
	) RETURN DATE;

	FUNCTION getvaliddate
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pformat          IN VARCHAR2 := contractparams.cparam_date_format
	   ,pcheckmode       IN PLS_INTEGER := cdate_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN DATE := NULL
	   ,pminvalue        IN DATE := NULL
	   ,pmaxvalue        IN DATE := NULL
	   ,pallowedvalues   IN tbldate := tbldate()
	   ,pforbiddenvalues IN tbldate := tbldate()
	   ,perrmsg          IN VARCHAR2 := NULL
	) RETURN DATE;

	PROCEDURE validateaccount
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2 := NULL
	   ,pcheckmode       IN PLS_INTEGER := cacc_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN typeaccountno := NULL
	   ,pallowedvalues   IN tblchar20 := tblchar20()
	   ,pforbiddenvalues IN tblchar20 := tblchar20()
	   ,perrmsg          IN VARCHAR2 := NULL
	);

	FUNCTION validaccount
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2 := NULL
	   ,pcheckmode       IN PLS_INTEGER := cacc_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN typeaccountno := NULL
	   ,pallowedvalues   IN tblchar20 := tblchar20()
	   ,pforbiddenvalues IN tblchar20 := tblchar20()
	   ,oerrmsg          OUT VARCHAR2
	) RETURN BOOLEAN;

	FUNCTION getvalidaccount
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2 := NULL
	   ,pcheckmode       IN PLS_INTEGER := cacc_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN typeaccountno := NULL
	   ,pallowedvalues   IN tblchar20 := tblchar20()
	   ,pforbiddenvalues IN tblchar20 := tblchar20()
	   ,perrmsg          IN VARCHAR2 := NULL
	) RETURN typeaccountno;

	FUNCTION equal
	(
		pnum1 IN NUMBER
	   ,pnum2 IN NUMBER
	) RETURN BOOLEAN;

	FUNCTION notequal
	(
		pnum1 IN NUMBER
	   ,pnum2 IN NUMBER
	) RETURN BOOLEAN;

	FUNCTION equal
	(
		pstr1 IN VARCHAR2
	   ,pstr2 IN VARCHAR2
	) RETURN BOOLEAN;

	FUNCTION notequal
	(
		pstr1 IN VARCHAR2
	   ,pstr2 IN VARCHAR2
	) RETURN BOOLEAN;

	FUNCTION equal
	(
		pdate1 IN DATE
	   ,pdate2 IN DATE
	) RETURN BOOLEAN;

	FUNCTION notequal
	(
		pdate1 IN DATE
	   ,pdate2 IN DATE
	) RETURN BOOLEAN;

	FUNCTION equal
	(
		pboolean1 IN BOOLEAN
	   ,pboolean2 IN BOOLEAN
	) RETURN BOOLEAN;

	FUNCTION notequal
	(
		pboolean1 IN BOOLEAN
	   ,pboolean2 IN BOOLEAN
	) RETURN BOOLEAN;

	FUNCTION leastdate
	(
		pdate1 IN DATE
	   ,pdate2 IN DATE
	) RETURN DATE;

	FUNCTION greatestdate
	(
		pdate1 IN DATE
	   ,pdate2 IN DATE
	) RETURN DATE;

	FUNCTION datesinsamemonths
	(
		pdate1 IN DATE
	   ,pdate2 IN DATE
	) RETURN BOOLEAN;

	FUNCTION datesindiffmonths
	(
		pdate1 IN DATE
	   ,pdate2 IN DATE
	) RETURN BOOLEAN;

	FUNCTION get_bod_remain
	(
		paccountno       IN taccount.accountno%TYPE
	   ,pdate            IN DATE
	   ,parchive         IN BOOLEAN := FALSE
	   ,pcheckemptyaccno IN BOOLEAN := FALSE
	) RETURN NUMBER;

	FUNCTION get_eod_remain
	(
		paccountno       IN taccount.accountno%TYPE
	   ,pdate            IN DATE
	   ,parchive         IN BOOLEAN := FALSE
	   ,pcheckemptyaccno IN BOOLEAN := FALSE
	) RETURN NUMBER;

	FUNCTION getsumincurrency
	(
		psum          IN NUMBER
	   ,pfromcurrency IN NUMBER
	   ,ptocurrency   IN NUMBER
	   ,pexchrate     IN NUMBER := NULL
	   ,poperdate     IN DATE := NULL
	) RETURN NUMBER;

	FUNCTION getsumincurrency
	(
		pamount     IN tamount
	   ,ptocurrency IN NUMBER
	   ,pexchrate   IN NUMBER := NULL
	   ,poperdate   IN DATE := NULL
	) RETURN NUMBER;

	FUNCTION getsumincurrency
	(
		paccountrecord IN taccountrecord
	   ,ptocurrency    IN NUMBER
	   ,pexchrate      IN NUMBER := NULL
	   ,poperdate      IN DATE := NULL
	) RETURN NUMBER;

	PROCEDURE createstamprow
	(
		paccountno IN taccount.accountno%TYPE
	   ,pstartdate IN DATE := NULL
	);
	FUNCTION getcredithistoryrecord
	(
		paccountno   IN taccount.accountno%TYPE
	   ,pstartdate   IN DATE
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN tcredithistory%ROWTYPE;

	FUNCTION pushdocno2skip(pdocno IN tdocument.docno%TYPE) RETURN BOOLEAN;
	PROCEDURE popdocno2skip(pdocno IN tdocument.docno%TYPE);
	PROCEDURE cleardocno2skip;
	PROCEDURE entryundo
	(
		pdocno         IN tdocument.docno%TYPE
	   ,pcheck         IN NUMBER := NULL
	   ,pwithoutlogoff IN BOOLEAN := FALSE
	);

	PROCEDURE validatesequence
	(
		psequencename IN VARCHAR2
	   ,ptablename    IN VARCHAR2
	   ,pcolumnname   IN VARCHAR2
	);

	FUNCTION getvalidatednextval
	(
		psequencename IN VARCHAR2
	   ,ptablename    IN VARCHAR2
	   ,pcolumnname   IN VARCHAR2
	) RETURN NUMBER;

	FUNCTION getcardtype
	(
		ppan            IN tcard.pan%TYPE
	   ,pmbr            IN tcard.mbr%TYPE
	   ,pcheckexistence IN BOOLEAN := FALSE
	) RETURN tcard.supplementary%TYPE;

	PROCEDURE dialogprolongationhistory
	(
		pcontractno IN tcontractprolongation.contractno%TYPE
	   ,preadonly   IN BOOLEAN := FALSE
	);
	PROCEDURE dialogprolongationhist_handler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	);
	FUNCTION dialogprolongationhistory
	(
		pcontractno   IN tcontract.no%TYPE
	   ,pkeyvaluelist IN contracttypeschema.typekeyvaluelist
	   ,preadonly     IN BOOLEAN := FALSE
	) RETURN NUMBER;

	PROCEDURE makeprolongationhistoryitem
	(
		pdialog       IN NUMBER
	   ,pitemname     IN VARCHAR2
	   ,px            IN NUMBER
	   ,py            IN NUMBER
	   ,pwidth        IN NUMBER
	   ,phight        IN NUMBER
	   ,panchor       IN NUMBER
	   ,pcontractno   IN tcontract.no%TYPE
	   ,pkeyvaluelist IN contracttypeschema.typekeyvaluelist
	);

	PROCEDURE makeprolonghistitem_handler
	(
		pwhat     CHAR
	   ,pdialog   NUMBER
	   ,pitemname VARCHAR
	   ,pcmd      NUMBER
	);

	PROCEDURE addmenuprolongation
	(
		pdialog     IN NUMBER
	   ,pmenu       IN NUMBER
	   ,pcontractno IN tcontractprolongation.contractno%TYPE
	   ,preadonly   IN BOOLEAN := FALSE
	);
	PROCEDURE enableprolongationmenu
	(
		pdialog  IN NUMBER
	   ,penabled IN BOOLEAN
	);
	PROCEDURE addmenuprolongation_handler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);

	FUNCTION contractcommited(pcontractno IN tcontract.no%TYPE) RETURN BOOLEAN;

	FUNCTION cardcommited
	(
		ppan IN typepan
	   ,pmbr IN typembr
	) RETURN BOOLEAN;

	FUNCTION nullor
	(
		pvalue1 IN NUMBER
	   ,pvalue2 IN NUMBER
	) RETURN BOOLEAN;
	FUNCTION nullor
	(
		pvalue1 IN VARCHAR2
	   ,pvalue2 IN VARCHAR2
	) RETURN BOOLEAN;
	FUNCTION nullor
	(
		pvalue1 IN DATE
	   ,pvalue2 IN DATE
	) RETURN BOOLEAN;

	FUNCTION nulland
	(
		pvalue1 IN NUMBER
	   ,pvalue2 IN NUMBER
	) RETURN BOOLEAN;
	FUNCTION nulland
	(
		pvalue1 IN VARCHAR2
	   ,pvalue2 IN VARCHAR2
	) RETURN BOOLEAN;
	FUNCTION nulland
	(
		pvalue1 IN DATE
	   ,pvalue2 IN DATE
	) RETURN BOOLEAN;

	FUNCTION nullxor
	(
		pvalue1 IN NUMBER
	   ,pvalue2 IN NUMBER
	) RETURN BOOLEAN;
	FUNCTION nullxor
	(
		pvalue1 IN VARCHAR2
	   ,pvalue2 IN VARCHAR2
	) RETURN BOOLEAN;
	FUNCTION nullxor
	(
		pvalue1 IN DATE
	   ,pvalue2 IN DATE
	) RETURN BOOLEAN;

	FUNCTION dectobin(pnumber IN PLS_INTEGER) RETURN VARCHAR2;

	FUNCTION getsetbitcount(pnumber IN PLS_INTEGER) RETURN PLS_INTEGER;

	FUNCTION getsetbitpos(psinglebitnumber IN PLS_INTEGER) RETURN PLS_INTEGER;

	FUNCTION bitset
	(
		pnumber          IN PLS_INTEGER
	   ,psinglebitnumber IN PLS_INTEGER
	) RETURN BOOLEAN;

	FUNCTION getpackageinfo_maindescription
	(
		ppackageinfo    IN custom_fintypes.typepackageinfo
	   ,paddpackagename BOOLEAN := FALSE
	) RETURN VARCHAR2;

	FUNCTION getpackageinfo_headerdescription(ppackageinfo IN custom_fintypes.typepackageinfo)
		RETURN VARCHAR2;

	FUNCTION getpackageinfo_bodydescription(ppackageinfo IN custom_fintypes.typepackageinfo)
		RETURN VARCHAR2;

	PROCEDURE saypackageinfo(ppackageinfo IN custom_fintypes.typepackageinfo);

	PROCEDURE saypackageinfo(ppackagename IN custom_fintypes.typepackagename);

END custom_contracttools;
/
CREATE OR REPLACE PACKAGE BODY custom_contracttools AS

	cpackage_name CONSTANT VARCHAR2(100) := 'ContractTools';

	cbodyversion CONSTANT VARCHAR2(10) := '22.00.01';

	cbodydate CONSTANT DATE := to_date('11.11.2022', 'DD.MM.YYYY');

	cbodytwcms CONSTANT VARCHAR2(50) := '4.15.88';

	cbodyrevision CONSTANT VARCHAR2(100) := '$Rev: 62164 $';

	csay_level CONSTANT NUMBER := 3;

	table_does_not_exist EXCEPTION;
	PRAGMA EXCEPTION_INIT(table_does_not_exist, -0942);

	column_does_not_exist EXCEPTION;
	PRAGMA EXCEPTION_INIT(column_does_not_exist, -0904);

	cmindate CONSTANT DATE := to_date('0001-01-01', 'YYYY-MM-DD');
	cmaxdate CONSTANT DATE := to_date('9999-01-01', 'YYYY-MM-DD');

	clogparam_available CONSTANT VARCHAR2(10) := 'AVAILABLE';
	clogparam_lowremain CONSTANT VARCHAR2(10) := 'LOWREMAIN';
	clogparam_overdraft CONSTANT VARCHAR2(10) := 'OVERDRAFT';

	cprolongationhistorymenu  CONSTANT VARCHAR2(50) := 'ProlongationHistoryMenu';
	cprolongationcontractno   CONSTANT VARCHAR2(50) := 'ProlongationContractNo';
	cprolongationreadonly     CONSTANT VARCHAR2(50) := 'ProlongationReadOnly';
	cprolongationhistorypanel CONSTANT VARCHAR2(50) := 'ProlongationHistoryPanel';
	cprolongationhistory      CONSTANT VARCHAR2(50) := 'ProlongationHistory';
	cfield_idprol             CONSTANT VARCHAR2(50) := 'cField_IdProl';
	cfield_contractno         CONSTANT VARCHAR2(50) := 'cField_ContractNo';
	cfield_startdate          CONSTANT VARCHAR2(50) := 'cField_StartDate';
	cfield_enddate            CONSTANT VARCHAR2(50) := 'cField_EndDate';
	cfield_key                CONSTANT VARCHAR2(50) := 'cField_Key';
	cfield_name               CONSTANT VARCHAR2(50) := 'cField_Name';
	cfield_value              CONSTANT VARCHAR2(50) := 'cField_Value';
	cprolongationhistoryparam CONSTANT VARCHAR2(50) := 'ProlongationHistoryParam';
	cprolongationkeyvaluelist CONSTANT VARCHAR2(50) := 'ProlongationKeyValueList';

	SUBTYPE typemethodname IS VARCHAR2(100);

	TYPE typeaccountrecord IS RECORD(
		 itemcode       tcontracttypeitems.itemcode%TYPE
		,itemname       tcontracttypeitemname.itemname%TYPE
		,description    tcontracttypeitems.description%TYPE
		,refaccounttype tcontracttypeitemname.refaccounttype%TYPE
		,acchow         tcontractaccount.acchow%TYPE
		,acctype        tcontractaccount.acctype%TYPE
		,acctypep       tcontractaccount.acctypep%TYPE
		,accstatus      tcontractaccount.accstatus%TYPE);

	TYPE typedocno2skiplist IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
	sadocno2skiplist typedocno2skiplist;

	sanewitems typenumber;

	sintmonthsret    NUMBER;
	sintdaysret      NUMBER;
	sacctyperet      NUMBER;
	scontractacctype NUMBER;

	sdonotfreedebitacc  BOOLEAN := FALSE;
	sdonotfreecreditacc BOOLEAN := FALSE;

	saobjecttype tarrnumbychar;

	FUNCTION acctypeperioddialog
	(
		pmonths  IN NUMBER
	   ,pdays    IN NUMBER
	   ,pacctype IN NUMBER
	) RETURN NUMBER;

	FUNCTION getversion RETURN VARCHAR2 IS
	
	BEGIN
		RETURN service.formatpackageversion(cpackage_name, cheaderrevision, cbodyrevision);
	END;

	FUNCTION getpackageinfo RETURN custom_fintypes.typepackageinfo IS
		cmethodname CONSTANT VARCHAR2(100) := cpackage_name || '.GetPackageInfo';
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

	PROCEDURE raiseif
	(
		pcondition IN BOOLEAN
	   ,pmessage   IN VARCHAR2
	) IS
	BEGIN
		IF pcondition
		THEN
			error.raiseerror(pmessage);
		END IF;
	END raiseif;

	FUNCTION addentry
	(
		pentryno       IN OUT NUMBER
	   ,pdebitaccount  IN OUT taccount%ROWTYPE
	   ,pcreditaccount IN OUT taccount%ROWTYPE
	   ,pentcode       IN NUMBER
	   ,pcurrencysum   IN NUMBER
	   ,pvalue         IN NUMBER
	   ,pshortrem      IN VARCHAR := NULL
	   ,pexchangeid    IN NUMBER := NULL
	   ,pcheckavl      IN NUMBER := NULL
	   ,pfullremark    IN tentry.fullremark%TYPE := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.AddEntry[1]';
		vret        NUMBER;
		vexchangeid NUMBER;
		ventryno    NUMBER;
		voperdate   DATE;
	BEGIN
		voperdate := seance.getoperdate();
		ventryno  := nvl(pentryno, 0);
		t.inpar('pFullRemark', pfullremark);
		s.say(cmethod_name || ': entry no ' || ventryno, csay_level);
	
		IF ventryno = 0
		THEN
			contracttypeschema.saadjusting.delete;
		END IF;
	
		vdebitcurrency  := account.getcurrencybyaccountno(pdebitaccount.accountno);
		vcreditcurrency := account.getcurrencybyaccountno(pcreditaccount.accountno);
		s.say(cmethod_name || ': debit ' || pdebitaccount.accountno || ' (' || vdebitcurrency ||
			  ') credit ' || pcreditaccount.accountno || ' (' || vcreditcurrency || ')'
			 ,csay_level);
	
		vexchangeid := nvl(pexchangeid, exchangerate.getdefaultexchange());
		s.say(cmethod_name || ': rate exchange id ' || vexchangeid, csay_level);
	
		IF vdebitcurrency != vcreditcurrency
		THEN
			s.say(cmethod_name || ': different currencies', csay_level);
			vret := exchangerate.prepareentry(vdebitcurrency
											 ,vcreditcurrency
											 ,pcurrencysum
											 ,pvalue
											 ,vexchangeid
											 ,voperdate);
			IF vret != 0
			THEN
				RETURN vret;
			END IF;
		
			ventryno := ventryno + 1;
			contracttypeschema.saadjusting(ventryno).no := ventryno;
			contracttypeschema.saadjusting(ventryno).debit := pdebitaccount.accountno;
			contracttypeschema.saadjusting(ventryno).credit := exchangerate.sconvertpassive;
			contracttypeschema.saadjusting(ventryno).value := exchangerate.ssummafrom;
			contracttypeschema.saadjusting(ventryno).entcode := pentcode;
			IF pshortrem IS NOT NULL
			THEN
				contracttypeschema.saadjusting(ventryno).shortremark := pshortrem;
			END IF;
			contracttypeschema.saadjusting(ventryno).fullremark := pfullremark;
			contracttypeschema.saadjusting(ventryno).flagcheckavl := pcheckavl;
			contracttypeschema.saadjusting(ventryno).entident := referenceentry.getident(pentcode);
		
			s.say(cmethod_name || ': ' || pdebitaccount.accountno || ' -> ' ||
				  exchangerate.sconvertpassive || ' for ' || exchangerate.ssummafrom
				 ,csay_level);
		
			ventryno := ventryno + 1;
			contracttypeschema.saadjusting(ventryno).no := ventryno;
			contracttypeschema.saadjusting(ventryno).debit := exchangerate.sconvertactive;
			contracttypeschema.saadjusting(ventryno).credit := pcreditaccount.accountno;
			contracttypeschema.saadjusting(ventryno).value := exchangerate.ssummato;
			contracttypeschema.saadjusting(ventryno).entcode := pentcode;
			IF pshortrem IS NOT NULL
			THEN
				contracttypeschema.saadjusting(ventryno).shortremark := pshortrem;
			END IF;
			contracttypeschema.saadjusting(ventryno).fullremark := pfullremark;
			contracttypeschema.saadjusting(ventryno).flagcheckavl := pcheckavl;
			contracttypeschema.saadjusting(ventryno).entident := referenceentry.getident(pentcode);
		
			s.say(cmethod_name || ': ' || exchangerate.sconvertactive || ' -> ' ||
				  pcreditaccount.accountno || ' for ' || exchangerate.ssummato
				 ,csay_level);
		
			IF exchangerate.sdifffrom IS NOT NULL
			THEN
				ventryno := ventryno + 1;
				contracttypeschema.saadjusting(ventryno).no := ventryno;
				contracttypeschema.saadjusting(ventryno).debit := exchangerate.sdifffrom;
				contracttypeschema.saadjusting(ventryno).credit := exchangerate.sdiffto;
				contracttypeschema.saadjusting(ventryno).value := exchangerate.sdiffsumma;
				contracttypeschema.saadjusting(ventryno).entcode := pentcode;
				contracttypeschema.saadjusting(ventryno).shortremark := 'R/m';
				contracttypeschema.saadjusting(ventryno).flagcheckavl := pcheckavl;
				contracttypeschema.saadjusting(ventryno).entident := referenceentry.getident(pentcode);
			
				s.say(cmethod_name || ': ' || exchangerate.sdifffrom || ' -> ' ||
					  exchangerate.sdiffto || ' for ' || exchangerate.sdiffsumma
					 ,csay_level);
			END IF;
		
			pdebitaccount.remain  := pdebitaccount.remain - exchangerate.ssummafrom;
			pcreditaccount.remain := pcreditaccount.remain + exchangerate.ssummato;
		ELSE
			s.say(cmethod_name || ': same currencies', csay_level);
		
			IF vdebitcurrency != pcurrencysum
			   AND vcreditcurrency != pcurrencysum
			THEN
				vret := exchangerate.prepareentry(vdebitcurrency
												 ,vcreditcurrency
												 ,pcurrencysum
												 ,pvalue
												 ,vexchangeid
												 ,voperdate);
				IF vret != 0
				THEN
					RETURN vret;
				END IF;
			
				ventryno := ventryno + 1;
				contracttypeschema.saadjusting(ventryno).no := ventryno;
				contracttypeschema.saadjusting(ventryno).debit := pdebitaccount.accountno;
				contracttypeschema.saadjusting(ventryno).credit := pcreditaccount.accountno;
				contracttypeschema.saadjusting(ventryno).value := exchangerate.ssummato;
				contracttypeschema.saadjusting(ventryno).entcode := pentcode;
				IF pshortrem IS NOT NULL
				THEN
					contracttypeschema.saadjusting(ventryno).shortremark := pshortrem;
				END IF;
				contracttypeschema.saadjusting(ventryno).fullremark := pfullremark;
				contracttypeschema.saadjusting(ventryno).flagcheckavl := pcheckavl;
				contracttypeschema.saadjusting(ventryno).entident := referenceentry.getident(pentcode);
			
				s.say(cmethod_name || ': ' || pdebitaccount.accountno || '->' ||
					  pcreditaccount.accountno || ' for ' || exchangerate.ssummato
					 ,csay_level);
			
				pdebitaccount.remain  := pdebitaccount.remain - exchangerate.ssummato;
				pcreditaccount.remain := pcreditaccount.remain + exchangerate.ssummato;
			ELSE
				ventryno := ventryno + 1;
				contracttypeschema.saadjusting(ventryno).no := ventryno;
				contracttypeschema.saadjusting(ventryno).debit := pdebitaccount.accountno;
				contracttypeschema.saadjusting(ventryno).credit := pcreditaccount.accountno;
				contracttypeschema.saadjusting(ventryno).value := pvalue;
				contracttypeschema.saadjusting(ventryno).entcode := pentcode;
				IF pshortrem IS NOT NULL
				THEN
					contracttypeschema.saadjusting(ventryno).shortremark := pshortrem;
				END IF;
				contracttypeschema.saadjusting(ventryno).fullremark := pfullremark;
				contracttypeschema.saadjusting(ventryno).flagcheckavl := pcheckavl;
				contracttypeschema.saadjusting(ventryno).entident := referenceentry.getident(pentcode);
			
				s.say(cmethod_name || ': ' || pdebitaccount.accountno || ' -> ' ||
					  pcreditaccount.accountno || ' for ' || pvalue
					 ,csay_level);
			
				pdebitaccount.remain  := pdebitaccount.remain - contracttypeschema.saadjusting(ventryno)
										.value;
				pcreditaccount.remain := pcreditaccount.remain + contracttypeschema.saadjusting(ventryno)
										.value;
			END IF;
		END IF;
	
		pentryno := ventryno;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END addentry;

	FUNCTION addentry
	(
		pcontractrow   IN tcontract%ROWTYPE
	   ,pentryno       IN OUT NUMBER
	   ,pdebitaccount  IN OUT taccountrecord
	   ,pcreditaccount IN OUT taccountrecord
	   ,pentcode       IN NUMBER
	   ,pcurrencysum   IN NUMBER
	   ,pvalue         IN NUMBER
	   ,pshortrem      IN VARCHAR := NULL
	   ,pexchangeid    IN NUMBER := NULL
	   ,pcheckavl      IN NUMBER := NULL
	   ,pwriterollback IN BOOLEAN := FALSE
	   ,pfullremark    IN tentry.fullremark%TYPE := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.AddEntry[2]';
		vdebitaccount  taccount%ROWTYPE;
		vcreditaccount taccount%ROWTYPE;
		vret           NUMBER;
	BEGIN
		IF pdebitaccount.accountno IS NULL
		THEN
			createaccountbycode(pcontractrow, pdebitaccount, pwriterollback);
		END IF;
		IF pcreditaccount.accountno IS NULL
		THEN
			createaccountbycode(pcontractrow, pcreditaccount, pwriterollback);
		END IF;
	
		copystruct(pdebitaccount, vdebitaccount);
		copystruct(pcreditaccount, vcreditaccount);
		vret := addentry(pentryno
						,vdebitaccount
						,vcreditaccount
						,pentcode
						,pcurrencysum
						,pvalue
						,pshortrem
						,pexchangeid
						,pcheckavl
						,pfullremark);
	
		copystruct(vdebitaccount, pdebitaccount);
		copystruct(vcreditaccount, pcreditaccount);
	
		RETURN vret;
	EXCEPTION
		WHEN usererror THEN
			RETURN err.geterrorcode();
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END addentry;

	FUNCTION addentry
	(
		pdocno              IN OUT NUMBER
	   ,pentryno            IN OUT NUMBER
	   ,pdebitaccount       IN VARCHAR
	   ,pcreditaccount      IN VARCHAR
	   ,pentcode            IN NUMBER
	   ,pcurrencysum        IN NUMBER
	   ,pvalue              IN NUMBER
	   ,pshortrem           IN VARCHAR := NULL
	   ,pexchangeid         IN NUMBER := NULL
	   ,pcheckavl           IN NUMBER := entry.flcheck
	   ,ptrandate           IN DATE := NULL
	   ,pfullrem            IN VARCHAR := NULL
	   ,pdebitpriority      IN NUMBER := entry.use_twcms
	   ,pcreditpriority     IN NUMBER := entry.use_twcms
	   ,ponlinedebitacc     IN VARCHAR := NULL
	   ,ponlinecreditacc    IN VARCHAR := NULL
	   ,pdebithandle        IN NUMBER := NULL
	   ,pcredithandle       IN NUMBER := NULL
	   ,pdebitusebonusdebt  IN BOOLEAN := TRUE
	   ,pcreditusebonusdebt IN BOOLEAN := TRUE
	   ,pneednotify         IN BOOLEAN := TRUE
	   ,pfimicomment        IN VARCHAR2 := NULL
	   ,pcheckcredit        IN NUMBER := NULL
	   ,pneednotifycredit   IN BOOLEAN := NULL
	   ,pfimicommentcredit  IN VARCHAR := NULL
	   ,pparentdocno        IN NUMBER := NULL
	   ,pcreatedocument     IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.AddEntry[3]';
	
		ventident treferenceentry.ident%TYPE;
	
		vdebitaccount  taccount%ROWTYPE;
		vcreditaccount taccount%ROWTYPE;
	BEGIN
		vdebitaccount.accountno  := pdebitaccount;
		vcreditaccount.accountno := pcreditaccount;
	
		ventident := referenceentry.getident(pentcode);
		IF ventident IS NULL
		THEN
			error.raisewhenerr();
		END IF;
	
		RETURN addentry(pdocno              => pdocno
					   ,pentryno            => pentryno
					   ,pdebitaccount       => vdebitaccount
					   ,pcreditaccount      => vcreditaccount
					   ,pcurrencysum        => pcurrencysum
					   ,pvalue              => pvalue
					   ,pentident           => ventident
					   ,prem                => pshortrem
					   ,pexchangeid         => pexchangeid
					   ,pcheckavl           => pcheckavl
					   ,pfullrem            => pfullrem
					   ,pdebitpriority      => pdebitpriority
					   ,pcreditpriority     => pcreditpriority
					   ,ponlinedebitacc     => ponlinedebitacc
					   ,ponlinecreditacc    => ponlinecreditacc
					   ,pdebithandle        => pdebithandle
					   ,pcredithandle       => pcredithandle
					   ,pdebitusebonusdebt  => pdebitusebonusdebt
					   ,pcreditusebonusdebt => pcreditusebonusdebt
					   ,pneednotify         => pneednotify
					   ,pfimicomment        => pfimicomment
					   ,pcheckcredit        => pcheckcredit
					   ,pneednotifycredit   => pneednotifycredit
					   ,pfimicommentcredit  => pfimicommentcredit
					   ,pvaluedate          => ptrandate
					   ,pparentdocno        => pparentdocno
					   ,pcreatedocument     => pcreatedocument);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			freeaccountobjects();
			RAISE;
	END addentry;

	FUNCTION addentry
	(
		pdocno              IN OUT NUMBER
	   ,pentryno            IN OUT NUMBER
	   ,pdebitaccount       IN OUT taccount%ROWTYPE
	   ,pcreditaccount      IN OUT taccount%ROWTYPE
	   ,pcurrencysum        IN NUMBER
	   ,pvalue              IN NUMBER
	   ,pentident           IN VARCHAR
	   ,prem                IN VARCHAR := NULL
	   ,pexchangeid         IN NUMBER := NULL
	   ,pcheckavl           IN NUMBER := entry.flcheck
	   ,pfullrem            IN VARCHAR := NULL
	   ,pdebitpriority      IN NUMBER := entry.use_twcms
	   ,pcreditpriority     IN NUMBER := entry.use_twcms
	   ,ponlinedebitacc     IN VARCHAR := NULL
	   ,ponlinecreditacc    IN VARCHAR := NULL
	   ,pdebithandle        IN NUMBER := NULL
	   ,pcredithandle       IN NUMBER := NULL
	   ,pdebitusebonusdebt  IN BOOLEAN := TRUE
	   ,pcreditusebonusdebt IN BOOLEAN := TRUE
	   ,pneednotify         IN BOOLEAN := TRUE
	   ,pfimicomment        IN VARCHAR2 := NULL
	   ,pcheckcredit        IN NUMBER := NULL
	   ,pneednotifycredit   IN BOOLEAN := NULL
	   ,pfimicommentcredit  IN VARCHAR := NULL
	   ,pvaluedate          IN DATE := NULL
	   ,poperdate           IN DATE := NULL
	   ,pskipdiffentry      IN BOOLEAN := FALSE
	   ,pparentdocno        IN NUMBER := NULL
	   ,pcreatedocument     IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddEntry[4]';
	
		vexchangeid NUMBER;
		voperdate   DATE;
		ventryno    NUMBER;
	
		vvaluedate    DATE := nvl(pvaluedate, SYSDATE);
		ventrygroupid toperationratesext.entrygroupid%TYPE;
		vdebitamount  NUMBER;
		vcreditamount NUMBER;
	
	BEGIN
		t.enter(cmethod_name
			   ,'for ' || pvalue || ' (' || pcurrencysum || ') with ident ' || pentident
			   ,csay_level);
		t.inpar('pValueDate', htools.d2s(pvaluedate), csay_level);
		t.inpar('pParentDocNo', pparentdocno);
	
		t.var('vValueDate', htools.d2s(vvaluedate), csay_level);
	
		voperdate := nvl(poperdate, seance.getoperdate());
		t.var('vOperDate', voperdate);
	
		ventryno := nvl(pentryno, 0);
	
		sdebitaccountno := pdebitaccount.accountno;
		t.var('debit account no', sdebitaccountno, csay_level);
		screditaccountno := pcreditaccount.accountno;
		t.var('credit account no', screditaccountno, csay_level);
	
		IF pdebithandle IS NOT NULL
		THEN
			sdebitaccount      := pdebithandle;
			sdonotfreedebitacc := TRUE;
		ELSE
			openhandle(sdebitaccount, sdebitaccountno, 'E');
		END IF;
	
		IF pcredithandle IS NOT NULL
		THEN
			screditaccount      := pcredithandle;
			sdonotfreecreditacc := TRUE;
		ELSE
			openhandle(screditaccount, screditaccountno, 'E');
		END IF;
		t.var('debit account handle', sdebitaccount, csay_level);
		t.var('credit account handle', screditaccount, csay_level);
	
		vexchangeid := pexchangeid;
		IF vexchangeid IS NULL
		THEN
			vexchangeid := exchangerate.getdefaultexchange();
		END IF;
		t.var('vExchangeId', vexchangeid);
		t.var('pCreateDocument', t.b2t(pcreatedocument));
	
		IF entry.addentries(pcheck           => nvl(pcheckavl, entry.flcheck)
						   ,podocno          => pdocno
						   ,pdoctype         => referencedoctype.typenone
						   ,pdocdate         => voperdate
						   ,pdocvalue        => 0
						   ,pono             => pentryno
						   ,pentdate         => vvaluedate
						   ,pentvalue        => pvalue
						   ,pentcurrency     => pcurrencysum
						   ,pexchangeid      => vexchangeid
						   ,pexratedate      => trunc(voperdate)
						   ,pentident        => pentident
						   ,pdebitacchandle  => sdebitaccount
						   ,paddentcode      => NULL
						   ,pcreditacchandle => screditaccount
						   ,pshortremark     => prem
						   ,pfullremark      => pfullrem
						   ,
							
							pparentdocno => pparentdocno
						   ,
							
							pdebitpriority  => nvl(pdebitpriority, entry.use_twcms)
						   ,pcreditpriority => nvl(pcreditpriority, entry.use_twcms)
						   ,ponlinedebitacc => ponlinedebitacc
						   ,
							
							ponlinecreditacc => ponlinecreditacc
						   ,
							
							pcreatedocument => pcreatedocument
						   ,
							
							pdebitusebonusdebt  => nvl(pdebitusebonusdebt, TRUE)
						   ,pcreditusebonusdebt => nvl(pcreditusebonusdebt, TRUE)
						   ,pneednotify         => nvl(pneednotify, TRUE)
						   ,pfimicomment        => pfimicomment
						   ,pcheckcredit        => pcheckcredit
						   ,pneednotifycredit   => pneednotifycredit
						   ,pfimicommentcredit  => pfimicommentcredit
						   ,
							
							poentrygroupid => ventrygroupid
						   ,
							
							pskipdiffentry => nvl(pskipdiffentry, FALSE)
						   ,odebitamount   => vdebitamount
						   ,ocreditamount  => vcreditamount) != 0
		THEN
			error.raisewhenerr();
		END IF;
	
		t.var('pEntryNo', pentryno);
		WHILE ventryno < pentryno
		LOOP
			ventryno := ventryno + 1;
			contracttypeschema.saentry(ventryno).docno := pdocno;
			contracttypeschema.saentry(ventryno).no := ventryno;
		END LOOP;
	
		pdebitaccount.remain  := pdebitaccount.remain - vdebitamount;
		pcreditaccount.remain := pcreditaccount.remain + vcreditamount;
	
		freeaccountobjects();
		t.leave(cmethod_name, plevel => csay_level);
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			freeaccountobjects();
			RAISE;
	END addentry;

	FUNCTION addentry
	(
		pcontractrow        IN tcontract%ROWTYPE
	   ,pdocno              IN OUT NUMBER
	   ,pentryno            IN OUT NUMBER
	   ,pdebitaccount       IN OUT taccountrecord
	   ,pcreditaccount      IN OUT taccountrecord
	   ,pcurrencysum        IN NUMBER
	   ,pvalue              IN NUMBER
	   ,pentident           IN VARCHAR
	   ,prem                IN VARCHAR := NULL
	   ,pexchangeid         IN NUMBER := NULL
	   ,pcheckavl           IN NUMBER := entry.flcheck
	   ,pfullrem            IN VARCHAR := NULL
	   ,pdebitpriority      IN NUMBER := entry.use_twcms
	   ,pcreditpriority     IN NUMBER := entry.use_twcms
	   ,ponlinedebitacc     IN VARCHAR := NULL
	   ,ponlinecreditacc    IN VARCHAR := NULL
	   ,pwriterollback      IN BOOLEAN := FALSE
	   ,pdebithandle        IN NUMBER := NULL
	   ,pcredithandle       IN NUMBER := NULL
	   ,pdebitusebonusdebt  IN BOOLEAN := TRUE
	   ,pcreditusebonusdebt IN BOOLEAN := TRUE
	   ,pneednotify         IN BOOLEAN := TRUE
	   ,pfimicomment        IN VARCHAR2 := NULL
	   ,
		
		pcheckcredit      IN NUMBER := NULL
	   ,pneednotifycredit IN BOOLEAN := NULL
	   ,
		
		pfimicommentcredit IN VARCHAR2 := NULL
	   ,pvaluedate         IN DATE := NULL
	   ,
		
		poperdate      IN DATE := NULL
	   ,pskipdiffentry IN BOOLEAN := FALSE
	   ,ptaglist       IN contracttypeschema.typeremarktaglist := cemptytaglist
	   ,
		
		pparentdocno    IN NUMBER := NULL
	   ,pcreatedocument IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddEntry[5]';
		vdebitaccount   taccount%ROWTYPE;
		vcreditaccount  taccount%ROWTYPE;
		vcreditpriority NUMBER := pcreditpriority;
		vdebitpriority  NUMBER := pdebitpriority;
		vret            NUMBER;
		vremark         treferenceremarkprofile.fullremark%TYPE;
		vremarkparams   contractentryremark.typeremarkparams;
	BEGIN
	
		t.enter(cmethod_name, 'debit account no ' || pdebitaccount.accountno, csay_level);
	
		IF pdebitaccount.accountno IS NULL
		THEN
			createaccountbycode(pcontractrow, pdebitaccount, pwriterollback);
		END IF;
	
		s.say(cmethod_name || ': credit account no ' || pcreditaccount.accountno, csay_level);
		IF pcreditaccount.accountno IS NULL
		THEN
			createaccountbycode(pcontractrow, pcreditaccount, pwriterollback);
		END IF;
	
		copystruct(pdebitaccount, vdebitaccount);
		copystruct(pcreditaccount, vcreditaccount);
	
		vremark := pfullrem;
		IF pfullrem IS NULL
		THEN
		
			vremarkparams.contract        := pcontractrow;
			vremarkparams.entryident      := pentident;
			vremarkparams.entrycode       := referenceentry.getcode(pentident);
			vremarkparams.debitaccountno  := vdebitaccount.accountno;
			vremarkparams.creditaccountno := vcreditaccount.accountno;
		
			vremarkparams.entrydocno := pdocno;
			vremarkparams.entryno    := pentryno;
		
			vremark := contractentryremark.getremarkbyno(vremarkparams, ptaglist);
		END IF;
	
		vret := addentry(pdocno
						,pentryno
						,vdebitaccount
						,vcreditaccount
						,pcurrencysum
						,pvalue
						,pentident
						,prem
						,pexchangeid
						,pcheckavl
						,pfullrem => vremark
						,
						 
						 pcreditpriority     => vcreditpriority
						,pdebitpriority      => vdebitpriority
						,ponlinedebitacc     => ponlinedebitacc
						,ponlinecreditacc    => ponlinecreditacc
						,pdebithandle        => pdebithandle
						,pcredithandle       => pcredithandle
						,pdebitusebonusdebt  => pdebitusebonusdebt
						,pcreditusebonusdebt => pcreditusebonusdebt
						,pneednotify         => pneednotify
						,pfimicomment        => pfimicomment
						,
						 
						 pcheckcredit      => pcheckcredit
						,pneednotifycredit => pneednotifycredit
						,
						 
						 pfimicommentcredit => pfimicommentcredit
						,pvaluedate         => nvl(pvaluedate, SYSDATE)
						,
						 
						 poperdate      => poperdate
						,pskipdiffentry => nvl(pskipdiffentry, FALSE)
						,
						 
						 pparentdocno    => pparentdocno
						,pcreatedocument => pcreatedocument);
	
		copystruct(vdebitaccount, pdebitaccount);
		copystruct(vcreditaccount, pcreditaccount);
	
		t.leave(cmethod_name, 'vRet=' || vret, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
		
			error.save(cmethod_name);
			RAISE;
	END addentry;

	FUNCTION addentrybysum
	(
		pdocno             IN NUMBER
	   ,pentryno           IN OUT NUMBER
	   ,pdebitaccount      IN VARCHAR
	   ,pcreditaccount     IN VARCHAR
	   ,pentcode           IN NUMBER
	   ,pdebitcurrency     IN NUMBER
	   ,pdebitvalue        IN NUMBER
	   ,pcreditcurrency    IN NUMBER
	   ,pcreditvalue       IN NUMBER
	   ,pshortrem          IN VARCHAR := NULL
	   ,pcheckavl          IN NUMBER := entry.flcheck
	   ,pfullrem           IN VARCHAR := NULL
	   ,pcheckcredit       IN NUMBER := NULL
	   ,pneednotifycredit  IN BOOLEAN := NULL
	   ,pfimicommentcredit IN VARCHAR := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.AddEntryBySum';
		ventident treferenceentry.ident%TYPE;
		voperdate DATE;
		ventryno  NUMBER;
	BEGIN
		voperdate := seance.getoperdate();
		ventryno  := nvl(pentryno, 0);
	
		sdebitaccountno  := pdebitaccount;
		screditaccountno := pcreditaccount;
		s.say(cmethod_name || ': debit account no ' || sdebitaccountno || ' credit account no ' ||
			  screditaccountno
			 ,csay_level);
	
		openhandle(sdebitaccount, sdebitaccountno, 'E');
		openhandle(screditaccount, screditaccountno, 'E');
		s.say(cmethod_name || ': debit account handle ' || sdebitaccount ||
			  'credit account handle ' || screditaccount
			 ,csay_level);
	
		vdebitcurrency  := pdebitcurrency;
		vcreditcurrency := pcreditcurrency;
	
		ventident := referenceentry.getident(pentcode);
		IF ventident IS NULL
		THEN
			error.raisewhenerr();
		END IF;
	
		IF vdebitcurrency != vcreditcurrency
		THEN
			s.say(cmethod_name || ': different currencies', csay_level);
			IF exchangerate.prepareentrybysum(pdebitvalue
											 ,vdebitcurrency
											 ,pcreditvalue
											 ,vcreditcurrency
											 ,voperdate) != 0
			THEN
				error.raisewhenerr();
			END IF;
		
			openhandle(sactiveconvertaccount, exchangerate.sconvertactive, 'E');
			openhandle(spassiveconvertaccount, exchangerate.sconvertpassive, 'E');
			s.say(cmethod_name || ': conversion active account handle ' || sactiveconvertaccount ||
				  ' conversion passive account handle'
				 ,csay_level);
		
			ventryno := ventryno + 1;
			IF entry.add(pcheckavl
						,pdocno
						,0
						,voperdate
						,0
						,ventryno
						,SYSDATE
						,exchangerate.ssummafrom
						,ventident
						,sdebitaccount
						,NULL
						,spassiveconvertaccount
						,pshortrem
						,pfullrem) != 0
			THEN
				error.raisewhenerr();
			END IF;
			s.say(cmethod_name || ': debit to conversion passive for ' || exchangerate.ssummafrom
				 ,csay_level);
		
			contracttypeschema.saentry(ventryno).docno := pdocno;
			contracttypeschema.saentry(ventryno).no := ventryno;
		
			ventryno := ventryno + 1;
			IF entry.add(pcheckavl
						,pdocno
						,0
						,voperdate
						,0
						,ventryno
						,SYSDATE
						,exchangerate.ssummato
						,ventident
						,sactiveconvertaccount
						,NULL
						,screditaccount
						,pshortrem
						,pfullrem
						,pcheckcredit          => pcheckcredit
						,pneednotifycredit     => pneednotifycredit
						,pfimicommentcredit    => pfimicommentcredit) != 0
			THEN
				error.raisewhenerr();
			END IF;
			s.say(cmethod_name || ': conversion active to credit for ' || exchangerate.ssummato
				 ,csay_level);
		
			contracttypeschema.saentry(ventryno).docno := pdocno;
			contracttypeschema.saentry(ventryno).no := ventryno;
		
			IF exchangerate.sdifffrom IS NOT NULL
			THEN
				openhandle(sdifffromaccount, exchangerate.sdifffrom, 'E');
				openhandle(sdifftoaccount, exchangerate.sdiffto, 'E');
				s.say(cmethod_name || ': difference from account ' || sdifffromaccount ||
					  ' difference to account ' || sdifftoaccount
					 ,csay_level);
			
				ventryno := ventryno + 1;
				IF entry.add(pcheckavl
							,pdocno
							,0
							,voperdate
							,0
							,ventryno
							,SYSDATE
							,exchangerate.sdiffsumma
							,ventident
							,sdifffromaccount
							,NULL
							,sdifftoaccount
							,'R/m'
							,pfullrem) != 0
				THEN
					error.raisewhenerr();
				END IF;
				s.say(cmethod_name || ': move difference for ' || exchangerate.sdiffsumma
					 ,csay_level);
			
				contracttypeschema.saentry(ventryno).docno := pdocno;
				contracttypeschema.saentry(ventryno).no := ventryno;
			END IF;
		ELSE
			s.say(cmethod_name || ': same currencies', csay_level);
		
			ventryno := ventryno + 1;
			IF entry.add(pcheckavl
						,pdocno
						,0
						,voperdate
						,0
						,ventryno
						,SYSDATE
						,pdebitvalue
						,ventident
						,sdebitaccount
						,NULL
						,screditaccount
						,pshortrem
						,pfullrem
						,pcheckcredit       => pcheckcredit
						,pneednotifycredit  => pneednotifycredit
						,pfimicommentcredit => pfimicommentcredit) != 0
			THEN
				error.raisewhenerr();
			END IF;
			s.say(cmethod_name || ': debit to credit for ' || pdebitvalue, csay_level);
		
			contracttypeschema.saentry(ventryno).docno := pdocno;
			contracttypeschema.saentry(ventryno).no := ventryno;
		END IF;
	
		freeaccountobjects();
	
		pentryno := ventryno;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			freeaccountobjects();
			RAISE;
	END addentrybysum;

	FUNCTION addentryfast
	(
		pcontractrow    IN tcontract%ROWTYPE
	   ,pdocno          IN OUT NUMBER
	   ,pentryno        IN OUT NUMBER
	   ,pdebitaccount   IN OUT taccountrecord
	   ,pcreditaccount  IN OUT taccountrecord
	   ,pcurrencysum    IN NUMBER
	   ,pvalue          IN NUMBER
	   ,pentcode        IN NUMBER
	   ,pshortrem       IN VARCHAR := NULL
	   ,pexchangeid     IN NUMBER := NULL
	   ,pcheckavl       IN NUMBER := entry.flnocheck
	   ,pfullrem        IN VARCHAR := NULL
	   ,pwriterollback  IN BOOLEAN := FALSE
	   ,pdebithandle    IN NUMBER := NULL
	   ,pcredithandle   IN NUMBER := NULL
	   ,pvaluedate      IN DATE := NULL
	   ,poperdate       IN DATE := NULL
	   ,pskipdiffentry  IN BOOLEAN := FALSE
	   ,ptaglist        IN contracttypeschema.typeremarktaglist := cemptytaglist
	   ,pparentdocno    IN NUMBER := NULL
	   ,pcreatedocument IN BOOLEAN := FALSE
	) RETURN NUMBER
	
	 IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.AddEntryFast';
		vret NUMBER;
	
		ventident treferenceentry.ident%TYPE;
	
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
	
		t.note(cmethod_name, ' docno ' || pdocno || ' entry no ' || pentryno, csay_level);
		t.note(cmethod_name
			  ,'debit account ' || pdebitaccount.accountno || ' (h ' || pdebithandle || ')' ||
			   ' credit account ' || pcreditaccount.accountno || ' (h ' || pcredithandle || ')'
			  ,csay_level);
	
		ventident := referenceentry.getident(pentcode);
		IF ventident IS NULL
		THEN
			error.raisewhenerr();
		END IF;
		t.var('vEntIdent', ventident);
	
		vret := addentry(pcontractrow   => pcontractrow
						,pdocno         => pdocno
						,pentryno       => pentryno
						,pdebitaccount  => pdebitaccount
						,pcreditaccount => pcreditaccount
						,pcurrencysum   => pcurrencysum
						,pvalue         => pvalue
						,pentident      => ventident
						,prem           => pshortrem
						,pexchangeid    => pexchangeid
						,pcheckavl      => nvl(pcheckavl, entry.flnocheck)
						,pfullrem       => pfullrem
						,
						 
						 pwriterollback => nvl(pwriterollback, FALSE)
						,pdebithandle   => pdebithandle
						,pcredithandle  => pcredithandle
						,
						 
						 pvaluedate      => pvaluedate
						,poperdate       => poperdate
						,pskipdiffentry  => pskipdiffentry
						,ptaglist        => ptaglist
						,pparentdocno    => pparentdocno
						,pcreatedocument => pcreatedocument);
	
		t.var('vRet', vret);
		IF vret != 0
		THEN
			error.raisewhenerr();
		END IF;
		t.var('pEntryNo', pentryno);
	
		t.leave(cmethod_name, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END addentryfast;

	FUNCTION addentry2reference
	(
		pident       IN VARCHAR2
	   ,pbasecode    IN CHAR
	   ,pname        VARCHAR2
	   ,pshortremark IN VARCHAR2 := NULL
	) RETURN NUMBER IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddEntry2Reference2';
		vret NUMBER;
	BEGIN
		err.seterror(0, cmethod_name);
		vret := referenceentry.addentry(pident, pbasecode, pname, pshortremark);
		IF err.geterrorcode() NOT IN (0, err.refentry_duplicate_ident)
		THEN
			error.raiseerror(err.geterrorcode
							,'Error adding entry with ID "' || pident || '": ' ||
							 err.getfullmessage());
		ELSE
			err.seterror(0, cmethod_name);
		END IF;
		COMMIT;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE addentry2reference
	(
		pident       VARCHAR
	   ,pbasecode    CHAR
	   ,pname        VARCHAR
	   ,pshortremark IN VARCHAR2 := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.AddEntry2Reference';
		vdummy NUMBER;
	BEGIN
		vdummy := addentry2reference(pident, pbasecode, pname, pshortremark);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END addentry2reference;

	PROCEDURE openhandle
	(
		phandle    IN OUT NUMBER
	   ,paccountno IN VARCHAR
	   ,pmod       IN CHAR := 'W'
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.OpenHandle';
	BEGIN
		phandle := existacchandle(paccountno);
		IF phandle = 0
		THEN
			phandle := account.newobject(paccountno, pmod);
			IF phandle = 0
			THEN
				error.raisewhenerr();
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END openhandle;

	PROCEDURE freeaccountobjects IS
	BEGIN
		freehandle(sdebitaccount, sdonotfreedebitacc);
		freehandle(screditaccount, sdonotfreecreditacc);
		freehandle(sactiveconvertaccount);
		freehandle(spassiveconvertaccount);
		freehandle(sdifffromaccount);
		freehandle(sdifftoaccount);
	
		sdonotfreedebitacc  := FALSE;
		sdonotfreecreditacc := FALSE;
	END freeaccountobjects;

	PROCEDURE freehandle
	(
		phandle    IN OUT NUMBER
	   ,pdonotfree IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FreeHandle';
		vno NUMBER;
	BEGIN
		IF nvl(phandle, 0) = 0
		THEN
			RETURN;
		END IF;
	
		vno := phandle;
		IF NOT pdonotfree
		THEN
			account.freeobject(phandle);
		END IF;
	
		CASE vno
			WHEN sdebitaccount THEN
				sdebitaccount := 0;
			WHEN screditaccount THEN
				screditaccount := 0;
			WHEN sactiveconvertaccount THEN
				sactiveconvertaccount := 0;
			WHEN spassiveconvertaccount THEN
				spassiveconvertaccount := 0;
			WHEN sdifffromaccount THEN
				sdifffromaccount := 0;
			WHEN sdifftoaccount THEN
				sdifftoaccount := 0;
			ELSE
				NULL;
		END CASE;
		phandle := 0;
	END freehandle;

	FUNCTION existacchandle(paccountno IN VARCHAR) RETURN NUMBER IS
	BEGIN
		IF (paccountno = sdebitaccountno)
		   AND (sdebitaccount != 0)
		THEN
			RETURN sdebitaccount;
		ELSIF (paccountno = screditaccountno)
			  AND (screditaccount != 0)
		THEN
			RETURN screditaccount;
		ELSIF (paccountno = exchangerate.sconvertactive)
			  AND (sactiveconvertaccount != 0)
		THEN
			RETURN sactiveconvertaccount;
		ELSIF (paccountno = exchangerate.sconvertpassive)
			  AND (spassiveconvertaccount != 0)
		THEN
			RETURN spassiveconvertaccount;
		ELSIF (paccountno = exchangerate.sdifffrom)
			  AND (sdifffromaccount != 0)
		THEN
			RETURN sdifffromaccount;
		ELSIF (paccountno = exchangerate.sdiffto)
			  AND (sdifftoaccount != 0)
		THEN
			RETURN sdifftoaccount;
		END IF;
	
		RETURN 0;
	END existacchandle;

	FUNCTION updateaccount(paccountno VARCHAR) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.UpdateAccount';
		vaccounthandle NUMBER;
	BEGIN
		s.say(cmethod_name || ': ' || paccountno, csay_level);
	
		vaccounthandle := account.newobject(paccountno, 'W');
		IF vaccounthandle = 0
		THEN
			error.raisewhenerr();
		END IF;
	
		account.writeobject(vaccounthandle);
		error.raisewhenerr();
	
		account.freeobject(vaccounthandle);
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			account.freeobject(vaccounthandle);
			RAISE;
	END updateaccount;

	FUNCTION closeaccount
	(
		paccountno IN VARCHAR
	   ,pclosedate IN DATE := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CloseAccount';
		vaccounthandle NUMBER;
	BEGIN
		openhandle(vaccounthandle, paccountno);
	
		IF service.getbit(account.getstat(vaccounthandle), account.stclose) != 1
		THEN
			account.closeanyaccount(vaccounthandle, nvl(pclosedate, seance.getoperdate()));
			error.raisewhenerr();
			account.writeobject(vaccounthandle);
			error.raisewhenerr();
		END IF;
	
		freehandle(vaccounthandle);
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			freehandle(vaccounthandle);
			RAISE;
	END closeaccount;

	FUNCTION closeaccounts
	(
		pcontractno IN VARCHAR
	   ,pclosedate  IN DATE := NULL
	) RETURN NUMBER IS
		vret    NUMBER;
		vbranch NUMBER := seance.getbranch();
	
		CURSOR ccontractaccount(pbranch IN NUMBER) IS
			SELECT i.itemcode
				  ,i.key
			FROM   tcontractitem i
			WHERE  i.branch = pbranch
			AND    i.no = pcontractno;
	BEGIN
		FOR i IN ccontractaccount(vbranch)
		LOOP
			vret := closeaccount(i.key, pclosedate);
			IF vret != 0
			THEN
				RETURN vret;
			END IF;
		END LOOP;
	
		RETURN 0;
	END closeaccounts;

	FUNCTION openaccount(paccountno IN VARCHAR) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.OpenAccount';
		vaccounthandle NUMBER;
	BEGIN
		openhandle(vaccounthandle, paccountno);
	
		IF service.getbit(account.getstat(vaccounthandle), account.stclose) = 1
		THEN
			account.setclosedate(vaccounthandle, NULL);
			error.raisewhenerr();
			account.writeobject(vaccounthandle);
			error.raisewhenerr();
		END IF;
	
		freehandle(vaccounthandle);
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			freehandle(vaccounthandle);
			RAISE;
	END openaccount;

	FUNCTION openaccounts(pcontractno IN VARCHAR) RETURN NUMBER IS
		vret    NUMBER;
		vbranch NUMBER := seance.getbranch();
	
		CURSOR ccontractaccount(pbranch IN NUMBER) IS
			SELECT i.itemcode
				  ,i.key
			FROM   tcontractitem i
			WHERE  i.branch = pbranch
			AND    i.no = pcontractno;
	BEGIN
		FOR i IN ccontractaccount(vbranch)
		LOOP
			vret := openaccount(i.key);
			IF vret != 0
			THEN
				RETURN vret;
			END IF;
		END LOOP;
	
		RETURN 0;
	END openaccounts;

	PROCEDURE savecardstatus
	(
		pcontractno tcontract.no%TYPE
	   ,ppan        tcard.pan%TYPE
	   ,pmbr        tcard.mbr%TYPE
	   ,pstat       tcard.crd_stat%TYPE
	   ,psign       tcard.signstat%TYPE
	) IS
	BEGIN
		contractparams.savechar(contractparams.ccontract
							   ,pcontractno
							   ,ppan || to_char(pmbr)
							   ,pstat || psign
							   ,pmaskmode => contractparams.cmaskkey
							   ,ppan4mask => ppan);
	
	END savecardstatus;

	PROCEDURE loadcardstatus
	(
		pcontractno tcontract.no%TYPE
	   ,ppanmbr     VARCHAR
	   ,pstat       OUT tcard.crd_stat%TYPE
	   ,psign       OUT tcard.signstat%TYPE
	) IS
		vstatsign VARCHAR(10);
		vres      NUMBER;
	BEGIN
		pstat := NULL;
		psign := NULL;
	
		vstatsign := contractparams.loadchar(contractparams.ccontract
											,pcontractno
											,ppanmbr
											,pdoexception             => FALSE
											,pmaskmode                => contractparams.cmaskkey);
		IF vstatsign IS NOT NULL
		THEN
			contractparams.deletevalue(contractparams.ccontract, pcontractno, ppanmbr);
			pstat := substr(vstatsign, 1, 1);
			psign := substr(vstatsign, 2);
		ELSE
			pstat := datamember.getchar(object.gettype(contracttype.object_name)
									   ,contract.gettype(pcontractno)
									   ,'Card_' || ppanmbr);
			vres  := datamember.datamemberdelete(object.gettype(contracttype.object_name)
												,contract.gettype(pcontractno)
												,'Card_' || ppanmbr);
		END IF;
	END loadcardstatus;

	PROCEDURE setcardsignstat
	(
		ppan            tcard.pan%TYPE
	   ,pmbr            tcard.mbr%TYPE
	   ,psign           tcard.signstat%TYPE
	   ,pstat           tcard.crd_stat%TYPE
	   ,pchecktranssign BOOLEAN := TRUE
	   ,pchecktransstat BOOLEAN := TRUE
	   ,pcomment        VARCHAR2 := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SetCardSignStat';
		vcardhandle NUMBER;
	BEGIN
		err.seterror(0, cmethod_name);
		vcardhandle := card.newobject(ppan, pmbr, 'W');
		IF vcardhandle = 0
		THEN
			error.raisewhenerr();
		END IF;
	
		IF psign IS NOT NULL
		THEN
		
			err.seterror(0, cmethod_name);
			card.setsignstat(vcardhandle, psign, pchecktranssign, pcomment);
			IF err.geterrorcode() = err.card_not_allowed_additional
			THEN
			
				t.note(cmethod_name, '[1] ErrCode=CARD_NOT_ALLOWED_ADDITIONAL');
				err.seterror(0, cmethod_name);
			ELSE
				error.raisewhenerr();
			END IF;
		END IF;
	
		IF pstat IS NOT NULL
		THEN
			err.seterror(0, cmethod_name);
			card.setcrd_stat(vcardhandle, pstat, pchecktransstat, pcomment);
			IF err.geterrorcode() = err.card_not_allowed_additional
			THEN
			
				t.note(cmethod_name, '[2] ErrCode=CARD_NOT_ALLOWED_ADDITIONAL');
				err.seterror(0, cmethod_name);
			ELSE
				error.raisewhenerr();
			END IF;
		
		END IF;
		card.writeobject(vcardhandle);
		error.raisewhenerr();
	
		card.freeobject(vcardhandle);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			IF vcardhandle != 0
			THEN
				card.freeobject(vcardhandle);
			END IF;
			RAISE;
	END setcardsignstat;

	FUNCTION closecard
	(
		pcontractno tcontract.no%TYPE
	   ,pcloseall   BOOLEAN := FALSE
	   ,pcomment    VARCHAR2 := NULL
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CloseCard';
		vstat       tcard.crd_stat%TYPE;
		vsign       tcard.signstat%TYPE;
		fcardclosed BOOLEAN := FALSE;
		vcardlist   apitypes.typecardlist;
	BEGIN
		s.say(cmethod_name || ': contract no ' || pcontractno, csay_level);
	
		vcardlist := contract.getcardlist(pcontractno);
		FOR i IN 1 .. vcardlist.count
		LOOP
			vstat := vcardlist(i).pcstat;
			vsign := vcardlist(i).a4mstat;
		
			s.say(cmethod_name || ': card ' || s.maskpan(vcardlist(i).pan) || '-' || vcardlist(i).mbr ||
				  ' stat ' || vstat || ' sign ' || vsign
				 ,csay_level);
		
			IF (pcloseall AND NOT (card.iscardclosed(vcardlist(i).pan, vcardlist(i).mbr)))
			   OR (vstat = referencecrd_stat.card_open)
			THEN
			
				setcardsignstat(vcardlist                   (i).pan
							   ,vcardlist                   (i).mbr
							   ,referencecardsign.cardclosed
							   ,NULL
							   ,TRUE
							   ,TRUE
							   ,pcomment);
				fcardclosed := TRUE;
				savecardstatus(pcontractno, vcardlist(i).pan, vcardlist(i).mbr, vstat, vsign);
				s.say(cmethod_name || ': card closed', csay_level);
			END IF;
		END LOOP;
	
		RETURN fcardclosed;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END closecard;

	FUNCTION unclosecard
	(
		pcontractno tcontract.no%TYPE
	   ,pcomment    VARCHAR2 := NULL
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR(80) := cpackage_name || '.UncloseCard';
	
		vstat         tcard.crd_stat%TYPE := NULL;
		vsign         tcard.signstat%TYPE := NULL;
		fcardunclosed BOOLEAN := FALSE;
		vcardlist     apitypes.typecardlist;
	BEGIN
		s.say(cmethod_name || ': contract no ' || pcontractno, csay_level);
	
		vcardlist := contract.getcardlist(pcontractno);
		FOR i IN 1 .. vcardlist.count
		LOOP
			s.say(cmethod_name || ': card ' || s.maskpan(vcardlist(i).pan) || '-' ||
				  to_char(vcardlist(i).mbr)
				 ,csay_level);
		
			IF vcardlist(i).pcstat = referencecrd_stat.card_closed
			THEN
				loadcardstatus(pcontractno
							  ,vcardlist(i).pan || to_char(vcardlist(i).mbr)
							  ,vstat
							  ,vsign);
				IF vstat IS NOT NULL
				THEN
					setcardsignstat(vcardlist(i).pan
								   ,vcardlist(i).mbr
								   ,vsign
								   ,vstat
								   ,FALSE
								   ,FALSE
								   ,pcomment);
					fcardunclosed := TRUE;
				END IF;
			END IF;
		
		END LOOP;
	
		RETURN fcardunclosed;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END unclosecard;

	FUNCTION changecardsstatus
	(
		pcontractno tcontract.no%TYPE
	   ,pfrom       tcard.crd_stat%TYPE
	   ,pto         tcard.crd_stat%TYPE
	   ,pundo       BOOLEAN
	   ,pcomment    VARCHAR2 := NULL
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR(80) := cpackage_name || '.ChangeCardsStatus';
	
		vchanged  BOOLEAN := FALSE;
		vcardlist apitypes.typecardlist;
	BEGIN
		s.say(cmethod_name || ': for contract ' || pcontractno || ' from ' || pfrom || ' to ' || pto
			 ,csay_level);
	
		IF pfrom <> pto
		THEN
			vcardlist := contract.getcardlist(pcontractno);
			FOR i IN 1 .. vcardlist.count
			LOOP
				s.say(cmethod_name || ': for ' || s.maskpan(vcardlist(i).pan) || '-' ||
					  to_char(vcardlist(i).mbr)
					 ,csay_level);
			
				IF vcardlist(i).pcstat = pfrom
				THEN
					setcardsignstat(vcardlist(i).pan
								   ,vcardlist(i).mbr
								   ,NULL
								   ,pto
								   ,FALSE
								   ,NOT pundo
								   ,pcomment);
				
					vchanged := TRUE;
				END IF;
			END LOOP;
		END IF;
	
		RETURN vchanged;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecardsstatus;

	FUNCTION lockcard
	(
		pcontractno tcontract.no%TYPE
	   ,pstatuslock tcard.crd_stat%TYPE
	   ,pundo       BOOLEAN := FALSE
	   ,pcomment    VARCHAR2 := NULL
	) RETURN BOOLEAN IS
	BEGIN
		RETURN changecardsstatus(pcontractno
								,referencecrd_stat.card_open
								,pstatuslock
								,pundo
								,pcomment);
	END lockcard;

	FUNCTION unlockcard
	(
		pcontractno tcontract.no%TYPE
	   ,pstatuslock tcard.crd_stat%TYPE
	   ,pundo       BOOLEAN := FALSE
	   ,pcomment    VARCHAR2 := NULL
	) RETURN BOOLEAN IS
	BEGIN
		RETURN changecardsstatus(pcontractno
								,pstatuslock
								,referencecrd_stat.card_open
								,pundo
								,pcomment);
	END unlockcard;

	PROCEDURE int_setavailable
	(
		paccountno     IN VARCHAR2
	   ,oavailable     IN OUT NUMBER
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER
	   ,pcheckclose    IN BOOLEAN
	   ,pwritetolog    IN BOOLEAN
	   ,powner         IN a4mlog.typeclientid
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.Int_SetAvailable';
		vowner         a4mlog.typeclientid;
		vaccounthandle NUMBER;
		voldvalue      NUMBER;
	BEGIN
		t.enter(cmethod_name);
	
		IF paccounthandle IS NULL
		THEN
			vaccounthandle := account.newobject(paccountno, 'W');
			IF vaccounthandle = 0
			THEN
				error.raisewhenerr();
			END IF;
		ELSE
			vaccounthandle := paccounthandle;
		END IF;
	
		IF pcheckclose
		THEN
			IF service.getbit(account.getstat(vaccounthandle), account.stclose) = 1
			THEN
				err.seterror(err.entry_account_is_closed, cmethod_name);
				error.raisewhenerr();
			END IF;
		END IF;
	
		IF pwritetolog
		THEN
			voldvalue := oavailable;
			vowner    := coalesce(powner, account.getidclient(vaccounthandle));
		END IF;
	
		account.setavailable(vaccounthandle, pvalue);
		IF err.geterrorcode() = 0
		THEN
			account.writeobject(vaccounthandle);
		END IF;
	
		error.raisewhenerr();
	
		IF paccounthandle IS NULL
		THEN
			account.freeobject(vaccounthandle);
		END IF;
	
		oavailable := pvalue;
	
		IF pwritetolog
		THEN
			a4mlog.cleanparamlist;
			a4mlog.addparamrec(clogparam_available, nvl(voldvalue, 0), pvalue);
			IF a4mlog.logobject(getobjecttype(account.object_name)
							   ,paccountno
							   ,'Edit account: Available (' || nvl(voldvalue, 0) || ' -> ' ||
								pvalue || ')'
							   ,a4mlog.act_change
							   ,a4mlog.putparamlist
							   ,powner => vowner) != 0
			THEN
				a4mlog.cleanparamlist;
				error.raisewhenerr();
			END IF;
			a4mlog.cleanparamlist;
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			IF vaccounthandle != 0
			THEN
				account.freeobject(vaccounthandle);
			END IF;
			RAISE;
	END int_setavailable;

	PROCEDURE setavailable
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetAvailable [row]';
	BEGIN
		int_setavailable(oaccountrow.accountno
						,oaccountrow.available
						,pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrow.idclient);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setavailable;

	PROCEDURE setavailable
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetAvailable [record]';
	BEGIN
		int_setavailable(oaccountrecord.accountno
						,oaccountrecord.available
						,pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrecord.idclient);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setavailable;

	PROCEDURE changeavailable
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeAvailable [row]';
	BEGIN
		int_setavailable(oaccountrow.accountno
						,oaccountrow.available
						,nvl(oaccountrow.available, 0) + pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrow.idclient);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changeavailable;

	PROCEDURE changeavailable
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeAvailable [record]';
	BEGIN
		int_setavailable(oaccountrecord.accountno
						,oaccountrecord.available
						,nvl(oaccountrecord.available, 0) + pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrecord.idclient);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changeavailable;

	PROCEDURE int_setlowremain
	(
		paccountno     IN VARCHAR2
	   ,olowremain     IN OUT NUMBER
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER
	   ,pcheckclose    IN BOOLEAN
	   ,pwritetolog    IN BOOLEAN
	   ,powner         IN a4mlog.typeclientid
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.Int_SetLowRemain';
		vowner         a4mlog.typeclientid;
		vaccounthandle NUMBER;
		voldvalue      NUMBER;
	BEGIN
		t.enter(cmethod_name);
	
		IF paccounthandle IS NULL
		THEN
			vaccounthandle := account.newobject(paccountno, 'W');
			IF vaccounthandle = 0
			THEN
				error.raisewhenerr();
			END IF;
		ELSE
			vaccounthandle := paccounthandle;
		END IF;
	
		IF pcheckclose
		THEN
			IF service.getbit(account.getstat(vaccounthandle), account.stclose) = 1
			THEN
				err.seterror(err.entry_account_is_closed, cmethod_name);
				error.raisewhenerr();
			END IF;
		END IF;
	
		IF pwritetolog
		THEN
			voldvalue := olowremain;
			vowner    := coalesce(powner, account.getidclient(vaccounthandle));
		END IF;
	
		account.setlowremain(vaccounthandle, pvalue);
		IF err.geterrorcode() = 0
		THEN
			account.writeobject(vaccounthandle);
		END IF;
	
		error.raisewhenerr();
	
		IF paccounthandle IS NULL
		THEN
			account.freeobject(vaccounthandle);
		END IF;
	
		olowremain := pvalue;
	
		IF pwritetolog
		THEN
			a4mlog.cleanparamlist;
			a4mlog.addparamrec(clogparam_lowremain, nvl(voldvalue, 0), pvalue);
			IF a4mlog.logobject(getobjecttype(account.object_name)
							   ,paccountno
							   ,'Edit account: LowRemain (' || nvl(voldvalue, 0) || ' -> ' ||
								pvalue || ')'
							   ,a4mlog.act_change
							   ,a4mlog.putparamlist
							   ,powner => vowner) != 0
			THEN
				a4mlog.cleanparamlist;
				error.raisewhenerr();
			END IF;
			a4mlog.cleanparamlist;
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			IF vaccounthandle != 0
			THEN
				account.freeobject(vaccounthandle);
			END IF;
			RAISE;
	END int_setlowremain;

	FUNCTION setlowremain
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := TRUE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetLowRemain [row]';
	BEGIN
		int_setlowremain(oaccountrow.accountno
						,oaccountrow.lowremain
						,pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrow.idclient);
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setlowremain;

	FUNCTION setlowremain
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := TRUE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetLowRemain [record]';
	BEGIN
		int_setlowremain(oaccountrecord.accountno
						,oaccountrecord.lowremain
						,pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrecord.idclient);
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setlowremain;

	PROCEDURE setlowremain
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetLowRemain [row]';
	BEGIN
		int_setlowremain(oaccountrow.accountno
						,oaccountrow.lowremain
						,pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrow.idclient);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setlowremain;

	PROCEDURE setlowremain
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetLowRemain [record]';
	BEGIN
		int_setlowremain(oaccountrecord.accountno
						,oaccountrecord.lowremain
						,pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrecord.idclient);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setlowremain;

	PROCEDURE changelowremain
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeLowRemain [row]';
	BEGIN
		int_setlowremain(oaccountrow.accountno
						,oaccountrow.lowremain
						,nvl(oaccountrow.lowremain, 0) + pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrow.idclient);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changelowremain;

	PROCEDURE changelowremain
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeLowRemain [record]';
	BEGIN
		int_setlowremain(oaccountrecord.accountno
						,oaccountrecord.lowremain
						,nvl(oaccountrecord.lowremain, 0) + pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrecord.idclient);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changelowremain;

	PROCEDURE int_setoverdraft
	(
		paccountno     IN VARCHAR2
	   ,ooverdraft     IN OUT NUMBER
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER
	   ,pcheckclose    IN BOOLEAN
	   ,pwritetolog    IN BOOLEAN
	   ,powner         IN a4mlog.typeclientid
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.Int_SetOverdraft';
		vowner         a4mlog.typeclientid;
		vaccounthandle NUMBER;
		voldvalue      NUMBER;
	BEGIN
		t.enter(cmethod_name);
	
		IF paccounthandle IS NULL
		THEN
			vaccounthandle := account.newobject(paccountno, 'W');
			IF vaccounthandle = 0
			THEN
				error.raisewhenerr();
			END IF;
		ELSE
			vaccounthandle := paccounthandle;
		END IF;
	
		IF pcheckclose
		THEN
			IF service.getbit(account.getstat(vaccounthandle), account.stclose) = 1
			THEN
				err.seterror(err.entry_account_is_closed, cmethod_name);
				error.raisewhenerr();
			END IF;
		END IF;
	
		IF pwritetolog
		THEN
			voldvalue := ooverdraft;
			vowner    := coalesce(powner, account.getidclient(vaccounthandle));
		END IF;
	
		account.setoverdraft(vaccounthandle, pvalue);
		IF err.geterrorcode() = 0
		THEN
			account.writeobject(vaccounthandle);
		END IF;
	
		error.raisewhenerr();
	
		IF paccounthandle IS NULL
		THEN
			account.freeobject(vaccounthandle);
		END IF;
	
		ooverdraft := pvalue;
	
		IF pwritetolog
		THEN
			a4mlog.cleanparamlist;
			a4mlog.addparamrec(clogparam_overdraft, nvl(voldvalue, 0), pvalue);
			IF a4mlog.logobject(getobjecttype(account.object_name)
							   ,paccountno
							   ,'Edit account: Overdraft (' || nvl(voldvalue, 0) || ' -> ' ||
								pvalue || ')'
							   ,a4mlog.act_change
							   ,a4mlog.putparamlist
							   ,powner => vowner) != 0
			THEN
			
				a4mlog.cleanparamlist;
				error.raisewhenerr();
			END IF;
			a4mlog.cleanparamlist;
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			IF vaccounthandle != 0
			THEN
				account.freeobject(vaccounthandle);
			END IF;
			RAISE;
	END int_setoverdraft;

	FUNCTION setoverdraft
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := TRUE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetOverdraft [row]';
	BEGIN
		int_setoverdraft(oaccountrow.accountno
						,oaccountrow.overdraft
						,pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrow.idclient);
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setoverdraft;

	FUNCTION setoverdraft
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := TRUE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetOverdraft [record]';
	BEGIN
		int_setoverdraft(oaccountrecord.accountno
						,oaccountrecord.overdraft
						,pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrecord.idclient);
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setoverdraft;

	PROCEDURE setoverdraft
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetOverdraft [row]';
	BEGIN
		int_setoverdraft(oaccountrow.accountno
						,oaccountrow.overdraft
						,pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrow.idclient);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setoverdraft;

	PROCEDURE setoverdraft
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetOverdraft [record]';
	BEGIN
		int_setoverdraft(oaccountrecord.accountno
						,oaccountrecord.overdraft
						,pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrecord.idclient);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setoverdraft;

	PROCEDURE changeoverdraft
	(
		oaccountrow    IN OUT taccount%ROWTYPE
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeOverdraft [row]';
	BEGIN
		int_setoverdraft(oaccountrow.accountno
						,oaccountrow.overdraft
						,nvl(oaccountrow.overdraft, 0) + pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrow.idclient);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changeoverdraft;

	PROCEDURE changeoverdraft
	(
		oaccountrecord IN OUT taccountrecord
	   ,pvalue         IN NUMBER
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	   ,pwritetolog    IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ChangeOverdraft [record]';
	BEGIN
		int_setoverdraft(oaccountrecord.accountno
						,oaccountrecord.overdraft
						,nvl(oaccountrecord.overdraft, 0) + pvalue
						,paccounthandle
						,pcheckclose
						,pwritetolog
						,oaccountrecord.idclient);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changeoverdraft;

	FUNCTION setacccreatedate
	(
		paccount       IN OUT taccount%ROWTYPE
	   ,pvalue         IN DATE
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SetAccCreateDate';
		vaccounthandle NUMBER;
	BEGIN
		IF paccounthandle IS NULL
		THEN
			vaccounthandle := account.newobject(paccount.accountno, 'W');
			IF vaccounthandle = 0
			THEN
				error.raisewhenerr();
			END IF;
		ELSE
			vaccounthandle := paccounthandle;
		END IF;
	
		IF pcheckclose
		THEN
			IF service.getbit(account.getstat(vaccounthandle), account.stclose) = 1
			THEN
				err.seterror(err.entry_account_is_closed, cmethod_name);
				error.raisewhenerr();
			END IF;
		END IF;
	
		account.setcreatedate(vaccounthandle, pvalue);
	
		IF err.geterrorcode() = 0
		THEN
			account.writeobject(vaccounthandle);
		END IF;
	
		error.raisewhenerr();
	
		IF paccounthandle IS NULL
		THEN
			account.freeobject(vaccounthandle);
		END IF;
	
		paccount.createdate := pvalue;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			IF vaccounthandle != 0
			THEN
				account.freeobject(vaccounthandle);
			END IF;
			RETURN err.geterrorcode;
	END setacccreatedate;

	FUNCTION setacccreatedate
	(
		paccount       IN OUT taccountrecord
	   ,pvalue         IN DATE
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	) RETURN NUMBER IS
		vaccrow taccount%ROWTYPE;
		vret    NUMBER;
	BEGIN
		copystruct(paccount, vaccrow);
		vret := setacccreatedate(vaccrow, pvalue, paccounthandle, pcheckclose);
		IF (vret = 0)
		THEN
			copystruct(vaccrow, paccount);
		END IF;
		RETURN vret;
	END setacccreatedate;

	FUNCTION setaccacct_stat
	(
		paccount       IN OUT taccount%ROWTYPE
	   ,pvalue         IN taccount.acct_stat%TYPE
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SetAccACCT_STAT';
		vaccounthandle NUMBER;
	BEGIN
		IF paccounthandle IS NULL
		THEN
			vaccounthandle := account.newobject(paccount.accountno, 'W');
			IF vaccounthandle = 0
			THEN
				error.raisewhenerr();
			END IF;
		ELSE
			vaccounthandle := paccounthandle;
		END IF;
	
		IF pcheckclose
		THEN
			IF service.getbit(account.getstat(vaccounthandle), account.stclose) = 1
			THEN
				err.seterror(err.entry_account_is_closed, cmethod_name);
				error.raisewhenerr();
			END IF;
		END IF;
	
		account.setacct_stat(vaccounthandle, pvalue);
	
		IF err.geterrorcode() = 0
		THEN
			account.writeobject(vaccounthandle);
		END IF;
	
		error.raisewhenerr();
	
		IF paccounthandle IS NULL
		THEN
			account.freeobject(vaccounthandle);
		END IF;
		paccount.acct_stat := pvalue;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			IF vaccounthandle != 0
			THEN
				account.freeobject(vaccounthandle);
			END IF;
			RETURN err.geterrorcode;
	END setaccacct_stat;

	FUNCTION setaccacct_stat
	(
		paccount       IN OUT taccountrecord
	   ,pvalue         IN taccount.acct_stat%TYPE
	   ,paccounthandle IN NUMBER := NULL
	   ,pcheckclose    IN BOOLEAN := TRUE
	) RETURN NUMBER IS
		vaccrow taccount%ROWTYPE;
		vret    NUMBER;
	BEGIN
		copystruct(paccount, vaccrow);
		vret := setaccacct_stat(vaccrow, pvalue, paccounthandle, pcheckclose);
		IF (vret = 0)
		THEN
			copystruct(vaccrow, paccount);
		END IF;
	
		RETURN vret;
	END setaccacct_stat;

	PROCEDURE readentcode
	(
		pentcode  OUT NUMBER
	   ,pentident IN VARCHAR
	) IS
		ventcode NUMBER;
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ReadEntCode';
	BEGIN
		err.seterror(0, cmethod_name);
		ventcode := referenceentry.getcode(pentident);
	
		IF ventcode IS NULL
		THEN
			error.raiseerror(err.refentry_invalid_ident
							,'Entry ID ' || pentident || ' is not found in Dictionary of entries');
		END IF;
		IF err.geterrorcode != 0
		THEN
			error.raisewhenerr;
		END IF;
	
		pentcode := ventcode;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END readentcode;

	FUNCTION readdmbrn
	(
		pkey          IN VARCHAR
	   ,pdoexeption   IN BOOLEAN := TRUE
	   ,pcontracttype IN NUMBER := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ReadDMBRn';
		vret NUMBER;
	BEGIN
		vret := datamember.getnumber(getobjecttype(contracttype.object_name)
									,nvl(pcontracttype, contracttypeschema.scontractrow.type)
									,pkey);
		IF vret IS NULL
		THEN
			IF pdoexeption
			THEN
				err.seterror(err.refct_schema_invalid_setup, cmethod_name);
				RAISE valuenotexists;
			END IF;
		END IF;
		RETURN vret;
	END readdmbrn;

	FUNCTION readdmbrc
	(
		pkey          IN VARCHAR
	   ,pdoexeption   IN BOOLEAN := TRUE
	   ,pcontracttype IN NUMBER := NULL
	) RETURN VARCHAR IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ReadDMBRc';
		vret VARCHAR(255);
	BEGIN
		vret := datamember.getchar(getobjecttype(contracttype.object_name)
								  ,nvl(pcontracttype, contracttypeschema.scontractrow.type)
								  ,pkey);
		IF vret IS NULL
		THEN
			IF pdoexeption
			THEN
				err.seterror(err.refct_schema_invalid_setup, cmethod_name);
				RAISE valuenotexists;
			END IF;
		END IF;
		RETURN vret;
	END readdmbrc;

	FUNCTION readdmbrd
	(
		pkey          IN VARCHAR
	   ,pdoexeption   IN BOOLEAN := TRUE
	   ,pcontracttype IN NUMBER := NULL
	) RETURN DATE IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ReadDMBRd';
		vret DATE;
	BEGIN
		vret := datamember.getdate(getobjecttype(contracttype.object_name)
								  ,nvl(pcontracttype, contracttypeschema.scontractrow.type)
								  ,pkey);
		IF vret IS NULL
		THEN
			IF pdoexeption
			THEN
				err.seterror(err.refct_schema_invalid_setup, cmethod_name);
				RAISE valuenotexists;
			END IF;
		END IF;
		RETURN vret;
	END readdmbrd;

	PROCEDURE writedmbrn
	(
		pkey          IN VARCHAR
	   ,pvalue        NUMBER
	   ,pdescription  VARCHAR := ' '
	   ,pcontracttype IN NUMBER := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.WriteDMBRn';
	BEGIN
		IF datamember.setnumber(getobjecttype(contracttype.object_name)
							   ,nvl(pcontracttype, contracttypeschema.scontractrow.type)
							   ,pkey
							   ,pvalue
							   ,pdescription) != 0
		THEN
			error.save(cmethod_name, err.geterrorcode(), err.getfullmessage());
			RAISE usererror;
		END IF;
	END writedmbrn;

	PROCEDURE writedmbrc
	(
		pkey          IN VARCHAR
	   ,pvalue        VARCHAR
	   ,pdescription  VARCHAR := ' '
	   ,pcontracttype IN NUMBER := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.WriteDMBRc';
	BEGIN
		IF datamember.setchar(getobjecttype(contracttype.object_name)
							 ,nvl(pcontracttype, contracttypeschema.scontractrow.type)
							 ,pkey
							 ,pvalue
							 ,pdescription) != 0
		THEN
			error.save(cmethod_name, err.geterrorcode(), err.getfullmessage());
			RAISE usererror;
		END IF;
	END writedmbrc;

	PROCEDURE writedmbrd
	(
		pkey          IN VARCHAR
	   ,pvalue        DATE
	   ,pdescription  VARCHAR := ' '
	   ,pcontracttype IN NUMBER := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.WriteDMBRd';
	BEGIN
		IF datamember.setdate(getobjecttype(contracttype.object_name)
							 ,nvl(pcontracttype, contracttypeschema.scontractrow.type)
							 ,pkey
							 ,pvalue
							 ,pdescription) != 0
		THEN
			error.save(cmethod_name, err.geterrorcode(), err.getfullmessage());
			RAISE usererror;
		END IF;
	END writedmbrd;

	PROCEDURE readchar
	(
		pdialog       IN NUMBER
	   ,pitem         IN VARCHAR
	   ,pcontracttype IN NUMBER := NULL
	   ,pdoexeption   IN BOOLEAN := FALSE
	) IS
	BEGIN
		dialog.putchar(pdialog, pitem, readdmbrc(pitem, pdoexeption, pcontracttype));
	END readchar;

	PROCEDURE readnumber
	(
		pdialog       IN NUMBER
	   ,pitem         IN VARCHAR
	   ,pcontracttype IN NUMBER := NULL
	   ,pdoexeption   IN BOOLEAN := FALSE
	) IS
	BEGIN
		dialog.putnumber(pdialog, pitem, readdmbrn(pitem, pdoexeption, pcontracttype));
	END readnumber;

	PROCEDURE readdate
	(
		pdialog       IN NUMBER
	   ,pitem         IN VARCHAR
	   ,pcontracttype IN NUMBER := NULL
	   ,pdoexeption   IN BOOLEAN := FALSE
	) IS
	BEGIN
		dialog.putdate(pdialog, pitem, readdmbrd(pitem, pdoexeption, pcontracttype));
	END readdate;

	PROCEDURE savechar
	(
		pdialog       IN NUMBER
	   ,pitem         IN VARCHAR
	   ,pcontracttype IN NUMBER := NULL
	   ,pdoexeption   BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SaveChar';
		vaccountno VARCHAR(20);
		vret       NUMBER;
		vctype     NUMBER := nvl(pcontracttype, contracttypeschema.scontractrow.type);
	BEGIN
		vaccountno := dialog.getchar(pdialog, pitem);
		IF pdoexeption
		THEN
			IF vaccountno IS NOT NULL
			THEN
				IF account.exist(vaccountno) != 0
				THEN
					dialog.goitem(pdialog, pitem);
					RAISE accountnotexists;
				END IF;
				vret := datamember.setchar(getobjecttype(contracttype.object_name)
										  ,vctype
										  ,pitem
										  ,vaccountno
										  ,'Financial scheme setup acct');
			ELSE
				dialog.goitem(pdialog, pitem);
				RAISE valuenotexists;
			END IF;
		ELSE
			vret := datamember.setchar(getobjecttype(contracttype.object_name)
									  ,vctype
									  ,pitem
									  ,vaccountno
									  ,'Financial scheme setup acct');
		END IF;
	
		IF vret != 0
		THEN
			error.save(cmethod_name, err.geterrorcode(), err.getfullmessage());
			RAISE usererror;
		END IF;
	END savechar;

	PROCEDURE savenumber
	(
		pdialog       IN NUMBER
	   ,pitem         VARCHAR
	   ,pcontracttype IN NUMBER := NULL
	   ,pdoexeption   BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SaveNumber';
		vret   NUMBER;
		vvalue NUMBER := dialog.getnumber(pdialog, pitem);
	BEGIN
		IF vvalue < 0
		THEN
			dialog.goitem(pdialog, pitem);
			RAISE negativevalue;
		END IF;
	
		IF vvalue IS NULL
		   AND pdoexeption
		THEN
			dialog.goitem(pdialog, pitem);
			RAISE valuenotexists;
		END IF;
	
		vret := datamember.setnumber(getobjecttype(contracttype.object_name)
									,nvl(pcontracttype, contracttypeschema.scontractrow.type)
									,pitem
									,vvalue
									,'Financial scheme setup item');
		IF vret != 0
		THEN
			error.save(cmethod_name, err.geterrorcode(), err.getfullmessage());
			RAISE usererror;
		END IF;
	END savenumber;

	PROCEDURE savedate
	(
		pdialog       IN NUMBER
	   ,pitem         VARCHAR
	   ,pcontracttype IN NUMBER := NULL
	   ,pdoexeption   BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SaveDate';
		vret   NUMBER;
		vvalue DATE := dialog.getdate(pdialog, pitem);
	BEGIN
		IF vvalue IS NULL
		   AND pdoexeption
		THEN
			dialog.goitem(pdialog, pitem);
			RAISE valuenotexists;
		END IF;
	
		vret := datamember.setdate(getobjecttype(contracttype.object_name)
								  ,nvl(pcontracttype, contracttypeschema.scontractrow.type)
								  ,pitem
								  ,vvalue
								  ,'Financial scheme setup item');
		IF vret != 0
		THEN
			error.save(cmethod_name, err.geterrorcode(), err.getfullmessage());
			RAISE usererror;
		END IF;
	END savedate;

	PROCEDURE savefield
	(
		pdialog       NUMBER
	   ,pitem         VARCHAR
	   ,pchecknull    BOOLEAN := TRUE
	   ,pcontracttype IN NUMBER := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SaveField';
		vret NUMBER;
	BEGIN
		IF dialog.getchar(pdialog, pitem) IS NULL
		   AND pchecknull
		THEN
			dialog.goitem(pdialog, pitem);
			RAISE valuenotexists;
		ELSE
			vret := datamember.setnumber(getobjecttype(contracttype.object_name)
										,nvl(pcontracttype, contracttypeschema.scontractrow.type)
										,pitem
										,dialog.getcurrentrecordnumber(pdialog, pitem, 'ItemId')
										,'Financial scheme setup item');
			IF vret != 0
			THEN
				error.save(cmethod_name, err.geterrorcode(), err.getfullmessage());
				RAISE usererror;
			END IF;
		END IF;
	END savefield;

	PROCEDURE savefieldstr
	(
		pdialog       NUMBER
	   ,pitem         VARCHAR
	   ,pchecknull    BOOLEAN := TRUE
	   ,pcontracttype IN NUMBER := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SaveFieldStr';
		vret NUMBER;
	BEGIN
		IF dialog.getchar(pdialog, pitem) IS NULL
		   AND pchecknull
		THEN
			dialog.goitem(pdialog, pitem);
			RAISE valuenotexists;
		ELSE
			vret := datamember.setchar(getobjecttype(contracttype.object_name)
									  ,nvl(pcontracttype, contracttypeschema.scontractrow.type)
									  ,pitem
									  ,dialog.getcurrentrecordchar(pdialog, pitem, 'ItemId')
									  ,'Financial scheme setup item');
			IF vret != 0
			THEN
				error.save(cmethod_name, err.geterrorcode(), err.getfullmessage());
				RAISE usererror;
			END IF;
		END IF;
	END savefieldstr;

	PROCEDURE setitemenabled
	(
		pdialog     NUMBER
	   ,pitem       VARCHAR
	   ,pcontractno VARCHAR
	   ,popercode   VARCHAR
	   ,pvalue      BOOLEAN := NULL
	   ,pparam      VARCHAR := NULL
	) IS
	BEGIN
		dialog.setenabled(pdialog
						 ,pitem
						 ,nvl(pvalue, TRUE) AND
						  contract.checkoperright(contract.right_modify_oper
												 ,pcontractno
												 ,popercode
												 ,upper(nvl(pparam, pitem))));
	END setitemenabled;

	PROCEDURE loadcontractaccount
	(
		pitem       NUMBER
	   ,oaccountrow OUT taccount%ROWTYPE
	   ,pcontractno VARCHAR := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.LoadContractAccount[rowtype]';
		vaccountno VARCHAR(20);
		vbranch    NUMBER := seance.getbranch();
	BEGIN
		s.say(cmethod_name || ': ' || pitem || ' for contract ' || pcontractno || '/' ||
			  contracttypeschema.scontractrow.no
			 ,csay_level);
	
		IF pitem IS NOT NULL
		THEN
			vaccountno := contract.getaccountno(nvl(pcontractno, contracttypeschema.scontractrow.no)
											   ,pitem);
			IF vaccountno IS NULL
			THEN
				RAISE accountnotexists;
			END IF;
		
			SELECT *
			INTO   oaccountrow
			FROM   taccount
			WHERE  branch = vbranch
			AND    accountno = vaccountno;
		END IF;
		s.say(cmethod_name || ': ' || vaccountno, csay_level);
	EXCEPTION
		WHEN accountnotexists THEN
			RAISE;
		WHEN no_data_found THEN
			err.seterror(err.account_not_found, cmethod_name);
			RAISE accountnotexists;
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RAISE usererror;
	END loadcontractaccount;

	PROCEDURE loadcontractaccount
	(
		pitem       NUMBER
	   ,oaccountrow OUT taccountrecord
	   ,pcontractno VARCHAR := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.LoadContractAccount[record]';
		vaccountrow taccount%ROWTYPE;
	BEGIN
		BEGIN
			loadcontractaccount(pitem, vaccountrow, pcontractno);
			copystruct(vaccountrow, oaccountrow);
		EXCEPTION
			WHEN accountnotexists THEN
				copystruct(vaccountrow, oaccountrow);
				err.seterror(0, cmethod_name);
			WHEN OTHERS THEN
				RAISE;
		END;
	
		oaccountrow.itemcode := pitem;
		s.say(cmethod_name || ': ' || pitem || ' no ' || oaccountrow.accountno, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethod_name || ': ' || SQLERRM);
			RAISE;
	END loadcontractaccount;

	PROCEDURE loadcontractaccounts
	(
		poaaccount  IN OUT typeaccarray
	   ,pcontractno VARCHAR := NULL
	   ,pdate       IN DATE := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.LoadContractAccounts';
		vno           VARCHAR(20);
		vbranch       NUMBER;
		vcontracttype VARCHAR(20);
	
		CURSOR c1 IS
			SELECT itemcode
			FROM   tcontracttypeitems a
			WHERE  branch = vbranch
			AND    TYPE = vcontracttype;
	BEGIN
		poaaccount.delete;
		vno           := nvl(pcontractno, contracttypeschema.scontractrow.no);
		vcontracttype := contract.gettype(vno);
		vbranch       := seance.getbranch();
		FOR i IN c1
		LOOP
			loadcontractaccount(i.itemcode, poaaccount(i.itemcode), vno);
			IF pdate IS NOT NULL
			THEN
			
				poaaccount(i.itemcode).remain := get_eod_remain(poaaccount(i.itemcode).accountno
															   ,pdate
															   ,FALSE
															   ,FALSE);
			
			END IF;
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END loadcontractaccounts;

	PROCEDURE loadcontractaccountbyaccno
	(
		paccountno   IN VARCHAR
	   ,oaccountrow  OUT taccount%ROWTYPE
	   ,pdoexception IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name ||
											   '.LoadContractAccountByAccNo[rowtype]';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pAccountNo', paccountno);
		t.inpar('pDoException', t.b2t(pdoexception));
	
		IF paccountno IS NOT NULL
		THEN
			BEGIN
				SELECT *
				INTO   oaccountrow
				FROM   taccount
				WHERE  branch = vbranch
				AND    accountno = paccountno;
			EXCEPTION
				WHEN no_data_found THEN
					IF NOT nvl(pdoexception, FALSE)
					THEN
						err.seterror(err.account_not_found, cmethod_name);
						RAISE usererror;
					ELSE
						error.raiseerror('Account [' || paccountno || '] not found');
					END IF;
				WHEN OTHERS THEN
					IF NOT nvl(pdoexception, FALSE)
					THEN
						err.seterror(SQLCODE, cmethod_name);
						RAISE usererror;
					ELSE
						RAISE;
					END IF;
			END;
		ELSE
			IF NOT nvl(pdoexception, FALSE)
			THEN
				err.seterror(err.account_invalid, cmethod_name);
				RAISE usererror;
			ELSE
				error.raiseerror('Invalid account No');
			END IF;
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN usererror THEN
			t.exc(cmethod_name, plevel => csay_level);
			RAISE usererror;
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END loadcontractaccountbyaccno;

	PROCEDURE loadcontractaccountbyaccno
	(
		paccountno   IN VARCHAR
	   ,oaccountrow  OUT taccountrecord
	   ,pdoexception IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name ||
											   '.LoadContractAccountByAccNo[record]';
		vaccountrow taccount%ROWTYPE;
	BEGIN
		loadcontractaccountbyaccno(paccountno, vaccountrow, nvl(pdoexception, FALSE));
	
		copystruct(vaccountrow, oaccountrow);
	EXCEPTION
		WHEN usererror THEN
			RAISE usererror;
		WHEN OTHERS THEN
			s.err(cmethod_name);
			RAISE;
	END loadcontractaccountbyaccno;

	PROCEDURE addrecordforreport
	(
		pname  VARCHAR
	   ,pvalue VARCHAR
	) IS
		cmethod_name CONSTANT VARCHAR(200) := cpackage_name || '.AddRecordForReport';
		vcount NUMBER := 0;
	BEGIN
		vcount := nvl(contracttypeschema.sacontractinfo.count, 0) + 1;
		contracttypeschema.sacontractinfo(vcount).name := pname;
		contracttypeschema.sacontractinfo(vcount).value := nvl(pvalue, ' ');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END addrecordforreport;

	FUNCTION getcredithistoryrecord
	(
		paccountno   IN taccount.accountno%TYPE
	   ,pstartdate   IN DATE
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN tcredithistory%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetCreditHistoryRecord';
		vbranch NUMBER := seance.getbranch();
		vret    tcredithistory%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
	
		IF paccountno IS NULL
		THEN
			error.raiseerror('Account No not defined');
		END IF;
	
		IF pstartdate IS NULL
		THEN
			error.raiseerror('Period start date not specified');
		END IF;
	
		BEGIN
			SELECT *
			INTO   vret
			FROM   tcredithistory
			WHERE  branch = vbranch
			AND    accountno = paccountno
			AND    startdate = pstartdate;
		EXCEPTION
			WHEN no_data_found THEN
				IF nvl(pdoexception, FALSE)
				THEN
					error.raiseerror('For account [' || paccountno ||
									 '] not found record for date [' || htools.d2s(pstartdate) ||
									 '] in history');
				END IF;
			WHEN OTHERS THEN
				RAISE;
		END;
	
		t.leave(cmethod_name, plevel => csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE createstamprow
	(
		paccountno IN taccount.accountno%TYPE
	   ,pstartdate IN DATE := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CreateStampRow';
		vbranch        NUMBER := seance.getbranch();
		vstartdate     DATE;
		vcredithistory tcredithistory%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pAccountNo', paccountno);
		t.inpar('pStartDate', htools.d2s(pstartdate));
	
		vstartdate := nvl(pstartdate, seance.getoperdate());
		t.var('vOperDate', vstartdate);
	
		vcredithistory := getcredithistoryrecord(paccountno, vstartdate, FALSE);
	
		IF vcredithistory.accountno IS NOT NULL
		THEN
			IF vcredithistory.enddate = vstartdate
			THEN
				setendcrddatetonull(paccountno, vstartdate);
			ELSIF vcredithistory.enddate <> vstartdate
			THEN
				error.raiseerror('Attempted addition of record with incorrect debt start date [' ||
								 htools.d2s(vstartdate) || ']');
			END IF;
		ELSE
			INSERT INTO tcredithistory
				(branch
				,accountno
				,startdate)
			VALUES
				(vbranch
				,paccountno
				,vstartdate);
		END IF;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END createstamprow;

	FUNCTION createstamprow
	(
		paccountno IN VARCHAR
	   ,poperdate  IN DATE := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CreateStampRow';
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		createstamprow(paccountno, poperdate);
		t.leave(cmethod_name, plevel => csay_level);
		RETURN 0;
	EXCEPTION
	
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END createstamprow;

	FUNCTION updatestamprow
	(
		paccountno IN VARCHAR
	   ,pupddate   IN DATE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.UpdateStampRow';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		UPDATE tcredithistory
		SET    startdate = pupddate
		WHERE  branch = vbranch
		AND    accountno = paccountno
		AND    enddate IS NULL;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END updatestamprow;

	PROCEDURE deletestamprow
	(
		paccountno IN VARCHAR
	   ,poperdate  IN DATE
	) IS
		cmethod_name CONSTANT VARCHAR(200) := cpackage_name || '.DeleteStampRow';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		DELETE FROM tcredithistory
		WHERE  branch = vbranch
		AND    accountno = paccountno
		AND    startdate = poperdate;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END deletestamprow;

	FUNCTION getstartcrddate
	(
		paccountno IN VARCHAR2
	   ,pdate      IN DATE
	) RETURN DATE IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetStartCrdDate[date]';
		vdate   DATE;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		IF pdate IS NULL
		THEN
			vdate := getstartcrddate(paccountno);
		ELSE
			SELECT MIN(startdate)
			INTO   vdate
			FROM   tcredithistory
			WHERE  branch = vbranch
			AND    accountno = paccountno
			AND    startdate <= pdate
			AND    (enddate >= pdate OR enddate IS NULL);
		END IF;
	
		RETURN vdate;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getstartcrddate;

	FUNCTION getstartcrddate(paccountno IN VARCHAR2) RETURN DATE IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetStartCrdDate';
		vdate   DATE;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		SELECT MIN(startdate)
		INTO   vdate
		FROM   tcredithistory
		WHERE  branch = vbranch
		AND    accountno = paccountno
		AND    enddate IS NULL;
	
		RETURN vdate;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getstartcrddate;

	FUNCTION setendcrddate
	(
		pstartdate IN DATE
	   ,paccountno IN VARCHAR
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SetEndCrdDate';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		UPDATE tcredithistory
		SET    enddate = seance.getoperdate()
		WHERE  branch = vbranch
		AND    accountno = paccountno
		AND    startdate = pstartdate;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setendcrddate;

	PROCEDURE setendcrddatetonull
	(
		paccountno IN VARCHAR
	   ,pstartdate IN DATE
	) IS
		cmethod_name CONSTANT VARCHAR(200) := cpackage_name || '.SetEndCrdDateToNull';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		UPDATE tcredithistory
		SET    enddate = NULL
		WHERE  branch = vbranch
		AND    accountno = paccountno
		AND    startdate = pstartdate;
	
		IF SQL%ROWCOUNT = 0
		THEN
			error.raiseerror('Credit opening date record not found!');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setendcrddatetonull;

	FUNCTION setviolatedstat(pcontractno IN VARCHAR) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SetViolatedStat';
		vret          NUMBER := 0;
		vcontractstat VARCHAR(10);
	BEGIN
		vcontractstat := contract.getstatus(pcontractno);
		IF NOT contract.checkstatus(vcontractstat, contract.stat_violate)
		THEN
			vret := contract.setstatus(pcontractno, contract.stat_violate, TRUE);
			IF vret = 0
			THEN
				contracttypeschema.fviolationon := TRUE;
			END IF;
		END IF;
	
		RETURN vret;
	END setviolatedstat;

	FUNCTION resetviolatedstat(pcontractno IN VARCHAR) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ResetViolatedStat';
		vret          NUMBER := 0;
		vcontractstat VARCHAR(10);
	BEGIN
		vcontractstat := contract.getstatus(pcontractno);
		IF contract.checkstatus(vcontractstat, contract.stat_violate)
		THEN
			vret := contract.setstatus(pcontractno, contract.stat_violate, FALSE);
			IF vret = 0
			THEN
				contracttypeschema.fviolationoff := TRUE;
			END IF;
		END IF;
	
		RETURN vret;
	END resetviolatedstat;

	FUNCTION closecontract(pcontractno IN VARCHAR) RETURN NUMBER IS
		vcontractstat VARCHAR(10);
	BEGIN
		vcontractstat := contract.getstatus(pcontractno);
		IF NOT contract.checkstatus(vcontractstat, contract.stat_close)
		THEN
			RETURN contract.setstatus(pcontractno, contract.stat_close, TRUE);
		END IF;
	
		RETURN 0;
	END closecontract;

	PROCEDURE closecontract
	(
		pcontractno   IN VARCHAR
	   ,precnoforundo IN OUT NUMBER
	   ,pundo         BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR(200) := cpackage_name || '.CloseContract';
		vcontractstat VARCHAR(10);
	BEGIN
		vcontractstat := contract.getstatus(pcontractno);
		IF NOT contract.checkstatus(vcontractstat, contract.stat_close)
		   OR pundo
		THEN
			contract.setstatus(pcontractno, contract.stat_close, TRUE, precnoforundo, pundo);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END closecontract;

	FUNCTION opencontract(pcontractno IN VARCHAR) RETURN NUMBER IS
		vcontractstat VARCHAR(10);
	BEGIN
		vcontractstat := contract.getstatus(pcontractno);
		IF contract.checkstatus(vcontractstat, contract.stat_close)
		THEN
			RETURN contract.setstatus(pcontractno, contract.stat_close, FALSE);
		END IF;
	
		RETURN 0;
	END opencontract;

	PROCEDURE setviolatedstat
	(
		pcontractno   IN VARCHAR
	   ,precnoforundo IN OUT NUMBER
	   ,pundo         BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR(200) := cpackage_name || '.SetViolatedStat';
		vcontractstat VARCHAR(10);
	BEGIN
		vcontractstat := contract.getstatus(pcontractno);
		IF NOT contract.checkstatus(vcontractstat, contract.stat_violate)
		   OR pundo
		THEN
			contract.setstatus(pcontractno, contract.stat_violate, TRUE, precnoforundo, pundo);
			contracttypeschema.fviolationon := TRUE;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setviolatedstat;

	PROCEDURE resetviolatedstat
	(
		pcontractno   IN VARCHAR
	   ,precnoforundo IN OUT NUMBER
	   ,pundo         BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR(200) := cpackage_name || '.ResetViolatedStat';
		vcontractstat VARCHAR(10);
	BEGIN
		vcontractstat := contract.getstatus(pcontractno);
		IF contract.checkstatus(vcontractstat, contract.stat_violate)
		   OR pundo
		THEN
			contract.setstatus(pcontractno, contract.stat_violate, FALSE, precnoforundo, pundo);
			contracttypeschema.fviolationoff := TRUE;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END resetviolatedstat;

	PROCEDURE opencontract
	(
		pcontractno   IN VARCHAR
	   ,precnoforundo IN OUT NUMBER
	   ,pundo         BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR(200) := cpackage_name || '.OpenContract';
		vcontractstat VARCHAR(10);
	BEGIN
		vcontractstat := contract.getstatus(pcontractno);
		IF contract.checkstatus(vcontractstat, contract.stat_close)
		   OR pundo
		THEN
			contract.setstatus(pcontractno, contract.stat_close, FALSE, precnoforundo, pundo);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END opencontract;

	FUNCTION getcontractstatus4ib
	(
		pcontractno IN tcontract.no%TYPE
	   ,pstatus     IN tcontract.status%TYPE := 'NONE'
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR(200) := cpackage_name || '.GetContractStatus4IB';
		vcntstatus tcontract.status%TYPE;
		vres       NUMBER;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
	
		t.inpar(cmethod_name, 'pContractNo:=' || pcontractno, csay_level);
		t.inpar(cmethod_name, 'pStatus:=' || pstatus, csay_level);
	
		IF (pstatus = 'NONE')
		THEN
			vcntstatus := contract.getstatus(pcontractno);
		ELSE
			vcntstatus := pstatus;
		END IF;
	
		CASE
			WHEN contract.checkstatus(vcntstatus, contract.stat_ok) THEN
				vres := 1;
			WHEN contract.checkstatus(vcntstatus, contract.stat_violate) THEN
				vres := 2;
			WHEN contract.checkstatus(vcntstatus, contract.stat_close) THEN
				vres := 3;
			WHEN contract.checkstatus(vcntstatus, contract.stat_suspend) THEN
				vres := 4;
			WHEN contract.checkstatus(vcntstatus, contract.stat_investigation) THEN
				vres := 5;
			ELSE
				error.raiseerror(cmethod_name || ': Unknown contract status!');
		END CASE;
		t.outpar(cmethod_name, 'vRes:=' || vres, csay_level);
		t.leave(cmethod_name, plevel => csay_level);
		RETURN vres;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcontractstatus4ib;

	FUNCTION get_bod_remain
	(
		paccountno       IN taccount.accountno%TYPE
	   ,pdate            IN DATE
	   ,parchive         IN BOOLEAN := FALSE
	   ,pcheckemptyaccno IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.Get_BOD_Remain';
		vvalue     NUMBER := 0;
		vremain    NUMBER := 0;
		vbranch    NUMBER;
		vacchandle NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'pAccountNo=[' || paccountno || '] pDate=[' || pdate || '] pArchive=[' ||
				t.b2t(parchive) || '] pDoException=[' || t.b2t(pcheckemptyaccno) || ']'
			   ,csay_level);
	
		IF paccountno IS NULL
		THEN
			IF nvl(pcheckemptyaccno, FALSE)
			THEN
				error.raiseerror('Account No not defined');
			ELSE
				t.leave(cmethod_name, 'EmptyAccNo return 0', csay_level);
				RETURN 0;
			END IF;
		END IF;
	
		vbranch := seance.getbranch();
	
		vacchandle := account.newobject(paccountno, 'R');
		error.raisewhenerr();
	
		IF vacchandle > 0
		THEN
			vremain := account.getremain(vacchandle);
			t.var(cmethod_name, ' current: vRemain=' || vremain, csay_level);
			account.freeobject(vacchandle);
		
			IF NOT nvl(parchive, FALSE)
			THEN
				t.note(cmethod_name, 'pArchive is FALSE', csay_level);
			
				SELECT nvl(SUM(u.value), 0) VALUE
				INTO   vvalue
				FROM   (SELECT -a.value VALUE
							  ,b.opdate
						FROM   tentry    a
							  ,tdocument b
						WHERE  a.branch = vbranch
						AND    a.debitaccount = paccountno
						AND    b.branch = a.branch
						AND    b.docno = a.docno
						AND    b.newdocno IS NULL
						UNION ALL
						SELECT a.value
							  ,b.opdate
						FROM   tentry    a
							  ,tdocument b
						WHERE  a.branch = vbranch
						AND    a.creditaccount = paccountno
						AND    b.branch = a.branch
						AND    b.docno = a.docno
						AND    b.newdocno IS NULL) u
				WHERE  u.opdate >= pdate;
			ELSE
				t.note(cmethod_name, 'pArchive is TRUE', csay_level);
				SELECT nvl(SUM(u.value), 0) VALUE
				INTO   vvalue
				FROM   (SELECT -a.value VALUE
							  ,b.opdate
						FROM   tentry    a
							  ,tdocument b
						WHERE  a.branch = vbranch
						AND    a.debitaccount = paccountno
						AND    b.branch = a.branch
						AND    b.docno = a.docno
						AND    b.newdocno IS NULL
						UNION ALL
						SELECT a.value
							  ,b.opdate
						FROM   tentry    a
							  ,tdocument b
						WHERE  a.branch = vbranch
						AND    a.creditaccount = paccountno
						AND    b.branch = a.branch
						AND    b.docno = a.docno
						AND    b.newdocno IS NULL
						
						UNION ALL
						SELECT -a.value VALUE
							  ,b.opdate
						FROM   tentryarc    a
							  ,tdocumentarc b
						WHERE  a.branch = vbranch
						AND    a.debitaccount = paccountno
						AND    b.branch = a.branch
						AND    b.docno = a.docno
						AND    b.newdocno IS NULL
						UNION ALL
						SELECT a.value
							  ,b.opdate
						FROM   tentryarc    a
							  ,tdocumentarc b
						WHERE  a.branch = vbranch
						AND    a.creditaccount = paccountno
						AND    b.branch = a.branch
						AND    b.docno = a.docno
						AND    b.newdocno IS NULL) u
				
				WHERE  u.opdate >= pdate;
			END IF;
		END IF;
		t.var(cmethod_name, 'vValue=' || vvalue, csay_level);
	
		vremain := vremain - vvalue;
	
		t.leave(cmethod_name, 'vRemain=' || vremain, csay_level);
		RETURN vremain;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, 'sqlcode=' || SQLCODE, plevel => csay_level);
			error.save(cmethod_name);
			IF vacchandle > 0
			THEN
				account.freeobject(vacchandle);
			END IF;
			RAISE;
	END;

	FUNCTION get_eod_remain
	(
		paccountno       IN taccount.accountno%TYPE
	   ,pdate            IN DATE
	   ,parchive         IN BOOLEAN := FALSE
	   ,pcheckemptyaccno IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.Get_EOD_Remain';
		vret NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'pAccountNo=[' || paccountno || '] pDate=[' || pdate || '] pArchive=[' ||
				t.b2t(parchive) || '] pDoException=[' || t.b2t(pcheckemptyaccno) || ']'
			   ,csay_level);
		vret := get_bod_remain(paccountno, pdate + 1, parchive, nvl(pcheckemptyaccno, FALSE));
		t.leave(cmethod_name, 'vRet=' || vret, csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getremainforacclist(pdate DATE) RETURN typeremainsforacclist IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetRemainForAccList';
		vaccountremains typeremainsforacclist;
		vaccounttobulk  typeaccounttobulk;
		vremaintobulk   typeremaintobulk;
	BEGIN
		s.say(cmethod_name || ' ----<< BEGIN', 1);
		s.say('  --  ' || cmethod_name ||
			  '" Input parameters: Date on which remains are calculated (pDate) " = ' ||
			  to_char(pdate, 'dd.mm.yyyy')
			 ,1);
		vaccountremains.delete;
	
		SELECT u.accountno
			  ,u.currentremain - nvl(SUM(u.value), 0) remain BULK COLLECT
		INTO   vaccounttobulk
			  ,vremaintobulk
		FROM   (SELECT CASE
						   WHEN b.opdate < pdate + 1 THEN
							0
						   ELSE
							-a.value
					   END VALUE
					  ,b.opdate
					  ,a.branch
					  ,a.debitaccount accountno
					  ,rfa.currentremain
				FROM   tentry                 a
					  ,tdocument              b
					  ,tremainsforacclist_gtb rfa
				WHERE  a.branch = rfa.branch
				AND    a.debitaccount = rfa.accountno
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL
				
				UNION ALL
				
				SELECT CASE
						   WHEN b.opdate < pdate + 1 THEN
							0
						   ELSE
							a.value
					   END VALUE
					  ,b.opdate
					  ,a.branch
					  ,a.creditaccount
					  ,rfa.currentremain
				FROM   tentry                 a
					  ,tdocument              b
					  ,tremainsforacclist_gtb rfa
				WHERE  a.branch = rfa.branch
				AND    a.creditaccount = rfa.accountno
				AND    b.branch = a.branch
				AND    b.docno = a.docno
				AND    b.newdocno IS NULL) u
		GROUP  BY u.accountno
				 ,u.currentremain;
	
		s.say(cmethod_name || ' "Rows fetched (vAccountToBulk.count)" = ' || vaccounttobulk.count
			 ,1);
	
		FOR i IN 1 .. vaccounttobulk.count
		LOOP
			vaccountremains(vaccounttobulk(i)) := vremaintobulk(i);
		END LOOP;
	
		s.say(cmethod_name || ' ---->> END', 1);
		RETURN vaccountremains;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
	END getremainforacclist;

	FUNCTION daycount
	(
		pbegdate IN DATE
	   ,penddate IN DATE
	) RETURN NUMBER IS
	BEGIN
		RETURN greatest(trunc(penddate) - trunc(pbegdate) + 1, 0);
	END daycount;

	FUNCTION daysinyear(pdate IN DATE) RETURN NUMBER IS
		vfirstdate DATE := trunc(pdate, 'YEAR');
	BEGIN
		RETURN add_months(vfirstdate, 12) - vfirstdate;
	END daysinyear;

	FUNCTION getyear(pdate IN DATE) RETURN NUMBER IS
	BEGIN
		RETURN to_number(to_char(pdate, 'yyyy'));
	END getyear;

	FUNCTION quarterlast_day(pdate IN DATE) RETURN DATE IS
		vyear VARCHAR(4);
	BEGIN
		vyear := to_char(pdate, 'yyyy');
		IF pdate >= to_date('0110' || vyear, 'ddmmyyyy')
		THEN
			RETURN to_date('3112' || vyear, 'ddmmyyyy');
		ELSIF pdate >= to_date('0107' || vyear, 'ddmmyyyy')
		THEN
			RETURN to_date('3009' || vyear, 'ddmmyyyy');
		ELSIF pdate >= to_date('0104' || vyear, 'ddmmyyyy')
		THEN
			RETURN to_date('3006' || vyear, 'ddmmyyyy');
		ELSE
			RETURN to_date('3103' || vyear, 'ddmmyyyy');
		END IF;
	END quarterlast_day;

	FUNCTION add_quarters
	(
		pdate  IN DATE
	   ,pcount IN NUMBER
	) RETURN DATE IS
		vdate DATE;
	BEGIN
		vdate := add_months(pdate, pcount);
		vdate := add_months(vdate, pcount);
		RETURN add_months(vdate, pcount);
	END add_quarters;

	FUNCTION dayscoefficient
	(
		pbegdate IN DATE
	   ,penddate IN DATE
	) RETURN NUMBER IS
		vcoefficient NUMBER;
	BEGIN
		IF pbegdate > penddate
		THEN
			RETURN 0;
		END IF;
	
		IF to_char(pbegdate, 'yyyy') != to_char(penddate, 'yyyy')
		THEN
			vcoefficient := daycount(pbegdate
									,to_date('3112' || to_char(pbegdate, 'yyyy'), 'ddmmyyyy')) /
							(daysinyear(pbegdate) * 100);
		
			FOR i IN to_number(to_char(pbegdate, 'yyyy')) + 1 .. to_number(to_char(penddate, 'yyyy')) - 1
			LOOP
				vcoefficient := vcoefficient + 1 / 100;
			END LOOP;
		
			vcoefficient := vcoefficient +
							daycount(to_date('0101' || to_char(penddate, 'yyyy'), 'ddmmyyyy')
									,penddate) / (daysinyear(penddate) * 100);
		
			RETURN vcoefficient;
		ELSE
			RETURN daycount(pbegdate, penddate) /(daysinyear(pbegdate) * 100);
		END IF;
	END dayscoefficient;

	FUNCTION getpreparesum
	(
		psummafrom    IN NUMBER
	   ,pcurrencyfrom IN NUMBER
	   ,psummato      IN NUMBER
	   ,pcurrencyto   IN NUMBER
	   ,pexchange     IN NUMBER
	   ,pdate         IN DATE
	   ,poutsum       OUT NUMBER
	   ,poutcurrency  OUT NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetPrepareSum';
	BEGIN
		IF exchangerate.preparesumma(pcurrencyfrom
									,pcurrencyto
									,pcurrencyfrom
									,psummafrom
									,pexchange
									,pdate) != 0
		THEN
			RETURN err.geterrorcode();
		END IF;
	
		IF exchangerate.ssummato > psummato
		THEN
			poutsum      := psummato;
			poutcurrency := pcurrencyto;
		ELSE
			poutsum      := psummafrom;
			poutcurrency := pcurrencyfrom;
		END IF;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END getpreparesum;

	FUNCTION getpreparesumto
	(
		psummafrom    IN NUMBER
	   ,pcurrencyfrom IN NUMBER
	   ,psummato      IN NUMBER
	   ,pcurrencyto   IN NUMBER
	   ,pexchange     IN NUMBER
	   ,pdate         IN DATE
	   ,poutsumto     OUT NUMBER
	   ,poutsum       OUT NUMBER
	   ,poutcurrency  OUT NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetPrepareSumTo';
	BEGIN
		IF exchangerate.preparesumma(pcurrencyfrom
									,pcurrencyto
									,pcurrencyfrom
									,psummafrom
									,pexchange
									,pdate) != 0
		THEN
			RETURN err.geterrorcode();
		END IF;
	
		IF exchangerate.ssummato > psummato
		THEN
			poutsumto    := psummato;
			poutsum      := psummato;
			poutcurrency := pcurrencyto;
		ELSE
			poutsumto    := exchangerate.ssummato;
			poutsum      := psummafrom;
			poutcurrency := pcurrencyfrom;
		END IF;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END getpreparesumto;

	PROCEDURE fillexchangelist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcurrent  IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillExchangeList';
	BEGIN
		IF exchangerate.filllist(pdialog, pitemname, 0, TRUE) > 0
		THEN
			IF pcurrent IS NOT NULL
			THEN
				dialog.setcurrecbyvalue(pdialog, pitemname, 'ItemId', pcurrent);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RAISE usererror;
	END fillexchangelist;

	PROCEDURE fillstatuslist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcurrent  IN VARCHAR
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillStatusList';
		vcount NUMBER;
		CURSOR referencecrd_statcursor IS
			SELECT * FROM treferencecrd_stat ORDER BY crd_stat;
	BEGIN
		err.seterror(0, cmethod_name);
	
		dialog.listclear(pdialog, pitemname);
		vcount := 0;
		FOR i IN referencecrd_statcursor
		LOOP
			vcount := vcount + 1;
			dialog.listaddrecord(pdialog, pitemname, i.crd_stat || '~' || i.name || '~', 0, 0);
		END LOOP;
	
		IF pcurrent IS NOT NULL
		THEN
			FOR i IN 1 .. vcount
			LOOP
				IF dialog.getrecordchar(pdialog, pitemname, 'ItemId', i) = pcurrent
				THEN
					dialog.setcurrec(pdialog, pitemname, i);
					dialog.putchar(pdialog
								  ,pitemname
								  ,dialog.getrecordchar(pdialog, pitemname, 'ItemName', i));
					RETURN;
				END IF;
			END LOOP;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RAISE usererror;
	END fillstatuslist;

	PROCEDURE fillsignstatlist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.FillSignStatList';
		vlist apitypes.typecardsignlist;
	BEGIN
		dialog.listclear(pdialog, pitemname);
		vlist := referencecardsign.getfulllist;
		FOR i IN 1 .. vlist.count
		LOOP
			dialog.listaddrecord(pdialog
								,pitemname
								,vlist(i).cardsign || '~' || vlist(i).name || '~'
								,0
								,0);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END fillsignstatlist;

	PROCEDURE savenewctaccount
	(
		pcontracttype   IN NUMBER
	   ,pitemname       IN VARCHAR
	   ,pitemcode       IN NUMBER
	   ,pitemdescr      IN VARCHAR
	   ,pitemcrmode     IN NUMBER
	   ,prefaccounttype IN NUMBER
	   ,paccounttype    IN NUMBER
	   ,prefaccttyp     IN VARCHAR
	   ,prefacctstat    IN VARCHAR
	   ,pledger         IN VARCHAR
	   ,psubledger      IN VARCHAR
	   ,paccsign        IN NUMBER
	   ,pcurrency       IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SaveNewCTAccount';
		vitemname VARCHAR(40);
		vbranch   NUMBER := seance.getbranch();
	BEGIN
		s.say(cmethod_name || ': Enter [pItemName=' || pitemname || ', pItemCode=' || pitemcode ||
			  ', pItemDescr=' || pitemdescr || ']'
			 ,csay_level);
		vitemname := upper(pitemname);
		INSERT INTO tcontracttypeitems
		VALUES
			(vbranch
			,pcontracttype
			,contracttype.itemaccount
			,pitemcode
			,pitemdescr);
	
		INSERT INTO tcontractaccount
		VALUES
			(vbranch
			,pitemcode
			,nvl(paccounttype, -1)
			,nvl(prefaccttyp, referenceacct_typ.typ_checking)
			,nvl(prefacctstat, referenceacct_stat.stat_open)
			,nvl(pitemcrmode, contractaccount.createmode_always)
			,pledger
			,psubledger
			,paccsign
			,pcurrency);
	
		UPDATE tcontracttypeitemname
		SET    itemcode       = pitemcode
			  ,refaccounttype = nvl(prefaccounttype, contractaccount.refaccounttype_single)
		WHERE  branch = vbranch
		AND    contracttype = pcontracttype
		AND    itemname = vitemname;
		IF SQL%ROWCOUNT = 0
		THEN
			INSERT INTO tcontracttypeitemname
			VALUES
				(vbranch
				,pcontracttype
				,vitemname
				,pitemcode
				,nvl(prefaccounttype, contractaccount.refaccounttype_single));
		END IF;
	
		s.say(cmethod_name || ': Leave ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END savenewctaccount;

	PROCEDURE savenewctaccount
	(
		pcontracttype IN NUMBER
	   ,pitemname     IN VARCHAR
	   ,pitemcode     IN NUMBER
	   ,pitemdescr    IN VARCHAR
	   ,pitemcrmode   IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SaveNewCTAccount[old]';
	BEGIN
		s.say(cmethod_name || ': Enter ', csay_level);
		savenewctaccount(pcontracttype
						,pitemname
						,pitemcode
						,pitemdescr
						,pitemcrmode
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL);
		s.say(cmethod_name || ': Leave ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END savenewctaccount;

	PROCEDURE additem
	(
		pctype          NUMBER
	   ,psourceitemcode NUMBER
	   ,pitem           VARCHAR
	   ,pdesc           VARCHAR
	   ,pitemtype       NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.AddItem';
		vitemcode   NUMBER;
		vitemaccrow tcontractaccount%ROWTYPE;
		vbranch     NUMBER := seance.getbranch();
	BEGIN
		s.say(cmethod_name || ': contract type ' || pctype || ' item type ' || pitemtype
			 ,csay_level);
	
		CASE pitemtype
			WHEN contracttype.itemaccount THEN
				vitemcode := scontracttypeitems.nextval();
				s.say(cmethod_name || ': item code ' || vitemcode, csay_level);
			
				sanewitems(psourceitemcode) := vitemcode;
			
				vitemaccrow := contractaccount.getrecord(psourceitemcode);
				s.say(cmethod_name || ': account type ' || vitemaccrow.acctype, csay_level);
			
				savenewctaccount(pctype
								,pitem
								,vitemcode
								,pdesc
								,vitemaccrow.acchow
								,contracttypeitems.getcitnamerecord(psourceitemcode).refaccounttype
								,vitemaccrow.acctype
								,vitemaccrow.acctypep
								,vitemaccrow.accstatus
								,vitemaccrow.ledger
								,vitemaccrow.subledger
								,vitemaccrow.accsign
								,vitemaccrow.currencyno);
			WHEN contracttype.itemcard THEN
				vitemcode := scontracttypeitems.nextval();
				s.say(cmethod_name || ': item code ' || vitemcode, csay_level);
			
				INSERT INTO tcontracttypeitems
				VALUES
					(vbranch
					,pctype
					,contracttype.itemcard
					,vitemcode
					,pdesc);
			
				contractcard.cloneitem(psourceitemcode, vitemcode);
			
				FOR i IN (SELECT *
						  FROM   tcontractcardacc
						  WHERE  branch = vbranch
						  AND    code = psourceitemcode)
				LOOP
					s.say(cmethod_name || ': account code ' || i.acccode || ' / ' ||
						  sanewitems(i.acccode)
						 ,csay_level);
					INSERT INTO tcontractcardacc
					VALUES
						(vbranch
						,vitemcode
						,sanewitems(i.acccode)
						,i.accstatus
						,i.description);
				END LOOP;
			ELSE
				error.raiseerror('Unknown element type');
		END CASE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END additem;

	PROCEDURE deletectaccount
	(
		pcontracttype IN NUMBER
	   ,pitemname     IN VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.DeleteCTAccount';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vitemcode NUMBER;
		CURSOR curexistaccount
		(
			pbranch       IN NUMBER
		   ,pcontracttype IN NUMBER
		   ,pitemcode     IN NUMBER
		) IS
			SELECT key AS accountno
			FROM   tcontractitem ci
				  ,tcontract     c
			WHERE  c.branch = ci.branch
			AND    c.type = pcontracttype
			AND    ci.branch = pbranch
			AND    ci.no = c.no
			AND    ci.itemcode = pitemcode;
	BEGIN
		s.say(cmethod_name || ': Enter', csay_level);
		vitemcode := contracttypeitems.getitemcode(pcontracttype, pitemname);
		FOR i IN curexistaccount(cbranch, pcontracttype, vitemcode)
		LOOP
			error.raiseerror('Cannot delete item ' || pitemname || ' [' || vitemcode ||
							 '] of contrat type [' || pcontracttype || ']: created accounts exist');
		END LOOP;
	
		DELETE FROM tcontracttypeitemname
		WHERE  branch = cbranch
		AND    contracttype = pcontracttype
		AND    itemname = upper(pitemname);
		IF SQL%ROWCOUNT = 0
		THEN
			error.raiseerror('Error deleting correspondences of item ' || pitemname ||
							 ' of contract type [' || pcontracttype ||
							 ']: item not found by character identifier');
		END IF;
	
		IF datamember.datamemberdelete(getobjecttype(contracttype.object_name)
									  ,pcontracttype
									  ,pitemname) != 0
		THEN
			error.raisewhenerr();
		END IF;
	
		DELETE FROM tcontractaccount
		WHERE  branch = cbranch
		AND    code = vitemcode;
		IF SQL%ROWCOUNT = 0
		THEN
			error.raiseerror('Error deleting account settings for item ' || pitemname || ' [' ||
							 vitemcode || '] of contract type [' || pcontracttype || ']');
		END IF;
	
		DELETE FROM tcontracttypeitems
		WHERE  branch = cbranch
		AND    itemcode = vitemcode;
		IF SQL%ROWCOUNT = 0
		THEN
			error.raiseerror('Error deleting item ' || pitemname || ' [' || vitemcode ||
							 '] of contract type [' || pcontracttype ||
							 ']: item not found by code');
		END IF;
	
		s.say(cmethod_name || ': Leave ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END deletectaccount;

	PROCEDURE cloneaccountitem
	(
		pctypefrom IN NUMBER
	   ,pctypeto   IN NUMBER
	   ,paccrec    IN typeaccountrecord
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CloneAccountItem';
		vitemcodeto NUMBER;
	BEGIN
		s.say(cmethod_name || ': ' || paccrec.itemname || ' from contract type ' || pctypefrom ||
			  ' to ' || pctypeto
			 ,csay_level);
		vitemcodeto := contracttypeitems.getnextuniqcode();
		s.say(cmethod_name || ': new item code ' || vitemcodeto, csay_level);
		s.say(cmethod_name || ': account type ' || paccrec.acctype, csay_level);
	
		savenewctaccount(pctypeto
						,paccrec.itemname
						,vitemcodeto
						,paccrec.description
						,paccrec.acchow
						,paccrec.refaccounttype
						,paccrec.acctype
						,paccrec.acctypep
						,paccrec.accstatus
						,NULL
						,NULL
						,NULL
						,NULL);
	
		ctaccounttypeperiod.cloneitem(pctypefrom, pctypeto, paccrec.itemname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END cloneaccountitem;

	PROCEDURE cloneaccountitems
	(
		pctypefrom IN NUMBER
	   ,pctypeto   IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CloneAccountItems';
		vaccrec typeaccountrecord;
		vbranch NUMBER := seance.getbranch();
		CURSOR caccountitems(pcontracttype tcontracttype.type%TYPE) IS
			SELECT a.code
				  ,c.itemname
				  ,b.description
				  ,c.refaccounttype
				  ,a.acchow
				  ,a.acctype
				  ,a.acctypep
				  ,a.accstatus
			FROM   tcontractaccount a
			INNER  JOIN tcontracttypeitems b
			ON     a.branch = b.branch
			AND    b.itemcode = a.code
			AND    b.itemtype = contracttype.itemaccount
			INNER  JOIN tcontracttypeitemname c
			ON     c.branch = b.branch
			AND    c.contracttype = b.type
			AND    c.itemcode = b.itemcode
			AND    b.type = pcontracttype
			WHERE  a.branch = vbranch;
	BEGIN
		s.say(cmethod_name || ': ', csay_level);
		contracttypeschema.saitemaccountarray.delete;
		DELETE FROM tcontracttypeitems
		WHERE  branch = vbranch
		AND    TYPE = pctypeto
		AND    itemtype = contracttype.itemaccount;
		FOR rec IN caccountitems(pctypefrom)
		LOOP
			vaccrec.itemcode       := rec.code;
			vaccrec.itemname       := rec.itemname;
			vaccrec.description    := rec.description;
			vaccrec.refaccounttype := rec.refaccounttype;
			vaccrec.acchow         := rec.acchow;
			vaccrec.acctype        := rec.acctype;
			vaccrec.acctypep       := rec.acctypep;
			vaccrec.accstatus      := rec.accstatus;
		
			cloneaccountitem(pctypefrom, pctypeto, vaccrec);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END cloneaccountitems;

	PROCEDURE clonecarditem
	(
		pctypeto      IN NUMBER
	   ,pitemcodefrom IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CloneCardItem';
		vbranch      NUMBER := seance.getbranch();
		vitemcodeto  NUMBER;
		vitemcodeacc NUMBER;
		vdescription VARCHAR(500);
	BEGIN
		s.say(cmethod_name || ': ' || pitemcodefrom || ' to contract type ' || pctypeto
			 ,csay_level);
		vitemcodeto := contracttypeitems.getnextuniqcode();
		s.say(cmethod_name || ': new item code ' || vitemcodeto, csay_level);
	
		vdescription := contracttypeitems.getrecord(pitemcodefrom).description;
		INSERT INTO tcontracttypeitems
		VALUES
			(vbranch
			,pctypeto
			,contracttype.itemcard
			,vitemcodeto
			,vdescription);
	
		contractcard.cloneitem(pitemcodefrom, vitemcodeto);
	
		FOR i IN (SELECT *
				  FROM   tcontractcardacc
				  WHERE  branch = vbranch
				  AND    code = pitemcodefrom)
		LOOP
			s.say(cmethod_name || ': account code ' || i.acccode, csay_level);
			vitemcodeacc := contracttypeitems.getcitnamerecord(pctypeto, contracttypeitems.getcitnamerecord(i.acccode).itemname)
							.itemcode;
			s.say(cmethod_name || ': item code ' || vitemcodeacc, csay_level);
		
			INSERT INTO tcontractcardacc
			VALUES
				(vbranch
				,vitemcodeto
				,vitemcodeacc
				,i.accstatus
				,i.description);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END clonecarditem;

	PROCEDURE clonecarditems
	(
		pctypefrom IN NUMBER
	   ,pctypeto   IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CloneCardItems';
		vbranch NUMBER := seance.getbranch();
	
		CURSOR ccarditems
		(
			pcontracttype IN NUMBER
		   ,pbranch       IN NUMBER
		) IS
			SELECT *
			FROM   tcontracttypeitems
			WHERE  branch = pbranch
			AND    TYPE = pcontracttype
			AND    itemtype = contracttype.itemcard
			ORDER  BY itemcode;
	BEGIN
		s.say(cmethod_name || ': ', csay_level);
		DELETE FROM tcontracttypeitems
		WHERE  branch = vbranch
		AND    TYPE = pctypeto
		AND    itemtype = contracttype.itemcard;
	
		FOR i IN ccarditems(pctypefrom, vbranch)
		LOOP
			s.say(cmethod_name || ': item code ' || i.itemcode, csay_level);
			clonecarditem(pctypeto, i.itemcode);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END clonecarditems;

	PROCEDURE cloneitems
	(
		pctypefrom IN NUMBER
	   ,pctypeto   IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CloneItems';
	BEGIN
		s.say(cmethod_name || ': ', csay_level);
		cloneaccountitems(pctypefrom, pctypeto);
		clonecarditems(pctypefrom, pctypeto);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END cloneitems;

	PROCEDURE addprchistory
	(
		pname      VARCHAR
	   ,premark    VARCHAR
	   ,pctypeto   NUMBER
	   ,pctypefrom NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.AddPrcHistory';
		vret     NUMBER;
		vdate    DATE;
		vpercent NUMBER;
	BEGIN
		vret  := datamember.datamemberdelete(getobjecttype(contracttype.object_name)
											,pctypeto
											,pname);
		vdate := NULL;
		LOOP
			vdate := datamember.gethistorynext(getobjecttype(contracttype.object_name)
											  ,pctypefrom
											  ,pname
											  ,vdate);
			EXIT WHEN vdate IS NULL;
		
			vpercent := datamember.gethistorynumber(getobjecttype(contracttype.object_name)
												   ,pctypefrom
												   ,pname
												   ,vdate);
			vret     := datamember.sethistorynumber(getobjecttype(contracttype.object_name)
												   ,pctypeto
												   ,pname
												   ,vdate
												   ,vpercent
												   ,premark);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END addprchistory;

	PROCEDURE addprchistoryint
	(
		pname      VARCHAR
	   ,premark    VARCHAR
	   ,pctypeto   NUMBER
	   ,pctypefrom NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.AddPrcHistoryInt';
		vret     NUMBER;
		vdate    DATE;
		vpercent NUMBER;
		vintcurr NUMBER;
	BEGIN
		vret  := datamember.datamemberdelete(getobjecttype(contracttype.object_name)
											,pctypeto
											,pname);
		vdate := NULL;
		LOOP
			vdate := datamember.getintervalhistorynextdate(getobjecttype(contracttype.object_name)
														  ,pctypefrom
														  ,pname
														  ,vdate);
			EXIT WHEN vdate IS NULL;
		
			vintcurr := NULL;
			LOOP
				vintcurr := datamember.getintervalhistorynextinterval(getobjecttype(contracttype.object_name)
																	 ,pctypefrom
																	 ,pname
																	 ,vdate
																	 ,vintcurr);
				EXIT WHEN vintcurr IS NULL;
			
				vpercent := datamember.getintervalhistorynumber(getobjecttype(contracttype.object_name)
															   ,pctypefrom
															   ,pname
															   ,vdate
															   ,vintcurr);
				vret     := datamember.setintervalhistorynumber(getobjecttype(contracttype.object_name)
															   ,pctypeto
															   ,pname
															   ,vdate
															   ,vintcurr
															   ,vpercent
															   ,premark);
			END LOOP;
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END addprchistoryint;

	PROCEDURE addhistoryint
	(
		pname      VARCHAR
	   ,premark    VARCHAR
	   ,pctypeto   NUMBER
	   ,pctypefrom NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.AddHistoryInt';
		vret     NUMBER;
		vpercent NUMBER;
		vintcurr NUMBER;
	BEGIN
		vret     := datamember.datamemberdelete(getobjecttype(contracttype.object_name)
											   ,pctypeto
											   ,pname);
		vintcurr := NULL;
		LOOP
			vintcurr := datamember.getintervalnext(getobjecttype(contracttype.object_name)
												  ,pctypefrom
												  ,pname
												  ,vintcurr);
			EXIT WHEN vintcurr IS NULL;
		
			vpercent := datamember.getintervalnumber(getobjecttype(contracttype.object_name)
													,pctypefrom
													,pname
													,vintcurr);
			vret     := datamember.setintervalnumber(getobjecttype(contracttype.object_name)
													,pctypeto
													,pname
													,vintcurr
													,vpercent
													,premark);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END addhistoryint;

	FUNCTION getdatebyzero
	(
		paccount   IN taccount%ROWTYPE
	   ,pstartdate IN DATE
	) RETURN DATE IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetDateByZero[rowtype]';
		vdate   DATE := NULL;
		vremain NUMBER := 0;
		vbranch NUMBER;
		ffirst  BOOLEAN := TRUE;
		CURSOR c1 IS
			SELECT opdate
				  ,SUM(VALUE) VALUE
			FROM   (SELECT b.opdate
						  ,-a.value VALUE
					FROM   tentry    a
						  ,tdocument b
					WHERE  a.branch = vbranch
					AND    a.debitaccount = paccount.accountno
					AND    b.branch = a.branch
					AND    b.docno = a.docno
					AND    b.opdate >= pstartdate
					AND    b.newdocno IS NULL
					UNION ALL
					SELECT b.opdate
						  ,a.value
					FROM   tentry    a
						  ,tdocument b
					WHERE  a.branch = vbranch
					AND    a.creditaccount = paccount.accountno
					AND    b.branch = a.branch
					AND    b.docno = a.docno
					AND    b.opdate >= pstartdate
					AND    b.newdocno IS NULL)
			GROUP  BY opdate
			ORDER  BY opdate DESC;
	BEGIN
		vbranch := seance.getbranch();
		SELECT remain
		INTO   vremain
		FROM   taccount
		WHERE  branch = vbranch
		AND    accountno = paccount.accountno;
		s.say(cmethod_name || ': start remain ' || vremain, csay_level);
		vdate := pstartdate;
	
		FOR i IN c1
		LOOP
			s.say(cmethod_name || ': date ' || vdate || ' remain ' || vremain, csay_level);
			IF vremain = 0
			THEN
				IF ffirst
				THEN
					vdate := i.opdate + 1;
				END IF;
				EXIT;
			END IF;
		
			ffirst  := FALSE;
			vremain := vremain - i.value;
			vdate   := i.opdate;
		END LOOP;
	
		IF vremain = 0
		THEN
			RETURN vdate;
		ELSE
			RETURN pstartdate;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN NULL;
	END getdatebyzero;

	FUNCTION getdatebyzero
	(
		paccount   IN taccountrecord
	   ,pstartdate IN DATE
	) RETURN DATE IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetDateByZero[record]';
		vaccount taccount%ROWTYPE;
	BEGIN
		copystruct(paccount, vaccount);
		RETURN getdatebyzero(vaccount, pstartdate);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getdatebyzero;

	FUNCTION getfirstnotnullremaindate
	(
		paccountno IN taccount.accountno%TYPE
	   ,pstartdate IN DATE
	   ,pstopdate  IN DATE
	) RETURN DATE IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetFirstNotNullRemainDate';
		vremain      NUMBER;
		vfirstremain NUMBER;
		vbranch      NUMBER;
		vdate        DATE;
		CURSOR c1 IS
			SELECT opdate
				  ,SUM(VALUE) VALUE
				  ,docno
				  ,no
			FROM   (SELECT b.opdate
						  ,-a.value VALUE
						  ,b.docno
						  ,a.no
					FROM   tentry    a
						  ,tdocument b
					WHERE  a.branch = vbranch
					AND    a.debitaccount = paccountno
					AND    b.branch = a.branch
					AND    b.docno = a.docno
					AND    b.opdate >= pstartdate
					AND    b.newdocno IS NULL
					UNION ALL
					SELECT b.opdate
						  ,a.value
						  ,b.docno
						  ,a.no
					FROM   tentry    a
						  ,tdocument b
					WHERE  a.branch = vbranch
					AND    a.creditaccount = paccountno
					AND    b.branch = a.branch
					AND    b.docno = a.docno
					AND    b.opdate >= pstartdate
					AND    b.newdocno IS NULL)
			GROUP  BY opdate
					 ,docno
					 ,no
			ORDER  BY opdate DESC
					 ,docno  DESC
					 ,no     DESC;
	BEGIN
		vbranch := seance.getbranch();
		SELECT remain
		INTO   vfirstremain
		FROM   taccount
		WHERE  branch = vbranch
		AND    accountno = paccountno;
		s.say(cmethod_name || ': start remain ' || vfirstremain, csay_level);
		vremain := vfirstremain;
		FOR i IN c1
		LOOP
			vremain := vremain - i.value;
			vdate   := i.opdate;
			s.say(cmethod_name || ': remain ' || vremain || ' date ' || vdate, csay_level);
		
			IF vdate > pstopdate
			THEN
				vfirstremain := vfirstremain - i.value;
				s.say(cmethod_name || ': start remain ' || vfirstremain, csay_level);
			END IF;
		
			EXIT WHEN(vremain = 0) AND(vdate <= pstopdate);
		END LOOP;
	
		IF vfirstremain = 0
		THEN
			vdate := NULL;
		END IF;
		s.say(cmethod_name || ': ' || vdate, csay_level);
		RETURN vdate;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			err.seterror(SQLCODE, cmethod_name);
			RAISE;
	END getfirstnotnullremaindate;

	FUNCTION getdate
	(
		pdate IN DATE
	   ,pday  IN NUMBER
	   ,pnext IN NUMBER
	) RETURN DATE IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetDate';
		vlastdate DATE;
		vdate     DATE;
	BEGIN
		vlastdate := last_day(add_months(pdate, -1));
		vdate     := least(vlastdate + pday, last_day(vlastdate + 1));
	
		IF (pnext = cgreatestequal AND vdate < pdate)
		   OR (pnext = cgreatest AND vdate <= pdate)
		THEN
			vdate := getdate(add_months(pdate, 1), pday, cany);
		ELSIF (pnext = cleastequal AND vdate > pdate)
		THEN
			vdate := getdate(add_months(pdate, -1), pday, cany);
		END IF;
	
		s.say(cmethod_name || ': ' || vdate, csay_level);
		RETURN vdate;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getdate;

	FUNCTION creategrouprisk
	(
		pcontractno IN VARCHAR
	   ,poldgroup   IN NUMBER
	   ,pnewgroup   IN NUMBER
	   ,pno         OUT NUMBER
	   ,pdate       IN DATE := NULL
	   ,pgrouptype  IN NUMBER := cgrpcrd
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CreateGroupRisk';
		vno     NUMBER;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		SELECT sgrouprisk_no.nextval INTO vno FROM dual;
	
		INSERT INTO tgrouprisk
			(branch
			,no
			,idclient
			,contractno
			,oldgroup
			,newgroup
			,changedate
			,grouptype)
		VALUES
			(vbranch
			,vno
			,contract.getidclient(pcontractno)
			,pcontractno
			,poldgroup
			,pnewgroup
			,nvl(pdate, seance.getoperdate())
			,pgrouptype);
	
		pno := vno;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END creategrouprisk;

	FUNCTION deletegrouprisk
	(
		pcontractno IN VARCHAR
	   ,pgrouptype  IN NUMBER := cgrpcrd
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.DeleteGroupRisk[grouptype]';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		DELETE FROM tgrouprisk
		WHERE  branch = vbranch
		AND    contractno = pcontractno
		AND    grouptype = pgrouptype;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END deletegrouprisk;

	FUNCTION deletegrouprisk(pno IN NUMBER) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(100) := cpackage_name || '.DeleteGroupRisk';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		DELETE FROM tgrouprisk
		WHERE  branch = vbranch
		AND    no = pno;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END deletegrouprisk;

	FUNCTION getgrouprisk
	(
		pidclient  IN NUMBER
	   ,pgrouptype IN NUMBER := cgrpcrd
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetGroupRisk[client]';
		vgroup  NUMBER;
		vbranch NUMBER;
	BEGIN
		vbranch := seance.getbranch();
	
		SELECT nvl(newgroup, 0)
		INTO   vgroup
		FROM   tgrouprisk
		WHERE  branch = vbranch
		AND    idclient = pidclient
		AND    grouptype = pgrouptype
		AND    no = (SELECT nvl(MAX(no), 0)
					 FROM   tgrouprisk
					 WHERE  branch = vbranch
					 AND    idclient = pidclient
					 AND    grouptype = pgrouptype);
	
		IF vgroup = 0
		THEN
			vgroup := 1;
		END IF;
	
		RETURN vgroup;
	EXCEPTION
		WHEN no_data_found THEN
			s.say(cmethod_name || ': no data found', csay_level);
			RETURN 1;
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN NULL;
	END getgrouprisk;

	FUNCTION getgrouprisk
	(
		pcontractno IN VARCHAR
	   ,pgrouptype  IN NUMBER := cgrpcrd
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetGroupRisk[contract]';
		vgroup  NUMBER;
		vbranch NUMBER;
	BEGIN
		vbranch := seance.getbranch();
	
		SELECT nvl(newgroup, 0)
		INTO   vgroup
		FROM   tgrouprisk
		WHERE  branch = vbranch
		AND    contractno = pcontractno
		AND    grouptype = pgrouptype
		AND    no = (SELECT nvl(MAX(no), 0)
					 FROM   tgrouprisk
					 WHERE  branch = vbranch
					 AND    contractno = pcontractno
					 AND    grouptype = pgrouptype);
	
		IF vgroup = 0
		THEN
			vgroup := 1;
		END IF;
		RETURN vgroup;
	EXCEPTION
		WHEN no_data_found THEN
			s.say(cmethod_name || ': no data found ', csay_level);
			RETURN 1;
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN NULL;
	END getgrouprisk;

	FUNCTION getgroupriskbydate
	(
		pcontractno tcontract.no%TYPE
	   ,pdate       DATE := NULL
	   ,pgrouptype  NUMBER := cgrpcrd
	) RETURN tgrouprisk.newgroup%TYPE IS
		cmethod_name CONSTANT VARCHAR2(186) := cpackage_name || '.GetGroupRiskByDate';
		vbranch tseance.branch%TYPE := seance.getbranch();
		vdate   DATE := nvl(pdate, seance.getoperdate());
		vgroup  tgrouprisk.newgroup%TYPE;
	BEGIN
		SELECT nvl(MAX(newgroup), 1)
		INTO   vgroup
		FROM   (SELECT newgroup
				FROM   tgrouprisk
				WHERE  branch = vbranch
				AND    contractno = pcontractno
				AND    changedate <= vdate
				ORDER  BY changedate DESC)
		WHERE  rownum = 1;
	
		s.say(cmethod_name || ': ' || vgroup, csay_level);
		RETURN vgroup;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getgroupriskbydate;

	PROCEDURE createaccountbycode
	(
		pcontractrow IN tcontract%ROWTYPE
	   ,paccount     IN OUT taccountrecord
	   ,puserbstd    IN BOOLEAN
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CreateAccountByCode';
		vaccountrow   taccount%ROWTYPE;
		vbranch       NUMBER := seance.getbranch();
		vcontractno   tcontract.no%TYPE;
		vcontractitem tcontractitem%ROWTYPE;
	
		vitemnamerecord tcontracttypeitemname%ROWTYPE;
		vacctypeparams  contracttypeschema.accounttypeparams;
		vcontractrow    tcontract%ROWTYPE;
	
	BEGIN
		s.say(cmethod_name || ': contract no ' || pcontractrow.no || ' item code ' ||
			  paccount.itemcode
			 ,csay_level);
	
		IF pcontractrow.no IS NULL
		THEN
			error.raiseerror('Contract No not defined');
		END IF;
	
		IF contract.checkstatus(contract.getstatus(pcontractrow.no), contract.stat_close)
		THEN
			s.say('CONTRACT_CLOSED');
			error.raiseerror('Impossible to create account as contract <' || pcontractrow.no ||
							 '> is closed');
		END IF;
	
		vcontractrow := pcontractrow;
		IF vcontractrow.type IS NULL
		   OR vcontractrow.idclient IS NULL
		THEN
			vcontractrow := contract.getcontractrowtype(pcontractrow.no);
		END IF;
	
		vcontractno := contract.getcurrentno();
		contract.setcurrentno(vcontractrow.no);
	
		err.seterror(0, cmethod_name);
		IF contract.getaccountno(vcontractrow.no, paccount.itemcode) IS NOT NULL
		THEN
			error.raiseerror('Contract: ' || vcontractrow.no ||
							 ' already contains account with ID: ' || paccount.itemcode);
		ELSE
			err.seterror(0, cmethod_name);
		END IF;
	
		IF puserbstd
		THEN
			--custom_contractrbstd.createaccountbycode(vcontractrow, paccount);
			contract.setcurrentno(vcontractno);
			RETURN;
		END IF;
	
		vaccountrow.idclient  := vcontractrow.idclient;
		vaccountrow.remain    := 0;
		vaccountrow.available := 0;
		vaccountrow.overdraft := nvl(paccount.overdraft, 0);
		vaccountrow.lowremain := nvl(paccount.lowremain, 0);
	
		vaccountrow.accounttype := paccount.accounttype;
		IF vaccountrow.accounttype IS NULL
		THEN
			vitemnamerecord := contracttypeitems.getcitnamerecord(paccount.itemcode);
			t.var('vItemNameRecord.ItemName', vitemnamerecord.itemname);
			IF contractaccount.checkrefaccounttype(vitemnamerecord.refaccounttype
												  ,contractaccount.refaccounttype_single)
			THEN
				vaccountrow.accounttype := contractaccount.getaccounttype(paccount.itemcode);
			ELSIF contractaccount.checkrefaccounttype(vitemnamerecord.refaccounttype
													 ,contractaccount.refaccounttype_table)
			THEN
			
				s.say(cmethod_name || ': RefAccountType_Table', csay_level);
				vacctypeparams := contracttypeschema.getaccounttypeparams(vcontractrow.no
																		 ,vitemnamerecord.itemname);
				s.say(cmethod_name || ': got vAccTypeParams', csay_level);
				vaccountrow.accounttype := ctaccounttypeperiod.getaccounttype(vcontractrow.type
																			 ,vitemnamerecord.itemname
																			 ,vacctypeparams);
				s.say(cmethod_name || ': vAccountRow.AccountType=' || vaccountrow.accounttype
					 ,csay_level);
			ELSE
				error.raiseerror('No settings for account with ID ' || vitemnamerecord.itemname || '[' ||
								 paccount.itemcode || '] in contract type [' || vcontractrow.type || ']');
			END IF;
		END IF;
	
		IF vaccountrow.accounttype IS NULL
		   OR vaccountrow.accounttype = -1
		THEN
			error.raiseerror('Type not defined for account with ID ' || vitemnamerecord.itemname || '[' ||
							 paccount.itemcode || ']');
		END IF;
	
		vaccountrow.acct_typ  := contractaccount.getacct_typ(paccount.itemcode);
		vaccountrow.acct_stat := contractaccount.getacct_stat(paccount.itemcode);
	
		vaccountrow.accountno  := paccount.accountno;
		vaccountrow.stat       := paccount.stat;
		vaccountrow.branchpart := vcontractrow.branchpart;
	
		vaccountrow.noplan := contractaccount.getnoplan(vaccountrow.accounttype
													   ,vaccountrow.branchpart
													   ,TRUE);
		IF accounttype.getaccmap(vaccountrow.accounttype) IS NOT NULL
		THEN
			contractaccount.checkcurrency4account(contract.gettype(vcontractrow.no)
												 ,paccount.itemcode
												 ,vaccountrow.accounttype);
		END IF;
	
		account.createaccount(vaccountrow, pdisableuserblockedcheck => TRUE);
		s.say(cmethod_name || ': error ' || err.geterrorcode(), csay_level);
		error.raisewhenerr();
	
		vcontractitem.branch   := vbranch;
		vcontractitem.no       := vcontractrow.no;
		vcontractitem.itemtype := contracttype.itemaccount;
		vcontractitem.itemcode := paccount.itemcode;
		vcontractitem.key      := vaccountrow.accountno;
		contract.insertaccountitem(vcontractitem);
	
		loadcontractaccount(paccount.itemcode, paccount, vcontractrow.no);
	
		contract.setcurrentno(vcontractno);
		s.say(cmethod_name || ': leave ', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			s.say('Exception occured, vContractNo=' || vcontractno || ', errm=' || SQLERRM
				 ,csay_level);
			contract.setcurrentno(vcontractno);
			error.save(cmethod_name);
			RAISE;
	END createaccountbycode;

	PROCEDURE copystruct
	(
		psrc  IN taccountrecord
	   ,pdest IN OUT taccount%ROWTYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CopyStruct[record]';
	BEGIN
		pdest.accountno     := psrc.accountno;
		pdest.remain        := nvl(psrc.remain, 0);
		pdest.idclient      := psrc.idclient;
		pdest.accounttype   := psrc.accounttype;
		pdest.acct_stat     := psrc.acct_stat;
		pdest.available     := nvl(psrc.available, 0);
		pdest.currencyno    := psrc.currencyno;
		pdest.overdraft     := nvl(psrc.overdraft, 0);
		pdest.lowremain     := nvl(psrc.lowremain, 0);
		pdest.debitreserve  := nvl(psrc.debitreserve, 0);
		pdest.creditreserve := nvl(psrc.creditreserve, 0);
		pdest.stat          := psrc.stat;
		pdest.createdate    := psrc.createdate;
		pdest.closedate     := psrc.closedate;
		pdest.updatesysdate := psrc.updatesysdate;
	END copystruct;

	PROCEDURE copystruct
	(
		psrc  IN taccount%ROWTYPE
	   ,pdest IN OUT taccountrecord
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CopyStruct[rowtype]';
	BEGIN
		pdest.accountno     := psrc.accountno;
		pdest.remain        := nvl(psrc.remain, 0);
		pdest.idclient      := psrc.idclient;
		pdest.accounttype   := psrc.accounttype;
		pdest.acct_stat     := psrc.acct_stat;
		pdest.available     := nvl(psrc.available, 0);
		pdest.currencyno    := psrc.currencyno;
		pdest.overdraft     := nvl(psrc.overdraft, 0);
		pdest.lowremain     := nvl(psrc.lowremain, 0);
		pdest.debitreserve  := nvl(psrc.debitreserve, 0);
		pdest.creditreserve := nvl(psrc.creditreserve, 0);
		pdest.stat          := psrc.stat;
		pdest.createdate    := psrc.createdate;
		pdest.closedate     := psrc.closedate;
		pdest.updatesysdate := psrc.updatesysdate;
	END copystruct;

	FUNCTION fillprchistarray
	(
		pcontracttype IN NUMBER
	   ,pname         IN CHAR
	   ,oardate       OUT typedate
	   ,oarpercent    OUT typenumber
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillPrcHistArray[w date]';
		vcount NUMBER;
	BEGIN
		vcount := 0;
		oardate(vcount) := NULL;
		LOOP
			oardate(vcount + 1) := datamember.gethistorynext(getobjecttype(contracttype.object_name)
															,pcontracttype
															,pname
															,oardate(vcount));
			EXIT WHEN oardate(vcount + 1) IS NULL;
		
			vcount := vcount + 1;
			oarpercent(vcount) := datamember.gethistorynumber(getobjecttype(contracttype.object_name)
															 ,pcontracttype
															 ,pname
															 ,oardate(vcount));
		END LOOP;
	
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END fillprchistarray;

	FUNCTION fillprchistarray
	(
		pcontracttype IN NUMBER
	   ,pname         IN CHAR
	   ,oahistarray   OUT typeprchistintarray
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillPrcHistArray';
		vcount NUMBER;
		vdate  DATE;
	BEGIN
		vcount := 0;
		oahistarray.delete;
		vdate := NULL;
		LOOP
			vdate := datamember.gethistorynext(getobjecttype(contracttype.object_name)
											  ,pcontracttype
											  ,pname
											  ,vdate);
			EXIT WHEN vdate IS NULL;
		
			vcount := vcount + 1;
			oahistarray(vcount).pdate := vdate;
			oahistarray(vcount).ppercent := datamember.gethistorynumber(getobjecttype(contracttype.object_name)
																	   ,pcontracttype
																	   ,pname
																	   ,vdate);
			oahistarray(vcount).pinterval := NULL;
		END LOOP;
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END fillprchistarray;

	FUNCTION fillprchistintarray
	(
		pcontracttype IN NUMBER
	   ,pname         IN CHAR
	   ,oardate       OUT typedate
	   ,oarpercent    OUT typenumber
	   ,oarinterval   OUT typenumber
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillPrcHistIntArray[w date]';
		vcount   NUMBER;
		vintcurr NUMBER;
	BEGIN
		vcount := 0;
		oardate(vcount) := NULL;
		LOOP
			oardate(vcount + 1) := datamember.getintervalhistorynextdate(getobjecttype(contracttype.object_name)
																		,pcontracttype
																		,pname
																		,oardate(vcount));
			EXIT WHEN oardate(vcount + 1) IS NULL;
		
			vintcurr := NULL;
			LOOP
				oarinterval(vcount + 1) := datamember.getintervalhistorynextinterval(getobjecttype(contracttype.object_name)
																					,pcontracttype
																					,pname
																					,oardate(vcount + 1)
																					,vintcurr);
				EXIT WHEN oarinterval(vcount + 1) IS NULL;
			
				oarpercent(vcount + 1) := datamember.getintervalhistorynumber(getobjecttype(contracttype.object_name)
																			 ,pcontracttype
																			 ,pname
																			 ,oardate(vcount + 1)
																			 ,oarinterval(vcount + 1));
				vcount := vcount + 1;
				oardate(vcount + 1) := oardate(vcount);
				vintcurr := oarinterval(vcount);
			END LOOP;
		END LOOP;
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END fillprchistintarray;

	FUNCTION fillprchistintarray
	(
		pcontracttype  IN NUMBER
	   ,pname          IN CHAR
	   ,oahistintarray OUT typeprchistintarray
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillPrcHistIntArray';
		vcount   NUMBER;
		vintcurr NUMBER;
		vdate    DATE;
	BEGIN
		vcount := 0;
		vdate  := NULL;
		LOOP
			vdate := datamember.getintervalhistorynextdate(getobjecttype(contracttype.object_name)
														  ,pcontracttype
														  ,pname
														  ,vdate);
			EXIT WHEN vdate IS NULL;
		
			vintcurr := NULL;
			LOOP
				vintcurr := datamember.getintervalhistorynextinterval(getobjecttype(contracttype.object_name)
																	 ,pcontracttype
																	 ,pname
																	 ,vdate
																	 ,vintcurr);
				EXIT WHEN vintcurr IS NULL;
			
				vcount := vcount + 1;
				oahistintarray(vcount).pinterval := vintcurr;
				oahistintarray(vcount).pdate := vdate;
				oahistintarray(vcount).ppercent := datamember.getintervalhistorynumber(getobjecttype(contracttype.object_name)
																					  ,pcontracttype
																					  ,pname
																					  ,vdate
																					  ,vintcurr);
			END LOOP;
		END LOOP;
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END fillprchistintarray;

	FUNCTION fillprcintarray
	(
		pcontracttype IN NUMBER
	   ,pname         IN CHAR
	   ,oaintarray    OUT typeprcintarray
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillPrcIntArray';
		vcount   NUMBER;
		vintcurr NUMBER;
	BEGIN
		vcount   := 0;
		vintcurr := NULL;
		oaintarray.delete;
		LOOP
			vintcurr := datamember.getintervalnext(getobjecttype(contracttype.object_name)
												  ,pcontracttype
												  ,pname
												  ,vintcurr);
			EXIT WHEN vintcurr IS NULL;
		
			vcount := vcount + 1;
			oaintarray(vcount).pinterval := vintcurr;
			oaintarray(vcount).ppercent := datamember.getintervalnumber(getobjecttype(contracttype.object_name)
																	   ,pcontracttype
																	   ,pname
																	   ,vintcurr);
		END LOOP;
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END fillprcintarray;

	FUNCTION copyprchistarray
	(
		pardatein     IN typedate
	   ,parpercentin  IN typenumber
	   ,oardateout    OUT typedate
	   ,oarpercentout OUT typenumber
	   ,pcount        IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CopyPrcHistArray';
	BEGIN
		FOR i IN 1 .. pcount
		LOOP
			oardateout(i) := pardatein(i);
			oarpercentout(i) := parpercentin(i);
		END LOOP;
		RETURN pcount;
	END copyprchistarray;

	FUNCTION copyprchistarray
	(
		pahistarray IN typeprchistintarray
	   ,oahistarray OUT typeprchistintarray
	   ,pcount      IN NUMBER := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CopyPrcHistArray[count]';
		vcount NUMBER;
	BEGIN
		IF pcount IS NULL
		THEN
			vcount := pahistarray.count;
		ELSE
			vcount := pcount;
		END IF;
	
		oahistarray.delete;
		FOR i IN 1 .. vcount
		LOOP
			oahistarray(i).pdate := pahistarray(i).pdate;
			oahistarray(i).ppercent := pahistarray(i).ppercent;
			oahistarray(i).pinterval := NULL;
		END LOOP;
		RETURN vcount;
	END copyprchistarray;

	FUNCTION copyprchistintarray
	(
		pardatein      IN typedate
	   ,parpercentin   IN typenumber
	   ,parintervalin  IN typenumber
	   ,oardateout     OUT typedate
	   ,oarpercentout  OUT typenumber
	   ,oarintervalout OUT typenumber
	   ,pcount         IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CopyPrcHistIntArray';
	BEGIN
		FOR i IN 1 .. pcount
		LOOP
			oardateout(i) := pardatein(i);
			oarpercentout(i) := parpercentin(i);
			oarintervalout(i) := parintervalin(i);
		END LOOP;
		RETURN pcount;
	END copyprchistintarray;

	FUNCTION copyprchistintarray
	(
		pahistintarray IN typeprchistintarray
	   ,oahistintarray OUT typeprchistintarray
	   ,pcount         IN NUMBER := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CopyPrcHistIntArray[count]';
		vcount NUMBER;
	BEGIN
		IF pcount IS NULL
		THEN
			vcount := pahistintarray.count;
		ELSE
			vcount := pcount;
		END IF;
	
		oahistintarray.delete;
		FOR i IN 1 .. vcount
		LOOP
			oahistintarray(i).pdate := pahistintarray(i).pdate;
			oahistintarray(i).pinterval := pahistintarray(i).pinterval;
			oahistintarray(i).ppercent := pahistintarray(i).ppercent;
		END LOOP;
		RETURN vcount;
	END copyprchistintarray;

	FUNCTION getpercent
	(
		pdate          IN DATE
	   ,pinterval      IN NUMBER
	   ,paprchistarray IN typeprchistintarray
	   ,oprcdate       OUT DATE
	   ,oprcvalue      OUT NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetPercent';
	BEGIN
		FOR i IN REVERSE 1 .. paprchistarray.count
		LOOP
			IF paprchistarray(i).pdate <= pdate
			THEN
				oprcdate := paprchistarray(i).pdate;
				IF pinterval IS NOT NULL
				THEN
					FOR j IN REVERSE 1 .. i
					LOOP
						EXIT WHEN paprchistarray(j).pdate != paprchistarray(i).pdate;
						IF paprchistarray(j).pinterval <= pinterval
						THEN
							oprcvalue := paprchistarray(j).ppercent;
							RETURN 0;
						END IF;
					END LOOP;
					EXIT;
				ELSE
					oprcvalue := paprchistarray(i).ppercent;
					RETURN 0;
				END IF;
			END IF;
		END LOOP;
	
		RETURN err.capitalise_percent_not_found;
	END getpercent;

	FUNCTION getpercentchange
	(
		pstartdate      IN DATE
	   ,penddate        IN DATE
	   ,pinterval       IN NUMBER
	   ,paprchistarray  IN typeprchistintarray
	   ,paprchistchange OUT typeprchistintarray
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetPercentChange';
		vcount NUMBER;
		vdate  DATE := NULL;
	BEGIN
		paprchistchange.delete;
		vcount := 0;
		FOR i IN 1 .. paprchistarray.count
		LOOP
			IF paprchistarray(i).pdate > pstartdate
				AND paprchistarray(i).pdate <= penddate
			THEN
				IF (vdate IS NULL)
				   OR (vdate != paprchistarray(i).pdate)
				THEN
					vdate := paprchistarray(i).pdate;
					vcount := vcount + 1;
					paprchistchange(vcount).pdate := vdate;
					IF pinterval IS NOT NULL
					THEN
						FOR j IN i .. paprchistarray.count
						LOOP
							EXIT WHEN paprchistarray(j).pdate != vdate;
						
							IF paprchistarray(j).pinterval <= pinterval
							THEN
								paprchistchange(vcount).ppercent := paprchistarray(j).ppercent;
							ELSE
								EXIT;
							END IF;
						END LOOP;
					
						IF paprchistchange(vcount).ppercent IS NULL
						THEN
							RETURN err.capitalise_percent_not_found;
						END IF;
					ELSE
						paprchistchange(vcount).ppercent := paprchistarray(i).ppercent;
					END IF;
				END IF;
			ELSIF paprchistarray(i).pdate > penddate
			THEN
				EXIT;
			END IF;
		END LOOP;
	
		RETURN 0;
	END getpercentchange;

	FUNCTION fillremainarray
	(
		paccount   IN taccountrecord
	   ,pstartdate IN DATE
	   ,penddate   IN DATE
	   ,oprcarray  OUT typeprcarray
	   ,pabsremain IN BOOLEAN := TRUE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillRemainArray';
		vbranch NUMBER;
		vcount  NUMBER;
		CURSOR c1 IS
			SELECT opdate
				  ,SUM(VALUE) VALUE
			FROM   (SELECT b.opdate
						  ,-a.value VALUE
					FROM   tentry    a
						  ,tdocument b
					WHERE  a.branch = vbranch
					AND    a.debitaccount = paccount.accountno
					AND    b.branch = a.branch
					AND    b.docno = a.docno
					AND    b.opdate >= pstartdate
					AND    b.opdate <= penddate
					AND    b.newdocno IS NULL
					UNION ALL
					SELECT b.opdate
						  ,a.value
					FROM   tentry    a
						  ,tdocument b
					WHERE  a.branch = vbranch
					AND    a.creditaccount = paccount.accountno
					AND    b.branch = a.branch
					AND    b.docno = a.docno
					AND    b.opdate >= pstartdate
					AND    b.opdate <= penddate
					AND    b.newdocno IS NULL)
			GROUP  BY opdate
			ORDER  BY opdate;
	
	BEGIN
		vbranch := seance.getbranch();
		oprcarray.delete;
		vcount := 1;
	
		oprcarray(1).premain := get_bod_remain(paccount.accountno, pstartdate);
	
		oprcarray(1).pdate := pstartdate;
	
		FOR i IN c1
		LOOP
			vcount := vcount + 1;
			IF (getyear(i.opdate + 1) > getyear(oprcarray(vcount - 1).pdate))
			   AND ((i.opdate + 1) != trunc(i.opdate + 1, 'year'))
			THEN
				oprcarray(vcount).pdate := trunc(i.opdate + 1, 'year');
				oprcarray(vcount).premain := oprcarray(vcount - 1).premain;
				vcount := vcount + 1;
			END IF;
		
			oprcarray(vcount).pdate := i.opdate + 1;
			oprcarray(vcount).premain := oprcarray(vcount - 1).premain + i.value;
		END LOOP;
	
		IF getyear(oprcarray(vcount).pdate) < getyear(penddate)
		THEN
			vcount := vcount + 1;
			oprcarray(vcount).pdate := trunc(penddate, 'year');
			oprcarray(vcount).premain := oprcarray(vcount - 1).premain;
		END IF;
	
		IF pabsremain
		THEN
			FOR i IN 1 .. vcount
			LOOP
				oprcarray(i).premain := abs(oprcarray(i).premain);
			END LOOP;
		END IF;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END fillremainarray;

	FUNCTION filltranchearray
	(
		paccount      IN taccountrecord
	   ,pstartdate    IN DATE
	   ,penddate      IN DATE
	   ,otranchearray OUT typetranchearray
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillTrancheArray';
		vperdate  DATE := NULL;
		vcount    NUMBER := 0;
		voffvalue NUMBER := 0;
		voffcount NUMBER := 0;
		voffcnt   NUMBER := 1;
		vtrvalue  NUMBER;
		vsub      NUMBER;
		vbranch   NUMBER;
		vaoff     typeprchistintarray;
	
		CURSOR c1 IS
			SELECT b.opdate
				  ,SUM(a.value) VALUE
			FROM   tentry    a
				  ,tdocument b
			WHERE  a.branch = vbranch
			AND    a.debitaccount = paccount.accountno
			AND    a.value > 0
			AND    b.branch = a.branch
			AND    b.docno = a.docno
			AND    b.opdate BETWEEN pstartdate AND penddate
			AND    b.newdocno IS NULL
			GROUP  BY opdate
			ORDER  BY opdate;
	
		CURSOR c2 IS
			SELECT b.opdate
				  ,SUM(a.value) VALUE
			FROM   tentry    a
				  ,tdocument b
			WHERE  a.branch = vbranch
			AND    a.creditaccount = paccount.accountno
			AND    a.value > 0
			AND    b.branch = a.branch
			AND    b.docno = a.docno
			AND    b.opdate BETWEEN pstartdate AND penddate
			AND    b.newdocno IS NULL
			GROUP  BY opdate
			ORDER  BY opdate;
	BEGIN
		vbranch := seance.getbranch();
		vaoff.delete;
		otranchearray.delete;
		FOR i IN c2
		LOOP
			voffcount := voffcount + 1;
			vaoff(voffcount).pdate := i.opdate;
			vaoff(voffcount).pinterval := i.value;
		END LOOP;
	
		FOR i IN c1
		LOOP
			vperdate := i.opdate + 1;
			vtrvalue := i.value;
			IF (voffcnt <= voffcount)
			   OR (voffvalue > 0)
			THEN
				LOOP
					IF voffvalue = 0
					THEN
						voffvalue := vaoff(voffcnt).pinterval;
						voffcnt   := voffcnt + 1;
					END IF;
				
					vcount := vcount + 1;
					otranchearray(vcount).ptranchedate := i.opdate + 1;
					otranchearray(vcount).pperioddate := vperdate;
					otranchearray(vcount).pperiodenddate := vaoff(voffcnt - 1).pdate;
					otranchearray(vcount).premain := vtrvalue;
					vperdate := vaoff(voffcnt - 1).pdate + 1;
					vsub := least(vtrvalue, voffvalue);
					vtrvalue := vtrvalue - vsub;
					voffvalue := voffvalue - vsub;
					EXIT WHEN(vtrvalue = 0) OR(voffcnt > voffcount);
				END LOOP;
			
				IF vtrvalue > 0
				THEN
					vcount := vcount + 1;
					otranchearray(vcount).ptranchedate := i.opdate + 1;
					otranchearray(vcount).pperioddate := vperdate;
					otranchearray(vcount).pperiodenddate := penddate;
					otranchearray(vcount).premain := vtrvalue;
				END IF;
			ELSE
				vcount := vcount + 1;
				otranchearray(vcount).ptranchedate := i.opdate + 1;
				otranchearray(vcount).pperioddate := i.opdate + 1;
				otranchearray(vcount).pperiodenddate := penddate;
				otranchearray(vcount).premain := i.value;
			END IF;
		END LOOP;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END filltranchearray;

	PROCEDURE copytranchearray
	(
		ptranchearray IN typetranchearray
	   ,otranchearray OUT typetranchearray
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CopyTrancheArray';
	BEGIN
		otranchearray.delete;
		FOR i IN 1 .. ptranchearray.count
		LOOP
			otranchearray(i).ptranchedate := ptranchearray(i).ptranchedate;
			otranchearray(i).pperioddate := ptranchearray(i).pperioddate;
			otranchearray(i).pperiodenddate := ptranchearray(i).pperiodenddate;
			otranchearray(i).pdays := ptranchearray(i).pdays;
			otranchearray(i).ppercent := ptranchearray(i).ppercent;
			otranchearray(i).premain := ptranchearray(i).premain;
			otranchearray(i).pprcdate := ptranchearray(i).pprcdate;
		END LOOP;
	END copytranchearray;

	FUNCTION years_between
	(
		pdateto   IN DATE
	   ,pdatefrom IN DATE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.Years_Between';
		cpref        CONSTANT VARCHAR(10) := '';
		vreturn NUMBER := 0;
	BEGIN
	
		vreturn := -to_number(to_char(pdatefrom, 'ddd')) /
				   to_number(to_char(add_months(trunc(pdatefrom, 'yyyy') - 1, 12), 'ddd'))
				  
				   + to_number(to_char(pdateto, 'yyyy')) - to_number(to_char(pdatefrom, 'yyyy'))
				  
				   + to_number(to_char(pdateto, 'ddd')) /
				   to_number(to_char(add_months(trunc(pdateto, 'yyyy') - 1, 12), 'ddd'));
		s.say(cpref || 'Years_Between (' || pdateto || ', ' || pdatefrom || ') ' || vreturn, 3);
	
		RETURN vreturn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
		
	END;

	FUNCTION calcpercent
	(
		paprcarray typeprcarray
	   ,pratebase  NUMBER := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CalcPercent';
		vratebase   NUMBER := nvl(pratebase, referenceprchistory.ratebase_year);
		vdaysinyear NUMBER;
		vprcstep    NUMBER := 0;
		vprctotal   NUMBER := 0;
		vdaystotal  NUMBER := 0;
	BEGIN
		percent.info_count := 0;
	
		FOR i IN 1 .. paprcarray.count
		LOOP
		
			IF nvl(paprcarray(i).pratebase, vratebase) = referenceprchistory.ratebase_day
			THEN
				vprcstep := paprcarray(i)
							.premain * paprcarray(i).ppercent * paprcarray(i).pdays / 100;
				s.say(cmethod_name || ': ' || vprcstep || ' = ' || paprcarray(i).premain || ' * ' || paprcarray(i)
					  .ppercent || ' * ' || paprcarray(i).pdays || ' / 100'
					 ,csay_level);
			ELSE
				vdaysinyear := daysinyear(paprcarray(i).pdate);
				vprcstep    := paprcarray(i)
							   .premain * paprcarray(i).ppercent * paprcarray(i).pdays / vdaysinyear / 100;
				s.say(cmethod_name || ': ' || vprcstep || ' = ' || paprcarray(i).premain || ' * ' || paprcarray(i)
					  .ppercent || ' * ' || paprcarray(i).pdays || ' / ' || vdaysinyear || ' / 100'
					 ,csay_level);
			
			END IF;
			vprctotal := vprctotal + vprcstep;
			s.say(cmethod_name || ': accumulated ' || vprctotal, csay_level);
			vdaystotal := vdaystotal + paprcarray(i).pdays;
			s.say(cmethod_name || ': days ' || vdaystotal, csay_level);
			putinfo(paprcarray(i).pdate
				   ,paprcarray(i).pdays
				   ,paprcarray(i).premain
				   ,paprcarray(i).ppercent
				   ,paprcarray(i).pprcdate
				   ,vprcstep);
		END LOOP;
		putinfo(NULL, vdaystotal, NULL, NULL, NULL, vprctotal);
		s.say(cmethod_name || ': total ' || vprctotal, csay_level);
		RETURN vprctotal;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END calcpercent;

	PROCEDURE putinfo
	(
		pdatebegin IN DATE
	   ,pdays      IN NUMBER
	   ,pvalue     IN NUMBER
	   ,pprcvalue  IN NUMBER
	   ,pprcdate   IN DATE
	   ,pprccalc   IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.PutInfo';
	BEGIN
		s.say(cmethod_name || ': begin date ' || pdatebegin, csay_level);
		s.say(cmethod_name || ': days count ' || pdays, csay_level);
		s.say(cmethod_name || ': value ' || pvalue, csay_level);
		s.say(cmethod_name || ': percent ' || pprcvalue, csay_level);
		s.say(cmethod_name || ': prc date ' || pprcdate, csay_level);
		s.say(cmethod_name || ': total ' || pprccalc, csay_level);
	
		percent.info_count := percent.info_count + 1;
		percent.info_date(percent.info_count) := pdatebegin;
		percent.info_days(percent.info_count) := pdays;
		percent.info_value(percent.info_count) := pvalue;
		percent.info_prcvalue(percent.info_count) := pprcvalue;
		percent.info_prcdate(percent.info_count) := pprcdate;
		percent.info_prccalc(percent.info_count) := pprccalc;
	END putinfo;

	FUNCTION getentsumbycode
	(
		paccount   IN taccountrecord
	   ,pentcode   IN NUMBER
	   ,pstartdate IN DATE
	   ,penddate   IN DATE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetEntSumByCode';
		vsumma  NUMBER;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		SELECT nvl(SUM(a.value), 0) summa
		INTO   vsumma
		FROM   tentry    a
			  ,tdocument b
		WHERE  a.branch = vbranch
		AND    a.debitaccount = paccount.accountno
		AND    a.debitentcode = pentcode
		AND    b.branch = a.branch
		AND    b.docno = a.docno
		AND    b.opdate BETWEEN pstartdate AND penddate
		AND    b.newdocno IS NULL;
		RETURN vsumma;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN NULL;
	END getentsumbycode;

	FUNCTION getcontractrecord
	(
		pcontractno  IN VARCHAR
	   ,ocontractrow OUT tcontract%ROWTYPE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetContractRecord';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		SELECT *
		INTO   ocontractrow
		FROM   tcontract
		WHERE  branch = vbranch
		AND    no = pcontractno;
		RETURN 0;
	EXCEPTION
		WHEN no_data_found THEN
			err.seterror(err.contract_not_found, cmethod_name);
			RETURN err.contract_not_found;
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END getcontractrecord;

	FUNCTION getdataforundo(pkey IN VARCHAR) RETURN VARCHAR IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetDataForUndo';
		vpos1 NUMBER := 0;
		vpos2 NUMBER := 0;
	BEGIN
		vpos1 := instr(contracttypeschema.srollbackdata, pkey);
		IF vpos1 = 0
		THEN
			RETURN NULL;
		END IF;
	
		vpos2 := instr(contracttypeschema.srollbackdata, '#', vpos1 + 1);
		IF vpos2 = 0
		THEN
			vpos2 := length(contracttypeschema.srollbackdata);
		ELSE
			vpos2 := vpos2 - 1;
		END IF;
	
		RETURN substr(contracttypeschema.srollbackdata
					 ,vpos1 + length(pkey)
					 ,vpos2 - vpos1 - length(pkey) + 1);
	END getdataforundo;

	FUNCTION getdataforundo
	(
		popos  IN OUT NUMBER
	   ,ovalue OUT VARCHAR
	) RETURN VARCHAR IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetDataForUndo[out]';
		vpos1 NUMBER := 0;
		vpos2 NUMBER := 0;
	BEGIN
		vpos1 := instr(contracttypeschema.srollbackdata, '#', 1, popos);
		IF vpos1 = 0
		THEN
			RETURN NULL;
		END IF;
	
		vpos2 := instr(contracttypeschema.srollbackdata, '#', vpos1 + 1);
		IF vpos2 = 0
		THEN
			vpos2 := length(contracttypeschema.srollbackdata);
		ELSE
			vpos2 := vpos2 - 1;
		END IF;
	
		ovalue := substr(contracttypeschema.srollbackdata, vpos1 + 4, vpos2 - vpos1 - 3);
		popos  := popos + 1;
		RETURN substr(contracttypeschema.srollbackdata, vpos1, 4);
	END getdataforundo;

	FUNCTION getargforundo
	(
		pvalue IN VARCHAR
	   ,oaarg  OUT typevarchar50
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.GetArgForUndo';
		vcount NUMBER := 0;
		vpos1  NUMBER := 1;
		vpos2  NUMBER;
		vvalue VARCHAR(1000);
	BEGIN
		IF pvalue IS NULL
		THEN
			RETURN 0;
		END IF;
	
		vvalue := pvalue;
		IF substr(pvalue, length(pvalue)) != '@'
		THEN
			vvalue := vvalue || '@';
		END IF;
	
		oaarg.delete;
		LOOP
			vpos2 := instr(vvalue, '@', vpos1, 1);
			EXIT WHEN vpos2 = 0;
		
			vcount := vcount + 1;
			oaarg(vcount) := substr(vvalue, vpos1, vpos2 - vpos1);
			vpos1 := vpos2 + 1;
		END LOOP;
	
		RETURN vcount;
	END getargforundo;

	FUNCTION savesnapshot
	(
		pcontractno    IN VARCHAR
	   ,popdate        IN DATE
	   ,psnapshotarray IN typesnapshotarray
	   ,pidsnapshot    OUT NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SaveSnapShot[array]';
		vidsnapshot NUMBER;
		vopdate     DATE;
		vbranch     NUMBER;
	BEGIN
		vopdate := nvl(popdate, seance.getoperdate());
		vbranch := seance.getbranch();
		SELECT scontractsnapshot_id.nextval INTO vidsnapshot FROM dual;
	
		FOR i IN 1 .. psnapshotarray.count
		LOOP
			INSERT INTO tcontractsnapshot
			VALUES
				(vbranch
				,pcontractno
				,vopdate
				,pidsnapshot
				,psnapshotarray(i).ident
				,psnapshotarray(i).value);
		END LOOP;
	
		pidsnapshot := vidsnapshot;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END savesnapshot;

	FUNCTION savesnapshot
	(
		pcontractno IN VARCHAR
	   ,popdate     IN DATE
	   ,pidsnapshot IN NUMBER
	   ,pident      IN VARCHAR
	   ,pvalue      IN VARCHAR
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SaveSnapShot';
		vopdate DATE;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		vopdate := nvl(popdate, seance.getoperdate());
	
		INSERT INTO tcontractsnapshot
		VALUES
			(vbranch
			,pcontractno
			,vopdate
			,pidsnapshot
			,pident
			,pvalue);
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END savesnapshot;

	FUNCTION loadsnapshot
	(
		pcontractno    IN VARCHAR
	   ,popdate        IN DATE
	   ,psnapshotarray OUT typesnapshotarray
	   ,pdate          OUT DATE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.LoadSnapShot';
		vbranch NUMBER;
		vopdate DATE;
		vcount  NUMBER;
		vdate   tcontractsnapshot.opdate%TYPE;
		CURSOR c1 IS
			SELECT ident
				  ,VALUE
				  ,opdate
			FROM   tcontractsnapshot
			WHERE  branch = vbranch
			AND    contractno = pcontractno
			AND    opdate <= vopdate
			AND    id = (SELECT MAX(id)
						 FROM   tcontractsnapshot
						 WHERE  branch = vbranch
						 AND    contractno = pcontractno
						 AND    opdate <= vopdate);
	BEGIN
		vcount  := 0;
		vbranch := seance.getbranch();
		vopdate := nvl(popdate, seance.getoperdate());
		vdate   := NULL;
		psnapshotarray.delete;
	
		FOR i IN c1
		LOOP
			vcount := vcount + 1;
			psnapshotarray(vcount).ident := i.ident;
			psnapshotarray(vcount).value := i.value;
			vdate := i.opdate;
		END LOOP;
	
		pdate := vdate;
		s.say(cmethod_name || ': date ' || pdate, csay_level);
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END loadsnapshot;

	FUNCTION loadsnapshot
	(
		pcontractno    IN VARCHAR
	   ,popdate        IN DATE
	   ,pident         IN VARCHAR
	   ,psnapshotarray OUT typesnapshotarray
	   ,pdate          OUT DATE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.LoadSnapShot[ident]';
		vbranch NUMBER;
		vopdate DATE;
		vcount  NUMBER;
		vdate   tcontractsnapshot.opdate%TYPE;
		CURSOR c1 IS
			SELECT ident
				  ,VALUE
				  ,opdate
			FROM   tcontractsnapshot
			WHERE  branch = vbranch
			AND    contractno = pcontractno
			AND    opdate <= vopdate
			AND    ident = pident
			AND    id = (SELECT MAX(id)
						 FROM   tcontractsnapshot
						 WHERE  branch = vbranch
						 AND    contractno = pcontractno
						 AND    opdate <= vopdate);
	BEGIN
		vcount  := 0;
		vbranch := seance.getbranch();
		vopdate := nvl(popdate, seance.getoperdate());
		vdate   := NULL;
		psnapshotarray.delete;
	
		FOR i IN c1
		LOOP
			vcount := vcount + 1;
			psnapshotarray(vcount).ident := i.ident;
			psnapshotarray(vcount).value := i.value;
			vdate := i.opdate;
		END LOOP;
	
		pdate := vdate;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END loadsnapshot;

	FUNCTION loadsnapshot
	(
		pcontractno IN VARCHAR
	   ,popdate     IN DATE
	   ,pident      IN VARCHAR
	   ,pvalue      OUT VARCHAR
	   ,pdate       OUT DATE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.LoadSnapShot[single]';
		vbranch NUMBER;
		vopdate DATE;
		CURSOR c1 IS
			SELECT VALUE
				  ,opdate
			FROM   tcontractsnapshot
			WHERE  branch = vbranch
			AND    contractno = pcontractno
			AND    opdate <= vopdate
			AND    ident = pident
			AND    id = (SELECT MAX(id)
						 FROM   tcontractsnapshot
						 WHERE  branch = vbranch
						 AND    contractno = pcontractno
						 AND    opdate <= vopdate);
	BEGIN
		vbranch := seance.getbranch();
		vopdate := nvl(popdate, seance.getoperdate());
	
		pvalue := NULL;
		pdate  := NULL;
	
		FOR i IN c1
		LOOP
			pvalue := i.value;
			pdate  := i.opdate;
		END LOOP;
	
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END loadsnapshot;

	FUNCTION delsnapshot(pidsnapshot IN NUMBER) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.DelSnapShot';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		DELETE FROM tcontractsnapshot
		WHERE  branch = vbranch
		AND    id = pidsnapshot;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cmethod_name);
			RETURN SQLCODE;
	END delsnapshot;

	FUNCTION savesshot
	(
		pcontractno    tcontract.no%TYPE
	   ,psshotdate     DATE := NULL
	   ,passhotparam   typesnapshotarray := cemptysshotparam
	   ,passhottranche typesshottranchearray := cemptysshottranche
	) RETURN tcontractsshot.id%TYPE IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SaveSShot';
		vid     tcontractsshot.id%TYPE := NULL;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		s.say(cmethod_name || ': contract no ' || pcontractno || ' snapshot date ' || psshotdate
			 ,csay_level);
	
		IF (passhotparam.count > 0)
		   OR (passhottranche.count > 0)
		THEN
			SAVEPOINT sp1;
			SELECT scontractsshot.nextval INTO vid FROM dual;
		
			INSERT INTO tcontractsshot
				(id
				,branch
				,contractno
				,sshotdate)
			VALUES
				(vid
				,vbranch
				,pcontractno
				,nvl(psshotdate, seance.getoperdate()));
			s.say(cmethod_name || ': insrted snapshot with id ' || vid, csay_level);
		
			IF passhotparam.count > 0
			THEN
				DECLARE
					vaident typevarchar40;
					vavalue typevarchar200;
				BEGIN
					FOR i IN 1 .. passhotparam.count
					LOOP
						vaident(i) := upper(passhotparam(i).ident);
						vavalue(i) := passhotparam(i).value;
					END LOOP;
				
					FORALL i IN 1 .. passhotparam.count
						INSERT INTO tcontractsshotparam
							(id
							,ident
							,VALUE)
						VALUES
							(vid
							,vaident(i)
							,vavalue(i));
				
					s.say(cmethod_name || ': parameters inserted ' || SQL%ROWCOUNT, csay_level);
					vaident.delete;
					vavalue.delete;
				END;
			END IF;
		
			IF passhottranche.count > 0
			THEN
				DECLARE
					vaident   typevarchar40;
					vaopdate  typedate;
					vavalue   typenumber;
					vaentcode typenumber;
				BEGIN
					FOR i IN 1 .. passhottranche.count
					LOOP
						vaident(i) := upper(passhottranche(i).ident);
						vaopdate(i) := passhottranche(i).opdate;
						vavalue(i) := passhottranche(i).value;
						vaentcode(i) := passhottranche(i).entcode;
					END LOOP;
				
					FORALL i IN 1 .. passhottranche.count
						INSERT INTO tcontractsshottranche
							(id
							,ident
							,opdate
							,VALUE
							,entcode)
						VALUES
							(vid
							,vaident(i)
							,vaopdate(i)
							,vavalue(i)
							,vaentcode(i));
					s.say(cmethod_name || ': inserted tranches ' || SQL%ROWCOUNT, csay_level);
				
					vaident.delete;
					vaopdate.delete;
					vavalue.delete;
					vaentcode.delete;
				END;
			END IF;
		
			s.say(cmethod_name || ': success', csay_level);
		ELSE
			s.say(cmethod_name || ': no data ', csay_level);
		END IF;
	
		RETURN vid;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK TO sp1;
			error.save(cmethod_name);
			RAISE;
	END savesshot;

	FUNCTION getsshotbydate
	(
		pcontractno tcontract.no%TYPE
	   ,plookupdate DATE
	   ,psshotdate  OUT DATE
	) RETURN tcontractsshot.id%TYPE IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetSShotByDate';
		vid     tcontractsshot.id%TYPE;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		s.say(cmethod_name || ': contract no ' || pcontractno || ' lookup date ' || plookupdate
			 ,csay_level);
	
		SELECT MAX(id)
			  ,MAX(sshotdate)
		INTO   vid
			  ,psshotdate
		FROM   tcontractsshot
		WHERE  branch = vbranch
		AND    contractno = pcontractno
		AND    sshotdate = (SELECT MAX(sshotdate)
							FROM   tcontractsshot
							WHERE  branch = vbranch
							AND    contractno = pcontractno
							AND    sshotdate <= plookupdate);
	
		s.say(cmethod_name || ': id ' || vid || ' snapshot date ' || psshotdate, csay_level);
		RETURN vid;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getsshotbydate;

	FUNCTION loadsshotparam(pid tcontractsshot.id%TYPE) RETURN typesnapshotarray IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.LoadSShotParam';
		vasshotparam typesnapshotarray;
		vaident      typevarchar40;
		vavalue      typevarchar200;
		CURSOR cursshotparam IS
			SELECT ident
				  ,VALUE
			FROM   tcontractsshotparam
			WHERE  id = pid
			ORDER  BY id
					 ,ident;
	BEGIN
		s.say(cmethod_name || ': for id ' || pid, csay_level);
	
		OPEN cursshotparam;
		FETCH cursshotparam BULK COLLECT
			INTO vaident
				,vavalue;
		CLOSE cursshotparam;
	
		FOR i IN 1 .. vaident.count
		LOOP
			vasshotparam(i).ident := vaident(i);
			vasshotparam(i).value := vavalue(i);
		END LOOP;
	
		vaident.delete;
		vavalue.delete;
		s.say(cmethod_name || ': parameters count ' || vasshotparam.count, csay_level);
		RETURN vasshotparam;
	EXCEPTION
		WHEN OTHERS THEN
			IF cursshotparam%ISOPEN
			THEN
				CLOSE cursshotparam;
			END IF;
			error.save(cmethod_name);
			RAISE;
	END loadsshotparam;

	FUNCTION identsearch
	(
		parray typesnapshotarray
	   ,pident tcontractsshotparam.ident%TYPE
	) RETURN PLS_INTEGER IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.IdentSearch';
	
		FUNCTION search
		(
			plow  PLS_INTEGER
		   ,phigh PLS_INTEGER
		) RETURN PLS_INTEGER IS
			idx PLS_INTEGER := trunc((plow + phigh) / 2);
		BEGIN
			IF parray(idx).ident = pident
			THEN
				RETURN idx;
			ELSIF plow = phigh
			THEN
				RETURN 0;
			ELSIF (plow + 1) = phigh
			THEN
				IF parray(phigh).ident = pident
				THEN
					RETURN phigh;
				ELSE
					RETURN 0;
				END IF;
			ELSIF parray(idx).ident > pident
			THEN
				RETURN search(plow, idx);
			ELSE
				RETURN search(idx, phigh);
			END IF;
		END search;
	BEGIN
		IF parray.count = 0
		THEN
			RETURN 0;
		END IF;
		RETURN search(1, parray.count);
	END identsearch;

	FUNCTION getsshotvalue
	(
		passhotparam typesnapshotarray
	   ,pident       tcontractsshotparam.ident%TYPE
	) RETURN tcontractsshotparam.value%TYPE IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetSShotValue';
		vpos PLS_INTEGER;
	BEGIN
		vpos := identsearch(passhotparam, upper(pident));
		IF vpos > 0
		THEN
			s.say(cmethod_name || ': ' || pident || ' found ' || passhotparam(vpos).value
				 ,csay_level);
			RETURN passhotparam(vpos).value;
		END IF;
	
		s.say(cmethod_name || ': ' || pident || ' not found ', csay_level);
		RETURN NULL;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getsshotvalue;

	PROCEDURE deletesshot(pid tcontractsshot.id%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.DeleteSShot';
	BEGIN
		s.say(cmethod_name || ': ' || pid, csay_level);
		DELETE FROM tcontractsshot WHERE id = pid;
		s.say(cmethod_name || ': deleted ' || SQL%ROWCOUNT, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END deletesshot;

	PROCEDURE fillaccounttypelist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pmonths   IN NUMBER
	   ,pdays     IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillAccountTypeList';
		vcount            NUMBER := 0;
		voriginalitemname VARCHAR(40);
		vbranch           NUMBER := seance.getbranch();
	BEGIN
		voriginalitemname := dialog.getchar(pdialog, 'oin_' || pitemname);
		dialog.listclear(pdialog, pitemname);
		FOR i IN (SELECT a.acctype
						,a.intdays
						,a.intmonths
						,b.name
				  FROM   tcontractacctypeperiod a
						,taccounttype           b
				  WHERE  a.branch = vbranch
				  AND    a.contracttype = scontractacctype
				  AND    ((voriginalitemname IS NOT NULL AND a.itemname = voriginalitemname) OR
						(voriginalitemname IS NULL AND a.itemname IS NULL))
				  AND    b.branch = a.branch
				  AND    b.accounttype = a.acctype
				  ORDER  BY a.intmonths * 31 + a.intdays)
		LOOP
			vcount := vcount + 1;
			dialog.listaddrecord(pdialog
								,pitemname
								,i.intmonths || '~' || i.intdays || '~' || i.acctype || '~' ||
								 i.name || '~'
								,0
								,0);
		
			IF pmonths IS NOT NULL
			THEN
				IF pmonths = i.intmonths
				   AND pdays = i.intdays
				THEN
					dialog.setcurrec(pdialog, pitemname, vcount);
				END IF;
			END IF;
		END LOOP;
	
		dialog.setenabled(pdialog, 'buDel_' || pitemname, vcount != 0);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END fillaccounttypelist;

	PROCEDURE makeacctypeitem
	(
		pdialog       IN NUMBER
	   ,px            IN NUMBER
	   ,py            IN NUMBER
	   ,pwidth        IN NUMBER
	   ,pheight       IN NUMBER
	   ,pcontracttype IN NUMBER
	   ,pitemname     IN VARCHAR := ''
	   ,pcaption      IN VARCHAR := ''
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.MakeAccTypeItem';
		vitemname VARCHAR(40);
	BEGIN
		scontractacctype := pcontracttype;
		vitemname        := nvl(pitemname, 'AccountTypeList');
	
		dialog.inputchar(pdialog, 'oin_' || vitemname, 0, 0, 40, '');
		ktools.visible(pdialog, 'oin_' || vitemname, FALSE);
		dialog.putchar(pdialog, 'oin_' || vitemname, pitemname);
	
		dialog.bevel(pdialog
					,px
					,py
					,pwidth
					,pheight
					,dialog.bevel_frame
					,pcaption => nvl(pcaption, 'Term deposit types'));
		dialog.list(pdialog
				   ,vitemname
				   ,px + 3
				   ,py + 2
				   ,pwidth - 22
				   ,pheight - 4
				   ,nvl(pcaption, 'Term deposit types'));
		dialog.listaddfield(pdialog, vitemname, 'ItemPeriodM', 'N', 10, 1);
		dialog.listaddfield(pdialog, vitemname, 'ItemPeriodD', 'N', 10, 1);
		dialog.listaddfield(pdialog, vitemname, 'ItemAccType', 'N', 10, 1);
		dialog.listaddfield(pdialog, vitemname, 'ItemAccName', 'C', 40, 1);
		dialog.setreadonly(pdialog, vitemname, TRUE);
		dialog.setcaption(pdialog
						 ,vitemname
						 ,'Term(months)~Term(days)~Account type~Account type name~');
		dialog.setitempost(pdialog, vitemname, 'ContractTools.AccTypeItemProc');
	
		dialog.button(pdialog
					 ,'buAdd_' || vitemname
					 ,px + pwidth - 15
					 ,py + 2
					 ,12
					 ,'Add'
					 ,0
					 ,0
					 ,'Add contract term');
		dialog.button(pdialog
					 ,'buDel_' || vitemname
					 ,px + pwidth - 15
					 ,py + 4
					 ,12
					 ,'Delete'
					 ,0
					 ,0
					 ,'Delete contract term');
		dialog.setitempre(pdialog, 'buAdd_' || vitemname, 'ContractTools.AccTypeItemProc');
		dialog.setitempre(pdialog, 'buDel_' || vitemname, 'ContractTools.AccTypeItemProc');
		fillaccounttypelist(pdialog, vitemname, NULL, NULL);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END makeacctypeitem;

	PROCEDURE acctypeitemproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.AccTypeItemProc';
	BEGIN
		IF pwhat = dialog.wtitempre
		THEN
			IF upper(substr(pitemname, 1, length('buAdd_'))) = upper('buAdd_')
			THEN
				IF dialog.exec(acctypeperioddialog(NULL, NULL, NULL)) = dialog.cmok
				THEN
					DECLARE
						vlistname         VARCHAR(40);
						voriginalitemname VARCHAR(40);
						vcount            NUMBER;
						vbranch           NUMBER := seance.getbranch();
					BEGIN
						vlistname         := substr(pitemname, length('buAdd_') + 1);
						voriginalitemname := dialog.getchar(pdialog, 'oin_' || vlistname);
						SELECT COUNT(*)
						INTO   vcount
						FROM   tcontractacctypeperiod
						WHERE  branch = vbranch
						AND    contracttype = scontractacctype
						AND    ((voriginalitemname IS NOT NULL AND itemname = voriginalitemname) OR
							  (voriginalitemname IS NULL AND itemname IS NULL))
						AND    intmonths = sintmonthsret
						AND    intdays = sintdaysret;
						IF vcount > 0
						THEN
							htools.message('Error', 'This period value is already used');
							RETURN;
						END IF;
					
						INSERT INTO tcontractacctypeperiod
							(branch
							,contracttype
							,acctype
							,intmonths
							,intdays
							,itemname)
						VALUES
							(vbranch
							,scontractacctype
							,sacctyperet
							,sintmonthsret
							,sintdaysret
							,voriginalitemname);
						fillaccounttypelist(pdialog, vlistname, sintmonthsret, sintdaysret);
					END;
				END IF;
			ELSIF upper(substr(pitemname, 1, length('buDel_'))) = upper('buDel_')
			THEN
				IF htools.ask('Warning', 'Delete selected period?')
				THEN
					DECLARE
						vm                NUMBER;
						vd                NUMBER;
						vlistname         VARCHAR(40);
						voriginalitemname VARCHAR(40);
						vbranch           NUMBER := seance.getbranch();
					BEGIN
						vlistname         := substr(pitemname, length('buDel_') + 1);
						voriginalitemname := dialog.getchar(pdialog, 'oin_' || vlistname);
						DELETE FROM tcontractacctypeperiod
						WHERE  branch = vbranch
						AND    contracttype = scontractacctype
						AND    ((voriginalitemname IS NOT NULL AND itemname = voriginalitemname) OR
							  (voriginalitemname IS NULL AND itemname IS NULL))
						AND    intmonths =
							   dialog.getcurrentrecordnumber(pdialog, vlistname, 'ItemPeriodM')
						AND    intdays =
							   dialog.getcurrentrecordnumber(pdialog, vlistname, 'ItemPeriodD');
						IF dialog.getlistreccount(pdialog, vlistname) = 1
						THEN
							vm := NULL;
							vd := NULL;
						ELSIF dialog.getcurrec(pdialog, vlistname) =
							  dialog.getlistreccount(pdialog, vlistname)
						THEN
							vm := dialog.getrecordnumber(pdialog
														,vlistname
														,'ItemPeriodM'
														,dialog.getlistreccount(pdialog, vlistname) - 1);
							vd := dialog.getrecordnumber(pdialog
														,vlistname
														,'ItemPeriodD'
														,dialog.getlistreccount(pdialog, vlistname) - 1);
						ELSE
							vm := dialog.getrecordnumber(pdialog
														,vlistname
														,'ItemPeriodM'
														,dialog.getcurrec(pdialog, vlistname) + 1);
							vd := dialog.getrecordnumber(pdialog
														,vlistname
														,'ItemPeriodD'
														,dialog.getcurrec(pdialog, vlistname) + 1);
						END IF;
					
						fillaccounttypelist(pdialog, vlistname, vm, vd);
					END;
				END IF;
			END IF;
		ELSIF pwhat = dialog.wtitempost
		THEN
			DECLARE
				vlistname         VARCHAR(40);
				voriginalitemname VARCHAR(40);
				vbranch           NUMBER := seance.getbranch();
			BEGIN
				vlistname         := pitemname;
				voriginalitemname := dialog.getchar(pdialog, 'oin_' || vlistname);
				IF dialog.exec(acctypeperioddialog(dialog.getcurrentrecordnumber(pdialog
																				,vlistname
																				,'ItemPeriodM')
												  ,dialog.getcurrentrecordnumber(pdialog
																				,vlistname
																				,'ItemPeriodD')
												  ,dialog.getcurrentrecordnumber(pdialog
																				,vlistname
																				,'ItemAccType'))) =
				   dialog.cmok
				THEN
					UPDATE tcontractacctypeperiod
					SET    acctype = sacctyperet
					WHERE  branch = vbranch
					AND    contracttype = scontractacctype
					AND    ((voriginalitemname IS NOT NULL AND itemname = voriginalitemname) OR
						  (voriginalitemname IS NULL AND itemname IS NULL))
					AND    intmonths = sintmonthsret
					AND    intdays = sintdaysret;
					fillaccounttypelist(pdialog, vlistname, sintmonthsret, sintdaysret);
				END IF;
			END;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END acctypeitemproc;

	FUNCTION acctypeperioddialog
	(
		pmonths  IN NUMBER
	   ,pdays    IN NUMBER
	   ,pacctype IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AccTypePeriodDialog';
		vdialog NUMBER;
	BEGIN
		vdialog := dialog.new('Account type compliance with the contract term'
							 ,0
							 ,0
							 ,60
							 ,6
							 ,pextid => cmethod_name);
		dialog.setdialogvalid(vdialog, 'ContractTools.AccTypePeriodProc');
	
		dialog.bevel(vdialog, 1, 1, 59, 3, dialog.bevel_frame);
	
		dialog.inputinteger(vdialog
						   ,'IntMonths'
						   ,14
						   ,2
						   ,'Contract validity period in months'
						   ,3
						   ,pcaption => 'Period:');
	
		dialog.inputinteger(vdialog
						   ,'IntDays'
						   ,28
						   ,2
						   ,'Contract validity period in days'
						   ,3
						   ,pcaption => 'months ');
	
		dialog.textlabel(vdialog, 'DayLab', 33, 2, 4, 'days');
	
		accounttype.makeitem(vdialog
							,'ItemAccountType'
							,14
							,3
							,10
							,'Acct type:'
							,'Acct type'
							,client.ct_persone
							,36
							,FALSE);
		dialog.setreadonly(vdialog, 'ItemAccountType', TRUE);
		accounttype.setdata(vdialog, 'ItemAccountType', pacctype);
	
		dialog.putnumber(vdialog, 'IntMonths', nvl(pmonths, 0));
	
		dialog.putnumber(vdialog, 'IntDays', nvl(pdays, 0));
	
		IF pmonths IS NOT NULL
		   AND pdays IS NOT NULL
		THEN
			dialog.setitemattributies(vdialog, 'IntMonths', dialog.selectoff);
			dialog.setitemattributies(vdialog, 'IntDays', dialog.selectoff);
		END IF;
	
		dialog.button(vdialog, 'Ok', 18, 5, 12, 'OK', dialog.cmok, 0, 'Save and exit dialog box');
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
	
		dialog.button(vdialog
					 ,'Cancel'
					 ,32
					 ,5
					 ,12
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel data saving and exit dialog box');
		RETURN vdialog;
	END acctypeperioddialog;

	PROCEDURE acctypeperiodproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		vmessage VARCHAR(100);
	BEGIN
		IF pwhat = dialog.wtdialogvalid
		THEN
			sintmonthsret := dialog.getnumber(pdialog, 'IntMonths');
			sintdaysret   := dialog.getnumber(pdialog, 'IntDays');
			sacctyperet   := accounttype.getdata(pdialog, 'ItemAccountType');
		
			IF sintmonthsret IS NULL
			   OR sintmonthsret < 0
			THEN
				vmessage := 'Invalid value';
				dialog.goitem(pdialog, 'IntMonths');
			ELSIF sintdaysret IS NULL
				  OR sintdaysret < 0
			THEN
				vmessage := 'Invalid value';
				dialog.goitem(pdialog, 'IntDays');
			ELSIF sintdaysret > 31
				  AND sintmonthsret > 0
			THEN
				vmessage := 'Term period cannot exceed 31 days~ if count of months is more than 0';
				dialog.goitem(pdialog, 'IntDays');
			ELSIF sacctyperet IS NULL
			THEN
				vmessage := 'Account type not specified';
				dialog.goitem(pdialog, 'ItemAccountType');
			END IF;
		
			IF vmessage IS NOT NULL
			THEN
				htools.message('Error', vmessage);
			END IF;
		END IF;
	END acctypeperiodproc;

	PROCEDURE copyacctypeperiod
	(
		ptypefrom IN NUMBER
	   ,ptypeto   IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.CopyAccTypePeriod';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		DELETE FROM tcontractacctypeperiod
		WHERE  branch = vbranch
		AND    contracttype = ptypeto;
	
		INSERT INTO tcontractacctypeperiod
			(branch
			,contracttype
			,acctype
			,intmonths
			,intdays
			,itemname
			,resident)
			(SELECT a.branch
				   ,ptypeto
				   ,a.acctype
				   ,a.intmonths
				   ,a.intdays
				   ,a.itemname
				   ,a.resident
			 FROM   tcontractacctypeperiod a
			 WHERE  branch = vbranch
			 AND    contracttype = ptypefrom);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END copyacctypeperiod;

	FUNCTION fillacctypeperiodarray
	(
		pcontracttype IN NUMBER
	   ,pitemname     IN VARCHAR := ''
	) RETURN typeacctypeperiodarray IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.FillAccTypePeriodArray';
		varracctypecount    NUMBER := 0;
		varracctypeinterval typeacctypeperiodarray;
		vbranch             NUMBER := seance.getbranch();
	
		CURSOR c1(poriginalitemname IN VARCHAR) IS
			SELECT intmonths
				  ,intdays
				  ,resident
				  ,acctype
			FROM   tcontractacctypeperiod
			WHERE  branch = vbranch
			AND    contracttype = pcontracttype
			AND    ((poriginalitemname IS NOT NULL AND itemname = poriginalitemname) OR
				  (poriginalitemname IS NULL AND itemname IS NULL))
			ORDER  BY intmonths
					 ,intdays;
	BEGIN
		varracctypeinterval.delete;
		FOR i IN c1(pitemname)
		LOOP
			varracctypecount := varracctypecount + 1;
			varracctypeinterval(varracctypecount).intmonths := i.intmonths;
			varracctypeinterval(varracctypecount).intdays := i.intdays;
			varracctypeinterval(varracctypecount).resident := i.resident;
			varracctypeinterval(varracctypecount).acctype := i.acctype;
		END LOOP;
	
		RETURN varracctypeinterval;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END fillacctypeperiodarray;

	FUNCTION buildremainarray
	(
		paopdate   IN OUT NOCOPY typedate
	   ,paremain   IN OUT NOCOPY typenumber
	   ,paprcdate  IN OUT NOCOPY typedate
	   ,pstartdate DATE
	   ,penddate   DATE
	   ,prp        typeremainparam
	) RETURN typeprcarray IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.BuildRemainArray';
		varet  typeprcarray;
		vcount PLS_INTEGER := 0;
	BEGIN
		IF (paopdate.count = 0)
		   OR (paopdate(paopdate.count) IS NOT NULL)
		THEN
			error.raiseerror('Information on tranches not loaded');
		END IF;
	
		FOR i IN 1 .. paopdate.count
		LOOP
			s.say(cmethod_name || ': ' || i || ' date ' || paopdate(i) || ' tranche ' ||
				  paremain(i) || ' percent date ' || paprcdate(i)
				 ,csay_level);
		END LOOP;
	
		FOR i IN REVERSE 1 .. paremain.count - 1
		LOOP
			paremain(i) := paremain(i + 1) - paremain(i);
		END LOOP;
	
		IF prp.checkremain = conlypositive
		THEN
			FOR i IN 1 .. paremain.count
			LOOP
				paremain(i) := greatest(paremain(i), 0);
			END LOOP;
		ELSIF prp.checkremain = conlynegative
		THEN
			FOR i IN 1 .. paremain.count
			LOOP
				paremain(i) := greatest(0, -paremain(i));
			END LOOP;
		END IF;
	
		FOR i IN 1 .. paopdate.count - 1
		LOOP
			IF paopdate(i) BETWEEN pstartdate AND penddate
			THEN
				vcount := vcount + 1;
				varet(vcount).pdate := paopdate(i);
			
				varet(vcount).premain := paremain(i + 1);
				varet(vcount).pprcdate := paprcdate(i);
			END IF;
		END LOOP;
	
		FOR i IN 1 .. varet.count
		LOOP
			s.say(cmethod_name || ': ' || i || ' date ' || varet(i).pdate || ' days ' || varet(i)
				  .pdays || ' percent ' || varet(i).ppercent || ' remain ' || varet(i).premain ||
				  ' percent date ' || varet(i).pprcdate
				 ,csay_level);
		END LOOP;
	
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END buildremainarray;

	FUNCTION fillremainarray
	(
		paccountno taccount.accountno%TYPE
	   ,pstartdate DATE
	   ,penddate   DATE
	   ,prp        typeremainparam := cemptyremainparam
	) RETURN typeprcarray IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.FillRemainArray[accountno]';
		vaopdate  typedate;
		varemain  typenumber;
		vaprcdate typedate;
		venddate  DATE := penddate + prp.includeenddate;
		varet     typeprcarray;
		vbranch   NUMBER := seance.getbranch();
	
		CURSOR curgettranchedate(pbranch tseance.branch%TYPE) IS
		
			SELECT opdate
				  ,SUM(VALUE)
				  ,MAX(prcdate)
			FROM   (
					
					SELECT CAST(NULL AS DATE) AS opdate
						   ,remain AS VALUE
						   ,CAST(NULL AS DATE) AS prcdate
					FROM   taccount
					WHERE  branch = pbranch
					AND    accountno = paccountno
					
					UNION ALL
					SELECT pstartdate AS opdate
						  ,0 AS VALUE
						  ,CAST(NULL AS DATE) AS prcdate
					FROM   dual
					
					UNION ALL
					SELECT venddate AS opdate
						  ,0 AS VALUE
						  ,CAST(NULL AS DATE) AS prcdate
					FROM   dual
					
					UNION ALL
					SELECT decode(sign(VALUE)
								 ,1
								 ,opdate + prp.creditcalcmode
								 ,-1
								 ,opdate + prp.debitcalcmode
								 ,opdate) AS opdate
						  ,VALUE
						  ,CAST(NULL AS DATE) AS prcdate
					FROM   (SELECT opdate AS opdate
								  ,SUM(VALUE) AS VALUE
							FROM   (SELECT /*+ ORDERED USE_NL(a b) INDEX(a iEntry_DebitAccount)*/
									 b.opdate AS opdate
									,-a.value AS VALUE
									FROM   tentry    a
										  ,tdocument b
									WHERE  a.branch = pbranch
									AND    a.debitaccount = paccountno
									AND    a.value > 0
									AND    b.branch = a.branch
									AND    b.docno = a.docno
									AND    b.opdate >= pstartdate
									AND    b.newdocno IS NULL
									UNION ALL
									SELECT /*+ ORDERED USE_NL(a b) INDEX(a iEntry_CreditAccount)*/
									 b.opdate
									,a.value AS VALUE
									FROM   tentry    a
										  ,tdocument b
									WHERE  a.branch = pbranch
									AND    a.creditaccount = paccountno
									AND    a.value > 0
									AND    b.branch = a.branch
									AND    b.docno = a.docno
									AND    b.opdate >= pstartdate
									AND    b.newdocno IS NULL)
							GROUP  BY opdate)
					
					UNION ALL
					SELECT nydate AS opdate
						  ,0 AS VALUE
						  ,CAST(NULL AS DATE) AS prcdate
					FROM   treferenceny
					WHERE  prp.includeny = cinclude
					AND    nydate > pstartdate
					AND    nydate < venddate)
			GROUP  BY opdate
			ORDER  BY opdate;
	
	BEGIN
		s.say(cmethod_name || ': account no ' || paccountno || ' start ' || pstartdate || ' end ' ||
			  penddate
			 ,csay_level);
	
		IF (pstartdate IS NULL)
		   OR (venddate IS NULL)
		   OR (pstartdate >= venddate)
		THEN
			RETURN varet;
		END IF;
	
		OPEN curgettranchedate(vbranch);
		FETCH curgettranchedate BULK COLLECT
			INTO vaopdate
				,varemain
				,vaprcdate;
		CLOSE curgettranchedate;
	
		varet := buildremainarray(vaopdate, varemain, vaprcdate, pstartdate, venddate, prp);
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			IF curgettranchedate%ISOPEN
			THEN
				CLOSE curgettranchedate;
			END IF;
			error.save(cmethod_name);
			RAISE;
	END fillremainarray;

	FUNCTION fillremainarray
	(
		paccountnoarr IN typeaccountnoarray
	   ,pstartdate    IN DATE
	   ,penddate      IN DATE
	   ,prp           IN typeremainparam := cemptyremainparam
	) RETURN typeprcarray IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.FillRemainArray';
		vaopdate  typedate;
		varemain  typenumber;
		vaprcdate typedate;
		venddate  DATE := penddate + prp.includeenddate;
		vaccnoarr typeaccountnoarray;
		j         NUMBER := 1;
		varet     typeprcarray;
		vbranch   NUMBER := seance.getbranch();
	
		CURSOR curgettranchedate(pbranch tseance.branch%TYPE) IS
		
			SELECT opdate
				  ,SUM(VALUE)
				  ,MAX(prcdate)
			FROM   (
					
					SELECT /*+ ORDERED USE_NL(t a) */
					 CAST(NULL AS DATE) AS opdate
					,remain AS VALUE
					,CAST(NULL AS DATE) AS prcdate
					FROM   ttmpaccountlist t
						   ,taccount        a
					WHERE  a.branch = pbranch
					AND    a.accountno = t.accountno
					
					UNION ALL
					SELECT pstartdate AS opdate
						  ,0 AS VALUE
						  ,CAST(NULL AS DATE) AS prcdate
					FROM   dual
					
					UNION ALL
					SELECT venddate AS opdate
						  ,0 AS VALUE
						  ,CAST(NULL AS DATE) AS prcdate
					FROM   dual
					
					UNION ALL
					SELECT decode(sign(VALUE)
								 ,1
								 ,opdate + prp.creditcalcmode
								 ,-1
								 ,opdate + prp.debitcalcmode
								 ,opdate) AS opdate
						  ,VALUE
						  ,CAST(NULL AS DATE) AS prcdate
					FROM   (SELECT opdate AS opdate
								  ,SUM(VALUE) AS VALUE
							FROM   (SELECT /*+ ORDERED USE_NL(t a b) INDEX(a iEntry_DebitAccount)*/
									 b.opdate AS opdate
									,-a.value AS VALUE
									FROM   ttmpaccountlist t
										  ,tentry          a
										  ,tdocument       b
									WHERE  a.branch = pbranch
									AND    a.debitaccount = t.accountno
									AND    a.value > 0
									AND    b.branch = a.branch
									AND    b.docno = a.docno
									AND    b.opdate >= pstartdate
									AND    b.newdocno IS NULL
									UNION ALL
									SELECT /*+ ORDERED USE_NL(t a b) INDEX(a iEntry_CreditAccount)*/
									 b.opdate
									,a.value AS VALUE
									FROM   ttmpaccountlist t
										  ,tentry          a
										  ,tdocument       b
									WHERE  a.branch = pbranch
									AND    a.creditaccount = t.accountno
									AND    a.value > 0
									AND    b.branch = a.branch
									AND    b.docno = a.docno
									AND    b.opdate >= pstartdate
									AND    b.newdocno IS NULL)
							GROUP  BY opdate)
					
					UNION ALL
					SELECT nydate AS opdate
						  ,0 AS VALUE
						  ,CAST(NULL AS DATE) AS prcdate
					FROM   treferenceny
					WHERE  prp.includeny = cinclude
					AND    nydate > pstartdate
					AND    nydate < venddate)
			GROUP  BY opdate
			ORDER  BY opdate;
	
	BEGIN
		s.say(cmethod_name || ': start ' || pstartdate || ' end ' || penddate, csay_level);
	
		IF (pstartdate IS NULL)
		   OR (venddate IS NULL)
		   OR (pstartdate >= venddate)
		THEN
			RETURN varet;
		END IF;
	
		FOR i IN 1 .. paccountnoarr.count
		LOOP
			s.say(cmethod_name || ': account no ' || paccountnoarr(i), csay_level);
			IF paccountnoarr(i) IS NOT NULL
			THEN
				vaccnoarr(j) := paccountnoarr(i);
				j := j + 1;
			END IF;
		END LOOP;
	
		DELETE FROM ttmpaccountlist;
		FORALL i IN 1 .. vaccnoarr.count
			INSERT INTO ttmpaccountlist VALUES (vaccnoarr(i));
	
		OPEN curgettranchedate(vbranch);
		FETCH curgettranchedate BULK COLLECT
			INTO vaopdate
				,varemain
				,vaprcdate;
		CLOSE curgettranchedate;
	
		varet := buildremainarray(vaopdate, varemain, vaprcdate, pstartdate, venddate, prp);
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			IF curgettranchedate%ISOPEN
			THEN
				CLOSE curgettranchedate;
			END IF;
			error.save(cmethod_name);
			RAISE;
	END fillremainarray;

	FUNCTION mergepercent
	(
		paremain      typeprcarray
	   ,paprc         referenceprchistory.typeprcarray
	   ,pfixedprcdate DATE := NULL
	   ,pdebugon      IN BOOLEAN := FALSE
	) RETURN typeprcarray IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.MergePercent';
		vprcrecord referenceprchistory.typeprcrecord;
		vprcdates  typedate;
		m          PLS_INTEGER := 1;
		n          PLS_INTEGER := 1;
		vcount     PLS_INTEGER;
		varet      typeprcarray;
	BEGIN
		IF paremain.count = 0
		THEN
			RETURN paremain;
		ELSIF (paprc IS NULL)
			  OR (paprc.count = 0)
		THEN
			error.raiseerror('Array of interest rates not specified');
		END IF;
	
		IF pdebugon
		THEN
			FOR i IN 1 .. paremain.count
			LOOP
				s.say(cmethod_name || ': ' || i || ' date ' || paremain(i).pdate || ' days ' || paremain(i)
					  .pdays || ' percent ' || paremain(i).ppercent || ' remain ' || paremain(i)
					  .premain || ' percent date ' || paremain(i).pprcdate || ' rate base ' || paremain(i)
					  .pratebase
					 ,csay_level);
			END LOOP;
		END IF;
	
		IF pfixedprcdate IS NULL
		THEN
			vcount := 1;
			vprcdates(vcount) := paprc(1).pdate;
		
			FOR i IN 2 .. paprc.count
			LOOP
				IF vprcdates(vcount) < paprc(i).pdate
				THEN
					vcount := vcount + 1;
					vprcdates(vcount) := paprc(i).pdate;
				END IF;
			END LOOP;
		
			IF vprcdates(1) > paremain(1).pdate
			THEN
				error.raiseerror('Not found value of interest rate for date <' || paremain(1)
								 .pdate || '>.');
			END IF;
		
			vcount := 0;
			LOOP
				EXIT WHEN m > paremain.count;
			
				IF vprcdates.count < n
				THEN
					vcount := vcount + 1;
					varet(vcount) := paremain(m);
					varet(vcount).pprcdate := vprcdates(vprcdates.count);
					m := m + 1;
				ELSIF vprcdates(n) > paremain(m).pdate
				THEN
					vcount := vcount + 1;
					varet(vcount) := paremain(m);
					varet(vcount).pprcdate := vprcdates(n - 1);
					m := m + 1;
				ELSIF vprcdates(n) = paremain(m).pdate
				THEN
					vcount := vcount + 1;
					varet(vcount) := paremain(m);
					varet(vcount).pprcdate := vprcdates(n);
					m := m + 1;
					n := n + 1;
				ELSIF vprcdates(n) > paremain(1).pdate
				THEN
					vcount := vcount + 1;
					varet(vcount) := paremain(m - 1);
					varet(vcount).pdate := vprcdates(n);
					varet(vcount).pprcdate := vprcdates(n);
					n := n + 1;
				ELSE
					n := n + 1;
				END IF;
			END LOOP;
		ELSE
			varet := paremain;
		END IF;
	
		FOR i IN 1 .. varet.count - 1
		LOOP
			varet(i).pdays := varet(i + 1).pdate - varet(i).pdate;
		END LOOP;
		varet(varet.count).pdays := 0;
	
		IF pfixedprcdate IS NULL
		THEN
			FOR i IN 1 .. varet.count
			LOOP
				varet(i).ppercent := referenceprchistory.getprc(paprc
															   ,varet(i).pdate
															   ,varet(i).pdays
															   ,varet(i).premain
															   ,FALSE
															   ,TRUE
															   ,varet(i).pratebase);
			END LOOP;
		ELSE
			FOR i IN 1 .. varet.count
			LOOP
			
				vprcrecord := referenceprchistory.getprcrecord(paprc
															  ,pfixedprcdate
															  ,varet        (i).pdays
															  ,varet        (i).premain
															  ,FALSE
															  ,TRUE);
				varet(i).ppercent := vprcrecord.pvalue;
				varet(i).pratebase := vprcrecord.pratebase;
				varet(i).pprcdate := vprcrecord.pdate;
			
			END LOOP;
		END IF;
	
		IF pdebugon
		THEN
			FOR i IN 1 .. varet.count
			LOOP
				s.say(cmethod_name || ': ' || i || ' date ' || varet(i).pdate || ' days ' || varet(i)
					  .pdays || ' percent ' || varet(i).ppercent || ' remain ' || varet(i).premain ||
					  ' percent date ' || varet(i).pprcdate || ' rate base ' || varet(i).pratebase
					 ,csay_level);
			END LOOP;
		END IF;
	
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END mergepercent;

	FUNCTION getaverageremain
	(
		paccountno taccount.accountno%TYPE
	   ,pstartdate DATE
	   ,penddate   DATE
	   ,pclosedate DATE := NULL
	   ,prp        typeremainparam := cemptyremainparam
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetAverageRemain';
		vremainarray typeprcarray;
		vsum         NUMBER := 0;
	BEGIN
		IF pclosedate IS NULL
		THEN
			vremainarray := fillremainarray(paccountno, pstartdate, penddate, prp);
		ELSE
			vremainarray := fillremainarray(paccountno, pstartdate, pclosedate, prp);
		END IF;
	
		IF vremainarray IS NULL
		THEN
			RETURN 0;
		END IF;
	
		FOR i IN 1 .. vremainarray.count - 1
		LOOP
			vremainarray(i).pdays := vremainarray(i + 1).pdate - vremainarray(i).pdate;
		END LOOP;
		vremainarray(vremainarray.count).pdays := 0;
	
		FOR i IN 1 .. vremainarray.count
		LOOP
			s.say(cmethod_name || ': remain ' || vremainarray(i).premain || ' days ' || vremainarray(i)
				  .pdays
				 ,csay_level);
			vsum := vsum + vremainarray(i).premain * vremainarray(i).pdays;
		END LOOP;
	
		RETURN vsum /(penddate - pstartdate);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getaverageremain;

	FUNCTION getentryarray
	(
		paccount   IN taccount.accountno%TYPE
	   ,pstartdate IN DATE
	   ,penddate   IN DATE
	   ,pmaxcount  IN NUMBER
	   ,parchive   IN BOOLEAN
	) RETURN contracttypeschema.tentryarray IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetEntryArray';
		vstartdate DATE := nvl(pstartdate, cmindate);
		venddate   DATE := nvl(penddate, cmaxdate);
		vmaxcount  NUMBER := nvl(pmaxcount, 999999999);
		vaopdate   types.arrdate;
		vadocno    types.arrnum;
		vano       types.arrnum;
		vadebit    types.arrnum;
		vaentvalue types.arrnum;
		vaentcode  types.arrnum;
		varemain   types.arrnum;
		varesult   contracttypeschema.tentryarray;
		vcount     PLS_INTEGER := 0;
		vbranch    NUMBER := seance.getbranch();
	
		CURSOR curentries
		(
			pbranch    NUMBER
		   ,pstartdate DATE
		) IS
			SELECT opdate
				  ,docno
				  ,no
				  ,debit
				  ,VALUE
				  ,debitentcode
				  ,remain
			FROM   (SELECT d.opdate
						  ,e.docno
						  ,e.no
						  ,debit
						  ,e.value
						  ,e.debitentcode
						  ,0 AS remain
					FROM   (SELECT branch
								  ,docno
								  ,no
								  ,1 AS debit
								  ,VALUE
								  ,debitentcode
							FROM   tentry
							WHERE  branch = pbranch
							AND    debitaccount = paccount
							UNION ALL
							SELECT branch
								  ,docno
								  ,no
								  ,0 AS debit
								  ,VALUE
								  ,debitentcode
							FROM   tentry
							WHERE  branch = pbranch
							AND    creditaccount = paccount) e
					JOIN   tdocument d
					ON     d.branch = e.branch
					AND    d.docno = e.docno
					WHERE  d.opdate >= pstartdate
					AND    d.newdocno IS NULL
					UNION ALL
					SELECT cmaxdate AS opdate
						  ,0
						  ,0
						  ,0
						  ,0
						  ,0
						  ,a.remain
					FROM   taccount a
					WHERE  a.branch = pbranch
					AND    a.accountno = paccount
					ORDER  BY opdate DESC
							 ,docno  DESC
							 ,no     DESC);
	
		CURSOR curentrieswitharc
		(
			pbranch    NUMBER
		   ,pstartdate DATE
		) IS
			SELECT opdate
				  ,docno
				  ,no
				  ,debit
				  ,VALUE
				  ,debitentcode
				  ,remain
			FROM   (SELECT d.opdate
						  ,e.docno
						  ,e.no
						  ,debit
						  ,e.value
						  ,e.debitentcode
						  ,0 AS remain
					FROM   (SELECT branch
								  ,docno
								  ,no
								  ,1 AS debit
								  ,VALUE
								  ,debitentcode
							FROM   tentry
							WHERE  branch = pbranch
							AND    debitaccount = paccount
							UNION ALL
							SELECT branch
								  ,docno
								  ,no
								  ,0 AS debit
								  ,VALUE
								  ,debitentcode
							FROM   tentry
							WHERE  branch = pbranch
							AND    creditaccount = paccount) e
					JOIN   tdocument d
					ON     d.branch = e.branch
					AND    d.docno = e.docno
					WHERE  d.opdate >= pstartdate
					AND    d.newdocno IS NULL
					UNION ALL
					SELECT da.opdate
						  ,ea.docno
						  ,ea.no
						  ,ea.debit
						  ,ea.value
						  ,ea.debitentcode
						  ,0 AS remain
					FROM   (SELECT branch
								  ,docno
								  ,no
								  ,1            AS debit
								  ,VALUE        AS VALUE
								  ,debitentcode
							FROM   tentryarc
							WHERE  branch = pbranch
							AND    debitaccount = paccount
							UNION ALL
							SELECT branch
								  ,docno
								  ,no
								  ,0 AS debit
								  ,VALUE
								  ,debitentcode
							FROM   tentryarc
							WHERE  branch = pbranch
							AND    creditaccount = paccount) ea
					JOIN   tdocumentarc da
					ON     da.branch = ea.branch
					AND    da.docno = ea.docno
					WHERE  da.opdate >= pstartdate
					AND    da.newdocno IS NULL
					UNION ALL
					SELECT cmaxdate AS opdate
						  ,0
						  ,0
						  ,0
						  ,0
						  ,0
						  ,a.remain
					FROM   taccount a
					WHERE  a.branch = pbranch
					AND    a.accountno = paccount
					ORDER  BY opdate DESC
							 ,docno  DESC
							 ,no     DESC);
	BEGIN
		s.say(cmethod_name || ': enter; pAccount=' || paccount || ' pStartDate=' || pstartdate ||
			  ' pEndDate=' || penddate || ' pMaxCount=' || pmaxcount || ' pArchive=' || CASE WHEN
			  parchive THEN 'true' ELSE 'false' END
			 ,1);
		IF NOT parchive
		THEN
			OPEN curentries(vbranch, vstartdate);
			FETCH curentries BULK COLLECT
				INTO vaopdate
					,vadocno
					,vano
					,vadebit
					,vaentvalue
					,vaentcode
					,varemain;
			CLOSE curentries;
		ELSE
			OPEN curentrieswitharc(vbranch, vstartdate);
			FETCH curentrieswitharc BULK COLLECT
				INTO vaopdate
					,vadocno
					,vano
					,vadebit
					,vaentvalue
					,vaentcode
					,varemain;
			CLOSE curentrieswitharc;
		END IF;
		s.say(cmethod_name || ': vaOpDate.count=' || vaopdate.count || ' current remain=' ||
			  varemain(1)
			 ,1);
		IF vaopdate.count > 1
		THEN
		
			varemain(2) := varemain(1);
			FOR i IN 2 .. varemain.count
			LOOP
				IF vadebit(i) > 0
				THEN
					varemain(i + 1) := varemain(i) + vaentvalue(i);
				ELSE
					varemain(i + 1) := varemain(i) - vaentvalue(i);
				END IF;
			END LOOP;
		
			FOR i IN 2 .. vaopdate.count
			LOOP
				IF vaopdate(i) <= venddate
				THEN
					vcount := vcount + 1;
					IF vcount > vmaxcount
					THEN
						EXIT;
					END IF;
					varesult(vcount).docno := vadocno(i);
					varesult(vcount).no := vano(i);
					varesult(vcount).accountno := paccount;
					varesult(vcount).debit := vadebit(i) > 0;
					varesult(vcount).entvalue := vaentvalue(i);
					varesult(vcount).entcode := vaentcode(i);
					varesult(vcount).remain := varemain(i);
				
					varesult(vcount).opdate := vaopdate(i);
				
					s.say(cmethod_name || ': DocNo=' || varesult(vcount).docno || ' No=' || varesult(vcount).no ||
						  ' EntValue=' || varesult(vcount).entvalue || ' Remain=' || varesult(vcount)
						  .remain || ' opDate=' || to_char(varesult(vcount).opdate, 'dd.mm.yyyy')
						 ,1);
				END IF;
			END LOOP;
		END IF;
		s.say(cmethod_name || ': leave; vaResult.count=' || varesult.count, 1);
		RETURN varesult;
	EXCEPTION
		WHEN OTHERS THEN
			IF curentries%ISOPEN
			THEN
				CLOSE curentries;
			END IF;
			IF curentrieswitharc%ISOPEN
			THEN
				CLOSE curentrieswitharc;
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getentryinfo
	(
		paccount        IN taccount.accountno%TYPE
	   ,pstartdate      IN DATE
	   ,penddate        IN DATE
	   ,pmaxcount       IN NUMBER
	   ,parchive        IN BOOLEAN
	   ,pignoreentcodes IN sql_typenumbers
	) RETURN contracttypeschema.typeentryinfoarray IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.GetEntryInfo';
		vresult      contracttypeschema.typeentryinfoarray;
		vaentryarray contracttypeschema.tentryarray;
	BEGIN
		vaentryarray := getentryarray(paccount, pstartdate, penddate, pmaxcount, parchive);
		FOR i IN 1 .. vaentryarray.count
		LOOP
			vresult(i).docno := vaentryarray(i).docno;
			vresult(i).no := vaentryarray(i).no;
			vresult(i).accountno := vaentryarray(i).accountno;
			vresult(i).entvalue := vaentryarray(i).entvalue;
			vresult(i).entcode := vaentryarray(i).entcode;
			vresult(i).debit := service.iif(vaentryarray(i).debit, 1, 0);
			vresult(i).remain := vaentryarray(i).remain;
		END LOOP;
	
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getentryinfo;

	FUNCTION loadparam
	(
		pctype       tcontract.type%TYPE
	   ,paitem       tblschitem
	   ,pdoexception BOOLEAN := TRUE
	   ,pstartdate   DATE := NULL
	) RETURN types.arrstr1000 IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.LoadParam[ctype]';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		cstartdate   CONSTANT DATE := nvl(pstartdate, seance.getoperdate());
		verrmsg VARCHAR2(4000) := NULL;
		varet   types.arrstr1000;
	BEGIN
		s.say(cmethod_name || ': for type ' || pctype || ' from date ' || htools.d2s(pstartdate)
			 ,csay_level);
	
		SELECT VALUE BULK COLLECT
		INTO   varet
		FROM   (SELECT /*+ ORDERED USE_NL (p) INDEX (p pk_CTypeParameters) */
				 p.value
				,nvl(p.startdate, cmindate) AS startdate
				,MAX(nvl(p.startdate, cmindate)) over(PARTITION BY p.key) AS maxstartdate
				FROM   TABLE(paitem) d
				LEFT   OUTER JOIN tcontracttypeparameters p
				ON     p.branch = cbranch
				AND    p.contracttype = pctype
				AND    p.key = upper(d.name)
				AND    nvl(p.startdate, cmindate) <= cstartdate
				ORDER  BY d.idx)
		WHERE  startdate = maxstartdate;
	
		IF pdoexception
		THEN
			FOR i IN 1 .. paitem.count
			LOOP
				s.say(cmethod_name || ': ' || paitem(i).name || ' ' || varet(i), csay_level);
				IF (paitem(i).attr1 IN (ctype, cboth))
				   AND (paitem(i).attr2 = cmandatory)
				   AND (varet(i) IS NULL)
				THEN
					verrmsg := verrmsg || ', ' || paitem(i).spec;
				END IF;
			END LOOP;
			IF verrmsg IS NOT NULL
			THEN
				error.raiseerror('For contract type <' || pctype || '> not defined parameters:' ||
								 substr(verrmsg, 2));
			END IF;
		END IF;
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END loadparam;

	FUNCTION loadparam
	(
		pcno         tcontract.no%TYPE
	   ,paitem       tblschitem
	   ,pactparam    types.arrstr1000
	   ,pdoexception BOOLEAN := TRUE
	) RETURN types.arrstr1000 IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.LoadParam[contract]';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		vaaux   types.arrstr1000;
		verrmsg VARCHAR2(4000) := NULL;
		i       PLS_INTEGER;
		varet   types.arrstr1000;
	BEGIN
		s.say(cmethod_name || ': for contract ' || pcno, csay_level);
	
		IF (pactparam IS NULL)
		   OR (pactparam.count = 0)
		THEN
			FOR i IN 1 .. paitem.count
			LOOP
				varet(i) := NULL;
			END LOOP;
		ELSE
			varet := pactparam;
		END IF;
	
		SELECT /*+ ORDERED USE_NL (p) INDEX (p pk_CNoParameters) */
		 p.value BULK COLLECT
		INTO   vaaux
		FROM   TABLE(paitem) d
		LEFT   OUTER JOIN tcontractparameters p
		ON     p.branch = cbranch
		AND    p.contractno = pcno
		AND    p.key = upper(d.name)
		ORDER  BY d.idx;
	
		FOR i IN 1 .. vaaux.count
		LOOP
			IF vaaux(i) IS NOT NULL
			THEN
				varet(i) := vaaux(i);
			END IF;
		END LOOP;
	
		IF pdoexception
		THEN
			FOR i IN 1 .. paitem.count
			LOOP
				s.say(cmethod_name || ': ' || paitem(i).name || ' ' || varet(i), csay_level);
				IF (paitem(i).attr1 IN (ccont))
				   AND (paitem(i).attr2 = cmandatory)
				   AND (varet(i) IS NULL)
				THEN
					verrmsg := verrmsg || ', ' || paitem(i).spec;
				END IF;
			END LOOP;
			IF verrmsg IS NOT NULL
			THEN
				error.raiseerror('For contract <' || pcno || '> not defined parameters:' ||
								 substr(verrmsg, 2));
			END IF;
		END IF;
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END loadparam;

	FUNCTION loadschemaparam
	(
		pschemacode tcontractschemas.type%TYPE
	   ,paitem      tblschitem
	) RETURN types.arrstr1000 IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.LoadSchemaParam';
		cbranch      CONSTANT NUMBER := seance.getbranch();
		varesult types.arrstr1000;
	BEGIN
		t.enter(cmethod_name, 'for schema ' || pschemacode);
	
		SELECT /*+ ORDERED USE_NL (p) INDEX (p pk_ContractSchParameters) */
		 p.value BULK COLLECT
		INTO   varesult
		FROM   TABLE(paitem) d
		LEFT   OUTER JOIN tcontractschparameters p
		ON     p.branch = cbranch
		AND    p.sch = pschemacode
		AND    p.key = upper(d.name)
		ORDER  BY d.idx;
	
		t.leave(cmethod_name, 'Counts ' || varesult.count);
		RETURN varesult;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION loadcaccounts
	(
		pcno     IN tcontract.no%TYPE
	   ,paicodes IN tblschitem
	) RETURN typeaccarray IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.LoadCAccounts[Codes]';
		vresult typeaccarray;
		cbranch CONSTANT NUMBER := seance.getbranch;
	BEGIN
		SELECT /*+ ORDERED USE_NL (ci a) INDEX (ci iContractItem_No) INDEX (a iAccount_AccountNo) */
		 a.accountno
		,to_number(d.name) AS itemcode
		,a.accounttype
		,a.idclient
		,nvl(a.remain, 0) AS remain
		,nvl(a.available, 0) AS available
		,a.acct_stat
		,a.currencyno
		,nvl(a.overdraft, 0) AS overdraft
		,nvl(a.lowremain, 0) AS lowremain
		,nvl(a.debitreserve, 0) AS debitreserve
		,nvl(a.creditreserve, 0) AS creditreserve
		,a.stat
		,a.createdate
		,a.closedate
		,a.updatesysdate BULK COLLECT
		INTO   vresult
		FROM   TABLE(paicodes) d
		LEFT   OUTER JOIN tcontractitem ci
		ON     ci.branch = cbranch
		AND    ci.no = pcno
		AND    ci.itemcode = to_number(d.name)
		LEFT   OUTER JOIN taccount a
		ON     a.branch = ci.branch
		AND    a.accountno = ci.key
		ORDER  BY d.idx;
		FOR i IN 1 .. vresult.count
		LOOP
			s.say(cmethod_name || ' input code: ' || paicodes(i).name || ' - ' ||
				  to_number(paicodes(i).name) || ' output: ' || vresult(i).itemcode
				 ,csay_level);
		END LOOP;
	
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END loadcaccounts;

	FUNCTION loadcaccounts
	(
		pctype       tcontract.type%TYPE
	   ,pcno         tcontract.no%TYPE
	   ,paitem       tblschitem
	   ,pdoexception BOOLEAN := TRUE
	) RETURN typeaccarray IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.LoadCAccounts[Contract]';
		vbranch NUMBER := seance.getbranch();
		varet   typeaccarray;
	BEGIN
		s.say(cmethod_name || ': contract type ' || pctype || ' no ' || pcno, csay_level);
	
		SELECT /*+ ORDERED USE_NL (n i a) INDEX (n PK_TCONTRACTTYPEITEMNAME) INDEX (i iContractItem_No) INDEX (a iAccount_AccountNo) */
		 a.accountno
		,n.itemcode
		,a.accounttype
		,a.idclient
		,nvl(a.remain, 0) AS remain
		,nvl(a.available, 0) AS available
		,a.acct_stat
		,a.currencyno
		,nvl(a.overdraft, 0) AS overdraft
		,nvl(a.lowremain, 0) AS lowremain
		,nvl(a.debitreserve, 0) AS debitreserve
		,nvl(a.creditreserve, 0) AS creditreserve
		,a.stat
		,a.createdate
		,a.closedate
		,a.updatesysdate BULK COLLECT
		INTO   varet
		FROM   TABLE(paitem) d
		LEFT   OUTER JOIN tcontracttypeitemname n
		ON     n.branch = vbranch
		AND    n.contracttype = pctype
		AND    n.itemname = upper(d.name)
		LEFT   OUTER JOIN tcontractitem i
		ON     i.branch = n.branch
		AND    i.no = pcno
		AND    i.itemcode = n.itemcode
		LEFT   OUTER JOIN taccount a
		ON     a.branch = i.branch
		AND    a.accountno = i.key
		ORDER  BY d.idx;
		IF pdoexception
		THEN
			NULL;
		END IF;
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END loadcaccounts;

	FUNCTION loadbaccounts
	(
		pctype       tcontract.type%TYPE
	   ,paitem       tblschitem
	   ,pdoexception BOOLEAN := TRUE
	) RETURN typeaccarray IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.LoadBAccounts';
		vbranch NUMBER := seance.getbranch();
		verrmsg VARCHAR2(4000) := NULL;
		varet   typeaccarray;
	BEGIN
		s.say(cmethod_name || ': contract type ' || pctype, csay_level);
		SELECT /*+ ORDERED USE_NL(p a) INDEX (p pk_CTypeParameters) INDEX (a iAccount_AccountNo) */
		 a.accountno
		,NULL
		,a.accounttype
		,a.idclient
		,nvl(a.remain, 0) AS remain
		,nvl(a.available, 0) AS available
		,a.acct_stat
		,a.currencyno
		,nvl(a.overdraft, 0) AS overdraft
		,nvl(a.lowremain, 0) AS lowremain
		,nvl(a.debitreserve, 0) AS debitreserve
		,nvl(a.creditreserve, 0) AS creditreserve
		,a.stat
		,a.createdate
		,a.closedate
		,a.updatesysdate BULK COLLECT
		INTO   varet
		FROM   TABLE(paitem) d
		LEFT   OUTER JOIN tcontracttypeparameters p
		ON     p.branch = vbranch
		AND    p.contracttype = pctype
		AND    p.key = upper(d.name)
		LEFT   OUTER JOIN taccount a
		ON     a.branch = p.branch
		AND    a.accountno = p.value
		ORDER  BY d.idx;
		IF pdoexception
		THEN
			FOR i IN 1 .. varet.count
			LOOP
				IF varet(i).accountno IS NULL
				THEN
					verrmsg := verrmsg || ', ' || paitem(i).spec;
				END IF;
			END LOOP;
			IF verrmsg IS NOT NULL
			THEN
				error.raiseerror('For contract type [' || pctype ||
								 '], bank accounts not defined:' || substr(verrmsg, 2));
			END IF;
		END IF;
		RETURN varet;
	EXCEPTION
		WHEN no_data_found THEN
			error.saveraise(cmethod_name
						   ,error.errorconst
						   ,'Error loading bank accounts for contract type [' || pctype || ']');
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END loadbaccounts;

	FUNCTION loadrateid
	(
		pctype IN tcontract.type%TYPE
	   ,paitem IN tblschitem
	) RETURN types.arrnum IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.LoadRateID[contract]';
		cbranch      CONSTANT NUMBER := seance.getbranch;
		vresult   types.arrnum;
		vobjectno tpercentbelong.objectno%TYPE := to_char(pctype);
	BEGIN
		s.say(cmethod_name || ': contract no ' || vobjectno, csay_level);
		SELECT /*+ ORDERED USE_NL (p) INDEX (p pk_PercentBelong_Object) */
		 p.id BULK COLLECT
		INTO   vresult
		FROM   TABLE(paitem) d
		LEFT   OUTER JOIN tpercentbelong p
		ON     p.branch = cbranch
		AND    p.category = referenceprchistory.ccontracttype
		AND    p.objectno = vobjectno
		AND    p.objectcat = d.name
		ORDER  BY d.idx;
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION loadrate
	(
		pctype       tcontract.type%TYPE
	   ,paitem       tblschitem
	   ,pdoexception BOOLEAN := TRUE
	) RETURN trate IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.LoadRate[Type]';
		vaid    types.arrnum;
		vaempty referenceprchistory.typeprcarray;
		varet   trate;
	BEGIN
		s.say(cmethod_name || ': contract type ' || pctype, csay_level);
	
		vaid := loadrateid(pctype, paitem);
		FOR i IN 1 .. vaid.count
		LOOP
			IF vaid(i) IS NOT NULL
			THEN
				varet(i) := referenceprchistory.getprcdata(vaid(i));
			ELSE
				IF pdoexception
				   AND (paitem(i).attr1 IN (ctype, cboth))
				THEN
					error.raiseerror('Not specified interest rate [' || paitem(i).spec ||
									 '] for contract type [' || pctype || ']');
				ELSE
					varet(i) := vaempty;
				END IF;
			END IF;
		END LOOP;
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END loadrate;

	FUNCTION loadrateid
	(
		pcno   IN tcontract.no%TYPE
	   ,paitem IN tblschitem
	) RETURN types.arrnum IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.LoadRateID [contract]';
		cbranch      CONSTANT NUMBER := seance.getbranch;
		vresult types.arrnum;
	BEGIN
		s.say(cmethod_name || ': contract no ' || pcno, csay_level);
		SELECT /*+ ORDERED USE_NL (p) INDEX (p pk_PercentBelong_Object) */
		 p.id BULK COLLECT
		INTO   vresult
		FROM   TABLE(paitem) d
		LEFT   OUTER JOIN tpercentbelong p
		ON     p.branch = cbranch
		AND    p.category = referenceprchistory.ccontract
		AND    p.objectno = pcno
		AND    p.objectcat = d.name
		ORDER  BY d.idx;
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION loadrate
	(
		pcno         tcontract.no%TYPE
	   ,paitem       tblschitem
	   ,pctrate      trate
	   ,pdoexception BOOLEAN := TRUE
	) RETURN trate IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.LoadRate[Contract]';
		vaid    types.arrnum;
		vaempty referenceprchistory.typeprcarray;
		varet   trate := pctrate;
	BEGIN
		s.say(cmethod_name || ': contract no ' || pcno, csay_level);
		vaid := loadrateid(pcno, paitem);
		FOR i IN 1 .. vaid.count
		LOOP
			IF vaid(i) IS NOT NULL
			THEN
				varet(i) := referenceprchistory.getprcdata(vaid(i));
			ELSE
				IF paitem(i).attr1 = ccont
				THEN
					IF pdoexception
					THEN
						error.raiseerror('Not specified interest rate <' || paitem(i).spec ||
										 '> for contract <' || pcno || '>');
					ELSE
						varet(i) := vaempty;
					END IF;
				END IF;
			END IF;
		END LOOP;
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END loadrate;

	FUNCTION loadentrycodes
	(
		paitem       tblschitem
	   ,pdoexception BOOLEAN := TRUE
	) RETURN types.arrnum IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.LoadEntryCodes';
		vbranch NUMBER := seance.getbranch();
		varet   types.arrnum;
	BEGIN
		s.say(cmethod_name || ': >>>', csay_level);
		SELECT /*+ ORDERED USE_NL (e) INDEX (e iReferenceEntry_Ident) */
		 e.code BULK COLLECT
		INTO   varet
		FROM   TABLE(paitem) n
		JOIN   treferenceentry e
		ON     e.branch = vbranch
		AND    e.ident = upper(n.name)
		ORDER  BY n.idx;
		IF pdoexception
		   AND (varet.count <> paitem.count)
		THEN
			error.raiseerror('Error loading entry codes');
		END IF;
		s.say(cmethod_name || ': <<<', csay_level);
		RETURN varet;
	EXCEPTION
		WHEN no_data_found THEN
			IF pdoexception
			THEN
				error.saveraise(cmethod_name, error.errorconst, 'Error loading entry codes');
			END IF;
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END loadentrycodes;

	FUNCTION loaditemcodes
	(
		pctype       IN tcontract.type%TYPE
	   ,paitem       IN tblschitem
	   ,pdoexception IN BOOLEAN
	) RETURN types.arrnum IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.LoadItemCodes';
		vresult types.arrnum;
		cbranch CONSTANT NUMBER := seance.getbranch;
	BEGIN
		SELECT /*+ ORDERED USE_NL (ctin) INDEX (pk_tContractTypeItemName) */
		 itemcode BULK COLLECT
		INTO   vresult
		FROM   TABLE(paitem) n
		LEFT   OUTER JOIN tcontracttypeitemname ctin
		ON     ctin.branch = cbranch
		AND    ctin.contracttype = pctype
		AND    ctin.itemname = upper(n.name)
		ORDER  BY n.idx;
		IF pdoexception
		THEN
			FOR i IN 1 .. vresult.count
			LOOP
				s.say(cmethod_name || ': result(' || i || ') = ' || vresult(i), csay_level);
				IF vresult(i) IS NULL
				THEN
					error.raiseerror('Cannot load items of contract type [' || pctype || ']');
				END IF;
			END LOOP;
		END IF;
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END loaditemcodes;

	FUNCTION loaditemnames(pctype tcontract.type%TYPE) RETURN types.arrstr40 IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.LoadItemNames';
		vacode  types.arrnum;
		vaname  types.arrstr40;
		varet   types.arrstr40;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethod_name, 'pCType=' || pctype, 1);
		SELECT itemcode
			  ,itemname BULK COLLECT
		INTO   vacode
			  ,vaname
		FROM   tcontracttypeitemname
		WHERE  branch = vbranch
		AND    contracttype = pctype;
		FOR i IN 1 .. vacode.count
		LOOP
			varet(vacode(i)) := vaname(i);
		END LOOP;
		t.leave(cmethod_name, 'vaRet.count=' || varet.count, 1);
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE changecreatedate
	(
		pcontractno          IN tcontract.no%TYPE
	   ,pcreatedate          IN tcontract.createdate%TYPE
	   ,pchangeacccreatedate IN BOOLEAN
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.ChangeCreateDate';
		vaccrow taccount%ROWTYPE;
	
		vaccountlist contract.typecontractitemlist;
	BEGIN
		IF pcreatedate IS NOT NULL
		THEN
			contract.setcreatedate(pcontractno, pcreatedate);
		
			IF pchangeacccreatedate
			THEN
				vaccountlist := contract.getaccountitemlist(pcontractno);
				FOR i IN 1 .. vaccountlist.count
				LOOP
					vaccrow.accountno := vaccountlist(i).accountno;
					IF setacccreatedate(vaccrow, pcreatedate, NULL, FALSE) != 0
					THEN
						error.raisewhenerr();
					END IF;
				
				END LOOP;
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecreatedate;

	PROCEDURE setacctype
	(
		paccountno      IN taccount.accountno%TYPE
	   ,pnewaccounttype IN NUMBER
	   ,paccounthandle  IN NUMBER := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.SetAccType';
		vhandle NUMBER;
	BEGIN
		IF paccounthandle IS NULL
		THEN
			vhandle := account.newobject(paccountno, 'W');
			IF vhandle = 0
			THEN
				error.raisewhenerr();
			END IF;
		ELSE
			vhandle := paccounthandle;
		END IF;
	
		account.setaccounttype(vhandle, pnewaccounttype);
		error.raisewhenerr();
	
		account.writeobject(vhandle);
		error.raisewhenerr();
	
		account.freeobject(vhandle);
	EXCEPTION
		WHEN OTHERS THEN
			IF vhandle IS NOT NULL
			THEN
				account.freeobject(vhandle);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END setacctype;

	FUNCTION getentcode
	(
		pentident    IN treferenceentry.ident%TYPE
	   ,pbasecode    IN CHAR
	   ,pname        IN VARCHAR2
	   ,pshortremark IN VARCHAR2 := NULL
	) RETURN treferenceentry.code%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetEntCode';
		vret NUMBER;
	BEGIN
		BEGIN
			readentcode(vret, pentident);
		EXCEPTION
			WHEN OTHERS THEN
			
				err.seterror(0, cmethod_name);
			
				vret := addentry2reference(pentident, pbasecode, pname, pshortremark);
		END;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION changecontractno(pcontractno IN tcontract.no%TYPE) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ChangeContractNo1f';
		cpref        CONSTANT VARCHAR(10) := '';
		vreturn        BOOLEAN := FALSE;
		vnewcontractno VARCHAR2(200);
		FUNCTION getnewcontractno(pcontractno IN tcontract.no%TYPE) RETURN VARCHAR2 IS
			cmethod_name CONSTANT VARCHAR2(65) := cpackage_name ||
												  '.ChangeContractNo1.GetNewContractNo';
			vret    VARCHAR2(200);
			vdialog NUMBER := 0;
		BEGIN
			vdialog := contract.getdialogcontractno(pcontractno);
			IF dialog.execdialog(vdialog) = dialog.cmok
			THEN
				vret := dialog.getchar(vdialog, 'ContractNo');
			END IF;
			dialog.destroy(vdialog);
			RETURN vret;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				IF vdialog != 0
				THEN
					dialog.destroy(vdialog);
				END IF;
				RAISE;
		END;
	BEGIN
		s.say(cpref || cmethod_name || ' start, OldContractNo=' || pcontractno, csay_level);
		vnewcontractno := getnewcontractno(pcontractno);
		s.say(cpref || cmethod_name || ' NewContractNo=' || vnewcontractno, csay_level);
		IF vnewcontractno IS NOT NULL
		THEN
			contract.changecontractno(pcontractno, vnewcontractno);
			vreturn := TRUE;
		END IF;
		s.say(cpref || cmethod_name || '(pContractNo ' || pcontractno || ', vNewContractNo ' ||
			  vnewcontractno || ') = ' || htools.bool2str(vreturn)
			 ,1);
		RETURN vreturn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecontractno;

	PROCEDURE changecontractno(pcontractno IN tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ChangeContractNo1p';
		cpref        CONSTANT VARCHAR(10) := '';
	BEGIN
		IF changecontractno(pcontractno)
		THEN
			NULL;
		END IF;
		s.say(cpref || ' Done ' || cmethod_name || '(pContractNo ' || pcontractno || ')', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecontractno;

	FUNCTION getparamsbycontracttype
	(
		pcontracttype IN tcontract.type%TYPE
	   ,paparams      typestrbystr
	) RETURN tcontract.rollbackdata%TYPE IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetParamsByContractType';
		vparams     tcontract.rollbackdata%TYPE := NULL;
		vschemaname tcontractschemas.name%TYPE;
		i           tcontract.rollbackdata%TYPE;
	BEGIN
		t.enter(cmethod_name);
		t.inpar(cmethod_name, 'pContractType:=' || pcontracttype);
		vschemaname := contracttype.getschemapackage(pcontracttype);
		t.note(cmethod_name, 'vSchemaName:=' || vschemaname);
		i := paparams.first;
		WHILE i IS NOT NULL
		LOOP
			t.note(cmethod_name, 'paParams(Key):=' || i);
			IF upper(i) = upper(vschemaname)
			THEN
				vparams := paparams(i);
				EXIT;
			END IF;
			i := paparams.next(i);
		END LOOP;
		t.note(cmethod_name, 'vParams:=' || vparams);
		t.leave(cmethod_name);
		RETURN vparams;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION parsedelimparamlinkcontract
	(
		pparam          VARCHAR2
	   ,pstartdelimiter VARCHAR2 := '['
	   ,penddelimiter   VARCHAR2 := ']'
	) RETURN typestrbystr IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.ParseDelimParamLinkContract';
		varet  typestrbystr;
		vs     tcontract.rollbackdata%TYPE;
		vkey   VARCHAR2(50);
		vvalue VARCHAR2(100);
		vpos   NUMBER;
	BEGIN
		t.enter(cmethod_name);
		t.inpar(cmethod_name
			   ,'pParam:=' || pparam || ' pStartDelimiter:=' || pstartdelimiter ||
				'; pEndDelimiter:=' || penddelimiter);
		vs   := pparam;
		vpos := instr(vs, pstartdelimiter);
		t.var('vPos', vpos);
		IF vpos > 0
		THEN
			t.note(cmethod_name, 'MAIN:=' || substr(vs, 1, vpos - 1));
			varet('MAIN') := substr(vs, 1, vpos - 1);
			vs := substr(vs, vpos);
			WHILE length(vs) > 0
			LOOP
				vpos := instr(vs, penddelimiter);
				vkey := upper(substr(vs, 2, vpos - 2));
				vs   := substr(vs, vpos + 1);
				vpos := instr(vs, pstartdelimiter);
				IF vpos > 0
				THEN
					vvalue := substr(vs, 1, vpos - 1);
					vs     := substr(vs, vpos);
				ELSE
					vvalue := vs;
					vs     := '';
				END IF;
				t.note(cmethod_name, vkey || ':=' || vvalue);
				varet(vkey) := vvalue;
			END LOOP;
		ELSE
			varet('MAIN') := pparam;
		END IF;
		t.leave(cmethod_name);
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION parsedelimparam
	(
		pparam VARCHAR2
	   ,pdelim VARCHAR2
	) RETURN tarrcharbychar IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.ParseDelimParam';
		vaparam uamp.tarrrecord;
		vname   VARCHAR2(100);
		varet   tarrcharbychar;
	BEGIN
		s.say(cmethod_name || ' pParam=' || pparam, 1);
		vaparam := uamp.parsestring(pparam, pdelim);
		FOR i IN 1 .. vaparam.count
		LOOP
			vname := upper(vaparam(i).name);
			s.say(cmethod_name || ' ' || vname || '=<' || vaparam(i).value || '>', 1);
			IF varet.exists(vname)
			THEN
				error.raiseerror('Duplicated parameter ' || vname || ' in string');
			END IF;
			varet(vname) := vaparam(i).value;
		END LOOP;
		s.say(cmethod_name || ' vaRet.count=' || varet.count, 1);
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION shiftparam(paparam contracttypeschema.typefschparamlist) RETURN tarrcharbychar IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.ShiftParam';
		vname VARCHAR2(100);
		varet tarrcharbychar;
	BEGIN
		s.say(cmethod_name || ' paParam.count=' || paparam.count, 1);
		FOR i IN 1 .. paparam.count
		LOOP
			vname := upper(paparam(i).id);
			s.say(cmethod_name || ' ' || vname || '=<' || paparam(i).stringvalue || '>', 1);
			IF varet.exists(vname)
			THEN
				error.raiseerror('Duplicated parameter ' || vname);
			END IF;
			varet(vname) := paparam(i).stringvalue;
		END LOOP;
		s.say(cmethod_name || 'vaRet.count=' || varet.count, 1);
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE addprolongation
	(
		pprolongationrow IN OUT tcontractprolongation%ROWTYPE
	   ,psaverollback    IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddProlongation[1]';
	BEGIN
		s.say(cmethod_name || ' starting', csay_level);
		IF pprolongationrow.contractno IS NULL
		THEN
			error.raiseerror('Contract No not defined');
		END IF;
		IF pprolongationrow.branch IS NULL
		THEN
			pprolongationrow.branch := seance.getbranch();
		END IF;
		IF pprolongationrow.clerkcode IS NULL
		THEN
			pprolongationrow.clerkcode := clerk.getcode();
		END IF;
	
		SELECT sq_cntprolongationid.nextval INTO pprolongationrow.idprol FROM dual;
	
		INSERT INTO tcontractprolongation VALUES pprolongationrow;
	
		IF psaverollback
		THEN
			contractrbstd.setprolongation(pprolongationrow.idprol);
		END IF;
		s.say(cmethod_name || ' finished, idProl=' || pprolongationrow.idprol, csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END addprolongation;

	FUNCTION addprolongation
	(
		pcontractno    IN tcontractprolongation.contractno%TYPE
	   ,pstartdate     IN tcontractprolongation.startdate%TYPE
	   ,penddate       IN tcontractprolongation.enddate%TYPE
	   ,pvalue         IN tcontractprolongation.value%TYPE
	   ,pcurrency      IN tcontractprolongation.currency%TYPE
	   ,pnewcontractno IN tcontractprolongation.newcontractno%TYPE := NULL
	   ,psaverollback  IN BOOLEAN := TRUE
	) RETURN tcontractprolongation.idprol%TYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddProlongation[2]';
		vprolongationrow tcontractprolongation%ROWTYPE;
	BEGIN
		s.say(cmethod_name || ' starting', csay_level);
		vprolongationrow.branch        := seance.getbranch();
		vprolongationrow.clerkcode     := clerk.getcode();
		vprolongationrow.contractno    := pcontractno;
		vprolongationrow.startdate     := pstartdate;
		vprolongationrow.enddate       := penddate;
		vprolongationrow.value         := pvalue;
		vprolongationrow.currency      := pcurrency;
		vprolongationrow.newcontractno := pnewcontractno;
		addprolongation(vprolongationrow, psaverollback);
		s.say(cmethod_name || ' finished, idProl=' || vprolongationrow.idprol, csay_level);
		RETURN vprolongationrow.idprol;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END addprolongation;

	PROCEDURE deleteprolongation(pidprol IN tcontractprolongation.idprol%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DeleteProlongation';
	BEGIN
		s.say(cmethod_name || ' starting, IdProl=' || pidprol, csay_level);
		IF pidprol IS NULL
		THEN
			error.raiseerror('Not defined prolongation number');
		END IF;
		DELETE FROM tcontractprolongation WHERE idprol = pidprol;
	
		s.say(cmethod_name || ' finished', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END deleteprolongation;

	FUNCTION getprolongation(pidprol IN tcontractprolongation.idprol%TYPE)
		RETURN tcontractprolongation%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetProlongation[1]';
		vret tcontractprolongation%ROWTYPE;
	BEGIN
		s.say(cmethod_name || ' starting pIdProl=' || pidprol, csay_level);
		IF pidprol IS NULL
		THEN
			error.raiseerror('Not defined prolongation number');
		END IF;
		SELECT * INTO vret FROM tcontractprolongation t WHERE t.idprol = pidprol;
		s.say(cmethod_name || ' finished', csay_level);
		RETURN vret;
	EXCEPTION
		WHEN no_data_found THEN
			RETURN vret;
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getprolongation
	(
		pcontractno       IN tcontractprolongation.contractno%TYPE
	   ,pprolongationtype IN PLS_INTEGER
	) RETURN tcontractprolongation%ROWTYPE IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetProlongation[2]';
		vret    tcontractprolongation%ROWTYPE;
		vbranch NUMBER := seance.getbranch();
	
		CURSOR curfirstprolongation(pcontractno IN tcontractprolongation.contractno%TYPE) IS
			SELECT *
			FROM   tcontractprolongation
			WHERE  branch = vbranch
			AND    contractno = pcontractno
			ORDER  BY startdate;
	
		CURSOR curlastprolongation(pcontractno IN tcontractprolongation.contractno%TYPE) IS
			SELECT *
			FROM   tcontractprolongation
			WHERE  branch = vbranch
			AND    contractno = pcontractno
			ORDER  BY startdate DESC;
	BEGIN
		s.say(cmethod_name || ' starting pContractNo=' || pcontractno || ', pProlongationType=' ||
			  pprolongationtype
			 ,csay_level);
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Contract No not defined');
		END IF;
		CASE pprolongationtype
			WHEN cfirstprolongation THEN
				FOR i IN curfirstprolongation(pcontractno)
				LOOP
					vret := i;
					EXIT;
				END LOOP;
			WHEN clastprolongation THEN
				FOR i IN curlastprolongation(pcontractno)
				LOOP
					vret := i;
					EXIT;
				END LOOP;
			ELSE
				error.raiseerror('Selection type from prolongation history not defined');
		END CASE;
		s.say(cmethod_name || ' finished', csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getprolongationcount(pcontractno IN tcontractprolongation.contractno%TYPE) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetProlongationCount';
		vcount  NUMBER := 0;
		vbranch NUMBER := seance.getbranch();
	BEGIN
		s.say(cmethod_name || ' starting pContractNo=' || pcontractno, csay_level);
		IF pcontractno IS NULL
		THEN
			error.raiseerror('Contract No not defined');
		END IF;
		SELECT COUNT(*)
		INTO   vcount
		FROM   tcontractprolongation
		WHERE  branch = vbranch
		AND    contractno = pcontractno;
		s.say(cmethod_name || ' finished, vCount=' || vcount, csay_level);
		RETURN vcount;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE addprolongation
	(
		pcontractno   tcontractprolongation.contractno%TYPE
	   ,pstartdate    tcontractprolongation.startdate%TYPE
	   ,penddate      tcontractprolongation.enddate%TYPE
	   ,pvalue        tcontractprolongation.value%TYPE
	   ,pcurrency     tcontractprolongation.currency%TYPE
	   ,paccountno    tcontractprolongation.newcontractno%TYPE
	   ,paparams      contractparams.typearrayparam2
	   ,psaverollback BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.AddProlongation[3]';
		vidprol tcontractprolongation.idprol%TYPE;
		vkey    VARCHAR2(40);
		vakey   types.arrstr40;
		vavalue types.arrstr1000;
		i       PLS_INTEGER := 0;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno);
		vidprol := addprolongation(pcontractno
								  ,pstartdate
								  ,penddate
								  ,pvalue
								  ,pcurrency
								  ,paccountno
								  ,psaverollback);
		t.var(' vIdProl=', vidprol);
	
		IF paparams.count > 0
		THEN
			vkey := paparams.first;
			WHILE vkey IS NOT NULL
			LOOP
				i := i + 1;
				vakey(i) := vkey;
				vavalue(i) := paparams(vkey);
				t.var(vakey(i) || ' = ' || vavalue(i) || '; ');
				vkey := paparams.next(vkey);
			END LOOP;
		
			FORALL i IN 1 .. vakey.count
			
				INSERT INTO tcontractprolongationparams
					(idprolparam
					,idprol
					,key
					,VALUE)
				VALUES
					(sq_cntprolongationparamid.nextval
					,vidprol
					,vakey(i)
					,vavalue(i));
		
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;
	FUNCTION getprolongationparams(pidprol tcontractprolongation.idprol%TYPE)
		RETURN contractparams.typearrayparam2 IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetProlongationParams';
		vakey   types.arrstr40;
		vavalue types.arrstr1000;
		varet   contractparams.typearrayparam2;
	BEGIN
		t.enter(cmethod_name, 'pIdProl=' || pidprol);
	
		SELECT key
			  ,VALUE BULK COLLECT
		INTO   vakey
			  ,vavalue
		FROM   tcontractprolongationparams
		WHERE  idprol = pidprol;
		FOR i IN 1 .. vakey.count
		LOOP
			varet(vakey(i)) := vavalue(i);
		END LOOP;
		t.leave(cmethod_name, 'vaRet.count=' || varet.count);
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;
	FUNCTION getprolongationlist(pcontractno tcontract.no%TYPE) RETURN tarrprolongation IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetProlongationList';
		vbranch NUMBER;
		i       PLS_INTEGER := 0;
		varet   tarrprolongation;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno);
		vbranch := seance.getbranch();
		FOR rec IN (SELECT idprol
						  ,contractno
						  ,startdate
						  ,enddate
						  ,VALUE
						  ,currency
						  ,clerkcode
						  ,newcontractno AS accountno
					FROM   tcontractprolongation
					WHERE  branch = vbranch
					AND    contractno = pcontractno
					ORDER  BY startdate)
		LOOP
			i := i + 1;
			varet(i).idprol := rec.idprol;
			varet(i).contractno := rec.contractno;
			varet(i).startdate := rec.startdate;
			varet(i).enddate := rec.enddate;
			varet(i).value := rec.value;
			varet(i).currency := rec.currency;
			varet(i).clerkcode := rec.clerkcode;
			varet(i).accountno := rec.accountno;
			varet(i).params := getprolongationparams(rec.idprol);
		END LOOP;
		t.leave(cmethod_name, 'vaRet.count=' || varet.count);
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;
	FUNCTION copyprol2rec(pprol tcontractprolongation%ROWTYPE) RETURN trecprolongation IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.CopyProl2Rec';
		vret trecprolongation;
	BEGIN
		vret.idprol     := pprol.idprol;
		vret.contractno := pprol.contractno;
		vret.startdate  := pprol.startdate;
		vret.enddate    := pprol.enddate;
		vret.value      := pprol.value;
		vret.currency   := pprol.currency;
		vret.clerkcode  := pprol.clerkcode;
		vret.accountno  := pprol.newcontractno;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;
	FUNCTION getrecprolongation(pidprol tcontractprolongation.idprol%TYPE) RETURN trecprolongation IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetRecProlongation[1]';
		vret trecprolongation;
	BEGIN
		t.enter(cmethod_name, 'pIdProl=' || pidprol);
		vret        := copyprol2rec(getprolongation(pidprol));
		vret.params := getprolongationparams(pidprol);
		t.leave(cmethod_name, 'vRet.ContractNo=' || vret.contractno);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;
	FUNCTION getrecprolongation
	(
		pcontractno       tcontract.no%TYPE
	   ,pprolongationtype PLS_INTEGER
	) RETURN trecprolongation IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetRecProlongation[2]';
		vprol tcontractprolongation%ROWTYPE;
		vret  trecprolongation;
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ' pProlongationType=' || pprolongationtype);
	
		vprol := getprolongation(pcontractno, pprolongationtype);
		IF vprol.contractno IS NULL
		THEN
			error.raiseerror('Records on prolongation of contract <' || pcontractno ||
							 '> not found');
		END IF;
		vret := copyprol2rec(vprol);
		IF vprol.idprol IS NOT NULL
		THEN
			vret.params := getprolongationparams(vprol.idprol);
		END IF;
	
		t.leave(cmethod_name, 'vRet.ContractNo=' || vret.contractno);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getobjecttype(pobjectname VARCHAR2) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetObjectType';
	BEGIN
		RETURN saobjecttype(pobjectname);
	EXCEPTION
		WHEN no_data_found THEN
			saobjecttype(pobjectname) := object.gettype(pobjectname);
			RETURN saobjecttype(pobjectname);
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE dolog
	(
		pobjectname VARCHAR2
	   ,pobjectid   VARCHAR2
	   ,plogaction  NUMBER
	   ,plogmsg     VARCHAR2
	   ,palogparam  tblchar100 := NULL
	   ,paoldvalue  tblchar100 := NULL
	   ,panewvalue  tblchar100 := NULL
	   ,powner      a4mlog.typeclientid := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.DoLog';
		vaparam a4mlog.typelogparamrecord;
		vowner  a4mlog.typeclientid := powner;
	BEGIN
		t.enter(cmethod_name
			   ,'pObjectName=' || pobjectname || ',pObjectId=' || pobjectid || ', pOwner=' ||
				powner
			   ,1);
		IF palogparam IS NOT NULL
		THEN
			FOR i IN 1 .. palogparam.count
			LOOP
				vaparam.value(palogparam(i)) := paoldvalue(i);
				vaparam.valuetwo(palogparam(i)) := panewvalue(i);
			END LOOP;
		END IF;
	
		IF vowner IS NULL
		   AND pobjectname = contract.object_name
		THEN
			vowner := contract.getclientid(pobjectid);
			t.var('vOwner', vowner);
		END IF;
	
		IF a4mlog.logobject(getobjecttype(pobjectname)
						   ,pobjectid
						   ,plogmsg
						   ,plogaction
						   ,vaparam
						   ,powner => vowner) <> 0
		THEN
			error.raisewhenerr();
		END IF;
		t.leave(cmethod_name, plevel => 1);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => 1);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getleastorgreatest
	(
		pfromvalue  IN NUMBER
	   ,pfromcurr   IN treferencecurrency.currency%TYPE
	   ,ptovalue    IN NUMBER
	   ,ptocurr     IN treferencecurrency.currency%TYPE
	   ,presulttype IN PLS_INTEGER
	   ,pexchrate   IN NUMBER := NULL
	   ,poperdate   IN DATE := NULL
	) RETURN tamount IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetLeastOrGreatest';
		vres      tamount;
		vexchrate NUMBER;
		voperdate DATE;
		verr      NUMBER;
	BEGIN
		s.say(cmethod_name || '(pFromValue=' || pfromvalue || ', pFromCurr=' || pfromcurr ||
			  ', pToValue=' || ptovalue || ', pToCurr=' || ptocurr || ', pExchRate=' || pexchrate ||
			  ', pOperDate=' || poperdate
			 ,csay_level);
		IF pfromvalue IS NULL
		THEN
			error.raiseerror('Not defined amount 1');
		END IF;
		IF pfromcurr IS NULL
		THEN
			error.raiseerror('Not defined currency for amount 1');
		ELSE
			IF referencecurrency.getname(pfromcurr) IS NULL
			THEN
				error.raiseerror('Not found currency {' || pfromcurr ||
								 '] in Dictionary of currencies');
			END IF;
		END IF;
	
		IF ptovalue IS NULL
		THEN
			error.raiseerror('Not defined amount 2');
		END IF;
		IF ptocurr IS NULL
		THEN
			error.raiseerror('Not defined currency for amount 2');
		ELSE
			IF referencecurrency.getname(ptocurr) IS NULL
			THEN
				error.raiseerror('Not found currency {' || ptocurr ||
								 '] in Dictionary of currencies');
			END IF;
		END IF;
	
		vexchrate := pexchrate;
		IF vexchrate IS NULL
		THEN
			vexchrate := exchangerate.getdefaultexchange();
		END IF;
	
		voperdate := poperdate;
		IF voperdate IS NULL
		THEN
			voperdate := seance.getoperdate();
		END IF;
	
		IF pfromcurr != ptocurr
		THEN
			verr := exchangerate.preparesumma(pfromcurr
											 ,ptocurr
											 ,pfromcurr
											 ,pfromvalue
											 ,vexchrate
											 ,voperdate);
			error.raisewhenerr();
			vres.value        := exchangerate.ssummato;
			vres.currencycode := ptocurr;
		ELSE
			vres.value        := pfromvalue;
			vres.currencycode := pfromcurr;
		END IF;
	
		CASE presulttype
			WHEN cleastequal THEN
				IF vres.value <= ptovalue
				THEN
					vres.value        := pfromvalue;
					vres.currencycode := pfromcurr;
				ELSE
					vres.value        := ptovalue;
					vres.currencycode := ptocurr;
				END IF;
			WHEN cgreatestequal THEN
				IF vres.value >= ptovalue
				THEN
					vres.value        := pfromvalue;
					vres.currencycode := pfromcurr;
				ELSE
					vres.value        := ptovalue;
					vres.currencycode := ptocurr;
				END IF;
			ELSE
				error.raiseerror('Undefined result');
		END CASE;
	
		s.say(cmethod_name || ' finished vRes.Value=' || vres.value || ', vRes.CurrCode=' ||
			  vres.currencycode
			 ,csay_level);
		RETURN vres;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getleast
	(
		pfromvalue IN NUMBER
	   ,pfromcurr  IN treferencecurrency.currency%TYPE
	   ,ptovalue   IN NUMBER
	   ,ptocurr    IN treferencecurrency.currency%TYPE
	   ,pexchrate  IN NUMBER := NULL
	   ,poperdate  IN DATE := NULL
	) RETURN tamount IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetLeast[1]';
		vres tamount;
	BEGIN
		s.say(cmethod_name || ' start', csay_level);
		vres := getleastorgreatest(pfromvalue
								  ,pfromcurr
								  ,ptovalue
								  ,ptocurr
								  ,cleastequal
								  ,pexchrate
								  ,poperdate);
		s.say(cmethod_name || ' finished', csay_level);
		RETURN vres;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE getleast
	(
		ovalue     OUT NUMBER
	   ,ocurr      OUT NUMBER
	   ,pfromvalue IN NUMBER
	   ,pfromcurr  IN treferencecurrency.currency%TYPE
	   ,ptovalue   IN NUMBER
	   ,ptocurr    IN treferencecurrency.currency%TYPE
	   ,pexchrate  IN NUMBER := NULL
	   ,poperdate  IN DATE := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetLeast[2]';
		vres tamount;
	BEGIN
		s.say(cmethod_name || ' start', csay_level);
		vres   := getleastorgreatest(pfromvalue
									,pfromcurr
									,ptovalue
									,ptocurr
									,cleastequal
									,pexchrate
									,poperdate);
		ovalue := vres.value;
		ocurr  := vres.currencycode;
		s.say(cmethod_name || ' finished', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION getgreatest
	(
		pfromvalue IN NUMBER
	   ,pfromcurr  IN treferencecurrency.currency%TYPE
	   ,ptovalue   IN NUMBER
	   ,ptocurr    IN treferencecurrency.currency%TYPE
	   ,pexchrate  IN NUMBER := NULL
	   ,poperdate  IN DATE := NULL
	) RETURN tamount IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.GetGreatest';
		vres tamount;
	BEGIN
		s.say(cmethod_name || ' start', csay_level);
		vres := getleastorgreatest(pfromvalue
								  ,pfromcurr
								  ,ptovalue
								  ,ptocurr
								  ,cgreatestequal
								  ,pexchrate
								  ,poperdate);
		s.say(cmethod_name || ' finished', csay_level);
		RETURN vres;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE getgreatest
	(
		ovalue     OUT NUMBER
	   ,ocurr      OUT NUMBER
	   ,pfromvalue IN NUMBER
	   ,pfromcurr  IN treferencecurrency.currency%TYPE
	   ,ptovalue   IN NUMBER
	   ,ptocurr    IN treferencecurrency.currency%TYPE
	   ,pexchrate  IN NUMBER := NULL
	   ,poperdate  IN DATE := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || 'GetGreatest.[2]';
		vres tamount;
	BEGIN
		s.say(cmethod_name || ' start', csay_level);
		vres   := getleastorgreatest(pfromvalue
									,pfromcurr
									,ptovalue
									,ptocurr
									,cgreatestequal
									,pexchrate
									,poperdate);
		ovalue := vres.value;
		ocurr  := vres.currencycode;
		s.say(cmethod_name || ' finished', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION dialogmessage
	(
		pcaption     IN VARCHAR2
	   ,pmessage     IN VARCHAR2
	   ,pflagcaption IN VARCHAR2
	   ,pnoshowagain IN BOOLEAN
	   ,pbutton      IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DialogMessage';
		vdialog NUMBER;
	
		VARRAY    types.arrtext;
		vmessage  VARCHAR(1500);
		vmessage2 VARCHAR(1500);
		vpos      NUMBER;
		vpos2     NUMBER;
		cbw CONSTANT NUMBER := 10;
		cdw NUMBER := 50;
		cmaxlen CONSTANT NUMBER := 80;
		varraysize NUMBER;
	BEGIN
		vmessage   := REPLACE(substr(pmessage, 1, 1500), chr(10), '~');
		varraysize := 0;
		cdw        := greatest(length(pcaption), cdw);
		LOOP
			vpos := instr(vmessage, '~');
			IF vpos = 0
			THEN
				vpos := length(vmessage) + 1;
			END IF;
			vmessage2 := nvl(substr(vmessage, 1, vpos - 1), ' ');
			WHILE length(vmessage2) > cmaxlen
			LOOP
				varraysize := varraysize + 1;
				vpos2      := instr(substr(vmessage2, 1, cmaxlen), ' ', -1);
				IF vpos2 = 0
				THEN
					vpos2 := cmaxlen + 1;
				END IF;
				VARRAY(varraysize) := substr(vmessage2, 1, vpos2 - 1);
				vmessage2 := substr(vmessage2, vpos2 + 1);
				vmessage := substr(vmessage, vpos2 + 1);
				cdw := greatest(cdw, length(VARRAY(varraysize)));
				vpos := vpos - vpos2;
			END LOOP;
			varraysize := varraysize + 1;
			VARRAY(varraysize) := nvl(substr(vmessage, 1, vpos - 1), ' ');
			vmessage := substr(vmessage, vpos + 1);
			cdw := greatest(cdw, length(VARRAY(varraysize)));
			EXIT WHEN vmessage IS NULL;
		END LOOP;
		cdw := cdw + 2;
	
		vdialog := dialog.new(nvl(pcaption, 'Warning!'), 0, 0, cdw, 8, pextid => cmethod_name);
		dialog.setmeasure(vdialog, 'H');
	
		FOR i IN 1 .. varraysize
		LOOP
			dialog.textlabel(vdialog, 'T' || to_char(i), 1, i + 1, cdw - 1, VARRAY(i));
			dialog.settextanchor(vdialog, 'T' || to_char(i), 0);
		END LOOP;
		dialog.setdialogresizeable(vdialog, FALSE);
		dialog.setdialoghasstatusbar(vdialog, FALSE);
		dialog.inputcheck(vdialog, 'NoShowAgain', 3, varraysize + 3, 37, pcaption => pflagcaption);
		dialog.putbool(vdialog, 'NoShowAgain', nvl(pnoshowagain, FALSE));
		IF pbutton = ktools.mb_yesno
		THEN
			dialog.button(vdialog
						 ,'btnOk'
						 ,round(cdw / 2 - cbw - 1)
						 ,varraysize + 5
						 ,cbw
						 ,'Yes'
						 ,pcmd => dialog.cmok);
			dialog.button(vdialog
						 ,'btnCancel'
						 ,round(cdw / 2 + 1)
						 ,varraysize + 5
						 ,cbw
						 ,'No'
						 ,pcmd => dialog.cmcancel);
		ELSE
			dialog.button(vdialog
						 ,'btnOk'
						 ,round(cdw / 2 - cbw / 2)
						 ,varraysize + 5
						 ,cbw
						 ,'OK'
						 ,pcmd => dialog.cmok);
		END IF;
		dialog.setdefault(vdialog, 'btnOk', TRUE);
		dialog.goitem(vdialog, 'btnOk');
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION showmessage
	(
		pcaption     IN VARCHAR2
	   ,pmessage     IN VARCHAR2
	   ,pflagcaption IN VARCHAR2
	   ,pnoshowagain IN OUT BOOLEAN
	   ,pbutton      IN NUMBER
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.ShowMessage';
		vdialog      NUMBER;
		vcmd         NUMBER;
		vnoshowagain BOOLEAN;
	BEGIN
		vnoshowagain := pnoshowagain;
		vdialog      := dialogmessage(pcaption, pmessage, pflagcaption, vnoshowagain, pbutton);
		vcmd         := dialog.execdialog(vdialog);
		pnoshowagain := dialog.getbool(vdialog, 'NoShowAgain');
		dialog.destroy(vdialog);
		RETURN vcmd;
	EXCEPTION
		WHEN OTHERS THEN
			IF vdialog != 0
			THEN
				dialog.destroy(vdialog);
			END IF;
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE dialogmessageproc
	(
		pwhat   IN CHAR
	   ,pdialog IN NUMBER
	   ,pitem   IN VARCHAR2
	   ,pcmd    IN NUMBER
	) IS
	BEGIN
		NULL;
	END;

	FUNCTION xirr
	(
		padate     types.arrdate
	   ,paamount   types.arrnum
	   ,pguess     NUMBER := NULL
	   ,pprecision NUMBER := 0.00001
	) RETURN NUMBER IS
		cmethod_name  CONSTANT VARCHAR2(80) := cpackage_name || '.xirr';
		cmaxiteration CONSTANT NUMBER := 50;
		vaperiodkoef types.arrnum;
		vret         NUMBER := NULL;
	
		FUNCTION f(x NUMBER) RETURN NUMBER IS
			r NUMBER;
		BEGIN
			r := paamount(1);
			FOR i IN 2 .. paamount.count
			LOOP
				r := r + paamount(i) / power((1 + x), vaperiodkoef(i));
			END LOOP;
			RETURN r;
		END;
		FUNCTION r
		(
			plo        NUMBER
		   ,pflo       NUMBER
		   ,phi        NUMBER
		   ,pfhi       NUMBER
		   ,piteration NUMBER := 0
		) RETURN NUMBER IS
			vmd  NUMBER;
			vfmd NUMBER;
		BEGIN
			IF piteration > cmaxiteration
			THEN
				t.note('error: iterations exceeded max; return null');
				RETURN NULL;
			END IF;
			IF sign(pflo) = sign(pfhi)
			THEN
				t.note('error: sign is iqual; return null');
				RETURN NULL;
			END IF;
			vmd := (plo + phi) / 2;
			IF abs(vmd - plo) < pprecision
			THEN
				t.var('root founded, iteration ', piteration);
				RETURN vmd;
			END IF;
			vfmd := f(vmd);
			IF sign(vfmd) = sign(pflo)
			THEN
				RETURN r(vmd, vfmd, phi, pfhi, piteration + 1);
			ELSE
				RETURN r(plo, pflo, vmd, vfmd, piteration + 1);
			END IF;
		END;
	BEGIN
		t.enter(cmethod_name, 'paDate.count=' || padate.count || ' pGuess=' || pguess);
		IF padate.count <> paamount.count
		THEN
			t.note('error: count of date dont equal count of amount; return null');
			RETURN NULL;
		END IF;
		IF pguess <= -1
		THEN
			t.note('error: wrong guess, less or equal then -1; return null');
			RETURN NULL;
		END IF;
		FOR i IN 2 .. padate.count
		LOOP
			vaperiodkoef(i) := (padate(i) - padate(1)) / 365;
		END LOOP;
		IF pguess IS NOT NULL
		THEN
			vret := r(pguess - 0.1, f(pguess - 0.1), pguess + 0.1, f(pguess + 0.1));
		END IF;
		IF vret IS NULL
		THEN
			vret := r(0, f(0), 1, f(1));
		END IF;
		IF vret IS NULL
		THEN
			vret := r(-1 + pprecision, f(-1 + pprecision), 10, f(10));
		END IF;
		t.leave(cmethod_name, 'vRet=' || vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION isitemnameexistsintype
	(
		pcontracttype IN tcontract.type%TYPE
	   ,pitemname     IN tcontracttypeitemname.itemname%TYPE
	) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.IsItemNameExistsInType';
		cbranch      CONSTANT NUMBER := seance.getbranch;
		vresult BOOLEAN;
		vflag   NUMBER;
	BEGIN
		t.enter(cmethod_name, pitemname);
	
		SELECT COUNT(*)
		INTO   vflag
		FROM   tcontracttypeitemname
		WHERE  branch = cbranch
		AND    contracttype = pcontracttype
		AND    itemname = pitemname
		AND    rownum = 1;
	
		vresult := vflag = 1;
	
		t.leave(cmethod_name, htools.b2s(vresult));
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END isitemnameexistsintype;

	PROCEDURE fixarrestedremain(paccount IN OUT NOCOPY taccountrecord) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name ||
											 '.FixArrestedRemain [by TAccountRecord]';
		vaarrests arrest.typearrestinfoarray;
	BEGIN
		t.enter(cmethod_name, paccount.remain);
	
		IF paccount.remain > 0
		THEN
		
			vaarrests := arrest.getaccountarrests(paccount.accountno);
		
			FOR i IN 1 .. vaarrests.count
			LOOP
			
				paccount.remain := greatest(paccount.remain - vaarrests(i).arrestamount + vaarrests(i)
											.releasedamount
										   ,0);
			
				EXIT WHEN paccount.remain = 0;
			END LOOP;
		END IF;
	
		t.leave(cmethod_name, paccount.remain);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END fixarrestedremain;

	PROCEDURE fixarrestedremain(paccount IN OUT NOCOPY taccount%ROWTYPE) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.FixArrestedRemain [by ROWTYPE]';
		vaccount taccountrecord;
	BEGIN
		t.enter(cmethod_name);
	
		copystruct(paccount, vaccount);
		fixarrestedremain(vaccount);
		copystruct(vaccount, paccount);
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END fixarrestedremain;

	PROCEDURE checkdelimiter(pdelimiter IN VARCHAR2) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.CheckDelimiter';
	BEGIN
		t.enter(cmethod_name, pdelimiter);
	
		IF pdelimiter IS NULL
		THEN
			error.raiseerror('Separator not specified!');
		END IF;
	
		IF length(pdelimiter) > 1
		THEN
			error.raiseerror('Length of separator exceeded!');
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END checkdelimiter;

	FUNCTION parsestring
	(
		pstring     IN VARCHAR2
	   ,pdelimiter  IN VARCHAR2
	   ,pmincount   IN NUMBER := NULL
	   ,pmaxcount   IN NUMBER := NULL
	   ,pparamcount IN NUMBER := NULL
	) RETURN types.arrstr4000 IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ParseString';
		vpattern VARCHAR2(50) := '.*?\' || pdelimiter;
		vstring  tcontract.rollbackdata%TYPE;
		varesult types.arrstr4000;
	BEGIN
		t.enter(cmethod_name
			   ,'pString = ' || pstring || ', pMinCount = ' || pmincount || ', pMaxCount = ' ||
				pmaxcount || ', pCountToReturn = ' || pparamcount);
	
		checkdelimiter(pdelimiter);
	
		IF length(pstring) > 4000
		THEN
			error.raiseerror('Error: string of parameters <' || pstring ||
							 '> exceeds maximum length of 4000 characters!');
		END IF;
	
		vstring := regexp_replace(TRIM(pstring), pdelimiter || '$', '');
	
		IF vstring IS NOT NULL
		THEN
			SELECT REPLACE(regexp_substr(vstring || pdelimiter, vpattern, 1, LEVEL), pdelimiter, '') BULK COLLECT
			INTO   varesult
			FROM   dual
			CONNECT BY regexp_substr(vstring || pdelimiter, vpattern, 1, LEVEL) IS NOT NULL;
		END IF;
	
		IF (pmincount IS NOT NULL)
		   AND (varesult.count < pmincount)
		THEN
			error.raiseerror('Error: string <' || pstring || '> requires no less than ' ||
							 pmincount || ' values (found ' || varesult.count || ')!');
		END IF;
	
		IF (pmaxcount IS NOT NULL)
		   AND (varesult.count > pmaxcount)
		THEN
			error.raiseerror('Error: string <' || pstring || '> supports not more than ' ||
							 pmaxcount || ' values (found ' || varesult.count || ')!');
		END IF;
	
		IF pparamcount IS NOT NULL
		THEN
			FOR i IN varesult.count + 1 .. pparamcount
			LOOP
				varesult(i) := NULL;
			END LOOP;
		END IF;
	
		t.leave(cmethod_name, varesult.count);
		RETURN varesult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END parsestring;

	FUNCTION paramstringtolist
	(
		pparamsstring  IN VARCHAR2
	   ,ppairdelimiter IN VARCHAR2 := ';'
	   ,pkeydelimiter  IN VARCHAR2 := '='
	   ,pprohibitdups  IN BOOLEAN := FALSE
	) RETURN contracttypeschema.typefschparamlist IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ParamStringToList';
		varesult     contracttypeschema.typefschparamlist;
		vadupssearch tarrcharbychar;
		vapairs      types.arrstr4000;
		vdelpos      NUMBER;
	BEGIN
		t.enter(cmethod_name, pparamsstring);
	
		checkdelimiter(pkeydelimiter);
	
		vapairs := parsestring(pparamsstring, ppairdelimiter);
	
		FOR i IN 1 .. vapairs.count
		LOOP
		
			IF vapairs(i) IS NULL
			THEN
				error.raiseerror('There is empty pair <parameter/value>!');
			END IF;
		
			vdelpos := instr(vapairs(i), pkeydelimiter);
		
			IF vdelpos = 0
			THEN
				error.raiseerror('Delimiter ''' || pkeydelimiter || ''' not found in pair <' ||
								 vapairs(i) || '>!');
			END IF;
		
			varesult(varesult.count + 1).id := upper(TRIM(substr(vapairs(i), 1, vdelpos - 1)));
		
			IF varesult(varesult.count).id IS NULL
			THEN
				error.raiseerror('Parameter name not defined in pair <' || vapairs(i) || '>!');
			END IF;
		
			IF pprohibitdups
			THEN
			
				IF vadupssearch.exists(varesult(varesult.count).id)
				THEN
					error.raiseerror('Parameter <' || varesult(varesult.count).id ||
									 '> used repeatedly!');
				END IF;
			
				vadupssearch(varesult(varesult.count).id) := 1;
			
			END IF;
		
			varesult(varesult.count).stringvalue := substr(vapairs(i), vdelpos + 1);
		
		END LOOP;
	
		t.leave(cmethod_name, varesult.count);
		RETURN varesult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END paramstringtolist;

	FUNCTION paramstringtoarray
	(
		pparamsstring  IN VARCHAR2
	   ,ppairdelimiter IN VARCHAR2 := ';'
	   ,pkeydelimiter  IN VARCHAR2 := '='
	) RETURN tarrcharbychar IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ParamStringToArray';
		varesult tarrcharbychar;
		vapairs  types.arrstr4000;
		vkey     VARCHAR2(100);
		vdelpos  NUMBER;
	BEGIN
		t.enter(cmethod_name, pparamsstring);
	
		checkdelimiter(pkeydelimiter);
	
		vapairs := parsestring(pparamsstring, ppairdelimiter);
	
		FOR i IN 1 .. vapairs.count
		LOOP
		
			IF vapairs(i) IS NULL
			THEN
				error.raiseerror('There is empty pair <parameter/value>!');
			END IF;
		
			vdelpos := instr(vapairs(i), pkeydelimiter);
		
			IF vdelpos = 0
			THEN
				error.raiseerror('Delimiter ''' || pkeydelimiter || ''' not found in pair <' ||
								 vapairs(i) || '>!');
			END IF;
		
			vkey := upper(TRIM(substr(vapairs(i), 1, vdelpos - 1)));
		
			IF vkey IS NULL
			THEN
				error.raiseerror('Parameter name not defined in pair <' || vapairs(i) || '>!');
			END IF;
		
			IF varesult.exists(vkey)
			THEN
				error.raiseerror('Parameter <' || vkey || '> used repeatedly!');
			END IF;
		
			varesult(vkey) := substr(vapairs(i), vdelpos + 1);
		
		END LOOP;
	
		t.leave(cmethod_name, varesult.count);
		RETURN varesult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END paramstringtoarray;

	FUNCTION getparamfromstring
	(
		pparamstring   IN VARCHAR2
	   ,pparam         IN VARCHAR2
	   ,pmandatory     IN BOOLEAN := TRUE
	   ,pprohibitnull  IN BOOLEAN := TRUE
	   ,ppairdelimiter VARCHAR2 := ';'
	   ,pkeydelimiter  VARCHAR2 := '='
	) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.GetParamFromString';
		vaparams contracttools.tarrcharbychar;
		vresult  VARCHAR2(4000);
	BEGIN
		t.enter(cmethod_name, pparamstring);
	
		vaparams := contracttools.paramstringtoarray(pparamstring, ppairdelimiter, pkeydelimiter);
	
		IF vaparams.exists(pparam)
		THEN
		
			IF vaparams(pparam) IS NOT NULL
			THEN
				vresult := vaparams(pparam);
			
			ELSIF pprohibitnull
			THEN
				error.raiseerror('Value of parameter <' || pparam || '> not defined!');
			END IF;
		
		ELSIF pmandatory
		THEN
			error.raiseerror('String of parameters <' || pparamstring ||
							 '> does not contain parameter <' || pparam || '>!');
		END IF;
	
		t.leave(cmethod_name, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END getparamfromstring;

	PROCEDURE legacyparsekey2pan
	(
		pkey IN VARCHAR2
	   ,opan OUT VARCHAR2
	   ,ombr OUT NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.LegacyParseKey2PAN';
	BEGIN
		opan := substr(pkey, 1, length(pkey) - 1);
		ombr := to_number(substr(pkey, -1));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END legacyparsekey2pan;

	FUNCTION ensurepan(ppan IN VARCHAR2) RETURN tcard.pan%TYPE IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.EnsurePAN';
		vresult tcard.pan%TYPE;
	BEGIN
	
		IF ppan IS NULL
		THEN
			error.raiseerror('Card PAN not specified!');
		END IF;
	
		vresult := ppan;
		RETURN vresult;
	
	EXCEPTION
		WHEN value_error THEN
			error.raiseerror('Length of card PAN exceeded!');
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END ensurepan;

	FUNCTION ensurembr(pmbr IN VARCHAR2) RETURN tcard.mbr%TYPE IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.EnsureMBR';
		vresult tcard.mbr%TYPE;
	BEGIN
	
		IF pmbr IS NULL
		THEN
			error.raiseerror('Card MBR not specified!');
		END IF;
	
		vresult := pmbr;
		RETURN vresult;
	
	EXCEPTION
		WHEN value_error THEN
			error.raiseerror('Invalid card MBR specified!');
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END ensurembr;

	PROCEDURE parsecardstring
	(
		pstring    VARCHAR2
	   ,opan       OUT tcard.pan%TYPE
	   ,ombr       OUT tcard.mbr%TYPE
	   ,pdelimiter VARCHAR2 := cdefaultcarddelim
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ParseCardString';
		vaparts types.arrstr4000;
	BEGIN
		t.enter(cmethod_name, pstring);
	
		vaparts := parsestring(pstring, pdelimiter);
	
		IF vaparts.exists(1)
		THEN
			opan := ensurepan(vaparts(1));
		ELSE
			error.raiseerror('PAN not defined!');
		END IF;
	
		IF vaparts.exists(2)
		THEN
			ombr := ensurembr(vaparts(2));
		ELSE
			error.raiseerror('Card MBR not specified (for ' || card.getmaskedpan(opan) || ')!');
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END parsecardstring;

	FUNCTION parsecardstring
	(
		pstring    VARCHAR2
	   ,pdelimiter VARCHAR2 := cdefaultcarddelim
	) RETURN apitypes.typeaccount2cardrecord IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ParseCardString';
		vresult apitypes.typeaccount2cardrecord;
		vaparts types.arrstr4000;
	BEGIN
		t.enter(cmethod_name, pstring);
	
		vaparts := parsestring(pstring, pdelimiter);
	
		IF vaparts.exists(1)
		THEN
			vresult.pan := ensurepan(vaparts(1));
		ELSE
			error.raiseerror('PAN not defined!');
		END IF;
	
		IF vaparts.exists(2)
		THEN
			vresult.mbr := ensurembr(vaparts(2));
		ELSE
			error.raiseerror('Card MBR not defined (for ' || card.getmaskedpan(vresult.pan) || ')!');
		END IF;
	
		IF vaparts.exists(3)
		   AND (vaparts(3) IS NOT NULL)
		THEN
		
			BEGIN
				vresult.acct_stat := vaparts(3);
			EXCEPTION
				WHEN value_error THEN
					error.raiseerror('Invalid card status specified!');
			END;
		
			IF NOT vresult.acct_stat IN (referenceacct_stat.stat_open
										,referenceacct_stat.stat_deposit
										,referenceacct_stat.stat_primary
										,referenceacct_stat.stat_view
										,referenceacct_stat.stat_close)
			THEN
				error.raiseerror('Unknown card status <' || vresult.acct_stat || '> (for ' ||
								 contract.getcardno(vresult.pan, vresult.mbr) || ')!');
			END IF;
		
		ELSE
			error.raiseerror('Card status not defined (for ' ||
							 contract.getcardno(vresult.pan, vresult.mbr) || ')!');
		END IF;
	
		t.leave(cmethod_name);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END parsecardstring;

	FUNCTION makecardstring
	(
		ppan       IN VARCHAR2
	   ,pmbr       IN VARCHAR2
	   ,pdelimiter VARCHAR2 := cdefaultcarddelim
	) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.MakeCardString';
	BEGIN
		checkdelimiter(pdelimiter);
		RETURN ensurepan(ppan) || pdelimiter || ensurembr(pmbr);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END makecardstring;

	FUNCTION isnumber
	(
		pvalue      IN VARCHAR2
	   ,pwhatisnull IN BOOLEAN := FALSE
	) RETURN BOOLEAN IS
		vdummy NUMBER;
	BEGIN
		IF pvalue IS NULL
		THEN
			RETURN pwhatisnull;
		END IF;
		vdummy := pvalue;
		RETURN TRUE;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN FALSE;
	END isnumber;

	FUNCTION isdate
	(
		pvalue      IN VARCHAR2
	   ,pformat     IN VARCHAR2 := contractparams.cparam_date_format
	   ,pwhatisnull IN BOOLEAN := FALSE
	) RETURN BOOLEAN IS
		vdummy DATE;
	BEGIN
		IF pvalue IS NULL
		THEN
			RETURN pwhatisnull;
		END IF;
		vdummy := to_date(pvalue, pformat);
		RETURN TRUE;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN FALSE;
	END isdate;

	PROCEDURE checkvalue_exists
	(
		pvalue     IN NUMBER
	   ,pvaluename IN VARCHAR2
	) IS
		cmethodname CONSTANT VARCHAR(60) := cpackage_name || '.CheckValue_Exists';
	BEGIN
		IF pvalue IS NULL
		THEN
			error.raiseerror('Empty value defined for parameter <' || pvaluename || '>!');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END checkvalue_exists;

	PROCEDURE checkvalue_exists
	(
		pvalue     IN DATE
	   ,pvaluename IN VARCHAR2
	) IS
		cmethodname CONSTANT VARCHAR(60) := cpackage_name || '.CheckValue_Exists';
	BEGIN
		IF pvalue IS NULL
		THEN
			error.raiseerror('Empty value defined for parameter <' || pvaluename || '>!');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END checkvalue_exists;

	PROCEDURE checkvalue_exists
	(
		pvalue     IN VARCHAR2
	   ,pvaluename IN VARCHAR2
	) IS
		cmethodname CONSTANT VARCHAR(60) := cpackage_name || '.CheckValue_Exists';
	BEGIN
		IF pvalue IS NULL
		THEN
			error.raiseerror('Empty value defined for parameter <' || pvaluename || '>!');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END checkvalue_exists;

	FUNCTION int_validatechar
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER
	   ,pprohibitnull    IN BOOLEAN
	   ,pwhatisnull      IN NUMBER
	   ,pallowedvalues   IN tblchar1000
	   ,pforbiddenvalues IN tblchar1000
	   ,oerrmsg          OUT VARCHAR2
	) RETURN VARCHAR2 IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.Int_ValidateChar';
		vparamdescr VARCHAR2(200) := CASE
										 WHEN pvaluename IS NOT NULL THEN
										  '"' || pvaluename || '" '
									 END;
		vrawvalue   VARCHAR2(1000);
		vresult     VARCHAR2(1000);
	BEGIN
		t.enter(cmethodname, pvalue);
	
		vrawvalue := nvl(pvalue, pwhatisnull);
	
		IF vrawvalue IS NULL
		THEN
		
			IF pprohibitnull
			THEN
				oerrmsg := 'Value of parameter ' || vparamdescr || ' not defined!';
			END IF;
		
		ELSE
		
			vresult := vrawvalue;
		
			IF (pallowedvalues.count > 0)
			   AND (vresult NOT MEMBER OF pallowedvalues)
			THEN
				oerrmsg := 'Value <' || vresult || '> of parameter ' || vparamdescr ||
						   ' does not match admissible values!';
			END IF;
		
			IF oerrmsg IS NULL
			THEN
			
				IF (pforbiddenvalues.count > 0)
				   AND (vresult MEMBER OF pforbiddenvalues)
				THEN
					oerrmsg := 'Prohibited to set value <' || vresult || '> for parameter ' ||
							   vparamdescr || '!';
				END IF;
			
				IF oerrmsg IS NULL
				THEN
				
					CASE pcheckmode
					
						WHEN cchar_donotcheck THEN
							NULL;
						
						ELSE
							error.raiseerror('Internal error: unknown string value check mode <' ||
											 pcheckmode || '>!');
						
					END CASE;
				
				END IF;
			
			END IF;
		
		END IF;
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END int_validatechar;

	PROCEDURE validatechar
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cchar_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN NUMBER := NULL
	   ,pallowedvalues   IN tblchar1000 := tblchar1000()
	   ,pforbiddenvalues IN tblchar1000 := tblchar1000()
	   ,perrmsg          IN VARCHAR2 := NULL
	) IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.ValidateChar';
		vdummy  VARCHAR2(1000);
		verrmsg VARCHAR2(200);
	BEGIN
		t.enter(cmethodname);
	
		vdummy := int_validatechar(pvalue
								  ,pvaluename
								  ,pcheckmode
								  ,pprohibitnull
								  ,pwhatisnull
								  ,pallowedvalues
								  ,pforbiddenvalues
								  ,verrmsg);
	
		raiseif(verrmsg IS NOT NULL, nvl(perrmsg, verrmsg));
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END validatechar;

	FUNCTION validchar
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cchar_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN NUMBER := NULL
	   ,pallowedvalues   IN tblchar1000 := tblchar1000()
	   ,pforbiddenvalues IN tblchar1000 := tblchar1000()
	   ,oerrmsg          OUT VARCHAR2
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.ValidChar';
		vdummy  VARCHAR2(1000);
		vresult BOOLEAN;
	BEGIN
		t.enter(cmethodname);
	
		vdummy := int_validatechar(pvalue
								  ,pvaluename
								  ,pcheckmode
								  ,pprohibitnull
								  ,pwhatisnull
								  ,pallowedvalues
								  ,pforbiddenvalues
								  ,oerrmsg);
	
		vresult := oerrmsg IS NULL;
	
		t.leave(cmethodname, htools.b2s(vresult));
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END validchar;

	FUNCTION getvalidchar
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cchar_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN NUMBER := NULL
	   ,pallowedvalues   IN tblchar1000 := tblchar1000()
	   ,pforbiddenvalues IN tblchar1000 := tblchar1000()
	   ,perrmsg          IN VARCHAR2 := NULL
	) RETURN VARCHAR2 IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.GetValidChar';
		verrmsg VARCHAR2(200);
		vresult VARCHAR2(1000);
	BEGIN
		t.enter(cmethodname);
	
		vresult := int_validatechar(pvalue
								   ,pvaluename
								   ,pcheckmode
								   ,pprohibitnull
								   ,pwhatisnull
								   ,pallowedvalues
								   ,pforbiddenvalues
								   ,verrmsg);
	
		raiseif(verrmsg IS NOT NULL, nvl(perrmsg, verrmsg));
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getvalidchar;

	FUNCTION int_validatenumber
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER
	   ,pprohibitnull    IN BOOLEAN
	   ,pwhatisnull      IN NUMBER
	   ,pminvalue        IN NUMBER
	   ,pmaxvalue        IN NUMBER
	   ,pallowedvalues   IN tblnumber
	   ,pforbiddenvalues IN tblnumber
	   ,oerrmsg          OUT VARCHAR2
	) RETURN NUMBER IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.Int_ValidateNumber';
		vparamdescr VARCHAR2(200) := CASE
										 WHEN pvaluename IS NOT NULL THEN
										  '"' || pvaluename || '" '
									 END;
		vrawvalue   VARCHAR2(2000);
		vresult     NUMBER;
	BEGIN
		t.enter(cmethodname, pvalue);
	
		vrawvalue := nvl(pvalue, pwhatisnull);
	
		IF vrawvalue IS NULL
		THEN
		
			IF pprohibitnull
			THEN
				oerrmsg := 'Value of parameter ' || vparamdescr || ' not defined!';
			END IF;
		
		ELSE
		
			IF isnumber(vrawvalue)
			THEN
			
				vresult := vrawvalue;
			
				IF (pminvalue IS NOT NULL)
				   AND (vresult < pminvalue)
				THEN
					oerrmsg := 'Value <' || vresult || '> of parameter ' || vparamdescr ||
							   ' is less than minimum allowed <' || pminvalue || '>!';
				END IF;
			
				IF oerrmsg IS NULL
				THEN
				
					IF (pmaxvalue IS NOT NULL)
					   AND (vresult > pmaxvalue)
					THEN
						oerrmsg := 'Value <' || vresult || '> of parameter ' || vparamdescr ||
								   ' exceeds maximum allowed <' || pmaxvalue || '>!';
					END IF;
				
					IF oerrmsg IS NULL
					THEN
					
						IF (pallowedvalues.count > 0)
						   AND (vresult NOT MEMBER OF pallowedvalues)
						THEN
							oerrmsg := 'Value <' || vresult || '> of parameter ' || vparamdescr ||
									   ' does not match admissible values!';
						END IF;
					
						IF oerrmsg IS NULL
						THEN
						
							IF (pforbiddenvalues.count > 0)
							   AND (vresult MEMBER OF pforbiddenvalues)
							THEN
								oerrmsg := 'Prohibited to set value <' || vresult ||
										   '> for parameter ' || vparamdescr || '!';
							END IF;
						
							IF oerrmsg IS NULL
							THEN
							
								CASE pcheckmode
								
									WHEN cnum_donotcheck THEN
										NULL;
									
									WHEN cnum_negative THEN
										IF vresult >= 0
										THEN
											oerrmsg := 'Value of parameter ' || vparamdescr ||
													   ' must be negative (<' || vresult ||
													   '> is specified)!';
										END IF;
									
									WHEN cnum_nonpositive THEN
										IF vresult > 0
										THEN
											oerrmsg := 'Value of parameter ' || vparamdescr ||
													   ' must be nonpositive (<' || vresult ||
													   '> is specified)!';
										END IF;
									
									WHEN cnum_zero THEN
										IF vresult <> 0
										THEN
											oerrmsg := 'Value of parameter ' || vparamdescr ||
													   ' must be null (<' || vresult ||
													   '> is specified)!';
										END IF;
									
									WHEN cnum_nonzero THEN
										IF vresult = 0
										THEN
											oerrmsg := 'Value of parameter ' || vparamdescr ||
													   ' must be nonzero (<' || vresult ||
													   '> is specified)!';
										END IF;
									
									WHEN cnum_nonnegative THEN
										IF vresult < 0
										THEN
											oerrmsg := 'Value of parameter ' || vparamdescr ||
													   ' must be nonnegative (<' || vresult ||
													   '> is specified)!';
										END IF;
									
									WHEN cnum_positive THEN
										IF vresult <= 0
										THEN
											oerrmsg := 'Value of parameter ' || vparamdescr ||
													   ' must be positive (<' || vresult ||
													   '> is specified)!';
										END IF;
									
									ELSE
										error.raiseerror('Internal error: unknown numeric value check mode <' ||
														 pcheckmode || '>!');
									
								END CASE;
							
							END IF;
						
						END IF;
					
					END IF;
				
				END IF;
			
			ELSE
				oerrmsg := 'Value <' || vrawvalue || '> of parameter ' || vparamdescr ||
						   ' is not numeric!';
			END IF;
		
		END IF;
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END int_validatenumber;

	PROCEDURE validatenumber
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cnum_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN NUMBER := NULL
	   ,pminvalue        IN NUMBER := NULL
	   ,pmaxvalue        IN NUMBER := NULL
	   ,pallowedvalues   IN tblnumber := tblnumber()
	   ,pforbiddenvalues IN tblnumber := tblnumber()
	   ,perrmsg          IN VARCHAR2 := NULL
	) IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.ValidateNumber';
		verrmsg VARCHAR2(200);
		vdummy  NUMBER;
	BEGIN
		t.enter(cmethodname);
	
		vdummy := int_validatenumber(pvalue
									,pvaluename
									,pcheckmode
									,pprohibitnull
									,pwhatisnull
									,pminvalue
									,pmaxvalue
									,pallowedvalues
									,pforbiddenvalues
									,verrmsg);
	
		raiseif(verrmsg IS NOT NULL, nvl(perrmsg, verrmsg));
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END validatenumber;

	FUNCTION validnumber
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cnum_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN NUMBER := NULL
	   ,pminvalue        IN NUMBER := NULL
	   ,pmaxvalue        IN NUMBER := NULL
	   ,pallowedvalues   IN tblnumber := tblnumber()
	   ,pforbiddenvalues IN tblnumber := tblnumber()
	   ,oerrmsg          OUT VARCHAR2
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.ValidNumber';
		vresult BOOLEAN;
		vdummy  NUMBER;
	BEGIN
		t.enter(cmethodname);
	
		vdummy := int_validatenumber(pvalue
									,pvaluename
									,pcheckmode
									,pprohibitnull
									,pwhatisnull
									,pminvalue
									,pmaxvalue
									,pallowedvalues
									,pforbiddenvalues
									,oerrmsg);
	
		vresult := oerrmsg IS NULL;
	
		t.leave(cmethodname, htools.b2s(vresult));
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END validnumber;

	FUNCTION getvalidnumber
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cnum_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN NUMBER := NULL
	   ,pminvalue        IN NUMBER := NULL
	   ,pmaxvalue        IN NUMBER := NULL
	   ,pallowedvalues   IN tblnumber := tblnumber()
	   ,pforbiddenvalues IN tblnumber := tblnumber()
	   ,perrmsg          IN VARCHAR2 := NULL
	) RETURN NUMBER IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.GetValidNumber';
		verrmsg VARCHAR2(200);
		vresult NUMBER;
	BEGIN
		t.enter(cmethodname);
	
		vresult := int_validatenumber(pvalue
									 ,pvaluename
									 ,pcheckmode
									 ,pprohibitnull
									 ,pwhatisnull
									 ,pminvalue
									 ,pmaxvalue
									 ,pallowedvalues
									 ,pforbiddenvalues
									 ,verrmsg);
	
		raiseif(verrmsg IS NOT NULL, nvl(perrmsg, verrmsg));
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getvalidnumber;

	FUNCTION int_validatedate
	(
		pvalue           IN DATE
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER
	   ,pprohibitnull    IN BOOLEAN
	   ,pwhatisnull      IN DATE
	   ,pminvalue        IN DATE
	   ,pmaxvalue        IN DATE
	   ,pallowedvalues   IN tbldate
	   ,pforbiddenvalues IN tbldate
	   ,oerrmsg          OUT VARCHAR2
	) RETURN DATE IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.Int_ValidateDate';
		vparamdescr VARCHAR2(200) := CASE
										 WHEN pvaluename IS NOT NULL THEN
										  '"' || pvaluename || '" '
									 END;
		vresult     DATE;
	BEGIN
		t.enter(cmethodname, pvalue);
	
		vresult := nvl(pvalue, pwhatisnull);
	
		IF vresult IS NULL
		THEN
		
			IF pprohibitnull
			THEN
				oerrmsg := 'Value of parameter ' || vparamdescr || ' not defined!';
			END IF;
		
		ELSE
		
			IF (pminvalue IS NOT NULL)
			   AND (vresult < pminvalue)
			THEN
				oerrmsg := 'Value <' || vresult || '> of parameter ' || vparamdescr ||
						   ' is less than minimum allowed <' || pminvalue || '>!';
			END IF;
		
			IF oerrmsg IS NULL
			THEN
			
				IF (pmaxvalue IS NOT NULL)
				   AND (vresult > pmaxvalue)
				THEN
					oerrmsg := 'Value <' || vresult || '> of parameter ' || vparamdescr ||
							   ' exceeds maximum allowed <' || pmaxvalue || '>!';
				END IF;
			
				IF oerrmsg IS NULL
				THEN
				
					IF (pallowedvalues.count > 0)
					   AND (vresult NOT MEMBER OF pallowedvalues)
					THEN
						oerrmsg := 'Value <' || vresult || '> of parameter ' || vparamdescr ||
								   ' does not match admissible values!';
					END IF;
				
					IF oerrmsg IS NULL
					THEN
					
						IF (pforbiddenvalues.count > 0)
						   AND (vresult MEMBER OF pforbiddenvalues)
						THEN
							oerrmsg := 'Prohibited to set value <' || vresult || '> for parameter ' ||
									   vparamdescr || '!';
						END IF;
					
						IF oerrmsg IS NULL
						THEN
						
							CASE pcheckmode
							
								WHEN cdate_donotcheck THEN
									NULL;
								
								WHEN cdate_nodayoff THEN
									IF referencecalendar.isselectedday(vresult)
									THEN
										oerrmsg := 'Date specified ' || vparamdescr ||
												   'cannot fall on day off!';
									END IF;
								
								WHEN cdate_dayoffnow THEN
									IF (vresult <> seance.getoperdate)
									   AND referencecalendar.isselectedday(vresult)
									THEN
										oerrmsg := 'Date specified ' || vparamdescr ||
												   'cannot fall on day off!';
									END IF;
								
								ELSE
									error.raiseerror('Internal error: unknown date check mode <' ||
													 pcheckmode || '>!');
								
							END CASE;
						
						END IF;
					
					END IF;
				
				END IF;
			
			END IF;
		
		END IF;
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END int_validatedate;

	FUNCTION int_getdateforvalidation
	(
		pvalue      IN VARCHAR2
	   ,pvaluename  IN VARCHAR2
	   ,pformat     IN VARCHAR2
	   ,pwhatisnull IN DATE
	) RETURN DATE IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.Int_GetDateForValidation';
		vresult DATE;
	BEGIN
		t.enter(cmethodname);
	
		IF pvalue IS NULL
		THEN
			vresult := pwhatisnull;
		
		ELSE
			IF isdate(pvalue, pformat)
			THEN
				vresult := to_date(pvalue, pformat);
			ELSE
				error.raiseerror('Value <' || pvalue || '> of parameter ' || CASE WHEN
								 pvaluename IS NOT NULL THEN '"' || pvaluename || '" '
								 END || 'is not date in format <' || pformat || '>!');
			END IF;
		END IF;
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END int_getdateforvalidation;

	PROCEDURE validatedate
	(
		pvalue           IN DATE
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cdate_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN DATE := NULL
	   ,pminvalue        IN DATE := NULL
	   ,pmaxvalue        IN DATE := NULL
	   ,pallowedvalues   IN tbldate := tbldate()
	   ,pforbiddenvalues IN tbldate := tbldate()
	   ,perrmsg          IN VARCHAR2 := NULL
	) IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.ValidateDate';
		verrmsg VARCHAR2(200);
		vdummy  DATE;
	BEGIN
		t.enter(cmethodname);
	
		vdummy := int_validatedate(pvalue
								  ,pvaluename
								  ,pcheckmode
								  ,pprohibitnull
								  ,pwhatisnull
								  ,pminvalue
								  ,pmaxvalue
								  ,pallowedvalues
								  ,pforbiddenvalues
								  ,verrmsg);
	
		raiseif(verrmsg IS NOT NULL, nvl(perrmsg, verrmsg));
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END validatedate;

	PROCEDURE validatedate
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pformat          IN VARCHAR2 := contractparams.cparam_date_format
	   ,pcheckmode       IN PLS_INTEGER := cdate_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN DATE := NULL
	   ,pminvalue        IN DATE := NULL
	   ,pmaxvalue        IN DATE := NULL
	   ,pallowedvalues   IN tbldate := tbldate()
	   ,pforbiddenvalues IN tbldate := tbldate()
	   ,perrmsg          IN VARCHAR2 := NULL
	) IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.ValidateDate';
		verrmsg      VARCHAR2(200);
		vdatetocheck DATE;
		vdummy       DATE;
	BEGIN
		t.enter(cmethodname);
	
		vdatetocheck := int_getdateforvalidation(pvalue, pvaluename, pformat, pwhatisnull);
	
		vdummy := int_validatedate(vdatetocheck
								  ,pvaluename
								  ,pcheckmode
								  ,pprohibitnull
								  ,pwhatisnull
								  ,pminvalue
								  ,pmaxvalue
								  ,pallowedvalues
								  ,pforbiddenvalues
								  ,verrmsg);
	
		raiseif(verrmsg IS NOT NULL, nvl(perrmsg, verrmsg));
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END validatedate;

	FUNCTION validdate
	(
		pvalue           IN DATE
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cdate_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN DATE := NULL
	   ,pminvalue        IN DATE := NULL
	   ,pmaxvalue        IN DATE := NULL
	   ,pallowedvalues   IN tbldate := tbldate()
	   ,pforbiddenvalues IN tbldate := tbldate()
	   ,oerrmsg          OUT VARCHAR2
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.ValidDate';
		vresult BOOLEAN;
		vdummy  DATE;
	BEGIN
		t.enter(cmethodname);
	
		vdummy := int_validatedate(pvalue
								  ,pvaluename
								  ,pcheckmode
								  ,pprohibitnull
								  ,pwhatisnull
								  ,pminvalue
								  ,pmaxvalue
								  ,pallowedvalues
								  ,pforbiddenvalues
								  ,oerrmsg);
	
		vresult := oerrmsg IS NULL;
	
		t.leave(cmethodname, htools.b2s(vresult));
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END validdate;

	FUNCTION validdate
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pformat          IN VARCHAR2 := contractparams.cparam_date_format
	   ,pcheckmode       IN PLS_INTEGER := cdate_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN DATE := NULL
	   ,pminvalue        IN DATE := NULL
	   ,pmaxvalue        IN DATE := NULL
	   ,pallowedvalues   IN tbldate := tbldate()
	   ,pforbiddenvalues IN tbldate := tbldate()
	   ,oerrmsg          OUT VARCHAR2
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.ValidDate';
		vdatetocheck DATE;
		vresult      BOOLEAN;
		vdummy       DATE;
	BEGIN
		t.enter(cmethodname);
	
		vdatetocheck := int_getdateforvalidation(pvalue, pvaluename, pformat, pwhatisnull);
	
		vdummy := int_validatedate(vdatetocheck
								  ,pvaluename
								  ,pcheckmode
								  ,pprohibitnull
								  ,pwhatisnull
								  ,pminvalue
								  ,pmaxvalue
								  ,pallowedvalues
								  ,pforbiddenvalues
								  ,oerrmsg);
	
		vresult := oerrmsg IS NULL;
	
		t.leave(cmethodname, htools.b2s(vresult));
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END validdate;

	FUNCTION getvaliddate
	(
		pvalue           IN DATE
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER := cdate_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN DATE := NULL
	   ,pminvalue        IN DATE := NULL
	   ,pmaxvalue        IN DATE := NULL
	   ,pallowedvalues   IN tbldate := tbldate()
	   ,pforbiddenvalues IN tbldate := tbldate()
	   ,perrmsg          IN VARCHAR2 := NULL
	) RETURN DATE IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.GetValidDate';
		verrmsg VARCHAR2(200);
		vresult DATE;
	BEGIN
		t.enter(cmethodname);
	
		vresult := int_validatedate(pvalue
								   ,pvaluename
								   ,pcheckmode
								   ,pprohibitnull
								   ,pwhatisnull
								   ,pminvalue
								   ,pmaxvalue
								   ,pallowedvalues
								   ,pforbiddenvalues
								   ,verrmsg);
	
		raiseif(verrmsg IS NOT NULL, nvl(perrmsg, verrmsg));
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getvaliddate;

	FUNCTION getvaliddate
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pformat          IN VARCHAR2 := contractparams.cparam_date_format
	   ,pcheckmode       IN PLS_INTEGER := cdate_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN DATE := NULL
	   ,pminvalue        IN DATE := NULL
	   ,pmaxvalue        IN DATE := NULL
	   ,pallowedvalues   IN tbldate := tbldate()
	   ,pforbiddenvalues IN tbldate := tbldate()
	   ,perrmsg          IN VARCHAR2 := NULL
	) RETURN DATE IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.GetValidDate';
		verrmsg      VARCHAR2(200);
		vdatetocheck DATE;
		vresult      DATE;
	BEGIN
		t.enter(cmethodname);
	
		vdatetocheck := int_getdateforvalidation(pvalue, pvaluename, pformat, pwhatisnull);
	
		vresult := int_validatedate(vdatetocheck
								   ,pvaluename
								   ,pcheckmode
								   ,pprohibitnull
								   ,pwhatisnull
								   ,pminvalue
								   ,pmaxvalue
								   ,pallowedvalues
								   ,pforbiddenvalues
								   ,verrmsg);
	
		raiseif(verrmsg IS NOT NULL, nvl(perrmsg, verrmsg));
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getvaliddate;

	FUNCTION int_validateaccount
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2
	   ,pcheckmode       IN PLS_INTEGER
	   ,pprohibitnull    IN BOOLEAN
	   ,pwhatisnull      IN typeaccountno
	   ,pallowedvalues   IN tblchar20
	   ,pforbiddenvalues IN tblchar20
	   ,oerrmsg          OUT VARCHAR2
	) RETURN typeaccountno IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.Int_ValidateAccount';
		vaccdescr VARCHAR2(200) := CASE
									   WHEN pvaluename IS NOT NULL THEN
										'("' || pvaluename || '") '
								   END;
		vrawvalue VARCHAR2(2000);
		vresult   typeaccountno;
	BEGIN
		t.enter(cmethodname, pvalue);
	
		vrawvalue := nvl(pvalue, pwhatisnull);
	
		IF vrawvalue IS NULL
		THEN
		
			IF pprohibitnull
			THEN
				oerrmsg := 'Number of account ' || vaccdescr || ' not defined!';
			END IF;
		
		ELSE
		
			IF account.accountexist(vrawvalue)
			THEN
			
				vresult := vrawvalue;
			
				IF (pallowedvalues.count > 0)
				   AND (vresult NOT MEMBER OF pallowedvalues)
				THEN
					oerrmsg := 'Number of account  <' || vresult || '> ' || vaccdescr ||
							   ' does not match admissible values!';
				END IF;
			
				IF oerrmsg IS NULL
				THEN
				
					IF (pforbiddenvalues.count > 0)
					   AND (vresult MEMBER OF pforbiddenvalues)
					THEN
						oerrmsg := 'Account number <' || vresult || '> ' || vaccdescr ||
								   ' is in range of prohibited values!';
					END IF;
				
					IF oerrmsg IS NULL
					THEN
					
						CASE pcheckmode
						
							WHEN cacc_donotcheck THEN
								NULL;
							
							ELSE
								error.raiseerror('Internal error: unknown account number check mode <' ||
												 pcheckmode || '>!');
							
						END CASE;
					
					END IF;
				
				END IF;
			
			ELSE
				oerrmsg := 'Value <' || vrawvalue || '> ' || vaccdescr || ' is not account number!';
			END IF;
		
		END IF;
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END int_validateaccount;

	PROCEDURE validateaccount
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2 := NULL
	   ,pcheckmode       IN PLS_INTEGER := cacc_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN typeaccountno := NULL
	   ,pallowedvalues   IN tblchar20 := tblchar20()
	   ,pforbiddenvalues IN tblchar20 := tblchar20()
	   ,perrmsg          IN VARCHAR2 := NULL
	) IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.ValidateAccount';
		verrmsg VARCHAR2(200);
		vdummy  typeaccountno;
	BEGIN
		t.enter(cmethodname);
	
		vdummy := int_validateaccount(pvalue
									 ,pvaluename
									 ,pcheckmode
									 ,pprohibitnull
									 ,pwhatisnull
									 ,pallowedvalues
									 ,pforbiddenvalues
									 ,verrmsg);
	
		raiseif(verrmsg IS NOT NULL, nvl(perrmsg, verrmsg));
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END validateaccount;

	FUNCTION validaccount
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2 := NULL
	   ,pcheckmode       IN PLS_INTEGER := cacc_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN typeaccountno := NULL
	   ,pallowedvalues   IN tblchar20 := tblchar20()
	   ,pforbiddenvalues IN tblchar20 := tblchar20()
	   ,oerrmsg          OUT VARCHAR2
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.ValidAccount';
		vdummy  typeaccountno;
		vresult BOOLEAN;
	BEGIN
		t.enter(cmethodname);
	
		vdummy := int_validateaccount(pvalue
									 ,pvaluename
									 ,pcheckmode
									 ,pprohibitnull
									 ,pwhatisnull
									 ,pallowedvalues
									 ,pforbiddenvalues
									 ,oerrmsg);
	
		vresult := oerrmsg IS NULL;
	
		t.leave(cmethodname, htools.b2s(vresult));
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END validaccount;

	FUNCTION getvalidaccount
	(
		pvalue           IN VARCHAR2
	   ,pvaluename       IN VARCHAR2 := NULL
	   ,pcheckmode       IN PLS_INTEGER := cacc_donotcheck
	   ,pprohibitnull    IN BOOLEAN := TRUE
	   ,pwhatisnull      IN typeaccountno := NULL
	   ,pallowedvalues   IN tblchar20 := tblchar20()
	   ,pforbiddenvalues IN tblchar20 := tblchar20()
	   ,perrmsg          IN VARCHAR2 := NULL
	) RETURN typeaccountno IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.GetValidAccount';
		verrmsg VARCHAR2(200);
		vresult typeaccountno;
	BEGIN
		t.enter(cmethodname);
	
		vresult := int_validateaccount(pvalue
									  ,pvaluename
									  ,pcheckmode
									  ,pprohibitnull
									  ,pwhatisnull
									  ,pallowedvalues
									  ,pforbiddenvalues
									  ,verrmsg);
	
		raiseif(verrmsg IS NOT NULL, nvl(perrmsg, verrmsg));
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getvalidaccount;

	FUNCTION equal
	(
		pnum1 IN NUMBER
	   ,pnum2 IN NUMBER
	) RETURN BOOLEAN IS
	BEGIN
		IF pnum1 IS NULL
		THEN
			RETURN(pnum2 IS NULL);
		ELSIF pnum2 IS NULL
		THEN
			RETURN FALSE;
		ELSE
			RETURN pnum1 = pnum2;
		END IF;
	END equal;

	FUNCTION notequal
	(
		pnum1 IN NUMBER
	   ,pnum2 IN NUMBER
	) RETURN BOOLEAN IS
	BEGIN
		RETURN NOT equal(pnum1, pnum2);
	END notequal;

	FUNCTION equal
	(
		pstr1 IN VARCHAR2
	   ,pstr2 IN VARCHAR2
	) RETURN BOOLEAN IS
	BEGIN
		IF pstr1 IS NULL
		THEN
			RETURN(pstr2 IS NULL);
		ELSIF pstr2 IS NULL
		THEN
			RETURN FALSE;
		ELSE
			RETURN pstr1 = pstr2;
		END IF;
	END equal;

	FUNCTION notequal
	(
		pstr1 IN VARCHAR2
	   ,pstr2 IN VARCHAR2
	) RETURN BOOLEAN IS
	BEGIN
		RETURN NOT equal(pstr1, pstr2);
	END notequal;

	FUNCTION equal
	(
		pdate1 IN DATE
	   ,pdate2 IN DATE
	) RETURN BOOLEAN IS
	BEGIN
		IF pdate1 IS NULL
		THEN
			RETURN(pdate2 IS NULL);
		ELSIF pdate2 IS NULL
		THEN
			RETURN FALSE;
		ELSE
			RETURN pdate1 = pdate2;
		END IF;
	END equal;

	FUNCTION notequal
	(
		pdate1 IN DATE
	   ,pdate2 IN DATE
	) RETURN BOOLEAN IS
	BEGIN
		RETURN NOT equal(pdate1, pdate2);
	END notequal;

	FUNCTION equal
	(
		pboolean1 IN BOOLEAN
	   ,pboolean2 IN BOOLEAN
	) RETURN BOOLEAN IS
	BEGIN
		IF pboolean1 IS NULL
		THEN
			RETURN(pboolean2 IS NULL);
		ELSIF pboolean2 IS NULL
		THEN
			RETURN FALSE;
		ELSE
			RETURN pboolean1 = pboolean2;
		END IF;
	END equal;

	FUNCTION notequal
	(
		pboolean1 IN BOOLEAN
	   ,pboolean2 IN BOOLEAN
	) RETURN BOOLEAN IS
	BEGIN
		RETURN NOT equal(pboolean1, pboolean2);
	END notequal;

	FUNCTION leastdate
	(
		pdate1 IN DATE
	   ,pdate2 IN DATE
	) RETURN DATE IS
		cmethodname CONSTANT VARCHAR(60) := cpackage_name || '.LeastDate';
	BEGIN
		IF pdate1 IS NULL
		THEN
			RETURN pdate2;
		ELSE
			RETURN nvl(least(pdate1, pdate2), pdate1);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END leastdate;

	FUNCTION greatestdate
	(
		pdate1 IN DATE
	   ,pdate2 IN DATE
	) RETURN DATE IS
		cmethodname CONSTANT VARCHAR(60) := cpackage_name || '.GreatestDate';
	BEGIN
		IF pdate1 IS NULL
		THEN
			RETURN pdate2;
		ELSE
			RETURN nvl(greatest(pdate1, pdate2), pdate1);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END greatestdate;

	FUNCTION datesinsamemonths
	(
		pdate1 IN DATE
	   ,pdate2 IN DATE
	) RETURN BOOLEAN IS
	BEGIN
		RETURN trunc(pdate1, 'MM') = trunc(pdate2, 'MM');
	END datesinsamemonths;

	FUNCTION datesindiffmonths
	(
		pdate1 IN DATE
	   ,pdate2 IN DATE
	) RETURN BOOLEAN IS
	BEGIN
		RETURN trunc(pdate1, 'MM') <> trunc(pdate2, 'MM');
	END datesindiffmonths;

	FUNCTION getsumincurrency
	(
		psum          IN NUMBER
	   ,pfromcurrency IN NUMBER
	   ,ptocurrency   IN NUMBER
	   ,pexchrate     IN NUMBER := NULL
	   ,poperdate     IN DATE := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.GetSumInCurrency [main]';
		vresult NUMBER;
	BEGIN
		t.enter(cmethod_name);
	
		IF ptocurrency = pfromcurrency
		THEN
			vresult := psum;
		ELSE
			IF exchangerate.preparesumma(pfromcurrency
										,ptocurrency
										,pfromcurrency
										,psum
										,coalesce(pexchrate, exchangerate.getdefaultexchange)
										,coalesce(poperdate, seance.getoperdate)) = 0
			THEN
				vresult := exchangerate.ssummato;
			ELSE
				error.raiseerror(err.geterrorcode, err.getfullmessage);
			END IF;
		END IF;
	
		t.leave(cmethod_name, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END getsumincurrency;

	FUNCTION getsumincurrency
	(
		pamount     IN tamount
	   ,ptocurrency IN NUMBER
	   ,pexchrate   IN NUMBER := NULL
	   ,poperdate   IN DATE := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.GetSumInCurrency [from Amount]';
	BEGIN
		RETURN getsumincurrency(pamount.value
							   ,pamount.currencycode
							   ,ptocurrency
							   ,pexchrate
							   ,poperdate);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END getsumincurrency;

	FUNCTION getsumincurrency
	(
		paccountrecord IN taccountrecord
	   ,ptocurrency    IN NUMBER
	   ,pexchrate      IN NUMBER := NULL
	   ,poperdate      IN DATE := NULL
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name ||
											 '.GetSumInCurrency [from AccountRecord]';
	BEGIN
		RETURN getsumincurrency(paccountrecord.remain
							   ,paccountrecord.currencyno
							   ,ptocurrency
							   ,pexchrate
							   ,poperdate);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END getsumincurrency;

	FUNCTION pushdocno2skip(pdocno IN tdocument.docno%TYPE) RETURN BOOLEAN IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.PushDocNo2Skip';
		vret BOOLEAN;
	BEGIN
		t.enter(cmethod_name, 'pDocNo=' || pdocno, csay_level);
		IF pdocno IS NULL
		THEN
			error.raiseerror('Financial document No not defined');
		END IF;
		IF sadocno2skiplist.exists(to_char(pdocno))
		THEN
		
			vret := FALSE;
		ELSE
			sadocno2skiplist(to_char(pdocno)) := 1;
			vret := TRUE;
		END IF;
		t.leave(cmethod_name, 'vRet=' || t.b2t(vret), csay_level);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE popdocno2skip(pdocno IN tdocument.docno%TYPE) IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.PopDocNo2Skip';
	BEGIN
		t.enter(cmethod_name, 'pDocNo=' || pdocno, csay_level);
		sadocno2skiplist.delete(to_char(pdocno));
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE cleardocno2skip IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.ClearDocNo2Skip';
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		sadocno2skiplist.delete();
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE entryundo
	(
		pdocno         IN tdocument.docno%TYPE
	   ,pcheck         IN NUMBER := NULL
	   ,pwithoutlogoff IN BOOLEAN := FALSE
	)
	
	 IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.EntryUndo';
	BEGIN
		t.enter(cmethod_name, 'pDocNo=' || pdocno, csay_level);
	
		IF pdocno IS NULL
		THEN
			error.raiseerror('Financial document No not defined');
		END IF;
	
		IF pushdocno2skip(pdocno)
		THEN
			DECLARE
				verrcode NUMBER;
			BEGIN
				verrcode := entry.undo(nvl(pcheck, entry.flnocheck)
									  ,pdocno
									  ,nvl(pwithoutlogoff, FALSE));
			
				IF verrcode != 0
				THEN
					IF verrcode != err.entry_not_found
					THEN
						error.raisewhenerr();
					ELSE
						err.seterror(0, cmethod_name);
					END IF;
				END IF;
			
				popdocno2skip(pdocno);
			EXCEPTION
				WHEN OTHERS THEN
					popdocno2skip(pdocno);
					RAISE;
			END;
		
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
		
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END entryundo;

	PROCEDURE validatesequence
	(
		psequencename IN VARCHAR2
	   ,ptablename    IN VARCHAR2
	   ,pcolumnname   IN VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.ValidateSequence';
		vincrementby NUMBER;
		vseqvalue    NUMBER;
		vmaxvalue    NUMBER;
		vdummy       NUMBER;
	BEGIN
		t.enter(cmethod_name
			   ,'SequenceName = ' || psequencename || ', TableName = ' || ptablename ||
				', FieldName = ' || pcolumnname);
	
		BEGIN
			SELECT last_number
				  ,increment_by
			INTO   vseqvalue
				  ,vincrementby
			FROM   dba_sequences
			WHERE  upper(sequence_name) = upper(psequencename);
		EXCEPTION
			WHEN no_data_found THEN
				error.raiseerror('Not found sequence <' || psequencename || '>!');
			WHEN OTHERS THEN
				RAISE;
		END;
	
		IF vseqvalue IS NOT NULL
		THEN
		
			BEGIN
				EXECUTE IMMEDIATE 'SELECT MAX(' || pcolumnname || ') FROM ' || ptablename
					INTO vmaxvalue;
			EXCEPTION
				WHEN table_does_not_exist THEN
					error.raiseerror('Not found table <' || ptablename || '>!');
				WHEN column_does_not_exist THEN
					error.raiseerror('Table <' || ptablename || '> has no field <' || pcolumnname || '>!');
				WHEN OTHERS THEN
					RAISE;
			END;
		
			IF vmaxvalue IS NOT NULL
			THEN
			
				t.var('vSeqValue', vseqvalue);
				t.var('vMaxValue', vmaxvalue);
			
				IF vseqvalue <= vmaxvalue
				THEN
				
					EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || psequencename || ' INCREMENT BY ' ||
									  to_char(vmaxvalue - vseqvalue + 1);
				
					EXECUTE IMMEDIATE 'SELECT ' || psequencename || '.NextVal FROM Dual'
						INTO vdummy;
				
					EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || psequencename || ' INCREMENT BY ' ||
									  vincrementby;
				
					t.note(cmethod_name, 'Corrected sequence <' || psequencename || '>!');
				
				END IF;
			
			END IF;
		
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END validatesequence;

	FUNCTION getvalidatednextval
	(
		psequencename IN VARCHAR2
	   ,ptablename    IN VARCHAR2
	   ,pcolumnname   IN VARCHAR2
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.GetValidatedNextVal';
		vresult NUMBER;
	BEGIN
	
		validatesequence(psequencename, ptablename, pcolumnname);
	
		EXECUTE IMMEDIATE 'SELECT ' || psequencename || '.NextVal FROM Dual'
			INTO vresult;
	
		t.leave(cmethod_name, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END getvalidatednextval;

	FUNCTION getcardtype
	(
		ppan            IN tcard.pan%TYPE
	   ,pmbr            IN tcard.mbr%TYPE
	   ,pcheckexistence IN BOOLEAN := FALSE
	) RETURN tcard.supplementary%TYPE IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.GetCardType';
		vret tcard.supplementary%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pPAN=' || s.maskpan(ppan) || ', pMBR=' || pmbr || ', pCheckExistence=' ||
				t.b2t(pcheckexistence));
		IF nvl(pcheckexistence, FALSE)
		   AND NOT card.cardexists(ppan, pmbr)
		THEN
			error.raiseerror(err.card_not_found);
		END IF;
	
		err.seterror(0, cmethod_name);
		vret := card.getcardtype(ppan, pmbr);
		error.raisewhenerr();
		t.var('vRet', vret);
	
		IF vret = card.ccsmixed
		THEN
			vret := card.ccsprimary;
		END IF;
	
		t.leave(cmethod_name, 'vRet=' || vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE addmenuprolongation
	(
		pdialog     IN NUMBER
	   ,pmenu       IN NUMBER
	   ,pcontractno IN tcontractprolongation.contractno%TYPE
	   ,preadonly   IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddMenuProlongation';
	BEGIN
	
		t.inpar(cmethod_name, 'pContactNo=' || pcontractno);
		IF getprolongationcount(pcontractno) > 0
		THEN
			mnu.item(pmenu
					,cprolongationhistorymenu
					,'Log of prolongations'
					,0
					,0
					,'View contract prolongation history');
			dialog.hiddenchar(pdialog, cprolongationcontractno, pcontractno);
			IF nvl(preadonly, FALSE)
			THEN
				dialog.disablemenucase(pdialog, cprolongationhistorymenu);
			END IF;
			dialog.setitempre(pdialog
							 ,cprolongationhistorymenu
							 ,cpackage_name || '.AddMenuProlongation_Handler'
							 ,dialog.proctype);
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
		
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE addmenuprolongation_handler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.AddMenuProlongation_Handler';
		vcontractno tcontractprolongation.contractno%TYPE;
	BEGIN
		t.enter(cmethod_name);
		IF pwhat = dialog.wtitempre
		THEN
			t.var('pItemName', pitemname);
			IF pitemname = upper(cprolongationhistorymenu)
			THEN
				vcontractno := dialog.getchar(pdialog, cprolongationcontractno);
				t.var('vContractNo', vcontractno);
			
				dialogprolongationhistory(vcontractno);
			END IF;
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE enableprolongationmenu
	(
		pdialog  IN NUMBER
	   ,penabled IN BOOLEAN
	) IS
	BEGIN
		IF penabled
		THEN
			dialog.enablemenucase(pdialog, cprolongationhistorymenu);
		ELSE
			dialog.disablemenucase(pdialog, cprolongationhistorymenu);
		END IF;
	END;

	PROCEDURE fillprolongationhistoryparam
	(
		pdialog IN NUMBER
	   ,pidprol IN tcontractprolongation.idprol%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.FillProlongationHistoryParam';
		vhistparamslist contractparams.typearrayparam2;
		vkeyvaluelist   contracttypeschema.typekeyvaluelist;
		vindex          tcontractprolongationparams.key%TYPE;
		vname           tcontractparameters.value%TYPE;
	BEGIN
		t.enter(cmethod_name, 'pIdProl=' || pidprol);
		ktools.lclear(pdialog, cprolongationhistoryparam);
		IF pidprol IS NOT NULL
		THEN
			vhistparamslist := getprolongationparams(pidprol);
			vkeyvaluelist   := dlg_tools.gethiddenkeyvaluelist(pdialog, cprolongationkeyvaluelist);
			dialog.listclear(pdialog, cprolongationhistoryparam);
			vindex := vhistparamslist.first();
			WHILE vindex IS NOT NULL
			LOOP
				IF vkeyvaluelist.exists(vindex)
				THEN
					vname := vkeyvaluelist(vindex);
				ELSE
					vname := vindex;
				END IF;
				dialog.listaddrecord(pdialog
									,cprolongationhistoryparam
									,'1~' || vindex || '~' || vname || '~' ||
									 vhistparamslist(vindex)
									,0
									,0);
				vindex := vhistparamslist.next(vindex);
			END LOOP;
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE fillprolongationhistory
	(
		pdialog     IN NUMBER
	   ,pcontractno IN tcontract.no%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.FillProlongationHistory';
		vhistlist tarrprolongation;
		vidprol   tcontractprolongation.idprol%TYPE;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno);
		vhistlist := getprolongationlist(pcontractno);
		dialog.listclear(pdialog, cprolongationhistory);
		FOR i IN 1 .. vhistlist.count
		LOOP
			dialog.listaddrecord(pdialog
								,cprolongationhistory
								,vhistlist(i).idprol || '~' || vhistlist(i).contractno || '~' || vhistlist(i)
								 .startdate || '~' || vhistlist(i).enddate || '~' || vhistlist(i)
								 .value
								,0
								,0);
		END LOOP;
		vidprol := dialog.getcurrentrecordnumber(pdialog, cprolongationhistory, cfield_idprol);
		fillprolongationhistoryparam(pdialog, vidprol);
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE makeprolongationhistoryitem
	(
		pdialog       IN NUMBER
	   ,pitemname     IN VARCHAR2
	   ,px            IN NUMBER
	   ,py            IN NUMBER
	   ,pwidth        IN NUMBER
	   ,phight        IN NUMBER
	   ,panchor       IN NUMBER
	   ,pcontractno   IN tcontract.no%TYPE
	   ,pkeyvaluelist IN contracttypeschema.typekeyvaluelist
	) IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.MakeProlongationHistoryItem';
	
		chandler CONSTANT VARCHAR2(100) := cpackage_name || '.MakeProlongHistItem_Handler';
		vpanel NUMBER;
	BEGIN
		t.enter(cmethod_name);
		vpanel := dialog.panel(pdialog, pitemname, px, py, pwidth - 1, phight + 1, 0);
		dialog.setanchor(pdialog, pitemname, panchor);
	
		dialog.list(vpanel
				   ,cprolongationhistory
				   ,1
				   ,2
				   ,round(pwidth / 2) - 3
				   ,phight - 2
				   ,'Log of prolongations'
				   ,TRUE
				   ,panchor => dialog.anchor_all);
		dialog.listaddfield(vpanel, cprolongationhistory, cfield_idprol, 'N', 5, 0);
		dialog.listaddfield(vpanel, cprolongationhistory, cfield_contractno, 'C', 20, 0);
		dialog.listaddfield(vpanel, cprolongationhistory, cfield_startdate, 'D', 10, 1);
		dialog.listaddfield(vpanel, cprolongationhistory, cfield_enddate, 'D', 10, 1);
		dialog.listaddfield(vpanel, cprolongationhistory, cfield_value, 'N', 5, 1);
	
		dialog.setcaption(vpanel, cprolongationhistory, 'Date from~Date to~Value~');
	
		dialog.setitemchange(vpanel, cprolongationhistory, chandler);
	
		dialog.list(vpanel
				   ,cprolongationhistoryparam
				   ,round(pwidth / 2) + 1
				   ,2
				   ,pwidth - round(pwidth / 2) - 4
				   ,phight - 2
				   ,'Prolongation parameters'
				   ,panchor => dialog.anchor_bottom + dialog.anchor_right + dialog.anchor_top);
		dialog.listaddfield(vpanel, cprolongationhistoryparam, cfield_idprol, 'N', 5, 0);
		dialog.listaddfield(vpanel, cprolongationhistoryparam, cfield_key, 'C', 15, 0);
		dialog.listaddfield(vpanel, cprolongationhistoryparam, cfield_name, 'C', 15, 1);
		dialog.listaddfield(vpanel, cprolongationhistoryparam, cfield_value, 'C', 20, 1);
	
		dialog.setcaption(vpanel, cprolongationhistoryparam, 'Name~Value~');
	
		dlg_tools.hiddenkeyvaluelist(vpanel, cprolongationkeyvaluelist, pkeyvaluelist);
	
		fillprolongationhistory(vpanel, pcontractno);
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE makeprolonghistitem_handler
	(
		pwhat     CHAR
	   ,pdialog   NUMBER
	   ,pitemname VARCHAR
	   ,pcmd      NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.MakeProlongHistItem_Handler';
		vidprol tcontractprolongation.idprol%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,': reason ' || pwhat || ' item name ' || pitemname || ' command ' || pcmd
			   ,csay_level);
		CASE pwhat
			WHEN dialog.wtdialogpre THEN
				t.note('*** wtDialogPre ***');
			WHEN dialog.wtitempre THEN
				t.note('*** wtItemPre ***');
			WHEN dialog.wtnextfield THEN
				t.note('*** wtNextField ***');
			WHEN dialog.wt_itemchange THEN
				t.note('*** Dialog.wt_ItemChange ***');
				vidprol := dialog.getcurrentrecordnumber(pdialog
														,cprolongationhistory
														,cfield_idprol);
				fillprolongationhistoryparam(pdialog, vidprol);
			WHEN dialog.wtitempost THEN
				t.note('*** wtItemPost ***');
			WHEN dialog.wtdialogpost THEN
				t.note('*** wtDialogPost ***');
			ELSE
				t.note('*** else ***');
		END CASE;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION dialogprolongationhistory
	(
		pcontractno   IN tcontract.no%TYPE
	   ,pkeyvaluelist IN contracttypeschema.typekeyvaluelist
	   ,preadonly     IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR(65) := cpackage_name || '.DialogProlongationHistory[1]';
		vdialog NUMBER;
		vy      NUMBER := 2;
		chandler CONSTANT VARCHAR2(100) := cpackage_name || '.DialogProlongationHist_Handler';
	BEGIN
		t.enter(cmethod_name
			   ,'pContractNo=' || pcontractno || ', pKeyValueList.count=' || pkeyvaluelist.count ||
				', pReadOnly=' || t.b2t(preadonly));
	
		vdialog := dialog.new('Log of prolongations for contract [' || pcontractno || ']'
							 ,0
							 ,0
							 ,80
							 ,0);
	
		dialog.hiddenchar(vdialog, cprolongationcontractno, pcontractno);
		dialog.hiddenbool(vdialog, cprolongationreadonly, preadonly);
	
		makeprolongationhistoryitem(vdialog
								   ,cprolongationhistorypanel
								   ,1
								   ,1
								   ,80
								   ,10
								   ,dialog.anchor_all
								   ,pcontractno
								   ,pkeyvaluelist);
	
		dialog.button(vdialog
					 ,'Ok'
					 ,round(80 / 2 - 10 / 2)
					 ,vy + 10
					 ,10
					 ,'Exit'
					 ,dialog.cmok
					 ,0
					 ,'Exit');
		dialog.setitempre(vdialog, 'Ok', chandler);
	
		dialog.setdefault(vdialog, 'Ok', TRUE);
	
		dialog.setdialogpre(vdialog, chandler);
		dialog.setdialogvalid(vdialog, chandler);
		dialog.setdialogpost(vdialog, chandler);
	
		t.leave(cmethod_name);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE dialogprolongationhist_handler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR2
	   ,pcmd      IN NUMBER
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.DialogProlongationHist_Handler';
		vidprol tcontractprolongation.idprol%TYPE;
	BEGIN
		t.enter(cmethod_name
			   ,': reason ' || pwhat || ' item name ' || pitemname || ' command ' || pcmd
			   ,csay_level);
		CASE pwhat
			WHEN dialog.wtdialogpre THEN
				t.note('*** wtDialogPre ***');
			WHEN dialog.wtitempre THEN
				t.note('*** wtItemPre ***');
			WHEN dialog.wtnextfield THEN
				t.note('*** wtNextField ***');
			WHEN dialog.wt_itemchange THEN
				t.note('*** Dialog.wt_ItemChange ***');
			
			WHEN dialog.wtitempost THEN
				t.note('*** wtItemPost ***');
			WHEN dialog.wtdialogpost THEN
				t.note('*** wtDialogPost ***');
			ELSE
				t.note('*** else ***');
		END CASE;
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			error.showerror();
			dialog.goitem(pdialog, 'Ok');
	END;

	PROCEDURE dialogprolongationhistory
	(
		pcontractno IN tcontractprolongation.contractno%TYPE
	   ,preadonly   IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.DialogProlongationHistory[2]';
		vdialog       NUMBER;
		vcontractno   tcontractprolongation.contractno%TYPE;
		vkeyvaluelist contracttypeschema.typekeyvaluelist;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno);
		vkeyvaluelist := contracttypeschema.getprolongationparamnamelist(pcontractno);
		vdialog       := dialogprolongationhistory(pcontractno
												  ,vkeyvaluelist
												  ,nvl(preadonly, FALSE));
		dialog.exec(vdialog);
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	FUNCTION contractcommited(pcontractno IN tcontract.no%TYPE) RETURN BOOLEAN IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT typemethodname := cpackage_name || '.ContractCommited';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		vcontractno tcontract.no%TYPE;
	BEGIN
		t.enter(cmethodname);
	
		SELECT no
		INTO   vcontractno
		FROM   tcontract
		WHERE  branch = cbranch
		AND    no = pcontractno;
	
		t.leave(cmethodname, htools.b2s(TRUE));
		RETURN TRUE;
	EXCEPTION
		WHEN no_data_found THEN
			t.leave(cmethodname, htools.b2s(FALSE));
			RETURN FALSE;
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END contractcommited;

	FUNCTION cardcommited
	(
		ppan IN typepan
	   ,pmbr IN typembr
	) RETURN BOOLEAN IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT typemethodname := cpackage_name || '.CardCommited';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		vpan typepan;
		vmbr typembr;
	BEGIN
		t.enter(cmethodname);
	
		SELECT pan
			  ,mbr
		INTO   vpan
			  ,vmbr
		FROM   tcard
		WHERE  branch = cbranch
		AND    pan = ppan
		AND    mbr = pmbr;
	
		t.leave(cmethodname, htools.b2s(TRUE));
		RETURN TRUE;
	EXCEPTION
		WHEN no_data_found THEN
			t.leave(cmethodname, htools.b2s(FALSE));
			RETURN FALSE;
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END cardcommited;

	FUNCTION nullor
	(
		pvalue1 IN NUMBER
	   ,pvalue2 IN NUMBER
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.NullOR';
	BEGIN
		RETURN(pvalue1 IS NOT NULL) OR(pvalue2 IS NOT NULL);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END nullor;

	FUNCTION nullor
	(
		pvalue1 IN VARCHAR2
	   ,pvalue2 IN VARCHAR2
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.NullOR';
	BEGIN
		RETURN(pvalue1 IS NOT NULL) OR(pvalue2 IS NOT NULL);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END nullor;

	FUNCTION nullor
	(
		pvalue1 IN DATE
	   ,pvalue2 IN DATE
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.NullOR';
	BEGIN
		RETURN(pvalue1 IS NOT NULL) OR(pvalue2 IS NOT NULL);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END nullor;

	FUNCTION nulland
	(
		pvalue1 IN NUMBER
	   ,pvalue2 IN NUMBER
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.NullAND';
	BEGIN
		RETURN(pvalue1 IS NOT NULL) AND(pvalue2 IS NOT NULL);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END nulland;

	FUNCTION nulland
	(
		pvalue1 IN VARCHAR2
	   ,pvalue2 IN VARCHAR2
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.NullAND';
	BEGIN
		RETURN(pvalue1 IS NOT NULL) AND(pvalue2 IS NOT NULL);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END nulland;

	FUNCTION nulland
	(
		pvalue1 IN DATE
	   ,pvalue2 IN DATE
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.NullAND';
	BEGIN
		RETURN(pvalue1 IS NOT NULL) AND(pvalue2 IS NOT NULL);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END nulland;

	FUNCTION nullxor
	(
		pvalue1 IN NUMBER
	   ,pvalue2 IN NUMBER
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.NullXOR';
	BEGIN
		RETURN((pvalue1 IS NULL) AND (pvalue2 IS NOT NULL)) OR((pvalue1 IS NOT NULL) AND
															   (pvalue2 IS NULL));
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END nullxor;

	FUNCTION nullxor
	(
		pvalue1 IN VARCHAR2
	   ,pvalue2 IN VARCHAR2
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.NullXOR';
	BEGIN
		RETURN((pvalue1 IS NULL) AND (pvalue2 IS NOT NULL)) OR((pvalue1 IS NOT NULL) AND
															   (pvalue2 IS NULL));
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END nullxor;

	FUNCTION nullxor
	(
		pvalue1 IN DATE
	   ,pvalue2 IN DATE
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.NullXOR';
	BEGIN
		RETURN((pvalue1 IS NULL) AND (pvalue2 IS NOT NULL)) OR((pvalue1 IS NOT NULL) AND
															   (pvalue2 IS NULL));
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END nullxor;

	FUNCTION dectobin(pnumber IN PLS_INTEGER) RETURN VARCHAR2 IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.DecToBin';
		vresult VARCHAR2(100);
	BEGIN
		t.enter(cmethodname, pnumber);
	
		SELECT listagg(sign(bitand(pnumber, power(2, LEVEL - 1))), '') within GROUP(ORDER BY LEVEL DESC)
		INTO   vresult
		FROM   dual
		CONNECT BY power(2, LEVEL - 1) <= pnumber;
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dectobin;

	FUNCTION getsetbitcount(pnumber IN PLS_INTEGER) RETURN PLS_INTEGER IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.GetSetBitCount';
		vresult NUMBER;
	BEGIN
		t.enter(cmethodname, pnumber);
	
		WITH t AS
		 (SELECT translate(to_char(pnumber, 'FMXXXXXXXX'), '0123456789ABCDEF', '0112122312232334') AS str
		  FROM   dual)
		SELECT SUM(substr(str, rownum, 1)) INTO vresult FROM t CONNECT BY LEVEL <= length(str);
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getsetbitcount;

	FUNCTION getsetbitpos(psinglebitnumber IN PLS_INTEGER) RETURN PLS_INTEGER IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.GetSetBitPos';
		vbinary VARCHAR2(100);
		vresult NUMBER;
	BEGIN
		t.enter(cmethodname, psinglebitnumber);
	
		vbinary := dectobin(psinglebitnumber);
	
		FOR i IN 1 .. length(vbinary)
		LOOP
		
			IF substr(vbinary, -i, 1) = '1'
			THEN
			
				IF vresult IS NULL
				THEN
					vresult := i;
				ELSE
					error.raiseerror('Internal error: control bit mask <' || vbinary ||
									 '> must have only one set bit!');
				END IF;
			
			END IF;
		
		END LOOP;
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getsetbitpos;

	FUNCTION bitset
	(
		pnumber          IN PLS_INTEGER
	   ,psinglebitnumber IN PLS_INTEGER
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.BitSet';
		vresult BOOLEAN;
	BEGIN
		t.enter(cmethodname, 'Number = ' || pnumber || ', SingleBitNumber = ' || psinglebitnumber);
	
		contracttools.raiseif(getsetbitcount(psinglebitnumber) <> 1
							 ,'Internal error: control bit mask <' || dectobin(psinglebitnumber) ||
							  '> must have only one set bit!');
	
		vresult := bitand(pnumber, psinglebitnumber) > 0;
	
		t.leave(cmethodname, htools.b2s(vresult));
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END bitset;

	FUNCTION getpackageinfo_maindescription
	(
		ppackageinfo    IN custom_fintypes.typepackageinfo
	   ,paddpackagename BOOLEAN := FALSE
	) RETURN VARCHAR2 IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.GetPackageInfo_Main';
	BEGIN
		RETURN ppackageinfo.packagedescr || service.iif(paddpackagename
													   ,' [' || ppackageinfo.packagename || ']'
													   ,'');
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getpackageinfo_headerdescription(ppackageinfo IN custom_fintypes.typepackageinfo)
		RETURN VARCHAR2 IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.GetPackageInfo_Header';
	BEGIN
		RETURN '  Package header: ' || ppackageinfo.headerversion || ' dated ' || htools.d2s(ppackageinfo.headerdate) || ' (' || ppackageinfo.headertwcms || ')' || service.iif(ppackageinfo.headercsm IS NULL
																																											   ,''
																																											   ,' [' ||
																																												ppackageinfo.headercsm || ']');
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getpackageinfo_bodydescription(ppackageinfo IN custom_fintypes.typepackageinfo)
		RETURN VARCHAR2 IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.GetPackageInfo_Body';
	BEGIN
		RETURN '  Package body:      ' || ppackageinfo.bodyversion || ' dated ' || htools.d2s(ppackageinfo.bodydate) || ' (' || ppackageinfo.bodytwcms || ')' || service.iif(ppackageinfo.bodycsm IS NULL
																																											,''
																																											,' [' ||
																																											 ppackageinfo.bodycsm || ']');
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE saypackageinfo(ppackageinfo IN custom_fintypes.typepackageinfo) IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.SayPackageInfo';
	BEGIN
		t.note('PackageInfo');
		s.say(getpackageinfo_maindescription(ppackageinfo, TRUE));
		s.say(getpackageinfo_headerdescription(ppackageinfo));
		s.say(getpackageinfo_bodydescription(ppackageinfo));
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE saypackageinfo(ppackagename IN custom_fintypes.typepackagename) IS
		cmethodname CONSTANT typemethodname := cpackage_name || '.SayPackageInfo';
		vpackageinfo custom_fintypes.typepackageinfo;
	BEGIN
		IF contracttypeschema.readpackageinfo(ppackagename, vpackageinfo)
		THEN
			saypackageinfo(vpackageinfo);
		ELSE
			s.say('Error of getting package information');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

BEGIN
	custom_contracttools.saypackageinfo(getpackageinfo);
END custom_contracttools;
/
