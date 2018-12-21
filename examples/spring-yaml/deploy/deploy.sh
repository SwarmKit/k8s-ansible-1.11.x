#!/bin/bash
#获取服务名称及版本
read -p "Input jarfile directory:" JARFILE
read -p "Input deploy time:" TIME

/usr/bin/mkdir /tmp/$TIME
/usr/bin/cat $JARFILE | /usr/bin/awk -F- '{name=$1"-"$2"-"$3; print name}' | awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}' > /tmp/jarname
/usr/bin/cat $JARFILE | /usr/bin/awk -F- '{print $4}' | awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}' > /tmp/jarversion
/usr/bin/cat $JARFILE | /usr/bin/awk -F- '{name=$1"-"$2"-"$3; print name}' | awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}' | sed 's#.#\l&#g' > /tmp/deployname


#
N=(`/usr/bin/cat /tmp/jarname`)
V=(`/usr/bin/cat /tmp/jarversion`)
X=(`/usr/bin/cat /tmp/deployname`)
#
NUM=`cat $JARFILE | wc -l`

for (( i=0; i < 29; i++ )); do
sed -e "s/##NAME##/${N[i]}/" -e "s/##VERSION##/${V[i]}/" -e "s/##DEPLOY##/${X[i]}/" -e "s/##TIME##/$TIME/" temp.yaml > /tmp/$TIME/`echo ${N[i]}`.yaml
done
