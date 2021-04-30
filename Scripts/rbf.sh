#!/bin/bash
# JARED HERMANS

# Run Intel EDS 2020.1
rm ../Quartus_Project/novpekcvlite.rbf
quartus_cpf -c ../Quartus_Project/output_files/DDR.sof ../Quartus_Project/novpekcvlite.rbf
