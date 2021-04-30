#!/bin/bash
# JARED HERMANS

# copy to <quartus prj directory>/MY_CODE/U_BOOT
bsp-create-settings \
        --type spl \
        --bsp-dir ../../software2/spl_bsp \
        --preloader-settings-dir "../../hps_isw_handoff/QSYS_hps_0/" \
        --settings ../../software2/spl_bsp/settings.bsp
cd ../../software2/spl_bsp
make


