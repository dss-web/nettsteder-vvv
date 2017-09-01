# Nettsteder 2.0 - VVV site template

This is not live yet -- under development.

vvv-custom.yml:

```yml
sites:
  nettsteder:
    repo: https://github.com/dss-web/nettsteder-vvv
    nginx_upstream: php71
    hosts:
      - nettsteder.dev
    custom:
      wp_type: subdirectory
      wp_version: latest
      acf_pro_key: license_key_goes_here

vm_config:
  memory: 2048

utilities:
  core:
    - memcached-admin
    - opcache-status
    - phpmyadmin
    - webgrind
    - php71

utility-sources:
  core: https://github.com/Varying-Vagrant-Vagrants/vvv-utilities.git
```
