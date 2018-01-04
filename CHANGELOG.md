# pulp_server Cookbook CHANGELOG
All notable changes to this project will be documented in this file.

## 0.2.1 (2018-01-04)

### Fixed
- managedb failure where sudo is configured with requiretty (Jerad Jacob)

### Added
- gem httpclient requirement in metadata (Jerad Jacob)

## 0.2.0 (2017-08-04)

### Added
- pulp_rpm_repo resource which allows to manage pulp repositories directly from cookbooks
- TLS enabled tests

### Changed
- Default pulp server version to 2.13

## 0.1.2 (2017-07-18)

- Fixes server.conf location in default recipe
- Fixes messaging and task broker urls in default server config

## 0.1.1 (2017-07-14)

- Changelog file created
- Add travis-ci configuration (.travis.yml, .kitchen.dokkent.yml)
- Fix EPEL gpgkey url to avoid issues with HTTP redirects

## 0.1.0 (2017-07-12)

- Initial version
