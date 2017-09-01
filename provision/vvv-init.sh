#!/usr/bin/env bash
# Provision WordPress Stable


DOMAIN=`get_primary_host "${VVV_SITE_NAME}".dev`
DOMAINS=`get_hosts "${DOMAIN}"`
SITE_TITLE=`get_config_value 'site_title' "${DOMAIN}"`
WP_VERSION=`get_config_value 'wp_version' 'latest'`
WP_TYPE=`get_config_value 'wp_type' "single"`
DB_NAME=`get_config_value 'db_name' "${VVV_SITE_NAME}"`
DB_NAME=${DB_NAME//[\\\/\.\<\>\:\"\'\|\?\!\*-]/}
ACF_PRO_KEY=`get_config_value 'acf_pro_key' "xyz"`
GITHUB_TOKEN=`get_config_value 'github_token' "xyz"`

# Clone the Nettsteder repo
if [[ ! -f "${VVV_PATH_TO_SITE}/local-config.php" ]]; then
    echo "Cloning Nettsteder..."
	noroot git clone https://github.com/dss-web/nettsteder "${VVV_PATH_TO_SITE}/public_html/"

	echo "Configure local-config.php"

	sed -i "s#nettsteder.regjeringen.no#${DOMAIN}#" "${VVV_PATH_TO_SITE}/public_html/local-config-sample.php"
	sed -i "s#database_name_here#${DB_NAME}#" "${VVV_PATH_TO_SITE}/public_html/local-config-sample.php"
	sed -i "s#username_here#wp#" "${VVV_PATH_TO_SITE}/public_html/local-config-sample.php"
	sed -i "s#password_here#wp#" "${VVV_PATH_TO_SITE}/public_html/local-config-sample.php"
	noroot mv "${VVV_PATH_TO_SITE}/public_html/local-config-sample.php" "${VVV_PATH_TO_SITE}/local-config.php"
fi

export ACF_PRO_KEY=${ACF_PRO_KEY}
export GITHUB_TOKEN=${GITHUB_TOKEN}
export COMPOSER_AUTH=`echo '{"github-oauth": { "github.com": "{{github_token}}"}}' | sed -i "s#{{github_token}}#${GITHUB_TOKEN}#"`

echo "AUTH: ${COMPOSER_AUTH}"

# Composer
if [[ ! -d "${VVV_PATH_TO_SITE}/public_html/vendor" ]]; then
	echo "Running composer install"
	cd ${VVV_PATH_TO_SITE}/public_html
	noroot composer install
else
	echo "Running composer update"
	cd ${VVV_PATH_TO_SITE}/public_html
	noroot composer update
fi



# Make a database, if we don't already have one
echo -e "\nCreating database '${DB_NAME}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/error.log
touch ${VVV_PATH_TO_SITE}/log/access.log

# Install and configure the latest stable version of WordPress
if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp/wp-load.php" ]]; then
    echo "Downloading WordPress..."
	noroot wp core download --version="${WP_VERSION}" --path="${VVV_PATH_TO_SITE}/public_html/wp/"
fi

# if [[ ! -f "${VVV_PATH_TO_SITE}/public_html/wp-config.php" ]]; then
#   echo "Configuring WordPress Stable..."
#   noroot wp core config --dbname="${DB_NAME}" --dbuser=wp --dbpass=wp --quiet --extra-php <<PHP
# define( 'WP_DEBUG', true );
# PHP
# fi

if ! $(noroot wp core is-installed); then
  echo "Installing WordPress Stable..."

  if [ "${WP_TYPE}" = "subdomain" ]; then
    INSTALL_COMMAND="multisite-install --subdomains"
  elif [ "${WP_TYPE}" = "subdirectory" ]; then
    INSTALL_COMMAND="multisite-install"
  else
    INSTALL_COMMAND="install"
  fi

  noroot wp core ${INSTALL_COMMAND} --url="${DOMAIN}" --quiet --title="${SITE_TITLE}" --admin_name=admin --admin_email="admin@local.dev" --admin_password="password"
else
  echo "Updating WordPress Stable..."
  cd ${VVV_PATH_TO_SITE}/public_html/wp
  noroot wp core update --version="${WP_VERSION}"
fi

cp -f "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf.tmpl" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
sed -i "s#{{DOMAINS_HERE}}#${DOMAINS}#" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
