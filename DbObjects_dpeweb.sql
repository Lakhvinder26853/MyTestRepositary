-- reset the schema: drop all the tables abd functions. 
drop schema if exists dpeweb cascade;

create schema dpeweb;

alter schema dpeweb
    owner TO dpeweb;

-- Table: dpeweb.tbl_defaultscriptnames

-- DROP TABLE dpeweb.tbl_defaultscriptnames;

CREATE TABLE dpeweb.tbl_defaultscriptnames
(
    scriptid SERIAL NOT NULL,
    scriptname text,
    createddate timestamp,
    modifieddate timestamp,
    status boolean,
    CONSTRAINT "ScripId" PRIMARY KEY (scriptid)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE dpeweb.tbl_defaultscriptnames
    OWNER TO dpeweb;

---------------------------------------------------------------------------------------------------1
-- Table: dpeweb.tbl_source

-- DROP TABLE dpeweb.tbl_source;

CREATE TABLE dpeweb.tbl_source
(
    sourceid SERIAL NOT NULL,
    sourcename text ,
    createddate timestamp,
    modifieddate timestamp,
    createdby text,
    modifiedby text ,
    CONSTRAINT "tbl_Source_pkey" PRIMARY KEY (sourceid)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE dpeweb.tbl_source
    OWNER TO dpeweb;

	
--------------------------------------------------------------------------------------------2
-- Table: dpeweb.tbl_groups

-- DROP TABLE dpeweb.tbl_groups;

CREATE TABLE dpeweb.tbl_groups
(
    groupid SERIAL NOT NULL,
    groupname text,
    sourceid integer NOT NULL,
    createddate timestamp,
    modifieddate timestamp,
    createdby text,
    modifiedby text,
    CONSTRAINT "GroupID" PRIMARY KEY (groupid),
    CONSTRAINT fksourceid FOREIGN KEY (sourceid)
        REFERENCES dpeweb.tbl_source (sourceid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE dpeweb.tbl_groups
    OWNER TO dpeweb;
--------------------------------------------------------------------------------------------3
-- Table: dpeweb.tbl_documents

-- DROP TABLE dpeweb.tbl_documents;

CREATE TABLE dpeweb.tbl_documents
(
    groupid integer NOT NULL,
    sourceid integer NOT NULL,
    documentid text,
    modifieddate timestamp,
    createddate timestamp,
    createdby text,
    modifiedby text,
    CONSTRAINT "docPrimarykey" PRIMARY KEY (sourceid, documentid, groupid),
    CONSTRAINT fkgroupid FOREIGN KEY (groupid)
        REFERENCES dpeweb.tbl_groups (groupid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fksourceid FOREIGN KEY (sourceid)
        REFERENCES dpeweb.tbl_source (sourceid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE dpeweb.tbl_documents
    OWNER TO dpeweb;
---------------------------------------------------------------------------------------------------4
-- Table: dpeweb.tbl_scripts

-- DROP TABLE dpeweb.tbl_scripts;

CREATE TABLE dpeweb.tbl_scripts
(
    groupid integer NOT NULL,
    scriptid SERIAL NOT NULL,
    sourceid integer NOT NULL,
    scriptname text,
    scriptcontent text,
    modifieddate timestamp,
    createddate timestamp,
    createdby text,
    modifiedby text,
    CONSTRAINT "Scriptd" PRIMARY KEY (scriptid),
    CONSTRAINT groupid FOREIGN KEY (groupid)
        REFERENCES dpeweb.tbl_groups (groupid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT sourceid FOREIGN KEY (sourceid)
        REFERENCES dpeweb.tbl_source (sourceid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE dpeweb.tbl_scripts
    OWNER TO dpeweb;
----------------------------------------------------------------------------------------------------5
-- Table: dpeweb.tbl_meta

-- DROP TABLE dpeweb.tbl_meta;

CREATE TABLE dpeweb.tbl_meta
(
    sourceid integer NOT NULL,
    documentid text NOT NULL,
    content text,
    CONSTRAINT tbl_meta_pkey PRIMARY KEY (sourceid, documentid)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE dpeweb.tbl_meta
    OWNER TO dpeweb;
-----------------------------------------------------------------------------------------------------6
-- Table: dpeweb.tbl_notes

-- DROP TABLE dpeweb.tbl_notes;

CREATE TABLE dpeweb.tbl_notes
(
    pknoteid SERIAL NOT NULL,
    sourceid integer NOT NULL,
    groupid integer NOT NULL,
    notecontent text,
    modifieddate timestamp,
    createddate timestamp,
    createdby text,
    modifiedby text,
    CONSTRAINT pknoteid PRIMARY KEY (pknoteid),
    CONSTRAINT fkgroupid FOREIGN KEY (groupid)
        REFERENCES dpeweb.tbl_groups (groupid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT fksourceid FOREIGN KEY (sourceid)
        REFERENCES dpeweb.tbl_source (sourceid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE dpeweb.tbl_notes
    OWNER TO dpeweb;
----------------------------------------------------------------------------------------------------------7
-- Table: dpeweb.tbl_originals

-- DROP TABLE dpeweb.tbl_originals;

CREATE TABLE dpeweb.tbl_originals
(
    sourceid integer NOT NULL,
    documentid text NOT NULL,
    createddate timestamp,
    modifieddate timestamp,
    createdby text,
    modifiedby text,
    CONSTRAINT tbl_originals_pkey PRIMARY KEY (sourceid, documentid),
    CONSTRAINT fksourceid FOREIGN KEY (sourceid)
        REFERENCES dpeweb.tbl_source (sourceid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE dpeweb.tbl_originals
    OWNER TO dpeweb;

------------------------------------------------------------------------------------------------------8
-- Table: dpeweb.tbl_values

-- DROP TABLE dpeweb.tbl_values;

CREATE TABLE dpeweb.tbl_values
(
    sourceid integer NOT NULL,
    documentid text  NOT NULL,
    datapoint text ,
    value text,
    valuetype text,
    createdby text ,
    createddate timestamp,
    modifiedby text,
    modifieddate timestamp
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE dpeweb.tbl_values
    OWNER to dpeweb;
    
--------------------------------------------------------------------------------------------------------10
-- FUNCTION: dpeweb.udf_clonesource(text, text)

-- DROP FUNCTION dpeweb.udf_clonesource(text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_clonesource(
	p_sourcename text,
	p_userid text)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE v_sourceid integer;

BEGIN
IF Not exists(select sources.sourcename from dpeweb.tbl_source sources where LOWER(sources.sourcename) = LOWER(p_sourcename))
THEN
-- Insert Source
INSERT INTO dpeweb.tbl_source(sourcename,createddate,createdby)	VALUES (p_sourcename, now(), p_userid);
-- get currentids
END IF;
RETURN 'Created';

END;

$BODY$;

ALTER FUNCTION dpeweb.udf_clonesource(text, text)
    OWNER TO dpeweb;

--------------------------------------------------------------------------------------------------------11
-- Table: dpeweb.tbl_document_sets

-- DROP TABLE dpeweb.tbl_document_sets;

CREATE TABLE dpeweb.tbl_document_sets
(
    sourceid integer NOT NULL,
    groupid integer NOT NULL,
    setname text COLLATE pg_catalog."default",
    documentids text COLLATE pg_catalog."default",
    createdby text COLLATE pg_catalog."default",
    createddate timestamp without time zone,
    modifiedby text COLLATE pg_catalog."default",
    modifieddate timestamp without time zone
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE dpeweb.tbl_document_sets
    OWNER to dpeweb;
----------------------------------------------------------------------------------------------------------------1
-- FUNCTION: dpeweb.udf_copyscripts(text, text, text, text)

-- DROP FUNCTION dpeweb.udf_copyscripts(text, text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_copyscripts(
	p_userid text,
	p_sourcename text,
	p_groupname text,
	p_newsourcename text)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
	
	v_newsourceid integer := (SELECT src.sourceid FROM dpeweb.tbl_source src WHERE src.sourcename =p_newsourcename);
   
	v_newgroupid integer := (SELECT grp.groupid FROM dpeweb.tbl_groups grp WHERE grp.groupname =p_groupname  AND grp.sourceid=v_newsourceid);

	 v_oldsourceid integer := (SELECT src.sourceid  FROM dpeweb.tbl_source src   WHERE src.sourcename =p_sourcename);

	 v_oldgroupid integer := (SELECT grp.groupid FROM dpeweb.tbl_groups grp WHERE grp.groupname =p_groupname AND grp.sourceid=v_oldsourceid);

 BEGIN
	delete from dpeweb.tbl_scripts src where  src.sourceid=v_newsourceid and src.groupid=v_newgroupid;
	INSERT INTO dpeweb.tbl_scripts(groupid, sourceid, scriptname, scriptcontent,createddate, createdby)
  select v_newgroupid ,v_newsourceid,st.scriptname , st.scriptcontent ,now(),p_userid from  dpeweb.tbl_scripts st where st.sourceid=v_oldsourceid and st.groupid=v_oldgroupid;
 END;

$BODY$;

ALTER FUNCTION dpeweb.udf_copyscripts(text, text, text, text)
    OWNER TO dpeweb;

--------------------------------------------------------------------------------------------------------------------------------------------------2
-- FUNCTION: dpeweb.udf_creategroup(text, text, text)

-- DROP FUNCTION dpeweb.udf_creategroup(text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_creategroup(
	p_sourcename text,
	p_groupname text,
	p_userid text)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE 
v_sourceid integer;
BEGIN 

 v_sourceid :=
  (SELECT sourceid
   FROM dpeweb.tbl_source src
   WHERE LOWER(src.sourcename) =LOWER(p_sourcename));

IF Not exists(select grp.groupname from dpeweb.tbl_groups grp where grp.sourceid = v_sourceid and LOWER(grp.groupname) = LOWER(p_groupname))
THEN
	INSERT INTO dpeweb.tbl_groups(groupname, sourceid, createddate,createdby)
	VALUES (p_groupname,
        v_sourceid,
        now(),
        p_userid);
	RETURN 'Created';
END IF;
RETURN 'Already Exist';
END;

$BODY$;

ALTER FUNCTION dpeweb.udf_creategroup(text, text, text)
    OWNER TO dpeweb;

-----------------------------------------------------------------------------------------------------------------------------------------------3
-- FUNCTION: dpeweb.udf_createsource(text, text)

-- DROP FUNCTION dpeweb.udf_createsource(text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_createsource(
	p_userid text,
	p_sourcename text)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE 
v_currentsourceId integer;
v_defaultgroupid integer;
begin
IF Not exists(select src.sourcename from dpeweb.tbl_source src where LOWER(src.sourcename) = LOWER(p_sourcename))
THEN
	-- CREATE SOURCE
	INSERT INTO dpeweb.tbl_source(sourcename, createddate,  createdby) VALUES (p_sourcename, now(), p_userid);

	--GET Currentsourceid
	SELECT currval(pg_get_serial_sequence('dpeweb.tbl_source','sourceid')) INTO v_currentsourceId;

	IF Not exists(select grp.groupname from dpeweb.tbl_groups grp where grp.sourceid = v_currentsourceId and grp.groupname = '_default' )
	THEN
		-- create _default group
		INSERT INTO dpeweb.tbl_groups(groupname, sourceid, createddate,createdby)
		VALUES ('_default', v_currentsourceId,now(), p_userid);
	
		-- select current default groupid
		SELECT currval(pg_get_serial_sequence('dpeweb.tbl_groups','groupid')) INTO v_defaultgroupid;
	End If;
	return 'created';
End If;
RETURN 'Already Exist';
end

$BODY$;

ALTER FUNCTION dpeweb.udf_createsource(text, text)
    OWNER TO dpeweb;

--------------------------------------------------------------------------------------------------------------------------------------------4
-- FUNCTION: dpeweb.udf_create_update_notes(text, text, text, text)

-- DROP FUNCTION dpeweb.udf_create_update_notes(text, text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_create_update_notes(
	p_sourcename text,
	p_groupname text,
	p_note text,
	p_userid text)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE v_sourceid integer;
v_groupid integer;

BEGIN v_sourceid :=
  (SELECT sourceid
   FROM dpeweb.tbl_source src
   WHERE src.sourcename =p_sourcename);
v_groupid :=
  (SELECT groupid
   FROM dpeweb.tbl_groups grp
   WHERE grp.groupname =p_groupname
     AND sourceid=v_sourceid);

IF EXISTS
  (SELECT notecontent
   FROM dpeweb.tbl_notes notes
   WHERE sourceid=v_sourceid
     AND groupid=v_groupid) THEN
UPDATE dpeweb.tbl_notes
SET notecontent=p_note,
    modifieddate=now(),
    modifiedby =p_userid
WHERE groupid =v_groupid
  AND sourceid=v_sourceid;

RETURN 1;

ELSE
INSERT INTO dpeweb.tbl_notes (sourceid,groupid,notecontent,createddate,createdby)
VALUES (v_sourceid,
        v_groupid,
        p_note,
        now(),
        p_userid);

RETURN 2;

END IF;

END;

$BODY$;

ALTER FUNCTION dpeweb.udf_create_update_notes(text, text, text, text)
    OWNER TO dpeweb;

--------------------------------------------------------------------------------------------------------------------------------5
-- FUNCTION: dpeweb.udf_deletescript(text, text, text, text)

-- DROP FUNCTION dpeweb.udf_deletescript(text, text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_deletescript(
	p_sourcename text,
	p_groupname text,
	p_scriptname text,
	p_userid text)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE 

getscriptid integer  =(SELECT st.scriptid
   FROM dpeweb.tbl_scripts st
   INNER JOIN dpeweb.tbl_source src ON st.sourceid= src.sourceid
   INNER JOIN dpeweb.tbl_groups grp ON grp.sourceid= st.sourceid
                            and grp.groupid = st.groupid
   WHERE src.sourcename=p_sourcename
     AND grp.groupname=p_groupname
     AND st.scriptname =p_scriptname);
 

  
BEGIN

DELETE
FROM dpeweb.tbl_scripts src
WHERE src.scriptid = getscriptid ;
RETURN 'success';

END;

$BODY$;

ALTER FUNCTION dpeweb.udf_deletescript(text, text, text, text)
    OWNER TO dpeweb;



-------------------------------------------------------------------------------------------------------------------6
-- FUNCTION: dpeweb.udf_getdefaultscriptnames(text, boolean)

-- DROP FUNCTION dpeweb.udf_getdefaultscriptnames(text, boolean);

CREATE OR REPLACE FUNCTION dpeweb.udf_getdefaultscriptnames(
	p_userid text,
	p_status boolean)
    RETURNS text[]
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

  
DECLARE
	list text[] ;
	 i INTEGER := 0 ;	
	 rec RECORD;
    BEGIN    
	
	FOR rec IN SELECT  dfs.scriptname FROM dpeweb.tbl_defaultscriptnames dfs where dfs.status=p_status
   	 LOOP
		list[i] := rec.scriptname;
			i := i+1;
   END LOOP;
	
         RETURN list;
           
     END;

$BODY$;

ALTER FUNCTION dpeweb.udf_getdefaultscriptnames(text, boolean)
    OWNER TO dpeweb;
---------------------------------------------------------------------------------------------------------------7
-- FUNCTION: dpeweb.udf_getdocumentids(text, text, text)

-- DROP FUNCTION dpeweb.udf_getdocumentids(text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_getdocumentids(
	p_userid text,
	p_sourcename text,
	p_groupname text)
    RETURNS text[]
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    DECLARE

	list text[] ;
	 counter INTEGER := 0 ;	
	 i INTEGER := 0 ;	
	 rec RECORD;	
    BEGIN
	
							

  FOR rec IN SELECT  doc.documentid FROM dpeweb.tbl_documents doc  
                                         INNER JOIN dpeweb.tbl_source src ON  
                                         doc.sourceid = src.sourceid  
                                         INNER JOIN dpeweb.tbl_groups grp ON  
                                         grp.groupid = doc.groupid and  
                                         grp.sourceid = doc.sourceid  
                                         where src.sourcename=p_sourcename  and grp.groupname=p_groupname
  LOOP
		list[i] := rec.documentid;
			i := i+1;
	 END LOOP;
      		
			return list;
     END;
	 
$BODY$;

ALTER FUNCTION dpeweb.udf_getdocumentids(text, text, text)
    OWNER TO dpeweb;
--------------------------------------------------------------------------------------------------------------8
-- FUNCTION: dpeweb.udf_getgroupnames(text, text)

-- DROP FUNCTION dpeweb.udf_getgroupnames(text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_getgroupnames(
	p_sourcename text,
	p_userid text)
    RETURNS text[]
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
	list text[] ;
	 counter INTEGER := 0 ;	
	 i INTEGER := 0 ;	
	 rec RECORD;	
    BEGIN
	
  FOR rec IN SELECT  grp.groupname	FROM dpeweb.tbl_groups grp   INNER JOIN dpeweb.tbl_source src ON 
                           grp.sourceid = src.sourceid   where src.sourcename = p_sourcename
  LOOP
		list[i] := rec.groupname;
			i := i+1;
   END LOOP;  		
			return list;
     END;
	 
$BODY$;

ALTER FUNCTION dpeweb.udf_getgroupnames(text, text)
    OWNER TO dpeweb;


-----------------------------------------------------------------------------------------------------------9
-- FUNCTION: dpeweb.udf_getmetaids(text, text)

-- DROP FUNCTION dpeweb.udf_getmetaids(text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_getmetaids(
	p_sourcename text,
	p_userid text)
    RETURNS text[]
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
	
	list text[] ;
	 i INTEGER := 0 ;	
	 rec RECORD;	
    BEGIN 
	FOR rec IN SELECT meta.documentid  FROM dpeweb.tbl_meta meta 
                                            inner join dpeweb.tbl_source src 
                                           on src.sourceid  = meta.sourceid
										where src.sourcename=p_sourcename
	LOOP
		list[i] := rec.documentid;
			i := i+1;
   END LOOP;
   
   return list;
     END;

$BODY$;

ALTER FUNCTION dpeweb.udf_getmetaids(text, text)
    OWNER TO dpeweb;
--------------------------------------------------------------------------------------------------------------10
-- FUNCTION: dpeweb.udf_getoriginalids(text, text)

-- DROP FUNCTION dpeweb.udf_getoriginalids(text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_getoriginalids(
	p_sourcename text,
	p_userid text)
    RETURNS text[]
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
	list text[] ;
	 i INTEGER := 0 ;	
	 rec RECORD;	
    BEGIN 
	FOR rec IN SELECT pdf.documentid  FROM dpeweb.tbl_originals pdf 
                                            inner join dpeweb.tbl_source src 
                                           on src.sourceid  = pdf.sourceid
										where src.sourcename=p_sourcename
	LOOP
		list[i] := rec.documentid;
			i := i+1;
   END LOOP;
   
   return list;
     END;

$BODY$;

ALTER FUNCTION dpeweb.udf_getoriginalids(text, text)
    OWNER TO dpeweb;
--------------------------------------------------------------------------------------------------------------11
-- FUNCTION: dpeweb.udf_getscriptcontent(text, text, text, text)

-- DROP FUNCTION dpeweb.udf_getscriptcontent(text, text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_getscriptcontent(
	p_sourcename text,
	p_groupname text,
	p_scriptname text,
	p_userid text)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE 
v_result text;

BEGIN v_result :=
  (SELECT  srtemp.scriptcontent	FROM dpeweb.tbl_scripts srtemp  
                                                      INNER JOIN dpeweb.tbl_source src ON  
                                                      srtemp.sourceid = src.sourceid  
                                                    INNER JOIN dpeweb.tbl_groups grp ON  
                                                     srtemp.sourceid = grp.sourceid  and  
                                                     grp.groupid = srtemp.groupid  
                                                   where src.sourcename = p_sourcename  and grp.groupname =p_groupname and srtemp.scriptname=p_scriptname);
	 
  --data1 := v_scriptid ;
--RETURN (SELECT  st.scriptcontent as scriptcontent FROM dpeweb.tbl_scripts st where  sourceid=v_sourceid  and groupid=v_groupid and scriptid=v_scriptid) ;
return v_result;

END

$BODY$;

ALTER FUNCTION dpeweb.udf_getscriptcontent(text, text, text, text)
    OWNER TO dpeweb;
---------------------------------------------------------------------------------------------------------------------------------12
-- FUNCTION: dpeweb.udf_getscriptids(text, text, text)

-- DROP FUNCTION dpeweb.udf_getscriptids(text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_getscriptids(
	p_userid text,
	p_sourcename text,
	p_groupname text)
    RETURNS text[]
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    DECLARE

	list text[] ;
	 counter INTEGER := 0 ;	
	 i INTEGER := 0 ;	
	 rec RECORD;
	 recscript RECORD;
    BEGIN	
		FOR rec IN SELECT  srtemp.scriptname	FROM dpeweb.tbl_scripts srtemp  
                                                      INNER JOIN dpeweb.tbl_source src ON  
                                                      srtemp.sourceid = src.sourceid  
                                                     INNER JOIN dpeweb.tbl_groups grp ON  
                                                     srtemp.sourceid = grp.sourceid  and  
                                                     grp.groupid = srtemp.groupid  
                                                   where src.sourcename = p_sourcename  and grp.groupname =p_groupname
  		LOOP
				list[i] := rec.scriptname;
				i := i+1;
   END LOOP;
   
	return list;
END;

$BODY$;

ALTER FUNCTION dpeweb.udf_getscriptids(text, text, text)
    OWNER TO dpeweb;
-----------------------------------------------------------------------------------------------------------------------------------13
-- FUNCTION: dpeweb.udf_getsourcenames(text)

-- DROP FUNCTION dpeweb.udf_getsourcenames(text);

CREATE OR REPLACE FUNCTION dpeweb.udf_getsourcenames(
	p_userid text)
    RETURNS text[]
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

   
DECLARE
	list text[] ;
	 i INTEGER := 0 ;	
	 rec RECORD;
    BEGIN    
	
	FOR rec IN SELECT sourcename FROM dpeweb.tbl_source
   	 LOOP
		list[i] := rec.sourcename;
			i := i+1;
   END LOOP;
	
         RETURN list;
           
     END;

$BODY$;

ALTER FUNCTION dpeweb.udf_getsourcenames(text)
    OWNER TO dpeweb;
------------------------------------------------------------------------------------------------------------------------------------14
-- FUNCTION: dpeweb.udf_gettxtids(text, text)

-- DROP FUNCTION dpeweb.udf_gettxtids(text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_gettxtids(
	p_sourcename text,
	p_userid text)
    RETURNS text[]
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
	list text[] ;
	 i INTEGER := 0 ;	
	 rec RECORD;
    BEGIN    
FOR rec IN SELECT doctxt.documentid  FROM dpeweb.tbl_documents doctxt 
                                            inner join dpeweb.tbl_source src 
                                           on src.sourceid  = doctxt.sourceid
										where src.sourcename=p_sourcename
   	 LOOP
		--RAISE NOTICE '%', rec.datapoint;
		--RAISE NOTICE '%', rec.values;
		list[i] := rec.documentid;
			i := i+1;
		--RAISE NOTICE '%', rec.datapoint;
   END LOOP;
	
         RETURN list;
           
     END;

$BODY$;

ALTER FUNCTION dpeweb.udf_gettxtids(text, text)
    OWNER TO dpeweb;
----------------------------------------------------------------------------------------------------------------------------------15
-- FUNCTION: dpeweb.udf_readnotes(text, text, text)

-- DROP FUNCTION dpeweb.udf_readnotes(text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_readnotes(
	p_userid text,
	p_sourcename text,
	p_groupname text)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

    DECLARE
	v_notes text;

	list text[] ;
	 counter INTEGER := 0 ;	
	 i INTEGER := 0 ;	
	 rec RECORD;	
    BEGIN
	
							
 v_notes := (SELECT note.notecontent from dpeweb.tbl_notes note  
                                                inner join  dpeweb.tbl_source src  
                                               on note.sourceid = src.sourceid  
                                               inner join dpeweb.tbl_groups grp  
                                               on grp.sourceid = note.sourceid  and  
                                                note.groupid = grp.groupid  
                                                where src.sourcename =p_sourcename and grp.groupname=p_groupname);
   
							
							
        		
			return v_notes;
     END;
	 
	 

$BODY$;

ALTER FUNCTION dpeweb.udf_readnotes(text, text, text)
    OWNER TO dpeweb;
-------------------------------------------------------------------------------------------------------------------------------------20
-- FUNCTION: dpeweb.udf_renamegroup(text, text, text, text)

-- DROP FUNCTION dpeweb.udf_renamegroup(text, text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_renamegroup(
	p_sourcename text,
	p_groupname text,
	p_newgroupname text,
	p_userid text)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE DECLARE 
v_groupid integer;
v_sourceid integer;

BEGIN 

v_sourceid :=  (SELECT sourceid  FROM dpeweb.tbl_source src  WHERE LOWER(src.sourcename) =LOWER(p_sourcename));

v_groupid :=  (select grp.groupid from dpeweb.tbl_groups grp where grp.sourceid= v_sourceid and LOWER(grp.groupname) =LOWER(p_groupname));

IF Not exists(SELECT groupname From dpeweb.tbl_groups where sourceid =v_sourceid and groupname = p_newgroupname) THEN

UPDATE dpeweb.tbl_groups
SET groupname=p_newgroupname,
    modifiedby =p_userid,
    modifieddate=now()
WHERE groupid =v_groupid;

RETURN 1;
END IF;
RETURN 0;

END;

$BODY$;

ALTER FUNCTION dpeweb.udf_renamegroup(text, text, text, text)
    OWNER TO dpeweb;
---------------------------------------------------------------------------------------------------------------------------------------21
-- FUNCTION: dpeweb.udf_renamescript(text, text, text, text, text)

-- DROP FUNCTION dpeweb.udf_renamescript(text, text, text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_renamescript(
	p_sourcename text,
	p_groupname text,
	p_previousscriptname text,
	p_newscriptname text,
	p_userid text)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE
v_scriptid integer;
v_sourceid integer;
v_groupid integer;

BEGIN

 v_sourceid :=  (SELECT sourceid  FROM dpeweb.tbl_source src  WHERE LOWER(src.sourcename) =LOWER(p_sourcename));

v_groupid :=  (select grp.groupid from dpeweb.tbl_groups grp where grp.sourceid= v_sourceid and LOWER(grp.groupname) =LOWER(p_groupname));

v_scriptid := (SELECT  srtemp.scriptid	FROM dpeweb.tbl_scripts srtemp where  srtemp.sourceid = v_sourceid  and  srtemp.groupid = v_groupid and LOWER(srtemp.scriptname) = LOWER(p_previousscriptname));

IF Not exists(SELECT sc.scriptname From dpeweb.tbl_scripts sc where sc.sourceid =v_sourceid and sc.groupid = v_groupid and sc.scriptname =  p_newscriptname) THEN
	UPDATE dpeweb.tbl_scripts
	SET scriptname=p_newscriptname,
    	modifieddate=now(),
    	modifiedby =p_userid
	WHERE scriptid = v_scriptid ;

RETURN 'success';
END IF;
END;

$BODY$;

ALTER FUNCTION dpeweb.udf_renamescript(text, text, text, text, text)
    OWNER TO dpeweb;
---------------------------------------------------------------------------------------------------------------------------------------------22
-- FUNCTION: dpeweb.udf_savescript(text, text, text, text, text)

-- DROP FUNCTION dpeweb.udf_savescript(text, text, text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_savescript(
	p_userid text,
	p_sourcename text,
	p_groupname text,
	p_scriptname text,
	p_scriptcontent text)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE DECLARE 
v_sourceid integer;
v_groupid integer;

BEGIN v_sourceid :=
  (SELECT sourceid
   FROM dpeweb.tbl_source src
   WHERE src.sourcename =p_sourcename);
v_groupid :=
  (SELECT groupid
   FROM dpeweb.tbl_groups grp
   WHERE grp.groupname =p_groupname
     AND grp.sourceid=v_sourceid);

IF EXISTS
  (SELECT st.scriptname
   FROM dpeweb.tbl_scripts st
   WHERE st.sourceid=v_sourceid
     AND st.groupid=v_groupid
     AND st.scriptname=p_scriptname) THEN
UPDATE dpeweb.tbl_scripts st
SET scriptcontent=p_scriptcontent,
    modifieddate=now(),
    modifiedby =p_userid
WHERE st.groupid =v_groupid
  AND st.sourceid=v_sourceid
  AND st.scriptname=p_scriptname ;

RETURN 1;

ELSE
INSERT INTO dpeweb.tbl_scripts(groupid, sourceid, scriptname, scriptcontent,createddate,createdby)
VALUES (v_groupid,
        v_sourceid,
        p_scriptname,
        p_scriptcontent,
        now(),
        p_userid);

RETURN 2;

END IF;

END;

$BODY$;

ALTER FUNCTION dpeweb.udf_savescript(text, text, text, text, text)
    OWNER TO dpeweb;

-----------------------------------------------------------------------------------------------------------------------------------------23
-- FUNCTION: dpeweb.udf_setdocumentgroup(text, text, text, text)

-- DROP FUNCTION dpeweb.udf_setdocumentgroup(text, text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_setdocumentgroup(
	p_sourcename text,
	p_documentid text,
	p_groupname text,
	p_userid text)
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE 
v_sourceid integer; 
v_groupid integer;
p_count text ;
p_removedocid integer;
BEGIN v_sourceid :=
  (SELECT sourceid 
   FROM dpeweb.tbl_source src
   WHERE src.sourcename =p_sourcename);
v_groupid :=
  (SELECT grp.groupid
   FROM dpeweb.tbl_groups grp
   WHERE grp.groupname =p_groupname
     AND grp.sourceid=v_sourceid);
IF  (p_groupname !='_default') 
THEN 

     p_removedocid := (SELECT grp.groupid
   FROM dpeweb.tbl_groups grp
   inner join dpeweb.tbl_documents doc on
   doc.groupid = grp.groupid
   WHERE grp.groupname ='_default' and doc.documentid =p_documentid and  grp.sourceid =v_sourceid) ;
   IF(p_removedocid >0)
   THEN
	
   delete from dpeweb.tbl_documents doc  where doc.sourceid=v_sourceid and  doc.groupid = p_removedocid and  doc.documentid =p_documentid;
	INSERT into dpeweb.tbl_documents(groupid, sourceid, documentid, createddate, createdby)	VALUES (v_groupid, v_sourceid, p_documentid,now(),p_userid);
	 RETURN    'document moved from _default';
   ELSE
   IF NOT EXISTS(SELECT * FROM dpeweb.tbl_documents doc WHERE doc.sourceid=v_sourceid AND doc.groupid =v_groupid AND doc.documentid = p_documentid)
  THEN
   INSERT INTO dpeweb.tbl_documents(
	groupid, sourceid, documentid,createddate, createdby)
	VALUES (v_groupid, v_sourceid,p_documentid,now(),p_userid);
   RETURN    'document inserted';
    ELSE
    RETURN 'Alraedy inserted';
	END IF;
   END IF ;
ELSE
 p_removedocid := (SELECT grp.groupid
   FROM dpeweb.tbl_groups grp
   inner join dpeweb.tbl_documents doc on
   doc.groupid = grp.groupid
   WHERE grp.groupname !='_default' and doc.documentid =p_documentid and  grp.sourceid =v_sourceid) ;
   IF(p_removedocid >0)
   THEN
   delete from dpeweb.tbl_documents doc  where doc.sourceid=v_sourceid and  doc.groupid = p_removedocid and  doc.documentid =p_documentid;
	INSERT into dpeweb.tbl_documents(groupid, sourceid, documentid, createddate, createdby)	VALUES (v_groupid, v_sourceid, p_documentid,now(),p_userid);
	 RETURN    'document moved to _default';
  ELSE
  IF NOT EXISTS(SELECT * FROM dpeweb.tbl_documents doc WHERE doc.sourceid=v_sourceid AND doc.groupid =v_groupid AND doc.documentid = p_documentid)
  THEN
     INSERT INTO dpeweb.tbl_documents(
	groupid, sourceid, documentid,createddate, createdby)
	VALUES (v_groupid, v_sourceid,p_documentid,now(),p_userid);
   RETURN    'document inserted';
   ELSE
    RETURN 'Alraedy inserted';
	END IF;
   END IF;
END IF;
END 

$BODY$;

ALTER FUNCTION dpeweb.udf_setdocumentgroup(text, text, text, text)
    OWNER TO dpeweb;



-----------------------------------------------------------------------------------------------------------------------------------------24
-- FUNCTION: dpeweb.udf_writedocument(text, text, text)

-- DROP FUNCTION dpeweb.udf_writedocument(text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_writedocument(
	p_userid text,
	p_sourcename text,
	p_documentid text)
    RETURNS integer
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE 
v_sourceid integer;
v_groupid Integer ;

BEGIN 

 	v_sourceid :=(SELECT sourceid FROM dpeweb.tbl_source src WHERE src.sourcename =p_sourcename);
    v_groupid := (select groupid  from dpeweb.tbl_groups where sourceid = v_sourceid and groupname = '_default');

IF NOT EXISTS (SELECT org.documentid FROM dpeweb.tbl_documents org WHERE org.sourceid=v_sourceid and org.groupid = v_groupid and org.documentid =p_documentid  ) THEN
	INSERT INTO dpeweb.tbl_documents(groupid, sourceid, documentid, createddate, createdby)
							  VALUES(v_groupid, v_sourceid, p_documentid, now(), p_userid);
  RETURN 1;

END IF;

END;

$BODY$;

ALTER FUNCTION dpeweb.udf_writedocument(text, text, text)
    OWNER TO dpeweb;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------26
-- FUNCTION: dpeweb.udf_writeoriginal(text, text, text[])

-- DROP FUNCTION dpeweb.udf_writeoriginal(text, text, text[]);

CREATE OR REPLACE FUNCTION dpeweb.udf_writeoriginal(
	p_userid text,
	p_sourcename text,
	p_originalids text[])
    RETURNS text
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE 
	v_sourceid integer;
	v_originalid text;
 	counter INTEGER := 0 ;
	v_arraylen int;
begin
		v_sourceid :=
  (SELECT sourceid
   FROM dpeweb.tbl_source src
   WHERE src.sourcename =p_sourcename);
	v_arraylen := array_length(p_originalids,1);
	IF ((v_sourceid > 0) and (v_arraylen > 0 ))  THEN
		FOR Counter in array_lower(p_originalids, 1) .. array_upper(p_originalids, 1)
		LOOP
			v_originalid := p_originalids[Counter];
			IF Not exists(SELECT vl.documentid From dpeweb.tbl_originals vl where vl.sourceid =v_sourceid and vl.documentid = v_originalid) THEN
				INSERT INTO dpeweb.tbl_originals(sourceid, documentid, createddate, createdby)
		    	VALUES (v_sourceid, v_originalid,now(),p_userid);		
			END IF;	
		END LOOP;
	END IF;
return 'created';
END

$BODY$;

ALTER FUNCTION dpeweb.udf_writeoriginal(text, text, text[])
    OWNER TO dpeweb;
---------------------------------------------------------------------------------------------------------------
-- FUNCTION: dpeweb.udf_delete_column_values(integer, text, text[])

-- DROP FUNCTION dpeweb.udf_delete_column_values(integer, text, text[]);

CREATE OR REPLACE FUNCTION dpeweb.udf_delete_column_values(
	p_sourceid integer,
	p_datapoint text,
	p_documentids text[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE DECLARE 
	counter INTEGER := 0 ;
	v_arraylen int;
	v_documentid text;
 BEGIN 
 
  v_arraylen := array_length(p_documentids,1);
	IF ((p_sourceid > 0) and (v_arraylen > 0 ))  THEN
		FOR Counter in array_lower(p_documentids, 1) .. array_upper(p_documentids, 1)
		LOOP
			v_documentid := p_documentids[Counter];
			IF exists(SELECT vl.datapoint From dpeweb.tbl_values vl where vl.sourceid =p_sourceid and vl.documentid = v_documentid and vl.datapoint = p_datapoint) THEN
				delete from dpeweb.tbl_values vs where vs.sourceid =p_sourceid and vs.documentid = v_documentid and vs.datapoint = p_datapoint;
			END IF;	
		END LOOP;
    END IF;
END;

$BODY$;

ALTER FUNCTION dpeweb.udf_delete_column_values(integer, text, text[])
    OWNER TO dpeweb;

----------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION: dpeweb.udf_create_column_values(text, integer, text, text[], text[], text[])

-- DROP FUNCTION dpeweb.udf_create_column_values(text, integer, text, text[], text[], text[]);

CREATE OR REPLACE FUNCTION dpeweb.udf_create_column_values(
	p_userid text,
	p_sourceid integer,
	p_datapoint text,
	p_documentids text[],
	p_value text[],
	p_valuetypes text[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

   BEGIN 
 		INSERT INTO dpeweb.tbl_values(sourceid, documentid, datapoint, value, valuetype, createdby, createddate)
		SELECT * FROM (
    					SELECT p_sourceid,
    					UNNEST(p_documentids) AS v_documentid, 
   						p_datapoint, 
    					UNNEST(p_value),
						UNNEST(p_valuetypes),
						p_userid, 
						now()
					) AS temptable
					WHERE NOT EXISTS (
    							SELECT 1 FROM dpeweb.tbl_values vl
    							WHERE vl.sourceid =temptable.p_sourceid and vl.documentid = temptable.v_documentid and vl.datapoint = temptable.p_datapoint
					);

	END;

$BODY$;

ALTER FUNCTION dpeweb.udf_create_column_values(text, integer, text, text[], text[], text[])
    OWNER TO dpeweb;


------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION: dpeweb.udf_update_column_values(text, integer, text, text[], text[], text[])

-- DROP FUNCTION dpeweb.udf_update_column_values(text, integer, text, text[], text[], text[]);

CREATE OR REPLACE FUNCTION dpeweb.udf_update_column_values(
	p_userid text,
	p_sourceid integer,
	p_datapoint text,
	p_documentids text[],
	p_value text[],
	p_valuetypes text[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

BEGIN 

UPDATE dpeweb.tbl_values as vl
SET 
documentid=temptable.v_documentid,
datapoint = temptable.p_datapoint,
value = temptable.v_value,
valuetype = temptable.v_valuetypes,
modifiedby=temptable.p_userid, 
modifieddate=temptable.modifydate
FROM (
	SELECT UNNEST(p_documentids) as v_documentid, 
			p_datapoint, 
     		UNNEST(p_value) as v_value,
            UNNEST(p_valuetypes) as v_valuetypes,
			p_userid,
			now() as modifydate
) AS temptable
WHERE vl.sourceid = p_sourceid and vl.documentid=temptable.v_documentid and vl.datapoint = temptable.p_datapoint;

END;

$BODY$;

ALTER FUNCTION dpeweb.udf_update_column_values(text, integer, text, text[], text[], text[])
    OWNER TO dpeweb;

-------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION: dpeweb.udf_document_sets(text, text, text, text, text[])

-- DROP FUNCTION dpeweb.udf_document_sets(text, text, text, text, text[]);

CREATE OR REPLACE FUNCTION dpeweb.udf_document_sets(
	p_userid text,
	p_sourcename text,
	p_groupname text,
	p_tableid text,
	p_documentids text[])
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

 DECLARE 
v_sourceid integer;
v_groupid Integer ;

BEGIN
v_sourceid :=(SELECT sourceid FROM dpeweb.tbl_source src WHERE src.sourcename =p_sourcename);
v_groupid := (select groupid  from dpeweb.tbl_groups where sourceid = v_sourceid and groupname = p_groupname);

delete from dpeweb.tbl_document_sets ds where ds.sourceid=v_sourceid and ds.groupid=v_groupid;

INSERT INTO dpeweb.tbl_document_sets(sourceid, groupid, setname, documentids, createdby, createddate)
values( v_sourceid,
		v_groupid,
		p_tableId,
    	UNNEST(p_documentids), 
    	p_userid, 
		now()
);

END;

$BODY$;

ALTER FUNCTION dpeweb.udf_document_sets(text, text, text, text, text[])
    OWNER TO dpeweb;

-----------------------------------------------------------------------------------------------------------------------------
-- FUNCTION: dpeweb.udf_document_gets(text, text, text, text)

-- DROP FUNCTION dpeweb.udf_document_gets(text, text, text, text);

CREATE OR REPLACE FUNCTION dpeweb.udf_document_gets(
	p_userid text,
	p_sourcename text,
	p_groupname text,
	p_tableid text)
    RETURNS text[]
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

 DECLARE 
v_sourceid integer;
v_groupid Integer ;
list text[] ;
i INTEGER := 0 ;	
rec RECORD;

BEGIN
v_sourceid :=(SELECT sourceid FROM dpeweb.tbl_source src WHERE src.sourcename =p_sourcename);
v_groupid := (select groupid  from dpeweb.tbl_groups where sourceid = v_sourceid and groupname = p_groupname);

FOR rec IN SELECT  tds.documentids	FROM dpeweb.tbl_document_sets tds  where tds.sourceid = v_sourceid and tds.groupid = v_groupid and tds.setname = p_tableId
  LOOP
		list[i] := rec.documentids;
			i := i+1;
   END LOOP;
return list;

END;

$BODY$;

ALTER FUNCTION dpeweb.udf_document_gets(text, text, text, text)
    OWNER TO dpeweb;

----------------------------------------------------------------------------------------------------------------------
-- FUNCTION: dpeweb.udf_writeoriginalid(text, text, text)

-- DROP FUNCTION dpeweb.udf_writeoriginalid(text, text, text);


CREATE  FUNCTION dpeweb.udf_writeoriginalid(
	p_userid text,
	p_sourcename text,
	p_originalids text)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS 
$BODY$

DECLARE 
	v_sourceid integer;
begin
	   v_sourceid :=(SELECT sourceid   FROM dpeweb.tbl_source src   WHERE src.sourcename =p_sourcename);
	   IF ((v_sourceid > 0) )  
	   THEN
		  IF Not exists(SELECT vl.documentid From dpeweb.tbl_originals vl where vl.sourceid =v_sourceid and vl.documentid = p_originalids) THEN
				INSERT INTO dpeweb.tbl_originals(sourceid, documentid, createddate, createdby)
		    	                         VALUES (v_sourceid, p_originalids,now(),p_userid);		
			
	   END IF;
	   END IF;
return 'created';
END
$BODY$;

ALTER FUNCTION dpeweb.udf_writeoriginalid(text, text, text)
    OWNER TO dpeweb;

-----------------------------------------------------------------------------------------------------------------------

-- Add default script names
INSERT INTO dpeweb.tbl_defaultscriptnames(	scriptname, createddate,status)	VALUES ('_filter', now(),true);
INSERT INTO dpeweb.tbl_defaultscriptnames(	scriptname, createddate,status)	VALUES ('Language', now(),false);
INSERT INTO dpeweb.tbl_defaultscriptnames(	scriptname, createddate,status)	VALUES ('Country', now(),false);
INSERT INTO dpeweb.tbl_defaultscriptnames(	scriptname, createddate,status)	VALUES ('ProductName', now(),false);
INSERT INTO dpeweb.tbl_defaultscriptnames(	scriptname, createddate,status)	VALUES ('IssueDate', now(),true);
INSERT INTO dpeweb.tbl_defaultscriptnames(	scriptname, createddate,status)	VALUES ('Version', now(),false);
INSERT INTO dpeweb.tbl_defaultscriptnames(	scriptname, createddate,status)	VALUES ('Catalog', now(),true);
INSERT INTO dpeweb.tbl_defaultscriptnames(	scriptname, createddate,status)	VALUES ('ManNumber', now(),false);
INSERT INTO dpeweb.tbl_defaultscriptnames(	scriptname, createddate,status)	VALUES ('Manufacturer', now(),true);

---------------------------------------------------------------------------------------------------------------
-- View: dpeweb.view_documentdata

-- DROP VIEW dpeweb.view_documentdata;

CREATE OR REPLACE VIEW dpeweb.view_documentdata AS
 SELECT row_number() OVER (ORDER BY sc.documentid) AS sno,
    sc.sourceid,
    sc.groupid,
    so.sourcename,
    sg.groupname,
    sc.documentid,
    sc.createddate,
    sc.createdby
   FROM dpeweb.tbl_documents sc
     JOIN dpeweb.tbl_source so ON sc.sourceid = so.sourceid
     JOIN dpeweb.tbl_groups sg ON sc.groupid = sg.groupid;

ALTER TABLE dpeweb.view_documentdata
    OWNER TO dpeweb;

---------------------------------------------------------------------------------------------------------------
-- View: dpeweb.view_documentdataweek

-- DROP VIEW dpeweb.view_documentdataweek;

CREATE OR REPLACE VIEW dpeweb.view_documentdataweek AS
 SELECT row_number() OVER (ORDER BY sc.documentid) AS sno,
    sc.sourceid,
    sc.groupid,
    so.sourcename,
    sg.groupname,
    sc.documentid,
    sc.createddate::timestamp::date AS createddate,
    sc.createdby
   FROM dpeweb.tbl_documents sc
     JOIN dpeweb.tbl_source so ON sc.sourceid = so.sourceid
     JOIN dpeweb.tbl_groups sg ON sc.groupid = sg.groupid
  WHERE sc.createddate >= (now()::timestamp::date - 7) AND sc.createddate <= (now()::timestamp::date + 1);

ALTER TABLE dpeweb.view_documentdataweek
    OWNER TO dpeweb;
---------------------------------------------------------------------------------------------------------------
-- View: dpeweb.view_scriptsdata

-- DROP VIEW dpeweb.view_scriptsdata;

CREATE OR REPLACE VIEW dpeweb.view_scriptsdata AS
 SELECT row_number() OVER (ORDER BY sc.scriptname) AS sno,
    sc.scriptid,
    so.sourcename,
    sg.groupname,
    sc.scriptname,
    sc.createddate,
    sc.createdby
   FROM dpeweb.tbl_scripts sc
     JOIN dpeweb.tbl_source so ON sc.sourceid = so.sourceid
     JOIN dpeweb.tbl_groups sg ON sc.groupid = sg.groupid;

ALTER TABLE dpeweb.view_scriptsdata
    OWNER TO dpeweb;



---------------------------------------------------------------------------------------------------------------
-- View: dpeweb.view_scriptsdataweek

-- DROP VIEW dpeweb.view_scriptsdataweek;

CREATE OR REPLACE VIEW dpeweb.view_scriptsdataweek AS
 SELECT row_number() OVER (ORDER BY sc.scriptname) AS sno,
    sc.scriptid,
    so.sourcename,
    sg.groupname,
    sc.scriptname,
    sc.createddate::timestamp::date AS createddate,
    sc.createdby
   FROM dpeweb.tbl_scripts sc
     JOIN dpeweb.tbl_source so ON sc.sourceid = so.sourceid
     JOIN dpeweb.tbl_groups sg ON sc.groupid = sg.groupid
  WHERE sc.createddate >= (now()::timestamp::date - 7) AND sc.createddate <= (now()::timestamp::date + 1);

ALTER TABLE dpeweb.view_scriptsdataweek
    OWNER TO dpeweb;



---------------------------------------------------------------------------------------------------------------
-- View: dpeweb.view_notes

-- DROP VIEW dpeweb.view_notes;

CREATE OR REPLACE VIEW dpeweb.view_notes AS
 SELECT notes.pknoteid,
    source.sourcename,
    groups.groupname,
    notes.notecontent,
    notes.createddate::timestamp::date AS createddate,
        CASE
            WHEN groups.groupname::text = '_default'::text THEN 'Global'::text
            ELSE 'Group'::text
        END AS notetype
   FROM dpeweb.tbl_notes notes
     JOIN dpeweb.tbl_source source ON notes.sourceid = source.sourceid
     JOIN dpeweb.tbl_groups groups ON notes.groupid = groups.groupid;

ALTER TABLE dpeweb.view_notes
    OWNER TO dpeweb;



---------------------------------------------------------------------------------------------------------------



