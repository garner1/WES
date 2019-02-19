REF=/home/garner1/Work/genomes/Homo_sapiens.GRCh37.dna.primary_assembly.fa/GRCh37.fa
BED=/home/garner1/Work/genomes/Homo_sapiens.GRCh37.dna.primary_assembly.fa/GRCh37.bed
numbproc=24
datadir=/media/garner1/hdd/WES/$(exp)_$(run) 
target_exome=~/Work/dataset/agilent/S07604715_Covered.woChr.bed
target_xgen=~/Work/dataset/GenesSubset/xgen.bed

usage:
	@echo "Usage: make rawDataDir=fullpath baseCalls=fullpath out=fullpath demultiplex"
	@echo "       make R1=fullpath R2=fullpath R1.fastp.gz=fullpath R2.fastp.gz=fullpath sampleID=string preprocessing"
	@echo "       make exp=string run=string R1=fullpath R2=fullpath align"
	@echo "       make prefix=Prefix2bamfile dedup"
	@echo "       make chrom=chr prefix=fullpathPrefix dedup_parallel"
	@echo "       make bamfilePrefix=fullpathPrefix varcall_mpileup"
	@echo "       make bamfilePrefix=fullpathPrefix varcall_freebayes"
	@echo "       make bamfilePrefix=fullpathPrefix alfred"
	@echo "       make multisample"

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

dedup_parallel:				#parallelize wrt chromosomes...much faster
	umi_tools dedup --chrom $(chrom) -I $(prefix).bam --paired -S $(prefix).$(chrom).dedup.bam --umi-separator=: \
	--edit-distance-threshold 2 -L $(prefix).$(chrom).log --output-stats=$(prefix).$(chrom)
	samtools merge -@ 24 $(prefix).dedup.bam $(prefix).$(chrom).dedup.bam
	samtools sort -@ 8 $(prefix).dedup.bam > $(prefix).dedup.sorted.bam

varcall_mpileup:
	samtools mpileup -uvf ${REF} $(bamfilePrefix).dedup.sorted.bam | bcftools call -vm -Ov > $(bamfilePrefix).mpileup.vcf
	bcftools norm -f ${REF} -o $(bamfilePrefix).mpileup.norm.vcf $(bamfilePrefix).mpileup.vcf

varcall_freebayes:
	freebayes -f ${REF} $(bamfilePrefix).dedup.sorted.bam > $(bamfilePrefix).freebayes.vcf
	bcftools norm -f ${REF} -o $(bamfilePrefix).freebayes.norm.vcf $(bamfilePrefix).freebayes.vcf

alfred:
	alfred qc -r ${REF} -b ${target_xgen} -j $(bamfilePrefix).json.gz -o $(bamfilePrefix).tsv.gz $(bamfilePrefix).dedup.sorted.bam

multisample:
	cat ${BED} | parallel "bcftools mpileup -Ou -f /home/garner1/Work/genomes/Homo_sapiens.GRCh37.dna.primary_assembly.fa/GRCh37.fa -r {} /media/garner1/hdd/WES/S??_BC145/S??.dedup.sorted.bam | bcftools call -vm -Ov -o /media/garner1/hdd/WES/{}.mpileup.vcf.gz"

	cat ${BED} | parallel "bcftools norm -f /home/garner1/Work/genomes/Homo_sapiens.GRCh37.dna.primary_assembly.fa/GRCh37.fa -o /media/garner1/hdd/WES/{}.mpileup.norm.vcf /media/garner1/hdd/WES/{}.mpileup.vcf.gz"
