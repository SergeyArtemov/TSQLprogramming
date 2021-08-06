if object_id('tempdb..#product') is not null drop table #product;

create table #product 
([id] int  not null
,[parentid] int null
,[qty] int not null
,[name] varchar(100) not null);

insert into #product([id],[parentid],[qty],[name])
select 1,null,1,'Изделие'
union select 2,1,2,'Деталь А'
union select 3,1,1,'Сборка А'
union select 4,2,3,'Материал А'
union select 5,2,2,'Заготовка А'
union select 6,3,1,'Деталь Б'
union select 7,5,3,'Материал Б'
union select 8,5,4,'Материал В'
union select 9,6,5,'Материал А'
union select 10,6,3,'Заготовка Б'
union select 11,6,2,'Заготовка В'
union select 12,10,10,'Материал Г'
union select 13,10,1,'Материал Д'
union select 14,11,4,'Материал Е';

-- 1ый запрос: "Сборка, начиная с определенного наименования (с накоплением кол-ва)"
declare
@name varchar(100) = 'Изделие';	-- "наименование" - входное значение для запроса №1

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




-- 2ой запрос: "Выборка по заданному уровню"
declare
@lev int = 3;-- "уровень" - входное значение для запроса #2

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