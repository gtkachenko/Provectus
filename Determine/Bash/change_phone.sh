#!/usr/bin/env bash
count_customer=$(ps aux | grep java | grep -v grep | wc -l)
if [ ${count_customer} -eq 1 ]; then
 client_path=$(ps uax | grep java | grep -v grep | grep -o -E "catalina.base=(/[a-zA-Z_-]*){3}" | sort | uniq | awk -F "=" '{print $2}')
 sed -i "s/800-817-5187/877-806-1932/g" $client_path/conf/defaultProperties
 sed -i "s/800-817-5187/877-806-1932/g" $client_path/conf/sclm.properties
else
 for client_path in $(ps uax | grep java | grep -v grep | grep -o -E "catalina.base=(/[a-zA-Z_-]*){3}" | sort | uniq | awk -F "=" '{print $2}');
 do
    sed -i "s/800-817-5187/877-806-1932/g" $client_path/conf/defaultProperties
    sed -i "s/800-817-5187/877-806-1932/g" $client_path/conf/sclm.properties
 done
fi

if [ ${count_customer} -eq 1 ]; then
 client_path=$(ps uax | grep java | grep -v grep | grep -o -E "catalina.base=(/[a-zA-Z_-]*){3}" | sort | uniq | awk -F "=" '{print $2}')
 inf_path=$(echo $client_path | sed 's|clients|inf/releases|g')
 client_name=$(echo $inf_path | awk -F "/" '{print $5}' )
 sed -i "s/1.800.817.5187/1.877.806.1932/g" $inf_path/WEB-INF/classes/language*
 count_folders=$(find $inf_path/privateLabels/ -type d | awk -F "/" '{print $7}' | sort -u | wc -l)

  if [ ${count_folders} -eq 1 ]; then
   folder=$(find $inf_path/privateLabels/ -type d  | awk -F "/" '{print $7}' | sort -u)
   sed -i "s/1.800.817.5187/1.877.806.1932/g" $inf_path/privateLabels/$folder/html/footer.html
  else
   for folder in $(find $inf_path/privateLabels/ -type d | awk -F "/" '{print $7}' | sort -u);
   do sed -i "s/1.800.817.5187/1.877.806.1932/g" $inf_path/privateLabels/$folder/html/footer.html
   done
  fi

else
  for client_path in $(ps uax | grep java | grep -v grep | grep -o -E "catalina.base=(/[a-zA-Z_-]*){3}" | sort | uniq | awk -F "=" '{print $2}');
  do inf_path=$(echo $client_path | sed 's|clients|inf/releases|g')
     client_name=$(echo $inf_path | awk -F "/" '{print $5}' )
     sed -i "s/1.800.817.5187/1.877.806.1932/g" $inf_path/WEB-INF/classes/language*
     count_folders=$(find $inf_path/privateLabels/ -type d | awk -F "/" '{print $7}' | sort -u | wc -l)
     if [ ${count_folders} -eq 1 ]; then
      folder=$(find $inf_path/privateLabels/ -type d | awk -F "/" '{print $7}' | sort -u)
      sed -i "s/1.800.817.5187/1.877.806.1932/g" $inf_path/privateLabels/$folder/html/footer.html
     else
      for folder in $(find $inf_path/privateLabels/ -type d | awk -F "/" '{print $}' | sort -u);
      do sed -i "s/1.800.817.5187/1.877.806.1932/g" $inf_path/privateLabels/$folder/html/footer.html
      done
     fi
  done
fi

