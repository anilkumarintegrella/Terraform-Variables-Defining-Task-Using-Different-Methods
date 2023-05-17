## Method 5

- Variables declared via seperate `variables.tf` file and defined via Environment variables
- To set Environment variables used command `Set-Item -Path env:TF_VAR_<variable name> -Value <value>`
- TF_VAR prefix is reserved by system
- For Example: `Set-Item -Path env:TF_VAR_loacation -Value "westeurope"`