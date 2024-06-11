#!/usr/bin/env sh

set -ex

unseal () {
vault operator unseal $(grep 'Key 1:' /vault/file/keys | awk '{print $NF}')
vault operator unseal $(grep 'Key 2:' /vault/file/keys | awk '{print $NF}')
vault operator unseal $(grep 'Key 3:' /vault/file/keys | awk '{print $NF}')
}

init () {
vault operator init > /vault/file/keys
}

log_in () {
   export ROOT_TOKEN=$(grep 'Initial Root Token:' /vault/file/keys | awk '{print $NF}')
   vault login $ROOT_TOKEN
}

create_token () {
   vault token create -id $MY_VAULT_TOKEN
}

create_root_user () {
   vault policy write superuser /superuser-policy.hcl
   vault auth enable userpass
   vault write auth/userpass/users/root policies=superuser password=root
}

create_airflow_mountpoint () {
   vault secrets enable -path=airflow -version=2 kv
}

add_sample_airflow_credentials(){
   vault kv put airflow/connections/conn_uri_example conn_uri=postgres://user:password@ip-address.bog.ge:5432/dbname?extra_conf_1=val_1\&extra_conf_2=val_2
   vault kv put airflow/connections/full_conn_example conn_type=postgres description="very comprehensive description" extra="{\"extra_conf_1\":\"val_1\",\"extra_conf_2\":\"val_2\"}" host="ip-address.bog.ge" login=username password=password port=5432 schema=dbname
   vault kv put airflow/variables/sample_var value=sample_variable_value
}

if [ -s /vault/file/keys ]; then
   unseal
else
   init
   unseal
   log_in
   create_token
   create_root_user
   create_airflow_mountpoint
   add_sample_airflow_credentials
fi

vault status > /vault/file/status