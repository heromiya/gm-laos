#! /bin/bash

#LONMIN=104.787
#LATMIN=16.568
#LONMAX=104.846
#LATMAX=16.611

LONMIN=104.7917
LATMIN=16.5863
LONMAX=104.7941
LATMAX=16.5878

ZLEVEL=18

export EPSG4326="+proj=longlat +datum=WGS84 +no_defs"
export EPSG3857="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"

cd Bing/gtiff/$ZLEVEL
#ls -l | awk '$5 != 3169 { print $9 }' | grep -v -e '^$' -e 'txt' > Z19.txt
#gdalbuildvrt -input_file_list Z19.txt Z19.vrt

rm -f tmp.txt
for ARGS in `iojs ../../../get.BingAerial.js $LONMIN $LATMIN $LONMAX $LATMAX $ZLEVEL`; do
    QKEY=`echo $ARGS | cut -d ',' -f 1`
    if [ `stat -c "%s" a${QKEY}.tif` -ne 3169 ]; then
	echo a${QKEY}.tif >> tmp.txt
    fi
done
gdalbuildvrt -overwrite -input_file_list tmp.txt tmp_bing.vrt
#gdal_translate -co compress=deflate tmp.vrt tmp_bing.tif

XMIN=`gdalinfo tmp_bing.vrt | grep "Upper Left" | sed 's/^Upper Left  (\([-.0-9]*\), \([-.0-9]*\)) .*/\1/g'`
YMIN=`gdalinfo tmp_bing.vrt | grep "Lower Right"| sed 's/^Lower Right (\([-.0-9]*\), \([-.0-9]*\)) .*/\2/g'`
XMAX=`gdalinfo tmp_bing.vrt | grep "Lower Right"| sed 's/^Lower Right (\([-.0-9]*\), \([-.0-9]*\)) .*/\1/g'`
YMAX=`gdalinfo tmp_bing.vrt | grep "Upper Left" | sed 's/^Upper Left  (\([-.0-9]*\), \([-.0-9]*\)) .*/\2/g'`
XRES=`gdalinfo tmp_bing.vrt | grep "Pixel Size" | sed 's/Pixel Size = (\([-.0-9]*\),\([-.0-9]*\))/\1/'`
YRES=`gdalinfo tmp_bing.vrt | grep "Pixel Size" | sed 's/Pixel Size = (\([-.0-9]*\),\([-.0-9]*\))/\2/'`

g.region n=$YMAX s=$YMIN e=$XMAX w=$XMIN nsres=$YRES ewres=$XRES --overwrite
r.external -o input=tmp.vrt output=bing --overwrite
v.in.ogr   -o dsn=gt/merge.shp output=gt type=boundary --overwrite




gdalwarp -overwrite -te $XMIN $YMIN $XMAX $YMAX -tr $XRES $YRES -wm 1024 -multi -co compress=Deflate $HOME/grene-mg-01/JRC-GHS/MT.vrt tmp_GHS.tif

cd ../../../
octave VillageMapping3.m

:<<EOF

#ls -l | awk '$5 != 3169 { print $9 }' | grep -v -e '^$' -e 'txt' > Z19.txt
#gdalbuildvrt -input_file_list Z19.txt Z19.vrt

    QKEY=`echo $ARGS | cut -d ',' -f 1`
    TLATMIN=`echo $ARGS |cut -d ',' -f 2`
    TLONMIN=`echo $ARGS |cut -d ',' -f 3`
    TLATMAX=`echo $ARGS |cut -d ',' -f 4`
    TLONMAX=`echo $ARGS |cut -d ',' -f 5`
    XMIN=`echo $LATMIN $LONMIN | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $1}'`
    YMIN=`echo $LATMIN $LONMIN | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $2}'`
    XMAX=`echo $LATMAX $LONMAX | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $1}'`
    YMAX=`echo $LATMAX $LONMAX | cs2cs $EPSG4326 +to $EPSG3857 | awk '{print $2}'`
    export QKEY XMIN YMIN XMAX YMAX
    
    gdalwarp -te $XMIN $YMIN $XMAX $YMAX -tr 

#done
EOF

     


exit 0
