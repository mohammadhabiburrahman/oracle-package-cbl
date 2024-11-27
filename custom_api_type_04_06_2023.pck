CREATE OR REPLACE PACKAGE custom_api_type AS

	cpackagespecversion CONSTANT VARCHAR2(100) := '$Rev: 61671 $';

	TYPE typeaccountrecord IS RECORD(
		 accountno        taccount.accountno%TYPE
		,accounttype      taccount.accounttype%TYPE
		,noplan           taccount.noplan%TYPE
		,stat             taccount.stat%TYPE
		,currency         taccount.currencyno%TYPE
		,idclient         taccount.idclient%TYPE
		,remain           taccount.remain%TYPE
		,available        taccount.available%TYPE
		,lowremain        taccount.lowremain%TYPE
		,crdlimit         taccount.overdraft%TYPE
		,debitreserve     taccount.debitreserve%TYPE
		,creditreserve    taccount.creditreserve%TYPE
		,branchpart       taccount.branchpart%TYPE
		,createclerk      taccount.createclerkcode%TYPE
		,createdate       taccount.createdate%TYPE
		,updateclerk      taccount.updateclerkcode%TYPE
		,updatedate       taccount.updatedate%TYPE
		,updatesysdate    taccount.updatesysdate%TYPE
		,acct_typ         taccount.acct_typ%TYPE
		,acct_stat        taccount.acct_stat%TYPE
		,extaccountno     tacc2acc.oldaccountno%TYPE
		,closedate        taccount.closedate%TYPE
		,remark           taccount.remark%TYPE
		,limitgrpid       taccount.limitgrpid%TYPE
		,remainupdatedate taccount.remainupdatedate%TYPE
		,finprofile       taccount.finprofile%TYPE
		,guid             types.guid
		,
		
		internallimitsgroupsysid taccount.internallimitsgroupsysid%TYPE
		,
		
		countergrpid          taccount.countergrpid%TYPE
		,permissibleexcesstype taccount.permissibleexcesstype%TYPE
		,permissibleexcess     taccount.permissibleexcess%TYPE
		,protectedamount       taccount.protectedamount%TYPE);
	TYPE typeaccountlist IS TABLE OF typeaccountrecord INDEX BY BINARY_INTEGER;

	TYPE typecardrecord IS RECORD(
		 pan                tcard.pan%TYPE
		,mbr                tcard.mbr%TYPE
		,idclient           tcard.idclient%TYPE
		,branchpart         tcard.branchpart%TYPE
		,enterdate          tcard.orderdate%TYPE
		,makingdate         tcard.makingdate%TYPE
		,distributiondate   tcard.distributiondate%TYPE
		,expirationdate     tcard.canceldate%TYPE
		,closedate          tcard.closedate%TYPE
		,release            tcard.release%TYPE
		,a4mstat            tcard.signstat%TYPE
		,pctype             tcard.crd_typ%TYPE
		,pcstat             tcard.crd_stat%TYPE
		,remake             tcard.remake%TYPE
		,makingpriority     tcard.makingpriority%TYPE
		,pvv                tcard.pinoffset%TYPE
		,cvv                tcard.cvv%TYPE
		,cvv2               tcard.cvv2%TYPE
		,remark             tcard.remark%TYPE
		,insure             tcard.insure%TYPE
		,insuredate         tcard.insuredate%TYPE
		,parentpan          tcard.parentpan%TYPE
		,parentmbr          tcard.parentmbr%TYPE
		,createclerk        tcard.createclerkcode%TYPE
		,createdate         tcard.createdate%TYPE
		,updateclerk        tcard.updateclerkcode%TYPE
		,updatedate         tcard.updatedate%TYPE
		,updatesysdate      tcard.updatesysdate%TYPE
		,currency           tcard.currencyno%TYPE
		,grplimit           tcard.grplimit%TYPE
		,finprofile         tcard.finprofile%TYPE
		,pinblock           tcard.pinblock%TYPE
		,cardproduct        tcard.cardproduct%TYPE
		,ipvv               tcard.ipvv%TYPE
		,cnsscheme          tcard.cnsscheme%TYPE
		,cnschannel         tcard.cnschannel%TYPE
		,cnsaddress         tcard.cnsaddress%TYPE
		,nameoncard         tcard.nameoncard%TYPE
		,createsysdate      tcard.createsysdate%TYPE
		,closesysdate       tcard.closesysdate%TYPE
		,remakedisable      tcard.remakedisable%TYPE
		,risklevel          tcard.risklevel%TYPE
		,ecstatus           tcard.ecstatus%TYPE
		,guid               types.guid
		,externalid         tcard.externalid%TYPE
		,f4dbc              tcard.f4dbc%TYPE
		,plastictype        tcard.plastictype%TYPE
		,ecsettings         tcard.ecsettings%TYPE
		,grplimitint        tcard.grplimitint%TYPE
		,ecuseperssett      tcard.useperssett%TYPE
		,reissued           tcard.reissued%TYPE
		,grpcounter         tcard.grpcounter%TYPE
		,etustatus          tcard.etustatus%TYPE
		,etunewchain        tcard.etunewchain%TYPE
		,supplementary      tcard.supplementary%TYPE
		,ecusedecoupledauth tcard.usedecoupledauth%TYPE
		,pinverifytype      tcard.pinverifytype%TYPE
		--,contactless        tcard.contactlesscapable%TYPE
		);
	TYPE typecardlist IS TABLE OF typecardrecord INDEX BY BINARY_INTEGER;

	TYPE typecardsignrecord IS RECORD(
		 cardsign     treferencecardsign.cardsign%TYPE
		,NAME         treferencecardsign.name%TYPE
		,remark       treferencecardsign.remark%TYPE
		,SIGNTYPE     treferencecardsign.signtype%TYPE
		,crd_stat     treferencecardsign.crd_stat%TYPE
		,additional   treferencecardsign.additional%TYPE
		,setgivendate treferencecardsign.setgivendate%TYPE);
	TYPE typecardsignlist IS TABLE OF typecardsignrecord INDEX BY BINARY_INTEGER;

	TYPE typecardstatrecord IS RECORD(
		 crd_stat treferencecrd_stat.crd_stat%TYPE
		,NAME     treferencecrd_stat.name%TYPE
		,remark   treferencecrd_stat.remark%TYPE
		,allowed  NUMBER);
	TYPE typecardstatlist IS TABLE OF typecardstatrecord INDEX BY BINARY_INTEGER;

	TYPE typecardecstatusrecord IS RECORD(
		 code   treferenceecstatus.code%TYPE
		,NAME   treferenceecstatus.name%TYPE
		,remark treferenceecstatus.remark%TYPE);

	TYPE typecardecstatuslist IS TABLE OF typecardecstatusrecord INDEX BY BINARY_INTEGER;

	TYPE typecardecparamrecord IS RECORD(
		 code               treferenceecstatus.code%TYPE
		,settingsrow        VARCHAR2(6)
		,isuseperssett      NUMBER(1)
		,isusedecoupledauth NUMBER(1));

	TYPE typecardremakereasonrecord IS RECORD(
		 remake   treferencecardremake.remake%TYPE
		,NAME     treferencecardremake.name%TYPE
		,usertype treferencecardremake.usertype%TYPE
		,remark   treferencecardremake.remark%TYPE);
	TYPE typecardremakereasonlist IS TABLE OF typecardremakereasonrecord INDEX BY BINARY_INTEGER;

	SUBTYPE typeaccrefreshrow IS trefreshaccount%ROWTYPE;
	TYPE listaccrefreshrow IS TABLE OF typeaccrefreshrow INDEX BY BINARY_INTEGER;

	TYPE typerefreshaccountrecord IS RECORD(
		 accountno             trefreshaccount.accountno%TYPE
		,TYPE                  trefreshaccount.type%TYPE
		,status                trefreshaccount.status%TYPE
		,currency              trefreshaccount.currency%TYPE
		,ledger                trefreshaccount.ledger%TYPE
		,avail                 trefreshaccount.avail%TYPE
		,rectype               trefreshaccount.rectype%TYPE
		,overdraft             trefreshaccount.overdraft%TYPE
		,clientid              trefreshaccount.clientid%TYPE
		,remain                trefreshaccount.remain%TYPE
		,debitreserve          trefreshaccount.debitreserve%TYPE
		,creditreserve         trefreshaccount.creditreserve%TYPE
		,lowremain             trefreshaccount.lowremain%TYPE
		,parentaccount         trefreshaccount.parentaccount%TYPE
		,historylength         trefreshaccount.historylength%TYPE
		,bonus                 trefreshaccount.bonus%TYPE
		,branchpart            trefreshaccount.branchpart%TYPE
		,bonusprogram          trefreshaccount.bonusprogram%TYPE
		,accounttype           trefreshaccount.accounttype%TYPE
		,AGGREGATE             trefreshaccount.aggregate%TYPE
		,priority              trefreshaccount.priority%TYPE
		,permissibleexcesstype trefreshaccount.permissibleexcesstype%TYPE
		,permissibleexcess     trefreshaccount.permissibleexcess%TYPE
		,protectedamount       trefreshaccount.protectedamount%TYPE);

	TYPE typerefreshclientrecord IS RECORD(
		 clientid            trefreshclient.clientid%TYPE
		,fio                 trefreshclient.fio%TYPE
		,sex                 trefreshclient.sex%TYPE
		,rectype             trefreshclient.rectype%TYPE
		,identtype           trefreshclient.identtype%TYPE
		,identity            trefreshclient.identity%TYPE
		,birthday            trefreshclient.birthday%TYPE
		,birthplace          trefreshclient.birthplace%TYPE
		,query               trefreshclient.query%TYPE
		,answer              trefreshclient.answer%TYPE
		,password            trefreshclient.password%TYPE
		,vip                 trefreshclient.vip%TYPE
		,branchpart          trefreshclient.branchpart%TYPE
		,extid               trefreshclient.extid%TYPE
		,residentcountry     trefreshclient.residentcountry%TYPE
		,residentcityinlatin trefreshclient.residentcityinlatin%TYPE
		,postalcode          trefreshclient.postalcode%TYPE
		,addressinlatin      trefreshclient.addressinlatin%TYPE
		,inn                 trefreshclient.inn%TYPE
		,guid                trefreshclient.guid%TYPE
		,residentstate       trefreshclient.residentstate%TYPE
		,categoryid          trefreshclient.categoryid%TYPE
		,limitcurrency       trefreshclient.limitcurrency%TYPE
		,latfirstname        trefreshclient.latfirstname%TYPE
		,latmiddlename       trefreshclient.latmiddlename%TYPE
		,latlastname         trefreshclient.latlastname%TYPE
		,phonenumber         trefreshclient.phonenumber%TYPE
		,firstname           trefreshclient.firstname%TYPE
		,middlename          trefreshclient.middlename%TYPE
		,lastname            trefreshclient.lastname%TYPE
		,deathdate           trefreshclient.deathdate%TYPE
		,email               trefreshclient.email%TYPE);

	/*TYPE typerefreshclientbankrecord IS RECORD(
    --clientid                 trefreshclientbank.clientid%TYPE
    --,NAME                     trefreshclientbank.name%TYPE
    --,shortname                trefreshclientbank.shortname%TYPE
    --,shortnametransliteration trefreshclientbank.shortnametransliteration%TYPE
    ,externalid              trefreshclientbank.externalid%TYPE
    ,legaladdresscountry     trefreshclientbank.legaladdresscountry%TYPE
    ,legaladdressregion      trefreshclientbank.legaladdressregion%TYPE
    ,legaladdresscity        trefreshclientbank.legaladdresscity%TYPE
    ,legaladdressstreet      trefreshclientbank.legaladdressstreet%TYPE
    ,legaladdresshouse       trefreshclientbank.legaladdresshouse%TYPE
    ,legaladdressbuilding    trefreshclientbank.legaladdressbuilding%TYPE
    ,legaladdressframe       trefreshclientbank.legaladdressframe%TYPE
    ,legaladdressflat        trefreshclientbank.legaladdressflat%TYPE
    ,legaladdresszip         trefreshclientbank.legaladdresszip%TYPE
    ,legaladdress            trefreshclientbank.legaladdress%TYPE
    ,legaladdressphone       trefreshclientbank.legaladdressphone%TYPE
    ,legaladdressfax         trefreshclientbank.legaladdressfax%TYPE
    ,legaladdressemail       trefreshclientbank.legaladdressemail%TYPE
    ,contactaddresscountry   trefreshclientbank.contactaddresscountry%TYPE
    ,contactaddressregion    trefreshclientbank.contactaddressregion%TYPE
    ,contactaddresscity      trefreshclientbank.contactaddresscity%TYPE
    ,contactaddressstreet    trefreshclientbank.contactaddressstreet%TYPE
    ,contactaddresshouse     trefreshclientbank.contactaddresshouse%TYPE
    ,contactaddressbuilding  trefreshclientbank.contactaddressbuilding%TYPE
    ,contactaddressframe     trefreshclientbank.contactaddressframe%TYPE
    ,contactaddressflat      trefreshclientbank.contactaddressflat%TYPE
    ,contactaddresszip       trefreshclientbank.contactaddresszip%TYPE
    ,contactaddress          trefreshclientbank.contactaddress%TYPE
    ,contactphone            trefreshclientbank.contactphone%TYPE
    ,contactfax              trefreshclientbank.contactfax%TYPE
    ,contactemail            trefreshclientbank.contactemail%TYPE
    ,postaladdresscountry    trefreshclientbank.postaladdresscountry%TYPE
    ,postaladdressregion     trefreshclientbank.postaladdressregion%TYPE
    ,postaladdresscity       trefreshclientbank.postaladdresscity%TYPE
    ,postaladdressstreet     trefreshclientbank.postaladdressstreet%TYPE
    ,postaladdresshouse      trefreshclientbank.postaladdresshouse%TYPE
    ,postaladdressbuilding   trefreshclientbank.postaladdressbuilding%TYPE
    ,postaladdressframe      trefreshclientbank.postaladdressframe%TYPE
    ,postaladdressflat       trefreshclientbank.postaladdressflat%TYPE
    ,postaladdresszip        trefreshclientbank.postaladdresszip%TYPE
    ,postaladdress           trefreshclientbank.postaladdress%TYPE
    ,registrationnumber      trefreshclientbank.registrationnumber%TYPE
    ,registrationdate        trefreshclientbank.registrationdate%TYPE
    ,registeringorganization trefreshclientbank.registeringorganization%TYPE
    ,inn                     trefreshclientbank.inn%TYPE
    ,okfs                    trefreshclientbank.okfs%TYPE
    ,okopf                   trefreshclientbank.okopf%TYPE
    ,kpp                     trefreshclientbank.kpp%TYPE
    ,ogrn                    trefreshclientbank.ogrn%TYPE
    ,enterprisecode          trefreshclientbank.enterprisecode%TYPE
    ,additionalinformation   trefreshclientbank.additionalinformation%TYPE
    ,statementpath           trefreshclientbank.statementpath%TYPE
    ,statementlang           trefreshclientbank.statementlang%TYPE
    ,closingdate             trefreshclientbank.closingdate%TYPE);*/

	TYPE typelimitinforange IS RECORD(
		 startdate DATE
		,stopdate  DATE
		,maxvalue  NUMBER);
	TYPE typelimitinforangelist IS TABLE OF typelimitinforange INDEX BY BINARY_INTEGER;

	TYPE typecardlimitrecord IS RECORD(
		 code            tcardlimititem.limitid%TYPE
		,NAME            treferencecardlimit.name%TYPE
		,TYPE            treferencecardlimit.limittype%TYPE
		,VALUE           tcardlimititem.maxvalue%TYPE
		,periodtype      tcardlimititem.periodtype%TYPE
		,period          tcardlimititem.period%TYPE
		,status          NUMBER
		,nextdate        tcardlimititem.nextdate%TYPE
		,availableexcess tcardlimititem.avlblexcess%TYPE
		,holdalg         NUMBER
		,currency        NUMBER
		,rangelist       typelimitinforangelist
		,modifymask      RAW(2));
	TYPE typecardlimitlist IS TABLE OF typecardlimitrecord INDEX BY BINARY_INTEGER;

	TYPE typeaccountlimitrecord IS RECORD(
		 code            taccountlimititem.limitid%TYPE
		,NAME            treferencecardlimit.name%TYPE
		,TYPE            treferencecardlimit.limittype%TYPE
		,VALUE           taccountlimititem.maxvalue%TYPE
		,periodtype      taccountlimititem.periodtype%TYPE
		,period          taccountlimititem.period%TYPE
		,status          NUMBER
		,nextdate        tcardlimititem.nextdate%TYPE
		,availableexcess tcardlimititem.avlblexcess%TYPE
		,modifymask      RAW(2)
		,rangelist       typelimitinforangelist);
	TYPE typeaccountlimitlist IS TABLE OF typeaccountlimitrecord INDEX BY BINARY_INTEGER;

	TYPE typeacc2cardlimitrecord IS RECORD(
		 code            tacc2cardlimititem.limitid%TYPE
		,NAME            treferencecardlimit.name%TYPE
		,TYPE            treferencecardlimit.limittype%TYPE
		,VALUE           tacc2cardlimititem.maxvalue%TYPE
		,periodtype      tacc2cardlimititem.periodtype%TYPE
		,period          tacc2cardlimititem.period%TYPE
		,status          NUMBER
		,nextdate        tcardlimititem.nextdate%TYPE
		,availableexcess tcardlimititem.avlblexcess%TYPE);
	TYPE typeacc2cardlimitlist IS TABLE OF typeacc2cardlimitrecord INDEX BY BINARY_INTEGER;

	TYPE typecustomerlimitrecord IS RECORD(
		 code            tcustomerlimititem.limitid%TYPE
		,NAME            treferencecardlimit.name%TYPE
		,TYPE            treferencecardlimit.limittype%TYPE
		,VALUE           tcustomerlimititem.maxvalue%TYPE
		,periodtype      tcustomerlimititem.periodtype%TYPE
		,period          tcustomerlimititem.period%TYPE
		,status          NUMBER
		,nextdate        tcustomerlimititem.nextdate%TYPE
		,availableexcess tcustomerlimititem.avlblexcess%TYPE
		,modifymask      RAW(2)
		,rangelist       typelimitinforangelist);
	TYPE typecustomerlimitlist IS TABLE OF typecustomerlimitrecord INDEX BY BINARY_INTEGER;

	TYPE typeclientlimitrecord IS RECORD(
		 code            tclientlimititem.limitid%TYPE
		,NAME            treferencecardlimit.name%TYPE
		,TYPE            treferencecardlimit.limittype%TYPE
		,VALUE           tclientlimititem.maxvalue%TYPE
		,periodtype      tclientlimititem.periodtype%TYPE
		,period          tclientlimititem.period%TYPE
		,status          NUMBER
		,nextdate        tclientlimititem.nextdate%TYPE
		,availableexcess tclientlimititem.avlblexcess%TYPE
		,modifymask      RAW(2)
		,rangelist       typelimitinforangelist);
	TYPE typeclientlimitlist IS TABLE OF typeclientlimitrecord INDEX BY BINARY_INTEGER;

	TYPE typeofflinelimitrecord IS RECORD(
		 maxvalue tcardlimititem.maxvalue%TYPE
		,holdalg  tcardlimititem.holdalg%TYPE
		,currency tcardlimititem.currency%TYPE
		,curvalue tcardofflinelimit.value%TYPE);

	TYPE typeretailerlimitrecord IS RECORD(
		 code            tretailerlimititem.limitid%TYPE
		,NAME            treferencecardlimit.name%TYPE
		,TYPE            treferencecardlimit.limittype%TYPE
		,VALUE           tretailerlimititem.maxvalue%TYPE
		,periodtype      tretailerlimititem.periodtype%TYPE
		,period          tretailerlimititem.period%TYPE
		,status          NUMBER
		,nextdate        tretailerlimititem.nextdate%TYPE
		,availableexcess tretailerlimititem.avlblexcess%TYPE);
	TYPE typeretailerlimitlist IS TABLE OF typeretailerlimitrecord INDEX BY BINARY_INTEGER;

	TYPE typechequebookintlimitrecord IS RECORD(
		 code       tchequebookinternallimititem.limitid%TYPE
		,NAME       treferencecardlimit.name%TYPE
		,TYPE       treferencecardlimit.limittype%TYPE
		,VALUE      tchequebookinternallimititem.maxvalue%TYPE
		,periodtype tchequebookinternallimititem.periodtype%TYPE
		,period     tchequebookinternallimititem.period%TYPE
		,status     NUMBER);
	TYPE typechequebookintlimitlist IS TABLE OF typechequebookintlimitrecord INDEX BY BINARY_INTEGER;

	TYPE typechequebookoperationrecord IS RECORD(
		 chequebookid NUMBER
		,operid       VARCHAR2(1000)
		,VALUE        NUMBER
		,currency     NUMBER
		,response     NUMBER
		,entcode      textract.entcode%TYPE
		,device       textract.device%TYPE
		,trantype     textract.enttype%TYPE);

	TYPE typecardintlimitrecord IS RECORD(
		 code       tcardinternallimititem.limitid%TYPE
		,NAME       treferencecardlimit.name%TYPE
		,TYPE       treferencecardlimit.limittype%TYPE
		,VALUE      tcardinternallimititem.maxvalue%TYPE
		,periodtype tcardinternallimititem.periodtype%TYPE
		,period     tcardinternallimititem.period%TYPE
		,status     NUMBER);
	TYPE typecardintlimitlist IS TABLE OF typecardintlimitrecord INDEX BY BINARY_INTEGER;

	TYPE typecardoperationrecord IS RECORD(
		 pan      tcard.pan%TYPE
		,mbr      tcard.mbr%TYPE
		,operid   VARCHAR2(1000)
		,VALUE    NUMBER
		,currency NUMBER
		,response NUMBER
		,entcode  textract.entcode%TYPE
		,device   textract.device%TYPE
		,trantype textract.enttype%TYPE);

	TYPE typeaccountintlimitrecord IS RECORD(
		 code       taccountinternallimititem.limitid%TYPE
		,NAME       treferencecardlimit.name%TYPE
		,TYPE       treferencecardlimit.limittype%TYPE
		,VALUE      taccountinternallimititem.maxvalue%TYPE
		,periodtype taccountinternallimititem.periodtype%TYPE
		,period     taccountinternallimititem.period%TYPE
		,status     NUMBER);
	TYPE typeaccountintlimitlist IS TABLE OF typeaccountintlimitrecord INDEX BY BINARY_INTEGER;

	TYPE typeaccountoperationrecord IS RECORD(
		 accountno taccount.accountno%TYPE
		,operid    VARCHAR2(1000)
		,VALUE     NUMBER
		,currency  NUMBER
		,response  NUMBER
		,entcode   textract.entcode%TYPE
		,device    textract.device%TYPE
		,trantype  textract.enttype%TYPE
		,entrycode NUMBER);

	TYPE typeretailerintlimitrecord IS RECORD(
		 code       tretailerintlimititem.limitid%TYPE
		,NAME       treferencecardlimit.name%TYPE
		,TYPE       treferencecardlimit.limittype%TYPE
		,VALUE      tretailerintlimititem.maxvalue%TYPE
		,periodtype tretailerintlimititem.periodtype%TYPE
		,period     tretailerintlimititem.period%TYPE
		,status     NUMBER);
	TYPE typeretailerintlimitlist IS TABLE OF typeretailerintlimitrecord INDEX BY BINARY_INTEGER;

	TYPE typeretaileroperationrecord IS RECORD(
		 retailerid NUMBER
		,operid     VARCHAR2(1000)
		,VALUE      NUMBER
		,currency   NUMBER
		,response   NUMBER
		,entcode    textract.entcode%TYPE
		,device     textract.device%TYPE
		,trantype   textract.enttype%TYPE);
	TYPE typeterminalintlimitrecord IS RECORD(
		 code       tterminalintlimititem.limitid%TYPE
		,NAME       treferencecardlimit.name%TYPE
		,TYPE       treferencecardlimit.limittype%TYPE
		,VALUE      tterminalintlimititem.maxvalue%TYPE
		,periodtype tterminalintlimititem.periodtype%TYPE
		,period     tterminalintlimititem.period%TYPE
		,status     NUMBER);
	TYPE typeterminalintlimitlist IS TABLE OF typeterminalintlimitrecord INDEX BY BINARY_INTEGER;

	TYPE typeterminaloperationrecord IS RECORD(
		 terminalid NUMBER
		,operid     VARCHAR2(1000)
		,VALUE      NUMBER
		,currency   NUMBER
		,response   NUMBER
		,entcode    textract.entcode%TYPE
		,device     textract.device%TYPE
		,trantype   textract.enttype%TYPE);

	TYPE typeclientintlimitrecord IS RECORD(
		 code       tclientinternallimititem.limitid%TYPE
		,NAME       treferencecardlimit.name%TYPE
		,TYPE       treferencecardlimit.limittype%TYPE
		,VALUE      tclientinternallimititem.maxvalue%TYPE
		,periodtype tclientinternallimititem.periodtype%TYPE
		,period     tclientinternallimititem.period%TYPE
		,status     NUMBER);
	TYPE typeclientintlimitlist IS TABLE OF typeclientintlimitrecord INDEX BY BINARY_INTEGER;

	TYPE typeclientoperationrecord IS RECORD(
		 clientid NUMBER
		,operid   VARCHAR2(1000)
		,VALUE    NUMBER
		,currency NUMBER
		,response NUMBER
		,entcode  textract.entcode%TYPE
		,device   textract.device%TYPE
		,trantype textract.enttype%TYPE);

	TYPE typechequebookrecord IS RECORD(
		 id            tchequebook.id%TYPE
		,no            tchequebook.no%TYPE
		,TYPE          tchequebook.type%TYPE
		,idclient      tchequebook.idclient%TYPE
		,accountno     tchequebook.accountno%TYPE
		,leafcnt       tchequebook.leafcnt%TYPE
		,finprofile    tchequebook.finprofile%TYPE
		,limitgroup    tchequebook.limitgroup%TYPE
		,limitcurrency tchequebook.limitcurrency%TYPE
		,expiration    tchequebook.expiration%TYPE
		,createdate    tchequebook.createdate%TYPE
		,issuedate     tchequebook.issuedate%TYPE
		,givendate     tchequebook.givendate%TYPE
		,closedate     tchequebook.closedate%TYPE
		,issstatus     tchequebook.issstatus%TYPE
		,branchpart    tchequebook.branchpart%TYPE
		,customername  tchequebook.customername%TYPE
		,updatedate    tchequebook.updatedate%TYPE
		,updatesysdate tchequebook.updatesysdate%TYPE
		,clerkcreate   tchequebook.clerkcreate%TYPE
		,clerkupdate   tchequebook.clerkupdate%TYPE);
	TYPE typechequebooklist IS TABLE OF typechequebookrecord INDEX BY BINARY_INTEGER;

	TYPE typechequerecord IS RECORD(
		 bookid       tcheque.bookid%TYPE
		,id           tcheque.id%TYPE
		,no           tcheque.no%TYPE
		,status       tcheque.status%TYPE
		,cancelreason tcheque.cancelreason%TYPE
		,docno        tcheque.docno%TYPE
		,remark       tcheque.remark%TYPE);
	TYPE typechequelist IS TABLE OF typechequerecord INDEX BY BINARY_INTEGER;

	SUBTYPE typecrstatuscode IS tcrreferencestatus.code%TYPE;

	SUBTYPE typecrstatusname IS tcrreferencestatus.name%TYPE;

	TYPE typecrstatusrecord IS RECORD(
		 code typecrstatuscode
		,NAME typecrstatusname);

	TYPE typecrstatuslist IS TABLE OF typecrstatusrecord INDEX BY BINARY_INTEGER;

	SUBTYPE typecrdreasoncode IS tcrdeclinereason.code%TYPE;

	SUBTYPE typecrdreasonname IS tcrdeclinereason.name%TYPE;

	TYPE typecrdreasonrecord IS RECORD(
		 code        typecrdreasoncode
		,NAME        typecrdreasonname
		,description tcrdeclinereason.description%TYPE
		,active      BOOLEAN
		,system      BOOLEAN);

	TYPE typecrdreasonlist IS TABLE OF typecrdreasonrecord INDEX BY BINARY_INTEGER;

	SUBTYPE typechequerequestid IS tchequerequest.id%TYPE;

	SUBTYPE typechequerequestbookno IS tchequerequest.bookno%TYPE;

	SUBTYPE typechequerequestserialno IS tchequerequest.serialno%TYPE;

	TYPE typechequerequestrecord IS RECORD(
		 id                 tchequerequest.id%TYPE
		,serialno           tchequerequest.serialno%TYPE
		,drawdate           tchequerequest.drawdate%TYPE
		,amount             tchequerequest.amount%TYPE
		,currency           tchequerequest.currency%TYPE
		,branchpart         tchequerequest.branchpart%TYPE
		,status             tchequerequest.status%TYPE
		,declinereason      tchequerequest.declinereason%TYPE
		,declinedescription tchequerequest.declinedescription%TYPE
		,createdby          tchequerequest.createdby%TYPE
		,createdopdate      tchequerequest.createdopdate%TYPE
		,createdsysdate     tchequerequest.createdsysdate%TYPE
		,updatedby          tchequerequest.updatedby%TYPE
		,updatedsysdate     tchequerequest.updatedsysdate%TYPE
		,objectuid          tchequerequest.objectuid%TYPE
		,bookno             tchequerequest.bookno%TYPE);

	TYPE typechequerequestlist IS TABLE OF typechequerequestrecord INDEX BY BINARY_INTEGER;

	TYPE typecrhistoryoperationrecord IS RECORD(
		 chequerequestid     tcrhistoryoperation.chequerequestid%TYPE
		,operationid         tcrhistoryoperation.operationid%TYPE
		,responsecode        tcrhistoryoperation.responsecode%TYPE
		,responsedescription tcrhistoryoperation.responsedescription%TYPE
		,docno               tcrhistoryoperation.docno%TYPE
		,execdate            tcrhistoryoperation.execdate%TYPE
		,execsysdate         tcrhistoryoperation.execsysdate%TYPE
		,execby              tcrhistoryoperation.execby%TYPE
		,rollbackdata        tcrhistoryoperation.rollbackdata%TYPE
		,limitundokey        tcrhistoryoperation.limitundokey%TYPE);

	TYPE typeaccount2cardrecord IS RECORD(
		 accountno   tacc2card.accountno%TYPE
		,pan         tacc2card.pan%TYPE
		,mbr         tacc2card.mbr%TYPE
		,acct_stat   tacc2card.acct_stat%TYPE
		,description tacc2card.description%TYPE
		,limitgrpid  tacc2card.limitgrpid%TYPE);
	TYPE typeaccount2cardlist IS TABLE OF typeaccount2cardrecord INDEX BY BINARY_INTEGER;

	TYPE typefinprofilerecord IS RECORD(
		 profile  tfinprofile.profile%TYPE
		,NAME     tfinprofile.name%TYPE
		,activity tfinprofile.activity%TYPE
		,status   tfinprofile.status%TYPE
		,note     tfinprofile.note%TYPE
		,id       tfinprofile.id%TYPE);

	TYPE typefinprofilelist IS TABLE OF typefinprofilerecord INDEX BY BINARY_INTEGER;

	TYPE typefinretadjustrecord IS RECORD(
		 retadjust NUMBER
		,credit    NUMBER
		,debit     NUMBER
		,status    NUMBER);
	TYPE typefinretadjustlist IS TABLE OF typefinretadjustrecord INDEX BY BINARY_INTEGER;

	TYPE typecurrency IS RECORD(
		 code             treferencecurrency.currency%TYPE
		,firstname1       treferencecurrency.firstname1%TYPE
		,firstname234     treferencecurrency.firstname234%TYPE
		,firstnameothers  treferencecurrency.firstnameothers%TYPE
		,firstshortname   treferencecurrency.firstshortname%TYPE
		,firstsex         treferencecurrency.firstsex%TYPE
		,secondname1      treferencecurrency.secondname1%TYPE
		,secondname234    treferencecurrency.secondname234%TYPE
		,secondnameothers treferencecurrency.secondnameothers%TYPE
		,secondshortname  treferencecurrency.secondshortname%TYPE
		,secondsex        treferencecurrency.secondsex%TYPE
		,PRECISION        treferencecurrency.precision%TYPE
		,description      treferencecurrency.description%TYPE
		,activeaccount    treferencecurrency.activeaccount%TYPE
		,passiveaccount   treferencecurrency.passiveaccount%TYPE
		,abbreviation     treferencecurrency.abbreviation%TYPE
		,favorite         treferencecurrency.favorite%TYPE);

	TYPE typecurrencylist IS TABLE OF typecurrency INDEX BY BINARY_INTEGER;

	TYPE typecustomerrecord IS RECORD(
		 customer         tcustomer.customer%TYPE
		,charalias        tcustomer.charalias%TYPE
		,numberalias      tcustomer.numberalias%TYPE
		,idclient         tcustomer.idclient%TYPE
		,stat             tcustomer.stat%TYPE
		,createdate       tcustomer.createdate%TYPE
		,createclerkcode  tcustomer.createclerkcode%TYPE
		,updatedate       tcustomer.updatedate%TYPE
		,updateclerkcode  tcustomer.updateclerkcode%TYPE
		,updatesysdate    tcustomer.updatesysdate%TYPE
		,accountno        tcustomer.accountno%TYPE
		,pinoffset        tcustomer.pinoffset%TYPE
		,remark           tcustomer.remark%TYPE
		,limitcurrency    tcustomer.limitcurrency%TYPE
		,password         tcustomer.password%TYPE
		,expdate          tcustomer.expdate%TYPE
		,statementopcount tcustomer.statementopcount%TYPE
		,closeoperdate    tcustomer.closeoperdate%TYPE
		,createoperdate   tcustomer.createoperdate%TYPE
		,sign             tcustomer.sign%TYPE
		,branchpart       tcustomer.branchpart%TYPE
		,profile          tcustomer.profile%TYPE
		,certificate      tcustomer.certificate%TYPE
		,guid             types.guid
		,
		
		extauthlevel tcustomer.extauthlevel%TYPE
		,
		
		extauthmode     tcustomer.extauthmode%TYPE
		,limitgrpid      tcustomer.limitgrpid%TYPE
		,customerproduct tcustomer.customerproduct%TYPE
		,objectuid       tcustomer.objectuid%TYPE
		,
		
		activationdate tcustomer.activationdate%TYPE
		,externalid     tcustomer.externalid%TYPE
		,phonealias     tcustomer.phonealias%TYPE);
	TYPE typecustomerlist IS TABLE OF typecustomerrecord INDEX BY BINARY_INTEGER;

	TYPE typeaccount2customerrecord IS RECORD(
		 customer  tacc2customer.customer%TYPE
		,accountno tacc2customer.accountno%TYPE
		,acct_stat tacc2customer.acct_stat%TYPE
		,acctdescr tacc2customer.acctdescr%TYPE);
	TYPE typeaccount2customerlist IS TABLE OF typeaccount2customerrecord INDEX BY BINARY_INTEGER;

	TYPE typecard2customerrecord IS RECORD(
		 customer tcard2customer.customer%TYPE
		,pan      tcard2customer.pan%TYPE
		,mbr      tcard2customer.mbr%TYPE
		,descr    tcard2customer.descr%TYPE);
	TYPE typecard2customerlist IS TABLE OF typecard2customerrecord INDEX BY BINARY_INTEGER;

	TYPE typecustomersignrecord IS RECORD(
		 sign treferencecustomersign.sign%TYPE
		,NAME treferencecustomersign.name%TYPE);
	TYPE typecustomersignlist IS TABLE OF typecustomersignrecord INDEX BY BINARY_INTEGER;

	TYPE typecustomerstatrecord IS RECORD(
		 stat VARCHAR2(1)
		,NAME VARCHAR2(20));
	TYPE typecustomerstatlist IS TABLE OF typecustomerstatrecord INDEX BY BINARY_INTEGER;

	SUBTYPE typepaymentextid IS tpaymentext.paymentextid%TYPE;

	TYPE typeatmpaymentrecord IS RECORD(
		 code            tatmpayment.code%TYPE
		,pan             tatmpayment.pan%TYPE
		,mbr             tatmpayment.mbr%TYPE
		,vendorname      tatmpayment.vendorname%TYPE
		,bic             tatmpayment.bic%TYPE
		,setlaccount     tatmpayment.setlaccount%TYPE
		,inn             tatmpayment.inn%TYPE
		,destinfo        tatmpayment.destinfo%TYPE
		,backaccountno   tatmpayment.backaccountno%TYPE
		,opercode        tatmpayment.opercode%TYPE
		,menutext        tatmpayment.menutext%TYPE
		,updatesysdate   tatmpayment.updatesysdate%TYPE
		,templatecode    tatmpaymenttemplate.templatecode%TYPE
		,destinationcode tatmpaymentdestination.destinationcode%TYPE
		,
		
		paymentextid typepaymentextid
		,
		
		corraccount tatmpayment.corraccount%TYPE
		,kpp         tatmpayment.kpp%TYPE);
	TYPE typeatmpaymentlist IS TABLE OF typeatmpaymentrecord INDEX BY BINARY_INTEGER;

	TYPE typeregularpaymentrecord IS RECORD(
		 code              tregularpayment.code%TYPE
		,startdate         tregularpayment.startdate%TYPE
		,periodtype        tregularpayment.periodtype%TYPE
		,period            tregularpayment.period%TYPE
		,stopdate          tregularpayment.stopdate%TYPE
		,preacthold        tregularpayment.preacthold%TYPE
		,VALUE             tregularpayment.value%TYPE
		,feevalue          tregularpayment.feevalue%TYPE
		,currency          tregularpayment.currency%TYPE
		,exrate            tregularpayment.exrate%TYPE
		,stat              tregularpayment.stat%TYPE
		,priority          tregularpayment.priority%TYPE
		,vendorname        tregularpayment.vendorname%TYPE
		,bic               tregularpayment.bic%TYPE
		,setlaccount       tregularpayment.setlaccount%TYPE
		,inn               tregularpayment.inn%TYPE
		,kpp               tregularpayment.kpp%TYPE
		,destinfo          tregularpayment.destinfo%TYPE
		,backaccountno     tregularpayment.backaccountno%TYPE
		,opercode          tregularpayment.opercode%TYPE
		,createopdate      tregularpayment.createopdate%TYPE
		,createsysdate     tregularpayment.createsysdate%TYPE
		,createclerk       tregularpayment.createclerk%TYPE
		,reservingerror    tregularpayment.reservingerror%TYPE
		,reservingerrormsg tregularpayment.reservingerrormsg%TYPE
		,lastpaymentdate   tregularpayment.lastpaymentdate%TYPE
		,templatecode      tregpaymenttemplate.templatecode%TYPE
		,destinationcode   tregpaymentdestination.destinationcode%TYPE
		,accountno         tregularpayment.accountno%TYPE
		,contractno        tregularpayment.contractno%TYPE
		,
		
		paymentextid typepaymentextid
		,
		
		objectuid   tregularpayment.objectuid%TYPE
		,corraccount tregularpayment.corraccount%TYPE);
	TYPE typeregularpaymentlist IS TABLE OF typeregularpaymentrecord INDEX BY BINARY_INTEGER;

	TYPE typepaymentextrecord IS RECORD(
		 docno       NUMBER
		,paymentmode PLS_INTEGER
		,code        NUMBER
		,
		
		bic         tpaymentext.bic%TYPE
		,bankname    tpaymentext.bankname%TYPE
		,corraccount tpaymentext.corraccount%TYPE
		,vendorname  tpaymentext.vendorname%TYPE
		,account     tpaymentext.account%TYPE
		,inn         tpaymentext.inn%TYPE
		,destinfo    tpaymentext.destinfo%TYPE
		,paymentdate DATE
		,
		
		paymentextid typepaymentextid
		,
		
		kpp tpaymentext.kpp%TYPE);

	TYPE typepaymentinforecord IS RECORD(
		 code  tpaymentfields.code%TYPE
		,ident tpaymentextinfo.ident%TYPE
		,info  tpaymentextinfo.info%TYPE);
	TYPE typepaymentinfolist IS TABLE OF typepaymentinforecord INDEX BY BINARY_INTEGER;

	TYPE typepaymentrecord IS RECORD(
		 paymentmode      PLS_INTEGER
		,templatecode     NUMBER
		,destinationcode  NUMBER
		,bic              tpaymentext.bic%TYPE
		,bankname         tpaymentext.bankname%TYPE
		,corraccount      tpaymentext.corraccount%TYPE
		,vendorname       tpaymentext.vendorname%TYPE
		,account          tpaymentext.account%TYPE
		,inn              tpaymentext.inn%TYPE
		,debitaccount     taccount.accountno%TYPE
		,creditaccount    tpaymenttemplate.backaccountno%TYPE
		,destinfo         tpaymentext.destinfo%TYPE
		,orgtext          tpaymentdestination.text%TYPE
		,opercode         tpaymenttemplate.opercode%TYPE
		,menutext         tpaymentdestination.menutext%TYPE
		,fpaymentstopped  BOOLEAN
		,ftemplatestopped BOOLEAN
		,fdeststopped     BOOLEAN
		,sic              tpaymenttemplate.sic%TYPE
		,latinname        tpaymenttemplate.latinname%TYPE
		,shortlatinname   tpaymenttemplate.shortlatinname%TYPE
		,chequetext       tpaymentdestination.chequetext%TYPE
		,
		
		paymentextid typepaymentextid
		,
		
		kpp tpaymenttemplate.kpp%TYPE);

	TYPE typecommissionsignrecord IS RECORD(
		 code treferencecommission.commission%TYPE
		,NAME treferencecommission.name%TYPE
		,make BOOLEAN);

	TYPE typecommissionsignlist IS TABLE OF typecommissionsignrecord INDEX BY BINARY_INTEGER;

	TYPE typeregpaybatchrecord IS RECORD(
		 packno          tregularreservpacket.packno%TYPE
		,allreccount     tregularreservpacket.allreccount%TYPE
		,reservereccount tregularreservpacket.reservereccount%TYPE
		,execreccount    tregularreservpacket.execreccount%TYPE
		,errorreccount   tregularreservpacket.errorreccount%TYPE
		,createdate      tregularreservpacket.createdate%TYPE
		,createsysdate   tregularreservpacket.createsysdate%TYPE);

	TYPE typeregpaybatchrecordrecord IS RECORD(
		 packno        tregularpaymentreserv.packno%TYPE
		,recno         tregularpaymentreserv.recno%TYPE
		,accountno     tregularpaymentreserv.accountno%TYPE
		,code          tregularpaymentreserv.code%TYPE
		,paymentdate   tregularpaymentreserv.paymentdate%TYPE
		,reservedvalue tregularpaymentreserv.reservedvalue%TYPE
		,createsysdate tregularpaymentreserv.createsysdate%TYPE
		,createopdate  tregularpaymentreserv.createopdate%TYPE
		,docno         tregularpaymentreserv.docno%TYPE
		,error         tregularpaymentreserv.error%TYPE
		,errormsg      tregularpaymentreserv.errormsg%TYPE
		,preacthold    tregularpaymentreserv.preacthold%TYPE
		,contractno    tregularpaymentreserv.contractno%TYPE
		,reservestring tregularpaymentreserv.reservestring%TYPE);

	TYPE typeentryrecord IS RECORD(
		 docno                tentry.docno%TYPE
		,no                   tentry.no%TYPE
		,doctype              tdocument.doctype%TYPE
		,opdate               tdocument.opdate%TYPE
		,clerkcode            tdocument.clerkcode%TYPE
		,station              tdocument.station%TYPE
		,parentdocno          tdocument.parentdocno%TYPE
		,childdocno           tdocument.childdocno%TYPE
		,description          tdocument.description%TYPE
		,systemdate           tdocument.systemdate%TYPE
		,valuedate            tentry.valuedate%TYPE
		,entcode              tentry.debitentcode%TYPE
		,addentcode           tentry.creditentcode%TYPE
		,debitaccount         tentry.debitaccount%TYPE
		,VALUE                tentry.value%TYPE
		,creditaccount        tentry.creditaccount%TYPE
		,shortremark          tentry.shortremark%TYPE
		,fullremark           tentry.fullremark%TYPE
		,onlinedebittranid    tentry.onlinedebittranid%TYPE
		,onlinecredittranid   tentry.onlinecredittranid%TYPE
		,entrygroupid         tentry.entrygroupid%TYPE
		,remain               taccount.remain%TYPE
		,pan                  tatmext.pan%TYPE
		,mbr                  tatmext.mbr%TYPE
		,trentcode            tatmext.entcode%TYPE
		,trcurrency           tatmext.currency%TYPE
		,trvalue              tatmext.value%TYPE
		,orgcurrency          tatmext.orgcurrency%TYPE
		,orgvalue             tatmext.orgvalue%TYPE
		,fromacct             tatmext.accountnoone%TYPE
		,toacct               tatmext.accountnotwo%TYPE
		,approval             tatmext.approval%TYPE
		,issuercode           tatmext.isscode%TYPE
		,acquirercode         tatmext.ficode%TYPE
		,retailerid           tposcheque.retailer%TYPE
		,device               tatmext.device%TYPE
		,termcode             tatmext.termcode%TYPE
		,termid               tatmext.term%TYPE
		,termlocation         tatmext.termlocation%TYPE
		,invoice              tatmext.invoice%TYPE
		,siccode              tatmext.siccode%TYPE
		,stan                 tatmext.stan%TYPE
		,expdate              tatmext.expdate%TYPE
		,acquireriin          tatmext.acquireriin%TYPE
		,forwardiin           tatmext.forwardiin%TYPE
		,isscountry           tatmext.isscountry%TYPE
		,acqcountry           tatmext.acqcountry%TYPE
		,trancode             tatmext.trancode%TYPE
		,enttype              tatmext.enttype%TYPE
		,messageno            tatmext.messageno%TYPE
		,userdata             texcommon.userdata%TYPE
		,paymode              tpaymentext.paymentmode%TYPE
		,paycode              tpaymentext.code%TYPE
		,paybic               tpaymentext.bic%TYPE
		,paybankname          tpaymentext.bankname%TYPE
		,paycorracc           tpaymentext.corraccount%TYPE
		,payvendorname        tpaymentext.vendorname%TYPE
		,paysettlacc          tpaymentext.account%TYPE
		,payinn               tpaymentext.inn%TYPE
		,payinfo              tpaymentext.destinfo%TYPE
		,paydate              tpaymentext.paymentdate%TYPE
		,paykpp               tpaymentext.kpp%TYPE
		,acqfee               tatmext.acqfee%TYPE
		,acqfeecurrency       tatmext.acqfeecurrency%TYPE
		,issfee               tatmext.issfee%TYPE
		,issfeecurrency       tatmext.issfeecurrency%TYPE
		,intrfee              tatmext.intrfee%TYPE
		,intrfeecurrency      tatmext.intrfeecurrency%TYPE
		,fullreverse          tatmext.fullreverse%TYPE
		,termbatchno          tposcheque.termbatchno%TYPE
		,eventobjecttype      teventpaymentext.objecttype%TYPE
		,eventobjectno        teventpaymentext.objectno%TYPE
		,eventno              teventpaymentext.eventno%TYPE
		,eventcode            teventpaymentext.eventcode%TYPE
		,eventkey             teventpaymentext.eventkey%TYPE
		,chequeopcode         tchequeext.opcode%TYPE
		,chequebookno         tchequeext.bookno%TYPE
		,chequeserialno       tchequeext.serialno%TYPE
		,chequeaccountno      tchequeext.accountno%TYPE
		,chequecustomername   tchequeext.customername%TYPE
		,chequeamount         tchequeext.amount%TYPE
		,chequecurrency       tchequeext.currency%TYPE
		,chequedrawdate       tchequeext.drawdate%TYPE
		,chequeinputdate      tchequeext.inputdate%TYPE
		,chequeresponse       tchequeext.response%TYPE
		,chequeresponseremark tchequeext.responseremark%TYPE
		,chequerequest        tchequeext.chequerequest%TYPE
		,chequeoperid         tchequeext.chequeoperid%TYPE
		,chequeuserdata       tchequeext.userdata%TYPE
		,enttypeext           tatmext.enttypeext%TYPE
		,prevtrandocno        tatmext.prevtrandocno%TYPE
		,nexttrandocno        tatmext.nexttrandocno%TYPE
		,prevtrancode         tatmext.prevtrancode%TYPE
		,cardproduct          tatmext.cardproduct%TYPE
		,exchangecode         tatmext.exchangecode%TYPE
		,exchangedate         tatmext.exchangedate%TYPE
		,termcountry          tatmext.termcountry%TYPE
		,termcity             tatmext.termcity%TYPE
		,acctimpactlist       tatmext.acctimpactlist%TYPE
		,guid                 types.guid
		,extdescription       tatmext.trandescription%TYPE
		,installmentdata      tatmext.installmentdata%TYPE
		,termretailername     tatmext.termretailername%TYPE
		,origtime             texcommon.trandate%TYPE
		,originalinvoice      tposcheque.originalinvoice%TYPE
		,additionalfields     tatmext.additionalfields%TYPE
		,additionalfieldsclob tatmext.additionalfieldsclob%TYPE
		,incpsfields          tatmext.incpsfields%TYPE
		,fptti                tatmext.fptti%TYPE
		,aliasdata            tatmext.aliasdata%TYPE
		,messtocardholder     tatmext.messtocardholder%TYPE
		,tipamount            tposcheque.tipamount%TYPE);
	TYPE typeentrylist IS TABLE OF typeentryrecord INDEX BY BINARY_INTEGER;

	TYPE typepersonerecord IS RECORD(
		 idclient      tclientpersone.idclient%TYPE
		,fio           tclientpersone.fio%TYPE
		,firstname     tclientpersone.firstname%TYPE
		,middlename    tclientpersone.middlename%TYPE
		,lastname      tclientpersone.lastname%TYPE
		,countryres    tclientpersone.countryres%TYPE
		,sex           tclientpersone.sex%TYPE
		,latfio        tclientpersone.latfio%TYPE
		,latfirstname  tclientpersone.latfirstname%TYPE
		,latmiddlename tclientpersone.latmiddlename%TYPE
		,latlastname   tclientpersone.latlastname%TYPE
		,birthday      tclientpersone.birthday%TYPE
		,birthfio      tclientpersone.birthfio%TYPE
		,birthplace    tclientpersone.birthplace%TYPE
		,deathdate     tclientpersone.deathdate%TYPE
		,no            tidentity.no%TYPE
		,identitytype  tidentity.type%TYPE
		,givendate     tidentity.givendate%TYPE
		,givenplace    tidentity.givenplace%TYPE
		,identexpdate  tidentity.expdate%TYPE
		,department    tidentity.department%TYPE
		,countryreg    tclientpersone.countryreg%TYPE
		,regionreg     tclientpersone.regionreg%TYPE
		,cityreg       tclientpersone.cityreg%TYPE
		,zipreg        tclientpersone.zipreg%TYPE
		,addressreg    tclientpersone.addressreg%TYPE
		,streetreg     tclientpersone.streetreg%TYPE
		,housereg      tclientpersone.housereg%TYPE
		,buildingreg   tclientpersone.buildingreg%TYPE
		,framereg      tclientpersone.framereg%TYPE
		,flatreg       tclientpersone.flatreg%TYPE
		,countrylive   tclientpersone.countrylive%TYPE
		,regionlive    tclientpersone.regionlive%TYPE
		,citylive      tclientpersone.citylive%TYPE
		,ziplive       tclientpersone.ziplive%TYPE
		,address       tclientpersone.address%TYPE
		,streetlive    tclientpersone.streetlive%TYPE
		,houselive     tclientpersone.houselive%TYPE
		,buildinglive  tclientpersone.buildinglive%TYPE
		,framelive     tclientpersone.framelive%TYPE
		,flatlive      tclientpersone.flatlive%TYPE
		,countrycont   tclientpersone.countrycont%TYPE
		,regioncont    tclientpersone.regioncont%TYPE
		,citycont      tclientpersone.citycont%TYPE
		,zipcont       tclientpersone.zipcont%TYPE
		,addresscont   tclientpersone.addresscont%TYPE
		,streetcont    tclientpersone.streetcont%TYPE
		,housecont     tclientpersone.housecont%TYPE
		,buildingcont  tclientpersone.buildingcont%TYPE
		,framecont     tclientpersone.framecont%TYPE
		,flatcont      tclientpersone.flatcont%TYPE
		,phone         tclientpersone.phone%TYPE
		,fax           tclientpersone.fax%TYPE
		,email         tclientpersone.email%TYPE
		,mobilephone   tclientpersone.mobilephone%TYPE
		,pager         tclientpersone.pager%TYPE
		,company       tclientpersone.company%TYPE
		,office        tclientpersone.office%TYPE
		,tabno         tclientpersone.tabno%TYPE
		,jobtitle      tclientpersone.jobtitle%TYPE
		,jobphone      tclientpersone.jobphone%TYPE
		,startjobtime  tclientpersone.startjobtime%TYPE
		,prevjob       tclientpersone.prevjob%TYPE
		,salary        tclientpersone.salary%TYPE
		,inn           tclientpersone.inn%TYPE
		,family        tclientpersone.family%TYPE
		,education     tclientpersone.education%TYPE
		,occupation    tclientpersone.occupation%TYPE
		,secretquery   tclientpersone.secretquery%TYPE
		,secretanswer  tclientpersone.secretanswer%TYPE
		,additional    tclientpersone.additional%TYPE
		,vip           tclientpersone.vip%TYPE
		,insider       tclientpersone.insider%TYPE
		,resident      tclientpersone.resident%TYPE
		,objrestricted tclientpersone.objrestricted%TYPE
		,statementpath tclientpersone.statementpath%TYPE
		,cnsscheme     tclientpersone.cnsscheme%TYPE
		,cnschannel    tclientpersone.cnschannel%TYPE
		,cnsaddress    tclientpersone.cnsaddress%TYPE
		,personalcode  tclientpersone.personalcode%TYPE
		,title         tclientpersone.title%TYPE
		,statementlang tclientpersone.statementlang%TYPE
		,riskgroup     tclientpersone.riskgroup%TYPE
		,branchpart    tclient.branchpart%TYPE
		,externalid    tclientpersone.externalid%TYPE
		,clerkcreate   tclientpersone.clerkcreate%TYPE
		,clerkmodify   tclientpersone.clerkmodify%TYPE
		,datecreate    tclientpersone.datecreate%TYPE
		,datemodify    tclientpersone.datemodify%TYPE
		,affiliate     tclientpersone.affiliate%TYPE
		,bankrupt      tclientpersone.bankrupt%TYPE
		,shareholder   tclientpersone.shareholder%TYPE
		,
		
		--persontype tclientpersone.persontype%TYPE
		--,ogrnip     tclientpersone.ogrnip%TYPE
		--,regdateip  tclientpersone.regdateip%TYPE
		--,statusofip tclientpersone.statusofip%TYPE
		
		guid              types.guid
		,categoryid        tclientpersone.categoryid%TYPE
		,grplimit          tclientpersone.grplimit%TYPE
		,grplimitint       tclientpersone.grplimitint%TYPE
		,limitcurrency     tclientpersone.limitcurrency%TYPE
		,grpcounters       tclientpersone.grpcounters%TYPE
		,personaldataexist tclientpersone.personaldataexist%TYPE
		,dateofcompletion  tclientpersone.dateofcompletion%TYPE);
	TYPE typepersonelist IS TABLE OF typepersonerecord INDEX BY BINARY_INTEGER;

	TYPE typeadditionaldocrecord IS RECORD(
		 TYPE        treferenceadditionaldoc.doctype%TYPE
		,description treferenceadditionaldoc.descript%TYPE
		,no          tadditionaldocument.no%TYPE
		,startdate   tadditionaldocument.regdate%TYPE
		,enddate     tadditionaldocument.expdate%TYPE
		,extid       treferenceadditionaldoc.extid%TYPE
		,remark      tadditionaldocument.remark%TYPE);
	TYPE typeadditionaldoclist IS TABLE OF typeadditionaldocrecord INDEX BY BINARY_INTEGER;

	TYPE typecompanyrecord IS RECORD(
		 idclient       tclientbank.idclient%TYPE
		,NAME           tclientbank.name%TYPE
		,countrylegal   tclientbank.countrylegal%TYPE
		,regionlegal    tclientbank.regionlegal%TYPE
		,citylegal      tclientbank.citylegal%TYPE
		,ziplegal       tclientbank.ziplegal%TYPE
		,addresslegal   tclientbank.addresslegal%TYPE
		,streetlegal    tclientbank.streetlegal%TYPE
		,houselegal     tclientbank.houselegal%TYPE
		,buildinglegal  tclientbank.buildinglegal%TYPE
		,framelegal     tclientbank.framelegal%TYPE
		,flatlegal      tclientbank.flatlegal%TYPE
		,phonelegal     tclientbank.phonelegal%TYPE
		,faxlegal       tclientbank.faxlegal%TYPE
		,emaillegal     tclientbank.emaillegal%TYPE
		,countrycont    tclientbank.countrycont%TYPE
		,regioncont     tclientbank.regioncont%TYPE
		,citycont       tclientbank.citycont%TYPE
		,zipcont        tclientbank.zipcont%TYPE
		,addresscont    tclientbank.addresscont%TYPE
		,streetcont     tclientbank.streetcont%TYPE
		,housecont      tclientbank.housecont%TYPE
		,buildingcont   tclientbank.buildingcont%TYPE
		,framecont      tclientbank.framecont%TYPE
		,flatcont       tclientbank.flatcont%TYPE
		,phonecont      tclientbank.phonecont%TYPE
		,faxcont        tclientbank.faxcont%TYPE
		,emailcont      tclientbank.emailcont%TYPE
		,regno          tclientbank.regno%TYPE
		,regdate        tclientbank.regdate%TYPE
		,closedate      tclientbank.closedate%TYPE
		,register       tclientbank.register%TYPE
		,inn            tclientbank.inn%TYPE
		,okfs           treferenceownform.name%TYPE
		,okopf          treferenceopf.name%TYPE
		,shortname      tclientbank.shortname%TYPE
		,countrypostal  tclientbank.countrypostal%TYPE
		,regionpostal   tclientbank.regionpostal%TYPE
		,citypostal     tclientbank.citypostal%TYPE
		,zippostal      tclientbank.zippostal%TYPE
		,addresspostal  tclientbank.addresspostal%TYPE
		,streetpostal   tclientbank.streetpostal%TYPE
		,housepostal    tclientbank.housepostal%TYPE
		,buildingpostal tclientbank.buildingpostal%TYPE
		,framepostal    tclientbank.framepostal%TYPE
		,flatpostal     tclientbank.flatpostal%TYPE
		,companycode    tclientbank.companycode%TYPE
		,additional     tclientbank.additional%TYPE
		,transname      tclientbank.transname%TYPE
		,statementpath  tclientbank.statementpath%TYPE
		,statementlang  tclientbank.statementlang%TYPE
		,clerkcreate    tclientbank.clerkcreate%TYPE
		,clerkmodify    tclientbank.clerkmodify%TYPE
		,datecreate     tclientbank.datecreate%TYPE
		,datemodify     tclientbank.datemodify%TYPE
		,branchpart     tclient.branchpart%TYPE
		,externalid     tclientbank.externalid%TYPE
		,guid           types.guid
		,kpp            tclientbank.kpp%TYPE
		,ogrn           tclientbank.ogrn%TYPE);

	TYPE typecorraccrecord IS RECORD(
		 bic     tclientbankcorraccount.bic%TYPE
		,corracc tclientbankcorraccount.corracc%TYPE
		,account tclientbankcorraccount.account%TYPE);
	TYPE typecorracclist IS TABLE OF typecorraccrecord INDEX BY BINARY_INTEGER;

	TYPE typecontactinforecord IS RECORD(
		 fio          tclientcontactinfo.fio%TYPE
		,jobtitle     tclientcontactinfo.jobtitle%TYPE
		,info         tclientcontactinfo.info%TYPE
		,clientidlink tclientcontactinfo.clientidlink%TYPE);
	TYPE typecontactinfolist IS TABLE OF typecontactinforecord INDEX BY BINARY_INTEGER;

	TYPE typecontracttyperecord IS RECORD(
		 TYPE        tcontracttype.type%TYPE
		,NAME        tcontracttype.name%TYPE
		,status      tcontracttype.status%TYPE
		,accessory   tcontracttype.accessory%TYPE
		,schematype  tcontracttype.schematype%TYPE
		,description tcontracttype.description%TYPE
		,startdate   DATE
		,enddate     DATE);
	TYPE typecontracttypelist IS TABLE OF typecontracttyperecord INDEX BY BINARY_INTEGER;

	TYPE typecontractrecord IS RECORD(
		 no          tcontract.no%TYPE
		,TYPE        tcontract.type%TYPE
		,idclient    tcontract.idclient%TYPE
		,createclerk tcontract.createclerk%TYPE
		,createdate  tcontract.createdate%TYPE
		,closeclerk  tcontract.closeclerk%TYPE
		,closedate   tcontract.closedate%TYPE
		,status      tcontract.status%TYPE
		,branchpart  tcontract.branchpart%TYPE
		,guid        types.guid);
	TYPE typecontractlist IS TABLE OF typecontractrecord INDEX BY BINARY_INTEGER;

	TYPE typecontracttypeinfo IS RECORD(
		 code NUMBER
		,NAME VARCHAR2(128));
	TYPE typecontracttypeinfolist IS TABLE OF typecontracttypeinfo INDEX BY PLS_INTEGER;

	TYPE typegroupcontracttypeinfo IS RECORD(
		 code NUMBER
		,NAME VARCHAR2(128));
	TYPE typegroupcontracttypeinfolist IS TABLE OF typegroupcontracttypeinfo INDEX BY PLS_INTEGER;

	TYPE typedirectdebitmandaterecord IS RECORD(
		 id                  tcontractdirectdebit.recid%TYPE
		,extid               tcontractdirectdebit.extid%TYPE
		,contractno          tcontractdirectdebit.contractno%TYPE
		,accountno           tcontractdirectdebit.accountno%TYPE
		,creationopdate      tcontractdirectdebit.creationopdate%TYPE
		,creationsysdate     tcontractdirectdebit.creationsysdate%TYPE
		,createdby           tcontractdirectdebit.createdby%TYPE
		,status              tcontractdirectdebit.status%TYPE
		,VALUE               tcontractdirectdebit.value%TYPE
		,currency            tcontractdirectdebit.currency%TYPE
		,duedate             tcontractdirectdebit.duedate%TYPE
		,bankcode            tcontractdirectdebit.bankcode%TYPE
		,bankname            tcontractdirectdebit.bankname%TYPE
		,bankbranch          tcontractdirectdebit.bankbranch%TYPE
		,sourceaccount       tcontractdirectdebit.sourceaccount%TYPE
		,clearingresultid    tcontractdirectdebit.clearingresultid%TYPE
		,clearingresult      treferenceddresponse.code%TYPE
		,clearingopdate      tcontractdirectdebit.clearingopdate%TYPE
		,clearingsysdate     tcontractdirectdebit.clearingsysdate%TYPE
		,clearedby           tcontractdirectdebit.clearedby%TYPE
		,clearedvalue        tcontractdirectdebit.clearedvalue%TYPE
		,additionalinfo      tcontractdirectdebit.additionalinfo%TYPE
		,modificationopdate  tcontractdirectdebit.modificationopdate%TYPE
		,modificationsysdate tcontractdirectdebit.modificationsysdate%TYPE
		,modifiedby          tcontractdirectdebit.modifiedby%TYPE
		,guid                types.guid);
	TYPE typedirectdebitmandatelist IS TABLE OF typedirectdebitmandaterecord INDEX BY BINARY_INTEGER;

	TYPE typewarrantrecord IS RECORD(
		 no            twarrant.no%TYPE
		,begindate     twarrant.begindate%TYPE
		,expdate       twarrant.expdate%TYPE
		,sourceid      twarrant.sourceid%TYPE
		,destid        twarrant.destid%TYPE
		,wtype         twarrant.wtype%TYPE
		,activity      twarrant.activity%TYPE
		,createdate    twarrant.createdate%TYPE
		,createclerk   twarrant.createclerk%TYPE
		,modifydate    twarrant.modifydate%TYPE
		,modifyclerk   twarrant.modifyclerk%TYPE
		,updatesysdate twarrant.updatesysdate%TYPE
		,complete      twarrant.complete%TYPE
		,notarial      twarrant.notarial%TYPE
		,additional    twarrant.additional%TYPE
		,guid          types.guid);
	TYPE typewarrantlist IS TABLE OF typewarrantrecord INDEX BY BINARY_INTEGER;

	TYPE typebeneficiaryrecord IS RECORD(
		 destid      ttastamentbeneficiary.destid%TYPE
		,note        ttastamentbeneficiary.note%TYPE
		,counterator ttastamentbeneficiary.counterator%TYPE
		,denominator ttastamentbeneficiary.denominator%TYPE);
	TYPE typebeneficiarylist IS TABLE OF typebeneficiaryrecord INDEX BY BINARY_INTEGER;

	TYPE typetestamentrecord IS RECORD(
		 no              ttastament.no%TYPE
		,begindate       ttastament.begindate%TYPE
		,sourceid        ttastament.sourceid%TYPE
		,destid          ttastament.destid%TYPE
		,ttype           ttastament.ttype%TYPE
		,activity        ttastament.activity%TYPE
		,note            ttastament.note%TYPE
		,counterator     ttastament.counterator%TYPE
		,denominator     ttastament.denominator%TYPE
		,createdate      ttastament.createdate%TYPE
		,createclerk     ttastament.createclerk%TYPE
		,modifydate      ttastament.modifydate%TYPE
		,modifyclerk     ttastament.modifyclerk%TYPE
		,updatesysdate   ttastament.updatesysdate%TYPE
		,beneficiarylist typebeneficiarylist
		,guid            types.guid);
	TYPE typetestamentlist IS TABLE OF typetestamentrecord INDEX BY BINARY_INTEGER;

	TYPE typeextractpacket IS RECORD(
		 packno        textractpacket.packno%TYPE
		,mindate       textractpacket.mindate%TYPE
		,maxdate       textractpacket.maxdate%TYPE
		,reccount      textractpacket.reccount%TYPE
		,donecount     textractpacket.donecount%TYPE
		,errcount      textractpacket.errcount%TYPE
		,warncount     textractpacket.warncount%TYPE
		,rollbackcount textractpacket.rollbackcount%TYPE
		,description   textractpacket.description%TYPE
		,SOURCE        textractpacket.source%TYPE
		,createdate    textractpacket.createdate%TYPE
		,rollbackdate  textractpacket.rollbackdate%TYPE);

	TYPE typeissuerfee IS RECORD(
		 backid   VARCHAR(20)
		,VALUE    NUMBER
		,islatent BOOLEAN);
	TYPE typeissuerfeelist IS TABLE OF typeissuerfee INDEX BY BINARY_INTEGER;

	TYPE typeextractrecord IS RECORD(
		 device       textract.device%TYPE
		,enttype      textract.enttype%TYPE
		,entcode      textract.entcode%TYPE
		,trandate     textract.operdate%TYPE
		,enttypeext   textract.enttypeext%TYPE
		,prevtrancode textract.prevtrancode%TYPE
		,origtype     textract.origtype%TYPE
		,
		
		issps       textract.psissuer%TYPE
		,issfiid     textract.issuerfiid%TYPE
		,isscode     NUMBER
		,isscountry  textract.isscountry%TYPE
		,cardprefix  textract.pan%TYPE
		,cardproduct NUMBER
		,pan         textract.pan%TYPE
		,mbr         textract.mbr%TYPE
		,pvv         textract.pinoffset%TYPE
		,cvv         textract.cvv%TYPE
		,cvv2        textract.cvv2%TYPE
		,expdate     textract.expdate%TYPE
		,approval    textract.approval%TYPE
		,
		
		offlinevalue    textract.offlinevalue%TYPE
		,offlinecurrency textract.offlinecurrency%TYPE
		,offlineatc      textract.offlineatc%TYPE
		,offlineatcprev  textract.offlineatcprev%TYPE
		,
		
		acqps        textract.psacquirer%TYPE
		,acqfiid      textract.acquirerfiid%TYPE
		,acqcode      NUMBER
		,acqcountry   textract.acqcountry%TYPE
		,retailer     textract.retailer%TYPE
		,term         textract.term%TYPE
		,orgterm      textract.term%TYPE
		,termcode     NUMBER
		,termlocation textract.termlocation%TYPE
		,mcc          textract.siccode%TYPE
		,stan         textract.stan%TYPE
		,invoice      textract.invoice%TYPE
		,acqiin       textract.acquireriin%TYPE
		,forwardiin   textract.forwardiin%TYPE
		,messageno    textract.messageno%TYPE
		,
		
		cnsend     textract.cnsend%TYPE
		,cnsscheme  textract.cnsscheme%TYPE
		,cnschannel textract.cnschannel%TYPE
		,cnsaddress textract.cnsaddress%TYPE
		,
		
		amount          textract.value%TYPE
		,withdrawal      textract.withdrawal%TYPE
		,currency        textract.currency%TYPE
		,orgamount       textract.orgvalue%TYPE
		,orgcurrency     textract.orgcurrency%TYPE
		,acqfee          textract.fee%TYPE
		,acqfeecurrency  textract.currency%TYPE
		,issfee          textract.issfee%TYPE
		,issfeecurrency  textract.issfeecurrency%TYPE
		,intrfee         textract.intrfee%TYPE
		,intrfeecurrency textract.intrfeecurrency%TYPE
		,fromacct        textract.debitaccountno%TYPE
		,toacct          textract.creditaccountno%TYPE
		,orgfromacct     textract.debitaccountno%TYPE
		,orgtoacct       textract.creditaccountno%TYPE
		,
		
		errorno                 textract.errorno%TYPE
		,warning                 textract.warning%TYPE
		,docno                   textract.docno%TYPE
		,trancode                textract.trancode%TYPE
		,userdata                textract.userdata%TYPE
		,receiptflag             textract.receiptflag%TYPE
		,cardtype                textract.cardtype%TYPE
		,fromaccttype            textract.debitaccounttype%TYPE
		,cardsign                tcard.signstat%TYPE
		,preauthhold             textract.preauthhold%TYPE
		,paymenthostid           textract.paymenthostid%TYPE
		,fromacctamount          textract.debitaccountvalue%TYPE
		,fromacctcurrency        textract.debitaccountcurrency%TYPE
		,bonusaccumulation       textract.bonusaccumulation%TYPE
		,frontpaymentid          textract.frontpaymentid%TYPE
		,backpaymentid           textract.backpaymentid%TYPE
		,fullreverse             textract.fullreverse%TYPE
		,origtrancode            textract.origtrancode%TYPE
		,draftcapture            textract.draftcapture%TYPE
		,termbatchno             textract.termbatchno%TYPE
		,toacctamount            textract.creditaccountvalue%TYPE
		,toacctcurrency          textract.creditaccountcurrency%TYPE
		,poscondition            textract.poscondition%TYPE
		,termcontactlesscapable  textract.termcontactlesscapable%TYPE
		,multitrannumber         textract.multitrannumber%TYPE
		,multitrancount          textract.multitrancount%TYPE
		,posentrymode            textract.posentrymode%TYPE
		,installmentdata         textract.installmentdata%TYPE
		,extdescription          textract.extdescription%TYPE
		,operdaterollback        textract.operdaterollback%TYPE
		,bonusprogramname        textract.bonusprogramname%TYPE
		,prizeid                 textract.prizeid%TYPE
		,prizequantity           textract.prizequantity%TYPE
		,stan2                   textract.stan2%TYPE
		,issuerfeelist           textract.issuerfeelist%TYPE
		,particularoperationdata textract.particularoperationdata%TYPE
		,acctimpactlist          textract.acctimpactlist%TYPE
		,ac_availbalancebefore   textract.ac_availbalancebefore%TYPE
		,TIME                    textract.time%TYPE
		,tokendata               textract.tokendata%TYPE
		,termcountry             textract.termcountry%TYPE
		,originalinvoice         textract.originalinvoice%TYPE
		,orgfee                  textract.orgfee%TYPE
		,messtocardholder        textract.messtocardholder%TYPE
		,protectedamount         textract.protectedamount%TYPE
		,protectedamountbefore   textract.protectedamountbefore%TYPE
		,amountorigdcc           textract.amountorigdcc%TYPE
		,dccfee                  textract.dccfee%TYPE
		,tipamount               textract.tipamount%TYPE
		--,foreignexchind          textract.foreignexchind%TYPE
		--,cardprofile             textract.cardprofile%TYPE
		);
	TYPE typeextractlist IS TABLE OF typeextractrecord INDEX BY BINARY_INTEGER;

	TYPE typeextractdelayrecord IS RECORD(
		 device   textractdelay.device%TYPE
		,enttype  textractdelay.enttype%TYPE
		,entcode  textractdelay.entcode%TYPE
		,trandate textractdelay.operdate%TYPE
		,
		
		issps      textractdelay.psissuer%TYPE
		,issfiid    textractdelay.issuerfiid%TYPE
		,isscountry textractdelay.isscountry%TYPE
		,pan        textractdelay.pan%TYPE
		,mbr        textractdelay.mbr%TYPE
		,pvv        textractdelay.pinoffset%TYPE
		,cvv        textractdelay.cvv%TYPE
		,cvv2       textractdelay.cvv2%TYPE
		,expdate    textractdelay.expdate%TYPE
		,approval   textractdelay.approval%TYPE
		,
		
		acqps        textractdelay.psacquirer%TYPE
		,acqfiid      textractdelay.acquirerfiid%TYPE
		,acqcountry   textractdelay.acqcountry%TYPE
		,retailer     textractdelay.retailer%TYPE
		,orgterm      textractdelay.term%TYPE
		,termlocation textractdelay.termlocation%TYPE
		,mcc          textractdelay.siccode%TYPE
		,stan         textractdelay.stan%TYPE
		,invoice      textractdelay.invoice%TYPE
		,acqiin       textractdelay.acquireriin%TYPE
		,forwardiin   textractdelay.forwardiin%TYPE
		,messageno    textractdelay.messageno%TYPE
		,cnsend       textractdelay.cnsend%TYPE
		,
		
		amount          textractdelay.value%TYPE
		,withdrawal      textractdelay.withdrawal%TYPE
		,currency        textractdelay.currency%TYPE
		,orgamount       textractdelay.orgvalue%TYPE
		,orgcurrency     textractdelay.orgcurrency%TYPE
		,acqfee          textractdelay.fee%TYPE
		,acqfeecurrency  textractdelay.currency%TYPE
		,issfee          textractdelay.issfee%TYPE
		,issfeecurrency  textractdelay.issfeecurrency%TYPE
		,intrfee         textractdelay.intrfee%TYPE
		,intrfeecurrency textractdelay.intrfeecurrency%TYPE
		,fromacct        textractdelay.debitaccountno%TYPE
		,toacct          textractdelay.creditaccountno%TYPE
		,
		
		errorno               textractdelay.errorno%TYPE
		,warning               textractdelay.warning%TYPE
		,docno                 textractdelay.docno%TYPE
		,trancode              textractdelay.trancode%TYPE
		,userdata              textractdelay.userdata%TYPE
		,fromacctamount        textractdelay.debitaccountvalue%TYPE
		,fromacctcurrency      textractdelay.debitaccountcurrency%TYPE
		,TIME                  textractdelay.time%TYPE
		,originalinvoice       textractdelay.originalinvoice%TYPE
		,orgfee                textractdelay.orgfee%TYPE
		,messtocardholder      textractdelay.messtocardholder%TYPE
		,protectedamount       textractdelay.protectedamount%TYPE
		,protectedamountbefore textractdelay.protectedamountbefore%TYPE
		,tipamount             textractdelay.tipamount%TYPE
		--,cardprofile           textractdelay.cardprofile%TYPE
		);
	TYPE typeextractdelaylist IS TABLE OF typeextractdelayrecord INDEX BY BINARY_INTEGER;

	TYPE typeextractbonusrecord IS RECORD(
		 programname VARCHAR(20)
		,entrycode   NUMBER
		,accountno   VARCHAR(30)
		,VALUE       NUMBER);

	TYPE typeextractholdrecord IS RECORD(
		 accountno       textractdelay.debitaccountno%TYPE
		,VALUE           textractdelay.value%TYPE
		,TYPE            VARCHAR(1)
		,status          NUMBER
		,docno           textractdelay.docno%TYPE
		,pan             textractdelay.pan%TYPE
		,mbr             textractdelay.mbr%TYPE
		,device          textractdelay.device%TYPE
		,entcode         textractdelay.entcode%TYPE
		,packno          textractdelay.packno%TYPE
		,recno           textractdelay.recno%TYPE
		,installmentdata textractdelay.installmentdata%TYPE
		,mcc             textractdelay.siccode%TYPE);
	TYPE typeextractholdlist IS TABLE OF typeextractholdrecord INDEX BY BINARY_INTEGER;

	TYPE typetransferrecord IS RECORD(
		 debitaccountno  VARCHAR(20)
		,debitvalue      NUMBER
		,debitcurrency   NUMBER
		,creditaccountno VARCHAR(20)
		,creditvalue     NUMBER
		,creditcurrency  NUMBER
		,entrycode       NUMBER);

	TYPE typeretailadjustingrecord IS RECORD(
		
		 docno          tdocument.docno%TYPE
		,opdate         tdocument.opdate%TYPE
		,VALUE          tentry.value%TYPE
		,tranaccount    taccgroup.account%TYPE
		,trancurrency   taccgroup.currency%TYPE
		,debitdirection BOOLEAN
		,
		
		device   tposcheque.device%TYPE
		,enttype  tposcheque.enttype%TYPE
		,entcode  tposcheque.entcode%TYPE
		,trandate tposcheque.valuedate%TYPE
		,
		
		issfiid     treferencefi.fiid%TYPE
		,isscode     tposcheque.isscode%TYPE
		,isscountry  tposcheque.isscountry%TYPE
		,cardprefix  tposcheque.pan%TYPE
		,cardproduct treferencecardproduct.code%TYPE
		,pan         tposcheque.pan%TYPE
		,mbr         tposcheque.mbr%TYPE
		,expdate     tposcheque.expdate%TYPE
		,approval    tposcheque.approval%TYPE
		,
		
		acqfiid      treferencefi.fiid%TYPE
		,acqcode      tposcheque.ficode%TYPE
		,acqcountry   tposcheque.acqcountry%TYPE
		,retailer     treferenceretailer.ident%TYPE
		,retailercode treferenceretailer.code%TYPE
		,term         treferenceterminal.ident%TYPE
		,termcode     tposcheque.termcode%TYPE
		,termlocation tposcheque.termlocation%TYPE
		,mcc          tposcheque.siccode%TYPE
		,stan         tposcheque.stan%TYPE
		,acqiin       tposcheque.acquireriin%TYPE
		,forwardiin   tposcheque.forwardiin%TYPE
		,
		
		amount      tposcheque.value%TYPE
		,currency    tposcheque.currency%TYPE
		,orgamount   tposcheque.orgvalue%TYPE
		,orgcurrency tposcheque.orgcurrency%TYPE
		,
		
		trancode tposcheque.trancode%TYPE);

	TYPE typeissclientpacket IS RECORD(
		 packno        tisspackets.packetno%TYPE
		,packtype      tisspackets.packettype%TYPE
		,createdate    tisspackets.rxdate%TYPE
		,execdate      tisspackets.procdate%TYPE
		,totalcount    tisspackets.reccount%TYPE
		,execcount     tisspackets.recprocessed%TYPE
		,errorcount    tisspackets.errors%TYPE
		,remark        tisspackets.remark%TYPE
		,filename      tisspackets.filename%TYPE
		,branchpart    tisspackets.branchpart%TYPE
		,fileid        tisspackets.fileid%TYPE
		,createsysdate tisspackets.rxsysdate%TYPE
		,clerk         tisspackets.clerk%TYPE
		,errorrbcount  tisspackets.errorsrb%TYPE);

	TYPE typeissclientrecord IS RECORD(
		 packetno  NUMBER
		,recordno  NUMBER
		,recstatus NUMBER
		,
		
		fio           tissclient.fio%TYPE
		,lastname      tissclient.lastname%TYPE
		,firstname     tissclient.firstname%TYPE
		,middlename    tissclient.middlename%TYPE
		,sex           tissclient.sex%TYPE
		,birthday      tissclient.birthday%TYPE
		,address       tissclient.address%TYPE
		,phone         tissclient.phone%TYPE
		,company       tissclient.company%TYPE
		,office        tissclient.office%TYPE
		,tabno         tissclient.tabno%TYPE
		,latfio        tissclient.latfio%TYPE
		,latlastname   tissclient.latlastname%TYPE
		,latfirstname  tissclient.latfirstname%TYPE
		,latmiddlename tissclient.latmiddlename%TYPE
		,birthfio      tissclient.birthfio%TYPE
		,birthplace    tissclient.birthplace%TYPE
		,family        tissclient.family%TYPE
		,job           tissclient.job%TYPE
		,jobphone      tissclient.jobphone%TYPE
		,salary        tissclient.salary%TYPE
		,corraddress   tissclient.corraddress%TYPE
		,email         tissclient.email%TYPE
		,fax           tissclient.fax%TYPE
		,inn           tissclient.inn%TYPE
		,
		
		--persontype tissclient.persontype%TYPE
		--,ogrnip     tissclient.ogrnip%TYPE
		--,regdateip  tissclient.regdateip%TYPE
		--,statusofip tissclient.statusofip%TYPE
		
		resident      tissclient.resident%TYPE
		,resaddress    tissclient.resaddress%TYPE
		,education     tissclient.education%TYPE
		,startjobtime  tissclient.startjobtime%TYPE
		,startbanktime tissclient.startbanktime%TYPE
		,identityno    tissclient.identityno%TYPE
		,identitydate  tissclient.identitydate%TYPE
		,identityplace tissclient.identityplace%TYPE
		,insure        tissclient.insure%TYPE
		,pan           tissclient.pan%TYPE
		,mbr           tissclient.mbr%TYPE
		,orderdate     tissclient.orderdate%TYPE
		,canceldate    tissclient.canceldate%TYPE
		,account       tissclient.account%TYPE
		,extaccount    tissclient.extaccount%TYPE
		,secretquery   tissclient.secretquery%TYPE
		,secretanswer  tissclient.secretanswer%TYPE
		,makeprior     tissclient.makeprior%TYPE
		,contracttype  tissclient.contracttype%TYPE
		,cardprefix    tissclient.cardprefix%TYPE
		,countryres    tissclient.countryres%TYPE
		,contractno    tissclient.contractno%TYPE
		,finprofile    tissclient.finprofile%TYPE
		,errordetail   tissclient.errordetail%TYPE
		,cnsclischeme  tissclient.cnsclischeme%TYPE
		,cnsclichannel tissclient.cnsclichannel%TYPE
		,cnscliattr    tissclient.cnscliattr%TYPE
		,cnscardscheme tissclient.cnscardscheme%TYPE
		,
		
		cnscardchannel tissclient.cnscardchannel%TYPE
		,cnscardattr    tissclient.cnscardattr%TYPE
		,cmsprofile     tissclient.cmsprofile%TYPE
		,personalcode   tissclient.personalcode%TYPE
		,schparam       tissclient.schparam%TYPE
		,
		
		magnstrip  tisschangecard.magnstrip%TYPE
		,crd_stat   tisschangecard.crd_stat%TYPE
		,signstat   tisschangecard.signstat%TYPE
		,groupcmd   tisschangecard.groupcmd%TYPE
		,limitcmd   tisschangecard.limitcmd%TYPE
		,finprofcmd tisschangecard.finprofcmd%TYPE
		,
		
		reason          tissremakecard.reason%TYPE
		,nameoncard      tissclient.nameoncard%TYPE
		,currencyno      tisschangecard.currencyno%TYPE
		,zipcont         tissclient.zipcont%TYPE
		,countrycont     tissclient.countrycont%TYPE
		,regioncont      tissclient.regioncont%TYPE
		,citycont        tissclient.citycont%TYPE
		,zipreg          tissclient.zipreg%TYPE
		,countryreg      tissclient.countryreg%TYPE
		,regionreg       tissclient.regionreg%TYPE
		,cityreg         tissclient.cityreg%TYPE
		,ziplive         tissclient.ziplive%TYPE
		,countrylive     tissclient.countrylive%TYPE
		,regionlive      tissclient.regionlive%TYPE
		,citylive        tissclient.citylive%TYPE
		,acct_type       tissclient.acct_type%TYPE
		,acct_stat       tissclient.acct_stat%TYPE
		,accounttype     tissclient.accounttype%TYPE
		,overdraft       tissclient.overdraft%TYPE
		,lowremain       tissclient.lowremain%TYPE
		,cellphone       tissclient.cellphone%TYPE
		,pager           tissclient.pager%TYPE
		,identityexpdate tissclient.identityexpdate%TYPE
		,clientextid     tissclient.clientextid%TYPE
		,pinoffset       tissclient.pinoffset%TYPE
		,cvv             tissclient.cvv%TYPE
		,cvv2            tissclient.cvv2%TYPE
		,branchpart      tissclient.branchpart%TYPE
		,cmchangepan     tissremakecard.cmchangepan%TYPE
		,contractdate    tissclient.contractdate%TYPE
		,identitydep     tissclient.identitydep%TYPE
		,acct2cstat      tissclient.acct2cstat%TYPE
		,acct2crddesc    tissclient.acct2crddesc%TYPE
		,remain          tissclient.remain%TYPE
		,remark          tissclient.remark%TYPE
		,tbprefix        tissclient.tbprefix%TYPE
		,charalias       tissclient.charalias%TYPE
		,numalias        tissclient.numalias%TYPE
		,phonealias      tissclient.phonealias%TYPE
		,password        tissclient.password%TYPE
		,certific        tissclient.certific%TYPE
		,tbcode          tissclient.tbcode%TYPE
		,cnsid           tisschangecard.cnsid%TYPE
		,affiliate       tissclient.affiliate%TYPE
		,authtype        tissclient.authtype%TYPE
		,authlevel       tissclient.authlevel%TYPE
		,cmsactive       tissclient.cmsactive%TYPE
		,streetreg       tissclient.streetreg%TYPE
		,housereg        tissclient.housereg%TYPE
		,buildingreg     tissclient.buildingreg%TYPE
		,framereg        tissclient.framereg%TYPE
		,flatreg         tissclient.flatreg%TYPE
		,streetlive      tissclient.streetlive%TYPE
		,houselive       tissclient.houselive%TYPE
		,buildinglive    tissclient.buildinglive%TYPE
		,framelive       tissclient.framelive%TYPE
		,flatlive        tissclient.flatlive%TYPE
		,streetcont      tissclient.streetcont%TYPE
		,housecont       tissclient.housecont%TYPE
		,buildingcont    tissclient.buildingcont%TYPE
		,framecont       tissclient.framecont%TYPE
		,flatcont        tissclient.flatcont%TYPE
		,vip             tissclient.vip%TYPE
		,risklevel       tissclient.risklevel%TYPE
		,ledger          tissclient.ledger%TYPE
		,subledger       tissclient.subledger%TYPE
		,notactual       tissclient.notactual%TYPE
		,planname        tissclient.planname%TYPE
		,cmsaccount      tissclient.cmsaccount%TYPE
		,title           tissclient.title%TYPE
		,userdata        tissclient.userdata%TYPE
		,idcnscard       tisschangecard.idcnscard%TYPE
		,idclient        tissclient.idclient%TYPE
		,cmsdisabled     tissclient.cmsdisabled%TYPE
		,remakepan       tissremakecard.remakepan%TYPE
		,remakembr       tissremakecard.remakembr%TYPE
		,prevjob         tissclient.prevjob%TYPE
		,blockreissue    tisschangecard.blockreissue%TYPE
		,cmsdynauth      tissclient.cmsdynauth%TYPE
		,cmsdefdyna      tissclient.cmsdefdyna%TYPE
		,stlang          tissclient.stlang%TYPE
		,occupation      tissclient.occupation%TYPE
		,VALUE           tissclient.value%TYPE
		,ipvv            tissclient.ipvv%TYPE
		,finprofileext   tissclient.finprofileext%TYPE
		,ecstatus        tissclient.ecstatus%TYPE
		,cardprodid      tissclient.cardproductid%TYPE
		,cmsbroadcast    tissclient.cmsbrct%TYPE
		,externalid      tissclient.externalid%TYPE
		,accfinprof      tissclient.accfinprof%TYPE
		,contrfinprof    tissclient.contrfinprof%TYPE
		,cov_action      tissclient.cov_action%TYPE
		,cov_no          tissclient.cov_no%TYPE
		,cov_part        tissclient.cov_part%TYPE
		,cov_type        tissclient.cov_type%TYPE
		,cov_amount      tissclient.cov_amount%TYPE
		,cov_quality     tissclient.cov_quality%TYPE
		,
		
		cov_date          tissclient.cov_date%TYPE
		,cov_number        tissclient.cov_number%TYPE
		,cov_clientid      tissclient.cov_clientid%TYPE
		,cov_accountno     tissclient.cov_accountno%TYPE
		,cov_rollback      tissclient.cov_rollback%TYPE
		,cov_salemonths    tissclient.cov_salemonths%TYPE
		,cov_saledays      tissclient.cov_saledays%TYPE
		,cov_saledate      tissclient.cov_saledate%TYPE
		,cov_discountedval tissclient.cov_discountedval%TYPE
		,cardprodident     tissclient.cardprodident%TYPE
		,
		
		isallowedcst tissclient.isallowedcst%TYPE
		,isallowedads tissclient.isallowedads%TYPE
		,isallowedtbu tissclient.isallowedtbu%TYPE
		,
		
		newcontractno tissclient.newcontractno%TYPE
		,movehold      tissclient.movehold%TYPE
		,exchrate      tissclient.exchrate%TYPE
		,moverate      tissclient.moverate%TYPE
		,mainpan       tissclient.mainpan%TYPE
		,mainmbr       tissclient.mainmbr%TYPE
		,supplementary tissclient.supplementary%TYPE
		,lcardextid    tissclient.lcardextid%TYPE
		--,contactless   tissclient.contactlesscapable%TYPE
		);
	TYPE typeissclientlist IS TABLE OF typeissclientrecord INDEX BY BINARY_INTEGER;

	TYPE typeissclientrecordacc IS RECORD(
		 accountno    tisscontaccount.accountno%TYPE
		,extaccountno tisscontaccount.extaccountno%TYPE
		,accounttype  tisscontaccount.acctype%TYPE
		,acct_type    tisscontaccount.accstatbo%TYPE
		,acct_stat    tisscontaccount.accstatfo%TYPE
		,stat         tisscontaccount.acc2crdstat%TYPE
		,a2cdesc      tisscontaccount.a2cdesc%TYPE
		,accindex     tisscontaccount.accindex%TYPE
		,accitemname  tisscontaccount.accitemname%TYPE);
	TYPE typeissclientrecordacclist IS TABLE OF typeissclientrecordacc INDEX BY BINARY_INTEGER;

	TYPE typeinpackrecord IS RECORD(
		 packno         tinpack.packno%TYPE
		,packtype       tinpack.packtype%TYPE
		,operdate       tinpack.operdate%TYPE
		,companyaccount tinpack.companyaccount%TYPE
		,countrec       tinpack.countrec%TYPE
		,countexecrec   tinpack.countexecrec%TYPE
		,counterrorrec  tinpack.counterrorrec%TYPE
		,allsum         tinpack.allsum%TYPE
		,execsum        tinpack.execsum%TYPE
		,lastrecno      tinpack.lastrecno%TYPE
		,note           tinpack.note%TYPE
		,packinfo       tinpack.packinfo%TYPE
		,remark         tinpack.remark%TYPE
		,filename       tinpack.filename%TYPE
		,createsysdate  tinpack.createsysdate%TYPE
		,createclerk    tinpack.createclerk%TYPE
		,updatedate     tinpack.updatedate%TYPE
		,updatesysdate  tinpack.updatesysdate%TYPE
		,updateclerk    tinpack.updateclerk%TYPE
		,branchpart     tinpack.branchpart%TYPE);

	TYPE typeinpackdatarecord IS RECORD(
		 packno        tinrecord.packno%TYPE
		,recno         tinrecord.recno%TYPE
		,accountno     tinrecord.accountno%TYPE
		,extaccount    tinrecord.extaccount%TYPE
		,contractno    tinrecord.contractno%TYPE
		,pan           tinrecord.pan%TYPE
		,mbr           tinrecord.mbr%TYPE
		,accountcrd    tinrecord.accountcrd%TYPE
		,accountcor    tinrecord.accountcor%TYPE
		,shortremark   tinrecord.shortremark%TYPE
		,fullremark    tinrecord.fullremark%TYPE
		,VALUE         tinrecord.value%TYPE
		,currency      tinrecord.currency%TYPE
		,currencyto    tinrecord.currencyto%TYPE
		,fio           tinrecord.fio%TYPE
		,docclient     tinrecord.docclient%TYPE
		,company       tinrecord.company%TYPE
		,office        tinrecord.office%TYPE
		,tabno         tinrecord.tabno%TYPE
		,docno         tinrecord.docno%TYPE
		,errorcode     tinrecord.errorcode%TYPE
		,rollbackdata  tinrecord.rollbackdata%TYPE
		,userdata      tinrecord.userdata%TYPE
		,execdate      tinrecord.execdate%TYPE
		,extaccountcor tinrecord.extaccountcor%TYPE
		,valuedate     tinrecord.valuedate%TYPE
		,guidenf       RAW(16));
	TYPE typeinpackdatarecordlist IS TABLE OF typeinpackdatarecord INDEX BY BINARY_INTEGER;

	TYPE typeplanaccountrecord IS RECORD(
		 consolidated tplanaccount.consolidated%TYPE
		,ledger       tplanaccount.ledger%TYPE
		,subledger    tplanaccount.subledger%TYPE
		,internal     tplanaccount.internal%TYPE
		,EXTERNAL     tplanaccount.external%TYPE
		,NAME         tplanaccount.name%TYPE
		,currency     tplanaccount.currencyno%TYPE
		,sign         tplanaccount.sign%TYPE
		,remark       tplanaccount.remark%TYPE
		,
		
		nonactualbalance BOOLEAN
		
		);

	TYPE typesecurnode IS RECORD(
		 id         NUMBER
		,parentid   NUMBER
		,LEVEL      NUMBER
		,key        VARCHAR(255)
		,text       VARCHAR(250)
		,subnodes   NUMBER
		,substart   NUMBER
		,state      NUMBER
		,nullable   BOOLEAN := FALSE
		,isfunction BOOLEAN := FALSE
		,objectid   NUMBER);
	TYPE typesecurnodetree IS TABLE OF typesecurnode INDEX BY BINARY_INTEGER;

	TYPE typesecuruserinfo IS RECORD(
		 code     tclerk.code%TYPE
		,clerkid  tclerk.clerkid%TYPE
		,NAME     tclerk.name%TYPE
		,usertype tclerk.type%TYPE);
	TYPE typesecuruserinfolist IS TABLE OF typesecuruserinfo INDEX BY BINARY_INTEGER;

	TYPE typesecurgroupinfo IS RECORD(
		 id     tclerkgroup.id%TYPE
		,NAME   tclerkgroup.name%TYPE
		,remark tclerkgroup.remark%TYPE);
	TYPE typesecurgroupinfolist IS TABLE OF typesecurgroupinfo INDEX BY BINARY_INTEGER;

	TYPE typesecurobjectinfo IS RECORD(
		 id          taccessobjects.id%TYPE
		,NAME        taccessobjects.name%TYPE
		,description taccessobjects.description%TYPE
		,packagename taccessobjects.packagename%TYPE);
	TYPE typesecurobjectinfolist IS TABLE OF typesecurobjectinfo INDEX BY BINARY_INTEGER;

	TYPE typesecurrightinfo IS RECORD(
		 userid    trights.userid%TYPE
		,usertype  trights.usertype%TYPE
		,objectid  trights.objectid%TYPE
		,accesskey trights.accesskey%TYPE);
	TYPE typesecurrightinfolist IS TABLE OF typesecurrightinfo INDEX BY BINARY_INTEGER;

	TYPE typeretailerrecord IS RECORD(
		 code             treferenceretailer.code%TYPE
		,ficode           treferenceretailer.ficode%TYPE
		,ident            treferenceretailer.ident%TYPE
		,NAME             treferenceretailer.name%TYPE
		,external_name    treferenceretailer.external_name%TYPE
		,external_city    treferenceretailer.external_city%TYPE
		,external_country treferenceretailer.external_country%TYPE
		,external_zipcode treferenceretailer.external_zipcode%TYPE
		,external_siccode treferenceretailer.external_siccode%TYPE
		,country          treferenceretailer.country%TYPE
		,city             treferenceretailer.city%TYPE
		,address          treferenceretailer.address%TYPE
		,phones           treferenceretailer.phones%TYPE
		,fax              treferenceretailer.fax%TYPE
		,email            treferenceretailer.email%TYPE
		,postalcode       treferenceretailer.postalcode%TYPE
		,country_code     treferenceretailer.country_code%TYPE
		,region_code      treferenceretailer.region_code%TYPE
		,city_code        treferenceretailer.city_code%TYPE
		,idclient         treferenceretailer.code_client%TYPE
		,note             treferenceretailer.note%TYPE
		,profile          treferenceretailer.profile%TYPE
		,branchpart       treferenceretailer.branchpart%TYPE
		,createdate       treferenceretailer.createdate%TYPE
		,createclerk      treferenceretailer.createclerk%TYPE
		,updatedate       treferenceretailer.updatedate%TYPE
		,updateclerk      treferenceretailer.updateclerk%TYPE
		,street           treferenceretailer.street%TYPE
		,house            treferenceretailer.house%TYPE
		,building         treferenceretailer.building%TYPE
		,frame            treferenceretailer.frame%TYPE
		,flat             treferenceretailer.flat%TYPE
		,isprototype      treferenceretailer.isprototype%TYPE
		,prototype        treferenceretailer.prototype%TYPE
		,inactive         treferenceretailer.inactive%TYPE
		,location         treferenceretailer.location%TYPE
		,merchantid       treferenceretailer.merchantid%TYPE
		,guid             types.guid
		,parentinactive   treferenceretailer.parentinactive%TYPE
		,external_ident   treferenceretailer.external_ident%TYPE
		,parentcode       treferenceretailer.parentcode%TYPE
		,limitgrp         treferenceretailer.limitgrp%TYPE
		,limitcurrency    treferenceretailer.limitcurrency%TYPE
		,reimbursement    treferenceretailer.reimbursement%TYPE
		,anyposrefund     treferenceretailer.anyposrefund%TYPE
		,limitgrpfo       treferenceretailer.limitgrpfo%TYPE);
	TYPE typeretailerlist IS TABLE OF typeretailerrecord INDEX BY BINARY_INTEGER;

	TYPE typeretailerextvaluelist IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

	TYPE typeretailerextattribute IS RECORD(
		 networkid NUMBER
		,fieldtype NUMBER
		,VALUE     VARCHAR2(100));
	TYPE typeretailerextattributelist IS TABLE OF typeretailerextattribute INDEX BY BINARY_INTEGER;

	TYPE typeretailercontact IS RECORD(
		 no       treferenceretailercontacts.orderno%TYPE
		,idclient treferenceretailercontacts.clientidlink%TYPE
		,fio      treferenceretailercontacts.fio%TYPE
		,jobtitle treferenceretailercontacts.post%TYPE
		,info     treferenceretailercontacts.note%TYPE);

	TYPE typeretailercontactlist IS TABLE OF typeretailercontact INDEX BY BINARY_INTEGER;

	TYPE typevendorgrouprecord IS RECORD(
		 groupcode   tvendorgroup.groupcode%TYPE
		,groupid     tvendorgroup.groupid%TYPE
		,description tvendorgroup.description%TYPE);

	TYPE typevendorgrouplist IS TABLE OF typevendorgrouprecord INDEX BY BINARY_INTEGER;

	TYPE typedisputerecord IS RECORD(
		 internalcode      tdispmandispute.internalcode%TYPE
		,startdate         tdispmandispute.startdate%TYPE
		,startoperatorcode tdispmandispute.startoperatorcode%TYPE
		,startoperatorname tdispmandispute.startoperatorname%TYPE
		,reasontext        tdispmandispute.reasontext%TYPE
		,prioritylevel     tdispmandispute.prioritylevel%TYPE
		,risklevel         tdispmandispute.risklevel%TYPE
		,state             tdispmandispute.state%TYPE
		,criticaldate      tdispmandispute.datecritical%TYPE
		,paymentsystem     tdispmandispute.paymentsystem%TYPE
		,modulecode        tdispmandispute.modulecode%TYPE
		,stopdate          tdispmandispute.stopdate%TYPE
		,stopoperatorcode  tdispmandispute.stopoperatorcode%TYPE
		,stopoperatorname  tdispmandispute.stopoperatorname%TYPE
		,closereason       tdispmandispute.closereason%TYPE);

	TYPE typedisputelist IS TABLE OF typedisputerecord INDEX BY BINARY_INTEGER;

	TYPE typedisputeeventrecord IS RECORD(
		 internalcode tdispmanevent.internalcode%TYPE
		,disputecode  tdispmanevent.disputecode%TYPE
		,eventtype    tdispmanevent.eventtype%TYPE
		,originalcode tdispmanevent.originalcode%TYPE
		,creationdate tdispmanevent.creationdate%TYPE
		,operatorcode tdispmanevent.operatorcode%TYPE
		,operatorname tdispmanevent.operatorname%TYPE
		,commenttext  tdispmanevent.commenttext%TYPE);

	TYPE typedisputeeventlist IS TABLE OF typedisputeeventrecord INDEX BY BINARY_INTEGER;

	TYPE typecardtaskimportrecord IS RECORD(
		 recno            tcardtaskimportrec.recno%TYPE
		,pan              tcardtaskimportrec.pan%TYPE
		,mbr              tcardtaskimportrec.mbr%TYPE
		,pinoffset        tcardtaskimportrec.pinoffset%TYPE
		,crd_stat         tcardtaskimportrec.crd_stat%TYPE
		,signstat         tcardtaskimportrec.signstat%TYPE
		,cvv              tcardtaskimportrec.cvv%TYPE
		,cvv2             tcardtaskimportrec.cvv2%TYPE
		,makeprior        tcardtaskimportrec.makeprior%TYPE
		,insure           tcardtaskimportrec.insure%TYPE
		,insuredate       tcardtaskimportrec.insuredate%TYPE
		,remark           tcardtaskimportrec.remark%TYPE
		,pinblock         tcardtaskimportrec.pinblock%TYPE
		,makingdate       tcardtaskimportrec.makingdate%TYPE
		,distributiondate tcardtaskimportrec.distributiondate%TYPE
		,closedate        tcardtaskimportrec.closedate%TYPE
		,ipvv             tcardtaskimportrec.ipvv%TYPE);

	TYPE typeclientcnsrecord IS RECORD(
		 idcns          tclientcnsobj.idcns%TYPE
		,idclient       tclientcnsobj.idclient%TYPE
		,profile        tclientcnsobj.cnsprofile%TYPE
		,scheme         tclientcnsobj.scheme%TYPE
		,status         tclientcnsobj.status%TYPE
		,startdate      tclientcnsobj.startdate%TYPE
		,expdate        tclientcnsobj.expdate%TYPE
		,createclerk    tclientcnsobj.createclerk%TYPE
		,createsysdate  tclientcnsobj.createsysdate%TYPE
		,updateclerk    tclientcnsobj.updateclerk%TYPE
		,updatesysdate  tclientcnsobj.updatesysdate%TYPE
		,accountno      tclientcnsobj.accountno%TYPE
		,updaterevision tclientcnsobj.updaterevision%TYPE
		,branchpart     tclientcnsobj.branchpart%TYPE
		,extidcns       tclientcnsobj.extidcns%TYPE);

	TYPE typeclientcnslist IS TABLE OF typeclientcnsrecord INDEX BY BINARY_INTEGER;

	TYPE typecardcnsrecord IS RECORD(
		 idcns           tcardcns.idcns%TYPE
		,idcnscard       tcardcns.idcnscard%TYPE
		,idclient        tclientcnsobj.idclient%TYPE
		,pan             tcardcns.pan%TYPE
		,mbr             tcardcns.mbr%TYPE
		,channel         tcardcns.channel%TYPE
		,address         tcardcns.address%TYPE
		,NAME            tcardcns.name%TYPE
		,title           tcardcns.title%TYPE
		,fio             tclientpersone.fio%TYPE
		,disabled        tcardcns.disabled%TYPE
		,parentidcnscard tcardcns.parentidcnscard%TYPE
		,createdate      tcardcns.createdate%TYPE
		,usefordynauth   tcardcns.usefordynauth%TYPE
		,isdefault       tcardcns.isdefault%TYPE
		,broadcast       tcardcns.broadcast%TYPE
		,useforextauth   tcustomercns.useforextauth%TYPE
		,extrainfo       tcustomercns.extrainfo%TYPE);

	TYPE typecardcnslist IS TABLE OF typecardcnsrecord INDEX BY BINARY_INTEGER;

	TYPE typecustomercnsrecord IS RECORD(
		 idcns         tcustomercns.idcns%TYPE
		,idcnscustomer tcustomercns.idcnscustomer%TYPE
		,idclient      tclientcnsobj.idclient%TYPE
		,customer      tcustomercns.customer%TYPE
		,channel       tcustomercns.channel%TYPE
		,address       tcustomercns.address%TYPE
		,NAME          tcustomercns.name%TYPE
		,title         tcustomercns.title%TYPE
		,fio           tclientpersone.fio%TYPE
		,disabled      tcustomercns.disabled%TYPE
		,usefordynauth tcustomercns.usefordynauth%TYPE
		,isdefault     tcustomercns.isdefault%TYPE
		,broadcast     tcustomercns.broadcast%TYPE
		,useforextauth tcustomercns.useforextauth%TYPE
		,extrainfo     tcustomercns.extrainfo%TYPE);

	TYPE typecustomercnslist IS TABLE OF typecustomercnsrecord INDEX BY BINARY_INTEGER;

	TYPE typeclientincnsrecord IS RECORD(
		 idcns         tclientcns.idcns%TYPE
		,idcnsclient   tclientcns.idcnsclient%TYPE
		,idclient      tclientcns.clientid%TYPE
		,channel       tclientcns.channel%TYPE
		,address       tclientcns.address%TYPE
		,NAME          tclientcns.name%TYPE
		,title         tclientcns.title%TYPE
		,fio           tclientpersone.fio%TYPE
		,disabled      tclientcns.disabled%TYPE
		,usefordynauth tclientcns.usefordynauth%TYPE
		,isdefault     tclientcns.isdefault%TYPE
		,broadcast     tclientcns.broadcast%TYPE
		,useforextauth tcustomercns.useforextauth%TYPE
		,extrainfo     tcustomercns.extrainfo%TYPE);

	TYPE typeclientincnslist IS TABLE OF typeclientincnsrecord INDEX BY BINARY_INTEGER;

	TYPE typeretailercnsrecord IS RECORD(
		 idcns         tretailercns.idcns%TYPE
		,idcnsretailer tretailercns.idcnsretailer%TYPE
		,idclient      tclientcnsobj.idclient%TYPE
		,retailer      tretailercns.retailer%TYPE
		,channel       tretailercns.channel%TYPE
		,address       tretailercns.address%TYPE
		,NAME          tclientbank.name%TYPE
		,disabled      tretailercns.disabled%TYPE);

	TYPE typeretailercnslist IS TABLE OF typeretailercnsrecord INDEX BY BINARY_INTEGER;

	TYPE typecnsrefchannelrecord IS RECORD(
		 code        tcnsrefchannel.code%TYPE
		,id          tcnsrefchannel.id%TYPE
		,description tcnsrefchannel.description%TYPE);
	TYPE typecnsrefchannellist IS TABLE OF typecnsrefchannelrecord INDEX BY BINARY_INTEGER;

	TYPE typecnsrefschemarecord IS RECORD(
		 code        tcnsrefschema.code%TYPE
		,id          tcnsrefschema.id%TYPE
		,description tcnsrefschema.description%TYPE
		,profile     tcnsrefschema.profile%TYPE);
	TYPE typecnsrefschemalist IS TABLE OF typecnsrefschemarecord INDEX BY BINARY_INTEGER;

	TYPE typecnsschemaelementrecord IS RECORD(
		 code        tcnsrefschemaelement.code%TYPE
		,id          tcnsrefschemaelement.id%TYPE
		,description tcnsrefschemaelement.description%TYPE
		,schemacode  tcnsrefschemaelement.schemacode%TYPE);
	TYPE typecnsschemaelementlist IS TABLE OF typecnsschemaelementrecord INDEX BY BINARY_INTEGER;

	TYPE typeclientaskrecord IS RECORD(
		 what  tclientask.what%TYPE
		,VALUE tclientask.value%TYPE
		,
		
		isallowedcst      tclientask.isallowedcst%TYPE
		,isallowedads      tclientask.isallowedads%TYPE
		,isallowedtelebank tclientask.isallowedtelebank%TYPE
		
		);

	TYPE typeclientasklist IS TABLE OF typeclientaskrecord INDEX BY BINARY_INTEGER;

	TYPE typetransinforecord IS RECORD(
		 trantime DATE
		,amount   NUMBER);

	TYPE typetransinfolist IS TABLE OF typetransinforecord INDEX BY BINARY_INTEGER;

	TYPE typememo IS RECORD(
		 id          NUMBER
		,typeobject  NUMBER
		,keyobject   VARCHAR(40)
		,text        VARCHAR(1000)
		,template    VARCHAR(100)
		,createdate  DATE
		,createclerk NUMBER
		,updatedate  DATE
		,updateclerk NUMBER
		,operdate    DATE
		,station     NUMBER
		,sessionid   NUMBER
		,idclient    NUMBER);

	TYPE typememolist IS TABLE OF typememo INDEX BY BINARY_INTEGER;

	SUBTYPE typememorecord IS typememo;

	TYPE typeuserprop IS RECORD(
		 id        VARCHAR(64)
		,fieldtype types.typevalue
		,valuestr  VARCHAR(4000)
		,valuenum  NUMBER
		,valuedate DATE
		,valuexml  xmltype
		,valuetext VARCHAR(4000)
		,ptype     VARCHAR(16));
	SUBTYPE typeuserproprecord IS typeuserprop;

	TYPE typeuserproplist IS TABLE OF typeuserprop INDEX BY BINARY_INTEGER;

	SUBTYPE typeclientaddproprecord IS typeuserprop;
	SUBTYPE typeclientaddproplist IS typeuserproplist;

	TYPE typeloyaltyprogram IS RECORD(
		 code                  tloyaltyprg.code%TYPE
		,NAME                  tloyaltyprg.name%TYPE
		,TYPE                  tloyaltyprg.type%TYPE
		,active                tloyaltyprg.active%TYPE
		,bonuscurrencyno       tloyaltyprg.bonuscurrencyno%TYPE
		,bonusaccountno        tloyaltyprg.bonusaccountno%TYPE
		,calccurrencyno        tloyaltyprg.calccurrencyno%TYPE
		,calcexchangerate      tloyaltyprg.calcexchangerate%TYPE
		,calcaccountno         tloyaltyprg.calcaccountno%TYPE
		,retailer              tloyaltyprg.retailer%TYPE
		,periodfrom            tloyaltyprg.periodfrom%TYPE
		,periodto              tloyaltyprg.periodto%TYPE
		,maxamount             tloyaltyprg.maxamount%TYPE
		,bonusliveperiod       tloyaltyprg.bonusliveperiod%TYPE
		,liveperiodcalendar    tloyaltyprg.liveperiodcalendar%TYPE
		,doclearing            tloyaltyprg.doclearing%TYPE
		,ident                 tloyaltyprg.ident%TYPE
		,checkbalance          tloyaltyprg.checkbalance%TYPE
		,prggroup              tloyaltyprg.prggroup%TYPE
		,gracedays             tloyaltyprg.gracedays%TYPE
		,gracefreeze           tloyaltyprg.gracefreeze%TYPE
		,gracemaxrenew         tloyaltyprg.gracemaxrenew%TYPE
		,expiretype            tloyaltyprg.expiretype%TYPE
		,expiredate            tloyaltyprg.expiredate%TYPE
		,expireperiod          tloyaltyprg.expireperiod%TYPE
		,expireiscalendar      tloyaltyprg.expireiscalendar%TYPE
		,expiresql             NUMBER
		,revburned             NUMBER
		,revnotburned          NUMBER
		,revexpiretype         tloyaltyprg.revexpiretype%TYPE
		,revexpiredate         tloyaltyprg.revexpiredate%TYPE
		,revexpireperiod       tloyaltyprg.revexpireperiod%TYPE
		,revexpireiscalendar   tloyaltyprg.revexpireiscalendar%TYPE
		,revexpiresql          NUMBER
		,revgracedays          NUMBER
		,revgracefreeze        NUMBER
		,revgracemaxrenew      NUMBER
		,revbonusliveperiod    NUMBER
		,revliveperiodcalendar NUMBER
		,objectuid             tloyaltyprg.objectuid%TYPE
		,usecalcaccforpaym     NUMBER
		,calcperiod            NUMBER
		
		);
	TYPE typeloyaltyprogramarray IS TABLE OF typeloyaltyprogram INDEX BY BINARY_INTEGER;

	TYPE typeextbonusrecord IS RECORD(
		 no         NUMBER
		,prgid      tloyaltyextbon.prgid%TYPE
		,prgname    tloyaltyextbon.prgname%TYPE
		,condid     tloyaltyextbon.condid%TYPE
		,condname   tloyaltyextbon.condname%TYPE
		,condtype   NUMBER
		,amount     NUMBER
		,currency   NUMBER
		,origdocno  NUMBER
		,userdata   tloyaltyextbon.userdata%TYPE
		,expirydate DATE);

	TYPE typebonusrecord IS RECORD(
		 amount      NUMBER
		,daccountno  taccount.accountno%TYPE
		,caccountno  taccount.accountno%TYPE
		,currency    treferencecurrency.currency%TYPE
		,entry       treferenceentry.code%TYPE
		,shortremark tentry.shortremark%TYPE
		,fullremark  tentry.fullremark%TYPE
		,extrecord   typeextbonusrecord
		,tranchedate DATE);
	TYPE typebonusrecordarray IS TABLE OF typebonusrecord INDEX BY BINARY_INTEGER;

	TYPE typeloyaltyinforecord IS RECORD(
		 amount     NUMBER
		,contractno tcontract.no%TYPE);

	TYPE typetelebankrecord IS RECORD(
		 customer         tcustomer.customer%TYPE
		,charalias        tcustomer.charalias%TYPE
		,numberalias      tcustomer.numberalias%TYPE
		,idclient         tcustomer.idclient%TYPE
		,stat             tcustomer.stat%TYPE
		,createdate       tcustomer.createdate%TYPE
		,createclerkcode  tcustomer.createclerkcode%TYPE
		,updatedate       tcustomer.updatedate%TYPE
		,updateclerkcode  tcustomer.updateclerkcode%TYPE
		,updatesysdate    tcustomer.updatesysdate%TYPE
		,accountno        tcustomer.accountno%TYPE
		,pinoffset        tcustomer.pinoffset%TYPE
		,remark           tcustomer.remark%TYPE
		,limitcurrency    tcustomer.limitcurrency%TYPE
		,password         tcustomer.password%TYPE
		,expdate          tcustomer.expdate%TYPE
		,statementopcount tcustomer.statementopcount%TYPE
		,closeoperdate    tcustomer.closeoperdate%TYPE
		,createoperdate   tcustomer.createoperdate%TYPE
		,sign             tcustomer.sign%TYPE
		,branchpart       tcustomer.branchpart%TYPE
		,profile          tcustomer.profile%TYPE
		,extauthmode      tcustomer.extauthmode%TYPE
		,extauthlevel     tcustomer.extauthlevel%TYPE
		,certificate      tcustomer.certificate%TYPE
		,telebankproduct  treferencecustomer.code%TYPE
		,limitgrpid       tcustomer.limitgrpid%TYPE
		,activationdate   tcustomer.activationdate%TYPE
		,externalid       tcustomer.externalid%TYPE
		,phonealias       tcustomer.phonealias%TYPE);
	TYPE typetelebanklist IS TABLE OF typetelebankrecord INDEX BY BINARY_INTEGER;

	TYPE typetelebankcardrecord IS RECORD(
		 customer  tcard2customer.customer%TYPE
		,pan       tcard2customer.pan%TYPE
		,mbr       tcard2customer.mbr%TYPE
		,descr     tcard2customer.descr%TYPE
		,cardextid tcard.externalid%TYPE);
	TYPE typetelebankcardlist IS TABLE OF typetelebankcardrecord INDEX BY BINARY_INTEGER;

	TYPE typetelebankaccountrecord IS RECORD(
		 customer  tcard2customer.customer%TYPE
		,accountno tacc2customer.accountno%TYPE
		,acctstat  tacc2customer.acct_stat%TYPE
		,descr     tacc2customer.acctdescr%TYPE);
	TYPE typetelebankaccountlist IS TABLE OF typetelebankaccountrecord INDEX BY BINARY_INTEGER;

	TYPE typetelebankemailrecord IS RECORD(
		 email tcustomerauthemail.email%TYPE
		,alias tcustomerauthemail.aliase%TYPE);
	TYPE typetelebankemaillist IS TABLE OF typetelebankemailrecord INDEX BY BINARY_INTEGER;

	TYPE typetelebankphonerecord IS RECORD(
		 phone tcustomerauthphone.phone%TYPE
		,alias tcustomerauthphone.aliase%TYPE);
	TYPE typetelebankphonelist IS TABLE OF typetelebankphonerecord INDEX BY BINARY_INTEGER;

	TYPE typetelebankauthcardrecord IS RECORD(
		 pan       tauthcustomerbycard.pan%TYPE
		,mbr       tauthcustomerbycard.mbr%TYPE
		,cardextid tcard.externalid%TYPE);
	TYPE typetelebankauthcardlist IS TABLE OF typetelebankauthcardrecord INDEX BY BINARY_INTEGER;

	TYPE typeeventsrecord IS RECORD(
		 code         tevent.code%TYPE
		,key          tevent.key%TYPE
		,keydate      tevent.keydate%TYPE
		,data         tevent.data%TYPE
		,packno       tevent.packno%TYPE
		,no           tevent.no%TYPE
		,error        tevent.error%TYPE
		,warning      tevent.warning%TYPE
		,rollbackdata tevent.rollbackdata%TYPE
		,createdate   tevent.createdate%TYPE);
	TYPE typeeventsrecordlist IS TABLE OF typeeventsrecord INDEX BY BINARY_INTEGER;

	TYPE typeterminalaccrecord IS RECORD(
		 currency     taccgroup.currency%TYPE
		,account      taccgroup.account%TYPE
		,accountgroup trefaccgrouptype.ident%TYPE);
	TYPE typeterminalacclist IS TABLE OF typeterminalaccrecord INDEX BY BINARY_INTEGER;

	TYPE typeretaileraccrecord IS RECORD(
		 account      taccgroup.account%TYPE
		,currency     taccgroup.currency%TYPE
		,accountgroup trefaccgrouptype.ident%TYPE);
	TYPE typeretaileracclist IS TABLE OF typeretaileraccrecord INDEX BY BINARY_INTEGER;

	TYPE typestatemententryrecord IS RECORD(
		 docno           tstatementdetail.docno%TYPE
		,entno           tstatementdetail.entno%TYPE
		,device          VARCHAR2(1)
		,trentcode       tatmext.entcode%TYPE
		,enttype         VARCHAR2(4)
		,entcode         treferenceentry.code%TYPE
		,trancode        tatmext.trancode%TYPE
		,account         tstatementdetail.account%TYPE
		,backaccount     tstatementdetail.backaccount%TYPE
		,pan             tstatementdetail.pan%TYPE
		,mbr             tstatementdetail.mbr%TYPE
		,operdate        tstatementdetail.operdate%TYPE
		,valuedate       tstatementdetail.trandate%TYPE
		,VALUE           tstatementdetail.value%TYPE
		,currency        VARCHAR2(10)
		,currentabb      tstatementdetail.currentabb%TYPE
		,orgvalue        tstatementdetail.orgvalue%TYPE
		,orgcurrency     VARCHAR2(10)
		,orgcurrentabb   tstatementdetail.orgcurrentabb%TYPE
		,siccode         tstatementdetail.sic%TYPE
		,mccname         tstatementdetail.mccname%TYPE
		,termlocation    VARCHAR2(1000)
		,termname        VARCHAR2(1000)
		,termcountry     PLS_INTEGER
		,termcity        VARCHAR2(90)
		,approval        tstatementdetail.approval%TYPE
		,shortremark     tentry.shortremark%TYPE
		,fullremark      tstatementdetail.fullremark%TYPE
		,operdetail      tstatementdetail.operdetail%TYPE
		,descriptor      VARCHAR2(1000)
		,retailername    tstatementdetail.retailer%TYPE
		,serialno        tstatementdetail.serialno%TYPE
		,bookno          tstatementdetail.bookno%TYPE
		,drawdate        tstatementdetail.drawdate%TYPE
		,inputdate       tstatementdetail.inputdate%TYPE
		,customername    tstatementdetail.customername%TYPE
		,acctimpactlist  tstatementdetail.acctimpactlist%TYPE
		,remain          NUMBER
		,extpsdata       VARCHAR2(4000)
		,messtorecipient VARCHAR2(750)
		,protectedamount NUMBER
		,bai             VARCHAR2(2));
	TYPE typestatemententrylist IS TABLE OF typestatemententryrecord INDEX BY BINARY_INTEGER;

	TYPE typeapplicationrecord IS RECORD(
		 applicationcode tapplication.code%TYPE
		,applicationno   tapplication.applicationno%TYPE
		,applicationtype tapplication.applicationtype%TYPE
		,idclient        tapplication.idclient%TYPE
		,statuscode      tapplication.statuscode%TYPE
		,declinedcode    tapplication.declinedcode%TYPE
		,text            tapplication.text%TYPE
		,createdate      tapplication.createdate%TYPE
		,createclerk     tapplication.createclerk%TYPE
		,updatedate      tapplication.updatedate%TYPE
		,updateclerk     tapplication.updateclerk%TYPE
		,branchpart      tapplication.branchpart%TYPE
		,createsysdate   tapplication.createsysdate%TYPE
		,updatesysdate   tapplication.updatesysdate%TYPE
		,guid            types.guid);
	TYPE typeapplicationlist IS TABLE OF typeapplicationrecord INDEX BY BINARY_INTEGER;

	TYPE typeapplicationobjectlnkrecord IS RECORD(
		 applicationno  tapplication.applicationno%TYPE
		,objectlinkcode treferenceapplobjectlink.code%TYPE);
	TYPE typeapplicationobjectlnklist IS TABLE OF typeapplicationobjectlnkrecord INDEX BY BINARY_INTEGER;

	TYPE typecontactrecord IS RECORD(
		 contacttype tclientcontactdata.contacttype%TYPE
		,contactdata tclientcontactdata.contactdata%TYPE);
	TYPE typecontactlist IS TABLE OF typecontactrecord INDEX BY BINARY_INTEGER;

	TYPE typefinstaterecord IS RECORD(
		 code tfinstateclient.code%TYPE);
	TYPE typefinstatelist IS TABLE OF typefinstaterecord INDEX BY BINARY_INTEGER;

	TYPE typecompanyofficerecord IS RECORD(
		 code tcompanyoffice.code%TYPE
		,NAME tcompanyoffice.name%TYPE);
	TYPE typecompanyofficelist IS TABLE OF typecompanyofficerecord INDEX BY BINARY_INTEGER;

	TYPE typeclientrecord IS RECORD(
		 idclient      tclient.idclient%TYPE
		,TYPE          tclient.type%TYPE
		,updatesysdate tclient.updatesysdate%TYPE
		,branchpart    tclient.branchpart%TYPE);
	TYPE typeclientlist IS TABLE OF typeclientrecord INDEX BY BINARY_INTEGER;

	TYPE typewarrantoperrecord IS RECORD(
		 opercode twarrantoperation.opercode%TYPE
		,NAME     treferencewarrantoperation.name%TYPE);
	TYPE typewarrantoperlist IS TABLE OF typewarrantoperrecord INDEX BY BINARY_INTEGER;

	TYPE typefindocumentrecord IS RECORD(
		 docno       tdocument.docno%TYPE
		,doctype     tdocument.doctype%TYPE
		,opdate      tdocument.opdate%TYPE
		,clerkcode   tdocument.clerkcode%TYPE
		,station     tdocument.station%TYPE
		,olddocno    tdocument.olddocno%TYPE
		,newdocno    tdocument.newdocno%TYPE
		,docvalue    tdocument.docvalue%TYPE
		,parentdocno tdocument.parentdocno%TYPE
		,childdocno  tdocument.childdocno%TYPE
		,description tdocument.description%TYPE);
	TYPE typefindocumentlist IS TABLE OF typefindocumentrecord INDEX BY BINARY_INTEGER;

	TYPE typeacquirergrouprecord IS RECORD(
		 code tacquirergroup.code%TYPE
		,id   tacquirergroup.id%TYPE
		,NAME tacquirergroup.name%TYPE);
	TYPE typeacquirergrouplist IS TABLE OF typeacquirergrouprecord INDEX BY BINARY_INTEGER;

	TYPE typeretaccgroupitem IS RECORD(
		 currency              taccgroup.currency%TYPE
		,corraccountno         taccgroup.account%TYPE
		,transactiveaccountno  taccgroup.account%TYPE
		,transpassiveaccountno taccgroup.account%TYPE);
	TYPE typeretaccgroupitemlist IS TABLE OF typeretaccgroupitem INDEX BY BINARY_INTEGER;

	TYPE typeterminalrecord IS RECORD(
		 code                       treferenceterminal.code%TYPE
		,ficode                     treferenceterminal.ficode%TYPE
		,retailercode               treferenceterminal.retailercode%TYPE
		,ident                      treferenceterminal.ident%TYPE
		,NAME                       treferenceterminal.name%TYPE
		,device                     treferenceterminal.device%TYPE
		,accountgroupcode           treferenceterminal.accountgroupcode%TYPE
		,external_name              treferenceterminal.external_name%TYPE
		,external_city              treferenceterminal.external_city%TYPE
		,external_country           treferenceterminal.external_country%TYPE
		,external_zipcode           treferenceterminal.external_zipcode%TYPE
		,external_siccode           treferenceterminal.external_siccode%TYPE
		,external_cpscode           treferenceterminal.external_cpscode%TYPE
		,panentrytype               treferenceterminal.panentrytype%TYPE
		,holderauthtype             treferenceterminal.holderauthtype%TYPE
		,poscapability              treferenceterminal.poscapability%TYPE
		,country                    treferenceterminal.country%TYPE
		,city                       treferenceterminal.city%TYPE
		,address                    treferenceterminal.address%TYPE
		,isdefault                  treferenceterminal.isdefault%TYPE
		,country_code               treferenceterminal.country_code%TYPE
		,region_code                treferenceterminal.region_code%TYPE
		,city_code                  treferenceterminal.city_code%TYPE
		,street                     treferenceterminal.street%TYPE
		,house                      treferenceterminal.house%TYPE
		,building                   treferenceterminal.building%TYPE
		,frame                      treferenceterminal.frame%TYPE
		,flat                       treferenceterminal.flat%TYPE
		,location                   treferenceterminal.location%TYPE
		,note                       treferenceterminal.note%TYPE
		,primarycurrency            treferenceterminal.primarycurrency%TYPE
		,branchpart                 treferenceterminal.branchpart%TYPE
		,timeoffset                 treferenceterminal.timeoffset%TYPE
		,pincapturecap              treferenceterminal.pincapturecap%TYPE
		,inactive                   treferenceterminal.inactive%TYPE
		,createdate                 treferenceterminal.createdate%TYPE
		,updatedate                 treferenceterminal.updatedate%TYPE
		,createclerk                treferenceterminal.createclerk%TYPE
		,updateclerk                treferenceterminal.updateclerk%TYPE
		,isprototype                treferenceterminal.isprototype%TYPE
		,prototype                  treferenceterminal.prototype%TYPE
		,batchno                    treferenceterminal.batchno%TYPE
		,guid                       types.guid
		,longitude                  treferenceterminal.longitude%TYPE
		,latitude                   treferenceterminal.latitude%TYPE
		,contactlesscapable         treferenceterminal.contactlesscapable%TYPE
		,selfservice                treferenceterminal.selfservice%TYPE
		,parentinactive             treferenceterminal.parentinactive%TYPE
		,ecommercecapable           treferenceterminal.ecommercecapable%TYPE
		,motocapable                treferenceterminal.motocapable%TYPE
		,cashincapable              treferenceterminal.cashincapable%TYPE
		,parentcode                 treferenceterminal.parentcode%TYPE
		,limitgrp                   treferenceterminal.limitgrp%TYPE
		,limitcurrency              treferenceterminal.limitcurrency%TYPE
		,mobilepos                  treferenceterminal.mobilepos%TYPE
		,pinpadcapable              treferenceterminal.pinpadcapable%TYPE
		,serialnumber               treferenceterminal.serialnumber%TYPE
		,transactionsunloadingdelay treferenceterminal.transactionsunloadingdelay%TYPE
		,acqgroupid                 treferenceterminal.acqgroupid%TYPE
		,poscategory                treferenceterminal.poscategory%TYPE
		,createoperdate             DATE
		,entrycapsextended          treferenceterminal.entrycapsextended%TYPE
		
		);
	TYPE typeterminallist IS TABLE OF typeterminalrecord INDEX BY BINARY_INTEGER;

	TYPE typestatementrecord IS RECORD(
		 code              tstatement.statementcode%TYPE
		,idclient          tstatement.idclient%TYPE
		,statementgrp      tstatement.statementgrp%TYPE
		,statementtype     tstatement.statementtype%TYPE
		,accountno         tstatement.accountno%TYPE
		,pan               tstatement.pan%TYPE
		,mbr               tstatement.mbr%TYPE
		,contractno        tstatement.contractno%TYPE
		,statementactivity tstatement.statementactivity%TYPE
		,taxid             tstatement.taxid%TYPE
		,taxdebitaccount   tstatement.taxdebitaccount%TYPE
		,sendtype          tstatement.sendtype%TYPE
		,startdate         tstatement.startdate%TYPE
		,periodtype        tstatement.periodtype%TYPE
		,period            tstatement.period%TYPE
		,foldercode        tstatement.foldercode%TYPE
		,lngcode           tstatement.lngcode%TYPE
		,checkoperations   tstatement.checkoperations%TYPE
		,email             tstatement.email%TYPE
		,zip               tstatement.zip%TYPE
		,country           tstatement.country%TYPE
		,region            tstatement.region%TYPE
		,city              tstatement.city%TYPE
		,address           tstatement.address%TYPE
		,street            tstatement.street%TYPE
		,house             tstatement.house%TYPE
		,building          tstatement.building%TYPE
		,frame             tstatement.frame%TYPE
		,flat              tstatement.flat%TYPE
		,fincomm           tstatement.fincomm%TYPE);
	TYPE typestatementlist IS TABLE OF typestatementrecord INDEX BY BINARY_INTEGER;

	TYPE typetestamentpersonrecord IS RECORD(
		 no       ttastament.no%TYPE
		,sourceid ttastament.sourceid%TYPE
		,destid   ttastament.destid%TYPE);

	TYPE typeencoderecord IS RECORD(
		 encode     treferenceencode.encode%TYPE
		,encodeansi treferenceencode.ansi%TYPE
		,NAME       treferenceencode.name%TYPE);

	TYPE typeencodelist IS TABLE OF typeencoderecord INDEX BY BINARY_INTEGER;

	TYPE typefindresultclient IS RECORD(
		 idclient tclient.idclient%TYPE);
	TYPE typefindresultclientlist IS TABLE OF typefindresultclient INDEX BY BINARY_INTEGER;

	TYPE typefindresultacc IS RECORD(
		 accountno taccount.accountno%TYPE);
	TYPE typefindresultacclist IS TABLE OF typefindresultacc INDEX BY BINARY_INTEGER;

	TYPE typefindresultcon IS RECORD(
		 contractno tcontract.no%TYPE);
	TYPE typefindresultconlist IS TABLE OF typefindresultcon INDEX BY BINARY_INTEGER;

	TYPE typefindresultcard IS RECORD(
		 pan tcard.pan%TYPE
		,mbr tcard.mbr%TYPE);
	TYPE typefindresultcardlist IS TABLE OF typefindresultcard INDEX BY BINARY_INTEGER;

	TYPE typefindresulttas IS RECORD(
		 tastamentno ttastament.no%TYPE);
	TYPE typefindresulttaslist IS TABLE OF typefindresulttas INDEX BY BINARY_INTEGER;

	TYPE typefindresultwar IS RECORD(
		 warrantno twarrant.no%TYPE);
	TYPE typefindresultwarlist IS TABLE OF typefindresultwar INDEX BY BINARY_INTEGER;

	TYPE typefindresultcns IS RECORD(
		 idcns tclientcnsobj.idcns%TYPE);
	TYPE typefindresultcnslist IS TABLE OF typefindresultcns INDEX BY BINARY_INTEGER;

	TYPE typefindresultcus IS RECORD(
		 customerno tcustomer.customer%TYPE);
	TYPE typefindresultcuslist IS TABLE OF typefindresultcus INDEX BY BINARY_INTEGER;

	TYPE typefindresultapp IS RECORD(
		 applicationno tapplication.applicationno%TYPE);
	TYPE typefindresultapplist IS TABLE OF typefindresultapp INDEX BY BINARY_INTEGER;

	TYPE typefindresultent IS RECORD(
		 docno tentry.docno%TYPE);
	TYPE typefindresultentlist IS TABLE OF typefindresultent INDEX BY BINARY_INTEGER;

	TYPE typefindresultcb IS RECORD(
		 no tchequebook.no%TYPE);
	TYPE typefindresultcblist IS TABLE OF typefindresultcb INDEX BY BINARY_INTEGER;

	TYPE typefindresultretailer IS RECORD(
		 retailercode treferenceretailer.code%TYPE);
	TYPE typefindresultretailerlist IS TABLE OF typefindresultretailer INDEX BY BINARY_INTEGER;

	TYPE typefindresultterminal IS RECORD(
		 terminalcode treferenceterminal.code%TYPE);
	TYPE typefindresultterminallist IS TABLE OF typefindresultterminal INDEX BY BINARY_INTEGER;

	TYPE addressinfo IS RECORD(
		 country   NUMBER(3)
		,region    VARCHAR(20)
		,city      VARCHAR(20)
		,street    VARCHAR(20)
		,postal    VARCHAR(30)
		,address   VARCHAR(200)
		,house     VARCHAR(20)
		,building  VARCHAR(20)
		,frame     VARCHAR(20)
		,flat      VARCHAR(20)
		,phone     VARCHAR(20)
		,fax       VARCHAR(20)
		,email     VARCHAR(200)
		,cellphone VARCHAR(20)
		,pager     VARCHAR(30)
		,ocato     VARCHAR(11)
		,area      NUMBER
		,octmo     VARCHAR(11));

	TYPE typeeventrecord IS RECORD(
		 event         NUMBER
		,debitaccount  VARCHAR(20)
		,creditaccount VARCHAR(20)
		,amount        NUMBER
		,currency      NUMBER
		,exchange      NUMBER
		,docno         NUMBER
		,entryno       NUMBER
		,entryident    VARCHAR2(40)
		,
		
		finprofilecode NUMBER
		,periodtype     NUMBER
		,period         NUMBER
		
		);

	TYPE typestatementfeerecord IS RECORD(
		
		 debitaccount  taccount.accountno%TYPE
		,amount        NUMBER
		,currency      NUMBER
		,exchange      NUMBER
		,docno         NUMBER
		,NAME          tstatementtax.name%TYPE
		,creditaccount tstatementtax.taxcreditaccount%TYPE
		,entryident    tstatementtax.entryident%TYPE);

	TYPE typelimit IS RECORD(
		 limitid         NUMBER
		,maxvalue        NUMBER
		,periodtype      NUMBER
		,period          NUMBER
		,curvalue        NUMBER
		,nextdate        DATE
		,availableexcess NUMBER
		,rangelist       typelimitinforangelist);
	TYPE typelimitlist IS TABLE OF typelimit INDEX BY BINARY_INTEGER;

	SUBTYPE limit_record IS typelimit;
	SUBTYPE limit_array IS typelimitlist;

	TYPE typelimitinfo IS RECORD(
		 limitid     NUMBER
		,limitname   VARCHAR2(60)
		,maxvalue    NUMBER
		,maxtype     NUMBER
		,periodtype  NUMBER
		,period      NUMBER
		,holdalg     NUMBER
		,currency    NUMBER
		,curvalue    NUMBER
		,limittype   NUMBER
		,limitstatus NUMBER
		,lastreset   DATE
		,nextdate    DATE
		,avlblexcess NUMBER
		,changedate  DATE
		,SQLCODE     NUMBER
		,rangelist   typelimitinforangelist
		,modifymask  RAW(2));
	TYPE typelimitinfolist IS TABLE OF typelimitinfo INDEX BY BINARY_INTEGER;

	TYPE typecounter IS RECORD(
		 counterid  NUMBER
		,maxvalue   NUMBER
		,periodtype NUMBER
		,period     NUMBER
		,curvalue   NUMBER
		,nextdate   DATE);
	TYPE typecounterlist IS TABLE OF typecounter INDEX BY BINARY_INTEGER;

	SUBTYPE counter_record IS typecounter;
	SUBTYPE counter_array IS typecounterlist;

	TYPE typecounterinfo IS RECORD(
		 counterid       NUMBER
		,countername     VARCHAR2(60)
		,maxvalue        NUMBER
		,periodtype      NUMBER
		,period          NUMBER
		,countertype     NUMBER
		,synchronizetype NUMBER
		,counterstatus   NUMBER
		,intlimitid      NUMBER
		,nextdate        DATE);
	TYPE typecounterinfolist IS TABLE OF typecounterinfo INDEX BY BINARY_INTEGER;

	TYPE typeapplobjectrecord IS RECORD(
		 objectlinkcode NUMBER
		,key1           VARCHAR(255)
		,key2           VARCHAR(255));
	TYPE typeapplobjectarray IS TABLE OF typeapplobjectrecord INDEX BY BINARY_INTEGER;

	TYPE typereferencevaluerecord IS RECORD(
		 code VARCHAR2(256)
		,NAME VARCHAR2(256));
	TYPE typereferencevaluelist IS TABLE OF typereferencevaluerecord INDEX BY BINARY_INTEGER;

	TYPE typemaskedfieldsrecord IS RECORD(
		 fieldname VARCHAR2(100)
		,maskcode  NUMBER);

	TYPE typemaskedfieldslist IS TABLE OF typemaskedfieldsrecord INDEX BY BINARY_INTEGER;

	SUBTYPE typesoperationsysid IS VARCHAR2(32);

	TYPE typesoperationsysidarray IS TABLE OF typesoperationsysid INDEX BY BINARY_INTEGER;

	SUBTYPE typesoparamid IS PLS_INTEGER;

	csoparamnamemaxlength CONSTANT PLS_INTEGER := 64;
	SUBTYPE typesoparamname IS VARCHAR2(64);

	SUBTYPE typesoparamtype IS PLS_INTEGER;

	csoparamstingvaluemaxlength CONSTANT PLS_INTEGER := 4000;

	SUBTYPE typesoparamnumericvalue IS NUMBER;

	SUBTYPE typesoparamdatetimevalue IS DATE;

	SUBTYPE typesoparambooleanvalue IS BOOLEAN;

	SUBTYPE typesoparamstringvalue IS VARCHAR2(4000);
	TYPE typesoparamstringvalues IS TABLE OF typesoparamstringvalue INDEX BY BINARY_INTEGER;
	TYPE typesoparamnumericvalues IS TABLE OF typesoparamnumericvalue INDEX BY BINARY_INTEGER;
	TYPE typesoparamdatetimevalues IS TABLE OF typesoparamdatetimevalue INDEX BY BINARY_INTEGER;
	TYPE typesoparambooleanvalues IS TABLE OF typesoparambooleanvalue INDEX BY BINARY_INTEGER;

	TYPE typesoparam IS RECORD(
		 id             typesoparamid
		,NAME           typesoparamname
		,TYPE           typesoparamtype
		,stringvalues   typesoparamstringvalues
		,numericvalues  typesoparamnumericvalues
		,datetimevalues typesoparamdatetimevalues
		,booleanvalues  typesoparambooleanvalues
		,
		
		redefinable BOOLEAN
		,redefined   BOOLEAN);

	TYPE typesoparamarray IS TABLE OF typesoparam INDEX BY BINARY_INTEGER;

	SUBTYPE typesotemplatesysid IS NUMBER;
	TYPE typesotemplatesysidarray IS TABLE OF typesotemplatesysid INDEX BY BINARY_INTEGER;

	csotemplatenamemaxlength CONSTANT PLS_INTEGER := 64;
	SUBTYPE typesotemplatename IS VARCHAR2(64);

	csotemplatedescrmaxlength CONSTANT PLS_INTEGER := 1024;
	SUBTYPE typesotemplatedescription IS VARCHAR2(1024);

	SUBTYPE typesotemplatecontext IS PLS_INTEGER;
	csotcsoaccounttype  CONSTANT typesotemplatecontext := 1;
	csotcsocontracttype CONSTANT typesotemplatecontext := 2;

	TYPE typesotemplate IS RECORD(
		 id               typesotemplatesysid
		,NAME             typesotemplatename
		,operationid      typesoperationsysid
		,params           typesoparamarray
		,active           BOOLEAN
		,CONTEXT          typesotemplatecontext
		,ownerid          NUMBER
		,parenttemplateid typesotemplatesysid
		,priority         BOOLEAN
		,createdby        NUMBER
		,createdatetime   DATE
		,modifiedby       NUMBER
		,modifydatetime   DATE);

	TYPE typesotemplatearray IS TABLE OF typesotemplate INDEX BY BINARY_INTEGER;

	TYPE typeoperationinfo IS RECORD(
		 operation         VARCHAR2(30)
		,accountno         VARCHAR2(20)
		,corraccountno     VARCHAR2(20)
		,amount            NUMBER
		,currency          NUMBER
		,includefeesamount BOOLEAN
		,batchmode         BOOLEAN
		,
		
		docno     NUMBER
		,entrycode NUMBER
		
		);

	TYPE typegroupoperation IS RECORD(
		 proc      toperationgroup.proc%TYPE
		,NAME      toperationgroup.name%TYPE
		,remark    toperationgroup.remark%TYPE
		,code      toperationgroup.code%TYPE
		,TYPE      toperationgroup.type%TYPE
		,active    toperationgroup.active%TYPE
		,sort      toperationgroup.sort%TYPE
		,groupcode toperationgroup.sort%TYPE);
	TYPE typegroupoperationlist IS TABLE OF typegroupoperation INDEX BY BINARY_INTEGER;

	TYPE typebopoperationsys IS RECORD(
		 id    tboprefoper.id%TYPE
		,ident tboprefoper.ident%TYPE
		,NAME  tboprefoper.name%TYPE);

	TYPE typebopoperation IS RECORD(
		 sys typebopoperationsys
		,usr types.typetree);

	TYPE typeboppacketsys IS RECORD(
		 no              tboppacket.no%TYPE
		,recordcount     tboppacket.recordcount%TYPE
		,execreccount    tboppacket.execreccount%TYPE
		,execerrreccount tboppacket.execerrreccount%TYPE
		,rberrreccount   tboppacket.rberrreccount%TYPE
		,crerrreccount   tboppacket.crerrreccount%TYPE
		,unldreccount    tboppacket.unldreccount%TYPE
		,createoperdate  tboppacket.createoperdate%TYPE
		,createsysdate   tboppacket.createsysdate%TYPE
		,execoperdate    tboppacket.execoperdate%TYPE
		,execsysdate     tboppacket.execsysdate%TYPE
		,unloadoperdate  tboppacket.unloadoperdate%TYPE
		,unloadsysdate   tboppacket.unloadsysdate%TYPE
		,rboperdate      tboppacket.rboperdate%TYPE
		,rbsysdate       tboppacket.rbsysdate%TYPE
		,createclerk     tboppacket.createclerk%TYPE
		,branchpart      tboppacket.branchpart%TYPE
		,execclerk       tboppacket.execclerk%TYPE
		,unloadclerk     tboppacket.unloadclerk%TYPE
		,rbclerk         tboppacket.rbclerk%TYPE
		,uniquekey       tboppackuniquekey.uniquekey%TYPE);

	TYPE typeboppacket IS RECORD(
		 sys typeboppacketsys
		,usr types.typetree);

	TYPE typeboprecordsys IS RECORD(
		 no            tboprecord.no%TYPE
		,status        tboprecord.status%TYPE
		,crstatus      tboprecord.crstatus%TYPE
		,unldstatus    tboprecord.unldstatus%TYPE
		,execerrorcode tboprecord.execerrorcode%TYPE
		,rberrorcode   tboprecord.rberrorcode%TYPE
		,crerrorcode   tboprecord.crerrorcode%TYPE
		,execerror     tboprecord.execerror%TYPE
		,rberror       tboprecord.rberror%TYPE
		,crerror       tboprecord.crerror%TYPE
		,requestid     tboprecord.requestid%TYPE
		,unloadorder   tboprecord.unloadorder%TYPE
		,HASH          tboprecord.hash%TYPE);

	TYPE typeboprecord IS RECORD(
		 sys typeboprecordsys
		,usr types.typetree);

	TYPE typecashiershift IS RECORD(
		 shift treferenceshift.shift%TYPE
		,NAME  treferenceshift.name%TYPE);
	TYPE typecashiershiftlist IS TABLE OF typecashiershift INDEX BY BINARY_INTEGER;

	TYPE typecashaccountofshift IS RECORD(
		 currency  tcashiershiftaccounts.currency%TYPE
		,accountno tcashiershiftaccounts.accountno%TYPE
		,minnote   tcashiershiftaccounts.minnote%TYPE);
	TYPE typecashaccountofshiftlist IS TABLE OF typecashaccountofshift INDEX BY BINARY_INTEGER;

	SUBTYPE typeomsfieldsmask IS RAW;
	SUBTYPE typeoms_sca_fieldsmask IS typeomsfieldsmask(2);
	cfmoms_sca_mask              CONSTANT typeoms_sca_fieldsmask := '0001';
	cfmoms_sca_lowerbound        CONSTANT typeoms_sca_fieldsmask := '0002';
	cfmoms_sca_excludelowerbound CONSTANT typeoms_sca_fieldsmask := '0004';
	cfmoms_sca_upperbound        CONSTANT typeoms_sca_fieldsmask := '0008';
	cfmoms_sca_excludeupperbound CONSTANT typeoms_sca_fieldsmask := '0010';
	cfmoms_sca_invertequality    CONSTANT typeoms_sca_fieldsmask := '0020';

	TYPE typeoms_searchcriterionattr IS RECORD(
		 NAME              VARCHAR2(64)
		,mask              VARCHAR2(4000)
		,lowerbound        VARCHAR2(4000)
		,excludelowerbound BOOLEAN
		,upperbound        VARCHAR2(4000)
		,excludeupperbound BOOLEAN
		,invertequality    BOOLEAN
		,fieldsmask        typeoms_sca_fieldsmask);

	TYPE typeoms_searchcriteriaattrs IS TABLE OF typeoms_searchcriterionattr INDEX BY BINARY_INTEGER;

	TYPE typeoms_searchcriteriaobject IS RECORD(
		 NAME                VARCHAR2(64)
		,searchcriteriaattrs typeoms_searchcriteriaattrs
		,parentindex         PLS_INTEGER
		,siblingindex        PLS_INTEGER
		,childindex          PLS_INTEGER);

	TYPE typeoms_searchcriteriaobjects IS TABLE OF typeoms_searchcriteriaobject INDEX BY BINARY_INTEGER;

	TYPE typepreparedtransactionrecord IS RECORD(
		 no                   tcashoperations.no%TYPE
		,docno                tcashoperations.docno%TYPE
		,accountno            tcashoperations.accountno%TYPE
		,contractno           tcashoperations.contractno%TYPE
		,TYPE                 tcashoperations.operationtype%TYPE
		,entrycode            tcashoperations.entrycode%TYPE
		,amount               tcashoperations.operationsum%TYPE
		,currency             NUMBER
		,assigncommission     NUMBER
		,amount2              NUMBER
		,currency2            tcashoperations.currency2%TYPE
		,exchrate             tcashoperations.exchrate%TYPE
		,createclerk          tcashoperations.orderclerkcode%TYPE
		,createdate           tcashoperations.orderdate%TYPE
		,createsysdate        tcashoperations.ordersysdate%TYPE
		,idclient             tcashoperations.idclient%TYPE
		,shortremark          tcashoperations.shortremark%TYPE
		,remark               tcashoperations.fullremark%TYPE
		,addinfo              tcashoperations.additional%TYPE
		,externalid           tcashoperations.externalid%TYPE
		,clienttype           tcashoperations.clienttype%TYPE
		,userattributesid     tcashoperations.userattributesid%TYPE
		,warrantno            tcashoperations.warrantno%TYPE
		,testamentno          tcashoperations.testamentno%TYPE
		,priority             tcashoperations.priority%TYPE
		,amounttype           tcashoperations.amounttype%TYPE
		,commissionlist       typesoparamnumericvalues
		,activecommissionlist typesoparamnumericvalues
		,branchpart           tcashoperations.branchpart%TYPE
		
		);
	TYPE typepreparedtransactionlist IS TABLE OF typepreparedtransactionrecord INDEX BY BINARY_INTEGER;

	TYPE typemacrosinfo IS RECORD(
		 code         NUMBER
		,NAME         VARCHAR2(50)
		,createdate   DATE
		,execdate     DATE
		,execcount    NUMBER
		,lastline     NUMBER
		,countline    NUMBER
		,breakonerror BOOLEAN
		,description  VARCHAR2(1000));

	TYPE typefincommissionplanrecord IS RECORD(
		 objectuid NUMBER
		,no        NUMBER
		,prc       NUMBER
		,amount    NUMBER
		,minamount NUMBER
		,maxamount NUMBER);
	TYPE typefincommissionplanlist IS TABLE OF typefincommissionplanrecord INDEX BY VARCHAR2(30);

	TYPE typefinpaymentplanrecord IS RECORD(
		 objectuid NUMBER
		,no        NUMBER
		,amount    NUMBER);
	TYPE typefinpaymentplanlist IS TABLE OF typefinpaymentplanrecord INDEX BY VARCHAR2(30);

	TYPE typefinpaymentrecord IS RECORD(
		 payment        tfinpayment.payment%TYPE
		,account        tfinpayment.account%TYPE
		,accounttwotype tfinpayment.accounttwotype%TYPE
		,accounttwo     tfinpayment.accounttwo%TYPE
		,accounttwolink tfinpayment.accounttwolink%TYPE
		,startdate      tfinpayment.startdate%TYPE
		,period         tfinpayment.period%TYPE
		,periodtype     tfinpayment.periodtype%TYPE
		,exchange       tfinpayment.exchange%TYPE
		,currency       tfinpayment.currency%TYPE
		,amount         tfinpayment.amount%TYPE
		,paybonus       tfinpayment.paybonus%TYPE
		,prcbonus       tfinpayment.prcbonus%TYPE
		,exchangebonus  tfinpayment.exchangebonus%TYPE);
	TYPE typefinpaymentlist IS TABLE OF typefinpaymentrecord INDEX BY BINARY_INTEGER;

	TYPE typecollectioncase IS RECORD(
		 branchpart tcollectioncase.branchpart%TYPE
		,id         tcollectioncase.id%TYPE
		,caseno     tcollectioncase.caseno%TYPE
		,idclient   tcollectioncase.idclient%TYPE
		,classid    tcollectioncase.classid%TYPE
		,priority   tcollectioncase.priority%TYPE
		,state      tcollectioncase.state%TYPE
		,createmode tcollectioncase.createmode%TYPE
		,
		
		createoperdate   tcollectioncase.createoperdate%TYPE
		,createsysdate    tcollectioncase.createsysdate%TYPE
		,createclerkcode  tcollectioncase.createclerkcode%TYPE
		,classsetoperdate tcollectioncase.classsetoperdate%TYPE
		,
		
		classsetsysdate tcollectioncase.classsetsysdate%TYPE
		,updateoperdate  tcollectioncase.updateoperdate%TYPE
		,updatesysdate   tcollectioncase.updatesysdate%TYPE
		,changeoperdate  tcollectioncase.changeoperdate%TYPE
		,changesysdate   tcollectioncase.changesysdate%TYPE
		,changeclerkcode tcollectioncase.changeclerkcode%TYPE
		,closemode       tcollectioncase.closemode%TYPE
		,
		
		closeoperdate tcollectioncase.closeoperdate%TYPE
		,closesuccess  tcollectioncase.closesuccess%TYPE
		,
		
		closesysdate       tcollectioncase.closesysdate%TYPE
		,closeclerkcode     tcollectioncase.closeclerkcode%TYPE
		,parentcase         tcollectioncase.parentcase%TYPE
		,personalclerkcode  tcollectioncase.personalclerkcode%TYPE
		,personalagencyid   tcollectioncase.personalagencyid%TYPE
		,disableautoclosure tcollectioncase.disableautoclosure%TYPE
		,
		
		externalid tcollectioncase.externalid%TYPE
		,objectuid  tcollectioncase.objectuid%TYPE);
	TYPE typecollectioncaselist IS TABLE OF typecollectioncase INDEX BY BINARY_INTEGER;

	TYPE typecollectionclass IS RECORD(
		 id                 tcollectclass.id%TYPE
		,classorder         tcollectclass.classorder%TYPE
		,code               tcollectclass.code%TYPE
		,NAME               tcollectclass.name%TYPE
		,disableautoclosure tcollectclass.disableautoclosure%TYPE
		,
		
		disablerevaluation tcollectclass.disablerevaluation%TYPE
		,
		
		defaultscheduleid   tcollectclass.defaultscheduleid%TYPE
		,defaultprioritytype tcollectclass.defaultprioritytype%TYPE
		,defaultpriorityid   tcollectclass.defaultpriorityid%TYPE
		,defaultagencyid     tcollectclass.defaultagencyid%TYPE
		,
		
		defaultclerkcode tcollectclass.defaultclerkcode%TYPE
		,existingcase     tcollectclass.existingcase%TYPE
		,
		
		useexistingcase tcollectclass.useexistingcase%TYPE
		,
		
		minlimitvalue     tcollectclass.minlimitvalue%TYPE
		,maxlimitvalue     tcollectclass.maxlimitvalue%TYPE
		,minbalance        tcollectclass.minbalance%TYPE
		,maxbalance        tcollectclass.maxbalance%TYPE
		,limitcurrency     tcollectclass.limitcurrency%TYPE
		,maxptpnumber      tcollectclass.maxptpnumber%TYPE
		,maxptpperiod      tcollectclass.maxptpperiod%TYPE
		,useclnd4ptpperiod tcollectclass.useclnd4ptpperiod%TYPE
		,minptppercentage  tcollectclass.minptppercentage%TYPE
		,minptpamount      tcollectclass.minptpamount%TYPE
		,
		
		minptpacceptable tcollectclass.minptpacceptable%TYPE
		,
		
		active tcollectclass.active%TYPE
		,
		
		activefromdate tcollectclass.activefromdate%TYPE
		,
		
		activetodate tcollectclass.activetodate%TYPE
		,
		
		objectuid tcollectclass.objectuid%TYPE);
	TYPE typecollectionclasslist IS TABLE OF typecollectionclass INDEX BY BINARY_INTEGER;

	TYPE typecollectionaction IS RECORD(
		 id   tcollectaction.id%TYPE
		,code tcollectaction.code%TYPE
		,NAME tcollectaction.name%TYPE
		,TYPE tcollectaction.type%TYPE
		,
		
		periodicity      tcollectaction.periodicity%TYPE
		,durationtype     tcollectaction.durationtype%TYPE
		,duration         tcollectaction.duration%TYPE
		,frequencytype    tcollectaction.frequencytype%TYPE
		,frequency        tcollectaction.frequency%TYPE
		,priority         tcollectaction.priority%TYPE
		,proc             tcollectaction.proc%TYPE
		,opcode           tcollectaction.opcode%TYPE
		,contractstate    tcollectaction.contractstate%TYPE
		,feeamount        tcollectaction.feeamount%TYPE
		,feecurrency      tcollectaction.feecurrency%TYPE
		,feeentrycode     tcollectaction.feeentrycode%TYPE
		,feeincomeaccount tcollectaction.feeincomeaccount%TYPE
		,agencyid         tcollectaction.agencyid%TYPE
		,classid          tcollectaction.classid%TYPE
		,classstartmode   tcollectaction.classstartmode%TYPE
		,
		
		stmtmsgid tcollectaction.stmtmsgid%TYPE
		,execmode  tcollectaction.execmode%TYPE
		,moving    tcollectaction.moving%TYPE
		,
		
		calendartype tcollectaction.execmode%TYPE);
	TYPE typecollectionactionlist IS TABLE OF typecollectionaction INDEX BY BINARY_INTEGER;

	TYPE typecollectionagency IS RECORD(
		 id             tcollectagency.id%TYPE
		,code           tcollectagency.code%TYPE
		,idclient       tcollectagency.idclient%TYPE
		,processfee     tcollectagency.processfee%TYPE
		,successfee     tcollectagency.successfee%TYPE
		,feecurrency    tcollectagency.feecurrency%TYPE
		,active         tcollectagency.active%TYPE
		,activedatefrom tcollectagency.activedatefrom%TYPE
		,activedateto   tcollectagency.activedateto%TYPE);
	TYPE typecollectionagencylist IS TABLE OF typecollectionagency INDEX BY BINARY_INTEGER;

	TYPE typecollectionschedule IS RECORD(
		 id   tcollectschedule.id%TYPE
		,NAME tcollectschedule.name%TYPE);
	TYPE typecollectionschedulelist IS TABLE OF typecollectionschedule INDEX BY BINARY_INTEGER;

	TYPE typecollectionpriority IS RECORD(
		 id            tcollectpriority.id%TYPE
		,priorityorder tcollectpriority.priorityorder%TYPE
		,code          tcollectpriority.code%TYPE
		,NAME          tcollectpriority.name%TYPE);
	TYPE typecollectionprioritylist IS TABLE OF typecollectionpriority INDEX BY BINARY_INTEGER;

	TYPE typecollectioncasecategory IS RECORD(
		 caseid        tcollectioncasecategory.caseid%TYPE
		,contractno    tcollectioncasecategory.contractno%TYPE
		,register      tcollectioncasecategory.register%TYPE
		,registerid    tcollectioncasecategory.registerid%TYPE
		,packno        tcollectioncasecategory.packno%TYPE
		,operdate      tcollectioncasecategory.operdate%TYPE
		,idrule        tcollectioncasecategory.idrule%TYPE
		,idattribute   tcollectioncasecategory.idattribute%TYPE
		,attributename tcollectioncasecategory.attributename%TYPE
		,claimamount   tcollectioncasecategory.claimamount%TYPE
		,claimdate     tcollectioncasecategory.claimdate%TYPE
		,keyvalue      tcollectioncasecategory.keyvalue%TYPE
		,ruleresult    tcollectioncasecategory.ruleresult%TYPE);
	TYPE typecollectioncasecategorylist IS TABLE OF typecollectioncasecategory INDEX BY BINARY_INTEGER;

	TYPE typecollectioncaseobject IS RECORD(
		 caseid       tcollectioncaseobject.caseid%TYPE
		,objecttype   tcollectioncaseobject.objecttype%TYPE
		,contractno   tcollectioncaseobject.contractno%TYPE
		,register     tcollectioncaseobject.register%TYPE
		,registerid   tcollectioncaseobject.registerid%TYPE
		,accountno    tcollectioncaseobject.accountno%TYPE
		,pan          tcollectioncaseobject.pan%TYPE
		,mbr          tcollectioncaseobject.mbr%TYPE
		,currency     tcollectioncaseobject.currency%TYPE
		,addmode      tcollectioncaseobject.addmode%TYPE
		,categorylist typecollectioncasecategorylist);
	TYPE typecollectioncaseobjectlist IS TABLE OF typecollectioncaseobject INDEX BY BINARY_INTEGER;

	TYPE typecollectioncaseschedule IS RECORD(
		 id           tcollectioncaseschedule.id%TYPE
		,caseid       tcollectioncaseschedule.caseid%TYPE
		,actionid     tcollectioncaseschedule.actionid%TYPE
		,actiondate   tcollectioncaseschedule.actiondate%TYPE
		,clerkid      tcollectioncaseschedule.clerkid%TYPE
		,cancelled    tcollectioncaseschedule.cancelled%TYPE
		,nextexecdate tcollectioncaseschedule.nextexecdate%TYPE
		,enddate      tcollectioncaseschedule.enddate%TYPE
		,status       tcollectioncaseschedule.status%TYPE);
	TYPE typecollectioncaseschedulelist IS TABLE OF typecollectioncaseschedule INDEX BY BINARY_INTEGER;

	TYPE typecollectioncaseaction IS RECORD(
		 id             tcollectioncaseaction.id%TYPE
		,caseid         tcollectioncaseaction.caseid%TYPE
		,casescheduleid tcollectioncaseaction.casescheduleid%TYPE
		,contractno     tcollectioncaseaction.contractno%TYPE
		,register       tcollectioncaseaction.register%TYPE
		,actionid       tcollectioncaseaction.actionid%TYPE
		,operdate       tcollectioncaseaction.operdate%TYPE
		,sysdatetime    tcollectioncaseaction.sysdatetime%TYPE
		,clerkcode      tcollectioncaseaction.clerkcode%TYPE
		,agencyid       tcollectioncaseaction.agencyid%TYPE
		,remarkid       tcollectioncaseaction.remarkid%TYPE
		,rollbackdata   tcollectioncaseaction.rollbackdata%TYPE
		,packno         tcollectioncaseaction.packno%TYPE);

	TYPE typefindresultcollection IS RECORD(
		 collectionid tcollectioncase.id%TYPE);
	TYPE typefindresultcollectionlist IS TABLE OF typefindresultcollection INDEX BY BINARY_INTEGER;

	TYPE typecommissionrecord IS RECORD(
		 commission  treferencecommission.commission%TYPE
		,NAME        treferencecommission.name%TYPE
		,debit       treferencecommission.debit%TYPE
		,debitlink   treferencecommission.debitlink%TYPE
		,credit      treferencecommission.credit%TYPE
		,creditlink  treferencecommission.creditlink%TYPE
		,method      treferencecommission.method%TYPE
		,entident    treferencecommission.entident%TYPE
		,description treferencecommission.description%TYPE
		,stat        treferencecommission.stat%TYPE
		,currency    treferencecommission.currency%TYPE
		,exchange    treferencecommission.exchange%TYPE);
	TYPE typecommissionlist IS TABLE OF typecommissionrecord INDEX BY BINARY_INTEGER;

	TYPE typecommissiondatarecord IS RECORD(
		 INTERVAL  NUMBER
		,amount    NUMBER
		,prc       NUMBER
		,minamount NUMBER
		,maxamount NUMBER);
	TYPE typecommissiondatalist IS TABLE OF typecommissiondatarecord INDEX BY BINARY_INTEGER;

	TYPE typecardcounterrecord IS RECORD(
		 code       tcardcounteritem.counterid%TYPE
		,NAME       treferencecounter.name%TYPE
		,TYPE       treferencecounter.countertype%TYPE
		,VALUE      tcardcounteritem.maxvalue%TYPE
		,periodtype tcardcounteritem.periodtype%TYPE
		,period     tcardcounteritem.period%TYPE
		,status     NUMBER
		,nextdate   tcardcounteritem.nextdate%TYPE);
	TYPE typecardcounterlist IS TABLE OF typecardcounterrecord INDEX BY BINARY_INTEGER;

	TYPE typeaccountcounterrecord IS RECORD(
		 code       taccountcounteritem.counterid%TYPE
		,NAME       treferencecounter.name%TYPE
		,TYPE       treferencecounter.countertype%TYPE
		,VALUE      taccountcounteritem.maxvalue%TYPE
		,periodtype taccountcounteritem.periodtype%TYPE
		,period     taccountcounteritem.period%TYPE
		,status     NUMBER
		,nextdate   tcardcounteritem.nextdate%TYPE);
	TYPE typeaccountcounterlist IS TABLE OF typeaccountcounterrecord INDEX BY BINARY_INTEGER;

	TYPE typeclientcounterrecord IS RECORD(
		 code       tclientcounteritem.counterid%TYPE
		,NAME       treferencecounter.name%TYPE
		,TYPE       treferencecounter.countertype%TYPE
		,VALUE      tclientcounteritem.maxvalue%TYPE
		,periodtype tclientcounteritem.periodtype%TYPE
		,period     tclientcounteritem.period%TYPE
		,status     NUMBER
		,nextdate   tclientcounteritem.nextdate%TYPE);
	TYPE typeclientcounterlist IS TABLE OF typeclientcounterrecord INDEX BY BINARY_INTEGER;

	TYPE enforcementorderrecord IS RECORD(
		 branch           tenforcementorder.branch%TYPE
		,no               tenforcementorder.no%TYPE
		,judgmentdate     tenforcementorder.judgmentdate%TYPE
		,effectivedate    tenforcementorder.effectivedate%TYPE
		,state            tenforcementorder.state%TYPE
		,clientid         tenforcementorder.clientid%TYPE
		,amount           tenforcementorder.amount%TYPE
		,bailiffname      tenforcementorder.bailiffname%TYPE
		,addititionalinfo tenforcementorder.addititionalinfo%TYPE
		,guid             types.guid
		,createopdate     tenforcementorder.createopdate%TYPE
		,createsysdate    tenforcementorder.createsysdate%TYPE
		,createdby        tenforcementorder.createdby%TYPE
		,modifyopdate     tenforcementorder.modifyopdate%TYPE
		,modifysysdate    tenforcementorder.modifysysdate%TYPE
		,modifiedby       tenforcementorder.modifiedby%TYPE
		,cancelsysdate    tenforcementorder.cancelsysdate%TYPE
		,cancellby        tenforcementorder.cancelledby%TYPE
		,cancelopdate     tenforcementorder.cancelopdate%TYPE
		,branchpart       tenforcementorder.branchpart%TYPE
		,organname        tenforcementorder.organ%TYPE
		,enforcementtype  tenforcementorder.enforcementtype%TYPE
		,corporateid      tenforcementorder.corporateid%TYPE);

	TYPE enforcementorderlist IS TABLE OF enforcementorderrecord INDEX BY BINARY_INTEGER;

	FUNCTION getversion RETURN VARCHAR2;

END;
/
CREATE OR REPLACE PACKAGE BODY custom_api_type AS

	cpackagename        CONSTANT VARCHAR2(100) := 'custom_api_type';
	cpackagebodyversion CONSTANT VARCHAR2(100) := '$Rev: 32361 $';

	FUNCTION getversion RETURN VARCHAR2 IS
	BEGIN
		RETURN cpackagename || ' spec[' || cpackagespecversion || '], body[' || cpackagebodyversion || ']';
	END;

BEGIN
	NULL;
END;
/
