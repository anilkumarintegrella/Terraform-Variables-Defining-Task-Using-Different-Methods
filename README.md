### Method 1

- Variables declared via seperate `variables.tf` file and defined it by default in same file

### Method 2

- Variables declared via seperate `variables.tf` file and defined it by passing through command line

### Method 3

- Variables declared via seperate `variables.tf` file and defined it by seperate `terraform.tfvars` file

### Method 4

- Variables declared via seperate `variables.tf` file and defined via passing `-var` command in CLI
- For Example: `terraform plan \`
                `-var "rg_name=rg-anil-vaghari-playground" \`
                `-var "location=westeurope" \`
                `-var "dns_zone=anilv.azure.integrella.net"`
- I have added `.\script.sh` file to run it

### Method 5

- Variables declared via seperate `variables.tf` file and defined via Environment variables
- To set Environment variables used command `Set-Item -Path env:TF_VAR_<variable name> -Value <value>`
- TF_VAR prefix is reserved by system
- For Example: `Set-Item -Path env:TF_VAR_loacation -Value "westeurope"`