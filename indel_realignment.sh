samtools view -ho bt2.sorted.het.modified.bam bt2.sorted.het.sam
samtools index bt2.sorted.het.modified.bam
octopus -R GRCh38_chr21.fa -I bt2.sorted.het.modified.bam -o output.vcf --bamout final.bt2.sorted.het.realigned.bam
samtools view -ho final.bt2.sorted.het.realigned.sam final.bt2.sorted.het.realigned.bam

python realignment.py

samtools sort merged.realigned.het.bam -o sorted.merged.realigned.het.bam
samtools index sorted.merged.realigned.het.bam
samtools view -ho sorted.merged.realigned.het.sam sorted.merged.realigned.het.bam

python3.7 ref_bi.py -s sorted.merged.realigned.het.sam -v chr21_het.vcf -f GRCh38_chr21.fa -o final.realigned.bt.bias
