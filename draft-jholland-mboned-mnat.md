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
  RFC8641:

informative:
  RFC2663:
  RFC3397:
  RFC3688:
  RFC6020:
  RFC6202:
  RFC6335:
  RFC7761:
  RFC8815:

--- abstract

This document defines a method for a network to maintain Network Address Translation address mappings for the transport of globally addressed multicast traffic within a network that can't otherwise forward the globally addressed traffic.
A new Multicast Network Address Translation (MNAT) service is defined to communicate the address mappings to ingress and egress points within the network, and considerations for operation of the MNAT service are described.

--- middle

# Introduction

Network Address Translation is very widely used for unicast traffic in a variety of networks and according to a variety of mechanisms.
{{RFC2663}} is recommended reading for background on the ways unicast NAT is used.

The handling of multicast traffic can pose a variety of additional problems for a network, some of which can be mitigated or avoided if traffic can be mapped to a different address space than its original addressing.
This document defines a new service, Multicast Network Address Translation (MNAT), as a mechanism to administer network address mappings for multicast traffic within a network, for the purpose of working around various addressing-related issues.
An overview of some of the motivating use cases that require network address remapping for multicast traffic is given in {{motivation}}.
An explanation of the protocol operation is given in {{protocol}}.

Messaging to and from the MNAT service is defined with RESTCONF {{RFC8040}} using the YANG {{RFC7950}} model in {{model}}.

Unlike traditional unicast NAT, MNAT performs address translation at both an ingress point to the network where the traffic is transformed to use an address scheme local to the network, and also at an egress point from the network where the traffic is transformed back to the original address scheme for further forwarding, or for further processing by a receiving application.

## Background

The reader is assumed to be familiar with the concepts and terminology regarding source-specific multicast as described in {{RFC4607}} and the use of IGMPv3 {{RFC3376}} and MLDv2 {{RFC3810}} for group management of source-specific multicast channels, as described in {{RFC4604}}.

The reader is also assumed to be familiar with the concepts and terminology for RESTCONF {{RFC8040}} and YANG {{RFC7950}}.

The reader is also assumed to be familiar with the use of DNS-SD {{RFC6763}} for discovery of services provided by the network to end hosts.

## Terminology

   Term | Definition
   ----:|:----------
  (S,G) | A source-specific multicast channel, as described in {{RFC4607}}. A pair of IP addresses with a source host IP and destination group IP.
  egress node | A MNAT client operating at a point where NATted multicast traffic exits the network (close to the receiver)
  ingress node | A MNAT client operating at a point where multicast traffic enters the network and gets NATted (close to the sender)
  MNAT client | A client using the ietf-mnat YANG model via RESTCONF, or a client with equivalent signaling to an MNAT service.
  NATted traffic | Multicast traffic that has been translated to use addressing or encapsulation assigned locally within the network, rather than its original global addressing.
  SSM | Source-specific multicast, as described in {{RFC4607}}

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in {{RFC2119}} and {{RFC8174}} when, and only when, they appear in all capitals, as shown here.

## Motivation {#motivation}

This section lists use cases where a global (S,G) may not be possible to transport within a network, requiring the use of some kind of encapsulation or address translation in order to adequately communicate the group membership for packet replication within the network, or in order to perform the forwarding for the subscribed traffic within the network.

 * Global IPv6 (S,G)s subscribed from within an IPv4-only network, or global IPv4 (S,G)s subscribed from within an IPv6-only network.
 * Networks with legacy devices that support only IGMPv2 or MLDv1, or otherwise do not support SSM and cannot discover the external sources without the use of non-standard services since interdomain any-source multicast has been deprecated (see {{RFC8815}}).
 * Networks that ingest external multicast traffic in a way that the route to the source of the traffic does not go through the ingest point may need to use a different source so that the Reverse Path Forwarding (RPF) can find the correct network location for the ingest.
 * Networks that provision multicast transport and packet replication channels with static routing instead of dynamic tree-building protocols like PIM-SM {{RFC7761}}.

A note elaborating on the use of static routing for multicast groups:

Some networks have found that there are good use cases to deliver a limited set of packet-replicating flows, including sometimes the use of externally sourced multicast traffic, but have struggled with the operational complexity of operating a dynamic tree-building system based on PIM-SM {{RFC7761}}.
Operating an MNAT service can allow these networks to provide for the limited use of packet-replicating data channels while keeping the operational complexity of handling a dynamically changing set of channels confined to a single service that implements their business logic for admission control, rather than trying to apply access control lists for group membership propagation spread across the network.

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

# Protocol Operation {#protocol}

## Overview

The use of MNAT within a network is defined in terms the folowing entities:

 * MNAT service
 * ingress nodes
 * egress nodes

Address translation is performed at the ingress (closest to the sender) and egress (closest to the receiver) nodes.
Ingress is where an external (S,G) is mapped to locally assigned address mapping before being forwarded for transport within the network.
Egress is where the traffic received on locally assigned addresses is translated back to the corresponding external (S,G) address before being forwarded for further transmission or processed by a receiving application.

The MNAT service maintains the mapping between external (S,G)s and the local network addresses used to transport traffic of those (S,G)s within the network.
The address mapping is performed according to the needs of the network operating the MNAT service, to satisfy whatever constraints and restrictions may be necessary or desirable according to the operational considerations within that network.
Some example considerations that have motivated the design of MNAT are described in {{motivation}}.

Ingress and egress nodes communicate with the MNAT service according to the schema defined by the YANG model in {{model}}.
In particular, they maintain an up-to-date table of the mappings between the external (S,G)s and the locally assigned addresses for transport within the network in order to perform the corresponding network address translations.

TBD: probably add a diagram here.
Probably something roughly similar to page 7 of the IETF 108 mboned presentation touching on this: https://www.ietf.org/proceedings/108/slides/slides-108-mboned-status-update-on-multicast-to-the-browser-00.pdf#page=7

### Egress Node Operational Modes {#virtual}

Egress nodes can run in at least two separate modes of operation.

One of the modes is "bump in the wire", which refers to a node that receives traffic using the network-assigned locally chosen addresses, and translates the traffic back to the associated externally addressed (S,G) before forwarding the traffic along the rest of the network paths to the receiving applications that tried to join the external (S,G).

The second mode is "bump in the host", which refers to a virtual node operating inside a client application.

As a "bump in the host" egress node, the virtual egress node can discover and connect to the MNAT service from a receiving application.
The receiving application would then use the knowledge about the address mapping within the network to perform a join for the mapped addresses in the local network, rather than for the external (S,G), treating the payloads of the packets received as though they arrived with the external (S,G) addressing.

A common scenario for a bump in the wire egress node deployment might be to have egress nodes operating in Customer Premises Equipment (CPE), such as a Cable Modem or Wi-Fi router inside the home of a customer to a multicast-capable Internet Service Provider (ISP).
In this scenario, the egress node discovery mechanism for the MNAT service might be a static configuration for the MNAT service's hostname, pushed by the ISP to the CPE devices.

For a bump in the host egress node, the discovery of the MNAT service might either operate via DNS-SD {{RFC6763}} using a search domain for the ISP distributed to hosts via a DHCP Domain Search option {{RFC3397}}, or via configuration instructions the ISP gives to their customers to configure a search domain for their devices, or to configure the MNAT service's hostname for that ISP in their applications.

## Service Discovery

It is RECOMMENDED that a network operating an MNAT service provide service discovery with the use of DNS-SD {{RFC6763}}.
However, a network MAY use other mechanisms, including options such as manual configuration.
As long as an MNAT client can find a valid hostname to use, it can connect to the given MNAT service and monitor changes to the address assignments within the network.

### Detecting Invalid Services

TBD: recommendations for noticing and discontinuing use of MNAT services that report mappings that don't correspond to the mappings apparently in use in the client's local network (particularly from egress nodes).

## RESTCONF Bootstrap

TBD: describe the RESTCONF validation and bootstrapping steps.
Use the same section name from I-D.draft-ietf-mboned-dorms as a template, assuming it passes a wider review.

## Message Handling

### Notification Subscription

When possible, changes to the group assignments should be communicated with subscriptions to data model updates using a server push mechanism, for example as described in {{RFC8641}}.

Where clients or servers do not support server push updates, long polling can be used instead to provide timely updates.  See {{RFC6202}} for an explanation of the approach and a discussion of its pros and cons.

If long polling and server push are both unavailable, MNAT clients may need to poll the server to monitor updates instead.
This approach is likely to encounter delays in the detection of changes to mapping decisions within the MNAT service, but can be used as a last resort for providing multicast connectivity.

### Egress Keys

Egress nodes open a persistent connection to the MNAT service and request allocation of an egress key with the get-new-egress-key rpc.
Egress keys are identifiers chosen by the MNAT service and communicated to egress nodes in the response to a successful get-new-egress-key rpc.
Egress keys SHOULD be based on a random value and unique per new key requested.

Egress nodes provide their egress key when performing group management functions (join and leave operations).

TBD: better explanation about how the service times out egress nodes that don't refresh their egress key on schedule, and how egress nodes that reconnect can attempt to refresh the prior key they were using, but must request a new one on error.
Probably define a state per egress key (e.g. active vs. recently expired vs. non-existant) for the MNAT service to maintain.
Explain how the MNAT service should use population count from the egress joins to make prioritization decisions for the assignment of flows when there is limited flow space.
Probably reference CBACC in that explanation (I-D.draft-ietf-mboned-cbacc).

### Egress Group Management

The join-global and leave-global RPCs in the YANG model provide a mechanism for egress nodes to directly advertise their group membership to the MNAT service for externally addressed (S,G)s.

Egress nodes advertise their group membership to external (S,G)s to the MNAT service and also advertise group membership to their next-hop router using IGMP or MLD for the locally mapped addressing withing the network.
Joins and leaves for the locally mapped network addresses occur in response to downstream joins for an external (S,G) that has or gains a mapping according to the MNAT service, when the join or leave propagates to the egress node.

Payloads of the locally mapped traffic should be treated as though they were carried in packets addressed as the external (S,G), including any authentication checks that should be performed for the traffic.
Egress nodes that forward traffic (non-virtual egress nodes) will perform an address translation from the locally mapped addressing to the original (S,G) (according to the address mapping the MNAT service provides) before forwarding packets matching a locally mapped address.
It is the responsibility of the MNAT service and the network that operates it to ensure that multiple different traffic streams are not merged to the same locally mapped addresses in a way that collides.

### Ingress Considerations

Like egress nodes, ingress nodes monitor the assignments provided by the MNAT service and perform network address translation and group membership propagation.
Ingress nodes perform the translation from an external (S,G) to the internally mapped addressing for the local network transport.

In general, ingress nodes are translating traffic before the in-network multicast fanout to multiple egress nodes.
So an ingress node is generally assumed to be feeding one or more egress nodes.
Because one ingress node can feed many egress nodes, ingress nodes should be given priority ahead of egress nodes for notifications about changes to the address mapping from the MNAT service.

### MNAT Service Considerations

The details of the address assignment strategies used by the internal logic of the MNAT service are out of scope for this document.
Different instances of MNAT services are expected to use a wide range of considerations specific to the networks in which the instances operate.

However, outside of address assignment there are some operational points an MNAT service instance should take into consideration:

 1. Assignment Transition Grace Period

    It's recommended to provide a grace period between reassigning a local address mapping to a new external (S,G) after unassigning its mapping to an old (S,G).
    The grace period should account for the expected time for the connected ingress and egress nodes to process the unassigning of the external (S,G) and for egress nodes to perform leave operations for the old locally mapped address, and for the leave operations to propagate through the network.

 2. Scaling

    The MNAT service should be appropriately provisioned to support the expected number of ingress and egress nodes within the network.
    In an eyeball network, restrictions on the number of egress nodes per shared receiver IP address may be appropriate, to avoid a rogue client application from forming an excessive number of egress connections.
    Alternately, for bump-in-the-wire deployments of egress nodes in CPE devices it may be appropriate to authenticate the egress connections with a client certificate for each home to avoid denial of service attacks based on overloading the MNAT service with egress connections.

    Additionally, it's RECOMMENDED to provide per-egress limits on the number of external simultaneous (S,G)s permitted per egress at a level appropriate to the scaling limitations for the network, to avoid denial of service attacks based on overloading the group assignments.

### Example Messaging Walkthrough

TBD: show what an expected example message sequence or 2 would look like.

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

Notable points to cover:

 * communcation with the MNAT service should be secured.  RESTCONF does this, alternate methods should also do it.
 * separate authentication of the contents of the multicast traffic is recommended.
 * mistaken mappings can result in receipt of payloads for the wrong channel.  This can happen transiently even during normal operation.  Recommend some steps to mitigate and avoid.
 * Clients can (deliberately or accidentally) overload the service.  Limits should be set to avoid disrupting traffic to the rest of the network.

# Acknowledgements

Thanks to Lenny Giuliano for very helpful comments on this document.

