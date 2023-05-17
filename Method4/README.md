## Method 4

- Variables declared via seperate `variables.tf` file and defined via passing `-var` command in CLI
- For Example: `terraform plan \`
                `-var "rg_name=rg-anil-vaghari-playground" \`
                `-var "location=westeurope" \`
                `-var "dns_zone=anilv.azure.integrella.net"`
