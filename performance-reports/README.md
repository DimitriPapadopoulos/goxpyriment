# goxpy performance reports

This folder contains reports on the timing performance of goepxyriment.

* We are most interested by tests made with external measurement devices, e.g. an oscilloscope and a photodiode, or a [Black Box Toolkit](https://chrplr.github.io/bbtkv3/). 

* The performance can be assessed by goxpryiment's `tests/TimingTests` suite, but any other well-argued for test is acceptable.

* Each report should be put in its own subfolder of `performance_reports`

* Please use markdown format for the main page of the report. One recommendation is to use a jupiter notebook (or R notebook) to create your report, then export it to markdown (leaving the original notebook files to facilitate the analyses is good too).

* Use a [pull request](https://github.com/chrplr/goxpyriment/pulls) or send your zip file with the report, e.g. `report.md`, file (markdown format) and potential additional support files, logs, analysis scripts, images, etc. to <christophe@pallier.org>

* Please do not forget to include a precise description of the hardware used, as provided, for example, by [go-inxi](http://chrplr.github.io/go-inxi).
Without a proposer description of the hardware, the report is useless.

* If performance is not satisfying, we want to know in order to try and address the issue if it is on goxpyriment side. So do not be shy.

* If performance is good, we also want to know as this will help people select hardware.

Christophe Pallier 
