CREATE OR REPLACE PACKAGE custom_overdueparameterscalculation IS

	sheaderversion CONSTANT VARCHAR2(100) := '2.1.7.180405';

	TYPE typetrxnandcyclerec IS RECORD(
		 branch              tcontract.branch%TYPE
		,contractno          tcontract.no%TYPE
		,statementdate       tcontractstcycle.statementdate%TYPE
		,trxndate            tcontracttrxnlist.postdate%TYPE
		,debitamount         tcontracttrxnlist.amount%TYPE
		,creditamount        tcontracttrxnlist.amount%TYPE
		,reversedebitamount  tcontracttrxnlist.amount%TYPE
		,reversecreditamount tcontracttrxnlist.amount%TYPE
		,currencynumber      tcontractstminpaymentdata.currencynumber%TYPE
		,packno              tcontracttrxnlist.packno%TYPE
		,contracttype        tcontract.type%TYPE
		,duedate             tcontractstcycle.duedate%TYPE
		,recno               tcontracttrxnlist.recno%TYPE
		,minpayment          tcontractstminpaymentdata.minpayment%TYPE
		,sdamount            NUMBER
		,createdate          tcontract.createdate%TYPE
		,lastduedate         tcontractstcycle.lastduedate%TYPE
		,nextstatementdate   tcontractstcycle.nextstatementdate%TYPE);
	TYPE typetrxnandcyclearray IS TABLE OF typetrxnandcyclerec INDEX BY BINARY_INTEGER;
	strxnandcyclearray typetrxnandcyclearray;

	TYPE typeoverdueparamsrecord IS RECORD(
		 overduedate   DATE
		,mp_payoffdate DATE
		,dueamount     NUMBER
		,overdueamount NUMBER
		,
		
		overdueamount_onduedate NUMBER
		,
		
		unpaidsdamountonpdate NUMBER
		,unpaidsdamountonddate NUMBER);

	TYPE typeminpaymentstdata IS TABLE OF vcontractstcyclempdata%ROWTYPE INDEX BY BINARY_INTEGER;

	TYPE typecacherecord IS RECORD(
		 minpaymentstdataarray         typeminpaymentstdata
		,lastaggrtrxnarrayforlastcycle typeaggregatedtrxn_varr
		,lastaggrtrxnrowforlastcycle   typeaggregatedtrxn_obj
		,minpayment_spec               tcontractstminpaymentdata.minpayment%TYPE
		,sdamount_spec                 tcontractstminpaymentdata.sdamount%TYPE
		,mp_payoffdate                 DATE
		,overduedate                   DATE
		,dueamount                     NUMBER
		,overdueamount                 NUMBER
		,unpaidsdamountonpdate         NUMBER
		,unpaidsdamountonddate         NUMBER
		,
		
		overdueamount_onduedate NUMBER
		,
		
		overdueamountarray typepaidhistarray);

	TYPE typecache IS TABLE OF typecacherecord INDEX BY VARCHAR2(50);
	scache typecache;

	TYPE typeupdatestminpaymdata_record IS RECORD(
		 screcno                  tcontractstminpaymentdata.screcno%TYPE
		,repayment_atcycleend     tcontractstminpaymentdata.repayment_atcycleend%TYPE
		,overdueamount_onduedate  tcontractstminpaymentdata.overdueamount_onduedate%TYPE
		,unpaidsdamount_onduedate tcontractstminpaymentdata.unpaidsdamount_onduedate%TYPE
		,aggregatedtrxn           tcontractstminpaymentdata.aggregatedtrxn%TYPE
		,prevmpovd_onduedate      tcontractstminpaymentdata.prevmpovd_onduedate%TYPE
		,mp_payoffdate_atcycleend tcontractstminpaymentdata.mp_payoffdate_atcycleend%TYPE);

	TYPE typeprepareddataforupd_arr IS TABLE OF typeupdatestminpaymdata_record INDEX BY VARCHAR2(50);
	sprepareddataforupd typeprepareddataforupd_arr;

	shlog NUMBER;

	PROCEDURE wlog(pstr VARCHAR2);

	PROCEDURE sdbalancescalculation
	(
		plogfilepath    VARCHAR2
	   ,pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE
	   ,pcontracttype   tcontracttype.type%TYPE := NULL
	   ,pcontractno     tcontract.no%TYPE := NULL
		
	   ,pnewcontractmode BOOLEAN := FALSE
		
	);

	PROCEDURE paidhistorymigration
	(
		plogfilepath    VARCHAR2
	   ,pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE
	   ,pcontracttype   tcontracttype.type%TYPE := NULL
	   ,pcontractno     tcontract.no%TYPE := NULL
		
	   ,pnewcontractmode BOOLEAN := FALSE
		
	);

	PROCEDURE paidhistorymigration_mscc
	(
		plogfilepath    VARCHAR2
	   ,pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE
	   ,pcontracttype   tcontracttype.type%TYPE := NULL
	   ,pcontractno     tcontract.no%TYPE := NULL
	);

	PROCEDURE fillstminpaymentdataarrays
	(
		paccountno      IN taccount.accountno%TYPE
	   ,pcurrencynumber IN tcontractstminpaymentdata.currencynumber%TYPE
	   ,pdate           DATE
	   ,pstatementdate  IN DATE := NULL
	);

	PROCEDURE prepareupd_contrstminpaymdata
	(
		pcontractno     tcontract.no%TYPE
	   ,paccountno      taccount.accountno%TYPE
	   ,pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE
	   ,ppackno         tcontracttrxnlist.packno%TYPE
	   ,ptrxndate       tcontracttrxnlist.postdate%TYPE
	   ,ptrxnamount     tcontracttrxnlist.amount%TYPE
	   ,ptrxntype       tcontracttrxnlist.trantype%TYPE
	   ,pnowstdate      BOOLEAN
	   ,pnowduedate     BOOLEAN
	);

	PROCEDURE rollbackaggregatedtrxn
	(
		paccountno       taccount.accountno%TYPE
	   ,pcurrencynumber  tcontractstminpaymentdata.currencynumber%TYPE
	   ,ppackno          tcontracttrxnlist.packno%TYPE
	   ,pifduedate       BOOLEAN
	   ,pifstatementdate BOOLEAN
	);

	FUNCTION getoverdueparameters
	(
		paccountno           taccount.accountno%TYPE
	   ,pcurrencynumber      tcontractstminpaymentdata.currencynumber%TYPE
	   ,pdate                DATE
	   ,pconsideroverduefrom NUMBER
	   ,ooverdueparameters   OUT typeoverdueparamsrecord
	) RETURN typepaidhistarray;

	PROCEDURE update_contrstminpaymentdata
	(
		pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE
	   ,pnowstdate      BOOLEAN
	   ,pnowduedate     BOOLEAN
	   ,pcacheindex     VARCHAR2
		
	);

	PROCEDURE clearcache(pcacheindex VARCHAR2 := NULL);

	FUNCTION getcycleallattrarray
	(
		pcontractno     tcontract.no%TYPE
	   ,pdate           DATE
	   ,pcurrencynumber NUMBER
	) RETURN typeminpaymentstdata;

	TYPE typeoverdueremainsrecord IS RECORD(
		 operdate      DATE
		,overdueamount NUMBER);
	TYPE typeoverdueremainsarray IS TABLE OF typeoverdueremainsrecord INDEX BY BINARY_INTEGER;

	FUNCTION getoverdueremains
	(
		pcontractno     tcontract.no%TYPE
	   ,pdate           DATE
	   ,paccountno      taccount.accountno%TYPE
	   ,pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE
	) RETURN typeoverdueremainsarray;

	TYPE typeverificationrow_record IS RECORD(
		 operdate   VARCHAR2(100)
		,contractno tcontracttrxnlist.contractno%TYPE
		,accountno  tcontracttrxnlist.accountno%TYPE
		,packno     tcontracttrxnlist.packno%TYPE
		,recno      tcontracttrxnlist.recno%TYPE
		,trantype   tcontracttrxnlist.trantype%TYPE
		,trandate   tcontracttrxnlist.trandate%TYPE
		,postdate   tcontracttrxnlist.postdate%TYPE
		,amount     tcontracttrxnlist.amount%TYPE);

	PROCEDURE fillverificationarray(pverificationrow typeverificationrow_record);

	PROCEDURE transactionverification
	(
		pdataforupdate typeupdatestminpaymdata_record
	   ,pcacheindex    VARCHAR2
	);

	PROCEDURE clearverificationarray;

	FUNCTION getlastpassedcycleinfo
	(
		paccountno      IN taccount.accountno%TYPE
	   ,pcurrencynumber IN tcontractstminpaymentdata.currencynumber%TYPE
	   ,pdate           IN DATE
	) RETURN vcontractstcyclempdata%ROWTYPE;

	TYPE type_repaym_unpaid_amnts_rec IS RECORD(
		 minpayment       NUMBER
		,mp_repayment     NUMBER
		,unpaidmp         NUMBER
		,sdamount         NUMBER
		,sd_repayment     NUMBER
		,unpaidsdamount   NUMBER
		,revdebitoverplus NUMBER
		,paid             NUMBER);

	FUNCTION getrepaymentamounts
	(
		paccountno      IN taccount.accountno%TYPE
	   ,pcurrencynumber IN tcontractstminpaymentdata.currencynumber%TYPE
	   ,pdate           DATE
	   ,pstatementdate  IN DATE := NULL
	) RETURN type_repaym_unpaid_amnts_rec;

END custom_overdueparameterscalculation;
/
CREATE OR REPLACE PACKAGE BODY custom_overdueparameterscalculation IS

	cpackagename CONSTANT VARCHAR2(30) := 'OverdueParametersCalculation';
	cbodyversion CONSTANT VARCHAR2(50) := '2.2.4.180405';

	sovdhistoryarray typepaidhistarray;

	TYPE typeverificationrow_array IS TABLE OF typeverificationrow_record INDEX BY BINARY_INTEGER;
	sverificationarray typeverificationrow_array;

	PROCEDURE clearredundantcacherow;

	PROCEDURE wlog(pstr VARCHAR2) IS
	BEGIN
		IF shlog IS NOT NULL
		THEN
			term.writerecord(shlog
							,to_char(systimestamp, 'YYYY-MM-DD HH24:MI:SS.FF3') || ': ' || pstr);
		END IF;
	END wlog;

	PROCEDURE sdbalancescalculation
	(
		plogfilepath    VARCHAR2
	   ,pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE
	   ,pcontracttype   tcontracttype.type%TYPE := NULL
	   ,pcontractno     tcontract.no%TYPE := NULL
		
	   ,pnewcontractmode BOOLEAN := FALSE
		
	) IS
		cmethodname CONSTANT VARCHAR2(90) := cpackagename || '.SDBalancesCalculation';
		cbranch     CONSTANT NUMBER := custom_seance.getbranch;
	
		vsqlerrm VARCHAR2(4000);
		vsqlcode VARCHAR2(30);
	
		vnextstmigrdate tcontractstcycle.statementdate%TYPE;
		vmigrdate       tcontractstcycle.statementdate%TYPE;
		vminpayment     tcontractstminpaymentdata.minpayment%TYPE;
	
	BEGIN
		custom_s.say('   ' || cmethodname || '  --<< BEGIN', 1);
		custom_s.say('   ' || cmethodname || '   -> INPUT PARAMETERS: ', 1);
		custom_s.say('   ' || cmethodname || '    - Log File Path (pLogFilePath) = ' ||
					 plogfilepath
					,1);
		custom_s.say('   ' || cmethodname || '    - Currency Number (pCurrencyNumber) = ' ||
					 pcurrencynumber
					,1);
		custom_s.say('   ' || cmethodname || '    - Contract Type  (pContractType) = ' ||
					 pcontracttype || ', [null means ALL TYPES SHOULD BE chosen]'
					,1);
		custom_s.say('   ' || cmethodname || '    - Contract Number  (pContractNo) = ' ||
					 pcontractno || ', [null means ALL CONTRACTS SHOULD BE chosen]'
					,1);
		custom_s.say('', 1);
	
		IF plogfilepath IS NOT NULL
		THEN
			wlog('   BEGIN');
			wlog('     <Statement Date balances calculation>');
			wlog('     Input Parameters: currency = ' || pcurrencynumber || ', contract type = ' ||
				 pcontracttype || ', contract number = ' || pcontractno || ', pNewContractMode = ' ||
				 service.iif(pnewcontractmode, 'YES', 'NO'));
		END IF;
	
		DELETE FROM tpaidhistmigrsdbalance
		WHERE  branch = cbranch
		AND    contracttype = pcontracttype
		AND    currencynumber = pcurrencynumber
		AND    CASE
				  WHEN pcontractno IS NOT NULL THEN
				   contractno
				  ELSE
				   '1'
			  END = CASE
				   WHEN pcontractno IS NOT NULL THEN
					pcontractno
				   ELSE
					'1'
			   END;
		custom_s.say('   ' || cmethodname ||
					 '   tPaidHistMigrSDBalance is cleared, deleted row number = ' || SQL%ROWCOUNT
					,1);
		IF plogfilepath IS NOT NULL
		THEN
			wlog('     tPaidHistMigrSDBalance is cleared, deleted row number = ' || SQL%ROWCOUNT);
		END IF;
	
		INSERT INTO tpaidhistmigrsdbalance
			SELECT DISTINCT branch
						   ,contractno
						   ,contracttype
						   ,currencynumber
						   ,statementdate
						   ,SUM(-debitamount + creditamount + reversedebitamount -
								reversecreditamount) over(PARTITION BY branch, contracttype, contractno, currencynumber ORDER BY branch, contracttype, contractno, currencynumber, statementdate) sdamount
			FROM   (SELECT ctl.branch
						  ,ctl.contractno
						  ,ctin.contracttype
						  ,ctl.postdate trxndate
						  ,SUM(CASE
								   WHEN ctl.trantype = 1 THEN
									ctl.amount
								   ELSE
									0
							   END) debitamount
						  ,SUM(CASE
								   WHEN ctl.trantype = 3 THEN
									ctl.amount
								   ELSE
									0
							   END) creditamount
						  ,SUM(CASE
								   WHEN ctl.trantype = 4 THEN
									ctl.amount
								   ELSE
									0
							   END) reversedebitamount
						  ,SUM(CASE
								   WHEN ctl.trantype = 2 THEN
									ctl.amount
								   ELSE
									0
							   END) reversecreditamount
						  ,(SELECT MIN(csc.statementdate)
							FROM   tcontractstcycle csc
							WHERE  csc.branch = ctl.branch
							AND    csc.contractno = ctl.contractno
							AND    csc.statementdate >= ctl.postdate) statementdate
						  ,CASE
							   WHEN ctin.itemname = 'ITEMDEPOSITDOM' THEN
								1
							   WHEN ctin.itemname = 'ITEMDEPOSITINT' THEN
								2
							   ELSE
								-1
						   END currencynumber
						  ,ctl.packno
					FROM   tcontracttypeitemname ctin
						  ,tcontractitem         ci
						  ,tcontracttrxnlist     ctl
					WHERE  ctin.branch = cbranch
					AND    ctin.contracttype = pcontracttype
					AND    ctin.itemname LIKE 'ITEMDEPOSIT%'
					AND    ctin.branch = ci.branch
					AND    ctin.itemcode = ci.itemcode
					AND    ctl.branch = ci.branch
					AND    ctl.contractno = ci.no
					AND    ctl.accountno = ci.key
					GROUP  BY ctl.branch
							 ,ctl.contractno
							 ,ctin.contracttype
							 ,ctin.contracttype
							 ,ctl.postdate
							 ,ctin.itemname
							 ,ctl.packno
					
					UNION ALL
					
					SELECT csmpd.branch
						  ,csc.contractno
						  ,ctin.contracttype
						  ,csc.statementdate    trxndate
						  ,0                    debitamount
						  ,0                    creditamount
						  ,0                    reversedebitamount
						  ,0                    reversecreditamount
						  ,csc.statementdate    statementdate
						  ,csmpd.currencynumber
						  ,0                    packno
					FROM   tcontractstminpaymentdata csmpd
						  ,tcontractstcycle          csc
						  ,tcontractitem             ci
						  ,tcontracttypeitemname     ctin
					WHERE  ctin.branch = cbranch
					AND    ctin.contracttype = pcontracttype
					AND    ctin.itemname LIKE 'ITEMDEPOSIT%'
					AND    ctin.branch = ci.branch
					AND    ctin.itemcode = ci.itemcode
					AND    csc.branch = ci.branch
					AND    csc.contractno = ci.no
					AND    csmpd.branch = csc.branch
					AND    csmpd.screcno = csc.recno
					AND    csmpd.currencynumber = pcurrencynumber
					AND    csmpd.currencynumber = CASE
							   WHEN ctin.itemname = 'ITEMDEPOSITDOM' THEN
								1
							   WHEN ctin.itemname = 'ITEMDEPOSITINT' THEN
								2
							   ELSE
								-1
						   END
					
					)
			WHERE  statementdate IS NOT NULL
			AND    currencynumber = pcurrencynumber
			AND    CASE
					  WHEN pcontractno IS NOT NULL THEN
					   contractno
					  ELSE
					   '1'
				  END = CASE
					   WHEN pcontractno IS NOT NULL THEN
						pcontractno
					   ELSE
						'1'
				   END;
		IF plogfilepath IS NOT NULL
		THEN
			wlog('     Statement Date Balances has been calculated succesfully, rows inserted : ' ||
				 SQL%ROWCOUNT);
		END IF;
		custom_s.say('   Statement Date Balances has been calculated succesfully, rows inserted : ' ||
					 SQL%ROWCOUNT
					,1);
		IF plogfilepath IS NOT NULL
		THEN
			COMMIT;
		END IF;
	
		IF pnewcontractmode
		   AND pcontractno IS NOT NULL
		THEN
			IF plogfilepath IS NOT NULL
			THEN
				wlog('     Since SD balance is calculated in `New contract mode` then for some cycles SD balance should be set equal to minimum payment');
			END IF;
		
			vnextstmigrdate := to_date(contractparams.loadchar(contractparams.ccontract
															  ,pcontractno
															  ,upper('NextStmtDate')
															  ,FALSE)
									  ,contractparams.cparam_date_format);
			vmigrdate       := NULL;
			SELECT MIN(statementdate)
			INTO   vmigrdate
			FROM   tcontractstcycle
			WHERE  branch = cbranch
			AND    contractno = pcontractno
			AND    nextstatementdate = vnextstmigrdate;
			IF plogfilepath IS NOT NULL
			THEN
				wlog(' vNextStMigrDate = ' || to_char(vnextstmigrdate, 'dd.mm.yyyy') ||
					 ', vMigrDate = ' || to_char(vmigrdate, 'dd.mm.yyyy'));
			END IF;
		
			UPDATE tcontract
			SET    createdate =
				   (SELECT trunc(MIN(nextstatementdate), 'mm')
					FROM   tcontractstcycle
					WHERE  branch = cbranch
					AND    contractno = pcontractno)
			WHERE  branch = cbranch
			AND    no = pcontractno;
		
			IF vmigrdate IS NOT NULL
			THEN
			
				FOR cc IN (SELECT *
						   FROM   tpaidhistmigrsdbalance
						   WHERE  branch = cbranch
						   AND    contractno = pcontractno
						   AND    contracttype = pcontracttype
						   AND    currencynumber = pcurrencynumber)
				LOOP
				
					IF cc.statementdate <= vmigrdate
					THEN
					
						IF cc.statementdate = vmigrdate
						THEN
						
							IF pcurrencynumber = 1
							THEN
								vminpayment := least(contracttools.get_eod_remain(contract.getaccountnobyitemname(pcontractno
																												 ,'ITEMDEPOSITDOM')
																				 ,vmigrdate
																				 ,pcheckemptyaccno => TRUE)
													,0);
							ELSE
								vminpayment := least(contracttools.get_eod_remain(contract.getaccountnobyitemname(pcontractno
																												 ,'ITEMDEPOSITINT')
																				 ,vmigrdate
																				 ,pcheckemptyaccno => TRUE)
													,0);
							END IF;
						
						ELSE
						
							SELECT -csmpd.minpayment
							INTO   vminpayment
							FROM   tcontractstcycle          csc
								  ,tcontractstminpaymentdata csmpd
							WHERE  csc.branch = cc.branch
							AND    csc.contractno = cc.contractno
							AND    csc.statementdate = cc.statementdate
							AND    csmpd.branch = csc.branch
							AND    csmpd.screcno = csc.recno
							AND    csmpd.currencynumber = cc.currencynumber;
						
						END IF;
					
						UPDATE tpaidhistmigrsdbalance
						SET    sdamount = vminpayment
						WHERE  branch = cc.branch
						AND    contractno = cc.contractno
						AND    contracttype = cc.contracttype
						AND    currencynumber = cc.currencynumber
						AND    statementdate = cc.statementdate;
					
						IF plogfilepath IS NOT NULL
						THEN
							wlog('      Statement date = ' ||
								 to_char(cc.statementdate, 'dd.mm.yyyy') || ', New SD amount = ' ||
								 (-1) * vminpayment);
						END IF;
					
					END IF;
				
				END LOOP;
			
			END IF;
		
			IF plogfilepath IS NOT NULL
			THEN
				wlog(' ');
				COMMIT;
			END IF;
		
		END IF;
	
		IF plogfilepath IS NOT NULL
		THEN
			wlog('   END');
		END IF;
	
		custom_s.say('   ' || cmethodname || '  -->> END', 1);
		custom_s.say('', 1);
	EXCEPTION
		WHEN OTHERS THEN
			IF plogfilepath IS NOT NULL
			THEN
				vsqlcode := SQLCODE;
				vsqlerrm := SQLERRM || ' ' || dbms_utility.format_error_backtrace;
				custom_s.say('<SDBalancesCalculation> ' || vsqlcode || '  ' || vsqlerrm, 1);
				wlog('<SDBalancesCalculation> ' || vsqlcode || '  ' || vsqlerrm);
				INSERT INTO tpaidhistorymigrerr
				VALUES
					(NULL
					,cbranch
					,pcontractno
					,pcontracttype
					,pcurrencynumber
					,'<SDBalancesCalculation> ' || vsqlcode || '  ' || vsqlerrm
					,NULL);
			ELSE
				error.raiseerror(cmethodname);
			END IF;
	END sdbalancescalculation;

	PROCEDURE paidhistorymigration
	(
		plogfilepath    VARCHAR2
	   ,pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE
	   ,pcontracttype   tcontracttype.type%TYPE := NULL
	   ,pcontractno     tcontract.no%TYPE := NULL
		
	   ,pnewcontractmode BOOLEAN := FALSE
		
	) IS
	
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.PaidHistoryMigration';
		cbranch     CONSTANT NUMBER := custom_seance.getbranch;
	
		vcontractno tcontract.no%TYPE;
	
		vdebitamount     NUMBER := 0;
		vcreditamount    NUMBER := 0;
		vrevdebitamount  NUMBER := 0;
		vrevcreditamount NUMBER := 0;
	
		vreduceddebit     NUMBER := 0;
		vdelta            NUMBER := 0;
		vpaidamount       NUMBER := 0;
		vrevdebitoverplus NUMBER := 0;
	
		vtrxndate DATE;
		vpackno   NUMBER;
	
		TYPE typeminpayment IS TABLE OF tcontractstminpaymentdata.minpayment%TYPE INDEX BY BINARY_INTEGER;
		vminpaymentarray typeminpayment;
		vminpayment      NUMBER;
		TYPE typerepayment_atcycleend IS TABLE OF tcontractstminpaymentdata.repayment_atcycleend%TYPE INDEX BY BINARY_INTEGER;
		vrepayment_atcycleendarrary typerepayment_atcycleend;
		vrepayment                  NUMBER := 0;
		TYPE typeunpaidsdamount_onduedate IS TABLE OF tcontractstminpaymentdata.unpaidsdamount_onduedate%TYPE INDEX BY BINARY_INTEGER;
		vunpaidsdamount_onduedatearray typeunpaidsdamount_onduedate;
	
		TYPE typeoverdueamount_onduedate IS TABLE OF tcontractstminpaymentdata.overdueamount_onduedate%TYPE INDEX BY BINARY_INTEGER;
		voverdueamount_onduedatearray typeoverdueamount_onduedate;
		TYPE typeprevmpovd_onduedate IS TABLE OF tcontractstminpaymentdata.prevmpovd_onduedate%TYPE INDEX BY BINARY_INTEGER;
		vprevmpovd_onduedatearray typeprevmpovd_onduedate;
	
		TYPE typesdamount IS TABLE OF tcontractstminpaymentdata.sdamount%TYPE INDEX BY BINARY_INTEGER;
		vsdamountarray typesdamount;
		vsdamount      NUMBER := 0;
		TYPE typeaggregatedtrxn IS TABLE OF tcontractstminpaymentdata.aggregatedtrxn%TYPE INDEX BY BINARY_INTEGER;
		vaggregatedtrxnarray typeaggregatedtrxn;
		vaggregatedtrxnrow   typeaggregatedtrxn_obj;
		vaggregatedtrxnvarr  typeaggregatedtrxn_varr := NEW typeaggregatedtrxn_varr();
		vindex               NUMBER := 0;
		TYPE typerecno IS TABLE OF tcontractstminpaymentdata.screcno%TYPE INDEX BY BINARY_INTEGER;
		vrecnoarray typerecno;
		vrecno      tcontractstcycle.recno%TYPE := NULL;
		TYPE typebranch IS TABLE OF tcontractstminpaymentdata.branch%TYPE INDEX BY BINARY_INTEGER;
		vbrancharray typebranch;
		TYPE typecurrencynumber IS TABLE OF tcontractstminpaymentdata.currencynumber%TYPE INDEX BY BINARY_INTEGER;
		vcurrencynumberarray typecurrencynumber;
		TYPE typemppayoffdate_atcycleend IS TABLE OF tcontractstminpaymentdata.mp_payoffdate_atcycleend%TYPE INDEX BY BINARY_INTEGER;
		vmppayoffdate_atcycleendarray typemppayoffdate_atcycleend;
		vmppayoffdate                 DATE := NULL;
	
		vstatementdate tcontractstcycle.statementdate%TYPE := NULL;
	
		i tcontractstminpaymentdata.screcno%TYPE;
	
		vtotalcontractcounter NUMBER := 0;
		verrorcontractcounter NUMBER := 0;
	
		vsqlerrm VARCHAR2(4000);
		vsqlcode VARCHAR2(30);
	
		vhandledcontrcounter NUMBER := 0;
		verrcontrcounter     NUMBER := 0;
	
		PROCEDURE updateminpaymentdata(pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE) IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.PaidHistoryMigration.UpdateMinPaymentData';
		
		BEGIN
			custom_s.say('     ' || cmethodname || ' --<< BEGIN', 1);
			custom_s.say('     ' || cmethodname ||
						 '  - INPUT PARAMETERS: currency number (pCurrencyNumber) = ' ||
						 pcurrencynumber
						,1);
		
			IF MOD(vtotalcontractcounter, 1000) = 0
			THEN
				IF plogfilepath IS NOT NULL
				THEN
					COMMIT;
				END IF;
			END IF;
		
			custom_s.say('### - ### --> vRepayment_AtCycleEndArrary.last = ' ||
						 vrepayment_atcycleendarrary.last
						,1);
			custom_s.say('### - ### --> vUnpaidSDAmount_OnDueDateArray.last = ' ||
						 vunpaidsdamount_onduedatearray.last
						,1);
			custom_s.say('### - ### --> vOverdueAmount_OnDueDateArray.last = ' ||
						 voverdueamount_onduedatearray.last
						,1);
			custom_s.say('### - ### --> vPrevMPOvd_OnDueDateArray.last = ' ||
						 vprevmpovd_onduedatearray.last
						,1);
			custom_s.say('### - ### --> vSDAmountArray.last = ' || vsdamountarray.last, 1);
			custom_s.say('### - ### --> vMPPayOffDate_AtCycleEndArray.last = ' ||
						 vmppayoffdate_atcycleendarray.last
						,1);
			custom_s.say('### - ### --> vAggregatedTrxnArray.last = ' || vaggregatedtrxnarray.last
						,1);
			custom_s.say('### - ### --> vBranchArray.last = ' || vbrancharray.last, 1);
			custom_s.say('### - ### --> vRecNoArray.last = ' || vrecnoarray.last, 1);
		
			FORALL j IN INDICES OF vrecnoarray
				UPDATE tcontractstminpaymentdata
				SET    repayment_atcycleend     = vrepayment_atcycleendarrary(j)
					  ,unpaidsdamount_onduedate = vunpaidsdamount_onduedatearray(j)
					  ,
					   
					   overdueamount_onduedate = voverdueamount_onduedatearray(j)
					  ,prevmpovd_onduedate     = vprevmpovd_onduedatearray(j)
					  ,
					   
					   sdamount                 = vsdamountarray(j)
					  ,mp_payoffdate_atcycleend = vmppayoffdate_atcycleendarray(j)
					  ,aggregatedtrxn           = vaggregatedtrxnarray(j)
				WHERE  branch = vbrancharray(j)
				AND    screcno = vrecnoarray(j)
				AND    currencynumber = pcurrencynumber;
		
			custom_s.say('     ' || cmethodname || '   Rows updated (sql%rowcount) = ' ||
						 SQL%ROWCOUNT
						,1);
		
			vmppayoffdate_atcycleendarray.delete;
		
			vminpaymentarray.delete;
			vrepayment_atcycleendarrary.delete;
			vunpaidsdamount_onduedatearray.delete;
		
			voverdueamount_onduedatearray.delete;
			vprevmpovd_onduedatearray.delete;
		
			vsdamountarray.delete;
			vaggregatedtrxnarray.delete;
			vrecnoarray.delete;
			vbrancharray.delete;
			vcurrencynumberarray.delete;
			vindex              := 0;
			vaggregatedtrxnvarr := NEW typeaggregatedtrxn_varr();
			vmppayoffdate       := NULL;
		
			vrecno         := NULL;
			vstatementdate := NULL;
		
			vhandledcontrcounter := vhandledcontrcounter + 1;
			IF plogfilepath IS NOT NULL
			THEN
				wlog(vcontractno || ' SAVED');
			END IF;
			custom_s.say('     ' || cmethodname || '   DATA FOR OLD CONTRACT WERE SAVED', 1);
			custom_s.say('     ' || cmethodname || ' -->> END', 1);
			custom_s.say('', 1);
		EXCEPTION
			WHEN OTHERS THEN
				verrcontrcounter      := verrcontrcounter + 1;
				verrorcontractcounter := verrorcontractcounter + 1;
				vsqlcode              := vsqlcode;
				vsqlerrm              := SQLERRM || ' ' || dbms_utility.format_error_backtrace;
				custom_s.say('<UpdateMinPaymentData> ' || vsqlcode || '  ' || vsqlerrm);
				INSERT INTO tpaidhistorymigrerr
				VALUES
					(vrecno
					,cbranch
					,vcontractno
					,pcontracttype
					,pcurrencynumber
					,'<UpdateMinPaymentData> ' || vsqlcode || '  ' || vsqlerrm
					,vtotalcontractcounter);
			
				vmppayoffdate_atcycleendarray.delete;
				vminpaymentarray.delete;
				vrepayment_atcycleendarrary.delete;
				vunpaidsdamount_onduedatearray.delete;
				voverdueamount_onduedatearray.delete;
				vprevmpovd_onduedatearray.delete;
				vsdamountarray.delete;
				vaggregatedtrxnarray.delete;
				vrecnoarray.delete;
				vbrancharray.delete;
				vcurrencynumberarray.delete;
			
		END updateminpaymentdata;
	
	BEGIN
		IF plogfilepath IS NOT NULL
		THEN
			shlog := term.fileopenwrite(plogfilepath || '-MAIN' || '-CUR-' || pcurrencynumber || '-' ||
										to_char(SYSDATE, ' YYYY-MM-DD HH24-MI-SS') || ', -CT-' ||
										pcontracttype || '-C-' || pcontractno || '.log');
			wlog('BEGIN');
			wlog('Input Parameters: currency = ' || pcurrencynumber || ', contract type = ' ||
				 pcontracttype || ', contract number = ' || pcontractno);
		END IF;
		custom_s.say(cmethodname || ' --<< BEGIN', 1);
		custom_s.say(cmethodname || '   -- INPUT PARAMETERS:', 1);
		custom_s.say(cmethodname || '    -> pLogFilePath = ' || plogfilepath || ', cBranch = ' ||
					 cbranch || ', pCurrencyNumber = ' || pcurrencynumber || ', pContractType = ' ||
					 pcontracttype || ', pContractNo = ' || pcontractno
					,1);
		custom_s.say('', 1);
	
		DELETE FROM tpaidhistorymigrerr
		WHERE  currencynumber = pcurrencynumber
		AND    contracttype = nvl(pcontracttype, contracttype)
		AND    nvl(contractno, '') = nvl(pcontractno, nvl(contractno, ''));
		IF plogfilepath IS NOT NULL
		THEN
			wlog('Clear rows with old errors. Rows deleted : ' || SQL%ROWCOUNT);
		END IF;
		custom_s.say('    Clear rows with old errors. Rows deleted : ' || SQL%ROWCOUNT, 1);
	
		sdbalancescalculation(plogfilepath
							 ,pcurrencynumber
							 ,pcontracttype
							 ,pcontractno
							 ,pnewcontractmode);
	
		SELECT sq.branch
			  ,sq.contractno
			  ,sq.statementdate
			  ,sq.trxndate
			  ,sq.debitamount
			  ,sq.creditamount
			  ,sq.reversedebitamount
			  ,sq.reversecreditamount
			  ,sq.currencynumber
			  ,sq.packno
			  ,sq.contracttype
			  ,csc.duedate
			  ,csc.recno
			  ,csmpd.minpayment
			  ,phmb.sdamount
			  ,c.createdate
			  ,csc.lastduedate
			  ,csc.nextstatementdate BULK COLLECT
		INTO   strxnandcyclearray
		FROM   tcontract c
			  ,tpaidhistmigrsdbalance phmb
			  ,tcontractstminpaymentdata csmpd
			  ,tcontractstcycle csc
			  ,(SELECT ctl.branch
					  ,ctl.contractno
					  ,ctl.postdate trxndate
					  ,CASE
						   WHEN ctl.trantype = 1 THEN
							ctl.amount
						   ELSE
							0
					   END debitamount
					  ,CASE
						   WHEN ctl.trantype = 3 THEN
							ctl.amount
						   ELSE
							0
					   END creditamount
					  ,CASE
						   WHEN ctl.trantype = 4 THEN
							ctl.amount
						   ELSE
							0
					   END reversedebitamount
					  ,CASE
						   WHEN ctl.trantype = 2 THEN
							ctl.amount
						   ELSE
							0
					   END reversecreditamount
					  ,(SELECT MAX(csc.statementdate)
						FROM   tcontractstcycle csc
						WHERE  csc.branch = ctl.branch
						AND    csc.contractno = ctl.contractno
						AND    csc.statementdate < ctl.postdate) statementdate
					  ,CASE
						   WHEN ctin.itemname = 'ITEMDEPOSITDOM' THEN
							1
						   WHEN ctin.itemname = 'ITEMDEPOSITINT' THEN
							2
						   ELSE
							-1
					   END currencynumber
					  ,ctl.packno
					  ,ctin.contracttype
					  ,ctl.recno
				FROM   tcontracttypeitemname ctin
					  ,tcontractitem         ci
					  ,tcontracttrxnlist     ctl
				WHERE  ctin.branch = cbranch
				AND    ctin.contracttype = pcontracttype
				AND    ctin.itemname LIKE 'ITEMDEPOSIT%'
				AND    ctin.branch = ci.branch
				AND    ctin.itemcode = ci.itemcode
				AND    ctl.branch = ci.branch
				AND    ctl.contractno = ci.no
				AND    ctl.accountno = ci.key
				GROUP  BY ctl.branch
						 ,ctl.contractno
						 ,ctl.postdate
						 ,ctin.itemname
						 ,ctl.packno
						 ,ctin.contracttype
						 ,ctl.trantype
						 ,ctl.recno
						 ,ctl.amount
				
				UNION ALL
				
				SELECT csmpd.branch
					  ,csc.contractno
					  ,CASE
						   WHEN csc.lastduedate IS NOT NULL THEN
							csc.duedate
						   ELSE
							csc.statementdate + 1
					   END trxndate
					  ,0 debitamount
					  ,0 creditamount
					  ,0 reversedebitamount
					  ,0 reversecreditamount
					  ,csc.statementdate statementdate
					  ,csmpd.currencynumber
					  ,0 packno
					  ,ctin.contracttype
					  ,0 recno
				FROM   tcontractstminpaymentdata csmpd
					  ,tcontractstcycle          csc
					  ,tcontractitem             ci
					  ,tcontracttypeitemname     ctin
				WHERE  ctin.branch = cbranch
				AND    ctin.contracttype = pcontracttype
				AND    ctin.itemname LIKE 'ITEMDEPOSIT%'
				AND    ctin.branch = ci.branch
				AND    ctin.itemcode = ci.itemcode
				AND    csc.branch = ci.branch
				AND    csc.contractno = ci.no
				AND    csmpd.branch = csc.branch
				AND    csmpd.screcno = csc.recno
				AND    csmpd.currencynumber = pcurrencynumber
				AND    csmpd.currencynumber = CASE
						   WHEN ctin.itemname = 'ITEMDEPOSITDOM' THEN
							1
						   WHEN ctin.itemname = 'ITEMDEPOSITINT' THEN
							2
						   ELSE
							-1
					   END
				
				) sq
		WHERE  csc.branch(+) = sq.branch
		AND    csc.contractno(+) = sq.contractno
		AND    csc.statementdate(+) = sq.statementdate
		AND    csmpd.branch(+) = csc.branch
		AND    csmpd.screcno(+) = csc.recno
		AND    nvl(csmpd.currencynumber, sq.currencynumber) = sq.currencynumber
		AND    sq.currencynumber = pcurrencynumber
		AND    phmb.branch = sq.branch
		AND    phmb.contracttype = sq.contracttype
		AND    phmb.contractno = sq.contractno
		AND    phmb.currencynumber = sq.currencynumber
		AND    phmb.statementdate = sq.statementdate
		AND    c.branch = sq.branch
		AND    c.no = sq.contractno
		AND    CASE
				  WHEN pcontractno IS NOT NULL THEN
				   sq.contractno
				  ELSE
				   '1'
			  END = CASE
				   WHEN pcontractno IS NOT NULL THEN
					pcontractno
				   ELSE
					'1'
			   END
		ORDER  BY sq.branch
				 ,sq.contractno
				 ,sq.trxndate
				 ,sq.recno
				 ,sq.packno;
	
		FOR i IN 1 .. strxnandcyclearray.count
		LOOP
			IF strxnandcyclearray(i)
			 .trxndate = strxnandcyclearray(i).duedate
				AND strxnandcyclearray(i).packno = 0
				AND strxnandcyclearray.exists(i + 1)
				AND strxnandcyclearray(i + 1).trxndate = strxnandcyclearray(i).duedate
			   
				AND strxnandcyclearray(i).contractno = strxnandcyclearray(i + 1).contractno
			
			THEN
				NULL;
				custom_s.say(' - info: Transaction was not handled', 1);
			ELSE
				IF vcontractno IS NULL
				THEN
					vcontractno   := strxnandcyclearray(i).contractno;
					vmppayoffdate := strxnandcyclearray(i).createdate;
					custom_s.say(cmethodname ||
								 ' - info: VERY FIRST CONTRACT has been taken for handling. ContractNo = ' ||
								 vcontractno
								,1);
				END IF;
			
				IF vrecno IS NULL
				THEN
					vrecno         := strxnandcyclearray(i).recno;
					vstatementdate := strxnandcyclearray(i).statementdate;
					vminpayment    := strxnandcyclearray(i).minpayment;
					vsdamount      := strxnandcyclearray(i).sdamount;
					custom_s.say(cmethodname ||
								 ' - info: Very first tContractStCycle.recNo has been taken for handling. vRecNo = ' ||
								 vrecno || ', Statement Date = ' || htools.d2s(vstatementdate) ||
								 ', SDAmount = ' || vsdamount);
				
					vprevmpovd_onduedatearray(vrecno) := 0;
					custom_s.say(cmethodname || '    1. vPrevMPOvd_OnDueDateArray (' || vrecno ||
								 ') = ' || vprevmpovd_onduedatearray(vrecno));
				
				END IF;
			
				IF vrecno != strxnandcyclearray(i).recno
				THEN
					vindex := vindex + 1;
					vaggregatedtrxnvarr.extend;
					vaggregatedtrxnrow := typeaggregatedtrxn_obj(vtrxndate
																,vdebitamount
																,vcreditamount
																,vrevdebitamount
																,vrevcreditamount
																,vrepayment
																,vpackno
																,vmppayoffdate
																,vpaidamount
																,vreduceddebit
																,vrevdebitoverplus);
					vaggregatedtrxnvarr(vindex) := vaggregatedtrxnrow;
					custom_s.say(cmethodname ||
								 '    -> tContractStCycle.recNo was changed. Index for vAggregatedTrxnVarr (vIndex) = ' ||
								 vindex || ', vTrxnDate = ' || htools.d2s(vtrxndate) ||
								 ', vPacNo = ' || vpackno || ', Old RecNo (vRecNo) = ' || vrecno);
					custom_s.say(cmethodname || '    -> (2) SAVED: TrxnDate = ' ||
								 htools.d2s(vtrxndate) || ', Debit = ' || vdebitamount ||
								 ', Credit = ' || vcreditamount || ', RevDebit = ' ||
								 vrevdebitamount || ', RevCredit = ' || vrevcreditamount ||
								 ', vReducedDebit = ' || vreduceddebit || ', vRevDebitOverplus = ' ||
								 vrevdebitoverplus || ', vPaidAmount = ' || vpaidamount ||
								 ', vRepayment = ' || vrepayment || ', vMPPayOffDate = ' ||
								 htools.d2s(vmppayoffdate));
					vmppayoffdate_atcycleendarray(vrecno) := vmppayoffdate;
					vrecnoarray(vrecno) := vrecno;
					vaggregatedtrxnarray(vrecno) := vaggregatedtrxnvarr;
					vminpaymentarray(vrecno) := vminpayment;
					vsdamountarray(vrecno) := vsdamount;
					vbrancharray(vrecno) := cbranch;
					vcurrencynumberarray(vrecno) := pcurrencynumber;
				
					IF vcontractno != strxnandcyclearray(i).contractno
					THEN
						custom_s.say(cmethodname ||
									 ' - info: ContractNo is changed. Old ContractNo (vContractNo) = ' ||
									 vcontractno
									,1);
						vaggregatedtrxnarray(vrecno) := vaggregatedtrxnvarr;
						updateminpaymentdata(pcurrencynumber);
						custom_s.say(cmethodname ||
									 ' -> NEW CONTRACT to hanlde (sTrxnAndCycleArray (i).contractNo) = ' || strxnandcyclearray(i)
									 .contractno || ', new recNo (sTrxnAndCycleArray (i).RecNo) = ' || strxnandcyclearray(i)
									 .recno ||
									 ', new Statement Date (sTrxnAndCycleArray (i).StatementDate) = ' ||
									 htools.d2s(strxnandcyclearray(i).statementdate));
					
						vmppayoffdate := strxnandcyclearray(i).createdate;
					END IF;
				
					vprevmpovd_onduedatearray(strxnandcyclearray(i).recno) := 0;
					custom_s.say(cmethodname || '    0. vPrevMPOvd_OnDueDateArray (' || strxnandcyclearray(i)
								 .recno || ') = ' ||
								 vprevmpovd_onduedatearray(strxnandcyclearray(i).recno));
				
					vrecno            := strxnandcyclearray(i).recno;
					vstatementdate    := strxnandcyclearray(i).statementdate;
					vcontractno       := strxnandcyclearray(i).contractno;
					vminpayment       := strxnandcyclearray(i).minpayment;
					vsdamount         := strxnandcyclearray(i).sdamount;
					vdebitamount      := 0;
					vcreditamount     := 0;
					vrevdebitamount   := 0;
					vrevcreditamount  := 0;
					vpaidamount       := 0;
					vrepayment        := 0;
					vrevdebitoverplus := 0;
					vreduceddebit     := 0;
				
					vindex              := 0;
					vaggregatedtrxnvarr := NEW typeaggregatedtrxn_varr();
					vtrxndate           := NULL;
					vpackno             := NULL;
				END IF;
			
				IF vtrxndate IS NULL
				THEN
					vtrxndate          := strxnandcyclearray(i).trxndate;
					vpackno            := strxnandcyclearray(i).packno;
					vaggregatedtrxnrow := typeaggregatedtrxn_obj(vtrxndate
																,vdebitamount
																,vcreditamount
																,vrevdebitamount
																,vrevcreditamount
																,vrepayment
																,vpackno
																,vmppayoffdate
																,vpaidamount
																,vreduceddebit
																,vrevdebitoverplus);
				END IF;
			
				IF vtrxndate != strxnandcyclearray(i).trxndate
				   OR vpackno != strxnandcyclearray(i).packno
				THEN
					vindex := vindex + 1;
					vaggregatedtrxnvarr.extend;
					custom_s.say(cmethodname ||
								 '    -> Transaction date or PackNo were changed. Index for vAggregatedTrxnVarr (vIndex) = ' ||
								 vindex || ', Old trxnDate (vTrxnDate) = ' ||
								 htools.d2s(vtrxndate) ||
								 ', new TrxnDate (sTrxnAndCycleArray (i).trxnDate) = ' ||
								 htools.d2s(strxnandcyclearray(i).trxndate) ||
								 ', Old PackNo (vPacNo) = ' || vpackno ||
								 ', New PackNo (sTrxnAndCycleArray (i).PackNo) = ' || strxnandcyclearray(i)
								 .packno
								,1);
					custom_s.say(cmethodname || '    -> (1) SAVED: TrxnDate = ' ||
								 htools.d2s(vtrxndate) || ', Debit = ' || vdebitamount ||
								 ', Credit = ' || vcreditamount || ', RevDebit = ' ||
								 vrevdebitamount || ', RevCredit = ' || vrevcreditamount ||
								 ', vReducedDebit = ' || vreduceddebit || ', vRevDebitOverplus = ' ||
								 vrevdebitoverplus || ', vPaidAmount = ' || vpaidamount ||
								 ', vRepayment = ' || vrepayment || ', vMPPayOffDate = ' ||
								 htools.d2s(vmppayoffdate));
					vaggregatedtrxnrow := typeaggregatedtrxn_obj(vtrxndate
																,vdebitamount
																,vcreditamount
																,vrevdebitamount
																,vrevcreditamount
																,vrepayment
																,vpackno
																,vmppayoffdate
																,vpaidamount
																,vreduceddebit
																,vrevdebitoverplus);
					vaggregatedtrxnvarr(vindex) := vaggregatedtrxnrow;
				
					vmppayoffdate_atcycleendarray(vrecno) := vmppayoffdate;
				
					vtrxndate := strxnandcyclearray(i).trxndate;
					vpackno   := strxnandcyclearray(i).packno;
				END IF;
			
				vdebitamount     := vdebitamount + strxnandcyclearray(i).debitamount;
				vcreditamount    := vcreditamount + strxnandcyclearray(i).creditamount;
				vrevdebitamount  := vrevdebitamount + strxnandcyclearray(i).reversedebitamount;
				vrevcreditamount := vrevcreditamount + strxnandcyclearray(i).reversecreditamount;
			
				vpaidamount := vpaidamount + strxnandcyclearray(i).creditamount;
				vdelta      := least(vpaidamount, strxnandcyclearray(i).reversecreditamount);
				vpaidamount := vpaidamount - vdelta;
			
				vreduceddebit     := vreduceddebit + strxnandcyclearray(i).debitamount;
				vdelta            := least(vreduceddebit, strxnandcyclearray(i).reversedebitamount);
				vreduceddebit     := vreduceddebit - vdelta;
				vrevdebitoverplus := vrevdebitoverplus +
									 (strxnandcyclearray(i).reversedebitamount - vdelta);
				vdelta            := 0;
			
				vrepayment := vpaidamount +
							  greatest(vrevdebitoverplus -
									   (greatest(abs(least(strxnandcyclearray(i).sdamount, 0)), 0) - strxnandcyclearray(i)
									   .minpayment)
									  ,0);
			
				vrepayment_atcycleendarrary(vrecno) := vrepayment;
			
				IF strxnandcyclearray(i).trxndate <= strxnandcyclearray(i).duedate
				THEN
					custom_s.say('### TEST-0', 1);
				
					IF NOT vminpaymentarray.exists(vminpaymentarray.prior(vrecno))
					   AND strxnandcyclearray(i).trxndate < strxnandcyclearray(i).duedate
					THEN
						vmppayoffdate := strxnandcyclearray(i).createdate;
						custom_s.say('### TEST-1', 1);
					ELSIF (vminpaymentarray.exists(vminpaymentarray.prior(vrecno)) AND
						  (vrepayment +
						  vrepayment_atcycleendarrary(vrepayment_atcycleendarrary.prior(vrecno))) >=
						  vminpaymentarray(vminpaymentarray.prior(vrecno)) AND strxnandcyclearray(i)
						  .trxndate < strxnandcyclearray(i).duedate OR
						  vrepayment >= strxnandcyclearray(i).minpayment AND strxnandcyclearray(i)
						  .trxndate = strxnandcyclearray(i).duedate AND
						  NOT
						   (strxnandcyclearray.exists(i + 1) AND strxnandcyclearray(i + 1).trxndate = strxnandcyclearray(i)
						   .duedate AND strxnandcyclearray(i + 1).contractno = vcontractno))
						  AND vmppayoffdate IS NULL
					THEN
						vmppayoffdate := strxnandcyclearray(i).trxndate;
						custom_s.say('### TEST-2', 1);
					ELSIF vminpaymentarray.exists(vminpaymentarray.prior(vrecno))
						  AND (vrepayment +
							   vrepayment_atcycleendarrary(vrepayment_atcycleendarrary.prior(vrecno))) <
						  vminpaymentarray(vminpaymentarray.prior(vrecno))
						  AND strxnandcyclearray(i).trxndate < strxnandcyclearray(i).duedate
					THEN
						vmppayoffdate := NULL;
						custom_s.say('### TEST-3', 1);
					ELSIF NOT vminpaymentarray.exists(vminpaymentarray.prior(vrecno))
						  AND vrepayment < strxnandcyclearray(i).minpayment
						  AND strxnandcyclearray(i).trxndate = strxnandcyclearray(i).duedate
						  AND NOT (strxnandcyclearray.exists(i + 1) AND strxnandcyclearray(i + 1)
						   .trxndate = strxnandcyclearray(i)
						   .duedate AND strxnandcyclearray(i + 1).contractno = vcontractno)
					THEN
						vmppayoffdate := NULL;
						custom_s.say('### TEST-4', 1);
					ELSIF vrepayment < strxnandcyclearray(i).minpayment
						  AND strxnandcyclearray(i).trxndate = strxnandcyclearray(i).duedate
						  AND NOT (strxnandcyclearray.exists(i + 1) AND strxnandcyclearray(i + 1)
						   .trxndate = strxnandcyclearray(i)
						   .duedate AND strxnandcyclearray(i + 1).contractno = vcontractno)
					THEN
						vmppayoffdate := NULL;
						custom_s.say('### TEST-5', 1);
					END IF;
				ELSE
					custom_s.say('### TEST-6', 1);
				
					IF vrepayment >= strxnandcyclearray(i).minpayment
					   AND vmppayoffdate IS NULL
					THEN
						vmppayoffdate := strxnandcyclearray(i).trxndate;
						custom_s.say('### TEST-7', 1);
					ELSIF vrepayment < strxnandcyclearray(i).minpayment
					THEN
						vmppayoffdate := NULL;
						custom_s.say('### TEST-8', 1);
					END IF;
				
				END IF;
				custom_s.say(cmethodname || '     vMPPayOffDate = ' || htools.d2s(vmppayoffdate));
			
				IF strxnandcyclearray(i).duedate = strxnandcyclearray(i).trxndate
					AND strxnandcyclearray(i).lastduedate IS NOT NULL
				THEN
					vunpaidsdamount_onduedatearray(vrecno) := abs(least(vpaidamount +
																		vrevdebitoverplus -
																		abs(least(strxnandcyclearray(i)
																				  .sdamount
																				 ,0))
																	   ,0));
				ELSIF strxnandcyclearray(i).trxndate <= strxnandcyclearray(i).duedate
					   AND strxnandcyclearray(i).lastduedate IS NULL
				THEN
					vunpaidsdamount_onduedatearray(vrecno) := 0;
				END IF;
			
				IF strxnandcyclearray(i).duedate = strxnandcyclearray(i).trxndate
					AND strxnandcyclearray(i).lastduedate IS NOT NULL
				THEN
					voverdueamount_onduedatearray(vrecno) := abs(least(vrepayment - strxnandcyclearray(i)
																	   .minpayment
																	  ,0));
				ELSIF strxnandcyclearray(i).trxndate <= strxnandcyclearray(i).duedate
					   AND strxnandcyclearray(i).lastduedate IS NULL
				THEN
					voverdueamount_onduedatearray(vrecno) := 0;
				END IF;
			
				IF strxnandcyclearray(i).trxndate = strxnandcyclearray(i).duedate
					AND
					vrepayment_atcycleendarrary.exists(vrepayment_atcycleendarrary.prior(vrecno))
					AND strxnandcyclearray(i).lastduedate IS NOT NULL
				THEN
					custom_s.say(cmethodname ||
								 '    vMinPaymentArray(vMinPaymentArray.prior(vRecNo)) = ' ||
								 vminpaymentarray(vminpaymentarray.prior(vrecno)) ||
								 ', vRepayment_AtCycleEndArrary.prior (vRepayment_AtCycleEndArrary (vRecNo)) = ' ||
								 vrepayment_atcycleendarrary(vrepayment_atcycleendarrary.prior(vrecno)) ||
								 ', vRepayment = ' || vrepayment
								,1);
					vprevmpovd_onduedatearray(vrecno) := greatest(nvl(vminpaymentarray(vminpaymentarray.prior(vrecno))
																	 ,0) -
																  (nvl(vrepayment_atcycleendarrary(vrepayment_atcycleendarrary.prior(vrecno))
																	  ,0) + nvl(vrepayment, 0))
																 ,0);
					custom_s.say(cmethodname || '    vPrevMPOvd_OnDueDateArray (' || vrecno ||
								 ') = ' || vprevmpovd_onduedatearray(vrecno)
								,1);
				ELSIF strxnandcyclearray(i).trxndate < strxnandcyclearray(i).duedate
					   AND strxnandcyclearray(i).lastduedate IS NULL
				THEN
					vprevmpovd_onduedatearray(vrecno) := 0;
					custom_s.say(cmethodname || '    2. vPrevMPOvd_OnDueDateArray (' || vrecno ||
								 ') = ' || vprevmpovd_onduedatearray(vrecno)
								,1);
				END IF;
			
			END IF;
		END LOOP;
	
		IF strxnandcyclearray.count <> 0
		THEN
			custom_s.say(cmethodname || '   (3) -> SAVED: TrxnDate = ' || htools.d2s(vtrxndate) ||
						 ', Debit = ' || vdebitamount || ', Credit = ' || vcreditamount ||
						 ', RevDebit = ' || vrevdebitamount || ', RevCredit = ' ||
						 vrevcreditamount || ', vReducedDebit = ' || vreduceddebit ||
						 ', vRevDebitOverplus = ' || vrevdebitoverplus || ', vPaidAmount = ' ||
						 vpaidamount || ', vRepayment = ' || vrepayment || ', vMPPayOffDate = ' ||
						 htools.d2s(vmppayoffdate));
			vrecnoarray(vrecno) := vrecno;
			vaggregatedtrxnarray(vrecno) := vaggregatedtrxnvarr;
			vminpaymentarray(vrecno) := vminpayment;
			vsdamountarray(vrecno) := vsdamount;
			vbrancharray(vrecno) := cbranch;
			vcurrencynumberarray(vrecno) := pcurrencynumber;
		
			vprevmpovd_onduedatearray(vrecno) := 0;
			custom_s.say(cmethodname || '    3. vPrevMPOvd_OnDueDateArray (' || vrecno || ') = ' ||
						 vprevmpovd_onduedatearray(vrecno));
		
			vmppayoffdate_atcycleendarray(vrecno) := vmppayoffdate;
		
			vaggregatedtrxnrow := typeaggregatedtrxn_obj(vtrxndate
														,vdebitamount
														,vcreditamount
														,vrevdebitamount
														,vrevcreditamount
														,vrepayment
														,vpackno
														,vmppayoffdate
														,vpaidamount
														,vreduceddebit
														,vrevdebitoverplus);
			vindex             := vindex + 1;
			vaggregatedtrxnvarr.extend;
			custom_s.say(cmethodname ||
						 ' tContractStCycle.recNo was changed. Index for vAggregatedTrxnVarr (vIndex) = ' ||
						 vindex || ', vTrxnDate = ' || htools.d2s(vtrxndate) ||
						 ', Old PackNo (vPacNo) = ' || vpackno || ', Old RecNo (vRecNo) = ' ||
						 vrecno
						,1);
			vaggregatedtrxnvarr(vindex) := vaggregatedtrxnrow;
		
			custom_s.say(cmethodname || ' Debit = ' || vdebitamount || ', Credit = ' ||
						 vcreditamount || ', RevDebit = ' || vrevdebitamount || ', RevCredit = ' ||
						 vrevcreditamount || ', vReducedDebit = ' || vreduceddebit ||
						 ', vRevDebitOverplus = ' || vrevdebitoverplus || ', vPaidAmount = ' ||
						 vpaidamount || ', vRepayment = ' || vrepayment
						,1);
		
			vaggregatedtrxnarray(vrecno) := vaggregatedtrxnvarr;
		
			updateminpaymentdata(pcurrencynumber);
			IF plogfilepath IS NOT NULL
			THEN
				COMMIT;
			END IF;
		END IF;
		IF plogfilepath IS NOT NULL
		THEN
			wlog('Successful contracts handled - ' || vhandledcontrcounter ||
				 ', erroneous contracts - ' || verrcontrcounter);
			wlog('END.');
			term.close(shlog);
		END IF;
		custom_s.say(cmethodname || ' -->> END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			IF plogfilepath IS NOT NULL
			THEN
				verrcontrcounter := verrcontrcounter + 1;
				vsqlcode         := vsqlcode;
				vsqlerrm         := SQLERRM || ' ' || dbms_utility.format_error_backtrace;
				custom_s.say('<Main> ' || vsqlcode || '  ' || vsqlerrm, 1);
				INSERT INTO tpaidhistorymigrerr
				VALUES
					(NULL
					,cbranch
					,pcontractno
					,pcontracttype
					,pcurrencynumber
					,'<Main> ' || vsqlcode || '  ' || vsqlerrm
					,NULL);
				term.close(shlog);
			ELSE
				error.save(cmethodname);
				RAISE;
			END IF;
			custom_s.say(cmethodname || '  -->> END', 1);
	END paidhistorymigration;

	PROCEDURE paidhistorymigration_mscc
	(
		plogfilepath    VARCHAR2
	   ,pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE
	   ,pcontracttype   tcontracttype.type%TYPE := NULL
	   ,pcontractno     tcontract.no%TYPE := NULL
	) IS
	
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.PaidHistoryMigration_MSCC';
		cbranch     CONSTANT NUMBER := custom_seance.getbranch;
	
		vcontractno tcontract.no%TYPE;
	
		vdebitamount     NUMBER := 0;
		vcreditamount    NUMBER := 0;
		vrevdebitamount  NUMBER := 0;
		vrevcreditamount NUMBER := 0;
	
		vreduceddebit     NUMBER := 0;
		vdelta            NUMBER := 0;
		vpaidamount       NUMBER := 0;
		vrevdebitoverplus NUMBER := 0;
	
		vtrxndate DATE;
		vpackno   NUMBER;
	
		vtrxntable  VARCHAR2(30000);
		vcycletable VARCHAR2(30000);
	
		TYPE typeminpayment IS TABLE OF tcontractstminpaymentdata.minpayment%TYPE INDEX BY BINARY_INTEGER;
		vminpaymentarray typeminpayment;
		vminpayment      NUMBER;
		TYPE typerepayment_atcycleend IS TABLE OF tcontractstminpaymentdata.repayment_atcycleend%TYPE INDEX BY BINARY_INTEGER;
		vrepayment_atcycleendarrary typerepayment_atcycleend;
		vrepayment                  NUMBER := 0;
		TYPE typeunpaidsdamount_onduedate IS TABLE OF tcontractstminpaymentdata.unpaidsdamount_onduedate%TYPE INDEX BY BINARY_INTEGER;
		vunpaidsdamount_onduedatearray typeunpaidsdamount_onduedate;
	
		TYPE typeoverdueamount_onduedate IS TABLE OF tcontractstminpaymentdata.overdueamount_onduedate%TYPE INDEX BY BINARY_INTEGER;
		voverdueamount_onduedatearray typeoverdueamount_onduedate;
		TYPE typeprevmpovd_onduedate IS TABLE OF tcontractstminpaymentdata.prevmpovd_onduedate%TYPE INDEX BY BINARY_INTEGER;
		vprevmpovd_onduedatearray typeprevmpovd_onduedate;
	
		TYPE typesdamount IS TABLE OF tcontractstminpaymentdata.sdamount%TYPE INDEX BY BINARY_INTEGER;
		vsdamountarray typesdamount;
		vsdamount      NUMBER := 0;
		TYPE typeaggregatedtrxn IS TABLE OF tcontractstminpaymentdata.aggregatedtrxn%TYPE INDEX BY BINARY_INTEGER;
		vaggregatedtrxnarray typeaggregatedtrxn;
		vaggregatedtrxnrow   typeaggregatedtrxn_obj;
		vaggregatedtrxnvarr  typeaggregatedtrxn_varr := NEW typeaggregatedtrxn_varr();
		vindex               NUMBER := 0;
		TYPE typerecno IS TABLE OF tcontractstminpaymentdata.screcno%TYPE INDEX BY BINARY_INTEGER;
		vrecnoarray typerecno;
		vrecno      tcontractstcycle.recno%TYPE := NULL;
		TYPE typebranch IS TABLE OF tcontractstminpaymentdata.branch%TYPE INDEX BY BINARY_INTEGER;
		vbrancharray typebranch;
		TYPE typecurrencynumber IS TABLE OF tcontractstminpaymentdata.currencynumber%TYPE INDEX BY BINARY_INTEGER;
		vcurrencynumberarray typecurrencynumber;
		TYPE typemppayoffdate_atcycleend IS TABLE OF tcontractstminpaymentdata.mp_payoffdate_atcycleend%TYPE INDEX BY BINARY_INTEGER;
		vmppayoffdate_atcycleendarray typemppayoffdate_atcycleend;
		vmppayoffdate                 DATE := NULL;
	
		vstatementdate tcontractstcycle.statementdate%TYPE := NULL;
	
		i tcontractstminpaymentdata.screcno%TYPE;
	
		vtotalcontractcounter NUMBER := 0;
		verrorcontractcounter NUMBER := 0;
	
		vsqlerrm VARCHAR2(4000);
		vsqlcode VARCHAR2(30);
	
		vhandledcontrcounter NUMBER := 0;
		verrcontrcounter     NUMBER := 0;
	
		PROCEDURE updateminpaymentdata(pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE) IS
			cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
												  '.PaidHistoryMigration.UpdateMinPaymentData';
		
		BEGIN
			custom_s.say('     ' || cmethodname || ' --<< BEGIN', 1);
			custom_s.say('     ' || cmethodname ||
						 '  - INPUT PARAMETERS: currency number (pCurrencyNumber) = ' ||
						 pcurrencynumber
						,1);
		
			IF MOD(vtotalcontractcounter, 1000) = 0
			THEN
				COMMIT;
			END IF;
		
			custom_s.say('### - ### --> vRepayment_AtCycleEndArrary.last = ' ||
						 vrepayment_atcycleendarrary.last
						,1);
			custom_s.say('### - ### --> vUnpaidSDAmount_OnDueDateArray.last = ' ||
						 vunpaidsdamount_onduedatearray.last
						,1);
			custom_s.say('### - ### --> vOverdueAmount_OnDueDateArray.last = ' ||
						 voverdueamount_onduedatearray.last
						,1);
			custom_s.say('### - ### --> vPrevMPOvd_OnDueDateArray.last = ' ||
						 vprevmpovd_onduedatearray.last
						,1);
			custom_s.say('### - ### --> vSDAmountArray.last = ' || vsdamountarray.last, 1);
			custom_s.say('### - ### --> vMPPayOffDate_AtCycleEndArray.last = ' ||
						 vmppayoffdate_atcycleendarray.last
						,1);
			custom_s.say('### - ### --> vAggregatedTrxnArray.last = ' || vaggregatedtrxnarray.last
						,1);
			custom_s.say('### - ### --> vBranchArray.last = ' || vbrancharray.last, 1);
			custom_s.say('### - ### --> vRecNoArray.last = ' || vrecnoarray.last, 1);
		
			FORALL j IN INDICES OF vrecnoarray
				UPDATE tcontractstminpaymentdata
				SET    repayment_atcycleend     = vrepayment_atcycleendarrary(j)
					  ,unpaidsdamount_onduedate = vunpaidsdamount_onduedatearray(j)
					  ,
					   
					   overdueamount_onduedate = voverdueamount_onduedatearray(j)
					  ,prevmpovd_onduedate     = vprevmpovd_onduedatearray(j)
					  ,
					   
					   sdamount                 = vsdamountarray(j)
					  ,mp_payoffdate_atcycleend = vmppayoffdate_atcycleendarray(j)
					  ,aggregatedtrxn           = vaggregatedtrxnarray(j)
				WHERE  branch = vbrancharray(j)
				AND    screcno = vrecnoarray(j)
				AND    currencynumber = pcurrencynumber;
		
			custom_s.say('     ' || cmethodname || '   Rows updated (sql%rowcount) = ' ||
						 SQL%ROWCOUNT
						,1);
		
			vmppayoffdate_atcycleendarray.delete;
		
			vminpaymentarray.delete;
			vrepayment_atcycleendarrary.delete;
			vunpaidsdamount_onduedatearray.delete;
		
			voverdueamount_onduedatearray.delete;
			vprevmpovd_onduedatearray.delete;
		
			vsdamountarray.delete;
			vaggregatedtrxnarray.delete;
			vrecnoarray.delete;
			vbrancharray.delete;
			vcurrencynumberarray.delete;
			vindex              := 0;
			vaggregatedtrxnvarr := NEW typeaggregatedtrxn_varr();
			vmppayoffdate       := NULL;
		
			vrecno         := NULL;
			vstatementdate := NULL;
		
			vhandledcontrcounter := vhandledcontrcounter + 1;
			IF plogfilepath IS NOT NULL
			THEN
				wlog(vcontractno || ' SAVED');
			END IF;
			custom_s.say('     ' || cmethodname || '   DATA FOR OLD CONTRACT WERE SAVED', 1);
			custom_s.say('     ' || cmethodname || ' -->> END', 1);
			custom_s.say('', 1);
		EXCEPTION
			WHEN OTHERS THEN
				verrcontrcounter      := verrcontrcounter + 1;
				verrorcontractcounter := verrorcontractcounter + 1;
				vsqlcode              := vsqlcode;
				vsqlerrm              := SQLERRM || ' ' || dbms_utility.format_error_backtrace;
				custom_s.say('<UpdateMinPaymentData> ' || vsqlcode || '  ' || vsqlerrm);
				INSERT INTO tpaidhistorymigrerr
				VALUES
					(vrecno
					,cbranch
					,vcontractno
					,pcontracttype
					,pcurrencynumber
					,'<UpdateMinPaymentData> ' || vsqlcode || '  ' || vsqlerrm
					,vtotalcontractcounter);
			
				vmppayoffdate_atcycleendarray.delete;
				vminpaymentarray.delete;
				vrepayment_atcycleendarrary.delete;
				vunpaidsdamount_onduedatearray.delete;
				voverdueamount_onduedatearray.delete;
				vprevmpovd_onduedatearray.delete;
				vsdamountarray.delete;
				vaggregatedtrxnarray.delete;
				vrecnoarray.delete;
				vbrancharray.delete;
				vcurrencynumberarray.delete;
			
		END updateminpaymentdata;
	
	BEGIN
		shlog := term.fileopenwrite(plogfilepath || '-MAIN' || '-CUR-' || pcurrencynumber || '-' ||
									to_char(SYSDATE, ' YYYY-MM-DD HH24-MI-SS') || ', -CT-' ||
									pcontracttype || '-C-' || pcontractno || '.log');
		wlog('BEGIN');
		wlog('Input Parameters: currency = ' || pcurrencynumber || ', contract type = ' ||
			 pcontracttype || ', contract number = ' || pcontractno);
		custom_s.say(cmethodname || ' --<< BEGIN', 1);
		custom_s.say(cmethodname || '   -- INPUT PARAMETERS:', 1);
		custom_s.say(cmethodname || '    -> pLogFilePath = ' || plogfilepath || ', cBranch = ' ||
					 cbranch || ', pCurrencyNumber = ' || pcurrencynumber || ', pContractType = ' ||
					 pcontracttype || ', pContractNo = ' || pcontractno
					,1);
		custom_s.say('', 1);
	
		DELETE FROM tpaidhistorymigrerr
		WHERE  currencynumber = pcurrencynumber
		AND    contracttype = nvl(pcontracttype, contracttype)
		AND    nvl(contractno, '') = nvl(pcontractno, nvl(contractno, ''));
		wlog('Clear rows with old errors. Rows deleted : ' || SQL%ROWCOUNT);
		custom_s.say('    Clear rows with old errors. Rows deleted : ' || SQL%ROWCOUNT, 1);
	
		FOR cc IN (SELECT table_name
				   FROM   user_tables
				   WHERE  (table_name LIKE 'TNA_CSC_%' OR table_name LIKE 'TNA_TRXN_%' OR
						  table_name LIKE 'TNA_BAL_%'))
		LOOP
			IF cc.table_name IN
			   (upper('tNA_csc_' || pcontracttype || '_' || cbranch || '_' || pcurrencynumber)
			   ,upper('tNA_trxn_' || pcontracttype || '_' || cbranch || '_' || pcurrencynumber)
			   ,upper('tNA_bal_' || pcontracttype || '_' || cbranch || '_' || pcurrencynumber))
			THEN
			
				EXECUTE IMMEDIATE 'drop table ' || cc.table_name;
			END IF;
		END LOOP;
	
		vcycletable := 'create table tNA_csc_' || pcontracttype || '_' || cbranch || '_' ||
					   pcurrencynumber || ' as
  select c.type contractType, csc.dueDate, csc.recNo, csmpd.minPayment, c.createDate, csc.lastDueDate, csc.NextStatementDate, csc.ContractNo, csmpd.currencyNumber, csc.StatementDate
   from tContractStMinPaymentData csmpd, tContractStCycle csc, tContract c
  where c.branch = ' || cbranch || '
	and c.type = ' || pcontracttype || '
	and csmpd.currencyNumber = ' || pcurrencynumber || '
	and csc.branch = c.branch
	and csc.ContractNo = c.no
	and csmpd.branch = csc.branch
	and csmpd.scRecNo = csc.recNo
	and csmpd.currencyNumber between 1 and 2';
		EXECUTE IMMEDIATE (vcycletable);
		EXECUTE IMMEDIATE ('create bitmap index iCSC_' || pcontracttype || '_' || cbranch || '_' ||
						  pcurrencynumber || ' on tNA_csc_' || pcontracttype || '_' || cbranch || '_' ||
						  pcurrencynumber || ' (
						 contractType )
					  ');
		EXECUTE IMMEDIATE ('create index icCSC_' || pcontracttype || '_' || cbranch || '_' ||
						  pcurrencynumber || ' on tNA_csc_' || pcontracttype || '_' || cbranch || '_' ||
						  pcurrencynumber || ' (
						 contractNo,
						 contractType )
					  ');
	
		vtrxntable := '
		   create table tNA_trxn_' || pcontracttype || '_' || cbranch || '_' ||
					  pcurrencynumber || ' as
		   select *
			 from (
			select ctl.branch, ctl.contractNo, ctl.postDate trxnDate,
				   case
				   when ctl.tranType = 1 then ctl.amount
				   else 0
				   end debitAmount,
				   case
				   when ctl.tranType = 3 then ctl.amount
				   else 0
				   end creditAmount,
				   case
				   when ctl.tranType = 4 then ctl.amount
				   else 0
				   end reverseDebitAmount,
				   case
				   when ctl.tranType = 2 then ctl.amount
				   else 0
				   end reverseCreditAmount,
				   (select max (csc.statementDate)
					  from tContractStCycle csc
					 where csc.branch = ctl.branch
					   and csc.contractNo = ctl.contractNo
					   and csc.StatementDate < ctl.postDate
				   ) StatementDate,
				   case
				   when ctin.itemName = ''ITEMDEPOSITDOM'' then 1
				   when ctin.itemName = ''ITEMDEPOSITINT'' then 2
				   else -1
				   end currencyNumber, ctl.packNo, ctin.contractType, ctl.recNo
			  from tContractTypeItemName ctin, tContractItem ci, tContractTrxnList ctl
			 where ctin.branch = ' || cbranch || '
			   and ctin.contractType = ' || pcontracttype || '
			   and ctin.itemName like ''ITEMDEPOSIT%''
			   and ctin.branch = ci.branch
			   and ctin.itemCode = ci.itemCode
			   and ctl.branch = ci.branch
			   and ctl.contractNo = ci.no
			   and ctl.accountNo = ci.key
			group by ctl.branch, ctl.contractNo, ctl.postDate, ctin.itemName, ctl.packNo, ctin.contractType, ctl.tranType, ctl.recNo, ctl.amount
		   )
		  where currencyNumber = ' || pcurrencynumber || '

		   union all
			-- {{{{{ Query below creates empty entries for each statement date in order to avoid special cases handling when there were no transactions within a cycle (!especially on Due Date!)
			select csmpd.branch, csc.contractNo,
				   case
				   when csc.lastDueDate is not null then csc.DueDate
				   else csc.statementDate + 1
				   end trxnDate,
				   0 debitAmount,
				   0 creditAmount,
				   0 reverseDebitAmount,
				   0 reverseCreditAmount,
				   csc.statementDate statementDate,
				   csmpd.currencyNumber,
				   0 packNo, ctin.contractType, 0 recNo
			  from tContractStMinPaymentData csmpd, tContractStCycle csc, tContractItem ci, tContractTypeItemName ctin
			 where ctin.branch = ' || cbranch || '
			   and ctin.contractType = ' || pcontracttype || '
			   and ctin.itemName like ''ITEMDEPOSIT%''
			   and ctin.branch = ci.branch
			   and ctin.itemCode = ci.itemCode
			   and csc.branch = ci.branch
			   and csc.contractNo = ci.no
			   and csmpd.branch = csc.branch
			   and csmpd.scRecNo = csc.recNo
			   and csmpd.currencyNumber = ' || pcurrencynumber || '
			   and csmpd.currencyNumber = case
										  when ctin.itemName = ''ITEMDEPOSITDOM'' then 1
										  when ctin.itemName = ''ITEMDEPOSITINT'' then 2
										  else -1
										  end

 ';
	
		EXECUTE IMMEDIATE (vtrxntable);
		EXECUTE IMMEDIATE (' create index iTrxn_' || pcontracttype || '_' || cbranch || '_' ||
						  pcurrencynumber || ' on tNA_trxn_' || pcontracttype || '_' || cbranch || '_' ||
						  pcurrencynumber || ' (
						contractNo,
						StatementDate
						)');
	
		EXECUTE IMMEDIATE ' create table tNA_bal_' || pcontracttype || '_' || cbranch || '_' ||
						  pcurrencynumber || ' as
	 select distinct branch, contractNo, contractType, currencyNumber, statementDate,
			sum (-debitAmount + creditAmount + ReverseDebitAmount - ReverseCreditAmount)
				 over (partition by branch, contractType, contractNO, currencyNumber order by branch, contractType, contractNO, currencyNumber, statementDate) SDAmount
	   from (
			 select *
			   from (
			  select ctl.branch, ctl.contractNo, ctin.contractType, ctl.postDate trxnDate,
					sum (case
						 when ctl.tranType = 1 then ctl.amount
						 else 0
						 end) debitAmount,
					sum (case
						 when ctl.tranType = 3 then ctl.amount
						 else 0
						 end) creditAmount,
					sum (case
						 when ctl.tranType = 4 then ctl.amount
						 else 0
						 end) reverseDebitAmount,
					sum (case
						 when ctl.tranType = 2 then ctl.amount
						 else 0
						 end) reverseCreditAmount,
					(select min (csc.statementDate)
					   from tContractStCycle csc
					  where csc.branch = ctl.branch
						and csc.contractNo = ctl.contractNo
						and csc.StatementDate >= ctl.postDate
					 ) StatementDate,
					 case
					 when ctin.itemName = ''ITEMDEPOSITDOM'' then 1
					 when ctin.itemName = ''ITEMDEPOSITINT'' then 2
					 else -1
					 end currencyNumber, ctl.packNo
				from tContractTypeItemName ctin, tContractItem ci, tContractTrxnList ctl
			   where ctin.branch = ' || cbranch || '
				 and ctin.contractType = ' || pcontracttype || '
				 and ctin.itemName like ''ITEMDEPOSIT%''
				 and ctin.branch = ci.branch
				 and ctin.itemCode = ci.itemCode
				 and ctl.branch = ci.branch
				 and ctl.contractNo = ci.no
				 and ctl.accountNo = ci.key
			group by ctl.branch, ctl.contractNo, ctin.contractType, ctin.contractType, ctl.postDate, ctin.itemName, ctl.packNo
			 )
			where currencyNumber = ' || pcurrencynumber || '

			union all
			   -- {{{{{ Query below creates empty entries for each statement date in order to avoid special cases handling when there were no transactions within a cycle
			   select csmpd.branch, csc.contractNo, ctin.contractType, csc.StatementDate trxnDate,
					  0 debitAmount,
					  0 creditAmount,
					  0 reverseDebitAmount,
					  0 reverseCreditAmount,
					  csc.statementDate statementDate,
					  csmpd.currencyNumber,
					  0 packNo
				 from tContractStMinPaymentData csmpd, tContractStCycle csc, tContractItem ci, tContractTypeItemName ctin
				where ctin.branch = ' || cbranch || '
				  and ctin.contractType = ' || pcontracttype || '
				  and ctin.itemName like ''ITEMDEPOSIT%''
				  and ctin.branch = ci.branch
				  and ctin.itemCode = ci.itemCode
				  and csc.branch = ci.branch
				  and csc.contractNo = ci.no
				  and csmpd.branch = csc.branch
				  and csmpd.scRecNo = csc.recNo
				  and csmpd.currencyNumber = ' || pcurrencynumber || '
				  and csmpd.currencyNumber = case
											 when ctin.itemName = ''ITEMDEPOSITDOM'' then 1
											 when ctin.itemName = ''ITEMDEPOSITINT'' then 2
											 else -1
											 end
				   -- }}}}}
			  )
		where statementDate is not null -- if Statement Date is null then it means that it has not passed yet
		';
		EXECUTE IMMEDIATE (' create unique index ibal_' || pcontracttype || '_' || cbranch || '_' ||
						  pcurrencynumber || ' on tNA_bal_' || pcontracttype || '_' || cbranch || '_' ||
						  pcurrencynumber || ' (
						contractNo,
						StatementDate
						)');
	
		EXECUTE IMMEDIATE '
		   begin
			 select trxn.branch, csc.contractNo, csc.statementDate, trxn.trxnDate,
					   trxn.debitAmount,
					   trxn.creditAmount,
					   trxn.reverseDebitAmount,
					   trxn.reverseCreditAmount,
					   trxn.currencyNumber,
					   trxn.packNo, trxn.contractType, csc.dueDate, csc.recNo, csc.minPayment, bal.SDAmount, csc.createDate, csc.lastDueDate, csc.NextStatementDate
			   bulk collect into OverdueParametersCalculation.sTrxnAndCycleArray
			   from tNA_csc_' || pcontracttype || '_' || cbranch || '_' ||
						  pcurrencynumber || ' csc, tNA_trxn_' || pcontracttype || '_' || cbranch || '_' ||
						  pcurrencynumber || ' trxn, tNA_bal_' || pcontracttype || '_' || cbranch || '_' ||
						  pcurrencynumber || ' bal
			  where csc.contractType(+) = ' || pcontracttype || '
				and trxn.contractNo = csc.contractNo (+)
				and trxn.StatementDate = csc.StatementDate(+)
				and bal.contractNo = trxn.contractNo
				and bal.statementDAte = trxn.StatementDate
			 order by trxn.branch, csc.contractNo, trxn.trxnDate, csc.recNo, trxn.packNo;
		   end;';
	
		FOR i IN 1 .. strxnandcyclearray.count
		LOOP
			IF strxnandcyclearray(i)
			 .trxndate = strxnandcyclearray(i).duedate
				AND strxnandcyclearray(i).packno = 0
				AND strxnandcyclearray.exists(i + 1)
				AND strxnandcyclearray(i + 1).trxndate = strxnandcyclearray(i).duedate
			   
				AND strxnandcyclearray(i).contractno = strxnandcyclearray(i + 1).contractno
			
			THEN
				NULL;
				custom_s.say(' - info: Transaction was not handled', 1);
			ELSE
				IF vcontractno IS NULL
				THEN
					vcontractno   := strxnandcyclearray(i).contractno;
					vmppayoffdate := strxnandcyclearray(i).createdate;
					custom_s.say(cmethodname ||
								 ' - info: VERY FIRST CONTRACT has been taken for handling. ContractNo = ' ||
								 vcontractno
								,1);
				END IF;
			
				IF vrecno IS NULL
				THEN
					vrecno         := strxnandcyclearray(i).recno;
					vstatementdate := strxnandcyclearray(i).statementdate;
					vminpayment    := strxnandcyclearray(i).minpayment;
					vsdamount      := strxnandcyclearray(i).sdamount;
					custom_s.say(cmethodname ||
								 ' - info: Very first tContractStCycle.recNo has been taken for handling. vRecNo = ' ||
								 vrecno || ', Statement Date = ' || htools.d2s(vstatementdate) ||
								 ', SDAmount = ' || vsdamount
								,1);
				
					vprevmpovd_onduedatearray(vrecno) := 0;
					custom_s.say(cmethodname || '    1. vPrevMPOvd_OnDueDateArray (' || vrecno ||
								 ') = ' || vprevmpovd_onduedatearray(vrecno));
				
				END IF;
			
				IF vrecno != strxnandcyclearray(i).recno
				THEN
					vindex := vindex + 1;
					vaggregatedtrxnvarr.extend;
					vaggregatedtrxnrow := typeaggregatedtrxn_obj(vtrxndate
																,vdebitamount
																,vcreditamount
																,vrevdebitamount
																,vrevcreditamount
																,vrepayment
																,vpackno
																,vmppayoffdate
																,vpaidamount
																,vreduceddebit
																,vrevdebitoverplus);
					vaggregatedtrxnvarr(vindex) := vaggregatedtrxnrow;
					custom_s.say(cmethodname ||
								 '    -> tContractStCycle.recNo was changed. Index for vAggregatedTrxnVarr (vIndex) = ' ||
								 vindex || ', vTrxnDate = ' || htools.d2s(vtrxndate) ||
								 ', vPacNo = ' || vpackno || ', Old RecNo (vRecNo) = ' || vrecno
								,1);
					custom_s.say(cmethodname || '    -> (2) SAVED: TrxnDate = ' ||
								 htools.d2s(vtrxndate) || ', Debit = ' || vdebitamount ||
								 ', Credit = ' || vcreditamount || ', RevDebit = ' ||
								 vrevdebitamount || ', RevCredit = ' || vrevcreditamount ||
								 ', vReducedDebit = ' || vreduceddebit || ', vRevDebitOverplus = ' ||
								 vrevdebitoverplus || ', vPaidAmount = ' || vpaidamount ||
								 ', vRepayment = ' || vrepayment || ', vMPPayOffDate = ' ||
								 htools.d2s(vmppayoffdate));
					vmppayoffdate_atcycleendarray(vrecno) := vmppayoffdate;
					vrecnoarray(vrecno) := vrecno;
					vaggregatedtrxnarray(vrecno) := vaggregatedtrxnvarr;
					vminpaymentarray(vrecno) := vminpayment;
					vsdamountarray(vrecno) := vsdamount;
					vbrancharray(vrecno) := cbranch;
					vcurrencynumberarray(vrecno) := pcurrencynumber;
				
					IF vcontractno != strxnandcyclearray(i).contractno
					THEN
						custom_s.say(cmethodname ||
									 ' - info: ContractNo is changed. Old ContractNo (vContractNo) = ' ||
									 vcontractno
									,1);
						vaggregatedtrxnarray(vrecno) := vaggregatedtrxnvarr;
						updateminpaymentdata(pcurrencynumber);
						custom_s.say(cmethodname ||
									 ' -> NEW CONTRACT to hanlde (sTrxnAndCycleArray (i).contractNo) = ' || strxnandcyclearray(i)
									 .contractno || ', new recNo (sTrxnAndCycleArray (i).RecNo) = ' || strxnandcyclearray(i)
									 .recno ||
									 ', new Statement Date (sTrxnAndCycleArray (i).StatementDate) = ' ||
									 htools.d2s(strxnandcyclearray(i).statementdate));
					
						vmppayoffdate := strxnandcyclearray(i).createdate;
					END IF;
				
					vprevmpovd_onduedatearray(strxnandcyclearray(i).recno) := 0;
					custom_s.say(cmethodname || '    0. vPrevMPOvd_OnDueDateArray (' || strxnandcyclearray(i)
								 .recno || ') = ' ||
								 vprevmpovd_onduedatearray(strxnandcyclearray(i).recno));
				
					vrecno            := strxnandcyclearray(i).recno;
					vstatementdate    := strxnandcyclearray(i).statementdate;
					vcontractno       := strxnandcyclearray(i).contractno;
					vminpayment       := strxnandcyclearray(i).minpayment;
					vsdamount         := strxnandcyclearray(i).sdamount;
					vdebitamount      := 0;
					vcreditamount     := 0;
					vrevdebitamount   := 0;
					vrevcreditamount  := 0;
					vpaidamount       := 0;
					vrepayment        := 0;
					vrevdebitoverplus := 0;
					vreduceddebit     := 0;
				
					vindex              := 0;
					vaggregatedtrxnvarr := NEW typeaggregatedtrxn_varr();
					vtrxndate           := NULL;
					vpackno             := NULL;
				END IF;
			
				IF vtrxndate IS NULL
				THEN
					vtrxndate          := strxnandcyclearray(i).trxndate;
					vpackno            := strxnandcyclearray(i).packno;
					vaggregatedtrxnrow := typeaggregatedtrxn_obj(vtrxndate
																,vdebitamount
																,vcreditamount
																,vrevdebitamount
																,vrevcreditamount
																,vrepayment
																,vpackno
																,vmppayoffdate
																,vpaidamount
																,vreduceddebit
																,vrevdebitoverplus);
				END IF;
			
				IF vtrxndate != strxnandcyclearray(i).trxndate
				   OR vpackno != strxnandcyclearray(i).packno
				THEN
					vindex := vindex + 1;
					vaggregatedtrxnvarr.extend;
					custom_s.say(cmethodname ||
								 '    -> Transaction date or PackNo were changed. Index for vAggregatedTrxnVarr (vIndex) = ' ||
								 vindex || ', Old trxnDate (vTrxnDate) = ' ||
								 htools.d2s(vtrxndate) ||
								 ', new TrxnDate (sTrxnAndCycleArray (i).trxnDate) = ' ||
								 htools.d2s(strxnandcyclearray(i).trxndate) ||
								 ', Old PackNo (vPacNo) = ' || vpackno ||
								 ', New PackNo (sTrxnAndCycleArray (i).PackNo) = ' || strxnandcyclearray(i)
								 .packno);
					custom_s.say(cmethodname || '    -> (1) SAVED: TrxnDate = ' ||
								 htools.d2s(vtrxndate) || ', Debit = ' || vdebitamount ||
								 ', Credit = ' || vcreditamount || ', RevDebit = ' ||
								 vrevdebitamount || ', RevCredit = ' || vrevcreditamount ||
								 ', vReducedDebit = ' || vreduceddebit || ', vRevDebitOverplus = ' ||
								 vrevdebitoverplus || ', vPaidAmount = ' || vpaidamount ||
								 ', vRepayment = ' || vrepayment || ', vMPPayOffDate = ' ||
								 htools.d2s(vmppayoffdate));
					vaggregatedtrxnrow := typeaggregatedtrxn_obj(vtrxndate
																,vdebitamount
																,vcreditamount
																,vrevdebitamount
																,vrevcreditamount
																,vrepayment
																,vpackno
																,vmppayoffdate
																,vpaidamount
																,vreduceddebit
																,vrevdebitoverplus);
					vaggregatedtrxnvarr(vindex) := vaggregatedtrxnrow;
				
					vmppayoffdate_atcycleendarray(vrecno) := vmppayoffdate;
				
					vtrxndate := strxnandcyclearray(i).trxndate;
					vpackno   := strxnandcyclearray(i).packno;
				END IF;
			
				vdebitamount     := vdebitamount + strxnandcyclearray(i).debitamount;
				vcreditamount    := vcreditamount + strxnandcyclearray(i).creditamount;
				vrevdebitamount  := vrevdebitamount + strxnandcyclearray(i).reversedebitamount;
				vrevcreditamount := vrevcreditamount + strxnandcyclearray(i).reversecreditamount;
			
				vpaidamount := vpaidamount + strxnandcyclearray(i).creditamount;
				vdelta      := least(vpaidamount, strxnandcyclearray(i).reversecreditamount);
				vpaidamount := vpaidamount - vdelta;
			
				vreduceddebit     := vreduceddebit + strxnandcyclearray(i).debitamount;
				vdelta            := least(vreduceddebit, strxnandcyclearray(i).reversedebitamount);
				vreduceddebit     := vreduceddebit - vdelta;
				vrevdebitoverplus := vrevdebitoverplus +
									 (strxnandcyclearray(i).reversedebitamount - vdelta);
			
				vrepayment := vpaidamount +
							  greatest(vrevdebitoverplus -
									   (greatest(abs(least(strxnandcyclearray(i).sdamount, 0)), 0) - strxnandcyclearray(i)
									   .minpayment)
									  ,0);
			
				vrepayment_atcycleendarrary(vrecno) := vrepayment;
			
				IF strxnandcyclearray(i).trxndate <= strxnandcyclearray(i).duedate
				THEN
					custom_s.say('### TEST-0', 1);
				
					IF NOT vminpaymentarray.exists(vminpaymentarray.prior(vrecno))
					   AND strxnandcyclearray(i).trxndate < strxnandcyclearray(i).duedate
					THEN
						vmppayoffdate := strxnandcyclearray(i).createdate;
						custom_s.say('### TEST-1', 1);
					ELSIF (vminpaymentarray.exists(vminpaymentarray.prior(vrecno)) AND
						  (vrepayment +
						  vrepayment_atcycleendarrary(vrepayment_atcycleendarrary.prior(vrecno))) >=
						  vminpaymentarray(vminpaymentarray.prior(vrecno)) AND strxnandcyclearray(i)
						  .trxndate < strxnandcyclearray(i).duedate OR
						  vrepayment >= strxnandcyclearray(i).minpayment AND strxnandcyclearray(i)
						  .trxndate = strxnandcyclearray(i).duedate AND
						  NOT
						   (strxnandcyclearray.exists(i + 1) AND strxnandcyclearray(i + 1).trxndate = strxnandcyclearray(i)
						   .duedate AND strxnandcyclearray(i + 1).contractno = vcontractno))
						  AND vmppayoffdate IS NULL
					THEN
						vmppayoffdate := strxnandcyclearray(i).trxndate;
						custom_s.say('### TEST-2', 1);
					ELSIF vminpaymentarray.exists(vminpaymentarray.prior(vrecno))
						  AND (vrepayment +
							   vrepayment_atcycleendarrary(vrepayment_atcycleendarrary.prior(vrecno))) <
						  vminpaymentarray(vminpaymentarray.prior(vrecno))
						  AND strxnandcyclearray(i).trxndate < strxnandcyclearray(i).duedate
					THEN
						vmppayoffdate := NULL;
						custom_s.say('### TEST-3', 1);
					ELSIF NOT vminpaymentarray.exists(vminpaymentarray.prior(vrecno))
						  AND vrepayment < strxnandcyclearray(i).minpayment
						  AND strxnandcyclearray(i).trxndate = strxnandcyclearray(i).duedate
						  AND NOT (strxnandcyclearray.exists(i + 1) AND strxnandcyclearray(i + 1)
						   .trxndate = strxnandcyclearray(i)
						   .duedate AND strxnandcyclearray(i + 1).contractno = vcontractno)
					THEN
						vmppayoffdate := NULL;
						custom_s.say('### TEST-4', 1);
					ELSIF vrepayment < strxnandcyclearray(i).minpayment
						  AND strxnandcyclearray(i).trxndate = strxnandcyclearray(i).duedate
						  AND NOT (strxnandcyclearray.exists(i + 1) AND strxnandcyclearray(i + 1)
						   .trxndate = strxnandcyclearray(i)
						   .duedate AND strxnandcyclearray(i + 1).contractno = vcontractno)
					THEN
						vmppayoffdate := NULL;
						custom_s.say('### TEST-5', 1);
					END IF;
				ELSE
					custom_s.say('### TEST-6', 1);
				
					IF vrepayment >= strxnandcyclearray(i).minpayment
					   AND vmppayoffdate IS NULL
					THEN
						vmppayoffdate := strxnandcyclearray(i).trxndate;
						custom_s.say('### TEST-7', 1);
					ELSIF vrepayment < strxnandcyclearray(i).minpayment
					THEN
						vmppayoffdate := NULL;
						custom_s.say('### TEST-8', 1);
					END IF;
				
				END IF;
				custom_s.say(cmethodname || '     vMPPayOffDate = ' || htools.d2s(vmppayoffdate));
			
				IF strxnandcyclearray(i).duedate = strxnandcyclearray(i).trxndate
					AND strxnandcyclearray(i).lastduedate IS NOT NULL
				THEN
					vunpaidsdamount_onduedatearray(vrecno) := abs(least(vpaidamount +
																		vrevdebitoverplus -
																		abs(least(strxnandcyclearray(i)
																				  .sdamount
																				 ,0))
																	   ,0));
				ELSIF strxnandcyclearray(i).trxndate <= strxnandcyclearray(i).duedate
					   AND strxnandcyclearray(i).lastduedate IS NULL
				THEN
					vunpaidsdamount_onduedatearray(vrecno) := 0;
				END IF;
			
				IF strxnandcyclearray(i).duedate = strxnandcyclearray(i).trxndate
					AND strxnandcyclearray(i).lastduedate IS NOT NULL
				THEN
					voverdueamount_onduedatearray(vrecno) := abs(least(vrepayment - strxnandcyclearray(i)
																	   .minpayment
																	  ,0));
				ELSIF strxnandcyclearray(i).trxndate <= strxnandcyclearray(i).duedate
					   AND strxnandcyclearray(i).lastduedate IS NULL
				THEN
					voverdueamount_onduedatearray(vrecno) := 0;
				END IF;
			
				IF strxnandcyclearray(i).trxndate = strxnandcyclearray(i).duedate
					AND
					vrepayment_atcycleendarrary.exists(vrepayment_atcycleendarrary.prior(vrecno))
					AND strxnandcyclearray(i).lastduedate IS NOT NULL
				THEN
					custom_s.say(cmethodname ||
								 '    vMinPaymentArray(vMinPaymentArray.prior(vRecNo)) = ' ||
								 vminpaymentarray(vminpaymentarray.prior(vrecno)) ||
								 ', vRepayment_AtCycleEndArrary.prior (vRepayment_AtCycleEndArrary (vRecNo)) = ' ||
								 vrepayment_atcycleendarrary(vrepayment_atcycleendarrary.prior(vrecno)) ||
								 ', vRepayment = ' || vrepayment
								,1);
					vprevmpovd_onduedatearray(vrecno) := greatest(nvl(vminpaymentarray(vminpaymentarray.prior(vrecno))
																	 ,0) -
																  (nvl(vrepayment_atcycleendarrary(vrepayment_atcycleendarrary.prior(vrecno))
																	  ,0) + nvl(vrepayment, 0))
																 ,0);
					custom_s.say(cmethodname || '    vPrevMPOvd_OnDueDateArray (' || vrecno ||
								 ') = ' || vprevmpovd_onduedatearray(vrecno)
								,1);
				ELSIF strxnandcyclearray(i).trxndate < strxnandcyclearray(i).duedate
					   AND strxnandcyclearray(i).lastduedate IS NULL
				THEN
					vprevmpovd_onduedatearray(vrecno) := 0;
					custom_s.say(cmethodname || '    2. vPrevMPOvd_OnDueDateArray (' || vrecno ||
								 ') = ' || vprevmpovd_onduedatearray(vrecno)
								,1);
				END IF;
			
			END IF;
		END LOOP;
	
		IF strxnandcyclearray.count != 0
		THEN
			custom_s.say(cmethodname || '   (3) -> SAVED: TrxnDate = ' || htools.d2s(vtrxndate) ||
						 ', Debit = ' || vdebitamount || ', Credit = ' || vcreditamount ||
						 ', RevDebit = ' || vrevdebitamount || ', RevCredit = ' ||
						 vrevcreditamount || ', vReducedDebit = ' || vreduceddebit ||
						 ', vRevDebitOverplus = ' || vrevdebitoverplus || ', vPaidAmount = ' ||
						 vpaidamount || ', vRepayment = ' || vrepayment || ', vMPPayOffDate = ' ||
						 htools.d2s(vmppayoffdate));
			vrecnoarray(vrecno) := vrecno;
			vaggregatedtrxnarray(vrecno) := vaggregatedtrxnvarr;
			vminpaymentarray(vrecno) := vminpayment;
			vsdamountarray(vrecno) := vsdamount;
			vbrancharray(vrecno) := cbranch;
			vcurrencynumberarray(vrecno) := pcurrencynumber;
		
			vprevmpovd_onduedatearray(vrecno) := 0;
			custom_s.say(cmethodname || '    3. vPrevMPOvd_OnDueDateArray (' || vrecno || ') = ' ||
						 vprevmpovd_onduedatearray(vrecno));
		
			vmppayoffdate_atcycleendarray(vrecno) := vmppayoffdate;
		
			vaggregatedtrxnrow := typeaggregatedtrxn_obj(vtrxndate
														,vdebitamount
														,vcreditamount
														,vrevdebitamount
														,vrevcreditamount
														,vrepayment
														,vpackno
														,vmppayoffdate
														,vpaidamount
														,vreduceddebit
														,vrevdebitoverplus);
			vindex             := vindex + 1;
			vaggregatedtrxnvarr.extend;
			custom_s.say(cmethodname ||
						 ' tContractStCycle.recNo was changed. Index for vAggregatedTrxnVarr (vIndex) = ' ||
						 vindex || ', vTrxnDate = ' || htools.d2s(vtrxndate) ||
						 ', Old PackNo (vPacNo) = ' || vpackno || ', Old RecNo (vRecNo) = ' ||
						 vrecno
						,1);
			vaggregatedtrxnvarr(vindex) := vaggregatedtrxnrow;
		
			custom_s.say(cmethodname || ' Debit = ' || vdebitamount || ', Credit = ' ||
						 vcreditamount || ', RevDebit = ' || vrevdebitamount || ', RevCredit = ' ||
						 vrevcreditamount || ', vReducedDebit = ' || vreduceddebit ||
						 ', vRevDebitOverplus = ' || vrevdebitoverplus || ', vPaidAmount = ' ||
						 vpaidamount || ', vRepayment = ' || vrepayment
						,1);
		
			vaggregatedtrxnarray(vrecno) := vaggregatedtrxnvarr;
		
			updateminpaymentdata(pcurrencynumber);
		
			COMMIT;
		END IF;
		wlog('Successful contracts handled - ' || vhandledcontrcounter ||
			 ', erroneous contracts - ' || verrcontrcounter);
		wlog('END.');
		term.close(shlog);
		custom_s.say(cmethodname || ' -->> END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			verrcontrcounter := verrcontrcounter + 1;
			vsqlcode         := vsqlcode;
			vsqlerrm         := SQLERRM || ' ' || dbms_utility.format_error_backtrace;
			custom_s.say('<Main> ' || vsqlcode || '  ' || vsqlerrm, 1);
			INSERT INTO tpaidhistorymigrerr
			VALUES
				(NULL
				,cbranch
				,pcontractno
				,pcontracttype
				,pcurrencynumber
				,'<Main> ' || vsqlcode || '  ' || vsqlerrm
				,NULL);
			term.close(shlog);
			custom_s.say(cmethodname || '  -->> END', 1);
	END paidhistorymigration_mscc;

	PROCEDURE fillstminpaymentdataarrays
	(
		paccountno      IN taccount.accountno%TYPE
	   ,pcurrencynumber IN tcontractstminpaymentdata.currencynumber%TYPE
	   ,pdate           DATE
	   ,pstatementdate  IN DATE := NULL
	)
	
	 IS
		cmethodname CONSTANT VARCHAR2(80) := cpackagename || '.FillStMinPaymentDataArrays';
		cbranch     CONSTANT NUMBER := custom_seance.getbranch;
	
		vcacheindex    VARCHAR2(50) := paccountno || '-' || pcurrencynumber || '-' ||
									   to_char(pdate, 'yyyy.mm.dd');
		vstatementdate DATE := coalesce(pstatementdate, pdate, to_date('01.01.2100', 'dd.mm.yyyy'));
		vindex         NUMBER;
	
	BEGIN
		t.enter(cmethodname
			   ,'pAccountNo = ' || paccountno || ', pCurrencyNumber = ' || pcurrencynumber ||
				', pDate = ' || htools.d2s(pdate) || ', pStatementDate = ' ||
				htools.d2s(pstatementdate));
	
		t.var('CacheIndex', vcacheindex);
	
		t.var('Records in cache', scache.count);
		IF scache.count >= 10
		THEN
			clearredundantcacherow;
			custom_s.say(cmethodname ||
						 '            - info: Redundant rows have been deleted from the cache');
		END IF;
	
		t.var('Data in cache', htools.b2s(scache.exists(vcacheindex)));
	
		IF NOT scache.exists(vcacheindex)
		THEN
		
			SELECT * BULK COLLECT
			INTO   scache(vcacheindex).minpaymentstdataarray
			FROM   vcontractstcyclempdata
			WHERE  branch = cbranch
			AND    accountno = paccountno
			AND    statementdate BETWEEN createdate AND vstatementdate
			AND    currencynumber = pcurrencynumber
			ORDER  BY statementdate;
		
			t.var('Cycles selected', scache(vcacheindex).minpaymentstdataarray.count);
		
			IF scache(vcacheindex).minpaymentstdataarray.count > 0
			THEN
			
				vindex := scache(vcacheindex).minpaymentstdataarray.count;
			
				t.var('Last selected SD'
					 ,htools.d2s(scache(vcacheindex).minpaymentstdataarray(vindex).statementdate));
				t.var('Discarding this cycle'
					 ,htools.b2s(scache(vcacheindex).minpaymentstdataarray(vindex)
								 .statementdate = vstatementdate));
			
				IF scache(vcacheindex).minpaymentstdataarray(vindex).statementdate = vstatementdate
				THEN
				
					scache(vcacheindex).minpayment_spec := scache(vcacheindex).minpaymentstdataarray(vindex)
														   .minpayment;
					scache(vcacheindex).sdamount_spec := scache(vcacheindex).minpaymentstdataarray(vindex)
														 .sdamount;
				
					scache(vcacheindex).minpaymentstdataarray.delete(vindex);
				END IF;
			
				IF scache(vcacheindex).minpaymentstdataarray.count > 0
				THEN
				
					vindex := scache(vcacheindex).minpaymentstdataarray.count;
				
					t.var('Using cycle with SD'
						 ,htools.d2s(scache(vcacheindex).minpaymentstdataarray(vindex)
									 .statementdate));
				
					scache(vcacheindex).lastaggrtrxnarrayforlastcycle := scache(vcacheindex).minpaymentstdataarray(vindex)
																		 .aggregatedtrxn;
				
					IF scache(vcacheindex)
					 .lastaggrtrxnarrayforlastcycle.exists(1)
						AND scache(vcacheindex).lastaggrtrxnarrayforlastcycle IS NOT NULL
					THEN
					
						FOR i IN 1 .. scache(vcacheindex).lastaggrtrxnarrayforlastcycle.count
						LOOP
						
							EXIT WHEN scache(vcacheindex).lastaggrtrxnarrayforlastcycle(i).trxndate > pdate;
						
							scache(vcacheindex).lastaggrtrxnrowforlastcycle := scache(vcacheindex)
																			   .lastaggrtrxnarrayforlastcycle(i);
						
							t.var('Taking TrxnDate'
								 ,htools.d2s(scache(vcacheindex)
											 .lastaggrtrxnrowforlastcycle.trxndate));
							t.var('Taking PackNo'
								 ,scache(vcacheindex).lastaggrtrxnrowforlastcycle.packno);
						END LOOP;
					END IF;
				END IF;
			
			END IF;
		
		END IF;
	
		t.var('Resulting cycles selected', scache(vcacheindex).minpaymentstdataarray.count);
	
		t.var('Resulting MinPayment_Spec', scache(vcacheindex).minpayment_spec);
		t.var('Resulting SDAmount_Spec', scache(vcacheindex).sdamount_spec);
		t.var('Resulting aggregated info TrxnDate'
			 ,htools.d2s(scache(vcacheindex).lastaggrtrxnrowforlastcycle.trxndate));
		t.var('Resulting aggregated info PackNo'
			 ,scache(vcacheindex).lastaggrtrxnrowforlastcycle.packno);
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END fillstminpaymentdataarrays;

	PROCEDURE prepareupd_contrstminpaymdata
	(
		pcontractno     tcontract.no%TYPE
	   ,paccountno      taccount.accountno%TYPE
	   ,pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE
	   ,ppackno         tcontracttrxnlist.packno%TYPE
	   ,ptrxndate       tcontracttrxnlist.postdate%TYPE
	   ,ptrxnamount     tcontracttrxnlist.amount%TYPE
	   ,ptrxntype       tcontracttrxnlist.trantype%TYPE
	   ,pnowstdate      BOOLEAN
	   ,pnowduedate     BOOLEAN
	) IS
		cmethodname CONSTANT VARCHAR2(90) := cpackagename || '.PrepareUpd_ContrStMinPaymData';
		cbranch     CONSTANT NUMBER := custom_seance.getbranch;
		coperdate   CONSTANT DATE := custom_seance.getoperdate;
	
		vdebitamount     NUMBER := 0;
		vcreditamount    NUMBER := 0;
		vrevdebitamount  NUMBER := 0;
		vrevcreditamount NUMBER := 0;
	
		vreduceddebit     NUMBER := 0;
		vrevdebitoverplus NUMBER := 0;
		vsdamount         NUMBER := 0;
		vpaidamount       NUMBER := 0;
		vrepayment        NUMBER := 0;
	
		vdelta NUMBER := 0;
	
		vmppayoffdate        DATE := NULL;
		vunpaidsdamount_ondd NUMBER := 0;
	
		vprevmpoverdue      NUMBER := 0;
		voverdueamount_ondd NUMBER;
	
		vindex NUMBER := 0;
	
		vcacheindex VARCHAR2(50) := paccountno || '-' || pcurrencynumber || '-' ||
									to_char(coperdate, 'yyyy.mm.dd');
	BEGIN
		custom_s.say(cmethodname || '  --<< BEGIN', 1);
		custom_s.say(cmethodname || '   - INPUT PARAMETERS: ', 1);
		custom_s.say(cmethodname || '     Contract Number (pContractNo) = ' || pcontractno, 1);
		custom_s.say(cmethodname || '     Account Number (pAccountNo) = ' || paccountno, 1);
		custom_s.say(cmethodname || '     Currency Number (pCurrencyNumber) = ' || pcurrencynumber
					,1);
		custom_s.say(cmethodname || '     Pack Number (pPackNo) = ' || ppackno, 1);
		custom_s.say(cmethodname || '     Transaction Date (pTrxnDate) = ' ||
					 htools.d2s(ptrxndate));
		custom_s.say(cmethodname || '     Transaction Amount (pTrxnAmount) = ' || ptrxnamount, 1);
		custom_s.say(cmethodname || '     Transaction Type (pTrxnType) = ' || ptrxntype ||
					 ', [1 - Debit, 2 - Reverse for Credit, 3 - Credit, 4 - Reverse for Debit]'
					,1);
		custom_s.say(cmethodname || '     Whether Statement Date is now (pNowStDate) = ' ||
					 service.iif(pnowstdate, 'YES', 'NO')
					,1);
		custom_s.say(cmethodname || '     Whether Due Date is now (pNowDueDate) = ' ||
					 service.iif(pnowduedate, 'YES', 'NO')
					,1);
		custom_s.say(cmethodname ||
					 '     [IMPLICIT] Contract Creation Date (ContractTypeSchema.sContractRow.CreateDate) = ' ||
					 htools.d2s(contracttypeschema.scontractrow.createdate));
		custom_s.say('', 1);
	
		IF ptrxntype = 1
		THEN
			vdebitamount := ptrxnamount;
		ELSIF ptrxntype = 2
		THEN
			vrevcreditamount := ptrxnamount;
		ELSIF ptrxntype = 3
		THEN
			vcreditamount := ptrxnamount;
		ELSIF ptrxntype = 4
		THEN
			vrevdebitamount := ptrxnamount;
		END IF;
	
		fillstminpaymentdataarrays(paccountno, pcurrencynumber, coperdate);
	
		IF NOT (scache.exists(vcacheindex) AND scache(vcacheindex).minpaymentstdataarray.exists(1) AND scache(vcacheindex)
			.minpaymentstdataarray IS NOT NULL)
		THEN
			custom_s.say(cmethodname || ' - info: No Statement Date passed');
			custom_s.say(cmethodname || '  -->> END');
			RETURN;
		END IF;
	
		IF scache(vcacheindex).lastaggrtrxnarrayforlastcycle IS NOT NULL
			AND scache(vcacheindex).lastaggrtrxnarrayforlastcycle.exists(1)
		THEN
			vindex := scache(vcacheindex).lastaggrtrxnarrayforlastcycle.count;
			custom_s.say(cmethodname ||
						 ' -> Current turnovers (from sCache(vCacheIndex).LastAggrTrxnROWForLastCycle): Debit = ' || scache(vcacheindex)
						 .lastaggrtrxnrowforlastcycle.debitamount || ', Credit = ' || scache(vcacheindex)
						 .lastaggrtrxnrowforlastcycle.creditamount || ', RevDebit = ' || scache(vcacheindex)
						 .lastaggrtrxnrowforlastcycle.reversedebitamount || ', RevCredit = ' || scache(vcacheindex)
						 .lastaggrtrxnrowforlastcycle.reversecreditamount || ', ReducedDebit = ' || scache(vcacheindex)
						 .lastaggrtrxnrowforlastcycle.reduceddebit || ', RevDebitOverplus = ' || scache(vcacheindex)
						 .lastaggrtrxnrowforlastcycle.revdebitoverplus || ', TrxnDate = ' || scache(vcacheindex)
						 .lastaggrtrxnrowforlastcycle.trxndate
						,1);
		
			IF scache(vcacheindex)
			 .lastaggrtrxnrowforlastcycle.trxndate IS NULL
				OR scache(vcacheindex).lastaggrtrxnarrayforlastcycle(vindex)
			   .trxndate > scache(vcacheindex).lastaggrtrxnrowforlastcycle.trxndate
			THEN
				error.raiseerror('Transactions with date ' ||
								 htools.d2s(scache(vcacheindex).lastaggrtrxnarrayforlastcycle(vindex)
											.trxndate) || ' have been adjusted already.' ||
								 ' To continue working you should undo all transactions between ' ||
								 htools.d2s((coperdate + 1)) || ' and ' ||
								 htools.d2s(scache(vcacheindex).lastaggrtrxnarrayforlastcycle(vindex)
											.trxndate));
			END IF;
		
		ELSE
			scache(vcacheindex).lastaggrtrxnrowforlastcycle := NEW typeaggregatedtrxn_obj(NULL
																						 ,NULL
																						 ,NULL
																						 ,NULL
																						 ,NULL
																						 ,NULL
																						 ,NULL
																						 ,NULL
																						 ,NULL
																						 ,NULL
																						 ,NULL);
			custom_s.say(cmethodname || '  - info: All Current turnovers are equal to zero', 1);
		END IF;
		custom_s.say(cmethodname ||
					 ' -> vIndex (sCache(vCacheIndex).LastAggrTrxnARRAYForLastCycle.count) = ' ||
					 vindex
					,1);
		custom_s.say(cmethodname || ' -> Input transaction: vDebitAmount = ' || vdebitamount ||
					 ', vCreditAmount = ' || vcreditamount || ', vRevCreditAmount = ' ||
					 vrevcreditamount || ', vRevDebitAmount = ' || vrevdebitamount
					,1);
	
		scache(vcacheindex).lastaggrtrxnrowforlastcycle.debitamount := vdebitamount +
																	   nvl(scache(vcacheindex)
																		   .lastaggrtrxnrowforlastcycle.debitamount
																		  ,0);
		scache(vcacheindex).lastaggrtrxnrowforlastcycle.creditamount := vcreditamount +
																		nvl(scache(vcacheindex)
																			.lastaggrtrxnrowforlastcycle.creditamount
																		   ,0);
		scache(vcacheindex).lastaggrtrxnrowforlastcycle.reversedebitamount := vrevdebitamount +
																			  nvl(scache(vcacheindex)
																				  .lastaggrtrxnrowforlastcycle.reversedebitamount
																				 ,0);
		scache(vcacheindex).lastaggrtrxnrowforlastcycle.reversecreditamount := vrevcreditamount +
																			   nvl(scache(vcacheindex)
																				   .lastaggrtrxnrowforlastcycle.reversecreditamount
																				  ,0);
		custom_s.say(cmethodname || ' -> Turnovers: vDebitTurnover = ' || scache(vcacheindex)
					 .lastaggrtrxnrowforlastcycle.debitamount || ', vCreditTurnover = ' || scache(vcacheindex)
					 .lastaggrtrxnrowforlastcycle.creditamount || ', vRevCreditTurnover = ' || scache(vcacheindex)
					 .lastaggrtrxnrowforlastcycle.reversecreditamount || ', vRevDebitTurnover = ' || scache(vcacheindex)
					 .lastaggrtrxnrowforlastcycle.reversedebitamount
					,1);
	
		vpaidamount := nvl(scache(vcacheindex).lastaggrtrxnrowforlastcycle.paid, 0) + vcreditamount;
		vdelta      := least(vpaidamount, vrevcreditamount);
		vpaidamount := vpaidamount - vdelta;
		custom_s.say(cmethodname || ' -> vPaidAmount = ' || vpaidamount || ', vRevCreditAmount = ' ||
					 vrevcreditamount || ', vDelta = ' || vdelta
					,1);
	
		vreduceddebit     := nvl(scache(vcacheindex).lastaggrtrxnrowforlastcycle.reduceddebit, 0) +
							 vdebitamount;
		vdelta            := least(vreduceddebit, vrevdebitamount);
		vreduceddebit     := vreduceddebit - vdelta;
		vrevdebitoverplus := nvl(scache(vcacheindex).lastaggrtrxnrowforlastcycle.revdebitoverplus
								,0) + (vrevdebitamount - vdelta);
		custom_s.say(cmethodname || ' -> vRevDebitAmount = ' || vrevdebitamount ||
					 ', vReducedDebit = ' || vreduceddebit || ', vRevDebitOverplus = ' ||
					 vrevdebitoverplus || ', vDelta = ' || vdelta
					,1);
	
		vsdamount := least(scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
						   .sdamount
						  ,0);
	
		vrepayment := vpaidamount + greatest(vrevdebitoverplus - (greatest(abs(vsdamount), 0) - scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
											 .minpayment)
											,0);
		custom_s.say(cmethodname || ' -> vSDAmount = ' || vsdamount || ', Repayment = ' ||
					 vrepayment ||
					 ', formula to Repayment calculaton [vPaidAmount + greatest(vRevDebitOverplus - (greatest(abs (vSDAmount), 0) - sCache(vCacheIndex).MinPaymentStDataArray(vMinPaymentStDataArray.count).MinPayment)]'
					,1);
	
		IF pnowduedate
		THEN
			custom_s.say(cmethodname || ' - info: Previous cycle`s MP overdue calculation', 1);
			IF scache(vcacheindex)
			 .minpaymentstdataarray.exists(scache(vcacheindex).minpaymentstdataarray.count - 1)
			THEN
				custom_s.say(cmethodname ||
							 ' -> Previous cycle`s MP (sCache(vCacheIndex).MinPaymentStDataArray.(sCache(vCacheIndex).MinPaymentStDataArray.count - 1).MinPayment) = ' || scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
							 .minpayment
							,1);
				custom_s.say(cmethodname ||
							 ' -> Previous cycle`s Repayemnt at the end of the cycle (sCache(vCacheIndex).MinPaymentStDataArray.(sCache(vCacheIndex).MinPaymentStDataArray.count - 1).Repayment_AtCycleEnd) = ' || scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
							 .repayment_atcycleend
							,1);
				custom_s.say(cmethodname || ' -> Current Cycle Repayment (vRepayment) = ' ||
							 vrepayment
							,1);
			
				vprevmpoverdue := greatest(nvl(scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
											   .minpayment
											  ,0) - (nvl(scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
														 .repayment_atcycleend
														,0) + nvl(vrepayment, 0))
										  ,0);
			ELSE
				custom_s.say(cmethodname ||
							 ' - info: Since previous cycle doesn`t exist then previuos cycle`s overdue is equal to 0'
							,1);
				vprevmpoverdue := 0;
			END IF;
		
			scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count).prevmpovd_onduedate := vprevmpoverdue;
		
			custom_s.say(cmethodname || ' -> Previous cycle`s MP overdue (vPrevMPOverdue) = ' ||
						 vprevmpoverdue
						,1);
		END IF;
	
		IF scache(vcacheindex).lastaggrtrxnrowforlastcycle.trxndate IS NULL
		THEN
			scache(vcacheindex).lastaggrtrxnrowforlastcycle := NEW
															   typeaggregatedtrxn_obj(ptrxndate
																					 ,vdebitamount
																					 ,vcreditamount
																					 ,vrevdebitamount
																					 ,vrevcreditamount
																					 ,0
																					 ,ppackno
																					 ,vmppayoffdate
																					 ,0
																					 ,0
																					 ,vrevdebitoverplus);
			scache(vcacheindex).lastaggrtrxnarrayforlastcycle := typeaggregatedtrxn_varr();
			vindex := vindex + 1;
			scache(vcacheindex).lastaggrtrxnarrayforlastcycle.extend;
			scache(vcacheindex).lastaggrtrxnarrayforlastcycle(vindex) := scache(vcacheindex)
																		 .lastaggrtrxnrowforlastcycle;
		END IF;
	
		IF ptrxndate != scache(vcacheindex).lastaggrtrxnrowforlastcycle.trxndate
		   OR ppackno != scache(vcacheindex).lastaggrtrxnrowforlastcycle.packno
		THEN
			custom_s.say(cmethodname ||
						 ' - info: trxnDate or packNo were changed therefore new record will be added into array'
						,1);
			custom_s.say(cmethodname ||
						 ' -> Old Trxn Date (sCache(vCacheIndex).LastAggrTrxnROWForLastCycle.trxnDate) = ' ||
						 htools.d2s(scache(vcacheindex).lastaggrtrxnrowforlastcycle.trxndate) ||
						 ', new Trxn Date (pTrxnDate) = ' || htools.d2s(ptrxndate) ||
						 ', old packNo (sCache(vCacheIndex).LastAggrTrxnROWForLastCycle.packNo) = ' || scache(vcacheindex)
						 .lastaggrtrxnrowforlastcycle.packno || ', new PackNo (pPackNo) = ' ||
						 ppackno
						,1);
		
			vindex := vindex + 1;
			custom_s.say(cmethodname ||
						 ' -> Index for vAggregatedTrxnVarr (vIndex) to insert new row = ' ||
						 vindex || ', pTrxnDate = ' || htools.d2s(ptrxndate) || ', pPackNo = ' ||
						 ppackno);
			scache(vcacheindex).lastaggrtrxnrowforlastcycle := typeaggregatedtrxn_obj(ptrxndate
																					 ,scache           (vcacheindex)
																					  .lastaggrtrxnrowforlastcycle.debitamount
																					 ,scache           (vcacheindex)
																					  .lastaggrtrxnrowforlastcycle.creditamount
																					 ,scache           (vcacheindex)
																					  .lastaggrtrxnrowforlastcycle.reversedebitamount
																					 ,scache           (vcacheindex)
																					  .lastaggrtrxnrowforlastcycle.reversecreditamount
																					 ,vrepayment
																					 ,ppackno
																					 ,vmppayoffdate
																					 ,vpaidamount
																					 ,vreduceddebit
																					 ,vrevdebitoverplus);
			scache(vcacheindex).lastaggrtrxnarrayforlastcycle.extend;
			scache(vcacheindex).lastaggrtrxnarrayforlastcycle(vindex) := scache(vcacheindex)
																		 .lastaggrtrxnrowforlastcycle;
		ELSE
			custom_s.say(cmethodname ||
						 ' - info: input trxnDate and packNo are the same as old ones'
						,1);
			custom_s.say(cmethodname || '  -> Index for vAggregatedTrxnVarr (vIndex) = ' || vindex ||
						 ', vTrxnDate = ' || htools.d2s(ptrxndate) || ', vPackNo = ' || ppackno
						,1);
			scache(vcacheindex).lastaggrtrxnrowforlastcycle := typeaggregatedtrxn_obj(ptrxndate
																					 ,scache           (vcacheindex)
																					  .lastaggrtrxnrowforlastcycle.debitamount
																					 ,scache           (vcacheindex)
																					  .lastaggrtrxnrowforlastcycle.creditamount
																					 ,scache           (vcacheindex)
																					  .lastaggrtrxnrowforlastcycle.reversedebitamount
																					 ,scache           (vcacheindex)
																					  .lastaggrtrxnrowforlastcycle.reversecreditamount
																					 ,vrepayment
																					 ,ppackno
																					 ,vmppayoffdate
																					 ,vpaidamount
																					 ,vreduceddebit
																					 ,vrevdebitoverplus);
			scache(vcacheindex).lastaggrtrxnarrayforlastcycle(vindex) := scache(vcacheindex)
																		 .lastaggrtrxnrowforlastcycle;
		END IF;
	
		IF pnowduedate
		THEN
			vunpaidsdamount_ondd := abs(least(vpaidamount + vrevdebitoverplus -
											  abs(least(scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
														.sdamount
													   ,0))
											 ,0));
			vunpaidsdamount_ondd := nvl(vunpaidsdamount_ondd, 0);
		
			voverdueamount_ondd := abs(least(vrepayment - scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
											 .minpayment
											,0));
			voverdueamount_ondd := nvl(voverdueamount_ondd, 0);
		
			scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count).overdueamount_onduedate := voverdueamount_ondd;
			scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count).unpaidsdamount_onduedate := vunpaidsdamount_ondd;
		
		ELSE
			vunpaidsdamount_ondd := nvl(scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
										.unpaidsdamount_onduedate
									   ,0);
		
			voverdueamount_ondd := nvl(scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
									   .overdueamount_onduedate
									  ,0);
		
		END IF;
		custom_s.say(cmethodname || ' -> Unpaid SD Amount On Due Date (vUnpaidSDAmount_OnDD) = ' ||
					 vunpaidsdamount_ondd ||
					 ', Overdue Amount on Due Date (vOverdueAmount_OnDD) = ' ||
					 voverdueamount_ondd
					,1);
	
		IF ptrxndate < scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
		  .duedate
		THEN
			custom_s.say(cmethodname ||
						 ' - info: Current transaction date is less than current cycle Due Date'
						,1);
			IF scache(vcacheindex)
			 .minpaymentstdataarray.exists(scache(vcacheindex).minpaymentstdataarray.count - 1)
			THEN
				custom_s.say(cmethodname || ' - info: Previous cycle exists', 1);
				IF scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
				 .minpayment > vrepayment + scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
				   .repayment_atcycleend
				THEN
					custom_s.say(cmethodname ||
								 ' -> Previous cycle Minimum Payment (sCache(vCacheIndex).MinPaymentStDataArray(sCache(vCacheIndex).MinPaymentStDataArray.count - 1).MinPayment) = ' || scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
								 .minpayment
								,1);
					custom_s.say(cmethodname ||
								 ' -> Previous cycle MP`s repayment (vRepayment + sCache(vCacheIndex).MinPaymentStDataArray(sCache(vCacheIndex).MinPaymentStDataArray.count - 1).Repayment_AtCycleEnd) = ' ||
								 (vrepayment + scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
								 .repayment_atcycleend)
								,1);
					vmppayoffdate := NULL;
				ELSE
					custom_s.say(cmethodname ||
								 ' - info: There is no overdue on current transaction date'
								,1);
					IF scache(vcacheindex).lastaggrtrxnarrayforlastcycle.exists(vindex - 1)
					THEN
						custom_s.say(cmethodname ||
									 ' -> Last MP_PayOffDate calculated within current cycle (sCache(vCacheIndex).LastAggrTrxnARRAYForLastCycle(vIndex - 1).MP_PayOffDate) = ' || scache(vcacheindex).lastaggrtrxnarrayforlastcycle(vindex - 1)
									 .mp_payoffdate
									,1);
						vmppayoffdate := scache(vcacheindex).lastaggrtrxnarrayforlastcycle(vindex - 1)
										 .mp_payoffdate;
					ELSE
						custom_s.say(cmethodname ||
									 ' -> MP_PayOffDate on Previous cycle`s end (sCache(vCacheIndex).MinPaymentStDataArray(sCache(vCacheIndex).MinPaymentStDataArray.count - 1).MP_PayOffDate_AtCycleEnd) = ' || scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
									 .mp_payoffdate_atcycleend
									,1);
						vmppayoffdate := scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
										 .mp_payoffdate_atcycleend;
					END IF;
					IF vmppayoffdate IS NULL
					THEN
						custom_s.say(cmethodname ||
									 ' - info: Since there is NO overdue and previously calculated MP_PayOffDate is null, then MP_PayOffDate is equal to current transaction date'
									,1);
						vmppayoffdate := ptrxndate;
					END IF;
				END IF;
			ELSE
				custom_s.say(cmethodname ||
							 ' - info: Current operational date is between the very first Statement Date and Due Date, therefore MP_PayOffDate is equal to the contract creation date'
							,1);
				vmppayoffdate := contracttypeschema.scontractrow.createdate;
				IF vmppayoffdate IS NULL
				THEN
					SELECT c.createdate
					INTO   vmppayoffdate
					FROM   tcontract c
					WHERE  c.branch = cbranch
					AND    c.no = pcontractno;
				END IF;
			END IF;
		ELSE
			custom_s.say(cmethodname ||
						 ' - info: current transaction date is more (or equal) than current cycle Due Date'
						,1);
			IF scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
			 .minpayment > vrepayment
			THEN
				custom_s.say(cmethodname ||
							 ' -> Current cycle Minimum Payment (sCache(vCacheIndex).MinPaymentStDataArray(sCache(vCacheIndex).MinPaymentStDataArray.count).MinPayment) = ' || scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
							 .minpayment
							,1);
				custom_s.say(cmethodname || ' -> Current cycle MP`s Repayment (vRepayment) = ' ||
							 vrepayment
							,1);
				vmppayoffdate := NULL;
			ELSE
				custom_s.say(cmethodname ||
							 ' - info: There is no overdue on current transaction date'
							,1);
				IF scache(vcacheindex).lastaggrtrxnarrayforlastcycle.exists(vindex - 1)
				THEN
					custom_s.say(cmethodname ||
								 ' -> Last MP_PayOffDate calculated within current cycle (sCache(vCacheIndex).LastAggrTrxnARRAYForLastCycle(vIndex - 1).MP_PayOffDate) = ' || scache(vcacheindex).lastaggrtrxnarrayforlastcycle(vindex - 1)
								 .mp_payoffdate
								,1);
					vmppayoffdate := scache(vcacheindex).lastaggrtrxnarrayforlastcycle(vindex - 1)
									 .mp_payoffdate;
				ELSE
					IF scache(vcacheindex)
					 .minpaymentstdataarray.exists(scache(vcacheindex)
													 .minpaymentstdataarray.count - 1)
					THEN
						custom_s.say(cmethodname ||
									 ' -> MP_PayOffDate on Previous cycle`s end (sCache(vCacheIndex).MinPaymentStDataArray(sCache(vCacheIndex).MinPaymentStDataArray.count - 1).MP_PayOffDate_AtCycleEnd) = ' || scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
									 .mp_payoffdate_atcycleend
									,1);
						vmppayoffdate := scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
										 .mp_payoffdate_atcycleend;
					ELSE
						custom_s.say(cmethodname ||
									 ' - info: transaction was posted on the very first Due Date'
									,1);
						vmppayoffdate := contracttypeschema.scontractrow.createdate;
						IF vmppayoffdate IS NULL
						THEN
							SELECT c.createdate
							INTO   vmppayoffdate
							FROM   tcontract c
							WHERE  c.branch = cbranch
							AND    c.no = pcontractno;
						END IF;
					END IF;
				END IF;
				IF vmppayoffdate IS NULL
				THEN
					custom_s.say(cmethodname ||
								 ' - info: Since there is NO overdue and previously calculated MP_PayOffDate is null, then MP_PayOffDate is equal to current transaction date'
								,1);
					vmppayoffdate := ptrxndate;
				END IF;
			END IF;
		END IF;
		scache(vcacheindex).lastaggrtrxnrowforlastcycle.mp_payoffdate := vmppayoffdate;
		scache(vcacheindex).lastaggrtrxnarrayforlastcycle(vindex) := scache(vcacheindex)
																	 .lastaggrtrxnrowforlastcycle;
	
		custom_s.say(cmethodname || ' -> Payoff Date (vMPPayOffDate) = ' ||
					 htools.d2s(vmppayoffdate));
	
		sprepareddataforupd(vcacheindex).screcno := scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
													.screcno;
		sprepareddataforupd(vcacheindex).repayment_atcycleend := vrepayment;
		sprepareddataforupd(vcacheindex).overdueamount_onduedate := voverdueamount_ondd;
		sprepareddataforupd(vcacheindex).unpaidsdamount_onduedate := vunpaidsdamount_ondd;
		sprepareddataforupd(vcacheindex).aggregatedtrxn := scache(vcacheindex)
														   .lastaggrtrxnarrayforlastcycle;
		sprepareddataforupd(vcacheindex).prevmpovd_onduedate := vprevmpoverdue;
		sprepareddataforupd(vcacheindex).mp_payoffdate_atcycleend := vmppayoffdate;
	
		scache(vcacheindex).dueamount := NULL;
	
		custom_s.say(cmethodname || '  -->> END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			custom_s.say(cmethodname || '  -->> END', 1);
			RAISE;
	END prepareupd_contrstminpaymdata;

	PROCEDURE update_contrstminpaymentdata
	(
		pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE
	   ,pnowstdate      BOOLEAN
	   ,pnowduedate     BOOLEAN
	   ,pcacheindex     VARCHAR2
		
	) IS
		cmethodname CONSTANT VARCHAR2(90) := cpackagename || '.Update_ContrStMinPaymentData';
		cbranch     CONSTANT NUMBER := custom_seance.getbranch;
	
		vscrecno tcontractstminpaymentdata.screcno%TYPE;
	
		vnowstatementdate BINARY_INTEGER := 0;
		vnowduedate       BINARY_INTEGER := 0;
	
	BEGIN
		custom_s.say(cmethodname || '  --<< BEGIN', 1);
	
		IF NOT sprepareddataforupd.exists(pcacheindex)
		THEN
			custom_s.say(cmethodname || '    NO DATA FOR THE TABLE UPDATE', 1);
			custom_s.say(cmethodname || '  -->> END', 1);
			RETURN;
		END IF;
	
		custom_s.say(cmethodname || '   - INPUT PARAMETERS: ', 1);
		custom_s.say(cmethodname || '     Currency Number (pCurrencyNumber) = ' || pcurrencynumber
					,1);
		custom_s.say(cmethodname || '     Whether Statement Date is now (pNowStDate) = ' ||
					 service.iif(pnowstdate, 'YES', 'NO')
					,1);
		custom_s.say(cmethodname || '     Whether Due Date is now (pNowDueDate) = ' ||
					 service.iif(pnowduedate, 'YES', 'NO')
					,1);
		custom_s.say(cmethodname || '     Index of the cache (pCacheIndex) = ' || pcacheindex, 1);
	
		custom_s.say(cmethodname ||
					 '     [IMPLICIT] Data for the update (sPreparedDataForUpd [pCacheIndex]): '
					,1);
		custom_s.say(cmethodname || '        sPreparedDataForUpd [pCacheIndex].scRecNo = ' || sprepareddataforupd(pcacheindex)
					 .screcno
					,1);
		custom_s.say(cmethodname ||
					 '        sPreparedDataForUpd [pCacheIndex].Repayment_AtCycleEnd = ' || sprepareddataforupd(pcacheindex)
					 .repayment_atcycleend
					,1);
		custom_s.say(cmethodname ||
					 '        sPreparedDataForUpd [pCacheIndex].OverDueAmount_OnDueDate = ' || sprepareddataforupd(pcacheindex)
					 .overdueamount_onduedate
					,1);
		custom_s.say(cmethodname ||
					 '        sPreparedDataForUpd [pCacheIndex].UnpaidSDAmount_OnDueDate = ' || sprepareddataforupd(pcacheindex)
					 .unpaidsdamount_onduedate
					,1);
		custom_s.say(cmethodname ||
					 '        sPreparedDataForUpd [pCacheIndex].PrevMPOvd_OnDueDate = ' || sprepareddataforupd(pcacheindex)
					 .prevmpovd_onduedate
					,1);
		custom_s.say(cmethodname ||
					 '        sPreparedDataForUpd [pCacheIndex].MP_PayOffDate_AtCycleEnd = ' ||
					 htools.d2s(sprepareddataforupd(pcacheindex).mp_payoffdate_atcycleend));
		custom_s.say(cmethodname || ' ', 1);
	
		vscrecno := sprepareddataforupd(pcacheindex).screcno;
		custom_s.say(cmethodname ||
					 ' -> tContractStMinPaymentData.scRecNo to be updated (vScRecNo) = ' ||
					 vscrecno
					,1);
	
		IF pnowstdate
		THEN
			vnowstatementdate := 1;
		END IF;
		IF pnowduedate
		THEN
			vnowduedate := 1;
		END IF;
	
		UPDATE tcontractstminpaymentdata
		SET    aggregatedtrxn           = sprepareddataforupd(pcacheindex).aggregatedtrxn
			  ,unpaidsdamount_onduedate = decode(vnowduedate
												,1
												,sprepareddataforupd(pcacheindex)
												 .unpaidsdamount_onduedate
												,unpaidsdamount_onduedate)
			  ,repayment_atcycleend     = decode(vnowstatementdate
												,1
												,sprepareddataforupd(pcacheindex)
												 .repayment_atcycleend
												,repayment_atcycleend)
			   
			  ,prevmpovd_onduedate      = decode(vnowduedate
												,1
												,sprepareddataforupd(pcacheindex)
												 .prevmpovd_onduedate
												,prevmpovd_onduedate)
			  ,overdueamount_onduedate  = decode(vnowduedate
												,1
												,sprepareddataforupd(pcacheindex)
												 .overdueamount_onduedate
												,overdueamount_onduedate)
			  ,mp_payoffdate_atcycleend = decode(vnowstatementdate
												,1
												,sprepareddataforupd(pcacheindex)
												 .mp_payoffdate_atcycleend
												,mp_payoffdate_atcycleend)
		
		WHERE  branch = cbranch
		AND    screcno = vscrecno
		AND    currencynumber = pcurrencynumber;
		custom_s.say(cmethodname || ' -> tContractStMinPaymentData Rows updated (sql%rowcount) = ' ||
					 SQL%ROWCOUNT
					,1);
	
		clearcache(pcacheindex);
	
		custom_s.say(cmethodname || '  -->> END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			clearverificationarray;
			error.save(cmethodname);
			custom_s.say(cmethodname || '  -->> END', 1);
			RAISE;
	END update_contrstminpaymentdata;

	PROCEDURE rollbackaggregatedtrxn
	(
		paccountno       taccount.accountno%TYPE
	   ,pcurrencynumber  tcontractstminpaymentdata.currencynumber%TYPE
	   ,ppackno          tcontracttrxnlist.packno%TYPE
	   ,pifduedate       BOOLEAN
	   ,pifstatementdate BOOLEAN
	) IS
		cmethodname CONSTANT VARCHAR2(80) := cpackagename || '.RollbackAggregatedTrxn';
		cbranch     CONSTANT NUMBER := custom_seance.getbranch;
		coperdate   CONSTANT DATE := custom_seance.getoperdate;
	
		vcurrentaggregatedtrxn  tcontractstminpaymentdata.aggregatedtrxn%TYPE;
		vreturnedaggregatedtrxn tcontractstminpaymentdata.aggregatedtrxn%TYPE;
	
		vrecno                    tcontractstminpaymentdata.screcno%TYPE;
		vunpaidsdamount_onduedate tcontractstminpaymentdata.unpaidsdamount_onduedate%TYPE := 0;
	
		voverdueamount_onduedate tcontractstminpaymentdata.overdueamount_onduedate%TYPE := 0;
		vprevmpovd_onduedate     tcontractstminpaymentdata.prevmpovd_onduedate%TYPE := 0;
	
		vmp_payoffdate_atcycleend tcontractstminpaymentdata.mp_payoffdate_atcycleend%TYPE;
		vrepayment_atcycleend     tcontractstminpaymentdata.repayment_atcycleend%TYPE := 0;
	
		vcacheindex VARCHAR2(50);
	BEGIN
		custom_s.say(cmethodname || ' ', 1);
		custom_s.say(cmethodname || '  --<< BEGIN', 1);
		custom_s.say(cmethodname || '    -- INPUT PARAMETERS: ', 1);
		custom_s.say(cmethodname || '      --  Currency Number (pCurrencyNumber) = ' ||
					 pcurrencynumber
					,1);
		custom_s.say(cmethodname || '      --  Package Number (pPackNo) = ' || ppackno, 1);
		custom_s.say(cmethodname ||
					 '      --  Whether rollbacked packNo was created on Due Date (pIfDueDate) = ' ||
					 service.iif(pifduedate, 'YES', 'NO')
					,1);
		custom_s.say(cmethodname ||
					 '      --  Whether rollbacked packNo was created on Statement Date (pIfStatementDate) = ' ||
					 service.iif(pifstatementdate, 'YES', 'NO')
					,1);
		custom_s.say(cmethodname || '      --  pAccountNo = ' || paccountno, 1);
	
		fillstminpaymentdataarrays(paccountno, pcurrencynumber, NULL);
		vcacheindex := paccountno || '-' || pcurrencynumber || '-' || NULL;
		custom_s.say(cmethodname || '      Cache Index (vCacheIndex) = ' || vcacheindex, 1);
	
		IF pifstatementdate
		THEN
			custom_s.say(cmethodname || '      - info:  Data is undone on Statement Date', 1);
			vmp_payoffdate_atcycleend := NULL;
			vrepayment_atcycleend     := NULL;
		END IF;
	
		IF scache.exists(vcacheindex)
		   AND scache(vcacheindex).minpaymentstdataarray IS NOT NULL
		   AND scache(vcacheindex).minpaymentstdataarray.exists(1)
		THEN
			vrecno := scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
					  .screcno;
		END IF;
		custom_s.say(cmethodname || '      Record Number to be changed (vRecNo) = ' || vrecno, 1);
	
		SELECT aggregatedtrxn
		INTO   vcurrentaggregatedtrxn
		FROM   tcontractstminpaymentdata
		WHERE  branch = cbranch
		AND    screcno = vrecno
		AND    currencynumber = pcurrencynumber;
	
		IF pifduedate
		THEN
			custom_s.say(cmethodname || '      - info:  Data is undone on Due Date', 1);
			vunpaidsdamount_onduedate := 0;
		
			voverdueamount_onduedate := 0;
			vprevmpovd_onduedate     := 0;
		
		ELSE
			IF vcurrentaggregatedtrxn.exists(1)
			   AND vcurrentaggregatedtrxn IS NOT NULL
			THEN
				vunpaidsdamount_onduedate := scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
											 .unpaidsdamount_onduedate;
			
				voverdueamount_onduedate := scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
											.overdueamount_onduedate;
				vprevmpovd_onduedate     := scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
											.prevmpovd_onduedate;
			
			ELSE
				vunpaidsdamount_onduedate := 0;
			
				voverdueamount_onduedate := 0;
				vprevmpovd_onduedate     := 0;
			
			END IF;
		END IF;
		custom_s.say(cmethodname ||
					 '      UnpaidSDAmount On Due Date to be set (vUnpaidSDAmount_OnDueDate) = ' ||
					 vunpaidsdamount_onduedate
					,1);
		custom_s.say(cmethodname ||
					 '      Overdue Amount On Due Date to be set (vOverdueAmount_OnDueDate) = ' ||
					 voverdueamount_onduedate
					,1);
		custom_s.say(cmethodname ||
					 '      Previous Cycle`s Overdue to be set (vPrevMPOvd_OnDueDate) = ' ||
					 vprevmpovd_onduedate
					,1);
		custom_s.say(cmethodname ||
					 '      Pay Off Date At Cycle End to be set (vMP_PayOffDate_AtCycleEnd) = ' ||
					 htools.d2s(vmp_payoffdate_atcycleend));
		custom_s.say(cmethodname ||
					 '      Repayment At Cycle End to be set (vRepayment_AtCycleEnd) = ' ||
					 vrepayment_atcycleend
					,1);
	
		vreturnedaggregatedtrxn := NEW typeaggregatedtrxn_varr();
	
		IF vcurrentaggregatedtrxn.exists(1)
		   AND vcurrentaggregatedtrxn IS NOT NULL
		THEN
			FOR i IN 1 .. vcurrentaggregatedtrxn.count
			LOOP
				IF (vcurrentaggregatedtrxn(i)
				   .packno != nvl(ppackno, 0) AND vcurrentaggregatedtrxn(i).packno != 0 OR vcurrentaggregatedtrxn(i)
				   .packno = 0 AND NOT nvl(pifduedate, FALSE) OR vcurrentaggregatedtrxn(i)
				   .packno = 0 AND vcurrentaggregatedtrxn(i).trxndate = scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
				   .statementdate + 1)
				   AND NOT (vcurrentaggregatedtrxn(i).packno = 0 AND pifstatementdate AND vcurrentaggregatedtrxn(i)
					.trxndate = coperdate)
				THEN
					custom_s.say(cmethodname ||
								 '       Not Deleted PackNo  (vCurrentAggregatedTrxn[' || i ||
								 '].trxnDate)= ' || htools.d2s(vcurrentaggregatedtrxn(i).trxndate) ||
								 ', packNo  (vCurrentAggregatedTrxn[' || i || '].packNo) = ' || vcurrentaggregatedtrxn(i)
								 .packno
								,1);
					vreturnedaggregatedtrxn.extend;
					vreturnedaggregatedtrxn(i) := vcurrentaggregatedtrxn(i);
				ELSE
					custom_s.say(cmethodname || '       DELETED PACKNO (vCurrentAggregatedTrxn[' || i ||
								 '].trxnDate)= ' || htools.d2s(vcurrentaggregatedtrxn(i).trxndate) ||
								 ', packNo  (CurrentAggregatedTrxn[' || i || '].packNo) = ' || vcurrentaggregatedtrxn(i)
								 .packno
								,1);
					EXIT;
				END IF;
			END LOOP;
		END IF;
	
		UPDATE tcontractstminpaymentdata
		SET    unpaidsdamount_onduedate = vunpaidsdamount_onduedate
			  ,
			   
			   overdueamount_onduedate = voverdueamount_onduedate
			  ,prevmpovd_onduedate     = vprevmpovd_onduedate
			  ,
			   
			   aggregatedtrxn           = vreturnedaggregatedtrxn
			  ,mp_payoffdate_atcycleend = vmp_payoffdate_atcycleend
			  ,repayment_atcycleend     = vrepayment_atcycleend
		WHERE  branch = cbranch
		AND    screcno = vrecno
		AND    currencynumber = pcurrencynumber;
		custom_s.say(cmethodname || '       Rows updated (sql%rowcount) = ' || SQL%ROWCOUNT, 1);
	
		custom_s.say(cmethodname || '  -->> END', 1);
	EXCEPTION
		WHEN no_data_found THEN
			custom_s.say(cmethodname ||
						 '    NO CYCLES/TRANSACTIONS FOR CHOSEN RECNO were found in tContractStMinPaymentData'
						,1);
			custom_s.say(cmethodname || '  -->> END', 1);
		WHEN OTHERS THEN
			error.save(cmethodname);
			custom_s.say(cmethodname || '  -->> END', 1);
			RAISE;
	END rollbackaggregatedtrxn;

	FUNCTION getoverdueparameters
	(
		paccountno           taccount.accountno%TYPE
	   ,pcurrencynumber      tcontractstminpaymentdata.currencynumber%TYPE
	   ,pdate                DATE
	   ,pconsideroverduefrom NUMBER
	   ,ooverdueparameters   OUT typeoverdueparamsrecord
	) RETURN typepaidhistarray IS
		cmethodname CONSTANT VARCHAR2(80) := cpackagename || '.GetOverdueParameters';
		cbranch     CONSTANT NUMBER := custom_seance.getbranch;
		coperdate   CONSTANT DATE := custom_seance.getoperdate;
	
		vtotalrepayment NUMBER := 0;
		vlastcycle      NUMBER := 0;
		vcacheindex     VARCHAR2(50) := paccountno || '-' || pcurrencynumber || '-' ||
										to_char(nvl(pdate, coperdate), 'yyyy.mm.dd');
	
		vcurmpovd  NUMBER := 0;
		vprevmpovd NUMBER := 0;
	
		vdate DATE := nvl(pdate, coperdate);
	BEGIN
	
		custom_s.say(cmethodname || ' ', 1);
		custom_s.say(cmethodname || '  --<< BEGIN', 1);
		custom_s.say(cmethodname || '    -- INPUT PARAMETERS: ', 1);
		custom_s.say(cmethodname || '     -- Account Number (pAccountNo) = ' || paccountno ||
					 ', Currency Number (pCurrencyNumber) = ' || pcurrencynumber ||
					 ', Date (vDate) = ' || htools.d2s(vdate) ||
					 ', From what point Overdue Data are calculated (pConsiderOverdueFrom) = ' ||
					 pconsideroverduefrom ||
					 ':  [1 - Period in days from last unpaid overdue debt, 2 - Period in cycles from last unpaid overdue debt, 3 - Period in days from first unpaid overdue debt, 4 -Period in cycles from first unpaid overdue debt]');
		custom_s.say('', 1);
	
		custom_s.say(cmethodname || '    vCacheIndex = ' || vcacheindex);
		custom_s.say(cmethodname || '    cOperDate = ' || htools.d2s(coperdate));
	
		IF scache.exists(vcacheindex)
		   AND scache(vcacheindex).dueamount IS NOT NULL
		THEN
			ooverdueparameters.overduedate   := scache(vcacheindex).overduedate;
			ooverdueparameters.mp_payoffdate := scache(vcacheindex).mp_payoffdate;
			ooverdueparameters.dueamount     := scache(vcacheindex).dueamount;
			ooverdueparameters.overdueamount := scache(vcacheindex).overdueamount;
		
			ooverdueparameters.unpaidsdamountonpdate := scache(vcacheindex).unpaidsdamountonpdate;
			ooverdueparameters.unpaidsdamountonddate := scache(vcacheindex).unpaidsdamountonddate;
			sovdhistoryarray                         := scache(vcacheindex).overdueamountarray;
		
			ooverdueparameters.overdueamount_onduedate := scache(vcacheindex)
														  .overdueamount_onduedate;
		
			custom_s.say(cmethodname || '    < DATA HAS BEEN TAKEN FROM CACHE >', 1);
		ELSE
			custom_s.say(cmethodname || '    < DATA IS CALCULATED >', 1);
		
			IF NOT scache.exists(vcacheindex)
			THEN
				fillstminpaymentdataarrays(paccountno, pcurrencynumber, vdate);
			ELSE
				custom_s.say(cmethodname ||
							 '    -info: data is calculated based on filled already cache'
							,1);
			END IF;
		
			custom_s.say(cmethodname ||
						 '       MP for special using. This parameter should be null if it is not Statement Date now (sCache(vCacheIndex).MinPayment_Spec) = ' || scache(vcacheindex)
						 .minpayment_spec
						,1);
			custom_s.say(cmethodname ||
						 '       SD Amount for special using. This parameter should be null if it is not Statement Date now (sCache(vCacheIndex).SDAmount_Spec) = ' || scache(vcacheindex)
						 .sdamount_spec
						,1);
		
			custom_s.say(cmethodname || '     ++ DUE AMOUNT CALCULATION ++', 1);
			IF scache(vcacheindex).minpayment_spec IS NULL
			THEN
				IF scache(vcacheindex).minpaymentstdataarray.exists(1)
					AND scache(vcacheindex).minpaymentstdataarray IS NOT NULL
				THEN
					custom_s.say(cmethodname ||
								 '       - info: Some cycles passed. sCache(vCacheIndex).MinPaymentStDataArray is not empty'
								,1);
					IF scache(vcacheindex).lastaggrtrxnrowforlastcycle IS NOT NULL
					THEN
						custom_s.say(cmethodname ||
									 '       - info: some transactions were posted within current cycle by the moment (sCache(vCacheIndex).LastAggrTrxnARRAYForLastCycle is not empty)'
									,1);
						custom_s.say(cmethodname ||
									 '       Repayment (sCache(vCacheIndex).LastAggrTrxnROWForLastCycle.Repayment) = ' || scache(vcacheindex)
									 .lastaggrtrxnrowforlastcycle.repayment ||
									 ', Min Payment (sCache(vCacheIndex).MinPaymentStDataArray (MinPaymentStDataArray.count).MinPayment) = ' || scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
									 .minpayment
									,1);
						ooverdueparameters.dueamount := abs(least(scache(vcacheindex).lastaggrtrxnrowforlastcycle.repayment - scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
																  .minpayment
																 ,0));
					ELSE
						custom_s.say(cmethodname ||
									 '       - info: no transactions were posted within a cycle therefore Due Amount = Min Payment'
									,1);
						ooverdueparameters.dueamount := scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
														.minpayment;
					END IF;
				ELSE
					custom_s.say(cmethodname ||
								 '       - info: no cycles passed yet. sCache(vCacheIndex).MinPaymentStDataArray is empty'
								,1);
					ooverdueparameters.dueamount := 0;
				END IF;
			ELSE
				custom_s.say(cmethodname ||
							 '     - info: Due Amount is requested on Statement Date therefore it is equal to Min Payment (sMinPayment)'
							,1);
				ooverdueparameters.dueamount := scache(vcacheindex).minpayment_spec;
			END IF;
			custom_s.say(cmethodname || '       Due Amount (oOverdueParameters.DueAmount) = ' ||
						 ooverdueparameters.dueamount
						,1);
			custom_s.say(cmethodname || '     ++', 1);
		
			custom_s.say(cmethodname || '     ++ OVERDUE AMOUNT CALCULATION ++', 1);
			sovdhistoryarray := typepaidhistarray();
			IF scache(vcacheindex).minpaymentstdataarray.exists(1)
				AND scache(vcacheindex).minpaymentstdataarray IS NOT NULL
			THEN
			
				custom_s.say(cmethodname || '       - info: some Statement Dates were passed', 1);
				IF vdate >= scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
				  .statementdate
				   AND vdate < scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
				  .duedate
				THEN
					custom_s.say(cmethodname ||
								 '       - info: Since vDate is less tnan Due Date then previous cycle should be considered'
								,1);
					vlastcycle := scache(vcacheindex).minpaymentstdataarray.count - 1;
				ELSIF vdate >= scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
					 .duedate
				THEN
					vlastcycle := scache(vcacheindex).minpaymentstdataarray.count;
					custom_s.say(cmethodname || '       - info: Due Date passed', 1);
				END IF;
				custom_s.say(cmethodname || '       Last Considered Cycle (vLastCycle) = ' ||
							 vlastcycle
							,1);
			
				sovdhistoryarray.extend(vlastcycle);
				custom_s.say(cmethodname ||
							 '       Current cycle Repayment (sLastAggrTrxnROWForLastCycle.Repayment) = ' ||
							 nvl(scache(vcacheindex).lastaggrtrxnrowforlastcycle.repayment, 0)
							,1);
				vtotalrepayment := nvl(scache(vcacheindex).lastaggrtrxnrowforlastcycle.repayment, 0);
			
				FOR i IN REVERSE 1 .. vlastcycle
				LOOP
					IF NOT (i = vlastcycle AND vdate >= scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
						.duedate)
					THEN
						vtotalrepayment := vtotalrepayment + nvl(scache(vcacheindex).minpaymentstdataarray(i)
																 .repayment_atcycleend
																,0);
						custom_s.say(cmethodname ||
									 '       - info: Repayment at cycle end has been considered (sCache(vCacheIndex).MinPaymentStDataArray(i).Repayment_AtCycleEnd) = ' || scache(vcacheindex).minpaymentstdataarray(i)
									 .repayment_atcycleend
									,1);
					END IF;
				
					sovdhistoryarray(i) := typepaidhistrecord(scache(vcacheindex).minpaymentstdataarray(i)
															  .statementdate
															 ,scache(vcacheindex).minpaymentstdataarray(i)
															  .duedate
															 ,scache(vcacheindex).minpaymentstdataarray(i)
															  .minpayment
															 ,abs(least(vtotalrepayment - scache(vcacheindex).minpaymentstdataarray(i)
																		.minpayment
																	   ,0))
															 ,scache(vcacheindex).minpaymentstdataarray(i)
															  .sdamount);
					custom_s.say(cmethodname || '       [i] :' || i || ', SD = ' ||
								 htools.d2s(sovdhistoryarray(i).statementdate) || ', DD = ' ||
								 htools.d2s(sovdhistoryarray(i).duedate) || ', MP = ' || scache(vcacheindex).minpaymentstdataarray(i)
								 .minpayment || ', Total Repayment (vTotalRepayment) = ' ||
								 vtotalrepayment || ', OverdueAmount in sOvdHistoryArray = ' || sovdhistoryarray(i)
								 .overdueamount
								,1);
				END LOOP;
				custom_s.say(cmethodname || '       Total Repayment (vTotalRepayment) = ' ||
							 vtotalrepayment
							,1);
			
				IF vlastcycle < 1
				THEN
					custom_s.say(cmethodname ||
								 '       - info: No overdue amount since no Due Date passed'
								,1);
					ooverdueparameters.overdueamount := 0;
				ELSE
					ooverdueparameters.overdueamount := sovdhistoryarray(sovdhistoryarray.count)
														.overdueamount;
				END IF;
			ELSE
				custom_s.say(cmethodname ||
							 '       - info: No cycles passed therefore Overdue Amount is equal to 0'
							,1);
				ooverdueparameters.overdueamount := 0;
			END IF;
			custom_s.say(cmethodname ||
						 '       Overdue Amount (oOverdueParameters.OverdueAmount) = ' ||
						 ooverdueparameters.overdueamount
						,1);
			custom_s.say(cmethodname || '     ++', 1);
		
			custom_s.say(cmethodname || '     ++ OVERDUE AMOUNT ON DUE DATE CALCULATION ++', 1);
			ooverdueparameters.overdueamount_onduedate := 0;
		
			IF scache(vcacheindex).minpaymentstdataarray.exists(1)
				AND scache(vcacheindex).minpaymentstdataarray IS NOT NULL
			THEN
			
				FOR i IN REVERSE 1 .. scache(vcacheindex).minpaymentstdataarray.count
				LOOP
				
					custom_s.say(cmethodname || '       (i=' || i || ') Statement date = ' ||
								 htools.d2s(scache(vcacheindex).minpaymentstdataarray(i)
											.statementdate) || ', Due date = ' ||
								 htools.d2s(scache(vcacheindex).minpaymentstdataarray(i).duedate) ||
								 ', vDate = ' || htools.d2s(vdate));
				
					IF vdate > scache(vcacheindex).minpaymentstdataarray(i).statementdate
					THEN
					
						IF vdate > scache(vcacheindex).minpaymentstdataarray(i).duedate
						THEN
							custom_s.say(cmethodname ||
										 '       - info: Due Date passed therefore Overdue Amount on Due Date is calculated');
							ooverdueparameters.overdueamount_onduedate := scache(vcacheindex).minpaymentstdataarray(i)
																		  .overdueamount_onduedate;
						
						ELSIF vdate = scache(vcacheindex).minpaymentstdataarray(i).duedate
						THEN
							custom_s.say(cmethodname ||
										 '       - info: Due Date is now therefore Overdue Amount on Due Date is taken as Overdue amount');
							ooverdueparameters.overdueamount_onduedate := ooverdueparameters.overdueamount;
						
						ELSE
							custom_s.say(cmethodname ||
										 '        - info: Due Date didn`t pass therefore Overdue Amount on Due Date is equal to 0');
						END IF;
					
						EXIT;
					END IF;
				
				END LOOP;
			
			ELSE
				custom_s.say(cmethodname ||
							 '       - info: No cycles passed therefore Overdue Amount on Due Date is equal to 0'
							,1);
			END IF;
			custom_s.say(cmethodname ||
						 '       Overdue Amount on Due Date (oOverdueParameters.OverDueAmount_OnDueDate) = ' ||
						 ooverdueparameters.overdueamount_onduedate
						,1);
			custom_s.say(cmethodname || '     ++', 1);
		
			custom_s.say(cmethodname || '     ++ OVERDUEDATE CALCULATION ++', 1);
			IF ooverdueparameters.overdueamount = 0
			THEN
				custom_s.say(cmethodname ||
							 '       - info: Overdue Amount is EQUAL TO 0 thefore there is no overdue'
							,1);
				ooverdueparameters.overduedate := NULL;
			ELSE
				IF pconsideroverduefrom IN
				   (contractdelinqsetup.covdday, contractdelinqsetup.covdcycle)
				THEN
					custom_s.say(cmethodname ||
								 '       - info: Overdue Beginning Date is considered from LAST unpaid debt'
								,1);
				
					FOR i IN REVERSE 1 .. vlastcycle
					LOOP
						custom_s.say(cmethodname || '       Statement date = ' || sovdhistoryarray(i)
									 .statementdate || ', Due Date = ' || sovdhistoryarray(i)
									 .duedate || ', Min. Payment = ' || sovdhistoryarray(i)
									 .minpayment || ', overdue amount = ' || sovdhistoryarray(i)
									 .overdueamount
									,1);
						IF nvl(sovdhistoryarray(i).overdueamount, 0) = 0
						THEN
							EXIT;
						END IF;
						ooverdueparameters.overduedate := sovdhistoryarray(i).duedate;
					END LOOP;
				
				ELSIF pconsideroverduefrom IN
					  (contractdelinqsetup.covdfirstday, contractdelinqsetup.covdfirstcycle)
				THEN
					custom_s.say(cmethodname ||
								 '       - info: Overdue Beginning Date is considered from FIRST unpaid debt'
								,1);
					FOR i IN REVERSE 1 .. vlastcycle
					LOOP
						custom_s.say(cmethodname ||
									 '       -> sCache(vCacheIndex).MinPaymentStDataArray(' || i ||
									 ').OverdueAmount_OnDueDate = ' || scache(vcacheindex).minpaymentstdataarray(i)
									 .overdueamount_onduedate || ', Statement Date = ' ||
									 htools.d2s(scache(vcacheindex).minpaymentstdataarray(i)
												.statementdate) || ', Due Date = ' ||
									 htools.d2s(scache(vcacheindex).minpaymentstdataarray(i)
												.duedate));
					
						IF i = vlastcycle
						THEN
							custom_s.say(cmethodname || '       Current cycle Due Date = ' ||
										 htools.d2s(scache(vcacheindex).minpaymentstdataarray(i)
													.duedate) || ', Current Cycle Min Payment = ' || scache(vcacheindex).minpaymentstdataarray(i)
										 .minpayment ||
										 ', Current cycle repayment (sCache(vCacheIndex).LastAggrTrxnROWForLastCycle.Repayment) = ' ||
										 nvl(scache(vcacheindex)
											 .lastaggrtrxnrowforlastcycle.repayment
											,0)
										,1);
						END IF;
					
						IF vdate BETWEEN scache(vcacheindex).minpaymentstdataarray(i).duedate AND scache(vcacheindex).minpaymentstdataarray(i)
						  .nextstatementdate
						THEN
						
							IF vdate != scache(vcacheindex).minpaymentstdataarray(i).duedate
							THEN
								custom_s.say(cmethodname || '       PrevMPOvd_OnDueDate = ' || scache(vcacheindex).minpaymentstdataarray(i)
											 .prevmpovd_onduedate ||
											 ', Current Cycle Repayment - Min Payment = ' ||
											 abs(least(nvl(nvl(scache(vcacheindex)
															   .lastaggrtrxnrowforlastcycle.repayment
															  ,0) - scache(vcacheindex).minpaymentstdataarray(i)
														   .minpayment
														  ,0)))
											,1);
								vprevmpovd := nvl(scache(vcacheindex).minpaymentstdataarray(i)
												  .prevmpovd_onduedate
												 ,0);
								vcurmpovd  := abs(least(nvl(nvl(scache(vcacheindex)
																.lastaggrtrxnrowforlastcycle.repayment
															   ,0) - scache(vcacheindex).minpaymentstdataarray(i)
															.minpayment
														   ,0)));
							ELSE
								IF scache(vcacheindex)
								 .minpaymentstdataarray.exists(i - 1)
									AND scache(vcacheindex).minpaymentstdataarray IS NOT NULL
								THEN
									custom_s.say(cmethodname ||
												 '       Prev. cycle min payment = ' || scache(vcacheindex).minpaymentstdataarray(i - 1)
												 .minpayment || ', repayment at prev. cycle end = ' || scache(vcacheindex).minpaymentstdataarray(i - 1)
												 .repayment_atcycleend
												,1);
									vprevmpovd := abs(least(nvl(scache(vcacheindex)
																.lastaggrtrxnrowforlastcycle.repayment
															   ,0) + nvl(scache(vcacheindex).minpaymentstdataarray(i - 1)
																		 .repayment_atcycleend
																		,0) -
															nvl(scache(vcacheindex).minpaymentstdataarray(i - 1)
																.minpayment
															   ,0)
														   ,0));
									vcurmpovd  := abs(least(nvl(nvl(scache(vcacheindex)
																	.lastaggrtrxnrowforlastcycle.repayment
																   ,0) - scache(vcacheindex).minpaymentstdataarray(i)
																.minpayment
															   ,0)));
								ELSE
									vcurmpovd := abs(least(nvl(nvl(scache(vcacheindex)
																   .lastaggrtrxnrowforlastcycle.repayment
																  ,0) - scache(vcacheindex).minpaymentstdataarray(i)
															   .minpayment
															  ,0)));
								END IF;
							END IF;
						
						ELSE
							custom_s.say(cmethodname || '       PrevMPOvd_OnDueDate = ' || scache(vcacheindex).minpaymentstdataarray(i)
										 .prevmpovd_onduedate ||
										 ', Repayment_AtCycleEnd - Min Payment = ' ||
										 abs(least(scache(vcacheindex).minpaymentstdataarray(i)
												   .repayment_atcycleend - scache(vcacheindex).minpaymentstdataarray(i)
												   .minpayment
												  ,0))
										,1);
							vprevmpovd := nvl(scache(vcacheindex).minpaymentstdataarray(i)
											  .prevmpovd_onduedate
											 ,0);
							vcurmpovd  := abs(least(scache(vcacheindex).minpaymentstdataarray(i)
													.repayment_atcycleend - scache(vcacheindex).minpaymentstdataarray(i)
													.minpayment
												   ,0));
						END IF;
						custom_s.say(cmethodname || '       Previous MP Overdue = ' || vprevmpovd ||
									 ', Current MP Overdue = ' || vcurmpovd
									,1);
					
						IF vcurmpovd != 0
						THEN
							IF vprevmpovd != 0
							THEN
								NULL;
							ELSE
								ooverdueparameters.overduedate := scache(vcacheindex).minpaymentstdataarray(i)
																  .duedate;
								EXIT;
							END IF;
						ELSE
						
							NULL;
						END IF;
					END LOOP;
				END IF;
			END IF;
			custom_s.say(cmethodname ||
						 '       Date when Overdue occurred (oOverdueParameters.OverdueDate) = ' ||
						 htools.d2s(ooverdueparameters.overduedate));
			custom_s.say(cmethodname || '     ++', 1);
		
			custom_s.say(cmethodname || '     ++ MP_PAYOFFDATE CALCULATION ++', 1);
			IF ooverdueparameters.overdueamount != 0
			THEN
				ooverdueparameters.mp_payoffdate := NULL;
				custom_s.say(cmethodname ||
							 '       - info: Overdue Amount is NOT EQUAL TO 0 thefore there MP_PayOffDate is NULL'
							,1);
			ELSE
				IF scache(vcacheindex).lastaggrtrxnrowforlastcycle.packno IS NOT NULL
				THEN
					ooverdueparameters.mp_payoffdate := scache(vcacheindex)
														.lastaggrtrxnrowforlastcycle.mp_payoffdate;
				ELSIF scache(vcacheindex)
				 .minpaymentstdataarray.exists(scache(vcacheindex)
													.minpaymentstdataarray.count - 1)
				THEN
					ooverdueparameters.mp_payoffdate := scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count - 1)
														.mp_payoffdate_atcycleend;
				ELSE
					custom_s.say(cmethodname ||
								 '       - info: no more than one statement dates passed or vDate is between first SD and DD. It is considered as fact contract has been living without overdue since its creation date'
								,1);
					custom_s.say(cmethodname ||
								 '       ContractTypeSchema.sContractRow.CreateDate = ' ||
								 contracttypeschema.scontractrow.createdate
								,1);
					ooverdueparameters.mp_payoffdate := contracttypeschema.scontractrow.createdate;
					IF ooverdueparameters.mp_payoffdate IS NULL
					THEN
						SELECT c.createdate
						INTO   ooverdueparameters.mp_payoffdate
						FROM   tcontract     c
							  ,tcontractitem ci
						WHERE  ci.branch = cbranch
						AND    ci.key = paccountno
						AND    c.branch = ci.branch
						AND    c.no = ci.no;
					END IF;
				END IF;
			END IF;
			custom_s.say(cmethodname ||
						 '       Date when all Minimum Payments were paid (oOverdueParameters.MP_PayOffDate) = ' ||
						 htools.d2s(ooverdueparameters.mp_payoffdate));
			custom_s.say(cmethodname || '     ++', 1);
		
			custom_s.say(cmethodname || '     ++ UNPAID SD AMOUNT ON DUE DATE CALCULATION ++', 1);
			IF scache(vcacheindex).minpaymentstdataarray.exists(1)
				AND scache(vcacheindex).minpaymentstdataarray IS NOT NULL
				AND vdate >= scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
			   .duedate
			THEN
				custom_s.say(cmethodname ||
							 '     - info: Due Date passed therefore Unpaid SD Amount is calculated'
							,1);
				ooverdueparameters.unpaidsdamountonddate := nvl(scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
																.unpaidsdamount_onduedate
															   ,0);
			ELSE
				custom_s.say(cmethodname ||
							 '     - info: Due Date didn`t pass therefore Unpaid SD Amount on Due Date is equal to 0'
							,1);
				ooverdueparameters.unpaidsdamountonddate := 0;
			END IF;
			custom_s.say(cmethodname ||
						 '       Unpaid SD Amount on Due Date (oOverdueParameters.UnpaidSDAmountOnDDate) = ' ||
						 ooverdueparameters.unpaidsdamountonddate
						,1);
			custom_s.say(cmethodname || '     ++', 1);
		
			custom_s.say(cmethodname ||
						 '     ++ UNPAID SD AMOUNT ON SPECIFIED DATE CALCULATION ++'
						,1);
			IF scache(vcacheindex).sdamount_spec IS NOT NULL
			THEN
				custom_s.say(cmethodname ||
							 '       - info: since vDate = Statement Date then oOverdueParameters.UnpaidSDAmountOnPDate = sCache(vCacheIndex).SDAmount_Spec'
							,1);
				ooverdueparameters.unpaidsdamountonpdate := nvl(abs(least(scache(vcacheindex)
																		  .sdamount_spec
																		 ,0))
															   ,0);
			ELSE
				IF scache(vcacheindex).minpaymentstdataarray.exists(1)
					AND scache(vcacheindex).minpaymentstdataarray IS NOT NULL
				THEN
					custom_s.say(cmethodname ||
								 '       - info:  Some cycles passed (sCache(vCacheIndex).MinPaymentStDataArray is not empty)'
								,1);
					custom_s.say(cmethodname ||
								 '       SDAmount (sCache(vCacheIndex).MinPaymentStDataArray (sCache(vCacheIndex).MinPaymentStDataArray.count).SDAmount) = ' || scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
								 .sdamount
								,1);
					custom_s.say(cmethodname ||
								 '       Paid (sCache(vCacheIndex).LastAggrTrxnROWForLastCycle.Paid) = ' ||
								 nvl(scache(vcacheindex).lastaggrtrxnrowforlastcycle.paid, 0) ||
								 ', RevDebitOverplus (sCache(vCacheIndex).LastAggrTrxnROWForLastCycle.RevDebitOverplus) = ' ||
								 nvl(scache(vcacheindex)
									 .lastaggrtrxnrowforlastcycle.revdebitoverplus
									,0)
								,1);
					ooverdueparameters.unpaidsdamountonpdate := nvl(abs(least(nvl(scache(vcacheindex)
																				  .lastaggrtrxnrowforlastcycle.paid
																				 ,0) +
																			  nvl(scache(vcacheindex)
																				  .lastaggrtrxnrowforlastcycle.revdebitoverplus
																				 ,0) -
																			  abs(least(scache(vcacheindex).minpaymentstdataarray(scache(vcacheindex).minpaymentstdataarray.count)
																						.sdamount
																					   ,0))
																			 ,0))
																   ,0);
				ELSE
					custom_s.say(cmethodname ||
								 '       - info: no cycles passed therefore UnpaidSDAmountOnPDate = 0'
								,1);
					ooverdueparameters.unpaidsdamountonpdate := 0;
				END IF;
			END IF;
			custom_s.say(cmethodname ||
						 '       Unpaid SD Amount on Specified Date (oOverdueParameters.UnpaidSDAmountOnPDate) = ' ||
						 ooverdueparameters.unpaidsdamountonpdate
						,1);
			custom_s.say(cmethodname || '     ++', 1);
		
			scache(vcacheindex).dueamount := ooverdueparameters.dueamount;
			scache(vcacheindex).overdueamount := ooverdueparameters.overdueamount;
		
			scache(vcacheindex).overdueamount_onduedate := ooverdueparameters.overdueamount_onduedate;
		
			scache(vcacheindex).overduedate := ooverdueparameters.overduedate;
			scache(vcacheindex).mp_payoffdate := ooverdueparameters.mp_payoffdate;
			scache(vcacheindex).unpaidsdamountonpdate := nvl(ooverdueparameters.unpaidsdamountonpdate
															,0);
			scache(vcacheindex).unpaidsdamountonddate := nvl(ooverdueparameters.unpaidsdamountonddate
															,0);
			scache(vcacheindex).overdueamountarray := sovdhistoryarray;
			custom_s.say(cmethodname || '     - info: Cache has been filled', 1);
		
		END IF;
	
		custom_s.say(cmethodname || '     CALCULATION RESULTS: ', 1);
		custom_s.say(cmethodname || '       Overdue Date (oOverdueParameters.OverdueDate) = ' ||
					 htools.d2s(ooverdueparameters.overduedate));
		custom_s.say(cmethodname || '       PayOff Date (oOverdueParameters.MP_PayOffDate) = ' ||
					 htools.d2s(ooverdueparameters.mp_payoffdate));
		custom_s.say(cmethodname || '       Due Amount (oOverdueParameters.DueAmount) = ' ||
					 ooverdueparameters.dueamount);
		custom_s.say(cmethodname || '       Overdue Amount (oOverdueParameters.OverdueAmount) = ' ||
					 ooverdueparameters.overdueamount);
		custom_s.say(cmethodname ||
					 '       Overdue Amount On Due Date (oOverdueParameters.OverDueAmount_OnDueDate) = ' ||
					 ooverdueparameters.overdueamount_onduedate);
		custom_s.say(cmethodname ||
					 '       Unpaid SD Amount on Current Date (oOverdueParameters.UnpaidSDAmountOnPDate) = ' ||
					 ooverdueparameters.unpaidsdamountonpdate);
		custom_s.say(cmethodname ||
					 '       Unpaid SD Amount on Due Date (oOverdueParameters.UnpaidSDAmountOnDDate) = ' ||
					 ooverdueparameters.unpaidsdamountonddate);
		custom_s.say('', 1);
		custom_s.say(cmethodname || '       OverdueAmount Array:', 1);
		IF sovdhistoryarray IS NOT NULL
		   AND sovdhistoryarray.exists(1)
		THEN
			FOR i IN 1 .. sovdhistoryarray.count
			LOOP
				custom_s.say(cmethodname || '    -> [i] = ' || i || ' : Statement Date = ' ||
							 htools.d2s(sovdhistoryarray(i).statementdate) || ', Due Date = ' ||
							 htools.d2s(sovdhistoryarray(i).duedate) || ', Minimum Payment = ' || sovdhistoryarray(i)
							 .minpayment || ', Overdue Amount = ' || sovdhistoryarray(i)
							 .overdueamount);
			END LOOP;
		ELSE
			custom_s.say(cmethodname || '       sOvdHistoryArray is empty', 1);
		END IF;
	
		custom_s.say(cmethodname || '  -->> END', 1);
		RETURN sovdhistoryarray;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			custom_s.say(cmethodname || '  -->> END', 1);
			RAISE;
	END getoverdueparameters;

	PROCEDURE clearcache(pcacheindex VARCHAR2 := NULL) IS
		cmethodname CONSTANT VARCHAR2(80) := cpackagename || '.ClearCache';
	BEGIN
		custom_s.say(cmethodname || '    --<< BEGIN', 1);
		custom_s.say(cmethodname ||
					 '     -> INPUT PARAMETERS: Index of the cache (pCacheIndex) = ' ||
					 pcacheindex
					,1);
		custom_s.say(cmethodname || '', 1);
		IF pcacheindex IS NULL
		THEN
			scache.delete;
			sprepareddataforupd.delete;
		ELSE
			scache.delete(pcacheindex);
			sprepareddataforupd.delete(pcacheindex);
		END IF;
		custom_s.say(cmethodname || '     - info: Cache is cleared', 1);
		custom_s.say(cmethodname || '    -->> END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			custom_s.say(cmethodname || '  -->> END', 1);
			RAISE;
	END clearcache;

	PROCEDURE clearredundantcacherow IS
		vcounter NUMBER := 8;
		vindex   VARCHAR2(50);
	BEGIN
		FOR i IN 1 .. vcounter
		LOOP
			vindex := scache.first;
			scache.delete(vindex);
		END LOOP;
	END clearredundantcacherow;

	FUNCTION getcycleallattrarray
	(
		pcontractno     tcontract.no%TYPE
	   ,pdate           DATE
	   ,pcurrencynumber NUMBER
	) RETURN typeminpaymentstdata IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetCycleAllAttrArray';
		cbranch     CONSTANT NUMBER := custom_seance.getbranch;
	
		vcyclerecordsarraytoreturn typeminpaymentstdata;
	BEGIN
		custom_s.say(cmethodname || '  --<< BEGIN', 1);
		custom_s.say(cmethodname || '   - INPUT PARAMETERS: pContractNo = ' || pcontractno ||
					 ', pDate = ' || htools.d2s(pdate) || ', pCurrencyNumber = ' ||
					 pcurrencynumber);
		SELECT contractno
			  ,statementdate
			  ,accountno
			  ,duedate
			  ,branch
			  ,screcno
			  ,currencynumber
			  ,minpayment
			  ,repayment_atcycleend
			  ,overdueamount_onduedate
			  ,unpaidsdamount_onduedate
			  ,sdamount
			  ,aggregatedtrxn
			  ,prevmpovd_onduedate
			  ,mp_payoffdate_atcycleend
			  ,createdate
			  ,nextstatementdate
			  ,lastduedate
			  ,dafdate
			  ,printedduedate BULK COLLECT
		INTO   vcyclerecordsarraytoreturn
		FROM   vcontractstcyclempdata v
		WHERE  branch = cbranch
		AND    contractno = pcontractno
		AND    statementdate <= pdate
		AND    currencynumber = nvl(pcurrencynumber, currencynumber)
		ORDER  BY statementdate
				 ,currencynumber;
	
		custom_s.say(cmethodname ||
					 '  Number of records array to be returned (vCycleRecordsArrayToReturn.count) = ' ||
					 vcyclerecordsarraytoreturn.count
					,1);
		custom_s.say(cmethodname || '  -->> END', 1);
		RETURN vcyclerecordsarraytoreturn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			custom_s.say(cmethodname || '  -->> END', 1);
			RAISE;
	END getcycleallattrarray;

	FUNCTION getoverdueremains
	(
		pcontractno     tcontract.no%TYPE
	   ,pdate           DATE
	   ,paccountno      taccount.accountno%TYPE
	   ,pcurrencynumber tcontractstminpaymentdata.currencynumber%TYPE
	) RETURN typeoverdueremainsarray IS
		cmethodname CONSTANT VARCHAR2(120) := cpackagename || '.GetOverdueRemains';
	
		TYPE typestcycleandmparray IS TABLE OF vcontractstcyclempdata%ROWTYPE INDEX BY BINARY_INTEGER;
		vstcycleandmparray typestcycleandmparray;
	
		vcacheindex VARCHAR2(50) := paccountno || '-' || pcurrencynumber || '-' ||
									to_char(pdate, 'yyyy.mm.dd');
	
		vaggregatedtrxn vcontractstcyclempdata.aggregatedtrxn%TYPE;
		vrepayment      NUMBER := 0;
		voverdueamount  NUMBER := 0;
	
		vrepayment_atprevcycleend NUMBER := 0;
	
		vprevcyclemp tcontractstminpaymentdata.minpayment%TYPE;
		vcurrcyclemp tcontractstminpaymentdata.minpayment%TYPE;
	
		vcyclearrayindex NUMBER := 0;
	
		varraytoreturn   typeoverdueremainsarray;
		varraytoretindex NUMBER := 0;
	BEGIN
		custom_s.say(cmethodname || '     --<< BEGIN', 1);
		custom_s.say(cmethodname || '      - INPUT PARAMETERS: pContractNo = ' || pcontractno ||
					 ', pDate = ' || htools.d2s(pdate) || ', pCurrencyNumber = ' ||
					 pcurrencynumber
					,1);
		custom_s.say('', 1);
	
		fillstminpaymentdataarrays(paccountno      => paccountno
								  ,pcurrencynumber => pcurrencynumber
								  ,pdate           => pdate);
	
		IF scache.exists(vcacheindex)
		   AND scache(vcacheindex).minpaymentstdataarray.exists(1)
		THEN
			FOR i IN REVERSE 1 .. scache(vcacheindex).minpaymentstdataarray.count
			LOOP
				vcyclearrayindex := vcyclearrayindex + 1;
				vstcycleandmparray(vcyclearrayindex) := scache(vcacheindex).minpaymentstdataarray(i);
				custom_s.say(cmethodname || '        Cycle: Statement Date = ' ||
							 htools.d2s(scache(vcacheindex).minpaymentstdataarray(i).statementdate) ||
							 ', Due date = ' ||
							 htools.d2s(scache(vcacheindex).minpaymentstdataarray(i).duedate) ||
							 ', Min payment = ' || scache(vcacheindex).minpaymentstdataarray(i)
							 .minpayment || ', Next Statement date = ' ||
							 htools.d2s(scache(vcacheindex).minpaymentstdataarray(i)
										.nextstatementdate));
				IF vcyclearrayindex = 2
				THEN
					EXIT;
				END IF;
			END LOOP;
		END IF;
		custom_s.say(cmethodname || '        Number of chosen cycles (vCycleArrayIndex) = ' ||
					 vcyclearrayindex
					,1);
	
		IF vstcycleandmparray.count = 2
		THEN
		
			vrepayment_atprevcycleend := vstcycleandmparray(2).repayment_atcycleend;
		
			custom_s.say(cmethodname ||
						 '        Repayment amount at the end of previous cycle (vRepayment_AtPrevCycleEnd) = ' ||
						 vrepayment_atprevcycleend
						,1);
			varraytoretindex := varraytoretindex + 1;
			varraytoreturn(varraytoretindex).operdate := vstcycleandmparray(1).statementdate + 1;
			varraytoreturn(varraytoretindex).overdueamount := greatest(vstcycleandmparray(2).minpayment -
																		nvl(vrepayment_atprevcycleend
																		   ,0)
																	  ,0);
			vrepayment := nvl(vrepayment_atprevcycleend, 0);
			voverdueamount := varraytoreturn(varraytoretindex).overdueamount;
			custom_s.say(cmethodname || '        - info: New overdue remain was added to array', 1);
			custom_s.say(cmethodname || '        -> vRepayment = ' || vrepayment ||
						 ', vOverdueAmount = ' || voverdueamount
						,1);
			custom_s.say(cmethodname || '        -> Remain at the end of previous cycle (' ||
						 varraytoretindex || '): OperDate = ' ||
						 htools.d2s(varraytoreturn(varraytoretindex).operdate) ||
						 ', Overdue amount = ' || varraytoreturn(varraytoretindex).overdueamount
						,1);
		END IF;
	
		custom_s.say(cmethodname || '        CURRENT CYCLE TRANSACTIONS CHECK:', 1);
		IF vstcycleandmparray.exists(2)
		THEN
			vprevcyclemp := vstcycleandmparray(2).minpayment;
		ELSE
			vprevcyclemp := 0;
		END IF;
		custom_s.say(cmethodname || '        Previous cycle Minimum payment (vPrevCycleMP) = ' ||
					 vprevcyclemp
					,1);
	
		IF vstcycleandmparray.exists(1)
		THEN
			vcurrcyclemp := vstcycleandmparray(1).minpayment;
			custom_s.say(cmethodname || '        Current cycle Minimum payment (vCurrCycleMP) = ' ||
						 vcurrcyclemp
						,1);
		
			IF scache(vcacheindex)
			 .lastaggrtrxnarrayforlastcycle.exists(1)
				AND scache(vcacheindex).lastaggrtrxnarrayforlastcycle IS NOT NULL
			THEN
				vaggregatedtrxn := scache(vcacheindex).lastaggrtrxnarrayforlastcycle;
			END IF;
		
			IF vaggregatedtrxn IS NOT NULL
			   AND vaggregatedtrxn.exists(1)
			THEN
				FOR i IN 1 .. vaggregatedtrxn.count
				LOOP
					custom_s.say(cmethodname || '         TrxnDate = ' ||
								 htools.d2s(vaggregatedtrxn(i).trxndate) || ', repayment = ' || vaggregatedtrxn(i)
								 .repayment || ', vOverdueAmount = ' || voverdueamount ||
								 ', vStCycleAndMPArray(1).DueDate = ' ||
								 htools.d2s(vstcycleandmparray(1).duedate));
				
					IF vaggregatedtrxn(i).trxndate <= pdate
					THEN
						IF vaggregatedtrxn(i)
						 .trxndate < vstcycleandmparray(1).duedate
							AND voverdueamount !=
							greatest(vprevcyclemp - vaggregatedtrxn(i).repayment, 0)
						THEN
							varraytoretindex := varraytoretindex + 1;
							vrepayment := vrepayment_atprevcycleend + vaggregatedtrxn(i).repayment;
							varraytoreturn(varraytoretindex).operdate := vaggregatedtrxn(i).trxndate;
							varraytoreturn(varraytoretindex).overdueamount := greatest(vprevcyclemp -
																					   vrepayment
																					  ,0);
							voverdueamount := varraytoreturn(varraytoretindex).overdueamount;
							custom_s.say(cmethodname ||
										 '           - info: New overdue remain was added to array'
										,1);
							custom_s.say(cmethodname || '            -> vRepayment = ' ||
										 vrepayment || ', vOverdueAmount = ' || voverdueamount
										,1);
							custom_s.say(cmethodname ||
										 '            -> Remain after current cycle payments (' ||
										 varraytoretindex || '): OperDate = ' ||
										 htools.d2s(varraytoreturn(varraytoretindex).operdate) ||
										 ', Overdue amount = ' || varraytoreturn(varraytoretindex)
										 .overdueamount
										,1);
						ELSIF vaggregatedtrxn(i)
						 .trxndate >= vstcycleandmparray(1).duedate
							   AND voverdueamount !=
							   greatest(vcurrcyclemp - vaggregatedtrxn(i).repayment, 0)
						THEN
							varraytoretindex := varraytoretindex + 1;
							vrepayment := vaggregatedtrxn(i).repayment;
							varraytoreturn(varraytoretindex).operdate := vaggregatedtrxn(i).trxndate;
							varraytoreturn(varraytoretindex).overdueamount := greatest(vcurrcyclemp -
																					   vrepayment
																					  ,0);
							voverdueamount := varraytoreturn(varraytoretindex).overdueamount;
							custom_s.say(cmethodname ||
										 '           - info: New overdue remain was added to array'
										,1);
							custom_s.say(cmethodname || '            -> vRepayment = ' ||
										 vrepayment || ', vOverdueAmount = ' || voverdueamount
										,1);
							custom_s.say(cmethodname ||
										 '            -> Remain after current cycle payments (' ||
										 varraytoretindex || '): OperDate = ' ||
										 htools.d2s(varraytoreturn(varraytoretindex).operdate) ||
										 ', Overdue amount = ' || varraytoreturn(varraytoretindex)
										 .overdueamount
										,1);
						END IF;
					END IF;
				END LOOP;
			END IF;
		END IF;
	
		IF varraytoretindex != 0
		THEN
			varraytoretindex := varraytoretindex + 1;
			varraytoreturn(varraytoretindex).operdate := pdate + 1;
			varraytoreturn(varraytoretindex).overdueamount := varraytoreturn(varraytoretindex - 1)
															  .overdueamount;
			custom_s.say(cmethodname ||
						 '           - info: Pseudo row with overdue amount on pDate has been added'
						,1);
		END IF;
	
		custom_s.say(cmethodname || '     -->> END', 1);
	
		custom_s.say(cmethodname || '           ARRAY TO RETURN:', 1);
		FOR k IN 1 .. varraytoreturn.count
		LOOP
			custom_s.say(cmethodname || '             OperDate = ' ||
						 htools.d2s(varraytoreturn(k).operdate) || ', Overdue Amount = ' || varraytoreturn(k)
						 .overdueamount);
		END LOOP;
		RETURN varraytoreturn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END getoverdueremains;

	PROCEDURE fillverificationarray(pverificationrow typeverificationrow_record) IS
		cmethodname CONSTANT VARCHAR2(120) := cpackagename || '.FillVerificationArray';
	
		vindex NUMBER;
	BEGIN
		custom_s.say(cmethodname || '     --<< BEGIN', 1);
		vindex := sverificationarray.count;
		custom_s.say(cmethodname ||
					 '           Number of the array elements before adding new row (vIndex) = ' ||
					 vindex
					,1);
		vindex := vindex + 1;
		sverificationarray(vindex) := pverificationrow;
		custom_s.say(cmethodname || '     -->> END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END fillverificationarray;

	PROCEDURE transactionverification
	(
		pdataforupdate typeupdatestminpaymdata_record
	   ,pcacheindex    VARCHAR2
	) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT VARCHAR2(120) := cpackagename || '.TransactionVerification';
		cbranch     CONSTANT NUMBER := custom_seance.getbranch;
		coperdate   CONSTANT DATE := custom_seance.getoperdate;
	
		vtran_packno     tcontracttrxnlist.packno%TYPE;
		vtran_contractno tcontracttrxnlist.contractno%TYPE;
		vtran_accountno  tcontracttrxnlist.accountno%TYPE;
	
		vtran_debitamount     NUMBER := 0;
		vtran_creditamount    NUMBER := 0;
		vtran_revdebitamount  NUMBER := 0;
		vtran_revcreditamount NUMBER := 0;
	
		vmpdata_prevpack_debamount     NUMBER := 0;
		vmpdata_prevpack_credamount    NUMBER := 0;
		vmpdata_prevpack_revdebamount  NUMBER := 0;
		vmpdata_prevpack_revcredamount NUMBER := 0;
	
		vmpdata_pack_debitamount     NUMBER := 0;
		vmpdata_pack_creditamount    NUMBER := 0;
		vmpdata_pack_revdebitamount  NUMBER := 0;
		vmpdata_pack_revcreditamount NUMBER := 0;
	
		vpassedsd_count NUMBER := 0;
	
		vlog CLOB;
	BEGIN
	
		vlog := vlog || '' || chr(10);
		vlog := vlog || '     --<< BEGIN' || chr(10);
	
		vlog := vlog || '' || chr(10);
		vlog := vlog ||
				'      +++++ TRANSACTIONS THAT WERE INSERTED INTO tContractTrxnList DURING THE ADJUSTMENT +++++' ||
				chr(10);
		FOR i IN 1 .. sverificationarray.count
		LOOP
		
			vlog := vlog || '           OperDate = ' || sverificationarray(i).operdate ||
					', ContractNo = ' || sverificationarray(i).contractno || ', AccountNo = ' || sverificationarray(i)
				   .accountno || ', PackNo = ' || sverificationarray(i).packno || ', RecNo = ' || sverificationarray(i)
				   .recno || ', TranType = ' || sverificationarray(i).trantype || ', TranDate = ' || sverificationarray(i)
				   .trandate || ', PostDate = ' || sverificationarray(i).postdate || ', Amount = ' || sverificationarray(i)
				   .amount || chr(10);
			IF sverificationarray(i)
			 .accountno = TRIM(substr(pcacheindex, 1, instr(pcacheindex, '-') - 1))
			THEN
				vtran_packno     := sverificationarray(i).packno;
				vtran_contractno := sverificationarray(i).contractno;
				vtran_accountno  := sverificationarray(i).accountno;
			
				IF sverificationarray(i).trantype = 1
				THEN
					vtran_debitamount := vtran_debitamount + sverificationarray(i).amount;
				ELSIF sverificationarray(i).trantype = 2
				THEN
					vtran_revcreditamount := vtran_revcreditamount + sverificationarray(i).amount;
				ELSIF sverificationarray(i).trantype = 3
				THEN
					vtran_creditamount := vtran_creditamount + sverificationarray(i).amount;
				ELSIF sverificationarray(i).trantype = 4
				THEN
					vtran_revdebitamount := vtran_revdebitamount + sverificationarray(i).amount;
				END IF;
			END IF;
		END LOOP;
	
		vlog := vlog ||
				'      +++++                                                                 +++++' ||
				chr(10);
		vlog := vlog || '' || chr(10);
	
		vlog := vlog ||
				'      +++++ CURRENT CYCLE DATA IS GOING TO BE WRITTEN DOWN INTO tContractStMinPaymentData +++++' ||
				chr(10);
		vlog := vlog || '      pDataForUpdate.scRecNo = ' || pdataforupdate.screcno || chr(10);
		vlog := vlog || '      pDataForUpdate.Repayment_AtCycleEnd = ' ||
				pdataforupdate.repayment_atcycleend || chr(10);
		vlog := vlog || '      pDataForUpdate.OverDueAmount_OnDueDate = ' ||
				pdataforupdate.overdueamount_onduedate || chr(10);
		vlog := vlog || '      pDataForUpdate.UnpaidSDAmount_OnDueDate = ' ||
				pdataforupdate.unpaidsdamount_onduedate || chr(10);
		vlog := vlog || '      pDataForUpdate.PrevMPOvd_OnDueDate = ' ||
				pdataforupdate.prevmpovd_onduedate || chr(10);
		vlog := vlog || '      pDataForUpdate.MP_PayOffDate_AtCycleEnd = ' ||
				pdataforupdate.mp_payoffdate_atcycleend || chr(10);
		vlog := vlog || '         TRANSACTION DETAILS:' || chr(10);
	
		IF pdataforupdate.aggregatedtrxn.exists(1)
		   AND pdataforupdate.aggregatedtrxn IS NOT NULL
		THEN
			FOR i IN 1 .. pdataforupdate.aggregatedtrxn.count
			LOOP
			
				vlog := vlog || '           trxn date = ' || pdataforupdate.aggregatedtrxn(i)
					   .trxndate || ', Debit = ' || pdataforupdate.aggregatedtrxn(i).debitamount ||
						', Credit = ' || pdataforupdate.aggregatedtrxn(i).creditamount ||
						', Rev.Debit = ' || pdataforupdate.aggregatedtrxn(i).reversedebitamount ||
						', Rev.Credit = ' || pdataforupdate.aggregatedtrxn(i).reversecreditamount ||
						', Repayment = ' || pdataforupdate.aggregatedtrxn(i).repayment ||
						', PackNo = ' || pdataforupdate.aggregatedtrxn(i).packno ||
						',  PayOff Date = ' || pdataforupdate.aggregatedtrxn(i).mp_payoffdate ||
						', Paid = ' || pdataforupdate.aggregatedtrxn(i).paid || ', ReducedDebit = ' || pdataforupdate.aggregatedtrxn(i)
					   .reduceddebit || ', RevDebitOverplus = ' || pdataforupdate.aggregatedtrxn(i)
					   .revdebitoverplus || chr(10);
			
				IF vtran_packno = pdataforupdate.aggregatedtrxn(i).packno
				THEN
					vmpdata_pack_debitamount     := pdataforupdate.aggregatedtrxn(i).debitamount;
					vmpdata_pack_creditamount    := pdataforupdate.aggregatedtrxn(i).creditamount;
					vmpdata_pack_revdebitamount  := pdataforupdate.aggregatedtrxn(i)
													.reversedebitamount;
					vmpdata_pack_revcreditamount := pdataforupdate.aggregatedtrxn(i)
													.reversecreditamount;
				END IF;
			
				IF pdataforupdate.aggregatedtrxn.exists(i - 1)
				   AND pdataforupdate.aggregatedtrxn(i - 1).packno != vtran_packno
				   AND vtran_packno = pdataforupdate.aggregatedtrxn(i).packno
				THEN
					vmpdata_prevpack_debamount     := pdataforupdate.aggregatedtrxn(i - 1)
													  .debitamount;
					vmpdata_prevpack_credamount    := pdataforupdate.aggregatedtrxn(i - 1)
													  .creditamount;
					vmpdata_prevpack_revdebamount  := pdataforupdate.aggregatedtrxn(i - 1)
													  .reversedebitamount;
					vmpdata_prevpack_revcredamount := pdataforupdate.aggregatedtrxn(i - 1)
													  .reversecreditamount;
				END IF;
			END LOOP;
		END IF;
	
		vlog := vlog ||
				'      +++++                                                                 +++++' ||
				chr(10);
		vlog := vlog || '' || chr(10);
	
		vlog := vlog || '      +++++                          DATA COMPARING by packNO = :' ||
				vtran_packno || '                        +++++' || chr(10);
		IF (vmpdata_pack_debitamount - vmpdata_prevpack_debamount) != vtran_debitamount
		   OR (vmpdata_pack_creditamount - vmpdata_prevpack_credamount) != vtran_creditamount
		   OR (vmpdata_pack_revdebitamount - vmpdata_prevpack_revdebamount) != vtran_revdebitamount
		   OR
		   (vmpdata_pack_revcreditamount - vmpdata_prevpack_revcredamount) != vtran_revcreditamount
		THEN
		
			SELECT COUNT(1)
			INTO   vpassedsd_count
			FROM   vcontractstcyclempdata
			WHERE  branch = cbranch
			AND    contractno = vtran_contractno
			AND    accountno = vtran_accountno;
		
			IF vpassedsd_count != 0
			THEN
				vlog := vlog || '      Tran debit = ' || vtran_debitamount ||
						', aggregated debit = ' ||
						(vmpdata_pack_debitamount - vmpdata_prevpack_debamount) || chr(10);
				vlog := vlog || '      Tran credit = ' || vtran_creditamount ||
						', aggregated credit = ' ||
						(vmpdata_pack_creditamount - vmpdata_prevpack_credamount) || chr(10);
				vlog := vlog || '      Tran RevDebit = ' || vtran_revdebitamount ||
						', aggregated rev debit = ' ||
						(vmpdata_pack_revdebitamount - vmpdata_prevpack_revdebamount) || chr(10);
				vlog := vlog || '      Tran RevCredit = ' || vtran_revcreditamount ||
						', aggregated rev credit = ' ||
						(vmpdata_pack_revcreditamount - vmpdata_prevpack_revcredamount) || chr(10);
			
				INSERT INTO tcontrtransdiscrepancy
					(transdiscrepancyid
					,ovdcalcparam_operdate
					,contractno
					,accountno
					,usedcacheindex
					,log
					,creationdate)
				VALUES
					(vtran_packno
					,coperdate
					,vtran_contractno
					,vtran_accountno
					,pcacheindex
					,vlog
					,SYSDATE);
				COMMIT;
				error.raiseerror('Discrepancy between transactions and aggregated ones was found. Contact a developer or support team');
			END IF;
		END IF;
		custom_s.say(cmethodname ||
					 '      +++++                                                                 +++++'
					,1);
		custom_s.say(cmethodname || '', 1);
	
		custom_s.say(cmethodname || '     -->> END', 1);
	
		custom_s.say(cmethodname || '', 1);
	EXCEPTION
		WHEN OTHERS THEN
			clearverificationarray;
			error.save(cmethodname);
			RAISE;
	END transactionverification;

	PROCEDURE clearverificationarray IS
		cmethodname CONSTANT VARCHAR2(120) := cpackagename || '.ClearVerificationArray';
	BEGIN
		custom_s.say(cmethodname || '     --<< BEGIN', 1);
		sverificationarray.delete;
		custom_s.say(cmethodname || '     -->> END', 1);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END clearverificationarray;

	FUNCTION getlastpassedcycleinfo
	(
		paccountno      IN taccount.accountno%TYPE
	   ,pcurrencynumber IN tcontractstminpaymentdata.currencynumber%TYPE
	   ,pdate           DATE
	) RETURN vcontractstcyclempdata%ROWTYPE IS
		cmethodname CONSTANT VARCHAR2(120) := cpackagename || '.GetLastPassedCycleInfo';
		vcycleinfotoreturn vcontractstcyclempdata%ROWTYPE;
		vcacheindex        VARCHAR2(100) := paccountno || '-' || pcurrencynumber || '-' ||
											to_char(pdate, 'yyyy.mm.dd');
		vindex             NUMBER;
	BEGIN
		custom_s.say(cmethodname || '      --<< BEGIN', 1);
		custom_s.say(cmethodname || '        - INPUT PARAMETERS: pAccountNo = ' || paccountno ||
					 ', pCurrencyNumber = ' || pcurrencynumber || ', pDate = ' ||
					 htools.d2s(pdate));
		custom_s.say(cmethodname || '        vCacheIndex = ' || vcacheindex);
	
		fillstminpaymentdataarrays(paccountno, pcurrencynumber, pdate);
	
		t.var('sCache.exists(vCacheIndex)', htools.b2s(scache.exists(vcacheindex)));
		t.var('sCache(vCacheIndex).MinPaymentStDataArray.exists(1)'
			 ,htools.b2s(scache(vcacheindex).minpaymentstdataarray.exists(1)));
		t.var('sCache(vCacheIndex).MinPaymentStDataArray is not null'
			 ,htools.b2s(scache(vcacheindex).minpaymentstdataarray IS NOT NULL));
	
		IF scache.exists(vcacheindex)
		   AND scache(vcacheindex).minpaymentstdataarray.exists(1)
		   AND scache(vcacheindex).minpaymentstdataarray IS NOT NULL
		THEN
			vindex := scache(vcacheindex).minpaymentstdataarray.count;
			custom_s.say(cmethodname || '        vIndex = ' || vindex, 1);
			vcycleinfotoreturn := scache(vcacheindex).minpaymentstdataarray(vindex);
		END IF;
		custom_s.say(cmethodname || '        vCycleInfoToReturn: Statement date  = ' ||
					 vcycleinfotoreturn.statementdate || ', SD Amount = ' ||
					 vcycleinfotoreturn.sdamount
					,1);
		custom_s.say(cmethodname || '      -->> END', 1);
		RETURN vcycleinfotoreturn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END getlastpassedcycleinfo;

	FUNCTION getrepaymentamounts
	(
		paccountno      IN taccount.accountno%TYPE
	   ,pcurrencynumber IN tcontractstminpaymentdata.currencynumber%TYPE
	   ,pdate           DATE
	   ,pstatementdate  IN DATE := NULL
	) RETURN type_repaym_unpaid_amnts_rec IS
		cmethodname CONSTANT VARCHAR2(120) := cpackagename || '.GetRepaymentAmounts';
	
		vrecordtoreturn type_repaym_unpaid_amnts_rec;
		vlastcycleindex NUMBER;
		vcacheindex     VARCHAR2(100) := paccountno || '-' || pcurrencynumber || '-' ||
										 to_char(pdate, 'yyyy.mm.dd');
	BEGIN
		custom_s.say(cmethodname || '      --<< BEGIN', 1);
		custom_s.say(cmethodname || '        - INPUT PARAMETERS: pAccountNo = ' || paccountno ||
					 ', pCurrencyNumber = ' || pcurrencynumber || ', pDate = ' ||
					 htools.d2s(pdate) || ', pStatementDate = ' || htools.d2s(pstatementdate));
		custom_s.say(cmethodname || '        vCacheIndex = ' || vcacheindex, 1);
	
		fillstminpaymentdataarrays(paccountno, pcurrencynumber, pdate, pstatementdate);
	
		IF scache.exists(vcacheindex)
		   AND scache(vcacheindex).minpaymentstdataarray.exists(1)
		   AND scache(vcacheindex).minpaymentstdataarray IS NOT NULL
		THEN
		
			vlastcycleindex := scache(vcacheindex).minpaymentstdataarray.count;
			custom_s.say(cmethodname || '        vLastCycleIndex = ' || vlastcycleindex, 1);
		
			vrecordtoreturn.minpayment   := scache(vcacheindex).minpaymentstdataarray(vlastcycleindex)
											.minpayment;
			vrecordtoreturn.mp_repayment := nvl(scache(vcacheindex)
												.lastaggrtrxnrowforlastcycle.repayment
											   ,0);
			vrecordtoreturn.unpaidmp     := nvl(abs(least(vrecordtoreturn.mp_repayment - scache(vcacheindex).minpaymentstdataarray(vlastcycleindex)
														  .minpayment
														 ,0))
											   ,0);
		
			vrecordtoreturn.sdamount       := scache(vcacheindex).minpaymentstdataarray(vlastcycleindex)
											  .sdamount;
			vrecordtoreturn.sd_repayment   := nvl(scache(vcacheindex)
												  .lastaggrtrxnrowforlastcycle.paid + scache(vcacheindex)
												  .lastaggrtrxnrowforlastcycle.revdebitoverplus
												 ,0);
			vrecordtoreturn.unpaidsdamount := nvl(abs(least(vrecordtoreturn.sd_repayment -
															abs(least(scache(vcacheindex).minpaymentstdataarray(vlastcycleindex)
																	  .sdamount
																	 ,0))
														   ,0))
												 ,0);
		
			vrecordtoreturn.revdebitoverplus := nvl(scache(vcacheindex)
													.lastaggrtrxnrowforlastcycle.revdebitoverplus
												   ,0);
			vrecordtoreturn.paid             := nvl(scache(vcacheindex)
													.lastaggrtrxnrowforlastcycle.paid
												   ,0);
		
		ELSE
		
			custom_s.say(cmethodname ||
						 '        - info: No cycles were passed or currency is not used or input parameters specified wrongly. All returned parameters are going to be set as 0'
						,1);
			vrecordtoreturn.minpayment   := 0;
			vrecordtoreturn.mp_repayment := 0;
			vrecordtoreturn.unpaidmp     := 0;
		
			vrecordtoreturn.sdamount       := 0;
			vrecordtoreturn.sd_repayment   := 0;
			vrecordtoreturn.unpaidsdamount := 0;
		
			vrecordtoreturn.revdebitoverplus := 0;
			vrecordtoreturn.paid             := 0;
		
		END IF;
	
		custom_s.say(cmethodname || '      RETURNED VALUES:', 1);
		custom_s.say(cmethodname || '         MinPayment = ' || vrecordtoreturn.minpayment ||
					 ', MP_Repayment = ' || vrecordtoreturn.mp_repayment || ', UnpaidMP = ' ||
					 vrecordtoreturn.unpaidmp);
		custom_s.say(cmethodname || '         SDAmount = ' || vrecordtoreturn.sdamount ||
					 ', SD_Repayment = ' || vrecordtoreturn.sd_repayment || ', UnpaidSDAmount = ' ||
					 vrecordtoreturn.unpaidsdamount);
		custom_s.say(cmethodname || '         RevDebitOverplus = ' ||
					 vrecordtoreturn.revdebitoverplus || ', Paid = ' || vrecordtoreturn.paid);
	
		custom_s.say(cmethodname || '      -->> END', 1);
		RETURN vrecordtoreturn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END getrepaymentamounts;

BEGIN
	custom_s.say(cpackagename || ' header version: ' || sheaderversion);
	custom_s.say(cpackagename || ' body version: ' || cbodyversion);
EXCEPTION
	WHEN OTHERS THEN
		error.save(cpackagename);
		RAISE;
END custom_overdueparameterscalculation;
/
