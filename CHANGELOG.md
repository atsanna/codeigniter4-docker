# Changelog
All notable changes to this project will be documented in this file.

## [4.2.1] - 2022-06-17

- `The new StartScript allows you to update Codeigniter 4`: by reading the file */vendor/codeigniter4/framework/system/CodeIgniter.php*, the script checks if a composer update is required to update the application. **Warning: Always backup before using a new image!**
- `Added the support for environment variables`: environment variables can be used to generate the Codeigniter .env file.  The file will be generated at container startup only if REGEN_ENV_FILE = 1.
- `New PHP images`: they are images designed for application development, complete with many pre-installed php and apache modules.
- `The new images will have a new numbering`: the numbering will contain both the codeigniter version and the php version
