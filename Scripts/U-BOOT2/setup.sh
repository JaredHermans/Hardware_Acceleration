#!/bin/bash
# JARED HERMANS

# Run Intel EDS 2016
bsp-create-settings \
        --type spl \
        --bsp-dir ../../Quartus_Project/software2/spl_bsp \
        --preloader-settings-dir "../../Quartus_Project/hps_isw_handoff/QSYS_hps_0/" \
        --settings ../../Quartus_Project/software2/spl_bsp/settings.bsp
cd ../../Quartus_Project/software2/spl_bsp
make


