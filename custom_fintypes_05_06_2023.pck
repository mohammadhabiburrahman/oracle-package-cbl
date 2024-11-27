CREATE OR REPLACE PACKAGE custom_fintypes AS

	cpackagedescr CONSTANT VARCHAR2(1000) := 'Package with declarations for financial schemes and contracts core';

	cheaderversion CONSTANT VARCHAR2(50) := '22.01.01';

	cheaderdate CONSTANT DATE := to_date('25.11.2022', 'DD.MM.YYYY');

	cheadertwcms CONSTANT VARCHAR2(50) := '4.15.87';

	cheaderrevision CONSTANT VARCHAR2(100) := '$Rev: 62324 $';

	SUBTYPE typeitemname IS VARCHAR2(50);

	SUBTYPE typepackagename IS tcontractschemas.packagename%TYPE;
	SUBTYPE typecontracttype IS tcontract.type%TYPE;
	SUBTYPE typecontractno IS tcontract.no%TYPE;

	SUBTYPE typeaccitemname IS tcontracttypeitemname.itemname%TYPE;
	SUBTYPE typeaccountno IS taccount.accountno%TYPE;

	SUBTYPE typeschemarow IS tcontractschemas%ROWTYPE;
	SUBTYPE typecontractrow IS tcontract%ROWTYPE;

	TYPE typecontractrowarray IS TABLE OF typecontractrow INDEX BY PLS_INTEGER;

	TYPE typedialogitem IS RECORD(
		 packagename  typepackagename
		,objectname   VARCHAR2(30)
		,itemname     typeitemname
		,textname     VARCHAR2(200)
		,objecttype   NUMBER
		,objectno     VARCHAR2(200)
		,customparams VARCHAR2(1000)
		,allowempty   BOOLEAN
		,emptycaption VARCHAR2(200)
		,valuefield   VARCHAR2(30)
		,currentvalue VARCHAR2(100)
		,command      NUMBER);

	TYPE typeitemdescription IS RECORD(
		 itemname    typeitemname
		,description VARCHAR2(100));
	TYPE typeitemdescriptionarray IS TABLE OF typeitemdescription INDEX BY PLS_INTEGER;

	TYPE typecontracttyperecord IS RECORD(
		 TYPE          NUMBER
		,NAME          tcontracttype.name%TYPE
		,accessory     NUMBER
		,sortorder     tcontracttype.sortorder%TYPE
		,favorite      PLS_INTEGER
		,status        tcontracttype.status%TYPE
		,ident         tcontracttype.ident%TYPE
		,startdate     DATE
		,enddate       DATE
		,schematype    NUMBER
		,schemapackage tcontractschemas.packagename%TYPE
		,
		
		isselected  NUMBER
		,description VARCHAR2(400)
		
		);
	TYPE typecontracttypelist IS TABLE OF typecontracttyperecord INDEX BY BINARY_INTEGER;

	TYPE typepackageinfo IS RECORD(
		 packagename typepackagename
		,
		
		packagedescr VARCHAR2(1000)
		,
		
		headerversion  VARCHAR2(50)
		,headerdate     DATE
		,headertwcms    VARCHAR2(50)
		,headerrevision VARCHAR2(100)
		,headercsm      VARCHAR2(100)
		,
		
		bodyversion  VARCHAR2(10)
		,bodydate     DATE
		,bodytwcms    VARCHAR2(50)
		,bodyrevision VARCHAR2(100)
		,bodycsm      VARCHAR2(100));

	cfld_id CONSTANT VARCHAR2(10) := upper('ItemID');

	cnotusedcaption CONSTANT VARCHAR2(10) := '#NOT_USED';

	FUNCTION getversion RETURN VARCHAR2;

	FUNCTION getpackageinfo RETURN custom_fintypes.typepackageinfo;

END custom_fintypes;
/
CREATE OR REPLACE PACKAGE BODY custom_fintypes AS

	cpackage_name CONSTANT VARCHAR2(100) := 'FinTypes';

	cbodyversion CONSTANT VARCHAR2(10) := '22.00.00';

	cbodydate CONSTANT DATE := to_date('07.10.2022', 'DD.MM.YYYY');

	cbodytwcms CONSTANT VARCHAR2(50) := '4.15.87';

	cbodyrevision CONSTANT VARCHAR2(100) := '$Rev: 61832 $';

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

BEGIN
	custom_contracttools.saypackageinfo(getpackageinfo);
END custom_fintypes;
/
