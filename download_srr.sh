#!/usr/bin/env bash

#helpdoc
helpdoc(){
    cat <<EOF
    download_srr.sh -c CORE -i TXT
    download_srr.sh -c CORE -i TXT --cluster CLUSTER -q QUEUE -m HOST

Description:
    download_srr.sh is a tool to help download SRA file using wget and extract fastq from SRA file using fastq-dump.
    You only need to prepare a txt file in advance, the first column is the SRR number, the second column is the name of the corresponding output file, 
    the second column can be ignored, the default is the SRR number.

Usage:
    -h,--help		Prints this usage statement.
    -V,--version	Prints the download_srr.sh version.
EXECUTION:
    -c,--core		Specifies the number of cores for the task
    -i,--input		the txt file prepared in advance

CLUSTER:
    --cluster		Set the submit command, e.g.bsub.(default: None)
    -q			Set the queue name for job submit.(default: None)
    -m			set the host name for job submit.(default: None)

Example:
    download_srr.sh -c 2 -i rename.txt
    download_srr.sh -c 2 -i rename.txt --cluster bsub -q Q104C512G_X4 -m yi02
	
EOF
}

getopt -T &>/dev/null;[ $? -ne 4 ] && { echo "not enhanced version";exit 1; }
parameters=`getopt -o c:i:q:m:hv --long core:,input:,cluster:,help,version -n "$0" -- "$@"`
[ $? -ne 0 ] && { echo "Try '$0 --help' for more information."; exit 1; }
eval set -- "$parameters"

while true;do
    case "$1" in
        -h|--help) helpdoc; exit ;;
        -V|--version) echo "$0 version V1.0"; exit ;;
        -c|--core) core="$2"; shift ;;
        -i|--input) input_file="$2"; shift ;;
        --cluster) cluster="$2"; shift ;;
        -q) queue="$2"; shift ;;
        -m) hosts="$2"; shift ;;
        --)
            shift
            break ;;
        *) helpdoc; exit ;;
    esac
    shift
done 
   
time1=$(date "+%Y%m%d") 
pwd1=$(dirname $(readlink -f "$0"))  
    
if [[ ! -d "download_srr" ]]; then
    mkdir download_srr
fi

if [ ! -f download_srr/log_"$time1".log ]; then
    touch download_srr/log_"$time1".log
fi

echo "SAMPLE:" > download_srr/config.yaml
awk '{print $1}' $input_file | while read line
do
echo ' - "'$line'"' >> download_srr/config.yaml
done
#echo "OUTPUT:" >> download_srr/config.yaml
#awk '{print $2}' $input_file | while read line
#do
#echo ' - "'$line'"' >> download_srr/config.yaml
#done

echo '''configfile: "download_srr/config.yaml"

rule all:
    input:
        expand("download_srr/{sample}.txt", sample=config["SAMPLE"])

rule download:
    output:
        "download_srr/{sample}.sra"
    shell:
        """
        wget -O {output} https://sra-pub-run-odp.s3.amazonaws.com/sra/{wildcards.sample}/{wildcards.sample}
        """

rule fastq_dump:
    input:
        "download_srr/{sample}.sra"
    output:
        "download_srr/{sample}.txt"
    shell:
        """
        fastq-dump --split-3 {input} -O download_srr &>> {output}
        mv download_srr/*.fastq .
        """


''' > download_srr/download_srr.py

echo "### start download\n" > download_srr/log_"$time1".log
if [ ! "$cluster" ]; then
    nohup snakemake -s download_srr/download_srr.py -c"$core" -p --latency-wait 60 >> download_srr/log_"$time1".log 2>&1 &
elif [ "$cluster" == "bsub" ]; then
    nohup snakemake -s download_srr/download_srr.py --cluster "bsub -o download_srr/download_srr.out -e download_srr/download_srr.err -q "$queue" -m "$hosts" " -j "$core" -p --latency-wait 60 >> download_srr/log_"$time1".log 2>&1 &
else
    echo 'The "cluster" parameter can only be absent or has a value of "bsub"'
    helpdoc
    exit 1
fi
