find ../ -type f -name "*.bin" | \
while read I; do
   md5sum "$I"
done

