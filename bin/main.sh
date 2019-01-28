#!/usr/bin/env bash

exp=$1				# name of the experimen, eg: MN14
run=$2				# bc124
R1=$3				# full path to R1 file
R2=$4	                        # full path to R2 file

refgen=~/Work/genomes/Homo_sapiens.GRCh37.dna.primary_assembly.fa/GRCh37.fa # full path to reference genome
numbproc=24
quality=30

echo "Processing " ${exp}_${run} 
datadir=/media/garner1/hdd/WES/${exp}_${run} 
mkdir -p $datadir
echo "Aligning ..."
if [ ! -f $datadir/$exp.bam.bai ]; then
    bwa mem -v 1 -t $numbproc $refgen $R1 $R2 | samtools view -h -Sb -q $quality - > $datadir/$exp.bam 
    samtools sort $datadir/$exp.bam  -o $datadir/$exp.sorted.bam
    mv $datadir/$exp.sorted.bam $datadir/$exp.bam 
    samtools index $datadir/$exp.bam 
fi
echo "Deduplicating ..."
if [ ! -f $datadir/$exp.bam.deduplicated.bam ]; then
    umi_tools dedup -I $datadir/$exp.bam  --paired -S $datadir/$exp.bam.deduplicated.bam --umi-separator=: --edit-distance-threshold 2 -L $datadir/$exp.group.log 
fi
if [ ! -f $datadir/$exp.bam.deduplicated.sorted.bam ]; then
    samtools sort $datadir/$exp.bam.deduplicated.bam -o $datadir/$exp.bam.deduplicated.sorted.bam
fi

echo "Coverage calculation ..."
if [ ! -f $datadir/$exp.hist.txt ]; then
    bedtools coverage -hist -abam $datadir/$exp.bam.deduplicated.sorted.bam -b ~/Work/pipelines/data/agilent/S07604715_Covered.woChr.bed > $datadir/$exp.hist.txt
fi
echo "Done!"
echo
