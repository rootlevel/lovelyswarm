# lovelyswarm

terraform plan -out=test.plan -var 'count_managers=2' -var 'count_workers=2' -var 'username=atsoy' -var 'product_name=tesla' -var 'tag=tagme'


terraform apply -state=test.tfstate -var 'count_managers=1' -var 'count_workers=1' -var 'username=deployman' -var 'product_name=tesla' -var 'tag=tagme'


terraform destroy -state=test.tfstate