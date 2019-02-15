REF=~/Work/genomes/Homo_sapiens.GRCh37.dna.primary_assembly.fa/GRCh37.fa
numbproc=24
datadir=/media/garner1/hdd/WES/$(exp)_$(run) 

usage:
	@echo "Usage: make rawDataDir=fullpath baseCalls=fullpath out=fullpath demultiplex"
	@echo "       make R1=fullpath R2=fullpath R1.fastp.gz=fullpath R2.fastp.gz=fullpath sampleID=string preprocessing"
	@echo "       make exp=string run=string R1=fullpath R2=fullpath align"
	@echo "       make prefix=Prefix2bamfile dedup"
	@echo "       make chrom=chr prefix=fullpathPrefix dedup_parallel"
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
	umi_tools dedup -I $(prefix).bam  --paired -S $(prefix).dedup.bam --umi-separator=: \
	--edit-distance-threshold 2 -L $(prefix).log --output-stats=$(prefix)
	samtools sort -@ 8 $(prefix).dedup.bam > $(prefix).dedup.sorted.bam

dedup_parallel:				#parallelize wrt chromosomes
	umi_tools dedup --chrom $(chrom) -I $(prefix).bam --paired -S $(prefix).$(chrom).dedup.bam --umi-separator=: \
	--edit-distance-threshold 2 -L $(prefix).$(chrom).log --output-stats=$(prefix).$(chrom)
	samtools merge -@ 24 $(prefix).dedup.bam $(prefix).$(chrom).dedup.bam
	samtools sort -@ 8 $(prefix).dedup.bam > $(prefix).dedup.sorted.bam

varcall:
	samtools mpileup -uvf ${REF} $(bamfilePrefix).dedup.sorted.bam | bcftools call -vm -Ov > $(bamfilePrefix).vcf
