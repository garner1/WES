#!/usr/bin/env bash

exp=$1				# name of the experimen, eg: MN14
run=$2				# bc124
datadir=$3			# /media/garner1/hdd/WES/${exp}_${run} 
R1=$4				# full path to R1 file
R2=$5	                        # full path to R2 file

refgen=~/Work/genomes/Homo_sapiens.GRCh37.dna.primary_assembly.fa/GRCh37.fa # full path to reference genome
numbproc=32
quality=30

echo "Processing " ${exp}_${run} 
mkdir -p $datadir
echo "Aligning ..."
bwa mem -v 1 -t $numbproc $refgen $R1 $R2 | samtools view -h -Sb -q $quality - > $datadir/$exp.bam 
# samtools sort $datadir/$exp.bam  -o $datadir/$exp.sorted.bam
# mv $datadir/$exp.sorted.bam $datadir/$exp.bam 
# samtools index $datadir/$exp.bam 
echo "Done!"
echo
