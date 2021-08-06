if object_id('tempdb..#product') is not null drop table #product;

create table #product 
([id] int  not null
,[parentid] int null
,[qty] int not null
,[name] varchar(100) not null);

insert into #product([id],[parentid],[qty],[name])
select 1,null,1,'�������'
union select 2,1,2,'������ �'
union select 3,1,1,'������ �'
union select 4,2,3,'�������� �'
union select 5,2,2,'��������� �'
union select 6,3,1,'������ �'
union select 7,5,3,'�������� �'
union select 8,5,4,'�������� �'
union select 9,6,5,'�������� �'
union select 10,6,3,'��������� �'
union select 11,6,2,'��������� �'
union select 12,10,10,'�������� �'
union select 13,10,1,'�������� �'
union select 14,11,4,'�������� �';

-- 1�� ������: "������, ������� � ������������� ������������ (� ����������� ���-��)"
declare
@name varchar(100) = '�������';	-- "������������" - ������� �������� ��� ������� �1

with assembl(id, [name], parentid, qty, [level], [path], fullqty) 
as(
select id, [name], parentid, qty,0, cast('' as varchar(500)), 1 fullqty  
	from #product p 
	where [name] = @name
union all
select p.id, p.[name], p.parentid, p.qty, a.[level]+1, cast(a.[path] +'.' + cast(a.id as varchar) as varchar(500)) , a.fullqty*p.qty fullqty 
	from #product p inner join assembl a
	on p.parentid = a.id
) 
select id, [name],parentid, qty, assembl.[level] ,assembl.[path], fullqty
	from assembl 
	order by [level], parentid;




-- 2�� ������: "������� �� ��������� ������"
declare
@lev int = 3;-- "�������" - ������� �������� ��� ������� #2

with assembl(id, [name], parentid, qty, [level], [path], fullqty) 
as(
select id, [name], parentid, qty,0, cast('' as varchar(500)), 1 fullqty  
	from #product p 
	where [parentid] is null
union all
select p.id, p.[name], p.parentid, p.qty, a.[level]+1, cast(a.[path] +'.' + cast(a.id as varchar)  as varchar(500)) , a.fullqty*p.qty fullqty 
	from #product p inner join assembl a
	on p.parentid = a.id
) 
select id, [name], parentid, qty, assembl.[level] ,assembl.[path], fullqty
	from assembl 
	where [level] = @lev
	order by parentid;