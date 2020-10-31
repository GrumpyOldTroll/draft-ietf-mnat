# (unadopted draft to be presented to mboned): draft-jholland-mboned-mnat

This repo is for the Internet Draft for MNAT (Multicast Network Address Translation).

**Contributions to this repository (commits and pull requests, as well as issues and comments) are covered under the IETF Note Well.** See [CONTRIBUTING.md](CONTRIBUTING.md) for more.

# Building the drafts

The build system for these drafts currently uses [an aging fork of i-d-template](https://github.com/GrumpyOldTroll/i-d-template/tree/yang-support) derived from the [upstream version](https://github.com/martinthomson/i-d-template), but adding some functionality intended to make it easier to work with [YANG](https://tools.ietf.org/html/rfc7950) models and their examples.  There was a [pull request](https://github.com/martinthomson/i-d-template/pull/193) submitted, but the comments have not yet been addressed and code re-submitted.  During the make, additional features validate examples against the YANG schema, and produce warning and error messages for YANG models that do not pass the yanglint checks.

In addition to [xml2rfc](https://github.com/martinthomson/i-d-template/blob/main/doc/SETUP.md#xml2rfc) and [kramdown](https://github.com/martinthomson/i-d-template/blob/main/doc/SETUP.md#kramdown-rfc2629), these drafts require pyang and [libyang](https://github.com/CESNET/libyang) (including yanglint):

~~~
python3 -m venv ~/venv-drafts
source ~/venv-drafts/bin/activate
python -m pip install xml2rfc pyang
~~~

