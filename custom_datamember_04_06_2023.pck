CREATE OR REPLACE PACKAGE custom_datamember AS
	crevision CONSTANT VARCHAR2(30) := '$Rev: 41386 $';

	FUNCTION getversion RETURN VARCHAR2;

	FUNCTION deletedatamember(vmbrcode IN NUMBER) RETURN NUMBER;
	FUNCTION datamemberdelete
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	) RETURN NUMBER;
	FUNCTION deletegroupdatamember
	(
		ptype IN NUMBER
	   ,pname IN CHAR
	) RETURN NUMBER;

	FUNCTION dialogedit
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pstr  IN CHAR
	) RETURN NUMBER;
	PROCEDURE dialogeditproc
	(
		pwhat IN CHAR
	   ,pid   IN NUMBER
	   ,pitem IN CHAR
	   ,pcmd  IN NUMBER
	);
	PROCEDURE dialogitemeditproc
	(
		pwhat IN CHAR
	   ,pid   IN NUMBER
	   ,pitem IN CHAR
	   ,pcmd  IN NUMBER
	);
	FUNCTION getcount RETURN NUMBER;
	FUNCTION gettext(precno IN NUMBER) RETURN VARCHAR;
	FUNCTION checkname(pname IN VARCHAR) RETURN BOOLEAN;

	FUNCTION getchar
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	) RETURN VARCHAR;
	FUNCTION getlongchar
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	) RETURN VARCHAR;
	FUNCTION getdate
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	) RETURN DATE;
	FUNCTION getnumber
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	) RETURN NUMBER;

	FUNCTION gethistorydate
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	   ,pdate IN DATE
	) RETURN DATE;
	FUNCTION gethistorynumber
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	   ,pdate IN DATE
	) RETURN NUMBER;
	FUNCTION gethistorynext
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	   ,pdate IN DATE
	) RETURN DATE;
	FUNCTION gethistoryintervaldate
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	   ,pdate IN DATE
	) RETURN DATE;
	FUNCTION getintervalchar
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pinterval IN NUMBER
	) RETURN VARCHAR;
	FUNCTION getintervaldate
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pinterval IN NUMBER
	) RETURN DATE;
	FUNCTION getintervalnumber
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pinterval IN NUMBER
	) RETURN NUMBER;
	FUNCTION getintervalnext
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pinterval IN NUMBER
	) RETURN NUMBER;
	FUNCTION getintervalhistorychar
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	) RETURN VARCHAR;

	FUNCTION getintervalhistorynumber
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	) RETURN NUMBER;
	FUNCTION getintervalhistorynextdate
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	   ,pdate IN DATE
	) RETURN DATE;
	FUNCTION getintervalhistorynextinterval
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	) RETURN NUMBER;

	FUNCTION getremark(pmbrcode IN NUMBER) RETURN VARCHAR;
	FUNCTION getname(pmbrcode IN NUMBER) RETURN VARCHAR;
	FUNCTION gettype
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	) RETURN NUMBER;

	FUNCTION setchar
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pcvalue     VARCHAR
	   ,premark     VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION setlongchar
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pcvalue     IN VARCHAR
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION setdate
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdvalue     DATE
	   ,premark     VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION setnumber
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pnvalue     NUMBER
	   ,premark     VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION sethistorychar
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdate       IN DATE
	   ,pcvalue     VARCHAR
	   ,premark     VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION sethistorydate
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdate       IN DATE
	   ,pdvalue     DATE
	   ,premark     VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION sethistorynumber
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdate       IN DATE
	   ,pnvalue     NUMBER
	   ,premark     VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION setintervalchar
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pinterval   IN NUMBER
	   ,pcvalue     VARCHAR
	   ,premark     VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION setintervaldate
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pinterval   IN NUMBER
	   ,pdvalue     DATE
	   ,premark     VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION setintervalnumber
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pinterval   IN NUMBER
	   ,pnvalue     NUMBER
	   ,premark     VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION setintervalhistorychar
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdate       IN DATE
	   ,pinterval   IN NUMBER
	   ,pcvalue     VARCHAR
	   ,premark     VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION setintervalhistorydate
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdate       IN DATE
	   ,pinterval   IN NUMBER
	   ,pdvalue     DATE
	   ,premark     VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;
	FUNCTION setintervalhistorynumber
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdate       IN DATE
	   ,pinterval   IN NUMBER
	   ,pnvalue     NUMBER
	   ,premark     VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER;

	FUNCTION getnamecount(vname IN VARCHAR) RETURN NUMBER;
	PROCEDURE setbranch(vbranch IN NUMBER);
	FUNCTION getbranch RETURN NUMBER;

	FUNCTION adddatamember
	(
		vtype   IN NUMBER
	   ,vname   IN VARCHAR
	   ,vremark IN VARCHAR
	) RETURN NUMBER;
	PROCEDURE updatedatamember
	(
		vmbrcode IN NUMBER
	   ,vname    IN VARCHAR
	   ,vremark  IN VARCHAR
	);

	FUNCTION getdialog
	(
		pmbrtype  IN NUMBER
	   ,ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN VARCHAR
	   ,premark   IN VARCHAR
	   ,pcanedit  IN BOOLEAN := TRUE
	   ,proundpos IN NUMBER := -1
	) RETURN NUMBER;

	single           CONSTANT NUMBER := 1;
	history          CONSTANT NUMBER := 2;
	INTERVAL         CONSTANT NUMBER := 3;
	interval_history CONSTANT NUMBER := 4;

	svcurrenttype NUMBER;
	svcurrentcode NUMBER;
	svupdated     BOOLEAN;
	svnewmbrcode  NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY custom_datamember AS
	cbodyrevision CONSTANT VARCHAR2(30) := '$Rev: 44809 $';
	cpackagename  CONSTANT VARCHAR2(30) := 'DataMember';

	TYPE varchar25table IS TABLE OF VARCHAR(25) INDEX BY BINARY_INTEGER;

	scurbranch   NUMBER;
	svdynahandle NUMBER;
	svscrollcnt  NUMBER;
	svscrollcur  NUMBER;
	svdatamember tdatamember%ROWTYPE;
	svtypename   varchar25table;

	PROCEDURE scrollerprepare;
	PROCEDURE scrollerrefresh;
	FUNCTION dialogitemedit RETURN NUMBER;
	FUNCTION getnextdata
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	   ,pno       IN NUMBER
	) RETURN tdatamembersingle%ROWTYPE;

	FUNCTION getdata
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	) RETURN tdatamembersingle%ROWTYPE;
	FUNCTION setdata
	(
		prow      IN tdatamembersingle%ROWTYPE
	   ,ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	   ,premark   IN VARCHAR
	) RETURN NUMBER;
	FUNCTION setdataautonomous
	(
		prow      IN tdatamembersingle%ROWTYPE
	   ,ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	   ,premark   IN VARCHAR
	) RETURN NUMBER;
	FUNCTION getcurbranch RETURN NUMBER;

	FUNCTION getversion RETURN VARCHAR2 IS
	BEGIN
		RETURN service.formatpackageversion(cpackagename, crevision, cbodyrevision);
	END;

	FUNCTION datamemberdelete
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	) RETURN NUMBER IS
	
		vname tdatamember.name%TYPE := upper(ltrim(rtrim(pname)));
	
		vbranch NUMBER := getcurbranch();
	BEGIN
		SELECT *
		INTO   svdatamember
		FROM   tdatamember
		WHERE  branch = vbranch
		AND    TYPE = ptype
		AND    code = pcode
		AND    NAME = vname;
		RETURN custom_datamember.deletedatamember(svdatamember.mbrcode);
	EXCEPTION
		WHEN no_data_found THEN
			RETURN 0;
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'custom_datamember.DataMemberDelete');
			RETURN SQLCODE;
	END;

	FUNCTION deletegroupdatamember
	(
		ptype IN NUMBER
	   ,pname IN CHAR
	) RETURN NUMBER IS
	
		vname tdatamember.name%TYPE := upper(ltrim(rtrim(pname)));
	
		vbranch NUMBER := getcurbranch();
		vret    NUMBER;
		CURSOR cdatamemberfordelete IS
			SELECT mbrcode
				  ,mbrtype
			FROM   tdatamember
			WHERE  branch = vbranch
			AND    TYPE = ptype
			AND    NAME = vname;
	BEGIN
		SAVEPOINT spdeletegroupdmbr;
		FOR i IN cdatamemberfordelete
		LOOP
			svdatamember.mbrcode := i.mbrcode;
			svdatamember.mbrtype := i.mbrtype;
			vret                 := custom_datamember.deletedatamember(svdatamember.mbrcode);
			IF (vret != 0)
			THEN
				ROLLBACK TO spdeletegroupdmbr;
				RETURN vret;
			END IF;
		END LOOP;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'custom_datamember.DeleteGroupDataMember');
			ROLLBACK TO spdeletegroupdmbr;
			RETURN SQLCODE;
	END;

	FUNCTION dialogedit
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pstr  IN CHAR
	) RETURN NUMBER IS
		vid NUMBER;
	BEGIN
		svupdated     := FALSE;
		svcurrenttype := ptype;
		svcurrentcode := pcode;
		vid           := browser.new('DataMember', 'List of additional data', 0, 0, 76, 19);
		dialog.statictext(vid, (74 - length(pstr)) / 2 + 1, 2, pstr);
	
		browser.scroller(vid, 1, 5, 74, 12);
	
		dialog.listaddfield(vid, 'SCROLLER', 'TYPE', 'C', 3, 1);
		dialog.listaddfield(vid, 'SCROLLER', 'NAME', 'C', 20, 1);
		dialog.listaddfield(vid, 'SCROLLER', 'COMMENT', 'C', 48, 1);
		browser.setcaption(vid, 'SCROLLER', 'Type~Name~Comment');
	
		dialog.button(vid, 'Add', 18, 17, 12, '    Add', 0, 0, 'Add data item');
		dialog.button(vid, 'Delete', 32, 17, 12, '  Delete', 0, 0, 'Delete data item');
		dialog.button(vid, 'Exit', 46, 17, 12, '   Exit', dialog.cmcancel, 0, 'Exit');
		browser.setdialogpre(vid, 'custom_datamember.DialogEditProc');
		browser.setdialogpost(vid, 'custom_datamember.DialogEditProc');
		dialog.setitempre(vid, 'Scroller', 'custom_datamember.DialogEditProc', dialog.proctype);
		dialog.setitempre(vid, 'Add', 'custom_datamember.DialogEditProc', dialog.proctype);
		dialog.setitempre(vid, 'Delete', 'custom_datamember.DialogEditProc', dialog.proctype);
		dialog.setitempost(vid, 'Scroller', 'custom_datamember.DialogEditProc', dialog.proctype);
		dialog.setitempost(vid, 'Add', 'custom_datamember.DialogEditProc', dialog.proctype);
		dialog.setitempost(vid, 'Delete', 'custom_datamember.DialogEditProc', dialog.proctype);
		RETURN vid;
	END;

	PROCEDURE dialogeditproc
	(
		pwhat IN CHAR
	   ,pid   IN NUMBER
	   ,pitem IN CHAR
	   ,pcmd  IN NUMBER
	) IS
		vstr     VARCHAR(20);
		vdialog  NUMBER;
		vcmd     NUMBER;
		vmbrcode NUMBER;
		vbranch  NUMBER := getcurbranch();
	BEGIN
		vdialog := 0;
		IF (pwhat = dialog.wtdialogpre)
		THEN
			custom_datamember.scrollerprepare;
			IF (svscrollcnt = 0)
			THEN
				dialog.setitemattributies(pid, 'Delete', dialog.selectoff);
			END IF;
		ELSIF (pwhat = dialog.wtdialogpost)
		THEN
			IF (svdynahandle != 0)
			THEN
				dynaset.close(svdynahandle);
				svdynahandle := 0;
			END IF;
		ELSIF (pwhat = dialog.wtitempre)
		THEN
			IF (pitem = 'SCROLLER')
			THEN
				IF (svdatamember.mbrtype = single)
				THEN
					vdialog := datamembersingle.dialogedit(svdatamember.mbrcode);
				ELSIF (svdatamember.mbrtype = history)
				THEN
					vdialog := datamemberhistory.dialogedit(svdatamember.mbrcode);
				ELSIF (svdatamember.mbrtype = INTERVAL)
				THEN
					vdialog := datamemberinterval.dialogedit(svdatamember.mbrcode);
				ELSIF (svdatamember.mbrtype = interval_history)
				THEN
					vdialog := datamemberintervalhistory.dialogedit(svdatamember.mbrcode);
				END IF;
			ELSIF (pitem = 'ADD')
			THEN
				vdialog := custom_datamember.dialogitemedit;
			ELSIF (pitem = 'DELETE')
			THEN
				vdialog := service.dialogconfirm('Warning !'
												,'Data item will be deleted'
												,'Yes'
												,'Delete data item'
												,'No'
												,'Do not delete data item');
			END IF;
			dialog.setitemdialog(pid, pitem, vdialog);
		ELSIF (pwhat = dialog.wtitempost)
		THEN
			vdialog := dialog.getitemdialog(pid, pitem);
			IF (pitem = 'SCROLLER')
			THEN
				IF (svupdated)
				THEN
					svupdated := FALSE;
					SELECT COUNT(*)
					INTO   vcmd
					FROM   tdatamember
					WHERE  branch = vbranch
					AND    TYPE = svcurrenttype
					AND    code = svcurrentcode;
					IF (vcmd < svscrollcnt)
					THEN
						vcmd := svscrollcur;
						dynaset.recorddelete(svdynahandle, svscrollcur);
						svscrollcnt := svscrollcnt - 1;
						IF (vcmd > svscrollcnt)
						THEN
							vcmd := svscrollcnt;
						END IF;
						browser.scrollerrefresh(pid, vcmd);
						IF (svscrollcnt = 0)
						THEN
							dialog.setitemattributies(pid, 'Delete', dialog.selectoff);
						END IF;
					ELSE
						vstr := substr(dynaset.getkeys(svdynahandle, svscrollcur), 2, 18);
						custom_datamember.scrollerrefresh;
						FOR vcmd IN 1 .. svscrollcnt
						LOOP
							IF (vstr = substr(dynaset.getkeys(svdynahandle, vcmd), 2, 18))
							THEN
								browser.scrollerrefresh(pid, vcmd);
								EXIT;
							END IF;
						END LOOP;
					END IF;
				END IF;
			ELSIF (pitem = 'ADD')
			THEN
				IF (svupdated)
				THEN
					svupdated := FALSE;
					custom_datamember.scrollerrefresh;
					FOR vcmd IN 1 .. svscrollcnt
					LOOP
						vstr := substr(dynaset.getkeys(svdynahandle, vcmd), 2, 18);
						SELECT mbrcode
						INTO   vmbrcode
						FROM   tdatamember
						WHERE  ROWID = chartorowid(vstr);
						IF (svnewmbrcode = vmbrcode)
						THEN
							browser.scrollerrefresh(pid, vcmd);
							EXIT;
						END IF;
					END LOOP;
				END IF;
				IF (svscrollcnt != 0)
				THEN
					dialog.setitemattributies(pid, 'Delete', dialog.selecton);
				END IF;
			ELSIF (pitem = 'DELETE')
			THEN
				vcmd := dialog.getdialogcommand(vdialog);
				IF (vcmd = dialog.cmok)
				THEN
					vstr := substr(dynaset.getkeys(svdynahandle, svscrollcur), 2, 18);
					BEGIN
						SAVEPOINT xdelete;
						DELETE FROM tdatamember WHERE ROWID = chartorowid(vstr);
						COMMIT;
					EXCEPTION
						WHEN OTHERS THEN
							err.seterror(SQLCODE, 'DialogEditProc');
							ROLLBACK TO xdelete;
							service.sayerr(pid, 'Warning !');
					END;
					vcmd := svscrollcur;
					custom_datamember.scrollerrefresh;
					IF (svscrollcnt != 0)
					THEN
						IF (vcmd > svscrollcnt)
						THEN
							vcmd := svscrollcnt;
						END IF;
						browser.scrollerrefresh(pid, vcmd);
					ELSE
						browser.scrollerrefresh(pid, dialog.firstrecord);
						dialog.setitemattributies(pid, pitem, dialog.selectoff);
					END IF;
				END IF;
			END IF;
			dialog.destroy(vdialog);
			dialog.setitemdialog(pid, pitem, 0);
		END IF;
	END;

	FUNCTION dialogitemedit RETURN NUMBER IS
		vid NUMBER;
	BEGIN
		vid := dialog.new('Add data item', 0, 0, 40, 6);
		dialog.setexternalid(vid, 'custom_datamember.ItemEdit');
	
		dialog.inputchar(vid
						,'Type'
						,7
						,2
						,27
						,'Select type of added item from list and press <Enter>'
						,NULL
						,'Type:');
		dialog.listaddfield(vid, 'Type', 'TypeName', 'C', 25, 1);
		dialog.listaddfield(vid, 'Type', 'Type', 'N', 5, 0);
		dialog.listaddrecord(vid
							,'Type'
							,svtypename(custom_datamember.single) || '~' ||
							 to_char(custom_datamember.single) || '~'
							,0
							,0);
		dialog.listaddrecord(vid
							,'Type'
							,svtypename(custom_datamember.history) || '~' ||
							 to_char(custom_datamember.history) || '~'
							,0
							,0);
		dialog.listaddrecord(vid
							,'Type'
							,svtypename(custom_datamember.interval) || '~' ||
							 to_char(custom_datamember.interval) || '~'
							,0
							,0);
		dialog.listaddrecord(vid
							,'Type'
							,svtypename(custom_datamember.interval_history) || '~' ||
							 to_char(custom_datamember.interval_history) || '~'
							,0
							,0);
		dialog.setitemattributies(vid, 'Type', dialog.updateoff);
		dialog.button(vid, 'Yes', 10, 4, 9, 'Enter', dialog.cmok, 0, ' ');
		dialog.button(vid, 'No', 22, 4, 9, 'Cancel', dialog.cmcancel, 0, ' ');
		dialog.setitemattributies(vid, 'Yes', dialog.defaulton);
		dialog.setitempre(vid, 'Yes', 'custom_datamember.DialogItemEditProc', dialog.proctype);
		dialog.setitempost(vid, 'Yes', 'custom_datamember.DialogItemEditProc', dialog.proctype);
		RETURN vid;
	END;

	PROCEDURE dialogitemeditproc
	(
		pwhat IN CHAR
	   ,pid   IN NUMBER
	   ,pitem IN CHAR
	   ,pcmd  IN NUMBER
	) IS
		vmbrcode NUMBER;
		vno      NUMBER;
		vname    VARCHAR(40);
		vremark  VARCHAR(250);
		vtype    NUMBER;
		vdialog  NUMBER;
	BEGIN
		IF (pwhat = dialog.wtitempre)
		THEN
			vdialog := 0;
			IF (dialog.getchar(pid, 'Type') IS NOT NULL)
			THEN
				vno := dialog.getlistcurrentrecordnumber(pid, 'Type');
				dialog.setitemcommand(pid, pitem, dialog.cmok);
				IF (vno = single)
				THEN
					vdialog := datamembersingle.dialogedit(NULL);
				ELSIF (vno = history)
				THEN
					vdialog := datamemberhistory.dialogedit(NULL);
				ELSIF (vno = INTERVAL)
				THEN
					vdialog := datamemberinterval.dialogedit(NULL);
				ELSIF (vno = interval_history)
				THEN
					vdialog := datamemberintervalhistory.dialogedit(NULL);
				END IF;
			ELSE
				dialog.goitem(pid, 'Type');
				dialog.sethothint(pid, 'Select type...');
			END IF;
			dialog.setitemdialog(pid, pitem, vdialog);
		ELSIF (pwhat = dialog.wtitempost)
		THEN
			vdialog := dialog.getitemdialog(pid, pitem);
			IF (vdialog != 0)
			THEN
				dialog.destroy(vdialog);
				dialog.setitemdialog(pid, pitem, 0);
			END IF;
		END IF;
	END;

	FUNCTION getcount RETURN NUMBER IS
	BEGIN
		RETURN svscrollcnt;
	END;

	FUNCTION gettext(precno IN NUMBER) RETURN VARCHAR IS
		vstr  VARCHAR(250);
		vhint VARCHAR(40);
	BEGIN
		svscrollcur := precno;
		vstr        := substr(dynaset.getkeys(svdynahandle, precno), 2, 18);
		SELECT * INTO svdatamember FROM tdatamember WHERE ROWID = chartorowid(vstr);
		IF (svdatamember.mbrtype = custom_datamember.single)
		THEN
			vstr  := ' S';
			vhint := svtypename(custom_datamember.single);
		ELSIF (svdatamember.mbrtype = custom_datamember.history)
		THEN
			vstr  := ' H';
			vhint := svtypename(custom_datamember.history);
		ELSIF (svdatamember.mbrtype = custom_datamember.interval)
		THEN
			vstr  := ' I';
			vhint := svtypename(custom_datamember.interval);
		ELSIF (svdatamember.mbrtype = custom_datamember.interval_history)
		THEN
			vstr  := 'IH';
			vhint := svtypename(custom_datamember.interval_history);
		ELSE
			vstr  := '??';
			vhint := 'Unknown data item type';
		END IF;
		vstr := vstr || '~' || svdatamember.name || '~' || svdatamember.remark || '~' || vhint;
		RETURN vstr;
	EXCEPTION
		WHEN OTHERS THEN
			RETURN NULL;
	END;

	FUNCTION getchar
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	) RETURN VARCHAR IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getdata(ptype, pcode, pname, NULL, NULL);
		RETURN vdatamemberrow.cvalue;
	END;

	FUNCTION getlongchar
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	) RETURN VARCHAR IS
		vcounter   NUMBER;
		vcharvalue VARCHAR2(4000);
	BEGIN
	
		vcounter   := to_number(custom_datamember.getchar(ptype, pcode, pname));
		vcounter   := nvl(vcounter, 0);
		vcharvalue := custom_datamember.getchar(ptype, pcode, pname || '1');
	
		FOR j IN 2 .. vcounter
		LOOP
			vcharvalue := vcharvalue ||
						  custom_datamember.getchar(ptype, pcode, pname || ltrim(rtrim(to_char(j))));
		END LOOP;
	
		RETURN vcharvalue;
	
	END;

	FUNCTION getdate
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	) RETURN DATE IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getdata(ptype, pcode, pname, NULL, NULL);
		RETURN vdatamemberrow.dvalue;
	END;

	FUNCTION getnumber
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getdata(ptype, pcode, pname, NULL, NULL);
		RETURN vdatamemberrow.nvalue;
	END;

	FUNCTION gethistorychar
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	   ,pdate IN DATE
	) RETURN VARCHAR IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getdata(ptype, pcode, pname, pdate, NULL);
		RETURN vdatamemberrow.cvalue;
	END;

	FUNCTION gethistorydate
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	   ,pdate IN DATE
	) RETURN DATE IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getdata(ptype, pcode, pname, pdate, NULL);
		RETURN vdatamemberrow.dvalue;
	END;

	FUNCTION gethistorynumber
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	   ,pdate IN DATE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getdata(ptype, pcode, pname, pdate, NULL);
		RETURN vdatamemberrow.nvalue;
	END;

	FUNCTION gethistorynext
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	   ,pdate IN DATE
	) RETURN DATE IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getnextdata(ptype, pcode, pname, pdate, NULL, NULL);
		RETURN vdatamemberrow.dvalue;
	END;

	FUNCTION gethistoryintervaldate
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	   ,pdate IN DATE
	) RETURN DATE IS
		vmbrcode tdatamember.mbrcode%TYPE;
		vmbrdate tdatamemberintervalhistory.mbrdate%TYPE;
	
		vname tdatamember.name%TYPE := upper(pname);
	
		vbranch NUMBER := getcurbranch();
	BEGIN
		SELECT mbrcode
		INTO   vmbrcode
		FROM   tdatamember
		WHERE  branch = vbranch
		AND    TYPE = ptype
		AND    code = pcode
		AND    NAME = vname
		AND    mbrtype = custom_datamember.interval_history;
		SELECT MAX(mbrdate)
		INTO   vmbrdate
		FROM   tdatamemberintervalhistory
		WHERE  mbrcode = vmbrcode
		AND    mbrdate <= pdate;
		RETURN vmbrdate;
	EXCEPTION
		WHEN no_data_found THEN
		
			RETURN NULL;
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'custom_datamember.GetHistoryIntervalDate');
			RETURN NULL;
	END;

	FUNCTION getintervalchar
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pinterval IN NUMBER
	) RETURN VARCHAR IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getdata(ptype, pcode, pname, NULL, pinterval);
		RETURN vdatamemberrow.cvalue;
	END;

	FUNCTION getintervaldate
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pinterval IN NUMBER
	) RETURN DATE IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getdata(ptype, pcode, pname, NULL, pinterval);
		RETURN vdatamemberrow.dvalue;
	END;

	FUNCTION getintervalnumber
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pinterval IN NUMBER
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getdata(ptype, pcode, pname, NULL, pinterval);
		RETURN vdatamemberrow.nvalue;
	END;

	FUNCTION getintervalnext
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pinterval IN NUMBER
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		dbms_output.put_line('getintervalnext: ' || ptype || '|' || pcode || '|' || pname || '|' ||
							 pinterval);
		vdatamemberrow := custom_datamember.getnextdata(ptype, pcode, pname, NULL, pinterval, NULL);
		dbms_output.put_line('vdatamemberrow ' || vdatamemberrow.nvalue);
	
		RETURN vdatamemberrow.nvalue;
	END;

	FUNCTION getintervalhistorychar
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	) RETURN VARCHAR IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getdata(ptype, pcode, pname, pdate, pinterval);
		RETURN vdatamemberrow.cvalue;
	END;

	FUNCTION getintervalhistorydate
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	) RETURN DATE IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getdata(ptype, pcode, pname, pdate, pinterval);
		RETURN vdatamemberrow.dvalue;
	END;

	FUNCTION getintervalhistorynumber
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getdata(ptype, pcode, pname, pdate, pinterval);
		RETURN vdatamemberrow.nvalue;
	END;

	FUNCTION getintervalhistorynextdate
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	   ,pdate IN DATE
	) RETURN DATE IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getnextdata(ptype, pcode, pname, pdate, NULL, 1);
		RETURN vdatamemberrow.dvalue;
	END;

	FUNCTION getintervalhistorynextinterval
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow := custom_datamember.getnextdata(ptype, pcode, pname, pdate, pinterval, 2);
		RETURN vdatamemberrow.nvalue;
	END;

	FUNCTION getremark(pmbrcode IN NUMBER) RETURN VARCHAR IS
		vremark tdatamember.remark%TYPE;
		vbranch NUMBER := getcurbranch();
	BEGIN
		SELECT remark
		INTO   vremark
		FROM   tdatamember
		WHERE  branch = vbranch
		AND    mbrcode = pmbrcode;
		RETURN vremark;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'custom_datamember.GetRemark');
			RETURN NULL;
	END;

	FUNCTION getname(pmbrcode IN NUMBER) RETURN VARCHAR IS
		vname   tdatamember.name%TYPE;
		vbranch NUMBER := getcurbranch();
	BEGIN
		SELECT NAME
		INTO   vname
		FROM   tdatamember
		WHERE  branch = vbranch
		AND    mbrcode = pmbrcode;
		RETURN vname;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'custom_datamember.GetRemark');
			RETURN NULL;
	END;

	FUNCTION gettype
	(
		ptype IN NUMBER
	   ,pcode IN NUMBER
	   ,pname IN CHAR
	) RETURN NUMBER IS
		vmbrtype tdatamember.mbrtype%TYPE;
	
		vname tdatamember.name%TYPE := upper(pname);
	
		vbranch NUMBER := getcurbranch();
	BEGIN
		SELECT mbrtype
		INTO   vmbrtype
		FROM   tdatamember
		WHERE  branch = vbranch
		AND    TYPE = ptype
		AND    code = pcode
		AND    NAME = vname;
	
		RETURN vmbrtype;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'custom_datamember.GetType');
			RETURN NULL;
	END;

	FUNCTION setchar
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pcvalue     IN VARCHAR
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow.cvalue := pcvalue;
	
		IF pautonomous
		THEN
			RETURN custom_datamember.setdataautonomous(vdatamemberrow
													  ,ptype
													  ,pcode
													  ,pname
													  ,NULL
													  ,NULL
													  ,premark);
		ELSE
		
			RETURN custom_datamember.setdata(vdatamemberrow
											,ptype
											,pcode
											,pname
											,NULL
											,NULL
											,premark);
		END IF;
	END;

	FUNCTION setlongchar
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pcvalue     IN VARCHAR
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vcvalue      VARCHAR2(4000);
		tmpcvalue    VARCHAR2(4000);
		maxstrlength NUMBER;
		vret         NUMBER;
		vcounter     NUMBER;
	BEGIN
		vcvalue      := pcvalue;
		vcounter     := 0;
		maxstrlength := 250;
	
		IF length(vcvalue) > maxstrlength
		THEN
			WHILE length(vcvalue) > maxstrlength
			LOOP
				tmpcvalue := substr(vcvalue, 1, maxstrlength);
				vcounter  := vcounter + 1;
				vret      := custom_datamember.setchar(ptype
													  ,pcode
													  ,pname || ltrim(rtrim(to_char(vcounter)))
													  ,tmpcvalue
													  ,premark
													  ,pautonomous);
				vcvalue   := substr(vcvalue, maxstrlength + 1);
			END LOOP;
			IF length(vcvalue) > 0
			THEN
				vcounter := vcounter + 1;
				vret     := custom_datamember.setchar(ptype
													 ,pcode
													 ,pname || ltrim(rtrim(to_char(vcounter)))
													 ,vcvalue
													 ,premark
													 ,pautonomous);
			END IF;
		ELSE
			vcounter := 1;
			vret     := custom_datamember.setchar(ptype
												 ,pcode
												 ,pname || ltrim(rtrim(to_char(vcounter)))
												 ,vcvalue
												 ,premark
												 ,pautonomous);
		END IF;
	
		RETURN custom_datamember.setchar(ptype
										,pcode
										,pname
										,ltrim(rtrim(to_char(vcounter)))
										,premark
										,pautonomous);
	
	END;

	FUNCTION setdate
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdvalue     IN DATE
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow.dvalue := pdvalue;
	
		IF pautonomous
		THEN
			RETURN custom_datamember.setdataautonomous(vdatamemberrow
													  ,ptype
													  ,pcode
													  ,pname
													  ,NULL
													  ,NULL
													  ,premark);
		ELSE
		
			RETURN custom_datamember.setdata(vdatamemberrow
											,ptype
											,pcode
											,pname
											,NULL
											,NULL
											,premark);
		END IF;
	END;

	FUNCTION setnumber
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pnvalue     IN NUMBER
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow.nvalue := pnvalue;
	
		IF pautonomous
		THEN
			RETURN custom_datamember.setdataautonomous(vdatamemberrow
													  ,ptype
													  ,pcode
													  ,pname
													  ,NULL
													  ,NULL
													  ,premark);
		ELSE
		
			RETURN custom_datamember.setdata(vdatamemberrow
											,ptype
											,pcode
											,pname
											,NULL
											,NULL
											,premark);
		END IF;
	END;

	FUNCTION sethistorychar
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdate       IN DATE
	   ,pcvalue     IN VARCHAR
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow.cvalue := pcvalue;
	
		IF pautonomous
		THEN
			RETURN custom_datamember.setdataautonomous(vdatamemberrow
													  ,ptype
													  ,pcode
													  ,pname
													  ,pdate
													  ,NULL
													  ,premark);
		ELSE
		
			RETURN custom_datamember.setdata(vdatamemberrow
											,ptype
											,pcode
											,pname
											,pdate
											,NULL
											,premark);
		END IF;
	END;

	FUNCTION sethistorydate
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdate       IN DATE
	   ,pdvalue     IN DATE
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow.dvalue := pdvalue;
	
		IF pautonomous
		THEN
			RETURN custom_datamember.setdataautonomous(vdatamemberrow
													  ,ptype
													  ,pcode
													  ,pname
													  ,pdate
													  ,NULL
													  ,premark);
		ELSE
		
			RETURN custom_datamember.setdata(vdatamemberrow
											,ptype
											,pcode
											,pname
											,pdate
											,NULL
											,premark);
		END IF;
	END;

	FUNCTION sethistorynumber
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdate       IN DATE
	   ,pnvalue     IN NUMBER
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow.nvalue := pnvalue;
	
		IF pautonomous
		THEN
			RETURN custom_datamember.setdataautonomous(vdatamemberrow
													  ,ptype
													  ,pcode
													  ,pname
													  ,pdate
													  ,NULL
													  ,premark);
		ELSE
		
			RETURN custom_datamember.setdata(vdatamemberrow
											,ptype
											,pcode
											,pname
											,pdate
											,NULL
											,premark);
		END IF;
	END;

	FUNCTION setintervalchar
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pinterval   IN NUMBER
	   ,pcvalue     IN VARCHAR
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow.cvalue := pcvalue;
	
		IF pautonomous
		THEN
			RETURN custom_datamember.setdataautonomous(vdatamemberrow
													  ,ptype
													  ,pcode
													  ,pname
													  ,NULL
													  ,pinterval
													  ,premark);
		ELSE
		
			RETURN custom_datamember.setdata(vdatamemberrow
											,ptype
											,pcode
											,pname
											,NULL
											,pinterval
											,premark);
		END IF;
	END;

	FUNCTION setintervaldate
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pinterval   IN NUMBER
	   ,pdvalue     IN DATE
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow.dvalue := pdvalue;
	
		IF pautonomous
		THEN
			RETURN custom_datamember.setdataautonomous(vdatamemberrow
													  ,ptype
													  ,pcode
													  ,pname
													  ,NULL
													  ,pinterval
													  ,premark);
		ELSE
		
			RETURN custom_datamember.setdata(vdatamemberrow
											,ptype
											,pcode
											,pname
											,NULL
											,pinterval
											,premark);
		END IF;
	END;

	FUNCTION setintervalnumber
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pinterval   IN NUMBER
	   ,pnvalue     IN NUMBER
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow.nvalue := pnvalue;
	
		IF pautonomous
		THEN
			RETURN custom_datamember.setdataautonomous(vdatamemberrow
													  ,ptype
													  ,pcode
													  ,pname
													  ,NULL
													  ,pinterval
													  ,premark);
		ELSE
		
			RETURN custom_datamember.setdata(vdatamemberrow
											,ptype
											,pcode
											,pname
											,NULL
											,pinterval
											,premark);
		END IF;
	END;

	FUNCTION setintervalhistorychar
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdate       IN DATE
	   ,pinterval   IN NUMBER
	   ,pcvalue     IN VARCHAR
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow.cvalue := pcvalue;
	
		IF pautonomous
		THEN
			RETURN custom_datamember.setdataautonomous(vdatamemberrow
													  ,ptype
													  ,pcode
													  ,pname
													  ,pdate
													  ,pinterval
													  ,premark);
		ELSE
		
			RETURN custom_datamember.setdata(vdatamemberrow
											,ptype
											,pcode
											,pname
											,pdate
											,pinterval
											,premark);
		END IF;
	END;

	FUNCTION setintervalhistorydate
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdate       IN DATE
	   ,pinterval   IN NUMBER
	   ,pdvalue     IN DATE
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow.dvalue := pdvalue;
	
		IF pautonomous
		THEN
			RETURN custom_datamember.setdataautonomous(vdatamemberrow
													  ,ptype
													  ,pcode
													  ,pname
													  ,pdate
													  ,pinterval
													  ,premark);
		ELSE
		
			RETURN custom_datamember.setdata(vdatamemberrow
											,ptype
											,pcode
											,pname
											,pdate
											,pinterval
											,premark);
		END IF;
	END;

	FUNCTION setintervalhistorynumber
	(
		ptype       IN NUMBER
	   ,pcode       IN NUMBER
	   ,pname       IN CHAR
	   ,pdate       IN DATE
	   ,pinterval   IN NUMBER
	   ,pnvalue     IN NUMBER
	   ,premark     IN VARCHAR
	   ,pautonomous IN BOOLEAN := FALSE
	) RETURN NUMBER IS
		vdatamemberrow tdatamembersingle%ROWTYPE;
	BEGIN
		vdatamemberrow.nvalue := pnvalue;
	
		IF pautonomous
		THEN
			RETURN custom_datamember.setdataautonomous(vdatamemberrow
													  ,ptype
													  ,pcode
													  ,pname
													  ,pdate
													  ,pinterval
													  ,premark);
		ELSE
		
			RETURN custom_datamember.setdata(vdatamemberrow
											,ptype
											,pcode
											,pname
											,pdate
											,pinterval
											,premark);
		END IF;
	END;

	FUNCTION checkname(pname IN VARCHAR) RETURN BOOLEAN IS
		vname VARCHAR(50);
	BEGIN
		RETURN TRUE;
		vname := service.upperr(ltrim(rtrim(pname)));
		vname := translate(vname, 'ABCDEFJHIGKLMNOPQRSTUVWXYZ1234567890_', ' ');
		vname := rtrim(vname);
		IF (vname IS NOT NULL)
		THEN
			RETURN FALSE;
		ELSE
			RETURN TRUE;
		END IF;
	END;

	FUNCTION deletedatamember(vmbrcode IN NUMBER) RETURN NUMBER IS
		vbranch NUMBER := getcurbranch();
	BEGIN
		DELETE tdatamember
		WHERE  branch = vbranch
		AND    mbrcode = vmbrcode;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'custom_datamember.DeleteDataMember');
			RETURN SQLCODE;
	END;

	FUNCTION getdata
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	) RETURN tdatamembersingle%ROWTYPE IS
		vrow     tdatamembersingle%ROWTYPE;
		vmbrcode tdatamember.mbrcode%TYPE;
		vmbrtype tdatamember.mbrtype%TYPE;
	
		vname tdatamember.name%TYPE := upper(pname);
	
		vbranch NUMBER := getcurbranch();
	BEGIN
		/*      SELECT mbrcode
              ,mbrtype
        INTO   vmbrcode
              ,vmbrtype
        FROM   tdatamember
        WHERE  branch = vbranch
        AND    TYPE = ptype
        AND    code = pcode
        AND    
              
               NAME = vname;*/
	
		SELECT mbrcode
			  ,mbrtype
		INTO   vmbrcode
			  ,vmbrtype
		FROM   tdatamember
		WHERE  branch = 1
		AND    TYPE = 20
		AND    code = 17
		AND    
			  
			   NAME = 'INTERVAL';
	
		IF (vmbrtype = custom_datamember.single)
		THEN
			SELECT * INTO vrow FROM tdatamembersingle WHERE mbrcode = vmbrcode;
		ELSIF (vmbrtype = custom_datamember.history)
		THEN
			SELECT cvalue
				  ,dvalue
				  ,nvalue
			INTO   vrow.cvalue
				  ,vrow.dvalue
				  ,vrow.nvalue
			FROM   tdatamemberhistory
			WHERE  mbrcode = vmbrcode
			AND    mbrdate = (SELECT MAX(mbrdate)
							  FROM   tdatamemberhistory
							  WHERE  mbrcode = vmbrcode
							  AND    mbrdate <= pdate);
		ELSIF (vmbrtype = custom_datamember.interval)
		THEN
			/*    SELECT cvalue
                  ,dvalue
                  ,nvalue
            INTO   vrow.cvalue
                  ,vrow.dvalue
                  ,vrow.nvalue
            FROM   tdatamemberinterval
            WHERE  mbrcode = vmbrcode
            AND    mbrvalue = (SELECT MAX(mbrvalue)
                               FROM   tdatamemberinterval
                               WHERE  mbrcode = vmbrcode
                               AND    mbrvalue <= pinterval);*/
		
			SELECT cvalue
				  ,dvalue
				  ,nvalue
			INTO   vrow.cvalue
				  ,vrow.dvalue
				  ,vrow.nvalue
			FROM   tdatamemberinterval
			WHERE  mbrcode = vmbrcode
			AND    mbrvalue = (SELECT MAX(mbrvalue)
							   FROM   tdatamemberinterval
							   WHERE  mbrcode = vmbrcode
							   AND    mbrvalue <= 0);
		
		ELSIF (vmbrtype = custom_datamember.interval_history)
		THEN
			SELECT cvalue
				  ,dvalue
				  ,nvalue
			INTO   vrow.cvalue
				  ,vrow.dvalue
				  ,vrow.nvalue
			FROM   tdatamemberintervalhistory
			WHERE  mbrcode = vmbrcode
			AND    mbrvalue = (SELECT MAX(mbrvalue)
							   FROM   tdatamemberintervalhistory
							   WHERE  mbrcode = vmbrcode
							   AND    mbrvalue <= pinterval
							   AND    mbrdate = (SELECT MAX(mbrdate)
												 FROM   tdatamemberintervalhistory
												 WHERE  mbrcode = vmbrcode
												 AND    mbrdate <= pdate))
			AND    mbrdate = (SELECT MAX(mbrdate)
							  FROM   tdatamemberintervalhistory
							  WHERE  mbrcode = vmbrcode
							  AND    mbrdate <= pdate);
		END IF;
		RETURN vrow;
	EXCEPTION
		WHEN no_data_found THEN
		
			RETURN vrow;
		WHEN OTHERS THEN
			custom_s.err('custom_datamember.GetData   pType-' || ptype || '  pCode-' || pcode ||
						 '  pName-' || pname || '  pDate-' || pdate || '  pInterval-' || pinterval);
			custom_err.seterror(SQLCODE, 'custom_datamember.GetData');
			RETURN vrow;
	END;

	FUNCTION getnextdata
	(
		ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	   ,pno       IN NUMBER
	) RETURN tdatamembersingle%ROWTYPE IS
		vmbrcode tdatamember.mbrcode%TYPE;
		vmbrtype tdatamember.mbrtype%TYPE;
		vrow     tdatamembersingle%ROWTYPE;
	
		vname tdatamember.name%TYPE := upper(pname);
	
		vbranch NUMBER := getcurbranch();
	
	BEGIN
		dbms_output.put_line('vbranch:' || vbranch || '|' || 'ptype:' || ptype || '|' || 'pcode:' ||
							 pcode || '|' || 'vname:' || vname);
		SELECT mbrcode
			  ,mbrtype
		INTO   vmbrcode
			  ,vmbrtype
		FROM   tdatamember
		WHERE  branch = vbranch
		AND    TYPE = ptype
		AND    code = pcode
		AND    NAME = vname;
	
		IF (vmbrtype = custom_datamember.history)
		THEN
			SELECT MIN(mbrdate)
			INTO   vrow.dvalue
			FROM   tdatamemberhistory
			WHERE  mbrcode = vmbrcode
			AND    ((pdate IS NULL) OR (mbrdate > pdate));
		ELSIF (vmbrtype = custom_datamember.interval)
		THEN
			SELECT MIN(mbrvalue)
			INTO   vrow.nvalue
			FROM   tdatamemberinterval
			WHERE  mbrcode = vmbrcode
			AND    ((pinterval IS NULL) OR (mbrvalue > pinterval));
		ELSIF (vmbrtype = custom_datamember.interval_history)
		THEN
			IF (pno = 1)
			THEN
				SELECT MIN(mbrdate)
				INTO   vrow.dvalue
				FROM   tdatamemberintervalhistory
				WHERE  mbrcode = vmbrcode
				AND    ((pdate IS NULL) OR (mbrdate > pdate));
			ELSE
				SELECT MIN(mbrvalue)
				INTO   vrow.nvalue
				FROM   tdatamemberintervalhistory
				WHERE  mbrcode = vmbrcode
				AND    ((pdate IS NULL) OR (mbrdate = pdate))
				AND    ((pinterval IS NULL) OR (mbrvalue > pinterval));
			END IF;
		END IF;
	
		RETURN vrow;
	EXCEPTION
		WHEN no_data_found THEN
		
			RETURN vrow;
		WHEN OTHERS THEN
			custom_err.seterror(SQLCODE, 'custom_datamember.GetNextData');
			RETURN vrow;
	END;

	FUNCTION setdata
	(
		prow      IN tdatamembersingle%ROWTYPE
	   ,ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	   ,premark   IN VARCHAR
	) RETURN NUMBER IS
		vmbrcode NUMBER;
		vmbrtype NUMBER;
	
		vname tdatamember.name%TYPE := upper(pname);
	
		vbranch NUMBER := getcurbranch();
	BEGIN
		SAVEPOINT datamembersetdata;
		BEGIN
			SELECT mbrcode
				  ,mbrtype
			INTO   vmbrcode
				  ,vmbrtype
			FROM   tdatamember
			WHERE  branch = vbranch
			AND    TYPE = ptype
			AND    code = pcode
			AND    NAME = vname;
			UPDATE tdatamember
			SET    remark = premark
			WHERE  branch = vbranch
			AND    TYPE = ptype
			AND    code = pcode
			AND    NAME = vname;
			IF (vmbrtype = custom_datamember.single)
			THEN
				UPDATE tdatamembersingle
				SET    cvalue = prow.cvalue
					  ,dvalue = prow.dvalue
					  ,nvalue = prow.nvalue
				WHERE  mbrcode = vmbrcode;
			ELSIF (vmbrtype = custom_datamember.history)
			THEN
				UPDATE tdatamemberhistory
				SET    cvalue = prow.cvalue
					  ,dvalue = prow.dvalue
					  ,nvalue = prow.nvalue
				WHERE  mbrcode = vmbrcode
				AND    mbrdate = pdate;
				IF (SQL%ROWCOUNT = 0)
				THEN
					INSERT INTO tdatamemberhistory
					VALUES
						(vmbrcode
						,pdate
						,prow.cvalue
						,prow.dvalue
						,prow.nvalue);
				END IF;
			ELSIF (vmbrtype = custom_datamember.interval)
			THEN
				UPDATE tdatamemberinterval
				SET    cvalue = prow.cvalue
					  ,dvalue = prow.dvalue
					  ,nvalue = prow.nvalue
				WHERE  mbrcode = vmbrcode
				AND    mbrvalue = pinterval;
				IF (SQL%ROWCOUNT = 0)
				THEN
					INSERT INTO tdatamemberinterval
					VALUES
						(vmbrcode
						,pinterval
						,prow.cvalue
						,prow.dvalue
						,prow.nvalue);
				END IF;
			ELSIF (vmbrtype = custom_datamember.interval_history)
			THEN
				UPDATE tdatamemberintervalhistory
				SET    cvalue = prow.cvalue
					  ,dvalue = prow.dvalue
					  ,nvalue = prow.nvalue
				WHERE  mbrcode = vmbrcode
				AND    mbrdate = pdate
				AND    mbrvalue = pinterval;
				IF (SQL%ROWCOUNT = 0)
				THEN
					INSERT INTO tdatamemberintervalhistory
					VALUES
						(vmbrcode
						,pdate
						,pinterval
						,prow.cvalue
						,prow.dvalue
						,prow.nvalue);
				END IF;
			END IF;
		EXCEPTION
			WHEN no_data_found THEN
				IF ((pdate IS NULL) AND (pinterval IS NULL))
				THEN
					vmbrtype := custom_datamember.single;
				ELSIF ((pdate IS NOT NULL) AND (pinterval IS NULL))
				THEN
					vmbrtype := custom_datamember.history;
				ELSIF ((pdate IS NULL) AND (pinterval IS NOT NULL))
				THEN
					vmbrtype := custom_datamember.interval;
				ELSIF ((pdate IS NOT NULL) AND (pinterval IS NOT NULL))
				THEN
					vmbrtype := custom_datamember.interval_history;
				ELSE
					RAISE no_data_found;
				END IF;
			
				SELECT sdatamember_mbrcode.nextval INTO vmbrcode FROM dual;
			
				INSERT INTO tdatamember
				VALUES
					(vbranch
					,ptype
					,pcode
					,vname
					,vmbrcode
					,vmbrtype
					,premark);
				IF (vmbrtype = custom_datamember.single)
				THEN
					INSERT INTO tdatamembersingle
					VALUES
						(vmbrcode
						,prow.cvalue
						,prow.dvalue
						,prow.nvalue);
				ELSIF (vmbrtype = custom_datamember.history)
				THEN
					INSERT INTO tdatamemberhistory
					VALUES
						(vmbrcode
						,pdate
						,prow.cvalue
						,prow.dvalue
						,prow.nvalue);
				ELSIF (vmbrtype = custom_datamember.interval)
				THEN
					INSERT INTO tdatamemberinterval
					VALUES
						(vmbrcode
						,pinterval
						,prow.cvalue
						,prow.dvalue
						,prow.nvalue);
				ELSIF (vmbrtype = custom_datamember.interval_history)
				THEN
					INSERT INTO tdatamemberintervalhistory
					VALUES
						(vmbrcode
						,pdate
						,pinterval
						,prow.cvalue
						,prow.dvalue
						,prow.nvalue);
				END IF;
		END;
		RETURN 0;
	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK TO datamembersetdata;
			err.seterror(SQLCODE, 'custom_datamember.SetData');
			RETURN SQLCODE;
	END;

	FUNCTION setdataautonomous
	(
		prow      IN tdatamembersingle%ROWTYPE
	   ,ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN CHAR
	   ,pdate     IN DATE
	   ,pinterval IN NUMBER
	   ,premark   IN VARCHAR
	) RETURN NUMBER IS
		PRAGMA AUTONOMOUS_TRANSACTION;
		vret NUMBER;
	BEGIN
		vret := custom_datamember.setdata(prow, ptype, pcode, pname, pdate, pinterval, premark);
		IF vret = 0
		THEN
			COMMIT;
		END IF;
		RETURN vret;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'custom_datamember.SetDataAutonomous');
			RETURN SQLCODE;
	END;

	PROCEDURE scrollerprepare IS
		vbranch NUMBER := getcurbranch();
	BEGIN
		svdynahandle := dynaset.open('FROM tDataMember' || ' WHERE Branch = ' || to_char(vbranch) ||
									 ' AND Type = ' || to_char(svcurrenttype) || ' AND Code = ' ||
									 to_char(svcurrentcode) || ' ORDER BY Name');
		IF (svdynahandle != 0)
		THEN
			svscrollcnt := dynaset.getcount(svdynahandle);
			svscrollcur := 1;
		ELSE
			svscrollcnt := 0;
			svscrollcur := 0;
		END IF;
	END;

	PROCEDURE scrollerrefresh IS
	BEGIN
		IF (svdynahandle != 0)
		THEN
			dynaset.close(svdynahandle);
		END IF;
		custom_datamember.scrollerprepare;
	END;

	FUNCTION getnamecount(vname IN VARCHAR) RETURN NUMBER IS
		vcount  NUMBER;
		vbranch NUMBER := getcurbranch();
	BEGIN
		SELECT COUNT(*)
		INTO   vcount
		FROM   tdatamember
		WHERE  branch = vbranch
		AND    TYPE = custom_datamember.svcurrenttype
		AND    code = custom_datamember.svcurrentcode
		AND    NAME = vname;
		RETURN vcount;
	END;

	PROCEDURE setbranch(vbranch IN NUMBER) IS
	BEGIN
		scurbranch := vbranch;
	END;

	FUNCTION getcurbranch RETURN NUMBER IS
	BEGIN
		IF scurbranch IS NOT NULL
		THEN
			RETURN scurbranch;
		END IF;
		--   RETURN seance.getbranch();
		RETURN 1;
	END;

	FUNCTION getbranch RETURN NUMBER IS
	BEGIN
		RETURN getcurbranch();
	END;

	FUNCTION adddatamember
	(
		vtype   IN NUMBER
	   ,vname   IN VARCHAR
	   ,vremark IN VARCHAR
	) RETURN NUMBER IS
		vmbrcode NUMBER;
		vbranch  NUMBER := getcurbranch();
	BEGIN
		err.seterror(0, 'AddDataMember');
		SELECT sdatamember_mbrcode.nextval INTO vmbrcode FROM dual;
		INSERT INTO tdatamember
		VALUES
			(vbranch
			,custom_datamember.svcurrenttype
			,custom_datamember.svcurrentcode
			,vname
			,vmbrcode
			,vtype
			,vremark);
		RETURN vmbrcode;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'AddDataMember');
			RETURN NULL;
	END;

	PROCEDURE updatedatamember
	(
		vmbrcode IN NUMBER
	   ,vname    IN VARCHAR
	   ,vremark  IN VARCHAR
	) IS
		vbranch NUMBER := getcurbranch();
	BEGIN
		err.seterror(0, 'UpdateDataMember');
		UPDATE tdatamember
		SET    NAME   = vname
			  ,remark = vremark
		WHERE  branch = vbranch
		AND    mbrcode = vmbrcode;
		RETURN;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'UpdateDataMember');
			RETURN;
	END;

	FUNCTION getdialog
	(
		pmbrtype  IN NUMBER
	   ,ptype     IN NUMBER
	   ,pcode     IN NUMBER
	   ,pname     IN VARCHAR
	   ,premark   IN VARCHAR
	   ,pcanedit  IN BOOLEAN := TRUE
	   ,proundpos IN NUMBER := -1
	) RETURN NUMBER IS
		CURSOR cdmbr
		(
			vbranch IN NUMBER
		   ,vtype   IN NUMBER
		   ,vcode   IN NUMBER
		   ,vname   IN CHAR
		) IS
			SELECT *
			FROM   tdatamember
			WHERE  branch = vbranch
			AND    TYPE = vtype
			AND    code = vcode
			AND    NAME = vname;
		vdmbr   cdmbr%ROWTYPE;
		vdialog NUMBER;
		vbranch NUMBER := getcurbranch();
	BEGIN
		vdialog := 0;
		OPEN cdmbr(vbranch, ptype, pcode, upper(pname));
		FETCH cdmbr
			INTO vdmbr;
		IF (cdmbr%FOUND)
		THEN
			IF (vdmbr.mbrtype = single)
			THEN
				vdialog := datamembersingle.dialogedit(vdmbr.mbrcode, pcanedit);
			ELSIF (vdmbr.mbrtype = history)
			THEN
				vdialog := datamemberhistory.dialogedit(vdmbr.mbrcode, pcanedit, proundpos);
			ELSIF (vdmbr.mbrtype = INTERVAL)
			THEN
				vdialog := datamemberinterval.dialogedit(vdmbr.mbrcode, pcanedit);
			ELSIF (vdmbr.mbrtype = interval_history)
			THEN
				vdialog := datamemberintervalhistory.dialogedit(vdmbr.mbrcode, pcanedit);
			END IF;
		ELSE
			custom_datamember.svcurrenttype := ptype;
			custom_datamember.svcurrentcode := pcode;
			vdmbr.mbrcode                   := custom_datamember.adddatamember(pmbrtype
																			  ,pname
																			  ,premark);
			IF (vdmbr.mbrcode IS NOT NULL)
			THEN
				IF (pmbrtype = single)
				THEN
					vdialog := datamembersingle.dialogedit(vdmbr.mbrcode, pcanedit);
				ELSIF (pmbrtype = history)
				THEN
					vdialog := datamemberhistory.dialogedit(vdmbr.mbrcode, pcanedit, proundpos);
				ELSIF (pmbrtype = INTERVAL)
				THEN
					vdialog := datamemberinterval.dialogedit(vdmbr.mbrcode, pcanedit);
				ELSIF (pmbrtype = interval_history)
				THEN
					vdialog := datamemberintervalhistory.dialogedit(vdmbr.mbrcode, pcanedit);
				END IF;
			END IF;
		END IF;
		CLOSE cdmbr;
		RETURN vdialog;
	EXCEPTION
		WHEN OTHERS THEN
			err.seterror(SQLCODE, 'GetDialog');
			IF (cdmbr%ISOPEN)
			THEN
				CLOSE cdmbr;
			END IF;
			RETURN vdialog;
	END;

BEGIN

	svtypename(custom_datamember.single) := 'Single data item';
	svtypename(custom_datamember.history) := 'History';
	svtypename(custom_datamember.interval) := 'Intervals';
	svtypename(custom_datamember.interval_history) := 'Interval history';
	svdynahandle := 0;
	svscrollcnt := 0;
	svscrollcur := 0;
END;
/
