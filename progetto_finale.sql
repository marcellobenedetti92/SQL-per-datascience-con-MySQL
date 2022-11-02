/*

OBIETTIVO DEL PROGETTO

Creare una tabella denormalizzata che contenga
indicatori comportamentali sul cliente
calcolati sulla base delle transazioni e del possesso prodotti


SCOPO ULTIMO

Creare le feature per un possibile modello di ML supervisionato


INDICATORI DA CALCOLARE

Ogni indicatore va riferito al singolo id_cliente
1) Età FATTO E VERIFICATO
2) Numero di transazioni in uscita su tutti i conti (segno -)
3) Numero di transazioni in entrata su tutti i conti (segno +)
4) Importo transato in uscita su tutti i conti (somma importi)
5) Importo transato in entrata su tutti i conti (somma importi)
6) Numero tot dei conti posseduti (conteggio conti associati a cliente) FATTO E VERIFICATO

7) Numero di conti posseduti per tipologia (un indicatore per tipo)
8) Numero di transazioni in uscita per tipologia (un indicatore per tipo)
9) Numero di transazioni in entrata per tipologia (un indicatore per tipo)
10) Importo transato in uscita per tipologia di conto (un indicatore per tipo)
11) Importo transato in uscita per tipologia di conto (un indicatore per tipo)
tante colonne quanto il numero delle tipologie

*/



-- RAPIDO SGUARDO ALLE TABELLE CHE COMPONGONO IL DATABASE DELLA BANCA CON PIN DELLE SCHEDE NELLA RESULT GRID PER FACILITARE I JOIN
select * from banca.cliente
select * from banca.conto
select * from banca.tipo_conto
select * from banca.tipo_transazione
select * from banca.transazioni



-- 1) Età
-- Creazione NUOVA TABELLA TEMPORANEA: id_cliente, età

create temporary table banca.tt_id_cliente_eta (
select
id_cliente,
truncate(datediff(current_date(),data_nascita)/365 ,0) as eta

from
banca.cliente
)

select * from banca.tt_id_cliente_eta



-- 2) Numero di transazioni in uscita su tutti i conti (segno -)
-- Creazione NUOVA TABELLA TEMPORANEA: id_cliente, num_trans_usc

create temporary table banca.tt_num_trans_usc (
select
conto.id_cliente,
sum(case when transazioni.id_tipo_trans in (3,4,5,6,7) then 1 else 0 end) num_trans_usc

from banca.conto as conto
inner join banca.transazioni as transazioni
on conto.id_conto = transazioni.id_conto

group by 1
)

select * from tt_num_trans_usc



-- 3) Numero di transazioni in entrata su tutti i conti (segno +)
-- Creazione NUOVA TABELLA TEMPORANEA: id_cliente, num_trans_ent

create temporary table banca.tt_num_trans_ent (
select
conto.id_cliente,
sum(case when transazioni.id_tipo_trans in (0,1,2) then 1 else 0 end) num_trans_ent

from banca.conto as conto
inner join banca.transazioni as transazioni
on conto.id_conto = transazioni.id_conto

group by 1
)

select * from tt_num_trans_ent



-- 4) Importo transato in uscita su tutti i conti (somma importi)
-- Creazione NUOVA TABELLA TEMPORANEA: id_cliente, sum_trans_usc

create temporary table banca.tt_transato_usc (
select
conto.id_cliente,
sum(case when transazioni.id_tipo_trans in (3,4,5,6,7) then transazioni.importo else 0 end) transato_usc

from banca.conto as conto
inner join banca.transazioni as transazioni
on conto.id_conto = transazioni.id_conto

group by 1
)

select * from tt_transato_usc



-- 5) Importo transato in entrata su tutti i conti (somma importi)
-- Creazione NUOVA TABELLA TEMPORANEA: id_cliente, sum_trans_ent

create temporary table banca.tt_transato_ent (
select
conto.id_cliente,
sum(case when transazioni.id_tipo_trans in (0,1,2) then transazioni.importo else 0 end) transato_ent

from banca.conto as conto
inner join banca.transazioni as transazioni
on conto.id_conto = transazioni.id_conto

group by 1
)

select * from tt_transato_ent



-- 6) Numero tot dei conti posseduti (conteggio conti associati a cliente)
-- Creazione NUOVA TABELLA TEMPORANEA: id_cliente, count_conti

create temporary table banca.tt_conti_posseduti (
select
id_cliente,
count(id_conto) as count_conti

from
banca.conto

group by
1)


select * from tt_conti_posseduti



-- 7) Numero di conti posseduti per tipologia (un indicatore per tipo)
-- Creazione NUOVA TABELLA TEMPORANEA: id_cliente, conto_base, conto_biz, conto_pvt, conto_famiglie

create temporary table banca.tt_id_cliente_conto (
select
id_cliente,
sum(case when id_tipo_conto = 0 then 1 else 0 end) as conto_base,
sum(case when id_tipo_conto = 1 then 1 else 0 end) as conto_biz,
sum(case when id_tipo_conto = 2 then 1 else 0 end) as conto_pvt,
sum(case when id_tipo_conto = 3 then 1 else 0 end) as conto_famiglie

from banca.conto #as conto
#inner join banca.transazioni as transazioni
#on conto.id_conto = transazioni.id_conto

group by
1)


select * from tt_id_cliente_conto



-- 8) Numero di transazioni in uscita per tipologia (un indicatore per tipo)
-- Creazione NUOVA TABELLA TEMPORANEA: id_cliente, num_trans_usc_acquisto_amazon, num_trans_usc_rata_mutuo, num_trans_usc_hotel, num_trans_usc_biglietto_aereo, num_trans_usc_supermercato

create temporary table banca.tt_num_trans_usc_tipo (
select
conto.id_cliente,
sum(case when transazioni.id_tipo_trans = '3' then 1 else 0 end) num_trans_usc_acquisto_amazon,
sum(case when transazioni.id_tipo_trans = '4' then 1 else 0 end) num_trans_usc_rata_mutuo,
sum(case when transazioni.id_tipo_trans = '5' then 1 else 0 end) num_trans_usc_hotel,
sum(case when transazioni.id_tipo_trans = '6' then 1 else 0 end) num_trans_usc_biglietto_aereo,
sum(case when transazioni.id_tipo_trans = '7' then 1 else 0 end) num_trans_usc_supermercato

from banca.conto as conto
inner join banca.transazioni as transazioni
on conto.id_conto = transazioni.id_conto

group by 1
)

select * from tt_num_trans_usc_tipo



-- 9) Numero di transazioni in entrata per tipologia (un indicatore per tipo)
-- Creazione NUOVA TABELLA TEMPORANEA: id_cliente, num_trans_ent_stipendio, num_trans_ent_pensione, num_trans_ent_dividendi

create temporary table banca.tt_num_trans_ent_tipo (
select
conto.id_cliente,
sum(case when transazioni.id_tipo_trans = '0' then 1 else 0 end) num_trans_ent_stipendio,
sum(case when transazioni.id_tipo_trans = '1' then 1 else 0 end) num_trans_ent_pensione,
sum(case when transazioni.id_tipo_trans = '2' then 1 else 0 end) num_trans_ent_dividendi

from banca.conto as conto
inner join banca.transazioni as transazioni
on conto.id_conto = transazioni.id_conto

group by 1
)

select * from tt_num_trans_ent_tipo



-- 10) Importo transato in uscita per tipologia di conto (un indicatore per tipo)
-- Creazione NUOVA TABELLA TEMPORANEA: id_cliente, transato_usc_acquisto_amazon, transato_usc_rata_mutuo, transato_usc_hotel, transato_usc_biglietto_aereo, transato_usc_supermercato

create temporary table banca.tt_transato_usc_tipo (
select
conto.id_cliente,
sum(case when transazioni.id_tipo_trans = '3' then transazioni.importo else 0 end) transato_usc_acquisto_amazon,
sum(case when transazioni.id_tipo_trans = '4' then transazioni.importo else 0 end) transato_usc_rata_mutuo,
sum(case when transazioni.id_tipo_trans = '5' then transazioni.importo else 0 end) transato_usc_hotel,
sum(case when transazioni.id_tipo_trans = '6' then transazioni.importo else 0 end) transato_usc_biglietto_aereo,
sum(case when transazioni.id_tipo_trans = '7' then transazioni.importo else 0 end) transato_usc_supermercato

from banca.conto as conto
inner join banca.transazioni as transazioni
on conto.id_conto = transazioni.id_conto

group by 1
)

select * from tt_transato_usc_tipo



-- 11) Importo transato in uscita per tipologia di conto (un indicatore per tipo)
-- Creazione NUOVA TABELLA TEMPORANEA: id_cliente, transato_ent_stipendio, transato_ent_pensione, transato_ent_dividendi

create temporary table banca.tt_transato_ent_tipo (
select
conto.id_cliente,
sum(case when transazioni.id_tipo_trans = '0' then transazioni.importo else 0 end) transato_ent_stipendio,
sum(case when transazioni.id_tipo_trans = '1' then transazioni.importo else 0 end) transato_ent_pensione,
sum(case when transazioni.id_tipo_trans = '2' then transazioni.importo else 0 end) transato_ent_dividendi

from banca.conto as conto
inner join banca.transazioni as transazioni
on conto.id_conto = transazioni.id_conto

group by 1
)

select * from tt_transato_ent_tipo




-- JOIN DI TUTTE LE TEMPORARY TABLE
#1 tt_id_cliente_eta.id_cliente
#2 tt_id_cliente_eta.eta
#3 tt_num_trans_usc.num_trans_usc
#4 tt_num_trans_ent.num_trans_ent
#5 tt_transato_usc.transato_usc
#6 tt_transato_ent.transato_ent
#7 tt_conti_posseduti.count_conti
#8 tt_id_cliente_conto.conto_base
#9 tt_id_cliente_conto.conto_biz
#10 tt_id_cliente_conto.conto_pvt
#11 tt_id_cliente_conto.conto_famiglie
#12 tt_num_trans_usc_tipo.acquisto_amazon
#13 tt_num_trans_usc_tipo.rata_mutuo
#14 tt_num_trans_usc_tipo.hotel
#15 tt_num_trans_usc_tipo.biglietto_aereo
#16 tt_num_trans_usc_tipo.supermercato
#17 tt_num_trans_ent_tipo.stipendio_ent
#18 tt_num_trans_ent_tipo.pensione_ent
#19 tt_num_trans_ent_tipo.dividendi_ent

create table banca.ml1 (

select
tt_id_cliente_eta.id_cliente,
tt_id_cliente_eta.eta,
tt_num_trans_usc.num_trans_usc,
tt_num_trans_ent.num_trans_ent,
tt_transato_usc.transato_usc,
tt_transato_ent.transato_ent,
tt_conti_posseduti.count_conti,
tt_id_cliente_conto.conto_base,
tt_id_cliente_conto.conto_biz,
tt_id_cliente_conto.conto_pvt,
tt_id_cliente_conto.conto_famiglie,
tt_num_trans_usc_tipo.acquisto_amazon,
tt_num_trans_usc_tipo.rata_mutuo,
tt_num_trans_usc_tipo.hotel,
tt_num_trans_usc_tipo.biglietto_aereo,
tt_num_trans_usc_tipo.supermercato,
tt_num_trans_ent_tipo.stipendio_ent,
tt_num_trans_ent_tipo.pensione_ent,
tt_num_trans_ent_tipo.dividendi_ent

from tt_id_cliente_eta
left join tt_num_trans_usc on tt_num_trans_usc.id_cliente = tt_id_cliente_eta.id_cliente
left join tt_num_trans_ent on tt_num_trans_ent.id_cliente = tt_num_trans_usc.id_cliente
left join tt_transato_usc on tt_transato_usc.id_cliente = tt_num_trans_ent.id_cliente
left join tt_transato_ent on tt_transato_ent.id_cliente = tt_transato_usc.id_cliente
left join tt_conti_posseduti on tt_conti_posseduti.id_cliente = tt_transato_ent.id_cliente
left join tt_id_cliente_conto on tt_id_cliente_conto.id_cliente = tt_conti_posseduti.id_cliente
left join tt_num_trans_usc_tipo on tt_num_trans_usc_tipo.id_cliente = tt_id_cliente_conto.id_cliente
left join tt_num_trans_ent_tipo on tt_num_trans_ent_tipo.id_cliente = tt_num_trans_usc_tipo.id_cliente

)

select * from banca.ml1