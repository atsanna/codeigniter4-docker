# Changelog
All notable changes to this project will be documented in this file.

## [4.2.3] - 2022-08-07

- `Upgrade to PHP 8.1.9`: Upgrade from php 8.1.7 to 8.1.9 version
- `Upgrade to CodeIgniter 4.2.3`: Upgrade Framework to Codeginiter 4.2.3


## [4.2.1] - 2022-06-17

- `The new StartScript allows you to update Codeigniter 4`: by reading the file */vendor/codeigniter4/framework/system/CodeIgniter.php*, the script checks if a composer update is required to update the application. **Warning: Always backup before using a new image!**
- `Added the support for environment variables`: environment variables can be used to generate the Codeigniter .env file.  The file will be generated at container startup only if REGEN_ENV_FILE = 1.
- `New PHP images`: they are images designed for application development, complete with many pre-installed php and apache modules.
- `The new images will have a new numbering`: the numbering will contain both the codeigniter version and the php version
