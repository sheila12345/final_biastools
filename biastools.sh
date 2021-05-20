wget http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/release/20190312_biallelic_SNV_and_INDEL/ALL.chr21.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.vcf.gz
bcftools view -s NA12878 -o chr21_NA12878.vcf ALL.chr21.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.vcf.gz
bcftools_annotate --rename-chrs GRCh38.chrom_map -o renamed_chr21_NA12878.vcf chr21_NA12878.vcf
bcftools view -i GT="het" -o chr21_het.vcf renamed_chr21_NA12878.vcf
bgzip -c renamed_chr21_NA12878.vcf > renamed_chr21_NA12878.vcf.gz

wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/001/405/GCA_000001405.15_GRCh38/seqs_for_alignment_pipelines.ucsc_ids/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna.gz
samtools faidx GCA_000001405.15_GRCh38_no_alt_analysis_set.fna -o GRCh38_chr21.fa chr21

bcftools consensus -f GRCh38_chr21.fa -o GRCh38_chr21.hapA.fa -H 1 renamed_chr21_NA12878.vcf.gz
bcftools consensus -f GRCh38_chr21.fa -o GRCh38_chr21.hapB.fa -H 2 renamed_chr21_NA12878.vcf.gz

mason_simulator -ir GRCh38_chr21.hapA.fa -o hapA_1.fq -or hapA_2.fq -oa hapA.sam -n 14400000
mason_simulator -ir GRCh38_chr21.hapB.fa -o hapB_1.fq -or hapB_2.fq -oa hapB.sam -n 14400000

bowtie2-build GRCh38_chr21.fa chr21_index

bowtie2-align-s -p 32 -x ../index/GRCh38_chr21/chr21_index -1 hapA_1.fq -2 hapA_2.fq -S hapA.bt2.sam
bowtie2-align-s -p 32 -x ../index/GRCh38_chr21/chr21_index -1 hapB_1.fq -2 hapB_2.fq -S hapB.bt2.sam

samtools sort -@ 16 -o hapA.bt2.sorted.sam hapA.bt2.sam
samtools sort -@ 16 -o hapB.bt2.sorted.sam hapB.bt2.sam

samtools merge -r bt2.sorted.sam hapA.bt2.sorted.sam hapB.bt2.sorted.sam
samtools view -ho bt2.sorted.bam bt2.sorted.sam

bedtools intersect -a bt2.sorted.bam -b chr21_het.vcf | samtools view -h > bt2.sorted.het.sam

python ref_bi.py -s bt2.sorted.het.sam -v chr21_het.vcf -f GRCh38_chr21.fa -o deeper_bt_bias.txt
