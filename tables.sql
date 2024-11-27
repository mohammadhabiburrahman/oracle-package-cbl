drop table APP_NPSTRANSACTIONS ;

create table APP_NPSTRANSACTIONS
(
  id                   NUMBER not null,
  filename             VARCHAR2(300),
  cardnumber           VARCHAR2(50),
  srn                  VARCHAR2(50),
  drn                  VARCHAR2(50),
  rrn                  VARCHAR2(50),
  authorizationcode    VARCHAR2(50),
  transactiondate      NVARCHAR2(50),
  transactiontype      VARCHAR2(50),
  transactionamount    NUMBER,
  settlementtme        NVARCHAR2(50),
  requestcategory      VARCHAR2(30),
  atmid                VARCHAR2(50),
  sic                  VARCHAR2(50),
  atmlocation          VARCHAR2(100),
  billingamount        NUMBER,
  billingphasedate     NVARCHAR2(50),
  issuerbank           VARCHAR2(50),
  acquirerbank         VARCHAR2(50),
  reconciliationamount NUMBER,
  reconciliationdate   NVARCHAR2(50),
  what_trx             VARCHAR2(50),
  srvc                 VARCHAR2(30),
  cpid                 VARCHAR2(30)
) ;

alter table APP_NPSTRANSACTIONS
  add primary key (ID) ;