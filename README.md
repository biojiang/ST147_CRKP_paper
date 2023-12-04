# ST147 CRKP paper
## Workflow for the CRKP ST147 paper.

This repository includes a collection of code and scripts used in the paper "Plasmid and anti-plasmid systems drive molecular evolution of an epidemic multidrug resistant Klebsiella pneumoniae clone".
## 1. Softwares
- [AMRFinderPlus](https://github.com/ncbi/amr) v3.10.20
- [ARIBA](https://github.com/sanger-pathogens/ariba) v2.14.6
- [ABRicate](https://github.com/tseemann/abricate) v1.0.0
- [BLAST](https://ftp.ncbi.nlm.nih.gov/blast/executables/LATEST/) v2.12.0
- [BactDating](https://github.com/xavierdidelot/BactDating) v1.1
- [bwa](https://bio-bwa.sourceforge.net/bwa.shtml) v0.7.17
- [cctyper](https://github.com/Russel88/CRISPRCasTyper) v1.8.0
- [Easyfig](https://mjsull.github.io/Easyfig/) v2.2.2
- [ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html) v3.4.4
- [Gubbins](https://github.com/nickjcroucher/gubbins) v3.0.0
- [iTOL](https://itol.embl.de/) v5
- [Kleborate](https://github.com/klebgenomics/Kleborate) v2.3.2
- [LongRepMarker](https://github.com/Xingyu-Liao/LongRepMarker_v2.0) v2.1.2
- [minicoda](https://docs.conda.io/projects/miniconda/en/latest/) v23.1.0
- [MUMmer](https://github.com/mummer4/mummer) v4.0.0
- [mlst](https://github.com/tseemann/mlst) v2.22
- [PHASTEST](https://phaster.ca/)
- [Prokka](https://github.com/tseemann/prokka) v1.14.5
- [Perl](https://www.perl.org/) v5.32.1
- [Python](https://www.python.org/) v3.10.8
- [R](https://www.r-project.org/) v4.2.2
- [RAxML](https://github.com/amkozlov/raxml-ng) v1.0.1
- [Snippy](https://github.com/tseemann/snippy) v4.6.0
- [SPAdes](https://github.com/ablab/spades) v3.13.0
- [wgsim](https://github.com/lh3/wgsim)

## 2. Dataset
All assembled Illumina sequence data have been deposited in GenBank under the BioProject accession number [PRJNA549322](https://www.ncbi.nlm.nih.gov/bioproject?LinkName=nuccore_bioproject&from_uid=1879540806).

## 3. Commands
Take the 44383 isolate as an example.
1. Assembly
  SPAdes
```
spades.py -1 44383_R1.fastq.gz -2 44383_R2.fastq.gzz --cov-cutoff auto -o 44383
``` 





