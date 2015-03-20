-- Create table
create table IDENTIFYCOLLECT
(
  offerno       VARCHAR2(36),
  jqcode        VARCHAR2(60),
  sycode        VARCHAR2(60),
  responsecode  VARCHAR2(6),
  tradeno       VARCHAR2(60),
  createdby     VARCHAR2(6),
  createdgroup  VARCHAR2(6),
  createddate   DATE,
  modifiedby    VARCHAR2(6),
  modifiedgroup VARCHAR2(6),
  modifieddate  DATE
);

insert into sysc_interface (LOCALURL, WEBSERVICEURL, WEBMETHOD, WEBTYPE, REMARK)
values (null, 'http://10.0.96.179:7005/mw/xmldispatch', '500', '0022', '校验码获取和验证接口');
