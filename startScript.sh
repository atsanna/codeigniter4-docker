#!/bin/bash
export PATH=/usr/local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

app_name="codeigniter4"
new_version="4.2.3"

set -eu

#compare version
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

print_text () {
	GREEN="\e[321m"
	ENDCOLOR="\e[0m"
	echo -e "${GREEN}#====================================================================#${ENDCOLOR}\r\n";
	echo -e "${GREEN}#  $1${ENDCOLOR}\r\n";
	echo -e "${GREEN}#====================================================================#${ENDCOLOR}\r\n";
}

#test compare version
testvercomp () {
    vercomp $1 $2
    case $? in
        0) op='=';;
        1) op='>';;
        2) op='<';;
    esac
    if [[ $op != $3 ]]
    then
        #echo "FAIL: Expected '$3', Actual '$op', Arg1 '$1', Arg2 '$2'"
		print_text "CodeIgniter ${installed_version} are installed";
		return 0
    else
        #echo "Pass: '$1 $op $2'"
		print_text "CodeIgniter are not latest version";
		print_text "Starting CodeIgniter update"
		#====================================================================#
		#                         UPDATE CODEIGNITER 4                       #
		#====================================================================#
		cd /var/www/html/$app_name && \
		composer update
		return 1
    fi
}

# return true if specified directory is empty
directory_empty() {
    [ -z "$(ls -A "$1/")" ]
}

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    local varValue=$(env | grep -E "^${var}=" | sed -E -e "s/^${var}=//")
    local fileVarValue=$(env | grep -E "^${fileVar}=" | sed -E -e "s/^${fileVar}=//")
    if [ -n "${varValue}" ] && [ -n "${fileVarValue}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    if [ -n "${varValue}" ]; then
        export "$var"="${varValue}"
    elif [ -n "${fileVarValue}" ]; then
        export "$var"="$(cat "${fileVarValue}")"
    elif [ -n "${def}" ]; then
        export "$var"="$def"
    fi
    unset "$fileVar"
}

# check if composer package is installed
package_exist() {
    composer show | grep $1 >/dev/null
}

# Codeigniter .env file generator
codeigniter_env_generator() {
			cd /var/www/html/$app_name
		echo "#--------------------------------------------------------------------" > .env
		echo "# Example Environment Configuration file" >> .env
		echo "#" >> .env
		echo "# This file can be used as a starting point for your own" >> .env
		echo "# custom .env files, and contains most of the possible settings" >> .env
		echo "# available in a default install." >> .env
		echo "#" >> .env
		echo "# By default, all of the settings are commented out. If you want" >> .env
		echo "# to override the setting, you must un-comment it by removing the '#'" >> .env
		echo "# at the beginning of the line." >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "# ENVIRONMENT" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "" >> .env

		ci_environment=${CI_ENVIRONMENT}
		if [[ -z "${ci_environment}" ]]; then
			echo "# CI_ENVIRONMENT = production" >> .env
		else
			echo "CI_ENVIRONMENT = ${ci_environment}" >> .env
		fi

		echo "" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "# APP" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "" >> .env

		baseURL=${APP_BASE_URL}
		if [[ -z "${baseURL}" ]]; then
			echo "# app.baseURL = ''" >> .env
		else
			echo "app.baseURL = '${baseURL}'" >> .env
		fi

		forceGlobalSecureRequests=${APP_FORCE_GLOBAL_SECURE_REQUESTS:-}
		if [[ -z "${forceGlobalSecureRequests}" ]]; then
			echo "# app.forceGlobalSecureRequests = false" >> .env
		else
			echo "app.forceGlobalSecureRequests = ${forceGlobalSecureRequests}" >> .env
		fi
		echo "" >> .env

		sessionDriver=${APP_SESSION_DRIVER:-}
		if [[ -z "${sessionDriver}" ]]; then
			echo "# app.sessionDriver = 'CodeIgniter\Session\Handlers\FileHandler'" >> .env
		else
			echo "app.sessionDriver = '${sessionDriver}'" >> .env
		fi

		sessionCookieName=${APP_SESSION_COOCKIE_NAME:-}
		if [[ -z "${sessionCookieName}" ]]; then
			echo "# app.sessionCookieName = 'ci_session'" >> .env
		else
			echo "app.sessionCookieName = '${sessionCookieName}'" >> .env
		fi

		sessionExpiration=${APP_SESSION_EXPIRATION:-}
		if [[ -z "${sessionExpiration}" ]]; then
			echo "# app.sessionExpiration = 7200" >> .env
		else
			echo "app.sessionExpiration = ${sessionExpiration}" >> .env
		fi

		sessionSavePath=${APP_SESSION_SAVE_PATH:-}
		if [[ -z "${sessionSavePath}" ]]; then
			echo "# app.sessionSavePath = null" >> .env
		else
			echo "app.sessionSavePath = ${sessionSavePath}" >> .env
		fi

		sessionMatchIP=${APP_SESSION_MATCH_CHIP:-}
		if [[ -z "${sessionMatchIP}" ]]; then
			echo "# app.sessionMatchIP = false" >> .env
		else
			echo "app.sessionMatchIP = ${sessionMatchIP}" >> .env
		fi

		sessionTimeToUpdate=${APP_SESSION_TIME_TO_UPDATE:-}
		if [[ -z "${sessionTimeToUpdate}" ]]; then
			echo "# app.sessionTimeToUpdate = 300" >> .env
		else
			echo "app.sessionTimeToUpdate = ${sessionTimeToUpdate}" >> .env
		fi

		sessionRegenerateDestroy=${APP_SESSION_REGENERATE_DESTROY:-}
		if [[ -z "${sessionRegenerateDestroy}" ]]; then
			echo "# app.sessionRegenerateDestroy = false" >> .env
		else
			echo "app.sessionRegenerateDestroy = ${sessionRegenerateDestroy}" >> .env
		fi
		echo "" >> .env

		CSPEnabled=${APP_CSP_ENABLED:-}
		if [[ -z "${CSPEnabled}" ]]; then
			echo "# app.CSPEnabled = false" >> .env
		else
			echo "app.CSPEnabled = ${CSPEnabled}" >> .env
		fi

		echo "" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "# DATABASE" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "" >> .env

		db_default_hostname=${DB_DEFAULT_HOSTNAME:-}
		if [[ -z "${db_default_hostname}" ]]; then
			echo "# database.default.hostname = localhost" >> .env
		else
			echo "database.default.hostname = ${db_default_hostname}" >> .env
		fi

		db_default_database=${DB_DEFAULT_DATABASE:-}
		if [[ -z "${db_default_database}" ]]; then
			echo "# database.default.database = ci4" >> .env
		else
			echo "database.default.database = ${db_default_database}" >> .env
		fi

		db_default_username=${DB_DEFAULT_USERNAME:-}
		if [[ -z "${db_default_username}" ]]; then
			echo "# database.default.username = root" >> .env
		else
			echo "database.default.username = ${db_default_username}" >> .env
		fi

		db_default_password=${DB_DEFAULT_PASSWORD:-}
		if [[ -z "${db_default_password}" ]]; then
			echo "# database.default.password = root" >> .env
		else
			echo "database.default.password = ${db_default_password}" >> .env
		fi

		db_default_DBDriver=${DB_DEFAULT_DRIVER:-}
		if [[ -z "${db_default_DBDriver}" ]]; then
			echo "# database.default.DBDriver = MySQLi" >> .env
		else
			echo "database.default.DBDriver = ${db_default_DBDriver}" >> .env
		fi

		db_default_port=${DB_DEFAULT_PORT:-}
		if [[ -z "${db_default_port}" ]]; then
			echo "# database.default.port = 3306" >> .env
		else
			echo "database.default.port = ${db_default_port}" >> .env
		fi

		db_default_DBPrefix=${DB_DEFAULT_PREFIX:-}
		if [[ -z "${db_default_DBPrefix}" ]]; then
			echo "# database.default.DBPrefix = " >> .env
		else
			echo "database.default.DBPrefix = ${db_default_DBPrefix}" >> .env
		fi
		echo "" >> .env

		db_tests_hostname=${DB_TESTS_HOSTNAME:-}
		if [[ -z "${db_tests_hostname}" ]]; then
			echo "# database.tests.hostname = localhost" >> .env
		else
			echo "database.tests.hostname = ${db_tests_hostname}" >> .env
		fi

		db_tests_database=${DB_TESTS_DATABASE:-}
		if [[ -z "${db_tests_database}" ]]; then
			echo "# database.tests.database = ci4" >> .env
		else
			echo "database.tests.database = ${db_tests_database}" >> .env
		fi

		db_tests_username=${DB_TESTS_USERNAME:-}
		if [[ -z "${db_tests_username}" ]]; then
			echo "# database.tests.username = root" >> .env
		else
			echo "database.tests.username = ${db_tests_username}" >> .env
		fi

		db_tests_password=${DB_TESTS_PASSWORD:-}
		if [[ -z "${db_tests_password}" ]]; then
			echo "# database.tests.password = root" >> .env
		else
			echo "database.tests.password = ${db_tests_password}" >> .env
		fi

		db_tests_DBDriver=${DB_TESTS_DRIVER:-}
		if [[ -z "${db_tests_DBDriver}" ]]; then
			echo "# database.tests.DBDriver = MySQLi" >> .env
		else
			echo "database.tests.DBDriver = ${db_tests_DBDriver}" >> .env
		fi

		db_tests_port=${DB_TESTS_PORT:-}
		if [[ -z "${db_tests_port}" ]]; then
			echo "# database.tests.port = 3306" >> .env
		else
			echo "database.tests.port = ${db_tests_port}" >> .env
		fi

		db_tests_DBPrefix=${DB_TESTS_PREFIX:-}
		if [[ -z "${db_tests_DBPrefix}" ]]; then
			echo "# database.tests.DBPrefix = " >> .env
		else
			echo "database.tests.DBPrefix = ${db_tests_DBPrefix}" >> .env
		fi
		echo "" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "# CONTENT SECURITY POLICY" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "" >> .env

		contentsecuritypolicy_reportOnly=${CONTENT_SECURE_POLICY_REPORT_ONLY:-}
		if [[ -z "${contentsecuritypolicy_reportOnly}" ]]; then
			echo "# contentsecuritypolicy.reportOnly = false" >> .env
		else
			echo "contentsecuritypolicy.reportOnly = ${contentsecuritypolicy_reportOnly}" >> .env
		fi

		contentsecuritypolicy_defaultSrc=${CONTENT_SECURE_POLICY_DEFAULT_SRC:-}
		if [[ -z "${contentsecuritypolicy_defaultSrc}" ]]; then
			echo "# contentsecuritypolicy.defaultSrc = 'none'" >> .env
		else
			echo "contentsecuritypolicy.defaultSrc = '${contentsecuritypolicy_defaultSrc}'" >> .env
		fi

		contentsecuritypolicy_scriptSrc=${CONTENT_SECURE_POLICY_SCRIPT_SRC:-}
		if [[ -z "${contentsecuritypolicy_scriptSrc}" ]]; then
			echo "# contentsecuritypolicy.scriptSrc = 'self'" >> .env
		else
			echo "contentsecuritypolicy.scriptSrc = '${contentsecuritypolicy_scriptSrc}'" >> .env
		fi

		contentsecuritypolicy_styleSrc=${CONTENT_SECURE_POLICY_STYLE_SRC:-}
		if [[ -z "${contentsecuritypolicy_styleSrc}" ]]; then
			echo "# contentsecuritypolicy.styleSrc = 'self'" >> .env
		else
			echo "contentsecuritypolicy.styleSrc = '${contentsecuritypolicy_styleSrc}'" >> .env
		fi

		contentsecuritypolicy_imageSrc=${CONTENT_SECURE_POLICY_IMAGE_SRC:-}
		if [[ -z "${contentsecuritypolicy_imageSrc}" ]]; then
			echo "# contentsecuritypolicy.imageSrc = 'self'" >> .env
		else
			echo "contentsecuritypolicy.imageSrc = '${contentsecuritypolicy_imageSrc}'" >> .env
		fi

		contentsecuritypolicy_base_uri=${CONTENT_SECURE_POLICY_BASE_URI:-}
		if [[ -z "${contentsecuritypolicy_base_uri}" ]]; then
			echo "# contentsecuritypolicy.base_uri = null" >> .env
		else
			echo "contentsecuritypolicy.base_uri = ${contentsecuritypolicy_base_uri}" >> .env
		fi

		contentsecuritypolicy_childSrc=${CONTENT_SECURE_POLICY_CHILD_SRC:-}
		if [[ -z "${contentsecuritypolicy_childSrc}" ]]; then
			echo "# contentsecuritypolicy.childSrc = null" >> .env
		else
			echo "contentsecuritypolicy.childSrc = ${contentsecuritypolicy_childSrc}" >> .env
		fi

		contentsecuritypolicy_connectSrc=${CONTENT_SECURE_POLICY_CONNECT_SRC:-}
		if [[ -z "${contentsecuritypolicy_connectSrc}" ]]; then
			echo "# contentsecuritypolicy.connectSrc = 'self'" >> .env
		else
			echo "contentsecuritypolicy.connectSrc = '${contentsecuritypolicy_childSrc}'" >> .env
		fi

		contentsecuritypolicy_fontSrc=${CONTENT_SECURE_POLICY_FONT_SRC:-}
		if [[ -z "${contentsecuritypolicy_fontSrc}" ]]; then
			echo "# contentsecuritypolicy.fontSrc = null" >> .env
		else
			echo "contentsecuritypolicy.fontSrc = ${contentsecuritypolicy_fontSrc}" >> .env
		fi

		contentsecuritypolicy_formAction=${CONTENT_SECURE_POLICY_FORM_ACTION:-}
		if [[ -z "${contentsecuritypolicy_formAction}" ]]; then
			echo "# contentsecuritypolicy.formAction = null" >> .env
		else
			echo "contentsecuritypolicy.formAction = ${contentsecuritypolicy_formAction}" >> .env
		fi

		contentsecuritypolicy_frameAncestors=${CONTENT_SECURE_POLICY_FRAME_ANCESTORS:-}
		if [[ -z "${contentsecuritypolicy_frameAncestors}" ]]; then
			echo "# contentsecuritypolicy.frameAncestors = null" >> .env
		else
			echo "contentsecuritypolicy.frameAncestors = ${contentsecuritypolicy_frameAncestors}" >> .env
		fi

		contentsecuritypolicy_frameSrc=${CONTENT_SECURE_POLICY_FRAME_SRC:-}
		if [[ -z "${contentsecuritypolicy_frameSrc}" ]]; then
			echo "# contentsecuritypolicy.frameSrc = null" >> .env
		else
			echo "contentsecuritypolicy.frameSrc = ${contentsecuritypolicy_frameSrc}" >> .env
		fi

		contentsecuritypolicy_mediaSrc=${CONTENT_SECURE_POLICY_MEDIA_SRC:-}
		if [[ -z "${contentsecuritypolicy_mediaSrc}" ]]; then
			echo "# contentsecuritypolicy.mediaSrc = null" >> .env
		else
			echo "contentsecuritypolicy.mediaSrc = ${contentsecuritypolicy_mediaSrc}" >> .env
		fi

		contentsecuritypolicy_objectSrc=${CONTENT_SECURE_POLICY_OBJECT_SRC:-}
		if [[ -z "${contentsecuritypolicy_objectSrc}" ]]; then
			echo "# contentsecuritypolicy.objectSrc = null" >> .env
		else
			echo "contentsecuritypolicy.objectSrc = ${contentsecuritypolicy_objectSrc}" >> .env
		fi

		contentsecuritypolicy_pluginTypes=${CONTENT_SECURE_POLICY_PLUGIN_TYPES:-}
		if [[ -z "${contentsecuritypolicy_pluginTypes}" ]]; then
			echo "# contentsecuritypolicy.pluginTypes = null" >> .env
		else
			echo "contentsecuritypolicy.pluginTypes = ${contentsecuritypolicy_pluginTypes}" >> .env
		fi

		contentsecuritypolicy_reportURI=${CONTENT_SECURE_POLICY_REPORT_URI:-}
		if [[ -z "${contentsecuritypolicy_reportURI}" ]]; then
			echo "# contentsecuritypolicy.reportURI = null" >> .env
		else
			echo "contentsecuritypolicy.reportURI = ${contentsecuritypolicy_reportURI}" >> .env
		fi

		contentsecuritypolicy_sandbox=${CONTENT_SECURE_POLICY_SANDBOX:-}
		if [[ -z "${contentsecuritypolicy_sandbox}" ]]; then
			echo "# contentsecuritypolicy.sandbox = false" >> .env
		else
			echo "contentsecuritypolicy.sandbox = ${contentsecuritypolicy_sandbox}" >> .env
		fi

		contentsecuritypolicy_upgradeInsecureRequests=${CONTENT_SECURE_POLICY_UPGRADE_INSECURE_REQUESTS:-}
		if [[ -z "${contentsecuritypolicy_upgradeInsecureRequests}" ]]; then
			echo "# contentsecuritypolicy.upgradeInsecureRequests = false" >> .env
		else
			echo "contentsecuritypolicy.upgradeInsecureRequests = ${contentsecuritypolicy_upgradeInsecureRequests}" >> .env
		fi

		echo "" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "# COOKIE" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "" >> .env

		cookie_prefix=${COOKIE_PREFIX:-}
		if [[ -z "${cookie_prefix}" ]]; then
			echo "# cookie.prefix = ''" >> .env
		else
			echo "cookie.prefix = '${cookie_prefix}'" >> .env
		fi

		cookie_expires=${COOKIE_EXPIRES:-}
		if [[ -z "${cookie_expires}" ]]; then
			echo "# cookie.expires = 0" >> .env
		else
			echo "cookie.expires = ${cookie_expires}" >> .env
		fi

		cookie_path=${COOKIE_PATH:-}
		if [[ -z "${cookie_path}" ]]; then
			echo "# cookie.path = '/'" >> .env
		else
			echo "cookie.path = '${cookie_path}'" >> .env
		fi

		cookie_domain=${COOKIE_DOMAIN:-}
		if [[ -z "${cookie_domain}" ]]; then
			echo "# cookie.domain = ''" >> .env
		else
			echo "cookie.domain = '${cookie_domain}'" >> .env
		fi

		cookie_secure=${COOKIE_SECURE:-}
		if [[ -z "${cookie_secure}" ]]; then
			echo "# cookie.secure = false" >> .env
		else
			echo "cookie.secure = ${cookie_secure}" >> .env
		fi

		cookie_httponly=${COOKIE_HTTP_OLNY:-}
		if [[ -z "${cookie_httponly}" ]]; then
			echo "# cookie.httponly = false" >> .env
		else
			echo "cookie.httponly = ${cookie_httponly}" >> .env
		fi

		cookie_samesite=${COOKIE_SAME_SITE:-}
		if [[ -z "${cookie_samesite}" ]]; then
			echo "# cookie.samesite = 'Lax'" >> .env
		else
			echo "cookie.samesite = '${cookie_samesite}'" >> .env
		fi

		cookie_raw=${COOKIE_RAW:-}
		if [[ -z "${cookie_raw}" ]]; then
			echo "# cookie.raw = false" >> .env
		else
			echo "cookie.raw = ${cookie_raw}" >> .env
		fi

		echo "" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "# ENCRYPTION" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "" >> .env

		encryption_key=${ENCRYPTION_KEY:-}
		if [[ -z "${encryption_key}" ]]; then
			echo "# encryption.key = " >> .env
		else
			echo "encryption.key = ${encryption_key}" >> .env
		fi

		encryption_driver=${ENCRYPTION_DRIVER:-}
		if [[ -z "${encryption_driver}" ]]; then
			echo "# encryption.driver = OpenSSL" >> .env
		else
			echo "encryption.driver = ${encryption_driver}" >> .env
		fi

		encryption_blockSize=${ENCRYPTION_BLOCK_SIZE:-}
		if [[ -z "${encryption_blockSize}" ]]; then
			echo "# encryption.blockSize = 16" >> .env
		else
			echo "encryption.blockSize = ${encryption_blockSize}" >> .env
		fi

		encryption_digest=${ENCRYPTION_DIGEST:-}
		if [[ -z "${encryption_digest}" ]]; then
			echo "# encryption.digest = 256" >> .env
		else
			echo "encryption.digest = ${encryption_digest}" >> .env
		fi

		echo "" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "# HONEYPOT" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "" >> .env

		honeypot_hidden=${HONEYPOT_HIDDEN:-}
		if [[ -z "${honeypot_hidden}" ]]; then
			echo "# honeypot.hidden = 'true'" >> .env
		else
			echo "honeypot.hidden = '${honeypot_hidden}'" >> .env
		fi

		honeypot_label=${HONEYPOT_LABEL:-}
		if [[ -z "${honeypot_label}" ]]; then
			echo "# honeypot.label = 'Fill This Field'" >> .env
		else
			echo "honeypot.label = '${honeypot_label}'" >> .env
		fi

		honeypot_name=${HONEYPOT_NAME:-}
		if [[ -z "${honeypot_name}" ]]; then
			echo "# honeypot.name = 'honeypot'" >> .env
		else
			echo "honeypot.name = '${honeypot_name}'" >> .env
		fi

		honeypot_template=${HONEYPOT_TEMPLATE:-}
		if [[ -z "${honeypot_template}" ]]; then
			echo "# honeypot.template = '<label>{label}</label><input type=\"text\" name=\"{name}\" value=\"\"/>'" >> .env
		else
			echo "honeypot.template = '${honeypot_template}'" >> .env
		fi

		honeypot_container=${HONEYPOT_CONTAINER:-}
		if [[ -z "${honeypot_container}" ]]; then
			echo "# honeypot.container = '<div style=\"display:none\">{template}</div>'" >> .env
		else
			echo "honeypot.container = '${honeypot_container}'" >> .env
		fi

		echo "" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "# SECURITY" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "" >> .env

		security_csrfProtection=${SECURITY_CSRF_PROTECTION:-}
		if [[ -z "${security_csrfProtection}" ]]; then
			echo "# security.csrfProtection = 'cookie'" >> .env
		else
			echo "security.csrfProtection = '${security_csrfProtection}'" >> .env
		fi

		security_tokenRandomize=${SECURITY_TOKEN_RANDOMIZE:-}
		if [[ -z "${security_tokenRandomize}" ]]; then
			echo "# security.tokenRandomize = false" >> .env
		else
			echo "security.tokenRandomize = ${security_tokenRandomize}" >> .env
		fi

		security_tokenName=${SECURITY_TOKEN_NAME:-}
		if [[ -z "${security_tokenName}" ]]; then
			echo "# security.tokenName = 'csrf_token_name'" >> .env
		else
			echo "security.tokenName = '${security_tokenName}'" >> .env
		fi

		security_headerName=${SECURITY_HEADER_NAME:-}
		if [[ -z "${security_headerName}" ]]; then
			echo "# security.headerName = 'X-CSRF-TOKEN'" >> .env
		else
			echo "security.headerName = '${security_headerName}'" >> .env
		fi

		security_cookieName=${SECURITY_COOKIE_NAME:-}
		if [[ -z "${security_cookieName}" ]]; then
			echo "# security.cookieName = 'csrf_cookie_name'" >> .env
		else
			echo "security.cookieName = '${security_cookieName}'" >> .env
		fi

		security_expires=${SECURITY_EXPIRES:-}
		if [[ -z "${security_expires}" ]]; then
			echo "# security.expires = 7200" >> .env
		else
			echo "security.expires = ${security_expires}" >> .env
		fi

		security_regenerate=${SECURITY_REGENERATE:-}
		if [[ -z "${security_regenerate}" ]]; then
			echo "# security.regenerate = true" >> .env
		else
			echo "security.regenerate = ${security_regenerate}" >> .env
		fi

		security_redirect=${SECURITY_REDIRECT:-}
		if [[ -z "${security_redirect}" ]]; then
			echo "# security.redirect = true" >> .env
		else
			echo "security.redirect = ${security_redirect}" >> .env
		fi

		security_samesite=${SECURITY_SAME_SITE:-}
		if [[ -z "${security_samesite}" ]]; then
			echo "# security.samesite = 'Lax'" >> .env
		else
			echo "security.samesite = '${security_samesite}'" >> .env
		fi

		echo "" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "# LOGGER" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "" >> .env

		logger_threshold=${LOGGER_THRESHOLD:-}
		if [[ -z "${logger_threshold}" ]]; then
			echo "# logger.threshold = 4" >> .env
		else
			echo "logger.threshold = ${logger_threshold}" >> .env
		fi

		echo "" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "# CURLRequest" >> .env
		echo "#--------------------------------------------------------------------" >> .env
		echo "" >> .env

		curlrequest_shareOptions=${CURL_REQUEST_SHARE_OPTIONS:-}
		if [[ -z "${curlrequest_shareOptions}" ]]; then
			echo "# curlrequest.shareOptions = true" >> .env
		else
			echo "curlrequest.shareOptions = ${curlrequest_shareOptions}" >> .env
		fi

}

#====================================================================#
#         CHECK IF CODEIGNITER 4 IS INSTALLED AND GET VERSION        #
#====================================================================#
installed_version="0.0.0.0"
if [ -f /var/www/html/$app_name/vendor/codeigniter4/framework/system/CodeIgniter.php ]; then
	# Installed;
	get_version="$(php -r '$file=file("/var/www/html/'"$app_name"'/vendor/codeigniter4/framework/system/CodeIgniter.php")[49];$version = str_replace("    public const CI_VERSION = ","", $file);echo str_replace(";","",$version);')"
else
	# Not Installed;
	get_version="'${installed_version}'";
fi

installed_version="${get_version:1:-1}";

if [ "${installed_version}" != "0.0.0.0" ]; then
	echo $(testvercomp "${new_version}" "${installed_version}" ">");
else
	print_text "New CodeIgniter instance";

	#====================================================================#
	#                        INSTALL CODEIGNITER 4                       #
	#====================================================================#
	print_text "Starting CodeIgniter installation"
	cd /var/www/html && \
	composer create-project codeigniter4/appstarter:$new_version $app_name

	#====================================================================#
	#                          Create test file                          #
	#====================================================================#
	print_text "Create Test file"
	printf "<?php\nphpinfo();\n?>" > /var/www/html/$app_name/public/test.php

	#====================================================================#
	#                            Permissions                             #
	#====================================================================#
	chown -R www-data:www-data /var/www/html
	chmod -R 0777 /var/www/html/$app_name/writable
fi

#====================================================================#
#                              ENV FILE                              #
#====================================================================#

if [[ -z "${REGEN_ENV_FILE}" ]]; then
  regen_env_file="Some default value because REGEN_ENV_FILE is undefined"
else
  regen_env_file="${REGEN_ENV_FILE}"
    if [ "${regen_env_file}" == "1" ]; then
	print_text "Regen .env file"

	codeigniter_env_generator

	else
		print_text "Same .env file"
  	fi
fi

#====================================================================#
#                           MAIL CONFIG                              #
#====================================================================#

if [[ -z "${ROOT_EMAIL}" ]]; then
  root_email=""
else
  root_email="${ROOT_EMAIL}"
fi
if [[ -z "${MAIL_SERVER}" ]]; then
  mail_server=""
else
  mail_server="${MAIL_SERVER}"
fi
if [[ -z "${MAIL_SERVER_PORT}" ]]; then
  mail_server_port=""
else
  mail_server_port="${MAIL_SERVER_PORT}"
fi
if [[ -z "${MAIL_SERVER_USER}" ]]; then
  mail_server_user=""
else
  mail_server_user="${MAIL_SERVER_USER}"
fi
if [[ -z "${MAIL_SERVER_PASSWORD}" ]]; then
  mail_server_password=""
else
  mail_server_password="${MAIL_SERVER_PASSWORD}"
fi
if [[ -z "${MAIL_SERVER_TLS}" ]]; then
  mail_server_tls=""
else
  mail_server_tls="${MAIL_SERVER_TLS}"
fi
if [[ -z "${MAIL_SERVER_STARTTLS}" ]]; then
  mail_server_starttls=""
else
  mail_server_starttls="${MAIL_SERVER_STARTTLS}"
fi

servername="localhost"
echo "root=${root_email}" > /etc/ssmtp/ssmtp.conf
echo "mailhub=${mail_server}:${mail_server_port}" >> /etc/ssmtp/ssmtp.conf
echo "hostname=${servername}" >> /etc/ssmtp/ssmtp.conf
echo "AuthUser=${mail_server_user}" >> /etc/ssmtp/ssmtp.conf
echo "AuthPass=${mail_server_password}" >> /etc/ssmtp/ssmtp.conf
echo "UseTLS=${mail_server_tls}" >> /etc/ssmtp/ssmtp.conf
echo "UseSTARTTLS=${mail_server_starttls}" >> /etc/ssmtp/ssmtp.conf
echo "sendmail_path=sendmail -i -t" >> /usr/local/etc/php/conf.d/20-sendmail.ini

yes 'y' | /usr/sbin/sendmailconfig
chmod 777 /etc/ssmtp /etc/ssmtp/*

#====================================================================#
#                        APACHE CONFIGURATION                        #
#====================================================================#
#sed -ri -e 's!/var/www/html!$app_name!g' /etc/apache2/sites-available/*.conf
#sed -ri -e 's!/var/www/!$app_name!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf


#====================================================================#
#                       A P A C H E    R U N                         #
#====================================================================#
/usr/sbin/apache2ctl -D FOREGROUND