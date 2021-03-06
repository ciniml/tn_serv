set_option -out_dir [file normalize .]
set_option -device GW1N-1-QFN48-6
set_option -pn GW1N-LV1QN48C6/I5
set_option -prj_name tn_serv

foreach file [glob serv/rtl/*.v] {
    add_file -hdl [file normalize $file]
}
add_file -hdl [file normalize src/ram32.sv]
add_file -hdl [file normalize src/tn_serv_top.sv]
add_file -cst [file normalize src/tn_serv.cst]
add_file -sdc [file normalize src/tn_serv.sdc]

run_synthesis -opt [file normalize synthesize.cfg]
run_pnr -timing
