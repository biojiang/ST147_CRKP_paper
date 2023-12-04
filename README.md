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
- [bedtools](https://github.com/arq5x/bedtools2) v2.30.0
- [cctyper](https://github.com/Russel88/CRISPRCasTyper) v1.8.0
- [CD-HIT](http://weizhongli-lab.org/cd-hit/) v4.8.1
- [coda](https://cran.r-project.org/web/packages/coda/index.html) v0.19
- [dereplicator](https://github.com/rrwick/Assembly-Dereplicator) v0.3.2
- [Easyfig](https://mjsull.github.io/Easyfig/) v2.2.2
- [ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html) v3.4.4
- [Gubbins](https://github.com/nickjcroucher/gubbins) v3.0.0
- [iTOL](https://itol.embl.de/) v5
- [Kleborate](https://github.com/klebgenomics/Kleborate) v2.3.2
- [LongRepMarker](https://github.com/Xingyu-Liao/LongRepMarker_v2.0) v2.1.2
- [minicoda](https://docs.conda.io/projects/miniconda/en/latest/) v23.1.0
- [minimap2](https://github.com/lh3/minimap2) v2.26
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
- [samtools](https://github.com/samtools/samtools) v1.16.1
- [wgsim](https://github.com/lh3/wgsim)

## 2. Dataset
All assembled Illumina sequence data have been deposited in GenBank under the BioProject accession number [PRJNA549322](https://www.ncbi.nlm.nih.gov/bioproject?LinkName=nuccore_bioproject&from_uid=1879540806).

## 3. Commands
Take the 44383 isolate as an example.
- Assembly
```
#SPAdes
spades.py -1 44383_R1.fastq.gz -2 44383_R2.fastq.gz --cov-cutoff auto -o 44383
``` 
- Genome annotation
```
#Prokka
prokka 44383.fasta --genus Klebsiella --species pneumoniae --prefix 44383 --outdir 44383 
```
- Capsular type assignment and virulence genes detection
```
#Kleborate
kleborate --all -o 44383.results.txt -a 44383.fasta
```
- ST assignment
```
#mlst
mlst 44383.fasta
```
- AMR genes detection
```
#AMRFinderPlus
amrfinder -p 44383.faa -g 44383.gff -n 44383.fasta -O annotation_dir/44383 --plus

#ARIBA
ariba getref ncbi out.ncbi
ariba prepareref -f out.ncbi.fa -m out.ncbi.tsv out.ncbi.prepareref
ariba run out.ncbi.prepareref 44383_R1.fastq 44383_R2.fastq 44383.run
```

- CRISPR-Cas system detection
```
#cctyper
cctyper -t 60 44383.fasta crispr/44383

#Get all the detetced type I-E and IV-A3 CRISPR-Cas spacers
perl getSpacers.pl

#remove redundant spacers (CD-HIT)
cd-hit-est -i ST147.IE.spacers.fasta -o ST147.IE.spacers.unique.fasta -s 1 -aL 1
```

- Plasmid replicon detection
```
#abricate
abricate -db plasmidfinder --nopath --minid 95 --mincov 90 --quiet 44383.fasta > replicon/44383.tab
```

- Core SNP Phylogenetic analysis
```
#snippy
# call SNPs for multiple isolates from the same reference KP16932.
snippy-multi input.tab --ref Kp46564.gb  --cpu 64 > runme.sh
# input.tab, a tab separated input file as follows
# input.tab = ID assembly.fasta
# Isolate	/path/to/contigs.fasta
less runme.sh   # check the script makes sense
sh ./runme.sh   # leave it running over lunch

# remove all the "weird" characters and replace them with N
snippy-clean_full_aln core.full.aln > clean.full.aln 

# Gubbins
# detect recombination region
run_gubbins.py -c 64 -p gubbins clean.full.aln

# remove recombination region
snp-sites -c gubbins.filtered_polymorphic_sites.fasta > clean.core.aln
# -c only output columns containing exclusively ACGT

# RAxML
# build core SNP tree
raxmlHPC -f a -x 12345 -p 12345 -# 100 -m GTRGAMMAX -s clean.core.aln -n tree
```
- Date phylogeny
```
#BactDating, R
library(BactDating)
library(coda)
#Load date information
date <- read.table(args[3],header=T)
d <- date$Date
names(d) <- date$ID
#Load from Gubbins results
t=loadGubbins("gubbins/gubbins")
#run BactDating
res <- bactdate(t,d,nbIts=1e8,useRec=T,model="arc")
name<-paste("arc",'-','1e8','.pdf',sep="")
rname<-paste("arc",'-','1e8','.RData',sep="")
pdf(name)
plot(res,'trace')
dev.off()
print(paste('1e8',res$dic))
#save records
save(res,file=rname);
```
- Analysis of self-targeting spacers
```
#Type I-E CRISPR-Cas
perl SelfTagetedSpacersBlastn.pl genome_dir IE_self_targeted_spacers_blast_dir I-E
perl getSelfTargetedStrains.pl strain.list IE_self_targeted_spacers_blast_dir > I-E.SelfTargetedStrain.lsit
#Type IV-A3 CRISPR-Cas
perl SelfTagetedSpacersBlastn.pl genome_dir IVA3_self_targeted_spacers_blast_dir IV-A3
perl getSelfTargetedStrains.pl strain.list IVA3_self_targeted_spacers_blast_dir > IV-A3.SelfTargetedStrain.lsit
```
- Synteny analysis of self-targeting sequence and carbapenemas-encoding genes
```
#minimap2
minimap2 -x asm5 -t 60 NCBI.Kp.plasmid.fasta 44383.fasta > minimap_dir/44383.plasmid.map

#bwa, samtools and bedtools
bwa index 44383.fasta
bwa mem -t 32 44383.fasta 44383_R1.fastq.gz -2 44383_R2.fastq.gz|samtools view -b -F 4 --threads 8 - | samtools sort --threads 8 - | bedtools genomecov -ibam - -dz > ./coverage_dir/44383.cov.bed

#LongRepMarker
java LongRepMarker -r 44383.fasta -o repeat_dir/44383.repeat

#Type I-E CRISPR-Cas self targeted spacers
perl getDirectEvidence.pl IE_self_targeted_spacers_blast_dir > IE_self_targeted_spacers.carb.Direct.evidence
perl getCoverageEvidence.pl coverage_dir repeat_dir annotation_dir IE_self_targeted_spacers_blast_dir
perl getPlasmidEvidence.pl IE_self_targeted_spacers_blast_dir minimap_dir > IE_self_targeted_spacers.carb.Plasmid.evidence
perl CombineEvidence.pl IE_self_targeted_spacers.carb.Direct.evidence IE_self_targeted_spacers.carb.Plasmid.evidence IE_self_targeted_spacers.carb.Coverage.evidence > IE_self_targeted_spacers.carb.Synteny.tab

#Type IV-A3 CRISPR-Cas self targeted spacers
perl getDirectEvidence.pl IVA3_self_targeted_spacers_blast_dir > IVA3_self_targeted_spacers.carb.Direct.evidence
perl getCoverageEvidence.pl coverage_dir repeat_dir annotation_dir IVA3_self_targeted_spacers_blast_dir
perl getPlasmidEvidence.pl IVA3_self_targeted_spacers_blast_dir minimap_dir > IVA3_self_targeted_spacers.carb.Plasmid.evidence
perl CombineEvidence.pl IVA3_self_targeted_spacers.carb.Direct.evidence IVA3_self_targeted_spacers.carb.Plasmid.evidence IVA3_self_targeted_spacers.carb.Coverage.evidence > IVA3_self_targeted_spacers.carb.Synteny.tab
```
- Genome dereplication
```
dereplicator.py --distance 0.0001 genome_dir derep_0.0001
```
- Logistic regression of type I-E and type IV-A3 self-targeting spacers with ST, region, type IV-A3 CRISPR-Cas and anti-CRISPR proteins
```
#Type I-E CRISPR-Cas self targeted spacers
self_IE <- read.table(file = "self_target_spacer_IE.txt",header = T,sep = "\t")
self_IE <- lapply(self_IE, factor)
self_IE$Region<- relevel(self_IE$Region, ref = "Northern_America")
lg.self_IE <- glm(SelfTarget_IE~ST+Region+CRISPR.IV.A3+AcrIE8.1+AcrIE9.2+AcrIF11, family = binomial(), self )
summary(lg.self_IE)
exp(cbind(coef(lg.self_IE), confint(lg.self_IE)))

#Type IV-A3 CRISPR-Cas self targeted spacers
self_IVA3 <- read.table(file = "self_target_spacer_IVA3.txt",header = T,sep = "\t")
self_IVA3 <- lapply(self_IVA3, factor)
self_IVA3$Region<- relevel(self_IVA3$Region, ref = "Northern_America")
lg.self_IVA3 <- glm(SelfTarget_IVA~ST+Region+AcrIE8.1+AcrIE9.2+AcrIF11, family = binomial(), self )
summary(lg.self_IVA3)
exp(cbind(coef(lg.self_IVA3), confint(lg.self_IVA3)))
```
- Logistic regression of carbapenemases with ST, region, type IV-A3 CRISPR-Cas and anti-CRISPR proteins
```
info <- read.table(file = "ST147.dedup2.txt",header = T,sep = "\t")
#KPC
KPC_data <- info[,c(2,7,9,12:15)]
KPC_data <- lapply( KPC_data, factor)
KPC_data$ST <- relevel(KPC_data$ST, ref = "ST147")
KPC_data$Region <- relevel(KPC_data$Region, ref = "Northern_America")
lg.KPC <- glm(KPC~., family = binomial(link='logit'), KPC_data )
summary(lg.KPC)
exp(cbind(Odds_Ratio = coef(lg.KPC), confint(lg.KPC)))
#NDM
NDM_data <- info[,c(3,7,9,12:15)]
NDM_data <- lapply( NDM_data, factor)
NDM_data$Region <- relevel(NDM_data$Region, ref = "Northern_America")
lg.NDM <- glm(NDM~., family = binomial(), NDM_data )
summary(lg.NDM)
exp(cbind(coef(lg.NDM), confint(lg.NDM)))
#OXA-48-like
OXA_data <- info2[,c(4,7,9,12:15)]
OXA_data <- lapply( OXA_data, factor)
OXA_data$Region <- relevel(OXA_data$Region, ref = "Northern_America")
lg.OXA2 <- glm(OXA.48.like~., family = binomial(), OXA_data )
summary(lg.OXA)
exp(cbind(coef(lg.OXA), confint(lg.OXA)))
#CTX-M
CTX_data <- info[,c(1,7,9,12:15)]
CTX_data <- lapply( CTX_data, factor)
CTX_data$Region <- relevel(CTX_data$Region, ref = "Northern_America")
lg.CTX <- glm(CTX.M~., family = binomial(), CTX_data )
summary(lg.CTX)
exp(cbind(coef(lg.CTX), confint(lg.CTX)))
```
- Logistic regression of KPC-2 and KPC-3 with ST, region, type IV-A3 CRISPR-Cas and anti-CRISPR proteins
```
#KPC-2
KPC2_info <- read.table("KPC-2.txt",header = T,sep = "\t")
KPC2_info <- lapply( KPC2_info, factor)
KPC2_info$Region <- relevel(KPC2_info$Region, ref = "Northern_America")
lg.kpc2_sub <- glm(KPC2~ST+Region+CRISPR.IV.A3+AcrIE8.1+AcrIE9.2+AcrIF11, family = binomial(), KPC2_info )
summary(lg.kpc2_sub)
exp(cbind(coef(lg.kpc2_sub), confint(lg.kpc2_sub)))
#KPC-3
KPC3_info <- read.table("KPC-3.txt",header = T,sep = "\t")
KPC3_info <- lapply( KPC3_info, factor)
lg.kpc3_sub <- glm(KPC3~ST+Region+CRISPR.IV.A3+AcrIE8.1+AcrIE9.2+AcrIF11, family = binomial(), KPC3_info )
summary(lg.kpc3_sub)
exp(cbind(coef(lg.kpc3_sub), confint(lg.kpc3_sub)))
```
