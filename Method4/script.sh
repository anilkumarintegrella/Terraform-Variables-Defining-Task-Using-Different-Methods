#!/bin/bash

terraform plan \
    -var "rg_name=rg-anil-vaghari-playground" \
    -var "location=westeurope" \
    -var "dns_zone=anilv.azure.integrella.net"
