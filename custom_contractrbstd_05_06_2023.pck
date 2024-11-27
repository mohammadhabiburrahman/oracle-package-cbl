CREATE OR REPLACE PACKAGE custom_contractrbstd IS

	crevision CONSTANT VARCHAR2(100) := '$Rev: 44809 $';

	cnullchar CONSTANT VARCHAR2(3) := 'XXX';

	cclose_none        CONSTANT PLS_INTEGER := 0;
	cclose_openedcards CONSTANT PLS_INTEGER := 1;
	cclose_allcards    CONSTANT PLS_INTEGER := 2;

	TYPE typecardstatchangeinfo IS RECORD(
		 pan     tcard.pan%TYPE
		,mbr     tcard.mbr%TYPE
		,oldstat tcard.crd_stat%TYPE
		,newstat tcard.crd_stat%TYPE);

	TYPE typecardstatchangeinfoarray IS TABLE OF typecardstatchangeinfo INDEX BY PLS_INTEGER;

	TYPE typecardsignchangeinfo IS RECORD(
		 pan     tcard.pan%TYPE
		,mbr     tcard.mbr%TYPE
		,oldsign tcard.signstat%TYPE
		,newsign tcard.signstat%TYPE);

	TYPE typecardsignchangeinfoarray IS TABLE OF typecardsignchangeinfo INDEX BY PLS_INTEGER;

	FUNCTION getversion RETURN VARCHAR2;

	PROCEDURE undolabel
	(
		pcontractno tcontract.no%TYPE
	   ,plabel      contractrb.tlabel
	);

	FUNCTION getstdlbldesc(plabel contractrb.tlabel) RETURN VARCHAR2;

	FUNCTION getdocnofromrollback(prollback IN contractrb.trollbackdata) RETURN NUMBER;

	PROCEDURE closecontract
	(
		pcontractno    IN tcontract.no%TYPE
	   ,pcomment       IN VARCHAR2 := NULL
	   ,pclosedate     IN DATE := NULL
	   ,pcloseallcards IN BOOLEAN := TRUE
	   ,plog           IN BOOLEAN := FALSE
	);

	PROCEDURE closecontract
	(
		pcontractno  IN tcontract.no%TYPE
	   ,pcards2close IN PLS_INTEGER
	   ,pcomment     IN VARCHAR2 := NULL
	   ,pclosedate   IN DATE := NULL
	   ,plog         IN BOOLEAN := FALSE
	);

	PROCEDURE setentry
	(
		pdocno tdocument.docno%TYPE
	   ,pcheck NUMBER := NULL
	);

	PROCEDURE violateon
	(
		pcontractno tcontract.no%TYPE
	   ,poldstatus  tcontract.status%TYPE := cnullchar
	   ,plog        BOOLEAN := FALSE
	);

	PROCEDURE violateoff
	(
		pcontractno tcontract.no%TYPE
	   ,poldstatus  tcontract.status%TYPE := cnullchar
	   ,plog        BOOLEAN := FALSE
	);

	PROCEDURE creditstart
	(
		paccountno taccount.accountno%TYPE
	   ,pdate      DATE := NULL
	);

	PROCEDURE creditchange
	(
		paccountno taccount.accountno%TYPE
	   ,pdate      DATE := NULL
	   ,pnewdate   DATE := NULL
	);

	PROCEDURE creditend
	(
		paccountno taccount.accountno%TYPE
	   ,pdate      DATE := NULL
	);

	PROCEDURE setarcdate
	(
		pcontractno  tcontract.no%TYPE
	   ,pcurrarcdate DATE
	   ,pnewarcdate  DATE
	);

	PROCEDURE setctrldate
	(
		pcontractno IN tcontract.no%TYPE
	   ,pkey        IN tcontractctrldate.key%TYPE
	   ,pdate       IN DATE
	   ,psaveequal  IN BOOLEAN := FALSE
	);

	PROCEDURE setarcdatebyctrl
	(
		pcontractno  tcontract.no%TYPE
	   ,pcurrarcdate DATE
	);

	PROCEDURE setaccacct_stat
	(
		paccount   IN OUT NOCOPY taccount%ROWTYPE
	   ,pacct_stat taccount.acct_stat%TYPE
	);

	PROCEDURE setaccacct_stat
	(
		paccount   IN OUT NOCOPY contracttools.taccountrecord
	   ,pacct_stat taccount.acct_stat%TYPE
	);

	PROCEDURE changegrouprisk
	(
		pcontractno tcontract.no%TYPE
	   ,poldvalue   tgrouprisk.oldgroup%TYPE
	   ,pnewvalue   tgrouprisk.newgroup%TYPE
	   ,pdate       DATE := NULL
	   ,pgrouptype  tgrouprisk.grouptype%TYPE := contracttools.cgrpcrd
	);

	PROCEDURE createaccountbycode
	(
		pcontract IN tcontract%ROWTYPE
	   ,paccount  IN OUT NOCOPY contracttools.taccountrecord
	);

	PROCEDURE suspendon
	(
		pcontractno tcontract.no%TYPE
	   ,poldstatus  tcontract.status%TYPE := cnullchar
	   ,plog        BOOLEAN := FALSE
	);

	PROCEDURE suspendoff
	(
		pcontractno tcontract.no%TYPE
	   ,poldstatus  tcontract.status%TYPE := cnullchar
	   ,plog        BOOLEAN := FALSE
	);
	PROCEDURE investigationon
	(
		pcontractno tcontract.no%TYPE
	   ,poldstatus  tcontract.status%TYPE := cnullchar
	   ,plog        BOOLEAN := FALSE
	);
	PROCEDURE investigationoff
	(
		pcontractno tcontract.no%TYPE
	   ,poldstatus  tcontract.status%TYPE := cnullchar
	   ,plog        BOOLEAN := FALSE
	);

	PROCEDURE changecontractparam
	(
		pcontractno    IN tcontractparameters.contractno%TYPE
	   ,pparam         IN tcontractparameters.key%TYPE
	   ,pnewvalue      IN tcontractparameters.value%TYPE
	   ,pmaskmode      IN NUMBER := NULL
	   ,pwritelog      IN BOOLEAN := FALSE
	   ,pparamname     IN VARCHAR := NULL
	   ,pvalues        IN contractparams.typevaluearray := contractparams.cemptyvaluearray
	   ,psaveinhistory IN BOOLEAN := FALSE
	   ,punequalonly   IN BOOLEAN := TRUE
	   ,ppan4mask      IN tcard.pan%TYPE := NULL
	   ,powner         IN a4mlog.typeclientid := NULL
	);

	PROCEDURE changecontractparam
	(
		pcontractno    IN tcontractparameters.contractno%TYPE
	   ,pparam         IN tcontractparameters.key%TYPE
	   ,pnewvalue      IN tcontractparameters.value%TYPE
	   ,poldvalue      IN tcontractparameters.value%TYPE
	   ,pmaskmode      IN NUMBER := NULL
	   ,pwritelog      IN BOOLEAN := FALSE
	   ,pparamname     IN VARCHAR := NULL
	   ,pvalues        IN contractparams.typevaluearray := contractparams.cemptyvaluearray
	   ,psaveinhistory IN BOOLEAN := FALSE
	   ,punequalonly   IN BOOLEAN := TRUE
	   ,ppan4mask      IN tcard.pan%TYPE := NULL
	   ,powner         IN a4mlog.typeclientid := NULL
	);

	PROCEDURE changecontractparamacc
	(
		pcontractno    IN tcontractparameters.contractno%TYPE
	   ,pparam         IN tcontractparameters.key%TYPE
	   ,pnewvalue      IN tcontractparameters.value%TYPE
	   ,pmaskmode      IN NUMBER := NULL
	   ,pwritelog      IN BOOLEAN := FALSE
	   ,pparamname     IN VARCHAR := NULL
	   ,pvalues        IN contractparams.typevaluearray := contractparams.cemptyvaluearray
	   ,psaveinhistory IN BOOLEAN := FALSE
	);

	PROCEDURE changepercentid
	(
		pcontractno IN tcontract.no%TYPE
	   ,pparam      IN tcontractparameters.key%TYPE
	   ,pnewvalue   IN tcontractparameters.value%TYPE
	   ,pwritehist  IN BOOLEAN
	   ,pdolog      IN BOOLEAN
	   ,powner      IN a4mlog.typeclientid := NULL
	);

	PROCEDURE changecardsignstat
	(
		ppan     IN tcard.pan%TYPE
	   ,pmbr     IN tcard.mbr%TYPE
	   ,psign    IN tcard.signstat%TYPE
	   ,pstat    tcard.crd_stat%TYPE
	   ,pcomment IN VARCHAR2
	);

	PROCEDURE changecardsignstat
	(
		ppan     IN tcard.pan%TYPE
	   ,pmbr     IN tcard.mbr%TYPE
	   ,psign    IN tcard.signstat%TYPE
	   ,pstat    tcard.crd_stat%TYPE
	   ,pcomment IN VARCHAR2
	   ,poldsign IN tcard.signstat%TYPE
	   ,poldstat tcard.crd_stat%TYPE
	);

	FUNCTION changecontractcardstat
	(
		pcontractno tcontract.no%TYPE
	   ,pfrom       IN tcard.crd_stat%TYPE
	   ,pto         IN tcard.crd_stat%TYPE
	   ,pcomment    IN VARCHAR2
	) RETURN typecardstatchangeinfoarray;
	PROCEDURE changecontractcardstat
	(
		pcontractno tcontract.no%TYPE
	   ,pfrom       IN tcard.crd_stat%TYPE
	   ,pto         IN tcard.crd_stat%TYPE
	   ,pcomment    IN VARCHAR2
	);

	FUNCTION changecontractcardsign
	(
		pcontractno tcontract.no%TYPE
	   ,pfrom       IN tcard.signstat%TYPE
	   ,pto         IN tcard.signstat%TYPE
	   ,pcomment    IN VARCHAR2
	) RETURN typecardsignchangeinfoarray;
	PROCEDURE changecontractcardsign
	(
		pcontractno tcontract.no%TYPE
	   ,pfrom       IN tcard.signstat%TYPE
	   ,pto         IN tcard.signstat%TYPE
	   ,pcomment    IN VARCHAR2
	);

	PROCEDURE changecparamvalue
	(
		pcontractno IN tcontractparameters.contractno%TYPE
	   ,pparam      IN tcontractparameters.key%TYPE
	   ,pnewvalue   IN tcontractparameters.value%TYPE
	   ,poldvalue   IN tcontractparameters.value%TYPE
	   ,pmaskmode   IN NUMBER := NULL
	);

	PROCEDURE setlastadjdate
	(
		pcontractno IN VARCHAR2
	   ,pdate       IN DATE
	);

	PROCEDURE setentryaux(pdocno IN tdocument.docno%TYPE);

	PROCEDURE changedebitreserve
	(
		paccountno IN taccount.accountno%TYPE
	   ,pvalue     IN NUMBER
	   ,pdelta     IN BOOLEAN := TRUE
	);
	PROCEDURE changecreditreserve
	(
		paccountno IN taccount.accountno%TYPE
	   ,pvalue     IN NUMBER
	   ,pdelta     IN BOOLEAN := TRUE
	);

	PROCEDURE createcoverage
	(
		pcontractno IN VARCHAR
	   ,pclientid   IN NUMBER
	   ,puamp       IN VARCHAR
	);
	PROCEDURE setprolongation(pidprol tcontractprolongation.idprol%TYPE);

	PROCEDURE setaccountstat
	(
		paccountno taccount.accountno%TYPE
	   ,pstat      CHAR
	   ,pset       BOOLEAN := TRUE
	);

	PROCEDURE closeaccount(paccountno taccount.accountno%TYPE);

	PROCEDURE ucloseaccount;

	PROCEDURE openaccount(paccountno taccount.accountno%TYPE);

	PROCEDURE lockcards
	(
		pcontractno tcontract.no%TYPE
	   ,pstatuslock tcard.crd_stat%TYPE
	   ,pundo       BOOLEAN := FALSE
	   ,pcomment    VARCHAR2 := NULL
	);
	PROCEDURE ulockcards
	(
		pcontractno tcontract.no%TYPE
	   ,pstatuslock tcard.crd_stat%TYPE
	   ,pundo       BOOLEAN := FALSE
	   ,pcomment    VARCHAR2 := NULL
	);

	PROCEDURE linkcard2account
	(
		ppan       IN tcard.pan%TYPE
	   ,pmbr       IN tcard.mbr%TYPE
	   ,paccountno IN taccount.accountno%TYPE
	   ,pstatus    IN tcontractcardacc.accstatus%TYPE
	);

	PROCEDURE changecontracttype
	(
		pcontractno      tcontract.no%TYPE
	   ,poldcontracttype tcontract.type%TYPE
	   ,pnewcontracttype tcontract.type%TYPE
	);

	PROCEDURE changeitemcodeaccount
	(
		paccount     apitypes.typeaccountrecord
	   ,polditemcode tcontractitem.itemcode%TYPE
	   ,pnewitemcode tcontractitem.itemcode%TYPE
	);

	PROCEDURE changeitemcodecard
	(
		pcard        apitypes.typeaccount2cardrecord
	   ,polditemcode tcontractcarditem.itemcode%TYPE
	   ,pnewitemcode tcontractcarditem.itemcode%TYPE
	);

	PROCEDURE savecontractuserattribute
	(
		pcontractno    IN tcontract.no%TYPE
	   ,pfieldname     IN VARCHAR2
	   ,pfieldtype     IN PLS_INTEGER
	   ,pvalue         IN VARCHAR2
	   ,pwriterollback IN BOOLEAN := TRUE
	);
	PROCEDURE saveaccountuserattribute
	(
		paccountno     IN taccount.accountno%TYPE
	   ,pfieldname     IN VARCHAR2
	   ,pfieldtype     IN PLS_INTEGER
	   ,pvalue         IN VARCHAR2
	   ,pwriterollback IN BOOLEAN := TRUE
	);
	PROCEDURE saveclientuserattribute
	(
		pclientid      IN tclient.idclient%TYPE
	   ,pfieldname     IN VARCHAR2
	   ,pfieldtype     IN PLS_INTEGER
	   ,pvalue         IN VARCHAR2
	   ,pwriterollback IN BOOLEAN := TRUE
	);

	PROCEDURE addcontractrestruct
	(
		pcontractno     tcontract.no%TYPE
	   ,prestructdate   DATE
	   ,preasonident    tcontractrestructreason.ident%TYPE
	   ,pconditionident tcontractrestructcondition.ident%TYPE
	   ,pcreatetype     PLS_INTEGER
	   ,preasonforbust  BOOLEAN
	);
	PROCEDURE addcontractbust(prec tcontractbust%ROWTYPE);
	PROCEDURE setbustcriteriadateend
	(
		pbustid  IN tcontractbust.bustid%TYPE
	   ,pdateend IN tcontractbust.dateend%TYPE
	);
	PROCEDURE setbustcriteriadeleted
	(
		pbustid    IN tcontractbust.bustid%TYPE
	   ,pdelreason IN tcontractbust.delreason%TYPE
	);

--PROCEDURE setexpressionlog(pexprid texpressionlog.id%TYPE);

END;
/
CREATE OR REPLACE PACKAGE BODY custom_contractrbstd IS

	cpackage_name CONSTANT VARCHAR2(80) := 'ContractRbStd';
	cbodyrevision CONSTANT VARCHAR2(100) := '$Rev: 44809 $';
	csay_level    CONSTANT NUMBER := 3;

	cnulldate CONSTANT DATE := to_date('0001-01-01', 'YYYY-MM-DD');

	crl_entry             CONSTANT contractrb.tlabel := contractrb.crs_std + 1;
	crl_close_contract    CONSTANT contractrb.tlabel := contractrb.crs_std + 2;
	crl_violate_on        CONSTANT contractrb.tlabel := contractrb.crs_std + 3;
	crl_violate_off       CONSTANT contractrb.tlabel := contractrb.crs_std + 4;
	crl_card_lock         CONSTANT contractrb.tlabel := contractrb.crs_std + 5;
	crl_card_unlock       CONSTANT contractrb.tlabel := contractrb.crs_std + 6;
	crl_credit_start      CONSTANT contractrb.tlabel := contractrb.crs_std + 7;
	crl_credit_update     CONSTANT contractrb.tlabel := contractrb.crs_std + 8;
	crl_credit_end        CONSTANT contractrb.tlabel := contractrb.crs_std + 9;
	crl_change_group      CONSTANT contractrb.tlabel := contractrb.crs_std + 10;
	crl_set_arc_date      CONSTANT contractrb.tlabel := contractrb.crs_std + 11;
	crl_chng_ctrl_date    CONSTANT contractrb.tlabel := contractrb.crs_std + 12;
	crl_chng_acct_stat    CONSTANT contractrb.tlabel := contractrb.crs_std + 13;
	crl_chng_group_risk   CONSTANT contractrb.tlabel := contractrb.crs_std + 14;
	crl_chng_cparam_value CONSTANT contractrb.tlabel := contractrb.crs_std + 15;
	crl_account_created   CONSTANT contractrb.tlabel := contractrb.crs_std + 16;
	crl_suspend_on        CONSTANT contractrb.tlabel := contractrb.crs_std + 17;
	crl_suspend_off       CONSTANT contractrb.tlabel := contractrb.crs_std + 18;
	crl_change_con_param  CONSTANT contractrb.tlabel := contractrb.crs_std + 19;
	crl_card_change       CONSTANT contractrb.tlabel := contractrb.crs_std + 20;
	crl_set_last_adj_date CONSTANT contractrb.tlabel := contractrb.crs_std + 21;
	crl_entryaux          CONSTANT contractrb.tlabel := contractrb.crs_std + 22;
	crl_debit_reserve     CONSTANT contractrb.tlabel := contractrb.crs_std + 23;
	crl_investigation_on  CONSTANT contractrb.tlabel := contractrb.crs_std + 24;
	crl_investigation_off CONSTANT contractrb.tlabel := contractrb.crs_std + 25;
	crl_coverage          CONSTANT contractrb.tlabel := loancoverage.crl_coverage;
	crl_prolongation      CONSTANT contractrb.tlabel := contractrb.crs_std + 27;
	crl_change_percentid  CONSTANT contractrb.tlabel := contractrb.crs_std + 28;
	crl_set_account_stat  CONSTANT contractrb.tlabel := contractrb.crs_std + 29;
	crl_credit_reserve    CONSTANT contractrb.tlabel := contractrb.crs_std + 30;
	crl_close_account     CONSTANT contractrb.tlabel := contractrb.crs_std + 31;
	crl_open_account      CONSTANT contractrb.tlabel := contractrb.crs_std + 32;
	crl_link_card2account CONSTANT contractrb.tlabel := contractrb.crs_std + 33;

	crl_change_type_contract    CONSTANT contractrb.tlabel := contractrb.crs_std + 34;
	crl_change_itemcode_account CONSTANT contractrb.tlabel := contractrb.crs_std + 35;
	crl_change_itemcode_card    CONSTANT contractrb.tlabel := contractrb.crs_std + 36;

	crl_change_contr_attribute   CONSTANT contractrb.tlabel := contractrb.crs_std + 37;
	crl_change_account_attribute CONSTANT contractrb.tlabel := contractrb.crs_std + 38;
	crl_change_client_attribute  CONSTANT contractrb.tlabel := contractrb.crs_std + 39;

	crl_add_contractrestruct     CONSTANT contractrb.tlabel := contractrb.crs_std + 40;
	crl_add_contractbust         CONSTANT contractrb.tlabel := contractrb.crs_std + 41;
	crl_set_contractbust_dateend CONSTANT contractrb.tlabel := contractrb.crs_std + 42;
	crl_set_contractbust_deleted CONSTANT contractrb.tlabel := contractrb.crs_std + 43;
	crl_expression_log           CONSTANT contractrb.tlabel := contractrb.crs_std + 44;

	crlp_idx       CONSTANT VARCHAR2(20) := 'IDX';
	crlp_value     CONSTANT VARCHAR2(20) := 'V';
	crlp_account   CONSTANT VARCHAR2(20) := 'AC';
	crlp_client    CONSTANT VARCHAR2(20) := 'CI';
	crlp_fieldtype CONSTANT VARCHAR2(20) := 'FT';

	crlp_clerkcode   CONSTANT VARCHAR2(20) := 'CC';
	crlp_sysdate     CONSTANT VARCHAR2(20) := 'SD';
	crlp_datebegin   CONSTANT VARCHAR2(20) := 'DB';
	crlp_dateend     CONSTANT VARCHAR2(20) := 'DE';
	crlp_description CONSTANT VARCHAR2(20) := 'DS';

	TYPE typedesc IS TABLE OF VARCHAR2(80);

	cstdlbldesc CONSTANT typedesc := typedesc('Entry'
											 ,'Close contract'
											 ,'Violation set'
											 ,'Violation removed'
											 ,'Card blocked'
											 ,'Card unblocked'
											 ,'Credit record created'
											 ,'Credit record changed (validity start date)'
											 ,'Credit record closed'
											 ,'Risk group changed'
											 ,'Contract archiving date is set'
											 ,'Contract control dates changed'
											 ,'Account status in PC changed'
											 ,'Risk group changed'
											 ,'Contract parameter value changed'
											 ,'Dynamic account created'
											 ,'"Suspended" mark is set'
											 ,'"Suspended" mark is removed'
											 ,'Contract parameter value changed'
											 ,'Card state/status changed'
											 ,'Last adjustment date is set'
											 ,'Additional entry'
											 ,'Debit hold changed'
											 ,'"Under investigation" status is set'
											 ,'"Under investigation" status is removed'
											 ,'Collateral created'
											 ,'Prolongation'
											 ,'Interest rate ID changed'
											 ,'Account status changed'
											 ,'Credit on-hold changed'
											 ,'Account closed'
											 ,'Open account'
											 ,'Card-to-account link created'
											 ,
											  
											  'Contract type is changed'
											 ,'Account ItemCode is changed'
											 ,'Card ItemCode is changed'
											 ,'User attribute of contract is changed'
											 ,'User attribute of account is changed'
											 ,'User attribute of card is changed'
											 ,'Restructuring is added'
											 ,'Default is added'
											 ,'End date of default is set'
											 ,'Default is marked as deleted'
											 ,'Conditional expressions logged');

	PROCEDURE uclosecontract(pcontractno tcontract.no%TYPE);
	PROCEDURE usetentry(pcontractno tcontract.no%TYPE);
	PROCEDURE uviolateon(pcontractno tcontract.no%TYPE);
	PROCEDURE uviolateoff(pcontractno tcontract.no%TYPE);
	PROCEDURE ucreditstart(pcontractno tcontract.no%TYPE);
	PROCEDURE ucreditchange(pcontractno tcontract.no%TYPE);
	PROCEDURE ucreditend(pcontractno tcontract.no%TYPE);
	PROCEDURE usetarcdate(pcontractno tcontract.no%TYPE);
	PROCEDURE usetarcdatebyctrl(pcontractno tcontract.no%TYPE);
	PROCEDURE usetaccacct_stat(pcontractno tcontract.no%TYPE);
	PROCEDURE uchangegrouprisk(pcontractno tcontract.no%TYPE);
	PROCEDURE uchangecparamvalue(pcontractno IN tcontract.no%TYPE);
	PROCEDURE ususpendon(pcontractno tcontract.no%TYPE);
	PROCEDURE ususpendoff(pcontractno tcontract.no%TYPE);
	PROCEDURE ucreateaccountbycode(pcontractno IN tcontract.no%TYPE);
	PROCEDURE uchangecontractparam(pcontractno IN tcontract.no%TYPE);
	PROCEDURE uchangecardsignstat(pcontractno IN tcontract.no%TYPE);
	PROCEDURE usetlastadjdate(pcontractno IN VARCHAR2);
	PROCEDURE usetentryaux(pcontractno tcontract.no%TYPE);
	PROCEDURE uchangedebitreserve;
	PROCEDURE uchangecreditreserve;
	PROCEDURE uinvestigationon(pcontractno tcontract.no%TYPE);
	PROCEDURE uinvestigationoff(pcontractno tcontract.no%TYPE);

	PROCEDURE usetprolongation;
	PROCEDURE uchangepercentid(pcontractno IN tcontract.no%TYPE);
	PROCEDURE usetaccountstat(pcontractno tcontract.no%TYPE);
	PROCEDURE uopenaccount;
	PROCEDURE ulinkcard2account;

	PROCEDURE uchangecontracttype;
	PROCEDURE uchangeitemcodeaccount;
	PROCEDURE uchangeitemcodecard;
	--PROCEDURE usetexpressionlog;

	FUNCTION getversion RETURN VARCHAR2 IS
	BEGIN
		RETURN service.formatpackageversion(cpackage_name, crevision, cbodyrevision);
	END;

	FUNCTION getcontractno
	(
		pkey        VARCHAR2
	   ,pcontractno tcontract.no%TYPE
	) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetContractNo';
	BEGIN
		RETURN nvl(contractrb.getcvalue(pkey), pcontractno);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getcontractno;

	PROCEDURE savecontractuserattribute
	(
		pcontractno    IN tcontract.no%TYPE
	   ,pfieldname     IN VARCHAR2
	   ,pfieldtype     IN PLS_INTEGER
	   ,pvalue         IN VARCHAR2
	   ,pwriterollback IN BOOLEAN := TRUE
	) IS
		cmethodname CONSTANT VARCHAR2(80) := cpackage_name || '.SaveContractUserAttribute';
		voldvalue VARCHAR2(4000);
		vdata     apitypes.typeuserproplist;
	BEGIN
		t.enter(cmethodname
			   ,'pContractNo=' || pcontractno || ', pFieldName=' || pfieldname || ' pValue = ' ||
				pvalue);
		CASE pfieldtype
			WHEN types.cstring THEN
				voldvalue := contract.getuserattributerecord(pcontractno, pfieldname).valuestr;
			WHEN types.cnumber THEN
				voldvalue := to_char(contract.getuserattributerecord(pcontractno, pfieldname)
									 .valuenum);
			WHEN types.cdate THEN
				voldvalue := to_char(contract.getuserattributerecord(pcontractno, pfieldname)
									 .valuedate
									,contractparams.cparam_date_format);
			ELSE
				error.raiseerror('User attribute type [' || pfieldtype || '] not supported');
		END CASE;
		t.var('vOldValue', voldvalue);
		IF voldvalue = pvalue
		THEN
			t.note(NULL, 'Already Saved Attribute');
		ELSE
			t.note(NULL, 'Save Attribute ' || pfieldname);
			vdata(1).id := pfieldname;
			CASE pfieldtype
				WHEN types.cstring THEN
					vdata(1).fieldtype := types.cstring;
					vdata(1).valuestr := pvalue;
				WHEN types.cnumber THEN
					vdata(1).fieldtype := types.cnumber;
					vdata(1).valuenum := to_number(pvalue);
				WHEN types.cdate THEN
					vdata(1).fieldtype := types.cdate;
					vdata(1).valuedate := to_date(pvalue, contractparams.cparam_date_format);
				ELSE
					error.raiseerror('User attribute type [' || pfieldtype || '] not supported');
			END CASE;
		
			contract.saveuserattributeslist(pcontractno, vdata);
		
			IF nvl(pwriterollback, TRUE)
			THEN
				contractrb.setlabel(crl_change_contr_attribute);
				contractrb.setcvalue(crlp_idx, pfieldname);
				contractrb.setcvalue(crlp_value, voldvalue);
				contractrb.setcvalue(crlp_fieldtype, pfieldtype);
			END IF;
		END IF;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE saveaccountuserattribute
	(
		paccountno     IN taccount.accountno%TYPE
	   ,pfieldname     IN VARCHAR2
	   ,pfieldtype     IN PLS_INTEGER
	   ,pvalue         IN VARCHAR2
	   ,pwriterollback IN BOOLEAN := TRUE
	) IS
		cmethodname CONSTANT VARCHAR2(80) := cpackage_name || '.SaveAccountUserAttribute';
		voldvalue VARCHAR2(4000);
		vdata     apitypes.typeuserproplist;
	BEGIN
		t.enter(cmethodname
			   ,'pAccountNo=' || paccountno || ', pFieldName=' || pfieldname || ', pFieldType=' ||
				pfieldtype || ', pValue = ' || pvalue);
		CASE pfieldtype
			WHEN types.cstring THEN
				voldvalue := account.getuserattributerecord(paccountno, pfieldname).valuestr;
			WHEN types.cnumber THEN
				voldvalue := to_char(account.getuserattributerecord(paccountno, pfieldname).valuenum);
			WHEN types.cdate THEN
				voldvalue := to_char(account.getuserattributerecord(paccountno, pfieldname)
									 .valuedate
									,contractparams.cparam_date_format);
			ELSE
				error.raiseerror('User attribute type [' || pfieldtype || '] not supported');
		END CASE;
		t.var('vOldValue', voldvalue);
		IF voldvalue = pvalue
		THEN
			t.note(NULL, 'Already Saved Attribute');
		ELSE
			t.note(NULL, 'Save Attribute ' || pfieldname);
			vdata(1).id := pfieldname;
			CASE pfieldtype
				WHEN types.cstring THEN
					vdata(1).fieldtype := types.cstring;
					vdata(1).valuestr := pvalue;
				WHEN types.cnumber THEN
					vdata(1).fieldtype := types.cnumber;
					vdata(1).valuenum := to_number(pvalue);
				WHEN types.cdate THEN
					vdata(1).fieldtype := types.cdate;
					vdata(1).valuedate := to_date(pvalue, contractparams.cparam_date_format);
				ELSE
					error.raiseerror('User attribute type [' || pfieldtype || '] not supported');
			END CASE;
		
			account.saveuserattributeslist(paccountno, vdata);
		
			IF nvl(pwriterollback, TRUE)
			THEN
				contractrb.setlabel(crl_change_account_attribute);
				contractrb.setcvalue(crlp_account, paccountno);
				contractrb.setcvalue(crlp_idx, pfieldname);
				contractrb.setcvalue(crlp_value, voldvalue);
				contractrb.setcvalue(crlp_fieldtype, pfieldtype);
			END IF;
		END IF;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE saveclientuserattribute
	(
		pclientid      IN tclient.idclient%TYPE
	   ,pfieldname     IN VARCHAR2
	   ,pfieldtype     IN PLS_INTEGER
	   ,pvalue         IN VARCHAR2
	   ,pwriterollback IN BOOLEAN := TRUE
	) IS
		cmethodname CONSTANT VARCHAR2(80) := cpackage_name || '.SaveClientUserAttribute';
		voldvalue VARCHAR2(4000);
		vdata     apitypes.typeuserproplist;
	BEGIN
		t.enter(cmethodname
			   ,'pClientId=' || pclientid || ', pFieldName=' || pfieldname || ' pValue = ' ||
				pvalue);
		CASE pfieldtype
			WHEN types.cstring THEN
				voldvalue := client.getuserattributerecord(pclientid, pfieldname).valuestr;
			WHEN types.cnumber THEN
				voldvalue := to_char(client.getuserattributerecord(pclientid, pfieldname).valuenum);
			WHEN types.cdate THEN
				voldvalue := to_char(client.getuserattributerecord(pclientid, pfieldname).valuedate
									,contractparams.cparam_date_format);
			ELSE
				error.raiseerror('User attribute type [' || pfieldtype || '] not supported');
		END CASE;
		t.var('vOldValue', voldvalue);
		IF voldvalue = pvalue
		THEN
			t.note(NULL, 'Already Saved Attribute');
		ELSE
			t.note(NULL, 'Save Attribute ' || pfieldname);
			vdata(1).id := pfieldname;
			CASE pfieldtype
				WHEN types.cstring THEN
					vdata(1).fieldtype := types.cstring;
					vdata(1).valuestr := pvalue;
				WHEN types.cnumber THEN
					vdata(1).fieldtype := types.cnumber;
					vdata(1).valuenum := to_number(pvalue);
				WHEN types.cdate THEN
					vdata(1).fieldtype := types.cdate;
					vdata(1).valuedate := to_date(pvalue, contractparams.cparam_date_format);
				ELSE
					error.raiseerror('User attribute type [' || pfieldtype || '] not supported');
			END CASE;
			client.saveuserattributeslist(pclientid, vdata);
		
			IF nvl(pwriterollback, TRUE)
			THEN
				contractrb.setlabel(crl_change_client_attribute);
				contractrb.setcvalue(crlp_client, pclientid);
				contractrb.setcvalue(crlp_idx, pfieldname);
				contractrb.setcvalue(crlp_value, voldvalue);
				contractrb.setcvalue(crlp_fieldtype, pfieldtype);
			END IF;
		END IF;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE addcontractrestruct
	(
		pcontractno     tcontract.no%TYPE
	   ,prestructdate   DATE
	   ,preasonident    tcontractrestructreason.ident%TYPE
	   ,pconditionident tcontractrestructcondition.ident%TYPE
	   ,pcreatetype     PLS_INTEGER
	   ,preasonforbust  BOOLEAN
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.AddContractRestruct';
		vid NUMBER;
	BEGIN
		vid := contractbust.addcontractrestruct(pcontractno
											   ,prestructdate
											   ,preasonident
											   ,pconditionident
											   ,pcreatetype
											   ,preasonforbust);
	
		contractrb.setlabel(crl_add_contractrestruct);
		contractrb.setnvalue(crlp_idx, vid);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END addcontractrestruct;

	PROCEDURE uaddcontractrestruct IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.UAddContractRestruct';
		vid NUMBER;
	BEGIN
		t.enter(cmethod_name);
		vid := contractrb.getnvalue(crlp_idx);
	
		IF vid IS NOT NULL
		THEN
			contractbust.deleterestruct(vid);
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uaddcontractrestruct;

	PROCEDURE addcontractbust(prec tcontractbust%ROWTYPE) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.AddContractBust';
		vrec tcontractbust%ROWTYPE;
	BEGIN
		t.enter(cmethod_name
			   ,'pRec.ObjectType=' || prec.objecttype || ', pRec.ClientId=' || prec.clientid ||
				', pRec.ContractNo=' || prec.contractno);
		vrec := prec;
		contractbust.addbustcriteria(vrec);
		t.var('vRec.Bustid', vrec.bustid);
		contractrb.setlabel(crl_add_contractbust);
		contractrb.setnvalue(crlp_idx, vrec.bustid);
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE uaddcontractbust IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.UAddContractBust';
		vid NUMBER;
	BEGIN
		t.enter(cmethod_name);
		vid := contractrb.getnvalue(crlp_idx);
	
		IF vid IS NOT NULL
		THEN
			contractbust.deletebustcriteria(vid);
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setbustcriteriadateend
	(
		pbustid  IN tcontractbust.bustid%TYPE
	   ,pdateend IN tcontractbust.dateend%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.SetBustCriteriaDateEnd';
		vrec tcontractbust%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, 'pBustId=' || pbustid || ', pDateEnd=' || pdateend);
		vrec := contractbust.getbustcriteriabyid(pbustid);
	
		contractbust.setbustcriteriadateend(pbustid, pdateend);
	
		contractrb.setlabel(crl_set_contractbust_dateend);
		contractrb.setnvalue(crlp_idx, vrec.bustid);
		contractrb.setnvalue(crlp_clerkcode, vrec.updateclerkcode);
		contractrb.setdvalue(crlp_sysdate, vrec.updatesysdate);
		contractrb.setdvalue(crlp_dateend, vrec.dateend);
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE usetbustcriteriadateend IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.USetBustCriteriaDateEnd';
		vrec tcontractbust%ROWTYPE;
	BEGIN
		t.enter(cmethod_name);
		vrec.bustid          := contractrb.getnvalue(crlp_idx);
		vrec.updateclerkcode := contractrb.getnvalue(crlp_clerkcode);
		vrec.updatesysdate   := contractrb.getdvalue(crlp_sysdate);
		vrec.dateend         := contractrb.getdvalue(crlp_dateend);
	
		IF vrec.bustid IS NOT NULL
		THEN
			contractbust.setbustcriteriadateend(vrec.bustid
											   ,vrec.dateend
											   ,vrec.updateclerkcode
											   ,vrec.updatesysdate);
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setbustcriteriadeleted
	(
		pbustid    IN tcontractbust.bustid%TYPE
	   ,pdelreason IN tcontractbust.delreason%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.SetBustCriteriaDeleted';
		vrec tcontractbust%ROWTYPE;
	BEGIN
		t.enter(cmethod_name, 'pBustId=' || pbustid || ', pDelReason=' || pdelreason);
		vrec := contractbust.getbustcriteriabyid(pbustid);
	
		contractbust.setbustcriteriadeleted(pbustid, pdelreason);
	
		contractrb.setlabel(crl_set_contractbust_deleted);
		contractrb.setnvalue(crlp_idx, vrec.bustid);
		contractrb.setnvalue(crlp_clerkcode, vrec.updateclerkcode);
		contractrb.setdvalue(crlp_sysdate, vrec.updatesysdate);
		contractrb.setcvalue(crlp_description, vrec.delreason);
		contractrb.setnvalue(crlp_value, vrec.deleted);
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE usetbustcriteriadeleted IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.USetBustCriteriaDeleted';
		vrec tcontractbust%ROWTYPE;
	BEGIN
		t.enter(cmethod_name);
		vrec.bustid          := contractrb.getnvalue(crlp_idx);
		vrec.updateclerkcode := contractrb.getnvalue(crlp_clerkcode);
		vrec.updatesysdate   := contractrb.getdvalue(crlp_sysdate);
		vrec.delreason       := contractrb.getcvalue(crlp_description);
		vrec.deleted         := contractrb.getnvalue(crlp_value);
	
		IF vrec.bustid IS NOT NULL
		THEN
			contractbust.setbustcriteriadeleted(vrec.bustid
											   ,vrec.dateend
											   ,vrec.updateclerkcode
											   ,vrec.updatesysdate
											   ,vrec.deleted);
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE undolabel
	(
		pcontractno tcontract.no%TYPE
	   ,plabel      contractrb.tlabel
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UndoLabel';
	BEGIN
		s.say(cmethod_name || ': for contract ' || pcontractno || ' label ' || plabel, csay_level);
		CASE plabel
			WHEN crl_entry THEN
				usetentry(pcontractno);
			WHEN crl_close_contract THEN
				uclosecontract(pcontractno);
			WHEN crl_violate_on THEN
				uviolateon(pcontractno);
			WHEN crl_violate_off THEN
				uviolateoff(pcontractno);
			WHEN crl_credit_start THEN
				ucreditstart(pcontractno);
			WHEN crl_credit_update THEN
				ucreditchange(pcontractno);
			WHEN crl_credit_end THEN
				ucreditend(pcontractno);
			WHEN crl_set_arc_date THEN
				usetarcdate(pcontractno);
			WHEN crl_chng_ctrl_date THEN
				usetarcdatebyctrl(pcontractno);
			WHEN crl_chng_acct_stat THEN
				usetaccacct_stat(pcontractno);
			WHEN crl_chng_group_risk THEN
				uchangegrouprisk(pcontractno);
			WHEN crl_chng_cparam_value THEN
				uchangecparamvalue(pcontractno);
			WHEN crl_account_created THEN
				ucreateaccountbycode(pcontractno);
			WHEN crl_suspend_on THEN
				ususpendon(pcontractno);
			WHEN crl_suspend_off THEN
				ususpendoff(pcontractno);
			WHEN crl_change_con_param THEN
				uchangecontractparam(pcontractno);
			WHEN crl_card_change THEN
				uchangecardsignstat(pcontractno);
			WHEN crl_set_last_adj_date THEN
				usetlastadjdate(pcontractno);
			WHEN crl_entryaux THEN
				usetentryaux(pcontractno);
			WHEN crl_debit_reserve THEN
				uchangedebitreserve();
			WHEN crl_investigation_on THEN
				uinvestigationon(pcontractno);
			WHEN crl_investigation_off THEN
				uinvestigationoff(pcontractno);
			
			WHEN crl_coverage THEN
				loancoverage.undolabel(pcontractno, plabel);
			WHEN crl_prolongation THEN
				usetprolongation;
			WHEN crl_change_percentid THEN
				uchangepercentid(pcontractno);
			WHEN crl_set_account_stat THEN
				usetaccountstat(pcontractno);
			WHEN crl_credit_reserve THEN
				uchangecreditreserve();
			
			WHEN crl_card_lock THEN
				ulockcards(pcontractno, contractrb.getcvalue('STAT'), TRUE);
			WHEN crl_card_unlock THEN
				lockcards(pcontractno, contractrb.getcvalue('STAT'), TRUE);
			WHEN crl_close_account THEN
				ucloseaccount();
			WHEN crl_open_account THEN
				uopenaccount();
			WHEN crl_link_card2account THEN
				ulinkcard2account();
			
			WHEN crl_change_type_contract THEN
				uchangecontracttype;
			WHEN crl_change_itemcode_account THEN
				uchangeitemcodeaccount;
			WHEN crl_change_itemcode_card THEN
				uchangeitemcodecard;
			
			WHEN crl_change_contr_attribute THEN
				savecontractuserattribute(pcontractno
										 ,contractrb.getcvalue(crlp_idx)
										 ,contractrb.getcvalue(crlp_fieldtype)
										 ,contractrb.getcvalue(crlp_value)
										 ,pwriterollback => FALSE);
			WHEN crl_change_account_attribute THEN
				saveaccountuserattribute(contractrb.getcvalue(crlp_account)
										,contractrb.getcvalue(crlp_idx)
										,contractrb.getcvalue(crlp_fieldtype)
										,contractrb.getcvalue(crlp_value)
										,pwriterollback => FALSE);
			WHEN crl_change_client_attribute THEN
				saveclientuserattribute(contractrb.getcvalue(crlp_client)
									   ,contractrb.getcvalue(crlp_idx)
									   ,contractrb.getcvalue(crlp_fieldtype)
									   ,contractrb.getcvalue(crlp_value)
									   ,pwriterollback => FALSE);
			
			WHEN crl_add_contractrestruct THEN
				uaddcontractrestruct();
			WHEN crl_add_contractbust THEN
				uaddcontractbust();
			WHEN crl_set_contractbust_dateend THEN
				usetbustcriteriadateend();
			WHEN crl_set_contractbust_deleted THEN
				usetbustcriteriadeleted();
			
			WHEN crl_expression_log THEN
				-- usetexpressionlog();
				NULL;
			ELSE
				error.raiseerror('Internal error: unidentified label in standard range - ' ||
								 plabel);
		END CASE;
		s.say(cmethod_name || ': leave', csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END undolabel;

	FUNCTION getstdlbldesc(plabel contractrb.tlabel) RETURN VARCHAR2 IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetStdLblDesc';
	BEGIN
		RETURN cstdlbldesc(plabel - contractrb.crs_std);
	EXCEPTION
		WHEN OTHERS THEN
			error.saveraise(cmethod_name
						   ,error.errorconst
						   ,'Label not described <' || plabel || '>');
	END getstdlbldesc;

	FUNCTION getdocnofromrollback(prollback IN contractrb.trollbackdata) RETURN NUMBER IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.GetDocNoFromRollback';
		vtemp   contractrb.trollbackdata;
		vresult NUMBER;
	BEGIN
		t.enter(cmethod_name, prollback);
		vtemp   := contractrb.initrbdata(prollback);
		vresult := contractrb.getnvalue(crl_entry, 'DN');
		t.leave(cmethod_name, prollback);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END getdocnofromrollback;

	PROCEDURE setcontractno
	(
		pkey        VARCHAR2
	   ,pcontractno tcontract.no%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SetContractNo';
	BEGIN
	
		contractrb.setcvalue(pkey, pcontractno);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setcontractno;

	PROCEDURE setentry
	(
		pdocno tdocument.docno%TYPE
	   ,pcheck NUMBER := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SetEntry';
	BEGIN
		IF pdocno IS NOT NULL
		THEN
			contractrb.setlabel(crl_entry);
			contractrb.setnvalue('DN', pdocno);
			IF nvl(pcheck, entry.flnocheck) <> entry.flnocheck
			THEN
				contractrb.setnvalue('CK', pcheck);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setentry;

	PROCEDURE usetentry(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.USetEntry';
		vcheck NUMBER;
	
	BEGIN
	
		vcheck := nvl(contractrb.getnvalue('CK'), entry.flnocheck);
	
		contracttools.entryundo(contractrb.getnvalue('DN'), vcheck);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END usetentry;

	PROCEDURE violateon
	(
		pcontractno tcontract.no%TYPE
	   ,poldstatus  tcontract.status%TYPE := cnullchar
	   ,plog        BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.ViolateOn';
		voldstatus tcontract.status%TYPE := poldstatus;
		vhistid    NUMBER;
		verrcode   NUMBER;
	BEGIN
		IF voldstatus = cnullchar
		THEN
			voldstatus := contract.getstatus(pcontractno);
		END IF;
	
		IF NOT contract.checkstatus(voldstatus, contract.stat_violate)
		THEN
			IF plog
			THEN
				contract.setstatus(pcontractno, contract.stat_violate, TRUE, vhistid, FALSE);
			ELSE
				verrcode := contract.setstatus(pcontractno, contract.stat_violate, TRUE);
				IF verrcode <> 0
				THEN
					error.raiseerror(verrcode);
				END IF;
			END IF;
			contracttypeschema.fviolationon := TRUE;
		
			contractrb.setlabel(crl_violate_on);
			setcontractno('CN', pcontractno);
			IF plog
			THEN
				contractrb.setnvalue('ID', vhistid);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END violateon;

	PROCEDURE uviolateon(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UViolateOn';
		vhistid  NUMBER;
		verrcode NUMBER;
	BEGIN
		IF contractrb.getnvalue('ID', vhistid)
		THEN
			contract.setstatus(getcontractno('CN', pcontractno)
							  ,contract.stat_violate
							  ,FALSE
							  ,vhistid
							  ,TRUE);
		ELSE
			verrcode := contract.setstatus(getcontractno('CN', pcontractno)
										  ,contract.stat_violate
										  ,FALSE);
			IF verrcode <> 0
			THEN
				error.raiseerror(verrcode);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uviolateon;

	PROCEDURE violateoff
	(
		pcontractno tcontract.no%TYPE
	   ,poldstatus  tcontract.status%TYPE := cnullchar
	   ,plog        BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.ViolateOff';
		voldstatus tcontract.status%TYPE := poldstatus;
		vhistid    NUMBER;
		verrcode   NUMBER;
	BEGIN
		IF voldstatus = cnullchar
		THEN
			voldstatus := contract.getstatus(pcontractno);
		END IF;
	
		IF contract.checkstatus(voldstatus, contract.stat_violate)
		THEN
			IF plog
			THEN
				contract.setstatus(pcontractno, contract.stat_violate, FALSE, vhistid, FALSE);
			ELSE
				verrcode := contract.setstatus(pcontractno, contract.stat_violate, FALSE);
				IF verrcode <> 0
				THEN
					error.raiseerror(verrcode);
				END IF;
			END IF;
			contracttypeschema.fviolationoff := TRUE;
		
			contractrb.setlabel(crl_violate_off);
			setcontractno('CN', pcontractno);
			IF plog
			THEN
				contractrb.setnvalue('ID', vhistid);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END violateoff;

	PROCEDURE uviolateoff(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UViolateOff';
		vhistid  NUMBER;
		verrcode NUMBER;
	BEGIN
		IF contractrb.getnvalue('ID', vhistid)
		THEN
			contract.setstatus(getcontractno('CN', pcontractno)
							  ,contract.stat_violate
							  ,TRUE
							  ,vhistid
							  ,TRUE);
		ELSE
			verrcode := contract.setstatus(getcontractno('CN', pcontractno)
										  ,contract.stat_violate
										  ,TRUE);
			IF verrcode <> 0
			THEN
				error.raiseerror(verrcode);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uviolateoff;

	PROCEDURE creditstart
	(
		paccountno taccount.accountno%TYPE
	   ,pdate      DATE := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.CreditStart';
		vdate DATE := pdate;
	BEGIN
		IF vdate IS NULL
		THEN
			vdate := seance.getoperdate();
		END IF;
	
		contracttools.createstamprow(paccountno, vdate);
		IF SQL%ROWCOUNT > 0
		THEN
			contractrb.setlabel(crl_credit_start);
			contractrb.setcvalue('AC', paccountno);
			contractrb.setdvalue('DC', vdate);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END creditstart;

	PROCEDURE ucreditstart(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UCreditStart';
	BEGIN
		contracttools.deletestamprow(contractrb.getcvalue('AC'), contractrb.getdvalue('DC'));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END ucreditstart;

	PROCEDURE creditchange
	(
		paccountno taccount.accountno%TYPE
	   ,pdate      DATE := NULL
	   ,pnewdate   DATE := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.CreditChange';
		verrcode NUMBER;
		vdate    DATE := pdate;
		vnewdate DATE := pnewdate;
	BEGIN
		IF vdate IS NULL
		THEN
			vdate := contracttools.getstartcrddate(paccountno);
		END IF;
		IF vnewdate IS NULL
		THEN
			vnewdate := seance.getoperdate();
		END IF;
	
		verrcode := contracttools.updatestamprow(paccountno, vnewdate);
		IF (vdate <> vnewdate)
		   AND (SQL%ROWCOUNT > 0)
		THEN
			contractrb.setlabel(crl_credit_update);
			contractrb.setcvalue('AC', paccountno);
			contractrb.setdvalue('DC', vdate);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END creditchange;

	PROCEDURE ucreditchange(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UCreditChange';
		verrcode NUMBER;
	BEGIN
		verrcode := contracttools.updatestamprow(contractrb.getcvalue('AC')
												,contractrb.getdvalue('DC'));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END ucreditchange;

	PROCEDURE creditend
	(
		paccountno taccount.accountno%TYPE
	   ,pdate      DATE := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.CreditEnd';
		verrcode NUMBER;
		vdate    DATE := pdate;
	BEGIN
		IF vdate IS NULL
		THEN
			vdate := contracttools.getstartcrddate(paccountno);
		END IF;
	
		verrcode := contracttools.setendcrddate(vdate, paccountno);
		IF SQL%ROWCOUNT > 0
		THEN
			contractrb.setlabel(crl_credit_end);
			contractrb.setcvalue('AC', paccountno);
			contractrb.setdvalue('DC', vdate);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END creditend;

	PROCEDURE ucreditend(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UCreditEnd';
	BEGIN
		contracttools.setendcrddatetonull(contractrb.getcvalue('AC'), contractrb.getdvalue('DC'));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END ucreditend;

	PROCEDURE setarcdate
	(
		pcontractno  tcontract.no%TYPE
	   ,pcurrarcdate DATE
	   ,pnewarcdate  DATE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SetArcDate';
	BEGIN
		IF nvl(pnewarcdate, cnulldate) <> nvl(pcurrarcdate, cnulldate)
		THEN
			contract.setarcdate(pcontractno, pnewarcdate);
			contractrb.setlabel(crl_set_arc_date);
			contractrb.setdvalue('AD', pcurrarcdate);
			setcontractno('CN', pcontractno);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setarcdate;

	PROCEDURE usetarcdate(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.USetArcDate';
	BEGIN
		contract.setarcdate(getcontractno('CN', pcontractno), contractrb.getdvalue('AD'));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END usetarcdate;

	PROCEDURE setctrldate
	(
		pcontractno IN tcontract.no%TYPE
	   ,pkey        IN tcontractctrldate.key%TYPE
	   ,pdate       IN DATE
	   ,psaveequal  IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SetCtrlDate';
		volddate DATE;
	BEGIN
		t.enter(cmethod_name, pdate);
	
		volddate := contractctrldate.readdate(pcontractno, pkey);
	
		IF psaveequal
		   OR contracttools.notequal(volddate, pdate)
		THEN
		
			contractctrldate.savedate(pcontractno, pkey, pdate);
		
			contractrb.setlabel(crl_chng_ctrl_date);
			contractrb.setnextnvalue('Key', pkey);
			contractrb.setdvalue(pkey, volddate);
		
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END setctrldate;

	PROCEDURE setarcdatebyctrl
	(
		pcontractno  tcontract.no%TYPE
	   ,pcurrarcdate DATE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SetArcDateByCtrl';
		vaoldkey  types.arrnum;
		vaolddate types.arrdate;
		vanewkey  types.arrnum;
		vanewdate types.arrdate;
		varcdate  DATE;
	BEGIN
		IF contractctrldate.cachechanges(pcontractno, vaoldkey, vaolddate, vanewkey, vanewdate)
		THEN
			varcdate := contractctrldate.getmindate(pcontractno);
			setarcdate(pcontractno, pcurrarcdate, varcdate);
		
			contractrb.setlabel(crl_chng_ctrl_date);
			setcontractno('CN', pcontractno);
		
			FOR i IN 1 .. vaoldkey.count
			LOOP
				contractrb.setnextnvalue('Key', vaoldkey(i));
				contractrb.setdvalue(vaoldkey(i), vaolddate(i));
			END LOOP;
		
			contractctrldate.flush(pcontractno);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setarcdatebyctrl;

	PROCEDURE usetarcdatebyctrl(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.USetArcDateByCtrl';
		vcontractno tcontract.no%TYPE;
		vctrlkey    PLS_INTEGER;
	BEGIN
		vcontractno := getcontractno('CN', pcontractno);
	
		WHILE contractrb.getnextnvalue('Key', vctrlkey)
		LOOP
			contractctrldate.setdate(vcontractno, vctrlkey, contractrb.getdvalue(vctrlkey));
		END LOOP;
	
		contractctrldate.flush(vcontractno);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END usetarcdatebyctrl;

	PROCEDURE setaccacct_stat
	(
		paccount   IN OUT NOCOPY taccount%ROWTYPE
	   ,pacct_stat taccount.acct_stat%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SetAccACCT_STAT';
		vprevacct_stat taccount.acct_stat%TYPE := paccount.acct_stat;
	BEGIN
		IF nvl(vprevacct_stat, '0') <> nvl(pacct_stat, '0')
		THEN
			IF contracttools.setaccacct_stat(paccount, pacct_stat) <> 0
			THEN
			
				error.raisewhenerr();
			
			END IF;
		
			contractrb.setlabel(crl_chng_acct_stat);
			contractrb.setcvalue('AN', paccount.accountno);
			contractrb.setcvalue('AS', vprevacct_stat);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setaccacct_stat;

	PROCEDURE setaccacct_stat
	(
		paccount   IN OUT NOCOPY contracttools.taccountrecord
	   ,pacct_stat taccount.acct_stat%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SetAccACCT_STAT';
		vprevacct_stat taccount.acct_stat%TYPE := paccount.acct_stat;
	BEGIN
		IF nvl(vprevacct_stat, '0') <> nvl(pacct_stat, '0')
		THEN
			IF contracttools.setaccacct_stat(paccount, pacct_stat) <> 0
			THEN
			
				error.raisewhenerr();
			
			END IF;
		
			contractrb.setlabel(crl_chng_acct_stat);
			contractrb.setcvalue('AN', paccount.accountno);
			contractrb.setcvalue('AS', vprevacct_stat);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setaccacct_stat;

	PROCEDURE usetaccacct_stat(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.USetAccACCT_STAT';
		vaccount taccount%ROWTYPE;
	BEGIN
		contracttools.loadcontractaccountbyaccno(contractrb.getcvalue('AN'), vaccount);
		IF contracttools.setaccacct_stat(vaccount, contractrb.getcvalue('AS')) <> 0
		THEN
		
			error.raisewhenerr();
		
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END usetaccacct_stat;

	PROCEDURE changegrouprisk
	(
		pcontractno tcontract.no%TYPE
	   ,poldvalue   tgrouprisk.oldgroup%TYPE
	   ,pnewvalue   tgrouprisk.newgroup%TYPE
	   ,pdate       DATE := NULL
	   ,pgrouptype  tgrouprisk.grouptype%TYPE := contracttools.cgrpcrd
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.ChangeGroupRisk';
		vno NUMBER;
	BEGIN
		IF contracttools.creategrouprisk(pcontractno, poldvalue, pnewvalue, vno, pdate, pgrouptype) <> 0
		THEN
		
			error.raisewhenerr();
		
		END IF;
	
		contractrb.setlabel(crl_chng_group_risk);
		contractrb.setnvalue('NO', vno);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changegrouprisk;

	PROCEDURE uchangegrouprisk(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UChangeGroupRisk';
	BEGIN
		IF contracttools.deletegrouprisk(contractrb.getnvalue('NO')) <> 0
		THEN
		
			error.raisewhenerr();
		
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uchangegrouprisk;

	PROCEDURE suspendon
	(
		pcontractno tcontract.no%TYPE
	   ,poldstatus  tcontract.status%TYPE := cnullchar
	   ,plog        BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SuspendOn';
		voldstatus tcontract.status%TYPE := poldstatus;
		vhistid    NUMBER;
		verrcode   NUMBER;
	BEGIN
		IF voldstatus = cnullchar
		THEN
			voldstatus := contract.getstatus(pcontractno);
		END IF;
	
		IF NOT contract.checkstatus(voldstatus, contract.stat_suspend)
		THEN
			IF plog
			THEN
				contract.setstatus(pcontractno, contract.stat_suspend, TRUE, vhistid, FALSE);
			ELSE
				verrcode := contract.setstatus(pcontractno, contract.stat_suspend, TRUE);
				IF verrcode <> 0
				THEN
					error.raiseerror(verrcode);
				END IF;
			END IF;
		
			contractrb.setlabel(crl_suspend_on);
			setcontractno('CN', pcontractno);
			IF plog
			THEN
				contractrb.setnvalue('ID', vhistid);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END suspendon;

	PROCEDURE ususpendon(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.USuspendOn';
		vhistid  NUMBER;
		verrcode NUMBER;
	BEGIN
		IF contractrb.getnvalue('ID', vhistid)
		THEN
			contract.setstatus(getcontractno('CN', pcontractno)
							  ,contract.stat_suspend
							  ,FALSE
							  ,vhistid
							  ,TRUE);
		ELSE
			verrcode := contract.setstatus(getcontractno('CN', pcontractno)
										  ,contract.stat_suspend
										  ,FALSE);
			IF verrcode <> 0
			THEN
				error.raiseerror(verrcode);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END ususpendon;

	PROCEDURE suspendoff
	(
		pcontractno tcontract.no%TYPE
	   ,poldstatus  tcontract.status%TYPE := cnullchar
	   ,plog        BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SuspendOff';
		voldstatus tcontract.status%TYPE := poldstatus;
		vhistid    NUMBER;
		verrcode   NUMBER;
	BEGIN
		IF voldstatus = cnullchar
		THEN
			voldstatus := contract.getstatus(pcontractno);
		END IF;
	
		IF contract.checkstatus(voldstatus, contract.stat_suspend)
		THEN
			IF plog
			THEN
				contract.setstatus(pcontractno, contract.stat_suspend, FALSE, vhistid, FALSE);
			ELSE
				verrcode := contract.setstatus(pcontractno, contract.stat_suspend, FALSE);
				IF verrcode <> 0
				THEN
					error.raiseerror(verrcode);
				END IF;
			END IF;
		
			contractrb.setlabel(crl_suspend_off);
			setcontractno('CN', pcontractno);
			IF plog
			THEN
				contractrb.setnvalue('ID', vhistid);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END suspendoff;

	PROCEDURE ususpendoff(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.USuspendOff';
		vhistid  NUMBER;
		verrcode NUMBER;
	BEGIN
		IF contractrb.getnvalue('ID', vhistid)
		THEN
			contract.setstatus(getcontractno('CN', pcontractno)
							  ,contract.stat_suspend
							  ,TRUE
							  ,vhistid
							  ,TRUE);
		ELSE
			verrcode := contract.setstatus(getcontractno('CN', pcontractno)
										  ,contract.stat_suspend
										  ,TRUE);
			IF verrcode <> 0
			THEN
				error.raiseerror(verrcode);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END ususpendoff;

	PROCEDURE investigationon
	(
		pcontractno tcontract.no%TYPE
	   ,poldstatus  tcontract.status%TYPE := cnullchar
	   ,plog        BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.InvestigateOn';
		voldstatus tcontract.status%TYPE := poldstatus;
		vhistid    NUMBER;
		verrcode   NUMBER;
	BEGIN
		IF voldstatus = cnullchar
		THEN
			voldstatus := contract.getstatus(pcontractno);
		END IF;
	
		IF NOT contract.checkstatus(voldstatus, contract.stat_investigation)
		THEN
			IF plog
			THEN
				contract.setstatus(pcontractno, contract.stat_investigation, TRUE, vhistid, FALSE);
			ELSE
				verrcode := contract.setstatus(pcontractno, contract.stat_investigation, TRUE);
				IF verrcode <> 0
				THEN
					error.raiseerror(verrcode);
				END IF;
			END IF;
		
			contractrb.setlabel(crl_investigation_on);
			setcontractno('CN', pcontractno);
			IF plog
			THEN
				contractrb.setnvalue('ID', vhistid);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END investigationon;

	PROCEDURE uinvestigationon(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UInvestigateOn';
		vhistid  NUMBER;
		verrcode NUMBER;
	BEGIN
		IF contractrb.getnvalue('ID', vhistid)
		THEN
			contract.setstatus(getcontractno('CN', pcontractno)
							  ,contract.stat_investigation
							  ,FALSE
							  ,vhistid
							  ,TRUE);
		ELSE
			verrcode := contract.setstatus(getcontractno('CN', pcontractno)
										  ,contract.stat_investigation
										  ,FALSE);
			IF verrcode <> 0
			THEN
				error.raiseerror(verrcode);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uinvestigationon;

	PROCEDURE investigationoff
	(
		pcontractno tcontract.no%TYPE
	   ,poldstatus  tcontract.status%TYPE := cnullchar
	   ,plog        BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.InvestigateOff';
		voldstatus tcontract.status%TYPE := poldstatus;
		vhistid    NUMBER;
		verrcode   NUMBER;
	BEGIN
		IF voldstatus = cnullchar
		THEN
			voldstatus := contract.getstatus(pcontractno);
		END IF;
	
		IF contract.checkstatus(voldstatus, contract.stat_investigation)
		THEN
			IF plog
			THEN
				contract.setstatus(pcontractno, contract.stat_investigation, FALSE, vhistid, FALSE);
			ELSE
				verrcode := contract.setstatus(pcontractno, contract.stat_investigation, FALSE);
				IF verrcode <> 0
				THEN
					error.raiseerror(verrcode);
				END IF;
			END IF;
		
			contractrb.setlabel(crl_investigation_off);
			setcontractno('CN', pcontractno);
			IF plog
			THEN
				contractrb.setnvalue('ID', vhistid);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END investigationoff;

	PROCEDURE uinvestigationoff(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UInvestigateOff';
		vhistid  NUMBER;
		verrcode NUMBER;
	BEGIN
		IF contractrb.getnvalue('ID', vhistid)
		THEN
			contract.setstatus(getcontractno('CN', pcontractno)
							  ,contract.stat_investigation
							  ,TRUE
							  ,vhistid
							  ,TRUE);
		ELSE
			verrcode := contract.setstatus(getcontractno('CN', pcontractno)
										  ,contract.stat_investigation
										  ,TRUE);
			IF verrcode <> 0
			THEN
				error.raiseerror(verrcode);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uinvestigationoff;

	PROCEDURE createaccountbycode
	(
		pcontract IN tcontract%ROWTYPE
	   ,paccount  IN OUT NOCOPY contracttools.taccountrecord
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.CreateAccountByCode';
	BEGIN
		contracttools.createaccountbycode(pcontract, paccount);
		contractrb.setlabel(crl_account_created);
		setcontractno('CNO', pcontract.no);
		contractrb.setcvalue('ANO', paccount.accountno);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END createaccountbycode;

	PROCEDURE ucreateaccountbycode(pcontractno IN tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UCreateAccountByCode';
		vcontractno tcontract.no%TYPE;
		vaccountno  taccount.accountno%TYPE;
		vexistsarr  contract.typeexistaccountarr;
	BEGIN
		vcontractno := getcontractno('CNO', pcontractno);
		vaccountno  := contractrb.getcvalue('ANO');
		contract.deleteorunlinkaccount(vcontractno, vaccountno, vexistsarr);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END ucreateaccountbycode;

	PROCEDURE changecontractparam
	(
		pcontractno    IN tcontractparameters.contractno%TYPE
	   ,pparam         IN tcontractparameters.key%TYPE
	   ,pnewvalue      IN tcontractparameters.value%TYPE
	   ,pmaskmode      IN NUMBER := NULL
	   ,pwritelog      IN BOOLEAN := FALSE
	   ,pparamname     IN VARCHAR := NULL
	   ,pvalues        IN contractparams.typevaluearray := contractparams.cemptyvaluearray
	   ,psaveinhistory IN BOOLEAN := FALSE
	   ,punequalonly   IN BOOLEAN := TRUE
	   ,
		
		ppan4mask IN tcard.pan%TYPE := NULL
	   ,powner    IN a4mlog.typeclientid := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.ChangeContractParam[1]';
		voldvalue tcontractparameters.value%TYPE;
	BEGIN
		voldvalue := contractparams.loadchar(contractparams.ccontract
											,pcontractno
											,pparam
											,FALSE
											,pmaskmode
											,ppan4mask);
		changecontractparam(pcontractno
						   ,pparam
						   ,pnewvalue
						   ,voldvalue
						   ,pmaskmode
						   ,pwritelog
						   ,pparamname
						   ,pvalues
						   ,psaveinhistory
						   ,punequalonly
						   ,ppan4mask
						   ,powner);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecontractparam;

	PROCEDURE changecontractparamacc
	(
		pcontractno    IN tcontractparameters.contractno%TYPE
	   ,pparam         IN tcontractparameters.key%TYPE
	   ,pnewvalue      IN tcontractparameters.value%TYPE
	   ,pmaskmode      IN NUMBER := NULL
	   ,pwritelog      IN BOOLEAN := FALSE
	   ,pparamname     IN VARCHAR := NULL
	   ,pvalues        IN contractparams.typevaluearray := contractparams.cemptyvaluearray
	   ,psaveinhistory IN BOOLEAN := FALSE
	)
	
	 IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.ChangeContractParamAcc';
		voldvalue tcontractparameters.value%TYPE;
	BEGIN
		IF account.exist(pnewvalue) <> 0
		THEN
			error.raiseerror('Account ' || pnewvalue || ' not found');
		END IF;
		voldvalue := contractparams.loadchar(contractparams.ccontract
											,pcontractno
											,pparam
											,FALSE
											,pmaskmode);
		changecontractparam(pcontractno
						   ,pparam
						   ,pnewvalue
						   ,voldvalue
						   ,pmaskmode
						   ,pwritelog
						   ,pparamname
						   ,pvalues
						   ,psaveinhistory);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecontractparamacc;

	PROCEDURE changecontractparam
	(
		pcontractno    IN tcontractparameters.contractno%TYPE
	   ,pparam         IN tcontractparameters.key%TYPE
	   ,pnewvalue      IN tcontractparameters.value%TYPE
	   ,poldvalue      IN tcontractparameters.value%TYPE
	   ,pmaskmode      IN NUMBER := NULL
	   ,pwritelog      IN BOOLEAN := FALSE
	   ,pparamname     IN VARCHAR := NULL
	   ,pvalues        IN contractparams.typevaluearray := contractparams.cemptyvaluearray
	   ,psaveinhistory IN BOOLEAN := FALSE
	   ,punequalonly   IN BOOLEAN := TRUE
	   ,
		
		ppan4mask IN tcard.pan%TYPE := NULL
	   ,powner    IN a4mlog.typeclientid := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.ChangeContractParam[2]';
		vsavingparams contractparams.typesavingparams;
		vsavingresult contractparams.typesavingresult;
	BEGIN
		vsavingparams.writelog      := pwritelog;
		vsavingparams.logparamname  := pparamname;
		vsavingparams.logvalues     := pvalues;
		vsavingparams.saveinhistory := psaveinhistory;
		vsavingparams.maskmode      := pmaskmode;
		vsavingparams.unequalonly   := punequalonly;
		vsavingparams.pan4mask      := ppan4mask;
		vsavingparams.owner         := powner;
	
		vsavingresult := contractparams.savechar(contractparams.ccontract
												,pcontractno
												,pparam
												,pnewvalue
												,vsavingparams);
	
		IF NOT nvl(punequalonly, TRUE)
		   OR nvl(pnewvalue, cnullchar) != nvl(poldvalue, cnullchar)
		THEN
			contractrb.setlabel(crl_change_con_param);
			setcontractno('CNO', pcontractno);
			contractrb.setcvalue('KEY', pparam);
			contractrb.setcvalue('OLD', poldvalue);
			IF pwritelog
			THEN
				contractrb.setcvalue('LOG', '1');
				contractrb.setcvalue('PAR', pparamname);
			END IF;
		
			IF vsavingresult.historyid IS NOT NULL
			THEN
				contractrb.setnvalue('HID', vsavingresult.historyid);
			END IF;
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecontractparam;

	PROCEDURE uchangecontractparam(pcontractno IN tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.UChangeContractParam';
		vcontract  tcontractparameters.contractno%TYPE;
		vparam     tcontractparameters.key%TYPE;
		vvalue     tcontractparameters.value%TYPE;
		vwritelog  BOOLEAN;
		vparamname VARCHAR(1000);
		vhistoryid tcontractparametershistory.recid%TYPE;
	BEGIN
		vcontract  := getcontractno('CNO', pcontractno);
		vparam     := contractrb.getcvalue('KEY');
		vvalue     := contractrb.getcvalue('OLD');
		vwritelog  := nvl(contractrb.getcvalue('LOG'), '0') = '1';
		vparamname := contractrb.getcvalue('PAR');
	
		vhistoryid := contractrb.getnvalue('HID');
		IF vhistoryid IS NOT NULL
		THEN
			contractparams.deletecontractparamhistory(vhistoryid);
		END IF;
	
		IF vvalue IS NULL
		THEN
			contractparams.deletevalue(contractparams.ccontract
									  ,vcontract
									  ,vparam
									  ,pwritelog                => vwritelog
									  ,pparamname               => vparamname);
		ELSE
			contractparams.savechar(contractparams.ccontract
								   ,vcontract
								   ,vparam
								   ,vvalue
								   ,pwhitelog                => vwritelog
								   ,pparamname               => vparamname);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uchangecontractparam;

	PROCEDURE changepercentid
	(
		pcontractno IN tcontract.no%TYPE
	   ,pparam      IN tcontractparameters.key%TYPE
	   ,pnewvalue   IN tcontractparameters.value%TYPE
	   ,pwritehist  IN BOOLEAN
	   ,pdolog      IN BOOLEAN
	   ,powner      IN a4mlog.typeclientid := NULL
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ChangePercentID';
		cpref        CONSTANT VARCHAR(10) := '';
		voldvalue tcontractparameters.value%TYPE;
		vnewvalue NUMBER := nvl(pnewvalue, 0);
	BEGIN
	
		voldvalue := referenceprchistory.getpercentid(referenceprchistory.ccontract
													 ,pcontractno
													 ,pparam);
		IF vnewvalue = voldvalue
		THEN
			NULL;
			s.say(cpref || 'Skipped ChangePercentID (' || pcontractno || ', ' || pparam || ', ' ||
				  pnewvalue || ', ' || voldvalue || ', ' || htools.bool2str(pwritehist) || ', ' ||
				  htools.bool2str(pdolog) || ')'
				 ,3);
		ELSE
			s.say('set pID' || nvl(pnewvalue, 0) || ' new val ' || pnewvalue, 1);
			IF vnewvalue > 0
			THEN
				referenceprchistory.savepercentid(referenceprchistory.ccontract
												 ,pcontractno
												 ,pparam
												 ,vnewvalue
												 ,pwritehist
												 ,pdolog
												 ,powner);
				s.say(cpref || 'Done ChangePercentID (' || pcontractno || ', ' || pparam || ', ' ||
					  pnewvalue || ', ' || voldvalue || ', ' || htools.bool2str(pwritehist) || ', ' ||
					  htools.bool2str(pdolog) || ')'
					 ,3);
			ELSE
				referenceprchistory.deletepercentid(referenceprchistory.ccontract
												   ,pcontractno
												   ,pparam
												   ,pwritehist
												   ,pdolog
												   ,powner);
				s.say(cpref || 'Deleted ChangePercentID (' || pcontractno || ', ' || pparam || ', ' ||
					  pnewvalue || ', ' || voldvalue || ', ' || htools.bool2str(pwritehist) || ', ' ||
					  htools.bool2str(pdolog) || ')'
					 ,3);
			END IF;
			contractrb.setlabel(crl_change_percentid);
			setcontractno('CNO', pcontractno);
			contractrb.setcvalue('KEY', pparam);
			contractrb.setcvalue('OLD', voldvalue);
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE uchangepercentid(pcontractno IN tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.UChangePercentID';
		cpref        CONSTANT VARCHAR(10) := '';
		vcontract tcontractparameters.contractno%TYPE;
		vparam    tcontractparameters.key%TYPE;
		vvalue    tcontractparameters.value%TYPE;
	BEGIN
	
		vcontract := getcontractno('CNO', pcontractno);
		vparam    := contractrb.getcvalue('KEY');
		vvalue    := contractrb.getcvalue('OLD');
		IF vvalue > 0
		THEN
			referenceprchistory.savepercentid(referenceprchistory.ccontract
											 ,pcontractno
											 ,vparam
											 ,vvalue);
			s.say(cpref || 'Done UChangePercentID (' || pcontractno || ', ' || vparam || ', ' ||
				  vvalue || ')'
				 ,3);
		ELSE
			referenceprchistory.deletepercentid(referenceprchistory.ccontract, pcontractno, vparam);
			s.say(cpref || 'Deleted UChangePercentID (' || pcontractno || ', ' || vparam || ', ' ||
				  vvalue || ')'
				 ,3);
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uchangepercentid;

	PROCEDURE changecardsignstat
	(
		ppan     IN tcard.pan%TYPE
	   ,pmbr     IN tcard.mbr%TYPE
	   ,psign    IN tcard.signstat%TYPE
	   ,pstat    tcard.crd_stat%TYPE
	   ,pcomment IN VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.ChangeCardSignStat [1]';
		vcard apitypes.typecardrecord;
	BEGIN
		vcard := card.getcardrecord(ppan, pmbr);
		changecardsignstat(ppan, pmbr, psign, pstat, pcomment, vcard.a4mstat, vcard.pcstat);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecardsignstat;

	PROCEDURE changecardsignstat
	(
		ppan     IN tcard.pan%TYPE
	   ,pmbr     IN tcard.mbr%TYPE
	   ,psign    IN tcard.signstat%TYPE
	   ,pstat    tcard.crd_stat%TYPE
	   ,pcomment IN VARCHAR2
	   ,poldsign IN tcard.signstat%TYPE
	   ,poldstat IN tcard.crd_stat%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.ChangeCardSignStat [2]';
		vset BOOLEAN := FALSE;
	
		PROCEDURE setlabelonce IS
			cmethod_name CONSTANT VARCHAR2(60) := changecardsignstat.cmethod_name ||
												  '.SetLabelOnce';
		BEGIN
			IF vset
			THEN
				RETURN;
			END IF;
			contractrb.setlabel(crl_card_change);
			contractrb.setcvalue('PAN', ppan);
			contractrb.setnvalue('MBR', pmbr);
			vset := TRUE;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethod_name);
				RAISE;
		END setlabelonce;
	
	BEGIN
		contracttools.setcardsignstat(ppan, pmbr, psign, pstat, TRUE, TRUE, pcomment);
		IF psign IS NOT NULL
		THEN
			setlabelonce();
			contractrb.setnvalue('SGN', poldsign);
		END IF;
		IF pstat IS NOT NULL
		THEN
			setlabelonce();
			contractrb.setcvalue('ST', poldstat);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecardsignstat;

	PROCEDURE uchangecardsignstat(pcontractno IN tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.UChangeCardSignStat';
		vpan  tcard.pan%TYPE;
		vmbr  tcard.mbr%TYPE;
		vsign tcard.signstat%TYPE;
		vstat tcard.crd_stat%TYPE;
	BEGIN
		vpan  := contractrb.getcvalue('PAN');
		vmbr  := contractrb.getnvalue('MBR');
		vsign := contractrb.getnvalue('SGN');
		vstat := contractrb.getcvalue('ST');
		contracttools.setcardsignstat(vpan, vmbr, vsign, vstat, FALSE, FALSE, 'Undo operation');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uchangecardsignstat;

	FUNCTION changecontractcardstat
	(
		pcontractno tcontract.no%TYPE
	   ,pfrom       IN tcard.crd_stat%TYPE
	   ,pto         IN tcard.crd_stat%TYPE
	   ,pcomment    IN VARCHAR2
	) RETURN typecardstatchangeinfoarray IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.ChangeContractCardStat [function]';
		vresult typecardstatchangeinfoarray;
	
		vcardlist apitypes.typecardlist;
	BEGIN
		t.enter(cmethod_name, pcontractno);
	
		IF (pfrom IS NULL)
		   OR (pfrom <> pto)
		THEN
			vcardlist := contract.getcardlist(pcontractno);
			FOR i IN 1 .. vcardlist.count
			LOOP
				IF vcardlist(i).pcstat = nvl(pfrom, vcardlist(i).pcstat)
				THEN
					changecardsignstat(vcardlist(i).pan
									  ,vcardlist(i).mbr
									  ,NULL
									  ,pto
									  ,pcomment
									  ,vcardlist(i).a4mstat
									  ,vcardlist(i).pcstat);
					vresult(vresult.count + 1).pan := vcardlist(i).pan;
					vresult(vresult.count).mbr := vcardlist(i).mbr;
				
					vresult(vresult.count).oldstat := pfrom;
					vresult(vresult.count).newstat := pto;
				END IF;
			END LOOP;
		END IF;
	
		t.leave(cmethod_name, vresult.count);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name);
			error.save(cmethod_name);
			RAISE;
	END changecontractcardstat;

	PROCEDURE changecontractcardstat
	(
		pcontractno tcontract.no%TYPE
	   ,pfrom       IN tcard.crd_stat%TYPE
	   ,pto         IN tcard.crd_stat%TYPE
	   ,pcomment    IN VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name ||
											  '.ChangeContractCardStat [procedure]';
		vdummy typecardstatchangeinfoarray;
	BEGIN
		vdummy := changecontractcardstat(pcontractno, pfrom, pto, pcomment);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecontractcardstat;

	FUNCTION changecontractcardsign
	(
		pcontractno tcontract.no%TYPE
	   ,pfrom       IN tcard.signstat%TYPE
	   ,pto         IN tcard.signstat%TYPE
	   ,pcomment    IN VARCHAR2
	) RETURN typecardsignchangeinfoarray IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.ChangeContractCardSign [function]';
		vresult   typecardsignchangeinfoarray;
		vcardlist apitypes.typecardlist;
	BEGIN
		IF (pfrom IS NULL)
		   OR (pfrom <> pto)
		THEN
			vcardlist := contract.getcardlist(pcontractno);
			FOR i IN 1 .. vcardlist.count
			LOOP
				IF vcardlist(i).a4mstat = nvl(pfrom, vcardlist(i).a4mstat)
				THEN
					changecardsignstat(vcardlist(i).pan
									  ,vcardlist(i).mbr
									  ,pto
									  ,NULL
									  ,pcomment
									  ,vcardlist(i).a4mstat
									  ,vcardlist(i).pcstat);
					vresult(vresult.count + 1).pan := vcardlist(i).pan;
					vresult(vresult.count).mbr := vcardlist(i).mbr;
					vresult(vresult.count).oldsign := pfrom;
					vresult(vresult.count).newsign := pto;
				END IF;
			END LOOP;
		END IF;
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecontractcardsign;

	PROCEDURE changecontractcardsign
	(
		pcontractno tcontract.no%TYPE
	   ,pfrom       IN tcard.signstat%TYPE
	   ,pto         IN tcard.signstat%TYPE
	   ,pcomment    IN VARCHAR2
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name ||
											  '.ChangeContractCardSign [procedure]';
		vdummy typecardsignchangeinfoarray;
	BEGIN
		vdummy := changecontractcardsign(pcontractno, pfrom, pto, pcomment);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecontractcardsign;

	PROCEDURE closecontract
	(
		pcontractno  IN tcontract.no%TYPE
	   ,pcards2close IN PLS_INTEGER
	   ,pcomment     IN VARCHAR2 := NULL
	   ,pclosedate   IN DATE := NULL
	   ,plog         IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CloseContract[1]';
		vhistid tcontractstatushistory.recno%TYPE;
	BEGIN
		t.enter(cmethod_name, plevel => csay_level);
		t.inpar('pContractNo', pcontractno);
		t.inpar('pCards2Close', pcards2close);
		t.inpar('pComment', pcomment);
		t.inpar('pCloseDate', htools.d2s(pclosedate));
		t.inpar('pLog', t.b2t(plog));
	
		CASE nvl(pcards2close, cclose_allcards)
			WHEN cclose_allcards THEN
				IF contracttools.closecard(pcontractno, TRUE, pcomment) IS NULL
				THEN
					error.raisewhenerr();
				END IF;
			WHEN cclose_openedcards THEN
				IF contracttools.closecard(pcontractno, FALSE, pcomment) IS NULL
				THEN
					error.raisewhenerr();
				END IF;
			WHEN cclose_none THEN
				NULL;
			ELSE
				error.raiseerror('Invalid card closure mode');
		END CASE;
	
		IF contracttools.closeaccounts(pcontractno, pclosedate) != 0
		THEN
			error.raisewhenerr();
		END IF;
	
		IF NOT plog
		THEN
			IF contracttools.closecontract(pcontractno) != 0
			THEN
				error.raisewhenerr();
			END IF;
		ELSE
			contracttools.closecontract(pcontractno, vhistid, FALSE);
		END IF;
	
		contractrb.setlabel(crl_close_contract);
		setcontractno('CN', pcontractno);
	
		IF plog
		THEN
			contractrb.setnvalue('ID', vhistid);
		END IF;
	
		t.leave(cmethod_name, plevel => csay_level);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethod_name, plevel => csay_level);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE closecontract
	(
		pcontractno    IN tcontract.no%TYPE
	   ,pcomment       IN VARCHAR2 := NULL
	   ,pclosedate     IN DATE := NULL
	   ,pcloseallcards IN BOOLEAN := TRUE
	   ,plog           IN BOOLEAN := FALSE
	) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.CloseContract[2]';
	BEGIN
		IF nvl(pcloseallcards, TRUE)
		THEN
			closecontract(pcontractno, cclose_allcards, pcomment, pclosedate, nvl(plog, FALSE));
		ELSE
			closecontract(pcontractno, cclose_openedcards, pcomment, pclosedate, nvl(plog, FALSE));
		
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END closecontract;

	PROCEDURE uclosecontract(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(200) := cpackage_name || '.UCloseContract';
		vcontractno tcontract.no%TYPE;
		vhistid     tcontractstatushistory.recno%TYPE;
	BEGIN
		vcontractno := getcontractno('CN', pcontractno);
	
		IF contracttools.openaccounts(vcontractno) != 0
		THEN
			error.raisewhenerr();
		END IF;
	
		IF contracttools.unclosecard(vcontractno, 'Undo operation') IS NULL
		THEN
			error.raisewhenerr();
		END IF;
	
		IF contractrb.getnvalue('ID', vhistid)
		THEN
			contracttools.opencontract(vcontractno, vhistid, TRUE);
		ELSE
			IF contracttools.opencontract(vcontractno) != 0
			THEN
				error.raisewhenerr();
			END IF;
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uclosecontract;

	PROCEDURE setlastadjdate
	(
		pcontractno IN VARCHAR2
	   ,pdate       IN DATE
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.SetLastAdjDate';
	BEGIN
		contractrb.setlabel(crl_set_last_adj_date);
		setcontractno('CN', pcontractno);
		contractrb.setdvalue('OLD', contract.getlastadjdate(pcontractno));
		contract.setlastadjdate(pcontractno, pdate);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE usetlastadjdate(pcontractno IN VARCHAR2) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.USetLastAdjDate';
		vcontractno tcontract.no%TYPE;
		vdate       DATE;
	BEGIN
		vcontractno := getcontractno('CN', pcontractno);
		vdate       := contractrb.getdvalue('OLD');
		contract.setlastadjdate(vcontractno, vdate);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;
	PROCEDURE changecparamvalue
	(
		pcontractno IN tcontractparameters.contractno%TYPE
	   ,pparam      IN tcontractparameters.key%TYPE
	   ,pnewvalue   IN tcontractparameters.value%TYPE
	   ,poldvalue   IN tcontractparameters.value%TYPE
	   ,pmaskmode   IN NUMBER := NULL
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.ChangeCParamValue';
		vrecid        NUMBER;
		vsavingparams contractparams.typesavingparams;
	BEGIN
	
		vsavingparams.maskmode := pmaskmode;
	
		vrecid := contractparams.savecharcontract(pcontractno
												 ,pparam
												 ,pnewvalue
												 ,poldvalue
												 ,vsavingparams);
	
		IF vrecid > 0
		THEN
			contractrb.setlabel(crl_chng_cparam_value);
			contractrb.setnvalue('ID', vrecid);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecparamvalue;

	PROCEDURE uchangecparamvalue(pcontractno IN tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UChangeCParamValue';
	BEGIN
		contractparams.undosavecharcontract(contractrb.getnvalue('ID'));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uchangecparamvalue;

	PROCEDURE setentryaux(pdocno tdocument.docno%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SetEntryAux';
	BEGIN
		IF pdocno IS NOT NULL
		THEN
			contractrb.setlabel(crl_entryaux);
			contractrb.setnvalue('DN', pdocno);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END setentryaux;
	PROCEDURE usetentryaux(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.USetEntryAux';
	
	BEGIN
	
		contracttools.entryundo(contractrb.getnvalue('DN'), entry.flnocheck);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END usetentryaux;

	PROCEDURE changedebitreserve
	(
		paccountno IN taccount.accountno%TYPE
	   ,pvalue     IN NUMBER
	   ,pdelta     IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.ChangeDebitReserve';
		vval NUMBER;
	BEGIN
		vval := nvl(pvalue, 0);
		IF (pdelta)
		THEN
			account.changedebitreserve(paccountno, vval, TRUE);
		ELSE
			DECLARE
				this NUMBER;
			BEGIN
				this := account.newobject(paccountno, 'W');
				IF (this = 0)
				THEN
					error.raiseerror(err.account_invalid_handle);
				END IF;
			
				vval := vval - account.getdebitreserve(this);
				account.changedebitreservebyhandle(this, vval);
			
				account.writeobject(this);
			
				error.raisewhenerr();
			
				account.freeobject(this);
			
			EXCEPTION
				WHEN OTHERS THEN
					account.freeobject(this);
					RAISE;
			END;
		END IF;
	
		contractrb.setlabel(crl_debit_reserve);
		contractrb.setcvalue('AN', paccountno);
		contractrb.setnvalue('DR', vval);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changedebitreserve;

	PROCEDURE uchangedebitreserve IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.UChangeDebitReserve';
	BEGIN
		account.changedebitreserve(contractrb.getcvalue('AN'), -contractrb.getnvalue('DR'));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uchangedebitreserve;

	PROCEDURE changecreditreserve
	(
		paccountno IN taccount.accountno%TYPE
	   ,pvalue     IN NUMBER
	   ,pdelta     IN BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.ChangeCreditReserve';
		vval NUMBER;
	BEGIN
		vval := nvl(pvalue, 0);
		IF pdelta
		THEN
			account.changecreditreserve(paccountno, vval, TRUE);
		ELSE
			DECLARE
				this NUMBER;
			BEGIN
				this := account.newobject(paccountno, 'W');
				IF this = 0
				THEN
					error.raiseerror(err.account_invalid_handle);
				END IF;
			
				vval := vval - account.getcreditreserve(this);
				account.changecreditreservebyhandle(this, vval);
			
				account.writeobject(this);
			
				error.raisewhenerr();
			
				account.freeobject(this);
			EXCEPTION
				WHEN OTHERS THEN
					account.freeobject(this);
					RAISE;
			END;
		END IF;
	
		contractrb.setlabel(crl_credit_reserve);
		contractrb.setcvalue('AN', paccountno);
		contractrb.setnvalue('DR', vval);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecreditreserve;

	PROCEDURE uchangecreditreserve IS
		cmethod_name CONSTANT VARCHAR2(60) := cpackage_name || '.UChangeCreditReserve';
	BEGIN
		account.changecreditreserve(contractrb.getcvalue('AN'), -contractrb.getnvalue('DR'));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uchangecreditreserve;

	PROCEDURE createcoverage
	(
		pcontractno IN VARCHAR
	   ,pclientid   IN NUMBER
	   ,puamp       IN VARCHAR
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.CreateCoverage';
	
	BEGIN
	
		loancoverage.createcoveragefromuamp(pcontractno, pclientid, puamp, crl_coverage);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;
	/*
        PROCEDURE setexpressionlog(pexprid texpressionlog.id%TYPE) IS
            cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetExpressionLog';
        BEGIN
            IF pexprid IS NOT NULL
            THEN
                contractrb.setlabel(crl_expression_log);
                contractrb.setnvalue('ExprId', pexprid);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                error.save(cmethod_name);
                RAISE;
        END;
    
    PROCEDURE usetexpressionlog IS
        cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.USetExpressionLog';
        vexprid texpressionlog.id%TYPE;
    BEGIN
        vexprid := contractrb.getnvalue('ExprId');
        sch_expression.deleteexpressionlog(vexprid);
    EXCEPTION
        WHEN OTHERS THEN
            error.save(cmethod_name);
            RAISE;
    END;*/

	PROCEDURE setprolongation(pidprol tcontractprolongation.idprol%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(65) := cpackage_name || '.SetProlongation';
	BEGIN
		IF pidprol IS NOT NULL
		THEN
			contractrb.setlabel(crl_prolongation);
			contractrb.setnvalue('IP', pidprol);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;
	PROCEDURE usetprolongation IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.USetProlongation';
		vidprol tcontractprolongation.idprol%TYPE;
	BEGIN
		vidprol := contractrb.getnvalue('IP');
		contracttools.deleteprolongation(vidprol);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE setaccountstat
	(
		paccountno taccount.accountno%TYPE
	   ,pstat      CHAR
	   ,pset       BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.SetAccountStat';
		vhandle  NUMBER := 0;
		voldstat taccount.stat%TYPE;
	BEGIN
		t.enter(cmethod_name, 'pAccountNo=' || paccountno || ' pStat=' || pstat, 1);
		contracttools.openhandle(vhandle, paccountno);
		error.raisewhenerr();
		voldstat := account.getstat(vhandle);
	
		IF (pset AND (service.getbit(voldstat, pstat) <> 1))
		   OR (NOT pset AND (service.getbit(voldstat, pstat) = 1))
		THEN
			IF account.testhandle(vhandle, cmethod_name) <> 'N'
			THEN
				IF pset
				THEN
					t.note(cmethod_name, 'Set status ' || pstat, 1);
					account.setstat(vhandle, service.setbit(voldstat, pstat));
				ELSE
					t.note(cmethod_name, 'Remove status ' || pstat, 1);
					account.setstat(vhandle, service.clsbit(voldstat, pstat));
				END IF;
			END IF;
			error.raisewhenerr();
			account.writeobject(vhandle);
			error.raisewhenerr();
			contractrb.setlabel(crl_set_account_stat);
			contractrb.setcvalue('A', paccountno);
			contractrb.setcvalue('S', pstat);
			contractrb.setnvalue('B', CASE WHEN pset THEN 1 ELSE 0 END);
		END IF;
		contracttools.freehandle(vhandle);
		t.leave(cmethod_name, NULL, 1);
	EXCEPTION
		WHEN OTHERS THEN
			IF vhandle <> 0
			THEN
				contracttools.freehandle(vhandle);
			END IF;
			t.exc(cmethod_name, SQLERRM(), 1);
			error.save(cmethod_name);
			RAISE;
	END;
	PROCEDURE usetaccountstat(pcontractno tcontract.no%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.USetAccountStat';
		vhandle NUMBER := 0;
	BEGIN
		t.enter(cmethod_name, 'pContractNo=' || pcontractno, 1);
		contracttools.openhandle(vhandle, contractrb.getcvalue('A'));
		error.raisewhenerr();
		IF contractrb.getnvalue('B') = 1
		THEN
			account.setstat(vhandle
						   ,service.clsbit(account.getstat(vhandle), contractrb.getcvalue('S')));
		ELSE
			account.setstat(vhandle
						   ,service.setbit(account.getstat(vhandle), contractrb.getcvalue('S')));
		END IF;
		account.writeobject(vhandle);
		error.raisewhenerr();
		contracttools.freehandle(vhandle);
		t.leave(cmethod_name, NULL, 1);
	EXCEPTION
		WHEN OTHERS THEN
			IF vhandle <> 0
			THEN
				contracttools.freehandle(vhandle);
			END IF;
			t.exc(cmethod_name, SQLERRM(), 1);
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE closeaccount(paccountno taccount.accountno%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.CloseAccount';
	BEGIN
		IF contracttools.closeaccount(paccountno) <> 0
		THEN
			error.raisewhenerr();
		END IF;
	
		contractrb.setlabel(crl_close_account);
		contractrb.setcvalue('ACC', paccountno);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE ucloseaccount IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UCloseAccount';
		vaccountno taccount.accountno%TYPE;
	BEGIN
		vaccountno := contractrb.getcvalue('ACC');
		IF contracttools.openaccount(vaccountno) <> 0
		THEN
			error.raisewhenerr();
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE openaccount(paccountno taccount.accountno%TYPE) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.CloseAccount';
	BEGIN
		IF contracttools.openaccount(paccountno) <> 0
		THEN
			error.raisewhenerr();
		END IF;
	
		contractrb.setlabel(crl_open_account);
		contractrb.setcvalue('ACC', paccountno);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE uopenaccount IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.UOpenAccount';
		vaccountno taccount.accountno%TYPE;
	BEGIN
		vaccountno := contractrb.getcvalue('ACC');
		IF contracttools.closeaccount(vaccountno) <> 0
		THEN
			error.raisewhenerr();
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE lockcards
	(
		pcontractno tcontract.no%TYPE
	   ,pstatuslock tcard.crd_stat%TYPE
	   ,pundo       BOOLEAN := FALSE
	   ,pcomment    VARCHAR2 := NULL
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.LockCards';
		vislock BOOLEAN;
	BEGIN
		t.enter(cmethod_name);
		vislock := contracttools.lockcard(pcontractno, pstatuslock, pundo, pcomment);
		t.note('vIsLock:=' || htools.bool2str(vislock));
		IF vislock
		THEN
			contractrb.setlabel(crl_card_lock);
			setcontractno('CN', pcontractno);
			contractrb.setcvalue('STAT', pstatuslock);
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END lockcards;

	PROCEDURE ulockcards
	(
		pcontractno tcontract.no%TYPE
	   ,pstatuslock tcard.crd_stat%TYPE
	   ,pundo       BOOLEAN := FALSE
	   ,pcomment    VARCHAR2 := NULL
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ULockCards';
		vislock BOOLEAN;
	BEGIN
		t.enter(cmethod_name);
		vislock := contracttools.unlockcard(pcontractno, pstatuslock, pundo, pcomment);
		t.note('vIsLock:=' || htools.bool2str(vislock));
		IF vislock
		THEN
			contractrb.setlabel(crl_card_unlock);
			setcontractno('CN', pcontractno);
			contractrb.setcvalue('STAT', pstatuslock);
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END ulockcards;

	PROCEDURE linkcard2account
	(
		ppan       IN tcard.pan%TYPE
	   ,pmbr       IN tcard.mbr%TYPE
	   ,paccountno IN taccount.accountno%TYPE
	   ,pstatus    IN tcontractcardacc.accstatus%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.LinkCard2Account';
	BEGIN
		card.createlinkaccount(ppan, pmbr, paccountno, pstatus);
	
		contractrb.setlabel(crl_link_card2account);
		contractrb.setcvalue('PAN', ppan);
		contractrb.setnvalue('MBR', pmbr);
		contractrb.setcvalue('ACC', paccountno);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END linkcard2account;

	PROCEDURE ulinkcard2account IS
		cmethod_name CONSTANT VARCHAR2(80) := cpackage_name || '.ULinkCard2Account';
	BEGIN
		card.deletelinkaccount(contractrb.getcvalue('PAN')
							  ,contractrb.getnvalue('MBR')
							  ,contractrb.getcvalue('ACC'));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END ulinkcard2account;

	PROCEDURE changecontracttype
	(
		pcontractno      tcontract.no%TYPE
	   ,poldcontracttype tcontract.type%TYPE
	   ,pnewcontracttype tcontract.type%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ChangeContractType';
	BEGIN
		t.enter(cmethod_name
			   ,'pOldContractType:=' || poldcontracttype || '; pNewContractType:=' ||
				pnewcontracttype || ';');
		IF contracttype.existstype(pnewcontracttype)
		THEN
			contractrb.setlabel(crl_change_type_contract);
			contractrb.setcvalue('CNO', pcontractno);
			contractrb.setnvalue('OLDTYPE', poldcontracttype);
			contractrb.setnvalue('NEWTYPE', pnewcontracttype);
		
			UPDATE tcontract SET TYPE = pnewcontracttype WHERE no = pcontractno;
		
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changecontracttype;

	PROCEDURE uchangecontracttype IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ULockCards';
		vcontractno      tcontract.no%TYPE;
		voldcontracttype tcontract.type%TYPE;
	BEGIN
		t.enter(cmethod_name);
		vcontractno      := contractrb.getcvalue(crl_change_type_contract, 'CNO');
		voldcontracttype := contractrb.getnvalue(crl_change_type_contract, 'OLDTYPE');
		t.note(cmethod_name
			  ,'Undo contract type change: ContractNO:=' || vcontractno || '; vOldContractType:=' ||
			   voldcontracttype || ';');
	
		IF contracttype.existstype(voldcontracttype)
		THEN
		
			UPDATE tcontract SET TYPE = voldcontracttype WHERE no = vcontractno;
		END IF;
	
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uchangecontracttype;

	PROCEDURE changeitemcodeaccount
	(
		paccount     apitypes.typeaccountrecord
	   ,polditemcode tcontractitem.itemcode%TYPE
	   ,pnewitemcode tcontractitem.itemcode%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ChangeItemCodeAccount';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethod_name
			   ,'pOldItemCode:=' || polditemcode || '; pNewItemCode:=' || pnewitemcode || ';');
		IF account.accountexist(paccount.accountno)
		THEN
			contractrb.setlabel(crl_change_itemcode_account);
			contractrb.setcvalue('ACCNO', paccount.accountno);
			contractrb.setnvalue('OLDITEMCODE', polditemcode);
			contractrb.setnvalue('NEWITEMCODE', pnewitemcode);
		
			UPDATE tcontractitem t
			SET    t.itemcode = pnewitemcode
			WHERE  t.branch = vbranch
			AND    t.key = paccount.accountno;
		
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changeitemcodeaccount;

	PROCEDURE uchangeitemcodeaccount IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.UChangeItemCodeAccount';
		vaccountno   tcontractitem.no%TYPE;
		volditemcode tcontractitem.itemcode%TYPE;
		vbranch      NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethod_name);
	
		vaccountno   := contractrb.getcvalue(crl_change_itemcode_account, 'ACCNO');
		volditemcode := contractrb.getcvalue(crl_change_itemcode_account, 'OLDITEMCODE');
	
		IF account.accountexist(vaccountno)
		THEN
		
			UPDATE tcontractitem t
			SET    t.itemcode = volditemcode
			WHERE  t.branch = vbranch
			AND    t.key = vaccountno;
		
			t.note(cmethod_name
				  ,'Undo account ItemCode change: AccountNo:=' || vaccountno || '; vOldItemCode:=' ||
				   volditemcode || ';');
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uchangeitemcodeaccount;

	PROCEDURE changeitemcodecard
	(
		pcard        apitypes.typeaccount2cardrecord
	   ,polditemcode tcontractcarditem.itemcode%TYPE
	   ,pnewitemcode tcontractcarditem.itemcode%TYPE
	) IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.ChangeItemCodeAccount';
		vbranch NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethod_name
			   ,'pOldItemCode:=' || polditemcode || '; pNewItemCode:=' || pnewitemcode || ';');
	
		IF card.cardexists(pcard.pan, pcard.mbr)
		THEN
		
			contractrb.setlabel(crl_change_itemcode_card);
			contractrb.setcvalue('PAN', pcard.pan);
			contractrb.setnvalue('MBR', pcard.mbr);
			contractrb.setnvalue('OLDITEMCODE', polditemcode);
			contractrb.setnvalue('NEWITEMCODE', pnewitemcode);
		
			UPDATE tcontractcarditem t
			SET    t.itemcode = pnewitemcode
			WHERE  t.branch = vbranch
			AND    t.pan = pcard.pan
			AND    t.mbr = pcard.mbr;
		
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END changeitemcodecard;

	PROCEDURE uchangeitemcodecard IS
		cmethod_name CONSTANT VARCHAR(60) := cpackage_name || '.UChangeItemCodeCard';
		vcardpan     tcard.pan%TYPE;
		vcardmbr     tcard.mbr%TYPE;
		vbranch      NUMBER := seance.getbranch();
		volditemcode tcontractcarditem.itemcode%TYPE;
	BEGIN
		t.enter(cmethod_name);
	
		vcardpan     := contractrb.getcvalue(crl_change_itemcode_card, 'PAN');
		vcardmbr     := contractrb.getcvalue(crl_change_itemcode_card, 'MBR');
		volditemcode := contractrb.getcvalue(crl_change_itemcode_card, 'OLDITEMCODE');
	
		IF card.cardexists(vcardpan, vcardmbr)
		THEN
		
			UPDATE tcontractcarditem t
			SET    t.itemcode = volditemcode
			WHERE  t.branch = vbranch
			AND    t.pan = vcardpan
			AND    t.mbr = vcardmbr;
		
			t.note(cmethod_name
				  ,'Undo card ItemCode change: PAN:=' || vcardpan || '; MBR:=' || vcardmbr ||
				   '; vOldItemCode:=' || volditemcode || ';');
		END IF;
		t.leave(cmethod_name);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END uchangeitemcodecard;

END custom_contractrbstd;
/
