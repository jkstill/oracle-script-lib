#!/usr/bin/env bash

# find the CRSCTL binary

CRSCTL=$(grep "ORA_CRS_HOME=" /etc/init.d/init.ohasd| cut -d "=" -f2)/bin/crsctl
export CRSCTL
echo CRSCTL: $CRSCTL


