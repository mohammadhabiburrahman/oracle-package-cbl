CREATE OR REPLACE PACKAGE custom_finaccountinstance IS

	crevision CONSTANT VARCHAR2(100) := '$Rev: 44809 $';

	FUNCTION getversion RETURN VARCHAR2;

	PROCEDURE makepage
	(
		ppage       NUMBER
	   ,pwidth      NUMBER
	   ,pheight     NUMBER
	   ,pobjectname VARCHAR := NULL
	   ,pkey        VARCHAR := NULL
	);
	PROCEDURE loadpage
	(
		ppage      NUMBER
	   ,pprofile   NUMBER
	   ,paccountno VARCHAR
	);
	PROCEDURE savepage
	(
		ppage      NUMBER
	   ,paccountno VARCHAR
	);
	FUNCTION getpageprofile(ppage NUMBER) RETURN NUMBER;
	PROCEDURE enablepage
	(
		ppage   NUMBER
	   ,penable BOOLEAN
	);

	PROCEDURE copyfinprofile
	(
		paccountno    VARCHAR
	   ,pnewaccountno VARCHAR
	);
	PROCEDURE fillsecurityarray;
	FUNCTION getsecurityarray RETURN custom_security.typerights;
	PROCEDURE getfinprofile
	(
		paccountno VARCHAR
	   ,pprofile   OUT NUMBER
	   ,pinstance  OUT NUMBER
	);
	PROCEDURE deleteinstance(paccountno VARCHAR);
	PROCEDURE putinstance
	(
		pinstance  NUMBER
	   ,pprofile   NUMBER
	   ,paccountno VARCHAR
	);

	FUNCTION getinstancecommissions(paccountno VARCHAR) RETURN types.arrnum;
	FUNCTION getinstancepayments(paccountno VARCHAR) RETURN types.arrnum;

END;
/
CREATE OR REPLACE PACKAGE BODY custom_finaccountinstance IS

	cpackagename CONSTANT VARCHAR(30) := 'FinAccountInstance';
	co_ident     CONSTANT VARCHAR(32) := 'FinAccountInstance';

	cbodyrevision CONSTANT VARCHAR2(100) := '$Rev: 44809 $';

	sbranch NUMBER;

	FUNCTION getprofile(paccountno VARCHAR) RETURN NUMBER;
	FUNCTION getinstance(paccountno VARCHAR) RETURN NUMBER;

	FUNCTION getversion RETURN VARCHAR2 IS
	BEGIN
		RETURN service.formatpackageversion(cpackagename, crevision, cbodyrevision);
	END;

	PROCEDURE copyfinprofile
	(
		paccountno    VARCHAR
	   ,pnewaccountno VARCHAR
	) IS
		vinstance NUMBER;
	BEGIN
		SAVEPOINT sp_accountcopyfinprofile;
		IF paccountno = pnewaccountno
		THEN
			error.raiseuser('Attempt to copy account with himself!');
		END IF;
		vinstance := getinstance(pnewaccountno);
		IF vinstance IS NOT NULL
		THEN
			fininstance.deletedata(vinstance);
		END IF;
		vinstance := fininstance.copydata(getinstance(paccountno)
										 ,TRUE
										 ,account.object_type
										 ,pnewaccountno
										 ,account.getidclientbyaccno(paccountno));
		IF vinstance IS NOT NULL
		THEN
			putinstance(vinstance, fininstance.getinstanceprofile(vinstance), pnewaccountno);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cpackagename || '.CopyFinProfile, ' || paccountno || ', ' || pnewaccountno);
			err.seterror(SQLCODE, cpackagename || '.CopyFinProfile');
			ROLLBACK TO sp_accountcopyfinprofile;
	END;

	FUNCTION getpageprofile(ppage NUMBER) RETURN NUMBER IS
	BEGIN
		RETURN fininstance.getpageprofile(ppage, co_ident);
	END;

	PROCEDURE makepage
	(
		ppage       NUMBER
	   ,pwidth      NUMBER
	   ,pheight     NUMBER
	   ,pobjectname VARCHAR
	   ,pkey        VARCHAR
	) IS
	BEGIN
		fininstance.makepage(ppage, co_ident, pwidth, pheight, finprofile.co_account, TRUE);
		IF pobjectname IS NOT NULL
		THEN
			fininstance.setsecuritykey(ppage, co_ident, pobjectname, pkey);
		END IF;
	END;

	PROCEDURE loadpage
	(
		ppage      NUMBER
	   ,pprofile   NUMBER
	   ,paccountno VARCHAR
	) IS
	BEGIN
		fininstance.loadpage(ppage
							,co_ident
							,pprofile
							,getinstance(paccountno)
							,account.getaccountrecord(paccountno).accounttype);
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cpackagename || '.LoadPage, ' || ppage || ', ' || pprofile || ', ' || paccountno);
			error.save(cpackagename || '.LoadPage');
			error.showerror;
	END;

	PROCEDURE savepage
	(
		ppage      NUMBER
	   ,paccountno VARCHAR
	) IS
		vinstance NUMBER;
		vprofile  NUMBER;
	BEGIN
		SAVEPOINT sp_accountsavepage;
		err.seterror(0, cpackagename || '.SavePage');
		fininstance.setlogkey(ppage
							 ,co_ident
							 ,account.object_name
							 ,paccountno
							 ,account.getidclientbyaccno(paccountno));
		vprofile  := fininstance.getpageprofile(ppage, co_ident);
		vinstance := fininstance.savepage(ppage, co_ident, vprofile, getinstance(paccountno));
		putinstance(vinstance, vprofile, paccountno);
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cpackagename || '.SavePage, ' || ppage || ', ' || paccountno);
			err.seterror(SQLCODE, cpackagename || '.SavePage');
			ROLLBACK TO sp_accountsavepage;
	END;

	PROCEDURE getfinprofile
	(
		paccountno VARCHAR
	   ,pprofile   OUT NUMBER
	   ,pinstance  OUT NUMBER
	) IS
	BEGIN
		pprofile  := getprofile(paccountno);
		pinstance := getinstance(paccountno);
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cpackagename || '.GetFinProfile: ' || paccountno);
			err.seterror(SQLCODE, cpackagename || '.GetFinProfile');
	END;

	PROCEDURE enablepage
	(
		ppage   NUMBER
	   ,penable BOOLEAN
	) IS
	BEGIN
		fininstance.enablepage(ppage, co_ident, penable, FALSE);
	END;

	PROCEDURE deleteinstance(paccountno VARCHAR) IS
		vinstance NUMBER;
	BEGIN
		vinstance := getinstance(paccountno);
		IF vinstance IS NOT NULL
		THEN
			custom_fininstance.deletedata(vinstance);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cpackagename || '.DeleteInstance: ' || paccountno);
			err.seterror(SQLCODE, cpackagename || '.DeleteInstance');
	END;

	FUNCTION getsecurityarray RETURN custom_security.typerights IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetSecurityArray';
	BEGIN
		RETURN custom_fininstance.getsecurityarray;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE fillsecurityarray IS
	BEGIN
		fininstance.fillsecurityarray();
	END;

	FUNCTION getprofile(paccountno VARCHAR) RETURN NUMBER IS
		vprofile NUMBER;
	BEGIN
		SELECT finprofile
		INTO   vprofile
		FROM   taccount
		WHERE  branch = sbranch
		AND    accountno = paccountno;
		RETURN vprofile;
	EXCEPTION
		WHEN no_data_found THEN
			RETURN NULL;
		WHEN OTHERS THEN
			s.err(cpackagename || '.GetProfile: ' || paccountno);
			RAISE;
	END;

	FUNCTION getinstance(paccountno VARCHAR) RETURN NUMBER IS
		vinstance NUMBER;
	BEGIN
		SELECT instance
		INTO   vinstance
		FROM   tfininstance
		WHERE  branchaccount = sbranch
		AND    accountno = paccountno;
		RETURN vinstance;
	EXCEPTION
		WHEN no_data_found THEN
			RETURN NULL;
		WHEN OTHERS THEN
			s.err(cpackagename || '.GetInstance: ' || paccountno);
			RAISE;
	END;

	PROCEDURE putinstance
	(
		pinstance  NUMBER
	   ,pprofile   NUMBER
	   ,paccountno VARCHAR
	) IS
	BEGIN
		IF paccountno IS NULL
		THEN
			error.raiseuser('Attempt to save instance for empty AccountNo!');
		END IF;
	
		UPDATE tfininstance
		SET    accountno     = paccountno
			  ,profile       = pprofile
			  ,branchaccount = sbranch
		WHERE  branch = sbranch
		AND    instance = pinstance;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cpackagename || '.PutInstance: ' || pinstance || ', ' || paccountno || ',' ||
				  pprofile);
			RAISE;
	END;

	FUNCTION getinstancecommissions(paccountno VARCHAR) RETURN types.arrnum IS
		vacommissions types.arrnum;
		vinstance     NUMBER;
	BEGIN
		vinstance := getinstance(paccountno);
		IF vinstance IS NOT NULL
		THEN
			vacommissions := fininstancecommissiondata.getinstancecommissions(vinstance);
		END IF;
		RETURN vacommissions;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cpackagename || '.GetInstanceCommissions: ' || paccountno);
			RAISE;
	END;

	FUNCTION getinstancepayments(paccountno VARCHAR) RETURN types.arrnum IS
		vapayments types.arrnum;
		vinstance  NUMBER;
	BEGIN
		vinstance := getinstance(paccountno);
		IF vinstance IS NOT NULL
		THEN
			vapayments := fininstancepayment.getinstancepayments(vinstance);
		END IF;
		RETURN vapayments;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cpackagename || '.GetInstancePayments: ' || paccountno);
			RAISE;
	END;

BEGIN
	sbranch := seance.getbranch();
END;
/
