# Readme

## Table of Contents

<!-- TOC -->

- [Readme](#readme)
    - [Table of Contents](#table-of-contents)
    - [Workflow Status](#workflow-status)
    - [Description](#description)
    - [Inputs](#inputs)
    - [Outputs](#outputs)
    - [Secrets](#secrets)
    - [Environment Variable](#environment-variable)
    - [Example](#example)
    - [Further Information](#further-information)
        - [Calendar Versioning Scheme](#calendar-versioning-scheme)
            - [Available options](#available-options)
            - [Examples](#examples)
            - [TimeZones](#timezones)

<!-- /TOC -->

## Workflow Status

| Status | Description |
| :----- | :---------- |
| ![Dependabot](https://api.dependabot.com/badges/status?host=github&repo=salt-labs/action-release-prepper) | Automated dependency updates |
| ![Greetings](https://github.com/salt-labs/action-release-prepper/workflows/Greetings/badge.svg) | Greets new users to the project. |
| ![Kaniko](https://github.com/salt-labs/action-release-prepper/workflows/Kaniko/badge.svg) | Testing and building containers with Kaniko |
| ![Labeler](https://github.com/salt-labs/action-release-prepper/workflows/Labeler/badge.svg) | Automates label addition to issues and PRs |
| ![Release](https://github.com/salt-labs/action-release-prepper/workflows/Release/badge.svg) | Ships new releases :ship: |
| ![Stale](https://github.com/salt-labs/action-release-prepper/workflows/Stale/badge.svg) | Checks for Stale issues and PRs  |

## Description

<!--
A detailed description of what the action does.
-->

A GitHub Action to prepare for shipping time. 🚢

This is a simple and opinionated Action that works by automating release tags using a [Calendar Versioning](https://calver.org) scheme.

The Action can also generate a basic Changelog between ```HEAD``` and the last applied tag.

The outputs from this Action can then be used to pass to ```actions/create-release```.

## Inputs

<!--
Descriptions for all the inputs available in this Action
-->
The following inputs are available:

| Input | Required | Description | Default | Examples |
| :---- | :------- | :---------- | :------ | :------ |
| log_level | False | Sets the log level for debugging purposes | ```INFO``` | ```DEBUG```</br>```INFO```</br>```WARN```</br>```ERR``` |
| tag_enable | False | Enable to apply a git tag. Disable if you just want release notes output. | ```FALSE``` | ```TRUE```</br>```FALSE``` |
| tag_force | False | Enable to force applying the tag. This will move a past tag if there was a CalVer scheme collision. </br></br>When disabled an error will not be thrown so the build will pass, there will just be no new tag applied. | ```FALSE``` | ```TRUE```</br>```FALSE``` |
| git_pretty_format | False | The format to provide to ```git log --pretty``` | ```* %G? %h %aN %s"``` | |
| calver_scheme | False | The CalVer scheme to use. Refer to the details below. | ```YYYY.0M.0D-GEN``` | ```YYYY.0M.0D-GEN-dev``` |
calver_split | False | The separator to use between ```MAJOR MINOR MICRO MODIFIER``` | ```.``` | ```-``` | ```.``` |
| calver_split_mod | False | The separator to use between ```MICRO``` and ```MODIFIER```. </br></br>Defaults to the same as ```calver_split``` | ```.``` | ```-``` | ```.``` |
| timezone | False | The timezone to export the CalVer in | UTC-0 | [Examples](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones "TZ Database Time Zone") |

## Outputs

<!--
Descriptions for all the outputs available in this Action
-->

The following outputs are available:

| Output | Description | Example |
| :----- | :---------- | :------ |
| changelog | A Changelog between ```HEAD``` and the last tag | ```* This is an amazing commit message``` |
| calver | Calendar Version generated in the provided scheme | ```2020.05.01-alpha``` |
| repo_owner | The GitHub repository organisation or owner | ```salt-labs``` |
| repo_name | The GitHub repository name | ```action-release-prepper``` |

## Secrets

<!--
Descriptions for all the secrets required by this Action
-->

The following secrets are used by the Action:

| Secret | Description | Example |
| :----- | :---------- | :------ |
| GITHUB_TOKEN | The GitHub Token to push the modified tags | ```${{secrets.GITHUB_TOKEN}}``` |

## Environment Variable

<!--
Descriptions for all the environment variables used by the Action
-->

- None

## Example

Refer to the included [examples](./examples "examples") directory.

## Further Information

### Calendar Versioning Scheme

The [CalVer scheme](https://calver.org) is summarised as follows: ```MAJOR.MINOR.MICRO.MODIFIER```

- **Major** - The first number in the version. The major segment is the most common calendar-based component.
- **Minor** - The second number in the version.
- **Micro** - The third and usually final number in the version. Sometimes
  referred to as the "patch" segment.
- **Modifier** - An _optional_ text tag or revision number, such as "dev", "alpha", "beta",
  "rc1", "3".

The vast majority of modern version identifiers are composed of two or
three numeric segments, plus the optional modifier. Convention
suggests that four-numeric-segment versions are discouraged.

#### Available options

- **`YYYY`** - Full year - 2006, 2016, 2106
- **`YY`** - Short year - 6, 16, 106
- **`0Y`** - Zero-padded year - 06, 16, 106
- **`MM`** - Short month - 1, 2 ... 11, 12
- **`0M`** - Zero-padded month - 01, 02 ... 11, 12
- **`WW`** - Short week (since start of year) - 1, 2, 33, 52
- **`0W`** - Zero-padded week - 01, 02, 33, 52
- **`DD`** - Short day - 1, 2 ... 30, 31
- **`0D`** - Zero-padded day - 01, 02 ... 30, 31
- **`GEN`** - Increment a number based on the last found Git tag for this numeric segment.

#### Examples

| Syntax | Output |
| :---------- | :---------- |
| ```YYYY.MM.GEN``` | ```2020.6.1``` |
| ```YYYY.0D.0M-GEN``` | ```2020.25.05-1``` |
| ```YYYY.0D.GEN``` | ```2020.25.1```
| ```YY-MM-0W``` | ```20-5-21``` |
| ```YY-MM-0W.GEN``` | ```20-5-21.1``` |
| ```YY.MM-GEN``` | ```20.5-1``` |

#### TimeZones

A list of available TZ Database time zones are available [HERE](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones "TZ Database Time Zone").
