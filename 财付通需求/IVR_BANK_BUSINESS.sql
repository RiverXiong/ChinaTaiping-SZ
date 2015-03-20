-- Create table
create table IVR_BANK_BUSINESS
(
  bank_id       VARCHAR2(20),
  bank_desc     VARCHAR2(300),
  cardkind      VARCHAR2(20),
  cardkind_desc VARCHAR2(300),
  business_id   VARCHAR2(20),
  business_desc VARCHAR2(300),
  createddate   DATE,
  creadedby     VARCHAR2(6),
  createdgroup  VARCHAR2(6),
  modifieddate  DATE,
  modifiedby    VARCHAR2(6),
  modifiedgroup VARCHAR2(6)
)
