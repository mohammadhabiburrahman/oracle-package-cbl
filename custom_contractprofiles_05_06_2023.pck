CREATE OR REPLACE PACKAGE custom_contractprofiles AS

	cbalanceonsd      CONSTANT PLS_INTEGER := 0;
	cunpaidtrxns      CONSTANT PLS_INTEGER := 1;
	cbalanceondd      CONSTANT PLS_INTEGER := 2;
	cbalanceondd_oper CONSTANT PLS_INTEGER := 3;

	cwaivernone CONSTANT PLS_INTEGER := 1;
	cwaiversd   CONSTANT PLS_INTEGER := 2;
	cwaiverfull CONSTANT PLS_INTEGER := 3;

	SUBTYPE typeentrygrouprow IS tcontractentrygroup%ROWTYPE;

	SUBTYPE typeitemname IS VARCHAR2(50);

	SUBTYPE typemonthlyfeerow IS treferencemonthlyfee%ROWTYPE;

	TYPE typemonthlyfeearray IS TABLE OF typemonthlyfeerow INDEX BY PLS_INTEGER;

	SUBTYPE typempprofilerow IS tcontractmpprofile%ROWTYPE;

	SUBTYPE typeprofilerow IS tcontractprofile%ROWTYPE;

	SUBTYPE typeparamrow IS tcontractotherparameters%ROWTYPE;

	SUBTYPE typepercentbelongrow IS tpercentbelong%ROWTYPE;

	sheaderversion CONSTANT VARCHAR2(100) := '4.6.6.220811';

	camountforredrateterms CONSTANT VARCHAR2(50) := 'MaxSDBal';

	TYPE typenumber IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
	TYPE typenumbernumber IS TABLE OF typenumber INDEX BY PLS_INTEGER;
	TYPE typempgroupparamrecord IS RECORD(
		 prcvalue NUMBER
		,curonly  BOOLEAN);
	TYPE typempgroupparamarray IS TABLE OF typempgroupparamrecord INDEX BY PLS_INTEGER;
	TYPE typempgroupparamarrarr IS TABLE OF typempgroupparamarray INDEX BY PLS_INTEGER;

	TYPE typegrouprecord IS RECORD(
		 groupid   NUMBER
		,groupname tcontractentrygroup.groupname%TYPE
		,grouptype NUMBER);
	TYPE typegrouparray IS TABLE OF typegrouprecord INDEX BY PLS_INTEGER;

	TYPE typeprofilparamarray IS TABLE OF types.arrstr1000 INDEX BY PLS_INTEGER;
	TYPE typeprofilgroupparamarray IS TABLE OF typeprofilparamarray INDEX BY PLS_INTEGER;
	TYPE typegrouprates IS TABLE OF contracttools.trate INDEX BY PLS_INTEGER;
	TYPE typeprofilegrouprates IS TABLE OF typegrouprates INDEX BY PLS_INTEGER;
	TYPE typegrouprateid IS TABLE OF types.arrnum INDEX BY PLS_INTEGER;
	TYPE typeprofilegrouprateid IS TABLE OF typegrouprateid INDEX BY PLS_INTEGER;

	TYPE typereducedratesrec IS RECORD(
		 terms            NUMBER
		,amount           NUMBER
		,rateid           NUMBER
		,reducedtermusage NUMBER);
	TYPE typereducedratesarr IS TABLE OF typereducedratesrec INDEX BY PLS_INTEGER;
	TYPE typereducedratesgrarr IS TABLE OF typereducedratesarr INDEX BY PLS_INTEGER;
	TYPE typereducedratesprofarr IS TABLE OF typereducedratesgrarr INDEX BY PLS_INTEGER;

	cmpbaselimit CONSTANT PLS_INTEGER := 1;
	cmpbaseused  CONSTANT PLS_INTEGER := 2;
	cmpbasegroup CONSTANT PLS_INTEGER := 3;

	cclgroup CONSTANT PLS_INTEGER := -1;

	cgrace_notused   CONSTANT PLS_INTEGER := 0;
	cgrace_paidmp    CONSTANT PLS_INTEGER := 1;
	cgrace_paidsdbal CONSTANT PLS_INTEGER := 2;

	cgrace_currentbalisless      CONSTANT PLS_INTEGER := 3;
	cgrace_unpdbaloflastsdisless CONSTANT PLS_INTEGER := 4;

	cgrace_unpaidsdamntonddisless CONSTANT PLS_INTEGER := 5;

	cgraceperusage_always        CONSTANT PLS_INTEGER := 1;
	cgraceperusage_prevcycleonly CONSTANT PLS_INTEGER := 2;

	cprefrateuse_contrcreationdate CONSTANT PLS_INTEGER := 1;
	cprefrateuse_trandate          CONSTANT PLS_INTEGER := 2;

	chowovlcalc_total     CONSTANT PLS_INTEGER := 1;
	chowovlcalc_lastcycle CONSTANT PLS_INTEGER := 2;

	cdate_current      CONSTANT PLS_INTEGER := 1;
	cdate_transaction  CONSTANT PLS_INTEGER := 2;
	cdate_history      CONSTANT PLS_INTEGER := 3;
	cdate_cardcreation CONSTANT PLS_INTEGER := 4;

	cproplsql_off CONSTANT PLS_INTEGER := 0;
	cproplsql_and CONSTANT PLS_INTEGER := 1;
	cproplsql_or  CONSTANT PLS_INTEGER := 2;

	camount_max         CONSTANT PLS_INTEGER := 1;
	camount_discrete    CONSTANT PLS_INTEGER := 2;
	camount_transaction CONSTANT PLS_INTEGER := 3;
	cother              CONSTANT PLS_INTEGER := 4;

	covdfeecalctype_notused    CONSTANT PLS_INTEGER := 1;
	covdfeecalctype_astotal    CONSTANT PLS_INTEGER := 2;
	covdfeecalctype_asmax      CONSTANT PLS_INTEGER := 3;
	covdfeecalctype_asmin      CONSTANT PLS_INTEGER := 4;
	covdfeecalctype_asinterest CONSTANT PLS_INTEGER := 5;

	cp_mpp_base         CONSTANT PLS_INTEGER := 1;
	cp_mpp_type         CONSTANT PLS_INTEGER := 2;
	cp_mpp_amount       CONSTANT PLS_INTEGER := 3;
	cp_mpp_prc          CONSTANT PLS_INTEGER := 4;
	cp_mpp_prccl        CONSTANT PLS_INTEGER := 5;
	cp_mpp_incunpaidmp  CONSTANT PLS_INTEGER := 6;
	cp_mpp_incoverlimit CONSTANT PLS_INTEGER := 7;
	cp_mpp_addunpaidmp  CONSTANT PLS_INTEGER := 8;
	cp_mpp_addoverlimit CONSTANT PLS_INTEGER := 9;
	cp_mpp_incmax       CONSTANT PLS_INTEGER := 10;

	cp_mpp_ovlcalctype CONSTANT PLS_INTEGER := 11;
	cp_mpp_mpnotless   CONSTANT PLS_INTEGER := 12;

	cp_mpp_mpbalanceless CONSTANT PLS_INTEGER := 13;
	cp_mpp_profileid     CONSTANT PLS_INTEGER := 14;

	campp_ident CONSTANT tblschitem := tblschitem(recschitem(cp_mpp_base
															,'MinPayBase'
															,'spec'
															,'descr'
															,contracttools.coptional
															,2
															,NULL
															,NULL
															,NULL)
												 ,recschitem(cp_mpp_type
															,'MinPayType'
															,''
															,''
															,contracttools.cmandatory
															,NULL
															,NULL
															,NULL
															,NULL)
												 ,recschitem(cp_mpp_amount
															,'MinPayAmount'
															,''
															,''
															,contracttools.cmandatory
															,NULL
															,NULL
															,NULL
															,NULL)
												 ,recschitem(cp_mpp_prc
															,'MinPayPrc'
															,''
															,''
															,contracttools.coptional
															,NULL
															,NULL
															,NULL
															,NULL)
												 ,recschitem(cp_mpp_prccl
															,'MinPayPrcCL'
															,''
															,''
															,contracttools.coptional
															,0
															,NULL
															,NULL
															,NULL)
												 ,recschitem(cp_mpp_incunpaidmp
															,'IncUnpaidMP'
															,''
															,''
															,contracttools.coptional
															,1
															,NULL
															,NULL
															,NULL)
												 ,recschitem(cp_mpp_incoverlimit
															,'IncOverLimit'
															,''
															,''
															,contracttools.coptional
															,1
															,NULL
															,NULL
															,NULL)
												 ,recschitem(cp_mpp_addunpaidmp
															,'AddUnpaidMP'
															,''
															,''
															,contracttools.coptional
															,0
															,NULL
															,NULL
															,NULL)
												 ,recschitem(cp_mpp_addoverlimit
															,'AddOverLimit'
															,''
															,''
															,contracttools.coptional
															,0
															,NULL
															,NULL
															,NULL)
												 ,recschitem(cp_mpp_incmax
															,'IncMax'
															,''
															,''
															,contracttools.coptional
															,1
															,NULL
															,NULL
															,NULL)
												  
												 ,recschitem(cp_mpp_ovlcalctype
															,'OverLimitCalcType'
															,''
															,''
															,contracttools.coptional
															,chowovlcalc_total
															,NULL
															,NULL
															,NULL)
												 ,recschitem(cp_mpp_mpnotless
															,'CalcMPNotLess'
															,''
															,''
															,contracttools.coptional
															,0
															,NULL
															,NULL
															,NULL)
												 ,recschitem(cp_mpp_mpbalanceless
															,'CalcMPBalanceLess'
															,''
															,''
															,contracttools.coptional
															,0
															,NULL
															,NULL
															,NULL)
												  
												  );

	cp_profileid           CONSTANT PLS_INTEGER := 01;
	cp_repayorder          CONSTANT PLS_INTEGER := 02;
	cp_repaydate           CONSTANT PLS_INTEGER := 03;
	cp_chargetype          CONSTANT PLS_INTEGER := 04;
	cp_divintbyrates       CONSTANT PLS_INTEGER := 05;
	cp_repaysettings       CONSTANT PLS_INTEGER := 06;
	cp_ovdallow            CONSTANT PLS_INTEGER := 07;
	cp_ovdallowamt         CONSTANT PLS_INTEGER := 08;
	cp_ovdallowprc         CONSTANT PLS_INTEGER := 09;
	cp_ovdfeedate          CONSTANT PLS_INTEGER := 10;
	cp_ovdfeetype          CONSTANT PLS_INTEGER := 11;
	cp_ovdfeeamt           CONSTANT PLS_INTEGER := 12;
	cp_ovdfeeprc           CONSTANT PLS_INTEGER := 13;
	cp_redovdfeetype       CONSTANT PLS_INTEGER := 14;
	cp_redovdfeeamt        CONSTANT PLS_INTEGER := 15;
	cp_redovdfeeprc        CONSTANT PLS_INTEGER := 16;
	cp_redovdfeeperiod     CONSTANT PLS_INTEGER := 17;
	cp_ovrlmtallow         CONSTANT PLS_INTEGER := 18;
	cp_ovrlmtallowamt      CONSTANT PLS_INTEGER := 19;
	cp_ovrlmtallowprc      CONSTANT PLS_INTEGER := 20;
	cp_ovrlmtterms         CONSTANT PLS_INTEGER := 21;
	cp_ovrlmtbased         CONSTANT PLS_INTEGER := 22;
	cp_ovrignorecorp       CONSTANT PLS_INTEGER := 23;
	cp_ovrlmttype          CONSTANT PLS_INTEGER := 24;
	cp_ovrlmtyear          CONSTANT PLS_INTEGER := 25;
	cp_ovrlmtamount        CONSTANT PLS_INTEGER := 26;
	cp_ovrlmtprc           CONSTANT PLS_INTEGER := 27;
	cp_redovrlmttype       CONSTANT PLS_INTEGER := 28;
	cp_redovrlmtyear       CONSTANT PLS_INTEGER := 29;
	cp_redovrlmtperiod     CONSTANT PLS_INTEGER := 30;
	cp_redovrlmtamt        CONSTANT PLS_INTEGER := 31;
	cp_redovrlmtprc        CONSTANT PLS_INTEGER := 32;
	cp_ovdfeebase          CONSTANT PLS_INTEGER := 33;
	cp_redovdfeebase       CONSTANT PLS_INTEGER := 34;
	cp_ovdfeeminamount     CONSTANT PLS_INTEGER := 35;
	cp_ovdfeemaxamount     CONSTANT PLS_INTEGER := 36;
	cp_redovdfeeminamount  CONSTANT PLS_INTEGER := 37;
	cp_redovdfeemaxamount  CONSTANT PLS_INTEGER := 38;
	cp_ovdfeedaysinyear    CONSTANT PLS_INTEGER := 39;
	cp_redovdfeedaysinyear CONSTANT PLS_INTEGER := 40;
	cp_intchrgmode         CONSTANT PLS_INTEGER := 41;
	cp_intbyremainchrgtype CONSTANT PLS_INTEGER := 42;
	cp_intbyremainrate     CONSTANT PLS_INTEGER := 43;

	cap_ident CONSTANT tblschitem := tblschitem(recschitem(cp_profileid
														  ,'ProfileId'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_repayorder
														  ,'RepayOrder'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_repaydate
														  ,'RepayDate'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,1
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_chargetype
														  ,'ChargeType'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,0
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_repaysettings
														  ,'RepaySettings'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,1
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovdallow
														  ,'OvdValAllow'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,0
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovdallowamt
														  ,'OvdValAllowAmount'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovdallowprc
														  ,'OvdValAllowPrc'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovdfeedate
														  ,'OvdFeeDate'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovdfeetype
														  ,'OvdFeeType'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovdfeeamt
														  ,'OvdFeeAmount'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovdfeeprc
														  ,'OvdFeePRc'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovdfeetype
														  ,'RedOvdFeeType'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovdfeeamt
														  ,'RedOvdFeeAmount'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovdfeeprc
														  ,'RedOvdFeePrc'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovdfeeperiod
														  ,'RedOvdFeePeriod'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovrlmtallow
														  ,'OvrLmtAllow'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovrlmtallowamt
														  ,'OvrLmtAllowAmount'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovrlmtallowprc
														  ,'OvrLmtAllowPrc'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovrlmtterms
														  ,'OvrLmtTerms'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovrlmtbased
														  ,'OvrLmtBased'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovrignorecorp
														  ,'IgnoreCorpOvl'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,0
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovrlmttype
														  ,'OvrLmtType'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovrlmtyear
														  ,'OvrLmtYear'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovrlmtamount
														  ,'OvrLmtAmount'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovrlmtprc
														  ,'OvrLmtPrc'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovrlmttype
														  ,'RedOvrLmtType'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovrlmtyear
														  ,'RedOvrLmtYear'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovrlmtperiod
														  ,'RedOvrLmtPeriod'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovrlmtamt
														  ,'RedOvrLmtAmount'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovrlmtprc
														  ,'RedOvrLmtPrc'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovdfeebase
														  ,'OvdFeeBase'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovdfeebase
														  ,'RedOvdFeeBase'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovdfeeminamount
														  ,'OvdMinAmount'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovdfeemaxamount
														  ,'OvdMaxAmount'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovdfeeminamount
														  ,'RedOvdMinAmount'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovdfeemaxamount
														  ,'RedOvdMaxAmount'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_ovdfeedaysinyear
														  ,'OvdFeeDaysInYear'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_redovdfeedaysinyear
														  ,'RedOvdFeeDaysInYear'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,NULL
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_intchrgmode
														  ,'IntMode'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,1
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_intbyremainchrgtype
														  ,'IntByRemainChargeType'
														  ,''
														  ,''
														  ,contracttools.cmandatory
														  ,1
														  ,NULL
														  ,NULL
														  ,NULL)
											   ,recschitem(cp_divintbyrates
														  ,'DivIntByRates'
														  ,''
														  ,''
														  ,contracttools.coptional
														  ,0
														  ,NULL
														  ,NULL
														  ,NULL));

	cpg_chargeint         CONSTANT PLS_INTEGER := 01;
	cpg_startdate         CONSTANT PLS_INTEGER := 02;
	cpg_shiftdays         CONSTANT PLS_INTEGER := 03;
	cpg_daysinyear        CONSTANT PLS_INTEGER := 04;
	cpg_chargeonb         CONSTANT PLS_INTEGER := 05;
	cpg_usegrace          CONSTANT PLS_INTEGER := 06;
	cpg_tillcursd         CONSTANT PLS_INTEGER := 07;
	cpg_unbillinc         CONSTANT PLS_INTEGER := 08;
	cpg_crdprcdate        CONSTANT PLS_INTEGER := 09;
	cpg_crdprctype        CONSTANT PLS_INTEGER := 10;
	cpg_crdprcprdt        CONSTANT PLS_INTEGER := 11;
	cpg_procalid          CONSTANT PLS_INTEGER := 12;
	cpg_proaddcond        CONSTANT PLS_INTEGER := 13;
	cpg_proplsql          CONSTANT PLS_INTEGER := 14;
	cpg_precalid          CONSTANT PLS_INTEGER := 15;
	cpg_preuse            CONSTANT PLS_INTEGER := 16;
	cpg_chargepaid        CONSTANT PLS_INTEGER := 17;
	cpg_onlyfirst         CONSTANT PLS_INTEGER := 18;
	cpg_crdprchist        CONSTANT PLS_INTEGER := 19;
	cpg_proprchist        CONSTANT PLS_INTEGER := 20;
	cpg_preprchist        CONSTANT PLS_INTEGER := 21;
	cpg_preprcusagestarts CONSTANT PLS_INTEGER := 22;

	capg_ident CONSTANT tblschitem := tblschitem(recschitem(cpg_chargeint
														   ,'ChargeInt'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_startdate
														   ,'StartDate'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_shiftdays
														   ,'ShiftDays'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_daysinyear
														   ,'DaysInYear'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_chargeonb
														   ,'ChargeOnB'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_usegrace
														   ,'UseRedRate'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_tillcursd
														   ,'TillCurSD'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_unbillinc
														   ,'UnBillInc'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_crdprcdate
														   ,'CrdPrcDate'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,contractprofiles.cdate_current
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_crdprctype
														   ,'CrdPrcType'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_crdprcprdt
														   ,'CrdPrcPrdt'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,1
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_procalid
														   ,'ProCalId'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_proaddcond
														   ,'ProAddCond'
														   ,''
														   ,''
														   ,contracttools.cmandatory
														   ,cproplsql_off
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_proplsql
														   ,'ProPLSQL'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_precalid
														   ,'PreCalId'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_preuse
														   ,'PreUse'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_chargepaid
														   ,'ChargePaid'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_onlyfirst
														   ,'OnlyFirst'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,0
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_crdprchist
														   ,'CrdPrcHist'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_proprchist
														   ,'ProPrcHist'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL
														   ,NULL)
												,recschitem(cpg_preprchist
														   ,'PrePrcHist'
														   ,''
														   ,''
														   ,contracttools.coptional
														   ,NULL
														   ,NULL
														   ,NULL
														   ,NULL)
												 
												,recschitem(cpg_preprcusagestarts
														   ,'PreUsageStartFrom'
														   ,''
														   ,''
														   ,contracttools.cmandatory
														   ,cprefrateuse_contrcreationdate
														   ,NULL
														   ,NULL
														   ,NULL)
												 
												 );

	cr_ovrprchist           CONSTANT PLS_INTEGER := 1;
	cr_redovrprchist        CONSTANT PLS_INTEGER := 2;
	cp_ovdfeeinterestrat    CONSTANT PLS_INTEGER := 3;
	cp_redovdfeeinterestrat CONSTANT PLS_INTEGER := 4;
	cr_intbyremainrate      CONSTANT PLS_INTEGER := 5;

	carates_ident CONSTANT tblschitem := tblschitem(recschitem(cr_ovrprchist
															  ,'OvrPrcHist'
															  ,''
															  ,''
															  ,contracttools.coptional
															  ,NULL
															  ,NULL
															  ,NULL
															  ,NULL)
												   ,recschitem(cr_redovrprchist
															  ,'RedOvrPrcHist'
															  ,''
															  ,''
															  ,contracttools.coptional
															  ,NULL
															  ,NULL
															  ,NULL
															  ,NULL)
												   ,recschitem(cp_ovdfeeinterestrat
															  ,'OvdFeeInterestRat'
															  ,''
															  ,''
															  ,contracttools.coptional
															  ,NULL
															  ,NULL
															  ,NULL
															  ,NULL)
												   ,recschitem(cp_redovdfeeinterestrat
															  ,'RedOvdFeeInterestRat'
															  ,''
															  ,''
															  ,contracttools.coptional
															  ,NULL
															  ,NULL
															  ,NULL
															  ,NULL)
												   ,recschitem(cr_intbyremainrate
															  ,'IntByRemainRate'
															  ,''
															  ,''
															  ,contracttools.coptional
															  ,NULL
															  ,NULL
															  ,NULL
															  ,NULL));

	crg_crdprchist CONSTANT PLS_INTEGER := 1;
	crg_proprchist CONSTANT PLS_INTEGER := 2;
	crg_preprchist CONSTANT PLS_INTEGER := 3;
	crg_redprchist CONSTANT PLS_INTEGER := 4;

	cagrates_ident CONSTANT tblschitem := tblschitem(recschitem(crg_crdprchist
															   ,'_CrdPrcHist'
															   ,''
															   ,''
															   ,contracttools.coptional
															   ,NULL
															   ,NULL
															   ,NULL
															   ,NULL)
													,recschitem(crg_proprchist
															   ,'_ProPrcHist'
															   ,''
															   ,''
															   ,contracttools.coptional
															   ,NULL
															   ,NULL
															   ,NULL
															   ,NULL)
													,recschitem(crg_preprchist
															   ,'_PrePrcHist'
															   ,''
															   ,''
															   ,contracttools.coptional
															   ,NULL
															   ,NULL
															   ,NULL
															   ,NULL)
													,recschitem(crg_redprchist
															   ,'_RedPrcHist'
															   ,''
															   ,''
															   ,contracttools.coptional
															   ,NULL
															   ,NULL
															   ,NULL
															   ,NULL));

	FUNCTION groupdialog(preadonly IN BOOLEAN := FALSE) RETURN NUMBER;
	PROCEDURE groupdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE groupsetupdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE operselectdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);

	FUNCTION profiledialog(preadonly IN BOOLEAN := FALSE) RETURN NUMBER;
	PROCEDURE profiledialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);

	PROCEDURE profilesetupdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE profilegroupsetupdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE editredintdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);

	FUNCTION mpprofiledialog(preadonly IN BOOLEAN := FALSE) RETURN NUMBER;
	PROCEDURE mpprofiledialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE mpprofilesetupdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE mpprofilegroupdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE prcdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);

	PROCEDURE makeitem
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,px        IN NUMBER
	   ,py        IN NUMBER
	   ,plen      IN NUMBER
	   ,pcaption  IN VARCHAR
	   ,phint     IN VARCHAR
	);
	PROCEDURE fillitem
	(
		pdialog       IN NUMBER
	   ,pitemname     IN VARCHAR
	   ,pcurrency     IN NUMBER
	   ,pemptyrecname IN VARCHAR := NULL
	   ,pmpprofile    BOOLEAN := FALSE
	);

	PROCEDURE fillgrouparray
	(
		pprofileid  IN NUMBER
	   ,ogrouparray IN OUT NOCOPY typenumber
	);
	FUNCTION getgrouplist RETURN typenumber;
	FUNCTION getgroupfulllist RETURN typegrouparray;
	FUNCTION getgroupidbyentcode(pentcode IN NUMBER) RETURN NUMBER;
	FUNCTION getgrouptype(pgroupid IN NUMBER) RETURN NUMBER;
	FUNCTION getgrouptypebyentrycode(pentrycode IN NUMBER) RETURN NUMBER;
	FUNCTION getgrouptypebyentryident(pentryident IN VARCHAR2) RETURN NUMBER;
	FUNCTION getgroupentcodelist(pgroupid IN NUMBER) RETURN typenumber;

	PROCEDURE getmpgroupsettings
	(
		pprofileid  IN NUMBER
	   ,pgrouparray IN OUT NOCOPY typempgroupparamarray
	);

	PROCEDURE getmpprofile
	(
		pprofileid  IN NUMBER
	   ,pprofilearr IN OUT NOCOPY types.arrstr1000
	);
	PROCEDURE getprofile
	(
		pprofileid     IN NUMBER
	   ,pprofilearr    IN OUT NOCOPY types.arrstr1000
	   ,pgroupsettings IN OUT NOCOPY typeprofilparamarray
	   ,prates         IN OUT NOCOPY contracttools.trate
	   ,predsettings   IN OUT NOCOPY typereducedratesgrarr
	);

	FUNCTION getobjecttype RETURN NUMBER;
	FUNCTION getmpobjecttype RETURN NUMBER;
	FUNCTION getbodyversion RETURN VARCHAR2;

	PROCEDURE dlg_monthlyfee_handler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);

	PROCEDURE dlg_monthlyfees_handler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);

	FUNCTION getmonthlyfeeprofile(pprofileid IN NUMBER) RETURN typemonthlyfeerow;

	FUNCTION getmonthlyfeeprofileentries(pprofileid IN NUMBER) RETURN tblnumber;

	PROCEDURE dropbox_monthlyfee_create
	(
		pdialog       IN NUMBER
	   ,pitemname     IN typeitemname
	   ,px            IN NUMBER
	   ,py            IN NUMBER
	   ,plen          IN NUMBER
	   ,pcaption      IN VARCHAR2
	   ,phint         IN VARCHAR2
	   ,pobjecttype   IN NUMBER
	   ,pobjectno     IN VARCHAR2
	   ,pemptycaption IN VARCHAR2 := fintypes.cnotusedcaption
	   ,pcommand      IN NUMBER := 0
	);

	PROCEDURE dropbox_monthlyfee_fill
	(
		pdialog     IN NUMBER
	   ,pdialogitem IN fintypes.typedialogitem
	);

	FUNCTION dropbox_monthlyfee_getvalue
	(
		pdialog      IN NUMBER
	   ,pitemname    IN typeitemname
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN VARCHAR2;

	FUNCTION dropbox_monthlyfee_save
	(
		pdialog        IN NUMBER
	   ,pitemname      IN typeitemname
	   ,pwritelog      IN BOOLEAN := FALSE
	   ,pparamname     IN VARCHAR2 := NULL
	   ,psaveinhistory IN BOOLEAN := FALSE
	) RETURN NUMBER;

	PROCEDURE ref_monthlyfees_run(preadonly IN BOOLEAN := FALSE);

	PROCEDURE ref_monthlyfees_addtomenu
	(
		pdialog   IN NUMBER
	   ,pmenu     IN NUMBER
	   ,preadonly IN BOOLEAN := FALSE
	);

	PROCEDURE ref_monthlyfees_menuhandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);

	PROCEDURE operationgroups_validate
	(
		porow       IN OUT NOCOPY typeentrygrouprow
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,oactiontype OUT custom_contractexchangetools.typeactiontype
	);

	PROCEDURE operationgroups_saverow
	(
		porow       IN OUT NOCOPY typeentrygrouprow
	   ,pactiontype custom_contractexchangetools.typeactiontype
	);

	PROCEDURE operation_validate
	(
		porow       IN OUT NOCOPY tcontractentrygrouplist%ROWTYPE
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,oactiontype OUT custom_contractexchangetools.typeactiontype
	);

	PROCEDURE monthlyfees_validate
	(
		porow       IN OUT NOCOPY typemonthlyfeerow
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,oactiontype OUT custom_contractexchangetools.typeactiontype
	);

	PROCEDURE monthlyfees_saverow
	(
		porow       IN OUT NOCOPY typemonthlyfeerow
	   ,pactiontype custom_contractexchangetools.typeactiontype
	);

	PROCEDURE monthlyfeeentry_validate
	(
		porow       IN OUT NOCOPY treferencemonthlyfeeentries%ROWTYPE
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,oactiontype OUT custom_contractexchangetools.typeactiontype
	);

	PROCEDURE mpprofiles_validate
	(
		porow       IN OUT NOCOPY typempprofilerow
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,oactiontype OUT custom_contractexchangetools.typeactiontype
	);

	PROCEDURE mpprofiles_validateparam(porow IN OUT NOCOPY typeparamrow);

	PROCEDURE mpprofiles_saverow
	(
		porow       IN OUT NOCOPY typempprofilerow
	   ,pactiontype custom_contractexchangetools.typeactiontype
	);

	PROCEDURE profiles_validate
	(
		porow       IN OUT NOCOPY typeprofilerow
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,oactiontype OUT custom_contractexchangetools.typeactiontype
	);

	PROCEDURE profiles_saverow
	(
		porow       IN OUT NOCOPY typeprofilerow
	   ,pactiontype custom_contractexchangetools.typeactiontype
	);

	PROCEDURE profiles_validateparam(porow IN OUT NOCOPY typeparamrow);

	FUNCTION profiles_export(psettings custom_contractexchangetools.typeexportsettings) RETURN xmltype;

	PROCEDURE profiles_import
	(
		pxml        xmltype
	   ,psettings   custom_contractexchangetools.typeimportsettings
	   ,psaverecord BOOLEAN := TRUE
	   ,ocontinue   OUT BOOLEAN
	);

END custom_contractprofiles;
/
CREATE OR REPLACE PACKAGE BODY custom_contractprofiles AS

	cpackagename CONSTANT VARCHAR2(30) := 'custom_ContractProfiles';
	cbodyversion CONSTANT VARCHAR2(30) := '4.7.9.230113';

	SUBTYPE typemethodname IS VARCHAR2(200);

	cemptymonthlyfeerow CONSTANT typemonthlyfeerow := NULL;

	c_noexception CONSTANT BOOLEAN := FALSE;
	c_doexception CONSTANT BOOLEAN := TRUE;

	crefname_monthlyfees CONSTANT VARCHAR2(50) := 'Dictionary of monthly fee profiles';
	cmnuitem_monthlyfees CONSTANT VARCHAR2(50) := 'MenuItem_MonthlyFeeReference';

	cdropbox_monthlyfee CONSTANT VARCHAR2(50) := 'DropBox_MonthlyFee';

	creadonly CONSTANT VARCHAR2(50) := cpackagename || '_ReadOnly';

	clist_profiles CONSTANT typeitemname := upper('List_Profiles');

	cfld_id   CONSTANT typeitemname := dlg_tools.cfld_id;
	cfld_name CONSTANT typeitemname := upper('ItemName');

	cbtn_ok     CONSTANT typeitemname := upper('Btn_OK');
	cbtn_cancel CONSTANT typeitemname := upper('Btn_Cancel');

	cbtn_add    CONSTANT typeitemname := upper('Btn_Add');
	cbtn_copy   CONSTANT typeitemname := upper('Btn_Copy');
	cbtn_delete CONSTANT typeitemname := upper('Btn_Delete');

	citem_profileid CONSTANT typeitemname := upper('Item_ProfileID');

	creftable_entrygroups    CONSTANT VARCHAR2(100) := upper('tContractEntryGroup');
	creftable_entrygrouplist CONSTANT VARCHAR2(100) := upper('tContractEntryGroupList');

	creftable_monthlyfees       CONSTANT VARCHAR2(100) := upper('tReferenceMonthlyFee');
	creftable_monthlyfeeentries CONSTANT VARCHAR2(100) := upper('tReferenceMonthlyFeeEntries');

	creftable_mpprofiles CONSTANT VARCHAR2(100) := upper('tContractMPProfile');

	creftable_profiles CONSTANT VARCHAR2(100) := upper('tContractProfile');
	creftable_percents CONSTANT VARCHAR2(100) := upper('tPercentBelong');
	creftable_groups   CONSTANT VARCHAR2(100) := upper('tContractProfileGroup');

	cobjectname_entrygroups CONSTANT VARCHAR2(100) := 'OperationGroups';
	cobjectname_monthlyfees CONSTANT VARCHAR2(100) := 'MonthlyFees';
	cobjectname_mpprofiles  CONSTANT VARCHAR2(100) := 'MPProfiles';
	cobjectname_profiles    CONSTANT VARCHAR2(100) := 'Profiles';

	excnull_index_key_value EXCEPTION;
	PRAGMA EXCEPTION_INIT(excnull_index_key_value, -06502);

	c_readonlyflag CONSTANT VARCHAR2(50) := cpackagename || '_ReadOnlyFlag';

	sgroupid       NUMBER;
	sprofileid     NUMBER;
	spriority      NUMBER;
	smpprofileid   NUMBER;
	stypefillarray referenceprchistory.typeitemfillarray;
	sprcvalue      NUMBER;
	scurvalue      BOOLEAN;
	siscreatenew   BOOLEAN;

	sapgrouprates  typeprofilegrouprates;
	sadummyrateid  types.arrnum;
	sapgrouprateid typeprofilegrouprateid;

	incorrectvalue EXCEPTION;
	valuenotexists EXCEPTION;

	TYPE typeschitemarr IS TABLE OF tblschitem INDEX BY BINARY_INTEGER;
	vapg_ident     typeschitemarr;
	vagrates_ident typeschitemarr;

	more_then_100prc EXCEPTION;
	empty_value EXCEPTION;

	FUNCTION groupsetupdialog
	(
		pgroupid  IN NUMBER
	   ,preadonly IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION profilesetupdialog
	(
		pprofileid IN NUMBER
	   ,preadonly  IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION profilegroupsetupdialog
	(
		pgroupid  IN NUMBER
	   ,preadonly IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION mpprofilesetupdialog
	(
		pprofileid IN NUMBER
	   ,preadonly  IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION mpprofilegroupdialog(preadonly IN BOOLEAN := FALSE) RETURN NUMBER;

	FUNCTION operselectdialog RETURN NUMBER;
	FUNCTION prcdialog
	(
		pvalue    IN VARCHAR
	   ,preadonly IN BOOLEAN := FALSE
	) RETURN NUMBER;
	PROCEDURE loadparam
	(
		pobjecttype  NUMBER
	   ,pobjectid    NUMBER
	   ,paitem       tblschitem
	   ,oaret        IN OUT NOCOPY types.arrstr1000
	   ,pprefix      VARCHAR := ''
	   ,pdoexception BOOLEAN := TRUE
	);
	FUNCTION loadrate
	(
		pobjecttype  NUMBER
	   ,pobjectid    NUMBER
	   ,paitem       tblschitem
	   ,paid         IN OUT NOCOPY types.arrnum
	   ,preadhistory BOOLEAN := TRUE
	   ,pprefix      VARCHAR := ''
	   ,pdoexception BOOLEAN := TRUE
	) RETURN contracttools.trate;
	FUNCTION editredintdialog
	(
		ppriority    IN NUMBER
	   ,pgraceisused IN BOOLEAN
	) RETURN NUMBER;

	PROCEDURE dlg_monthlyfees_filllist
	(
		pdialog    IN NUMBER
	   ,pprofileid IN NUMBER := NULL
	);
	PROCEDURE monthlyfees_importinteractive(pdialog NUMBER);
	PROCEDURE dlg_operationgroups_filllist(pdialog NUMBER);
	PROCEDURE operationgroups_importinteractive(pdialog NUMBER);

	PROCEDURE profiles_importinteractive(pdialog NUMBER);
	PROCEDURE mpprofiles_importinteractive(pdialog NUMBER);

	FUNCTION serialize
	(
		patblnumber IN tblnumber
	   ,pdelimiter  IN VARCHAR2 := ';'
	) RETURN VARCHAR2 IS
		cmethodname CONSTANT typemethodname := cpackagename || '.Serialize';
		vresult VARCHAR2(4000);
	BEGIN
		t.enter(cmethodname);
	
		FOR i IN 1 .. patblnumber.count
		LOOP
			vresult := vresult || patblnumber(i) || pdelimiter;
		END LOOP;
	
		vresult := rtrim(vresult, ';');
	
		t.leave(cmethodname, vresult);
		RETURN vresult;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END serialize;

	FUNCTION getmonthlyfeeprofiles(pindexbyid IN BOOLEAN := FALSE) RETURN typemonthlyfeearray IS
		cmethodname CONSTANT typemethodname := cpackagename || '.GetMonthlyFeeProfiles';
	
		FUNCTION int_getmonthlyfeeprofiles
		(
			pbranch    IN NUMBER
		   ,pindexbyid IN BOOLEAN
		) RETURN typemonthlyfeearray result_cache IS
			cmethodname CONSTANT typemethodname := cpackagename || '.Int_GetMonthlyFeeProfiles';
			vresult typemonthlyfeearray;
			vtemp   typemonthlyfeearray;
		BEGIN
		
			SELECT * BULK COLLECT
			INTO   vresult
			FROM   treferencemonthlyfee
			WHERE  branch = pbranch
			ORDER  BY profileid;
		
			IF pindexbyid
			THEN
				FOR i IN 1 .. vresult.count
				LOOP
					vtemp(vresult(i).profileid) := vresult(i);
				END LOOP;
				vresult := vtemp;
			END IF;
		
			RETURN vresult;
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethodname);
				error.save(cmethodname);
				RAISE;
		END int_getmonthlyfeeprofiles;
	
	BEGIN
		RETURN int_getmonthlyfeeprofiles(seance.getbranch, pindexbyid);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getmonthlyfeeprofiles;

	FUNCTION getmonthlyfeeprofile(pprofileid IN NUMBER) RETURN typemonthlyfeerow IS
		cmethodname CONSTANT typemethodname := cpackagename || '.GetMonthlyFeeProfile';
	BEGIN
		RETURN getmonthlyfeeprofiles(pindexbyid => TRUE)(pprofileid);
	EXCEPTION
		WHEN excnull_index_key_value THEN
			error.raiseerror('Monthly fee profile ID is null!');
		WHEN no_data_found THEN
			error.raiseerror('Monthly fee profile with ID <' || pprofileid ||
							 '> is not defined in the reference!');
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getmonthlyfeeprofile;

	FUNCTION getmonthlyfeeprofileentries(pprofileid IN NUMBER) RETURN tblnumber IS
		cmethodname CONSTANT typemethodname := cpackagename || '.GetMonthlyFeeProfileEntries';
	
		FUNCTION int_getmonthlyfeeprofileentries
		(
			pbranch    IN NUMBER
		   ,pprofileid IN NUMBER
		) RETURN tblnumber result_cache IS
			cmethodname CONSTANT typemethodname := cpackagename ||
												   '.Int_GetMonthlyFeeProfileEntries';
			vresult tblnumber;
		BEGIN
		
			SELECT entrycode BULK COLLECT
			INTO   vresult
			FROM   treferencemonthlyfeeentries
			WHERE  branch = pbranch
			AND    profileid = pprofileid;
		
			RETURN vresult;
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethodname);
				error.save(cmethodname);
				RAISE;
		END int_getmonthlyfeeprofileentries;
	
	BEGIN
		RETURN int_getmonthlyfeeprofileentries(seance.getbranch, pprofileid);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getmonthlyfeeprofileentries;

	FUNCTION groupdialog(preadonly IN BOOLEAN := FALSE) RETURN NUMBER IS
		cmethodname  CONSTANT VARCHAR2(100) := cpackagename || '.GroupDialog';
		chandlername CONSTANT VARCHAR2(100) := cpackagename || '.GroupDialogProc';
		vdialog  NUMBER;
		vmenu    NUMBER;
		vsubmenu NUMBER;
	BEGIN
		s.say(cmethodname || '    --<< BEGIN', 1);
		vdialog := dialog.new('Operations groups setup'
							 ,0
							 ,0
							 ,80
							 ,17
							 ,presizable               => TRUE
							 ,pextid                   => cmethodname);
		dialog.hiddenbool(vdialog, c_readonlyflag, preadonly);
		dialog.setdialogpre(vdialog, chandlername);
		dialog.setdialogvalid(vdialog, chandlername);
		dialog.setdialogpost(vdialog, chandlername);
	
		vmenu    := mnu.new(vdialog);
		vsubmenu := mnu.submenu(vmenu, 'Operations', '');
		mnu.item(vsubmenu, 'miImport', 'Import', 0, 0, '');
		dialog.setitempre(vdialog, 'miImport', chandlername);
		mnu.item(vsubmenu, 'miExport', 'Export', 0, 0, '');
		dialog.setitempre(vdialog, 'miExport', chandlername);
	
		dialog.list(vdialog, 'GroupsList', 2, 2, 59, 11, 'Operations groups');
		dialog.setanchor(vdialog, 'GroupsList', dialog.anchor_all);
		dialog.listaddfield(vdialog, 'GroupsList', 'Id', 'N', 4, 1);
		dialog.listaddfield(vdialog, 'GroupsList', 'Name', 'C', 50, 1);
		dialog.setcaption(vdialog, 'GroupsList', 'Code~Group name');
		dialog.setitempost(vdialog, 'GroupsList', chandlername);
		dialog.button(vdialog, 'Insert', 66, 2, 12, 'Add', 0, 0, 'Add new group');
		dialog.setanchor(vdialog, 'Insert', dialog.anchor_right + dialog.anchor_top);
		dialog.button(vdialog, 'Delete', 66, 4, 12, 'Delete', 0, 0, 'Delete selected group');
		dialog.setanchor(vdialog, 'Delete', dialog.anchor_right + dialog.anchor_top);
		dialog.button(vdialog, 'Exit', 66, 13, 12, 'Exit', dialog.cmok, 0, 'Exit dialog');
		dialog.setanchor(vdialog, 'Exit', dialog.anchor_right + dialog.anchor_bottom);
		dialog.setitempre(vdialog, 'Insert', chandlername, dialog.proctype);
		dialog.setitempre(vdialog, 'Delete', chandlername, dialog.proctype);
		s.say(cmethodname || '    -->>  END', 1);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GroupDialog');
			RAISE;
	END;

	FUNCTION getnewentrygroupid RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetNewEntryGroupId';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vgroupid NUMBER;
	BEGIN
		SELECT coalesce(MAX(groupid), 0) + 1
		INTO   vgroupid
		FROM   tcontractentrygroup
		WHERE  branch = cbranch;
		t.leave(cmethodname, 'return ' || to_char(coalesce(vgroupid, 1)));
		RETURN coalesce(vgroupid, 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetNewEntryGroupId');
			RAISE;
	END;

	PROCEDURE insertentrygroup
	(
		pgroupid     NUMBER := NULL
	   ,pgroupname   VARCHAR2
	   ,pcashadvance NUMBER
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.InsertEntryGroup';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vgroupid  NUMBER;
		vpriority NUMBER;
	BEGIN
		t.enter(cmethodname, 'GroupId=' || pgroupid);
		SAVEPOINT sp_insertentrygroup;
		vgroupid := coalesce(pgroupid, getnewentrygroupid());
	
		INSERT INTO tcontractentrygroup
		VALUES
			(cbranch
			,vgroupid
			,pgroupname
			,pcashadvance);
		t.note('inserted');
	
		a4mlog.cleanparamlist;
		a4mlog.addparamrec('Group', vgroupid);
		a4mlog.logobject(object.gettype(contracttype.object_name)
						,'OPER_GROUP=' || vgroupid
						,'Creation'
						,a4mlog.act_add
						,a4mlog.putparamlist);
	
		FOR i IN (SELECT * FROM tcontractprofile WHERE branch = cbranch)
		LOOP
			SELECT nvl(MAX(priority), 0) + 1
			INTO   vpriority
			FROM   tcontractprofilegroup
			WHERE  branch = cbranch
			AND    profileid = i.profileid;
			INSERT INTO tcontractprofilegroup
			VALUES
				(cbranch
				,vgroupid
				,i.profileid
				,vpriority);
		END LOOP;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			ROLLBACK TO sp_insertentrygroup;
			RAISE;
	END;

	PROCEDURE insertentrygroup(prow typeentrygrouprow) IS
	BEGIN
		insertentrygroup(prow.groupid, prow.groupname, prow.cashadvance);
	END;

	PROCEDURE updateentrygroup
	(
		pgroupid       NUMBER
	   ,pgroupname     VARCHAR2
	   ,pcashadvance   NUMBER
	   ,paddonnotfound BOOLEAN := FALSE
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.UpdateEntryGroup';
	
		cbranch CONSTANT NUMBER := seance.getbranch();
		voldrow typeentrygrouprow;
	BEGIN
		t.enter(cmethodname, 'GroupId=' || pgroupid);
		SAVEPOINT sp_updateentrygroup;
	
		SELECT *
		INTO   voldrow
		FROM   tcontractentrygroup
		WHERE  branch = cbranch
		AND    groupid = pgroupid;
	
		UPDATE tcontractentrygroup
		SET    groupname   = pgroupname
			  ,cashadvance = pcashadvance
		WHERE  branch = cbranch
		AND    groupid = pgroupid;
	
		a4mlog.cleanparamlist;
		a4mlog.addparamrec('Group', voldrow.groupid, pgroupid, pcompare => FALSE);
		a4mlog.addparamrec('Name', voldrow.groupname, pgroupname);
		a4mlog.addparamrec('Name', voldrow.cashadvance, pcashadvance);
		a4mlog.logobject(object.gettype(contracttype.object_name)
						,'OPER_GROUP=' || pgroupid
						,'Update'
						,a4mlog.act_change
						,a4mlog.putparamlist);
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN no_data_found THEN
			s.err(cmethodname);
			IF paddonnotfound
			THEN
				insertentrygroup(pgroupid, pgroupname, pcashadvance);
			END IF;
		WHEN OTHERS THEN
			error.save(cmethodname);
			ROLLBACK TO sp_updateentrygroup;
			RAISE;
	END;

	PROCEDURE updateentrygroup
	(
		prow           typeentrygrouprow
	   ,paddonnotfound BOOLEAN := FALSE
	) IS
	BEGIN
		updateentrygroup(prow.groupid, prow.groupname, prow.cashadvance, paddonnotfound);
	END;

	PROCEDURE dlg_operationgroups_filllist(pdialog NUMBER) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.Dlg_OperationGroups_FillList';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		CURSOR c1 IS
			SELECT *
			FROM   tcontractentrygroup
			WHERE  branch = cbranch
			ORDER  BY branch
					 ,groupid;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		dialog.listclear(pdialog, 'GroupsList');
		FOR i IN c1
		LOOP
			dialog.listaddrecord(pdialog, 'GroupsList', i.groupid || '~' || i.groupname || '~');
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE groupdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GroupDialogProc';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	
		vcou NUMBER;
		vmax NUMBER;
		vret NUMBER;
	
		vcurrent NUMBER;
		vname    VARCHAR(50);
	
	BEGIN
		s.say(cmethodname || '    --<< BEGIN', 1);
		IF pwhat = dialog.wtdialogpre
		THEN
		
			dialog.setenable(pdialog, 'Insert', NOT dialog.getbool(pdialog, c_readonlyflag));
			dialog.setenable(pdialog, 'Delete', NOT dialog.getbool(pdialog, c_readonlyflag));
		
			SELECT COUNT(*) INTO vcou FROM tcontractentrygroup WHERE branch = cbranch;
			IF vcou = 0
			THEN
				insertentrygroup(0, 'Other operations', 3);
				contracttools.addentry2reference('CHARGE_INTEREST_GROUP_0'
												,'99'
												,'Charge interest for 0 operations group');
			END IF;
			dlg_operationgroups_filllist(pdialog);
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF pitemname = 'INSERT'
			THEN
				DECLARE
					vnewgroupid NUMBER;
					vcount      NUMBER;
				BEGIN
					SAVEPOINT spitem;
				
					vnewgroupid := getnewentrygroupid;
				
					insertentrygroup(vnewgroupid, 'Other operations', 0);
				
					contracttools.addentry2reference('CHARGE_INTEREST_GROUP_' || vnewgroupid
													,'99'
													,'Charge interest for ' || vnewgroupid);
				
					contracttools.readentcode(vcurrent, 'CHARGE_INTEREST_GROUP_' || vnewgroupid);
				
					DELETE FROM tcontractentrygrouplist
					WHERE  branch = cbranch
					AND    entcode = vcurrent;
				
					SELECT COUNT(*)
					INTO   vcount
					FROM   tcontractentrygroup
					WHERE  branch = cbranch
					AND    groupid = vnewgroupid;
					s.say('try insert into list with groupid=' || vnewgroupid || ', parent count=' ||
						  vcount);
				
					INSERT INTO tcontractentrygrouplist
					VALUES
						(cbranch
						,vnewgroupid
						,vcurrent);
					a4mlog.cleanparamlist;
					a4mlog.addparamrec('Group', vnewgroupid);
					a4mlog.addparamrec('Ident', 'CHARGE_INTEREST_GROUP_' || vnewgroupid);
					a4mlog.addparamrec('EntCode', vcurrent);
					a4mlog.logobject(object.gettype(contracttype.object_name)
									,'OPER_GROUP=' || vnewgroupid
									,'Add operation to group: ' || 'CHARGE_INTEREST_GROUP_' || vmax || '(' ||
									 vcurrent || ')'
									,a4mlog.act_add
									,a4mlog.putparamlist);
					IF dialog.exec(groupsetupdialog(vnewgroupid)) = dialog.cmok
					THEN
						dlg_operationgroups_filllist(pdialog);
						dialog.setcurrecbyvalue(pdialog, 'GroupsList', 'Id', vnewgroupid);
					
						COMMIT;
					ELSE
						ROLLBACK TO spitem;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						ROLLBACK TO spitem;
						RAISE;
				END;
			ELSIF pitemname = 'DELETE'
			THEN
				vret     := dialog.getcurrentrecordnumber(pdialog, 'GROUPSLIST', 'Id');
				vcurrent := dialog.getcurrec(pdialog, 'GROUPSLIST');
				IF vret = 0
				THEN
					htools.sethotmessage('Warning'
										,'This group was created by default and cannot be deleted!');
					RETURN;
				END IF;
				IF htools.ask('Attention', 'Delete selected group?')
				THEN
					BEGIN
						SAVEPOINT spitem;
						FOR i IN (SELECT * FROM tcontractprofile WHERE branch = cbranch)
						LOOP
							BEGIN
								SELECT priority
								INTO   vcou
								FROM   tcontractprofilegroup
								WHERE  branch = cbranch
								AND    profileid = i.profileid
								AND    groupid = vret;
							
								UPDATE tcontractprofilegroup
								SET    priority = priority - 1
								WHERE  branch = cbranch
								AND    profileid = i.profileid
								AND    priority > vcou;
							EXCEPTION
								WHEN no_data_found THEN
									s.err(cmethodname);
							END;
							contractparams.deletevaluepart(getobjecttype, i.profileid, vret);
							referenceprchistory.deletepercentid(referenceprchistory.crvpother1
															   ,i.profileid
															   ,vret || '_CrdPrcHist');
							referenceprchistory.deletepercentid(referenceprchistory.crvpother1
															   ,i.profileid
															   ,vret || '_RedPrcHist');
						END LOOP;
						BEGIN
							SAVEPOINT sp_deletegroup;
						
							DELETE FROM tcontractentrygroup
							WHERE  branch = cbranch
							AND    groupid = vret;
						
							custom_contractexchangetools.deletematchingrows(cpackagename
																		   ,creftable_entrygroups
																		   ,'GroupId'
																		   ,pdestcode => vret);
						
							a4mlog.cleanparamlist;
							a4mlog.addparamrec('Group', vret);
							a4mlog.logobject(object.gettype(contracttype.object_name)
											,'OPER_GROUP=' || vret
											,'Deleting'
											,a4mlog.act_del
											,a4mlog.putparamlist);
						
							dialog.listdeleterecord(pdialog
												   ,'GROUPSLIST'
												   ,dialog.getcurrec(pdialog, 'GROUPSLIST'));
						
							COMMIT;
						EXCEPTION
							WHEN OTHERS THEN
								s.err(cmethodname || '.DeleteGroup');
								ROLLBACK TO sp_deletegroup;
								RAISE;
						END;
					
					EXCEPTION
						WHEN OTHERS THEN
							ROLLBACK TO spitem;
							error.showerror('Error');
							dialog.goitem(pdialog, 'Delete');
					END;
				END IF;
			
			ELSIF pitemname = upper('miExport')
			THEN
				DECLARE
					cbranch CONSTANT VARCHAR2(100) := seance.getbranch();
					vexportsettings custom_contractexchangetools.typeexportsettings;
				BEGIN
					vexportsettings.tablename      := creftable_entrygroups;
					vexportsettings.packagename    := cpackagename;
					vexportsettings.objectname     := cobjectname_entrygroups;
					vexportsettings.whereclause    := 'branch=' || cbranch;
					vexportsettings.orderclause    := 'GroupId';
					vexportsettings.codecolumn     := 'GroupId';
					vexportsettings.identcolumn    := '';
					vexportsettings.namecolumn     := 'GroupName';
					vexportsettings.exportchilds   := TRUE;
					vexportsettings.childtablelist := creftable_entrygrouplist;
					dialog.exec(custom_contractexchangetools.dialogexport(vexportsettings));
				END;
			
			ELSIF pitemname = upper('miImport')
			THEN
				operationgroups_importinteractive(pdialog);
			
			END IF;
		ELSIF pwhat = dialog.wtitempost
		THEN
			IF pitemname = 'GROUPSLIST'
			THEN
				BEGIN
					SAVEPOINT spitem;
					vret     := dialog.getcurrentrecordnumber(pdialog, pitemname, 'Id');
					vcurrent := dialog.getcurrec(pdialog, pitemname);
					IF dialog.exec(groupsetupdialog(vret, dialog.getbool(pdialog, c_readonlyflag))) =
					   dialog.cmok
					THEN
						SELECT groupname
						INTO   vname
						FROM   tcontractentrygroup
						WHERE  branch = cbranch
						AND    groupid = vret;
						dialog.listputrecord(pdialog
											,'GROUPSLIST'
											,vret || '~' || vname || '~'
											,vcurrent);
						COMMIT;
					ELSE
						ROLLBACK TO spitem;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						ROLLBACK TO spitem;
						RAISE;
				END;
			END IF;
		END IF;
		s.say(cmethodname || '    -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.showerror('Error');
			dialog.goitem(pdialog, 'Exit');
	END;

	FUNCTION groupsetupdialog
	(
		pgroupid  IN NUMBER
	   ,preadonly IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethodname  CONSTANT VARCHAR2(100) := cpackagename || '.GroupSetupDialog';
		chandlername CONSTANT VARCHAR2(100) := cpackagename || '.GroupSetupDialogProc';
		vdialog NUMBER := 0;
	BEGIN
		s.say(cmethodname || '    --<< BEGIN', 1);
		sgroupid := pgroupid;
		vdialog  := dialog.new('Operations group setup', 0, 0, 92, 10, pextid => cmethodname);
		dialog.hiddenbool(vdialog, c_readonlyflag, preadonly);
		dialog.setdialogpre(vdialog, chandlername);
		dialog.setdialogvalid(vdialog, chandlername);
		dialog.setdialogpost(vdialog, chandlername);
	
		dialog.bevel(vdialog, 1, 1, 91, 4, dialog.bevel_frame, pcaption => 'Group parameters');
		dialog.inputinteger(vdialog, 'GroupID', 16, 2, 'Operations group code', 3, 'Group code:');
		dialog.inputchar(vdialog, 'GroupName', 36, 2, 53, 'Specify group name', 50, 'Group name:');
		dialog.inputchar(vdialog
						,'GroupType'
						,36
						,3
						,38
						,'Operations group type'
						,38
						,'Group type:');
		dialog.listaddfield(vdialog, 'GroupType', 'ItemID', 'N', 1, 0);
		dialog.listaddfield(vdialog, 'GroupType', 'ItemName', 'C', 38, 1);
		dialog.listaddrecord(vdialog
							,'GroupType'
							,'0~Non cash advance operations~'
							,dialog.cmconfirm);
		dialog.listaddrecord(vdialog, 'GroupType', '1~Cash advance operations~', dialog.cmconfirm);
		dialog.listaddrecord(vdialog, 'GroupType', '2~Payments~', dialog.cmconfirm);
		dialog.listaddrecord(vdialog, 'GroupType', '3~Other charges~', dialog.cmconfirm);
		dialog.setitemattributies(vdialog, 'GroupType', dialog.updateoff);
		dialog.inputchar(vdialog
						,'EntIdent'
						,36
						,4
						,40
						,'Operation code of interest charging for this group'
						,50
						,'Interest charge operation code:');
		dialog.setitemattributies(vdialog, 'GroupID', dialog.selectoff);
		dialog.setitemattributies(vdialog, 'EntIdent', dialog.selectoff);
	
		dialog.bevel(vdialog, 1, 5, 91, 15, dialog.bevel_frame, pcaption => 'Group operations');
		dialog.list(vdialog, 'OperList', 3, 7, 84, 10, 'Operations groups');
		dialog.listaddfield(vdialog, 'OperList', 'EntCode', 'N', 3, 0);
		dialog.listaddfield(vdialog, 'OperList', 'Mark', 'C', 1, 1);
		dialog.listaddfield(vdialog, 'OperList', 'Ident', 'C', 40, 1);
		dialog.listaddfield(vdialog, 'OperList', 'Name', 'C', 40, 1);
		dialog.setcaption(vdialog, 'OperList', '+~Operation code~Operation name~');
		dialog.setitempost(vdialog, 'OperList', cpackagename || '.GroupSetupDialogProc');
		dialog.button(vdialog, 'Insert', 33, 19, 12, 'Add', 0, 0, 'Add operations');
		dialog.button(vdialog
					 ,'Delete'
					 ,48
					 ,19
					 ,12
					 ,'Delete'
					 ,0
					 ,0
					 ,'Delete marked operations (or selected operation)');
		dialog.setitempre(vdialog, 'Insert', chandlername, dialog.proctype);
		dialog.setitempre(vdialog, 'Delete', chandlername, dialog.proctype);
	
		dialog.button(vdialog
					 ,'Ok'
					 ,33
					 ,21
					 ,12
					 ,'OK'
					 ,dialog.cmok
					 ,0
					 ,'Save changes and exit dialog');
		dialog.button(vdialog
					 ,'Cancel'
					 ,48
					 ,21
					 ,12
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel changes and exit dialog');
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
		s.say(cmethodname || '    -->>  END', 1);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE groupsetupdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GroupSetupDialogProc';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	
		vret  NUMBER;
		vrete NUMBER;
		vretc VARCHAR(50);
	
		PROCEDURE filloperationlist IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.GroupSetupDialogProc.FillOperationList';
			CURSOR c1 IS
				SELECT a.*
				FROM   treferenceentry a
				WHERE  a.branch = cbranch
				AND    a.code NOT IN
					   (SELECT entcode FROM tcontractentrygrouplist WHERE branch = cbranch)
				ORDER  BY a.branch
						 ,a.ident;
		
			CURSOR c2 IS
				SELECT b.*
				FROM   tcontractentrygrouplist a
					  ,treferenceentry         b
				WHERE  a.branch = cbranch
				AND    a.groupid = sgroupid
				AND    b.branch = a.branch
				AND    b.code = a.entcode
				ORDER  BY b.branch
						 ,b.ident;
		
		BEGIN
			s.say(cmethodname || '     --<< BEGIN', 1);
			dialog.listclear(pdialog, 'OperList');
			IF sgroupid = 0
			THEN
				FOR i IN c1
				LOOP
					dialog.listaddrecord(pdialog
										,'OperList'
										,i.code || '~ ~' || i.ident || '~' || i.name || '~');
				END LOOP;
				dialog.setitemattributies(pdialog, 'Insert', dialog.selectoff);
				dialog.setitemattributies(pdialog, 'Delete', dialog.selectoff);
			ELSE
				FOR i IN c2
				LOOP
					dialog.listaddrecord(pdialog
										,'OperList'
										,i.code || '~ ~' || i.ident || '~' || i.name || '~');
				END LOOP;
			
				dialog.setenable(pdialog, 'Insert', NOT dialog.getbool(pdialog, c_readonlyflag));
				dialog.setenable(pdialog, 'Delete', NOT dialog.getbool(pdialog, c_readonlyflag));
			
			END IF;
			s.say(cmethodname || '     -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.GroupSetupDialogProc');
				RAISE;
		END;
	
	BEGIN
		s.say(cmethodname || '    --<< BEGIN', 1);
		IF pwhat = dialog.wtdialogpre
		THEN
		
			dialog.setenable(pdialog, 'Ok', NOT dialog.getbool(pdialog, c_readonlyflag));
		
			SELECT groupid
				  ,groupname
				  ,cashadvance
			INTO   vrete
				  ,vretc
				  ,vret
			FROM   tcontractentrygroup
			WHERE  branch = cbranch
			AND    groupid = sgroupid;
			dialog.putnumber(pdialog, 'GroupID', vrete);
			dialog.putchar(pdialog, 'GroupName', vretc);
			dialog.putchar(pdialog, 'EntIdent', 'CHARGE_INTEREST_GROUP_' || vrete);
			referenceentry.filllist(pdialog, 'EntCode', 0);
			dialog.setcurrecbyvalue(pdialog, 'GroupType', 'ItemId', vret);
			filloperationlist;
		ELSIF pwhat = dialog.wtitempost
		THEN
			IF pitemname = 'OPERLIST'
			THEN
				IF dialog.getcurrentrecordchar(pdialog, 'OperList', 'Mark') = '+'
				THEN
					dialog.listputrecord(pdialog
										,'OperList'
										,dialog.getcurrentrecordnumber(pdialog
																	  ,'OperList'
																	  ,'EntCode') || '~ ~' ||
										 dialog.getcurrentrecordchar(pdialog, 'OperList', 'Ident') || '~' ||
										 dialog.getcurrentrecordchar(pdialog, 'OperList', 'Name') || '~'
										,dialog.getcurrec(pdialog, 'OperList'));
				ELSE
					dialog.listputrecord(pdialog
										,'OperList'
										,dialog.getcurrentrecordnumber(pdialog
																	  ,'OperList'
																	  ,'EntCode') || '~+~' ||
										 dialog.getcurrentrecordchar(pdialog, 'OperList', 'Ident') || '~' ||
										 dialog.getcurrentrecordchar(pdialog, 'OperList', 'Name') || '~'
										,dialog.getcurrec(pdialog, 'OperList'));
				END IF;
			END IF;
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF pitemname = 'INSERT'
			THEN
				IF dialog.exec(operselectdialog) = dialog.cmok
				THEN
					filloperationlist;
				END IF;
			ELSIF pitemname = 'DELETE'
			THEN
				IF (dialog.getlistreccount(pdialog, 'OperList') > 0)
				   AND (htools.ask('Attention', 'Delete selected operation(s) from group?'))
				THEN
					vret := 0;
					FOR i IN 1 .. dialog.getlistreccount(pdialog, 'OperList')
					LOOP
						IF dialog.getrecordchar(pdialog, 'OperList', 'Mark', i) = '+'
						THEN
							vret := vret + 1;
							a4mlog.cleanparamlist;
							a4mlog.addparamrec('Group', sgroupid);
							a4mlog.addparamrec('Ident'
											  ,dialog.getrecordchar(pdialog
																   ,'OperList'
																   ,'Ident'
																   ,i));
							a4mlog.addparamrec('EntCode'
											  ,dialog.getrecordnumber(pdialog
																	 ,'OperList'
																	 ,'EntCode'
																	 ,i));
							a4mlog.logobject(object.gettype(contracttype.object_name)
											,'OPER_GROUP=' || sgroupid
											,'Deleting operation from group: ' ||
											 dialog.getrecordchar(pdialog, 'OperList', 'Ident', i) || '(' ||
											 dialog.getrecordnumber(pdialog
																   ,'OperList'
																   ,'EntCode'
																   ,i) || ')'
											,a4mlog.act_del
											,a4mlog.putparamlist);
							DELETE FROM tcontractentrygrouplist
							WHERE  branch = cbranch
							AND    groupid = sgroupid
							AND    entcode =
								   dialog.getrecordnumber(pdialog, 'OperList', 'EntCode', i);
						END IF;
					END LOOP;
					IF vret > 0
					THEN
						filloperationlist;
					ELSIF dialog.getlistreccount(pdialog, 'OperList') > 0
					THEN
						a4mlog.cleanparamlist;
						a4mlog.addparamrec('Group', sgroupid);
						a4mlog.addparamrec('Ident'
										  ,dialog.getcurrentrecordchar(pdialog
																	  ,'OperList'
																	  ,'Ident'));
						a4mlog.addparamrec('EntCode'
										  ,dialog.getcurrentrecordnumber(pdialog
																		,'OperList'
																		,'EntCode'));
						a4mlog.logobject(object.gettype(contracttype.object_name)
										,'OPER_GROUP=' || sgroupid
										,'Deleting operation from group: ' ||
										 dialog.getcurrentrecordchar(pdialog, 'OperList', 'Ident') || '(' ||
										 dialog.getcurrentrecordnumber(pdialog
																	  ,'OperList'
																	  ,'EntCode') || ')'
										,a4mlog.act_del
										,a4mlog.putparamlist);
						DELETE FROM tcontractentrygrouplist
						WHERE  branch = cbranch
						AND    groupid = sgroupid
						AND    entcode =
							   dialog.getcurrentrecordnumber(pdialog, 'OperList', 'EntCode');
						dialog.listdeleterecord(pdialog
											   ,'OperList'
											   ,dialog.getcurrec(pdialog, 'OperList'));
					END IF;
				END IF;
			END IF;
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			IF pcmd = dialog.cmconfirm
			THEN
				dialog.goitem(pdialog, 'GroupType');
				RETURN;
			ELSIF pcmd = dialog.cmok
			THEN
				vret  := dialog.getcurrentrecordnumber(pdialog, 'GroupType', 'ItemId');
				vretc := ltrim(rtrim(dialog.getchar(pdialog, 'GroupName')));
				IF vretc IS NULL
				THEN
					dialog.goitem(pdialog, 'GroupName');
					RAISE incorrectvalue;
				END IF;
			
				updateentrygroup(sgroupid, vretc, vret);
			END IF;
		END IF;
		s.say(cmethodname || '    -->>  END', 1);
	EXCEPTION
		WHEN incorrectvalue THEN
			dialog.sethothint(pdialog, 'Incorrect value');
			dialog.goitem(pdialog, 'GroupName');
			RETURN;
		WHEN valuenotexists THEN
			dialog.sethothint(pdialog, 'Value not specified');
			dialog.goitem(pdialog, 'EntCode');
			RETURN;
		WHEN OTHERS THEN
			error.showerror('Error');
			dialog.goitem(pdialog, 'Cancel');
	END;

	FUNCTION operselectdialog RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.OperSelectDialog';
		vdialog NUMBER;
	BEGIN
		s.say(cmethodname || '    --<< BEGIN', 1);
		vdialog := dialog.new('Operations select dialog'
							 ,0
							 ,0
							 ,88
							 ,10
							 ,presizable                => TRUE
							 ,pextid                    => cmethodname);
		dialog.setdialogpre(vdialog, cpackagename || '.OperSelectDialogProc');
		dialog.setdialogvalid(vdialog, cpackagename || '.OperSelectDialogProc');
		dialog.setdialogpost(vdialog, cpackagename || '.OperSelectDialogProc');
	
		dialog.checkbox(vdialog
					   ,'LIST'
					   ,2
					   ,1
					   ,83
					   ,19
					   ,'Operations list'
					   ,'~Operation code~Operation name~');
		dialog.setanchor(vdialog, 'LIST', dialog.anchor_all);
		dialog.listaddfield(vdialog, 'LIST', 'EntCode', 'N', 4, 0);
		dialog.listaddfield(vdialog, 'LIST', 'Ident', 'C', 40, 1);
		dialog.listaddfield(vdialog, 'LIST', 'Name', 'C', 40, 1);
	
		dialog.button(vdialog
					 ,'Ok'
					 ,32
					 ,22
					 ,12
					 ,'OK'
					 ,dialog.cmok
					 ,0
					 ,'Add selected operations and exit dialog');
		dialog.setanchor(vdialog, 'Ok', dialog.anchor_bottom);
		dialog.button(vdialog
					 ,'Cancel'
					 ,46
					 ,22
					 ,12
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel changes and exit dialog');
		dialog.setanchor(vdialog, 'Cancel', dialog.anchor_bottom);
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
		s.say(cmethodname || '    -->>  END', 1);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.OperSelectDialog');
			RAISE;
	END;

	PROCEDURE operselectdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.OperSelectDialogProc';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	
		vcheck VARCHAR2(2000);
		vres   NUMBER;
	
		CURSOR c1 IS
			SELECT a.*
			FROM   treferenceentry a
			WHERE  a.branch = cbranch
			AND    a.code NOT IN
				   (SELECT entcode FROM tcontractentrygrouplist WHERE branch = cbranch)
			ORDER  BY a.branch
					 ,a.ident;
	BEGIN
		s.say(cmethodname || '    --<< BEGIN', 1);
		IF pwhat = dialog.wtdialogpre
		THEN
			FOR i IN c1
			LOOP
				dialog.listaddrecord(pdialog
									,'List'
									,i.code || '~' || i.ident || '~' || i.name || '~');
			END LOOP;
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			vcheck := dialog.getchar(pdialog, 'LIST');
			FOR i IN 1 .. nvl(length(vcheck), 0)
			LOOP
				IF substr(vcheck, i, 1) = '1'
				THEN
					INSERT INTO tcontractentrygrouplist
					VALUES
						(cbranch
						,sgroupid
						,dialog.getrecordnumber(pdialog, 'List', 'EntCode', i));
					a4mlog.cleanparamlist;
					a4mlog.addparamrec('Group', sgroupid);
					a4mlog.addparamrec('Ident', dialog.getrecordchar(pdialog, 'List', 'Ident', i));
					a4mlog.addparamrec('EntCode'
									  ,dialog.getrecordnumber(pdialog, 'List', 'EntCode', i));
					vres := a4mlog.logobject(object.gettype(contracttype.object_name)
											,'OPER_GROUP=' || sgroupid
											,'Add operation to group: ' ||
											 dialog.getrecordchar(pdialog, 'List', 'Ident', i) || '(' ||
											 dialog.getrecordnumber(pdialog, 'List', 'EntCode', i) || ')'
											,a4mlog.act_add
											,a4mlog.putparamlist);
				END IF;
			END LOOP;
		END IF;
		s.say(cmethodname || '    -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.showerror('Error');
			dialog.goitem(pdialog, 'Cancel');
	END;

	PROCEDURE dlg_profiles_filllist(pdialog IN NUMBER) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.Dlg_Profiles_FillList';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	BEGIN
		dialog.listclear(pdialog, 'ProfileList');
		FOR i IN (SELECT *
				  FROM   tcontractprofile
				  WHERE  branch = cbranch
				  ORDER  BY branch
						   ,profileid)
		LOOP
			dialog.listaddrecord(pdialog
								,'ProfileList'
								,i.profileid || '~' || i.currency || '~' || i.profilename);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dlg_profiles_filllist;

	PROCEDURE insertprofile
	(
		poid      IN OUT NOCOPY NUMBER
	   ,pname     VARCHAR2 := NULL
	   ,pcurrency NUMBER := 0
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.InsertProfile';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	BEGIN
		SAVEPOINT sp_insertprofile;
		t.enter(cmethodname, 'Name=' || coalesce(pname, '[null]'));
		IF poid IS NULL
		THEN
			SELECT nvl(MAX(profileid), 0) + 1
			INTO   poid
			FROM   tcontractprofile
			WHERE  branch = cbranch;
		END IF;
		INSERT INTO tcontractprofile
		VALUES
			(cbranch
			,poid
			,coalesce(pname, 'New profile ' || poid)
			,pcurrency);
	
		a4mlog.cleanparamlist;
		a4mlog.addparamrec('Profile', poid);
		a4mlog.logobject(object.gettype(contracttype.object_name)
						,'CONTRACT_PROFILE=' || poid
						,'Creation'
						,a4mlog.act_add
						,a4mlog.putparamlist);
	
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			ROLLBACK TO sp_insertprofile;
			RAISE;
	END insertprofile;

	FUNCTION profiledialog(preadonly IN BOOLEAN := FALSE) RETURN NUMBER IS
		cmethodname  CONSTANT typemethodname := cpackagename || '.ProfileDialog';
		chandlername CONSTANT typemethodname := cpackagename || '.ProfileDialogProc';
		vdialog  NUMBER;
		vmenu    NUMBER;
		vsubmenu NUMBER;
	BEGIN
		t.enter(cmethodname);
	
		vdialog := dialog.new('Interest and fees calculation profiles setup'
							 ,0
							 ,0
							 ,80
							 ,17
							 ,presizable                                    => TRUE
							 ,pextid                                        => cmethodname);
	
		dialog.hiddenbool(vdialog, c_readonlyflag, preadonly);
	
		vmenu    := mnu.new(vdialog);
		vsubmenu := mnu.submenu(vmenu, 'Operations', '');
		mnu.item(vsubmenu, 'miImport', 'Import', 0, 0, '');
		dialog.setitempre(vdialog, 'miImport', chandlername);
		mnu.item(vsubmenu, 'miExport', 'Export', 0, 0, '');
		dialog.setitempre(vdialog, 'miExport', chandlername);
	
		dialog.list(vdialog, 'ProfileList', 2, 2, 59, 11, 'Profiles');
		dialog.listaddfield(vdialog, 'ProfileList', 'Id', 'N', 4, 1);
		dialog.listaddfield(vdialog, 'ProfileList', 'Cur', 'N', 8, 1);
		dialog.listaddfield(vdialog, 'ProfileList', 'Name', 'C', 43, 1);
	
		dialog.setcaption(vdialog, 'ProfileList', 'Code~Currency~Profile name');
		dialog.setanchor(vdialog, 'ProfileList', dialog.anchor_all);
		dialog.setitempre(vdialog, 'ProfileList', chandlername);
	
		dlg_profiles_filllist(vdialog);
	
		dlg_tools.drawbutton(vdialog
							,'Insert'
							,66
							,2
							,12
							,'Add'
							,'Add new profile'
							,chandlername
							,preadonly
							,panchor => dialog.anchor_right + dialog.anchor_top);
		dlg_tools.drawbutton(vdialog
							,'Copy'
							,66
							,4
							,12
							,'Copy'
							,'Copy selected profile into new profile'
							,chandlername
							,preadonly
							,panchor => dialog.anchor_right + dialog.anchor_top);
		dlg_tools.drawbutton(vdialog
							,'Delete'
							,66
							,6
							,12
							,'Delete'
							,'Delete selected profile'
							,chandlername
							,preadonly
							,panchor => dialog.anchor_right + dialog.anchor_top);
		dlg_tools.drawbutton(vdialog
							,'Exit'
							,66
							,14
							,12
							,'Exit'
							,'Exit dialog'
							,dialog.cmok
							,pdefault     => TRUE
							,panchor      => dialog.anchor_right + dialog.anchor_top);
	
		t.leave(cmethodname);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END profiledialog;

	PROCEDURE profiledialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.ProfileDialogProc';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		cobjecttype CONSTANT NUMBER := getobjecttype;
	
		vdelinqsettingsprofinfo VARCHAR2(100);
		vcurrent                NUMBER;
		vname                   VARCHAR2(50);
		vprofileid              NUMBER;
		vsourceprofileid        NUMBER;
		vpriority               NUMBER;
		vcurrency               NUMBER;
	
	BEGIN
		t.enter(cmethodname);
	
		IF pwhat = dialog.wtitempre
		THEN
			IF pitemname = 'INSERT'
			THEN
				BEGIN
					SAVEPOINT spitem;
					insertprofile(vprofileid, '');
					vpriority := 0;
					FOR i IN (SELECT *
							  FROM   tcontractentrygroup
							  WHERE  branch = cbranch
							  ORDER  BY branch
									   ,groupid)
					LOOP
						vpriority := vpriority + 1;
						INSERT INTO tcontractprofilegroup
						VALUES
							(cbranch
							,i.groupid
							,vprofileid
							,vpriority);
					END LOOP;
				
					IF dialog.exec(profilesetupdialog(vprofileid)) = dialog.cmok
					THEN
						COMMIT;
						dlg_profiles_filllist(pdialog);
						dialog.setcurrecbyvalue(pdialog, 'ProfileList', 'Id', vprofileid);
					ELSE
						ROLLBACK TO spitem;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						ROLLBACK TO spitem;
						RAISE;
				END;
			ELSIF pitemname = 'COPY'
			THEN
				BEGIN
					SAVEPOINT spitem;
					vsourceprofileid := dialog.getcurrentrecordnumber(pdialog, 'ProfileList', 'Id');
					insertprofile(vprofileid
								 ,NULL
								 ,dialog.getcurrentrecordnumber(pdialog, 'ProfileList', 'Cur'));
				
					INSERT INTO tcontractprofilegroup
						(SELECT cbranch
							   ,a.groupid
							   ,vprofileid
							   ,a.priority
						 FROM   tcontractprofilegroup a
						 WHERE  a.branch = cbranch
						 AND    a.profileid = vsourceprofileid);
				
					INSERT INTO tcontractredintsettings
						(SELECT cbranch
							   ,vprofileid
							   ,groupid
							   ,priority
							   ,terms
							   ,amount
							   ,rateid
							   ,reducedtermusage
						 FROM   tcontractredintsettings
						 WHERE  branch = cbranch
						 AND    profileid = vsourceprofileid);
				
					contractparams.copyparameters(cobjecttype, vsourceprofileid, vprofileid);
					referenceprchistory.copypercentid(referenceprchistory.crvpother1
													 ,vsourceprofileid
													 ,vprofileid);
					IF dialog.exec(profilesetupdialog(vprofileid)) = dialog.cmok
					THEN
						COMMIT;
						dlg_profiles_filllist(pdialog);
						dialog.setcurrecbyvalue(pdialog, 'ProfileList', 'Id', vprofileid);
					ELSE
						ROLLBACK TO spitem;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						ROLLBACK TO spitem;
						RAISE;
				END;
			ELSIF pitemname = 'DELETE'
			THEN
				vprofileid := dialog.getcurrentrecordnumber(pdialog, 'PROFILELIST', 'Id');
				SELECT COUNT(*)
				INTO   vcurrent
				FROM   tcontracttypeparameters
				WHERE  branch = cbranch
				AND    key LIKE 'PROFILE%'
				AND    VALUE = to_char(vprofileid);
				IF vcurrent > 0
				THEN
					htools.sethotmessage('Warning'
										,'This profile already used and cannot be deleted!');
					RETURN;
				END IF;
			
				SELECT COUNT(*)
				INTO   vcurrent
				FROM   tcontractparameters
				WHERE  branch = cbranch
				AND    key LIKE 'PROFILE%'
				AND    VALUE = to_char(vprofileid);
				IF vcurrent > 0
				THEN
					htools.sethotmessage('Warning'
										,'This profile already used in contracts and cannot be deleted!');
					RETURN;
				END IF;
			
				SELECT MIN('Contract type = ' || contracttype || ', Overdue period = ' || period ||
						   ', Overlimit = ' || overlimit)
				INTO   vdelinqsettingsprofinfo
				FROM   tcontractdelinqprofiles
				WHERE  branch = cbranch
				AND    profile = vprofileid;
				IF vdelinqsettingsprofinfo IS NOT NULL
				THEN
					htools.sethotmessage('Warning'
										,'Deleted profile is used currently in Delinquency State settings: ' ||
										 vdelinqsettingsprofinfo);
					RETURN;
				END IF;
			
				IF htools.ask('Attention', 'Delete selected profile?')
				THEN
					BEGIN
						SAVEPOINT spitem;
					
						DELETE FROM tcontractprofile
						WHERE  branch = cbranch
						AND    profileid = vprofileid;
					
						custom_contractexchangetools.deletematchingrows(cpackagename
																	   ,creftable_profiles
																	   ,'ProfileId'
																	   ,pdestcode => to_char(vprofileid));
					
						a4mlog.cleanparamlist;
						a4mlog.addparamrec('Profile', vprofileid);
						a4mlog.logobject(object.gettype(contracttype.object_name)
										,'CONTRACT_PROFILE=' || vprofileid
										,'Deleting'
										,a4mlog.act_del
										,a4mlog.putparamlist);
					
						contractparams.deletevalue(cobjecttype, vprofileid);
						referenceprchistory.deletepercentbelong(referenceprchistory.crvpother1
															   ,vprofileid);
						dialog.listdeleterecord(pdialog
											   ,'PROFILELIST'
											   ,dialog.getcurrec(pdialog, 'PROFILELIST'));
						COMMIT;
					EXCEPTION
						WHEN OTHERS THEN
							ROLLBACK TO spitem;
							error.showerror('Error');
							dialog.goitem(pdialog, 'Delete');
					END;
				END IF;
			ELSIF pitemname = 'PROFILELIST'
			THEN
				BEGIN
					SAVEPOINT spitem;
					vprofileid := dialog.getcurrentrecordnumber(pdialog, pitemname, 'Id');
					vcurrent   := dialog.getcurrec(pdialog, pitemname);
					IF dialog.exec(profilesetupdialog(vprofileid
													 ,dialog.getbool(pdialog, c_readonlyflag))) =
					   dialog.cmok
					THEN
					
						SELECT profilename
							  ,currency
						INTO   vname
							  ,vcurrency
						FROM   tcontractprofile
						WHERE  branch = cbranch
						AND    profileid = vprofileid;
					
						dialog.listputrecord(pdialog
											,'PROFILELIST'
											,vprofileid || '~' || vcurrency || '~' || vname || '~'
											,vcurrent);
						COMMIT;
					ELSE
						ROLLBACK TO spitem;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						ROLLBACK TO spitem;
						RAISE;
				END;
			
			ELSIF pitemname = upper('miExport')
			THEN
				DECLARE
					cbranch CONSTANT VARCHAR2(100) := seance.getbranch();
					vexportsettings custom_contractexchangetools.typeexportsettings;
				BEGIN
					vexportsettings.tablename := creftable_profiles;
					vexportsettings.packagename := cpackagename;
					vexportsettings.objectname := cobjectname_profiles;
					vexportsettings.whereclause := 'branch=' || cbranch;
					vexportsettings.orderclause := 'ProfileID';
					vexportsettings.codecolumn := 'ProfileID';
					vexportsettings.identcolumn := '';
					vexportsettings.namecolumn := 'ProfileName';
					vexportsettings.exportchilds := FALSE;
					vexportsettings.additionalsettings(vexportsettings.tablename).parametersobjecttype := 'CONTRACT_PROFILE';
					dialog.exec(custom_contractexchangetools.dialogexport(vexportsettings));
				END;
			
			ELSIF pitemname = upper('miImport')
			THEN
				profiles_importinteractive(pdialog);
			END IF;
		END IF;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END profiledialogproc;

	FUNCTION profilesetupdialog
	(
		pprofileid IN NUMBER
	   ,preadonly  IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethodname  CONSTANT typemethodname := cpackagename || '.ProfileSetupDialog';
		chandlername CONSTANT typemethodname := cpackagename || '.ProfileSetupDialogProc';
	
		c_dialogwidth  CONSTANT NUMBER := 80;
		c_dialogheight CONSTANT NUMBER := 26;
	
		vdialog  NUMBER;
		vpanel1  NUMBER;
		vpanel2  NUMBER;
		vpanel4  NUMBER;
		vpanel5  NUMBER;
		vmenu    NUMBER;
		vsubmenu NUMBER;
		vpage    NUMBER;
	
		PROCEDURE drawoperationgroupslist
		(
			ppage             IN NUMBER
		   ,pitemname         IN VARCHAR2
		   ,pforrepaymentpage IN BOOLEAN
		) IS
			cmethodname CONSTANT typemethodname := profilesetupdialog.cmethodname ||
												   '.DrawOperationGroupsList';
		BEGIN
			t.enter(cmethodname);
		
			IF pforrepaymentpage
			THEN
				dialog.list(ppage
						   ,pitemname
						   ,3
						   ,6
						   ,58
						   ,8
						   ,'Use "Up" and "Down" buttons to set up operations groups order');
			ELSE
				dialog.list(ppage
						   ,pitemname
						   ,3
						   ,6
						   ,71
						   ,6
						   ,'Click on the operations group to set up interest charge settings');
			END IF;
			dialog.listaddfield(ppage, pitemname, 'Id', 'N', 4, 1);
			dialog.listaddfield(ppage, pitemname, 'Payments', 'C', 8, 1, dialog.align_center);
			dialog.listaddfield(ppage, pitemname, 'Name', 'C', 42, 1);
			dialog.listaddfield(ppage, pitemname, 'GroupType', 'N', 1, 0);
			dialog.setcaption(ppage, pitemname, 'Code~Payments~Group name~');
		
			IF pforrepaymentpage
			THEN
				dlg_tools.drawbutton(ppage
									,'Up'
									,65
									,7
									,12
									,'Up'
									,'Increase repayment priority for selected group'
									,chandlername
									,preadonly
									,panchor => dialog.anchor_right + dialog.anchor_top);
				dlg_tools.drawbutton(ppage
									,'Down'
									,65
									,9
									,12
									,'Down'
									,'Decrease repayment priority for selected group'
									,chandlername
									,preadonly
									,panchor => dialog.anchor_right + dialog.anchor_top);
			
			ELSE
				dialog.setitempost(ppage, pitemname, chandlername);
			END IF;
		
			t.leave(cmethodname);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethodname);
				error.save(cmethodname);
				RAISE;
		END drawoperationgroupslist;
	
		PROCEDURE makepage_repayment(ppage IN NUMBER) IS
			cmethodname CONSTANT typemethodname := profilesetupdialog.cmethodname ||
												   '.MakePage_Repayment';
		BEGIN
			t.enter(cmethodname);
		
			dlg_tools.drawnestedbevel(ppage, 1, 1, 78, 16);
		
			dlg_tools.makedroplist(ppage
								  ,'RepayOrder'
								  ,25
								  ,2
								  ,48
								  ,48
								  ,'Repayment order:'
								  ,'Repayment order');
			dialog.listaddrecord(ppage, 'RepayOrder', '1~Transaction Date then Group Priority');
			dialog.listaddrecord(ppage, 'RepayOrder', '2~Group Priority then Transaction Date');
		
			dlg_tools.makedroplist(ppage
								  ,'RepaySettings'
								  ,25
								  ,3
								  ,48
								  ,48
								  ,'Repayment settings:'
								  ,'Additional repayment settings');
			dialog.listaddrecord(ppage, 'RepaySettings', '1~Not used');
			dialog.listaddrecord(ppage, 'RepaySettings', '2~At first pay billed transactions only');
			dialog.listaddrecord(ppage, 'RepaySettings', '3~Pay transactions by cycles');
		
			dlg_tools.drawnestedbevel(ppage, 1, 4, 78, 16);
		
			drawoperationgroupslist(ppage, 'GroupsListRep', TRUE);
		
			t.leave(cmethodname);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethodname);
				error.save(cmethodname);
				RAISE;
		END makepage_repayment;
	
		PROCEDURE makepage_interestbygroups(ppage IN NUMBER) IS
			cmethodname CONSTANT typemethodname := profilesetupdialog.cmethodname ||
												   '.MakePage_InterestByGroups';
		BEGIN
			t.enter(cmethodname);
		
			dlg_tools.drawnestedbevel(ppage, 1, 1, 78, 16);
		
			dlg_tools.makedroplist(ppage
								  ,'RepayDate'
								  ,25
								  ,2
								  ,18
								  ,18
								  ,'Repayment Date:'
								  ,'Repayment date');
			dialog.listaddrecord(ppage, 'RepayDate', '1~Transaction Date');
			dialog.listaddrecord(ppage, 'RepayDate', '2~Posting Date');
		
			contractsql.makeitem(ppage
								,'TransFullRemarkG'
								,25
								,3
								,2
								,30
								,'Entry full remark'
								,'Entry full remark:'
								,contractsql.ctype_funcchar
								,'DEFAULT'
								,TRUE
								,FALSE
								,sch_customer.scontracttype);
		
			dlg_tools.drawnestedbevel(ppage, 1, 4, 78, 16);
		
			drawoperationgroupslist(ppage, 'GroupsListInt', FALSE);
		
			dialog.inputcheck(ppage
							 ,'ChargeType'
							 ,3
							 ,14
							 ,50
							 ,'Charge interest separately by operation groups'
							 ,'Charge interest separately by operation groups'
							 ,panchor => dialog.anchor_left + dialog.anchor_bottom);
		
			dialog.inputcheck(ppage
							 ,'DivIntByRates'
							 ,3
							 ,15
							 ,50
							 ,'Charge interest separately by rate types'
							 ,'Charge interest separately by rate types'
							 ,panchor => dialog.anchor_left + dialog.anchor_bottom);
		
			t.leave(cmethodname);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethodname);
				error.save(cmethodname);
				RAISE;
		END makepage_interestbygroups;
	
		PROCEDURE makepage_interestbyremain(ppage IN NUMBER) IS
			cmethodname CONSTANT typemethodname := profilesetupdialog.cmethodname ||
												   '.MakePage_InterestByRemain';
		BEGIN
			t.enter(cmethodname);
		
			dlg_tools.drawnestedbevel(ppage, 1, 1, 78, 5);
		
			dlg_tools.makedroplist(ppage
								  ,'IntByRemainChargeType'
								  ,25
								  ,2
								  ,24
								  ,24
								  ,'Charge type:'
								  ,'Charge type'
								  ,chandlername);
			dialog.listaddrecord(ppage, 'IntByRemainChargeType', '1~Do not charge');
			dialog.listaddrecord(ppage, 'IntByRemainChargeType', '2~Flat amount on tiers');
		
			dlg_tools.makedroplist(ppage
								  ,'IntByRemainRate'
								  ,25
								  ,3
								  ,24
								  ,24
								  ,'Regular rate:'
								  ,'Regular rate for interest calculation');
		
			contractsql.makeitem(ppage
								,'TransFullRemarkR'
								,25
								,4
								,2
								,30
								,'Entry full remark'
								,'Entry full remark:'
								,contractsql.ctype_funcchar
								,'DEFAULT'
								,TRUE
								,FALSE
								,sch_customer.scontracttype);
		
			t.leave(cmethodname);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethodname);
				error.save(cmethodname);
				RAISE;
		END makepage_interestbyremain;
	
	BEGIN
		t.enter(cmethodname);
	
		vdialog := dialog.new('Profile setup' || CASE
								  WHEN pprofileid IS NOT NULL THEN
								   ' <ID=' || pprofileid || '>'
							  END
							 ,0
							 ,0
							 ,c_dialogwidth
							 ,c_dialogheight
							 ,presizable => TRUE
							 ,pextid => cmethodname);
	
		sprofileid := pprofileid;
	
		stypefillarray.delete;
		stypefillarray(1).pcategory := referenceprchistory.ccontracttype;
		stypefillarray(1).pno := NULL;
	
		dialog.hiddenbool(vdialog, c_readonlyflag, preadonly);
	
		vmenu := mnu.new(vdialog);
	
		vsubmenu := mnu.submenu(vmenu, 'Dictionaries', 'Dictionaries');
		mnu.item(vsubmenu, 'HoliDays', 'Dictionary of calendars', 0, 0, 'Dictionary of calendars');
		mnu.item(vsubmenu
				,'SprGroup'
				,'Dictionary of operations groups'
				,0
				,0
				,'Dictionary of operations groups');
		mnu.item(vsubmenu
				,'SprPrcProfSetup'
				,'Dictionary of interest rates'
				,0
				,0
				,'Dictionary of interest rates');
		dialog.setitempre(vdialog, 'HoliDays', chandlername);
		dialog.setitempre(vdialog, 'SprGroup', chandlername);
		dialog.setitempre(vdialog, 'SprPrcProfSetup', chandlername);
		dialog.setitempost(vdialog, 'SprPrcProfSetup', chandlername);
		contractsql.addmenu(vsubmenu
						   ,vsubmenu
						   ,'SprRemark'
						   ,'Dictionary of entry full remark'
						   ,contractsql.ctype_funcchar
						   ,'DEFAULT'
						   ,preadonly
						   ,NULL
						   ,TRUE
						   ,sch_customer.scontracttype
						   ,'SCH_Customer');
	
		dialog.bevel(vdialog, 1, 1, 79, 4, dialog.bevel_frame);
	
		dialog.inputchar(vdialog
						,'ProfileName'
						,20
						,2
						,57
						,'Specify profile name'
						,50
						,'Profile name:');
	
		referencecurrency.makeitem(vdialog
								  ,'Cur'
								  ,20
								  ,3
								  ,3
								  ,'Currency:'
								  ,'Currency code of profile'
								  ,50
								  ,FALSE
								  ,TRUE
								  ,TRUE);
	
		dlg_tools.makedroplist(vdialog
							  ,'IntMode'
							  ,20
							  ,4
							  ,22
							  ,22
							  ,'Charge interest:'
							  ,'Interest charge mode'
							  ,chandlername);
		dialog.listaddrecord(vdialog, 'IntMode', '1~By operation groups');
		dialog.listaddrecord(vdialog, 'IntMode', '2~By remaining balance');
	
		dialog.pagelist(vdialog, 'PAGER', 1, 6, 79, 17);
	
		vpage := dialog.page(vdialog, 'PAGER', 'Repayment', 'Repayment');
		makepage_repayment(vpage);
	
		vpage := dialog.page(vdialog, 'PAGER', 'Interest', 'InterestG');
		makepage_interestbygroups(vpage);
	
		vpage := dialog.page(vdialog, 'PAGER', 'Interest', 'InterestR');
		makepage_interestbyremain(vpage);
	
		vpanel2 := dialog.page(vdialog, 'PAGER', 'Overdue Fee', 'OverdueFee');
		dialog.bevel(vpanel2, 1, 1, 78, 6, dialog.bevel_frame);
	
		dlg_tools.makedroplist(vpanel2
							  ,'OvdValAllow'
							  ,28
							  ,2
							  ,32
							  ,30
							  ,'Allowable Overdue:'
							  ,'Allowable Overdue value');
		dialog.listaddrecord(vpanel2, 'OvdValAllow', '1~Not allowable', dialog.cmconfirm);
		dialog.listaddrecord(vpanel2, 'OvdValAllow', '2~Calculate as total of', dialog.cmconfirm);
		dialog.listaddrecord(vpanel2
							,'OvdValAllow'
							,'3~Calculate as maximum between'
							,dialog.cmconfirm);
		dialog.listaddrecord(vpanel2
							,'OvdValAllow'
							,'4~Calculate as minimum between'
							,dialog.cmconfirm);
	
		dialog.inputmoney(vpanel2
						 ,'OvdValAllowAmount'
						 ,28
						 ,3
						 ,'Allowable overdue flat amount value'
						 ,'Flat amount:');
		dialog.inputmoney(vpanel2
						 ,'OvdValAllowPrc'
						 ,56
						 ,3
						 ,'Allowable percentage overdue value'
						 ,'Percentage:'
						 ,plen => 6);
	
		dlg_tools.makedroplist(vpanel2
							  ,'OvdFeeDate'
							  ,28
							  ,4
							  ,32
							  ,30
							  ,'Charge date:'
							  ,'Overdue Fee charge date');
		dialog.listaddrecord(vpanel2, 'OvdFeeDate', '1~Statement Date');
		dialog.listaddrecord(vpanel2, 'OvdFeeDate', '2~Payment Due Date');
	
		contractsql.makeitem(vpanel2
							,'TransFullRemarkOF'
							,28
							,5
							,3
							,30
							,'Entry full remark'
							,'Entry full remark:'
							,contractsql.ctype_funcchar
							,'DEFAULT'
							,TRUE
							,FALSE
							,sch_customer.scontracttype);
	
		dialog.pagelist(vpanel2, 'OLFPAGER', 1, 8, 77, 8);
		vpanel5 := dialog.page(vpanel2, 'OLFPAGER', 'Regular Fee Amount');
		dialog.bevel(vpanel5, 1, 1, 76, 5, dialog.bevel_frame);
	
		dlg_tools.makedroplist(vpanel5
							  ,'OvdFeeType'
							  ,26
							  ,2
							  ,32
							  ,30
							  ,'Charge type:'
							  ,'Overdue Fee charge type'
							  ,chandlername);
		dialog.listaddrecord(vpanel5, 'OvdFeeType', covdfeecalctype_notused || '~Not used');
		dialog.listaddrecord(vpanel5
							,'OvdFeeType'
							,covdfeecalctype_astotal || '~Charge fee as total of');
		dialog.listaddrecord(vpanel5
							,'OvdFeeType'
							,covdfeecalctype_asmax || '~Charge fee as maximum between');
		dialog.listaddrecord(vpanel5
							,'OvdFeeType'
							,covdfeecalctype_asmin || '~Charge fee as minimum between');
		dialog.listaddrecord(vpanel5
							,'OvdFeeType'
							,covdfeecalctype_asinterest || '~Charge interest');
	
		dlg_tools.makedroplist(vpanel5
							  ,'OvdFeeBase'
							  ,26
							  ,3
							  ,32
							  ,30
							  ,'Overdue fee base:'
							  ,'Overdue fee base');
		dialog.listaddrecord(vpanel5, 'OvdFeeBase', '1~Unpaid MP on due date', dialog.cmconfirm);
		dialog.listaddrecord(vpanel5, 'OvdFeeBase', '2~Statement date amount', dialog.cmconfirm);
	
		dialog.inputmoney(vpanel5
						 ,'OvdFeeAmount'
						 ,26
						 ,4
						 ,'Charge flat amount for overdue payment'
						 ,'Flat amount:');
		dialog.inputmoney(vpanel5
						 ,'OvdFeePrc'
						 ,54
						 ,4
						 ,'Charge percentage value for overdue payment'
						 ,'Percentage:'
						 ,plen => 6);
	
		dlg_tools.makedroplist(vpanel5
							  ,'OvdFeeInterestRat'
							  ,26
							  ,3
							  ,32
							  ,24
							  ,'Rate:'
							  ,'Interest rate for overdue fee calculation');
		dialog.setvisible(vpanel5, 'OvdFeeInterestRat', FALSE);
	
		dialog.inputinteger(vpanel5, 'OvdFeeDaysInYear', 26, 4, 'Days in year', 3, 'Days in year:');
		dialog.setvisible(vpanel5, 'OvdFeeDaysInYear', FALSE);
	
		dialog.inputmoney(vpanel5
						 ,'OvdMinAmount'
						 ,26
						 ,5
						 ,'Minimum overdue amount'
						 ,pcaption                => 'Minimum:'
						 ,plen                    => 10);
		dialog.inputmoney(vpanel5
						 ,'OvdMaxAmount'
						 ,50
						 ,5
						 ,'Miximum overdue amount'
						 ,pcaption                => 'Maximum:'
						 ,plen                    => 10);
	
		vpanel5 := dialog.page(vpanel2, 'OLFPAGER', 'Promotional Fee Amount');
		dialog.bevel(vpanel5, 1, 1, 76, 6, dialog.bevel_frame);
	
		dlg_tools.makedroplist(vpanel5
							  ,'RedOvdFeeType'
							  ,26
							  ,2
							  ,32
							  ,30
							  ,'Charge type:'
							  ,'Overdue Fee charge type'
							  ,chandlername);
		dialog.listaddrecord(vpanel5, 'RedOvdFeeType', covdfeecalctype_notused || '~Not used');
		dialog.listaddrecord(vpanel5
							,'RedOvdFeeType'
							,covdfeecalctype_astotal || '~Charge fee as total of');
		dialog.listaddrecord(vpanel5
							,'RedOvdFeeType'
							,covdfeecalctype_asmax || '~Charge fee as maximum between');
		dialog.listaddrecord(vpanel5
							,'RedOvdFeeType'
							,covdfeecalctype_asmin || '~Charge fee as minimum between');
		dialog.listaddrecord(vpanel5
							,'RedOvdFeeType'
							,covdfeecalctype_asinterest || '~Charge interest');
	
		dlg_tools.makedroplist(vpanel5
							  ,'RedOvdFeeBase'
							  ,26
							  ,3
							  ,32
							  ,30
							  ,'Overdue fee base:'
							  ,'Overdue fee base');
		dialog.listaddrecord(vpanel5, 'RedOvdFeeBase', '1~Unpaid MP on due date', dialog.cmconfirm);
		dialog.listaddrecord(vpanel5, 'RedOvdFeeBase', '2~Statement date amount', dialog.cmconfirm);
	
		dialog.inputmoney(vpanel5
						 ,'RedOvdFeeAmount'
						 ,26
						 ,4
						 ,'Charge flat amount for overdue payment'
						 ,'Flat amount:');
		dialog.inputmoney(vpanel5
						 ,'RedOvdFeePrc'
						 ,54
						 ,4
						 ,'Charge percentage value for overdue payment'
						 ,'Percentage:'
						 ,plen => 6);
	
		dlg_tools.makedroplist(vpanel5
							  ,'RedOvdFeeInterestRat'
							  ,26
							  ,3
							  ,32
							  ,24
							  ,'Rate:'
							  ,'Interest rate for overdue fee calculation');
		dialog.setvisible(vpanel5, 'RedOvdFeeInterestRat', FALSE);
	
		dialog.inputinteger(vpanel5
						   ,'RedOvdFeeDaysInYear'
						   ,26
						   ,4
						   ,'Days in year'
						   ,3
						   ,'Days in year:');
		dialog.setvisible(vpanel5, 'RedOvdFeeDaysInYear', FALSE);
	
		dialog.inputmoney(vpanel5
						 ,'RedOvdMinAmount'
						 ,26
						 ,5
						 ,'Minimum overdue amount'
						 ,pcaption                => 'Minimum:'
						 ,plen                    => 10);
		dialog.inputmoney(vpanel5
						 ,'RedOvdMaxAmount'
						 ,50
						 ,5
						 ,'Miximum overdue amount'
						 ,pcaption                => 'Maximum:'
						 ,plen                    => 10);
	
		referencecalendar.inputcalendar(vpanel5
									   ,'RedOvdFeePeriod'
									   ,26
									   ,6
									   ,40
									   ,'Using Calendar:'
									   ,'Calendar of Promotional Rate Using');
	
		vpanel4 := dialog.page(vdialog, 'PAGER', 'Over-Limit Fee');
		dialog.bevel(vpanel4, 1, 1, 78, 7, dialog.bevel_frame);
	
		dlg_tools.makedroplist(vpanel4
							  ,'OvrLmtAllow'
							  ,28
							  ,2
							  ,32
							  ,30
							  ,'Allowable Over-Limit:'
							  ,'Allowable Over-Limit value');
		dialog.listaddrecord(vpanel4
							,'OvrLmtAllow'
							,'1~Calculate as maximum between'
							,dialog.cmconfirm);
		dialog.listaddrecord(vpanel4
							,'OvrLmtAllow'
							,'2~Calculate as minimum between'
							,dialog.cmconfirm);
	
		dialog.inputmoney(vpanel4
						 ,'OvrLmtAllowAmount'
						 ,28
						 ,3
						 ,'Allowable flat amount over-limit value'
						 ,'Flat amount:');
		dialog.inputmoney(vpanel4
						 ,'OvrLmtAllowPrc'
						 ,56
						 ,3
						 ,'Allowable percentage over-limit value'
						 ,'Percentage:'
						 ,plen => 6);
	
		dlg_tools.makedroplist(vpanel4
							  ,'OvrLmtTerms'
							  ,28
							  ,4
							  ,32
							  ,30
							  ,'Charging terms:'
							  ,'Over-Limit Fee charging condition');
		dialog.listaddrecord(vpanel4
							,'OvrLmtTerms'
							,'1~Limit Excess within Cycle'
							,dialog.cmconfirm);
		dialog.listaddrecord(vpanel4
							,'OvrLmtTerms'
							,'2~Limit Excess on Statement Date'
							,dialog.cmconfirm);
	
		dlg_tools.makedroplist(vpanel4
							  ,'OvrLmtBased'
							  ,28
							  ,5
							  ,32
							  ,30
							  ,'Over-Limit Fee Base:'
							  ,'Over-Limit Fee Based on');
		dialog.listaddrecord(vpanel4
							,'OvrLmtBased'
							,'1~Limit Excess within Cycle'
							,dialog.cmconfirm);
		dialog.listaddrecord(vpanel4
							,'OvrLmtBased'
							,'2~Limit Excess on Statement Date'
							,dialog.cmconfirm);
	
		contractsql.makeitem(vpanel4
							,'TransFullRemarkOLF'
							,28
							,6
							,3
							,30
							,'Entry full remark'
							,'Entry full remark:'
							,contractsql.ctype_funcchar
							,'DEFAULT'
							,TRUE
							,FALSE
							,sch_customer.scontracttype);
	
		dialog.inputcheck(vpanel4
						 ,'IgnoreCorpOvl'
						 ,28
						 ,7
						 ,41
						 ,'Charge overlimit fee regardless of overlimit in corporate contract'
						 ,'Charge regardless of corporate overlimit');
	
		dialog.pagelist(vpanel4, 'OLFPAGER', 1, 9, 77, 7);
		vpanel1 := dialog.page(vpanel4, 'OLFPAGER', 'Regular Fee Amount');
		dialog.bevel(vpanel1, 1, 1, 76, 5, dialog.bevel_frame);
	
		dlg_tools.makedroplist(vpanel1
							  ,'OvrLmtType'
							  ,28
							  ,2
							  ,32
							  ,30
							  ,'Charge type:'
							  ,'Over-Limit Fee charge type');
	
		dlg_tools.makedroplist(vpanel1
							  ,'OvrPrcHist'
							  ,28
							  ,3
							  ,32
							  ,60
							  ,'Interest rate:'
							  ,'Choose history of interest rates for the over-limit');
	
		dialog.inputmoney(vpanel1
						 ,'OvrLmtAmount'
						 ,28
						 ,3
						 ,'Charge flat amount for over-limit'
						 ,'Flat amount:');
		dialog.inputmoney(vpanel1
						 ,'OvrLmtPrc'
						 ,56
						 ,3
						 ,'Charge percentage value for over-limit'
						 ,'Percentage:'
						 ,plen => 6);
		dialog.inputinteger(vpanel1
						   ,'OvrLmtYear'
						   ,28
						   ,4
						   ,'Specify days number in year(by default days number in current year)'
						   ,3
						   ,pcaption => 'Days in year:');
	
		vpanel1 := dialog.page(vpanel4, 'OLFPAGER', 'Promotional Fee Amount');
		dialog.bevel(vpanel1, 1, 1, 76, 5, dialog.bevel_frame);
	
		dlg_tools.makedroplist(vpanel1
							  ,'RedOvrLmtType'
							  ,28
							  ,2
							  ,32
							  ,30
							  ,'Charge type:'
							  ,'Over-Limit Fee charge type');
	
		dlg_tools.makedroplist(vpanel1
							  ,'RedOvrPrcHist'
							  ,28
							  ,3
							  ,32
							  ,60
							  ,'Interest rate:'
							  ,'Choose history of interest rates for the over-limit');
	
		dialog.inputmoney(vpanel1
						 ,'RedOvrLmtAmount'
						 ,28
						 ,3
						 ,'Charge flat amount for over-limit'
						 ,'Flat amount:');
		dialog.inputmoney(vpanel1
						 ,'RedOvrLmtPrc'
						 ,56
						 ,3
						 ,'Charge percentage value for over-limit'
						 ,'Percentage:'
						 ,plen => 6);
		dialog.inputinteger(vpanel1
						   ,'RedOvrLmtYear'
						   ,28
						   ,4
						   ,'Specify days number in year(by default days number in current year)'
						   ,3
						   ,pcaption => 'Days in year:');
		referencecalendar.inputcalendar(vpanel1
									   ,'RedOvrLmtPeriod'
									   ,28
									   ,5
									   ,40
									   ,'Using Calendar:'
									   ,'Calendar of Promotional Rate Using');
	
		dlg_tools.startbuttondrawing(c_dialogwidth, 2);
		dlg_tools.drawbutton(vdialog
							,'Ok'
							,'OK'
							,'Save changes and exit dialog'
							,c_dialogheight - 2
							,dialog.cmok
							,preadonly
							,TRUE
							,dialog.anchor_bottom);
		dlg_tools.drawbutton(vdialog
							,'Cancel'
							,'Cancel'
							,'Cancel changes and exit dialog'
							,c_dialogheight - 2
							,dialog.cmcancel
							,panchor => dialog.anchor_bottom);
	
		dialog.setdialogpre(vdialog, chandlername);
		dialog.setdialogvalid(vdialog, chandlername);
		dialog.setdialogpost(vdialog, chandlername);
	
		t.leave(cmethodname);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END profilesetupdialog;

	PROCEDURE profilesetupdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ProfileSetupDialogProc';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		cobjecttype CONSTANT NUMBER := getobjecttype;
	
		CURSOR c1 IS
			SELECT b.*
			FROM   tcontractprofilegroup a
				  ,tcontractentrygroup   b
			WHERE  a.branch = cbranch
			AND    a.profileid = sprofileid
			AND    b.branch = a.branch
			AND    b.groupid = a.groupid
			ORDER  BY a.branch
					 ,a.profileid
					 ,a.priority;
	
		vret    NUMBER;
		vretred NUMBER;
		vretbon NUMBER;
		vretc   VARCHAR(50);
		vclnd   NUMBER;
	
		PROCEDURE fillgrouplists IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.ProfileSetupDialogProc.FillGroupLists';
			vrepid NUMBER;
			vintid NUMBER;
		BEGIN
			t.enter(cmethodname);
		
			vrepid := dialog.getcurrentrecordnumber(pdialog, 'GroupsListRep', 'Id');
			vintid := dialog.getcurrentrecordnumber(pdialog, 'GroupsListInt', 'Id');
		
			dialog.listclear(pdialog, 'GroupsListRep');
			dialog.listclear(pdialog, 'GroupsListInt');
			FOR i IN c1
			LOOP
				dialog.listaddrecord(pdialog
									,'GroupsListRep'
									,i.groupid || '~' || service.iif(i.cashadvance = 2, '*', ' ') || '~' ||
									 i.groupname || '~' || i.cashadvance || '~');
				dialog.listaddrecord(pdialog
									,'GroupsListInt'
									,i.groupid || '~' || service.iif(i.cashadvance = 2, '*', ' ') || '~' ||
									 i.groupname || '~' || i.cashadvance || '~');
			END LOOP;
		
			dialog.setcurrecbyvalue(pdialog, 'GroupsListRep', 'Id', vrepid);
			dialog.setcurrecbyvalue(pdialog, 'GroupsListInt', 'Id', vintid);
		
			t.leave(cmethodname);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname);
				RAISE;
		END fillgrouplists;
	
		PROCEDURE ovdfeeitems
		(
			ptype IN NUMBER
		   ,psign IN VARCHAR
		)
		
		 IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.ProfileSetupDialogProc.OvdFeeItems';
		BEGIN
			s.say(cmethodname || '     --<< BEGIN pType: ' || ptype, 1);
			IF ptype = covdfeecalctype_notused
			THEN
			
				dialog.setvisible(pdialog, psign || 'OvdFeeBase', TRUE);
				dialog.setvisible(pdialog, psign || 'OvdFeeAmount', TRUE);
				dialog.setvisible(pdialog, psign || 'OvdFeePrc', TRUE);
				dialog.setvisible(pdialog, psign || 'OvdFeeDaysInYear', FALSE);
				dialog.setvisible(pdialog, psign || 'OvdFeeInterestRat', FALSE);
				dialog.setitemattributies(pdialog, psign || 'OvdFeeDaysInYear', dialog.echooff);
				dialog.setitemattributies(pdialog, psign || 'OvdFeeInterestRat', dialog.echooff);
			
				dialog.setitemattributies(pdialog, psign || 'OvdFeeAmount', dialog.selectoff);
				dialog.setitemattributies(pdialog, psign || 'OvdFeePrc', dialog.selectoff);
				dialog.setitemattributies(pdialog, psign || 'OvdFeePeriod', dialog.selectoff);
			
				dialog.setitemattributies(pdialog, psign || 'OvdFeeBase', dialog.selectoff);
			
				IF psign IS NULL
				THEN
					dialog.setcurrec(pdialog, 'RedOvdFeeType', 1);
					dialog.setitemattributies(pdialog, 'RedOvdFeeType', dialog.selectoff);
					dialog.setitemattributies(pdialog, 'RedOvdFeeAmount', dialog.selectoff);
					dialog.setitemattributies(pdialog, 'RedOvdFeePrc', dialog.selectoff);
					dialog.setitemattributies(pdialog, 'RedOvdFeePeriod', dialog.selectoff);
				
					dialog.setitemattributies(pdialog, 'RedOvdFeeBase', dialog.selectoff);
				
				END IF;
			
			ELSIF ptype IN (covdfeecalctype_astotal, covdfeecalctype_asmax, covdfeecalctype_asmin)
			THEN
			
				dialog.setvisible(pdialog, psign || 'OvdFeeBase', TRUE);
				dialog.setvisible(pdialog, psign || 'OvdFeeAmount', TRUE);
				dialog.setvisible(pdialog, psign || 'OvdFeePrc', TRUE);
				dialog.setvisible(pdialog, psign || 'OvdFeeDaysInYear', FALSE);
				dialog.setvisible(pdialog, psign || 'OvdFeeInterestRat', FALSE);
				dialog.setitemattributies(pdialog, psign || 'OvdFeeDaysInYear', dialog.echooff);
				dialog.setitemattributies(pdialog, psign || 'OvdFeeInterestRat', dialog.echooff);
			
				dialog.setitemattributies(pdialog, psign || 'OvdFeeAmount', dialog.selecton);
				dialog.setitemattributies(pdialog, psign || 'OvdFeePrc', dialog.selecton);
				dialog.setitemattributies(pdialog, psign || 'OvdFeePeriod', dialog.selecton);
			
				dialog.setitemattributies(pdialog, psign || 'OvdFeeBase', dialog.selecton);
			
				IF psign IS NULL
				THEN
					dialog.setitemattributies(pdialog, 'RedOvdFeeType', dialog.selecton);
				
					dialog.setitemattributies(pdialog, 'RedOvdFeeBase', dialog.selecton);
				
				END IF;
			
			ELSIF ptype = covdfeecalctype_asinterest
			THEN
				dialog.setvisible(pdialog, psign || 'OvdFeeBase', FALSE);
				dialog.setvisible(pdialog, psign || 'OvdFeeAmount', FALSE);
				dialog.setvisible(pdialog, psign || 'OvdFeePrc', FALSE);
				dialog.setvisible(pdialog, psign || 'OvdFeeDaysInYear', TRUE);
				dialog.setvisible(pdialog, psign || 'OvdFeeInterestRat', TRUE);
				dialog.setitemattributies(pdialog, psign || 'OvdFeeDaysInYear', dialog.echoon);
				dialog.setitemattributies(pdialog, psign || 'OvdFeeInterestRat', dialog.echoon);
				dialog.setitemattributies(pdialog, psign || 'OvdFeePeriod', dialog.selecton);
			
			END IF;
		
			IF ptype = covdfeecalctype_astotal
			   AND psign IS NULL
			THEN
				dialog.setenable(pdialog, 'OvdMinAmount', TRUE);
				dialog.setenable(pdialog, 'OvdMaxAmount', TRUE);
			ELSIF ptype <> covdfeecalctype_astotal
				  AND psign IS NULL
			THEN
				dialog.setenable(pdialog, 'OvdMinAmount', FALSE);
				dialog.setenable(pdialog, 'OvdMaxAmount', FALSE);
				dialog.putnumber(pdialog, 'OvdMinAmount', NULL);
				dialog.putnumber(pdialog, 'OvdMaxAmount', NULL);
			ELSIF ptype = covdfeecalctype_astotal
				  AND psign IS NOT NULL
			THEN
				dialog.setenable(pdialog, 'RedOvdMinAmount', TRUE);
				dialog.setenable(pdialog, 'RedOvdMaxAmount', TRUE);
			ELSIF ptype <> covdfeecalctype_astotal
				  AND psign IS NOT NULL
			THEN
				dialog.setenable(pdialog, 'RedOvdMinAmount', FALSE);
				dialog.setenable(pdialog, 'RedOvdMaxAmount', FALSE);
				dialog.putnumber(pdialog, 'RedOvdMinAmount', NULL);
				dialog.putnumber(pdialog, 'RedOvdMaxAmount', NULL);
			END IF;
		
			s.say(cmethodname || '     -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname);
				RAISE;
		END;
	
		PROCEDURE ovllmtitems
		(
			ptype IN NUMBER
		   ,psign IN VARCHAR
		) IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.ProfileSetupDialogProc.OvlLmtItems';
		BEGIN
			s.say(cmethodname || '     --<< BEGIN', 1);
			IF ptype = 1
			THEN
				dialog.setitemattributies(pdialog, psign || 'OvrPrcHist', dialog.echooff);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtYear', dialog.echooff);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtAmount', dialog.echoon);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtPrc', dialog.echoon);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtAmount', dialog.selectoff);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtPrc', dialog.selectoff);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtPeriod', dialog.selectoff);
				IF psign IS NULL
				THEN
					dialog.setitemattributies(pdialog, 'RedOvrLmtType', dialog.selectoff);
					dialog.setcurrec(pdialog, 'RedOvrLmtType', 1);
					ovllmtitems(1, 'Red');
				END IF;
			ELSIF ptype = 2
			THEN
				dialog.setitemattributies(pdialog, psign || 'OvrPrcHist', dialog.echoon);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtYear', dialog.echoon);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtAmount', dialog.echooff);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtPrc', dialog.echooff);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtPeriod', dialog.selecton);
				IF psign IS NULL
				THEN
					dialog.setitemattributies(pdialog, 'RedOvrLmtType', dialog.selecton);
				END IF;
			ELSIF ptype IN (3, 4, 5)
			THEN
				dialog.setitemattributies(pdialog, psign || 'OvrPrcHist', dialog.echooff);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtYear', dialog.echooff);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtAmount', dialog.echoon);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtPrc', dialog.echoon);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtAmount', dialog.selecton);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtPrc', dialog.selecton);
				dialog.setitemattributies(pdialog, psign || 'OvrLmtPeriod', dialog.selecton);
				IF psign IS NULL
				THEN
					dialog.setitemattributies(pdialog, 'RedOvrLmtType', dialog.selecton);
				END IF;
			END IF;
			s.say(cmethodname || '     -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.ProfileSetupDialogProc.OvlLmtItems');
				RAISE;
		END;
		PROCEDURE ovdawlitems(ptype IN NUMBER) IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.ProfileSetupDialogProc.OvdAwlItems';
		BEGIN
			s.say(cmethodname || '      --<< BEGIN ' || 'pType: ' || ptype, 1);
		
			IF ptype = 1
			THEN
				dialog.setitemattributies(pdialog, 'OvdValAllowAmount', dialog.selectoff);
				dialog.setitemattributies(pdialog, 'OvdValAllowPrc', dialog.selectoff);
			ELSIF ptype IN (2, 3, 4)
			THEN
				dialog.setitemattributies(pdialog, 'OvdValAllowAmount', dialog.selecton);
				dialog.setitemattributies(pdialog, 'OvdValAllowPrc', dialog.selecton);
			END IF;
			s.say(cmethodname || '     -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.ProfileSetupDialogProc.OvdAwlItems');
				RAISE;
		END;
	
		PROCEDURE switchinterestpage
		(
			pdialog       IN NUMBER
		   ,pprefixtoshow IN VARCHAR2
		   ,pprefixtohide IN VARCHAR2
		) IS
			cmethodname CONSTANT typemethodname := profilesetupdialogproc.cmethodname ||
												   '.SwitchInterestPage';
			vneedactivate BOOLEAN;
		BEGIN
			t.enter(cmethodname);
		
			vneedactivate := dialog.getcurpage(dialog.idbyname(pdialog, 'PAGER')) IN
							 (dialog.idbyname(pdialog, 'InterestG')
							 ,dialog.idbyname(pdialog, 'InterestR'));
		
			dialog.setvisible(dialog.idbyname(pdialog, 'Interest' || pprefixtoshow), TRUE);
			dialog.setvisible(dialog.idbyname(pdialog, 'Interest' || pprefixtohide), FALSE);
		
			IF vneedactivate
			THEN
				dialog.setfocus(dialog.idbyname(pdialog, 'Interest' || pprefixtoshow));
			END IF;
		
			contractsql.setcurid(pdialog
								,'TransFullRemark' || pprefixtoshow
								,contractsql.getcurid(pdialog, 'TransFullRemark' || pprefixtohide));
		
			t.leave(cmethodname);
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethodname);
				error.save(cmethodname);
				RAISE;
		END switchinterestpage;
	
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
	
		s.say(cmethodname || ' pWhat: ' || pwhat || ' pDialog: ' || pdialog || ' pItemName: ' ||
			  pitemname || ' pCmd: ' || pcmd
			 ,1);
	
		IF pwhat = dialog.wtdialogpre
		THEN
		
			SELECT profilename
				  ,currency
			INTO   vretc
				  ,vret
			FROM   tcontractprofile
			WHERE  branch = cbranch
			AND    profileid = sprofileid;
			dialog.putchar(pdialog, 'ProfileName', vretc);
			referencecurrency.setdata(pdialog, 'Cur', vret);
			contractparams.loaddialogfieldnumber(pdialog
												,'IntMode'
												,cobjecttype
												,sprofileid
												,NULL
												,1);
			profilesetupdialogproc(dialog.wtnextfield, pdialog, 'IntMode', 0);
		
			contractsql.setcurid(pdialog
								,'TransFullRemarkG'
								,contractparams.loadnumber(cobjecttype
														  ,sprofileid
														  ,'TransFullRemark'
														  ,FALSE));
			contractsql.setcurid(pdialog
								,'TransFullRemarkR'
								,contractparams.loadnumber(cobjecttype
														  ,sprofileid
														  ,'TransFullRemark'
														  ,FALSE));
			contractsql.setcurid(pdialog
								,'TransFullRemarkOF'
								,contractparams.loadnumber(cobjecttype
														  ,sprofileid
														  ,'TransFullRemarkOF'
														  ,FALSE));
			contractsql.setcurid(pdialog
								,'TransFullRemarkOLF'
								,contractparams.loadnumber(cobjecttype
														  ,sprofileid
														  ,'TransFullRemarkOLF'
														  ,FALSE));
		
			contractparams.loaddialognumber(pdialog, 'OvdMinAmount', cobjecttype, sprofileid);
			contractparams.loaddialognumber(pdialog, 'OvdMaxAmount', cobjecttype, sprofileid);
			contractparams.loaddialognumber(pdialog, 'RedOvdMinAmount', cobjecttype, sprofileid);
			contractparams.loaddialognumber(pdialog, 'RedOvdMaxAmount', cobjecttype, sprofileid);
		
			contractparams.loaddialogfieldnumber(pdialog
												,'RepayOrder'
												,cobjecttype
												,sprofileid
												,NULL
												,1);
			contractparams.loaddialogfieldnumber(pdialog
												,'RepayDate'
												,cobjecttype
												,sprofileid
												,NULL
												,1);
			contractparams.loaddialogfieldnumber(pdialog
												,'RepaySettings'
												,cobjecttype
												,sprofileid
												,NULL
												,1);
			contractparams.loaddialogbool(pdialog, 'ChargeType', cobjecttype, sprofileid);
			contractparams.loaddialogbool(pdialog, 'DivIntByRates', cobjecttype, sprofileid);
			fillgrouplists;
		
			contractparams.loaddialogfieldnumber(pdialog
												,'IntByRemainChargeType'
												,cobjecttype
												,sprofileid
												,NULL
												,1);
			referenceprchistory.fillitem(pdialog
										,'IntByRemainRate'
										,referenceprchistory.cremain
										,referenceprchistory.crvpother1
										,sprofileid
										,stypefillarray);
			profilesetupdialogproc(dialog.wtnextfield, pdialog, 'IntByRemainChargeType', 0);
		
			vret := contractparams.loaddialogfieldnumber(pdialog
														,'OvdValAllow'
														,cobjecttype
														,sprofileid
														,NULL
														,1);
			contractparams.loaddialognumber(pdialog, 'OvdValAllowAmount', cobjecttype, sprofileid);
			contractparams.loaddialognumber(pdialog, 'OvdValAllowPrc', cobjecttype, sprofileid);
			ovdawlitems(vret);
			contractparams.loaddialogfieldnumber(pdialog
												,'OvdFeeDate'
												,cobjecttype
												,sprofileid
												,NULL
												,1);
		
			vret := contractparams.loaddialogfieldnumber(pdialog
														,'OvdFeeType'
														,cobjecttype
														,sprofileid
														,NULL
														,1);
		
			IF vret = covdfeecalctype_asinterest
			THEN
				referenceprchistory.fillitem(pdialog
											,'OvdFeeInterestRat'
											,referenceprchistory.cperiodremain
											,referenceprchistory.crvpother1
											,sprofileid
											,stypefillarray);
				contractparams.loaddialognumber(pdialog
											   ,'OvdFeeDaysInYear'
											   ,cobjecttype
											   ,sprofileid);
			END IF;
		
			ovdfeeitems(vret, '');
		
			vret := contractparams.loaddialogfieldnumber(pdialog
														,'OvdFeeBase'
														,cobjecttype
														,sprofileid
														,NULL
														,1);
			vret := contractparams.loaddialogfieldnumber(pdialog
														,'RedOvdFeeBase'
														,cobjecttype
														,sprofileid
														,NULL
														,1);
		
			contractparams.loaddialognumber(pdialog, 'OvdFeeAmount', cobjecttype, sprofileid);
			contractparams.loaddialognumber(pdialog, 'OvdFeePrc', cobjecttype, sprofileid);
			vret := contractparams.loaddialogfieldnumber(pdialog
														,'RedOvdFeeType'
														,cobjecttype
														,sprofileid
														,NULL
														,1);
		
			IF vret = covdfeecalctype_asinterest
			THEN
				referenceprchistory.fillitem(pdialog
											,'RedOvdFeeInterestRat'
											,referenceprchistory.cperiodremain
											,referenceprchistory.crvpother1
											,sprofileid
											,stypefillarray);
				contractparams.loaddialognumber(pdialog
											   ,'RedOvdFeeDaysInYear'
											   ,cobjecttype
											   ,sprofileid);
			END IF;
		
			ovdfeeitems(vret, 'Red');
			contractparams.loaddialognumber(pdialog, 'RedOvdFeeAmount', cobjecttype, sprofileid);
			contractparams.loaddialognumber(pdialog, 'RedOvdFeePrc', cobjecttype, sprofileid);
			referencecalendar.setclndtodialog(pdialog
											 ,'RedOvdFeePeriod'
											 ,contractparams.loadnumber(cobjecttype
																	   ,sprofileid
																	   ,'RedOvdFeePeriod'
																	   ,FALSE));
		
			contractparams.loaddialogfieldnumber(pdialog
												,'OvrLmtAllow'
												,cobjecttype
												,sprofileid
												,NULL
												,1);
			contractparams.loaddialognumber(pdialog, 'OvrLmtAllowAmount', cobjecttype, sprofileid);
			contractparams.loaddialognumber(pdialog, 'OvrLmtAllowPrc', cobjecttype, sprofileid);
			contractparams.loaddialogfieldnumber(pdialog
												,'OvrLmtTerms'
												,cobjecttype
												,sprofileid
												,NULL
												,1);
			vretbon := contractparams.loaddialogfieldnumber(pdialog
														   ,'OvrLmtBased'
														   ,cobjecttype
														   ,sprofileid
														   ,NULL
														   ,1);
		
			contractparams.loaddialogbool(pdialog, 'IgnoreCorpOvl', cobjecttype, sprofileid);
		
			dialog.listaddrecord(pdialog, 'OvrLmtType', '1~Not used~', dialog.cmconfirm);
			dialog.listaddrecord(pdialog, 'RedOvrLmtType', '1~Not used~', dialog.cmconfirm);
			IF vretbon = 1
			THEN
				dialog.listaddrecord(pdialog, 'OvrLmtType', '2~Charge interest~', dialog.cmconfirm);
				dialog.listaddrecord(pdialog
									,'RedOvrLmtType'
									,'2~Charge interest~'
									,dialog.cmconfirm);
			END IF;
			dialog.listaddrecord(pdialog
								,'OvrLmtType'
								,'3~Charge fee as total of~'
								,dialog.cmconfirm);
			dialog.listaddrecord(pdialog
								,'OvrLmtType'
								,'4~Charge fee as maximum between~'
								,dialog.cmconfirm);
			dialog.listaddrecord(pdialog
								,'OvrLmtType'
								,'5~Charge fee as minimum between~'
								,dialog.cmconfirm);
			dialog.listaddrecord(pdialog
								,'RedOvrLmtType'
								,'3~Charge fee as total of~'
								,dialog.cmconfirm);
			dialog.listaddrecord(pdialog
								,'RedOvrLmtType'
								,'4~Charge fee as maximum between~'
								,dialog.cmconfirm);
			dialog.listaddrecord(pdialog
								,'RedOvrLmtType'
								,'5~Charge fee as minimum between~'
								,dialog.cmconfirm);
		
			vret := contractparams.loaddialogfieldnumber(pdialog
														,'OvrLmtType'
														,cobjecttype
														,sprofileid
														,NULL
														,2);
			ovllmtitems(vret, '');
			contractparams.loaddialognumber(pdialog, 'OvrLmtAmount', cobjecttype, sprofileid);
			contractparams.loaddialognumber(pdialog, 'OvrLmtPrc', cobjecttype, sprofileid);
			contractparams.loaddialognumber(pdialog, 'OvrLmtYear', cobjecttype, sprofileid);
			referenceprchistory.fillitem(pdialog
										,'OvrPrcHist'
										,referenceprchistory.cperiodremain
										,referenceprchistory.crvpother1
										,sprofileid
										,stypefillarray);
		
			vret := contractparams.loaddialogfieldnumber(pdialog
														,'RedOvrLmtType'
														,cobjecttype
														,sprofileid
														,NULL
														,2);
			ovllmtitems(vret, 'Red');
			contractparams.loaddialognumber(pdialog, 'RedOvrLmtAmount', cobjecttype, sprofileid);
			contractparams.loaddialognumber(pdialog, 'RedOvrLmtPrc', cobjecttype, sprofileid);
			contractparams.loaddialognumber(pdialog, 'RedOvrLmtYear', cobjecttype, sprofileid);
			referencecalendar.setclndtodialog(pdialog
											 ,'RedOvrLmtPeriod'
											 ,contractparams.loadnumber(cobjecttype
																	   ,sprofileid
																	   ,'RedOvrLmtPeriod'
																	   ,FALSE));
			referenceprchistory.fillitem(pdialog
										,'RedOvrPrcHist'
										,referenceprchistory.cperiodremain
										,referenceprchistory.crvpother1
										,sprofileid
										,stypefillarray);
		
		ELSIF pwhat = dialog.wtnextfield
		THEN
			IF pitemname = 'OVDFEETYPE'
			THEN
				vret := dialog.getcurrentrecordnumber(pdialog, pitemname, 'ItemId');
				ovdfeeitems(vret, '');
				IF vret = covdfeecalctype_asinterest
				THEN
					referenceprchistory.fillitem(pdialog
												,'OvdFeeInterestRat'
												,referenceprchistory.cperiodremain
												,referenceprchistory.crvpother1
												,sprofileid
												,stypefillarray);
				END IF;
			ELSIF pitemname = 'REDOVDFEETYPE'
			THEN
				vret := dialog.getcurrentrecordnumber(pdialog, pitemname, 'ItemId');
				ovdfeeitems(vret, 'Red');
				IF vret = covdfeecalctype_asinterest
				THEN
					referenceprchistory.fillitem(pdialog
												,'RedOvdFeeInterestRat'
												,referenceprchistory.cperiodremain
												,referenceprchistory.crvpother1
												,sprofileid
												,stypefillarray);
				END IF;
			
			ELSIF upper(pitemname) = 'INTMODE'
			THEN
				IF dialog.getcurrentrecordnumber(pdialog, pitemname, 'ItemId') = 1
				THEN
					switchinterestpage(pdialog, 'G', 'R');
				ELSE
					switchinterestpage(pdialog, 'R', 'G');
				END IF;
			
			ELSIF upper(pitemname) = 'INTBYREMAINCHARGETYPE'
			THEN
				dlg_tools.setenabled(pdialog
									,tblchar100('IntByRemainRate', 'TransFullRemarkR')
									,dialog.getcurrentrecordnumber(pdialog, pitemname, 'ItemId') <> 1);
			END IF;
		ELSIF pwhat = dialog.wtitempost
		THEN
			IF pitemname = 'GROUPSLISTINT'
			THEN
				BEGIN
					SAVEPOINT spitem;
					vret := dialog.getcurrentrecordnumber(pdialog, pitemname, 'Id');
					IF dialog.exec(profilegroupsetupdialog(vret)) != dialog.cmok
					THEN
						ROLLBACK TO spitem;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						ROLLBACK TO spitem;
						RAISE;
				END;
			ELSIF pitemname = 'SPRPRCPROFSETUP'
			THEN
				referenceprchistory.fillitem(pdialog
											,'OvrPrcHist'
											,referenceprchistory.cperiodremain
											,referenceprchistory.crvpother1
											,sprofileid
											,stypefillarray);
			END IF;
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF pitemname = 'UP'
			THEN
				vret := dialog.getcurrec(pdialog, 'GROUPSLISTREP');
				IF vret = 1
				THEN
					RETURN;
				END IF;
				UPDATE tcontractprofilegroup
				SET    priority = priority - 1
				WHERE  branch = cbranch
				AND    profileid = sprofileid
				AND    groupid = dialog.getcurrentrecordnumber(pdialog, 'GROUPSLISTREP', 'Id');
				UPDATE tcontractprofilegroup
				SET    priority = priority + 1
				WHERE  branch = cbranch
				AND    profileid = sprofileid
				AND    groupid = dialog.getrecordnumber(pdialog, 'GROUPSLISTREP', 'Id', vret - 1);
				fillgrouplists;
				COMMIT;
			ELSIF pitemname = 'DOWN'
			THEN
				vret := dialog.getcurrec(pdialog, 'GROUPSLISTREP');
				IF vret = dialog.getlistreccount(pdialog, 'GROUPSLISTREP')
				THEN
					RETURN;
				END IF;
				UPDATE tcontractprofilegroup
				SET    priority = priority + 1
				WHERE  branch = cbranch
				AND    profileid = sprofileid
				AND    groupid = dialog.getcurrentrecordnumber(pdialog, 'GROUPSLISTREP', 'Id');
				UPDATE tcontractprofilegroup
				SET    priority = priority - 1
				WHERE  branch = cbranch
				AND    profileid = sprofileid
				AND    groupid = dialog.getrecordnumber(pdialog, 'GROUPSLISTREP', 'Id', vret + 1);
				fillgrouplists;
				COMMIT;
			ELSIF pitemname = 'HOLIDAYS'
			THEN
				referencecalendar.startup(dialog.getbool(pdialog, c_readonlyflag));
				referencecalendar.fillcalendarlist(pdialog
												  ,upper('RedOvrLmtPeriod')
												  ,referencecalendar.getcalendars
												  ,FALSE);
			ELSIF pitemname = 'SPRGROUP'
			THEN
				dialog.exec(contractprofiles.groupdialog(dialog.getbool(pdialog, c_readonlyflag)));
				fillgrouplists;
			ELSIF pitemname = 'SPRPRCPROFSETUP'
			THEN
				dialog.exec(referenceprchistory.maindialog(referenceprchistory.ccontracttype
														  ,NULL
														  ,preadonly => dialog.getbool(pdialog
																					  ,c_readonlyflag)));
				referenceprchistory.fillitem(pdialog
											,'OvrPrcHist'
											,referenceprchistory.cperiodremain
											,referenceprchistory.crvpother1
											,sprofileid
											,stypefillarray);
			END IF;
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			IF pcmd = dialog.cmconfirm
			THEN
				vret := dialog.getcurrentrecordnumber(pdialog, pitemname, 'ItemId');
				IF pitemname = 'OVRLMTTYPE'
				THEN
					ovllmtitems(vret, '');
				ELSIF pitemname = 'REDOVRLMTTYPE'
				THEN
					ovllmtitems(vret, 'Red');
				ELSIF pitemname = 'OVDFEETYPE'
				THEN
					ovdfeeitems(vret, '');
				ELSIF pitemname = 'OVDVALALLOW'
				THEN
					ovdawlitems(vret);
				ELSIF pitemname = 'REDOVDFEETYPE'
				THEN
					ovdfeeitems(vret, 'Red');
				ELSIF pitemname = 'OVRLMTBASED'
				THEN
					vret    := dialog.getcurrentrecordnumber(pdialog, 'OvrLmtType', 'ItemId');
					vretred := dialog.getcurrentrecordnumber(pdialog, 'RedOvrLmtType', 'ItemId');
					dialog.listclear(pdialog, 'OvrLmtType');
					dialog.listclear(pdialog, 'RedOvrLmtType');
					dialog.listaddrecord(pdialog, 'OvrLmtType', '1~Not used', dialog.cmconfirm);
					dialog.listaddrecord(pdialog, 'RedOvrLmtType', '1~Not used', dialog.cmconfirm);
					IF dialog.getcurrec(pdialog, pitemname) = 1
					THEN
						dialog.listaddrecord(pdialog
											,'OvrLmtType'
											,'2~Charge interest'
											,dialog.cmconfirm);
						dialog.listaddrecord(pdialog
											,'RedOvrLmtType'
											,'2~Charge interest'
											,dialog.cmconfirm);
					ELSE
						IF vret = 2
						THEN
							vret := 1;
						END IF;
						IF vretred = 2
						THEN
							vretred := 1;
						END IF;
					END IF;
					dialog.listaddrecord(pdialog
										,'OvrLmtType'
										,'3~Charge fee as total of'
										,dialog.cmconfirm);
					dialog.listaddrecord(pdialog
										,'OvrLmtType'
										,'4~Charge fee as maximum between'
										,dialog.cmconfirm);
					dialog.listaddrecord(pdialog
										,'OvrLmtType'
										,'5~Charge fee as minimum between'
										,dialog.cmconfirm);
					dialog.listaddrecord(pdialog
										,'RedOvrLmtType'
										,'3~Charge fee as total of'
										,dialog.cmconfirm);
					dialog.listaddrecord(pdialog
										,'RedOvrLmtType'
										,'4~Charge fee as maximum between'
										,dialog.cmconfirm);
					dialog.listaddrecord(pdialog
										,'RedOvrLmtType'
										,'5~Charge fee as minimum between'
										,dialog.cmconfirm);
					dialog.setcurrecbyvalue(pdialog, 'OvrLmtType', 'ItemId', vret);
					dialog.setcurrecbyvalue(pdialog, 'RedOvrLmtType', 'ItemId', vretred);
					ovllmtitems(vret, '');
					ovllmtitems(vretred, 'Red');
				END IF;
				dialog.goitem(pdialog, pitemname);
			
			ELSIF pcmd = dialog.cmok
			THEN
				BEGIN
				
					contractparams.savedialogfieldnumber(pdialog
														,'RepayOrder'
														,cobjecttype
														,sprofileid
														,pwhitelog   => TRUE
														,pparamname  => 'Repayment order');
					contractparams.savedialogfieldnumber(pdialog
														,'RepaySettings'
														,cobjecttype
														,sprofileid
														,pwhitelog      => TRUE
														,pparamname     => 'Additional repayment settings');
				
					IF dialog.getcurrentrecordnumber(pdialog, 'IntMode', 'ItemId') = 1
					THEN
						contractparams.savedialogfieldnumber(pdialog
															,'RepayDate'
															,cobjecttype
															,sprofileid
															,pwhitelog   => TRUE
															,pparamname  => 'Repayment date');
						contractparams.savenumber(cobjecttype
												 ,sprofileid
												 ,'TransFullRemark'
												 ,contractsql.getcurid(pdialog, 'TransFullRemarkG')
												 ,pwhitelog => TRUE
												 ,pparamname => 'TransFullRemark');
						contractparams.savedialogbool(pdialog
													 ,'ChargeType'
													 ,cobjecttype
													 ,sprofileid
													 ,pwhitelog   => TRUE
													 ,pparamname  => 'Charge interest separately by operation groups');
						contractparams.savedialogbool(pdialog
													 ,'DivIntByRates'
													 ,cobjecttype
													 ,sprofileid
													 ,pwhitelog      => TRUE
													 ,pparamname     => 'Charge interest separately by rate types');
					ELSE
					
						IF contractparams.savedialogfieldnumber(pdialog
															   ,'IntByRemainChargeType'
															   ,cobjecttype
															   ,sprofileid
															   ,pwhitelog              => TRUE
															   ,pparamname             => 'Interest charge type') <> 1
						THEN
						
							referenceprchistory.saveitem(pdialog
														,'IntByRemainRate'
														,referenceprchistory.crvpother1
														,sprofileid);
						
							contractparams.savenumber(cobjecttype
													 ,sprofileid
													 ,'TransFullRemark'
													 ,contractsql.getcurid(pdialog
																		  ,'TransFullRemarkR')
													 ,pwhitelog => TRUE
													 ,pparamname => 'TransFullRemark');
						
						END IF;
					
					END IF;
				
					contractparams.savedialogfieldnumber(pdialog
														,'OvrLmtAllow'
														,cobjecttype
														,sprofileid
														,pwhitelog    => TRUE
														,pparamname   => 'Allowable Over-Limit value');
					contractparams.savedialognumber(pdialog
												   ,'OvrLmtAllowAmount'
												   ,cobjecttype
												   ,sprofileid
												   ,pwhitelog          => TRUE
												   ,pparamname         => 'Allowable flat amount over-limit value');
					contractparams.savedialognumber(pdialog
												   ,'OvrLmtAllowPrc'
												   ,cobjecttype
												   ,sprofileid
												   ,pwhitelog       => TRUE
												   ,pparamname      => 'Allowable percentage over-limit value');
					contractparams.savedialogfieldnumber(pdialog
														,'OvrLmtTerms'
														,cobjecttype
														,sprofileid
														,pwhitelog    => TRUE
														,pparamname   => 'Over-Limit Fee charging condition');
					contractparams.savedialogfieldnumber(pdialog
														,'OvrLmtBased'
														,cobjecttype
														,sprofileid
														,pwhitelog    => TRUE
														,pparamname   => 'Over-Limit Fee Based on');
					contractparams.savedialogbool(pdialog
												 ,'IgnoreCorpOvl'
												 ,cobjecttype
												 ,sprofileid
												 ,pwhitelog      => TRUE
												 ,pparamname     => 'Charge overlimit fee regardless of overlimit in corporate contract');
				
					IF dialog.getnumber(pdialog, 'OvdMinAmount') IS NOT NULL
					   AND dialog.getnumber(pdialog, 'OvdMaxAmount') IS NOT NULL
					   AND (dialog.getnumber(pdialog, 'OvdMinAmount') >=
							dialog.getnumber(pdialog, 'OvdMaxAmount'))
					THEN
						dialog.sethothint(pdialog
										 ,'Minimum amount should not be more than Maximum amount');
						dialog.goitem(pdialog, 'OvdMinAmount');
						RETURN;
					ELSE
						contractparams.savedialognumber(pdialog
													   ,'OvdMinAmount'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog     => TRUE
													   ,pparamname    => 'OvdMinAmount'
													   ,pisnull       => TRUE);
						contractparams.savedialognumber(pdialog
													   ,'OvdMaxAmount'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog     => TRUE
													   ,pparamname    => 'OvdMaxAmount'
													   ,pisnull       => TRUE);
					END IF;
				
					IF dialog.getnumber(pdialog, 'RedOvdMinAmount') IS NOT NULL
					   AND dialog.getnumber(pdialog, 'RedOvdMaxAmount') IS NOT NULL
					   AND (dialog.getnumber(pdialog, 'RedOvdMinAmount') >=
							dialog.getnumber(pdialog, 'RedOvdMaxAmount'))
					THEN
						dialog.sethothint(pdialog
										 ,'Minimum amount should not be more than Maximum amount');
						dialog.goitem(pdialog, 'RedOvdMinAmount');
						RETURN;
					ELSE
						contractparams.savedialognumber(pdialog
													   ,'RedOvdMinAmount'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog        => TRUE
													   ,pparamname       => 'RedOvdMinAmount'
													   ,pisnull          => TRUE);
						contractparams.savedialognumber(pdialog
													   ,'RedOvdMaxAmount'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog        => TRUE
													   ,pparamname       => 'RedOvdMaxAmount'
													   ,pisnull          => TRUE);
					END IF;
				
					vret := contractparams.savedialogfieldnumber(pdialog
																,'OvrLmtType'
																,cobjecttype
																,sprofileid
																,pwhitelog   => TRUE
																,pparamname  => 'Over-Limit Fee charge type');
					IF vret = 2
					THEN
						referenceprchistory.saveitem(pdialog
													,'OvrPrcHist'
													,referenceprchistory.crvpother1
													,sprofileid);
						contractparams.savedialognumber(pdialog
													   ,'OvrLmtYear'
													   ,cobjecttype
													   ,sprofileid
													   ,TRUE
													   ,pwhitelog   => TRUE
													   ,pparamname  => 'Days in year for Over-limit Fee');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvrLmtAmount');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvrLmtPrc');
					ELSIF vret IN (3, 4, 5)
					THEN
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvrLmtYear');
						contractparams.savedialognumber(pdialog
													   ,'OvrLmtAmount'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog     => TRUE
													   ,pparamname    => 'Over-limit Fee Flat amount');
						contractparams.savedialognumber(pdialog
													   ,'OvrLmtPrc'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog   => TRUE
													   ,pparamname  => 'Over-limit Fee Percentage Value');
					ELSE
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvrLmtYear');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvrLmtAmount');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvrLmtPrc');
					END IF;
				
					vret := contractparams.savedialogfieldnumber(pdialog
																,'RedOvrLmtType'
																,cobjecttype
																,sprofileid
																,pwhitelog      => TRUE
																,pparamname     => 'Over-limit Promotional Fee charge type');
					IF vret = 2
					THEN
						referenceprchistory.saveitem(pdialog
													,'RedOvrPrcHist'
													,referenceprchistory.crvpother1
													,sprofileid);
						contractparams.savedialognumber(pdialog
													   ,'RedOvrLmtYear'
													   ,cobjecttype
													   ,sprofileid
													   ,TRUE
													   ,pwhitelog      => TRUE
													   ,pparamname     => 'Days in year for Over-limit Promotional Fee');
						vclnd := referencecalendar.getclndfromdialog(pdialog, 'RedOvrLmtPeriod');
						IF vclnd IS NULL
						THEN
							dialog.goitem(pdialog, 'RedOvrLmtPeriod');
							RAISE contractparams.valuenotexists;
						END IF;
						contractparams.savenumber(cobjecttype
												 ,sprofileid
												 ,'RedOvrLmtPeriod'
												 ,vclnd
												 ,pwhitelog        => TRUE
												 ,pparamname       => 'Calendar of Promotional Over-limit Fee Using');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvrLmtAmount');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvrLmtPrc');
					ELSIF vret IN (3, 4, 5)
					THEN
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvrLmtYear');
						contractparams.savedialognumber(pdialog
													   ,'RedOvrLmtAmount'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog        => TRUE
													   ,pparamname       => 'Promotional Over-limit Fee Flat amount');
						contractparams.savedialognumber(pdialog
													   ,'RedOvrLmtPrc'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog     => TRUE
													   ,pparamname    => 'Promotional Over-limit Fee Percentage Value');
						vclnd := referencecalendar.getclndfromdialog(pdialog, 'RedOvrLmtPeriod');
						IF vclnd IS NULL
						THEN
							dialog.goitem(pdialog, 'RedOvrLmtPeriod');
							RAISE contractparams.valuenotexists;
						END IF;
						contractparams.savenumber(cobjecttype
												 ,sprofileid
												 ,'RedOvrLmtPeriod'
												 ,vclnd
												 ,pwhitelog        => TRUE
												 ,pparamname       => 'Calendar of Promotional Over-limit Fee Using');
					ELSE
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvrLmtYear');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvrLmtAmount');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvrLmtPrc');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvrLmtPeriod');
					END IF;
				
					IF contractparams.savedialogfieldnumber(pdialog
														   ,'OvdValAllow'
														   ,cobjecttype
														   ,sprofileid
														   ,pwhitelog    => TRUE
														   ,pparamname   => 'Allowable overdue amount calculation type') IN
					   (2, 3, 4)
					THEN
						contractparams.savedialognumber(pdialog
													   ,'OvdValAllowAmount'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog          => TRUE
													   ,pparamname         => 'Allowable Overdue Flat amount');
						contractparams.savedialognumber(pdialog
													   ,'OvdValAllowPrc'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog       => TRUE
													   ,pparamname      => 'Overdue Percentage Value');
					ELSE
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdValAllowAmount');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdValAllowPrc');
					END IF;
				
					contractparams.savedialogfieldnumber(pdialog
														,'OvdFeeDate'
														,cobjecttype
														,sprofileid
														,pwhitelog   => TRUE
														,pparamname  => 'Overdue Fee Charging Date');
				
					contractparams.savenumber(cobjecttype
											 ,sprofileid
											 ,'TransFullRemarkOF'
											 ,contractsql.getcurid(pdialog, 'TransFullRemarkOF')
											 ,pwhitelog => TRUE
											 ,pparamname => 'TransFullRemarkOF');
					contractparams.savenumber(cobjecttype
											 ,sprofileid
											 ,'TransFullRemarkOLF'
											 ,contractsql.getcurid(pdialog, 'TransFullRemarkOLF')
											 ,pwhitelog => TRUE
											 ,pparamname => 'TransFullRemarkOLF');
				
					IF contractparams.savedialogfieldnumber(pdialog
														   ,'OvdFeeType'
														   ,cobjecttype
														   ,sprofileid
														   ,pwhitelog   => TRUE
														   ,pparamname  => 'Overdue Fee charge type') IN
					   (2, 3, 4)
					THEN
						contractparams.savedialognumber(pdialog
													   ,'OvdFeeAmount'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog     => TRUE
													   ,pparamname    => 'Overdue Fee Flat amount');
						contractparams.savedialognumber(pdialog
													   ,'OvdFeePrc'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog   => TRUE
													   ,pparamname  => 'Overdue Fee Percentage Value');
					
						contractparams.savedialogfieldnumber(pdialog
															,'OvdFeeBase'
															,cobjecttype
															,sprofileid
															,pwhitelog   => TRUE
															,pparamname  => 'Overdue Fee Base');
					
					ELSE
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeeAmount');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeePrc');
					
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeeBase');
					
					END IF;
				
					vret := contractparams.savedialogfieldnumber(pdialog
																,'OvdFeeType'
																,cobjecttype
																,sprofileid
																,pwhitelog   => TRUE
																,pparamname  => 'Overdue fee caclulation type');
					IF vret = covdfeecalctype_asinterest
					THEN
						referenceprchistory.saveitem(pdialog
													,'OvdFeeInterestRat'
													,referenceprchistory.crvpother1
													,sprofileid);
						contractparams.savedialognumber(pdialog
													   ,'OvdFeeDaysInYear'
													   ,cobjecttype
													   ,sprofileid
													   ,TRUE
													   ,pwhitelog         => TRUE
													   ,pparamname        => 'Days in year for overdue fee calculation');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeeBase');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeeAmount');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeePrc');
					ELSIF vret IN
						  (covdfeecalctype_astotal, covdfeecalctype_asmax, covdfeecalctype_asmin)
					THEN
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeeInterestRat');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeeDaysInYear');
						contractparams.savedialogfieldnumber(pdialog
															,'OvdFeeBase'
															,cobjecttype
															,sprofileid
															,pwhitelog   => TRUE
															,pparamname  => 'Overude fee calculation base');
						contractparams.savedialognumber(pdialog
													   ,'OvdFeeAmount'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog     => TRUE
													   ,pparamname    => 'Overdue fee flat amount');
						contractparams.savedialognumber(pdialog
													   ,'OvdFeePrc'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog   => TRUE
													   ,pparamname  => 'Overdue fee percentage');
					ELSE
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeeBase');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeeAmount');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeePrc');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeeInterestRat');
						contractparams.deletevalue(cobjecttype, sprofileid, 'OvdFeeDaysInYear');
					END IF;
				
					vret := contractparams.savedialogfieldnumber(pdialog
																,'RedOvdFeeType'
																,cobjecttype
																,sprofileid
																,pwhitelog      => TRUE
																,pparamname     => 'Reduced Overdue fee caclulation type');
					IF vret = covdfeecalctype_asinterest
					THEN
						referenceprchistory.saveitem(pdialog
													,'RedOvdFeeInterestRat'
													,referenceprchistory.crvpother1
													,sprofileid);
						contractparams.savedialognumber(pdialog
													   ,'RedOvdFeeDaysInYear'
													   ,cobjecttype
													   ,sprofileid
													   ,TRUE
													   ,pwhitelog            => TRUE
													   ,pparamname           => 'Days in year for reduced overdue fee calculation');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvdFeeBase');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvdFeeAmount');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvdFeePrc');
						vclnd := referencecalendar.getclndfromdialog(pdialog, 'RedOvdFeePeriod');
						s.say('!!!!!!!!!! vClnd =' || vclnd, 1);
						IF vclnd IS NULL
						THEN
							dialog.goitem(pdialog, 'RedOvdFeePeriod');
							RAISE contractparams.valuenotexists;
						END IF;
						contractparams.savenumber(cobjecttype
												 ,sprofileid
												 ,'RedOvdFeePeriod'
												 ,vclnd
												 ,pwhitelog        => TRUE
												 ,pparamname       => 'Calendar of Promotional Overdue Fee Using');
					ELSIF vret IN
						  (covdfeecalctype_astotal, covdfeecalctype_asmax, covdfeecalctype_asmin)
					THEN
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvdFeeInterestRat');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvdFeeDaysInYear');
						contractparams.savedialogfieldnumber(pdialog
															,'RedOvdFeeBase'
															,cobjecttype
															,sprofileid
															,pwhitelog      => TRUE
															,pparamname     => 'Reduced overude fee calculation base');
						contractparams.savedialognumber(pdialog
													   ,'RedOvdFeeAmount'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog        => TRUE
													   ,pparamname       => 'Reduced overdue fee flat amount');
						contractparams.savedialognumber(pdialog
													   ,'RedOvdFeePrc'
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog     => TRUE
													   ,pparamname    => 'Reduced Overdue fee percentage');
						vclnd := referencecalendar.getclndfromdialog(pdialog, 'RedOvdFeePeriod');
						s.say('!!!!!!!!!! vClnd =' || vclnd, 1);
						IF vclnd IS NULL
						THEN
							dialog.goitem(pdialog, 'RedOvdFeePeriod');
							RAISE contractparams.valuenotexists;
						END IF;
						contractparams.savenumber(cobjecttype
												 ,sprofileid
												 ,'RedOvdFeePeriod'
												 ,vclnd
												 ,pwhitelog        => TRUE
												 ,pparamname       => 'Calendar of Promotional Overdue Fee Using');
					ELSE
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvdFeeBase');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvdFeeAmount');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvdFeePrc');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvdFeeInterestRat');
						contractparams.deletevalue(cobjecttype, sprofileid, 'RedOvdFeeDaysInYear');
					END IF;
				
					contractparams.savedialogfieldnumber(pdialog
														,'IntMode'
														,cobjecttype
														,sprofileid
														,pwhitelog   => TRUE
														,pparamname  => 'Interest charge mode');
				
					vret := dialog.getnumber(pdialog, 'Cur');
					IF nvl(vret, 0) = 0
					THEN
						dialog.goitem(pdialog, 'Cur');
						RAISE contractparams.incorrectvalue;
					END IF;
					vretc := ltrim(rtrim(dialog.getchar(pdialog, 'ProfileName')));
					IF vretc IS NULL
					THEN
						dialog.goitem(pdialog, 'ProfileName');
						RAISE contractparams.incorrectvalue;
					END IF;
				
					UPDATE tcontractprofile
					SET    profilename = vretc
						  ,currency    = vret
					WHERE  branch = cbranch
					AND    profileid = sprofileid;
				
				EXCEPTION
					WHEN referenceprchistory.ratenotdefined THEN
						dialog.sethothint(pdialog, 'Interest rate not defined');
						RETURN;
					WHEN contractparams.accountnotexists THEN
						dialog.sethothint(pdialog, 'Account not found');
						RETURN;
					WHEN contractparams.valuenotexists
						 OR contractparams.incorrectvalue THEN
						dialog.sethothint(pdialog, 'Incorrect value');
						RETURN;
					WHEN OTHERS THEN
						err.seterror(SQLCODE, cpackagename || '.ProfileSetupDialogProc');
						service.sayerr(pdialog, 'Error');
						dialog.goitem(pdialog, 'Cancel');
						RETURN;
				END;
			END IF;
		END IF;
		s.say(cmethodname || '    -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.ProfileSetupDialogProc');
			RAISE;
	END;

	FUNCTION profilegroupsetupdialog
	(
		pgroupid  IN NUMBER
	   ,preadonly IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethodname  CONSTANT typemethodname := cpackagename || '.ProfileGroupSetupDialog';
		chandlername CONSTANT typemethodname := cpackagename || '.ProfileGroupSetupDialogProc';
	
		vdialog   NUMBER;
		vpanel0   NUMBER;
		vpanel1   NUMBER;
		vpanel2   NUMBER;
		vpanel3   NUMBER;
		vpanel4   NUMBER;
		vmenu     NUMBER;
		vopermenu NUMBER;
	
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		stypefillarray.delete;
		stypefillarray(1).pcategory := referenceprchistory.ccontracttype;
		stypefillarray(1).pno := NULL;
		sgroupid := pgroupid;
		vdialog := dialog.new('Interest charge setup'
							 ,0
							 ,0
							 ,78
							 ,17
							 ,presizable             => TRUE
							 ,pextid                 => cmethodname);
		dialog.hiddenbool(vdialog, c_readonlyflag, preadonly);
		dialog.setdialogpre(vdialog, chandlername);
		dialog.setdialogvalid(vdialog, chandlername);
		dialog.setdialogpost(vdialog, chandlername);
	
		dialog.bevel(vdialog, 1, 1, 77, 10, dialog.bevel_frame);
		dialog.inputcheck(vdialog
						 ,sgroupid || '_ChargeInt'
						 ,5
						 ,1
						 ,length('Charge interest') + 2
						 ,'Charge interest by operation group'
						 ,'Charge interest');
		dialog.setitempost(vdialog, sgroupid || '_ChargeInt', chandlername);
		dialog.inputchar(vdialog
						,sgroupid || '_StartDate'
						,33
						,2
						,23
						,'Start Interest Calculation From'
						,NULL
						,'Interest Calculation From:');
		dialog.listaddfield(vdialog, sgroupid || '_StartDate', 'ItemID', 'N', 1, 0);
		dialog.listaddfield(vdialog, sgroupid || '_StartDate', 'ItemName', 'C', 23, 1);
		dialog.setitemattributies(vdialog, sgroupid || '_StartDate', dialog.updateoff);
		dialog.listaddrecord(vdialog, sgroupid || '_StartDate', '1~Transaction Date');
		dialog.listaddrecord(vdialog, sgroupid || '_StartDate', '2~Posting Date');
		dialog.listaddrecord(vdialog, sgroupid || '_StartDate', '3~Statement Date');
		dialog.listaddrecord(vdialog, sgroupid || '_StartDate', '4~Payment Due Date');
		dialog.listaddrecord(vdialog, sgroupid || '_StartDate', '5~Cycle`s first day');
		dialog.inputinteger(vdialog, sgroupid || '_ShiftDays', 61, 2, 'days', 3, pcaption => '+');
		dialog.statictext(vdialog, 65, 2, 'days', NULL);
		dialog.inputinteger(vdialog
						   ,sgroupid || '_DaysInYear'
						   ,33
						   ,3
						   ,'Specify days number in year (by default days number in current year)'
						   ,3
						   ,pcaption => 'Days in year:');
		dialog.inputchar(vdialog
						,sgroupid || '_ChargeOnB'
						,33
						,4
						,17
						,'Transaction Amount for Interest Charging'
						,NULL
						,'Charge Interest on:');
		dialog.listaddfield(vdialog, sgroupid || '_ChargeOnB', 'ItemID', 'N', 1, 0);
		dialog.listaddfield(vdialog, sgroupid || '_ChargeOnB', 'ItemName', 'C', 17, 1);
		dialog.setitemattributies(vdialog, sgroupid || '_ChargeOnB', dialog.updateoff);
		dialog.listaddrecord(vdialog, sgroupid || '_ChargeOnB', '1~Full balance', dialog.cmconfirm);
		dialog.listaddrecord(vdialog
							,sgroupid || '_ChargeOnB'
							,'2~Remaining balance'
							,dialog.cmconfirm);
		dialog.inputcheck(vdialog
						 ,sgroupid || '_UseRedRate'
						 ,5
						 ,5
						 ,20
						 ,'Use Grace Period'
						 ,'Use Grace Period');
		dialog.setitempost(vdialog, sgroupid || '_UseRedRate', chandlername);
		dialog.inputcheck(vdialog
						 ,sgroupid || '_ChargePaid'
						 ,5
						 ,6
						 ,70
						 ,'Don`t Charge interest on paid amount till Due Date'
						 ,'Don`t Charge interest on paid amount till Due Date');
		dialog.setitempost(vdialog, sgroupid || '_ChargePaid', chandlername);
		dialog.inputcheck(vdialog
						 ,sgroupid || '_OnlyFirst'
						 ,5
						 ,7
						 ,70
						 ,'Don`t Charge interest on paid amount In first billing cycle only'
						 ,'In first billing cycle only');
	
		dialog.inputcheck(vdialog
						 ,sgroupid || '_TillCurSD'
						 ,5
						 ,8
						 ,70
						 ,'Charge interest till Current Statement Date'
						 ,'Charge interest till Charging Date');
		dialog.setitempost(vdialog, sgroupid || '_TillCurSD', chandlername);
		dialog.bevel(vdialog
					,1
					,9
					,77
					,1
					,dialog.bevel_top
					,pcaption => 'In case Due Amount is not paid till Due Date');
		dialog.inputcheck(vdialog
						 ,sgroupid || '_UnBillInc'
						 ,5
						 ,10
						 ,70
						 ,'Charge interest on unbilled transactions too'
						 ,'Charge interest on unbilled transactions too');
	
		dialog.pagelist(vdialog, 'PAGER', 1, 12, 77, 7);
		vpanel0 := dialog.page(vdialog, 'PAGER', 'Rate choice');
		dialog.bevel(vpanel0, 1, 1, 76, 4, dialog.bevel_frame);
		dlg_tools.makedroplist(vpanel0
							  ,sgroupid || '_CrdPrcDate'
							  ,31
							  ,2
							  ,25
							  ,25
							  ,'Date selection:'
							  ,'Interest rate date selection type');
		dialog.listaddrecord(vpanel0
							,sgroupid || '_CrdPrcDate'
							,cdate_current || '~Use current business date');
		dialog.listaddrecord(vpanel0
							,sgroupid || '_CrdPrcDate'
							,cdate_transaction || '~Use transaction date');
		dialog.listaddrecord(vpanel0
							,sgroupid || '_CrdPrcDate'
							,cdate_history || '~Use rate history');
		dialog.listaddrecord(vpanel0
							,sgroupid || '_CrdPrcDate'
							,cdate_cardcreation || '~Use card creation date');
	
		dlg_tools.makedroplist(vpanel0
							  ,sgroupid || '_CrdPrcType'
							  ,31
							  ,3
							  ,25
							  ,25
							  ,'Select amount by:'
							  ,'Interest rate amount selection type');
		dialog.listaddrecord(vpanel0
							,sgroupid || '_CrdPrcType'
							,camount_max || '~Remaining balance');
		dialog.listaddrecord(vpanel0
							,sgroupid || '_CrdPrcType'
							,camount_discrete || '~Discrete remaining balance');
		dialog.listaddrecord(vpanel0
							,sgroupid || '_CrdPrcType'
							,camount_transaction || '~Transaction amount');
	
		dlg_tools.makedroplist(vpanel0
							  ,sgroupid || '_CrdPrcPrdt'
							  ,31
							  ,4
							  ,25
							  ,25
							  ,'"Period" starts from:'
							  ,'Time origin of "Period" interval');
		dialog.listaddrecord(vpanel0, sgroupid || '_CrdPrcPrdt', '1~Contract creation date');
		dialog.listaddrecord(vpanel0, sgroupid || '_CrdPrcPrdt', '2~Transaction date');
	
		vpanel1 := dialog.page(vdialog, 'PAGER', 'Regular Rate');
		dialog.bevel(vpanel1, 1, 1, 76, 4, dialog.bevel_frame);
		dialog.inputchar(vpanel1
						,sgroupid || '_CrdPrcHist'
						,31
						,2
						,40
						,'Choose history of regular interest rates for credit'
						,NULL
						,'Regular Interest Rate:');
		dialog.listaddfield(vpanel1, sgroupid || '_CrdPrcHist', 'ItemID', 'C', 40, 0);
		dialog.listaddfield(vpanel1, sgroupid || '_CrdPrcHist', 'ItemName', 'C', 60, 1);
		dialog.setitemattributies(vpanel1, sgroupid || '_CrdPrcHist', dialog.updateoff);
	
		vpanel2 := dialog.page(vdialog, 'PAGER', 'Promotional Rate');
		dialog.bevel(vpanel2, 1, 1, 76, 4, dialog.bevel_frame);
		dialog.inputchar(vpanel2
						,sgroupid || '_ProPrcHist'
						,31
						,2
						,40
						,'Choose Promotional Interest Rate'
						,NULL
						,'Promotional Interest Rate:');
		dialog.listaddfield(vpanel2, sgroupid || '_ProPrcHist', 'ItemID', 'C', 40, 0);
		dialog.listaddfield(vpanel2, sgroupid || '_ProPrcHist', 'ItemName', 'C', 60, 1);
		dialog.setitemattributies(vpanel2, sgroupid || '_ProPrcHist', dialog.updateoff);
		referencecalendar.inputcalendar(vpanel2
									   ,sgroupid || '_ProCalId'
									   ,31
									   ,3
									   ,40
									   ,'Rate Using Calendar:'
									   ,'Calendar of Promotional Rate Using');
		dialog.inputchar(vpanel2
						,sgroupid || '_ProAddCond'
						,31
						,4
						,4
						,'PL/SQL block usage mode'
						,NULL
						,'Additional condition:');
		dialog.listaddfield(vpanel2, sgroupid || '_ProAddCond', 'ItemID', 'N', 1, 0);
		dialog.listaddfield(vpanel2, sgroupid || '_ProAddCond', 'ItemName', 'C', 4, 1);
		dialog.setreadonly(vpanel2, sgroupid || '_ProAddCond', TRUE);
		dialog.listaddrecord(vpanel2
							,sgroupid || '_ProAddCond'
							,cproplsql_off || '~None'
							,dialog.cmconfirm);
		dialog.listaddrecord(vpanel2
							,sgroupid || '_ProAddCond'
							,cproplsql_and || '~And'
							,dialog.cmconfirm);
		dialog.listaddrecord(vpanel2
							,sgroupid || '_ProAddCond'
							,cproplsql_or || '~Or'
							,dialog.cmconfirm);
		dialog.button(vpanel2
					 ,sgroupid || '_ProPLSQL'
					 ,39
					 ,4
					 ,15
					 ,'PL/SQL block'
					 ,0
					 ,0
					 ,'Additional conditions to check whether promotional rate should be generated');
		dialog.setitempre(vpanel2, sgroupid || '_ProPLSQL', chandlername);
	
		vpanel3 := dialog.page(vdialog, 'PAGER', 'Preferential Rate');
		dialog.bevel(vpanel3, 1, 1, 76, 5, dialog.bevel_frame);
		dialog.inputchar(vpanel3
						,sgroupid || '_PrePrcHist'
						,31
						,2
						,40
						,'Choose Preferential Interest Rate'
						,NULL
						,'Preferential Interest Rate:');
		dialog.listaddfield(vpanel3, sgroupid || '_PrePrcHist', 'ItemID', 'C', 40, 0);
		dialog.listaddfield(vpanel3, sgroupid || '_PrePrcHist', 'ItemName', 'C', 60, 1);
		dialog.setitemattributies(vpanel3, sgroupid || '_PrePrcHist', dialog.updateoff);
		referencecalendar.inputcalendar(vpanel3
									   ,sgroupid || '_PreCalId'
									   ,31
									   ,3
									   ,40
									   ,'Rate Using Calendar:'
									   ,'Calendar of Preferential Rate Using');
		dialog.inputchar(vpanel3
						,sgroupid || '_PreUsageStartFrom'
						,31
						,4
						,40
						,'Usage period starts from'
						,NULL
						,'Usage period starts from:');
		dialog.listaddfield(vpanel3, sgroupid || '_PreUsageStartFrom', 'ItemID', 'C', 40, 0);
		dialog.listaddfield(vpanel3, sgroupid || '_PreUsageStartFrom', 'ItemName', 'C', 60, 1);
		dialog.listaddrecord(vdialog
							,sgroupid || '_PreUsageStartFrom'
							,cprefrateuse_contrcreationdate || '~' || 'Contract creation date' || '~'
							,NULL
							,0);
		dialog.listaddrecord(vdialog
							,sgroupid || '_PreUsageStartFrom'
							,cprefrateuse_trandate || '~' || 'Transaction date' || '~'
							,NULL
							,0);
		dialog.setitemattributies(vpanel3, sgroupid || '_PreUsageStartFrom', dialog.updateoff);
		dialog.inputinteger(vpanel3
						   ,sgroupid || '_PreUse'
						   ,31
						   ,5
						   ,'Specify cycles number '
						   ,3
						   ,pcaption => 'Usage period (cycles):');
	
		vpanel4 := dialog.page(vdialog, 'PAGER', 'Reduced Rate');
		dialog.list(vpanel4, 'RedPrcList', 1, 2, 55, 3, '');
		dialog.listaddfield(vpanel4, 'RedPrcList', 'Priority', 'N', 2, 0);
		dialog.listaddfield(vpanel4, 'RedPrcList', 'Terms', 'C', 30, 1);
		dialog.listaddfield(vpanel4, 'RedPrcList', 'RateName', 'C', 25, 1);
		dialog.setcaption(vpanel4, 'RedPrcList', 'Terms~Interest rate');
		dialog.setitempost(vpanel4, 'RedPrcList', chandlername);
		dialog.button(vpanel4
					 ,'Insert'
					 ,63
					 ,2
					 ,12
					 ,'Add'
					 ,0
					 ,0
					 ,'Add interest rate'
					 ,panchor => dialog.anchor_right);
		dialog.button(vpanel4
					 ,'Delete'
					 ,63
					 ,4
					 ,12
					 ,'Delete'
					 ,0
					 ,0
					 ,'Delete interest rate'
					 ,panchor => dialog.anchor_right);
		dialog.button(vpanel4
					 ,'Up'
					 ,59
					 ,2
					 ,2
					 ,unistr('\25B2')
					 ,0
					 ,0
					 ,'Move up'
					 ,panchor => dialog.anchor_right);
		dialog.button(vpanel4
					 ,'Down'
					 ,59
					 ,4
					 ,2
					 ,unistr('\25BC')
					 ,0
					 ,0
					 ,'Move down'
					 ,panchor => dialog.anchor_right);
		dialog.setitempre(vpanel4, 'Insert', chandlername);
		dialog.setitempre(vpanel4, 'Delete', chandlername);
		dialog.setitempre(vpanel4, 'Up', chandlername);
		dialog.setitempre(vpanel4, 'Down', chandlername);
	
		dialog.button(vdialog
					 ,'Ok'
					 ,27
					 ,20
					 ,12
					 ,'OK'
					 ,dialog.cmok
					 ,0
					 ,'Save changes and exit dialog'
					 ,panchor => dialog.anchor_bottom);
		dialog.button(vdialog
					 ,'Cancel'
					 ,41
					 ,20
					 ,12
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel changes and exit dialog'
					 ,panchor => dialog.anchor_bottom);
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
	
		vmenu     := mnu.new(vdialog);
		vopermenu := mnu.submenu(vmenu, 'Dictionaries', 'Dictionaries');
		mnu.item(vopermenu
				,'SprPrc'
				,'Dictionary of interest rates'
				,0
				,0
				,'Dictionary of interest rates');
		mnu.item(vopermenu, 'HoliDays', 'Dictionary of calendars', 0, 0, 'Dictionary of calendars');
		dialog.setitempre(vdialog, 'SprPrc', chandlername);
		dialog.setitempre(vdialog, 'HoliDays', chandlername);
		dialog.setitempre(vdialog, 'Ok', chandlername);
	
		s.say(cmethodname || '    -->>  END', 1);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END profilegroupsetupdialog;

	PROCEDURE profilegroupsetupdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.ProfileGroupSetupDialogProc';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		cobjecttype CONSTANT NUMBER := getobjecttype;
	
		vcurrentparam VARCHAR2(100);
		vclnd         NUMBER;
		vret          NUMBER;
	
		PROCEDURE promoblockdisable IS
			cmethodname CONSTANT typemethodname := profilegroupsetupdialogproc.cmethodname ||
												   '.PromoBlockDisable';
		BEGIN
			dialog.setenable(pdialog
							,sgroupid || '_ProPLSQL'
							,dialog.getcurrentrecordnumber(pdialog
														  ,sgroupid || '_ProAddCond'
														  ,'ItemID') <> cproplsql_off);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname);
				RAISE;
		END promoblockdisable;
	
		PROCEDURE reddisable IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.ProfileGroupSetupDialogProc.RedDisable';
		BEGIN
			s.say(cmethodname || '      --<< BEGIN', 1);
			IF dialog.getbool(pdialog, sgroupid || '_UseRedRate')
			THEN
				dialog.setitemattributies(pdialog, sgroupid || '_TillCurSD', dialog.selecton);
				IF dialog.getbool(pdialog, sgroupid || '_TillCurSD')
				THEN
					dialog.setitemattributies(pdialog, sgroupid || '_UnBillInc', dialog.selecton);
				ELSE
					dialog.setitemattributies(pdialog, sgroupid || '_UnBillInc', dialog.selectoff);
					dialog.putbool(pdialog, sgroupid || '_UnBillInc', FALSE);
				END IF;
			ELSE
				dialog.setitemattributies(pdialog, sgroupid || '_TillCurSD', dialog.selectoff);
				dialog.setitemattributies(pdialog, sgroupid || '_UnBillInc', dialog.selectoff);
				dialog.putbool(pdialog, sgroupid || '_TillCurSD', FALSE);
				dialog.putbool(pdialog, sgroupid || '_UnBillInc', FALSE);
			END IF;
			s.say(cmethodname || '     -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.ProfileGroupSetupDialogProc.RedDisable');
				RAISE;
		END;
	
		PROCEDURE onlyfirsthide IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.ProfileGroupSetupDialogProc.OnlyFirstHide';
		BEGIN
			s.say(cmethodname || '      --<< BEGIN', 1);
			IF dialog.getbool(pdialog, sgroupid || '_ChargePaid')
			THEN
				dialog.setitemattributies(pdialog, sgroupid || '_OnlyFirst', dialog.selecton);
			ELSE
				dialog.setitemattributies(pdialog, sgroupid || '_OnlyFirst', dialog.selectoff);
				dialog.putbool(pdialog, sgroupid || '_OnlyFirst', FALSE);
			END IF;
			s.say(cmethodname || '     -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.ProfileGroupSetupDialogProc.OnlyFirstHide');
				RAISE;
		END;
	
		PROCEDURE chargepaidhide IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.ProfileGroupSetupDialogProc.ChargePaidHide';
		BEGIN
			s.say(cmethodname || '      --<< BEGIN', 1);
			IF dialog.getcurrentrecordnumber(pdialog, sgroupid || '_ChargeOnB', 'ItemID') = 2
			   AND dialog.getbool(pdialog, sgroupid || '_UseRedRate')
			THEN
				dialog.setitemattributies(pdialog, sgroupid || '_ChargePaid', dialog.selecton);
			ELSE
				dialog.setitemattributies(pdialog, sgroupid || '_ChargePaid', dialog.selectoff);
				dialog.putbool(pdialog, sgroupid || '_ChargePaid', FALSE);
			END IF;
			onlyfirsthide;
			s.say(cmethodname || '     -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.ProfileGroupSetupDialogProc.ChargePaidHide');
				RAISE;
		END;
	
		PROCEDURE disableall IS
			cmethodname CONSTANT typemethodname := profilegroupsetupdialogproc.cmethodname ||
												   '.DisableAll';
			vchargeon BOOLEAN;
		BEGIN
			vchargeon := dialog.getbool(pdialog, sgroupid || '_ChargeInt');
		
			dialog.setenable(pdialog, sgroupid || '_StartDate', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_ShiftDays', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_DaysInYear', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_ChargeOnB', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_CrdPrcHist', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_CrdPrcDate', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_CrdPrcType', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_CrdPrcPrdt', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_ProPrcHist', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_ProCalId', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_ProAddCond', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_ProPLSQL', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_PrePrcHist', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_PreCalId', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_PreUse', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_ChargePaid', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_OnlyFirst', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_TillCurSD', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_UnBillInc', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_UseRedRate', vchargeon);
			dialog.setenable(pdialog, sgroupid || '_PreUsageStartFrom', vchargeon);
		
			IF vchargeon
			THEN
				promoblockdisable;
				chargepaidhide;
				reddisable;
			END IF;
		
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cmethodname);
				RAISE;
		END disableall;
	
		PROCEDURE fillreducedrates IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.ProfileGroupSetupDialogProc.FillReducedRates';
			CURSOR curredrates IS
				SELECT *
				FROM   tcontractredintsettings
				WHERE  branch = cbranch
				AND    profileid = sprofileid
				AND    groupid = sgroupid
				ORDER  BY priority;
			vatext        types.arrstr1000;
			vinterestrate VARCHAR(500);
		BEGIN
			s.say(cmethodname || '      --<< BEGIN', 1);
			vatext(cgrace_notused) := 'Not used';
			vatext(cgrace_paidmp) := 'MP is paid before DD';
			vatext(cgrace_paidsdbal) := 'SD balance is paid before DD';
			vatext(cgrace_currentbalisless) := 'Current balance is less than';
			vatext(cgrace_unpdbaloflastsdisless) := 'Unpaid balance of last SD is less than';
			vatext(cgrace_unpaidsdamntonddisless) := 'Unpaid SD Amount on Due Date is less than';
			dialog.listclear(pdialog, 'RedPrcList');
			FOR i IN curredrates
			LOOP
				IF i.rateid <> -1
				THEN
					vinterestrate := referenceprchistory.getrecord_rateref(i.rateid).name;
				ELSE
					vinterestrate := 'Don''t charge interest';
				END IF;
				dialog.listaddrecord(pdialog
									,'RedPrcList'
									,i.priority || '~' || vatext(i.terms) || ' ' || i.amount || '~' ||
									 vinterestrate || '~');
			END LOOP;
			s.say(cmethodname || '     -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.ProfileGroupSetupDialogProc.FillReducedRates');
				RAISE;
		END;
	
		PROCEDURE editredintrate(ppriority IN NUMBER) IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.ProfileGroupSetupDialogProc.EditRedIntRate';
			vpriority NUMBER;
		BEGIN
			s.say(cmethodname || '      --<< BEGIN', 1);
			IF ppriority IS NULL
			THEN
				SELECT COUNT(*)
				INTO   vpriority
				FROM   tcontractredintsettings
				WHERE  branch = cbranch
				AND    profileid = sprofileid
				AND    groupid = sgroupid;
				vpriority := vpriority + 1;
			ELSE
				vpriority := ppriority;
			END IF;
		
			spriority := vpriority;
			dialog.exec(editredintdialog(vpriority
										,dialog.getbool(pdialog, sgroupid || '_UseRedRate')));
			s.say(cmethodname || '     -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.ProfileGroupSetupDialogProc.EditRedIntRate');
				RAISE;
		END;
	
		PROCEDURE deleteredintrate(ppriority IN NUMBER) IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.ProfileGroupSetupDialogProc.DeleteRedIntRate';
		BEGIN
			s.say(cmethodname || '      --<< BEGIN', 1);
			s.say('DeleteRedIntRat pPriority=' || ppriority, 1);
			DELETE FROM tcontractredintsettings
			WHERE  branch = cbranch
			AND    profileid = sprofileid
			AND    groupid = sgroupid
			AND    priority = ppriority;
			UPDATE tcontractredintsettings
			SET    priority = priority - 1
			WHERE  branch = cbranch
			AND    profileid = sprofileid
			AND    groupid = sgroupid
			AND    priority > ppriority;
			s.say(cmethodname || '     -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.ProfileGroupSetupDialogProc.DeleteRedIntRate');
				RAISE;
		END;
	
		PROCEDURE upredintrate(ppriority IN NUMBER) IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.ProfileGroupSetupDialogProc.UpRedIntRate';
		BEGIN
			s.say(cmethodname || '      --<< BEGIN', 1);
			s.say('UpRedIntRate pPriority=' || ppriority, 1);
			IF ppriority = 1
			THEN
				s.say('UpRedIntRate 0', 1);
				RETURN;
			ELSE
			
				UPDATE tcontractredintsettings
				SET    priority = -ppriority
				WHERE  branch = cbranch
				AND    profileid = sprofileid
				AND    groupid = sgroupid
				AND    priority = ppriority - 1;
			
				UPDATE tcontractredintsettings
				SET    priority = ppriority - 1
				WHERE  branch = cbranch
				AND    profileid = sprofileid
				AND    groupid = sgroupid
				AND    priority = ppriority;
			
				UPDATE tcontractredintsettings
				SET    priority = ppriority
				WHERE  branch = cbranch
				AND    profileid = sprofileid
				AND    groupid = sgroupid
				AND    priority = -ppriority;
			END IF;
			s.say(cmethodname || '     -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.ProfileGroupSetupDialogProc.UpRedIntRate');
				RAISE;
		END;
	
		PROCEDURE downredintrate(ppriority IN NUMBER) IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.ProfileGroupSetupDialogProc.DownRedIntRate';
			vmax NUMBER;
		BEGIN
			s.say(cmethodname || '      --<< BEGIN', 1);
			SELECT MAX(priority)
			INTO   vmax
			FROM   tcontractredintsettings
			WHERE  branch = cbranch
			AND    profileid = sprofileid
			AND    groupid = sgroupid;
			IF ppriority = vmax
			THEN
				RETURN;
			ELSE
				upredintrate(ppriority + 1);
			END IF;
			s.say(cmethodname || '     -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.ProfileGroupSetupDialogProc.DownRedIntRate');
				RAISE;
		END;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		s.say(cmethodname || '        ProfileGroupSetupDialogProc: pWhat =' || pwhat ||
			  ' pDialog=' || pdialog || ' pItemName=' || pitemname || ' pCmd=' || pcmd
			 ,1);
		IF pwhat = dialog.wtdialogpre
		THEN
		
			dialog.setenable(pdialog, 'Ok', NOT dialog.getbool(pdialog, c_readonlyflag));
			dialog.setenable(pdialog, 'INSERT', NOT dialog.getbool(pdialog, c_readonlyflag));
			dialog.setenable(pdialog, 'DELETE', NOT dialog.getbool(pdialog, c_readonlyflag));
			dialog.setenable(pdialog, 'UP', NOT dialog.getbool(pdialog, c_readonlyflag));
			dialog.setenable(pdialog, 'DOWN', NOT dialog.getbool(pdialog, c_readonlyflag));
		
			IF contractparams.loaddialogbool(pdialog
											,sgroupid || '_ChargeInt'
											,cobjecttype
											,sprofileid)
			THEN
				contractparams.loaddialogfieldnumber(pdialog
													,sgroupid || '_StartDate'
													,cobjecttype
													,sprofileid);
				IF contractparams.loaddialognumber(pdialog
												  ,sgroupid || '_ShiftDays'
												  ,cobjecttype
												  ,sprofileid) IS NULL
				THEN
					dialog.putnumber(pdialog, sgroupid || '_ShiftDays', 0);
					contractparams.savedialognumber(pdialog
												   ,sgroupid || '_ShiftDays'
												   ,cobjecttype
												   ,sprofileid
												   ,pwhitelog => TRUE
												   ,pparamname => 'Group:' || sgroupid ||
																  'Shift on days');
				END IF;
				contractparams.loaddialognumber(pdialog
											   ,sgroupid || '_DaysInYear'
											   ,cobjecttype
											   ,sprofileid);
				contractparams.loaddialogfieldnumber(pdialog
													,sgroupid || '_ChargeOnB'
													,cobjecttype
													,sprofileid);
				referenceprchistory.fillitem(pdialog
											,sgroupid || '_CrdPrcHist'
											,referenceprchistory.cperiodremain
											,referenceprchistory.crvpother1
											,sprofileid
											,stypefillarray);
				contractparams.loaddialogfieldnumber(pdialog
													,sgroupid || '_CrdPrcDate'
													,cobjecttype
													,sprofileid);
				contractparams.loaddialogfieldnumber(pdialog
													,sgroupid || '_CrdPrcType'
													,cobjecttype
													,sprofileid);
				contractparams.loaddialogfieldnumber(pdialog
													,sgroupid || '_CrdPrcPrdt'
													,cobjecttype
													,sprofileid);
				fillreducedrates;
			
				referenceprchistory.fillitem(pdialog
											,sgroupid || '_ProPrcHist'
											,referenceprchistory.cperiodremain
											,referenceprchistory.crvpother1
											,sprofileid
											,stypefillarray
											,TRUE
											,-1
											,'Don''t use Interest Rate');
				referencecalendar.setclndtodialog(pdialog
												 ,sgroupid || '_ProCalId'
												 ,contractparams.loadnumber(cobjecttype
																		   ,sprofileid
																		   ,sgroupid ||
																			'_ProCalId'
																		   ,FALSE));
				contractparams.loaddialogfieldnumber(pdialog
													,sgroupid || '_ProAddCond'
													,cobjecttype
													,sprofileid
													,pdefaultvalue => cproplsql_off);
				referenceprchistory.fillitem(pdialog
											,sgroupid || '_PrePrcHist'
											,referenceprchistory.czero
											,referenceprchistory.crvpother1
											,sprofileid
											,stypefillarray
											,TRUE
											,-1
											,'Don''t use Interest Rate');
				referencecalendar.setclndtodialog(pdialog
												 ,sgroupid || '_PreCalId'
												 ,contractparams.loadnumber(cobjecttype
																		   ,sprofileid
																		   ,sgroupid ||
																			'_PreCalId'
																		   ,FALSE));
				contractparams.loaddialognumber(pdialog
											   ,sgroupid || '_PreUse'
											   ,cobjecttype
											   ,sprofileid);
			
				IF contractparams.loaddialognumber(pdialog
												  ,sgroupid || '_PreUsageStartFrom'
												  ,cobjecttype
												  ,sprofileid) IS NULL
				THEN
					dialog.setcurrecbyvalue(pdialog
										   ,sgroupid || '_PreUsageStartFrom'
										   ,pfield => 'ItemID'
										   ,pvalue => cprefrateuse_contrcreationdate);
				ELSE
					contractparams.loaddialogfieldnumber(pdialog
														,sgroupid || '_PreUsageStartFrom'
														,cobjecttype
														,sprofileid);
				END IF;
			
				IF NOT contractparams.loaddialogbool(pdialog
													,sgroupid || '_UseRedRate'
													,cobjecttype
													,sprofileid)
				THEN
					NULL;
				ELSE
					contractparams.loaddialogbool(pdialog
												 ,sgroupid || '_ChargePaid'
												 ,cobjecttype
												 ,sprofileid);
					contractparams.loaddialogbool(pdialog
												 ,sgroupid || '_OnlyFirst'
												 ,cobjecttype
												 ,sprofileid);
					contractparams.loaddialogbool(pdialog
												 ,sgroupid || '_TillCurSD'
												 ,cobjecttype
												 ,sprofileid);
					contractparams.loaddialogbool(pdialog
												 ,sgroupid || '_UnBillInc'
												 ,cobjecttype
												 ,sprofileid);
				END IF;
			ELSE
				referenceprchistory.fillitem(pdialog
											,sgroupid || '_CrdPrcHist'
											,referenceprchistory.cperiodremain
											,referenceprchistory.crvpother1
											,sprofileid
											,stypefillarray);
				referenceprchistory.fillitem(pdialog
											,sgroupid || '_LowPrcHist'
											,referenceprchistory.cperiodremain
											,referenceprchistory.crvpother1
											,sprofileid
											,stypefillarray
											,TRUE
											,-1
											,'Don''t Charge Interest');
				referenceprchistory.fillitem(pdialog
											,sgroupid || '_ProPrcHist'
											,referenceprchistory.cperiodremain
											,referenceprchistory.crvpother1
											,sprofileid
											,stypefillarray
											,TRUE
											,-1
											,'Don''t use Interest Rate');
				referenceprchistory.fillitem(pdialog
											,sgroupid || '_PrePrcHist'
											,referenceprchistory.czero
											,referenceprchistory.crvpother1
											,sprofileid
											,stypefillarray
											,TRUE
											,-1
											,'Don''t use Interest Rate');
			END IF;
			disableall;
		
		ELSIF pwhat = dialog.wtitempre
		THEN
		
			CASE pitemname
				WHEN upper(sgroupid || '_ProPLSQL') THEN
					IF dialog.exec(dynasqldlg.editdlg(contractparams.loadnumber(cobjecttype
																			   ,sprofileid
																			   ,sgroupid ||
																				'_ProPLSQL'
																			   ,FALSE)
													 ,pexample => 'begin' || chr(10) ||
																  '  :RET:= 1;' || chr(10) || 'end;')) =
					   dialog.cmok
					THEN
						contractparams.savenumber(cobjecttype
												 ,sprofileid
												 ,sgroupid || '_ProPLSQL'
												 ,dynasqldlg.geteditsqlcode);
					END IF;
				WHEN 'HOLIDAYS' THEN
					referencecalendar.startup(dialog.getbool(pdialog, c_readonlyflag));
					referencecalendar.fillcalendarlist(pdialog
													  ,upper(sgroupid || '_ProCalId')
													  ,referencecalendar.getcalendars
													  ,FALSE);
					referencecalendar.fillcalendarlist(pdialog
													  ,upper(sgroupid || '_PreCalId')
													  ,referencecalendar.getcalendars
													  ,FALSE);
				WHEN 'SPRPRC' THEN
					dialog.exec(referenceprchistory.maindialog(referenceprchistory.ccontracttype
															  ,NULL
															  ,preadonly => dialog.getbool(pdialog
																						  ,c_readonlyflag)));
					referenceprchistory.fillitem(pdialog
												,sgroupid || '_CrdPrcHist'
												,referenceprchistory.cperiodremain
												,referenceprchistory.crvpother1
												,sprofileid
												,stypefillarray);
					fillreducedrates;
					referenceprchistory.fillitem(pdialog
												,sgroupid || '_ProPrcHist'
												,referenceprchistory.cperiodremain
												,referenceprchistory.crvpother1
												,sprofileid
												,stypefillarray
												,TRUE
												,-1
												,'Don''t use Interest Rate');
					referenceprchistory.fillitem(pdialog
												,sgroupid || '_PrePrcHist'
												,referenceprchistory.czero
												,referenceprchistory.crvpother1
												,sprofileid
												,stypefillarray
												,TRUE
												,-1
												,'Don''t use Interest Rate');
				WHEN 'INSERT' THEN
					editredintrate(NULL);
					fillreducedrates;
				WHEN 'DELETE' THEN
					deleteredintrate(dialog.getcurrentrecordnumber(pdialog
																  ,'RedPrcList'
																  ,'Priority'));
					fillreducedrates;
				WHEN 'UP' THEN
					upredintrate(dialog.getcurrentrecordnumber(pdialog, 'RedPrcList', 'Priority'));
					fillreducedrates;
				WHEN 'DOWN' THEN
					downredintrate(dialog.getcurrentrecordnumber(pdialog, 'RedPrcList', 'Priority'));
					fillreducedrates;
				
				WHEN 'OK' THEN
					IF nvl(dialog.getchar(pdialog, sgroupid || '_UseRedRate'), 0) != 0
					   AND
					   nvl(dialog.getcurrentrecordchar(pdialog, 'RedPrcList', 'Terms'), 'N') = 'N'
					THEN
						htools.sethotmessage('Error!'
											,'At least one reduced rate has to be specified for operation group for which grace period was set');
						dialog.goitem(pdialog, 'RedPrcList');
					END IF;
				
				ELSE
					NULL;
			END CASE;
		ELSIF pwhat = dialog.wtitempost
		THEN
			IF pitemname = sgroupid || '_CHARGEINT'
			THEN
				disableall;
			ELSIF pitemname = 'REDPRCLIST'
			THEN
				vret := dialog.getcurrentrecordnumber(pdialog, pitemname, 'Priority');
				editredintrate(vret);
				fillreducedrates;
			ELSE
				chargepaidhide;
				reddisable;
			END IF;
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			IF pcmd = dialog.cmconfirm
			THEN
				IF pitemname = sgroupid || '_CHARGEONB'
				THEN
					chargepaidhide;
					dialog.goitem(pdialog, pitemname);
				ELSIF pitemname = sgroupid || '_PROADDCOND'
				THEN
					promoblockdisable;
					dialog.cancelclose(pdialog);
				END IF;
			ELSIF pcmd = dialog.cmok
			THEN
				s.say(cmethodname || '        -info: pCmd = Dialog.cmOk', 1);
			
				SAVEPOINT setparams;
			
				BEGIN
					vcurrentparam := sgroupid || '_ChargeInt';
					IF contractparams.savedialogbool(pdialog
													,vcurrentparam
													,cobjecttype
													,sprofileid
													,pwhitelog     => TRUE
													,pparamname    => 'Group:' || sgroupid ||
																	  ' Charge interest')
					THEN
						s.say(cmethodname || '        -info: ' || vcurrentparam || ' was saved', 1);
						vcurrentparam := sgroupid || '_StartDate';
						contractparams.savedialogfieldnumber(pdialog
															,vcurrentparam
															,cobjecttype
															,sprofileid
															,pwhitelog     => TRUE
															,pparamname    => 'Group:' || sgroupid ||
																			  ' Start Interest Calculation From');
						vcurrentparam := sgroupid || '_ShiftDays';
						contractparams.savedialognumber(pdialog
													   ,vcurrentparam
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog     => TRUE
													   ,pparamname    => 'Group:' || sgroupid ||
																		 ' Shift on days');
						vcurrentparam := sgroupid || '_DaysInYear';
						contractparams.savedialognumber(pdialog
													   ,vcurrentparam
													   ,cobjecttype
													   ,sprofileid
													   ,TRUE
													   ,pwhitelog     => TRUE
													   ,pparamname    => 'Group:' || sgroupid ||
																		 ' Days in year');
						vcurrentparam := sgroupid || '_ChargeOnB';
						vret          := contractparams.savedialogfieldnumber(pdialog
																			 ,vcurrentparam
																			 ,cobjecttype
																			 ,sprofileid
																			 ,pwhitelog     => TRUE
																			 ,pparamname    => 'Group:' ||
																							   sgroupid ||
																							   ' Charge Interest on');
						vcurrentparam := sgroupid || '_CrdPrcHist';
						referenceprchistory.saveitem(pdialog
													,vcurrentparam
													,referenceprchistory.crvpother1
													,sprofileid);
						vcurrentparam := sgroupid || '_CrdPrcDate';
						contractparams.savedialogfieldnumber(pdialog
															,vcurrentparam
															,cobjecttype
															,sprofileid
															,pwhitelog     => TRUE
															,pparamname    => 'Group:' || sgroupid ||
																			  ' Select Regular Rate by');
						vcurrentparam := sgroupid || '_CrdPrcType';
						contractparams.savedialogfieldnumber(pdialog
															,vcurrentparam
															,cobjecttype
															,sprofileid
															,pwhitelog     => TRUE
															,pparamname    => 'Group:' || sgroupid ||
																			  ' Select Regular Rate by');
						vcurrentparam := sgroupid || '_CrdPrcPrdt';
						contractparams.savedialogfieldnumber(pdialog
															,vcurrentparam
															,cobjecttype
															,sprofileid
															,pwhitelog     => TRUE
															,pparamname    => 'Group:' || sgroupid ||
																			  ' Select Regular Rate by');
						vcurrentparam := sgroupid || '_ProPrcHist';
						referenceprchistory.saveitem(pdialog
													,vcurrentparam
													,referenceprchistory.crvpother1
													,sprofileid);
						vcurrentparam := sgroupid || '_ProCalId';
						vclnd         := referencecalendar.getclndfromdialog(pdialog, vcurrentparam);
						IF vclnd IS NULL
						THEN
							dialog.goitem(pdialog, vcurrentparam);
							RAISE contractparams.valuenotexists;
						END IF;
						contractparams.savenumber(cobjecttype
												 ,sprofileid
												 ,vcurrentparam
												 ,vclnd
												 ,pwhitelog     => TRUE
												 ,pparamname    => 'Group:' || sgroupid ||
																   ' Calendar of Promotional Rate Using');
						vcurrentparam := sgroupid || '_ProAddCond';
						contractparams.savedialogfieldnumber(pdialog
															,vcurrentparam
															,cobjecttype
															,sprofileid
															,pwhitelog     => TRUE
															,pparamname    => 'Group:' || sgroupid ||
																			  ' Promotional rate PL/SQL block usage mode');
						vcurrentparam := sgroupid || '_PrePrcHist';
						referenceprchistory.saveitem(pdialog
													,vcurrentparam
													,referenceprchistory.crvpother1
													,sprofileid);
						vcurrentparam := sgroupid || '_PreCalId';
						vclnd         := referencecalendar.getclndfromdialog(pdialog, vcurrentparam);
						IF vclnd IS NULL
						THEN
							dialog.goitem(pdialog, vcurrentparam);
							RAISE contractparams.valuenotexists;
						END IF;
						contractparams.savenumber(cobjecttype
												 ,sprofileid
												 ,vcurrentparam
												 ,vclnd
												 ,pwhitelog     => TRUE
												 ,pparamname    => 'Group:' || sgroupid ||
																   ' Calendar of Preferential Rate Using');
						vcurrentparam := sgroupid || '_PreUse';
						contractparams.savedialognumber(pdialog
													   ,vcurrentparam
													   ,cobjecttype
													   ,sprofileid
													   ,pwhitelog     => TRUE
													   ,pparamname    => 'Group:' || sgroupid ||
																		 ' Preferential Rate Usage period');
						vcurrentparam := sgroupid || '_UseRedRate';
						IF contractparams.savedialogbool(pdialog
														,vcurrentparam
														,cobjecttype
														,sprofileid
														,pwhitelog     => TRUE
														,pparamname    => 'Group:' || sgroupid ||
																		  ' Use Grace Period')
						THEN
							IF vret = 2
							THEN
								vcurrentparam := sgroupid || '_ChargePaid';
								IF contractparams.savedialogbool(pdialog
																,vcurrentparam
																,cobjecttype
																,sprofileid
																,pwhitelog     => TRUE
																,pparamname    => 'Group:' ||
																				  sgroupid ||
																				  ' Don`t Charge interest on paid amount till Due Date')
								THEN
									vcurrentparam := sgroupid || '_OnlyFirst';
									contractparams.savedialogbool(pdialog
																 ,vcurrentparam
																 ,cobjecttype
																 ,sprofileid
																 ,pwhitelog     => TRUE
																 ,pparamname    => 'Group:' ||
																				   sgroupid ||
																				   ' In first billing cycle only');
								ELSE
									vcurrentparam := sgroupid || '_OnlyFirst';
									contractparams.deletevalue(cobjecttype
															  ,sprofileid
															  ,vcurrentparam);
								END IF;
							ELSE
								vcurrentparam := sgroupid || '_ChargePaid';
								contractparams.deletevalue(cobjecttype, sprofileid, vcurrentparam);
								vcurrentparam := sgroupid || '_OnlyFirst';
								contractparams.deletevalue(cobjecttype, sprofileid, vcurrentparam);
							END IF;
						ELSE
							vcurrentparam := sgroupid || '_ChargePaid';
							contractparams.deletevalue(cobjecttype, sprofileid, vcurrentparam);
							vcurrentparam := sgroupid || '_OnlyFirst';
							contractparams.deletevalue(cobjecttype, sprofileid, vcurrentparam);
						END IF;
						vcurrentparam := sgroupid || '_TillCurSD';
						contractparams.savedialogbool(pdialog
													 ,vcurrentparam
													 ,cobjecttype
													 ,sprofileid
													 ,pwhitelog     => TRUE
													 ,pparamname    => 'Group:' || sgroupid ||
																	   ' Charge interest till Charging Date');
						vcurrentparam := sgroupid || '_UnBillInc';
						contractparams.savedialogbool(pdialog
													 ,vcurrentparam
													 ,cobjecttype
													 ,sprofileid
													 ,pwhitelog     => TRUE
													 ,pparamname    => 'Group:' || sgroupid ||
																	   ' Charge interest on unbilled transactions too');
						vcurrentparam := sgroupid || '_PreUsageStartFrom';
						contractparams.savedialogfieldnumber(pdialog
															,vcurrentparam
															,cobjecttype
															,sprofileid
															,pwhitelog     => TRUE
															,pparamname    => 'Group:' || sgroupid ||
																			  'Preferential Rate usage starts from');
					ELSE
						s.say(cmethodname || '        -info: ' || sgroupid ||
							  '_ChargeInt WAS NOT saved');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_StartDate');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_ShiftDays');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_AccRemain');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_DaysInYear');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_ChargeOnB');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_CrdPrcDate');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_CrdPrcType');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_ProCalId');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_PreCalId');
						contractparams.deletevalue(cobjecttype, sprofileid, sgroupid || '_PreUse');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_ChargePaid');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_OnlyFirst');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_TillCurSD');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_UnBillInc');
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_UseRedRate');
					
						contractparams.deletevalue(cobjecttype
												  ,sprofileid
												  ,sgroupid || '_PreUsageStartFrom');
					
					END IF;
				EXCEPTION
					WHEN referenceprchistory.ratenotdefined THEN
						s.say(cmethodname || '### TEST - 1', 1);
						dialog.sethothint(pdialog, 'Interest rate not defined');
						RETURN;
					WHEN contractparams.valuenotexists
						 OR contractparams.incorrectvalue THEN
						s.say(cmethodname || '### TEST - 2', 1);
						dialog.sethothint(pdialog, 'Incorrect value');
						dialog.goitem(pdialog, vcurrentparam);
						ROLLBACK TO setparams;
						RETURN;
					WHEN OTHERS THEN
						s.say(cmethodname || '### TEST - 3', 1);
						err.seterror(SQLCODE, cpackagename || '.ProfileGroupSetupDialogProc');
						service.sayerr(pdialog, 'Error');
						dialog.goitem(pdialog, 'Cancel');
						RETURN;
				END;
			END IF;
		END IF;
		s.say(cmethodname || '    -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.ProfileGroupSetupDialogProc');
			RAISE;
	END;

	FUNCTION editredintdialog
	(
		ppriority    IN NUMBER
	   ,pgraceisused IN BOOLEAN
	) RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.EditRedIntDialog';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	
		vdialog   NUMBER;
		vmenu     NUMBER;
		vopermenu NUMBER;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		vdialog := dialog.new('Reduced interest settings', 0, 0, 70, 7, pextid => cmethodname);
		dialog.bevel(vdialog, 1, 1, 68, 4, dialog.bevel_frame, pcaption => 'Settings');
		dialog.setdialogpre(vdialog, cpackagename || '.EditRedIntDialogProc');
		dialog.setdialogvalid(vdialog, cpackagename || '.EditRedIntDialogProc');
		dialog.setdialogpost(vdialog, cpackagename || '.EditRedIntDialogProc');
		dialog.inputchar(vdialog, 'Terms', 10, 2, 35, 'Reducing rate condition', NULL, 'Term:');
		dialog.listaddfield(vdialog, 'Terms', 'ItemID', 'N', 1, 0);
		dialog.listaddfield(vdialog, 'Terms', 'ItemName', 'C', 40, 1);
		dialog.setitemattributies(vdialog, 'Terms', dialog.updateoff);
		IF pgraceisused
		THEN
			dialog.listaddrecord(vdialog
								,'Terms'
								,cgrace_paidmp || '~MP is paid before DD'
								,dialog.cmconfirm);
			dialog.listaddrecord(vdialog
								,'Terms'
								,cgrace_paidsdbal || '~SD balance is paid before DD'
								,dialog.cmconfirm);
		END IF;
		dialog.listaddrecord(vdialog
							,'Terms'
							,cgrace_currentbalisless || '~Current balance is less than'
							,dialog.cmconfirm);
		dialog.listaddrecord(vdialog
							,'Terms'
							,cgrace_unpdbaloflastsdisless ||
							 '~Unpaid balance of last SD is less than'
							,dialog.cmconfirm);
		dialog.listaddrecord(vdialog
							,'Terms'
							,cgrace_unpaidsdamntonddisless ||
							 '~Unpaid SD Amount on Due Date is less than'
							,dialog.cmconfirm);
	
		dialog.inputmoney(vdialog, camountforredrateterms, 50, 2, '');
		dialog.setenable(vdialog, camountforredrateterms, FALSE);
	
		dialog.inputchar(vdialog, 'RedPrcHist', 10, 3, 35, 'Reduced rate', NULL, 'Rate:');
		dialog.listaddfield(vdialog, 'RedPrcHist', 'ItemID', 'C', 40, 0);
		dialog.listaddfield(vdialog, 'RedPrcHist', 'ItemName', 'C', 60, 1);
		dialog.setitemattributies(vdialog, 'RedPrcHist', dialog.updateoff);
	
		dialog.inputchar(vdialog
						,'Usage'
						,10
						,4
						,35
						,'For what period the reduced term should be applied'
						,NULL
						,'Usage:');
		dialog.listaddfield(vdialog, 'Usage', 'ItemID', 'N', 1, 0);
		dialog.listaddfield(vdialog, 'Usage', 'ItemName', 'C', 40, 1);
		dialog.setitemattributies(vdialog, 'Usage', dialog.updateoff);
		dialog.listaddrecord(vdialog
							,'Usage'
							,cgraceperusage_always || '~Always'
							,dialog.cmconfirm
							,0);
		dialog.listaddrecord(vdialog
							,'Usage'
							,cgraceperusage_prevcycleonly || '~Apply for previous cycle only'
							,dialog.cmconfirm
							,0);
	
		siscreatenew := TRUE;
		FOR i IN (SELECT *
				  FROM   tcontractredintsettings
				  WHERE  branch = cbranch
				  AND    profileid = sprofileid
				  AND    groupid = sgroupid
				  AND    priority = ppriority)
		LOOP
			dialog.setcurrecbyvalue(vdialog, 'Terms', 'ItemId', i.terms);
			dialog.setcurrecbyvalue(vdialog
								   ,'Usage'
								   ,'ItemId'
								   ,nvl(i.reducedtermusage, cgraceperusage_always));
			dialog.putnumber(vdialog, camountforredrateterms, i.amount);
			referenceprchistory.fillitem(vdialog
										,'RedPrcHist'
										,referenceprchistory.cperiodremain
										,referenceprchistory.crvpother1
										,sprofileid
										,stypefillarray
										,TRUE
										,-1
										,'Don`t Charge Interest'
										,pcurrentid => i.rateid);
			siscreatenew := FALSE;
		END LOOP;
		vmenu     := mnu.new(vdialog);
		vopermenu := mnu.submenu(vmenu, 'Dictionaries', 'Dictionaries');
		mnu.item(vopermenu
				,'SprPrc'
				,'Dictionary of interest rates'
				,0
				,0
				,'Dictionary of interest rates');
		dialog.setitempre(vdialog
						 ,'SprPrc'
						 ,cpackagename || '.EditRedIntDialogProc'
						 ,dialog.proctype);
		dialog.button(vdialog
					 ,'Ok'
					 ,22
					 ,6
					 ,12
					 ,'OK'
					 ,dialog.cmok
					 ,0
					 ,'Save changes and exit dialog');
		dialog.button(vdialog
					 ,'Cancel'
					 ,36
					 ,6
					 ,12
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel changes and exit dialog');
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
		s.say(cmethodname || '    -->>  END', 1);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.EditRedIntDialog');
			RAISE;
	END;

	PROCEDURE editredintdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.EditRedIntDialogProc';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	
		vrateid NUMBER;
		vterms  NUMBER;
		vamount NUMBER;
	
		vreducedtermusage tcontractredintsettings.reducedtermusage%TYPE;
	
		PROCEDURE enablesdamountfield IS
		
		BEGIN
			IF dialog.getcurrentrecordnumber(pdialog, 'Terms', 'ItemID') IN
			   (cgrace_currentbalisless
			   ,cgrace_unpdbaloflastsdisless
			   ,cgrace_unpaidsdamntonddisless)
			THEN
				dialog.setenable(pdialog, camountforredrateterms, TRUE);
			ELSE
				dialog.setenable(pdialog, camountforredrateterms, FALSE);
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.EditRedIntDialogProc.EnableSDAmountField');
				RAISE;
		END;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		SAVEPOINT redintdialog;
		CASE pwhat
			WHEN dialog.wtdialogpre THEN
				IF siscreatenew
				THEN
					referenceprchistory.fillitem(pdialog
												,'RedPrcHist'
												,referenceprchistory.cperiodremain
												,referenceprchistory.crvpother1
												,sprofileid
												,stypefillarray
												,TRUE
												,-1
												,'Don''t Charge Interest');
				END IF;
				enablesdamountfield;
			WHEN dialog.wtitempre THEN
				CASE pitemname
					WHEN 'SPRPRC' THEN
						dialog.exec(referenceprchistory.maindialog(referenceprchistory.ccontracttype
																  ,NULL));
						referenceprchistory.fillitem(pdialog
													,'RedPrcHist'
													,referenceprchistory.cperiodremain
													,referenceprchistory.crvpother1
													,sprofileid
													,stypefillarray
													,TRUE
													,-1
													,'Don''t Charge Interest');
					ELSE
						NULL;
				END CASE;
			WHEN dialog.wtitempost THEN
				NULL;
			WHEN dialog.wtdialogvalid THEN
				CASE pcmd
					WHEN dialog.cmconfirm THEN
						CASE pitemname
							WHEN 'TERMS' THEN
								enablesdamountfield;
							ELSE
								NULL;
						END CASE;
						dialog.goitem(pdialog, pitemname);
						RETURN;
					WHEN dialog.cmok THEN
						vterms            := dialog.getcurrentrecordnumber(pdialog
																		  ,'Terms'
																		  ,'ItemID');
						vrateid           := dialog.getcurrentrecordnumber(pdialog
																		  ,'RedPrcHist'
																		  ,'ItemID');
						vreducedtermusage := dialog.getcurrentrecordnumber(pdialog
																		  ,'Usage'
																		  ,'ItemID');
						IF vterms IN (cgrace_currentbalisless
									 ,cgrace_unpdbaloflastsdisless
									 ,cgrace_unpaidsdamntonddisless)
						THEN
							vamount := dialog.getnumber(pdialog, camountforredrateterms);
						
						ELSE
							vamount := NULL;
						END IF;
						IF siscreatenew
						THEN
							INSERT INTO tcontractredintsettings
							VALUES
								(cbranch
								,sprofileid
								,sgroupid
								,spriority
								,vterms
								,vamount
								,vrateid
								,vreducedtermusage);
						ELSE
							UPDATE tcontractredintsettings
							SET    terms            = vterms
								  ,amount           = vamount
								  ,rateid           = vrateid
								  ,reducedtermusage = vreducedtermusage
							WHERE  branch = cbranch
							AND    profileid = sprofileid
							AND    groupid = sgroupid
							AND    priority = spriority;
						END IF;
					ELSE
						NULL;
				END CASE;
			ELSE
				NULL;
		END CASE;
		s.say(cmethodname || '    -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK TO redintdialog;
			error.showerror('Error');
			dialog.goitem(pdialog, 'Cancel');
	END;

	PROCEDURE makeitem
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,px        IN NUMBER
	   ,py        IN NUMBER
	   ,plen      IN NUMBER
	   ,pcaption  IN VARCHAR
	   ,phint     IN VARCHAR
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.MakeItem';
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		dialog.inputchar(pdialog, pitemname, px, py, plen, phint, plen, pcaption);
		dialog.listaddfield(pdialog, pitemname, 'ItemID', 'N', 3, 0);
		dialog.listaddfield(pdialog, pitemname, 'ItemName', 'C', plen - 3, 1);
		dialog.setitemattributies(pdialog, pitemname, dialog.updateoff);
		s.say(cmethodname || '    -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.MakeItem');
			RAISE;
	END;

	PROCEDURE fillitem
	(
		pdialog       IN NUMBER
	   ,pitemname     IN VARCHAR
	   ,pcurrency     IN NUMBER
	   ,pemptyrecname IN VARCHAR := NULL
	   ,pmpprofile    BOOLEAN := FALSE
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.FillItem';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	
		CURSOR c1 IS
			SELECT *
			FROM   tcontractprofile
			WHERE  branch = cbranch
			AND    currency = pcurrency
			ORDER  BY profilename;
	
		CURSOR c2 IS
			SELECT * FROM tcontractmpprofile WHERE branch = cbranch ORDER BY profilename;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		dialog.listclear(pdialog, pitemname);
		IF (pemptyrecname IS NOT NULL)
		THEN
			dialog.listaddrecord(pdialog, pitemname, '0~' || '0 ' || pemptyrecname || '~');
		END IF;
		IF NOT pmpprofile
		THEN
			FOR i IN c1
			LOOP
				dialog.listaddrecord(pdialog
									,pitemname
									,i.profileid || '~' || i.profileid || ' ' || i.profilename || '~');
			END LOOP;
		ELSE
			FOR i IN c2
			LOOP
				dialog.listaddrecord(pdialog
									,pitemname
									,i.profileid || '~' || i.profileid || ' ' || i.profilename || '~');
			END LOOP;
		END IF;
		s.say(cmethodname || '    -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.FillItem');
			RAISE;
	END;

	PROCEDURE fillgrouparray
	(
		pprofileid  IN NUMBER
	   ,ogrouparray IN OUT NOCOPY typenumber
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.FillGroupArray';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		SELECT a.groupid BULK COLLECT
		INTO   ogrouparray
		FROM   tcontractprofilegroup a
		WHERE  a.branch = cbranch
		AND    a.profileid = pprofileid
		ORDER  BY a.branch
				 ,a.profileid
				 ,a.priority;
		s.say(cmethodname || '    -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.FillGroupArray');
			RAISE;
	END;

	FUNCTION getgrouplist RETURN typenumber IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetGroupList';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		varr typenumber;
	
	BEGIN
		s.say(cmethodname || '    --<< BEGIN', 1);
		SELECT a.groupid BULK COLLECT
		INTO   varr
		FROM   tcontractentrygroup a
		WHERE  a.branch = cbranch;
		s.say(cmethodname || '    -->>  END', 1);
		RETURN varr;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetGroupList');
			RAISE;
	END;

	FUNCTION getgroupfulllist RETURN typegrouparray IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetGroupFullList';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		varr typegrouparray;
	
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		SELECT groupid
			  ,groupname
			  ,cashadvance AS grouptype BULK COLLECT
		INTO   varr
		FROM   tcontractentrygroup a
		WHERE  a.branch = cbranch
		ORDER  BY groupid;
		s.say(cmethodname || '     -->>  END', 1);
		RETURN varr;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetGroupFullList');
			RAISE;
	END;

	FUNCTION getgroupentcodelist(pgroupid IN NUMBER) RETURN typenumber IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetGroupEntCodeList';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	
		varr typenumber;
	
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		IF pgroupid = 0
		THEN
			SELECT a.code BULK COLLECT
			INTO   varr
			FROM   treferenceentry a
			WHERE  a.branch = cbranch
			AND    a.code NOT IN
				   (SELECT entcode FROM tcontractentrygrouplist WHERE branch = cbranch);
		ELSE
			SELECT a.entcode BULK COLLECT
			INTO   varr
			FROM   tcontractentrygrouplist a
			WHERE  a.branch = cbranch
			AND    a.groupid = pgroupid;
		END IF;
		s.say(cmethodname || '     -->>  END', 1);
		RETURN varr;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetGroupEntCodeList');
			RAISE;
	END;

	FUNCTION getgroupidbyentcode(pentcode IN NUMBER) RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetGroupIdByEntCode';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		vret NUMBER;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		SELECT groupid
		INTO   vret
		FROM   tcontractentrygrouplist
		WHERE  branch = cbranch
		AND    entcode = pentcode;
		s.say(cmethodname || '     -->>  END', 1);
		RETURN vret;
	EXCEPTION
		WHEN no_data_found THEN
			RETURN 0;
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END getgroupidbyentcode;

	FUNCTION getgrouptypebyentrycode(pentrycode IN NUMBER) RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetGroupTypeByEntryCode';
	BEGIN
		RETURN getgrouptype(getgroupidbyentcode(pentrycode));
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getgrouptypebyentrycode;

	FUNCTION getgrouptypebyentryident(pentryident IN VARCHAR2) RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetGroupTypeByEntryIdent';
		ventrycode NUMBER;
	BEGIN
		contracttools.readentcode(ventrycode, pentryident);
		RETURN getgrouptypebyentrycode(ventrycode);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getgrouptypebyentryident;

	FUNCTION getgrouptype(pgroupid IN NUMBER) RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetGroupType';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		vret NUMBER;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		SELECT cashadvance
		INTO   vret
		FROM   tcontractentrygroup
		WHERE  branch = cbranch
		AND    groupid = pgroupid;
		s.say(cmethodname || '     -->>  END', 1);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetGroupType');
			RAISE;
	END;

	PROCEDURE getmpgroupsettings
	(
		pprofileid  IN NUMBER
	   ,pgrouparray IN OUT NOCOPY typempgroupparamarray
	) IS
		cmethodname   CONSTANT VARCHAR2(100) := cpackagename || '.GetMPGroupSettings';
		cbranch       CONSTANT NUMBER := seance.getbranch;
		cmpobjecttype CONSTANT NUMBER := getmpobjecttype;
	
		CURSOR c1 IS
			SELECT *
			FROM   tcontractentrygroup
			WHERE  branch = cbranch
			ORDER  BY branch
					 ,groupid;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		pgrouparray(cclgroup).prcvalue := nvl(contractparams.loadnumber(cmpobjecttype
																	   ,pprofileid
																	   ,'MP_Percent_CL'
																	   ,FALSE)
											 ,0);
		pgrouparray(cclgroup).curonly := FALSE;
		FOR i IN c1
		LOOP
			pgrouparray(i.groupid).prcvalue := nvl(contractparams.loadnumber(cmpobjecttype
																			,pprofileid
																			,'MP_Percent_' ||
																			 i.groupid
																			,FALSE)
												  ,0);
			pgrouparray(i.groupid).curonly := nvl(contractparams.loadbool(cmpobjecttype
																		 ,pprofileid
																		 ,'MP_Current_' ||
																		  i.groupid
																		 ,FALSE)
												 ,FALSE);
		END LOOP;
		s.say(cmethodname || '     -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetMPGroupSettings');
			RAISE;
	END;

	FUNCTION getnewmpprofileid RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetNewMPProfileId';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vprofileid NUMBER;
	BEGIN
		t.enter(cmethodname);
		SELECT coalesce(MAX(profileid), 0) + 1
		INTO   vprofileid
		FROM   tcontractmpprofile
		WHERE  branch = cbranch;
		t.leave(cmethodname, 'return ' || to_char(coalesce(vprofileid, 1)));
		RETURN coalesce(vprofileid, 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetNewEntryProfileId');
			RAISE;
	END;

	PROCEDURE insertmpprofile
	(
		pprofileid   NUMBER
	   ,pprofilename VARCHAR2
	   ,plog         BOOLEAN := TRUE
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.InsertMPProfile';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vprofileid NUMBER := pprofileid;
	BEGIN
		t.enter(cmethodname);
		vprofileid := coalesce(vprofileid, getnewmpprofileid());
	
		INSERT INTO tcontractmpprofile
		VALUES
			(cbranch
			,vprofileid
			,pprofilename);
	
		IF plog
		THEN
			a4mlog.cleanparamlist;
			a4mlog.addparamrec('MPProfile', vprofileid);
			a4mlog.logobject(object.gettype(contracttype.object_name)
							,'CONTRACT_MP_PROFILE=' || vprofileid
							,'Creation'
							,a4mlog.act_add
							,a4mlog.putparamlist);
		END IF;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetNewEntryProfileId');
			RAISE;
	END;

	PROCEDURE updatempprofile
	(
		pprofileid   NUMBER
	   ,pprofilename VARCHAR2
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.InsertMPProfile';
		cbranch     CONSTANT NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethodname);
		UPDATE tcontractmpprofile
		SET    profilename = pprofilename
		WHERE  branch = cbranch
		AND    profileid = pprofileid;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetNewEntryProfileId');
			RAISE;
	END;

	FUNCTION mpprofiledialog(preadonly IN BOOLEAN := FALSE) RETURN NUMBER IS
		cmethodname  CONSTANT VARCHAR2(100) := cpackagename || '.MPProfileDialog';
		chandlername CONSTANT VARCHAR2(100) := cpackagename || '.MPProfileDialogProc';
		vdialog  NUMBER;
		vmenu    NUMBER;
		vsubmenu NUMBER;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		vdialog := dialog.new('Minimum Payment calculation profiles setup'
							 ,0
							 ,0
							 ,80
							 ,17
							 ,presizable                                  => TRUE
							 ,pextid                                      => cmethodname);
		dialog.hiddenbool(vdialog, c_readonlyflag, preadonly);
		dialog.setdialogpre(vdialog, chandlername);
		dialog.setdialogvalid(vdialog, chandlername);
		dialog.setdialogpost(vdialog, chandlername);
	
		vmenu    := mnu.new(vdialog);
		vsubmenu := mnu.submenu(vmenu, 'Operations', '');
		mnu.item(vsubmenu, 'miImport', 'Import', 0, 0, '');
		dialog.setitempre(vdialog, 'miImport', chandlername);
		mnu.item(vsubmenu, 'miExport', 'Export', 0, 0, '');
		dialog.setitempre(vdialog, 'miExport', chandlername);
	
		dialog.list(vdialog, 'ProfileList', 2, 2, 59, 11, 'Profiles');
		dialog.setanchor(vdialog, 'ProfileList', dialog.anchor_all);
		dialog.listaddfield(vdialog, 'ProfileList', 'Id', 'N', 4, 1);
		dialog.listaddfield(vdialog, 'ProfileList', 'Name', 'C', 50, 1);
		dialog.setcaption(vdialog, 'ProfileList', 'Code~Profile name');
		dialog.setitempost(vdialog, 'ProfileList', chandlername);
		dialog.button(vdialog, 'Insert', 66, 3, 12, 'Add', 0, 0, 'Add new profile');
		dialog.setanchor(vdialog, 'Insert', dialog.anchor_right + dialog.anchor_top);
		dialog.button(vdialog
					 ,'Copy'
					 ,66
					 ,5
					 ,12
					 ,'Copy'
					 ,0
					 ,0
					 ,'Copy selected profile into new profile');
		dialog.setanchor(vdialog, 'Copy', dialog.anchor_right + dialog.anchor_top);
		dialog.button(vdialog, 'Delete', 66, 7, 12, 'Delete', 0, 0, 'Delete selected profile');
		dialog.setanchor(vdialog, 'Delete', dialog.anchor_right + dialog.anchor_top);
		dialog.button(vdialog, 'Exit', 66, 14, 12, 'Exit', dialog.cmok, 0, 'Exit dialog');
		dialog.setanchor(vdialog, 'Exit', dialog.anchor_right + dialog.anchor_bottom);
		dialog.setitempre(vdialog, 'Insert', chandlername, dialog.proctype);
		dialog.setitempre(vdialog, 'Copy', chandlername, dialog.proctype);
		dialog.setitempre(vdialog, 'Delete', chandlername, dialog.proctype);
		s.say(cmethodname || '     -->>  END', 1);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(chandlername);
			RAISE;
	END;

	PROCEDURE dlg_mpprofiles_filllist(pdialog NUMBER) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.Dlg_MPProfiles_FillList';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		CURSOR c1 IS
			SELECT *
			FROM   tcontractmpprofile
			WHERE  branch = cbranch
			ORDER  BY branch
					 ,profileid;
	
	BEGIN
		s.say(cmethodname || '      --<< BEGIN', 1);
		dialog.listclear(pdialog, 'ProfileList');
		FOR i IN c1
		LOOP
			dialog.listaddrecord(pdialog
								,'ProfileList'
								,i.profileid || '~' || i.profileid || ' ' || i.profilename || '~');
		END LOOP;
		s.say(cmethodname || '      -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.MPProfileDialogProc.Dlg_Profiles_FillList');
			RAISE;
	END;

	PROCEDURE mpprofiledialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname   CONSTANT VARCHAR2(100) := cpackagename || '.MPProfileDialogProc';
		cbranch       CONSTANT NUMBER := seance.getbranch;
		cmpobjecttype CONSTANT NUMBER := getmpobjecttype;
	
		vret   NUMBER;
		vname  VARCHAR(50);
		vcount NUMBER;
	
		vdelinqsettingsmpprofinfo VARCHAR2(100);
	
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		IF pwhat = dialog.wtdialogpre
		THEN
		
			dialog.setenable(pdialog, 'Insert', NOT dialog.getbool(pdialog, c_readonlyflag));
			dialog.setenable(pdialog, 'Delete', NOT dialog.getbool(pdialog, c_readonlyflag));
			dialog.setenable(pdialog, 'Copy', NOT dialog.getbool(pdialog, c_readonlyflag));
		
			dlg_mpprofiles_filllist(pdialog);
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF pitemname = 'INSERT'
			THEN
				DECLARE
					vprofileid NUMBER;
				BEGIN
					SAVEPOINT spitem;
					vprofileid := getnewmpprofileid();
				
					insertmpprofile(vprofileid, 'New profile ' || vprofileid);
				
					IF dialog.exec(mpprofilesetupdialog(vprofileid)) = dialog.cmok
					THEN
						COMMIT;
						dlg_mpprofiles_filllist(pdialog);
						dialog.setcurrecbyvalue(pdialog, 'ProfileList', 'Id', vprofileid);
					ELSE
						ROLLBACK TO spitem;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						ROLLBACK TO spitem;
						RAISE;
				END;
			ELSIF pitemname = 'COPY'
			THEN
				DECLARE
					vprofileid NUMBER;
				BEGIN
					SAVEPOINT spitem;
					vret       := dialog.getcurrentrecordnumber(pdialog, 'ProfileList', 'Id');
					vprofileid := getnewmpprofileid();
					insertmpprofile(vprofileid, 'New profile ' || vprofileid);
					contractparams.copyparameters(cmpobjecttype, vret, vprofileid);
				
					IF dialog.exec(mpprofilesetupdialog(vprofileid)) = dialog.cmok
					THEN
						COMMIT;
						dlg_mpprofiles_filllist(pdialog);
						dialog.setcurrecbyvalue(pdialog, 'ProfileList', 'Id', vprofileid);
					ELSE
						ROLLBACK TO spitem;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						ROLLBACK TO spitem;
						RAISE;
				END;
			ELSIF pitemname = 'DELETE'
			THEN
				vret := dialog.getcurrentrecordnumber(pdialog, 'PROFILELIST', 'Id');
				SELECT COUNT(*)
				INTO   vcount
				FROM   tcontracttypeparameters
				WHERE  branch = cbranch
				AND    key LIKE 'MPPROFILE%'
				AND    VALUE = to_char(vret);
				IF vcount > 0
				THEN
					htools.sethotmessage('Warning'
										,'This profile is already in use and cannot be deleted!');
					RETURN;
				END IF;
			
				SELECT COUNT(*)
				INTO   vcount
				FROM   tcontractparameters
				WHERE  branch = cbranch
				AND    key LIKE 'MPPROFILE%'
				AND    VALUE = to_char(vret);
				IF vcount > 0
				THEN
					htools.sethotmessage('Warning'
										,'This profile already used in contracts and cannot be deleted!');
					RETURN;
				END IF;
			
				SELECT MIN('Contract type = ' || contracttype || ', Overdue period = ' || period ||
						   ', Overlimit = ' || overlimit)
				INTO   vdelinqsettingsmpprofinfo
				FROM   tcontractdelinqprofiles
				WHERE  branch = cbranch
				AND    mpprofile = vret;
				IF vdelinqsettingsmpprofinfo IS NOT NULL
				THEN
					htools.sethotmessage('Warning'
										,'Deleted profile is used currently in Delinquency State settings: ' ||
										 vdelinqsettingsmpprofinfo);
					RETURN;
				END IF;
			
				SELECT COUNT(*)
				INTO   vcount
				FROM   tcontractparameters
				WHERE  branch = cbranch
				AND    key LIKE 'MPPROFILE%'
				AND    VALUE = to_char(vret);
				IF vcount > 0
				THEN
					htools.sethotmessage('Warning'
										,'This profile is already in use and cannot be deleted!');
					RETURN;
				END IF;
				IF htools.ask('Attention', 'Delete selected profile?')
				THEN
					BEGIN
						SAVEPOINT spitem;
					
						DELETE FROM tcontractmpprofile
						WHERE  branch = cbranch
						AND    profileid = vret;
					
						a4mlog.cleanparamlist;
						a4mlog.addparamrec('MPProfile', vret);
						a4mlog.logobject(object.gettype(contracttype.object_name)
										,'CONTRACT_MP_PROFILE=' || vret
										,'Deleting'
										,a4mlog.act_del
										,a4mlog.putparamlist);
					
						contractparams.deletevalue(cmpobjecttype, vret);
					
						custom_contractexchangetools.deletematchingrows(cpackagename
																	   ,creftable_mpprofiles
																	   ,'ProfileId'
																	   ,pdestcode => to_char(vret));
					
						dialog.listdeleterecord(pdialog
											   ,'PROFILELIST'
											   ,dialog.getcurrec(pdialog, 'PROFILELIST'));
						COMMIT;
					EXCEPTION
						WHEN OTHERS THEN
							ROLLBACK TO spitem;
							error.showerror('Error');
							dialog.goitem(pdialog, 'Delete');
					END;
				END IF;
			
			ELSIF pitemname = upper('miExport')
			THEN
				DECLARE
					cbranch CONSTANT VARCHAR2(100) := seance.getbranch();
					vexportsettings custom_contractexchangetools.typeexportsettings;
				BEGIN
					vexportsettings.tablename := creftable_mpprofiles;
					vexportsettings.packagename := cpackagename;
					vexportsettings.objectname := cobjectname_mpprofiles;
					vexportsettings.whereclause := 'branch=' || cbranch;
					vexportsettings.orderclause := 'ProfileID';
					vexportsettings.codecolumn := 'ProfileID';
					vexportsettings.identcolumn := '';
					vexportsettings.namecolumn := 'ProfileName';
					vexportsettings.exportchilds := FALSE;
					vexportsettings.additionalsettings(vexportsettings.tablename).parametersobjecttype := 'CONTRACT_MP_PROFILE';
					dialog.exec(custom_contractexchangetools.dialogexport(vexportsettings));
				END;
			
			ELSIF pitemname = upper('miImport')
			THEN
				mpprofiles_importinteractive(pdialog);
			END IF;
		ELSIF pwhat = dialog.wtitempost
		THEN
			IF pitemname = 'PROFILELIST'
			THEN
				DECLARE
					vprofileid NUMBER;
					vpos       NUMBER;
				BEGIN
					SAVEPOINT spitem;
					vprofileid := dialog.getcurrentrecordnumber(pdialog, pitemname, 'Id');
					vpos       := dialog.getcurrec(pdialog, pitemname);
					IF dialog.exec(mpprofilesetupdialog(vprofileid
													   ,dialog.getbool(pdialog, c_readonlyflag))) =
					   dialog.cmok
					THEN
						SELECT profilename
						INTO   vname
						FROM   tcontractmpprofile
						WHERE  branch = cbranch
						AND    profileid = vprofileid;
						dialog.listputrecord(pdialog
											,'PROFILELIST'
											,vprofileid || '~' || vprofileid || ' ' || vname || '~'
											,vpos);
						COMMIT;
					ELSE
						ROLLBACK TO spitem;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						ROLLBACK TO spitem;
						RAISE;
				END;
			END IF;
		END IF;
		s.say(cmethodname || '       -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.MPProfileDialogProc');
			RAISE;
	END;

	FUNCTION mpprofilesetupdialog
	(
		pprofileid IN NUMBER
	   ,preadonly  IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.MPProfileSetupDialog';
		vdialog NUMBER;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		smpprofileid := pprofileid;
		vdialog := dialog.new('Profile setup' || CASE
								  WHEN pprofileid IS NOT NULL THEN
								   ' <ID=' || pprofileid || '>'
							  END
							 ,0
							 ,0
							 ,76
							 ,22
							 ,pextid => cmethodname);
		dialog.hiddenbool(vdialog, c_readonlyflag, preadonly);
		dialog.setdialogpre(vdialog, cpackagename || '.MPProfileSetupDialogProc');
		dialog.setdialogvalid(vdialog, cpackagename || '.MPProfileSetupDialogProc');
		dialog.setdialogpost(vdialog, cpackagename || '.MPProfileSetupDialogProc');
	
		dialog.bevel(vdialog, 1, 1, 75, 2, dialog.bevel_frame);
		dialog.inputchar(vdialog
						,'ProfileName'
						,22
						,2
						,50
						,'Specify profile name'
						,50
						,'Profile name:');
	
		dialog.bevel(vdialog, 1, 3, 75, 13, dialog.bevel_frame, pcaption => 'Minimum Payment');
		dialog.inputchar(vdialog
						,'MinPayBase'
						,22
						,4
						,30
						,'Base amount for Minimum Payment calculation'
						,NULL
						,'Base amount:');
		dialog.listaddfield(vdialog, 'MinPayBase', 'ItemID', 'N', 1, 0);
		dialog.listaddfield(vdialog, 'MinPayBase', 'ItemName', 'C', 30, 1);
		dialog.setitemattributies(vdialog, 'MinPayBase', dialog.updateoff);
		dialog.listaddrecord(vdialog
							,'MinPayBase'
							,cmpbaselimit || '~Credit Limit~'
							,dialog.cm_confirm);
		dialog.listaddrecord(vdialog
							,'MinPayBase'
							,cmpbaseused || '~Total Used Credit Limit~'
							,dialog.cm_confirm);
		dialog.listaddrecord(vdialog
							,'MinPayBase'
							,cmpbasegroup || '~Used Limit by Operation Groups~'
							,dialog.cm_confirm);
		dialog.button(vdialog
					 ,'GrpSetup'
					 ,55
					 ,4
					 ,12
					 ,'Setup'
					 ,0
					 ,0
					 ,'Minimum Payment settings bu operation group');
		dialog.setitempre(vdialog
						 ,'GrpSetup'
						 ,cpackagename || '.MPProfileSetupDialogProc'
						 ,dialog.proctype);
		dialog.inputchar(vdialog
						,'MinPayType'
						,22
						,5
						,30
						,'Minimum Payment calculation type'
						,NULL
						,'Calculation type:');
		dialog.listaddfield(vdialog, 'MinPayType', 'ItemID', 'N', 1, 0);
		dialog.listaddfield(vdialog, 'MinPayType', 'ItemName', 'C', 30, 1);
		dialog.setitemattributies(vdialog, 'MinPayType', dialog.updateoff);
		dialog.listaddrecord(vdialog, 'MinPayType', '1~Calculate as total of~');
		dialog.listaddrecord(vdialog, 'MinPayType', '2~Calculate as maximum between~');
		dialog.listaddrecord(vdialog, 'MinPayType', '3~Calculate as minimum between~');
		dialog.inputmoney(vdialog
						 ,'MinPayAmount'
						 ,22
						 ,6
						 ,'Specify Minimum Payment flat amount'
						 ,pcaption => 'Flat amount:');
		dialog.inputmoney(vdialog
						 ,'MinPayPrc'
						 ,22
						 ,7
						 ,'Specify Minimum Payment percentage value'
						 ,pcaption => 'Percentage value:');
		dialog.inputcheck(vdialog
						 ,'MinPayPrcCL'
						 ,39
						 ,7
						 ,36
						 ,'Use percent of Credit Limit additionally in MP calculation'
						 ,'Use percent of Credit Limit');
		dialog.setitempre(vdialog
						 ,'MinPayPrcCL'
						 ,cpackagename || '.MPProfileSetupDialogProc'
						 ,dialog.proctype);
		dialog.bevel(vdialog, 1, 8, 75, 1, dialog.bevel_top, pcaption => 'Overdue amount');
		dialog.inputcheck(vdialog
						 ,'IncUnpaidMP'
						 ,5
						 ,9
						 ,62
						 ,'Include overdue amount to MP amount'
						 ,'Include overdue amount to MP amount');
		dialog.setitempre(vdialog
						 ,'IncUnpaidMP'
						 ,cpackagename || '.MPProfileSetupDialogProc'
						 ,dialog.proctype);
		dialog.inputcheck(vdialog
						 ,'AddUnpaidMP'
						 ,5
						 ,10
						 ,62
						 ,'Include unpaid MP amount to base calculation amount'
						 ,'Include unpaid MP amount to base calculation amount');
		dialog.bevel(vdialog, 1, 11, 75, 1, dialog.bevel_top, pcaption => 'Over-limit amount');
	
		dialog.inputcheck(vdialog
						 ,'IncOverLimit'
						 ,5
						 ,12
						 ,62
						 ,'Include to Minimum Payment amount'
						 ,'Include to MP amount');
		dialog.setitempre(vdialog
						 ,'IncOverLimit'
						 ,cpackagename || '.MPProfileSetupDialogProc'
						 ,dialog.proctype);
	
		dialog.inputchar(vdialog
						,'OverLimitCalcType'
						,46
						,12
						,24
						,'How overlimit should be calculated'
						,NULL
						,'and calculate as:');
		dialog.listaddfield(vdialog, 'OverLimitCalcType', 'ItemID', 'N', 1, 0);
		dialog.listaddfield(vdialog, 'OverLimitCalcType', 'ItemName', 'C', 30, 1);
		dialog.setitemattributies(vdialog, 'OverLimitCalcType', dialog.updateoff);
		dialog.listaddrecord(vdialog
							,'OverLimitCalcType'
							,chowovlcalc_total || '~' || 'Total overlimit' || '~'
							,dialog.cm_confirm);
		dialog.listaddrecord(vdialog
							,'OverLimitCalcType'
							,chowovlcalc_lastcycle || '~' || 'Last cycle overlimit' || '~'
							,dialog.cm_confirm);
		dialog.setitemattributies(vdialog, 'OverLimitCalcType', dialog.updateoff);
	
		dialog.inputcheck(vdialog
						 ,'AddOverLimit'
						 ,5
						 ,13
						 ,62
						 ,'Include over-limit amount to base calculation amount'
						 ,'Include over-limit amount to base calculation amount');
		dialog.bevel(vdialog, 1, 14, 75, 1, dialog.bevel_top);
		dialog.inputcheck(vdialog
						 ,'IncMax'
						 ,5
						 ,15
						 ,68
						 ,'Use maximum between overdue amount and over-limit amount'
						 ,'Use maximum between overdue amount and over-limit amount');
	
		dialog.bevel(vdialog, 1, 16, 75, 3, dialog.bevel_frame);
		dialog.inputmoney(vdialog
						 ,'CalcMPNotLess'
						 ,57
						 ,17
						 ,'Calculated MP amount should not be less than'
						 ,'Calculated MP amount should not be less than:');
		dialog.setitempre(vdialog
						 ,'CalcMPNotLess'
						 ,cpackagename || '.MPProfileSetupDialogProc'
						 ,dialog.proctype);
	
		dialog.inputmoney(vdialog
						 ,'CalcMPBalanceLess'
						 ,57
						 ,18
						 ,'MP will not be calculated if SD balance is less than the specified amount'
						 ,'MP should not be calculated if SD balance less than:');
	
		dialog.button(vdialog
					 ,'Ok'
					 ,26
					 ,21
					 ,12
					 ,'OK'
					 ,dialog.cmok
					 ,0
					 ,'Save changes and exit dialog');
		dialog.button(vdialog
					 ,'Cancel'
					 ,40
					 ,21
					 ,12
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel changes and exit dialog');
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
		s.say(cmethodname || '       -->>  END', 1);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.MPProfileSetupDialog');
			RAISE;
	END;

	PROCEDURE mpprofilesetupdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname   CONSTANT VARCHAR2(100) := cpackagename || '.MPProfileSetupDialogProc';
		cbranch       CONSTANT NUMBER := seance.getbranch;
		cmpobjecttype CONSTANT NUMBER := getmpobjecttype;
	
		vretc VARCHAR(50);
		vret  NUMBER;
	
		PROCEDURE enablecontrol IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.MPProfileSetupDialogProc.EnableControl';
			vminpaybase   NUMBER;
			vincunpaidmp  BOOLEAN;
			vincoverlimit BOOLEAN;
		BEGIN
			s.say(cmethodname || '      --<< BEGIN', 1);
			vminpaybase := dialog.getcurrentrecordnumber(pdialog, 'MinPayBase', 'ItemId');
		
			vincunpaidmp  := dialog.getbool(pdialog, 'IncUnpaidMP');
			vincoverlimit := dialog.getbool(pdialog, 'IncOverLimit');
			s.say('EnableControl->vMinPayBase=' || vminpaybase || ' vIncUnpaidMP=' ||
				  service.iif(vincunpaidmp, 1, 2) || ' vIncOverLimit=' ||
				  service.iif(vincoverlimit, 1, 2)
				 ,1);
			IF vminpaybase = cmpbaselimit
			THEN
				dialog.setitemattributies(pdialog, 'GrpSetup', dialog.echooff);
				dialog.setitemattributies(pdialog, 'MinPayPrc', dialog.selecton);
				dialog.setitemattributies(pdialog, 'MinPayPrcCL', dialog.echooff);
				dialog.setitemattributies(pdialog, 'IncUnpaidMP', dialog.selecton);
				dialog.setitemattributies(pdialog, 'IncOverLimit', dialog.selecton);
				dialog.setitemattributies(pdialog, 'AddOverLimit', dialog.selectoff);
				dialog.putbool(pdialog, 'AddOverLimit', FALSE);
				IF vincunpaidmp
				THEN
					dialog.setitemattributies(pdialog, 'AddUnpaidMP', dialog.selecton);
				ELSE
					dialog.setitemattributies(pdialog, 'AddUnpaidMP', dialog.selectoff);
					dialog.putbool(pdialog, 'AddUnpaidMP', FALSE);
				END IF;
			ELSIF vminpaybase = cmpbaseused
			THEN
				dialog.setitemattributies(pdialog, 'GrpSetup', dialog.echooff);
				dialog.setitemattributies(pdialog, 'MinPayPrc', dialog.selecton);
				dialog.setitemattributies(pdialog, 'MinPayPrcCL', dialog.echooff);
				dialog.setitemattributies(pdialog, 'IncUnpaidMP', dialog.selecton);
				dialog.setitemattributies(pdialog, 'IncOverLimit', dialog.selecton);
				IF vincunpaidmp
				THEN
					dialog.setitemattributies(pdialog, 'AddUnpaidMP', dialog.selecton);
				ELSE
					dialog.setitemattributies(pdialog, 'AddUnpaidMP', dialog.selectoff);
					dialog.putbool(pdialog, 'AddUnpaidMP', FALSE);
				END IF;
				IF vincoverlimit
				THEN
					dialog.setitemattributies(pdialog, 'AddOverLimit', dialog.selecton);
				ELSE
					dialog.setitemattributies(pdialog, 'AddOverLimit', dialog.selectoff);
					dialog.putbool(pdialog, 'AddOverLimit', FALSE);
				END IF;
			ELSE
				dialog.setitemattributies(pdialog, 'GrpSetup', dialog.echoon);
				dialog.setitemattributies(pdialog, 'MinPayPrcCL', dialog.echoon);
				IF dialog.getbool(pdialog, 'MinPayPrcCL')
				THEN
					dialog.setitemattributies(pdialog, 'MinPayPrc', dialog.selecton);
				ELSE
					dialog.setitemattributies(pdialog, 'MinPayPrc', dialog.selectoff);
				END IF;
				dialog.setitemattributies(pdialog, 'IncUnpaidMP', dialog.selecton);
				dialog.setitemattributies(pdialog, 'IncOverLimit', dialog.selecton);
				dialog.setitemattributies(pdialog, 'AddUnpaidMP', dialog.selectoff);
				dialog.putbool(pdialog, 'AddUnpaidMP', FALSE);
				dialog.setitemattributies(pdialog, 'AddOverLimit', dialog.selectoff);
				dialog.putbool(pdialog, 'AddOverLimit', FALSE);
			END IF;
			IF vincunpaidmp
			   AND vincoverlimit
			THEN
				dialog.setitemattributies(pdialog, 'IncMax', dialog.selecton);
			ELSE
				dialog.setitemattributies(pdialog, 'IncMax', dialog.selectoff);
				dialog.putbool(pdialog, 'IncMax', FALSE);
			END IF;
		
			IF vincoverlimit
			THEN
				dialog.setitemattributies(pdialog, 'OverLimitCalcType', dialog.selecton);
			ELSE
				dialog.setitemattributies(pdialog, 'OverLimitCalcType', dialog.selectoff);
			END IF;
			s.say(cmethodname || '       -->>  END', 1);
		
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.MPProfileSetupDialogProc.EnableControl');
				RAISE;
		END;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		s.say('pWhat=' || pwhat || ' pItemName=' || pitemname || ' pCmd=' || pcmd, 1);
		IF pwhat = dialog.wtdialogpre
		THEN
		
			dialog.setenable(pdialog, 'Ok', NOT dialog.getbool(pdialog, c_readonlyflag));
		
			SELECT profilename
			INTO   vretc
			FROM   tcontractmpprofile
			WHERE  branch = cbranch
			AND    profileid = smpprofileid;
			dialog.putchar(pdialog, 'ProfileName', vretc);
			contractparams.loaddialogfieldnumber(pdialog
												,'MinPayBase'
												,cmpobjecttype
												,smpprofileid
												,NULL
												,2);
			contractparams.loaddialogfieldnumber(pdialog
												,'MinPayType'
												,cmpobjecttype
												,smpprofileid
												,NULL
												,2);
			contractparams.loaddialognumber(pdialog, 'MinPayAmount', cmpobjecttype, smpprofileid);
			contractparams.loaddialognumber(pdialog, 'MinPayPrc', cmpobjecttype, smpprofileid);
			contractparams.loaddialogbool(pdialog, 'MinPayPrcCL', cmpobjecttype, smpprofileid);
			contractparams.loaddialogbool(pdialog, 'IncUnpaidMP', cmpobjecttype, smpprofileid);
			contractparams.loaddialogbool(pdialog, 'IncOverLimit', cmpobjecttype, smpprofileid);
			contractparams.loaddialogbool(pdialog, 'AddUnpaidMP', cmpobjecttype, smpprofileid);
			contractparams.loaddialogbool(pdialog, 'AddOverLimit', cmpobjecttype, smpprofileid);
			contractparams.loaddialogbool(pdialog, 'IncMax', cmpobjecttype, smpprofileid);
		
			contractparams.loaddialogfieldnumber(pdialog
												,'OverLimitCalcType'
												,cmpobjecttype
												,smpprofileid
												,NULL
												,chowovlcalc_total);
			contractparams.loaddialognumber(pdialog
										   ,'CalcMPNotLess'
										   ,cmpobjecttype
										   ,smpprofileid
										   ,0);
			contractparams.loaddialognumber(pdialog
										   ,'CalcMPBalanceLess'
										   ,cmpobjecttype
										   ,smpprofileid
										   ,0);
		
			enablecontrol;
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF pitemname IN ('INCUNPAIDMP', 'INCOVERLIMIT', 'MINPAYPRCCL')
			THEN
				enablecontrol;
			ELSIF pitemname = 'GRPSETUP'
			THEN
				dialog.exec(mpprofilegroupdialog(dialog.getbool(pdialog, c_readonlyflag)));
			END IF;
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			IF pcmd = dialog.cmconfirm
			THEN
				enablecontrol;
				dialog.goitem(pdialog, pitemname);
			ELSIF pcmd = dialog.cmok
			THEN
				BEGIN
					vret := contractparams.savedialogfieldnumber(pdialog
																,'MinPayBase'
																,cmpobjecttype
																,smpprofileid
																,pwhitelog     => TRUE
																,pparamname    => 'Base amount for Minimum Payment calculation');
					contractparams.savedialogfieldnumber(pdialog
														,'MinPayType'
														,cmpobjecttype
														,smpprofileid
														,pwhitelog     => TRUE
														,pparamname    => 'Minimum Payment calculation type');
					contractparams.savedialognumber(pdialog
												   ,'MinPayAmount'
												   ,cmpobjecttype
												   ,smpprofileid
												   ,pwhitelog     => TRUE
												   ,pparamname    => 'Minimum Payment flat amount');
					IF vret <= 2
					THEN
						contractparams.savedialognumber(pdialog
													   ,'MinPayPrc'
													   ,cmpobjecttype
													   ,smpprofileid
													   ,pwhitelog     => TRUE
													   ,pparamname    => 'Minimum Payment percentage value');
						contractparams.deletevalue(cmpobjecttype, smpprofileid, 'MinPayPrcCL');
					ELSE
						IF contractparams.savedialogbool(pdialog
														,'MinPayPrcCL'
														,cmpobjecttype
														,smpprofileid
														,pwhitelog     => TRUE
														,pparamname    => 'Use percent of Credit Limit')
						THEN
							contractparams.savedialognumber(pdialog
														   ,'MinPayPrc'
														   ,cmpobjecttype
														   ,smpprofileid
														   ,pwhitelog     => TRUE
														   ,pparamname    => 'Minimum Payment percentage value');
						ELSE
							contractparams.deletevalue(cmpobjecttype, smpprofileid, 'MinPayPrc');
						END IF;
					END IF;
					contractparams.savedialogbool(pdialog
												 ,'IncUnpaidMP'
												 ,cmpobjecttype
												 ,smpprofileid
												 ,pwhitelog     => TRUE
												 ,pparamname    => 'Include overdue amount to MP amount');
					contractparams.savedialogbool(pdialog
												 ,'IncOverLimit'
												 ,cmpobjecttype
												 ,smpprofileid
												 ,pwhitelog     => TRUE
												 ,pparamname    => 'Include over-limit amount to MP amount');
					contractparams.savedialogbool(pdialog
												 ,'AddUnpaidMP'
												 ,cmpobjecttype
												 ,smpprofileid
												 ,pwhitelog     => TRUE
												 ,pparamname    => 'Include Unpaid Min Payment Amount to Base Calculation Amount');
					contractparams.savedialogbool(pdialog
												 ,'AddOverLimit'
												 ,cmpobjecttype
												 ,smpprofileid
												 ,pwhitelog     => TRUE
												 ,pparamname    => 'Include Over-limit Amount to Base Calculation Amount');
					contractparams.savedialogbool(pdialog
												 ,'IncMax'
												 ,cmpobjecttype
												 ,smpprofileid
												 ,pwhitelog     => TRUE
												 ,pparamname    => 'Use maximum between Overdue amount and Over-limit amount');
				
					contractparams.savedialogfieldnumber(pdialog
														,'OverLimitCalcType'
														,cmpobjecttype
														,smpprofileid
														,pwhitelog          => TRUE
														,pparamname         => 'How overlimit should be calculated');
					IF NOT dialog.getbool(pdialog, 'IncOverLimit')
					THEN
						contractparams.deletevalue(cmpobjecttype
												  ,smpprofileid
												  ,'OverLimitCalcType');
					END IF;
					contractparams.savedialognumber(pdialog
												   ,'CalcMPNotLess'
												   ,cmpobjecttype
												   ,smpprofileid
												   ,pwhitelog      => TRUE
												   ,pparamname     => 'Calculated MP amount should not be less than');
					contractparams.savedialognumber(pdialog
												   ,'CalcMPBalanceLess'
												   ,cmpobjecttype
												   ,smpprofileid
												   ,pwhitelog          => TRUE
												   ,pparamname         => 'MP should not be calculated if balance less');
				
					vretc := ltrim(rtrim(dialog.getchar(pdialog, 'ProfileName')));
					IF vretc IS NULL
					THEN
						dialog.goitem(pdialog, 'ProfileName');
						RAISE contractparams.incorrectvalue;
					END IF;
				
					UPDATE tcontractmpprofile
					SET    profilename = vretc
					WHERE  branch = cbranch
					AND    profileid = smpprofileid;
				
				EXCEPTION
					WHEN contractparams.valuenotexists
						 OR contractparams.incorrectvalue THEN
						dialog.sethothint(pdialog, 'Incorrect value');
						RETURN;
					WHEN OTHERS THEN
						err.seterror(SQLCODE, cpackagename || '.MPProfileSetupDialogProc');
						service.sayerr(pdialog, 'Error');
						dialog.goitem(pdialog, 'Cancel');
						RETURN;
				END;
			END IF;
		END IF;
		s.say(cmethodname || '       -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.MPProfileSetupDialogProc');
			RAISE;
	END;

	FUNCTION mpprofilegroupdialog(preadonly IN BOOLEAN := FALSE) RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.MPProfileGroupDialog';
		vdialog NUMBER;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		vdialog := dialog.new('Minimum Payment setup', 0, 0, 74, 17, pextid => cmethodname);
		dialog.hiddenbool(vdialog, c_readonlyflag, preadonly);
		dialog.setdialogpre(vdialog, cpackagename || '.MPProfileGroupDialogProc');
		dialog.setdialogpost(vdialog, cpackagename || '.MPProfileGroupDialogProc');
	
		dialog.bevel(vdialog, 1, 1, 73, 15, dialog.bevel_frame, pcaption => 'Operations groups');
		dialog.list(vdialog, 'GroupsList', 3, 3, 67, 11, 'Operations groups');
		dialog.listaddfield(vdialog, 'GroupsList', 'Id', 'C', 4, 1);
		dialog.listaddfield(vdialog, 'GroupsList', 'Name', 'C', 50, 1);
		dialog.listaddfield(vdialog, 'GroupsList', 'CurT', 'C', 1, 1);
		dialog.listaddfield(vdialog, 'GroupsList', 'Prc', 'C', 10, 1, 'R');
		dialog.setcaption(vdialog, 'GroupsList', 'Code~Name~Current cycle transactions only~Value');
		dialog.setitempost(vdialog, 'GroupsList', cpackagename || '.MPProfileGroupDialogProc');
		s.say(cmethodname || '      -->>  END', 1);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.MPProfileGroupDialog');
			RAISE;
	END;

	PROCEDURE mpprofilegroupdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname   CONSTANT VARCHAR2(100) := cpackagename || '.MPProfileGroupDialogProc';
		cbranch       CONSTANT NUMBER := seance.getbranch;
		cmpobjecttype CONSTANT NUMBER := getmpobjecttype;
	
		CURSOR c1 IS
			SELECT *
			FROM   tcontractentrygroup
			WHERE  branch = cbranch
			ORDER  BY branch
					 ,groupid;
	
		vret VARCHAR(4);
	
		PROCEDURE fillgrouplist IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.MPProfileGroupDialogProc.FillGroupList';
			vprc  NUMBER;
			vsign VARCHAR(1);
		BEGIN
			s.say(cmethodname || '      --<< BEGIN', 1);
			dialog.listclear(pdialog, 'GroupsList');
			vprc := nvl(contractparams.loadnumber(cmpobjecttype
												 ,smpprofileid
												 ,'MP_Percent_CL'
												 ,FALSE)
					   ,0);
			dialog.listaddrecord(pdialog
								,'GroupsList'
								,'CL~Credit limit~~' || to_char(vprc, '990.00') || '~');
			FOR i IN c1
			LOOP
				vprc  := nvl(contractparams.loadnumber(cmpobjecttype
													  ,smpprofileid
													  ,'MP_Percent_' || i.groupid
													  ,FALSE)
							,0);
				vsign := service.iif(nvl(contractparams.loadnumber(cmpobjecttype
																  ,smpprofileid
																  ,'MP_Current_' || i.groupid
																  ,FALSE)
										,0) = 0
									,' '
									,'+');
				dialog.listaddrecord(pdialog
									,'GroupsList'
									,i.groupid || '~' || i.groupname || '~' || vsign || '~' ||
									 to_char(vprc, '990.00') || '~');
			END LOOP;
			s.say(cmethodname || '      -->>  END', 1);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.MPProfileGroupDialogProc.FillGroupList');
				RAISE;
		END;
	
		PROCEDURE savevalues IS
			PRAGMA AUTONOMOUS_TRANSACTION;
			cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.SaveValues';
		BEGIN
			t.var('vRet', vret);
			contractparams.savenumber(cmpobjecttype
									 ,smpprofileid
									 ,'MP_Percent_' || vret
									 ,sprcvalue
									 ,TRUE
									 ,'Minimum Payment percentage value for group ' || vret);
			IF vret <> 'CL'
			THEN
				contractparams.savebool(cmpobjecttype
									   ,smpprofileid
									   ,'MP_Current_' || vret
									   ,scurvalue
									   ,TRUE
									   ,'Current cycle transactions only' || vret);
			END IF;
			COMMIT;
		EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK;
				error.save(cmethodname);
				RAISE;
		END savevalues;
	
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		IF pwhat = dialog.wtdialogpre
		THEN
			fillgrouplist;
		ELSIF pwhat = dialog.wtitempost
		THEN
		
			vret := dialog.getcurrentrecordchar(pdialog, pitemname, 'Id');
			IF dialog.exec(prcdialog(vret, dialog.getbool(pdialog, c_readonlyflag))) = dialog.cmok
			THEN
			
				savevalues;
				fillgrouplist;
				dialog.setcurrecbyvalue(pdialog, 'GroupsList', 'Id', vret);
			
			END IF;
		END IF;
		s.say(cmethodname || '      -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.showerror('Error');
			dialog.goitem(pdialog, 'Exit');
	END;

	FUNCTION prcdialog
	(
		pvalue    IN VARCHAR
	   ,preadonly IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethodname   CONSTANT VARCHAR2(100) := cpackagename || '.PrcDialog';
		cmpobjecttype CONSTANT NUMBER := getmpobjecttype;
		vdialog NUMBER;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		vdialog := dialog.new('Minimum Payment value for group ' || pvalue
							 ,0
							 ,0
							 ,40
							 ,10
							 ,pextid => cmethodname);
		dialog.bevel(vdialog, 1, 1, 39, 3, dialog.bevel_frame);
		dialog.inputmoney(vdialog
						 ,'Amount'
						 ,20
						 ,2
						 ,'Percentage value of group debt included to MP'
						 ,'Value:');
		dialog.putnumber(vdialog
						,'Amount'
						,nvl(contractparams.loadnumber(cmpobjecttype
													  ,smpprofileid
													  ,'MP_Percent_' || pvalue
													  ,FALSE)
							,0));
		dialog.inputcheck(vdialog
						 ,'Current'
						 ,3
						 ,3
						 ,35
						 ,'Use outstanding of current cycle transaction for MP calculation'
						 ,pcaption => 'Current cycle transactions only');
		dialog.putbool(vdialog
					  ,'Current'
					  ,nvl(contractparams.loadbool(cmpobjecttype
												  ,smpprofileid
												  ,'MP_Current_' || pvalue
												  ,FALSE)
						  ,FALSE));
		dialog.hiddenbool(vdialog, c_readonlyflag, preadonly);
		IF pvalue = 'CL'
		THEN
			dialog.setitemattributies(vdialog, 'Current', dialog.echooff);
		END IF;
		dialog.button(vdialog
					 ,'Ok'
					 ,8
					 ,5
					 ,12
					 ,'OK'
					 ,dialog.cmok
					 ,0
					 ,'Save changes and exit dialog');
	
		dialog.setenable(vdialog, 'Ok', NOT dialog.getbool(vdialog, c_readonlyflag));
	
		dialog.button(vdialog
					 ,'Cancel'
					 ,22
					 ,5
					 ,12
					 ,'Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel changes and exit dialog');
		dialog.setdialogvalid(vdialog, cpackagename || '.PrcDialogProc');
		s.say(cmethodname || '      -->>  END', 1);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.PrcDialog');
			RAISE;
	END;

	PROCEDURE prcdialogproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.PrcDialogProc';
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		IF pwhat = dialog.wtdialogvalid
		THEN
			sprcvalue := nvl(dialog.getnumber(pdialog, 'Amount'), -1);
			IF sprcvalue < 0
			   OR sprcvalue > 100
			THEN
				dialog.sethothint(pdialog, 'Incorrect value');
				dialog.goitem(pdialog, 'Amount');
			END IF;
			scurvalue := dialog.getbool(pdialog, 'Current');
		END IF;
		s.say(cmethodname || '      -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.PrcDialogProc');
			RAISE;
	END;

	PROCEDURE checkcache(pidx IN NUMBER) IS
		cmethodname CONSTANT VARCHAR2(80) := cpackagename || '.CheckCache';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		vmax NUMBER;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		s.say(cmethodname || ': start', 1);
		IF NOT vapg_ident.exists(pidx)
		THEN
			SELECT MAX(groupid) INTO vmax FROM tcontractentrygroup WHERE branch = cbranch;
			FOR g IN 0 .. vmax
			LOOP
				vapg_ident(g) := tblschitem(recschitem(1, '1', '1', '1', '1', '1', '1', '1', '1'));
				vagrates_ident(g) := tblschitem(recschitem(1
														  ,'1'
														  ,'1'
														  ,'1'
														  ,'1'
														  ,'1'
														  ,'1'
														  ,'1'
														  ,'1'));
				FOR i IN 1 .. capg_ident.count
				LOOP
					IF NOT vapg_ident(g).exists(i)
					THEN
						vapg_ident(g).extend(1);
					END IF;
					vapg_ident(g)(i) := recschitem(capg_ident(i).idx
												  ,upper(g || '_' || capg_ident(i).name)
												  ,capg_ident(i).spec
												  ,capg_ident(i).descr
												  ,capg_ident(i).attr1
												  ,capg_ident(i).attr2
												  ,capg_ident(i).attr3
												  ,capg_ident(i).attr4
												  ,capg_ident(i).attr5);
				END LOOP;
				FOR i IN 1 .. cagrates_ident.count
				LOOP
					IF NOT vagrates_ident(g).exists(i)
					THEN
						vagrates_ident(g).extend(1);
					END IF;
					vagrates_ident(g)(i) := recschitem(cagrates_ident(i).idx
													  ,g || cagrates_ident(i).name
													  ,cagrates_ident(i).spec
													  ,cagrates_ident(i).descr
													  ,cagrates_ident(i).attr1
													  ,cagrates_ident(i).attr2
													  ,cagrates_ident(i).attr3
													  ,cagrates_ident(i).attr4
													  ,cagrates_ident(i).attr5);
				END LOOP;
			END LOOP;
		END IF;
		s.say(cmethodname || '      -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE getprofile
	(
		pprofileid     IN NUMBER
	   ,pprofilearr    IN OUT NOCOPY types.arrstr1000
	   ,pgroupsettings IN OUT NOCOPY typeprofilparamarray
	   ,prates         IN OUT NOCOPY contracttools.trate
	   ,predsettings   IN OUT NOCOPY typereducedratesgrarr
	) IS
		cmethodname CONSTANT VARCHAR2(80) := cpackagename || '.GetProfile';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		cobjecttype CONSTANT NUMBER := getobjecttype;
	
		CURSOR c1 IS(
			SELECT a.groupid
			FROM   tcontractprofilegroup a
			WHERE  a.branch = cbranch
			AND    a.profileid = pprofileid)
			ORDER  BY a.branch
					 ,a.profileid
					 ,a.priority;
	
		PROCEDURE loadredrates
		(
			pgroupid  IN NUMBER
		   ,osettings IN OUT NOCOPY typereducedratesarr
		) IS
		BEGIN
			s.say(cmethodname || '      --<< BEGIN', 1);
			SELECT terms
				  ,amount
				  ,rateid
				  ,reducedtermusage BULK COLLECT
			INTO   osettings
			FROM   tcontractredintsettings
			WHERE  branch = cbranch
			AND    profileid = pprofileid
			AND    groupid = pgroupid
			ORDER  BY priority;
			s.say(cmethodname || '      -->>  END', 1);
		EXCEPTION
			WHEN no_data_found THEN
				osettings(1).terms := cgrace_notused;
				s.say('!!!!!!!!! NO_DATA_FOUND !!!!!', 1);
			WHEN OTHERS THEN
				error.save(cmethodname || '.LoadRedRates');
				RAISE;
		END;
	
	BEGIN
		t.enter(cmethodname, pprofileid);
	
		loadparam(cobjecttype, pprofileid, cap_ident, pprofilearr, '', FALSE);
	
		prates := loadrate(9, pprofileid, carates_ident, sadummyrateid, TRUE, '');
	
		pprofilearr(cp_intbyremainrate) := sadummyrateid(cr_intbyremainrate);
	
		FOR i IN c1
		LOOP
			pgroupsettings(i.groupid)(0) := NULL;
			checkcache(i.groupid);
			loadparam(cobjecttype
					 ,pprofileid
					 ,vapg_ident(i.groupid)
					 ,pgroupsettings(i.groupid)
					 ,i.groupid || '_'
					 ,FALSE);
			predsettings(i.groupid)(1).terms := cgrace_notused;
			loadredrates(i.groupid, predsettings(i.groupid));
			IF NOT predsettings.exists(i.groupid)
			THEN
				predsettings(i.groupid)(1).terms := cgrace_notused;
			END IF;
			sapgrouprateid(pprofileid)(i.groupid)(0) := NULL;
			sapgrouprates(pprofileid)(i.groupid) := loadrate(9
															,pprofileid
															,vagrates_ident(i.groupid)
															,sapgrouprateid(pprofileid) (i.groupid)
															,FALSE
															,i.groupid);
			pgroupsettings(i.groupid)(cpg_crdprchist) := sapgrouprateid(pprofileid) (i.groupid)
														 (crg_crdprchist);
			pgroupsettings(i.groupid)(cpg_proprchist) := sapgrouprateid(pprofileid) (i.groupid)
														 (crg_proprchist);
			pgroupsettings(i.groupid)(cpg_preprchist) := sapgrouprateid(pprofileid) (i.groupid)
														 (crg_preprchist);
		END LOOP;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE getmpprofile
	(
		pprofileid  IN NUMBER
	   ,pprofilearr IN OUT NOCOPY types.arrstr1000
	) IS
		cmethodname CONSTANT VARCHAR2(80) := cpackagename || '.GetMPProfile';
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		loadparam(getmpobjecttype, pprofileid, campp_ident, pprofilearr, '', FALSE);
		pprofilearr(cp_mpp_profileid) := pprofileid;
		FOR j IN 1 .. pprofilearr.count
		LOOP
			s.say(cmethodname || '   -->>>>>  pProfileArr (' || j || ') = ' || pprofilearr(j), 1);
		END LOOP;
		s.say(cmethodname || '      -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE loadparam
	(
		pobjecttype  NUMBER
	   ,pobjectid    NUMBER
	   ,paitem       tblschitem
	   ,oaret        IN OUT NOCOPY types.arrstr1000
	   ,pprefix      VARCHAR := ''
	   ,pdoexception BOOLEAN := TRUE
	) IS
		cmethodname CONSTANT VARCHAR2(80) := cpackagename || '.LoadParam[other]';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		verrmsg VARCHAR2(4000) := NULL;
		i       PLS_INTEGER;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		s.say(cmethodname || ': for object ' || pobjecttype || ' - ' || pobjectid, 1);
	
		SELECT /*+ CARDINALITY(D 30) ORDERED USE_NL(d p) INDEX (p pk_COtherParameters) */
		 nvl(p.value, d.attr2) BULK COLLECT
		INTO   oaret
		FROM   TABLE(paitem) d
		LEFT   OUTER JOIN tcontractotherparameters p
		ON     p.branch = cbranch
		AND    p.objecttype = pobjecttype
		AND    p.objectno = to_char(pobjectid)
		AND    p.key = upper(d.name)
		ORDER  BY d.idx;
	
		IF pdoexception
		THEN
			FOR i IN 1 .. paitem.count
			LOOP
				s.say(cmethodname || ': ' || paitem(i).name || ' ' || oaret(i), 1);
				IF (paitem(i).attr1 = contracttools.cmandatory)
				   AND (oaret(i) IS NULL)
				THEN
					verrmsg := verrmsg || ', ' || paitem(i).spec;
					s.say('Error' || ': ' || paitem(i).name || ' ' || oaret(i));
				END IF;
			END LOOP;
			IF verrmsg IS NOT NULL
			THEN
				error.raiseuser('The following parameters are not defined:' || substr(verrmsg, 2));
			END IF;
		END IF;
		s.say(cmethodname || '      -->>  END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END loadparam;

	FUNCTION loadrate
	(
		pobjecttype  NUMBER
	   ,pobjectid    NUMBER
	   ,paitem       tblschitem
	   ,paid         IN OUT NOCOPY types.arrnum
	   ,preadhistory BOOLEAN := TRUE
	   ,pprefix      VARCHAR := ''
	   ,pdoexception BOOLEAN := TRUE
	) RETURN contracttools.trate IS
		cmethodname CONSTANT VARCHAR2(80) := cpackagename || '.LoadRate[Cat]';
		vbranch NUMBER := seance.getbranch();
		vaid    types.arrnum;
		vaempty referenceprchistory.typeprcarray;
		varet   contracttools.trate;
	BEGIN
		s.say(cmethodname || '     --<< BEGIN', 1);
		s.say(cmethodname || ': pObjectType=' || pobjecttype || ', pObjectID=' || pobjectid, 1);
		SELECT /*+ ORDERED USE_NL (p) INDEX (p pk_PercentBelong_Object) */
		 p.id BULK COLLECT
		INTO   vaid
		FROM   TABLE(paitem) d
		LEFT   OUTER JOIN tpercentbelong p
		ON     p.branch = vbranch
		AND    p.category = pobjecttype
		AND    p.objectno = to_char(pobjectid)
		AND    p.objectcat = d.name
		ORDER  BY d.idx;
		IF preadhistory
		THEN
			FOR i IN 1 .. vaid.count
			LOOP
				s.say(cmethodname || '     Rate ID for arrayID [' || i || '] = ' || vaid(i), 1);
				IF vaid(i) IS NOT NULL
				THEN
					varet(i) := referenceprchistory.getprcdata(vaid(i));
				ELSE
					IF pdoexception
					   AND (paitem(i).attr1 IN (contracttools.cmandatory))
					THEN
						error.raiseuser('Interest rate <' || paitem(i).spec || '> is not defined');
					ELSE
						varet(i) := vaempty;
					END IF;
				END IF;
			END LOOP;
		END IF;
		paid := vaid;
		FOR jj IN 1 .. paid.count
		LOOP
			s.say(cmethodname || '     Rate ID for paID [' || jj || '] = ' || paid(jj), 1);
		END LOOP;
		s.say(cmethodname || '      -->>  END', 1);
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END loadrate;

	FUNCTION getobjecttype RETURN NUMBER IS
		cmethodname CONSTANT typemethodname := cpackagename || '.GetObjectType';
	BEGIN
		RETURN contractparams.getobjecttype('CONTRACT_PROFILE');
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getobjecttype;

	FUNCTION getmpobjecttype RETURN NUMBER IS
		cmethodname CONSTANT typemethodname := cpackagename || '.GetMPObjectType';
	BEGIN
		RETURN contractparams.getobjecttype('CONTRACT_MP_PROFILE');
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END getmpobjecttype;

	FUNCTION getbodyversion RETURN VARCHAR2 IS
	BEGIN
		RETURN cbodyversion;
	END getbodyversion;

	PROCEDURE logmonthlyfeechanges
	(
		poldrow     IN typemonthlyfeerow
	   ,pnewrow     IN typemonthlyfeerow
	   ,poldentries IN VARCHAR2
	   ,pnewentries IN VARCHAR2
	   ,paction     IN NUMBER
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.LogMonthlyFeeChanges';
		vcomment   VARCHAR2(200);
		vprofileid NUMBER;
	BEGIN
		t.enter(cmethodname, paction);
	
		a4mlog.cleanparamlist;
		a4mlog.addparamrec('Profile ID', poldrow.profileid, pnewrow.profileid);
		a4mlog.addparamrec('Profile name', poldrow.name, pnewrow.name);
		a4mlog.addparamrec('Charge condition', poldrow.chargecondition, pnewrow.chargecondition);
		a4mlog.addparamrec('Tariff ID', poldrow.tariffid, pnewrow.tariffid);
		a4mlog.addparamrec('Profile name', poldrow.name, pnewrow.name);
		a4mlog.addparamrec('Profile entries', poldentries, pnewentries);
	
		IF a4mlog.getparamlistcount > 0
		THEN
		
			CASE paction
				WHEN a4mlog.act_add THEN
					vprofileid := pnewrow.profileid;
					vcomment   := 'Monthly fee profile (ID = <' || vprofileid || '>, Name = <' ||
								  pnewrow.name || '>) added';
				WHEN a4mlog.act_change THEN
					vprofileid := poldrow.profileid;
					vcomment   := 'Monthly fee profile (ID = <' || vprofileid || '>, Name = <' ||
								  poldrow.name || '>) changed';
				WHEN a4mlog.act_del THEN
					vprofileid := poldrow.profileid;
					vcomment   := 'Monthly fee profile (ID = <' || vprofileid || '>, Name = <' ||
								  poldrow.name || '>) deleted';
				ELSE
					error.raiseerror('Logging of action <' || paction || '> is not supported!');
			END CASE;
		
			a4mlog.logobject(object.gettype(contracttype.object_name)
							,'MonthlyFeeProfile=' || vprofileid
							,vcomment
							,paction
							,a4mlog.putparamlist);
		
		END IF;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END logmonthlyfeechanges;

	PROCEDURE insertmonthlyfee
	(
		ponewrow IN OUT NOCOPY typemonthlyfeerow
	   ,plog     BOOLEAN := TRUE
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.DML_MonthlyFee_AddProfile';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	BEGIN
		t.enter(cmethodname);
		SAVEPOINT sp_insertmonthlyfee;
	
		INSERT INTO treferencemonthlyfee
			(branch
			,NAME
			,chargecondition
			,tariffid
			,waivercondition)
		VALUES
			(cbranch
			,ponewrow.name
			,ponewrow.chargecondition
			,ponewrow.tariffid
			,ponewrow.waivercondition)
		RETURNING profileid INTO ponewrow.profileid;
		t.var('poNewRow.ProfileID', ponewrow.profileid);
	
		IF plog
		THEN
			logmonthlyfeechanges(cemptymonthlyfeerow, ponewrow, NULL, NULL, a4mlog.act_add);
		END IF;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK TO sp_insertmonthlyfee;
		
			ponewrow.profileid := NULL;
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE dml_monthlyfee_addprofile
	(
		ponewrow      IN OUT NOCOPY typemonthlyfeerow
	   ,paentrieslist IN tblnumber
	) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT typemethodname := cpackagename || '.DML_MonthlyFee_AddProfile';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	BEGIN
		t.enter(cmethodname);
	
		insertmonthlyfee(ponewrow, plog => FALSE);
	
		FORALL i IN 1 .. paentrieslist.count
			INSERT INTO treferencemonthlyfeeentries
			VALUES
				(cbranch
				,ponewrow.profileid
				,paentrieslist(i));
	
		logmonthlyfeechanges(cemptymonthlyfeerow
							,ponewrow
							,NULL
							,serialize(paentrieslist)
							,a4mlog.act_add);
	
		COMMIT;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
		
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dml_monthlyfee_addprofile;

	PROCEDURE updatemonthlyfee
	(
		pnewrow       IN typemonthlyfeerow
	   ,poldrow       IN typemonthlyfeerow := cemptymonthlyfeerow
	   ,pclearentries BOOLEAN := FALSE
	   ,plog          BOOLEAN := TRUE
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.DML_MonthlyFee_UpdateProfile';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		voldrow typemonthlyfeerow := poldrow;
	
	BEGIN
		t.enter(cmethodname);
		SAVEPOINT sp_updatemonthlyfee;
	
		IF pnewrow.branch <> cbranch
		THEN
			error.raiseerror('Internal Error! Incorrect call for update monthly fee profile');
		END IF;
	
		IF voldrow.profileid IS NULL
		THEN
			voldrow := getmonthlyfeeprofile(pnewrow.profileid);
		END IF;
	
		UPDATE treferencemonthlyfee
		SET    ROW = pnewrow
		WHERE  branch = cbranch
		AND    profileid = pnewrow.profileid;
	
		IF pclearentries
		THEN
			DELETE FROM treferencemonthlyfeeentries
			WHERE  branch = cbranch
			AND    profileid = pnewrow.profileid;
		END IF;
	
		IF plog
		THEN
			logmonthlyfeechanges(voldrow, pnewrow, NULL, NULL, a4mlog.act_change);
		END IF;
	
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK TO sp_updatemonthlyfee;
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE dml_monthlyfee_updateprofile
	(
		pnewrow       IN typemonthlyfeerow
	   ,paentrieslist IN tblnumber
	) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT typemethodname := cpackagename || '.DML_MonthlyFee_UpdateProfile';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		vaoldentrieslist tblnumber;
		voldrow          typemonthlyfeerow;
	BEGIN
	
		voldrow          := getmonthlyfeeprofile(pnewrow.profileid);
		vaoldentrieslist := getmonthlyfeeprofileentries(pnewrow.profileid);
	
		updatemonthlyfee(pnewrow, voldrow, pclearentries => FALSE, plog => FALSE);
	
		DELETE FROM treferencemonthlyfeeentries
		WHERE  branch = cbranch
		AND    profileid = pnewrow.profileid
		AND    entrycode NOT MEMBER OF paentrieslist;
	
		FORALL i IN 1 .. paentrieslist.count MERGE INTO treferencemonthlyfeeentries USING dual
						 ON((branch = cbranch) AND (profileid = pnewrow.profileid) AND
							(entrycode = paentrieslist(i)))
			WHEN NOT MATCHED THEN INSERT VALUES(cbranch, pnewrow.profileid, paentrieslist(i));
	
		logmonthlyfeechanges(voldrow
							,pnewrow
							,serialize(vaoldentrieslist)
							,serialize(paentrieslist)
							,a4mlog.act_change);
	
		COMMIT;
	
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dml_monthlyfee_updateprofile;

	PROCEDURE dml_monthlyfee_deleterecord(prow IN typemonthlyfeerow) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT typemethodname := cpackagename || '.DML_MonthlyFee_DeleteRecord';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		vaoldentrieslist tblnumber;
	BEGIN
	
		vaoldentrieslist := getmonthlyfeeprofileentries(prow.profileid);
	
		DELETE FROM treferencemonthlyfee
		WHERE  branch = cbranch
		AND    profileid = prow.profileid;
	
		custom_contractexchangetools.deletematchingrows(cpackagename
													   ,creftable_monthlyfees
													   ,'ProfileId'
													   ,pdestcode => to_char(prow.profileid));
	
		logmonthlyfeechanges(prow
							,cemptymonthlyfeerow
							,serialize(vaoldentrieslist)
							,NULL
							,a4mlog.act_del);
	
		COMMIT;
	
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dml_monthlyfee_deleterecord;

	FUNCTION isreadonly(pdialog IN NUMBER) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackagename || '.IsReadOnly';
	BEGIN
		RETURN dlg_tools.getboolfrommaindialog(pdialog, creadonly);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END isreadonly;

	FUNCTION dlg_monthlyfee_create
	(
		ptitle         IN VARCHAR2
	   ,pmonthlyfeerow IN typemonthlyfeerow
	) RETURN NUMBER IS
		cmethodname  CONSTANT typemethodname := cpackagename || '.Dlg_MonthlyFee_Create';
		chandlername CONSTANT typemethodname := cpackagename || '.Dlg_MonthlyFee_Handler';
	
		c_dialogwidth  CONSTANT NUMBER := 90;
		c_dialogheight CONSTANT NUMBER := 22;
	
		vsubmenu NUMBER;
		vdialog  NUMBER;
		vmenu    NUMBER;
	
	BEGIN
		t.enter(cmethodname);
	
		vdialog := dialog.new(ptitle, 0, 0, c_dialogwidth, c_dialogheight, pextid => cmethodname);
	
		dialog.hiddennumber(vdialog, citem_profileid, pmonthlyfeerow.profileid);
	
		vmenu    := dialog.menu(vdialog);
		vsubmenu := dialog.submenu(vmenu, 'Dictionaries', 'Dictionaries');
		contractcommission.addmenu_refview(vdialog, vsubmenu, preadonly => isreadonly(vdialog));
	
		dialog.bevel(vdialog
					,1
					,1
					,c_dialogwidth - 1
					,2
					,dialog.bevel_frame
					,pcaption => 'Profile name');
		dialog.inputchar(vdialog, 'ProfileName', 23, 2, 64, 'Profile name', 50, 'Profile name:');
		dialog.putchar(vdialog, 'ProfileName', pmonthlyfeerow.name);
	
		dialog.bevel(vdialog
					,1
					,3
					,c_dialogwidth - 1
					,4
					,dialog.bevel_frame
					,pcaption => 'Charge parameters');
		dlg_tools.makedroplist(vdialog
							  ,'ChargeCond'
							  ,23
							  ,4
							  ,62
							  ,62
							  ,'Charge condition:'
							  ,'Charge condition');
		dialog.listaddrecord(vdialog
							,'ChargeCond'
							,cbalanceonsd ||
							 '~Outstanding balance on SD or posted transactions within cycle');
		dialog.listaddrecord(vdialog
							,'ChargeCond'
							,cunpaidtrxns || '~Unpaid transactions within cycle');
		dialog.listaddrecord(vdialog, 'ChargeCond', cbalanceondd || '~Outstanding balance on DD');
		dialog.listaddrecord(vdialog
							,'ChargeCond'
							,cbalanceondd_oper || '~Outstanding balance on DD (by operations)');
		dlg_tools.setdroplistvalue(vdialog, 'ChargeCond', pmonthlyfeerow.chargecondition);
	
		contractcommission.dropbox_commission_create(vdialog
													,'TariffID'
													,23
													,5
													,62
													,'Tariff:'
													,'Tariff'
													,NULL
													,contractcommission.ctypeintervalsumm
													,pvalue => pmonthlyfeerow.tariffid);
	
		dlg_tools.makedroplist(vdialog
							  ,'WaiverCond'
							  ,23
							  ,6
							  ,62
							  ,62
							  ,'Waiver condition:'
							  ,'Waiver condition');
		dialog.listaddrecord(vdialog, 'WaiverCond', cwaivernone || '~Don''t waive');
		dialog.listaddrecord(vdialog
							,'WaiverCond'
							,cwaiversd || '~SD balance should be paid till Due date');
		dialog.listaddrecord(vdialog
							,'WaiverCond'
							,cwaiverfull || '~Full balance should be paid till Due date');
		dlg_tools.setdroplistvalue(vdialog, 'WaiverCond', pmonthlyfeerow.waivercondition);
	
		dialog.bevel(vdialog
					,1
					,7
					,c_dialogwidth - 1
					,12
					,dialog.bevel_frame
					,pcaption => 'Entries');
		objectentrycode.createlist2(vdialog
								   ,'EntryList'
								   ,4
								   ,8
								   ,69
								   ,11
								   ,'Entry list'
								   ,pbtnlayout  => objectentrycode.cright
								   ,preadonly   => isreadonly(vdialog));
		objectentrycode.fillentrylist(vdialog
									 ,'EntryList'
									 ,getmonthlyfeeprofileentries(pmonthlyfeerow.profileid));
	
		dlg_tools.startbuttondrawing(c_dialogwidth, 2);
		dlg_tools.drawbutton(vdialog
							,cbtn_ok
							,'OK'
							,'Save changes and exit dialog'
							,c_dialogheight - 2
							,dialog.cmok
							,isreadonly(vdialog)
							,TRUE);
		dlg_tools.drawbutton(vdialog
							,cbtn_cancel
							,'Cancel'
							,'Cancel changes and exit dialog'
							,c_dialogheight - 2
							,dialog.cmcancel
							,chandlername);
	
		dialog.setdialogvalid(vdialog, chandlername);
		dialog.setdialogpost(vdialog, chandlername);
	
		t.leave(cmethodname);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			dialog.destroy(vdialog);
			error.save(cmethodname);
			RAISE;
	END dlg_monthlyfee_create;

	FUNCTION dlg_monthlyfee_getdata
	(
		pdialog        IN NUMBER
	   ,omonthlyfeerow OUT NOCOPY typemonthlyfeerow
	   ,oaentrieslist  OUT NOCOPY tblnumber
	   ,pdoexception   IN BOOLEAN
	) RETURN BOOLEAN IS
		cmethodname CONSTANT typemethodname := cpackagename || '.Dlg_MonthlyFee_GetData';
	BEGIN
		t.enter(cmethodname);
	
		omonthlyfeerow.branch          := seance.getbranch;
		omonthlyfeerow.profileid       := dialog.getnumber(pdialog, citem_profileid);
		omonthlyfeerow.name            := dlg_tools.getchar(pdialog
														   ,'ProfileName'
														   ,'Profile name'
														   ,pdoexception => pdoexception);
		omonthlyfeerow.chargecondition := dlg_tools.getdroplistvalue(pdialog
																	,'ChargeCond'
																	,'Charge condition'
																	,pdoexception => pdoexception);
		omonthlyfeerow.tariffid        := contractcommission.dropbox_commission_getvalue(pdialog
																						,'TariffID'
																						,pdoexception);
		omonthlyfeerow.waivercondition := dlg_tools.getdroplistvalue(pdialog
																	,'WaiverCond'
																	,'Waiver condition'
																	,pdoexception => pdoexception);
	
		oaentrieslist := tblnumber();
		oaentrieslist.extend(dialog.getlistreccount(pdialog, 'EntryList'));
	
		FOR i IN 1 .. dialog.getlistreccount(pdialog, 'EntryList')
		LOOP
			oaentrieslist(i) := dialog.getrecordnumber(pdialog, 'EntryList', 'CODE', i);
		END LOOP;
	
		IF pdoexception
		   AND (omonthlyfeerow.chargecondition = cbalanceondd_oper)
		   AND (oaentrieslist.count = 0)
		THEN
			dlg_tools.raisevalidateerror(pdialog
										,'EntryList'
										,'At least one entry must be specified for the selected charge condition!');
		END IF;
	
		t.leave(cmethodname, htools.b2s(TRUE));
		RETURN TRUE;
	EXCEPTION
		WHEN dlg_tools.validate_error THEN
			t.exc(cmethodname);
			t.leave(cmethodname, htools.b2s(FALSE));
			RETURN FALSE;
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dlg_monthlyfee_getdata;

	PROCEDURE dlg_monthlyfee_handler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.Dlg_MonthlyFee_Handler';
		vmonthlyfeerow typemonthlyfeerow;
		ventrieslist   tblnumber;
	
		FUNCTION profilechanged(pdialog IN NUMBER) RETURN BOOLEAN IS
			cmethodname CONSTANT typemethodname := dlg_monthlyfee_handler.cmethodname ||
												   '.ProfileChanged';
		
			voriginalmonthlyfeerow typemonthlyfeerow;
			vaoriginalentrieslist  tblnumber := tblnumber();
			vcurrentmonthlyfeerow  typemonthlyfeerow;
			vacurrententrieslist   tblnumber := tblnumber();
			vresult                BOOLEAN := FALSE;
			vdummy                 BOOLEAN := FALSE;
		
		BEGIN
			t.enter(cmethodname);
		
			IF NOT isreadonly(pdialog)
			THEN
			
				vdummy := dlg_monthlyfee_getdata(pdialog
												,vcurrentmonthlyfeerow
												,vacurrententrieslist
												,c_noexception);
			
				IF vcurrentmonthlyfeerow.profileid IS NOT NULL
				THEN
					voriginalmonthlyfeerow := getmonthlyfeeprofile(vcurrentmonthlyfeerow.profileid);
					vaoriginalentrieslist  := getmonthlyfeeprofileentries(vcurrentmonthlyfeerow.profileid);
				END IF;
			
				vresult := contracttools.notequal(voriginalmonthlyfeerow.name
												 ,vcurrentmonthlyfeerow.name) OR
						   contracttools.notequal(voriginalmonthlyfeerow.chargecondition
												 ,vcurrentmonthlyfeerow.chargecondition) OR
						   contracttools.notequal(voriginalmonthlyfeerow.tariffid
												 ,vcurrentmonthlyfeerow.tariffid) OR
						   contracttools.notequal(voriginalmonthlyfeerow.waivercondition
												 ,vcurrentmonthlyfeerow.waivercondition) OR
						   contracttools.notequal(serialize(vaoriginalentrieslist)
												 ,serialize(vacurrententrieslist));
			
			END IF;
		
			t.leave(cmethodname, htools.b2s(vresult));
			RETURN vresult;
		EXCEPTION
			WHEN OTHERS THEN
				t.exc(cmethodname);
				error.save(cmethodname);
				RAISE;
		END profilechanged;
	
	BEGIN
		t.enter(cmethodname
			   ,'Dialog = ' || pdialog || ', What = ' || pwhat || ', ItemName = ' || pitemname ||
				', Cmd = ' || pcmd);
	
		CASE pwhat
		
			WHEN dialog.wt_itempre THEN
			
				IF (pitemname = cbtn_cancel)
				   AND profilechanged(pdialog)
				   AND (NOT
					htools.ask('Warning'
								   ,'All changes made will be lost!~Do you really want to close?'))
				THEN
					dialog.cancelclose(pdialog);
				END IF;
			
			WHEN dialog.wt_dialogvalid THEN
			
				IF (pcmd = dialog.cmok)
				   AND dlg_monthlyfee_getdata(pdialog, vmonthlyfeerow, ventrieslist, c_doexception)
				THEN
				
					BEGIN
					
						IF vmonthlyfeerow.profileid IS NULL
						THEN
						
							dml_monthlyfee_addprofile(vmonthlyfeerow, ventrieslist);
						
							dialog.putnumber(pdialog, citem_profileid, vmonthlyfeerow.profileid);
						
						ELSE
							dml_monthlyfee_updateprofile(vmonthlyfeerow, ventrieslist);
						END IF;
					
					EXCEPTION
						WHEN OTHERS THEN
							dialog.cancelclose(pdialog);
							htools.showmessage('Error', error.getusertext);
					END;
				
				END IF;
			
			WHEN dialog.wt_dialogpost THEN
			
				IF pcmd = dialog.cmok
				THEN
					dlg_monthlyfees_filllist(dialog.getowner(pdialog)
											,dialog.getnumber(pdialog, citem_profileid));
				END IF;
			
			ELSE
				NULL;
		END CASE;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dlg_monthlyfee_handler;

	FUNCTION dlg_monthlyfees_create(preadonly IN BOOLEAN := FALSE) RETURN NUMBER IS
		cmethodname  CONSTANT typemethodname := cpackagename || '.Dlg_MonthlyFees_Create';
		chandlername CONSTANT typemethodname := cpackagename || '.Dlg_MonthlyFees_Handler';
	
		c_dialogwidth  CONSTANT NUMBER := 80;
		c_dialogheight CONSTANT NUMBER := 17;
	
		vdialog  NUMBER;
		vmenu    NUMBER;
		vsubmenu NUMBER;
	
	BEGIN
		t.enter(cmethodname);
	
		vdialog := dialog.new(crefname_monthlyfees
							 ,0
							 ,0
							 ,c_dialogwidth
							 ,c_dialogheight
							 ,0
							 ,TRUE
							 ,cmethodname);
	
		dlg_tools.setbooltomaindialog(vdialog, creadonly, preadonly);
	
		vmenu    := mnu.new(vdialog);
		vsubmenu := mnu.submenu(vmenu, 'Operations', '');
		mnu.item(vsubmenu, 'miImport', 'Import', 0, 0, '');
		dialog.setitempre(vdialog, 'miImport', chandlername);
		mnu.item(vsubmenu, 'miExport', 'Export', 0, 0, '');
		dialog.setitempre(vdialog, 'miExport', chandlername);
	
		dialog.list(vdialog
				   ,clist_profiles
				   ,2
				   ,2
				   ,59
				   ,11
				   ,'Double-click on a profile to edit it'
				   ,FALSE
				   ,dialog.anchor_all);
		dialog.listaddfield(vdialog, clist_profiles, cfld_id, 'N', 6, 1);
		dialog.listaddfield(vdialog, clist_profiles, cfld_name, 'C', 50, 1);
	
		dialog.setcaption(vdialog, clist_profiles, 'ID~Profile name');
		dialog.setitempre(vdialog, clist_profiles, chandlername);
	
		dlg_tools.drawbutton(vdialog
							,cbtn_add
							,66
							,2
							,12
							,'Add'
							,'Add new profile'
							,chandlername
							,preadonly
							,panchor => dialog.anchor_right + dialog.anchor_top);
		dlg_tools.drawbutton(vdialog
							,cbtn_copy
							,66
							,4
							,12
							,'Copy'
							,'Copy selected profile'
							,chandlername
							,preadonly
							,panchor => dialog.anchor_right + dialog.anchor_top);
		dlg_tools.drawbutton(vdialog
							,cbtn_delete
							,66
							,6
							,12
							,'Delete'
							,'Delete selected profile'
							,chandlername
							,preadonly
							,panchor => dialog.anchor_right + dialog.anchor_top);
		dlg_tools.drawbutton(vdialog
							,cbtn_cancel
							,66
							,13
							,12
							,'Exit'
							,'Exit dialog'
							,dialog.cmcancel
							,panchor => dialog.anchor_right + dialog.anchor_bottom);
	
		dlg_monthlyfees_filllist(vdialog);
	
		dialog.setdialogpost(vdialog, chandlername);
	
		t.leave(cmethodname);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			dialog.destroy(vdialog);
			error.save(cmethodname);
			RAISE;
	END dlg_monthlyfees_create;

	PROCEDURE dlg_monthlyfees_filllist
	(
		pdialog    IN NUMBER
	   ,pprofileid IN NUMBER := NULL
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.Dlg_MonthlyFees_FillList';
		vmonthlyfeearray typemonthlyfeearray;
		vcurrentpos      NUMBER;
	BEGIN
		t.enter(cmethodname);
	
		vcurrentpos := dialog.getlistcurrentrecordnumber(pdialog, clist_profiles);
	
		dialog.listclear(pdialog, clist_profiles);
	
		vmonthlyfeearray := getmonthlyfeeprofiles;
		FOR i IN 1 .. vmonthlyfeearray.count
		LOOP
			dialog.listaddrecord(pdialog
								,clist_profiles
								,vmonthlyfeearray(i).profileid || '~' || vmonthlyfeearray(i).name);
		END LOOP;
	
		IF pprofileid IS NOT NULL
		THEN
			dialog.setcurrecbyvalue(pdialog, clist_profiles, cfld_id, pprofileid);
		
		ELSE
			dlg_tools.setlistoldposition(pdialog, clist_profiles, vcurrentpos);
		END IF;
	
		dlg_tools.setenabled(pdialog
							,tblchar100(cbtn_copy, cbtn_delete)
							,(vmonthlyfeearray.count > 0) AND (NOT isreadonly(pdialog)));
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dlg_monthlyfees_filllist;

	PROCEDURE dlg_monthlyfees_handler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.Dlg_MonthlyFees_Handler';
		vprofilerow typemonthlyfeerow;
	BEGIN
		t.enter(cmethodname
			   ,'Dialog = ' || pdialog || ', What = ' || pwhat || ', ItemName = ' || pitemname ||
				', Cmd = ' || pcmd);
	
		CASE pwhat
		
			WHEN dialog.wt_itempre THEN
			
				CASE pitemname
				
					WHEN cbtn_add THEN
						dialog.exec(dlg_monthlyfee_create('Add monthly fee profile'
														 ,cemptymonthlyfeerow));
					
					WHEN cbtn_copy THEN
						vprofilerow           := getmonthlyfeeprofile(dialog.getcurrentrecordnumber(pdialog
																								   ,clist_profiles
																								   ,cfld_id));
						vprofilerow.profileid := NULL;
						dialog.exec(dlg_monthlyfee_create('Copy monthly fee profile', vprofilerow));
					
					WHEN cbtn_delete THEN
					
						IF htools.ask('Confirm'
									 ,'Delete monthly fee profile <' ||
									  dialog.getcurrentrecordnumber(pdialog
																   ,clist_profiles
																   ,cfld_id) || '>?')
						THEN
						
							BEGIN
							
								dml_monthlyfee_deleterecord(getmonthlyfeeprofile(dialog.getcurrentrecordnumber(pdialog
																											  ,clist_profiles
																											  ,cfld_id)));
							
								dlg_monthlyfees_filllist(pdialog);
							
							EXCEPTION
								WHEN OTHERS THEN
									htools.showmessage('Error', error.getusertext);
							END;
						
						END IF;
					
					WHEN clist_profiles THEN
						vprofilerow := getmonthlyfeeprofile(dialog.getcurrentrecordnumber(pdialog
																						 ,clist_profiles
																						 ,cfld_id));
						dialog.exec(dlg_monthlyfee_create('Edit monthly fee profile <ID=' ||
														  vprofilerow.profileid || '>'
														 ,vprofilerow));
					
					WHEN upper('miExport') THEN
						DECLARE
							cbranch CONSTANT VARCHAR2(100) := seance.getbranch();
							vexportsettings custom_contractexchangetools.typeexportsettings;
						BEGIN
							vexportsettings.tablename    := creftable_monthlyfees;
							vexportsettings.packagename  := cpackagename;
							vexportsettings.objectname   := cobjectname_monthlyfees;
							vexportsettings.whereclause  := 'branch=' || cbranch;
							vexportsettings.orderclause  := 'ProfileID';
							vexportsettings.codecolumn   := 'ProfileID';
							vexportsettings.identcolumn  := '';
							vexportsettings.namecolumn   := 'Name';
							vexportsettings.exportchilds := TRUE;
							dialog.exec(custom_contractexchangetools.dialogexport(vexportsettings));
						END;
					
					WHEN upper('miImport') THEN
						monthlyfees_importinteractive(pdialog);
					
					ELSE
						NULL;
				END CASE;
			
			WHEN dialog.wt_dialogpost THEN
				dlg_tools.refreshallitems(cpackagename, cdropbox_monthlyfee);
			
			ELSE
				NULL;
		END CASE;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dlg_monthlyfees_handler;

	PROCEDURE ref_monthlyfees_run(preadonly IN BOOLEAN := FALSE) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.Ref_MonthlyFees_Run';
	BEGIN
		t.enter(cmethodname);
	
		dialog.exec(dlg_monthlyfees_create(preadonly));
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END ref_monthlyfees_run;

	PROCEDURE ref_monthlyfees_addtomenu
	(
		pdialog   IN NUMBER
	   ,pmenu     IN NUMBER
	   ,preadonly IN BOOLEAN := FALSE
	) IS
		cmethodname  CONSTANT typemethodname := cpackagename || '.Ref_MonthlyFees_AddToMenu';
		chandlername CONSTANT typemethodname := cpackagename || '.Ref_MonthlyFees_MenuHandler';
	BEGIN
		t.enter(cmethodname);
	
		dialog.menuitem(pmenu
					   ,cmnuitem_monthlyfees
					   ,crefname_monthlyfees
					   ,0
					   ,0
					   ,'Use this menu item to setup monthly fee profiles'
					   ,chandlername);
	
		dlg_tools.setbooltomaindialog(pdialog, creadonly, preadonly);
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END ref_monthlyfees_addtomenu;

	PROCEDURE ref_monthlyfees_menuhandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.Ref_MonthlyFees_MenuHandler';
	BEGIN
		t.enter(cmethodname);
	
		IF (pwhat = dialog.wtitempre)
		   AND (pitemname = upper(cmnuitem_monthlyfees))
		THEN
			ref_monthlyfees_run(isreadonly(pdialog));
		END IF;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END ref_monthlyfees_menuhandler;

	PROCEDURE dropbox_monthlyfee_create
	(
		pdialog       IN NUMBER
	   ,pitemname     IN typeitemname
	   ,px            IN NUMBER
	   ,py            IN NUMBER
	   ,plen          IN NUMBER
	   ,pcaption      IN VARCHAR2
	   ,phint         IN VARCHAR2
	   ,pobjecttype   IN NUMBER
	   ,pobjectno     IN VARCHAR2
	   ,pemptycaption IN VARCHAR2 := fintypes.cnotusedcaption
	   ,pcommand      IN NUMBER := 0
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.DropBox_MonthlyFee_Create';
	BEGIN
		t.enter(cmethodname, pitemname);
	
		dlg_tools.makedroplist(pdialog, pitemname, px, py, plen, plen, pcaption, phint);
	
		dlg_tools.registeritem(cpackagename
							  ,cdropbox_monthlyfee
							  ,pdialog
							  ,pitemname
							  ,'Monthly fee profile'
							  ,pobjecttype
							  ,pobjectno
							  ,pemptycaption
							  ,pcommand => pcommand);
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dropbox_monthlyfee_create;

	PROCEDURE dropbox_monthlyfee_fill
	(
		pdialog     IN NUMBER
	   ,pdialogitem IN fintypes.typedialogitem
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.DropBox_MonthlyFee_Fill';
		cbranch     CONSTANT NUMBER := seance.getbranch;
	BEGIN
		t.enter(cmethodname);
	
		FOR i IN (SELECT * FROM treferencemonthlyfee WHERE branch = cbranch ORDER BY profileid)
		LOOP
			dialog.listaddrecord(pdialog
								,pdialogitem.itemname
								,i.profileid || '~' || i.name
								,pdialogitem.command);
		END LOOP;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dropbox_monthlyfee_fill;

	FUNCTION dropbox_monthlyfee_getvalue
	(
		pdialog      IN NUMBER
	   ,pitemname    IN typeitemname
	   ,pdoexception IN BOOLEAN := FALSE
	) RETURN VARCHAR2 IS
		cmethodname CONSTANT typemethodname := cpackagename || '.DropBox_MonthlyFee_GetValue';
	BEGIN
		RETURN dlg_tools.getitemvalue(pdialog, pitemname, pdoexception);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dropbox_monthlyfee_getvalue;

	FUNCTION dropbox_monthlyfee_save
	(
		pdialog        IN NUMBER
	   ,pitemname      IN typeitemname
	   ,pwritelog      IN BOOLEAN := FALSE
	   ,pparamname     IN VARCHAR2 := NULL
	   ,psaveinhistory IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		cmethodname CONSTANT typemethodname := cpackagename || '.DropBox_MonthlyFee_Save';
	BEGIN
		dlg_tools.saveitemvalue(pdialog, pitemname, pwritelog, pparamname, psaveinhistory);
		RETURN dlg_tools.getitemvalue(pdialog, pitemname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END dropbox_monthlyfee_save;

	PROCEDURE operationgroups_importinteractive(pdialog NUMBER) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.OperationGroups_ImportInteractive';
		vdialog         NUMBER;
		vimportsettings custom_contractexchangetools.typeimportsettings;
	BEGIN
		vimportsettings.referencename := 'Operations groups';
		vimportsettings.packagename := cpackagename;
		vimportsettings.tablename := creftable_entrygroups;
		vimportsettings.objectname := cobjectname_entrygroups;
		vimportsettings.codecolumn := 'GroupId';
		vimportsettings.identcolumn := '';
		vimportsettings.additionalsettings(creftable_entrygrouplist).objectname := 'Operation';
	
		vdialog := custom_contractexchangetools.dialogimport(vimportsettings);
	
		IF dialog.execdialog(vdialog) = dialog.cmok
		THEN
			COMMIT;
			dlg_operationgroups_filllist(pdialog);
		END IF;
		dialog.destroy(vdialog);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE operationgroups_validate
	(
		porow       IN OUT NOCOPY typeentrygrouprow
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,oactiontype OUT custom_contractexchangetools.typeactiontype
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.OperationGroups_Validate';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vgroupid NUMBER;
	BEGIN
	
		vgroupid := custom_contractexchangetools.getdestcode(creftable_entrygroups
															,'GroupId'
															,porow.groupid);
	
		oactiontype := custom_contractexchangetools.getactiontype(pimportmode, vgroupid IS NULL);
	
		IF oactiontype IN (custom_contractexchangetools.cacttype_mtexists_update
						  ,custom_contractexchangetools.cacttype_locexists_update
						  ,custom_contractexchangetools.cacttype_notexists_add)
		THEN
			porow.groupid := vgroupid;
		END IF;
	
		porow.branch := cbranch;
	
		t.var('ActionType', oactiontype);
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE operation_validate
	(
		porow       IN OUT NOCOPY tcontractentrygrouplist%ROWTYPE
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,oactiontype OUT custom_contractexchangetools.typeactiontype
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.Operation_Validate';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vgroupid       NUMBER;
		vsourceentcode tcontractentrygrouplist.entcode%TYPE;
	BEGIN
		vgroupid := custom_contractexchangetools.getdestcode(creftable_entrygroups
															,'GroupId'
															,porow.groupid);
	
		IF vgroupid IS NOT NULL
		THEN
			porow.groupid := vgroupid;
		
		ELSE
			error.raiseerror('The entry group was not found in the matching table (' ||
							 coalesce(to_char(porow.groupid), '[null]') || ')');
		END IF;
	
		IF porow.entcode IS NOT NULL
		THEN
			vsourceentcode := porow.entcode;
			custom_contractexchangetools.validateentrycode(porow.entcode);
			IF porow.entcode IS NULL
			THEN
				error.raiseerror('The entry code was not found in the matching table (EntryCode=' ||
								 to_char(vsourceentcode) || ')');
			END IF;
		END IF;
	
		porow.branch := cbranch;
	
		t.var('ActionType', oactiontype);
		t.var('poRow.GroupId', porow.groupid);
		t.var('poRow.EntCode', porow.entcode);
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE operationgroups_saverow
	(
		porow       IN OUT NOCOPY typeentrygrouprow
	   ,pactiontype custom_contractexchangetools.typeactiontype
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.OperationGroups_SaveRow';
		cbranch     CONSTANT NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethodname, 'pActionType=' || pactiontype || ', GroupId=' || porow.groupid);
		CASE pactiontype
			WHEN custom_contractexchangetools.cacttype_skipbyerror THEN
				NULL;
			WHEN custom_contractexchangetools.cacttype_mtexists_skip THEN
				NULL;
			WHEN custom_contractexchangetools.cacttype_locexists_skip THEN
				NULL;
			WHEN custom_contractexchangetools.cacttype_mtexists_update THEN
			
				DELETE FROM tcontractentrygrouplist
				WHERE  branch = cbranch
				AND    groupid = porow.groupid;
			
				updateentrygroup(porow, paddonnotfound => TRUE);
			
			WHEN custom_contractexchangetools.cacttype_notexists_add THEN
				porow.groupid := getnewentrygroupid();
				insertentrygroup(porow);
			ELSE
				error.raiseerror('Internal error: unknown action type [' ||
								 coalesce(to_char(pactiontype), 'null') || ']');
		END CASE;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE monthlyfees_validate
	(
		porow       IN OUT NOCOPY typemonthlyfeerow
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,oactiontype OUT custom_contractexchangetools.typeactiontype
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.MonthlyFees_Validate';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vprofileid NUMBER;
		vtariffid  NUMBER;
	BEGIN
		vprofileid := custom_contractexchangetools.getdestcode(creftable_monthlyfees
															  ,'ProfileId'
															  ,porow.profileid);
	
		oactiontype := custom_contractexchangetools.getactiontype(pimportmode, vprofileid IS NULL);
	
		IF oactiontype IN (custom_contractexchangetools.cacttype_mtexists_update
						  ,custom_contractexchangetools.cacttype_locexists_update
						  ,custom_contractexchangetools.cacttype_notexists_add)
		THEN
			porow.profileid := vprofileid;
		END IF;
	
		IF porow.tariffid IS NOT NULL
		THEN
		
			vtariffid := custom_contractexchangetools.getdestcode('tContractCommissionRef'
																 ,'CommissionNo'
																 ,porow.tariffid);
		
			IF vtariffid IS NULL
			THEN
				error.raiseerror('The tariff was not found in the matching table (Id=' ||
								 porow.tariffid || ')');
			ELSE
				t.note(cmethodname
					  ,'found matching for TariffId: ' || porow.tariffid || ' -> ' || vtariffid);
			END IF;
		
			porow.tariffid := vtariffid;
		END IF;
	
		porow.branch := cbranch;
	
		t.var('ActionType', oactiontype);
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE monthlyfees_importinteractive(pdialog NUMBER) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT typemethodname := cpackagename || '.MonthlyFees_ImportInteractive';
		vdialog         NUMBER;
		vimportsettings custom_contractexchangetools.typeimportsettings;
	BEGIN
		vimportsettings.referencename := crefname_monthlyfees;
		vimportsettings.packagename := cpackagename;
		vimportsettings.tablename := creftable_monthlyfees;
		vimportsettings.objectname := cobjectname_monthlyfees;
		vimportsettings.codecolumn := 'ProfileID';
		vimportsettings.identcolumn := '';
		vimportsettings.additionalsettings(creftable_monthlyfeeentries).objectname := 'MonthlyFeeEntry';
		vdialog := custom_contractexchangetools.dialogimport(vimportsettings);
	
		IF dialog.execdialog(vdialog) = dialog.cmok
		THEN
			COMMIT;
			dlg_monthlyfees_filllist(pdialog);
		END IF;
		dialog.destroy(vdialog);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE monthlyfeeentry_validate
	(
		porow       IN OUT NOCOPY treferencemonthlyfeeentries%ROWTYPE
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,oactiontype OUT custom_contractexchangetools.typeactiontype
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.MonthlyFeeEntry_Validate';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vprofileid NUMBER;
	BEGIN
		vprofileid := custom_contractexchangetools.getdestcode(creftable_monthlyfees
															  ,'ProfileId'
															  ,porow.profileid);
	
		oactiontype := custom_contractexchangetools.getactiontype(pimportmode, vprofileid IS NULL);
	
		IF oactiontype IN (custom_contractexchangetools.cacttype_mtexists_update
						  ,custom_contractexchangetools.cacttype_locexists_update
						  ,custom_contractexchangetools.cacttype_notexists_add)
		THEN
			porow.profileid := vprofileid;
		END IF;
	
		custom_contractexchangetools.validateentrycode(porow.entrycode);
		IF porow.entrycode IS NULL
		THEN
			error.raiseerror('The entry code was not found in the matching table (EntryCode=' ||
							 coalesce(to_char(porow.entrycode), '[null]') || ')');
		END IF;
	
		porow.branch := cbranch;
	
		t.var('ActionType', oactiontype);
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE monthlyfees_saverow
	(
		porow       IN OUT NOCOPY typemonthlyfeerow
	   ,pactiontype custom_contractexchangetools.typeactiontype
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.MonthlyFees_SaveRow';
	
	BEGIN
		t.enter(cmethodname, 'pActionType=' || pactiontype || ', ProfileId=' || porow.profileid);
		CASE pactiontype
			WHEN custom_contractexchangetools.cacttype_skipbyerror THEN
				NULL;
			WHEN custom_contractexchangetools.cacttype_mtexists_skip THEN
				NULL;
			WHEN custom_contractexchangetools.cacttype_locexists_skip THEN
				NULL;
			WHEN custom_contractexchangetools.cacttype_mtexists_update THEN
			
				updatemonthlyfee(porow, pclearentries => TRUE, plog => TRUE);
			
			WHEN custom_contractexchangetools.cacttype_notexists_add THEN
				insertmonthlyfee(porow);
			ELSE
				error.raiseerror('Internal error: unknown action type [' ||
								 coalesce(to_char(pactiontype), 'null') || ']');
		END CASE;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE mpprofiles_importinteractive(pdialog NUMBER) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.MPProfiles_ImportInteractive';
		vdialog         NUMBER;
		vimportsettings custom_contractexchangetools.typeimportsettings;
	BEGIN
		vimportsettings.referencename := 'Minimum Payment calculation profiles';
		vimportsettings.packagename := cpackagename;
		vimportsettings.tablename := creftable_mpprofiles;
		vimportsettings.objectname := cobjectname_mpprofiles;
		vimportsettings.codecolumn := 'ProfileID';
		vimportsettings.identcolumn := '';
		vimportsettings.additionalsettings(creftable_mpprofiles).parametersobjecttype := 'CONTRACT_MP_PROFILE';
	
		vdialog := custom_contractexchangetools.dialogimport(vimportsettings);
	
		IF dialog.execdialog(vdialog) = dialog.cmok
		THEN
			COMMIT;
			dlg_mpprofiles_filllist(pdialog);
		END IF;
		dialog.destroy(vdialog);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE mpprofiles_validate
	(
		porow       IN OUT NOCOPY typempprofilerow
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,oactiontype OUT custom_contractexchangetools.typeactiontype
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.MPProfiles_Validate';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vprofileid NUMBER;
	BEGIN
		vprofileid := custom_contractexchangetools.getdestcode(creftable_mpprofiles
															  ,'ProfileId'
															  ,porow.profileid);
	
		oactiontype := custom_contractexchangetools.getactiontype(pimportmode, vprofileid IS NULL);
	
		IF oactiontype IN (custom_contractexchangetools.cacttype_mtexists_update
						  ,custom_contractexchangetools.cacttype_locexists_update
						  ,custom_contractexchangetools.cacttype_notexists_add)
		THEN
			porow.profileid := vprofileid;
		END IF;
	
		porow.branch := cbranch;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE mpprofiles_validateparam(porow IN OUT NOCOPY typeparamrow) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.MPProfiles_ValidateParam';
		vpos         NUMBER;
		vsourcegroup NUMBER;
		vdestgroup   NUMBER;
		verrmessage  VARCHAR2(1000);
		vprofileid   NUMBER;
		vsubstr      VARCHAR2(100);
	BEGIN
		t.enter(cmethodname, 'Key=' || porow.key);
	
		vprofileid := to_number(custom_contractexchangetools.getdestcode(creftable_mpprofiles
																		,'ProfileId'
																		,porow.objectno));
		IF vprofileid IS NULL
		THEN
			custom_contractexchangetools.log(custom_contractexchangetools.clogtype_error
											,cpackagename
											,'ContractParams'
											,porow.objectno || '|' || porow.key
											,NULL
											,'The profile id was not found in the matching table [' ||
											 porow.objectno || ']');
		ELSE
		
			IF porow.key LIKE upper('MP_Percent_') || '%'
			   OR porow.key LIKE upper('MP_Current_') || '%'
			THEN
			
				vpos := instr(porow.key, '_', 1, 2);
			
				vsubstr := substr(porow.key, vpos + 1, length(porow.key) - vpos);
			
				IF regexp_replace(vsubstr, '[[:digit:]]') IS NULL
				THEN
				
					vsourcegroup := to_number(vsubstr);
					vdestgroup   := to_number(custom_contractexchangetools.getdestcode('tContractEntryGroup'
																					  ,'GroupId'
																					  ,vsourcegroup));
					IF vdestgroup IS NOT NULL
					THEN
						porow.key := substr(porow.key, 1, vpos) || vdestgroup;
					ELSE
						verrmessage := verrmessage ||
									   service.iif(verrmessage IS NOT NULL, ', ', NULL) ||
									   'The entry group code was not found in the matching table [' ||
									   vsourcegroup || ']';
					END IF;
				END IF;
			END IF;
		
			IF porow.key LIKE '%_PROPLSQL'
			THEN
				IF porow.value IS NOT NULL
				THEN
					porow.value := custom_contractexchangetools.getdestcode('tDynaSQL'
																		   ,'Code'
																		   ,porow.value);
					IF porow.value IS NULL
					THEN
						verrmessage := verrmessage ||
									   service.iif(verrmessage IS NOT NULL, ', ', NULL) ||
									   'The pl/sql-block code was not found in the matching table [' ||
									   porow.key || ']';
					END IF;
				END IF;
			END IF;
		
			IF verrmessage IS NOT NULL
			THEN
				custom_contractexchangetools.log(custom_contractexchangetools.clogtype_error
												,cpackagename
												,'ContractParams'
												,porow.objectno || '|' || porow.key
												,NULL
												,verrmessage);
				RETURN;
			END IF;
		
			porow.objectno := vprofileid;
		END IF;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE mpprofiles_saverow
	(
		porow       IN OUT NOCOPY typempprofilerow
	   ,pactiontype custom_contractexchangetools.typeactiontype
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.MPProfiles_SaveRow';
	
	BEGIN
		t.enter(cmethodname, 'pActionType=' || pactiontype || ', ProfileId=' || porow.profileid);
		CASE pactiontype
			WHEN custom_contractexchangetools.cacttype_skipbyerror THEN
				NULL;
			WHEN custom_contractexchangetools.cacttype_mtexists_skip THEN
				NULL;
			WHEN custom_contractexchangetools.cacttype_locexists_skip THEN
				NULL;
			WHEN custom_contractexchangetools.cacttype_mtexists_update THEN
				updatempprofile(porow.profileid, porow.profilename);
			WHEN custom_contractexchangetools.cacttype_notexists_add THEN
				porow.profileid := getnewmpprofileid();
				insertmpprofile(porow.profileid, porow.profilename, TRUE);
			ELSE
				error.raiseerror('Internal error: unknown action type [' ||
								 coalesce(to_char(pactiontype), 'null') || ']');
		END CASE;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE profiles_importinteractive(pdialog NUMBER) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT typemethodname := cpackagename || '.Profiles_ImportInteractive';
		vdialog         NUMBER;
		vimportsettings custom_contractexchangetools.typeimportsettings;
	BEGIN
		vimportsettings.referencename := 'Interest and fees calculation profiles';
		vimportsettings.packagename   := cpackagename;
		vimportsettings.tablename     := creftable_profiles;
		vimportsettings.objectname    := cobjectname_profiles;
		vimportsettings.codecolumn    := 'ProfileID';
		vimportsettings.identcolumn   := '';
		vimportsettings.importchilds  := FALSE;
	
		vdialog := custom_contractexchangetools.dialogimport(vimportsettings);
	
		IF dialog.execdialog(vdialog) = dialog.cmok
		THEN
			COMMIT;
			dlg_profiles_filllist(pdialog);
		END IF;
		dialog.destroy(vdialog);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE profiles_validate
	(
		porow       IN OUT NOCOPY typeprofilerow
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,oactiontype OUT custom_contractexchangetools.typeactiontype
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.Profiles_Validate';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vprofileid NUMBER;
	BEGIN
		vprofileid := custom_contractexchangetools.getdestcode(creftable_profiles
															  ,'ProfileId'
															  ,porow.profileid);
	
		oactiontype := custom_contractexchangetools.getactiontype(pimportmode, vprofileid IS NULL);
	
		IF oactiontype IN (custom_contractexchangetools.cacttype_mtexists_update
						  ,custom_contractexchangetools.cacttype_locexists_update
						  ,custom_contractexchangetools.cacttype_notexists_add)
		THEN
			porow.profileid := vprofileid;
		END IF;
	
		porow.branch := cbranch;
	
		t.var('ActionType', oactiontype);
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE profiles_saverow
	(
		porow       IN OUT NOCOPY typeprofilerow
	   ,pactiontype custom_contractexchangetools.typeactiontype
	) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.MPProfiles_SaveRow';
		cbranch     CONSTANT NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethodname, 'pActionType=' || pactiontype || ', ProfileId=' || porow.profileid);
		CASE pactiontype
			WHEN custom_contractexchangetools.cacttype_skipbyerror THEN
				NULL;
			WHEN custom_contractexchangetools.cacttype_mtexists_skip THEN
				NULL;
			WHEN custom_contractexchangetools.cacttype_locexists_skip THEN
				NULL;
			WHEN custom_contractexchangetools.cacttype_mtexists_update THEN
				BEGIN
					SAVEPOINT sp_updateprofile;
				
					UPDATE tcontractprofile
					SET    profilename = porow.profilename
						  ,currency    = porow.currency
					WHERE  branch = cbranch
					AND    profileid = porow.profileid;
				
					referenceprchistory.deletepercentbelong(referenceprchistory.crvpother1
														   ,porow.profileid);
				
					contractparams.deletevalue(getobjecttype, porow.profileid);
				
					DELETE FROM tcontractprofilegroup
					WHERE  branch = cbranch
					AND    profileid = porow.profileid;
				
					DELETE FROM tcontractredintsettings
					WHERE  branch = cbranch
					AND    profileid = porow.profileid;
				
				EXCEPTION
					WHEN OTHERS THEN
						error.save(cmethodname || '.Update');
						ROLLBACK TO sp_updateprofile;
						RAISE;
				END;
			
			WHEN custom_contractexchangetools.cacttype_notexists_add THEN
				insertprofile(porow.profileid, porow.profilename, porow.currency);
			ELSE
				error.raiseerror('Internal error: unknown action type [' ||
								 coalesce(to_char(pactiontype), 'null') || ']');
		END CASE;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE profiles_validateparam(porow IN OUT NOCOPY typeparamrow) IS
		cmethodname CONSTANT typemethodname := cpackagename || '.Profiles_ValidateParam';
		vpos         NUMBER;
		vsourcegroup NUMBER;
		vdestgroup   NUMBER;
		verrmessage  VARCHAR2(1000);
		vprofileid   NUMBER;
	BEGIN
		t.enter(cmethodname, 'Key=' || porow.key);
	
		vprofileid := to_number(custom_contractexchangetools.getdestcode(creftable_profiles
																		,'ProfileId'
																		,porow.objectno));
		IF vprofileid IS NULL
		THEN
			custom_contractexchangetools.log(custom_contractexchangetools.clogtype_error
											,cpackagename
											,'ContractParams'
											,porow.objectno || '|' || porow.key
											,NULL
											,'The profile id was not found in the matching table [' ||
											 porow.objectno || ']');
		ELSE
		
			vpos := instr(porow.key, '_');
			IF vpos > 0
			   AND substr(porow.key, vpos + 1) IN
			   (upper('ChargeInt')
				   ,upper('StartDate')
				   ,upper('ShiftDays')
				   ,upper('DaysInYear')
				   ,upper('ChargeOnB')
				   ,upper('UseRedRate')
				   ,upper('ChargePaid')
				   ,upper('OnlyFirst')
				   ,upper('TillCurSD')
				   ,upper('UnBillInc')
				   ,upper('CrdPrcDate')
				   ,upper('CrdPrcType')
				   ,upper('CrdPrcPrdt')
				   ,upper('CrdPrcHist')
				   ,upper('ProPrcHist')
				   ,upper('ProCalId')
				   ,upper('ProAddCond')
				   ,upper('ProPLSQL')
				   ,upper('PrePrcHist')
				   ,upper('PreCalId')
				   ,upper('PreUsageStartFrom'))
			THEN
				vsourcegroup := to_number(substr(porow.key, 1, vpos - 1));
				vdestgroup   := to_number(custom_contractexchangetools.getdestcode('tContractEntryGroup'
																				  ,'GroupId'
																				  ,vsourcegroup));
				IF vdestgroup IS NOT NULL
				THEN
					porow.key := vdestgroup || '_' || substr(porow.key, vpos + 1);
				ELSE
					verrmessage := verrmessage || service.iif(verrmessage IS NOT NULL, ', ', NULL) ||
								   'The entry group code was not found in the matching table [' ||
								   vsourcegroup || ']';
				END IF;
			END IF;
		
			IF porow.key LIKE '%_PROPLSQL'
			THEN
				IF porow.value IS NOT NULL
				THEN
					porow.value := custom_contractexchangetools.getdestcode('tDynaSQL'
																		   ,'Code'
																		   ,porow.value);
					IF porow.value IS NULL
					THEN
						verrmessage := verrmessage ||
									   service.iif(verrmessage IS NOT NULL, ', ', NULL) ||
									   'The pl/sql-block code was not found in the matching table [' ||
									   porow.key || ']';
					END IF;
				END IF;
			END IF;
		
			IF verrmessage IS NOT NULL
			THEN
				custom_contractexchangetools.log(custom_contractexchangetools.clogtype_error
												,cpackagename
												,'ContractParams'
												,porow.objectno || '|' || porow.key
												,NULL
												,verrmessage);
				RETURN;
			END IF;
		
			porow.objectno := vprofileid;
		END IF;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION profiles_export(psettings custom_contractexchangetools.typeexportsettings) RETURN xmltype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.Profiles_Export';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vblockxml       xmltype;
		vxml            xmltype;
		vcurstr         CLOB;
		vexportsettings custom_contractexchangetools.typeexportsettings;
		vmainxml        xmltype;
		vchildxml       xmltype;
		vacodelist      tblnumber;
	BEGIN
		t.enter(cmethodname);
	
		vmainxml := custom_contractexchangetools.export2xml(psettings, FALSE);
	
		vexportsettings.tablename    := creftable_percents;
		vexportsettings.packagename  := cpackagename;
		vexportsettings.objectname   := NULL;
		vexportsettings.whereclause  := ' branch=' || cbranch || ' and Category = 9 ' ||
										service.iif(psettings.whereclause IS NOT NULL
												   ,'and ObjectNo in (select ProfileId from tContractProfile where ' ||
													psettings.whereclause || ')'
												   ,NULL);
		vexportsettings.orderclause  := 'ObjectNo';
		vexportsettings.codecolumn   := 'ObjectNo';
		vexportsettings.exportchilds := FALSE;
	
		vchildxml := custom_contractexchangetools.export2xml(vexportsettings, TRUE);
		SELECT xmlconcat(vmainxml, vchildxml) INTO vmainxml FROM dual;
	
		vexportsettings.tablename    := 'tContractProfileGroup';
		vexportsettings.packagename  := cpackagename;
		vexportsettings.objectname   := NULL;
		vexportsettings.whereclause  := ' branch=' || cbranch ||
										service.iif(psettings.whereclause IS NOT NULL
												   ,'and ProfileId in (select ProfileId from tContractProfile where ' ||
													psettings.whereclause || ')'
												   ,NULL);
		vexportsettings.orderclause  := 'Priority';
		vexportsettings.codecolumn   := 'GroupId';
		vexportsettings.exportchilds := FALSE;
	
		vchildxml := custom_contractexchangetools.export2xml(vexportsettings, TRUE);
		SELECT xmlconcat(vmainxml, vchildxml) INTO vmainxml FROM dual;
	
		vexportsettings.tablename    := 'tContractRedIntSettings';
		vexportsettings.packagename  := cpackagename;
		vexportsettings.objectname   := NULL;
		vexportsettings.whereclause  := ' branch=' || cbranch ||
										service.iif(psettings.whereclause IS NOT NULL
												   ,'and ProfileId in (select ProfileId from tContractProfile where ' ||
													psettings.whereclause || ')'
												   ,NULL);
		vexportsettings.orderclause  := 'Priority';
		vexportsettings.codecolumn   := 'GroupId';
		vexportsettings.exportchilds := FALSE;
	
		vchildxml := custom_contractexchangetools.export2xml(vexportsettings, TRUE);
		SELECT xmlconcat(vmainxml, vchildxml) INTO vmainxml FROM dual;
	
		IF psettings.whereclause IS NOT NULL
		THEN
			vcurstr := 'select value from tContractOtherParameters p
				where branch=' || cbranch ||
					   ' and objectType in (select ObjectType from  tContractOtherObjectType where Branch = p.Branch
				 and ObjectSign = ''CONTRACT_PROFILE'') and key like ''%_PROPLSQL'' and ObjectNo in (select ProfileId from tContractProfile where ' ||
					   psettings.whereclause || ')';
			s.say('SQL4DS:');
			s.say(vcurstr);
		
			IF custom_contractexchangetools.needbindcodelist(psettings.whereclause)
			THEN
				EXECUTE IMMEDIATE vcurstr BULK COLLECT
					INTO vacodelist
					USING custom_contractexchangetools.getcodelist;
			ELSE
				EXECUTE IMMEDIATE vcurstr BULK COLLECT
					INTO vacodelist;
			END IF;
		ELSE
			vcurstr := 'select value from tContractOtherParameters p
				where branch=' || cbranch ||
					   ' and objectType in (select ObjectType from  tContractOtherObjectType where Branch = p.Branch
				 and ObjectSign = ''CONTRACT_PROFILE'') and key like ''%_PROPLSQL''';
			s.say('SQL4DS:');
			s.say(vcurstr);
			EXECUTE IMMEDIATE vcurstr BULK COLLECT
				INTO vacodelist;
		END IF;
	
		FOR i IN 1 .. vacodelist.count
		LOOP
			SELECT xmltype(custom_dynasql.exportsql(vacodelist(i))) INTO vblockxml FROM dual;
			SELECT xmlconcat(vxml, vblockxml) INTO vxml FROM dual;
		END LOOP;
	
		EXECUTE IMMEDIATE 'select XMLElement("' || custom_contractexchangetools.cdsblockstag ||
						  '", :1) from dual'
			INTO vxml
			USING vxml;
		SELECT xmlconcat(vmainxml, vxml) INTO vxml FROM dual;
	
		EXECUTE IMMEDIATE 'select XMLElement("' || upper(psettings.objectname) ||
						  '", :1) from dual'
			INTO vxml
			USING vxml;
	
		custom_contractexchangetools.sayxml(vxml, psettings.objectname || ' xml');
	
		RETURN vxml;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END profiles_export;

	PROCEDURE profiles_import
	(
		pxml        xmltype
	   ,psettings   custom_contractexchangetools.typeimportsettings
	   ,psaverecord BOOLEAN := TRUE
	   ,ocontinue   OUT BOOLEAN
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.Profiles_Import';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vimportsettings custom_contractexchangetools.typeimportsettings;
	BEGIN
		t.enter(cmethodname, 'SaveRecord=' || htools.b2s(psaverecord));
		SAVEPOINT sp_profilesimport;
		custom_contractexchangetools.sayxml(pxml, psettings.objectname || ' xml');
	
		s.say('-------------------Main table----------------------');
		custom_contractexchangetools.importfromxml(pxml
												  ,psettings
												  ,psaverecord
												  ,pclearlog   => TRUE
												  ,ocontinue   => ocontinue);
		s.say('-----------------end main table-------------------- (oContinue=' ||
			  htools.b2s(ocontinue) || ')');
	
		IF ocontinue
		THEN
			s.say('------------------Profile Groups---------------------');
			FOR grouprow IN (SELECT VALUE(p) xml
							 FROM   TABLE(xmlsequence(pxml.extract('//' ||
																   upper(psettings.objectname) || '/' ||
																   upper(creftable_groups) || '/' ||
																   upper(creftable_groups) || '_ROW'))) p)
			LOOP
				DECLARE
					verrmessage      VARCHAR2(1000);
					vdestprofileid   NUMBER;
					vdestgroupid     NUMBER;
					vsourceprofileid NUMBER;
					vrow             tcontractprofilegroup%ROWTYPE;
				
				BEGIN
					vrow.branch := cbranch;
				
					vrow.profileid := xmltools.getvalue(grouprow.xml
													   ,'//' || upper(creftable_groups) || '_ROW' ||
														'/PROFILEID');
					t.var('ProfileId', vrow.profileid);
					vsourceprofileid := vrow.profileid;
				
					vrow.groupid := xmltools.getvalue(grouprow.xml
													 ,'//' || upper(creftable_groups) || '_ROW' ||
													  '/GROUPID');
					t.var('GroupId', vrow.groupid);
				
					vrow.priority := xmltools.getvalue(grouprow.xml
													  ,'//' || upper(creftable_groups) || '_ROW' ||
													   '/PRIORITY');
					t.var('Priority', vrow.priority);
				
					vdestprofileid := to_number(custom_contractexchangetools.getdestcode(creftable_profiles
																						,'ProfileId'
																						,vrow.profileid));
					IF vdestprofileid IS NULL
					THEN
						verrmessage := 'The profile was not found in the matching table [' ||
									   vrow.profileid || ']';
					END IF;
				
					vdestgroupid := to_number(custom_contractexchangetools.getdestcode('tContractEntryGroup'
																					  ,'GroupId'
																					  ,vrow.groupid));
					IF vdestgroupid IS NULL
					THEN
						verrmessage := verrmessage ||
									   service.iif(verrmessage IS NOT NULL, '; ', NULL) ||
									   'The entry group was not found in the matching table [' ||
									   vrow.groupid || ']';
					END IF;
				
					IF verrmessage IS NOT NULL
					THEN
						error.raiseerror(verrmessage);
					ELSE
						vrow.profileid := vdestprofileid;
						vrow.groupid   := vdestgroupid;
						IF psaverecord
						THEN
							s.say(cmethodname || ': before insert');
							INSERT INTO tcontractprofilegroup VALUES vrow;
							s.say(cmethodname || ': inserted ' || SQL%ROWCOUNT);
						END IF;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						error.save(cmethodname);
						custom_contractexchangetools.log(custom_contractexchangetools.clogtype_error
														,psettings.packagename
														,psettings.objectname
														,vsourceprofileid
														,NULL
														,coalesce(error.getusertext
																 ,error.geterrortext));
				END;
			END LOOP;
		
			s.say('----------------end Profile Groups-------------------');
		
			s.say('-------------------Reduced rates----------------------');
			FOR redintsettingsrow IN (SELECT VALUE(p) xml
									  FROM   TABLE(xmlsequence(pxml.extract('//' ||
																			upper(psettings.objectname) || '/' ||
																			upper('tContractRedIntSettings') || '/' ||
																			upper('tContractRedIntSettings') ||
																			'_ROW'))) p)
			LOOP
				DECLARE
					verrmessage      VARCHAR2(1000);
					vdestprofileid   NUMBER;
					vdestgroupid     NUMBER;
					vsourceprofileid NUMBER;
					vdestrateid      NUMBER;
					vrow             tcontractredintsettings%ROWTYPE;
				BEGIN
					vrow.branch := cbranch;
				
					vrow.profileid := xmltools.getvalue(redintsettingsrow.xml
													   ,'//' || upper('tContractRedIntSettings') ||
														'_ROW' || '/PROFILEID');
					t.var('ProfileId', vrow.profileid);
					vsourceprofileid := vrow.profileid;
				
					vrow.groupid := xmltools.getvalue(redintsettingsrow.xml
													 ,'//' || upper('tContractRedIntSettings') ||
													  '_ROW' || '/GROUPID');
					t.var('GroupId', vrow.groupid);
				
					vrow.priority := xmltools.getvalue(redintsettingsrow.xml
													  ,'//' || upper('tContractRedIntSettings') ||
													   '_ROW' || '/PRIORITY');
					t.var('Priority', vrow.priority);
				
					vrow.terms := xmltools.getvalue(redintsettingsrow.xml
												   ,'//' || upper('tContractRedIntSettings') ||
													'_ROW' || '/TERMS');
					t.var('Terms', vrow.terms);
				
					vrow.amount := xmltools.getvalue(redintsettingsrow.xml
													,'//' || upper('tContractRedIntSettings') ||
													 '_ROW' || '/AMOUNT');
					t.var('Amount', vrow.amount);
				
					vrow.rateid := xmltools.getvalue(redintsettingsrow.xml
													,'//' || upper('tContractRedIntSettings') ||
													 '_ROW' || '/RATEID');
					t.var('RateId', vrow.rateid);
				
					vrow.reducedtermusage := xmltools.getvalue(redintsettingsrow.xml
															  ,'//' ||
															   upper('tContractRedIntSettings') ||
															   '_ROW' || '/REDUCEDTERMUSAGE');
					t.var('ReducedTermUsage', vrow.reducedtermusage);
				
					vdestprofileid := to_number(custom_contractexchangetools.getdestcode(creftable_profiles
																						,'ProfileId'
																						,vrow.profileid));
					IF vdestprofileid IS NULL
					THEN
						verrmessage := 'The profile was not found in the matching table [' ||
									   vrow.profileid || ']';
					END IF;
				
					vdestgroupid := to_number(custom_contractexchangetools.getdestcode('tContractEntryGroup'
																					  ,'GroupId'
																					  ,vrow.groupid));
					IF vdestgroupid IS NULL
					THEN
						verrmessage := verrmessage ||
									   service.iif(verrmessage IS NOT NULL, '; ', NULL) ||
									   'The entry group was not found in the matching table [' ||
									   vrow.groupid || ']';
					END IF;
				
					vdestrateid := to_number(custom_contractexchangetools.getdestcode('tPercentName'
																					 ,'Id'
																					 ,vrow.rateid));
					IF vdestrateid IS NULL
					THEN
						verrmessage := verrmessage ||
									   service.iif(verrmessage IS NOT NULL, '; ', NULL) ||
									   'The interest rate was not found in the matching table [' ||
									   vrow.rateid || ']';
					END IF;
				
					IF verrmessage IS NOT NULL
					THEN
						error.raiseerror(verrmessage);
					ELSE
						vrow.profileid := vdestprofileid;
						vrow.groupid   := vdestgroupid;
						vrow.rateid    := vdestrateid;
						IF psaverecord
						THEN
							s.say(cmethodname || ': before insert');
							INSERT INTO tcontractredintsettings VALUES vrow;
							s.say(cmethodname || ': inserted ' || SQL%ROWCOUNT);
						END IF;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						error.save(cmethodname);
						custom_contractexchangetools.log(custom_contractexchangetools.clogtype_error
														,psettings.packagename
														,psettings.objectname
														,vsourceprofileid
														,NULL
														,coalesce(error.getusertext
																 ,error.geterrortext));
				END;
			END LOOP;
			s.say('-----------------end Reduced rates--------------------');
		
			s.say('-------------------ImportParams----------------------');
			vimportsettings.packagename := cpackagename;
			vimportsettings.objectname := psettings.objectname;
			vimportsettings.tablename := 'None';
			vimportsettings.additionalsettings(vimportsettings.tablename).parametersobjecttype := 'CONTRACT_PROFILE';
			custom_contractexchangetools.importparams(pxml, vimportsettings);
			s.say('-----------------end ImportParams--------------------');
		
			s.say('-------------------PercentBelong----------------------');
			FOR percentbelong IN (SELECT VALUE(p) xml
								  FROM   TABLE(xmlsequence(pxml.extract('//' ||
																		upper(psettings.objectname) || '/' ||
																		upper(creftable_percents || '/' ||
																			  upper(creftable_percents) ||
																			  '_ROW')))) p)
			LOOP
				DECLARE
					verrmessage      VARCHAR2(1000);
					vdestprofileid   NUMBER;
					vdestpercentid   NUMBER;
					vsourceprofileid NUMBER;
					vrow             typepercentbelongrow;
				BEGIN
					vrow.branch := cbranch;
				
					vrow.objectno := xmltools.getvalue(percentbelong.xml
													  ,'//' || upper(creftable_percents) || '_ROW' ||
													   '/OBJECTNO');
					t.var('ObjectNo', vrow.objectno);
					vsourceprofileid := vrow.objectno;
				
					vrow.id := xmltools.getvalue(percentbelong.xml
												,'//' || upper(creftable_percents) || '_ROW' ||
												 '/ID');
					t.var('Id', vrow.id);
				
					vrow.category := xmltools.getvalue(percentbelong.xml
													  ,'//' || upper(creftable_percents) || '_ROW' ||
													   '/CATEGORY');
					t.var('Category', vrow.category);
				
					vrow.objectcat := xmltools.getvalue(percentbelong.xml
													   ,'//' || upper(creftable_percents) || '_ROW' ||
														'/OBJECTCAT');
					t.var('ObjectCat', vrow.objectcat);
				
					vdestprofileid := to_number(custom_contractexchangetools.getdestcode(creftable_profiles
																						,'ProfileId'
																						,vrow.objectno));
					IF vdestprofileid IS NULL
					THEN
						verrmessage := 'The profile was not found in the matching table [' ||
									   vrow.objectno || ']';
					END IF;
				
					vdestpercentid := to_number(custom_contractexchangetools.getdestcode('tPercentName'
																						,'Id'
																						,vrow.id));
					IF vdestpercentid IS NULL
					THEN
						verrmessage := verrmessage ||
									   service.iif(verrmessage IS NOT NULL, '; ', NULL) ||
									   'The interest rate was not found in the matching table [' ||
									   vrow.id || ']';
					END IF;
				
					IF verrmessage IS NOT NULL
					THEN
						error.raiseerror(verrmessage);
					ELSE
						vrow.objectno := vdestprofileid;
						vrow.id       := vdestpercentid;
						IF psaverecord
						THEN
							s.say(cmethodname || ': before insert');
							INSERT INTO tpercentbelong VALUES vrow;
							s.say(cmethodname || ': inserted ' || SQL%ROWCOUNT);
						END IF;
					END IF;
				EXCEPTION
					WHEN OTHERS THEN
						error.save(cmethodname);
						custom_contractexchangetools.log(custom_contractexchangetools.clogtype_error
														,psettings.packagename
														,psettings.objectname
														,vsourceprofileid
														,NULL
														,coalesce(error.getusertext
																 ,error.geterrortext));
				END;
			END LOOP;
			s.say('-----------------end PercentBelong--------------------');
		END IF;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			ROLLBACK TO sp_profilesimport;
			RAISE;
	END;

END custom_contractprofiles;
/
