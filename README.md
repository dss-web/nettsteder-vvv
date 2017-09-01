# Nettsteder 2.0 - VVV site template

This is not live yet -- under development.

[Install VVV](https://varyingvagrantvagrants.org/docs/en-US/installation/)

To be able to clone private repos, [add a new SSH key](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/) to your GitHub account.

In the local VVV folder
- create the following vvv-custom.yml file:
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
      acf_pro_key: acf_pro_license_key
      github_token: github_token_for_dss-web_private_repo

vm_config:
  memory: 2048

utilities:
  core:
    - php71

utility-sources:
  core: https://github.com/Varying-Vagrant-Vagrants/vvv-utilities.git
```
- create the nettsteder folder: `mkdir nettsteder`

In the local VVV folder, run `vagrant reload --provision`
