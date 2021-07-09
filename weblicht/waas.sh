#!/bin/bash
ENDPOINT=https://weblicht.sfs.uni-tuebingen.de/WaaS/api/1.0/chain/process
CHAIN=/home/djettka/git-clones/software-citation-dhd/weblicht/chain6420048689971300672.xml
APIKEY=###API key for Weblicht as a service###
XMLDIR=/home/djettka/git-clones/software-citation-dhd/data/DHd-Abstracts-2018/XML-files

cd $XMLDIR
mkdir -p ../TCF-files

for FILENAME in *.xml; do
	curl -X POST -F chains=@$CHAIN -F content=@$FILENAME -F apikey=$APIKEY $ENDPOINT > "../TCF-files/${FILENAME%.xml}-tcf.xml"
done

