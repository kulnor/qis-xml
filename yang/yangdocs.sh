#!/bin/bash
# Generates .yang files derived formats, example, documentation
# Requires pyang (https://github.com/mbj4668/pyang)

for f in *.yang; do
    pyang -f tree -o "${f%.yang}.txt" $f 
    pyang -f jstree -o "${f%.yang}.html" $f
    pyang -f uml -o "${f%.yang}.uml" $f
    pyang -f sample-xml-skeleton -o "${f%.yang}.sample.xml" $f
    pyang -f yin -o "${f%.yang}.yin.xml" $f
done
