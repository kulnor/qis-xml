# qis-xml v1.1 (draft)
***A metadata specification for Quantum Information Science***

QIS-XML is an XML specification for the management of metadata in Quantum Information Science (QIS). Its purpose is to provide a standard model and tools to describe and exchange knowledge about fundamental entities in order to maximize classsic and quantum systems inter-operability. 

The main objectives of QIS-XML are:

* Provide a standard mechanism to describe quantum gates, quantum circuits, quantum pseudo-code, and quantum device capabilities
* Ensure inter-operability of quantum systems with classic computers
* Facilitate the integration of quantum technology in existing Information and Communication Technology (ICT) infrastructure
* Provide a framework for the storage and exchange of information by QIS software
* Build the foundation for quantum compilers and procedure calls
* Support the development of educational tools
* Foster a better understanding of QIS amongst ICT experts

Version 1.0 of QIS-XML was originally published at [qisxml.org](http://www.qisxml.org) in 2011 at the conclusion of my [MS Thesis](http://arxiv.org/abs/1106.2684). Work started on version 1.1 in the summer of 2016 and is in progress. 

This version aims at:

* Generally improving / enhancing version 1.0
* Adding features to describe quantum device capabilities
* Adding a [YANG](https://en.wikipedia.org/wiki/YANG) version of the model to enable integration with [NETCONF](https://en.wikipedia.org/wiki/NETCONF)
* Collapsing the specification in a single namespace to simplify usage and adoption *[completed]*
* Potentially adding support for [QMI](http://www.dwavesys.com/software) programming model used by D-Wave (annealing)

# How to navigate
* High level background and project overview is provided below
* The XML schema specification is in the ```xsd``` directory and the YANG model under ```yang```
* Examples and official reference libraries in the ````xml``` directory 


#QIS-XML Overview
* [Background](#background)
* [What is Quantum Information Science?](#about-qis)
* [What is XML?](#about-qis)
* [What is QIS?](#about-qis)
* [What is QIS-XML?](#about-qisxml)
* [QIS-XML Status](#status)

<a name="bg"></a>
## Background
While Quantum Information Science (QIS) is still in its infancy, the ability for quantum based hardware or computers to communicate and integrate with their classical counterparts will be a major requirement towards their success. Little attention however has been paid to this aspect of QIS. To manage and exchange information between systems, today's classic Information Technology (IT) commonly uses the eXtensible Markup Language (XML) and its related tools. XML is composed of numerous specifications related to various fields of expertise. No such global specification however has been defined for quantum computers. QIS-XML is a proposed XML metadata specification for the description of fundamental components of QIS (gates & circuits) and a platform for the development of a hardware independent low level pseudo-code for quantum algorithms.

<a name="about-qis"></a>
## What is Quantum Information Science?
Quantum Information Science (QIS) concerns information science that depends on quantum effects in physics. QIS technology differentiates itself from classic computers by building upon quantum physics and quantum mechanical effects such as entanglement, interference, superposition, and and non-determinism. Quantum based computing can in some case provide tremendous boost in performance and solve problems that otherwise could take a very long time to compute (only a few such algorithms however have been designed to date). In QIS, many concepts familiar to the Classic Information Science (CIS) get transformed to their quantum equivalent. A classic bit for example becomes a qubit (and can behave quit differently). Instead of using logical electronic gates, quantum gates are assembled to form quantum circuits and execute quantum algorithms.

Quantum computers are currently at a very experimental stage. No production system is in existence and, while small prototypes are being tested in the laboratories (using a few qubits), we may not see such reality before 10,20 or even more. The main challenge is that, while we do understand the underlying physics, the engineering to build such systems is not available. Nevertheless, quantum hardware is an unavoidable outcome. According to Moore's law, we double the number of transistors that can be place in a processor every couple of year. This shrinking process cannot continue indefinitely and we will in the next 10 to 20 year read the size a single atoms at which level quantum mechanical effects can no longer be ignored. While we may therefore not immediately take advantage quantum algorithm, classic computers will soon have to operate on quantum hardware.

Learning Quantum Information Science is a fascinating experience. It is also mind boggling process that will change your vision and understanding of the world if you are not yet familiar with the weirdness of quantum mechanics. Various research papers, publications and web site are available on the topic.
 
<a name="about-xml"></a>
## What is XML?

<a name="about-xml=metadata"></a>
### What is metadata?
In the computer world, information collected on objects or data is commonly referred to as "Metadata". While many definitions exist for this term, the general consensus is to say that Metadata is "Data bout Data". Metadata does not change anything about the item it describes but rather defines its nature but attaching a set of descriptive attributes to the object. Simple examples are the title of a book, the brand or the color of a car, the name of a person, the number of calories of a food item, etc.

An important aspect of metadata is that it can be stored, accessed or exchanged with having to pass along the underlying objects. We can browse a library catalog remotely or select a car from a brochure with going to the dealership. In a similar way, we could get describe quantum hardware, gates, circuits or algorithms with getting actual access to a real quantum computer, whether it exists or not.

<a name="about-xml-xml"></a>
### What is the eXtensible Markup Language (XML)?
Nowadays, information systems commonly capture metadata using a format called the Extensible Markup Language or XML. It is a system that "tags" or "markups" elements of information and stores them in a standard text format that can be read by any computer. XML is used everywhere on the Web, in particular to exchange information between organizations. It has emerged in recent years as a dominant technology. While invisible to most end users, XML is driving today's' Internet.

XML is actually a term that encompasses several technologies and functionalist. Adopting XML as a common language allows information systems not only to capture metadata (in XML) but also to validate it against agreed upon specifications (using DTD or XSchema), transform it to other formats such as HTML or PDF(using XSLT), search it to build catalogs and lookup information (using XPath or XQuery), exchange it (using SOAP based web services) and even edit it (using XForms). All these functionalist are inherent to the XML technology and require little efforts to implement. 

<a name="about-qisxml"></a>
## What is QIS-XML?
QIS-XML is a draft XML specification for the management of metadata in the emerging field of Quantum Information Science (QIS). The purpose of the specification is to provide a metadata model and tools to describe low level objects and concepts. A prototype module is also under development for the capture of information regarding quantum hardware.

The main objectives of QIS-XML are:

* Provide a standard mechanism to describe quantum gates, quantum circuits, quantum pseudo-code and quantum device capabilities
* Ensure Inter-operability of quantum systems with classic computer systems
* Facilitate the integration of quantum technology in existing Information and Communication Technology (ICT) infrastructure
* Provide a framework for the storage and exchange of information by QIS software
* Build the foundation for quantum compilers and procedure calls
* Support the development of educational tools
* Foster a better understanding of QIS amongst ICT experts

Version 1.0 of QIS-XML was release in 2011. For details, see ["QIS-XML: An Extensible Markup Language for Quantum Information Science", Pascal Heus, Richard Gomez, June 2011, arXiv:0712.3925v1](http://arxiv.org/abs/1106.2684)
Rationale

Quantum Information Science is in its infancy. However, while we do not know precisely when production level quantum hardware will become available, rapid progress is being made and prototype quantum systems have been demonstrated to work. QIS research however has been so far primarily lead by physicists and the ICT community has shown little interest in it. This has been an impediment to the development of QIS as it will somehow need to smoothly integrate and co-exists with classic ICT. This lack of IT expertise may also lead to improperly designed architecture or incompatible systems.

QIS-XML is an effort to address some of these issues by bridging both fields though a widely accepted technology: the eXtensible Markup Language (XML). Having an XML specification available will allow systems from both domains to understand each other. It will also familiarize IT experts with QIS technology by presenting quantum concepts through the well understood XML language. QIS will also benefit from the XML technology which will facilitate the development and harmonization of tools.

<a name="about-qisxml-researcher"></a>
### QIS-XML for the researcher

If you are a researcher in Quantum Information Science working on architecture, systems, or tools, QIS-XML will support your work by providing a solid metadata model for the description of gates, circuits an pseudo-code. By using an industry standard open technology, it will also ensure that your product will integrate smoothly within the classic information science infrastructure.

<a name="about-qisxml-ict"></a>
### QIS-XML for ICT experts

If you are an ICT expert, QIS-XML will help you understand the foundation of Quantum Information Science and facilitate the integration of local or remote quantum hardware (such as quantum co-processors) in your products. It also facilitate the development and inter-operability of software tools by ensuring a common representation framework.

<a name="about-qisxml-manufacturer"></a>
### QIS-XML for Quantum equipment manufacturers

If you are producing quantum hardware (circuits, co-processors, computers), adopting QIS-XML will facilitate the integration of your product with other systems (classic or quantum) and ensure compatibility with QIS-XML based tools. Note that this does not precludes the use of proprietary solutions but mainly provides a generic abstraction layer to exchange information with other systems or tools.

<a name="qisxml-status"></a>
## QIS-XML Status and Timeline?
QIS-XML 1.0 was initially release in June of 2011 at the conclusion of my MS thesis. It has been fairly dormant since. 

The specification has in the summer of 2016 received attention from the [IEEE working group P1913](https://standards.ieee.org/develop/project/1913.html) focusing on Software Defined Quantum Communication. This has lead to the current effort towards producing version 1.1 including a YANG version of the model to facilitate configuration and eventually operations of quantum devices using NETCONF. 

The future of QIS-XML greatly depends on its adoption and the establishment of a well supported community. An XML specification cannot be lead by individual effort and, without institutional support and adoption, such specification is not sustainable. If you are interested in the QIS-XML initiative and can potentially support to its adoption, maintenance and development, we encourage you to contact us to discuss possible collaboration options.



