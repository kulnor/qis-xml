#!/bin/bash
# Generates .yang files derived formats, example, documentation
# Requires pyang (https://github.com/mbj4668/pyang)

includes="plgah-qis-types.yang"
for f in *.yang; do
    echo $f
    if [ $f != "plgah-qis-types.yang" ] ; then
        echo "-->txt"
        pyang -f tree -o "${f%.yang}.txt" $f $includes
        echo "-->jstree"
        pyang -f jstree -o "${f%.yang}.html" $f $includes
        #echo "-->uml"
        #pyang -f uml -o "${f%.yang}.uml" $f
        echo "-->sample-xml"
        pyang -f sample-xml-skeleton -o "${f%.yang}.sample.xml" $f $includes
    fi
    echo "-->yin"
    pyang -f yin -o "${f%.yang}.yin.xml" $f
done
