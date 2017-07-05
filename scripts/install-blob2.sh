#!/usr/bin/env bash

PYTHONBLOB=$1

set -x

# Untar GeoPySpark
mkdir -p $HOME/.local/lib/python3.4/site-packages
cd $HOME/.local/lib/python3.4/site-packages
tar axf /blobs/$PYTHONBLOB

# Patch in NetCDF support
mkdir -p /home/hadoop/.local/lib/python3.4/site-packages/geopyspark/netcdf
touch /home/hadoop/.local/lib/python3.4/site-packages/geopyspark/netcdf/__init__.py
cat <<EOF > /home/hadoop/.local/lib/python3.4/site-packages/geopyspark/netcdf/datasets.py
import numpy as np

from pyspark import SparkContext
from math import floor, ceil
from shapely.geometry import Point

from geopyspark.geotrellis.constants import LayerType, LayoutScheme
from geopyspark.geotrellis import SpaceTimeKey, Extent, Tile
from geopyspark.geotrellis.layer import TiledRasterLayer


class Gddp(object):

    x_offset = (-360.0 + 1/8.0)
    y_offset = ( -90.0 + 1/8.0)

    def display_raster(uri, extent, day, sc):

        if not isinstance(uri, str):
            raise Exception

        if not isinstance(sc, SparkContext):
            raise Exception

        int_day = int(day)
        float_extent = list(map(lambda coord: float(coord), extent))

        jvm = sc._gateway.jvm
        rdd = jvm.geopyspark.netcdf.datasets.Gddp.display_raster(uri, float_extent, int_day, sc._jsc.sc())
        return TiledRasterLayer(sc, SPATIAL, rdd)

    def rdd_of_rasters(uri, extent, days, base_instant, sc):

        if not isinstance(uri, str):
            raise Exception

        if not isinstance(sc, SparkContext):
            raise Exception

        int_days = list(map(lambda day: int(day), days))
        float_extent = list(map(lambda coord: float(coord), extent))

        jvm = sc._gateway.jvm
        rdd = jvm.geopyspark.netcdf.datasets.Gddp.rasters(uri, float_extent, int_days, base_instant, sc._jsc.sc())
        return TiledRasterLayer(sc, LayerType.SPACETIME, rdd)

    def raster(uri, extent, day, sc):

        if not isinstance(uri, str):
            raise Exception

        if not isinstance(sc, SparkContext):
            raise Exception

        int_day = int(day)
        float_extent = list(map(lambda coord: float(coord), extent))

        jvm = sc._gateway.jvm
        tup = jvm.geopyspark.netcdf.datasets.Gddp.raster(uri, float_extent, int_day)
        cols = tup._1()
        rows = tup._2()
        jvm_array = tup._3()
        array = np.flipud(np.array(list(jvm_array)).reshape((rows,cols)))
        return array

    def samples(uri, point, days, sc):

        if not isinstance(uri, str):
            raise Exception

        if not isinstance(sc, SparkContext):
            raise Exception

        int_days = list(map(lambda day: int(day), days))
        float_point = list(map(lambda coord: float(coord), point))

        jvm = sc._gateway.jvm
        rdd = jvm.geopyspark.netcdf.datasets.Gddp.samples(uri, float_point, int_days, sc._jsc.sc())
        return rdd
EOF

set +x
