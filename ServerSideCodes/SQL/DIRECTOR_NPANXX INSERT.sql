drop table director_npanxx;

create table director_npanxx
(
NPANXX           VARCHAR2(255 BYTE),
AREA             VARCHAR2(255 BYTE),
STATE            VARCHAR2(255 BYTE),
TERRITORY        VARCHAR2(255 BYTE),
SVP              VARCHAR2(255 BYTE),
DIRECTOR         VARCHAR2(255 BYTE)
);

select * from director_clli_3;

commit;

INSERT ALL
into director_npanxx_2 values ('203324','Operating Area 1','CT','Connecticut','Paul Quick','Michael Wynschenk','Michael Wynschenk')
into director_npanxx_2 values ('224228','Operating Area 4','IL','Illinois','Greg Stephens','Eric Barie','Eric Barie')
into director_npanxx_2 values ('260894','Operating Area 4','IN','Indiana','Greg Stephens','Kirk Lehman','Kirk Lehman')
into director_npanxx_2 values ('281003','Operating Area 5','TX','Texas','Pedro Correa','Cort Petterson','Cort Petterson')
into director_npanxx_2 values ('310271','Operating Area 7','CA','California','Joe Gamble','Beach Cities','Leticia Solis')
into director_npanxx_2 values ('323877','Operating Area 7','CA','California','Joe Gamble','Beach Cities','Leticia Solis')
into director_npanxx_2 values ('325372','Operating Area 5','TX','Texas','Pedro Correa','Cort Petterson','Cort Petterson')
into director_npanxx_2 values ('419782','Operating Area 2','OH','Ohio','Elena Kilpatrick','Kevin Wallick','Kevin Wallick')
into director_npanxx_2 values ('503263','Operating Area 6','OR','Oregon','Dave Davidson','Steve Sandman','Steve Sandman')
into director_npanxx_2 values ('509656','Operating Area 6','WA','Washington','Dave Davidson','Kay Quinn','Kay Quinn')
into director_npanxx_2 values ('530694','Operating Area 5','CA','Southwest','Pedro Correa','Mark Jeffries','Mark Jeffries')
into director_npanxx_2 values ('570663','Operating Area 1','PA','Pennsylvania','Paul Quick','Rich O''Brien','Rich O''Brien')
into director_npanxx_2 values ('616296','Operating Area 2','MI','Michigan','Elena Kilpatrick','Bob Pero','Bob Pero')
into director_npanxx_2 values ('618665','Operating Area 4','IL','Illinois','Greg Stephens','Mike Nelson','Mike Nelson')
into director_npanxx_2 values ('626237','Operating Area 7','CA','California','Joe Gamble','Gateway','Geraldine Leibelt')
into director_npanxx_2 values ('704243','Operating Area 3','NC','North Carolina','Melanie Williams','Bill Wright','Bill Wright')
into director_npanxx_2 values ('704983','Operating Area 3','NC','North Carolina','Melanie Williams','Bill Wright','Bill Wright')
into director_npanxx_2 values ('740652','Operating Area 2','OH','Ohio','Elena Kilpatrick','Kevin Wallick','Kevin Wallick')
into director_npanxx_2 values ('803473','Operating Area 3','SC','South Carolina','Melanie Williams','Todd Van Epps','Todd Van Epps')
into director_npanxx_2 values ('843293','Operating Area 3','SC','South Carolina','Melanie Williams','Todd Van Epps','Todd Van Epps')
into director_npanxx_2 values ('903468','Operating Area 5','TX','Texas','Pedro Correa','Joel Peterson','Joel Peterson')
into director_npanxx_2 values ('909302','Operating Area 7','CA','California','Joe Gamble','Inland','Donald Jackson')
into director_npanxx_2 values ('928714','Operating Area 7','CA','California','Joe Gamble','NorCal','Thomas Novotney')
into director_npanxx_2 values ('931459','Operating Area 3','TN','South States','Melanie Williams','David Byrd','David Byrd')
into director_npanxx_2 values ('941053','Operating Area 3','FL','Florida','Melanie Williams','S Suncoast / Eastern','Doug Spurlin')
into director_npanxx_2 values ('951309','Operating Area 7','CA','California','Joe Gamble','Inland','Donald Jackson')
into director_npanxx_2 values ('979279','Operating Area 5','TX','Texas','Pedro Correa','Cort Petterson','Cort Petterson')
into director_npanxx_2 values ('979828','Operating Area 5','TX','Texas','Pedro Correa','Cort Petterson','Cort Petterson')
select * from dual;


INSERT ALL
into director_npanxx_3 values ('203324','East','CT','Connecticut','Chris Levendos','Michael Wynschenk','Michael Wynschenk')
into director_npanxx_3 values ('224228','Midwest','IL','Illinois','Greg Stephens','Eric Barie','Eric Barie')
into director_npanxx_3 values ('260894','Midwest','IN','Indiana','Greg Stephens','Kirk Lehman','Kirk Lehman')
into director_npanxx_3 values ('281003','South','TX','Texas','Melanie Williams','Cort Petterson','Cort Petterson')
into director_npanxx_3 values ('310271','West','CA','California','Joe Gamble','Beach Cities','Leticia Solis')
into director_npanxx_3 values ('323877','West','CA','California','Joe Gamble','Beach Cities','Leticia Solis')
into director_npanxx_3 values ('325372','South','TX','Texas','Melanie Williams','Cort Petterson','Cort Petterson')
into director_npanxx_3 values ('419782','Midwest','OH','Ohio','Greg Stephens','Kevin Wallick','Kevin Wallick')
into director_npanxx_3 values ('503263','West','OR','Oregon','Joe Gamble','Steve Sandman','Steve Sandman')
into director_npanxx_3 values ('509656','West','WA','Washington','Joe Gamble','Kay Quinn','Kay Quinn')
into director_npanxx_3 values ('530694','West','CA','Southwest','Joe Gamble','Mark Jeffries','Mark Jeffries')
into director_npanxx_3 values ('570663','East','PA','Pennsylvania','Chris Levendos','Rich O''Brien','Rich O''Brien')
into director_npanxx_3 values ('616296','Midwest','MI','Michigan','Greg Stephens','Bob Pero','Bob Pero')
into director_npanxx_3 values ('618665','Midwest','IL','Illinois','Greg Stephens','Mike Nelson','Mike Nelson')
into director_npanxx_3 values ('626237','West','CA','California','Joe Gamble','Gateway','Geraldine Leibelt')
into director_npanxx_3 values ('704243','South','NC','North Carolina','Melanie Williams','Bill Wright','Bill Wright')
into director_npanxx_3 values ('704983','South','NC','North Carolina','Melanie Williams','Bill Wright','Bill Wright')
into director_npanxx_3 values ('740652','Midwest','OH','Ohio','Greg Stephens','Kevin Wallick','Kevin Wallick')
into director_npanxx_3 values ('803473','South','SC','South Carolina','Melanie Williams','Todd Van Epps','Todd Van Epps')
into director_npanxx_3 values ('843293','South','SC','South Carolina','Melanie Williams','Todd Van Epps','Todd Van Epps')
into director_npanxx_3 values ('903468','South','TX','Texas','Melanie Williams','Joel Peterson','Joel Peterson')
into director_npanxx_3 values ('909302','West','CA','California','Joe Gamble','Inland','Donald Jackson')
into director_npanxx_3 values ('928714','West','CA','California','Joe Gamble','NorCal','Thomas Novotney')
into director_npanxx_3 values ('931459','South','TN','South States','Melanie Williams','David Byrd','David Byrd')
into director_npanxx_3 values ('941053','South','FL','Florida','Melanie Williams','S Suncoast / Eastern','Doug Spurlin')
into director_npanxx_3 values ('951309','West','CA','California','Joe Gamble','Inland','Donald Jackson')
into director_npanxx_3 values ('979279','South','TX','Texas','Melanie Williams','Cort Petterson','Cort Petterson')
into director_npanxx_3 values ('979828','South','TX','Texas','Melanie Williams','Cort Petterson','Cort Petterson')
select * from dual;


select *
from director_npanxx
where npanxx = '979828'
;

delete from director_npanxx
where npanxx in (
'203324',
'224228',
'260894',
'281003',
'310271',
'323877',
'325372',
'419782',
'503263',
'509656',
'530694',
'570663',
'616296',
'618665',
'626237',
'704243',
'704983',
'740652',
'803473',
'843293',
'903468',
'909302',
'928714',
'931459',
'941053',
'951309',
'979279',
'979828')
;


create table director_npanxx_4 as select * from director_npanxx_3
/

;


update director_npanxx_4
set svp = 'Julie Murtagh'
where area = 'East';


;

update director_npanxx_4
set area = 'East'
where state in ('OH','WV');


select distinct area, state, svp
from director_npanxx_4
order by 1,2;