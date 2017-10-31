---
title: 'PFEIFER: Preprocessing Framework for Electrograms Intermittently Fiducialized from Experimental Recordings '
tags:
  - Electrogram
  - Electrocardiogram
  - Ischemia
  - Fiducial
  - Cardiac
  - Signal processing
  - MATLAB 

authors:
 - name: Anton Rodenhauser
   orcid: 0000-0003-1077-8230
   affiliation: 2
 - name: Wilson W Good 
   orcid: 0000-0002-0111-9076
   affiliation: 1 2
 - name: Brian Zenger 
   orcid: 0000-0002-0039-9184
   affiliation: 1 2
 - name: Jess Tate 
   orcid: 0000-0002-2934-1453
   affiliation: 1 2
 - name: Kedar Aras 
   orcid: 0000-0002-9898-1462
   affiliation: 1 2
 - name: Brett Burton 
   orcid: 0000-0002-3971-4225
   affiliation: 1 2
 - name: Rob S. MacLeod 
   orcid:  0000-0002-0000-0356
   affiliation: 1 2

affiliations:
 - name: University of Utah Bioengineering Department
   index: 1
 - name: Scientific Computing and Imaging Institute
   index: 2
date: 25 October 2017
bibliography: josspaper.bib
---

# Summary

##High Level Functionality

Preprocessing Framework for Electrograms Intermittently Fiducialized from
Experimental Recordings (PFEIFER) is a MATLAB Graphical User Interface designed
to process bioelectric signals acquired from experiments.  
PFEIFER was specifically designed to process electrocardiographic
recordings from electrodes placed on or around the heart or on the body
surface.  Specific steps included in
PFEIFER allow the user to remove some forms of noise, correct for
signal drift, and mark specific instants or intervals in time
(fiducialize) within all of the time sampled
channels. PFEIFER includes many unique features that allow the user to
process electrical signals in a consistent and time efficient manner, with
additional options for advanced user configurations and input. PFEIFER is
structured as a consolidated framework that provides many
standard processing pipelines but also has flexibility to allow the user to
customize many of the steps. PFEIFER allows the user to import time
aligned cardiac electrical signals, semi-automatically determine
fiducial markings from those signals, and perform computational tasks that prepare the signals for subsequent display and analysis.

##Statement of Need

 Time signals recorded
from typical experiments in cardiac electrophysiology require a
substantial amount of processing before they can be used for diagnostic or
analytical purposes. However, these processing steps
are rarely described in adequate
detail in literature. Until now, there has also been a scarcity of
commonly available software tools, each group creating one-off tools for
their exclusive use.  This lack of shared tools, code, and even detailed algorithms has
made comparisons across labs impossible.  Rather then refining and
improving these techniques, each lab has been required to traverse their
own learning curve, repeat mistakes of others, and produce results that
lack the confidence of robust and well tested processing.

PFEIFER provides both a set of open source tools to share with other
groups as well as a common framework within which these processing
steps can be performed.  Because the
framework is modular, flexible, and open source, written in a simple, high
level language, other groups can easily replace or add functionality to
suit there needs and compare results with other groups using the same
tools. In addition to flexibility, PFEIFER has very little computational
overhead so that it can efficiently process tens and even hundred of
independent channels of time signals.

Of special note is that PFEIFER also contains built in functionality
for significantly reducing overall experiment processing time by
semi-automatically fiducializing the time signals, which are
assumed to be approximately periodic, e.g., a sequence of heart
beats. This capability is novel and we know of no other published
description that achieves these goals. The combination of flexibility,
minimal computational requirements, time saving algorithms,
and a structured framework easy to modify and extend makes PFEIFER the
ideal toolkit for researchers processing cardiac electrical signals.


---
nocite: | 
  @Good2016, @MacLeod2005, @Swenson2011, @Aras2014, @Aras2016
---

# References

  
