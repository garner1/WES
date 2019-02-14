REF=~/Work/genomes/Homo_sapiens.GRCh37.dna.primary_assembly.fa/GRCh37.fa
numbproc=24
datadir=/media/garner1/hdd/WES/$(exp)_$(run) 

usage:
	@echo "Usage: make rawDataDir=fullpath baseCalls=fullpath out=fullpath demultiplex"
	@echo "       make R1=fullpath R2=fullpath R1.fastp.gz=fullpath R2.fastp.gz=fullpath sampleID=string preprocessing"
	@echo "       make exp=string run=string R1=fullpath R2=fullpath align"
	@echo "       make bamfile=fullpath  dedupbam=fullpath logfile=fullpath datadir=fullpath dedup"
	@echo "       make bamfile=fullpath chrom=chr prefix=fullpathPrefix dedup_parallel"
	@echo "       make bamfilePrefix=fullpathPrefix varcall"

demultiplex:
	mkdir -p $(out)
	bcl2fastq -i $(baseCalls) -R $(rawDataDir) -o $(out) --no-lane-splitting --tiles s_[3]

preprocessing:
	fastp -i $(R1) -I $(R2) -o $(R1.fastp.gz) -O $(R2.fastp.gz) -h $(sampleID).report.html

align:
	mkdir -p ${datadir}
	bwa mem -v 1 -t ${numbproc} ${REF} $(R1) $(R2) | samtools sort -T $(exp) > ${datadir}/$(exp).bam

dedup:	
	umi_tools dedup -I $(bamfile)  --paired -S $(dedupbam) --umi-separator=: \
	--edit-distance-threshold 2 -L $(logfile) --output-stats=$(datadir)

dedup_parallel:				#parallelize wrt chromosomes
	umi_tools dedup --chrom $(chrom) -I $(bamfile) --paired -S $(prefix).$(chrom).dedup.bam --umi-separator=: \
	--edit-distance-threshold 2 -L $(prefix).$(chrom).log --output-stats=$(prefix).$(chrom)

varcall:
	bcftools mpileup -uvf ${REF} $(bamfilePrefix).dedup.bam | bcftools call -vm -Ov >  $(bamfilePrefix).vcf
