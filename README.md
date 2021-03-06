# Nettsteder 2.0 - VVV site template

This is not live yet -- under development.

1) [Install VVV](https://varyingvagrantvagrants.org/docs/en-US/installation/)

2) To be able to clone the private repositories:
	- [Add a new SSH key](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/) to your GitHub account.
	- Set up SSH forwarding by [adding your SSH key to the ssh-agent](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#adding-your-ssh-key-to-the-ssh-agent)

3) In the local VVV folder, create the following vvv-custom.yml file:

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

	vm_config:
	  memory: 2048
	  cores: 2

	utilities:
	  core:
	    - php71

	utility-sources:
	  core: https://github.com/Varying-Vagrant-Vagrants/vvv-utilities.git
	```

4) In the local VVV folder run `vagrant up`, or `vagrant reload --provision` if vagrant is already running.
