---
title: Multicast Network Address Translation
abbrev: MNAT
docname: draft-jholland-mboned-mnat-00
date: 2020-10-31
category: std

ipr: trust200902
area: Ops
workgroup: Mboned
keyword: Internet-Draft

stand_alone: yes
pi: [toc, sortrefs, symrefs]

author:
 -
    ins: J. Holland
    name: Jake Holland
    org: Akamai Technologies, Inc.
    street: 150 Broadway
    city: Cambridge, MA 02144
    country: United States of America
    email: jakeholland.net@gmail.com

normative:
  RFC2119:
  RFC3810:
  RFC3376:
  RFC4604:
  RFC4607:
  RFC6763:
  RFC7950:
  RFC8040:
  RFC8174:
  RFC8340:

informative:
  RFC3688:
  RFC6020:
  RFC6335:

--- abstract

XXXX

--- middle

# Introduction

XXXX

## Motivation

XXXX

## Background

The reader is assumed to be familiar with the use of DNS-SD {{RFC6763}} for discovery of services provided by the network to end hosts.

The reader is also assumed to be familiar with the concepts and terminology regarding source-specific multicast as described in {{RFC4607}} and the use of IGMPv3 {{RFC3376}} and MLDv2 {{RFC3810}} for group management of source-specific multicast channels, as described in {{RFC4604}}.

The reader is also assumed to be familiar with the concepts and terminology for RESTCONF {{RFC8040}} and YANG {{RFC7950}}.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in {{RFC2119}} and {{RFC8174}} when, and only when, they appear in all capitals, as shown here.

## Notes for Contributors and Reviewers

Note to RFC Editor: Please remove this section and its subsections before publication.

This section is to provide references to make it easier to review the development and discussion on the draft so far.

### Venues for Contribution and Discussion {#venue}

This document is in the Github repository at:

https://github.com/GrumpyOldTroll/draft-ietf-mnat

Readers are welcome to open issues and send pull requests for this document. 

Please note that contributions may be merged and substantially edited, and as a reminder, please carefully consider the Note Well before contributing: https://datatracker.ietf.org/submit/note-well/

Substantial discussion of this document should take place on the MBONED working group mailing list (mboned@ietf.org).

 * Join: https://www.ietf.org/mailman/listinfo/mboned
 * Search: https://mailarchive.ietf.org/arch/browse/mboned/

# Protocol Operation

XXXX

# YANG Model {#model}

## Yang Tree

The tree diagram below uses the notation defined in {{RFC8340}}.

~~~~~~~~~
YANG-TREE ietf-mnat.yang
~~~~~~~~~
{: title="MNAT Tree Diagram" }

## Yang Module

~~~~~~~~~
YANG-MODULE ietf-mnat.yang
~~~~~~~~~

# IANA Considerations

## The YANG Module Names Registry

This document adds one YANG module to the "YANG Module Names" registry maintained at \<https://www.iana.org/assignments/yang-parameters\>.
The following registrations are made, per the format in Section 14 of {{RFC6020}}:

~~~
      name:      ietf-mnat
      namespace: urn:ietf:params:xml:ns:yang:ietf-mnat
      prefix:    mnat
      reference: I-D.draft-jholland-mboned-mnat
~~~

## The XML Registry

This document adds the following registration to the "ns" subregistry of the "IETF XML Registry" defined in {{RFC3688}}, referencing this document.

~~~
       URI: urn:ietf:params:xml:ns:yang:ietf-mnat
       Registrant Contact: The IESG.
       XML: N/A, the requested URI is an XML namespace.
~~~

## The Service Name and Transport Protocol Port Number Registry

This document adds one service name to the "Service Name and Transport Protocol Port Number Registry" maintained at \<https://www.iana.org/assignments/service-names-port-numbers\>.
The following registrations are made, per the format in Section 8.1.1 of {{RFC6335}}:

~~~
     Service Name:            mnat
     Transport Protocol(s):   TCP, UDP
     Assignee:                IESG <iesg@ietf.org>
     Contact:                 IETF Chair <chair@ietf.org>
     Description:             The MNAT service (RESTCONF that
                              includes ietf-mnat YANG model)
     Reference:               I-D.draft-jholland-mboned-mnat
     Port Number:             N/A
     Service Code:            N/A
     Known Unauthorized Uses: N/A
     Assignment Notes:        N/A
~~~

# Security Considerations {#security}

TBD.  (What, me worry?)

# Acknowledgements

Thanks.

