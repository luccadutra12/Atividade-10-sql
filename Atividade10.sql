 create database aeronautica_db;
go

use aeronautica_db;
go

create table materiais (
    id int identity(1,1) primary key,
    nome varchar(250) not null,
    descricao varchar(max),
    medida varchar(25) not null,
    estoque_minimo int default 0,
    ativo int not null default 1
);
go

create table fornecedores (
    id int identity(1,1) primary key,
    nome varchar(250) not null,
    contato varchar(250),
    telefone varchar(25),
    ativo int not null default 1
);
go

create table entradas (
    id int identity(1,1) primary key,
    id_material int not null,
    id_fornecedor int not null,
    data_entrada date not null,
    quantidade int not null,
    preco decimal(10,2) not null,
    nota_fiscal varchar(50),
    foreign key (id_material) references materiais(id),
    foreign key (id_fornecedor) references fornecedores(id)
);
go

create table saidas (
    id int identity(1,1) primary key,
    id_material int not null,
    data_saida date not null,
    quantidade int not null,
    destino varchar(50),
    foreign key (id_material) references materiais(id)
);
go

select name
from sys.tables;

insert into materiais
    (nome, descricao, medida, estoque_minimo, ativo)
values
('chapa de alumínio', 'chapa de alumínio de liga 6061-t6', 'm²', 100, 1),
('tubo de titânio', 'tubo de titânio grau 5', 'm', 50, 1),
('parafuso de aço inoxidável', 'parafuso de aço inoxidável aisi 316', 'unidade', 200, 1),
('fio de cobre', 'fio de cobre esmaltado', 'm', 150, 1),
('rebite de alumínio', 'rebite de alumínio sólido', 'unidade', 300, 1),
('chapa de fibra de carbono', 'chapa de fibra de carbono pré-impregnada', 'm²', 80, 1),
('resina epóxi', 'resina epóxi para laminação', 'kg', 40, 1),
('tecido de fibra de vidro', 'tecido de fibra de vidro para laminação', 'm²', 120, 1),
('pintura poliuretânica', 'pintura poliuretânica para aeronaves', 'l', 30, 1),
('adesivo estrutural', 'adesivo estrutural de alta resistência', 'kg', 25, 1);
go

select * from materiais;
go

insert into fornecedores
    (nome, contato, telefone, ativo)
values
('aerometalúrgica do sudeste', 'joão silva', '(11) 9999-9999', 1),
('titânio do brasil', 'maria souza', '(21) 3333-3333', 1),
('fixadores industriais', 'pedro santos', '(31) 2222-2222', 1),
('condutor elétrico', 'ana oliveira', '(41) 5555-5555', 1),
('rebites e fixadores', 'carlos rodrigues', '(19) 8888-8888', 1),
('fibra & carbono technology', 'juliana almeida', '(11) 4444-4444', 1),
('epoxi & compostos', 'roberto mendes', '(27) 7777-7777', 1),
('fibra de vidro do brasil', 'fernanda costa', '(48) 6666-6666', 1),
('tintas aeronáuticas', 'marcelo santos', '(11) 2222-2222', 1),
('adesivos especiais', 'patricia lima', '(47) 9999-9999', 1);
go

select * from fornecedores;
go


create procedure registrar_entrada
    @p_id_material int,
    @p_id_fornecedor int,
    @p_data_entrada date,
    @p_quantidade int,
    @p_preco decimal(10,2),
    @p_nota_fiscal varchar(50)
as
begin
    insert into entradas (
        id_material,
        id_fornecedor,
        data_entrada,
        quantidade,
        preco,
        nota_fiscal
    )
    values (
        @p_id_material,
        @p_id_fornecedor,
        @p_data_entrada,
        @p_quantidade,
        @p_preco,
        @p_nota_fiscal
    );
end;
go


exec registrar_entrada 1, 1, '2023-10-25', 100, 5.50, 'nf001';
exec registrar_entrada 2, 2, '2023-10-26', 50, 12.00, 'nf002';
exec registrar_entrada 7, 7, '2023-10-27', 40, 18.90, 'nf150';
go

select * from entradas;
go


create procedure registrar_saida
    @p_id_material int,
    @p_data_saida date,
    @p_quantidade int,
    @p_destino varchar(50)
as
begin
    insert into saidas (
        id_material,
        data_saida,
        quantidade,
        destino
    )
    values (
        @p_id_material,
        @p_data_saida,
        @p_quantidade,
        @p_destino
    );
end;
go


exec registrar_saida 3, '2023-11-01', 50, 'op003';
exec registrar_saida 6, '2023-11-05', 20, 'op010';
go

select * from saidas;
go


create procedure inativar_material
    @p_id_material int
as
begin
    update materiais
    set ativo = 0
    where id = @p_id_material;
end;
go


exec inativar_material 4;
exec inativar_material 10;
go

select id, nome, ativo
from materiais
where id in (4, 10);
go


create procedure inativar_fornecedor
    @p_id_fornecedor int
as
begin
    update fornecedores
    set ativo = 0
    where id = @p_id_fornecedor;
end;
go


exec inativar_fornecedor 4;
exec inativar_fornecedor 10;
go

select id, nome, ativo
from fornecedores
where id in (4, 10);
go

create function calcular_estoque (@p_id_material int)
returns int
as
begin
    declare @total_entradas int = 0;
    declare @total_saidas int = 0;

    select @total_entradas = isnull(sum(quantidade), 0)
    from entradas
    where id_material = @p_id_material;

    select @total_saidas = isnull(sum(quantidade), 0)
    from saidas
    where id_material = @p_id_material;

    return @total_entradas - @total_saidas;
end;
go

select dbo.calcular_estoque(1) as estoque_material_1;
select dbo.calcular_estoque(2) as estoque_material_2;
select dbo.calcular_estoque(7) as estoque_material_7;
go

create view consultar_estoque
as
select
    id,
    nome,
    medida,
    estoque_minimo,
    dbo.calcular_estoque(id) as estoque_atual
from materiais;
go

select *
from consultar_estoque
order by nome asc;
go

select *
from entradas;

select *
from saidas;
