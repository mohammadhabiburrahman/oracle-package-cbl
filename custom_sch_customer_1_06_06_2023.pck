CREATE OR REPLACE PACKAGE custom_sch_customer_1 AS
	SUBTYPE typepackagename IS tcontractschemas.packagename%TYPE;
	SUBTYPE typebillingcycle IS tcontractstcycle%ROWTYPE;

	SUBTYPE typecontractno IS tcontract.no%TYPE;
	scontracttype NUMBER;

	TYPE typedelstatusrecord IS RECORD(
		 overduecalctype         PLS_INTEGER
		,period                  NUMBER
		,fairperiod              NUMBER
		,deldate                 DATE
		,overduecalcspecmodeused BOOLEAN
		,overdueamount_threshold NUMBER
		,overlimitcalctype       PLS_INTEGER
		,overlimit               NUMBER
		,stateid                 NUMBER
		,state                   contractstatereference.typestaterow
		,profileiddom            NUMBER
		,profileidint            NUMBER
		,mpprofileiddom          NUMBER
		,mpprofileidint          NUMBER
		,aggregatedoverdueamount NUMBER
		,lastreggroupindex       NUMBER
		,currentgroupindex       NUMBER
		,lastregisteredstatecode contractstatereference.typestatecode
		,lastregisteredstickmode tcontractstatehistory.stickmode%TYPE
		,statechangeallowed      BOOLEAN);

	TYPE typeprcchargerecord IS RECORD(
		 groupid NUMBER
		,amount  NUMBER);

	cnotdefined CONSTANT PLS_INTEGER := 1;
	caggregate  CONSTANT PLS_INTEGER := 2;
	cseparate   CONSTANT PLS_INTEGER := 3;
	cnotused    CONSTANT PLS_INTEGER := 4;

	TYPE typeprcchargearray IS TABLE OF typeprcchargerecord INDEX BY PLS_INTEGER;
	TYPE typenumber IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
	SUBTYPE typecontracttype IS tcontract.type%TYPE;
	TYPE typepaidhistcurrarray IS TABLE OF typepaidhistarray INDEX BY PLS_INTEGER;

	SUBTYPE typeovdfeeprofilesettings IS toverduefeecalclogmain%ROWTYPE;
	SUBTYPE typeovdfeecalcdata IS tregpromologcalcsetings%ROWTYPE;
	TYPE typeovdfeeasintcalcdetails IS TABLE OF toverduefeeinterestcalcdetails%ROWTYPE INDEX BY PLS_INTEGER;

	TYPE typeovdfeecalclog IS RECORD(
		 hasinfo         BOOLEAN := FALSE
		,profilesettings typeovdfeeprofilesettings
		,regularcalcdata typeovdfeecalcdata
		,promocalcdata   typeovdfeecalcdata
		,intcalcdetails  typeovdfeeasintcalcdetails
		,lastfeecharge   DATE);

	TYPE typecloseinfo IS RECORD(
		 account        contracttools.taccountrecord
		,prcchargearray typeprcchargearray
		
		,overduefee        NUMBER := 0
		,overduefeegst     NUMBER := 0
		,ovdfeecalclog     typeovdfeecalclog
		,overlimitfee      NUMBER := 0
		,overlimitfeegst   NUMBER := 0
		,installmentamount NUMBER := 0
		,totalbalance      NUMBER);
	TYPE typecloseinfoarray IS TABLE OF typecloseinfo INDEX BY PLS_INTEGER;
	caggregate CONSTANT PLS_INTEGER := 2;

	PROCEDURE getinterestamount
	(
		pcontractno           IN VARCHAR
	   ,oaprcarraydom         OUT NOCOPY typeprcchargearray
	   ,oaprcarrayint         OUT NOCOPY typeprcchargearray
	   ,oaovdfeeamount        OUT NOCOPY typenumber
	   ,oaovlfeeamount        OUT NOCOPY typenumber
	   ,osavedinterestcalclog OUT NOCOPY typeparsedinterestlog_tab
	   ,puserdefinedoperdate  IN DATE := NULL
	);
END;
/
CREATE OR REPLACE PACKAGE BODY custom_sch_customer_1 AS
	cpackagename CONSTANT typepackagename := 'custom_SCH_Customer_1';

	scontractno        typecontractno;
	scontractstat      VARCHAR2(10);
	sodparams          contractdcsetup.typeparamarray;
	saccumintaccmode   NUMBER;
	sdepaccount        custom_contracttools.typeaccarray;
	sovdaccount        custom_contracttools.typeaccarray;
	sintaccount        custom_contracttools.typeaccarray;
	smpprofile         custom_contractprofiles.typeprofilparamarray;
	smpgroupsettings   custom_contractprofiles.typempgroupparamarrarr;
	sprofile           custom_contractprofiles.typeprofilparamarray;
	sopergroup         custom_contractprofiles.typeprofilgroupparamarray;
	sopergroupredrates custom_contractprofiles.typereducedratesprofarr;
	sprofilerates      custom_contractprofiles.typegrouprates;
	sordergroup        custom_contractprofiles.typenumbernumber;
	slabel             types.arrstr20;
	sautounstick       BOOLEAN;
	scardlist1         custom_api_type.typeaccount2cardlist;
	scardlist2         apitypes.typeaccount2cardlist;
	scardcount1        NUMBER;
	scardcount2        NUMBER;

	TYPE typedelparamrecord IS RECORD(
		 overdueint NUMBER
		,limitint   NUMBER);
	sdelparam typedelparamrecord;

	sprecision            types.arrnum;
	sinttoinston          types.arrbool;
	ssavedinterestcalclog typeparsedinterestlog_tab;
	TYPE typeamnthistoryrecord IS RECORD(
		 operdate DATE
		,amount   NUMBER
		,balance  NUMBER);
	TYPE typeamnthistoryarray IS TABLE OF typeamnthistoryrecord INDEX BY PLS_INTEGER;

	TYPE typestrarrarr IS TABLE OF types.arrstr1000 INDEX BY PLS_INTEGER;
	TYPE typeaccarrarr IS TABLE OF contracttools.typeaccarray INDEX BY PLS_INTEGER;
	sprcchargeint typeprcchargearray;
	vdummypha     typepaidhistarray;
	sacparamccy   typestrarrarr;
	sacctparamccy typestrarrarr;
	sacparam      types.arrstr1000;
	sact_cparam   types.arrstr1000;
	sactparamccy  typestrarrarr;
	sactparam     types.arrstr1000;
	sabaccounts   typeaccarrarr;

	TYPE typedelstatusarray IS TABLE OF typedelstatusrecord INDEX BY PLS_INTEGER;
	sdelstatus  typedelstatusarray;
	sdeldate    types.arrdate;
	slastdocno  types.arrnum;
	sblockparam typedelstatusrecord;

	TYPE typedelinqprofilearray IS TABLE OF tcontractdelinqprofiles%ROWTYPE INDEX BY PLS_INTEGER;
	TYPE typedelinqprofilearrbycurr IS TABLE OF typedelinqprofilearray INDEX BY PLS_INTEGER;

	TYPE typecontrtypeparams_cache_rec IS RECORD(
		 usedcurrency           types.arrbool
		,delinqprofiles         typedelinqprofilearrbycurr
		,defaultriskgroup       NUMBER
		,readsetupscheme_called BOOLEAN := FALSE);
	TYPE typecontrtypeparams_cache_arr IS TABLE OF typecontrtypeparams_cache_rec INDEX BY PLS_INTEGER;
	scontrtype_cache typecontrtypeparams_cache_arr;

	SUBTYPE typemethodname IS VARCHAR2(200);

	cintaccmode_donotaccumulate CONSTANT PLS_INTEGER := 0;
	cintaccmode_bankincomeacc   CONSTANT PLS_INTEGER := 1;
	cintaccmode_intaccbalance   CONSTANT PLS_INTEGER := 2;
	excothererror EXCEPTION;

	TYPE typeitemrecord IS RECORD(
		 dep NUMBER
		,ovd NUMBER
		,INT NUMBER);
	TYPE typeitemarray IS TABLE OF typeitemrecord INDEX BY PLS_INTEGER;
	sitem typeitemarray;
	cp_lastodfee    CONSTANT PLS_INTEGER := 01;
	cp_lastdocno    CONSTANT PLS_INTEGER := 02;
	cp_limit        CONSTANT PLS_INTEGER := 03;
	cp_pbaccount    CONSTANT PLS_INTEGER := 04;
	cp_payaccount   CONSTANT PLS_INTEGER := 05;
	cp_payamount    CONSTANT PLS_INTEGER := 06;
	cp_profile      CONSTANT PLS_INTEGER := 07;
	cp_mpprofile    CONSTANT PLS_INTEGER := 08;
	cp_fixprofile   CONSTANT PLS_INTEGER := 09;
	cp_fixmpprofile CONSTANT PLS_INTEGER := 10;
	cp_accoltype    CONSTANT PLS_INTEGER := 11;
	cp_accolamount  CONSTANT PLS_INTEGER := 12;
	cp_accolprc     CONSTANT PLS_INTEGER := 13;
	cp_accstatus    CONSTANT PLS_INTEGER := 14;
	cp_paydate      CONSTANT PLS_INTEGER := 15;
	cp_inttoinston  CONSTANT PLS_INTEGER := 16;

	cp_cardlock          CONSTANT PLS_INTEGER := 01;
	cp_chaccstatus       CONSTANT PLS_INTEGER := 02;
	cp_zerompcycles      CONSTANT PLS_INTEGER := 03;
	cp_useshield         CONSTANT PLS_INTEGER := 04;
	cp_nextstmtdate      CONSTANT PLS_INTEGER := 05;
	cp_closedocno        CONSTANT PLS_INTEGER := 06;
	cp_closepackno       CONSTANT PLS_INTEGER := 07;
	cp_gendaf            CONSTANT PLS_INTEGER := 08;
	cp_lastadpackno      CONSTANT PLS_INTEGER := 09;
	cp_delcycle4dc       CONSTANT PLS_INTEGER := 10;
	cp_dclasttime        CONSTANT PLS_INTEGER := 11;
	cp_billcyclecalendar CONSTANT PLS_INTEGER := 12;
	cp_ovdperiodcalcmode CONSTANT PLS_INTEGER := 13;
	cp_ovdperioddatefrom CONSTANT PLS_INTEGER := 14;
	cp_ovdperioddateto   CONSTANT PLS_INTEGER := 15;

	cmp0_count          CONSTANT NUMBER := 1;
	cmp0_dontcount      CONSTANT NUMBER := 2;
	cmp0_restart        CONSTANT NUMBER := 3;
	covdcalc_normal     CONSTANT PLS_INTEGER := 1;
	covdcalc_frzwithrep CONSTANT PLS_INTEGER := 2;
	covdcalc_frzworep   CONSTANT PLS_INTEGER := 3;

	cctp_usecur                      CONSTANT PLS_INTEGER := 01;
	cctp_profile                     CONSTANT PLS_INTEGER := 02;
	cctp_mpprofile                   CONSTANT PLS_INTEGER := 03;
	cctp_pblimit                     CONSTANT PLS_INTEGER := 04;
	cctp_acccredlimitmin             CONSTANT PLS_INTEGER := 05;
	cctp_acccredlimitmax             CONSTANT PLS_INTEGER := 06;
	cctp_acccashlimitpbtype          CONSTANT PLS_INTEGER := 07;
	cctp_pricardlimitmax             CONSTANT PLS_INTEGER := 08;
	cctp_prilimitbpuse               CONSTANT PLS_INTEGER := 09;
	cctp_pricashlimitpbtype          CONSTANT PLS_INTEGER := 10;
	cctp_supcardlimitmax             CONSTANT PLS_INTEGER := 11;
	cctp_suplimitbpuse               CONSTANT PLS_INTEGER := 12;
	cctp_supcashlimitpbtype          CONSTANT PLS_INTEGER := 13;
	cctp_shieldtype                  CONSTANT PLS_INTEGER := 14;
	cctp_shieldamount                CONSTANT PLS_INTEGER := 15;
	cctp_shieldprc                   CONSTANT PLS_INTEGER := 16;
	cctp_proshieldtype               CONSTANT PLS_INTEGER := 17;
	cctp_proshieldamount             CONSTANT PLS_INTEGER := 18;
	cctp_proshieldprc                CONSTANT PLS_INTEGER := 19;
	cctp_proshieldclnd               CONSTANT PLS_INTEGER := 20;
	cctp_proshieldcycles             CONSTANT PLS_INTEGER := 21;
	cctp_proshielddoboth             CONSTANT PLS_INTEGER := 22;
	cctp_shieldcalctype              CONSTANT PLS_INTEGER := 23;
	cctp_shieldplsql                 CONSTANT PLS_INTEGER := 24;
	cctp_shieldacc                   CONSTANT PLS_INTEGER := 25;
	cctp_stmtfeeamount               CONSTANT PLS_INTEGER := 26;
	cctp_stmtfeeacc                  CONSTANT PLS_INTEGER := 27;
	cctp_accoltype                   CONSTANT PLS_INTEGER := 28;
	cctp_accolamount                 CONSTANT PLS_INTEGER := 29;
	cctp_accolprc                    CONSTANT PLS_INTEGER := 30;
	cctp_shieldwhentocharge          CONSTANT PLS_INTEGER := 31;
	cctp_shieldcertainday            CONSTANT PLS_INTEGER := 32;
	cctp_shieldbaseamount            CONSTANT PLS_INTEGER := 33;
	cctp_shieldcalcmethod            CONSTANT PLS_INTEGER := 34;
	cctp_rangeshieldprc              CONSTANT PLS_INTEGER := 35;
	cctp_rangeshieldamount           CONSTANT PLS_INTEGER := 36;
	cctp_installmentonfee            CONSTANT PLS_INTEGER := 37;
	cctp_instonfeecalc               CONSTANT PLS_INTEGER := 38;
	cctp_instonfeeacc                CONSTANT PLS_INTEGER := 39;
	cctp_inttoinston                 CONSTANT PLS_INTEGER := 40;
	cctp_inttoinstfrom               CONSTANT PLS_INTEGER := 41;
	cctp_inttoinstto                 CONSTANT PLS_INTEGER := 42;
	cctp_inttoinstct                 CONSTANT PLS_INTEGER := 43;
	cctp_debttoinston                CONSTANT PLS_INTEGER := 44;
	cctp_debttoinstct                CONSTANT PLS_INTEGER := 45;
	cctp_stmntfeecalctype            CONSTANT PLS_INTEGER := 46;
	cctp_stmntfeeprcnt               CONSTANT PLS_INTEGER := 47;
	cctp_supamnttoshieldbaseamount   CONSTANT PLS_INTEGER := 48;
	cctp_monthlyfeeprof              CONSTANT PLS_INTEGER := 49;
	cctp_priincrscrdlimbyallwovl     CONSTANT PLS_INTEGER := 50;
	cctp_supincrscrdlimbyallwovl     CONSTANT PLS_INTEGER := 51;
	cctp_priincrscashlimbyallwovl    CONSTANT PLS_INTEGER := 52;
	cctp_supincrscashlimbyallwovl    CONSTANT PLS_INTEGER := 53;
	cctp_accincrscashlimbyallwovl    CONSTANT PLS_INTEGER := 54;
	cctp_gst_profileid               CONSTANT PLS_INTEGER := 55;
	cctp_lcf_acccredlmtprofileid     CONSTANT PLS_INTEGER := 56;
	cctp_lcf_acccredtemplmtprofileid CONSTANT PLS_INTEGER := 57;

	cctp_exchangerate      CONSTANT PLS_INTEGER := 01;
	cctp_intlog            CONSTANT PLS_INTEGER := 02;
	cctp_correction        CONSTANT PLS_INTEGER := 03;
	cctp_stmttype          CONSTANT PLS_INTEGER := 04;
	cctp_stmtfolder        CONSTANT PLS_INTEGER := 05;
	cctp_stmtmode          CONSTANT PLS_INTEGER := 06;
	cctp_promtext          CONSTANT PLS_INTEGER := 07;
	cctp_stmttrns          CONSTANT PLS_INTEGER := 08;
	cctp_corpmode          CONSTANT PLS_INTEGER := 09;
	cctp_calendarid        CONSTANT PLS_INTEGER := 10;
	cctp_usedaf            CONSTANT PLS_INTEGER := 11;
	cctp_dafreport         CONSTANT PLS_INTEGER := 12;
	cctp_outpath           CONSTANT PLS_INTEGER := 13;
	cctp_useinst           CONSTANT PLS_INTEGER := 14;
	cctp_instaddpay        CONSTANT PLS_INTEGER := 15;
	cctp_instaddacc        CONSTANT PLS_INTEGER := 16;
	cctp_instaddint        CONSTANT PLS_INTEGER := 17;
	cctp_instdooneentry    CONSTANT PLS_INTEGER := 18;
	cctp_shieldchargemode  CONSTANT PLS_INTEGER := 19;
	cctp_shieldcalendar    CONSTANT PLS_INTEGER := 20;
	cctp_defstate          CONSTANT PLS_INTEGER := 21;
	cctp_periodtype        CONSTANT PLS_INTEGER := 22;
	cctp_overlimittype     CONSTANT PLS_INTEGER := 23;
	cctp_instdepend        CONSTANT PLS_INTEGER := 24;
	cctp_dafgen4ctype      CONSTANT PLS_INTEGER := 25;
	cctp_stmntpl_sql       CONSTANT PLS_INTEGER := 26;
	cctp_overdueamountcurr CONSTANT PLS_INTEGER := 27;
	cctp_ovdperiodcalcmode CONSTANT PLS_INTEGER := 28;
	cctp_ovdperioddatefrom CONSTANT PLS_INTEGER := 29;
	cctp_ovdperioddateto   CONSTANT PLS_INTEGER := 30;

	scycleinfoloaded    BOOLEAN := FALSE;
	scurrentcycle       typebillingcycle;
	spreviouscycle      typebillingcycle;
	scurrentmp          types.arrnum;
	snextduedate        DATE;
	sprcchargedom       typeprcchargearray;
	scorpcontractnumber typecontractno;
	scorpnumberloaded   BOOLEAN;
	smulticurrency      BOOLEAN;
	smulticurrencyrate  types.arrnum;
	spaidhistarray      typepaidhistcurrarray;

	cacp_ident CONSTANT tblschitem := tblschitem(recschitem(cp_cardlock
														   ,'CardLock'
														   ,''
														   ,''
														   ,custom_contracttools.cboth
														   ,custom_contracttools.coptional
														   ,NULL
														   ,3
														   ,0)
												,recschitem(cp_chaccstatus
														   ,'ChangeAccStatus'
														   ,''
														   ,''
														   ,custom_contracttools.cboth
														   ,custom_contracttools.coptional
														   ,NULL
														   ,2
														   ,0)
												,recschitem(cp_zerompcycles
														   ,'ZeroMPCycles'
														   ,''
														   ,''
														   ,custom_contracttools.cboth
														   ,custom_contracttools.coptional
														   ,NULL
														   ,cmp0_count
														   ,0)
												,recschitem(cp_useshield
														   ,'UseShield'
														   ,''
														   ,''
														   ,custom_contracttools.ccont
														   ,custom_contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL)
												,recschitem(cp_nextstmtdate
														   ,'NextStmtDate'
														   ,''
														   ,''
														   ,custom_contracttools.ccont
														   ,custom_contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cp_closedocno
														   ,'CloseDocNo'
														   ,''
														   ,''
														   ,custom_contracttools.ccont
														   ,custom_contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cp_closepackno
														   ,'ClosePackNo'
														   ,''
														   ,''
														   ,custom_contracttools.ccont
														   ,custom_contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cp_gendaf
														   ,'GenDAF'
														   ,''
														   ,''
														   ,custom_contracttools.ccont
														   ,custom_contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL)
												,recschitem(cp_lastadpackno
														   ,'LastAdPackNo'
														   ,''
														   ,''
														   ,custom_contracttools.ccont
														   ,custom_contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL)
												,recschitem(cp_delcycle4dc
														   ,'DelCycle4DC'
														   ,''
														   ,''
														   ,custom_contracttools.ccont
														   ,custom_contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL)
												,recschitem(cp_dclasttime
														   ,'DCLastTimeSendData'
														   ,''
														   ,''
														   ,custom_contracttools.ccont
														   ,custom_contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL)
												,recschitem(cp_billcyclecalendar
														   ,'BillCycleCalendar'
														   ,''
														   ,''
														   ,custom_contracttools.ccont
														   ,custom_contracttools.coptional
														   ,-1
														   ,NULL
														   ,NULL)
												,recschitem(cp_ovdperiodcalcmode
														   ,'OvdPeriodCalcMode'
														   ,''
														   ,''
														   ,custom_contracttools.cboth
														   ,custom_contracttools.cmandatory
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cp_ovdperioddatefrom
														   ,'OvdPeriodDateFrom'
														   ,''
														   ,''
														   ,custom_contracttools.cboth
														   ,custom_contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cp_ovdperioddateto
														   ,'OvdPeriodDateTo'
														   ,''
														   ,''
														   ,custom_contracttools.cboth
														   ,custom_contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL)
												 
												 );

	cacontrpint_ident CONSTANT tblschitem := tblschitem(recschitem(cp_lastodfee
																  ,'Last_Overdue_Fee_2'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_lastdocno
																  ,'LastDocNo_2'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,0
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_limit
																  ,'Limit2'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_pbaccount
																  ,'AccountINT'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_payaccount
																  ,'PayAccountINT'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_payamount
																  ,'PayAmountINT'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,1
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_profile
																  ,'ProfileINT'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_mpprofile
																  ,'MPProfileINT'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_fixprofile
																  ,'FixProfileINT'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,0
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_fixmpprofile
																  ,'FixMPProfileINT'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,0
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_accoltype
																  ,'AccOverLimitTypeINT'
																  ,''
																  ,''
																  ,contracttools.cboth
																  ,contracttools.coptional
																  ,NULL
																  ,NULL
																  ,-1)
													   ,recschitem(cp_accolamount
																  ,'AccOverLimitAmountINT'
																  ,''
																  ,''
																  ,contracttools.cboth
																  ,contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_accolprc
																  ,'AccOverLimitPrcINT'
																  ,''
																  ,''
																  ,contracttools.cboth
																  ,contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_accstatus
																  ,'Acc_Status_2'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_paydate
																  ,'PayDate_2'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_inttoinston
																  ,'IntToInstOnINT'
																  ,''
																  ,''
																  ,contracttools.ccont
																  ,contracttools.coptional
																  ,0
																  ,NULL
																  ,NULL));

	cacontrpdom_ident CONSTANT tblschitem := tblschitem(recschitem(cp_lastodfee
																   
																  ,'Last_Overdue_Fee_1'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_lastdocno
																  ,'LastDocNo_1'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,0
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_limit
																  ,'Limit1'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_pbaccount
																  ,'AccountDOM'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_payaccount
																  ,'PayAccountDOM'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_payamount
																  ,'PayAmountDOM'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,1
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_profile
																  ,'ProfileDOM'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_mpprofile
																  ,'MPProfileDOM'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_fixprofile
																  ,'FixProfileDOM'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,0
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_fixmpprofile
																  ,'FixMPProfileDOM'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,0
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_accoltype
																  ,'AccOverLimitTypeDOM'
																  ,''
																  ,''
																  ,custom_contracttools.cboth
																  ,custom_contracttools.coptional
																  ,NULL
																  ,NULL
																  ,-1)
													   ,recschitem(cp_accolamount
																  ,'AccOverLimitAmountDOM'
																  ,''
																  ,''
																  ,custom_contracttools.cboth
																  ,custom_contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_accolprc
																  ,'AccOverLimitPrcDOM'
																  ,''
																  ,''
																  ,custom_contracttools.cboth
																  ,custom_contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_accstatus
																  ,'Acc_Status_1'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_paydate
																  ,'PayDate_1'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,NULL
																  ,NULL
																  ,NULL)
													   ,recschitem(cp_inttoinston
																  ,'IntToInstOnDOM'
																  ,''
																  ,''
																  ,custom_contracttools.ccont
																  ,custom_contracttools.coptional
																  ,0
																  ,NULL
																  ,NULL));

	FUNCTION getamnthistory
	
	(
		pcurno   IN NUMBER
	   ,penddate DATE := NULL
	) RETURN typeamnthistoryarray;

	FUNCTION ifcurrencyisusedintype
	
	(
		pcurno        IN NUMBER
	   ,pcontracttype IN typecontracttype := NULL
	   ,pcontractno   IN typecontractno := NULL
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := 'custom_sch_customer_1' || '.IfCurrencyIsUsedInType';
		vcontracttype typecontracttype;
		vresult       BOOLEAN;
	BEGIN
		t.enter(cmethodname
			   ,'pCurNo = ' || pcurno || ', pContractType = ' || pcontracttype ||
				', pContractNo = ' || pcontractno);
	
		IF pcontracttype IS NOT NULL
		THEN
			vcontracttype := pcontracttype;
		ELSIF pcontractno IS NOT NULL
		THEN
			vcontracttype := contract.gettype(pcontractno);
		ELSE
			error.raiseerror('Internal error: pContractType and pContractNo can not be NULL simultaneously');
		END IF;
	
		t.var('Selected ContractType', vcontracttype);
	
		IF scontrtype_cache.exists(vcontracttype)
		   AND scontrtype_cache(vcontracttype).usedcurrency.exists(1)
		THEN
			s.say(cmethodname || '     - info: data are going to be taken from CACHE');
		ELSE
			s.say(cmethodname ||
				  '     - info: data in cache has not existed. Data are going to be read from DISC');
			scontrtype_cache(vcontracttype).usedcurrency(1) := nvl(contractparams.loadbool(contractparams.ccontracttype
																						  ,vcontracttype
																						  ,'UseCurDOM'
																						  ,FALSE)
																  ,FALSE);
			scontrtype_cache(vcontracttype).usedcurrency(2) := nvl(contractparams.loadbool(contractparams.ccontracttype
																						  ,vcontracttype
																						  ,'UseCurINT'
																						  ,FALSE)
																  ,FALSE);
		END IF;
	
		vresult := scontrtype_cache(vcontracttype).usedcurrency(pcurno);
	
		t.leave(cmethodname, htools.b2s(vresult));
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END ifcurrencyisusedintype;

	FUNCTION getlimittype_int(pcontractno IN typecontractno) RETURN PLS_INTEGER;

	FUNCTION getlimittype_int(pcontractno IN typecontractno) RETURN PLS_INTEGER IS
		cmethodname CONSTANT typemethodname := cpackagename || '.GetLimitType_Int';
		vresult PLS_INTEGER;
	
		PROCEDURE getdata
		(
			pcurno     IN NUMBER
		   ,oacardlist OUT NOCOPY custom_api_type.typeaccount2cardlist
		   ,ocardcount OUT NUMBER
		) IS
			cmethodname CONSTANT typemethodname := getlimittype_int.cmethodname || '.GetData';
		BEGIN
			t.enter(cmethodname, pcurno);
		
			IF ifcurrencyisusedintype(pcurno, contracttypeschema.scontractrow.type, pcontractno)
			   AND sdepaccount.exists(pcurno)
			THEN
				oacardlist := custom_accounts.getcardlist(sdepaccount(pcurno).accountno);
				ocardcount := oacardlist.count +
							  customer.getcustomercount(sdepaccount(pcurno).accountno);
			ELSE
				oacardlist.delete;
				ocardcount := 0;
			END IF;
		
			t.leave(cmethodname, ocardcount);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethodname);
				error.save(cmethodname);
				RAISE;
		END getdata;
	
	BEGIN
		t.enter(cmethodname, pcontractno);
	
		getdata(1, scardlist1, scardcount1);
		--getdata(2, scardlist2, scardcount2);
	
		IF (scardcount1 = 0)
		   AND (scardcount2 = 0)
		THEN
			vresult := cnotdefined;
		
		ELSIF ifcurrencyisusedintype(1, contracttypeschema.scontractrow.type, pcontractno)
			  AND ifcurrencyisusedintype(2, contracttypeschema.scontractrow.type, pcontractno)
		THEN
		
			vresult := service.iif(((scardcount1 > 0) AND (scardcount2 > 0)), cseparate, caggregate);
		ELSE
		
			vresult := cnotused;
		END IF;
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getlimittype_int;

	/*
        FUNCTION ifcurrencyisusedintype
        
        (
            pcurno        IN NUMBER
           ,pcontracttype IN typecontracttype := NULL
           ,pcontractno   IN typecontractno := NULL
        ) RETURN BOOLEAN IS
            cmethodname CONSTANT typemethodname := cpackagename || '.IfCurrencyIsUsedInType';
            vcontracttype typecontracttype;
            vresult       BOOLEAN;
        BEGIN
            t.enter(cmethodname
                   ,'pCurNo = ' || pcurno || ', pContractType = ' || pcontracttype ||
                    ', pContractNo = ' || pcontractno);
        
            IF pcontracttype IS NOT NULL
            THEN
                vcontracttype := pcontracttype;
            ELSIF pcontractno IS NOT NULL
            THEN
                vcontracttype := contract.gettype(pcontractno);
            ELSE
                error.raiseerror('Internal error: pContractType and pContractNo can not be NULL simultaneously');
            END IF;
        
            t.var('Selected ContractType', vcontracttype);
        
            IF scontrtype_cache.exists(vcontracttype)
               AND scontrtype_cache(vcontracttype).usedcurrency.exists(1)
            THEN
                s.say(cmethodname || '     - info: data are going to be taken from CACHE');
            ELSE
                s.say(cmethodname ||
                      '     - info: data in cache has not existed. Data are going to be read from DISC');
                scontrtype_cache(vcontracttype).usedcurrency(1) := nvl(contractparams.loadbool(contractparams.ccontracttype
                                                                                              ,vcontracttype
                                                                                              ,'UseCurDOM'
                                                                                              ,FALSE)
                                                                      ,FALSE);
                scontrtype_cache(vcontracttype).usedcurrency(2) := nvl(contractparams.loadbool(contractparams.ccontracttype
                                                                                              ,vcontracttype
                                                                                              ,'UseCurINT'
                                                                                              ,FALSE)
                                                                      ,FALSE);
            END IF;
        
            vresult := scontrtype_cache(vcontracttype).usedcurrency(pcurno);
        
            t.leave(cmethodname, htools.b2s(vresult));
            RETURN vresult;
        EXCEPTION
            WHEN OTHERS THEN
                t.exc(cmethodname);
                error.save(cmethodname);
                RAISE;
        END ifcurrencyisusedintype;
    */
	PROCEDURE getriskgroup
	(
		plastregovdperiod tcontractstatehistory.calculatedovdperiodinterval%TYPE
	   ,plastregoverlimit tcontractstatehistory.overlimit%TYPE
	   ,
		
		pcurrentovdperiod tcontractstatehistory.overdue%TYPE
	   ,pcurrentovdamount NUMBER
	   ,pcurrentoverlimit tcontractstatehistory.overlimit%TYPE
	   ,
		
		olastreggroupindex OUT NUMBER
	   ,ocurrentgroupindex OUT NUMBER
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetRiskGroup';
	
		vlastreggroup_periodindex NUMBER;
	
		vifoveduewaspaidwithinstate BOOLEAN := FALSE;
		vifovdthresholdwasexceeded  BOOLEAN := TRUE;
	
		vindexfornegativeperiod NUMBER := 1;
		vfoundnegativeperiod    NUMBER;
	
	BEGIN
		s.say(cmethodname || '    --<< BEGIN');
		s.say(cmethodname || '      - INPUT PARAMETERS: ');
		s.say(cmethodname ||
			  '           Last registered group: Overdue period (pLastRegOvdPeriod) = ' ||
			  plastregovdperiod || ', Overlimit (pLastRegOverLimit) = ' || plastregoverlimit);
		s.say(cmethodname || '           Current group: Overdue period (pCurrentOvdPeriod) = ' ||
			  pcurrentovdperiod || ', Overdue amount (pCurrentOvdAmount) = ' || pcurrentovdamount ||
			  ', Overlimit (pCurrentOverlimit) = ' || pcurrentoverlimit);
		s.say(cmethodname || '');
	
		s.say(cmethodname || '');
		s.say(cmethodname ||
			  '             - info: LAST REGISTERED DELINQUENCY GROUP INDEX IS GOING TO BE CALCULATED');
	
		FOR i IN REVERSE 1 .. sdelstatus.count
		LOOP
		
			IF nvl(plastregovdperiod, -0.75) > -0.75
			   AND sdelstatus(i).period > -0.75
			THEN
				s.say(cmethodname || '              Delinquency group index (i) = ' || i ||
					  ', Ovd period (sDelStatus(i).Period) = ' || sdelstatus(i).period ||
					  ', Overlimit (sDelStatus(i).OverLimit) = ' || sdelstatus(i).overlimit);
				IF nvl(plastregovdperiod, -0.75) >= sdelstatus(i).period
				   AND nvl(plastregoverlimit, 0) >= sdelstatus(i).overlimit
				THEN
					olastreggroupindex        := i;
					vlastreggroup_periodindex := sdelstatus(i).period;
					s.say(cmethodname || '                - info: exit point 1');
					EXIT;
				END IF;
			
			ELSIF nvl(plastregovdperiod, -0.75) <= -0.75
				  AND sdelstatus(i).period <= -0.75
			THEN
			
				s.say(cmethodname ||
					  '                      Delinquency group index (vIndexForNegativePeriod) = ' ||
					  vindexfornegativeperiod ||
					  ', Ovd period (sDelStatus(vIndexForNegativePeriod).Period) = ' || sdelstatus(vindexfornegativeperiod)
					  .period ||
					  ', Ovl amount ( sDelStatus(vIndexForNegativePeriod).OverLimit ) = ' || sdelstatus(vindexfornegativeperiod)
					  .overlimit);
			
				IF -nvl(plastregovdperiod, -0.75) >= -sdelstatus(vindexfornegativeperiod).period
				   AND nvl(plastregoverlimit, 0) >= sdelstatus(vindexfornegativeperiod).overlimit
				   AND (vfoundnegativeperiod IS NULL OR
						vfoundnegativeperiod = sdelstatus(vindexfornegativeperiod).period)
				THEN
					vfoundnegativeperiod      := sdelstatus(vindexfornegativeperiod).period;
					vlastreggroup_periodindex := sdelstatus(vindexfornegativeperiod).period;
					olastreggroupindex        := vindexfornegativeperiod;
				END IF;
			
				s.say(cmethodname || '                      vFoundNegativePeriod = ' ||
					  vfoundnegativeperiod);
				IF vfoundnegativeperiod IS NOT NULL
				   AND vfoundnegativeperiod <> sdelstatus(vindexfornegativeperiod).period
				THEN
					s.say(cmethodname || '                - info: exit point 2');
					EXIT;
				END IF;
			
				vindexfornegativeperiod := vindexfornegativeperiod + 1;
			
			END IF;
		END LOOP;
		s.say(cmethodname ||
			  '              Last registered group period index (vLastRegGroup_PeriodIndex) = ' ||
			  vlastreggroup_periodindex);
		s.say(cmethodname || '              oLastRegGroupIndex = ' || olastreggroupindex);
	
		s.say(cmethodname || '');
		s.say(cmethodname ||
			  '             - info: CURRENT DELINQUENCY GROUP INDEX IS GOING TO BE CALCULATED');
	
		vindexfornegativeperiod := 1;
		vfoundnegativeperiod    := NULL;
	
		FOR i IN REVERSE 1 .. sdelstatus.count
		LOOP
			IF nvl(pcurrentovdperiod, -0.75) <= -0.75
			   AND sdelstatus(i).period <= -0.75
			THEN
			
				s.say(cmethodname ||
					  '                      Delinquency group index (vIndexForNegativePeriod) = ' ||
					  vindexfornegativeperiod ||
					  ', Ovd period (sDelStatus(vIndexForNegativePeriod).Period) = ' || sdelstatus(vindexfornegativeperiod)
					  .period ||
					  ', Ovl amount ( sDelStatus(vIndexForNegativePeriod).OverLimit ) = ' || sdelstatus(vindexfornegativeperiod)
					  .overlimit);
				IF -nvl(pcurrentovdperiod, -0.75) >= -sdelstatus(vindexfornegativeperiod).period
				   AND nvl(pcurrentoverlimit, 0) >= sdelstatus(vindexfornegativeperiod).overlimit
				   AND (vfoundnegativeperiod IS NULL OR
						vfoundnegativeperiod = sdelstatus(vindexfornegativeperiod).period)
				THEN
					vfoundnegativeperiod       := sdelstatus(vindexfornegativeperiod).period;
					ocurrentgroupindex         := vindexfornegativeperiod;
					vifovdthresholdwasexceeded := NULL;
				END IF;
			
				s.say(cmethodname || '                      vFoundNegativePeriod = ' ||
					  vfoundnegativeperiod);
				IF vfoundnegativeperiod IS NOT NULL
				   AND vfoundnegativeperiod <> sdelstatus(vindexfornegativeperiod).period
				THEN
					s.say(cmethodname || '                - info: exit point 3');
					EXIT;
				END IF;
			
				vindexfornegativeperiod := vindexfornegativeperiod + 1;
			
			ELSIF nvl(pcurrentovdperiod, -0.75) > -0.75
				  AND sdelstatus(i).period >= -0.75
			THEN
				s.say(cmethodname || '              Delinquency group index (i) = ' || i ||
					  ', Ovd period (sDelStatus(i).Period) = ' || sdelstatus(i).period ||
					  ', Overlimit (sDelStatus(i).OverLimit) = ' || sdelstatus(i).overlimit);
				IF nvl(pcurrentovdperiod, -0.75) >= sdelstatus(i).period
				THEN
					IF nvl(pcurrentovdamount, -0.75) >= sdelstatus(i).overdueamount_threshold
					   AND nvl(pcurrentoverlimit, 0) >= sdelstatus(i).overlimit
					THEN
						ocurrentgroupindex := i;
						s.say(cmethodname || '                - info: exit point 4');
						EXIT;
					ELSIF nvl(pcurrentovdamount, -0.75) < sdelstatus(i).overdueamount_threshold
						  AND vlastreggroup_periodindex = sdelstatus(i).period
					THEN
						vifoveduewaspaidwithinstate := TRUE;
						vifovdthresholdwasexceeded  := FALSE;
						s.say(cmethodname || '                - info: preliminary exit point 5');
						EXIT;
					ELSIF nvl(pcurrentovdamount, -0.75) < sdelstatus(i).overdueamount_threshold
						  AND vlastreggroup_periodindex <> sdelstatus(i).period
					THEN
						vifovdthresholdwasexceeded := FALSE;
						s.say(cmethodname || '                - info: preliminary exit point 6');
						EXIT;
					END IF;
				END IF;
			END IF;
		END LOOP;
		s.say(cmethodname || '              vIfOvedueWasPaidWithinState = ' ||
			  service.iif(vifoveduewaspaidwithinstate, 'YES', 'NO'));
		s.say(cmethodname || '              vIfOvdThresholdWasExceeded = ' ||
			  service.iif(vifovdthresholdwasexceeded, 'YES', 'NO'));
		s.say(cmethodname ||
			  '              Preliminary current group index (oCurrentGroupIndex) = ' ||
			  ocurrentgroupindex ||
			  ', [if oCurrentGroupIndex is NULL then further analysis should be performed]');
	
		IF vifoveduewaspaidwithinstate
		   AND vifovdthresholdwasexceeded = FALSE
		THEN
			FOR i IN REVERSE 1 .. sdelstatus.count
			LOOP
				s.say(cmethodname || '               Delinquency group index (i) = ' || i);
				IF sdelstatus(i).period = -0.75
					AND nvl(pcurrentoverlimit, 0) >= sdelstatus(i).overlimit
				THEN
					ocurrentgroupindex := i;
					s.say(cmethodname || '                - info: exit point 7');
					EXIT;
				END IF;
			END LOOP;
		ELSIF vifovdthresholdwasexceeded = FALSE
		THEN
			FOR i IN REVERSE 1 .. sdelstatus.count
			LOOP
				s.say(cmethodname || '               Delinquency group index (i) = ' || i);
				IF sdelstatus(i).period = vlastreggroup_periodindex
					AND nvl(pcurrentoverlimit, 0) >= sdelstatus(i).overlimit
				THEN
					ocurrentgroupindex := i;
					s.say(cmethodname || '                - info: exit point 8');
					EXIT;
				END IF;
			END LOOP;
		END IF;
		s.say(cmethodname || '              Final current group index (oCurrentGroupIndex) = ' ||
			  ocurrentgroupindex);
	
		s.say(cmethodname || '    -->> END');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname || '.GetRiskGroup');
			RAISE;
	END getriskgroup;

	PROCEDURE resetcorpcontractnumber IS
		cmethodname CONSTANT typemethodname := cpackagename || '.ResetCorpContractNumber';
	BEGIN
		scorpcontractnumber := NULL;
		scorpnumberloaded   := FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END resetcorpcontractnumber;

	PROCEDURE getdelparameters(pdate IN DATE := NULL);

	PROCEDURE getdelparameters(pdate IN DATE := NULL) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.GetDelParameters';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		coperdate   CONSTANT DATE := seance.getoperdate;
		ccalcdate   CONSTANT DATE := coalesce(pdate, coperdate);
	
		voverdueamount      NUMBER := 0;
		vlastoverduepaydate DATE;
		voverduedate        DATE;
		voverduedayscount   NUMBER;
		vnooverduedayscount NUMBER;
	
		volpercenttotal          NUMBER := 0;
		volpercent               types.arrnum;
		vovdperiod               NUMBER;
		vlmtperiod               NUMBER;
		vovldays                 types.arrnum;
		vovldate                 types.arrdate;
		vamntarr                 typeamnthistoryarray;
		vmaxovldate              DATE := NULL;
		vmaxovldays              NUMBER := 0;
		vlmtused                 types.arrnum;
		vmaxlmtused              NUMBER := 0;
		vhasoverlimit            BOOLEAN := FALSE;
		vhasoverdue              BOOLEAN := FALSE;
		vpaiddelperiod           NUMBER;
		vlastzeromp              DATE;
		vprevstaterow            contractstatereference.typeregisteredstaterow;
		vcurr                    NUMBER;
		vprev                    NUMBER;
		vstickmode               NUMBER;
		vifaggrlimitisused       BOOLEAN;
		vaggrlimitamount         NUMBER := 0;
		vaggroverlimitamount     NUMBER := 0;
		vaggrcurrency            NUMBER := NULL;
		vaccountremain           NUMBER := 0;
		vaggrremain              NUMBER := 0;
		vconvertedamount         NUMBER := 0;
		voverdueparameters       custom_overdueparameterscalculation.typeoverdueparamsrecord;
		vfairperiod              NUMBER;
		voverduecalcspecmodeused BOOLEAN := FALSE;
		vovdperioddatefrom       DATE;
		vovdperioddateto         DATE;
		vadeldates               types.arrdate;
	
	BEGIN
		t.enter(cmethodname);
	
		IF NOT ifcurrencyisusedintype(contracttools.getvalidnumber(sactparam(cctp_overdueamountcurr)
																  ,'Overdue amount currency'
																  ,pallowedvalues => tblnumber(1, 2))
									 ,contracttypeschema.scontractrow.type
									 ,scontractno)
		THEN
			error.raiseerror('Overdue amount currency <' ||
							 slabel(sactparam(cctp_overdueamountcurr)) ||
							 '> is not used in contract type <' || scontracttype || '>!');
		END IF;
	
		FOR i IN 1 .. 2
		LOOP
		
			IF ifcurrencyisusedintype(i, contracttypeschema.scontractrow.type, scontractno)
			THEN
			
				spaidhistarray(i) := custom_overdueparameterscalculation.getoverdueparameters(sdepaccount(i)
																							  .accountno
																							 ,i
																							 ,ccalcdate
																							 ,sdelparam.overdueint
																							 ,voverdueparameters);
			
				sdeldate(i) := voverdueparameters.overduedate;
			
				vlastoverduepaydate := greatest(nvl(vlastoverduepaydate
												   ,voverdueparameters.mp_payoffdate)
											   ,voverdueparameters.mp_payoffdate);
			
				voverdueamount := voverdueamount +
								  contracttools.getsumincurrency(voverdueparameters.overdueamount
																,sdepaccount                     (i)
																 .currencyno
																,sdepaccount                     (sactparam(cctp_overdueamountcurr))
																 .currencyno);
			
			ELSE
				sdeldate(i) := NULL;
			END IF;
		
		END LOOP;
	
		voverduedate := least(nvl(sdeldate(1), ccalcdate), nvl(sdeldate(2), ccalcdate));
		t.var('OverdueDate', voverduedate);
	
		voverduedayscount := ccalcdate - voverduedate;
		t.var('vOverdue days count', voverduedayscount);
	
		t.var('Last overdue pay date', vlastoverduepaydate);
	
		IF ((vlastoverduepaydate IS NULL) AND (voverduedayscount < 0))
		   OR ((vlastoverduepaydate IS NOT NULL) AND (vlastoverduepaydate > ccalcdate))
		THEN
			vlastoverduepaydate := ccalcdate;
		END IF;
	
		vnooverduedayscount := ccalcdate - nvl(vlastoverduepaydate, ccalcdate);
		t.var('No-overdue days', vnooverduedayscount);
	
		vifaggrlimitisused := getlimittype_int(contracttypeschema.scontractrow.no) = caggregate;
		s.say(cmethodname || ' -> Whether aggregated credit limit is used (vIfAggrLimitIsUsed): ' ||
			  service.iif(vifaggrlimitisused, 'YES', 'NO'));
	
		IF vifaggrlimitisused
		THEN
			FOR i IN 1 .. 2
			LOOP
				s.say(cmethodname || '     currency: ------<' || i || '>------');
				IF ifcurrencyisusedintype(i, scontracttype, contracttypeschema.scontractrow.no)
				THEN
					s.say(cmethodname || '    -> Currency number sDepAccount.(' || i ||
						  ').CurrencyNo = ' || sdepaccount(i).currencyno);
				
					IF vaggrcurrency IS NULL
					THEN
						vaggrcurrency := sdepaccount(i).currencyno;
						s.say(cmethodname ||
							  '    -> AGGREGATED CURRENCY NUMBER. Taken from sDepAccount(' || i ||
							  ').CurrencyNo = ' || vaggrcurrency);
					END IF;
				
					s.say(cmethodname || '     -> Account Credit Limit Amount (sDepAccount(' || i ||
						  ').OverDraft) = ' || sdepaccount(i).overdraft);
					vconvertedamount := contracttools.getsumincurrency(sdepaccount  (i).overdraft
																	  ,sdepaccount  (i).currencyno
																	  ,vaggrcurrency);
					vaccountremain   := custom_contracttools.getsumincurrency(sdepaccount(i)
																			 ,vaggrcurrency);
				
					s.say(cmethodname ||
						  '     -> Converted Account Credit Limit Amount (vConvertedAmount) = ' ||
						  vconvertedamount);
					vaggrlimitamount := vaggrlimitamount + vconvertedamount;
					s.say(cmethodname || '     -> Converted Account Remain (vAccountRemain) = ' ||
						  vaccountremain);
					vaggrremain := vaggrremain + vaccountremain;
				END IF;
			
				IF sovdaccount(i).accountno IS NOT NULL
				THEN
					s.say(cmethodname || '     -> Overlimit Amount For (sOvdAccount (' || i ||
						  ').Remain) = ' || sovdaccount(i).remain);
					vconvertedamount := custom_contracttools.getsumincurrency(sovdaccount(i)
																			 ,vaggrcurrency);
					s.say(cmethodname ||
						  '     -> Converted Overlimit Amount (vConvertedAmount) = ' ||
						  vconvertedamount);
					vaggroverlimitamount := vaggroverlimitamount + vconvertedamount;
				END IF;
			
			END LOOP;
			s.say(cmethodname || ' -> AGGREGATED CREDIT LIMIT AMOUNT (vAggrLimitAmount) = ' ||
				  vaggrlimitamount);
			s.say(cmethodname || ' -> AGGREGATED OVERLIMIT AMOUNT (vAggrOverLimitAmount) = ' ||
				  vaggroverlimitamount);
			s.say(cmethodname || ' -> AGGREGATED REMAIN AMOUNT (vAggrRemain) = ' || vaggrremain);
		END IF;
	
		FOR i IN 1 .. 2
		LOOP
		
			vovldays(i) := 0;
			vovldate(i) := NULL;
			vlmtused(i) := 0;
		
			s.say(cmethodname || ' -> sOvdAccount (' || i || ').Remain = ' || sovdaccount(i)
				  .remain);
		
			IF (sovdaccount(i).remain < 0)
			   OR (vaggroverlimitamount <> 0)
			THEN
				vhasoverlimit := TRUE;
			END IF;
			s.say(cmethodname || ' -> Whether overlimit exists: ' ||
				  service.iif(vhasoverlimit, 'YES', 'NO'));
		
			IF (sdeldate(i) IS NOT NULL)
			THEN
				vhasoverdue := TRUE;
			END IF;
		
			IF NOT ifcurrencyisusedintype(i, scontracttype, contracttypeschema.scontractrow.no)
			THEN
				volpercent(i) := 0;
			ELSE
			
				IF NOT vifaggrlimitisused
				THEN
				
					IF sdepaccount(i).overdraft = 0
					THEN
						s.say(cmethodname || ' -> sDepAccount (' || i || ').OverDraft = ' || sdepaccount(i)
							  .overdraft);
						IF sovdaccount(i).remain < 0
						THEN
							volpercent(i) := 100;
							vlmtused(i) := 100;
						ELSE
							volpercent(i) := 0;
							vlmtused(i) := 0;
						END IF;
					
					ELSE
						volpercent(i) := abs(sovdaccount(i).remain) * 100 / sdepaccount(i)
										.overdraft;
						vlmtused(i) := greatest(-sdepaccount(i).remain, 0) * 100 / sdepaccount(i)
									  .overdraft;
						s.say(cmethodname || ' -> sOLPercent (' || i || ') = ' || volpercent(i));
						s.say(cmethodname || ' -> vLmtUsed (' || i || ') = ' || vlmtused(i));
					END IF;
				END IF;
				vamntarr := getamnthistory(i);
				FOR j IN REVERSE 1 .. vamntarr.count
				LOOP
					IF vamntarr(j).balance = 0
					THEN
						EXIT;
					END IF;
					vovldate(i) := vamntarr(j).operdate;
				END LOOP;
				IF vovldate(i) IS NOT NULL
				THEN
					vovldays(i) := greatest(ccalcdate - vovldate(i), 0);
				END IF;
			END IF;
			vmaxovldays := greatest(vovldays(i), vmaxovldays);
			IF vovldate(i) IS NOT NULL
			THEN
				vmaxovldate := least(nvl(vmaxovldate, vovldate(i)), vovldate(i));
			END IF;
			IF NOT vifaggrlimitisused
			THEN
				vmaxlmtused     := greatest(vmaxlmtused, vlmtused(i));
				volpercenttotal := greatest(volpercenttotal, volpercent(i));
			END IF;
		END LOOP;
	
		IF vifaggrlimitisused
		THEN
			IF vaggrlimitamount = 0
			   AND vaggrremain < 0
			THEN
				volpercenttotal := 100;
				vmaxlmtused     := 100;
			ELSIF vaggrremain >= 0
			THEN
				volpercenttotal := 0;
				vmaxlmtused     := 0;
			ELSE
				volpercenttotal := abs((vaggroverlimitamount / vaggrlimitamount) * 100);
				vmaxlmtused     := (greatest(-vaggrremain, 0) / vaggrlimitamount) * 100;
			END IF;
		END IF;
		s.say(cmethodname || ' -> sOLPercentTotal -> ' || volpercenttotal);
		s.say(cmethodname || ' -> vMaxLmtUsed -> ' || vmaxlmtused);
	
		IF sdelparam.overdueint IN (contractdelinqsetup.covdday, contractdelinqsetup.covdfirstday)
		THEN
		
			vovdperiod     := voverduedayscount;
			vpaiddelperiod := vnooverduedayscount;
		
		ELSIF sdelparam.overdueint IN
			  (contractdelinqsetup.covdcycle, contractdelinqsetup.covdfirstcycle)
		THEN
		
			SELECT COUNT(*)
			INTO   vovdperiod
			FROM   tcontractstcycle a
			WHERE  a.branch = cbranch
			AND    a.contractno = scontractno
			AND    a.lastduedate BETWEEN voverduedate AND ccalcdate;
		
			vovdperiod := greatest(vovdperiod - 1, 0);
		
			CASE sacparam(cp_zerompcycles)
			
				WHEN cmp0_count THEN
					s.say(cmethodname || ' -> cMP0_Count');
					SELECT COUNT(*)
					INTO   vpaiddelperiod
					FROM   tcontractstcycle a
					WHERE  a.branch = cbranch
					AND    a.contractno = scontractno
					AND    a.lastduedate BETWEEN nvl(vlastoverduepaydate, ccalcdate) AND ccalcdate;
				
				WHEN cmp0_dontcount THEN
					s.say(cmethodname || ' -> cMP0_DontCount');
					SELECT COUNT(*)
					INTO   vpaiddelperiod
					FROM   (SELECT c.branch
								  ,c.contractno
								  ,c.lastduedate
								  ,MAX(d.minpayment) AS mp
							FROM   tcontractstcycle c
							JOIN   tcontractstminpaymentdata d
							ON     d.branch = c.branch
							AND    d.screcno = c.recno
							WHERE  c.branch = cbranch
							AND    c.contractno = scontractno
							AND    c.lastduedate BETWEEN nvl(vlastoverduepaydate, ccalcdate) AND
								   ccalcdate
							GROUP  BY c.branch
									 ,c.contractno
									 ,c.lastduedate)
					WHERE  mp > 0;
				
				WHEN cmp0_restart THEN
					s.say(cmethodname || ' -> cMP0_Restart');
					SELECT MAX(lastduedate)
					INTO   vlastzeromp
					FROM   (SELECT c.branch
								  ,c.contractno
								  ,c.lastduedate
								  ,MAX(d.minpayment) AS mp
							FROM   tcontractstcycle c
							JOIN   tcontractstminpaymentdata d
							ON     d.branch = c.branch
							AND    d.screcno = c.recno
							WHERE  c.branch = cbranch
							AND    c.contractno = scontractno
							AND    c.lastduedate BETWEEN nvl(vlastoverduepaydate, ccalcdate) AND
								   ccalcdate
							GROUP  BY c.branch
									 ,c.contractno
									 ,c.lastduedate)
					WHERE  mp = 0;
					s.say(cmethodname || ' -> vLastZeroMP=' || vlastzeromp);
					SELECT COUNT(*)
					INTO   vpaiddelperiod
					FROM   tcontractstcycle a
					WHERE  a.branch = cbranch
					AND    a.contractno = scontractno
					AND    a.lastduedate BETWEEN greatest(vlastoverduepaydate, vlastzeromp + 1) AND
						   ccalcdate;
				
			END CASE;
		
		END IF;
	
		vfairperiod := vovdperiod;
	
		IF ((sacparam(cp_ovdperiodcalcmode) = covdcalc_frzwithrep) AND vhasoverdue)
		   OR (sacparam(cp_ovdperiodcalcmode) = covdcalc_frzworep)
		THEN
		
			vovdperioddatefrom := to_date(sacparam(cp_ovdperioddatefrom)
										 ,contractparams.cparam_date_format);
			vovdperioddateto   := to_date(sacparam(cp_ovdperioddateto)
										 ,contractparams.cparam_date_format);
		
			IF (sacparam(cp_ovdperiodcalcmode) = covdcalc_frzworep)
			   AND (voverduedate <= vovdperioddateto)
			THEN
			
				FOR i IN 1 .. 2
				LOOP
				
					IF ifcurrencyisusedintype(i, contracttypeschema.scontractrow.type, scontractno)
					THEN
						vdummypha := custom_overdueparameterscalculation.getoverdueparameters(sdepaccount(i)
																							  .accountno
																							 ,i
																							 ,vovdperioddatefrom
																							 ,sdelparam.overdueint
																							 ,voverdueparameters);
						vadeldates(i) := voverdueparameters.overduedate;
					ELSE
						vadeldates(i) := NULL;
					END IF;
				
					t.var('vOverdueParameters.OverdueDate', voverdueparameters.overduedate);
				
				END LOOP;
			
				voverduedate := least(nvl(vadeldates(1), vovdperioddatefrom)
									 ,nvl(vadeldates(2), vovdperioddatefrom));
			
				vovdperiod := ccalcdate - voverduedate;
			
			END IF;
		
			t.var('vOvdPeriodDateFrom', vovdperioddatefrom);
			t.var('vOverdueDate', voverduedate);
			t.var('vOvdPeriod', vovdperiod);
			t.var('cOperDate', coperdate);
		
			voverduecalcspecmodeused := voverduedate <= vovdperioddateto;
		
			t.var('vOverdueCalcSpecModeUsed', htools.b2s(voverduecalcspecmodeused));
		
			IF voverduecalcspecmodeused
			THEN
			
				IF coperdate < vovdperioddateto
				THEN
					vovdperiod := vovdperiod -
								  (coperdate - greatest(voverduedate, vovdperioddatefrom));
					t.var('vOvdPeriod1', vovdperiod);
				ELSE
					vovdperiod := vovdperiod -
								  (vovdperioddateto - greatest(voverduedate, vovdperioddatefrom));
					t.var('vOvdPeriod2', vovdperiod);
				END IF;
			
			END IF;
		
		END IF;
	
		s.say(cmethodname || ' -> OvdPeriod =' || vovdperiod);
		s.say(cmethodname || ' -> PaidDelPeriod =' || vpaiddelperiod);
	
		IF sdelparam.limitint = contractdelinqsetup.covloverprc
		THEN
			vlmtperiod := volpercenttotal;
		ELSIF sdelparam.limitint = contractdelinqsetup.covllimitprc
		THEN
			vlmtperiod := vmaxlmtused;
			IF vmaxlmtused > 0
			THEN
				vhasoverlimit := TRUE;
			END IF;
		ELSIF sdelparam.limitint = contractdelinqsetup.covloverday
		THEN
			vlmtperiod := vmaxovldays;
		ELSIF sdelparam.limitint = contractdelinqsetup.covlovercycle
		THEN
			IF vmaxovldays = 0
			THEN
				vlmtperiod := 0;
			ELSE
				SELECT COUNT(*) - 1
				INTO   vlmtperiod
				FROM   tcontractstcycle a
				WHERE  a.branch = cbranch
				AND    a.contractno = scontractno
				AND    a.statementdate BETWEEN vmaxovldate AND ccalcdate;
				vlmtperiod := greatest(vlmtperiod, 0);
			END IF;
		END IF;
		s.say(cmethodname || ' -> LmtPeriod =' || vlmtperiod);
	
		vprevstaterow := contractstatereference.getlastregisteredstate(scontractno);
		s.say(cmethodname || ' -> Last Registered State (vPrevStateRow.StateCode) = ' ||
			  vprevstaterow.statecode || ', vPrevStateRow.Overdue = ' || vprevstaterow.overdue
			 ,1);
		s.say(cmethodname || ' -> vPaidDelPeriod = ' || vpaiddelperiod || ', vDelDate = ' ||
			  voverduedate || ', vOvdPeriod = ' || vovdperiod
			 ,1);
	
		getriskgroup(plastregovdperiod => nvl(vprevstaterow.calculatedovdperiodinterval
											 ,vprevstaterow.overdue)
					,plastregoverlimit => nvl(vprevstaterow.overlimit, 0)
					,
					 
					 pcurrentovdperiod => CASE
										  
											  WHEN sdeldate(1) || sdeldate(2) IS NOT NULL THEN
											   vovdperiod
										  
											  WHEN vpaiddelperiod = 0
												   AND nvl(vprevstaterow.overdue, 0) >= 0 THEN
											   NULL
										  
											  ELSE
											   -vpaiddelperiod
										  
										  END
					,pcurrentovdamount => voverdueamount
					,pcurrentoverlimit => nvl(vlmtperiod, 0)
					,
					 
					 olastreggroupindex => vprev
					,ocurrentgroupindex => vcurr);
	
		IF vprevstaterow.statecode IS NULL
		THEN
		
			vprevstaterow.statecode := sdelstatus(scontrtype_cache(scontracttype).defaultriskgroup)
									   .state.statecode;
		END IF;
	
		IF (vprev IS NOT NULL)
		   AND (vprevstaterow.stickmode <> contractstatereference.cstickmanual)
		   AND sautounstick
		   AND (vprevstaterow.statecode = sdelstatus(vcurr).state.statecode)
		THEN
		
			s.say(cmethodname ||
				  ' ->  - info: Stick mode should be taken from previous state with it possbile settings change (sDelStatus(' ||
				  vprev || ').State.StickState) = ' || sdelstatus(vprev).state.stickstate);
			vstickmode := sdelstatus(vprev).state.stickstate;
		ELSE
		
			s.say(cmethodname ||
				  ' -> info: Stick mode should be taken from previous state "AS IS" NOT CONSIDERING possible settings change (vPrevStateRow.StickMode) = ' ||
				  vprevstaterow.stickmode);
			vstickmode := vprevstaterow.stickmode;
		END IF;
	
		s.say(cmethodname || ' -> Chosen stick mode (vStickMode) = ' || vstickmode ||
			  ', [0 - Don''t stick, 1 - Stick automatically, 2 - Stick below, 3 - Stick above, 4- Stick manually]');
	
		s.say(cmethodname || ' -> Last registered delinquency group index (vPrev) = ' || vprev);
		s.say(cmethodname || ' -> Last registered state code (vPrevStateRow.StateCode) = ' ||
			  vprevstaterow.statecode);
		s.say(cmethodname || ' -> Current delinquency group index (vCurr) = ' || vcurr);
	
		sblockparam := sdelstatus(vcurr);
	
		IF (vstickmode = contractstatereference.cdontstick)
		   OR (vstickmode = contractstatereference.cstickbelow)
		   AND (vprev < vcurr)
		   OR (vstickmode = contractstatereference.cstickabove)
		   AND (vprev > vcurr)
		THEN
		
			sblockparam.statechangeallowed := TRUE;
			s.say(cmethodname ||
				  '  - info: Delinquency state should be changed according to current delinquency group index');
		
			IF NOT vhasoverdue
			THEN
				vovdperiod   := nullif(-vpaiddelperiod, 0);
				vfairperiod  := nullif(-vpaiddelperiod, 0);
				voverduedate := NULL;
			END IF;
			IF NOT vhasoverlimit
			THEN
				vlmtperiod := NULL;
			END IF;
		
		ELSE
		
			sblockparam.statechangeallowed := FALSE;
			s.say(cmethodname ||
				  ' - info: Last registered delinquency state should NOT be changed');
		
			sblockparam.stateid := contractstatereference.getstateid(vprevstaterow.statecode);
			sblockparam.state   := contractstatereference.getstate(sblockparam.stateid);
		END IF;
	
		s.say(cmethodname || ' -> Calculated state code (sBlockParam.State.StateCode) = ' ||
			  sblockparam.state.statecode);
	
		sblockparam.period                  := vovdperiod;
		sblockparam.fairperiod              := vfairperiod;
		sblockparam.deldate                 := voverduedate;
		sblockparam.overduecalcspecmodeused := voverduecalcspecmodeused;
		sblockparam.overduecalctype         := sactparam(cctp_periodtype);
		sblockparam.overlimitcalctype       := sactparam(cctp_overlimittype);
		sblockparam.overlimit               := vlmtperiod;
		sblockparam.aggregatedoverdueamount := voverdueamount;
		sblockparam.lastreggroupindex       := vprev;
		sblockparam.currentgroupindex       := vcurr;
		sblockparam.lastregisteredstatecode := vprevstaterow.statecode;
		sblockparam.lastregisteredstickmode := vprevstaterow.stickmode;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getdelparameters;

	PROCEDURE loadparam
	(
		pcno         typecontractno
	   ,paitem       tblschitem
	   ,pactparam    types.arrstr1000
	   ,oacparam     IN OUT NOCOPY types.arrstr1000
	   ,pdoexception BOOLEAN := TRUE
	) IS
		cmethod_name CONSTANT VARCHAR2(80) := 'custom_sch_customer_1' || '.LoadParam[contract]';
		cbranch      CONSTANT NUMBER := seance.getbranch;
		verrmsg VARCHAR2(4000) := NULL;
	BEGIN
		s.say(cmethod_name || ': BEGIN for contract ' || pcno);
	
		SELECT /*+ ORDERED USE_NL (p) INDEX (p pk_CNoParameters) */
		 nvl(p.value, d.attr3) BULK COLLECT
		INTO   oacparam
		FROM   TABLE(paitem) d
		LEFT   OUTER JOIN tcontractparameters p
		ON     p.branch = cbranch
		AND    p.contractno = pcno
		AND    p.key = upper(d.name)
		ORDER  BY d.idx;
	
		FOR i IN 1 .. oacparam.count
		LOOP
			IF (oacparam(i) IS NULL OR
			   (paitem(i).attr5 IS NOT NULL AND oacparam(i) = paitem(i).attr5))
			   AND pactparam.exists(i)
			THEN
				oacparam(i) := pactparam(i);
			END IF;
		END LOOP;
	
		s.say(cmethod_name || '     LOADED CONTRACT PARAMETERS:');
		FOR nn IN 1 .. paitem.count
		LOOP
			s.say(cmethod_name || '       name ( paItem(' || nn || ').name ) = ' || paitem(nn).name ||
				  ', value ( oaCParam(' || nn || ') )= ' || oacparam(nn));
		END LOOP;
	
		IF pdoexception
		THEN
			FOR i IN 1 .. paitem.count
			LOOP
			
				IF (paitem(i).attr1 IN (contracttools.ccont))
				   AND (paitem(i).attr2 = contracttools.cmandatory)
				   AND (oacparam(i) IS NULL)
				THEN
					verrmsg := verrmsg || ', ' || paitem(i).spec;
				END IF;
			END LOOP;
			IF verrmsg IS NOT NULL
			THEN
				error.raiseerror('Contract <' || pcno ||
								 '>: following parameters are not defined:' || substr(verrmsg, 2));
			END IF;
		END IF;
		s.say(cmethod_name || ': END for contract ' || pcno);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethod_name);
			RAISE;
	END;

	PROCEDURE fillmpprofilesettings(pmpprofileid IN tcontractmpprofile.profileid%TYPE) IS
		cmethodname CONSTANT VARCHAR2(80) := cpackagename || '.FillMPProfileSettings';
	BEGIN
		IF NOT smpprofile.exists(pmpprofileid)
		THEN
			smpprofile(pmpprofileid)(custom_contractprofiles.cp_mpp_base) := 2;
			custom_contractprofiles.getmpprofile(pmpprofileid, smpprofile(pmpprofileid));
			IF smpprofile(pmpprofileid)
			 (custom_contractprofiles.cp_mpp_base) = custom_contractprofiles.cmpbasegroup
			THEN
				smpgroupsettings(pmpprofileid)(0).prcvalue := 0;
				custom_contractprofiles.getmpgroupsettings(pmpprofileid
														  ,smpgroupsettings(pmpprofileid));
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END fillmpprofilesettings;

	PROCEDURE fillinterestprofsettings(pintprofileid IN tcontractprofile.profileid%TYPE) IS
		cmethodname CONSTANT VARCHAR2(80) := cpackagename || '.FillInterestProfSettings';
	BEGIN
		t.enter(cmethodname, pintprofileid);
	
		IF NOT sprofile.exists(pintprofileid)
		THEN
			sprofile(pintprofileid)(custom_contractprofiles.cp_profileid) := pintprofileid;
			sopergroup(pintprofileid)(0)(custom_contractprofiles.cpg_chargeint) := 0;
			sprofilerates(pintprofileid)(0)(custom_contractprofiles.cr_ovrprchist) := NULL;
			sopergroupredrates(pintprofileid)(0)(1).rateid := NULL;
		
			custom_contractprofiles.getprofile(pintprofileid
											  ,sprofile(pintprofileid)
											  ,sopergroup(pintprofileid)
											  ,sprofilerates(pintprofileid)
											  ,sopergroupredrates(pintprofileid));
		END IF;
	
		IF NOT sordergroup.exists(pintprofileid)
		THEN
			sordergroup(pintprofileid)(0) := NULL;
			custom_contractprofiles.fillgrouparray(pintprofileid, sordergroup(pintprofileid));
		END IF;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END fillinterestprofsettings;

	PROCEDURE resetcurrentcycle IS
		cmethodname CONSTANT typemethodname := cpackagename || '.ResetCurrentCycle';
	BEGIN
		scurrentcycle  := NULL;
		spreviouscycle := NULL;
		scurrentmp.delete;
		snextduedate     := NULL;
		scycleinfoloaded := FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END resetcurrentcycle;

	PROCEDURE getcontractdata
	(
		pcreatenew     IN BOOLEAN := FALSE
	   ,penddate       IN DATE := NULL
	   ,pfromadjusting IN BOOLEAN := FALSE
	   ,pcalcdelparams IN BOOLEAN := TRUE
	) IS
		cmethodname CONSTANT VARCHAR2(80) := 'custom_sch_customer_1' || '.GetContractData';
		coperdate   CONSTANT DATE := seance.getoperdate;
		cbranch     CONSTANT NUMBER := seance.getbranch;
		venddate DATE := coalesce(penddate, seance.getoperdate);
	BEGIN
		s.say(cmethodname || '  --<< BEGIN');
		s.say(cmethodname || '  -- INPUT PARAMETERS:');
		s.say(cmethodname || '     Whether New Contract is created (pCreateNew) = ' ||
			  service.iif(pcreatenew, 'YES', 'NO'));
		s.say(cmethodname || '     What Date are Data obtained on (vEndDate) = ' ||
			  htools.d2s(venddate));
		s.say(cmethodname ||
			  '     Whether the method was run from ExecAdjustment (pFromAdjusting) = ' ||
			  service.iif(pfromadjusting, 'YES', 'NO'));
		s.say(cmethodname ||
			  '     implicit: Contract Number (ContractTypeSchema.sContractRow.No) = ' ||
			  contracttypeschema.scontractrow.no);
		s.say(cmethodname || ' ');
	
		s.say(cmethodname || ' - Accumulate Interest Mode {Interest coming back} = ' ||
			  saccumintaccmode);
		IF NOT pfromadjusting
		THEN
			SELECT *
			INTO   contracttypeschema.scontractrow
			FROM   tcontract
			WHERE  branch = cbranch
			AND    no = contracttypeschema.scontractrow.no;
		END IF;
		scontractno := contracttypeschema.scontractrow.no;
	
		FOR i IN 1 .. 2
		LOOP
			custom_contracttools.loadcontractaccount(sitem(i).dep, sdepaccount(i));
			custom_contracttools.loadcontractaccount(sitem(i).ovd, sovdaccount(i));
			IF saccumintaccmode <> cintaccmode_donotaccumulate
			THEN
				s.say(cmethodname || '--> sItem(' || i || ').Int = ' || sitem(i).int);
				custom_contracttools.loadcontractaccount(sitem(i).int, sintaccount(i));
				s.say(cmethodname || '--> sIntAccount(' || i || ').accountNo = ' || sintaccount(i)
					  .accountno);
			END IF;
		
			IF ifcurrencyisusedintype(i, contracttypeschema.scontractrow.type, scontractno)
			THEN
				IF sprecision(i) IS NULL
				THEN
					sprecision(i) := referencecurrency.getprecision(sdepaccount(i).currencyno);
				END IF;
			
				sacparamccy(i)(0) := NULL;
				IF i = 1
				THEN
					loadparam(scontractno
							 ,cacontrpdom_ident
							 ,sacctparamccy(i)
							 ,sacparamccy(i)
							 ,FALSE);
				ELSE
					loadparam(scontractno
							 ,cacontrpint_ident
							 ,sacctparamccy(i)
							 ,sacparamccy(i)
							 ,FALSE);
				END IF;
				fillmpprofilesettings(sacparamccy(i) (cp_mpprofile));
				fillinterestprofsettings(sacparamccy(i) (cp_profile));
			
				sinttoinston(i) := (sactparamccy(i) (cctp_inttoinston) = 1) AND
								   (sacparamccy(i) (cp_inttoinston) = 1) AND
								   (coperdate BETWEEN
								   nvl(to_date(sactparamccy(i) (cctp_inttoinstfrom)
											   ,contractparams.cparam_date_format)
									   ,coperdate) AND
								   nvl(to_date(sactparamccy(i) (cctp_inttoinstto)
											   ,contractparams.cparam_date_format)
									   ,coperdate));
			
			ELSE
				sacparamccy(i)(cp_lastdocno) := 0;
			END IF;
		
		END LOOP;
	
		resetcurrentcycle;
		resetcorpcontractnumber;
	
		loadparam(scontractno, cacp_ident, sact_cparam, sacparam, FALSE);
	
		IF NOT pcreatenew
		THEN
		
			FOR i IN 1 .. 2
			LOOP
				slastdocno(i) := sacparamccy(i) (cp_lastdocno);
			END LOOP;
		
			IF pcalcdelparams
			THEN
				getdelparameters(venddate);
			END IF;
		
		END IF;
		s.say(cmethodname || '  -->> END');
	EXCEPTION
		WHEN contracttools.valuenotexists
			 OR contracttools.usererror THEN
			error.save(cmethodname);
			RAISE excothererror;
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getcontractdata;

	/*PROCEDURE filldcarrays IS
                cmethodname CONSTANT VARCHAR2(80) := 'custom_sch_customer_1' || '.FillDCArrays';
            BEGIN
                s.say(cmethodname || ' -> Start');
                sodparams.delete;
                solparams.delete;
                schargefromparam.delete;
            
                sodparams(1).paramcode := 'OVERDUE_AMOUNT';
                sodparams(1).paramname := 'Overdue amount';
                sodparams(1).paramtype := 2;
                sodparams(1).parammin := 0;
                sodparams(1).parammax := NULL;
            
                sodparams(2).paramcode := 'OVERDUE_PERIOD';
                sodparams(2).paramname := 'Overdue period (days)';
                sodparams(2).paramtype := 1;
                sodparams(2).parammin := 0;
                sodparams(2).parammax := NULL;
            
                solparams(1).paramcode := 'OVERLIMIT_AMOUNT';
                solparams(1).paramname := 'Over-limit amount';
                solparams(1).paramtype := 2;
                solparams(1).parammin := 0;
                solparams(1).parammax := NULL;
            
                solparams(2).paramcode := 'OVERLIMIT_RATE';
                solparams(2).paramname := 'Over-limit rate (%)';
                solparams(2).paramtype := 2;
                solparams(2).parammin := 0;
                solparams(2).parammax := NULL;
            
                solparams(3).paramcode := 'OVERLIMIT_PERIOD';
                solparams(3).paramname := 'Over-limit period (days)';
                solparams(3).paramtype := 1;
                solparams(3).parammin := 0;
                solparams(3).parammax := NULL;
            
                schargefromparam(1).itemid := 1;
                schargefromparam(1).itemname := 'Card Account in Domestic Currency';
                schargefromparam(2).itemid := 2;
                schargefromparam(2).itemname := 'Card Account in International Currency';
                schargefromparam(3).itemid := 3;
                schargefromparam(3).itemname := 'Card Account in Fee Currency';
                s.say(cmethodname || ' -> End');
            EXCEPTION
                WHEN OTHERS THEN
                    error.save(cmethodname);
                    RAISE;
            END;
        
        PROCEDURE readsetupscheme(ploadprofiles IN BOOLEAN := TRUE) IS
            cmethodname CONSTANT VARCHAR2(80) := 'custom_sch_customer_1' || '.ReadSetupScheme';
            cbranch     CONSTANT NUMBER := seance.getbranch;
            vprfcount  NUMBER := 0;
            vtypearray contractlink.typenumber;
            vindex     NUMBER := 0;
        
            CURSOR curdelinqset IS
                SELECT v.*
                      ,rownum rnum
                FROM   vtypedelinqsettings_bytype v
                WHERE  branch = cbranch
                AND    contracttype = scontracttype
                ORDER  BY period    DESC
                         ,overlimit DESC;
        
        BEGIN
            t.enter(cmethodname);
        
            s.say(cmethodname || ' -> OperDate=' || seance.getoperdate);
            filldcarrays;
            FOR i IN 1 .. 2
            LOOP
                sprecision(i) := NULL;
                sitem(i).dep := contracttypeitems.getitemcode(scontracttype, 'ItemDeposit' || slabel(i));
                sitem(i).ovd := contracttypeitems.getitemcode(scontracttype
                                                             ,'ItemOverdraft' || slabel(i));
                IF saccumintaccmode <> cintaccmode_donotaccumulate
                THEN
                    sitem(i).int := contracttypeitems.getitemcode(scontracttype
                                                                 ,'ItemInterest' || slabel(i));
                END IF;
            END LOOP;
        
            sactparam   := loadparam(scontracttype, cactp_ident);
            sact_cparam := loadparam(scontracttype, cacp_ident, FALSE);
            IF sactparam(cctp_stmtmode) IN (2, 3, 4)
               AND sactparam(cctp_stmttrns) = 0
            THEN
                RAISE excothererror;
            END IF;
            IF sactparam(cctp_corpmode) = '1'
            THEN
                IF contractlink.getlinktypes(scontracttype, contractlink.clink, vtypearray) <> 1
                THEN
                    RAISE contractparams.accountnotexists;
                END IF;
                sactparam(cctp_calendarid) := contractparams.loadnumber(contractparams.ccontracttype
                                                                       ,vtypearray(1)
                                                                       ,'CalendarId');
            END IF;
        
            FOR i IN 1 .. 2
            LOOP
                smainprofile(i) := NULL;
                IF ifcurrencyisusedintype(i, scontracttype)
                THEN
                    vprfcount := vprfcount + 1;
                    smainprofile(i) := contractparams.loadnumber(contractparams.ccontracttype
                                                                ,scontracttype
                                                                ,'Profile' || slabel(i));
                    fillinterestprofsettings(smainprofile(i));
                
                    IF debtcollectoravailable
                    THEN
                        contractdcsetup.loadchargectvalues('DC_Charge', scontracttype, schargeparam);
                        contractdcsetup.loadctvalues('DC_' || slabel(i)
                                                    ,scontracttype
                                                    ,sdcparam
                                                    ,sodparams
                                                    ,solparams);
                        IF i = 1
                        THEN
                            sodparamsdom := sodparams;
                            solparamsdom := solparams;
                            sdcparamdom  := sdcparam;
                        ELSE
                            sodparamsint := sodparams;
                            solparamsint := solparams;
                            sdcparamint  := sdcparam;
                        END IF;
                    END IF;
                
                    IF NOT sordergroup.exists(smainprofile(i))
                    THEN
                        sordergroup(smainprofile(i))(0) := NULL;
                        custom_contractprofiles.fillgrouparray(smainprofile(i)
                                                              ,sordergroup(smainprofile(i)));
                    END IF;
                    IF sordergroup(smainprofile(i)).count = 0
                    THEN
                        RAISE contractparams.incorrectvalue;
                    END IF;
                END IF;
            END LOOP;
        
            FOR i IN 1 .. 2
            LOOP
                smpaltprofile(i) := 0;
                smpmainprofile(i) := NULL;
                IF (nvl(ploadprofiles, FALSE) OR contractcalendar.issdinsomecalendar)
                   AND ifcurrencyisusedintype(i, scontracttype)
                THEN
                    s.say(cmethodname || ': call custom_contractprofiles.GetMPProfile');
                    smpmainprofile(i) := contractparams.loadnumber(contractparams.ccontracttype
                                                                  ,scontracttype
                                                                  ,'MPProfile' || slabel(i));
                    fillmpprofilesettings(smpmainprofile(i));
                END IF;
            END LOOP;
        
            FOR i IN 1 .. 2
            LOOP
                IF ifcurrencyisusedintype(i, scontracttype)
                THEN
                    IF i = 1
                    THEN
                        sactparamccy(i) := loadparam(scontracttype, cactp_dom_ident);
                        sacctparamccy(i) := loadparam(scontracttype, cacontrpdom_ident, FALSE);
                        sabaccounts(i) := contracttools.loadbaccounts(scontracttype
                                                                     ,cab_identdom
                                                                     ,FALSE);
                    ELSE
                        sactparamccy(i) := loadparam(scontracttype, cactp_int_ident);
                        sacctparamccy(i) := loadparam(scontracttype, cacontrpint_ident, FALSE);
                        sabaccounts(i) := contracttools.loadbaccounts(scontracttype
                                                                     ,cab_identint
                                                                     ,FALSE);
                    END IF;
                END IF;
            END LOOP;
        
            IF (vprfcount = 0)
               AND (nvl(ploadprofiles, FALSE) OR contractcalendar.isddinsomecalendar OR
               contractcalendar.issdinsomecalendar)
            THEN
                RAISE contractparams.incorrectvalue;
            END IF;
            sdelstatus.delete;
            sdelparam.overdueint := sactparam(cctp_periodtype);
            sdelparam.limitint   := sactparam(cctp_overlimittype);
        
            s.say(cmethodname || '             - info: DELINQUENCY GROUP CACHE IS GOING TO BE FILLED ');
            FOR cc IN curdelinqset
            LOOP
                vindex := cc.rnum;
                s.say(cmethodname || '               Delinquency group index (vIndex) = ' || vindex ||
                      ', Ovd. period = ' || cc.period || ', Overlimit = ' || cc.overlimit ||
                      ', OverdueAmount_Threshold = ' || cc.overdueamount_threshold);
                sdelstatus(vindex).period := cc.period;
                sdelstatus(vindex).overdueamount_threshold := cc.overdueamount_threshold;
                sdelstatus(vindex).overlimit := cc.overlimit;
                sdelstatus(vindex).stateid := cc.stateid;
                sdelstatus(vindex).state := contractstatereference.getstate(cc.stateid);
                sdelstatus(vindex).profileiddom := cc.profileid_dom;
                sdelstatus(vindex).mpprofileiddom := cc.mp_profileid_dom;
                sdelstatus(vindex).profileidint := cc.profileid_int;
                sdelstatus(vindex).mpprofileidint := cc.mp_profileid_int;
            
                IF nvl(cc.period, -0.75) = -0.75
                   AND nvl(cc.overlimit, -0.75) = -0.75
                THEN
                    scontrtype_cache(scontracttype).defaultriskgroup := vindex;
                END IF;
            
            END LOOP;
            s.say(cmethodname ||
                  '             Default group index (sContrType_Cache(sContractType).DefaultRiskGroup) = ' || scontrtype_cache(scontracttype)
                  .defaultriskgroup);
        
            contracttools.readentcode(sdelfeeonentcode, 'OVERDUE_FEE_ON');
            contracttools.readentcode(sovdfeeonentcode, 'OVERLIMIT_FEE_ON');
            contracttools.readentcode(ssrvfeeonentcode, 'MONTHLY_FEE_ON');
            contracttools.readentcode(scrdshieldentcode, 'CREDIT_SHIELD_PREMIUM');
        
            SELECT code BULK COLLECT
            INTO   sprconentcode
            FROM   treferenceentry
            WHERE  branch = cbranch
            AND    ident LIKE 'CHARGE_INTEREST_GROUP_%';
        
            smulticurrency := ifcurrencyisusedintype(1, scontracttype, scontractno) AND
                              ifcurrencyisusedintype(2, scontracttype, scontractno);
        
            IF smulticurrency
            THEN
                smulticurrencyrate(1) := getrate(contractaccount.getaccounttypecurrency(scontracttype
                                                                                       ,'ItemDeposit' ||
                                                                                        slabel(1))
                                                ,contractaccount.getaccounttypecurrency(scontracttype
                                                                                       ,'ItemDeposit' ||
                                                                                        slabel(2))
                                                ,seance.getoperdate);
                smulticurrencyrate(2) := getrate(contractaccount.getaccounttypecurrency(scontracttype
                                                                                       ,'ItemDeposit' ||
                                                                                        slabel(2))
                                                ,contractaccount.getaccounttypecurrency(scontracttype
                                                                                       ,'ItemDeposit' ||
                                                                                        slabel(1))
                                                ,seance.getoperdate);
            
            ELSE
                FOR i IN 1 .. 2
                LOOP
                    IF ifcurrencyisusedintype(i, scontracttype, scontractno)
                    THEN
                        smulticurrencyrate(i) := 1;
                    END IF;
                END LOOP;
            END IF;
        
            scontrtype_cache(scontracttype).readsetupscheme_called := TRUE;
        
            t.leave(cmethodname);
        EXCEPTION
            WHEN excothererror THEN
                RAISE;
            WHEN contractparams.accountnotexists THEN
                error.saveraise(cmethodname, error.errorconst, 'Account does not exist');
            WHEN contractparams.valuenotexists THEN
                error.saveraise(cmethodname
                               ,error.errorconst
                               ,'Can''t find some value at contract type settings (contract type ' ||
                                scontracttype || ')');
            WHEN contractparams.incorrectvalue THEN
                error.saveraise(cmethodname
                               ,error.errorconst
                               ,'Incorrect value at contract type settings (contract type ' ||
                                scontracttype || ')');
            WHEN contracttools.usererror THEN
                error.save(cmethodname);
                RAISE excothererror;
            WHEN OTHERS THEN
                err.seterror(SQLCODE, cmethodname);
                error.save(cmethodname);
                RAISE excothererror;
        END readsetupscheme;
    */

	FUNCTION calccontractforclose(psaveinterestcalclog BOOLEAN := FALSE) RETURN typecloseinfoarray;

	PROCEDURE getinterestamount
	(
		pcontractno           IN VARCHAR
	   ,oaprcarraydom         OUT NOCOPY typeprcchargearray
	   ,oaprcarrayint         OUT NOCOPY typeprcchargearray
	   ,oaovdfeeamount        OUT NOCOPY typenumber
	   ,oaovlfeeamount        OUT NOCOPY typenumber
	   ,osavedinterestcalclog OUT NOCOPY typeparsedinterestlog_tab
	   ,puserdefinedoperdate  IN DATE := NULL
	) IS
		cmethodname     CONSTANT VARCHAR2(80) := 'custom_sch_customer_1' || '.GetInterestAmount';
		cbranch         CONSTANT NUMBER := custom_seance.getbranch;
		cactualoperdate CONSTANT DATE := custom_seance.getoperdate;
		vcloseinfoarray typecloseinfoarray;
	BEGIN
		custom_seance.settempoperdate(nvl(puserdefinedoperdate, cactualoperdate));
	
		custom_s.say(cmethodname || ', OperDate = ' || htools.d2s(custom_seance.getoperdate) ||
					 ', cActualOperDate = ' || htools.d2s(cactualoperdate));
	
		IF custom_contracttypeschema.scontractrow.no IS NULL
		   OR pcontractno <> custom_contracttypeschema.scontractrow.no
		THEN
			SELECT *
			INTO   contracttypeschema.scontractrow
			FROM   tcontract
			WHERE  branch = cbranch
			AND    no = pcontractno;
			scontractno   := custom_contracttypeschema.scontractrow.no;
			scontracttype := custom_contracttypeschema.scontractrow.type;
			scontractstat := contract.getstatus(contracttypeschema.scontractrow.no);
			IF contract.checkstatus(scontractstat, contract.stat_close)
			THEN
				error.raiseerror('Contract is closed');
			END IF;
		END IF;
		--readsetupscheme(FALSE);
		getcontractdata;
	
		vcloseinfoarray := calccontractforclose(TRUE);
	
		oaprcarraydom := sprcchargedom;
		oaprcarrayint := sprcchargeint;
	
		FOR i IN 1 .. 2
		LOOP
			IF vcloseinfoarray.exists(i)
			THEN
			
				oaovdfeeamount(i) := vcloseinfoarray(i).overduefee;
			
				oaovlfeeamount(i) := vcloseinfoarray(i).overlimitfee;
			END IF;
		END LOOP;
	
		osavedinterestcalclog := ssavedinterestcalclog;
	
		custom_seance.settempoperdate(cactualoperdate);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			custom_seance.settempoperdate(cactualoperdate);
			RAISE;
	END getinterestamount;
BEGIN

	NULL;

END custom_sch_customer_1;
/
