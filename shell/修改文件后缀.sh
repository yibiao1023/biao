for i in `ls *.$1`
do
        mv $i ${i%.*}.$2
done
