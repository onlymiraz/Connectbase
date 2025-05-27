--WAREHOUSE   

---IL SPA MR-2 Denominator  
select sum(dw_line_cnt_count) lines   --dw_line_cnt_acna, sum(dw_line_cnt_count) lines 
from dw_wst_app.nmp_dw_mr_line_cnt_splacc
where dw_line_cnt_state = 'IL'
and dw_line_cnt_acna not in ('BNK','ZZZ')
and dw_line_cnt_bdate = '1109'
and dw_line_cnt_piu = '0'
and (dw_line_cnt_circuit like '%T3%'
or dw_line_cnt_circuit like '%FS%')
and dw_line_cnt_class in ('XDD4X','XDH1X','XDH3X','XDV2X','XDV3X','XDV5X','XDV6X')



select dw_line_cnt_circuit, dw_line_cnt_piu
from dw_wst_app.nmp_dw_mr_line_cnt_splacc
where dw_line_cnt_state = 'IL'
and dw_line_cnt_bdate = '1106'
and (dw_line_cnt_circuit like '%T3%'
or dw_line_cnt_circuit like '%FS%')
and dw_line_cnt_class in ('XDD4X','XDH1X','XDH3X','XDV2X','XDV3X','XDV5X','XDV6X')
  
