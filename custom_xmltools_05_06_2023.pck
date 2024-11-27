CREATE OR REPLACE PACKAGE custom_xmltools AS

	crevision CONSTANT VARCHAR(100) := '$Rev: 45210 $';

	FUNCTION getatrvalue
	(
		pxml     xmltype
	   ,pxpath   VARCHAR
	   ,patrname VARCHAR
	   ,pxnames  VARCHAR := NULL
	) RETURN VARCHAR;

	FUNCTION getvalue
	(
		pxml    xmltype
	   ,pxpath  VARCHAR
	   ,pxnames VARCHAR := NULL
	) RETURN VARCHAR;

	FUNCTION getlvalue
	(
		pxml    xmltype
	   ,pxpath  VARCHAR
	   ,pxnames VARCHAR := NULL
	) RETURN CLOB;

	FUNCTION getlvalues
	(
		pxml   xmltype
	   ,pxpath VARCHAR
	) RETURN CLOB;

	PROCEDURE init
	(
		pcontinuestreamid  NUMBER := NULL
	   ,pskipheader        BOOLEAN := FALSE
	   ,pwriteemptyelement BOOLEAN := FALSE
	);

	PROCEDURE additem
	(
		pname     VARCHAR
	   ,pvalue    VARCHAR
	   ,patrname  VARCHAR := NULL
	   ,patrval   VARCHAR := NULL
	   ,patrname2 VARCHAR := NULL
	   ,patrval2  VARCHAR := NULL
	   ,patrname3 VARCHAR := NULL
	   ,patrval3  VARCHAR := NULL
	   ,patrname4 VARCHAR := NULL
	   ,patrval4  VARCHAR := NULL
	   ,patrname5 VARCHAR := NULL
	   ,patrval5  VARCHAR := NULL
	   ,patrname6 VARCHAR := NULL
	   ,patrval6  VARCHAR := NULL
	   ,patrname7 VARCHAR := NULL
	   ,patrval7  VARCHAR := NULL
	   ,patrname8 VARCHAR := NULL
	   ,patrval8  VARCHAR := NULL
	   ,patrname9 VARCHAR := NULL
	   ,patrval9  VARCHAR := NULL
	);

	PROCEDURE additeml
	(
		pname     VARCHAR
	   ,pvalue    CLOB
	   ,patrname  VARCHAR := NULL
	   ,patrval   VARCHAR := NULL
	   ,patrname2 VARCHAR := NULL
	   ,patrval2  VARCHAR := NULL
	   ,patrname3 VARCHAR := NULL
	   ,patrval3  VARCHAR := NULL
	   ,patrname4 VARCHAR := NULL
	   ,patrval4  VARCHAR := NULL
	   ,patrname5 VARCHAR := NULL
	   ,patrval5  VARCHAR := NULL
	   ,patrname6 VARCHAR := NULL
	   ,patrval6  VARCHAR := NULL
	   ,patrname7 VARCHAR := NULL
	   ,patrval7  VARCHAR := NULL
	   ,patrname8 VARCHAR := NULL
	   ,patrval8  VARCHAR := NULL
	   ,patrname9 VARCHAR := NULL
	   ,patrval9  VARCHAR := NULL
	);

	PROCEDURE opentag
	(
		pname     VARCHAR
	   ,patrname  VARCHAR := NULL
	   ,patrval   VARCHAR := NULL
	   ,patrname2 VARCHAR := NULL
	   ,patrval2  VARCHAR := NULL
	   ,patrname3 VARCHAR := NULL
	   ,patrval3  VARCHAR := NULL
	   ,patrname4 VARCHAR := NULL
	   ,patrval4  VARCHAR := NULL
	   ,patrname5 VARCHAR := NULL
	   ,patrval5  VARCHAR := NULL
	   ,patrname6 VARCHAR := NULL
	   ,patrval6  VARCHAR := NULL
	   ,patrname7 VARCHAR := NULL
	   ,patrval7  VARCHAR := NULL
	   ,patrname8 VARCHAR := NULL
	   ,patrval8  VARCHAR := NULL
	   ,patrname9 VARCHAR := NULL
	   ,patrval9  VARCHAR := NULL
	);

	PROCEDURE closetag(pname VARCHAR);

	FUNCTION finish RETURN xmltype;
	FUNCTION finish_arrtext RETURN types.arrtext;
	PROCEDURE abort;

	PROCEDURE finishwithcontinuestream;
	FUNCTION getcurrentsid RETURN NUMBER;

	FUNCTION getversion RETURN VARCHAR;

END;
/
CREATE OR REPLACE PACKAGE BODY custom_xmltools AS

	cpackage CONSTANT VARCHAR2(100) := 'XMLTools';

	cbodyrevision CONSTANT VARCHAR2(100) := '$Rev: 45210 $';

	sxmlsid NUMBER;

	FUNCTION getversion RETURN VARCHAR IS
	BEGIN
		RETURN service.formatpackageversion(cpackage, crevision, cbodyrevision);
	END;

	PROCEDURE say(ptext VARCHAR) IS
	BEGIN
		IF ptext LIKE cpackage || '%'
		THEN
			s.say(ptext);
		ELSE
			s.say(cpackage || ': ' || ptext);
		END IF;
	END;

	FUNCTION getatrvalue
	(
		pxml     xmltype
	   ,pxpath   VARCHAR
	   ,patrname VARCHAR
	   ,pxnames  VARCHAR
	) RETURN VARCHAR IS
		cprocname CONSTANT VARCHAR(10000) := cpackage || '.GetAtrValue(path=' || pxpath ||
											 ', Atr = ' || patrname || ', nls = ' || pxnames || ')';
		vret VARCHAR(32767);
	BEGIN
	
		IF pxml.existsnode(pxpath, pxnames) = 1
		THEN
			SELECT extractvalue(pxml, pxpath || '/@' || patrname, pxnames) INTO vret FROM dual;
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION getvalue
	(
		pxml    xmltype
	   ,pxpath  VARCHAR
	   ,pxnames VARCHAR
	) RETURN VARCHAR IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.GetValue(path=' || pxpath || ', nls = ' ||
											pxnames || ')';
		vret VARCHAR(32767);
	BEGIN
		IF pxml.existsnode(pxpath, pxnames) = 1
		THEN
			SELECT extractvalue(pxml, pxpath, pxnames) INTO vret FROM dual;
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION getlvalue
	(
		pxml    xmltype
	   ,pxpath  VARCHAR
	   ,pxnames VARCHAR
	) RETURN CLOB IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.GetLValue(path=' || pxpath || ', nls = ' ||
											pxnames || ')';
		vret   CLOB;
		vxpath VARCHAR(32767) := pxpath || '/text()';
	BEGIN
		IF pxml.existsnode(vxpath, pxnames) = 1
		THEN
			vret := pxml.extract(vxpath, pxnames).getclobval;
			vret := dbms_xmlgen.convert(vret, dbms_xmlgen.entity_decode);
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION getlvalues
	(
		pxml   xmltype
	   ,pxpath VARCHAR
	) RETURN CLOB IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.GetLValues(path=' || pxpath || ')';
	BEGIN
		RETURN pxml.extract(pxpath).getclobval();
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE init
	(
		pcontinuestreamid  NUMBER
	   ,pskipheader        BOOLEAN
	   ,pwriteemptyelement BOOLEAN
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.Init(' || pcontinuestreamid || ')';
	BEGIN
		IF pcontinuestreamid IS NULL
		THEN
			IF sxmlsid IS NOT NULL
			THEN
				stream.closeabort(sxmlsid);
			END IF;
			sxmlsid := clobstream.open();
			xmlproducer.writebegindocument(sxmlsid, pskipheader => pskipheader);
		ELSE
			IF sxmlsid != pcontinuestreamid
			THEN
				stream.closeabort(sxmlsid);
			END IF;
			sxmlsid := pcontinuestreamid;
		END IF;
		xmlproducer.wantemptytags := nvl(pwriteemptyelement, FALSE);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE additem
	(
		pname     VARCHAR
	   ,pvalue    VARCHAR
	   ,patrname  VARCHAR := NULL
	   ,patrval   VARCHAR := NULL
	   ,patrname2 VARCHAR := NULL
	   ,patrval2  VARCHAR := NULL
	   ,patrname3 VARCHAR := NULL
	   ,patrval3  VARCHAR := NULL
	   ,patrname4 VARCHAR := NULL
	   ,patrval4  VARCHAR := NULL
	   ,patrname5 VARCHAR := NULL
	   ,patrval5  VARCHAR := NULL
	   ,patrname6 VARCHAR := NULL
	   ,patrval6  VARCHAR := NULL
	   ,patrname7 VARCHAR := NULL
	   ,patrval7  VARCHAR := NULL
	   ,patrname8 VARCHAR := NULL
	   ,patrval8  VARCHAR := NULL
	   ,patrname9 VARCHAR := NULL
	   ,patrval9  VARCHAR := NULL
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.AddItem[' || pname || ']';
		vattrlist xmldecl.attributes;
		PROCEDURE add_
		(
			patrname  VARCHAR
		   ,patrvalue VARCHAR
		) IS
			i PLS_INTEGER;
		BEGIN
			IF patrname IS NOT NULL
			THEN
				i := nvl(vattrlist.last, 0) + 1;
				vattrlist(i).name := patrname;
				vattrlist(i).value := patrvalue;
			END IF;
		END;
	BEGIN
		vattrlist.delete;
		add_(patrname, patrval);
		add_(patrname2, patrval2);
		add_(patrname3, patrval3);
		add_(patrname4, patrval4);
		add_(patrname5, patrval5);
		add_(patrname6, patrval6);
		add_(patrname7, patrval7);
		add_(patrname8, patrval8);
		add_(patrname9, patrval9);
		xmlproducer.writeelement(sxmlsid, pname, pvalue, vattrlist);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE additeml
	(
		pname     VARCHAR
	   ,pvalue    CLOB
	   ,patrname  VARCHAR := NULL
	   ,patrval   VARCHAR := NULL
	   ,patrname2 VARCHAR := NULL
	   ,patrval2  VARCHAR := NULL
	   ,patrname3 VARCHAR := NULL
	   ,patrval3  VARCHAR := NULL
	   ,patrname4 VARCHAR := NULL
	   ,patrval4  VARCHAR := NULL
	   ,patrname5 VARCHAR := NULL
	   ,patrval5  VARCHAR := NULL
	   ,patrname6 VARCHAR := NULL
	   ,patrval6  VARCHAR := NULL
	   ,patrname7 VARCHAR := NULL
	   ,patrval7  VARCHAR := NULL
	   ,patrname8 VARCHAR := NULL
	   ,patrval8  VARCHAR := NULL
	   ,patrname9 VARCHAR := NULL
	   ,patrval9  VARCHAR := NULL
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.AddItemL[clob][' || pname || ']';
		vattrlist xmldecl.attributes;
		PROCEDURE add_
		(
			patrname  VARCHAR
		   ,patrvalue VARCHAR
		) IS
			i PLS_INTEGER;
		BEGIN
			IF patrname IS NOT NULL
			THEN
				i := nvl(vattrlist.last, 0) + 1;
				vattrlist(i).name := patrname;
				vattrlist(i).value := patrvalue;
			END IF;
		END;
	BEGIN
		vattrlist.delete;
		add_(patrname, patrval);
		add_(patrname2, patrval2);
		add_(patrname3, patrval3);
		add_(patrname4, patrval4);
		add_(patrname5, patrval5);
		add_(patrname6, patrval6);
		add_(patrname7, patrval7);
		add_(patrname8, patrval8);
		add_(patrname9, patrval9);
		xmlproducer.writeelement_clob(sxmlsid, pname, pvalue, vattrlist);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION finish RETURN xmltype IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.Finish()';
		vxml xmltype;
		vstr CLOB;
	BEGIN
		xmlproducer.writeenddocument(sxmlsid);
		vstr := clobstream.getlocator(sxmlsid);
		vxml := xmltype(vstr);
		say(cprocname || ' : Msg = ' || substr(vxml.getclobval, 1, types.cmaxlenchar));
		stream.close(sxmlsid);
		sxmlsid := NULL;
		RETURN vxml;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			IF sxmlsid IS NOT NULL
			THEN
				stream.closeabort(sxmlsid);
			END IF;
			RAISE;
	END;

	FUNCTION finish_arrtext RETURN types.arrtext IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.Finish[arrtext]()';
		vatext types.arrtext;
		vstr   CLOB;
	BEGIN
		xmlproducer.writeenddocument(sxmlsid);
		vstr   := clobstream.getlocator(sxmlsid);
		vatext := htools.clob2arrtext(vstr);
		say(cprocname || ' : Msg = ' || vatext(1));
		stream.close(sxmlsid);
		sxmlsid := NULL;
		RETURN vatext;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			IF sxmlsid IS NOT NULL
			THEN
				stream.closeabort(sxmlsid);
			END IF;
			RAISE;
	END;

	PROCEDURE finishwithcontinuestream IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.FinishWithContinueStream';
	BEGIN
		xmlproducer.writeenddocument(sxmlsid);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	FUNCTION getcurrentsid RETURN NUMBER IS
	BEGIN
		RETURN sxmlsid;
	END;

	PROCEDURE opentag
	(
		pname     VARCHAR
	   ,patrname  VARCHAR := NULL
	   ,patrval   VARCHAR := NULL
	   ,patrname2 VARCHAR := NULL
	   ,patrval2  VARCHAR := NULL
	   ,patrname3 VARCHAR := NULL
	   ,patrval3  VARCHAR := NULL
	   ,patrname4 VARCHAR := NULL
	   ,patrval4  VARCHAR := NULL
	   ,patrname5 VARCHAR := NULL
	   ,patrval5  VARCHAR := NULL
	   ,patrname6 VARCHAR := NULL
	   ,patrval6  VARCHAR := NULL
	   ,patrname7 VARCHAR := NULL
	   ,patrval7  VARCHAR := NULL
	   ,patrname8 VARCHAR := NULL
	   ,patrval8  VARCHAR := NULL
	   ,patrname9 VARCHAR := NULL
	   ,patrval9  VARCHAR := NULL
	) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.OpenTag[' || pname || ']';
		vattrlist xmldecl.attributes;
		PROCEDURE add_
		(
			patrname  VARCHAR
		   ,patrvalue VARCHAR
		) IS
			i PLS_INTEGER;
		BEGIN
			IF patrname IS NOT NULL
			THEN
				i := nvl(vattrlist.last, 0) + 1;
				vattrlist(i).name := patrname;
				vattrlist(i).value := patrvalue;
			END IF;
		END;
	BEGIN
		vattrlist.delete;
		add_(patrname, patrval);
		add_(patrname2, patrval2);
		add_(patrname3, patrval3);
		add_(patrname4, patrval4);
		add_(patrname5, patrval5);
		add_(patrname6, patrval6);
		add_(patrname7, patrval7);
		add_(patrname8, patrval8);
		add_(patrname9, patrval9);
		xmlproducer.writebegintag(sxmlsid, pname, vattrlist);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE closetag(pname VARCHAR) IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.CloseTag(' || pname || ')';
	BEGIN
		xmlproducer.writeendtag(sxmlsid, pname);
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			RAISE;
	END;

	PROCEDURE abort IS
		cprocname CONSTANT VARCHAR(1000) := cpackage || '.Abort()';
	BEGIN
		say(cprocname || ' : start... sxmlsid = ' || sxmlsid);
		IF sxmlsid IS NOT NULL
		THEN
			xmlproducer.writeenddocument(sxmlsid);
			stream.closeabort(sxmlsid);
			sxmlsid := NULL;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			error.save(cprocname);
			error.clear;
	END;

END;
/
