CREATE OR REPLACE PACKAGE custom_contractexchangetools IS

	crevision CONSTANT VARCHAR2(100) := '$Rev: 61218 $';

	cdateformat  CONSTANT VARCHAR2(10) := 'dd.mm.yyyy';
	cdsblockstag CONSTANT VARCHAR2(100) := 'DYNASQLBLOCKS';

	SUBTYPE typelogtype IS PLS_INTEGER;
	clogtype_msg     CONSTANT typelogtype := 0;
	clogtype_warning CONSTANT typelogtype := 1;
	clogtype_error   CONSTANT typelogtype := 2;

	SUBTYPE typeimportmode IS PLS_INTEGER;
	cimportmode_stop CONSTANT typeimportmode := 1;
	cimportmode_skip CONSTANT typeimportmode := 2;
	cimportmode_over CONSTANT typeimportmode := 3;
	cimportmode_auto CONSTANT typeimportmode := cimportmode_skip;

	SUBTYPE typepackagename IS VARCHAR2(200);
	SUBTYPE typeparamobjecttype IS tcontractotherobjecttype.objectsign%TYPE;

	TYPE typecolumnrec IS RECORD(
		 column_name VARCHAR2(128)
		,data_type   VARCHAR2(106));
	TYPE typecolumnarray IS TABLE OF typecolumnrec INDEX BY BINARY_INTEGER;
	cemptycolumnarray typecolumnarray;

	eximportstop EXCEPTION;
	PRAGMA EXCEPTION_INIT(eximportstop, -20001);

	SUBTYPE typeaccountaccessory IS PLS_INTEGER;
	cintrabankaccount typeaccountaccessory := 1;
	cpersonaccount    typeaccountaccessory := 2;
	ccorporateaccount typeaccountaccessory := 3;

	--SUBTYPE typesrccode IS tcontractimportmatching.sourcecode%TYPE;
	SUBTYPE typesrccode IS NUMBER;
	--SUBTYPE typedestcode IS tcontractimportmatching.destcode%TYPE;
	--SUBTYPE typetablename IS tcontractimportmatching.tablename%TYPE;
	SUBTYPE typedestcode IS NUMBER;
	SUBTYPE typetablename IS VARCHAR2(200);

	TYPE typeexportaddsettingsrecord IS RECORD(
		 objectname           VARCHAR2(100)
		,dynasqlblockcolumns  types.arrstr100
		,parametersobjecttype typeparamobjecttype);
	TYPE typeexportadditionalsettings IS TABLE OF typeexportaddsettingsrecord INDEX BY VARCHAR2(1000);

	TYPE typeexportsettings IS RECORD(
		 referencename      VARCHAR2(1000)
		,packagename        typepackagename
		,tablename          VARCHAR2(1000)
		,objectname         VARCHAR2(100)
		,whereclause        CLOB
		,orderclause        VARCHAR2(1000)
		,codecolumn         VARCHAR2(100)
		,identcolumn        VARCHAR2(100)
		,namecolumn         VARCHAR2(100)
		,exportchilds       BOOLEAN := FALSE
		,childtablelist     VARCHAR2(1000)
		,additionalsettings typeexportadditionalsettings);

	TYPE typeaddsettingsrecord IS RECORD(
		 codecolumn   VARCHAR2(100)
		,sequencename VARCHAR2(100)
		,objectname   VARCHAR2(100)
		,
		
		dynasqlblockcolumns  types.arrstr100
		,parametersobjecttype typeparamobjecttype);

	TYPE typeadditionalsettings IS TABLE OF typeaddsettingsrecord INDEX BY VARCHAR2(1000);
	TYPE typeimportsettings IS RECORD(
		 referencename      VARCHAR2(1000)
		,packagename        typepackagename
		,tablename          VARCHAR2(1000)
		,objectname         VARCHAR2(100)
		,codecolumn         VARCHAR2(100)
		,identcolumn        VARCHAR2(100)
		,importmode         typeimportmode := cimportmode_auto
		,refcodecolumn      VARCHAR2(100)
		,additionalsettings typeadditionalsettings
		,
		
		importchilds      BOOLEAN := TRUE
		,dopreparatorywork BOOLEAN := TRUE);

	SUBTYPE typeactiontype IS PLS_INTEGER;
	cacttype_unknown          CONSTANT typeactiontype := 0;
	cacttype_stop             CONSTANT typeactiontype := 1;
	cacttype_notexists_add    CONSTANT typeactiontype := 2;
	cacttype_mtexists_skip    CONSTANT typeactiontype := 3;
	cacttype_locexists_skip   CONSTANT typeactiontype := 4;
	cacttype_mtexists_update  CONSTANT typeactiontype := 5;
	cacttype_locexists_update CONSTANT typeactiontype := 6;
	cacttype_matching         CONSTANT typeactiontype := 7;
	cacttype_skipbyerror      CONSTANT typeactiontype := 8;

	FUNCTION getversion RETURN VARCHAR2;

	PROCEDURE sayxml
	(
		pxml          xmltype
	   ,pdescription  VARCHAR2 := NULL
	   ,plength2debug NUMBER := NULL
	);

	PROCEDURE clearlog;

	PROCEDURE log
	(
		plogtype     typelogtype
	   ,ppackagename VARCHAR2
	   ,pobjectname  VARCHAR2
	   ,psourcecode  VARCHAR2
	   ,pactiontype  typeactiontype := NULL
	   ,pmessage     VARCHAR2 := NULL
	);

	PROCEDURE logevent
	(
		pobjectname VARCHAR2
	   ,pkey        VARCHAR2
	   ,paction     IN NUMBER
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,pfilename   VARCHAR2
	);

	PROCEDURE addmatchingrow
	(
		ppackagename VARCHAR2
	   ,ptablename   VARCHAR2
	   ,pcolumnname  VARCHAR2
	   ,psourcecode  typesrccode
	   ,pdestcode    typedestcode
	);

	PROCEDURE deletematchingrows
	(
		ppackagename VARCHAR2 := NULL
	   ,ptablename   VARCHAR2 := NULL
	   ,pcolumnname  VARCHAR2 := NULL
	   ,psourcecode  typesrccode := NULL
	   ,pdestcode    typedestcode := NULL
	);

	FUNCTION getdestcode
	(
		ptablename   VARCHAR2
	   ,pcolumnname  VARCHAR2
	   ,psourcecode  typesrccode
	   ,ppackagename VARCHAR2 := NULL
	) RETURN typedestcode;

	FUNCTION export2xml
	(
		ppackagename VARCHAR2
	   ,ptablename   VARCHAR2
	   ,pobjectname  VARCHAR2 := NULL
	   ,pwhere       VARCHAR2 := NULL
	   ,porder       VARCHAR2 := NULL
	) RETURN xmltype;
	FUNCTION export2xml
	(
		psettings   typeexportsettings
	   ,puseroottag BOOLEAN := TRUE
	   ,pcount      NUMBER := NULL
	) RETURN xmltype;

	PROCEDURE importfromxml
	(
		pxml             xmltype
	   ,psettings        typeimportsettings
	   ,psaverecord      BOOLEAN := TRUE
	   ,pclearlog        BOOLEAN := TRUE
	   ,pshowprogressbar BOOLEAN := FALSE
	);
	PROCEDURE importfromxml
	(
		pxml             xmltype
	   ,psettings        typeimportsettings
	   ,psaverecord      BOOLEAN := TRUE
	   ,pclearlog        BOOLEAN := TRUE
	   ,pshowprogressbar BOOLEAN := FALSE
	   ,ocontinue        OUT BOOLEAN
	);

	PROCEDURE importparams
	(
		pxml             xmltype
	   ,psettings        typeimportsettings
	   ,pparamobjecttype typeparamobjecttype := NULL
	   ,psaverecord      BOOLEAN := TRUE
	);

	FUNCTION loadfromfile
	(
		ppath        IN VARCHAR2
	   ,pencode      IN VARCHAR2
	   ,pinteractive IN BOOLEAN := TRUE
	) RETURN xmltype;
	PROCEDURE savetofile
	(
		pxml             IN xmltype
	   ,ppath            IN VARCHAR2
	   ,pencoding        IN VARCHAR2
	   ,pshowprogressbar BOOLEAN := FALSE
	);

	FUNCTION dialogexport(psettings typeexportsettings) RETURN NUMBER;
	PROCEDURE dialogexporthandler
	(
		pwhat   IN NUMBER
	   ,pdialog IN NUMBER
	   ,pitem   IN VARCHAR2
	   ,pcmd    IN NUMBER
	);

	FUNCTION dialogimport(psettings typeimportsettings) RETURN NUMBER;
	PROCEDURE dialogimporthandler
	(
		pwhat   IN NUMBER
	   ,pdialog IN NUMBER
	   ,pitem   IN VARCHAR2
	   ,pcmd    IN NUMBER
	);

	PROCEDURE resultdialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN CHAR
	   ,pcmd      IN NUMBER
	);

	FUNCTION existsmethod
	(
		ppackagename typepackagename
	   ,pmethodname  VARCHAR2
	   ,pformat      VARCHAR2
	) RETURN BOOLEAN;

	PROCEDURE validateentrycode(poentrycode IN OUT NOCOPY treferenceentry.code%TYPE);

	PROCEDURE validateaccount
	(
		poaccount         IN OUT NOCOPY account.typeaccountno
	   ,paccountaccessory typeaccountaccessory := NULL
	);

	PROCEDURE validatecardsign(pocardsign IN OUT NOCOPY treferencecardsign.cardsign%TYPE);

	PROCEDURE validatecontracttype(pocontracttype IN OUT NOCOPY tcontracttype.type%TYPE);

	PROCEDURE validateaccounttype(poaccounttype IN OUT NOCOPY taccounttype.accounttype%TYPE);

	FUNCTION getactiontype
	(
		pimportmode       typeimportmode
	   ,pcodecolumnisnull BOOLEAN
	) RETURN typeactiontype;

	PROCEDURE exportreferenceentry;
	PROCEDURE addmatchingreferenceentry;

	PROCEDURE exportreferencecalendar;
	PROCEDURE addmatchingreferencecalendar;

	PROCEDURE exportreferencecontracttype;
	PROCEDURE addmatchingreferencecontracttype;

	FUNCTION getcurrentsettings RETURN typeimportsettings;
	FUNCTION getcurrentparentsettings RETURN typeimportsettings;

	--PROCEDURE clearactiontypes4table(ptablename typetablename);
	/*PROCEDURE setactiontype
    (
        ptablename  typetablename
       ,psourcecode typesrccode
       ,pactiontype typeactiontype
    );*/
	/*  FUNCTION getactiontypebysrccode
    (
        ptablename  typetablename
       ,psourcecode typesrccode
    ) RETURN typeactiontype;*/

	PROCEDURE referenceentries_import
	(
		pxml        xmltype
	   ,psettings   custom_contractexchangetools.typeimportsettings
	   ,psaverecord BOOLEAN := TRUE
	);

	PROCEDURE referencecalendar_import
	(
		pxml        xmltype
	   ,psettings   custom_contractexchangetools.typeimportsettings
	   ,psaverecord BOOLEAN := TRUE
	);

	PROCEDURE referencecontracttype_import
	(
		pxml        xmltype
	   ,psettings   custom_contractexchangetools.typeimportsettings
	   ,psaverecord BOOLEAN := TRUE
	);

	PROCEDURE setrecordcount(pvalue NUMBER);

	FUNCTION getcodelist RETURN tblnumber;
	FUNCTION needbindcodelist(pwhereclause CLOB) RETURN BOOLEAN;

END custom_contractexchangetools;
/
CREATE OR REPLACE PACKAGE BODY custom_contractexchangetools IS

	cpackagename  CONSTANT VARCHAR2(100) := 'custom_ContractExchangeTools';
	cbodyrevision CONSTANT VARCHAR2(100) := '$Rev: 62887 $';

	cencode CONSTANT VARCHAR2(10) := 'UTF-8';

	cheader    CONSTANT VARCHAR2(100) := '<?xml version = "1.0" encoding = "';
	cchr10     CONSTANT CHAR(1) := chr(10);
	cheaderend CONSTANT VARCHAR2(12) := '" ?>' || cchr10;

	cpostfiximport        CONSTANT VARCHAR2(100) := '_Import';
	cpostfixexport        CONSTANT VARCHAR2(100) := '_Export';
	cpostfixvalidate      CONSTANT VARCHAR2(100) := '_Validate';
	cpostfixvalidateparam CONSTANT VARCHAR2(100) := '_ValidateParam';
	cpostfixsaverow       CONSTANT VARCHAR2(100) := '_SaveRow';

	cdsblocktag CONSTANT VARCHAR2(100) := custom_dynasql.cmainnode;

	cparamstag        CONSTANT VARCHAR2(100) := 'CONTRACTPARAMS';
	cparamtag         CONSTANT VARCHAR2(100) := 'PARAM';
	cparamobjectnotag CONSTANT VARCHAR2(100) := 'OBJECTNO';
	cparamkeytag      CONSTANT VARCHAR2(100) := 'KEY';
	cparamvaluetag    CONSTANT VARCHAR2(100) := 'VALUE';

	cdynasqltable CONSTANT VARCHAR2(100) := 'tDynaSQL';

	cmaxsyssign CONSTANT NUMBER := 30;

	TYPE typecursor IS REF CURSOR;

	sdebug          BOOLEAN := TRUE;
	sexportsettings typeexportsettings;
	simportsettings typeimportsettings;
	sxml            xmltype;

	scurrentsettings       typeimportsettings;
	scurrentparentsettings typeimportsettings;

	TYPE typecolumnsbytablename IS TABLE OF typecolumnarray INDEX BY VARCHAR2(200);

	sacolumns   typecolumnsbytablename;
	sapkcolumns typecolumnsbytablename;
	sauicolumns typecolumnsbytablename;

	sacodelist tblnumber := tblnumber();

	cemptyimportsettings CONSTANT typeimportsettings := NULL;

	TYPE typemethodexistsbyformatlist IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
	TYPE typemethodexistsbymethodlist IS TABLE OF typemethodexistsbyformatlist INDEX BY VARCHAR2(128);
	TYPE typemethodexistsbyschemas IS TABLE OF typemethodexistsbymethodlist INDEX BY typepackagename;

	samethodexists     typemethodexistsbyschemas;
	sreccountinportion NUMBER := 1000;

	--TYPE typeactiontypebyid IS TABLE OF custom_contractexchangetools.typeactiontype INDEX BY typesrccode;
	--TYPE typeactiontypebytable IS TABLE OF custom_contractexchangetools.typeactiontypebyid INDEX BY typetablename;
	--saactiontypes typeactiontypebytable;

	FUNCTION addsettings_getcodecolumn(psettings typeimportsettings) RETURN VARCHAR2;
	FUNCTION addsettings_getsequencename(psettings typeimportsettings) RETURN VARCHAR2;
	FUNCTION addsettings_getobjectname(psettings typeimportsettings) RETURN VARCHAR2;
	FUNCTION addsettings_getparametersobjecttype(psettings typeimportsettings)
		RETURN typeparamobjecttype;

	FUNCTION expaddsettings_getparametersobjecttype(psettings typeexportsettings)
		RETURN typeparamobjecttype;
	FUNCTION expaddsettings_getdynasqlblockcolumns(psettings typeexportsettings) RETURN types.arrstr100;

	FUNCTION getcolumns(ptablename VARCHAR2) RETURN typecolumnarray;
	FUNCTION getpkcolumns(ptablename VARCHAR2) RETURN typecolumnarray;
	FUNCTION getfkmatchingstr
	(
		pconstraintname  VARCHAR2
	   ,pmaintablealias  VARCHAR2
	   ,pchildtablealias VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION addalias
	(
		pstr       VARCHAR2
	   ,ptablename VARCHAR2
	   ,palias     VARCHAR2
	) RETURN VARCHAR2;
	FUNCTION gettablecodecolumn(ptablename VARCHAR2) RETURN VARCHAR2;

	FUNCTION columnexists
	(
		pacolumns   typecolumnarray
	   ,pcolumnname VARCHAR2
	) RETURN BOOLEAN;
	FUNCTION branchexists(pacolumns typecolumnarray) RETURN BOOLEAN;

	FUNCTION getversion RETURN VARCHAR2 IS
	BEGIN
		RETURN service.formatpackageversion(cpackagename, crevision, cbodyrevision);
	END;

	PROCEDURE sayxml
	(
		pxml          xmltype
	   ,pdescription  VARCHAR2 := NULL
	   ,plength2debug NUMBER := NULL
	) IS
		vclob CLOB;
	BEGIN
		IF pxml IS NOT NULL
		THEN
			IF sdebug
			THEN
				vclob := pxml.getclobval();
				IF plength2debug IS NOT NULL
				THEN
					s.say(coalesce(pdescription, 'XML') || '[only ' || plength2debug || ']:');
					s.say(substr(vclob, 1, plength2debug));
				ELSE
					s.say(coalesce(pdescription, 'XML') || ':');
					s.say(vclob);
				END IF;
			END IF;
		ELSE
			s.say(coalesce(pdescription, 'XML') || ' is empty');
		END IF;
	END;

	PROCEDURE say(ptext CLOB) IS
	BEGIN
		IF sdebug
		THEN
			s.say(ptext);
		END IF;
	END;

	PROCEDURE say(pmessage VARCHAR2) IS
	BEGIN
		IF sdebug
		THEN
			s.say(pmessage);
		END IF;
	END;

	PROCEDURE setcurrentsettings(psettings typeimportsettings) IS
	BEGIN
		scurrentsettings := psettings;
	END;

	FUNCTION getcurrentsettings RETURN typeimportsettings IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetCurrentSettings';
	BEGIN
		t.leave(cmethodname
			   ,'tableName=' || scurrentsettings.tablename || ', Code=' ||
				scurrentsettings.codecolumn || ', RefCode=' || scurrentsettings.refcodecolumn);
		RETURN scurrentsettings;
	END;

	PROCEDURE setcurrentparentsettings(psettings typeimportsettings) IS
	BEGIN
		scurrentparentsettings := psettings;
	END;

	FUNCTION getcurrentparentsettings RETURN typeimportsettings IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetCurrentParentSettings';
	BEGIN
		t.leave(cmethodname
			   ,'tableName=' || scurrentparentsettings.tablename || ', Code=' ||
				scurrentparentsettings.codecolumn || ', RefCode=' ||
				scurrentparentsettings.refcodecolumn);
		RETURN scurrentparentsettings;
	END;

	/*  PROCEDURE clearactiontypes4table(ptablename typetablename) IS
            cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ClearActionTypes4Table';
        BEGIN
            IF saactiontypes.exists(upper(ptablename))
            THEN
                saactiontypes(upper(ptablename)).delete;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                error.save(cmethodname);
                RAISE;
        END;
    */
	/*  PROCEDURE setactiontype
            (
                ptablename  typetablename
               ,psourcecode typesrccode
               ,pactiontype typeactiontype
            ) IS
                cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.SetActionType';
            BEGIN
                t.enter(cmethodname
                       ,'TableName=' || ptablename || ', SourceCode=' || psourcecode || ', ActionType=' ||
                        pactiontype);
                saactiontypes(upper(ptablename))(psourcecode) := pactiontype;
            EXCEPTION
                WHEN OTHERS THEN
                    error.save(cmethodname);
                    RAISE;
            END;
        
        FUNCTION getactiontypebysrccode
        (
            ptablename  typetablename
           ,psourcecode typesrccode
        ) RETURN typeactiontype IS
            cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetActionTypeBySrcCode';
            vactiontype typeactiontype;
        BEGIN
            t.enter(cmethodname, 'TableName=' || ptablename || ', SourceCode=' || psourcecode);
            IF saactiontypes.exists(upper(ptablename))
               AND saactiontypes(upper(ptablename)).exists(psourcecode)
            THEN
                s.say('p1');
                vactiontype := saactiontypes(upper(ptablename)) (psourcecode);
            ELSE
                s.say('p2');
                vactiontype := cacttype_unknown;
            END IF;
            t.leave(cmethodname, 'return ' || vactiontype);
            RETURN vactiontype;
        EXCEPTION
            WHEN OTHERS THEN
                error.save(cmethodname);
                RAISE;
        END;
    */
	FUNCTION getimportmodedescription(pimportmode typeimportmode) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetImportModeDescription';
		vret VARCHAR2(100);
	BEGIN
		CASE pimportmode
			WHEN cimportmode_stop THEN
				vret := 'Stop import';
			WHEN cimportmode_over THEN
				vret := 'Refresh';
			WHEN cimportmode_skip THEN
				vret := 'Skip';
			ELSE
				vret := 'unknown import mode';
		END CASE;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getparamsxml
	(
		psettings         typeexportsettings
	   ,pparamsobjecttype typeparamobjecttype := NULL
	) RETURN xmltype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetParamsXML';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vxml    xmltype;
		vcurstr VARCHAR2(4000);
	BEGIN
	
		IF psettings.whereclause IS NOT NULL
		THEN
			vcurstr := 'select XMLElement("' || cparamstag || '", XMLAGG(XMLElement("' || cparamtag ||
					   '", XMLForest(objectNo, key, value)))) from tContractOtherParameters
						   where branch=' || cbranch || '
							 and objecttype in (select  ObjectType from tContractOtherObjectType
												 where Branch = ' || cbranch || ' and   ObjectSign = ''' ||
					   coalesce(pparamsobjecttype
							   ,expaddsettings_getparametersobjecttype(psettings)) || ''')
												   and ObjectNo in (select ' || psettings.codecolumn || ' from ' ||
					   psettings.tablename || ' where ' || psettings.whereclause || ')';
			s.say('SQL4Params:');
			s.say(vcurstr);
		
			IF custom_contractexchangetools.needbindcodelist(psettings.whereclause)
			THEN
				EXECUTE IMMEDIATE vcurstr
					INTO vxml
					USING custom_contractexchangetools.getcodelist;
			ELSE
				EXECUTE IMMEDIATE vcurstr
					INTO vxml;
			END IF;
		ELSE
			vcurstr := 'select XMLElement("' || cparamstag || '", XMLAGG(XMLElement("' || cparamtag ||
					   '", XMLForest(objectNo, key, value)))) from tContractOtherParameters
						   where branch=' || cbranch || '
							 and objecttype in (select  ObjectType from tContractOtherObjectType
												 where Branch = ' || cbranch || ' and   ObjectSign = ''' ||
					   coalesce(pparamsobjecttype
							   ,expaddsettings_getparametersobjecttype(psettings)) || ''')';
			s.say('SQL4Params:');
			s.say(vcurstr);
			EXECUTE IMMEDIATE vcurstr
				INTO vxml;
		END IF;
	
		RETURN vxml;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION exportdynasqlblock(pdsrow tdynasql%ROWTYPE) RETURN xmltype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetDynaSQLXML';
		vxml xmltype;
		vsrc CLOB;
	BEGIN
		vsrc := dynasql.getsql(pdsrow.code);
		SELECT xmlelement("DYNASQL"
						  ,xmlattributes(pdsrow.objtype objtype
									   ,pdsrow.objmodule objmodule
									   ,pdsrow.objident objident
									   ,pdsrow.code code)
						  ,xmlforest(vsrc SQL, pdsrow.locator locator, pdsrow.remark remark))
		INTO   vxml
		FROM   dual;
		sayxml(vxml, 'DynaSQLBlock');
	
		RETURN vxml;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getdynasqlxml(psettings typeexportsettings) RETURN xmltype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetDynaSQLXML';
		vxml xmltype;
	
		vcurstr          VARCHAR2(32767);
		vcursor          typecursor;
		vdynasqlrow      tdynasql%ROWTYPE;
		vblockxml        xmltype;
		vadynasqlcolumns types.arrstr100;
	
	BEGIN
		t.enter(cmethodname);
		vadynasqlcolumns := expaddsettings_getdynasqlblockcolumns(psettings);
		t.var('DynaSQLColumns.Count', vadynasqlcolumns.count);
		FOR i IN 1 .. vadynasqlcolumns.count
		LOOP
			t.var('-------- DynaSQLColumns(' || i || ')', vadynasqlcolumns(i));
			vcurstr := 'select ds.* from  ' || psettings.tablename || ' t' || cchr10 ||
					   'join tDynaSQL ds on t.' || vadynasqlcolumns(i) || '=ds.code' || cchr10 ||
					   service.iif(psettings.whereclause IS NOT NULL
								  ,' where ' ||
								   addalias(psettings.whereclause, psettings.tablename, 't')
								  ,'') || cchr10 ||
					   service.iif(psettings.orderclause IS NOT NULL
								  ,' order by ' ||
								   addalias(psettings.orderclause, psettings.tablename, 't')
								  ,'');
			t.note('CursorSQL', vcurstr);
			OPEN vcursor FOR vcurstr;
			LOOP
				FETCH vcursor
					INTO vdynasqlrow;
				EXIT WHEN vcursor%NOTFOUND;
				vblockxml := exportdynasqlblock(vdynasqlrow);
				EXECUTE IMMEDIATE 'select XMLConcat(:1, :2) from dual'
					INTO vxml
					USING vxml, vblockxml;
			END LOOP;
			CLOSE vcursor;
		END LOOP;
	
		IF vxml IS NOT NULL
		THEN
			EXECUTE IMMEDIATE 'select XMLElement("' || cdsblockstag || '", :1) from dual'
				INTO vxml
				USING vxml;
		END IF;
	
		sayxml(vxml, 'DynaSQLBlocks');
		t.leave(cmethodname);
		RETURN vxml;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getmainxml
	(
		psettings     typeexportsettings
	   ,pshowprogress BOOLEAN := FALSE
	   ,pallcount     NUMBER := NULL
	) RETURN xmltype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.cMethodName';
		vxml        xmltype;
		vfullxml    xmltype;
		vportion    NUMBER;
		vcount      NUMBER;
		vmainsql    CLOB;
		vsql        CLOB;
		vcolumnlist VARCHAR2(32767);
		voffset     NUMBER;
		vallcount   NUMBER := pallcount;
	BEGIN
		t.enter(cmethodname, 'AllCount=' || vallcount);
		IF vallcount IS NULL
		THEN
			vsql := 'select count(1) from ' || psettings.tablename ||
					service.iif(psettings.whereclause IS NOT NULL
							   ,' where ' || psettings.whereclause
							   ,'');
			s.say(cmethodname || ': SQL4Count:');
			s.say(vsql);
		
			IF needbindcodelist(psettings.whereclause)
			THEN
				EXECUTE IMMEDIATE vsql
					INTO vallcount
					USING getcodelist;
			ELSE
				EXECUTE IMMEDIATE vsql
					INTO vallcount;
			END IF;
		
			t.var('AllCount[2]', vallcount);
		END IF;
	
		vsql := 'select listagg(case data_type ' || cchr10 ||
				'when ''DATE'' then ''to_char(''||column_name||'', ''''' || cdateformat ||
				''''') as ''||column_name' || cchr10 ||
			   
				'else column_name ' || cchr10 || 'end  ' || cchr10 ||
				', '', '') within group (order by column_id) as column_list' || cchr10 ||
				' from  user_tab_columns t ' || cchr10 || 'where t.table_name = upper(''' ||
				psettings.tablename || ''')';
		s.say(cmethodname || ': SQL:');
		s.say(vsql);
		EXECUTE IMMEDIATE vsql
			INTO vcolumnlist;
	
		t.var('saCodeList.Count', getcodelist().count);
	
		IF coalesce(vallcount, 0) > coalesce(sreccountinportion, 0)
		THEN
			vmainsql := 'select  XMLAGG( ' || cchr10 || ' XMLElement("' ||
						upper(psettings.tablename) || '_ROW", XMLForest (' || vcolumnlist || '))) ' ||
						cchr10 || ' from (select * from  ' || psettings.tablename || cchr10 ||
						service.iif(psettings.whereclause IS NOT NULL
								   ,' where ' || psettings.whereclause
								   ,'') || cchr10 ||
					   
						service.iif(psettings.orderclause IS NOT NULL
								   ,' order by ' || psettings.orderclause
								   ,'') || cchr10 || ' offset :1 rows' || cchr10 ||
						' fetch next :2 rows only) ';
			s.say(cmethodname || ': SQL2:');
			s.say(vmainsql);
		
			vportion := 1;
			vcount   := 0;
			IF pshowprogress
			   AND coalesce(vallcount, 0) > 0
			THEN
				dialog.percentbox('INIT'
								 ,vallcount
								 ,coalesce(psettings.referencename, psettings.objectname));
			END IF;
			t.var('RecCountInPortion', sreccountinportion);
		
			LOOP
			
				voffset := (vportion - 1) * sreccountinportion;
				t.var('Offset', voffset);
				IF needbindcodelist(psettings.whereclause)
				THEN
					EXECUTE IMMEDIATE vmainsql
						INTO vxml
						USING getcodelist, voffset, sreccountinportion;
				ELSE
					EXECUTE IMMEDIATE vmainsql
						INTO vxml
						USING voffset, sreccountinportion;
				END IF;
				SELECT xmlconcat(vfullxml, vxml) INTO vfullxml FROM dual;
				EXIT WHEN vxml IS NULL;
			
				vcount := vcount + sreccountinportion;
				t.note('Portion', vportion);
				t.note('Count?', vcount);
			
				vportion := vportion + 1;
				IF pshowprogress
				   AND coalesce(vallcount, 0) > 0
				THEN
					dialog.percentbox('SHOW', service.iif(vcount <= vallcount, vcount, vallcount));
				END IF;
			END LOOP;
			EXECUTE IMMEDIATE 'select XMLElement("' || upper(psettings.tablename) ||
							  '", :1) from dual'
				INTO vfullxml
				USING vfullxml;
		
			IF pshowprogress
			   AND coalesce(vallcount, 0) > 0
			THEN
				dialog.percentbox('DOWN');
			END IF;
		ELSE
		
			vmainsql := 'select XMLElement("' || upper(psettings.tablename) || '",  XMLAGG( ' ||
						cchr10 || ' XMLElement("' || upper(psettings.tablename) ||
						'_ROW", XMLForest (' || vcolumnlist || ')))) ' || cchr10 ||
						' from (select * from  ' || psettings.tablename || cchr10 ||
						service.iif(psettings.whereclause IS NOT NULL
								   ,' where ' || psettings.whereclause
								   ,'') || cchr10 ||
					   
						service.iif(psettings.orderclause IS NOT NULL
								   ,' order by ' || psettings.orderclause
								   ,'') || ')';
			s.say(cmethodname || ': SQL2:');
		
			s.say(cmethodname || ': SQL2:');
			s.say(vmainsql);
		
			IF needbindcodelist(psettings.whereclause)
			THEN
				EXECUTE IMMEDIATE vmainsql
					INTO vfullxml
					USING getcodelist;
			ELSE
				EXECUTE IMMEDIATE vmainsql
					INTO vfullxml;
			END IF;
		END IF;
		t.leave(cmethodname, 'exported ' || vcount || ' rows');
		RETURN vfullxml;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			IF pshowprogress
			   AND coalesce(vallcount, 0) > coalesce(sreccountinportion, 0)
			THEN
				dialog.percentbox('DOWN');
			END IF;
			RAISE;
	END;

	FUNCTION export_
	(
		psettings typeexportsettings
	   ,pcount    NUMBER := NULL
	) RETURN xmltype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.Export_';
		vxml                  xmltype;
		vparamsxml            xmltype;
		vdynasqlxml           xmltype;
		vtablelist            VARCHAR2(2000);
		vchildsettings        typeexportsettings;
		vchildxml             xmltype;
		vparametersobjecttype typeparamobjecttype;
	BEGIN
		t.enter(cmethodname, 'tablename=' || psettings.tablename);
		IF psettings.tablename IS NULL
		THEN
			t.note('table name is empty');
			RETURN vxml;
		END IF;
	
		vxml := getmainxml(psettings, TRUE, pcount);
	
		sayxml(vxml);
	
		vdynasqlxml := getdynasqlxml(psettings);
		IF vdynasqlxml IS NOT NULL
		THEN
			SELECT xmlconcat(vxml, vdynasqlxml) INTO vxml FROM dual;
		END IF;
	
		vparametersobjecttype := expaddsettings_getparametersobjecttype(psettings);
		IF vparametersobjecttype IS NOT NULL
		THEN
			vparamsxml := getparamsxml(psettings, vparametersobjecttype);
			SELECT xmlconcat(vxml, vparamsxml) INTO vxml FROM dual;
		END IF;
	
		vtablelist := ' ' || upper(REPLACE(REPLACE(psettings.childtablelist, ' ', ''), ',', ', ')) || ', ';
		t.var('TableList', vtablelist);
	
		IF psettings.exportchilds
		THEN
		
			FOR i IN (SELECT constraint_name
							,table_name
					  FROM   user_constraints
					  WHERE  constraint_type = 'R'
					  AND    r_constraint_name IN
							 (SELECT constraint_name
							   FROM   user_constraints
							   WHERE  table_name = upper(psettings.tablename)
							   AND    constraint_type = 'P'))
			LOOP
			
				s.say('---------------------------------' || i.table_name || ': ' ||
					  instr(vtablelist, ' ' || i.table_name || ',', 1, 1));
				IF psettings.childtablelist IS NULL
				   OR instr(vtablelist, ' ' || i.table_name || ',', 1, 1) > 0
				THEN
					vchildsettings             := psettings;
					vchildsettings.tablename   := i.table_name;
					vchildsettings.whereclause := i.table_name || '.rowid in (select ' ||
												  i.table_name || '.rowid from ' || i.table_name ||
												  ' join ' || psettings.tablename || ' on ' ||
												  getfkmatchingstr(i.constraint_name
																  ,psettings.tablename
																  ,i.table_name) ||
												  service.iif(psettings.whereclause IS NOT NULL
															 ,' where ' ||
															  addalias(psettings.whereclause
																	  ,psettings.tablename
																	  ,psettings.tablename)
															 ,'') || ')';
					vchildsettings.objectname  := psettings.objectname;
					vchildsettings.codecolumn  := gettablecodecolumn(i.table_name);
					vchildsettings.orderclause := vchildsettings.codecolumn;
					vchildxml                  := export_(vchildsettings);
					EXECUTE IMMEDIATE 'select XMLConcat(:1, :2) from dual'
						INTO vxml
						USING vxml, vchildxml;
				END IF;
			END LOOP;
		END IF;
	
		RETURN vxml;
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE clearlog IS
	BEGIN
		t.enter(cpackagename || '.ClearLog');
		EXECUTE IMMEDIATE 'truncate table tContractImportLog';
	END;

	PROCEDURE clear IS
	BEGIN
		sacolumns.delete;
		sapkcolumns.delete;
		scurrentsettings       := cemptyimportsettings;
		scurrentparentsettings := cemptyimportsettings;
	END;

	FUNCTION getcolumns(ptablename VARCHAR2) RETURN typecolumnarray IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetColumns';
		vsql VARCHAR2(1000);
	BEGIN
		t.enter(cmethodname);
		IF NOT sacolumns.exists(ptablename)
		THEN
			vsql := 'select column_name, data_type from  user_tab_columns t ' || cchr10 ||
					'where t.table_name = upper(''' || ptablename || ''') ' || cchr10 ||
					'order by column_id';
			EXECUTE IMMEDIATE vsql BULK COLLECT
				INTO sacolumns(ptablename);
			t.note(cmethodname, 'read');
		END IF;
		IF sacolumns.exists(ptablename)
		THEN
			t.leave(cmethodname, 'Columns.Count=' || sacolumns(ptablename).count);
			RETURN sacolumns(ptablename);
		ELSE
			t.leave(cmethodname, 'return empty array');
			RETURN cemptycolumnarray;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE fillpkcolumns
	(
		ptablename     VARCHAR2
	   ,paddcodecolumn BOOLEAN := FALSE
	   ,pcodecolumn    VARCHAR2 := NULL
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.FillPKColumns';
	BEGIN
		t.enter(cmethodname
			   ,'TableName=' || ptablename || ', pAddCodeColumn=' || htools.b2s(paddcodecolumn) ||
				', pCodeColumn=' || pcodecolumn);
		IF sapkcolumns.count = 0
		THEN
			s.say('p1');
		
			SELECT column_name
				  ,NULL AS data_type BULK COLLECT
			INTO   sapkcolumns(ptablename)
			FROM   user_cons_columns
			WHERE  owner = 'A4M'
			AND    constraint_name IN (SELECT constraint_name
									   FROM   user_constraints
									   WHERE  table_name = upper(ptablename)
									   AND    constraint_type = 'P')
			ORDER  BY position;
			t.note(cmethodname, 'from user_cons_columns: ' || sapkcolumns.count);
		
			IF paddcodecolumn
			   AND sapkcolumns.count = 0
			   AND pcodecolumn IS NOT NULL
			THEN
				s.say('p2');
				sapkcolumns(ptablename)(1).column_name := upper(pcodecolumn);
				IF branchexists(getcolumns(ptablename))
				THEN
					sapkcolumns(ptablename)(2).column_name := 'BRANCH';
				END IF;
			END IF;
		END IF;
		t.leave(cmethodname, 'PKColumns.Count=' || sapkcolumns.count);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getpkcolumns(ptablename VARCHAR2) RETURN typecolumnarray IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetPKColumns';
	BEGIN
		IF NOT sapkcolumns.exists(ptablename)
		THEN
			fillpkcolumns(ptablename, FALSE, NULL);
		END IF;
		IF sapkcolumns.exists(ptablename)
		THEN
			t.leave(cmethodname, 'PKColumns.Count=' || sapkcolumns(ptablename).count);
			RETURN sapkcolumns(ptablename);
		ELSE
			t.leave(cmethodname, 'return empty array');
			RETURN cemptycolumnarray;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getuicolumns
	(
		ptablename  VARCHAR2
	   ,pcodecolumn VARCHAR2
	) RETURN typecolumnarray IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetUIColumns';
	BEGIN
		IF NOT sauicolumns.exists(ptablename)
		THEN
			SELECT column_name
				  ,NULL AS data_type BULK COLLECT
			INTO   sauicolumns(ptablename)
			FROM   user_ind_columns
			WHERE  table_name = upper(ptablename)
			AND    index_name IN (SELECT index_name
								  FROM   user_indexes i
								  WHERE  table_owner = 'A4M'
								  AND    table_name = upper(ptablename)
								  AND    uniqueness = 'UNIQUE'
								  AND    EXISTS (SELECT *
										  FROM   user_ind_columns
										  WHERE  table_name = i.table_name
										  AND    index_name = i.index_name
										  AND    column_name = upper(pcodecolumn))
								  AND    rownum = 1);
		END IF;
		IF sauicolumns.exists(ptablename)
		THEN
			t.leave(cmethodname, 'UIColumns.Count=' || sauicolumns(ptablename).count);
			RETURN sauicolumns(ptablename);
		ELSE
			t.leave(cmethodname, 'return empty array');
			RETURN cemptycolumnarray;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION columnexists
	(
		pacolumns   typecolumnarray
	   ,pcolumnname VARCHAR2
	) RETURN BOOLEAN IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ColumnExists';
		vret BOOLEAN := FALSE;
	BEGIN
		t.enter(cmethodname);
		FOR i IN 1 .. pacolumns.count
		LOOP
			IF upper(pacolumns(i).column_name) = upper(pcolumnname)
			THEN
				vret := TRUE;
				EXIT;
			END IF;
		END LOOP;
		t.leave(cmethodname);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION branchexists(pacolumns typecolumnarray) RETURN BOOLEAN IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.BranchExists';
	BEGIN
		t.enter(cmethodname);
		RETURN columnexists(pacolumns, 'BRANCH');
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getupdatecolumnstr
	(
		ptablename  VARCHAR2
	   ,pacolumns   typecolumnarray := cemptycolumnarray
	   ,papkcolumns typecolumnarray := cemptycolumnarray
	) RETURN CLOB IS
		cmethodname CONSTANT VARCHAR2(100) := 'GetUpdateColumnStr';
		vret CLOB;
		ccomma CONSTANT VARCHAR2(10) := ', ';
		vacolumns   typecolumnarray := pacolumns;
		vapkcolumns typecolumnarray := papkcolumns;
	BEGIN
		t.enter(cmethodname);
		IF vacolumns.count = 0
		THEN
			vacolumns := getcolumns(ptablename);
		END IF;
		IF vapkcolumns.count = 0
		THEN
			vapkcolumns := getpkcolumns(ptablename);
		END IF;
		FOR i IN 1 .. vacolumns.count
		LOOP
			IF NOT columnexists(vapkcolumns, vacolumns(i).column_name)
			THEN
				vret := vret || vacolumns(i).column_name || ' = :u' || i || ccomma;
			END IF;
		END LOOP;
		vret := substr(vret, 1, length(vret) - length(ccomma));
		t.leave(cmethodname, 'return ' || vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getmergeonstr
	(
		ptablename  VARCHAR2
	   ,papkcolumns typecolumnarray := cemptycolumnarray
	) RETURN CLOB IS
		cmethodname CONSTANT VARCHAR2(100) := 'GetMergeOnStr';
		vret CLOB;
		cand CONSTANT VARCHAR2(10) := ' and ';
		vapkcolumns typecolumnarray := papkcolumns;
	BEGIN
		t.enter(cmethodname, 'pTableName=' || ptablename);
		IF vapkcolumns.count = 0
		THEN
			vapkcolumns := getpkcolumns(ptablename);
		END IF;
		FOR i IN 1 .. vapkcolumns.count
		LOOP
			t.var(' vaColumns(' || i || ').column_name', vapkcolumns(i).column_name);
			vret := vret || 't.' || vapkcolumns(i).column_name || '=:p' || i || cand;
		END LOOP;
	
		vret := substr(vret, 1, length(vret) - length(cand));
		t.leave(cmethodname, 'return ' || vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getinsertcolumnstr
	(
		ptablename VARCHAR2
	   ,pacolumns  custom_contractexchangetools.typecolumnarray := cemptycolumnarray
	) RETURN CLOB IS
		cmethodname CONSTANT VARCHAR2(100) := 'GetInsertColumnStr';
		vret CLOB;
		ccomma CONSTANT VARCHAR2(10) := ', ';
		vacolumns typecolumnarray := pacolumns;
	BEGIN
		t.enter(cmethodname);
		IF vacolumns.count = 0
		THEN
			vacolumns := getcolumns(ptablename);
		END IF;
		FOR i IN 1 .. vacolumns.count
		LOOP
			vret := vret || vacolumns(i).column_name || ccomma;
		END LOOP;
		vret := substr(vret, 1, length(vret) - length(ccomma));
		t.leave(cmethodname);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getinsertbindstr
	(
		ptablename VARCHAR2
	   ,pacolumns  custom_contractexchangetools.typecolumnarray := cemptycolumnarray
	) RETURN CLOB IS
		cmethodname CONSTANT VARCHAR2(100) := 'GetInsertBindStr';
		vret CLOB;
		ccomma CONSTANT VARCHAR2(10) := ', ';
		vacolumns typecolumnarray := pacolumns;
	BEGIN
		t.enter(cmethodname);
		IF vacolumns.count = 0
		THEN
			vacolumns := getcolumns(ptablename);
		END IF;
		FOR i IN 1 .. vacolumns.count
		LOOP
		
			vret := vret || ':' || i || ccomma;
		
		END LOOP;
		vret := substr(vret, 1, length(vret) - length(ccomma));
		t.leave(cmethodname);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION addsettings_getcodecolumn(psettings typeimportsettings) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.AddSettings_GetCodeColumn';
		vcodecolumn VARCHAR2(100);
	BEGIN
		t.enter(cmethodname, 'tableName=' || psettings.tablename);
		IF psettings.additionalsettings.exists(psettings.tablename)
		THEN
			vcodecolumn := upper(psettings.additionalsettings(psettings.tablename).codecolumn);
		END IF;
		t.leave(cmethodname, 'return ' || vcodecolumn);
		RETURN vcodecolumn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION addsettings_getsequencename(psettings typeimportsettings) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.AddSettings_GetSequenceName';
		vsequencename VARCHAR2(100);
	BEGIN
		IF psettings.additionalsettings.exists(psettings.tablename)
		THEN
			vsequencename := upper(psettings.additionalsettings(psettings.tablename).sequencename);
		END IF;
		RETURN vsequencename;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION addsettings_getparametersobjecttype(psettings typeimportsettings)
		RETURN typeparamobjecttype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
											  '.AddSettings_GetParametersObjectType';
		vparametersobjecttype typeparamobjecttype;
	BEGIN
		IF psettings.additionalsettings.exists(psettings.tablename)
		THEN
			vparametersobjecttype := upper(psettings.additionalsettings(psettings.tablename)
										   .parametersobjecttype);
		END IF;
		RETURN vparametersobjecttype;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION expaddsettings_getparametersobjecttype(psettings typeexportsettings)
		RETURN typeparamobjecttype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename ||
											  '.AddSettings_GetParametersObjectType';
		vparametersobjecttype typeparamobjecttype;
	BEGIN
		IF psettings.additionalsettings.exists(psettings.tablename)
		THEN
			vparametersobjecttype := upper(psettings.additionalsettings(psettings.tablename)
										   .parametersobjecttype);
		END IF;
		RETURN vparametersobjecttype;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION expaddsettings_getdynasqlblockcolumns(psettings typeexportsettings) RETURN types.arrstr100 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.AddSettings_GetDynaSQLBlockColumns';
		varet      types.arrstr100;
		vtablename VARCHAR2(100);
	BEGIN
		t.enter(cmethodname, 'TableName=' || psettings.tablename);
	
		vtablename := psettings.additionalsettings.first;
		s.say('p0: ' || vtablename);
		IF psettings.additionalsettings.exists(psettings.tablename)
		THEN
			s.say('p1');
			varet := psettings.additionalsettings(psettings.tablename).dynasqlblockcolumns;
		
		END IF;
		t.leave(cmethodname, 'return ' || varet.count);
		RETURN varet;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION addsettings_getobjectname(psettings typeimportsettings) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.AddSettings_GetObjectName';
		vobjectname VARCHAR2(100);
	BEGIN
		IF psettings.additionalsettings.exists(psettings.tablename)
		THEN
			vobjectname := upper(psettings.additionalsettings(psettings.tablename).objectname);
		END IF;
		RETURN vobjectname;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION gettablecodecolumn(ptablename VARCHAR2) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetTableCodeColumn';
		vcodecolumn VARCHAR2(100);
	BEGIN
		t.enter(cmethodname, 'TableName=' || ptablename);
		SELECT column_name
		INTO   vcodecolumn
		FROM   user_cons_columns
		WHERE  owner = 'A4M'
		AND    table_name = upper(ptablename)
		AND    constraint_name IN (SELECT constraint_name
								   FROM   user_constraints
								   WHERE  owner = 'A4M'
								   AND    table_name = upper(ptablename)
								   AND    constraint_type = 'P')
		AND    column_name <> 'BRANCH'
		AND    rownum = 1
		ORDER  BY position;
	
		t.leave(cmethodname, 'CodeColumn=' || vcodecolumn);
		RETURN vcodecolumn;
	EXCEPTION
		WHEN no_data_found THEN
			t.leave(cmethodname, 'CodeColumn=[null]');
			RETURN NULL;
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getchildtablerefcodecolumn
	(
		pchildtablename      VARCHAR2
	   ,pconstraintname      VARCHAR2
	   ,pparenttablename     VARCHAR2
	   ,pparentrefcodecolumn VARCHAR2
	) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetChildTableRefCodeColumn';
		vcodecolumn VARCHAR2(100);
	BEGIN
		t.enter(cmethodname
			   ,'ChildTableName=' || pchildtablename || ', ConstraintName=' || pconstraintname ||
				', ParentTableName=' || pparenttablename || ', ParentTableCodeColumn=' ||
				pparentrefcodecolumn);
		SELECT column_name
		INTO   vcodecolumn
		FROM   user_cons_columns
		WHERE  owner = 'A4M'
		AND    table_name = upper(pchildtablename)
		AND    constraint_name = upper(pconstraintname)
		AND    position IN (SELECT position
							FROM   user_cons_columns
							WHERE  owner = 'A4M'
							AND    table_name = upper(pparenttablename)
							AND    column_name = upper(pparentrefcodecolumn));
	
		t.leave(cmethodname, 'RefCodeColumn=' || vcodecolumn);
		RETURN vcodecolumn;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION addalias
	(
		pstr       VARCHAR2
	   ,ptablename VARCHAR2
	   ,palias     VARCHAR2
	) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.AddAlias';
		vret          VARCHAR2(32767) := ' ' || lower(pstr) || ' ';
		vacolumnarray typecolumnarray;
	BEGIN
		t.enter(cmethodname, pstr);
		vacolumnarray := getcolumns(ptablename);
		FOR i IN 1 .. vacolumnarray.count
		LOOP
			say(i || ':' || vacolumnarray(i).column_name);
			vret := REPLACE(vret
						   ,' ' || lower(vacolumnarray(i).column_name) || ' '
						   ,' ' || palias || '.' || lower(vacolumnarray(i).column_name) || ' ');
			say(i || ': ret(1)=' || vret);
			vret := REPLACE(vret
						   ,' ' || lower(vacolumnarray(i).column_name) || '='
						   ,' ' || palias || '.' || lower(vacolumnarray(i).column_name) || '=');
			say(i || ': ret(2)=' || vret);
		END LOOP;
		t.leave(cmethodname, vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getfkmatchingstr
	(
		pconstraintname  VARCHAR2
	   ,pmaintablealias  VARCHAR2
	   ,pchildtablealias VARCHAR2
	) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.AddAlias';
		vret    VARCHAR2(32767);
		vpkname VARCHAR2(128);
	BEGIN
		t.enter(cmethodname);
		SELECT r_constraint_name
		INTO   vpkname
		FROM   user_constraints
		WHERE  constraint_name = upper(pconstraintname);
	
		FOR i IN (SELECT *
				  FROM   user_cons_columns
				  WHERE  constraint_name = upper(pconstraintname)
				  ORDER  BY position)
		LOOP
			say('---------------' || i.position || ': ' || i.column_name);
			FOR j IN (SELECT *
					  FROM   user_cons_columns
					  WHERE  constraint_name = vpkname
					  AND    position = i.position)
			LOOP
				say('--' || j.column_name || ', [' || service.iif(vret IS NOT NULL, ' and ', ' ') || ']');
				vret := vret || service.iif(vret IS NOT NULL, ' and ', ' ') || pchildtablealias || '.' ||
						i.column_name || ' = ' || pmaintablealias || '.' || j.column_name;
			END LOOP;
		END LOOP;
		t.leave(cmethodname, vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getvaluesstr
	(
		ptablename        VARCHAR2
	   ,pacolumns         typecolumnarray := cemptycolumnarray
	   ,pexcludepkcolumns BOOLEAN := FALSE
	   ,papkcolumns       typecolumnarray := cemptycolumnarray
	) RETURN CLOB IS
		cmethodname CONSTANT VARCHAR2(100) := 'GetValuesStr';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		vret CLOB;
		ccomma CONSTANT VARCHAR2(10) := ', ';
		vacolumns   typecolumnarray := pacolumns;
		vapkcolumns typecolumnarray := papkcolumns;
	BEGIN
		t.enter(cmethodname
			   ,'pExcludePkColumns=' || htools.b2s(pexcludepkcolumns) || ', pTableName=' ||
				ptablename);
		IF vacolumns.count = 0
		THEN
			vacolumns := getcolumns(ptablename);
		END IF;
		IF pexcludepkcolumns
		   AND vapkcolumns.count = 0
		THEN
			vapkcolumns := getpkcolumns(ptablename);
		END IF;
		FOR i IN 1 .. vacolumns.count
		LOOP
			t.var(' vaColumns(' || i || ').column_name', vacolumns(i).column_name);
			IF pexcludepkcolumns
			   AND columnexists(vapkcolumns, vacolumns(i).column_name)
			THEN
				s.say(cmethodname || ': skip ' || vacolumns(i).column_name);
			ELSE
				IF vacolumns(i).column_name = 'BRANCH'
				THEN
					s.say('p1');
					vret := vret || cbranch || ccomma;
				ELSE
					s.say('p2');
					vret := vret || 'poRow.' || vacolumns(i).column_name || ccomma;
				END IF;
			END IF;
		END LOOP;
	
		vret := substr(vret, 1, length(vret) - length(ccomma));
		t.leave(cmethodname, 'return ' || vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getpkvaluesstr
	(
		ptablename  VARCHAR2
	   ,papkcolumns typecolumnarray := cemptycolumnarray
	) RETURN CLOB IS
		cmethodname CONSTANT VARCHAR2(100) := 'GetPKValuesStr';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		vret CLOB;
		ccomma CONSTANT VARCHAR2(10) := ', ';
		vapkcolumns typecolumnarray := papkcolumns;
	BEGIN
		t.enter(cmethodname, 'pTableName=' || ptablename);
	
		IF vapkcolumns.count = 0
		THEN
			vapkcolumns := getpkcolumns(ptablename);
		END IF;
	
		FOR i IN 1 .. vapkcolumns.count
		LOOP
			t.var(' vaColumns(' || i || ').column_name', vapkcolumns(i).column_name);
			IF vapkcolumns(i).column_name = 'BRANCH'
			THEN
				s.say('p1');
				vret := vret || cbranch || ccomma;
			ELSE
				s.say('p2');
				vret := vret || 'poRow.' || vapkcolumns(i).column_name || ccomma;
			END IF;
		END LOOP;
	
		vret := substr(vret, 1, length(vret) - length(ccomma));
		t.leave(cmethodname, 'return ' || vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getvalidaterowstr
	(
		pimportsettings       typeimportsettings
	   ,pparentimportsettings typeimportsettings
	   ,pbranchexists         BOOLEAN
	   ,psaverecord           BOOLEAN
	) RETURN CLOB IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetValidateRowStr';
		vret CLOB;
	BEGIN
		vret := ' procedure ValidateRow (poRow in out nocopy typeRow, pSettings ContractExchangeTools.typeImportSettings, pParentSettings ContractExchangeTools.typeImportSettings, oActionType out ContractExchangeTools.typeActionType) is ' ||
				cchr10;
		vret := vret || '  cMethodName constant varchar2(100):= ''ValidateRow'';' || cchr10;
		vret := vret || '  cBranch     constant number := Seance.GetBranch();' || cchr10;
		vret := vret || '  vCode number;' || cchr10;
		vret := vret || '  vRefCode number;' || cchr10;
		vret := vret || 'begin' || cchr10;
	
		s.say(cmethodname || ': pImportSettings.CodeColumn=' || pimportsettings.codecolumn);
		vret := vret ||
				'  vCode := ContractExchangeTools.GetDestCode(pSettings.tableName, pSettings.CodeColumn, poRow.' ||
				pimportsettings.codecolumn || ');' || cchr10;
		vret := vret || '  s.say(cMethodName || '': vCode[1]=''||vCode);' || cchr10;
		s.say(cmethodname || ': pImportSettings.RefCodeColumn=' || pimportsettings.refcodecolumn);
		IF pimportsettings.refcodecolumn IS NOT NULL
		THEN
			vret := vret ||
					'  if pParentSettings.TableName is not null and pSettings.RefCodeColumn is not null then' ||
					cchr10;
			vret := vret ||
					'    vRefCode  := ContractExchangeTools.GetDestCode(pParentSettings.TableName, ''' ||
					coalesce(addsettings_getcodecolumn(pparentimportsettings)
							,pparentimportsettings.codecolumn) || ''', poRow.' ||
					pimportsettings.refcodecolumn || ');' || cchr10;
			vret := vret || '    s.say(cMethodName || '': vRefCode=''||vRefCode);' || cchr10;
			vret := vret ||
					'    if vCode is null and htools.equal(upper(pSettings.CodeColumn), upper(pSettings.RefCodeColumn)) then' ||
					cchr10;
			vret := vret || '      vCode:= vRefCode;' || cchr10;
			vret := vret || '      s.say(cMethodName || '': vCode[2]=''||vCode);' || cchr10;
			vret := vret || '    end if;  ' || cchr10;
			vret := vret || '  end if;  ' || cchr10;
		END IF;
	
		IF pparentimportsettings.tablename IS NOT NULL
		   AND pimportsettings.refcodecolumn IS NOT NULL
		THEN
			vret := vret || '  oActionType := ContractExchangeTools.GetActionTypeBySrcCode(''' ||
					pparentimportsettings.tablename || ''',  poRow.' ||
					pimportsettings.refcodecolumn || ');' || cchr10;
		ELSE
			vret := vret ||
					'  oActionType := ContractExchangeTools.GetActionType(pSettings.ImportMode, vCode is null);' ||
					cchr10;
		END IF;
		vret := vret || '  t.var(''ActionType'', oActionType);' || cchr10;
	
		vret := vret ||
				'  if oActionType in (ContractExchangeTools.cActType_MTExists_Update, ContractExchangeTools.cActType_LocExists_Update, ContractExchangeTools.cActType_NotExists_Add) then -- cActType_LocExists_Update reserved for adding character identifier' ||
				cchr10;
		IF pimportsettings.refcodecolumn IS NOT NULL
		THEN
			vret := vret || '    poRow.' || pimportsettings.refcodecolumn || ' := vRefCode;' ||
					cchr10;
		END IF;
		IF psaverecord
		THEN
			vret := vret || '    poRow.' || pimportsettings.codecolumn ||
					' := coalesce(vCode, poRow.' || pimportsettings.codecolumn || ');' || cchr10;
		ELSE
			vret := vret || '    poRow.' || pimportsettings.codecolumn || ' := vCode;' || cchr10;
		END IF;
	
		vret := vret || '  end if;  ' || cchr10;
	
		IF pbranchexists
		THEN
			vret := vret || '  begin' || cchr10;
			vret := vret || '    poRow.Branch := cBranch;' || cchr10;
			vret := vret || '  exception' || cchr10;
			vret := vret || '    when others then' || cchr10;
			vret := vret || '      s.err(cMethodName);' || cchr10;
			vret := vret || '  end;' || cchr10;
		END IF;
	
		vret := vret || '  t.Leave(cMethodName);' || cchr10;
		vret := vret || '  exception  ' || cchr10;
		vret := vret || '    when others then' || cchr10;
		vret := vret || '      Error.Save(cMethodName);' || cchr10;
		vret := vret || '      raise;       ' || cchr10;
		vret := vret || '  end;' || cchr10;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getsaverowstr(pimportsettings typeimportsettings) RETURN CLOB IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetSaveRowStr';
		vacolumns        typecolumnarray;
		vapkcolumns      typecolumnarray;
		vauicolumns      typecolumnarray;
		vret             CLOB;
		vupdatecolumnstr CLOB;
	BEGIN
		vacolumns   := getcolumns(pimportsettings.tablename);
		vapkcolumns := getpkcolumns(pimportsettings.tablename);
	
		vret := ' procedure SaveRow (poRow in out nocopy typeRow, pSettings ContractExchangeTools.typeImportSettings, pActionType in ContractExchangeTools.typeActionType) is ' ||
				cchr10;
		vret := vret || '  cMethodName   constant varchar2(100):= ''SaveRow'';' || cchr10;
		vret := vret || '  cBranch       constant number := Seance.GetBranch();' || cchr10;
		vret := vret || '  cChr10        constant char(1):= Chr(10);' || cchr10;
	
		vret := vret || '  vSQL          varchar2(32767);' || cchr10;
	
		vret := vret || 'begin' || cchr10;
		vret := vret ||
				'if pActionType in (ContractExchangeTools.cActType_MTExists_Update, ContractExchangeTools.cActType_LocExists_Update, ContractExchangeTools.cActType_NotExists_Add) then' ||
				cchr10;
	
		IF vapkcolumns.count = 0
		THEN
			vauicolumns      := getuicolumns(pimportsettings.tablename, pimportsettings.codecolumn);
			vupdatecolumnstr := getupdatecolumnstr(pimportsettings.tablename
												  ,vacolumns
												  ,vauicolumns);
		END IF;
		IF vapkcolumns.count > 0
		THEN
			vret := vret || '   vSQL := ''merge into ' || pimportsettings.tablename || ' t ' ||
					cchr10;
			vret := vret || '          using dual' || cchr10;
			vret := vret || '             on (' ||
					getmergeonstr(pimportsettings.tablename, vapkcolumns) || ')'' || cChr10;' ||
					cchr10;
			vret := vret || '  vSQL := vSQL || '' when matched then'' || cChr10;' || cchr10;
			vret := vret || '  vSQL := vSQL || ''   update set ' ||
					getupdatecolumnstr(pimportsettings.tablename, vacolumns, vapkcolumns) ||
					''' || cChr10;' || cchr10;
			vret := vret || '  vSQL := vSQL || '' when not matched then'' || cChr10;' || cchr10;
			vret := vret || '  vSQL := vSQL || ''   insert (' ||
					getinsertcolumnstr(pimportsettings.tablename, vacolumns) || ')'';' || cchr10;
			vret := vret || '  vSQL := vSQL || ''   values (' ||
					getinsertbindstr(pimportsettings.tablename, vacolumns) || ')'';' || cchr10;
			vret := vret || '  s.say(''SQL=''||vSQL);' || cchr10;
			vret := vret || '  begin  ' || cchr10;
			vret := vret || '    execute immediate vSQL using ' ||
					getpkvaluesstr(pimportsettings.tablename, vapkcolumns) || ', ' ||
					getvaluesstr(pimportsettings.tablename, vacolumns, TRUE, vapkcolumns) || ', ' ||
					getvaluesstr(pimportsettings.tablename, vacolumns) || ';' || cchr10;
			vret := vret || '  exception' || cchr10;
			vret := vret || '    when others then' || cchr10;
			vret := vret || '      s.err(''merge'');' || cchr10;
			IF pimportsettings.codecolumn IS NOT NULL
			THEN
				vret := vret ||
						'      ContractExchangeTools.Log(ContractExchangeTools.cLogType_Error, ''' ||
						cpackagename || ''', ''' || pimportsettings.objectname || ''', poRow.' ||
						pimportsettings.codecolumn || ', vActionType, ''Save Error: ''|| sqlerrm);' ||
						cchr10;
			ELSE
				vret := vret ||
						'      ContractExchangeTools.Log(ContractExchangeTools.cLogType_Error, ''' ||
						cpackagename || ''', ''' || pimportsettings.objectname ||
						''', ''-'', vActionType, ''Save Error: ''|| sqlerrm);' || cchr10;
			END IF;
			vret := vret || '  end; ' || cchr10;
		
		ELSIF vauicolumns.count > 0
		THEN
			IF vupdatecolumnstr IS NOT NULL
			THEN
				vret := vret || '   vSQL := ''merge into ' || pimportsettings.tablename || ' t ' ||
						cchr10;
				vret := vret || '          using dual' || cchr10;
				vret := vret || '             on (' ||
						getmergeonstr(pimportsettings.tablename, vauicolumns) || ')'' || cChr10;' ||
						cchr10;
				vret := vret || '  vSQL := vSQL || '' when matched then'' || cChr10;' || cchr10;
				vret := vret || '  vSQL := vSQL || ''   update set ' || vupdatecolumnstr ||
						''' || cChr10;' || cchr10;
				vret := vret || '  vSQL := vSQL || '' when not matched then'' || cChr10;' || cchr10;
				vret := vret || '  vSQL := vSQL || ''   insert (' ||
						getinsertcolumnstr(pimportsettings.tablename, vacolumns) || ')'';' ||
						cchr10;
				vret := vret || '  vSQL := vSQL || ''   values (' ||
						getinsertbindstr(pimportsettings.tablename, vacolumns) || ')'';' || cchr10;
				vret := vret || '  s.say(''SQL=''||vSQL);' || cchr10;
				s.say('bind1: ' || getpkvaluesstr(pimportsettings.tablename, vauicolumns));
				s.say('bind2: ' ||
					  getvaluesstr(pimportsettings.tablename, vacolumns, TRUE, vauicolumns));
				s.say('bind3: ' || getvaluesstr(pimportsettings.tablename, vacolumns));
				vret := vret || '  begin  ' || cchr10;
				vret := vret || '    execute immediate vSQL using ' ||
						getpkvaluesstr(pimportsettings.tablename, vauicolumns) || ', ' ||
						getvaluesstr(pimportsettings.tablename, vacolumns, TRUE, vauicolumns) || ', ' ||
						getvaluesstr(pimportsettings.tablename, vacolumns) || ';' || cchr10;
				vret := vret || '  exception' || cchr10;
				vret := vret || '    when others then' || cchr10;
				vret := vret || '      s.err(''merge'');' || cchr10;
				IF pimportsettings.codecolumn IS NOT NULL
				THEN
					vret := vret ||
							'      ContractExchangeTools.Log(ContractExchangeTools.cLogType_Error, ''' ||
							cpackagename || ''', ''' || pimportsettings.objectname || ''', poRow.' ||
							pimportsettings.codecolumn ||
							', vActionType, ''Save Error: ''||sqlerrm);' || cchr10;
				ELSE
					vret := vret ||
							'      ContractExchangeTools.Log(ContractExchangeTools.cLogType_Error, ''' ||
							cpackagename || ''', ''' || pimportsettings.objectname ||
							''', ''-'', vActionType, ''Save Error: ''|| sqlerrm);' || cchr10;
				END IF;
				vret := vret || '  end; ' || cchr10;
			ELSE
			
				vret := vret || '  vSQL := vSQL || ''   insert into ' || pimportsettings.tablename || ' (' ||
						getinsertcolumnstr(pimportsettings.tablename, vacolumns) || ')'';' ||
						cchr10;
				vret := vret || '  vSQL := vSQL || ''   values (' ||
						getinsertbindstr(pimportsettings.tablename, vacolumns) || ')'';' || cchr10;
				vret := vret || '  s.say(''SQL=''||vSQL);' || cchr10;
				vret := vret || '  begin  ' || cchr10;
				vret := vret || '    execute immediate vSQL using ' ||
						getvaluesstr(pimportsettings.tablename, vacolumns) || ';' || cchr10;
				vret := vret || '  exception' || cchr10;
				vret := vret || '    when others then' || cchr10;
				vret := vret || '      s.err(''insert'');' || cchr10;
				vret := vret || '      if sqlerrm not like ''%unique constraint%'' then' || cchr10;
				IF pimportsettings.codecolumn IS NOT NULL
				THEN
					vret := vret ||
							'        ContractExchangeTools.Log(ContractExchangeTools.cLogType_Error, ''' ||
							cpackagename || ''', ''' || pimportsettings.objectname || ''', poRow.' ||
							pimportsettings.codecolumn ||
							', vActionType, ''Save Error: ''||sqlerrm);' || cchr10;
				ELSE
					vret := vret ||
							'      ContractExchangeTools.Log(ContractExchangeTools.cLogType_Error, ''' ||
							cpackagename || ''', ''' || pimportsettings.objectname ||
							''', ''-'', vActionType, ''Save Error: ''|| sqlerrm);' || cchr10;
				END IF;
				vret := vret || '      end if;' || cchr10;
				vret := vret || '  end; ' || cchr10;
			END IF;
		
		ELSE
			vret := vret || '  vSQL := vSQL || ''   insert into ' || pimportsettings.tablename || ' (' ||
					getinsertcolumnstr(pimportsettings.tablename, vacolumns) || ')'';' || cchr10;
			vret := vret || '  vSQL := vSQL || ''   values (' ||
					getinsertbindstr(pimportsettings.tablename, vacolumns) || ')'';' || cchr10;
			vret := vret || '  s.say(''SQL=''||vSQL);' || cchr10;
			vret := vret || '  begin  ' || cchr10;
			vret := vret || '    execute immediate vSQL using ' ||
					getvaluesstr(pimportsettings.tablename, vacolumns) || ';' || cchr10;
			vret := vret || '  exception' || cchr10;
			vret := vret || '    when others then' || cchr10;
			vret := vret || '      s.err(''insert'');' || cchr10;
			vret := vret ||
					'      ContractExchangeTools.Log(ContractExchangeTools.cLogType_Error, ''' ||
					cpackagename || ''', ''' || pimportsettings.objectname || ''', poRow.' ||
					pimportsettings.codecolumn || ', vActionType, ''Save Error: ''||sqlerrm);' ||
					cchr10;
			vret := vret || '  end; ' || cchr10;
		END IF;
	
		vret := vret || 'end if;           ' || cchr10;
		vret := vret || '  t.Leave(cMethodName);' || cchr10;
		vret := vret || 'exception  ' || cchr10;
		vret := vret || '  when others then' || cchr10;
		vret := vret || '    Error.Save(cMethodName);' || cchr10;
		vret := vret || '    raise;       ' || cchr10;
		vret := vret || 'end;' || cchr10;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION export2xml
	(
		psettings   typeexportsettings
	   ,puseroottag BOOLEAN := TRUE
	   ,pcount      NUMBER := NULL
	) RETURN xmltype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.Export2XML';
		vxml xmltype;
	
	BEGIN
		vxml := export_(psettings, pcount);
		IF puseroottag
		   AND psettings.objectname IS NOT NULL
		THEN
			EXECUTE IMMEDIATE 'select XMLElement("' || upper(psettings.objectname) ||
							  '", :1) from dual'
				INTO vxml
				USING vxml;
		END IF;
		t.leave(cmethodname);
		RETURN vxml;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION export2xml
	(
		ppackagename VARCHAR2
	   ,ptablename   VARCHAR2
	   ,pobjectname  VARCHAR2 := NULL
	   ,pwhere       VARCHAR2 := NULL
	   ,porder       VARCHAR2 := NULL
	) RETURN xmltype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.Export2XML';
		vsettings typeexportsettings;
	BEGIN
		vsettings.packagename := ppackagename;
		vsettings.tablename   := ptablename;
		vsettings.objectname  := pobjectname;
		vsettings.whereclause := pwhere;
		vsettings.orderclause := porder;
	
		RETURN export2xml(vsettings, TRUE, NULL);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE log
	(
		plogtype     typelogtype
	   ,ppackagename VARCHAR2
	   ,pobjectname  VARCHAR2
	   ,psourcecode  VARCHAR2
	   ,pactiontype  typeactiontype := NULL
	   ,pmessage     VARCHAR2 := NULL
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.Log';
	BEGIN
		t.enter(cmethodname, pobjectname || ': ' || psourcecode || ', ' || pmessage);
		IF psourcecode IS NOT NULL
		THEN
			/*INSERT INTO tcontractimportlog
                (logtype
                ,packagename
                ,objectname
                ,sourcecode
                ,actiontype
                ,message)
            VALUES
                (plogtype
                ,ppackagename
                ,pobjectname
                ,psourcecode
                ,pactiontype
                ,pmessage);*/
			NULL;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE addmatchingrow
	(
		ppackagename VARCHAR2
	   ,ptablename   VARCHAR2
	   ,pcolumnname  VARCHAR2
	   ,psourcecode  typesrccode
	   ,pdestcode    typedestcode
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.AddMatchingRow';
		cbranch     CONSTANT NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethodname
			   ,ppackagename || ', ' || ptablename || ', ' || pcolumnname || ', ' || psourcecode || ', ' ||
				pdestcode);
		/*INSERT INTO tcontractimportmatching
            (branch
            ,packagename
            ,tablename
            ,columnname
            ,sourcecode
            ,destcode)
        VALUES
            (cbranch
            ,upper(ppackagename)
            ,upper(ptablename)
            ,upper(pcolumnname)
            ,psourcecode
            ,pdestcode);*/
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE deletematchingrows
	(
		ppackagename VARCHAR2 := NULL
	   ,ptablename   VARCHAR2 := NULL
	   ,pcolumnname  VARCHAR2 := NULL
	   ,psourcecode  typesrccode := NULL
	   ,pdestcode    typedestcode := NULL
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.DeleteMatchingRows';
		cbranch     CONSTANT NUMBER := seance.getbranch();
	BEGIN
		t.enter(cmethodname
			   ,ppackagename || ', ' || ptablename || ', ' || pcolumnname || ', ' || psourcecode || ', ' ||
				pdestcode);
		/*DELETE FROM tcontractimportmatching
        WHERE  branch = cbranch
        AND    tablename = coalesce(upper(ptablename), tablename)
        AND    columnname = coalesce(upper(pcolumnname), columnname)
        AND    packagename = coalesce(upper(ppackagename), packagename)
        AND    sourcecode = coalesce(psourcecode, sourcecode)
        AND    destcode = coalesce(pdestcode, destcode);*/
		t.leave(cmethodname, 'deleted ' || SQL%ROWCOUNT);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE clearmatchingtable IS
	BEGIN
		t.enter(cpackagename || '.ClearMatchingTable');
		EXECUTE IMMEDIATE 'truncate table tContractImportMatching';
	END;

	FUNCTION getdestcode
	(
		ptablename   VARCHAR2
	   ,pcolumnname  VARCHAR2
	   ,psourcecode  typesrccode
	   ,ppackagename VARCHAR2 := NULL
	) RETURN typedestcode IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetDestCode';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vret typedestcode;
	BEGIN
		t.enter(cmethodname
			   ,'PackageName=' || ppackagename || ', TableName=' || ptablename || ', ColumnName=' ||
				pcolumnname || ', SourceCode=' || psourcecode);
		/*   SELECT destcode
        INTO   vret
        FROM   tcontractimportmatching
        WHERE  branch = cbranch
        AND    tablename = upper(ptablename)
        AND    columnname = upper(pcolumnname)
        AND    ((ppackagename IS NULL) OR (packagename = upper(ppackagename)))
        AND    sourcecode = psourcecode;*/
		t.leave(cmethodname, 'return ' || to_char(vret));
		RETURN vret;
	EXCEPTION
		WHEN no_data_found THEN
			t.leave(cmethodname, 'return null');
			RETURN NULL;
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE logevent
	(
		pobjectname VARCHAR2
	   ,pkey        VARCHAR2
	   ,paction     IN NUMBER
	   ,pimportmode custom_contractexchangetools.typeimportmode
	   ,pfilename   VARCHAR2
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.LogEvent';
	BEGIN
		t.enter(cmethodname
			   ,'ObjectName=' || pobjectname || ', Action=' || paction || ', Key=' || pkey);
	
		a4mlog.cleanparamlist;
	
		a4mlog.addparamrec('Import Mode', getimportmodedescription(pimportmode), NULL);
		a4mlog.addparamrec('File Name', pfilename, NULL);
	
		a4mlog.logobject(object.gettype(pobjectname)
						,pkey
						,'Import ' ||
						 service.iif(pfilename IS NOT NULL, ' [' || pfilename || ']', NULL)
						,paction
						,a4mlog.putparamlist);
	
		a4mlog.cleanparamlist;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getlogtypedescription
	(
		plogtype          typelogtype
	   ,pshortdescription BOOLEAN := FALSE
	) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetLogTypeDescription';
		vret VARCHAR2(100);
	BEGIN
		IF pshortdescription
		THEN
			CASE plogtype
				WHEN clogtype_msg THEN
					vret := 'M';
				WHEN clogtype_warning THEN
					vret := 'W';
				WHEN clogtype_error THEN
					vret := 'E';
				ELSE
					error.raiseerror('Unknown code of log record type [' || plogtype || ']');
			END CASE;
		ELSE
			CASE plogtype
				WHEN clogtype_msg THEN
					vret := 'Message';
				WHEN clogtype_warning THEN
					vret := 'Warning';
				WHEN clogtype_error THEN
					vret := 'Error';
				ELSE
					error.raiseerror('Unknown code of log record type [' || plogtype || ']');
			END CASE;
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethodname);
			RETURN NULL;
	END;

	FUNCTION getactiontypedescription
	(
		pactiontype       typeactiontype
	   ,pshortdescription BOOLEAN := FALSE
	) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetActionTypeDescription';
		vret VARCHAR2(100);
	BEGIN
		error.clear;
		IF pshortdescription
		THEN
			CASE pactiontype
				WHEN NULL THEN
					vret := '';
				WHEN cacttype_unknown THEN
					vret := '?';
				WHEN cacttype_stop THEN
					vret := 'X';
				WHEN cacttype_notexists_add THEN
					vret := '+';
				WHEN cacttype_mtexists_skip THEN
					vret := 'M/-';
				WHEN cacttype_locexists_skip THEN
					vret := 'L/-';
				WHEN cacttype_mtexists_update THEN
					vret := 'M/U';
				WHEN cacttype_locexists_update THEN
					vret := 'L/U';
				
				WHEN cacttype_matching THEN
					vret := 'C';
				ELSE
					vret := '';
				
			END CASE;
		ELSE
			CASE pactiontype
				WHEN NULL THEN
					vret := '';
				WHEN cacttype_unknown THEN
					vret := 'Data not validated. Import actions not defined';
				WHEN cacttype_stop THEN
					vret := 'Identifier exists. Import stopped';
				WHEN cacttype_notexists_add THEN
					vret := 'New record';
				WHEN cacttype_mtexists_skip THEN
					vret := 'Record is found by correspondence table';
				WHEN cacttype_locexists_skip THEN
					vret := 'Record is found by locator';
				WHEN cacttype_mtexists_update THEN
					vret := 'Record is found by correspondence table. Update';
				WHEN cacttype_locexists_update THEN
					vret := 'Record is found by locator. Update';
				
				WHEN cacttype_matching THEN
					vret := 'Search for correspondence';
				ELSE
					vret := '';
				
			END CASE;
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethodname);
			RETURN NULL;
	END;

	FUNCTION resultdialog(pcontinue BOOLEAN := FALSE) RETURN NUMBER IS
		cmethodname   CONSTANT VARCHAR2(100) := cpackagename || '.ResultDialog';
		chandlername  CONSTANT VARCHAR2(100) := cpackagename || '.ResultDialogHandler';
		cdialogwidth  CONSTANT NUMBER := 80;
		cdialogheight CONSTANT NUMBER := 15;
		cbuttonwidth  CONSTANT NUMBER := 10;
	
		vdialog   NUMBER;
		vmenu     NUMBER;
		vmenufile NUMBER;
		vcaption  VARCHAR(100);
	BEGIN
		IF pcontinue
		THEN
			vcaption := 'Data parsing results';
		ELSE
			vcaption := 'Import results';
		END IF;
		vdialog := dialog.new(vcaption
							 ,0
							 ,0
							 ,cdialogwidth
							 ,cdialogheight
							 ,presizable    => TRUE
							 ,pextid        => cpackagename || '.ResultDialog');
		dialog.setdialogpre(vdialog, chandlername);
	
		vmenu     := mnu.new(vdialog);
		vmenufile := mnu.submenu(vmenu, 'File', '');
		mnu.item(vmenufile, 'mniSaveAs', 'Save as...', 0, 0, 'Save results to file');
		dialog.setitempre(vdialog, 'mniSaveAs', chandlername);
	
		dialog.list(vdialog, 'lstResult', 1, 2, cdialogwidth - 3, cdialogheight - 4, '');
		dialog.listaddfield(vdialog, 'lstResult', 'LogType', 'C', 1, 1);
		dialog.listaddfield(vdialog, 'lstResult', 'PackageName', 'C', 15, 0);
		dialog.listaddfield(vdialog, 'lstResult', 'Object', 'C', 15, 1);
		dialog.listaddfield(vdialog, 'lstResult', 'Code', 'C', 8, 1);
		dialog.listaddfield(vdialog, 'lstResult', 'Message', 'C', 40, 1);
		dialog.setcaption(vdialog, 'lstResult', 'Type~Object~ID~Message');
	
		dialog.setanchor(vdialog, 'lstResult', dialog.anchor_all);
		IF pcontinue
		THEN
			dialog.button(vdialog
						 ,'btnImport'
						 ,cdialogwidth / 2 - cbuttonwidth - 2
						 ,cdialogheight
						 ,cbuttonwidth
						 ,'Import'
						 ,0
						 ,0
						 ,'Continue import'
						 ,panchor => dialog.anchor_bottom);
			dialog.setitempre(vdialog, 'btnImport', chandlername);
			dialog.button(vdialog
						 ,'btnCancel'
						 ,cdialogwidth / 2 + 2
						 ,cdialogheight
						 ,cbuttonwidth
						 ,'Cancel'
						 ,dialog.cmcancel
						 ,0
						 ,'Interrupt import'
						 ,panchor => dialog.anchor_bottom);
			dialog.button(vdialog
						 ,'btnClose'
						 ,(cdialogwidth - cbuttonwidth) / 2
						 ,cdialogheight
						 ,cbuttonwidth
						 ,'OK'
						 ,dialog.cmcancel
						 ,0
						 ,'Close'
						 ,panchor => dialog.anchor_bottom);
			dialog.setvisible(vdialog, 'btnClose', FALSE);
		ELSE
			dialog.button(vdialog
						 ,'btnClose'
						 ,(cdialogwidth - cbuttonwidth) / 2
						 ,cdialogheight
						 ,cbuttonwidth
						 ,'OK'
						 ,dialog.cmcancel
						 ,0
						 ,'Close'
						 ,panchor => dialog.anchor_bottom);
		END IF;
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			s.err(cmethodname);
			IF vdialog IS NOT NULL
			THEN
				RETURN vdialog;
			END IF;
	END;

	PROCEDURE showresultdialog(pcontinue BOOLEAN := FALSE) IS
	BEGIN
		dialog.exec(resultdialog(pcontinue));
	END;

	PROCEDURE resultdialoghandler
	(
		pwhat     IN CHAR
	   ,pdialog   IN NUMBER
	   ,pitemname IN CHAR
	   ,pcmd      IN NUMBER
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ResultDialogHandler';
		vcount           NUMBER;
		vfilename        VARCHAR2(255);
		vhandle          NUMBER;
		vneedparenthesis BOOLEAN;
	
		FUNCTION format
		(
			pstr    VARCHAR2
		   ,plength NUMBER
		) RETURN VARCHAR2 IS
		BEGIN
			RETURN rpad(substr(pstr, 1, service.iif(length(pstr) > plength, plength - 3, plength)) ||
						service.iif(length(pstr) > plength, '...', '')
					   ,plength
					   ,' ');
		END;
	
		PROCEDURE filllist IS
		BEGIN
			dialog.listclear(pdialog, 'lstResult');
			/*FOR i IN (SELECT * FROM tcontractimportlog ORDER BY no)
            LOOP
            
                vneedparenthesis := i.actiontype IS NOT NULL AND i.message IS NOT NULL;
                dialog.listaddrecord(pdialog
                                    ,'lstResult'
                                    ,getlogtypedescription(i.logtype, TRUE) || '~' ||
                                     i.packagename || '~' || i.objectname || '~' || i.sourcecode || '~' ||
                                     getactiontypedescription(i.actiontype) ||
                                     service.iif(vneedparenthesis, ' [', '') || i.message ||
                                     service.iif(vneedparenthesis, ']', '')
                                    ,0
                                    ,0);
            END LOOP;*/
		
		END;
	
		PROCEDURE savereport IS
		BEGIN
			vfilename := term.filedialog('Save result to file'
										,FALSE
										,NULL
										,'*.txt *.*'
										,pisencode            => TRUE
										,pdefencode           => nvl(term.getlastencode
																	,referenceencode.getdefault));
			s.say('FileName=' || vfilename);
			IF vfilename IS NOT NULL
			THEN
				IF instr(vfilename, '.') = 0
				THEN
					vfilename := vfilename || '.txt';
				END IF;
				BEGIN
					IF term.getlastencode IS NOT NULL
					THEN
						vhandle := term.fileopenwrite(vfilename, NULL, term.getlastencode);
						/*FOR i IN (SELECT DISTINCT *
                                  FROM   tcontractimportlog
                                  ORDER  BY packagename
                                           ,objectname
                                           ,sourcecode
                                           ,no)
                        LOOP
                            term.writerecord(vhandle
                                            ,format(getlogtypedescription(i.logtype, FALSE), 20) || '| ' ||
                                             format(i.packagename, 40) || ' | ' ||
                                             format(i.objectname, 30) || ' | ' ||
                                             format(i.sourcecode, 10) || ' | ' || i.message);
                        END LOOP;*/
						term.close(vhandle);
						service.saymsg(pdialog, 'Message', 'File saved');
					ELSE
						service.saymsg(pdialog, 'Warning!', 'Encoding must be specified');
					END IF;
				EXCEPTION
					WHEN term.error THEN
						service.saymsg(pdialog, 'Warning!', term.errorname || '~' || vfilename);
						term.closeabort(vhandle);
					WHEN OTHERS THEN
						service.sayerr(pdialog, 'Error!');
						term.closeabort(vhandle);
				END;
			END IF;
		END;
	
	BEGIN
		s.say(cmethodname || ': start [' || pwhat || ', ' || pdialog || ', ' || pitemname || ', ' || pcmd || ']');
		IF pwhat = dialog.wt_dialogpre
		THEN
			filllist;
		ELSIF pwhat = dialog.wtitempre
		THEN
			IF pitemname = upper('mniSaveAs')
			THEN
				-- SELECT COUNT(1) INTO vcount FROM tcontractimportlog;
				s.say(cmethodname || ': SaveAs: count=' || vcount);
				IF vcount > 0
				THEN
					savereport;
				ELSE
					service.saymsg(pdialog, 'Warning!', 'No data to be saved');
				END IF;
			ELSIF pitemname = upper('btnImport')
			THEN
				DECLARE
					vcontinue BOOLEAN;
				BEGIN
					IF existsmethod(simportsettings.packagename
								   ,simportsettings.objectname || cpostfiximport
								   ,'/in:Y/in:S/in:B/ret:E')
					THEN
						EXECUTE IMMEDIATE ' begin ' || simportsettings.packagename || '.' ||
										  simportsettings.objectname || cpostfiximport ||
										  '(:1, :2, :3); end;'
							USING sxml, simportsettings, TRUE;
					ELSIF existsmethod(simportsettings.packagename
									  ,simportsettings.objectname || cpostfiximport
									  ,'/in:Y/in:S/in:B/out:B/ret:E')
					THEN
						EXECUTE IMMEDIATE ' begin ' || simportsettings.packagename || '.' ||
										  simportsettings.objectname || cpostfiximport ||
										  '(:1, :2, :3, :4); end;'
							USING sxml, simportsettings, TRUE, OUT vcontinue;
					ELSE
						importfromxml(sxml, simportsettings, TRUE, TRUE, TRUE);
					END IF;
					logevent(contract.object_name
							,'IMPORT|' || simportsettings.objectname
							,a4mlog.act_execend
							,simportsettings.importmode
							,NULL);
					COMMIT;
					htools.message('Import', 'Import completed');
					dialog.setcaption(pdialog, 'Import result');
					filllist;
					dialog.setvisible(pdialog, 'btnImport', FALSE);
					dialog.setvisible(pdialog, 'btnCancel', FALSE);
					dialog.setvisible(pdialog, 'btnClose', TRUE);
				END;
			
			END IF;
		END IF;
	
	END;

	FUNCTION getvalue
	(
		pxml  IN xmltype
	   ,ppath IN VARCHAR
	) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetValue';
		vret VARCHAR2(32000);
	BEGIN
		t.enter(cmethodname, ppath);
		vret := xmltools.getvalue(pxml, ppath);
		say(cmethodname || ': return ' || vret);
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getclobvalue
	(
		pxml  IN xmltype
	   ,ppath IN VARCHAR
	) RETURN VARCHAR2 IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetClobValue';
		vclob CLOB;
	BEGIN
		t.enter(cmethodname, ppath);
		vclob := xmltools.getlvalue(pxml, ppath);
		say(cmethodname || ': length=' || length(vclob));
		RETURN vclob;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE importdynasqlblock(pxml xmltype) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ImportDynaSQLBlock';
		vsrcblockcode  NUMBER;
		vdestblockcode NUMBER;
	
		vneedaddmatching BOOLEAN;
	BEGIN
		t.enter(cmethodname);
		sayxml(pxml, 'Block');
	
		vsrcblockcode := custom_dynasql.lookforouteridandcode(pxml).code;
		t.var('SrcBlockCode', vsrcblockcode);
	
		vdestblockcode   := getdestcode(cdynasqltable, 'Code', vsrcblockcode);
		vneedaddmatching := vdestblockcode IS NULL;
	
		custom_dynasql.importsql(pxml.getclobval
								,FALSE
								,vdestblockcode
								,pautonomoustransaction => FALSE);
	
		IF vneedaddmatching
		   AND vdestblockcode IS NOT NULL
		THEN
			addmatchingrow(cpackagename, cdynasqltable, 'Code', vsrcblockcode, vdestblockcode);
		END IF;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE importdynasqlblocks(pxml xmltype) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ImportDynaSQLBlocks';
	BEGIN
		t.enter(cmethodname);
	
		FOR dsblock IN (SELECT VALUE(p) xml
						FROM   TABLE(xmlsequence(pxml.extract('//' || cdsblockstag || cdsblocktag))) p)
		LOOP
			importdynasqlblock(dsblock.xml);
		END LOOP;
	
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE importparams
	(
		pxml             xmltype
	   ,psettings        typeimportsettings
	   ,pparamobjecttype typeparamobjecttype := NULL
	   ,psaverecord      BOOLEAN := TRUE
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ImportParams';
		cbranch     CONSTANT NUMBER := seance.getbranch;
		vrow             tcontractotherparameters%ROWTYPE;
		vparamobjecttype typeparamobjecttype := coalesce(pparamobjecttype
														,addsettings_getparametersobjecttype(psettings));
	BEGIN
	
		t.enter(cmethodname, 'ParametersObjectType=' || vparamobjecttype);
		BEGIN
			SELECT objecttype
			INTO   vrow.objecttype
			FROM   tcontractotherobjecttype
			WHERE  branch = cbranch
			AND    objectsign = vparamobjecttype;
		EXCEPTION
			WHEN no_data_found THEN
				error.raiseerror('Import parameters: invalid object type [' || vparamobjecttype || ']');
		END;
		FOR param IN (SELECT VALUE(p) xml
					  FROM   TABLE(xmlsequence(pxml.extract('//' || cparamstag || '/' || cparamtag))) p)
		LOOP
			vrow.objectno := getvalue(param.xml, '//' || cparamtag || '/' || cparamobjectnotag);
			t.var('ObjectNo[1]', vrow.objectno);
			vrow.key   := getvalue(param.xml, '//' || cparamtag || '/' || cparamkeytag);
			vrow.value := getvalue(param.xml, '//' || cparamtag || '/' || cparamvaluetag);
		
			IF existsmethod(psettings.packagename
						   ,psettings.objectname || cpostfixvalidateparam
						   ,'/inout:S/ret:E')
			THEN
				EXECUTE IMMEDIATE 'begin ' || psettings.packagename || '.' || psettings.objectname ||
								  cpostfixvalidateparam || '(:inoutRow); end;'
					USING IN OUT vrow;
			ELSE
				vrow.objectno := getdestcode(psettings.tablename
											,psettings.codecolumn
											,vrow.objectno);
				t.var('ObjectNo[2]', vrow.objectno);
			END IF;
		
			IF psaverecord
			THEN
				MERGE INTO tcontractotherparameters p
				USING dual
				ON (p.branch = cbranch AND p.objecttype = vrow.objecttype AND p.objectno = vrow.objectno AND p.key = vrow.key)
				WHEN MATCHED THEN
					UPDATE SET VALUE = vrow.value
				WHEN NOT MATCHED THEN
					INSERT
						(branch
						,objecttype
						,objectno
						,key
						,VALUE)
					VALUES
						(cbranch
						,vrow.objecttype
						,vrow.objectno
						,vrow.key
						,vrow.value);
			END IF;
		
		END LOOP;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE import_
	(
		pxml             xmltype
	   ,psettings        typeimportsettings
	   ,psaverecord      BOOLEAN := TRUE
	   ,pparentsettings  typeimportsettings := cemptyimportsettings
	   ,ocontinue        OUT BOOLEAN
	   ,pshowprogressbar BOOLEAN := FALSE
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.Import_';
		vmainobjecttag        VARCHAR2(1000) := upper(coalesce(psettings.objectname
															  ,psettings.tablename));
		vtabletagname         VARCHAR2(100) := upper(psettings.tablename);
		vsettings             typeimportsettings := psettings;
		vacolumnarray         typecolumnarray;
		vblocksql             CLOB;
		vvaluepart            VARCHAR2(4000);
		vvaluepartclob        CLOB;
		vallcount             NUMBER;
		vcount                NUMBER;
		voldcode              NUMBER;
		vsequencename         VARCHAR2(100);
		vcodecolumnname       VARCHAR2(100);
		vchildsettings        typeimportsettings;
		vpos                  NUMBER;
		vparametersobjecttype typeparamobjecttype;
		vpath                 VARCHAR2(1000);
		vxmlvalue             xmltype;
	BEGIN
		t.enter(cmethodname
			   ,'TagName=' || vtabletagname || ', TableName=' || psettings.tablename ||
				', ShowProgressBar=' || htools.b2s(pshowprogressbar));
	
		IF upper(psettings.tablename) = 'TDYNASQL'
		THEN
			RETURN;
		END IF;
		sayxml(pxml
			  ,service.iif(pparentsettings.tablename IS NOT NULL, 'Child XML', 'Main XML')
			  ,1000);
	
		clear;
		--clearactiontypes4table(psettings.tablename);
	
		setcurrentsettings(vsettings);
		setcurrentparentsettings(pparentsettings);
	
		vcodecolumnname := coalesce(addsettings_getcodecolumn(vsettings), vsettings.codecolumn);
		vsequencename   := addsettings_getsequencename(vsettings);
	
		vacolumnarray := getcolumns(vsettings.tablename);
		fillpkcolumns(vsettings.tablename, FALSE, vcodecolumnname);
	
		IF pshowprogressbar
		THEN
			vallcount := 0;
			FOR line IN (SELECT VALUE(p) xml
						 FROM   TABLE(xmlsequence(pxml.extract('//' || vtabletagname || '/' ||
															   upper(vsettings.tablename) || '_ROW'))) p)
			LOOP
				vallcount := vallcount + 1;
			END LOOP;
			t.var('AllCount', vallcount);
			IF vallcount > 0
			THEN
				dialog.percentbox('INIT'
								 ,vallcount
								 ,coalesce(vsettings.referencename, vsettings.objectname));
			END IF;
		END IF;
	
		vcount := 0;
		FOR line IN (SELECT VALUE(p) xml
					 FROM   TABLE(xmlsequence(pxml.extract('//' || vtabletagname || '/' ||
														   upper(vsettings.tablename) || '_ROW'))) p)
		LOOP
		
			IF line.xml IS NOT NULL
			THEN
				s.say('------------------------');
				sayxml(line.xml);
				vblocksql := 'declare' || cchr10;
				vblocksql := vblocksql || 'subtype typeRow is ' || vsettings.tablename ||
							 '%RowType;' || cchr10;
				vblocksql := vblocksql || 'vRow typeRow;' || cchr10;
				IF vsettings.refcodecolumn IS NOT NULL
				THEN
					vblocksql := vblocksql || 'vSrcRefCode ContractExchangeTools.typeSrcCode;' ||
								 cchr10;
				END IF;
				vblocksql := vblocksql || 'vActionType ContractExchangeTools.typeActionType;' ||
							 cchr10;
				IF NOT existsmethod(vsettings.packagename
								   ,vsettings.objectname || cpostfixvalidate
								   ,'/inout:S/in:I/out:I/ret:E')
				THEN
					vblocksql := vblocksql || getvalidaterowstr(vsettings
															   ,pparentsettings
															   ,branchexists(vacolumnarray)
															   ,psaverecord);
				END IF;
				IF psaverecord
				   AND NOT existsmethod(vsettings.packagename
									   ,vsettings.objectname || cpostfixsaverow
									   ,'/inout:S/in:I/ret:E')
				THEN
					vblocksql := vblocksql || getsaverowstr(vsettings);
				END IF;
				vblocksql := vblocksql || 'begin' || cchr10 || '  null;' || cchr10;
				FOR i IN 1 .. vacolumnarray.count
				LOOP
					t.var('column' || i
						 ,vacolumnarray(i).column_name || '[' || vacolumnarray(i).data_type || ']');
					vpath := '//' || upper(vsettings.tablename) || '_ROW/' || vacolumnarray(i)
							.column_name;
				
					IF vacolumnarray(i).data_type = 'NUMBER'
					THEN
						vvaluepart := getvalue(line.xml, vpath);
						IF vvaluepart IS NOT NULL
						THEN
							vblocksql := vblocksql || '  vRow.' || vacolumnarray(i).column_name ||
										 ' := ';
							vblocksql := vblocksql || vvaluepart || ';' || cchr10;
							IF vacolumnarray(i).column_name = upper(vsettings.codecolumn)
							THEN
								voldcode := to_number(vvaluepart);
								t.var('OldCode', voldcode);
							END IF;
						END IF;
					ELSIF vacolumnarray(i).data_type IN ('VARCHAR', 'VARCHAR2', 'CHAR')
					THEN
						vvaluepart := getvalue(line.xml, vpath);
						IF vvaluepart IS NOT NULL
						THEN
							vblocksql := vblocksql || '  vRow.' || vacolumnarray(i).column_name ||
										 ' := ' || '''' || REPLACE(vvaluepart, '''', '''''') ||
										 ''';' || cchr10;
						END IF;
					ELSIF vacolumnarray(i).data_type = 'DATE'
					THEN
						vvaluepart := getvalue(line.xml, vpath);
						IF vvaluepart IS NOT NULL
						THEN
							vblocksql := vblocksql || '  vRow.' || vacolumnarray(i).column_name ||
										 ' := ';
							vblocksql := vblocksql || ' to_date(''' || vvaluepart || ''', ''' ||
										 cdateformat || ''');' || cchr10;
						END IF;
					ELSIF vacolumnarray(i).data_type = 'XMLTYPE'
					THEN
					
						vxmlvalue := line.xml.extract(vpath);
						IF vxmlvalue IS NOT NULL
						THEN
							vblocksql := vblocksql || '  vRow.' || vacolumnarray(i).column_name ||
										 ' := ';
							vblocksql := vblocksql || ' XMLType.CreateXML(''' ||
										 vxmlvalue.getclobval() || ''');' || cchr10;
						END IF;
					ELSIF vacolumnarray(i).data_type = 'CLOB'
					THEN
						vvaluepartclob := xmltools.getlvalue(line.xml, vpath);
						IF vvaluepartclob IS NOT NULL
						THEN
							vblocksql := vblocksql || '  vRow.' || vacolumnarray(i).column_name ||
										 ' := ' || '''' || REPLACE(vvaluepartclob, '''', '''''') ||
										 ''';' || cchr10;
							vblocksql := vblocksql;
						END IF;
					ELSE
						vvaluepart := getvalue(line.xml, vpath);
						IF vvaluepart IS NOT NULL
						THEN
							vblocksql := vblocksql || '  vRow.' || vacolumnarray(i).column_name ||
										 ' := ' || vvaluepart || ';' || cchr10;
						END IF;
					END IF;
				END LOOP;
				IF vsettings.refcodecolumn IS NOT NULL
				THEN
					vblocksql := vblocksql || '  vSrcRefCode := vRow.' || vsettings.refcodecolumn || ';' ||
								 cchr10;
				END IF;
			
				vblocksql := vblocksql || ' begin' || cchr10;
				IF existsmethod(vsettings.packagename
							   ,vsettings.objectname || cpostfixvalidate
							   ,'/inout:S/in:I/out:I/ret:E')
				THEN
					vblocksql := vblocksql || '  execute immediate '' begin ' ||
								 vsettings.packagename || '.' || vsettings.objectname ||
								 cpostfixvalidate || '(:inoutRow, ' || vsettings.importmode ||
								 ', :ActType ); end;''  using in out vRow, out vActionType;' ||
								 cchr10;
				ELSE
					vblocksql := vblocksql ||
								 '  ValidateRow(vRow, ContractExchangeTools.GetCurrentSettings,  ContractExchangeTools.GetCurrentParentSettings, vActionType);' ||
								 cchr10;
				END IF;
				vblocksql := vblocksql || 'exception' || cchr10;
				vblocksql := vblocksql || '  when others then' || cchr10;
			
				vblocksql := vblocksql || '    ContractExchangeTools.SetActionType  (''' ||
							 vsettings.tablename || ''', ' || voldcode ||
							 ', ContractExchangeTools.cActType_SkipByError);' || cchr10;
				vblocksql := vblocksql || '    raise;' || cchr10;
				vblocksql := vblocksql || 'end;    ' || cchr10;
			
				vblocksql := vblocksql || '  t.var(''ActionType[1]'', vActionType);' || cchr10;
			
				IF pparentsettings.tablename IS NOT NULL
				   AND vsettings.refcodecolumn IS NOT NULL
				THEN
					vblocksql := vblocksql ||
								 '  if coalesce(vActionType, ContractExchangeTools.cActType_Unknown) = ContractExchangeTools.cActType_Unknown then' ||
								 cchr10;
					vblocksql := vblocksql ||
								 '    vActionType := ContractExchangeTools.GetActionTypeBySrcCode(''' ||
								 pparentsettings.tablename || ''', vSrcRefCode);' || cchr10;
					vblocksql := vblocksql || '    t.var(''ActionType[2]'', vActionType);' ||
								 cchr10;
					vblocksql := vblocksql || '  end if;' || cchr10;
				END IF;
			
				IF vsettings.codecolumn IS NOT NULL
				THEN
					vblocksql := vblocksql || '  t.var(''CodeColumnValue'', vRow.' ||
								 vsettings.codecolumn || ');' || cchr10;
				END IF;
			
				vblocksql := vblocksql ||
							 '  if coalesce(vActionType, ContractExchangeTools.cActType_Unknown)=ContractExchangeTools.cActType_Stop then  ' ||
							 cchr10;
				vblocksql := vblocksql ||
							 '    htools.message(''Import'', ''Record exists. Import stopped'');' ||
							 cchr10;
				vblocksql := vblocksql || '    raise ContractExchangeTools.exImportStop; ' ||
							 cchr10;
				vblocksql := vblocksql || '  end if;' || cchr10;
			
				IF psaverecord
				THEN
					IF vcodecolumnname IS NOT NULL
					   AND vsequencename IS NOT NULL
					THEN
						vblocksql := vblocksql ||
									 '  if vActionType=ContractExchangeTools.cActType_NotExists_Add then  ' ||
									 cchr10;
						vblocksql := vblocksql || '    vRow.' || vcodecolumnname || ':=' ||
									 vsequencename || '.NextVal();' || cchr10;
						vblocksql := vblocksql || '  end if; ' || cchr10;
					END IF;
				
					vblocksql := vblocksql || '  ContractExchangeTools.SetActionType  (''' ||
								 vsettings.tablename || ''', ' || voldcode || ', vActionType);' ||
								 cchr10;
				
					IF existsmethod(vsettings.packagename
								   ,vsettings.objectname || cpostfixsaverow
								   ,'/inout:S/in:I/ret:E')
					THEN
						vblocksql := vblocksql || '  execute immediate '' begin ' ||
									 vsettings.packagename || '.' || vsettings.objectname ||
									 cpostfixsaverow ||
									 '(:inoutRow, :ActType ); end;''  using in out vRow, in vActionType;' ||
									 cchr10;
					ELSE
						vblocksql := vblocksql ||
									 '  SaveRow(vRow, ContractExchangeTools.GetCurrentSettings,  vActionType);' ||
									 cchr10;
					
					END IF;
				
					IF vsettings.codecolumn IS NOT NULL
					   AND (vsettings.refcodecolumn IS NULL OR
					   vsettings.refcodecolumn IS NOT NULL AND
					   vsettings.codecolumn <> vsettings.refcodecolumn)
					THEN
						vblocksql := vblocksql ||
									 '  if coalesce(vActionType, ContractExchangeTools.cActType_Unknown) =  ContractExchangeTools.cActType_NotExists_Add then' ||
									 cchr10;
						vblocksql := vblocksql || '    ContractExchangeTools.AddMatchingRow (''' ||
									 vsettings.packagename || ''', ''' || vsettings.tablename ||
									 ''', ''' || vsettings.codecolumn || ''', ' || voldcode ||
									 ', vRow.' || vsettings.codecolumn || ');' || cchr10;
						vblocksql := vblocksql || '  end if;' || cchr10;
					END IF;
				END IF;
			
				IF vsettings.codecolumn IS NOT NULL
				   AND pparentsettings.tablename IS NULL
				THEN
					vblocksql := vblocksql ||
								 '  ContractExchangeTools.Log(ContractExchangeTools.cLogType_Msg, ''' ||
								 vsettings.packagename || ''', ''' || vsettings.objectname ||
								 ''', ' || voldcode || ', vActionType, ' || voldcode ||
								 ' ||'' -> ''|| vRow.' || vsettings.codecolumn || ');' || cchr10;
				END IF;
			
				vblocksql := vblocksql || 'exception';
				vblocksql := vblocksql || '  when ContractExchangeTools.exImportStop then' ||
							 cchr10;
				vblocksql := vblocksql || '    raise ContractExchangeTools.exImportStop;' || cchr10;
				vblocksql := vblocksql || '  when others then' || cchr10;
				vblocksql := vblocksql || '    raise;' || cchr10;
				vblocksql := vblocksql || 'end;' || cchr10;
				say(vblocksql);
				BEGIN
					SAVEPOINT sp_importrow;
					error.clear();
					EXECUTE IMMEDIATE vblocksql;
				EXCEPTION
					WHEN eximportstop THEN
						ROLLBACK TO sp_importrow;
						custom_contractexchangetools.log(custom_contractexchangetools.clogtype_msg
														,vsettings.packagename
														,vsettings.objectname
														,voldcode
														,cacttype_stop
														,'');
						ocontinue := FALSE;
						EXIT;
					
					WHEN OTHERS THEN
						error.save(cmethodname);
						ROLLBACK TO sp_importrow;
					
						IF error.getusertext = 'ImportStop'
						THEN
							custom_contractexchangetools.log(custom_contractexchangetools.clogtype_msg
															,vsettings.packagename
															,vsettings.objectname
															,voldcode
															,cacttype_stop
															,'');
							ocontinue := FALSE;
							EXIT;
						ELSE
							IF psaverecord
							THEN
								custom_contractexchangetools.log(custom_contractexchangetools.clogtype_error
																,vsettings.packagename
																,vsettings.objectname
																,voldcode
																,NULL
																,coalesce(error.getusertext
																		 ,error.geterrortext));
							ELSE
							
								custom_contractexchangetools.log(custom_contractexchangetools.clogtype_warning
																,vsettings.packagename
																,vsettings.objectname
																,voldcode
																,NULL
																,coalesce(error.getusertext
																		 ,error.geterrortext));
							
							END IF;
						END IF;
				END;
			END IF;
			vcount := vcount + 1;
			IF pshowprogressbar
			   AND coalesce(vallcount, 0) > 0
			THEN
				dialog.percentbox('SHOW', vcount);
			END IF;
		END LOOP;
		IF pshowprogressbar
		   AND coalesce(vallcount, 0) > 0
		THEN
			dialog.percentbox('DOWN');
		END IF;
	
		vparametersobjecttype := addsettings_getparametersobjecttype(psettings);
		IF vparametersobjecttype IS NOT NULL
		THEN
			FOR params IN (SELECT VALUE(p) xml
						   FROM   TABLE(xmlsequence(pxml.extract('//' || vmainobjecttag || '/' ||
																 cparamstag))) p)
			LOOP
				sayxml(params.xml, 'ContractOtherParameters');
				IF params.xml IS NOT NULL
				THEN
					importparams(params.xml, psettings, vparametersobjecttype, psaverecord);
				END IF;
			END LOOP;
		END IF;
	
		IF coalesce(psettings.importchilds, TRUE)
		THEN
			FOR i IN (SELECT constraint_name
							,table_name
					  FROM   user_constraints
					  WHERE  constraint_type = 'R'
					  AND    r_constraint_name IN
							 (SELECT constraint_name
							   FROM   user_constraints
							   WHERE  table_name = upper(vsettings.tablename)
							   AND    constraint_type = 'P'))
			LOOP
			
				vchildsettings            := vsettings;
				vchildsettings.tablename  := i.table_name;
				vchildsettings.objectname := addsettings_getobjectname(vchildsettings);
			
				IF vchildsettings.objectname IS NULL
				THEN
					vpos                      := instr(vsettings.objectname, ' | ');
					vchildsettings.objectname := service.iif(vpos = 0
															,vsettings.objectname
															,substr(vsettings.objectname
																   ,1
																   ,vpos - 1)) || ' | ' ||
												 i.table_name;
				END IF;
			
				vchildsettings.identcolumn := NULL;
			
				vchildsettings.refcodecolumn := getchildtablerefcodecolumn(i.table_name
																		  ,i.constraint_name
																		  ,vsettings.tablename
																		  ,coalesce(addsettings_getcodecolumn(vsettings)
																				   ,gettablecodecolumn(vsettings.tablename)
																				   ,vsettings.codecolumn));
			
				vchildsettings.codecolumn := coalesce(addsettings_getcodecolumn(vchildsettings)
													 ,gettablecodecolumn(vchildsettings.tablename)
													 ,vchildsettings.refcodecolumn);
			
				IF coalesce(ocontinue, TRUE)
				THEN
					import_(pxml
						   ,vchildsettings
						   ,psaverecord
						   ,vsettings
						   ,ocontinue
						   ,pshowprogressbar);
				END IF;
			END LOOP;
		END IF;
		ocontinue := coalesce(ocontinue, TRUE);
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			IF pshowprogressbar
			THEN
				htools.message('error', 'down');
				dialog.percentbox('DOWN');
			END IF;
			RAISE;
	END;

	PROCEDURE importfromxml
	(
		pxml             xmltype
	   ,psettings        typeimportsettings
	   ,psaverecord      BOOLEAN := TRUE
	   ,pclearlog        BOOLEAN := TRUE
	   ,pshowprogressbar BOOLEAN := FALSE
	) IS
		vcontinue BOOLEAN;
	BEGIN
		importfromxml(pxml, psettings, psaverecord, pclearlog, pshowprogressbar, vcontinue);
	END;

	PROCEDURE importfromxml
	(
		pxml             xmltype
	   ,psettings        typeimportsettings
	   ,psaverecord      BOOLEAN := TRUE
	   ,pclearlog        BOOLEAN := TRUE
	   ,pshowprogressbar BOOLEAN := FALSE
	   ,ocontinue        OUT BOOLEAN
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ImportFromXML';
		vmainobjecttag VARCHAR2(1000) := upper(coalesce(psettings.objectname, psettings.tablename));
	BEGIN
		t.enter(cmethodname
			   ,'TableName=' || psettings.tablename || ', ObjectName=' || psettings.objectname ||
				', CodeColumn=' || psettings.codecolumn || ', SaveRecord=' ||
				htools.b2s(psaverecord));
		SAVEPOINT sp_fullimport;
	
		IF pclearlog
		THEN
			clearlog;
		END IF;
		sayxml(pxml, 'Full XML for Import');
	
		IF pxml.existsnode('/' || vmainobjecttag) = 0
		THEN
			error.raiseerror(err.ue_value_incorrect
							,'Selected file does not contain object data ' || vmainobjecttag || ')!');
		END IF;
	
		IF psaverecord
		THEN
			FOR blocks IN (SELECT VALUE(p) xml
						   FROM   TABLE(xmlsequence(pxml.extract('//' || vmainobjecttag || '/' ||
																 cdsblockstag))) p)
			LOOP
				sayxml(blocks.xml, 'DynaSQLBlocks');
				IF blocks.xml IS NOT NULL
				THEN
					importdynasqlblocks(blocks.xml);
				END IF;
			END LOOP;
		END IF;
	
		import_(pxml.extract('//' || vmainobjecttag)
			   ,psettings
			   ,psaverecord
			   ,ocontinue => ocontinue
			   ,pshowprogressbar => pshowprogressbar);
	
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			ROLLBACK TO sp_fullimport;
			RAISE;
	END;

	FUNCTION dialogexport(psettings typeexportsettings) RETURN NUMBER IS
		cmethodname             VARCHAR2(64) := '.DialogExport';
		vdialog                 NUMBER;
		vcaption                VARCHAR2(1000);
		ceventhandlermethodname VARCHAR2(64) := cpackagename || '.DialogExportHandler';
		cdialogwidth  CONSTANT NUMBER := 80;
		cdialogheight CONSTANT NUMBER := 40;
		clistheight   CONSTANT NUMBER := 12;
		cbuttonwidth  CONSTANT NUMBER := 15;
		vy NUMBER := 2;
	
	BEGIN
		t.enter(cmethodname);
		sexportsettings := psettings;
		IF psettings.referencename IS NOT NULL
		THEN
			vcaption := psettings.referencename ||
						service.iif(instr(psettings.referencename, ':') > 0, NULL, ': import');
		ELSE
			vcaption := 'Import';
		END IF;
	
		vdialog := dialog.new(vcaption, 1, 1, cdialogwidth, cdialogheight);
		dialog.setexternalid(vdialog, cmethodname);
	
		dialog.inputchar(vdialog
						,'File'
						,15
						,vy
						,plen     => cdialogwidth - 2 - 15
						,phint    => 'Enter file name'
						,pmaxlen  => 250
						,pcaption => 'File name: ');
		dialog.setitempre(vdialog, 'File', ceventhandlermethodname);
		dialog.setmandatory(vdialog, 'File');
	
		vy := vy + 2;
		dialog.checkbox(vdialog, 'lExportList', 3, vy, (cdialogwidth - 7), clistheight, '');
		dialog.setanchor(vdialog, 'lExportList', dialog.anchor_all);
		dialog.listaddfield(vdialog, 'lExportList', 'Sign', 'N', 1, 0);
		dialog.listaddfield(vdialog, 'lExportList', 'Code', 'C', 10, 1);
		dialog.listaddfield(vdialog
						   ,'lExportList'
						   ,'Ident'
						   ,'C'
						   ,10
						   ,htools.b2i(psettings.identcolumn IS NOT NULL));
		dialog.listaddfield(vdialog, 'lExportList', 'Name', 'C', 80, 1);
		IF psettings.identcolumn IS NOT NULL
		THEN
			dialog.setcaption(vdialog, 'lExportList', '~Code~ID~Name');
		ELSE
			dialog.setcaption(vdialog, 'lExportList', '~Code~Name');
		END IF;
	
		dialog.setitempre(vdialog, 'lExportList', ceventhandlermethodname);
		dialog.setitempost(vdialog, 'lExportList', ceventhandlermethodname);
	
		vy := vy + clistheight + 3;
		dialog.button(vdialog
					 ,'btnExport'
					 ,round(cdialogwidth / 2) - cbuttonwidth / 2 - 2 - cbuttonwidth
					 ,vy
					 ,cbuttonwidth
					 ,'Unload'
					 ,dialog.cm_ok
					 ,phint => 'Export selected records');
		dialog.setitempost(vdialog, 'btnExport', ceventhandlermethodname);
		dialog.setdialogpre(vdialog, ceventhandlermethodname);
		dialog.button(vdialog
					 ,'btnExportAll'
					 ,round(cdialogwidth / 2) - cbuttonwidth / 2
					 ,vy
					 ,cbuttonwidth
					 ,'Unload all'
					 ,dialog.cm_ok
					 ,phint => 'Export all records');
		dialog.setitempost(vdialog, 'btnExportAll', ceventhandlermethodname);
		dialog.setdialogpre(vdialog, ceventhandlermethodname);
		dialog.button(vdialog
					 ,'btnCancel'
					 ,round(cdialogwidth / 2) + cbuttonwidth / 2 + 2
					 ,vy
					 ,cbuttonwidth
					 ,'Cancel'
					 ,dialog.cm_cancel
					 ,0
					 ,phint => 'Exit without exporting data');
		t.leave(cmethodname);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || cmethodname);
			RAISE;
	END;

	PROCEDURE dialogexporthandler
	(
		pwhat   IN NUMBER
	   ,pdialog IN NUMBER
	   ,pitem   IN VARCHAR2
	   ,pcmd    IN NUMBER
	) IS
		cmethodname VARCHAR2(64) := '.DialogExportHandler';
	
		PROCEDURE filllist IS
			vcursor typecursor;
			vcurstr VARCHAR2(1000);
			TYPE typerecord IS RECORD(
				 code  VARCHAR2(1000)
				,ident VARCHAR2(1000)
				,NAME  VARCHAR2(4000));
			vrecord typerecord;
		
		BEGIN
			vcurstr := 'select ' || coalesce(sexportsettings.codecolumn, 'Code') || ' as Code, ';
			IF sexportsettings.identcolumn IS NOT NULL
			THEN
				vcurstr := vcurstr || sexportsettings.identcolumn || ' as Ident, ';
			ELSE
				vcurstr := vcurstr || ' null as Ident, ';
			END IF;
			vcurstr := vcurstr || sexportsettings.namecolumn || ' as Name' || cchr10 || ' from ' ||
					   sexportsettings.tablename || cchr10 ||
					   service.iif(sexportsettings.whereclause IS NOT NULL
								  ,'where ' || sexportsettings.whereclause
								  ,NULL) || cchr10 ||
					   service.iif(sexportsettings.orderclause IS NOT NULL
								  ,'order by ' || sexportsettings.orderclause
								  ,NULL);
			s.say('sql=' || vcurstr);
			OPEN vcursor FOR vcurstr;
			LOOP
				FETCH vcursor
					INTO vrecord;
				EXIT WHEN vcursor%NOTFOUND;
			
				dialog.listaddrecord(pdialog
									,'lExportList'
									,'0' || '~' || vrecord.code || '~' || vrecord.ident || '~' ||
									 vrecord.name);
			
			END LOOP;
			CLOSE vcursor;
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || '.FillCommandList');
				RAISE;
		END;
	
		PROCEDURE export(pallrecord BOOLEAN) IS
			vfile         VARCHAR2(1000);
			vpath         VARCHAR2(1000);
			vxml          xmltype;
			vcount        NUMBER;
			vlistreccount NUMBER;
		BEGIN
		
			vfile := dialog.getchar(pdialog, 'File');
			IF TRIM(vfile) IS NULL
			THEN
				dialog.goitem(pdialog, 'File');
				dialog.sethothint(pdialog, 'File for unloading not specified.');
				dialog.cancelclose(pdialog);
				RETURN;
			END IF;
		
			vpath := htools.getfilepath(vfile);
			IF vpath IS NULL
			   OR NOT (term.dir_exists(vpath))
			THEN
				dialog.goitem(pdialog, 'File');
				dialog.sethothint(pdialog, 'Specify existing directory!');
				dialog.cancelclose(pdialog);
				RETURN;
			END IF;
		
			IF NOT htools.equal(upper(htools.getfileext(vfile)), upper('xml'))
			THEN
				vfile := vfile || '.xml';
				dialog.putchar(pdialog, 'File', vfile);
			END IF;
		
			IF term.fileexists(vfile)
			THEN
				IF dialog.exec(service.dialogconfirm('Warning!'
													,'Do you really want to overwrite existing file [' ||
													 vfile ||
													 ']? ~ All data contained in file will be deleted!'
													,'  Yes '
													,'Continue saving'
													,'  No   '
													,'Cancel')) <> dialog.cm_ok
				THEN
					dialog.goitem(pdialog, 'File');
					dialog.cancelclose(pdialog);
					RETURN;
				END IF;
			END IF;
		
			vcount        := 0;
			vlistreccount := dialog.getlistreccount(pdialog, 'lExportList');
			t.var('GetListRecCount', vlistreccount);
			IF vlistreccount = 0
			THEN
				htools.message('Warning!', 'No data to export!');
				RETURN;
			END IF;
		
			sacodelist.delete;
			IF pallrecord
			THEN
				vcount := vlistreccount;
			ELSE
				FOR i IN 1 .. vlistreccount
				LOOP
					IF dialog.getbool(pdialog, 'lExportList', i)
					THEN
						vcount := vcount + 1;
						sacodelist.extend;
						sacodelist(sacodelist.count) := dialog.getrecordchar(pdialog
																			,'lExportList'
																			,'Code'
																			,i);
					END IF;
				END LOOP;
			
				t.var('Count', vcount);
			
				IF vcount = 0
				THEN
					dialog.sethothint(pdialog, 'Attention! Select records to be exported!');
					dialog.goitem(pdialog, 'lExportList');
					RETURN;
				END IF;
			
				IF vcount = vlistreccount
				THEN
					sacodelist.delete;
				END IF;
			END IF;
		
			IF sacodelist.count > 0
			THEN
				sexportsettings.whereclause := service.iif(sexportsettings.whereclause IS NOT NULL
														  ,sexportsettings.whereclause || ' and '
														  ,'') || sexportsettings.codecolumn ||
											   ' member of :w1';
			END IF;
		
			IF sexportsettings.objectname IS NOT NULL
			   AND existsmethod(sexportsettings.packagename
							   ,sexportsettings.objectname || cpostfixexport
							   ,'/in:S/ret:Y')
			THEN
				EXECUTE IMMEDIATE ' begin :Out := ' || sexportsettings.packagename || '.' ||
								  sexportsettings.objectname || cpostfixexport || '(:1); end;'
					USING OUT vxml, IN sexportsettings;
			ELSE
				vxml := export2xml(sexportsettings, pcount => vcount);
			END IF;
		
			savetofile(vxml, vfile, cencode, TRUE);
			htools.message('Export', 'Export complete!');
		END;
	
	BEGIN
		t.enter(cmethodname || ' (' || pwhat || ', ' || pdialog || ', ' || pitem || ', ' || pcmd || ')');
		IF pwhat = dialog.wt_dialogpre
		THEN
			filllist;
		ELSIF pwhat = dialog.wt_itempre
		THEN
			IF pitem = upper('File')
			THEN
				DECLARE
					vfile VARCHAR2(1000);
				BEGIN
					vfile := TRIM(term.filedialog('Select file'
												 ,FALSE
												 ,''
												 ,'*.xml'
												 ,FALSE
												 ,term.lt_all));
					IF vfile IS NOT NULL
					THEN
						IF NOT htools.equal(upper(htools.getfileext(vfile)), upper('xml'))
						THEN
							vfile := vfile || '.xml';
						END IF;
						dialog.putchar(pdialog, 'File', vfile);
					END IF;
				END;
			END IF;
		
		ELSIF pwhat = dialog.wt_itempost
		THEN
			IF pitem = upper('btnExport')
			THEN
				export(FALSE);
			ELSIF pitem = upper('btnExportAll')
			THEN
				export(TRUE);
			END IF;
		END IF;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
		
			error.show('Error', error.geterrortext);
	END;

	FUNCTION dialogimport(psettings typeimportsettings) RETURN NUMBER IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.DialogImport';
		ceventname  CONSTANT VARCHAR2(100) := cpackagename || '.DialogImportHandler';
		vdialog  NUMBER;
		vcaption VARCHAR2(1000);
		vfile    dcmaskfile.typeparam;
		cdialogwidth CONSTANT NUMBER := 70;
		cbuttonwidth CONSTANT NUMBER := 12;
		vy NUMBER := 2;
	BEGIN
		t.enter(cmethodname);
		IF psettings.referencename IS NOT NULL
		THEN
			vcaption := psettings.referencename ||
						service.iif(instr(psettings.referencename, ':') > 0, NULL, ': import');
		ELSE
			vcaption := 'Import';
		END IF;
	
		simportsettings := psettings;
	
		vdialog := dialog.new(vcaption, 1, 1, cdialogwidth, 8, pextid => cmethodname);
		dialog.setdialogpre(vdialog, ceventname);
	
		dialog.bevel(vdialog, 1, 1, cdialogwidth - 1, 5, dialog.bevel_frame, NULL, '');
	
		vfile.caption   := '  Data file:';
		vfile.hint      := 'Select file for import';
		vfile.extension := 'XML';
		vfile.isencod   := FALSE;
		vfile.dctype    := dcmaskfile.cmode_fullpath;
		vfile.width     := cdialogwidth - 22;
		dcmaskfile.new(vdialog, 'eFile', 20, vy, vfile, pmaxwidth => 45);
	
		vy := vy + 2;
		dialog.inputchar(vdialog
						,'eImportMode'
						,20
						,vy
						,46
						,'Actions if errors occur or identifiers are identical'
						,pcaption => '  Import mode:');
		dialog.listaddfield(vdialog, 'eImportMode', 'Code', 'N', 1, pshow => 0);
		dialog.listaddfield(vdialog, 'eImportMode', 'Name', 'C', 20);
	
		dialog.listaddrecord(vdialog
							,'eImportMode'
							,cimportmode_stop || '~' || getimportmodedescription(cimportmode_stop));
		dialog.listaddrecord(vdialog
							,'eImportMode'
							,cimportmode_over || '~' || getimportmodedescription(cimportmode_over));
		dialog.listaddrecord(vdialog
							,'eImportMode'
							,cimportmode_skip || '~' || getimportmodedescription(cimportmode_skip));
	
		dialog.setcurrecbyvalue(vdialog, 'eImportMode', 'Code', cimportmode_skip);
	
		vy := vy + 3;
	
		dialog.button(vdialog
					 ,'btnLoad'
					 ,round(cdialogwidth / 2) - 2 - cbuttonwidth
					 ,vy
					 ,12
					 ,'Apply'
					 ,dialog.cm_ok
					 ,phint => 'Process import');
		dialog.setitempre(vdialog, 'btnLoad', ceventname);
		dialog.button(vdialog
					 ,'btnCancel'
					 ,round(cdialogwidth / 2) + 2
					 ,vy
					 ,12
					 ,'Cancel'
					 ,dialog.cm_cancel
					 ,0
					 ,phint => 'Cancel import');
	
		t.leave(cmethodname);
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.DialogImport');
			RAISE;
	END;

	PROCEDURE dialogimporthandler
	(
		pwhat   IN NUMBER
	   ,pdialog IN NUMBER
	   ,pitem   IN VARCHAR2
	   ,pcmd    IN NUMBER
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.DialogImportHandler';
		vfileparam dcmaskfile.typemaskfile;
	BEGIN
		t.enter(cmethodname || '[' || pwhat || ', ' || pdialog || ', ' || pitem || ', ' || pcmd || ']');
		IF pwhat = dialog.wt_dialogpre
		THEN
			IF NOT contracttype.checkright(contracttype.right_modify)
			THEN
				service.saymsg(pdialog, 'Warning!', 'You are not authorized to import dictionary~');
				dialog.abort(pdialog);
				RETURN;
			END IF;
		ELSIF pwhat = dialog.wt_itempre
		THEN
			IF pitem = upper('btnLoad')
			THEN
				vfileparam := dcmaskfile.getvalue(pdialog, 'eFile');
				IF upper(substr(vfileparam.mask, (length(vfileparam.mask) - 3), 4)) <> '.XML'
				THEN
					vfileparam.mask := vfileparam.mask || '.xml';
				END IF;
				IF NOT term.fileexists(vfileparam.path || vfileparam.mask)
				THEN
					dcmaskfile.goitem(pdialog, 'eFile');
					dialog.sethothint(pdialog, 'Attention! Nonexistent file specified!');
					RETURN;
				END IF;
			
				logevent(contract.object_name
						,'IMPORT|' || simportsettings.objectname
						,a4mlog.act_execstart
						,simportsettings.importmode
						,vfileparam.path || vfileparam.mask);
			
				sxml := loadfromfile(vfileparam.path || vfileparam.mask, cencode);
				IF sxml IS NOT NULL
				THEN
					simportsettings.importmode := dialog.getcurrentrecordnumber(pdialog
																			   ,'eImportMode'
																			   ,'Code');
					DECLARE
						vcontinue BOOLEAN;
					BEGIN
						IF existsmethod(simportsettings.packagename
									   ,simportsettings.objectname || cpostfiximport
									   ,'/in:Y/in:S/in:B/ret:E')
						THEN
							EXECUTE IMMEDIATE ' begin ' || simportsettings.packagename || '.' ||
											  simportsettings.objectname || cpostfiximport ||
											  '(:1, :2, :3); end;'
								USING sxml, simportsettings, NOT simportsettings.dopreparatorywork;
						ELSIF existsmethod(simportsettings.packagename
										  ,simportsettings.objectname || cpostfiximport
										  ,'/in:Y/in:S/in:B/out:B/ret:E')
						THEN
							EXECUTE IMMEDIATE ' begin ' || simportsettings.packagename || '.' ||
											  simportsettings.objectname || cpostfiximport ||
											  '(:1, :2, :3, :4); end;'
								USING sxml, simportsettings, NOT simportsettings.dopreparatorywork, OUT vcontinue;
						ELSE
							importfromxml(sxml
										 ,simportsettings
										 ,NOT simportsettings.dopreparatorywork
										 ,TRUE
										 ,TRUE
										 ,ocontinue => vcontinue);
						END IF;
						showresultdialog(coalesce(simportsettings.dopreparatorywork, TRUE) AND
										 coalesce(vcontinue, TRUE));
					EXCEPTION
						WHEN OTHERS THEN
							error.showerror('Import');
							dialog.cancelclose(pdialog);
					END;
				ELSE
					htools.message('Import', 'No data to import!');
				END IF;
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cpackagename || '.DialogImportHandler(' || pwhat || ', ' || pdialog || ', ' ||
					   pitem || ', ' || pcmd || ')');
			dialog.abort(pdialog);
			RAISE;
	END;

	PROCEDURE savetofile
	(
		pxml             IN xmltype
	   ,ppath            IN VARCHAR2
	   ,pencoding        IN VARCHAR2
	   ,pshowprogressbar BOOLEAN := FALSE
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.SaveToFile';
		vhandle NUMBER;
		vlength NUMBER;
	BEGIN
		t.enter(cmethodname);
		IF pxml IS NOT NULL
		THEN
			t.note(cmethodname, 'XML is not null');
			t.note(cmethodname, ' correct path = ' || htools.getfilepath(ppath));
		
			vhandle := term.fileopenwrite(ppath, penc => pencoding);
		
			term.writebuffer(vhandle, cheader || pencoding || cheaderend);
		
			t.note(cmethodname, 'start writing to file');
		
			vlength := length(pxml.getclobval);
		
			IF pshowprogressbar
			THEN
				dialog.percentbox('INIT'
								 ,vlength
								 ,coalesce(sexportsettings.referencename
										  ,sexportsettings.objectname) || ': save to file');
			END IF;
			FOR i IN 0 .. trunc(vlength / 4000)
			LOOP
			
				term.writebuffer(vhandle, substr(pxml.getclobval, i * 4000 + 1, 4000));
				IF pshowprogressbar
				THEN
					dialog.percentbox('SHOW', i * 4000);
				END IF;
			END LOOP;
			term.close(vhandle);
			IF pshowprogressbar
			THEN
				dialog.percentbox('DOWN');
			END IF;
		ELSE
			t.note(cmethodname, 'XML is null');
		END IF;
		t.leave(cmethodname);
	EXCEPTION
		WHEN OTHERS THEN
			term.closeabort(vhandle);
			error.save(cpackagename || '.SaveToFile');
			RAISE;
	END;

	FUNCTION loadfromfile
	(
		ppath        IN VARCHAR2
	   ,pencode      IN VARCHAR2
	   ,pinteractive IN BOOLEAN := TRUE
	) RETURN xmltype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.LoadFromFile';
		vhandle NUMBER;
		vclob   CLOB;
		vblob   BLOB;
		vxml    xmltype;
		vraw    RAW(32767);
		ex_wrongstructure EXCEPTION;
		vlength    NUMBER;
		vcurlength NUMBER;
	BEGIN
		t.enter(cmethodname);
		vhandle := term.fileopenread(ppath, NULL, 'BIN');
		IF pinteractive
		THEN
			vlength := term.getlength(vhandle);
			t.var('Length', vlength);
			dialog.percentbox('INIT', vlength, 'Load file');
		END IF;
		dbms_lob.createtemporary(vblob, TRUE);
		vlength := 0;
		WHILE TRUE
		LOOP
			vraw := term.readbinblock(vhandle, 32000);
			EXIT WHEN vraw IS NULL;
			vcurlength := utl_raw.length(vraw);
			dbms_lob.writeappend(vblob, vcurlength, vraw);
			IF pinteractive
			THEN
				vlength := vlength + vcurlength;
			
				dialog.percentbox('SHOW', vlength);
			END IF;
		END LOOP;
		vclob := term.bytetochar(vblob, pencode);
		dbms_lob.freetemporary(vblob);
		IF pinteractive
		THEN
			dialog.percentbox('DOWN');
		END IF;
	
		t.note(cmethodname, 'load to clob  - complete, length=' || dbms_lob.getlength(vclob));
	
		BEGIN
			vxml := xmltype.createxml(vclob);
		EXCEPTION
			WHEN OTHERS THEN
				error.save(cpackagename || cmethodname || '.CreateXML');
				IF pinteractive
				THEN
					htools.showmessage('Import', 'Invalid XML file structure!');
				END IF;
				RAISE ex_wrongstructure;
		END;
	
		term.close(vhandle);
		t.leave(cmethodname);
		RETURN vxml;
	EXCEPTION
		WHEN ex_wrongstructure THEN
			error.save(cpackagename || cmethodname);
			term.closeabort(vhandle);
			RETURN vxml;
		
		WHEN OTHERS THEN
			error.save(cpackagename || cmethodname);
			term.closeabort(vhandle);
			IF pinteractive
			THEN
				dialog.percentbox('DOWN');
			END IF;
			RAISE;
	END;

	FUNCTION existsmethod
	(
		ppackagename typepackagename
	   ,pmethodname  VARCHAR2
	   ,pformat      VARCHAR2
	) RETURN BOOLEAN IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ExistsMethod';
		vret BOOLEAN;
	BEGIN
		t.enter(cmethodname, 'PackageName=' || ppackagename || ', MethodName=' || pmethodname);
	
		IF ppackagename IS NULL
		THEN
			error.raiseerror('Batch name not defined');
		END IF;
	
		IF pmethodname IS NULL
		THEN
			error.raiseerror('Method name not defined');
		END IF;
	
		IF samethodexists.exists(ppackagename)
		   AND samethodexists(ppackagename).exists(pmethodname)
		   AND samethodexists(ppackagename)(pmethodname).exists(pformat)
		THEN
			vret := samethodexists(ppackagename) (pmethodname) (pformat) = 1;
		END IF;
	
		s.say(cmethodname || ': exists(1)=' || htools.b2s(vret));
	
		IF vret IS NULL
		THEN
		
			FOR i IN (SELECT status
							,object_type
					  FROM   user_objects
					  WHERE  object_name = upper(ppackagename)
					  ORDER  BY object_type)
			LOOP
				IF i.status = 'INVALID'
				THEN
					error.raiseerror(i.object_type || ' ' || ppackagename || ' not valid');
				END IF;
			END LOOP;
		
			vret := service.existproc(ppackagename, pmethodname, pformat);
			s.say(cmethodname || ': exists(2)=' || htools.b2s(vret));
			samethodexists(ppackagename)(pmethodname)(pformat) := htools.b2i(vret);
		END IF;
	
		t.leave(cmethodname, 'return ' || htools.b2s(vret));
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE validateentrycode(poentrycode IN OUT NOCOPY treferenceentry.code%TYPE) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ValidateEntryCode';
	BEGIN
		t.enter(cmethodname, 'EntryCode=' || poentrycode);
		IF poentrycode IS NOT NULL
		THEN
			poentrycode := getdestcode('tReferenceEntry', 'Code', poentrycode);
		END IF;
	
		t.leave(cmethodname, 'return ' || poentrycode);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE validatecardsign(pocardsign IN OUT NOCOPY treferencecardsign.cardsign%TYPE) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ValidateCardSign';
	BEGIN
		t.enter(cmethodname, 'CardSign=' || pocardsign);
		IF pocardsign IS NOT NULL
		THEN
			IF pocardsign > cmaxsyssign
			THEN
			
				pocardsign := coalesce(getdestcode('tReferenceCardSign', 'CardSign', pocardsign)
									  ,pocardsign);
			END IF;
		END IF;
		t.leave(cmethodname, 'return ' || pocardsign);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE validatecontracttype(pocontracttype IN OUT NOCOPY tcontracttype.type%TYPE) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ValidateContractType';
	BEGIN
		t.enter(cmethodname, 'ContractType=' || pocontracttype);
		IF pocontracttype IS NOT NULL
		THEN
			pocontracttype := getdestcode('tContractType', 'Type', pocontracttype);
		END IF;
		t.leave(cmethodname, 'return ' || pocontracttype);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE validateaccounttype(poaccounttype IN OUT NOCOPY taccounttype.accounttype%TYPE) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ValidateAccountType';
	BEGIN
		t.enter(cmethodname, 'AccountType=' || poaccounttype);
		IF poaccounttype IS NOT NULL
		THEN
			poaccounttype := coalesce(getdestcode('tAccountType', 'AccountType', poaccounttype)
									 ,poaccounttype);
		END IF;
		t.leave(cmethodname, 'return ' || poaccounttype);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE validateaccount
	(
		poaccount         IN OUT NOCOPY account.typeaccountno
	   ,paccountaccessory typeaccountaccessory := NULL
	) IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ValidateAccount';
		cbranch     CONSTANT NUMBER := seance.getbranch();
		vexists BOOLEAN := FALSE;
	BEGIN
		t.enter(cmethodname, 'Account=' || poaccount || ', AccountAccessory=' || paccountaccessory);
		IF poaccount IS NULL
		THEN
			RETURN;
		END IF;
		CASE paccountaccessory
			WHEN NULL THEN
				vexists := account.accountexist(poaccount);
			WHEN cintrabankaccount THEN
				FOR i IN (SELECT 1
						  FROM   taccount a
						  JOIN   tclientbank clc
						  ON     clc.branch = a.branch
						  AND    clc.idclient = a.idclient
						  WHERE  a.branch = cbranch
						  AND    a.accounttype = 0
						  AND    accountno = poaccount)
				LOOP
					vexists := TRUE;
				END LOOP;
			WHEN ccorporateaccount THEN
				FOR i IN (SELECT 1
						  FROM   taccount a
						  JOIN   tclientbank clc
						  ON     clc.branch = a.branch
						  AND    clc.idclient = a.idclient
						  JOIN   taccounttype at
						  ON     at.branch = a.branch
						  AND    at.accounttype = a.accounttype
						  AND    at.usecorporate = 1
						  WHERE  a.branch = cbranch
						  AND    accountno = poaccount)
				LOOP
					vexists := TRUE;
				END LOOP;
			WHEN cpersonaccount THEN
				FOR i IN (SELECT 1
						  FROM   taccount a
						  JOIN   tclientpersone clp
						  ON     clp.branch = a.branch
						  AND    clp.idclient = a.idclient
						  JOIN   taccounttype at
						  ON     at.branch = a.branch
						  AND    at.accounttype = a.accounttype
						  AND    at.useprivate = 1
						  WHERE  a.branch = cbranch
						  AND    accountno = poaccount)
				LOOP
					vexists := TRUE;
				END LOOP;
			ELSE
				NULL;
			
		END CASE;
	
		IF NOT vexists
		THEN
			poaccount := NULL;
		END IF;
		t.leave(cmethodname, 'return Account=' || poaccount);
	EXCEPTION
		WHEN OTHERS THEN
			t.exc(cmethodname);
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE exportreferenceentry IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ExportReferenceEntry';
		cbranch     CONSTANT VARCHAR2(100) := seance.getbranch();
		vexportsettings custom_contractexchangetools.typeexportsettings;
	BEGIN
		vexportsettings.referencename := 'Dictionary of entries';
		vexportsettings.tablename     := 'tReferenceEntry';
		vexportsettings.packagename   := cpackagename;
		vexportsettings.objectname    := 'ReferenceEntries';
		vexportsettings.whereclause   := 'branch=' || cbranch;
		vexportsettings.orderclause   := 'Code';
		vexportsettings.codecolumn    := 'Code';
		vexportsettings.identcolumn   := 'Ident';
		vexportsettings.namecolumn    := 'Name';
		vexportsettings.exportchilds  := FALSE;
		dialog.exec(dialogexport(vexportsettings));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE addmatchingreferenceentry IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.AddMatchingReferenceEntry';
		vimportsettings custom_contractexchangetools.typeimportsettings;
	BEGIN
		vimportsettings.referencename     := 'Dictionary of entries: add correspondences';
		vimportsettings.packagename       := cpackagename;
		vimportsettings.tablename         := 'tReferenceEntry';
		vimportsettings.objectname        := 'ReferenceEntries';
		vimportsettings.codecolumn        := 'Code';
		vimportsettings.identcolumn       := 'Ident';
		vimportsettings.dopreparatorywork := FALSE;
		dialog.exec(custom_contractexchangetools.dialogimport(vimportsettings));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE referenceentries_import
	(
		pxml        xmltype
	   ,psettings   custom_contractexchangetools.typeimportsettings
	   ,psaverecord BOOLEAN := TRUE
	) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ReferenceEntries_SaveRow';
		vsourcecode treferenceentry.code%TYPE;
		vdestcode   treferenceentry.code%TYPE;
		vident      treferenceentry.ident%TYPE;
	BEGIN
		clearlog;
	
		FOR entryrow IN (SELECT VALUE(p) xml
						 FROM   TABLE(xmlsequence(pxml.extract('//' || upper(psettings.objectname) || '/' ||
															   upper(psettings.tablename) || '/' ||
															   upper(psettings.tablename) || '_ROW'))) p)
		LOOP
			vsourcecode := xmltools.getvalue(entryrow.xml
											,'//' || upper('tReferenceEntry') || '_ROW' || '/CODE');
			vdestcode   := getdestcode(psettings.tablename, 'Code', vsourcecode);
		
			IF vdestcode IS NULL
			THEN
				vident    := xmltools.getvalue(entryrow.xml
											  ,'//' || upper(psettings.tablename) || '_ROW' ||
											   '/IDENT');
				vdestcode := referenceentry.getcode(vident);
				IF psaverecord
				   AND vdestcode IS NOT NULL
				THEN
					addmatchingrow(cpackagename
								  ,psettings.tablename
								  ,'Code'
								  ,vsourcecode
								  ,vdestcode);
				END IF;
				IF vdestcode IS NOT NULL
				THEN
					custom_contractexchangetools.log(custom_contractexchangetools.clogtype_msg
													,psettings.packagename
													,psettings.objectname
													,vsourcecode
													,cacttype_locexists_skip
													,vsourcecode || '->' || vdestcode);
				ELSE
					custom_contractexchangetools.log(custom_contractexchangetools.clogtype_error
													,psettings.packagename
													,psettings.objectname
													,vsourcecode
													,cacttype_matching
													,'Not found entry code ' || vident);
				END IF;
			ELSE
				custom_contractexchangetools.log(custom_contractexchangetools.clogtype_msg
												,psettings.packagename
												,psettings.objectname
												,vsourcecode
												,cacttype_mtexists_skip
												,vsourcecode || '->' || vdestcode);
			END IF;
		END LOOP;
	
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE exportreferencecalendar IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ExportReferenceCalendar';
		cbranch     CONSTANT VARCHAR2(100) := seance.getbranch();
		vexportsettings custom_contractexchangetools.typeexportsettings;
	BEGIN
		vexportsettings.referencename := 'Dictionary of calendars';
		vexportsettings.tablename     := 'tReferenceCalendar';
		vexportsettings.packagename   := cpackagename;
		vexportsettings.objectname    := 'ReferenceCalendar';
		vexportsettings.whereclause   := 'branch=' || cbranch;
		vexportsettings.orderclause   := 'Id';
		vexportsettings.codecolumn    := 'Id';
		vexportsettings.identcolumn   := 'StrId';
		vexportsettings.namecolumn    := 'Name';
		vexportsettings.exportchilds  := FALSE;
		dialog.exec(dialogexport(vexportsettings));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE addmatchingreferencecalendar IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.AddMatchingReferenceCalendar';
		vimportsettings custom_contractexchangetools.typeimportsettings;
	BEGIN
		vimportsettings.referencename     := 'Dictionary of calendars: add correspondences';
		vimportsettings.packagename       := cpackagename;
		vimportsettings.tablename         := 'tReferenceCalendar';
		vimportsettings.objectname        := 'ReferenceCalendar';
		vimportsettings.codecolumn        := 'Id';
		vimportsettings.identcolumn       := 'StrId';
		vimportsettings.dopreparatorywork := FALSE;
		dialog.exec(custom_contractexchangetools.dialogimport(vimportsettings));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE referencecalendar_import
	(
		pxml        xmltype
	   ,psettings   custom_contractexchangetools.typeimportsettings
	   ,psaverecord BOOLEAN := TRUE
	) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ReferenceCalendar_Import';
		vsourcecode treferenceentry.code%TYPE;
		vdestcode   treferenceentry.code%TYPE;
		vident      treferenceentry.ident%TYPE;
	BEGIN
		clearlog;
	
		FOR calendarrow IN (SELECT VALUE(p) xml
							FROM   TABLE(xmlsequence(pxml.extract('//' ||
																  upper(psettings.objectname) || '/' ||
																  upper(psettings.tablename) || '/' ||
																  upper(psettings.tablename) ||
																  '_ROW'))) p)
		LOOP
			vsourcecode := custom_xmltools.getvalue(calendarrow.xml
												   ,'//' || upper(psettings.tablename) || '_ROW' ||
													'/ID');
			vdestcode   := getdestcode(psettings.tablename, 'Id', vsourcecode);
		
			IF vdestcode IS NULL
			THEN
				vident    := xmltools.getvalue(calendarrow.xml
											  ,'//' || upper(psettings.tablename) || '_ROW' ||
											   '/STRID');
				vdestcode := referencecalendar.getidbystrid(vident);
				IF psaverecord
				   AND vdestcode IS NOT NULL
				THEN
					addmatchingrow(cpackagename, psettings.tablename, 'Id', vsourcecode, vdestcode);
				END IF;
				IF vdestcode IS NOT NULL
				THEN
					custom_contractexchangetools.log(custom_contractexchangetools.clogtype_msg
													,psettings.packagename
													,psettings.objectname
													,vsourcecode
													,cacttype_locexists_skip
													,vsourcecode || '->' || vdestcode);
				ELSE
					custom_contractexchangetools.log(custom_contractexchangetools.clogtype_error
													,psettings.packagename
													,psettings.objectname
													,vsourcecode
													,cacttype_matching
													,'Not found calendar code ' || vident);
				END IF;
			ELSE
				custom_contractexchangetools.log(custom_contractexchangetools.clogtype_msg
												,psettings.packagename
												,psettings.objectname
												,vsourcecode
												,cacttype_mtexists_skip
												,vsourcecode || '->' || vdestcode);
			END IF;
		END LOOP;
	
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			error.save(cmethodname);
			RAISE;
	END;

	FUNCTION getactiontype
	(
		pimportmode       typeimportmode
	   ,pcodecolumnisnull BOOLEAN
	) RETURN typeactiontype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.GetActionType';
		vactiontype typeactiontype;
	BEGIN
		t.enter(cmethodname
			   ,'ImportMode=' || getimportmodedescription(pimportmode) || ', CodeColumn Is Null=' ||
				htools.b2s(pcodecolumnisnull));
		IF pcodecolumnisnull
		THEN
			vactiontype := custom_contractexchangetools.cacttype_notexists_add;
		ELSE
			CASE pimportmode
				WHEN custom_contractexchangetools.cimportmode_skip THEN
					vactiontype := custom_contractexchangetools.cacttype_mtexists_skip;
				WHEN custom_contractexchangetools.cimportmode_over THEN
					vactiontype := custom_contractexchangetools.cacttype_mtexists_update;
				WHEN custom_contractexchangetools.cimportmode_stop THEN
					vactiontype := custom_contractexchangetools.cacttype_stop;
				ELSE
					error.raiseerror('Unknown import mode [' ||
									 coalesce(to_char(pimportmode), 'null') || ']');
			END CASE;
		END IF;
		t.leave(cmethodname, 'return ' || vactiontype);
		RETURN vactiontype;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE exportreferencecontracttype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ExportReferenceContractType';
		cbranch     CONSTANT VARCHAR2(100) := seance.getbranch();
		vexportsettings custom_contractexchangetools.typeexportsettings;
	BEGIN
		vexportsettings.referencename := 'Dictionary of contract types';
		vexportsettings.tablename     := 'tContractType';
		vexportsettings.packagename   := cpackagename;
		vexportsettings.objectname    := 'ReferenceContractType';
		vexportsettings.whereclause   := 'branch=' || cbranch;
		vexportsettings.orderclause   := 'Type';
		vexportsettings.codecolumn    := 'Type';
		vexportsettings.identcolumn   := 'Ident';
		vexportsettings.namecolumn    := 'Name';
		vexportsettings.exportchilds  := FALSE;
		dialog.exec(dialogexport(vexportsettings));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE addmatchingreferencecontracttype IS
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.AddMatchingReferenceContractType';
		vimportsettings custom_contractexchangetools.typeimportsettings;
	BEGIN
		vimportsettings.referencename     := 'Dictionary of contract types: add correspondences';
		vimportsettings.packagename       := cpackagename;
		vimportsettings.tablename         := 'tContractType';
		vimportsettings.objectname        := 'ReferenceContractType';
		vimportsettings.codecolumn        := 'Type';
		vimportsettings.identcolumn       := 'Ident';
		vimportsettings.dopreparatorywork := FALSE;
		dialog.exec(custom_contractexchangetools.dialogimport(vimportsettings));
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE referencecontracttype_import
	(
		pxml        xmltype
	   ,psettings   custom_contractexchangetools.typeimportsettings
	   ,psaverecord BOOLEAN := TRUE
	) IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		cmethodname CONSTANT VARCHAR2(100) := cpackagename || '.ReferenceContractType_Import';
		vsourcecode treferenceentry.code%TYPE;
		vdestcode   treferenceentry.code%TYPE;
		vident      treferenceentry.ident%TYPE;
	BEGIN
		t.enter(cmethodname, 'SaveRecord=' || htools.b2s(psaverecord));
		clearlog;
		FOR vrow IN (SELECT VALUE(p) xml
					 FROM   TABLE(xmlsequence(pxml.extract('//' || upper(psettings.objectname) || '/' ||
														   upper(psettings.tablename) || '/' ||
														   upper(psettings.tablename) || '_ROW'))) p)
		LOOP
			vsourcecode := xmltools.getvalue(vrow.xml
											,'//' || upper(psettings.tablename) || '_ROW' || '/' ||
											 upper(psettings.codecolumn));
			vdestcode   := getdestcode(psettings.tablename
									  ,upper(psettings.codecolumn)
									  ,vsourcecode);
		
			IF vdestcode IS NULL
			THEN
				vident    := xmltools.getvalue(vrow.xml
											  ,'//' || upper(psettings.tablename) || '_ROW' || '/' ||
											   upper(psettings.identcolumn));
				vdestcode := contracttype.getrecordbyident(vident).type;
				IF psaverecord
				   AND vdestcode IS NOT NULL
				THEN
					addmatchingrow(cpackagename
								  ,psettings.tablename
								  ,upper(psettings.codecolumn)
								  ,vsourcecode
								  ,vdestcode);
				END IF;
				IF vdestcode IS NOT NULL
				THEN
					custom_contractexchangetools.log(custom_contractexchangetools.clogtype_msg
													,psettings.packagename
													,psettings.objectname
													,vsourcecode
													,cacttype_locexists_skip
													,vsourcecode || '->' || vdestcode);
				ELSE
					custom_contractexchangetools.log(custom_contractexchangetools.clogtype_error
													,psettings.packagename
													,psettings.objectname
													,vsourcecode
													,cacttype_matching
													,'Not found contract type' || ' ' || vident);
				END IF;
			ELSE
				custom_contractexchangetools.log(custom_contractexchangetools.clogtype_msg
												,psettings.packagename
												,psettings.objectname
												,vsourcecode
												,cacttype_mtexists_skip
												,vsourcecode || '->' || vdestcode);
			END IF;
		END LOOP;
	
		COMMIT;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
			error.save(cmethodname);
			RAISE;
	END;

	PROCEDURE setrecordcount(pvalue NUMBER) IS
	BEGIN
		sreccountinportion := pvalue;
	END;

	FUNCTION getcodelist RETURN tblnumber IS
	BEGIN
		RETURN sacodelist;
	END;

	FUNCTION needbindcodelist(pwhereclause CLOB) RETURN BOOLEAN IS
	BEGIN
		RETURN instr(pwhereclause, ':w1') > 0;
	END;

END custom_contractexchangetools;
/
