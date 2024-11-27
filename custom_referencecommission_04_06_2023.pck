CREATE OR REPLACE PACKAGE custom_referencecommission AS
	TYPE typevarchar IS TABLE OF VARCHAR(40) INDEX BY BINARY_INTEGER;
	TYPE typenumber IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

	object_name CONSTANT VARCHAR(20) := 'COMMISSION';
	object_type NUMBER;

	crevision CONSTANT VARCHAR(100) := '$Rev: 44809 $';

	debit_account  CONSTANT VARCHAR(20) := 'DEBIT';
	credit_account CONSTANT VARCHAR(20) := 'CREDIT';

	cvaluestr_debit  CONSTANT VARCHAR(20) := 'Debited acct';
	cvaluestr_credit CONSTANT VARCHAR(20) := 'Credited acct';

	sacommission               typenumber;
	sacommissiondebitaccount   typevarchar;
	sacommissioncreditaccount  typevarchar;
	sacommissionentcode        typenumber;
	sacommissionvalue          typenumber;
	sacommissioncurrency       typenumber;
	sacommissioncreditvalue    typenumber;
	sacommissioncreditcurrency typenumber;
	sacommissionstat           typevarchar;
	sacommissionexchange       typenumber;
	scommissioncount           NUMBER;

	FUNCTION getversion RETURN VARCHAR;
	FUNCTION calc
	(
		pcommissionrow IN treferencecommission%ROWTYPE
	   ,pvalue         IN OUT NUMBER
	   ,pcurrencyin    IN NUMBER
	   ,pcurrencyout   IN NUMBER
	   ,pdate          IN DATE
	   ,pdirection     IN NUMBER := NULL
	) RETURN NUMBER;
	FUNCTION calc
	(
		pcommissionrow   IN treferencecommission%ROWTYPE
	   ,pvalue           IN NUMBER
	   ,pcurrency        IN NUMBER
	   ,pdebitvalue      OUT NUMBER
	   ,pdebitcurrency   IN NUMBER
	   ,pcreditvalue     OUT NUMBER
	   ,pcreditcurrency  IN NUMBER
	   ,pdate            IN DATE
	   ,pdebitdirection  IN NUMBER
	   ,pcreditdirection IN NUMBER
	) RETURN NUMBER;
	FUNCTION dialogeditint(pwhat IN NUMBER) RETURN NUMBER;
	PROCEDURE dialogeditintproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	FUNCTION dialogdataint(pcommission IN NUMBER) RETURN NUMBER;
	PROCEDURE dialogdataintproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	FUNCTION dialoglist RETURN NUMBER;
	PROCEDURE dialoglistproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	FUNCTION dialogupdate(pwhat IN NUMBER) RETURN NUMBER;
	PROCEDURE dialogupdateproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);
	PROCEDURE fillsecurityarray
	(
		plevel IN NUMBER
	   ,pkey   IN VARCHAR
	);
	FUNCTION getcheck(pcommission IN NUMBER) RETURN NUMBER;
	FUNCTION getcount RETURN NUMBER;
	FUNCTION getentident(pcommission IN NUMBER) RETURN VARCHAR;
	FUNCTION getname(pcommission IN NUMBER) RETURN VARCHAR;
	FUNCTION gettext(pno IN NUMBER) RETURN VARCHAR;
	PROCEDURE init
	(
		ptypeobject    IN NUMBER
	   ,pkeyobject     IN VARCHAR
	   ,pdebitaccount  IN VARCHAR
	   ,pcreditaccount IN VARCHAR
	   ,pvalue         IN NUMBER
	   ,pdate          IN DATE
	   ,pcurrency      IN NUMBER := NULL
	);
	PROCEDURE init
	(
		pcommission    IN NUMBER
	   ,pdebitaccount  IN VARCHAR
	   ,pcreditaccount IN VARCHAR
	   ,pvalue         IN NUMBER
	   ,pdate          IN DATE
	   ,pcurrency      IN NUMBER := NULL
	);

	FUNCTION getrow(pcommission IN NUMBER) RETURN treferencecommission%ROWTYPE;
	FUNCTION exist(pcommission IN NUMBER) RETURN BOOLEAN;

	PROCEDURE dialogparamviewproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	);

	FUNCTION getcommissionrecord(pcommission IN NUMBER) RETURN custom_api_type.typecommissionrecord;
	FUNCTION getcommissiondatalist(pcommission IN NUMBER) RETURN custom_api_type.typecommissiondatalist;

END;
/
CREATE OR REPLACE PACKAGE BODY custom_referencecommission AS
	cpackagename  CONSTANT VARCHAR(40) := 'custom_referenceCommission';
	cbodyrevision CONSTANT VARCHAR(100) := '$Rev: 44809 $';
	--cbodyrevision CONSTANT VARCHAR(100) := '';
	smethodcount NUMBER;
	samethod     typenumber;
	samethodname typevarchar;

	right_view   CONSTANT NUMBER := 1;
	right_modify CONSTANT NUMBER := 2;

	code_base24 CONSTANT CHAR(2) := '09';

	method_interval CONSTANT NUMBER := 1;

	from_lst CONSTANT NUMBER := 1;
	from_int CONSTANT NUMBER := 2;

	what_add  CONSTANT NUMBER := 1;
	what_edit CONSTANT NUMBER := 2;

	SUBTYPE typedirectionvalue IS PLS_INTEGER;

	cdvcredit CONSTANT typedirectionvalue := 1;
	cdvdebit  CONSTANT typedirectionvalue := 2;

	saintint typenumber;
	saintval typenumber;
	saintprc typenumber;
	saintmin typenumber;
	saintmax typenumber;

	scommissionrow treferencecommission%ROWTYPE;
	scommissionadd treferencecommission%ROWTYPE;

	sdshandle    NUMBER;
	slstreccount NUMBER;
	slstrecno    NUMBER;
	sintreccount NUMBER;
	sintrecno    NUMBER;
	sfrom        NUMBER;
	scaptured    BOOLEAN;
	smodified    BOOLEAN;

	SUBTYPE typesortmode IS PLS_INTEGER;

	csmcode CONSTANT typesortmode := 1;
	csmname CONSTANT typesortmode := 2;

	SUBTYPE typeparamviewvalue IS VARCHAR2(16);

	cpvvsortmode  CONSTANT typeparamviewvalue := 'SORTMODE';
	cpvvorderdesc CONSTANT typeparamviewvalue := 'ORDERDESC';

	PROCEDURE deletecommission;
	PROCEDURE dynasetopen;
	PROCEDURE fillaccountlist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	);
	PROCEDURE fillexchangelist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	);
	PROCEDURE fillintervalarray(pcommission IN NUMBER);
	PROCEDURE filllinklist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	);
	PROCEDURE fillmethodlist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	);
	FUNCTION getparm
	(
		pstring IN VARCHAR
	   ,pno     IN NUMBER
	) RETURN NUMBER;
	FUNCTION getfreecommission RETURN NUMBER;
	FUNCTION getrightkey(paction IN VARCHAR) RETURN VARCHAR;
	PROCEDURE savedataint(pdialog IN NUMBER);

	PROCEDURE log
	(
		pcommission IN NUMBER
	   ,ptext       IN VARCHAR
	   ,paction     IN NUMBER
	);
	PROCEDURE logparam
	(
		pparam     IN VARCHAR
	   ,pvalue     IN VARCHAR
	   ,pclearlist IN BOOLEAN := FALSE
	);

	FUNCTION dialogparamview RETURN NUMBER;
	FUNCTION getdata(pident IN VARCHAR) RETURN NUMBER;
	PROCEDURE putdata
	(
		pident IN VARCHAR
	   ,pvalue IN NUMBER
	);

	FUNCTION getdbcrvaluebystr(pvaluestr IN VARCHAR) RETURN VARCHAR;
	FUNCTION getdbcrstrbyvalue(pvalue IN VARCHAR) RETURN VARCHAR;

	FUNCTION getversion RETURN VARCHAR IS
	BEGIN
		RETURN service.formatpackageversion(cpackagename, crevision, cbodyrevision);
	END;

	FUNCTION calc
	(
		pcommissionrow IN treferencecommission%ROWTYPE
	   ,pvalue         IN OUT NUMBER
	   ,pcurrencyin    IN NUMBER
	   ,pcurrencyout   IN NUMBER
	   ,pdate          IN DATE
	   ,pdirection     IN NUMBER
	) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.Calc(one direction)';
		vcurrency     NUMBER;
		vexchange     NUMBER;
		vvaluemin     NUMBER;
		vvaluemax     NUMBER;
		vindexint     NUMBER;
		vindexval     NUMBER;
		vindexprc     NUMBER;
		vstring       VARCHAR(250);
		vprecisionout NUMBER;
	
		vdirection NUMBER;
		vrate      NUMBER;
	
	BEGIN
		IF pcommissionrow.method = method_interval
		THEN
			vindexint     := 1;
			vindexprc     := 1;
			vindexval     := 1;
			vprecisionout := referencecurrency.getprecision(pcurrencyout);
		
			vcurrency := nvl(pcommissionrow.currency, seance.getcurrency);
			s.say(cpackagename || '.Calc|vCommCurrency = ' || vcurrency);
		
			IF pdirection IS NULL
			THEN
				vdirection := cdvcredit;
				s.say(cpackagename || '.Calc|vDirection(nvl) = ' || vdirection);
			ELSE
				vdirection := pdirection;
				s.say(cpackagename || '.Calc|vDirection = ' || vdirection);
			END IF;
		
			s.say(cpackagename || '.Calc|pCurrencyIn  = ' || pcurrencyin);
			s.say(cpackagename || '.Calc|pCurrencyOut = ' || pcurrencyout);
		
			IF vcurrency != pcurrencyin
			THEN
				vexchange := pcommissionrow.exchange;
				vindexint := exchangerate.getrate(vexchange, pcurrencyin, vcurrency, pdate);
				IF vindexint IS NULL
				THEN
					RETURN err.geterrorcode;
				END IF;
			END IF;
		
			IF vcurrency != pcurrencyout
			THEN
				vexchange := pcommissionrow.exchange;
			
				IF vdirection = cdvdebit
				THEN
					vrate     := exchangerate.getrate(vexchange, pcurrencyout, vcurrency, pdate);
					vindexval := 1 / vrate;
				ELSIF vdirection = cdvcredit
				THEN
				
					vindexval := exchangerate.getrate(vexchange, vcurrency, pcurrencyout, pdate);
				END IF;
			
				IF vindexval IS NULL
				THEN
					RETURN err.geterrorcode;
				END IF;
			END IF;
		
			IF pcurrencyin != pcurrencyout
			THEN
				vexchange := pcommissionrow.exchange;
			
				IF vdirection = cdvdebit
				THEN
					vrate     := exchangerate.getrate(vexchange, pcurrencyout, pcurrencyin, pdate);
					vindexprc := 1 / vrate;
				ELSIF vdirection = cdvcredit
				THEN
				
					vindexprc := exchangerate.getrate(vexchange, pcurrencyin, pcurrencyout, pdate);
				END IF;
			
				IF vindexprc IS NULL
				THEN
					RETURN err.geterrorcode;
				END IF;
			END IF;
		
			s.say(cpackagename || '.Calc|vIndexInt = ' || vindexint);
			s.say(cpackagename || '.Calc|vIndexVal = ' || vindexval);
			s.say(cpackagename || '.Calc|vIndexPrc = ' || vindexprc);
		
			vstring := custom_datamember.getintervalchar(object_type
														,pcommissionrow.commission
														,'INTERVAL'
														,pvalue * vindexint);
			IF vstring IS NULL
			THEN
				err.seterror(err.refcomm_data_not_defined, cpackagename || '.Calc');
				RETURN err.geterrorcode;
			END IF;
			pvalue := round(nvl(getparm(vstring, 1), 0) * vindexval, vprecisionout) +
					  round(round(nvl(getparm(vstring, 2), 0) * pvalue / 100
								 ,referencecurrency.getprecision(pcurrencyin)) * vindexprc
						   ,vprecisionout);
		
			vvaluemin := getparm(vstring, 3);
			IF vvaluemin IS NOT NULL
			THEN
				pvalue := greatest(round(vvaluemin * vindexval, vprecisionout), pvalue);
			END IF;
		
			vvaluemax := getparm(vstring, 4);
			IF vvaluemax IS NOT NULL
			THEN
				pvalue := least(round(vvaluemax * vindexval, vprecisionout), pvalue);
			END IF;
			pvalue := round(pvalue, vprecisionout);
		
		ELSE
			pvalue := 0;
		END IF;
	
		s.say(cwhere || '|pValue = ' || pvalue);
	
		err.seterror(0, cpackagename || '.Calc');
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.Calc');
			RETURN error.getcode;
	END;

	FUNCTION calc
	(
		pcommissionrow   IN treferencecommission%ROWTYPE
	   ,pvalue           IN NUMBER
	   ,pcurrency        IN NUMBER
	   ,pdebitvalue      OUT NUMBER
	   ,pdebitcurrency   IN NUMBER
	   ,pcreditvalue     OUT NUMBER
	   ,pcreditcurrency  IN NUMBER
	   ,pdate            IN DATE
	   ,pdebitdirection  IN NUMBER
	   ,pcreditdirection IN NUMBER
	) RETURN NUMBER IS
	BEGIN
	
		IF pdebitcurrency IS NOT NULL
		THEN
			pdebitvalue := pvalue;
			IF calc(pcommissionrow, pdebitvalue, pcurrency, pdebitcurrency, pdate, pdebitdirection) != 0
			THEN
				RETURN err.geterrorcode;
			END IF;
		ELSE
			pdebitvalue := NULL;
		END IF;
	
		IF pcreditcurrency IS NOT NULL
		THEN
			pcreditvalue := pvalue;
			IF calc(pcommissionrow
				   ,pcreditvalue
				   ,pcurrency
				   ,pcreditcurrency
				   ,pdate
				   ,pcreditdirection) != 0
			THEN
				RETURN err.geterrorcode;
			END IF;
		ELSE
			pcreditvalue := NULL;
		END IF;
		RETURN 0;
	END;

	FUNCTION dialogeditint(pwhat IN NUMBER) RETURN NUMBER IS
		vdialog NUMBER;
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.DialogEditInt';
	BEGIN
		vdialog := dialog.new('Enter/edit interval data', 0, 0, 52, 11, pextid => cwhere);
	
		dialog.inputinteger(vdialog, 'What', 0, 0, ' ');
		dialog.setitemattributies(vdialog
								 ,'What'
								 ,dialog.echooff || dialog.selectoff || dialog.updateoff);
		dialog.inputchar(vdialog, 'Interval', 27, 2, 20, 'Enter interval value', NULL, 'Interval:');
		dialog.inputchar(vdialog
						,'Value'
						,27
						,3
						,20
						,'Enter constant numeric fee value'
						,NULL
						,'Numeric value:');
		dialog.inputchar(vdialog
						,'Percent'
						,27
						,4
						,20
						,'Enter percentage value of entry amount'
						,NULL
						,'Percentage of amount:');
		dialog.inputchar(vdialog
						,'MinValue'
						,27
						,5
						,20
						,'Enter fee minimum value'
						,NULL
						,'       Minimum value:');
		dialog.inputchar(vdialog
						,'MaxValue'
						,27
						,6
						,20
						,'Enter fee maximum value'
						,NULL
						,'        Maximum value:');
	
		dialog.button(vdialog, 'Ok', 14, 8, 11, '  Enter', dialog.cmok, 0, 'Save changes');
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
		dialog.button(vdialog
					 ,'Cancel'
					 ,27
					 ,8
					 ,11
					 ,' Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel changes');
	
		dialog.setdialogpre(vdialog, cpackagename || '.DialogEditIntProc');
		dialog.setdialogvalid(vdialog, cpackagename || '.DialogEditIntProc');
	
		dialog.putnumber(vdialog, 'What', pwhat);
	
		IF NOT security.checkright(object_name, getrightkey(right_modify))
		THEN
			dialog.setitemattributies(vdialog, 'Ok', dialog.selectoff);
		END IF;
	
		RETURN vdialog;
	END;

	PROCEDURE dialogeditintproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		vitemname VARCHAR(20);
		vret      NUMBER;
	BEGIN
		IF pwhat = dialog.wtdialogpre
		THEN
			IF dialog.getnumber(pdialog, 'What') = what_add
			THEN
				dialog.putchar(pdialog, 'Interval', NULL);
				dialog.putchar(pdialog, 'Value', NULL);
				dialog.putchar(pdialog, 'Percent', NULL);
				dialog.putchar(pdialog, 'MinValue', NULL);
				dialog.putchar(pdialog, 'MaxValue', NULL);
			ELSE
				dialog.putchar(pdialog, 'Interval', saintint(sintrecno));
				dialog.putchar(pdialog, 'Value', saintval(sintrecno));
				dialog.putchar(pdialog, 'Percent', saintprc(sintrecno));
				dialog.putchar(pdialog, 'MinValue', saintmin(sintrecno));
				dialog.putchar(pdialog, 'MaxValue', saintmax(sintrecno));
			END IF;
		
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			IF dialog.getchar(pdialog, 'Interval') IS NULL
			THEN
				dialog.sethothint(pdialog, 'Error: Field not defined');
				dialog.goitem(pdialog, 'Interval');
				RETURN;
			END IF;
		
			BEGIN
				vitemname := 'Interval';
				vret      := to_number(dialog.getchar(pdialog, 'Interval'));
				vitemname := 'Percent';
				vret      := to_number(dialog.getchar(pdialog, 'Percent'));
				vitemname := 'Value';
				vret      := to_number(dialog.getchar(pdialog, 'Value'));
				vitemname := 'MinValue';
				vret      := to_number(dialog.getchar(pdialog, 'MinValue'));
				vitemname := 'MaxValue';
				vret      := to_number(dialog.getchar(pdialog, 'MaxValue'));
			EXCEPTION
				WHEN OTHERS THEN
					dialog.sethothint(pdialog, 'Error: invalid field value');
					dialog.goitem(pdialog, vitemname);
					RETURN;
			END;
		
			vret := to_number(dialog.getchar(pdialog, 'Interval'));
			FOR i IN 1 .. sintreccount
			LOOP
				IF dialog.getnumber(pdialog, 'What') = what_add
				   AND saintint(i) = vret
				   OR dialog.getnumber(pdialog, 'What') = what_edit
				   AND saintint(i) = vret
				   AND i != sintrecno
				THEN
					dialog.sethothint(pdialog, 'Error: attempted duplication of interval value');
					dialog.goitem(pdialog, 'Interval');
					RETURN;
				END IF;
			END LOOP;
		
			IF dialog.getnumber(pdialog, 'What') = what_add
			THEN
				sintreccount := sintreccount + 1;
				sintrecno    := sintreccount;
			END IF;
			saintint(sintrecno) := to_number(dialog.getchar(pdialog, 'Interval'));
			saintval(sintrecno) := to_number(dialog.getchar(pdialog, 'Value'));
			saintprc(sintrecno) := to_number(dialog.getchar(pdialog, 'Percent'));
			saintmin(sintrecno) := to_number(dialog.getchar(pdialog, 'MinValue'));
			saintmax(sintrecno) := to_number(dialog.getchar(pdialog, 'MaxValue'));
		END IF;
	END;

	FUNCTION dialogdataint(pcommission IN NUMBER) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.DialogDataInt';
		vdialog NUMBER;
	BEGIN
		vdialog := browser.new('ReferenceCommission', 'Fee data', 0, 0, 70, 20);
		dialog.setexternalid(vdialog, cwhere);
	
		referencecurrency.makeitem(vdialog
								  ,'Currency'
								  ,16
								  ,2
								  ,3
								  ,'Currency code:'
								  ,'Select currency code from list'
								  ,40);
	
		dialog.inputinteger(vdialog, 'Commission', 0, 0, ' ');
		dialog.setitemattributies(vdialog
								 ,'Commission'
								 ,dialog.echooff || dialog.selectoff || dialog.updateoff);
		dialog.inputinteger(vdialog, 'Exchange', 0, 0, ' ');
		dialog.setitemattributies(vdialog
								 ,'Exchange'
								 ,dialog.echooff || dialog.selectoff || dialog.updateoff);
		dialog.inputchar(vdialog
						,'ExchangeName'
						,16
						,3
						,40
						,'Select conversion rate name from list'
						,NULL
						,'Rate:');
		dialog.listaddfield(vdialog, 'ExchangeName', 'Code', 'N', 5, 0);
		dialog.listaddfield(vdialog, 'ExchangeName', 'Name', 'C', 40, 1);
		dialog.setitemattributies(vdialog, 'ExchangeName', dialog.updateoff);
	
		browser.scroller(vdialog, 1, 5, 68, 13, dialog.firstrecord, '<Enter> - edit record');
		dialog.listaddfield(vdialog, 'Scroller', 'Int', 'N', 12, 1, 'R');
		dialog.listaddfield(vdialog, 'Scroller', 'Val', 'N', 12, 1, 'R');
		dialog.listaddfield(vdialog, 'Scroller', 'Prc', 'N', 12, 1, 'R');
		dialog.listaddfield(vdialog, 'Scroller', 'Min', 'N', 12, 1, 'R');
		dialog.listaddfield(vdialog, 'Scroller', 'Max', 'N', 12, 1, 'R');
	
		browser.setcaption(vdialog, 'Scroller', 'Interval~Amount~Percentage~Minimum~Maximum');
	
		dialog.button(vdialog, 'Ok', 10, 18, 11, '  Save', dialog.cmok, 0, 'Save settings');
		dialog.button(vdialog, 'Add', 23, 18, 11, '    Add', 0, 0, 'Add record');
		dialog.button(vdialog, 'Delete', 36, 18, 11, '  Delete', 0, 0, 'Delete record');
		dialog.button(vdialog, 'Cancel', 49, 18, 11, '  Exit', dialog.cmcancel, 0, 'Exit');
	
		dialog.setitempre(vdialog
						 ,'Scroller'
						 ,cpackagename || '.DialogDataIntProc'
						 ,dialog.proctype);
		dialog.setitempre(vdialog, 'Add', cpackagename || '.DialogDataIntProc', dialog.proctype);
		dialog.setitempre(vdialog, 'Delete', cpackagename || '.DialogDataIntProc', dialog.proctype);
		dialog.setitempre(vdialog, 'Cancel', cpackagename || '.DialogDataIntProc', dialog.proctype);
		dialog.setitempost(vdialog
						  ,'Scroller'
						  ,cpackagename || '.DialogDataIntProc'
						  ,dialog.proctype);
		dialog.setitempost(vdialog, 'Add', cpackagename || '.DialogDataIntProc', dialog.proctype);
		dialog.setitempost(vdialog
						  ,'Delete'
						  ,cpackagename || '.DialogDataIntProc'
						  ,dialog.proctype);
		dialog.setitempost(vdialog
						  ,'Cancel'
						  ,cpackagename || '.DialogDataIntProc'
						  ,dialog.proctype);
		browser.setdialogpre(vdialog, cpackagename || '.DialogDataIntProc');
		browser.setdialogvalid(vdialog, cpackagename || '.DialogDataIntProc');
		browser.setdialogpost(vdialog, cpackagename || '.DialogDataIntProc');
	
		dialog.putnumber(vdialog, 'Commission', pcommission);
	
		IF NOT security.checkright(object_name, getrightkey(right_modify))
		THEN
			dialog.setitemattributies(vdialog, 'Ok', dialog.selectoff);
			dialog.setitemattributies(vdialog, 'Add', dialog.selectoff);
			dialog.setitemattributies(vdialog, 'Delete', dialog.selectoff);
		END IF;
	
		RETURN vdialog;
	END;

	PROCEDURE dialogdataintproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		vdialog NUMBER;
	BEGIN
		IF pwhat = dialog.wtdialogpre
		THEN
			sfrom     := from_int;
			smodified := FALSE;
			referencecurrency.setdata(pdialog, 'Currency', scommissionrow.currency);
			fillexchangelist(pdialog, 'ExchangeName');
			dialog.putnumber(pdialog, 'Exchange', scommissionrow.exchange);
			dialog.putchar(pdialog
						  ,'ExchangeName'
						  ,substr(exchangerate.getname(dialog.getnumber(pdialog, 'Exchange'))
								 ,1
								 ,40));
			fillintervalarray(dialog.getnumber(pdialog, 'Commission'));
			browser.scrollerrefresh(pdialog, dialog.firstrecord);
			IF sintreccount = 0
			THEN
				dialog.setitemattributies(pdialog, 'Ok', dialog.selectoff);
				dialog.setitemattributies(pdialog, 'Delete', dialog.selectoff);
			END IF;
		
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF pitemname = 'SCROLLER'
			THEN
				dialog.setitemdialog(pdialog
									,pitemname
									,referencecommission.dialogeditint(what_edit));
			ELSIF pitemname = 'ADD'
			THEN
				dialog.setitemdialog(pdialog
									,pitemname
									,referencecommission.dialogeditint(what_add));
			ELSIF pitemname = 'DELETE'
			THEN
				dialog.setitemdialog(pdialog
									,pitemname
									,service.dialogconfirm('Warning !'
														  ,'Do you really want to delete records?'
														  ,'  Yes '
														  ,' '
														  ,'  No   '
														  ,' '));
			ELSIF pitemname = 'CANCEL'
			THEN
				IF smodified
				THEN
					dialog.setitemdialog(pdialog
										,pitemname
										,service.dialogconfirm3('Warning !'
															   ,'Do you want to save changes?'
															   ,'     Yes      '
															   ,'Save changes'
															   ,'     No       '
															   ,'Exit without saving changes'
															   ,'   Continue    '
															   ,'Cancel exit'));
				END IF;
			END IF;
		
		ELSIF pwhat = dialog.wtitempost
		THEN
			vdialog := dialog.getitemdialog(pdialog, pitemname);
			IF pitemname = 'SCROLLER'
			THEN
				IF dialog.getdialogcommand(vdialog) = dialog.cmok
				THEN
					smodified := TRUE;
					browser.scrollerrefresh(pdialog, dialog.currentrecord);
				END IF;
				dialog.goitem(pdialog, 'Scroller');
			
			ELSIF pitemname = 'ADD'
			THEN
				IF dialog.getdialogcommand(vdialog) = dialog.cmok
				THEN
					smodified := TRUE;
					browser.scrollerrefresh(pdialog, dialog.lastrecord);
					IF sintreccount != 0
					THEN
						IF security.checkright(object_name, getrightkey(right_modify))
						THEN
							dialog.setitemattributies(pdialog, 'Ok', dialog.selecton);
							dialog.setitemattributies(pdialog, 'Delete', dialog.selecton);
						END IF;
					END IF;
				END IF;
				dialog.goitem(pdialog, 'Scroller');
			
			ELSIF pitemname = 'DELETE'
			THEN
				IF dialog.getdialogcommand(vdialog) = dialog.cmok
				THEN
					smodified := TRUE;
					FOR i IN sintrecno .. sintreccount - 1
					LOOP
						saintint(i) := saintint(i + 1);
						saintval(i) := saintval(i + 1);
						saintprc(i) := saintprc(i + 1);
						saintmin(i) := saintmin(i + 1);
						saintmax(i) := saintmax(i + 1);
					END LOOP;
					sintreccount := sintreccount - 1;
					browser.scrollerrefresh(pdialog, least(sintrecno, sintreccount));
					IF sintreccount = 0
					THEN
						dialog.setitemattributies(pdialog, 'Ok', dialog.selectoff);
						dialog.setitemattributies(pdialog, 'Delete', dialog.selectoff);
					END IF;
				END IF;
				dialog.goitem(pdialog, 'Scroller');
			
			ELSIF pitemname = 'CANCEL'
			THEN
				IF vdialog != 0
				THEN
					IF dialog.getdialogcommand(vdialog) = dialog.cmok
					THEN
						dialog.setdialogcommand(pdialog, dialog.cmok);
					ELSIF dialog.getdialogcommand(vdialog) = dialog.cmconfirm
					THEN
						dialog.setdialogcommand(pdialog, dialog.cmcancel);
					ELSIF dialog.getdialogcommand(vdialog) = dialog.cmcancel
					THEN
						dialog.goitem(pdialog, pitemname);
					END IF;
				END IF;
			END IF;
			dialog.destroy(dialog.getitemdialog(pdialog, pitemname));
			dialog.setitemdialog(pdialog, pitemname, 0);
		
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			IF pcmd = dialog.cmconfirm
			THEN
				IF pitemname = 'EXCHANGENAME'
				THEN
					dialog.putnumber(pdialog
									,'Exchange'
									,dialog.getcurrentrecordnumber(pdialog, 'ExchangeName', 'Code'));
					dialog.goitem(pdialog, 'Scroller');
				END IF;
			ELSE
				savedataint(pdialog);
			END IF;
		
		ELSIF pwhat = dialog.wtdialogpost
		THEN
			sfrom := from_lst;
		END IF;
	END;

	FUNCTION dialoglist RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.DialogList';
		vdialog   NUMBER;
		vmainmenu NUMBER;
	
		vservicemenu NUMBER;
	
	BEGIN
		vdialog := browser.new('ReferenceCommission', 'Dictionary of fees', 0, 0, 80, 20);
		dialog.setexternalid(vdialog, cwhere);
	
		browser.scroller(vdialog, 1, 2, 78, 16, dialog.firstrecord, '<Enter> - edit record');
		dialog.listaddfield(vdialog, 'Scroller', 'Debit', 'C', 20, 1);
		dialog.listaddfield(vdialog, 'Scroller', 'Credit', 'C', 20, 1);
		dialog.listaddfield(vdialog, 'Scroller', 'Name', 'C', 100, 1);
	
		browser.setcaption(vdialog, 'Scroller', 'Debit~Credit~Name');
	
		dialog.button(vdialog, 'Add', 22, 18, 11, 'Add', 0, 0, 'Add fee');
		dialog.button(vdialog, 'Delete', 36, 18, 11, 'Delete', 0, 0, 'Delete fee');
		dialog.button(vdialog, 'Cancel', 50, 18, 11, 'Exit', dialog.cmcancel, 0, 'Exit');
	
		vmainmenu := mnu.new(vdialog);
		browser.standardmenufind(vmainmenu);
		browser.setdialogmenu(vdialog, vmainmenu);
	
		vservicemenu := mnu.submenu(vmainmenu, 'Service', 'Service');
		mnu.item(vservicemenu, 'mnu_ParamView', 'Viewing parameters', 0, 0, ' ');
		dialog.setitempre(vdialog
						 ,'mnu_ParamView'
						 ,cpackagename || '.DialogListProc'
						 ,dialog.proctype);
	
		dialog.setitempre(vdialog, 'Scroller', cpackagename || '.DialogListProc', dialog.proctype);
		dialog.setitempre(vdialog, 'Add', cpackagename || '.DialogListProc', dialog.proctype);
		dialog.setitempre(vdialog, 'Delete', cpackagename || '.DialogListProc', dialog.proctype);
		dialog.setitempost(vdialog, 'Scroller', cpackagename || '.DialogListProc', dialog.proctype);
		dialog.setitempost(vdialog, 'Add', cpackagename || '.DialogListProc', dialog.proctype);
		dialog.setitempost(vdialog, 'Delete', cpackagename || '.DialogListProc', dialog.proctype);
		browser.setdialogpre(vdialog, cpackagename || '.DialogListProc');
		browser.setdialogpost(vdialog, cpackagename || '.DialogListProc');
	
		IF NOT security.checkright(object_name, getrightkey(right_modify))
		THEN
			dialog.setitemattributies(vdialog, 'Add', dialog.selectoff);
			dialog.setitemattributies(vdialog, 'Delete', dialog.selectoff);
		END IF;
	
		dialog.setdialogresizeable(vdialog, TRUE);
		dialog.setdialogcanmaximize(vdialog, TRUE);
	
		dialog.setanchor(vdialog, 'Scroller', dialog.anchor_all);
		dialog.setanchor(vdialog, 'Add', dialog.anchor_bottom);
		dialog.setanchor(vdialog, 'Delete', dialog.anchor_bottom);
		dialog.setanchor(vdialog, 'Cancel', dialog.anchor_bottom);
	
		RETURN vdialog;
	END;

	PROCEDURE dialoglistproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		vdialog NUMBER;
		dummy   VARCHAR2(250);
	BEGIN
		IF pwhat = dialog.wtdialogpre
		THEN
			IF NOT security.checkright(object_name, getrightkey(right_view))
			THEN
				service.saymsg(pdialog, 'Warning !', 'You are not authorized to view dictionary~');
				dialog.abort(pdialog);
				RETURN;
			END IF;
		
			IF security.checkright(object_name, getrightkey(right_modify))
			THEN
				IF object.capture(object_name, object_name) != 0
				THEN
				
					CASE err.geterrorcode
						WHEN err.object_busy THEN
						
							service.saymsg(pdialog
										  ,'Warning !'
										  ,'Dictionary is being edited from another station~' ||
										   object.capturedobjectinfo(object_name, object_name) || '~');
						
						ELSE
							service.sayerr(pdialog, 'Warning !');
					END CASE;
				
					dialog.abort(pdialog);
					RETURN;
				END IF;
				scaptured := TRUE;
			ELSE
				scaptured := FALSE;
			END IF;
		
			sfrom := from_lst;
		
			dynasetopen;
			browser.scrollerrefresh(pdialog, dialog.firstrecord);
			IF slstreccount = 0
			THEN
				dialog.setitemattributies(pdialog, 'Delete', dialog.selectoff);
			END IF;
		
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF pitemname = 'SCROLLER'
			THEN
				dummy := gettext(browser.getcurpos(pdialog));
				dialog.setitemdialog(pdialog, pitemname, dialogupdate(what_edit));
			ELSIF pitemname = 'ADD'
			THEN
				dialog.setitemdialog(pdialog, pitemname, dialogupdate(what_add));
			ELSIF pitemname = 'DELETE'
			THEN
				dummy := gettext(browser.getcurpos(pdialog));
				dialog.setitemdialog(pdialog
									,pitemname
									,service.dialogconfirm('Warning !'
														  ,'Do you really want to delete fee [' ||
														   scommissionrow.name || '] ?'
														  ,'  Yes '
														  ,' '
														  ,'  No   '
														  ,' '));
			
			ELSIF pitemname = 'MNU_PARAMVIEW'
			THEN
				IF dialog.exec(dialogparamview) = dialog.cmok
				THEN
					dynaset.close(sdshandle);
					dynasetopen;
					browser.scrollerrefresh(pdialog, least(slstrecno, slstreccount));
				END IF;
			
			END IF;
		
		ELSIF pwhat = dialog.wtitempost
		THEN
			vdialog := dialog.getitemdialog(pdialog, pitemname);
			IF dialog.getdialogcommand(dialog.getitemdialog(pdialog, pitemname)) = dialog.cmok
			THEN
				IF pitemname = 'SCROLLER'
				THEN
					browser.scrollerrefresh(pdialog, dialog.currentrecord);
				
				ELSIF pitemname = 'ADD'
				THEN
					dynaset.close(sdshandle);
					dynasetopen;
					browser.scrollerrefresh(pdialog, dialog.lastrecord);
					IF slstreccount != 0
					THEN
						IF security.checkright(object_name, getrightkey(right_modify))
						THEN
							dialog.setitemattributies(pdialog, 'Delete', dialog.selecton);
						END IF;
					END IF;
				
				ELSIF pitemname = 'DELETE'
				THEN
					deletecommission;
					IF err.geterrorcode != 0
					THEN
						dialog.destroy(dialog.getitemdialog(pdialog, pitemname));
						service.sayerr(pdialog, 'Warning !');
						RETURN;
					END IF;
					dynaset.close(sdshandle);
					dynasetopen;
					browser.scrollerrefresh(pdialog, least(slstrecno, slstreccount));
					IF slstreccount = 0
					THEN
						dialog.setitemattributies(pdialog, 'Delete', dialog.selectoff);
					END IF;
				END IF;
			END IF;
			dialog.destroy(dialog.getitemdialog(pdialog, pitemname));
			dialog.setitemdialog(pdialog, pitemname, 0);
			dialog.goitem(pdialog, 'Scroller');
		
		ELSIF pwhat = dialog.wtdialogpost
		THEN
			dynaset.close(sdshandle);
			IF scaptured
			THEN
				object.release(object_name, object_name);
			END IF;
		END IF;
	END;

	FUNCTION dialogupdate(pwhat IN NUMBER) RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.DialogUpdate';
		vcaption VARCHAR(100);
		vdialog  NUMBER;
	BEGIN
	
		IF pwhat = what_add
		THEN
			vcaption := 'Add fee';
		ELSE
			vcaption := 'Edit fee';
		END IF;
		vdialog := dialog.new(vcaption, 0, 0, 80, 17, pextid => cwhere);
	
		dialog.inputinteger(vdialog, 'What', 0, 0, ' ');
		dialog.setitemattributies(vdialog
								 ,'What'
								 ,dialog.echooff || dialog.selectoff || dialog.updateoff);
		dialog.inputinteger(vdialog, 'Commission', 0, 0, ' ');
		dialog.setitemattributies(vdialog
								 ,'Commission'
								 ,dialog.echooff || dialog.selectoff || dialog.updateoff);
		dialog.inputchar(vdialog, 'Name', 16, 2, 57, 'Enter fee name', 100, '        Name:');
		dialog.inputchar(vdialog
						,'Debit'
						,16
						,4
						,20
						,'Select fee debit component from list'
						,NULL
						,'Debit:');
		dialog.setitemattributies(vdialog, 'Debit', dialog.updateoff);
		dialog.listaddfield(vdialog, 'Debit', 'Debit', 'C', 20, 1);
		dialog.inputchar(vdialog
						,'DebitLink'
						,51
						,4
						,20
						,'Select fee debit component link from list'
						,NULL
						,' Link:');
		dialog.setitemattributies(vdialog, 'DebitLink', dialog.updateoff);
		dialog.listaddfield(vdialog, 'DebitLink', 'DebitLink', 'C', 20, 1);
		dialog.inputchar(vdialog
						,'Credit'
						,16
						,5
						,20
						,'Select fee credit component from list'
						,NULL
						,'Credit:');
		dialog.setitemattributies(vdialog, 'Credit', dialog.updateoff);
		dialog.listaddfield(vdialog, 'Credit', 'Credit', 'C', 20, 1);
		dialog.inputchar(vdialog
						,'CreditLink'
						,51
						,5
						,20
						,'Select fee credit component link from list'
						,NULL
						,' Link:');
		dialog.setitemattributies(vdialog, 'CreditLink', dialog.updateoff);
		dialog.listaddfield(vdialog, 'CreditLink', 'CreditLink', 'C', 20, 1);
		dialog.inputinteger(vdialog, 'Method', 0, 0, ' ');
		dialog.setitemattributies(vdialog
								 ,'Method'
								 ,dialog.echooff || dialog.selectoff || dialog.updateoff);
	
		windows.edittext(vdialog
						,'Description'
						,16
						,8
						,57
						,4
						,'Enter fee description'
						,'  Descr.:');
		dialog.checkbox(vdialog, 'Stat', 16, 12, 55, 1, 'Define fee charge conditions');
		dialog.listaddrecord(vdialog, 'Stat', 'Charge if no funds in acct', 0, 0);
	
		dialog.button(vdialog, 'Ok', 22, 15, 11, '  Enter', dialog.cmok, 0, 'Save changes');
		dialog.setitemattributies(vdialog, 'Ok', dialog.defaulton);
		dialog.button(vdialog, 'Data', 36, 15, 11, '   Data ', 0, 0, 'Fee data');
		dialog.button(vdialog
					 ,'Cancel'
					 ,50
					 ,15
					 ,11
					 ,' Cancel'
					 ,dialog.cmcancel
					 ,0
					 ,'Cancel changes');
	
		dialog.setitempre(vdialog, 'Data', cpackagename || '.DialogUpdateProc', dialog.proctype);
		dialog.setitempost(vdialog, 'Data', cpackagename || '.DialogUpdateProc', dialog.proctype);
		dialog.setdialogpre(vdialog, cpackagename || '.DialogUpdateProc');
		dialog.setdialogvalid(vdialog, cpackagename || '.DialogUpdateProc');
		dialog.setdialogpost(vdialog, cpackagename || '.DialogUpdateProc');
	
		dialog.putnumber(vdialog, 'What', pwhat);
	
		IF NOT security.checkright(object_name, getrightkey(right_modify))
		THEN
			dialog.setitemattributies(vdialog, 'Ok', dialog.selectoff);
		END IF;
	
		RETURN vdialog;
	END;

	PROCEDURE dialogupdateproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		vitemname VARCHAR(20);
		vbranch   NUMBER := seance.getbranch;
	BEGIN
		IF pwhat = dialog.wtdialogpre
		THEN
			SAVEPOINT referencecommissiondialogupd;
			IF dialog.getnumber(pdialog, 'What') = what_add
			THEN
				dialog.putnumber(pdialog, 'Commission', getfreecommission);
				dialog.putchar(pdialog, 'Debit', NULL);
				dialog.putchar(pdialog, 'DebitLink', NULL);
				dialog.putchar(pdialog, 'Credit', NULL);
				dialog.putchar(pdialog, 'CreditLink', NULL);
				dialog.putnumber(pdialog, 'Method', method_interval);
				dialog.putchar(pdialog, 'Name', NULL);
				dialog.puttext(pdialog, 'Description', NULL);
				dialog.putchar(pdialog, 'Stat', NULL);
				dialog.setitemattributies(pdialog, 'Ok', dialog.selectoff);
				scommissionrow.currency := NULL;
				scommissionrow.exchange := NULL;
			ELSE
				dialog.putnumber(pdialog, 'Commission', scommissionrow.commission);
				dialog.putchar(pdialog, 'Debit', getdbcrstrbyvalue(scommissionrow.debit));
				dialog.putchar(pdialog, 'DebitLink', scommissionrow.debitlink);
				dialog.putchar(pdialog, 'Credit', getdbcrstrbyvalue(scommissionrow.credit));
				dialog.putchar(pdialog, 'CreditLink', scommissionrow.creditlink);
				BEGIN
					dialog.putnumber(pdialog, 'Method', scommissionrow.method);
				EXCEPTION
					WHEN OTHERS THEN
						dialog.putnumber(pdialog, 'Method', method_interval);
				END;
			
				dialog.putchar(pdialog, 'Name', scommissionrow.name);
				dialog.puttext(pdialog, 'Description', scommissionrow.description);
				dialog.putchar(pdialog, 'Stat', scommissionrow.stat);
			END IF;
			fillaccountlist(pdialog, 'Debit');
			filllinklist(pdialog, 'DebitLink');
			fillaccountlist(pdialog, 'Credit');
			filllinklist(pdialog, 'CreditLink');
		
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF pitemname = 'DATA'
			THEN
				IF dialog.getnumber(pdialog, 'Method') = method_interval
				THEN
					dialog.setitemdialog(pdialog
										,'Data'
										,dialogdataint(dialog.getnumber(pdialog, 'Commission')));
				END IF;
			END IF;
		
		ELSIF pwhat = dialog.wtitempost
		THEN
			IF pitemname = 'DATA'
			   AND dialog.getdialogcommand(dialog.getitemdialog(pdialog, 'Data')) = dialog.cmok
			THEN
				IF dialog.getnumber(pdialog, 'What') = what_edit
				THEN
					COMMIT;
				END IF;
				IF security.checkright(object_name, getrightkey(right_modify))
				THEN
					dialog.setitemattributies(pdialog, 'Ok', dialog.selecton);
					dialog.goitem(pdialog, 'Ok');
				ELSE
					dialog.goitem(pdialog, pitemname);
				END IF;
			END IF;
			dialog.destroy(dialog.getitemdialog(pdialog, pitemname));
			dialog.setitemdialog(pdialog, pitemname, 0);
		
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			IF pcmd = dialog.cmconfirm
			THEN
				IF pitemname = 'DEBIT'
				THEN
					dialog.goitem(pdialog, 'DebitLink');
				ELSIF pitemname = 'DEBITLINK'
				THEN
					dialog.goitem(pdialog, 'Credit');
				ELSIF pitemname = 'CREDIT'
				THEN
					dialog.goitem(pdialog, 'CreditLink');
				ELSIF pitemname = 'CREDITLINK'
				THEN
				
					dialog.goitem(pdialog, 'Name');
				
				END IF;
			
			ELSIF pcmd = dialog.cmok
			THEN
				scommissionadd.commission  := dialog.getnumber(pdialog, 'Commission');
				scommissionadd.debit       := getdbcrvaluebystr(dialog.getchar(pdialog, 'Debit'));
				scommissionadd.debitlink   := dialog.getchar(pdialog, 'DebitLink');
				scommissionadd.credit      := getdbcrvaluebystr(dialog.getchar(pdialog, 'Credit'));
				scommissionadd.creditlink  := dialog.getchar(pdialog, 'CreditLink');
				scommissionadd.method      := dialog.getnumber(pdialog, 'Method');
				scommissionadd.name        := dialog.getchar(pdialog, 'Name');
				scommissionadd.description := substr(dialog.gettext(pdialog, 'Description'), 1, 256);
				scommissionadd.stat        := rtrim(dialog.getchar(pdialog, 'Stat'));
				IF scommissionadd.currency IS NULL
				THEN
					scommissionadd.currency := scommissionrow.currency;
					scommissionadd.exchange := scommissionrow.exchange;
				END IF;
			
				IF scommissionadd.debit IS NULL
				THEN
					vitemname := 'Debit';
				ELSIF scommissionadd.credit IS NULL
				THEN
					vitemname := 'Credit';
				
				ELSIF scommissionadd.name IS NULL
				THEN
					vitemname := 'Name';
				END IF;
			
				IF vitemname IS NOT NULL
				THEN
					dialog.sethothint(pdialog, 'Error: Field not defined');
					dialog.goitem(pdialog, vitemname);
					RETURN;
				END IF;
			
				BEGIN
					SAVEPOINT referencecommissiondialogvalid;
					IF dialog.getnumber(pdialog, 'What') = what_add
					THEN
						scommissionadd.entident := getentident(scommissionadd.commission);
						INSERT INTO treferencecommission
						VALUES
							(vbranch
							,scommissionadd.commission
							,scommissionadd.name
							,scommissionadd.debit
							,scommissionadd.debitlink
							,scommissionadd.credit
							,scommissionadd.creditlink
							,scommissionadd.method
							,scommissionadd.entident
							,scommissionadd.description
							,scommissionadd.stat
							,scommissionadd.currency
							,scommissionadd.exchange);
						referenceentry.addentry(scommissionadd.entident
											   ,code_base24
											   ,scommissionadd.name);
						logparam('Name', scommissionadd.name, TRUE);
						logparam('Debit', scommissionadd.debit);
						logparam('DebitLink', scommissionadd.debitlink);
						logparam('Credit', scommissionadd.credit);
						logparam('CreditLink', scommissionadd.creditlink);
						logparam('Method', scommissionadd.method);
						logparam('EntIdent', scommissionadd.entident);
						logparam('Description', scommissionadd.description);
						logparam('Stat', scommissionadd.stat);
						logparam('Currency', scommissionadd.currency);
						logparam('Exchange', scommissionadd.exchange);
						log(scommissionadd.commission
						   ,'Add fee ' || scommissionadd.name || ', Debit: ' ||
							scommissionadd.debit || ', DebitLink: ' || scommissionadd.debitlink ||
							', Credit: ' || scommissionadd.credit || ', CreditLink: ' ||
							scommissionadd.creditlink || ', Method: ' || scommissionadd.method ||
							', EntIdent: ' || scommissionadd.entident || ', Description: ' ||
							scommissionadd.description || ', Stat: ' || scommissionadd.stat ||
							', Currency: ' || scommissionadd.currency || ', Exchange: ' ||
							scommissionadd.exchange
						   ,a4mlog.act_add);
					ELSE
						UPDATE treferencecommission
						SET    NAME        = scommissionadd.name
							  ,debit       = scommissionadd.debit
							  ,debitlink   = scommissionadd.debitlink
							  ,credit      = scommissionadd.credit
							  ,creditlink  = scommissionadd.creditlink
							  ,method      = scommissionadd.method
							  ,description = scommissionadd.description
							  ,stat        = scommissionadd.stat
							  ,currency    = scommissionadd.currency
							  ,exchange    = scommissionadd.exchange
						WHERE  branch = vbranch
						AND    commission = scommissionrow.commission;
						referenceentry.updateentry(scommissionrow.entident
												  ,code_base24
												  ,scommissionadd.name);
						logparam('Name', scommissionadd.name, TRUE);
						logparam('Debit', scommissionadd.debit);
						logparam('DebitLink', scommissionadd.debitlink);
						logparam('Credit', scommissionadd.credit);
						logparam('CreditLink', scommissionadd.creditlink);
						logparam('Method', scommissionadd.method);
						logparam('EntIdent', scommissionadd.entident);
						logparam('Description', scommissionadd.description);
						logparam('Stat', scommissionadd.stat);
						logparam('Currency', scommissionadd.currency);
						logparam('Exchange', scommissionadd.exchange);
						log(scommissionadd.commission
						   ,'Change fee ' || scommissionadd.name || ', Debit: ' ||
							scommissionadd.debit || ', DebitLink: ' || scommissionadd.debitlink ||
							', Credit: ' || scommissionadd.credit || ', CreditLink: ' ||
							scommissionadd.creditlink || ', Method: ' || scommissionadd.method ||
							', EntIdent: ' || scommissionrow.entident || ', Description: ' ||
							scommissionadd.description || ', Stat: ' || scommissionadd.stat ||
							', Currency: ' || scommissionadd.currency || ', Exchange: ' ||
							scommissionadd.exchange
						   ,a4mlog.act_change);
					END IF;
					IF err.geterrorcode != 0
					THEN
						ROLLBACK TO referencecommissiondialogvalid;
						service.sayerr(pdialog, 'Warning !');
						dialog.goitem(pdialog, pitemname);
						RETURN;
					END IF;
					COMMIT;
				EXCEPTION
					WHEN OTHERS THEN
						ROLLBACK TO referencecommissiondialogvalid;
						err.seterror(SQLCODE, cpackagename || '.DialogUpdateProc');
						service.sayerr(pdialog, 'Warning !');
						dialog.goitem(pdialog, pitemname);
				END;
			END IF;
		
		ELSIF pwhat = dialog.wtdialogpost
		THEN
			IF dialog.getdialogcommand(pdialog) = dialog.cmcancel
			THEN
				BEGIN
					ROLLBACK TO referencecommissiondialogupd;
				EXCEPTION
					WHEN OTHERS THEN
						NULL;
				END;
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, cpackagename || '.DialogUpdateProc');
			service.sayerr(pdialog, 'Warning !');
			dialog.goitem(pdialog, pitemname);
	END;

	PROCEDURE fillsecurityarray
	(
		plevel IN NUMBER
	   ,pkey   IN VARCHAR
	) IS
	BEGIN
		IF plevel = 1
		THEN
			security.stitle := 'List of allowed actions';
			security.sarraysize := 2;
			security.scodearray(1) := right_view;
			security.scodearray(2) := right_modify;
			security.stextarray(1) := 'View';
			security.stextarray(2) := 'Modification';
		ELSE
			security.sarraysize := 0;
		END IF;
	END;

	FUNCTION getcount RETURN NUMBER IS
	BEGIN
		IF sfrom = from_lst
		THEN
			slstreccount := dynaset.getcount(sdshandle);
			RETURN slstreccount;
		ELSIF sfrom = from_int
		THEN
			RETURN sintreccount;
		END IF;
	END;

	FUNCTION getcheck(pcommission IN NUMBER) RETURN NUMBER IS
	BEGIN
		IF rtrim(substr(sacommissionstat(pcommission), 1, 1)) IS NULL
		THEN
			RETURN entry.flcheck;
		ELSE
			RETURN entry.flnocheck;
		END IF;
	END;

	FUNCTION getentident(pcommission IN NUMBER) RETURN VARCHAR IS
	BEGIN
		RETURN 'OPCOM_' || lpad(to_char(pcommission), 5, '0');
	END;

	FUNCTION getname(pcommission IN NUMBER) RETURN VARCHAR IS
		vname   treferencecommission.name%TYPE;
		vbranch NUMBER := seance.getbranch;
	BEGIN
		SELECT NAME
		INTO   vname
		FROM   treferencecommission
		WHERE  branch = vbranch
		AND    commission = pcommission;
	
		RETURN vname;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetName');
			RETURN NULL;
	END;

	FUNCTION gettext(pno IN NUMBER) RETURN VARCHAR IS
		vdebit  VARCHAR(40);
		vcredit VARCHAR(40);
		vrowid  VARCHAR(20);
	
		c_db CONSTANT VARCHAR(5) := 'D -> ';
		c_cr CONSTANT VARCHAR(5) := 'C -> ';
	
	BEGIN
		IF sfrom = from_lst
		THEN
			slstrecno := pno;
			vrowid    := dynaset.getkeys(sdshandle, pno);
			SELECT *
			INTO   scommissionrow
			FROM   treferencecommission
			WHERE  ROWID = chartorowid(substr(vrowid, -18));
		
			IF scommissionrow.debitlink IS NULL
			THEN
				vdebit := getdbcrstrbyvalue(scommissionrow.debit);
			ELSE
			
				IF scommissionrow.debit IN (debit_account, cvaluestr_debit)
				THEN
					vdebit := c_db || scommissionrow.debitlink;
				
				ELSIF scommissionrow.debit IN (credit_account, cvaluestr_credit)
				THEN
					vdebit := c_cr || scommissionrow.debitlink;
				END IF;
			END IF;
		
			IF scommissionrow.creditlink IS NULL
			THEN
				vcredit := getdbcrstrbyvalue(scommissionrow.credit);
			ELSE
				IF scommissionrow.credit IN (debit_account, cvaluestr_debit)
				THEN
					vcredit := c_db || scommissionrow.creditlink;
				
				ELSIF scommissionrow.credit IN (credit_account, cvaluestr_credit)
				THEN
					vcredit := c_cr || scommissionrow.creditlink;
				END IF;
			END IF;
		
			RETURN vdebit || '~' || vcredit || '~' || scommissionrow.name || '~';
		
		ELSIF sfrom = from_int
		THEN
			sintrecno := pno;
			RETURN to_char(saintint(sintrecno)) || '~' || to_char(saintval(sintrecno)) || '~' || to_char(saintprc(sintrecno)) || '~' || to_char(saintmin(sintrecno)) || '~' || to_char(saintmax(sintrecno)) || '~';
		END IF;
	END;

	PROCEDURE init
	(
		ptypeobject    IN NUMBER
	   ,pkeyobject     IN VARCHAR
	   ,pdebitaccount  IN VARCHAR
	   ,pcreditaccount IN VARCHAR
	   ,pvalue         IN NUMBER
	   ,pdate          IN DATE
	   ,pcurrency      IN NUMBER := NULL
		
	) IS
		vbranch NUMBER := seance.getbranch;
		CURSOR c1 IS
			SELECT b.*
			FROM   tcommission          a
				  ,treferencecommission b
			WHERE  a.branch = vbranch
			AND    a.typeobject = ptypeobject
			AND    a.keyobject = pkeyobject
			AND    b.branch = a.branch
			AND    b.commission = a.commission;
	
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.Init';
		vcommissionrow treferencecommission%ROWTYPE;
		vcurrency      NUMBER;
	
		vdebitdirection  NUMBER;
		vcreditdirection NUMBER;
	
		vcommcurrency NUMBER;
	BEGIN
	
		err.seterror(0, cwhere);
		s.say(cwhere || '|pDebitAccount  = ' || pdebitaccount);
		s.say(cwhere || '|pCreditAccount = ' || pcreditaccount);
	
		scommissioncount := 0;
		vcurrency        := nvl(pcurrency, account.getcurrencybyaccountno(pdebitaccount));
		IF vcurrency IS NULL
		THEN
			RETURN;
		END IF;
		FOR i IN c1
		LOOP
			scommissioncount := scommissioncount + 1;
		
			sacommission(scommissioncount) := i.commission;
		
			IF i.debit IN (debit_account, cvaluestr_debit)
			THEN
				sacommissiondebitaccount(scommissioncount) := pdebitaccount;
			
			ELSIF i.debit IN (credit_account, cvaluestr_credit)
			THEN
				sacommissiondebitaccount(scommissioncount) := pcreditaccount;
			END IF;
		
			IF i.debitlink IS NOT NULL
			THEN
				sacommissiondebitaccount(scommissioncount) := planaccount.getlinkedaccountno(sacommissiondebitaccount(scommissioncount)
																							,i.debitlink);
				IF sacommissiondebitaccount(scommissioncount) IS NULL
				THEN
					RETURN;
				END IF;
			END IF;
		
			IF i.credit IN (credit_account, cvaluestr_credit)
			THEN
				sacommissioncreditaccount(scommissioncount) := pcreditaccount;
			
			ELSIF i.credit IN (debit_account, cvaluestr_debit)
			THEN
				sacommissioncreditaccount(scommissioncount) := pdebitaccount;
			END IF;
		
			IF i.creditlink IS NOT NULL
			THEN
				sacommissioncreditaccount(scommissioncount) := planaccount.getlinkedaccountno(sacommissioncreditaccount(scommissioncount)
																							 ,i.creditlink);
				IF sacommissioncreditaccount(scommissioncount) IS NULL
				THEN
					RETURN;
				END IF;
			END IF;
		
			sacommissionentcode(scommissioncount) := referenceentry.getcode(i.entident);
			IF sacommissionentcode(scommissioncount) IS NULL
			THEN
				RETURN;
			END IF;
		
			vcommissionrow.commission := i.commission;
			vcommissionrow.method := i.method;
			vcommissionrow.currency := i.currency;
			vcommissionrow.exchange := i.exchange;
			sacommissionvalue(scommissioncount) := pvalue;
			sacommissioncreditvalue(scommissioncount) := pvalue;
			sacommissionstat(scommissioncount) := i.stat;
			sacommissionexchange(scommissioncount) := i.exchange;
			sacommissioncurrency(scommissioncount) := account.getcurrencybyaccountno(sacommissiondebitaccount(scommissioncount));
			sacommissioncreditcurrency(scommissioncount) := account.getcurrencybyaccountno(sacommissioncreditaccount(scommissioncount));
			IF sacommissioncurrency(scommissioncount) IS NULL
			   OR sacommissioncreditcurrency(scommissioncount) IS NULL
			THEN
				RETURN;
			END IF;
		
			BEGIN
				s.say(cwhere || '|pDebitAccount  = ' || pdebitaccount);
				s.say(cwhere || '|pCreditAccount = ' || pcreditaccount);
				s.say(cwhere || '|saCommissionDebitAccount  = ' ||
					  sacommissiondebitaccount(scommissioncount));
				s.say(cwhere || '|saCommissionCreditAccount = ' ||
					  sacommissioncreditaccount(scommissioncount));
			
				s.say(cwhere || '|vCurrency                  = ' || vcurrency);
				s.say(cwhere || '|saCommissionCreditCurrency = ' ||
					  sacommissioncreditcurrency(scommissioncount));
				s.say(cwhere || '|saCommissionCurrency       = ' ||
					  sacommissioncurrency(scommissioncount));
			
			EXCEPTION
				WHEN no_data_found THEN
					error.save(cwhere);
			END;
		
			vcommcurrency := nvl(i.currency, seance.getcurrency);
			IF (vcommcurrency = sacommissioncreditcurrency(scommissioncount) OR
			   vcommcurrency = sacommissioncurrency(scommissioncount))
			THEN
			
				s.say(cpackagename || '.Init|vCommCurrency = any');
				vdebitdirection  := cdvdebit;
				vcreditdirection := cdvcredit;
			
			ELSIF (vcommcurrency != sacommissioncreditcurrency(scommissioncount) AND
				  vcommcurrency != sacommissioncurrency(scommissioncount))
			THEN
				s.say(cpackagename || '.Init|vCommCurrency != any');
				vdebitdirection  := cdvdebit;
				vcreditdirection := cdvcredit;
			ELSE
				s.say(cpackagename || '.Init|vCommCurrency ?');
			END IF;
		
			IF calc(vcommissionrow
				   ,pvalue
				   ,vcurrency
				   ,sacommissionvalue(scommissioncount)
				   ,sacommissioncurrency(scommissioncount)
				   ,sacommissioncreditvalue(scommissioncount)
				   ,sacommissioncreditcurrency(scommissioncount)
				   ,pdate
				   ,vdebitdirection
				   ,vcreditdirection) != 0
			THEN
				RETURN;
			END IF;
			IF sacommissionvalue(scommissioncount) = 0
			   OR sacommissioncreditvalue(scommissioncount) = 0
			THEN
				scommissioncount := scommissioncount - 1;
			END IF;
		END LOOP;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
		
	END;

	PROCEDURE init
	(
		pcommission    IN NUMBER
	   ,pdebitaccount  IN VARCHAR
	   ,pcreditaccount IN VARCHAR
	   ,pvalue         IN NUMBER
	   ,pdate          IN DATE
	   ,pcurrency      IN NUMBER := NULL
	) IS
		vbranch NUMBER := seance.getbranch;
		CURSOR c1 IS
			SELECT *
			FROM   treferencecommission
			WHERE  branch = vbranch
			AND    commission = pcommission;
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.Init';
		vcommissionrow treferencecommission%ROWTYPE;
		vcurrency      NUMBER;
		vcommcurrency  NUMBER;
		vdebitignore   BOOLEAN;
		vcreditignore  BOOLEAN;
	
		vdebitdirection  NUMBER;
		vcreditdirection NUMBER;
	
	BEGIN
		s.say(cwhere);
		err.seterror(0, cwhere);
	
		scommissioncount := 0;
		vcurrency        := nvl(pcurrency, account.getcurrencybyaccountno(pdebitaccount));
		IF vcurrency IS NULL
		THEN
			RETURN;
		END IF;
		FOR i IN c1
		LOOP
		
			vdebitignore  := FALSE;
			vcreditignore := FALSE;
		
			scommissioncount := scommissioncount + 1;
			sacommission(scommissioncount) := i.commission;
		
			IF i.debit IN (debit_account, cvaluestr_debit)
			THEN
				IF pdebitaccount IS NOT NULL
				THEN
					sacommissiondebitaccount(scommissioncount) := pdebitaccount;
				ELSE
					vdebitignore := TRUE;
				END IF;
			ELSIF i.debit IN (credit_account, cvaluestr_credit)
			THEN
				IF pcreditaccount IS NOT NULL
				THEN
					sacommissiondebitaccount(scommissioncount) := pcreditaccount;
				ELSE
					vdebitignore := TRUE;
				END IF;
			END IF;
		
			IF i.debitlink IS NOT NULL
			   AND vdebitignore = FALSE
			THEN
				sacommissiondebitaccount(scommissioncount) := planaccount.getlinkedaccountno(sacommissiondebitaccount(scommissioncount)
																							,i.debitlink);
				IF sacommissiondebitaccount(scommissioncount) IS NULL
				THEN
					RETURN;
				END IF;
			END IF;
		
			IF i.credit IN (credit_account, cvaluestr_credit)
			THEN
				IF pcreditaccount IS NOT NULL
				THEN
					sacommissioncreditaccount(scommissioncount) := pcreditaccount;
				ELSE
					vcreditignore := TRUE;
				END IF;
			
			ELSIF i.credit IN (debit_account, cvaluestr_debit)
			THEN
				IF pdebitaccount IS NOT NULL
				THEN
					sacommissioncreditaccount(scommissioncount) := pdebitaccount;
				ELSE
					vcreditignore := TRUE;
				END IF;
			END IF;
		
			IF i.creditlink IS NOT NULL
			   AND vcreditignore = FALSE
			THEN
				sacommissioncreditaccount(scommissioncount) := planaccount.getlinkedaccountno(sacommissioncreditaccount(scommissioncount)
																							 ,i.creditlink);
				IF sacommissioncreditaccount(scommissioncount) IS NULL
				THEN
					RETURN;
				END IF;
			END IF;
		
			IF vdebitignore = FALSE
			   OR vcreditignore = FALSE
			THEN
				sacommissionentcode(scommissioncount) := referenceentry.getcode(i.entident);
				IF sacommissionentcode(scommissioncount) IS NULL
				THEN
					RETURN;
				END IF;
				vcommissionrow.commission := i.commission;
				vcommissionrow.method := i.method;
				vcommissionrow.currency := i.currency;
				vcommissionrow.exchange := i.exchange;
				sacommissionstat(scommissioncount) := i.stat;
				sacommissionexchange(scommissioncount) := i.exchange;
				IF vdebitignore = FALSE
				THEN
					sacommissioncurrency(scommissioncount) := account.getcurrencybyaccountno(sacommissiondebitaccount(scommissioncount));
					IF sacommissioncurrency(scommissioncount) IS NULL
					THEN
						RETURN;
					END IF;
					sacommissionvalue(scommissioncount) := pvalue;
				ELSE
					sacommissioncurrency(scommissioncount) := NULL;
					sacommissionvalue(scommissioncount) := NULL;
				END IF;
				IF vcreditignore = FALSE
				THEN
					sacommissioncreditcurrency(scommissioncount) := account.getcurrencybyaccountno(sacommissioncreditaccount(scommissioncount));
					IF sacommissioncreditcurrency(scommissioncount) IS NULL
					THEN
						RETURN;
					END IF;
					sacommissioncreditvalue(scommissioncount) := pvalue;
				ELSE
					sacommissioncreditcurrency(scommissioncount) := NULL;
					sacommissioncreditvalue(scommissioncount) := NULL;
				END IF;
				BEGIN
					s.say(cwhere || '|pDebitAccount  = ' || pdebitaccount);
					s.say(cwhere || '|pCreditAccount = ' || pcreditaccount);
					s.say(cwhere || '|saCommissionDebitAccount  = ' ||
						  sacommissiondebitaccount(scommissioncount));
					s.say(cwhere || '|saCommissionCreditAccount = ' ||
						  sacommissioncreditaccount(scommissioncount));
				
					s.say(cwhere || '|vCurrency                  = ' || vcurrency);
					s.say(cwhere || '|saCommissionCreditCurrency = ' ||
						  sacommissioncreditcurrency(scommissioncount));
					s.say(cwhere || '|saCommissionCurrency       = ' ||
						  sacommissioncurrency(scommissioncount));
				
				EXCEPTION
					WHEN no_data_found THEN
						error.save(cwhere);
				END;
			
				vcommcurrency := nvl(i.currency, seance.getcurrency);
				IF (vcommcurrency = sacommissioncreditcurrency(scommissioncount) OR
				   vcommcurrency = sacommissioncurrency(scommissioncount))
				THEN
				
					s.say(cwhere || '|vCommCurrency = any');
					vdebitdirection  := cdvdebit;
					vcreditdirection := cdvcredit;
				
				ELSIF (vcommcurrency != sacommissioncreditcurrency(scommissioncount) AND
					  vcommcurrency != sacommissioncurrency(scommissioncount))
				THEN
					s.say(cwhere || '|vCommCurrency != any');
					vdebitdirection  := cdvdebit;
					vcreditdirection := cdvcredit;
				ELSE
					s.say(cwhere || '|vCommCurrency ?');
				END IF;
			
				s.say(cwhere || '|vDebitDirection  = ' || vdebitdirection);
				s.say(cwhere || '|vCreditDirection = ' || vcreditdirection);
			
				IF calc(vcommissionrow
					   ,pvalue
					   ,vcurrency
					   ,sacommissionvalue(scommissioncount)
					   ,sacommissioncurrency(scommissioncount)
					   ,sacommissioncreditvalue(scommissioncount)
					   ,sacommissioncreditcurrency(scommissioncount)
					   ,pdate
					   ,vdebitdirection
					   ,vcreditdirection) != 0
				THEN
					RETURN;
				END IF;
			
			END IF;
		
			IF ((vdebitignore AND vcreditignore) OR sacommissionvalue(scommissioncount) = 0 OR
			   sacommissioncreditvalue(scommissioncount) = 0)
			THEN
				sacommissionvalue(scommissioncount) := 0;
				sacommissioncreditvalue(scommissioncount) := 0;
				scommissioncount := scommissioncount - 1;
			END IF;
		
		END LOOP;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cwhere);
			RAISE;
		
	END;

	PROCEDURE deletecommission IS
		vret    NUMBER;
		vbranch NUMBER := seance.getbranch;
	BEGIN
		SAVEPOINT referencecommissiondelete;
	
		DELETE FROM treferencecommission
		WHERE  branch = vbranch
		AND    commission = scommissionrow.commission;
	
		DELETE FROM tcommission
		WHERE  branch = vbranch
		AND    commission = scommissionrow.commission;
	
		vret := custom_datamember.datamemberdelete(object_type
												  ,scommissionrow.commission
												  ,'INTERVAL');
	
		logparam('Name', scommissionadd.name, TRUE);
		logparam('Debit', scommissionadd.debit);
		logparam('DebitLink', scommissionadd.debitlink);
		logparam('Credit', scommissionadd.credit);
		logparam('CreditLink', scommissionadd.creditlink);
		logparam('Method', scommissionadd.method);
		logparam('EntIdent', scommissionadd.entident);
		logparam('Description', scommissionadd.description);
		logparam('Stat', scommissionadd.stat);
		logparam('Currency', scommissionadd.currency);
		logparam('Exchange', scommissionadd.exchange);
		log(scommissionrow.commission
		   ,'Delete fee ' || scommissionrow.name || ', Debit: ' || scommissionrow.debit ||
			', DebitLink: ' || scommissionrow.debitlink || ', Credit: ' || scommissionrow.credit ||
			', CreditLink: ' || scommissionrow.creditlink || ', Method: ' || scommissionrow.method ||
			', EntIdent: ' || scommissionrow.entident || ', Description: ' ||
			scommissionrow.description || ', Stat: ' || scommissionrow.stat || ', Currency: ' ||
			scommissionrow.currency || ', Exchange: ' || scommissionrow.exchange
		   ,a4mlog.act_del);
		COMMIT;
		err.seterror(0, cpackagename || '.DeleteCommission');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.DeleteCommission');
			ROLLBACK TO referencecommissiondelete;
	END;

	PROCEDURE dynasetopen IS
	
		vsql       VARCHAR2(4000);
		vsortmode  typesortmode;
		vorderdesc BOOLEAN;
	
		vbranch NUMBER := seance.getbranch;
	BEGIN
	
		vsql := 'from tReferenceCommission where Branch = ' || to_char(vbranch);
	
		vsortmode := nvl(getdata(cpvvsortmode), csmcode);
	
		IF vsortmode = csmcode
		THEN
			vsql := vsql || ' order by Commission';
		ELSE
			vsql := vsql || ' order by Name';
		END IF;
	
		vorderdesc := htools.i2b(getdata(cpvvorderdesc));
	
		IF vorderdesc
		THEN
			vsql := vsql || ' desc';
		END IF;
	
		sdshandle := dynaset.open(vsql);
	END;

	PROCEDURE fillaccountlist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	) IS
	BEGIN
		dialog.listaddrecord(pdialog, pitemname, cvaluestr_debit || '~', dialog.cmconfirm, 0);
		dialog.listaddrecord(pdialog, pitemname, cvaluestr_credit || '~', dialog.cmconfirm, 0);
	END;

	PROCEDURE fillexchangelist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	) IS
		vbranch NUMBER := seance.getbranch;
		CURSOR c1 IS
			SELECT exchangeid
				  ,exchangename
			FROM   treferenceexchange
			WHERE  branch = vbranch
			ORDER  BY exchangeid;
	BEGIN
		dialog.listaddrecord(pdialog, pitemname, '~~', dialog.cmconfirm, 0);
		FOR i IN c1
		LOOP
			dialog.listaddrecord(pdialog
								,pitemname
								,to_char(i.exchangeid) || '~' || substr(i.exchangename, 1, 40) || '~'
								,dialog.cmconfirm
								,0);
		END LOOP;
	END;

	PROCEDURE fillintervalarray(pcommission IN NUMBER) IS
		vinterval NUMBER;
		vstring   VARCHAR(250);
	BEGIN
		sintreccount := 0;
		LOOP
			vinterval := custom_datamember.getintervalnext(object_type
														  ,pcommission
														  ,'INTERVAL'
														  ,vinterval);
			EXIT WHEN vinterval IS NULL;
			vstring := custom_datamember.getintervalchar(object_type
														,pcommission
														,'INTERVAL'
														,vinterval);
			sintreccount := sintreccount + 1;
			saintint(sintreccount) := vinterval;
			saintval(sintreccount) := getparm(vstring, 1);
			saintprc(sintreccount) := getparm(vstring, 2);
			saintmin(sintreccount) := getparm(vstring, 3);
			saintmax(sintreccount) := getparm(vstring, 4);
		END LOOP;
		err.seterror(0, cpackagename || '.FillIntervalArray');
	END;

	PROCEDURE filllinklist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	) IS
		vbranch NUMBER := seance.getbranch;
		CURSOR c1 IS
			SELECT DISTINCT link FROM tplan2plan WHERE branch = vbranch ORDER BY link;
	BEGIN
		dialog.listaddrecord(pdialog, pitemname, '~', dialog.cmconfirm, 0);
		FOR i IN c1
		LOOP
			dialog.listaddrecord(pdialog, pitemname, i.link || '~', dialog.cmconfirm, 0);
		END LOOP;
	END;

	PROCEDURE fillmethodlist
	(
		pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	) IS
	BEGIN
		FOR i IN 1 .. smethodcount
		LOOP
			dialog.listaddrecord(pdialog
								,pitemname
								,samethodname(i) || '~' || samethod(i) || '~'
								,dialog.cmconfirm
								,0);
		END LOOP;
	END;

	FUNCTION getfreecommission RETURN NUMBER IS
		vcommission NUMBER;
	BEGIN
		SELECT seq_referencecommission.nextval INTO vcommission FROM dual;
		RETURN vcommission;
	END;

	FUNCTION getparm
	(
		pstring IN VARCHAR
	   ,pno     IN NUMBER
	) RETURN NUMBER IS
		vbeg NUMBER;
		vend NUMBER;
	BEGIN
		vbeg := instr(pstring, '|', 1, pno);
		vend := instr(pstring, '|', 1, pno + 1);
		IF vbeg IS NULL
		   OR vend IS NULL
		THEN
			RETURN NULL;
		END IF;
		RETURN substr(pstring, vbeg + 1, vend - vbeg - 1);
	END;

	FUNCTION getrightkey(paction IN VARCHAR) RETURN VARCHAR IS
	BEGIN
		RETURN '|' || paction || '|';
	END;

	PROCEDURE savedataint(pdialog IN NUMBER) IS
		vret NUMBER;
	BEGIN
		IF nvl(dialog.getnumber(pdialog, 'Currency'), seance.getcurrency) != seance.getcurrency
		   AND dialog.getnumber(pdialog, 'Exchange') IS NULL
		THEN
			dialog.sethothint(pdialog, 'Error: Field not defined');
			dialog.goitem(pdialog, 'ExchangeName');
			RETURN;
		END IF;
	
		scommissionadd.currency := dialog.getnumber(pdialog, 'Currency');
		scommissionadd.exchange := dialog.getnumber(pdialog, 'Exchange');
	
		scommissionrow.currency := scommissionadd.currency;
		scommissionrow.exchange := scommissionadd.exchange;
	
		vret := custom_datamember.datamemberdelete(object_type
												  ,dialog.getnumber(pdialog, 'Commission')
												  ,'INTERVAL');
		FOR i IN 1 .. sintreccount
		LOOP
			vret := custom_datamember.setintervalchar(object_type
													 ,dialog.getnumber(pdialog, 'Commission')
													 ,'INTERVAL'
													 ,saintint(i)
													 ,'|' || saintval(i) || '|' || saintprc(i) || '|' ||
													  saintmin(i) || '|' || saintmax(i) || '|'
													 ,NULL);
		END LOOP;
	END;

	FUNCTION getrow(pcommission IN NUMBER) RETURN treferencecommission%ROWTYPE IS
		vrow    treferencecommission%ROWTYPE;
		vbranch NUMBER := seance.getbranch;
	BEGIN
		SELECT *
		INTO   vrow
		FROM   treferencecommission
		WHERE  branch = vbranch
		AND    commission = pcommission;
		RETURN vrow;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetRow [' || pcommission || ']');
			RETURN NULL;
	END;

	PROCEDURE log
	(
		pcommission IN NUMBER
	   ,ptext       IN VARCHAR
	   ,paction     IN NUMBER
	) IS
	BEGIN
		IF a4mlog.logobject(object_type
						   ,pcommission
						   ,substr(ptext, 1, 250)
						   ,paction
						   ,a4mlog.putparamlist) != 0
		THEN
			error.raiseerror(error.errorconst, 'Error writing to log:~' || err.getfullmessage);
		END IF;
		a4mlog.cleanplist;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.Log');
			RAISE;
	END;

	PROCEDURE logparam
	(
		pparam     IN VARCHAR
	   ,pvalue     IN VARCHAR
	   ,pclearlist IN BOOLEAN
	) IS
	BEGIN
		IF pclearlist
		THEN
			a4mlog.cleanplist;
		END IF;
		a4mlog.addparamrec(pparam, pvalue);
	END;

	FUNCTION exist(pcommission IN NUMBER) RETURN BOOLEAN IS
		vbranch NUMBER := seance.getbranch;
	BEGIN
		FOR i IN (SELECT branch
				  FROM   treferencecommission
				  WHERE  branch = vbranch
				  AND    commission = pcommission)
		LOOP
			RETURN TRUE;
		END LOOP;
		RETURN FALSE;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.Exist');
			RETURN FALSE;
	END;

	FUNCTION dialogparamview RETURN NUMBER IS
		cwhere CONSTANT VARCHAR2(100) := cpackagename || '.DialogParamView';
		vdialog NUMBER;
	
		PROCEDURE fillsortmodelist(pitemname IN VARCHAR) IS
		BEGIN
			dialog.listclear(vdialog, pitemname);
		
			dialog.listaddrecord(vdialog, pitemname, csmcode || '~' || 'Code' || '~', 0, 0);
			dialog.listaddrecord(vdialog, pitemname, csmname || '~' || 'Name' || '~', 0, 0);
		END;
	
	BEGIN
		vdialog := dialog.new('Viewing parameters', 0, 0, 50, 10, pextid => cwhere);
		dialog.setdialogpre(vdialog, cpackagename || '.DialogParamViewProc');
		dialog.setdialogvalid(vdialog, cpackagename || '.DialogParamViewProc');
	
		dialog.inputinteger(vdialog, 'SortMode', 15, 2, '', 30, 'Sorting:');
		dialog.listaddfield(vdialog, 'SortMode', 'Code', 'N', 1, 0);
		dialog.listaddfield(vdialog, 'SortMode', 'Name', 'C', 15, 1);
		dialog.setitempre(vdialog, 'SortMode', cpackagename || '.DialogParamViewProc');
	
		dialog.inputcheck(vdialog, 'OrderDesc', 15, 4, 35, 'Sort in reverse order');
	
		dialog.button(vdialog, 'Save', 13, 6, 11, 'Enter', dialog.cmok, 0, 'Save changes');
		dialog.setitemattributies(vdialog, 'Save', dialog.defaulton);
		dialog.button(vdialog, 'Cancel', 26, 6, 11, 'Cancel', dialog.cmcancel, 0, 'Cancel changes');
	
		fillsortmodelist('SortMode');
	
		RETURN vdialog;
	END;

	PROCEDURE dialogparamviewproc
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN VARCHAR
	   ,pcmd      IN NUMBER
	) IS
		vret NUMBER;
	BEGIN
		IF pwhat = dialog.wtdialogpre
		THEN
			dialog.setcurrecbyvalue(pdialog
								   ,'SortMode'
								   ,'Code'
								   ,nvl(getdata(cpvvsortmode), csmcode));
			dialog.putbool(pdialog, 'OrderDesc', htools.i2b(nvl(getdata(cpvvorderdesc), 0)));
		
		ELSIF pwhat = dialog.wtdialogvalid
		THEN
			putdata(cpvvsortmode, dialog.getcurrentrecordnumber(pdialog, 'SortMode', 'Code'));
			putdata(cpvvorderdesc, htools.b2i(dialog.getbool(pdialog, 'OrderDesc')));
		
			COMMIT;
		END IF;
	END;

	FUNCTION getdata(pident IN VARCHAR) RETURN NUMBER IS
		vret    NUMBER;
		vbranch NUMBER := seance.getbranch;
	BEGIN
		vret := custom_datamember.getnumber(object_type, vbranch, pident);
		RETURN vret;
	END;

	PROCEDURE putdata
	(
		pident IN VARCHAR
	   ,pvalue IN NUMBER
	) IS
		vret    NUMBER;
		vbranch NUMBER := seance.getbranch;
	BEGIN
		vret := custom_datamember.setnumber(object_type, vbranch, pident, pvalue, NULL);
	END;

	FUNCTION getcommissionrecord(pcommission IN NUMBER) RETURN custom_api_type.typecommissionrecord IS
		vcommissionrow    treferencecommission%ROWTYPE;
		vcommissionrecord custom_api_type.typecommissionrecord;
	BEGIN
		vcommissionrow := getrow(pcommission);
	
		vcommissionrecord.commission  := vcommissionrow.commission;
		vcommissionrecord.name        := vcommissionrow.name;
		vcommissionrecord.debit       := vcommissionrow.debit;
		vcommissionrecord.debitlink   := vcommissionrow.debitlink;
		vcommissionrecord.credit      := vcommissionrow.credit;
		vcommissionrecord.creditlink  := vcommissionrow.creditlink;
		vcommissionrecord.method      := vcommissionrow.method;
		vcommissionrecord.entident    := vcommissionrow.entident;
		vcommissionrecord.description := vcommissionrow.description;
		vcommissionrecord.stat        := vcommissionrow.stat;
		vcommissionrecord.currency    := vcommissionrow.currency;
		vcommissionrecord.exchange    := vcommissionrow.exchange;
	
		RETURN vcommissionrecord;
	
	EXCEPTION
		WHEN no_data_found THEN
			error.save(cpackagename || '.GetCommissionRecord', err.refcomm_data_not_defined);
			RETURN NULL;
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetCommissionRecord');
			RETURN NULL;
	END;

	FUNCTION getcommissiondatalist(pcommission IN NUMBER) RETURN custom_api_type.typecommissiondatalist IS
		vindex              NUMBER;
		vinterval           NUMBER;
		vstring             VARCHAR(250);
		vcommissiondatalist custom_api_type.typecommissiondatalist;
	BEGIN
		vindex := 0;
	
		LOOP
			vinterval := custom_datamember.getintervalnext(object_type
														  ,pcommission
														  ,'INTERVAL'
														  ,vinterval);
		
			vstring := custom_datamember.getintervalchar(object_type
														,pcommission
														,'INTERVAL'
														,vinterval);
		
			vindex := vindex + 1;
		
			vcommissiondatalist(vindex).interval := vinterval;
			vcommissiondatalist(vindex).amount := getparm(vstring, 1);
			vcommissiondatalist(vindex).prc := getparm(vstring, 2);
			vcommissiondatalist(vindex).minamount := getparm(vstring, 3);
			vcommissiondatalist(vindex).maxamount := getparm(vstring, 4);
			EXIT WHEN vinterval IS NULL;
		END LOOP;
	
		RETURN vcommissiondatalist;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.GetCommissionDataList');
			vcommissiondatalist.delete();
			RETURN vcommissiondatalist;
	END;

	FUNCTION getdbcrvaluebystr(pvaluestr IN VARCHAR) RETURN VARCHAR IS
		vvalue VARCHAR(20) := NULL;
	BEGIN
		IF pvaluestr = cvaluestr_debit
		THEN
			vvalue := debit_account;
		ELSIF pvaluestr = cvaluestr_credit
		THEN
			vvalue := credit_account;
		END IF;
		RETURN vvalue;
	END;

	FUNCTION getdbcrstrbyvalue(pvalue IN VARCHAR) RETURN VARCHAR IS
		vvaluestr VARCHAR(20) := NULL;
	BEGIN
		IF pvalue IN (debit_account, cvaluestr_debit)
		THEN
			vvaluestr := cvaluestr_debit;
		ELSIF pvalue IN (credit_account, cvaluestr_credit)
		THEN
			vvaluestr := cvaluestr_credit;
		END IF;
		s.say('GetDbCrStrByValue: vValueStr=' || vvaluestr);
		RETURN vvaluestr;
	END;

BEGIN

	smethodcount := 1;
	samethod(1) := method_interval;
	samethodname(1) := 'Interval-based';
	object_type := custom_object.gettype(object_name);
	dbms_output.put_line('object_type:' || object_type);
END;
/
