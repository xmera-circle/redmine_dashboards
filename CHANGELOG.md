# Changelog for Redmine Dashboards

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2.0.1 - 2023-08-18

### Fixed

* scale of charts to show only integer values

### Deleted

* unused chart.js files

## 2.0.0 - 2023-04-06

### Added

* Redmine 5 Support (breaking change)
* github templates
* github actions to run automated tests

### Removed

* Chart.js from plugin in order to use the library incorporated in Redmine to version 3.7.1

## 1.1.1 - 2022-09-23

### Changed

* plugin initialization to add advanced_plugin_helper as requirement

## 1.1.0 - 2022-09-21

### Added

* calendar block
* spent time block with entries
* open approval block of redmine_dmsf
* locked files block of redmine_dmsf
* checkbox for disabling My Page

### Changes

* BasePresenter class by integrating AdvancedPluginHelper

## 1.0.4 - 2022-06-29

### Changes

* size of thumbnails of news
* news preview by showing summary but removing default image

## 1.0.3 - 2022-06-17

### Fixed

* doubling edit form when cancel diagram block
* display of issue counter when using position 'inline'

### Changed

* permission names to :manage_*


## 1.0.2 - 2022-05-01

### Changed

* width of issue counter block by removing min-width css attribute
* display of visibility settings in dashboard configurations according to the
permission

### Fixed

* missing permission to change contents on a dashboard when allowed to change
dashboard configuration

## 1.0.1 - 2022-04-28

### Changed

* custom css styles of issue counters to be in the cached block

## 1.0.0 - 2022-03-04

### Added

* issue counter block
* redmine default charts as block
* button block
* button macro
* block settings validation

### Changed

* permissions
* latest news block styling
* block rendering
* dashboard layout


### Fixed

* failing redmine tests
* missing translations for error messages

## 0.1.0 - 2022-01-27

### Added

* dashboards feature on welcome page from Additional plugin
